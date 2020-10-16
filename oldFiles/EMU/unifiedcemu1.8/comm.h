#ifndef __COMM__
#define __COMM__

class comm
{
public:

  virtual int Open (void) = 0;
  virtual void Close (void) = 0;
  virtual int Read (uchar * buf) = 0;
  virtual void Write (uchar * buf, int len) = 0;
  virtual void WriteATR (uchar * buf, int len) = 0;
    virtual ~ comm (void)
  {
  }
}
extern *Comm;
void Pat_Yield ();
void PatSleep();
void setupcomm (const string & base, const string & port, int baud,
                int atrbaud, int address, int irq);

struct buffer
{
  uchar data[255];
  int length;
};

#endif
