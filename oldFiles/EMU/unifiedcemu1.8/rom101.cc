/*
*  Main function for specific data 
*/

#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "comm.h"

// Rom11

#define FLAG0 memory.m [0x50]
#define FLAG1 memory.m [0x51]
#define FLAG2 memory.m [0x52]
#define FLAG3 memory.m [0x53]

void func_2020 (void);          // Use Rom10 MAP
void func_908e (void);          // use Rom10 COMPUTE_N1D1
void func_81fb (void);          // Use Rom10 WAIGMSGLOOP
void donothingfunc (void);
uchar & Rom10MemFunc (int i);

void func_skip3 (void);
void func_skip2 (void);
void func_skip1 (void);

void func_skip3 (void){};
void func_skip2 (void){};
void func_skip1 (void){};

void func_79c0 (void)           // WAITMSGLOOP
{
  if (out.length) {
    ioDebugOutput ();
    Comm->Write (out.data, out.length);
    out.length = 0;
  }
  in.length = Comm->Read (in.data);
  if (in.length) {
    ioDebugInput ();
    GEN_IRQ (0x4010);
    ioStartPacket ();
  }

  CPU__6805_Step ();
}



void initROM101 (void)
{
  MemFunc = Rom10MemFunc;

  precomp[0x4030] = ioReset;
  precomp[0x44d1] = ioSendByte;

  precomp[0x44bb] = ioBeforeATR;
  precomp[0x44cd] = ioAfterATR;

  precomp[0x4155] = ioStartBit;
  precomp[0x4057] = ioStartBit;
  precomp[0x40cd] = ioReceiveBit;
  precomp[0x40b4] = ioParity;
  precomp[0x40ac] = ioParity;
  precomp[0x404f] = ioWaitStart;

  precomp[0x79c0] = func_79c0;

  precomp[0x2020] = func_2020;

/*  precomp[0x5304] = ioStartBit;
  precomp[0x5259] = ioReceiveBit;
  precomp[0x5238] = ioParity;
  precomp[0x5240] = ioParity;
  precomp[0x5245] = ioReceiveByte;
  precomp[0x52e1] = ioWaitStart;

  precomp[0x2020] = func_2020;
  precomp[0x504a] = func_908e;

  // Rom 11
  precomp[0x99fd] = Debugger;
  precomp[0x99eb] = Debugger;
  precomp[0x972a] = Debugger;
  precomp[0x974b] = func_skip3;
  precomp[0x9751] = func_skip2;

  // B89
  precomp[0xc3ce] = func_81fb;
  precomp[0x2028] = donothingfunc;*/

  precomp[0x467a] = Debugger;
  precomp[0x468c] = Debugger;
  precomp[0x5752] = Debugger;

  precomp[0x5716] = func_skip3;
  precomp[0x5732] = func_skip3;
  precomp[0x5739] = func_skip3;
  precomp[0x573c] = func_skip3;
  precomp[0x5745] = func_skip3;

  precomp[0x57ce] = func_skip2;
  precomp[0x57db] = func_skip2;


  for (int a = 0; a < 0x41f; ++a)
    memory.m[a] = 0xff;

  memory[0x0001] = 0x08;
  memory[0x0002] = 0x03;
  memory[0x0007] = 0x82;
  ANRTS = 0x400b;

  DataSpacePTR = 0xC080;
  DataSpaceEnd = 0xE000;
}
