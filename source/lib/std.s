.section .text
write:
    cmp     r2, #0
    bxeq   lr

    push { r4, r5, r6, r7, lr }
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2
    mov     r7, #0
1:
    ldrb    r0, [ r5, r7 ]
    blx     r4
    add     r7, #1
    subs    r6, r6, #1
    bhi     1b

    mov     r0, r7
    pop { r4, r5, r6, r7, pc }
