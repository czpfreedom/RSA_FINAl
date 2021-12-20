#include "rsa_final_c.h"
#include "openssl/bn.h"
#include "bn/bn_lcl.h"

#define DMAX 8

#ifdef BN_PART_32
int BN_WORD_C_openssl_transform(BIGNUM *a, BN_WORD_C* b){
    BN_WORD_C_setzero(b);
    b->m_neg=a->neg;
    b->m_top=a->top*2;
    if(b->m_top>(BN_WORD_LENGTH_MAX)/2){
        //error
        return -1;
    }
    for(int i=0;i<a->top;i++){
        b->m_data[2*i]=(BN_PART)(a->d[i]%((unsigned long)1<<32));
        b->m_data[2*i+1]=(BN_PART)(a->d[i]/((unsigned long)1<<32));
    }     
    return 1;
}

int openssl_BN_WORD_C_transform(BIGNUM *a, BN_WORD_C *b){
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

int BN_OPEN_PRINT(BIGNUM *a){
    printf("top:%d\n",a->top);
    printf("neg:%d\n",a->neg);
    for(int i=a->top-1;i>=0;i--){
        printf("%x,",a->d[i]);
    }
    printf("\n");
    return 1;
}

#endif

#ifdef BN_PART_64

int BN_WORD_C_openssl_transform(BIGNUM *a, BN_WORD_C *b){
    BN_WORD_C_setzero(b);
    b->m_neg=a->neg;
    b->m_top=a->top;
    if(a->top==0){
        BN_WORD_C_setzero(b);
        return 1;
    }
    if(b->m_top>(BN_WORD_LENGTH_MAX)/2){
        //error
        return -1;
    }
    for(int i=0;i<a->top;i++){
        b->m_data[i]=a->d[i];
    }
    return 1;
}

int openssl_BN_WORD_C_transform(BIGNUM *a, BN_WORD_C* b){
    BN_rand(a,sizeof(BN_PART)*8*b->m_top,0,0);
    for(int i=0;i<b->m_top;i++){
        a->d[i]=(unsigned long)(b->m_data[i]);
    }
    return 1;
}

int BN_OPEN_PRINT(BIGNUM *a){
    printf("top:%d\n",a->top);
    printf("neg:%d\n",a->neg);
    for(int i=a->top-1;i>=0;i--){
        printf("%lx,",a->d[i]);
    }
    printf("\n");
    return 1;
}

#endif

int main(){

    BIGNUM *open_a, *open_e, *open_p, *open_q, *open_n, *open_result, *open_bn_result;
    BN_WORD_C *bn_a, *bn_e, *bn_n, *bn_result;

    BN_CTX *ctx;

    int sum=0;
    int loop_num=DMAX*DMAX;

    open_n=BN_new();
    open_p=BN_new();
    open_q=BN_new();
    bn_n=BN_WORD_C_new(DMAX,0);
    ctx=BN_CTX_new();
    
    BN_generate_prime_ex(open_p,DMAX*sizeof(BN_PART)*4,0,NULL,NULL,NULL);
    BN_generate_prime_ex(open_q,DMAX*sizeof(BN_PART)*4,0,NULL,NULL,NULL);
    BN_mul(open_n,open_p,open_q,ctx);
    BN_WORD_C_openssl_transform(open_n,bn_n);

    for (int i=1;i<=DMAX;i++){
        for(int j=1;j<=DMAX;j++){

            open_a=BN_new();
            open_e=BN_new();
            open_result=BN_new();
            open_bn_result=BN_new();

            bn_a=BN_WORD_C_new(i,0);
            bn_e=BN_WORD_C_new(j,0);
            bn_result=BN_WORD_C_new(DMAX,0);    

            BN_rand(open_a,i*sizeof(BN_PART)*8,0,0);
            BN_rand(open_e,j*sizeof(BN_PART)*8,0,0);

            BN_WORD_C_openssl_transform(open_a,bn_a);
            BN_WORD_C_openssl_transform(open_e,bn_e);

            BN_mod_exp(open_result, open_a, open_e, open_n, ctx);
            BN_mod_exp_cuda_c(bn_result, bn_a, bn_e , bn_n);
            openssl_BN_WORD_C_transform(open_bn_result,bn_result);

	    if(BN_cmp(open_result,open_bn_result)==0){
	        sum=sum+1;
	    }
	    else {
	        printf("result error:i:%d,j:%d\n",i,j);
	    }

	    BN_free(open_a);
	    BN_free(open_e);
	    BN_free(open_result);
	    BN_free(open_bn_result);

	    BN_WORD_C_free(bn_a);
	    BN_WORD_C_free(bn_e);
	    BN_WORD_C_free(bn_result);
	}
    }

    printf("LOOP_NUM:%d,RIGHT:%d\n",loop_num,sum);
    
    return 0;

}
