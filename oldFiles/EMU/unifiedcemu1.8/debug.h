#ifndef __DEBUG__
#define __DEBUG__
#ifndef DEBUG
#define DEBUG

extern unsigned int debug_x;

void debug (void);

#define DEBUG_NONE (1 << 0)
#define DEBUG_BIG (1 << 1)
#define DEBUG_CAM  (1 << 2)
#define DEBUG_SAVE (1 << 3)
#define DEBUG_6805 (1 << 4)
#define DEBUG_MAP (1 << 5)
#define DEBUG_ROM (1 << 6)
#define DEBUG_NYI (1 << 7)
#define DEBUG_OUT (1 << 8)
#define DEBUG_IN (1 << 9)
#define DEBUG_CMD (1 << 10)
#define DEBUG_COMM (1 << 11)
#define DEBUG_RUN (1 << 12)
#define DEBUG_KEY (1 << 13)
#define DEBUG_DEBUG (1 << 14)
#define DEBUG_EMM (1 << 15)
#define DEBUG_CMD07 (1 << 16)
#define DEBUG_B1 (1 << 17)
#define DEBUG_EMU (1 << 18)
#define DEBUG_EMU_0x80 (1 << 19)
#define DEBUG_NAGRA (1 << 20)
#define DEBUG_ALL (0xffffffff)

#define D_BIG if (debug_x & DEBUG_BIG) cout
#define D_CAM if (debug_x & DEBUG_CAM) cout
#define D_SAVE if (debug_x & DEBUG_SAVE) cout
#define D_6805 if (debug_x & DEBUG_6805) cout
#define D_MAP if (debug_x & DEBUG_MAP) cout
#define D_ROM if (debug_x & DEBUG_ROM) cout
#define D_NYI if (debug_x & DEBUG_NYI) cout
#define D_OUT if (debug_x & DEBUG_OUT) cout
#define D_IN if (debug_x & DEBUG_IN) cout
#define D_CMD if (debug_x & DEBUG_CMD) cout
#define D_CMD1 if (debug_x & DEBUG_CMD) cout
#define D_COMM if (debug_x & DEBUG_COMM) cout
#define D_RUN if (debug_x & DEBUG_RUN) cout
#define D_KEY if (debug_x & DEBUG_KEY) cout
#define D_DEBUG if (debug_x & DEBUG_DEBUG) cout
#define D_EMM if (debug_x & DEBUG_EMM) cout
#define D_CMD07 if (debug_x & DEBUG_CMD07) cout
#define D_B1 if (debug_x & DEBUG_B1) cout
#define D_EMU if (debug_x & DEBUG_EMU) cout
#define D_EMU_0x80 if (debug_x & DEBUG_EMU_0x80) cout
#define D_NAGRA if (debug_x & DEBUG_NAGRA) cout

#endif //DEBUG
#endif //__DEBUG__
