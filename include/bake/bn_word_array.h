#include "bn_word.h"

typedef struct bignumber_word_array_st{
	    int word_num;
	        BN_WORD **bn_word;
}BN_WORD_ARRAY;

BN_WORD_ARRAY *BN_WORD_ARRAY_new(int word_num, int dmax);

void BN_WORD_ARRAY_free(BN_WORD_ARRAY *a);
