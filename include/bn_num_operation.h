#ifndef BN_NUM_OPER_H
#define BN_NUM_OPER_H

#include "bn_num.h"
#include "bn_word_operation.h"
#include "bn_word.h"

__host__ BN_NUM *BN_NUM_new(int wmax,int dmax);

__device__ BN_NUM *BN_NUM_new_device(int wmax, int dmax);

__host__ void BN_NUM_free(BN_NUM *a);

__device__ void BN_NUM_free_device(BN_NUM *a);

#endif
