任务描述
本关任务：使用 C++ 语言，将上一实验生成的LLVM IR中间代码翻译成riscv64的目标代码。

允许调用LLVM的库函数实现上述功能。

相关知识
利用 IR 构造模块
模块是LLVM IR的顶层数据结构。每个模块包含一系列函数，每个函数包含一系列基本块，每个基本块包含一系列指令。模块还包含一些外围实体以支持其模型，例如全局变量、目标数据布局、外部函数原型，还有数据结构声明。为了生成 LLVM IR 的目标代码，我们需要先利用 IR 构造模块，以便后续的处理。你需要使用 llvm/IRReader/IRReader.h 头文件中的 parseIRFile 函数，具体的使用方法请参照 LLVM 官方文档。

以下是IRReader.h的局部说明，其中parseIR用到分析程序内存给定MemoryBuffer中的二进制形式的中间代码。parserIRFile读取一个IR文件并进行分析，将其转换成 LLVM Assembly并返回一个Module(确切説返回指向该Module的智能指针)。

/// If the given MemoryBuffer holds a bitcode image, return a Module
/// for it.  Otherwise, attempt to parse it as LLVM Assembly and return
/// a Module for it.
/// \param DataLayoutCallback Override datalayout in the llvm assembly.
std::unique_ptr<Module> parseIR(
    MemoryBufferRef Buffer, SMDiagnostic &Err, LLVMContext &Context,
    DataLayoutCallbackTy DataLayoutCallback = [](StringRef) { return None; });
/// If the given file holds a bitcode image, return a Module for it.
/// Otherwise, attempt to parse it as LLVM Assembly and return a Module
/// for it.
/// \param DataLayoutCallback Override datalayout in the llvm assembly.
std::unique_ptr<Module> parseIRFile(
    StringRef Filename, SMDiagnostic &Err, LLVMContext &Context,
    DataLayoutCallbackTy DataLayoutCallback = [](StringRef) { return None; });
 
目标三元组
目标代码的生成依赖于具体的机器体系结构。我们使用一个被称作目标三元组 (target triple) 的字符串来描述一个特定的体系结构，格式为 <arch><sub>-<vendor>-<sys>-<abi>。可以在命令行执行如下命令，来获取当前机器的目标三元组：

$ clang --version | grep Target
Target: x86_64-unknown-linux-gnu
在 C++ 中，可以使用 LLVM 提供的 sys::getDefaultTargetTriple() 函数获取当前机器的目标三元组。

auto TargetTriple = sys::getDefaultTargetTriple();
头歌平台的服务器是X86_64的Ubuntu系统，但是本实验要求生成的目标平台代码是riscv64，所以，并不需要获取本机(native)的三元组。

如果LLVM IR包含的目标机器的信息，可以使用module的 getTargetTriple() 方法来获取:

  /// Get the target triple which is a string describing the target host.
  /// @returns a string containing the target triple.
  const std::string &getTargetTriple() const { return TargetTriple; } 
具体使用请参照 LLVM 文档。
由于在上一实验中生成的LLVM IR并不包含目标平台的任何信息，你也可以调用module的setTargetTriple方法在代码中直接设定目标平台.该方法与getTargetTriple方法都定义在LLVM的module.h中：

  /// Set the target triple.
  void setTargetTriple(StringRef T) { TargetTriple = std::string(T); }
 
示例:

 auto target_triple = "armv7-unknown-linux-gnueabihf";
 module->setTargetTriple(target_triple); 
接下来，我们初始化所有用来生成目标代码的目标。

InitializeAllTargetInfos();
InitializeAllTargets();
InitializeAllTargetMCs();
InitializeAllAsmParsers();
InitializeAllAsmPrinters();
之后，我们就可以利用 TargetRegistry::lookupTarget 函数，通过刚刚得到的目标三元组得到一个对应的目标。这个函数定义在 llvm/Support/TargetRegistry.h 头文件中，你可以参照 LLVM 官方文档来学习它的使用方法。

目标机器
我们还需要一个目标机器 (TargetMachine)，这个类提供了我们将要生成的代码的目标平台的完整机器描述。如果我们想要针对特定的特性（如 SSE）或特定的 CPU（如英特尔的 Skylake），我们可以在这里指定。

要查看 LLVM 知道哪些特性和 CPU，我们可以使用 llc。例如，让我们来看看 arm(riscv64也类似)：

$ llvm-as < /dev/null | llc -march=arm -mattr=help
Available CPUs for this target:
  arm1020e      - Select the arm1020e processor.
  arm1020t      - Select the arm1020t processor.
  arm1022e      - Select the arm1022e processor.
  arm10e        - Select the arm10e processor.
  ...
  
Available features for this target:
  32bit                    - Prefer 32-bit Thumb instrs.
  8msecext                 - Enable support for ARMv8-M Security Extensions.
  a12                      - Cortex-A12 ARM processors.
  a15                      - Cortex-A15 ARM processors.
  a17                      - Cortex-A17 ARM processors.
  ...
在本任务中，为了简化问题，我们只需要使用通用 CPU，不需要任何附加功能、选项或重定位模型。

示例如下：

auto CPU = "generic-rv64";
auto Features = "";
TargetOptions opt;
auto RM = Optional<Reloc::Model>();
auto TheTargetMachine = Target->createTargetMachine(TargetTriple, CPU, Features, opt, RM);
具体的函数功能和变量意义可以参照 LLVM 官方文档。

配置模块
这部分的操作并不是必须的（这也意味着跳过这一步并不影响你的程序的正确性），但是指定模块的数据布局和目标三元组将有利于后续对程序的优化。可以使用 module 的 setDataLayout 和 setTargetTriple 方法。

生成目标代码
一切准备就绪，我们已经利用 IR 构造了模块，并且获得了目标平台的体系结构信息，可以利用 LLVM 生成目标代码了。LLVM用pass对 IR 进行操作(比如对IR进行某类优化，亦或是生成最终的目标代码)。 我们需要定义一个 pass：

legacy::PassManager pass;
然后我们需要使用 TargetMachine 类的 addPassesToEmitFile 方法将它设置为生成目标代码的 pass。

TheTargetMachine->addPassesToEmitFile(pass, dest, nullptr, gen_filetype)
可以查阅文档详细了解这个函数，现在要关注的是 dest，它是一个 raw_pwrite_stream 类型的变量，用来定义要写入文件的位置。参考代码如下：

auto Filename = "output.o";
std::error_code EC;
raw_fd_ostream dest(Filename, EC, sys::fs::OF_None);
为了方便评测，代码中已经为你提供了生成文件名的函数 std::string getGenFilename(const std::string &ir_filename， const CodeGenFileType &gen_filetype)，请使用它获取文件名。

最后，运行该 pass，生成目标代码。

pass.run(*module);
dest.flush();
程序框架
为方便编程，已提供了必要的程序框架：

.
├── lib   #运行时库函数
│   ├── libsysy.a #此为arm的运行时库
│   ├── sylib.c   #riscv64将直接用.c
│   └── sylib.h
├── llvm_ir #测试用例及其输入
│   ├── 012_func_defn.ll
│   ├── 038_continue.ll
│   ├── 067_sort_test7.in
│   ├── 067_sort_test7.ll
│   ├── 087_gcd.in
│   ├── 087_gcd.ll
│   ├── test2.ll
├── src  #程序文件夹 
│   └── step1
│       ├── Makefile   #Makefile
│       ├── codegen.cc  #生成目标代码的函数
│       ├── include
│       │   └── codegen.h  #头文件
│       ├── main.cc  #主控程序
└── test-cases #备用测试用例及输入和预期输出
    ├── calculator.ans
    ├── calculator.c
    ├── calculator.in
    ├── dijkstra.ans
    ├── dijkstra.c
    ├── dijkstra.in
    ├── hanoi.ans
    ├── hanoi.c
    ├── hanoi.in
    ├── max-flow.ans
    ├── max-flow.c
    ├── max-flow.in
    ├── percolation.ans
    ├── percolation.c
    └── percolation.in
你需要关注的文件只有三个：

main.cc
codegen.h
codegen.cc
codegen.h
请勿与LLVM的CodeGen.h混淆。该头文件申明了两个函数：

bool codeGenerate(const std::string &ir_filename,
                  const CodeGenFileType &gen_filetype);
std::string getGenFilename(const std::string &ir_filename,
                           const CodeGenFileType &gen_filetype);
 
codeGenerate()
函数codeGenerate()将一个给定的LLVM IR文件翻译成指定类型的.o或.s文件。目标文件名将根据输入文件和输出文件的类型自动命名。
函数codeGenerate()有两个形参：

std::string &ir_filename - LLVM IR文件名
CodeGenFileType - 目标代码的类型
CodeGenFileType在LLVM的CodeGen.h中定义:

  // Code generation optimization level.
  namespace CodeGenOpt {
    enum Level {
      None = 0,      // -O0
      Less = 1,      // -O1
      Default = 2,   // -O2, -Os
      Aggressive = 3 // -O3
    };
  }
  /// These enums are meant to be passed into addPassesToEmitFile to indicate
  /// what type of file to emit, and returned by it to indicate what type of
  /// file could actually be made.
  enum CodeGenFileType {
    CGFT_AssemblyFile,
    CGFT_ObjectFile,
    CGFT_Null         // Do not emit any output.
  };
  // Specify what functions should keep the frame pointer.
  enum class FramePointerKind { None, NonLeaf, All };
 
其中枚举类型CodeGenOpt定义了优化级别，分别对应-O0,-O1,-O2,-O3等； 
枚举类型FramePointerKind用于对叶子函数优化。

本实验用到的是CodeGenFileType类：
枚举类CodeGenFileType定义了需要输出(emit)的文件类型：

CGFT_AssemblyFile - 汇编文件(.s)
CGFT_ObjectFile - 目标代码(.o)
CGFT_Null - 不需要输出
getGenFilename()
函数getGenFilename()与codeGenerate()的形参完全相同，其功能是根据输入的IR文件和指定输出文件的类型返回一个文件名。
示例：
输入：(012_func_defn.ll,CGFT_AssemblyFile)
返回：012_func_defn.s

以上两个函数，均在codeGen.cc中实现。

main.cc
main.cc接受命令行参数argv[1](测试用例.ll文件)，然后直接调codeGenerate(argv[1], llvm::CGFT_AssemblyFile)生成目标代码。

codegen.cc
genGenFilename()和codeGenerate()方法均在该程序文件中实现。

编程要求
在codeGen.cc中补充代码，实现codeGenerate()函数，完成目标代码的生成，能将上一实验生成的LLVM IR翻译成ARMv7的汇编代码。

以下是上一实验生成012_func_defn.ll:

@a = global i32 0
declare i32 @getint()
declare float @getfloat()
declare i32 @getch()
declare i32 @getarray(i32*)
declare i32 @getfarray(float*)
declare void @putint(i32)
declare void @putfloat(float)
declare void @putch(i32)
declare void @putarray(i32, i32*)
declare void @putfarray(i32, float*)
declare void @_sysy_starttime(i32)
declare void @_sysy_stoptime(i32)
declare void @__aeabi_memcpy4(i32*, i32*, i32)
declare void @__aeabi_memclr4(i32*, i32)
declare void @__aeabi_memset4(i32*, i32, i32)
declare void @llvm.memset.p0.i32(i32*, i8, i32, i1)
define i32 @func(i32 %arg_0) {
label_entry:
  %v1 = alloca i32
  store i32 %arg_0, i32* %v1
  %v2 = alloca i32
  %v3 = load i32, i32* %v1
  %v4 = sub i32 %v3, 1
  store i32 %v4, i32* %v1
  %v5 = load i32, i32* %v1
  store i32 %v5, i32* %v2
  br label %label_ret
label_ret:                                                ; preds = %label_entry
  %v6 = load i32, i32* %v2
  ret i32 %v6
}
define i32 @main() {
label_entry:
  %v0 = alloca i32
  %v1 = alloca i32
  store i32 10, i32* @a
  %v2 = load i32, i32* @a
  %v3 = call i32 @func(i32 %v2)
  store i32 %v3, i32* %v1
  %v4 = load i32, i32* %v1
  store i32 %v4, i32* %v0
  br label %label_ret
label_ret:                                                ; preds = %label_entry
  %v5 = load i32, i32* %v0
  ret i32 %v5
}
 
注意它不包含任何目标平台的信息。你需要在程序中指定目标平台。

你需要补充的代码共分三段，包括：

初始化目标的registry;
设置目标平台;
初始化addPassesToEmitFile()函数的参数。
测试说明
平台首先make codegen以生成可运行的codegen；
然后运行codegen，并以测试用例(.ll)为输入，将其翻译成.s（arm的汇编码）；
下一步用riscv64-unknown-elf-gcc编译上一步生成的汇编代码，并连接sy的库函数源程序sylib.c，生成riscv64目标平台的可执行代码；
接着用qemu-riscv64虚拟机执行riscv64的目标代码。如果测试用例需要输入，评测程序会自动给目标程序“喂”输入。
最后，比较输出结果(包含测试用例return的结果)。如果结果完全一致，即通过评测。
上述评测中的任何一步出错都会报告错误信息并退出评测。通常,错误多来自你写的代码codegen.cc。请根据反馈的错误信息，修改代码，并重新评测。

注：不要尝试在命令行make codegen,因为生成的目标代码的size超过头歌允许的最大限制. 但这不影响你在评测结束后，在命令行观察llvm_ir文件夹里生成的riscv64汇编文件(.s)和riscv64可执行文件(.riscv)。 

如果确有需要，你可以自行将项目文件git clone到本地测试。

如果程序有错，评测程序每次都会提示出错信息，并指出出错的行号。请根据提示修改代码并重新评测。

有兴趣的同学甚至可以对IR文件进行若干个pass的优化，然后再执行目标代码生成的pass，并比较优化前后生成的汇编代码的不同。