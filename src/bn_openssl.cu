#include "bn_openssl.h"

int  BN_WORD_openssl_transform(BIGNUM *a, BN_WORD *b, int dmax){
	for(int i=0;i<a->dmax;i++){
	    b->d[i]=a->d[i];
	}
	return 0;
}
