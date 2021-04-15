#include "endecrypt.h"

int XAV_RSA_encrypt (BN_NUM *plaintext , BN_NUM *n, BN_NUM *e, BN_NUM *ciphertext){
    int wmax=plaintext->wmax;
    int dmax=plaintext->word[0]->dmax;
    BN_NUM_parallel_mont_exp( plaintext, n, e, wmax, dmax, ciphertext);
    return 0;
}

int XAV_RSA_decrypt (BN_NUM *ciphertext, BN_NUM *n, BN_NUM *d, BN_NUM *plaintext ){
    int wmax=plaintext->wmax;
    int dmax=plaintext->word[0]->dmax;
    BN_NUM_parallel_mont_exp( ciphertext, n, d, wmax, dmax, plaintext);
    return 0;
}

