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

#ifndef ___COMMON_H
#define ___COMMON_H

#include "debug.h"
// Debugging B1

#ifdef DEBUG
#define d(x) {if (debug_x & DEBUG_B1) { (x); } }
#else
#define d(x) ; 
#endif

#ifdef DEBUG
#define decm(x) {if (debug_x & DEBUG_CMD07) { (x); } }
#else
#define decm(x) ; 
#endif

#ifdef __DEBUG__
#define demm(x) {if (debug_x & DEBUG_EMM) { (x); } }
#else
#define demm(x) ; 
#endif

#ifdef DEBUG_EMU
#ifdef DEBUG_EMU_0x80

#define de(x) { if(debug_x & DEBUG_EMU) { (x); } }
#else
#define de(x) { if(debug_x & DEBUG_EMU_0x80) { (x); } }
#endif
#else
#define de(x) ;
#endif

#ifdef DEBUG_NAGRA
#define dn(a) { if(debug_x & DEBUG_NAGRA) { a; } }
#else
#define dn(a) ;
#endif


#endif //___COMMON_H

