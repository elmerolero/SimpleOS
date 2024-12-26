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

.equ MU_DATA_SIZE_7,  0x01
.equ MU_DATA_SIZE_8,  0x03

.equ MU_DISABLE,                    0x00
.equ MU_RECEIVER_ENABLE,            0x01
.equ MU_TRANSMITER_ENABLE,          0x02
.equ MU_RECEIVER_TRANSMITER_ENABLE, 0x03

.equ MU_MAX_BAUDRATE, 31250000

.section .text
.global uart_init
uart_init:
    ldr     r3, =#MU_MAX_BAUDRATE
    cmp     r0, r3
    bxhi    lr
    cmp     r1, #3
    bxhi    lr

    push { r4 - r5, lr }
    
    # Back up baud-rate and data size parameter
    mov     r4, r0
    mov     r5, r1

    // Set ALT FUNC 5 on pins 14 and 15 (for AUX MINI UART)
    mov     r0, #14
    mov     r1, #GPIO_ALTF5
    bl      gpio_setMode

    mov     r0, #15
    mov     r1, #GPIO_ALTF5
    bl      gpio_setMode

    # Calculates baud-rate register value
    ldr     r0, =#250000000
    lsl     r1, r4, #3
    bl      math_unsigned_divide
    sub     r0, r0, #1

    // Registers initialization
    ldr     r3, =AUX_BASE
    ldr     r2, [r3, #AUX_ENABLES]
    orr     r2, #1
    str     r2, [r3, #AUX_ENABLES]

    mov     r2, #0
    str     r2, [r3, #AUX_MU_IER_REG]
    
    mov     r2, #0
    str     r2, [r3, #AUX_MU_CNTL_REG]

    str     r5, [r3, #AUX_MU_LCR_REG]
    
    mov     r2, #0
    str     r2, [r3, #AUX_MU_MCR_REG]
    
    mov     r2, #0x00
    str     r2, [r3, #AUX_MU_IIR_REG]

    //mov     r2, #324
    str     r0, [r3, #AUX_MU_BAUD_REG]

    // Disables Pull up-down resistors
    ldr     r3, =GPIO_GPPUD
    mov     r2, #0
    str     r2, [ r3 ]

    // Wait 150 cicles required
    mov     r0, #150
    bl      utils_delay

    ldr     r3, =GPIO_GPPUDCLK0
    mov     r2, #1
    lsl     r2, #14
    str     r2, [ r3 ]

    // Wait 150 cicles required again
    mov     r0, #150
    bl      utils_delay

    mov     r2, #0
    str     r2, [ r3 ]

    // Enables TX
    ldr     r3, =AUX_BASE
    mov     r2, #MU_RECEIVER_TRANSMITER_ENABLE
    str     r2, [ r3, #AUX_MU_CNTL_REG ]

    pop     { r4 - r5, pc }


@ ------------------------------------------------------------------------------
@ Read a byte from UART
@ Inputs
@   None
@ Outputs
@   r0: Byte read from receiver
@ ------------------------------------------------------------------------------
.section .text
.global uart_readByte
uart_readByte:
    push { lr }

    ldr     r1, =AUX_BASE
1:
    ldr     r2, [ r1, #AUX_MU_LSR_REG ]
    tst     r2, #0x01
    beq     1b
    ldr     r0, [ r1, #AUX_MU_IO_REG ]

    pop { pc }

@ ------------------------------------------------------------------------------
@ Send the letter ascii code specified in R0 trough UART
@ R0: Letter to send through UART
@ ------------------------------------------------------------------------------
.section .text
.global uart_writeByte
uart_writeByte:
    push { lr }

    ldr     r1, =AUX_BASE             // 0x20215000
1:
    ldr     r2, [r1, #AUX_MU_LSR_REG] // AUX_BASE + 0x54
    tst     r2, #0x20
    beq     1b
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
1:
    cmp     r5, r4
    bhs     2f
    ldrb    r0, [r3, r5]
    cmp     r0, #'\0'
    beq     2f
    bl      uart_writeByte
    add     r5, #1
    b       1b
2:
    pop { r4, r5, pc }
    
.section .text
.global uart_writeNumber
uart_writeNumber:
    push { r4, lr }
    mov r4, r0
1:
    mov r1, #10
    bl  math_unsigned_module
    add r0, r0, #48
    bl  uart_writeByte
    mov r0, r4
    mov r1, #10
    bl math_unsigned_divide
    mov r4, r0
    teq r0, #0
    bne   1b
    pop  { r4, pc }
    
    
    