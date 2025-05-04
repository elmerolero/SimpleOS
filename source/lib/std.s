
u32_string:
    cmp     r1, #0x10
    bxhi    lr

    push { r4, r5, r6, r7, lr }
    
    mov     r4, r0
    mov     r5, r1

    // Find max power of base and save it in r6
    mov     r2, r1
1:
    mul     r2, r1, r1
    cmp     r2, r0
    movls   r1, r2
    bls     1b
    mov     r6, r1
2:
    bl      math_u32_divide
    
    // Convert result into ascii character
    cmp     r0, #9
    addhi   r0, r0, #7
    add     r0, r0, #48
    // TODO Add sending byte or write in specified buffer here

    // Backs up reminder
    mov     r4, r1

    // Decrements base
    mov     r0, r6
    mov     r1, r5
    bl      math_u32_divide
    mov     r1, r0
    mov     r6, r0
    mov     r0, r4
    cmp     r6, r5
    bhs     2b

    pop  { r4, r5, r6, r7, pc }
