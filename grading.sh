#!/bin/bash

#make clean（清除上一次的评测程序）
rm pl0.l lex.yy.c > /dev/null 2>&1  

#新建文本，准备存放程序输出结果
touch tokens.txt

#新建文本，准备存放错误信息	         
touch error.txt		

#读取键盘输入到typ中         
read -p '' typ	
	         
flex pl0.l > error.txt 2>&1	         
#用flex编译源文件，保存错误信息

#检查是否成功生成
if [ ! -f "lex.yy.c" ];then	         
echo "所需c文件:lex.yy.c 不存在，编译未成功，请检查源程序的格式。"
echo "下面是错误信息："
cat error.txt
else
#生成最终的可执行程序文件
gcc -o pl0 lex.yy.c         
#执行最终生成的程序
./pl0 test_cases/case_$typ.pl0 > tokens.txt    

#显示程序运行结果
cat tokens.txt											
fi
