#include "bn_word_operation.h"
#include "pseudo.h"
#include "parallel_mont_exp.h"
#include "stdio.h"


__host__ int BN_NUM_inverse(const BN_NUM *n, const int d, const int l, BN_NUM *n_inverse){
    BN_NUM *zero,*one,*R1, *R2, *s1, *s2, *t1, *t2,*temp,*temp_mul,*q;
    zero=BN_NUM_new(d,l);
    one=BN_NUM_new(d,l);
    R1=BN_NUM_new(d,l);
    R2=BN_NUM_new(d,l);
    s1=BN_NUM_new(d,l);
    s2=BN_NUM_new(d,l);
    t1=BN_NUM_new(d,l);
    t2=BN_NUM_new(d,l);
    temp=BN_NUM_new(d,l);
    q=BN_NUM_new(d,l);
    temp_mul=BN_NUM_new(d,l);
    BN_NUM_setzero(zero);
    BN_NUM_setone(one);
    BN_NUM_copy(n,R1);
    BN_NUM_sub(zero,R1,R2);
    BN_NUM_div(R2,R1,q,R2);
    BN_NUM_add(q,one,q);
    BN_NUM_setzero(s1);
    BN_NUM_setone(t1);
    BN_NUM_sub(zero,q,t2);
    while(BN_NUM_cmp(R2,one)!=0){
        BN_NUM_copy(R2,temp);
	BN_NUM_div(R1,R2,q,R2);
	BN_NUM_copy(temp,R1);
	BN_NUM_copy(s2,temp);
	BN_NUM_mul(q,s2,temp_mul);
	BN_NUM_sub(s1,temp_mul,s2);
	BN_NUM_copy(temp,s1);
	BN_NUM_copy(t2,temp);
	BN_NUM_mul(q,t2,temp_mul);
	BN_NUM_sub(t1,temp_mul,t2);
        BN_NUM_copy(temp,t1);
    }
    BN_NUM_copy(t2,n_inverse);
    BN_NUM_free(zero);
    BN_NUM_free(one);
    BN_NUM_free(R1);
    BN_NUM_free(R2);
    BN_NUM_free(s1);
    BN_NUM_free(s2);
    BN_NUM_free(t1);
    BN_NUM_free(t2);
    BN_NUM_free(temp);
    BN_NUM_free(q);
    BN_NUM_free(temp_mul);
    return 0;
}

__host__ int BN_NUM_parallel_mod_mul(const BN_NUM *a, const BN_NUM *b, const BN_NUM *n, const int d, const int l,
		BN_NUM *result){    	
    BN_NUM *n_inverse, *u, *u_temp, *v, *v_temp,*m, *c ,*zero,*temp_result,*a_sub,*b_sub,*one,*R_pro;
    int *any_value;
    BN_WORD *n0_inverse;
    cudaMallocManaged((void **)&(any_value),d*sizeof(int));
    zero=BN_NUM_new(d,l);
    n_inverse=BN_NUM_new(d,l);
    temp_result=BN_NUM_new(d,l);
    u=BN_NUM_new(d,l);
    u_temp=BN_NUM_new(d,l);
    v_temp=BN_NUM_new(d,l);
    v=BN_NUM_new(d,l);
    m=BN_NUM_new(d,l);
    c=BN_NUM_new(d,l);
    a_sub=BN_NUM_new(d,l);
    b_sub=BN_NUM_new(d,l);
    one=BN_NUM_new(d,l);
    R_pro=BN_NUM_new(d,l);
    n0_inverse=BN_WORD_new(l);
    BN_NUM_setzero(zero);
    BN_NUM_setone(one);
    BN_NUM_copy(a,a_sub);
    BN_NUM_copy(b,b_sub);
    while(BN_NUM_cmp(a_sub,n)==1){
        BN_NUM_sub(a_sub,n,temp_result);
	BN_NUM_copy(temp_result,a_sub);
    }
    if(BN_NUM_cmp(a_sub,n)==0){
        BN_NUM_setzero(result);
	return 0;
    }
    while(BN_NUM_cmp(b_sub,n)==1){
        BN_NUM_sub(b_sub,n,temp_result);
        BN_NUM_copy(temp_result,b_sub);
    }
    if(BN_NUM_cmp(b_sub,n)==0){
        BN_NUM_setzero(result);
        return 0;
    }
    BN_NUM_inverse(n,d,l,n_inverse);
    BN_NUM_sub(zero,n_inverse,temp_result);
    BN_NUM_copy(temp_result,n_inverse);
    BN_WORD_copy(n_inverse->word[0],n0_inverse);
    BN_NUM_sub(zero,n,R_pro);
    BN_NUM_mul_mod_host(a_sub,R_pro,n,temp_result);
    BN_NUM_copy(temp_result,a_sub);
    BN_NUM_mul_mod_host(b_sub,R_pro,n,temp_result);
    BN_NUM_copy(temp_result,b_sub);
    parallel_mont_mul<<<1,d>>>(a_sub,b_sub,n,d,l,n0_inverse,temp_result,u,u_temp,v,m,c,v_temp,any_value);
    cudaDeviceSynchronize();
    parallel_mont_mul<<<1,d>>>(temp_result,one,n,d,l,n0_inverse,result,u,u_temp,v,m,c,v_temp,any_value);
    cudaDeviceSynchronize();
    cudaFree(any_value);
    BN_NUM_free(zero);
    BN_NUM_free(n_inverse);
    BN_NUM_free(temp_result);
    BN_NUM_free(u);
    BN_NUM_free(u_temp);
    BN_NUM_free(v_temp);
    BN_NUM_free(v);
    BN_NUM_free(m);
    BN_NUM_free(c);
    BN_NUM_free(a_sub);
    BN_NUM_free(b_sub);
    BN_WORD_free(n0_inverse);
    return 0;
}


__global__ void parallel_mont_mul(const BN_NUM *a,const BN_NUM *b,const BN_NUM *n,const int wmax,const int dmax,const BN_WORD *n0_inverse,
		BN_NUM *result, BN_NUM *u, BN_NUM *u_temp,BN_NUM *v, BN_NUM *m, BN_NUM *c,BN_NUM *v_temp, int *any_value){
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    BN_WORD_setzero(u->word[j]);
    BN_WORD_setzero(v->word[j]);
    __syncthreads();
    BN_WORD *temp_result, *zero,* one;
    BN_NUM  *bn_temp_result, *bn_temp_result2, *zero_num;
    temp_result=BN_WORD_new_device(dmax);
    zero=BN_WORD_new_device(dmax);
    one=BN_WORD_new_device(dmax);
    BN_WORD_setzero(zero);
    BN_WORD_setone(one);
    bn_temp_result=BN_NUM_new_device(wmax,dmax);
    bn_temp_result2=BN_NUM_new_device(wmax,dmax);
    zero_num=BN_NUM_new_device(wmax,dmax);
    BN_NUM_setzero(zero_num);
//need error_check
    
    for(int i=0;i<wmax;i++){
        mad_lo(a->word[j],b->word[i],v->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,u->word[j]);
	mul_lo(v->word[j],n0_inverse,m->word[j]);
	__syncthreads();
	//need synchronization
	BN_WORD_copy(m->word[0],m->word[j]);
	mad_lo(n->word[j],m->word[j],v->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,u->word[j]);
	BN_WORD_copy(v->word[j],v_temp->word[j]);
	__syncthreads();
	//need synchronization
	BN_WORD_copy(v_temp->word[int_mod(j+1,wmax)],v->word[j]);
	BN_WORD_add(u->word[j],v->word[j],temp_result);
	BN_WORD_copy(temp_result,v->word[j]);
	if(BN_WORD_cmp(u->word[j],v->word[j])==1){
	    BN_WORD_setone(u->word[j]);
	    v->word[j]->carry=0;
	}
	else {
	    BN_WORD_setzero(u->word[j]);
	    v->word[j]->carry=0;
	}
	mad_hi(a->word[j],b->word[i],v->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,u->word[j]);
	mad_hi(n->word[j],m->word[j],v->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,v->word[j]);
	BN_WORD_add(u->word[j],u_temp->word[j],temp_result);
	BN_WORD_copy(temp_result,u->word[j]);
	if(j==0){
	    printf("i:%d\n",i);
	    BN_NUM_print(v);
	}
    }
    
    BN_WORD_copy(u->word[j],c->word[j]);
    __syncthreads();
	__syncthreads();
    any_value[j]=any(u);
    __syncthreads();
    if(j==0){
            printf("c:");
            BN_NUM_print(c);
    }
    while(any_value[j]==0){
        BN_WORD_copy(u->word[int_mod(j-1,wmax)],u_temp->word[j]);
	__syncthreads();
	BN_WORD_copy(u_temp->word[j],u->word[j]);
	if(j==0){
	    BN_WORD_setzero(u->word[j]);
	}
	BN_WORD_add(u->word[j],v->word[j],temp_result);
	BN_WORD_copy(temp_result,v->word[j]);
        if((BN_WORD_cmp(u->word[j],v->word[j])==2)||(BN_WORD_cmp(u->word[j],v->word[j])==0)){
            BN_WORD_setzero(u->word[j]);
            v->word[j]->carry=0;
        }
        else {
            BN_WORD_setone(u->word[j]);
            v->word[j]->carry=0;
        }
	BN_WORD_add(c->word[j],u->word[j],temp_result);
	BN_WORD_copy(temp_result,c->word[j]);
	__syncthreads();
	any_value[j]=any(u);
    }
    
    BN_WORD_copy(v->word[j],result->word[j]);
    __syncthreads();
    //need sy
    BN_WORD_copy(c->word[wmax-1],c->word[j]);
    while(BN_WORD_cmp(c->word[j],zero)==1){
        while((BN_NUM_cmp(result,n)==1)||(BN_NUM_cmp(result,n)==0)){
	    BN_NUM_sub_device(result,n,bn_temp_result);
	    BN_NUM_copy(bn_temp_result,result);
	}
	BN_WORD_sub(c->word[j],one,temp_result);
	BN_WORD_copy(temp_result,c->word[j]);
	BN_NUM_sub_device(zero_num,n,bn_temp_result);
	BN_NUM_add_device(bn_temp_result,result,bn_temp_result2);
	BN_NUM_copy(bn_temp_result2,result);
    }
    while((BN_NUM_cmp(result,n)==1)||(BN_NUM_cmp(result,n)==0)){
        BN_NUM_sub_device(result,n,bn_temp_result);
        BN_NUM_copy(bn_temp_result,result);
    }
    if(j==0){
            printf("result:");
            BN_NUM_print(result);
    }
    BN_WORD_free_device(temp_result);
    BN_WORD_free_device(zero);
    BN_WORD_free_device(one);
    BN_NUM_free_device(bn_temp_result);
    BN_NUM_free_device(bn_temp_result2);
    BN_NUM_free_device(zero_num);
    
}
/*
__host__ int BN_NUM_R_inverse(const BN_NUM *n, BN_NUM *result){
    int wmax=n->wmax;
    int dmax=n->word[0]->dmax;
    int neg1=0, neg2=0, neg_temp=0;
    BN_NUM *R1, *R2, *temp_result, *mul_result,*zero, *one, *t1, *t2, *q;
    R1=BN_NUM_new(wmax,dmax);
    R2=BN_NUM_new(wmax,dmax);
    temp_result=BN_NUM_new(wmax,dmax);
    mul_result=BN_NUM_new(wmax,dmax);
    zero=BN_NUM_new(wmax,dmax);
    one=BN_NUM_new(wmax,dmax);
    t1=BN_NUM_new(wmax,dmax);
    t2=BN_NUM_new(wmax,dmax);
    q=BN_NUM_new(wmax,dmax);
    BN_NUM_copy(n,R1);
    BN_NUM_setzero(zero);
    BN_NUM_setone(one);
    BN_NUM_sub(zero,n,R2);
    while((BN_NUM_cmp(R2,n)==1)||BN_NUM_cmp(R2,n)==0){
        BN_NUM_sub(R2,n,temp_result);
        BN_NUM_copy(temp_result,R2);
    }
    printf("R1:\n");
    BN_NUM_print(R1);
    printf("R2:\n");
    BN_NUM_print(R2);
    BN_NUM_setzero(s2);
    BN_NUM_setone(t2);
    while(BN_NUM_cmp(R2,one)!=0){
        BN_NUM_div(R1,R2,q,temp_result);
        BN_NUM_copy(R2,R1);
        BN_NUM_copy(temp_result,R2);
        BN_NUM_mul(t2,q,mul_result);
        BN_NUM_sub(t1,mul_result,temp_result);
	if(BN_NUM_cmp(temp_result,t1)==1){
	    neg=0;
	}
        BN_NUM_copy(t2,t1);
        BN_NUM_copy(temp_result,t2);
    }
    BN_NUM_copy(t2,result);
    BN_NUM_sub(zero,n,R1);
    BN_NUM_mul_mod_host(R1,result,n,R2);
    BN_NUM_print(R2);
    return 0;
}
*/
__host__ int BN_NUM_mul_mod_host(const BN_NUM *a, const BN_NUM *b, const BN_NUM *n, BN_NUM *result){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int bit;
    BN_NUM *a_sub, *b_sub, *temp_result;
    a_sub=BN_NUM_new(wmax,dmax);
    b_sub=BN_NUM_new(wmax,dmax);
    temp_result=BN_NUM_new(wmax,dmax);
    BN_NUM_copy(a,a_sub);
    BN_NUM_copy(b,b_sub);
    while(BN_NUM_cmp(a_sub,n)==1){
        BN_NUM_sub(a_sub,n,temp_result);
        BN_NUM_copy(temp_result,a_sub);
    }
    if(BN_NUM_cmp(a_sub,n)==0){
        BN_NUM_setzero(result);
        return 0;
    }
    while(BN_NUM_cmp(b_sub,n)==1){
        BN_NUM_sub(b_sub,n,temp_result);
        BN_NUM_copy(temp_result,b_sub);
    }
    if(BN_NUM_cmp(b_sub,n)==0){
        BN_NUM_setzero(result);
        return 0;
    }
    BN_NUM_setzero(result);
    for(int i=wmax-1;i>=0;i--){
        for(int j=dmax-1;j>=0;j--){
            for(int k=sizeof(BN_ULONG)*8-1;k>=0;k--){
                bit=get_bit(b_sub->word[i]->d[j],k);
                BN_NUM_add(result,result,temp_result);
                if((BN_NUM_cmp(temp_result, result)==2)||(BN_NUM_cmp(temp_result,n)==1)||(BN_NUM_cmp(temp_result,n)==0)){
                    BN_NUM_sub(temp_result,n,result);
                }
                else {
                    BN_NUM_copy(temp_result,result);
                }
                if(bit==1){
                    BN_NUM_add(result,a_sub,temp_result);
                    if((BN_NUM_cmp(temp_result, result)==2)||(BN_NUM_cmp(temp_result,n)==1)
                                    ||(BN_NUM_cmp(temp_result,n)==0)){
                            BN_NUM_sub(temp_result,n,result);
                    }
                    else {
                            BN_NUM_copy(temp_result,result);
                    }
                }
            }
        }
    }
    return 0;
}


__host__ int BN_NUM_parallel_mont_exp(const BN_NUM *a, const BN_NUM *e, const BN_NUM *n,const int d,const int l,
                BN_NUM *result){
    int *any_value;
    BN_WORD *n0_inverse;
    BN_NUM *a_pro, *bn_temp, *R_pro, *zero, *one, *n_inverse, *u, *u_temp,*v,*m, *c,*v_temp;
    cudaMallocManaged((void **)&(any_value),d*sizeof(int));
    n0_inverse=BN_WORD_new(l);
    a_pro=BN_NUM_new(d,l);
    bn_temp=BN_NUM_new(d,l);
    R_pro=BN_NUM_new(d,l);
    zero=BN_NUM_new(d,l);
    one=BN_NUM_new(d,l);
    n_inverse=BN_NUM_new(d,l);
    u=BN_NUM_new(d,l);
    v=BN_NUM_new(d,l);
    m=BN_NUM_new(d,l);
    c=BN_NUM_new(d,l);
    u_temp=BN_NUM_new(d,l);
    v_temp=BN_NUM_new(d,l);
   // R_inverse=BN_NUM_new(d,l);
    BN_NUM_copy(a,a_pro);
    BN_NUM_setzero(zero);
    BN_NUM_setone(one);
    while(BN_NUM_cmp(a_pro,n)==1){
        BN_NUM_sub(a_pro,n,bn_temp);
        BN_NUM_copy(bn_temp,a_pro);
    }
    if(BN_NUM_cmp(a_pro,n)==0){
        BN_NUM_setzero(result);
        return 0;
    }
    BN_NUM_sub(zero,n,R_pro);
    BN_NUM_mul_mod_host(a_pro,R_pro,n,bn_temp);
    BN_NUM_copy(bn_temp,a_pro);
    BN_NUM_inverse(n,d,l,n_inverse);
    BN_NUM_sub(zero,n_inverse,bn_temp);
    BN_NUM_copy(bn_temp,n_inverse);
    BN_WORD_copy(n_inverse->word[0],n0_inverse);
    BN_NUM_copy(R_pro,result);

    for(int i=d-1;i>=0;i--){
        for(int j=l-1;j>=0;j--){
            for(int k=sizeof(BN_ULONG)*8-1;k>=0;k--){
                parallel_mont_mul<<<1,d>>>(result,result,n,d,l,n0_inverse,bn_temp,u,u_temp,v,m,c,v_temp, any_value);
                cudaDeviceSynchronize();
                BN_NUM_copy(bn_temp,result);
                if(get_bit(e->word[i]->d[j],k)==(BN_ULONG)1){
                    parallel_mont_mul<<<1,d>>>(result,a_pro,n,d,l,n0_inverse,bn_temp,u,u_temp,v,m,c,v_temp, any_value);
                    cudaDeviceSynchronize();
                    BN_NUM_copy(bn_temp,result);
//		    printf("result:\n");
//		    BN_NUM_print(result);
                }
            }
        }
    }
/*    BN_NUM_R_inverse(n,R_inverse);
    BN_NUM_mul_mod_host(result,R_inverse,n,bn_temp);
    BN_NUM_copy(bn_temp,result);
    */
    return 0;
}
