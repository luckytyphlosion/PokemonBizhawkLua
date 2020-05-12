#include <stdint.h>
#include <stdio.h>

typedef uint32_t uint;
typedef uint64_t u64;

int main(void) {
    uint seed = 54160;
    u64 frame = 0;
    
    do {
        seed = seed * 0x41C64E61 + 0x6073;
        frame++;
    } while (seed != 0x8c6b6616);
    
    printf("frame: %lu\n", frame);
    return 0;
}
