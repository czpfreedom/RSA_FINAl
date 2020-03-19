#include "pseudo.h"
#include "stdio.h"

#ifndef DMAX
#define DMAX 32
#endif

__device__ int mul_lo (BN_WORD *a, BN_WORD *b, BN_WORD *result){
    int dmax=a->dmax;
    if ((a->carry!=0)||(b->carry!=0)){
	return -2;
    }
    if((b->dmax!=dmax)||(result->dmax!=dmax)){
	return -1;
    }
    result->carry=0;
    BN_WORD_setzero(result);
    result->d[0]=a->d[0]*b->d[0];
    for(int i=1;i<dmax;i++){
        result->d[i]=0;
    }
    return 0;
}

 __device__ int mad_lo (BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    int dmax=a->dmax;
    BN_WORD *temp_result;
    temp_result=BN_WORD_new_device(dmax);
    if ((a->carry!=0)||(b->carry!=0)){
	return -2;
    }
    if((b->dmax!=dmax)||(c->dmax!=dmax)||(result_u->dmax!=dmax)||(result_v->dmax!=dmax)){
        return -1;
    }
    BN_WORD_setzero(temp_result);
    BN_WORD_setzero(result_u);
    BN_WORD_setzero(result_v);
    mul_lo(a,b,result_v);
    BN_WORD_add(result_v, c, temp_result);
    BN_WORD_copy(temp_result,result_v);
    if(result_v->carry==1){
        result_u->carry=0;
        result_u->d[0]=1;
        for(int i=1;i<dmax;i++){
            result_u->d[i]=0;
        }
    }
    else{
        result_u->carry=0;
	BN_WORD_setzero(result_u);
    }
    result_v->carry=0;
    BN_WORD_free_device(temp_result);
    return 0;
}

__device__ int mad_hi(BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    int dmax=a->dmax;
    if ((a->carry!=0)||(b->carry!=0)){
        return -2;
    }
    if((b->dmax!=dmax)||(c->dmax!=dmax)||(result_u->dmax!=dmax)||(result_v->dmax!=dmax)){
        return -1;
    }
    BN_WORD *result, *temp_result,*c_2dmax;
    result=BN_WORD_new_device(dmax*2);
    temp_result=BN_WORD_new_device(dmax*2);
    c_2dmax=BN_WORD_new_device(dmax*2);
    BN_WORD_setzero(result);
    BN_WORD_setzero(temp_result);
    BN_WORD_setzero(c_2dmax);
    BN_WORD_mul(a,b,result);
    BN_WORD_right_shift(result,temp_result,1);
    BN_WORD_copy(temp_result,result);
    for(int i=0;i<dmax;i++){
        c_2dmax->d[i]=c->d[i];
    }
    for(int i=dmax;i<dmax*2;i++){
        c_2dmax->d[i]=0;
    }
    BN_WORD_setzero(temp_result);
    BN_WORD_setzero(result_u);
    BN_WORD_setzero(result_v);
    BN_WORD_add(result,c_2dmax,temp_result);
    for(int i=0;i<dmax;i++){
        result_v->d[i]=temp_result->d[i];
    }
    for(int i=0;i<dmax;i++){
        result_u->d[i]=temp_result->d[i+dmax];
    }
    BN_WORD_free_device(result);
    BN_WORD_free_device(temp_result);
    BN_WORD_free_device(c_2dmax);
    return 0;
}

__global__ void mad_lo_global(BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    mad_lo(a,b,c,result_u,result_v);
}

__global__ void mad_hi_global(BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    printf("start\n");
    mad_hi(a,b,c,result_u,result_v);
}

/*
__host__ __device__ void mad_hi(BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v,BN_WORD *mul_word_result,
		BN_WORD *mid_value1, BN_WORD *mid_value2, BN_WORD *mid_value3, BN_WORD *mid_value4, BN_WORD *mid_value5,int *mul_return_value,
		int *add_return_value, int *mid_return_value, int * return_value){
    BN_WORD_mul(a,b,result_u,result_v,mul_word_result, mid_value1, mid_value2, mid_value3, mid_value4, mid_value5,mul_return_value,add_return_value,
		    mid_return_value);
    BN_WORD_left_shift(result_u,mid_value1,DMAX-1,mid_return_value);
    BN_WORD_right_shift(result_v,mid_value3,1,mid_return_value);
    BN_WORD_right_shift(result_u,mid_value4,1,mid_return_value);
    BN_WORD_add(mid_value1,result_v,mid_value2,mid_return_value);
    BN_WORD_add(mid_value2,c,result_v,mid_return_value);
    BN_WORD_setzero(mid_value2);
    if(*(result_v->carry)!=0){
        *(result_v->carry)=0;
	BN_WORD_setone(mid_value2);
    }
    BN_WORD_add(mid_value4,mid_value2,result_u,mid_return_value);
    *return_value=0;
    return;
}
*/
