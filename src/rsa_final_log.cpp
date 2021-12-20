#include "rsa_final_log.h"
#include "stdio.h"
#include "rsa_final.h"

namespace namespace_rsa_final{

int CRT_N :: log_info(LOG_TYPE log_type){
    char log_info_data[LOG_INFO_LENGTH_MAX];
    struct timeval tv;
    gettimeofday(&tv,NULL);
    Time_Stamp time_stamp(tv);
    FILE *log_file;
    if(log_type==CRT_CREATE_LOG){
        snprintf(m_log_file_name,LOG_FILE_NAME_LENGTH, "%s/CRT:%lu.log",RSA_FINAL_LOG,time_stamp.m_data);
        log_file=fopen(m_log_file_name,"a+");
        snprintf(log_info_data, LOG_INFO_LENGTH_MAX, "  Operation:CRT_CREATE\n\n-----------------------------------------\n\n");
        LOG_INFO( log_file, time_stamp, log_info_data);
        fclose(log_file);
        return 1;
    }
    return 0;
}

int CRT_N :: log_info(LOG_TYPE log_type, BN_WORD a, BN_WORD b, BN_WORD r){
    char log_info_data[LOG_INFO_LENGTH_MAX];
    struct timeval tv;
    gettimeofday(&tv,NULL);
    Time_Stamp time_stamp(tv);
    FILE *log_file;
    if(log_type==CRT_MOD_MUL_LOG){
        log_file=fopen(m_log_file_name,"a+");
        std::string str_a, str_b, str_n, str_r;
        a.BN_WORD_2_Str(str_a);
        b.BN_WORD_2_Str(str_b);
        m_rsa_n.m_n.BN_WORD_2_Str(str_n);
        r.BN_WORD_2_Str(str_r);
	std::cout<<str_a<<std::endl;
        snprintf(log_info_data, LOG_INFO_LENGTH_MAX, "  Operation:CRT_MOD_MUL\n  bn_a:%s\n\n  bn_b:%s\n\n  bn_n:%s\n\n  bn_result:%s\n\n -----------------------------------------\n\n", str_a.c_str(), str_b.c_str(), str_n.c_str(), str_r.c_str());
        LOG_INFO( log_file, time_stamp, log_info_data);
        fclose(log_file);
        return 1;
    }
    if(log_type==CRT_MOD_EXP_LOG){
        log_file=fopen(m_log_file_name,"a+");
        std::string str_a, str_b, str_n, str_r;
        a.BN_WORD_2_Str(str_a);
        b.BN_WORD_2_Str(str_b);
        m_rsa_n.m_n.BN_WORD_2_Str(str_n);
        r.BN_WORD_2_Str(str_r);
        snprintf(log_info_data, LOG_INFO_LENGTH_MAX, "  Operation:CRT_MOD_EXP\n  bn_a:%s\n\n  bn_e:%s\n\n  bn_n:%s\n\n  bn_result:%s\n\n -----------------------------------------\n\n", str_a.c_str(), str_b.c_str(), str_n.c_str(), str_r.c_str());
        LOG_INFO( log_file, time_stamp, log_info_data);
        fclose(log_file);
        return 1;
    }
    return 0;
}

int CRT_N :: log_info(LOG_TYPE log_type, BN_WORD_ARRAY a, BN_WORD e, BN_WORD_ARRAY r){
    char log_info_data[LOG_INFO_LENGTH_MAX];
    struct timeval tv;
    gettimeofday(&tv,NULL);
    Time_Stamp time_stamp(tv);
    FILE *log_file;
    if(log_type==CRT_MOD_EXP_ARRAY_LOG){
        log_file=fopen(m_log_file_name,"a+");
	snprintf(log_info_data, LOG_INFO_LENGTH_MAX,"  Operation:CRT_MOD_EXP_ARRAY\n  bn_word_num:%d\n  crypt_size:%d\n", a.m_bn_word_num, m_rsa_n.m_n.m_top);
	LOG_INFO( log_file, time_stamp, log_info_data);
	fclose(log_file);
	return 1;
    }
    return 0;
}

int LOG_INFO( FILE *file, Time_Stamp time_stamp, char *log_info){
    fprintf(file,"TimeStamp:%s\n%s", time_stamp.m_full, log_info);
    return 1;
}

}
