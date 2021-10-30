#include "bn_word.h"

namespace namespace_rsa_final{

__host__ RSA_N *RSA_N_new(int dmax){
    RSA_N *rsa_n;
    rsa_n=(RSA_N*)malloc(sizeof(RSA_N));
    rsa_n->n=BN_WORD_new(dmax);
    rsa_n->p=BN_WORD_new(dmax);
    rsa_n->q=BN_WORD_new(dmax);
    return rsa_n;
}

__host__ int RSA_N_free(RSA_N *rsa_n){
    BN_WORD_free(rsa_n->n);
    BN_WORD_free(rsa_n->p);
    BN_WORD_free(rsa_n->q);
    free(rsa_n);
    return 0;
}

}
