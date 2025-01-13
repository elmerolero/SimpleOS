.include "auxiliary.s"
.include "gpio.s"

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

.equ AUX_MU_ENABLE,   0x01

.equ MU_DATA_SIZE_7,  0x01
.equ MU_DATA_SIZE_8,  0x03

.equ MU_DISABLE,                    0x00
.equ MU_RECEIVER_ENABLE,            0x01
.equ MU_TRANSMITER_ENABLE,          0x02
.equ MU_RECEIVER_TRANSMITER_ENABLE, 0x03

.equ MU_MAX_BAUDRATE, 31250000
.section .data
.align 1
buffer: .skip 33

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
    mov     r1, #GPIO_MODE_ALTF5
    bl      gpio_setMode

    mov     r0, #15
    mov     r1, #GPIO_MODE_ALTF5
    bl      gpio_setMode

    // Disables pull up/down resistors for pins 14 and 15
    mov     r0, #14
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_pud_mode_write

    mov     r0, #15
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_pud_mode_write

    // Calculates baud-rate register value
    ldr     r0, =#250000000
    lsl     r1, r4, #3
    bl      math_u32_divide
    sub     r0, r0, #1

    // Registers initialization
    ldr     r3, =AUX_BASE
    ldr     r2, [r3, #AUX_ENABLES]
    orr     r2, #AUX_MU_ENABLE
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

    str     r0, [r3, #AUX_MU_BAUD_REG]

    // Disables Pull up-down resistors
   /*ldr     r3, =GPIO_GPPUD
    mov     r2, #0
    str     r2, [ r3 ]

    // Wait 150 cicles required
    mov     r0, #150
    bl      utils_delay

    ldr     r3, =GPIO_GPPUDCLK0
    mov     r2, #3
    lsl     r2, #14
    str     r2, [ r3 ]

    // Wait 150 cicles required again
    mov     r0, #150
    bl      utils_delay

    mov     r2, #0
    str     r2, [ r3 ]*/

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
.global uart_byte_read
uart_byte_read:
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
.global uart_byte_write
uart_byte_write:
    push { lr }

    ldr     r1, =AUX_BASE             // 0x20215000
1:
    ldr     r2, [r1, #AUX_MU_LSR_REG] // AUX_BASE + 0x54
    tst     r2, #0x20
    beq     1b
    and     r0, r0, #0xFF
    str     r0, [r1, #AUX_MU_IO_REG]  // AUX_BASE + 0x40

    pop { pc }

@ ------------------------------------------------------------------------------
@ Send the ascii string through UART
@ R0: Address of text to be sent through UART
@ R1: String size
@ ------------------------------------------------------------------------------
.section .text
.global uart_write_bytes
uart_write_bytes:
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
    cmp     r0, #0
    beq     2f
    bl      uart_byte_write
    add     r5, #1
    b       1b
2:
    pop { r4, r5, pc }

@ ------------------------------------------------------------------------------
@ Convert an unsigned int number to text and sends it through UART for unsigned 
@ int numbers. Supports 255 base
@ R0: Number to be sent
@ R1: Numerical base of the number
@ ------------------------------------------------------------------------------
.section .text
.global uart_u32_write
uart_u32_write:
    cmp     r1, #0xFF
    bxhi    lr

    push { r4 - r6, lr }

    mov     r4, r0
    mov     r5, r1

    ldr     r6, =buffer
    mov     r0, #0x00
    strb    r0, [r6], #1

1:
    mov     r0, r4
    mov     r1, r5
    bl      math_u32_divide
    mov     r4, r0
    mov     r0, r1
    cmp     r0, #9
    addhi   r0, r0, #7
    add     r0, r0, #48
    strb    r0, [r6], #1
    teq     r4, #0
    bne     1b
2:
    ldrb    r0, [r6, #-1]!
    cmp     r0, #0x00
    blne    uart_byte_write
    bne     2b
    pop  { r4 - r6, pc }
    
@ ------------------------------------------------------------------------------
@ Convert a number to text and sends it through UART
@ It only works in base 10
@ R0: Number to be sent
@ ------------------------------------------------------------------------------
.section .text
.global uart_s32_write
uart_s32_write:
    push { r4, r5, r6, lr }
    mov     r4, r0
    cmp     r0, #0
    movlt   r0, #'-'
    bl      uart_byte_write
    
    ldr     r6, =buffer
    mov     r0, #0
    strb    r0, [r6], #1
1:
    mov     r0, r4
    mov     r1, #10
    bl      math_s32_divide
    mov     r4, r0
    mov     r0, r1
    bl      math_s32_abs
    add     r0, r0, #48
    and     r0, r0, #0xFF
    strb    r0, [r6], #1
    teq     r4, #0
    bne     1b
2:
    ldrb    r0, [r6, #-1]!
    cmp     r0, #0
    blne    uart_byte_write
    bne     2b
    pop  { r4, r5, r6, pc }