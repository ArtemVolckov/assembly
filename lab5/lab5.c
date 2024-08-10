// grayscale with C/NASM
// image format - BMP

#include <stdio.h>
//#include <stdlib.h>
//#include <math.h>
//#include <time.h>
//#include "image.h"

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_ONLY_BMP

#include "stb_image.h"
#include "stb_image_write.h"

#define FORMAT_ERR     1
#define FILE_MISS_ERR  2
#define FILE_LOAD_ERR  3
#define FILE_WRITE_ERR 4
    
void convert_to_grayscale(unsigned char* img, int width, int height, int channels) {
    for (int i = 0; i < width * height; i++) {
        int idx = i * channels;

        unsigned char r = img[idx];
        unsigned char g = img[idx + 1];
        unsigned char b = img[idx + 2];

        unsigned char gray = (unsigned char)(r * 0.3 + g * 0.59 + b * 0.11);

        img[idx] = gray;
        img[idx + 1] = gray;
        img[idx + 2] = gray;

        if (channels == 4) {
            img[idx + 3] = img[idx + 3];       
        }
    }
}
 
int main (int argc, char* argv[]) {
    FILE* f;
    int width, height, channels;    

    if (argc != 3) {
        fprintf(stderr, "Usage: %s input_file output_file\n", *argv);
        return FORMAT_ERR; 
    }
    for (int i = 1; i < 3; ++i) {
        if ((f = fopen(argv[i], "r")) == NULL) {
            perror(argv[i]);
            return FILE_MISS_ERR;
        }
    }

    // unsigned char* stbi_load(const char* filename, int* x, int* y, int* comp, int req_comp);
    // comp -> number of channels in the original image (3 - RGB, 4 - RGBA)
    // req_comp -> required number of channels in the uploaded image. If zero -> comp

    unsigned char* img = stbi_load(argv[1], &width, &height, &channels, 0); 

    if (img == NULL) {
        fprintf(stderr, "Error loading image\n");
        return FILE_LOAD_ERR;
    }
    convert_to_grayscale(img, width, height, channels);

    if (stbi_write_bmp(argv[2], width, height, channels, img) == 0) {
        fprintf(stderr, "Error writing image\n");
        stbi_image_free(img);
        return FILE_WRITE_ERR;
    }
    stbi_image_free(img);
    printf("Image converted to grayscale and saved as %s\n", argv[2]);
    return 0;
}
