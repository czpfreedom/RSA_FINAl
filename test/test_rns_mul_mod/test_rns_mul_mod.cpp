#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#define DMAX 32

using namespace std;

int main(){

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


}
