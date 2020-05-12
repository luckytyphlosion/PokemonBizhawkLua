#include <stdint.h>
#include <stdio.h>

static inline uint32_t rotl(const uint32_t x, int k) {
	return (x << k) | (x >> (32 - k));
}


static uint32_t s[4];

uint32_t next(void) {
	const uint32_t result = rotl(s[0] + s[3], 7) + s[0];

	const uint32_t t = s[1] << 9;

	s[2] ^= s[0];
	s[3] ^= s[1];
	s[1] ^= s[2];
	s[0] ^= s[3];

	s[2] ^= t;

	s[3] = rotl(s[3], 11);

	return result;
}

uint32_t split_mix_32(uint32_t x) {
    x ^= x >> 16;
    x *= 0x85ebca6b;
    x ^= x >> 13;
    x *= 0xc2b2ae35;
    x ^= x >> 16;
    return x;
}

void seed_rng(uint32_t seed) {
    for (int i = 0; i < 4; i++) {
        s[i] = split_mix_32(seed);
        seed = s[i];
        printf("s%d: 0x%08x\n", i, s[i]);
    }
    printf("\n");
}

int main(void) {
    seed_rng(42069);
    for (int i = 0; i < 10; i++) {
        printf("value: 0x%08x\n", next());
    }
    return 0;
}
