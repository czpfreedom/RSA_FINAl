#include "openssl/bn.h"
#include "openssl/bn_lcl.h"
#include "iostream"

using namespace std;


int BN_OPEN_PRINT(BIGNUM *a){
    cout<<"dmax:"<<(a->dmax)<<endl;
    cout<<"top:"<<(a->top)<<endl;
    for(int i=(a->top)-1;i>=0;i--){
	cout<<hex<<a->d[i]<<",";
    }
    cout<<endl;
}

int main(){
    BIGNUM *open_zero, *open_one;
    open_zero=BN_new();
    open_one=BN_new();
    BN_zero(open_zero);
    BN_one(open_one);
    unsigned int *m1;
    unsigned int *m2;
    m1=(unsigned int*)malloc(sizeof(unsigned int)*4);
    m2=(unsigned int*)malloc(sizeof(unsigned int)*4);
    m1[0]=4294967279;
    m1[1]=4294967231;
    m1[2]=4294967197;
    m1[3]=4294967189;
    m2[0]=4294966367;
    m2[1]=4294966337;
    m2[2]=4294966297;
    m2[3]=4294966243;
    BIGNUM *open_m1_0, *open_m1_1, *open_m1_2, *open_m1_3;
    BIGNUM *open_m2_0, *open_m2_1, *open_m2_2, *open_m2_3;
    open_m1_0=BN_new();
    open_m1_1=BN_new();
    open_m1_2=BN_new();
    open_m1_3=BN_new();
    open_m2_0=BN_new();
    open_m2_1=BN_new();
    open_m2_2=BN_new();
    open_m2_3=BN_new();
    BN_rand(open_m1_0,32,0,0);
        open_m1_0->d[0]=(BN_ULONG)m1[0];
    BN_rand(open_m1_1,32,0,0);
        open_m1_1->d[0]=(BN_ULONG)m1[1];
    BN_rand(open_m1_2,32,0,0);
        open_m1_2->d[0]=(BN_ULONG)m1[2];
    BN_rand(open_m1_3,32,0,0);
        open_m1_3->d[0]=(BN_ULONG)m1[3];
    BN_rand(open_m2_0,32,0,0);
        open_m2_0->d[0]=(BN_ULONG)m2[0];
    BN_rand(open_m2_1,32,0,0);
        open_m2_1->d[0]=(BN_ULONG)m2[1];
    BN_rand(open_m2_2,32,0,0);
        open_m2_2->d[0]=(BN_ULONG)m2[2];
    BN_rand(open_m2_3,32,0,0);    
        open_m2_3->d[0]=(BN_ULONG)m2[3];
    cout<<"m1_0"<<endl;
    BN_OPEN_PRINT(open_m1_0);   
    cout<<"m1_1"<<endl;
    BN_OPEN_PRINT(open_m1_1);
    cout<<"m1_2"<<endl;
    BN_OPEN_PRINT(open_m1_2);
    cout<<"m1_3"<<endl;
    BN_OPEN_PRINT(open_m1_3);
    cout<<"m2_0"<<endl;
    BN_OPEN_PRINT(open_m2_0);
    cout<<"m2_1"<<endl;
    BN_OPEN_PRINT(open_m2_1);
    cout<<"m2_2"<<endl;
    BN_OPEN_PRINT(open_m2_2);
    cout<<"m2_3"<<endl;
    BN_OPEN_PRINT(open_m2_3);
    BIGNUM *open_M1, *open_M2;
    BN_CTX *ctx;
    open_M1=BN_new();
    open_M2=BN_new();
    ctx=BN_CTX_new();
    BN_mul(open_M1,open_m1_0,open_m1_1,ctx);
    BN_mul(open_M1,open_M1,open_m1_2,ctx);
    BN_mul(open_M1,open_M1,open_m1_3,ctx);
    BN_mul(open_M2,open_m2_0,open_m2_1,ctx);
    BN_mul(open_M2,open_M2,open_m2_2,ctx);
    BN_mul(open_M2,open_M2,open_m2_3,ctx);
    cout<<"M1:"<<endl;
    BN_OPEN_PRINT(open_M1);
    cout<<"M2:"<<endl;
    BN_OPEN_PRINT(open_M2);
    BIGNUM *open_M1_0, *open_M1_1, *open_M1_2, *open_M1_3;
    BIGNUM *open_M2_0, *open_M2_1, *open_M2_2, *open_M2_3;
    BIGNUM *r;
    open_M1_0=BN_new();
    open_M1_1=BN_new();
    open_M1_2=BN_new();
    open_M1_3=BN_new();
    open_M2_0=BN_new();
    open_M2_1=BN_new();
    open_M2_2=BN_new();
    open_M2_3=BN_new();
    r=BN_new();
    BN_div(open_M1_0,r,open_M1,open_m1_0,ctx);
    BN_div(open_M1_1,r,open_M1,open_m1_1,ctx);
    BN_div(open_M1_2,r,open_M1,open_m1_2,ctx);
    BN_div(open_M1_3,r,open_M1,open_m1_3,ctx);
    BN_div(open_M2_0,r,open_M2,open_m2_0,ctx);
    BN_div(open_M2_1,r,open_M2,open_m2_1,ctx);
    BN_div(open_M2_2,r,open_M2,open_m2_2,ctx);
    BN_div(open_M2_3,r,open_M2,open_m2_3,ctx);
    cout<<"M1_0:"<<endl;
    BN_OPEN_PRINT(open_M1_0);
    cout<<"M1_1:"<<endl;
    BN_OPEN_PRINT(open_M1_1);
    cout<<"M1_2:"<<endl;
    BN_OPEN_PRINT(open_M1_2);
    cout<<"M1_3:"<<endl;
    BN_OPEN_PRINT(open_M1_3);
    cout<<"M2_0:"<<endl;
    BN_OPEN_PRINT(open_M2_0);
    cout<<"M2_1:"<<endl;
    BN_OPEN_PRINT(open_M2_1);
    cout<<"M2_2:"<<endl;
    BN_OPEN_PRINT(open_M2_2);
    cout<<"M2_3:"<<endl;
    BN_OPEN_PRINT(open_M2_3);
    BIGNUM *open_a, *open_b;
    BIGNUM *open_n;
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    BN_rand(open_a,128,0,0);
        open_a->d[0]=0xf312251da5cce920;
        open_a->d[1]=0x8d45d384f1558c9f;
    BN_rand(open_b,128,0,0);
        open_b->d[0]=0x0e5dc88969e86a13;
	open_b->d[1]=0xab836b0e064f26ec;
    BN_rand(open_n,128,0,0);
        open_n->d[0]=0x297ceeaaf0b75af9;
        open_n->d[1]=0xf1b9f5478ae28aa4;
    BIGNUM *open_a_M, *open_b_M, *x;
    open_a_M=BN_new();
    open_b_M=BN_new();
    x=BN_new();
    BN_mod_mul(open_a_M,open_a,open_M1,open_n,ctx);
    BN_mod_mul(open_b_M,open_b,open_M1,open_n,ctx);
    BN_mul(x,open_a_M,open_b_M,ctx);
    BIGNUM *x_1_0, *x_1_1, *x_1_2, *x_1_3;
    BIGNUM *x_2_0, *x_2_1, *x_2_2, *x_2_3;
    x_1_0=BN_new();
    x_1_1=BN_new();
    x_1_2=BN_new();
    x_1_3=BN_new();
    x_2_0=BN_new();
    x_2_1=BN_new();
    x_2_2=BN_new();
    x_2_3=BN_new();
    BN_mod(x_1_0,x,open_m1_0,ctx);
    BN_mod(x_1_1,x,open_m1_1,ctx);
    BN_mod(x_1_2,x,open_m1_2,ctx);
    BN_mod(x_1_3,x,open_m1_3,ctx);
    BN_mod(x_2_0,x,open_m2_0,ctx);
    BN_mod(x_2_1,x,open_m2_1,ctx);
    BN_mod(x_2_2,x,open_m2_2,ctx);
    BN_mod(x_2_3,x,open_m2_3,ctx);
    cout<<"x_1_0:"<<endl;
    BN_OPEN_PRINT(x_1_0);
    cout<<"x_1_1:"<<endl;
    BN_OPEN_PRINT(x_1_1);
    cout<<"x_1_2:"<<endl;
    BN_OPEN_PRINT(x_1_2);
    cout<<"x_1_3:"<<endl;
    BN_OPEN_PRINT(x_1_3);
    cout<<"x_2_0:"<<endl;
    BN_OPEN_PRINT(x_2_0);
    cout<<"x_2_1:"<<endl;
    BN_OPEN_PRINT(x_2_1);
    cout<<"x_2_2:"<<endl;
    BN_OPEN_PRINT(x_2_2);
    cout<<"x_2_3:"<<endl;
    BN_OPEN_PRINT(x_2_3);
}