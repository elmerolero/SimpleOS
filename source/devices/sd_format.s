.include "devices/sd_format.inc"

.section .text
.align 4
sd_calculateSizeCsdV1:
    push { r4, r5, r6, r7, lr }
    // BLOCK_LEN 2^READ_BL_LEN
    lsr     r4, r2, #16
    and     r4, r4, #0xF
    mov     r5, #1
    lsl     r4, r5, r4
    
    // MULT 2^(C_SIZE_MULT + 2)
    lsr     r5, r1, #15
    and     r5, #0x7
    add     r5, r5, #2
    mov     r6, #1
    lsl     r5, r6, r5

    // BLOCKNR (C_SIZE + 1) * MULT
    lsl     r6, r2, #22
    lsr     r6, r6, #20
    orr     r6, r6, r1, lsr #30

    mul     r0, r4, r5
    mul     r0, r0, r6

    pop { r4, r5, r6, r7, pc }
    