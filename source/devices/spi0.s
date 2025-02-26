/* January 17th 2025 - Main SPI */
/* Ismael Salas López */
.include "globals/variables.s"

.equ SPI0_BASE,      0x20204000
.equ SPI0_CS_REG,    0x00
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
    # Makes sure that a right value was set up
    cmp     r1, #3
    bxhi    lr

    push { r4, r5, lr }

    // Backs up registers
    mov     r4, r0
    mov     r5, r1

    // Set ALT FUNC 0 from pin 9 to pin 11
    mov     r0, #8
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write

    mov     r0, #9
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write

    mov     r0, #10
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write

    mov     r0, #11
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write
    
    // Calculates clock register value
    ldr     r0, =core_freq
    mov     r1, r4
    ldr     r0, [ r0 ]
    bl      math_u32_divide
    sub     r0, r0, #1

    // Disable SPI0
    ldr     r4, =SPI0_BASE
    mov     r1, #0
    str     r1, [ r4, #SPI0_CS_REG ]

    // Saves calculated value
    str     r0, [ r4, #SPI0_CLK_REG ]

    // Load SPI options
    orr     r5, r5, #(SPI0_CLK_PHA_0 | SPI0_CLK_POL_0)
    str     r5, [ r4, #SPI0_CS_REG ]

    pop { r4, r5, pc }

.section .text
spi0_byte_write:
    push { lr }

    // Crean sent byte
    and     r0, r0, #0xFF

    // Enable transfer bit
    ldr     r1, =SPI0_BASE
    ldr     r2, [ r1, #SPI0_CS_REG ]
    orr     r2, r2, #(SPI0_TA_ENABLE | SPI0_CLEAR_TX | SPI0_CLEAR_RX)
    str     r2, [ r1, #SPI0_CS_REG ]

    // Write byte in FIFO
    str     r0, [ r1, #SPI0_FIFO_REG ]

    // Check for done transfer
    mov     r2, #SPI0_DONE_STATUS
1:
    ldr     r3, [ r1, #SPI0_CS_REG ]
    and     r3, r3, r2
    cmp     r3, r2
    bne     1b

    // Wait to make sure that slave data was received
    mov     r2, #SPI0_RXD_STATUS
2:
    ldr     r3, [ r1, #SPI0_CS_REG ]
    and     r3, r3, r2
    cmp     r3, r2
    bne     2b

    // Read returned data
    ldr     r0, [ r1, #SPI0_FIFO_REG ]

    pop { pc }

.section .text
spi0_bytes_write:
    push { r4, r5, r6, lr }
    mov     r4, r0
    mov     r5, r1
    mov     r6, #0
1:
    cmp     r6, r5
    bhs     2f
    ldr     r0, [ r4, r6 ]
    bl      spi0_byte_write
    add     r6, r6, #1
    b       1b
2:
    pop { r4, r5, r6, pc }


.section .text
spi0_byte_read:
    push { r4, lr }
    and     r0, r0, #0xFF
    ldr     r1, =SPI0_BASE
    mov     r3, #0x40000
    mov     r4, #0x10000
    mov     r2, #(SPI0_CLEAR_RX | SPI0_CLEAR_TX | SPI0_TA_ENABLE )
    orr     r2, #SPI0_REN_ENABLE
    str     r2, [ r1, #SPI0_CS_REG ]
1:
    ldr     r2, [ r1, #SPI0_CS_REG ]
    and     r2, r2, r3
    cmp     r2, r3
    bne     1b

    str     r0, [ r1, #SPI0_FIFO_REG ]
2:
    ldr     r2, [ r1, #SPI0_CS_REG ]
    and     r2, r4
    cmp     r2, r4
    bne     2b

    mov     r2, #0
    str     r2, [ r1, #SPI0_CS_REG]

    pop  { r4, pc }
