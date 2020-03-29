#ifndef BN_NUM_OPER_H
#define BN_NUM_OPER_H

#include "bn_num.h"
#include "bn_word_operation.h"
#include "bn_word.h"

__host__ BN_NUM *BN_NUM_new(int wmax,int dmax);

__device__ BN_NUM *BN_NUM_new_device(int wmax, int dmax);

__host__ void BN_NUM_free(BN_NUM *a);

__device__ void BN_NUM_free_device(BN_NUM *a);

__host__ __device__ void BN_NUM_copy(const BN_NUM *a, BN_NUM *b);

__host__ __device__ void BN_NUM_setzero(BN_NUM *a);

__host__ __device__ void BN_NUM_setone(BN_NUM *a);

__host__ __device__ int BN_NUM_cmp(const BN_NUM *a,const BN_NUM *b);

__host__ __device__ void BN_NUM_print(const BN_NUM *a);

__host__ int BN_NUM_add (const BN_NUM *a,const BN_NUM *b,BN_NUM *result);

__device__ int BN_NUM_add_device(const BN_NUM *a,const BN_NUM *b,BN_NUM *result);

__host__ int BN_NUM_sub (const BN_NUM *a,const BN_NUM *b,BN_NUM *result);

__device__ int BN_NUM_sub_device(const BN_NUM *a, const BN_NUM *b, BN_NUM *result);

__host__ int BN_NUM_left_shift_bits(const BN_NUM *a,BN_NUM *b,int bits);

__host__ int BN_NUM_right_shift_bits(const BN_NUM *a,BN_NUM *b,int bits);

__host__ int BN_NUM_mul(const BN_NUM *a,const BN_NUM *b,BN_NUM *result);

__host__ int BN_NUM_div(const BN_NUM *a,const BN_NUM *b,BN_NUM *q, BN_NUM *r);

#endif
