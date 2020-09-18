#ifndef BN_WORD_H
#define BN_WORD_H

#include "config.h"

//define BN_PART char or int or long

#ifndef BN_PART
#ifdef BN_PART_32
#define BN_PART unsigned int
#endif

#ifdef BN_PART_64
#define BN_PART unsigned long
#endif

#endif

typedef struct bignumber_word_st{
    int dmax;
    BN_PART *d;
}BN_WORD;

#endif
