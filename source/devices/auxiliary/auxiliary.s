.include "devices/devices.s"

// Auxiliary registers
.equ AUX_IRQ_REG, 0x00
.equ AUX_ENABLE_REG, 0x04

// To indicate which device enable from auxiliary
.equ AUX_UART_ENABLE,   0x01
.equ AUX_SPI1_ENABLE,   0x02
.equ AUX_SPI2_ENABLE,   0x04

.section .text
auxiliary_Enable:
    push    { lr }
    and     r2, r0, #(AUX_UART_ENABLE | AUX_SPI1_ENABLE | AUX_SPI2_ENABLE)
    mov     r0, #AUX_DEVICES
    bl      devices_AddressGet  
    ldr     r1, [r0, #AUX_ENABLE_REG]
    orr     r1, r1, r2
    str     r1, [r0, #AUX_ENABLE_REG]
    pop     { pc }
