#include "rsa_final.h"

namespace namespace_rsa_final{
    
BN_WORD_ARRAY :: BN_WORD_ARRAY(){
    m_bn_word_num = BN_WORD_ARRAY_DEFAULT_SIZE;
    m_bn_word = (BN_WORD *)malloc(sizeof(BN_WORD)*m_bn_word_num);
}

BN_WORD_ARRAY :: BN_WORD_ARRAY(int bn_word_num){
    m_bn_word_num = bn_word_num;
    m_bn_word = (BN_WORD *)malloc(sizeof(BN_WORD)*m_bn_word_num);
}

BN_WORD_ARRAY :: BN_WORD_ARRAY(BN_WORD_ARRAY &bn_word_array){
    m_bn_word_num = bn_word_array.m_bn_word_num;
    m_bn_word = (BN_WORD *)malloc(sizeof(BN_WORD)*m_bn_word_num);
    memcpy(m_bn_word,bn_word_array.m_bn_word,sizeof(BN_WORD)*m_bn_word_num);
}

BN_WORD_ARRAY& BN_WORD_ARRAY :: operator= (BN_WORD_ARRAY &bn_word_array){
    m_bn_word_num = bn_word_array.m_bn_word_num;
    m_bn_word = (BN_WORD *)malloc(sizeof(BN_WORD)*m_bn_word_num);
    memcpy(m_bn_word,bn_word_array.m_bn_word,sizeof(BN_WORD)*m_bn_word_num);
    return *this;
}

BN_WORD_ARRAY :: ~BN_WORD_ARRAY(){
    free(m_bn_word);
}

}
