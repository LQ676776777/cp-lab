#!/bin/bash

if [ ! -d "build" ]; then
  mkdir build
fi

cd build || exit

if [ -f "compiler" ]; then
  rm compiler
fi

cmake .. > cmake_output.txt 2>&1

if [ $? -ne 0 ]; then
  cat cmake_output.txt
  echo "CMake 失败，请检查 CMakeLists.txt 文件或构建配置。"
  exit 1
fi

make > make_output.txt 2>&1

if [ ! -f "compiler" ]; then
  cat make_output.txt
  echo "没有找到编译器 compiler，请修改代码后重新评测。"
  exit 1
fi

read -p '' case
chmod +x compiler

#./compiler ../test/checker/0$case.sy

if [[ ${#case} -eq 2 ]]; then
    ./compiler ../test/checker/${case}.sy
elif [[ ${#case} -eq 1 ]]; then
    ./compiler ../test/checker/0${case}.sy
fi