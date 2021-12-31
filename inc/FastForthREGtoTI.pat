!FastForthREGtoTI.pat
! ============================================
! translate Forth registers to TI's ones
! ============================================

PC=R0!
SP=R1!
RSP=R1!
SR=R2!
CG1=R2!
CG2=R3!
rDOCOL=R4!
rDODOES=R5!
rDOCON=R6!
rDOVAR=R7!
R=R4!
Q=R5!
P=R6!
M=R7!
Y=R8!
X=R9!
W=R10!
T=R11!
S=R12!
IP=R13!
TOS=R14!
PSP=R15!

! forth words filter
\"\s*\"=\"\s*\"!            ." xxxx" filter
S\"\s*\"=S\"\s*\"!          S" xxxx" filter
s\"\s*\"=S\"\s*\"!          s" xxxx" filter
\(\s*\)=\(\s*\)!            ( xxxx) and .( xxxx) filter
abort\"\s*\"=ABORT\"\s*\"!  abort" xxxx" filter
ABORT\"\s*\"=ABORT\"\s*\"!  ABORT" xxxx" filter
!
D\.R=D\.R!
!
M\*=M\*!
M\+=M\+!
!
R\>=R\>!
R\@=R\@!
\>R=\>R!
!
S\>=S\>!
\>S=\>S!
S\<=S\<!
S\>\==S\>\=!
\.S=\.S!
\s\_=\S\_!                  s_   filter
\S\_=\S\_!                  S_   filter
!
\<\#=\<\#!
\#S=\#S!
\#\>=\#\>!
!
T\{=T\{!
\}T=\}T!
!
U\.R=U\.R!
!
! ASCII numbers interpreter complement
'NUL'=\$00!
'SOH'=\$01!
'STX'=\$02!
'ETX'=\$03!
'EOT'=\$04!
'ENQ'=\$05!
'ACK'=\$06!
'BEL'=\$07!
'BS'=\$08!    Backspace
'HT'=\$09!    Horizontal Tabulation
'LF'=\$0A!
'VT'=\$0B!
'FF'=\$0C!
'CR'=\$0D!
'SO'=\$0E!
'SI'=\$0F!
'DLE'=\$10!
'DC1'=\$11!
'XON'=\$11!
'DC2'=\$12!
'DC3'=\$13!
'XOFF'=\$13!
'DC4'=\$14!
'NAK'=\$15!
'SYN'=\$16!
'ETB'=\$17!
'CAN'=\$18!
'EM'=\$19!
'SUB'=\$1A!
'ESC'=\$1B! escape char
'FS'=\$1C!
'GS'=\$1D!
'RS'=\$1E!
'US'=\$1F!
'SP'=\$20!
'DEL'=\$7F!
'R'='R'!
'Q'='Q'!
'P'='P'!
'M'='M'!
'Y'='Y'!
'X'='X'!
'W'='W'!
'T'='T'!
'S'='S'!
(SW1)=(SW1)!
(SW2)=(SW2)!
(RST)=(RST)!
\/RTS=\/RTS!
\/CTS=\/CTS!
XON\/XOFF=XON\/XOFF!

! ============================================
! SR bits :
! ============================================
\#C=\#1!        = SR(0) Carry flag
\#Z=\#2!        = SR(1) Zero flag
\#N=\#4!        = SR(2) Negative flag
\#V=\#\$100!    = SR(8) oVerflow flag
GIE=8!          = SR(3) Enable Int
CPUOFF=\$10!    = SR(4) CPUOFF
OSCOFF=\$20!    = SR(5) OSCOFF
SCG0=\$40!      = SR(6) SCG0
SCG1=\$80!      = SR(7) SCG1
UF9=\$200!      = SR(9) User Flag 1 used by ?NUMBER --> INTERPRET --> LITERAL to process double numbers, else free for use.
UF10=\$400!     = SR(10) User Flag 2
UF11=\$800!     = SR(11) User Flag 3

LPM4=\$F0! SR(LPM4)
LPM3=\$D0! SR(LPM3)
LPM2=\$90! SR(LPM2)
LPM1=\$50! SR(LPM1)
LPM0=\$10! SR(LPM0)

! ============================================
! PORTx, Reg  bits :
! ============================================
BIT0=1!
BIT1=2!
BIT2=4!
BIT3=8!
BIT4=\$10!
BIT5=\$20!
BIT6=\$40!
BIT7=\$80!
BIT8=\$100!
BIT9=\$200!
BIT10=\$400!
BIT11=\$800!
BIT12=\$1000!
BIT13=\$2000!
BIT14=\$4000!
BIT15=\$8000!

! ============================================
! symbolic codes :
! ============================================
RET=MOV \@R1+,R0!   \ MOV @RSP+,PC
RETA=MOVA \@R1+,R0! \ MOVA @RSP+,PC
NOP=MOV \#0,R3!     \                one word one cycle
NOP2=\$3C00 ,!      \ compile JMP 0  one word two cycles
NOP3=MOV R0,R0!     \ MOV PC,PC      one word three cycles
NEXT=MOV \@R13+,R0! \ MOV @IP+,PC
\'\ \\=\'\ \\!      \ to compile INTERPRET in CORE_ANS.f
DODOES=\$1285!
DOCON=\$1286!
DOVAR=\$1287!

! ============================================
! ADD-ON flags :
! ============================================
FLOORED=\$8000!
LF_XTAL=\$4000!
HMPY=1!