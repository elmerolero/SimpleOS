.section .text
main:
    bl      stack_Init
    bl      _start
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER | MU_RECEIVER)
    mov     r3, #MU_RECEIVE_INTERRUPT
    bl      uart0_Init

    bl      emmc_Init
 
    @ Send CMD0
    mov     r0, #0
    mov     r1, #0
    bl      emmc_CmdSend

    @ Sends CMD8
    mov     r0, #6
    mov     r2, #0x100
    mov     r1, #0x0AA
    orr     r1, r1, r2
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    bl      emmc_ResponseClear

    @ Sends ACMD55
1:
    mov     r0, #12
    mov     r1, #0
    bl      emmc_CmdSend

    @ Send an ACMD41
    mov     r0, #11
    mov     r1, #0x40000000
    orr     r1, #0xFF0000
    orr     r1, #0x8000
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    tst     r0, #0x80000000
    beq     1b

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Send CMD2
    mov     r0, #2
    mov     r1, #0
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    mov     r4, r1
    mov     r5, r2
    mov     r6, r3
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    mov     r0, r4
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    mov     r0, r5
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    mov     r0, r6
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD3
    mov     r0, #3
    mov     r1, #0
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    lsr     r4, r0, #16 
    lsr     r0, r0, #16
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD9
    mov     r0, #7
    lsl     r1, r4, #16
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    mov     r5, r0
    mov     r6, r1
    mov     r7, r2
    mov     r8, r3
    mov     r1, #2
    bl      utils_u32_write
    bl      next_line
    mov     r0, r6
    mov     r1, #2
    bl      utils_u32_write
    bl      next_line
    mov     r0, r7
    mov     r1, #2
    bl      utils_u32_write
    bl      next_line
    mov     r0, r8
    mov     r1, #2
    bl      utils_u32_write
    bl      next_line

    // Sends CMD7
    mov     r0, #5
    lsl     r1, r4, #16
    bl      emmc_CmdSend 
    bl      emmc_ResponseRead
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD13
2:
    mov     r0, #8
    lsl     r1, r4, #16
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    tst     r0, #0x800
    beq     2b

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r0, r5
    mov     r1, r6
    mov     r2, r7
    mov     r3, r8
    bl      sd_calculateSizeCsdV1
    mov     r4, r0
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r0, r4
    mov     r1, #2048
    bl      math_u32_divide
    mov     r4, r0
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    push { r0, r1, r2, r3 }
    mov     r0, #9
    mov     r1, #512
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    
    mov     r0, #512
    bl      emmc_BlockSizeWrite
    pop { r0, r1, r2, r3 }

    mov     r4, #0x800
    // Sends CMD17
3:
    mov     r0, #10
    mov     r1, r4
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    tst     r0, #0x40000000
    subne   r5, r5, #1
    bne     3b

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r0, r4
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    bl      emmc_DataRead
    
    mov     r0, #'A'
    bl      uart0_PutByte
    bl      next_line
loop:
    b       loop

next_line:
    push { lr }
    mov     r0, #'\r'
    bl      uart0_PutByte
    mov     r0, #'\n'
    bl      uart0_PutByte
    pop { pc }

baudrate_speed:
    .word 9600

.include "kernel/boot.s"
.include "devices/sd_format.s"
