#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#define DMAX 2

using namespace std;

int main(){

    BIGNUM *open_a, *open_e, *open_n, *open_result;
    BN_CTX *ctx;
    BN_WORD *bn_a,*bn_e, *bn_result;
    RSA_N *rsa_n;

    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    rsa_n=RSA_N_new(DMAX);

    BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
    BN_rand(open_e,DMAX*sizeof(BN_PART)*8,0,0);
    
    BN_WORD_openssl_prime_generation(rsa_n);
    openssl_BN_WORD_transform(rsa_n->n,open_n , DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_e,bn_e,DMAX);

    cout<<"open_a"<<endl;
    BN_OPEN_PRINT(open_a);
    cout<<"open_e"<<endl;
    BN_OPEN_PRINT(open_e);
    cout<<"open_n"<<endl;
    BN_OPEN_PRINT(open_n);    

    CRT_N crt_n(rsa_n);

    BN_mod_exp(open_result, open_a, open_e, open_n, ctx);
    crt_n.CRT_MUL_EXP(bn_a, bn_e, bn_result);

    cout<<"open_result"<<endl;
    BN_OPEN_PRINT(open_result);
    cout<<"bn_result"<<endl;
    BN_WORD_print(bn_result);


}
