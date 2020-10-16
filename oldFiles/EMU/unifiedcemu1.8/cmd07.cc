#include "debug.h"
#include "misc.h"
#include "cmd07.h"
#include "mapcalls.h"
#include "cemu.h"
#include <iostream>
using namespace std;

char bufstr[255];

//sha1 vars
unsigned char bytes[64];
int unprocessedBytes;
uint32_t size;
uint32_t H0, H1, H2, H3, H4;

uint8_t nagrasaideakey[16];
uint8_t rsamodulus[0x40];
uint8_t ideakey8696[16];
uint8_t verifykey[16];
uint8_t sessionkey[16];
int pos10, pos11;

int dolog = 0;

void SetIdeaKey8696(char * key)
{
	GetBuf(ideakey8696,key);
}
void SetRSAModulus(char * key)
{
	GetBuf(rsamodulus,key);
}
void SetVerifyKey(char * key)
{
	GetBuf(verifykey,key);
}
void SetNagraSAIdeaKey(char * key)
{
	GetBuf(nagrasaideakey,key);
	addtolog("Set Nagra S.A. Ideakey -");
	addtolog(key);
}

void SetSessionKey(char * key)
{
	GetBuf(sessionkey,key);
	addtolog("Set Session Key -");
	addtolog(key);
}

void SetLog(int log)
{
	dolog = log;
}
void addtolog(char *logentry)
{
  if (dolog) D_CMD07 << logentry << endl; //printf("%s\r\n",logentry);;
	return;
}
int axtoi(char *hexStg) {
  int n = 0;         // position in string
  int m;             // position in digit[] to shift
  int count;         // loop index
  int intValue = 0;  // integer value of hex string
  int digit[9];      // hold values to convert
  while (n < 8) {
     if (hexStg[n]=='\0')
        break;
     if (hexStg[n] > 0x29 && hexStg[n] < 0x40 ) //if 0 to 9
        digit[n] = hexStg[n] & 0x0f;            //convert to int
     else if (hexStg[n] >='a' && hexStg[n] <= 'f') //if a to f
        digit[n] = (hexStg[n] & 0x0f) + 9;      //convert to int
     else if (hexStg[n] >='A' && hexStg[n] <= 'F') //if A to F
        digit[n] = (hexStg[n] & 0x0f) + 9;      //convert to int
     else break;
    n++;
  }
  count = n;
  m = n - 1;
  n = 0;
  while(n < count) {
     intValue = intValue | (digit[n] << (m << 2));
     m--;   // adjust the position to set
     n++;   // next digit to process
  }
  return (intValue);
}

char * GetBufStr(unsigned char *inBuf,int len)
{
	int i;
	char tempstr2[4];
	strcpy(bufstr,"\0");
  for (i=0;i<len;i++){
    sprintf(tempstr2,"%02X",inBuf[i]);
    strcat(bufstr,tempstr2);
  }
	return bufstr;
}

void GetBuf(unsigned char *retBuf, char *tempstr) {
  unsigned char  byte;
  int i;
  char tempstr2[4];

  tempstr2[2] = '\0';
  for (i=0;i<(int)strlen(tempstr)/2;i++){
    tempstr2[0] = tempstr[i * 2];
    tempstr2[1] = tempstr[i * 2 + 1];
    byte = axtoi(tempstr2);
    retBuf[i] = byte & 0xFF;
  }
}
void padleft(char *ret, char *pad, int len){
  int i;
  char tempstr[255];

  strcpy(tempstr,"");
  len = len - strlen(ret);
  for (i=0; i<len;i++){
    strcat(tempstr,pad);
  }
  strcat(tempstr,ret);
  strcpy(ret,tempstr);
}

void RotateBytes(unsigned char *out, const unsigned char *in, int n)
{
  // loop is executed atleast once, so it's not a good idea to
  // call with n=0 !!
  out+=n;
  do { *(--out)=*(in++); } while(--n);
}

void RotateBytes(unsigned char *in, int n)
{
  // loop is executed atleast once, so it's not a good idea to
  // call with n=0 !!
  unsigned char *e=in+n-1;
  do {
    unsigned char temp=*in;
    *in++=*e;
    *e-- =temp;
    } while(in<e);
}

void revbytes(char * inbuf, char * outbuf){
  int i,len;
  char tempstr[5000], tempstr2[4];

  strcpy(tempstr,"");
  len = strlen(inbuf);
  for (i=len/2; i>=0; i--){
    tempstr2[0] = inbuf[i * 2];
    tempstr2[1] = inbuf[i * 2 + 1];
    tempstr2[2] = '\0';
    strcat(tempstr,tempstr2);
  }
  strcpy(outbuf,tempstr);
}

// circular left bit rotation.  MSB wraps around to LSB
uint32_t lrot( uint32_t x, int bits )
{
	return (x<<bits) | (x>>(32 - bits));
};

// Save a 32-bit unsigned integer to memory, in big-endian order
void storeBigEndianUint32( unsigned char* byte, uint32_t num )
{
	assert( byte );
	byte[0] = (unsigned char)(num>>24);
	byte[1] = (unsigned char)(num>>16);
	byte[2] = (unsigned char)(num>>8);
	byte[3] = (unsigned char)num;
}

// Constructor *******************************************************
void SHA1create(){
	// make sure that the data type is the right size
	assert( sizeof( uint32_t ) * 5 == 20 );
	
	// initialize
	H0 = 0x67452301;
	H1 = 0xefcdab89;
	H2 = 0x98badcfe;
	H3 = 0x10325476;
	H4 = 0xc3d2e1f0;
	unprocessedBytes = 0;
	size = 0;
}

// Destructor ********************************************************
void SHA1destroy()
{
  int c;
	// erase data
	H0 = H1 = H2 = H3 = H4 = 0;
	for(  c = 0; c < 64; c++ ) bytes[c] = 0;
	unprocessedBytes = size = 0;
}

// process ***********************************************************
void process()
{
	assert( unprocessedBytes == 64 );
	//printf( "process: " ); hexPrinter( bytes, 64 ); printf( "\n" );
	int t;
	uint32_t a, b, c, d, e, K, f, W[80];
	// starting values
	a = H0;
	b = H1;
	c = H2;
	d = H3;
	e = H4;
	// copy and expand the message block
	for( t = 0; t < 16; t++ ) W[t] = (bytes[t*4] << 24)
									+(bytes[t*4 + 1] << 16)
									+(bytes[t*4 + 2] << 8)
									+ bytes[t*4 + 3];
	for(; t< 80; t++ ) W[t] = lrot( W[t-3]^W[t-8]^W[t-14]^W[t-16], 1 );
	
	/* main loop */
	uint32_t temp;
	for( t = 0; t < 80; t++ )
	{
		if( t < 20 ) {
			K = 0x5a827999;
			f = (b & c) | ((b ^ 0xFFFFFFFF) & d);//TODO: try using ~
		} else if( t < 40 ) {
			K = 0x6ed9eba1;
			f = b ^ c ^ d;
		} else if( t < 60 ) {
			K = 0x8f1bbcdc;
			f = (b & c) | (b & d) | (c & d);
		} else {
			K = 0xca62c1d6;
			f = b ^ c ^ d;
		}
		temp = lrot(a,5) + f + e + W[t] + K;
		e = d;
		d = c;
		c = lrot(b,30);
		b = a;
		a = temp;
		//printf( "t=%d %08x %08x %08x %08x %08x\n",t,a,b,c,d,e );
	}
	/* add variables */
	H0 += a;
	H1 += b;
	H2 += c;
	H3 += d;
	H4 += e;
	//printf( "Current: %08x %08x %08x %08x %08x\n",H0,H1,H2,H3,H4 );
	/* all bytes have been processed */
	unprocessedBytes = 0;
}

// addBytes **********************************************************
void addBytes( unsigned char* data, int num )
{
	assert( data );
	assert( num > 0 );
	// add these bytes to the running total
	size += num;
	// repeat until all data is processed
	while( num > 0 )
	{
		// number of bytes required to complete block
		int needed = 64 - unprocessedBytes;
		assert( needed > 0 );
		// number of bytes to copy (use smaller of two)
		int toCopy = (num < needed) ? num : needed;
		// Copy the bytes
		memcpy( bytes + unprocessedBytes, data, toCopy );
		// Bytes have been copied
		num -= toCopy;
		data += toCopy;
		unprocessedBytes += toCopy;
		
		// there is a full block
		if( unprocessedBytes == 64 ) process();
	}
}

// digest ************************************************************
unsigned char* getDigest(unsigned char* digest)
{
	// save the message size
	uint32_t totalBitsL = size << 3;
	uint32_t totalBitsH = size >> 29;
	// add 0x80 to the message
	addBytes( (unsigned char*)"\x80", 1 );
	
	unsigned char footer[64] = {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	// block has no room for 8-byte filesize, so finish it
	if( unprocessedBytes > 56 )
		addBytes( (unsigned char*)footer, 64 - unprocessedBytes);
	assert( unprocessedBytes <= 56 );
	// how many zeros do we need
	int neededZeros = 56 - unprocessedBytes;
	// store file size (in bits) in big-endian format
	storeBigEndianUint32( footer + neededZeros    , totalBitsH );
	storeBigEndianUint32( footer + neededZeros + 4, totalBitsL );
	// finish the final block
	addBytes( (unsigned char*)footer, neededZeros + 8 );
	// allocate memory for the digest bytes
	//unsigned char* digest = (unsigned char*)malloc( 20 );
	// copy the digest bytes
	storeBigEndianUint32( digest, H0 );
	storeBigEndianUint32( digest + 4, H1 );
	storeBigEndianUint32( digest + 8, H2 );
	storeBigEndianUint32( digest + 12, H3 );
	storeBigEndianUint32( digest + 16, H4 );
  //      free(digest);
	// return the digest
	return digest;
}


void EnKeyIdea(uint8_t *pPlainKey, uint16_t *pEncryptedKey)
{
    int i,j;
    uint16_t val;

    for (i=0; i<8; i++) {
      pEncryptedKey[i] = (pPlainKey[0] << 8) | pPlainKey[1];
      pPlainKey += 2;
    }
    j = 0;
    while (i < 52) { // loop 44 times
      j++;       // j is now 1..8
      // shift bits
      val = (pEncryptedKey[j&7] << 9) | (pEncryptedKey[(j+1)&7] >> 7);
      // store into next block, last round j <- 4 so need +4 in next block
      pEncryptedKey[7+j] = val;
      pEncryptedKey += j & 8; // increment by 8 if j <- 8
      j &= 0x07; // keep j between 0..7
      i++;
    }
}

// invert key
// multiplicative inverse
uint16_t inv(uint16_t val)
{
    uint16_t retval;
    uint16_t val_quot,val_rem,val_rem1;

    if (val >= 2) {
      val_quot = 65537 / val;
      val_rem  = 65537 % val;
      retval = 1;
      while (val_rem != 1) {
        val_rem1 = val / val_rem;
        val = val % val_rem;
        retval += val_rem1 * val_quot;
        if (val == 1) {
          return(retval);
        }
        val_rem1 = val_rem / val;
        val_rem  = val_rem % val;
        val_quot += val_rem1 * retval;
      }
      retval = (1 - val_quot) & 0xFFFF;
    } else {
      retval = val;
    }
    return retval;
}
//---------------------------------------------------------------------------
void DeKeyIdea(uint16_t *pEncryptedKey, uint16_t *pDecryptedKey)
{
    int i;
    uint16_t Buf[52], *pBuf;
    uint32_t sp28, sp32, sp36;

    char tempstr[255],tempstr2[255];

    // work on first 4 shorts
    pBuf = &Buf[51];
    sp28 = inv(*pEncryptedKey++);    // [0]
    sp32 = - *pEncryptedKey++;       // [1]
    sp36 = - *pEncryptedKey++;       // [2]
    *pBuf-- = inv(*pEncryptedKey++); // [3]
    *pBuf-- = sp36;
    *pBuf-- = sp32;
    *pBuf-- = sp28;

    // do loop 7 times and work in blocks of 6 for 42 shorts
    // IDEA_ROUNDS is 8
    for (i=0; i<7; i++) {
      sp28 = *pEncryptedKey++;          // [0]
      *pBuf-- = *pEncryptedKey++;       // [1]
      *pBuf-- = sp28;
      sp28 = inv(*pEncryptedKey++);     // [2]
      sp32 = - *pEncryptedKey++;        // [3]
      sp36 = - *pEncryptedKey++;        // [4]
      *pBuf-- = inv(*pEncryptedKey++);  // [5]
      *pBuf-- = sp32;
      *pBuf-- = sp36;
      *pBuf-- = sp28;
    }

    // work on last 6 shorts
    sp28 = *pEncryptedKey++;          // [0]
    *pBuf-- = *pEncryptedKey++;       // [1]
    *pBuf-- = sp28;
    sp28 = inv(*pEncryptedKey++);     // [2]
    sp32 = - *pEncryptedKey++;        // [3]
    sp36 = - *pEncryptedKey++;        // [4]
    *pBuf-- = inv(*pEncryptedKey++);  // [5]
    *pBuf-- = sp36;
    *pBuf-- = sp32;
    *pBuf-- = sp28;

    if(pBuf[0] == 0xff) {}
    // now copy Buf to pDecryptedKey
    memcpy(pDecryptedKey,(uint16_t *)Buf,sizeof(Buf));

    strcpy(tempstr,"\0");
    for (i=0;i<52;i++){
      sprintf(tempstr2,"%04X ",pDecryptedKey[i]);
      strcat(tempstr,tempstr2);
    }
    addtolog("Expanded Decryption Idea Key-");
    addtolog(tempstr);

}
// similar to MUL(x,y) macro
uint16_t _mul(uint16_t x, uint16_t y)
{
    uint32_t _t32;
    uint16_t ret;
    uint16_t high, low;
    if (x == 0) return 1-y;
    _t32 = (uint32_t) x * y;
    low = _t32 & 0xffff;
    high = _t32 >> 16;
    ret = (low - high) + (low<high?1:0);
    return(ret);
}

void CipherIdea8B(uint8_t *pInputBuf, uint8_t *pOutputBuf, uint16_t *Key)
{
    uint16_t x1, x2, x3,x4, s2, s3;
    uint16_t *in, *out;
    int r = 8; // IDEA_ROUNDS

    in = (uint16_t *)pInputBuf;
    x1 = *in++;
    x2 = *in++;
    x3 = *in++;
    x4 = *in;

    x1 = (x1>>8) | (x1<<8);
    x2 = (x2>>8) | (x2<<8);
    x3 = (x3>>8) | (x3<<8);
    x4 = (x4>>8) | (x4<<8);

    do {
        x1 = _mul(x1, *Key++);
        x2 += *Key++;
        x3 += *Key++;
        x4 = _mul(x4, *Key++ );

        s3 = x3;
        x3 ^= x1;
        x3 = _mul(x3, *Key++);
        s2 = x2;
        x2 ^=x4;
        x2 += x3;
        x2 = _mul(x2, *Key++);
        x3 += x2;

        x1 ^= x2;
        x4 ^= x3;

        x2 ^= s3;
        x3 ^= s2;
    } while( --r );
    x1 = _mul(x1, *Key++);
    x3 += *Key++;
    x2 += *Key++;
    x4 = _mul(x4, *Key);

    out = (uint16_t *)pOutputBuf;
    *out++ = (x1>>8) | (x1<<8);
    *out++ = (x3>>8) | (x3<<8);
    *out++ = (x2>>8) | (x2<<8);
    *out   = (x4>>8) | (x4<<8);
}

void SignIdea(uint8_t *pInputBuf, uint16_t KeyLen, uint8_t *pSig,  uint8_t *pKey) {
    int i,j,k;
    uint8_t buf[16];
    uint16_t Key[52]; // 52 = 6*IDEA_ROUNDS+4
    char tempstr[255],tempstr2[255];

    memcpy(buf,pKey,16);
    for (i=0; i < KeyLen ; i+=8) {

      EnKeyIdea(buf,Key);

      memcpy(buf,buf+8,8);

      strcpy(tempstr,"\0");
      for (k=0;k<8;k++){
        sprintf(tempstr2,"%02X",pInputBuf[k+i]);
        strcat(tempstr,tempstr2);
      }

      CipherIdea8B(pInputBuf+i, buf+8, Key);

      strcat(tempstr," XOR ");
      for (k=0;k<8;k++){
        sprintf(tempstr2,"%02X",buf[k+8]);
        strcat(tempstr,tempstr2);
      }

      for (j=7; j>=0; j--) {
        buf[j+8] ^= pInputBuf[i+j];
      }
      strcat(tempstr," = ");
      for (k=0;k<8;k++){
        sprintf(tempstr2,"%02X",buf[k+8]);
        strcat(tempstr,tempstr2);
      }
      addtolog(tempstr);
    }
    buf[8]&=0x7F;
    memcpy(pSig,buf+8,8);
}


void IDEACryptCBC(uint8_t *pInputBuf, uint16_t *pKey, uint8_t *pOutputBuf, uint16_t KeyLen, uint8_t *pSeed, uint8_t a5)
{
    char tempstr[255], tempstr2[255];
    uint16_t i,sp64,sp66;
    uint8_t Seed[16], buf[8];
    uint8_t *startout;
    int startlen;

    startout = pOutputBuf;
    startlen = KeyLen;

    addtolog("Idea Decrypted(dCW) -");
    strcpy(tempstr,"\0");
    for (i=0;i<startlen;i++){
      sprintf(tempstr2,"%02X",pInputBuf[i]);
      strcat(tempstr,tempstr2);
    }
    addtolog(tempstr);

    sp64 = 1;
    sp66 = 0;
    if (pSeed == 0) {
      memset(Seed,0,8);
    } else {
      memmove(Seed,pSeed,8);
    }

    while (KeyLen >= 8) {
      if (a5) {
        for (i=0; i<8; i++) {
          buf[i] = *pInputBuf++ ^ Seed[i];
        }
      } else {
        // a5 == 0
        memmove(Seed + sp64*8, pInputBuf, 8);
        for (i=0; i<8; i++) {
          buf[(i^sp66) & 0xFFFF] = *pInputBuf++;
        }
      }

      strcpy(tempstr,"Idea Rnd - ");
      for (i=0;i<8;i++){
        sprintf(tempstr2,"%02X",buf[i]);
        strcat(tempstr,tempstr2);
      }

      CipherIdea8B(buf,buf,pKey);

      strcat(tempstr," - ");
      for (i=0;i<8;i++){
        sprintf(tempstr2,"%02X",buf[i]);
        strcat(tempstr,tempstr2);
      }

      if (a5) {
        for (i=0; i<8; i++) {
          *pOutputBuf++ = buf[(i^sp66) & 0xFFFF];
        }
        memmove(Seed,pOutputBuf-8,8);
      } else {
        // a5 == 0
        for (i=0; i<8; i++) {
          *pOutputBuf++ = buf[(i^sp66) & 0xFFFF] ^
                          Seed[i+((sp64 ^ 1) & 0xFFFF)*8];
        }
        sp64 ^= 1;
      }
      KeyLen -= 8;

      strcat(tempstr," - ");
      for (i=0;i<8;i++){
        sprintf(tempstr2,"%02X",pOutputBuf[i-8]);
        strcat(tempstr,tempstr2);
      }
      addtolog(tempstr);

    }
    while ((--KeyLen & 0xFFFF) != 0xFFFF) {
      *pOutputBuf = 0;
    }

    addtolog("Idea Encrypted(CW) -");
    strcpy(tempstr,"\0");
    for (i=0;i<startlen;i++){
      sprintf(tempstr2,"%02X",startout[i]);
      strcat(tempstr,tempstr2);
    }
    addtolog(tempstr);
}

void xxor(unsigned char *data, int len, const unsigned char *v1, const unsigned char *v2)
{
  switch(len) { // looks ugly, but the compiler can optimize it very well ;)
    case 16:
      *((unsigned int *)data+3) = *((unsigned int *)v1+3) ^ *((unsigned int *)v2+3);
      *((unsigned int *)data+2) = *((unsigned int *)v1+2) ^ *((unsigned int *)v2+2);
    case 8:
      *((unsigned int *)data+1) = *((unsigned int *)v1+1) ^ *((unsigned int *)v2+1);
    case 4:
      *((unsigned int *)data+0) = *((unsigned int *)v1+0) ^ *((unsigned int *)v2+0);
      break;
    default:
      while(len--) *data++ = *v1++ ^ *v2++;
      break;
    }
}

void Encrypt9c(unsigned char *data){
  uint16_t Key[52];
  uint8_t pOutputBuf[71];

  addtolog("9C Response Idea Session Key -");
  addtolog(GetBufStr(sessionkey,16));

  EnKeyIdea(sessionkey, Key);

  IDEACryptCBC(data+pos10,Key,pOutputBuf,0x8,0,0);

  IDEACryptCBC(data+pos11,Key,pOutputBuf+8,0x8,0,0);

  addtolog("9C Response Control Words -");
  addtolog(GetBufStr(pOutputBuf,16));
  return;
}


const unsigned char primes[] = {
  0x03,0x05,0x07,0x0B,0x0D,0x11,0x13,0x17,0x1D,0x1F,0x25,0x29,0x2B,0x2F,0x35,0x3B,
  0x3D,0x43,0x47,0x49,0x4F,0x53,0x59,0x61,0x65,0x67,0x6B,0x6D,0x71,0x7F,0x83,0x89,
  0x8B,0x95,0x97,0x9D,0xA3,0xA7,0xAD,0xB3,0xB5,0xBF,0xC1,0xC5,0xC7,0xD3,0xDF,0xE3,
  0xE5,0xE9,0xEF,0xF1,0xFB
};

void MakePrime(BIGNUM *n, unsigned char *residues)
{
  bool isPrime;
  do {
    BN_add_word(n,2);
    isPrime=true;
    for(int i=0; i<53; i++) {
      residues[i]+=2;
      residues[i]%=primes[i];
      if(residues[i]==0) isPrime=false;
      }
    } while(!isPrime);
}

void ExpandInput(unsigned char *hw)
{
  char tempstr[512],tempstr2[512];
  uint16_t Key[52];
  int i,k;

  EnKeyIdea(nagrasaideakey, Key);

  strcpy(tempstr,"\0");
  for (i=0;i<52;i++){
    sprintf(tempstr2,"%04X ",Key[i]);
    strcat(tempstr,tempstr2);
  }
  addtolog("Expanded Nagravision Idea Key - ");
  addtolog(tempstr);

  hw[0]^=(0xDE +(0xDE<<1)) & 0xFF;
  hw[1]^=(hw[0]+(0xDE<<1)) & 0xFF;
  for(i=2; i<0x80; i++) hw[i]^=hw[i-2]+hw[i-1];

  strcpy(tempstr,"\0");
  for (i=0;i<0x80;i++){
    sprintf(tempstr2,"%02X",hw[i]);
    strcat(tempstr,tempstr2);
  }
  addtolog("Expanded Input - ");
  addtolog(tempstr);

  unsigned char buf[8];
  memset(buf,0,8);
  for(i=0; i<0x80; i+=8) {
    xxor(buf,8,buf,&hw[i]);
    strcpy(tempstr,"\0");
    for (k=0;k<8;k++){
      sprintf(tempstr2,"%02X",buf[k]);
      strcat(tempstr,tempstr2);
    }
    strcat(tempstr," - ");

    CipherIdea8B(buf, buf, Key);

    for (k=0;k<8;k++){
      sprintf(tempstr2,"%02X",buf[k]);
      strcat(tempstr,tempstr2);
    }
    strcat(tempstr," - ");

    xxor(buf,8,buf,&hw[i]);

    for (k=0;k<8;k++){
      sprintf(tempstr2,"%02X",buf[k]);
      strcat(tempstr,tempstr2);
    }
    addtolog(tempstr);

    memcpy(&hw[i],buf,8);
  }

  strcpy(tempstr,"\0");
  for (i=0;i<0x80;i++){
    sprintf(tempstr2,"%02X",hw[i]);
    strcat(tempstr,tempstr2);
  }
  addtolog("Idea Encrypted Expanded Nagravision Input to Map3b/57 - ");
  addtolog(tempstr);

}

int DoMap(int f, unsigned char *data, int len)
{
 switch(f) {
    case 0x3b:
      if(len>=80) {
        D_CMD07 << "Map 3B" << endl;
        map3b(data);
        map3b(data+0x28);
        return 1;
        }
      break;
    case 0x57:
      if(len>=128) {
	D_CMD07 << "Map 57" << endl;
        map57(data);
        return 1;
        }
      break;
    default:
      printf("Unsupported call %02x\n",f);
      return 0;
      break;
    }
 return 0;
}

int MECM(unsigned char in15, int algo, unsigned char *cw)
{
  int i;
  uint16_t ks[52];
  char tempstr[512], tempstr2[512];
  unsigned char hd[5], hw[128+64], buf[20];
  unsigned char digest[20];
	
  hd[0]=in15&0x7F; //highbyte
  hd[1]=cw[14];    //lowbyte, cw2byte7
  hd[2]=cw[15];    //cw2byte8
  hd[3]=cw[6];     //cw1byte7
  hd[4]=cw[7];     //cw1byte8

  sprintf(tempstr,"%02X%02X%02X%02X%02X",hd[0],hd[1],hd[2],hd[3],hd[4]);
  addtolog("Expansion Seed - ");
  addtolog(tempstr);

    memset(hw,0,sizeof(hw));
    if(algo==0x40) {
      memcpy(hw,hd,3);
      ExpandInput(hw);
  
      hw[0x18]|=1; hw[0x40]|=1;

      if(!DoMap(0x3b,hw,80)) return 0;
      RotateBytes(hw,64);
      RotateBytes(&hw[64],64);

      addtolog("Rotated Map 3b Input to SHA - ");
      addtolog(GetBufStr(hw,0x80));
			
      SHA1create();
      addBytes(hw,0x80);
      memset(hw,0,128);
      hw[0]=H3&0xFF;
      hw[1]=(H3>>8)&0xFF;

      sprintf(tempstr,"H3 = %08X",(unsigned int)H3);
      addtolog(tempstr);

      addtolog("SHA 3b Output - ");
      addtolog(GetBufStr(hw,20));

      SHA1destroy();

    }
    else if(algo==0x60) { // map 4D/4E/57
    memcpy(hw,hd,5);
    ExpandInput(hw);
    cBN bh;
    RotateBytes(hw,128);
    BN_bin2bn(hw,128,bh);

    /* MAP 4D */
    unsigned char residues[53];
    BN_set_bit(bh,0x3FF);
    BN_set_bit(bh,0);
    strcpy(tempstr,"\0");
    for(int i=0; i<53; i++) {
      residues[i]=BN_mod_word(bh,primes[i]);

  
      sprintf(tempstr2,"%02X",residues[i]);
      strcat(tempstr,tempstr2);
    }
    addtolog("MAP 4d residues - ");
    addtolog(tempstr);

    /* MAP 4E */
    MakePrime(bh,residues);
   /* Do some byte jumbling */
    BN_bn2bin(bh,hw);
    RotateBytes(hw,128);
    BN_bin2bn(hw,128,bh);

    addtolog("MAP 4e jumble - ");
    addtolog(GetBufStr(hw,128));

    /* MAP 4E */
    MakePrime(bh,residues);
    BN_bn2bin(bh,hw);
    RotateBytes(hw,128);

    addtolog("Input to MAP 57 - ");
    addtolog(GetBufStr(hw,128));

    /* MAP 57 */
      if(!DoMap(0x57,hw,128)) return 0;
    addtolog("Output from MAP 57 - ");
    addtolog(GetBufStr(hw,128));
    } // end algo 0x60
    else {
      printf("Unknown MECM algo %02x\n",algo);
      return 0;
    }

      sprintf(tempstr,"%02X%02X",hw[0],hw[1]);
      addtolog("SHA1 Intermediate Results - ");
      addtolog(tempstr);

      memcpy(&hw[128],hw,64);
      RotateBytes(&hw[64],128);

      addtolog("SHA1 Intermediate Input - ");
      addtolog(GetBufStr(hw,0x80));

      SHA1create();
      addBytes(&hw[64],0x80);
      getDigest(digest);
      SHA1destroy();

      addtolog("SHA1 Intermediate Output - ");
      addtolog(GetBufStr(digest,20));
			
      for (i=0;i<20;i++) buf[i] = digest[i];
      RotateBytes(buf,20);

  memcpy(&buf[8],buf,8);

  addtolog("Control Word Idea Key - ");
  addtolog(GetBufStr(buf,20));

  EnKeyIdea(buf, ks);

  memcpy(&buf[0],&cw[8],6);
  memcpy(&buf[6],&cw[0],6);

  addtolog("Idea 12 Control Words Input - ");
  addtolog(GetBufStr(buf,16));

  CipherIdea8B(&buf[4], &buf[4], ks);

  addtolog("Idea 12 Control Words Intermediate - ");
  addtolog(GetBufStr(buf,16));

  CipherIdea8B(buf, buf, ks);

  addtolog("Idea 12 Control Words Output - ");
  addtolog(GetBufStr(buf,16));
 
  memcpy(&cw[ 0],&buf[6],3);
  memcpy(&cw[ 4],&buf[9],3);
  memcpy(&cw[ 8],&buf[0],3);
  memcpy(&cw[12],&buf[3],3);

  for(int i=0; i<16; i+=4) cw[i+3]=cw[i]+cw[i+1]+cw[i+2];
  addtolog("Cleartext Control Words - ");
  addtolog(GetBufStr(cw,16));


  return 1;
}


int ProcessECM(unsigned char *buff)
{
  unsigned char cw[16];
  int mecmAlgo=0, l = 0;
  pos10 = 0, pos11 = 0;
#ifdef DEBUG
  bool contFail=false;
#endif

  addtolog("EMU Starting Control Word String -");
  addtolog(GetBufStr(buff,0x60));

  for(int i=16; i<0x40 && l!=3; ) {
    switch(buff[i]) {
      case 0x10:
      case 0x11:
        if(buff[i+1]==0x09) {
          int s=(~buff[i])&1;
          mecmAlgo=buff[i+2]&0x60;
          memcpy(cw+(s<<3),&buff[i+3],8);
          if(buff[i] == 0x10) pos10 = i + 3;
	  else if(buff[i] == 0x11) pos11 = i + 3;
          i+=11; l|=(s+1);
          }
        else {
          //commented out for joe-q public
          //printf("system-nagra2: bad length %d in CW nano %02x\n",buff[i+1],buff[i]);
          //replaced with this user friendly message
          if (ghetoroll == 1)
	        {
	        printf("The Keys have changed, please update your key files\n\n");
	        }
	        if (ghetoroll == 0)
	        {
	        printf("Waiting for the Keys to roll, please stand by...\nIf This message does not stop after 15 minutes,\nmanually update your keys or try Ghettoroll\n\n");
      }
          i++;
          }
        break;
      case 0x00:
        i+=2; break;
      case 0x13 ... 0x15:
        i+=4; break;
      case 0x30 ... 0x36:
      case 0xB0:
        i+=buff[i+1]+2;
        break;
      default:
#ifdef DEBUG
        //commented out the following lines for joe-q public
        //if(!contFail) printf("Unknown ECM nano");
        //printf(" %02x",buff[i]);
        //replaced with this user friendly message
      if (ghetoroll == 1)
      {
      printf("The Keys have changed, please update your key files\n\n");
      }
      if (ghetoroll == 0)
      {
      printf("Waiting for the Keys to roll, please stand by...\nIf This message does not stop after 15 minutes,\nmanually update your keys or try Ghettoroll\n\n");
      }
      contFail=true;
#endif
        i++;
        continue;
      }
#ifdef DEBUG
if (ghetoroll == 1)
{
 if(contFail) { printf("The Keys have changed, please update your key files\n\n"); contFail=false; }
 }
 if (ghetoroll == 0)
 {
    if(contFail) { printf("Waiting For the Keys to roll, please stand by...\n\n"); contFail=false; }
}
#endif
    }
#ifdef DEBUG
if (ghetoroll == 1)
{
if(contFail) printf("The Keys have changed, please update your key files\n\n");
}
if (ghetoroll == 0)
{
  if(contFail) printf("Waiting For the Keys to roll, please stand by...\n\n");
}
#endif

if(pos11 == 0){
   addtolog("Error: Unable to find Rev103 control words.");
   return 0;
 }

 addtolog("Rev103 Control Words -");
  addtolog(GetBufStr(cw,16));
   if(l!=3) return 0; 
  if(mecmAlgo>0) {
      if(!MECM(buff[15],mecmAlgo,cw)) return 0;
      }
	memcpy (buff+pos10,cw+8,8);
	memcpy (buff+pos11,cw,8);

  addtolog("EMU Return Control Word String -");
  addtolog(GetBufStr(buff,0x60));
		
  return 1;
}
