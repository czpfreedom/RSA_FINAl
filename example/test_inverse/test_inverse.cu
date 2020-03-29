#include "bn_num_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "parallel_mont_mul.h"


#ifndef DMAX
#define DMAX 2
#endif

#ifndef WMAX
#define WMAX 2
#endif

using namespace std;

int main(){
// test inverse
BIGNUM *open_n;
BN_NUM *bn_n, *bn_n_inverse,*bn_result;
open_n=BN_new();
BN_rand(open_n,WMAX*DMAX*(sizeof(BN_ULONG)*8),0,0);
while((open_n->d[0]%((BN_ULONG)2))==0){
    BN_rand(open_n,WMAX*DMAX*(sizeof(BN_ULONG)*8),0,0);
}
//open_n_neg=BN_new();
//BN_rand(open_n_neg,WMAX*DMAX*(sizeof(BN_ULONG)*8),0,0);
//open_n->d[0]=0x123456789abcdeffL;
//open_n->d[1]=0x23456789abcdefffL;
//open_n->d[2]=0x3456789abcdeffffL;
//open_n->d[3]=0x456789abcdefffffL;
//open_n_neg->d[0]=0xedcba98765432101L;
//open_n_inverse->d[0]=
bn_n=BN_NUM_new(WMAX,DMAX);
bn_n_inverse=BN_NUM_new(WMAX,DMAX);
bn_result=BN_NUM_new(WMAX,DMAX);
BN_NUM_openssl_transform(open_n,bn_n,WMAX,DMAX);
//cout<<"bn_n_inverse"<<endl;
BN_NUM_inverse(bn_n, WMAX, DMAX, bn_n_inverse);
BN_NUM_mul(bn_n,bn_n_inverse,bn_result);
cout<<"n:"<<endl;
BN_NUM_print(bn_n);
cout<<"n_inverse:"<<endl;
BN_NUM_print(bn_n_inverse);
cout<<"result"<<endl;
BN_NUM_print(bn_result);
}

