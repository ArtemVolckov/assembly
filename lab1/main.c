#include <stdio.h>

int main() {
    long res = 0;
    unsigned a = 4;
    unsigned short b = 2;
    unsigned c = 9;
    unsigned short d = 3;
    unsigned e = 10;
    res = ((a*b*c)-(c*d*e))/((a/b)+(c/d));
    printf("%ld\n", res);
}
