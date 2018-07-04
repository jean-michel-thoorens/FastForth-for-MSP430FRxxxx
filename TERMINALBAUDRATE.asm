
; TERM alias eUSCI_Ax : select baudrate versus frequency
    .IF FREQUENCY = 0.25
        .SWITCH TERMINALBAUDRATE

        .CASE 9600
; Configure UART_TERM @ 38400 bauds / 1MHz
; N=1000000/38400=26.04166... ==> UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=10, UCBRS0= fn(frac(N))=fn(0.04166)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,    &TERMBRW
            MOV.W   #00A1h, &TERMMCTLW

        .CASE 19200  ; PL2303TA baudrate
; Configure UART_TERM @ 38400 bauds / 500kHz
; N=500000/38400=13.20833 ==> UCOS16=0, UCBR0=int(N)=13, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.20833)=0x11
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,     &TERMBRW
            MOV.W   #1100h,&TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 250kHz
; N=250000/31250=8 ==> UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0000h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 250kHz
; N=250000/38400=6.5124166... ==> UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.512416)=0xAA
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,     &TERMBRW
            MOV.W   #0AA00h,&TERMMCTLW

        .CASE 57600  ; PL2303TA baudrate
; Configure UART_TERM @ 57600 bauds / 250kHz
; N=250000/57600=4.340277.. ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.340277)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #04900h,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 250 kHz : baudrate not implemented"
        .ENDCASE


    .ELSEIF FREQUENCY = 0.5
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 19200 bauds / 1MHz
; N=1000000/19200=52.0833... ==> UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=fn(0.0833)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,    &TERMBRW
            MOV.W   #0241h,&TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 38400 bauds / 1MHz
; N=1000000/38400=26.04166... ==> UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=10, UCBRS0= fn(frac(N))=fn(0.04166)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,    &TERMBRW
            MOV.W   #00A1h, &TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 500kHz
; N=500000/31250=16 ==> UCOS16=0, UCBR0=int(N)=16, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #16,     &TERMBRW
            MOV.W   #0000h,&TERMMCTLW

        .CASE 38400  ; PL2303TA baudrate
; Configure UART_TERM @ 38400 bauds / 500kHz
; N=500000/38400=13.20833 ==> UCOS16=0, UCBR0=int(N)=13, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.20833)=0x11
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,     &TERMBRW
            MOV.W   #1100h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 115200 bauds / 1MHz
; N=1000000/115200=8.68055... ==> UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.68055)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0D600h,&TERMMCTLW

        .CASE 100800  ; PL2303TA baudrate
; Configure UART_TERM @ 201600 bauds / 1MHz
; N=1000000/201600=4.955401 ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.200396)=0xFE
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0FE00h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 230400 bauds / 1MHz
; N=1000000/230400=4.34027... ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.340277)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #04900h,&TERMMCTLW

        .CASE 134400  ; PL2303TA baudrate
; Configure UART_TERM @ 268800 bauds / 1MHz
; N=1000000/134400=3.72024 ==> UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.72024)=0xBB
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,     &TERMBRW
            MOV.W   #0BB00h,&TERMMCTLW

;        .CASE 161280  ; PL2303TA baudrate
;; Configure UART_TERM @ 161280 bauds / 500kHz
;; N=500000/161280=3.100198 ==> UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.100198)=0x08
;; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;            MOV     #3,     &TERMBRW
;            MOV.W   #01100h,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 500 kHz : baudrate not implemented"
        .ENDCASE


    .ELSEIF FREQUENCY = 1
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 1MHz
; N=1000000/9600=104.166... ==> UCOS16=1, UCBR0=int(N/16)=6, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0.1666)=0x20
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,    &TERMBRW
            MOV     #2081h, &TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 1MHz
; N=1000000/19200=52.0833... ==> UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=fn(0.0833)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,    &TERMBRW
            MOV.W   #0241h,&TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 1MHz
; N=1000000/31250=32 ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 1MHz
; N=1000000/38400=26.04166... ==> UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=10, UCBRS0= fn(frac(N))=fn(0.04166)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,    &TERMBRW
            MOV.W   #00A1h, &TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 1MHz
; N=1000000/57600=17.301... ==> UCOS16=0, UCBR0=int(N)=17, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.301)=0x4A
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #17,     &TERMBRW
            MOV.W   #04A00h,&TERMMCTLW

        .CASE 100800  ; PL2303TA baudrate
; Configure UART_TERM @ 100800 bauds / 1MHz
; N=1000000/100800=9,920634 ==> UCOS16=0, UCBR0=int(N)=9, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.920634)=0xFD
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #9,     &TERMBRW
            MOV.W   #0FD00h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 1MHz
; N=1000000/115200=8.68055... ==> UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.68055)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0D600h,&TERMMCTLW

        .CASE 134400  ; PL2303TA baudrate
; Configure UART_TERM @ 134400 bauds / 1MHz
; N=1000000/134400=7.440476 ==> UCOS16=0, UCBR0=int(N)=7, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.440476)=0x55
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #7,     &TERMBRW
            MOV.W   #05500h,&TERMMCTLW

        .CASE 161280  ; PL2303TA baudrate
; Configure UART_TERM @ 161280 bauds / 1MHz
; N=1000000/161280=6.200396 ==> UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.200396)=0x11
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,     &TERMBRW
            MOV.W   #01100h,&TERMMCTLW

        .CASE 201600  ; PL2303TA baudrate
; Configure UART_TERM @ 201600 bauds / 1MHz
; N=1000000/201600=4.955401 ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.200396)=0xFE
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0FE00h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 1MHz
; N=1000000/230400=4.34027... ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.340277)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #04900h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 1MHz
; N=1000000/250000=4 ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0000h,&TERMMCTLW

        .CASE 268800  ; PL2303TA baudrate
; Configure UART_TERM @ 268800 bauds / 1MHz
; N=1000000/268800=3.72024 ==> UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.72024)=0xBB
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,     &TERMBRW
            MOV.W   #0BB00h,&TERMMCTLW

;        .CASE 403200  ; PL2303TA baudrate
;; Configure UART_TERM @ 403200 bauds / 1MHz
;; N=1000000/403200=2.48016 ==> UCOS16=0, UCBR0=int(N)=2, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.48016)=0x55
;; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;            MOV     #2,     &TERMBRW
;            MOV.W   #05500h,&TERMMCTLW


        .ELSECASE
            .error "UART_TERM / 1 MHz : baudrate not implemented"
        .ENDCASE

    .ELSEIF FREQUENCY = 2
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 19200 bauds / 4MHz
; N=4000000/38400=208.333... ==> UCOS16=1, UCBR0=int(N/16)=13, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.33333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,    &TERMBRW
            MOV.W   #4901h, &TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 9600 bauds / 1MHz
; N=1000000/9600=104.166... ==> UCOS16=1, UCBR0=int(N/16)=6, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0.1666)=0x20
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,    &TERMBRW
            MOV     #2081h, &TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 2MHz
; N=2000000/31250=64 ==> UCOS16=1, UCBR0=int(N/16)=4, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 19200 bauds / 1MHz
; N=1000000/19200=52.0833... ==> UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=fn(0.0833)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,    &TERMBRW
            MOV.W   #0241h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 115200 bauds / 4MHz
; N=8000000/230400=34.7222... ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0.72222)=0xBB
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #0BB21h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 57600 bauds / 1MHz
; N=1000000/57600=17.301... ==> UCOS16=0, UCBR0=int(N)=17, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.301)=0x4A
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #17,     &TERMBRW
            MOV.W   #04A00h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 115200 bauds / 1MHz
; N=1000000/115200=8.68055... ==> UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.68055)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0D600h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 2MHz
; N=2000000/250000=8 ==> UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0000h,&TERMMCTLW

        .CASE 268800  ; PL2303TA baudrate
; Configure UART_TERM @ 134400 bauds / 1MHz
; N=1000000/134400=7.440476 ==> UCOS16=0, UCBR0=int(N)=7, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.440476)=0x55
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #7,     &TERMBRW
            MOV.W   #05500h,&TERMMCTLW

        .CASE 403200  ; PL2303TA baudrate
; Configure UART_TERM @ 201600 bauds / 1MHz
; N=1000000/201600=4.955401 ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.200396)=0xFE
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0FE00h,&TERMMCTLW

        .CASE 460800 ; CP2102 baudrate
; Configure UART_TERM @ 921600 bauds / 4MHz
; N = 4000000/460800 = 4.34027... ==> {UCOS16=0, UCBR1=int(N)=4, UCBRF1=dont_care=0  UCBRS1=fn(frac(N))=fn(0.34027)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,     &TERMBRW
             MOV.W   #04900h,&TERMMCTLW

        .CASE 614400 ; PL2303TA baudrate
; Configure UART_TERM @ 2457600 bauds / 8MHz
; N = 8000000/2457600 = 3.25521... ==> {UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.25521)=0x44
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #3,     &TERMBRW
             MOV.W   #04400h,&TERMMCTLW

        .CASE 806400  ; PL2303TA baudrate
; Configure UART_TERM @ 806400 bauds / 2MHz
; Configure UART_TERM @ 403200 bauds / 1MHz
; N=1000000/403200=2.48016 ==> UCOS16=0, UCBR0=int(N)=2, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.48016)=0x55
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #05500h,&TERMMCTLW

;        .CASE 921600
;; Configure UART_TERM @ 921600 bauds / 2MHz
;; N = 2000000/921600 = 2.170138... ==> {UCOS16=0, UCBR1=int(N)=2, UCBRF1=dont_care=0  UCBRS1=fn(frac(N))=fn(0.170138)=0x11
;; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;             MOV     #2,     &TERMBRW
;             MOV.W   #01100h,&TERMMCTLW


        .ELSECASE
            .error "UART_TERM / 2 MHz : baudrate not implemented"
        .ENDCASE

    .ELSEIF FREQUENCY = 4
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 4MHz
; N=4000000/19200=416.666... ==> UCOS16=1, UCBR0=int(N/16)=26, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.66666)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #26,    &TERMBRW
            MOV.W   #0D601h,&TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 4MHz
; N=4000000/38400=208.333... ==> UCOS16=1, UCBR0=int(N/16)=13, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.33333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,    &TERMBRW
            MOV.W   #4901h, &TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 4MHz
; N=4000000/31250=128 ==> UCOS16=1, UCBR0=int(N/16)=8, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 4MHz
; N=4000000/38400=104.1666... ==> UCOS16=1, UCBR0=int(N/16)=6, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0.16666)=0x20
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,     &TERMBRW
            MOV.W   #02081h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 4MHz
; N=8000000/115200=69.444... ==> UCOS16=1, UCBR0=int(N/16)=4, UCBRF0=int(frac(N/16)*16)=5, UCBRS0= fn(frac(N))=fn(0.44444)=0x55
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #5551h, &TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 4MHz
; N=8000000/230400=34.7222... ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0.72222)=0xBB
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #0BB21h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 4MHz
; see table "Recommended Settings for Typical Crystals and Baudrates"
            MOV     #17,    &TERMBRW
            MOV.W   #04A00h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 4MHz
; N=4000000/250000=16 ==> UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0001h, &TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 4MHz
; N = 8000000/921600 = 8.680555... ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.68055)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #8,     &TERMBRW
             MOV.W   #0D600h,&TERMMCTLW

        .CASE 806400  ; PL2303TA baudrate
; Configure UART_TERM @ 806400 bauds / 4MHz
; Configure UART_TERM @ 201600 bauds / 1MHz
; N=1000000/201600=4.955401 ==> UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.200396)=0xFE
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0FE00h,&TERMMCTLW

        .CASE 921600 ; CP2102 baudrate
; Configure UART_TERM @ 921600 bauds / 4MHz
; N = 8000000/921600 = 4.34027... ==> {UCOS16=0, UCBR1=int(N)=4, UCBRF1=dont_care=0  UCBRS1=fn(frac(N))=fn(0.34027)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,     &TERMBRW
             MOV.W   #04900h,&TERMMCTLW

        .CASE 1228800 ; PL2303TA baudrate
; Configure UART_TERM @ 2457600 bauds / 8MHz
; N = 8000000/1228800 = 3.25521... ==> {UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.25521)=0x44
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #3,     &TERMBRW
             MOV.W   #04400h,&TERMMCTLW


        .ELSECASE
            .error "UART_TERM / 4 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 4 MHz baudrates


    .ELSEIF FREQUENCY = 8
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 8MHz
; N=8000000/9600=833.333... ==> UCOS16=1, UCBR0=int(N/16)=52, UCBRF0=int(frac(N/16)*16)=1, UCBRS0= fn(frac(N))=fn(0.33333)=0x49
            MOV     #52,    &TERMBRW
            MOV     #4911h, &TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 8MHz
; N=8000000/19200=416.666... ==> UCOS16=1, UCBR0=int(N/16)=26, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.66666)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #26,    &TERMBRW
            MOV.W   #0D601h,&TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 8MHz
; N=8000000/31250=256 ==> UCOS16=1, UCBR0=int(N/16)=16, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #16,     &TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 8MHz
; N=8000000/38400=208.333... ==> UCOS16=1, UCBR0=int(N/16)=13, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.33333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,    &TERMBRW
            MOV.W   #4901h, &TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 8MHz
; N=8000000/57600=138.888... ==> UCOS16=1, UCBR0=int(N/16)=8, UCBRF0=int(frac(N/16)*16)=10, UCBRS0= fn(frac(N))=fn(0.88888)=0xF7
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0F7A1h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 8MHz
; N=8000000/115200=69.444... ==> UCOS16=1, UCBR0=int(N/16)=4, UCBRF0=int(frac(N/16)*16)=5, UCBRS0= fn(frac(N))=fn(0.44444)=0x55
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #5551h, &TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 8MHz
; N=8000000/230400=34.7222... ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0.72222)=0xBB
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #0BB21h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 8MHz
; N=8000000/250000=32 ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #0001h, &TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 8MHz
; see table "Recommended Settings for Typical Crystals and Baudrates"
            MOV     #17,    &TERMBRW
            MOV.W   #04A00h,&TERMMCTLW

        .CASE 614400 ; PL2303TA baudrate
; Configure UART_TERM @ 614400 bauds / 8MHz
; N = 8000000/614400 = 13.02083... ==> {UCOS16=0, UCBR0=int(N)=13, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.02083)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #13,     &TERMBRW
             MOV.W   #00200h,&TERMMCTLW

        .CASE 806400  ; PL2303TA baudrate
; Configure UART_TERM @ 806400 bauds / 8MHz
; Configure UART_TERM @ 100800 bauds / 1MHz
; N=1000000/100800=9,920634 ==> UCOS16=0, UCBR0=int(N)=9, UCBRF0=dont_care=0, UCBRS0= fn(frac(N))=fn(0.920634)=0xFD
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #9,     &TERMBRW
            MOV.W   #0FD00h,&TERMMCTLW

        .CASE 921600
; Configure UART_TERM @ 921600 bauds / 8MHz
; Configure UART_TERM @ 1843200 bauds / 16MHz
; N = 16000000/1843200 = 8.680555... ==> {UCOS16=0, UCBR1=int(N)=8, UCBRF1=dont_care=0  UCBRS1=fn(frac(N))=fn(0.68055)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #8,     &TERMBRW
             MOV.W   #0D600h,&TERMMCTLW

        .CASE 1000000
; Configure UART_TERM @ 1000000 bauds / 8MHz
; Configure UART_TERM @ 2000000 bauds / 16MHz
; N = 16000000/2000000 = 8 ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
            MOV     #8 ,    &TERMBRW
            MOV.W   #00000h,&TERMMCTLW

        .CASE 1228800 ; PL2303TA baudrate
; Configure UART_TERM @ 1228800 bauds / 8MHz
; N = 8000000/1228800 = 6.510416... ==> {UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.510416)=0xAA
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #6,     &TERMBRW
             MOV.W   #0AA00h,&TERMMCTLW

        .CASE 1382400 ; CP2102 baudrate
; Configure UART_TERM @ 1382400 bauds / 8MHz
; N = 8000000/1382400 = 5.787037... ==> {UCOS16=0, UCBR0=int(N)=5, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.787037)=0xED
            MOV     #5,    &TERMBRW
            MOV.W   #0DD00h,&TERMMCTLW

        .CASE 1843200 ; CP2102 baudrate (with programming)
; Configure UART_TERM @ 1843200 bauds / 8MHz
; N = 16000000/1843200 = 4.34027... ==> {UCOS16=0, UCBR1=int(N)=4, UCBRF1=dont_care=0  UCBRS1=fn(frac(N))=fn(0.34027)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,     &TERMBRW
             MOV.W   #04900h,&TERMMCTLW

        .CASE 2457600 ; PL2303TA baudrate
; Configure UART_TERM @ 2457600 bauds / 8MHz
; N = 8000000/1228800 = 3.25521... ==> {UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.25521)=0x44
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #3,     &TERMBRW
             MOV.W   #04400h,&TERMMCTLW

        .CASE 3000000 ; PL2303TA baudrate
; Configure UART_TERM @ 3000000 bauds / 8MHz
; Configure UART_TERM @ 6000000 bauds / 16MHz
; N = 16000000/6000000 = 2.6666.. ==> {UCOS16=0, UCBR0=int(N)=2, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.6666)=0xB6
            MOV     #2,    &TERMBRW
            MOV.W   #0B600h,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 8 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 8 MHz baudrates



    .ELSEIF FREQUENCY = 10
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 10MHz
; Configure UART_TERM @ 19200 bauds / 20MHz
; N=20000000/19200=1041.66666 ==> UCOS16=1, UCBR0=int(N/16)=65, UCBRF0=int(frac(N/16)*16)=1, UCBRS0= fn(frac(N))=fn(0.66666)=0xd6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #65,&TERMBRW
            MOV     #0D611h,&TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 10MHz
; Configure UART_TERM @ 38400 bauds / 20MHz
; N=20000000/38400=520.833333 ==> UCOS16=1, UCBR0=int(N/16)=32, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0)=0xBF
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #32,&TERMBRW
            MOV.W   #0BF01h,&TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 10MHz
; N=10000000/31250=320 ==> UCOS16=1, UCBR0=int(N/16)=20, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #20,&TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 10MHz
; N=10000000/38400=260.41666 ==> UCOS16=1, UCBR0=int(N/16)=16, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=fn(.04166)=0x92
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #16,&TERMBRW
            MOV.W   #09241h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 10MHz
; Configure UART_TERM @ 115200 bauds / 20MHz
; N=20000000/115200=173.61111... ==> UCOS16=1, UCBR0=int(N/16)=10, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.6111)=0xAD
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #10,&TERMBRW
            MOV.W   #0AD01h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 10MHz
; Configure UART_TERM @ 230400 bauds / 20MHz
; N=20000000/230400=86.80555... ==> UCOS16=1, UCBR0=int(N/16)=5, UCBRF0=int(frac(N/16)*16)=6, UCBRS0= fn(frac(N))=fn(0.80555)=0xEE
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #5,&TERMBRW
            MOV.W   #0EE61h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 10MHz
; Configure UART_TERM @ 460800 bauds / 20MHz
; N=20000000/460800=43.402777... ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=0Bh, UCBRS0= fn(frac(N))=fn(0.4027)=0x92
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #92B1h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 10MHz
; Configure UART_TERM @ 500000 bauds / 20MHz
; N = 20000000/500000 = 40 ==> {UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=8  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,  &TERMBRW
            MOV.W   #0081h,&TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 10MHz
; Configure UART_TERM @ 921600 bauds / 20MHz
; N = 20000000/921600 = 21.701388... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=5  UCBRS0=fn(frac(N))=fn(0.70138)=0xB7
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0B751h,&TERMMCTLW

        .CASE 500000 ; CP2102 baudrate
; Configure UART_TERM @ 500000 bauds / 10MHz
; Configure UART_TERM @ 1000000 bauds / 20MHz
; N = 20000000/1000000 = 20 ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=4,  UCBRS0=fn(frac(N))=fn(0.000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0041h,&TERMMCTLW

        .CASE 614400
; Configure UART_TERM @ 614400 bauds / 10MHz
; Configure UART_TERM @ 1228800 bauds / 20MHz
; N = 20000000/1228800 = 16.276... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=0,  UCBRS0=fn(frac(N))=fn(0.276)=0x44
            MOV     #1,     &TERMBRW
            MOV.W   #04411h,&TERMMCTLW

        .CASE 921600
; Configure UART_TERM @ 921600 bauds / 10MHz
; Configure UART_TERM @ 1843200 bauds / 20MHz
; N = 20000000/1843200 = 10.85069...  {UCOS16=0, UCBR0=int(N)=10, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.85069)=0xDF
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #10,    &TERMBRW
             MOV.W   #0DF00h,&TERMMCTLW

        .CASE 1000000
; Configure UART_TERM @ 1000000 bauds / 10MHz
; N = 10000000/1000000 = 10 ==> {UCOS16=0, UCBR0=int(N)=10, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.0)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #10,     &TERMBRW
            MOV.W   #0,&TERMMCTLW

        .CASE 1228800
; Configure UART_TERM @ 1228800 bauds / 10MHz
; N = 10000000/1228800 = 8.138.. ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.138)=0x10
            MOV     #8,     &TERMBRW
            MOV.W   #01000h,&TERMMCTLW

        .CASE 1382400
; Configure UART_TERM @ 1382400 bauds / 10MHz
; N = 10000000/1382400 = 7.2338.. ==> {UCOS16=0, UCBR0=int(N)=7, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.2338)=0x22
            MOV     #7,     &TERMBRW
            MOV.W   #02200h,&TERMMCTLW

        .CASE 1843200
; Configure UART_TERM @ 1843200 bauds / 10MHz
; N = 10000000/1843200 = 5.4253...  {UCOS16=0, UCBR0=int(N)=5, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.4253)=0x92
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #5,    &TERMBRW
             MOV.W   #09200h,&TERMMCTLW

        .CASE 2457600 ; PL2303TA baudrate
; Configure UART_TERM @ 2457600 bauds / 10MHz
; N = 10000000/2457600 = 4.069010... ==> {UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.06901)=0x01
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,     &TERMBRW
             MOV.W   #00100h,&TERMMCTLW

        .CASE 3000000 ; PL2303TA baudrate
; Configure UART_TERM @ 3000000 bauds / 10MHz
; Configure UART_TERM @ 6000000 bauds / 20MHz
; N = 20000000/6000000 = 3.3333333 ==> {UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.33333)=0x49
            MOV     #3,&TERMBRW
             MOV.W   #04900h,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 10 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 10 MHz baudrates

    .ELSEIF FREQUENCY = 12
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 12MHz
; Configure UART_TERM @ 19200 bauds / 24MHz
; N=12000000/19200=1250 ==> UCOS16=1, UCBR0=int(N/16)=78, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #78,    &TERMBRW
            MOV     #0021h, &TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 12MHz
; Configure UART_TERM @ 38400 bauds / 24MHz
; N=24000000/19200=625 ==> UCOS16=1, UCBR0=int(N/16)=39, UCBRF0=int(frac(N/16)*16)=1, UCBRS0= fn(frac(N))=fn(0)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #39,    &TERMBRW
            MOV.W   #0011h,&TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 8MHz
; N=12000000/31250=384 ==> UCOS16=1, UCBR0=int(N/16)=24, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #24,     &TERMBRW
            MOV.W   #1,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 12MHz
; N=12000000/19200=312.5... ==> UCOS16=1, UCBR0=int(N/16)=19, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0.5)=0x55
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #19,    &TERMBRW
            MOV.W   #05581h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 12MHz
; Configure UART_TERM @ 115200 bauds / 24MHz
; N=24000000/115200=208.333... ==> UCOS16=1, UCBR0=int(N/16)=13, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,     &TERMBRW
            MOV.W   #04901h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 12MHz
; Configure UART_TERM @ 230400 bauds / 24MHz
; N=24000000/230400=104.1666... ==> UCOS16=1, UCBR0=int(N/16)=6, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0.1666)=0x20
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,     &TERMBRW
            MOV.W   #2081h, &TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 12MHz
; Configure UART_TERM @ 460800 bauds / 24MHz
; N=24000000/460800=52.08333... ==> UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=fn(0.0833)=0x02
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,     &TERMBRW
            MOV.W   #0241h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 12MHz
; Configure UART_TERM @ 500000 bauds / 24MHz
; N = 24000000/500000 = 48 ==> {UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;            MOV     #3,  &TERMBRW
;            MOV.W   #0001h,&TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 12MHz
; Configure UART_TERM @ 921600 bauds / 24MHz
; N = 24000000/921600 = 26.041666... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=10  UCBRS0=fn(frac(N))=fn(0.0416)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #00A1h,&TERMMCTLW

        .CASE 500000 ; CP2102 baudrate
; Configure UART_ @ 500000 bauds / 12MHz
; Configure UART_ @ 1000000 bauds / 24MHz
; N = 24000000/1000000 = 24 ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=4,  UCBRS0=fn(frac(N))=fn(0.000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0041h,&TERMMCTLW

        .CASE 614400
; Configure UART_TERM @ 614400 bauds / 12MHz
; Configure UART_TERM @ 1228800 bauds / 24MHz
; N = 24000000/1228800 = 19.531... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=3,  UCBRS0=fn(frac(N))=fn(0.531)=0xAA
            MOV     #1,     &TERMBRW
            MOV.W   #0AA31h,&TERMMCTLW

        .CASE 921600
; Configure UART_TERM @ 921600 bauds / 12MHz
; Configure UART_TERM @ 1843200 bauds / 24MHz
; N = 24000000/1843200 = 13.08203...  {UCOS16=0, UCBR0=int(N)=13, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.08203)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #17,    &TERMBRW
            MOV.W   #04A00h,&TERMMCTLW

        .CASE 1000000
; Configure UART_TERM @ 1000000 bauds / 12MHz
; N = 12000000/1000000 = 12 ==> {UCOS16=0, UCBR0=int(N)=12, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #12,    &TERMBRW
            MOV.W   #0,&TERMMCTLW

        .CASE 1228800 ; PL2303TA baudrate
; Configure UART_TERM @ 1228800 bauds / 12MHz
; Configure UART_TERM @ 2457600 bauds / 24MHz
; N = 24000000/2457600 = 9.765625... ==> {UCOS16=0, UCBR0=int(N)=9, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.765625)=0xDD
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #9,     &TERMBRW
             MOV.W   #0dd00h,&TERMMCTLW

        .CASE 1382400 ; CP2102 baudrate (with programming)
; Configure UART_TERM @ 1382400 bauds / 12MHz
; N = 12000000/1382400 = 8.68055... ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.68055)=0x6B
            MOV     #8,    &TERMBRW
            MOV.W   #06B00h,&TERMMCTLW

        .CASE 1843200 ; CP2102 baudrate (with programming)
; Configure UART_TERM @ 1843200 bauds / 12MHz
; N = 12000000/1843200 = 6.510416... ==> {UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.5104)=0xaa
            MOV     #6,    &TERMBRW
            MOV.W   #0AA00h,&TERMMCTLW

        .CASE 2000000
; Configure UART_TERM @ 2000000 bauds / 12MHz
; Configure UART_TERM @ 4000000 bauds / 24MHz
; N = 24000000/4000000 = 6... ==> {UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.0000000)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #6,&TERMBRW
             MOV.W   #0,&TERMMCTLW

        .CASE 2457600 ; PL2303TA baudrate
; Configure UART_TERM @ 1228800 bauds / 12MHz
; N = 12000000/2457600 = 4.8828... ==> {UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.8828)=0xF7
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,     &TERMBRW
             MOV.W   #0F700h,&TERMMCTLW

        .CASE 3000000 ; PL2303TA baudrate
; Configure UART_TERM @ 3000000 bauds / 12MHz
; Configure UART_TERM @ 6000000 bauds / 24MHz
; N = 24000000/6000000 = 4 ==> {UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
             MOV     #4,     &TERMBRW
             MOV.W   #0,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 12 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 12 MHz baudrates





    .ELSEIF FREQUENCY = 16
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 16MHz
; N=16000000/9600=1666.666... ==> UCOS16=1, UCBR0=int(N/16)=104, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0.66666)=0xD6
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #104,    &TERMBRW
            MOV     #0D621h, &TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 16MHz
; N=16000000/19200=833.333... ==> UCOS16=1, UCBR0=int(N/16)=52, UCBRF0=int(frac(N/16)*16)=1, UCBRS0= fn(frac(N))=fn(0.33333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #52,    &TERMBRW
            MOV     #4911h, &TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 16MHz
; N=16000000/31250=512 ==> UCOS16=1, UCBR0=int(N/16)=32, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #32,     &TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 16MHz
; N=16000000/19200=416.666... ==> UCOS16=1, UCBR0=int(N/16)=26, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.66666)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #26,    &TERMBRW
            MOV.W   #0D601h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 16MHz
; N=16000000/57600=277.777... ==> UCOS16=1, UCBR0=int(N/16)=17, UCBRF0=int(frac(N/16)*16)=5, UCBRS0= fn(frac(N))=fn(0.77777)=0xDD
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #17,     &TERMBRW
            MOV.W   #0DD51h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 16MHz
; N=16000000/115200=138.888... ==> UCOS16=1, UCBR0=int(N/16)=8, UCBRF0=int(frac(N/16)*16)=10, UCBRS0= fn(frac(N))=fn(0.88888)=0xF7
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #8,     &TERMBRW
            MOV.W   #0F7A1h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 16MHz
; N=16000000/230400=69.444... ==> UCOS16=1, UCBR0=int(N/16)=4, UCBRF0=int(frac(N/16)*16)=5, UCBRS0= fn(frac(N))=fn(0.44444)=0x55
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #5551h, &TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 16MHz
; N=16000000/250000=64 ==> UCOS16=1, UCBR0=int(N/16)=4, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #4,     &TERMBRW
            MOV.W   #0001h, &TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 16MHz
; N=16000000/460800=34.7222... ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0.72222)=0xBB
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #0BB21h,&TERMMCTLW

        .CASE 500000 ; CP2102 baudrate
; Configure UART_TERM @ 500000 bauds / 16MHz
; N = 16000000/500000 = 32 ==> {UCOS16=1, UCBR0=int(N/16)=2, UCBRF1=int(frac(N/16)*16)=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;            MOV     #2,  &TERMBRW
;            MOV.W   #00001h,&TERMMCTLW

        .CASE 921600
;; Configure UART_TERM @ 921600 bauds / 16MHz
; N = 1600000/921600 = 17.3611... ==> {UCOS16=0, UCBR0=int(N)=14, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.3611)=0x4A
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #17,    &TERMBRW
            MOV.W   #04A00h,&TERMMCTLW
; Configure UART_TERM @ 921600 bauds / 16MHz
; N = 16000000/921600 = 17.3611 ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=1  UCBRS0=fn(frac(N))=fn(0.3611)=0x4A
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;            MOV     #1,    &TERMBRW
;            MOV.W   #04A11h,&TERMMCTLW

        .CASE 1000000
; Configure UART_TERM @ 1000000 bauds / 16MHz
; N = 16000000/1000000 = 16 ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,    &TERMBRW
            MOV.W   #00001h,&TERMMCTLW

        .CASE 1228800 ; PL2303TA baudrate
; Configure UART_TERM @ 1228800 bauds / 16MHz
; Configure UART_TERM @ 614400 bauds / 8MHz
; N = 8000000/614400 = 13.02083... ==> {UCOS16=0, UCBR0=int(N)=13, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.02083)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #13,     &TERMBRW
             MOV.W   #00200h,&TERMMCTLW

        .CASE 1382400 ; CP2102 baudrate (with programming)
; Configure UART_TERM @ 1382400 bauds / 16MHz
; N = 16000000/1382400 = 11.574074... ==> {UCOS16=0, UCBR0=int(N)=11, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.68055)=0x6B
            MOV     #11,    &TERMBRW
            MOV.W   #06B00h,&TERMMCTLW

        .CASE 1843200 ; CP2102 baudrate (with programming)
; Configure UART_TERM @ 1843200 bauds / 16MHz
; N = 16000000/1843200 = 8.680555... ==> {UCOS16=0, UCBR1=int(N)=8, UCBRF1=dont_care=0  UCBRS1=fn(frac(N))=fn(0.68055)=0xD6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #8,     &TERMBRW
             MOV.W   #0D600h,&TERMMCTLW

        .CASE 2000000
; Configure UART_TERM @ 2000000 bauds / 16MHz
; N = 16000000/2000000 = 8 ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
            MOV     #8 ,    &TERMBRW
            MOV.W   #00000h,&TERMMCTLW

        .CASE 2457600 ; PL2303TA baudrate
; Configure UART_TERM @ 1228800 bauds / 8MHz
; N = 8000000/1228800 = 6.510416... ==> {UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.510416)=0xAA
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #6,     &TERMBRW
             MOV.W   #0AA00h,&TERMMCTLW

        .CASE 2764800
; Configure UART_TERM @ 2764800 bauds / 16MHz
; N = 16000000/2764800 = 5.787037... ==> {UCOS16=0, UCBR0=int(N)=5, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.787037)=0xED
            MOV     #5,    &TERMBRW
            MOV.W   #0DD00h,&TERMMCTLW

        .CASE 3000000 ; PL2303TA baudrate
; Configure UART_TERM @ 3000000 bauds / 16MHz
; N = 16000000/3000000 = 5.333333... ==> {UCOS16=0, UCBR0=int(N)=5, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.333333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #5,     &TERMBRW
             MOV.W   #04900h,&TERMMCTLW

        .CASE 4000000 ; PL203HXD baudrate
; Configure UART_TERM @ 4000000 bauds / 16MHz
; N = 16000000/4000000 = 4... ==> {UCOS16=0, UCBR0=int(N)=0, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.0000000)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,&TERMBRW
             MOV.W   #0,&TERMMCTLW

        .CASE 5000000 ; PL203HXD baudrate
; Configure UART_TERM @ 5000000 bauds / 16MHz
; N = 16000000/5000000 = 3.2... ==> {UCOS16=0, UCBR0=int(N)=0, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.2)=0x11
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #3,&TERMBRW
             MOV.W   #02100h,&TERMMCTLW

        .CASE 6000000 ; PL2303TA baudrate
; Configure UART_TERM @ 6000000 bauds / 24MHz
; N = 16000000/6000000 = 2.6666.. ==> {UCOS16=0, UCBR0=int(N)=2, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.6666)=0xB6
            MOV     #2,&TERMBRW
            MOV.W   #0B600h,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 16 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 16 MHz baudrates

    .ELSEIF FREQUENCY = 20
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 20MHz
; N=20000000/9600=2083.3333 ==> UCOS16=1, UCBR0=int(N/16)=130, UCBRF0=int(frac(N/16)*16)=3, UCBRS0= fn(frac(N))=(fn(.3333))=0x25
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #130,&TERMBRW
            MOV     #2531h,&TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 20MHz
; N=20000000/19200=1041.66666 ==> UCOS16=1, UCBR0=int(N/16)=65, UCBRF0=int(frac(N/16)*16)=1, UCBRS0= fn(frac(N))=fn(0.66666)=0xd6
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #65,&TERMBRW
            MOV     #0D611h,&TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 20MHz
; N=20000000/31250=640 ==> UCOS16=1, UCBR0=int(N/16)=40, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #40,&TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 20MHz
; N=20000000/38400=520.833333 ==> UCOS16=1, UCBR0=int(N/16)=32, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0)=0xBF
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #32,&TERMBRW
            MOV.W   #0BF01h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 20MHz
; N=20000000/57600=346.0207... ==> UCOS16=1, UCBR0=int(N/16)=21, UCBRF0=int(frac(N/16)*16)=0Ah, UCBRS0= fn(frac(N))=fn(0.0207)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #21,&TERMBRW
            MOV.W   #000A1h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 20MHz
; N=20000000/115200=173.61111... ==> UCOS16=1, UCBR0=int(N/16)=10, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.6111)=0xAD
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #10,&TERMBRW
            MOV.W   #0AD01h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 20MHz
; N=20000000/230400=86.80555... ==> UCOS16=1, UCBR0=int(N/16)=5, UCBRF0=int(frac(N/16)*16)=6, UCBRS0= fn(frac(N))=fn(0.80555)=0xEE
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #5,&TERMBRW
            MOV.W   #0EE61h,&TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 20MHz
; N=20000000/250000=80 ==> UCOS16=1, UCBR0=int(N/16)=5, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #5,     &TERMBRW
            MOV.W   #0001h, &TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 20MHz
; N=20000000/460800=43.402777... ==> UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=0Bh, UCBRS0= fn(frac(N))=fn(0.4027)=0x92
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,     &TERMBRW
            MOV.W   #92B1h,&TERMMCTLW

        .CASE 500000 ; CP2102 baudrate
; Configure UART_TERM @ 500000 bauds / 20MHz
; N = 20000000/500000 = 40 ==> {UCOS16=1, UCBR0=int(N/16)=2, UCBRF0=int(frac(N/16)*16)=8  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #2,  &TERMBRW
            MOV.W   #0081h,&TERMMCTLW

        .CASE 921600
; Configure UART_TERM @ 921600 bauds / 20MHz
; N = 20000000/921600 = 21.701388... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=5  UCBRS0=fn(frac(N))=fn(0.70138)=0xB7
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0B751h,&TERMMCTLW

        .CASE 1000000
; Configure UART_TERM @ 1000000 bauds / 20MHz
; N = 20000000/1000000 = 20 ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=4,  UCBRS0=fn(frac(N))=fn(0.000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0041h,&TERMMCTLW

        .CASE 1228800
; Configure UART_TERM @ 1228800 bauds / 20MHz
; N = 20000000/1228800 = 16.276... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=0,  UCBRS0=fn(frac(N))=fn(0.276)=0x44
            MOV     #1,     &TERMBRW
            MOV.W   #04411h,&TERMMCTLW

        .CASE 1382400
; Configure UART_TERM @ 1382400 bauds / 20MHz
; N = 20000000/1382400 = 14.46759... ==> {UCOS16=0, UCBR0=int(N)=14, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.46759)=0x55
            MOV     #14,     &TERMBRW
            MOV.W   #05500h,&TERMMCTLW

        .CASE 1843200
; Configure UART_TERM @ 1843200 bauds / 20MHz
; N = 20000000/1843200 = 10.85069...  {UCOS16=0, UCBR0=int(N)=10, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.85069)=0xDF
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #10,    &TERMBRW
             MOV.W   #0DF00h,&TERMMCTLW

        .CASE 2457600 ; PL2303TA baudrate
; Configure UART_TERM @ 2457600 bauds / 20MHz
; N = 20000000/2457600 = 8.13802... ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.13802)=0x11
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #8,     &TERMBRW
             MOV.W   #01100h,&TERMMCTLW

        .CASE 3000000 ; PL2303TA baudrate
; Configure UART_TERM @ 3000000 bauds / 20MHz
; N = 20000000/3000000 = 6.666666 ==> {UCOS16=0, UCBR0=int(N)=6, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.66666)=0xD6
            MOV     #6,&TERMBRW
             MOV.W   #0D600h,&TERMMCTLW

        .CASE 4000000 ; PL2303HXD baudrate
; Configure UART_TERM @ 4000000 bauds / 20MHz
; N = 20000000/4000000 = 5... ==> {UCOS16=0, UCBR0=int(N)=5, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.0000000)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #5,&TERMBRW
             MOV.W   #0,&TERMMCTLW

        .CASE 5000000 ; PL203HXD baudrate
; Configure UART_TERM @ 5000000 bauds / 20MHz
; N = 20000000/5000000 = 4... ==> {UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.00)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,&TERMBRW
             MOV.W   #0,&TERMMCTLW

        .CASE 6000000 ; PL2303TA baudrate
; Configure UART_TERM @ 6000000 bauds / 20MHz
; N = 20000000/6000000 = 3.3333333 ==> {UCOS16=0, UCBR0=int(N)=3, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.33333)=0x49
            MOV     #3,&TERMBRW
             MOV.W   #04900h,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 20 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 20 MHz baudrates

    .ELSEIF FREQUENCY = 24
        .SWITCH TERMINALBAUDRATE
        .CASE 9600
; Configure UART_TERM @ 9600 bauds / 24MHz
; N=24000000/9600=2500 ==> UCOS16=1, UCBR0=int(N/16)=156, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=(fn(0))=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #156,    &TERMBRW
            MOV     #0041h, &TERMMCTLW

        .CASE 19200
; Configure UART_TERM @ 19200 bauds / 24MHz
; N=24000000/19200=1250 ==> UCOS16=1, UCBR0=int(N/16)=78, UCBRF0=int(frac(N/16)*16)=2, UCBRS0= fn(frac(N))=fn(0)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #78,    &TERMBRW
            MOV     #0021h, &TERMMCTLW

        .CASE 31250  ; MIDI interface
; Configure UART_TERM @ 31250 bauds / 8MHz
; N=24000000/31250=768 ==> UCOS16=1, UCBR0=int(N/16)=48, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #48,     &TERMBRW
            MOV.W   #0001h,&TERMMCTLW

        .CASE 38400
; Configure UART_TERM @ 38400 bauds / 24MHz
; N=24000000/19200=625 ==> UCOS16=1, UCBR0=int(N/16)=39, UCBRF0=int(frac(N/16)*16)=1, UCBRS0= fn(frac(N))=fn(0)=0x00
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #39,    &TERMBRW
            MOV.W   #0011h,&TERMMCTLW

        .CASE 57600
; Configure UART_TERM @ 57600 bauds / 24MHz
; N=24000000/57600=416.666... ==> UCOS16=1, UCBR0=int(N/16)=26, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.666)=0xD6
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #26,     &TERMBRW
            MOV.W   #0D601h,&TERMMCTLW

        .CASE 115200
; Configure UART_TERM @ 115200 bauds / 24MHz
; N=24000000/115200=208.333... ==> UCOS16=1, UCBR0=int(N/16)=13, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0.333)=0x49
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #13,     &TERMBRW
            MOV.W   #04901h,&TERMMCTLW

        .CASE 230400
; Configure UART_TERM @ 230400 bauds / 24MHz
; N=24000000/230400=104.1666... ==> UCOS16=1, UCBR0=int(N/16)=6, UCBRF0=int(frac(N/16)*16)=8, UCBRS0= fn(frac(N))=fn(0.1666)=0x20
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,     &TERMBRW
            MOV.W   #2081h, &TERMMCTLW

        .CASE 250000  ; DMX interface
; Configure UART_TERM @ 250000 bauds / 24MHz
; N=24000000/250000=96 ==> UCOS16=1, UCBR0=int(N/16)=6, UCBRF0=int(frac(N/16)*16)=0, UCBRS0= fn(frac(N))=fn(0)=0
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #6,     &TERMBRW
            MOV.W   #0001h, &TERMMCTLW

        .CASE 460800
; Configure UART_TERM @ 460800 bauds / 24MHz
; N=24000000/460800=52.08333... ==> UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=4, UCBRS0= fn(frac(N))=fn(0.0833)=0x02
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #3,     &TERMBRW
            MOV.W   #0241h,&TERMMCTLW

        .CASE 500000 ; CP2102 baudrate
; Configure UART_TERM @ 500000 bauds / 24MHz
; N = 24000000/500000 = 48 ==> {UCOS16=1, UCBR0=int(N/16)=3, UCBRF0=int(frac(N/16)*16)=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
;            MOV     #3,  &TERMBRW
;            MOV.W   #0001h,&TERMMCTLW

        .CASE 921600
; Configure UART_TERM @ 921600 bauds / 24MHz
; N = 24000000/921600 = 26.041666... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=10  UCBRS0=fn(frac(N))=fn(0.0416)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #00A1h,&TERMMCTLW

        .CASE 1000000
; Configure UART_TERM @ 1000000 bauds / 24MHz
; N = 24000000/1000000 = 24 ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=4,  UCBRS0=fn(frac(N))=fn(0.000)=0x00
; TERMBRW=UCBR1, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
            MOV     #1,     &TERMBRW
            MOV.W   #0041h,&TERMMCTLW

        .CASE 1228800
; Configure UART_TERM @ 1228800 bauds / 24MHz
; N = 24000000/1228800 = 19.531... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=3,  UCBRS0=fn(frac(N))=fn(0.531)=0xAA
            MOV     #1,     &TERMBRW
            MOV.W   #0AA31h,&TERMMCTLW

        .CASE 1382400
; Configure UART_TERM @ 1382400 bauds / 24MHz
; N = 24000000/1382400 = 17.36111... ==> {UCOS16=1, UCBR0=int(N/16)=1, UCBRF0=int(frac(N/16)*16)=1,  UCBRS0=fn(frac(N))=fn(0.3611)=0x4A
            MOV     #1,     &TERMBRW
            MOV.W   #04A11h,&TERMMCTLW

        .CASE 1843200
; Configure UART_TERM @ 1843200 bauds / 24MHz
; N = 24000000/1843200 = 13.08203...  {UCOS16=0, UCBR0=int(N)=13, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.08203)=0x02
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #13,    &TERMBRW
             MOV.W   #0200h,&TERMMCTLW

        .CASE 2457600 ; PL2303TA baudrate
; Configure UART_TERM @ 2457600 bauds / 24MHz
; N = 24000000/2457600 = 9.765625... ==> {UCOS16=0, UCBR0=int(N)=9, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.765625)=0xDD
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #9,     &TERMBRW
             MOV.W   #0DD00h,&TERMMCTLW

        .CASE 3000000 ; PL2303TA baudrate
; Configure UART_TERM @ 3000000 bauds / 24MHz
; N = 24000000/3000000 = 8 ==> {UCOS16=0, UCBR0=int(N)=8, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
            MOV     #8,&TERMBRW
            MOV.W   #0,&TERMMCTLW

        .CASE 4000000 ; PL2303HXD baudrate
; Configure UART_TERM @ 4000000 bauds / 24MHz
; N = 24000000/4000000 = 6... ==> {UCOS16=0, UCBR0=int(N)=0, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.0000000)=0
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #6,&TERMBRW
             MOV.W   #0,&TERMMCTLW

        .CASE 5000000 ; PL203HXD baudrate
; Configure UART_TERM @ 5000000 bauds / 24MHz
; N = 24000000/5000000 = 4.8... ==> {UCOS16=0, UCBR0=int(N)=0, UCBRF0=dont_care=0, UCBRS0=fn(frac(N))=fn(0.2)=0x11
; TERMBRW=UCBR0, TERMMCTLW= (UCBRS0<<8)|(UCBRF0<<4)|UCOS16
             MOV     #4,&TERMBRW
             MOV.W   #0EE00h,&TERMMCTLW

        .CASE 6000000 ; PL2303TA baudrate
; Configure UART_TERM @ 6000000 bauds / 24MHz
; N = 24000000/6000000 = 4 ==> {UCOS16=0, UCBR0=int(N)=4, UCBRF0=dont_care=0  UCBRS0=fn(frac(N))=fn(0.00000)=0x00
            MOV     #4,&TERMBRW
            MOV.W   #0,&TERMMCTLW

        .ELSECASE
            .error "UART_TERM / 24 MHz : baudrate not implemented"
        .ENDCASE ; UART_TERM / 24MHz baudrates

    .ELSEIF 
        .error "UART_TERM frequency not implemented"
    .ENDIF ; frequency

