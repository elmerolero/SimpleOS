@ ------------------------------------------------------------------------------
@ Switch values among registers
@ R0: First value
@ R1: Second value
@ ------------------------------------------------------------------------------
.section .text
.global utils_switchRegisters
utils_switchRegisters:
eor     r0, r0, r1
eor     r1, r1, r0
eor     r0, r0, r1
mov     pc, lr

@ ------------------------------------------------------------------------------
@ Waits the number of cycles specified in R0
@ R0: Number of cycles
@ ------------------------------------------------------------------------------
.section .text
.global utils_delay
utils_delay:
1:
    subs    r0, #1
    bne     1b
    bx      lr
