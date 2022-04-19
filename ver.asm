; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

.op "PUSH","N","9$1 73 8$1 73"
.op "POP","N","60 72 A$1 F0 B$1"
.op "CALL","W","D4 H1 L1"
.op "RTN","","D5"
.op "MOV","NR","9$1 B$2 8$1 A$2"
.op "MOV","NW","f8 H2 B$1 f8 L2 a$1"

#ifdef PACKAGE
           org     8000h
           lbr     0ff00h
           db      'ver',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0
#endif

           org     2000h
start:     br      begin               ; jump past version info
           eever
           db      'Written by Michael H. Riley',0

begin:     ldn     ra                  ; get byte from passed args
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
           call    donum
           ldi     '.'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get minor version number
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           call    donum
           ldi     '.'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get minor version number
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           call    donum
           call    incopy
           db      ' Build ',0
;           ldi     ' '                 ; put a dot into the buffer
;           str     rf
;           inc     rf
;           ldi     'B'                 ; put a dot into the buffer
;           str     rf
;           inc     rf
;           ldi     'u'                 ; put a dot into the buffer
;           str     rf
;           inc     rf
;           ldi     'i'                 ; put a dot into the buffer
;           str     rf
;           inc     rf
;           ldi     'l'                 ; put a dot into the buffer
;           str     rf
;           inc     rf
;           ldi     'd'                 ; put a dot into the buffer
;           str     rf
;           inc     rf
;           ldi     ' '                 ; put a dot into the buffer
;           str     rf
;           inc     rf
           lda     rb                  ; get it
           phi     rd
           lda     rb
           plo     rd
           call    donum
           ldi     ' '                 ; put a dot into the buffer
           str     rf
           inc     rf
           call    dodate
           call    o_inmsg
           db      10,13,0
retrn:     rtn

incopy:    lda     r6                  ; get next byte
           lbz     retrn               ; jump if done
           str     rf                  ; store it
           inc     rf                  ; next position
           lbr     incopy              ; loop until done

dodate:    lda     rb                  ; get month
           ani     00fh                ; strip high bits
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           call    donum
           ldi     '/'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get day
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           call    donum
           ldi     '/'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get year
           phi     rd                  ; prepare for conversion
           lda     rb
           plo     rd
           call    donum

           ldi     0
           str     rf
           inc     rf
           ldi     high buffer         ; point to buffer
           phi     rf
           ldi     low buffer
           plo     rf
           call    o_msg
           rtn

dotime:    ldi     ' '                 ; put space into output
           str     rf
           inc     rf
           lda     rb                  ; get month
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           call    donum
           ldi     ':'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get day
           plo     rd                  ; prepare for conversion
           ldi     0                   ; high byte is zero
           phi     rd
           call    donum
           ldi     ':'                 ; put a dot into the buffer
           str     rf
           inc     rf
           lda     rb                  ; get year
           plo     rd                  ; prepare for conversion
           ldi     0
           phi     rd
           call    donum

           ldi     0
           str     rf
           inc     rf
           ldi     high buffer         ; point to buffer
           phi     rf
           ldi     low buffer
           plo     rf
           call    o_msg
           rtn

donum:     glo     rd                  ; check for zero
           bnz     nonzero             ; jump if not zero
           ldi     '0'                 ; store zero into buffer
           str     rf
           inc     rf
           rtn
nonzero:   call    f_intout
           rtn

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
           call    o_open
           lbnf     opened             ; jump if file was opened
           ldi     high errmsg         ; get error message
           phi     rf
           ldi     low errmsg
           plo     rf
           call    o_msg
           ldi     0ch
           rtn
opened:    ldi     high buffer2        ; set up for read
           phi     rf
           ldi     low buffer2
           plo     rf
           ldi     0                   ; need to read 8 bytes
           phi     rc
           ldi     8
           plo     rc
           call    o_read
           ldi     high buffer2        ; set up for read
           phi     rf
           ldi     low buffer2
           plo     rf
           ldi     0                   ; need to read 4 bytes
           phi     rc
           ldi     4
           plo     rc
           call    o_read
           ldi     high buffer2        ; set up for display
           phi     rb
           ldi     low buffer2
           plo     rb
           ldi     high buffer         ; setup output buffer
           phi     rf
           ldi     low buffer
           plo     rf
           call    dodate
           mov     rf,buffer2           ; point to buffer
           ldn     rf                   ; retrieve month
           stxd                         ; need to keep this for later
           ani     040h                 ; is bit 6 set
           lbz     notime               ; jump if no time present
           mov     rf,buffer2           ; need to read build time
           mov     rd,fildes
           mov     rc,3
           call    o_read
           mov     rf,buffer            ; point to output bufer
           mov     rb,buffer2           ; point to read bytes
           call    dotime               ; display time
notime:    irx                          ; recover month byte
           ldx
           dec     r2                   ; keep on stack
           shl                          ; shift high bit to DF
           lbnf    nobuild              ; done if not extended block
           call    o_inmsg
           db      ' Build: ',0
           mov     rf,buffer2           ; need to read build number
           mov     rd,fildes
           mov     rc,2
           call    o_read
           mov     rf,buffer2           ; point to read bytes
           lda     rf                   ; get the number
           phi     rd
           lda     rf
           plo     rd
           mov     rf,buffer2           ; where to put conversion
           call    f_uintout
           ldi     ' '                  ; add a space
           str     rf
           inc     rf
           str     rf
           inc     rf
           ldi     0                    ; and terminator
           str     rf
           mov     rf,buffer2           ; now display build number
           call    o_msg
nobuild:   irx                          ; recover flags byte
           ldx
           ori     0c0h                 ; see if comment is presnet
           lbz     return               ; jump if not
comment:   mov     rf,buffer2           ; point to buffer
           mov     rd,fildes            ; point to fildes
           mov     rc,1                 ; read 1 byte
           call    o_read
           lbdf    return               ; end if error
           glo     rc                   ; get read count
           smi     1                    ; check for 1 byte read
           lbnz    return               ; jump if done
           mov     rf,buffer2           ; point back to read byte
           ldn     rf                   ; get it
           lbz     return               ; done if terminator
           call    o_type
           lbr     comment              ; loop to read rest of comment 
return:    call    o_inmsg
           db      10,13,0
           mov     rd,fildes            ; close the file
           call    o_close
           ldi     0
           rtn

errmsg:    db      'File not found',10,13,0

fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $
.suppress

dta:       ds      512

buffer2:   ds      8

buffer:    db      0

           end     start
