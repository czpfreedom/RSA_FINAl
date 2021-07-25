#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

using namespace std;

#ifdef BN_PART_32
int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax){
    for(int i=0;i<a->dmax;i++){
        b->d[2*i]=(BN_PART)(a->d[i]%((unsigned long)1<<32));
	b->d[2*i+1]=(BN_PART)(a->d[i]/((unsigned long)1<<32));
    }    
    return 0;
}

int openssl_BN_WORD_transform(BN_WORD *a, BIGNUM *b, int dmax){
    BN_rand(b,sizeof(BN_PART)*8*dmax,0,0);
    for(int i=0;2*i<dmax;i++){
        b->d[i]=(unsigned long)(a->d[2*i])+(((unsigned long)a->d[2*i+1])<<(sizeof(BN_PART)*8));
    }
    return 0;
}
#endif

#ifdef BN_PART_64
int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax){
    for(int i=0;i<a->dmax;i++){
        b->d[i]=a->d[i];
    }
    return 0;
}

int openssl_BN_WORD_transform(BN_WORD *a, BIGNUM *b, int dmax){
    BN_rand(b,sizeof(BN_PART)*8*dmax,0,0);
    for(int i=0;i<dmax;i++){
        b->d[i]=a->d[i];	
    }		    
    return 0;
}
#endif

int BN_WORD_openssl_prime_generation(RSA_N *rsa_n){
    int dmax=rsa_n->n->dmax;
    int p_dmax=dmax/2;
    BIGNUM *prime;
    prime=BN_new();
    BN_generate_prime_ex(prime,p_dmax*sizeof(BN_PART)*8-2,0,NULL,NULL,NULL);
    BN_WORD_openssl_transform(prime,rsa_n->p,dmax);
    BN_generate_prime_ex(prime,p_dmax*sizeof(BN_PART)*8-2,0,NULL,NULL,NULL);
    BN_WORD_openssl_transform(prime,rsa_n->q,dmax);
    BN_WORD_mul(rsa_n->p, rsa_n->q, rsa_n->n);
    return 0;
}


int BN_OPEN_PRINT(BIGNUM *a){
    cout<<hex<<"dmax:"<<(a->dmax)<<endl;
    cout<<hex<<"top:"<<(a->top)<<endl;
    for(int i=(a->top)-1;i>=0;i--){
        cout<<hex<<a->d[i]<<",";
    }
    cout<<endl;
}
