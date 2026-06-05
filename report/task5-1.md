# 实验 5-1 LLVM IR 中间代码生成（赋值语句）

## 一、任务描述

在已有的「flex/bison 前端 + AST + 访问者模式 IR 生成器」框架上，补全 `genIR.cpp` 中
`void GenIR::visit(StmtAST &ast)` 内 **赋值语句**（`sType == ASS`）的翻译。其余 visit 方法（表达式、控制流、数组初始化、函数等）框架已实现。

`StmtAST` 在 `ASS` 时持有两个子节点：

```cpp
unique_ptr<LValAST> lVal;   // 左值，如 a 或 arr[i][j]
unique_ptr<AddExpAST> exp;  // 右值表达式
```

语义：把 `exp` 的值 `store` 到 `lVal` 所代表的变量地址。

## 二、关键机制：requireLVal

`LVal` 在文法里有两处出现 —— 既是赋值语句左值，也是 `PrimaryExp` 里的取值表达式。所以
`visit(LValAST)` 用全局标志 `requireLVal` 区分：

- `requireLVal == true`：返回变量**地址**（指针 `i32*`/`float*`），不发射 `load`；
- `requireLVal == false`（默认）：发射 `load` 指令，`recentVal` 是取出的**值**。

`visit(LValAST)` 进入时立即 `bool isTrueLVal = requireLVal; requireLVal = false;`，即标志是「一次性」的，用完即清。因此赋值语句必须在 visit 左值**之前**把它置 true。

## 三、实现

```cpp
case ASS: {
    // 左值：取地址而非取值
    requireLVal = true;
    ast.lVal->accept(*this);
    Value *lValPtr = recentVal;          // i32* 或 float*

    // 右值
    ast.exp->accept(*this);
    Value *rVal = recentVal;             // i32 / float / i1

    Type *pointee = static_cast<PointerType *>(lValPtr->type_)->contained_;

    // 比较结果(i1)先扩展为 i32
    if (rVal->type_ == INT1_T)
        rVal = builder->create_zext(rVal, INT32_T);
    // 强类型对齐：store 的 val 必须等于指针所指类型
    if (pointee == INT32_T && rVal->type_ == FLOAT_T)
        rVal = builder->create_fptosi(rVal, INT32_T);   // float -> int
    else if (pointee == FLOAT_T && rVal->type_ == INT32_T)
        rVal = builder->create_sitofp(rVal, FLOAT_T);   // int -> float

    builder->create_store(rVal, lValPtr);                // 注意顺序 (val, ptr)
    break;
}
```

### 三个必须处理的点

1. **顺序**：先 `requireLVal=true` 再 visit 左值，否则左值会被 load 成右值丢失地址。
2. **类型转换**：`ir.h` 里 `create_store` 带断言
   `assert(val->type_ == static_cast<PointerType*>(ptr->type_)->contained_)`，
   所以 `int a; a = 1.5;`（float→int）、`float f; f = 3;`（int→float）必须显式转换，否则触发断言。
3. **i1 扩展**：右值可能是 `!x` 这类一元逻辑非的结果（`icmp` 产出 `i1`），先 `zext` 到 i32 再按需转 float，避免类型不匹配。`store` 参数顺序是 `(值, 地址)`，不能写反。

## 四、构建与测试

评测命令（`src/` 下）：

```bash
mkdir build && cd build && cmake .. && make -j4
./compiler -ir case.sy > case.ll
clang -o case.target case.ll ../lib/sylib.c -w
./case.target [< case.in]; echo $?    # 比对 stdout + 返回值
```

本机无 `cmake`，按 CMakeLists 等价手工编译验证：

```bash
g++ -std=c++17 -w -I. -IAST -IIR \
    AST/ast.cpp AST/parser.cpp AST/tokens.cpp \
    IR/genIR.cpp IR/ir.cpp main.cpp -o build/compiler
```

5 个测试用例（stdout + 返回值）全部通过：

| 用例 | 内容 | 结果 |
|---|---|---|
| 012_func_defn | 函数定义/调用 | ✅ exit 9 |
| 038_continue | continue 控制流 | ✅ exit 36 |
| 067_sort_test7 | 数组 + 排序（带 .in） | ✅ 97 个有序数 |
| 087_gcd | 递归 gcd（带 .in） | ✅ 13 行输出 |
| test2 | 综合 | ✅ 输出 7 |

> `067` 用 `diff` 显示一行差异，实为 `.out` 文件是 Windows CRLF（仓库在 Windows 盘上），`od -c` 验证内容字节级一致，非真实差异。

## 五、踩坑记录

1. **`ir.cpp` 缺 `#include <cstdint>`**：gcc 13 下 `*(uint64_t*)&val`（`ConstantFloat::print` 输出 float 的十六进制位模式）报 `uint64_t was not declared`。这是框架自带文件的可移植性问题，本机验证时用 `g++ -include cstdint` 旁路，未改动框架文件。educoder 评测端 gcc 版本更老可隐式包含，编译无碍。

2. **本机无 cmake**：`src/makefile` 指向的是另一套目录布局（`flex_bison/`、`printer/`），与真实 `AST/`、`IR/` 结构不符，不可用；按 `CMakeLists.txt` 的源文件清单手工 g++ 编译即可。`parser.cpp`/`tokens.cpp` 已由 bison/flex 预生成，无需再跑 `.y`/`.l`。
