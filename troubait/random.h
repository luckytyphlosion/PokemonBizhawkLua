#ifndef GUARD_RANDOM_H
#define GUARD_RANDOM_H
#include <stdint.h>

#define MULTIPLIER 0x41C64E61
#define ADDEND 0x6073
#define INVERSE_MULTIPLIER 0x8852d5a1

typedef uint32_t uint;

uint random(uint * seed);
void random_advance(uint * seed, uint n);
#endif
