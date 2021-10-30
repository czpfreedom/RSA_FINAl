#ifndef RSA_H
#define RSA_H

#include "rsa_final_c.h"
#include "rsa_final_log.h"

namespace namespace_rsa_final{

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

    FILE *m_log_file;
    Time_Stamp m_time_stamp;
    Time_System m_time_system;

    CRT_N (RSA_N rsa_n);
    CRT_N (CRT_N &crt_n)=delete;
    CRT_N& operator=(CRT_N &crt_n)=delete;
    ~CRT_N ();

    int CRT_MUL_MOD(BN_WORD a, BN_WORD b, BN_WORD result);
    int CRT_EXP_MOD(BN_WORD a, BN_WORD e, BN_WORD result);
    int CRT_EXP_MOD_PARALL(BN_WORD a, BN_WORD e, BN_WORD result);

    int log_create();
    int log_info(LOG_TYPE log_type);
    int log_quit();

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

}

#endif
