.section .text
main:
    bl      stack_Init
    bl      _start
    ldr     r0, baudrate_speed
    mov     r1, #MU_DATA_SIZE_8
    mov     r2, #(MU_TRANSMITER_ENABLE | MU_RECEIVER_ENABLE)
    mov     r3, #0
    bl      uart0_Init
    
loop:
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
