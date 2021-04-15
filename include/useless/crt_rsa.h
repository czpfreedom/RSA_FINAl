#ifndef CRT_RSA_H
#define CRT_RSA_H

#include "bn_word_parallel_mont_exp.h"

#define rns_word_mul_mod(a,b,n) (RNS_WORD)((((unsigned long)a)*((unsigned long)b))%((unsigned long)n))
#define rns_word_add_mod(a,b,n) (RNS_WORD)((((unsigned long)a)+((unsigned long)b))%((unsigned long)n))
#define rns_word_rand()  (RNS_WORD)(((unsigned long)(rand()))%((unsigned long)((unsigned long)UN_INT_MAX+1)))
