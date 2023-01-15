#include<stdio.h>
#include"sm4.h"
#define ENCRYPT 1
#define DECRYPT 0

void sm4(u8 sm4_enc, u32 sm4_key[4], u32 sm4_din[4], u32 sm4_dout[4]) {
	u32 RK[32]; // round key
	u32 K[4]; // Intermediate ciphertext
	u32 sm4_key_temp[] = {sm4_key[0],sm4_key[1],sm4_key[2],sm4_key[3]};
	u32 sm4_din_temp[] = {sm4_din[0],sm4_din[1],sm4_din[2],sm4_din[3]};
	
	if(sm4_enc = ENCRYPT){
		getRK(sm4_key_temp, K, RK);
		encryptSM4(sm4_din_temp, RK, sm4_dout);
	}
	else{
		getRK(sm4_key_temp, K, RK);
		decryptSM4(sm4_din_temp, RK, sm4_dout);
	}
} 

void sm4_ctr(u32 sm4_ctr_iv[4], u32 sm4_ctr_key[4], u32 sm4_ctr_din[4], u32 sm4_ctr_dout[4]) {
	u32 sm4_ctr_iv_temp [] = {sm4_ctr_iv[0],sm4_ctr_iv[1],sm4_ctr_iv[2],sm4_ctr_iv[3]};
	u32 sm4_ctr_key_temp[] = {sm4_ctr_key[0],sm4_ctr_key[1],sm4_ctr_key[2],sm4_ctr_key[3]};
	u32 sm4_ctr_din_temp[] = {sm4_ctr_din[0],sm4_ctr_din[1],sm4_ctr_din[2],sm4_ctr_din[3]};
	u32 sm4_ctr_iv_cipher[4];
	
	sm4(ENCRYPT,sm4_ctr_key_temp,sm4_ctr_iv_temp,sm4_ctr_iv_cipher);
	
	sm4_ctr_dout[0] = sm4_ctr_iv_cipher[0] ^ sm4_ctr_din_temp[0];
	sm4_ctr_dout[1] = sm4_ctr_iv_cipher[1] ^ sm4_ctr_din_temp[1];
	sm4_ctr_dout[2] = sm4_ctr_iv_cipher[2] ^ sm4_ctr_din_temp[2];
	sm4_ctr_dout[3] = sm4_ctr_iv_cipher[3] ^ sm4_ctr_din_temp[3];
} 

int main(){
	u8  sm4_ctr_channel = 4;
	u32 sm4_ctr_iv[4];
	u32 sm4_ctr_key[4];
	u32 sm4_ctr_din[sm4_ctr_channel][4];
	u32 sm4_ctr_dout[sm4_ctr_channel][4];
	
	//sm4_ctr_iv
	sm4_ctr_iv[0] = 0x00010203;
	sm4_ctr_iv[1] = 0x04050607;
	sm4_ctr_iv[2] = 0x08090A0B;
	sm4_ctr_iv[3] = 0x0C0D0E0F;
	
	//sm4_ctr_key
	sm4_ctr_key[0] = 0x01234567;
	sm4_ctr_key[1] = 0x89abcdef;
	sm4_ctr_key[2] = 0xfedcba98;
	sm4_ctr_key[3] = 0x76543210;
	
	//sm4_ctr_din_0channel
	sm4_ctr_din[0][0] = 0xAAAAAAAA;
	sm4_ctr_din[0][1] = 0xAAAAAAAA;
	sm4_ctr_din[0][2] = 0xBBBBBBBB;
	sm4_ctr_din[0][3] = 0xBBBBBBBB;
	
	//sm4_ctr_din_1channel
	sm4_ctr_din[1][0] = 0xCCCCCCCC;
	sm4_ctr_din[1][1] = 0xCCCCCCCC;
	sm4_ctr_din[1][2] = 0xDDDDDDDD;
	sm4_ctr_din[1][3] = 0xDDDDDDDD;
	
	//sm4_ctr_din_2channel
	sm4_ctr_din[2][0] = 0xEEEEEEEE;
	sm4_ctr_din[2][1] = 0xEEEEEEEE;
	sm4_ctr_din[2][2] = 0xFFFFFFFF;
	sm4_ctr_din[2][3] = 0xFFFFFFFF;
	
	//sm4_ctr_din_3channel
	sm4_ctr_din[3][0] = 0xAAAAAAAA;
	sm4_ctr_din[3][1] = 0xAAAAAAAA;
	sm4_ctr_din[3][2] = 0xBBBBBBBB;
	sm4_ctr_din[3][3] = 0xBBBBBBBB;
	
	for(u32 i=0; i<sm4_ctr_channel; i++){
		sm4_ctr(sm4_ctr_iv,sm4_ctr_key,sm4_ctr_din[i],sm4_ctr_dout[i]);
		sm4_ctr_iv[3] ++;
		printf("%08x %08x %08x %08x\n", sm4_ctr_dout[i][0], sm4_ctr_dout[i][1], sm4_ctr_dout[i][2], sm4_ctr_dout[i][3]);
	}
	return 0;
}

/*
SM4-CTR Test Vectors

Example 1
Plaintext:
AA AA AA AA AA AA AA AA BB BB BB BB BB BB BB BB
CC CC CC CC CC CC CC CC DD DD DD DD DD DD DD DD
EE EE EE EE EE EE EE EE FF FF FF FF FF FF FF FF
AA AA AA AA AA AA AA AA BB BB BB BB BB BB BB BB

Encryption Key:
01 23 45 67 89 AB CD EF FE DC BA 98 76 54 32 10

IV:
00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

Ciphertext:
AC 32 36 CB 97 0C C2 07 91 36 4C 39 5A 13 42 D1
A3 CB C1 87 8C 6F 30 CD 07 4C CE 38 5C DD 70 C7
F2 34 BC 0E 24 C1 19 80 FD 12 86 31 0C E3 7B 92
6E 02 FC D0 FA A0 BA F3 8B 29 33 85 1D 82 45 14

Example 2
Plaintext:
AA AA AA AA AA AA AA AA BB BB BB BB BB BB BB BB
CC CC CC CC CC CC CC CC DD DD DD DD DD DD DD DD
EE EE EE EE EE EE EE EE FF FF FF FF FF FF FF FF
AA AA AA AA AA AA AA AA BB BB BB BB BB BB BB BB

Encryption Key:
FE DC BA 98 76 54 32 10 01 23 45 67 89 AB CD EF

IV:
00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

Ciphertext:
5D CC CD 25 B9 5A B0 74 17 A0 85 12 EE 16 0E 2F
8F 66 15 21 CB BA B4 4C C8 71 38 44 5B C2 9E 5C
0A E0 29 72 05 D6 27 04 17 3B 21 23 9B 88 7F 6C
8C B5 B8 00 91 7A 24 88 28 4B DE 9E 16 EA 29 06
*/

