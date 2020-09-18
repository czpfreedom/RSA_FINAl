#ifndef XAVIER_RSA_H
#define XAVIER_RSA_H

#include "bn_num.h"

typedef struct

typedef struct xavier_rsa_st{
    BN_NUM *n;
    BN_NUM *e;
    BN_NUM *d;
    BN_NUM *p;
    BN_NUM *q;
    BN_NUM *dmp1;
    BN_NUM *dmq1;
    BN_NUM *iqmp;
}XAV_RSA;

XAV_RSA *XAV_RSA_NEW(int wmax, int dmax);

XAV_RSA *XAV_RSA_NEW_KEY(BN_NUM *n, BN_NUM *e, BN_NUM *d);

int XAV_RSA_SET_KEY(XAV_RSA *);



#endif
