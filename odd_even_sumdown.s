;registers r24 for return value
;r23, r25 for overwriting
;r16, r17 saved/restored for push/pop
;r27:r26 for X, r29:r28 for Y, r31:r30 for Z


; 5 steps approach
; 1: DATA
; 2: determine and assign registers
; 3: control flow
; 4: functions
; 5: offsets
.section .data
a: 
.byte 1, 2, 3
.byte 10, 11, 12
.byte 4, 5, 6

c:
.byte 0, 0, 0
.byte 0, 0, 0
.byte 0, 0, 0

num_rows: .byte 3
num_cols: .byte 3


.section .text
.global asm_function

ldi r24, lo8(a)
push r24
ldi r24, hi8(a)
push r24
ldi r24, lo8(c)
push r24
ldi r24, hi8(c)
push r24
lds r24, num_rows
push r24
lds r24, num_cols
push r24

call elementwise

pop r24
pop r24
pop r24
pop r24
pop r24
pop r24
ret

elementwise:
    push r16
    push r17
    push r28
    push r29
    in r28, 0X3D ;low byte of SP, setting Y lowbyte to SP lowbyte
    in r29, 0x3E ;high byte of SP, setting Y highbyte to SP highbyte

    ldd r16, Y+8 ;num rows
    ldd r31, Y+9 ; Setting Z to c 31 = highbyte
    ldd r30, Y+10 ; r30 is lowbyte, X = r31:r30
    ldd r27, Y+12 ; setting X lowbyte to a low byte
    ldd r28, Y+11; setting x highbyte to a highbyte


row_loop:  ; for row in range(num_rows)
    cpi r16, 0  ;comparing r16 (num rows) to 0
    breq loop_done ;if r16 isnt 0, then continue
    ldd r17,  Y+7  ;setting r17 (num cols) to column number 
col_loop:
    cpi r17, 0 ;comparing r17 (col rows) to 0
    breq row_next ;if 0 then go to row_next

    ld r24, X+ ; set a[x] to r24, auto increment x
    push  r24 ;push r24 into stack
    call sumdown ;call sumdown subroutine
    pop r25 ; pop argument from stack, (well be using 24, which is why we store in 25)
    st Z+, r24 ; set Z to r24, then auto increment Z.


    dec r17; decrement num cols
    jmp col_loop

row_next:
    dec r16;
    jmp row_loop 

loop_done:
    pop r29
    pop r28
    pop r17
    pop r16
    ret

sumdown:
    push r28
    push r29
    in r28, 0X3D ; setting Y to SP (for using Y+...)
    in r29, 0x3E 

    ldd r24, Y+5 ; the value pushed in my r24 in element wise, which is c[row][column]
    cpi r24, 0 ;if r24 is 0 then return 0, but r24 is alr 0 if its 0 so we dont have to ldi it or anything
    breq sd_done

    mov r23, r24
    andi r23, 1 ;comparing it to 1, if odd number itll be 1, which means itll set Z flag as 0, if not then itll be 0 for Z flag
    brne sd_odd ; this is why we use brne here to route to sd_odd

sd_even:
    dec r24
    push r24
    call sumdown
    pop r25
    ldd r25, Y+5
    add r24, r25
    addi r24, 2
    jmp sd_done

sd_odd:
    dec r24
    push r24
    call sumdown
    pop r25
    ldd r25, Y+5
    add r24, r25
    inc r24

sd_done: 
    pop r29
    pop r28
    ret

.end