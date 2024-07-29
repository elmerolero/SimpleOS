.include "gpio.s"

.equ AUX_BASE,    0x20215000
.equ UART_BASE,   0x20201000

.equ UART_DR,        0x00
.equ UART_RSRECT,    0x04
.equ UART_FR,        0x18
.equ UART_ILPR,      0x20
.equ UART_IBRD,      0x24
.equ UART_FBRD,      0x28
.equ UART_LCRH,      0x2c
.equ UART_CR ,       0x30
.equ UART_IFLS ,     0x34
.equ UART_IMSC,      0x38
.equ UART_RIS ,      0x3C
.equ UART_MIS ,      0x40
.equ UART_ICR,       0x44
.equ UART_DMCR,      0x48
.equ UART_ITCR,      0x80
.equ UART_ITIP,      0x84
.equ UART_ITOP,      0x88
.equ UART_TDR,       0x8C

.equ AUX_ENABLES,     0x20215004
.equ AUX_MU_IO_REG,   0x20215040
.equ AUX_MU_IER_REG,  0x20215044
.equ AUX_MU_IIR_REG,  0x20215048
.equ AUX_MU_LCR_REG,  0x2021504C
.equ AUX_MU_MCR_REG,  0x20215050
.equ AUX_MU_LSR_REG,  0x20215054
.equ AUX_MU_MSR_REG,  0x20215058
.equ AUX_MU_SCRATCH,  0x2021505C
.equ AUX_MU_CNTL_REG, 0x20215060
.equ AUX_MU_STAT_REG, 0x20215064
.equ AUX_MU_BAUD_REG, 0x20215068
.equ MINI_UART_8BIT,  0x1
.equ MINI_UART_7BIT,  0x0

.section .text
uart_init:
    push    { lr }
    
    // Registers initialization
    ldr     r2, =AUX_ENABLES
    mov     r1, #1
    str     r1, [r2]
    ldr     r2, =AUX_MU_IER_REG
    mov     r1, #0
    str     r1, [r2]
    ldr     r2, =AUX_MU_CNTL_REG
    str     r1, [r2]
    ldr     r2, =AUX_MU_LCR_REG
    mov     r1, #3
    str     r1, [r2]
    ldr     r2, =AUX_MU_MCR_REG
    mov     r1, #0
    str     r1, [r2]
    ldr     r2, =AUX_MU_IER_REG
    str     r1, [r2]
    ldr     r2, =AUX_MU_IIR_REG
    mov     r1, #0xC6
    str     r1, [r2]
    ldr     r2, =AUX_MU_BAUD_REG
    mov     r1, #324
    str     r1, [r2]

    // Set ALT FUNC 5 on pins 14 and 15
    mov     r0, #14
    mov     r1, #GPIO_ALTF5
    bl      gpio_setMode

    mov     r0, #15
    mov     r1, #GPIO_ALTF5
    bl      gpio_setMode

    //
    ldr     r2, =GPIO_GPPUD
    mov     r1, #0
    str     r1, [ r2 ]

    mov     r0, #150
1:
    subs    r0, #1
    bne     1b

    ldr     r2, =GPIO_GPPUDCLK0
    mov     r1, #3
    lsl     r1, #14
    str     r1, [ r2 ]

    mov     r0, #150
2:
    subs    r0, #1
    bne     2b

    mov     r1, #0
    str     r1, [ r2 ]

    ldr     r2, =AUX_MU_CNTL_REG
    mov     r1, #3
    str     r1, [ r2 ]

    pop     { pc }

    

    /*mov     r3, #0
    str     r3, [ r1, #GPIO_GPPUDCLK0 ]



    ldr     r2, =AUX_MU_CNTL_REG
    mov     r1, #2
    str     r1, [r2]*/

    /*ldr     r1, =GPIO_BASE
    ldr     r2, =UART_BASE
    mov     r3, #0
    str     r3, [ r2, #UART_CR ]

    str     r3, [ r1, #GPIO_GPPUD ]
    bl      uart_delay

    mov     r3, #3
    lsl     r3, #14
    str     r3, [ r1, #GPIO_GPPUDCLK0 ]
    bl      uart_delay 

    mov     r3, #0
    str     r3, [ r1, #GPIO_GPPUDCLK0 ]
    
    ldr     r3, =0x7FF
    str     r3, [ r2, #UART_ICR ]

    mov     r3, #1
    str     r3, [ r2, #UART_IBRD ]
    mov     r3, #40
    str     r3, [ r2, #UART_FBRD ]

    mov     r3, #70
    str     r3, [ r2, #UART_LCRH ]

    ldr     r3, =0x07F2
    str     r3, [ r2, #UART_IMSC ]

    ldr     r3, =0x0301
    str     r3, [ r2, #UART_CR ]*/

    pop     { pc }

.section .text
uart_delay:
    push    { lr }
    mov     r0, #0
uart_delayLoop:
    add     r0, #1
    cmp     r0, #255
    bls     uart_delayLoop
    pop     { pc }



.section .text
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
