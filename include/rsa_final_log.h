#ifndef RSA_FINAL_LOG_H
#define RSA_FINAL_LOG_H

#include "stdio.h"
#include "rsa_final_time_stamp.h"

namespace namespace_rsa_final{

int LOG_INFO( FILE *file, Time_Stamp time_stamp, char *log_info);

}

#endif
