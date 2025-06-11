.include "devices/system.s"
.include "devices/auxiliary.s"

// Mini UART
.equ AUX_MU_IO_REG,         0x40
.equ AUX_MU_IER_REG,        0x44
.equ AUX_MU_IIR_REG,        0x48
.equ AUX_MU_LCR_REG,        0x4C
.equ AUX_MU_MCR_REG,        0x50
.equ AUX_MU_LSR_REG,        0x54
.equ AUX_MU_MSR_REG,        0x58
.equ AUX_MU_SCRATCH_REG,    0x5C
.equ AUX_MU_CNTL_REG,       0x60
.equ AUX_MU_STAT_REG,       0x64
.equ AUX_MU_BAUD_REG,       0x68

.equ MU_DATA_SIZE_7,        0x01
.equ MU_DATA_SIZE_8,        0x03

.equ MU_DISABLE,                    0x00
.equ MU_RECEIVER_ENABLE,            0x01
.equ MU_TRANSMITER_ENABLE,          0x02

.equ MU_INTERRUPTS_DISABLE,         0x00
.equ MU_RECEIVE_INTERRUPT_ENABLE,   0x01
.equ MU_TRANSMIT_INTERRUPT_ENABLE,  0x02

.equ GPIO_MODE_ALTF5,           2
.equ GPIO_PUD_MODE_DISABLE,     0

.section .data
buffer: .skip 32

@ ------------------------------------------------------------------------------
@ Initializes UART 0
@ r0: Baudrate
@ r1: Data size
@ r2: Enabling options
@ r3: Enabling interrupt options
@ ------------------------------------------------------------------------------
.section .text
uart0_Init:
    ldr     r3, mu_MaxBaudRate
    cmp     r0, r3
    cmpls   r1, #MU_DATA_SIZE_8
    bxhi    lr

    push { r4, r5, r6, r7, lr }
    
    # Back up baud-rate and data size parameter
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2
    mov     r7, r3

    // Set ALT FUNC 5 on pins 14 and 15 (for AUX MINI UART)
    mov     r0, #14
    mov     r1, #GPIO_MODE_ALTF5
    bl      gpio_ModeSet

    mov     r0, #15
    mov     r1, #GPIO_MODE_ALTF5
    bl      gpio_ModeSet

    // Calculates baud-rate register value
    bl      system_CoreFreqGet
    lsl     r1, r4, #3
    bl      math_u32_divide
    sub     r0, r0, #1
    mov     r3, r0

    // Enables mini UART
    mov     r0, #AUX_UART_ENABLE
    bl      auxiliary_Enable

    // Clean registers
    mov     r2, #0
    str     r2, [r0, #AUX_MU_IER_REG]
    str     r2, [r0, #AUX_MU_CNTL_REG]
    str     r2, [r0, #AUX_MU_LCR_REG]
    str     r2, [r0, #AUX_MU_MCR_REG]

    // Sets baud rate
    mov     r2, r3
    str     r2, [r0, #AUX_MU_BAUD_REG]

    // Set data size
    mov     r2, r5
    str     r2, [r0, #AUX_MU_LCR_REG]

    // Interrupts
    and     r2, r7, #(MU_RECEIVE_INTERRUPT_ENABLE | MU_TRANSMIT_INTERRUPT_ENABLE)
    str     r2, [r0, #AUX_MU_IER_REG]

    // Disables pull up/down resistors for pins 14 and 15
    mov     r0, #14
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_pud_mode_write

    mov     r0, #15
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_pud_mode_write

    // Enabling UART options
    mov     r0, #AUX_DEVICES
    bl      devices_AddressGet
    and     r2, r6, #(MU_RECEIVER_ENABLE | MU_TRANSMITER_ENABLE)
    str     r2, [ r0, #AUX_MU_CNTL_REG ]
    mov     r0, #0

    pop     { r4, r5, r6, r7, pc }

mu_MaxBaudRate: .word 31250000


@ ------------------------------------------------------------------------------
@ Read a byte from UART
@ Inputs
@   None
@ Outputs
@   r0: Byte read from receiver
@ ------------------------------------------------------------------------------
.section .text
uart0_read:
    push { lr }
    mov     r0, #AUX_DEVICES
    bl      devices_AddressGet       
1:
    ldr     r1, [ r0, #AUX_MU_LSR_REG ]
    tst     r1, #1
    beq     1b
    ldr     r0, [ r0, #AUX_MU_IO_REG ]
    pop { pc }

@ ------------------------------------------------------------------------------
@ Send the letter ascii code specified in R0 trough UART
@ R0: Letter to send through UART
@ ------------------------------------------------------------------------------
.section .text
uart0_write:
    push { lr }
    and     r2, r0, #0xFF
    mov     r0, #AUX_DEVICES
    bl      devices_AddressGet
1:
    ldr     r1, [r0, #AUX_MU_LSR_REG]
    tst     r1, #0x20
    beq     1b
    str     r2, [r0, #AUX_MU_IO_REG]
    pop { pc }

@ ------------------------------------------------------------------------------
@ Send the ascii string through UART
@ R0: Address of text to be sent through UART
@ R1: String size
@ ------------------------------------------------------------------------------
.section .text
uart0_write_bytes:
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
    bl      uart0_write
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
.global uart0_u32_write
uart0_u32_write:
    cmp     r1, #16
    bxhi    lr

    push { r4, r5, r6, lr }

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
    blne    uart0_write
    bne     2b
    pop  { r4, r5, r6, pc }

@ ------------------------------------------------------------------------------
@ Convert a number to text and sends it through UART
@ It only works in base 10
@ R0: Number to be sent
@ ------------------------------------------------------------------------------
.section .text
uart0_s32_write:
    push { r4, r5, r6, lr }
    mov     r4, r0
    cmp     r0, #0
    movlt   r0, #'-'
    bl      uart0_write
    
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
    blne    uart0_write
    bne     2b
    pop  { r4, r5, r6, pc }

@ ------------------------------------------------------------------------------
@ Integer division in ARMv6
@ r0: dividend
@ r1: divisor
@ Ouputs:
@ r0: quotient
@ r1: remainder (optional)
@ ------------------------------------------------------------------------------
.global math_u32_divide
math_u32_divide:         
    cmp     r1, #0           
    beq     math_u32_divide_error   // Handle division by 0

    mov     r3, r0
    mov     r0, #0
    cmp     r3, r1              // if dividend < divisor then
    movlo   r1, r3              
    bxlo    lr                  // If true, return (quotient = 0, remainder = dividend)

    push { r4, r5, r6, lr }

    mov     r2, #1
1:
    mov     r4, #0              // Set the lowest bit position (0)
2:
    lsl     r5, r1, r4
    sub     r6, r3, r5
    cmp     r6, r5              // Compare remainder with divisor << bit
    addhs   r4, r4, #1
    bhs     2b                  // If remainder <= divisor, increment bit position one position
    mov     r3, r6              // Subtract divisor << bit from remainder
    orr     r0, r0, r2, lsl r4  // Set the corresponding bit in the quotient
    cmp     r3, r1
    bhs     1b
    mov     r1, r3
    pop { r4, r5, r6, pc }                

math_u32_divide_error:
    mov r0, #0           // En caso de error, cociente = 0
    bx lr