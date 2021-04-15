#ifndef BN_PART_H
#define BN_PART_H 

#include "rsa_final.h"

__host__ __device__ int int_mod(const int a,const int b);

__host__ __device__ int BN_PART_mul(const BN_PART a, const BN_PART b, BN_PART &u, BN_PART &v);

__host__ __device__ BN_PART get_bit(const BN_PART a,int i);

__host__ int BN_PART_inverse(const BN_PART a, const BN_PART b, BN_PART &a_inverse);
// return a^{-1} mod b
// if b=0, return a^{-1} mod 2^m

__host__ __device__ int BN_PART_mul_lo(const BN_PART a, const BN_PART b, BN_PART &result);

__host__ __device__ int BN_PART_mad_lo(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v);

__host__ __device__ int BN_PART_mad_hi(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v);

__host__ __device__ int BN_PART_any(BN_PART *a, int dmax);

#endif
