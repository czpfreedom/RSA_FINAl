#include "rsa_rns.h"

namespace namespace_rsa_final{

__global__ void RNS_mul_mod_kernel(BN_WORD *bn_a,BN_WORD *bn_b,int base_num,BN_PART *m1, BN_PART *m2,BN_PART *d,BN_PART *e,BN_PART *a, BN_PART *a_2,BN_PART *b,BN_PART*b_2,BN_PART *c,BN_PART *x_result){
    int thread_id=threadIdx.x+blockIdx.x*blockDim.x;
    unsigned int mask=0xffffffff;
    BN_PART x_1, x_2, y_1, y_2,s_1,s_2;
    BN_PART theta,xi,theta_k,sigma,sigma_add,sigma_k,s_1_add,L1,L2;
    float L1_float,L2_float;
    BN_WORD_BN_PART_mod_device(bn_a, m1[thread_id], x_1);
    BN_WORD_BN_PART_mod_device(bn_a, m2[thread_id], x_2);
    BN_WORD_BN_PART_mod_device(bn_b, m1[thread_id], y_1);
    BN_WORD_BN_PART_mod_device(bn_b, m2[thread_id], y_2);
    BN_PART_mul_mod(x_1,y_1,m1[thread_id],x_1);
    BN_PART_mul_mod(x_2,y_2,m2[thread_id],x_2);
    BN_PART_mul_mod(x_1,d[thread_id],m1[thread_id],theta);
    BN_PART_mul_mod(x_2,e[thread_id],m2[thread_id],xi);
    L1_float=0;
    sigma=0;
    for(int k=0;k<base_num;k++){
        theta_k=__shfl_sync(mask,theta,k,32);
        L1_float+=(float)theta_k/m1[k];
        BN_PART_mul_mod(a[thread_id*base_num+k],theta_k,m2[thread_id],sigma_add);
        BN_PART_add_mod(sigma,sigma_add,m2[thread_id],sigma);
    }
  L1=(BN_PART)L1_float;
    BN_PART_add_mod(sigma,xi,m2[thread_id],sigma);
    BN_PART_mul_mod(L1,a_2[thread_id],m2[thread_id],sigma_add);
    BN_PART_add_mod(sigma,sigma_add,m2[thread_id],sigma);
    L2_float=0;
    s_1=0;
    for(int k=0;k<base_num;k++){
        sigma_k=__shfl_sync(mask,sigma,k,32);
        L2_float+=(float)sigma_k/m2[k];
        BN_PART_mul_mod(b[thread_id*base_num+k],sigma_k,m1[thread_id],s_1_add);
        BN_PART_add_mod(s_1,s_1_add,m1[thread_id],s_1);
    }
    L2=(BN_PART)L2_float;
    BN_PART_mul_mod(L2,b_2[thread_id],m1[thread_id],s_1_add);
    BN_PART_add_mod(s_1,s_1_add,m1[thread_id],s_1);
    BN_PART_mul_mod(sigma,c[thread_id],m2[thread_id],s_2);
    BN_PART_mul_mod(s_1,d[thread_id],m1[thread_id],theta);
    BN_PART_mul_mod(s_2,e[thread_id],m2[thread_id],xi);
    L1_float=0;
    sigma=0;
   for(int k=0;k<base_num;k++){
        theta_k=__shfl_sync(mask,theta,k,32);
        L1_float+=(float)theta_k/m1[k];
        BN_PART_mul_mod(a[thread_id*base_num+k],theta_k,m2[thread_id],sigma_add);
        sigma=BN_PART_add_mod(sigma,sigma_add,m2[thread_id],sigma);
    }
    L1=(BN_PART)L1_float;
    BN_PART_add_mod(sigma,xi,m2[thread_id],sigma);
    BN_PART_mul_mod(L1,a_2[thread_id],m2[thread_id],sigma_add);
    BN_PART_add_mod(sigma,sigma_add,m2[thread_id],sigma);
    L2_float=0;
    s_1=0;
    for(int k=0;k<base_num;k++){
        sigma_k=__shfl_sync(mask,sigma,k,32);
        L2_float+=(float)sigma_k/m2[k];
        BN_PART_mul_mod(b[thread_id*base_num+k],sigma_k,m1[thread_id],s_1_add);
        BN_PART_add_mod(s_1,s_1_add,m1[thread_id],s_1);
    }
    L2=(BN_PART)L2_float;
    BN_PART_mul_mod(L2,b_2[thread_id],m1[thread_id],s_1_add);
    BN_PART_add_mod(s_1,s_1_add,m1[thread_id],x_result[thread_id]);
}


__host__ RNS_N:: RNS_N(RSA_N *rsa_n){
    m_rsa_n=rsa_n;
    m_base_num=m_rsa_n->n->dmax;
    cudaMallocManaged((void**)&(m_m1),BASE_MAX*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_m2),BASE_MAX*sizeof(BN_PART));
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
    cudaMallocManaged((void**)&(m_d),m_base_num*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_e),m_base_num*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_a),m_base_num*m_base_num*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_a_2),m_base_num*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_b),m_base_num*m_base_num*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_b_2),m_base_num*sizeof(BN_PART));
    cudaMallocManaged((void**)&(m_c),m_base_num*sizeof(BN_PART));
    BN_PART M, M_inverse, p_temp, M1_i_inverse,M1_i_m1_i, M2_i_inverse,M2_i_m2_i;
    BN_WORD *temp_result, *bn_m, *q, *r, *bn_M1_i_inverse, *bn_M2_i_inverse;
    temp_result=BN_WORD_new(m_base_num);
    bn_m=BN_WORD_new(m_base_num);
    q=BN_WORD_new(m_base_num);
    r=BN_WORD_new(m_base_num);
    bn_M1_i_inverse=BN_WORD_new(m_base_num);
    bn_M2_i_inverse=BN_WORD_new(m_base_num);

    m_m1[0] =0xffffffffffffffc5;
    m_m1[1] =0xffffffffffffffad;
    m_m1[2] =0xffffffffffffffa1;
    m_m1[3] =0xffffffffffffff4d;
    m_m1[4] =0xffffffffffffff43;
    m_m1[5] =0xfffffffffffffeff;
    m_m1[6] =0xfffffffffffffee9;
    m_m1[7] =0xfffffffffffffebd;
    m_m1[8] =0xfffffffffffffe9f;
    m_m1[9] =0xfffffffffffffe95;
    m_m1[10]=0xfffffffffffffe57;
    m_m1[11]=0xfffffffffffffe3b;
    m_m1[12]=0xfffffffffffffe09;
    m_m1[13]=0xfffffffffffffd19;
    m_m1[14]=0xfffffffffffffcc7;
    m_m1[15]=0xfffffffffffffcb5;
    m_m1[16]=0xfffffffffffffcb3;
    m_m1[17]=0xfffffffffffffc7f;
    m_m1[18]=0xfffffffffffffc7d;
    m_m1[19]=0xfffffffffffffc59;
    m_m1[20]=0xfffffffffffffc4f;
    m_m1[21]=0xfffffffffffffc01;
    m_m1[22]=0xfffffffffffffbff;
    m_m1[23]=0xfffffffffffffbcb;
    m_m1[24]=0xfffffffffffffbc9;
    m_m1[25]=0xfffffffffffffb2d;
    m_m1[26]=0xfffffffffffffb05;
    m_m1[27]=0xfffffffffffffad5;
    m_m1[28]=0xfffffffffffffa9d;
    m_m1[29]=0xfffffffffffffa43;
    m_m1[30]=0xfffffffffffffa3d;
    m_m1[31]=0xfffffffffffffa31;

    m_m2[0] =0xfffffffffffffa1f;
    m_m2[1] =0xfffffffffffffa13;
    m_m2[2] =0xfffffffffffff9df;
    m_m2[3] =0xfffffffffffff9d1;
    m_m2[4] =0xfffffffffffff9b9;
    m_m2[5] =0xfffffffffffff97f;
    m_m2[6] =0xfffffffffffff925;
    m_m2[7] =0xfffffffffffff8f9;
    m_m2[8] =0xfffffffffffff8f3;
    m_m2[9] =0xfffffffffffff8d1;
    m_m2[10]=0xfffffffffffff8bd;
    m_m2[11]=0xfffffffffffff8a5;
    m_m2[12]=0xfffffffffffff863;
    m_m2[13]=0xfffffffffffff835;
    m_m2[14]=0xfffffffffffff82d;
    m_m2[15]=0xfffffffffffff80f;
    m_m2[16]=0xfffffffffffff803;
    m_m2[17]=0xfffffffffffff7cf;
    m_m2[18]=0xfffffffffffff7ab;
    m_m2[19]=0xfffffffffffff781;
    m_m2[20]=0xfffffffffffff733;
    m_m2[21]=0xfffffffffffff713;
    m_m2[22]=0xfffffffffffff70f;
    m_m2[23]=0xfffffffffffff6fb;
    m_m2[24]=0xfffffffffffff6b5;
    m_m2[25]=0xfffffffffffff661;
    m_m2[26]=0xfffffffffffff643;
    m_m2[27]=0xfffffffffffff60b;
    m_m2[28]=0xfffffffffffff605;
    m_m2[29]=0xfffffffffffff5db;
    m_m2[30]=0xfffffffffffff5b7;
    m_m2[31]=0xfffffffffffff563;

    BN_WORD_setone(m_M1);
    BN_WORD_setone(m_M2);
    for(int i=0;i<m_base_num;i++){
        BN_PART_BN_WORD_transform(m_m1[i],bn_m);
        BN_WORD_mul(bn_m,m_M1,m_M1);
    }
    for(int i=0;i<m_base_num;i++){
        BN_PART_BN_WORD_transform(m_m2[i],bn_m);
        BN_WORD_mul(bn_m,m_M2,m_M2);
    }
    BN_WORD_mod(m_M1,m_rsa_n->n,m_M1_n);
    BN_WORD_mod(m_M2,m_rsa_n->n,m_M2_n);
    for(int i=0;i<m_base_num;i++){
        BN_PART_BN_WORD_transform(m_m1[i], bn_m);
        BN_WORD_div(m_M1,bn_m,m_M1_i[i],r);
        BN_PART_BN_WORD_transform(m_m2[i], bn_m);
        BN_WORD_div(m_M2,bn_m,m_M2_i[i],r);
        BN_WORD_BN_PART_mod(m_M1_i[i],m_m1[i],M1_i_m1_i);
        BN_PART_mod_inverse(M1_i_m1_i,m_m1[i],M1_i_inverse);
        BN_PART_BN_WORD_transform(M1_i_inverse,bn_M1_i_inverse);
        BN_WORD_mul_mod(bn_M1_i_inverse,m_M1_i[i],m_M1,m_M1_red_i[i]);
        BN_WORD_BN_PART_mod(m_M2_i[i],m_m2[i],M2_i_m2_i);
	BN_PART_mod_inverse(M2_i_m2_i,m_m2[i],M2_i_inverse);
        BN_PART_BN_WORD_transform(M2_i_inverse, bn_M2_i_inverse);
        BN_WORD_mul_mod(bn_M2_i_inverse,m_M2_i[i],m_M2,m_M2_red_i[i]);
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_BN_PART_mod(m_M1_i[i],m_m1[i],M);
        BN_WORD_BN_PART_mod(m_rsa_n->n,m_m1[i],p_temp);
	BN_PART_mul_mod(M,p_temp,m_m1[i],M);
	BN_PART_mod_inverse(M,m_m1[i],M_inverse);
        m_d[i]=m_m1[i]-M_inverse;
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_BN_PART_mod(m_M2_i[i],m_m2[i],M);
        BN_WORD_BN_PART_mod(m_M1,m_m2[i],M_inverse);
	BN_PART_mul_mod(M,M_inverse,m_m2[i],M);
	BN_PART_mod_inverse(M,m_m2[i],m_e[i]);
    }
    for(int i=0;i<m_base_num;i++){
        for(int j=0;j<m_base_num;j++){
            BN_WORD_BN_PART_mod(m_M2_i[i],m_m2[i],M);
	    BN_PART_mul_mod(M,m_m1[j],m_m2[i],M);
            BN_PART_mod_inverse(M,m_m2[i],M_inverse);
            BN_WORD_BN_PART_mod(m_rsa_n->n,m_m2[i],p_temp);
	    BN_PART_mul_mod(M_inverse,p_temp,m_m2[i],m_a[i*m_base_num+j]);
        }
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_BN_PART_mod(m_M2_i[i],m_m2[i],M);
        M=m_m2[i]-M;
        BN_PART_mod_inverse(M,m_m2[i],M_inverse);
        BN_WORD_BN_PART_mod(m_rsa_n->n,m_m2[i],p_temp);
	BN_PART_mul_mod(M_inverse,p_temp,m_m2[i],m_a_2[i]);
    }
    for(int i=0;i<m_base_num;i++){
        for(int j=0;j<m_base_num;j++){
            BN_WORD_BN_PART_mod(m_M2_i[j],m_m1[i],M);
            m_b[i*m_base_num+j]=M;
        }
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_BN_PART_mod(m_M2,m_m1[i],M);
        M=m_m1[i]-M;
        m_b_2[i]=M;
    }
    for(int i=0;i<m_base_num;i++){
        BN_WORD_BN_PART_mod(m_M2_i[i],m_m2[i],M);
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

int RNS_N :: RNS_MUL_MOD(BN_WORD *a, BN_WORD *b, BN_WORD *result){
       int dmax=a->dmax;
    BN_WORD *a_temp, *b_temp;
    BN_PART *x_result;
    a_temp=BN_WORD_new(dmax);
    b_temp=BN_WORD_new(dmax);
    cudaMallocManaged((void**)&(x_result),m_base_num*sizeof(BN_PART));
    BN_WORD_mul_mod(a, m_M1, m_rsa_n->n, a_temp); //a=a*M mod n
    BN_WORD_mul_mod(b, m_M1, m_rsa_n->n, b_temp);
    RNS_mul_mod_kernel<<<1,dmax>>>(a_temp,b_temp,m_base_num, m_m1,m_m2,m_d,m_e,m_a,m_a_2,m_b,m_b_2,m_c,x_result);
    cudaDeviceSynchronize();
    RSA_RNS_reduction1(x_result,result);
    if(BN_WORD_cmp(result,m_rsa_n->n)==1){
        BN_WORD_sub(result,m_rsa_n->n,result);
    }
    BN_WORD_free(a_temp);
    BN_WORD_free(b_temp);
    cudaFree(x_result);
    return 0;    
}

int RNS_N:: RSA_RNS_reduction1(BN_PART *x_result, BN_WORD *result){
    BN_WORD *result_add, *bn_x;
    bn_x=BN_WORD_new(m_base_num);
    result_add=BN_WORD_new(m_base_num);
    BN_WORD_setzero(result);
    for(int i=0;i<m_base_num;i++){
        BN_PART_BN_WORD_transform(x_result[i],bn_x);
        BN_WORD_mul_mod(bn_x,m_M1_red_i[i],m_M1,result_add);
        BN_WORD_add_mod(result,result_add,m_M1,result);
    }
    return 0;
}

}
