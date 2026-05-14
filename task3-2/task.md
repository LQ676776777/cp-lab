# 第1关：用antlr生成Sysy2022语言的语法分析器

任务描述
利用antlr生成Sysy2022的语法分析程序。要求任给一个Sysy2022语言的有语法错误源程序，能够指出错误在哪一行出现,并提示错误信息。

相关知识
为了完成本关任务，你需要掌握：
Sysy2022语言的定义。
antlr的语法规则，请查阅antlr的参考手册。
antlr官方文档

SysY2022语言的定义
SysY语言是编译系统设计赛要实现的编程语言 。 由 C语言的一个子集 扩展而成 。 每个 SysY程序 的源码存储在一个扩展名为 sy的 文件 中 。 该文件中有且仅有一个名为 main的主函数定义，还 可以包含若干全局变量声明 、 常量声明和其他 函数定义 。 SysY语言支持 int/float类型 和 元素为 int/float类型 且 按行优先存储的多维数组类型, 其中int型整数为32位有符号数,float为 32位单精度浮点数； const 修饰符用于声明常量。 SysY支持 int和 float之间的隐式类型转换，但是无显式的强制 类型转化支持。

函数
函数 可以带参数也可以不带参数，参数的类型可以是 int/float或者数组类型；函数可以返回 int/float类型的值 ，或者不返回值 (即声明为 void类型 )。
当参数为 int/float时，按值传递；而参数为数组类型时，实际传递的是数组的起始地址 ，并且形参只有第一维的长度可以空缺。 函数体由若干变量声明和语句组成。

变量声明
可以在一个变量 /常量声明语句中声明多个变量或常量 ，声
明时可以带初始化表达式。所有变量 /常量 要求先 定义再使用。在函数外声明的为全局变量 /常量 ，在函数内声明的为局部变量 /常量。

语句
语句包括赋值语句、表达式语句 (表达式可以为空 )、 语句块、 if语句、while语句、 break语句 、 continue语句 、 return语句 。语句块中可以包含若干变量声明和语句。

表达式
支持 基本的算术运算（ （+、 -、 *、 /、 %）、关系运算（==、 !=、 <、 >、<=、 >=）和逻辑运算 （!、 &&、 ||），非 0表示真、 0表示假 ，而关系运算或逻辑运算的结果用1表示真、 0表示假 。 算符的优先级和结合性 以及计算规则 (含逻辑运算的“短路计算” ”)与 C语言一致 。

文法
参见SysY2022语言定义
该定义未述及的部分，以标准C语言为准。
例如，以下程序符合SysY2022定义：

 int main() {
   int a = 10;
   int b = 3;
   if (!(a > b)) putint(1); else putint(2);
   return 0;
}
标识符和常量
标识符与C语言相同；支持十进制，八进制和十六进制整型常量和float型单精度浮点数。

其它说明
SysY有且仅有一个不带参数，返回值为int的main()函数，该函数是整个程序的入口。注意main函数的返回值是评测点之一，需正确处理。

SysY2022语言多维数组的初始化形式较多，且测试用例经常涉及，需认真研究。

antlr 的语法以及使用规则
antlr的语法解析模块是通过处理其规则文件来生成词法和语法分析器的，源文件的扩展名为.g4。
在源文件的开头是：

grammar 语法名;
如果词法文件和语法文件属于不同的文件，则应当将已经定义好的词法文件import进来：

import 词法文件名
注意：语法名要和语法文件的名称相同，例如文件名为Sysy.g4，那么就必须是grammar Sysy

剩余部分可以自行定义语法规则。
下表列出了部分常用的正则表达式：

符号	含义
|	或
[ ]	括号里的内容取其一
*	0或多个
+	1或多个
-	表达有序区间，如a-z,0-9
.	除\n以外的所有字符
\	转义符
注意：规则行务必没有缩进(即从行首开始)，且对应的动作必须在同一行开始，即正则表达式与对应动作之间不允许有空行。

你的第一条语法规则必须是compUnit** (注意大小写！)，这条语法规则将作为整个语法分析的切入点，也是后续构建AST的根节点。

语法分析程序框架
为方便同学们完成编译器的构造，实训为同学们提供了部分代码的框架，包括：

.
├── Sysy.g4   # 语法规则 
├── SysyLex.g4  # 词法规则
├── src
│   ├── Makefile # Makefile
│   ├── AstVisitor.cpp
│   ├── AstVisitor.h
│   ├── Display.h #输出接口的基类头文件
│   ├── ast.cpp  # 打印AST
│   ├── ast.h   # 头文件 
│   ├── common.h #基本类型的头文件common.h
│   ├── utils.h #输出的函数头文件utils.h
│   └── main.cpp   #main函数
└── test_cases     #测试用例，有(无)语法错误的各一组 
    ├── 012_func_defn.sy
    ├── 038_continue.sy
    ├── 067_sort_test7.sy
    ├── 087_gcd.sy
    ├── case_1.sy
    ├── case_2.sy
    ├── case_3.sy
    ├── case_4.sy
    ├── case_5.sy
    └── test2.sy
定义了一些方便输出的函数头文件utils.h
定义输出接口的基类头文件Display.h
定义基本类型的头文件common.h
方便你编程的ast.h和ast.cpp，可以在其中定义派生类型
AstVisitor.h，派生antlr生成的SysyBaseVisitor类,以创建AST。
AstVisitor.cpp，补充完整在AstVisitor.h中声明的visit方法。
main.cpp，主控程序。
makefile，makefile文件。
编程要求
在右侧编辑器修改、补充代码，完成识别Sysy2022语言的语法识别器。

在Sysy.ｇ4文件中完善语法规则 具体要完成的语法规则，是SysY语言(2022版)定义中的Stmt语法部分：
语句
Stmt → LVal '=' Exp ';' | [Exp] ';' | Block
| 'if' '( Cond ')' Stmt [ 'else' Stmt ]
| 'while' '(' Cond ')' Stmt
| 'break' ';'
| 'continue' ';'
| 'return' [Exp] ';'
  

请将上述文法未实现的几类语句:while,continue,break,return在Sysy.g4文件中完成。
注意在语句的每类产生式规则后面用#标注标签,以产生更具体的rulecontext.上述5类语句的标签分别为:while,continue,break,return.如果你采用了不同的标签,将导致产生的方法名不同,影响后续实验(你得修改改相应的名字).

只要正确给出了语法规则，即可通过第１关。

while语句的AST
antlr4生成的语法分析器采用了访问者模式，它根据Sysy.g4和SysyLex.g4文件生成SysyBaseVisitor类(还有其它类)，你需要在该基类基础上创建新的类:AstVisitor，以实现AST的构造。这个类的实现在AstVisitor.cpp文件中，对应头文件为AstVisitor.h:

 namespace frontend {
    using namespace ast;
    class AstVisitor : public SysyBaseVisitor {
    public:
        [[nodiscard]] std::unique_ptr<CompileUnit> compileUnit();
        antlrcpp::Any visitCompUnit(SysyParser::CompUnitContext *ctx) override;
        antlrcpp::Any visitConstDecl(SysyParser::ConstDeclContext *ctx) override;
        antlrcpp::Any visitInt(SysyParser::IntContext *ctx) override;
        antlrcpp::Any visitFloat(SysyParser::FloatContext *ctx) override;
        antlrcpp::Any visitVarDecl(SysyParser::VarDeclContext *ctx) override;
        antlrcpp::Any visitInit(SysyParser::InitContext *ctx) override;
        antlrcpp::Any visitInitList(SysyParser::InitListContext *ctx) override;
        antlrcpp::Any visitFuncDef(SysyParser::FuncDefContext *ctx) override;
        antlrcpp::Any visitVoid(SysyParser::VoidContext *ctx) override;
        antlrcpp::Any visitScalarParam(SysyParser::ScalarParamContext *ctx) override;
        antlrcpp::Any visitArrayParam(SysyParser::ArrayParamContext *ctx) override;
        antlrcpp::Any visitBlock(SysyParser::BlockContext *ctx) override;
        antlrcpp::Any visitAssign(SysyParser::AssignContext *ctx) override;
        antlrcpp::Any visitExprStmt(SysyParser::ExprStmtContext *ctx) override;
        antlrcpp::Any visitBlockStmt(SysyParser::BlockStmtContext *ctx) override;
        antlrcpp::Any visitIfElse(SysyParser::IfElseContext *ctx) override;
        antlrcpp::Any visitWhile(SysyParser::WhileContext *ctx) override;
        antlrcpp::Any visitBreak(SysyParser::BreakContext *ctx) override;
        antlrcpp::Any visitContinue(SysyParser::ContinueContext *ctx) override;
        antlrcpp::Any visitReturn(SysyParser::ReturnContext *ctx) override;
        antlrcpp::Any visitLVal(SysyParser::LValContext *ctx) override;
        antlrcpp::Any visitPrimaryExp_(SysyParser::PrimaryExp_Context *ctx) override;
        antlrcpp::Any visitLValExpr(SysyParser::LValExprContext *ctx) override;
        antlrcpp::Any visitDecIntConst(SysyParser::DecIntConstContext *ctx) override;
        antlrcpp::Any visitOctIntConst(SysyParser::OctIntConstContext *ctx) override;
        antlrcpp::Any visitHexIntConst(SysyParser::HexIntConstContext *ctx) override;
        antlrcpp::Any visitDecFloatConst(SysyParser::DecFloatConstContext *ctx) override;
        antlrcpp::Any visitHexFloatConst(SysyParser::HexFloatConstContext *ctx) override;
        antlrcpp::Any visitCall(SysyParser::CallContext *ctx) override;
        antlrcpp::Any visitUnaryAdd(SysyParser::UnaryAddContext *ctx) override;
        antlrcpp::Any visitUnarySub(SysyParser::UnarySubContext *ctx) override;
        antlrcpp::Any visitNot(SysyParser::NotContext *ctx) override;
        antlrcpp::Any visitStringConst(SysyParser::StringConstContext *ctx) override;
        antlrcpp::Any visitDiv(SysyParser::DivContext *ctx) override;
        antlrcpp::Any visitMod(SysyParser::ModContext *ctx) override;
        antlrcpp::Any visitMul(SysyParser::MulContext *ctx) override;
        antlrcpp::Any visitAdd(SysyParser::AddContext *ctx) override;
        antlrcpp::Any visitSub(SysyParser::SubContext *ctx) override;
        antlrcpp::Any visitGeq(SysyParser::GeqContext *ctx) override;
        antlrcpp::Any visitLt(SysyParser::LtContext *ctx) override;
        antlrcpp::Any visitLeq(SysyParser::LeqContext *ctx) override;
        antlrcpp::Any visitGt(SysyParser::GtContext *ctx) override;
        antlrcpp::Any visitNeq(SysyParser::NeqContext *ctx) override;
        antlrcpp::Any visitEq(SysyParser::EqContext *ctx) override;
        antlrcpp::Any visitAnd(SysyParser::AndContext *ctx) override;
        antlrcpp::Any visitOr(SysyParser::OrContext *ctx) override;
        antlrcpp::Any visitNumber(SysyParser::NumberContext *ctx) override;
    private:
        std::vector<std::unique_ptr<Expression>>
        visitDimensions(const std::vector<SysyParser::ExpContext *> &ctxs);
        std::unique_ptr<CompileUnit> m_compile_unit;
    };
} // namespace frontend
其中visitWhile()方法未完成，请在AstVisitor中补充代码实现这个方法：
       antlrcpp::Any visitWhile(SysyParser::WhileContext *ctx) override;
WhileContex定义在SysyParser.h(antlr4自动生成)：

   class  WhileContext : public StmtContext {
  public:
    WhileContext(StmtContext *ctx);
    antlr4::tree::TerminalNode *While();
    antlr4::tree::TerminalNode *Lparen();
    CondContext *cond();
    antlr4::tree::TerminalNode *Rparen();
    StmtContext *stmt();
    virtual void enterRule(antlr4::tree::ParseTreeListener *listener) override;
    virtual void exitRule(antlr4::tree::ParseTreeListener *listener) override;
    virtual antlrcpp::Any accept(antlr4::tree::ParseTreeVisitor *visitor) override;
  };
WhileContext派生自StmtContex,而StmtContext派生自antlr4::ParserRuleContext,后者又派生自RuleContext.它们都有一个继承自ParserTree的accept()方法.

本关的测试用例都是有语法错误的，parser将对测试用例进行语法检查，并报告语法错误输出测试用例的错误具体出现在哪一行(有可能是实际出现语法错误的下一行)。语法的检查和报错都是自动生成的，你只需正确描述语法即可。

注意 在antlr4中，语法文件的每一条规则的首字母应该是小写的！


# 第2关：用antlr生成Sysy2022语言的AST

任务描述
利用antlr生成Sysy2022语言的语法分析程序，要求任给一个语法正确的Sysy2022语言的源程序，输出其抽象语法树(AST)。

相关知识
为了完成本关任务，你需要掌握：
Sysy2022语言的定义
antlr的visitor模式
modern c++相关知识
抽象语法树AST

相关知识
请自行查阅抽象语法树的相关资料，可以参考：
gcc实现中的AST
http://www.cse.iitb.ac.in/grc/intdocs/gcc-implementation-details.html#toc_Top
c++17标准
antlr官方文档

语法分析程序框架
为方便同学们完成编译器的构造，实训为同学们提供了部分代码的框架，包括：

.
├── Sysy.g4   # 语法规则 
├── SysyLex.g4  # 词法规则
├── src
│   ├── Makefile # Makefile
│   ├── AstVisitor.cpp
│   ├── AstVisitor.h
│   ├── Display.h #输出接口的基类头文件
│   ├── ast.cpp  # 打印AST
│   ├── ast.h   # 头文件 
│   ├── common.h #基本类型的头文件common.h
│   ├── utils.h #输出的函数头文件utils.h
│   └── main.cpp   #main函数
└── test_cases     #测试用例，有(无)语法错误的各一组 
    ├── 012_func_defn.sy
    ├── 038_continue.sy
    ├── 067_sort_test7.sy
    ├── 087_gcd.sy
    ├── case_1.sy
    ├── case_2.sy
    ├── case_3.sy
    ├── case_4.sy
    ├── case_5.sy
    └── test2.sy
定义了一些方便输出的函数头文件utils.h
定义输出接口的基类头文件Display.h
定义基本类型的头文件common.h
方便你编程的ast.h和ast.cpp，可以在其中定义派生类型
AstVisitor.h，派生自antlr生成的SysyBaseVisitor类。
AstVisitor.cpp，你需要补充其中的visitWhile()方法
main.cpp，你需要根据自己编写的AstVisitor和AstRewriter来补充该文件，使其可以正确输出AST。
makefile，你可以根据需要修改makefile文件。
编程要求
本关和上一关共用一套程序。
如果你没有通过第1关,请回到第1关完善文法。
如果你已经通过第1关,则继续完成你在上一关未完成的visitWhile()方法。

antlr4生成的语法分析器采用了访问者模式，它根据Sysy.g4和SysyLex.g4文件生成SysyBaseVisitor类(还有其它类)，你需要在该基类基础上创建新的类:AstVisitor，以实现AST的构造。这个类的实现在AstVisitor.cpp文件中，对应头文件为AstVisitor.h:

 namespace frontend {
    using namespace ast;
    class AstVisitor : public SysyBaseVisitor {
    public:
        [[nodiscard]] std::unique_ptr<CompileUnit> compileUnit();
        antlrcpp::Any visitCompUnit(SysyParser::CompUnitContext *ctx) override;
        antlrcpp::Any visitConstDecl(SysyParser::ConstDeclContext *ctx) override;
        antlrcpp::Any visitInt(SysyParser::IntContext *ctx) override;
        antlrcpp::Any visitFloat(SysyParser::FloatContext *ctx) override;
        antlrcpp::Any visitVarDecl(SysyParser::VarDeclContext *ctx) override;
        antlrcpp::Any visitInit(SysyParser::InitContext *ctx) override;
        antlrcpp::Any visitInitList(SysyParser::InitListContext *ctx) override;
        antlrcpp::Any visitFuncDef(SysyParser::FuncDefContext *ctx) override;
        antlrcpp::Any visitVoid(SysyParser::VoidContext *ctx) override;
        antlrcpp::Any visitScalarParam(SysyParser::ScalarParamContext *ctx) override;
        antlrcpp::Any visitArrayParam(SysyParser::ArrayParamContext *ctx) override;
        antlrcpp::Any visitBlock(SysyParser::BlockContext *ctx) override;
        antlrcpp::Any visitAssign(SysyParser::AssignContext *ctx) override;
        antlrcpp::Any visitExprStmt(SysyParser::ExprStmtContext *ctx) override;
        antlrcpp::Any visitBlockStmt(SysyParser::BlockStmtContext *ctx) override;
        antlrcpp::Any visitIfElse(SysyParser::IfElseContext *ctx) override;
        antlrcpp::Any visitWhile(SysyParser::WhileContext *ctx) override;
        antlrcpp::Any visitBreak(SysyParser::BreakContext *ctx) override;
        antlrcpp::Any visitContinue(SysyParser::ContinueContext *ctx) override;
        antlrcpp::Any visitReturn(SysyParser::ReturnContext *ctx) override;
        antlrcpp::Any visitLVal(SysyParser::LValContext *ctx) override;
        antlrcpp::Any visitPrimaryExp_(SysyParser::PrimaryExp_Context *ctx) override;
        antlrcpp::Any visitLValExpr(SysyParser::LValExprContext *ctx) override;
        antlrcpp::Any visitDecIntConst(SysyParser::DecIntConstContext *ctx) override;
        antlrcpp::Any visitOctIntConst(SysyParser::OctIntConstContext *ctx) override;
        antlrcpp::Any visitHexIntConst(SysyParser::HexIntConstContext *ctx) override;
        antlrcpp::Any visitDecFloatConst(SysyParser::DecFloatConstContext *ctx) override;
        antlrcpp::Any visitHexFloatConst(SysyParser::HexFloatConstContext *ctx) override;
        antlrcpp::Any visitCall(SysyParser::CallContext *ctx) override;
        antlrcpp::Any visitUnaryAdd(SysyParser::UnaryAddContext *ctx) override;
        antlrcpp::Any visitUnarySub(SysyParser::UnarySubContext *ctx) override;
        antlrcpp::Any visitNot(SysyParser::NotContext *ctx) override;
        antlrcpp::Any visitStringConst(SysyParser::StringConstContext *ctx) override;
        antlrcpp::Any visitDiv(SysyParser::DivContext *ctx) override;
        antlrcpp::Any visitMod(SysyParser::ModContext *ctx) override;
        antlrcpp::Any visitMul(SysyParser::MulContext *ctx) override;
        antlrcpp::Any visitAdd(SysyParser::AddContext *ctx) override;
        antlrcpp::Any visitSub(SysyParser::SubContext *ctx) override;
        antlrcpp::Any visitGeq(SysyParser::GeqContext *ctx) override;
        antlrcpp::Any visitLt(SysyParser::LtContext *ctx) override;
        antlrcpp::Any visitLeq(SysyParser::LeqContext *ctx) override;
        antlrcpp::Any visitGt(SysyParser::GtContext *ctx) override;
        antlrcpp::Any visitNeq(SysyParser::NeqContext *ctx) override;
        antlrcpp::Any visitEq(SysyParser::EqContext *ctx) override;
        antlrcpp::Any visitAnd(SysyParser::AndContext *ctx) override;
        antlrcpp::Any visitOr(SysyParser::OrContext *ctx) override;
        antlrcpp::Any visitNumber(SysyParser::NumberContext *ctx) override;
    private:
        std::vector<std::unique_ptr<Expression>>
        visitDimensions(const std::vector<SysyParser::ExpContext *> &ctxs);
        std::unique_ptr<CompileUnit> m_compile_unit;
    };
} // namespace frontend
其中visitWhile()方法未完成，请在AstVisitor中补充代码实现这个方法：
       antlrcpp::Any visitWhile(SysyParser::WhileContext *ctx) override;
WhileContex定义在SysyParser.h(antlr4自动生成)：

   class  WhileContext : public StmtContext {
  public:
    WhileContext(StmtContext *ctx);
    antlr4::tree::TerminalNode *While();
    antlr4::tree::TerminalNode *Lparen();
    CondContext *cond();
    antlr4::tree::TerminalNode *Rparen();
    StmtContext *stmt();
    virtual void enterRule(antlr4::tree::ParseTreeListener *listener) override;
    virtual void exitRule(antlr4::tree::ParseTreeListener *listener) override;
    virtual antlrcpp::Any accept(antlr4::tree::ParseTreeVisitor *visitor) override;
  };
WhileContext派生自StmtContex,而StmtContext派生自antlr4::ParserRuleContext,后者又派生自RuleContext.它们都有一个继承自ParserTree的accept()方法.

在右侧编辑器修改、补充代码，完成识别Sysy2022语言的语法识别器。在编辑器窗一次只能显示一个文件，可以通过点击“代码文件”旁边的小三角箭头，在多个文件中自由切换。

我们已经为你提供好了Makefile文件，测试程序将直接make，编译上述程序框架中的文件，然后用make生成的程序parser来测试一组测试用例。

本关的测试用例都是没有语法错误的，parser将对测试用例进行语法分析，并输出AST。AST的输出函数不需要你完成。

由于AST的绘制并无统一标准，万一你输出的AST与预期结果不同，可向老师申请人工复核。如果老师认可你输出的AST，可以人工赋分(虽然系统仍显示未过关，但不影响成绩)。

注意事项
平台测试的antlr版本是4.9.3,若要在本地测试，我们建议你安装相应版本的antlr。
对于Linux系统，可以使用以下命令获取得到4.9.3版本的源码：

wget https://www.antlr.org/download/antlr4-cpp-runtime-4.9.3-source.zip
具体的安装方法可以见antlr c++ runtime安装文档

编译antlr程序时，需要手动链接到antlr c++ runtime库，比如:
g++ *.cpp -lantlrr-runtime 
不过，框架已为你准备了Makefile，它会自动链接antlr4 runtime库.

main
main.cpp-主函数读取待分析的源程序，送入SysyLexer中进行词法解析，通过CommonTokenStream生成token流，将结果送入SysyParser。parser.CompUnit()得到语法树的根，其中CompUnit是语法文件中的第一条语法。用类AstVisitor遍历语法树，生成AST，最后调用ast->print(std::cout,0)，打印输出AST。

helper function
utils.h中定义了一些方便输出和调试的函数，可以供你使用。
Display.h中定义了一个基类Display。后续在定义AST上节点的类型时，可以继承Display类，并实现虚函数print来方便输出。
common.h中定义一些基本类型，例如常量类型、数值类型等。