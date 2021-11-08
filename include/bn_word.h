#ifndef BN_WORD_H
#define BN_WORD_H

#include "bn_part.h"
#include "stdio.h"

namespace namespace_rsa_final{

class GPU_WORD{

public:
      BN_PART m_data[BN_WORD_LENGTH_MAX];
    int m_neg;
    int m_top;

    __host__ __device__ GPU_WORD();
    __host__ __device__ GPU_WORD(GPU_WORD &gw);
    __host__ __device__ GPU_WORD& operator=(GPU_WORD &gw);
    __host__ __device__ ~GPU_WORD();

    __host__ __device__ GPU_WORD& operator+ (GPU_WORD &gw);
    __host__ __device__ GPU_WORD& operator- (GPU_WORD &gw);
    __host__ __device__ GPU_WORD& operator* (GPU_WORD &gw);
    __host__ __device__ GPU_WORD& operator/ (GPU_WORD &gw);
    __host__ __device__ GPU_WORD& operator% (GPU_WORD &gw);
    
    __host__ __device__ bool operator==(GPU_WORD &gw_2);
    __host__ __device__ bool operator!=(GPU_WORD &gw_2);
    __host__ __device__ bool operator> (GPU_WORD &gw_2);
    __host__ __device__ bool operator< (GPU_WORD &gw_2);
    __host__ __device__ bool operator>=(GPU_WORD &gw_2);
    __host__ __device__ bool operator<=(GPU_WORD &gw_2);  

    __host__ __device__ BN_PART get_bit(int i);
    __host__ __device__ int left_shift (int bits);
    __host__ __device__ int right_shift(int bits);
    __host__ __device__ int check_top(); //check top and zeor together
    __host__ __device__ int change_neg();
    
    __host__ int BN_WORD_2_GPU_WORD(BN_WORD &bw);
    __host__ int GPU_WORD_2_BN_WORD(BN_WORD &bw);

    __host__ __device__ int setzero();
    __host__ __device__ int setone();
    __host__ __device__ int setR(int top);

    __host__ __device__ int print();

};

}

#endif

