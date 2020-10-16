;
; This version uses a larger cmd buffer for the N2 CMD $04 and CMD $07.
; This version spoofs ROM101 Rev007 ATR with IFS=0x78/120d.
;
;ird2pc design:
;ISO/IRD     Atmel                 MC1489          DB9 Female
;CLK     --- 5  (XTAL1)
;I/O     --- 2  (PD0/RxD)
;Reset   --- 7  (PD3/INT1)
;            19 (PB7/SCK)  ------- 4i 6o   ------- pin 2 RxD PC receives
;            17 (PB5/MOSI) ------- 8o 10i  ------- pin 3 TxD PC transmits
;                          ------- 1i 3o   ------- pin 1 DCD
;                          ------- 11o 13i ------- pin 8 CTS 
;GND     --- 10 (GND)      ------- 7(GND)  ------- pin 5 GND
;Vcc     --- 20 (Vcc)      ------- 14(Vcc)

.NOLIST
.include "2313def.inc"
.LIST

.equ  IRDIO      = PD0  ; ird2pc uses PD0
.equ  IRDRESET   = PD3  ; ird2pc uses PD3
.equ  IRDPIN     = PIND ; ird2pc uses PIND

.equ  AtmelTxD   = PB7   ; ird2pc uses PB7
.equ  TxPORT     = PORTB ; ird2pc uses PORTB
.equ  TxDIR      = DDRB  ; ird2pc uses DDRB
.equ  AtmelRxD   = PB5
.equ  RxPIN      = PINB

.equ  IRDTx      = IRDIO
.equ  IRDRx      = IRDIO

.equ StackSize = 8

.def SID  =  R1	; System ID
.def NAD  =  R2	; Network Address (0x21 from IRD, 0x12 from card, 0x31 from PC)
.def PCB  =  R3	; Procedure Control Block
.def LEN  =  R4	; Message length
.def LRC  =  R5	; Message Checksum

; Segment type:	Pure code
.CSEG ;	ROM
		rjmp	Ext_RST		; Reset
		reti			;[v2] do nothing External Int 0
		rjmp	Ext_Int		; External Int 1 - ISO7816 Reset line
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
		
;----------------------------------------------------------------------------------------------------------
	    
Ext_RST:	
		sbi	ACSR, 7		; Turn off ADC
		cli
		clr	r16
		out	GIMSK, r16	; Disable INT 0	& 1
		out	MCUCR, r16	; No Extern SRAM, Low level on INT 0&1 generates interrupt
;
;  Setup PORT output pins
;
                ldi     r16, (1<<IRDIO) ; Float IRDIO High
                out     TxPORT, r16
		ldi	r16, (1<<AtmelTxD)
		out	TxDIR, r16	; AtmelTxD is output, others inputs

; External Int - We get	here when the ISO reset	line is	activated (active low)
Ext_Int:
		SBI     TxPORT,AtmelTxD	; 
	
		ldi	r16, Low(sStack) ; Set stack to 0x0067
		out	SPL, r16
RstLow:
		sbis	IRDPIN, IRDRESET ; Wait for reset to go high
		rjmp	RstLow

		cli

		ldi	r16, 0x80	; [v2]
		out	GIMSK, r16	; [v2] Int 1 enabled only
		sei

		ldi	r25, 32		; delay 99 clocks
		rcall	Delay
	
		ldi	ZL, Low(ATR_data*2)
		ldi	ZH, High(ATR_data*2) ; Z = 0x023C (Flash 0x011E * 2) ATR in FLASH 16-bit addr
					; 
		ldi	r18, 27		; ATR is 27 bytes long
SendATRLp:
		lpm			; Get byte of ATR in R0, R0 <- (Z)

		adiw	ZL, 1		; Inc Z
		mov	r16, r0
		rcall	TX_ATR	
		brne	SendATRLp

MainLoop:
		ldi	r16, Low(sStack) ; Set stack to 0x0067
		out	SPL, r16

                                        ; Save NAD,PCB,LEN,LRC in registers to save Buffer space
		rcall	InitYbuf
		rcall	RX_IRD          ; NAD
		mov     NAD, r16
		rcall	RX_IRD          ; PCB
		mov     PCB, r16     
		rcall	RX_IRD          ; LEN
		mov	LEN, r16
		tst	LEN		; zero len message ?
		breq	RXIRDZEROLENGTH
		mov	r18, LEN
		
RXIRDDATALOOP:
		rcall	RX_IRD
		st	Y+, r16		; store	msg in Buffer
		dec	r18		; dec count
		brne	RXIRDDATALOOP	; read in msg bytes

RXIRDZEROLENGTH:
		rcall	RX_IRD		; LRC
		mov     LRC, r16
		
;------------------------------------------------------------------------------------				

                mov     r16, NAD        ; Send NAD, PCB, LEN to PC
                rcall   TX_PC
                mov     r16, PCB
                rcall   TX_PC
                mov     r16, LEN
                rcall   TX_PC
                tst     LEN
                breq    TXPCLRC
                
		mov     r18,LEN
		rcall	InitYbuf
TXPCLOOP:
		ld      r16,Y+
		rcall   TX_PC
		dec     r18
		brne    TXPCLOOP

TXPCLRC:		
		mov     r16, LRC        ; Send LRC
		rcall   TX_PC

;------------------------------------------------------------------------------------				
RX_FROM_PC:
		rcall	InitYbuf        ; Init Y ptr to start of Buffer
		rcall	RX_PC           ; NAD
		mov     NAD, r16
		rcall	RX_PC           ; PCB
		mov     PCB, r16
		rcall	RX_PC           ; LEN
		mov	LEN, r16
		tst	LEN		; zero len message ?
		breq	RXPCZEROLENGTH
		mov	r18, LEN
		
RXPCDATALOOP:
		rcall	RX_PC
		st	Y+, r16		; store	in Buffer
		dec	r18		; dec count
		brne	RXPCDATALOOP	; read in message bytes

RXPCZEROLENGTH:
		rcall	RX_PC	        ; LRC
		mov     LRC, r16
		
;------------------------------------------------------------------------------------				
TX_TO_IRD:
                mov     r16, NAD        ; Send NAD, PCB, LEN to IRD
                rcall   TX_IRD
                mov     r16, PCB
                rcall   TX_IRD
                mov     r16, LEN
                rcall   TX_IRD
                tst     LEN
                breq    TXIRDLRC
		mov     r18,LEN		
		rcall	InitYbuf        ; Init Y ptr to start of Buffer
		
TXIRDLOOP:
		ld      r16,Y+
		rcall   TX_IRD
		dec     r18
		brne    TXIRDLOOP

TXIRDLRC:
		mov     r16, LRC        ; Send LRC
		rcall   TX_IRD
		
		rjmp MainLoop

;------------------------------------------------------------------------------------
; TX line is PD0, TO IRD FROM AVR
; 32 cycles per ETU
; stack use 1(push)+2(rcall)=3
TX_IRD:
		push    r18
TxP0_start:
		sbis	PIND, IRDTx	; wait for I/O to go high - line idle
		rjmp	TxP0_start


		sbi	DDRD, IRDTx	; set I/O line as output (TX)
		ldi	r25, 8
		rcall	Delay		; 27 clocks, guard time
		rjmp	TxP0_L1

TxP0_L1:				; set TX low (start bit)
		cbi	PORTD, IRDTx
		rjmp	TxP0_L2
TxP0_L2:
		rjmp	TxP0_L3
TxP0_L3:
		nop
		ldi	r18, 8		; count	8 bits
		clr	r24		; clear	parity reg

TxP0_L4:				; Start of loop transmitting 32 cycles per ETU
		ldi	r25, 4		; delay 15 clocks
		rcall	Delay
		nop
		rol	r16		; put MSb into carry
		brcs	TxP0_L10	; jump if bit =	1
		nop
		sbi	PORTD, IRDTx	; bit =	0 so set TX high (inverted data)
		rjmp	TxP0_L5         ; start counting here

TxP0_L10:
		cbi	PORTD, IRDTx	; bit =	1 so set TX low	(inverted data)
		rjmp	TxP0_L5		; send more bits, start counting here
		
TxP0_L5:
		adc	r24, r25	; calc parity
		andi	r24, 1
		dec	r18		; dec count of bits
		brne	TxP0_L4		; TX 8 bits


		ldi	r25, 4		; delay 15 clocks
		rcall	Delay
		rjmp	TxP0_L6
TxP0_L6:				
		ror	r24             ; put parity bit into carry
		brcs	TxP0_L9
		nop
		sbi	PORTD, IRDTx	; bit =	0 so set TX high (inverted data)
		rjmp	TxP0_L7

TxP0_L9:
		cbi	PORTD, IRDTx	; bit =	1 so set TX low	(inverted data)
		rjmp	TxP0_L7		; done sending
		
TxP0_L7:
		ldi	r25, 7		; delay 24 clocks
		rcall	Delay
				
		sbi	PORTD, IRDTx    ; set I/O line high
		cbi	DDRD, IRDTx	; set I/O line to input	(RX)
		pop     r18
		ret
		
;---------------------------------
; Receive byte from IRD into r16
; 32 cycles per ETU
; stack use is 1(push)

RX_IRD:
		push    r18
RxP0_start:
		sbis	PIND, IRDRx	; wait for RX to go high = line	idle
		rjmp	RxP0_start

RxP0_L1:
		sbic	PIND, IRDRx	; wait for RX to go low	= start	bit
		rjmp	RxP0_L1

		ldi	r25, 6          ; start counting here
RxP0_L2:	dec	r25
		brne	RxP0_L2		; delay 18 cycles, 1/2 ETU

		ldi	r16, 1		; set "mark bit" flag

                                        ; Start of loop sampling every 32 cycles per ETU
RxP0_L3:
		ldi	r25, 8
RxP0_L4:	dec	r25
		brne	RxP0_L4		; delay 24 cycles

                nop                     ; delay 3 more cycles before sampling
                nop
                clc     
                sbic    PIND, IRDRx     ; Skip next if IO Low, start counting here
                sec
                
		rol	r16		; C << r16 << C
		                        ; shift	bit into LSB of	R16 - this will	bit reverse 
		                        ;   the received data
		brcc	RxP0_L3		; loop until "mark bit" is shifted into carry

		com	r16		; invert data

		ldi	r25, 9
RxP0_L5:	dec	r25
		brne	RxP0_L5		; delay 27 cycles

RxP0_L6:
		sbis	PIND, IRDRx	; wait for line	to go high = inactive
		rjmp	RxP0_L6
		pop     r18
		ret

;------------------------------------------------------------------------------------
; 39 cycles per ETU, 115,384 baud at 4.5Mhz
; stack use is 0

RX_PC:	

WAIT_FOR_232_START_BIT:

	SBIS    RxPIN,AtmelRxD		; skip next if RX high
	rjmp	RX_232_low
	rjmp	WAIT_FOR_232_START_BIT	; loop back until RX is low
			
RX_232_low:                             ; start bit seen
	LDI     R25,7	                ; start counting here
rx_pc_l1:	
	dec     r25
	brne    rx_pc_l1		; delay 21 cycles, 1/2 ETU
	NOP
	
	LDI     r16,0b10000000          ; set "mark bit" flag
	
Receive_Bit_Loop:                       ; Start of loop to sample every 39 cycles per ETU
	LDI     R25,11			; value to delay
rx_pc_l2:	
	dec     r25
	brne    rx_pc_l2                ; delay 33 cycles

        clc                             ; C=0
        sbic    PIND,AtmelRxD           ; Skip next if PC IO Low, start counting here
        sec                             ; C=1

	ROR     r16                     ; C >> r16 >> C        
	BRCC    Receive_Bit_Loop	; Loop if more data bits needed

	NOP				; do nothing-waste cycle

	LDI     r25,10	                ; duration of stop bit(s)
rx_pc_l3:	
	dec     r25                     ; delay 30 cycles
	brne    rx_pc_l3
			

wait_sb_low:
	SBIS	RxPIN,AtmelRxD 		; get next byte when RX high	
	rjmp    wait_sb_low

        ret

;---------------------------------------------------------------------------------------
; 39 ETU 115,384 at 4.5Mhz
; send byte in r16 to PC
; stack use is 1(push)

TX_PC:
	push    r18
	
	cbi     TxPORT,AtmelTxD	  ; send start bit
	ldi     r25,11            ; start counting here
TX_PC_L1:
	dec     r25
	brne    TX_PC_L1          ; delay 33 cycles
	
	ldi     r24,8             ; send 8 bits
	
TX_PC_SETNEXTBIT:                 ; Start of loop transmitting 39 cycles per ETU
	ror     r16               ; C << r16 << C
	brcs    TX_PC_SETHIGH     ; if C==1 output High
	
TX_PC_SETLOW:
	nop                       ; balance
	cbi     TxPORT,AtmelTxD	  ; data bit == 0 so output Low	
        rjmp    TX_PC_L2          ; start counting here

TX_PC_SETHIGH:	
	sbi     TxPORT,AtmelTxD	  ; data bit == 1 so output High	
	rjmp    TX_PC_L2          ; start counting here

TX_PC_L2:
        nop
        nop
	ldi     r25,9	
TX_PC_L3:
	dec     r25
	brne    TX_PC_L3          ; delay 27 cycles
	
	dec     r24
	brne    TX_PC_SETNEXTBIT
	rjmp    TX_PC_DONETX
	
TX_PC_DONETX:	
	sbi     TxPORT,AtmelTxD	  ; output High	
	ldi     r25,9
	rcall   delay             ; delay 30 cycles
	
	pop     r18
	ret
	
;---------------------------------------------------------------------------------------
; 372 cycles per ETU
; send byte in r16 to IRD
; stack use is 1(push)+2(rcall)=3

TX_ATR:
		push	r18		; save count
		sbi	DDRD, IRDTx	; AVR uses PD0 as I/O Line - so set to output


		ldi	r25, 240	; delay	723 cycles, guard time
		rcall	Delay


		cbi	PORTD, IRDTx	; set TX line low for start bit
		rjmp	TaL1            ; start counting here

TaL1:
		rjmp	TaL2

TaL2:				        ; save the data	byte - although	it's not used.
		mov	r15, r16


		ldi	r18, 8		; 8 bits
		clr	r24		; clear	parity

Ta8bits:				; Start of loop to transmit 372 cycles per ETU
		ldi	r25, 117        ; delay 354 cycles
		rcall	Delay
		rjmp	TaL3

TaL3:		rol	r16             ; put data bit into carry - send MSb first
		brcs	Ta_TXhi		; jump if bit == 1
		nop
		sbi	PORTD, IRDTx    ; data bit = 0 so set TX line High (inverted)
		rjmp	TaL4            ; start counting here

Ta_TXhi:	cbi	PORTD, IRDTx	; data bit = 1 so set TX line Low (inverted)
		rjmp	TaL4            ; start counting here
		
TaL4:
		adc	r24, r25
		andi	r24, 1		; calculate parity
		dec	r18
		brne	Ta8bits

		ldi	r25, 118	; 357 clocks
		rcall	Delay

		ror	r24		; check	parity
		brcs	Ta_TXhi9        ; jump if parity bit == 1
		nop
		sbi	PORTD, IRDTx	; parity bit = 0 so set TX High (inverted)
		rjmp	TaDone

Ta_TXhi9: 
		cbi	PORTD, IRDTx	; parity bit = 1 so set TX Low (inverted)
		rjmp	TaDone
		
TaDone:	
		ldi	r25, 120	; 363 clocks
		rcall	Delay


		nop
		sbi	PORTD, IRDTx	; TX line low
		cbi	DDRD, IRDTx	; set I/O line to input	(RX)
		pop	r18		; restore count
		dec	r18		; dec count, sent 1 byte of ATR
		ret

; End of function TX_ATR


;  InitYbuf; Y = addr to head of data buffer
;
InitYbuf:
		ldi	YL, low(Buffer) ; Y <- 0x0068
		ldi	YH, high(Buffer)
		ret
; End of function InitYbuf
		
;-----------------------------------
;
; Delay	-  timing = 3 +	3 x R25	 cycles
;
Delay:
		dec	r25
		brne	Delay
		ret
; End of function Delay
           
; ATR - LRC is next to last byte on 2nd line
; LRC is all bytes(from T0 to TK) XORed together except for TS(0x3F) char.
;                    D  N  A  S  P  1  0  1    R   e  v  0  0  7 LRC
; DNASP101 Rev007 = 44 4E 41 53 50 31 30 31 20 52 65 76 30 30 37 E5
; ATR FF to 71, LRC=F4
; TA3 78      , LRC=78, receive block size(IFS) now 0x78/120d, old was 0x64/100d
;     47 to 50, LRC=0F
;     31 to 37, LRC=66
; LRC=F4^78^0F^66=E5
; DNASP101 Rev007 IFS=0x78/120d
; data stored in 16-bit Flash ROM and needs to be aligned so an extra 00 byte is added.
ATR_data:   .db 0x3F,0xFF,0x95,0x00,0xFF,0x91,0x81,0x71,0x78,0x47,0x00,0x44,0x4E,0x41
	    .db 0x53,0x50,0x31,0x30,0x31,0x20,0x52,0x65,0x76,0x30,0x30,0x37,0xE5,0x00

.ESEG ;	EEPROM

; Segment type:	Pure data
.DSEG ;	RAM
	   .org 0x60      ; 128d bytes of SRAM
	
sRAMstart: .byte StackSize   ; size of stack is 8
.set sStack = sRAMStart + StackSize - 1 ; sStack <- 0x0067

Buffer:	   .byte 120  ; 120d/0x78 buffer for msg data
           .exit
