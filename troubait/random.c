#include <stdint.h>
#include "random.h"

uint fast_multipliers[] = {
    0x41c64e61, 0x980b40c1, 0xd0f71181, 0x68206301, 0xb689c601, 0xf2378c01, 0x58ff1801, 0x843e3001, 
    0x517c6001, 0xc6f8c001, 0x1df18001, 0x7be30001, 0xf7c60001, 0xef8c0001, 0xdf180001, 0xbe300001, 
    0x7c600001, 0xf8c00001, 0xf1800001, 0xe3000001, 0xc6000001, 0x8c000001, 0x18000001, 0x30000001, 
    0x60000001, 0xc0000001, 0x80000001, 0x00000001, 0x00000001, 0x00000001, 0x00000001, 0x00000001
};

uint fast_addends[] = {
    0x00006073, 0xe979f606, 0x8e2ff08c, 0x3a657318, 0xd34d2e30, 0x30037c60, 0xc0ab78c0, 0xdbe8f180, 
    0xe219e300, 0x6d53c600, 0x7f278c00, 0x904f1800, 0x689e3000, 0xf13c6000, 0x6278c000, 0xc4f18000, 
    0x89e30000, 0x13c60000, 0x278c0000, 0x4f180000, 0x9e300000, 0x3c600000, 0x78c00000, 0xf1800000, 
    0xe3000000, 0xc6000000, 0x8c000000, 0x18000000, 0x30000000, 0x60000000, 0xc0000000, 0x80000000, 
};

uint random(uint * seed) {
    *seed = *seed * MULTIPLIER + ADDEND;
    return *seed >> 16;
}

void random_advance(uint * seed, uint n) {
    int i = 0;
    uint temp_seed = *seed;
    while (n > 0) {
        if ((n & 1) == 1) {
            temp_seed = temp_seed * fast_multipliers[i] + fast_addends[i];
        }
        n >>= 1;
        i++;
        if (i >= 32) {
            break;
        }
    }
    *seed = temp_seed;
}
