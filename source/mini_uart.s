.include "gpio.s"

.extern utils_delay

.equ AUX_BASE,    0x20215000
.equ AUX_ENABLES, 0x04

// Mini UART
.equ AUX_MU_IO_REG,   0x40
.equ AUX_MU_IER_REG,  0x44
.equ AUX_MU_IIR_REG,  0x48
.equ AUX_MU_LCR_REG,  0x4C
.equ AUX_MU_MCR_REG,  0x50
.equ AUX_MU_LSR_REG,  0x54
.equ AUX_MU_MSR_REG,  0x58
.equ AUX_MU_SCRATCH,  0x5C
.equ AUX_MU_CNTL_REG, 0x60
.equ AUX_MU_STAT_REG, 0x64
.equ AUX_MU_BAUD_REG, 0x68

.section .text
uart_init:
    push    { lr }
    
    // Set ALT FUNC 5 on pins 14 and 15 (for AUX MINI UART)
    mov     r0, #14
    mov     r1, #GPIO_ALTF5
    bl      gpio_setMode

    mov     r0, #15
    mov     r1, #GPIO_ALTF5
    bl      gpio_setMode

    // Registers initialization
    ldr     r2, =AUX_BASE
    mov     r1, #1
    str     r1, [r2, #AUX_ENABLES]

    mov     r1, #0
    str     r1, [r2, #AUX_MU_IER_REG]
    
    mov     r1, #0
    str     r1, [r2, #AUX_MU_CNTL_REG]
    
    mov     r1, #3
    str     r1, [r2, #AUX_MU_LCR_REG]
    
    mov     r1, #0
    str     r1, [r2, #AUX_MU_MCR_REG]
    
    mov     r1, #0x00
    str     r1, [r2, #AUX_MU_IIR_REG]
    
    mov     r1, #324
    str     r1, [r2, #AUX_MU_BAUD_REG]

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

    // Enables TX
    ldr     r2, =AUX_BASE
    mov     r1, #2
    str     r1, [ r2, #AUX_MU_CNTL_REG ]

    pop     { pc }

.section .text
.global uart_writeChar
uart_writeChar


/*.section .text
uart_write:
    push    { lr }
    ldr     r3, =AUX_MU_IO_REG
    mov     r4, #1
    lsl     r4, #5
uart_writeCheck:
    ldr     r5, [ r3, #UART_FR ]
    and     r5, r4
    cmp     r5, r4
    beq     uart_writeCheck
    mov     r4, #65
    str     r4, [ r3 ]
    pop     { pc }
*/