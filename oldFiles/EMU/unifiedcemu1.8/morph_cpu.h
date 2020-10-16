/*
 * Softcam plugin to VDR (C++)
 *
 * This code is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * Or, point your browser to http://www.gnu.org/copyleft/gpl.html
 */

#ifndef __MORPH_CPU_H
#define __MORPH_CPU_H

#include "debug.h"

// ----------------------------------------------------------------

class cMap {
public:
  virtual ~cMap() {};
  virtual unsigned char Get(unsigned short ea)=0;
  virtual void Set(unsigned short ea, unsigned char val)=0;
  virtual bool IsFine(void)=0;
};

// ----------------------------------------------------------------

class cMapMem : public cMap {
private:
  unsigned short offset;
  unsigned char *mem;
  int size;
public:
  cMapMem(unsigned short Offset, int Size);
  virtual ~cMapMem();
  virtual unsigned char Get(unsigned short ea);
  virtual void Set(unsigned short ea, unsigned char val);
  virtual bool IsFine(void);
  };

// ----------------------------------------------------------------

class cFileMap;

class cMapRom : public cMap {
private:
  unsigned short offset;
  cFileMap *fm;
  unsigned char *addr;
  int size;
public:
  cMapRom(unsigned short Offset, const char *Filename, int InFileOffset=0);
  virtual ~cMapRom();
  virtual unsigned char Get(unsigned short ea);
  virtual void Set(unsigned short ea, unsigned char val);
  virtual bool IsFine(void);
  };

// ----------------------------------------------------------------

class cMapEeprom : public cMap {
private:
  unsigned short offset;
  cFileMap *fm;
  unsigned char *addr;
  int size, otpSize;
public:
  cMapEeprom(unsigned short Offset, const char *Filename, int OtpSize, int InFileOffset=0);
  virtual ~cMapEeprom();
  virtual unsigned char Get(unsigned short ea);
  virtual void Set(unsigned short ea, unsigned char val);
  virtual bool IsFine(void);
  };

// ----------------------------------------------------------------

#define MAX_BREAKPOINTS 4
#define MAX_MAPPER      8
#define MAX_PAGES       4
#define PAGE_SIZE       32*1024

#define bitset(d,bit) (((d)>>(bit))&1)

class c6805 {
private:
  unsigned short pc, sp, spHi, spLow;
  unsigned short bp[MAX_BREAKPOINTS], numBp;
  unsigned char mapMap[(MAX_PAGES+1)*PAGE_SIZE];
  cMap *mapper[MAX_MAPPER];
  int nextMapper;
  int pageMap[256];
  bool indirect;
#ifdef DEBUG_STAT
  unsigned int stats[256];
#endif
  //
  void InitMapper(void);
  void ClearMapper(void);
  void branch(bool branch);
  inline void tst(unsigned char c);
  inline void push(unsigned char c);
  inline unsigned char pop(void);
  void pushpc(void);
  void poppc(void);
  void pushc(void);
  void popc(void);
  unsigned char add(unsigned char op, unsigned char c);
  unsigned char sub(unsigned char op1, unsigned char op2, unsigned char c);
  unsigned char rollR(unsigned char op, unsigned char c);
  unsigned char rollL(unsigned char op, unsigned char c);
protected:
  unsigned char a, x, y, cr, dr;
  
  unsigned char MapA[2048];	//Map Registry A - this is a worst case size
  unsigned int  MapOperationCount;

  struct CC { unsigned char c, z, n, i, h, v; } cc;
  //
  int Run(int max_count);
  void AddBreakpoint(unsigned short addr);
  void ClearBreakpoints(void);
  bool AddMapper(cMap *map, unsigned short start, int size, unsigned char seg=0);
  void ResetMapper(void);
  unsigned char Get(unsigned short ea) const;
  unsigned char Get(unsigned char seg, unsigned short ea) const;
  void Set(unsigned short ea, unsigned char val);
  void Set(unsigned char seg, unsigned short ea, unsigned char val);
  void GetMem(unsigned short addr, unsigned char *data, int len, unsigned char seg=0) const;
  void SetMem(unsigned short addr, const unsigned char *data, int len, unsigned char seg=0);
  void ForceSet(unsigned short ea, unsigned char val, bool ro);
  void SetSp(unsigned short SpHi, unsigned short SpLow);
  void SetPc(unsigned short addr);
  unsigned short GetPc(void) const { return pc; }
  void PopPc(void) { poppc(); }
  virtual void Stepper(void)=0;
  virtual int MapCall(void)=0;
public:
  c6805(void);
  virtual ~c6805();
  };

#endif
