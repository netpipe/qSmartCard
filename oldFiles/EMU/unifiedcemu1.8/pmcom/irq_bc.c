/* irq_bc.c */

#include <dos.h>
#include <mem.h>
#include <assert.h>
#include <alloc.h>
#include <stdlib.h>

#include "irqwrap.h"
#include "irq.h"

/*
IRQ Installing/Uninstalling functions
*/

#ifdef _DEBUG
#define ASSERT(x)        assert(x)
#else
#define ASSERT(x)
#endif

#define STACK_SIZE   (4 * 1024)      /* 4k stack should be plenty */

#define TRUE 1
#define FALSE 0

/*
If the irq will use system stack or the specially allocated stack
space in the heap.
*/
#define ALLOCATE_STACKS  TRUE

typedef void interrupt (*IRQ_ISR)(void);
static int bInitIRQ = FALSE;
void *IRQStacks[IRQ_STACKS];

TIRQWrapper OldIRQVectors[16] =
{
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL
};

#pragma argsused
int LockData(void *a, long size)
{
  return (0);
}

#pragma argsused
int LockCode(void *a, long size)
{
  return (0);
}

#pragma argsused
int UnlockData(void *a, long size)
{
  return (0);
}

#pragma argsused
int UnlockCode(void *a, long size)
{
  return (0);
}

/* Forward definitions */
static int InitIRQ(void);
static void ShutDownIRQ(void);

/* ************************************************************************
   Function: InstallIRQ
   Description:
     Installs handler for specific IRQ.
*/
int InstallIRQ(int nIRQ, int (*IRQHandler)(void))
{
  int nIRQVect;

  ASSERT(nIRQ >= 0 && nIRQ < 16);  /* Invalid IRQ vector */
  ASSERT(OldIRQVectors[nIRQ] == NULL);  /* Nothing previously attached to this IRQ */
  ASSERT(IRQHandler != NULL);  /* Invalid handler address */
  ASSERT(IRQHandlers[nIRQ] == NULL);

  if (!bInitIRQ)
    if (!InitIRQ())
      return (FALSE);

  if (nIRQ > 7)
    nIRQVect = 0x70 + (nIRQ - 8);
  else
    nIRQVect = 0x8 + nIRQ;

  (IRQ_ISR)OldIRQVectors[nIRQ] = getvect(nIRQVect);
  IRQHandlers[nIRQ] = IRQHandler;  /* IRQWrapper will call IRQHandler */
  setvect(nIRQVect, (IRQ_ISR)IRQWrappers[nIRQ]);
  return (TRUE);
}

/* ************************************************************************
   Function: UninstallIRQ
   Description:
     Uninstalls IRQ handler.
*/
void UninstallIRQ(int nIRQ)
{
  int nIRQVect;
  int i;

  ASSERT(bInitIRQ);
  ASSERT(nIRQ < 16 && nIRQ >= 0);
  ASSERT(IRQHandlers[nIRQ] != NULL);

  if (nIRQ > 7)
    nIRQVect = 0x70 + (nIRQ - 8);
  else
    nIRQVect = 0x8 + nIRQ;

  setvect(nIRQVect, (IRQ_ISR)OldIRQVectors[nIRQ]);
  IRQHandlers[nIRQ] = NULL;

  /*
  Check whether all the IRQs are uninstalled and call ShutDownIRQ().
  */
  for (i = 0; i < 16; ++i)
    if (IRQHandlers[i] != NULL)
      return;  /* Still remains a handler */
  ShutDownIRQ();
}

/* ************************************************************************
   Function: InitIRQ
   Description:
     Initial setup of the IRQ wrappers
   Returns:
     0 -- failed to allocate memory for the stacks.
*/
static int InitIRQ(void)
{
  #if (!ALLOCATE_STACKS)
  memset(IRQStacks, 0, sizeof(IRQStacks));
  bInitIRQ = TRUE;
  atexit(ExitIRQ);
  return (TRUE);
  #else
  int i;

  for (i = 0; i < IRQ_STACKS; ++i)
  {
    if ((IRQStacks[i] = malloc(STACK_SIZE)) == NULL)
    {
      for (; i >= 0; --i)  /* Free what was allocated */
        free((char *)IRQStacks[i] - (STACK_SIZE - 16));
      return (FALSE);
    }
    (char *)IRQStacks[i] += (STACK_SIZE - 16);  /* Stack is incremented downward */
  }
  bInitIRQ = TRUE;
  return (TRUE);
  #endif
}

/* ************************************************************************
   Function: ShutDownIRQ
   Description:
     Deallocates the stacks for IRQ wrappers.
*/
static void ShutDownIRQ(void)
{
  #if (!ALLOCATE_STACKS)
  ASSERT(bInitIRQ);
  #else
  int i;

  ASSERT(bInitIRQ);

  for (i = 0; i	< IRQ_STACKS; ++i)
  {
    ASSERT(IRQStacks[i] != NULL);
    free((char *)IRQStacks[i] - (STACK_SIZE - 16));
  }
  #endif
}


/*
Extracting memory contents is compiler dependent as well
*/

/* ************************************************************************
   Function: _peekb
   Description:
*/
unsigned char _peekb(int nSeg, int nOfs)
{
  return (*((unsigned char far *)MK_FP((nSeg), (nOfs))));
}

/* ************************************************************************
   Function: _peekw
   Description:
*/
unsigned short int _peekw(int nSeg, int nOfs)
{
  return (*((unsigned int far *)MK_FP((nSeg), (nOfs))));
}

/* ************************************************************************
   Function: _peekd
   Description:
*/
unsigned long _peekd(int nSeg, int nOfs)
{
  return (*((unsigned long far *)MK_FP((nSeg), (nOfs))));
}

