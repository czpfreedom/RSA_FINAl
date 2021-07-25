#include "bn_openssl.h"
#include "iostream"
#include "rsa_final.h" 

#define DMAX 32
#define LOOP_NUM 10

using namespace std;

int BN_WORD_cmp_test(const BN_WORD *a,const BN_WORD *b){
	if((a->dmax)!=(b->dmax)){
	    return -1;
	}
	for(int i=(a->dmax)-1;i>=0;i--){
	    if(a->d[i]>b->d[i]){
		return 1;
	    }
	    if(a->d[i]<b->d[i]){
		return 2;
	    }
	}
	return 0;
}

int main(){

    BIGNUM *open_a, *open_b, *open_e, *open_n, *open_result; 
    BN_WORD *bn_a,*bn_b, *bn_e, *bn_result;
    BN_WORD *bn_open_result;
    BN_CTX *ctx;
    
    int sum;
    
    RSA_N *rsa_n;
    rsa_n=RSA_N_new(DMAX);
    BN_WORD_openssl_prime_generation(rsa_n);
    CRT_N  crt_n(rsa_n);
    open_n=BN_new();
    openssl_BN_WORD_transform(rsa_n->n, open_n, DMAX);

//test_crt_mul_mod

    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);
	
	BN_mod_mul(open_result,open_a,open_b,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	crt_n.CRT_MUL_MOD(bn_a,bn_b,bn_result);
	if(BN_WORD_cmp_test(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_crt_mod_mul:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);
//test_crt_exp_mod
    
    open_a=BN_new();
    open_e=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_e,DMAX*sizeof(BN_PART)*8,0,0);
	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_e,bn_e,DMAX);
	
	BN_mod_exp(open_result,open_a,open_e,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	crt_n.CRT_EXP_MOD(bn_a,bn_e,bn_result);
	if(BN_WORD_cmp_test(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_crt_mod_exp:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;
    BN_free(open_a);
    BN_free(open_e);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_e);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

//test_crt_exp_mod_parallel
    open_a=BN_new();
    open_e=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_e,DMAX*sizeof(BN_PART)*8,0,0);
	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_e,bn_e,DMAX);
	
	BN_mod_exp(open_result,open_a,open_e,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	crt_n.CRT_EXP_MOD_PARALL(bn_a,bn_e,bn_result);
	if(BN_WORD_cmp_test(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_crt_mod_exp_parallel:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;
    BN_free(open_a);
    BN_free(open_e);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_e);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

    return 0;
}
