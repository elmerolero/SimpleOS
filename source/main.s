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
.include "devices/pwm.s"

.section .data
.align 1
    clear_screen:   .asciz "\033[2J\033[H"

.align 1
    welcome_message: .asciz "Bienvenido a Mini+ OS\r\n"

    screen_width: .asciz "Ancho de pantalla: "
    screen_height: .asciz "Alto de pantalla: "

.align 1
    interrupts_init_message: .asciz "Inicializando interrupciones.\r\n"

.align 1
    msd_card_init_message:            .asciz "Inicializando Tarjeta SD.\r\n"
    fat32_bytes_per_sector_message:   .asciz "Bytes por sector: "
    fat32_sectors_per_cluster:        .asciz "Sectores por cluster: "
    fat32_reserved_sectors:           .asciz "Sectores reservados: "
    fat32_num_FATS:                   .asciz "Numero de FATs: "
    fat32_FAT_size:                   .asciz "Tamaño de FAT: "
    fat32_total_sectors:              .asciz "Número total de sectores: "
    fat32_root_cluster:               .asciz "Cluster del directorio raiz: "

.align 1
    endl: .asciz "\r\n"

.align 1
    peciosa: .asciz "Alondra Itzaliny, te amo pechocha <3\r\n"


.align 4
screen_dimmensions:
    .word 1024
    .word 768

/* Punto de Inicio */
.section .init
.global _start
_start:
    mov     sp, #0x8000
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
    ldr     r0, =96153
    mov     r1, #0x03
    bl      aux_mini_uart_init

    ldr     r0, =clear_screen
    mov     r1, #7
    bl      aux_mini_uart_write_bytes

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

    ldr     r0, =msd_card_init_message
    mov     r1, #27
    bl      aux_mini_uart_write_bytes

    bl      msd_card_init
    bl      msd_card_fat32_init

    mov     r5, #0
    mov     r8, #0
    mov     r9, #0
    mov     r11, #0
1:
    ldr     r0, =fat32_root_sector
    ldr     r0, [ r0 ]
    add     r0, r0, r8
    bl      msd_card_sector_read
 
    ldr     r4, =sector_buffer
    mov     r5, #0
2:
    ldrb    r0, [ r4, r5 ]      // Looks for an entry
    cmp     r0, #0x00
    beq     5f
    cmp     r0, #0xE5           // Is it a deleted entry?
    beq     4f
    add     r6, r5, #11
    ldrb    r0, [ r4, r6 ]
    cmp     r0, #0x0F           // LNF?
    beq     4f

    ldr     r10, =files
    mov     r6, #0
3:
    add     r7, r5, r6
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    add     r6, r6, #1
    cmp     r6, #8
    blo     3b
    mov     r0, #'.'
    bl      aux_mini_uart_byte_write
    add     r7, r5, #8
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    add     r7, r5, #9
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    add     r7, r5, #10
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    mov     r0, #' '
    bl      aux_mini_uart_byte_write

    // Read cluster msb
    add     r6, r5, #0x15
    ldrb    r1, [ r4, r6 ]
    add     r6, r5, #0x14
    ldrb    r0, [ r4, r6 ]
    orr     r1, r0, r1, lsl #8

    // Read cluster lsb
    add     r6, r5, #0x1B
    ldrb    r2, [ r4, r6 ]
    add     r6, r5, #0x1A
    ldrb    r0, [ r4, r6 ]
    orr     r2, r0, r2, lsl #8
    orr     r1, r2, r1, lsl #16

    // Read file size from msb to lsb
    add     r6, r5, #0x1C
    ldrb    r2, [ r4, r6 ]
    add     r6, r5, #0x1D
    ldrb    r0, [ r4, r6 ]
    orr     r2, r2, r0, lsl #8
    add     r6, r5, #0x1E
    ldrb    r0, [ r4, r6 ]
    orr     r2, r2, r0, lsl #16
    add     r6, r5, #0x1F
    ldrb    r0, [ r4, r6 ]
    orr     r2, r2, r0, lsl #24
    
    add     r6, r11, #0x0C
    str     r1, [ r10, r6 ]

    add     r6, r11, #0x10
    str     r2, [ r10, r6 ]   

    mov     r0, r1
    mov     r1, #16
    mov     r7, r2
    bl      aux_mini_uart_u32_write
    mov     r0, #' '
    bl      aux_mini_uart_byte_write

    mov     r0, r7
    mov     r1, #16
    bl      aux_mini_uart_u32_write

    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    add     r11, r11, #20
4:                                          // Next entry
    add     r5, r5, #32
    b       2b
5:
    add     r8, r8, #1
    cmp     r5, #512
    beq     1b

    bl      pwm_init

loop:
    bl      aux_mini_uart_byte_read
    cmp     r0, #13
    blne    aux_mini_uart_byte_write
    bne     loop
    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write
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
