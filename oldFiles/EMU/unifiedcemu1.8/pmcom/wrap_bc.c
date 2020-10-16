/* wrap_bc.c */

#include <mem.h>
#include <dos.h>

#include "irqwrap.h"

/*
IRQ wrappers for BC
*/

typedef void interrupt (*IRQ_ISR)(void);
extern TIRQWrapper OldIRQVectors[16];

/* As these can not be stored in local variables (stack frame changed) */
int SaveSS[16];
int SaveSP[16];

/*
IMPORTANT:
Whenever bcc is invoked with -3 option a -DPUSH386 should be present!
*/
#ifdef PUSH386
#define EMIT386(x)  __emit__(x)
#else
#define EMIT386(x)
#endif

#define PUSHA386()  EMIT386(0x66); EMIT386(0x60);
#define POPA386()  EMIT386(0x66); EMIT386(0x61);

/*
Define wrap for each IRQ.
1. Save the current stack frame.
2. Search for free stack in previously allocated array of stacks.
3. If found switch to this stack frame.
4. Mark the stack is in use.
4. Invoke user call-back functio to handle the IRQ.
5. Invoke the IRQ handler pointer by old IRQ vector (if demanded).
6. Restore the stack frame.
NOTE: There is a problem when free stack is not found. Here
the IRQ will be served in the stack frame of the caller which
may be a certain risk. The other way is to leave the IRQ wrap
with unserved IRQ which may crash the system.
Its supposed that having 8 stacks allocated would be enough.
It is a common practice to work in the stack frame where IRQ
occured and this makes even the case when no free stack found
not so dangerous. In irq_bc there's a define ALLOCATE_STACK that
could turn off allocating speicial stack frames	serving IRQs.
*/
#define IRQWRAP(x)\
static void interrupt IRQWrap##x(void)\
{\
  char **pStack;\
  char *pStackInUse;\
\
  PUSHA386();\
\
  pStackInUse = NULL;\
  SaveSS[##x] = _SS;\
  SaveSP[##x] = _SP;\
\
  pStack = (char **)&IRQStacks[IRQ_STACKS];\
  do\
  {\
    --pStack;\
    if (*pStack != NULL)\
    {\
      pStackInUse = *pStack;\
      _CX = FP_SEG(*pStack);\
      _DX = FP_OFF(*pStack);\
      *pStack = NULL;\
      _SS = _CX;\
      _SP = _DX;\
      break;\
    }\
  }\
  while (pStack != &IRQStacks[0]);\
\
  if (IRQHandlers[##x]())\
    ((IRQ_ISR)OldIRQVectors[##x])();\
\
  _SP = SaveSP[##x];\
  _SS = SaveSS[##x];\
\
  if (pStackInUse)\
    *pStack = pStackInUse;\
\
  POPA386();\
}

IRQWRAP(0);
IRQWRAP(1);
IRQWRAP(2);
IRQWRAP(3);  /* Comment this when uncommenting IRQWrap3 below */
/* This is IRQWrap3 -- COM2, uncomment for debugging */
/*
static void interrupt IRQWrap3(void)
{
  char **pStack;
  char *pStackInUse;

  PUSHA386();

  pStackInUse = NULL;
  SaveSS[3] = _SS;
  SaveSP[3] = _SP;

  pStack = (char **)&IRQStacks[IRQ_STACKS];
  do
  {
    --pStack;
    if (*pStack != NULL)
    {
      pStackInUse = *pStack;
      _CX = FP_SEG(*pStack);
      _DX = FP_OFF(*pStack);
      *pStack = NULL;
      _SS = _CX;
      _SP = _DX;
      break;
    }
  }
  while (pStack != &IRQStacks[0]);

  if (IRQHandlers[3]())
    ((IRQ_ISR)OldIRQVectors[3])();

  _SP = SaveSP[3];
  _SS = SaveSS[3];

  if (pStackInUse)
    *pStack = pStackInUse;

  POPA386();
}
*/

IRQWRAP(4);
IRQWRAP(5);
IRQWRAP(6);
IRQWRAP(7);
IRQWRAP(8);
IRQWRAP(9);
IRQWRAP(10);
IRQWRAP(11);
IRQWRAP(12);
IRQWRAP(13);
IRQWRAP(14);
IRQWRAP(15);

TIRQWrapper IRQWrappers[16] =
{
  (TIRQWrapper)IRQWrap0,
  (TIRQWrapper)IRQWrap1,
  (TIRQWrapper)IRQWrap2,
  (TIRQWrapper)IRQWrap3,
  (TIRQWrapper)IRQWrap4,
  (TIRQWrapper)IRQWrap5,
  (TIRQWrapper)IRQWrap6,
  (TIRQWrapper)IRQWrap7,
  (TIRQWrapper)IRQWrap8,
  (TIRQWrapper)IRQWrap9,
  (TIRQWrapper)IRQWrap10,
  (TIRQWrapper)IRQWrap11,
  (TIRQWrapper)IRQWrap12,
  (TIRQWrapper)IRQWrap13,
  (TIRQWrapper)IRQWrap14,
  (TIRQWrapper)IRQWrap15
};

TIRQHandler IRQHandlers[16] =
{
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
};

