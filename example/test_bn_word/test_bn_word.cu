#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"


#define DMAX 32

using namespace std;

int main(){

	
    BIGNUM *open_a, *open_b,*open_result;
    BN_WORD *bn_a, *bn_b, *bn_result, *bn_word_result;
    int transform_result;
    int *cmp_return_value, *add_return_value, *sub_return_value,*shift_return_value;
// test add
    cout<<"test add:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_add(open_result,open_a,open_b);
    
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_result,bn_result,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;    
	exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cudaMallocManaged((void**)&(add_return_value),sizeof(int));
    BN_WORD_add(bn_a,bn_b,bn_word_result,add_return_value);
    if(*(add_return_value)!=0){
        cerr<<"Error: add failed"<<endl;
	exit(1);
    }
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);
    cudaFree(add_return_value);

//test sub

    cout<<"test sub:"<<endl;
    open_a=BN_new();
    open_b=BN_new();
    open_result=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    BN_rand(open_b,DMAX*(sizeof(BN_ULONG)*8),0,0);
    BN_sub(open_result,open_a,open_b);
    
    bn_a=BN_WORD_new(DMAX);
    bn_b=BN_WORD_new(DMAX);
    bn_result=BN_WORD_new(DMAX);
    bn_word_result=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX)+BN_WORD_openssl_transform(open_b,bn_b,DMAX)+BN_WORD_openssl_transform(open_result,bn_result,DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;    
	exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cout<<"b:"<<endl;
    BN_WORD_print(bn_b);
    cout<<"open_result"<<endl;
    BN_WORD_print(bn_result);
    cudaMallocManaged((void**)&(sub_return_value),sizeof(int));
    cudaMallocManaged((void**)&(cmp_return_value),sizeof(int));
    BN_WORD_cmp(bn_a,bn_b,cmp_return_value);
    BN_WORD_sub(bn_a,bn_b,bn_word_result,cmp_return_value,sub_return_value);
    cout<<"sub_return:"<<*(sub_return_value)<<endl;
    if(*(sub_return_value)!=0){
        cerr<<"Error: sub failed"<<endl;
	exit(1);
    }
    cout<<"bn_word_result"<<endl;
    BN_WORD_print(bn_word_result);
    BN_free(open_a);
    BN_free(open_b);
    BN_free(open_result);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_b);
    BN_WORD_free(bn_result);
    BN_WORD_free(bn_word_result);
    cudaFree(cmp_return_value);
    cudaFree(sub_return_value);

//test shift
    open_a=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    bn_a=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    bn_result=BN_WORD_new(DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cudaMallocManaged((void**)&(shift_return_value),sizeof(int));
    BN_WORD_left_shift(bn_a,bn_result,10,shift_return_value);
    cout<<"left_shift:"<<endl;
    BN_WORD_print(bn_result);
    BN_WORD_right_shift(bn_a,bn_result,10,shift_return_value);
    cout<<"right_shift:"<<endl;
    BN_WORD_print(bn_result);
    BN_free(open_a);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_result);
    cudaFree(shift_return_value);


//test shift_bits
    open_a=BN_new();
    BN_rand(open_a,DMAX*(sizeof(BN_ULONG)*8),1,0);
    bn_a=BN_WORD_new(DMAX);
    transform_result=BN_WORD_openssl_transform(open_a,bn_a,DMAX);
    bn_result=BN_WORD_new(DMAX);
    if(transform_result!=0){
        cerr<<"Error: transform failed"<<endl;
        exit(1);
    }
    cout<<"a:"<<endl;
    BN_WORD_print(bn_a);
    cudaMallocManaged((void**)&(shift_return_value),sizeof(int));
    BN_WORD_left_shift_bits(bn_a,bn_result,4,shift_return_value);
    cout<<"left_shift_bits:"<<endl;
    BN_WORD_print(bn_result);
    BN_WORD_right_shift_bits(bn_a,bn_result,4,shift_return_value);
    cout<<"right_shift_bits:"<<endl;
    BN_WORD_print(bn_result);
    BN_free(open_a);
    BN_WORD_free(bn_a);
    BN_WORD_free(bn_result);
    cudaFree(shift_return_value);


}


