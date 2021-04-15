#ifndef BN_WORD_PARALLEL_MONT_GLO_EXP_H
#define BN_WORD_PARALLEL_MONT_GLO_EXP_H

#include "bn_word_parallel_mont_exp.h"

__global__ void BN_WORD_parallel_mont_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *n, const BN_PART n0_inverse, BN_WORD *square,BN_WORD *result);

__host__ int BN_WORD_parallel_mont_glo_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *n, BN_WORD *result);

__host__ int BN_WORD_parallel_mont_crt_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *p, const BN_WORD *q, BN_WORD *result);

#endif
