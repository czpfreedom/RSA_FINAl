#include "bn_word.h"
#include "stdio.h"
#include "string.h"
#include "iostream"
#include "sstream"
#include <iomanip>

namespace namespace_rsa_final{

BN_WORD :: BN_WORD(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=0;
    m_top=1;
}

BN_WORD:: BN_WORD(BN_WORD &bn_word){
    memcpy(m_data,bn_word.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=bn_word.m_neg;
    m_top=bn_word.m_top;
}

BN_WORD& BN_WORD:: operator=(BN_WORD &bn_word){
    memcpy(m_data,bn_word.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=bn_word.m_neg;
    m_top=bn_word.m_top;
    return *this;
}

BN_WORD:: ~BN_WORD(){

}

int BN_WORD:: check_top(){
    for(int i=BN_WORD_LENGTH_MAX-1;i>=0;i--){
        if(i==0){
            if(m_data[i]==0){
                setzero();
                return 1;
            }
        }
        if(m_data[i]!=0){
            m_top=i+1;
            break;
        }
    }
    if(m_top>BN_WORD_LENGTH_MAX/2){
        //error
        return -1;
    }
    return 1;
}

int BN_WORD:: setzero(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=0;
    m_top=1;
    return 1;
}

int BN_WORD:: setone(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_data[0]=1;
    m_neg=0;
    m_top=1;
    return 1;
}

int BN_WORD:: setR(int top){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_data[top-1]=1;
    m_neg=0;
    m_top=top;
    return 1;
}

int BN_WORD:: print(){
    if(m_neg==0){
        printf("postive: top: %d\n", m_top);
    }
    if(m_neg==1){
        printf("negtive: top: %d\n", m_top);
    }
    for(int i=m_top-1;i>=0;i--){
        printf("%lx,",m_data[i]);
    }
    printf("\n");
    return 1;
}

int BN_WORD:: BN_WORD_2_Str(std::string &str){
    std:: stringstream fmt;
    for(int i=m_top-1;i>=0;i--){
	fmt<<std::setw(sizeof(BN_PART)*2)<<std::setfill('0')<<std::hex<<m_data[i];
    }
    fmt>>str;
    /*
    std::cout<<"start_print"<<std::endl;
    std::cout<<"BN_WORD"<<std::endl;
    print();
    std::cout<<"String"<<std::hex<<str<<std::endl;
    */
    return 0;
}

int BN_WORD:: Str_2_BN_WORD(std::string str){
    std:: string sub_str;
    int top=0;
    setzero();
    std:: stringstream fmt;
    for(int i=str.length()/(sizeof(BN_PART)*2)-1;i>=0;i--){
        sub_str=str.substr(i*(sizeof(BN_PART)*2),sizeof(BN_PART)*2);
	fmt.clear();
	fmt<<std::hex<<sub_str;
	fmt>>m_data[top];
	top++;
    }
    m_top=top;
    return 1;
}

int BN_WORD:: BN_WORD_C_2_BN_WORD(BN_WORD_C *bw_c){
    memcpy(m_data,bw_c->m_data,sizeof(BN_PART)*BN_WORD_LENGTH_MAX);
    m_top=bw_c->m_top;
    m_neg=bw_c->m_neg;
    return 1;
}

int BN_WORD:: BN_WORD_2_BN_WORD_C(BN_WORD_C *bw_c){
    memcpy(bw_c->m_data,m_data,sizeof(BN_PART)*BN_WORD_LENGTH_MAX);
    bw_c->m_top=m_top;
    bw_c->m_neg=m_neg;
    return 1;
}


BN_WORD& BN_WORD :: operator+ (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1+gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator- (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1-gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator* (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1*gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator/ (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1/gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

BN_WORD& BN_WORD :: operator% (BN_WORD &bw){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw);
    gw_1=gw_1%gw_2;
    gw_1.GPU_WORD_2_BN_WORD(*this);
    return *this;
}

bool BN_WORD :: operator==(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1==gw_2);
}

bool BN_WORD :: operator!=(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1!=gw_2);
}
 
bool BN_WORD :: operator> (BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1>gw_2);
}

bool BN_WORD :: operator< (BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1<gw_2);
}

bool BN_WORD :: operator>=(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1>=gw_2);
}

bool BN_WORD :: operator<=(BN_WORD &bw_2){
    GPU_WORD gw_1,gw_2;
    gw_1.BN_WORD_2_GPU_WORD(*this);
    gw_2.BN_WORD_2_GPU_WORD(bw_2);
    return (gw_1<=gw_2);
}

}
