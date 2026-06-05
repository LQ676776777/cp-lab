# cp-lab

华中科技大学 2026 春《编译原理》实验代码仓库。最终目标：实现一个 SysY 语言的编译器，目标平台 RISC-V。

## 进度

全部实验已完成 —— SysY → 词法 → 语法 → 语义检查 → LLVM IR → RISC-V64 目标代码 全链路打通。

| 实验 | 内容 | 状态 |
|---|---|---|
| 1-1 | 编译工具链使用（gcc / clang / arm-gcc / make） | ✅ |
| 1-2 | SysY 语言与运行时库（买卖股票） | ✅ |
| 1-4 | RISC-V 汇编（冒泡排序） | ✅ |
| 2 | 词法分析（flex / ANTLR） | ✅ |
| 3 | 语法分析 | ✅ |
| 4 | 静态语义检查 | ✅ |
| 5 | 中间代码生成（LLVM IR，赋值语句翻译） | ✅ 5/5 用例本地通过 |
| 6-2 | RISC-V64 代码生成（基于 LLVM） | ✅ 5/5 用例 qemu-riscv64 实测通过 |

## 目录

- `src/` — 实验 1-1 代码（4 个 step：shell1/2/3.sh、step4/Makefile）
- `task1-2/`、`task1-4/` — 实验 1-2 / 1-4 代码
- `task2-2/` — 实验 2 词法分析
- `task3-2/` — 实验 3 语法分析
- `task4-1/` — 实验 4 静态语义检查（Checker + 符号表）
- `task5-1/` — 实验 5 LLVM IR 中间代码生成（访问者模式）
- `task6-2/` — 实验 6-2 RISC-V64 目标代码生成（LLVM TargetMachine）
- `report/` — 各关学习笔记与实验报告（含 task5-1.md、task6-2.md 等）
- `task.md` — 头歌任务原文汇总
- `编译实验任务和antlr_flex_bison演示.pdf` — 课程任务说明

## 环境

WSL2 Ubuntu 24.04，已装 gcc/g++、clang/LLVM 18、Java 17、flex/bison、ANTLR4、`arm-linux-gnueabihf-gcc`、`riscv64-linux-gnu-gcc`、qemu-arm/riscv64。


