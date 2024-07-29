.include "utils.s"
.include "font.s"

.section .data
.align 4
foregroundColour:
.word 0x00000000

.align 4
canvasAddress:
.int 0

.section .text
canvas_setForegroundColour:
ldr     r1, =foregroundColour
str     r0, [ r1 ]
mov     pc, lr

.section .text
canvas_getForegroundColour:
ldr     r0, =foregroundColour
ldrh    r0, [ r0 ]
mov     pc, lr


.section .text
canvas_setAddress:
ldr     r1, =canvasAddress
str     r0, [ r1 ]
mov     pc, lr

.section .text
canvas_drawPixel:
ldr     r2, =canvasAddress
ldr     r2, [ r2 ]
ldr     r3, [ r2, #0x04 ]
cmp     r1, r3
movhs   pc, lr

ldr     r3, [ r2 ]
cmp     r0, r3
movhs   pc, lr

ldr     r2, [ r2, #0x20 ]
mla     r0, r1, r3, r0
add     r2, r0, lsl #1

ldr     r3, =foregroundColour
ldrh    r3, [ r3 ]
strh    r3, [ r2 ]

mov     pc, lr

.section .text
canvas_drawLine:
push { r4, r5, r6, r7, r8, r9, r10, r11, r12, lr }

// Obtiene la dirección del framebuffer 
ldr     r4, =canvasAddress
ldr     r4, [ r4 ]

// Carga la altura de la pantalla y valida que y1 e y2 no sean mayores que la misma 
ldr     r5, [ r4, #0x04 ]                       
cmp     r1, r5
cmpmi   r3, r5
pophs  { r4, r5, r6, r7, r8, r9, r10, r11, r12, pc }

// Carga la anchura de la pantalla y valida que x1 y x2 no sean mayores que la misma 
ldr     r5, [ r4 ]
cmp     r0, r5
cmpmi   r2, r5
pophs  { r4, r5, r6, r7, r8, r9, r10, r11, r12, pc }

// Respalda la anchura de la pantalla
mov     r6, r5

// Obtiene el desplazamiento de x1, y1
ldr     r11, [ r4, #0x20 ]
mov     r12, r11
mla     r5, r1, r6, r0
add     r11, r5, lsl #1

// Obtiene el desplazamiento de x2, y2 
mla     r5, r3, r6, r2
add     r12, r5, lsl #1

// Obtiene |dx| (r6)
subs    r6, r2, r0
submi   r7, r6, r6
submi   r6, r7, r6

// Obtiene |dy| (r7)
subs    r7, r3, r1
submi   r8, r7, r7
submi   r7, r8, r7

// Compara dx y dy
cmp     r6, r7

// Intercambia x1 e y1 si dx < dy
movmi   r5, #1
movhs   r5, #0
eormi   r0, r0, r1
eormi   r1, r1, r0
eormi   r0, r0, r1     

// Intercambia x2 e y2 si dx < dy 
eormi   r2, r2, r3
eormi   r3, r3, r2
eormi   r2, r2, r3

// Intercambia dx y dy si dx < dy
eormi   r6, r6, r7
eormi   r7, r7, r6
eormi   r6, r6, r7 

eormi   r11, r11, r12
eormi   r12, r12, r11
eormi   r11, r11, r12 

// Obtiene n2dydx (r8)
sub     r8, r7, r6
lsl     r8, #1

// Obtiene d(r9) 
add     r9, r7, #2
sub     r9, r6

// Obtiene n2dy (r7) 
lsl     r7, #1

// Obtiene el ancho de la pantalla (r1)
ldr     r4, [ r4 ]

// Obtiene el desplazamiento en x (r0)
cmp     r2, r0
mov     r0, #1
movls   r0, #-1

// Obtiene el desplazamiento en y (r1)
cmp     r3, r1
mov     r1, #1
movls   r1, #-1

cmp     r5, #0
bne     canvas_drawLineCaseB

canvas_drawLineCaseA:
mul   r1, r4, r1
lsl   r1, #1
lsl   r0, #1
b     canvas_drawLineCaseEnd

canvas_drawLineCaseB:
mul   r0, r4, r0
lsl   r0, #1
lsl   r1, #1

canvas_drawLineCaseEnd:
ldr    r4, =foregroundColour
ldrh   r4, [ r4 ]

canvas_drawLineLoop:
    cmp     r11, r12
    beq     canvas_drawLineEnd
        cmp     r9, #0
        addlt   r9, r7

        addge   r11, r1
        addge   r9, r8  
        strh    r4, [ r11 ]
        add     r11, r0
        b canvas_drawLineLoop

canvas_drawLineEnd:
pop  { r4, r5, r6, r7, r8, r9, r10, r11, r12, pc }

.section .text
canvas_fillRect:
push { r4, r5, r6, r7, lr }
ldr     r4, =canvasAddress
ldr     r4, [ r4 ]

// Obtiene x + w
add     r6, r0, r2

// Obtiene y + h
add     r7, r1, r3

// Obtiene la altura y valida que y e (y + h) sean mayores que la altura de 
// la pantalla
ldr     r5, [ r4, #0x04 ]
cmp     r1, r5
cmpls   r7, r5
pophi { r4, r5, r6, r7, pc }

// Obtiene la base y valida que x e (x + w) sean mayores que la base de 
// la pantalla
ldr     r5, [ r4 ]
cmp     r0, r4
cmpls   r6, r5
pophi { r4, r5, r6, r7, pc }


// Obtiene el despazamiento de (x, y) y se posiciona
ldr     r4, [ r4, #0x20 ]
mla     r0, r5, r1, r0
add     r0, r4, r0, lsl #2

// Obtiene el desplazamiento de x + w, y + h
mla     r1, r5, r7, r6
add     r1, r4, r1, lsl #2

// Carga el color
ldr     r4, =foregroundColour
ldr     r4, [ r4 ]

// Obtiene el desplazamiento de anchoPantalla - w
sub     r3, r5, r2
lsl     r3, #2

// Reserva el desplazamiento que delimita el ancho del rectángulo a dibujar
lsl     r2, #2

// Límite del renglon
mov     r5, r0

// Carga el color
ldr     r4, =foregroundColour
ldr     r4, [ r4 ]

strh    r4, [ r0 ]
strh    r4, [ r1 ]

// Mientras desplazamiento (x, y) < desplazamiento (x+w, x+h)
canvas_fillRectLoop:
cmp     r0, r1
bhi     canvas_fillRectEnd

// Agrega el desplazamiento
add     r5, r2
    canvas_fillRectFill:
        cmp     r0, r5
        bhi     canvas_fillRectFillEnd
        str     r4, [ r0 ], #2
        b       canvas_fillRectFill
    canvas_fillRectFillEnd:
add     r0, r3
add     r5, r3
b canvas_fillRectLoop

canvas_fillRectEnd:
pop { r4, r5, r6, r7, pc }

@ r0 - char
@ r1 - x
@ r2 - y
.section .text
canvas_drawChar:
    stmfd   sp!, { r4-r9, lr }

    cmp     r0, #0xFF
    bhi     2f

    ldr     r3, =canvasAddress
    ldr     r3, [ r3 ]
    ldr     r4, [ r3, #0x04 ]
    cmp     r2, r4
    bhs     2f

    ldr     r4, [ r3 ]
    add     r1, #5
    cmp     r1, r4
    bhs     2f

    mla     r5, r2, r4, r1
    ldr     r3, [ r3, #0x20 ]
    add     r3, r5, lsl #2
    mov     r1, r4, lsl #2

    ldr     r2, =font
    mov     r4, #4
    add     r0, r4, r0, lsl #3
    ldr     r5, [r2, r0]
    ldr     r7, =foregroundColour
    ldr     r7, [ r7 ]
    lsr     r5, #24
    mov     r8, #6
    mov     r9, r3
    mov     r6, #1
  
1:
    tst     r5, #1
    strne   r7, [ r9 ]
    add     r9, r1
    lsr     r5, #1
    subs    r8, #1
    bne     1b
    sub     r3, #4
    mov     r9, r3
    mov     r8, #8
    subs    r6, #1
    bne     1b
    mov     r6, #0x04
    sub     r0, r4
    cmp     r4, #0
    subne   r4, #4
    ldrne   r5, [r2, r0]
    bne     1b
2:
    pop { r4, r5, r6, r7, r8, r9, pc }


.text
canvas_drawText:
    push { r4, r5, r6, lr }
    
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2
1:
    ldrb    r0, [r4], #1
    tst     r0, #0xFF
    beq     2f
    mov     r1, r5
    mov     r2, r6
    bl      canvas_drawChar
    add     r5, #7
    b       1b
2:
    pop { r4, r5, r6, lr }
