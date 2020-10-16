#include "cemu.h"
#include "comm.h"
#include "6805_cpu.h"
//#ifndef _WIN32
//#include "dpmi.h"
//#endif
int flipit (uchar c)
{
  const char NibbleTable[16] = { 0x00, 0x08, 0x04, 0x0C, 0x02, 0x0A, 0x06, 0x0E,
    0x01, 0x09, 0x05, 0x0D, 0x03, 0x0B, 0x07, 0x0F
  };
  c ^= 0xff;
  return NibbleTable[(c) >> 4] + (NibbleTable[(c) & 0x0F] << 4);
}

#ifdef _WIN32
#include <windows.h>

static const int baudtable[][2] = {
  {110, CBR_110}, {300, CBR_300}, {600, CBR_600}, {1200, CBR_1200},
  {2400, CBR_2400}, {4800, CBR_4800}, {9600, CBR_9600}, {19200, CBR_19200},
  {38400, CBR_38400}, {57600, CBR_57600}, {115200, CBR_115200}, {0, 0}
};

class commserial:public comm
{
  HANDLE port;
  int databaud, atrbaud, inverse, address, irq;
  string device;

  void setdatabaud (void)       // 8N1
  {
    DCB dcb = { 0 };

    dcb.DCBlength = sizeof (dcb);
    if (!GetCommState (port, &dcb))
      return;
    dcb.BaudRate = databaud;
    dcb.ByteSize = 8;
    dcb.Parity = NOPARITY;
    dcb.StopBits = ONESTOPBIT;
    dcb.fParity = FALSE;
    dcb.fTXContinueOnXoff = FALSE;
    dcb.fOutX = FALSE;
    dcb.fInX = FALSE;

    if (!SetCommState (port, &dcb))
      return;
  }

  void setatrbaud (void)        // 8O2
  {
    DCB dcb = { 0 };

    dcb.DCBlength = sizeof (dcb);
    if (!GetCommState (port, &dcb))
      return;
    dcb.BaudRate = atrbaud;
    dcb.ByteSize = 8;
    dcb.Parity = ODDPARITY;
    dcb.StopBits = TWOSTOPBITS;
    dcb.fParity = TRUE;
    dcb.fTXContinueOnXoff = FALSE;
    dcb.fOutX = FALSE;
    dcb.fInX = FALSE;

    if (!SetCommState (port, &dcb))
      return;
  }

  virtual int readbyte (void)
  {
    DWORD dwRead = 0;
    uchar c;

/*    Sleep (1);*/
        ReadFile (port, &c, 1, &dwRead, NULL);
    if (dwRead) {
      if (inverse)
      {

        return flipit (c);
        }
      else
        return c;
    }
    PatSleep ();
    return -1;
  }

public:

  commserial (const string & d, int db, int ab, int inv, int A, int I)
:  databaud (-1), atrbaud (-1), inverse (inv),
    address (A), irq (I), device (d) {
    port = INVALID_HANDLE_VALUE;
    for (int a = 0; baudtable[a][0]; ++a) {
      if (ab == baudtable[a][0])
        atrbaud = baudtable[a][1];
      if (db == baudtable[a][0])
        databaud = baudtable[a][1];
    }
  }

  virtual int Open (void)
  {
    port = CreateFile (device.c_str (),
                       GENERIC_READ | GENERIC_WRITE,
                       0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if (port == INVALID_HANDLE_VALUE)
      return 0;
    setdatabaud ();

    return 1;
  }

  virtual void Close (void)
  {
    if (port != INVALID_HANDLE_VALUE) {
      CloseHandle (port);
      port = INVALID_HANDLE_VALUE;
    }
  }

  virtual int Read (uchar * buf)
  {
    int data;

    if ((data = readbyte ()) != 0x21)
      return 0;
    buf[0] = data;

    while ((data = readbyte ()) < 0);
    buf[1] = data;

    while ((data = readbyte ()) < 0);
    buf[2] = data;

    for (int a = 0; a < buf[2] + 1; ++a) {
      while ((data = readbyte ()) < 0);
      { buf[3 + a] = data;
/*      Sleep (10); */
      }
    }

    return buf[2] + 4;
  }


  virtual void Write (uchar * buf, int len)
  {
    DWORD dwWritten;
    
    if (inverse)
      for (int a = 0; a < len; ++a)
        buf[a] = flipit (buf[a]);
    WriteFile (port, buf, len, &dwWritten, NULL);
//     Sleep (1); 
  }

  virtual void WriteATR (uchar * buf, int len)
  {
    DWORD dwWritten;
    if (inverse) {
      setatrbaud ();
      WriteFile (port, buf, len, &dwWritten, NULL);
      setdatabaud ();
    }
  }
};


#else
#ifdef DJGPP

#include "pmcom/irq.h"
#include "pmcom/com.h"
#include <dpmi.h>

class commserial:public comm
{
  int databaud, atrbaud, inverse, port, address, irq;
  string device;

  void setdatabaud (void)       // 8N1
  {
    COMSetTransmitParameters (port, databaud, 8, 'N', 1);
  }

  void setatrbaud (void)        // 8O2
  {
    COMSetTransmitParameters (port, atrbaud, 8, 'O', 2);
  }

  virtual int readbyte (void)
  {
    uchar c;
    if (COMReadChar (port, (char *) &c, 0) == 0) {
      if (inverse)
        return flipit (c);
      else
        return c;
    }
    __dpmi_yield ();
    return -1;
  }

public:

  commserial (const string & d, int db, int ab, int inv, int A, int I)
:  databaud (db), atrbaud (ab), inverse (inv),
    address (A), irq (I), device (d) {
    istringstream is (device);
    is >> port;
    port -= 1;
    COMInit ();
  }

  ~commserial () {
    COMShutDown ();
  }

  virtual int Open (void)
  {
    if ((irq >= 0) && (address >= 0))
      COMSetHardwareParameters (port, irq, address);
    if (COMPortOpen (port, databaud, 8, 'N', 1, 0, 0) != 0)
      return 0;
    return 1;
  }

  virtual void Close (void)
  {
    COMPortClose (port);
  }

  virtual int Read (uchar * buf)
  {
    int data;

    if ((data = readbyte ()) != 0x21)
      return 0;
    buf[0] = data;

    while ((data = readbyte ()) < 0);
    buf[1] = data;

    while ((data = readbyte ()) < 0);
    buf[2] = data;

    for (int a = 0; a < buf[2] + 1; ++a) {
      while ((data = readbyte ()) < 0); {
         buf[3 + a] = data;

      }

    }
    __dpmi_yield();
    return buf[2] + 4;
  }


  virtual void Write (uchar * buf, int len)
  {
    if (inverse)
      for (int a = 0; a < len; ++a)
        buf[a] = flipit (buf[a]);
    COMWriteBuffer (port, (char *) buf, 0, len, 0);
  }

  virtual void WriteATR (uchar * buf, int len)
  {
    if (inverse) {
      setatrbaud ();
      COMWriteBuffer (port, (char *) buf, 0, len, 0);
      setdatabaud ();
    }
  }

};

#else

#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

const int baudtable[][2] = {
  {50, B50}, {75, B75}, {110, B110}, {134, B134}, {150, B150}, {200, B200},
  {300, B300}, {600, B600}, {1200, B1200}, {2400, B2400}, {4800, B4800},
  {9600, B9600}, {19200, B19200}, {38400, B38400}, {57600, B57600},
  {115200, B115200}, {0, 0}
};


class commserial:public comm
{
  int databaud, atrbaud, device_fd, inverse;
  string device;

  void setdatabaud (void)       // 8N1
  {
    struct termios tio;
      tcgetattr (device_fd, &tio);
      cfsetispeed (&tio, databaud);
      cfsetospeed (&tio, databaud);
      tio.c_iflag &= ~(IXON | IXOFF | IXANY | IGNBRK | BRKINT | PARMRK |
                       ISTRIP | INLCR | IGNCR | ICRNL);
      tio.c_oflag &= ~OPOST;
      tio.c_lflag &= ~(ICANON | ECHO | ECHOCTL | ISIG | IEXTEN);
      tio.c_lflag |= NOFLSH;
      tio.c_cflag &= ~(CRTSCTS | CSIZE | CSTOPB | PARODD | PARENB);
      tio.c_cflag |= CLOCAL | CREAD | CS8;
      tio.c_cc[VTIME] = 1;
      tio.c_cc[VMIN] = 0;
      tcflush (device_fd, TCIFLUSH);
      tcsetattr (device_fd, TCSANOW, &tio);
  }

  void setatrbaud (void)        // 8O2
  {
    struct termios tio;
    tcgetattr (device_fd, &tio);
    cfsetispeed (&tio, atrbaud);
    cfsetospeed (&tio, atrbaud);
    tio.c_iflag &= ~(IXON | IXOFF | IXANY | IGNBRK | BRKINT | PARMRK |
                     ISTRIP | INLCR | IGNCR | ICRNL);
    tio.c_oflag &= ~OPOST;
    tio.c_lflag &= ~(ICANON | ECHO | ECHOCTL | ISIG | IEXTEN);
    tio.c_lflag |= NOFLSH;
    tio.c_cflag &= ~(CRTSCTS | CSIZE);
    tio.c_cflag |= CLOCAL | CREAD | CS8 | CSTOPB | PARODD | PARENB;
    tio.c_cc[VTIME] = 1;
    tio.c_cc[VMIN] = 0;
    tcflush (device_fd, TCIFLUSH);
    tcsetattr (device_fd, TCSANOW, &tio);
  }

  virtual int readbyte (void)
  {
    uchar c;
    if (::read (device_fd, &c, 1) == 1) {
      if (inverse)
        return flipit (c);
      else
        return c;
    }
    //__dpmi_yield ();
    return -1;
  }

public:

  commserial (const string & d, int db, int ab, int inv, int address, int irq)
:  databaud (-1), atrbaud (-1), inverse (inv), device (d) {
    for (int a = 0; baudtable[a][0]; ++a) {
      if (ab == baudtable[a][0])
        atrbaud = baudtable[a][1];
      if (db == baudtable[a][0])
        databaud = baudtable[a][1];
    }
  }

  virtual int Open (void)
  {
    if ((device_fd =::open (device.c_str (), O_RDWR | O_NOCTTY)) <= 0) {
      cout << "Error opening " << device << "!" << endl;
      return 0;
    }
    if (databaud < 0) {
      cout << "Invalid Data Baud Rate" << endl;
      return 0;
    }
    if (atrbaud < 0) {
      cout << "Invalid Atr Baud Rate" << endl;
      return 0;
    }
    setdatabaud ();
    return 1;
  }

  virtual void Close (void)
  {
    ::close (device_fd);
  }

  virtual int Read (uchar * buf)
  {
    int data;

    if ((data = readbyte ()) != 0x21)
     	return 0;
    buf[0] = data;

    while ((data = readbyte ()) < 0);
    buf[1] = data;

    while ((data = readbyte ()) < 0);
    buf[2] = data;

    for (int a = 0; a < buf[2] + 1; ++a) {
      while ((data = readbyte ()) < 0);
//      __dpmi_yield ();
      buf[3 + a] = data;
    }
    return buf[2] + 4;
  }

  virtual void Write (uchar * buf, int len)
  {
    if (inverse)
      for (int a = 0; a < len; ++a)
        buf[a] = flipit (buf[a]);
    ::write (device_fd, buf, len);
  }

  virtual void WriteATR (uchar * buf, int len)
  {
    if (inverse) {
      setatrbaud ();
      for (int a = 0; a < len; ++a)
        buf[a] = flipit (buf[a]);
      ::write (device_fd, buf, len);
      setdatabaud ();
    }
  }
};

#endif
#endif
class commstream:public comm
{
  ifstream i;
  ofstream o;
  int okcnt, errcnt;

  uchar si[256], sv[256];
  int sil, svl;

public:

    commstream (void)
  {
  }

  virtual int Open (void)
  {
    i.open ("stream.in");
    if (!i.is_open ()) {
      cout << "Error opening stream.in" << endl;
      return 0;
    }
    o.open ("stream.out");
    if (!o.is_open ()) {
      cout << "Error opening stream.out" << endl;
      return 0;
    }
    o.fill ('0');
    o.setf (ios::uppercase);
    cout << "Stream I/O files opened" << endl;
    okcnt = 0;
    errcnt = 0;
    return 1;
  }

  virtual void Close (void)
  {
    o << "MatchCnt=" << dec << okcnt << endl;
    o << "MatchErr=" << dec << errcnt << endl;
    cout << "MatchCnt=" << dec << okcnt << endl;
    cout << "MatchErr=" << dec << errcnt << endl;
    i.close ();
    o.close ();
    sig_int (0);
  }

  virtual int Read (uchar * buf)
  {
    static int R = 0;

    ++R;
    if (R < 10)
      return 0;
    R = 0;

    char line[1024];
    int found21 = 0, found12 = 0, len;
    char temp[512];

    while (!(found21 & found12)) {
      i.getline (line, 1024);
      if (!i) {
	sig_usr1(0);
        Close ();
        exit (0);
      }
      istringstream sline (line);
      len = sline >> ba (temp, 512);

      if (temp[0] == 0x21) {
        for (int a = 0; a < len; ++a)
          si[a] = temp[a];
        sil = len;
        found21 = 1;
        found12 = 0;
      }
      if (temp[0] == 0x12) {
        for (int a = 0; a < len; ++a)
          sv[a] = temp[a];
        svl = len;
        found12 = 1;
      }
    }

    for (int a = 0; a < sil; ++a)
      buf[a] = si[a];

    // Fix CRC
    unsigned char crc = 0;
    for (int a = 0; a < sil - 1; ++a)
      crc ^= buf[a];
    buf[sil - 1] = crc;
    return sil;
  }

  virtual void Write (uchar * buf, int len)
  {
    int error = 0;
    if (len != svl)
      error = 1;
    else
      for (int a = 0; a < len; ++a)
        if (buf[a] != sv[a])
          error = 1;

    if (error) {
      errcnt++;
      o << "IRD=" << bas (si, sil) << endl;
      o << "CAM=" << bas (sv, svl) << endl;
      o << "OUT=" << bas (buf, len) << endl;
    } else
      okcnt++;
  }

  virtual void WriteATR (uchar * buf, int len)
  {
  }
};

comm *Comm = 0;

void setupcomm (const string & type, const string & port, int baud,
                int atrbaud, int address, int irq)
{
  if (port == "stream")
    Comm = new commstream ();
  else if (type == "avr")
    Comm = new commserial (port, baud, atrbaud, 0, address, irq);
  else if (type == "modserial")
    Comm = new commserial (port, baud, atrbaud, 1, address, irq);
  else {
    cout << "Unknown Port Type" << endl;
    exit (1);
  }
}

void Pat_Yield ()
{
cout << "DpmiYield" << endl;

}

#ifdef _WIN32
void PatSleep ()
{

chkmsgqteecomm++;
if (chkmsgqteecomm >= sleepqteewait) {
  
 Sleep (1);
 chkmsgqteecomm=0;
}
}
#else
void PatSleep ()
{

chkmsgqteecomm++;
if (chkmsgqteecomm >= sleepqteewait) {
    //__dpmi_yield ();
     chkmsgqteecomm=0;
}
}
#endif


