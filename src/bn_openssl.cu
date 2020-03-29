#include "bn_openssl.h"

int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax){
	for(int i=0;i<a->dmax;i++){
	    b->d[i]=a->d[i];
	}
	return 0;
}

int BN_NUM_openssl_transform(BIGNUM *a,BN_NUM *b, int wmax, int dmax){
    for(int i=0;i<wmax;i++){
        for(int j=0;j<dmax;j++){
	    b->word[i]->d[j]=a->d[i*dmax+j];
	}
    }    
    return 0;
}
