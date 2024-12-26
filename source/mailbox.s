// Mailbox address and offsets
.equ MAILBOX_BASE,      0x2000B880
.equ MAILBOX_READ,      0x00
.equ MAILBOX_POLL,      0x10
.equ MAILBOX_SENDER,    0x14
.equ MAILBOX_STATUS,    0x18
.equ MAILBOX_CONFIG,    0x1C
.equ MAILBOX_WRITE,     0x20

// Mailbox channels
.equ MAILBOX_CHANNEL_POWER_MANAGEMENT,      0x00
.equ MAILBOX_CHANNEL_FRAMEBUFFER_CHANGE,    0x01
.equ MAILBOX_CHANNEL_VIRTUAL_UART,          0x02
.equ MAILBOX_CHANNEL_VCHIQ,                 0x03
.equ MAILBOX_CHANNEL_LEDS,                  0x04
.equ MAILBOX_CHANNEL_BUTTONS,               0x05
.equ MAILBOX_CHANNEL_TOUCHSCREEN,           0x06
.equ MAILBOX_CHANNEL_UNUSED,                0x07
.equ MAILBOX_CHANNEL_TAGS_ARM_TO_VC,        0x08
.equ MAILBOX_CHANNEL_TAGS_VC_TO_ARM,        0x09

// Mailbox status
.equ MAILBOX_STATUS_FULL,      0x80000000
.equ MAILBOX_STATUS_EMPTY,     0x40000000
.equ MAILBOX_STATUS_LEVEL,     0x400000FF

@ ------------------------------------------------------------------------------
@ Writes into mailbox 0
@ r0: Message to send through mailbox
@ r1: Channel
@ ------------------------------------------------------------------------------
.section .text
mailbox_write:
    tst     r0, #0x0F
    bxne    lr
    cmp     r1, #0x0F
    bxhi    lr

    push { lr }
    mov     r2, r0
    ldr     r0, =MAILBOX_BASE
1:
    ldr     r3, [ r0, #MAILBOX_STATUS ]
    tst     r3, #MAILBOX_STATUS_FULL
    bne     1b
    add     r2, r1
    str     r2, [ r0, #MAILBOX_WRITE ]
    pop  { pc }

@ ------------------------------------------------------------------------------
@ Reads from mailbox 0
@ r0: Channel
@ ------------------------------------------------------------------------------
.section .text
mailbox_read:
    cmp     r0, #0x0F
    bxhi    lr
    
    push { lr }
    mov     r1, r0
    ldr     r0, =MAILBOX_BASE
1:
    ldr     r3, [ r0, #MAILBOX_STATUS ]
    tst     r3, #MAILBOX_STATUS_EMPTY
    bne     1b
    ldr     r3, [ r0, #MAILBOX_READ ]
    and     r2, r3, #0x0F
    teq     r2, r1 
    bne     1b
    and     r0, r3, #0xfffffff0
    pop  { pc }
