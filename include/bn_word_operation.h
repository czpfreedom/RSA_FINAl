#ifndef BN_WORD_OPERATION_H
#define BN_WORD_OPERATION_H

#include "bn_word.h"

__host__ BN_WORD *BN_WORD_new(int dmax);

__device__ BN_WORD *BN_WORD_new_device(int dmax);

__host__ void BN_WORD_free(BN_WORD *a);

__device__ void BN_WORD_free_device(BN_WORD *a);

__host__ __device__ void BN_WORD_setzero(BN_WORD *a); // a->0


__host__ __device__ void BN_WORD_setone(BN_WORD *a); //a->1

__host__ __device__ int BN_WORD_copy(BN_WORD *a,BN_WORD *b);
//-1: a->dmax!=b->dmax
//0: right

__host__ __device__ void BN_WORD_print(BN_WORD *a);

__host__ __device__ int BN_WORD_cmp(BN_WORD *a, BN_WORD *b);
// -1: a->dmax!=b->dmax
// -2: a'carry or b'carry !=0
// 0: right
// 1: a is bigger
// 2: b is bigger


__host__ __device__ int BN_WORD_left_shift(BN_WORD *a,BN_WORD *b,int words);
// -1: a->dmax!=b->dmax
// -3: shift_words>a->dmax
// 0: right

__host__ __device__ int BN_WORD_left_shift_bits(BN_WORD *a,BN_WORD *b,int bits);
// -1: a->dmax!=b->dmax
// -3: shift_bits>bits of bn_ulong
// 0: right

__host__ __device__ int BN_WORD_right_shift(BN_WORD *a,BN_WORD *b,int words);
// -1: a->dmax!=b->dmax
// -3: shift_words>a->dmax
// 0: right

__host__ __device__ int BN_WORD_right_shift_bits(BN_WORD *a,BN_WORD *b,int bits);
// -1: a->dmax!=b->dmax
// -3: shift_bits>bits of bn_ulong
// 0: right

__host__ __device__ int BN_WORD_add(BN_WORD *a, BN_WORD *b, BN_WORD *result);
// -1: a->dmax!=b->dmax
// -2: a'carry or b'carry !=0
// 0: right

__host__ __device__ int BN_WORD_sub(BN_WORD *a, BN_WORD *b, BN_WORD *result);
// -1: a->dmax!=b->dmax
// -2: a'carry or b'carry !=0
// -4: a<b
// 0: right


__host__ __device__ void BN_WORD_high (BN_WORD *a, BN_WORD *b);

__host__ __device__ void BN_WORD_low (BN_WORD *a, BN_WORD *b);

__device__ int BN_WORD_mul_half(BN_WORD *a, BN_WORD *b, BN_WORD *result);

__device__ int BN_WORD_mul(BN_WORD *a, BN_WORD *b, BN_WORD *result);
// -1: a->dmax!=b->dmax
// -2: a'carry or b'carry !=0
// 0: right

//__global__ void gpu_bn_word_mul(BN_WORD *a,BN_WORD *b,BN_WORD *result);
/*
__host__ __device__ void BN_WORD_mul_word_bnulong(BN_WORD *a, BN_ULONG b,BN_WORD *result, BN_WORD *mid_value1, BN_WORD *mid_value2,
                BN_WORD *mid_value5, int *return_value, int *mid_return_value);


__host__ __device__ void BN_WORD_mul(BN_WORD *a, BN_WORD *b, BN_WORD *result_u,BN_WORD *result_v,BN_WORD *mul_word_result,  BN_WORD *mid_value1,
                BN_WORD *mid_value2, BN_WORD *mid_value3,BN_WORD *mid_value4, BN_WORD *mid_value5,int *return_value,
		int *add_return_value,int *mid_return_value);
*/

#endif
