#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"


#define DMAX 32

#define CUDA_TIMING

//#define PRINT

#define ADD

#define SUB
#define shift
#define shift_bits

using namespace std;

#ifdef CUDA_TIMING
#include "sys/time.h"
#endif

int main(){

	
    BIGNUM *open_a, *open_b,*open_result;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_result;
    int transform_result;
    int return_value;

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

#ifdef ADD

// test add
    cout<<"test add:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    BN_add(open_result,open_a,open_b);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"add_cpu_time: "<<sum_time<<endl;
#endif

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    BN_WORD_add(bn_a,bn_b,bn_word_result);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"add_gpu_time: "<<sum_time<<endl;
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
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);

#endif

#ifdef SUB
//test sub

    cout<<"test sub:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    BN_sub(open_result,open_a,open_b);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"sub_cpu_time: "<<sum_time<<endl;
#endif

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    BN_WORD_sub(bn_a,bn_b,bn_word_result);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"sub_gpu_time: "<<sum_time<<endl;
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
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);

#endif

#ifdef SHIFT
//test shift
    open_a=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    bn_a=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    bn_result=BN_WORD_new(DMAX);

#ifdef PRINT
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    BN_WORD_left_shift(bn_a,bn_result,10);
    cout<<"left_shift:"<<endl;
    BN_WORD_print(bn_result);
    BN_WORD_right_shift(bn_a,bn_result,10);
    cout<<"right_shift:"<<endl;
    BN_WORD_print(bn_result);
#endif

    BN_free(open_a);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_result);

#endif

#ifdef SHIFT_BITS
//test shift_bits
    open_a=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    bn_a=BN_WORD_new(DMAX);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    bn_result=BN_WORD_new(DMAX);

#ifdef PRINT
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    BN_WORD_left_shift_bits(bn_a,bn_result,72);
    cout<<"left_shift_bits:"<<endl;
    BN_WORD_print(bn_result);
    BN_WORD_right_shift_bits(bn_a,bn_result,72);
    cout<<"right_shift_bits:"<<endl;
    BN_WORD_print(bn_result);
#endif

    BN_free(open_a);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_result);
#endif

}


