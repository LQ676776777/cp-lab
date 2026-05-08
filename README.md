# cp-lab

华中科技大学 2026 春《编译原理》实验代码仓库。最终目标：实现一个 SysY 语言的编译器，目标平台 RISC-V。

## 进度

| 实验 | 内容 | 状态 |
|---|---|---|
| 1-1 | 编译工具链使用（gcc / clang / arm-gcc / make） | ✅ |
| 1-2 | SysY 语言与运行时库（买卖股票） | ✅ |
| 1-4 | RISC-V 汇编（冒泡排序） | ✅ |
| 2 | 词法分析 | ⏳ |
| 3 | 语法分析 | ⏳ |
| 4 | 静态语义检查 | ⏳ |
| 5 | 中间代码生成 | ⏳ |
| 6-2 | RISC-V64 代码生成（LLVM） | ⏳ |

## 目录

- `src/` — 实验 1-1 代码（4 个 step：shell1/2/3.sh、step4/Makefile）
- `task1-2/`、`task1-4/` — 对应实验的代码
- `report/` — 各关学习笔记与实验报告素材
- `task.md` — 头歌任务原文汇总
- `编译实验任务和antlr_flex_bison演示.pdf` — 课程任务说明

## 环境

WSL2 Ubuntu 24.04，已装 gcc/g++、clang/LLVM 18、Java 17、flex/bison、ANTLR4、`arm-linux-gnueabihf-gcc`、`riscv64-linux-gnu-gcc`、qemu-arm/riscv64。


