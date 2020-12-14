#ifndef BN_OPENSSL_H
#define BN_OPENSSL_H

#include "bn_word.h"
#include "openssl/bn.h"
#include "openssl/bn_lcl.h"
#include "rns_rsa.h"

__host__ int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax);
// a->b  if a's byte < dmax return -1
// else return 0

__host__ int openssl_BN_WORD_transform(BN_WORD *a, BIGNUM *b, int dmax);

__host__ int BN_WORD_openssl_prime_generation(RSA_N *rsa_n);

__host__ int BN_OPEN_PRINT(BIGNUM *a);

#endif
