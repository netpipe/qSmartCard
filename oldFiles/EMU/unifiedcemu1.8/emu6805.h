#include "logfile.h"
extern int MAP_reg0;
extern int MAP_reg1;
extern int ANRTS;
//extern class B1morph B1_morph;
int ProcessB1(int id, unsigned char *buffer, int len, int pos);

void runCode (void);
void initEMU (void);
void initEMU2 (void);
void initEMU3 (void);

void mpz_import (mpz_t m, int addr, int size);
void mpz_export (mpz_t m, int addr, int size);
extern mpz_t MAP_modulos, MAP_exponent, MAP_input, MAP_output,
  MAP_a, MAP_b, MAP_c;

void ioStartPacket (void);
void ioReset (void);
void ioStartBit (void);
void ioReceiveBit (void);
void ioParity (void);
void ioReceiveByte (void);
void ioOverByte (void);
void ioWaitStart (void);
void ioSendByte (void);
void ioBeforeATR (void);
void ioAfterATR (void);
void ioDebugInput (void);
void ioDebugOutput (void);
void decryptfnc (void);
void decryptall (void);
void decryptfnc07 (void);
void decryptkeysfunc (void);
void process_b1_decEmm(char * b1_decEmm);
void log_b1(char *before, char *after);

void func_debug_on (void);
void func_debug_off (void);
void initROM3 (void);
void initROM10 (void);
void initROM11 (void);
void initROM101 (void);
void ReloadROM (void);

void setEMMKeys(void);

extern int DataSpacePTR;
extern int DataSpaceEnd;

//EMM Key Related
/*extern char D_0901[193];
extern char N_0901[193];
extern char EMMG_0901[193];

extern char EMMG_0801[193];
extern char N_0801[193];
extern char D_0801[193];

extern char EMMG_0101[193];
extern char N_0101[193];
extern char D_0101[193];

extern char EMMG_0001[193];
extern char N_0001[193];
extern char D_0001[193];
*/
extern char b1sig[10];

extern int emmProvider;
//extern int index;
char *ShowTime( char *ttime );
//char* ShowDate(void);
char *datestring( char *date );

