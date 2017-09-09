!MSP430FR2xxx.pat

LPM4=\$F8! SR(LPM4+GIE)
LPM3=\$D8! SR(LPM3+GIE)
LPM2=\$98! SR(LPM2+GIE)
LPM1=\$58! SR(LPM1+GIE)
LPM0=\$18! SR(LPM0+GIE)


SFRIE1=\$100!       \ SFR enable register
SFRIFG1=\$102!      \ SFR flag register
SFRRPCR=\$104!      \ SFR reset pin control

PMMCTL0=\$120!      \ PMM Control 0
PMMCTL1=\$122!      \ PMM Control 0
PMMCTL2=\$124!      \ PMM Control 0
PMMIFG=\$12A!       \ PMM interrupt flags 
PM5CTL0=\$130!      \ PM5 Control 0

SYSCTL=\$140!       \ System control 
SYSBSLC=\$142!      \ Bootstrap loader configuration area             
SYSJMBC=\$146!      \ JTAG mailbox control        
SYSJMBI0=\$148!     \ JTAG mailbox input 0        
SYSJMBI1=\$14A!     \ JTAG mailbox input 1        
SYSJMBO0=\$14C!     \ JTAG mailbox output 0       
SYSJMBO1=\$14E!     \ JTAG mailbox output 1       
SYSBERRIV=\$158!    \ Bus Error vector generator  
SYSUNIV=\$15A!      \ User NMI vector generator   
SYSSNIV=\$15C!      \ System NMI vector generator 
SYSRSTIV=\$15E!     \ Reset vector generator      
SYSCFG0=\$160!      \ System configuration 0 
SYSCFG1=\$162!      \ System configuration 1 
SYSCFG2=\$164!      \ System configuration 2 

CSCTL0=\$180!       \ CS control 0 
CSCTL1=\$182!       \ CS control 1 
CSCTL2=\$184!       \ CS control 2 
CSCTL3=\$186!       \ CS control 3 
CSCTL4=\$188!       \ CS control 4 
CSCTL5=\$18A!       \ CS control 5 
CSCTL6=\$18C!       \ CS control 6 

FRCTLCTL0=\$1A0!    \ FRAM control 0    
GCCTL0=\$1A4!       \ General control 0 
GCCTL1=\$1A6!       \ General control 1 

CRC16DI=\$1C0!      \ CRC data input                  
CRCDIRB=\$1C2!      \ CRC data input reverse byte     
CRCINIRES=\$1C4!    \ CRC initialization and result   
CRCRESR=\$1C6!      \ CRC result reverse byte  

WDTCTL=\$1CC!        \ WDT control register


PAIN=\$200!
PAOUT=\$202!
PADIR=\$204!
PAREN=\$206!
PASEL0=\$20A!
PASEL1=\$20C!
P1IV=\$20E!
PASELC=\$216!
PAIES=\$218!
PAIE=\$21A!
PAIFG=\$21C!
P2IV=\$21E!

P1IN=\$200!
P1OUT=\$202!
P1DIR=\$204!
P1REN=\$206!
P1SEL0=\$20A!
P1SEL1=\$20C!
P1SELC=\$216!
P1IES=\$218!
P1IE=\$21A!
P1IFG=\$21C!

P2IN=\$201!
P2OUT=\$203!
P2DIR=\$205!
P2REN=\$207!
P2SEL0=\$20B!
P2SEL1=\$20D!
P2SELC=\$217!
P2IES=\$219!
P2IE=\$21B!
P2IFG=\$21D!

P3IN=\$220!
P3OUT=\$222!
P3DIR=\$224!
P3REN=\$226!
P3SEL0=\$22A!
P3SEL1=\$22C!


RTCCTL=\$300!       \ RTC control                                  
RTCIV=\$304!        \ RTC interrupt vector word                       
RTCMOD=\$308!       \ RTC modulo                                       
RTCCNT=\$30C!       \ RTC counter register    


TACLR=4!
TAIFG=1!
CCIFG=1!

TA0CTL=\$380!       \ TA0 control                 
TA0CCTL0=\$382!     \ Capture/compare control 0   
TA0CCTL1=\$384!     \ Capture/compare control 1   
TA0CCTL2=\$386!     \ Capture/compare control 2   
TA0R=\$390!         \ TA0 counter register        
TA0CCR0=\$392!      \ Capture/compare register 0  
TA0CCR1=\$394!      \ Capture/compare register 1  
TA0CCR2=\$396!      \ Capture/compare register 2  
TA0EX0=\$3A0!       \ TA0 expansion register 0    
TA0IV=\$3AE!        \ TA0 interrupt vector        

TA1CTL=\$3C0!       \ TA1 control                 
TA1CCTL0=\$3C2!     \ Capture/compare control 0   
TA1CCTL1=\$3C4!     \ Capture/compare control 1   
TA1CCTL2=\$3C6!     \ Capture/compare control 2   
TA1R=\$3D0!         \ TA1 counter register        
TA1CCR0=\$3D2!      \ Capture/compare register 0  
TA1CCR1=\$3D4!      \ Capture/compare register 1  
TA1CCR2=\$3D6!      \ Capture/compare register 2  
TA1EX0=\$3E0!       \ TA1 expansion register 0    
TA1IV=\$3EE!        \ TA1 interrupt vector        

TA2CTL=\$400!       \ TA2 control                 
TA2CCTL0=\$402!     \ Capture/compare control 0   
TA2CCTL1=\$404!     \ Capture/compare control 1   
TA2R=\$410!         \ TA2 counter register        
TA2CCR0=\$412!      \ Capture/compare register 0  
TA2CCR1=\$414!      \ Capture/compare register 1  
TA2EX0=\$420!       \ TA2 expansion register 0    
TA2IV=\$42E!        \ TA2 interrupt vector        

TA3CTL=\$440!       \ TA3 control                 
TA3CCTL0=\$442!     \ Capture/compare control 0   
TA3CCTL1=\$444!     \ Capture/compare control 1   
TA3R=\$450!         \ TA3 counter register        
TA3CCR0=\$452!      \ Capture/compare register 0  
TA3CCR1=\$454!      \ Capture/compare register 1  
TA3EX0=\$460!       \ TA3 expansion register 0    
TA3IV=\$46E!        \ TA3 interrupt vector        

MPY=\$4C0!          \ 16-bit operand 1 – multiply                     
MPYS=\$4C2!         \ 16-bit operand 1 – signed multiply              
MAC=\$4C4!          \ 16-bit operand 1 – multiply accumulate          
MACS=\$4C6!         \ 16-bit operand 1 – signed multiply accumulate   
OP2=\$4C8!          \ 16-bit operand 2                                
RESLO=\$4CA!        \ 16 × 16 result low word                         
RESHI=\$4CC!        \ 16 × 16 result high word                        
SUMEXT=\$4CE!       \ 16 × 16 sum extension register                  
MPY32L=\$4D0!       \ 32-bit operand 1 – multiply low word            
MPY32H=\$4D2!       \ 32-bit operand 1 – multiply high word           
MPYS32L=\$4D4!      \ 32-bit operand 1 – signed multiply low word     
MPYS32H=\$4D6!      \ 32-bit operand 1 – signed multiply high word    
MAC32L=\$4D8!       \ 32-bit operand 1 – multiply accumulate low word         
MAC32H=\$4DA!       \ 32-bit operand 1 – multiply accumulate high word        
MACS32L=\$4DC!      \ 32-bit operand 1 – signed multiply accumulate low word  
MACS32H=\$4DE!      \ 32-bit operand 1 – signed multiply accumulate high word 
OP2L=\$4E0!         \ 32-bit operand 2 – low word                 
OP2H=\$4E2!         \ 32-bit operand 2 – high word                
RES0=\$4E4!         \ 32 × 32 result 0 – least significant word   
RES1=\$4E6!         \ 32 × 32 result 1                            
RES2=\$4E8!         \ 32 × 32 result 2                            
RES3=\$4EA!         \ 32 × 32 result 3 – most significant word    
MPY32CTL0=\$4EC!    \ MPY32 control register 0                    



UCA0CTLW0=\$500!    \ eUSCI_A control word 0        
UCA0CTLW1=\$502!    \ eUSCI_A control word 1        
UCA0BRW=\$506!         
UCA0BR0=\$506!      \ eUSCI_A baud rate 0           
UCA0BR1=\$507!      \ eUSCI_A baud rate 1           
UCA0MCTLW=\$508!    \ eUSCI_A modulation control    
UCA0STAT=\$50A!     \ eUSCI_A status                
UCA0RXBUF=\$50C!    \ eUSCI_A receive buffer        
UCA0TXBUF=\$50E!    \ eUSCI_A transmit buffer       
UCA0ABCTL=\$510!    \ eUSCI_A LIN control           
UCA0IRTCTL=\$512!   \ eUSCI_A IrDA transmit control 
UCA0IRRCTL=\$513!   \ eUSCI_A IrDA receive control  
UCA0IE=\$51A!       \ eUSCI_A interrupt enable      
UCA0IFG=\$51C!      \ eUSCI_A interrupt flags       
UCA0IV=\$51E!       \ eUSCI_A interrupt vector word 

UCA1CTLW0=\$520!    \ eUSCI_A control word 0        
UCA1CTLW1=\$522!    \ eUSCI_A control word 1        
UCA1BRW=\$526!         
UCA1BR0=\$526!      \ eUSCI_A baud rate 0           
UCA1BR1=\$527!      \ eUSCI_A baud rate 1           
UCA1MCTLW=\$528!    \ eUSCI_A modulation control    
UCA1STAT=\$52A!     \ eUSCI_A status                
UCA1RXBUF=\$52C!    \ eUSCI_A receive buffer        
UCA1TXBUF=\$52E!    \ eUSCI_A transmit buffer       
UCA1ABCTL=\$530!    \ eUSCI_A LIN control           
UCA1IRTCTL=\$532!   \ eUSCI_A IrDA transmit control 
UCA1IRRCTL=\$533!   \ eUSCI_A IrDA receive control  
UCA1IE=\$53A!       \ eUSCI_A interrupt enable      
UCA1IFG=\$53C!      \ eUSCI_A interrupt flags       
UCA1IV=\$53E!       \ eUSCI_A interrupt vector word 


UCB0CTLW0=\$540!    \ eUSCI_B control word 0          
UCB0CTLW1=\$542!    \ eUSCI_B control word 1 
UCB0BRW=\$546!         
UCB0BR0=\$546!      \ eUSCI_B bit rate 0              
UCB0BR1=\$547!      \ eUSCI_B bit rate 1              
UCB0STATW=\$548!    \ eUSCI_B status word 
UCBCNT0=\$549!      \ eUSCI_B hardware count           
UCB0TBCNT=\$54A!    \ eUSCI_B byte counter threshold  
UCB0RXBUF=\$54C!    \ eUSCI_B receive buffer          
UCB0TXBUF=\$54E!    \ eUSCI_B transmit buffer         
UCB0I2COA0=\$554!   \ eUSCI_B I2C own address 0       
UCB0I2COA1=\$556!   \ eUSCI_B I2C own address 1       
UCB0I2COA2=\$558!   \ eUSCI_B I2C own address 2       
UCB0I2COA3=\$55A!   \ eUSCI_B I2C own address 3       
UCB0ADDRX=\$55C!    \ eUSCI_B received address        
UCB0ADDMASK=\$55E!  \ eUSCI_B address mask            
UCB0I2CSA=\$560!    \ eUSCI I2C slave address         
UCB0IE=\$56A!       \ eUSCI interrupt enable          
UCB0IFG=\$56C!      \ eUSCI interrupt flags           
UCB0IV=\$56E!       \ eUSCI interrupt vector word     

UCTXACK=\$20!
UCTR=\$10!

LCDCTL0=\$600!      \ LCD control register 0   
LCDCTL1=\$602!      \ LCD control register 1   
LCDBLKCTL=\$604!    \ LCD blink control register     
LCDMEMCTL=\$606!    \ LCD memory control register     
LCDVCTL=\$608!      \ LCD voltage control register   
LCDPCTL0=\$60A!     \ LCD port control 0    
LCDPCTL1=\$60C!     \ LCD port control 1    
LCDPCTL2=\$60E!     \ LCD port control 2    
LCDCSS0=\$614!      \ LCD COM/SEG select register   
LCDCSS1=\$616!      \ LCD COM/SEG select register   
LCDCSS2=\$618!      \ LCD COM/SEG select register   
LCDIV=\$61E!        \ LCD interrupt vector 
LCDM0=\$620!        \ LCD memory 0 
LCDM1=\$621!        \ LCD memory 1 
LCDM2=\$622!        \ LCD memory 2 
LCDM3=\$623!        \ LCD memory 3 
LCDM4=\$624!        \ LCD memory 4 
LCDM5=\$625!        \ LCD memory 5 
LCDM6=\$626!        \ LCD memory 6 
LCDM7=\$627!        \ LCD memory 7 
LCDM8=\$628!        \ LCD memory 8 
LCDM9=\$629!        \ LCD memory 9 
LCDM10=\$62A!       \ LCD memory 10 
LCDM11=\$62B!       \ LCD memory 11 
LCDM12=\$62C!       \ LCD memory 12 
LCDM13=\$62D!       \ LCD memory 13 
LCDM14=\$62E!       \ LCD memory 14 
LCDM15=\$62F!       \ LCD memory 15 
LCDM16=\$630!       \ LCD memory 16 
LCDM17=\$631!       \ LCD memory 17 
LCDM18=\$632!       \ LCD memory 18 
LCDM19=\$633!       \ LCD memory 19  
LCDM20=\$634!       \ LCD memory 20 
LCDM21=\$635!       \ LCD memory 21 
LCDM22=\$636!       \ LCD memory 22 
LCDM23=\$637!       \ LCD memory 23 
LCDM24=\$638!       \ LCD memory 24 
LCDM25=\$639!       \ LCD memory 25 
LCDM26=\$63A!       \ LCD memory 26 
LCDM27=\$63B!       \ LCD memory 27 
LCDM28=\$63C!       \ LCD memory 28 
LCDM29=\$63D!       \ LCD memory 29  
LCDM30=\$63E!       \ LCD memory 30 
LCDM31=\$63F!       \ LCD memory 31 
LCDM32=\$640!       \ LCD memory 32 
LCDM33=\$641!       \ LCD memory 33 
LCDM34=\$642!       \ LCD memory 34 
LCDM35=\$643!       \ LCD memory 35 
LCDM36=\$644!       \ LCD memory 36 
LCDM37=\$645!       \ LCD memory 37 
LCDM38=\$646!       \ LCD memory 38 
LCDM39=\$647!       \ LCD memory 39  
LCDBM0=\$640!       \ LCD blinking memory 0 
LCDBM1=\$641!       \ LCD blinking memory 1 
LCDBM2=\$642!       \ LCD blinking memory 2 
LCDBM3=\$643!       \ LCD blinking memory 3 
LCDBM4=\$644!       \ LCD blinking memory 4 
LCDBM5=\$645!       \ LCD blinking memory 5 
LCDBM6=\$646!       \ LCD blinking memory 6 
LCDBM7=\$647!       \ LCD blinking memory 7 
LCDBM8=\$648!       \ LCD blinking memory 8 
LCDBM9=\$649!       \ LCD blinking memory 9 
LCDBM10=\$64A!      \ LCD blinking memory 10 
LCDBM11=\$64B!      \ LCD blinking memory 11 
LCDBM12=\$64C!      \ LCD blinking memory 12 
LCDBM13=\$64D!      \ LCD blinking memory 13 
LCDBM14=\$64E!      \ LCD blinking memory 14 
LCDBM15=\$64F!      \ LCD blinking memory 15 
LCDBM16=\$650!      \ LCD blinking memory 16 
LCDBM17=\$651!      \ LCD blinking memory 17 
LCDBM18=\$652!      \ LCD blinking memory 18 
LCDBM19=\$653!      \ LCD blinking memory 19 


BAKMEM0=\$660!      \ Backup Memory 0     
BAKMEM1=\$662!      \ Backup Memory 1     
BAKMEM2=\$664!      \ Backup Memory 2     
BAKMEM3=\$666!      \ Backup Memory 3     
BAKMEM4=\$668!      \ Backup Memory 4     
BAKMEM5=\$66A!      \ Backup Memory 5     
BAKMEM6=\$66C!      \ Backup Memory 6     
BAKMEM7=\$66E!      \ Backup Memory 7     
BAKMEM8=\$670!      \ Backup Memory 8     
BAKMEM9=\$672!      \ Backup Memory 9     
BAKMEM10=\$674!     \ Backup Memory 10    
BAKMEM11=\$676!     \ Backup Memory 11    
BAKMEM12=\$678!     \ Backup Memory 12    
BAKMEM13=\$67A!     \ Backup Memory 13    
BAKMEM14=\$67C!     \ Backup Memory 14    
BAKMEM15=\$67E!     \ Backup Memory 15    


ADC10CTL0=\$700!    \ ADC10_B Control register 0               
ADC10CTL1=\$702!    \ ADC10_B Control register 1               
ADC10CTL2=\$704!    \ ADC10_B Control register 2               
ADC10LO=\$706!      \ ADC10_B Window Comparator Low Threshold  
ADC10HI=\$708!      \ ADC10_B Window Comparator High Threshold 
ADC10MCTL0=\$70A!   \ ADC10_B Memory Control Register 0        
ADC10MEM0=\$712!    \ ADC10_B Conversion Memory Register       
ADC10IE=\$71A!      \ ADC10_B Interrupt Enable                 
ADC10IFG=\$71C!     \ ADC10_B Interrupt Flags                  
ADC10IV=\$71E!      \ ADC10_B Interrupt Vector Word            

ADCON=\$10!
ADCSTART=\$03!

