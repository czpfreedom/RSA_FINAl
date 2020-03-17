#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"


#define DMAX 3

using namespace std;

int main(){
    BIGNUM *open_a, *open_b, *open_result;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_result,*bn_a_half,*bn_b_half, *mid_value1, *mid_value2, *mid_value3,*temp_result;
    int transform_result;
    BN_CTX *ctx;
    int *shift_return_value, *add_return_value;

//test mul
    cout<<"test_mul:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_mul(open_result,open_a,open_b,ctx);
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_a_half=BN_WORD_new(DMAX);
    bn_b_half=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX*2);
    bn_word_result=BN_WORD_new(DMAX*2);
    mid_value1=BN_WORD_new(DMAX*2);
    mid_value2=BN_WORD_new(DMAX*2);
    mid_value3=BN_WORD_new(DMAX*2);
    temp_result=BN_WORD_new(DMAX*2);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_result,bn_result,DMAX*2);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cudaMallocManaged((void**)&(shift_return_value),sizeof(int));
    cudaMallocManaged((void**)&(add_return_value),sizeof(int));
    BN_WORD_mul(bn_a,bn_b, bn_a_half, bn_b_half,bn_word_result,mid_value1,mid_value2, mid_value3, temp_result,add_return_value, shift_return_value);
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);







}

