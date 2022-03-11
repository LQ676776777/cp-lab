#include <stdio.h>
#include <alibaba.h>
 
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
 
int main(void)
{
   int y = 14;
   printf( "Hello, I am your instuctor, please introduce yourself.\n");
 
   #ifdef BILIBILI
   printf("My name is Bilibi, I am %d  years old!\n");
   #endif
 
   qq();
   return 0;
}