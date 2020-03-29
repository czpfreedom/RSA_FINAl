#include "bn_num_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"

#ifndef DMAX
#define DMAX 4
#endif

#ifndef WMAX
#define WMAX 2
#endif

using namespace std;

int main(){
    
	
    BIGNUM *open_a, *open_b,*open_result,*open_d,*open_r;
    BN_NUM *bn_a, *bn_b, *bn_result, *bn_d, *bn_r,*bn_word_result, *bn_word_d, *bn_word_r;
    BN_CTX *ctx;
    int transform_result;
    int return_value;
/*

// test add
    cout<<"test add:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
    BN_add(open_result,open_a,open_b);

    bn_a=BN_NUM_new(WMAX,DMAX);
    bn_b=BN_NUM_new(WMAX,DMAX);
    bn_result=BN_NUM_new(WMAX,DMAX);
    bn_word_result=BN_NUM_new(WMAX,DMAX);
    transform_result=BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX)+BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX)+BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_NUM_print(bn_a);
    cout<<"b:"<<endl;
    BN_NUM_print(bn_b);
    cout<<"open_result"<<endl;
    BN_NUM_print(bn_result);
    return_value=BN_NUM_add(bn_a,bn_b,bn_word_result);
    if(return_value!=0){
        cerr<<"Error: add failed"<<endl;
        exit(1);
    }
    cout<<"bn_word_result"<<endl;
    BN_NUM_print(bn_word_result);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_NUM_free(bn_a);
    BN_NUM_free(bn_b);
    BN_NUM_free(bn_result);
    BN_NUM_free(bn_word_result);
    
//test sub
    
    cout<<"test sub:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
    BN_sub(open_result,open_a,open_b);

    bn_a=BN_NUM_new(WMAX,DMAX);
    bn_b=BN_NUM_new(WMAX,DMAX);
    bn_result=BN_NUM_new(WMAX,DMAX);
    bn_word_result=BN_NUM_new(WMAX,DMAX);
    transform_result=BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX)+BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX)+BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_NUM_print(bn_a);
    cout<<"b:"<<endl;
    BN_NUM_print(bn_b);
    cout<<"open_result"<<endl;
    BN_NUM_print(bn_result);
    return_value=BN_NUM_sub(bn_a,bn_b,bn_word_result);
    if(return_value!=0){
        cerr<<"Error: sub failed"<<endl;
        exit(1);
    }
    cout<<"bn_word_result"<<endl;
    BN_NUM_print(bn_word_result);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_NUM_free(bn_a);
    BN_NUM_free(bn_b);
    BN_NUM_free(bn_result);
    BN_NUM_free(bn_word_result);

//test shift

    open_a=BN_new();
    BN_rand(open_a,WMAX*DMAX*(sizeof(BN_ULONG)*8),1,0);
    bn_a=BN_NUM_new(WMAX,DMAX);
    transform_result=BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
    bn_result=BN_NUM_new(WMAX,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_NUM_print(bn_a);
    BN_NUM_left_shift_bits(bn_a,bn_result,8);
    cout<<"left_shift_bits:"<<endl;
    BN_NUM_print(bn_result);
    BN_NUM_right_shift_bits(bn_a,bn_result,8);
    cout<<"right_shift_bits:"<<endl;
    BN_NUM_print(bn_result);
    BN_free(open_a);
    BN_NUM_free(bn_a);
    BN_NUM_free(bn_result);

 // test mul

    cout<<"test mul:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
    BN_mul(open_result,open_a,open_b,ctx);
    bn_a=BN_NUM_new(WMAX,DMAX);
    bn_b=BN_NUM_new(WMAX,DMAX);
    bn_result=BN_NUM_new(WMAX,DMAX);
    bn_word_result=BN_NUM_new(WMAX,DMAX);
    transform_result=BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX)+BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX)+BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_NUM_print(bn_a);
    cout<<"b:"<<endl;
    BN_NUM_print(bn_b);
    return_value=BN_NUM_mul(bn_a,bn_b,bn_word_result);
    if(return_value!=0){
        cerr<<"Error: mul failed"<<endl;
        exit(1);
    }
    cout<<"bn_word_result"<<endl;
    BN_NUM_print(bn_word_result);
    cout<<"open_result"<<endl;
    BN_NUM_print(bn_result);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_NUM_free(bn_a);
    BN_NUM_free(bn_b);
    BN_NUM_free(bn_result);
    BN_NUM_free(bn_word_result);
    BN_CTX_free(ctx);
*/
//test div

    cout<<"test div:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_d=BN_new();
    open_r=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,1,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,1,0);
    open_b->d[DMAX*WMAX-1]=0;
    open_b->d[DMAX*WMAX-2]=0;
    open_b->d[DMAX*WMAX-3]=0;
    BN_div(open_d,open_r,open_a,open_b,ctx);
    bn_a=BN_NUM_new(WMAX,DMAX);
    bn_b=BN_NUM_new(WMAX,DMAX);
    bn_d=BN_NUM_new(WMAX,DMAX);
    bn_r=BN_NUM_new(WMAX,DMAX);
    bn_word_d=BN_NUM_new(WMAX,DMAX);
    bn_word_r=BN_NUM_new(WMAX,DMAX);
    BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
    BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX);
    cout<<"1"<<endl;
    BN_NUM_openssl_transform(open_d,bn_d,WMAX,DMAX);
    BN_NUM_openssl_transform(open_r,bn_r,WMAX,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_NUM_print(bn_a);
    cout<<"b:"<<endl;
    BN_NUM_print(bn_b);
    return_value=BN_NUM_div(bn_a,bn_b,bn_word_d,bn_word_r);
    if(return_value!=0){
        cerr<<"Error: div failed"<<endl;
        exit(1);
    }
    cout<<"bn_word_d"<<endl;
    BN_NUM_print(bn_word_d);
    cout<<"bn_word_r"<<endl;
    BN_NUM_print(bn_word_r);
    cout<<"open_d"<<endl;
    BN_NUM_print(bn_d);
    cout<<"open_r"<<endl;
    BN_NUM_print(bn_r);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_d);
    BN_free(open_r);
    BN_NUM_free(bn_a);
    BN_NUM_free(bn_b);
    BN_NUM_free(bn_r);
    BN_NUM_free(bn_d);
    BN_NUM_free(bn_word_d);
    BN_NUM_free(bn_word_r);
    BN_CTX_free(ctx);

}
