#ifndef RSA_CONFIG_H
#define RSA_CONFIG_H

namespace namespace_rsa_final {

/**********************************************************/
/***Config BN_PART datatype********************************/
/**********************************************************/

//#define BN_PART_32

#define BN_PART_64

/**********************************************************/
/*Config BN_WORD_LENGTH ***********************************/
/**********************************************************/

const int BN_WORD_LENGTH_MAX = 128;

const int BN_WORD_ARRAY_DEFAULT_SIZE = 32;

/**********************************************************/
/*Config Memory style**************************************/
/**********************************************************/

//#define NOTEMP

//#define SHARED

const int WARP_SIZE = 32;

/**********************************************************/
/*Config LOG_LOCATION**************************************/
/**********************************************************/

#define RSA_FINAL_LOG "/home/nx2/rsa_final_new/log"

const int LOG_FILE_NAME_LENGTH = 128;

const int LOG_INFO_LENGTH_MAX = 100000;

typedef enum log_type{
    CRT_CREATE_LOG=1,
    CRT_MOD_MUL_LOG,
    CRT_MOD_EXP_LOG,
    CRT_MOD_EXP_ARRAY_LOG
}LOG_TYPE;

/**********************************************************/
/*Config OPENSSL*******************************************/
/**********************************************************/

#define EXTRA_OPENSSL

/**********************************************************/
/*Config time**********************************************/
/**********************************************************/

typedef enum time_type{
    PRE_TIME=1,
    IMPL_TIME,
    TOTAL_TIME

}TIME_TYPE;

//#define CUDA_TIMING

/**********************************************************/

}

#endif
