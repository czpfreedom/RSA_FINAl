#include "bn_word_pseudo.h"

__host__ __device__ int BN_WORD_mul_lo(const BN_ULONG a, const BN_ULONG b, BN_ULONG &result){
    BN_ULONG temp_u, temp_v;
    BN_ULONG_mul(a,b,temp_u,temp_v);
    result=temp_v;
    return 0;
}

__host__ __device__ int BN_WORD_mad_lo(const BN_ULONG a, const BN_ULONG b, BN_ULONG c, BN_ULONG &u, BN_ULONG &v){
    BN_ULONG temp_u, temp_v;
    BN_ULONG_mul(a,b,temp_u,temp_v);
    v=temp_v+c;
    if(v<c){
        u=1;
    }
    else{
        u=0;
    }
    return 0;
}

__host__ __device__ int BN_WORD_mad_hi(const BN_ULONG a, const BN_ULONG b, BN_ULONG c, BN_ULONG &u, BN_ULONG &v){
    BN_ULONG temp_u, temp_v;
    BN_ULONG_mul(a,b,temp_u,temp_v);
    v=temp_u+c;
    if(v<c){
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

__host__ __device__ int BN_WORD_any(BN_ULONG *a, int dmax){
    for(int i=0;i<dmax;i++){
        if(a[i]!=0){
            return 0;
        }
    }
    return 1;
}

