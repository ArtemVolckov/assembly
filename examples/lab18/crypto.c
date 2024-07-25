#include <stdio.h>
#include <stdlib.h>
#include "crypto.h"

int crypto(char * filefrom, char * fileto, unsigned long key){
	FILE * fin, * fout;
	char buf[4096];
	int f, i, div, rem;
	fin=fopen(filefrom, "r");
	if (fin==NULL){
		perror(filefrom);
		return 1;
	}
	fout=fopen(fileto, "w");
	if (fout==NULL){
		perror(fileto);
		fclose(fin);
		return 1;
	}
	while ((f=fread(buf, 1, 4096, fin))>0){
		div=f/sizeof(long);
		rem=f%sizeof(long);
		for (i=0; i<div; i++)
			((long *)buf)[i]^=key;
		for (i=0; i<rem; i++)
			buf[div*sizeof(long)+i]^=((char *)&key)[i];
		if (fwrite(buf, 1, f, fout)!=f)
			break;
	}
	fclose(fin);
	fclose(fout);
	return f!=0;
}
