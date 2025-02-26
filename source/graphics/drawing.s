.include "graphics/font.s"
.extern utils_switchRegisters

.equ CANVAS_ADDRESS,    0x00
.equ CANVAS_WIDTH,      0x04
.equ CANVAS_HEIGHT,     0x08
.equ CANVAS_DEPTH,      0x0C
.equ CANVAS_PITCH,      0x10
.equ CANVAS_FOREGROUND, 0x14

.section .data
.align 4
canvas:
canvas_address: .word 0
canvas_width:   .word 0
canvas_height:  .word 0
canvas_depth:   .word 0
canvas_pitch:   .word 0
canvas_foreground_color:  .word 0

@ ------------------------------------------------------------------------------
@ Set canvas options
@ r0: Canvas address (u32)
@ r1: Canvas width (u32)
@ r2: Canvas height (u32)
@ r3: Canvas depth (u32)
@ ------------------------------------------------------------------------------
.section .text
.global canvas_options_write
canvas_options_write:
    push { r4, lr }
    ldr     r4, =canvas
    str     r0, [ r4, #CANVAS_ADDRESS ]
    str     r1, [ r4, #CANVAS_WIDTH ]
    str     r2, [ r4, #CANVAS_HEIGHT ]
    str     r3, [ r4, #CANVAS_DEPTH ]
    pop  { r4, pc }

@ ------------------------------------------------------------------------------
@ Set canvas' address
@ r0: Canvas address (u32)
@ ------------------------------------------------------------------------------
.global canvas_address_write
canvas_address_write:
    ldr     r1, =canvas_address
    str     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Getet canvas' address
@ Output
@ r0: Canvas address (u32)
@ ------------------------------------------------------------------------------
.global canvas_address_read
canvas_address_read:
    ldr     r1, =canvas_address
    ldr     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Set canvas' width
@ Input
@ r0: Canvas width
@ ------------------------------------------------------------------------------
.global canvas_width_write
canvas_width_write:
    ldr     r1, =canvas_width
    str     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Get canvas' address
@ Output
@ r0: Canvas address (u32)
@ ------------------------------------------------------------------------------
.global canvas_with_read
canvas_width_read:
    ldr     r1, =canvas_width
    ldr     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Set canvas' height
@ Input
@ r0: Canvas height
@ ------------------------------------------------------------------------------
.global canvas_height_write
canvas_height_write:
    ldr     r1, =canvas_height
    str     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Get canvas' height
@ Output
@ r0: Canvas height
@ ------------------------------------------------------------------------------
.global canvas_height_read
canvas_height_read:
    ldr     r1, =canvas_height
    ldr     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Set canvas' depth
@ Input
@ r0: Canvas depth
@ ------------------------------------------------------------------------------
.global canvas_depth_write
canvas_depth_write:
    ldr     r1, =canvas_depth
    str     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Get canvas' depth
@ Output
@ r0: Canvas depth
@ ------------------------------------------------------------------------------
.global canvas_depth_write
canvas_depth_read:
    ldr     r1, =canvas_depth
    ldr     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Set canvas' pitch or stride
@ Input
@ r0: Canvas stride
@ ------------------------------------------------------------------------------
.global canvas_pitch_write
canvas_pitch_write:
    ldr     r1, =canvas_pitch
    str     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Get canvas' pitch
@ Input
@ r0: Canvas pitch
@ ------------------------------------------------------------------------------
.global canvas_pitch_read
canvas_pitch_read:
    ldr     r1, =canvas_pitch
    ldr     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Set foreground color
@ Input
@ r0: Foreground color
@ ------------------------------------------------------------------------------
.global canvas_foreground_write
canvas_foreground_write:
    ldr     r1, =canvas_foreground_color
    str     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Gets foreground color
@ Output
@ r0: Foreground color
@ ------------------------------------------------------------------------------
.global canvas_foreground_read 
canvas_foreground_read:
    ldr     r1, =canvas_foreground_color
    ldr     r0, [ r1 ]
    bx      lr

@ ------------------------------------------------------------------------------
@ Put a pixel in the specified dimension 
@ R0: X position in canvas (u32)
@ R1: Y position in canvas (u32)
@ ------------------------------------------------------------------------------
.section .text
.global canvas_pixel_draw
canvas_pixel_draw:
    ldr     r2, =canvas
    ldr     r3, [ r2, #CANVAS_HEIGHT ]
    cmp     r1, r3
    bxhs    lr

    ldr     r3, [ r2, #CANVAS_WIDTH ]
    cmp     r0, r3
    bxhs    lr

    ldr     r2, [ r2 ]
    mla     r0, r1, r3, r0
    lsl     r0, #2

    ldr     r3, [ r3, #CANVAS_FOREGROUND ]
    str     r3, [ r2, r0 ]

    bx      lr

.section .text
canvas_drawLine:
push { r4, r5, r6, r7, r8, r9, r10, r11, r12, lr }

// Obtiene la dirección del framebuffer 
ldr     r4, =canvas_address
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
ldr    r4, =canvas_foreground_color
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

@ ------------------------------------------------------------------------------
@ Fills a rect
@ R0: X position in canvas (u32)
@ R1: Y position in canvas (u32)
@ r2: Rect's width (u32)
@ r3: Rect's height (u32)
@ ------------------------------------------------------------------------------
.section .text
.global canvas_fill_rect
canvas_fill_rect:
    push { r4 - r9, lr }
    ldr     r4, =canvas

    // Gets height and checks that (y + h) are not greather than 
    // screen height
    add     r5, r1, r3
    ldr     r6, [ r4, #CANVAS_HEIGHT ]
    cmp     r5, r6
    pophs { r4 - r9, pc }

    // Gets width and checks that (x + w) are not greather than
    // screen width
    add     r5, r0, r2
    ldr     r6, [ r4, #CANVAS_WIDTH ]
    cmpls   r5, r6
    pophs { r4 - r9, pc }

    // Gets foreground color and framebuffer address
    ldr     r9, [ r4, #CANVAS_FOREGROUND ]
    ldr     r4, [ r4 ]

1:
    mov     r7, r0      @ X position (incremented width times)
    mov     r8, r2      @ Width (decremented until is lower than zero)
2:
    // Gets (y * width + x) * b offset
    mla     r5, r1, r6, r7
    lsl     r5, #2
    str     r9, [ r4, r5 ]
    add     r7, r7, #1
    subs    r8, r8, #1
    bhs     2b
    add     r1, r1, #1
    subs    r3, r3, #1
    bhs     1b

    pop { r4 - r9, pc }

@ r0 - char
@ r1 - x
@ r2 - y
.section .text
.global canvas_char_draw
canvas_char_draw:
    cmp     r0, #0xFF
    bxhi    lr

    push { r4-r10, lr }

    ldr     r3, =canvas
    ldr     r5, [ r3, #CANVAS_HEIGHT ]
    add     r2, r2, #8
    cmp     r2, r5
    bhs     2f

    ldr     r5, [ r3, #CANVAS_WIDTH ]
    add     r1, r1, #5
    cmp     r1, r5
    bhs     2f

    // Reads canvas address
    ldr     r3, [ r3 ]
    
    // The letter to be drawn is multiplied by eight
    lsl     r0, r0, #3

    // Offset for (x, y) calculated in (y * screen_width + y) * bytes form
    sub     r2, r2, #8
    mla     r4, r2, r5, r1
    lsl     r4, r4, #2

    // Width * 4
    lsl     r5, r5, #2

    // Loads font and foreground color
    ldr     r7, =font
    ldr     r8, =canvas_foreground_color
    ldr     r8, [ r8 ]

    add     r0, r0, #4
    ldr     r6, [ r7, r0 ]
    lsr     r6, #24

    mov     r10, #1
    mov     r9, #8
1:
    tst     r6, #1
    strne   r8, [ r3, r4 ]
    lsr     r6, r6, #1
    add     r4, r4, r5
    subs    r9, #1
    bne     1b
    
    subs    r10, r10, #1
    subeq   r0, r0, #4
    ldreq   r6, [ r7, r0 ]

    sub     r4, r4, r5, lsl #3
    sub     r4, #4
    mov     r9, #8
    cmp     r6, #0
    movne   r9, #8
    bne     1b
2:
    pop { r4 - r10, pc }

@ ------------------------------------------------------------------------------
@ Show text through the screen
@ r0: Pointer to text shown
@ r1: Text size
@ r2: X position
@ r3: Y position
@ ------------------------------------------------------------------------------
.section .text
.global canvas_text_draw
canvas_text_draw:
    push { r4 - r8, lr }
    
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2
    mov     r7, r3
    mov     r8, r2
1:
    ldrb    r0, [r4], #1
    cmp     r0, #0
    beq     3f
    cmp     r5, #0
    blo     3f
    cmp     r0, #'\n'
    beq     2f
    cmp     r0, #'\r'
    subeq   r5, #1
    beq     1b
    mov     r1, r6
    mov     r2, r7
    bl      canvas_char_draw
    add     r6, r6, #5
    sub     r5, r5, #1
    b       1b
2:
    mov     r6, r8
    add     r7, #7
    sub     r5, #1
    b       1b
3:
    pop { r4 - r8, pc }
