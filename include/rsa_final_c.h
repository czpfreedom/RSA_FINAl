#ifndef RSA_FINAL_C_H
#define RSA_FINAL_C_H

#include "config.h"
#include "string.h"
#include "iostream"

namespace namespace_rsa_final {

#ifdef __cplusplus
extern "C" { 
#endif

#ifdef  BN_PART_32
#define BN_PART unsigned int
#endif

#ifdef  BN_PART_64
#define BN_PART unsigned long
#endif 

/***** BIGNUM **********************************/


class BN_WORD{

public:

    BN_PART m_data[BN_WORD_LENGTH_MAX];
    int m_neg;
    int m_top;

    BN_WORD();
    BN_WORD(BN_WORD &bn_word);
    BN_WORD& operator=(BN_WORD &bn_word);
    ~BN_WORD();

    BN_WORD& operator+ (BN_WORD &bw);
    BN_WORD& operator- (BN_WORD &bw);
    BN_WORD& operator* (BN_WORD &bw);
    BN_WORD& operator/ (BN_WORD &bw);
    BN_WORD& operator% (BN_WORD &bw);

    bool operator==(BN_WORD &bw_2);
    bool operator!=(BN_WORD &bw_2);
    bool operator> (BN_WORD &bw_2);
    bool operator< (BN_WORD &bw_2);
    bool operator>=(BN_WORD &bw_2);
    bool operator<=(BN_WORD &bw_2);

    int setzero();
    int setone();
    int setR(int top);
    int check_top();

    int print();   

    int BN_WORD_2_Str(std:: string &str);
    int Str_2_BN_WORD(std:: string str);

};

int BN_mod_exp_cuda(BN_WORD &rr, BN_WORD &a, BN_WORD &p,BN_WORD &m);


#ifdef __cplusplus
}
#endif

}
#endif
