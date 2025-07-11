.section .text
main:
    bl      stack_Init
    bl      _start
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER | MU_RECEIVER)
    mov     r3, #(MU_RECEIVE_INTERRUPT)
    bl      uart0_Init
    
loop:
    b       loop
    mov     r0, #1 
    bl      uart0_Read
    cmp     r0, #13
    movne   r1, #1 
    blne    uart0_Write
    bne     loop
    mov     r0, #'\r'
    mov     r1, #1 
    bl      uart0_Write
    mov     r0, #'\n'
    mov     r1, #1 
    bl      uart0_Write
    b       loop

baudrate_speed:
    .word 9600

.include "kernel/boot.s"
