#include "openssl/bn.h"
#include "bn_openssl.h"
#include "bn_word_parallel_mont_glo_exp.h"
#include "rns_rsa.h"
#include "iostream"
#include "sys/time.h"

#define LOOP_NUM 100

#define DMAX 32

using namespace std;

int main(){
    BIGNUM *open_a, *open_e, *open_n, *open_result;
    BN_WORD *bn_a,*bn_e, *bn_n, *bn_result,*bn_word_result;
    BN_CTX *ctx;
    
    RSA_N *rsa_n;
    rsa_n=RSA_N_new(DMAX);

    timeval start, stop;
    double sum_time;

    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);

    BN_WORD_openssl_prime_generation(rsa_n);

    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_e,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_e,bn_e,DMAX);    
    
    BN_WORD_copy(rsa_n->n,bn_n);
    openssl_BN_WORD_transform(bn_n,open_n,DMAX);

    RNS_N rns_n(rsa_n);
    
    gettimeofday(&start,0);
    for(int i=0; i<LOOP_NUM;i++){
        BN_mod_exp(open_result, open_a, open_e, open_n, ctx);
    }
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"cpu_time: "<<sum_time<<endl;

    gettimeofday(&start,0);
    for(int i=0; i<LOOP_NUM/10;i++){
        BN_WORD_parallel_mont_exp(bn_a,bn_e,bn_n,bn_result);
    }
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"crt_gpu_time: "<<sum_time<<endl;

    gettimeofday(&start,0);
    for(int i=0; i<LOOP_NUM;i++){
        rns_n.RSA(bn_a,bn_e,bn_result);
    }
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"rns_gpu_time: "<<sum_time<<endl;

}
