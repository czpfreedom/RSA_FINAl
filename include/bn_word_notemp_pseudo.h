#ifndef BN_WORD_PSEUDO_H
#define BN_WORD_PSEUDO_H


#include "bn_word_operation.h"


__host__ __device__ int BN_WORD_mad_lo_notemp(const BN_ULONG a, const BN_ULONG b, BN_ULONG &u, BN_ULONG &v);

__host__ __device__ int BN_WORD_mad_hi_notemp(const BN_ULONG a, const BN_ULONG b, BN_ULONG &u, BN_ULONG &v);



#endif
