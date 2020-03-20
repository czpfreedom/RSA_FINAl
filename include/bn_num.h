#ifndef BN_NUM_H
#define BN_NUM_H


#include "bn_word.h"

typedef struct bignum_num_st{
    int wmax;
    BN_WORD **word;
}BN_NUM;

#endif
