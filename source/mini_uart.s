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
.global uart_init
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


@ ------------------------------------------------------------------------------
@ Send the letter ascii code specified in R0 trough UART
@ R0: Letter to send through UART
@ ------------------------------------------------------------------------------
.section .text
.global uart_writeChar
uart_writeChar:
    push { lr }

1:
    ldr     r1, =AUX_BASE             // 0x20215000
    ldr     r2, [r1, #AUX_MU_LSR_REG] // AUX_BASE + 0x54
    and     r2, #0x20
    cmp     r2, #0x20
    bne     1b
    str     r0, [r1, #AUX_MU_IO_REG]  // AUX_BASE + 0x40

    pop { pc }

@ ------------------------------------------------------------------------------
@ Send the ascii string through UART
@ R0: Address of text to be sent through UART
@ R1: String size
@ ------------------------------------------------------------------------------
.section .text
.global uart_writeText
uart_writeText:
    push { r4, r5, lr }

    mov     r3, r0
    mov     r4, r1
    mov     r5, #0
    cmp     r3, r5
    beq     2f
    cmp     r4, r5
1:
    cmp     r5, r4
    bhs     2f
    ldrb    r0, [r3, r5]
    cmp     r0, #'\0'
    beq     2f
    bl      uart_writeChar
    add     r5, #1
    b       1b
2:
    pop { r4, r5, pc }
    