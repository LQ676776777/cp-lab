# cp-lab — 编译原理实验

华中科技大学 2026 编译原理实验仓库。

最终目标：实现一个 SysY 语言的编译器。

## 工作模式（重要）

- **不再向头歌（educoder）push**。每个子实验在头歌上是独立 git repo；本地这个仓库只保留 1-1 那次 clone 的内容作为基础，**所有后续实验代码全部写在本仓库内**。
- **备份去 GitHub**：`github` remote = 用户的私有仓库，平时 `git push`（默认就是 github）。
- **`origin` = 头歌**，保留但不再使用。**禁止误推到 origin**。任何 push 命令在本项目里默认指向 github。
- 头歌任务的初始文件如果本地没有，**直接在本地手动创建**（命名/路径按头歌的约定，方便对照）。任务说明统一收集在 `task.md`。

## 实验进度（截止日期）

| 实验 | 内容 | 截止 | 本地状态 |
|---|---|---|---|
| 1-1 | 编译工具链使用（gcc/clang/arm-gcc/make 共 4 step） | 2026-05-10 | ✅ 全部完成、已验证 |
| 1-2 | SysY 语言与运行时库（买卖股票） | 2026-05-10 | ✅ 已写（手算验证，无 SysY 编译器实测） |
| 1-4 | RISC-V 汇编（冒泡排序） | 2026-05-10 | ✅ 已写并 qemu 实测 |
| 2 | 词法分析（flex 或 ANTLR 任选一） | 2026-05-17 | 未开始 |
| 3 | 语法分析 | 2026-05-24 | 未开始 |
| 4 | 静态语义检查 | 2026-06-07 | 未开始 |
| 5-1 | 中间代码生成（LLVM IR，赋值语句翻译） | 2026-06-21 | ✅ 已写、5/5 用例本地实测通过 |
| 6-2 | RISC-V 64 代码生成（基于 LLVM） | 2026-06-28 | 未开始 |

目标平台：**RISC-V**（1-4 与 6-2 选 RISC-V，舍弃 ARM 1-3 / 6-1 选项）。

## 仓库结构

```
src/                  实验 1-1 工作区（gcc/clang/arm-gcc/make 4 step）
  shell1.sh           ✅ 1-1 step1: gcc -DBILIBILI def-test.c alibaba.c -o def-test
  shell2.sh           ✅ 1-1 step2: clang --target=armv7-linux-gnueabihf -O2 -S bar.c
  shell3.sh           ✅ 1-1 step3: arm-linux-gnueabihf-gcc + sylib.a + qemu-arm
  step4/Makefile      ✅ 1-1 step4: 构建 helloworld (g++)
  def-test.c, alibaba.c/h, bar.c, iplusf.c, sylib.a, ...

task1-2/src/step1.sy  ✅ 1-2 SysY 买卖股票最大利润
task1-4/src/bubble.s  ✅ 1-4 RISC-V 冒泡排序（已 qemu 实测）

report/               每关一份学习/报告 md
  1-1.md  1-2.md  1-4.md

lex/, test_cases/     实验 2 模板（pl0.l + .pas 用例）
lib/                  SysY 运行时库源码 sylib.c / sylib.h
input/                getarray 等输入样例（gcd / add）
demo/                 参考实现（MyCompiler.tar.gz, Plain_SyC.tar.gz, libsysy.a, compiler 二进制）
grading*.sh           本地复现头歌评测的脚本
task.md               所有头歌任务说明的合集（用户手工整理）
```

## 环境（WSL2 Ubuntu 24.04，已验证）

- gcc/g++ 13.3、clang/LLVM 18.1、Java 17、flex 2.6.4、bison 3.8.2、antlr4 4.9.2
- `arm-linux-gnueabihf-gcc` 13.3，sysroot `/usr/arm-linux-gnueabihf/`
- `riscv64-linux-gnu-gcc` 13.3，sysroot `/usr/riscv64-linux-gnu/`
- `qemu-arm` 8.2、`qemu-riscv64` 8.2

## 已知陷阱与约定

1. **`$RISCV` 变量名冲突**：`~/.bashrc` 中的 `$RISCV` 指向 OS 实验的裸机工具链 `/mnt/c/.../os_labs/riscv64-elf-gcc`（前缀 `riscv64-unknown-elf-`），**不要改**。本实验需要 Linux sysroot 时直接写 `/usr/riscv64-linux-gnu/`，或用 `$RISCV_SYSROOT`。两套命令前缀不同，PATH 共存无冲突。

2. **clang 18 默认把"隐式函数声明"当错误**。任务里的 `putint/putch` 没声明（任务描述说"可直接无视"），shell2.sh 必须加 `-Wno-error=implicit-function-declaration` 才能编通过。

3. **`sylib.a` 是 ARM 32 位预编译库**（`ar t` + `file` 验证过）。所以 shell3 的链接命令用的是 ARM 工具链 + 这个 sylib.a 没问题。RISC-V 平台后续实验若要类似的运行时库，需要从 `lib/sylib.c` 自己用 RISC-V 工具链编一个。

4. **不向头歌 push**。如果某天需要交头歌，要去对应实验的独立 git repo 单独操作，不要在本仓库内 `git push origin`。

## 远端

- `github` https://github.com/LQ676776777/cp-lab.git — 主用，备份/版本管理
- `origin` https://git.educoder.net/p536xc2re/mwxi874jqt20260508110511.git — 头歌（**不用，仅保留**）

## 参考资料

- 头歌课堂：https://www.educoder.net/classrooms/VHDQX2CZ
- 大赛 SysY 语言定义 + 运行时库 + 测试：https://gitlab.eduxiji.net/csc1/nscscc/compiler2025
- 课程任务说明：`编译实验任务和antlr_flex_bison演示.pdf`
- 用户整理的头歌任务原文：`task.md`
