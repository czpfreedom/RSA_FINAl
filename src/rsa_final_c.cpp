#include "rsa_final.h"


int BN_mod_exp_cuda(BN_WORD *rr, const BN_WORD *a, const BN_WORD *p, const BN_WORD *m){
    RSA_N rsa_n = new RSA_N(m);
    CRT_N crt_n = new CRT_N(rsa_n);

    crt_n.CRT_MUL_EXP(result, a, p, m);
    return 1;

}
