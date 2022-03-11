#include <stdio.h>

int main()
{
    int m, n;
	        
    printf("Enter two positive integers: ");
    scanf("%d %d",&m, &n);

    while(m != n) {
       if(m > n)  m -= n;
       else n -= m;
       
     }

    printf("GCD = %d\n",m);
    
    return 0;
}  