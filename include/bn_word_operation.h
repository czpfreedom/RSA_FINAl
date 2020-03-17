#ifndef BN_WORD_OPERATION_H
#define BN_WORD_OPERATION_H

#include "bn_word.h"

BN_WORD* BN_WORD_new(int dmax);

int BN_WORD_free(BN_WORD *a);

__host__ __device__ int BN_WORD_setzero(BN_WORD *a); // a->0

//int BN_WORD_copy(BN_WORD *a,BN_WORD *b);

__host__ __device__ int BN_WORD_setone(BN_WORD *a);

__host__ __device__ void BN_WORD_print(BN_WORD *a);

__host__ __device__ void BN_WORD_cmp(BN_WORD *a, BN_WORD *b, int *cmp);
// -1: carry of a or b is not 0
// -2: damx of a and b is not equal
// 0: right
// 1: a is bigger
// 2: b is bigger
__host__ __device__ void BN_WORD_left_shift(BN_WORD *a,BN_WORD *b,int words,int *return_value);
//-1 : a->dmax<words
//-2 : a->dmax and b->dmax is not equal
//0 : right 

__host__ __device__ void BN_WORD_left_shift_bits(BN_WORD *a,BN_WORD *b,int bits,int *return_value);
//-1 : bits>64
//-2 : a->dmax and b->dmax is not equal
//0 : right 

__host__ __device__ void BN_WORD_right_shift(BN_WORD *a,BN_WORD *b,int words,int *return_value);
//-1 : a->dmax<words
//-2 : a->dmax and b->dmax is not equal
//0 : right

__host__ __device__ void BN_WORD_right_shift_bits(BN_WORD *a,BN_WORD *b,int bits,int *return_value);
//-1 : bits>64
//-2 : a->dmax and b->dmax is not equal
//0 : right 

__host__ __device__ void BN_WORD_add(BN_WORD *a, BN_WORD *b, BN_WORD *result, int *return_value);
// -1: carry of a or b is not 0
// -2: damx of a and b is not equal
// 0: right

__host__ __device__ void BN_WORD_sub(BN_WORD *a, BN_WORD *b, BN_WORD *result, int *cmp_return_value,int *return_value);

// -1: carry of a or b is not 0
// -2: damx of a and b is not equal
// -3: a is smaller than b
// 0: right

__host__ __device__ void BN_WORD_high (BN_WORD *a, BN_WORD *b);

__host__ __device__ void BN_WORD_low (BN_WORD *a, BN_WORD *b);

__host__ __device__ void BN_WORD_mul_half(BN_WORD *a, BN_WORD *b, BN_WORD *result, BN_WORD *mid_value1,BN_WORD *mid_value2,int *add_return_value);

__host__ __device__ void BN_WORD_mul(BN_WORD *a, BN_WORD *b, BN_WORD *a_half, BN_WORD *b_half,BN_WORD *result,BN_WORD *mid_value1,  BN_WORD *mid_value2, BN_WORD *mid_value3, BN_WORD *temp_result, int *add_return_value, int *shift_return_value);

/*
__host__ __device__ void BN_WORD_mul_word_bnulong(BN_WORD *a, BN_ULONG b,BN_WORD *result, BN_WORD *mid_value1, BN_WORD *mid_value2,
                BN_WORD *mid_value5, int *return_value, int *mid_return_value);


__host__ __device__ void BN_WORD_mul(BN_WORD *a, BN_WORD *b, BN_WORD *result_u,BN_WORD *result_v,BN_WORD *mul_word_result,  BN_WORD *mid_value1,
                BN_WORD *mid_value2, BN_WORD *mid_value3,BN_WORD *mid_value4, BN_WORD *mid_value5,int *return_value,
		int *add_return_value,int *mid_return_value);
*/

#endif
