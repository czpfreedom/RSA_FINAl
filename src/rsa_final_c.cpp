#include "rsa_final.h"

int BN_mod_exp_cpp(BN_WORD *rr,  BN_WORD *a,  BN_WORD *p,  BN_WORD *m){
    RSA_N *rsa_n;
    rsa_n = RSA_N_new(a->dmax);
    CRT_N crt_n(rsa_n);
    crt_n.CRT_MUL_EXP(a, p, rr);
    return 0;
}


int BN_mod_exp_cuda(BN_WORD *rr,  BN_WORD *a, BN_WORD *p, BN_WORD *m){

    BN_mod_exp_cpp(rr, a, p, m);
    return 1;


}
