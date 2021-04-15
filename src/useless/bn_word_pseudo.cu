#include "bn_word_pseudo.h"

__host__ __device__ int BN_WORD_mul_lo(const BN_PART a, const BN_PART b, BN_PART &result){
    BN_PART temp_u, temp_v;
    BN_PART_mul(a,b,temp_u,temp_v);
    result=temp_v; 
    return 0;
}

__host__ __device__ int BN_WORD_mad_lo(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v){
    BN_PART temp_u, temp_v;
    BN_PART_mul(a,b,temp_u,temp_v);
    v=temp_v+c;
    if(v<temp_v){
        u=1;
    }
    else{
        u=0;
    }
    return 0;
}

__host__ __device__ int BN_WORD_mad_hi(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v){
    BN_PART temp_u, temp_v;
    BN_PART_mul(a,b,temp_u,temp_v);
    v=temp_u+c;
    if(v<temp_u){
        u=1;
    }
    else{
        u=0;
    }
    return 0;
}


/*
__host__ __device__ int BN_WORD_any(BN_WORD *a){
    int dmax=a->dmax;
    for(int i=0;i<dmax;i++){
        if(a->d[i]!=0){
	    return 0;
	}
    }
    return 1;
}
*/

__host__ __device__ int BN_WORD_any(BN_PART *a, int dmax){
    for(int i=0;i<dmax;i++){
        if(a[i]!=0){
            return 0;
        }
    }
    return 1;
}

