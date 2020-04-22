#include "bn_word_parallel_mont_exp.h"
#include "stdio.h"
#include "iostream"
#include "time.h"
#include "sys/time.h"

using namespace std;

#define LOOP_NUM 1

//#define notemp

#define SHARE

#define CUDA_TIMING

#define HZ_PER_US (double)1

#ifdef SHARE
#define U 0
#define V dmax
#define M dmax*2
#define C dmax*3
#endif

#ifdef notemp

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_ULONG n0_inverse, BN_WORD *result, 
		BN_WORD *u, BN_WORD *v, BN_WORD *m, BN_WORD *c){
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    BN_ULONG p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;
    int dmax=a->dmax;
    //branch need cal

#ifdef CUDA_TIMING
    clock_t start_t, start_loop_t,start_deletecarry_t, start_deleteu_t, end_setzero_t, end_total_t,end_loop_t, end_deletecarry_t, end_deleteu_t;
    double total_t;
#endif

#ifdef CUDA_TIMING
    start_t=clock();
#endif
    p_a=a->d[j];
    p_n=n->d[j];
    p_u=0;
    p_v=0;
    m->d[j]=0;
    c->d[j]=0;

    __syncthreads();


#ifdef CUDA_TIMING
    end_setzero_t=clock();
    total_t=(end_setzero_t-start_t)/HZ_PER_US;
    if(j==0){
        printf("setzero_time:%f\n",total_t);
    }
#endif

#ifdef CUDA_TIMING
    start_loop_t=clock();
#endif
    
    for(int i=0;i<dmax;i++){
	p_b=b->d[i];
        BN_WORD_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
        BN_WORD_mul_lo(p_v,n0_inverse,m->d[j]);
        __syncthreads();
	p_m=m->d[0];
        BN_WORD_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	v->d[j]=p_v;
        __syncthreads();
	p_v=v->d[int_mod(j+1,dmax)];
	p_v=p_u+p_v;
	if(p_v<p_u){
	    p_u=1;
	}
	else{
	    p_u=0;
	}
        BN_WORD_mad_hi(p_a,p_b,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
        BN_WORD_mad_hi(p_n,p_m,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	__syncthreads();
    }

#ifdef CUDA_TIMING
    end_loop_t=clock();
    total_t=(end_loop_t-start_loop_t)/HZ_PER_US;
    if(j==0){
        printf("loop_time:%f\n",total_t);
    }
#endif
#ifdef CUDA_TIMING
    start_deleteu_t=clock();
#endif

    c->d[j]=p_u;
    u->d[j]=p_u;
    __syncthreads();
    while(BN_WORD_any(u,dmax)==0){
	u->d[j]=p_u;
        __syncthreads();
	p_u=u->d[int_mod(j-1,dmax)];
        if(j==0){
            p_u=0;
        }
	p_v=p_u+p_v;
	if(p_v<p_u){
	    p_u=1;
	}
	else{
	    p_u=0;
	}
	c->d[j]=c->d[j]+p_u;
        __syncthreads();
	u->d[j]=p_u;
    }
    result->d[j]=p_v;
    c->d[j]=c->d[dmax-1];
#ifdef CUDA_TIMING
    end_deleteu_t=clock();
    total_t=(end_deleteu_t-start_deleteu_t)/HZ_PER_US;
    if(j==0){
        printf("deleteu_time:%f\n",total_t);
    }
#endif
#ifdef CUDA_TIMING
    start_deletecarry_t=clock();
#endif

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
#ifdef CUDA_TIMING
    end_deletecarry_t=clock();
    total_t=(end_deletecarry_t-start_deletecarry_t)/HZ_PER_US;
    if(j==0){
        printf("deletecarry_time:%f\n",total_t);
    }
#endif    
#ifdef CUDA_TIMING
    end_total_t=clock();
    total_t=(end_total_t-start_t)/HZ_PER_US;
    if(j==0){
        printf("total_time:%f\n",total_t);
    }
#endif

}

#endif


#ifdef SHARE

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_ULONG n0_inverse, BN_WORD *result){
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    BN_ULONG p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;
    int dmax=a->dmax;
    extern __shared__ BN_ULONG host_temp[];
    BN_ULONG* temp = (BN_ULONG*)host_temp;
    //branch need cal

#ifdef CUDA_TIMING
    clock_t start_t, start_loop_t,start_deletecarry_t, start_deleteu_t, end_setzero_t, end_total_t,end_loop_t, end_deletecarry_t, end_deleteu_t;
    double total_t;
#endif

#ifdef CUDA_TIMING
    start_t=clock();
#endif
    p_a=a->d[j];
    p_n=n->d[j];
    p_u=0;
    p_v=0;
    temp[M+j]=0;
    temp[C+j]=0;

    __syncthreads();


#ifdef CUDA_TIMING
    end_setzero_t=clock();
    total_t=(end_setzero_t-start_t)/HZ_PER_US;
    if(j==0){
        printf("setzero_time:%f\n",total_t);
    }
#endif

#ifdef CUDA_TIMING
    start_loop_t=clock();
#endif
    
    for(int i=0;i<dmax;i++){
	p_b=b->d[i];
        BN_WORD_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
        BN_WORD_mul_lo(p_v,n0_inverse,temp[M+j]);
        __syncthreads();
	p_m=temp[M+0];
        BN_WORD_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	temp[V+j]=p_v;
        __syncthreads();
	p_v=temp[V+int_mod(j+1,dmax)];
	p_v=p_u+p_v;
	if(p_v<p_u){
	    p_u=1;
	}
	else{
	    p_u=0;
	}
        BN_WORD_mad_hi(p_a,p_b,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
        BN_WORD_mad_hi(p_n,p_m,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	__syncthreads();
    }

#ifdef CUDA_TIMING
    end_loop_t=clock();
    total_t=(end_loop_t-start_loop_t)/HZ_PER_US;
    if(j==0){
        printf("loop_time:%f\n",total_t);
    }
#endif
#ifdef CUDA_TIMING
    start_deleteu_t=clock();
#endif

    temp[C+j]=p_u;
    temp[U+j]=p_u;
    __syncthreads();//
    while(BN_WORD_any(temp+U,dmax)==0){
	p_u=temp[U+int_mod(j-1,dmax)];
        if(j==0){
            p_u=0;
        }
	p_v=p_u+p_v;
	if(p_v<p_u){
	    p_u=1;
	}
	else{
	    p_u=0;
	}
	temp[C+j]=temp[C+j]+p_u;
        __syncthreads();
	temp[U+j]=p_u;
	__syncthreads();
    }
    result->d[j]=p_v;
    temp[C+j]=temp[C+dmax-1];
#ifdef CUDA_TIMING
    end_deleteu_t=clock();
    total_t=(end_deleteu_t-start_deleteu_t)/HZ_PER_US;
    if(j==0){
        printf("deleteu_time:%f\n",total_t);
    }
#endif
#ifdef CUDA_TIMING
    start_deletecarry_t=clock();
#endif

    while(temp[C+j]!=0){
        while((BN_WORD_cmp(result,n)==1)||(BN_WORD_cmp(result,n)==0)){
            BN_WORD_sub(result,n,result);
        }
	temp[C+j]=temp[C+j]-1;
        BN_WORD_sub(result,n,result);
    }
    while((BN_WORD_cmp(result,n)==1)||(BN_WORD_cmp(result,n)==0)){
        BN_WORD_sub(result,n,result);
    }
#ifdef CUDA_TIMING
    end_deletecarry_t=clock();
    total_t=(end_deletecarry_t-start_deletecarry_t)/HZ_PER_US;
    if(j==0){
        printf("deletecarry_time:%f\n",total_t);
    }
#endif    
#ifdef CUDA_TIMING
    end_total_t=clock();
    total_t=(end_total_t-start_t)/HZ_PER_US;
    if(j==0){
        printf("total_time:%f\n",total_t);
    }
#endif

}

#endif

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

#ifdef notemp

__host__ int BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result){

//#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
  //  clock_t start_t, end_t;
  //  double total_t;

//#endif

    int dmax=a->dmax;
    BN_ULONG n0_inverse;
    BN_WORD *a_pro, *b_pro, *temp_result, *u,*v,*m,*c,*one, *zero,*R_pro;
    a_pro=BN_WORD_new(dmax);
    b_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    u=BN_WORD_new(dmax);
    v=BN_WORD_new(dmax);
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

//#ifdef CUDA_TIMING
    gettimeofday(&start,0);
  //  start_t=clock();

//#endif

    BN_WORD_parallel_mont_mul<<<1,dmax>>>(a_pro,b_pro,n,n0_inverse,temp_result, u, v, m, c);
    cudaDeviceSynchronize();

//#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
  //  end_t=clock();
//    total_t=(end_t-start_t);
 //   printf("clock_parallel_time:%f\n",total_t);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"parallel_time: "<<sum_time<<endl;
//#endif
    
    BN_WORD_copy(temp_result,result);
    BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,one,n,n0_inverse,temp_result, u, v, m, c);
    cudaDeviceSynchronize();
    BN_WORD_copy(temp_result,result);
    return 0;

}

#endif


#ifdef SHARE

__host__ int BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result){

//#ifdef CUDA_TIMING
    timeval start, stop;
    double sum_time;
  //  clock_t start_t, end_t;
  //  double total_t;

//#endif

    int dmax=a->dmax;
    BN_ULONG n0_inverse;
    BN_WORD *a_pro, *b_pro, *temp_result, *zero, *one, *R_pro;
    a_pro=BN_WORD_new(dmax);
    b_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
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

//#ifdef CUDA_TIMING
    gettimeofday(&start,0);
  //  start_t=clock();

//#endif

    BN_WORD_parallel_mont_mul<<<1,dmax,4*dmax*sizeof(BN_ULONG)>>>(a_pro,b_pro,n,n0_inverse,temp_result);
    cudaDeviceSynchronize();

//#ifdef CUDA_TIMING
    gettimeofday(&stop,0);
  //  end_t=clock();
//    total_t=(end_t-start_t);
 //   printf("clock_parallel_time:%f\n",total_t);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"parallel_time: "<<sum_time<<endl;
//#endif
    
    BN_WORD_copy(temp_result,result);
    BN_WORD_parallel_mont_mul<<<1,dmax,4*dmax*sizeof(BN_ULONG)>>>(result,one,n,n0_inverse,temp_result);
    cudaDeviceSynchronize();
    BN_WORD_copy(temp_result,result);
    return 0;

}

#endif


/*
__host__ int BN_WORD_parallel_mont_exp(const BN_WORD *a, const BN_WORD *e, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;
//time
    timeval start, stop;
    double sum_time;

    BN_ULONG n0_inverse;
    BN_WORD *a_pro, *temp_result,*u,*u_temp,*v,*v_temp,*m,*c,*one, *zero,*R_pro;
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
//time
    gettimeofday(&start,0);

    for(int i=dmax-1;i>=0;i--){
        for(int j=sizeof(BN_ULONG)*8-1;j>=0;j--){
	     BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,result,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c);
	     cudaDeviceSynchronize();
	     BN_WORD_copy(temp_result,result);
	     if(get_bit(e->d[i],j)==(BN_ULONG)1){
		 BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,a_pro,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c);
		 cudaDeviceSynchronize();       
		 BN_WORD_copy(temp_result,result);
	     }
	}
    }
    BN_WORD_parallel_mont_mul<<<1,dmax>>>(result,one,n,n0_inverse,temp_result, u, u_temp, v, v_temp, m, c);
    cudaDeviceSynchronize();
    BN_WORD_copy(temp_result,result);
//time
    gettimeofday(&stop,0);
    sum_time = 1000000*(stop.tv_sec - start.tv_sec) + stop.tv_usec - start.tv_usec;
    cout<<"parallel_time: "<<sum_time<<endl;

    return 0;
}

*/
