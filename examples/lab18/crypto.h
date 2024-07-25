#include <stdio.h>
#include <stdlib.h>

#ifndef CRYPTO
#define CRYPTO

int crypto(char *, char *, unsigned long);

int cryptoasm(char *, char *, unsigned long);

int cryptoasmSSE(char *, char *, unsigned long);

#endif
