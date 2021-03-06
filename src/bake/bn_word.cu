#include "bn_word.h"
#include "stdlib.h"
#include <stdio.h>
#include "sstream"
#include "iostream"
#include "string"

namespace namespace_rsa_final{

__host__ BN_WORD *BN_WORD_new(int dmax){
    BN_WORD *a;
    cudaMallocManaged((void**)&(a),sizeof(BN_WORD));
    a->dmax=dmax;
    cudaMallocManaged((void**)&(a->d),dmax*sizeof(BN_PART));
    return a;
}

__host__ void BN_WORD_free(BN_WORD *a){
    cudaFree(a->d);
    cudaFree(a);
}

__device__ BN_WORD *BN_WORD_new_device(int dmax){
    BN_WORD *a;
    a=(BN_WORD*)malloc(sizeof(BN_WORD));
    a->dmax=dmax;
    a->d=(BN_PART*)malloc(dmax*sizeof(BN_PART));
    return a;
}

__device__ void BN_WORD_free_device(BN_WORD *a){
    free(a->d);
    free(a);
}

__host__ __device__ void BN_WORD_setzero(BN_WORD *a){
    for(int i=0;i<a->dmax;i++){
        a->d[i]=0;
    }
}

__host__ __device__ void BN_WORD_setone(BN_WORD *a){
    a->d[0]=1;
    for(int i=1;i<a->dmax;i++){
        a->d[i]=0;
    }
}

__host__ int BN_WORD_copy_host(const BN_WORD *a,BN_WORD *b){
    return BN_WORD_copy(a,b);
}


__host__ __device__ int BN_WORD_copy(const BN_WORD *a,BN_WORD *b){
    if(a->dmax!=b->dmax){
        return -1;
    }
    for(int i=0;i<a->dmax;i++){
        b->d[i]=a->d[i];
    }
    return 0;
}

__host__ int BN_WORD_print(const BN_WORD *a){
    printf("dmax:%d\n",a->dmax);
    for(int i=(a->dmax)-1;i>=0;i--){
#ifdef BN_PART_32
	printf("%x,",a->d[i]);
#endif
#ifdef BN_PART_64
        printf("%lx,",a->d[i]);
#endif
    }
    printf("\n");
    return 0;
}

__device__ int BN_WORD_print_device(const BN_WORD *a){
    printf("dmax:%d\n",a->dmax);
    for(int i=(a->dmax)-1;i>=0;i--){
#ifdef BN_PART_32
	printf("%x,",a->d[i]);
#endif
#ifdef BN_PART_64
        printf("%lx,",a->d[i]);
#endif
    }
    printf("\n");
    return 0;
}

__host__ int BN_WORD_print_log(FILE *out, BN_WORD *a){
    fprintf(out,"dmax:%x\n", a->dmax);	
    for(int i=(a->dmax)-1;i>=0;i--){
#ifdef BN_PART_32
        fprintf(out,"%x,", a->d[i]);	
#endif
#ifdef BN_PART_64
        fprintf(out,"%lx,", a->d[i]);	
#endif
    }
    fprintf(out,"\n");	
    return 0;
}

__host__ __device__ int BN_WORD_cmp(const BN_WORD *a,const BN_WORD *b){
    if((a->dmax)!=(b->dmax)){
        return -1;
    }
    for(int i=(a->dmax)-1;i>=0;i--){
        if(a->d[i]>b->d[i]){
            return 1;
        }
        if(a->d[i]<b->d[i]){
            return 2;
        }
    }
    return 0;
}

__host__ __device__ BN_PART bn_word_get_bit(const BN_WORD *a, int i){
    return BN_PART_get_bit(a->d[i/(sizeof(BN_PART)*8)],i%(sizeof(BN_PART)*8));
}

__host__ __device__ int BN_WORD_left_shift(const BN_WORD *a,BN_WORD *b,int words){
    if((a->dmax)!=(b->dmax)){
        return -1;
    }
    if((a->dmax)<words){
        return -2;
    }
    for(int i=(a->dmax)-1;i>=words;i--){
        b->d[i]=a->d[i-words];
    }
    for(int i=words-1;i>=0;i--){
        b->d[i]=0;
    }
    return 0;
}


__host__ __device__ int BN_WORD_left_shift_bits(const BN_WORD *a,BN_WORD *b,int bits){
    int num_bits=bits%(sizeof(BN_PART)*8);
    int num_bnpart=bits/(sizeof(BN_PART)*8);
    if((a->dmax)!=(b->dmax)){
        return -1;
    }
    b->d[num_bnpart]=a->d[0]<<num_bits;
    for (int i=1+num_bnpart;i<a->dmax;i++){
	if(num_bits==0){
	    b->d[i]=((a->d[i-num_bnpart])<<num_bits);
	}
	else{
	    b->d[i]=((a->d[i-num_bnpart])<<num_bits)+((a->d[i-1-num_bnpart])>>(sizeof(BN_PART)*8-num_bits));
	}
    }
    for (int i=0;i<num_bnpart;i++){
        b->d[i]=0;
    }
    return 0;
}

__host__ __device__ int BN_WORD_right_shift(const BN_WORD *a,BN_WORD *b,int words){
    if((a->dmax)!=(b->dmax)){
        return -1;
    }
    if((a->dmax)<words){
        return -3;
    }
    for(int i=0;i<a->dmax-words;i++){
        b->d[i]=a->d[i+words];
    }
    for(int i=a->dmax-words;i<a->dmax;i++){
        b->d[i]=0;
    }
    return 0;
}

__host__ __device__ int BN_WORD_right_shift_bits(const BN_WORD *a,BN_WORD *b,int bits){
    int num_bits=bits%(sizeof(BN_PART)*8);
    int num_bnpart=bits/(sizeof(BN_PART)*8);
    if((a->dmax)!=(b->dmax)){
        return -1;
    }
    for (int i=0;i<a->dmax-1-num_bnpart;i++){
	if(num_bits==0){
	    b->d[i]=(a->d[i+num_bnpart])>>num_bits;
	}
	else{
	    b->d[i]=((a->d[i+num_bnpart])>>num_bits)+((a->d[i+num_bnpart+1])<<(sizeof(BN_PART)*8-num_bits));
	}
    }
    b->d[a->dmax-1-num_bnpart]=(a->d[a->dmax-1])>>num_bits;
    for(int i=a->dmax-num_bnpart;i<a->dmax;i++){
        b->d[i]=0;
    }
    return 0;
}

__host__ __device__ int BN_WORD_add(const BN_WORD *a, const BN_WORD *b, BN_WORD *result){
    BN_PART mid_value;
    BN_PART carry1=0;
    BN_PART carry2=0;
    for (int i=0;i<a->dmax;i++){
        carry2=carry1;
        carry1=0;
        mid_value=a->d[i]+carry2;
        if(mid_value<a->d[i]){
            carry1=1;
        }
        mid_value=mid_value+b->d[i];
        if(mid_value<b->d[i]){
            carry1=1;
        }
        result->d[i]=mid_value;
    }
    return 0;
}

__host__ __device__ int BN_WORD_sub(const BN_WORD *a, const BN_WORD *b, BN_WORD *result){
    BN_PART mid_value1, mid_value;
    BN_PART carry1,carry2;
    int cmp=BN_WORD_cmp(a,b);
    if(cmp==0){
        BN_WORD_setzero(result);
	return 0;
    }
    result->dmax=a->dmax;
    carry2=0;
    carry1=0;
    for(int i=0;i<a->dmax;i++){
        carry2=carry1;
	carry1=0;
	mid_value1=a->d[i]-carry2;
	if(mid_value1>a->d[i]){
	    carry1=1;
	}
	mid_value=mid_value1-b->d[i];
	if(mid_value>mid_value1){
	    carry1=1;
	}
	result->d[i]=mid_value;
    }
    return 0;
}

__host__ int BN_WORD_mul(const BN_WORD *a, const BN_WORD *b, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *result_temp;
    BN_WORD *a_temp;
    result_temp=BN_WORD_new(dmax);
    a_temp=BN_WORD_new(dmax);
    BN_WORD_setzero(result_temp);
    BN_WORD_copy(a,a_temp);
    for (int i=0;i<dmax;i++){
        for(int j=0;j<sizeof(BN_PART)*8;j++){
	    if(BN_PART_get_bit(b->d[i],j)==1){
	        BN_WORD_add(result_temp,a_temp,result_temp);
	    }
	    BN_WORD_left_shift_bits(a,a_temp,i*sizeof(BN_PART)*8+j+1);
	}
    }
    BN_WORD_copy(result_temp,result);
    BN_WORD_free(result_temp);
    BN_WORD_free(a_temp);
    return 0;
}

__device__ int BN_WORD_mul_device(const BN_WORD *a, const BN_WORD *b, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *result_temp;
    BN_WORD *a_temp;
    result_temp=BN_WORD_new_device(dmax);
    a_temp=BN_WORD_new_device(dmax);
    BN_WORD_setzero(result_temp);
    BN_WORD_copy(a,a_temp);
    for (int i=0;i<dmax;i++){
        for(int j=0;j<sizeof(BN_PART)*8;j++){
            if(BN_PART_get_bit(b->d[i],j)==1){
                BN_WORD_add(result_temp,a_temp,result_temp);
            }
            BN_WORD_left_shift_bits(a,a_temp,i*sizeof(BN_PART)*8+j);
        }
    }
    BN_WORD_copy(result_temp,result);
    BN_WORD_free_device(result_temp);
    BN_WORD_free_device(a_temp);
    return 0;
}

__host__ int BN_WORD_div(const BN_WORD *a, const BN_WORD *b, BN_WORD *q, BN_WORD *r){
    int dmax=a->dmax;
    BN_WORD_setzero(q);
    BN_WORD *one,*a_temp,*b_temp,*temp_result,*div_temp;
    one=BN_WORD_new(dmax);
    a_temp=BN_WORD_new(dmax);
    b_temp=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    div_temp=BN_WORD_new(dmax);
    BN_WORD_setone(one);
    int shift_num=0;
    if(BN_WORD_cmp(a,b)==0){
        BN_WORD_setone(q);
        BN_WORD_setzero(r);
        return 0;
    }
    BN_WORD_copy(a,a_temp);
    while((BN_WORD_cmp(a_temp,b)==1)||(BN_WORD_cmp(a_temp,b)==0)){
        shift_num ++;
        BN_WORD_right_shift_bits(a_temp,temp_result,1);
        BN_WORD_copy(temp_result,a_temp);
    }
    shift_num --;
    BN_WORD_copy(a,a_temp);
    BN_WORD_left_shift_bits(b,b_temp,shift_num);
    BN_WORD_setzero(q);
    for(int i=shift_num;i>=0;i--){
        if((BN_WORD_cmp(a_temp,b_temp)==1)||(BN_WORD_cmp(a_temp,b_temp)==0)){
            BN_WORD_sub(a_temp,b_temp,temp_result);
	    BN_WORD_copy(temp_result,a_temp);
            BN_WORD_left_shift_bits(one,div_temp,i);
            BN_WORD_add(q,div_temp,temp_result);
	    BN_WORD_copy(temp_result,q);
        }
        BN_WORD_right_shift_bits(b_temp,temp_result,1);
        BN_WORD_copy(temp_result,b_temp);
    }
    BN_WORD_copy(a_temp,r);
    BN_WORD_free(one);
    BN_WORD_free(a_temp);
    BN_WORD_free(b_temp);
    BN_WORD_free(temp_result);
    BN_WORD_free(div_temp);
    return 0;
}

__device__ int BN_WORD_div_device(const BN_WORD *a, const BN_WORD *b, BN_WORD *q, BN_WORD *r){
    int dmax=a->dmax;
    BN_WORD_setzero(q);
    BN_WORD *one,*a_temp,*b_temp,*temp_result,*div_temp;
    one=BN_WORD_new_device(dmax);
    a_temp=BN_WORD_new_device(dmax);
    b_temp=BN_WORD_new_device(dmax);
    temp_result=BN_WORD_new_device(dmax);
    div_temp=BN_WORD_new_device(dmax);
    BN_WORD_setone(one);
    int shift_num=0;
    if(BN_WORD_cmp(a,b)==0){
        BN_WORD_setone(q);
        BN_WORD_setzero(r);
        return 0;
    }
    BN_WORD_copy(a,a_temp);
    while((BN_WORD_cmp(a_temp,b)==1)||(BN_WORD_cmp(a_temp,b)==0)){
        shift_num ++;
        BN_WORD_right_shift_bits(a_temp,temp_result,1);
        BN_WORD_copy(temp_result,a_temp);
    }
    shift_num --;
    BN_WORD_copy(a,a_temp);
    BN_WORD_left_shift_bits(b,b_temp,shift_num);
    BN_WORD_setzero(q);
    for(int i=shift_num;i>=0;i--){
        if((BN_WORD_cmp(a_temp,b_temp)==1)||(BN_WORD_cmp(a_temp,b_temp)==0)){
            BN_WORD_sub(a_temp,b_temp,temp_result);
            BN_WORD_copy(temp_result,a_temp);
            BN_WORD_left_shift_bits(one,div_temp,i);
            BN_WORD_add(q,div_temp,temp_result);
            BN_WORD_copy(temp_result,q);
        }
        BN_WORD_right_shift_bits(b_temp,temp_result,1);
        BN_WORD_copy(temp_result,b_temp);
    }
    BN_WORD_copy(a_temp,r);
    BN_WORD_free_device(one);
    BN_WORD_free_device(a_temp);
    BN_WORD_free_device(b_temp);
    BN_WORD_free_device(temp_result);
    BN_WORD_free_device(div_temp);
    return 0;
}

__host__ int BN_WORD_mod (const BN_WORD *a, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *q;
    q =BN_WORD_new(dmax);
    BN_WORD_div(a,n,q,result);
    BN_WORD_free(q);
    return 0;
}

__device__ int BN_WORD_mod_device (const BN_WORD *a, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *q;
    q =BN_WORD_new_device(dmax);
    BN_WORD_div_device(a,n,q,result);
    BN_WORD_free_device(q);
    return 0;
}

__host__ int BN_WORD_add_mod(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *q, *a_temp, *b_temp, *temp_result;
    q=BN_WORD_new(dmax);
    a_temp=BN_WORD_new(dmax);
    b_temp=BN_WORD_new(dmax);
    temp_result=BN_WORD_new(dmax);
    BN_WORD_mod(a,n,a_temp);
    BN_WORD_mod(b,n,b_temp);
    BN_WORD_add(a_temp,b_temp,temp_result);
    if((BN_WORD_cmp(a_temp,temp_result)==1)||(BN_WORD_cmp(temp_result,n)==1)){
        BN_WORD_sub(temp_result,n,temp_result);
    }
    BN_WORD_copy(temp_result,result);
    BN_WORD_free(q);
    BN_WORD_free(a_temp);
    BN_WORD_free(b_temp);
    BN_WORD_free(temp_result);
    return 0;
}

__host__ int BN_WORD_mul_mod(const BN_WORD *a, const BN_WORD *b, const BN_WORD *n, BN_WORD *result){
    int dmax=a->dmax;
    int bit;
    BN_WORD *a_sub, *b_sub, *temp_result1, *temp_result2;
    a_sub=BN_WORD_new(dmax);
    b_sub=BN_WORD_new(dmax);
    temp_result1=BN_WORD_new(dmax);
    temp_result2=BN_WORD_new(dmax);
    BN_WORD_copy(a,a_sub);
    BN_WORD_copy(b,b_sub);
    BN_WORD_mod(a_sub,n,a_sub);
    if(BN_WORD_cmp(a_sub,n)==0){
        BN_WORD_setzero(result);
        return 0;
    }
    BN_WORD_mod(b_sub,n,b_sub);
    if(BN_WORD_cmp(b_sub,n)==0){
        BN_WORD_setzero(result);
        return 0;
    }
    BN_WORD_setzero(temp_result1);
    BN_WORD_setzero(temp_result2);
    for(int i=dmax-1;i>=0;i--){
        for(int j=sizeof(BN_PART)*8-1;j>=0;j--){
                bit=BN_PART_get_bit(b_sub->d[i],j);
                BN_WORD_add(temp_result1,temp_result1,temp_result2);
                if((BN_WORD_cmp(temp_result1, temp_result2)==1)||(BN_WORD_cmp(temp_result2,n)==1)||(BN_WORD_cmp(temp_result2,n)==0)){
                    BN_WORD_sub(temp_result2,n,temp_result1);
                }
                else {
                    BN_WORD_copy(temp_result2,temp_result1);
                }
                if(bit==1){
                    BN_WORD_add(temp_result1,a_sub,temp_result2);
                    if((BN_WORD_cmp(temp_result1, temp_result2)==1)||(BN_WORD_cmp(temp_result2,n)==1)||(BN_WORD_cmp(temp_result2,n)==0)){
                            BN_WORD_sub(temp_result2,n,temp_result1);
                    }
                    else {
                            BN_WORD_copy(temp_result2,temp_result1);
                    }
                }
        }
    }
    BN_WORD_copy(temp_result1,result);
    BN_WORD_free(a_sub);
    BN_WORD_free(b_sub);
    BN_WORD_free(temp_result1);
    BN_WORD_free(temp_result2);
    return 0;
}


#ifdef BN_PART_64
__host__ __device__ int BN_PART_BN_WORD_transform(BN_PART a, BN_WORD *result){
    BN_WORD_setzero(result);
    result->d[0]=a;
    return 0;
}

__host__ int BN_WORD_BN_PART_mod (BN_WORD *a, BN_PART n, BN_PART &result){
    int dmax=a->dmax;
    BN_WORD *word_n;
    BN_WORD *word_result;
    word_n=BN_WORD_new(dmax);
    word_result=BN_WORD_new(dmax);
    BN_PART_BN_WORD_transform(n,word_n);
    BN_WORD_mod(a,word_n,word_result);
    result=word_result->d[0];
    BN_WORD_free(word_n);
    BN_WORD_free(word_result);
    return 0;
}

__device__ int BN_WORD_BN_PART_mod_device (BN_WORD *a, BN_PART n, BN_PART &result){
    int dmax=a->dmax;
    BN_WORD *word_n,*word_result;
    word_n=BN_WORD_new_device(dmax);
    word_result=BN_WORD_new_device(dmax);
    BN_PART_BN_WORD_transform(n,word_n);
    BN_WORD_mod_device(a,word_n,word_result);
    result=word_result->d[0];
    BN_WORD_free_device(word_n);
    BN_WORD_free_device(word_result);
    return 0;
}

// need consider some length

__host__ int BN_WORD_2_Str(BN_WORD *a, std::string str){
    std:: ostringstream ostr1;
    for(int i=a->dmax-1;i>=0;i--){
        ostr1<<std::hex<<a->d[i]<<",";
    }
    str=ostr1.str();
    return 0;
}

__host__ int Str_2_BN_WORD(BN_WORD *a, std::string str){
    int str_num;
    for(int i=0;i<a->dmax;i++){
        a->d[i]=0;
    }
    for(int i=0;i<a->dmax;i++){
        for(int j=0;j<sizeof(BN_PART)*8;j++){
	    str_num=i*sizeof(BN_PART)*8+j;
	    if((str[str_num]>='0')&&(str[str_num]<='9')){
	        a->d[i]=a->d[i]*16+str[str_num]-'0';
	    }
	    if((str[str_num]>='A')&&(str[str_num]<='F')){
	        a->d[i]=a->d[i]*16+str[str_num]-'A'+10;
	    }
	    if((str[str_num]>='a')&&(str[str_num]<='f')){
		a->d[i]=a->d[i]*16+str[str_num]-'a'+10;
	    }
            if(str_num==str.length()-1){
	        return 0;
	    }	    
	}
    }
    return 0;
}

#endif

}
