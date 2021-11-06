#include "rsa_final.h"
#include "bn_openssl.h"
#include "iostream"
#include "bn/bn_lcl.h"
#include <iomanip>

#define DMAX 32
#define LOOP_NUM 32


using namespace namespace_rsa_final;

int main(){

    BIGNUM *open_a, *open_b, *open_n, *open_result, *open_R;
    BN_CTX *ctx;
    BN_WORD bn_a,bn_b, bn_result, bn_open_result;
    RSA_N rsa_n;

    open_a=BN_new();
    open_b=BN_new();
    open_n=BN_new();
    open_result=BN_new();
    ctx=BN_CTX_new();
    open_R=BN_new();

    int sum=0;

    for(int i=0;i<LOOP_NUM;i++){

        BN_rand(open_a,DMAX*sizeof(BN_PART)*8,0,0);
        BN_rand(open_b,DMAX*sizeof(BN_PART)*8,0,0);
        
        BN_rand(open_R,(DMAX+1)*sizeof(BN_PART)*8,0,0);
        open_R->d[DMAX]=1;
        
        BN_WORD_openssl_prime_generation(rsa_n,DMAX*sizeof(BN_PART)*8);
        openssl_BN_WORD_transform(open_n,rsa_n.m_n);
/*

	std::string str_a="c8382ed52a65f1296c43b9c55e46df4befbcb3b67d74e0f9a732c1c6f5b241fc46437fa1be332f5abebbfeafc6e6ef46c90b6e88a6845d4280dfab108fb25d7ea792f529549b76e448e7ba2a49acec7a008bd34deaf0d7133b94cce7d2c7c01d82c062007999023d1f29ac7d1b46b85aa2c00eadff1e33525b9a67028ca7c91b4b57ec37cba6bada474df696850f5bd12f6eaafce9a7b7eabc1a1593557228ddee53ed3ef87ad5d12c84609a31d59ae90939c5565060647fb5bd4994756534ac293e1c04d3555c3bc0188fefe685819f20d8263ac1fcc386a0d21f21b2b9597027041fbe6e8f4ebdd40b1a8d14d1b7152f4cd3f097195de819c3bdfe277a9a82";

	std::string str_b="c40c23e6f8572fbf3ef3ebce64fae530c85b1717d616f5bfe3dc2e22598561a52bcb5e61ad453f2d178885fbf73411f398c4ef3af110a6ab4b2d0fca8c8225b2165a37f3e604d270e9711f3110e4e1e3446e468bf367e23a80a2ef2d6c586d33eca03a311ae5bf8eed4852550894ce51dc21f086edf75779d7838ca25604f5c63de571c3459a96be01947ef3669c91ca1ad5cee5454cd36cd833bfb13102cc89cc1cd83bde44fd9d99d7fc1043230c709331e307be56fa0cd525fa92de41cd82628bf433385717846fd38c276d16d7034f603a5be279477979d77d19252abd6b1c5178b3c636da328a356cb924ce196b8217bc3879d75a7e896045f72a77a17f";

	std::string str_n="9aa8673d4679873eddfafd81b6ecb2d9758fe8a7ac8f48904459b3ffef875759e82653d5fef67ff73382803c6b44e4a51dd68348ea0d5061086fd53307ae77b94c10078127a2d24ab10e9fb34d0c29da6743d68c381af72186bcea5c5bd826779bdb76513ba3f0aa1c28b08a4acc2ebbac4430b08d5d791e4b698a295b8eaf4db390bc81376f0f282f5450bf62ebc59a010501d9d9c41fbdc5eec654b1a7793acf722572e9be5c2b8a94f86a4509f1066f0eeb3a4474da213c19de8d38df63c49f7ce87c1e1036c060c9fed5807752ef9bebe2111b51920e344ea5a5867bb3f48b638b8e1abe62892c2dc77f93ba286f2f18f32096dd3566dc8e28f45716e28d";

	bn_a.Str_2_BN_WORD(str_a);
	bn_b.Str_2_BN_WORD(str_b);
	rsa_n.m_n.Str_2_BN_WORD(str_n);
*/
        BN_WORD_openssl_transform(open_a,bn_a);
        BN_WORD_openssl_transform(open_b,bn_b);
/*
	
        openssl_BN_WORD_transform(open_a,bn_a);
        openssl_BN_WORD_transform(open_b,bn_b);
        openssl_BN_WORD_transform(open_n,rsa_n.m_n);
*/

        RSA_N rsa_n2=rsa_n;
        CRT_N *crt_n ;
        crt_n = new CRT_N (rsa_n);

        BN_mod_mul(open_result, open_a, open_b, open_n, ctx);

        crt_n->CRT_MOD_MUL(bn_a, bn_b, bn_result);
	
	BN_WORD_openssl_transform(open_result,bn_open_result);

        if(bn_result==bn_open_result){
                sum=sum+1;
        }
	else{
	    printf("a:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_a.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("b:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<bn_b.m_data[j];
	    }
	    std::cout<<std::endl;
	    printf("n:\n");
	    for(int j=31;j>=0;j--){
	        std::cout<<std::hex<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<rsa_n.m_n.m_data[j];
	    }
	    std::cout<<std::endl;
	}

    }
    std:: cout<<"test_crt_mul_mod:"<<std:: endl;
    std:: cout<<"total:"<< LOOP_NUM<<", right:"<<sum<<std:: endl;

    return 0;

}
