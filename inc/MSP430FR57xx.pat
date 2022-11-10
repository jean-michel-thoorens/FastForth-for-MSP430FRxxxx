@set-syntax{C;\;}!  tell GEMA to replace default Comment separator '!' by ';'

;MSP430FR57xx.pat

; ============================================
; RAM
; ============================================

; ----------------------------------------------
; FORTH RAM areas :
; ----------------------------------------------
LSTACK_SIZE=\#16; words
PSTACK_SIZE=\#48; words
RSTACK_SIZE=\#48; words
PAD_LEN=\#84; bytes
CIB_LEN=\#84; bytes
HOLD_SIZE=\#34; bytes
;
; ----------------------------------------------
; FastForth RAM memory map (>= 1k):
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
SOURCE_LEN=\$1DB8;      len of input stream
SOURCE_ORG=\$1DBA;      adr of input stream
TOIN=\$1DBC;            >IN
;
DP=\$1DBE;              dictionary ptr
LASTVOC=\$1DC0;         keep VOC-LINK
CURRENT=\$1DC2;         CURRENT dictionnary ptr
CONTEXT=\$1DC4;         CONTEXT dictionnary space (8 + Null CELLS)
;
; ---------------------------------------
; RAM_ORG + $1D8 : may be shared between FORTH compiler and user application
; ---------------------------------------
LAST_NFA=\$1DD6;
LAST_THREAD=\$1DD8;
LAST_CFA=\$1DDA;
LAST_PSP=\$1DDC;
ASMBW1=\$1DDE;          3 backward labels
ASMBW2=\$1DE0;
ASMBW3=\$1DE2;
ASMFW1=\$1DE4;          3 forward labels
ASMFW2=\$1DE6;
ASMFW3=\$1DE8;
PREV_TOIN=\$1DEA;
; ---------------------------------------
; RAM_ORG + $1EC RAM free 
; ---------------------------------------
;
