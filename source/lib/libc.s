@ ------------------------------------------------------------------------------
@ Sets an u8 value into a range of bytes defined by pointer and size
@ r0: Pointer to start address
@ r1: Value
@ r2: Length (number of bytes)
@ ------------------------------------------------------------------------------
.section .text
memset:
    push { r4, r5, r6, r7, r8, r9, r10, r11, r12, lr }

    // Back up r0 and r1
    mov     r4, r0
    mov     r5, r1

    //
    mov     r0, r2
    mov     r1, #32     // Number of 32 blocks
    bl      math_u32_divide

    mov     r2, r0 // Number of blocks
    mov     r3, r1 // Missing bytes
    mov     r0, r4 // Restore pointer

    and     r5, r5, #0xFF         @ Make sure that it is an 8 bits value
    orr     r5, r5, r5, LSL #8    @ r4 = 0x0000VVVV
    orr     r5, r5, r5, LSL #16   @ r4 = 0xVVVVVVVV
    mov     r6, r5
    mov     r7, r5
    mov     r8, r5
    mov     r9, r5
    mov     r10, r5
    mov     r11, r5
    mov     r12, r5

    // Checks for blocks to move
    cmp     r2, #0
    beq     2f

    // Loop to copy 32 bytes blocks
1:
    stmia   r4!, {r5-r12}
    subs    r2, r2, #1
    bne     1b

    // Loop to copy missing blocks
    cmp     r3, #0
    beq     3f
2:
    strb    r5, [r4], #1
    subs    r3, r3, #1
    bne     2b
3:
    pop { r4, r5, r6, r7, r8, r9, r10, r11, r12, pc }


@ ------------------------------------------------------------------------------
@ Sets an u8 value into a range of bytes defined by pointer and size
@ r0: Pointer to start address
@ r1: Value
@ r2: Length (number of bytes)
@ ------------------------------------------------------------------------------
.section .text
memset_safe:
    and     r1, r1, #0xFF
    subs    r2, r2, #1
    bxlt    lr   
    strb    r1, [ r0, r2 ]
    b       memset_safe

@ ------------------------------------------------------------------------------
@ Copies a group of bytes from one destination to another
@ r0: Pointer to destination address
@ r1: Pointer to source address
@ r2: Length (number of bytes)
@ ------------------------------------------------------------------------------
.section .text
memcpy_safe:
    subs    r2, r2, #1
    bxlt    lr
    ldrb    r3, [ r1, r2 ]
    strb    r3, [ r0, r2 ]
    b       memcpy_safe
