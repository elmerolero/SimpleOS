.section .data
welcome_message: .asciz "Bienvenido a Simple OS\r"

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
    mov     r1, #23
    bl      uart0_Write

loop:
    b       loop

baudrate_speed:
    .word 9600

.include "kernel/boot.s"
