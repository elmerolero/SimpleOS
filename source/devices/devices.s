.equ INTERRUPT_DEVICES,     0x00
.equ ARM_TIMER_DEVICES,     0x01
.equ MAILBOX_DEVICES,       0x02
.equ CLOCK_MANAGER_DEVICES, 0x03
.equ GPIO_DEVICES,          0x04
.equ AUXILIARY_DEVICES,     0x05

.section .text
devices_AddressGet:
    ldr     r1, =devices_mmu
    ldr     r0, [ r1, r0, lsl #2 ]
    bx      lr

.section .data
devices:
    .word 0x2000B200 // Interrupts
    .word 0x2000B400 // ARM Timer
    .word 0x2000B880 // Mailbox
    .word 0x20101000 // Clock Manager
    .word 0x20200000 // GPIO
    .word 0x20215000 // Auxiliary

devices_mmu:
    .word 0x00100200 // Interrupts
    .word 0x00100400 // ARM Timer
    .word 0x00100880 // Mailbox
    .word 0x00101000 // Clock Manager
    .word 0x00102000 // GPIO
    .word 0x00103000 // Auxiliary

.section .data
devicess_AddressStart: .word 0x1000000
devicess_AddressEnd:   .word 0x1FFFFFF


