#!/bin/bash
#export PATH=/root/.opam/system/bin:/usr/local/arm/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin:/usr/lib/jvm/jdk-11/bin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/sbin:/usr/games:/usr/local/games:/snap/bin:/opt/RISCV/riscv/bin:/opt/RISCV/riscv/bin:/opt/RISCV/riscv/bin

#export JAVA_HOME=/usr/lib/jvm/jdk-11
#export JRE_HOME=${JAVA_HOME}
#export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib:/usr/local/lib/antlr-4.9.3-complete.jar
#export PATH=${JAVA_HOME}/bin:$PATH
#alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.9.3-complete.jar:$CLASSPATH" org.antlr.v4.Tool'

#antlr4 SysyParser.g4 -Dlanguage=Cpp -listener -visitor -o generated/
#java -cp "/usr/local/lib/antlr-4.9.3-complete.jar:$CLASSPATH" org.antlr.v4.Tool Sysy.g4 -Dlanguage=Cpp -listener -visitor -o generated/


cd generated
make  2>&1 >/dev/null

         
#检查是否成功生成scanner
if [ ! -f "scanner" ];then	         
echo "编译不成功，请检查规则文件和主程序 。"
else
read -p '' case_no	
      
#执行scanner
./scanner ../test_cases/case_$case_no.c
fi
