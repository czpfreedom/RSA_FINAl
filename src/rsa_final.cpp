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

int BN_WORD:: setR(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_data[32]=1;
    m_neg=0;
    m_top=33;
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

#ifdef __cplusplus
}
#endif

int BN_mod_exp_cpp(BN_WORD rr,  BN_WORD a,  BN_WORD p,  BN_WORD m){
/*
    RSA_N rsa_n(m);
    CRT_N crt_n(rsa_n);
    crt_n.CRT_EXP_MOD_PARALL(a, p, rr);
    return 1;
*/
}

int BN_mod_exp_cuda(BN_WORD rr,  BN_WORD a, BN_WORD p, BN_WORD m){
// log    
    BN_mod_exp_cpp(rr, a, p, m);
    return 1;
}

}
