#include "bn_num_operation.h"

__host__ BN_NUM *BN_NUM_new(int wmax,int dmax){
    BN_NUM *a;
    cudaMallocManaged((void**)&(a),sizeof(BN_NUM));
    a->wmax=wmax;
    cudaMallocManaged((void**)&(a->word),sizeof(BN_WORD*)*wmax);
    for(int i=0;i<wmax;i++){
        *(a->word+i)=BN_WORD_new(dmax);
    }
    return a;
}

__device__ BN_NUM *BN_NUM_new_device(int wmax,int dmax){
    BN_NUM *a;
    a=(BN_NUM*)malloc(sizeof(BN_NUM));
    a->wmax=wmax;
    a->word=(BN_WORD **)malloc(sizeof(BN_WORD*)*wmax);
    for(int i=0;i<wmax;i++){
        *(a->word+i)=BN_WORD_new_device(dmax);
    }
    return a;

}
__host__ void BN_NUM_free(BN_NUM *a){
    for(int i=0;i<a->wmax;i++){
        BN_WORD_free(*(a->word+1));
    }
    cudaFree(a->word);
    cudaFree(a);
}

__device__ void BN_NUM_free_device(BN_NUM *a){
    for(int i=0;i<a->wmax;i++){
        BN_WORD_free_device(*(a->word+1));
    }
    free(a->word);
    free(a);
}

