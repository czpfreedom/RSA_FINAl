#ifndef RSA_FINAL_LOG_H
#define RSA_FINAL_LOG_H

#include "stdio.h"
#include "rsa_final_time_stamp.h"

namespace namespace_rsa_final{

typedef enum log_type{
    CRT_MUL_LOG=1,
    CRT_MOD_LOG,

}LOG_TYPE;

int LOG_INFO( FILE *file, Time_Stamp time_stamp, char *log_info, int log_info_length );

}

#endif
