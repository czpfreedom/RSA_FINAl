#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"


#define DMAX 100
#define LOOP_NUM 100

#define CUDA_TIMING

//#define CTX_mul_bnulong
//#define CTX_mul_part
#define CTX_mul

//#define PRINT

using namespace std;

#ifdef CUDA_TIMING
#include "sys/time.h"
#endif


int main(){
    BIGNUM *open_a, *open_b,*open_result;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_u, *bn_word_v,*bn_ctx;
    BN_CTX *ctx;
    BN_ULONG bn_u, bn_v;


#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

#ifdef CTX_mul_bnulong
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,sizeof(BN_ULONG)*8,0,0);
    BN_rand(open_b,sizeof(BN_ULONG)*8,0,0);
    BN_mul(open_result,open_a,open_b,ctx);

    bn_result=BN_WORD_new(2);
    BN_WORD_openssl_transform(open_result,bn_result,2);

    BN_ULONG_mul(open_a->d[0],open_b->d[0],bn_u,bn_v);

    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cout<<"a:"<<hex<<open_a->d[0]<<endl;
    cout<<"b:"<<hex<<open_b->d[0]<<endl;
    cout<<"u:"<<hex<<bn_u<<endl;
    cout<<"v:"<<hex<<bn_v<<endl;
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_result);

#endif

#ifdef CTX_mul_part
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,sizeof(BN_ULONG)*8,0,0);
    BN_mul(open_result,open_a,open_b,ctx);

    bn_a=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX+1);
    bn_word_v=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX+1);

    BN_WORD_CTX_mul_part(bn_a,open_b->d[0],bn_u,bn_word_v);

    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cout<<"u:"<<hex<<bn_u<<endl;
    cout<<"open_word_v"<<endl;
    BN_WORD_print(bn_word_v);
    BN_free(open_a);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_v);

#endif

#ifdef CTX_mul

    cout<<"CTX_mul:"<<endl;

    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);


#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    for(int i=0;i<LOOP_NUM;i++){
        BN_mul(open_result,open_a,open_b,ctx);
    }
#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"mul_cpu_time: "<<sum_time<<endl;
#endif

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX*2);
    bn_word_u=BN_WORD_new(DMAX);
    bn_word_v=BN_WORD_new(DMAX);
    bn_ctx=BN_WORD_CTX_new(DMAX,4);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX*2);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    for(int i=0;i<LOOP_NUM;i++){
        BN_WORD_CTX_mul(bn_a,bn_b,bn_word_u,bn_word_v,bn_ctx);
    }
#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"mul_gpu_time: "<<sum_time<<endl;
#endif

#ifdef PRINT    
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cout<<"bn_word_u"<<endl;
    BN_WORD_print(bn_word_u);
    cout<<"bn_word_v"<<endl;
    BN_WORD_print(bn_word_v);
#endif

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_u);
    BN_WORD_free(bn_word_v);
    BN_WORD_CTX_free(bn_ctx,4);
#endif

}
