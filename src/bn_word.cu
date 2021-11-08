#include "bn_word.h"
#include "stdio.h"

namespace namespace_rsa_final{

BN_WORD& BN_WORD :: operator+ (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1+gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator- (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1-gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator* (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1*gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator/ (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1/gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator% (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1%gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

bool BN_WORD :: operator==(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1==gw_2);
}

bool BN_WORD :: operator!=(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1!=gw_2);
}
 
bool BN_WORD :: operator> (BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1>gw_2);
}

bool BN_WORD :: operator< (BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1<gw_2);
}

bool BN_WORD :: operator>=(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1>=gw_2);
}

bool BN_WORD :: operator<=(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1<=gw_2);
}

}
