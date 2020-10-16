/* timer.h */
#ifndef TIMER_H
#define TIMER_H

#ifdef __cplusplus
extern "C" {
#endif

#define	TIMERMAX 8
#define evTimer	5	/* high byte will hold consequtive timer number that expired */

extern volatile unsigned long int nTimerValue;

int TIMERInit(void);
void TIMERShutDown(void);
void TIMERStart(int nTimer, int miliseconds, void (*Handler)(int nEvent));
int TIMERIsExpired(int nTimer);
void TIMERStop(int nTimer);

#ifdef __cplusplus
}
#endif

#endif  /* ifndef TIMER_H */

