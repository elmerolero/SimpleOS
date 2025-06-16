.equ INTERRUPT_DEVICES, 0x00
.equ MAILBOX_DEVICES,   0x01
.equ GPIO_DEVICES,      0x02
.equ AUX_DEVICES,       0x03

.section .text
devices_AddressGet:
    ldr     r1, =devices_mmu
    ldr     r0, [ r1, r0, lsl #2 ]
    bx      lr

.section .data

devices:
    .word 0x2000B200 // Interrupts
    .word 0x2000B880 // Mailbox
    .word 0x20200000 // GPIO
    .word 0x20215000 // Auxiliary*/

devices_mmu:
    .word 0xD200 // Interrupts
    .word 0xD880 // Mailbox
    .word 0xE000 // GPIO
    .word 0xF000 // Auxiliary
