#include "rsa_crt.h"
#include "rsa_final.h"
#include "stdlib.h"
#include "string.h"

namespace namespace_rsa_final{

__device__ int  GPU_WORD_parallel_Mon(BN_PART *A, BN_PART *B, BN_PART *N, BN_PART n0_inverse, BN_PART *M, BN_PART *U, BN_PART *V, BN_PART *C, BN_PART *result, int thread_id){
    BN_PART p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;
    p_a=A[thread_id];
    p_n=N[thread_id];
    p_u=0;
    p_v=0;
    M[thread_id]=0;
    C[thread_id]=0;

    for(int i=0;i<WARP_SIZE;i++){
        p_b=B[i];
        BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        BN_PART_mul_lo(p_v,n0_inverse,M[thread_id]);
        p_m=M[0];
        BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        V[thread_id]=p_v;
        p_v=V[int_mod(thread_id+1,WARP_SIZE)];
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
    C[thread_id]=p_u;
    U[thread_id]=p_u;
    while(BN_PART_any(U,WARP_SIZE)==0){
        p_u=U[int_mod(thread_id-1,WARP_SIZE)];
        if(thread_id==0){
            p_u=0;
	}
        p_v=p_u+p_v;
        if(p_v<p_u){
            p_u=1;
        }
        else{
            p_u=0;
        }
        C[thread_id]=C[thread_id]+p_u;
        U[thread_id]=p_u;
    }
    result[thread_id]=p_v;

    return 1;
};

__device__ int GPU_WORD_delete_carry(BN_PART *result, BN_PART *N, BN_PART c){
    GPU_WORD gw_result, gw_n;
    gw_result.setzero();
    gw_n.setzero();
    for(int i=0;i<WARP_SIZE;i++){
        gw_result.m_data[i]=result[i];
        gw_n.m_data[i]=N[i];
    }
    gw_result.m_data[WARP_SIZE]=c;
    gw_result.m_top=WARP_SIZE+1;
    gw_n.m_top=WARP_SIZE;
    gw_result.check_top();
    gw_result=gw_result%gw_n;
    for(int i=0;i<WARP_SIZE;i++){
        result[i]=gw_result.m_data[i];
    }
    return 1;
}	

__global__ void  GPU_WORD_mod_mul(BN_PART *A, BN_PART *B, BN_PART *N, BN_PART n0_inverse, BN_PART *result){
   int j=threadIdx.x;

   __shared__ BN_PART M[WARP_SIZE];
   __shared__ BN_PART U[WARP_SIZE];
   __shared__ BN_PART V[WARP_SIZE];
   __shared__ BN_PART C[WARP_SIZE];

   __shared__ BN_PART ONE[WARP_SIZE];
   ONE[j]=0;
   ONE[0]=1;

   GPU_WORD_parallel_Mon(A,B,N,n0_inverse,M,U,V,C,result,j);

   if(j==WARP_SIZE-1){
       GPU_WORD_delete_carry(result, N, C[j]);
   }
   __syncthreads();

   GPU_WORD_parallel_Mon(result,ONE,N,n0_inverse,M,U,V,C,result,j);

   if(j==WARP_SIZE-1){
       GPU_WORD_delete_carry(result, N, C[j]);
   }
   __syncthreads();

}

__global__ void GPU_WORD_mod_exp( BN_PART *A, BN_PART *E , int E_bits, BN_PART *mR, BN_PART *N , BN_PART n0_inverse, BN_PART *result){

    int i=threadIdx.x/WARP_SIZE;
    int j=threadIdx.x%WARP_SIZE;

    __shared__ BN_PART M1[WARP_SIZE];
    __shared__ BN_PART U1[WARP_SIZE];
    __shared__ BN_PART V1[WARP_SIZE];
    __shared__ BN_PART C1[WARP_SIZE];

    __shared__ BN_PART M2[WARP_SIZE];
    __shared__ BN_PART U2[WARP_SIZE];
    __shared__ BN_PART V2[WARP_SIZE];
    __shared__ BN_PART C2[WARP_SIZE];

    __shared__ BN_PART R[WARP_SIZE];
    __shared__ BN_PART ONE[WARP_SIZE];
    __shared__ BN_PART S1[WARP_SIZE];
    __shared__ BN_PART S2[WARP_SIZE];
    __shared__ BN_PART S3[WARP_SIZE];

    __shared__ BN_PART R2[WARP_SIZE];

    int k,k_i,k_j;
   
    if(i==0){
        ONE[j]=0;
 	ONE[0]=1;   
    }
    else{
        R[j]=mR[j];
    }

    __syncthreads();

    if(i==0){
        S1[j]=A[j];
    }
    else{
        S2[j]=A[j];
    }

    __syncthreads();

   
    for(k=0;k<E_bits; k++){
        k_i=k/(sizeof(BN_PART)*8);
        k_j=k%(sizeof(BN_PART)*8);
        if(i==0){
	    GPU_WORD_parallel_Mon(R,S1,N,n0_inverse,M1,U1,V1,C1,R2,j);
 	}
 	else{
 	    GPU_WORD_parallel_Mon(S2,S2,N,n0_inverse,M2,U2,V2,C2,S3,j);
 	}
 	__syncthreads();   
 	if(i==0){
 	    if(j==WARP_SIZE-1){
 	        GPU_WORD_delete_carry(R2, N, C1[j]);
	    }
 	}
 	else{
 	    if(j==WARP_SIZE-1){
 	        GPU_WORD_delete_carry(S3, N, C2[j]);
	    }       
 	}
 	__syncthreads();
 	if(i==0){
            if(BN_PART_get_bit(E[k_i],k_j)==1){
     	        R[j]=R2[j];
 	    }
 	}
 	else{
            S2[j]=S3[j];
 	}
 	__syncthreads();   
	S1[j]=S2[j];
	__syncthreads();   
    }

    if(i==0){
        GPU_WORD_parallel_Mon(R,ONE,N,n0_inverse,M1,U1,V1,C1,R2,j);
        if(j==WARP_SIZE-1){
	    GPU_WORD_delete_carry(R2, N, C1[j]);
 	}
	result[j]=R2[j];
    }
}

__global__ void GPU_WORD_ARRAY_mod_exp( BN_PART *A, BN_PART *E , int E_bits, BN_PART *mR, BN_PART *N , BN_PART n0_inverse, BN_PART *result){

    int bid=blockIdx.x;
    int i=threadIdx.x/WARP_SIZE;
    int j=threadIdx.x%WARP_SIZE;

    __shared__ BN_PART M1[WARP_SIZE];
    __shared__ BN_PART U1[WARP_SIZE];
    __shared__ BN_PART V1[WARP_SIZE];
    __shared__ BN_PART C1[WARP_SIZE];

    __shared__ BN_PART M2[WARP_SIZE];
    __shared__ BN_PART U2[WARP_SIZE];
    __shared__ BN_PART V2[WARP_SIZE];
    __shared__ BN_PART C2[WARP_SIZE];

    __shared__ BN_PART R[WARP_SIZE];
    __shared__ BN_PART ONE[WARP_SIZE];
    __shared__ BN_PART S1[WARP_SIZE];
    __shared__ BN_PART S2[WARP_SIZE];
    __shared__ BN_PART S3[WARP_SIZE];

    __shared__ BN_PART R2[WARP_SIZE];

    int k,k_i,k_j;
   
    if(i==0){
        ONE[j]=0;
 	ONE[0]=1;   
    }
    else{
        R[j]=mR[j];
    }

    __syncthreads();

    if(i==0){
        S1[j]=A[bid*WARP_SIZE+j];
    }
    else{
        S2[j]=A[bid*WARP_SIZE+j];
    }

    __syncthreads();

   
    for(k=0;k<E_bits; k++){
        k_i=k/(sizeof(BN_PART)*8);
        k_j=k%(sizeof(BN_PART)*8);
        if(i==0){
	    GPU_WORD_parallel_Mon(R,S1,N,n0_inverse,M1,U1,V1,C1,R2,j);
 	}
 	else{
 	    GPU_WORD_parallel_Mon(S2,S2,N,n0_inverse,M2,U2,V2,C2,S3,j);
 	}
 	__syncthreads();   
 	if(i==0){
 	    if(j==WARP_SIZE-1){
 	        GPU_WORD_delete_carry(R2, N, C1[j]);
	    }
 	}
 	else{
 	    if(j==WARP_SIZE-1){
 	        GPU_WORD_delete_carry(S3, N, C2[j]);
	    }       
 	}
 	__syncthreads();
 	if(i==0){
            if(BN_PART_get_bit(E[k_i],k_j)==1){
     	        R[j]=R2[j];
 	    }
 	}
 	else{
            S2[j]=S3[j];
 	}
 	__syncthreads();   
	S1[j]=S2[j];
	__syncthreads();   
    }

    if(i==0){
        GPU_WORD_parallel_Mon(R,ONE,N,n0_inverse,M1,U1,V1,C1,R2,j);
        if(j==WARP_SIZE-1){
	    GPU_WORD_delete_carry(R2, N, C1[j]);
 	}
        result[bid*WARP_SIZE+j]=R2[j];
    }

}



}
