#include <stdio.h>
#include <stdlib.h>
#include "misc.h"
#include "cmd07.h"
#include "common.h"
#include <openssl/bn.h>
//#define BENCHMARK
#ifdef BENCHMARK
#include <sys/time.h>
#include <time.h>
#include <string>
using namespace std;
double elapsed_avg=0, elapsed_max=0, elapsed_min=0;
int z=0;
void wtime_(double tim[2], int *ierr2 )
{
   struct timeval time1; 
//   long tim1, tim2; 
   int ierr; 
//   double elap; 
   ierr = gettimeofday(&time1, NULL) ; 
   *ierr2 = ierr; 
   if (ierr != 0 ) printf("bad return of gettimeofday, ierr = %d \n",ierr);  
   tim[0] = time1.tv_sec;
   tim[1] = time1.tv_usec; 
//   printf("tim sec = %.0f \n",tim[0]);
 //  printf("tim usec = %.0f \n", tim[1]);   
}

char *time_stamp(char *ttime)
{ time_t rawtime;
  struct tm * timeinfo;
  string tminfo;
 
  time ( &rawtime );
  timeinfo = localtime ( &rawtime );
  ttime = asctime (timeinfo);
  ttime[19]=0x0;
    
  return (ttime) ;

}
#endif

BIGNUM *bn_glb0, *bn_glb1, *bn_glb3, *bn_glb5, *bn_glb6, *bn_glb7;
BIGNUM *bn_glb_a, *bn_glb_b, *bn_glb_c, *bn_glb_d, *bn_glb_e, *bn_glb_f, *bn_glb_g;
BIGNUM *bn_glb_h, *bn_glb_i, *bn_glb_j, *bn_glb_k, *bn_glb_l, *bn_glb_m;
BIGNUM *glb2pow128, *mask128, *glb2pow64, *mask64;
BN_CTX *t1;


void printx(BIGNUM *bn) {
  unsigned char data[256];
  int i, len;
  memset(data, 0, 256);
  len = BN_bn2bin(bn, data);
  if(len)
    RotateBytes(data, len);
  for(i = 0; i < len; i+=4) {
    if(i != 0 && i%4 == 0)
      printf(" ");
    printf("0x%08x", *(unsigned int *)(&data[i]));
  }
  printf("\n");
}


void mod_add(BIGNUM *arg1, BIGNUM *arg2, BIGNUM *arg3, BIGNUM *arg4)
{
  BN_add(arg1, arg2, arg3);
  if(BN_cmp(arg1, arg4) >= 0) {
    BN_sub(arg1, arg1, arg4);
  }
  BN_mask_bits(arg1, 128);
}

void bn_cmplx1(BIGNUM *arg1, BIGNUM *arg2, BIGNUM *arg3,
          BIGNUM *arg4, BIGNUM *arg5)
{
  int j;
  BIGNUM *var44, *var64, *var84, *vara4;
  var44 = BN_new();
  var64 = BN_new();
  var84 = BN_new();
  vara4 = BN_new();
  BN_copy(var44, arg2);
  BN_copy(var64, arg3);
  BN_clear(vara4);
  for(j=0; j<2; j++) {
    BN_copy(var84, var64);
    BN_mask_bits(var84, 64);
    BN_rshift(var64, var64, 64);
    BN_mul(var84, var84, var44, t1);
    BN_add(vara4, vara4, var84);
    BN_copy(var84, vara4);
    BN_mask_bits(var84, 128);
    BN_mul(var84, vara4, arg4, t1);
    BN_mask_bits(var84, 64);
    BN_mul(var84, var84, arg5, t1);
    BN_add(vara4, vara4, var84);
    BN_rshift(vara4, vara4, 64);
    if(BN_cmp(vara4, arg5) >= 0) {
      BN_sub(vara4, vara4, arg5);
    }
    BN_mask_bits(vara4, 128);
  }
  BN_copy(arg1, vara4);
  BN_free(var44);
  BN_free(var64);
  BN_free(var84);
  BN_free(vara4);
}

void bn_cmplx1a(BIGNUM *arg1, BIGNUM *arg2, BIGNUM *arg3,
          BIGNUM *arg4, BIGNUM *arg5)
{
  int j;
  BIGNUM *var44, *var64, *var84, *vara4;
  var44 = BN_new();
  var64 = BN_new();
  var84 = BN_new();
  vara4 = BN_new();
  BN_copy(var44, arg2);
  BN_copy(var64, arg3);
  BN_clear(vara4);
  for(j=0; j<2; j++) {
    BN_copy(var84, var64);
    BN_mask_bits(var84, 64);
    BN_rshift(var64, var64, 64);
    BN_mul(var84, var84, var44, t1);
    BN_add(vara4, vara4, var84);
    BN_copy(var84, vara4);
    BN_mask_bits(var84, 128);
    BN_mul(var84, vara4, arg4, t1);
    BN_mask_bits(var84, 64);
    BN_mul(var84, var84, arg5, t1);
    BN_add(vara4, vara4, var84);
    BN_rshift(vara4, vara4, 64);
    if(j==0 && BN_cmp(vara4, arg5) >= 0) {
      BN_sub(vara4, vara4, arg5);
    }
    BN_mask_bits(vara4, 128);
  }
  BN_copy(arg1, vara4);
  BN_free(var44);
  BN_free(var64);
  BN_free(var84);
  BN_free(vara4);
}

//uses 3, 1, glb2pow128
//sets 1, 0 (unused)
void mod_sub()
{
  BN_copy(bn_glb0, bn_glb3);
  BN_mod_sub(bn_glb1, bn_glb3, bn_glb1, glb2pow128, t1);
  BN_mask_bits(bn_glb1, 128);
}

//uses 1, 3, 6
//sets  1, 0 (unused), 7(unused)
void bn_func1(BIGNUM *arg0) {
  BIGNUM *var30 = BN_new();
  BIGNUM *var50 = BN_new();
  BN_copy(var30,arg0);
  BN_mask_bits(var30, 8);
  unsigned int x = BN_get_word(var30);
  BN_copy(var30,arg0);
  if( x != 0) {
    BN_clear(var50);
    BN_set_word(var50, 2);
    BN_sub(var30, var30, var50);
  } else {
    BN_clear(var50);
    BN_set_word(var50, 0xfe);
    BN_add(var30, var30, var50);
  }
  BN_copy(bn_glb7, bn_glb1);
  if(BN_is_zero(arg0)) {
    BN_clear(bn_glb7);
    BN_set_word(bn_glb7, 1);
    BN_clear(bn_glb0);

    mod_add(bn_glb1, bn_glb7, bn_glb0, bn_glb3);
    BN_free(var30);
    BN_free(var50);
    return;
  } else {
    int msb = BN_num_bits(var30) -1;
    while (msb > 0) {

      bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
      msb--;
      if(BN_is_bit_set(var30, msb)) {

        bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
      }
    }
    BN_clear(bn_glb7);
    BN_set_word(bn_glb7, 1);

    bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
    BN_clear(bn_glb0);
  }
  BN_free(var30);
  BN_free(var50);
}

//uses 3, 6, a, b, c, l, glb2pow128
//sets 0, 1, 5, 7, a, b, c, f, g
void bn_func2(int arg0)
{
  BN_copy(bn_glb1, bn_glb_b);

  mod_add(bn_glb1, bn_glb1, bn_glb1, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);
  BN_copy(bn_glb5, bn_glb_c);
  BN_mask_bits(bn_glb1, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_g, bn_glb1);
  BN_copy(bn_glb1, bn_glb7);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  BN_copy(bn_glb7, bn_glb_a);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  mod_sub();
  BN_copy(bn_glb_f, bn_glb1);
  BN_copy(bn_glb1, bn_glb7);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);

  mod_add(bn_glb1, bn_glb1, bn_glb1, bn_glb3);

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);
  BN_copy(bn_glb1, bn_glb_c);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  BN_copy(bn_glb5, bn_glb_l);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  BN_copy(bn_glb0, bn_glb_f);

  mod_add(bn_glb1, bn_glb0, bn_glb1, bn_glb3);
  mod_add(bn_glb1, bn_glb0, bn_glb1, bn_glb3);
  if(arg0 == 0) {
    BN_copy(bn_glb_a, bn_glb1);
  } else {
    BN_copy(bn_glb_f, bn_glb1);
  }

  mod_add(bn_glb1, bn_glb0, bn_glb1, bn_glb3);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);
  BN_copy(bn_glb1, bn_glb_b);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);

  mod_add(bn_glb1, bn_glb1, bn_glb1, bn_glb3);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);

  mod_add(bn_glb1, bn_glb1, bn_glb1, bn_glb3);

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  mod_sub();
  if(arg0 == 0) {
    BN_copy(bn_glb_b, bn_glb1);
    BN_copy(bn_glb_c, bn_glb_g);
  } else {
    BN_copy(bn_glb_f, bn_glb1);
    BN_copy(bn_glb_f, bn_glb_g);
  }
}

//uses 3, 6, a, b, c, d, e, k
//sets 0, 1, 5, 7, a, b, c, f, g, h, i, j
void bn_func3(int arg0)
{
  BN_copy(bn_glb1, bn_glb_c);
  BN_copy(bn_glb7, bn_glb1);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);

  bn_cmplx1(bn_glb0, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  BN_copy(bn_glb_f, bn_glb0);
  BN_copy(bn_glb5, bn_glb_d);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);
  mod_sub();
  BN_copy(bn_glb0, bn_glb_a);

  mod_add(bn_glb1, bn_glb0, bn_glb1, bn_glb3);
  BN_copy(bn_glb_g, bn_glb1);
  BN_copy(bn_glb5, bn_glb_c);

  bn_cmplx1(bn_glb0, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  if(arg0 == 0) {
    BN_copy(bn_glb_c, bn_glb0);
  } else {
    BN_copy(bn_glb_g, bn_glb0);
  }

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  BN_copy(bn_glb_h, bn_glb1);
  BN_copy(bn_glb0, bn_glb_a);

  mod_add(bn_glb0, bn_glb0, bn_glb7, bn_glb3);
  BN_copy(bn_glb7, bn_glb0);

  //NOTE: don't 'mod' bn_glb1, but DO 'mod' glb_i
  bn_cmplx1(bn_glb7, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  bn_cmplx1a(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  BN_copy(bn_glb_i, bn_glb7);
  BN_copy(bn_glb1, bn_glb_e);
  BN_copy(bn_glb5, bn_glb_f);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_f, bn_glb1);
  mod_sub();
  BN_copy(bn_glb0, bn_glb_b);

  mod_add(bn_glb1, bn_glb0, bn_glb1, bn_glb3);
  BN_copy(bn_glb_j, bn_glb1);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  BN_copy(bn_glb0, bn_glb1);
  BN_copy(bn_glb1, bn_glb7);
  BN_copy(bn_glb7, bn_glb0);
  mod_sub();

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  if(arg0 == 0) {
    BN_copy(bn_glb_a, bn_glb1);
  } else {
    BN_copy(bn_glb_f, bn_glb1);
  }

  mod_add(bn_glb1, bn_glb1, bn_glb1, bn_glb3);
  mod_sub();
  BN_copy(bn_glb7, bn_glb_i);

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  BN_copy(bn_glb5, bn_glb_j);

  bn_cmplx1(bn_glb0, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb1, bn_glb_f);
  BN_copy(bn_glb_f, bn_glb0);
  BN_copy(bn_glb7, bn_glb_b);

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  BN_copy(bn_glb7, bn_glb1);
  BN_copy(bn_glb1, bn_glb_g);
  BN_copy(bn_glb5, bn_glb_h);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  mod_sub();
  BN_copy(bn_glb7, bn_glb_f);

  mod_add(bn_glb1, bn_glb1, bn_glb7, bn_glb3);
  BN_copy(bn_glb5, bn_glb_k);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  if(arg0 == 0) {
    BN_copy(bn_glb_b, bn_glb1);
  } else {
    BN_copy(bn_glb_f, bn_glb1);
  }
}

//uses c, d, e, m
//sets 0, a, b, c
void bn_cmplx7()
{
  BIGNUM *var1;
  var1 = BN_new();
  BN_copy(bn_glb0, bn_glb_c);
  if(BN_is_zero(bn_glb_c)) {
    BN_copy(bn_glb_a, bn_glb_d);
    BN_copy(bn_glb_b, bn_glb_e);
    BN_copy(bn_glb_c, bn_glb_m);
    bn_func3(1);
  } else {
    BN_clear(var1);
    BN_set_word(var1, 0xFFFFFFFF);
    BN_mask_bits(bn_glb_a, 32);
    BN_lshift(var1, bn_glb_m, 0x20);
    BN_add(bn_glb_a, bn_glb_a, var1);
    BN_mask_bits(bn_glb_a, 128);
    bn_func3(0);
  }
  BN_free(var1);
}
void bn_cmplx2(BIGNUM *var1, BIGNUM *var2, BIGNUM *var3, BIGNUM *var4,
          BIGNUM *var5, BIGNUM *var6) {
  BIGNUM *var48;
  int len = BN_num_bits(var6);
  int i;
  if(len < 2)
    return;

  if(BN_is_zero(var2) && BN_is_zero(var3) && BN_is_zero(var4))
    return;
  var48 = BN_new();
  BN_copy(bn_glb3, var1);

  BN_copy(bn_glb6, bn_glb3);
  BN_set_bit(bn_glb6, 0);
  BN_sub(bn_glb6, glb2pow128, bn_glb6);
  BN_mod_inverse(bn_glb6, bn_glb6, glb2pow64, t1);
  BN_clear(bn_glb0);
  //
  if(! BN_is_zero(bn_glb3)) {
    BN_clear(bn_glb1);
    BN_set_word(bn_glb1, 2);
    BN_clear(bn_glb_k);
    BN_set_word(bn_glb_k, 0x88);
    BN_mod_exp(bn_glb1, bn_glb1, bn_glb_k, bn_glb3, t1);
  }
  //
  for(i=0; i < 4; i++) {

    bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);
  }
  //
  BN_clear(bn_glb7);
  BN_set_word(bn_glb7, 1);
  BN_add(bn_glb0, bn_glb3, bn_glb7);
  BN_copy(bn_glb_k, bn_glb0);
  BN_rshift(bn_glb_k, bn_glb_k, 1);
  BN_copy(bn_glb7, bn_glb1);
  BN_copy(bn_glb5, bn_glb_k);
  BN_mask_bits(bn_glb5, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_k, bn_glb1);

  BN_copy(bn_glb1, var5);
  BN_mask_bits(bn_glb1, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  BN_copy(bn_glb_l, bn_glb1);
  BN_copy(bn_glb1, bn_glb7);
  BN_clear(bn_glb5);
  BN_set_word(bn_glb5, 1);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_c, bn_glb1);
  BN_copy(bn_glb_m, bn_glb1);
  BN_copy(bn_glb1, bn_glb7);

  BN_copy(bn_glb5, var2);
  BN_mask_bits(bn_glb5, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_a, bn_glb1);
  BN_copy(bn_glb1, bn_glb7);

  BN_copy(bn_glb5, var3);
  BN_mask_bits(bn_glb5, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_b, bn_glb1);
  BN_copy(bn_glb_d, bn_glb_a);
  BN_copy(bn_glb_e, bn_glb_b);

  int x = len -1;
  while(x > 0) {
    x--;
    bn_func2(0);
    if(BN_is_bit_set(var6, x)) {
      bn_cmplx7();
    }
  }

  BN_copy(bn_glb1, bn_glb_c);
  BN_mask_bits(bn_glb1, 128);
  BN_copy(bn_glb7, bn_glb1);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb1, bn_glb6, bn_glb3);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  BN_clear(bn_glb7);
  BN_set_word(bn_glb7, 1);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb7, bn_glb6, bn_glb3);
  BN_copy(bn_glb0, bn_glb1);
  BN_clear(bn_glb7);
  BN_set_word(bn_glb7, 1);
  BN_copy(bn_glb1, bn_glb0);
  BN_clear(bn_glb0);
  bn_func1(var1);
  BN_copy(bn_glb5, bn_glb_b);
  BN_mask_bits(bn_glb5, 128);

  bn_cmplx1(bn_glb0, bn_glb1, bn_glb5, bn_glb6, bn_glb3);

  BN_copy(bn_glb7, bn_glb0);
  BN_copy(bn_glb5, bn_glb_c);
  BN_mask_bits(bn_glb5, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);

  BN_copy(bn_glb5, bn_glb_a);
  BN_mask_bits(bn_glb5, 128);

  bn_cmplx1(bn_glb1, bn_glb1, bn_glb5, bn_glb6, bn_glb3);

  BN_clear(bn_glb5);
  BN_set_word(bn_glb5, 1);

  bn_cmplx1(bn_glb0, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_a, bn_glb0);
  BN_copy(bn_glb1, bn_glb7);

  BN_clear(bn_glb5);
  BN_set_word(bn_glb5, 1);

  bn_cmplx1(bn_glb0, bn_glb1, bn_glb5, bn_glb6, bn_glb3);
  BN_copy(bn_glb_b, bn_glb0);
  BN_free(var48);
}
 
void map57(unsigned char *data) {
  BIGNUM *var38, *var58, *var78, *var98, *varb8, *vard8;
  BN_CTX *t;
  unsigned char tmpdata[256];
  unsigned char res[256];

  t = BN_CTX_new();
  t1 = BN_CTX_new();
  BN_CTX_init(t);

  glb2pow128 = BN_new();
  BN_clear(glb2pow128);
  BN_set_bit(glb2pow128, 128);
  mask128 = BN_new();
  BN_hex2bn(&mask128, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");

  glb2pow64 = BN_new();
  BN_clear(glb2pow64);
  BN_set_bit(glb2pow64, 64);
  mask64 = BN_new();
  BN_hex2bn(&mask64, "FFFFFFFFFFFFFFFF");
  
  bn_glb0=BN_new(); BN_clear(bn_glb0);
  bn_glb1=BN_new(); BN_clear(bn_glb1);
  bn_glb3=BN_new(); BN_clear(bn_glb3);
  bn_glb5=BN_new(); BN_clear(bn_glb5);
  bn_glb6=BN_new(); BN_clear(bn_glb6);
  bn_glb7=BN_new(); BN_clear(bn_glb7);

  bn_glb_a=BN_new(); BN_clear(bn_glb_a);
  bn_glb_b=BN_new(); BN_clear(bn_glb_b);
  bn_glb_c=BN_new(); BN_clear(bn_glb_c);
  bn_glb_d=BN_new(); BN_clear(bn_glb_d);
  bn_glb_e=BN_new(); BN_clear(bn_glb_e);
  bn_glb_f=BN_new(); BN_clear(bn_glb_f);
  bn_glb_g=BN_new(); BN_clear(bn_glb_g);
  bn_glb_h=BN_new(); BN_clear(bn_glb_h);
  bn_glb_i=BN_new(); BN_clear(bn_glb_i);
  bn_glb_j=BN_new(); BN_clear(bn_glb_j);
  bn_glb_k=BN_new(); BN_clear(bn_glb_k);
  bn_glb_l=BN_new(); BN_clear(bn_glb_l);
  bn_glb_m=BN_new(); BN_clear(bn_glb_m);

  var38=BN_new(); BN_clear(var38);
  var58=BN_new(); BN_clear(var58);
  var78=BN_new(); BN_clear(var78);
  var98=BN_new(); BN_clear(var98);
  varb8=BN_new(); BN_clear(varb8);
  vard8=BN_new(); BN_clear(vard8);

  memcpy(tmpdata, data, 0x80);
  RotateBytes(tmpdata, 0x80);
  BN_bin2bn(tmpdata, 16, var78);
  BN_bin2bn(tmpdata+0x10, 16, varb8);
  BN_bin2bn(tmpdata+0x20, 16, var98);
  BN_bin2bn(tmpdata+0x40, 16, vard8);
  BN_bin2bn(tmpdata+0x60, 16, var38);
  BN_bin2bn(tmpdata+0x70, 16, var58);

  bn_cmplx2(varb8, var58, vard8, var38, var78, var98);

  memset(res, 0, 0x80);
  unsigned int *dest = (unsigned int *)res, *src = (unsigned int *)data;
  *dest++ = src[0x03];
  *dest++ = src[0x02];
  *dest++ = src[0x01];
  *dest++ = src[0x00];
  *dest++ = src[0x07];
  *dest++ = src[0x06];
  *dest++ = src[0x05];
  *dest++ = src[0x04];

  memset(tmpdata, 0, 0x20);
  int len = BN_bn2bin(bn_glb_a, tmpdata);
  if(len) {
    RotateBytes(tmpdata, len);
  }
  src = (unsigned int *)tmpdata;
  *dest++ = src[0x03];
  *dest++ = src[0x02];
  *dest++ = src[0x01];
  *dest++ = src[0x00];

  memset(tmpdata, 0, 0x20);
  len = BN_bn2bin(bn_glb_m, tmpdata);
  if(len) {
    RotateBytes(tmpdata, len);
  }
  *dest = src[0x03];
  dest+=4;

  memset(tmpdata, 0, 0x20);
  len = BN_bn2bin(bn_glb_b, tmpdata);
  if(len) {
    RotateBytes(tmpdata, len);
  }
  *dest++ = src[0x03];
  *dest++ = src[0x02];
  *dest++ = src[0x01];
  *dest++ = src[0x00];

  dest+=4;
  src = (unsigned int *)(data+0x60);
  *dest++ = src[0x03];
  *dest++ = src[0x01];
  *dest++ = src[0x01];
  *dest++ = src[0x00];
  *dest++ = src[0x07];
  *dest++ = src[0x06];
  *dest++ = src[0x05];
  *dest++ = src[0x04];

  *(unsigned int *)(data + (8<<2))= *(unsigned int *)(res + (11<<2));
  *(unsigned int *)(data + (9<<2))= *(unsigned int *)(res + (10<<2));
  *(unsigned int *)(data + (10<<2))= *(unsigned int *)(res + (9<<2));
  *(unsigned int *)(data + (11<<2))= *(unsigned int *)(res + (8<<2));
  *(unsigned int *)(data + (12<<2))= *(unsigned int *)(res + (12<<2));
  *(unsigned int *)(data + (13<<2))= *(unsigned int *)(res + (13<<2));
  *(unsigned int *)(data + (14<<2))= *(unsigned int *)(res + (14<<2));
  *(unsigned int *)(data + (15<<2))= *(unsigned int *)(res + (15<<2));
  *(unsigned int *)(data + (16<<2))= *(unsigned int *)(res + (19<<2));
  *(unsigned int *)(data + (17<<2))= *(unsigned int *)(res + (18<<2));
  *(unsigned int *)(data + (18<<2))= *(unsigned int *)(res + (17<<2));
  *(unsigned int *)(data + (19<<2))= *(unsigned int *)(res + (16<<2));
  *(unsigned int *)(data + (20<<2))= *(unsigned int *)(res + (20<<2));
  *(unsigned int *)(data + (21<<2))= *(unsigned int *)(res + (21<<2));
  *(unsigned int *)(data + (22<<2))= *(unsigned int *)(res + (22<<2));
  *(unsigned int *)(data + (23<<2))= *(unsigned int *)(res + (23<<2));

  BN_free(glb2pow128);
  BN_free(mask128);
  BN_free(glb2pow64);
  BN_free(mask64);
  
  BN_free(bn_glb0);
  BN_free(bn_glb1);
  BN_free(bn_glb3);
  BN_free(bn_glb5);
  BN_free(bn_glb6);
  BN_free(bn_glb7);

  BN_free(bn_glb_a);
  BN_free(bn_glb_b);
  BN_free(bn_glb_c);
  BN_free(bn_glb_d);
  BN_free(bn_glb_e);
  BN_free(bn_glb_f);
  BN_free(bn_glb_g);
  BN_free(bn_glb_h);
  BN_free(bn_glb_i);
  BN_free(bn_glb_j);
  BN_free(bn_glb_k);
  BN_free(bn_glb_l);
  BN_free(bn_glb_m);

  BN_free(var38);
  BN_free(var58);
  BN_free(var78);
  BN_free(var98);
  BN_free(varb8);
  BN_free(vard8);

  BN_CTX_free(t);
  BN_CTX_free(t1);
}


////////////////////////////////////////////////////////////////////////////
//  Map3b unveiled (by Jagaer)
///////////////////////////////////////////////////////////////////////////
void map3b(unsigned char *data)
{ 
#ifdef BENCHMARK
	double s[2], s2[2], elapsed;
	int err, err2;
	char ttime[64];
	FILE *f;
	wtime_(s, &err );
#endif
///////////////////////////////////////////////////////////////////////////////

  cBN keymulinv, keybig, ukey, reinput;
  cBN ushift;
  cBN sum, num1, num2;
  cBNctx ctx;
  BN_set_bit(ushift,128);
  unsigned char tmpdat[24];
  RotateBytes(tmpdat,data,24); BN_bin2bn(tmpdat,24,keybig);
  RotateBytes(tmpdat,data+24,16); BN_bin2bn(tmpdat,16,ukey);

  BN_zero(num1);
  BN_sub(keymulinv,num1,ukey);
  BN_set_bit(num1,64);
  BN_mod_inverse(keymulinv,keymulinv,num1,ctx);

  BN_set_word(num1,2);
  BN_set_word(num2,132);
  BN_mod_exp(reinput,num1,num2,ukey,ctx);

  for(int i = 0; i<4; i++) {
    BN_copy(num1,reinput);
    BN_mask_bits(num1,64);
    BN_mul(num1,num1,reinput,ctx);

    BN_mul(num2,num1,keymulinv,ctx);
    BN_mask_bits(num2,64);
    BN_mul(num2,ukey,num2,ctx);
    BN_add(num1,num1,num2);
    BN_rshift(num1,num1,64);

    BN_rshift(num2,reinput,64);
    BN_mul(num2,num2,reinput,ctx);
    BN_add(num1,num2,num1);

    BN_mul(num2,num1,keymulinv,ctx);
    BN_mask_bits(num2,64);
    BN_mul(num2,num2,ukey,ctx);

    BN_add(reinput,num1,num2);
    BN_rshift(reinput,reinput,64);
    if(BN_cmp(reinput,ukey)==1 || BN_cmp(reinput,ushift)>=0)
      BN_sub(reinput,reinput,ukey);
    BN_mask_bits(reinput,128);
    }

  BN_zero(sum);
  for(int i=0; i<3; i++) {	
    BN_copy(num1,keybig);
    BN_mask_bits(num1,64);
    BN_rshift(keybig,keybig,64);
    BN_mul(num1,num1,reinput,ctx);
    BN_add(sum,sum,num1);

    BN_copy(num1,sum);
    BN_mask_bits(num1,64);
    BN_mul(num1,num1,keymulinv,ctx);
    if(i==2) {
      BN_lshift(num2,num1,64);
      BN_add(num2,num2,num1);
      }
    else {
      BN_mask_bits(num1,64);
      BN_mul(num1,num1,ukey,ctx);
      BN_add(sum,sum,num1);
      BN_rshift(sum,sum,64);
      if(BN_cmp(sum, ukey)==1 || BN_cmp(sum,ushift)>=0)
         BN_sub(sum,sum,ukey);
      BN_mask_bits(sum,128);
      }
    }

  //Low bytes 
  BN_rshift(num1,num2,2);
  BN_add(num1,num1,sum);
  BN_rshift(num1,num1,52);
  BN_mask_bits(num1,12);
  memset(data, 0, 16);
  int len=BN_bn2bin(num1,data);
  if(len) RotateBytes(data,len);

  //High bytes
  BN_mask_bits(num2,64);
  BN_mul(num2,num2,ukey,ctx);
  BN_add(num2,num2,sum);
  BN_rshift(num2,num2,64);
  BN_lshift(num2,num2,12);
  BN_mask_bits(num2,64);
  len=BN_bn2bin(num2,data+8);
  if(len) RotateBytes(data+8,len);
////////////////////////////////////////////////////////////////////
#ifdef BENCHMARK
wtime_(s2, &err2 );
//printf("After Map3b = %.0f sec, %.0f microseconds\n",s2[0], s2[1]);
s[0] = s2[0] - s[0] ;
      s[1] = s2[1] - s[1] ;
elapsed = 1.e6*s[0] + s[1]; 
      printf("elapsed time is %.0f microseconds -- %s\n", elapsed,time_stamp(ttime));
elapsed_avg += elapsed;
if (z == 0 ) elapsed_min = elapsed;
if (elapsed > elapsed_max) elapsed_max = elapsed;
if (elapsed < elapsed_min) elapsed_min = elapsed;
z++;
if (z == 20) {
printf("*****Averaged time elapsed 20 samples %.0f microseconds -- %s *****\n",elapsed_avg/20,time_stamp(ttime));
printf("*****Elapsed Time Max %.0f microseconds -- %s\n",elapsed_max,time_stamp(ttime));
printf("*****Elapsed Time Min %.0f microseconds -- %s\n",elapsed_min,time_stamp(ttime));
if ((f = fopen ("bench.txt","a"))!=NULL){
   fprintf(f,"*****Averaged time elapsed 20 samples %.0f microseconds -- %s *****\n",elapsed_avg/20,time_stamp(ttime));
   fprintf(f,"*****Elapsed Time Max %.0f microseconds -- %s\n",elapsed_max,time_stamp(ttime));
   fprintf(f,"*****Elapsed Time Min %.0f microseconds -- %s\n",elapsed_min,time_stamp(ttime));
   fclose(f);
}
elapsed_max=0;
elapsed_min=0;
z=0;
elapsed_avg=0;
}
#endif
}

