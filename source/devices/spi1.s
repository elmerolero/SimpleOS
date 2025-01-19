.include "auxiliary.s"
.include "gpio.s"

.equ AUX_SPI1_CNTL0,  0x80
.equ AUX_SPI1_CNTL1,  0x84
.equ AUX_SPI1_STAT,   0x88
.equ AUX_SPI1_PEEK,   0x8C
.equ AUX_SPI1_IO,     0xA0
.equ AUX_SPI1_TXHOLD, 0xB0

.equ AUX_SPI1_ENABLE, 0x02

.equ AUX_SPI1_CNTL_SHIFT_LENGTH_8, 0x08

.equ AUX_SPI1_CNTRL_SHIFT_OUT_LS_BIT_FIRST, 0x00
.equ AUX_SPI1_CNTRL_SHIFT_OUT_MS_BIT_FIRST, 0x40

.equ AUX_SPI1_CNTRL_IDLE_LOW,   0x00
.equ AUX_SPI1_CNTRL_IDLE_HIGH,  0x80

.equ AUX_SPI1_OUT_FALLING_EDGE, 0x0000
.equ AUX_SPI1_OUT_RISING_EDGE,  0x0100 // CPHA

.equ AUX_SPI1_IN_FALLING_EDGE,  0x0000
.equ AUX_SPI1_IN_RISING_EDGE,   0x0400 // CPOL

.equ SPI1_DISABLE,  0x0000
.equ SPI1_ENABLE,   0x0800

.equ AUX_SPI1_DOUT_NO_HOLD,     0x0000

.section .text
.global spi1_init
spi1_init:
    push { r4, r5, lr }
    // Set ALT FUNC 0 from pin 9 to 11 (for SPI)
    mov     r0, #8
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    mov     r0, #9
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    mov     r0, #10
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    mov     r0, #11
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    // Registers initialization
    ldr     r4, =AUX_BASE
    ldr     r2, [r4, #AUX_ENABLES]
    orr     r2, #AUX_SPI1_ENABLE
    str     r2, [r4, #AUX_ENABLES]

    // Clear CNTL register
    mov     r0, #1
    lsl     r0, r0, #9
    str     r0, [ r4, #AUX_SPI1_CNTL0 ]
    mov     r0, #0
    str     r0, [ r4, #AUX_SPI1_CNTL1 ]
    ldr     r0, [ r4, #AUX_SPI1_PEEK ]
    ldr     r0, [ r4, #AUX_SPI1_STAT ]

    // Loads SPI1 options
    mov     r0, #SPI1_ENABLE
    orr     r0, #AUX_SPI1_CNTL_SHIFT_LENGTH_8
    orr     r0, r0, #(AUX_SPI1_CNTRL_SHIFT_OUT_MS_BIT_FIRST | AUX_SPI1_OUT_RISING_EDGE | AUX_SPI1_IN_RISING_EDGE)
    mov     r1, #1024                @ Loads #1249 in r1
    add     r1, #224
    lsl     r1, r1, #20
    orr     r0, r0, r1
    mov     r1, #3                   @ Enables CS2
    lsl     r1, #17
    orr     r0, r0, r1
    
    str     r0, [ r4, #AUX_SPI1_CNTL0 ]
    
    pop { r4, r5, pc }

@ ------------------------------------------------------------------------------
@ Send the byte specified in R0 trough SPI
@ R0: Byte to be sent through SPI
@ ------------------------------------------------------------------------------
.section .text
.global spi1_byte_write
spi1_byte_write:
    push { lr }
    ldr     r2, =AUX_BASE
    and     r0, r0, #0xFF
1:
    ldr     r1, [ r2, #AUX_SPI1_STAT ]
    and     r1, #0x400
    cmp     r1, #0
    bne     1b
    str     r0, [ r2, #AUX_SPI1_IO ]
    
    pop  { pc }

@ ------------------------------------------------------------------------------
@ Send the byte specified in R0 trough SPI
@ R0: Byte to be sent through SPI
@ ------------------------------------------------------------------------------
.section .text
.global spi1_byte_read
spi1_byte_read:
    push { lr }
    ldr     r2, =AUX_BASE
1:
    ldr     r1, [ r2, #AUX_SPI1_STAT ]
    and     r1, #0x80
    cmp     r1, #0
    bne     1b
    ldr     r0, [ r2, #AUX_SPI1_IO ]
    
    pop  { pc }
