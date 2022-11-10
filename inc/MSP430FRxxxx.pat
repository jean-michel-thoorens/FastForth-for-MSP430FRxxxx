
@set-syntax{C;\;}!  tell GEMA to replace default Comment separator '!' by ';'

;MSP430FRxxxx.pat
;FAST_FORTH V4.1

; ============================================
; FRAM INFO
; ============================================
INFO_ORG=\$1800;
INFO_LEN=\$0200;

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
;                       BIT5=assembler 16 bits with 20 bits addr
HMPY=\$10;              BIT4=hardware MPY
;                       BIT3=
;                       BIT2=
;                       BIT1=
;                       BIT0=
; ----------------------------------------------
DEEP_ORG=\$1810;        MOV #DEEP_ORG,X                         TERMINAL
; ----------------------------------------------             UART       I2C
DEEP_TERM_VEC=\$1810;   address of default TERMINAL vect.--> UCAx       UCBx
DEEP_STOP=\$1812;       address of default STOP_APP      --> TX_IDLE    RET
DEEP_ABORT=\$1814;      address of default ABORT_APP:    -->   ABORT_TERM
DEEP_SOFT=\$1816;       address of default SOFT_APP:     -->       RET
DEEP_HARD=\$1818;       address of default HARD_APP:     -->    INIT_TERM
DEEP_BACKGRND=\$181A;   address of default BACKGRND_APP: --> RX_ON    I2C_ACCEPT
DEEP_DP=\$181C;         to DEEP_INIT RST_DP
DEEP_LASTVOC=\$181E;    to DEEP_INIT RST_LASTVOC
DEEP_CURRENT=\$1820;    to DEEP_INIT RST_CURRENT
DEEP_CONTEXT=\$1822;    to DEEP_INIT RST_CONTEXT
;                       NULL_WORD
; ----------------------------------------------
PUC_ABORT_ORG=\$1826;   MOV #PUC_ABORT_ORG,X
; ----------------------------------------------
INIT_ACCEPT=\$1826;     to INIT PFA_ACCEPT
INIT_EMIT=\$1828;       to INIT PFA_EMIT
INIT_KEY=\$182A;        to INIT PFA_KEY
INIT_CIB=\$182C;        to INIT CIB_ORG
;
; ----------------------------------------------
FORTH_ORG=\$182E;       MOV #FORTH_ORG,X
; ----------------------------------------------
INIT_RSP=\$182E;        to INIT RSP
; ----------------------------------------------
INIT_DOXXX=\$1830;      MOV #INIT_DOXXX,X
; ----------------------------------------------
INIT_DOCOL=\$1830;      to INIT rDOCOL   (R4)
INIT_DODOES=\$1832;     to INIT rDODOES  (R5)
INIT_DOCON=\$1834;      to INIT rDOCON   (R6)
INIT_DOVAR=\$1836;      to INIT rDOVAR   (R7)
INIT_BASE=\$1838;       to INIT BASE
INIT_LEAVE=\$183A;      to INIT LEAVEPTR
;
; ----------------------------------------------
RST_ORG=\$183C;
RST_LEN=\$14;           20 bytes
; ----------------------------------------------
STOP_APP=\$183C;        address of current STOP_APP
ABORT_APP=\$183E;       address of current ABORT_APP
SOFT_APP=\$1840;        address of current SOFT_APP
HARD_APP=\$1842;        address of current HARD_APP
BACKGRND_APP=\$1844;    address of current BACKGRND_APP
RST_DP=\$1846;          RST_RET value for (RAM) DDP
RST_LASTVOC=\$1848;     RST_RET value for (RAM) LASTVOC
RST_CURRENT=\$184A;     RST_RET value for (RAM) CURRENT
RST_CONTEXT=\$184C;     RST_RET value for (RAM) CONTEXT (8 CELLS) + NULL_WORD
;
; ===============================================
; FAST FORTH V 4.0: FRAM usage, INFO space free from $1860 to $19FF
; ===============================================
;
; ============================================
; FRAM TLV
; ============================================
TLV_ORG=\$1A00;         Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN=\$0100;       
DEVICEID=\$1A04;

; ============================================
; FRAM MAIN
; ============================================
; to use in ASSEMBLER mode
;
\#INIT_FORTH=\#\!+8;            common QABORT_YES|WARM subroutine used to init FORTH and its interpreter
\#ABORT_TERM=\#\!+\$3C;         CALL #ABORT_TERM to discard pending TERMINAL download
\#TOS2WARM=\#SYS+\$0E;          CALL #TOS2WARM      to do WARM with TOS value
TOS2WARM=\' SYS \$0E +
\#TOS2COLD=\#SYS+\$14;          CALL #TOS2COLD      to do COLD with TOS value
TOS2COLD=\' SYS \$14 +
\#I2C_CTRL=\#KEY+\$0A;          used as is: MOV.B #<CTRL_CHAR>,Y
;                                           CALL #I2C_CTRL
\#UART_RXON=\#KEY+8;            CALL #UART_RXON
\#UART_RXOFF=\#ACCEPT+\$26;     CALL #UART_RXOFF
\#BACKGRND=\#ACCEPT+\$1C;       MOV #BACKGRND,PC
\#NEXT_ADR=\#\[THEN\];          FORTH CODE NEXT instruction (MOV @IP+,PC)
\#LIT=\#\[THEN\]+2;             asm CODE run time of LITERAL
\#XSQUOTE=\#\[THEN\]+\$16;      asm CODE run time of QUOTE     
\#SETIB=\#\[THEN\]+\$2A;        FORTH CODE Set Input Buffer with org & len values, reset >IN pointer 
\#REFILL=\#\[THEN\]+\$3A;       FORTH CODE accept one line from input and leave org len of input buffer
\#CIB_ORG=\#\[THEN\]+\$46;      [CIB_ORG] = TIB_ORG by default; may be redirected to SDIB_ORG
\#QFBRAN=\#\[THEN\]+\$52;       FORTH CODE compiled by IF UNTIL
\#BRAN=\#\[THEN\]+\$58;         FORTH CODE compiled by ELSE REPEAT AGAIN
\#XDODOES=\#\[THEN\]+\$5C;      to restore rDODOES: MOV #XDODOES,rDODOES
\#XDOCON=\#\[THEN\]+\$6A;       to restore rDOCON: MOV #XDOCON,rDOCON    
\#XDOVAR=\&\$1836;              to restore rDOVAR: MOV &INIT_DOVAR,rDOVAR
\#XDOCOL=\&\$1830;              to restore rDOCOL: MOV &INIT_DOCOL,rDOCOL
\#MUSMOD=\#\<\#+8;              asm CODE 32/16 unsigned division, used by ?NUMBER, UM/MOD
\#MDIV1DIV2=\#\<\#+\$1A;        asm CODE input for 48/16 unsigned division with DVDhi=0, see DOUBLE M*/
\#MDIV1=\#\<\#+\$22;            asm CODE input for 48/16 unsigned division, see DOUBLE M*/
\#RET_ADR=\#\<\#+\$4C;          asm CODE            used by MARKER
\#D\.=\#U\.+\$0A;               MOV #D.,PC          used in DOUBLE.f
\#BL_WORD=\#WORD+2;
\#INTERPRET=\#\\+8;             MOV #INTERPRET,PC   used in CORE_ANS.f
\#EXECUTE=\#\\+\$28;            MOV #EXECUTE,PC     used in CORE_ANS.f
\#ABORT=\#ALLOT+8;              MOV #ABORT,PC       used in CORE_ANS.f
\#QUIT=\#ALLOT+\$0E;            MOV #QUIT,PC        used in CORE_ANS.f
\#Read_File=\&READ+\$0C;        CALL #Read_File, sequentially load a sector in SD_BUF
\#Write_File=\#WRITE+\$4;       CALL #Write_File, sequentially write SD_BUF in a sector
