#include "bn_part_operation.h"


#ifndef INT_MASK2L
#define INT_MASK2L (0xffffffff)
#endif

#ifndef INT_MASK2l
#define INT_MASK2l (0xffff)
#endif

#ifndef LONG_MASK2L
#define LONG_MASK2L (0xffffffffffffffffL)// unsigned long
#endif

#ifndef LONG_MASK2l
#define LONG_MASK2l (0xffffffffL)        // unsigned long also  but with 32 zeros at the top
#endif

__host__ __device__ int int_mod(const int a,const int b){
    int c=a;
    while(c<0){
        c=c+b;
    }
    return c%b;
}

#ifdef BN_PART_32

__device__ __host__ int BN_PART_mul(const BN_PART a, const BN_PART b, BN_PART &u, BN_PART &v){
    unsigned long result = (((unsigned long)a)&LONG_MASK2l)*(((unsigned long)b)&LONG_MASK2l);
    u=(unsigned int)((result>>(sizeof(unsigned int)*8))&LONG_MASK2l);
    v=(unsigned int)((result)&LONG_MASK2l);
    return 0;
}

#endif

#ifdef BN_PART_64
__device__ __host__ int BN_PART_mul(const BN_PART a, const BN_PART b, BN_PART &u, BN_PART &v){
    BN_PART ah= (a>>32)&LONG_MASK2l;
    BN_PART al= a&LONG_MASK2l;
    BN_PART bh= (b>>32)&LONG_MASK2l;
    BN_PART bl= b&LONG_MASK2l;

    BN_PART carry= 0;
    BN_PART ll=al*bl;
    BN_PART hl=ah*bl;
    BN_PART lh=al*bh;
    BN_PART hh=ah*bh;
    v=ll+(hl<<32);
    if(v<ll){
        carry=carry+1;
