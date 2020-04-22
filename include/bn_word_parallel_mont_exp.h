#ifndef BN_WORD_PARALLEL_MONT_EXP_H
#define BN_WORD_PARALLEL_MONT_EXP_H
#include "bn_word_pseudo.h"

//#define notemp

#define SHARE

#ifdef notemp

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_ULONG n0_inverse, BN_WORD *result,
                BN_WORD *u, BN_WORD *v, BN_WORD *m, BN_WORD *c);

#endif


#ifdef SHARE

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_ULONG n0_inverse, BN_WORD *result);

#endif

__host__ int BN_WORD_mul_mod_host(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result);


__host__ int BN_ULONG_inverse(const BN_ULONG n, BN_ULONG &n_inverse);

__host__ int BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result);

__host__ int BN_WORD_parallel_mont_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *n, BN_WORD *result);


#endif
