#ifndef PSEUDO_H
#define PSEUDO_H

#include "bn_word_operation.h"
#include "bn_num_operation.h"


__device__ int mul_lo (const BN_WORD *a,const  BN_WORD *b, BN_WORD *result);
// -1: damx of a or b or result is not equal
// -2: carry of a or b is not 0
// 0: right

__device__ int mad_lo (const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v);
// -1: damx of a or b or c or u or v is not equal
// -2: carry of a or b is not 0
// 0: right

__device__ int mad_hi (const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v);
// -1: damx of a or b or u or v is not equal
// -2: carry of a or b is not 0
// 0: right

__device__ int any(BN_NUM *a);
//1: =0
//0: !=0

__global__ void mul_lo_global(const BN_WORD *a, const BN_WORD *b, BN_WORD*result);

__global__ void mad_lo_global(const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v);

__global__ void mad_hi_global(const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v);


/*

__host__ __device__ void mad_hi(BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v,BN_WORD *mul_word_result,
                BN_WORD *mid_value1, BN_WORD *mid_value2, BN_WORD *mid_value3, BN_WORD *mid_value4, BN_WORD *mid_value5,int *mul_return_value,
                int *add_return_value, int *mid_return_value, int * return_value);


//void mad_hi (BN_WORD a, BN_WORD b, BN_WORD c, BN_WORD &u, BN_WORD &v);
// -1: carry of a or b is not 0
// -2: damx of a and b is not equal
// 0: right
*/
#endif
