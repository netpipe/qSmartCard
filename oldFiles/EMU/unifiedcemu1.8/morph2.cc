#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <ctype.h>
#include <fstream>
#include <iostream>
#include <iomanip>
#include "debug.h"
#include "common.h"
#ifndef TESTER
#include "data.h"
#include "misc.h"
#include <time.h>
#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "comm.h"
#include "cmd07.h"
#include "logfile.h"
#include "keycmd.h"
#include "keysets.h"
//********************************************************* (10/17/2006) **
//#include "main.h"
//extern class DllClass m_DLLInstance;
//#include "morph.h"
//extern class B1morph B1_morph;
//********************************************************* (10/17/2006) **
#endif



#define SYSTEM_NAGRA         0x1800
#define SYSTEM_NAGRA2        0x1801
#define SYSTEM_NAGRA_BEV     0x1234

#define SYSTEM_NAME_N1       "Nagra"
#define SYSTEM_NAME_N2       "Nagra2"
#define SYSTEM_PRI           -10
#define FILEMAP_DOMAIN       "nagra"

//#define DEBUG_EMU        // debug CardEmu (very verbose!)
//#define DEBUG_EMU_0x80   // if the above is enabled, limit output to range x080-0xc0
//#define DEBUG_STAT     // give some statistics on CardEmu
//#define DEBUG_MAP      // debug file mapping code
//#define DEBUG_NAGRA    	 // debug Nagra crypt code
//#define DEBUG_LOG      // debug Nagra logger code
static bool pc80flag=false;
// -- cMap ---------------------------------------------------------------------

class cMap {
public:
  cMap(void) {};
  virtual ~cMap() {};
  virtual unsigned char Get(unsigned short ea)=0;
  virtual void Set(unsigned short ea, unsigned char val)=0;
  virtual bool IsFine(void)=0;
};

// -- cMapMem ------------------------------------------------------------------

class cMapMem : public cMap {
private:
  int offset;
  unsigned char *mem;
  int size;
public:
  cMapMem(unsigned short Offset, int Size);
  virtual ~cMapMem();
  virtual unsigned char Get(unsigned short ea);
  virtual void Set(unsigned short ea, unsigned char val);
  virtual bool IsFine(void);
  };

cMapMem::cMapMem(unsigned short Offset, int Size)
{
  offset=Offset; size=Size;
  if((mem=(unsigned char *)malloc(size)))
    memset(mem,0,size);
  dn(c_printf("mapmem: new map off=%04X size=%04X\n",offset,size))
}

cMapMem::~cMapMem()
{
  free(mem);
}

bool cMapMem::IsFine(void)
{
  return (mem!=0);
}

unsigned char cMapMem::Get(unsigned short ea)
{
  return (ea>=offset && ea<offset+size) ? mem[ea-offset] : 0;
}

void cMapMem::Set(unsigned short ea, unsigned char val)
{
  if(ea>=offset && ea<offset+size)
    mem[ea-offset]=val;
}

// -- cMapRom ------------------------------------------------------------------

class cMapRom : public cMap {
private:
  unsigned short offset;
  cFileMap *fm;
  unsigned char *addr;
  int size;
public:
  cMapRom(int Offset, const char *Filename);
  virtual ~cMapRom();
  virtual unsigned char Get(unsigned short ea);
  virtual void Set(unsigned short ea, unsigned char val);
  virtual bool IsFine(void);
  };

cMapRom::cMapRom(int Offset, const char *Filename)
{
  offset=Offset; addr=0;
  fm=filemaps.GetFileMap(Filename,FILEMAP_DOMAIN,false);
  if(fm && fm->Map()) {
    addr=fm->Addr();
    size=fm->Size();
    dn(c_printf("maprom: new map off=%04X size=%04X\n",offset,size));
    }
}

cMapRom::~cMapRom()
{
  if(fm) fm->Unmap();
}

bool cMapRom::IsFine(void)
{
  return (addr!=0);
}

unsigned char cMapRom::Get(unsigned short ea)
{
  return (ea-offset >=0 && ea-offset < size) ? addr[ea-offset] : 0;
}

void cMapRom::Set(unsigned short ea, unsigned char val)
{
  if(ea-offset >= 0 && ea-offset < size) de(c_printf("[ROM] "))
  // this is a ROM!
}

// -- cMapEeprom ---------------------------------------------------------------

class cMapEeprom : public cMap {
private:
  unsigned short offset;
  cFileMap *fm;
  unsigned char *addr;
  int size, otpSize;
public:
  cMapEeprom(unsigned short Offset, const char *Filename, int OtpSize);
  virtual ~cMapEeprom();
  virtual unsigned char Get(unsigned short ea);
  virtual void Set(unsigned short ea, unsigned char val);
  virtual bool IsFine(void);
  };

cMapEeprom::cMapEeprom(unsigned short Offset, const char *Filename, int OtpSize)
{
  offset=Offset; otpSize=OtpSize; addr=0;
  fm=filemaps.GetFileMap(Filename,FILEMAP_DOMAIN,true);
  if(fm && fm->Map()) {
    addr=fm->Addr();
    size=fm->Size();
    dn(c_printf("mapeeprom: new map off=%04X size=%04X otp=%04X\n",offset,size,otpSize))
    }
}

cMapEeprom::~cMapEeprom()
{
  if(fm) fm->Unmap();
}

bool cMapEeprom::IsFine(void)
{
  return (addr!=0);
}

unsigned char cMapEeprom::Get(unsigned short ea)
{
  return (ea>=offset && ea<offset+size) ? addr[ea-offset] : 0;
}

void cMapEeprom::Set(unsigned short ea, unsigned char val)
{
  if(ea>=offset && ea<offset+otpSize) {
    if(addr[ea-offset]==0) {
      addr[ea-offset]=val;
      de(c_printf("[OTP-SET] "))
      }
    de(c_printf("[OTP] "))
    }
  if(ea>=offset+otpSize && ea<offset+size) {
    addr[ea-offset]=val;
    de(c_printf("[EEP] "))
    }
}

// -- c6805 --------------------------------------------------------------------

#define MAX_BREAKPOINTS 4
#define MAX_MAPPER      8
#define BASE_SIZE       32*1024
#define SEGMENT_SIZE    32*1024
#define MAX_SEGMENTS    4
#define MEM_SIZE        BASE_SIZE+MAX_SEGMENTS*SEGMENT_SIZE

#define bitset(d,bit) (((d)>>(bit))&1)
#define OLDHILO(ea)      ((Get(ea)<<8)+Get((ea)+1))
#define HILO(ea,s)    ((Get(ea,(s))<<8)+Get(ea+1,(s)))

class c6805 {
private:
  unsigned short pc_m, sp_m, spHi, spLow;
  unsigned short bp[MAX_BREAKPOINTS], numBp;
  unsigned char mapMap[MEM_SIZE];
  cMap *mapper[MAX_MAPPER];
  int nextMapper;
  unsigned char segMap[MAX_SEGMENTS];
  unsigned char segCount;
  bool indirect;
#ifdef DEBUG_STAT
  unsigned int stats[256];
#endif
  //
  void branch(bool branch);
  inline void tst(unsigned char c);
  inline void push_m(unsigned char c);
  inline unsigned char pop_m(void);
  void pushpc(void);
  void poppc(void);
  void pushc(void);
  void popc(void);
  unsigned char add(unsigned char op, unsigned char c);
  unsigned char sub(unsigned char op1, unsigned char op2, unsigned char c);
  unsigned char rollR(unsigned char op, unsigned char c);
  unsigned char rollL(unsigned char op, unsigned char c);
public:
  unsigned int  MapOperationCount;
  unsigned char MapA[2048];	//Map Registry A - this is a worst case size
  unsigned char a_m, cr, dr;
  unsigned short x_m, y_m; //NOTE: there are really 'unsigned char', but defined as short for indexed addressing
  struct CC { unsigned char c, z, n, i, h; } cc;
  //
  int Run(int max_count);
  void AddBreakpoint(unsigned short addr);
  void ClearBreakpoints(void);
  bool AddMapper(cMap *map, unsigned short start, int size, int seg = 0);
  unsigned char Get(unsigned short ea, unsigned char seg = 0) const;
  void Set(unsigned short ea, unsigned char val, unsigned char seg = 0);
  void GetMem(unsigned short addr, unsigned char *data, int len) const;
  void SetMem(unsigned short addr, const unsigned char *data, int len);
  void SetSegMem(unsigned short addr, const unsigned char *data, int len, unsigned char seg);
  void GetSegMem(unsigned short addr, unsigned char *data, int len, unsigned char seg) const;
  void ForceSet(unsigned short ea, unsigned char val, bool ro);
  void SetSp(unsigned short SpHi, unsigned short SpLow);
  void SetPc(unsigned short addr);
  unsigned short GetPc(void) const { return pc_m; }
  void PopPc(void) { poppc(); }
  unsigned char GetSegment(unsigned char seg) const;
  virtual void Stepper(void) {return;}
public:
  c6805(void);
  virtual ~c6805();
  };

c6805::c6805(void) {
	dn(c_printf("c6805::c6805\n"))
  cc.c=0; cc.z=0; cc.n=0; cc.i=0; cc.h=0;
  pc_m=0; a_m=0; x_m=0; y_m=0; dr=0; cr = 0; sp_m=spHi=0x100; spLow=0xC0;
  
  ClearBreakpoints();
  memset(MapA,0,sizeof(MapA));
  memset(mapMap,0,sizeof(mapMap));
  memset(mapper,0,sizeof(mapper));
  mapper[0]=new cMapMem(0,MEM_SIZE);
  nextMapper=1;
  memset(segMap,0,sizeof(segMap));
  segMap[1] = 1;
  segMap[2] = 2;
  segCount=3;
  
#ifdef DEBUG_STAT
  memset(stats,0,sizeof(stats));
#endif
}

c6805::~c6805()
{
#ifdef DEBUG_STAT
  int i, j, sort[256];
  bool done=false;
  for(i=0 ; i<256 ; i++) sort[i]=i;
  for(i=0 ; i<256 && !done ; i++)
    for(j=0 ; j<255 ; j++)
      if(stats[sort[j]]<stats[sort[j+1]]) {
        int x=sort[j];
        sort[j]=sort[j+1];
        sort[j+1]=x;
        done=false;
        }
  printf("6805: opcode statistics\n");
  for(i=0 ; i<256 ; i++)
    if((j=stats[sort[i]])) printf("6805: opcode %02X: %d\n",sort[i],j);
#endif
  for(int i=0; i<MAX_MAPPER; i++) delete mapper[i];
}

bool c6805::AddMapper(cMap *map, unsigned short start, int size, int seg)
{
  unsigned int offset = 0;
  int i;
  for(i = 0; i < segCount;i++) {
    if (segMap[i] == seg) {
      offset = i*SEGMENT_SIZE;
      break;
      }
    }
  if(i == segCount) {
    offset = segCount*SEGMENT_SIZE;
    segMap[segCount++] = seg;
    }
  if(map && map->IsFine()) {
    if(nextMapper<MAX_MAPPER) {
      mapper[nextMapper]=map;
      memset(&mapMap[offset+start],nextMapper,size);
      nextMapper++;
      return true;
      }
    else de(c_printf("6805: too many mappers\n"))
    }
  else de(c_printf("6805: mapper not ready\n"))
  delete map;
  return false;
}

unsigned char c6805::GetSegment(unsigned char seg) const
{
  for(int i = 0; i < segCount; i++)
    if(segMap[i] == seg)
      return i;
  return 0;
}

unsigned char c6805::Get(unsigned short ea, unsigned char seg) const
{
  unsigned int offset = 0;
  if(ea > BASE_SIZE)
    offset = GetSegment(seg)*SEGMENT_SIZE;
  return mapper[mapMap[offset+ea]&0x7f]->Get(ea);
}

void c6805::Set(unsigned short ea, unsigned char val, unsigned char seg)
{
  unsigned char mapId;
  unsigned int offset = 0;
  if(ea > BASE_SIZE)
    offset = GetSegment(seg)*SEGMENT_SIZE;
  mapId=mapMap[offset+ea];
  if(!(mapId&0x80)) mapper[mapId&0x7f]->Set(ea,val);
}

void c6805::ForceSet(unsigned short ea, unsigned char val, bool ro)
{
  mapMap[ea]=0;     		// reset to RAM map
  Set(ea,val);      		// set value
  if(ro) mapMap[ea]|=0x80; 	// protect byte
}

void c6805::SetMem(unsigned short addr, const unsigned char *data, int len)
{
  while(len>0) { Set(addr++,*data++); len--; }
}

void c6805::GetMem(unsigned short addr, unsigned char *data, int len) const
{
  while(len>0) { *data++=Get(addr++); len--; }
}

void c6805::SetSegMem(unsigned short addr, const unsigned char *data, int len, unsigned char seg)
{
  while(len>0) { Set(addr++,*data++,seg); len--; }
}

void c6805::GetSegMem(unsigned short addr, unsigned char *data, int len, unsigned char seg) const
{
  while(len>0) { *data++=Get(addr++,seg); len--; }
}
void c6805::SetSp(unsigned short SpHi, unsigned short SpLow)
{
  spHi =sp_m=SpHi;
  spLow   =SpLow;
}

void c6805::SetPc(unsigned short addr)
{
  pc_m=addr;
}

void c6805::AddBreakpoint(unsigned short addr)
{
  if(numBp<MAX_BREAKPOINTS) {
    bp[numBp++]=addr;
    de(c_printf("6805: setting breakpoint at 0x%04X\n",addr))
    }
  else de(c_printf("6805: too many breakpoints\n"))
}

void c6805::ClearBreakpoints(void)
{
  numBp=0;
  memset(bp,0,sizeof(bp));
}

#ifdef DEBUG_EMU
static const char * const ops[] = {
//         0x00    0x01    0x02    0x03    0x04    0x05    0x06    0x07    0x08    0x09    0x0a    0x0b    0x0c    0x0d    0x0e    0x0f
/* 0x00 */ "BRSET","BRCLR","BRSET","BRCLR","BRSET","BRCLR","BRSET","BRCLR","BRSET","BRCLR","BRSET","BRCLR","BRSET","BRCLR","BRSET","BRCLR",
/* 0x10 */ "BSET", "BCLR", "BSET", "BCLR", "BSET", "BCLR", "BSET", "BCLR", "BSET", "BCLR", "BSET", "BCLR", "BSET", "BCLR", "BSET", "BCLR", 
/* 0x20 */ "BRA",  "BRN",  "BHI",  "BLS",  "BCC",  "BCS",  "BNE",  "BEQ",  "BHCC", "BHCS", "BPL",  "BMI",  "BMC",  "BMS",  "BIL",  "BIH",
/* 0x30 */ "NEG",  "op31", "op32", "COM",  "LSR",  "op35", "ROR",  "ASR",  "ASL",  "ROL",  "DEC",  "op3b", "INC",  "TST",  "SWAP", "CLR",  
/* 0x40 */ "NEG",  "op41", "MUL",  "COM",  "LSR",  "op45", "ROR",  "ASR",  "ASL",  "ROL",  "DEC",  "op4b", "INC",  "TST",  "SWAP", "CLR",  
/* 0x50 */ "NEG",  "op51", "MUL",  "COM",  "LSR",  "op55", "ROR",  "ASR",  "ASL",  "ROL",  "DEC",  "op5b", "INC",  "TST",  "SWAP", "CLR",  
/* 0x60 */ "NEG",  "op61", "op62", "COM",  "LSR",  "op65", "ROR",  "ASR",  "ASL",  "ROL",  "DEC",  "op6b", "INC",  "TST",  "SWAP", "CLR",  
/* 0x70 */ "NEG",  "LDP",  "op72", "COM",  "LSR",  "LDP",  "ROR",  "ASR",  "ASL",  "ROL",  "DEC",  "TAD",  "INC",  "TST",  "SWAP", "CLR",  
/* 0x80 */ "RTI",  "RTS",  "op82", "SWI",  "POPA", "POP%c","POPC", "RTSP", "PUSHA","PUSH%c","PUSHC","TDA", "TCA",  "JSRP", "STOP", "WAIT", 
/* 0x90 */ "pre90","pre91","pre92","T%2$c%1$c","T%cS","TAS","TS%c","TA%c", "CLC",  "SEC",  "CLI",  "SEI",  "RSP",  "NOP",  "TSA",  "T%cA", 
/* 0xa0 */ "SUB",  "CMP",  "SBC",  "CP%c", "AND",  "BIT",  "LDA",  "opa7", "EOR",  "ADC",  "ORA",  "ADD",  "PUSHP", "BSR",  "LD%c","POPP", 
/* 0xb0 */ "SUB",  "CMP",  "SBC",  "CP%c", "AND",  "BIT",  "LDA",  "STA",  "EOR",  "ADC",  "ORA",  "ADD",  "JMP",  "JSR",  "LD%c", "ST%c", 
/* 0xc0 */ "SUB",  "CMP",  "SBC",  "CP%c", "AND",  "BIT",  "LDA",  "STA",  "EOR",  "ADC",  "ORA",  "ADD",  "JMP",  "JSR",  "LD%c", "ST%c", 
/* 0xd0 */ "SUB",  "CMP",  "SBC",  "CP%c", "AND",  "BIT",  "LDA",  "STA",  "EOR",  "Asubstituted format tagsDC",  "ORA",  "ADD",  "JMP",  "JSR",  "LD%c", "ST%c", 
/* 0xe0 */ "SUB",  "CMP",  "SBC",  "CP%c", "AND",  "BIT",  "LDA",  "STA",  "EOR",  "ADC",  "ORA",  "ADD",  "JMP",  "JSR",  "LD%c", "ST%c", 
/* 0xf0 */ "SUB",  "CMP",  "SBC",  "CP%c", "AND",  "BIT",  "LDA",  "STA",  "EOR",  "ADC",  "ORA",  "ADD",  "JMP",  "JSR",  "LD%c", "ST%c", 
  };
#endif

// Flags:
// 1 - read operant
// 2 - write operant
// 3 - read/write
// 4 - use CSR
static const char opFlags[] = {
//         00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
/* 0x00 */  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
/* 0x10 */  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
/* 0x20 */  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/* 0x30 */  3, 0, 0, 3, 3, 0, 3, 3, 3, 3, 3, 0, 3, 1, 3, 2, 
/* 0x40 */  3, 0, 0, 3, 3, 0, 3, 3, 3, 3, 3, 0, 3, 1, 3, 2, 
/* 0x50 */  3, 0, 0, 3, 3, 0, 3, 3, 3, 3, 3, 0, 3, 1, 3, 2, 
/* 0x60 */  3, 0, 0, 3, 3, 0, 3, 3, 3, 3, 3, 0, 3, 1, 3, 2, 
/* 0x70 */  3, 1, 0, 3, 3, 0, 3, 3, 3, 3, 3, 0, 3, 1, 3, 2, 
/* 0x80 */  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/* 0x90 */  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
/* 0xa0 */  1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0,
/* 0xb0 */  1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 0, 0, 1, 2,
/* 0xc0 */  5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 0, 0, 5, 6,
/* 0xd0 */  5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 0, 0, 5, 6,
/* 0xe0 */  5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 0, 0, 5, 6,
/* 0xf0 */  5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 0, 0, 5, 6,
  };

int c6805::Run(int max_count)
{
// returns:
// 0 - breakpoint
// 1 - stack overflow
// 2 - instruction counter exeeded
// 3 - unsupported instruction

#ifdef DEBUG_EMU_0x80
  pc80flag=false;
#endif
  int count=0;
  de(c_printf("6805: cr:-pc- aa xx yy dr -sp- HINZC -mem@pc- -mem@sp-\n"))
  while (1) {
#ifdef DEBUG_EMU_0x80
    {
    bool flag=(pc_m>=0x80 && pc_m<0xC0);
    if(pc80flag && !flag) de(c_printf("6805: [...]\n"));
    pc80flag=flag;
    }
#endif
    de(c_printf("6805: %02X:%04X %02X %02X %02X %02X %04X %c%c%c%c%c %02X%02X%02X%02X %02X%02X%02X%02X ",
               cr,pc_m,a_m,x_m,y_m,dr,sp_m,
               cc.h?'H':'.',cc.i?'I':'.',cc.n?'N':'.',cc.z?'Z':'.',cc.c?'C':'.',
               Get(pc_m,cr),Get(pc_m+1,cr),Get(pc_m+2,cr),Get(pc_m+3,cr),Get(sp_m+1),Get(sp_m+2),Get(sp_m+3),Get(sp_m+4)))
    if(sp_m<spLow) {
      de(c_printf("stack overflow\n"))
      return 1;
      }
    if(++count>=max_count) {
      de(c_printf("max. instruction counter exceeded\n"))
      return 2;
      }

    Stepper();
    unsigned short *ex=&x_m;
    unsigned char seg = dr;
    bool paged=false;
    indirect=false;
    unsigned char ins=Get(pc_m++,cr);
#ifdef DEBUG_EMU
    char xs='X';
#endif
 
    // check pre-byte (ST7 extention)
    switch(ins) {
      case 0x31: // use Paged mode (or SP)
        ins=Get(pc_m++,cr);
        switch(ins) {
          case 0x22 ... 0x27: printf("WARN: V-flag not yet calculated "); break;
          case 0x75:
          case 0x8D:
          case 0xC0 ... 0xCB:
          case 0xCE ... 0xCF:
          case 0xD0 ... 0xDB:
          case 0xDE ... 0xDF: paged=true; indirect=true; break;
          case 0xE0 ... 0xEB:
          case 0xEE ... 0xEF: ex=&sp_m; de(xs='S'); break;
          }
        break;
      case 0x32: // use Paged mode Y offset or (or indirect SP)
        ins=Get(pc_m++,cr);
        switch(ins) {
          case 0x22 ... 0x27: printf("WARN: V-flag not yet calculated "); indirect=true; break;
          case 0xC3:
          case 0xCE ... 0xCF:
          case 0xD0 ... 0xDB:
          //case 0xDE ... 0xDF: paged=true; indirect=true; ex=&y; idx=*ex; de(xs='Y') de(xi='Y') break;
	      case 0xDE ... 0xDF: paged=true; indirect=true; break;
          case 0xE0 ... 0xEB:
          case 0xEE ... 0xEF: indirect=true; ex=&sp_m; de(xs='S'); break;
          }
        break;
      case 0x91: // use Y register with indirect addr mode
        indirect=true;
        // fall through
      case 0x90: // use Y register
        ex=&y_m; de(xs='Y')
        ins=Get(pc_m++,cr);
        break;
      case 0x92: // use indirect addr mode
        indirect=true;
        ins=Get(pc_m++,cr);
        break;
      }
    unsigned char use_dsr = opFlags[ins] & 0x04;

#ifdef DEBUG_EMU
#ifdef DEBUG_EMU_0x80
    if(pc80flag)
#endif
      {
      char str[8];
#ifndef DJGPP
      snprintf(str,sizeof(str),ops[ins],xs,xs^1);
#else
      sprintf(str,ops[ins],xs,xs^1);
#endif
      de(c_printf("%-5s ",str));
      }
#endif

    // address decoding
    unsigned short ea=0;
    switch(ins>>4) {
      case 0x2:			// no or special address mode
      case 0x8:
      case 0x9:
        break;
      case 0xA:			// immediate
        de(c_printf("#%02X ",Get(pc_m, cr)))
        ea=pc_m++; break;
      case 0x3:			// short
      case 0xB:
		ea=Get(pc_m++, cr);
		if (ea==5) 
			//Special Attribute bit
			ea = 5;
		else {
			if(!indirect) {		// short direct
			  }
			else {			// short indirect
			  de(c_printf("[%02X] -> ",ea))
              ea = Get(ea, use_dsr ? dr : cr);
			}
		}
        de(c_printf("%02X ",ea))
        break;
      case 0xC:			// long
        if(!indirect) {		// long direct
          ea=HILO(pc_m, cr); pc_m+=2;
          }
        else {			// long indirect
          if(paged) {
            ea=HILO(pc_m, cr); pc_m+=2;
            de(c_printf("[%02X] -> ",ea))
            seg = Get(ea, use_dsr ? dr : cr);
            ea++;
          } else {
            ea=Get(pc_m++, cr);
            de(c_printf("[%02X] -> ",ea))
            }
          ea = HILO(ea, use_dsr ? dr : cr);
          }
        de(c_printf("%04X ",ea))
        break;
      case 0xD:			// long indexed
        if(!indirect) {		// long direct indexed
          ea=HILO(pc_m, cr); pc_m+=2;
          de(c_printf("(%04X",ea))
          }
        else {			// long indirect indexed
          if(paged) {
            ea=HILO(pc_m, cr); pc_m+=2;
            de(c_printf("([%02X]",ea))
            seg = Get(ea++, use_dsr ? dr : cr);
          } else {
            ea=Get(pc_m++, cr);
            de(c_printf("([%02X]",ea))
            }
          ea = HILO(ea, use_dsr ? dr : cr);
          de(c_printf(",%c) -> (%04X",xs,ea))
          }
        ea+=*ex;
        de(c_printf(",%c) -> %04X ",xs,ea))
        break;
      case 0x6:			// short indexed
      case 0xE:
        ea=Get(pc_m++,cr);
        if(!indirect) {		// short direct indexed
          de(c_printf("(%02X",ea))
          }
        else {			// short indirect indexed
          de(c_printf("([%02X]",ea))
          ea = Get(ea, use_dsr ? dr : cr);
          de(c_printf(",%c) -> (%02X",xs,ea))
          }
        ea+=*ex;
        de(c_printf(",%c) -> %04X ",xs,ea))
        break;
      case 0x7:			// indexed
      case 0xF:
        ea=*ex;
        de(c_printf("(%c) -> %02X ",xs,ea))
        break;
      case 0x4:			// inherent A
        de(c_printf("A "))
        break;
      case 0x5:			// inherent X/Y
        de(c_printf("%c ",xs))
        break;
      case 0x0:			// bit
      case 0x1:
        ea=Get(pc_m++,cr);
        if(!indirect) {
          de(c_printf("%02X",ea))
          }
        else {
          de(c_printf("[%02X]",ea))
          ea = Get(ea, use_dsr ? dr : cr);
          indirect=false; // don't use indirect mode in case this is a bit branch
          }
        break;
      }

    // read operant
    unsigned char flags=opFlags[ins], op=0;
    if(flags & 1) {
      switch(ins>>4) {
        case 0x2:			// no or special address mode
        case 0x8:
        case 0x9:
          break;
        case 0xA:			// immediate
        case 0x3:			// short
        case 0xB:
        case 0xC:			// long
        case 0xD:			// long indexed
        case 0x6:			// short indexed
        case 0xE:
        case 0x7:			// indexed
        case 0xF:
        case 0x0:			// bit
        case 0x1:
		  //if register 5 bit 7 is set
		  if (Get(0x00,0x05)& 0x40) {
			  //Get Start and end of codespace from bin
			  unsigned short start = Get(0,0x30C0);
			  unsigned short end =  Get(0,0x30C1);
			  if ( ((ea>>8) >=start) && ((ea>>8)<=end))
				  //its in the dataspace - return 0
				  op = 0x00;
			  else
				  //its in the codespace return 1
				  op = 0x01;
		  }
		  else
			  op= Get(ea, use_dsr ? seg : cr); 
		  break;
        case 0x4:			// inherent A
          op=a_m; break;
        case 0x5:			// inherent X/Y
          op=*ex; break;
        }
      }

    // command decoding
#ifdef DEBUG_STAT
    stats[ins]++;
#endif
    switch(ins) {
      case 0xA6: // LDA
      case 0xB6:
      case 0xC6:
      case 0xD6:
      case 0xE6:
      case 0xF6:
        a_m=op; tst(op); break;
      case 0xAE: // LDX
      case 0xBE:
      case 0xCE:
      case 0xDE:
      case 0xEE:
      case 0xFE:
        *ex=op; tst(op); break;
      case 0xB7: // STA
      case 0xC7:
      case 0xD7:
      case 0xE7:
      case 0xF7:
        op=a_m; tst(op); break;
      case 0xBF: // STX
      case 0xCF:
      case 0xDF:
      case 0xEF:
      case 0xFF:
        op=*ex; tst(op); break;
      case 0x97: // TAX
        *ex=a_m; break;
      case 0x9F: // TXA
        a_m=*ex; break;
      case 0x93: // TYX (ST7)
        if(ex==&x_m) *ex=y_m; else *ex=x_m; break;
      case 0x3D: // TST
      case 0x4D:
      case 0x5D:
      case 0x6D:
      case 0x7D:
        tst(op); break;
      case 0x3F: // CLR
      case 0x4F:
      case 0x5F:
      case 0x6F:
      case 0x7F:
        op=0; tst(0); break;
      case 0x3C: // INC
      case 0x4C:
      case 0x5C:
      case 0x6C:
      case 0x7C:
        op++; tst(op); break;
      case 0x3A: // DEC
      case 0x4A:
      case 0x5A:
      case 0x6A:
      case 0x7A:
        op--; tst(op); break;
      case 0x33: // COM
      case 0x43:
      case 0x53:
      case 0x63:
      case 0x73:
        op=~op; cc.c=1; tst(op); break;
      case 0x30: // NEG
      case 0x40:
      case 0x50:
      case 0x60:
      case 0x70:
        op=~op+1; if(!op) cc.c=0; tst(op); break;
      case 0x42: // MUL
      case 0x52:
        {
        unsigned short res=*ex * a_m;
        *ex=(res>>8); a_m=res&0xff; cc.c=0; cc.h=0;
        break;
        }
      case 0xA9: // ADC
      case 0xB9:
      case 0xC9:
      case 0xD9:
      case 0xE9:
      case 0xF9:
        a_m=add(op,cc.c); break;
      case 0xAB: // ADD
      case 0xBB:
      case 0xCB:
      case 0xDB:
      case 0xEB:
      case 0xFB:
        a_m=add(op,0); break;
      case 0xA2: // SBC
      case 0xB2:
      case 0xC2:
      case 0xD2:
      case 0xE2:
      case 0xF2:
        a_m=sub(a_m,op,cc.c); break;
      case 0xA0: // SUB
      case 0xB0:
      case 0xC0:
      case 0xD0:
      case 0xE0:
      case 0xF0:
        a_m=sub(a_m,op,0); break;
      case 0xA1: // CMP
      case 0xB1:
      case 0xC1:
      case 0xD1:
      case 0xE1:
      case 0xF1:
        sub(a_m,op,0); break;
      case 0xA3: // CPX
      case 0xB3:
      case 0xC3:
      case 0xD3:
      case 0xE3:
      case 0xF3:
        sub(*ex,op,0); break;
      case 0xA4: // AND
      case 0xB4:
      case 0xC4:
      case 0xD4:
      case 0xE4:
      case 0xF4:
        a_m &= op; tst(a_m); break;
      case 0xAA: // ORA
      case 0xBA:
      case 0xCA:
      case 0xDA:
      case 0xEA:
      case 0xFA:
        a_m |= op; tst(a_m); break;
      case 0xA8: // EOR
      case 0xB8:
      case 0xC8:
      case 0xD8:
      case 0xE8:
      case 0xF8:
        a_m ^= op; tst(a_m); break;
      case 0xA5: // BIT
      case 0xB5:
      case 0xC5:
      case 0xD5:
      case 0xE5:
      case 0xF5:
        tst(a_m & op); break;
      case 0x38: // ASL
      case 0x48:
      case 0x58:
      case 0x68:
      case 0x78:
        op=rollL(op,0); break;
      case 0x39: // ROL
      case 0x49:
      case 0x59:
      case 0x69:
      case 0x79:
        op=rollL(op,cc.c); break;
      case 0x37: // ASR
      case 0x47:
      case 0x57:
      case 0x67:
      case 0x77:
        op=rollR(op,bitset(op,7)); break;
      case 0x34: // LSR
      case 0x44:
      case 0x54:
      case 0x64:
      case 0x74:
        op=rollR(op,0); break;
      case 0x36: // ROR
      case 0x46:
      case 0x56:
      case 0x66:
      case 0x76:
        op=rollR(op,cc.c); break;
      case 0x3E: // SWAP (ST7)
      case 0x4E:
      case 0x5E:
      case 0x6E:
      case 0x7E:
        op=(op<<4)|(op>>4); tst(op); break;
	  case 0x00:
	  case 0x01:
	  case 0x02:
	  case 0x03:
	  case 0x04:
	  case 0x05:
	  case 0x06:
	  case 0x07:
	  case 0x08:
	  case 0x09:
	  case 0x0a:
	  case 0x0b:
	  case 0x0c:
	  case 0x0d:
	  case 0x0e:
      case 0x0F: // BRSET BRCLR
        {
        int bit=(ins&0x0F)>>1;
        de(c_printf(",#%x,",bit))
        cc.c=bitset(op,bit);
        branch((ins&0x01) ? cc.c:!cc.c);
        break;
        }
	  case 0x10:
	  case 0x11:
	  case 0x12:
	  case 0x13:
	  case 0x14:
	  case 0x15:
	  case 0x16:
	  case 0x17:
	  case 0x18:
	  case 0x19:
	  case 0x1a:
	  case 0x1b:
	  case 0x1c:
	  case 0x1d:
	  case 0x1e:
	  case 0x1F: // BSET BCLR
        {
        int bit=(ins&0x0F)>>1;
        de(c_printf(",#%x",bit))
        if(ins&0x01) op &= ~(1<<bit);
        else         op |=  (1<<bit);
        break;
        }
      case 0x20: // BRA
        branch(true); break;
      case 0x21: // BRN
        branch(false); break;
      case 0x22: // BHI
        branch(!cc.c && !cc.z); break;
      case 0x23: // BLS
        branch( cc.c ||  cc.z); break;
      case 0x24: // BCC BHS
        branch(!cc.c); break;
      case 0x25: // BCS BLO
        branch( cc.c); break;
      case 0x26: // BNE
        branch(!cc.z); break;
      case 0x27: // BEQ
        branch( cc.z); break;
      case 0x28: // BHCC
        branch(!cc.h); break;
      case 0x29: // BHCS
        branch( cc.h); break;
      case 0x2A: // BPL
        branch(!cc.n); break;
      case 0x2B: // BMI
        branch( cc.n); break;
      case 0x2C: // BMC
        branch(!cc.i); break;
      case 0x2D: // BMS
        branch( cc.i); break;
      case 0xBC: // JMP
      case 0xCC:
      case 0xDC:
      case 0xEC:
      case 0xFC:
        pc_m=ea; break;
      case 0xAD: // BSR
        pushpc(); pc_m--; branch(true); break;
      case 0xBD: // JSR
      case 0xCD:
      case 0xDD:
      case 0xED:
      case 0xFD:
        pushpc(); pc_m=ea; break;
      case 0x71: // LDP
        dr = Get(pc_m++,cr); break;
      case 0x72: // LDP
        dr = Get(Get(pc_m++,cr)); break;
      case 0x75: // LDP
        ea=HILO(pc_m, cr);
        if(paged) {
          seg = Get(ea,dr);
          ea++;
          }
        dr = Get(ea, seg);
        break;
      case 0x7B: // TAD
        dr = a_m; break;
      case 0x8B: // TDA
        a_m = dr; break;
      case 0x8C: // TCA
        a_m = cr; break;
      case 0xAC: // PUSHP
        push_m(dr); pc_m--; break;
      case 0xAF: // POPP
        dr = pop_m(); pc_m--; break;
      case 0x87: // RTSP
        cr = pop_m(); poppc(); break;
      case 0x8D: //JSRP
		D_B1 << "\n\nInside JSRP Block\n\n";
        if(paged) {
          ea=OLDHILO(pc_m); pc_m+=2;
		  //original code
          //seg=Get(ea++, dr);
          //ea=HILO(ea, dr);
        } else {
          //original code
          //seg=Get(pc_m++, cr);
          //ea=HILO(pc_m, cr); pc_m+=2;
		  //new code
		  ea=pc_m; pc_m+=3;
          }
		seg=Get(ea++);
		ea=OLDHILO(ea);
		if ( (ea==0xA822) && (seg==0x00)) {
			D_B1 << "\n\nInside Map Call, ea: " << ea << " seg: " << seg << " a_m: " << a_m;
			//Map Call
			switch (a_m) {
				case 0x02:
					D_B1 << "\n\nInside Map02";
					//Map #2 - this is just a setup Map
					MapOperationCount = Get(0x48,0x00)*8;	//Register 48 Contains the number of 8 byte sections the map will operate on
					D_B1 << "\n\nMapOperationCount: " << MapOperationCount;
					break;
				case 0x0f:
					{
						D_B1 << "\n\nInside Map0F";
						//Map F - this swaps the value of map rom A with the value specified in $44 and $45
						unsigned char *pTemp = (unsigned char *)malloc(MapOperationCount);
						unsigned short addr=0;	
						addr = Get(0x45,0x00);
						D_B1 << "\n\nAddr: " << addr;
						//addr = addr<<8 + Get(0x00,0x45);
						GetSegMem(addr, pTemp, MapOperationCount, 0); //addr, data, offset, Stores the value to pTemp
						SetSegMem(addr, MapA, MapOperationCount, 0); //Swap the Map Register A Value with the value @ $44, $45
						memcpy(MapA, pTemp, MapOperationCount);  //Replace the Map Regsiter Value with Temp;
					}
					break;
				default:
					printf("\n\nUnrecognized map call: %d\n\n", a_m);
					pushpc(); push_m(cr); cr=seg; pc_m=ea;
					break;
			}
		}
		else {
			pushpc(); push_m(cr); cr=seg; pc_m=ea;
		}
        break;
      case 0x81: // RTS
        poppc(); break;
      case 0x83: // SWI
        pushpc(); push_m(x_m); push_m(a_m); pushc();
        cc.i=1; pc_m=HILO(0x1ffc, cr); break;
      case 0x80: // RTI
        popc(); a_m=pop_m(); x_m=pop_m(); poppc(); break;
      case 0x9C: // RSP
        sp_m=spHi; break;
      case 0x96: // TSX
        *ex=sp_m; break;
      case 0x94: // TXS (ST7)
        sp_m=*ex; break;
      case 0x9E: // TSA
        a_m=sp_m; break;
      case 0x95: // TAS (ST7)
        sp_m=a_m; break;
      case 0x84: // POPA (ST7)
        a_m=pop_m(); break;
      case 0x85: // POPX (ST7)
        *ex=pop_m(); break;
      case 0x86: // POPC (ST7)
        popc(); break;
      case 0x88: // PUSHA (ST7)
        push_m(a_m); break;
      case 0x89: // PUSHX (ST7)
        push_m(*ex); break;
      case 0x8A: // PUSHC (ST7)
        pushc(); break;
      case 0x98: // CLC
        cc.c=0; break;
      case 0x99: // SEC
        cc.c=1; break;
      case 0x9A: // CLI
        cc.i=0; break;
      case 0x9B: // SEI
        cc.i=1; break;
      case 0x9D: // NOP
        break;
      case 0x90: // pre-bytes
      case 0x91:
      case 0x92:
        de(c_printf("pre-byte %02X in command decoding\n",ins))
        return 3;
      default:
        de(c_printf("unsupported instruction 0x%02X\n",ins))
        return 3;
      }

    // write operant
    if(flags & 2) {
      switch(ins>>4) {
        case 0x2:			// no or special address mode
        case 0x8:
        case 0x9:
          break;
        case 0xA:			// immediate
        case 0x3:			// short
        case 0xB:
        case 0xC:			// long
        case 0xD:			// long indexed
        case 0x6:			// short indexed
        case 0xE:
        case 0x7:			// indexed
        case 0xF:
        case 0x0:			// bit
        case 0x1:
          Set(ea,op,use_dsr ? seg : cr); break;
        case 0x4:			// inherent A
          a_m=op; break;
        case 0x5:			// inherent X/Y
          *ex=op; break;
        }
      }
    de(c_printf("\n"))

    for(int i=numBp-1 ; i>=0 ; i--) {
      if(bp[i]==pc_m) {
        de(c_printf("6805: breakpoint at %04X\n",pc_m))
	de(c_printf("6805: {next EMM_CMD}\n\n"))
        return 0;
        }
      }
    }
}

void c6805::branch(bool branch)
{
#ifdef DEBUG_EMU
  {
  unsigned char off=Get(pc_m);
  if(indirect) {
    de(c_printf("[%02X] -> ",off))
    off=Get(off);
    }
  unsigned short npc=pc_m+off+1;
  if(off&0x80) npc-=0x100; // gcc fixup. take care of sign
  de(c_printf("%04X ",npc))
  if(branch) de(c_printf("(taken) "))
  }
#endif
  pc_m++;
  if(branch) {
    unsigned char offset=Get(pc_m-1);
    if(indirect) offset=Get(offset);
    pc_m+=offset;
    if(offset&0x80) pc_m-=0x100; // gcc fixup. take care of sign
    }
}

void c6805::push_m(unsigned char c)
{
  Set(sp_m--,c);
}

unsigned char c6805::pop_m(void)
{
  return Get(++sp_m);
}

void c6805::pushpc(void)
{
  push_m(pc_m & 0xff);
  push_m(pc_m >> 8);
}

void c6805::poppc(void)
{
  pc_m=(pop_m()<<8) | pop_m();
}

void c6805::pushc(void)
{
  unsigned char c=0xE0+(cc.h?16:0)+(cc.i?8:0)+(cc.n?4:0)+(cc.z?2:0)+(cc.c?1:0);
  push_m(c);
}

void c6805::popc(void)
{
  unsigned char c=pop_m();
  cc.h=(c&16) ? 1:0;
  cc.i=(c& 8) ? 1:0;
  cc.n=(c& 4) ? 1:0;
  cc.z=(c& 2) ? 1:0;
  cc.c=(c& 1) ? 1:0;
}

void c6805::tst(unsigned char c)
{
  cc.z=!c;
  cc.n=bitset(c,7);
}

unsigned char c6805::add(unsigned char op, unsigned char c)
{
  unsigned short res_half=(a_m&0x0f) + (op&0x0f) + c;
  unsigned short res=(unsigned short)a_m + (unsigned short)op + (unsigned short)c;
  cc.h=res_half > 0x0f;
  cc.c=res > 0xff;
  res&=0xff;
  tst(res);
  return res;
}

unsigned char c6805::sub(unsigned char op1, unsigned char op2, unsigned char c)
{
  short res=(short)op1 - (short)op2 - (short)c;
  cc.c=res < 0;
  res&=0xff;
  tst(res);
  return res;
}

unsigned char c6805::rollR(unsigned char op, unsigned char c)
{
  cc.c=bitset(op,0);
  op >>= 1;
  op |= c << 7;
  tst(op);
  return op;
}

unsigned char c6805::rollL(unsigned char op, unsigned char c)
{
  cc.c=bitset(op,7);
  op <<= 1;
  op |= c;
  tst(op);
  return op;
}

// -- cEmu ---------------------------------------------------------------------

#define MAX_COUNT 1000000

class cEmu : public c6805 {
protected:
  int romNr, id;
  char *romName, *romExtName, *eepromName;
  //
  int InitStart, InitEnd;
  int EmmStart, EmmEnd, EmmKey0, EmmKey1;
  int FindKeyStart, FindKeyEnd;
  int MapAddr;
  int Rc1H, Rc1L;
  int EnsIrdChk, Cmd83Chk;
  int SoftInt, StackHigh;
  //
  bool AddRom(unsigned short addr, unsigned short size, const char *name);
  bool AddEeprom(unsigned short addr, unsigned short size, unsigned short otpSize, const char *name);
  //
  virtual bool InitSetup(void) { return true; }
  virtual bool UpdateSetup(const unsigned char *emm) { return true; }
  virtual bool MathMapHandler(void);
public:
  cEmu(void);
  virtual ~cEmu();
  bool Init(int RomNr, int Id);
  bool GetOpKeys(const unsigned char *Emm, unsigned char *id, unsigned char *key0, unsigned char *key1);
  bool GetPkKeys(const unsigned char *select, unsigned char *pkset);
  bool Matches(int RomNr, int Id);
  };

cEmu::cEmu(void)
{
  romName=romExtName=eepromName=0;
}

cEmu::~cEmu()
{
  free(romName);
  free(romExtName);
  free(eepromName);
}

bool cEmu::AddRom(unsigned short addr, unsigned short size, const char *name)
{
  cMap *map=new cMapRom(addr,name);
  return AddMapper(map,addr,size);
}

bool cEmu::AddEeprom(unsigned short addr, unsigned short size, unsigned short otpSize, const char *name)
{
  cMap *map=new cMapEeprom(addr,name,otpSize);
  return AddMapper(map,addr,size);
}

bool cEmu::Matches(int RomNr, int Id)
{
  return (romNr==RomNr && id==Id);
}

bool cEmu::Init(int RomNr, int Id)
{
  romNr=RomNr; id=Id;
  //sprintf(&romName,"ROM%d.bin",romNr);
  //sprintf(&romExtName,"ROM%dext.bin",romNr);
  //sprintf(&eepromName,"eep%i_%02x.bin",romNr,(id&0xff00)>>8);
  if(InitSetup()) {
    ForceSet(EnsIrdChk, 0x81,true);
    ForceSet(Cmd83Chk+0,0x98,true);
    ForceSet(Cmd83Chk+1,0x9d,true);
    if(SoftInt) {
      Set(0x1ffc,SoftInt>>8);
      Set(0x1ffd,SoftInt&0xff);
      }
    SetSp(StackHigh,0);
    SetPc(InitStart);
    ClearBreakpoints();
    AddBreakpoint(InitEnd);
    if(!Run(MAX_COUNT)) return true;
    }
  return false;
}
/*
bool cEmu::GetOpKeys(const unsigned char *Emm, unsigned char *id, unsigned char *key0, unsigned char *key1)
{
  int keys=0;
  if(UpdateSetup(Emm)) {
    SetMem(0x0080,&Emm[0],64);
    SetMem(0x00F8,&Emm[1],2);
    SetPc(EmmStart);
    ClearBreakpoints();
    AddBreakpoint(EmmEnd);
    AddBreakpoint(MapAddr);
    AddBreakpoint(EmmKey0);
    AddBreakpoint(EmmKey1);
    while(!Run(MAX_COUNT)) {
      unsigned short pc=GetPc();
      if(pc==EmmKey0) {
        GetMem(0x82,key0,8);
        keys++;
        }
      if(pc==EmmKey1) {
        GetMem(0x82,key1,8);
        keys++;
        }
      if(pc==MapAddr) {
        if(!MathMapHandler()) break;
        PopPc(); // remove return address from stack
        }
      if(pc==EmmEnd) {
        GetMem(0x00F8,id,2);
        break;
        }
      }
    }
  return (keys==2);
}

bool cEmu::GetPkKeys(const unsigned char *select, unsigned char *pkset)
{
  Set(0x0081,select[2]<<7);
  SetMem(0x00F8,select,3);
  SetPc(FindKeyStart);
  ClearBreakpoints();
  AddBreakpoint(FindKeyEnd);
  while(!Run(MAX_COUNT)) {
    unsigned short pc=GetPc();
    if(pc==FindKeyEnd) {
      if(!cc.c) {
        de(c_printf("Updating PK keys\n"))
        unsigned short loc=(Get(Rc1H)<<8)+Get(Rc1L);
        for(int i=0; i<45; i+=15) GetMem(loc+4+i,pkset+i,15);
        return true;
        }
      else {
        de(c_printf("Updating PK keys failed. Used a correct EEPROM image for provider %04x ?\n",((select[0]<<8)|select[1])))
        break;
        }
      }
    }
  return false;
}
*/
bool cEmu::MathMapHandler(void)
{
  de(c_printf("Unsupported math call $%02X in ROM %d, please report\n",a_m,romNr))
  return false;
}

int ProcessB1(int id, unsigned char *buffer, int len, int pos)
{
  static c6805 *emu[3];
  static int started[3] = {0, 0, 0};
  cMapRom *rom, *rom1, *rom2;
  cMapRom *eeprom1, *eeprom2;
  char romName[]="ROM102.bin";
  char eepromName[20];
  int res;
  int retvalue = 0;
  switch(id) {
    case 0x0101:
    case 0x0001:
#ifndef DJGPP
      sprintf(eepromName,"EEP01_102.bin");
#else
      sprintf(eepromName,"EEP1_102.bin");
#endif
      id = 0;
      break;
    case 0x0801:
    case 0x0901:
#ifndef DJGPP
      sprintf(eepromName,"EEP08_102.bin");
#else
      sprintf(eepromName,"EEP8_102.bin");
#endif
      id = 1;
      break;
    default:
      printf("ID: %04X\n", id);
#ifndef DJGPP
      sprintf(eepromName,"EEP%02X_102.bin", 0xff&(id >>8));
#else
      sprintf(eepromName,"EEP%X_102.bin", 0xff&(id >>8));
#endif      
      id = 2;
      break;
    }
  if (! started[id]) {
    emu[id] = new c6805();

    //UROM(0x4000-0x7fff)+ROM00(0x8000-0xffff)
    rom = new cMapRom(0x4000, romName);
    if(! rom->IsFine()) {
      printf("Could not load %s\n", romName);
      retvalue = 6;
      return retvalue;
      }
    emu[id]->AddMapper(rom, 0x4000, 0xC000, 0x00);
    //ROM01(0x8000-0xffff)
    rom1 = new cMapRom(0x8000 - 0xC000, romName);
    emu[id]->AddMapper(rom1, 0x8000, 0x8000, 0x01);
    //ROM02(0x8000-0xbfff)
    rom2 = new cMapRom(0x8000 - 0x14000, romName);
    emu[id]->AddMapper(rom2, 0x8000, 0x4000, 0x02);
    //EEPROM(0x3000-0x37ff)
    eeprom1 = new cMapRom(0x3000, eepromName);
    if(! eeprom1->IsFine()) {
      printf("Could not load %s\n", eepromName);
      retvalue = 7;
      return retvalue;
      }
    emu[id]->AddMapper(eeprom1, 0x3000, 0x0800, 0x00);
    //EEPROM(0x8000-0xbfff)
    eeprom2 = new cMapRom(0x8000 - 0x800, eepromName);
    emu[id]->AddMapper(eeprom2, 0x8000, 0x4000, 0x80);
    emu[id]->AddBreakpoint(0x0000);
    emu[id]->AddBreakpoint(0x9569);
    started[id] = 1;
  }
  d(c_printf("Original B1:\n"));
  d(HexDump(buffer, len));
  emu[id]->SetSp(0x0FFF,0xFF0);
  emu[id]->SetMem(0x80, buffer, len);
  emu[id]->SetPc(0x80+pos+1);
  res=emu[id]->Run(1000);
  // returns:
  // 0 - breakpoint
  // 1 - stack overflow
  // 2 - instruction counter exeeded
  // 3 - unsupported instruction
  if (res > 0) retvalue = res;

  if(emu[id]->GetPc() == 0x0000) {
    printf("Emulator Exit Status - B1 execution failed\n");
    retvalue = 8;
    return retvalue;
    }
  emu[id]->GetMem(0x80, buffer, len);
  d(c_printf("Morphed B1: Run exit:%d - A:%d\n", res, emu[id]->a_m));
  d(HexDump(buffer, len));
 // if (retvalue > 0 && retvalue <=3) return retvalue; 
 // else return (emu[id]->a_m > retvalue ? emu[id]->a_m : retvalue);
 return retvalue;
}
