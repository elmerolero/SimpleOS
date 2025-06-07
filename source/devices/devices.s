.section .text
devices_AddressGet:
    ldr     r1, =devices
    ldr     r0, [ r1, r0, lsl #2 ]
    bx      lr

.equ INTERRUPT_DEVICES, 0x00
.equ GPIO_DEVICES,      0x01
.equ AUX_DEVICES,       0x02

.section .data
mmu_enabled:
    .word 0

devices:
    .word 0x2000B200 // Interrupts
    .word 0x20200000  // GPIO
    .word 0x20215000  // Auxiliary
