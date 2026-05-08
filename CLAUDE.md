# cp-lab — 编译原理实验

华中科技大学 2026 编译原理实验仓库。从头歌（educoder）平台 clone 下来，本地完成后再上传评测。

最终目标：实现一个 SysY 语言的编译器。

## 实验路径与目标平台

- **头歌平台 6 个实验，占 70 分**（自动评测）。课程目标 PDF：`编译实验任务和antlr_flex_bison演示.pdf`
- **目标平台：RISC-V**（已选定，对应实验 1-4 和实验 6-2）
- ARM 是另一种选择，本仓库部分模板脚本是 ARM 版本（见下方"已知陷阱"）

实验进度（截止日期）：

| 实验 | 内容 | 截止 |
|---|---|---|
| 1 | 工具/语言/平台（1-1, 1-2, **1-4 RISCV**） | 2026-05-10 |
| 2 | 词法分析（flex 或 ANTLR 任选一） | 2026-05-17 |
| 3 | 语法分析 | 2026-05-24 |
| 4 | 静态语义检查 | 2026-06-07 |
| 5 | 中间代码生成 | 2026-06-21 |
| 6 | 目标代码生成（**6-2 riscv64**，基于 LLVM） | 2026-06-28 |

## 仓库结构

```
src/         学生代码（实验 1 各小步：def-test.c, bar.c, iplusf.c, helloworld 等）
  shell1.sh  实验 1-1 编译命令脚本（学生填写）
  shell2.sh  实验 1-1 clang 交叉编译脚本（学生填写）— 当前为 ARM 模板
  shell3.sh  实验 1-1 cc + qemu 链路脚本（学生填写）— 当前为 ARM 模板
  step4/     实验 1-2 SysY 运行时库相关（Makefile + helloworld）
lex/         实验 2 flex 模板（pl0.l）
test_cases/  实验 2 测试用例（case_1.pas ... case_5.pas）
input/       gcd / add 测试输入
lib/         SysY 运行时库 sylib.c / sylib.h
demo/        参考资料（MyCompiler.tar.gz, Plain_SyC.tar.gz, libsysy.a）
grading*.sh  本地复现头歌评测的脚本
```

## 环境（已验证可用）

WSL2 Ubuntu 24.04。已装：
- gcc/g++ 13.3、Java 17、clang/LLVM 18.1、flex 2.6.4、bison 3.8.2、antlr4 4.9.2
- `riscv64-linux-gnu-gcc` 13.3（apt 包，sysroot `/usr/riscv64-linux-gnu/`）
- `qemu-riscv64` 8.2

端到端验证命令（已通过，返回 89）：
```bash
riscv64-linux-gnu-gcc -S -O2 sort.c -o sort.s
riscv64-linux-gnu-gcc sort.s -o sort.elf
qemu-riscv64 -L /usr/riscv64-linux-gnu/ sort.elf
```

## 已知陷阱

1. **`$RISCV` 变量名冲突**：`~/.bashrc` 里 `$RISCV` 已被 OS 实验占用，指向 `/mnt/c/.../os_labs/riscv64-elf-gcc`（裸机 `riscv64-unknown-elf-` 工具链）。**不要改它**，OS 实验还要用。本编译实验需要 sysroot 时，要么直接写 `/usr/riscv64-linux-gnu/`，要么定义 `$RISCV_SYSROOT`。两套工具链命令前缀不同，PATH 里可以并存。

2. **`src/shell2.sh` 和 `src/shell3.sh` 是 ARM 模板**（`arm-linux-gnueabihf-gcc`、`qemu-arm`）。既然选了 RISC-V，写入这两个脚本时要替换为：
   - `arm-linux-gnueabihf-gcc` → `riscv64-linux-gnu-gcc`
   - `qemu-arm -L $ARM` → `qemu-riscv64 -L /usr/riscv64-linux-gnu/`
   - 汇编后缀 `.arm.s` → `.riscv.s`（按需）

   头歌平台上对应的实验题目本身可能就是 ARM 版（1-3）；提交前确认题面到底要哪种架构，再决定是改脚本还是切回 ARM。

3. **头歌交叉编译器命名**：PDF 第 11 页标注头歌服务器上是 `riscv64-unknown-elf-gcc`（裸机版），与本地 apt 装的 `riscv64-linux-gnu-gcc`（Linux 用户态）**不是同一个**。提交时如果 grading 脚本依赖具体命令名，需要适配。

## 头歌平台

- 实验主页：https://www.educoder.net/paths/r72isgp8
- 课堂：https://www.educoder.net/classrooms/VHDQX2CZ
- 大赛参考（SysY 语言定义+运行时库+测试用例）：https://gitlab.eduxiji.net/csc1/nscscc/compiler2025
