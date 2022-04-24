#!/bin/bash

cd src
chmod +x shell1.sh
./shell1.sh > err1.txt
if [ ! -f "def-test" ];then	         
echo "未找到def-test，编译未成功，请检查编译脚本。"
echo "下面是错误信息："
cat err1.txt
else
./def-test 
fi