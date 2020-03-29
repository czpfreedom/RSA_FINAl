#include "bn_num_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "parallel_mont_mul.h"


#ifndef DMAX
#define DMAX 3
#endif

#ifndef WMAX
#define WMAX 5
#endif

using namespace std;

int main(){

BIGNUM *open_a, *open_b,*open_n,*open_R,*open_R_inverse,*open_mul_result,*open_result,*open_temp_result;
BN_CTX *ctx;
BN_NUM *bn_a, *bn_b, *bn_n, *bn_R,*bn_mul_result,*bn_result,*bn_word_result;
open_a=BN_new();
open_b=BN_new();
open_n=BN_new();
open_R=BN_new();
open_R_inverse=BN_new();
open_mul_result=BN_new();
open_result=BN_new();
open_temp_result=BN_new();
ctx=BN_CTX_new();
/*
char_R=(unsigned char*)malloc(sizeof(unsigned char)*(WMAX*DMAX*64+1));
for(int i=0;i<WMAX*DMAX*64;i++){
    char_R[i]=0;
}
char_R[WMAX*DMAX*64]='1';
BN_bin2bn(char_R, WMAX*DMAX*64+1, open_R);
BN_NUM_openssl_transform(open_R,bn_R,WMAX,DMAX);
BN_NUM_print(bn_R);
*/
bn_a=BN_NUM_new(WMAX,DMAX);
bn_b=BN_NUM_new(WMAX,DMAX);
bn_n=BN_NUM_new(WMAX,DMAX);
bn_R=BN_NUM_new(WMAX,DMAX);
bn_mul_result=BN_NUM_new(WMAX,DMAX);
bn_result=BN_NUM_new(WMAX,DMAX);
bn_word_result=BN_NUM_new(WMAX,DMAX);
BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
while((open_n->d[0]%2)==0){
    	BN_rand(open_n,DMAX*(sizeof(BN_ULONG)*8)*WMAX,0,0);
}
BN_rand(open_R,DMAX*(sizeof(BN_ULONG)*8)*WMAX+sizeof(BN_ULONG)*8,0,0);
for(int i=0;i<DMAX*WMAX;i++){
    open_R->d[i]=0;
}
open_R->d[DMAX*WMAX]=1;
BN_NUM_openssl_transform(open_R,bn_R,WMAX,DMAX);
BN_NUM_print(bn_R);
printf("R:%lx\n",open_R->d[DMAX*WMAX]);
/*
//process
BIGNUM *open_v,*open_n_inverse, *open_m, *open_q;
BN_WORD *bn_v, *bn_n_inverse, *bn_m;
open_v=BN_new();
open_n_inverse=BN_new();
open_m=BN_new();
open_q=BN_new();
bn_v=BN_WORD_new(DMAX);
bn_n_inverse=BN_WORD_new(DMAX);
bn_m=BN_WORD_new(DMAX);
BN_mod_mul(open_v,open_a,open_b,open_R,ctx);
BN_WORD_openssl_transform(open_v,bn_v,DMAX);
cout<<"open_v:"<<endl;
BN_WORD_print(bn_v);
BN_mod_inverse(open_n_inverse,open_n,open_R,ctx);
BN_sub(open_n_inverse,open_R,open_n_inverse);
BN_WORD_openssl_transform(open_n_inverse,bn_n_inverse,DMAX);
cout<<"open_n_inverse:"<<endl;
BN_WORD_print(bn_n_inverse);
BN_mod_mul(open_m,open_v,open_n_inverse,open_R,ctx);
BN_WORD_openssl_transform(open_m,bn_m,DMAX);
cout<<"open_m:"<<endl;
BN_WORD_print(bn_m);
BN_mod_mul(open_temp_result,open_n,open_m,open_R,ctx);
BN_add(open_v,open_v,open_temp_result);
BN_WORD_openssl_transform(open_v,bn_v,DMAX);
cout<<"open_v:"<<endl;
BN_WORD_print(bn_v);
printf("u:%lx\n",open_v->d[WMAX*DMAX]);
BN_mul(open_temp_result,open_a,open_b,ctx);
BN_div(open_v,open_n_inverse,open_temp_result,open_R,ctx);
BN_WORD_openssl_transform(open_v,bn_v,DMAX);
cout<<"open_v:"<<endl;
BN_WORD_print(bn_v);
BN_mul(open_temp_result,open_m,open_n,ctx);
BN_div(open_q,open_n_inverse,open_temp_result,open_R,ctx);
BN_add(open_temp_result,open_q,open_v);
BN_WORD_openssl_transform(open_temp_result,bn_v,DMAX);
cout<<"open_v:"<<endl;
BN_WORD_print(bn_v);




//end process
*/
BN_mod_mul(open_temp_result,open_a,open_b,open_n,ctx);
BN_mod_inverse(open_R_inverse,open_R,open_n,ctx);
BN_mod_mul(open_result,open_temp_result,open_R_inverse,open_n,ctx);
BN_mod_mul(open_mul_result,open_R_inverse,open_R,open_n,ctx);
BN_NUM_openssl_transform(open_a,bn_a,WMAX,DMAX);
BN_NUM_openssl_transform(open_b,bn_b,WMAX,DMAX);
BN_NUM_openssl_transform(open_n,bn_n,WMAX,DMAX);
BN_NUM_openssl_transform(open_result,bn_result,WMAX,DMAX);
BN_NUM_openssl_transform(open_mul_result,bn_mul_result,WMAX,DMAX);
cout<<"open_a"<<endl;
BN_NUM_print(bn_a);
cout<<"open_b"<<endl;
BN_NUM_print(bn_b);
cout<<"open_n"<<endl;
BN_NUM_print(bn_n);
cout<<"open_result"<<endl;
BN_NUM_print(bn_result);
BN_NUM_mod_mul(bn_a, bn_b,bn_n,WMAX, DMAX ,bn_word_result);
cout<<"bn_word_result"<<endl;
BN_NUM_print(bn_word_result);

}
