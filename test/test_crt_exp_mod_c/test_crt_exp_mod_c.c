#include "rsa_final_c.h"

#define DMAX 2

int main(){
    BN_WORD *bn_a,*bn_e, *bn_n, *bn_result;

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    

    bn_a->d[0]=0x381ab7f6831c8bf5;
    bn_a->d[1]=0xb24b56d9c3831196;
    bn_e->d[0]=0x56ae26828b733720;
    bn_e->d[1]=0x980fbe7625eeb306;
    bn_n->d[0]=0x8b7372832abfad11;
    bn_n->d[1]=0xb619eb0eec80947;

    BN_mod_exp_cuda(bn_result,bn_a,bn_e,bn_n);
    printf("%lx,%lx\n",bn_result->d[1],bn_result->d[0]);

}
