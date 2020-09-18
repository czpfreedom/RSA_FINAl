#ifndef RNS_RSA_H
#define RNS_RSA_H

#include "bn_word_operation.h"

#define RNS_WORD unsigned int 

#define BASE_MAX 32

#define rns_word_mul_mod(a,b,n) (RNS_WORD)((((unsigned long)a)*((unsigned long)b))%((unsigned long)n))
#define rns_word_add_mod(a,b,n) (RNS_WORD)((((unsigned long)a)+((unsigned long)b))%((unsigned long)n))
#define rns_word_rand()  (RNS_WORD)(((unsigned long)(rand()))%((unsigned long)((unsigned long)UN_INT_MAX+1)))



//RSA: a^e mod n

typedef struct rsa_n{
    BN_WORD *n;
    BN_WORD *p;
    BN_WORD *q;

}RSA_N;

__host__ RSA_N *RSA_N_new(int dmax);

__host__ int RSA_N_free(RSA_N *rsa_n);

__host__ int RSA_N_print(RSA_N *rsa_n);


class RNS_N{

public:
    RSA_N *m_rsa_n; //
    int m_base_num; //num of m1 and m2 which is effective, depend on the size of n
    RNS_WORD *m_m1; //size=BASE_MAX but only base_num is effective
    RNS_WORD *m_m2; //size=BASE_MAX but only base_num is effective
    BN_WORD *m_M1; 
    BN_WORD *m_M2;
    BN_WORD **m_M1_i; //M1_i
    BN_WORD **m_M2_i;
    BN_WORD **m_M1_red_i; //M1_i^-1 * M1_i mod M1
    BN_WORD **m_M2_red_i; //M2_i^-1 * M2_i mod M2
    BN_WORD *m_M1_n;
    BN_WORD *m_M2_n;
    RNS_WORD *m_d; //size=base_num
    RNS_WORD *m_e; //size=base_num
    RNS_WORD *m_a; //size=base_num*base_num
    RNS_WORD *m_a_2; //size=base_num
    RNS_WORD *m_b; //size=base_num*base_num
    RNS_WORD *m_b_2; //size=base_num
    RNS_WORD *m_c; //size=base_num

    __host__ RNS_N();

    __host__ RNS_N(RSA_N *rsa_n);

    __host__ ~RNS_N();

    __host__ int RNS_print();

    __host__ int RNS_mul_mod(BN_WORD *a, BN_WORD *b, BN_WORD *result);

    __host__ int RSA (BN_WORD *a, BN_WORD *e, BN_WORD *result); // result=a^e mod n

    __host__ int RSA_RNS_reduction1(RNS_WORD *x_result, BN_WORD *result);

    __host__ int RSA_RNS_reduction2(RNS_WORD *x_result, BN_WORD *result);
};


__host__ int BN_WORD_RNS_WORD_mod (BN_WORD *a, RNS_WORD b, RNS_WORD &c);//c=a mod b

__device__ int BN_WORD_RNS_WORD_mod_device (BN_WORD *a, RNS_WORD b, RNS_WORD &c);

__host__ __device__ int RNS_WORD_BN_WORD_transform(RNS_WORD a, int bits, BN_WORD *result); //transform RNS_WORD to BN_WORD with bits bits is effective

__host__ int RNS_WORD_mod_inverse(RNS_WORD a, RNS_WORD n, RNS_WORD &a_inverse); // a_inverse =a^(-1)mod n

__global__ void RNS_mul_mod_kernel(BN_WORD *bn_a,BN_WORD *bn_b,int base_num,RNS_WORD *m1, RNS_WORD *m2,RNS_WORD *d,RNS_WORD *e,RNS_WORD *a, RNS_WORD *a_2,RNS_WORD *b,RNS_WORD *b_2,RNS_WORD *c,RNS_WORD *x_result);

__global__ void RSA_RNS_kernel(BN_WORD *bn_a, BN_WORD *bn_e, int base_num, RNS_WORD *m1, RNS_WORD *m2, RNS_WORD *d, RNS_WORD *e, RNS_WORD *a, RNS_WORD *a_2, RNS_WORD *b, RNS_WORD *b_2, RNS_WORD *c, RNS_WORD *x_result); // a=a*M mod p

#endif
