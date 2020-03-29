#include "bn_num_operation.h"
#include "stdio.h"


BN_ULONG get_bit(BN_ULONG a,int i){
    return  (a&((BN_ULONG)1<<i))/((BN_ULONG)1<<i);
}


__host__ BN_NUM *BN_NUM_new(int wmax,int dmax){
    BN_NUM *a;
    cudaMallocManaged((void**)&(a),sizeof(BN_NUM));
    a->wmax=wmax;
    cudaMallocManaged((void**)&(a->word),sizeof(BN_WORD*)*wmax);
    for(int i=0;i<wmax;i++){
        *(a->word+i)=BN_WORD_new(dmax);
    }
    return a;
}

__device__ BN_NUM *BN_NUM_new_device(int wmax,int dmax){
    BN_NUM *a;
    a=(BN_NUM*)malloc(sizeof(BN_NUM));
    a->wmax=wmax;
    a->word=(BN_WORD **)malloc(sizeof(BN_WORD*)*wmax);
    for(int i=0;i<wmax;i++){
        *(a->word+i)=BN_WORD_new_device(dmax);
    }
    return a;

}
__host__ void BN_NUM_free(BN_NUM *a){
    for(int i=0;i<a->wmax;i++){
        BN_WORD_free(a->word[i]);
    }
    cudaFree(a->word);
    cudaFree(a);
}

__device__ void BN_NUM_free_device(BN_NUM *a){
    for(int i=0;i<a->wmax;i++){
        BN_WORD_free_device(a->word[i]);
    }
    free(a->word);
    free(a);
}

__host__ __device__ void BN_NUM_copy(const BN_NUM *a, BN_NUM *b){
    for(int i=0;i<a->wmax;i++){
        BN_WORD_copy(a->word[i],b->word[i]);
    }
}

__host__ __device__ void BN_NUM_setzero(BN_NUM *a){
    for(int i=0;i<a->wmax;i++){
        BN_WORD_setzero(a->word[i]);
    }
}

__host__ __device__ void BN_NUM_setone(BN_NUM *a){
    BN_WORD_setone(a->word[0]);
    for(int i=1;i<a->wmax;i++){
        BN_WORD_setzero(a->word[i]);
    }
}

__host__ __device__ int BN_NUM_cmp(const BN_NUM *a,const BN_NUM *b){
    int cmp;
    if(a->wmax!=b->wmax)
	    return -1;
    for(int i=a->wmax-1;i>=0;i--){
	cmp=BN_WORD_cmp(a->word[i],b->word[i]);
        if(cmp==1){
            return 1;
        }
        if(cmp==2){
            return 2;
        }
    }
    return 0;
}

__host__ __device__ void BN_NUM_print(const BN_NUM *a){
    printf("wmax:%d\n",a->wmax);
    for(int i=a->wmax-1;i>=0;i--){
        BN_WORD_print(a->word[i]);
     }
}

__host__ int BN_NUM_add(const BN_NUM *a,const BN_NUM *b,BN_NUM *result){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int cmp;
    BN_WORD *carry1,*carry2,*temp;
    carry1=BN_WORD_new(dmax);
    carry2=BN_WORD_new(dmax);
    temp=BN_WORD_new(dmax);
    BN_WORD_setzero(carry1);
    BN_WORD_setzero(carry2);
    BN_WORD_setzero(temp);
    for (int i=0;i<wmax;i++){
        BN_WORD_copy(carry1,carry2);
        BN_WORD_setzero(carry1);
	BN_WORD_add(a->word[i],carry2,temp);
	cmp=BN_WORD_cmp(a->word[i],temp);
        if(cmp==1){
            BN_WORD_setone(carry1);
        }
	BN_WORD_add(temp,b->word[i],result->word[i]);
	cmp=BN_WORD_cmp(b->word[i],result->word[i]);
        if(cmp==1){
            BN_WORD_setone(carry1);
        }
    }
    BN_WORD_free(carry1);
    BN_WORD_free(carry2);
    BN_WORD_free(temp);
    return 0;
}


__device__ int BN_NUM_add_device(const BN_NUM *a,const BN_NUM *b,BN_NUM *result){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int cmp;
    BN_WORD *carry1,*carry2,*temp;
    carry1=BN_WORD_new_device(dmax);
    carry2=BN_WORD_new_device(dmax);
    temp=BN_WORD_new_device(dmax);
    BN_WORD_setzero(carry1);
    BN_WORD_setzero(carry2);
    BN_WORD_setzero(temp);
    for (int i=0;i<wmax;i++){
        BN_WORD_copy(carry1,carry2);
        BN_WORD_setzero(carry1);
        BN_WORD_add(a->word[i],carry2,temp);
        cmp=BN_WORD_cmp(a->word[i],temp);
        if(cmp==1){
            BN_WORD_setone(carry1);
        }
        BN_WORD_add(temp,b->word[i],result->word[i]);
        cmp=BN_WORD_cmp(b->word[i],result->word[i]);
        if(cmp==1){
            BN_WORD_setone(carry1);
        }
    }
    BN_WORD_free_device(carry1);
    BN_WORD_free_device(carry2);
    BN_WORD_free_device(temp);
    return 0;
}


__host__ int BN_NUM_sub(const BN_NUM *a,const BN_NUM *b,BN_NUM *result){
    int wmax=a->wmax;
    int cmp;
    int dmax=a->word[0]->dmax;
    BN_WORD *carry1, *carry2,*temp;
    carry1=BN_WORD_new(dmax);
    carry2=BN_WORD_new(dmax);
    temp=BN_WORD_new(dmax);
    BN_WORD_setzero(carry1);
    BN_WORD_setzero(carry2);
    BN_WORD_setzero(temp);
    for(int i=0;i<wmax;i++){
        BN_WORD_copy(carry1,carry2);
        BN_WORD_setzero(carry1);
        BN_WORD_sub(a->word[i],b->word[i],temp);
        cmp=BN_WORD_cmp(a->word[i],temp);
        if(cmp==2){
            BN_WORD_setone(carry1);
        }
        BN_WORD_sub(temp,carry2,result->word[i]);
        cmp=BN_WORD_cmp(temp,result->word[i]);
        if(cmp==2){
            BN_WORD_setone(carry1);
        }
    }
    BN_WORD_free(carry1);
    BN_WORD_free(carry2);
    BN_WORD_free(temp);
    return 0;
}


__device__ int BN_NUM_sub_device(const BN_NUM *a,const BN_NUM *b,BN_NUM *result){
    int wmax=a->wmax;
    int cmp;
    int dmax=a->word[0]->dmax;
    BN_WORD *carry1, *carry2,*temp;
    carry1=BN_WORD_new_device(dmax);
    carry2=BN_WORD_new_device(dmax);
    temp=BN_WORD_new_device(dmax);
    BN_WORD_setzero(carry1);
    BN_WORD_setzero(carry2);
    BN_WORD_setzero(temp);
    for(int i=0;i<wmax;i++){
	BN_WORD_copy(carry1,carry2);
	BN_WORD_setzero(carry1);
        BN_WORD_sub(a->word[i],b->word[i],temp);
	cmp=BN_WORD_cmp(a->word[i],temp);
	if(cmp==2){
	    BN_WORD_setone(carry1);
	}
	BN_WORD_sub(temp,carry2,result->word[i]);
	cmp=BN_WORD_cmp(temp,result->word[i]);
	if(cmp==2){
	    BN_WORD_setone(carry1);
	}
    }
    BN_WORD_free_device(carry1);
    BN_WORD_free_device(carry2);
    BN_WORD_free_device(temp);
    return 0;
}

__host__ int BN_NUM_left_shift_bits(const BN_NUM *a,BN_NUM *b,int bits){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int bits_bn_ulong=sizeof(BN_ULONG)*8;
    int shift_num=bits/(bits_bn_ulong);
    int real_bits=bits%(bits_bn_ulong);
    int j,i_w,i_d,j_w,j_d,i_sub_w,i_sub_d;
    for(int i=0;i<wmax*dmax-shift_num;i++){
        j=i+shift_num;
	i_w=i/dmax;
	i_d=i%dmax;
	j_w=j/dmax;
	j_d=j%dmax;
	i_sub_w=(i-1)/dmax;
	i_sub_d=(i-1)%dmax;
	if(i==0){
	b->word[j_w]->d[j_d]=(a->word[i_w]->d[i_d])<<real_bits;
	}
	else{
	    if(real_bits==0){
		    b->word[j_w]->d[j_d]=((a->word[i_w]->d[i_d])<<real_bits)
                +((a->word[i_sub_w]->d[i_sub_d])/((BN_ULONG)1<<(bits_bn_ulong-real_bits-1))/((BN_ULONG)1<<1));
	    }    
	    else{
	    	    b->word[j_w]->d[j_d]=((a->word[i_w]->d[i_d])<<real_bits)
		+((a->word[i_sub_w]->d[i_sub_d])/((BN_ULONG)1<<(bits_bn_ulong-real_bits)));
	    }
	}
    }
    for(int j=0;j<shift_num;j++){
	j_w=j/dmax;
        j_d=j%dmax;
	b->word[j_w]->d[j_d]=0;
    }
    return 0;
}
/*
__host__ int BN_NUM_left_shift_bits(const BN_NUM *a,BN_NUM *b,int bits){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int bits_bn_ulong=sizeof(BN_ULONG)*8;
    int shift_num=bits/(bits_bn_ulong);
    int real_bits=bits%(bits_bn_ulong);
    int j,i_w,i_d,j_w,j_d,i_sub_w,i_sub_d;
    for(int i=0;i<wmax*dmax-shift_num;i++){
        j=i+shift_num;
        i_w=i/dmax;
        i_d=i%dmax;
        j_w=j/dmax;
        j_d=j%dmax;
        i_sub_w=(i-1)/dmax;
        i_sub_d=(i-1)%dmax;
        if(i==0){
        b->word[j_w]->d[j_d]=(a->word[i_w]->d[i_d])<<real_bits;
        }
        b->word[j_w]->d[j_d]=((a->word[i_w]->d[i_d])<<real_bits)
                +((a->word[i_sub_w]->d[i_sub_d])/((BN_ULONG)1<<(bits_bn_ulong-real_bits)));
    }
    return 0;
}
*/

__host__ int BN_NUM_right_shift_bits(const BN_NUM *a,BN_NUM *b,int bits){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int bits_bn_ulong=sizeof(BN_ULONG)*8;
    int shift_num=bits/(bits_bn_ulong);
    int real_bits=bits%(bits_bn_ulong);
    int j,i_w,i_d,j_w,j_d,i_add_w,i_add_d;
    for(int i=shift_num;i<wmax*dmax;i++){
        j=i-shift_num;
        i_w=i/dmax;
        i_d=i%dmax;
        j_w=j/dmax;
        j_d=j%dmax;
        i_add_w=(i+1)/dmax;
        i_add_d=(i+1)%dmax;
	if(i==(dmax*wmax-1)){
        b->word[j_w]->d[j_d]=(a->word[i_w]->d[i_d])/((BN_ULONG)1<<real_bits);
	}
	else{
	    if(real_bits==0){
		    b->word[j_w]->d[j_d]=((a->word[i_w]->d[i_d])/((BN_ULONG)1<<real_bits))
                +((a->word[i_add_w]->d[i_add_d])<<(bits_bn_ulong-real_bits-1)<<1);
	    }
	    else{
	    	    b->word[j_w]->d[j_d]=((a->word[i_w]->d[i_d])/((BN_ULONG)1<<real_bits))
                +((a->word[i_add_w]->d[i_add_d])<<(bits_bn_ulong-real_bits));	    
	    }
	}
    }
    for(int j=wmax*dmax-shift_num;j<wmax*dmax;j++){
	j_w=j/dmax;
        j_d=j%dmax;
        b->word[j_w]->d[j_d]=0;
    }
    return 0;
}




__host__ int BN_NUM_mul(const BN_NUM *a, const BN_NUM *b, BN_NUM *result){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int bits_bn_ulong=sizeof(BN_ULONG)*8;
    int shift_bits;
    BN_ULONG mul_value;
    BN_NUM *a_shift;
    BN_NUM *temp_result;
    a_shift=BN_NUM_new(wmax,dmax);
    temp_result=BN_NUM_new(wmax,dmax);
    BN_NUM_setzero(result);
    for(int w=0;w<wmax;w++){
        for(int d=0;d<dmax;d++){
	    for(int i=0;i<bits_bn_ulong;i++){
	        shift_bits=w*dmax*bits_bn_ulong+d*bits_bn_ulong+i;
		mul_value=get_bit(b->word[w]->d[d],i);
		if(mul_value==(BN_ULONG)1){
		    BN_NUM_setzero(a_shift);
		    BN_NUM_left_shift_bits(a,a_shift,shift_bits);
		    BN_NUM_add(result,a_shift,temp_result);
		    BN_NUM_copy(temp_result,result);
		}
	    }
	}
    }
   return 0; 
}

__host__ int BN_NUM_div(const BN_NUM *a, const BN_NUM *b, BN_NUM *q, BN_NUM *r){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    BN_NUM_setzero(q);
    BN_NUM *one,*a_temp,*b_temp,*temp_result,*div_temp;
    one=BN_NUM_new(wmax,dmax);
    a_temp=BN_NUM_new(wmax,dmax);
    b_temp=BN_NUM_new(wmax,dmax);
    temp_result=BN_NUM_new(wmax,dmax);
    div_temp=BN_NUM_new(wmax,dmax);
    BN_NUM_setone(one);
    int shift_num=0;
    if(BN_NUM_cmp(a,b)==2){
        BN_NUM_setzero(q);
	BN_NUM_copy(a,r);
	return 0;
    }
    if(BN_NUM_cmp(a,b)==0){
        BN_NUM_setone(q);
	BN_NUM_setzero(r);
	return 0;
    }
    BN_NUM_copy(a,a_temp);
    while((BN_NUM_cmp(a_temp,b)==1)||(BN_NUM_cmp(a_temp,b)==0)){
        shift_num ++;
	BN_NUM_right_shift_bits(a_temp,temp_result,1);
	BN_NUM_copy(temp_result,a_temp);
    }
    shift_num --;
  //  printf("shift_num:%d\n",shift_num);
    BN_NUM_copy(a,a_temp);
    BN_NUM_left_shift_bits(b,b_temp,shift_num);
    for(int i=shift_num;i>=0;i--){
        if(BN_NUM_cmp(a_temp,b_temp)==1){
	    BN_NUM_sub(a_temp,b_temp,a_temp);
	    BN_NUM_left_shift_bits(one,div_temp,i);
//	    printf("div_temp:\n");
//	    BN_NUM_print(div_temp);
	    BN_NUM_add(q,div_temp,q);
	}
	BN_NUM_right_shift_bits(b_temp,temp_result,1);
	BN_NUM_copy(temp_result,b_temp);
    }
    BN_NUM_copy(a_temp,r);
    return 0;
}


/*
__host__ int BN_NUM_mul(const BN_NUM *a, const BN_NUM *b, BN_NUM *result){
    int wmax=a->wmax;
    int dmax=a->word[0]->dmax;
    int i,j,m;
    BN_WORD *carry1, *carry2, *carry3, *carry4, *temp_result, *temp_mul_result;
    carry1=BN_WORD_new(2*dmax);
    carry2=BN_WORD_new(2*dmax);
    carry3=BN_WORD_new(2*dmax);
    carry4=BN_WORD_new(2*dmax);
    temp_result=BN_WORD_new(2*dmax);
    temp_mul_result=BN_WORD_new(2*dmax);
    for(m=0;m<2*wmax-1;m++){
        for(i=0;i<=m;i++){
	    j=m-i;
	    BN_WORD_mul(a->word[i],b->word[j],temp_mul_result);
	    BN_WORD_add(temp_result,temp_mul_result,temp_result);
	    if(temp_result->carry==1){
	        temp_result->carry=0;
		BN_WORD_add(carry4,one,carry4);
	    }
	}
	BN_WORD_add()
    }
}
*/

