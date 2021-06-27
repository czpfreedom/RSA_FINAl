#include "rsa_crt.h"
#include "stdio.h"
#include <ctime>
#include "iostream"
#include <sys/time.h>

using namespace std;

double cpuSecond() {
    struct timeval tp;
    gettimeofday(&tp,NULL);
    return ((double)tp.tv_sec + (double)tp.tv_usec*1.e-6);
}


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

__global__ void BN_WORD_parallel_mont_exp(int dmax, BN_WORD *square_1, BN_WORD *square_2, BN_WORD *result_2, const BN_WORD *e, const BN_WORD *n, const BN_WORD *one, const BN_PART n0_inverse, BN_WORD *result){
    int thread_id=threadIdx.x+blockIdx.x*blockDim.x;
    int tix= thread_id%dmax;
    int tiy= thread_id/dmax;
    BN_PART p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;

    __shared__  BN_PART A[2][SHARED_SIZE];
    __shared__  BN_PART B[2][SHARED_SIZE];
    __shared__  BN_PART M[2][SHARED_SIZE];
    __shared__  BN_PART C[2][SHARED_SIZE];
    __shared__  BN_PART U[2][SHARED_SIZE];
    __shared__  BN_PART V[2][SHARED_SIZE];
    __shared__  BN_PART N   [SHARED_SIZE];
    __shared__  BN_PART E   [SHARED_SIZE];

    if(tiy==0){
	N[tix]=n->d[tix];
	E[tix]=e->d[tix];
    }
    __syncthreads();

//Montgomery
    for(int i=0; i<dmax*sizeof(BN_PART)*8;i++){
//赋值	    

        if(tiy==0){
	    A[tiy][tix]=square_1->d[tix];	
	    B[tiy][tix]=square_1->d[tix];	
	}
        else{
	    A[tiy][tix]=square_2->d[tix];	
	    B[tiy][tix]=result_2->d[tix];	
	}
	__syncthreads();

	p_u=0;
	p_v=0;
	M[tiy][tix]=0;
	C[tiy][tix]=0;
	p_n=N[tix];
	p_a=A[tiy][tix];

	__syncthreads();

//循环计算
	for(int j=0;j<dmax;j++){
	    p_b=B[tiy][j];
	    BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
	    p_u=ptemp_u+p_u;
	    BN_PART_mul_lo(p_v,n0_inverse,M[tiy][tix]);
	    __syncthreads();
	    p_m=M[tiy][0];
	    BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
	    p_u=ptemp_u+p_u;
	    V[tiy][tix]=p_v;
	    __syncthreads();
	    p_v=V[tiy][int_mod(tix+1,dmax)];
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
	C[tiy][tix]=p_u;
	U[tiy][tix]=p_u;

//去除carry值

	while(BN_PART_any(U[tiy],dmax)==0){
	    p_u=U[tiy][int_mod(tix-1,dmax)];
	    if(tix==0){
		p_u=0;
	    }
	    p_v=p_u+p_v;
	    if(p_v<p_u){
		p_u=1;
	    }
	    else{
		p_u=0;
	    }
	    C[tiy][tix]=C[tiy][tix]+p_u;
	    U[tiy][tix]=p_u;
	}
	
//模运算

	if(tiy==0){
	    A[tiy][tix]=p_v;
	    C[tiy][tix]=C[tiy][dmax-1];
	    square_1->d[tix]=A[tiy][tix];
	    if(tix==0){
	        while(C[tiy][tix]!=0){
		    BN_WORD_mod_device(square_1,n,square_1);
    		    C[tiy][tix]=C[tiy][tix]-1;
    		    BN_WORD_sub(square_1,n,square_1);
    		}
    		BN_WORD_mod_device(square_1,n,square_1);						    	    
	    }
	}
	else{
	    if(BN_PART_get_bit(E[i/(sizeof(BN_PART)*8)],i%(sizeof(BN_PART)*8))==1){
	        A[tiy][tix]=p_v;
    		C[tiy][tix]=C[tiy][dmax-1];
		result_2->d[tix]=A[tiy][tix];
    		if(tix==0){
    		    while(C[tiy][tix]!=0){
			BN_WORD_mod_device(result_2,n,result_2);
    			C[tiy][tix]=C[tiy][tix]-1;
    			BN_WORD_sub(result_2,n,result_2);
    		    }
    		    BN_WORD_mod_device(result_2,n,result_2);						    
    		}	        
	    }
	}
	__syncthreads();
	if((tiy==0)&&(tix==0)){
	    BN_WORD_copy(square_1,square_2);
	}
	__syncthreads();
    }

//Reduce
    A[tiy][tix]=result_2->d[tix];
    B[tiy][tix]=one->d[tix];
    p_a=A[tiy][tix];
    p_u=0;
    p_v=0;
    M[tiy][tix]=0;
    C[tiy][tix]=0;

    for(int j=0;j<dmax;j++){
	p_b=B[tiy][j];
	BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	BN_PART_mul_lo(p_v,n0_inverse,M[tiy][tix]);
	p_m=M[tiy][0];
	BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	V[tiy][tix]=p_v;
	p_v=V[tiy][int_mod(tix+1,dmax)];
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
    C[tiy][tix]=p_u;
    U[tiy][tix]=p_u;
    while(BN_PART_any(U[tiy],dmax)==0){
	p_u=U[tiy][int_mod(tix-1,dmax)];
	if(tix==0){
	    p_u=0;
	}
	p_v=p_u+p_v;
	if(p_v<p_u){
	    p_u=1;
	}
	else{
	    p_u=0;
	}
	C[tiy][tix]=C[tiy][tix]+p_u;
	U[tiy][tix]=p_u;
    }
    A[tiy][tix]=p_v;
    C[tiy][tix]=C[tiy][dmax-1];
    if(tiy==0){
	result->d[tix]=A[tiy][tix];
	if(tix==0){
	    while(C[tiy][tix]!=0){
		BN_WORD_mod_device(result,n,result);
    		C[tiy][tix]=C[tiy][tix]-1;
    		BN_WORD_sub(result,n,result);
    	    }
	    BN_WORD_mod_device(result,n,result);						    
	}
    }
}

__global__ void BN_WORD_ARRAY_parallel_mont_exp(int dmax, BN_WORD_ARRAY *square_1, BN_WORD_ARRAY *square_2, BN_WORD_ARRAY *result_2, const BN_WORD_ARRAY *e, const BN_WORD *n, const BN_WORD *one, const BN_PART n0_inverse, BN_WORD_ARRAY *result){
    int thread_id=threadIdx.x+blockIdx.x*blockDim.x;
    int tix= (thread_id%(2*dmax))%dmax;
    int tiy= (thread_id%(2*dmax))/dmax;
    int tib= (thread_id/(2*dmax));
    BN_PART p_a, p_b, p_u, p_v,ptemp_u,p_n,p_m;

    __shared__  BN_PART A[2][SHARED_SIZE];
    __shared__  BN_PART B[2][SHARED_SIZE];
    __shared__  BN_PART M[2][SHARED_SIZE];
    __shared__  BN_PART C[2][SHARED_SIZE];
    __shared__  BN_PART U[2][SHARED_SIZE];
    __shared__  BN_PART V[2][SHARED_SIZE];
    __shared__  BN_PART N   [SHARED_SIZE];
    __shared__  BN_PART E   [SHARED_SIZE];

    if(tiy==0){
	N[tix]=n->d[tix];
	E[tix]=e->bn_word[tib]->d[tix];
    }
    __syncthreads();

//Montgomery
    for(int i=0; i<dmax*sizeof(BN_PART)*8;i++){
//赋值	    

        if(tiy==0){
	    A[tiy][tix]=square_1->bn_word[tib]->d[tix];	
	    B[tiy][tix]=square_1->bn_word[tib]->d[tix];	
	}
        else{
	    A[tiy][tix]=square_2->bn_word[tib]->d[tix];	
	    B[tiy][tix]=result_2->bn_word[tib]->d[tix];	
	}
	__syncthreads();

	p_u=0;
	p_v=0;
	M[tiy][tix]=0;
	C[tiy][tix]=0;
	p_n=N[tix];
	p_a=A[tiy][tix];

	__syncthreads();

//循环计算
	for(int j=0;j<dmax;j++){
	    p_b=B[tiy][j];
	    BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
	    p_u=ptemp_u+p_u;
	    BN_PART_mul_lo(p_v,n0_inverse,M[tiy][tix]);
	    __syncthreads();
	    p_m=M[tiy][0];
	    BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
	    p_u=ptemp_u+p_u;
	    V[tiy][tix]=p_v;
	    __syncthreads();
	    p_v=V[tiy][int_mod(tix+1,dmax)];
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
	C[tiy][tix]=p_u;
	U[tiy][tix]=p_u;

//去除carry值

	while(BN_PART_any(U[tiy],dmax)==0){
	    p_u=U[tiy][int_mod(tix-1,dmax)];
	    if(tix==0){
		p_u=0;
	    }
	    p_v=p_u+p_v;
	    if(p_v<p_u){
		p_u=1;
	    }
	    else{
		p_u=0;
	    }
	    C[tiy][tix]=C[tiy][tix]+p_u;
	    U[tiy][tix]=p_u;
	}
	
//模运算

	if(tiy==0){
	    A[tiy][tix]=p_v;
	    C[tiy][tix]=C[tiy][dmax-1];
	    square_1->bn_word[tib]->d[tix]=A[tiy][tix];
	    if(tix==0){
	        while(C[tiy][tix]!=0){
		    BN_WORD_mod_device(square_1->bn_word[tib],n,square_1->bn_word[tib]);
    		    C[tiy][tix]=C[tiy][tix]-1;
    		    BN_WORD_sub(square_1->bn_word[tib],n,square_1->bn_word[tib]);
    		}
    		BN_WORD_mod_device(square_1->bn_word[tib],n,square_1->bn_word[tib]);						    	    
	    }
	}
	else{
	    if(BN_PART_get_bit(E[i/(sizeof(BN_PART)*8)],i%(sizeof(BN_PART)*8))==1){
	        A[tiy][tix]=p_v;
    		C[tiy][tix]=C[tiy][dmax-1];
		result_2->bn_word[tib]->d[tix]=A[tiy][tix];
    		if(tix==0){
    		    while(C[tiy][tix]!=0){
			BN_WORD_mod_device(result_2->bn_word[tib],n,result_2->bn_word[tib]);
    			C[tiy][tix]=C[tiy][tix]-1;
    			BN_WORD_sub(result_2->bn_word[tib],n,result_2->bn_word[tib]);
    		    }
    		    BN_WORD_mod_device(result_2->bn_word[tib],n,result_2->bn_word[tib]);
    		}	        
	    }
	}
	__syncthreads();
	if((tiy==0)&&(tix==0)){
	    BN_WORD_copy(square_1->bn_word[tib],square_2->bn_word[tib]);
	}
	__syncthreads();
    }

//Reduce
    A[tiy][tix]=result_2->bn_word[tib]->d[tix];
    B[tiy][tix]=one->d[tix];
    p_a=A[tiy][tix];
    p_u=0;
    p_v=0;
    M[tiy][tix]=0;
    C[tiy][tix]=0;

    for(int j=0;j<dmax;j++){
	p_b=B[tiy][j];
	BN_PART_mad_lo(p_a,p_b,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	BN_PART_mul_lo(p_v,n0_inverse,M[tiy][tix]);
	p_m=M[tiy][0];
	BN_PART_mad_lo(p_n,p_m,p_v,ptemp_u,p_v);
	p_u=ptemp_u+p_u;
	V[tiy][tix]=p_v;
	p_v=V[tiy][int_mod(tix+1,dmax)];
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
    C[tiy][tix]=p_u;
    U[tiy][tix]=p_u;
    while(BN_PART_any(U[tiy],dmax)==0){
	p_u=U[tiy][int_mod(tix-1,dmax)];
	if(tix==0){
	    p_u=0;
	}
	p_v=p_u+p_v;
	if(p_v<p_u){
	    p_u=1;
	}
	else{
	    p_u=0;
	}
	C[tiy][tix]=C[tiy][tix]+p_u;
	U[tiy][tix]=p_u;
    }
    A[tiy][tix]=p_v;
    C[tiy][tix]=C[tiy][dmax-1];
    if(tiy==0){
	result->bn_word[tib]->d[tix]=A[tiy][tix];
	if(tix==0){
	    while(C[tiy][tix]!=0){
		BN_WORD_mod_device(result->bn_word[tib],n,result->bn_word[tib]);
    		C[tiy][tix]=C[tiy][tix]-1;
    		BN_WORD_sub(result->bn_word[tib],n,result->bn_word[tib]);
    	    }
	    BN_WORD_mod_device(result->bn_word[tib],n,result->bn_word[tib]);						    
	}
    }
}

CRT_N ::CRT_N (RSA_N *rsa_n){

    m_rsa_n = rsa_n;
    int dmax = m_rsa_n->n->dmax;
    m_zero=BN_WORD_new(dmax);
    m_one=BN_WORD_new(dmax);
    m_R=BN_WORD_new(dmax);
    BN_WORD_setzero(m_zero);
    BN_WORD_setone(m_one);
    BN_WORD_sub(m_zero,m_rsa_n->n,m_R);

    BN_PART_mod_inverse(m_rsa_n->n->d[0], 0, m_n0_inverse);
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
    BN_WORD *a_pro, *temp_result, *square;
    a_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    square=BN_WORD_new(dmax);

    BN_WORD_mod(a,m_rsa_n->n,a_pro);
    BN_WORD_mul_mod(a_pro,m_R,m_rsa_n->n,temp_result);
    BN_WORD_copy(temp_result,a_pro);
    BN_WORD_copy(a_pro,square);
    BN_WORD_copy(m_R,result);
/*
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
*/

    for(int i=0;i<dmax;i++){
        for(int j=0;j<sizeof(BN_PART)*8;j++){
	    if(BN_PART_get_bit(e->d[i],j)==1){
		BN_WORD_parallel_Mon<<<1,dmax>>>(result, square, m_rsa_n->n,m_n0_inverse, result);
		cudaDeviceSynchronize();
	    }
	    BN_WORD_parallel_Mon<<<1,dmax>>>(square,square, m_rsa_n->n,m_n0_inverse, square);
	    cudaDeviceSynchronize();
	}
    }

    BN_WORD_parallel_Mon<<<1,dmax>>>(result,m_one, m_rsa_n->n,m_n0_inverse, result);
    cudaDeviceSynchronize();
    BN_WORD_free(a_pro);
    BN_WORD_free(square);
    BN_WORD_free(temp_result);
    return 0;
}

int CRT_N :: CRT_EXP_MOD_PARALL(BN_WORD *a, BN_WORD *e, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *a_pro, *temp_result, *square_1, *square_2, *result_2;
    a_pro=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    square_1=BN_WORD_new(dmax);
    square_2=BN_WORD_new(dmax);
    result_2=BN_WORD_new(dmax);
   
    BN_WORD_mod(a,m_rsa_n->n,a_pro);
    BN_WORD_mul_mod(a_pro,m_R,m_rsa_n->n,temp_result);
    BN_WORD_copy(temp_result,a_pro);
    BN_WORD_copy(a_pro,square_1);
    BN_WORD_copy(a_pro,square_2);
    BN_WORD_copy(m_R,result_2);
       
    BN_WORD_parallel_mont_exp<<<1,dmax*2>>>(dmax, square_1, square_2, result_2, e, m_rsa_n->n, m_one, m_n0_inverse, result);
    cudaDeviceSynchronize();
    
    BN_WORD_free(a_pro);
    BN_WORD_free(temp_result);
    BN_WORD_free(square_1);
    BN_WORD_free(square_2);
    BN_WORD_free(result_2);
    return 0;
}

int CRT_N :: CRT_EXP_MOD_ARRAY(BN_WORD_ARRAY *a, BN_WORD_ARRAY *e, BN_WORD_ARRAY *result){
    int word_num = a->word_num;
    int dmax = a->bn_word[0]->dmax;
    BN_WORD_ARRAY *a_pro, *temp_result, *square_1, *square_2, *result_2;

    clock_t time_start=clock();
    
    a_pro=BN_WORD_ARRAY_new(word_num, dmax);
    temp_result=BN_WORD_ARRAY_new(word_num, dmax);
    square_1=BN_WORD_ARRAY_new(word_num, dmax);
    square_2=BN_WORD_ARRAY_new(word_num, dmax);
    result_2=BN_WORD_ARRAY_new(word_num, dmax);
    
    clock_t time_end=clock();
    cout<<"new time use:"<<1000*(time_end-time_start)/(double)CLOCKS_PER_SEC<<"ms"<<endl;

    time_start=clock();
    for(int i=0;i<word_num;i++){
	BN_WORD_mod(a->bn_word[i],m_rsa_n->n,a_pro->bn_word[i]);
    	BN_WORD_mul_mod(a_pro->bn_word[i],m_R,m_rsa_n->n,temp_result->bn_word[i]);
    	BN_WORD_copy(temp_result->bn_word[i],a_pro->bn_word[i]);
    	BN_WORD_copy(a_pro->bn_word[i],square_1->bn_word[i]);
    	BN_WORD_copy(a_pro->bn_word[i],square_2->bn_word[i]);
    	BN_WORD_copy(m_R,result_2->bn_word[i]);
    }

    time_end=clock();
    cout<<"init time use:"<<1000*(time_end-time_start)/(double)CLOCKS_PER_SEC<<"ms"<<endl;
    
    time_start=clock();
    double iStart = cpuSecond();
    BN_WORD_ARRAY_parallel_mont_exp<<<word_num,2*dmax>>>(dmax, square_1, square_2, result_2, e, m_rsa_n->n , m_one, m_n0_inverse, result);
    cudaDeviceSynchronize();
    double iElaps = cpuSecond() - iStart;
    time_end=clock();
    cout<<"iElaps:"<<iElaps<<endl;
    cout<<"calculate time use:"<<1000*(time_end-time_start)/(double)CLOCKS_PER_SEC<<"ms"<<endl;

    time_start=clock();
    BN_WORD_ARRAY_free(a_pro);
    BN_WORD_ARRAY_free(temp_result);
    BN_WORD_ARRAY_free(square_1);
    BN_WORD_ARRAY_free(square_2);
    BN_WORD_ARRAY_free(result_2);
    time_end=clock();
    cout<<"free time use:"<<1000*(time_end-time_start)/(double)CLOCKS_PER_SEC<<"ms"<<endl;
    return 0;
}
