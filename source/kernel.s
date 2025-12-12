.section .data
welcome_message: .asciz "Bienvenido a Simple OS\r\n"

.section .text
main:
    bl      stack_Init
    bl      _start
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER | MU_RECEIVER)
    mov     r3, #MU_RECEIVE_INTERRUPT
    bl      uart0_Init

    ldr     r0, =welcome_message
    mov     r1, #24
    bl      uart0_Write

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
    mov     r0, #8
    mov     r1, #0
    bl      emmc_CmdSend

    @ Send an ACMD41
    mov     r0, #7
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
    mov     r0, #0
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

    //
    mov     r0, #3
    mov     r1, #0
    bl      emmc_CmdSend
    bl      emmc_ResponseRead
    mov     r1, #16
    bl      utils_u32_write
    
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
