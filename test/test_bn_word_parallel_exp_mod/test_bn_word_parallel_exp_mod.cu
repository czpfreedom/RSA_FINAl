#include "openssl/bn.h"
#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "bn_word_parallel_mont_exp.h"
#include "iostream"

#include "parallel_mont_exp.h"

using namespace std;

#define CUDA_TIMING

#define DMAX 32

//#define inverse
//#define mul_host
#define parallel_mul_mod
//#define parallel_exp_mod

#ifdef CUDA_TIMING
#include "sys/time.h"
#endif


int main(){
    
    BIGNUM *open_a, *open_b, *open_e, *open_n, *open_result;

    BN_CTX *ctx;

    BN_WORD *bn_a,*bn_b,*bn_e, *bn_n, *bn_result,*bn_word_result;
    BN_NUM *num_a, *num_b, *num_n, *num_word_result;

    BN_ULONG n_inverse;

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

#ifdef inverse
    open_a=BN_new();
    BN_rand(open_a,sizeof(BN_ULONG)*8,0,0);
    while((open_a->d[0])%2==0){
          BN_rand(open_a,sizeof(BN_ULONG)*8,0,0);
    }
    cout<<"a:"<<hex<<open_a->d[0]<<endl;
    BN_ULONG_inverse((open_a->d[0]), n_inverse);

    cout<<"a_inverse:"<<hex<<n_inverse<<endl;
    cout<<"mul:"<<hex<<((open_a->d[0])*n_inverse)<<endl;
    BN_free(open_a);
#endif

#ifdef mul_host
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    BN_rand(open_a,DMAX*sizeof(BN_ULONG)*8,0,0);
    BN_rand(open_b,DMAX*sizeof(BN_ULONG)*8,0,0);
    BN_rand(open_n,DMAX*sizeof(BN_ULONG)*8,0,0);

//    BN_mod_mul(open_result,open_a,open_b,open_n,ctx);

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);
    
    BN_WORD_mul_mod_host(bn_a,bn_b,bn_n,bn_word_result);
     
    cout<<"open_a"<<endl;
    BN_WORD_print(bn_a);
    cout<<"open_b"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_n"<<endl;
    BN_WORD_print(bn_n);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_n);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);

#endif

#ifdef parallel_mul_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);

    num_a=BN_NUM_new(DMAX,1);
    num_b=BN_NUM_new(DMAX,1);
    num_n=BN_NUM_new(DMAX,1);
    num_word_result=BN_NUM_new(DMAX,1);

    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8),0,0);

    while((open_n->d[0]%2)==0){
        BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8),0,0);
    }

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    BN_mod_mul(open_result, open_a, open_b, open_n, ctx);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"cpu_time: "<<sum_time<<endl;
#endif

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

    BN_NUM_openssl_transform(open_a,num_a,DMAX,1);
    BN_NUM_openssl_transform(open_b,num_b,DMAX,1);
    BN_NUM_openssl_transform(open_n,num_n,DMAX,1);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    BN_WORD_parallel_mont_mul(bn_a,bn_b,bn_n,bn_word_result);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"gpu_time: "<<sum_time<<endl;
#endif

//    BN_NUM_parallel_mod_mul(num_a,num_b,num_n,DMAX,1,num_word_result);
    cout<<"open_a"<<endl;
    BN_WORD_print(bn_a);
    cout<<"open_b"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_n"<<endl;
    BN_WORD_print(bn_n);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
 //   cout<<"num_word_result"<<endl;
//    BN_NUM_print(num_word_result);

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_n);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);


#endif


#ifdef parallel_exp_mod
    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    
    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);
    
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_e,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8),0,0);


    while((open_n->d[0]%2)==0){
        BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8),0,0);
    }

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    
    BN_mod_exp(open_result, open_a, open_e, open_n, ctx);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"cpu_time: "<<sum_time<<endl;
#endif

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_e,bn_e,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    
    BN_WORD_parallel_mont_exp(bn_a,bn_e,bn_n,bn_word_result);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"gpu_time: "<<sum_time<<endl;
#endif

    cout<<"open_a"<<endl;
    BN_WORD_print(bn_a);
    cout<<"open_e"<<endl;
    BN_WORD_print(bn_e);
    cout<<"open_n"<<endl;
    BN_WORD_print(bn_n);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);

    BN_free(open_a);
    BN_free(open_e);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_e);
    BN_WORD_free(bn_n);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);


#endif


    return 0;
}
