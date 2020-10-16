# com_bc.mak
# Make file to build com.lib and com_dbg.lib
#
# Prior to invoke make for the first time provide 'dbg' and 'rel'
# subdirectories in the current directory.
#
# Options from the make command line
# -D_DEBUG -- build debug version
# -DDISABLE_TIMING -- will disable the library to use the system timer
#   and	this will disable all the xxxTimed() functions from operation as well
# -DDISABLE_PREEMPTING -- will turn off the ability to be preempted the
#   process of handling COM IRQs.
# -DP386 -- will turn on '-3' option of the compiler and will push
#   all the 32bit registers in the IRQ wrappers.
#
# Output:
#   dbg\com.lib  -- in case /D_DEBUG specified on make command line.
#     This is debug version of the library. Contains plenty of extra
#     arguments checkings and internal functions control.
#   rel\com.lib -- This is release version of the library.
#

!ifdef _DEBUG
OUTPUTDIR = dbg
TARGET = dbg\com.lib
BCCOPTIONS = -v -D_DEBUG -O1 -ml
!else
OUTPUTDIR = rel
TARGET = rel\com.lib
BCCOPTIONS = -O1 -ml
!endif

!ifdef DISABLE_TIMING
TOPTION = -DDISABLE_TIMING
!else
TOPTION =
!endif

!ifdef DISABLE_TIMING
PREOPTION = -DDISABLE_PREEMPTING
!else
PREOPTION =
!endif

!ifdef P386
P386OPTION = -DPUSH386 -3
!else
p386OPTION = -1
!endif

.path.obj = $(OUTPUTDIR)
.path.lib = $(OUTPUTDIR)

MODULES = wrap_bc.obj irq_bc.obj com.obj timer.obj

#
# NOTE: When this make file is invoked for first time tlib may show
# a harmless warning.
#
.c.obj:
  bcc -c $(BCCOPTIONS) $(TOPTION) $(PREOPTION) $(P386OPTION) -n$(.path.obj) $<
  tlib $(TARGET) +-$@

$(TARGET): $(MODULES)

#
# Header files dependencies
#
com.c: com.h irq.h timer.h

wrap_bc.c: irqwrap.h

irq_bc.c: irqwrap.h irq.h

timer.c: timer.h

