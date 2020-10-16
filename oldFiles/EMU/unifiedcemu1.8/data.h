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

#ifndef ___DATA_H
#define ___DATA_H

#include "misc.h"

// ----------------------------------------------------------------

class cFileMap : public cSimpleItem {//, private cMutex {
private:
	char *filename;
	bool rw;
	//
	int fd, len, count;
	unsigned char *addr;
	bool failed;
	//
	void Clean(void);
public:
	cFileMap(const char *Filename, bool Rw);
	~cFileMap();
	bool Map(void);
	bool Unmap(void);
	void Sync(void);
	int Size(void) const { return len; }
	unsigned char *Addr(void) const { return addr; }
	bool IsFileMap(const char *Name, bool Rw);
};

// ----------------------------------------------------------------

class cFileMaps : public cSimpleList<cFileMap> {//, private cMutex {
private:
	char *cfgDir; 
public:
	cFileMaps(void);
	~cFileMaps();
	void SetCfgDir(const char *CfgDir);
	cFileMap *GetFileMap(const char *name, const char *domain, bool rw);
};

extern cFileMaps filemaps;

#endif //___DATA_H
