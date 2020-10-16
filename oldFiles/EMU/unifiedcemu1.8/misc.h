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

#ifndef ___MISC_H
#define ___MISC_H
#ifndef UTIL_ATTR_PRINTF
# ifdef __GNUC__
/// Declare a routine to have PRINTF format error checking
#  define UTIL_ATTR_PRINTF(fmtArgNum) __attribute__ ((format (printf, fmtArgNum, fmtArgNum+1)))
# else
#  define UTIL_ATTR_PRINTF(fmtArgNum)
# endif
#endif

#include <stdio.h>

#include <openssl/bn.h>

// Some functions may be used by generic C compilers!
#ifdef __cplusplus
extern "C" {
#endif

    /// Print to cout, but with C style arguments
    extern void c_printf(const char *format, ...) UTIL_ATTR_PRINTF(1);

#ifdef __cplusplus
}
#endif


// ----------------------------------------------------------------

bool CheckNull(const unsigned char *data, int len);
unsigned int crc32_le(unsigned int crc, unsigned char const *p, int len);
void HexDump(const unsigned char *buffer, int n);


// ----------------------------------------------------------------

class cBN {
private:
  BIGNUM big;
public:
  cBN(void) { BN_init(&big); }
  ~cBN() { BN_free(&big); }
  operator BIGNUM* () { return &big; }
  bool Get(const unsigned char *in, int n);
  bool GetLE(const unsigned char *in, int n);
  int Put(unsigned char *out, int n) const;
  int PutLE(unsigned char *out, int n) const;
  };

class cBNctx {
private:
  BN_CTX *ctx;
public:
  cBNctx(void) { ctx=BN_CTX_new(); }
  ~cBNctx() { BN_CTX_free(ctx); }
  operator BN_CTX* () { return ctx; }
  };

// ----------------------------------------------------------------

class cSimpleListBase;

class cSimpleItem {
friend class cSimpleListBase;
private:
  cSimpleItem *next;
public:
  virtual ~cSimpleItem() {}
  cSimpleItem *Next(void) const { return next; }
  };

class cSimpleListBase {
protected:
  cSimpleItem *first, *last;
  int count;
public:
  cSimpleListBase(void);
  ~cSimpleListBase();
  void Add(cSimpleItem *Item, cSimpleItem *After=0);
  void Ins(cSimpleItem *Item);
  void Del(cSimpleItem *Item, bool Del=true);
  void Clear(void);
  int Count(void) const { return count; }
  };

template<class T> class cSimpleList : public cSimpleListBase {
public:
  T *First(void) const { return (T *)first; }
  T *Last(void) const { return (T *)last; }
  T *Next(const T *item) const { return (T *)item->cSimpleItem::Next(); }
  };

#endif //___MISC_H
