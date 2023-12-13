/* Controlador base */
.equ TIMER_BASE,    0x20003000

/* Registros de control */
.equ TIMER_CS,      0x00
.equ TIMER_CLO,     0x04
.equ TIMER_CHI,     0x08
.equ TIMER_C0,      0x0C
.equ TIMER_C1,      0x10
.equ TIMER_C2,      0x14
.equ TIMER_C3,      0x18

@ -----------------------------------------------------------
@ Obtiene el tiempo transcurrido en el reloj del sistema
@ -----------------------------------------------------------
.section .text
timer_getTimeStamp:
    push { lr }
    ldr     r0, =TIMER_BASE
    ldrd    r0, r1, [ r0, #TIMER_CLO ]
    pop  { pc }


@ -----------------------------------------------------------
@ Espera la cantidad de tiempo indicada en micro-segundos
@ -----------------------------------------------------------
.section .text
timer_wait:
    push { r4, r5, lr }
    mov     r4, r0
    bl      timer_getTimeStamp
    mov     r5, r0
timer_waitLoop:
    bl      timer_getTimeStamp
    sub     r0, r5
    cmp     r0, r4
    bls     timer_waitLoop
    pop { r4, r5, pc }
