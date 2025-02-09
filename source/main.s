/* Operating System for Raspberry Pi */
.include "lib/utils.s"
.include "lib/math.s"
.include "devices/gpio.s"
.include "devices/spi0.s"
.include "devices/spi1.s"
.include "devices/aux_mini_uart.s"
.include "devices/arm_timer.s"
.include "interrupts/interrupts.s"
.include "graphics/frame_buffer.s"
.include "graphics/drawing.s"
.include "devices/system_timer.s"
.include "devices/msd_card.s"

.section .data
.align 1
welcome_message: .ascii "Bienvenido a Mini+ OS\r\n"
end_message: .byte 0

.align 1
peciosa: .ascii "Alondra Itzaliny, te amo pechocha <3\r\n"

.align 1
screen_width: .ascii "Ancho de pantalla: "

.align 1
screen_height: .ascii "Alto de pantalla: "

.align 1
interrupts_init_message: .ascii "Inicializando interrupciones.\r\n"

.align 1
error_message: .ascii "No se habilitó el módulo SPI\r\n"

.align 1
success_message: .ascii "Se recibió SPI!\r\n"

.align 1
endl: .ascii "\r\n"


.align 4
screen_dimmensions:
    .word 1024
    .word 768

/* Punto de Inicio */
.section .init
.global _start
_start:
    ldr     sp, =0x8000
    bl      stack_init
    b       main

stack_init:
    mov       r0, #0xDB       @ Undefined
    msr       cpsr, r0
    ldr       sp, =_undefined_stack_end
    mov       r0, #0xD7       @ Abort
    msr       cpsr, r0
    ldr       sp, =_abort_stack_end
    mov       r0, #0xD1       @ Fast Interrupt Request
    msr       cpsr, r0
    ldr       sp, =_fiq_stack_end
    mov       r0, #0xD2       @ IRQ
    msr       cpsr, r0
    ldr       sp, =_irq_stack_end
    mov       r0, #0xDF       @ SYS
    msr       cpsr, r0
    ldr       sp, =_sys_stack_end
    mov       r0, #0xD3       @ SVC
    msr       cpsr, r0
    bx        lr

.section .text
.global main
main:
    ldr     r0, =#96153
    mov     r1, #0x03
    bl      aux_mini_uart_init

    ldr     r0, =welcome_message
    mov     r1, #23
    bl      aux_mini_uart_write_bytes

    ldr     r7, =endl
    ldr     r8, =interrupts_init_message
    mov     r0, r5
    mov     r1, #19
    bl      aux_mini_uart_write_bytes
    mov     r0, r8
    mov     r1, #31
    bl      aux_mini_uart_write_bytes
    bl      interrupts_init
    bl      arm_timer_init

    // Get dimmensions
    ldr     r4, =screen_dimmensions
    bl      framebuffer_get_dimmensions
    str     r0, [ r4 ]
    str     r1, [ r4, #4 ]


    ldr     r0, =screen_width
    mov     r1, #19
    bl      aux_mini_uart_write_bytes
    
    ldr     r0, [ r4 ]
    mov     r1, #10
    bl      aux_mini_uart_u32_write
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    ldr     r0, =screen_height
    mov     r1, #18
    bl      aux_mini_uart_write_bytes

    ldr     r0, [ r4, #4 ]
    mov     r1, #10
    bl      aux_mini_uart_u32_write
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    mov     r0, r5
    mov     r1, #19

    ldr     r0, [ r4 ]
    ldr     r1, [ r4, #4 ]
    mov     r2, #32
    bl      framebuffer_init

    ldr     r4, =FrameBufferInfo
    ldr     r0, [ r4, #FRAMEBUFFER_ADDRESS ]
    ldr     r1, [ r4, #FRAMEBUFFER_PHYSICAL_WIDTH ]
    ldr     r2, [ r4, #FRAMEBUFFER_PHYSICAL_HEIGHT ]
    ldr     r3, [ r4, #FRAMEBUFFER_DEPTH ]
    bl      canvas_options_write

    ldr     r0, [ r4, #FRAMEBUFFER_PITCH ]
    bl      canvas_pitch_write

    ldr     r0, =0xFF333333
    bl      canvas_foreground_write

    mov     r0, #0
    mov     r1, #0
    ldr     r2, [ r4, #0x00]
    sub     r2, #1
    ldr     r3, [ r4, #0x04 ]
    sub     r3, #1
    bl      canvas_fill_rect

    ldr     r0, =0xFF5dc1b9
    bl      canvas_foreground_write

    ldr     r0, =welcome_message
    mov     r1, #23
    mov     r2, #0
    mov     r3, #0
    bl      canvas_text_draw

    ldr     r0, =0x20215000
    ldr     r0, [ r0, #0x80 ]
    mov     r1, #10
    bl      aux_mini_uart_u32_write

    mov     r0, #' '
    bl      aux_mini_uart_byte_write

    ldr     r0, =0x20215000
    ldr     r0, [ r0, #0x88 ]
    mov     r1, #10
    bl      aux_mini_uart_u32_write

    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write

    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    ldr     r0, =40000
    mov     r1, #0
    bl      spi0_init

    mov     r4, #10
1:
    mov     r0, #0xFF
    bl      spi0_byte_write
    subs    r4, #1
    bge     1b

    mov     r1, #16
    bl      aux_mini_uart_u32_write
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    ldr     r4, =cmd00
    mov     r5, #0
2:  
    ldrb    r0, [ r4, r5 ]
    bl      spi0_byte_write
    add     r5, r5, #1
    cmp     r5, #6
    bne     2b

    mov     r1, #16
    bl      aux_mini_uart_u32_write
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    mov     r5, #10
3:
    mov     r0, #0xFF
    bl      spi0_byte_write
    mov     r1, #16
    bl      aux_mini_uart_u32_write
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write
    subs    r5, #1
    bge     3b

/*  mov     r0, #0x40
    bl      spi0_byte_write
    mov     r0, #0x00
    bl      spi0_byte_write
    mov     r0, #0x00
    bl      spi0_byte_write
    mov     r0, #0x00
    bl      spi0_byte_write
    mov     r0, #0x00
    bl      spi0_byte_write
    mov     r0, #0x00
    bl      spi0_byte_write
    mov     r0, #0x95
    bl      spi0_byte_write
2:
    mov     r0, #0xFF
    bl      spi0_byte_write
    bl      spi0_byte_read
    cmp     r0, #0x01
    bne     2b*/

loop:
    bl      aux_mini_uart_byte_read
    cmp     r0, #13
    blne    aux_mini_uart_byte_write
    bne     loop
    mov     r0, r7
    mov     r1, #2
    bl      aux_mini_uart_write_bytes
    b       loop

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
    bl      gpio_mode_write
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
