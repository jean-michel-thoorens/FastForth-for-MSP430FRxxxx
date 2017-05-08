; -*- coding: utf-8 -*-
; http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
; Copyright (C) <2015>  <J.M. THOORENS>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;C ALIGNED  addr -- a-addr       align given addr
            FORTHWORD "ALIGNED"
ALIGNED     BIT     #1,TOS
            ADDC    #0,TOS
            mNEXT

;C ALIGN    --                         align HERE
            FORTHWORD "ALIGN"
ALIGNN      BIT     #1,&DDP   ; 3
            ADDC    #0,&DDP   ; 4
            mNEXT


