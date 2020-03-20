#include "bn_word_operation.h"
#include "pseudo.h"
#include "parallel_mont_mul.h"

__host__ __device__ int_mod(const int a,const int b){
    return a%b;
}


__global__ void parallel_mont_mul(const BN_NUM *a,const BN_NUM *b,const BN_WORD_NUM *n,const int wmax,const int dmax,const BN_WORD *n0_inverse,
		BN_NUM *result, BN_NUM *u, BN_NUM *u_temp,BN_NUM *v, BN_NUM *m, BN_NUM *c, BN_NUM *t){
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    BN_WORD_setzero(u->word[j]);
    BN_WORD_setzero(v->word[j]);
//need error_check
    for(int i=0;i<wmax;i++){
        mad_lo(a->word[j],b->word[i],v->word[j],u_temp->word[j],v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],u->word[j]);
	mul_lo(u->word[j],n0_inverse,n->word[j]);
	//need synchronization
	BN_WORD_copy(m->word[0],m->word[j]);
	mad_lo(n->word[i],m->word[j],v->word[j],u_temp->word[j],v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],u->word[j]);
	//need synchronization
	BN_WORD_copy(v->word[j],v->word[int_mod(j+1,wmax)]);
	BN_WORD_add(u->word[j],v->word[j],v->word[j]);
	if(v->word[j]->carry==0){
	    BN_WORD_setzero(u->word[j]);
	    v->word[j]->carry=0;
	}
	else {
	    BN_WORD_setone(u->word[j]);
	    v->word[j]->carry=0;
	}
	mad_hi(a->word[j],b->word[i],v->word[j],u_temp->word[j],v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],u->word[j]);
	mad_hi(n->word[i],m->word[j],v->word[j],u_temp->word[j],v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],u->word[j]);
    }
    BN_WORD_copy(u->word[j],c->word[j]);
    while(any(u->word[j])==0){
        BN_WORD_copy(u->word[int_mod(j-1)],u->word[j]);
	if(j==0){
	    BN_WORD_setzero(u->word[j]);
	}
	BN_WORD_add(u->word[j],v->word[j],v->word[j]);
        if(v->word[j]->carry==0){
            BN_WORD_setzero(u->word[j]);
            v->word[j]->carry=0;
        }
        else {
            BN_WORD_setone(u->word[j]);
            v->word[j]->carry=0;
        }
	BN_WORD_add(c->word[j],u->word[j],c->word[j]);
    }
    BN_WORD_copy(v->word[j],t->word[j]);
    //need sy
    BN_WORD_copy(c->word[wmax-1],c->word[j]);
    if(any(c->word[j])){
        BN_NUM_sub(t,n,t);
    }
}
