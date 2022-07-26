/* Sistema Operativo para Raspberry Pi */
.include "uart.s"
.include "frameBuffer.s"
.include "drawing.s"
.include "systemTimer.s"

/* Punto de Inicio */
.section .init
.global _start
_start:
    b   main

.section .text
.global main
main:
mov     sp, #0x8000

mov     r0, #800
mov     r1, #480
mov     r2, #16
bl      framebuffer_init

teq     r0, #0
beq     error

bl      canvas_setAddress
mov     r2, r0

ldr     r4, [ r2, #0x00 ]
ldr     r5, [ r2, #0x04 ]

ldr     r10, =#5000

ldrh r0, =#0xFFFF
bl  canvas_setForegroundColour

mov     r0, #0
mov     r1, #0
mov     r2, r4
mov     r3, r5
bl      canvas_fillRect

mov     r0, #0x0000
bl      canvas_setForegroundColour

render:

mov     r0, #0
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

b   render

error:
    mov     r0, #16
    mov     r1, #GPIO_OUTPUT
    bl      gpio_setMode
    cmp     r0, #-1
    beq     error
    ldr     r3, =GPIO_BASE
    mov     r4, #1                      @ Establece el pin 16 como salida
    lsl     r4, #16
    mov     r5, #1
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
    b       turn_off
/*
error:
    mov r1, #1                      @ Establece el pin 16 como salida
    lsl r1, #18
    str r1, [ r0, #GPIO_GPFSEL1 ]
    mov r1, #1                      @ Establece el pin 16 como salida
    lsl r1, #16
    str r1, [ r0, #GPIO_GPSET0 ]    @ Enciende el pin
error_loop:
    b error*/
