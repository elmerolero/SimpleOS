.extern uart0_write_bytes

.section .data
.align 1
undefined_message: .ascii "Undefined instruction\r\n"

.section .text
.global interrupt_undefined
interrupt_undefined:
    push { r0-r12, lr }
    mrs r0, spsr
    push { r0 }
    ldr     r0, =undefined_message
    mov     r1, #23
    bl      uart0_write_bytes
    pop { r0 }
    msr spsr_cxsf, r0
    pop { r0-r12, lr }
    subs pc, lr, #4

