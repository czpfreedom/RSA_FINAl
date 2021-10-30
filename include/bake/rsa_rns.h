#ifndef RSA_RNS_H
#define RSA_RNS_H

#include "bn_word.h"

#define BASE_MAX 32

namespace namespace_rsa_final{

__global__ void RNS_mul_mod_kernel(BN_WORD *bn_a,BN_WORD *bn_b,int base_num,BN_PART *m1, BN_PART *m2,BN_PART *d,BN_PART *e,BN_PART *a, BN_PART *a_2,BN_PART *b,BN_PART*b_2,BN_PART *c,BN_PART *x_result);

}

#endif
