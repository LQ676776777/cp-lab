#include <stdio.h>
#include <alibaba.h>
 
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
 
void alibaba(void)
{
   int y;
   printf("My name is Alibaba, I am %d years old.\n", y);
 
   #ifdef BILIBILI
   printf("Alibaba: Hey Bili, お久しぶり.\n");
   #endif
}