#ifndef BN_OPENSSL_H
#define BN_OPENSSL_H

#include "bn_word.h"
#include "openssl/bn.h"
#include "openssl/bn_lcl.h"
#include "bn_num.h"


int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax);
// a->b  if a's byte < dmax return -1
// else return 0

int BN_NUM_openssl_transform(BIGNUM *a,BN_NUM *b, int wmax, int dmax);

#endif
