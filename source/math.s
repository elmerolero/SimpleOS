.section .text
math_absi:
cmp     r0, #0
subls   r1, r0, r0
subls   r0, r1, r0
mov     pc, lr
