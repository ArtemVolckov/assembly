#include <stdio.h>

int main() {
    unsigned long res = 0;
    unsigned a = 1;
    unsigned short b = 1;
    unsigned c = 1;
    unsigned short d = 1;
    unsigned e = 1;
    res = ((a*b*c)-(c*d*e))/((a/b)+(c/d));
    printf("%ld\n", res);
}
