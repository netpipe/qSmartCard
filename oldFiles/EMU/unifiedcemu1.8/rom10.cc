/*
*  Main function for specific data 
*/

#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "comm.h"
#include "cmd07.h"
#include "misc.h"

#define FLAG0 memory.m [0x50]
#define FLAG1 memory.m [0x51]
#define FLAG2 memory.m [0x52]
#define FLAG3 memory.m [0x53]
#define CYCLEBYTE memory.m [0xc0a0]

int NewRev = 0;

void func_2020 (void)           // Rom10 MAP
{
  uint addr;
  addr = memory.g16 (0x4d);
  char *s = "UNKNOWN";

  switch (A) {
    case 0x02:
      s = "Reg0 = 0";
      MAP_reg0 = 0;
      break;

    case 0x08:
      s = "POWM";
      D_MAP << ba (addr, 64) << endl;
      mpz_import (MAP_input, addr, 64);
      mpz_powm (MAP_output, MAP_input, MAP_exponent, MAP_modulos);
      mpz_export (MAP_output, addr, 64);
      D_MAP << ba (addr, 64) << endl;
      break;

    case 0x11:
      s = "Reg0 = 1";
      MAP_reg0 = 1;
      break;

    case 0x15:
      s = "Modulos";
      D_MAP << ba (addr, 64) << endl;
      mpz_import (MAP_modulos, addr, 64);
      break;

    case 0x27:
      s = "Exponent";
      D_MAP << ba (addr, 64) << endl;
      mpz_import (MAP_exponent, addr, 64);
      break;

    case 0x29:
      A = 0xe0;
      memory [0x120] = A;
      break;

    case 0x2e:
      s = "Exponent 03";
      //mpz_set_str (MAP_exponent, b2s_inv (&memory [0x45], 1), 16);
      mpz_set_ui (MAP_exponent, 3);
      break;

    default:
      cout << "A=" << h8 << (int) A
        << ", Address = " << h16 << addr
        << ", PC = " << h16 << memory.g16 (SP + 3) << " - " << s << endl;
      Debugger ();
      break;
  }
  D_MAP << "A=" << h8 << (int) A
    << ", Addresse = " << h16 << addr
    << ", PC = " << h16 << memory.g16 (SP + 3) << " - " << s << endl;
  PC = ANRTS;
}

void func_908e (void)           // COMPUTE_N1D1
{
  D_MAP << "Compute N1D1 - 908e" << endl;

  D_MAP << ba (0x100, 32) << endl;
  D_MAP << ba (0x120, 32) << endl;

  mpz_import (MAP_a, 0x100, 32);
  mpz_import (MAP_b, 0x120, 32);
  mpz_mul (MAP_c, MAP_a, MAP_b);
  mpz_export (MAP_c, 0xE0, 64);
  D_MAP << ba (0xE0, 64) << endl;

  mpz_sub_ui (MAP_a, MAP_a, 1);
  mpz_sub_ui (MAP_b, MAP_b, 1);
  mpz_mul (MAP_a, MAP_a, MAP_b);
  mpz_mul_ui (MAP_a, MAP_a, 2);
  mpz_add_ui (MAP_a, MAP_a, 1);
  mpz_cdiv_q_ui (MAP_a, MAP_a, 3);
  mpz_export (MAP_a, 0x160, 64);
  D_MAP << ba (0x160, 64) << endl;

  PC = ANRTS;
}



void func_81fb (void)           // WAITMSGLOOP
{
  if (NewRev) {
    char fname[] = "eeprom.xxx.bn10";
    for (int a = 0; a < 3; ++a)
      fname[7 + a] = memory[DataSpacePTR + 5 + a];
    //writeEEPROM (fname);
  }

  if (out.length) {
    ioDebugOutput ();
  if (portdev != "stream") {
    Comm->Write (out.data, out.length);
     }
    out.length = 0;
  }
  if (!(FLAG0 & 0x20)) {
    in.length = Comm->Read (in.data);
    if (in.length) {
      ioDebugInput ();
      GEN_IRQ (0x4010);
      ioStartPacket ();
    }
  }

  CPU__6805_Step ();
}

void func_913d (void)           // CHECKCYCLEBYTE
{
  int o_PC = memory.g16 (SP + 1);
  cout << "CheckCycleByte " << h8 << (int) memory[o_PC]
    << " | CycleByte = " << h8 << (int) CYCLEBYTE << endl;
  CPU__6805_Step ();
}

void func_919a (void)           // WRITEEEPROM
{
  int o_PC = memory.g16 (SP + 1);
  cout << "WriteEEPROM"
    << " | EEP Address = " << h16 << (int) memory.g16 (o_PC)
    << " | RAM Address = " << h8 << (int) memory[o_PC + 2]
    << " | Length = " << h8 << (int) memory[o_PC + 3] << endl;
  cout << "Data = " << bas (memory[o_PC + 2], memory[o_PC + 3] - 1)
    << endl;
  CPU__6805_Step ();
}

void func_9153 (void)           // WRITECYCLEBYTE
{
  cout << "WriteCycleByte " << h8 << (int) X
    << " | Old CycleByte = " << h8 << (int) CYCLEBYTE << endl;
  CPU__6805_Step ();
}

void func_916f (void)           // WRITEMINORVER
{
  cout << "WriteMinorVer" << " | A = " << h8 << (int) A << endl;
  NewRev = 1;
  CPU__6805_Step ();
}

uchar & FAST Rom10MemFunc (int i)
{
  static uchar temp = 0;
  i &= 0xffff;
  if ((i >= 0x10) && (i < 0x40))
  {
    if ((i != 0x26) && (PC != 0xc596))
    {
      cout << "READING " << h8 << i << endl;
      Debugger ();
    }
    temp = i;
    return temp;
  }
  if ((i >= 0x4000) && (i < 0xA000))
    return memory.m[i];
  else if ((i >= 7) && (i < 0x41f))
    return memory.m[i];
  else if ((i >= 0xC000) && (i < 0xE000))
    if (memory[0x0002] & 0x80) {
      static uchar a = 0x01;
      return a;
    } else
      return memory.m[i];
  else if (i == 0x0000) {
    if ((precomp[PC] == CPU__6805_Step) &&
        (precomp[(PC - 1) & 0xffff] == CPU__6805_Step) &&
        (precomp[(PC - 2) & 0xffff] == CPU__6805_Step) &&
        (precomp[(PC - 3) & 0xffff] == CPU__6805_Step)) {
      cout << "Memory 0x0000 Access : PC = " << h16 << (int) PC
        << " : IO = " << h8 << (int) memory.m[i] << endl;
      CPU__6805_Print ();
    }
    return memory.m[i];
  } else if (i == 0x0001) {
    memory.m[i] = 0x13;
    return memory.m[i];
  } else if ((i == 0x0005) || (i == 0x0006)) {
    if (memory.m[0x0007] & 0x82)
      memory.m[i] = random ();
    return memory.m[i];
  } else if ((i >= 0) && (i < 0x41f))
    return memory.m[i];
  else if (precomp[i] == CPU__6805_Step)
    memory.Bad (i);
  return memory.m[0];
};


void func_1c (void){
  int i;
  char tempstr[255],tempstr2[255];
  strcpy(tempstr,"\0");
  for (i=0;i<0x60;i++){
    sprintf(tempstr2,"%02X",memory.g8(0x80 + i));
    strcat(tempstr,tempstr2);
  }
  D_CMD07 << "1c input -\r\n" << tempstr << endl;

  CPU__6805_Step ();
}

void loadsessionkey(void){
	if (sessionkeyfile != 1) return; 
  int i;
  char tempstr[255],tempstr2[4];
	
  FILE * pFile;

  pFile = fopen ( "session.key" , "rt" );
  if (pFile==NULL) {
	  CPU__6805_Step ();
    return;
  }
  fgets (tempstr , 255 , pFile);
  fclose (pFile);
	if (strlen(tempstr) < 32) return;
	tempstr2[2] = '\0';
  for (i=0;i<16;i++){
    tempstr2[0] = tempstr[i * 2];
    tempstr2[1] = tempstr[i * 2 + 1];
    strcat(tempstr,tempstr2);
		memory[0x150 + i] = axtoi(tempstr2);
  }
  strcpy(tempstr,"\0");
  for (i=0;i<16;i++){
    sprintf(tempstr2,"%02X",memory.g8(0x150 + i));
    strcat(tempstr,tempstr2);
  }
  printf("Set Session Key -\r\n%s\r\n",tempstr);

}

void func_cab0 (void){
  int i;
  char tempstr[255],tempstr2[255];
  strcpy(tempstr,"\0");
  for (i=0;i<16;i++){
    sprintf(tempstr2,"%02X",memory.g8(0x150 + i));
    strcat(tempstr,tempstr2);
  }
    D_CMD07 << "Session Key -\r\n" << tempstr << endl;

  CPU__6805_Step ();
}

void func_cc1c (void){
	if (sessionkeyfile != 1) return; 
  int i;
  char tempstr[255],tempstr2[4];

  FILE * pFile;

  pFile = fopen ( "session.key" , "wt" );
  if (pFile==NULL) {
	  CPU__6805_Step ();
    return;
  }
  strcpy(tempstr,"\0");
  for (i=0;i<16;i++){
    sprintf(tempstr2,"%02X",memory.g8(0x150 + i));
    strcat(tempstr,tempstr2);
  }
  fputs (tempstr , pFile);
  fclose (pFile);
	
  CPU__6805_Step ();
}

void func_3b57 (void){
  unsigned char data[0x60];
  int i;
  for (i=0;i<0x60;i++){
    data[i] = memory.g8(0x80 + i);
  }
  D_CMD07 << "<< CMD07" << endl;
  D_CMD07 << "[RX] - $CMD 07 - Entitlement Control Message (ECM)\n\n" << bas(in.data, in.length) << endl;
	ProcessECM(data);

  for (i=0;i<0x60;i++){
    memory[0x80 + i] = data[i];
  }
  CPU__6805_Step ();
}

	
void initROM10 (void)
{
  MemFunc = Rom10MemFunc;

  // Map Stuff
  precomp[0x2020] = func_2020;
  precomp[0x908e] = func_908e;

  // IO Stuff
  precomp[0x4037] = ioReset;
  precomp[0x4512] = ioSendByte;
  precomp[0x81ca] = ioBeforeATR;
  precomp[0x81cd] = ioAfterATR;
  precomp[0x81fb] = func_81fb;

  precomp[0x4053] = ioStartBit;
  precomp[0x405c] = ioStartBit;
  precomp[0x40e5] = ioReceiveBit;
  precomp[0x40bf] = ioParity;
  precomp[0x40c7] = ioParity;
  precomp[0x40cc] = ioReceiveByte;
  precomp[0x4178] = ioOverByte;
  precomp[0x417d] = ioWaitStart;

  // Trap
  precomp[0x9986] = Debugger;

  // Eeprom Revision Stuff
  /*precomp[0x913d] = func_913d;
     precomp[0x9153] = func_9153;
     precomp[0x916f] = func_916f;
     precomp[0x919a] = func_919a; */

  // A21 WAITMSGLOOP
  precomp[0xc153] = func_81fb;



	//MAP 3B/57
  //Nagravision string
  char tempstr[512];
	if (debug_x & DEBUG_CMD07) SetLog(1);
	strcpy(tempstr,"4E61677261566973696F6E20532E412E");
	SetNagraSAIdeaKey(tempstr);
  loadsessionkey();

	precomp[0xca81] = func_3b57;
  precomp[0xcaa4] = func_3b57;
	precomp[0xcc1c] = func_cc1c; 

  precomp[0xc900] = func_1c;
	  precomp[0xcab0] = func_cab0;
		
  memory[0x0001] = 0x13;
  memory[0x0002] = 0x03;
  memory[0x0007] = 0x82;
  ANRTS = 0x400b;

  DataSpacePTR = 0xC080;
  DataSpaceEnd = 0xE000;
}
