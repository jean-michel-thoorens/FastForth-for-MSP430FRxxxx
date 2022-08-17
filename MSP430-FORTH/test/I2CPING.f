\ https://theforth.net/package/i2c/current-view/i2c-detect.frt

\ I2C
\ ===
\ 
\ Matthias Trute <mtrute@web.de>
\ Version 1.0.3 - 2017-04-30
\ 
\ This package provides some more or less
\ generic I2C related words. They are generic
\ in a sense that they depend on a low level
\ hardware driver, that provides some very
\ basic routines to access the I2C interface.
\ They are based on the amforth recipe 
\ http://amforth.sourceforge.net/TG/recipes/I2C-Generic.html
\ 
\ They are tested with amforth on an Atmega with
\ it's hardware I2C module called TWI.
\ 
\ The driver uses the following hardware low level words, that
\ the user has to provide.
\ 
\ i2c.wait ( -- )
\   wait for the bus
\ 
\ i2c.start ( -- )
\   send start condition
\ 
\ i2c.stop ( -- )
\   send stop condition
\ 
\ i2c.restart ( -- )
\   send the restart condition
\ 
\ i2c.tx ( c -- )
\   send 1 byte
\ 
\ i2c.rx ( -- c )
\   receive 1 byte, send ACK
\ 
\ i2c.rxn ( -- c )
\   receive 1 byte, send NACK
\ 
\ The following two words are not essential but
\ are useful for tools and checks.
\ 
\ i2c.status ( -- n )
\   get i2c status in a system specific way
\ 
\ i2c.ping?   ( addr -- f )
\   detect the presence of a device on the bus, f is true if a device
\   at addr responds


\ detect presence of all possible devices on I2C bus
\ only the 7 bit address schema is supported

\ not all bitpatterns are valid 7bit i2c addresses
: i2c.7bitaddr? ( a -- f)  $7 $78 within ;

: i2c.detect   ( -- )
    base @ hex
    \ header line
    4 spaces $10 0 do i 3 .r loop
    $80 0 do
      i $0f and 0= if
        cr i 2 .r [char] : emit space
      then
      i i2c.7bitaddr? if
        i i2c.ping? if \ does device respond?
            i 3 .r
          else
            ."  --" 
        then
      else
         ."    "
      then
    loop 
    cr base !
;

\ output looks like
\ (ATmega1280)> i2c.detect 
\       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
\  0:                       -- -- -- -- -- -- -- -- --
\ 10:  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\ 20:  -- -- -- -- -- -- -- 27 -- -- -- -- -- -- -- --
\ 30:  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\ 40:  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\ 50:  50 -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\ 60:  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\ 70:  -- -- -- -- -- -- -- --                        
\  ok
\ 