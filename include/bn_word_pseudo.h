#ifndef BN_WORD_PSEUDO_H
#define BN_WORD_PSEUDO_H

#include "bn_word_operation.h"

__host__ __device__ int BN_WORD_mul_lo(const BN_PART a, const BN_PART b, BN_PART &result);

__host__ __device__ int BN_WORD_mad_lo(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v);

__host__ __device__ int BN_WORD_mad_hi(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v);

//__host__ __device__ int BN_WORD_any(BN_WORD *a);

__host__ __device__ int BN_WORD_any(BN_PART *a, int dmax);
#endif
