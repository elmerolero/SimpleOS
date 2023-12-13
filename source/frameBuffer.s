.include "mailbox.s"

.section .data
.align 12
FrameBufferInfo:
.int 800    /* 0x00 Anchura física */
.int 480    /* 0x04 Altura física */
.int 800    /* 0x08 Anchura virtual */
.int 480    /* 0x0C Altura virtual */
.int 0      /* 0x10 GPU - Pitch */
.int 32     /* 0x14 Profundidad de bit */
.int 0      /* 0x18 Posición X respecto a la pantalla */
.int 0      /* 0x1C Posición Y respecto a la pantalla */
.int 0      /* 0x20 Apuntador hacia el framebuffer de la GPU */
.int 0      /* 0x24 Tamaño de GPU */

.section .text
framebuffer_init:
    cmp     r0, #2048
	cmpls   r1, #2048
    cmpls   r2, #32
    movhi   r0, #0
    movhi   pc, lr

    push { r4, lr }
    ldr     r4, =FrameBufferInfo
    str     r0, [ r4, #0x00 ]
    str     r1, [ r4, #0x04 ]
    str     r0, [ r4, #0x08 ]
    str     r1, [ r4, #0x0C ]
    str     r2, [ r4, #0x14 ]

    add     r0, r4, #0x40000000
    mov     r1, #1
    bl      mailbox_write

    mov     r0, #1
    bl      mailbox_read

    teq     r0, #0
    movne   r0, #0
    popne { r4, pc }

    mov     r0, r4
    pop { r4, pc } 
