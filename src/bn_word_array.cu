#include "rsa_final.h"

namespace namespace_rsa_final{

__host__ BN_WORD_ARRAY *BN_WORD_ARRAY_new(int word_num, int dmax){
    BN_WORD_ARRAY *a;
    cudaMallocManaged((void**)&(a),sizeof(BN_WORD_ARRAY));
    a->word_num=word_num;
    cudaMallocManaged((void**)&(a->bn_word),sizeof(BN_WORD*));
    for(int i=0;i<word_num; i++){
        a->bn_word[i]=BN_WORD_new(dmax);
    }
    return a;
}

__host__ void BN_WORD_ARRAY_free(BN_WORD_ARRAY *a){
    for(int i=0;i<a->word_num;i++){
        BN_WORD_free(a->bn_word[i]);
    } 
    cudaFree(a->bn_word);
    cudaFree(a);

}

}
