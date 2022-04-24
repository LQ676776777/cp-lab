#include <stdio.h>
#include "alibaba.h"
 
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
 
void alibaba(void)
{
   int y = 24;
   printf("Alibaba: My name is Alibaba, I am %d years old.\n", y);
 
   #ifdef BILIBILI
   printf("Alibaba: Hey Bili, 你娃最近赚钱没得？\n");
   #endif
}