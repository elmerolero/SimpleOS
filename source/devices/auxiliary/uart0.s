.include "devices/auxiliary/auxiliary.s"

.section .data
.init_ptr:  .word uart0_Init
.read_ptr:  .word uart0_Read
.write_ptr: .word uart0_Write

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
uart0_Buffer: .skip 128

@ ------------------------------------------------------------------------------
@ Initializes UART 0
@ r0: Baudrate
@ r1: Data size
@ r2: Enabling options
@ r3: Enabling interrupt options
@ ------------------------------------------------------------------------------
.section .text
uart0_Init:
    push { r4, r5, r6, r7, lr }
    ldr     r4, mu_MaxBaudRate
    cmp     r0, r4
    cmpls   r1, #MU_DATA_SIZE_8
    pophi { r4, r5, r6, r7, lr }
    
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

    // Disables pull up/down resistors for pins 14 and 15
    mov     r0, #14
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_pud_mode_write

    mov     r0, #15
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_pud_mode_write

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
    and     r2, r7, #(MU_RECEIVE_INTERRUPT_ENABLE | MU_TRANSMIT_INTERRUPT_ENABLE | 0x0C)
    str     r2, [r0, #AUX_MU_IER_REG]

    // Enabling UART options
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
uart0_Read:
    push { lr }
    mov     r0, #AUXILIARY_DEVICES
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
uart0_Write:
    push { lr }
    and     r2, r0, #0xFF
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
1:
    ldr     r1, [r0, #AUX_MU_LSR_REG]
    tst     r1, #0x20
    beq     1b
    str     r2, [r0, #AUX_MU_IO_REG]
    pop { pc }

.equ AUX_MU_NO_INTERRUPT_PENDING,   0x01
.equ AUX_MU_RECEIVER_BYTE_PENDING,  0x04
uart0_InterruptHandler:
    push    { lr }
1:
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    ldr     r1, [r0, #AUX_MU_IIR_REG]
    tst     r1, #AUX_MU_NO_INTERRUPT_PENDING
    bne     2f
    tst     r1, #AUX_MU_RECEIVER_BYTE_PENDING
    blne    uart0_Read
    bl      uart0_Write
    b       1b
2:
    pop     { pc }
    

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
    bl      uart0_Write
    add     r5, #1
    b       1b
2:
    pop { r4, r5, pc }
