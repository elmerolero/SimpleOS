.include "devices/auxiliary/auxiliary.s"

.section .data
.init_ptr:  .word uart0_Init
//.read_ptr:  .word uart0_Read
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
uart0_BlockingRead:
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
uart0_BlockingWrite:
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
@ Puts a byte into buffer
@ Inputs
@   R0 - Byte to send
@ Outputs
@   None
@ ------------------------------------------------------------------------------
uart0_PutByte:
    push { r4, r5, lr }
    @ Gets buffer structure
    ldr     r4, =uart0_TXBuffer
    @ r2 <- Head
    ldr     r2, [ r4, #BUFFER_HEAD ]
    @ r3 <- Tail
    ldr     r3, [ r4, #BUFFER_TAIL ]
    @ r4 <- Buffer
    add     r4, r4, #BUFFER_REFF
    @ r5 <- Buffer's size
    mov     r5, #AUX_MU_BUFFER_SIZE
    sub     r5, #1
    @ Checks for buffer availability (head -> next != tail)
    add     r1, r2, #1
    and     r1, r1, r5
    cmp     r1, r3
    beq     1f
    @ Stores the byte, updates head and enables TX Interrupts
    strb    r0, [ r4, r2 ]
    sub     r4, r4, #BUFFER_REFF
    str     r1, [ r4, #BUFFER_HEAD ]
    mov     r0, #MU_TRANSMIT_INTERRUPT
    bl      uart0_InterruptsEnable
1:
    mov     r0, #0
    pop { r4, r5, pc }

@ ------------------------------------------------------------------------------
@ Interface function u32 write(const u8 buff[count], u32 count)
@ Copy the bytes of an specified buffer into UART's output buffer
@ IMPORTANT: UART's buffer must be a power of two to work without problems.
@ Inputs
@   R0, Source
@   R1, Size
@ Outputs
@   R0, Count of bytes written in buffer
@ ------------------------------------------------------------------------------
uart0_Write:
    push { r4, r5, r6, r7, lr }
    cmp     r0, #0
    cmphi   r1, #0
    blo     2f
    @ r0 <- Counter
    @ r1 <- Size
    @ r2 <- Datum
    @ r3 <- Source
    mov     r3, r0
    @ Gets buffer structure
    ldr     r6, =uart0_TXBuffer
    @ r4 <- Head
    ldr     r4, [ r6, #BUFFER_HEAD ]
    @ r5 <- Tail
    ldr     r5, [ r6, #BUFFER_TAIL ]
    @ r6 <- Reference to circular buffer
    add     r6, r6, #BUFFER_REFF
    @ r7 <- Buffer's size - 1
    mov     r7, #AUX_MU_BUFFER_SIZE
    sub     r7, r7, #1
    @ r0 <- Counter
    mov     r0, #0
1:
    @ Checks for buffer availability (head -> next != tail)
    add     r2, r4, #1
    and     r2, r2, r7
    cmp     r2, r5
    beq     2f

    @ Copy the item from source to buffer
    ldrb    r2, [ r3, r0 ]
    strb    r2, [ r6, r4 ]

    @ Increments counter, updates head and decrements size
    add     r0, r0, #1
    add     r4, r4, #1
    and     r4, r4, r7
    subs    r1, r1, #1
    bne     1b

    @ Saves head
    sub     r6, r6, #BUFFER_REFF
    str     r4, [ r6, #BUFFER_HEAD ]

    @ Checks if enable interruptions for TX (count > 0)
    cmp     r0, #0
    beq     2f

    @ Enable transmit interrupts
    mov     r3, r0
    mov     r0, #MU_TRANSMIT_INTERRUPT
    bl      uart0_InterruptsEnable
    mov     r3, r0
2:
    pop { r4, r5, r6, r7, pc }


@ ------------------------------------------------------------------------------
@ Read received bytes from UART and saves them in a circular buffer.
@ IMPORTANT: Buffer must be a power of two to work without problems.
@ Inputs
@   None
@ Outputs
@   None
@ ------------------------------------------------------------------------------
uart0_Input:
    push { r4, r5, r6, lr }
    @ Get device to be used (aux mini UART)
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    @ Get RX Buffer
    ldr     r4, =uart0_RXBuffer
    @ r1 <- datum and aux variable that always will be head -> next
    @ r2 <- head
    ldr     r2, [ r4, #BUFFER_HEAD ]
    @ r3 <- tail
    ldr     r3, [ r4, #BUFFER_TAIL ]
    @ r4 <- buffer
    add     r4, r4, #BUFFER_REFF
    @ r5 <- device
    mov     r5, r0
    @ r5 <- buffer's size (1024)
    mov     r6, #AUX_MU_BUFFER_SIZE
    sub     r6, r6, #1
    @ r0 <- counter
    mov     r0, #0
1:
    @ Checks for any value in FIFOs
    ldr     r1, [ r5, #AUX_MU_LSR_REG ]
    tst     r1, #1
    beq     2f
    @ Makes sure that buffer is not full (next_head != tail)
    add     r1, r2, #1
    and     r1, r1, r6
    cmp     r1, r3
    beq     2f
    @ Gets value from FIFOs and saves byte in buffer
    ldrb    r1, [ r5, #AUX_MU_IO_REG ]
    strb    r1, [ r4, r2 ]
    @ Increments counter, updates head and continue
    add     r0, r0, #1
    add     r2, r2, #1
    ands    r2, r2, r6
    b       1b
2:
    @ Saves the new value of head
    sub     r4, r4, #BUFFER_REFF
    str     r2, [ r4, #BUFFER_HEAD ]
    @ If counter is zero, exit without enabling TX interrupts
    cmp     r0, #0
    beq     3f
    @ Enables interrupt for TX
    mov     r0, #MU_TRANSMIT_INTERRUPT
    bl      uart0_InterruptsEnable
3:
    mov     r0, #0
    pop { r4, r5, r6, pc }

@ ------------------------------------------------------------------------------
@ Checks for received bytes in circular buffer and echoes them through UART
@ IMPORTANT: Buffer must be a power of two to work without problems.
@ Inputs
@   None
@ Outputs
@   None
@ ------------------------------------------------------------------------------
uart0_TXHandler:
    push { r4, r5, lr }
    @ r0 <- datum
    mov     r0, #AUXILIARY_DEVICES
    bl      devices_AddressGet
    @ Get RX Buffer
    ldr     r3, =uart0_TXBuffer
    @ r1 <- tail
    ldr     r1, [ r3, #BUFFER_TAIL ]
    @ r2 <- head
    ldr     r2, [ r3, #BUFFER_HEAD ]
    @ r3 <- buffer
    add     r3, r3, #BUFFER_REFF
    @ r4 <- device
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
    strb    r0, [ r4, #AUX_MU_IO_REG ]

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
    blne    uart0_TXHandler
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
    bl      uart0_BlockingWrite
    add     r5, #1
    b       1b
2:
    pop { r4, r5, pc }
