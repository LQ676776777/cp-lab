# 实验一 工具，语言与平台

## 1-1 GCC编译器的使用

**gcc**
任务描述
本关任务：用gcc编译器，指定合适的命令行选项，编译出符合要求的二进制可执行代码。

相关知识
为了完成本关任务，你需要掌握：1.熟悉gcc编译器
2.gcc的命令行选项-D

GCC介绍
GCC（GNU Compiler Collection，GNU编译器套件）是由GNU开发的编程语言编译器。GNU编译器套件包括C、C++、 Objective-C、 Fortran、Java、Ada和Go语言前端，也包括了这些语言的库（如libstdc++，libgcj等。）

C++是GNU针对C++语言的编译器。

GCC的命令行选项
常用的命令行选项有：

-E 只执行预处理
-c 编译或汇编源文件，不执行链接
-S 完成编译但不执行汇编，产生汇编文件
-o file 指定输出的文件为file。如果未指定该选项，在Linux下生成的可执行代码将被命名为缺省值a.out。指定输出文件名时，应使用缺省的后缀：预处理后：.i； 汇编代码：.s；目标代码.o等。
-DSOMETHING 宏定义,即预处理语句“#define SOMETHING”中的宏SOMETHING。
-I 指定头文件的搜索路径
-O 批定优化级别，如：-O2,-O3等。编译系统设计赛在决赛阶段将用-O2选项对测试用例在目标平台上进行编译优化，用优化的可执行代码的执行时间/你的编译器生成的汇编代码在目标平台上汇编后生成的可执行代码运行时间\*100 所得的值作为你在该测试用例上的性能得分。
更详细的命令行选项，请参考：
GCC 选项总结

编程要求
有以下源程序和.h文件：
def-test.c
alibaba.c
alibaba.h

def-test.c
#include <stdio.h>
#include "alibaba.h"
int main(void)
{
printf( "Instructor: Hello, I am your instuctor, please introduce yourself.\n");

#ifdef BILIBILI
printf("BILIBILI: My name is Bili, 先生お久しぶりです!\n");
#endif

alibaba();
return 0;
}
alibaba.h
#ifndef **ALIBABA**
#define **ALIBABA**

void alibaba(void);

#endif  
alibaba.c
#include <stdio.h>
#include "alibaba.h"

void alibaba(void)
{
int y = 24;
printf("Alibaba: My name is Alibaba, I am %d years old.\n", y);

#ifdef BILIBILI
printf("Alibaba: Hey Bili, 你娃最近赚钱没得？\n");
#endif
}
根据提示，在右侧编辑器填写编译指令，用gcc编译器编译def-test.c和alibaba.c, 并指定合适的编译选项，生成二进制可执行代码def-test。执行的结果应当包括Bilibili的自我介绍以及Alibaba对BiliBili的喊话。

**clang**
任务描述
本关任务：用clang编译器，并指定合适的编译选项，将一个SysY2022语言的源程序“翻译”成一个优化的armv7的汇编代码。

相关知识
为了完成本关任务，你需要掌握：
1.熟悉clang编译器
2.clang的编译选项

Clang
Clang是一个用C++编写、基于LLVM、发布于LLVM BSD许可证下的编译器，它与GCC高度兼容，并在某些方面超越了gcc。

clang++是针对C++的编译器。

关于clang的详细介绍，参见：Clang编译器用户手册

更多LLVM编译工具链，参见：The LLVM Compiler Infrastructure

Clang命令行编译选项
Clang的命令行编译选项基本继承了gcc的大部分编译选项，如：-S, -o, -O, -c等。它也有一些gcc不支持的编译选项，比如交叉编译，通过指定-target参数，可以在X86的平台将C源程序“翻译”成其它平台下的汇编代码或二进制代码。

比如，下列编译指令将helloworld.c编译成armv7架构,linux操作系统，遵循gnueabihf嵌入式应用程序二进制接口，并支持arm硬浮点的汇编代码:

clang -S -target armv7-linux-gnueabihf helloworld.c -o helloword.s

更多clang命令行编译选项，请参考：
Clang Command Line Options

编程要求
有符合SysY2022语言的源程序bar.c:(编译系统设计赛中，这类程序扩展名被指定为.SY，为让编译器和编辑器能正确识别该文件，在本实验中，仍以C为扩展名，望知晓！以后不再说明)：

 int bar(){
    int a = 10*10;  //这里在编译时可以直接计算出100这个值，这叫做“常数折叠”
    int b = 20;     //这个变量没有用到，可以在代码中删除，这叫做“死代码删除”
    if (a>0){       //因为a一定大于0，所以判断条件和else语句都可以去掉
        return a+1; //这里可以在编译器就计算出是101
    }
    else{
        return a-1;
    }
}
int main() {
    int a = bar();      //这里可以直接换成 a=101
    putint(a);  //SysY的运行时函数，输出整数a
    putch(10);  //SysY运行时函数，输出换行符
}
上述程序在编译时，显然有较大优化空间，main()函数可以直接输出整数101和一换行即可。

本关的任务，是用clang编译器把上述程序bar.c“翻译”成优化的(优化级别O2)armv7架构，linux系统，符合gnueabihf嵌入式二进制接口规则，并支持arm硬浮点的汇编代码（本程序并没有浮点数）。汇编代码文件名为bar.clang.arm.s。

由于程序的第16，17行分别调用了SysY2022运行时库函数，并不是标准C语言的一部分，又未在任何地方声明，编译时会有警告性提示信息，可以直接无视。

请将编译指令填写在右侧编辑窗口的shell2.sh文件中。

**交叉编译器arm-linux-gnueabihf-gcc和qemu-arm虚拟机的使用**
交叉编译器arm-linux-gnueabihf-gcc
arm-linux-gnueabihf-gcc是Linaro旗下的交叉编译器，其功能与gcc相当，区别在于它可以将C源程序编译成arm汇编代码或二进制可执行程序。由于本实验的要完成的编译器只需将SysY2022(C的子集)源程序编译成arm汇编代码，出于排错、学习或者性能比较的需要，我们可能需要比较自己的编译器生成的arm汇编代码，与编译工具生成的arm汇编代码有多大区别。所以，熟悉这款交叉编译器是有意义的。当然，这一工作也可以直接在目标平台(比如arm架构的树莓派）上直接用gcc -S来完成，但当arm资源有限时，用唾手可得的X86 Linux服务器来完成这件工作就显得十分有意义。

arm-linux-gnueabihf-gcc跟gcc的用法十分类似，主要命令行编译选项有：

-S 只生成汇编代码
-O 优化选项，如-O2,-O3等
-march= 设置具体的arm型号，如armv8,armv7等，编译系统设计赛的目标平台指定为armv7。
-mfpu= 设置浮点运算单元，比如vfp,vfpv3,vfpv4,neon,neon-vfpv4等。
-mfloat-abi= 在编译带有浮点参数的函数时采用的接口中规范，只有三个选项：
-mfloat-abi=soft
-mfloat-abi=softfp
-mfloat-abi=hard
"soft"选项：表明不使用FPU硬件，而是使用GCC的整数算术运算来模拟浮点运算。

"softfp"选项：表明要使用FPU硬件来做浮点运算，只是，函数的参数传递到整数寄存器（r0-r3）中，然后再传递到FPU中。

"hard"选项：表明要使用FPU硬件来做浮点运算，并且，函数的参数直接传递到FPU的寄存器（s0、d0）中。

上述-mfpu选项的设置，要看目标平台具体支持哪此选项。在linux系统，可以通过在命令行键入：
cat /proc/cpuinfo
查看cpu的特性。比如，编译大赛组委会提供的树莓派其CPU具有以下特性：
processor: 0-3 (共4个)
model name: ARMv7 Processor rev 3 (v7l)
Features: half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm crc32
即支持vpf,vpfv3,vfpv4,vfpd32,neon等特性。其中neon是ARM的Advanced SIMD(单指令多数据)技术的俗称，一个128位的neon寄存器可以被分割为4个32位寄存器(即可装入4个int或单精度浮点型float)，在作数组运算或矩阵运算时，可以考虑这种机制以提高性能(每次取4个地址连续的int或float进行运算).

qemu-arm虚拟机
在arm资源缺乏时，可以在X86架构的linux服务器上用qemu-arm虚拟机来运行arm的可执行代码，以检查测试用例是否被正确编译。
使用的方法是：
qemu-arm -L /usr/arm-linux-gnueabihf/ arm可执行代码
在educoder的命令行上，可以用环境变量$ARM代替arm运行时库的路径，但在在脚本文件中，请直接指定arm运行时库路径。

编程要求
程序iplusf.c如下：

extern void putfloat(float a);
extern float getfloat();
extern int getint();
extern void putch(int a);
int main(){
    int a;
    float b;
    a = getint();
    b = getfloat();
    putfloat(a + b);
    putch(10);
    return 0;
} 
程序iplusf.c调用SysY2022运行时库函数读取一个整数a和一个单精度浮点数b，然后输出两数的和，再输出一个换行符。由于浮点数的引入，不得不另加extern语句声明运行时库函数，以使编译器
能正确传参。但请注意，SysY2022语言的程序本身是不会有extern语句的，编译器需要正确处理运行时库函数的不同类型的参数。

请编写一个sell脚本文件shell3.sh，先后完下列任务

用arm-linux-gnueabihf-gcc 将iplusf.c编译成arm汇编代码iplusf.arm.s 
再次用arm-linux-gnueabihf-gcc 汇编iplusf.arm.s，同时连接SysY2022的运行时库sylib.a，生成arm的可执行代码iplusf.arm
用qemu-arm运行iplusf.arm

**make的使用**
任务描述
本关任务：编写一个 Makefile，使用 make 完成项目的构建。

相关知识
为了完成本关任务，你需要掌握：简单 Makefile 的编写。

make 是什么
GNU Make（下称 make）是一个用来控制从源文件生成可执行文件或者其他非源文件的项目构建工具。比如可以执行命令

make foo 
构建可执行文件 foo。但实际上执行这条命令并不会起作用，因为 make 不知道如何构建 foo。

make 通过一个叫作 Makefile 的文件获得构建程序的规则。所以为了使用 make 构建项目，我们需要学习书写 Makefile。

Makefile 文件的格式
Makefile文件由一系列规则构成。每条规则的形式如下：

target ... : prerequisites ...
    command
    ...
上面第一行冒号前面的部分，叫做目标，冒号后面的部分叫做依赖；第二行必须由一个 tab 键起首，后面跟着命令。这描述了文件的依赖关系，也就是说，target 这一个或多个的目标文件依赖于 prerequisites 中的文件，其生成规则定义在 command 中。prerequisites 中如果有一个或以上的文件比 target 文件要新的话，command 所定义的命令就会被执行。

目标通常是文件名，指明 make 命令所要构建的对象，比如上文的 foo 。目标可以是一个文件名，也可以是多个文件名，之间用空格分隔。目标也可以不是一个文件名，而是表示某种操作，这类目标被称作伪目标。

.PHONY : clean
clean :
    -rm $(objects)
在上面的示例中，.PHONY 表示 clean 是一个“伪目标”，所以 make 就不会去检查是否存在一个叫做 clean 的文件。

依赖通常是一组文件名，之间用空格分隔。它指定了目标是否需要被重新构建：只要有一个依赖不存在，或者有过更新，目标就需要重新构建。

命令表示了如何更新目标文件，由一行或多行的 Shell 命令组成。它是构建目标的具体指令，它的运行结果通常就是生成目标文件。

Makefile 文件的基本语法
注释
在 Makefile 中表示注释。

foo.o: foo.c def.h
    # This is a comment.
    cc -c foo.c
使用变量
Makefile 允许使用变量。变量会在被使用的地方展开，就像 C 语言中的宏一样。

objects := main.o foo.o bar.o
CXX := clang++
CXXFLAGS := -Wall -g -O2 -std=c++17
main: $(object)
    $(CXX) -o main $(objects) $(CXXFLAGS)
等价于：

main: main.o foo.o bar.o
    clang++ -o main main.o foo.o bar.o -Wall -g -O2 -std=c++17
Makefile 提供了 4 种赋值运算符：

VARIABLE = value    // make 会将整个 Makefile 展开后，将 value 最终的值赋给 VARIABLE
VARIABLE ?= value    // 如果 VARIABLE 没有被赋值过，则赋值为 value
VARIABLE := value    // make 会将 Makefile 展开到当前位置，将 value 当前的值赋给 VARIABLE
VARIABLE += value    // 为 VARIABLE 追加 value
隐含规则
如果将一个 Makefile 中的所有命令都写出来，是比较繁琐的：

objects := main.o foo.o bar.o
CXX := clang++
CXXFLAGS := -Wall -g -O2 -std=c++17
main: $(object)
    $(CXX) -o main $(objects) $(CXXFLAGS)
main.o: main.cc
    $(CXX) -c main.cc
foo.o: foo.cc
    $(CXX) -c foo.cc
bar.o: bar.cc
    $(CXX) -c bar.cc
可以发现，像 $(CXX) -c main.cc 这样的命令是比较 trivial 的，make 可以使用隐含规则对类似于这种的常用规则进行自动推导。这里介绍一些隐含规则。

对于 C 程序，<n>.o 目标的依赖会自动推导为 <n>.c ，并且其生成命令是 $(CC) –c $(CPPFLAGS) $(CFLAGS)。
对于 C++ 程序，<n>.o 的目标的依赖会自动推导为 <n>.cc 或是 <n>.C ，并且其生成命令是 $(CXX) –c $(CPPFLAGS) $(CXXFLAGS) 。
对于汇编和汇编预处理，<n>.o 的目标的依赖会自动推导为 <n>.s ，默认使用编译器 as ，并且其生成命令是： $ (AS) $(ASFLAGS) 。 <n>.s 的目标的依赖会自动推导为 <n>.S ，默认使用 C 预编译器 cpp ，并且其生成命令是： $(AS) $(ASFLAGS) 。
链接Object文件时，<n> 目标依赖于 <n>.o ，通过运行 C 的编译器来运行链接程序生成（一般是 ld ），其生成命令是： $(CC) $(LDFLAGS) <n>.o $(LOADLIBES) $(LDLIBS)。
在使用隐含规则时，要注意对应变量的定义。

根据隐含规则，上述 Makefile 可以被简化：

objects := main.o foo.o bar.o
CXX := clang++
CXXFLAGS := -Wall -g -O2 -std=c++17
main: $(object)
    $(CXX) $(objects) -o $@ 
%.o: %.cc
    $(CXX) $(CXXFLAGS) -c %<
上述代码中，$<代表依赖项（.cc文件），$@代表目标（.o文件）。

这里仅介绍了一些基本的 Makefile 语法，同学们也可以在网上对 Makefile 的高级语法进行更深入的学习。

编程要求
根据提示，在右侧编辑器完成 Makefile，完成 helloworld 项目的构建。为了方便评测，你需要为 helloworld 目标编写一条生成一个名为 helloworld 的可执行文件的规则。

## 1-2 Sysy语言与运行时库

任务描述
本关任务：熟悉SysY语言和运行时库，并用该语言写一个解决“买卖股票的最佳时机”的程序。

相关知识
语言
SysY 语言是编译系统设计赛要实现的编程语言。由 C 语言的一个子集扩展而成。每个 SysY 程序的源码存储在一个扩展名为 sy 的文件中。该文件中有且仅有一个名为 main 的主函数定义，还可以包含若干全局变量声明、常量声明和其他函数定义。SysY 语言支持 int/float 类型和元素为 int/float 类型且按行优先存储的多维数组类型，其中 int 型整数为 32 位有符号数;float 为 32 位单精度浮点 数;const 修饰符用于声明常量。SysY 支持 int 和 float 之间的隐式类型，但是无显式的强制类型转化支持。
关于SysY语言的详细定义，请参见：
SysY2022语言定义-V1.pdf

运行时库
SysY 语言本身没有提供输入/输出(I/O)的语言构造，I/O 是以运行时库方式提供，库函数可以在 SysY 程序中的函数内调用。部分 SysY 运行时库函数的参数类型会超出 SysY 支持的数据类型，如可以为字符串。SysY 编译器需要能处理这种情况，将 SysY 程序中这样的参数正确地传递给 SysY 运行时库。

SysY语言的运行时库详解请参见：
SysY2022运行时库-V1.pdf

编程要求
给定一个数组 prices ，它的第 i 个元素 prices[i] 表示一支给定股票第 i 个交易日的价格(假定股价是整数)。你只能选择某个交易日买入这只股票，并选择在未来的另一个交易日卖出该股票。设计一个算法来计算你所能获取的最大利润，并返回这个最大利润值。如果你不能获取任何利润，返回 0 。
示例1：
输入：7 1 5 3 6 4
输出：5
解释：在第 2 个交易日（股票价格 = 1）的时候买入，在第 5 个交易日（股票价格 = 6）的时候卖出，最大利润 = 6-1 = 5 。注意利润不能是 7-1 = 6, 因为不能在买入前卖出股票。

示例2：
输入：7 6 4 3 1
输出：0
解释：卖出价大于买入价才能获利。5个交易日股价一直在下跌，没有获得利润的可能。

程序用
int prices[N];
存储某支股票连续N个交易日的股价，其中N是常量。要求：

完成函数maxProfit()，其输入是股价组成的数组，返回值是可以获得的最大利润；
在main()里添加适当语句,完成：
接受N个整数(连续N个交易日的股价)的输入;
调用maxProfit()，获得可能的最大利润，并输出该数值，然后换行；
main()函数返回1。
提示：0 <= prices[i] <= 10000

根据提示，在右侧编辑器补充代码，完成上述要求。

注意SysY语言没有for语句,没有++，--，+=， -=等运算符。

task1-2/src/step1.sy
```cpp
const int N = 10;
int prices[N]; 

// 请完成函数maxProfit(),其输入为股价数组，输出为可获得的最大利润 
int maxProfit(int prices[]){
    // ----------  开始




    // ----------- 结束
}

// main()接收连续N个交易日的股价输入并存入数组prices[],
// 接着调用maxProfit()求可能的最大利润，然后输出该值，并换行。
int main(){
    // 股价数组的输入：



    int best = maxProfit(prices);
    //结果输出：

   return 1;
}

```

## 1-4 RISC-V 汇编（1-3是arm）

任务描述
RISC-V 汇编。

本关任务：用RISCV 汇编编写一个对数组排序的函数。

相关知识
1.RISC-V介绍
2.RISC-V汇编

RISC-V介绍
RISC-V(读作“RISC-FIVE”)是基于精简指令集计算(RISC)原理建立的开放指令集架构(ISA)，V表示为第五代RISC(精简指令集计算机).
RISC-V架构简单，完全开源。

RISC-V汇编
RISCV汇编请参考相关资料

编程要求
本关任务：完善一个按升序对数组进行排序的arm汇编程序。

其中，主程序(SysY语言)的代码如下：

// getint(),putint(),putch()为SysY运行时函数
// bubblesort()在bubblesort.s中定义
int main(){
int n = 10;
int a[10];
int i = 0;
while (i < n) {
a[i] = getint(); //输入整数
i = i + 1;
}
i = bubblesort(a, 10);
while (i < n) {
putint(a[i]);//输出a[i]
putch(32); //输出空格
i = i + 1;
}
putch(10);//输出换行
return 0;
}
主程序的流程为

输入10个整数组成的数组
调用函数bubblesort（位于bubble.s文件中）进行排序
显示排序后的结果
注意：
调用者sort.c用bubblesort(a,10)的返回值初始化循环变量i,故bubblesort()的返回值必须为0。

你只需要补充完善以下riscv64汇编代码(bubblesort.s)，以完成程序中的bubblesort函数。

        .text
        .align  1
        .globl  bubblesort
        .type   bubblesort, @function

bubblesort:
.L2:
li a0,0
ret
.size bubblesort, .-bubblesort
说明：函数bubblesort的C语言说明如下
int bubblesort(int \*arr, int n)
main调用bubblesort之前，将数组arr的首地址保存在寄存器a0中，数组元素的个数n保存在寄存器a1中。bubblesort返回值为0，由a0传递（调用者借返回值 给循环变量赋初值 ）。
src/bubble.s
```s
        .text
        .align  1
        .globl  bubblesort
        .type   bubblesort, @function
bubblesort:


.L2:
        li      a0,0
        ret
        .size   bubblesort, .-bubblesort

```