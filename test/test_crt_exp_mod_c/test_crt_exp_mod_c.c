#include "rsa_final_c.h"

#define DMAX 1

int main(){

    BN_WORD *bn_a,*bn_e, *bn_n, *bn_result;

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    
    bn_a->d[0]=2;
    bn_e->d[0]=3;
    bn_n->d[0]=5;


    BN_mod_exp_cuda(bn_result,bn_a,bn_e,bn_n);

}
