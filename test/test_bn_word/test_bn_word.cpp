#include "bn_word.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#define DMAX 32
#define LOOP_NUM 1024

using namespace namespace_rsa_final;

int main(){
    BIGNUM *open_a, *open_b, *open_n, *open_result, *open_q, *open_r;
    BN_WORD bn_a, bn_b, bn_n, bn_result,bn_open_result, bn_q, bn_r;
    
    BN_CTX *ctx;
    int sum;

// test_bn_word_add
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,i,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);

	BN_add(open_result,open_a,open_b);
	BN_WORD_openssl_transform(open_result,bn_open_result);

	bn_result=bn_a+bn_b;

	if(bn_result==bn_open_result){
	    sum=sum+1;
	}
    }
    std::cout<<"test_bn_word_add:"<<std::endl;
    std::cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std::endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);


// test_bn_word_sub
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,i,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);

	BN_sub(open_result,open_a,open_b);
	BN_WORD_openssl_transform(open_result,bn_open_result);

	bn_result=bn_a-bn_b;
	if(bn_result==bn_open_result){
	    sum=sum+1;
	}
    }
    std::cout<<"test_bn_word_sub:"<<std::endl;
    std::cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std::endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);

// test_bn_word_mul
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,i,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);

	BN_mul(open_result,open_a,open_b,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result);

	bn_result=bn_a*bn_b;
	if(bn_result==bn_open_result){
	    sum=sum+1;
	}
    }
    std:: cout<<"test_bn_word_mul:"<<std:: endl;
    std:: cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std::endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);

// test_bn_word_div
    open_a=BN_new();
    open_b=BN_new();
    open_q=BN_new();
    open_r=BN_new();

    ctx=BN_CTX_new();
    
    sum=0;
    for (int i=1;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,i,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);

	BN_div(open_q,open_r,open_a,open_b,ctx);

	bn_q=bn_a/bn_b;
	BN_WORD_openssl_transform(open_q,bn_open_result);
	if(bn_q==bn_open_result){
	    sum=sum+1;
	}
    }
    std::cout<<"test_bn_word_div:"<<std::endl;
    std::cout<<"total:"<< LOOP_NUM-1<<", right:"<<sum<<std::endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_q);
    BN_free(open_r);
    BN_CTX_free(ctx);
 
// test_bn_word_rem
    open_a=BN_new();
    open_b=BN_new();
    open_q=BN_new();
    open_r=BN_new();

    ctx=BN_CTX_new();
    
    sum=0;
    for (int i=1;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,i,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);

	BN_div(open_q,open_r,open_a,open_b,ctx);

	bn_r=bn_a%bn_b;
	BN_WORD_openssl_transform(open_r,bn_open_result);
	if(bn_r==bn_open_result){
	    sum=sum+1;
	}
    }
    std::cout<<"test_bn_word_rem:"<<std::endl;
    std::cout<<"total:"<< LOOP_NUM-1<<", right:"<<sum<<std::endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_q);
    BN_free(open_r);
    BN_CTX_free(ctx);
 
// test_bn_word_mod
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    sum=0;
    for (int i=1;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,i,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);

	BN_mod(open_result,open_a,open_b,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result);

	bn_result=bn_a%bn_b;
	if(bn_result==bn_open_result){
	    sum=sum+1;
	}
    }
    std::cout<<"test_bn_word_mod:"<<std::endl;
    std::cout<<"total:"<< LOOP_NUM-1<<", right:"<<sum<<std::endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);


//test_bn_word_add_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);
	BN_WORD_openssl_transform(open_n,bn_n);

	BN_mod_add(open_result,open_a,open_b,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result);

	bn_result=(bn_a+bn_b)%bn_n;
	if(bn_result==bn_open_result){
	    sum=sum+1;
	}
    }
    std:: cout<<"test_bn_word_add_mod:"<<std:: endl;
    std:: cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std:: endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

//test_bn_word_mul_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a);
	BN_WORD_openssl_transform(open_b,bn_b);
	BN_WORD_openssl_transform(open_n,bn_n);

	BN_mod_mul(open_result,open_a,open_b,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result);

	bn_result=(bn_a*bn_b)%bn_n;
	if(bn_result==bn_open_result){
	    sum=sum+1;
	}
    }
    std:: cout<<"test_bn_word_mul_mod:"<<std:: endl;
    std:: cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std:: endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

    return 0;
}
