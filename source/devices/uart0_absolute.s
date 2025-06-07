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
.equ MU_RECEIVER_TRANSMITER_ENABLE, 0x03

.equ MU_RECEIVE_INTERRUPT_ENABLE,   0x01
.equ MU_TRANSMIT_INTERRUPT_ENABLE,  0x02

.equ GPIO_MODE_ALTF5,           2
.equ GPIO_PUD_MODE_DISABLE,     0

// GPIO pin range
.equ GPIO_PIN_MIN,  0
.equ GPIO_PIN_MAX,  53

// Available pin modes 
.equ GPIO_MODE_INPUT,   0
.equ GPIO_MODE_OUTPUT,  1
.equ GPIO_MODE_ALTF0,   4
.equ GPIO_MODE_ALTF1,   5
.equ GPIO_MODE_ALTF2,   6
.equ GPIO_MODE_ALTF3,   7
.equ GPIO_MODE_ALTF4,   3
.equ GPIO_MODE_ALTF5,   2
.equ GPIO_MODE_MIN,     0
.equ GPIO_MODE_MAX,     7

// Available pull up/down mode
.equ GPIO_PUD_MODE_DISABLE,     0
.equ GPIO_PUD_MODE_DOWN_ENABLE, 1
.equ GPIO_PUD_MODE_UP_ENABLE,   2
.equ GPIO_PUD_MODE_MIN,         0
.equ GPIO_PUD_MODE_MAX,         2

// Registers to set
.equ GPIO_PIN_LOW,      0
.equ GPIO_PIN_HIGH,     1
.equ GPIO_PIN_WRITE_MIN, 0
.equ GPIO_PIN_WRITE_MAX, 1

/* Registers to set pin mode */
.equ GPIO_GPFSEL0,  0x0 
.equ GPIO_GPFSEL1,  0x4
.equ GPIO_GPFSEL2,  0x8
.equ GPIO_GPFSEL3,  0xC
.equ GPIO_GPFSEL4,  0x10
.equ GPIO_GPFSEL5,  0x14

/* Pin Set - To give a positive output */
.equ GPIO_GPSET0,   0x1C
.equ GPIO_GPSET1,   0x20

/* Pin Clear - To give a negative output */
.equ GPIO_GPCLR0,   0x28
.equ GPIO_GPCLR1,   0x2C

/* Niveles del pin */
.equ GPIO_GPLEV0,   0x34
.equ GPIO_GPLEV1,   0x38

/* Estado de evento detectado (Evect Detect Status) */
.equ GPIO_GPEDS0,   0x40
.equ GPIO_GPEDS1,   0x44

/* Rising Edge Detect Enable */
.equ GPIO_GPREN0,   0x4C
.equ GPIO_GPREN1,   0x50

/* FAlling Edge Detect Enable */
.equ GPIO_GPFEN0,   0x58 
.equ GPIO_GPFEN1,   0x5C

/* High Detect Enable */
.equ GPIO_GPHEN0,   0x64
.equ GPIO_GPHEN1,   0x68

/* GPIO Pin Low Detect Enable */
.equ GPIO_GPLEN0,   0x70
.equ GPIO_GPLEN1,   0x74

/* GPIO Pin Async. Rising Edge Detect */
.equ GPIO_GPAREN0,  0x7C
.equ GPIO_GPAREN1,  0x80

/* GPIO Pin Asyn. Falling Edge Detect */
.equ GPIO_GPAFEN0,  0x88
.equ GPIO_GPAFEN1,  0x8C

/* Pin pull-up/down Enable */
.equ GPIO_GPPUD,        0x94
.equ GPIO_GPPUDCLK0,    0x98
.equ GPIO_GPPUDCLK1,    0x9C

// GPIO PUD mode write errors
.equ GPIO_ERROR_INVALID_PIN,        0xFFFFFFFF
.equ GPIO_ERROR_INVALID_PIN_MODE,   0xFFFFFFFE
.equ GPIO_ERROR_INVALID_PUD_MODE,   0xFFFFFFFE

.section .init
buffer: .skip 32

.section .init
uart0A_Init:
    push { r4, r5, r6, lr }
    
    # Back up baud-rate and data size parameter
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2

    // Set ALT FUNC 5 on pins 14 and 15 (for AUX MINI UART)
    mov     r0, #14
    mov     r1, #GPIO_MODE_ALTF5
    bl      gpioA_ModeSet

    mov     r0, #15
    mov     r1, #GPIO_MODE_ALTF5
    bl      gpioA_ModeSet

    // Disables pull up/down resistors for pins 14 and 15
    mov     r0, #14
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpioA_pud_mode_write

    mov     r0, #15
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpioA_pud_mode_write

    // Calculates baud-rate register value
    //ldr     r0, =250000000
    //lsl     r1, r4, #3
    //bl      math_u32_divide
    //sub     r0, r0, #1

    // Enables mini UART
    ldr     r0, =0x20215000
    mov     r1, #AUX_UART_ENABLE
    str     r1, [r0, #AUX_ENABLE_REG]

    // Clean registers
    mov     r2, #0
    str     r2, [r0, #AUX_MU_IER_REG]
    
    mov     r2, #0
    str     r2, [r0, #AUX_MU_CNTL_REG]

    str     r5, [r0, #AUX_MU_LCR_REG]
    
    mov     r2, #0
    str     r2, [r0, #AUX_MU_MCR_REG]
    
    mov     r2, #0
    str     r2, [r0, #AUX_MU_IIR_REG]

    mov     r3, #324
    str     r3, [r0, #AUX_MU_BAUD_REG]

    // Enables TX
    mov     r2, #MU_RECEIVER_TRANSMITER_ENABLE
    str     r2, [ r0, #AUX_MU_CNTL_REG ]

    pop     { r4, r5, r6, pc }


@ ------------------------------------------------------------------------------
@ Read a byte from UART
@ Inputs
@   None
@ Outputs
@   r0: Byte read from receiver
@ ------------------------------------------------------------------------------
.section .init
uart0A_read:
    push { lr }
    ldr     r0, =0x20215000     
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
.section .init
uart0A_write:
    push { lr }
    and     r2, r0, #0xFF
    ldr     r0, =0x20215000
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
.section .init
uart0A_write_bytes:
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
    bl      uart0A_write
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
.section .init
.global uart0_u32_write
uart0A_u32_write:
    cmp     r1, #0x10
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
    blne    uart0A_write
    bne     2b
    pop  { r4, r5, r6, pc }


@ ------------------------------------------------------------------------------
@ Convert a number to text and sends it through UART
@ It only works in base 10
@ R0: Number to be sent
@ ------------------------------------------------------------------------------
.section .init
uart0A_s32_write:
    push { r4, r5, r6, lr }
    mov     r4, r0
    cmp     r0, #0
    movlt   r0, #'-'
    bl      uart0A_write
    
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
    blne    uart0A_write
    bne     2b
    pop  { r4, r5, r6, pc }

.section .init
gpioA_ModeSet:
    cmp         r0, #53             
    cmpls       r1, #GPIO_MODE_MAX
    bhi         3f
    push {r4, lr}            
    mov         r2, r0                  // Pin number
    mov         r3, r1                  // Pin mode
    ldr         r0, =0x20200000
1:
    cmp         r2, #10                 // If r2 < 10 goes next step
    bmi         2f                      
    add         r0, #4 
    sub         r2, #10
    b           1b
2:
    add         r2, r2, r2, lsl #1      // r3 << (r2 * 3)
    ldr         r1, [ r0 ]              // r1 = GPIOSELX
    mov         r4, #7              
    mvn         r4, r4, lsl r2      
    and         r1, r1, r4          
    orr         r1, r1, r3, lsl r2      // r1 | (r3 << r2)
    str         r1, [ r0 ]          
    mov         r0, #0  
    b           4f
3:
    mov         r0,     #-1
4:
    pop {r4, pc}            @ Finaliza

.section .init
gpioA_pud_mode_write:
    cmp     r0, #GPIO_MODE_MAX
    movhi   r0, #GPIO_ERROR_INVALID_PIN
    bxhi    lr
    cmp     r1, #GPIO_PUD_MODE_MAX
    movhi   r1, #GPIO_ERROR_INVALID_PUD_MODE
    bxhi    lr

    push { r4, r5, r6, lr } 

    // Backs up the mode that will be updated
    mov     r4, r1

    // We get the bit for the desired pin and the offset
    mov     r0, r4
    mov     r1, #32
    bl      math_u32_divide
    mov     r5, r0
    mov     r6, r1

    // Gets GPIO address
    ldr     r0, =0x20200000
    
    // Set GPPUD mode
    str     r4, [ r0, #GPIO_GPPUD ]
    lsl     r3, r5, #2
    add     r2, r3, #GPIO_GPPUDCLK0
    mov     r3, #1
    lsl     r3, r3, r6
    str     r3, [ r0, r2 ]

    // Wait 150 cycles required again
    mov     r0, #150
    bl      utilsA_delay

    ldr     r0, =0x20200000
    mov     r3, #0
    str     r3, [ r0, #GPIO_GPPUD ]
    str     r3, [ r0, r2 ]
    mov     r0, #0

    pop { r4, r5, r6, pc }

@ ------------------------------------------------------------------------------
@ Waits the number of cycles specified in R0
@ R0: Number of cycles
@ ------------------------------------------------------------------------------
.section .text
.global utilsA_delay
utilsA_delay:
1:
    subs    r0, #1
    bne     1b
    bx      lr
