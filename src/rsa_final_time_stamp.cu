#include "stdio.h"
#include "string.h"
#include "rsa_final_time_stamp.h"
#include <ctime>
#include <sys/time.h>

namespace namespace_rsa_final{

double cpuSecond() {
    struct timeval tp;
    gettimeofday(&tp,NULL);
    return ((double)tp.tv_sec + (double)tp.tv_usec*1.e-6);
}

Time_Stamp:: Time_Stamp(){

}


Time_Stamp:: Time_Stamp(struct timeval tv){
    struct tm* pTime;
    pTime = localtime(&tv.tv_sec);
    m_data=(unsigned long)((pTime->tm_year+900)%1000)*(unsigned long)(10000000000000000)+(unsigned long)(pTime->tm_mon+1)*(unsigned long)(100000000000000)+(unsigned long)(pTime->tm_mday)*(unsigned long)(1000000000000)+ (unsigned long)(pTime->tm_hour)*(unsigned long)(10000000000)+ (unsigned long)(pTime->tm_min)*(unsigned long)(100000000)+(unsigned long)(pTime->tm_sec)*(unsigned long)(1000000)+(unsigned long)(tv.tv_usec/1000)*(unsigned long)(1000)+(unsigned long)tv.tv_usec%1000;

    sprintf(m_abbr,"%d-%d-%d-%d-%d-%d-%d-%d",pTime->tm_year+1900,pTime->tm_mon+1,pTime->tm_mday,pTime->tm_hour,pTime->tm_min,pTime->tm_sec,tv.tv_usec/1000,tv.tv_usec%1000);
    sprintf(m_full,"Year:%d Month:%d Day:%d Hour:%d Min:%d Sec:%d ", pTime->tm_year+1900,pTime->tm_mon+1,pTime->tm_mday,pTime->tm_hour,pTime->tm_min,pTime->tm_sec);

}

Time_Stamp:: Time_Stamp(Time_Stamp& time_stamp){
    m_data=time_stamp.m_data;
    memcpy(m_abbr,time_stamp.m_abbr,TIME_STAMP_ABBR_LENGTH);
    memcpy(m_full,time_stamp.m_full,TIME_STAMP_FULL_LENGTH);
}

Time_Stamp& Time_Stamp:: operator=(Time_Stamp& time_stamp){
    m_data=time_stamp.m_data;
    memcpy(m_abbr,time_stamp.m_abbr,TIME_STAMP_ABBR_LENGTH);
    memcpy(m_full,time_stamp.m_full,TIME_STAMP_FULL_LENGTH);
    return * this;
}


int Time_Stamp:: refresh(){
    return 0;
}

Time_System :: Time_System(){
    cudaEventCreate(&m_cuda_create_time);	
    cudaEventCreate(&m_cuda_start_time);	
    cudaEventCreate(&m_cuda_pre_time);	
    cudaEventCreate(&m_cuda_impl_time);	
    cudaEventCreate(&m_cuda_quit_time);	
}

Time_System :: ~Time_System(){
    cudaEventDestroy(m_cuda_create_time);
    cudaEventDestroy(m_cuda_start_time);
    cudaEventDestroy(m_cuda_pre_time);
    cudaEventDestroy(m_cuda_impl_time);
    cudaEventDestroy(m_cuda_quit_time);
}

int Time_System :: refresh(Time_System_Node time_system_node){
    if(time_system_node==Time_Create_NODE){
	m_cpu_create_time=cpuSecond();
	cudaEventRecord(m_cuda_create_time, 0);
        return 0;
    }
    if(time_system_node==Time_Start_NODE){
	m_cpu_start_time=cpuSecond();
	cudaEventRecord(m_cuda_start_time, 0);
	return 0;
    }
    if(time_system_node==Time_Pre_NODE){
	m_cpu_pre_time=cpuSecond();
	cudaEventRecord(m_cuda_pre_time, 0);
	return 0;
    }
    if(time_system_node==Time_Impl_NODE){
	m_cpu_impl_time=cpuSecond();
	cudaEventRecord(m_cuda_impl_time, 0);
	return 0;
    }
    if(time_system_node==Time_Quit_NODE){
	m_cpu_impl_time=cpuSecond();
	cudaEventRecord(m_cuda_impl_time, 0);
	return 0;
    }
    return -1;
}

double Time_System :: CPU_TIME(double start_time, double end_time){
    return end_time-start_time; 
}

float Time_System :: CUDA_TIME(cudaEvent_t &start_time, cudaEvent_t &end_time){
     cudaEventSynchronize(start_time);
     cudaEventSynchronize(end_time);
     float time;
     cudaEventElapsedTime(&time, start_time, end_time);
     return time;
}

}
