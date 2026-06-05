# 实验 6-2 RISC-V64 目标代码生成（基于 LLVM）

## 一、任务描述

利用 LLVM 库，把上一实验（5-1）生成的 LLVM IR（`.ll`）翻译成 **riscv64** 汇编（`.s`）。
框架已搭好，只需在 `src/step1/codegen.cc` 的 `codeGenerate()` 里补三段代码：

1. 初始化目标 registry；
2. 指定目标平台三元组；
3. 准备 `addPassesToEmitFile()` 的参数（输出流、PassManager、文件类型）。

其余（`parseIRFile` 读 IR、`lookupTarget`、`createTargetMachine`、`setDataLayout`、
`pass.run`）框架已写好。

## 二、LLVM 目标代码生成流水线

```
parseIRFile(.ll) ──► Module
        │
        ▼
InitializeAll{TargetInfos,Targets,TargetMCs,AsmParsers,AsmPrinters}()   ← 补充1
        │
        ▼
target_triple = "riscv64-unknown-elf"   ← 补充2  （IR 本身不含平台信息，须手动指定）
        │
TargetRegistry::lookupTarget(triple) ─► Target
        │
Target->createTargetMachine(triple, cpu="generic", features="") ─► TargetMachine
        │
addPassesToEmitFile(pass, dest, nullptr, CGFT_AssemblyFile)   ← 补充3
        │
pass.run(*module) ─► 写出 .s
```

## 三、三段实现

### 补充1 — 初始化所有目标

```cpp
InitializeAllTargetInfos();
InitializeAllTargets();
InitializeAllTargetMCs();
InitializeAllAsmParsers();
InitializeAllAsmPrinters();
```

不初始化的话 `TargetRegistry::lookupTarget` 找不到 riscv64，返回空指针。

### 补充2 — 指定目标平台

```cpp
std::string target_triple = "riscv64-unknown-elf";
```

三元组 `<arch>-<vendor>-<sys>`：`arch=riscv64` 决定 XLEN=64；`elf` 对应裸机
newlib 工具链（评测用 `riscv64-unknown-elf-gcc` 汇编、`qemu-riscv64` 运行）。

### 补充3 — addPassesToEmitFile 参数

```cpp
auto filename = getGenFilename(ir_filename, gen_filetype);  // 087_gcd.ll -> 087_gcd.s
std::error_code EC;
raw_fd_ostream dest(filename, EC, sys::fs::OF_None);
if (EC) { errs() << "Could not open file: " << EC.message(); return 1; }
legacy::PassManager pass;
auto file_type = gen_filetype;        // 本实验为 CGFT_AssemblyFile
```

注意 `EC` 必须先声明再传给 `raw_fd_ostream`，构造后立即检查（打不开文件则报错返回）。

## 四、构建与测试

评测端流程（`src/step1` 下）：

```bash
make codegen
./codegen case.ll                      # 生成 case.s
riscv64-unknown-elf-gcc -o case.riscv case.s ../../lib/sylib.c -w
qemu-riscv64 case.riscv [< case.in]    # 比对 stdout + 返回值
```

5 个用例全部通过（与 5-1 期望输出一致）：

| 用例 | 返回值 | 输出 | 结果 |
|---|---|---|---|
| 012_func_defn | 9 | — | ✅ |
| 038_continue | 36 | — | ✅ |
| 067_sort_test7 | 0 | 97 个有序数 | ✅ |
| 087_gcd | 0 | 13 行 gcd 结果 | ✅ |
| test2 | 0 | 7 | ✅ |

## 五、评测端报错：CPU 必须用 `generic-rv64`（关键修正）

提交后评测端报：

```
'generic' is not a recognized processor for this target (ignoring processor)   ← 重复多行
LLVM ERROR: Cannot select: 0x...: ch = store<...> ... i64 = add ..., Constant:i64<-1> ...
In function: func
... Aborted (core dumped) ../src/step1/codegen
... undefined reference to `main'   ← 下游连锁：codegen 崩了没生成 .s
```

根因是框架里 `auto cpu = "generic";`（ARM 遗留值）。**较老版本的 LLVM 不认 RISC-V 的
`"generic"`**，于是「忽略该 CPU」，子目标没被正确配置成 RV64，连最基本的 `add/sub/store`
都选不出指令 → `Cannot select` → codegen 进程 Aborted。codegen 一崩，`.s` 没产出（或为空），
后面 `riscv64-unknown-elf-gcc` 链接时自然 `undefined reference to main`，那是连锁错误不是独立问题。

修正：改成 RISC-V 的通用 CPU 名 —— 与 `task.md` 示例一致：

```cpp
auto cpu = "generic-rv64";   // 原为 "generic"（ARM 遗留）
```

> 本机 LLVM 18 对 `"generic"` 和 `"generic-rv64"` 都接受，所以这个坑在本机没暴露，
> 只在评测端较老的 LLVM 上才崩——属于「本机版本比评测端新」掩盖了问题的典型情况。
> `features=""` 不受影响：无 M 扩展时 `mul/div/rem` 会降级为 libgcc 调用，不会 Cannot select。

## 六、本地验证踩坑（环境差异）

本机 LLVM 18、且 newlib 工具链与框架默认值都与评测端有差异，验证时绕了几道弯，
但**最终目标文件 `codegen.cc` 严格按框架的 LLVM 11 API 提交，未为迁就本机而改动**：

1. **框架是 LLVM 11 API，本机是 LLVM 18**。框架 `codegen.h` 用
   `llvm/Support/Host.h`、`llvm/Support/TargetRegistry.h`，源码用 `Optional<Reloc::Model>`、
   `CGFT_AssemblyFile`——都是 LLVM ≤15 的写法。本机要编译需把头路径改成
   `llvm/TargetParser/Host.h`、`llvm/MC/TargetRegistry.h`，`Optional`→`std::optional`，
   `CGFT_*`→`CodeGenFileType::*`。**这些只是版本迁移，不在我补的 3 段逻辑里**，
   故只在 `/tmp` 临时副本上改，仓库里的文件保持 LLVM 11 写法供评测端编译。

2. **本机 newlib 是 hard-float（lp64d）多库，LLVM `generic` 却生成 soft-float（rv64i）**。
   `.s` 的 `.attribute 5,"rv64i"` 标明无 F/D 扩展，与本机 hard-float libc 链接时报
   `can't link soft-float modules with double-float modules`。这是**本机运行库浮点变体单一**
   导致的，与生成的汇编正确性无关。为在本机跑通，临时把 `features` 设为 `+m,+a,+f,+d,+c`、
   `opt.MCOptions.ABIName="lp64d"`，让 LLVM 输出 rv64gc/lp64d 硬浮点，再与本机 hard-float
   newlib 链接——5 例全部正确运行。**仓库提交版仍保持 `cpu="generic"`、`features=""`**
   （框架原值，评测端工具链含 soft-float 多库，按原值即可）。

3. `riscv64-linux-gnu-gcc`（glibc）只有 lp64d 单库、无 soft-float 变体，故走的是
   `os_labs` 下的 `riscv64-unknown-elf-gcc`(newlib) + `qemu-riscv64` 路线验证。

> 一句话：`codegen.cc` 的三段补充逻辑正确，IR→riscv64 汇编→qemu 执行全链路实测通过；
> 本机所有 workaround 只为补足「LLVM 版本差异」与「本机缺 soft-float 运行库」两项环境差，
> 均未写进交付文件。
