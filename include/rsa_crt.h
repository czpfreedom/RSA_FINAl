#ifndef RSA_CRT_H
#define RSA_CRT_H

#include "bn_word.h"

namespace namespace_rsa_final{

__device__ int  GPU_WORD_parallel_Mon(BN_PART *A, BN_PART *B,  BN_PART *N, BN_PART n0_inverse, BN_PART *M, BN_PART *U, BN_PART *V, BN_PART *C, BN_PART *result, int thread_id);

__device__ int GPU_WORD_delete_carry(BN_PART *result, BN_PART *N, BN_PART c);

__global__ void GPU_WORD_mod_mul( BN_PART *A, BN_PART *B , BN_PART *N , BN_PART n0_inverse, BN_PART *result);

__global__ void GPU_WORD_mod_exp( BN_PART *A, BN_PART *E , int E_bits, BN_PART *mR, BN_PART *N , BN_PART n0_inverse, BN_PART *result);

__global__ void GPU_WORD_ARRAY_mod_exp( BN_PART *A, BN_PART *E , int E_bits, BN_PART *mR, BN_PART *N , BN_PART n0_inverse, BN_PART *result);
}

#endif
