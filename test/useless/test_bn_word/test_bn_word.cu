#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "sys/time.h"

#define DMAX 32
#define LOOP_NUM 1

#define PRINT



//#define BN_PART_MUL

#define ADD

//#define SUB

//#define SHIFT

//#define SHIFT_BITS

using namespace std;

int main(){
	
    BIGNUM *open_a, *open_b,*open_result;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_result;

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif


#ifdef BN_PART_MUL
    //test bn_ulong_mul
    BN_PART a=0x12345678L;
    BN_PART b=0x23456789L;
    BN_PART u,v;
    BN_PART_mul(a,b,u,v);
    cout<<hex<<"u:"<<u<<"v:"<<v<<endl;
    cout<<hex<<"result:"<<((unsigned long)a)*((unsigned long)b)<<endl;
#endif

#ifdef ADD

// test add
    cout<<"test add:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_PART)*8),0,0);
    
    

    open_a->d[0]=0x034d05d9f20e948d;
    open_a->d[1]=0x676bb39aa1307b61;
    open_a->d[2]=0x194f45a090d2a582;
    open_a->d[3]=0x7d958c240ee48b81;
    open_a->d[4]=0xdad78c12f40d6239;
    open_a->d[5]=0xa9541b1d41ec4564;
    open_a->d[6]=0xff6e065ea7657698;
    open_a->d[7]=0x8b2fc1937a84a2c8;
    open_a->d[8]=0x0f5b5219c24a4474;
    open_a->d[9]=0x0c094a937fe667c0;
    open_a->d[10]=0x5d00233a4b3c7945;
    open_a->d[11]=0x9b848db5a250e884;
    open_a->d[12]=0x658ea14a0554d5f7;
    open_a->d[13]=0xcb25482ade47324c;
    open_a->d[14]=0x92698dedd2f47787;
    open_a->d[15]=0xacf091a3d73ddbd8;

    open_b->d[0]=0xc5de03980c4093e2;
    open_b->d[1]=0x5668f211ba6503b4;
    open_b->d[2]=0x5c457dc846ab61c7;
    open_b->d[3]=0x325836efe908e063;
    open_b->d[4]=0x2fd924432c1df673;
    open_b->d[5]=0xcc4c003ee51a86c2;
    open_b->d[6]=0xfa482e48871e4d70;
    open_b->d[7]=0x35c5c7f574b04d22;
    open_b->d[8]=0x9821ea6d25127733;
    open_b->d[9]=0x7517a3dfa32d968a;
    open_b->d[10]=0x13bc52284f9b3cdb;
    open_b->d[11]=0xb917691e865ea6f8;
    open_b->d[12]=0x674dd349b0d6fb5a;
    open_b->d[13]=0xa39bee6fb6ca6c7e;
    open_b->d[14]=0x2e1147b51fd02e58;
    open_b->d[15]=0x30a940a7828ad0c0;

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif
    for(int i=0;i<LOOP_NUM;i++){
        BN_add(open_result,open_a,open_b);
    }
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
    for(int i=0;i<LOOP_NUM;i++){
        BN_WORD_add(bn_a,bn_b,bn_word_result);
    }
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
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),1,0);
    BN_rand(open_b,DMAX*(sizeof(BN_PART)*8),0,0);
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

    BN_WORD_sub(bn_a,bn_b,bn_a);

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
    BN_WORD_print(bn_a);
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
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),1,0);
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
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),1,0);
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


