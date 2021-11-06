#ifndef RSA_FINAL_TIME_STAMP_H
#define RSA_FINAL_TIME_STAMP_H

#include <sys/time.h>
#include <time.h>
#include "cuda_runtime.h"

#define TIME_STAMP_ABBR_LENGTH 30
#define TIME_STAMP_FULL_LENGTH 50

namespace namespace_rsa_final{

double cpuSecond();

// Time: Year:4 Month:2 Day:2 Hour:2 Minute:2 Second:2 Ms:3 Us:3
// c++ char array end with a '\0'
class Time_Stamp {
public: 

    unsigned long m_data;
    char m_abbr[TIME_STAMP_ABBR_LENGTH];
    char m_full[TIME_STAMP_FULL_LENGTH];

    Time_Stamp();
    Time_Stamp(struct timeval tv);
    Time_Stamp(Time_Stamp& time_stamp);
    Time_Stamp& operator=(Time_Stamp& time_stamp);
    
    int refresh();

};

typedef enum time_system_node{
    Time_Create_NODE=1,
    Time_Start_NODE,
    Time_Pre_NODE,
    Time_Impl_NODE,
    Time_Quit_NODE,
}Time_System_Node; 
    
class Time_System{
public:
// time calculate with cpu_second()

    double m_cpu_create_time;
    double m_cpu_start_time;
    double m_cpu_pre_time;
    double m_cpu_impl_time;
    double m_cpu_quit_time;
    
// time calculate with cuda_event;

    cudaEvent_t m_cuda_create_time;
    cudaEvent_t m_cuda_start_time;
    cudaEvent_t m_cuda_pre_time;
    cudaEvent_t m_cuda_impl_time;
    cudaEvent_t m_cuda_quit_time;

    Time_System();
    ~Time_System();

    int refresh(Time_System_Node time_system_node);

    double CPU_TIME(double start_time, double end_time);
    float CUDA_TIME(cudaEvent_t &start_time, cudaEvent_t &end_time);

};

}
#endif

