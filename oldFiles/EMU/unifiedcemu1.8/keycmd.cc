/*
Usage h/H	- HELP		Outputs Help screen
Usage c/C	- CMD		Output IRD command traffic
Usage 7		- CMD07		Output CMD07 info
Usage 6		- 6805		debug the 6805 emulator commands. This is very intensive
Usage p/P	- MAP		debug the map functions from libgmp
Usage i/I	- INPUT		Output incoming byte strings
		- OUTPUT	Output outgoing byte strings
Usage l/L	- COMM		debug low level communication
Usage r/R	- RUN		Output various info taken from a running bin (keys, etc)
Usage k/K	- KEY		Output just key info
Usage m/M	- EMM		Output EMM's that have been decoded
Usage b/B	- B1		Output B1 morph
Usage u/U	- EMU		Output B1 processing emulator, verbose output
Usage 8		- EMU_0x80	Output B1 emulator, limited to 0x80 - 0xC0, must used with EMU
Usage n/N 	- NAGRA		debug ROM102 MAPROM/MAPMEM
Usage d/D	- DEBUG		Turn on/off debug debug processing
Usage 1		- BIG_INT   	debug big_int
Usage x/X	- NONE		Turn ALL debug/output off
Usage a/A	- ALL	        Turn ALL debug/output on
Usage s/S	- LOG		Open/close dumplog and capture screen output
Usage e/E	- SAVE		Save EEPROM
*/

#include "debug.h"
#include "keycmd.h"
#include "cemu.h"
#include "emu6805.h"
#include "cmd07.h"
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "logfile.h"
#if !defined(DJGPP) && !defined(_WIN32)
#include <termios.h>
#endif
#include <unistd.h>   // for read()

#ifdef DJGPP
#include <pc.h>
#include <conio.h>
#endif

#ifdef _WIN32
#include <conio.h>
#endif

#ifdef CYGWIN                                   // under Cygwin (gcc for Windows) we
#define USE_POLL                                //  need poll() for kbhit(). Won't work otherwise.
#include <sys/poll.h>                          
#endif     

using namespace std;

std::ofstream fout;
std::streambuf* cout_sbuf = std::cout.rdbuf();

teebuf teeout(std::cout.rdbuf(), fout.rdbuf());
int on[17] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int temp_debug_x = 0;

const char Usage[] = "Usage h/H	- HELP		Outputs Help screen\r\nUsage c/C	- CMD		Output IRD command traffic\r\nUsage 7		- CMD07		Output CMD07 info\r\nUsage 6		- 6805		debug the 6805 emulator commands\r\nUsage p/P	- MAP		debug the map functions from libgmp\r\nUsage i/I	- INPUT		Output incoming byte strings\r\n		- OUTPUT	Output outgoing byte strings\r\nUsage l/L	- COMM		debug low level communication\r\nUsage r/R	- RUN		Output various info taken from a running bin\r\nUsage k/K	- KEY		Output just key info\r\nUsage m/M	- EMM		Output EMM\'s that have been decoded\r\nUsage b/B	- B1		Output B1 morph\r\nUsage u/U	- EMU		Output B1 processing emulator, verbose output\r\nUsage 8		- EMU_0x80	Output B1 emulator limited, must used with EMU\r\nUsage n/N 	- NAGRA		debug ROM102 MAPROM/MAPMEM\r\nUsage d/D	- DEBUG		Turn on/off debug debug processing\r\nUsage 1		- BIG_INT   	debug big_int\r\nUsage x/X	- NONE		Turn ALL debug/output off\r\nUsage a/A	- ALL	        Turn ALL debug/output on\r\nUsage s/S	- LOG		Open/close dumplog for screen capture\r\nUsage e/E	- SAVE		Save EEPROM";

#if !defined(DJGPP) && !defined(_WIN32)
static struct termios initial_settings, new_settings;
static int peek_character = -1;
 
void init_keyboard()
{
    tcgetattr(0,&initial_settings);
    new_settings = initial_settings;
    new_settings.c_lflag &= ~ICANON;
    new_settings.c_lflag &= ~ECHO;
    new_settings.c_lflag |= ISIG;
    new_settings.c_cc[VMIN] = 1;
    new_settings.c_cc[VTIME] = 0;
    tcsetattr(0, TCSANOW, &new_settings);
}

void close_keyboard()
{
    tcsetattr(0, TCSANOW, &initial_settings);
}


int kbhit()
{

#ifdef  USE_POLL
  struct pollfd fd;
  fd.fd = STDIN_FILENO;
  fd.events = POLLIN;
  fd.revents = 0;
  return poll (&fd, 1, 0) > 0;
#else
    unsigned char ch;
    int nread;
    if (peek_character != -1) return 1;
    new_settings.c_cc[VMIN]=0;
    tcsetattr(0, TCSANOW, &new_settings);
    nread = read(0,&ch,1);
    new_settings.c_cc[VMIN]=1;
    tcsetattr(0, TCSANOW, &new_settings);
    if(nread == 1) 
    {
        peek_character = ch;
        return 1;
    }
    return 0;
#endif
}

int readch()
{
char ch;

    if(peek_character != -1) 
    {
        ch = peek_character;
        peek_character = -1;
        return ch;
    }
    read(0,&ch,1);
    return ch;
}
#endif

void sEEP ()
{
  string f;
  f = dishfile;
  writeEEPROM (f.c_str ());
  cout << "EEPROM Saved!" << endl;
}


void dump_log ()
{
 char ttime[64]; 
 fout.open("dumplog.txt",ios::app);   
 if (fout.is_open()) {
    std::cout << "*****Dump Log " << "dumplog.txt Opened***** " << ShowTime(ttime) << endl; 

    std::cout.rdbuf(&teeout);
 } else {
       std::cerr << "Cannot write " << "dumplog.txt" << endl;
 }
 //    string f;
//     CLogFile dumplog;

    // f = strcat(datestring(),"dumplog.txt");
 //    dumplog.ChangeFile(f);
//     std::ofstream fout(f);
     //f = "dumplog.txt";
     //fout.open (f.c_str(),ios::app);

}

void close_log()
{  
   char ttime[64];
   if (fout.is_open ()) {
      std::cout << "*****Dump Log Closed***** " << ShowTime(ttime) << endl;
      std::cout.rdbuf(cout_sbuf);
      fout.close();
     }
   else
      std::cout << "Error Closing Dump Log" << endl;
}


void keycmd()
{  
    char c;
    char ttime[64];

    if (kbhit()) {
#if !defined(DJGPP) && !defined(_WIN32)
          c = readch();
#else
	  c = getch();
#endif
    switch (c) {
      case 's':
      case 'S':
        if (!on[0]) {
	  dump_log();
	  on[0] = 1;
	  }
	else {
	  close_log();
	  on[0] = 0;
 	  }
	break;  
      case '6':
        if (!on[1]) {
	  cout << "****6805_CPU DEBUGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_6805;
	  on[1] = 1;
	  }
	else {
	  cout << "****6805_CPU DEBUGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_6805;
	  on[1] = 0;
 	  }        
        break;    
      case 'c':
      case 'C':
        if (!on[2]) {
	  cout << "****CMD LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_CMD;
	  on[2] = 1;
	  }
	else {
	  cout << "****CMD LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_CMD;
	  on[2] = 0;
 	  }
        break;
      case '7':
	if (!on[3]) {
	  cout << "****CMD07 LOGGING ON**** " << ShowTime(ttime) << endl;
	  SetLog(1);
          debug_x |= DEBUG_CMD07;
	  on[3] = 1;
	  }
	else {
	  cout << "****CMD07 LOGGING OFF**** " << ShowTime(ttime) << endl;
	  SetLog(0);
	  debug_x ^= DEBUG_CMD07;
	  on[3] = 0;
 	  }	
        break;
      case 'i':
      case 'I':
	if (!on[4]) {
	  cout << "****INPUT/OUTPUT LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_IN;
  	  debug_x |= DEBUG_OUT;
	  on[4] = 1;
	  }
	else {
	  cout << "****INPUT/OUTPUT LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_IN;
	  debug_x ^= DEBUG_OUT;
	  on[4] = 0;
 	  }	        
        break;
      case 'l':
      case 'L':
        if (!on[5]) {
	  cout << "****COMM LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_COMM;
	  on[5] = 1;
	  }
	else {
	  cout << "****COMM LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_COMM;
	  on[5] = 0;
 	  }	     
        break;
      case 'b':
      case 'B':
        if (!on[6]) {
	  cout << "****B1 LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_B1;
	  on[6] = 1;
	  }
	else {
	  cout << "****B1 LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_B1;
	  on[6] = 0;
 	  }
        break;
      case 'm':
      case 'M':
        if (!on[7]) {
	  cout << "****EMM LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_EMM;
	  on[7] = 1;
	  }
	else {
	  cout << "****EMM LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_EMM;
	  on[7] = 0;
 	  }
        break;
      case 'k':
      case 'K':
        if (!on[9]) {
	  cout << "****KEY LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_KEY;
	  on[9] = 1;
	  }
	else {
	  cout << "****KEY LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_KEY;
	  on[9] = 0;
 	  }
        break;
      case 'u':
      case 'U':
        if (!on[10]) {
	  cout << "****VERBOSE MORPH EMULATOR DEBUGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_EMU;
	  on[10] = 1;
	  }
	else {
	  cout << "****VERBOSE MORPH EMULATOR DEBUGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_EMU;
	  on[10] = 0;
 	  }
        break;
      case '8':
        if (!on[11]) {
	  cout << "****LIMITED MORPH EMULATOR DEBUGGING ON**** " << ShowTime(ttime) << endl;
//	  debug_x |= DEBUG_EMU;
	  debug_x |= DEBUG_EMU_0x80;
	  on[11] = 1;
	  }
	else {
	  cout << "****LIMITED MORPH EMULATOR DEBUGGING OFF**** " << ShowTime(ttime) << endl;
//	  debug_x ^= DEBUG_EMU;
	  debug_x ^= DEBUG_EMU_0x80;
	  on[11] = 0;
 	  }
        break;
      case 'r':
      case 'R':
        if (!on[12]) {
	  cout << "****RUNNING BIN INFO LOGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_RUN;
	  on[12] = 1;
	  }
	else {
	  cout << "****RUNNING BIN INFO LOGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_RUN;
	  on[12] = 0;
 	  }
        break;
      case '1':
        if (!on[13]) {
	  cout << "****BIG_INT DEBUGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_BIG;
	  on[13] = 1;
	  }
	else {
	  cout << "****BIG_INT DEBUGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_BIG;
	  on[13] = 0;
 	  }
        break;
      case 'p':
      case 'P':
        if (!on[14]) {
	  cout << "****LIBGMP MAP FUNCTION DEBUGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_MAP;
	  on[14] = 1;
	  }
	else {
	  cout << "****LIBGMP MAP FUNCTION DEBUGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_MAP;
	  on[14] = 0;
 	  };
        break;
      case 'd':
      case 'D':
        if (!on[15]) {
	  cout << "****DEBUG DEBUGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_DEBUG;
	  on[15] = 1;
	  }
	else {
	  cout << "****DEBUG DEBUGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_DEBUG;
	  on[15] = 0;
 	  }
        break;
      case 'n':
      case 'N':
        if (!on[16]) {
	  cout << "****ROM102 MAP DEBUGGING ON**** " << ShowTime(ttime) << endl;
	  debug_x |= DEBUG_NAGRA;
	  on[16] = 1;
	  }
	else {
	  cout << "****ROM102 MAP DEBUGGING OFF**** " << ShowTime(ttime) << endl;
	  debug_x ^= DEBUG_NAGRA;
	  on[16] = 0;
 	  }
        break;
      case 'a':
      case 'A':
	cout << "****Enable All****" << endl ;
        debug_x |= DEBUG_ALL;
        break;
      case 'x':
      case 'X':
         cout << "****Disable All****" << endl ;
	 debug_x = 0;
	 for (int a = 0; a < 18; a++)
	    on[a] = 0; 
         break;
      case 'e':
      case 'E':
	 cout << "****SAVING EEPROM**** " << ShowTime(ttime) << endl;
	 sEEP ();
        break;
      case 'h':
      case 'H':
	if (!on[17]) {
	  cout << Usage << "\r\nType 'H' or 'h' to return to logging" << endl;
	  temp_debug_x = debug_x;
	  debug_x = 0;
	  on[17] = 1;
	  }
	else {
	  on[17] = 0;
 	  debug_x = temp_debug_x;
          }	
 	break;
      default:
        cout << Usage << endl;
        break;
    }
 } 

}

