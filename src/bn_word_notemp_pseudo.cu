#include "bn_word_notemp_pseudo.h"


__host__ __device__ int BN_WORD_mad_lo_notemp(const BN_ULONG a, const BN_ULONG b, BN_ULONG &u, BN_ULONG &v){
    BN_ULONG temp_u, temp_v;
    BN_ULONG_mul(a,b,temp_u,temp_v);
    v=temp_v+v;
    if(v<temp_v){
        u=u+1;
    }
    else{
        u=u;
    }
    return 0;
}

__host__ __device__ int BN_WORD_mad_hi_notemp(const BN_ULONG a, const BN_ULONG b, BN_ULONG &u, BN_ULONG &v){
    BN_ULONG temp_u, temp_v;
    BN_ULONG_mul(a,b,temp_u,temp_v);
    v=temp_u+v;
    if(v<temp_u){
        u=u+1;
    }
    else{
        u=u;
    }
    return 0;
}

