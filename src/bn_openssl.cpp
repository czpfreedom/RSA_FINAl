#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#ifdef EXTRA_OPENSSL

namespace namespace_rsa_final{

#ifdef BN_PART_32

int BN_WORD_openssl_transform(BIGNUM *a, BN_WORD &b){
    b.m_neg=a->neg;
    b.m_top=a->top*2;
    if(b.m_top>(BN_WORD_LENGTH_MAX)/2){
        //error
	return -1;
    }
    for(int i=0;i<a->top;i++){
	b.m_data[2*i]=(BN_PART)(a->d[i]%((unsigned long)1<<32));
	b.m_data[2*i+1]=(BN_PART)(a->d[i]/((unsigned long)1<<32));
    }
    return 1;
}

int openssl_BN_WORD_transform(BIGNUM *a, BN_WORD &b){
    if(b.m_top%2==0){
        int dmax=b.m_top/2;
    	BN_rand(a,sizeof(BN_PART)*8*b.m_top,0,0);
	for(int i=0;i<dmax;i++){
	    a->d[i]=(unsigned long)(b.m_data[2*i])+((unsigned long)b.m_data[2*i+1])<<(sizeof(BN_PART)*8);
	}
	return 1;
    }
    else{
        int dmax=b.m_top/2+1;
    	BN_rand(a,sizeof(BN_PART)*8*b.m_top,0,0);
	for(int i=0;i<dmax-1;i++){
	    a->d[i]=(unsigned long)(b.m_data[2*i])+((unsigned long)b.m_data[2*i+1])<<(sizeof(BN_PART)*8);
	}
	a->d[dmax-1]=(unsigned long)(b.m_data[2*(dmax-1)]);
	return 1;
    }
    return -1;
}

#endif

#ifdef BN_PART_64

int BN_WORD_openssl_transform(BIGNUM *a, BN_WORD &b){
    b.setzero();
    b.m_neg=a->neg;
    b.m_top=a->top;
    if(a->top==0){
        b.setzero();
	return 1;
    }
    if(b.m_top>(BN_WORD_LENGTH_MAX)/2){
        //error
	return -1;
    }
    for(int i=0;i<a->top;i++){
	b.m_data[i]=a->d[i];
    }
    return 1;
}

int openssl_BN_WORD_transform(BIGNUM *a, BN_WORD &b){
    BN_rand(a,sizeof(BN_PART)*8*b.m_top,0,0);

    for(int i=0;i<b.m_top;i++){
	a->d[i]=(unsigned long)(b.m_data[i]);
    }
    return 1;
}

#endif


int BN_WORD_openssl_prime_generation(RSA_N &rsa_n, int bits){
    int p_bits=bits/2;
    BIGNUM *prime;
    prime=BN_new();
    BN_generate_prime_ex(prime,p_bits,0,NULL,NULL,NULL);
    BN_WORD_openssl_transform(prime,rsa_n.m_p);
    BN_generate_prime_ex(prime,p_bits,0,NULL,NULL,NULL);
    BN_WORD_openssl_transform(prime,rsa_n.m_q);
    rsa_n.m_n=rsa_n.m_p*rsa_n.m_q;
    return 1;
}

int BN_OPEN_PRINT(BIGNUM *a){
    std::cout<<std::hex<<"dmax:"<<(a->dmax)<<std::endl;
    std::cout<<std::hex<<"top:"<<(a->top)<<std::endl;
    for(int i=(a->top)-1;i>=0;i--){
	    std::cout<<std::hex<<a->d[i]<<",";
    }
    std::cout<<std::endl;
    return 1;
}

}

#endif
