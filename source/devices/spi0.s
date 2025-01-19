/* January 17th 2025 - Main SPI */
/* Copyright 2025 Ismael Salas López */
.include "gpio.s"

.equ SPI0_BASE,     0x20204000
.equ SPI0_CS_REG,   0x00
.equ SPI0_FIFO_REG,  0x04
.equ SPI0_CLK_REG,   0x08
.equ SPI0_DLEN_REG,  0x0C
.equ SPI0_LTOH_REG,  0x10
.equ SPI0_DC_REG,    0x14

.equ SPI0_CSEL0,                0x0
.equ SPI0_CSEL1,                0x01
.equ SPI0_CSEL2,                0x02
.equ SPI0_CLK_PHA_0,            0x00
.equ SPI0_CLK_PHA_1,            0x04
.equ SPI0_CLK_POL_0,            0x00
.equ SPI0_CLK_POL_1,            0x08
.equ SPI0_CLEAR_NA,             0x00
.equ SPI0_CLEAR_TX,             0x10
.equ SPI0_CLEAR_RX,             0x20
.equ SPI0_CSPOL_0,              0x00
.equ SPI0_CSPOL_1,              0x40
.equ SPI0_TA_DISABLE,           0x00
.equ SPI0_TA_ENABLE,            0x80
.equ SPI0_DMA_DISABLE,          0x00
.equ SPI0_DMA_ENABLE,           0x0100
.equ SPI0_INT_ON_DONE_DISABLE,  0x00
.equ SPI0_INT_ON_DONE_ENABLE,   0x0200
.equ SPI0_INT_ON_RXR_DISABLE,   0x00
.equ SPI0_INT_ON_RXR_ENABLE,    0x0400
.equ SPI0_ADCS_DISABLE,         0x00          
.equ SPI0_ADCS_ENABLE,          0x0800  @ Automatically deassert chip select
.equ SPI0_REN_DISABLE,          0x00
.equ SPI0_REN_ENABLE,           0x1000 @ Read enable
.equ SPI0_LEN_DISABLE,          0x00
.equ SPI0_LEN_ENABLE,           0x2000 @ 0 LoSSI master
.equ SPI0_DONE_STATUS,          0x10000
.equ SPI0_RXD_STATUS,           0x20000
.equ SPI0_TXD_STATUS,           0x40000
.equ SPI0_RXR_STATUS,           0x80000
.equ SPI0_RXF_STATUS,           0x100000




.section .text
.global spi0_init
spi0_init:
    push { r4, r5, lr }
    mov r0, #SPI0_DONE_STATUS
    // Set ALT FUNC 0 from pin 9 to 11 (for SPI)
    mov     r0, #21
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    mov     r0, #20
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    mov     r0, #19
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    mov     r0, #16
    mov     r1, #GPIO_MODE_ALTF4
    bl      gpio_setMode

    // Loads SPI1 options
    mov     r0, #0
    orr     r0, #0
    orr     r0, r0, #0
    mov     r1, #1024                @ Loads #1249 in r1
    add     r1, #224
    lsl     r1, r1, #20
    orr     r0, r0, r1
    mov     r1, #3                   @ Enables CS2
    lsl     r1, #17
    orr     r0, r0, r1
    
    str     r0, [ r4 ]
    
    pop { r4, r5, pc }
