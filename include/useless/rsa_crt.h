#ifndef RSA_CRT__H
#define RSA_CRT__H
#include "bn_word.h"

#ifdef NOTEMP

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_PART n0_inverse, BN_WORD *result,
                BN_WORD *u, BN_WORD *v, BN_WORD *m, BN_WORD *c);

#endif


#ifdef SHARED

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_PART n0_inverse, BN_WORD *result);

#endif



__host__ int BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result);

__host__ int BN_WORD_parallel_mont_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *n, BN_WORD *result);


#endif
