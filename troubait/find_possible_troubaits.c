#include <stdint.h>
#include <stdio.h>
#include "random.h"

#define TRUE 1
#define FALSE 0

enum {
    HP, ATK, DEF, SPE, SPA, SPD
};

// Pokemon natures
#define NATURE_HARDY 0
#define NATURE_LONELY 1
#define NATURE_BRAVE 2
#define NATURE_ADAMANT 3
#define NATURE_NAUGHTY 4
#define NATURE_BOLD 5
#define NATURE_DOCILE 6
#define NATURE_RELAXED 7
#define NATURE_IMPISH 8
#define NATURE_LAX 9
#define NATURE_TIMID 10
#define NATURE_HASTY 11
#define NATURE_SERIOUS 12
#define NATURE_JOLLY 13
#define NATURE_NAIVE 14
#define NATURE_MODEST 15
#define NATURE_MILD 16
#define NATURE_QUIET 17
#define NATURE_BASHFUL 18
#define NATURE_RASH 19
#define NATURE_CALM 20
#define NATURE_GENTLE 21
#define NATURE_SASSY 22
#define NATURE_CAREFUL 23
#define NATURE_QUIRKY 24

#define MALE 0
#define FEMALE 1

typedef struct {
    uint pid;
    uint nature;
    union {
        uint real_ivs[6];
        struct {
            uint real_hp;
            uint real_atk;
            uint real_def;
            uint real_spe;
            uint real_spa;
            uint real_spd;
        };
    };

    union {
        uint seen_ivs[6];
        struct {
            uint seen_hp;
            uint seen_atk;
            uint seen_def;
            uint seen_spe;
            uint seen_spa;
            uint seen_spd;
        };
    };
    uint gender;
    uint shiny;
} Pokemon;

typedef struct {
    uint nature;
    uint gender;
    uint shiny;
    union {
        uint stats[6];
        struct {
            uint hp;
            uint atk;
            uint def;
            uint spe;
            uint spa;
            uint spd;
        };
    };
} PokemonParameters;

const uint base_stats[] = {45, 50, 50, 45, 40, 60};
#define LEVEL 5

const uint sNatureStatTable[][5] =
{
    // Atk Def Spd Sp.Atk Sp.Def
    {    0,  0,  0,     0,     0}, // Hardy
    {   +1, -1,  0,     0,     0}, // Lonely
    {   +1,  0, -1,     0,     0}, // Brave
    {   +1,  0,  0,    -1,     0}, // Adamant
    {   +1,  0,  0,     0,    -1}, // Naughty
    {   -1, +1,  0,     0,     0}, // Bold
    {    0,  0,  0,     0,     0}, // Docile
    {    0, +1, -1,     0,     0}, // Relaxed
    {    0, +1,  0,    -1,     0}, // Impish
    {    0, +1,  0,     0,    -1}, // Lax
    {   -1,  0, +1,     0,     0}, // Timid
    {    0, -1, +1,     0,     0}, // Hasty
    {    0,  0,  0,     0,     0}, // Serious
    {    0,  0, +1,    -1,     0}, // Jolly
    {    0,  0, +1,     0,    -1}, // Naive
    {   -1,  0,  0,    +1,     0}, // Modest
    {    0, -1,  0,    +1,     0}, // Mild
    {    0,  0, -1,    +1,     0}, // Quiet
    {    0,  0,  0,     0,     0}, // Bashful
    {    0,  0,  0,    +1,    -1}, // Rash
    {   -1,  0,  0,     0,    +1}, // Calm
    {    0, -1,  0,     0,    +1}, // Gentle
    {    0,  0, -1,     0,    +1}, // Sassy
    {    0,  0,  0,    -1,    +1}, // Careful
    {    0,  0,  0,     0,     0}, // Quirky
};

inline uint calculate_hp_stat(Pokemon * mon) {
    return ((mon->real_hp + (2 * base_stats[HP]) + 100) * LEVEL)/100 + 10;
}

inline uint calculate_non_hp_stat(Pokemon * mon, uint stat) {      
    uint temp_stat = ((mon->real_ivs[stat] + 2 * base_stats[stat]) * LEVEL) / 100 + 5;
    switch (sNatureStatTable[mon->nature][stat - 1]) {
        case 1:
            return (temp_stat * 11) / 10;
        case 0:
        default:
            return temp_stat;
        case -1:
            return (temp_stat * 9) / 10;
    }
}


uint generate_mon(uint input_seed, uint frame, Pokemon * mon, PokemonParameters * params) {
    uint seed = input_seed;
    uint pid_half_1;
    uint temp_ivs;
    uint gender_aux;

    random_advance(&seed, frame);

    pid_half_1 = random(&seed);
    mon->pid = pid_half_1 | random(&seed) << 16;
    mon->nature = (mon->pid) % 25;
    
    if (mon->nature != params->nature) {
        return FALSE;
    }

    temp_ivs = random(&seed);
    mon->real_hp = temp_ivs & 0x1f;
    mon->real_atk = (temp_ivs >> 5) & 0x1f;
    mon->real_def = (temp_ivs >> 10) & 0x1f;

    temp_ivs = random(&seed);
    mon->real_spe = temp_ivs & 0x1f;
    mon->real_spa = (temp_ivs >> 5) & 0x1f;
    mon->real_spd = (temp_ivs >> 10) & 0x1f;

    gender_aux = mon->pid & 0xff;
    if (gender_aux < 127) {
        mon->gender = FEMALE;
    } else {
        mon->gender = MALE;
    }

    if (mon->gender != params->gender) {
        return FALSE;
    }

    random(&seed); // lag frame
    
    if (random(&seed) > 0x3f) {
        mon->shiny = FALSE;
    } else {
        mon->shiny = TRUE;
    }

    if (mon->shiny != params->shiny) {
        return FALSE;
    }

    random(&seed); // lag frame

    uint first_iv = random(&seed) % 6;
    mon->real_ivs[first_iv] = 31;

    uint second_iv;
    do {
        second_iv = random(&seed) % 6;
    } while (first_iv == second_iv);
    mon->real_ivs[second_iv] = 31;

    if (calculate_hp_stat(mon) != params->hp) {
        return FALSE;
    }

    for (int i = 1; i < 6; i++) {
        if (calculate_non_hp_stat(mon, i) != params->stats[i]) {
            return FALSE;
        }
    }

    return TRUE;
}

void find_all_possible_troubaits(void) {
    PokemonParameters params = {
        .nature = NATURE_IMPISH,
        .gender = FEMALE,
        .shiny = FALSE,
        .hp = 21,
        .atk = 11,
        .def = 12,
        .spa = 9,
        .spd = 11,
        .spe = 11
    };
    Pokemon mon;

    for (int cur_seed = 0; cur_seed < 65536; cur_seed++) {
        for (int cur_frame = 340; cur_frame < 350; cur_frame++) {
            if (generate_mon(cur_seed, cur_frame, &mon, &params)) {
                printf("Found mon at seed %d, frame %d\nIVs: %d HP/%d Atk/%d Def/%d SpA/%d SpD/%d Spe\n\n",
                    cur_seed, cur_frame, mon.real_hp, mon.real_atk, mon.real_def, mon.real_spa, mon.real_spd, mon.real_spe);
            }
        }
    }
}

int main(void) {
    find_all_possible_troubaits();

    return 0;
}
