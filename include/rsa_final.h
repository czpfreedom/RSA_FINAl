#ifndef RSA_H
#define RSA_H

#include "rsa_final_c.h"

/***** BIGNUM ARRAY *****************************/

typedef struct bignumber_word_array_st{
    int word_num;
    BN_WORD **bn_word;
}BN_WORD_ARRAY;

BN_WORD_ARRAY *BN_WORD_ARRAY_new(int word_num, int dmax);

void BN_WORD_ARRAY_free(BN_WORD_ARRAY *a);

int BN_WORD_print(const BN_WORD *a);

int BN_WORD_copy_host(const BN_WORD *a,BN_WORD *b);

int BN_WORD_mul(const BN_WORD *a, const BN_WORD *b, BN_WORD *result);
/************************************************/

/***** RSA_N ************************************/
typedef struct rsa_n_st{
    BN_WORD *n;
    BN_WORD *p;
    BN_WORD *q;
}RSA_N;

RSA_N *RSA_N_new(int dmax);

int RSA_N_free(RSA_N *rsa_n);

/************************************************/

/***** CRT_N ************************************/

class CRT_N{
public: 
    RSA_N *m_rsa_n;
    BN_WORD *m_zero;
    BN_WORD *m_one;
    BN_WORD *m_R;
    BN_PART m_n0_inverse;

    CRT_N (RSA_N *rsa_n);
    ~CRT_N ();

    int CRT_MUL_MOD(BN_WORD *a, BN_WORD *b, BN_WORD *result);
    int CRT_EXP_MOD(BN_WORD *a, BN_WORD *e, BN_WORD *result);
    int CRT_EXP_MOD_PARALL(BN_WORD *a, BN_WORD *e, BN_WORD *result);
    int CRT_EXP_MOD_ARRAY(BN_WORD_ARRAY *a, BN_WORD_ARRAY *b, BN_WORD_ARRAY *result);
};
/************************************************/

/***** RNS_N ************************************/

/************************************************/

#endif
