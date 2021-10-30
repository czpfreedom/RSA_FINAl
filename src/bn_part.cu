#include "bn_part.h"

#ifndef INT_MASK2L
#define INT_MASK2L (0xffffffff)
#endif

#ifndef INT_MASK2l
#define INT_MASK2l (0xffff)
#endif

#ifndef LONG_MASK2L
#define LONG_MASK2L (0xffffffffffffffffL)// unsigned long
#endif

#ifndef LONG_MASK2l
#define LONG_MASK2l (0xffffffffL)        // unsigned long also  but with 32 zeros at the top
#endif

namespace namespace_rsa_final{

int int_mod(const int a,const int b){
    int c=a%b;
    while(c<0){
        c=c+b;
    }
    return c;
}

#ifdef BN_PART_32

int BN_PART_mul(const BN_PART a, const BN_PART b, BN_PART &u, BN_PART &v){
    unsigned long result = (((unsigned long)a)&LONG_MASK2l)*(((unsigned long)b)&LONG_MASK2l);
    u=(unsigned int)((result>>(sizeof(unsigned int)*8))&LONG_MASK2l);
    v=(unsigned int)((result)&LONG_MASK2l);
    return 0;
}

#endif

#ifdef BN_PART_64
int BN_PART_mul(const BN_PART a, const BN_PART b, BN_PART &u, BN_PART &v){
    BN_PART ah= (a>>32)&LONG_MASK2l;
    BN_PART al= a&LONG_MASK2l;
    BN_PART bh= (b>>32)&LONG_MASK2l;
    BN_PART bl= b&LONG_MASK2l;

    BN_PART carry= 0;
    BN_PART ll=al*bl;
    BN_PART hl=ah*bl;
    BN_PART lh=al*bh;
    BN_PART hh=ah*bh;
    v=ll+(hl<<32);
    if(v<ll){
        carry=carry+1;
    }
    ll=v;
    v=ll+(lh<<32);
    if(v<ll){
        carry=carry+1;
    }
    hh=hh+((hl>>32)&LONG_MASK2l)+((lh>>32)&LONG_MASK2l)+carry;
    u=hh;
    return 0;
}
#endif

int BN_PART_get_bit(const BN_PART a,int i){
    return  (a&((BN_PART)1<<i))>>i;

}

int BN_PART_mod_inverse(const BN_PART a, const BN_PART b, BN_PART &a_inverse){
    BN_PART temp, R1, R2, t1,t2,q;
    if(b==0){
        R1=a;
        R2=0-a;
        t1=1;
        q=1+R2/R1;
        R2=R2%R1;
        t2=0-q;
    }
    else{
	R1=a;
	R2=b;
	t1=1;
	t2=0;
    }
    while(R2!=0){
        temp=R2;
        q=R1/R2;
        R2=R1%R2;
        R1=temp;
        temp=t2;
        t2=t1-t2*q;
        t1=temp;
    }
    if(R1==1){
	if(b==0){
	    a_inverse=t1;
	}
	else {
            a_inverse=t1%b;	
	}
        return 0;
    }
    else{
        return -1;
    }
}

int BN_PART_mul_lo(const BN_PART a, const BN_PART b, BN_PART &result){
    BN_PART temp_u, temp_v;
    BN_PART_mul(a,b,temp_u,temp_v);
    result=temp_v;
    return 0;
}

int BN_PART_mad_lo(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v){
    BN_PART temp_u, temp_v;
    BN_PART_mul(a,b,temp_u,temp_v);
    v=temp_v+c;
    if(v<temp_v){
        u=1;
    }
    else{
        u=0;
    }
    return 0;
}

int BN_PART_mad_hi(const BN_PART a, const BN_PART b, BN_PART c, BN_PART &u, BN_PART &v){
    BN_PART temp_u, temp_v;
    BN_PART_mul(a,b,temp_u,temp_v);
    v=temp_u+c;
    if(v<temp_u){
        u=1;
    }
    else{
        u=0;
    }
    return 0;
}

int BN_PART_any(BN_PART *a, int dmax){
    for(int i=0;i<dmax;i++){
        if(a[i]!=0){
            return 0;
        }
    }
    return 1;
}

#ifdef BN_PART_32
int BN_PART_add_mod(BN_PART a, BN_PART b, BN_PART n, BN_PART &result){
    result = (BN_PART)((((unsigned long)a)+((unsigned long)b))%((unsigned long)n));
    return 0;
}

int BN_PART_mul_mod(BN_PART a, BN_PART b, BN_PART n, BN_PART &result){
    result = (BN_PART)((((unsigned long)a)*((unsigned long)b))%((unsigned long)n));
    return 0;
}

#endif


#ifdef BN_PART_64
int BN_PART_add_mod(BN_PART a, BN_PART b, BN_PART n, BN_PART &result){
    a=a%n;
    b=b%n;
    BN_PART temp_result=a+b;
    if(temp_result<a){
	result=temp_result-n;
    }
    else{
        result=temp_result%n;
    }

    return 0;
}

int BN_PART_mul_mod(BN_PART a, BN_PART b, BN_PART n, BN_PART &result){
    a=a%n;
    b=b%n;
    BN_PART temp_result=0;
    while(b>0){
	if(b&1){
	    BN_PART_add_mod(temp_result,a,n,temp_result);
	}
	BN_PART_add_mod(a,a,n,a);
	b>>=1;
    }
    result=temp_result;

    return 0;
}

#endif


}
