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
D\.R=D\.R

M\*=M\*
M\+=M\+

R\>=R\>!
R\@=R\@!
\>R=\>R!

S\>=S\>!
\>S=\>S!
S\<=S\<!
S\>\==S\>\=!
\.S=\.S!
S\"=S\"!
S\_=S\_!

\<\#=\<\#!
\#S=\#S!
\#\>=\#\>!

T\{=T\{!
\}T=\}T!

U\.R=U\.R!

! ASCII numbers interpreter complement
\'NUL\'=\$00!
\'SOH\'=\$01!
\'STX\'=\$02!
\'ETX\'=\$03!
\'EOT\'=\$04!
\'ENQ\'=\$05!
\'ACK\'=\$06!
\'BEL\'=\$07!
\'BS\'=\$08!    Backspace
\'HT\'=\$09!    Horizontal Tabulation
\'LF\'=\$0A!
\'VT\'=\$0B!
\'FF\'=\$0C!    
\'CR\'=\$0D!
\'SO\'=\$0E!
\'SI\'=\$0F!
\'DLE\'=\$10!
\'DC1\'=\$11!   XON
\'DC2\'=\$12!
\'DC3\'=\$13!   XOFF
\'DC4\'=\$14!
\'NAK\'=\$15!
\'SYN\'=\$16!
\'ETB\'=\$17!
\'CAN\'=\$18!
\'EM\'=\$19!
\'SUB\'=\$1A!
\'ESC\'=\$1B!
\'FS\'=\$1C!
\'GS\'=\$1D!
\'RS\'=\$1E!
\'US\'=\$1F!
\'SP\'=\$20!
\'\'\'=\$27!'  QNUMBER can't interpret ''' !
\'DEL\'=\$7F!

\(RTS\)=\(RTS\)!
\(CTS\)=\(CTS\)!


! ============================================
! SR bits :
! ============================================
\#C=\#1!        = SR(0) Carry flag
\#Z=\#2!        = SR(1) Zero flag
\#N=\#4!        = SR(2) Negative flag
\#GIE=\#8!      = SR(3) Enable Int
\#CPUOFF=\#\$10!= SR(4) CPUOFF    
\#OSCOFF=\#\$20!= SR(5) OSCOFF
\#SCG0=\#\$40!  = SR(6) SCG0     
\#SCG1=\#\$80!  = SR(7) SCG1
\#V=\#\$100!    = SR(8) oVerflow flag
\#UF9=\#\$200!  = SR(9) User Flag 1 used by ?NUMBER --> INTERPRET --> LITERAL to process double numbers, else free for use.  
\#UF10=\#\$400! = SR(10) User Flag 2  
\#UF11=\#\$800! = SR(11) User Flag 3  

LPM4=\$F0! SR(LPM4)
LPM3=\$D0! SR(LPM3)
LPM2=\$90! SR(LPM2)
LPM1=\$50! SR(LPM1)
LPM0=\$10! SR(LPM0)

LPM4\+GIE=\$F8! SR(LPM4+GIE)
LPM3\+GIE=\$D8! SR(LPM3+GIE)
LPM2\+GIE=\$98! SR(LPM2+GIE)
LPM1\+GIE=\$58! SR(LPM1+GIE)
LPM0\+GIE=\$18! SR(LPM0+GIE)

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

