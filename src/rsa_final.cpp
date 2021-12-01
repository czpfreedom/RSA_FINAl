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

int BN_WORD_C_setzero(BN_WORD_C *a){
    
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

BN_WORD :: BN_WORD(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=0;
    m_top=1;
}

BN_WORD:: BN_WORD(BN_WORD &bn_word){
    memcpy(m_data,bn_word.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=bn_word.m_neg;
    m_top=bn_word.m_top;
}

BN_WORD& BN_WORD:: operator=(BN_WORD &bn_word){
    memcpy(m_data,bn_word.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=bn_word.m_neg;
    m_top=bn_word.m_top;
    return *this;
}

BN_WORD:: ~BN_WORD(){

}

int BN_WORD:: check_top(){
    for(int i=BN_WORD_LENGTH_MAX-1;i>=0;i--){
	if(i==0){
	    if(m_data[i]==0){
	        setzero();
    		return 1;	    
	    }
	}
        if(m_data[i]!=0){
	    m_top=i+1;
	    break;
	}
    }
    if(m_top>BN_WORD_LENGTH_MAX/2){
	//error
        return -1;
    }
    return 1;

}

int BN_WORD:: setzero(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=0;
    m_top=1;
    return 1;
}

int BN_WORD:: setone(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_data[0]=1;
    m_neg=0;
    m_top=1;
    return 1;
}

int BN_WORD:: setR(int top){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_data[top-1]=1;
    m_neg=0;
    m_top=top;
    return 1;
}

int BN_WORD:: print(){
    if(m_neg==0){
        printf("postive: top: %d\n", m_top);
    }
    if(m_neg==1){
        printf("negtive: top: %d\n", m_top);
    }
    for(int i=m_top-1;i>=0;i--){
        printf("%lx,",m_data[i]);
    }
    printf("\n");
    return 1;
}

int BN_WORD:: BN_WORD_2_Str(std::string &str){
    std:: stringstream fmt;
    for(int i=m_top-1;i>=0;i--){
	fmt<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<std::hex<<m_data[i];
    }
    fmt>>str;
    return 0;
}

int BN_WORD:: Str_2_BN_WORD(std::string str){
    std:: string sub_str;
    int top=0;
    setzero();
    std:: stringstream fmt;
    for(int i=str.length()/(sizeof(BN_PART)*2)-1;i>=0;i--){
        sub_str=str.substr(i*(sizeof(BN_PART)*2),sizeof(BN_PART)*2);
	fmt.clear();
	fmt<<std::hex<<sub_str;
	fmt>>m_data[top];
	top++;
    }
    m_top=top;
    return 1;
}

int BN_WORD:: BN_WORD_C_2_BN_WORD(BN_WORD_C *bw_c){
    memcpy(m_data,bw_c->m_data,sizeof(BN_PART)*BN_WORD_LENGTH_MAX);
    m_top=bw_c->m_top;
    m_neg=bw_c->m_neg;
    return 1;
}

int BN_WORD:: BN_WORD_2_BN_WORD_C(BN_WORD_C *bw_c){
    memcpy(bw_c->m_data,m_data,sizeof(BN_PART)*BN_WORD_LENGTH_MAX);
    bw_c->m_top=m_top;
    bw_c->m_neg=m_neg;
    return 1;
}

int BN_mod_exp_cuda(BN_WORD &rr,  BN_WORD a, BN_WORD e, BN_WORD n){
// log    
    RSA_N rsa_n;
    rsa_n.m_n=n;
    CRT_N crt_n = * new CRT_N(rsa_n);
    crt_n.CRT_MOD_EXP(a,e,rr);
    return 1;
}






}
