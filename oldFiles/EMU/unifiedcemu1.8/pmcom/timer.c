/* timer.c */

#include <string.h>

#include "irq.h"
#include "timer.h"

#include <assert.h>

#define TRUE 1
#define FALSE 0

#ifdef _DEBUG
#define ASSERT(x)        assert(x)
#else
#define ASSERT(x)
#endif

struct Timer
{
  long nTimer;
  void (*EventHandler)(int nEvent);
};

static struct Timer Timers[TIMERMAX];
static int bTIMERInit = FALSE;
volatile unsigned long int nTimerValue;
static int bTIMERDisabled = FALSE;

/* ************************************************************************
   Function: TIMERHandler
   Description:
     Invoked 19.5 times per second.
     Decrements each of	the timers.
     Invokes correspondent handlers if timer expires.
     Entering this functions IRQs are disabled.
*/
static int TIMERHandler(void)
{
  struct Timer *pTimer;

  ++nTimerValue;

  if (bTIMERDisabled)
    return (1);

  pTimer = &Timers[TIMERMAX - 1];
  do
  {
    if (pTimer->nTimer != 0)
    {
      if (--pTimer->nTimer == 0)
        if (pTimer->EventHandler != NULL)  /* This is atomic operation */
          pTimer->EventHandler(evTimer | ((int)(pTimer - Timers) << 8));
    }
    --pTimer;
  }
  while (pTimer != Timers);

  return (1);  /* Call BIOS handler on exit */
}

/* ************************************************************************
   Function: TIMERInit
   Description:
*/
int TIMERInit(void)
{
  ASSERT(!bTIMERInit);  /* TIMERInit() should be called only once */

  if (!InstallIRQ(0, TIMERHandler))
    return (FALSE);

  bTIMERInit = TRUE;

  memset(Timers, 0, sizeof(Timers));
  nTimerValue = 0;
  return (TRUE);
}

/* ************************************************************************
   Function: TIMERShutDown
   Description:
*/
void TIMERShutDown(void)
{
  ASSERT(bTIMERInit);  /* Should be called after calling TIMERInit() */
  UninstallIRQ(0);
}

/* ************************************************************************
   Function: TIMERStart
   Description:
*/
void TIMERStart(int nTimer, int miliseconds, void (*Handler)(int nEvent))
{
  ASSERT(bTIMERInit);  /* Should be called after calling TIMERInit() */
  ASSERT(nTimer < TIMERMAX);  /* Check for valid range */
  ASSERT(nTimer >= 0);

  /* Activating a timer should be atom operation */
  bTIMERDisabled = TRUE;
  Timers[nTimer].nTimer	= miliseconds / 50 + 1;
  Timers[nTimer].EventHandler =	Handler;
  bTIMERDisabled = FALSE;
}

/* ************************************************************************
   Function: TIMERIsExpired
   Description:
*/
int TIMERIsExpired(int nTimer)
{
  ASSERT(bTIMERInit);  /* Should be called after calling TIMERInit() */
  ASSERT(nTimer < TIMERMAX);  /* Check for valid range */
  ASSERT(nTimer >= 0);

  if (Timers[nTimer].nTimer > 0)
    return (FALSE);

  ASSERT(Timers[nTimer].nTimer == 0);
  return (TRUE);
}

/* ************************************************************************
   Function: TIMERStop
   Description:
*/
void TIMERStop(int nTimer)
{
  ASSERT(bTIMERInit);  /* Should be called after calling TIMERInit() */

  /* Deactivating a timer should be atom operation */
  bTIMERDisabled = TRUE;
  Timers[nTimer].nTimer	= 0;
  Timers[nTimer].EventHandler =	NULL;
  bTIMERDisabled = FALSE;
}

