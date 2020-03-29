#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"


#define DMAX 3


using namespace std;

__global__ void gpu_bn_word_mul(BN_WORD *a,BN_WORD *b,BN_WORD *result){
    BN_WORD_mul(a,b,result);
}


int main(){
    BIGNUM *open_a, *open_b, *open_result;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_result;
    int transform_result;
    BN_CTX *ctx;

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
    bn_result=BN_WORD_new(DMAX*2);
    bn_word_result=BN_WORD_new(DMAX*2);
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
    gpu_bn_word_mul<<<1,1>>>(bn_a,bn_b,bn_word_result);
    cudaDeviceSynchronize();
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);

}

