; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

           org     8000h
           lbr     0ff00h
           db      'ver',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0

           org     2000h
           br      start               ; jump past version info

include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0

start:     ldn     ra                  ; get byte from passed args
           bnz     filever             ; jump for file version
           ldi     high buffer         ; point to buffer
           phi     rf
           ldi     low buffer
           plo     rf
           ldi     04h                 ; point to os data
           phi     rb
           ldi     0
           plo     rb
           lda     rb                  ; get major version number
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           sep     scall               ; convert number
           dw      donum
           ldi     '.'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get minor version number
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           sep     scall               ; convert number
           dw      donum
           ldi     '.'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get minor version number
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           sep     scall               ; convert number
           dw      donum
           ldi     ' '                 ; put a dot into the buffer
           str     rf
           inc     rf
           ldi     'B'                 ; put a dot into the buffer
           str     rf
           inc     rf
           ldi     'u'                 ; put a dot into the buffer
           str     rf
           inc     rf
           ldi     'i'                 ; put a dot into the buffer
           str     rf
           inc     rf
           ldi     'l'                 ; put a dot into the buffer
           str     rf
           inc     rf
           ldi     'd'                 ; put a dot into the buffer
           str     rf
           inc     rf
           ldi     ' '                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get it
           phi     rd
           lda     rb
           plo     rd
           sep     scall               ; convert number
           dw      donum
           ldi     ' '                 ; put a dot into the buffer
           str     rf
           inc     rf
           sep     scall               ; display date
           dw      dodate
           sep     scall               ; display cr/lf
           dw      f_inmsg
           db      10,13,0
           sep     sret                ; and return to caller

dodate:    lda     rb                  ; get month
           ani     07fh                ; strip high bit
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           sep     scall               ; convert number
           dw      donum
           ldi     '/'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get day
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           sep     scall               ; convert number
           dw      donum
           ldi     '/'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get year
           phi     rd                  ; prepare for conversion
           lda     rb
           plo     rd
           sep     scall               ; convert number
           dw      donum

           ldi     0
           str     rf
           inc     rf
           ldi     high buffer         ; point to buffer
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall               ; display version
           dw      o_msg
           sep     sret                ; and return to caller

donum:     glo     rd                  ; check for zero
           bnz     nonzero             ; jump if not zero
           ldi     '0'                 ; store zero into buffer
           str     rf
           inc     rf
           sep     sret                ; and return
nonzero:   sep     scall               ; convert number
           dw      f_intout
           sep     sret                ; and return to caller

filever:   ghi     ra                  ; transfer args to rf
           phi     rf
           glo     ra
           plo     rf
loop1:     lda     ra                  ; find end of filename
           smi     33                  ; looking for a space or less
           lbdf     loop1              ; loop until found
           dec     ra                  ; back up 1
           ldi     0                   ; need to terminate it
           str     ra
           ldi     high fildes         ; get file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     0                   ; flags for open
           plo     r7
           sep     scall               ; attempt to open file
           dw      o_open
           lbnf     opened             ; jump if file was opened
           ldi     high errmsg         ; get error message
           phi     rf
           ldi     low errmsg
           plo     rf
           sep     scall               ; display it
           dw      o_msg
           lbr     o_wrmboot           ; and return to os
opened:    ldi     high buffer2        ; set up for read
           phi     rf
           ldi     low buffer2
           plo     rf
           ldi     0                   ; need to read 8 bytes
           phi     rc
           ldi     8
           plo     rc
           sep     scall               ; read them
           dw      o_read
           ldi     high buffer2        ; set up for read
           phi     rf
           ldi     low buffer2
           plo     rf
           ldi     0                   ; need to read 4 bytes
           phi     rc
           ldi     4
           plo     rc
           sep     scall               ; read them
           dw      o_read
           ldi     high buffer2        ; set up for display
           phi     rb
           ldi     low buffer2
           plo     rb
           ldi     high buffer         ; setup output buffer
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall                ; display the date
           dw      dodate
           mov     rf,buffer2           ; point to buffer
           ldn     rf                   ; retrieve month
           shl                          ; shift high bit to DF
           lbnf    return               ; done if not extended block
           sep     scall                ; need to display build number
           dw      f_inmsg
           db      ' Build: ',0
           mov     rf,buffer2           ; need to read build number
           mov     rd,fildes
           mov     rc,2
           sep     scall
           dw      o_read
           mov     rf,buffer2           ; point to read bytes
           lda     rf                   ; get the number
           phi     rd
           lda     rf
           plo     rd
           mov     rf,buffer2           ; where to put conversion
           sep     scall                ; convert number
           dw      f_uintout
           ldi     ' '                  ; add a space
           str     rf
           inc     rf
           str     rf
           inc     rf
           ldi     0                    ; and terminator
           str     rf
           mov     rf,buffer2           ; now display build number
           sep     scall
           dw      f_msg
comment:   mov     rf,buffer2           ; point to buffer
           mov     rd,fildes            ; point to fildes
           mov     rc,1                 ; read 1 byte
           sep     scall
           dw      o_read
           lbdf    return               ; end if error
           glo     rc                   ; get read count
           smi     1                    ; check for 1 byte read
           lbnz    return               ; jump if done
           mov     rf,buffer2           ; point back to read byte
           ldn     rf                   ; get it
           lbz     return               ; done if terminator
           sep     scall                ; otherwise display it
           dw      f_type
           lbr     comment              ; loop to read rest of comment 
return:    sep     scall                ; display cr/lf
           dw      f_inmsg
           db      10,13,0
           mov     rd,fildes            ; close the file
           sep     scall
           dw      o_close
           lbr     o_wrmboot            ; return to OS


errmsg:    db      'File not found',10,13,0

fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

dta:       ds      512

buffer2:   ds      8

buffer:    db      0
