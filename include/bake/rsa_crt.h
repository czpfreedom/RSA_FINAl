#ifndef RSA_CRT_H
#define RSA_CRT_H

#define SHARED_SIZE 32

#include "bn_word.h"

namespace namespace_rsa_final{

__global__ void BN_WORD_parallel_Mon(const BN_WORD a, const BN_WORD b, const BN_WORD n, const BN_PART n0_inverse, BN_WORD result);

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD a, const BN_WORD b, const BN_WORD n, const BN_WORD one, const BN_PART n0_inverse, BN_WORD result);

__global__ void BN_WORD_parallel_mont_exp(int dmax, BN_WORD *square_1, BN_WORD *square_2, BN_WORD *result_2, const BN_WORD *e, const BN_WORD *n, const BN_WORD *one, const BN_PART n0_inverse, BN_WORD *result);

__global__ void BN_WORD_ARRAY_parallel_mont_exp(int dmax, BN_WORD_ARRAY *square_1, BN_WORD_ARRAY *square_2, BN_WORD_ARRAY *result_2, const BN_WORD_ARRAY *e, const BN_WORD *n, const BN_WORD *one, const BN_PART n0_inverse, BN_WORD_ARRAY *result);

}

#endif

