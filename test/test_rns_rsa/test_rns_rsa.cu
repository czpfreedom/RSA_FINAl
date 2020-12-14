#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "rns_rsa.h"
#include <time.h> 


#define DMAX 64
#define UN_INT_MAX 0xffffffff

//#define rns_new_test
//#define test_RNS_WORD_BN_WORD_transform
//#define test_BN_WORD_RNS_WORD_mod
//#define test_RNS_WORD_mod_inverse
//#define test_prime_generation
//#define test_rsn_rsa_reduction
//#define test_rns_mul_mod
//#define test_rns_mul_mod_particular
//#define test_rns_mul_mod_particular2
//#define test_rsa_rns
//#define test_rsa_rns_particular
#define test_rsa_rns_particular2


using namespace std;

int main(){

#ifdef rns_new_test
    unsigned int *m1, *m2;
    BIGNUM *m, *M;
    BN_WORD *bn_M;
    BN_CTX *ctx;
    m1=(unsigned int*)malloc(sizeof(unsigned int)*32);
    m2=(unsigned int*)malloc(sizeof(unsigned int)*32);
    m=BN_new();
    M=BN_new();
    bn_M=BN_WORD_new(32);
    ctx=BN_CTX_new();
    m1[0]=0xffffffef;
    m1[1]=0xffffffbf;
    m1[2]=0xffffff9d;
    m1[3]=0xffffff95;
    m1[4]=0xffffff79;
    m1[5]=0xffffff67;
    m1[6]=0xffffff47;
    m1[7]=0xffffff2f;
    m1[8]=0xfffffef5;
    m1[9]=0xfffffed5;
    m1[10]=0xfffffec5;
    m1[11]=0xfffffe9f;
    m1[12]=0xfffffe8f;
    m1[13]=0xfffffe7d;
    m1[14]=0xfffffe5d;
    m1[15]=0xfffffe2d;
    m1[16]=0xfffffe1d;
    m1[17]=0xfffffdf1;
    m1[18]=0xfffffd8b;
    m1[19]=0xfffffd85;
    m1[20]=0xfffffd81;
    m1[21]=0xfffffd7b;
    m1[22]=0xfffffd6f;
    m1[23]=0xfffffd5b;
    m1[24]=0xfffffd3f;
    m1[25]=0xfffffd37;
    m1[26]=0xfffffd19;
    m1[27]=0xfffffccd;
    m1[28]=0xfffffcaf;
    m1[29]=0xfffffca9;
    m1[30]=0xfffffc9b;
    m1[31]=0xfffffc65;
    
    m2[0]=0xfffffc5f;
    m2[1]=0xfffffc41;
    m2[2]=0xfffffc19;
    m2[3]=0xfffffbe3;
    m2[4]=0xfffffbdd;
    m2[5]=0xfffffbd7;
    m2[6]=0xfffffbc9;
    m2[7]=0xfffffbab;
    m2[8]=0xfffffba1;
    m2[9]=0xfffffb93;
    m2[10]=0xfffffb89;
    m2[11]=0xfffffb71;
    m2[12]=0xfffffb69;
    m2[13]=0xfffffb53;
    m2[14]=0xfffffb47;
    m2[15]=0xfffffb39;
    m2[16]=0xfffffb1b;
    m2[17]=0xfffffaf7;
    m2[18]=0xfffffaf1;
    m2[19]=0xfffffad9;
    m2[20]=0xfffffad3;
    m2[21]=0xfffffacf;
    m2[22]=0xfffffabd;
    m2[23]=0xfffffab1;
    m2[24]=0xfffffa97;
    m2[25]=0xfffffa7f;
    m2[26]=0xfffffa57;
    m2[27]=0xfffffa51;
    m2[28]=0xfffffa4f;
    m2[29]=0xfffffa3d;
    m2[30]=0xfffffa21;
    m2[31]=0xfffffa07;

    BN_rand(m,sizeof(unsigned int)*8,0,0);
    BN_rand(M,sizeof(unsigned int)*8,0,0);
    M->d[0]=1;
    for(int i=0;i<32;i++){
        m->d[0]=(BN_ULONG)m1[i];
	BN_mul(M,M,m,ctx);
	cout<<i<<":"<<m->d[0]<<endl;
    }
    BN_WORD_openssl_transform(M,bn_M,32);
    BN_WORD_print(bn_M);


    BN_rand(m,sizeof(unsigned int)*8,0,0);
    BN_rand(M,sizeof(unsigned int)*8,0,0);
    M->d[0]=1;
    for(int i=0;i<32;i++){
	    m->d[0]=(BN_ULONG)m2[i];
	    BN_mul(M,M,m,ctx);
	    cout<<i<<":"<<m->d[0]<<endl;
    }
    BN_WORD_openssl_transform(M,bn_M,32);
    BN_WORD_print(bn_M);

#endif

#ifdef test_RNS_WORD_BN_WORD_transform
    RNS_WORD rns_a;
    BN_WORD *bn_a;
    RNS_N rns_example;
    bn_a=BN_WORD_new(DMAX);
    srand((unsigned)time(NULL)); 
    rns_a=rns_word_rand();
    rns_example.RNS_WORD_BN_WORD_transform(rns_a,DMAX*sizeof(RNS_WORD)*8,bn_a);
    cout<<hex<<"rns_a:"<<rns_a<<endl;
    cout<<"bn_a:"<<endl;
    BN_WORD_print(bn_a);
    BN_WORD_free(bn_a);
#endif

#ifdef test_BN_WORD_RNS_WORD_mod
    RNS_N rns_example;
    BIGNUM *open_a,*open_b,*open_result,*open_q;
    BN_WORD *bn_a, *bn_b, *bn_result;
    RNS_WORD rns_b, rns_result;
    BN_CTX *ctx;
    open_a=BN_new();
    open_b=BN_new();
    open_q=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    srand((unsigned)time(NULL));
    rns_b=rns_word_rand();
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_b,sizeof(BN_PART)*8,0,0);
    open_b->d[0]=rns_b;
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    BN_div(open_q,open_result,open_a,open_b,ctx);
    BN_WORD_openssl_transform(open_result,bn_result,DMAX);
    cout<<"bn_result:"<<endl;
    BN_WORD_print(bn_result);
    rns_example.BN_WORD_RNS_WORD_mod(bn_a,rns_b,rns_result);
    cout<<"rns_result:"<<hex<<rns_result<<endl;
#endif

#ifdef test_RNS_WORD_mod_inverse
    RNS_N rns_example;
    RNS_WORD a, n, a_inverse;
    srand((unsigned)time(NULL));
    /*
    a=rns_word_rand();
    while(a%2==0){
        srand((unsigned)time(NULL));
	a=rns_word_rand();
    }
    */
    a=0xfffa982f;
    n=4294967279;
    rns_example.RNS_WORD_mod_inverse(a,n,a_inverse);
    cout<<hex<<"a:"<<a<<endl;
    cout<<hex<<"a_inverse:"<<a_inverse<<endl;
    cout<<hex<<"n:"<<n<<endl;
    cout<<"result:"<<rns_word_mul_mod(a,a_inverse,n)<<endl;
#endif

#ifdef test_prime_generation
    RSA_N *rsa_n;
    rsa_n =RSA_N_new(DMAX);
    BN_WORD_openssl_prime_generation(rsa_n);
    cout<<"rsa_n:"<<endl;
    RSA_N_print(rsa_n);

#endif

#ifdef test_rsn_rsa_reduction

    cout<<"test_rns_rsa_reduction\n"<<endl;

    RSA_N *rsa_n;
    RNS_WORD *x_input,*x_output;
    BN_WORD *x_result;
    rsa_n=RSA_N_new(DMAX);
    x_input=(RNS_WORD*)malloc(sizeof(RNS_WORD)*DMAX);
    x_output=(RNS_WORD*)malloc(sizeof(RNS_WORD)*DMAX);
    x_result=BN_WORD_new(DMAX);
    BN_WORD_openssl_prime_generation(rsa_n);


    rsa_n->n->d[0]=0xf20e948d;
    rsa_n->n->d[1]=0x34d05d9;
    rsa_n->n->d[2]=0xa1307b61;
    rsa_n->n->d[3]=0x676bb39a;
    rsa_n->n->d[4]=0x90d2a582;
    rsa_n->n->d[5]=0x194f45a0;
    rsa_n->n->d[6]=0xee48b81;
    rsa_n->n->d[7]=0x7d958c24;
    rsa_n->n->d[8]=0xf40d6239;
    rsa_n->n->d[9]=0xdad78c12;
    rsa_n->n->d[10]=0x41ec4564;
    rsa_n->n->d[11]=0xa9541b1d;
    rsa_n->n->d[12]=0xa7657698;
    rsa_n->n->d[13]=0xff6e065e;
    rsa_n->n->d[14]=0x7a84a2c8;
    rsa_n->n->d[15]=0x8b2fc193;
    rsa_n->n->d[16]=0xc24a4474;
    rsa_n->n->d[17]=0xf5b5219;
    rsa_n->n->d[18]=0x7fe667c0;
    rsa_n->n->d[19]=0xc094a93;
    rsa_n->n->d[20]=0x4b3c7945;
    rsa_n->n->d[21]=0x5d00233a;
    rsa_n->n->d[22]=0xa250e884;
    rsa_n->n->d[23]=0x9b848db5;
    rsa_n->n->d[24]=0x554d5f7;
    rsa_n->n->d[25]=0x658ea14a;
    rsa_n->n->d[26]=0xde47324c;
    rsa_n->n->d[27]=0xcb25482a;
    rsa_n->n->d[28]=0xd2f47787;
    rsa_n->n->d[29]=0x92698ded;
    rsa_n->n->d[30]=0xd73ddbd8;
    rsa_n->n->d[31]=0xacf091a3;

    rsa_n->p->d[0]=0x1aa0b77d;
    rsa_n->p->d[1]=0xfdaafa7f;
    rsa_n->p->d[2]=0x3f5b85e8;
    rsa_n->p->d[3]=0xe07d761f;
    rsa_n->p->d[4]=0xf6e6418a;
    rsa_n->p->d[5]=0xdea8f359;
    rsa_n->p->d[6]=0xc9f39cf3;
    rsa_n->p->d[7]=0x58c385a8;
    rsa_n->p->d[8]=0x97807c4f;
    rsa_n->p->d[9]=0xa01a59be;
    rsa_n->p->d[10]=0x26d53732;
    rsa_n->p->d[11]=0xaa1821ff;
    rsa_n->p->d[12]=0xd42d33d4;
    rsa_n->p->d[13]=0x34303f76;
    rsa_n->p->d[14]=0x9443f8ab;
    rsa_n->p->d[15]=0xcdbcf49c;

    for(int i=16;i<32;i++){
        rsa_n->p->d[i]=0;
    }

    rsa_n->q->d[0]=0x6d897e51;
    rsa_n->q->d[1]=0x9afdcf09;
    rsa_n->q->d[2]=0xa8eb3330;
    rsa_n->q->d[3]=0xa935c62c;
    rsa_n->q->d[4]=0x915d2d5e;
    rsa_n->q->d[5]=0x8c639f7f;
    rsa_n->q->d[6]=0x394de028;
    rsa_n->q->d[7]=0x35fc9a83;
    rsa_n->q->d[8]=0x48c2b9aa;
    rsa_n->q->d[9]=0x48eff4ef;
    rsa_n->q->d[10]=0xfa10009b;
    rsa_n->q->d[11]=0x39abc440;
    rsa_n->q->d[12]=0x28266abf;
    rsa_n->q->d[13]=0x6e54aacf;
    rsa_n->q->d[14]=0x11ad6b28;
    rsa_n->q->d[15]=0xd7305f88;

    for(int i=16;i<32;i++){
            rsa_n->q->d[i]=0;
    }

    RNS_N rns_n(rsa_n);
    
    
    x_input[0]=0x8508f7c4;
    x_input[1]=0x50c28e8e;
    x_input[2]=0xfe6c100e;
    x_input[3]=0x54cff943;
    x_input[4]=0x56782a60;
    x_input[5]=0x57ab7ecc;
    x_input[6]=0xe302bb3c;
    x_input[7]=0xad0fe9b2;
    x_input[8]=0x18e4f36a;
    x_input[9]=0x117c380d;
    x_input[10]=0x4c5cf0c5;
    x_input[11]=0x23c07e9b;
    x_input[12]=0x8b24b46d;
    x_input[13]=0x98f662ff;
    x_input[14]=0xecf3db66;
    x_input[15]=0x7d4cc128;
    x_input[16]=0xd47755b3;
    x_input[17]=0xe28a478e;
    x_input[18]=0x44aebb99;
    x_input[19]=0x7907cb38;
    x_input[20]=0xcd6e30a6;
    x_input[21]=0x80959b6f;
    x_input[22]=0x6b24966c;
    x_input[23]=0x538f3c12;
    x_input[24]=0x68ea78c3;
    x_input[25]=0xfb844a69;
    x_input[26]=0x78576db9;
    x_input[27]=0xb9576b02;
    x_input[28]=0xcc9f2625;
    x_input[29]=0xc8bd5c4d;
    x_input[30]=0x3c142bc8;
    x_input[31]=0xd6aee2f7;

    rns_n.RSA_RNS_reduction1(x_input,x_result);
    cout<<"x_result_1:"<<endl;
    BN_WORD_print(x_result);

    x_input[0]=0xe4376ff2;
    x_input[1]=0x080fea74;
    x_input[2]=0x0425db07;
    x_input[3]=0xac023bb8;
    x_input[4]=0x316a7aa7;
    x_input[5]=0x301f43b9;
    x_input[6]=0x2d5b544c;
    x_input[7]=0x97467f4d;
    x_input[8]=0xceedf62e;
    x_input[9]=0x8f8fc8b0;
    x_input[10]=0xe2993dfc;
    x_input[11]=0x2180b4be;
    x_input[12]=0x30db32c6;
    x_input[13]=0x2e1ee502;
    x_input[14]=0x107213cc;
    x_input[15]=0xaf9208db;
    x_input[16]=0xac706903;
    x_input[17]=0x0f0a347e;
    x_input[18]=0x91f0520e;
    x_input[19]=0x0ff28a08;
    x_input[20]=0x5ab90156;
    x_input[21]=0xaa06f66b;
    x_input[22]=0xb56b5f36;
    x_input[23]=0xe613ca9c;
    x_input[24]=0x0b529a82;
    x_input[25]=0xa139f662;
    x_input[26]=0x73d441ce;
    x_input[27]=0x830bbcfe;
    x_input[28]=0x00422697;
    x_input[29]=0xea0610c7;
    x_input[30]=0x3e652e5d;
    x_input[31]=0x1fcd9366;

    rns_n.RSA_RNS_reduction2(x_input,x_result);
    cout<<"x_result_2:"<<endl;
    BN_WORD_print(x_result);

    
}
#endif

#ifdef test_rns_mul_mod
    
    cout<<"test_rns_mul_mod\n"<<endl;

    BIGNUM *open_a, *open_b, *open_n, *open_result;

    BN_CTX *ctx;

    BN_WORD *bn_a,*bn_b, *bn_n,*bn_result,*bn_word_result;

    RSA_N *rsa_n;

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
    rsa_n=RSA_N_new(DMAX);
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_WORD_openssl_prime_generation(rsa_n);

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    openssl_BN_WORD_transform(rsa_n->n,open_n,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);

    BN_mod_mul(open_result, open_a, open_b, open_n, ctx);

    BN_WORD_openssl_transform(open_result,bn_result,DMAX);


    cout<<"open_a"<<endl;
    BN_WORD_print(bn_a);
    cout<<"open_b"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_n"<<endl;
    BN_WORD_print(bn_n);
    cout<<"rsa_n"<<endl;
    RSA_N_print(rsa_n);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);

    RNS_N rns_n(rsa_n);
    rns_n.RNS_mul_mod(bn_a, bn_b, bn_word_result);

    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
}
#endif

#ifdef test_rns_mul_mod_particular

    cout<<"test_rns_mul_mod_particular\n"<<endl;

    BIGNUM *open_a, *open_b, *open_n, *open_result;

    BN_CTX *ctx;

    BN_WORD *bn_a,*bn_b, *bn_n,*bn_result,*bn_word_result;

    RSA_N *rsa_n;

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
    rsa_n=RSA_N_new(DMAX);
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    open_a->d[0]=0xa29a6438b975707e;
    open_a->d[1]=0xe8843d3be0397aa1;
    open_a->d[2]=0xf45876233bbd8acd;
    open_a->d[3]=0x95db72e79ca4f478;
    open_a->d[4]=0x948fca52f524d9d4;
    open_a->d[5]=0x0728676e2e36a1a8;
    open_a->d[6]=0x3d3fa533a764394c;
    open_a->d[7]=0xe47dbb5dd36133c5;
    open_a->d[8]=0x7442b9c667a19bfc;
    open_a->d[9]=0x1b3b081474762226;
    open_a->d[10]=0xb9e26798138bba55;
    open_a->d[11]=0x96d204147b9430c8;
    open_a->d[12]=0x77e70dd9b533b9b4;
    open_a->d[13]=0x9b4bb20d9a0d96b7;
    open_a->d[14]=0x83b111f3b687371f;
    open_a->d[15]=0x74ec4ff83e5d9ef5;
    
    BN_WORD_openssl_prime_generation(rsa_n);

    rsa_n->n->d[0]=0xf20e948d;
    rsa_n->n->d[1]=0x34d05d9;
    rsa_n->n->d[2]=0xa1307b61;
    rsa_n->n->d[3]=0x676bb39a;
    rsa_n->n->d[4]=0x90d2a582;
    rsa_n->n->d[5]=0x194f45a0;
    rsa_n->n->d[6]=0xee48b81;
    rsa_n->n->d[7]=0x7d958c24;
    rsa_n->n->d[8]=0xf40d6239;
    rsa_n->n->d[9]=0xdad78c12;
    rsa_n->n->d[10]=0x41ec4564;
    rsa_n->n->d[11]=0xa9541b1d;
    rsa_n->n->d[12]=0xa7657698;
    rsa_n->n->d[13]=0xff6e065e;
    rsa_n->n->d[14]=0x7a84a2c8;
    rsa_n->n->d[15]=0x8b2fc193;
    rsa_n->n->d[16]=0xc24a4474;
    rsa_n->n->d[17]=0xf5b5219;
    rsa_n->n->d[18]=0x7fe667c0;
    rsa_n->n->d[19]=0xc094a93;
    rsa_n->n->d[20]=0x4b3c7945;
    rsa_n->n->d[21]=0x5d00233a;
    rsa_n->n->d[22]=0xa250e884;
    rsa_n->n->d[23]=0x9b848db5;
    rsa_n->n->d[24]=0x554d5f7;
    rsa_n->n->d[25]=0x658ea14a;
    rsa_n->n->d[26]=0xde47324c;
    rsa_n->n->d[27]=0xcb25482a;
    rsa_n->n->d[28]=0xd2f47787;
    rsa_n->n->d[29]=0x92698ded;
    rsa_n->n->d[30]=0xd73ddbd8;
    rsa_n->n->d[31]=0xacf091a3;

    rsa_n->p->d[0]=0x1aa0b77d;
    rsa_n->p->d[1]=0xfdaafa7f;
    rsa_n->p->d[2]=0x3f5b85e8;
    rsa_n->p->d[3]=0xe07d761f;
    rsa_n->p->d[4]=0xf6e6418a;
    rsa_n->p->d[5]=0xdea8f359;
    rsa_n->p->d[6]=0xc9f39cf3;
    rsa_n->p->d[7]=0x58c385a8;
    rsa_n->p->d[8]=0x97807c4f;
    rsa_n->p->d[9]=0xa01a59be;
    rsa_n->p->d[10]=0x26d53732;
    rsa_n->p->d[11]=0xaa1821ff;
    rsa_n->p->d[12]=0xd42d33d4;
    rsa_n->p->d[13]=0x34303f76;
    rsa_n->p->d[14]=0x9443f8ab;
    rsa_n->p->d[15]=0xcdbcf49c;

    for(int i=16;i<32;i++){
        rsa_n->p->d[i]=0;
    }

    rsa_n->q->d[0]=0x6d897e51;
    rsa_n->q->d[1]=0x9afdcf09;
    rsa_n->q->d[2]=0xa8eb3330;
    rsa_n->q->d[3]=0xa935c62c;
    rsa_n->q->d[4]=0x915d2d5e;
    rsa_n->q->d[5]=0x8c639f7f;
    rsa_n->q->d[6]=0x394de028;
    rsa_n->q->d[7]=0x35fc9a83;
    rsa_n->q->d[8]=0x48c2b9aa;
    rsa_n->q->d[9]=0x48eff4ef;
    rsa_n->q->d[10]=0xfa10009b;
    rsa_n->q->d[11]=0x39abc440;
    rsa_n->q->d[12]=0x28266abf;
    rsa_n->q->d[13]=0x6e54aacf;
    rsa_n->q->d[14]=0x11ad6b28;
    rsa_n->q->d[15]=0xd7305f88;

    for(int i=16;i<32;i++){
            rsa_n->q->d[i]=0;
    }

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_b,bn_b,DMAX);
    openssl_BN_WORD_transform(rsa_n->n,open_n,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);

    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

    RNS_N rns_n(rsa_n);

    BIGNUM *open_M, *open_M_inverse,*open_a_M;
    open_M=BN_new();
    open_M_inverse=BN_new();
    open_a_M=BN_new();
    openssl_BN_WORD_transform(rns_n.m_M1,open_M,DMAX);

    BN_mod_inverse(open_M_inverse,open_M,open_n,ctx);
    BN_mod_mul(open_a_M,open_a,open_M_inverse,open_n,ctx);

    BN_WORD *bn_a_M;
    bn_a_M=BN_WORD_new(DMAX);

    BN_WORD_openssl_transform(open_a_M,bn_a_M,DMAX);
//    rns_n.RNS_mul_mod(bn_a_M,bn_a_M,bn_result);

    cout<<"bn_a_M"<<endl;
    BN_WORD_print(bn_a_M);

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
}
#endif


#ifdef test_rns_mul_mod_particular2

    cout<<"test_rns_mul_mod_particular2\n"<<endl;

    BIGNUM *open_a_M, *open_a, *open_n, *open_a_square;
    BIGNUM *open_M, *open_M_inverse,*open_a_square_M;
    BIGNUM *open_m1, *open_m2, *open_a_mod_m;

    BN_CTX *ctx;

    BN_WORD *bn_a, *bn_a_square;

    RSA_N *rsa_n;

    open_a_M=BN_new();
    open_a=BN_new();
    open_n=BN_new();
    open_a_square=BN_new();
    open_M=BN_new();
    open_M_inverse=BN_new();
    open_a_square_M=BN_new();
    open_m1=BN_new();
    open_m2=BN_new();
    open_a_mod_m=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_a_square=BN_WORD_new(DMAX);

    BN_rand(open_a_M,DMAX*(sizeof(BN_PART)*8),0,0);    
    
    open_a_M->d[0]=0xa29a6438b975707e;
    open_a_M->d[1]=0xe8843d3be0397aa1;
    open_a_M->d[2]=0xf45876233bbd8acd;
    open_a_M->d[3]=0x95db72e79ca4f478;
    open_a_M->d[4]=0x948fca52f524d9d4;
    open_a_M->d[5]=0x0728676e2e36a1a8;
    open_a_M->d[6]=0x3d3fa533a764394c;
    open_a_M->d[7]=0xe47dbb5dd36133c5;
    open_a_M->d[8]=0x7442b9c667a19bfc;
    open_a_M->d[9]=0x1b3b081474762226;
    open_a_M->d[10]=0xb9e26798138bba55;
    open_a_M->d[11]=0x96d204147b9430c8;
    open_a_M->d[12]=0x77e70dd9b533b9b4;
    open_a_M->d[13]=0x9b4bb20d9a0d96b7;
    open_a_M->d[14]=0x83b111f3b687371f;
    open_a_M->d[15]=0x74ec4ff83e5d9ef5;

    rsa_n=RSA_N_new(DMAX);

    BN_WORD_openssl_prime_generation(rsa_n);

    rsa_n->n->d[0]=0xf20e948d;
    rsa_n->n->d[1]=0x34d05d9;
    rsa_n->n->d[2]=0xa1307b61;
    rsa_n->n->d[3]=0x676bb39a;
    rsa_n->n->d[4]=0x90d2a582;
    rsa_n->n->d[5]=0x194f45a0;
    rsa_n->n->d[6]=0xee48b81;
    rsa_n->n->d[7]=0x7d958c24;
    rsa_n->n->d[8]=0xf40d6239;
    rsa_n->n->d[9]=0xdad78c12;
    rsa_n->n->d[10]=0x41ec4564;
    rsa_n->n->d[11]=0xa9541b1d;
    rsa_n->n->d[12]=0xa7657698;
    rsa_n->n->d[13]=0xff6e065e;
    rsa_n->n->d[14]=0x7a84a2c8;
    rsa_n->n->d[15]=0x8b2fc193;
    rsa_n->n->d[16]=0xc24a4474;
    rsa_n->n->d[17]=0xf5b5219;
    rsa_n->n->d[18]=0x7fe667c0;
    rsa_n->n->d[19]=0xc094a93;
    rsa_n->n->d[20]=0x4b3c7945;
    rsa_n->n->d[21]=0x5d00233a;
    rsa_n->n->d[22]=0xa250e884;
    rsa_n->n->d[23]=0x9b848db5;
    rsa_n->n->d[24]=0x554d5f7;
    rsa_n->n->d[25]=0x658ea14a;
    rsa_n->n->d[26]=0xde47324c;
    rsa_n->n->d[27]=0xcb25482a;
    rsa_n->n->d[28]=0xd2f47787;
    rsa_n->n->d[29]=0x92698ded;
    rsa_n->n->d[30]=0xd73ddbd8;
    rsa_n->n->d[31]=0xacf091a3;

    rsa_n->p->d[0]=0x1aa0b77d;
    rsa_n->p->d[1]=0xfdaafa7f;
    rsa_n->p->d[2]=0x3f5b85e8;
    rsa_n->p->d[3]=0xe07d761f;
    rsa_n->p->d[4]=0xf6e6418a;
    rsa_n->p->d[5]=0xdea8f359;
    rsa_n->p->d[6]=0xc9f39cf3;
    rsa_n->p->d[7]=0x58c385a8;
    rsa_n->p->d[8]=0x97807c4f;
    rsa_n->p->d[9]=0xa01a59be;
    rsa_n->p->d[10]=0x26d53732;
    rsa_n->p->d[11]=0xaa1821ff;
    rsa_n->p->d[12]=0xd42d33d4;
    rsa_n->p->d[13]=0x34303f76;
    rsa_n->p->d[14]=0x9443f8ab;
    rsa_n->p->d[15]=0xcdbcf49c;

    for(int i=16;i<32;i++){
        rsa_n->p->d[i]=0;
    }

    rsa_n->q->d[0]=0x6d897e51;
    rsa_n->q->d[1]=0x9afdcf09;
    rsa_n->q->d[2]=0xa8eb3330;
    rsa_n->q->d[3]=0xa935c62c;
    rsa_n->q->d[4]=0x915d2d5e;
    rsa_n->q->d[5]=0x8c639f7f;
    rsa_n->q->d[6]=0x394de028;
    rsa_n->q->d[7]=0x35fc9a83;
    rsa_n->q->d[8]=0x48c2b9aa;
    rsa_n->q->d[9]=0x48eff4ef;
    rsa_n->q->d[10]=0xfa10009b;
    rsa_n->q->d[11]=0x39abc440;
    rsa_n->q->d[12]=0x28266abf;
    rsa_n->q->d[13]=0x6e54aacf;
    rsa_n->q->d[14]=0x11ad6b28;
    rsa_n->q->d[15]=0xd7305f88;

    for(int i=16;i<32;i++){
            rsa_n->q->d[i]=0;
    }

    openssl_BN_WORD_transform(rsa_n->n,open_n,DMAX);

    RNS_N rns_n(rsa_n);

    openssl_BN_WORD_transform(rns_n.m_M1,open_M,DMAX);

    BN_mod_inverse(open_M_inverse,open_M,open_n,ctx);
    BN_mod_mul(open_a,open_a_M,open_M_inverse,open_n,ctx);
    BN_mod_mul(open_a_square,open_a,open_a,open_n,ctx);
    BN_mod_mul(open_a_square_M,open_a_square,open_M,open_n,ctx);

    BN_rand(open_m1,32,0,0);
    BN_rand(open_m2,32,0,0);

    cout<<"open_a_square:"<<endl;
    BN_OPEN_PRINT(open_a_square);

    for(int i=0;i<DMAX;i++){
        open_m1->d[0]=rns_n.m_m1[i];
	BN_mod(open_a_mod_m,open_a_square_M,open_m1,ctx);
	cout<<"open_a_square_M_mod_m1["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }
    
    cout<<endl<<endl;

    for(int i=0;i<DMAX;i++){        
	open_m2->d[0]=rns_n.m_m2[i];
	BN_mod(open_a_mod_m,open_a_square_M,open_m2,ctx);
	cout<<"open_a_square_M_mod_m2["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);

    rns_n.RNS_mul_mod(bn_a,bn_a,bn_a_square);

    cout<<"bn_a_square:"<<endl;
    BN_WORD_print(bn_a_square);
}
#endif


#ifdef test_rsa_rns
    
    cout<<"test_rsa_rns\n"<<endl;

    BIGNUM *open_a, *open_e, *open_n, *open_result;

    BN_CTX *ctx;

    BN_WORD *bn_a,*bn_e, *bn_n,*bn_result,*bn_word_result;

    RSA_N *rsa_n;

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
    rsa_n=RSA_N_new(DMAX);
    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_rand(open_e,DMAX*(sizeof(BN_PART)*8),0,0);
    BN_WORD_openssl_prime_generation(rsa_n);

    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_e,bn_e,DMAX);
    openssl_BN_WORD_transform(rsa_n->n,open_n,DMAX);
    BN_WORD_openssl_transform(open_n,bn_n,DMAX);

    BN_mod_exp(open_result, open_a, open_e, open_n, ctx);

    BN_WORD_openssl_transform(open_result,bn_result,DMAX);

    RNS_N rns_n(rsa_n);

    cout<<"open_a"<<endl;
    BN_WORD_print(bn_a);
    cout<<"open_b"<<endl;
    BN_WORD_print(bn_e);
    cout<<"open_n"<<endl;
    BN_WORD_print(bn_n);
    cout<<"rsa_n"<<endl;
    RSA_N_print(rsa_n);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);

    rns_n.RSA (bn_a, bn_e, bn_word_result);

    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
}

#endif

#ifdef test_rsa_rns_particular

    cout<<"test_rsa_rns_particular\n"<<endl;

    BIGNUM *open_a, *open_e, *open_n, *open_a_exp_e;
    BIGNUM *open_a_M, *open_a_exp_2, *open_a_exp_2_M, *open_a_exp_4, *open_a_exp_4_M, *open_a_exp_8, *open_a_exp_8_M;
    BIGNUM *open_a_exp_2_MM, *open_a_exp_4_MM, *open_a_exp_8_MM;
    BIGNUM *open_M, *open_M_inverse, *open_m1, *open_m2, *open_a_mod_m;
    BN_CTX *ctx;

    BN_WORD *bn_a,*bn_e, *bn_a_exp_e;
    BN_WORD *bn_a_exp_2, *bn_a_exp_4, *bn_a_exp_8;

    RSA_N *rsa_n;

    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_a_exp_e=BN_new();
    open_a_M=BN_new();
    open_a_exp_2=BN_new();
    open_a_exp_2_M=BN_new();
    open_a_exp_4=BN_new();
    open_a_exp_4_M=BN_new();
    open_a_exp_8=BN_new();
    open_a_exp_8_M=BN_new();
    open_a_exp_2_MM=BN_new();
    open_a_exp_4_MM=BN_new();
    open_a_exp_8_MM=BN_new();
    open_M=BN_new();
    open_M_inverse=BN_new();
    open_m1=BN_new();
    open_m2=BN_new();
    open_a_mod_m=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_a_exp_e=BN_WORD_new(DMAX);
    bn_a_exp_2=BN_WORD_new(DMAX);
    bn_a_exp_4=BN_WORD_new(DMAX);
    bn_a_exp_8=BN_WORD_new(DMAX);


    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    open_a->d[0]=0xd00005024dafc563;
    open_a->d[1]=0x00a688eda00ed5d5;
    open_a->d[2]=0xf9907955ad3b2f13;
    open_a->d[3]=0x590212b125d8f9a4;
    open_a->d[4]=0x5bb069c88f50b155;
    open_a->d[5]=0xeae30a70c31f0d70;
    open_a->d[6]=0xcd170a1c86d190f6;
    open_a->d[7]=0x18f68f7e62cfefcd;
    open_a->d[8]=0xbdb7b1ede304ecf0;
    open_a->d[9]=0xc0662eb26870f7ff;
    open_a->d[10]=0xb1f4599fa5a58964;
    open_a->d[11]=0x8047b1badd4e8c9b;
    open_a->d[12]=0x8ac84fd54e3c0ff;
    open_a->d[13]=0xdb97d33d6d003f41;
    open_a->d[14]=0xcd6c32b3f6d0c166;
    open_a->d[15]=0xf351f08bde9a5a78;

    BN_rand(open_e,DMAX*(sizeof(BN_PART)*8),0,0);
    open_e->d[0]=0x00000000000000ff;
    open_e->d[1]=0x3d0c3c085732e3c4;
    open_e->d[2]=0x5bb4f748d3ab8cea;
    open_e->d[3]=0xe2b71092d38edde3;
    open_e->d[4]=0xa2a901c136fd740d;
    open_e->d[5]=0x89bebaf980e7dee8;
    open_e->d[6]=0xf5b2f877b65054e7;
    open_e->d[7]=0xa9048aa9ca113dec;
    open_e->d[8]=0x1f4ff2c4682ddacb;
    open_e->d[9]=0x6e533f43c2530bb9;
    open_e->d[10]=0xf41e4c5db68cdf3a;
    open_e->d[11]=0xb3cafdab97690fec;
    open_e->d[12]=0x288352fd76b7d527;
    open_e->d[13]=0xd52bdb9c02f83f7c;
    open_e->d[14]=0x713940c5353ad959;
    open_e->d[15]=0x865edf16ef04e50c;

    rsa_n=RSA_N_new(DMAX);
    
    BN_WORD_openssl_prime_generation(rsa_n);

    rsa_n->n->d[0]=0xf20e948d;
    rsa_n->n->d[1]=0x34d05d9;    
    rsa_n->n->d[2]=0xa1307b61;
    rsa_n->n->d[3]=0x676bb39a;
    rsa_n->n->d[4]=0x90d2a582;
    rsa_n->n->d[5]=0x194f45a0;
    rsa_n->n->d[6]=0xee48b81;
    rsa_n->n->d[7]=0x7d958c24;
    rsa_n->n->d[8]=0xf40d6239;
    rsa_n->n->d[9]=0xdad78c12;
    rsa_n->n->d[10]=0x41ec4564;
    rsa_n->n->d[11]=0xa9541b1d;
    rsa_n->n->d[12]=0xa7657698;
    rsa_n->n->d[13]=0xff6e065e;
    rsa_n->n->d[14]=0x7a84a2c8;
    rsa_n->n->d[15]=0x8b2fc193;
    rsa_n->n->d[16]=0xc24a4474;
    rsa_n->n->d[17]=0xf5b5219;
    rsa_n->n->d[18]=0x7fe667c0;
    rsa_n->n->d[19]=0xc094a93;
    rsa_n->n->d[20]=0x4b3c7945;
    rsa_n->n->d[21]=0x5d00233a;
    rsa_n->n->d[22]=0xa250e884;
    rsa_n->n->d[23]=0x9b848db5;
    rsa_n->n->d[24]=0x554d5f7;
    rsa_n->n->d[25]=0x658ea14a;
    rsa_n->n->d[26]=0xde47324c;
    rsa_n->n->d[27]=0xcb25482a;
    rsa_n->n->d[28]=0xd2f47787;
    rsa_n->n->d[29]=0x92698ded;
    rsa_n->n->d[30]=0xd73ddbd8;
    rsa_n->n->d[31]=0xacf091a3;

    rsa_n->p->d[0]=0x1aa0b77d;
    rsa_n->p->d[1]=0xfdaafa7f;
    rsa_n->p->d[2]=0x3f5b85e8;
    rsa_n->p->d[3]=0xe07d761f;
    rsa_n->p->d[4]=0xf6e6418a;
    rsa_n->p->d[5]=0xdea8f359;
    rsa_n->p->d[6]=0xc9f39cf3;
    rsa_n->p->d[7]=0x58c385a8;
    rsa_n->p->d[8]=0x97807c4f;
    rsa_n->p->d[9]=0xa01a59be;
    rsa_n->p->d[10]=0x26d53732;
    rsa_n->p->d[11]=0xaa1821ff;
    rsa_n->p->d[12]=0xd42d33d4;
    rsa_n->p->d[13]=0x34303f76;
    rsa_n->p->d[14]=0x9443f8ab;
    rsa_n->p->d[15]=0xcdbcf49c;

    for(int i=16;i<32;i++){
        rsa_n->p->d[i]=0;
    }

    rsa_n->q->d[0]=0x6d897e51;
    rsa_n->q->d[1]=0x9afdcf09;
    rsa_n->q->d[2]=0xa8eb3330;
    rsa_n->q->d[3]=0xa935c62c;
    rsa_n->q->d[4]=0x915d2d5e;
    rsa_n->q->d[5]=0x8c639f7f;
    rsa_n->q->d[6]=0x394de028;
    rsa_n->q->d[7]=0x35fc9a83;
    rsa_n->q->d[8]=0x48c2b9aa;
    rsa_n->q->d[9]=0x48eff4ef;
    rsa_n->q->d[10]=0xfa10009b;
    rsa_n->q->d[11]=0x39abc440;
    rsa_n->q->d[12]=0x28266abf;
    rsa_n->q->d[13]=0x6e54aacf;
    rsa_n->q->d[14]=0x11ad6b28;
    rsa_n->q->d[15]=0xd7305f88;
    
    for(int i=16;i<32;i++){
	    rsa_n->q->d[i]=0;
    }
    
    RNS_N rns_n(rsa_n);
    
    BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    BN_WORD_openssl_transform(open_e,bn_e,DMAX);
    openssl_BN_WORD_transform(rsa_n->n,open_n,DMAX);

    openssl_BN_WORD_transform(rns_n.m_M1,open_M,DMAX);

    BN_rand(open_m1,32,0,0);
    BN_rand(open_m2,32,0,0);

    BN_mod_mul(open_a_M,open_a,open_M,open_n,ctx);
    cout<<"open_a_M:"<<endl;
    BN_OPEN_PRINT(open_a_M);

    cout<<endl<<endl;
/*
    for(int i=0;i<DMAX;i++){
        open_m1->d[0]=rns_n.m_m1[i];
	BN_mod(open_a_mod_m,open_a_M,open_m1,ctx);
	cout<<"open_a_M_mod_m1["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    for(int i=0;i<DMAX;i++){
	open_m1->d[0]=rns_n.m_m1[i];
	BN_mod(open_a_mod_m,open_a_M,open_m2,ctx);
	cout<<"open_a_M_mod_m2["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    cout<<endl<<endl<<endl;
*/
// i=0
    cout<<"i=0"<<endl<<endl;
    BN_mod_mul(open_a_exp_2,open_a,open_a,open_n,ctx);
    BN_mod_mul(open_a_exp_2_M,open_a_exp_2,open_M,open_n,ctx);
    BN_mul(open_a_exp_2_MM,open_a_M,open_a_M,ctx);
/*
    for(int i=0;i<DMAX;i++){
        open_m1->d[0]=rns_n.m_m1[i];
	BN_mod(open_a_mod_m,open_a_exp_2_M,open_m1,ctx);
	cout<<"open_a_exp_2_M_mod_m1["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    for(int i=0;i<DMAX;i++){
        open_m2->d[0]=rns_n.m_m2[i];
        BN_mod(open_a_mod_m,open_a_exp_2_M,open_m2,ctx);
        cout<<"open_a_exp_2_M_mod_m2["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    for(int i=0;i<DMAX;i++){
        open_m1->d[0]=rns_n.m_m1[i];
	BN_mod(open_a_mod_m,open_a_exp_2_MM,open_m1,ctx);
	cout<<"open_a_exp_2_MM_mod_m1["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    for(int i=0;i<DMAX;i++){
        open_m2->d[0]=rns_n.m_m2[i];
        BN_mod(open_a_mod_m,open_a_exp_2_MM,open_m2,ctx);
        cout<<"open_a_exp_2_MM_mod_m2["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }    
*/
    rns_n.RNS_mul_mod(bn_a,bn_a,bn_a_exp_2);

    cout<<"open_a_exp_2:"<<endl;
    BN_OPEN_PRINT(open_a_exp_2);

    cout<<"bn_a_exp_2:"<<endl;
    BN_WORD_print(bn_a_exp_2);
    cout<<endl<<endl<<endl;
//i=1
    cout<<"i=1"<<endl<<endl;

    BN_mod_mul(open_a_exp_4,open_a_exp_2,open_a_exp_2,open_n,ctx);
    BN_mod_mul(open_a_exp_4_M,open_a_exp_4,open_M,open_n,ctx);
/*
    for(int i=0;i<DMAX;i++){
        open_m1->d[0]=rns_n.m_m1[i];
        BN_mod(open_a_mod_m,open_a_exp_4_M,open_m1,ctx);
        cout<<"open_a_exp_4_M_mod_m1["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    for(int i=0;i<DMAX;i++){
        open_m2->d[0]=rns_n.m_m2[i];
        BN_mod(open_a_mod_m,open_a_exp_4_M,open_m2,ctx);
        cout<<"open_a_exp_4_M_mod_m2["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }
*/
    rns_n.RNS_mul_mod(bn_a_exp_2,bn_a_exp_2,bn_a_exp_4);

    cout<<endl<<endl<<endl;
//i=2

    cout<<"i=2"<<endl<<endl;

    cout<<"open_a_exp_4:"<<endl;
    BN_OPEN_PRINT(open_a_exp_4);
    cout<<"bn_a_exp_4:"<<endl;
    BN_WORD_print(bn_a_exp_4);

    BN_mod_mul(open_a_exp_8,open_a_exp_4,open_a_exp_4,open_n,ctx);
    BN_mod_mul(open_a_exp_8_M,open_a_exp_8,open_M,open_n,ctx);

    for(int i=0;i<DMAX;i++){
        open_m1->d[0]=rns_n.m_m1[i];
        BN_mod(open_a_mod_m,open_a_exp_8_M,open_m1,ctx);
        cout<<"open_a_exp_8_M_mod_m1["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    for(int i=0;i<DMAX;i++){
        open_m2->d[0]=rns_n.m_m2[i];
        BN_mod(open_a_mod_m,open_a_exp_8_M,open_m2,ctx);
        cout<<"open_a_exp_8_M_mod_m2["<<i<<"]:"<<open_a_mod_m->d[0]<<endl;
    }

    cout<<endl<<endl<<endl;

    rns_n.RNS_mul_mod(bn_a_exp_4,bn_a_exp_4,bn_a_exp_8);
    
    cout<<"open_a_exp_8"<<endl;
    BN_OPEN_PRINT(open_a_exp_8);

    cout<<"open_a_exp_8_M"<<endl;
    BN_OPEN_PRINT(open_a_exp_8_M);

    BN_mod_inverse(open_M_inverse, open_M, open_n, ctx);
    BN_mod_mul(open_a_exp_8,open_a_exp_8_M,open_M_inverse,open_n,ctx);
    cout<<"open_a_exp_8_2"<<endl;
    BN_OPEN_PRINT(open_a_exp_8);

    cout<<"bn_a_exp_8"<<endl;
    BN_WORD_print(bn_a_exp_8);

    cout<<"open_a"<<endl;
    BN_WORD_print(bn_a);
    cout<<"open_e"<<endl;
    BN_WORD_print(bn_e);
    cout<<"rsa_n"<<endl;
    RSA_N_print(rsa_n);
    
    BN_mod_exp(open_a_exp_e, open_a, open_e, open_n, ctx);

    rns_n.RSA (bn_a, bn_e, bn_a_exp_e);

    cout<<"open_a_exp_e:"<<endl;
    BN_OPEN_PRINT(open_a_exp_e);

    cout<<"bn_a_exp_e"<<endl;
    BN_WORD_print(bn_a_exp_e);
}

#endif

#ifdef test_rsa_rns_particular2

    BIGNUM *open_a, *open_e, *open_n, *open_M, *open_a_M, *open_a_exp_2, *open_a_exp_2_M, *open_a_exp_4, *open_a_exp_4_M, 
           *open_a_exp_8, *open_a_exp_8_M, *open_a_exp_e;
    BN_WORD *bn_a, *bn_e, *bn_a_exp_2, *bn_a_exp_4, *bn_a_exp_8, *bn_a_exp_e;
    BN_CTX *ctx;
    RSA_N *rsa_n;

    open_a=BN_new();
    open_e=BN_new();
    open_n=BN_new();
    open_M=BN_new();
    open_a_M=BN_new();
    open_a_exp_2=BN_new();
    open_a_exp_2_M=BN_new();
    open_a_exp_4=BN_new();
    open_a_exp_4_M=BN_new();    
    open_a_exp_8=BN_new();
    open_a_exp_8_M=BN_new();
    open_a_exp_e=BN_new();

    bn_a=BN_WORD_new(DMAX);
    bn_e=BN_WORD_new(DMAX);
    bn_a_exp_2=BN_WORD_new(DMAX);
    bn_a_exp_4=BN_WORD_new(DMAX);
    bn_a_exp_8=BN_WORD_new(DMAX);
    bn_a_exp_e=BN_WORD_new(DMAX);

    ctx=BN_CTX_new();

    rsa_n=RSA_N_new(DMAX);

    BN_rand(open_a,DMAX*(sizeof(BN_PART)*8),0,0);
    
    open_a->d[0]=0xa8b674776744fc3d;
    open_a->d[1]=0xd0ed3d2fb730a591;
    open_a->d[2]=0x69002ccec19f20fa;
    open_a->d[3]=0x82461f8e045b91df;
    open_a->d[4]=0xa948e221d4faf813;
    open_a->d[5]=0x378e64bb3ff07e07;
    open_a->d[6]=0x79e4afd5d59f3bd1;
    open_a->d[7]=0x65a6ea899a1f70f2;
    open_a->d[8]=0x762e6cf56dd4b491;
    open_a->d[9]=0x048b5bb076bcae4d;
    open_a->d[10]=0x09bb3c6f9daab912;
    open_a->d[11]=0xa520ec22fd818856;
    open_a->d[12]=0xf9003b3cf1f37212;
    open_a->d[13]=0xc7128554903aa833;
    open_a->d[14]=0x423226f58107457d;
    open_a->d[15]=0x5c4db164553a343a;
    open_a->d[16]=0xef69b0f54f80cf28;
    open_a->d[17]=0x526961e6a427c3dd;
    open_a->d[18]=0xdb2d150756b142c4;
    open_a->d[19]=0x835551aec77861d2;
    open_a->d[20]=0x83fbd12df62a931a;
    open_a->d[21]=0x5760f1f64a43ffcc;
    open_a->d[22]=0xb9f6caa77cc6d640;
    open_a->d[23]=0x5c12a6fae7abbe01;
    open_a->d[24]=0xb7099a8895d1233c;
    open_a->d[25]=0xb861390481ec336b;
    open_a->d[26]=0xf70cb2c25636a6e7;
    open_a->d[27]=0xc8f54c785eb82e8a;
    open_a->d[28]=0x0ff2658ff2e77098;
    open_a->d[29]=0x99b6ba026d9194c5;
    open_a->d[30]=0xdc3a0a4ca8327068;
    open_a->d[31]=0x9121dcef98a0a8de;
    
    BN_rand(open_e,DMAX*(sizeof(BN_PART)*8),0,0);
/*    open_e->d[0]=0x587e0fb0a74c7de3;
    open_e->d[1]=0xf1489cbb56806481;
    open_e->d[2]=0x03b417ea7ebd1490;
    open_e->d[3]=0xe22b80481a429368;
    open_e->d[4]=0x7f1c9e243ace8b79;
    open_e->d[5]=0x91568582600d06a7;
    open_e->d[6]=0xaef87afbc947d055;
    open_e->d[7]=0xe5873bb13ae12828;
    open_e->d[8]=0x87ff6a7a1e083f70;
    open_e->d[9]=0xde086f4858268dff;
    open_e->d[10]=0x67b92a4272e50042;
    open_e->d[11]=0xa9dd1393125c3462;
    open_e->d[12]=0x04236f4d73f83a94;
    open_e->d[13]=0x7cf6bce4aaaf71ed;
    open_e->d[14]=0x8be824c68d667317;
    open_e->d[15]=0x1e3f61e96697943d;
    open_e->d[16]=0x60413381386a5ba4;
    open_e->d[17]=0x17edcd986415b7a7;
    open_e->d[18]=0xc150c165461f2e12;
    open_e->d[19]=0xc9685d900ae3d3f8;
    open_e->d[20]=0x6b5f776e8048fd5b;
    open_e->d[21]=0x21ac63505f358336;
    open_e->d[22]=0x92ee2d4615830ead;
    open_e->d[23]=0x87bdd1b52f1364bf;
    open_e->d[24]=0xb92560f3bc1d8197;
    open_e->d[25]=0x6a7adeb6cbe1604b;
    open_e->d[26]=0x7413f5102a34ba9a;
    open_e->d[27]=0x67c673c36a890a36;
    open_e->d[28]=0xabd50332c0a602d7;
    open_e->d[29]=0xd61a1da7f4614951;
    open_e->d[30]=0xda680e4d1bed68d1;
    open_e->d[31]=0x90ea59f41f849599;
*/

    open_e->d[0]=6;
    for(int i=1;i<32;i++){
        open_e->d[i]=0;
    }

    BN_WORD_openssl_prime_generation(rsa_n);

    rsa_n->p->d[0]=0xe539827b;
    rsa_n->p->d[1]=0xd3a7b7d6;
    rsa_n->p->d[2]=0x08f04d24;
    rsa_n->p->d[3]=0x87a0cd3c;
    rsa_n->p->d[4]=0x83013513;
    rsa_n->p->d[5]=0xf5b10a86;
    rsa_n->p->d[6]=0xfd3ac6a7;
    rsa_n->p->d[7]=0xdfb427ae;
    rsa_n->p->d[8]=0x2b33a4ef;
    rsa_n->p->d[9]=0x51368acb;
    rsa_n->p->d[10]=0x633e5475;
    rsa_n->p->d[11]=0xa2eb769a;
    rsa_n->p->d[12]=0xde69a075;
    rsa_n->p->d[13]=0xbc411d24;
    rsa_n->p->d[14]=0x08b8d54a;
    rsa_n->p->d[15]=0x8dd4ab79;
    rsa_n->p->d[16]=0x0cbb3565;
    rsa_n->p->d[17]=0x2788f562;
    rsa_n->p->d[18]=0x52e0e100;
    rsa_n->p->d[19]=0x4d43bde7;
    rsa_n->p->d[20]=0x2c8650be;
    rsa_n->p->d[21]=0x4d1ffd4c;
    rsa_n->p->d[22]=0x7bada706;
    rsa_n->p->d[23]=0x1f225b32;
    rsa_n->p->d[24]=0xf2b636c1;
    rsa_n->p->d[25]=0xe4fd7d2f;
    rsa_n->p->d[26]=0xf55d27a5;
    rsa_n->p->d[27]=0x0aac1237;
    rsa_n->p->d[28]=0xc513661a;
    rsa_n->p->d[29]=0x57b4fbb6;
    rsa_n->p->d[30]=0x68909eac;
    rsa_n->p->d[31]=0x33c6eb4e;

    for(int i=32;i<64;i++){
        rsa_n->p->d[i]=0;
    }

    rsa_n->q->d[0]=0xd2238c41;
    rsa_n->q->d[1]=0xd27b4aaf;
    rsa_n->q->d[2]=0xd35d09a7;
    rsa_n->q->d[3]=0x15894fea;
    rsa_n->q->d[4]=0xcfdb293a;
    rsa_n->q->d[5]=0x2b9b7820;
    rsa_n->q->d[6]=0x401d9713;
    rsa_n->q->d[7]=0x62a49fa9;
    rsa_n->q->d[8]=0x9833bed8;
    rsa_n->q->d[9]=0x67a58d77;
    rsa_n->q->d[10]=0x1a4978e4;
    rsa_n->q->d[11]=0x17816e1f;
    rsa_n->q->d[12]=0x8d92afb2;
    rsa_n->q->d[13]=0x67b971df;
    rsa_n->q->d[14]=0x633b2d91;
    rsa_n->q->d[15]=0xd4f9ac52;
    rsa_n->q->d[16]=0x9e2287d0;
    rsa_n->q->d[17]=0x7ec8e462;
    rsa_n->q->d[18]=0xc9672329;
    rsa_n->q->d[19]=0x9847f502;
    rsa_n->q->d[20]=0xa4ef3d62;
    rsa_n->q->d[21]=0xe2eee1a8;
    rsa_n->q->d[22]=0x30c77380;
    rsa_n->q->d[23]=0x1c855ff8;
    rsa_n->q->d[24]=0x60d7694a;
    rsa_n->q->d[25]=0xa6cddc43;
    rsa_n->q->d[26]=0x47a05bc6;
    rsa_n->q->d[27]=0xc49e083d;
    rsa_n->q->d[28]=0x94c43b0e;
    rsa_n->q->d[29]=0x56059223;
    rsa_n->q->d[30]=0xf5afb6ec;
    rsa_n->q->d[31]=0x3f67c38f;
    for(int i=32;i<64;i++){
        rsa_n->p->d[i]=0;
    }


    rsa_n->n->d[0]=0x63c6653b;
    rsa_n->n->d[1]=0xc9aa76e6;
    rsa_n->n->d[2]=0x8db9c9e6;
    rsa_n->n->d[3]=0x9805521f;
    rsa_n->n->d[4]=0x5dfa6d43;
    rsa_n->n->d[5]=0x53a3f952;
    rsa_n->n->d[6]=0x5e4f4ffa;
    rsa_n->n->d[7]=0x15fa4d4b;
    rsa_n->n->d[8]=0x079c3c2c;
    rsa_n->n->d[9]=0x4159e90e;
    rsa_n->n->d[10]=0x0bebf432;
    rsa_n->n->d[11]=0xafef8874;
    rsa_n->n->d[12]=0xd66989fb;
    rsa_n->n->d[13]=0x322adfdc;
    rsa_n->n->d[14]=0x050ae093;
    rsa_n->n->d[15]=0xa61878cf;
    rsa_n->n->d[16]=0xf57a3602;
    rsa_n->n->d[17]=0x0696adc4;
    rsa_n->n->d[18]=0x97164107;
    rsa_n->n->d[19]=0xafbff01b;
    rsa_n->n->d[20]=0x1a0e42f2;
    rsa_n->n->d[21]=0x57c410de;
    rsa_n->n->d[22]=0x66cda890;
    rsa_n->n->d[23]=0x1bc96f6a;
    rsa_n->n->d[24]=0x86df4d9e;
    rsa_n->n->d[25]=0x4ccf16bc;
    rsa_n->n->d[26]=0xe561f128;
    rsa_n->n->d[27]=0x27c7d373;
    rsa_n->n->d[28]=0xc912209b;
    rsa_n->n->d[29]=0xb8620455;
    rsa_n->n->d[30]=0x83752f4e;
    rsa_n->n->d[31]=0x98e0c3c4;
    rsa_n->n->d[32]=0x7dc5dca0;
    rsa_n->n->d[33]=0xbeae9058;
    rsa_n->n->d[34]=0x3fb8f428;
    rsa_n->n->d[35]=0x782ad281;
    rsa_n->n->d[36]=0x33d8ced5;
    rsa_n->n->d[37]=0x67c1e888;
    rsa_n->n->d[38]=0xe763ab2b;
    rsa_n->n->d[39]=0xf9477755;
    rsa_n->n->d[40]=0x058a467b;
    rsa_n->n->d[41]=0x8c972c15;
    rsa_n->n->d[42]=0xde208b93;
    rsa_n->n->d[43]=0x1e182f3e;
    rsa_n->n->d[44]=0xcfe6bb2d;
    rsa_n->n->d[45]=0x9d29b47b;
    rsa_n->n->d[46]=0x3196c5f3;
    rsa_n->n->d[47]=0x6b783c01;
    rsa_n->n->d[48]=0x5ad4a66c;
    rsa_n->n->d[49]=0xd32e0781;
    rsa_n->n->d[50]=0x194174ee;
    rsa_n->n->d[51]=0x91a4cb9a;
    rsa_n->n->d[52]=0x0d3fb2f5;
    rsa_n->n->d[53]=0x5a40b7ef;
    rsa_n->n->d[54]=0x02303b67;
    rsa_n->n->d[55]=0x31c098e3;
    rsa_n->n->d[56]=0x9f2a1c15;
    rsa_n->n->d[57]=0xa0eb24d1;
    rsa_n->n->d[58]=0xe246a2ad;
    rsa_n->n->d[59]=0xf2832414;
    rsa_n->n->d[60]=0x4ce30ec0;
    rsa_n->n->d[61]=0xef4f3dab;
    rsa_n->n->d[62]=0x9b52bcda;
    rsa_n->n->d[63]=0x0cd2f07e;
    RNS_N rns_n(rsa_n);

    openssl_BN_WORD_transform(rsa_n->n, open_n, DMAX);

    BN_mod(open_a,open_a,open_n,ctx);

    BN_WORD_openssl_transform(open_a , bn_a, DMAX);
    BN_WORD_openssl_transform(open_e , bn_e, DMAX);
    openssl_BN_WORD_transform(rns_n.m_M1, open_M, DMAX);

//i=0

    cout<<"i=0\n"<<endl;
    BN_mod_mul(open_a_exp_2,open_a,open_a,open_n,ctx);
    rns_n.RNS_mul_mod(bn_a,bn_a,bn_a_exp_2);

//i=1 

    cout<<"i=1\n"<<endl;
    BN_mod_mul(open_a_exp_4,open_a_exp_2,open_a_exp_2,open_n,ctx);
    rns_n.RNS_mul_mod(bn_a_exp_2,bn_a_exp_2,bn_a_exp_4);

//i=2
    cout<<"i=2\n"<<endl;
    BN_mod_mul(open_a_exp_8,open_a_exp_4,open_a_exp_4,open_n,ctx);
    rns_n.RNS_mul_mod(bn_a_exp_4,bn_a_exp_4,bn_a_exp_8);

    BN_mod_exp(open_a_exp_e,open_a,open_e,open_n,ctx);
    rns_n.RSA(bn_a,bn_e, bn_a_exp_e);

    cout<<"open_a:"<<endl;
    BN_OPEN_PRINT(open_a);
    cout<<"open_e:"<<endl;
    BN_OPEN_PRINT(open_e);
    cout<<"rsa_n:"<<endl;
    RSA_N_print(rsa_n);
    cout<<"open_a_exp_2:"<<endl;
    BN_OPEN_PRINT(open_a_exp_2);
    cout<<"bn_a_exp_2:"<<endl;
    BN_WORD_print(bn_a_exp_2);
    cout<<"open_a_exp_4:"<<endl;
    BN_OPEN_PRINT(open_a_exp_4);
    cout<<"bn_a_exp_4:"<<endl;
    BN_WORD_print(bn_a_exp_4);
    cout<<"open_a_exp_8:"<<endl;
    BN_OPEN_PRINT(open_a_exp_8);
    cout<<"bn_a_exp_8:"<<endl;
    BN_WORD_print(bn_a_exp_8);
    cout<<"open_a_exp_e:"<<endl;
    BN_OPEN_PRINT(open_a_exp_e);
    cout<<"bn_a_exp_e:"<<endl;
    BN_WORD_print(bn_a_exp_e);

/*
   cout<<"open_rsa_result:"<<endl;
    BN_OPEN_PRINT(open_rsa_result);
    cout<<"bn_rsa_result:"<<endl;
    BN_WORD_print(bn_rsa_result);
*/
}
#endif
