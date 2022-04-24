extern void putfloat(float a);
extern float getfloat();
extern void putch(int a);

int main(){
    float a, b;
    a = 020e-04f;
    b = getfloat();
    putfloat(a + b);
    putch(10);
    return 0;
} 