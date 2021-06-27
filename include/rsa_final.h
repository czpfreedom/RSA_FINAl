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
class RNS_N{

public:
    RSA_N *m_rsa_n; //
    int m_base_num; //num of m1 and m2 which is effective, depend on the size of n, m_base_num can be 32 or 64
    BN_PART *m_m1; //size=BASE_MAX but only base_num is effective
    BN_PART *m_m2; //size=BASE_MAX but only base_num is effective
    BN_WORD *m_M1;
    BN_WORD *m_M2;
    BN_WORD **m_M1_i; //M1_i
    BN_WORD **m_M2_i;
    BN_WORD **m_M1_red_i; //M1_i^-1 * M1_i mod M1
    BN_WORD **m_M2_red_i; //M2_i^-1 * M2_i mod M2
    BN_WORD *m_M1_n;
    BN_WORD *m_M2_n;
    BN_PART *m_d; //size=base_num
    BN_PART *m_e; //size=base_num
    BN_PART *m_a; //size=base_num*base_num
    BN_PART *m_a_2; //size=base_num
    BN_PART *m_b; //size=base_num*base_num
    BN_PART *m_b_2; //size=base_num
    BN_PART *m_c; //size=base_num

    RNS_N();

    RNS_N(RSA_N *rsa_n);

    ~RNS_N();

    int RNS_print();

    int RNS_MUL_MOD(BN_WORD *a, BN_WORD *b, BN_WORD *result);

    int RSA (BN_WORD *a, BN_WORD *e, BN_WORD *result); // result=a^e mod n

    int RSA_RNS_reduction1(BN_PART *x_result, BN_WORD *result);

    int RSA_RNS_reduction2(BN_PART *x_result, BN_WORD *result);
};

/************************************************/

#endif
