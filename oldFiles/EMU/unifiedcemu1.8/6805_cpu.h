#ifndef _CPU_6805_
#define _CPU_6805_

#define     memonicsTableSize            256
#define     memorySize                    65536

typedef void voidFunc (void);
extern voidFunc *precomp[memorySize];
extern voidFunc *precompDebug[memorySize];

extern int RomVer;

class _CCR
{
public:
  bool C, Z, N, I, H;

  _CCR (void):C (0), Z (0), N (0), I (0), H (0)
  {
  }

  inline uchar get ()
  {
    uchar x = 0;
    if (C)
      x |= 0x01;
    if (Z)
      x |= 0x02;
    if (N)
      x |= 0x04;
    if (I)
      x |= 0x08;
    if (H)
      x |= 0x10;
    return x;
  }

  inline uchar set (uchar x)
  {
    C = x & 0x01;
    Z = x & 0x02;
    N = x & 0x04;
    I = x & 0x08;
    I = x & 0x10; 
//    H = x & 0x10; Question error
    return x & 0x1f;
  }
};

extern uint backtrace[0x100];
extern uint backtraceI;

typedef uchar *Ptr;
typedef uchar Byte;
typedef void (*instructionPointer) ();
typedef void (*instructionText) (ostream &o);

extern char trace;
extern uchar A;                 /*      Accumulator A */
extern uchar X;                 /*      Index Register */
extern uchar Y;
extern _CCR CCR;                /*      Condition Code Register */
extern uint SP;                 /*  Stack Pointer */
extern uint PC;                 /*  Program Counter */
extern int topStack;

extern void GEN_IRQ (uint);
extern void FAST CPU__6805_Step (void);
extern void FAST CPU__Execute ();
extern void CPU__6805_Print ();
extern void CPU__6805_Reset (void);
extern void CPU__6805_Initz (void);
extern void Debugger (void);

extern int SaveEEPROM (char *ROM, int dir, int lon);
extern int LoadROM (char *ROM, int dir, int lon);

typedef uchar & memFunc (int i);
extern memFunc *MemFunc;

class Memory
{
public:
  uchar m[memorySize];

  void Bad (int i)
  {
    cout << "BAD MEMORY ACCESS: " << h16 << i << endl;
    Debugger ();
  }

  inline uchar & operator[] (int i)
  {
    return MemFunc (i);
  };

  void s (int l, void *v, int s)
  {
    for (int a = 0; a < s; ++a)
      m[l + a] = ((uchar *) v)[a];
  }
  void s8 (int l, uint s)
  {
    (*this)[l] = (uchar) s;
  }
  void s16 (int l, uint s)
  {
    (*this)[l + 0] = (uchar) (s >> 8);
    (*this)[l + 1] = (uchar) (s >> 0);
  }
  void s32 (int l, uint s)
  {
    (*this)[l + 0] = (uchar) (s >> 24);
    (*this)[l + 1] = (uchar) (s >> 16);
    (*this)[l + 2] = (uchar) (s >> 8);
    (*this)[l + 3] = (uchar) (s >> 0);
  }
  void s64 (int l, uint64 s)
  {
    (*this)[l + 0] = (uchar) (s >> 56);
    (*this)[l + 1] = (uchar) (s >> 48);
    (*this)[l + 2] = (uchar) (s >> 40);
    (*this)[l + 3] = (uchar) (s >> 32);
    (*this)[l + 4] = (uchar) (s >> 24);
    (*this)[l + 5] = (uchar) (s >> 16);
    (*this)[l + 6] = (uchar) (s >> 8);
    (*this)[l + 7] = (uchar) (s >> 0);
  }


  void _s16 (int l, uint s)
  {
    (*this)[l + 1] = (uchar) (s >> 8);
    (*this)[l + 0] = (uchar) (s >> 0);
  }
  void _s32 (int l, uint s)
  {
    (*this)[l + 3] = (uchar) (s >> 24);
    (*this)[l + 2] = (uchar) (s >> 16);
    (*this)[l + 1] = (uchar) (s >> 8);
    (*this)[l + 0] = (uchar) (s >> 0);
  }
  void _s64 (int l, uint64 s)
  {
    (*this)[l + 7] = (uchar) (s >> 56);
    (*this)[l + 6] = (uchar) (s >> 48);
    (*this)[l + 5] = (uchar) (s >> 40);
    (*this)[l + 4] = (uchar) (s >> 32);
    (*this)[l + 3] = (uchar) (s >> 24);
    (*this)[l + 2] = (uchar) (s >> 16);
    (*this)[l + 1] = (uchar) (s >> 8);
    (*this)[l + 0] = (uchar) (s >> 0);
  }
  void g (int l, void *v, int s)
  {
    for (int a = 0; a < s; ++a)
      ((uchar *) v)[a] = m[l + a];
  }
  uint g8 (int l)
  {
    return (*this)[l];
  }
  inline uint g16 (int l)
  {
    return ((*this)[l + 0] << 8) + ((*this)[l + 1] << 0);
  }
  uint g32 (int l)
  {
    return ((*this)[l + 0] << 24) + ((*this)[l + 1] << 16) +
      ((*this)[l + 2] << 8) + ((*this)[l + 3] << 0);
  }
  uint64 g64 (int l)
  {
    return ((uint64) (*this)[l + 0] << 56) +
      ((uint64) (*this)[l + 1] << 48) +
      ((uint64) (*this)[l + 2] << 40) +
      ((uint64) (*this)[l + 3] << 32) +
      ((uint64) (*this)[l + 4] << 24) +
      ((uint64) (*this)[l + 5] << 16) +
      ((uint64) (*this)[l + 6] << 8) + ((uint64) (*this)[l + 7] << 0);
  }
  uint _g16 (int l)
  {
    return ((*this)[l + 1] << 8) + ((*this)[l + 0] << 0);
  }
  uint _g32 (int l)
  {
    return ((*this)[l + 3] << 24) + ((*this)[l + 2] << 16) +
      ((*this)[l + 1] << 8) + ((*this)[l + 0] << 0);
  }
  uint64 _g64 (int l)
  {
    return ((uint64) (*this)[l + 7] << 56) +
      ((uint64) (*this)[l + 6] << 48) +
      ((uint64) (*this)[l + 5] << 40) +
      ((uint64) (*this)[l + 4] << 32) +
      ((uint64) (*this)[l + 3] << 24) +
      ((uint64) (*this)[l + 2] << 16) +
      ((uint64) (*this)[l + 1] << 8) + ((uint64) (*this)[l + 0] << 0);
  }
};
extern Memory memory;

class bas
{
  uchar *addr;
  int length;

public:

    bas (void *a, int l):addr ((uchar *) a), length (l)
  {
  }

  bas (int a, int l):addr (&memory[a]), length (l)
  {
  }

  friend ostream & operator << (ostream & o, bas b)
  {
    for (int a = 0; a < b.length; ++a)
      o << " " << h8 << (int) b.addr[a];
    return o;
  }
};

class ba
{
  uchar *addr;
  int length;

public:

    ba (void *a, int l):addr ((uchar *) a), length (l)
  {
  }

  ba (int a, int l):addr (&memory[a]), length (l)
  {
  }

  friend ostream & operator << (ostream & o, const ba & b)
  {
    for (int a = 0; a < b.length; ++a)
      o << h8 <<  (int) b.addr[a];
    return o;
  }

  friend int operator >> (istream & i, const ba & b)
  {
    for (int a = 0; a < b.length; ++a) {
      string s;
      i >> setw (2) >> s;
      if (!i)
        return a;
      int i;
      istringstream is (s);
      is >> hex >> i;
      b.addr[a] = i;
    }
    return b.length;
  }
};

#endif
