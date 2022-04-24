chmod +x src/shell1.sh
.src/shell1.sh > err1.txt
if [ ! -f "src/def-test" ];then	         
echo "def-test，编译未成功，请检查编译脚本。"
echo "下面是错误信息："
cat err1.txt
else
.src/def-test 
fi