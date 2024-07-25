void work_image_c(void * from, void * to, int x, int y){
	int i;
	unsigned char * src=from, * dst=to, c;
	if (x<0)
		return;
	for (i=0; i<x*y; i++){
		c=(src[i*4]+src[i*4+1]+src[i*4+2])/3;
		dst[i*4]=c;
		dst[i*4+1]=c;
		dst[i*4+2]=c;
		dst[i*4+3]=src[i*4+3];
	}
}
