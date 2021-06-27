#ifndef BN_WORD_H
#define BN_WORD_H

#include "bn_part.h"
#include "stdio.h"

__device__ BN_WORD *BN_WORD_new_device(int dmax);

__device__ void BN_WORD_free_device(BN_WORD *a);

__host__ __device__ void BN_WORD_setzero(BN_WORD *a); // a->0

__host__ __device__ void BN_WORD_setone(BN_WORD *a); //a->1

__host__ __device__ int BN_WORD_copy(const BN_WORD *a,BN_WORD *b);
//-1: a->dmax!=b->dmax
//0: right

__device__ int BN_WORD_print_device(const BN_WORD *a);

__host__ int BN_WORD_print_log(FILE *out, BN_WORD *a);

__host__ __device__ int BN_WORD_cmp(const BN_WORD *a,const  BN_WORD *b);
// -1: a->dmax!=b->dmax
// 0: right
// 1: a is bigger
// 2: b is bigger

__host__ __device__ BN_PART bn_word_get_bit(const BN_WORD *a, int i);

__host__ __device__ int BN_WORD_left_shift(const BN_WORD *a,BN_WORD *b,int words);
// -1: a->dmax!=b->dmax
// -2: shift_words>a->dmax
// 0: right

__host__ __device__ int BN_WORD_left_shift_bits(const BN_WORD *a,BN_WORD *b,int bits);
// -1: a->dmax!=b->dmax
// 0: right
// need some test

__host__ __device__ int BN_WORD_right_shift(const BN_WORD *a,BN_WORD *b,int words);
// -1: a->dmax!=b->dmax
// -2: shift_words>a->dmax
// 0: right

__host__ __device__ int BN_WORD_right_shift_bits(const BN_WORD *a,BN_WORD *b,int bits);
// -1: a->dmax!=b->dmax
// 0: right
// need some test

__host__ __device__ int BN_WORD_add(const BN_WORD *a, const BN_WORD *b, BN_WORD *result);

__host__ __device__ int BN_WORD_sub(const BN_WORD *a, const BN_WORD *b, BN_WORD *result);
// -2: a<b
// 0: right

__device__ int BN_WORD_mul_device(const BN_WORD *a, const BN_WORD *b, BN_WORD *result);

__host__ int BN_WORD_div(const BN_WORD *a, const BN_WORD *b, BN_WORD *q, BN_WORD *r);

__device__ int BN_WORD_div_device(const BN_WORD *a, const BN_WORD *b, BN_WORD *q, BN_WORD *r);

__host__ int BN_WORD_mod (const BN_WORD *a, const BN_WORD *n, BN_WORD *result);

__device__ int BN_WORD_mod_device (const BN_WORD *a, const BN_WORD *n, BN_WORD *result);

__host__ int BN_WORD_add_mod(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result);

__host__ int BN_WORD_mul_mod(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result);

__host__ __device__ int BN_PART_BN_WORD_transform(BN_PART a, BN_WORD *result);

__host__ int BN_WORD_BN_PART_mod (BN_WORD *a, BN_PART n, BN_PART &result);

__device__ int BN_WORD_BN_PART_mod_device (BN_WORD *a, BN_PART n, BN_PART &result);


#endif
