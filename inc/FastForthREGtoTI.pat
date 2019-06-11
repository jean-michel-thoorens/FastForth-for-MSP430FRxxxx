!FastForthREGtoTI.pat
! ============================================
! translate Forth registers to TI's ones
! ============================================

PC=R0!
SP=R1!
RSP=R1!
SR=R2!
rDODOES=R4!
rDOCON=R5!
rDOVAR=R6!
rDOCOL=R7!
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
\#S=\#S!
S\"=S\"!

T\{=T\{!
\}T=\}T!

U\.R=U\.R!

\(RTS=\(RTS!
CTS\)=CTS\)!
