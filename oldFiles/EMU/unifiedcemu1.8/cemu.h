using namespace std;
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <sstream>
#include <gmp.h>

#include <gmpxx.h>

#ifndef DJGPP
#define FAST __attribute__ ((section ("fast")))
#else
#define FAST
#endif

#ifdef _WIN32
#define random rand
#endif

#define h8 setw (2) << hex
#define h16 setw (4) << hex
#define h32 setw (8) << hex
#define h64 setw (16) << hex

#define test_bit(val, bit)  ((val & (1 << bit)) == (1 << bit))

typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;
#ifdef _MSC_VER
typedef __int64 int64;
typedef unsigned __int64 uint64;
#else
typedef long long int64;
typedef unsigned long long uint64;
#endif

#include "debug.h"

void sig_int (int unused);

extern uint camid;
extern uint irdid;
extern uint offsetkey86;
extern uint offsetkey96;

extern uint64 boxkey;
extern uint64 key0;
extern uint64 key1;
extern uint tz;
extern uint zip;
extern uchar blackout[];
extern uint NoSave;
extern string dishfile;
extern string tierfile;
extern volatile uint Break;
extern uint Debugging;
extern uint Debugstat;
extern int EMMLOG;
extern int ghetoroll;
extern int originalghetoroll;
extern int STREAMLOG;
extern int atrstart;
extern int atrreset;
extern int nbprecomp;
extern int checkdelaykey;
extern int sleepqteewait;
extern int chkmsgqtee ;
extern int chkmsgqteecomm ;
extern struct buffer in, out;
//extern ofstream streamlog;
extern string streamlogfile;
extern string emmlogfile;
extern string stf86;
extern string stf96;
//extern string key86name;
//extern string key96name;
extern int bootdisk;
extern char strtofind86[];
extern char strtofind96[];
extern int cmdforkeys;

extern char altstrtofind86[];
extern char altstrtofind96[];
extern uint altoffsetkey86;
extern uint altoffsetkey96;

extern int altcmdforkeys;

extern char buffstrtofind86[];
extern char buffstrtofind96[];
extern uint buffoffsetkey86;
extern uint buffoffsetkey96;

extern int buffcmdforkeys;

extern uint sessionkeyfile;

extern string portdev;
void writeEEPROM (const char *filename);
void sig_usr1 (int unused);
void infokey ();
void infokey905 ();
void infokey906 ();
void outkey(int);
int ascHexToInt(char aChar );
char intToAscHex(int aInt );
void ReloadROM ();
int setUpROM();

