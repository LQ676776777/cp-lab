#include <stdio.h>
#include <alibaba.h>
 
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
 
int main(void)
{
  
   printf( "Hello, I am your instuctor, please introduce yourself.\n");
 
   #ifdef BILIBILI
   printf("My name is Bilibi, 先生お久しぶりです!\n");
   #endif
 
   alibaba();
   return 0;
}