#ifndef ___MORPH2_H
#define ___MORPH2_H

#include "morph_cpu.h"
#include "misc.h"
#include "common.h"

class cN2Emu : protected c6805 {
private:
  bool initDone;
protected:
  bool Init(int id, int romv);
  virtual void Stepper(void) {}
public:
  cN2Emu(void);
  virtual ~cN2Emu() {}
  virtual int ProcessB1(int id, unsigned char *data, int len, int pos);
  virtual int MapCall();
  };


cN2Emu::cN2Emu(void)
{
  initDone=false;
}

bool cN2Emu::Init(int id, int romv)
{
  int provid=0;

  if(id == 0x0001 || id == 0x0101) provid = 0x0101;
  else if (id == 0x0801 || id == 0x0901) provid = 0x0801;

  if(!initDone) {
    ResetMapper();
    char buff[256];
#ifndef DJGPP
    snprintf(buff,sizeof(buff),"ROM%d.bin",romv);
#else
    sprintf(buff,"ROM%d.bin",romv);
#endif
    // UROM  0x00:0x4000-0x7fff
    if(!AddMapper(new cMapRom(0x4000,buff,0x00000),0x4000,0x4000,0x00)) {
      printf("Check your directory for ROM102.bin.....missing or corrupted!\n");
      return false;
    }
    // ROM00 0x00:0x8000-0xffff
    if(!AddMapper(new cMapRom(0x8000,buff,0x04000),0x8000,0x8000,0x00)) return false;
    // ROM01 0x01:0x8000-0xffff
    if(!AddMapper(new cMapRom(0x8000,buff,0x0C000),0x8000,0x8000,0x01)) return false;
    // ROM02 0x02:0x8000-0xbfff
    if(!AddMapper(new cMapRom(0x8000,buff,0x14000),0x8000,0x4000,0x02)) return false;

#ifndef DJGPP
      snprintf(buff,sizeof(buff),"EEP%02X_%d.bin",(provid>>8)&0xFF,romv);
#else
      sprintf(buff,"EEP%X_%d.bin",(provid>>8)&0xFF,romv);
#endif
    // Eeprom00 0x00:0x3000-0x37ff OTP 0x80
    if(!AddMapper(new cMapRom(0x3000,buff,0x0000),0x3000,0x0800,0x00)) {
	printf("Check your directory for %s .....missing or corrupted!\n",buff);
	return false;
    }
    // Eeprom80 0x80:0x8000-0xbfff
    if(!AddMapper(new cMapRom(0x8000,buff,0x0800),0x8000,0x4000,0x80)) return false;
    initDone=true;
    }
  return true;
}


int cN2Emu::ProcessB1(int id, unsigned char *data, int len, int pos)
{
  if(Init(id,102)) {
    d(c_printf("Original B1:\n"));
    d(HexDump(data, len));
    SetMem(0x80,data,len);
    SetPc(0x80+pos);
    SetSp(0x0FFF,0x0FF0);
    ClearBreakpoints();
    AddBreakpoint(0x0000);
    AddBreakpoint(0x9569);
    if(!Run(1000) && GetPc()==0x9569) {
      GetMem(0x80,data,len);
      d(c_printf("Morphed B1: Run exit: - A:%d\n", a));
      d(HexDump(data, len));
      return max((int)a,6);
      }
    }
  return -1;
}

int cN2Emu::MapCall()
{
   int retVal = 0;
   switch (a) {
    case 0x02:
     //Map #2 - this is just a setup Map
     MapOperationCount = Get(0x00,0x48)*8;	//Register 48 Contains the number of 8 byte sections the map will operate on
     break;
    case 0x0f: {
	 //Map F - this swaps the value of map rom A with the value specified in $44 and $45
	 unsigned char *pTemp = (unsigned char *)malloc(MapOperationCount);
	 unsigned short addr=0;	
	 addr = Get(0x00,0x45);
	 //addr = addr<<8 + Get(0x00,0x45);
	 GetMem(addr, pTemp, MapOperationCount, 0);
	 SetMem(addr, MapA, MapOperationCount, 0); //Swap the Map Register A Value with the value @ $44, $45
	 memcpy(MapA, pTemp, MapOperationCount);  //Replace the Map Regsiter Value with Temp;
	 free(pTemp);
	}
	break;
	default:
	 retVal = -1;
	 break;
	}
   return retVal;
}
#endif
