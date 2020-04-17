#include "bn_num_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "parallel_mont_exp.h"


#ifndef DMAX
#define DMAX 1
#endif

#ifndef WMAX
#define WMAX 3
#endif

using namespace std;

int main(){



BIGNUM *open_a, *open_b,*open_e,*open_n,*open_result,*open_R, *open_temp;
BN_CTX *ctx;
BN_NUM *bn_a, *bn_b,*bn_e, *bn_n, *bn_result,*bn_word_result;
/*
//test R_inverse and test mul_mod_host
open_a=BN_new();
open_b=BN_new();
open_n=BN_new();
open_result=BN_new();
ctx=BN_CTX_new();

bn_a=BN_NUM_new(WMAX,DMAX);
bn_b=BN_NUM_new(WMAX,DMAX);
bn_n=BN_NUM_new(WMAX,DMAX);
bn_result=BN_NUM_new(WMAX,DMAX);
bn_word_result=BN_NUM_new(WMAX,DMAX);

BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
while((open_n->d[0]%2)==0){
        BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
}
BN_mod_mul(open_result, open_a, open_b, open_n, ctx);
BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX);
BN_NUM_openssl_transform(open_n,bn_n,WMAX,DMAX);
BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
cout<<"open_a"<<endl;
BN_NUM_print(bn_a);
cout<<"open_b"<<endl;
BN_NUM_print(bn_b);
cout<<"open_n"<<endl;
BN_NUM_print(bn_n);
cout<<"open_result"<<endl;
BN_NUM_print(bn_result);
BN_NUM_mul_mod_host(bn_a, bn_b, bn_n,bn_word_result);
cout<<"bn_word_result"<<endl;
BN_NUM_print(bn_word_result);
BN_free(open_a);
BN_free(open_b);
BN_free(open_n);
BN_free(open_result);
BN_CTX_free(ctx);
BN_NUM_free(bn_a);
BN_NUM_free(bn_b);
BN_NUM_free(bn_n);
BN_NUM_free(bn_result);
BN_NUM_free(bn_word_result);
*/
//test parallel_exp_mod

open_a=BN_new();
open_e=BN_new();
open_n=BN_new();
open_result=BN_new();
open_R=BN_new();
open_temp=BN_new();
ctx=BN_CTX_new();

bn_a=BN_NUM_new(WMAX,DMAX);
bn_e=BN_NUM_new(WMAX,DMAX);
bn_n=BN_NUM_new(WMAX,DMAX);
bn_result=BN_NUM_new(WMAX,DMAX);
bn_word_result=BN_NUM_new(WMAX,DMAX);
BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_e,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_R,DMAX*(sizeof(BN_ULONG)*8)*WMAX+8,0,0);
for(int i=0;i<WMAX*DMAX;i++){
    open_R->d[i]=0;
}
open_R->d[WMAX*DMAX]=1;
while((open_n->d[0]%2)==0){
        BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
}
BN_mod_exp(open_result, open_a, open_e, open_n, ctx);
BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
BN_NUM_openssl_transform(open_e,bn_e,WMAX,DMAX);
BN_NUM_openssl_transform(open_n,bn_n,WMAX,DMAX);
BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
cout<<"open_a"<<endl;
BN_NUM_print(bn_a);
cout<<"open_e"<<endl;
BN_NUM_print(bn_e);
cout<<"open_n"<<endl;
BN_NUM_print(bn_n);
cout<<"open_result"<<endl;
BN_NUM_print(bn_result);
BN_NUM_parallel_mont_exp(bn_a, bn_e, bn_n, WMAX, DMAX, bn_word_result);
cout<<"bn_word_result"<<endl;
BN_NUM_print(bn_word_result);

BN_free(open_a);
BN_free(open_e);
BN_free(open_n);
BN_free(open_result);
BN_CTX_free(ctx);
BN_NUM_free(bn_a);
BN_NUM_free(bn_e);
BN_NUM_free(bn_n);
BN_NUM_free(bn_result);
BN_NUM_free(bn_word_result);


return 0;


}
