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


#include <ctype.h>
#include <string.h>
#include <cstdarg>
#include <iostream>
#include <sys/types.h>
#include <list>
#include "common.h"
#include "misc.h"
#include "cmd07.h"

using namespace std;
#define PER_LINE 16
extern "C" void c_printf(const char *format, ...) {
#if defined(__GNUC__) && __GNUC__ >= 3
    //workaround to handle C printf style formatting and divert to cout. 
    //Debug controls what goes to cout
    static const size_t BUFSIZE = 64*1024;
    char buffer[BUFSIZE];
    va_list ap;
    va_start (ap, format);
#ifndef DJGPP
    vsnprintf(buffer, BUFSIZE, format, ap);
#else
    vsprintf(buffer, format, ap);
#endif
    buffer[BUFSIZE-1] = '\0';
    std::cout<<buffer;
#else
    va_list ap;
    va_start (ap, format);
    std::cout.vform (format, ap);
#endif
}

void HexDump(const unsigned char *buffer, int n)
{
  c_printf("dump: n=%d/0x%04X\n",n,n);
  for(int i=0; i<n;) {
    c_printf("%04X: ",i+0x80);
    for(int l=0 ; l<PER_LINE && i<n ; l++) c_printf("%02X ",buffer[i++]);
    c_printf("\n");
    }
}

bool CheckNull(const unsigned char *data, int len)
{
	while(--len>=0) if(data[len]) return false;
	return true;
}

#define CRCPOLY_LE 0xedb88320

unsigned int crc32_le(unsigned int crc, unsigned char const *p, int len)
{
	crc^=0xffffffff; // zlib mod
	while(len--) {
		crc^=*p++;
		for(int i=0; i<8; i++)
			crc=(crc&1) ? (crc>>1)^CRCPOLY_LE : (crc>>1);
	}
	crc^=0xffffffff; // zlib mod
	return crc;
}
// -- cBN ----------------------------------------------------------------------

bool cBN::Get(const unsigned char *in, int n)
{
  return BN_bin2bn(in,n,&big)!=0;
}

int cBN::Put(unsigned char *out, int n) const
{
  int s=BN_num_bytes(&big);
  if(s>n) {
    unsigned char buff[s];
    BN_bn2bin(&big,buff);
    memcpy(out,buff+s-n,n);
    }
  else if(s<n) {
    int l=n-s;
    memset(out,0,l);
    BN_bn2bin(&big,out+l);
    }
  else BN_bn2bin(&big,out);
  return s;
}

bool cBN::GetLE(const unsigned char *in, int n)
{
  unsigned char tmp[n];
  RotateBytes(tmp,in,n);
  return BN_bin2bn(tmp,n,&big)!=0;
}

int cBN::PutLE(unsigned char *out, int n) const
{
  int s=Put(out,n);
  RotateBytes(out,n);
  return s;
}
// -- cSimpleListBase --------------------------------------------------------------

cSimpleListBase::cSimpleListBase(void)
{
	first=last=0; count=0;
}

cSimpleListBase::~cSimpleListBase()
{
	Clear();
}

void cSimpleListBase::Add(cSimpleItem *Item, cSimpleItem *After)
{
	if(After) {
		Item->next=After->next;
		After->next=Item;
	}
	else {
		Item->next=0;
		if(last) last->next=Item;
		else first=Item;
	}
	if(!Item->next) last=Item;
	count++;
}

void cSimpleListBase::Ins(cSimpleItem *Item)
{
	Item->next=first;
	first=Item;
	count++;
}

void cSimpleListBase::Del(cSimpleItem *Item, bool Del)
{
	if(first==Item) {
		first=Item->next;
		if(!first) last=0;
	}
	else {
		cSimpleItem *item=first;
		while(item) {
			if(item->next==Item) {
				item->next=Item->next;
				if(!item->next) last=item;
				break;
			}
			item=item->next;
		}
	}
	count--;
	if(Del) delete Item;
}

void cSimpleListBase::Clear(void)
{
	while(first) Del(first);
	first=last=0; count=0;
}
