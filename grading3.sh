cd src
chmod +x shell3.sh

if [ $(cat shell3.sh  | grep -c "arm-linux-gnueabihf-gcc") -eq 0 ]; then 
echo 'arm-linux-gnueabihf-gcc not used!' 
elif  $(cat shell3.sh  | grep -c "qemu-arm") -eq 0 ]; then 
echo 'qemu-arm not used!' 
else
    ./shell3.sh
fi
