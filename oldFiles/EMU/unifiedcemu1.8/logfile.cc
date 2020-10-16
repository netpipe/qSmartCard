#include "logfile.h"
#include <time.h>
//#include <dirent.h>
#include <string>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>


void CLogFile::OpenFile(const char *strFile, bool bAppend, long lTruncate)
{
//	m_lTruncate = lTruncate;
	m_filename = strFile;

	char szFile[257];
	strcpy(szFile, strFile);
	if (!(m_pLogFile = fopen(szFile, bAppend ? "a" : "w")))
		{
		//CreateDirectories(szFile);

		m_pLogFile = fopen(szFile, bAppend ? "a" : "w");
		}

}

CLogFile::CLogFile()
{
	OpenFile("", true);
}

	/////////////////////////////////
	//	Destructor, close if logfile if opened
CLogFile::~CLogFile()
{
	CloseFile();
}

void CLogFile::CloseFile()
{
        char tempstr[100];
	char ttime[64];
	if (m_pLogFile)
		{
		sprintf(tempstr,"\n=============== Finished Logging %s ===============\n\n",timestamp(ttime));

		fputs(tempstr, m_pLogFile);
		fclose(m_pLogFile);
		}

}

void CLogFile::ChangeFile(const char *strFile, bool bAppend, long lTruncate)
{
	if (strFile != m_filename)
		{
		CloseFile();
		OpenFile(strFile, bAppend, lTruncate);
		}
}

char *CLogFile::timestamp( char *ttime )
{ time_t rawtime;
  struct tm * timeinfo;
  string tminfo;

 
  time ( &rawtime );
  timeinfo = localtime ( &rawtime );
  ttime = asctime (timeinfo);
  ttime[19]=0x0;

    
  return (ttime) ;

}
