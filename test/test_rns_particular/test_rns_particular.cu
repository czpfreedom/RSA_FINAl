#include "bn_word_operation.h"
#include "bn_openssl.h"
#include "openssl/bn.h"
#include "iostream"
#include "rns_rsa.h"

using namespace std;

#define DMAX 32

int main(){
    
    BIGNUM *open_a_exp_2_M, *open_a_exp_2;
    BN_WORD *bn_a_exp_2_M, *one , *bn_a_exp_2;

    open_a_exp_2_M =BN_new();
    open_a_exp_2 =BN_new();

    bn_a_exp_2_M=BN_WORD_new(DMAX);
    one=BN_WORD_new(DMAX);
    bn_a_exp_2=BN_WORD_new(DMAX);
    
    open_a_exp_2_M->d[0]=0xc92b0971fe4f286f;
    open_a_exp_2_M->d[1]=0xbdd4a5ac5b957f15;
    open_a_exp_2_M->d[2]=0x7594c368d77e0749;
    open_a_exp_2_M->d[3]=0xafedc313f7ed6be4;
    open_a_exp_2_M->d[4]=0x0ab0b056202b58ac;
    open_a_exp_2_M->d[5]=0x75a01b5c2706cc27;
    open_a_exp_2_M->d[6]=0xf9b634a72e83c409;
    open_a_exp_2_M->d[7]=0xc0f58988ef34efeb;
    open_a_exp_2_M->d[8]=0xa77d3c86e75cbba7;
    open_a_exp_2_M->d[9]=0x8120ee732313fe4a;
    open_a_exp_2_M->d[10]=0x70bc75629ad7b620;
    open_a_exp_2_M->d[11]=0x549bf6d428af8f7c;
    open_a_exp_2_M->d[12]=0xccdc7493b62bd152;
    open_a_exp_2_M->d[13]=0x6ec1369a95119eca;
    open_a_exp_2_M->d[14]=0xc07ad5a2f2c4a5e0;
    open_a_exp_2_M->d[15]=0xdd99d24b59c8ac98;
    
    RSA_n *rsa_n;

    rsa_n=RSA_N_new(DMAX);

    BN_WORD_openssl_prime_generation(rsa_n);

    rsa_n->n->d[0]=0xf20e948d;
    rsa_n->n->d[1]=0x34d05d9;
    rsa_n->n->d[2]=0xa1307b61;
    rsa_n->n->d[3]=0x676bb39a;
    rsa_n->n->d[4]=0x90d2a582;
    rsa_n->n->d[5]=0x194f45a0;
    rsa_n->n->d[6]=0xee48b81;
    rsa_n->n->d[7]=0x7d958c24;
    rsa_n->n->d[8]=0xf40d6239;
    rsa_n->n->d[9]=0xdad78c12;
    rsa_n->n->d[10]=0x41ec4564;
    rsa_n->n->d[11]=0xa9541b1d;
    rsa_n->n->d[12]=0xa7657698;
    rsa_n->n->d[13]=0xff6e065e;
    rsa_n->n->d[14]=0x7a84a2c8;
    rsa_n->n->d[15]=0x8b2fc193;
    rsa_n->n->d[16]=0xc24a4474;
    rsa_n->n->d[17]=0xf5b5219;
    rsa_n->n->d[18]=0x7fe667c0;
    rsa_n->n->d[19]=0xc094a93;
    rsa_n->n->d[20]=0x4b3c7945;
    rsa_n->n->d[21]=0x5d00233a;
    rsa_n->n->d[22]=0xa250e884;
    rsa_n->n->d[23]=0x9b848db5;
    rsa_n->n->d[24]=0x554d5f7;
    rsa_n->n->d[25]=0x658ea14a;
    rsa_n->n->d[26]=0xde47324c;
    rsa_n->n->d[27]=0xcb25482a;
    rsa_n->n->d[28]=0xd2f47787;
    rsa_n->n->d[29]=0x92698ded;
    rsa_n->n->d[30]=0xd73ddbd8;
    rsa_n->n->d[31]=0xacf091a3;

    rsa_n->p->d[0]=0x1aa0b77d;
    rsa_n->p->d[1]=0xfdaafa7f;
    rsa_n->p->d[2]=0x3f5b85e8;
    rsa_n->p->d[3]=0xe07d761f;
    rsa_n->p->d[4]=0xf6e6418a;
    rsa_n->p->d[5]=0xdea8f359;
    rsa_n->p->d[6]=0xc9f39cf3;
    rsa_n->p->d[7]=0x58c385a8;
    rsa_n->p->d[8]=0x97807c4f;
    rsa_n->p->d[9]=0xa01a59be;
    rsa_n->p->d[10]=0x26d53732;
    rsa_n->p->d[11]=0xaa1821ff;
    rsa_n->p->d[12]=0xd42d33d4;
    rsa_n->p->d[13]=0x34303f76;
    rsa_n->p->d[14]=0x9443f8ab;
    rsa_n->p->d[15]=0xcdbcf49c;

    for(int i=16;i<32;i++){
        rsa_n->p->d[i]=0;
    }

    rsa_n->q->d[0]=0x6d897e51;
    rsa_n->q->d[1]=0x9afdcf09;
    rsa_n->q->d[2]=0xa8eb3330;
    rsa_n->q->d[3]=0xa935c62c;
    rsa_n->q->d[4]=0x915d2d5e;
    rsa_n->q->d[5]=0x8c639f7f;
    rsa_n->q->d[6]=0x394de028;
    rsa_n->q->d[7]=0x35fc9a83;
    rsa_n->q->d[8]=0x48c2b9aa;
    rsa_n->q->d[9]=0x48eff4ef;
    rsa_n->q->d[10]=0xfa10009b;
    rsa_n->q->d[11]=0x39abc440;
    rsa_n->q->d[12]=0x28266abf;
    rsa_n->q->d[13]=0x6e54aacf;
    rsa_n->q->d[14]=0x11ad6b28;
    rsa_n->q->d[15]=0xd7305f88;

    for(int i=16;i<32;i++){
            rsa_n->q->d[i]=0;
    }

    RNS_N rns_n(rsa_n); 
}
