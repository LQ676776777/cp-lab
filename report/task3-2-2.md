# 实验 3-2 第 2 关 构造 AST（补全 visitWhile）

## 一、任务描述

第 2 关与第 1 关共用工程。第 1 关已让 ANTLR 能正确解析合法的 SysY 源程序生成 parse tree；第 2 关要在 parse tree 之上由 `AstVisitor`（继承自 `SysyBaseVisitor`）以**访问者模式**生成项目自定义的抽象语法树（`ast.h` 里那一族 `Statement`/`Expression` 派生类），最终由 `ast->print(cout, 0)` 打印。

框架已经把绝大部分 visit 方法写好了，只剩 `visitWhile()` 留给我们补全。

## 二、关键文件回顾

- `task3-2/src/AstVisitor.cpp:206-212` — `visitWhile` 桩函数：`new While(nullptr, nullptr)`，需要替换为正确的 cond/body
- `task3-2/src/ast.h:372-386` — `While` 节点类：构造签名 `While(unique_ptr<Expression> cond, unique_ptr<Statement> body)`
- `SysyParser.h`（antlr 生成）— `WhileContext` 提供 `cond()` 和 `stmt()` 两个访问器（注意：**`stmt()` 不是 `vector`**，因为 while 只有一条 body 子语句；而 if-else 的 `stmt(0)/stmt(1)` 是因为有两条）

## 三、实现

仿照同文件里现成的 `visitIfElse` / `visitBreak` / `visitContinue` / `visitReturn`，结构高度一致：

```cpp
antlrcpp::Any AstVisitor::visitWhile(SysyParser::WhileContext *const ctx) {
    auto const cond_ = ctx->cond()->accept(this).as<Expression *>();
    std::unique_ptr<Expression> cond(cond_);
    auto const body_ = ctx->stmt()->accept(this).as<Statement *>();
    std::unique_ptr<Statement> body(body_);
    auto const ret = new While(std::move(cond), std::move(body));
    return static_cast<Statement *>(ret);
}
```

四步：
1. **递归 visit 条件子树**：`ctx->cond()->accept(this)` 触发 `visitLOr_`/.../`visitLValExpr` 等方法，最终回填一个 `Expression *`
2. **递归 visit body 子树**：`ctx->stmt()` 拿到唯一的 body 语句，再 accept；返回值是 `Statement *`（具体可能是 Block、Assignment、IfElse、While、Break...，多态由继承体系承担）
3. **构造 AST 节点**：`new While(cond, body)`，所有权用 `unique_ptr` 包好直接 move 进去
4. **返回值规范**：必须 `static_cast<Statement *>` 转回基类指针。caller（`visitBlock`）拿到的是 `Statement *`，如果回 `While *`，`antlrcpp::Any::as<Statement *>()` 会因为类型不严格匹配而抛 `bad_cast`

## 四、踩坑点

### 1. `ctx->stmt()` vs `ctx->stmt(0)`

`if-else` 的 stmt 在 ANTLR 文法中出现了**两次**（then 分支 + else 分支），生成的访问器是重载形式 `stmt(int i)` 返回第 i 个；而 while 只出现一次，访问器是 `stmt()`（无参，返回单个）。直接拷贝 `visitIfElse` 的代码会写错，必须照着 `WhileContext` 的实际声明来。

### 2. 必须返回 `Statement *`

`visitBlock` 中调用：
```cpp
auto const stmt = stmt_->accept(this).as<Statement *>();
```
`antlrcpp::Any::as<T>()` 是**精确类型匹配**，不做派生类→基类的隐式上行转换。哪怕 `While` 公有继承 `Statement`，存了 `While *` 也取不出 `Statement *`。所以必须先显式 `static_cast<Statement *>()` 再返回。

### 3. 所有权语义

`accept()` 返回的裸指针是"刚 `new` 出来"的、未受所有权管理的。立刻包成 `unique_ptr` 是为了避免后续早 return / 异常路径泄漏。`While` 的构造函数收的也是 `unique_ptr`，move 进去即可，零拷贝、零所有权混乱。

### 4. `new While(nullptr, nullptr)` 不是占位符

桩代码里那两个 `nullptr` 不是"任你随便传"——后续 `ast::While::print` 会去 deref `m_cond`/`m_body`。如果不替换，运行时会段错误而不是输出 AST。

## 五、本地验证

本机未装 `libantlr4-runtime-dev`，无法把 parser 完整连编。但可单独跑：

```bash
antlr4 Sysy.g4 -Dlanguage=Cpp -listener -visitor -o _gen/
grep -A 8 "class  WhileContext" _gen/SysyParser.h
```

输出的 `WhileContext` 含 `cond()` 与 `stmt()` 两个访问器，与 `visitWhile` 中调用一致，签名核对通过。完整测试留给头歌平台或本机装 `libantlr4-runtime-dev` 之后跑 `grading2.sh`。

## 六、收获

- **访问者模式的本质**：把"遍历"和"动作"解耦。ANTLR 把"如何走 parse tree"这件事写在生成的 `accept()` 里；我们只要在 visitor 子类里告诉它"遇到 X 节点要构造 Y AST 节点"。新增一种节点类型不影响旧的遍历逻辑。
- **parse tree 与 AST 不一样**：parse tree 严格按文法形状，节点冗余（比如左递归展开成的层层 `add1/add2`、单产生式包裹）；AST 是逻辑形状，二元运算只有 `BinaryExpr(op, lhs, rhs)`、循环只有 `While(cond, body)`。visitor 的工作就是把前者"拍平"成后者。
- **`antlrcpp::Any` 是带类型 tag 的可变盒子**，`.as<T>()` 必须类型严格匹配。这也是为什么所有 visit 方法的最后一句几乎都是 `return static_cast<基类 *>(ret);` —— 模板的精确匹配把"上行转换"变成了显式义务。
- **C++ 的 RAII 在 visitor 里非常合手**：`unique_ptr` + `std::move` 让节点的所有权沿着调用栈干净流动，根节点 `m_compile_unit` 持有整棵树，析构时一次性递归释放，不需要手写 destructor。
