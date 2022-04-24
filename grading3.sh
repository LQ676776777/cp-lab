cd src
chmod +x shell2.sh
./shell2.sh > /dev/null 2>&1 
if [ ! -f "bar.clang.arm.s" ];then	         
echo "未找到bar.clang.arm.s，编译未成功，请检查编译命令及编译选项。"
echo "下面是错误信息："

else
cat bar.clang.arm.s
fi  