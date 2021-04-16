#include "bn_word.h"
#include "bn_openssl.h"
#include "iostream"

#define DMAX 2

using namespace std;

int main(){

    BIGNUM *open_a, *open_b, *open_n, *open_mod, *open_add_mod, *open_mul_mod;
    BN_CTX *ctx;
    BN_WORD *bn_a,*bn_b, *bn_n, *bn_mod, *bn_add_mod, *bn_mul_mod;

    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_mod=BN_new();
    open_add_mod=BN_new();
    open_mul_mod=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_mod=BN_WORD_new(DMAX);
    bn_add_mod=BN_WORD_new(DMAX);
    bn_mul_mod=BN_WORD_new(DMAX);

    BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
    BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
    BN_rand(open_n,DMAX*sizeof(BN_PART)*8,0,0);

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);

    cout<<"open_a"<<endl;
    BN_OPEN_PRINT(open_a);
    cout<<"open_b"<<endl;
    BN_OPEN_PRINT(open_b);
    cout<<"open_n"<<endl;
    BN_OPEN_PRINT(open_n);    

    BN_mod(open_mod, open_a, open_n, ctx);
    BN_WORD_copy(bn_a,bn_mod);
    BN_WORD_mod(bn_mod,bn_n,bn_mod);
    cout<<"open_mod"<<endl;
    BN_OPEN_PRINT(open_mod);
    cout<<"bn_mod"<<endl;
    BN_WORD_print(bn_mod);

    BN_mod_add(open_add_mod, open_a,open_b, open_n, ctx);
    BN_WORD_copy(bn_a,bn_add_mod);
    BN_WORD_add_mod(bn_add_mod,bn_b, bn_n,bn_add_mod);
    cout<<"open_mod_add"<<endl;
    BN_OPEN_PRINT(open_add_mod);
    cout<<"bn_mod_add"<<endl;
    BN_WORD_print(bn_add_mod);

    BN_mod_mul(open_mul_mod, open_a,open_b, open_n, ctx);
    BN_WORD_copy(bn_a,bn_mul_mod);
    BN_WORD_mul_mod(bn_mul_mod,bn_b,bn_n,bn_mul_mod);
    cout<<"open_mod_mul"<<endl;
    BN_OPEN_PRINT(open_mul_mod);
    cout<<"bn_mod_mul"<<endl;
    BN_WORD_print(bn_mul_mod);
}
