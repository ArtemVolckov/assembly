#include "grayscale_funcs.h"

void convert_to_grayscale_c(unsigned char* img, int width, int height, int channels) {
    for (long long i = 0; i < width * height; ++i) {
        long long idx = i * channels;

        unsigned char r = img[idx];
        unsigned char g = img[idx + 1];
        unsigned char b = img[idx + 2];

        unsigned char gray = (unsigned char)(r * 0.3 + g * 0.59 + b * 0.11);

        img[idx] = gray;
        img[idx + 1] = gray;
        img[idx + 2] = gray;
    }
} 
