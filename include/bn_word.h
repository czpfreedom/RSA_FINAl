#ifndef BN_WORD_H
#define BN_WORD_H

#ifdef BN_PART_32
#define BN_PART_32 unsigned int
#endif

#ifdef BN_PART_64
#define BN_PART_64 unsigned long
#endif

typedef struct bignumber_word_st{
    int dmax;
    BN_PART*d;
}BN_WORD;

#endif
