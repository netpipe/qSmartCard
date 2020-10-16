#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <assert.h>
#include <openssl/bn.h>

#ifndef cmd07H
#define cmd07H

void addtolog(char *logentry);
int axtoi(char *hexStg);
void GetBuf(unsigned char *retBuf, char *tempstr);
char *GetBufStr(unsigned char *inBuf,int len);
void padleft(char *ret, char *pad, int len);
void RotateBytes(unsigned char *in, int n);
void RotateBytes(unsigned char *out, const unsigned char *in, int n);
void revbytes(char * inbuf, char * outbuf);
uint32_t lrot( uint32_t x, int bits );
void storeBigEndianUint32( unsigned char* byte, uint32_t num );
void SHA1create();
void SHA1destroy();
void process();
void addBytes( unsigned char* data, int num );
unsigned char* getDigest();
void EnKeyIdea(uint8_t *pPlainKey, uint16_t *pEncryptedKey);
void DeKeyIdea(uint16_t *pEncryptedKey, uint16_t *pDecryptedKey);
uint16_t inv(uint16_t val);
uint16_t mul(uint16_t x, uint16_t y);
void CipherIdea8B(uint8_t *pInputBuf, uint8_t *pOutputBuf, uint16_t *Key);
void IDEACryptCBC(uint8_t *pInputBuf, uint16_t *pKey, uint8_t *pOutputBuf, uint16_t KeyLen, uint8_t *pSeed, uint8_t a5);
void xxor(unsigned char *data, int len, const unsigned char *v1, const unsigned char *v2);
int DoEmu(int map, unsigned char *data);
void MakePrime(BIGNUM *n, unsigned char *residues);
void ExpandInput(unsigned char *hw);
int MECM(unsigned char in15, int algo, unsigned char *cw);
int ProcessECM(unsigned char *data);
void SetNagraSAIdeaKey(char * key);
void SetLog(int log);
void SetSessionKey(char * key);
void Encrypt9c(unsigned char *data);

#endif
