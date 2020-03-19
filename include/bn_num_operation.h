#ifndef BN_NUM_OPER_H
#define BN_NUM_OPER_H

#include "bn_num.h"
#include "bn_word_operation.h"
#include "bn_word.h"

BN_NUM *BN_NUM_new(int wmax);

void BN_NUM_free(BN_NUM *a);

#endif
