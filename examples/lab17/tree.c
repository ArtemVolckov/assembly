#include <stdio.h>
#include <stdlib.h>
#include "tree.h"

struct Node * left(struct Node * p){
	struct Node * tmp;
	tmp=p->r;
	p->r=tmp->l;
	tmp->l=p;
	p->b--;
	if (tmp->b>0) p->b-=tmp->b;
	tmp->b--;
	if (p->b<0) tmp->b+=p->b;
	return tmp;
}

struct Node * right(struct Node * p){
	struct Node * tmp;
	tmp=p->l;
	p->l=tmp->r;
	tmp->r=p;
	p->b++;
	if (tmp->b<0) p->b-=tmp->b;
	tmp->b++;
	if (p->b>0) tmp->b+=p->b;
	return tmp;
}

int addrec(struct Node ** pp, int k){
	int n, d;
	if (*pp){
		if ((*pp)->k==k)
			return -1;
		d=(*pp)->k>k;
		n=addrec(d?&(*pp)->l:&(*pp)->r, k);
		if (n==1){
			if (d)
				(*pp)->b--;
			else
				(*pp)->b++;
			switch ((*pp)->b){
			case -1:
			case 1:
				return 1;
			case -2:
				if ((*pp)->l->b>0)
					(*pp)->l=left((*pp)->l);
				*pp=right(*pp);
				return 0;
			case 2:
				if ((*pp)->r->b<0)
					(*pp)->r=right((*pp)->r);
				*pp=left(*pp);
				return 0;
			default:
				return 0;
			}
		}
		else
			return n;
	}
	else{
		*pp=malloc(sizeof(struct Node));
		if (*pp){
			(*pp)->k=k;
			(*pp)->b=0;
			(*pp)->l=(*pp)->r=NULL;
			return 1;
		}
		else
			return -1;
	}
}

int Add(struct Node ** proot, int k){
	return addrec(proot, k)!=-1;
}

void Free(struct Node * root){
	if (root){
		Free(root->l);
		Free(root->r);
		free(root);
	}
}

void Print(struct Node * root){
	if (root){
		Print(root->l);
		printf("%d\n", root->k);
		Print(root->r);
	}
}

struct Node * Search(struct Node * root, int k){
	for (; root && root->k!=k; root=root->k>k?root->l:root->r);
	return root;
}

int delrec(struct Node ** pp, int k, struct Node * p){
	int n, d;
	struct Node * tmp;
	if (*pp){
		if ((*pp)->k==k){
			p=*pp;
			d=p->b<0;
		}
		else
			d=(*pp)->k>k;
		n=delrec(d?&(*pp)->l:&(*pp)->r, k, p);
		switch (n){
		case -1:
			if (p==NULL)
				return -1;
			if ((*pp)->k!=k)
				p->k=(*pp)->k;
			tmp=*pp;
			*pp=d?(*pp)->r:(*pp)->l;
			free(tmp);
			return 1;
		case 1:
			if (d)
				(*pp)->b++;
			else
				(*pp)->b--;
			switch ((*pp)->b){
			case 0:
				return 1;
			case -2:
				n=(*pp)->l->b!=0;
				if ((*pp)->l->b>0)
					(*pp)->l=left((*pp)->l);
				*pp=right(*pp);
				return n;
			case 2:
				n=(*pp)->r->b!=0;
				if ((*pp)->r->b<0)
					(*pp)->r=right((*pp)->r);
				*pp=left(*pp);
				return n;
			default:
				return 0;
			}
		default:	
			return n;
		}
	}
	else
		return -1;
}

int Del(struct Node ** proot, int k){
	return delrec(proot, k, NULL)!=-1;
}
