/* Please ADD your comments if you modify the code
 * SVP. Ajouter vos commentaire si vous modifier le code
 *
 * Programme origanellemet écrit par SPM
 * Mise à jour de CEMU pour intégrer les modification dans JAVAEMU0.43 de IHATEALIASES fait par RealityMan
 * Utilisitation du model HUGE RealityMan
 * Ajout de la fonction MAP_FUNCTION pour le déencryptage RealtyMan 
 * Ajout des fonctions de communication RS232 -=Digit=-
 * Mise a jour pour JAVAEMU 0.7 (single thread for the moment) RealityMan ( Thanks to Voltaic and IHateAliases)
 * Update to version 0.7 JavaEmu and release version RealityMan. 
 * Convert from TC to DJGPP compiler. RealityMan aka RMA
 * Add support at the version REV380
 * Add EMM Decryption (Only works if keys match provider)  - GreenGiant and Punkd
 * Add Autoroll for rom10to102 - GreenGiant and Punkd
 * Updated Autoroll to handle B1 Morph-Updated Map3b - Docdude *** much help from authors Emunation
 * Added EMM decryption for primary provider 0001/0801, now hardcoded for speed - Docdude
 * Added keyboard cmds and better logging functions - Docdude
 * Cross-platform/compiler compatability - LazyBastard and Docdude
 * Added Active Key Display - Overnite and Daemons
 * Fixed Autoroll Routines - MegaHambone and Overnite
 * Added ghetoroll in case autoroll goes down - Coward
 * Added ghetoroll for 0905 and 0906 Provider Keys - Coward
 * Added bootdisk option to read and write keys from A: Floppy Drive (dos bootdisk users only) - Overnite
 * Added Dynamic Timezones, removed "Daylight" option from cemu.cnf, no longer needed - Overnite
 * "fixed" the eep(xx)_102.bin missing or corrupted error - Coward and Overnite
 * Added Apr11/07 Fix - LazyBastard
 * Config file naming improved. cemu.cnf for DOS only, cemu.conf for non 8.3 - LazyBastard
 * Log file naming sanity - emm.log, stream.log - LazyBastard
 * Session key file naming sanity - session.key - LazyBastard
 * Moved Map Call from Run() in morph_cpu.cc and placed it in morph2.h for expandability. - MegaHambone (Docdude's idea)
 * Renamed version with U suffix to denote Unified Codebase (Version Control Experiment) - MegaHambone
 *
*/

#ifdef _WIN32
#include <windows.h>
#endif

#include <signal.h>
#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "comm.h"
#include "emmhelper.h"
#include "stdio.h"
#include "keycmd.h"
#include <sstream>

/**
 Variable definitions
*/

char *version = "10B v1.81U AutoRoll"; 

/* Variables Used/Set by configuration File */
#ifdef DJGPP
	string inifile ("cemu.cnf");
#else
	string inifile ("cemu.conf");
#endif
string romfile;
string dishfile;
string tierfile;

struct buffer in, out;


int cmdforkeys = 0xb1;
int ghetoroll = 0;
int originalghetoroll = 0;
int bootdisk = 0;
int firstrun = 1;
string stf86 = "42001006080010";
string stf96 = "42001046080010";
char strtofind86[120]=     "42001006080010";
char strtofind96[120]="42001046080010";
uint offsetkey86 = 14;
uint offsetkey96 = 14;

int altcmdforkeys = 0xb1;
char altstrtofind86[120]=     "42001006080010";
char altstrtofind96[120]="42001046080010";
uint altoffsetkey86 = 14;
uint altoffsetkey96 = 14;

int buffcmdforkeys = 0xb1;
char buffstrtofind86[120]=     "42001006080010";
char buffstrtofind96[120]="42001046080010";
uint buffoffsetkey86 = 14;
uint buffoffsetkey96 = 14;
string portdev="";

char* strtofindb1_86 = "42001006080010";
char* strtofindb1_96 = "42001046080010";




int sleepqteewait = 50;
int chkmsgqtee = 0;
int chkmsgqteecomm = 0;


string streamlogfile ("stream.log");
string emmlogfile ("emm.log");
uint camid = 0;
uint irdid = 0;
uint64 boxkey = 0;
uint64 key0 = 0;
uint64 key1 = 0;
uchar blackout[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
uint tz = 0;
uint zip = 0;
uint DayLight = 0;
uint NoSave = 0;
uint debug_x = 0;
volatile uint Break = 0;
uint Debugging = 0;
uint Debugstat = 0;
int nbprecomp = 10;
int checkdelaykey = 30;
uint sessionkeyfile = 0;

int readBinaryFile (const char *filename, uint startAddr)
{
  ifstream f (filename, ios::binary);
  if (!f.is_open ()) {
    cout << "\n" << "File " << filename << " not found!" << "\n";
    return -1;
  }
  f.seekg (0, ios::end);
  int length = f.tellg ();
  f.seekg (0, ios::beg);
  f.read ((char *) memory.m + startAddr, length);
  f.close ();
  return length;
}

void writeEEPROM (const char *filename)
{
  ofstream f (filename, ios::binary);
  if (!f.is_open ()) {
    cout << "\n" << "Unable to open " << filename << " for writing!" << "\n";
    return;
  }
  if (RomVer == 3)
    f.write ((char *) &memory.m[0xE000], 0x1000);
  if (RomVer == 10)
    f.write ((char *) &memory.m[0xC000], 0x2000);
  if (RomVer == 11)
    f.write ((char *) &memory.m[0xC000], 0x2000);
  if (RomVer == 101)
    f.write ((char *) &memory.m[0xC000], 0x2000);
  f.close ();
}

void sig_usr1 (int unused)
{
  writeEEPROM (dishfile.c_str ());
  cout << "EEPROM Saved!" << "\n";
}

void sig_int (int unused)
{
	cout << "SigInt Received." << "\n";
	if (!NoSave){
		writeEEPROM (dishfile.c_str ());
		cout << "EEPROM Saved!" << "\n";
	}
	Break = 1;
#if !defined(DJGPP) && !defined(_WIN32)
        if(!Debugstat) close_keyboard();
#endif
}

void sig_usr2 (int unused)
{
	cout << "SigUsr2 Received" << "\n";
  debug_x ^= DEBUG_6805;
}

int setUpROM ()
{
  for (int a = 0x0; a < 0xFFFF; a++)
    memory.m[a] = 0x00;

//        Load ROM Binary Into Memory

  int EepLoc = 0;
  int RomLoc = 0x4000;
  int RomSize = readBinaryFile (romfile.c_str (), RomLoc); 
  if (RomSize == 0x4000){
    RomVer = 3;
	  EepLoc = 0xE000;
  }
  else if (RomSize == 0x6000) {
	  EepLoc = 0xC000;
    if (memory.m[0x400F] == 0x06)
      RomVer = 10;
    else if (memory.m[0x400F] == 0x20)
      RomVer = 11;
    else if (memory.m[0x400F] == 0x55)
      RomVer = 101;
    else
      return -1;
  } else
    return -1;
//    RomVer = 101;
  cout << "ROM Version : " << dec << RomVer << "\n";
  cout << "ROM FILE    : " << romfile << " = " << h16 << RomLoc << " to "
    << h16 << RomLoc + RomSize - 1 << "\n";

/*  
//        *  Load EEPROM Image Into Memory
*/
  /* Optimized/Moved to above IF statement
  if (RomVer == 3)
    EepLoc = 0xE000;
  if (RomVer == 10)
    EepLoc = 0xC000;
  if (RomVer == 11)
    EepLoc = 0xC000;
  if (RomVer == 101)
    EepLoc = 0xC000;
*/
  int EepSize = readBinaryFile (dishfile.c_str (), EepLoc);
  if (EepSize < 0)
    return -1;
  cout << "EEPROM FILE : " << dishfile << " = " << h16 << EepLoc << " to "
    << h16 << EepLoc + EepSize - 1 << "\n";

 initEMU ();
  return 0;
}


void ReloadROM ()
{
  for (int a = 0x0; a < 0xFFFF; a++)
    memory.m[a] = 0x00;

  int RomLoc = 0x4000;
  int RomSize = readBinaryFile (romfile.c_str (), RomLoc);
  if (RomSize == 0x4000)
    RomVer = 3;
  else if (RomSize == 0x6000) {
    if (memory.m[0x400F] == 0x06)
      RomVer = 10;
    else if (memory.m[0x400F] == 0x20)
      RomVer = 11;
    else if (memory.m[0x400F] == 0x55)
      RomVer = 101;
  }
  
  int EepLoc = 0;
/*  if (RomVer == 3)
    EepLoc = 0xE000;
  if (RomVer == 10)
    EepLoc = 0xC000;
  if (RomVer == 11)
    EepLoc = 0xC000;
  if (RomVer == 101)
    EepLoc = 0xC000;

*/
    EepLoc = 0xC000;

 readBinaryFile (dishfile.c_str (), EepLoc);
 
  


}

//Support if autoroll routine changes
void infokey ()
{
if (bootdisk == 0){

    ifstream f3 ("reload.key");
    if (f3.is_open ()) {
  ifstream f ("86.key");
    if (f.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd863] = (ascHexToInt(f.get()) * 16 )+ ascHexToInt(f.get());
	  }
   f.close ();
  }

  ifstream f2 ("96.key");
  if (f2.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd873] = (ascHexToInt(f2.get()) * 16 )+ ascHexToInt(f2.get());
	  }
   f2.close ();


   D_KEY << "0901 Idea Key0 (86) : " << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << "\n";
   D_KEY << "0901 Idea Key1 (96) : " << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << "\n";
   f3.close ();
   remove( "reload.key" );
  
  }
  }
}




if (bootdisk == 1){

    ifstream f3 ("a:\\reload.key");
    if (f3.is_open ()) {
  ifstream f ("a:\\86.key");
    if (f.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd863] = (ascHexToInt(f.get()) * 16 )+ ascHexToInt(f.get());
	  }
f.close ();
  }

  ifstream f2 ("a:\\96.key");
  if (f2.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd873] = (ascHexToInt(f2.get()) * 16 )+ ascHexToInt(f2.get());
	  }
f2.close ();


   D_KEY << "0901 Idea Key0 (86) : " << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << "\n";
   D_KEY << "0901 Idea Key1 (96) : " << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << "\n";
   f3.close ();
   remove( "a:\\reload.key" );
  
  }
  }
}

}

void infokey905 ()
{
if (bootdisk == 0){

    ifstream f3 ("reload.key");
    if (f3.is_open ()) {
  ifstream f ("86_0905.key");
    if (f.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd863] = (ascHexToInt(f.get()) * 16 )+ ascHexToInt(f.get());
	  }
f.close ();
  }

  ifstream f2 ("96_0905.key");
  if (f2.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd873] = (ascHexToInt(f2.get()) * 16 )+ ascHexToInt(f2.get());
	  }
f2.close ();


   D_KEY << "0905 Idea Key0 (06) : " << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << "\n";
   D_KEY << "0905 Idea Key1 (46) : " << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << "\n";
   f3.close ();
   remove( "reload.key" );
  
  }
  }
}




if (bootdisk == 1){

    ifstream f3 ("a:\\reload.key");
    if (f3.is_open ()) {
  ifstream f ("a:\\86_0905.key");
    if (f.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd863] = (ascHexToInt(f.get()) * 16 )+ ascHexToInt(f.get());
	  }
f.close ();
  }

  ifstream f2 ("a:\\96_0905.key");
  if (f2.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd873] = (ascHexToInt(f2.get()) * 16 )+ ascHexToInt(f2.get());
	  }
f2.close ();


   D_KEY << "0905 Idea Key0 (06) : " << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << "\n";
   D_KEY << "0905 Idea Key1 (46) : " << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << "\n";
   f3.close ();
   remove( "a:\\reload.key" );
  
  }
  }
}

}

void infokey906 ()
{
if (bootdisk == 0){

    ifstream f3 ("reload.key");
    if (f3.is_open ()) {
  ifstream f ("86_0906.key");
    if (f.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd863] = (ascHexToInt(f.get()) * 16 )+ ascHexToInt(f.get());
	  }
f.close ();
  }

  ifstream f2 ("96_0906.key");
  if (f2.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd873] = (ascHexToInt(f2.get()) * 16 )+ ascHexToInt(f2.get());
	  }
f2.close ();


   D_KEY << "0906 Idea Key0 (06) : " << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << "\n";
   D_KEY << "0906 Idea Key1 (46) : " << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << "\n";
   f3.close ();
   remove( "reload.key" );
  
  }
  }
}




if (bootdisk == 1){

    ifstream f3 ("a:\\reload.key");
    if (f3.is_open ()) {
  ifstream f ("a:\\86_0906.key");
    if (f.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd863] = (ascHexToInt(f.get()) * 16 )+ ascHexToInt(f.get());
	  }
f.close ();
  }

  ifstream f2 ("a:\\96_0906.key");
  if (f2.is_open ()) {
	  for (int a = 0; a < 16; a++){
		  memory.m[a+0xd873] = (ascHexToInt(f2.get()) * 16 )+ ascHexToInt(f2.get());
	  }
f2.close ();


   D_KEY << "0906 Idea Key0 (06) : " << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << "\n";
   D_KEY << "0906 Idea Key1 (46) : " << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << "\n";
   f3.close ();
   remove( "a:\\reload.key" );
  
  }
  }
}

}

void outkey (int keynum){
	if (bootdisk == 0)
	{
	
	FILE *f;
	if (keynum == 86){
		if ((f = fopen ("86.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd863]);
			fclose(f);
		}
	} else if (keynum == 96){
		if ((f = fopen ("96.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd873]);
			fclose(f);
		}
	} else {
		if ((f = fopen ("86.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd863]);
			fclose(f);
		}
		if ((f = fopen ("96.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd873]);
			fclose(f);
		}
	}
}

if (bootdisk == 1)
	{
	
	FILE *f;
	if (keynum == 86){
		if ((f = fopen ("a:\\86.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd863]);
			fclose(f);
		}
	} else if (keynum == 96){
		if ((f = fopen ("a:\\96.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd873]);
			fclose(f);
		}
	} else {
		if ((f = fopen ("a:\\86.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd863]);
			fclose(f);
		}
		if ((f = fopen ("a:\\96.key","w"))!=NULL){
			for (int a=0; a<16; a++)
				fprintf(f,"%02X",memory.m[a+0xd873]);
			fclose(f);
		}
	}
}


}


int readProperties (void)
{
  int baud_rate = 115200, atr_baud_rate = 9600;
  string port_dev ("/dev/ttyS0"), port_type ("avr");
  int address = -1, irq = -1;
  struct debug_opts
    {
     char *command;
     uint flag;
    }
  opts[] = {
    {
    "NONE", DEBUG_NONE}
    , {
    "BIG_INT", DEBUG_BIG}
    , {
    "CAM", DEBUG_CAM}
    , {
    "SAVE", DEBUG_SAVE}
    , {
    "6805", DEBUG_6805}
    , {
    "MAP", DEBUG_MAP}
    , {
    "ROM3", DEBUG_ROM}
    , {
    "NYI", DEBUG_NYI}
    , {
    "OUTPUT", DEBUG_OUT}
    , {
    "INPUT", DEBUG_IN}
    , {
    "CMD", DEBUG_CMD}
    , {
    "COMM", DEBUG_COMM}
    , {
    "RUN", DEBUG_RUN}
    , {
    "KEY", DEBUG_KEY}
    , {
    "DEBUG", DEBUG_DEBUG}
    , {
    "EMM", DEBUG_EMM}
    , {
    "CMD07", DEBUG_CMD07}
    , {
    "ALL", DEBUG_ALL}
    , {
    "B1", DEBUG_B1}
    , {
    "EMU", DEBUG_EMU}
    , { 
    "EMU_0x80", DEBUG_EMU_0x80}
    , { 
    "NAGRA", DEBUG_NAGRA}
    , {
    NULL, 0}
    , };
  

  ifstream keyfile ("keys.cnf");
  if (keyfile.is_open ()) {
    keyfile >> hex >> key0 >> key1;
    keyfile.close ();
  }

  ifstream infile (inifile.c_str ());
  char line[512] = "";  

  if (!infile.is_open ()) {
    cout << "\n" << "File " << inifile << " not found" << "\n";
    return 1;
  }

  for (infile.getline (line, 512); !!infile; infile.getline (line, 512)) { //old value 512
    if (line[0] != '#') {
      istringstream sline (line);
      string token;
      sline >> token;

      if (token == "baud")
        sline >> dec >> baud_rate;

      if (token == "atrbaud")
        sline >> dec >> atr_baud_rate;

      if (token == "debug") {
        string s;
        for (sline >> s; !!sline; sline >> s) {
          if (s == "none")
            debug_x = 0;
          else
            for (int a = 0; opts[a].command; ++a) {
              if (s == opts[a].command) {
                debug_x |= opts[a].flag;
		    //Set configuration file debug tokens and initialize key cmd on status
		    switch (opts[a].flag) {
     		      case 16:		//DEBUG_6805
			  on[1] = 1;
		      break;    
		      case 1024:     	//DEBUG_CMD
			  on[2] = 1;
		      break;
		      case 65536:	//DEBUG_CMD07
			  on[3] = 1;
		      break;
		      case 256:		//DEBUG_IN,DEBUG_OUT
		      case 512:
			  on[4] = 1;
		      break;
		      case 2048:	//DEBUG_COMM
			  on[5] = 1;
		      break;
		      case 131072:	//DEBUG_B1
			  on[6] = 1;
		      break;
		      case 32768:	//DEBUG_EMM
			  on[7] = 1;
		      break;
		      case 8192:	//DEBUG_KEY
			  on[9] = 1;
		      break;
		      case 262144:	//DEBUG_EMU
			  on[10] = 1;
		      break;
		      case 524288:	//DEBUG_EMU_0x80
			  on[11] = 1;
		      break;
		      case 4096:	//DEBUG_RUN
			  on[12] = 1;
		      break;
		      case 2:		//DEBUG_BIG
			  on[13] = 1;
	              break;
		      case 32:		//DEBUG_MAP
			  on[14] = 1;
		      break;
		      case 16384:	//DEBUG_DEBUG
			  on[15] = 1;
		      break;
		      case 1048576:	//DEBUG_NAGRA
			  on[16] = 1;
		      break;
		}
            }
          }
        }
      }

	  if (token == "port"){
        sline >> port_dev;
                   if ((toupper(port_dev[0]) == 'C') && (toupper(port_dev[1]) == 'O') && (toupper(port_dev[2]) == 'M')){
			//Since dos cant handle 'COMX', we simply detect for it, and replace it with the number only.
			port_dev = (int) port_dev[3];
                        #ifdef _WIN32
                           port_dev = "COM"+ port_dev;
                        #endif

		}

                cout << "Using port: " << port_dev << "\n";
                portdev=port_dev;
               
	  }

      if (token == "address")
        sline >> hex >> address;

      if (token == "irq")
        sline >> dec >> irq;

      if (token == "rombin")
        sline >> romfile;

      if (token == "dishbin")
        sline >> dishfile;

 	if (token == "tz") {
 	string TZ;
 	sline >> TZ;
 	  if (TZ == "alaska")
            tz = 0xdd;
          if (TZ == "eastern")
            tz = 0xed;
          if (TZ == "central")
            tz = 0xe9;
          if (TZ == "mountain")
            tz = 0xe5;
          if (TZ == "pacific")
            tz = 0xe1;
          if (TZ == "atlantic")
            tz = 0xf1;
          if (TZ == "newfounland")
            tz = 0xf3;
          if (TZ == "honolulu")
            tz = 0xd9;
      }
      
      
      
      if (token == "zip")
        sline >> dec >> zip;

      if (token == "NoSave")
        sline >> dec >> NoSave;

      if (token == "cmdforkeys")
        sline >>  hex >> cmdforkeys;

      if (token == "debugging")
        sline >> dec >> Debugging;
	Debugstat = Debugging;

          if (token == "EMMLOG")
        sline >> EMMLOG;
	  if (token == "STREAMLOG")
        sline >> STREAMLOG;
          if (token == "sendatrreset")
        sline >> atrreset;
          if (token == "sendatrstart")
        sline >> atrstart;
          if (token == "nbprecomp")
        sline >> nbprecomp;
          if (token == "sleepqteewait")
        sline >> sleepqteewait;
            if (token == "checkdelaykey")
        sline >> checkdelaykey;

        if (token == "stringtofind86")
          sline >>  strtofind86;
        if (token == "stringtofind96")
          sline >>  strtofind96;

          if (token == "offsetkey86")
        sline >> dec >> offsetkey86;
          if (token == "offsetkey96")
        sline >> dec >> offsetkey96;

        if (token == "altstringtofind86")
          sline >>  altstrtofind86;
        if (token == "altstringtofind96")
          sline >>  altstrtofind96;

          if (token == "altoffsetkey86")
        sline >> dec >> altoffsetkey86;
          if (token == "altoffsetkey96")
        sline >> dec >> altoffsetkey96;

      if (token == "streamlog") {
              if (!!sline)
                sline >> streamlogfile;
              }
            if (token == "emmlog") {
              if (!!sline)
                sline >> emmlogfile;
              }
            if (token == "ghetoroll") {
              if (!!sline)
                sline >> ghetoroll;
                
              }
              if (ghetoroll == 1)
              {
              originalghetoroll = 1;
              }
              if (ghetoroll == 0)
              {
              originalghetoroll = 0;
              }
            if (token == "bootdisk") {
              if (!!sline)
                sline >> bootdisk;
              }

/*       streamlog.open (streamlogfile.c_str ());

       streamlog.setf (ios::uppercase);
        if (streamlog.is_open ())
          cout << "Stream Log Opened" << "\n";
        else
          cout << "Error Opening Stream Log" << "\n";
     }
*/
      if (token == "protocol")
        sline >> port_type;
      if (token == "sessionkey")
        sline >> dec >> sessionkeyfile;
    }
  }
  infile.close ();
  setupcomm (port_type, port_dev, baud_rate, atr_baud_rate, address, irq);
  return 0;
}

int main (int argc, char **argv)
{
  
  int retCode;
  FILE * pFile;
  cout.fill ('0');
  cout.setf (ios::uppercase);
  
  cout << " --- !!! FREEWARE !!! ---" << "\n"<<"\n";
  cout << "Cemu " << version << "\n" ;
  cout << "See the cemu.cnf for parameters" << "\n" ;
  cout << "Now with Autoroll and Ghetoroll" << endl;
  cout << "Now with Dynamically Changing Timezones" << endl;
  cout << "\n" << "For use with Rom102to10 bin" <<"\n";
  cout << "\n" << " --- !!! FREEWARE !!! ---" << "\n"<<"\n";




  if (argc > 1)
      inifile = argv[1];
  
    retCode = readProperties ();
    pFile = fopen ("reload.key","w");
    fclose(pFile);    
  
  if (bootdisk == 1)
  {
  pFile = fopen ("a:\\reload.key","w");
  fclose(pFile);
  }  
  
    if (retCode != 0)
      return retCode;
  
  signal (SIGINT, sig_int);
  
#ifdef _WIN32
  SetPriorityClass (GetCurrentProcess (), HIGH_PRIORITY_CLASS); 
#else
#ifndef DJGPP
  signal (SIGUSR1, sig_usr1);
  signal (SIGUSR2, sig_usr2);
#endif
#endif

  if (!Comm->Open ()) {
    cout << "Unable to open serial port!" << "\n";
    return (1);
  }


  retCode = setUpROM ();

  Comm->Close ();

  sig_int (0);

  return (retCode);
}
