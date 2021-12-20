#include "rsa_final.h"
#include <stdio.h>
#include "rsa_final_log.h"
#include "string.h"
#include "iostream"
#include "sstream"
#include <iomanip>

namespace namespace_rsa_final{


#ifdef __cplusplus
extern "C" {
#endif

BN_WORD_C* BN_WORD_C_new(int top, int neg){
    BN_WORD_C *bw_c;
    bw_c=(BN_WORD_C*)malloc(sizeof(BN_WORD_C));
    bw_c->m_top=top;
    bw_c->m_neg=neg;
    return bw_c;

}

int BN_WORD_C_free(BN_WORD_C *bw_c){
    free(bw_c);
    return 1;
}

int BN_WORD_C_setzero(BN_WORD_C *bw_c){
    memset(bw_c->m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    bw_c->m_top=1;
    bw_c->m_neg=0;
    return 1;
}

int BN_WORD_C_check_top(BN_WORD_C *bw_c){
    for(int i=BN_WORD_LENGTH_MAX-1;i>=0;i--){
        if(i==0){
            if(bw_c->m_data[i]==0){
                BN_WORD_C_setzero(bw_c);
                return 1;
            }
        }
        if(bw_c->m_data[i]!=0){
            bw_c->m_top=i+1;
            break;
        }
    }
    if(bw_c->m_top>BN_WORD_LENGTH_MAX/2){
        //error
        return -1;
    }
    return 1;
}

int BN_mod_exp_cuda_c(BN_WORD_C *rr, BN_WORD_C *a, BN_WORD_C *e , BN_WORD_C *n){
    BN_WORD bn_a, bn_e, bn_n, bn_rr;
    bn_a.BN_WORD_C_2_BN_WORD(a);
    bn_e.BN_WORD_C_2_BN_WORD(e);
    bn_n.BN_WORD_C_2_BN_WORD(n);
    BN_mod_exp_cuda(bn_rr,  bn_a, bn_e, bn_n);
    bn_rr.BN_WORD_2_BN_WORD_C(rr);
    return 1;
}

#ifdef __cplusplus
}
#endif

int BN_mod_exp_cuda(BN_WORD &rr,  BN_WORD a, BN_WORD e, BN_WORD n){
    RSA_N rsa_n;
    rsa_n.m_n=n;
    CRT_N crt_n(rsa_n);
    crt_n.CRT_MOD_EXP(a,e,rr);
    return 1;
}

}
