.section .text
utils_switchRegisters:
eor     r0, r0, r1
eor     r1, r1, r0
eor     r0, r0, r1
mov     pc, lr
