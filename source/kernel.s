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

    bl      sdhost_Init

    mov     r0, #0
    mov     r1, #0
    bl      sdhost_SendCommand
    bl      uart0_PutByte
    bl      next_line

    mov     r0, #6
    mov     r1, #0xAA
    orr     r1, r1, #0x100
    bl      sdhost_SendCommand
    bl      uart0_PutByte
    bl      next_line
    bl      sdhost_GetResponse
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r0, #12
    mov     r1, #0
    bl      sdhost_SendCommand
    bl      uart0_PutByte
    bl      next_line
    bl      sdhost_GetResponse
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    /*bl      emmc_Init
 
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
    tst     r0, #0x80000000
    beq     1b

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Send CMD2
    mov     r0, #2
    mov     r1, #0
    bl      emmc_SendCommand

    // Sends CMD3
    mov     r0, #3
    mov     r1, #0
    bl      emmc_SendCommand
    lsr     r0, r0, #16
    lsl     r0, r0, #16
    mov     r4, r0
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r0, #8
    mov     r1, r4
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD7
    mov     r0, #5
    mov     r1, r4
    bl      emmc_SendCommand
    bl      emmc_IncreaseClock

    // Sends CMD13
2:
    mov     r0, #8
    mov     r1, r4
    bl      emmc_SendCommand
    mov     r5, r0
    mov     r1, #16
    bl      utils_u32_write
    tst     r5, #(1 << 8)
    beq     2b

    @ CMD16
    mov     r0, #9
    mov     r1, #512
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends ACMD55
    mov     r0, #12
    mov     r1, r4
    bl      emmc_SendCommand

    mov     r0, #'A'
    bl      uart0_PutByte
    bl      next_line

    @ Send an ACMD6
    mov     r0, #4
    mov     r1, #2
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    bl    emmc_IncreaseBandWidth
    
    mov     r0, #'B'
    bl      uart0_PutByte
    bl      next_line
4:
    // Sets the block size
    mov     r0, #512
    mov     r1, #1
    bl      emmc_SetBlockSize

    // Sends CMD17
    mov     r0, #10
    mov     r1, #0
    bl      emmc_SendCommand
    tst     r0, #0x800
    beq     5f

    mov     r0, #512
    bl      emmc_GetData
5:
    mov     r0, #'C'
    bl      uart0_PutByte
    bl      next_line

    // Sets the block size
    mov     r0, #512
    mov     r1, #1
    bl      emmc_SetBlockSize

    // Sends CMD17
    mov     r0, #10
    mov     r1, #0
    bl      emmc_SendCommand

    mov     r0, #512
    bl      emmc_GetData*/

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
.include "devices/sdhost.s"
