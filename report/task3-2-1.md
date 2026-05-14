# 实验 3-2 第 1 关 ANTLR 语法分析器（补全 Stmt 文法）

## 一、任务描述

在已有的 `Sysy.g4` 框架内补完 Stmt 部分剩余的 4 条语句产生式：`while` / `break` / `continue` / `return`。每条规则后用 `#` 标签命名（标签名固定，影响后续 `AstVisitor` 中生成的 `visitXxx` 方法名）。

ANTLR4 自动从语法文件生成的递归下降分析器自带语法错误恢复与定位，因此本关本身不需写一行 C++，只要规则正确，遇到非法源程序会自动报"哪一行的什么错"。

## 二、SysY 语句文法（最终）

```antlr
stmt
    : lVal Assign exp Semicolon                # assign
    | exp? Semicolon                           # exprStmt
    | block                                    # blockStmt
    | If Lparen cond Rparen stmt (Else stmt)?  # ifElse
    | While Lparen cond Rparen stmt            # while
    | Break Semicolon                          # break
    | Continue Semicolon                       # continue
    | Return exp? Semicolon                    # return
    ;
```

四条新增规则一一对应 SysY2022 文法中：

| SysY 文法 | ANTLR 规则 | 标签 |
|---|---|---|
| `'while' '(' Cond ')' Stmt` | `While Lparen cond Rparen stmt` | `# while` |
| `'break' ';'` | `Break Semicolon` | `# break` |
| `'continue' ';'` | `Continue Semicolon` | `# continue` |
| `'return' [Exp] ';'` | `Return exp? Semicolon` | `# return` |

`[Exp]` 在 BNF 里代表"可选"，在 ANTLR 里写作后缀 `?`。

## 三、实现要点

### 1. 终结符要用 SysyLex.g4 里的 Token 名

`SysyLex.g4` 已经把所有关键字/符号定义成大写驼峰的 Token：`While`、`Break`、`Continue`、`Return`、`Lparen`、`Rparen`、`Semicolon`。规则里**不能**再写裸字面量 `'while'`/`';'`，否则 ANTLR 会偷偷生成匿名 token 与现有 Token 冲突，导致歧义警告或行为不符。

### 2. 标签名严格按要求

任务明文规定标签必须是 `while`/`continue`/`break`/`return`（小写）。ANTLR 据此生成的上下文类是 `WhileContext` / `BreakContext` / `ContinueContext` / `ReturnContext`，对应 visitor 方法 `visitWhile/...`。后续 `AstVisitor` 已经按这些名字声明（`visitWhile` 等），改名会破坏链路。

### 3. `If…Else` 的悬空 else 问题

原有的 `ifElse` 写成 `If Lparen cond Rparen stmt (Else stmt)?`，ANTLR 默认采用"贪婪匹配"（greedy），即 `else` 优先与最近的 `if` 结合 —— 这正是 C 的语义，所以无需额外处理。新增 while/return 不影响这个分支。

### 4. `return exp?` 的可选表达式

`return ;` 与 `return a + 1 ;` 都合法，用 `exp?` 表达。ANTLR 解析 `return ;` 时 `exp?` 匹配空，不会回溯失败。

## 四、验证

```bash
antlr4 Sysy.g4 -Dlanguage=Cpp -listener -visitor -o _gen/
```

无 warning 无 error，`_gen/SysyParser.cpp/.h` 正常产出。AstVisitor 头文件中已声明的 `visitWhile`/`visitBreak`/`visitContinue`/`visitReturn` 与 ANTLR 生成的上下文类名匹配。

本关测试用例都是有语法错误的源文件，平台用生成的 parser 跑这些用例，期望它正确报"第 N 行有错误"。规则正确即可通过，错误恢复机制由 ANTLR 默认实现承担。

## 五、收获

- `#` 标签是 ANTLR4 给同一规则的多个分支命名 alternative 的语法糖，会让生成的 visitor 拆出独立方法 —— 这是和"在 visitor 里手动 `dispatch ctx.children[0]`"相比最大的便利。
- 词法在 `SysyLex.g4`、语法在 `Sysy.g4` 分离的工程结构，强迫终结符必须先有 Token 名再被引用，避免了字符串重复定义的混乱。
- ANTLR 的语法错误报告/恢复"开箱即用"，写文法时只需保证产生式正确，不需要像手写递归下降那样自己去 `synchronize()`。这是声明式工具的红利。
