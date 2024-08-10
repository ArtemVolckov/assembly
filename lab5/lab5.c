// grayscale with C/NASM
// image format - BMP

#include <stdio.h>
#include <time.h>
#include "grayscale_funcs.h"

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_ONLY_BMP

#include "stb_image.h"
#include "stb_image_write.h"

#define FORMAT_ERR     1
#define FILE_MISS_ERR  2
#define FILE_LOAD_ERR  3
#define FILE_WRITE_ERR 4

// Assembly function
extern void convert_to_grayscale_s(unsigned char* img, int width, int height, int channels);

void time_conversion(void (*convert_func)(unsigned char*, int, int, int), 
                     unsigned char* img, int width, int height, int channels, const char* label) {
    struct timespec t1, t2;
    
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
        convert_func(img, width, height, channels);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);

    long seconds = t2.tv_sec - t1.tv_sec;
    long nanoseconds = t2.tv_nsec - t1.tv_nsec;

    if (nanoseconds < 0) {
        seconds--;
        nanoseconds += 1000000000;     
    }
    printf("%s: %ld.%09ld\n", label, seconds, nanoseconds);                             
}
    
int main (int argc, char* argv[]) {
    FILE* f;
    int width, height, channels;    
    struct timespec t, t1, t2;

    if (argc != 4) {
        fprintf(stderr, "Usage: %s input_image.bmp output_c_image.bmp output_asm_image.bmp\n", *argv);
        return FORMAT_ERR; 
    }

    // check if files exist
    for (int i = 1; i < 4; ++i) {
        if ((f = fopen(argv[i], "r")) == NULL) {
            perror(argv[i]);
            return FILE_MISS_ERR;
        }
        fclose(f);
    }

    // unsigned char* stbi_load(const char* filename, int* x, int* y, int* comp, int req_comp);
    // comp -> number of channels in the original image (3 - RGB, 4 - RGBA)
    // req_comp -> required number of channels in the uploaded image. If zero -> comp

    // C PART

    unsigned char* img = stbi_load(argv[1], &width, &height, &channels, 0); 
    
    if (img == NULL) {
        fprintf(stderr, "Error loading input_image\n");
        return FILE_LOAD_ERR;
    }

    time_conversion(convert_to_grayscale_c, img, width, height, channels, "C");
    
    if (stbi_write_bmp(argv[2], width, height, channels, img) == 0) {
        fprintf(stderr, "Error writing output_c_image\n");
        stbi_image_free(img);
        return FILE_WRITE_ERR;
    }

    // ASM PART

    img = stbi_load(argv[1], &width, &height, &channels, 0); 
    
    if (img == NULL) {
        fprintf(stderr, "Error loading input_image\n");
        return FILE_LOAD_ERR;
    }

    time_conversion(convert_to_grayscale_s, img, width, height, channels, "ASM");

    if (stbi_write_bmp(argv[3], width, height, channels, img) == 0) {
        fprintf(stderr, "Error writing output_asm_image\n");
        stbi_image_free(img);
        return FILE_WRITE_ERR;
    }

    stbi_image_free(img);
    return 0;
}
