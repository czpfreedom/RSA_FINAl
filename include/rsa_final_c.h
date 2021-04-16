#ifndef RSA_FINAL_C_H
#define RSA_FINAL_C_H

#include "config.h"

#ifdef __cplusplus
extern "C" { 
#endif

#ifdef  BN_PART_32
#define BN_PART unsigned int
#endif

#ifdef  BN_PART_64
#define BN_PART unsigned long
#endif 

/***** BIGNUM **********************************/


typedef struct bignumber_word_st{
    int dmax;
    BN_PART*d;
}BN_WORD;

BN_WORD *BN_WORD_new(int dmax);

void BN_WORD_free(BN_WORD *a);

/************************************************/


int BN_mod_exp_cuda(BN_WORD *rr, BN_WORD *a, BN_WORD *p,BN_WORD *m);
// rr=a^p mod m   
// return 1 right
// return 0 error  

#ifdef __cplusplus
}
#endif

#endif
