# This is the ONLY Makefile for cemu10b
#  it works with ALL environments.
#
# The default environment is Linux,
# Detection of DJGPP is now automatic.
# To specify cygwin environment, use cygwin=1.
# To specify mingw environment, use mingw=1.
#
# Make small=1 will reduce the size of the executable, but with a performance hit.
# Make static=1 requires static libraries for the environment your using
# Make 32bit=1 will cross compile for 32bit CPU when using 64bit OS.
#
# Example; "make cygwin=1", "make cygwin=1 clean",
#  "make static=1" "make cygwin=1 static=1 clean"
#
# "make compress" expects strip and upx to be in the path.
#
# DO NOT USE ANY .bat FILES!!!
# make
# make compress
# make clean

cemuObjects=cemu.o 6805_cpu.o emu6805.o rom10.o comm.o debug.o cmd07.o data.o misc.o mapcalls.o logfile.o keycmd.o morph_cpu.o

ifdef DJGPP
CC=gpp
cemu=cemu.exe
else
ifdef mingw
cemu=cemu.exe
else
CC=g++
cemu=cemu
endif
endif

ifdef 32bit
ifdef static
ifdef small
CCOPT=-static -mtune=i386 -march=i386 -m32 -Os -DFAST_CEMU
else
CCOPT=-static -mtune=i386 -march=i386 -m32 -funroll-loops -frerun-loop-opt -fomit-frame-pointer -O3 -Wall -g -DFAST_CEMU
endif
else
ifdef small
CCOPT=-mtune=i386 -march=i386 -m32 -Os -DFAST_CEMU
else
CCOPT=-mtune=i386 -march=i386 -m32 -funroll-loops -frerun-loop-opt -fomit-frame-pointer -O3 -Wall -g -DFAST_CEMU
endif
endif
else
ifdef static
ifdef small
CCOPT=-static -Os -DFAST_CEMU
else
CCOPT=-static -funroll-loops -frerun-loop-opt -fomit-frame-pointer -O3 -Wall -g -DFAST_CEMU
endif
else
ifdef small
CCOPT=-Os -DFAST_CEMU
else
CCOPT=-funroll-loops -frerun-loop-opt -fomit-frame-pointer -O3 -Wall -g -DFAST_CEMU
endif
endif
endif

cemu: $(cemuObjects)

ifdef DJGPP
	$(CC) $(CCOPT) $(cemuObjects) -lcrypto -lgmpxx -lgmp pmcom/rel/com.a -g -o $(cemu)
else
	$(CC) $(CCOPT) $(cemuObjects) -lcrypto -lgmpxx -lgmp -g -o $(cemu)
ifdef cygwin
	cp cemu.exe cemu
endif
endif

compress:
	strip -s $(cemu)
	upx -9 $(cemu)
.cc.o:
ifdef cygwin
	$(CC) -DCYGWIN $(CCOPT) -c $<
else
ifdef mingw
	$(CC) -mno-cygwin $(CCOPT) -c $<
else
	$(CC) $(CCOPT) -c $<
endif
endif

.c.o:
	$(CC) $(CCOPT) -c $<
clean:
ifdef DJGPP
	erase *.o
	erase $(cemu)
else
	rm -f *.o $(cemu)
ifdef cygwin
	rm -f cemu.exe
endif
endif

