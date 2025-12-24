.equ DMA_DEVICES,           0x00
.equ INTERRUPT_DEVICES,     0x01
.equ ARM_TIMER_DEVICES,     0x02
.equ MAILBOX_DEVICES,       0x03
.equ CLOCK_MANAGER_DEVICES, 0x04
.equ GPIO_DEVICES,          0x05
.equ AUXILIARY_DEVICES,     0x06
.equ EMMC_DEVICES,          0x07

.section .text
devices_AddressGet:
    ldr     r1, =devices_mmu
    ldr     r0, [ r1, r0, lsl #2 ]
    bx      lr

.section .data
devices:
    .word 0x20007000 // DMA
    .word 0x2000B200 // Interrupts
    .word 0x2000B400 // ARM Timer
    .word 0x2000B880 // Mailbox
    .word 0x20101000 // Clock Manager
    .word 0x20200000 // GPIO
    .word 0x20215000 // Auxiliary
    .word 0x20300000 // EMMC

devices_mmu:
    .word 0x00100000 // DMA
    .word 0x00101200 // Interrupts
    .word 0x00101400 // ARM Timer
    .word 0x00101880 // Mailbox
    .word 0x00102000 // Clock Manager
    .word 0x00103000 // GPIO
    .word 0x00104000 // Auxiliaries
    .word 0x00105000 // EMMC
    

.section .data
devicess_AddressStart: .word 0x1000000
devicess_AddressEnd:   .word 0x1FFFFFF


