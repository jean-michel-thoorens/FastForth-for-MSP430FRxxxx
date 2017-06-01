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


;https://forth-standard.org/standard/core/CHARS
;C CHARS    n1 -- n2            chars->adrs units
            FORTHWORD "CHARS"
            mNEXT

;https://forth-standard.org/standard/core/CHARPlus
;C CHAR+    c-addr1 -- c-addr2   add char size
            FORTHWORD "CHAR+"
            ADD     #1,TOS
            mNEXT

;https://forth-standard.org/standard/core/CELLS
;C CELLS    n1 -- n2            cells->adrs units
            FORTHWORD "CELLS"
            ADD     TOS,TOS
            mNEXT

;https://forth-standard.org/standard/core/CELLPlus
;C CELL+    a-addr1 -- a-addr2      add cell size
            FORTHWORD "CELL+"
            ADD     #2,TOS
            mNEXT

