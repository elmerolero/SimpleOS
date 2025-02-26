//.include "gpio.s"
.include "auxiliary.s"

.equ UART_BASE,     0x20201000  // UART Base Address

.equ UART_DR,       0x0         // Data register
.equ UART_RSRECR,   0x4           
.equ UART_FR,       0x18        // Flag register
.equ UART_ILPR,     0x20        // Not in use
.equ UART_IBRD,     0x24        // Integer baud rate divisor
.equ UART_FBRD,     0x28        // Fraction baud rate divisor
.equ UART_LCRH,     0x2c        // Line control register
.equ UART_CR,       0x30        // Control register
.equ UART_IFLS,     0x34        // Interrupt FIFO Level Select Register
.equ UART_IMSC,     0x38        // Interrupt Mask Set Clear Register
.equ UART_RIS,      0x3c        // Raw Interrupt Status Register
.equ UART_MIS,      0x40        // Masked Interrup Status Register
.equ UART_ICR,      0x44        // Interrupt Clear Register
.equ UART_DMACR,    0x48        // DMA Control Register
.equ UART_ITCR,     0x80        // Test Control Register
.equ UART_ITIP,     0x84        // Integration Test Input Register
.equ UART_ITOP,     0x88        // Integration test Output Register
.equ UART_TDR,      0x8c        // Test Data Register

.equ UART_LENGTH_EIGHT, 0x3
.equ UART_LENGTH_SEVEN, 0x2
.equ UART_LENGTH_SIX,   0x1
.equ UART_LENGTH_FIVE,  0x0

.equ UART_STOP_BIT_ONE, 0x0
.equ UART_STOP_BIT_TWO, 0x1

.equ UART_PARITY_NONE, 0x0
.equ UART_PARITY_ODD,  0x1
.equ UART_PARITY_EVEN, 0x3

.equ UART_FIFO_ENABLED,     0x10

// External functions
.extern gpio_mode_write
.extern utils_delay

@ -------------------------------------------------------------------
@ uart_init - Initializes UART using 14 and 15 GPIO pins 
@ r0 - Baud rate
@ r1 - Data bit size
@ r2 - Stop bits number
@ r3 - Parity bit type
@ -------------------------------------------------------------------
/* .section .text
uart_init:
    push    { r4, r5, lr }

    // Save parameters
    mov     r4, r0
    mov     r5, #0
    orr     r5, r5, r1, lsl #5
    orr     r5, r5, r2, lsl #3
    orr     r5, r5, r3, lsl #1

    // Set alternative modes
    mov     r0, #14
    mov     r1, #GPIO_ALTF0
    bl      gpio_mode_write

    mov     r4, r0
    mov     r0, #15
    mov     r1, #GPIO_ALTF0
    bl      gpio_mode_write

    ldr     r0, =UART_BASE

    // Control Register programming
    // Disable UART
    mov     r1, #0
    str     r1, [ r0, #UART_CR ]      
    
    // Flush transmit FIFO
1:
    ldr     r1, [ r0, #UART_FR ]
    and     r1, #0x8
    cmp     r1, #0x8
    beq     1b

    // Reset settings
    mov     r1, #0
    str     r1, [ r0, #UART_LCRH ]

    // Interrups disabled
    mov     r1, #0x7FF
    str     r1, [ r0, #UART_ICR ] 

    // 312.5 For baud rate register
    mov     r1, #19
    str     r1, [ r0, #UART_IBRD ]
    mov     r1, #53125
    str     r1, [ r0, #UART_FBRD ]     

    // Disables Pull up-down resistors
    ldr     r2, =GPIO_GPPUD
    mov     r1, #0
    str     r1, [ r2 ]

    // Wait 150 cicles required
    mov     r0, #150
    bl      utils_delay

    ldr     r2, =GPIO_GPPUDCLK0
    mov     r1, #1
    lsl     r1, #14
    str     r1, [ r2 ]

    // Wait 150 cicles required again
    mov     r0, #150
    bl      utils_delay

    mov     r1, #0
    str     r1, [ r2 ]

    // Set UART settings
    ldr     r0, =UART_BASE
    str     r5, [ r0, #UART_LCRH ]

    // Enables UART
    mov     r1, #0x201
    str     r1, [ r0, #UART_CR ]

    pop     { r4, r5, pc }
*/