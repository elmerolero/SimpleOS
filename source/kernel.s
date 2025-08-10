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

    bl      uart0_PutByte

loop:
    b       loop

baudrate_speed:
    .word 9600

.include "kernel/boot.s"
