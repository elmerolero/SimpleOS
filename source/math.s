@ ------------------------------------------------------------------------------
@ Integer absolute in ARMv6
@ r0: value
@ Ouputs:
@ r0: absolute(value)
@ ------------------------------------------------------------------------------
.section .text
math_abs:
cmp     r0, #0
subls   r1, r0, r0
subls   r0, r1, r0
bx      lr

@ ------------------------------------------------------------------------------
@ Integer division in ARMv6
@ r0: dividend
@ r1: divisor
@ Ouputs:
@ r0: quotient
@ ------------------------------------------------------------------------------
.global math_unsigned_divide
math_unsigned_divide:         
    cmp     r1, #0           
    beq     math_unsigned_divide_error   // Handle division by 0

    mov     r3, r0
    mov     r0, #0
    cmp     r3, r1              // if dividend < divisor then
    bxlo    lr                  //     return

    push { r4 - r6, lr }

    mov     r2, #1
1:
    mov     r4, #0              // Set the lowest bit position (0)
2:
    lsl     r5, r1, r4
    sub     r6, r3, r5
    cmp     r6, r5              // Compare remainder with divisor << bit
    addhi   r4, r4, #1
    bhi     2b                  // If remainder <= divisor, increment bit position one position
    mov     r3, r6              // Subtract divisor << bit from remainder
    orr     r0, r0, r2, lsl r4  // Set the corresponding bit in the quotient
    cmp     r3, r1
    bhs     1b
    pop { r4 - r6, pc }                

math_unsigned_divide_error:
    mov r0, #0           // En caso de error, cociente = 0
    bx lr


@ ------------------------------------------------------------------------------
@ Integer division for remainder in ARMv6
@ Inputs
@ r0: dividend
@ r1: divisor
@ Ouputs:
@ r0: remainder
@ ------------------------------------------------------------------------------
.global math_unsigned_module
math_unsigned_module:         
    cmp     r1, #0           
    beq     math_unsigned_module_error   // Handle division by 0

    cmp     r0, r1              // if dividend < divisor then
    bxlo    lr                  //     return

    push { r4 - r6, lr }

    mov     r2, #1
1:
    mov     r4, #0              // Set the lowest bit position (0)
2:
    lsl     r5, r1, r4
    sub     r6, r0, r5
    cmp     r6, r5              // Compare remainder with divisor << bit
    addhi   r4, r4, #1
    bhi     2b                  // If remainder <= divisor, increment bit position one position
    mov     r0, r6              // Subtract divisor << bit from remainder
    cmp     r0, r1
    bhs     1b
    pop { r4 - r6, pc }                

math_unsigned_module_error:
    mov r0, #0           // En caso de error, cociente = 0
    bx lr
