# 实验2-2在本目录下进行实验

任务描述
利用 antlr 工具生成SysY2022语言的词法分析器，要求输入一个SysY2022语言源程序文件,比如test.cpp，词法分析器能输出该程序的token以及token的种别。

相关知识
为了完成本关任务，你需要掌握：antlr 的语法和使用规则。请参考 antlr 手册。

antlr 的语法以及使用规则
antlr的词法解析模块是通过处理其源文件来生词法分析器的，源文件的扩展名为.g4，其语法被分为两个部分：

lexer grammar '文件名'
词法定义
语法名部分：antlr处理的.g4文件中是可以把词法和语法部分放在一起进行处理的，当我们要将他们分开，单独处理词法部分时，需要加上lexer关键词。grammar的文件名必须和.g4前面的名称对应上。
词法部分为一系列TOKEN的定义，一般使用正则表达式书写。在定义TOKEN时，应用全大写字母，避免和语法规则混淆。
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

SysY2022的词法
SysY2022的语言定义参见:
SysY2022语言定义

为便于评测，统一约定单词符号(token)对应的输出种别名称如下表所示:

单词	种别名称
'int'	INT
'float'	FLOAT
'void'	VOID
'const'	CONST
'return'	RETURN
'if'	IF
'else'	ELSE
'while'	WHILE
'break'	BREAK
'continue'	CONTINUE
'('	LP
')'	RP
'['	LB
']'	RB
'{'	LC
'}'	RC
,	COMMA
;	SEMICOLON
?	QUESTION
:	COLON
!	NOT
=	ASSIGN
-	MINUS
+	ADD
*	MUL
/	DIV
%	MOD
&&	AND
||	OR
==	EQ
!=	NE
<	LT
<=	LE
>	GT
>=	GE
标识符	ID
int型字面量	INT_LIT
float型字面量	FLOAT_LIT
注意:2.0f, .04, 4e-04都是合法的float型字面量,但2f不是合法的float型字面量；123,076,0xFF等都是合法的int型字面量,但096就不是合法的int型字面量。

编程要求
现有文件:
├── Sysy.g4      # SysY2022 antlr4 grammar规则文件
├── SysyLex.g4   # SysY2022 antlr4 Lexical规则文件
├── generated    # 生成程序及主控程序目录
│   ├── Makefile # Makefile
│   ├── main.cpp # 主控程序
│   └── main.h   # 头文件
└── test_cases   # 测试用例
    ├── case_1.c
    ├── case_2.c
    ├── case_3.c
    ├── case_4.c
    └── case_5.c
main.h定义了token种别编号对应的输出字符串

请在右侧代码编辑器窗口，完善词法规则(SysyLex.g4)和相关程序(main.cpp,main.h)，实现对Sysy程序的词法识别，并按要求输出token及种别，或者报告词法错误。

你需要补充的具体内容
(一)在SysyLex.g4文件中，补充以下词法规则
(1) 标识符ID;
(2) int型字面量INT_LIT;
(3) float型字面量FLOAT_LIT;
(4) 词法错误
(二)确认main.h中定义的token种别名称与其种别编号一致
对于下面的词法规则：

lexer grammar SysyLex;
// keyword
INT : 'int';
FLOAT : 'float';
VOID : 'void';
CONST : 'const';
RETURN : 'return';
IF : 'if';
ELSE : 'else';
WHILE : 'while'; 
antlr4会生成如下的C++代码（头文件):

   enum {
    INT = 1, FLOAT = 2, VOID = 3, CONST = 4, RETURN = 5, IF = 6, ELSE = 7, 
    WHILE = 8
  };
为正确输出token种别名称(如INT)而非其编号(1)，在main.h文件中定义了string类型的数组：

 std::string tokenTypeName[] = {"", "INT", "FLOAT", "VOID", "CONST", "RETURN", "IF", "ELSE",   "WHILE", "BREAK", "CONTINUE", "LP", "RP", 
    "LB", "RB", "LC", "RC", "COMMA", "SEMICOLON", "QUESTION", 
    "COLON", "MINUS", "NOT", "ASSIGN", "ADD", "MUL", "DIV", 
    "MOD", "AND", "OR", "EQ", "NEQ", "LT", "LE", "GT", 
    "GE", "INT_LIT", "FLOAT_LIT", "ID", "STRING", "", 
    "", "", "LEX_ERR"};
请确保token的名称与其定义的顺序一致。由于token从1开始编号，故token名称数组的0号元素置为"",对于不需要输出的种别名称亦可用""略过。

(三)在main.cpp中，正确显示token及token的种别信息.

对于识别出的合法的单词(token)，直接输出：
识别出的单词 : 种别名称

(“:”号前后各留一空格，一个单词占一行）
对于所有的词法错误，应该报告词法错误，例如: '9ab'，'2f'等，应该报告错误，报告格式为：
Lexical error - 行号 : 识别出来的串(如'9ab')

(“-”和“:”号前后各留一空格，报告之后换行)
对于whitespace和注释，直接忽略；
main.cpp
#include <iostream>
#include "antlr4-runtime.h"
#include "SysyLexer.h"
#include "SysyParser.h"
#include "main.h"
using namespace antlr4;
int main(int argc, const char* argv[]) {
    std::ifstream stream;
    stream.open(argv[1]);
    ANTLRInputStream input(stream);
    //ANTLRInputStream input(std::cin);
    SysyLexer lexer(&input);
    CommonTokenStream tokens(&lexer);
    tokens.fill();
   
    for (auto token : tokens.getTokens()) {
  
        //简单粗暴的输出token信息并不符合题目要求
        //std::cout << token->toString() << std::endl;
    }
    /* 语法分析
    SysyParser parser(&tokens);
    tree::ParseTree* tree = parser.compUnit();
    std::cout << tree->toStringTree(&parser) << std::endl << std::endl;
    */
    return 0;
}    
main.cpp中，token的输出(该输出句语已被注释掉)直接调用了token->toString()，其直接输出token及token的种别编号，这并不符合实验要求，请查阅antlr4的API手册，调用合适的方法，获得所需信息，提示：

token->getText() - 取得token对应的文本符号串

token->getLine() - 取得token所在的行号

token->getType() - 取得token的种别编号,如果token及其词法规则的定义顺序与main.h中tokenTypeName[]数组元素的顺序一致，则tokenTypeName[token->getType()]可获得token种别名称。
注意，当token的Type值为lexer.LEX_ERR应报词法错误；当Type值为lexer.EOF时，应忽略，不输出。

测试说明
平台会对根据你编写规则文件自动生成识别词法的C++代码，并与main.cpp连编生成词法分析器scanner ，并用该分析器分析每组测试用例，输出结果。当所有测试用例输出的结果都与预期结果一致时，即通过此关。

你可以在命令行输入以下命令，将antlr4规则翻译成C++词法分析程序：
antlr4 Sysy.g4 -Dlanguage=Cpp -listener -visitor -o generated/
其中anlr4是ava -cp "/usr/local/lib/antlr-4.9.3-complete.jar:$CLASSPATH" org.antlr.v4.Tool的别称。
生成的词法分析程序将存放在指定的generated 文件夹。
如果生成顺利，可以执行

 cd generated
 make
编译生成词法分析器scanner。接着，可以运行该分析器分析测试用例(以case_1.c为例)：
./scanner ../test_cases/case_1.c

