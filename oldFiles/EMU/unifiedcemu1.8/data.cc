/*
 * This code is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * Or, point your browser to http://www.gnu.org/copyleft/gpl.html
 */

#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#if !defined(DJGPP) && !defined(_WIN32)
#include <sys/mman.h>
#endif
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include "unistd.h"
#include "common.h"
#include "data.h"
#include "misc.h"

#define CACACHE_FILE	"ca.cache"

//#define MAP_SHARED 1 //?
//#define MS_ASYNC   0 //?

#ifndef S_ISREG
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#endif

#ifndef O_BINARY
#define O_BINARY  0
#endif 


// -- cFileMap -----------------------------------------------------------------

cFileMap::cFileMap(const char *Filename, bool Rw)
{
	filename=strdup(Filename);
	rw=Rw;
	fd=-1; count=len=0; addr=0; failed=false;
}

cFileMap::~cFileMap()
{
	Clean();
	free(filename);
}

bool cFileMap::IsFileMap(const char *Name, bool Rw)
{
	return (!strcmp(Name,filename) && (!Rw || rw));
}

void cFileMap::Clean(void)
{
#if !defined(DJGPP) && !defined(_WIN32)
        if(addr) { munmap(addr,len); addr=0; len=0; }
#else
        if(addr) free(addr);
#endif
	if(fd>=0) { close(fd); fd=-1; }
}

bool cFileMap::Map(void)
{
	//cMutexLock lock(this);
	if(addr) { count++; return true; }
	if(!failed) {
		struct stat ds;
		if(!stat(filename,&ds)) {
			if(S_ISREG(ds.st_mode)) {
				fd=open(filename,(rw ? O_RDWR : O_RDONLY) | O_BINARY );
				if(fd>=0) {
#if !defined(DJGPP) && !defined(_WIN32)
                                        unsigned char *map=(unsigned char *)mmap(0,ds.st_size,rw ? (PROT_READ|PROT_WRITE):(PROT_READ),MAP_SHARED,fd,0);
                                        if(map!=MAP_FAILED) {
						addr=map; len=ds.st_size; count=1;
						return true;
                                        }
                                        else d(c_printf("filemap: mapping failed on %s: %s\n",filename,strerror(errno)))
                                        close(fd); fd=-1;
#else
                                        unsigned char *map=(unsigned char *)malloc(ds.st_size);
                                        read(fd, map, ds.st_size);
					addr=map; len=ds.st_size; count=1;
					return true;
#endif
				}
				else d(c_printf("filemap: error opening %s: %s\n",filename,strerror(errno)))
			}
			else d(c_printf("filemap: %s is not a regular file\n",filename))
		}
		else d(c_printf("filemap: can't stat %s: %s\n",filename,strerror(errno)))
		failed=true; // don't try this one over and over again
	}
	return false;
}

bool cFileMap::Unmap(void)
{
	//cMutexLock lock(this);
	if(addr) {
		if(!(--count)) { Clean(); return true; }
		else Sync();
	}
	return false;
}

void cFileMap::Sync(void)
{
#if !defined(DJGPP) && !defined(_WIN32)
  	//cMutexLock lock(this);
        if(addr) msync(addr,len,MS_ASYNC);
#endif
}

// -- cFileMaps ----------------------------------------------------------------

cFileMaps filemaps;

cFileMaps::cFileMaps(void)
{
	cfgDir=0;
}

cFileMaps::~cFileMaps()
{
	Clear();
	free(cfgDir);
}

void cFileMaps::SetCfgDir(const char *CfgDir)
{
	free(cfgDir);
	cfgDir=strdup(CfgDir);
}

cFileMap *cFileMaps::GetFileMap(const char *name, const char *domain, bool rw)
{
	//cMutexLock lock(this);
	char path[256];
#ifndef DJGPP
        snprintf(path,sizeof(path),"%s",name);
#else
        sprintf(path,"%s",name);
#endif
	cFileMap *fm=First();
	while(fm) {
		if(fm->IsFileMap(path,rw)) return fm;
		fm=Next(fm);
	}
	fm=new cFileMap(path,rw);
	Add(fm);
	return fm;
}
