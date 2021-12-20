#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"
#include <iomanip>

#define DMAX 16
#define LOOP_NUM 2

using namespace namespace_rsa_final;

int main(){

    BIGNUM *open_a, *open_b, *open_n, *open_result;
    BN_CTX *ctx;
    BN_WORD bn_a,bn_b, bn_result, bn_open_result;
    RSA_N rsa_n;

    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    int sum=0;

    for(int i=0;i<LOOP_NUM;i++){

        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
        BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
        
        BN_WORD_openssl_prime_generation(rsa_n,DMAX*sizeof(BN_PART)*8);
        openssl_BN_WORD_transform(open_n,rsa_n.m_n);

        BN_WORD_openssl_transform(open_a,bn_a);
        BN_WORD_openssl_transform(open_b,bn_b);

        CRT_N crt_n ;
        crt_n = *new CRT_N (rsa_n);

        BN_mod_mul(open_result, open_a, open_b, open_n, ctx);

        crt_n.CRT_MOD_MUL(bn_a, bn_b, bn_result);
	
	BN_WORD_openssl_transform(open_result,bn_open_result);
/*
        if(bn_result==bn_open_result){
                sum=sum+1;
        }
	else{
*/
	    printf("a:\n");
	    for(int j=DMAX-1;j>=0;j--){
	        std::cout<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<std::hex<<bn_a.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("b:\n");
	    for(int j=DMAX-1;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_b.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("n:\n");
	    for(int j=DMAX-1;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<rsa_n.m_n.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("open_result:\n");
	    for(int j=DMAX-1;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_open_result.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("bn_result:\n");
	    for(int j=DMAX-1;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_result.m_data[j];
	    }
	    std::cout<<std::endl;
//	}
    }
    std:: cout<<"test_crt_mul_mod:"<<std:: endl;
    std:: cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std:: endl;

    return 0;

}
