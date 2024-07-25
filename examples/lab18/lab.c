#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "crypto.h"

int main(int argc, char * argv[]){
	struct timespec t, t1, t2;
	unsigned long key;
	int rc;
	char * pkey;
	if (argc!=6){
		fprintf(stderr, "Usage: %s filefrom filetoC filetoAsm filetoAsmSSE key\n", argv[0]);
		return 1;
	}
	key=strtoul(argv[5], &pkey, 16);
	if (*pkey){
		fprintf(stderr, "Error key\n");
		return 1;
	}
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	rc=crypto(argv[1], argv[2], key);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	if (rc){
		fprintf(stderr, "Error encryption file with C\n");
		return 1;
	}
	printf("Crypto C: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	rc=cryptoasm(argv[1], argv[3], key);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	if (rc){
		fprintf(stderr, "Error encryption file with Asm\n");
		return 1;
	}
	printf("Crypto Asm: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	rc=cryptoasmSSE(argv[1], argv[4], key);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	if (rc){
		fprintf(stderr, "Error encryption file with AsmSSE\n");
		return 1;
	}
	printf("Crypto AsmSSE: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	return 0;
}
