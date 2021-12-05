#include "rsa_crt.h"
#include "rsa_final.h"
#include "stdlib.h"
#include "string.h"

namespace namespace_rsa_final{

CRT_N :: CRT_N(){
    log_info(CRT_CREATE_LOG);

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

    log_info(CRT_CREATE_LOG);

}

CRT_N :: CRT_N (CRT_N &crt_n){
    m_rsa_n = crt_n.m_rsa_n;
    m_zero = crt_n.m_zero;
    m_one = crt_n.m_one;
    m_R =crt_n.m_R;
    m_n0_inverse = crt_n.m_n0_inverse;

    memcpy(m_log_file_name,crt_n.m_log_file_name,LOG_FILE_NAME_LENGTH);
}

CRT_N& CRT_N :: operator= (CRT_N &crt_n){

    m_rsa_n = crt_n.m_rsa_n;
    m_zero = crt_n.m_zero;
    m_one = crt_n.m_one;
    m_R =crt_n.m_R;
    m_n0_inverse = crt_n.m_n0_inverse;

    memcpy(m_log_file_name,crt_n.m_log_file_name,LOG_FILE_NAME_LENGTH);
    return * this;
}

CRT_N :: ~CRT_N (){
}

int CRT_N :: CRT_MOD_MUL(BN_WORD a, BN_WORD b, BN_WORD &result){
    BN_WORD aR, bR;
    aR=(a*m_R)%m_rsa_n.m_n;
    bR=(b*m_R)%m_rsa_n.m_n;

    int n_top=m_rsa_n.m_n.m_top;
   
    BN_PART *bp_a, *bp_b, *bp_n, *bp_result;
    cudaMallocManaged((void**)&(bp_a),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_b),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_n),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_result),WARP_SIZE*sizeof(BN_PART));

    memset(bp_a,0,WARP_SIZE);
    memset(bp_b,0,WARP_SIZE);
    memset(bp_n,0,WARP_SIZE);
    memset(bp_result,0,WARP_SIZE);

    memcpy(bp_a,aR.m_data,aR.m_top*sizeof(BN_PART));
    memcpy(bp_b,bR.m_data,bR.m_top*sizeof(BN_PART));
    memcpy(bp_n,m_rsa_n.m_n.m_data,m_rsa_n.m_n.m_top*sizeof(BN_PART));
    
    GPU_WORD_mod_mul<<<1,WARP_SIZE>>>(bp_a,bp_b,bp_n,m_n0_inverse,bp_result, n_top);
    cudaDeviceSynchronize();

    result.setzero(); 
    memcpy(result.m_data,bp_result,n_top*sizeof(BN_PART));
    result.check_top();

    log_info(CRT_MOD_MUL_LOG,a,b,result);

    cudaFree(bp_a);
    cudaFree(bp_b);
    cudaFree(bp_n);
    cudaFree(bp_result);
    return 1;
}

int CRT_N :: CRT_MOD_EXP(BN_WORD a, BN_WORD e, BN_WORD &result){
    BN_WORD aR;
    aR=(a*m_R)%m_rsa_n.m_n;

    int n_top=m_rsa_n.m_n.m_top;
   
    BN_PART *bp_a,*bp_e,*bp_r,*bp_n,*bp_result;
    int E_bits=e.m_top*sizeof(BN_PART)*8;

    cudaMallocManaged((void**)&(bp_a),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_e),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_r),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_n),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_result),WARP_SIZE*sizeof(BN_PART));

    memset(bp_a,0,WARP_SIZE);
    memset(bp_e,0,WARP_SIZE);
    memset(bp_n,0,WARP_SIZE);
    memset(bp_r,0,WARP_SIZE);
    memset(bp_result,0,WARP_SIZE);
    
    memcpy(bp_a,aR.m_data,aR.m_top*sizeof(BN_PART));
    memcpy(bp_e,e.m_data,e.m_top*sizeof(BN_PART));
    memcpy(bp_n,m_rsa_n.m_n.m_data,m_rsa_n.m_n.m_top*sizeof(BN_PART));
    memcpy(bp_r,m_R.m_data,m_R.m_top*sizeof(BN_PART));

    GPU_WORD_mod_exp<<<1,WARP_SIZE*2>>>(bp_a,bp_e,E_bits,bp_r,bp_n,m_n0_inverse,bp_result, n_top);
    cudaDeviceSynchronize();

    result.setzero(); 
    memcpy(result.m_data,bp_result,n_top*sizeof(BN_PART));
    result.check_top();

    log_info(CRT_MOD_EXP_LOG,a,e,result);
    
    cudaFree(bp_a);
    cudaFree(bp_e);
    cudaFree(bp_n);
    cudaFree(bp_r);
    cudaFree(bp_result);
    return 1;
}

int CRT_N :: CRT_MOD_EXP_ARRAY(BN_WORD_ARRAY a, BN_WORD e, BN_WORD_ARRAY &result){
    int bn_word_num=a.m_bn_word_num;
    BN_WORD_ARRAY aR(bn_word_num);
    for(int i=0;i<bn_word_num;i++){
        aR.m_bn_word[i]=(a.m_bn_word[i]*m_R)%m_rsa_n.m_n;    
    }

    BN_PART *bp_a,*bp_e,*bp_r,*bp_n,*bp_result;
    int E_bits=e.m_top*sizeof(BN_PART)*8;
    int n_top=m_rsa_n.m_n.m_top;

    cudaMallocManaged((void**)&(bp_a),bn_word_num*WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_e),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_r),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_n),WARP_SIZE*sizeof(BN_PART));
    cudaMallocManaged((void**)&(bp_result),bn_word_num*WARP_SIZE*sizeof(BN_PART));

    memset(bp_a,0,bn_word_num*WARP_SIZE);
    memset(bp_e,0,WARP_SIZE);
    memset(bp_n,0,WARP_SIZE);
    memset(bp_r,0,WARP_SIZE);
    memset(bp_result,0,bn_word_num*WARP_SIZE);

    for(int i=0;i<bn_word_num;i++){
        memcpy(bp_a+i*WARP_SIZE,aR.m_bn_word[i].m_data,aR.m_bn_word[i].m_top*sizeof(BN_PART));
    }
    memcpy(bp_e,e.m_data,e.m_top*sizeof(BN_PART));
    memcpy(bp_n,m_rsa_n.m_n.m_data,m_rsa_n.m_n.m_top*sizeof(BN_PART));
    memcpy(bp_r,m_R.m_data,m_R.m_top*sizeof(BN_PART));

    GPU_WORD_ARRAY_mod_exp<<<bn_word_num,WARP_SIZE*2>>>(bp_a,bp_e,E_bits,bp_r,bp_n,m_n0_inverse,bp_result,n_top);
    cudaDeviceSynchronize();

    for(int i=0;i<bn_word_num;i++){
        result.m_bn_word[i].setzero();    
	memcpy(result.m_bn_word[i].m_data,bp_result+i*WARP_SIZE,n_top*sizeof(BN_PART));
    	result.m_bn_word[i].check_top();
    }

    log_info(CRT_MOD_EXP_ARRAY_LOG,a,e,result);

    cudaFree(bp_a);
    cudaFree(bp_e);
    cudaFree(bp_n);
    cudaFree(bp_r);
    cudaFree(bp_result);
    return 1;
}

}
