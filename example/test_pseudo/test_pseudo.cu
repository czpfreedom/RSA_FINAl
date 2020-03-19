#include "bn_openssl.h"
#include "openssl/bn.h"
#include "pseudo.h"
#include "iostream"



#define DMAX 3

using namespace std;

int main(){

    BIGNUM *open_a, *open_b, *open_c, *open_result, *open_mid_value1, *open_mid_value2, *pow_2_w ;
    BN_WORD *bn_a, *bn_b, *bn_c, *bn_result,*bn_word_result, *mad_lo_u,*mad_lo_v,*mad_hi_u,*mad_hi_v;
    BN_CTX *ctx;
    int transform_result, return_value;
// test mul_lo
    cout<<"test mul_lo:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_mul(open_result,open_a,open_b,ctx);
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_result,bn_result,DMAX);
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
    return_value=mul_lo(bn_a,bn_b,bn_word_result);
    if(return_value!=0){
        cerr<<"Error: mul_lo failed"<<endl;
        exit(1);
    }
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

// test mad_lo
    
    cout<<"test mad_lo:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_c=BN_new();
    open_result=BN_new();
    open_mid_value1=BN_new();
    open_mid_value2=BN_new();
    ctx=BN_CTX_new();
    pow_2_w=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_c,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(pow_2_w,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_mid_value2,DMAX*(sizeof(BN_ULONG)*8),0,0);
    pow_2_w->top=DMAX;
    pow_2_w->dmax=DMAX;
    pow_2_w->d[0]=0;
    pow_2_w->d[1]=1;
    for(int i=2;i<DMAX;i++){
        pow_2_w->d[i]=0;
    }
    BN_mul(open_mid_value1,open_a,open_b,ctx);
    open_mid_value2->d[0]=open_mid_value1->d[0];
    for(int i=1;i<DMAX;i++){
        open_mid_value2->d[i]=0;
    }
    BN_add(open_result,open_mid_value2,open_c);
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_c=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX*2);
    mad_lo_u=BN_WORD_new(DMAX);
    mad_lo_v=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_c,bn_c,DMAX)
	    +BN_WORD_openssl_transform(open_result,bn_result,DMAX*2);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"c:"<<endl;
    BN_WORD_print(bn_c);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    mad_lo_global<<<1,1>>>(bn_a,bn_b,bn_c,mad_lo_u,mad_lo_v);
    cudaDeviceSynchronize();
    cout<<"bn_word_result_u"<<endl;
    BN_WORD_print(mad_lo_u);
    cout<<"bn_word_result_v"<<endl;
    BN_WORD_print(mad_lo_v);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_c);
    BN_free(open_result);
    BN_free(open_mid_value1);
    BN_free(open_mid_value2);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_c);
    BN_WORD_free(mad_lo_u);
    BN_WORD_free(mad_lo_v);


//test mad_hi


    cout<<"test mad_hi:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_c=BN_new();
    open_result=BN_new();
    open_mid_value1=BN_new();
    open_mid_value2=BN_new();
    ctx=BN_CTX_new();
    pow_2_w=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(open_c,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(pow_2_w,DMAX*(sizeof(BN_ULONG)*8),0,0);
    pow_2_w->top=DMAX;
    pow_2_w->dmax=DMAX;
    pow_2_w->d[0]=0;
    pow_2_w->d[1]=1;
    for(int i=2;i<DMAX;i++) pow_2_w->d[i]=0;
    BN_mul(open_mid_value1,open_a,open_b,ctx);
    BN_mul(open_mid_value2,open_c,pow_2_w,ctx);
    BN_add(open_result,open_mid_value2,open_mid_value1);
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_c=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX*2);
    mad_hi_u=BN_WORD_new(DMAX);
    mad_hi_v=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_c,bn_c,DMAX)+BN_WORD_openssl_transform(open_result,bn_result,DMAX*2);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"c:"<<endl;
    BN_WORD_print(bn_c);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    mad_hi_global<<<1,1>>>(bn_a, bn_b, bn_c, mad_hi_u, mad_hi_v);
    cudaDeviceSynchronize();
    cout<<"bn_word_result_u"<<endl;
    BN_WORD_print(mad_hi_u);
    cout<<"bn_word_result_v"<<endl;
    BN_WORD_print(mad_hi_v);
    
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_c);
    BN_free(pow_2_w);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_c);
    BN_WORD_free(mad_hi_u);
    BN_WORD_free(mad_hi_v);

/*  test mad_hi
   
   
   
    cout<<"test mul_hi:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_c=BN_new();
    open_result=BN_new();
    open_remain=BN_new();
    open_mid_value1=BN_new();
    open_mid_value2=BN_new();
    ctx=BN_CTX_new();
    pow_2_w=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(open_c,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(pow_2_w,DMAX*(sizeof(BN_ULONG)*8),0,0);
    pow_2_w->top=DMAX;
    pow_2_w->dmax=DMAX;
    pow_2_w->d[0]=0;
    pow_2_w->d[1]=1;
    for(int i=2;i<DMAX;i++) pow_2_w->d[i]=0;
    BN_mul(open_mid_value1,open_a,open_b,ctx);
    BN_mul(open_mid_value2,open_c,pow_2_w,ctx);
    BN_add(open_result,open_mid_value2,open_mid_value1);
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_c=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX*2);
    mad_hi_u=BN_WORD_new(DMAX);
    mad_hi_v=BN_WORD_new(DMAX);
    mid_value1=BN_WORD_new(DMAX);
    mid_value2=BN_WORD_new(DMAX);
    mid_value3=BN_WORD_new(DMAX);
    mid_value4=BN_WORD_new(DMAX);
    mul_word_result=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_c,bn_c,DMAX)
            +BN_WORD_openssl_transform(open_result,bn_result,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"c:"<<endl;
    BN_WORD_print(bn_c);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cudaMallocManaged((void**)&(add_return_value),sizeof(int));
    cudaMallocManaged((void**)&(mid_return_value),sizeof(int));
    cudaMallocManaged((void**)&(mul_return_value),sizeof(int));
    cudaMallocManaged((void**)&(mad_hi_return_value),sizeof(int));
    mad_hi(bn_a,bn_b,bn_c,mad_hi_u, mad_hi_v,mul_word_result,mid_value1,mid_value2,mid_value3,mid_value4,mul_return_value,
                add_return_value, mid_return_value, mad_hi_return_value);
    if(*(mad_hi_return_value)!=0){
        cerr<<"Error: add failed"<<endl;
        exit(1);
    }
    cout<<"bn_word_result_u"<<endl;
    BN_WORD_print(mad_hi_u);
    cout<<"bn_word_result_v"<<endl;
    BN_WORD_print(mad_hi_v);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_c);
    BN_free(pow_2_w);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_c);
    BN_WORD_free(bn_result);
    BN_WORD_free(mad_lo_u);
    BN_WORD_free(mad_lo_v);
    cudaFree(add_return_value);
    cudaFree(mad_hi_return_value);
    cudaFree(mad_hi_return_value);
*/
}
