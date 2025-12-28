/* Operating System for Raspberry Pi */
/* Mailbox Interface */
/* Ismael Salas López */

// Mailbox address and offsets
.equ MAILBOX_READ,      0x00
.equ MAILBOX_POLL,      0x10
.equ MAILBOX_SENDER,    0x14
.equ MAILBOX_STATUS,    0x18
.equ MAILBOX_CONFIG,    0x1C
.equ MAILBOX_WRITE,     0x20

// Mailbox status
.equ MAILBOX_STATUS_FULL,      0x80000000
.equ MAILBOX_STATUS_EMPTY,     0x40000000
.equ MAILBOX_STATUS_LEVEL,     0x400000FF

// Request buffer format
.equ REQUEST_BUFFER_SIZE,           0x00
.equ REQUEST_BUFFER_CODE,           0x04
.equ REQUEST_BUFFER_TAG,            0x08
.equ REQUEST_BUFFER_ANSWER_SIZE,    0x0C
.equ REQUEST_BUFFER_REQUEST_SIZE,   0x10
.equ REQUEST_BUFFER_SENT_BYTES,     0x14
.equ REQUEST_BUFFER_VALUE,          0x28

@ ------------------------------------------------------------------------------
@ Writes into mailbox
@ r0: Buffer address with the message to send through mailbox
@ r1: Mailbox channel
@ ------------------------------------------------------------------------------
.section .text
mailbox_write:
    tst     r0, #0x0F
    bxne    lr
    cmp     r1, #0x0F
    bxhi    lr

    push { lr }
    add     r2, r0, #0x40000000  // Backs up the address in r2 but adds that amount to align with gpu
    mov     r3, r1               // Backs up the channel in r3
    mov     r0, #MAILBOX_DEVICES
    bl      devices_GetAddress
1:
    ldr     r1, [ r0, #MAILBOX_STATUS ]
    tst     r1, #MAILBOX_STATUS_FULL
    bne     1b
    add     r2, r2, r3
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
    mov     r2, r0
    mov     r0, #MAILBOX_DEVICES
    bl      devices_GetAddress
1:
    ldr     r1, [ r0, #MAILBOX_STATUS ]
    tst     r1, #MAILBOX_STATUS_EMPTY
    bne     1b
    ldr     r1, [ r0, #MAILBOX_READ ]
    and     r3, r1, #0x0F
    teq     r3, r2
    bne     1b
    and     r0, r1, #0xfffffff0
    pop  { pc }
