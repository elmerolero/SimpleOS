.section .text
main:
    bl      stack_Init
    bl      _start
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER | MU_RECEIVER)
    mov     r3, #MU_RECEIVE_INTERRUPT
    bl      uart0_Init

    bl      dma_Disable
    bl      emmc_Init
 
    @ Send CMD0
    mov     r0, #0
    mov     r1, #0
    bl      emmc_SendCommand

    @ Sends CMD8
    mov     r0, #6
    mov     r2, #0x100
    mov     r1, #0x0AA
    orr     r1, r1, r2
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Sends ACMD55
1:
    mov     r0, #12
    mov     r1, #0
    bl      emmc_SendCommand

    @ Send an ACMD41
    mov     r0, #11
    mov     r1, #0x40000000
    orr     r1, #0xFF0000
    orr     r1, #0x8000
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    tst     r0, #0x80000000
    beq     1b

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Send CMD2
    mov     r0, #2
    mov     r1, #0
    bl      emmc_SendCommand
    bl      emmc_GetResponse
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
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    lsr     r0, r0, #16
    lsl     r0, r0, #16
    mov     r4, r0
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD9
    mov     r0, #7
    mov     r1, r4
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    mov     r5, r0
    mov     r6, r1
    mov     r7, r2
    mov     r8, r3
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    mov     r0, r6
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    mov     r0, r7
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    mov     r0, r8
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD7
    mov     r0, #5
    mov     r1, r4
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD13
2:
    mov     r0, #8
    mov     r1, r4
    bl      emmc_SendCommand
    bl      emmc_GetResponse
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
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    pop { r0, r1, r2, r3 }

    // Increases clock frequency
    bl      emmc_IncreaseClock

    mov     r0, #'A'
    bl      uart0_PutByte

    mov     r4, #0
    // Sends CMD17
3:
    mov     r0, #512
    mov     r1, #1
    bl      emmc_SetBlockSize
    
    mov     r0, #10
    mov     r1, r4
    bl      emmc_SendCommand
    bl      emmc_GetResponse
    tst     r0, #0x40000000
    bne     4f

    bl      emmc_GetData
    add     r4, r4, #512
    b       3b
    
4:
    mov     r0, #'B'
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
.include "devices/dma.s"
