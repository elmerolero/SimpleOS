.include "devices/mailbox_interface.s"

.extern uart_write_bytes

.equ FRAMEBUFFER_PHYSICAL_WIDTH,    0x00
.equ FRAMEBUFFER_PHYSICAL_HEIGHT,   0x04
.equ FRAMEBUFFER_VIRTUAL_WIDTH,     0x08
.equ FRAMEBUFFER_VIRTUAL_HEIGHT,    0x0C
.equ FRAMEBUFFER_PITCH,             0x10
.equ FRAMEBUFFER_DEPTH,             0x14
.equ FRAMEBUFFER_OFFSET_X,          0x18
.equ FRAMEBUFFER_OFFSET_Y,          0x1C
.equ FRAMEBUFFER_ADDRESS,           0x20
.equ FRAMEBUFFER_SIZE,              0x24

.section .data
.align 4
FrameBufferInfo:
.int 1024    /* 0x00 Anchura física */
.int 768    /* 0x04 Altura física */
.int 1024    /* 0x08 Anchura virtual */
.int 768    /* 0x0C Altura virtual */
.int 0      /* 0x10 GPU - Pitch */
.int 32     /* 0x14 Profundidad de bit */
.int 0      /* 0x18 Posición X respecto a la pantalla */
.int 0      /* 0x1C Posición Y respecto a la pantalla */
.int 0      /* 0x20 Apuntador hacia el framebuffer de la GPU */
.int 0      /* 0x24 Tamaño de GPU */

.align 4
RequestData:
.int 32                                 // Buffer size
.int 0                                  // Request
.int TAG_GET_PHYSICAL_SIZE              // Tag
.int 8                                  // Answer buffer size
.int 0                                  // Request code
.int 0                                  // Width (output)
.int 0                                  // Height (output)
.int 0                                  // End of message

.align 1
buffer_size_error: .ascii "Error retrieving tag property, size is not matching.\r\n"


.section .text
framebuffer_init:
    cmp     r0, #2048
	cmpls   r1, #2048
    cmpls   r2, #32
    movhi   r0, #0
    movhi   pc, lr

    push { lr }
    ldr     r3, =FrameBufferInfo
    str     r0, [ r3, #FRAMEBUFFER_PHYSICAL_WIDTH ]
    str     r1, [ r3, #FRAMEBUFFER_PHYSICAL_HEIGHT ]
    str     r0, [ r3, #FRAMEBUFFER_VIRTUAL_WIDTH ]
    str     r1, [ r3, #FRAMEBUFFER_VIRTUAL_HEIGHT ]
    str     r2, [ r3, #FRAMEBUFFER_DEPTH ]

    add     r0, r3, #0x40000000
    mov     r1, #1
    bl      mailbox_write

    mov     r0, #1
    bl      mailbox_read

    mov     r0, r3
    pop { pc } 

.section .text
framebuffer_get_dimmensions:
    push    { lr }

    // Dirección de RequestData para la GPU
    ldr     r2, =RequestData
    add     r0, r2, #0x40000000    // Dirección no cacheada
    mov     r1, #8                 // Canal del framebuffer
    bl      mailbox_write

    // Leer respuesta del Mailbox
    mov     r0, #8                 // Canal del framebuffer
    bl      mailbox_read

    // Validar tamaño de la respuesta
    ldr     r3, [r0, #12]          // Campo Answer buffer size
    cmp     r3, #8                 // Verificar si es igual a 8
    mov     r0, #-1
    bne     error                  // Si no, salida con error

    // Extraer dimensiones
    ldr     r2, =RequestData
    ldr     r0, [r2, #20]          // Width
    ldr     r1, [r2, #24]          // Height

    pop     { pc }                 // Regresar al llamador

error:
    cmp     r0, #-1
    ldreq     r0, =buffer_size_error
    moveq     r1, #54
    bleq      uart_write_bytes
    pop     { pc }
