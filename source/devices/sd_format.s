.include "devices/sd_format.inc"

.section .text
.align 4
sd_calculateSizeCsdV1:
    push { r4, r5, r6, r7, lr }
    and     r4, r2, #READ_BL_LEN_V1
    lsr     r1, #20
    
    and     r5, r1, #C_SIZE_PART1_V1
    lsl     r6, r1, #12
    lsr     r6, #10
    orr     r5, r6, r5, lsr #30

    and     r6, r1, #C_SIZE_MULT_V1
    lsr     r0, r6, #15
    pop { r4, r5, r6, r7, pc }
    