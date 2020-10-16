/*
*  function for specific data 
*/

#include <time.h>
#include "cemu.h"
#include "6805_cpu.h"
#include "emu6805.h"
#include "comm.h"
#include "cmd07.h"
#include "common.h"
#include <fstream>
#include <iostream>
#include <iomanip>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include "logfile.h"
#include "keycmd.h"
#include "keysets.h"
#include "morph2.h"

int DataSpacePTR = 0;

int DataSpaceEnd = 0;
int atrstart;
int atrreset;

char EMMG_0901[193];
char N_0901[193];
char D_0901[193];

char EMMG_0801[193];
char N_0801[193];
char D_0801[193];

char EMMG_0101[193];
char N_0101[193];
char D_0101[193];

char EMMG_0001[193];
char N_0001[193];
char D_0001[193];

int EMMLOG;
int STREAMLOG;

int bidoncmd;
int bidoncmpt=0;
int switchmethode=0;
int const startEmmIndex = 15;  //Index of where the emm starts in the incoming data offset

int emmProvider = 0;           //Holds the provider, 0101, 0901 etc
int ecmKeySelect = 0;		//Holds the value of the active key
int oldecmKeySelect = 0;        //old vs new, for detecting active key changes
int oldEmmProvider = 0;        //old vs new, for detecting when to change keys
int emmKeySelect = 0;          //Holds the keyselect, such as 820090 

char payloadStr[192] = "";     //Payload from EMM in hex string format, byteswapped
int payload[96];               //payloadStr in byte format, byteswapped 

char emmRsa1[192] = "";        //Emm as str after rsa round 1 
uint8_t emmRsa1Bytes[96];          //emmRsa1 in bytes format

char decEmmAsString[192] = ""; //Final decrypted EMM in Hex String format
string decEmm_str;


char b1[156];			//b1 as string, unprocessed
uint8_t b1_Emm[96];		//b1 in bytes format
char b1_morphed[156];		//processed b1 after morph
char b1_other[156];		//other b1
char b1sig[10];			//holder b1 signature

CLogFile emmlog;		
CLogFile strmlog;
cN2Emu B1Morph;

int methodA = 0;                //0 for unknown  1 for 820010   2 for 820090
int pad86 = 0;
int pad96 = 0;
int valtmp = 0;
int needupdate = 0;
uchar rspfnc07[8] = {0x12,0x0,0x4,0x87,0x0,0x90,0x0,0x1};
time_t time_start,time_now;
double time_diff;




#if !defined(CYGWIN) || defined(_WIN32)
int strlcpy( char *dst, const char *src, size_t siz )
    {
    register char* d = dst;
    register const char* s = src;
    register size_t n = siz + 1;
    /* Copy as many bytes as will fit */
    if (n != 0 && --n != 0)
        {
        do
            {
            if ((*d++ = *s++) == 0)
                break;
            } while ( --n != 0 );
        }

    /* Not enough room in dst, add NUL and traverse rest of src */
    if (n == 0)
        {
        if (siz != 0)
             *d = '\0'; /* NUL-terminate dst */

        while (*s++)
        ;
        }

    return (s - src - 1); /* count does not include NUL */
    }
#endif

class database
    {
    public:

    int start, end, len;
    int item[256], num;
    int firstfree;

    void enumerate()
        {
        num = 0;

        for ( int Z = start; Z < end; Z += memory[Z + 1] + 2 )
            if (memory[Z] == 0x07)
                item[num++] = Z;
        }

    void defrag( void )
        {
        uchar* m = new uchar[len];
        int Z = 0;

        for ( int a = 0; a < num; ++a )
            if (item[a])
                {
                for ( int b = 0; b < memory[item[a] + 1] + 2; ++b )
                    m[Z + b] = memory[item[a] + b];

                Z += memory[item[a] + 1] + 2;
                }

        firstfree = start + Z;

        while (Z < len)
            {
            int L = len - Z;

            if (L == 0x101)
                L = 0xFF;

            if (L > 0x100)
                L = 0x100;

            m[Z] = 0x0f;
            m[Z + 1] = L - 2;

            for ( int a = 2; a < L; ++a )
                m[Z + a] = 0;

            Z += L;
            }

        for ( int a = 0; a < len; ++a )
            memory[start + a] = m[a];

        delete m;
        }

    void additem( int type, int length, uchar *data )
        {
        enumerate();
        defrag();
        enumerate();

        item[num++] = firstfree;
        memory[firstfree++] = 0x07;
        memory[firstfree++] = length + 1;
        memory[firstfree++] = type;

        for ( int a = 0; a < length; ++a )
            memory[firstfree++] = data[a];

        defrag();
        }

    void removeall( int type )
        {
        enumerate();

        for ( int a = 0; a < num; ++a )
            if (memory[item[a] + 2] == type)
                item[a] = 0;

        defrag();
        }

    int readfile( string fname )
        {
        ifstream f(fname.c_str());

        if (!f.is_open())
            {
            cout << "Cannot open " << fname << "!" << endl;
            return 0;
            }

        char line[1024];

        for ( f.getline(line, 1024); !!f; f.getline(line, 1024) )
            if (line[0] == '!')
                {
                istringstream l(line + 1);
                string command;
                l >> command;

                if (command == "defrag")
                    {
                    enumerate();
                    defrag();
                    }
                else if (command == "removeall")
                    {
                    int type;

                    for ( l >> hex >> type; !!l; l >> type )
                        removeall(type);
                    }
                else if (command == "consolidate")
                    {
                    }
                else if (command == "add")
                    {
                    uchar type, length;
                    string data;
                    l >> ba(&type, 1);
                    l >> ba(&length, 1);
                    l >> data;
                    uchar d[256];
                    istringstream sdata(data);
                    sdata >> ba(d, length);
                    additem(type, length, d);
                    }
                else
                    cout << command << endl;
                }

        f.close();
        return 1;
        }

    void print()
        {
        enumerate();
        int count06 = 0;

        for ( int a = 0; a < num; ++a )
            {
            int Z = item[a];
            /*    D_RUN << "Item: " << h8 << (int) memory[Z]
                    << " " << h8 << (int) memory[Z + 1]
                    << " " << h8 << (int) memory[Z + 2]
                    << " " << ba (Z + 3, memory [Z + 1] - 1) << endl;*/
            switch( memory[Z + 2] )
                {
                case 0x01: // Ird Info
                    D_RUN << "Zip Code    : " << dec << memory.g32(Z + 7) << endl;
                    D_RUN << "Time Zone   : " << h8 << memory.g8(Z + 11) << endl;
                    D_RUN << "IrdID       : R" << dec << setw(10) << memory._g32(Z + 13) << "    0x" << h32
                        << memory._g32(Z + 13) << endl;
                    D_RUN << "Box Keys    : " << h64 << memory.g64(Z + 33) << endl;
                    break;

                case 0x06: // Provider Info
                    D_RUN << "CamID       : S" << dec << setw(10) << memory.g32(Z + 6) << "    0x" << h32
                        << memory.g32(Z + 6) << endl;
                    D_RUN << "Blackout    : " << ba(Z + 30, 12) << endl;
                    D_RUN << "Key0        : " << ba(Z + 42, 8) << endl;
                    D_RUN << "Key1        : " << ba(Z + 50, 8) << endl;

                    if ((++count06) == 2)
                        {
                        key0 = memory.g64(Z + 42);
                        key1 = memory.g64(Z + 50);
                        ofstream keyfile("keys.cnf");
                        keyfile << hex << key0 << endl << key1 << endl;
                        keyfile.close();
                        }

                    break;
                }
            }
        }

    void update( void )
        {
        enumerate();
        int count06 = 0;

        for ( int a = 0; a < num; ++a )
            {
            int Z = item[a];

            switch( memory[Z + 2] )
                {
                case 0x01: // Ird Info
                    if (zip)
                        //memory.s32 (Z + 7, zip);
                        memory.s32(0xD0F4, zip); //Edited for Rom10to102 hack - loads Zip from cemu.ini

                    if (tz)
                        //memory.s8 (Z + 11, tz);
                        memory.s8(0xD0E9, tz); //Edited for Rom10to102 hack - loads TZ from cemu.ini

                    if (irdid)
                        memory._s32(Z + 13, irdid);

                    if (boxkey)
                        memory.s64(Z + 33, boxkey);

                    break;

                case 0x06: // Provider Info
                    if ((++count06) != 2)
                        break;

                    if (camid)
                        memory.s32(Z + 6, camid);

                    if (blackout[11] || blackout[10] || blackout[9])
                        memory.s(Z + 30, blackout, 12);

                    if (key0)
                        memory.s64(Z + 42, key0);

                    if (key1)
                        memory.s64(Z + 50, key1);

                    break;
                }
            }
        }

    database() :
        start(memory.g16(DataSpacePTR)),
        end(DataSpaceEnd),
        len(end - start)
        {
        if (tierfile[0])
            readfile(tierfile);

        update();
        }
    } * Database = 0;

void mpz_import( mpz_t m, int addr, int size ) { mpz_import(m, size, -1, 1, -1, 0, &memory[addr]); }

void mpz_export( mpz_t m, int addr, int size )
    {
    uchar Z[256];
    size_t count;

    for ( int a = 0; a < size; ++a )
        Z[a] = 0;

    mpz_export(Z, &count, -1, 1, -1, 0, m);

    for ( int a = 0; a < size; ++a )
        memory[addr + a] = Z[a];
    }

/**
 Variable definitions
*/

int MAP_reg0 = 0;
int MAP_reg1 = 0;

mpz_t MAP_modulos, MAP_exponent, MAP_input, MAP_output, MAP_a, MAP_b, MAP_c;

mpz_t MAP_payload, MAP_E, EMMG, MAP_N, MAP_D, MAP_EMM, MAP_Result;

int ANRTS = 0;

int packetbit, parity, packetptr;

void ioStartPacket( void ) // Called just before first byte of packet
    {
    packetptr = 0;
    packetbit = 0;
    D_COMM << h16 << PC << " ioStartPacket" << endl;
    }

void ioReset( void ) // Set IO High After Reset
    {
    in.length = 0;
    out.length = 0;
    D_COMM << h16 << PC << " ioReset" << endl;
    CPU__6805_Step();
    }

void ioStartBit( void ) // Start Bit
    {
    if (packetptr < in.length)
        memory.m[0] = 0;
    else
        memory.m[0] = 1;

    parity = 1;

    D_COMM << h16 << PC << " " << dec << packetptr << " - " << h8 << (int)in.data[packetptr] << " - Start "
        << dec << (int)memory.m[0] << " - ";
    CPU__6805_Step();
    }

void ioReceiveBit( void ) // Receive Bit
    {
    if (in.data[packetptr]&(0x80 >> packetbit++))
        {
        memory.m[0] = 0;
        }
    else
        {
        memory.m[0] = 1;
        parity ^= 1;
        }

    if (packetbit == 8)
        {
        packetptr++;
        packetbit = 0;
        }

    D_COMM << dec << (int)memory.m[0];
    CPU__6805_Step();
    }

void ioParity( void ) // Parity
    {
    memory.m[0] = parity;

    D_COMM << " - Parity " << dec << (int)memory.m[0] << endl;
    CPU__6805_Step();
    }

void ioReceiveByte( void ) // Received Byte
    {
    D_COMM << h16 << PC << " ioReceiveByte " << h8 << (int)A << endl;
    CPU__6805_Step();
    }

void ioOverByte( void ) // Overbyte
    {
    memory.m[0] = 1;
    D_COMM << h16 << PC << " ioOverByte" << endl;
    CPU__6805_Step();
    }

void ioWaitStart( void ) // Wait For Start Bit
    {
    if (packetptr < in.length)
        memory.m[0] = 0;
    else
        memory.m[0] = 1;

    D_COMM << h16 << PC << " ioWaitStart" << endl;
    CPU__6805_Step();
    }

void ioSendByte( void ) // SENDBYTE
    {
    out.data[out.length++] = A;
    PC = ANRTS;
    D_COMM << "ioSendByte " << h8 << (int)A << endl;
    }

void ioBeforeATR( void ) // Before BUILDATR Call
    {
    D_COMM << "ioBeforeATR" << endl;
    CPU__6805_Step();
    }

void ioAfterATR2( void ) // After BUILDATR Call
{ CPU__6805_Step(); }

void ioAfterATR( void )  // After BUILDATR Call
    {
    if ((atrstart + atrreset > 0))
        {
        Comm->WriteATR(out.data, out.length);
        cout << "ATR ---" << bas(out.data, out.length) << " = ";

        for ( int a = 11; a < out.length - 1; ++a )
            {
            if (out.data[a] >= 0x20)
                cout << out.data[a];
            else
                cout << ".";
            }

        cout << endl;
        out.length = 0;
        D_COMM << "ioAfterATR" << endl;
        atrstart = 0;
        }

    CPU__6805_Step();
    }

void func_debug_on( void )
    {
    CPU__6805_Step();
    debug_x |= DEBUG_6805;
    }

void func_debug_off( void )
    {
    debug_x &= ~DEBUG_6805;
    CPU__6805_Step();
    }
#define I_NAD in.data [0]
#define I_PCB in.data [1]
#define I_LEN in.data [2]
#define I_LRC in.data [3 + I_LEN]
#define I_IFS in.data [3]

#define I_CLA in.data [3]
#define I_INS in.data [4]
#define I_P1 in.data [5]
#define I_P2 in.data [6]
#define I_CL in.data [7]
#define I_CN in.data [8]
#define I_DL in.data [9]
#define I_DATA (in.data+10)

void ioDebugInput2( void ) { }

void ioDebugInput( void )
  
{   char *streamfile;
    char date[32];
    char ttime[64];

    if ((in.length >= 1) && (in.data[0] == 0x21))
        {
        if (STREAMLOG == 1) {
    	     ostringstream streamoss;
             streamoss << setfill('0') << hex << uppercase << ba(in.data, in.length) << endl;
	     streamfile = strcat(datestring(date),streamlogfile.c_str());
             strmlog.ChangeFile(streamfile);
	     strmlog.Write("%s",streamoss.str().c_str());
           }
        D_IN << "<<" << bas(in.data, in.length) << endl;

        D_CMD1 << "<< NAD = " << h8 << (int)I_NAD << ", PCB = " << h8 << (int)I_PCB << ", LEN = " << h8
            << (int)I_LEN << ", LRC = " << h8 << (int)I_LRC << endl;


            if (bidoncmpt > 10)  bidoncmpt=0;
               

        if ((I_PCB &0xFC) == 0xC0) // Control


            switch( I_PCB &0x03 )

                {
                case 0x00:
                    D_IN << "<< CTRLREQ - RESYNC" << endl;
                    bidoncmpt = 0;
                    break;

                case 0x01:
                    D_IN << "<< CTRLREQ - IFS - " << h8 << (int)I_IFS << endl;
            /*        if (bidoncmpt<1 ) {cout << ShowTime() << " Reset dected from CTRLREQ-IFS...." << endl;
                     initEMU3();}

                    bidoncmpt++;*/
                    break;

                case 0x02:
                    D_IN << "<< CTRLREQ - ABORT" << endl;
                    break;

                case 0x03:
                    D_IN << "<< CTRLREQ - WTX" << endl;
                    break;
                }

        else if ((I_PCB &0xEF) == 0x80) // Check Sum
            switch( I_PCB &0x10 )
                {
                case 0x00:
                    D_IN << "<< CAM OUTPUT CSUM ERROR" << endl;
                    break;

                case 0x10:
                    D_IN << "<< CAM OUTPUT PARITY ERROR" << endl;
                    break;
                }
        else if ((I_PCB &0x9F) == 0x00) // Normal Message
            {
            D_CMD1 << "<< CLA = " << h8 << (int)I_CLA << ", INS = " << h8 << (int)I_INS << ", P1 = " << h8
                << (int)I_P1 << ", P2 = " << h8 << (int)I_P2 << ", CL = " << h8 << (int)I_CL << ", CN = "
                << h8 << (int)I_CN << ", DL = " << h8 << (int)I_DL << endl;

            switch( I_CN )
                {

                // N2 CMDS


                case 0x07:
		                    D_CMD << "[RX] - $CMD 07 - Entitlement Control Message (07)" << hex << uppercase << ba(in.data, in.length) << endl;

                                    //Coward's ghetoroll for provider 0905 and 0906 code begins
                                    {
                                                       
                              
			                                           if ( (int)in.data[11] == 5) {
			                                              if (switchmethode != 5 ) {
			                                                 switchmethode = 5;
			                                                 ghetoroll = 1;
			                                                 D_KEY << "Calling ghetoroll for provider 0905" << endl;
			                                                 if (bootdisk == 0){
			                                                 FILE * pFile;
			                                                 pFile = fopen ("reload.key","w");
			                                                 fclose(pFile);
			                                                 }
			                                                 infokey905();
			                                                 
			                                                 if (bootdisk == 1)
			                                                 {
			                                                 FILE * pFile;
			                                                 pFile = fopen ("a:\\reload.key","w");
			                                                 fclose(pFile);
			                                                 }
			                                                 infokey905();    
			                            
			                                                                  
			                                               }
			                                              }
			                                               else if ( (int)in.data[11] == 6) {
			                                                 if (switchmethode != 6 ) {
			                                                    switchmethode = 6;
			                                                    ghetoroll = 1;
			                                                    D_KEY << "Calling ghetoroll for provider 0906" << endl;
			                                                 if (bootdisk == 0){
			                                                    FILE * pFile;
			                                                 pFile = fopen ("reload.key","w");
			                                                 fclose(pFile);
			                                                 }
			                                                 infokey906();
			                                                 
			                                                 if (bootdisk == 1)
			                                                 {
			                                                 FILE * pFile;
			                                                 pFile = fopen ("a:\\reload.key","w");
			                                                 fclose(pFile);
			                                                 }
			                                                      
			                            
			                                                    infokey906();
			                                 
			                                               }
			                                           } 
			                                           else if (switchmethode !=0 ) {
			                                              switchmethode = 0;
			                                              ghetoroll = originalghetoroll;
			                                              D_KEY << "Switching back to Provider 0901 keys 86.key,96.key" << endl;
			                                                                                            
			                                              if (bootdisk == 0)
			                                              {
			                                              FILE * pFile;
			                                                 pFile = fopen ("reload.key","w");
			                                                 fclose(pFile);
			                                                 }
			                                                 infokey();
			                                              
			                                              if (bootdisk == 1)
			                                                 {
			                                                 FILE * pFile;
			                                                 pFile = fopen ("a:\\reload.key","w");
			                                                 fclose(pFile);
			                                                 }
			                                              infokey();
			                                              }
                                        }
                               
                               
                               //Coward's ghetoroll for provider 0905 and 0906 code ends
                                        
                                    ecmKeySelect = (in.data[12]); // set the active key
				           	{
				                	if (ecmKeySelect != oldecmKeySelect) // If both keys are different, write to file
				                        {
				                        	ofstream a_file ("active.key");
				                        	a_file << hex << ecmKeySelect << endl;
				                        	a_file.close();
				                        {
				                        	if (oldecmKeySelect != 0) // if oldecmKeySelect was not zero, display key change on screen
				                        {
				                        	D_KEY << ShowTime(ttime) << " The Active Key has Switched! The New Active Key is: Key" << hex << ecmKeySelect << endl;
				                	}
				         	}
				         oldecmKeySelect = ecmKeySelect; 
				         }
		                    }
                    break;

                case 0x12:
                    D_CMD << "[RX] - $CMD 12 - Serial Number Request" << endl;
                    break;

                case 0x1C:
                    D_CMD << "[RX] - $CMD 1C - Control Word Request (video decrypt key request)" << endl;
                    break;

                case 0x15:
                    D_CMD << "[RX] - $CMD 15 - Update status request" << endl;
                    break;

                case 0x22:
                    D_CMD << "[RX] - $CMD 22 - Data item request" << endl;
                    break;

                case 0x2A:
                    D_CMD << "[RX] - $CMD 2A - MECM Key Request" << endl;
                    break;

                case 0x2B:
                    D_CMD << "[RX] - $CMD 2B - MECM Key Update" << endl;
                    break;

                case 0x64:
                    D_CMD << "[RX] - $CMD 64 - Write IRD info" << endl;
                    break;

		case 0x65:
		    D_CMD << "[RX] - $CMD 65 - Request for data encrypted by command $64" << endl;
		    break;

                case 0xC0:
                    D_CMD << "[RX] - $CMD C0 - CAM status request" << endl;
                    break;

                case 0xC7:
                    D_CMD << "[RX] - $CMD C7 - Request for ID of updated data items" << endl;
                    break;

                case 0xC8:
                    D_CMD << "[RX] - $CMD C8 - Get Date/Hour command" << endl;
                    break;

                case 0x00:
                    D_CMD << "<< Entitlement Management Message" << endl;
                    break;

                case 0x01:
                    D_CMD << "<< PPV Entitlement Management Message" << endl;
                    break;

                case 0x02:
                    D_CMD << "<< MECM key update" << endl;
                    break;

                case 0x03:
                    D_CMD << "<< Entitlement Control Message (03)" << endl;
                    break;

                case 0x04:
		                    D_CMD << "[RX] - $CMD 04 - Entitlement Mangagement Message (04)" << endl;
		
                                       if (ghetoroll == 1) {
		                       time (&time_now);
		                       time_diff = difftime(time_now,time_start);
		                       if (time_diff > checkdelaykey) {
		                 
		                          time(&time_start );
		                          
		                         infokey();
		                        }
		                       }
		                    else
		                       decryptfnc();
		                       
		
                    break;

                case 0x13:
                    D_CMD << "<< Control Word" << endl;
                    break;

                case 0x14:
                    D_CMD << "<< Processing cycle" << endl;
                    break;

                case 0x20:
                    D_CMD << "<< Data items available - " << h8 << (int)I_DATA[0] << endl;
                    break;

                case 0x21:
		    D_CMD << "<< Data item - " << h8 << (int)I_DATA[0] << " [" << dec << (int)I_DATA[4] << "] " << (dec) << (int)(I_DATA[5] - 3) << "L" << endl;
                    break;

                case 0x32:
                    D_CMD << "<< Request for encryption of data to be sent in callback" << endl;
                    break;

                case 0x33:
                    D_CMD << "<< Request for data encrypted by previous command $32" << endl;
                    break;

                case 0x40:
                    D_CMD << "<< EEPROM data space available" << endl;
                    break;

                case 0x41:
                    D_CMD << "<< PPV buy write" << endl;
                    break;

                case 0x42:
                    D_CMD << "<< PPV buy link" << endl;
                    break;
		
		case 0x47:
		    D_CMD << "<< DT06 Key Update" << endl;
		    break;

                case 0x55:
                    D_CMD << "<< Read email" << endl;
                    break;

                case 0x56:
                    D_CMD << "<< Delete email" << endl;
                    break;

                case 0x60:
                    D_CMD << "<< Get IRD command" << endl;
                    break;

                case 0x61:
                    D_CMD << "<< Write IRD info" << endl;
                    break;

 		case 0x85:
		    D_CMD << "<< Create indirection information" << endl;
		    break;

                case 0x99:
                    D_CMD << "<< Anti-piracy message" << endl;
                    break;

                //  case 0xc0:
                //  D_CMD << "<< CAM status" << endl;
                //  break;
                case 0xc1:
                    D_CMD << "<< Request for ID of updated data items" << endl;
                    break;

                default:
                    if (RomVer < 100) 
                        D_CMD << "[RX] - $CMD [XX] - UNKNOWN COMMAND" << bas(in.data, in.length) << endl;
  
                    //exit (1);
                    break;
                }
            }
       		   else {
            D_CMD << "<< UNKNOWN INPUT - " << bas(in.data, in.length) << endl;
            //exit (1);
            }
        }
    }

#define O_NAD out.data [0]
#define O_PCB out.data [1]
#define O_LEN out.data [2]
#define O_LRC out.data [out.length - 1]
#define O_IFS out.data [3]

#define O_CC out.data [3]
#define O_AL out.data [4]
#define O_DATA (out.data+5)
#define O_SW1 out.data [5 + O_AL]
#define O_SW2 out.data [6 + O_AL]

void ioDebugOutput( void )
{
    char ttime[64];
    D_OUT << ">>" << bas(out.data, out.length) << endl;

    if ((out.length >= 1) && (out.data[0] == 0x12))
        {
        if (STREAMLOG == 1) {
             ostringstream streamoss;
             streamoss << setfill('0') << hex << uppercase << ba(out.data, out.length) << endl;
	     
	     strmlog.Write("%s",streamoss.str().c_str());
		
           }
        D_CMD1 << "<< NAD = " << h8 << (int)O_NAD << ", PCB = " << h8 << (int)O_PCB << ", LEN = " << h8 << (int)O_LEN << ", LRC = " << h8 << (int)O_LRC << endl;

        if ((O_PCB &0xFC) == 0xE0) // Control
            switch( O_PCB &0x03 )
                {
                case 0x00:
                    D_OUT << ">> CTRLREQ - RESYNC" << endl;
                    break;

                case 0x01:
                    D_OUT << ">> CTRLREQ - IFS - " << h8 << (int)O_IFS << endl;
                    break;

                case 0x02:
                    D_OUT << ">> CTRLREQ - ABORT" << endl;
                    break;

                case 0x03:
                    D_OUT << ">> CTRLREQ - WTX" << endl;
                    break;
                }
        else if ((O_PCB &0xAC) == 0x00) // Normal Message
            {
            D_CMD1 << "<< CC = " << h8 << (int)O_CC << ", AL = " << h8 << (int)O_AL << ", SW1 = " << h8
                << (int)O_SW1 << ", SW2 = " << h8 << (int)O_SW2 << endl;

            switch( O_CC )
                {

                // N2 commands
                case 0x84:
                    D_CMD << "[TX] - $RSP 84 - Entitlement Management Message (EMM)" << endl;
                    break;

                case 0x87:
                    D_CMD << "[TX] - $RSP 87 - Entitlement Control Message (ECM)" << endl;
                    break;

                case 0x92:
                    D_CMD << "[TX] - $RSP 92 - Serial Number send" << setw(10) << dec
                        << (int)((O_DATA[0] << 24) + (O_DATA[1] << 16) + (O_DATA[2] << 8) + O_DATA[3])
                        << " - " << h32
                        << (int)((O_DATA[0] << 24) + (O_DATA[1] << 16) + (O_DATA[2] << 8) + O_DATA[3])
                        << endl;
                    break;

                case 0x9C:
                    D_CMD << "[TX] - $RSP 9C - Control Word send (video decrypt key send)" << endl;
                    break;

                case 0x95:
                    D_CMD << "[TX] - $RSP 95 - Update status send" << endl;
                    break;

                case 0xA2:
                    D_CMD << "[TX] - $RSP A2 - Data item send " << dec << (int)O_DATA[0] << endl;
                    break;

                case 0xAA:
                    D_CMD << "[TX] - $RSP AA - Send for callback encryption" << endl;
                    break;

                case 0xAB:
                    D_CMD << "[TX] - $RSP AB - Send IRD command" << endl;
                    break;

                case 0xE4:
                    D_CMD << "[TX] - $RSP E4 - Send IRD info" << endl;
                    break;

                case 0xB0:
                    D_CMD << "[TX] - $RSP B0 - CAM status send " << h8 << (int)O_DATA[0] << " " << h8
                        << (int)O_DATA[1] << " " << h8 << (int)O_DATA[2] << " " << h8 << (int)O_DATA[3]
                        << endl;
                    break;

                case 0xB7:
                    D_CMD << "[TX] - $RSP B7 - Send ID of updated data items" << endl;
                    break;

                case 0xB8:
                    D_CMD << "[TX] - $RSP B8 - Send Date/Hour command" << endl;
                    break;

                //END N2 commands

                case 0x80:
                    D_CMD << ">> Entitlement Management Message" << endl;
                    break;

                case 0x81:
                    D_CMD << ">> PPV Entitlement Management Message" << endl;
                    break;

                case 0x82:
                    D_CMD << ">> MECM key update" << endl;
                    break;

                case 0x83:
                    D_CMD << ">> Entitlement Control Message" << endl;
                    break;

                //    case 0x92:
                //     D_CMD << ">> Serial Number - S" << setw (10) << dec
                //      << (int) ((O_DATA[0] << 24) + (O_DATA[1] << 16) +
                //               (O_DATA[2] << 8) + O_DATA[3])
                //     << " - " << h32
                //    << (int) ((O_DATA[0] << 24) + (O_DATA[1] << 16) +
                //             (O_DATA[2] << 8) + O_DATA[3]) << endl;
                // break;
                case 0x93:
                    D_CMD << ">> Control Word" << endl;
                    break;

                case 0x94:
                    D_CMD << ">> Processing cycle" << endl;
                    break;

                case 0x6F:
                    cout << ShowTime(ttime) << " Reset detected, please be patient. Reseting emulation" << endl;

		//	setUpROM();
                    initEMU3();
                    break;

                case 0xA0:
                    D_CMD << ">> Data items available - " << dec << (int)O_DATA[0] << endl;
                    break;

                case 0xA1:
                    D_CMD << ">> Data item - " << h8 << (int)O_DATA[0] << " - " << bas(O_DATA + 1, O_AL - 1)
                        << endl;
                    break;

                case 0xF0:
                    D_CMD << ">> Request for encryption of data to be sent in callback" << endl;
                    break;

                case 0xF1:
                    D_CMD << ">> Request for data encrypted by previous command $F0" << endl;
                    break;

                case 0x70:
                    D_CMD << ">> EEPROM data space available - " << h16 << (int)((O_DATA[0] << 8) + O_DATA[1])
                        << endl;
                    break;

                case 0x71:
                    D_CMD << ">> PPV buy write" << endl;
                    break;

                case 0x72:
                    D_CMD << ">> PPV buy link" << endl;
                    break;

                case 0xD5:
                    D_CMD << ">> Read email" << endl;
                    break;

                case 0xD6:
                    D_CMD << ">> Delete email" << endl;
                    break;

                case 0xE0:
                    D_CMD << ">> Get IRD command" << endl;
                    break;

                case 0xE1:
                    D_CMD << ">> Write IRD info" << endl;
                    break;

                case 0x99:
                    D_CMD << ">> Anti-piracy message" << endl;
                    break;

                //   case 0xB0:
                //     D_CMD << ">> CAM status - "
                //       << h8 << (int) O_DATA[0] << " "
                //       << h8 << (int) O_DATA[1] << " "
                //       << h8 << (int) O_DATA[2] << " " << h8 << (int) O_DATA[3] << endl;
                //     break;
                case 0xB1:
                    D_CMD << ">> Request for ID of updated data items - " << h8 << (int)O_DATA[0] << " " << h8
                        << (int)O_DATA[1] << endl;

                    if ((O_DATA[1] &0x21) && Database)
                        Database->print();

                    break;

                default:
                    if (RomVer < 100)
                        D_CMD << "[TX] - $RSP [XX] - UNKNOWN COMMAND" << bas(out.data, out.length) << endl;



                    // exit (1);
                    break;
                }
            }
        else
            {
            D_CMD << ">> UNKNOWN OUTPUT - " << bas(out.data, out.length) << endl;
            //exit (1);
            }
        }
    }

voidFunc* precomp[memorySize];
voidFunc* precompDebug[memorySize];
memFunc* MemFunc;

void initEMU( void )
    {



    D_KEY << "Cmd for keys : " ;
    D_KEY <<  hex << (int)cmdforkeys << endl;

    //D_KEY << "Current B1 Signature : " << b1sig << endl;
   // D_KEY << "Current altB1 Signature : " << altb1sig << endl;


    D_KEY << "String for key86 : " << strtofind86 << endl;


    D_KEY << "Offset for key86 : ";

    D_KEY <<  dec << (int)offsetkey86 << endl;


    D_KEY << "String for key96 : " << strtofind96 << endl;


    D_KEY << "Offset for key96 : ";

    D_KEY <<  dec << offsetkey96 << endl;

/*
    cout << "Alternate Cmd for keys    :" ;
    cout <<  hex << (int)altcmdforkeys << dec << ":" <<endl;


    cout << "Alternate String for key86:" << altstrtofind86 << ":" << endl;


    cout << "Alternate Offset for key86:";

    cout <<  dec << (int)altoffsetkey86 << dec << ":" << endl;


    cout << "Alternate String for key96:" << altstrtofind96 << ":" << endl;


    cout << "Alternate Offset for key96:";

    cout <<  dec << altoffsetkey96 << ":" <<endl;

*/


    initEMU2();


    if (Debugging)
        {
        while (Debugging)
            {
            debug();
            CPU__Execute();
            Break = 0;
            }
        }
    else {
#if !defined(DJGPP) && !defined(_WIN32)
	if(!Debugstat) init_keyboard();
#endif
	CPU__Execute();

	}
    if (!NoSave)
        sig_usr1(0);

    if (Database)
        delete Database;
    }

void setEMMKeys()
    {

    /* Set P,Q, RSA Key and EMM */
    if (emmProvider == 0x0001)
        {
	mpz_set_str(MAP_N, keyset1[0][0], 16);
	mpz_set_str(MAP_D, keyset1[0][1], 16);        
        mpz_set_str(EMMG, keyset1[0][2], 16);
        }
     else if (emmProvider == 0x0101)
        {
        mpz_set_str(MAP_N, keyset1[0][3], 16);
	mpz_set_str(MAP_D, keyset1[0][4], 16);
        mpz_set_str(EMMG, keyset1[0][5], 16);
        }
     else if (emmProvider == 0x0801)
        {
	mpz_set_str(MAP_N, keyset8[0][0], 16);
	mpz_set_str(MAP_D, keyset8[0][1], 16);        
        mpz_set_str(EMMG, keyset8[0][2], 16);
        }
    else if (emmProvider == 0x0901)
        {
	mpz_set_str(MAP_N, keyset8[0][3], 16);
	mpz_set_str(MAP_D, keyset8[0][4], 16);        
        mpz_set_str(EMMG, keyset8[0][5], 16);
        }
      
    }

void initEMU2()
    {
  if (portdev != "stream") {
    Comm->Close();
    Comm->Open();
    ReloadROM();
    }

    MAP_reg0 = 0;
    MAP_reg1 = 0;

    mpz_init(MAP_modulos);
    mpz_init(MAP_exponent);
    mpz_init(MAP_input);
    mpz_init(MAP_output);
    mpz_init(MAP_a);
    mpz_init(MAP_b);
    mpz_init(MAP_c);

    mpz_init(EMMG);
    mpz_init(MAP_N);
    mpz_init(MAP_payload);
    mpz_init(MAP_D);
    mpz_init(MAP_EMM);
    mpz_init(MAP_Result);
    mpz_init(MAP_E);

    setEMMKeys();

    for ( int a = 0; a < memorySize; ++a )
        precompDebug[a] = 0;

    for ( int a = 0; a < memorySize; ++a )
        precomp[a] = CPU__6805_Step;

    for ( int a = 0x2000; a < 0x4000; ++a )
        precomp[a] = Debugger;

    precomp[0] = Debugger;

    CPU__6805_Initz();
    CPU__6805_Reset();

    if (RomVer == 10)
        initROM10();
    
    if (camid)
        memory.s32(DataSpacePTR + 8, camid);

    D_RUN << "Database At : " << h16 << memory.g16(DataSpacePTR) << endl;
    int Rev = (RomVer < 100) ? DataSpacePTR + 0x02 : DataSpacePTR + 0x12;
    D_RUN << "Revision AT : " << h16 << Rev << endl;
    D_RUN << "Revision    : " << memory[Rev + 0] << memory[Rev + 1] << memory[Rev + 2] << memory[Rev + 3]
        << memory[Rev + 4] << memory[Rev + 5] << endl;
    D_RUN << "CamID       : S" << setw(10) << dec << memory.g32(DataSpacePTR + 8) << "    0x" << h32
        << memory.g32(DataSpacePTR + 8) << endl;

    if (RomVer < 100)
        Database = new database();

	infokey(); //If autoroll goes down

     cout << "Current idea0 in bin : "   << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << endl;
    cout  << "Current idea1 in bin : "   << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << endl;

    }

void initEMU3()
    {
  if (portdev != "stream") {
    Comm->Close();
    Comm->Open();
    ReloadROM();

    }

    MAP_reg0 = 0;
    MAP_reg1 = 0;

    mpz_init(MAP_modulos);
    mpz_init(MAP_exponent);
    mpz_init(MAP_input);
    mpz_init(MAP_output);
    mpz_init(MAP_a);
    mpz_init(MAP_b);
    mpz_init(MAP_c);

    mpz_init(EMMG);
    mpz_init(MAP_N);
    mpz_init(MAP_payload);
    mpz_init(MAP_D);
    mpz_init(MAP_EMM);
    mpz_init(MAP_Result);
    mpz_init(MAP_E);

    setEMMKeys();

    for ( int a = 0; a < memorySize; ++a )
        precompDebug[a] = 0;

    for ( int a = 0; a < memorySize; ++a )
        precomp[a] = CPU__6805_Step;

    for ( int a = 0x2000; a < 0x4000; ++a )
        precomp[a] = Debugger;

    precomp[0] = Debugger;

    CPU__6805_Initz();
    CPU__6805_Reset();

    if (RomVer == 10)
        initROM10();
    
    if (camid)
        memory.s32(DataSpacePTR + 8, camid);

    D_RUN << "Database At : " << h16 << memory.g16(DataSpacePTR) << endl;
    int Rev = (RomVer < 100) ? DataSpacePTR + 0x02 : DataSpacePTR + 0x12;
    D_RUN << "Revision AT : " << h16 << Rev << endl;
    D_RUN << "Revision    : " << memory[Rev + 0] << memory[Rev + 1] << memory[Rev + 2] << memory[Rev + 3]
        << memory[Rev + 4] << memory[Rev + 5] << endl;
    D_RUN << "CamID       : S" << setw(10) << dec << memory.g32(DataSpacePTR + 8) << "    0x" << h32
        << memory.g32(DataSpacePTR + 8) << endl;

    if (RomVer < 100)
        Database = new database();
    /*  ioAfterATR2 ();
    */
    }

void decryptkeysfunc() 
    {
		char ttime[64];
 	{
#ifdef CYGWIN
	char key86str[33] = "\0"; //Reset it every time
 	
	if (strstr(b1_morphed, strtofind86) > 0)
            {
            strlcpy(key86str, strstr(b1_morphed, strtofind86) + offsetkey86, 33);
             }

        char key96str[33] = "\0"; //Reset it every time

        if (strstr(b1_morphed, strtofind96) > 0)
            {
            strlcpy(key96str, strstr(b1_morphed, strtofind96) + offsetkey96, 33);
             }
#else
	char key86str[33] = "\0"; //Reset it every time
 	
	if (strstr(b1_morphed, strtofind86) > 0)
            {
            strlcpy(key86str, strstr(b1_morphed, strtofind86) + offsetkey86, 32);
             }

        char key96str[33] = "\0"; //Reset it every time

        if (strstr(b1_morphed, strtofind96) > 0)
            {
            strlcpy(key96str, strstr(b1_morphed, strtofind96) + offsetkey96, 32);
             }
#endif
           if (strlen(key86str) > 0)
            {
            needupdate = 0;
        
    	    if (EMMLOG == 1)
                {
		emmlog.Write("KEY86:\n%s\n\n",key86str);
//                ofstream myfile("EMMLOG.txt", ios::app);
//                myfile <<  "KEY86:\n" << key86str << "\n\n";
//                myfile.close();
                }

            if (strlen(key86str) < 32)
                {
                pad86 = 1;
                }
            else
                {
                pad86 = 0;
                }

           

            for ( int b = 0; b < 16; b++ )
                {
                valtmp = (ascHexToInt(key86str[(b * 2) - pad86])
                              * 16) + ascHexToInt(key86str[(b * 2) + 1 - pad86]);

                if (memory.m[b + 0xd863] != valtmp)
                    {
                   needupdate = 1;
                    }

                memory.m[b + 0xd863] = valtmp;
                }

            if (needupdate == 1)
                {
                D_KEY << ShowTime(ttime) << " Bin updated with  Key 86 : " << key86str << endl;
		D_KEY << ShowTime(ttime) << " The Active Key is Key " << ecmKeySelect << endl;
                fstream f(dishfile.c_str(), ios::in |ios::out |ios::binary);
                f.seekp(0x1863);
                f.write((char *) &memory.m[0xD863], 0x0010);
                f.close();
		outkey(86);
                }
                else
                {
                
                D_KEY << ShowTime(ttime) << " No need to update Key 86 : " << key86str << endl;
		D_KEY << ShowTime(ttime) << " The Active Key is Key " << ecmKeySelect << endl;
                }

            }

        if (strlen(key96str) > 0)
            {
            needupdate = 0;

            if (EMMLOG == 1)
                {
		emmlog.Write("KEY96:\n%s\n\n--\n\n",key96str);
		
//                ofstream myfile("EMMLOG.txt", ios::app);
//                myfile << "KEY96:\n" << key96str << "\n\n";
//                myfile.close();
                }


            if (strlen(key96str) < 32)
                {
                pad96 = 1;
                }
            else
                {
                pad96 = 0;
                }

            for ( int b = 0; b < 16; b++ )
                {
                valtmp = (ascHexToInt(key96str[(b * 2) - pad96])
                              * 16) + ascHexToInt(key96str[(b * 2) + 1 - pad96]);

                if (memory.m[b + 0xd873] != valtmp)
                    {
                   needupdate = 1;
                    }

                memory.m[b + 0xd873] = valtmp;
                }


            if (needupdate == 1)
                {
                D_KEY << ShowTime(ttime) << " Bin updated with  Key 96 : " << key96str << endl;
		D_KEY << ShowTime(ttime) << " The Active Key is Key " << ecmKeySelect << endl;
                fstream f(dishfile.c_str(), ios::in |ios::out |ios::binary);
                f.seekp(0x1873);
                f.write((char *) &memory.m[0xD873], 0x0010);
                f.close();
		outkey(96);
                }
                else
                {
                D_KEY << ShowTime(ttime) << " No need to update Key 96 : " << key96str << endl;
		D_KEY << ShowTime(ttime) << " The Active Key is Key " << ecmKeySelect << endl;
                }
            }
        }
      }





void log_b1(char *before, char *after)
{ 	char ttime[64];
	int y;
	string b1_str(before);
	string b1_morphed_str(after);
	y=0; 
	while (y < (int)b1_str.length()) {
		switch(b1_str.compare(y,2,b1_morphed_str, y,2)) {
    			case 0: // The same
      				y+=2;
      			break;
    			case -1: // Less than
					
      				b1_str.insert(y,"<");
				b1_str.insert(y+3,">");
				b1_morphed_str.insert(y,"<");
				b1_morphed_str.insert(y+3,">");
				y+=4;
			break;
    			case 1: // Greater than
       				 	
      				b1_str.insert(y,"<");
				b1_str.insert(y+3,">");
				b1_morphed_str.insert(y,"<");
				b1_morphed_str.insert(y+3,">");
				y+=4;
			break;
	        }	
	   
        }

	D_B1 << "B1 Before Morph:\n" << b1_str << endl << endl;
	D_B1 << "B1 After Morph:\n" << b1_morphed_str << endl << endl;	

        if (strlen(b1) > 0)
          {
            if (EMMLOG == 1)
                {
		emmlog.Write("Logged Key EMM ***** %s\n\n",ShowTime(ttime));
		emmlog.Write("B1 Before Morph:\n%s\n\n",b1_str.c_str());

                } 
           }

	if (strlen(b1_morphed) > 0)
	  { 
             if (EMMLOG == 1)
               	 {
		 emmlog.Write("B1 After Morph:\n%s\n\n",b1_morphed_str.c_str());

      	        } 
           }
} //end log_b1

bool passthroughemu() 
{
   int i;
   const char b1rev[9] = "B1CD7BB5";
   const char b1ECM1[27] = "B17180C6B0D1CD5AFEB8BBB7BB";
   const char b1ECM2[25] = "B1C63067A403A103262D7180";
   char tempstr[5];
   char tempstr2[5];
   char ttime[64];
   bool result;
   if ( b1_Emm[18] == cmdforkeys ) {
   	strcpy(b1sig,"\0");
	strcpy(tempstr2,"\0");
  	for (i=18;i<22;i++)
	   {
    	      sprintf(tempstr2,"%02X",b1_Emm[i]);
              strcat(b1sig,tempstr2);
	   }   
       }
  // look for B1 key nano 
  strcpy(tempstr,"\0");
  sprintf(tempstr,"%04X",emmProvider);
  decEmm_str = decEmmAsString;

  if (strstr(decEmmAsString,b1sig) > 0 && decEmm_str.rfind(tempstr,20) == 16) {
     if (strstr(decEmmAsString,b1rev) > 0)
       {
	result = false;
        strlcpy(b1_other, strstr(GetBufStr(b1_Emm,96), b1rev) + 2, 155);
        D_B1 << "B1 Revision update detected... Passing B1:\n" << b1_other << endl;      
        if (EMMLOG == 1)
           {
	    emmlog.Write("B1 Revision Update Logged ***** %s\n\n",ShowTime(ttime));
	    emmlog.Write("B1 Revision Update:\n%s\n\n--\n\n",b1_other);

           }
       }
     else if (strstr(decEmmAsString,b1ECM1) > 0)
	{
	 result = false;	
	 strlcpy(b1_other, strstr(GetBufStr(b1_Emm,96), b1ECM1) + 2, 155);
	 D_B1 << "B1 ECM1 detected... Passing B1:\n" << b1_other << endl;      
         if (EMMLOG == 1)
           {
	    emmlog.Write("B1 ECM1 Logged ***** %s\n\n",ShowTime(ttime));
	    emmlog.Write("B1 ECM1:\n%s\n\n--\n\n",b1_other);

           }
        }
     else if (strstr(decEmmAsString,b1ECM2) > 0)
	{
	 result = false;	
	 strlcpy(b1_other, strstr(GetBufStr(b1_Emm,96), b1ECM2) + 2, 155);
	 D_B1 << "B1 ECM2 detected... Passing B1:\n" << b1_other << endl;      
         if (EMMLOG == 1)
           {
	    emmlog.Write("B1 ECM2 Logged ***** %s\n\n",ShowTime(ttime));
	    emmlog.Write("B1 ECM2:\n%s\n\n--\n\n",b1_other);

           }
        }
     else
       {
      result = true;
       }
  }
  else {
    result = false;
    strlcpy(b1_other, strstr(GetBufStr(b1_Emm,96), b1sig) + 2, 155);
    D_B1 << "B1 Invalid... Passing B1:\n" << b1_other << endl << endl;
        if (EMMLOG == 1)
	  {
	   emmlog.Write("Invalid B1 Logged ***** %s\n\n",ShowTime(ttime));
	   emmlog.Write("Invalid B1:\n%s\n\n--\n\n",b1_other);
          } 
       }
  return result;
}

int b1_morph()
{  
   int i;
   char tempstr2[5];
   char ttime[64];
   int status = 0;
   if (!passthroughemu()) return -1;
 
   if ( b1_Emm[18] == cmdforkeys ) {
	strcpy(b1sig,"\0");
	strcpy(tempstr2,"\0");
        for (i=18;i<22;i++)
           {
               sprintf(tempstr2,"%02X",b1_Emm[i]);
               strcat(b1sig,tempstr2);
	    }   
	
	D_B1 << "B1sig: " << hex << b1sig << endl;
	strlcpy(b1, strstr(decEmmAsString, b1sig) + 2, 155);
		
       }
	// Send EMM to process dynamic code in B1 nano...new morph routine
	if (strlen(b1) > 0) 
	   { 
		process_b1_decEmm(decEmmAsString);
          
		//B1_morph.ProcessB1(emmProvider, reinterpret_cast<unsigned char*>(&b1_Emm),reinterpret_cast<unsigned char*>(b1_Emm));
		//Removed - 1.6x codebase didn't autoroll as of March 2/ 2007
		//status = CemuTools::instance().b1Morph().ProcessB1(emmProvider, reinterpret_cast<unsigned char*>(&b1_Emm),96,19);
		status = B1Morph.ProcessB1(emmProvider, reinterpret_cast<unsigned char*>(&b1_Emm),96,19);
           }


	// convert processed B1 to hexstring for logging and for decryptkeysfunc()
        // check for invalid or non-key B1 and log
	if (strstr(GetBufStr(b1_Emm,96), b1sig) > 0) {

	        strlcpy(b1_morphed, strstr(GetBufStr(b1_Emm,96), b1sig) + 2, 155);
		
		switch(status) { 
	 		
			case 1:
			case 2:
			case 3:
			case 8:
			   if (status == 1) D_B1 << "Emulator Exit Status: " << dec << status << " - stack overflow" << endl;
			   else if (status == 2) D_B1 << "Emulator Exit Status: " << dec << status << " - instruction counter exceeded" << endl;
			   else if (status == 3) D_B1 << "Emulator Exit Status: " << dec << status << " - unsupported instruction" << endl;
			   else if (status == -1) D_B1 << "Emulator Exit Status: " << dec << status << " - B1 execution failed" << endl;      		

			   D_B1 << "Morph Execution failed...B1 Logged:\n" << b1_morphed << endl << endl;

		           if (EMMLOG == 1)
                	       {
				emmlog.Write("Morph Execution failed...B1 Logged ***** %s\n\n",ShowTime(ttime));
				emmlog.Write("B1:\n%s\n\n--\n\n",b1_morphed);

               		     }
			break;
			case 6:
			   printf("Check your directory for ROM102.bin.....missing or corrupted!\n");
		   	break;
			case 7:
			   printf("Check your directory for EEP(xx)102.bin.....missing or corrupted!\n");
			break;
			default:
			      D_B1 << "Emulator Exit Status: 0 - Successful B1 morph\n" << endl;
  			      // log key b1 and highlight differences in commands before & after
		 	      log_b1(b1, b1_morphed); 
			break;
				}

           }  
	return 0;
} 



// convert B1 EMM to byte array
void process_b1_decEmm(char * b1_decEmm)
{
	GetBuf(b1_Emm,b1_decEmm);
}


void decryptfnc()
{
   char tempstr[5];
   char *emmfile;
   char date[32];

                    D_EMM << "<< CMD04" << endl;

                    D_EMM << "[RX] - $CMD 04 - Entitlement Management Message (EMM)\n\n"
                        << bas(in.data, in.length) << endl;
                    emmProvider = (in.data[10] << 8) + in.data[11];
                    emmKeySelect = (in.data[12] << 16) + (in.data[13] << 8) + in.data[14];
                
                    if ((emmProvider != oldEmmProvider) || (emmProvider == 0))
                        {
                        oldEmmProvider = emmProvider;
                        setEMMKeys(); //Reset Keys in memory to proper EMM keys
                        D_EMM << ">> Set keys, provider: " << setfill('0') << setw(4) << hex << emmProvider << endl;
			} 
                    else {
			D_EMM << ">> Set keys, provider: " << setfill('0') << setw(4) << hex << emmProvider << endl;
			}
                    if (emmProvider == 0x0001)
                        { // Provider 0001 EMM (Dish)
                        D_EMM << ">> Dish EMM - 0001" << endl;
                        }
                     else if (emmProvider == 0x0101)
                        { // Provider 0101 EMM (Dish)
                        D_EMM << ">> Dish EMM - 0101" << endl;
                        }
		     else if (emmProvider == 0x0901)
                        { // Provider 0901 EMM (Bev)
                        D_EMM << ">> Bev EMM - 0901" << endl;
                        }
		     else if (emmProvider == 0x0801)
                        { // Provider 0801 EMM (Bev)
                        D_EMM << ">> Bev EMM - 0801" << endl;
                        }
                     else
                        {
                        D_EMM << "Unknown EMM - " << hex << emmProvider << endl;
                        }

                    if (emmKeySelect == 0x820010)
                        { // How to decrypt the EMM
                        methodA = 1;
                        }
                    else if (emmKeySelect == 0x820090)
                        {
                        methodA = 2;
                        }
                    else if (emmKeySelect == 0x810090)
                        {
                        methodA = 0;
                        }
                    
                    
                    else
                        {
                        methodA = 0;
                        }


                //    cout << "N Size: " << mpz_sizeinbase(MAP_N,16)  << " D Size: " << mpz_sizeinbase(MAP_D,16) << " EMMG Size: " << mpz_sizeinbase(EMMG,16) << endl;
			D_EMM << "N:\n" << setfill('0') << setw(192) << hex << MAP_N << endl << endl;
			D_EMM << "D:\n" << setfill('0') << setw(192) << hex << MAP_D << endl << endl;
			D_EMM << "EMMG:\n" << setfill('0') << setw(192) << hex << EMMG << endl << endl;
   	
   	if ((mpz_sizeinbase(MAP_N, 16) == 192) && (mpz_sizeinbase(MAP_D, 16) == 192) && (mpz_sizeinbase(EMMG, 16) == 192))
                        {
                        //Check to see if keys exist, thus continue with decryption, otherwise dont.
			
                        //EMM DECRYPT LOGGING
			
			
                        if (EMMLOG == 1)
                            { 
			     ostringstream emmoss;
			     emmoss << setfill('0') << uppercase << hex << ba(in.data,in.length);
			     emmfile = strcat(datestring(date),emmlogfile.c_str());

			     emmlog.ChangeFile(emmfile);  
			     emmlog.Write("Encrypted $04\n%s\n\n",emmoss.str().c_str());
                       
                            }


                        if (methodA > 0)
                            {
                            for ( int b = 0; b < 96; b++ )
                                { //Trim emm to payload and Byteswap
                                payload[b] = in.data[(95 - b) + startEmmIndex];
                                }

                            for ( int i = 0; i < 96; i++ )
                                {
                                payloadStr[i * 2] = intToAscHex(((int)payload[i]) / 16);
                                payloadStr[(i * 2) + 1] = intToAscHex(payload[i] &0x0F);
                                }

                            payloadStr[192] = '\0'; //Add string terminator character

                            mpz_set_str(MAP_payload, payloadStr, 16);
                            
			    D_EMM << "Payload:\n" << setfill('0') << setw(192) << hex << MAP_payload << endl << endl;
			    //demm(gmp_printf ("Payload:\n%0192.2ZX\n\n",MAP_payload));
   

                            /* First Round RSA  M^3 mod Rsa Key  */
                            mpz_set_ui(MAP_E, 3);
                            mpz_powm(MAP_EMM, MAP_payload, MAP_E, EMMG);
                            /* Done first Round of RSA */

			    D_EMM << "EMM After 1st RSA:\n" << setfill('0') << setw(192) << hex << MAP_EMM << endl << endl;
                            //demm(gmp_printf ("EMM After 1st RSA:\n%0192.2ZX\n\n",MAP_EMM));
		    
                         if (methodA == 2)
                                { 
				//Only do the following if its an 820090 type emm.
                                // Allow of editing of EMM after rsa1, and before going to rsa2
                                // 1) Convert from gmp type variable to string
                                // 2) Convert from string to integer array
                                // 3) Edit as needed
                                // 4) Convert from integer array to string
                                // 5) Set gmp type variable (MAP_EMM) to the string
 
     				gmp_sprintf (emmRsa1,"%0192.2ZX",MAP_EMM);    //#1

       
                  		//Convert from a hex string to a integer array  #2
				GetBuf(emmRsa1Bytes,emmRsa1);	

	

   		 		//Do the modifications to the EMM after RSA1 here   //#3
				
                                 emmRsa1Bytes[0] |= (in.data[14] &0x80);


                                //End Modifications

                                for ( int i = 0; i < 96; i++ )    //#4
                                    { 
                                    emmRsa1[i * 2] = intToAscHex(((int)emmRsa1Bytes[i]) / 16);
                                    emmRsa1[(i * 2) + 1] = intToAscHex(emmRsa1Bytes[i] &0x0F);
                                    }

                                mpz_set_str(MAP_EMM, emmRsa1, 16); //#5

                               	D_EMM << "EMM After 1st RSA with modification:\n" << setfill('0') << setw(192) << hex << MAP_EMM << endl << endl;
				//demm(gmp_printf ("EMM After 1st RSA with modification:\n%0192.2ZX\n\n",MAP_EMM));
			
                                }

                            /*Begin Second Round of RSA */
                            /* R (decrypted emm) = M^D mod N */
                            mpz_powm(MAP_Result, MAP_EMM, MAP_D, MAP_N);
                            /* Done Second Round of RSA */

                            gmp_sprintf(decEmmAsString, "%0192.2ZX", MAP_Result);
			    sprintf(tempstr,"%04X",emmProvider);
			 
			    decEmm_str = decEmmAsString; 


		if (decEmm_str.rfind(tempstr,20) != 16) {
		   D_EMM << "EMM Decryption failed:\n" << setfill('0') << setw(192) << hex << decEmmAsString << endl << endl;
		   //demm(printf("EMM Decryption failed:\n%s\n\n",decEmmAsString));
		   if (EMMLOG == 1) {
		     emmlog.Write("EMM Decryption failed:\n%s\n\n",decEmmAsString);
  		     }
		   }
		else {
		   D_EMM << "Decrypted EMM:\n" << setfill('0') << setw(192) << hex << decEmmAsString << endl << endl;
                   //demm(printf("Decrypted EMM:\n%s\n\n",decEmmAsString)); 
 		    //EMM LOGGING	
                   if (EMMLOG == 1) emmlog.Write("Decrypted:\n%s\n\n",decEmmAsString);
		   }	
                            //Begin Key stuff

                            // if this is a keyupdate packet, it will have the following signature starting at keyoffset
                            //'42001006080010' <- key86
                            //'42001046080010' <- key96

			    //Look for B1 command

			    GetBuf(b1_Emm,decEmmAsString); //convert to byte array
                            
			    if ( b1_Emm[18] == cmdforkeys)  
				{
                                   D_B1 << "\nCall decrypt " << hex << cmdforkeys << endl << endl;

                		   //b1_morph();   //process B1 command 
		                   if (b1_morph() == -1) return;
						   
						   else decryptkeysfunc();
                        
			        }
                     
                                                     
                            //FINISHHHHHHHHHHHHHHH
                            
                         }   
                        }

}


void decryptfnc07()
            {   char ttime[64];

                ofstream myfile("ecm07.txt", ios::app);
		myfile << ShowTime(ttime) << endl;
                myfile << setfill('0') << uppercase << hex << ba(in.data, in.length) <<  endl;
                myfile.close();
//                cout  << hex << ba(in.data, in.length) << endl;
//                ecmKeySelect = (in.data[14] );
/*                if  ( ecmKeySelect =0x08) {
                   ofstream myfile1("ecm07key.txt", ios::app);
                   myfile1  << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) ;
                   myfile1.close();
                } else 
                {
                   ofstream myfile1("ecm07key.txt", ios::app);
                   myfile1  << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b);
                   myfile1.close();
                }
*/
                if  ((ecmKeySelect=0x08)) {
                   ofstream myfile1("ecm07key.txt", ios::app);
                   myfile1 << setfill('0') << uppercase << hex << h64 << memory.g64 (0xd863) <<  h64 << memory.g64 (0xd86b) << endl;
                   myfile1.close();
                } else 
                {
                   ofstream myfile1("ecm07key.txt", ios::app);
                   myfile1 << setfill('0') << uppercase << hex << h64 << memory.g64 (0xd873) <<  h64 << memory.g64 (0xd87b) << endl;
                   myfile1.close();
                }



         //   system("cmd07");

}


char *ShowTime( char *ttime )
{ time_t rawtime;
  struct tm * timeinfo;
  string tminfo;
  
 
  time ( &rawtime );
  timeinfo = localtime ( &rawtime );
  ttime = asctime (timeinfo);
  ttime[19]=0x0;
  return (ttime) ;

}

/*
char* ShowDate()
{ time_t rawtime;
  struct tm * timeinfo;
  string tminfo;
  char* ttime;
 
  time ( &rawtime );
  timeinfo = localtime ( &rawtime );
  ttime = asctime (timeinfo);
  ttime[11]=0x0;
  return (ttime) ;

}
*/

char *datestring( char *date )
{
  struct tm tim;
 
  time_t now;
  now = time ( NULL );
  tim = *localtime(&now);

  strftime (date, 10, "%Y%m%d", &tim);
  return(date);
}
