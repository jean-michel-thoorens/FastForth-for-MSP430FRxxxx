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
R=R7!
Y=R8!
X=R9!
W=R10!
T=R11!
S=R12!
IP=R13!
TOS=R14!
PSP=R15!

! forth words filter
U\.R=U\.R!
R\>=R\>!
R\@=R\@!
\>R=\>R!
S\>=S\>!
S\<=S\<!
S\>\==S\>\=!
\.S=\.S!
\#S=\#S!
S\"=S\"!

T\{=T\{!
\}T=\}T!
!_R=_R
!_S=_S
!_T=_T
!_W=_W
!_X=_X
!_Y=_Y
