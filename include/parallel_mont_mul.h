#ifndef PARALLEL_MONT_MUL_H
#define PARALLEL_MONT_MUL_H

#include "bn_num.h"
#include "bn_num_operation.h"
#include "pseudo.h"

__host__ int BN_NUM_inverse(const BN_NUM *n, const int d, const int l, BN_NUM *n_inverse);

__host__ int BN_NUM_mod_mul(const BN_NUM *a, const BN_NUM *b, const BN_NUM *n, const int d, const int l,BN_NUM *result);


__global__ void parallel_mont_mul(const BN_NUM *a,const BN_NUM *b,const BN_NUM *n,const int wmax,const int dmax,const BN_WORD *n0_inverse,
                BN_NUM *result, BN_NUM *u, BN_NUM *u_temp,BN_NUM *v, BN_NUM *m, BN_NUM *c,BN_NUM *v_temp, int *any_value);







#endif
