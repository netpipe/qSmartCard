# makefile
#
# makefile to build rel/com.a and dbg/com.a
#
#
# Prior to invoke make for the first time provide 'dbg' and 'rel'
# subdirectories in the current directory (provided in the zip archive
# if directory tree preserved while extracting).
#
# Options from the make command line
# _DEBUG=1 -- build debug version
# DISABLE_TIMING=1 -- will disable the library to use the system timer
#   and	this will disable all the xxxTimed() functions from operation as well
# DISABLE_PREEMPTING=1 -- will turn off the ability to be preempted the
#   process of handling COM IRQs.
#
# Output:
#   dbg\com.a  -- in case _DEBUG=1 is specified on make command line.
#     This is debug version of the library. Contains plenty of extra
#     arguments checkings and internal functions control.
#   rel\com.a -- This is release version of the library.
#

ifdef _DEBUG
OUTPUTDIR = dbg
TARGET = dbg/com.a
GCCOPTIONS = -g -Wall -D_DEBUG
else
OUTPUTDIR = rel
TARGET = rel/com.a
GCCOPTIONS = -s -O1 -Wall
endif

ifdef DISABLE_TIMING
TOPTION= -DDISABLE_TIMING
else
TOPTION=
endif

ifdef DISABLE_PREEMPTING
PREOPTION= -DDISABLE_PREEMPTING
else
PREOPTION=
endif

OBJECTS = $(OUTPUTDIR)/wrap_g.o $(OUTPUTDIR)/irq_g.o $(OUTPUTDIR)/com.o \
  $(OUTPUTDIR)/timer.o

# Main target is rel/com.a or dbg/com_dbg.a
$(TARGET): $(OBJECTS)
	ar rs $(TARGET) $(OBJECTS)

# Implicit rule to compile each of the program modules
# $@ stands for the full obj module file name + extention (target file)
# $< stands for the c moudule file name + extention (source file)
$(OUTPUTDIR)/%.o: %.c
	gcc -c $(GCCOPTIONS) $(TOPTION) $(PREOPTION) -o $@ $<

$(OUTPUTDIR)/%.o: %.S
	gcc -c $(GCCOPTIONS) $(TOPTION) $(PREOPTION) -o $@ $<

#
# Header files dependencies
#
com.c: com.h irq.h

irq_g.c: irqwrap.h irq.h

timer.c: timer.h

.PHONY: clean
clean:
	erase $(OUTPUTDIR)\*.o
	erase $(OUTPUTDIR)\*.a

