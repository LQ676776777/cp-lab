extern void putfloat(float a);
extern float getfloat();
extern int getint();
extern void putch(int a);

int main(){
    int a;
    float b;
    a = getint();
    b = getfloat();
    putfloat(a + b);
    putch(10);
    return 0;
} 