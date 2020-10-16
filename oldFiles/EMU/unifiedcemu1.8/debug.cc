#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "comm.h"

const char Usage_b[] = "Usage: bp x/bc x/bl";
const char Usage_d[] = "Usage: d/d x/d x x";
const char Usage_e[] = "Usage: e x x ....";
const char Usage_r[] = "Usage: r/r R x";
const char Usage[] = "Usage: b/d/e/g/s/q/r/w";


void dumpmem (uint lo, uint hi)
{
  uint lo16 = lo & 0xfff0, hi16 = (hi + 0x0f) & 0xfff0;

  for (uint i = lo16; i < hi16; i += 0x0010) {
    cout << h16 << i << " : ";
    for (uint j = 0; j < 0x0010; ++j)
      if ((i + j >= lo) && (i + j < hi))
        cout << h8 << (int) memory.m[i + j] << " ";
      else
        cout << "   ";
    cout << " -- ";
    for (uint j = 0; j < 0x0010; ++j)
      if ((i + j >= lo) && (i + j < hi)) {
        uchar c = memory.m[i + j];
        if ((c >= 0x10) && (c < 0x80))
          cout << c;
        else
          cout << ".";
      } else
        cout << " ";
    cout << endl;
  }
}

void dump (istringstream & s)
{
  static uint old = 0;
  uint lo, hi;
  s >> lo;
  if (!s) {
    dumpmem (old, old + 0x100);
    old += 0x100;
    return;
  }
  s >> hi;
  if (!s) {
    dumpmem (lo, lo + 0x100);
    old = lo + 0x100;
    return;
  }
  dumpmem (lo, hi);
  old = hi;
}

void edit (istringstream & s)
{
  uint a, x;
  s >> a;
  if (!s) {
    cout << Usage_e << endl;
    return;
  }
  int i = 0;
  for (s >> x; !!s; s >> x) {
    if ((i & 0x0003) == 0)
      cout << h16 << (a + i) << " : ";
    else
      cout << ", ";
    cout << h8 << (int) memory.m[a + i] << " <-- " << h8 << x;
    memory.m[a + i] = x;
    ++i;
    if ((i & 0x0003) == 0)
      cout << endl;
  }
  if (!i)
    cout << Usage_e << endl;
  if ((i & 0x0003) != 0)
    cout << endl;
}

void regi (istringstream & s)
{
  string r;
  uint x;
  s >> r >> x;
	if ((r == "pc") || (r == "PC")){
		cout << "PC : " << h16 << (int) PC << " <-- ";
		PC = x;
		cout << (int) PC << endl;
	}
	else if ((r == "sp") || (r == "SP")){
		cout << "SP : " << h16 << (int) SP << " <-- ";
		SP=x;
		cout << (int) SP << endl;
	}
	else if ((r == "ccr") || (r == "CCR"))
		cout << "CCR : " << h16 << (int) CCR.get () << " <-- "
			<< (int) (CCR.set (x)) << endl;
	else if ((r == "a") || (r == "A")){
		cout << "A : " << h16 << (int) A << " <-- ";
		A = x;
		cout << (int) A << endl;
	}
	else if ((r == "x") || (r == "X")){
		cout << "X : " << h16 << (int) X << " <-- ";
		X = x;
		cout << (int) X << endl;
	}
	else if ((r == "y") || (r == "Y")){
		cout << "Y : " << h16 << (int) Y << " <-- ";
		Y = x;
		cout << (int) Y << endl;
	}
  else
    CPU__6805_Print ();
}

void bp (istringstream & s)
{
  char c;
  uint a;
  s >> c;
  if (!s)
    cout << Usage_b << endl;
  else
    switch (c) {
      case 'p':
      case 'P':
        s >> a;
        if (!s)
          cout << Usage_b << endl;
        else if (precompDebug[a])
          cout << Usage_b << endl;
        else {
          precompDebug[a] = precomp[a];
          precomp[a] = debug;
        }
        break;
      case 'c':
      case 'C':
        s >> a;
        if (!s)
          cout << Usage_b << endl;
        else if (!precompDebug[a])
          cout << Usage_b << endl;
        else {
          precomp[a] = precompDebug[a];
          precompDebug[a] = 0;
        }
        break;
      case 'l':
      case 'L':
        for (a = 0; a < memorySize; ++a)
          if (precompDebug[a])
            cout << h16 << a << " ";
        cout << endl;
        break;
      default:
        cout << Usage_b << endl;
        break;
    }
}

void wEEP (istringstream & s)
{
  string f;
  s >> f;
  if (!s)
    f = dishfile;
  writeEEPROM (f.c_str ());
}

void step (istringstream & s)
{
  uint i;
  s >> dec >> i;
  if (!s)
    i = 1;
  for (uint a = 0; a < i; ++a) {
    if (precompDebug[PC])
      precompDebug[PC] ();
    else
      precomp[PC] ();
    CPU__6805_Print ();
  }
}

void debug (void)
{
  CPU__6805_Print ();
  while (true) {
    cout << "# ";
    char si[256];
    cin.getline (si, 256);
    istringstream s (si);
    s >> hex;

    char c;
    s >> c;
    switch (c) {
      case 'd':
      case 'D':
        dump (s);
        break;
      case 'e':
      case 'E':
        edit (s);
        break;
      case 'r':
      case 'R':
        regi (s);
        break;
      case 'g':
      case 'G':
        if (precompDebug[PC])
          precompDebug[PC] ();
        else
          precomp[PC] ();
        return;
        break;
      case 's':
      case 'S':
        step (s);
        break;
      case 'q':
      case 'Q':
	Debugstat = 1;
        Debugging = 0;
        Break = 1;
        return;
        break;
      case 'b':
      case 'B':
        bp (s);
        break;
      case 'w':
      case 'W':
        wEEP (s);
        break;
      case 'i':
         cout << "Disable Debug Input" << endl ;
         break;
      case 'I':
         cout << "enable Debug Input" << endl ;
         break;
      default:
        cout << Usage << endl;
        break;
    }
  }
}
