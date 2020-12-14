#ifndef BN_PART_H
#define BN_PART_H 

#include "bn_word.h"

__host__ __device__ int int_mod(const int a,const int b);

__host__ __device__ int BN_PART_mul(const BN_PART a, const BN_PART b, BN_PART &u, BN_PART &v);

__host__ __device__ BN_PART get_bit(const BN_PART a,int i);

__host__ __device__ BN_PART bn_word_get_bit(const BN_WORD *a, int i);

__host__ int BN_PART_inverse(const BN_PART n, BN_PART &n_inverse);

#endif
