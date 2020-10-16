/* 
* 6805 Emulator from anonymous take on zackyfiles
*/

#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "keycmd.h"
/*-----------------------------------------------------------------------------------------------------*/
/*  Registre du CPU 6805 */
uchar A;                        /* Accumulator A */
uchar X;                        /* Index Register */
uchar Y;
_CCR CCR;                       /* Condition Code Register */
uint SP;                        /* Stack Pointer */
uint PC;                        /* Program Counter */

int OPMOD;

uchar *_XY;
#define XY (*_XY)

static instructionPointer instructionTable[memonicsTableSize][4];
static instructionText instructionTableT[memonicsTableSize][4];

Memory memory;
int topStack;
uchar IRQ;

#ifndef FAST_CEMU
uint backtrace[0x100];
uint backtraceI = 0;
#endif

int RomVer = 0;

/*-----------------------------------------------------------------------------------------------------*/

void CPU__6805_Print ()
{
  cout << h16 << PC << ": ";
  (*instructionTableT[memory.m[PC]][OPMOD]) (cout);
  cout << "\t"
    << "SP=" << h16 << (int) SP
    << ", A=" << h8 << (int) A
    << ", X=" << h8 << (int) X
    << ", Y=" << h8 << (int) Y
    << ", CCR=" << h8 << (int) CCR.get ()
    << ", [PC]=" << h8 << (int) memory.m[PC]
    << ", Stack = ";
  for (int a = SP + 1; a <= topStack; ++a)
    cout << h8 << (int) memory[a] << " ";
  cout << endl;
#ifndef FAST_CEMU
  for (int a = 0; a < 0x100; ++a)
    cout << h16 << backtrace[(backtraceI - a - 1) & 0xff] << "    ";
  cout << endl;
#endif
}


void FAST CPU__6805_Step ()
{

  uchar opcode = memory[PC];    /*  Instruction */
  
#ifndef FAST_CEMU
  backtrace[backtraceI++] = PC;
  backtraceI &= 0xff;
  D_6805 << "PC=" << h16 << (int) PC
    << ", SP=" << h16 << (int) SP
    << ", A=" << h8 << (int) A
    << ", X=" << h8 << (int) X
    << ", CCR=" << h8 << (int) CCR.get () << ", [PC]=" << h8 << (int) memory.m[PC]
    << ", OP=" << h8 << (int) memory.m[PC + 1] << endl;
    << (*instructionTableT[opcode][OPMOD]) ();
#endif

  (*instructionTable[opcode][OPMOD]) ();
}

void FAST CPU__Execute ()
{
  while (!Break) {
  if(!Debugstat) keycmd();
  for (int a = 0; a <= nbprecomp; ++a)
    {
      precomp[PC] ();
 
      }

  }

}

void CPU__6805_Reset ()
{
  PC = 0x4000;                  /* Reset the PC of 6805 */
  if (RomVer == 3)
    topStack = 0x7f;
  if (RomVer == 10)
    topStack = 0x3ff;
  if (RomVer == 11)
    topStack = 0x3ff;
  if (RomVer == 101)
    topStack = 0x3ff;
  SP = topStack;
  A = 0;
  X = 0;
  Y = 0;
  CCR.set (0);
  _XY = &X;
  OPMOD = 0;
}

/*-----------------------------------------------------------------------------------------------------*/
void CPU_IllegalInstruction (void)
{
  Debugger ();
}

void CPU_T_IllegalInstruction (ostream &o)
{
  o << "UNK";
}

/*-----------------------------------------------------------------------------------------------------*/

class SetInstruction
{
public:
  SetInstruction (uint num, instructionPointer i0, instructionPointer i1, instructionPointer i2, instructionPointer i3,
                            instructionText t0, instructionText t1, instructionText t2, instructionText t3)
  {
    instructionTable [num] [0] = i0;
    instructionTable [num] [1] = i1;
    instructionTable [num] [2] = i2;
    instructionTable [num] [3] = i3;
    instructionTableT [num] [0] = t0;
    instructionTableT [num] [1] = t1;
    instructionTableT [num] [2] = t2;
    instructionTableT [num] [3] = t3;
  }
};

class SetupInstructions
{
public:
  SetupInstructions ()
  {
    for (uint a = 0; a < 0x100; ++ a)
      SetInstruction I (a, CPU_IllegalInstruction, CPU_IllegalInstruction, CPU_IllegalInstruction, CPU_IllegalInstruction,
                        CPU_T_IllegalInstruction, CPU_T_IllegalInstruction, CPU_T_IllegalInstruction, CPU_T_IllegalInstruction);
  }
} _SetupInstructions_;

#define SET_INSTRUCTION(NUM,I,I0,I1,I2,I3) \
SetInstruction I##_constructor (NUM, CPU_##I##_##I0, CPU_##I##_##I1, CPU_##I##_##I2, CPU_##I##_##I3, \
                                     CPU_T_##I##_##I0, CPU_T_##I##_##I1, CPU_T_##I##_##I2, CPU_T_##I##_##I3)

#define INSTRUCTION_INH(NAME,NUM) \
void FAST CPU_INH_##NAME##_00 (void) { ++ PC; CPU_##NAME (); } \
void CPU_T_INH_##NAME##_00 (ostream &o) { o << # NAME << "\t" << "\t"; } \
SET_INSTRUCTION (NUM, INH_##NAME, 00, 00, 00, 00);

#define INSTRUCTION_INHA(NAME,NUM) \
void FAST CPU_INHA_##NAME##_00 (void) { ++ PC; CPU_##NAME (A, -1); } \
void CPU_T_INHA_##NAME##_00 (ostream &o) { o << # NAME << "\t" << "A\t"; } \
SET_INSTRUCTION (NUM, INHA_##NAME, 00, 00, 00, 00);

#define INSTRUCTION_INHX(NAME,NUM) \
void FAST CPU_INHX_##NAME##_00 (void) { ++ PC; CPU_##NAME (XY, -1); } \
void CPU_T_INHX_##NAME##_00 (ostream &o) { o << # NAME << "\t" << (_XY == &X ? "X\t" : "Y\t"); } \
SET_INSTRUCTION (NUM, INHX_##NAME, 00, 00, 00, 00);

#define INSTRUCTION_IMM(NAME,NUM) \
void FAST CPU_IMM_##NAME##_00 (void) { ++ PC; int z = PC ++; CPU_##NAME (memory [z], memory [z]); } \
void CPU_T_IMM_##NAME##_00 (ostream &o) { o << # NAME << "\t" << h8 << (uint) memory [PC + 1] << "\t"; } \
SET_INSTRUCTION (NUM, IMM_##NAME, 00, 00, 00, 00);

#define INSTRUCTION_REL(NAME,NUM) \
void FAST CPU_REL_##NAME##_00 (void) { ++ PC; int z = PC ++; CPU_##NAME (*((char *) &(memory [z])), memory [z]); } \
void CPU_T_REL_##NAME##_00 (ostream &o) { o << # NAME << "\t" << h16 << (PC + (char) memory [PC + 1] + 2) << "\t"; } \
SET_INSTRUCTION (NUM, REL_##NAME, 00, 00, 00, 00);

#define INSTRUCTION_IX(NAME,NUM) \
void FAST CPU_IX_##NAME##_00 (void) { ++ PC; int z = X; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX_##NAME##_90 (void) { ++ PC; int z = Y; CPU_##NAME (memory [z], z); } \
void CPU_T_IX_##NAME##_00 (ostream &o) { o << # NAME << "\t" << "[X]\t"; } \
void CPU_T_IX_##NAME##_90 (ostream &o) { o << # NAME << "\t" << "[Y]\t"; } \
SET_INSTRUCTION (NUM, IX_##NAME, 00, 90, 90, 00);

#define INSTRUCTION_IX1(NAME,NUM) \
void FAST CPU_IX1_##NAME##_00 (void) { ++ PC; int z = memory [PC ++] + X; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX1_##NAME##_90 (void) { ++ PC; int z = memory [PC ++] + Y; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX1_##NAME##_91 (void) { ++ PC; int z = memory [memory [PC ++]] + Y; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX1_##NAME##_92 (void) { ++ PC; int z = memory [memory [PC ++]] + X; CPU_##NAME (memory [z], z); } \
void CPU_T_IX1_##NAME##_00 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[" << h8 << z << "+X]\t"; } \
void CPU_T_IX1_##NAME##_90 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[" << h8 << z << "+Y]\t"; } \
void CPU_T_IX1_##NAME##_91 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[[" << h8 << z << "]+Y]\t"; } \
void CPU_T_IX1_##NAME##_92 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[[" << h8 << z << "]+X]\t"; } \
SET_INSTRUCTION (NUM, IX1_##NAME, 00, 90, 91, 92);

#define INSTRUCTION_IX2(NAME,NUM) \
void FAST CPU_IX2_##NAME##_00 (void) { ++ PC; int z = memory.g16 (PC ++) + X; PC ++; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX2_##NAME##_90 (void) { ++ PC; int z = memory.g16 (PC ++) + Y; PC ++; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX2_##NAME##_91 (void) { ++ PC; int z = memory.g16 (memory [PC ++]) + Y; CPU_##NAME (memory [z], z); } \
void FAST CPU_IX2_##NAME##_92 (void) { ++ PC; int z = memory.g16 (memory [PC ++]) + X; CPU_##NAME (memory [z], z); } \
void CPU_T_IX2_##NAME##_00 (ostream &o) { int z = memory.g16 (PC + 1); o << # NAME << "\t" << "[" << h16 << z << "+X]"; } \
void CPU_T_IX2_##NAME##_90 (ostream &o) { int z = memory.g16 (PC + 1); o << # NAME << "\t" << "[" << h16 << z << "+Y]"; } \
void CPU_T_IX2_##NAME##_91 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[[" << h8 << z << "].w+Y]"; } \
void CPU_T_IX2_##NAME##_92 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[[" << h8 << z << "].w+X]"; } \
SET_INSTRUCTION (NUM, IX2_##NAME, 00, 90, 91, 92);

#define INSTRUCTION_EXT(NAME,NUM) \
void FAST CPU_EXT_##NAME##_00 (void) { ++ PC; int z = memory.g16 (PC ++); PC ++; CPU_##NAME (memory [z], z); } \
void FAST CPU_EXT_##NAME##_91 (void) { ++ PC; int z = memory.g16 (memory [PC ++]); CPU_##NAME (memory [z], z); } \
void CPU_T_EXT_##NAME##_00 (ostream &o) { int z = memory.g16 (PC + 1); o << # NAME << "\t" << "[" << h16 << z << "]\t"; } \
void CPU_T_EXT_##NAME##_91 (ostream &o) { int z = memory.m [PC + 1]; o << # NAME << "\t" << "[[" << h8 << z << "].w]\t"; } \
SET_INSTRUCTION (NUM, EXT_##NAME, 00, 00, 91, 91);

#define INSTRUCTION_DIR(NAME,NUM) \
void FAST CPU_DIR_##NAME##_00 (void) { ++ PC; int z = memory [PC ++]; CPU_##NAME (memory [z], z); } \
void FAST CPU_DIR_##NAME##_91 (void) { ++ PC; int z = memory [memory [PC ++]]; CPU_##NAME (memory [z], z); } \
void CPU_T_DIR_##NAME##_00 (ostream &o) { int z = memory [PC + 1]; o << # NAME << "\t" << "[" << h8 << z << "]\t"; } \
void CPU_T_DIR_##NAME##_91 (ostream &o) { int z = memory [PC + 1]; o << # NAME << "\t" << "[[" << h8 << z << "]]\t"; } \
SET_INSTRUCTION (NUM, DIR_##NAME, 00, 00, 91, 91);

#define INSTRUCTION_BTB(NAME,NUM) \
void FAST CPU_BTB_##NAME##_00 (void) { ++ PC; uchar z1 = memory [PC ++]; uchar z2 = memory [PC ++]; CPU_##NAME (memory [z1], z2); } \
void CPU_T_BTB_##NAME##_00 (ostream &o) { int z1 = memory [PC + 1]; int z2 = (char) memory [PC + 2]; \
  o << # NAME << "\t" << "[" << h8 << z1 << "]" \
    << ", " << h16 << (PC + z2 + 3); } \
SET_INSTRUCTION (NUM, BTB_##NAME, 00, 00, 00, 00);



void inline CPU_OP90 (void)
{
  _XY = &Y;
  OPMOD = 1;
  CPU__6805_Step ();
  OPMOD = 0;
  _XY = &X;
}

INSTRUCTION_INH (OP90, 0x90);

     void inline CPU_OP91 (void)
{
  OPMOD = 2;
  CPU__6805_Step ();
  OPMOD = 0;
}

INSTRUCTION_INH (OP91, 0x91);

     void inline CPU_OP92 (void)
{
  OPMOD = 3;
  CPU__6805_Step ();
  OPMOD = 0;
}

INSTRUCTION_INH (OP92, 0x92);

#define CPU_BRSET(BIT) \
void inline CPU_BRSET##BIT (uchar &OP1, char OP2) \
{ \
  CCR.C = OP1 & (1 << BIT); \
  if (CCR.C) \
    PC += OP2; \
} \
INSTRUCTION_BTB (BRSET##BIT, 0x00 + 2 * BIT);

#define CPU_BRCLR(BIT) \
void inline CPU_BRCLR##BIT (uchar &OP1, char OP2) \
{ \
  CCR.C = OP1 & (1 << BIT); \
  if (!CCR.C) \
    PC += OP2; \
} \
INSTRUCTION_BTB (BRCLR##BIT,0x01 + 2 * BIT);

#define CPU_BSET(BIT) \
void inline CPU_BSET##BIT (uchar &OP, int _OP) \
{ \
  OP |= (1 << BIT); \
} \
INSTRUCTION_DIR (BSET##BIT,0x10 + 2 * BIT);

#define CPU_BCLR(BIT) \
void inline CPU_BCLR##BIT (uchar &OP, int _OP) \
{ \
  OP &= ~(1 << BIT); \
} \
INSTRUCTION_DIR (BCLR##BIT,0x11 + 2 * BIT);

CPU_BRSET (0);
CPU_BRSET (1);
CPU_BRSET (2);
CPU_BRSET (3);
CPU_BRSET (4);
CPU_BRSET (5);
CPU_BRSET (6);
CPU_BRSET (7);

CPU_BRCLR (0);
CPU_BRCLR (1);
CPU_BRCLR (2);
CPU_BRCLR (3);
CPU_BRCLR (4);
CPU_BRCLR (5);
CPU_BRCLR (6);
CPU_BRCLR (7);

CPU_BSET (0);
CPU_BSET (1);
CPU_BSET (2);
CPU_BSET (3);
CPU_BSET (4);
CPU_BSET (5);
CPU_BSET (6);
CPU_BSET (7);

CPU_BCLR (0);
CPU_BCLR (1);
CPU_BCLR (2);
CPU_BCLR (3);
CPU_BCLR (4);
CPU_BCLR (5);
CPU_BCLR (6);
CPU_BCLR (7);


void inline CPU_BRA (char &OP, int _OP)
{
  PC += OP;
}

INSTRUCTION_REL (BRA, 0x20);

void inline CPU_BRN (char &OP, int _OP)
{
}

INSTRUCTION_REL (BRN, 0x21);

void inline CPU_BHI (char &OP, int _OP)
{
  if (!CCR.C && !CCR.Z)
    PC += OP;
}

INSTRUCTION_REL (BHI, 0x22);

void inline CPU_BLS (char &OP, int _OP)
{
  if (CCR.C || CCR.Z)
    PC += OP;
}

INSTRUCTION_REL (BLS, 0x23);

void inline CPU_BCC (char &OP, int _OP)
{
  if (!CCR.C)
    PC += OP;
}

INSTRUCTION_REL (BCC, 0x24);

void inline CPU_BCS (char &OP, int _OP)
{
  if (CCR.C)
    PC += OP;
}

INSTRUCTION_REL (BCS, 0x25);

void inline CPU_BNE (char &OP, int _OP)
{
  if (!CCR.Z)
    PC += OP;
}

INSTRUCTION_REL (BNE, 0x26);

void inline CPU_BEQ (char &OP, int _OP)
{
  if (CCR.Z)
    PC += OP;
}

INSTRUCTION_REL (BEQ, 0x27);

void inline CPU_BHCC (char &OP, int _OP)
{
  if (!CCR.H)
    PC += OP;
}

INSTRUCTION_REL (BHCC, 0x28);

void inline CPU_BHCS (char &OP, int _OP)
{
  if (CCR.H)
    PC += OP;
}

INSTRUCTION_REL (BHCS, 0x29);

void inline CPU_BPL (char &OP, int _OP)
{
  if (!CCR.N)
    PC += OP;
}

INSTRUCTION_REL (BPL, 0x2a);

void inline CPU_BMI (char &OP, int _OP)
{
  if (CCR.N)
    PC += OP;
}

INSTRUCTION_REL (BMI, 0x2b);

void inline CPU_BMC (char &OP, int _OP)
{
  if (!CCR.I)
    PC += OP;
}

INSTRUCTION_REL (BMC, 0x2c);

void inline CPU_BMS (char &OP, int _OP)
{
  if (CCR.I)
    PC += OP;
}

INSTRUCTION_REL (BMS, 0x2d);

void inline CPU_BIL (char &OP, int _OP)
{
  if (IRQ)
    PC += OP;
}

INSTRUCTION_REL (BIL, 0x2e);

void inline CPU_BIH (char &OP, int _OP)
{
  if (!IRQ)
    PC += OP;
}

INSTRUCTION_REL (BIH, 0x2f);


static inline void ponflags (uchar m)
{
  CCR.Z = !m;
  CCR.N = m & 0x80;
}



void inline CPU_NEG (uchar & OP, int _OP)
{
  ponflags (OP = -OP);
  CCR.C = OP;
}

INSTRUCTION_DIR (NEG, 0x30);
INSTRUCTION_INHA (NEG, 0x40);
INSTRUCTION_INHX (NEG, 0x50);
INSTRUCTION_IX1 (NEG, 0x60);
INSTRUCTION_IX (NEG, 0x70);

void inline CPU_MUL (uchar & OP, int _OP)
{
  uint p;

  p = uint (A) * uint (XY);
  XY = uchar (p >> 8);
  A = uchar (p);
  CCR.H = 0;
  CCR.C = 0;
}

INSTRUCTION_INHA (MUL, 0x42);
INSTRUCTION_INHX (MUL, 0x52);

void inline CPU_COM (uchar & OP, int _OP)
{
  ponflags (OP = ~OP);
  CCR.C = 1;
}

INSTRUCTION_DIR (COM, 0x33);
INSTRUCTION_INHA (COM, 0x43);
INSTRUCTION_INHX (COM, 0x53);
SetInstruction CPU_INHX_COM_constructor_2 (0x51, CPU_INHX_COM_00, CPU_INHX_COM_00, CPU_INHX_COM_00, CPU_INHX_COM_00,
   CPU_T_IllegalInstruction, CPU_T_IllegalInstruction, CPU_T_IllegalInstruction, CPU_T_IllegalInstruction);
INSTRUCTION_IX1 (COM, 0x63);
INSTRUCTION_IX (COM, 0x73);

void inline CPU_LSR (uchar & OP, int _OP)
{
  CCR.C = OP & 0x01;
  ponflags (OP >>= 1);
}

INSTRUCTION_DIR (LSR, 0x34);
INSTRUCTION_INHA (LSR, 0x44);
INSTRUCTION_INHX (LSR, 0x54);
INSTRUCTION_IX1 (LSR, 0x64);
INSTRUCTION_IX (LSR, 0x74);

void inline CPU_ROR (uchar & OP, int _OP)
{
  uint i = OP;
  if (CCR.C)
    i |= 0x100;
  CCR.C = i & 0x01;
  i >>= 1;
  ponflags (OP = i);
}

INSTRUCTION_DIR (ROR, 0x36);
INSTRUCTION_INHA (ROR, 0x46);
INSTRUCTION_INHX (ROR, 0x56);
INSTRUCTION_IX1 (ROR, 0x66);
INSTRUCTION_IX (ROR, 0x76);

void inline CPU_ASR (uchar & OP, int _OP)
{
  char c;

  c = OP;
  CCR.C = c & 0x01;
  c >>= 1;
  ponflags (OP = c);
}

INSTRUCTION_DIR (ASR, 0x37);
INSTRUCTION_INHA (ASR, 0x47);
INSTRUCTION_INHX (ASR, 0x57);
INSTRUCTION_IX1 (ASR, 0x67);
INSTRUCTION_IX (ASR, 0x77);

void inline CPU_LSL (uchar & OP, int _OP)
{
  CCR.C = OP & 0x80;
  ponflags (OP <<= 1);
}

INSTRUCTION_DIR (LSL, 0x38);
INSTRUCTION_INHA (LSL, 0x48);
INSTRUCTION_INHX (LSL, 0x58);
INSTRUCTION_IX1 (LSL, 0x68);
INSTRUCTION_IX (LSL, 0x78);

void inline CPU_ROL (uchar & OP, int _OP)
{
  uint i = OP << 1;
  if (CCR.C)
    i |= 0x01;
  CCR.C = i & 0x100;
  ponflags (OP = i);
}

INSTRUCTION_DIR (ROL, 0x39);
INSTRUCTION_INHA (ROL, 0x49);
INSTRUCTION_INHX (ROL, 0x59);
INSTRUCTION_IX1 (ROL, 0x69);
INSTRUCTION_IX (ROL, 0x79);

void inline CPU_DEC (uchar & OP, int _OP)
{
  ponflags (--OP);
}

INSTRUCTION_DIR (DEC, 0x3a);
INSTRUCTION_INHA (DEC, 0x4a);
INSTRUCTION_INHX (DEC, 0x5a);
INSTRUCTION_IX1 (DEC, 0x6a);
INSTRUCTION_IX (DEC, 0x7a);

void inline CPU_INC (uchar & OP, int _OP)
{
  ponflags (++OP);
}

INSTRUCTION_DIR (INC, 0x3c);
INSTRUCTION_INHA (INC, 0x4c);
INSTRUCTION_INHX (INC, 0x5c);
INSTRUCTION_IX1 (INC, 0x6c);
INSTRUCTION_IX (INC, 0x7c);

void inline CPU_TST (uchar & OP, int _OP)
{
  ponflags (OP);
}

INSTRUCTION_DIR (TST, 0x3d);
INSTRUCTION_INHA (TST, 0x4d);
INSTRUCTION_INHX (TST, 0x5d);
INSTRUCTION_IX1 (TST, 0x6d);
INSTRUCTION_IX (TST, 0x7d);

void inline CPU_SWAP (uchar & OP, int _OP)
{
  OP = (OP << 4) | (OP >> 4);
}

INSTRUCTION_DIR (SWAP, 0x3e);
INSTRUCTION_INHA (SWAP, 0x4e);
INSTRUCTION_INHX (SWAP, 0x5e);

void inline CPU__CLR (uchar & OP, int _OP)
{
  ponflags (OP = 0);
}

INSTRUCTION_DIR (_CLR, 0x3f);
INSTRUCTION_INHA (_CLR, 0x4f);
INSTRUCTION_INHX (_CLR, 0x5f);
INSTRUCTION_IX1 (_CLR, 0x6f);
INSTRUCTION_IX (_CLR, 0x7f);



void inline CPU_RTI (void)
{
  CCR.set (memory[++SP]);
  A = memory[++SP];
  X = memory[++SP];
  PC = memory[++SP];
  PC <<= 8;
  PC |= memory[++SP];
}

INSTRUCTION_INH (RTI, 0x80);

void inline CPU_RTS (void)
{
  PC = memory[++SP];
  PC <<= 8;
  PC |= memory[++SP];
}

INSTRUCTION_INH (RTS, 0x81);

void inline CPU_SWI (void)
{
  memory[SP--] = (uchar) PC;
  memory[SP--] = PC >> 8;
  memory[SP--] = X;
  memory[SP--] = A;
  memory[SP--] = CCR.get ();
  CCR.I = 1;
  PC = 0x4004;
}

INSTRUCTION_INH (SWI, 0x83);

void inline CPU_POP (uchar & OP, int _OP)
{
  OP = memory[++SP];
}

INSTRUCTION_INHA (POP, 0x84);
INSTRUCTION_INHX (POP, 0x85);

void inline CPU_POPCC ()
{
  CCR.set (memory[++SP]);
}

INSTRUCTION_INH (POPCC, 0x86);

void inline CPU_PUSH (uchar & OP, int _OP)
{
  memory[SP--] = OP;
}

INSTRUCTION_INHA (PUSH, 0x88);
INSTRUCTION_INHX (PUSH, 0x89);

void inline CPU_PUSHCC ()
{
  memory[SP--] = CCR.get ();
}

INSTRUCTION_INH (PUSHCC, 0x8A);

void inline CPU_TYX ()
{
  Y = X;
}

INSTRUCTION_INH (TYX, 0x93);


void inline CPU_TS (uchar & OP, int _OP)
{
  OP = SP;
}

INSTRUCTION_INHX (TS, 0x96);
INSTRUCTION_INHA (TS, 0x9e);

void inline CPU_TA (uchar & OP, int _OP)
{
  OP = A;
}

INSTRUCTION_INHX (TA, 0x97);

void inline CPU_TX (uchar & OP, int _OP)
{
  OP = XY;
}

INSTRUCTION_INHA (TX, 0x9f);

void inline CPU_CLC (void)
{
  CCR.C = 0;
}

INSTRUCTION_INH (CLC, 0x98);

void inline CPU_SEC (void)
{
  CCR.C = 1;
}

INSTRUCTION_INH (SEC, 0x99);

void inline CPU_CLI (void)
{
  CCR.I = 0;
}

INSTRUCTION_INH (CLI, 0x9a);

void inline CPU_SEI (void)
{
  CCR.I = 1;
}

INSTRUCTION_INH (SEI, 0x9b);

void inline CPU_RSP (void)
{
  SP = topStack;
}

INSTRUCTION_INH (RSP, 0x9c);

void inline CPU_NOP (void)
{
}

INSTRUCTION_INH (NOP, 0x9d);

void inline CPU_SUB (uchar & OP, int _OP)
{
  CCR.C = OP > A;
  ponflags (A -= OP);
}

INSTRUCTION_IMM (SUB, 0xa0);
INSTRUCTION_DIR (SUB, 0xb0);
INSTRUCTION_EXT (SUB, 0xc0);
INSTRUCTION_IX2 (SUB, 0xd0);
INSTRUCTION_IX1 (SUB, 0xe0);
INSTRUCTION_IX (SUB, 0xf0);

void inline CPU_CMP (uchar & OP, int _OP)
{
  CCR.C = OP > A;
  ponflags (A - OP);
}

INSTRUCTION_IMM (CMP, 0xa1);
INSTRUCTION_DIR (CMP, 0xb1);
INSTRUCTION_EXT (CMP, 0xc1);
INSTRUCTION_IX2 (CMP, 0xd1);
INSTRUCTION_IX1 (CMP, 0xe1);
INSTRUCTION_IX (CMP, 0xf1);

void inline CPU_SBC (uchar & OP, int _OP)
{
  uint c = OP;
  if (CCR.C)
    ++c;
  CCR.C = c > A;
  ponflags (A -= c);
}

INSTRUCTION_IMM (SBC, 0xa2);
INSTRUCTION_DIR (SBC, 0xb2);
INSTRUCTION_EXT (SBC, 0xc2);
INSTRUCTION_IX2 (SBC, 0xd2);
INSTRUCTION_IX1 (SBC, 0xe2);
INSTRUCTION_IX (SBC, 0xf2);

void inline CPU_CPX (uchar & OP, int _OP)
{
  CCR.C = OP > XY;
  ponflags (XY - OP);
}

INSTRUCTION_IMM (CPX, 0xa3);
INSTRUCTION_DIR (CPX, 0xb3);
INSTRUCTION_EXT (CPX, 0xc3);
INSTRUCTION_IX2 (CPX, 0xd3);
INSTRUCTION_IX1 (CPX, 0xe3);
INSTRUCTION_IX (CPX, 0xf3);

void inline CPU_AND (uchar & OP, int _OP)
{
  ponflags (A &= OP);
}

INSTRUCTION_IMM (AND, 0xa4);
INSTRUCTION_DIR (AND, 0xb4);
INSTRUCTION_EXT (AND, 0xc4);
INSTRUCTION_IX2 (AND, 0xd4);
INSTRUCTION_IX1 (AND, 0xe4);
INSTRUCTION_IX (AND, 0xf4);

void inline CPU_BIT (uchar & OP, int _OP)
{
  ponflags (A & OP);
}

INSTRUCTION_IMM (BIT, 0xa5);
INSTRUCTION_DIR (BIT, 0xb5);
INSTRUCTION_EXT (BIT, 0xc5);
INSTRUCTION_IX2 (BIT, 0xd5);
INSTRUCTION_IX1 (BIT, 0xe5);
INSTRUCTION_IX (BIT, 0xf5);

void inline CPU_LDA (uchar & OP, int _OP)
{
  ponflags (A = OP);
}

INSTRUCTION_IMM (LDA, 0xa6);
INSTRUCTION_DIR (LDA, 0xb6);
INSTRUCTION_EXT (LDA, 0xc6);
INSTRUCTION_IX2 (LDA, 0xd6);
INSTRUCTION_IX1 (LDA, 0xe6);
INSTRUCTION_IX (LDA, 0xf6);

void inline CPU_STA (uchar & OP, int _OP)
{
  ponflags (OP = A);
}

INSTRUCTION_DIR (STA, 0xb7);
INSTRUCTION_EXT (STA, 0xc7);
INSTRUCTION_IX2 (STA, 0xd7);
INSTRUCTION_IX1 (STA, 0xe7);
INSTRUCTION_IX (STA, 0xf7);

void inline CPU_EOR (uchar & OP, int _OP)
{
  ponflags (A ^= OP);
}

INSTRUCTION_IMM (EOR, 0xa8);
INSTRUCTION_DIR (EOR, 0xb8);
INSTRUCTION_EXT (EOR, 0xc8);
INSTRUCTION_IX2 (EOR, 0xd8);
INSTRUCTION_IX1 (EOR, 0xe8);
INSTRUCTION_IX (EOR, 0xf8);

void inline CPU_ADC (uchar & OP, int _OP)
{
  uint a;
  uchar h;

  a = A + OP;
  h = (A & 0xf) + (OP & 0xf);
  if (CCR.C) {
    ++a;
    ++h;
  }
  ponflags (A = a);
  CCR.C = a >= 0x100;
  CCR.H = h >= 0x10;
}

INSTRUCTION_IMM (ADC, 0xa9);
INSTRUCTION_DIR (ADC, 0xb9);
INSTRUCTION_EXT (ADC, 0xc9);
INSTRUCTION_IX2 (ADC, 0xd9);
INSTRUCTION_IX1 (ADC, 0xe9);
INSTRUCTION_IX (ADC, 0xf9);

void inline CPU_ORA (uchar & OP, int _OP)
{
  ponflags (A |= OP);
}

INSTRUCTION_IMM (ORA, 0xaa);
INSTRUCTION_DIR (ORA, 0xba);
INSTRUCTION_EXT (ORA, 0xca);
INSTRUCTION_IX2 (ORA, 0xda);
INSTRUCTION_IX1 (ORA, 0xea);
INSTRUCTION_IX (ORA, 0xfa);

void inline CPU_ADD (uchar & OP, int _OP)
{
  uint a;
  uchar h;

  a = A + OP;
  h = (A & 0xf) + (OP & 0xf);
  ponflags (A = a);
  CCR.C = a >= 0x100;
  CCR.H = h >= 0x10;
}

INSTRUCTION_IMM (ADD, 0xab);
INSTRUCTION_DIR (ADD, 0xbb);
INSTRUCTION_EXT (ADD, 0xcb);
INSTRUCTION_IX2 (ADD, 0xdb);
INSTRUCTION_IX1 (ADD, 0xeb);
INSTRUCTION_IX (ADD, 0xfb);

void inline CPU_JMP (uchar & OP, int _OP)
{
  PC = _OP;
}

INSTRUCTION_DIR (JMP, 0xbc);
INSTRUCTION_EXT (JMP, 0xcc);
INSTRUCTION_IX2 (JMP, 0xdc);
INSTRUCTION_IX1 (JMP, 0xec);
INSTRUCTION_IX (JMP, 0xfc);

void inline CPU_BSR (char &OP, int _OP)
{
  memory[SP--] = PC;
  memory[SP--] = PC >> 8;
  PC += OP;
}

INSTRUCTION_REL (BSR, 0xad);

void inline CPU_JSR (uchar & OP, int _OP)
{
  memory[SP--] = PC;
  memory[SP--] = PC >> 8;
  PC = _OP;
}

INSTRUCTION_DIR (JSR, 0xbd);
INSTRUCTION_EXT (JSR, 0xcd);
INSTRUCTION_IX2 (JSR, 0xdd);
INSTRUCTION_IX1 (JSR, 0xed);
INSTRUCTION_IX (JSR, 0xfd);

void inline CPU_LDX (uchar & OP, int _OP)
{
  ponflags (XY = OP);
}

INSTRUCTION_IMM (LDX, 0xae);
INSTRUCTION_DIR (LDX, 0xbe);
INSTRUCTION_EXT (LDX, 0xce);
INSTRUCTION_IX2 (LDX, 0xde);
INSTRUCTION_IX1 (LDX, 0xee);
INSTRUCTION_IX (LDX, 0xfe);

void inline CPU_STX (uchar & OP, int _OP)
{
  ponflags (OP = XY);
}

INSTRUCTION_DIR (STX, 0xbf);
INSTRUCTION_EXT (STX, 0xcf);
INSTRUCTION_IX2 (STX, 0xdf);
INSTRUCTION_IX1 (STX, 0xef);
INSTRUCTION_IX (STX, 0xff);


/*-----------------------------------------------------------------------------------------------------*/
/*  Instruccion no emuladas */

void inline CPU_STOP (void)
{
  Debugger ();
}

INSTRUCTION_INH (STOP, 0x8e);

void inline CPU_WAIT (void)
{
  Debugger ();
}

INSTRUCTION_INH (WAIT, 0x8f);

/*-----------------------------------------------------------------------------------------------------*/
void Debugger (void)
{
  CPU__6805_Print ();
  exit (0);
}

/*-----------------------------------------------------------------------------------------------------*/
void GEN_IRQ (uint pc)
{
  memory[SP--] = (uchar) PC;
  memory[SP--] = PC >> 8;
  memory[SP--] = X;
  memory[SP--] = A;
  memory[SP--] = CCR.get ();
  CCR.I = 1;
  PC = pc;
}

void CPU__6805_Initz ()
{
  /*  Initialize Instruction Table */
}
