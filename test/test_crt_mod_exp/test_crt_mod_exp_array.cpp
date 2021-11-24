#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"
#include <iomanip>

#define WORD_NUM 1024
#define DMAX 32

using namespace namespace_rsa_final;

int main(){

    BIGNUM *open_e, *open_n;
    BIGNUM *open_a[WORD_NUM];
    BIGNUM *open_result[WORD_NUM];
    BN_CTX *ctx;

    BN_WORD bn_e;
    BN_WORD_ARRAY bn_a_array, bn_result_array, bn_open_result_array;
    RSA_N rsa_n;

    bn_a_array=*new BN_WORD_ARRAY(WORD_NUM);
    bn_result_array=*new BN_WORD_ARRAY(WORD_NUM);
    bn_open_result_array=*new BN_WORD_ARRAY(WORD_NUM);

    
    open_e=BN_new();
    open_n=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_e,DMAX*sizeof(BN_PART)*8,0,0);
    BN_WORD_openssl_transform(open_e,bn_e);


    for(int i=0;i<WORD_NUM;i++){
        open_a[i]=BN_new();
        open_result[i]=BN_new();    
    	BN_rand(open_a[i],DMAX*sizeof(BN_PART)*8,0,0);
        BN_WORD_openssl_transform(open_a[i],bn_a_array.m_bn_word[i]);
    }
    

    BN_WORD_openssl_prime_generation(rsa_n,DMAX*sizeof(BN_PART)*8);
    openssl_BN_WORD_transform(open_n,rsa_n.m_n);
    

    CRT_N crt_n ;
    crt_n = *new CRT_N (rsa_n);

    for(int i=0 ; i<WORD_NUM;i++){
        BN_mod_exp(open_result[i], open_a[i], open_e, open_n, ctx);    
        BN_WORD_openssl_transform(open_result[i],bn_open_result_array.m_bn_word[i]);
    }

    crt_n.CRT_MOD_EXP_ARRAY(bn_a_array, bn_e, bn_result_array);

    int sum=0;

    for(int i=0; i<WORD_NUM;i++){
        if(bn_result_array.m_bn_word[i]==bn_open_result_array.m_bn_word[i]){
	    sum=sum+1;
        }    
	else{
	    printf("a:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_a_array.m_bn_word[i].m_data[j];
	    }
	    std::cout<<std::endl; 
/*		    ;
	    printf("e:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_e.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("n:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<rsa_n.m_n.m_data[j];
	    }
	    std::cout<<std::endl;
*/
	    printf("result:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_result_array.m_bn_word[i].m_data[j];
	    }
	    std::cout<<std::endl;
	}
    }

    std:: cout<<"test_crt_mod_exp_array:"<<std:: endl;
    std:: cout<<"total:"<< WORD_NUM<<", right:"<<sum<<std:: endl;

    return 0;

}
