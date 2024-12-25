.section .text
math_abs:
cmp     r0, #0
subls   r1, r0, r0
subls   r0, r1, r0
bx      lr

// Integer Division in ARMv6
// Inputs:
//   r0 = dividend (numerator)
//   r1 = divisor (denominator)
// Outputs:
//   r0 = quotient
.global math_unsigned_divide
math_unsigned_divide:         
    cmp     r1, #0           
    beq     math_divide_error   // Handle division by 0

    mov     r3, r0
    mov     r0, #0
    cmp     r3, r1              // if dividend < divisor then
    bxlt    lr                  //     return

    push { r4, lr }

    mov     r2, #1
1:
    mov     r4, #0              // Set the lowest bit position (0)
2:         
    cmp     r3, r1, lsl r4      // Compare remainder with divisor << bit
    addhi   r4, r4, #1
    bhi     2b                  // If remainder <= divisor, increment bit position one position
    cmp     r4, #0
    subhi   r4, r4, #1          
    sub     r3, r3, r1, lsl r4  // Subtract divisor << bit from remainder
    orr     r0, r0, r2, lsl r4  // Set the corresponding bit in the quotient
    cmp     r3, r1
    bhi     1b
    pop { r4, pc }                

math_divide_error:
    mov r0, #0           // En caso de error, cociente = 0
    bx lr

// Integer division for remainder in ARMv6
// Inputs:
//   r0 = dividend (numerator)
//   r1 = divisor (denominator)
// Outputs:
//   r0 = quotient
.global math_unsigned_module
math_unsigned_module:
    cmp     r1, #0           
    beq     math_module_error   // Handle division by 0

    cmp     r0, r1              // if dividend < divisor then
    bxlt    lr                  //     return

    push { lr }

    mov     r2, #1
1:
    mov     r3, #0              // Set the lowest bit position (0)
2:
    add     r3, r3, #1            
    cmp     r0, r1, lsl r3      // Compare remainder with divisor << bit
    bgt     2b                  // If remainder <= divisor, increment bit position one position
    subs    r3, r3, #1          
    sub     r0, r0, r1, lsl r3  // Subtract divisor << bit from remainder
    cmp     r0, r1
    bge     1b
    pop { pc }                

math_module_error:
    mov r0, #0           // En caso de error, cociente = 0
    mov r1, #0           // En caso de error, residuo = 0
    bx lr
