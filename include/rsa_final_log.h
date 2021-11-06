#ifndef RSA_FINAL_LOG_H
#define RSA_FINAL_LOG_H

#include "stdio.h"
#include "rsa_final_time_stamp.h"

namespace namespace_rsa_final{

typedef enum log_type{
    CRT_MUL_MOD_LOG=1,
    CRT_EXP_MOD_LOG,

}LOG_TYPE;

typedef enum time_type{
    PRE_TIME=1,
    IMPL_TIME,
    TOTAL_TIME,

}TIME_TYPE;

int LOG_INFO( FILE *file, Time_Stamp time_stamp, char *log_info, int log_info_length );

}

#endif
