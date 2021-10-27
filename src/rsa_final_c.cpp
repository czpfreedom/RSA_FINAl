#include "rsa_final.h"
#include <stdio.h>

namespace namespace_rsa_final{

int BN_mod_exp_cpp(BN_WORD *rr,  BN_WORD *a,  BN_WORD *p,  BN_WORD *m){
    RSA_N *rsa_n;
    rsa_n = RSA_N_new(a->dmax);
    BN_WORD_copy_host(m,rsa_n->n);
    CRT_N crt_n(rsa_n);
    crt_n.CRT_EXP_MOD_PARALL(a, p, rr);
    RSA_N_free(rsa_n);
    return 0;
}

int print_log_BN1(BN_WORD *rr){
    FILE * f=NULL;
    int k=0;
    f=fopen("/usr/local/log/rsa_final.log","a+"); 
    if(f!=NULL){
        for(k=0;k<rr->dmax;k++){
	    fprintf(f,"%lx\n",rr->d[k]);
    	    fprintf(f,"#########################\n");
        }
    }
    fclose(f);

}
int BN_mod_exp_cuda(BN_WORD *rr,  BN_WORD *a, BN_WORD *p, BN_WORD *m){
    print_log_BN1(p);
    BN_mod_exp_cpp(rr, a, p, m);
    return 1;
}

}
