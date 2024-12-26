/* Sistema Operativo para Raspberry Pi */
.include "frameBuffer.s"
.include "drawing.s"
.include "systemTimer.s"

.extern uart_writeText
.extern uart_writeByte

.data
.align 1
welcome_message: .ascii "Bienvenido a Mini+ OS\r\n"
screen_width: .ascii "Ancho de pantalla: "
screen_height: .ascii "Alto de pantalla: "
endl: .ascii "\r\n"

.align 4
array:
    .word 1024
    .word 766

/* Punto de Inicio */
.section .init
.global _start
_start:
    b   main

.section .text
.global main
main:
    ldr     sp, =0x8000
    ldr     r0, =#96153
    mov     r1, #0x03
    bl      uart_init

    ldr     r0, =welcome_message
    mov     r1, #23
    bl      uart_writeText
    
    ldr     r2, =array
    str     r0, [r2]
    str     r1, [r2, #4]

    ldr     r4, =array
    ldr     r5, =screen_width
    ldr     r6, =screen_height
    ldr     r7, =endl
    mov     r0, r5
    mov     r1, #19
    bl      uart_writeText
    ldr     r0, [r4]
    bl      uart_writeNumber
    mov     r0, r7
    mov     r1, #2
    bl      uart_writeText

    mov     r0, r6
    mov     r1, #18
    bl      uart_writeText
    ldr     r0, [r4, #4]
    bl      uart_writeNumber
    mov     r0, r7
    mov     r1, #2
    bl      uart_writeText
loop:
    bl      uart_readByte
    cmp     r0, #13
    blne    uart_writeByte
    bne     loop
    mov     r0, r7
    mov     r1, #2
    bl      uart_writeText
    b       loop

/*.section .text
.global main
main:
mov     sp, #0x8000

mov     r0, #800
mov     r1, #480
mov     r2, #32
bl      framebuffer_init

teq     r0, #-1
beq     error

bl      canvas_setAddress
mov     r2, r0

ldr     r4, [ r2, #0x00 ]
ldr     r5, [ r2, #0x04 ]

ldr     r10, =#5000

ldr  r0, =#0xFFFFFFFF
bl  canvas_setForegroundColour

mov     r0, #0
mov     r1, #0
mov     r2, r4
mov     r3, r5
bl      canvas_fillRect

mov     r0, #0x00000000
bl      canvas_setForegroundColour

mov     r4, #0
mov     r5, #1
mov     r6, #800

render:
    ldr     r0, =text
    mov     r1, #0
    mov     r2, #0
    bl      canvas_drawText
    b       render*/

    /*mov     r0, #0
    mov     r1, #0
    mov     r2, #624
    mov     r3, #400
    bl      canvas_drawLine
    mov     r0, #0
    mov     r1, #200
    mov     r2, #624
    mov     r3, #200
    bl      canvas_drawLine
    mov     r0, #0
    mov     r1, #200
    mov     r2, #624
    mov     r3, #0
    bl      canvas_drawLine
    mov     r0, #312
    mov     r1, #0
    mov     r2, #312
    mov     r3, #400
    bl      canvas_drawLine

b   render*/
/*
error:
    mov     r0, #16
    mov     r1, #GPIO_OUTPUT
    bl      gpio_setMode
    cmp     r0, #-1
    beq     error
    ldr     r3, =GPIO_BASE
    mov     r4, #1                      @ Establece el pin 16 como salida
    lsl     r4, #16
    mov     r5, #1*/
/* 
turn_off: 
    str     r4, [ r3, #GPIO_GPCLR0 ]    @ Apaga el pin
    b       loop

turn_on:            
    str     r4, [ r3, #GPIO_GPSET0 ]    @ Enciende el pin
/* 
loop:
    ldr     r0, =2000000
    bl      timer_wait
    cmp     r5, #1
    moveq   r5, #0
    beq     turn_on
    mov     r5, #1
    b       turn_off*/

/*error:
    mov r1, #1                      @ Establece el pin 16 como salida
    lsl r1, #18
    str r1, [ r0, #GPIO_GPFSEL1 ]
    mov r1, #1                      @ Establece el pin 16 como salida
    lsl r1, #16
    str r1, [ r0, #GPIO_GPSET0 ]    @ Enciende el pin
error_loop:
    b error*/
