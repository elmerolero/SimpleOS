
.equ MAILBOX_BASE,      0x2000B880
.equ MAILBOX_READ,      0x00
.equ MAILBOX_POLL,      0x10
.equ MAILBOX_SENDER,    0x14
.equ MAILBOX_STATUS,    0x18
.equ MAILBOX_CONFIG,    0x1C
.equ MAILBOX_WRITE,     0x20

.section .text
mailbox_write:
    tst     r0, #0x0F           /* r0 -> mensaje */
    movne   pc, lr
    cmp     r1, #0x0F           /* r1 -> canal */
    movhi   pc, lr

    push { lr }
    mov     r2, r0
    ldr     r0, =MAILBOX_BASE
mailbox_waitWrite:
    ldr     r3, [ r0, #MAILBOX_STATUS ]
    tst     r3, #0x80000000
    bne     mailbox_waitWrite
    add     r2, r1
    str     r2, [ r0, #MAILBOX_WRITE ]
    pop  { pc }

.section .text
mailbox_read:
    cmp     r0, #0x0F
    movhi   pc, lr
    
    push { lr }
    mov     r1, r0
    ldr     r0, =MAILBOX_BASE
mailbox_waitRead:
    ldr     r3, [ r0, #MAILBOX_STATUS ]
    tst     r3, #0x40000000
    bne     mailbox_waitRead
    ldr     r3, [ r0, #MAILBOX_READ ]
    and     r2, r3, #0x0F
    teq     r2, r1 
    bne     mailbox_waitRead
    and     r0, r3, #0xfffffff0
    pop  { pc }
