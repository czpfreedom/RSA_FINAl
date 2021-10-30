#include "bn_word.h"
#include "stdio.h"

namespace namespace_rsa_final{

GPU_WORD :: GPU_WORD(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=0;
    m_top=1; 
}

GPU_WORD :: GPU_WORD(GPU_WORD &gw){
    memcpy(m_data,gw.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=gw.m_neg;
    m_top=gw.m_top;
}

GPU_WORD& GPU_WORD ::operator=(GPU_WORD &gw){
    memcpy(m_data,gw.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=gw.m_neg;
    m_top=gw.m_top;
    return *this;
}

GPU_WORD :: ~GPU_WORD(){

}

GPU_WORD& GPU_WORD :: operator+(GPU_WORD &gw_2){
    BN_PART carry1, carry2;
    GPU_WORD add_result;
    GPU_WORD gw_1_neg, gw_2_neg;
    GPU_WORD gw_1;
    gw_1=*this;
    int top;
    if(gw_1.m_neg==gw_2.m_neg){
        add_result.m_neg=gw_1.m_neg;
	carry1=0;
	carry2=0;
	top=(gw_1.m_top>=gw_2.m_top)?gw_1.m_top:gw_2.m_top;
	for(int i=0;i<top;i++){
	    carry2=carry1;
	    carry1=0; 
	    add_result.m_data[i]=carry2+gw_1.m_data[i];
	    if(add_result.m_data[i]<gw_1.m_data[i]){
	        carry1=1;
	    }
	    add_result.m_data[i]=add_result.m_data[i]+gw_2.m_data[i];
	    if(add_result.m_data[i]<gw_2.m_data[i]){
		carry1=1;
	    }	    	    
	}
	add_result.m_data[top]=carry1;
	add_result.check_top();
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        gw_2_neg=gw_2;
	gw_2_neg.change_neg();
	if(gw_1==gw_2_neg){
	    add_result.setzero();
	    *this=add_result;
	    return *this;
	}
	if(gw_1>gw_2_neg){
	    top=gw_1.m_top;
	    carry2=0;
	    carry1=0;
	    for(int i=0;i<top;i++){
	        carry2=carry1;
		carry1=0;
		add_result.m_data[i]=gw_1.m_data[i]-carry2;
		if(add_result.m_data[i]>gw_1.m_data[i]){
		    carry1=1;
		}
		add_result.m_data[i]=add_result.m_data[i]-gw_2.m_data[i];
		if(add_result.m_data[i]>gw_2.m_data[i]){
		    carry1=1;
		}
	    }
	    add_result.m_neg=0;
	    add_result.check_top();
	}
	if(gw_1<gw_2_neg){
	    top=gw_2_neg.m_top;
	    carry2=0;
	    carry1=0;
	    for(int i=0;i<top;i++){
	        carry2=carry1;
		carry1=0;
		add_result.m_data[i]=gw_2.m_data[i]-carry2;
		if(add_result.m_data[i]>gw_2.m_data[i]){
		    carry1=1;
		}
		add_result.m_data[i]=add_result.m_data[i]-gw_1.m_data[i];
		if(add_result.m_data[i]>gw_1.m_data[i]){
		    carry1=1;
		}
	    }
	    add_result.m_neg=1;
	    add_result.check_top();
	}
    }    
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        gw_1_neg=gw_1;
	gw_1_neg.change_neg();
	if(gw_1_neg==gw_2){
	    add_result.setzero();
	    *this=add_result;
	    return *this;
	}
	if(gw_1_neg>gw_2){
	    top=gw_1.m_top;
	    carry2=0;
	    carry1=0;
	    for(int i=0;i<top;i++){
	        carry2=carry1;
		carry1=0;
		add_result.m_data[i]=gw_1.m_data[i]-carry2;
		if(add_result.m_data[i]>gw_1.m_data[i]){
		    carry1=1;
		}
		add_result.m_data[i]=add_result.m_data[i]-gw_2.m_data[i];
		if(add_result.m_data[i]>gw_2.m_data[i]){
		    carry1=1;
		}
	    }
	    add_result.m_neg=1;
	    add_result.check_top();
	}
	if(gw_1_neg<gw_2){
	    top=gw_2_neg.m_top;
	    carry2=0;
	    carry1=0;
	    for(int i=0;i<top;i++){
	        carry2=carry1;
		carry1=0;
		add_result.m_data[i]=gw_2.m_data[i]-carry2;
		if(add_result.m_data[i]>gw_2.m_data[i]){
		    carry1=1;
		}
		add_result.m_data[i]=add_result.m_data[i]-gw_1.m_data[i];
		if(add_result.m_data[i]>gw_1.m_data[i]){
		    carry1=1;
		}
	    }
	    add_result.m_neg=1;
	    add_result.check_top();
	}
    }    
    *this= add_result;
    return *this;	    	
}

GPU_WORD& GPU_WORD :: operator-(GPU_WORD &gw_2){
    GPU_WORD gw_2_neg;
    GPU_WORD sub_result;
    GPU_WORD gw_1;
    gw_1=*this;
    gw_2_neg = gw_2;
    gw_2_neg.change_neg();
    sub_result=gw_1+gw_2_neg;
    *this = sub_result;
    return * this;
}

GPU_WORD& GPU_WORD :: operator*(GPU_WORD &gw_2){
    GPU_WORD mul_result;
    GPU_WORD gw_1_mul;
    GPU_WORD gw_1;
    gw_1=*this;
    mul_result.setzero();
    gw_1_mul=gw_1;
    for(int i=0;i<sizeof(BN_PART)*8*gw_2.m_top;i++){
	gw_1_mul.left_shift(1);
        if(gw_2.get_bit(i)==1){
	    mul_result=mul_result+gw_1_mul;
	}
    }
    if(gw_1.m_neg==gw_2.m_neg){
        mul_result.m_neg=0;
    }
    if(gw_1.m_neg!=gw_2.m_neg){
        mul_result.m_neg=1;
    }
    mul_result.check_top();
    *this=mul_result;
    return *this;
}

GPU_WORD& GPU_WORD :: operator/(GPU_WORD &gw_2){
    GPU_WORD div_result;
    GPU_WORD gw_1_neg, gw_2_neg;
    GPU_WORD zero, one;
    GPU_WORD gw_1;
    gw_1=*this;
    int shift_num;
    gw_1_neg=gw_1;
    gw_2_neg=gw_2;
    zero.setzero();
    one.setone();
    if(gw_1.m_neg==1){
        gw_1_neg.change_neg();
    }
    if(gw_2.m_neg==1){
        gw_2_neg.change_neg();
    }
    
    if(gw_1_neg<gw_2_neg){
        div_result.setzero();
	*this=div_result;
	return *this;
    }
    
    shift_num=0;
    while(gw_1_neg>=gw_2_neg){
        shift_num++;
	gw_2_neg.left_shift(1);
    }
    gw_2_neg.right_shift(1);
    shift_num--;
    one.left_shift(shift_num);
    for(int i=0;i<shift_num;i++){
        if(gw_1_neg>=gw_2_neg){
	    gw_1_neg=gw_1_neg-gw_2_neg;
	    div_result=div_result+one;
	}
	gw_2_neg.right_shift(1);
	one.right_shift(1);
    }
    if(gw_1.m_neg==gw_2.m_neg){
        div_result.m_neg=0;
    }
    if(gw_1.m_neg!=gw_2.m_neg){
        div_result.m_neg=1;
    }
    div_result.check_top();
    *this = div_result;
    return *this;
    
}

GPU_WORD& GPU_WORD :: operator%(GPU_WORD &gw_2){
    GPU_WORD rem_result;
    GPU_WORD gw_1_neg, gw_2_neg;
    GPU_WORD zero, one;
    GPU_WORD gw_1;
    gw_1=*this;
    int shift_num;
    gw_1_neg=gw_1;
    gw_2_neg=gw_2;
    zero.setzero();
    one.setone();
    if(gw_1.m_neg==1){
        gw_1_neg.change_neg();
    }
    if(gw_2.m_neg==1){
        gw_2_neg.change_neg();
    }
    
    if(gw_1_neg<gw_2_neg){
	rem_result=gw_1;
	*this=rem_result;
	return *this;
    }
    
    shift_num=0;
    while(gw_1_neg>=gw_2_neg){
        shift_num++;
	gw_2_neg.left_shift(1);
    }
    gw_2_neg.right_shift(1);
    shift_num--;
    one.left_shift(shift_num);
    for(int i=0;i<shift_num;i++){
        if(gw_1_neg>=gw_2_neg){
	    gw_1_neg=gw_1_neg-gw_2_neg;
	}
	gw_2_neg.right_shift(1);
	one.right_shift(1);
    }
    rem_result=gw_1_neg;
    rem_result.check_top();
    *this = rem_result;
    return *this;
}

int  GPU_WORD :: left_shift (int bits){
    int num_bits=bits%(sizeof(BN_PART)*8);
    int num_bnpart=bits/(sizeof(BN_PART)*8);
    GPU_WORD shift_result;
    GPU_WORD gw;
    gw=*this;
    shift_result.m_neg=gw.m_neg;
    shift_result.m_top=gw.m_top;
    for (int i=0;i<num_bnpart;i++){
        shift_result.m_data[i]=0;
    }
    shift_result.m_data[num_bnpart]=gw.m_data[0]<<num_bits;
    for (int i=num_bnpart+1;i<=num_bnpart+gw.m_top;i++){
        if(num_bits==0){
            shift_result.m_data[i]=gw.m_data[i-num_bnpart];
        }
        else{
	    shift_result.m_data[i]=gw.m_data[i-num_bnpart]<<num_bits+gw.m_data[i-num_bnpart-1]>>(sizeof(BN_PART)*8-num_bits);
        }
    }
    shift_result.check_top();
    *this=shift_result;
    return 1;
}

int GPU_WORD :: right_shift(int bits){
    int num_bits=bits%(sizeof(BN_PART)*8);
    int num_bnpart=bits/(sizeof(BN_PART)*8);	
    GPU_WORD shift_result;
    GPU_WORD gw;
    gw=*this;
    shift_result.m_neg=gw.m_neg;
    shift_result.m_top=gw.m_top;
    for (int i=0;i<gw.m_top-num_bnpart;i++){
	if(num_bits==0){	    
	    shift_result.m_data[i]=gw.m_data[i+num_bnpart];
	}
	else{
	    shift_result.m_data[i]=gw.m_data[i+num_bnpart]>>num_bits+gw.m_data[i+num_bnpart+1]<<(sizeof(BN_PART)*8-num_bits);
	}
    }
    shift_result.check_top();
    *this = shift_result;
    return 1;
}

bool GPU_WORD :: operator==(GPU_WORD &gw_2){
    GPU_WORD gw_1;
    gw_1=*this;
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        return false;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        return false;
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==0)){
        if(gw_1.m_top>gw_2.m_top){
	    return false;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return false;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return false;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return false;
	    }
	}
	return true;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==1)){
        if(gw_1.m_top>gw_2.m_top){
	    return false;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return false;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return false;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return false;
	    }
	}
	return true;    
    }
    //error
    return false; 
}

bool GPU_WORD :: operator!=(GPU_WORD &gw_2){
    GPU_WORD gw_1;
    gw_1=*this;
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        return true;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        return true;
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==0)){
        if(gw_1.m_top>gw_2.m_top){
	    return true;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return true;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return true;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return false;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==1)){
        if(gw_1.m_top>gw_2.m_top){
	    return true;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return true;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return true;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return false;    
    }
    //error
    return false; 
}

bool GPU_WORD :: operator>(GPU_WORD &gw_2){
    GPU_WORD gw_1;
    gw_1=*this;
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        return true;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        return false;
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==0)){
        if(gw_1.m_top>gw_2.m_top){
	    return true;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return false;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return true;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return false;
	    }
	}
	return false;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==1)){
        if(gw_1.m_top>gw_2.m_top){
	    return false;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return true;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return false;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return false;    
    }
    //error
    return false; 
}

bool GPU_WORD :: operator<(GPU_WORD &gw_2){
    GPU_WORD gw_1;
    gw_1=*this;
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        return false;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        return true;
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==0)){
        if(gw_1.m_top>gw_2.m_top){
	    return false;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return true;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return false;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return false;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==1)){
        if(gw_1.m_top>gw_2.m_top){
	    return true;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return false;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return true;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return false;
	    }
	}
	return false;    
    }
    //error
    return false; 
}

bool GPU_WORD :: operator>=(GPU_WORD &gw_2){
    GPU_WORD gw_1;
    gw_1=*this;
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        return true;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        return false;
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==0)){
        if(gw_1.m_top>gw_2.m_top){
	    return true;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return false;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return true;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return false;
	    }
	}
	return true;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==1)){
        if(gw_1.m_top>gw_2.m_top){
	    return false;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return true;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return false;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return true;    
    }
    //error
    return false; 
}

bool GPU_WORD :: operator<=(GPU_WORD &gw_2){
    GPU_WORD gw_1;
    gw_1=*this;
    if((gw_1.m_neg==0)&&(gw_2.m_neg==1)){
        return false;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==0)){
        return true;
    }
    if((gw_1.m_neg==0)&&(gw_2.m_neg==0)){
        if(gw_1.m_top>gw_2.m_top){
	    return false;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return true;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return false;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return true;
    }
    if((gw_1.m_neg==1)&&(gw_2.m_neg==1)){
        if(gw_1.m_top>gw_2.m_top){
	    return true;
	}
	if(gw_1.m_top<gw_2.m_top){
	    return false;
	}
	for(int i=gw_1.m_top-1;i>=0;i--){
	    if(gw_1.m_data[i]>gw_2.m_data[i]){
	        return true;
	    }
	    if(gw_1.m_data[i]<gw_2.m_data[i]){
	        return true;
	    }
	}
	return true;    
    }
    //error
    return false; 
}

BN_PART GPU_WORD :: get_bit(int i){
    int num_bits=i%(sizeof(BN_PART)*8);
    int num_bnpart=i/(sizeof(BN_PART)*8);
    return BN_PART_get_bit(m_data[num_bnpart],num_bits);
}

int GPU_WORD :: check_top(){
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

int GPU_WORD :: change_neg(){
    if(m_neg==1){
        m_neg=0;
    }
    else{    
        m_neg=1;
    }
    check_top();
    return 1;
}


int GPU_WORD :: BN_WORD_2_GPU_WORD(BN_WORD &bw){
    memcpy(m_data,bw.m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=bw.m_neg;
    m_top=bw.m_top;
    return 1;
}

int GPU_WORD :: GPU_WORD_2_BN_WORD(BN_WORD &bw){
    memcpy(bw.m_data,m_data,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    bw.m_neg=m_neg;
    bw.m_top=m_top;
    return 1;
}

int GPU_WORD :: setzero(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));
    m_neg=0;
    m_top=1;
    return 1;
}

int GPU_WORD :: setone(){
    memset(m_data,0,BN_WORD_LENGTH_MAX*sizeof(BN_PART));               
    m_data[0]=1;
    m_neg=0;                
    m_top=1;
    return 1;
}

int GPU_WORD :: print(){
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

}
