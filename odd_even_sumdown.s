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

asm_function:
ldi r16, lo8(a)
push r16
ldi r16, hi8(a)
push r16

lds r16, num_rows
push r16

lds r16, num_cols
push r16

call elementwise
pop 0
pop 0
pop 0
pop 0
pop 0
pop 0
ret

elementwise:
push r28
push r29
in r28, 0x3d
in r29, 0x3e

ldd r26, Y+10
ldd r27, Y+9

sumdown:
