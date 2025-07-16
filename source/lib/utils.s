.section .data
utils_Buffer: .skip 32

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

@ ------------------------------------------------------------------------------
@ Convert an unsigned int32 number to text and sends it through UART for unsigned 
@ int numbers. Supports 255 base
@ R0: Number to be sent
@ R1: Numerical base of the number
@ ------------------------------------------------------------------------------
.section .text
utils_u32_write:
    cmp     r1, #16
    bxhi    lr

    push { r4, r5, r6, lr }

    mov     r4, r0
    mov     r5, r1

    ldr     r6, =utils_Buffer
    mov     r0, #0x00
    strb    r0, [r6], #1

1:
    mov     r0, r4
    mov     r1, r5
    bl      math_u32_divide
    mov     r4, r0
    mov     r0, r1
    cmp     r0, #9
    addhi   r0, r0, #7
    add     r0, r0, #48
    push    { r0 }
    teq     r4, #0
    bne     1b
2:
    pop     { r0 }
    cmp     r0, #0x00
    blne    uart0_BlockingWrite
    bne     2b
    pop  { r4, r5, r6, pc }

@ ------------------------------------------------------------------------------
@ Convert a number to text and sends it through UART
@ It only works in base 10
@ R0: Number to be sent
@ ------------------------------------------------------------------------------
.section .text
utils_s32_write:
    push { r4, r5, r6, lr }
    mov     r4, r0
    cmp     r0, #0
    movlt   r0, #'-'
    bl      uart0_BlockingWrite
    
    ldr     r6, =utils_Buffer
    mov     r0, #0
    strb    r0, [r6], #1
1:
    mov     r0, r4
    mov     r1, #10
    bl      math_s32_divide
    mov     r4, r0
    mov     r0, r1
    bl      math_s32_abs
    add     r0, r0, #48
    and     r0, r0, #0xFF
    strb    r0, [r6], #1
    teq     r4, #0
    bne     1b
2:
    ldrb    r0, [r6, #-1]!
    cmp     r0, #0
    blne    uart0_BlockingWrite
    bne     2b
    pop  { r4, r5, r6, pc }
