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
    SysyLexer lexer(&input);
    CommonTokenStream tokens(&lexer);

    tokens.fill();

    for (auto token : tokens.getTokens()) {
        size_t type = token->getType();
        if (type == Token::EOF) continue;
        if (type == SysyLexer::LEX_ERR) {
            std::cout << "Lexical error - line " << token->getLine()
                      << " : " << token->getText() << std::endl;
        } else {
            std::cout << token->getText() << " : "
                      << tokenTypeName[type] << std::endl;
        }
    }

    return 0;
}
