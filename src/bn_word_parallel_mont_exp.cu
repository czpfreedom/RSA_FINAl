#include "bn_word_parallel_mont_exp.h"
#include "stdio.h"
#include "iostream"

using namespace std;

#define CUDA_TIMING

#ifdef CUDA_TIMING
#include "sys/time.h"
#endif

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_ULONG n0_inverse, BN_WORD *result, 
		BN_WORD *u, BN_WORD *u_temp,BN_WORD *v, BN_WORD *m, BN_WORD *c,BN_WORD *v_temp, int *any_value){
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    int dmax=a->dmax;
    //branch need cal

    if(j==0){
	    BN_WORD_setzero(u);
	    BN_WORD_setzero(v);
	    BN_WORD_setzero(u_temp);
	    BN_WORD_setzero(v_temp);
	    BN_WORD_setzero(m);
	    BN_WORD_setzero(c);
    }
    __syncthreads();


    for(int i=0;i<dmax;i++){
        BN_WORD_mad_lo(a->d[j],b->d[i],v->d[j],u_temp->d[j],v->d[j]);
	u->d[j]=u_temp->d[j]+u->d[j];
        BN_WORD_mul_lo(v->d[j],n0_inverse,m->d[j]);
        __syncthreads();
        m->d[j]=m->d[0];
        BN_WORD_mad_lo(n->d[j],m->d[j],v->d[j],u_temp->d[j],v->d[j]);
	u->d[j]=u_temp->d[j]+u->d[j];
	v_temp->d[j]=v->d[j];
        __syncthreads();
	v->d[j]=v_temp->d[int_mod(j+1,dmax)];
	v->d[j]=u->d[j]+v->d[j];
	if(v->d[j]<u->d[j]){
	    u->d[j]=1;
	}
	else{
	    u->d[j]=0;
	}
        BN_WORD_mad_hi(a->d[j],b->d[i],v->d[j],u_temp->d[j],v->d[j]);
	u->d[j]=u_temp->d[j]+u->d[j];
        BN_WORD_mad_hi(n->d[j],m->d[j],v->d[j],u_temp->d[j],v->d[j]);
	u->d[j]=u_temp->d[j]+u->d[j];
	__syncthreads();
    }
    c->d[j]=u->d[j];
    __syncthreads();
    any_value[j]=BN_WORD_any(u);
    __syncthreads();
    while(any_value[j]==0){
	u_temp->d[j]=u->d[int_mod(j-1,dmax)];
        __syncthreads();
	u->d[j]=u_temp->d[j];
        if(j==0){
            u->d[j]=0;
        }
	v->d[j]=u->d[j]+v->d[j];
	if(v->d[j]<u->d[j]){
	    u->d[j]=1;
	}
	else{
	    u->d[j]=0;
	}
	c->d[j]=c->d[j]+u->d[j];
        __syncthreads();
        any_value[j]=BN_WORD_any(u);
    }
    BN_WORD_copy(v,result);
    c->d[j]=c->d[dmax-1];
    while(c->d[j]!=0){
        while((BN_WORD_cmp(result,n)==1)||(BN_WORD_cmp(result,n)==0)){
            BN_WORD_sub(result,n,result);
        }
	c->d[j]=c->d[j]-1;
        BN_WORD_sub(result,n,result);
    }
    while((BN_WORD_cmp(result,n)==1)||(BN_WORD_cmp(result,n)==0)){
        BN_WORD_sub(result,n,result);
    }
}


__host__ int BN_WORD_mul_mod_host(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;
    int bit;
    BN_WORD *a_sub, *b_sub, *temp_result;
    a_sub=BN_WORD_new(dmax);
    b_sub=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    BN_WORD_copy(a,a_sub);
    BN_WORD_copy(b,b_sub);
    while(BN_WORD_cmp(a_sub,n)==1){
        BN_WORD_sub(a_sub,n,a_sub);
    }
    if(BN_WORD_cmp(a_sub,n)==0){
        BN_WORD_setzero(result);
	return 0;
    }
    while(BN_WORD_cmp(b_sub,n)==1){
        BN_WORD_sub(b_sub,n,b_sub);
    }
    if(BN_WORD_cmp(b_sub,n)==0){
        BN_WORD_setzero(result);
        return 0;
    }
    BN_WORD_setzero(result);
    for(int i=dmax-1;i>=0;i--){
        for(int j=sizeof(BN_ULONG)*8-1;j>=0;j--){
		bit=get_bit(b_sub->d[i],j);
                BN_WORD_add(result,result,temp_result);
                if((BN_WORD_cmp(temp_result, result)==2)||(BN_WORD_cmp(temp_result,n)==1)||(BN_WORD_cmp(temp_result,n)==0)){
                    BN_WORD_sub(temp_result,n,result);
                }
                else {
                    BN_WORD_copy(temp_result,result);
                }
                if(bit==1){
                    BN_WORD_add(result,a_sub,temp_result);
                    if((BN_WORD_cmp(temp_result, result)==2)||(BN_WORD_cmp(temp_result,n)==1)||(BN_WORD_cmp(temp_result,n)==0)){
                            BN_WORD_sub(temp_result,n,result);
                    }
                    else {
                            BN_WORD_copy(temp_result,result);
                    }
                }
	}
    }
    BN_WORD_free(a_sub);
    BN_WORD_free(b_sub);
    BN_WORD_free(temp_result);
    return 0;
}

__host__ int BN_ULONG_inverse(const BN_ULONG n, BN_ULONG &n_inverse){
    BN_ULONG temp;
    BN_ULONG R1=n;
    BN_ULONG R2=0-n;
    BN_ULONG t1=1;
    BN_ULONG q=1+R2/R1;
    R2=R2%R1;
    BN_ULONG t2=0-q;
    while(R2!=1){
        temp=R2;
	q=R1/R2;
	R2=R1%R2;
	R1=temp;
	temp=t2;
	t2=t1-t2*q;
	t1=temp;
    }
    n_inverse=0-t2;
    return 0;
}

__host__ int BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result){

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

    int dmax=a->dmax;
    int *any_value;
    BN_ULONG n0_inverse;
    BN_WORD *a_pro, *b_pro, *temp_result, *u,*u_temp,*v,*v_temp,*m,*c,*one, *zero,*R_pro;
    cudaMallocManaged((void **)&(any_value),dmax*sizeof(int));
    a_pro=BN_WORD_new(dmax);
    b_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    u=BN_WORD_new(dmax);
    u_temp=BN_WORD_new(dmax);
    v=BN_WORD_new(dmax);
    v_temp=BN_WORD_new(dmax);
    m=BN_WORD_new(dmax);
    c=BN_WORD_new(dmax);
    one=BN_WORD_new(dmax);
    zero=BN_WORD_new(dmax);
    R_pro=BN_WORD_new(dmax);
    BN_WORD_setone(one);
    BN_WORD_setzero(zero);
    BN_WORD_copy(a,a_pro);
    BN_WORD_copy(b,b_pro);
    while(BN_WORD_cmp(a_pro,n)==1){
        BN_WORD_sub(a_pro,n,a_pro);
    }
    if(BN_WORD_cmp(a_pro,n)==0){
        BN_WORD_setzero(result);
        return 0;
    }
    while(BN_WORD_cmp(b_pro,n)==1){
        BN_WORD_sub(b_pro,n,b_pro);
    }
    if(BN_WORD_cmp(b_pro,n)==0){
        BN_WORD_setzero(result);
        return 0;
    }
    BN_WORD_sub(zero,n,R_pro);
    while(BN_WORD_cmp(R_pro,n)==1){
        BN_WORD_sub(R_pro,n,R_pro);
    }
    BN_WORD_mul_mod_host(a_pro,R_pro,n,temp_result);//
    BN_WORD_copy(temp_result,a_pro);
    BN_WORD_mul_mod_host(b_pro,R_pro,n,temp_result);
    BN_WORD_copy(temp_result,b_pro);
    BN_ULONG_inverse(n->d[0],n0_inverse);//

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    BN_WORD_parallel_mont_mul<<<1,dmax>>>(a_pro,b_pro,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c, any_value);
    cudaDeviceSynchronize();

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"parallel_time: "<<sum_time<<endl;
#endif
    
    BN_WORD_copy(temp_result,result);
    BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,one,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c, any_value);
    cudaDeviceSynchronize();
    BN_WORD_copy(temp_result,result);
    return 0;

}


__host__ int BN_WORD_parallel_mont_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;

#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
#endif

    int *any_value;
    BN_ULONG n0_inverse;
    BN_WORD *a_pro, *temp_result,*u,*u_temp,*v,*v_temp,*m,*c,*one, *zero,*R_pro;
    cudaMallocManaged((void **)&(any_value),dmax*sizeof(int));
    a_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    u=BN_WORD_new(dmax);
    u_temp=BN_WORD_new(dmax);
    v=BN_WORD_new(dmax);
    v_temp=BN_WORD_new(dmax);
    m=BN_WORD_new(dmax);
    c=BN_WORD_new(dmax);
    one=BN_WORD_new(dmax);
    zero=BN_WORD_new(dmax);
    R_pro=BN_WORD_new(dmax);
    BN_WORD_setone(one);
    BN_WORD_setzero(zero);
    BN_WORD_copy(a,a_pro);
    while(BN_WORD_cmp(a_pro,n)==1){
        BN_WORD_sub(a_pro,n,a_pro);
    }
    if(BN_WORD_cmp(a_pro,n)==0){
        BN_WORD_setzero(result);
	return 0;
    }
    BN_WORD_sub(zero,n,R_pro);
    while(BN_WORD_cmp(R_pro,n)==1){
        BN_WORD_sub(R_pro,n,R_pro);
    }
    BN_WORD_mul_mod_host(a_pro,R_pro,n,temp_result);//
    BN_WORD_copy(temp_result,a_pro);
    BN_ULONG_inverse(n->d[0],n0_inverse);//
    BN_WORD_copy(R_pro,result);

#ifdef CUDA_TIMING
    gettimeofday(&start,0);
#endif

    for(int i=dmax-1;i>=0;i--){
        for(int j=sizeof(BN_ULONG)*8-1;j>=0;j--){
	     BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,result,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c, any_value);
	     cudaDeviceSynchronize();
	     BN_WORD_copy(temp_result,result);
	     if(get_bit(e->d[i],j)==(BN_ULONG)1){
		 BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,a_pro,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c, any_value);
		 cudaDeviceSynchronize();       
		 BN_WORD_copy(temp_result,result);
	     }
	}
    }
    BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,one,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c, any_value);
    cudaDeviceSynchronize();
    BN_WORD_copy(temp_result,result);

#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"parallel_time: "<<sum_time<<endl;
#endif

    return 0;
}
