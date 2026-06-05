# 实验 4-1 SysY2022 静态语义检查

## 一、任务描述

在已有的 AST + 符号表框架上实现 `Checker` 类（继承 `Visitor`）以访问者模式遍历整棵 AST，检测 10 类语义错误并通过 `ErrorReporter` 报告：

| 错误 | ErrorType | 报告者 | 触发点 |
|---|---|---|---|
| 重复变量/形参 | VarDuplicated | `InsertVar`/`InsertFunc`（已有） | `visit(DeclAST)` 间接 |
| 重复函数 | FuncDuplicated | `InsertFunc`（已有）+ `visit(FuncDefAST)` 兜底 | 函数符号表插入失败 |
| 未定义变量 | VarUnknown | `visit(LValAST)`（已有） | 符号表查不到 |
| 未定义函数 | FuncUnknown | `visit(CallAST)` | Call 时查不到 |
| 实参形参不匹配（个数/类型） | FuncParamsNotMatch | `visit(CallAST)` | 数量或类型不等 |
| return 类型不符 | FuncReturnTypeNotMatch | `visit(ReturnStmtAST)` | 当前 fn 类型 ≠ return 表达式类型 |
| 数组下标非整数 | ArrayIndexNotInt | `visit(LValAST)` + `InsertVar`（已有） | 下标 `Expr_int` 为 false |
| break 不在循环 | BreakNotInLoop | `visit(StmtAST)` | `is_inloop == false` |
| continue 不在循环 | ContinueNotInLoop | `visit(StmtAST)` | 同上 |
| 非数组用下标访问 | VisitVariableError | `visit(LValAST)` | 变量非数组但 `arrays` 非空 |

## 二、is_inloop 继承属性传播

`break/continue` 是否合法取决于"我现在在不在 while 体里"。框架给 `BlockAST`/`BlockItemAST`/`StmtAST`/`SelectStmtAST`/`IterationStmtAST` 都加了 `bool is_inloop = false;` 的继承属性 —— 父节点 visit 子节点**之前**必须把自身的 `is_inloop` 拷到子节点，**只有 `IterationStmtAST` 把 body 的 `is_inloop` 强制置 true**。废弃的 `bool in_loop` 旧字段被这个继承属性替代，原因是：if/else 内部嵌套 while 时，is_inloop 必须沿"父→子"单向传，旧字段无法处理"if 在 while 内部"和"while 在 if 内部"的对称性。

传播图（一行总结每个 visit 干了啥）：

```
BlockAST.is_inloop  -->  每个 BlockItemAST.is_inloop
BlockItemAST.is_inloop -->  StmtAST.is_inloop
StmtAST.is_inloop -->  selectStmt.is_inloop, block.is_inloop
StmtAST -->  iterationStmt.is_inloop = true（与父无关，循环节点本身入环）
SelectStmtAST.is_inloop -->  ifStmt.is_inloop, elseStmt.is_inloop
IterationStmtAST -->  stmt.is_inloop = true（保险，再置一次）
```

为什么 `iterationStmt.is_inloop = true` 还要在 `IterationStmtAST::visit` 里把 `stmt.is_inloop = true` 再置一次？因为 `IterationStmtAST` 直接持有的是 `StmtAST stmt`，"循环体本身就是一条语句"——必须保证它带上 true，**无论上层走的哪条路径**调到我（防御性传播）。冗余但安全。

## 三、报错的具体实现

### 1. `visit(LValAST)`：下标非 int + 非数组当数组用

```cpp
for (auto &exp : ast.arrays) {
    if (exp) exp->accept(*this);
    if (!Expr_int) {
        err.error(ErrorType::ArrayIndexNotInt, *ast.id);
        exit(int(ErrorType::ArrayIndexNotInt));
    }
}
...
if (!entry->is_array && !ast.arrays.empty()) {
    err.error(ErrorType::VisitVariableError, *ast.id);
    exit(int(ErrorType::VisitVariableError));
}
```

`Expr_int` 是表达式访问后留下的"上次表达式是不是 int"标志（`NumberAST::visit` / `LValAST` 末尾会刷新它）。下标必须是 int，所以 visit 完一维就立刻判。

### 2. `visit(CallAST)`：函数未定义 / 个数 / 类型

```cpp
if (entry == nullptr) {
    err.error(ErrorType::FuncUnknown, *ast.id);
    exit(int(ErrorType::FuncUnknown));
}
if (entry->func_params.size() != ast.funcCParamList.size()) {
    err.error(ErrorType::FuncParamsNotMatch, *ast.id);
    exit(int(ErrorType::FuncParamsNotMatch));
}
for (auto &exp : ast.funcCParamList) {
    exp->accept(*this);
    if (current_type.type != entry->func_params[i].type) {
        err.error(ErrorType::FuncParamsNotMatch, *ast.id);
        exit(int(ErrorType::FuncParamsNotMatch));
    }
    i++;
}
```

注意函数名前 `getint`/`putint` 等运行时库函数被前面的白名单跳过了，所以这里不会报"运行时函数未定义"。

### 3. `visit(ReturnStmtAST)`：返回类型不匹配

```cpp
if (entry->type != current_type.type) {
    err.error(ErrorType::FuncReturnTypeNotMatch, "");
    exit(int(ErrorType::FuncReturnTypeNotMatch));
}
```

`return;`（无 exp）会先把 `current_type.type` 置为 `TYPE_VOID`，所以"void 函数有 return;"是合法的，"void 函数 return 1;"才会触发。

### 4. `visit(StmtAST)`：break/continue 检查

```cpp
if (ast.sType == STYPE::BRE) {
    if (!ast.is_inloop) {
        err.error(ErrorType::BreakNotInLoop, "");
        exit(int(ErrorType::BreakNotInLoop));
    }
}
// continue 同理
```

到这一步 `ast.is_inloop` 已经被父节点传播好了，本节点只查不传。

### 5. `visit(FuncDefAST)`：兜底重复定义

```cpp
if (!InsertFunc(ast)) {
    err.error(ErrorType::FuncDuplicated, *ast.id);
    exit(int(ErrorType::FuncDuplicated));
}
```

实际上 `InsertFunc` 在检测到"已存在且 is_func"时已经 `exit`；只有"已存在但不是函数（被变量同名占了）"才会让 insert 失败返回 false。这里兜底，按 FuncDuplicated 上报（语义最接近 —— 因为这个名字已经无法再当函数名用）。

## 四、踩坑记录

1. **`Expr_int` 是状态标志，不是局部变量**。它在 `Checker` 类里是一个 `bool` 成员，每个表达式 visit 完都会刷新。用它判数组下标是否 int 只在"刚刚 visit 完那一维 exp"的窗口里有效，不能延后。

2. **`ErrorReporter::error` 里 ast 参数对部分错误是被忽略的**（FuncReturnTypeNotMatch / BreakNotInLoop / ContinueNotInLoop / VisitVariableError 都不带 ast 字符串），所以传 `""` 不影响输出格式。

3. **检测到错误必须 `exit`**。框架走的是"一遇到错就退出整个进程"的哲学（错误码 = `ErrorType` 的枚举值），而不是"收集多个错"。这里跟 gcc/clang 的多错误恢复设计不一样，简单粗暴但易于 grading。

4. **is_inloop 沿用"父传子"是 Knuth 意义上的继承属性**（vs 综合属性沿"子返父"）。在 visitor 模式里，继承属性的赋值必须放在 `accept` 之前 —— 顺序写反就废了。

5. **`if (!InsertFunc(ast))` 这一支大部分情况下走不到**（InsertFunc 内部已经 `exit`）。但仍要兜底，因为"变量名占用"这类罕见情况会让它返回 false。

## 五、本地验证

本机没有 cmake，无法跑 `grading.sh` 完整流程，但 `g++ -std=c++17 -fsyntax-only -Isrc/parser -Isrc/checker src/checker/checker.cpp src/checker/errorReporter.cpp` 通过，无 warning。完整测试留给头歌平台或本机装 cmake 后跑。

## 六、收获

- **访问者模式 + 继承属性是经典组合**：visitor 解耦"遍历"和"动作"，继承属性解决"祖先环境对后裔的影响"（如 is_inloop、当前函数返回类型、当前作用域）。SysY 这类小语言的检查器十几个 visit 方法就够了，可读性远胜手写递归。
- **符号表 `list<map>` 的栈式结构**：每进新作用域 `push_front`，每出去 `pop_front`，`Lookup` 从 front 往后线性搜 —— 这就是教科书"分层符号表"的最朴素实现，O(深度·宽度) 但对编译器够用。
- **`exit` vs 错误恢复**：教学场景下 fail-fast 让 grader 容易判分；工业编译器需要恢复（continue parsing/checking 收集多错），代价是要在每个出错点设计一个安全的恢复点（synchronization token）。后者的复杂度量级远大于前者。
- 这一关只动了 `checker.cpp` 一个文件，体现出"框架 + 钩子"良好分层带来的红利：所有的脚手架（AST、ErrorReporter、符号表）都在外面，关心的只是"在这个钩子里我应该报哪个错"。
