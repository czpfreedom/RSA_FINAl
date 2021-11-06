#include "rsa_crt.h"
#include "rsa_final.h"
#include "stdlib.h"
#include "string.h"

namespace namespace_rsa_final{

CRT_N :: CRT_N(){

}

CRT_N :: CRT_N (RSA_N rsa_n){
    m_rsa_n=rsa_n;
    m_zero.setzero();
    m_one.setone();
    m_R.setR();
    BN_PART_mod_inverse(m_rsa_n.m_n.m_data[0], 0, m_n0_inverse);
    m_n0_inverse=0-m_n0_inverse;
//n_neg
    struct timeval tv;
    gettimeofday(&tv,NULL);
    m_time_stamp = * new Time_Stamp(tv);
    m_time_system = * new Time_System();
    log_create();
}

CRT_N :: CRT_N (CRT_N &crt_n){
    m_rsa_n = crt_n.m_rsa_n;
    m_zero = crt_n.m_zero;
    m_one = crt_n.m_one;
    m_R =crt_n.m_R;
    m_n0_inverse = crt_n.m_n0_inverse;

    m_log_file = crt_n.m_log_file;
    m_time_stamp = crt_n.m_time_stamp;
    m_time_system = crt_n.m_time_system;
}

CRT_N& CRT_N :: operator= (CRT_N &crt_n){

    m_rsa_n = crt_n.m_rsa_n;
    m_zero = crt_n.m_zero;
    m_one = crt_n.m_one;
    m_R =crt_n.m_R;
    m_n0_inverse = crt_n.m_n0_inverse;

    m_log_file = crt_n.m_log_file;
    m_time_stamp = crt_n.m_time_stamp;
    m_time_system = crt_n.m_time_system;

    return * this;
}


CRT_N :: ~CRT_N (){
    log_quit();
}

int CRT_N :: CRT_MOD_MUL(BN_WORD a, BN_WORD b, BN_WORD &result){
    BN_WORD aR, bR;
    BN_WORD n=m_rsa_n.m_n;
    aR=(a*m_R)%n;
    bR=(b*m_R)%n;
   
    BN_PART *bp_a;
    BN_PART *bp_b;
    BN_PART *bp_n;
    BN_PART *bp_result;
    cudaMallocManaged((void**)&(bp_a),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_b),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_n),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_result),WARP_SIZE*sizeof(BN_PART));


    for(int i=0;i<WARP_SIZE;i++){
        bp_a[i]=0;
        bp_b[i]=0;
        bp_n[i]=0;
        bp_result[i]=0;
    }

    for(int i=0;i<aR.m_top;i++){
	bp_a[i]=aR.m_data[i];
    }
    
    for(int i=0;i<bR.m_top;i++){
	bp_b[i]=bR.m_data[i];
    }
    for(int i=0;i<n.m_top;i++){
	bp_n[i]=n.m_data[i];
    }
    
    GPU_WORD_mul_mod<<<1,WARP_SIZE>>>(bp_a,bp_b,bp_n,m_n0_inverse,bp_result);
    cudaDeviceSynchronize();

    result.setzero(); 
    for(int i=0;i<WARP_SIZE;i++){
	result.m_data[i]=bp_result[i];
    }
    result.m_top=32;
    
    cudaFree(bp_result);
    return 1;
}

int CRT_N :: log_create(){

    char file_name[200];
    snprintf(file_name,sizeof(file_name), "%s%s.log",RSA_FINAL_LOG, m_time_stamp.m_abbr);
    m_log_file = fopen(file_name, "a+");
    return 1;

}

int CRT_N :: log_info(LOG_TYPE log_type){
    return 1;
}

int CRT_N :: time_info(LOG_TYPE log_type, TIME_TYPE time_type){
    return 1;
}

int CRT_N :: log_quit(){

    fclose(m_log_file);
    return 1; 
    
}

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
        __syncthreads();
        p_m=M[0];
        BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
        p_u=ptemp_u+p_u;
        V[thread_id]=p_v;
        __syncthreads();
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
    __syncthreads();//
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
        __syncthreads();
    }
    result[thread_id]=p_v;

    return 1;	
}


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



__global__ void  GPU_WORD_mul_mod(BN_PART *A, BN_PART *B, BN_PART *N, BN_PART n0_inverse, BN_PART *result){
   int j=threadIdx.x;
   
   __shared__ BN_PART M[WARP_SIZE]; 
   __shared__ BN_PART U[WARP_SIZE]; 
   __shared__ BN_PART V[WARP_SIZE]; 
   __shared__ BN_PART C[WARP_SIZE]; 

   BN_PART c;
   
   __shared__ BN_PART ONE[WARP_SIZE];
   ONE[j]=0;
   ONE[0]=1;

   GPU_WORD_parallel_Mon(A,B,N,n0_inverse,M,U,V,C,result,j);

   c=C[WARP_SIZE-1];

   if(j==0){
       GPU_WORD_delete_carry(result, N, c); 
   }
   __syncthreads();

   GPU_WORD_parallel_Mon(result,ONE,N,n0_inverse,M,U,V,C,result,j);

   c=C[WARP_SIZE-1];

   if(j==0){
       GPU_WORD_delete_carry(result, N, c); 
   }
   __syncthreads();

}

}
