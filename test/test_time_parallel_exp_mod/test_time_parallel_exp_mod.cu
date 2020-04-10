#include "bn_num_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "parallel_mont_exp.h"

#define CUDA_TIMING

#ifndef DMAX
#define DMAX 1
#endif

#ifndef WMAX
#define WMAX 100
#endif

#ifdef CUDA_TIMING
#include "sys/time.h"
#endif

using namespace std;

int main(){



BIGNUM *open_a, *open_b,*open_e,*open_n,*open_result,*open_R, *open_temp;
BN_CTX *ctx;
BN_NUM *bn_a, *bn_b,*bn_e, *bn_n, *bn_result,*bn_word_result;

#ifdef CLOCKING
clock_t start, stop, sum_time;
#endif

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

//test R_inverse and test mul_mod_host
open_a=BN_new();
open_b=BN_new();
open_n=BN_new();
open_result=BN_new();
ctx=BN_CTX_new();

bn_a=BN_NUM_new(WMAX,DMAX);
bn_b=BN_NUM_new(WMAX,DMAX);
bn_n=BN_NUM_new(WMAX,DMAX);
bn_result=BN_NUM_new(WMAX,DMAX);
bn_word_result=BN_NUM_new(WMAX,DMAX);

BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
while((open_n->d[0]%2)==0){
        BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
}
#ifdef CLOCKING
    start=clock();
#endif 

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
for(int i=0;i<1;i++){
    BN_mod_mul(open_result, open_a, open_b, open_n, ctx);
}

#ifdef CLOCKING
    stop=time(NULL);
    sum_time= stop-start;
    cout<<"cpu_time:"<<(double)(sum_time)<<endl;
#endif

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"cpu_time: "<<sum_time<<endl;
#endif

BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX);
BN_NUM_openssl_transform(open_n,bn_n,WMAX,DMAX);
BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
/*
cout<<"open_a"<<endl;
BN_NUM_print(bn_a);
cout<<"open_b"<<endl;
BN_NUM_print(bn_b);
cout<<"open_n"<<endl;
BN_NUM_print(bn_n);
cout<<"open_result"<<endl;
BN_NUM_print(bn_result);
*/
#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

for(int i=0;i<1;i++){
    BN_NUM_parallel_mod_mul(bn_a, bn_b, bn_n,bn_word_result);
}

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"gpu_time: "<<sum_time<<endl;
#endif

/*
cout<<"bn_word_result"<<endl;
BN_NUM_print(bn_word_result);
*/
BN_free(open_a);
BN_free(open_b);
BN_free(open_n);
BN_free(open_result);
BN_CTX_free(ctx);
BN_NUM_free(bn_a);
BN_NUM_free(bn_b);
BN_NUM_free(bn_n);
BN_NUM_free(bn_result);
BN_NUM_free(bn_word_result);
/*
//test parallel_exp_mod

open_a=BN_new();
open_e=BN_new();
open_n=BN_new();
open_result=BN_new();
open_R=BN_new();
open_temp=BN_new();
ctx=BN_CTX_new();

bn_a=BN_NUM_new(WMAX,DMAX);
bn_e=BN_NUM_new(WMAX,DMAX);
bn_n=BN_NUM_new(WMAX,DMAX);
bn_result=BN_NUM_new(WMAX,DMAX);
bn_word_result=BN_NUM_new(WMAX,DMAX);
BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_e,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_R,DMAX*(sizeof(BN_ULONG)*8)*WMAX+8,0,0);
for(int i=0;i<WMAX*DMAX;i++){
    open_R->d[i]=0;
}
open_R->d[WMAX*DMAX]=1;
while((open_n->d[0]%2)==0){
        BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
}
BN_mod_exp(open_result, open_a, open_e, open_n, ctx);
BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
BN_NUM_openssl_transform(open_e,bn_e,WMAX,DMAX);
BN_NUM_openssl_transform(open_n,bn_n,WMAX,DMAX);
BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
cout<<"open_a"<<endl;
BN_NUM_print(bn_a);
cout<<"open_e"<<endl;
BN_NUM_print(bn_e);
cout<<"open_n"<<endl;
BN_NUM_print(bn_n);
cout<<"open_result"<<endl;
BN_NUM_print(bn_result);
BN_NUM_parallel_mont_exp(bn_a, bn_e, bn_n, WMAX, DMAX, bn_word_result);
cout<<"bn_word_result"<<endl;
BN_NUM_print(bn_word_result);

BN_free(open_a);
BN_free(open_e);
BN_free(open_n);
BN_free(open_result);
BN_CTX_free(ctx);
BN_NUM_free(bn_a);
BN_NUM_free(bn_e);
BN_NUM_free(bn_n);
BN_NUM_free(bn_result);
BN_NUM_free(bn_word_result);
*/

return 0;


}
