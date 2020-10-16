#ifndef _LOGFILE_
#define _LOGFILE_
#include <stdio.h>
#include <string>
#include <stdarg.h>
using namespace std;

//	CLogFile, a debug log file wrapper
class CLogFile
{
public:
	//CreateDirectories(char filename);
	//	Constructor, open the logfile
	CLogFile();

	//	Destructor, close if logfile if opened
	~CLogFile();

	void OpenFile(const char *strFile, bool bAppend = true, long lTruncate = 4096);
	void ChangeFile(const char *strFile, bool bAppend = true, long lTruncate = 4096);
	void CloseFile();
	char *timestamp(char *ttime);
	//	Write log info into the logfile, with printf like parameters support
	void Write(const char* pszFormat, ...)
	{
		if (!m_pLogFile)
			return;
		//write the formated log string to szLog
		char szLog[256];
		va_list argList;
		va_start( argList, pszFormat );
		vsprintf( szLog, pszFormat, argList );
		va_end( argList );

		char szLine[256];
		
	
		sprintf(szLine, "%s",szLog);
		
		fputs(szLine, m_pLogFile);

		fflush(m_pLogFile);
	}

private:
	FILE* m_pLogFile;
//	long m_lTruncate;

	string m_filename;
};

#endif //_LOGFILE_
