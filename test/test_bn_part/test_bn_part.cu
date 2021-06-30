#include "bn_word.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"

#ifdef BN_PART_64
#define LOOP_NUM 1000

using namespace std;

int main(){

    BIGNUM *open_a, *open_b, *open_n, *open_a_inverse, *open_result;
    BN_PART part_a, part_b, part_n, part_a_inverse, part_result;
    BN_PART part_open_a_inverse, part_open_result;
    BN_CTX *ctx;

    int sum;

//BN_PART_mod_inverse b=0
    open_a=BN_new();
    open_b=BN_new();
    open_a_inverse=BN_new();
    ctx=BN_CTX_new();

    sum =0;

    for(int i=0;i<LOOP_NUM;i++ ){
        BN_rand(open_a,sizeof(BN_PART)*8,0,0);
        BN_rand(open_b,2*sizeof(BN_PART)*8,0,0);

        open_a->d[0]=open_a->d[0]*2+1; // to make sure open_a be an odd number
        part_a=open_a->d[0];
        
	open_b->d[0]=0;
        open_b->d[1]=1;

        BN_mod_inverse(open_a_inverse,open_a,open_b,ctx);

        part_open_a_inverse=open_a_inverse->d[0];

        BN_PART_mod_inverse(part_a,0,part_a_inverse);

        if(part_open_a_inverse==part_a_inverse){
	    sum=sum+1;
        }
    }
    cout<<"test_bn_part_mod_inverse b==0:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_a_inverse);
    BN_CTX_free(ctx);

//BN_PART_mod_inverse b!=0
    open_a=BN_new();
    open_b=BN_new();
    open_a_inverse=BN_new();

    ctx=BN_CTX_new();

    sum =0;

    for(int i=0;i<LOOP_NUM;i++ ){

        BN_rand(open_a,sizeof(BN_PART)*8,0,0);
        BN_rand(open_b,sizeof(BN_PART)*8,0,0);

        open_a->d[0]=1;
        part_a=open_a->d[0];
        part_b=open_b->d[0];

        BN_mod_inverse(open_a_inverse,open_a,open_b,ctx);

        part_open_a_inverse=open_a_inverse->d[0];

        BN_PART_mod_inverse(part_a,part_b,part_a_inverse);

        if(part_open_a_inverse==part_a_inverse){
	    sum=sum+1;
        }
    }
    cout<<"test_bn_part_mod_inverse b!=0:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_a_inverse);
    BN_CTX_free(ctx);

//BN_PART_add_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    sum =0;

    for(int i=0;i<LOOP_NUM;i++ ){
	BN_rand(open_a,sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,sizeof(BN_PART)*8,0,0);
	        
	part_a=open_a->d[0];
	part_b=open_b->d[0];
	part_n=open_n->d[0];

	BN_mod_add(open_result,open_a,open_b,open_n,ctx);

	part_open_result=open_result->d[0];

	BN_PART_add_mod(part_a,part_b,part_n,part_result);
	
	if(part_open_result==part_result){
	    sum=sum+1;
	}
    }

    cout<<"test_bn_part_add_mod:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

//BN_PART_mul_mod
    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();

    ctx=BN_CTX_new();

    sum =0;

    for(int i=0;i<LOOP_NUM;i++ ){
	BN_rand(open_a,sizeof(BN_PART)*8,0,0);
	BN_rand(open_b,sizeof(BN_PART)*8,0,0);
	BN_rand(open_n,sizeof(BN_PART)*8,0,0);
	        
	part_a=open_a->d[0];
	part_b=open_b->d[0];
	part_n=open_n->d[0];

	BN_mod_mul(open_result,open_a,open_b,open_n,ctx);

	part_open_result=open_result->d[0];

	BN_PART_mul_mod(part_a,part_b,part_n,part_result);
	
	if(part_open_result==part_result){
	    sum=sum+1;
	}
    }

    cout<<"test_bn_part_mul_mod:"<<endl;
    cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<endl;

    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_n);
    BN_free(open_result);
    BN_CTX_free(ctx);

    return 0;
}

#endif
