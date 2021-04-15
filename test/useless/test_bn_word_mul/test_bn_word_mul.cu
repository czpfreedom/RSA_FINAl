#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"

#define DMAX 3
#define LOOP_NUM 1
#define CUDA_TIMING

#define PRINT

//#define MUL
#define DIV

using namespace std;

#ifdef CUDA_TIMING
#include "sys/time.h"
#endif

__global__ void gpu_bn_word_mul(BN_WORD *a,BN_WORD *b,BN_WORD *result){
    BN_WORD_mul_device(a,b,result);
}


int main(){
    BIGNUM *open_a, *open_b, *open_result, *open_q, *open_r;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_result, *bn_q, *bn_r, *bn_word_q, *bn_word_r;
    BN_CTX *ctx;

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

#ifdef MUL
//test mul
    cout<<"test_mul:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_PART)*8),0,0);

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

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    BN_WORD *test_word;
    for(int i=0;i<LOOP_NUM;i++){
        test_word=BN_WORD_new(DMAX);
	BN_WORD_free(test_word);
    }
#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"new_cpu_time: "<<sum_time<<endl;
#endif

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX*2);
    bn_word_result=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    for(int i=0;i<LOOP_NUM;i++){
	BN_WORD_mul(bn_a,bn_b,bn_word_result);
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
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
#endif

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);
#endif
//test div
#ifdef DIV
    cout<<"test_div:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_q=BN_new();
    open_r=BN_new();
    ctx=BN_CTX_new();
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_PART)*8),0,0);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    for(int i=0;i<LOOP_NUM;i++){
        BN_div(open_q,open_r,open_a,open_b,ctx);
    }
#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"div_cpu_time: "<<sum_time<<endl;
#endif
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_q=BN_WORD_new(DMAX);
    bn_r=BN_WORD_new(DMAX);
    bn_word_q=BN_WORD_new(DMAX);
    bn_word_r=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_q,bn_q,DMAX)+BN_WORD_openssl_transform(open_r,bn_r,DMAX);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
        BN_WORD_div(bn_a,bn_b,bn_word_q,bn_word_r);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"div_cpu_time: "<<sum_time<<endl;
#endif

#ifdef PRINT
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_q"<<endl;
    BN_WORD_print(bn_q);
    cout<<"open_r"<<endl;
    BN_WORD_print(bn_r);
    cout<<"bn_word_q"<<endl;
    BN_WORD_print(bn_word_q);
    cout<<"bn_word_r"<<endl;
    BN_WORD_print(bn_word_r);
#endif

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_q);
    BN_free(open_r);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_q);
    BN_WORD_free(bn_r);
    BN_WORD_free(bn_word_q);
    BN_WORD_free(bn_word_r);
#endif
}

