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

    // CMD8
    mov     r0, #6
    mov     r1, #0xAA
    orr     r1, r1, #0x100
    bl      sdhost_SendCommand
    bl      uart0_PutByte
    mov     r0, #'-'
    bl      uart0_PutByte
    bl      sdhost_GetResponse
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // CMD55
1:
    mov     r0, #12
    mov     r1, #0
    bl      sdhost_SendCommand
    bl      uart0_PutByte
    mov     r0, #'-'
    bl      uart0_PutByte
    bl      sdhost_GetResponse
    tst     r0, #(1 << 5)
    moveq   r0, #'E'
    bleq    uart0_PutByte
    beq     loop

    // ACMD41
    mov     r0, #11
    mov     r1, #0x40000000
    orr     r1, #0xFF0000
    orr     r1, #0x8000
    bl      sdhost_SendCommand
    mov     r0, #'-'
    bl      uart0_PutByte
    bl      sdhost_GetResponse
    tst     r4, #0x80000000
    beq     1b
    mov     r4, r0
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Send CMD2
    mov     r0, #2
    mov     r1, #0
    bl      emmc_SendCommand
    bl      sdhost_GetResponse
    mov     r1, #16
    bl      utils_u32_write
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
.include "devices/sdhost.s"
