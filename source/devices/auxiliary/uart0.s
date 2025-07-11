.include "devices/auxiliary/auxiliary.s"

.section .data
.init_ptr:  .word uart0_Init
.read_ptr:  .word uart0_Read
.write_ptr: .word uart0_Write

.align 4
uart0_RXBuffer:
uart0_ReceiveBufferHead:    .word 0
uart0_ReceiveBufferTail:    .word 0
uart0_ReceiveBuffer:        .skip 1024

uart0_TXBuffer:
uart0_TransmitBufferHead:   .word 0
uart0_TransmitBufferTail:   .word 0
uart0_TransmitBuffer:       .skip 1024

// To structure buffer
.equ BUFFER_HEAD, 0x00
.equ BUFFER_TAIL, 0x04
.equ BUFFER_REFF, 0x08

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

.equ MU_DISABLE,            0x00
.equ MU_RECEIVER,    0x01
.equ MU_TRANSMITER,  0x02

.equ MU_INTERRUPTS_DISABLE, 0x00
.equ MU_RECEIVE_INTERRUPT,  0x01
.equ MU_TRANSMIT_INTERRUPT, 0x02

.equ GPIO_MODE_ALTF5,       2
.equ GPIO_PUD_MODE_DISABLE, 0

.equ AUX_MU_BUFFER_SIZE, 1024

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
    and     r2, r7, #(MU_RECEIVE_INTERRUPT | MU_TRANSMIT_INTERRUPT | 0x0C)
    orr     r2, r2, #0x0C
    str     r2, [r0, #AUX_MU_IER_REG]

    // Enabling UART options
    and     r2, r6, #(MU_RECEIVER | MU_TRANSMITER)
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

@ ------------------------------------------------------------------------------
@ Enable interrupts
@ IMPORTANT: Make sure that UART is enabled or this won't work
@ R0: Interrupt parameters
@ ------------------------------------------------------------------------------
.section .text
uart0_InterruptsEnable:
    push { lr }
    @ Backs up r0
    and     r2, r0, #(MU_RECEIVE_INTERRUPT | MU_TRANSMIT_INTERRUPT | 0x0C)

    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    ldr     r1, [ r0, #AUX_MU_IER_REG ]
    orr     r1, r2
    str     r1, [ r0, #AUX_MU_IER_REG ]
    pop { pc }

@ ------------------------------------------------------------------------------
@ Disable interrupts for UART
@ IMPORTANT: Make sure that UART is enabled or this won't work
@ R0: Interrupt parameters
@ ------------------------------------------------------------------------------
.section .text
uart0_InterruptsDisable:
    push { lr }
    and     r2, r0, #(MU_RECEIVE_INTERRUPT | MU_TRANSMIT_INTERRUPT | 0x0C)
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    ldr     r1, [ r0, #AUX_MU_IER_REG ]
    bic     r1, r2
    str     r1, [ r0, #AUX_MU_IER_REG ]
    pop { pc }

@ ------------------------------------------------------------------------------
@ Copy the bytes of an specified buffer into UART's output buffer
@ IMPORTANT: Buffer must be a power of two to work without problems.
@ Inputs
@   R0, Source
@   R1, Size
@ Outputs
@   None
@ ------------------------------------------------------------------------------
uart0_OutputWrite:
    push { r4, r5, r6, r7, r8, r9, lr }
    @ r0 datum
    @ r1 size
    @ r2 counter
    @ r3 pointer
    mov     r0, r3
    @ r4 head
    ldr     r5, =uart0_TransmitBufferTail
    ldr     r5, [ r5 ]
    @ r5 tail
    ldr     r6, =uart0_TransmitBufferHead
    mov     r8, r6 
    ldr     r6, [ r6 ]

    @ r7 Reference to buffer
    ldr     r7, =uart0_TransmitBuffer

    @ r9 Buffer's size - 1
    mov     r6, #AUX_MU_BUFFER_SIZE
    sub     r6, r6, #1

1:
    add     r1, r2, #1
    and     r1, r1, r6
    cmp     r1, r3
    beq     2f

2:
    pop { r4, r5, r6, r7, r8, r9, pc }


@ ------------------------------------------------------------------------------
@ Read received bytes from UART and saves them in a circular buffer.
@ IMPORTANT: Buffer must be a power of two to work without problems.
@ Inputs
@   None
@ Outputs
@   R0 -> Number of bytes read
@ ------------------------------------------------------------------------------
uart0_Input:
    push { r4, r5, r6, r7, lr }
    // r1 <- datum
    // r2 <- aux that always will be head -> next
    @ Get RX Buffer
    ldr     r5, =uart0_RXBuffer
    @ r3 <- head
    ldr     r3, [ r5, #BUFFER_HEAD ]
    @ r4 <- tail
    ldr     r4, [ r5, #BUFFER_TAIL ]
    @ r5 <- buffer
    add     r5, r5, #BUFFER_REFF
    @ r6 <- device
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    mov     r6, r0
    @ r7 <- buffer's size (1024)
    mov     r7, #AUX_MU_BUFFER_SIZE
    sub     r7, r7, #1
    @ r0 <- counter
    mov     r0, #0
1:
    @ Checks for any value in FIFOs
    ldr     r1, [ r6, #AUX_MU_LSR_REG ]
    tst     r1, #1
    beq     2f
    @ Makes sure that buffer is not full (next_head != tail)
    add     r2, r3, #1
    ands    r2, r2, r7
    cmp     r2, r4
    beq     2f
    @ Gets value from FIFOs and saves byte in buffer
    ldr     r1, [ r6, #AUX_MU_IO_REG ]
    strb    r1, [ r5, r3 ]
    @ Increments counter, updates head and continue
    add     r0, r0, #1
    mov     r3, r2
    b       1b
2:
    @ Saves the new value of head
    sub     r5, r5, #BUFFER_REFF
    str     r3, [ r5, #BUFFER_HEAD ]
    @ If counter is zero, exit without enabling TX interruptions
    cmp     r0, #0
    beq     3f
    @ Enables interrupt for TX
    mov     r4, r0
    mov     r0, #(MU_TRANSMIT_INTERRUPT)
    bl      uart0_InterruptsEnable
    mov     r0, r4
3:
    pop { r4, r5, r6, r7, pc }

@ ------------------------------------------------------------------------------
@ Checks for received bytes in circular buffer and echoes them through UART
@ IMPORTANT: Buffer must be a power of two to work without problems.
@ Inputs
@   None
@ Outputs
@   None
@ ------------------------------------------------------------------------------
uart0_Output:
    push { r4, r5, lr }
    @ r0 <- datum
    @ Get RX Buffer
    ldr     r3, =uart0_RXBuffer
    @ r1 <- tail
    ldr     r1, [ r3, #BUFFER_TAIL ]
    @ r2 <- head
    ldr     r2, [ r3, #BUFFER_HEAD ]
    @ r3 <- buffer
    add     r3, r3, #BUFFER_REFF
    @ r4 <- device
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    mov     r4, r0
    @ r5 <- buffer's size (1024)
    mov     r5, #AUX_MU_BUFFER_SIZE
    sub     r5, r5, #1

    @ Checks for UART availability
    ldr     r0, [ r4, #AUX_MU_LSR_REG ]
    tst     r0, #0x20
    beq     2f
    
    @ Makes sure that buffer is not empty (tail == head)
    cmp     r1, r2
    beq     1f

    @ Gets value from buffer and sends it throught UART
    ldrb    r0, [ r3, r1 ]
    str     r0, [ r4, #AUX_MU_IO_REG ]

    @ Updates tail and exit
    add     r1, r1, #1
    and     r1, r1, r5
    b       2f
1:
    @ Disables interrupt for TX
    mov     r5, r1
    mov     r0, #MU_TRANSMIT_INTERRUPT
    bl      uart0_InterruptsDisable
    mov     r1, r5
2:
    sub     r3, r3, #BUFFER_REFF
    str     r1, [ r3, #BUFFER_TAIL ]
    pop { r4, r5, pc }


.equ AUX_MU_NO_INTERRUPT_PENDING,   0x01
.equ AUX_MU_TRANSMITER_AVAILABLE,   0x02
.equ AUX_MU_RECEIVER_PENDING,       0x04
uart0_InterruptHandler:
    push    { lr }

    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet

    ldr     r1, [r0, #AUX_MU_IIR_REG]
    tst     r1, #AUX_MU_NO_INTERRUPT_PENDING
    bne     2f

    tst     r1, #AUX_MU_RECEIVER_PENDING
    blne    uart0_Input

    tst     r1, #AUX_MU_TRANSMITER_AVAILABLE
    blne    uart0_Output
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
