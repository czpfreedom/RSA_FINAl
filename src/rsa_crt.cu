#include "rsa_crt.h"
#include "stdio.h"

__global__ void BN_WORD_parallel_Mon(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_PART n0_inverse, BN_WORD *result){
    
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    BN_PART p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;
    int dmax=a->dmax;

    __shared__  BN_PART M[SHARED_SIZE];
    __shared__  BN_PART C[SHARED_SIZE];
    __shared__  BN_PART U[SHARED_SIZE];
    __shared__  BN_PART V[SHARED_SIZE];
    __shared__  BN_PART A[SHARED_SIZE];
    __shared__  BN_PART B[SHARED_SIZE];
    __shared__  BN_PART N[SHARED_SIZE];

    if(j==0){
	for(int i=0; i<dmax;i++){
	    A[i]=a->d[i];
	    B[i]=b->d[i];
	    N[i]=n->d[i];
	}
    }

    __syncthreads();

    p_a=A[j];
    p_n=N[j];
    p_u=0;
    p_v=0;
    M[j]=0;
    C[j]=0;

    for(int i=0;i<dmax;i++){
        p_b=B[i];
        BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mul_lo(p_v,n0_inverse,M[j]);
        __syncthreads();
        p_m=M[0];
        BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
	V[j]=p_v;
        __syncthreads();
	p_v=V[int_mod(j+1,dmax)];
        p_v=p_u+p_v;
        if(p_v<p_u){
            p_u=1;
        }
        else{
            p_u=0;
        }
        BN_PART_mad_hi(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mad_hi(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
    }
    C[j]=p_u;
    U[j]=p_u;
    __syncthreads();//
    while(BN_PART_any(U,dmax)==0){
	p_u=U[int_mod(j-1,dmax)];
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
	C[j]=C[j]+p_u;
	U[j]=p_u;
        __syncthreads();
    }
    result->d[j]=p_v;
    C[j]=C[dmax-1];
    if(j==0){
        while(C[j]!=0){
	    BN_WORD_mod_device(result,n,result);
	    C[j]=C[j]-1;
    	    BN_WORD_sub(result,n,result);
    	}
	BN_WORD_mod_device(result,n,result);
    }

}

__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, const BN_WORD *one, const BN_PART n0_inverse, BN_WORD *result){
    int j=threadIdx.x+blockIdx.x*blockDim.x;
    BN_PART p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;
    int dmax=a->dmax;

    __shared__  BN_PART M[SHARED_SIZE];
    __shared__  BN_PART C[SHARED_SIZE];
    __shared__  BN_PART U[SHARED_SIZE];
    __shared__  BN_PART V[SHARED_SIZE];
    __shared__  BN_PART A[SHARED_SIZE];
    __shared__  BN_PART B[SHARED_SIZE];
    __shared__  BN_PART N[SHARED_SIZE];

    if(j==0){
	for(int i=0; i<dmax;i++){
	    A[i]=a->d[i];
	    B[i]=b->d[i];
	    N[i]=n->d[i];
	}
    }

    __syncthreads();

    // Montgomery 
    p_a=A[j];
    p_n=N[j];
    p_u=0;
    p_v=0;
    M[j]=0;
    C[j]=0;

    for(int i=0;i<dmax;i++){
        p_b=B[i];
        BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mul_lo(p_v,n0_inverse,M[j]);
        __syncthreads();
        p_m=M[0];
        BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
	V[j]=p_v;
        __syncthreads();
	p_v=V[int_mod(j+1,dmax)];
        p_v=p_u+p_v;
        if(p_v<p_u){
            p_u=1;
        }
        else{
            p_u=0;
        }
        BN_PART_mad_hi(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mad_hi(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
    }
    C[j]=p_u;
    U[j]=p_u;
    __syncthreads();//
    while(BN_PART_any(U,dmax)==0){
	p_u=U[int_mod(j-1,dmax)];
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
	C[j]=C[j]+p_u;
	U[j]=p_u;
        __syncthreads();
    }
    result->d[j]=p_v;
    C[j]=C[dmax-1];
    if(j==0){
        while(C[j]!=0){
	    BN_WORD_mod_device(result,n,result);
	    C[j]=C[j]-1;
    	    BN_WORD_sub(result,n,result);
    	}
	BN_WORD_mod_device(result,n,result);
    }

// Montgomery Reduce
    if(j==0){
        for(int i=0; i<dmax;i++){
            A[i]=result->d[i];
            B[i]=one->d[i];
        }
    }

    __syncthreads();
    
    p_a=A[j];
    p_n=n->d[j];
    p_u=0;
    p_v=0;
    M[j]=0;
    C[j]=0;

    for(int i=0;i<dmax;i++){
        p_b=B[i];
        BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mul_lo(p_v,n0_inverse,M[j]);
        __syncthreads();
        p_m=M[0];
        BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
	V[j]=p_v;
        __syncthreads();
	p_v=V[int_mod(j+1,dmax)];
        p_v=p_u+p_v;
        if(p_v<p_u){
            p_u=1;
        }
        else{
            p_u=0;
        }
        BN_PART_mad_hi(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mad_hi(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
    }
    C[j]=p_u;
    U[j]=p_u;
    __syncthreads();//
    while(BN_PART_any(U,dmax)==0){
	p_u=U[int_mod(j-1,dmax)];
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
	C[j]=C[j]+p_u;
	U[j]=p_u;
        __syncthreads();
    }
    result->d[j]=p_v;
    C[j]=C[dmax-1];
    if(j==0){
        while(C[j]!=0){
	    BN_WORD_mod_device(result,n,result);
	    C[j]=C[j]-1;
    	    BN_WORD_sub(result,n,result);
    	}
	BN_WORD_mod_device(result,n,result);
    }

}
/*
__global__ void BN_WORD_parallel_mont_mul(const BN_WORD *square_1, const BN_WORD *square_2, const BN_WORD *result2, const BN_WORD *e, const BN_WORD *n, const BN_WORD *one, const BN_PART n0_inverse, BN_WORD *result){
    int dmax=square_1->dmax;
    int thread_id=threadIdx.x+blockIdx.x*blockDim.x;
    int j= thread_id%dmax;
    BN_PART e_i;
    BN_PART p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;

    __shared__  BN_PART M1[SHARED_SIZE];
    __shared__  BN_PART C1[SHARED_SIZE];
    __shared__  BN_PART U1[SHARED_SIZE];
    __shared__  BN_PART V1[SHARED_SIZE];
    __shared__  BN_PART M2[SHARED_SIZE];
    __shared__  BN_PART C2[SHARED_SIZE];
    __shared__  BN_PART U2[SHARED_SIZE];
    __shared__  BN_PART V2[SHARED_SIZE];

    for(int i=0; i<dmax*sizeof(BN_PART)*8;i++){
        e_i = bn_word_get_bit(e,i);
	if(thread_id<dmax){
	
	else {
	
	}

    }
}
*/


CRT_N ::CRT_N (RSA_N *rsa_n){

    m_rsa_n = rsa_n;
    int dmax = m_rsa_n->n->dmax;
    m_zero=BN_WORD_new(dmax);
    m_one=BN_WORD_new(dmax);
    m_R=BN_WORD_new(dmax);
    BN_WORD_setzero(m_zero);
    BN_WORD_setone(m_one);
    BN_WORD_sub(m_zero,m_rsa_n->n,m_R);

    BN_PART_inverse(m_rsa_n->n->d[0], 0, m_n0_inverse);
    m_n0_inverse=0-m_n0_inverse;

}

CRT_N :: ~CRT_N (){
    BN_WORD_free(m_zero);
    BN_WORD_free(m_R);

}

int CRT_N :: CRT_MUL_MOD(BN_WORD *a, BN_WORD *b, BN_WORD *result){
    int dmax = a->dmax;
    BN_WORD *a_pro, *b_pro, *temp_result;
    
    a_pro=BN_WORD_new(dmax);
    b_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    BN_WORD_mod(a,m_rsa_n->n,a_pro);
    BN_WORD_mod(b,m_rsa_n->n,b_pro);
    
    
    BN_WORD_mul_mod(a_pro,m_R,m_rsa_n->n,temp_result);
    BN_WORD_copy(temp_result,a_pro);
    BN_WORD_mul_mod(b_pro,m_R,m_rsa_n->n,temp_result);
    BN_WORD_copy(temp_result,b_pro);
    BN_WORD_parallel_Mon<<<1,dmax>>>(a_pro, b_pro, m_rsa_n->n,m_n0_inverse, result);
    cudaDeviceSynchronize();
    BN_WORD_parallel_Mon<<<1,dmax>>>(result,m_one, m_rsa_n->n,m_n0_inverse, result);
    cudaDeviceSynchronize();
    BN_WORD_free(a_pro);
    BN_WORD_free(b_pro);
    BN_WORD_free(temp_result);
    return 0;
}

int CRT_N :: CRT_EXP_MOD(BN_WORD *a, BN_WORD *e, BN_WORD *result){
    
    int dmax = a->dmax;
    BN_WORD *a_pro, *temp_result;
    a_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);

    BN_WORD_mod(a,m_rsa_n->n,a_pro);
    BN_WORD_mul_mod(a_pro,m_R,m_rsa_n->n,temp_result);
    BN_WORD_copy(temp_result,a_pro);
    BN_WORD_copy(m_R,result);


    for(int i=dmax-1; i>=0;i--){
        for(int j=sizeof(BN_PART)*8-1;j>=0;j--){
	    BN_WORD_parallel_Mon<<<1,dmax>>>(result, result, m_rsa_n->n,m_n0_inverse, result); 
	    cudaDeviceSynchronize();
	    if(BN_PART_get_bit(e->d[i],j)==1){
                BN_WORD_parallel_Mon<<<1,dmax>>>(result, a_pro, m_rsa_n->n,m_n0_inverse, result);
		cudaDeviceSynchronize();
	    }
	}
    }

    BN_WORD_parallel_Mon<<<1,dmax>>>(result,m_one, m_rsa_n->n,m_n0_inverse, result);
    cudaDeviceSynchronize();
    BN_WORD_free(a_pro);
    BN_WORD_free(temp_result);
    return 0;

}
