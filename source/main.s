/* Operating System for Raspberry Pi */
.include "lib/utils.s"
.include "lib/math.s"
.include "devices/gpio.s"
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

    bl      msd_card_init
    bl      msd_card_fat32_init
/*11:
    mov     r0, #0x800
    bl      msd_card_sector_index_write
    ldr     r0, =cmd17
    mov     r1, #6
    bl      spi0_bytes_write
12:
    cmp     r0, #0xFE
    beq     13f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       12b

13:
    mov     r4, #90
14:
    mov     r0, #0xFF
    bl      spi0_byte_write
    mov     r1, #16
    bl      aux_mini_uart_u32_write
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write
    subs    r4, r4, #1
    bhs     14b

    ldr     r4, =422
15:
    mov     r0, #0xFF
    bl      spi0_byte_write
    subs    r4, r4, #1
    bhs     15b

    ldr     r0, =0x6801
    bl      msd_card_sector_index_write
    ldr     r0, =cmd17
    mov     r1, #6
    bl      spi0_bytes_write
17:
    cmp     r0, #0xFE
    beq     18f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       17b
18:
    mov     r4, #512
19:
    mov     r0, #0xFF
    bl      spi0_byte_write
    mov     r1, #10
    bl      aux_mini_uart_u32_write
    mov     r0, #','
    bl      aux_mini_uart_byte_write
    mov     r0, #' '
    bl      aux_mini_uart_byte_write
    subs    r4, r4, #1
    bge     19b*/

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
