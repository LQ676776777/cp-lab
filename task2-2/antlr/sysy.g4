lexer grammar sysy;

import literals;

INT : 'int';
FLOAT : 'float';
VOID : 'void';

CONST : 'const';

IF : 'if';
ELSE : 'else';
WHILE : 'while';
BREAK : 'break';
CONTINUE : 'continue';
RETURN : 'return';
FOR : 'for';
DO : 'do';

ASSIGN : '=';

ADD : '+';
MINUS : '-';
MUL : '*';
DIV : '/';
MOD : '%';

EQ : '==';
NE : '!=';
LT : '<';
GT : '>';
LE : '<=';
GE : '>=';

NOT : '!';
AND : '&&';
OR : '||';

COMMA : ',';
SEMICOLON : ';';
LP : '(';
RP : ')';
LB : '[';
RB : ']';
LC : '{';
RC : '}';
QUESTION : '?';
COLON : ':';

ID : [A-Za-z_][_0-9A-Za-z]*;

WHITESPACE : [ \t\r\n]+ -> skip;

LINECOMMENT : '//' ~[\r\n]* -> skip;
BLOCKCOMMENT : '/*' .*? '*/' -> skip;
