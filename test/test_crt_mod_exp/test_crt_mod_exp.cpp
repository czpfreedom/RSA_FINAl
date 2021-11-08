#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"
#include <iomanip>

#define DMAX 32
#define LOOP_NUM 32


using namespace namespace_rsa_final;

int main(){

    BIGNUM *open_a, *open_e, *open_n, *open_result;
    BN_CTX *ctx;
    BN_WORD bn_a,bn_e, bn_result, bn_open_result;
    RSA_N rsa_n;

    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    int sum=0;

    for(int i=0;i<LOOP_NUM;i++){

        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
        BN_rand(open_e,DMAX*sizeof(BN_PART)*8,0,0);
        
        BN_WORD_openssl_prime_generation(rsa_n,DMAX*sizeof(BN_PART)*8);
        openssl_BN_WORD_transform(open_n,rsa_n.m_n);
        BN_WORD_openssl_transform(open_a,bn_a);
        BN_WORD_openssl_transform(open_e,bn_e);

        RSA_N rsa_n2=rsa_n;
        CRT_N *crt_n ;
        crt_n = new CRT_N (rsa_n);

        BN_mod_exp(open_result, open_a, open_e, open_n, ctx);

        crt_n->CRT_MOD_EXP(bn_a, bn_e, bn_result);
	
	BN_WORD_openssl_transform(open_result,bn_open_result);

        if(bn_result==bn_open_result){
                sum=sum+1;
        }
	else{
	    printf("a:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_a.m_data[j];
	    }
	    std::cout<<std::endl;
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
	    printf("result:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_result.m_data[j];
	    }
	    std::cout<<std::endl;
	}

    }

    std:: cout<<"test_crt_exp_mod:"<<std:: endl;
    std:: cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std:: endl;

    return 0;

}
