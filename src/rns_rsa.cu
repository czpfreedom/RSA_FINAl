#include "rns_rsa.h"
#include "iostream"
#include "bn_word_parallel_mont_exp.h"


using namespace std;

__host__ RSA_N *RSA_N_new(int dmax){
    RSA_N *rsa_n;
    rsa_n=(RSA_N*)malloc(sizeof(RSA_N));
    rsa_n->n=BN_WORD_new(dmax);
    rsa_n->p=BN_WORD_new(dmax);
    rsa_n->q=BN_WORD_new(dmax);
    return rsa_n;
}

__host__ int RSA_N_free(RSA_N *rsa_n){
    BN_WORD_free(rsa_n->n);
    BN_WORD_free(rsa_n->p);
    BN_WORD_free(rsa_n->q);
    free(rsa_n);
    return 0;
}

__host__ int RSA_N_print(RSA_N *rsa_n){
   printf("p:\n");
   BN_WORD_print(rsa_n->p);
   printf("q:\n");
   BN_WORD_print(rsa_n->q);
   printf("n:\n");
   BN_WORD_print(rsa_n->n);
   return 0;
}

__host__ __device__ int RNS_WORD_BN_WORD_transform(RNS_WORD a, int bits, BN_WORD *result){
    int shift_num=bits/(sizeof(BN_PART)*8);
    int shift_bits=bits%(sizeof(BN_PART)*8);
    BN_WORD_setzero(result);
    if(shift_bits==0){
        result->d[shift_num-1]=a;
    }
    else{
        result->d[shift_num-1]=a<<(shift_bits);
	result->d[shift_num]=a>>(sizeof(RNS_WORD)*8-shift_bits);
    }
    return 0;
}

__host__ int BN_WORD_RNS_WORD_mod (BN_WORD *a, RNS_WORD b, RNS_WORD &c){
    BN_WORD *a_temp;
    BN_WORD *b_temp;
    a_temp=BN_WORD_new(a->dmax);
    b_temp=BN_WORD_new(a->dmax);
    BN_WORD_copy(a,a_temp);
    for(int i=(sizeof(BN_PART)*8*(a->dmax));i>=(sizeof(RNS_WORD)*8);i--){
        RNS_WORD_BN_WORD_transform(b,i,b_temp);
	while((BN_WORD_cmp(a_temp,b_temp)==1)||(BN_WORD_cmp(a_temp,b_temp)==0)){
	    BN_WORD_sub(a_temp,b_temp,a_temp);
	}
    }
    c=a_temp->d[0];
    BN_WORD_free(a_temp);
    BN_WORD_free(b_temp);
    return 0;
}

__device__ int BN_WORD_RNS_WORD_mod_device (BN_WORD *a, RNS_WORD b, RNS_WORD &c){
    BN_WORD *a_temp;
    BN_WORD *b_temp;
    a_temp=BN_WORD_new_device(a->dmax);
    b_temp=BN_WORD_new_device(a->dmax);
    BN_WORD_copy(a,a_temp);
    for(int i=(sizeof(BN_PART)*8*(a->dmax));i>=(sizeof(RNS_WORD)*8);i--){
        RNS_WORD_BN_WORD_transform(b,i,b_temp);
	while((BN_WORD_cmp(a_temp,b_temp)==1)||(BN_WORD_cmp(a_temp,b_temp)==0)){
	    BN_WORD_sub(a_temp,b_temp,a_temp);
	}
    }
    c=a_temp->d[0];
    BN_WORD_free_device(a_temp);
    BN_WORD_free_device(b_temp);
    return 0;
}

__host__ int RNS_WORD_mod_inverse (RNS_WORD a, RNS_WORD n, RNS_WORD &a_inverse){
    long s1, s2, q, r1, r2,temp;
    r1=(long)n;
    r2=(long)a;
    s1=0;
    s2=1;
    while(r2!=1){
       q=r1/r2;
       temp=r2;
       r2=r1%r2;
       r1=temp;
       temp=s2;
       s2=s1-q*s2;
       s1=temp;
    }
    while(s2<0){
       s2=s2+(long)n;
    }
    s2=s2%n;
    a_inverse=(RNS_WORD)s2;
    return 0;
}

__host__ RNS_N:: RNS_N(RSA_N *rsa_n){
    m_rsa_n=rsa_n;
    m_base_num=m_rsa_n->n->dmax;
    cudaMallocManaged((void**)&(m_m1),BASE_MAX*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_m2),BASE_MAX*sizeof(RNS_WORD));
    m_M1=BN_WORD_new(m_base_num);
    m_M2=BN_WORD_new(m_base_num);
    m_M1_n=BN_WORD_new(m_base_num);
    m_M2_n=BN_WORD_new(m_base_num);
    m_M1_i=(BN_WORD**)malloc(m_base_num*sizeof(BN_WORD*));
    m_M2_i=(BN_WORD**)malloc(m_base_num*sizeof(BN_WORD*));
    m_M1_red_i=(BN_WORD**)malloc(m_base_num*sizeof(BN_WORD*));
    m_M2_red_i=(BN_WORD**)malloc(m_base_num*sizeof(BN_WORD*));
    for(int i=0;i<m_base_num;i++){
	m_M1_i[i]=BN_WORD_new(m_base_num);
    }
    for(int i=0;i<m_base_num;i++){
	m_M2_i[i]=BN_WORD_new(m_base_num);
    }
    for(int i=0;i<m_base_num;i++){
        m_M1_red_i[i]=BN_WORD_new(m_base_num);
    }
    for(int i=0;i<m_base_num;i++){
	m_M2_red_i[i]=BN_WORD_new(m_base_num);
    }
    cudaMallocManaged((void**)&(m_d),m_base_num*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_e),m_base_num*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_a),m_base_num*m_base_num*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_a_2),m_base_num*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_b),m_base_num*m_base_num*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_b_2),m_base_num*sizeof(RNS_WORD));
    cudaMallocManaged((void**)&(m_c),m_base_num*sizeof(RNS_WORD));
    RNS_WORD M, M_inverse, p_temp, M1_i_inverse,M1_i_m1_i, M2_i_inverse,M2_i_m2_i; 
    BN_WORD *temp_result, *bn_m, *q, *r, *bn_M1_i_inverse, *bn_M2_i_inverse;
    temp_result=BN_WORD_new(m_base_num);
    bn_m=BN_WORD_new(m_base_num);
    q=BN_WORD_new(m_base_num);
    r=BN_WORD_new(m_base_num);
    bn_M1_i_inverse=BN_WORD_new(m_base_num);
    bn_M2_i_inverse=BN_WORD_new(m_base_num);

    m_m1[0]=0xffffffef;
    m_m1[1]=0xffffffbf;
    m_m1[2]=0xffffff9d;
    m_m1[3]=0xffffff95;
    m_m1[4]=0xffffff79;
    m_m1[5]=0xffffff67;
    m_m1[6]=0xffffff47;
    m_m1[7]=0xffffff2f;
    m_m1[8]=0xfffffef5;
    m_m1[9]=0xfffffed5;
    m_m1[10]=0xfffffec5;
    m_m1[11]=0xfffffe9f;
    m_m1[12]=0xfffffe8f;
    m_m1[13]=0xfffffe7d;
    m_m1[14]=0xfffffe5d;
    m_m1[15]=0xfffffe2d;
    m_m1[16]=0xfffffe1d;
    m_m1[17]=0xfffffdf1;
    m_m1[18]=0xfffffd8b;
    m_m1[19]=0xfffffd85;
    m_m1[20]=0xfffffd81;
    m_m1[21]=0xfffffd7b;
    m_m1[22]=0xfffffd6f;
    m_m1[23]=0xfffffd5b;
    m_m1[24]=0xfffffd3f;
    m_m1[25]=0xfffffd37;
    m_m1[26]=0xfffffd19;
    m_m1[27]=0xfffffccd;
    m_m1[28]=0xfffffcaf;
    m_m1[29]=0xfffffca9;
    m_m1[30]=0xfffffc9b;
    m_m1[31]=0xfffffc65;
    m_m1[32]=0xfffff9fd;
    m_m1[33]=0xfffff9e9;
    m_m1[34]=0xfffff9e5;
    m_m1[35]=0xfffff9d9;
    m_m1[36]=0xfffff9bb;
    m_m1[37]=0xfffff9b3;
    m_m1[38]=0xfffff9af;
    m_m1[39]=0xfffff9a9;
    m_m1[40]=0xfffff9a7;
    m_m1[41]=0xfffff99b;
    m_m1[42]=0xfffff989;
    m_m1[43]=0xfffff971;
    m_m1[44]=0xfffff96d;
    m_m1[45]=0xfffff961;
    m_m1[46]=0xfffff94d;
    m_m1[47]=0xfffff919;
    m_m1[48]=0xfffff8ef;
    m_m1[49]=0xfffff8d5;
    m_m1[50]=0xfffff8d1;
    m_m1[51]=0xfffff8a5;
    m_m1[52]=0xfffff887;
    m_m1[53]=0xfffff871;
    m_m1[54]=0xfffff863;
    m_m1[55]=0xfffff853;
    m_m1[56]=0xfffff841;
    m_m1[57]=0xfffff83b;
    m_m1[58]=0xfffff80f;
    m_m1[59]=0xfffff803;
    m_m1[60]=0xfffff7ed;
    m_m1[61]=0xfffff7d3;
    m_m1[62]=0xfffff7c9;
    m_m1[63]=0xfffff7a9;


    m_m2[0]=0xfffffc5f;
    m_m2[1]=0xfffffc41;
    m_m2[2]=0xfffffc19;
    m_m2[3]=0xfffffbe3;
    m_m2[4]=0xfffffbdd;
    m_m2[5]=0xfffffbd7;
    m_m2[6]=0xfffffbc9;
    m_m2[7]=0xfffffbab;
    m_m2[8]=0xfffffba1;
    m_m2[9]=0xfffffb93;
    m_m2[10]=0xfffffb89;
    m_m2[11]=0xfffffb71;
    m_m2[12]=0xfffffb69;
    m_m2[13]=0xfffffb53;
    m_m2[14]=0xfffffb47;
    m_m2[15]=0xfffffb39;
    m_m2[16]=0xfffffb1b;
    m_m2[17]=0xfffffaf7;
    m_m2[18]=0xfffffaf1;
    m_m2[19]=0xfffffad9;
    m_m2[20]=0xfffffad3;
    m_m2[21]=0xfffffacf;
    m_m2[22]=0xfffffabd;
    m_m2[23]=0xfffffab1;
    m_m2[24]=0xfffffa97;
    m_m2[25]=0xfffffa7f;
    m_m2[26]=0xfffffa57;
    m_m2[27]=0xfffffa51;
    m_m2[28]=0xfffffa4f;
    m_m2[29]=0xfffffa3d;
    m_m2[30]=0xfffffa21;
    m_m2[31]=0xfffffa07;
    m_m2[32]=0xfffff79f;
    m_m2[33]=0xfffff791;
    m_m2[34]=0xfffff78b;
    m_m2[35]=0xfffff71b;
    m_m2[36]=0xfffff6f5;
    m_m2[37]=0xfffff6f1;
    m_m2[38]=0xfffff6e9;
    m_m2[39]=0xfffff6df;
    m_m2[40]=0xfffff6cb;
    m_m2[41]=0xfffff6c1;
    m_m2[42]=0xfffff6bb;
    m_m2[43]=0xfffff6a7;
    m_m2[44]=0xfffff6a3;
    m_m2[45]=0xfffff6a1;
    m_m2[46]=0xfffff69d;
    m_m2[47]=0xfffff697;
    m_m2[48]=0xfffff68f;
    m_m2[49]=0xfffff661;
    m_m2[50]=0xfffff65b;
    m_m2[51]=0xfffff649;
    m_m2[52]=0xfffff635;
    m_m2[53]=0xfffff623;
    m_m2[54]=0xfffff60d;
    m_m2[55]=0xfffff5d1;
    m_m2[56]=0xfffff5cb;
    m_m2[57]=0xfffff599;
    m_m2[58]=0xfffff58d;
    m_m2[59]=0xfffff577;
    m_m2[60]=0xfffff563;
    m_m2[61]=0xfffff551;
    m_m2[62]=0xfffff53f;
    m_m2[63]=0xfffff539;

    BN_WORD_setone(m_M1);
    BN_WORD_setone(m_M2);
    for(int i=0;i<m_base_num;i++){
        RNS_WORD_BN_WORD_transform(m_m1[i],sizeof(RNS_WORD)*8, bn_m);
	BN_WORD_mul(bn_m,m_M1,temp_result);
	BN_WORD_copy(temp_result,m_M1);
    }
    for(int i=0;i<m_base_num;i++){
	RNS_WORD_BN_WORD_transform(m_m2[i],sizeof(RNS_WORD)*8, bn_m);
	BN_WORD_mul(bn_m,m_M2,temp_result);
	BN_WORD_copy(temp_result,m_M2);
    }					    
    BN_WORD_div(m_M1,m_rsa_n->n,q,m_M1_n);
    BN_WORD_div(m_M2,m_rsa_n->n,q,m_M2_n);
    for(int i=0;i<m_base_num;i++){
        RNS_WORD_BN_WORD_transform(m_m1[i], sizeof(RNS_WORD)*8, bn_m);
	BN_WORD_div(m_M1,bn_m,m_M1_i[i],r);
        RNS_WORD_BN_WORD_transform(m_m2[i], sizeof(RNS_WORD)*8, bn_m);
	BN_WORD_div(m_M2,bn_m,m_M2_i[i],r);
	BN_WORD_RNS_WORD_mod(m_M1_i[i],m_m1[i],M1_i_m1_i);
	RNS_WORD_mod_inverse(M1_i_m1_i,m_m1[i],M1_i_inverse);
	RNS_WORD_BN_WORD_transform(M1_i_inverse,sizeof(RNS_WORD)*8, bn_M1_i_inverse);
	BN_WORD_mul_mod_host(bn_M1_i_inverse,m_M1_i[i],m_M1,m_M1_red_i[i]);
	BN_WORD_RNS_WORD_mod(m_M2_i[i],m_m2[i],M2_i_m2_i);
	RNS_WORD_mod_inverse(M2_i_m2_i,m_m2[i],M2_i_inverse);
	RNS_WORD_BN_WORD_transform(M2_i_inverse,sizeof(RNS_WORD)*8, bn_M2_i_inverse);
	BN_WORD_mul_mod_host(bn_M2_i_inverse,m_M2_i[i],m_M2,m_M2_red_i[i]);
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_RNS_WORD_mod(m_M1_i[i],m_m1[i],M);
	BN_WORD_RNS_WORD_mod(m_rsa_n->n,m_m1[i],p_temp);
    	M=rns_word_mul_mod(M,p_temp,m_m1[i]);
    	RNS_WORD_mod_inverse(M,m_m1[i],M_inverse);
    	m_d[i]=m_m1[i]-M_inverse;
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_RNS_WORD_mod(m_M2_i[i],m_m2[i],M);
	BN_WORD_RNS_WORD_mod(m_M1,m_m2[i],M_inverse);
	M=rns_word_mul_mod(M,M_inverse,m_m2[i]);
	RNS_WORD_mod_inverse(M,m_m2[i],m_e[i]);
    }
    for(int i=0;i<m_base_num;i++){
	for(int j=0;j<m_base_num;j++){
	    BN_WORD_RNS_WORD_mod(m_M2_i[i],m_m2[i],M);
	    M=rns_word_mul_mod(M,m_m1[j],m_m2[i]);
	    RNS_WORD_mod_inverse(M,m_m2[i],M_inverse);
	    BN_WORD_RNS_WORD_mod(m_rsa_n->n,m_m2[i],p_temp);
	    m_a[i*m_base_num+j]=rns_word_mul_mod(M_inverse,p_temp,m_m2[i]);
	}		
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_RNS_WORD_mod(m_M2_i[i],m_m2[i],M);
	M=m_m2[i]-M;
	RNS_WORD_mod_inverse(M,m_m2[i],M_inverse);
	BN_WORD_RNS_WORD_mod(m_rsa_n->n,m_m2[i],p_temp);
	m_a_2[i]=rns_word_mul_mod(M_inverse,p_temp,m_m2[i]);
    }
    for(int i=0;i<m_base_num;i++){
        for(int j=0;j<m_base_num;j++){
	    BN_WORD_RNS_WORD_mod(m_M2_i[j],m_m1[i],M);
	    m_b[i*m_base_num+j]=M;
	}
    }
    for(int i=0;i<m_base_num;i++){
	BN_WORD_RNS_WORD_mod(m_M2,m_m1[i],M);
	M=m_m1[i]-M;
	m_b_2[i]=M;
    }
    for(int i=0;i<m_base_num;i++){
	BN_WORD_RNS_WORD_mod(m_M2_i[i],m_m2[i],M);
	m_c[i]=M;
    }
    BN_WORD_free(temp_result);
    BN_WORD_free(q);
    BN_WORD_free(bn_m);
    BN_WORD_free(r); 
    BN_WORD_free(bn_M1_i_inverse);
}

__host__ RNS_N:: ~RNS_N(){
    cudaFree(m_m1);
    cudaFree(m_m2);
    BN_WORD_free(m_M1);
    BN_WORD_free(m_M2);
    BN_WORD_free(m_M1_n);
    BN_WORD_free(m_M2_n);
    for(int i=0;i<m_base_num;i++){
        BN_WORD_free(m_M1_i[i]);
	BN_WORD_free(m_M1_red_i[i]);
    }
    free(m_M1_i);
    free(m_M2_i);
    free(m_M1_red_i);
    free(m_M2_red_i);
    cudaFree(m_d);
    cudaFree(m_e);
    cudaFree(m_a);
    cudaFree(m_a_2);
    cudaFree(m_b);
    cudaFree(m_b_2);
    cudaFree(m_c);
}

__host__  int RNS_N:: RNS_print(){
    printf("rsa_n:\n");
    RSA_N_print(m_rsa_n);
    printf("base_num:%x\n",m_base_num);
    for(int i=0;i<m_base_num;i++){
        printf("m1[%x]:%x\n",i,m_m1[i]);
    }
    for(int i=0;i<m_base_num;i++){ 
	printf("m2[%x]:%x\n",i,m_m2[i]);
    }
    printf("M1:\n");
    BN_WORD_print(m_M1);
    printf("M2:\n");
    BN_WORD_print(m_M2);
    for(int i=0;i<m_base_num;i++){
	printf("M1_%x:",i);
    	BN_WORD_print(m_M1_i[i]);
    }
    for(int i=0;i<m_base_num;i++){
        printf("M2_%x:",i);
	BN_WORD_print(m_M2_i[i]);
    }
    for(int i=0;i<m_base_num;i++){
	printf("M1_red_%x:\n",i);
    	BN_WORD_print(m_M1_red_i[i]);
    }
    for(int i=0;i<m_base_num;i++){
	printf("M2_red_%x:\n",i);
	BN_WORD_print(m_M2_red_i[i]);
    }		
    printf("M1_n:\n");
    BN_WORD_print(m_M1_n);
    printf("M2_n:\n");
    BN_WORD_print(m_M2_n);
    for(int i=0;i<m_base_num;i++){
        printf("d%x:%x\n",i,m_d[i]);
    }
    for(int i=0;i<m_base_num;i++){
        printf("e%x:%x\n",i,m_e[i]);
    }
    for(int i=0;i<m_base_num*m_base_num;i++){
        printf("a%x:%x\n",i,m_a[i]);
    }
    for(int i=0;i<m_base_num;i++){
        printf("a_2_%x:%u\n",i,m_a_2[i]);
    }
    for(int i=0;i<m_base_num*m_base_num;i++){
        printf("b%x:%x\n",i,m_b[i]);
    }
    for(int i=0;i<m_base_num;i++){
        printf("b_2_%x:%u\n",i,m_b_2[i]);
    }
    for(int i=0;i<m_base_num;i++){
	printf("c%x:%x\n",i,m_c[i]);
    }
    return 0;
}

__host__ int RNS_N:: RNS_mul_mod (BN_WORD *a, BN_WORD *b, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *a_temp, *b_temp,*one;
    RNS_WORD *x_result;
    a_temp=BN_WORD_new(dmax);
    b_temp=BN_WORD_new(dmax);
    one=BN_WORD_new(dmax);
    cudaMallocManaged((void**)&(x_result),m_base_num*sizeof(RNS_WORD));
    BN_WORD_mul_mod_host(a, m_M1, m_rsa_n->n, a_temp); //a=a*M mod n
    BN_WORD_mul_mod_host(b, m_M1, m_rsa_n->n, b_temp);
    BN_WORD_setone(one);
    if(dmax==32){
	RNS_mul_mod_kernel_32<<<1,dmax>>>(a_temp,b_temp,m_base_num, m_m1,m_m2,m_d,m_e,m_a,m_a_2,m_b,m_b_2,m_c,x_result);
    	cudaDeviceSynchronize();
    }
    if(dmax==64){
	RNS_mul_mod_kernel_64<<<1,dmax>>>(a_temp,b_temp,m_base_num, m_m1,m_m2,m_d,m_e,m_a,m_a_2,m_b,m_b_2,m_c,x_result);
	cudaDeviceSynchronize();
    }
    if((dmax!=32)&&(dmax!=64)){
	print("base_num is not 32 or 64, error\n");
	return -1;
    }
    RSA_RNS_reduction1(x_result,result);
    printf("mod_mul: result1:\n");
    BN_WORD_print(result);
    RNS_mul_mod_kernel<<<1,dmax>>>(result,one,m_base_num, m_m1,m_m2,m_d,m_e,m_a,m_a_2,m_b,m_b_2,m_c,x_result);
    cudaDeviceSynchronize();
    RSA_RNS_reduction1(x_result,result);  
    BN_WORD_free(a_temp);
    cudaFree(x_result);
    return 0;
}

__host__ int RNS_N:: RSA (BN_WORD *a, BN_WORD *e, BN_WORD *result){
    int dmax=a->dmax;
    BN_WORD *a_temp;
    RNS_WORD *x_result;
    a_temp=BN_WORD_new(dmax);
    cudaMallocManaged((void**)&(x_result),m_base_num*sizeof(RNS_WORD));
    BN_WORD_mul_mod_host(a, m_M1, m_rsa_n->n, a_temp); //a=a*M mod n
    printf("bn_a_M:\n");
    BN_WORD_print(a_temp);
    if(dmax==32){
        RSA_RNS_kernel_32<<<1,dmax*2,m_base_num*2>>>(a_temp,e,m_base_num, m_m1,m_m2,m_d,m_e,m_a,m_a_2,m_b,m_b_2,m_c,x_result);    
    	cudaDeviceSynchronize();
    }
    if(dmax==64){
        RSA_RNS_kernel_64<<<1,dmax*2,m_base_num*2>>>(a_temp,e,m_base_num, m_m1,m_m2,m_d,m_e,m_a,m_a_2,m_b,m_b_2,m_c,x_result);
	cudaDeviceSynchronize();
    }
    if((dmax!=32)&&(dmax!=64)){
        print("base_num is not 32 or 64, error\n");
	return -1;
    }
    RSA_RNS_reduction1(x_result,result);
    BN_WORD_free(a_temp);
    cudaFree(x_result);
    return 0;
}


__global__ void RNS_mul_mod_kernel(BN_WORD *bn_a,BN_WORD *bn_b,int base_num,RNS_WORD *m1, RNS_WORD *m2,RNS_WORD *d,RNS_WORD *e,RNS_WORD *a, RNS_WORD *a_2,RNS_WORD *b,RNS_WORD *b_2,RNS_WORD *c,RNS_WORD *x_result){
    int thread_id=threadIdx.x+blockIdx.x*blockDim.x;
    unsigned int mask=0xffffffff;
    RNS_WORD x_1, x_2, y_1, y_2;
    RNS_WORD theta,xi,theta_k,sigma,sigma_add,sigma_k,x_result_1,x_result_add,L1,L2;
    float L1_float,L2_float;
    BN_WORD_RNS_WORD_mod_device(bn_a, m1[thread_id], x_1);
    BN_WORD_RNS_WORD_mod_device(bn_a, m2[thread_id], x_2);
    BN_WORD_RNS_WORD_mod_device(bn_b, m1[thread_id], y_1);
    BN_WORD_RNS_WORD_mod_device(bn_b, m2[thread_id], y_2);
    x_1=rns_word_mul_mod(x_1,y_1,m1[thread_id]);
    x_2=rns_word_mul_mod(x_2,y_2,m2[thread_id]);
    if((bn_b->d[0]!=1)||(bn_b->d[1]!=0)){
        printf("mul_mod;x_1[%x]:%x\n",thread_id,x_1);
    	printf("mul_mod;x_2[%x]:%x\n",thread_id,x_2);
    }
    theta=rns_word_mul_mod(x_1,d[thread_id],m1[thread_id]);
    xi=rns_word_mul_mod(x_2,e[thread_id],m2[thread_id]);
    L1_float=0;
    sigma=0;
    for(int k=0;k<base_num;k++){
        theta_k=__shfl_sync(mask,theta,k);
	L1_float+=(float)theta_k/m1[k];
	sigma_add=rns_word_mul_mod(a[thread_id*base_num+k],theta_k,m2[thread_id]);
	sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_id]);
    }
    L1=(RNS_WORD)L1_float;
    sigma=rns_word_add_mod(sigma,xi,m2[thread_id]);
    sigma_add=rns_word_mul_mod(L1,a_2[thread_id],m2[thread_id]);
    sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_id]);
    L2_float=0;
    x_result_1=0;
    for(int k=0;k<base_num;k++){
        sigma_k=__shfl_sync(mask,sigma,k,32);
	L2_float+=(float)sigma_k/m2[k];
	x_result_add=rns_word_mul_mod(b[thread_id*base_num+k],sigma_k,m1[thread_id]);
	x_result_1=rns_word_add_mod(x_result_1,x_result_add,m1[thread_id]);
    }
    L2=(RNS_WORD)L2_float;
    x_result_add=rns_word_mul_mod(L2,b_2[thread_id],m1[thread_id]);
    x_result[thread_id]=rns_word_add_mod(x_result_1,x_result_add,m1[thread_id]);
    if((bn_b->d[0]!=1)||(bn_b->d[1]!=0)){
	printf("mul_mod;x_result[%x]:%x\n",thread_id,x_result[thread_id]);
    }
}

__global__ void RSA_RNS_kernel(BN_WORD *bn_a,BN_WORD *bn_e,int base_num,RNS_WORD *m1,RNS_WORD *m2, RNS_WORD *d,RNS_WORD *e,RNS_WORD *a, RNS_WORD *a_2,RNS_WORD *b,RNS_WORD *b_2,RNS_WORD *c,RNS_WORD *x_result){
    int thread_id=threadIdx.x+blockIdx.x*blockDim.x;
    int thread_j=thread_id%base_num;
    RNS_WORD x_square_1,x_square_2, x_result_1, x_result_2,L1,L2,theta, xi ,sigma,theta_k,sigma_k,sigma_add, s_1,s_1_add;
    float  L1_float, L2_float;
    int mark=0;
    extern __shared__ RNS_WORD x_shared[];
    BN_WORD_RNS_WORD_mod_device(bn_a, m1[thread_j], x_square_1);
    BN_WORD_RNS_WORD_mod_device(bn_a, m2[thread_j], x_square_2);
    printf("bn_a_M_mod_m1[%x]:%x\n",thread_id,x_square_1);
    printf("bn_a_M_mod_m2[%x]:%x\n",thread_id,x_square_2);
    unsigned int mask=0xffffffff;    
    for(int i=0;i<base_num;i++){
        for(int j=0;j<base_num;j++){
	    __syncthreads();
	    if(thread_id<base_num){
	        x_shared[thread_j]=x_square_1;
		x_shared[thread_j+base_num]=x_square_2;
	    }
	    __syncthreads();
	    if(thread_id>=base_num){
	        x_square_1=x_shared[thread_j];
		x_square_2=x_shared[thread_j+base_num];
	    }
	    __syncthreads();
	    //square*square
	    if(thread_id<base_num){
	        x_square_1=rns_word_mul_mod(x_square_1,x_square_1,m1[thread_j]);
    		x_square_2=rns_word_mul_mod(x_square_2,x_square_2,m2[thread_j]);
    		theta=rns_word_mul_mod(x_square_1,d[thread_j],m1[thread_j]);
		xi=rns_word_mul_mod(x_square_2,e[thread_j],m2[thread_j]);
		L1_float=0;
		sigma=0;
		for(int k=0;k<base_num;k++){
		    theta_k=__shfl_sync(mask,theta,k,32);
		    L1_float+=(float)theta_k/m1[k];
		    sigma_add=rns_word_mul_mod(a[thread_j*base_num+k],theta_k,m2[thread_j]);
		    sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_j]);
		}
		L1=(RNS_WORD)L1_float;
		sigma=rns_word_add_mod(sigma,xi,m2[thread_j]);
		sigma_add=rns_word_mul_mod(L1,a_2[thread_j],m2[thread_j]);
		sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_j]);
		L2_float=0;
		s_1=0;
		for(int k=0;k<base_num;k++){
		    sigma_k=__shfl_sync(mask,sigma,k,32);
		    L2_float+=(float)sigma_k/m2[k];
		    s_1_add=rns_word_mul_mod(b[thread_j*base_num+k],sigma_k,m1[thread_j]);
		    s_1=rns_word_add_mod(s_1,s_1_add,m1[thread_j]);
		}
		L2=(RNS_WORD)L2_float;
		s_1_add=rns_word_mul_mod(L2,b_2[thread_j],m1[thread_j]);
		x_square_1=rns_word_add_mod(s_1,s_1_add,m1[thread_j]);
		x_square_2=rns_word_mul_mod(sigma,c[thread_j],m2[thread_j]);
#ifdef I_BIT_0
		if((i==0)&&(j==0)){
		    printf("bn_a_exp_2_M_mod_m1[%x]:%x\n",thread_id,x_square_1);
		    printf("bn_a_exp_2_M_mod_m2[%x]:%x\n",thread_id,x_square_2);
		}
#endif

#ifdef I_BIT_1
                if((i==0)&&(j==1)){
                    printf("bn_a_exp_4_M_mod_m1[%x]:%x\n",thread_id,x_square_1);
                    printf("bn_a_exp_4_M_mod_m2[%x]:%x\n",thread_id,x_square_2);
                }
#endif
#ifdef I_BIT_2
                if((i==0)&&(j==2)){
                    printf("bn_a_exp_8_M_mod_m1[%x]:%x\n",thread_id,x_square_1);
                    printf("bn_a_exp_8_M_mod_m2[%x]:%x\n",thread_id,x_square_2);
                }
#endif
	    }
	    //result=square*result
	    else{
	        if(get_bit(bn_e->d[i],j)==(BN_PART)1){
		//need shared memory
		    if(mark==0){
		        x_result_1=x_square_1;
			x_result_2=x_square_2;
			mark=1;
		    }
		    else{
	 		x_result_1=rns_word_mul_mod(x_result_1,x_square_1,m1[thread_j]);
     			x_result_2=rns_word_mul_mod(x_result_2,x_square_2,m2[thread_j]);
			theta=rns_word_mul_mod(x_result_1,d[thread_j],m1[thread_j]);
     			xi=rns_word_mul_mod(x_result_2,e[thread_j],m2[thread_j]);
     			L1_float=0;
     			sigma=0;
     			for(int k=0;k<base_num;k++){
	 			theta_k=__shfl_sync(mask,theta,k,32);
	 			L1_float+=(float)theta_k/m1[k];
	 			sigma_add=rns_word_mul_mod(a[thread_j*base_num+k],theta_k,m2[thread_j]);
	 			sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_j]);
     			}
			L1=(RNS_WORD)L1_float;
     			sigma=rns_word_add_mod(sigma,xi,m2[thread_j]);
			sigma_add=rns_word_mul_mod(L1,a_2[thread_j],m2[thread_j]);
     			sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_j]);
     			L2_float=0;
     			s_1=0; 
     			for(int k=0;k<base_num;k++){
	 			sigma_k=__shfl_sync(mask,sigma,k,32);
		 		L2_float+=(float)sigma_k/m2[k];
	 			s_1_add=rns_word_mul_mod(b[thread_j*base_num+k],sigma_k,m1[thread_j]);
	 			s_1=rns_word_add_mod(s_1,s_1_add,m1[thread_j]);
	     		}		   
     			L2=(RNS_WORD)L2_float;
     			s_1_add=rns_word_mul_mod(L2,b_2[thread_j],m1[thread_j]);
     			x_result_1=rns_word_add_mod(s_1,s_1_add,m1[thread_j]);
     			x_result_2=rns_word_mul_mod(sigma,c[thread_j],m2[thread_j]);
		    }
		}
#ifdef I_BIT_0
		if((i==0)&&(j==0)){
		}
#endif
#ifdef I_BIT_1
		if((i==0)&&(j==1)){
		}
#endif
#ifdef I_BIT_2
		if((i==0)&&(j==2)){
		}
#endif
	    }
	
        }
    }
    __syncthreads();
    if(thread_id>=base_num){
	x_shared[thread_j]=x_result_1;
	x_shared[thread_j+base_num]=x_result_2;
    }
    if(thread_id<base_num){
	x_result_1=x_shared[thread_j];
	x_result_2=x_shared[thread_j+base_num];
    	theta=rns_word_mul_mod(x_result_1,d[thread_j],m1[thread_j]);
    	xi=rns_word_mul_mod(x_result_2,e[thread_j],m2[thread_j]);
    	L1_float=0;
    	sigma=0;
    	for(int k=0;k<base_num;k++){
		theta_k=__shfl_sync(mask,theta,k,32);
		L1_float+=(float)theta_k/m1[k];
		sigma_add=rns_word_mul_mod(a[thread_j*base_num+k],theta_k,m2[thread_j]);
		sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_j]);
    	}
    	L1=(RNS_WORD)L1_float;
    	sigma=rns_word_add_mod(sigma,xi,m2[thread_j]);
    	sigma_add=rns_word_mul_mod(L1,a_2[thread_j],m2[thread_j]);
    	sigma=rns_word_add_mod(sigma,sigma_add,m2[thread_j]);
    	L2_float=0;
    	s_1=0; 
    	for(int k=0;k<base_num;k++){
		sigma_k=__shfl_sync(mask,sigma,k,32);
		L2_float+=(float)sigma_k/m2[k];
		s_1_add=rns_word_mul_mod(b[thread_j*base_num+k],sigma_k,m1[thread_j]);
		s_1=rns_word_add_mod(s_1,s_1_add,m1[thread_j]);
    	}		   
    	L2=(RNS_WORD)L2_float;
    	s_1_add=rns_word_mul_mod(L2,b_2[thread_j],m1[thread_j]);
    	x_result[thread_j]=rns_word_add_mod(s_1,s_1_add,m1[thread_j]);
    }
}

__host__ int RNS_N:: RSA_RNS_reduction1(RNS_WORD *x_result, BN_WORD *result){
    BN_WORD *result_add, *bn_x;
    bn_x=BN_WORD_new(m_base_num);
    result_add=BN_WORD_new(m_base_num);
    BN_WORD_setzero(result);
    for(int i=0;i<m_base_num;i++){
        RNS_WORD_BN_WORD_transform(x_result[i],sizeof(RNS_WORD)*8,bn_x);
	BN_WORD_mul_mod_host(bn_x,m_M1_red_i[i],m_M1,result_add);
	BN_WORD_add_mod_host(result,result_add,m_M1,result);
    }
    return 0;
}

__host__ int RNS_N:: RSA_RNS_reduction2(RNS_WORD *x_result, BN_WORD *result){
    BN_WORD *result_add, *bn_x;
    bn_x=BN_WORD_new(m_base_num);
    result_add=BN_WORD_new(m_base_num);
    BN_WORD_setzero(result);
    for(int i=0;i<m_base_num;i++){
        RNS_WORD_BN_WORD_transform(x_result[i],sizeof(RNS_WORD)*8,bn_x);
        BN_WORD_mul_mod_host(bn_x,m_M2_red_i[i],m_M2,result_add);
        BN_WORD_add_mod_host(result,result_add,m_M2,result);
    }
    return 0;
}

/*
    m_M1->d[0]=0x77985e5f;
    m_M1->d[1]=0x3b24aba7;
    m_M1->d[2]=0x1860cdd4;
    m_M1->d[3]=0x4b54b64d;
    m_M1->d[4]=0x587fd8b2;
    m_M1->d[5]=0xf0ea0ad5;
    m_M1->d[6]=0x8fcd9f4d;
    m_M1->d[7]=0x2da1a3f4;
    m_M1->d[8]=0xb68892ed;
    m_M1->d[9]=0x0239d494;
    m_M1->d[10]=0x1b911305;
    m_M1->d[11]=0xf4afddef;
    m_M1->d[12]=0x576cf656;
    m_M1->d[13]=0xaee50801;
    m_M1->d[14]=0xce2511a5;
    m_M1->d[15]=0xef50a335;
    m_M1->d[16]=0xee9a7715;
    m_M1->d[17]=0xe0276ec7;
    m_M1->d[18]=0xdf431b50;
    m_M1->d[19]=0x8fcd69ff;
    m_M1->d[20]=0x5675a100;
    m_M1->d[21]=0x6e41d06c;
    m_M1->d[22]=0x62bd6520;
    m_M1->d[23]=0x43a789e4;
    m_M1->d[24]=0x2da442e2;
    m_M1->d[25]=0x600dc5b9;
    m_M1->d[26]=0xdb8fe947;
    m_M1->d[27]=0x920141be;
    m_M1->d[28]=0x0e417b4b;
    m_M1->d[29]=0xb134f2fe;
    m_M1->d[30]=0x069d4df9;
    m_M1->d[31]=0xffffc492;

    m_M2->d[0]=0xf92db8dd;
    m_M2->d[1]=0xeb720815;
    m_M2->d[2]=0x31eeb1bc;
    m_M2->d[3]=0x283022fa;
    m_M2->d[4]=0xeace80df;
    m_M2->d[5]=0xbc3d8630;
    m_M2->d[6]=0x395bb69b;
    m_M2->d[7]=0xe0f69eb0;
    m_M2->d[8]=0xfec07a5f;
    m_M2->d[9]=0xcde9f980;
    m_M2->d[10]=0x8dbebedd;
    m_M2->d[11]=0x23201df2;
    m_M2->d[12]=0xf25e6242;
    m_M2->d[13]=0xa8231c1b;
    m_M2->d[14]=0x0219f9c9;
    m_M2->d[15]=0x1de97696;
    m_M2->d[16]=0x914aa0d6;
    m_M2->d[17]=0xf5a99d64;
    m_M2->d[18]=0xe9a9a8cc;
    m_M2->d[19]=0xbd420dc5;
    m_M2->d[20]=0x593ebeb4;
    m_M2->d[21]=0xe0fccc6d;
    m_M2->d[22]=0xe469c091;
    m_M2->d[23]=0xf1c229a8;
    m_M2->d[24]=0x43979531;
    m_M2->d[25]=0xee1d2206;
    m_M2->d[26]=0xc89784e8;
    m_M2->d[27]=0x70638d2b;
    m_M2->d[28]=0x795198af;
    m_M2->d[29]=0x923f12c4;
    m_M2->d[30]=0x2db293aa;
    m_M2->d[31]=0xffff648c;
*/
