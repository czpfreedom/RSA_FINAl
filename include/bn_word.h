#ifndef BN_WORD_H
#define BN_WORD_H

#ifndef BN_ULONG
#define BN_ULONG unsigned long
#endif

typedef struct bignumber_word_st{
    int dmax;
    BN_ULONG carry;
    BN_ULONG *d;
}BN_WORD;

#endif
