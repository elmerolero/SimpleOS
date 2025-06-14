
@ ------------------------------------------------------------------------------
@ Sets an u8 value into a range of bytes defined by pointer and size
@ r0: Pointer to start address
@ r1: Value
@ r2: Length (number of bytes)
@ ------------------------------------------------------------------------------
.section .text
memset:
    push { r4, r5, r6, r7, r8, r9, r10, r11, lr }

    // Back up r0 and r1 and r2
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2

    //
    mov     r0, r2
    mov     r1, #32     // Number of 32 blocks
    bl      math_u32_divide

    and     r1, r1, #0xFF         @ Make sure that it is an 8 bits value
    orr     r3, r1, r1, LSL #8    @ r3 = 0x0000VVVV
    orr     r3, r3, r3, LSL #16   @ r3 = 0xVVVVVVVV

    mov     r4, r3
    mov     r5, r3
    mov     r6, r3
    mov     r7, r3
    mov     r8, r3
    mov     r9, r3
    mov     r10, r3
    mov     r11, r3

    mov     r12, #32
    udiv    r12, r2, r12          @ r12 = número de bloques de 32 bytes
    cbz     r12, .tail

    pop { r4, r5, r6, r7, r8, r9, r10, r11, lr }


@ ------------------------------------------------------------------------------
@ Sets an u8 value into a range of bytes defined by pointer and size
@ r0: Pointer to start address
@ r1: Value
@ r2: Length (number of bytes)
@ ------------------------------------------------------------------------------
.section .text
memset_safe:
    and     r1, r1, #0xFF
    subs    r2, #-1
    bxlt    lr   
    strb    r1, [ r0, r2 ]
    b       memset_safe
