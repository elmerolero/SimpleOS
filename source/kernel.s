.section .text
main:
    mov     sp, #0xC000
    bl      _start
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER_ENABLE | MU_RECEIVER_ENABLE)
    mov     r3, #0
    bl      uart0_Init
    
loop:
    mov     r0, #1 
    bl      uart0_read
    cmp     r0, #13
    movne   r1, #1 
    blne    uart0_write
    bne     loop
    mov     r0, #'\r'
    mov     r1, #1 
    bl      uart0_write
    mov     r0, #'\n'
    mov     r1, #1 
    bl      uart0_write
    b       loop

baudrate_speed:
    .word 9600

.include "kernel/boot.s"
