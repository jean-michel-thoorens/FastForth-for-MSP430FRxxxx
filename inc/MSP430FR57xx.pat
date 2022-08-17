
@set-syntax{C;\;}!  tell GEMA to replace default Comment separator '!' by ';'
;MSP430FR57xx.pat

; ----------------------------------------------
; FastForth RAM memory map (= 1k):
; ----------------------------------------------
LEAVEPTR=\$1C00;        Leave-stack pointer, init by QUIT
LSATCK=\$1C00;          leave stack,      grow up
PSTACK=\$1C80;          parameter stack,  grow down
RSTACK=\$1CE0;          Return stack,     grow down
;
PAD_I2CADR=\$1CE0;      RX I2C address
PAD_I2CCNT=\$1CE2;      count max
PAD_ORG=\$1CE4;         user scratch pad buffer, 84 bytes, grow up
;
TIB_I2CADR=\$1D38;      TX I2C address
TIB_I2CCNT=\$1D3A;      count of bytes
TIB_ORG=\$1D3C;         Terminal input buffer, 84 bytes, grow up
;
HOLDS_ORG=\$1D90;       base address for HOLDS
HOLD_BASE=\$1DB2;       BASE HOLD area, grow down
;
HP=\$1DB2;              HOLD ptr
STATEADR=\$1DB4;        Interpreter state
BASEADR=\$1DB6;         base
CAPS=\$1DB8;            CAPS ON/OFF
SOURCE_LEN=\$1DBA;      len of input stream
SOURCE_ORG=\$1DBC;      adr of input stream
TOIN=\$1DBE;            >IN
;
DP=\$1DC0;              dictionary ptr
LASTVOC=\$1DC2;         keep VOC-LINK
CURRENT=\$1DC4;         CURRENT dictionnary ptr
CONTEXT=\$1DC6;         CONTEXT dictionnary space (8 + Null CELLS)
;
; ---------------------------------------
; RAM_ORG + $1DD8 : may be shared between FORTH compiler and user application
; ---------------------------------------
LAST_NFA=\$1DD8;
LAST_THREAD=\$1DDA;
LAST_CFA=\$1DDC;
LAST_PSP=\$1DDE;
ASMBW1=\$1DE0;          3 backward labels
ASMBW2=\$1DE2;
ASMBW3=\$1DE4;
ASMFW1=\$1DE6;          3 forward labels
ASMFW2=\$1DE8;
ASMFW3=\$1DEA;
;
; ---------------------------------------
; RAM_ORG + $1DEC RAM free 
; ---------------------------------------
;
