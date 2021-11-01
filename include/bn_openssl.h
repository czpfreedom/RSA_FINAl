#ifndef BN_OPENSSL_H
#define BN_OPENSSL_H

#include "openssl/bn.h"
#include "rsa_final.h"

#ifdef EXTRA_OPENSSL

namespace namespace_rsa_final{

int BN_WORD_openssl_transform(BIGNUM *a, BN_WORD &b);

int openssl_BN_WORD_transform(BIGNUM *a, BN_WORD &b);

int BN_WORD_openssl_prime_generation(RSA_N &rsa_n, int bits);

int BN_OPEN_PRINT(BIGNUM *a);

}

#endif
#endif
