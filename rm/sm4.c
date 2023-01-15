#include<stdio.h>
#include"sm4.h"

u32 functionB(u32 b) {
	u8 a[4];
	short i;
	a[0] = b / 0x1000000;
	a[1] = b / 0x10000;
	a[2] = b / 0x100;
	a[3] = b;
	b = Sbox[a[0]] * 0x1000000 + Sbox[a[1]] * 0x10000 + Sbox[a[2]] * 0x100 + Sbox[a[3]];
	return b;
}


u32 loopLeft(u32 a, short length) {
	short i;
	for(i = 0; i < length; i++) {
		a = a * 2 + a / 0x80000000;
	}
	return a;
}


u32 functionL1(u32 a) {
	return a ^ loopLeft(a, 2) ^ loopLeft(a, 10) ^ loopLeft(a, 18) ^ loopLeft(a, 24);
}


u32 functionL2(u32 a) {
	return a ^ loopLeft(a, 13) ^ loopLeft(a, 23);
}


u32 functionT(u32 a, short mode) {
	return mode == 1 ? functionL1(functionB(a)) : functionL2(functionB(a));
}
 

void extendFirst(u32 MK[], u32 K[]) {
	int i;
	for(i = 0; i < 4; i++) {
		K[i] = MK[i] ^ FK[i]; 
	} 
}


void extendSecond(u32 RK[], u32 K[]) {
	short i;
	for(i = 0; i <32; i++) {
		K[(i+4)%4] = K[i%4] ^ functionT(K[(i+1)%4] ^ K[(i+2)%4] ^ K[(i+3)%4] ^ CK[i], 2);
		RK[i] = K[(i+4)%4];
	} 
}


void getRK(u32 MK[], u32 K[], u32 RK[]) {
	extendFirst(MK, K);
	extendSecond(RK, K);
}


void iterate32(u32 X[], u32 RK[]) {
	short i;
	for(i = 0; i < 32; i++) {
		X[(i+4)%4] = X[i%4] ^ functionT(X[(i+1)%4] ^ X[(i+2)%4] ^ X[(i+3)%4] ^ RK[i], 1);
	}
}


void reverse(u32 X[], u32 Y[]) {
	 short i;
	 for(i = 0; i < 4; i++){
	 	Y[i] = X[4 - 1 - i];
	 } 
} 


void encryptSM4(u32 X[], u32 RK[], u32 Y[]) {
	iterate32(X, RK);
	reverse(X, Y);
} 


void decryptSM4(u32 X[], u32 RK[], u32 Y[]) {
	short i;
	u32 reverseRK[32];
	for(i = 0; i < 32; i++) {
		reverseRK[i] = RK[32-1-i];
	}
	iterate32(X, reverseRK);
	reverse(X, Y);
}
 



