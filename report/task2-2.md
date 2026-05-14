# 实验 2-2 ANTLR 实现 SysY2022 词法分析器

## 一、任务描述

用 ANTLR4 工具生成 SysY2022 的词法分析器：读入一个 SysY 源文件，逐 token 输出"文本 : 种别名称"；遇到非法 token 报告 `Lexical error - 行号 : '串'`。空白与注释忽略，EOF 不输出。

需要补全三处：
1. `task2-2/SysyLex.g4`：补 `INT_LIT`、`FLOAT_LIT`、`ID`、词法错误 `LEX_ERR`
2. `task2-2/generated/main.h`：确认 `tokenTypeName[]` 顺序与 `.g4` 中 token 顺序一致
3. `task2-2/generated/main.cpp`：实现按规范输出 token / 报错

## 二、ANTLR4 词法规则要点

- 一行规则：`TOKEN : 正则;`，全大写避免与语法规则冲突
- 行首不许缩进；规则与正则之间不许空行
- `fragment` 修饰的规则**不会被分配 token 编号**，仅供其他规则复用
- `-> skip` 让匹配到的 token 不进入 token stream（用于空白和注释）
- **歧义消解**：先比"最长匹配"（maximal munch），同长度时**先定义的规则胜出**

## 三、关键设计

### 1. INT_LIT — 三种合法整数

```antlr
INT_LIT
    : [1-9] [0-9]*
    | '0' [0-7]*
    | '0' [xX] [0-9a-fA-F]+
    ;
```

- `[1-9][0-9]*` 十进制（首位非 0）
- `'0' [0-7]*` 单独的 `0` 或八进制（如 `075`）
- `'0' [xX] ...` 十六进制

`096` 这种"以 0 开头但有非八进制位"的串，本规则只能吃到首位 `0`，剩下的 `96` 让 `LEX_ERR` 接管，最终整串被报错。

### 2. FLOAT_LIT — 必须有小数点或指数

```antlr
FLOAT_LIT
    : ([0-9]+ '.' [0-9]* | '.' [0-9]+) EXPONENT? [fF]?
    | [0-9]+ EXPONENT [fF]?
    ;

fragment
EXPONENT : [eE] [+-]? [0-9]+ ;
```

两个分支分别处理：
- 含小数点：`2.0f` / `.04` / `1.` / `2.5e3`
- 不含小数点但**必须有指数**：`4e-04` / `020e-04`

注意第二个分支不允许"纯数字 + f"（如 `2f`），所以 `2f` 落不到 `FLOAT_LIT`，会被 `LEX_ERR` 兜住——这正是题目要的行为。

`EXPONENT` 用 `fragment` 抽出来复用，不污染 token 表。

### 3. ID

```antlr
ID : [a-zA-Z_] [a-zA-Z_0-9]* ;
```

放在所有关键字之后。`int` 这类既能匹配 `INT` 也能匹配 `ID`，长度同为 3，**先定义的 `INT` 胜出**，所以关键字优先于普通标识符——这就是为什么关键字必须放最前面。

### 4. LEX_ERR — 兜底错误规则

```antlr
LEX_ERR : [0-9] [a-zA-Z0-9_.]+ ;
```

放在文件**最后**。它专门吃"以数字开头，后面跟着字母/数字/下划线/点"的串：

| 输入 | INT_LIT | FLOAT_LIT | LEX_ERR | 胜者 |
|---|---|---|---|---|
| `123` | `123` (3) | – | `123` (3) | INT_LIT（先定义）✓ |
| `1.5` | `1` (1) | `1.5` (3) | `1.5` (3) | FLOAT_LIT（最长 + 先定义）✓ |
| `0xFF` | `0xFF` (4) | – | `0xFF` (4) | INT_LIT ✓ |
| `096` | `0` (1) | – | `096` (3) | LEX_ERR（最长）✓ |
| `9ab` | `9` (1) | – | `9ab` (3) | LEX_ERR ✓ |
| `2f` | `2` (1) | – | `2f` (2) | LEX_ERR ✓ |
| `3l14` | `3` (1) | – | `3l14` (4) | LEX_ERR ✓ |
| `020e-04` | `0` (1) | `020e-04` (7) | `020e` (4) | FLOAT_LIT ✓ |

设计要点：把 `LEX_ERR` 写得能"吞掉"非法整/浮点的所有字符，但又**不会比合法 INT_LIT/FLOAT_LIT 更长**（因为合法规则定义在前），从而让 ANTLR 的最长匹配 + 先定义胜出规则自动完成分发。

## 四、main.h token 编号对齐

ANTLR 按 token 在 `.g4` 中出现顺序从 1 开始编号（`fragment` 跳过）。最终顺序：

```
1 INT  2 FLOAT  3 VOID  4 CONST  5 RETURN  6 IF  7 ELSE  8 WHILE  9 BREAK  10 CONTINUE
11 LP  12 RP  13 LB  14 RB  15 LC  16 RC
17 COMMA  18 SEMICOLON  19 QUESTION  20 COLON
21 MINUS  22 NOT  23 ASSIGN  24 ADD  25 MUL  26 DIV  27 MOD
28 AND  29 OR  30 EQ  31 NEQ  32 LT  33 LE  34 GT  35 GE
36 INT_LIT  37 FLOAT_LIT  38 ID  39 STRING
40 WS  41 LINE_COMMENT  42 BLOCK_COMMENT
43 LEX_ERR
```

`tokenTypeName[]` 中 40-42 位置用 `""` 占位（这三个被 `-> skip` 掉，不会进 token stream，但编号占用），43 是 `LEX_ERR`。生成器用 `antlr4 Sysy.g4 -Dlanguage=Cpp ...` 跑出来的 `SysyLexer.tokens` 与本表逐项一致，已验证。

## 五、main.cpp 输出逻辑

```cpp
for (auto token : tokens.getTokens()) {
    size_t type = token->getType();
    if (type == Token::EOF) continue;
    if (type == SysyLexer::LEX_ERR) {
        std::cout << "Lexical error - " << token->getLine()
                  << " : '" << token->getText() << "'" << std::endl;
    } else {
        std::cout << token->getText() << " : "
                  << tokenTypeName[type] << std::endl;
    }
}
```

要点：
- `Token::EOF` 是 ANTLR 内部 EOF 标记（`size_t(-1)`），需跳过；不要写裸 `EOF`（会与 `<cstdio>` 的宏冲突）
- `getText()` 取原文，`getLine()` 取行号，`getType()` 取编号
- 报错格式严格按平台样例：`Lexical error - line <N> : <text>`（行号前必须带字面量 `line`，被报的串**不**加引号），`-` 与 `:` 前后各一空格

## 六、踩坑记录

1. **`STRING : '"'(ESC|.)*?'"';`** 在原文件里就有了，但 `ESC` 是 `fragment`，**不会**额外占编号。所以只要新加的 INT_LIT / FLOAT_LIT / ID 插在 STRING 之前，且 LEX_ERR 放在 BLOCK_COMMENT 之后，整个编号就和 main.h 自动对齐。

2. **不能给 `[1-9][0-9]*` 加 `[fF]?` 之类的"统一后缀"**——那样 `2f` 就会被吞成"int + 字母"的合法串，错误检测就废了。FLOAT 和 INT 的边界要清晰。

3. **`LEX_ERR` 的位置很重要**：必须在 `INT_LIT`/`FLOAT_LIT` 之后定义。原因是当二者长度相同时（如 `123`），先定义的规则胜出，必须让合法规则赢。

4. **本机未装 antlr4 C++ runtime**（`libantlr4-runtime-dev`），不能本地连编 scanner。已用 `antlr4 Sysy.g4 -Dlanguage=Cpp ...` 单独跑过，生成的 `SysyLexer.tokens` 编号与 `main.h` 完全对齐，语法层面无误。最终编译验证留给头歌平台或本地装库后做。

## 七、测试用例预期行为

- `case_1.c` `case_5.c`：纯合法 token，全部按 `text : NAME` 输出
- `case_2.c`：`0xf`/`0xc`/`075` 都是合法 INT_LIT
- `case_3.c`：`085` 触发 LEX_ERR（首位 0 但含 8）；`020e-04` 是合法 FLOAT_LIT
- `case_4.c`：`3l14`、`2f` 都触发 LEX_ERR

## 八、收获

- ANTLR4 的"最长匹配 + 先定义胜出"是写词法规则最核心的两条原则。理解它之后，关键字 vs 标识符、合法字面量 vs 词法错误的分发都不再需要复杂的回溯，只需排好规则的**顺序**和**贪婪程度**。
- 词法错误不必在主程序里写"如果不像数字那就报错"的判断，而是把"非法"也写成一条 token 规则交给 lexer 自动产出 —— 这种"声明式错误恢复"是 ANTLR 优雅的地方。
- `fragment` 的存在让我们能复用正则片段（如 EXPONENT）而不污染 token 编号空间。
