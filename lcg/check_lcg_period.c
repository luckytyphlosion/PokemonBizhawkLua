#include <stdint.h>
#include <stdio.h>

typedef uint32_t uint;
typedef uint64_t u64;

int main(void) {
    uint seed = 0;
    u64 period = 0;
    
    do {
        seed = seed * 0x41C64E61 + 0x6073;
        period++;
    } while (seed != 0);
    
    printf("period: %lu\n", period);
    return 0;
}
