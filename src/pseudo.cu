#include "pseudo.h"
#include "stdio.h"


__device__ int mul_lo (const BN_WORD *a, const BN_WORD *b, BN_WORD *result){
    int dmax=a->dmax;
    if ((a->carry!=0)||(b->carry!=0)){
	return -2;
    }
    if((b->dmax!=dmax)||(result->dmax!=dmax)){
	return -1;
    }
    result->carry=0;
    BN_WORD_setzero(result);
    BN_WORD *result_temp;
    result_temp=BN_WORD_new_device(dmax*2);
    BN_WORD_setzero(result_temp);
    BN_WORD_mul(a,b,result_temp);
    for(int i=0;i<dmax;i++){
        result->d[i]=result_temp->d[i];
    }
    return 0;
}

 __device__ int mad_lo (const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    int dmax=a->dmax;
    if ((a->carry!=0)||(b->carry!=0)){
	return -2;
    }
    if((b->dmax!=dmax)||(c->dmax!=dmax)||(result_u->dmax!=dmax)||(result_v->dmax!=dmax)){
        return -1;
    }
    BN_WORD *temp_result;
    temp_result=BN_WORD_new_device(dmax);
    BN_WORD_setzero(result_u);
    BN_WORD_setzero(result_v);
    mul_lo(a,b,result_v);
    BN_WORD_add(result_v, c, temp_result);
    BN_WORD_copy(temp_result,result_v);
    if(BN_WORD_cmp(c,result_v)==1){
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
    return 0;
}

__device__ int mad_hi(const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    int dmax=a->dmax;
    if ((a->carry!=0)||(b->carry!=0)){
        return -2;
    }
    if((b->dmax!=dmax)||(c->dmax!=dmax)||(result_u->dmax!=dmax)||(result_v->dmax!=dmax)){
        return -1;
    }
    BN_WORD *result, *temp_result,*temp_2_result;
    result=BN_WORD_new_device(dmax*2);
    temp_result=BN_WORD_new_device(dmax);
    temp_2_result=BN_WORD_new_device(dmax*2);
    BN_WORD_setzero(result);
    BN_WORD_mul(a,b,result);
    BN_WORD_right_shift(result,temp_2_result,dmax);
    BN_WORD_copy(temp_2_result,result);
    BN_WORD_setzero(result_u);
    BN_WORD_setzero(result_v);
    for(int i=0;i<dmax;i++){
        result_v->d[i]=result->d[i];
    }
    BN_WORD_add(result_v,c,temp_result);
    BN_WORD_copy(temp_result,result_v);
    if(BN_WORD_cmp(c,result_v)==1){
        BN_WORD_setone(result_u);
    }
    BN_WORD_free_device(result);
    return 0;
}

__device__ int any(BN_NUM *a){
    int cmp;
    BN_NUM *zero;
    zero=BN_NUM_new_device(a->wmax,a->word[0]->dmax);
    cmp=BN_NUM_cmp(a,zero);
    if(cmp==0)
	    return 1;
    else return 0;
}

__global__ void mul_lo_global(const BN_WORD *a, const BN_WORD *b, BN_WORD*result){
    mul_lo(a,b,result);
}

__global__ void mad_lo_global(const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
    mad_lo(a,b,c,result_u,result_v);
}

__global__ void mad_hi_global(const BN_WORD *a, const BN_WORD *b, const BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v){
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
