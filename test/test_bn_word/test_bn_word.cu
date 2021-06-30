#include "bn_word.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#define DMAX 32
#define LOOP_NUM 1000

using namespace std;


int main(){
    BIGNUM *open_a, *open_b, *open_n, *open_result, *open_q, *open_r;
    BN_WORD *bn_a,*bn_b, *bn_n, *bn_result, *bn_q, *bn_r;
    BN_WORD *bn_open_result, *bn_open_q, *bn_open_r;
    BN_PART part_n, part_open_result, part_result;
    BN_CTX *ctx;
    int sum;

// test_bn_word_add
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);

	BN_add(open_result,open_a,open_b);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	BN_WORD_add(bn_a,bn_b,bn_result);
	if(BN_WORD_cmp(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}

    }
    cout<<"test_bn_word_add:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

// test_bn_word_sub
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
	BN_add(open_a,open_a,open_b);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);

	BN_sub(open_result,open_a,open_b);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	BN_WORD_sub(bn_a,bn_b,bn_result);
	if(BN_WORD_cmp(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_sub:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

// test_bn_word_mul
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);

	BN_mul(open_result,open_a,open_b,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	BN_WORD_mul(bn_a,bn_b,bn_result);
	if(BN_WORD_cmp(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_mul:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

    
// test_bn_word_div
    open_a=BN_new();
    open_b=BN_new();
    open_q=BN_new();
    open_r=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_q=BN_WORD_new(DMAX);
    bn_r=BN_WORD_new(DMAX);
    bn_open_q=BN_WORD_new(DMAX);
    bn_open_r=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);

	BN_div(open_q,open_r,open_a,open_b,ctx);
	BN_WORD_openssl_transform(open_q,bn_open_q,DMAX);
	BN_WORD_openssl_transform(open_r,bn_open_r,DMAX);

	BN_WORD_div(bn_a,bn_b,bn_q,bn_r);
	if((BN_WORD_cmp(bn_q,bn_open_q)==0)&&(BN_WORD_cmp(bn_r,bn_open_r)==0)){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_div:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_q);
    BN_free(open_r);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_q);
    BN_WORD_free(bn_r);
    BN_WORD_free(bn_open_q);
    BN_WORD_free(bn_open_r);
    
// test_bn_word_mod
    open_a=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_n,bn_n,DMAX);

	BN_mod(open_result,open_a,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	BN_WORD_mod(bn_a,bn_n,bn_result);
	if(BN_WORD_cmp(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_mod:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_n);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

//test_bn_word_add_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);
	BN_WORD_openssl_transform(open_n,bn_n,DMAX);

	BN_mod_add(open_result,open_a,open_b,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	BN_WORD_add_mod(bn_a,bn_b,bn_n,bn_result);
	if(BN_WORD_cmp(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_add_mod:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_n);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

//test_bn_word_mul_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_n=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_open_result=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,DMAX*sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	BN_WORD_openssl_transform(open_b,bn_b,DMAX);
	BN_WORD_openssl_transform(open_n,bn_n,DMAX);

	BN_mod_mul(open_result,open_a,open_b,open_n,ctx);
	BN_WORD_openssl_transform(open_result,bn_open_result,DMAX);

	BN_WORD_mul_mod(bn_a,bn_b,bn_n,bn_result);
	if(BN_WORD_cmp(bn_result,bn_open_result)==0){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_mul_mod:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_n);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_open_result);

//test_bn_word_bn_part_mod
    open_a=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    bn_a=BN_WORD_new(DMAX);

    sum=0;
    for (int i=0;i<LOOP_NUM;i++){
	BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,sizeof(BN_PART)*8,0,0);

	BN_WORD_openssl_transform(open_a,bn_a,DMAX);
	part_n=open_n->d[0];

	BN_mod(open_result,open_a,open_n,ctx);
	part_open_result=open_result->d[0];

	BN_WORD_BN_PART_mod(bn_a,part_n,part_result);
	if(part_result==part_open_result){
	    sum=sum+1;
	}
    }
    cout<<"test_bn_word_bn_part_mod:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

    BN_WORD_free(bn_a);

    return 0;
}
