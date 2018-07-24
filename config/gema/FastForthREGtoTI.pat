!FastForthREGtoTI.pat
! ============================================
! translate Forth registers to TI's ones
! ============================================

PC=R0!
RSP=R1!
SR=R2!
rDODOES=R4!
rDOCON=R5!
rDOVAR=R6!
rEXIT=R7!
rDOCOL=R7!
Q=R4!
P=R5!
M=R6!
L=R7!
Y=R8!
X=R9!
W=R10!
T=R11!
S=R12!
IP=R13!
TOS=R14!
PSP=R15!


DOVAR=\$1286!   to reinit rDOVAR : MOV #DOVAR,rDOVAR
DOCON=\$1285!   to reinit rDOCON : MOV #DOCON,rDOCON
DODOES=\$1284!  to reinit rDODOES: MOV #DODOES,rDODOES


! forth words filter
M\*=M\*
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
