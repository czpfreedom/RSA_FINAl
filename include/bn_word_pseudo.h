#ifndef BN_WORD_PSEUDO_H
#define BN_WORD_PSEUDO_H


#include "bn_word_operation.h"

__host__ __device__ int BN_WORD_mul_lo(const BN_ULONG a, const BN_ULONG b, BN_ULONG &result);

__host__ __device__ int BN_WORD_mad_lo(const BN_ULONG a, const BN_ULONG b, BN_ULONG c, BN_ULONG &u, BN_ULONG &v);

__host__ __device__ int BN_WORD_mad_hi(const BN_ULONG a, const BN_ULONG b, BN_ULONG c, BN_ULONG &u, BN_ULONG &v);

//__host__ __device__ int BN_WORD_any(BN_WORD *a);

__host__ __device__ int BN_WORD_any(BN_ULONG *a, int dmax);
#endif
