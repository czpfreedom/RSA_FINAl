#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#define DMAX 32
#define LOOP_NUM 1

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

using namespace std;

int main(){
    
    BIGNUM  *open_a;
    BIGNUM  **open_m1, **open_m2, **open_a_mod_m1, **open_a_mod_m2;
    BN_CTX *ctx;
    BN_WORD *bn_a;
    BN_WORD *bn_a_reduction;
    BN_PART *bn_a_mod_m1, *bn_a_mod_m2;
    RSA_N *rsa_n;
    int sum;
    
    open_m1=(BIGNUM **)malloc(sizeof(BIGNUM*)*DMAX);
    open_m2=(BIGNUM **)malloc(sizeof(BIGNUM*)*DMAX);

    rsa_n=RSA_N_new(DMAX);
    BN_WORD_openssl_prime_generation(rsa_n);
    RNS_N rns_n(rsa_n);
    for(int i=0;i<DMAX;i++){
	open_m1[i]=BN_new();
	open_m2[i]=BN_new();
        BN_rand(open_m1[i],sizeof(BN_PART)*8,0,0);
        BN_rand(open_m2[i],sizeof(BN_PART)*8,0,0);
        open_m1[i]->d[0]=rns_n.m_m1[i];
        open_m2[i]->d[0]=rns_n.m_m2[i];
    }
// test RSA_RNS_reduction1
    open_a=BN_new();
    ctx=BN_CTX_new();
    bn_a=BN_WORD_new(DMAX);
    bn_a_reduction=BN_WORD_new(DMAX);
    open_a_mod_m1= (BIGNUM**)malloc(sizeof(BIGNUM*)*DMAX);
    bn_a_mod_m1=(BN_PART *)malloc(sizeof(BN_PART)*DMAX);
    for(int i=0;i<DMAX;i++){
        open_a_mod_m1[i]=BN_new();
    }
    sum=0;
    for(int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
        for(int j=0;j<DMAX;j++){
	    BN_mod(open_a_mod_m1[j],open_a,open_m1[j],ctx);
	    bn_a_mod_m1[j]=open_a_mod_m1[j]->d[0];
	}    
	rns_n.RSA_RNS_reduction1(bn_a_mod_m1, bn_a_reduction);	
	if(BN_WORD_cmp_test(bn_a,bn_a_reduction)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_rns_reduction1:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

// test RSA_RNS_reduction2

/*
    BIGNUM *open_a, *open_b, *open_n, *open_result;
    BN_CTX *ctx;
    BN_WORD *bn_a,*bn_b, *bn_result;
    RSA_N *rsa_n;

    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    rsa_n=RSA_N_new(DMAX);

    BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
    BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
    
    BN_WORD_openssl_prime_generation(rsa_n);
    openssl_BN_WORD_transform(rsa_n->n,open_n , DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);

    cout<<"open_a"<<endl;
    BN_OPEN_PRINT(open_a);
    cout<<"open_b"<<endl;
    BN_OPEN_PRINT(open_b);
    cout<<"open_n"<<endl;
    BN_OPEN_PRINT(open_n);    

    RNS_N rns_n(rsa_n);

    BN_mod_mul(open_result, open_a, open_b, open_n, ctx);
    rns_n.RNS_MUL_MOD(bn_a, bn_b, bn_result);

    RSA_N_free(rsa_n);

    cout<<"open_result"<<endl;
    BN_OPEN_PRINT(open_result);
    cout<<"bn_result"<<endl;
    BN_WORD_print(bn_result);
*/

}
