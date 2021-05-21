#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#define WORD_NUM 512
#define DMAX 32

using namespace std;

int main(){

    BIGNUM *open_a, *open_e, *open_n, *open_result;
    BN_CTX *ctx;
    BN_WORD_ARRAY *bn_a,*bn_e, *bn_result, *bn_open_result;
    RSA_N *rsa_n;

    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_ARRAY_new(WORD_NUM,DMAX);
    bn_e=BN_WORD_ARRAY_new(WORD_NUM,DMAX);
    bn_result=BN_WORD_ARRAY_new(WORD_NUM,DMAX);
    bn_open_result=BN_WORD_ARRAY_new(WORD_NUM,DMAX);
    rsa_n=RSA_N_new(DMAX);

    BN_WORD_openssl_prime_generation(rsa_n);
    openssl_BN_WORD_transform(rsa_n->n,open_n ,DMAX);
    
    CRT_N crt_n(rsa_n);
    
    for(int i=0;i<WORD_NUM;i++){
        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
        BN_rand(open_e,DMAX*sizeof(BN_PART)*8,0,0);    
        BN_WORD_openssl_transform(open_a,bn_a->bn_word[i],DMAX);
        BN_WORD_openssl_transform(open_e,bn_e->bn_word[i],DMAX);    
        BN_mod_exp(open_result, open_a, open_e, open_n, ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result->bn_word[i],DMAX);
    }

    crt_n.CRT_EXP_MOD_ARRAY(bn_a,bn_e,bn_result);
/*    
    for(int i=0;i<WORD_NUM;i++){
        printf("bn_open_result[%x]:\n",i);
	BN_WORD_print(bn_open_result->bn_word[i]);
        printf("bn_result[%x]:\n",i);
	BN_WORD_print(bn_result->bn_word[i]);
    }
*/
    RSA_N_free(rsa_n);



}
