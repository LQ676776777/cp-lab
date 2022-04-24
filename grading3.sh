cd src
chmod +x shell3.sh
./shell3.sh 

if [ ! -f "bar.armgcc.arm.s" ];then	         
echo "未找到bar.clang.arm.s，编译未成功，请检查编译命令及编译选项。"
echo "下面是错误信息："

else
cat bar.clang.arm.s
fi  