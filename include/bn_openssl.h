#ifndef BN_OPENSSL_H
#define BN_OPENSSL_H

#include "bn_word.h"
#include "openssl/bn.h"
#include "openssl/bn_lcl.h"

int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax);
// a->b  if a's byte < dmax return -1
// else return 0

#endif
