#include "pseudo.h"

#ifndef DMAX
#define DMAX 32
#endif

__host__ __device__ void mul_lo (BN_WORD *a, BN_WORD *b, BN_WORD *c,int *return_value){
    if ((*(a->carry)!=0)||(*(b->carry)!=0)){
	*return_value=-1;
        return ;
    }
    if(*(a->dmax)!=*(b->dmax)){
	*return_value=-2;
        return ;
    }
    *(c->dmax)=*(a->dmax);
    *(c->carry)=0;
    c->d[0]=a->d[0]*b->d[0];
    for(int i=1;i<*(c->dmax);i++){
        c->d[i]=0;
    }
    *return_value=0;
    return ;
}

__host__ __device__ void mad_lo (BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *u, BN_WORD *v, int *return_value, int *mul_lo_return_value, int *bn_word_add_return_value){
    if ((*(a->carry)!=0)||(*(b->carry)!=0)){
        *return_value =-1;
	return ;
    }
    if((*(a->dmax)!=*(b->dmax))||(*(a->dmax)!=*(u->dmax))||(*(a->dmax)!=*(v->dmax))){
	*return_value=-2;
        return ;
    }
    mul_lo(a,b,v,mul_lo_return_value);
    BN_WORD_add(v, c, v,bn_word_add_return_value);
    if(*(v->carry)==1){
        *(u->carry)=0;
        u->d[0]=1;
        for(int i=1;i<*(u->dmax);i++){
            u->d[i]=0;
        }
    }
    else{
        *(u->carry)=0;
        for(int i=0;i<*(u->dmax);i++){
            u->d[i]=0;
        }

    }
    *(v->carry)=0;
    *return_value=0;
    return ;
}

__host__ __device__ void mad_hi(BN_WORD *a, BN_WORD *b, BN_WORD *c, BN_WORD *result_u, BN_WORD *result_v,BN_WORD *a_half, BN_WORD *b_half,BN_WORD *result,BN_WORD *mid_value1,  BN_WORD *mid_value2, BN_WORD *mid_value3, BN_WORD *temp_result, BN_WORD *c_2dmax, int *add_return_value,int *shift_return_value){
    int dmax=*(a->dmax);
    BN_WORD_mul(a,b,a_half,b_half,result,mid_value1,mid_value2,mid_value3,temp_result,add_return_value,shift_return_value);
    BN_WORD_right_shift(result,temp_result,1,shift_return_value);
    for(int i=0;i<dmax*2;i++){
        result->d[i]=temp_result->d[i];
    }
    for(int i=0;i<dmax;i++){
        c_2dmax->d[i]=c->d[i];
    }
    for(int i=dmax;i<dmax*2;i++){
        c_2dmax->d[i]=0;
    }
    BN_WORD_add(result,c_2dmax,temp_result,add_return_value);
    for(int i=0;i<dmax;i++){
        result_v->d[i]=temp_result->d[i];
    }
    for(int i=0;i<dmax;i++){
        result_u->d[i]=temp_result->d[i+dmax];
    }
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
