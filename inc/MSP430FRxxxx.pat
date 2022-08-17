
@set-syntax{C;\;}!  tell GEMA to replace default Comment separator '!' by ';'
;MSP430FRxxxx.pat

; ============================================
; FRAM INFO
; ============================================
; INFO_ORG=\$1800;

; You can check the addresses below by comparing their values in DTCforthMSP430FRxxxx.lst
; those addresses are usable with the symbolic assembler

FREQ_KHZ=\$1800;        FREQUENCY (in kHz)
TERMBRW_RST=\$1802;     TERMBRW_RST
TERMMCTLW_RST=\$1804;   TERMMCTLW_RST
I2CSLAVEADR=\$1802;     I2C_SLAVE address
I2CSLAVEADR1=\$1804;
LPM_MODE=\$1806;        LPM_MODE value, LPM0+GIE is the default value
USERSYS=\$1808;         user SYS variable, defines software RESET, DEEP_RST, INIT_HARWARE, etc.
VERSION=\$180A;
THREADS=\$180C;         THREADS
; ---------------------------------------------
KERNEL_ADDON=\$180E;
; ---------------------------------------------
FLOORED=\$8000;         BIT15=FLOORED DIVISION
LF_XTAL=\$4000;         BIT14=LF_XTAL
;                       BIT13=UART CTS
;                       BIT12=UART RTS
;                       BIT11=UART XON/XOFF
;                       BIT10=UART half duplex
;                       BIT9=I2C_TERMINAL
;                       BIT8=Q15.16 input
;                       BIT7=DOUBLE input
;                       BIT6=assembler 20 bits
;                       BIT5=assembler 16 bits
;                       BIT4=assembler 16 bits with 20 bits addr
HMPY=8;                 BIT3=hardware MPY
;                       BIT2=
;                       BIT1=
;                       BIT0=
; ----------------------------------------------
DEEP_ORG=\$1810;        MOV #DEEP_ORG,X
; ----------------------------------------------
DEEP_TERM_VEC=\$1810;   address of default TERMINAL vector
DEEP_STOP=\$1812;       address of default STOP_APP
DEEP_SOFT=\$1814;       address of default SOFT_APP
DEEP_HARD=\$1816;       address of default HARD_APP
DEEP_BACKGRND=\$1818;   address of default BACKGRND_APP
DEEP_DP=\$181A;         to DEEP_INIT RST_DP
DEEP_LASTVOC=\$181C;    to DEEP_INIT RST_LASTVOC
DEEP_CURRENT=\$181E;    to DEEP_INIT RST_CURRENT
DEEP_CONTEXT=\$1820;    to DEEP_INIT RST_CONTEXT
;
; ----------------------------------------------
PUC_ABORT_ORG=\$1822;   MOV #PUC_ABORT_ORG,X
; ----------------------------------------------
INIT_ACCEPT=\$1822;     to INIT PFA_ACCEPT
INIT_EMIT=\$1824;       to INIT PFA_EMIT
INIT_KEY=\$1826;        to INIT PFA_KEY
INIT_CIB=\$1828;        to INIT CIB_ORG
;
; ----------------------------------------------
FORTH_ORG=\$182A;       MOV #FORTH_ORG,X        \to preserve the state of DEFERed words
; ----------------------------------------------
INIT_RSP=\$182A;        to INIT RSP
; ----------------------------------------------
INIT_DOXXX=\$182C;      MOV #INIT_DOXXX,X       \ to restore DOxxx registers
; ----------------------------------------------
INIT_DOCOL=\$182C;      to INIT rDOCOL   (R4) to restore rDOCOL: MOV &INIT_DOCOL,rDOCOL
INIT_DODOES=\$182E;     to INIT rDODOES  (R5)
INIT_DOCON=\$1830;      to INIT rDOCON   (R6)
INIT_DOVAR=\$1832;      to INIT rDOVAR   (R7)
INIT_CAPS=\$1834;       to INIT CAPS
INIT_BASE=\$1836;       to INIT BASE
INIT_LEAVE=\$1838;      to INIT LEAVEPTR
;
; ----------------------------------------------
RST_ORG=\$183A;
RST_LEN=\$10;           16 bytes
; ----------------------------------------------
STOP_APP=\$183A;        address of current STOP_APP
SOFT_APP=\$183C;        address of current SOFT_APP
HARD_APP=\$183E;        address of current HARD_APP
BACKGRND_APP=\$1840;    address of current BACKGRND_APP
RST_DP=\$1842;          RST_RET value for (RAM) DDP
RST_LASTVOC=\$1844;     RST_RET value for (RAM) LASTVOC
RST_CURRENT=\$1846;     RST_RET value for (RAM) CURRENT
RST_CONTEXT=\$1848;     RST_RET value for (RAM) CONTEXT (8 CELLS)
;
; ===============================================
; FAST FORTH V 4.0: FRAM usage, INFO space free from $185A to $19FF
; ===============================================
;
; ============================================
; FRAM TLV
; ============================================
TLV_ORG=\$1A00;         Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN=\$0100;       
DEVICEID=\$1A04;

; ============================================
; FORTH RAM areas :
; ============================================
LSTACK_SIZE=\#16; words
PSTACK_SIZE=\#48; words
RSTACK_SIZE=\#48; words
PAD_LEN=\#84; bytes
CIB_LEN=\#84; bytes
HOLD_SIZE=\#34; bytes

; ============================================
; FRAM MAIN
; ============================================
; to use in ASSEMBLER mode
; see device.pat for other addresses

I2C_CTRL=KEY\+\$0A;         used as is: MOV.B #<CTRL_CHAR>,Y
;                                           CALL #I2C_CTRL
\#UART_RXON=\#KEY\+8;           CALL #UART_RXON
\#UART_RXOFF=\#ACCEPT\+\$26;    CALL #UART_RXOFF
\#BACKGRND=\#ACCEPT\+\$1C;      MOV #BACKGRND,PC
\#STOP_APP=\&SYS\+2;            CALL #STOP_APP     
\#TOS2WARM=\#SYS\+\$0E;         CALL #TOS2WARM      WARM with TOS value
\#TOS2COLD=\#SYS\+\$14;         CALL #TOS2COLD      COLD with TOS value
INTERPRET=\\+\$08;              address used in CORE_ANS.f
\#ABORT=\#ALLOT\+\$08;          MOV #ABORT,PC   used in CORE_ANS.f
\#QUIT=\#ALLOT\+\$0E;           MOV #QUIT,PC    used in CORE_ANS.f
\#D\.=\#U\.+\$0A;               MOV #D.,PC      used in DOUBLE.f
\#Read_File=\&READ\+\$0C;       CALL #Read_File, sequentially load a sector in SD_BUF
\#Write_File=\#WRITE\+4;        CALL #Write_File, sequentially write SD_BUF in a sector
