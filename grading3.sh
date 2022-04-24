export PATH=/root/.opam/system/bin:/usr/local/arm/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin:/usr/lib/jvm/jdk-11/bin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/sbin:/usr/games:/usr/local/games:/snap/bin:/opt/RISCV/riscv/bin:/opt/RISCV/riscv/bin:/opt/RISCV/riscv/bin

cd src
chmod +x shell3.sh

if [ $(cat shell3.sh  | grep -c "arm-linux-gnueabihf-gcc") -eq 0 ]; then 
echo 'arm-linux-gnueabihf-gcc not used!' 
elif [ $(cat shell3.sh  | grep -c "qemu-arm") -eq 0 ]; then 
echo 'qemu-arm not used!' 
else
./shell3.sh
fi
