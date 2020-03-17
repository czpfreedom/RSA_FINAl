#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "stdlib.h"
#include "iostream"
#include <stdio.h>

#ifndef BN_MASK2L
#define BN_MASK2L (0xffffffffffffffffL)// unsigned long
#endif

#ifndef BN_MASK2l
#define BN_MASK2l (0xffffffffL)        // unsigned long also  but with 32 zeros at the top
#endif




#ifndef get_bit
#define get_bit(a,i)     (a&((BN_ULONG)1<<i))>>i
#endif


BN_WORD* BN_WORD_new(int dmax){
    BN_WORD *a;
    a=new BN_WORD();
    cudaMallocManaged((void**)&(a->dmax),sizeof(int));
    cudaMallocManaged((void**)&(a->carry),sizeof(int));
    *(a->dmax)=dmax;
    *(a->carry)=0;
    cudaMallocManaged((void**)&(a->d),*(a->dmax)*sizeof(BN_ULONG));
    return a;
}

int BN_WORD_free(BN_WORD *a){
    cudaFree(a->dmax);
    cudaFree(a->carry);
    cudaFree(a->d);
    delete(a);
    return 0;
}

__host__ __device__ int BN_WORD_setzero(BN_WORD *a){
    *(a->carry)=0;
    for(int i=0;i<*a->dmax;i++){
        a->d[i]=0;
    }
    return 0;
}

__host__ __device__ int BN_WORD_setone(BN_WORD *a){
    *(a->carry)=0;
    a->d[0]=1;
    for(int i=1;i<*a->dmax;i++){
        a->d[i]=0;
    }
    return 0;
}


/*int BN_WORD_copy(BN_WORD *a,BN_WORD *b){
    *(b->carry)=*(a->carry);
    if(*(a->dmax)==*(b->dmax)){
        ;
    }
    else {
        *(b->dmax)=*(a->dmax);
        cudaFree((b->d));
        cudaMallocManaged((void **)&(b->d),*(b->dmax)*sizeof(BN_ULONG));
        for(int i=0;i<*(b->dmax);i++){
            b->d[i]=a->d[i];
        }
    }
}
*/

__host__ __device__ void BN_WORD_print(BN_WORD *a){
    printf("dmax:%d\n",*(a->dmax));
    printf("carry:%lx\n",*(a->carry));
    for(int i=*(a->dmax)-1;i>=0;i--){
        printf("%lx,",a->d[i]);
    }
    printf("\n");
}

__host__ __device__ void BN_WORD_cmp(BN_WORD *a, BN_WORD *b, int *return_value){
    *return_value=0;
    if ((*(a->carry)!=0)||(*(b->carry)!=0)){
        *return_value=-1;
        return;
    }
    if(*(a->dmax)!=*(b->dmax)){
        *return_value=-2;
        return ;
    }
    for(int i=*(a->dmax)-1;i>=0;i--){
        if(a->d[i]>b->d[i]){
            *return_value=1;
            return;
        }
        if(a->d[i]<b->d[i]){
            *return_value=2;
            return;
        }
    }
    *return_value=0;
    return ;
}

__host__ __device__ void BN_WORD_left_shift(BN_WORD *a,BN_WORD *b,int words,int *return_value){
    if(*(a->dmax)<words){
        *return_value=-1;
	return;
    }
    if(*(a->dmax)!=*(b->dmax)){
        *return_value=-2;
	return;
    }
    *(b->carry)=*(a->carry);
    *(b->dmax)=*(a->dmax);
    for(int i=*(a->dmax)-1;i>=words;i--){
        b->d[i]=a->d[i-words];
    }
    for(int i=words-1;i>=0;i--){
        b->d[i]=0;
    }
    *return_value=0;
    return ;
}



__host__ __device__ void BN_WORD_left_shift_bits(BN_WORD *a,BN_WORD *b,int bits,int *return_value){
    if(bits>sizeof(BN_ULONG)*8){
        *return_value=-1;
	return;
    }
    if(*(a->dmax)!=*(b->dmax)){
        *return_value=-2;
        return;
    }
    *(b->carry)=*(a->carry);
    *(b->dmax)=*(a->dmax);
    b->d[0]=a->d[0]<<bits;
    for (int i=1;i<*(a->dmax);i++){
        b->d[i]=(a->d[i]<<bits)+(a->d[i-1])/((BN_ULONG)1<<(sizeof(BN_ULONG)*8-bits));
    }
    *return_value=0;
    return;
}



__host__ __device__ void BN_WORD_right_shift(BN_WORD *a,BN_WORD *b,int words, int *return_value){
    if(*(a->dmax)<words){
        *return_value=-1;
        return;
    }
    if(*(a->dmax)!=*(b->dmax)){
        *return_value=-2;
        return;
    }
    for(int i=0;i<*(a->dmax)-words;i++){
        b->d[i]=a->d[i+words];
    }
    for(int i=*(a->dmax)-words;i<*(a->dmax);i++){
        b->d[i]=0;
    }
    *return_value=0;
    return;
}

__host__ __device__ void BN_WORD_right_shift_bits(BN_WORD *a,BN_WORD *b,int bits,int *return_value){
    if(bits>sizeof(BN_ULONG)*8){
        *return_value=-1;
        return;
    }
    if(*(a->dmax)!=*(b->dmax)){
        *return_value=-2;
        return;
    }
    *(b->carry)=*(a->carry);
    *(b->dmax)=*(a->dmax);
    for (int i=0;i<*(a->dmax)-1;i++){
        b->d[i]=(a->d[i])/((BN_ULONG)1<<bits)+((a->d[i+1])<<(sizeof(BN_ULONG)*8-bits));
//	printf("%lx\n",(a->d[i])/(1<<bits));
//	printf("%lx\n",(a->d[i+1])<<(sizeof(BN_ULONG)*8-bits));
    }
    b->d[*(a->dmax)-1]=(a->d[*(a->dmax)-1])/((BN_ULONG)1<<bits);
    *return_value=0;
    return;
}



__host__ __device__ void BN_WORD_add(BN_WORD *a, BN_WORD *b, BN_WORD *result, int *return_value){
    BN_ULONG carry2=0;
    BN_ULONG carry1=0;
    BN_ULONG mid_value;
    if ((*(a->carry)!=0)||(*(b->carry)!=0)){
        *return_value=-1;
	return ;
    }
    if(*(a->dmax)!=*(b->dmax)){
	*return_value=-2;
        return ;
    }
    *(result->dmax)=*(a->dmax);
    for (int i=0;i<*(a->dmax);i++){
	carry2=carry1;
	carry1=0;
        mid_value=(a->d[i]+carry2)&BN_MASK2L;
        if(mid_value<a->d[i]){
            carry1=1;
        }
        mid_value=(mid_value+b->d[i])&BN_MASK2L;
        if(mid_value<b->d[i]){
            carry1=1;
        }
        result->d[i]=mid_value;
    }
    *(result->carry)=carry1;
    *return_value=0;
    return ;
}

__host__ __device__ void BN_WORD_sub(BN_WORD *a, BN_WORD *b, BN_WORD *result, int *cmp_return_value,int *return_value){
    BN_ULONG mid_value1, mid_value;
    BN_ULONG carry1,carry2;
    BN_WORD_cmp(a,b,cmp_return_value);
    if(*(cmp_return_value)==-1){
        *return_value=-1;
        return;
    }
    if(*(cmp_return_value)==-2){
        *return_value=-2;
	return;
    }
    if(*(cmp_return_value)==2){
        *return_value=-3;
	return;
    }
    if(*(cmp_return_value)==0){
	*return_value=0;
        BN_WORD_setzero(result);
	return;
    }
    if(*(cmp_return_value)==1){
        *(result->dmax)=*(a->dmax);
	*(result->carry)=0;
        carry2=0;
	carry1=0;
        for(int i=0;i<*(a->dmax);i++){
	    carry2=carry1;
	    carry1=0;
            mid_value1=(a->d[i]-carry2)&BN_MASK2L;
            if(mid_value1>a->d[i]){
                carry1=1;
            }
            mid_value=(mid_value1-b->d[i])&BN_MASK2L;
            if(mid_value>mid_value1){
                carry1=1;
            }
            result->d[i]=mid_value;
        }
        *return_value=0;
    }
}

__host__ __device__ void BN_WORD_high (BN_WORD *a, BN_WORD *b){
    *(b->dmax)=*(a->dmax);
    *(b->carry)=*(a->dmax);
    for(int i=0;i<*(a->dmax);i++){
        b->d[i]=(a->d[i])/((BN_ULONG)1<<sizeof(BN_ULONG)*4);
    }	
}

__host__ __device__ void BN_WORD_low (BN_WORD *a, BN_WORD *b){
    *(b->dmax)=*(a->dmax);
    *(b->carry)=*(a->dmax);
    for(int i=0;i<*(a->dmax);i++){
        b->d[i]=(a->d[i])&BN_MASK2l;
    }
}

__host__ __device__ void BN_WORD_mul_half(BN_WORD *a, BN_WORD *b, BN_WORD *result, BN_WORD *mid_value1,
	       	BN_WORD *mid_value2,int *add_return_value){
    int dmax=*(a->dmax);
    BN_WORD_setzero(result);
    for(int i=0;i<dmax;i++){
	BN_WORD_setzero(mid_value1);
	BN_WORD_setzero(mid_value2);
	for(int j=0;j<dmax;j++){
	    mid_value1->d[i+j]=(b->d[i])*(a->d[j]);
	}
	BN_WORD_add(result,mid_value1,mid_value2,add_return_value);
	for(int j=0;j<dmax*2;j++){
	    result->d[j]=mid_value2->d[j];
	}
    }
}

__host__ __device__ void BN_WORD_mul(BN_WORD *a, BN_WORD *b, BN_WORD *a_half, BN_WORD *b_half,BN_WORD *result,
		BN_WORD *mid_value1,  BN_WORD *mid_value2, BN_WORD *mid_value3, BN_WORD *temp_result,
		int *add_return_value, int *shift_return_value){
    int dmax=*(a->dmax);
    BN_WORD_setzero(a_half);
    BN_WORD_setzero(b_half);
    BN_WORD_setzero(mid_value1);
    BN_WORD_setzero(mid_value2);
    BN_WORD_setzero(mid_value3);
    BN_WORD_setzero(temp_result);
    BN_WORD_low(a,a_half);
    BN_WORD_low(b,b_half);
    BN_WORD_mul_half(a_half,b_half,mid_value3,mid_value1,mid_value2,add_return_value);
    BN_WORD_add(result,mid_value3,temp_result,add_return_value);
    for(int i=0;i<dmax*2;i++){
        result->d[i]=temp_result->d[i];
    }


    BN_WORD_setzero(a_half);
    BN_WORD_setzero(b_half);
    BN_WORD_setzero(mid_value1);
    BN_WORD_setzero(mid_value2);
    BN_WORD_setzero(mid_value3);
    BN_WORD_setzero(temp_result);
    BN_WORD_high(a,a_half);
    BN_WORD_low(b,b_half);
    BN_WORD_mul_half(a_half,b_half,mid_value3,mid_value1,mid_value2,add_return_value);
    BN_WORD_left_shift_bits(mid_value3,temp_result,sizeof(BN_ULONG)*4,shift_return_value);
    for(int i=0;i<dmax*2;i++){
        mid_value3->d[i]=temp_result->d[i];
    }

    BN_WORD_add(result,mid_value3,temp_result,add_return_value);
    for(int i=0;i<dmax*2;i++){
        result->d[i]=temp_result->d[i];
    }

    BN_WORD_setzero(a_half);
    BN_WORD_setzero(b_half);
    BN_WORD_setzero(mid_value1);
    BN_WORD_setzero(mid_value2);
    BN_WORD_setzero(mid_value3);
    BN_WORD_setzero(temp_result);
    BN_WORD_low(a,a_half);
    BN_WORD_high(b,b_half);
    BN_WORD_mul_half(a_half,b_half,mid_value3,mid_value1,mid_value2,add_return_value);
    BN_WORD_left_shift_bits(mid_value3,temp_result,sizeof(BN_ULONG)*4,shift_return_value);
    for(int i=0;i<dmax*2;i++){
        mid_value3->d[i]=temp_result->d[i];
    }

    BN_WORD_add(result,mid_value3,temp_result,add_return_value);
    for(int i=0;i<dmax*2;i++){
        result->d[i]=temp_result->d[i];
    }

    BN_WORD_setzero(a_half);
    BN_WORD_setzero(b_half);
    BN_WORD_setzero(mid_value1);
    BN_WORD_setzero(mid_value2);
    BN_WORD_setzero(mid_value3);
    BN_WORD_setzero(temp_result);
    BN_WORD_high(a,a_half);
    BN_WORD_high(b,b_half);
    BN_WORD_mul_half(a_half,b_half,mid_value3,mid_value1,mid_value2,add_return_value);
    BN_WORD_left_shift(mid_value3,temp_result,1,shift_return_value);
    for(int i=0;i<dmax*2;i++){
        mid_value3->d[i]=temp_result->d[i];
    }

    BN_WORD_add(result,mid_value3,temp_result,add_return_value);
    for(int i=0;i<dmax*2;i++){
        result->d[i]=temp_result->d[i];
    }
}

/*

__host__ __device__ void BN_WORD_mul_word_bnulong(BN_WORD *a, BN_ULONG b,BN_WORD *result, BN_WORD *mid_value1, BN_WORD *mid_value2, 
		BN_WORD *mid_value3, int *return_value, int *mid_return_value){
    if(*(a->carry)!=0){
        *return_value=-1;
	return;
    }
    BN_WORD_setzero(result);
    BN_WORD_setzero(mid_value1);
    BN_WORD_setzero(mid_value2);
    BN_WORD_setzero(mid_value3);
    for(int i=0;i<sizeof(BN_ULONG)*8;i++){
        if(get_bit(b,i)==1){
	    BN_WORD_left_shift_bits(a,mid_value2,i,mid_return_value);
	    *(mid_value1->carry)=0;
	    *(mid_value3->carry)=0;
	    BN_WORD_add(mid_value1,mid_value2,mid_value3,mid_return_value);
	    *(result->carry)=*(result->carry)+(a->d[*(a->dmax)-1])/((BN_ULONG)1<<(sizeof(BN_ULONG)*8-i))+*(mid_value3->carry);
	    for(int j=0;j<*(a->dmax);j++){
	        mid_value1->d[j]=mid_value3->d[j];
	    }
	}
    }
//    BN_WORD_print(mid_value1);
    for(int i=0;i<*(a->dmax);i++){
        result->d[i]=mid_value3->d[i];
    }
    *return_value=0;
    return;
}

__host__ __device__ void BN_WORD_mul(BN_WORD *a, BN_WORD *b, BN_WORD *result_u,BN_WORD *result_v,BN_WORD *mul_word_result,  BN_WORD *mid_value1, 
		BN_WORD *mid_value2, BN_WORD *mid_value3,BN_WORD *mid_value4, BN_WORD *mid_value5, 
		int *return_value,int *add_return_value,int *mid_return_value){
    BN_WORD_setzero(mid_value3);
    BN_WORD_setzero(mid_value4);
    BN_WORD_setzero(result_u);
    for (int i=0;i<*(b->dmax);i++){
        BN_WORD_mul_word_bnulong(a,b->d[i], mul_word_result, mid_value1,mid_value2,mid_value5,add_return_value,mid_return_value);
	*(mid_value3->carry)=0;
	BN_WORD_left_shift(mul_word_result,mid_value4,i,mid_return_value);
	*(mid_value4->carry)=0;
	BN_WORD_setone(mid_value5);
	BN_WORD_add(mid_value3,mid_value4,mid_value5,mid_return_value);
	for (int j=0;j<*(b->dmax);j++){
	    mid_value3->d[j]=mid_value5->d[j];
	}
	BN_WORD_right_shift(mul_word_result,mid_value1,*(a->dmax)-i,mid_return_value);
	*(mid_value1->carry)=0;
	mid_value1->d[i]=*(mul_word_result->carry);
	BN_WORD_setzero(mid_value2);
	if(*(mid_value3->carry)!=0){
	    BN_WORD_setone(mid_value2);
	}
	BN_WORD_add(result_u,mid_value1,mid_value5,mid_return_value);
	for (int j=0;j<*(b->dmax);j++){
            result_u->d[j]=mid_value5->d[j];
        }
	BN_WORD_add(result_u,mid_value2,mid_value5,mid_return_value);
	for (int j=0;j<*(b->dmax);j++){
            result_u->d[j]=mid_value5->d[j];
        }
    }
    for(int i=0;i<*(a->dmax);i++){
        result_v->d[i]=mid_value3->d[i];
    }
    *(result_u->carry)=0;
    *(result_v->carry)=0;
    *(return_value)=0;
    return;
}
*/
