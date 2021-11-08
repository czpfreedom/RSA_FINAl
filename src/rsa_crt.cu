#include "rsa_crt.h"
#include "rsa_final.h"
#include "stdlib.h"
#include "string.h"

namespace namespace_rsa_final{

CRT_N :: CRT_N(){

}

CRT_N :: CRT_N (RSA_N rsa_n){
    m_rsa_n=rsa_n;
    m_zero.setzero();
    m_one.setone();
    int R_top=rsa_n.m_n.m_top+1;
    m_R.setR(R_top);
    m_R=m_R%m_rsa_n.m_n;
    BN_PART_mod_inverse(m_rsa_n.m_n.m_data[0], 0, m_n0_inverse);
    m_n0_inverse=0-m_n0_inverse;
//n_neg
    struct timeval tv;
    gettimeofday(&tv,NULL);
    m_time_stamp = * new Time_Stamp(tv);
    m_time_system = * new Time_System();
    log_create();
}

CRT_N :: CRT_N (CRT_N &crt_n){
    m_rsa_n = crt_n.m_rsa_n;
    m_zero = crt_n.m_zero;
    m_one = crt_n.m_one;
    m_R =crt_n.m_R;
    m_n0_inverse = crt_n.m_n0_inverse;

    m_log_file = crt_n.m_log_file;
    m_time_stamp = crt_n.m_time_stamp;
    m_time_system = crt_n.m_time_system;
}

CRT_N& CRT_N :: operator= (CRT_N &crt_n){

    m_rsa_n = crt_n.m_rsa_n;
    m_zero = crt_n.m_zero;
    m_one = crt_n.m_one;
    m_R =crt_n.m_R;
    m_n0_inverse = crt_n.m_n0_inverse;

    m_log_file = crt_n.m_log_file;
    m_time_stamp = crt_n.m_time_stamp;
    m_time_system = crt_n.m_time_system;

    return * this;
}


CRT_N :: ~CRT_N (){
    log_quit();
}

int CRT_N :: CRT_MOD_MUL(BN_WORD a, BN_WORD b, BN_WORD &result){
    BN_WORD aR, bR;
    BN_WORD n=m_rsa_n.m_n;
    aR=(a*m_R)%n;
    bR=(b*m_R)%n;
   
    BN_PART *bp_a;
    BN_PART *bp_b;
    BN_PART *bp_n;
    BN_PART *bp_result;
    cudaMallocManaged((void**)&(bp_a),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_b),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_n),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_result),WARP_SIZE*sizeof(BN_PART));

    for(int i=0;i<WARP_SIZE;i++){
        bp_a[i]=0;
        bp_b[i]=0;
        bp_n[i]=0;
        bp_result[i]=0;
    }

    for(int i=0;i<aR.m_top;i++){
	bp_a[i]=aR.m_data[i];
    }
    
    for(int i=0;i<bR.m_top;i++){
	bp_b[i]=bR.m_data[i];
    }
    for(int i=0;i<n.m_top;i++){
	bp_n[i]=n.m_data[i];
    }
    
    GPU_WORD_mod_mul<<<1,WARP_SIZE>>>(bp_a,bp_b,bp_n,m_n0_inverse,bp_result);
    cudaDeviceSynchronize();

    result.setzero(); 
    for(int i=0;i<WARP_SIZE;i++){
	result.m_data[i]=bp_result[i];
    }
    result.m_top=32;
    
    cudaFree(bp_result);
    return 1;
}

int CRT_N :: CRT_MOD_EXP(BN_WORD a, BN_WORD e, BN_WORD &result){
    BN_WORD aR;
    BN_WORD n=m_rsa_n.m_n;
    aR=(a*m_R)%n;
    
    int E_bits=e.m_top*sizeof(BN_PART)*8;
   
    BN_PART *bp_a;
    BN_PART *bp_e;
    BN_PART *bp_r;
    BN_PART *bp_n;
    BN_PART *bp_result;
    cudaMallocManaged((void**)&(bp_a),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_e),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_r),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_n),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_result),WARP_SIZE*sizeof(BN_PART));

    for(int i=0;i<WARP_SIZE;i++){
        bp_a[i]=0;
        bp_e[i]=0;
	bp_r[i]=0;
        bp_n[i]=0;
        bp_result[i]=0;
    }

    for(int i=0;i<aR.m_top;i++){
	bp_a[i]=aR.m_data[i];
    }
    
    for(int i=0;i<e.m_top;i++){
	bp_e[i]=e.m_data[i];
    }
    for(int i=0;i<n.m_top;i++){
	bp_n[i]=n.m_data[i];
    }
    for(int i=0;i<m_R.m_top;i++){
	bp_r[i]=m_R.m_data[i];
    }

    GPU_WORD_mod_exp<<<1,WARP_SIZE*2>>>(bp_a,bp_e,E_bits,bp_r,bp_n,m_n0_inverse,bp_result);
    cudaDeviceSynchronize();

    result.setzero(); 
    for(int i=0;i<WARP_SIZE;i++){
	result.m_data[i]=bp_result[i];
    }
    result.m_top=32;
    
    cudaFree(bp_result);
    return 1;
    
}


int CRT_N :: log_create(){

    char file_name[200];
    snprintf(file_name,sizeof(file_name), "%s%s.log",RSA_FINAL_LOG, m_time_stamp.m_abbr);
    m_log_file = fopen(file_name, "a+");
    return 1;

}

int CRT_N :: log_info(LOG_TYPE log_type){
    return 1;
}

int CRT_N :: time_info(LOG_TYPE log_type, TIME_TYPE time_type){
    return 1;
}

int CRT_N :: log_quit(){

    fclose(m_log_file);
    return 1; 
    
}

}
