#ifndef RSA_FINAL_C_H
#define RSA_FINAL_C_H

#include "rsa_config_c.h"

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

typedef struct bn_word_c_st{
    BN_PART m_data[BN_WORD_LENGTH_MAX];
    int m_neg;
    int m_top;

}BN_WORD_C;

BN_WORD_C* BN_WORD_C_new(int top, int neg);

int BN_WORD_C_free(BN_WORD_C *bw_c);

int BN_WORD_C_setzero(BN_WORD_C *bw_c);

int BN_mod_exp_cuda_c(BN_WORD_C *rr, BN_WORD_C *a, BN_WORD_C *e , BN_WORD_C *n);

#ifdef __cplusplus
}
#endif

#endif
