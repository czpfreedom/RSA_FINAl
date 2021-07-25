#ifndef BN_OPENSSL_H
#define BN_OPENSSL_H

#include "openssl/bn.h"
#include "rsa_final.h"

int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax);

int openssl_BN_WORD_transform(BN_WORD *a, BIGNUM *b, int dmax);

int BN_WORD_openssl_prime_generation(RSA_N *rsa_n);

int BN_OPEN_PRINT(BIGNUM *a);


#endif
