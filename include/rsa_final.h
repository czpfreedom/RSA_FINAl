#ifndef RSA_H
#define RSA_H

#include "rsa_config.h"
#include "rsa_final_c.h"
#include "rsa_final_log.h"
#include "iostream"
#include "string.h"

namespace namespace_rsa_final{

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
    int BN_WORD_2_BN_WORD_C(BN_WORD_C *bw_c);
    int BN_WORD_C_2_BN_WORD(BN_WORD_C *bw_c);

};

/***** BN_WORD_ARRAY ****************************/
class BN_WORD_ARRAY{
public:

    BN_WORD *m_bn_word;
    int m_bn_word_num;

    BN_WORD_ARRAY();
    BN_WORD_ARRAY(int bn_word_num);
    BN_WORD_ARRAY(BN_WORD_ARRAY &bn_word_array);
    BN_WORD_ARRAY &operator= (BN_WORD_ARRAY &bn_word_array);
    ~BN_WORD_ARRAY();
};

/***** RSA_N ************************************/
class RSA_N{

public:

    BN_WORD m_n;
    BN_WORD m_p;
    BN_WORD m_q;
};

/************************************************/

/***** CRT_N ************************************/

class CRT_N{
public: 
    RSA_N m_rsa_n;
    BN_WORD m_zero;
    BN_WORD m_one;
    BN_WORD m_R;
    BN_PART m_n0_inverse;
    
    char m_log_file_name[LOG_FILE_NAME_LENGTH];

    CRT_N ();
    CRT_N (RSA_N rsa_n);
    CRT_N (CRT_N &crt_n);
    CRT_N& operator= (CRT_N &crt_n);
    ~CRT_N ();

    int CRT_MOD_MUL(BN_WORD a, BN_WORD b, BN_WORD &result);
    int CRT_MOD_EXP(BN_WORD a, BN_WORD e, BN_WORD &result);
    int CRT_MOD_EXP_ARRAY(BN_WORD_ARRAY a, BN_WORD e, BN_WORD_ARRAY &result);
    
//    int CRT_EXP_MOD_PARALL(BN_WORD a, BN_WORD e, BN_WORD result);

    int log_info(LOG_TYPE log_type);
    int log_info(LOG_TYPE log_type, BN_WORD a, BN_WORD b, BN_WORD r);
    int log_info(LOG_TYPE log_type, BN_WORD_ARRAY a, BN_WORD e, BN_WORD_ARRAY r);
//    int log_info(LOG_TYPE log_type);
//    int time_info(LOG_TYPE log_type, TIME_TYPE time_type);

};
/************************************************/

/***** RNS_N ************************************/
/*
class RNS_N{

public:
    RSA_N *m_rsa_n; //
    int m_base_num; //num of m1 and m2 which is effective, depend on the size of n, m_base_num can be 32 or 64
    BN_PART *m_m1; //size=BASE_MAX but only base_num is effective
    BN_PART *m_m2; //size=BASE_MAX but only base_num is effective
    BN_WORD *m_M1;
    BN_WORD *m_M2;
    BN_WORD **m_M1_i; //M1_i
    BN_WORD **m_M2_i;
    BN_WORD **m_M1_red_i; //M1_i^-1 * M1_i mod M1
    BN_WORD **m_M2_red_i; //M2_i^-1 * M2_i mod M2
    BN_WORD *m_M1_n;
    BN_WORD *m_M2_n;
    BN_PART *m_d; //size=base_num
    BN_PART *m_e; //size=base_num
    BN_PART *m_a; //size=base_num*base_num
    BN_PART *m_a_2; //size=base_num
    BN_PART *m_b; //size=base_num*base_num
    BN_PART *m_b_2; //size=base_num
    BN_PART *m_c; //size=base_num

    RNS_N();

    RNS_N(RSA_N *rsa_n);

    ~RNS_N();

    int RNS_print();

    int RNS_MUL_MOD(BN_WORD *a, BN_WORD *b, BN_WORD *result);

    int RSA (BN_WORD *a, BN_WORD *e, BN_WORD *result); // result=a^e mod n

    int RSA_RNS_reduction1(BN_PART *x_result, BN_WORD *result);

    int RSA_RNS_reduction2(BN_PART *x_result, BN_WORD *result);
};
*/
/************************************************/

int BN_mod_exp_cuda(BN_WORD &rr,  BN_WORD a, BN_WORD e, BN_WORD n);


}

#endif
