cd src
chmod +x shell2.sh
./shell2.sh > err2.txt
if [ ! -f "bar.clang.s" ];then	         
echo "未找到bar.clang.s，编译未成功，请检查编译脚本。"
echo "下面是错误信息："
cat err2.txt
else
cat bar.clang.s
fi 