@ ------------------------------------------------------------------------------
@ Integer absolute in ARMv6
@ r0: value
@ Ouputs:
@ r0: absolute(value)
@ ------------------------------------------------------------------------------
.section .text
.global math_s32_abs
math_s32_abs:
cmp     r0, #0
sublt   r1, r0, r0
sublt   r0, r1, r0
bx      lr

@ ------------------------------------------------------------------------------
@ Integer division in ARMv6
@ r0: dividend
@ r1: divisor
@ Ouputs:
@ r0: quotient
@ r1: remainder (optional)
@ ------------------------------------------------------------------------------
.global math_u32_divide
math_u32_divide:         
    cmp     r1, #0           
    beq     math_u32_divide_error   // Handle division by 0

    mov     r3, r0
    mov     r0, #0
    cmp     r3, r1              // if dividend < divisor then
    movlo   r1, r3              
    bxlo    lr                  // If true, return (quotient = 0, remainder = dividend)

    push { r4, r5, r6, lr }

    mov     r2, #1
1:
    mov     r4, #0              // Set the lowest bit position (0)
2:
    lsl     r5, r1, r4
    sub     r6, r3, r5
    cmp     r6, r5              // Compare remainder with divisor << bit
    addhs   r4, r4, #1
    bhs     2b                  // If remainder <= divisor, increment bit position one position
    mov     r3, r6              // Subtract divisor << bit from remainder
    orr     r0, r0, r2, lsl r4  // Set the corresponding bit in the quotient
    cmp     r3, r1
    bhs     1b
    mov     r1, r3
    pop { r4, r5, r6, pc }                

math_u32_divide_error:
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
.global math_u32_module
math_u32_module:         
    cmp     r1, #0           
    beq     math_u32_module_error   // Handle division by 0

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

math_u32_module_error:
    mov r0, #0           // En caso de error, cociente = 0
    bx lr


@ ------------------------------------------------------------------------------
@ Signed integer division (APCS compliant)
@ Inputs:
@   r0 = dividend
@   r1 = divisor
@ Outputs:
@   r0 = quotient
@   r1 = remainder
@ Clobbers:
@   r2, r3, r4 (caller-saved)
@ ------------------------------------------------------------------------------
.section .text
.global math_s32_divide
math_s32_divide:
    push    {r4, lr}               @ Save callee-saved registers and return address

    cmp     r1, #0                 @ Check if divisor is zero
    beq     math_s32_divide_error  @ Handle division by zero

    mov     r3, r0, asr #31        @ Get sign of dividend (-1 if negative, 0 if positive)
    eor     r4, r0, r3             @ Absolute value of dividend: dividend ^ sign
    sub     r4, r4, r3             @ Adjust to absolute value: abs(dividend)

    mov     r2, r1, asr #31        @ Get sign of divisor (-1 if negative, 0 if positive)
    eor     r3, r1, r2             @ Absolute value of divisor: divisor ^ sign
    sub     r3, r3, r2             @ Adjust to absolute value: abs(divisor)

    mov     r0, r4                 @ Move absolute dividend to r0
    mov     r1, r3                 @ Move absolute divisor to r1

    bl      math_u32_divide        @ Perform unsigned division (quotient in r0, remainder in r1)

    eor     r2, r0, r4, asr #31    @ Determine if quotient should be negative
    rsbmi   r0, r0, #0             @ If negative, negate quotient

    eor     r2, r1, r4, asr #31    @ Adjust remainder sign to match dividend
    rsbmi   r1, r1, #0             @ If negative, negate remainder

    pop     {r4, pc}               @ Restore callee-saved registers and return

math_s32_divide_error:
    mov     r0, #0                 @ On division by zero, quotient = 0
    mov     r1, #0                 @ remainder = 0
    pop     {r4, pc}               @ Restore callee-saved registers and return

@ ------------------------------------------------------------------------------
@ Signed integer remainder (APCS compliant)
@ Inputs:
@   r0 = dividend
@   r1 = divisor
@ Outputs:
@   r0 = remainder
@ Clobbers:
@   r2, r3, r4 (caller-saved)
@ ------------------------------------------------------------------------------
.global math_s32_module
math_s32_module:
    push    {r4, lr}               @ Save callee-saved registers and return address

    cmp     r1, #0                 @ Check if divisor is zero
    beq     math_s32_module_error @ Handle division by zero

    mov     r3, r0, asr #31        @ Get sign of dividend (-1 if negative, 0 if positive)
    eor     r4, r0, r3             @ Absolute value of dividend: dividend ^ sign
    sub     r4, r4, r3             @ Adjust to absolute value: abs(dividend)

    mov     r2, r1, asr #31        @ Get sign of divisor (-1 if negative, 0 if positive)
    eor     r3, r1, r2             @ Absolute value of divisor: divisor ^ sign
    sub     r3, r3, r2             @ Adjust to absolute value: abs(divisor)

    mov     r0, r4                 @ Move absolute dividend to r0
    mov     r1, r3                 @ Move absolute divisor to r1

    bl      math_u32_divide        @ Perform unsigned division (r1 now contains the unsigned remainder)

    mov     r2, r0, asr #31        @ Get original sign of dividend
    eor     r0, r1, r2             @ Adjust remainder to match dividend's sign
    submi   r0, r1, #0             @ If negative, negate remainder

    pop     {r4, pc}               @ Restore callee-saved registers and return

math_s32_module_error:
    mov     r0, #0                 @ On division by zero, remainder = 0
    pop     {r4, pc}               @ Restore callee-saved registers and return
