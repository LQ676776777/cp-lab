# 实验一 工具，语言与平台

## 1-1 GCC编译器的使用

任务描述
本关任务：用gcc编译器，指定合适的命令行选项，编译出符合要求的二进制可执行代码。

相关知识
为了完成本关任务，你需要掌握：1.熟悉gcc编译器
2.gcc的命令行选项-D

GCC介绍
GCC（GNU Compiler Collection，GNU编译器套件）是由GNU开发的编程语言编译器。GNU编译器套件包括C、C++、 Objective-C、 Fortran、Java、Ada和Go语言前端，也包括了这些语言的库（如libstdc++，libgcj等。）

C++是GNU针对C++语言的编译器。

GCC的命令行选项
常用的命令行选项有：

-E 只执行预处理
-c 编译或汇编源文件，不执行链接
-S 完成编译但不执行汇编，产生汇编文件
-o file 指定输出的文件为file。如果未指定该选项，在Linux下生成的可执行代码将被命名为缺省值a.out。指定输出文件名时，应使用缺省的后缀：预处理后：.i； 汇编代码：.s；目标代码.o等。
-DSOMETHING 宏定义,即预处理语句“#define SOMETHING”中的宏SOMETHING。
-I 指定头文件的搜索路径
-O 批定优化级别，如：-O2,-O3等。编译系统设计赛在决赛阶段将用-O2选项对测试用例在目标平台上进行编译优化，用优化的可执行代码的执行时间/你的编译器生成的汇编代码在目标平台上汇编后生成的可执行代码运行时间\*100 所得的值作为你在该测试用例上的性能得分。
更详细的命令行选项，请参考：
GCC 选项总结

编程要求
有以下源程序和.h文件：
def-test.c
alibaba.c
alibaba.h

def-test.c
#include <stdio.h>
#include "alibaba.h"
int main(void)
{
printf( "Instructor: Hello, I am your instuctor, please introduce yourself.\n");

#ifdef BILIBILI
printf("BILIBILI: My name is Bili, 先生お久しぶりです!\n");
#endif

alibaba();
return 0;
}
alibaba.h
#ifndef **ALIBABA**
#define **ALIBABA**

void alibaba(void);

#endif  
alibaba.c
#include <stdio.h>
#include "alibaba.h"

void alibaba(void)
{
int y = 24;
printf("Alibaba: My name is Alibaba, I am %d years old.\n", y);

#ifdef BILIBILI
printf("Alibaba: Hey Bili, 你娃最近赚钱没得？\n");
#endif
}
根据提示，在右侧编辑器填写编译指令，用gcc编译器编译def-test.c和alibaba.c, 并指定合适的编译选项，生成二进制可执行代码def-test。执行的结果应当包括Bilibili的自我介绍以及Alibaba对BiliBili的喊话。

## 1-2 Sysy语言与运行时库

任务描述
本关任务：熟悉SysY语言和运行时库，并用该语言写一个解决“买卖股票的最佳时机”的程序。

相关知识
语言
SysY 语言是编译系统设计赛要实现的编程语言。由 C 语言的一个子集扩展而成。每个 SysY 程序的源码存储在一个扩展名为 sy 的文件中。该文件中有且仅有一个名为 main 的主函数定义，还可以包含若干全局变量声明、常量声明和其他函数定义。SysY 语言支持 int/float 类型和元素为 int/float 类型且按行优先存储的多维数组类型，其中 int 型整数为 32 位有符号数;float 为 32 位单精度浮点 数;const 修饰符用于声明常量。SysY 支持 int 和 float 之间的隐式类型，但是无显式的强制类型转化支持。
关于SysY语言的详细定义，请参见：
SysY2022语言定义-V1.pdf

运行时库
SysY 语言本身没有提供输入/输出(I/O)的语言构造，I/O 是以运行时库方式提供，库函数可以在 SysY 程序中的函数内调用。部分 SysY 运行时库函数的参数类型会超出 SysY 支持的数据类型，如可以为字符串。SysY 编译器需要能处理这种情况，将 SysY 程序中这样的参数正确地传递给 SysY 运行时库。

SysY语言的运行时库详解请参见：
SysY2022运行时库-V1.pdf

编程要求
给定一个数组 prices ，它的第 i 个元素 prices[i] 表示一支给定股票第 i 个交易日的价格(假定股价是整数)。你只能选择某个交易日买入这只股票，并选择在未来的另一个交易日卖出该股票。设计一个算法来计算你所能获取的最大利润，并返回这个最大利润值。如果你不能获取任何利润，返回 0 。
示例1：
输入：7 1 5 3 6 4
输出：5
解释：在第 2 个交易日（股票价格 = 1）的时候买入，在第 5 个交易日（股票价格 = 6）的时候卖出，最大利润 = 6-1 = 5 。注意利润不能是 7-1 = 6, 因为不能在买入前卖出股票。

示例2：
输入：7 6 4 3 1
输出：0
解释：卖出价大于买入价才能获利。5个交易日股价一直在下跌，没有获得利润的可能。

程序用
int prices[N];
存储某支股票连续N个交易日的股价，其中N是常量。要求：

完成函数maxProfit()，其输入是股价组成的数组，返回值是可以获得的最大利润；
在main()里添加适当语句,完成：
接受N个整数(连续N个交易日的股价)的输入;
调用maxProfit()，获得可能的最大利润，并输出该数值，然后换行；
main()函数返回1。
提示：0 <= prices[i] <= 10000

根据提示，在右侧编辑器补充代码，完成上述要求。

注意SysY语言没有for语句,没有++，--，+=， -=等运算符。

task1-2/src/step1.sy
```cpp
const int N = 10;
int prices[N]; 

// 请完成函数maxProfit(),其输入为股价数组，输出为可获得的最大利润 
int maxProfit(int prices[]){
    // ----------  开始




    // ----------- 结束
}

// main()接收连续N个交易日的股价输入并存入数组prices[],
// 接着调用maxProfit()求可能的最大利润，然后输出该值，并换行。
int main(){
    // 股价数组的输入：



    int best = maxProfit(prices);
    //结果输出：

   return 1;
}

```

## 1-4 RISC-V 汇编（1-3是arm）

任务描述
RISC-V 汇编。

本关任务：用RISCV 汇编编写一个对数组排序的函数。

相关知识
1.RISC-V介绍
2.RISC-V汇编

RISC-V介绍
RISC-V(读作“RISC-FIVE”)是基于精简指令集计算(RISC)原理建立的开放指令集架构(ISA)，V表示为第五代RISC(精简指令集计算机).
RISC-V架构简单，完全开源。

RISC-V汇编
RISCV汇编请参考相关资料

编程要求
本关任务：完善一个按升序对数组进行排序的arm汇编程序。

其中，主程序(SysY语言)的代码如下：

// getint(),putint(),putch()为SysY运行时函数
// bubblesort()在bubblesort.s中定义
int main(){
int n = 10;
int a[10];
int i = 0;
while (i < n) {
a[i] = getint(); //输入整数
i = i + 1;
}
i = bubblesort(a, 10);
while (i < n) {
putint(a[i]);//输出a[i]
putch(32); //输出空格
i = i + 1;
}
putch(10);//输出换行
return 0;
}
主程序的流程为

输入10个整数组成的数组
调用函数bubblesort（位于bubble.s文件中）进行排序
显示排序后的结果
注意：
调用者sort.c用bubblesort(a,10)的返回值初始化循环变量i,故bubblesort()的返回值必须为0。

你只需要补充完善以下riscv64汇编代码(bubblesort.s)，以完成程序中的bubblesort函数。

        .text
        .align  1
        .globl  bubblesort
        .type   bubblesort, @function

bubblesort:
.L2:
li a0,0
ret
.size bubblesort, .-bubblesort
说明：函数bubblesort的C语言说明如下
int bubblesort(int \*arr, int n)
main调用bubblesort之前，将数组arr的首地址保存在寄存器a0中，数组元素的个数n保存在寄存器a1中。bubblesort返回值为0，由a0传递（调用者借返回值 给循环变量赋初值 ）。
src/bubble.s
```s
        .text
        .align  1
        .globl  bubblesort
        .type   bubblesort, @function
bubblesort:


.L2:
        li      a0,0
        ret
        .size   bubblesort, .-bubblesort

```