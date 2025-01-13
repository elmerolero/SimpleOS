.section .data
.align 1
prefetch_abort_message: .ascii "Ha ocurrido un error\r\n"

.section .text
.global interrupt_prefetch_abort
interrupt_prefetch_abort:
    push { r0-r12, lr }
    mrs r0, spsr
    push { r0 }
    ldr     r0, =prefetch_abort_message
    mov     r1, #22
    bl      uart_write_bytes
    pop { r0 }
    msr spsr_cxsf, r0
    pop { r0-r12, lr }
    subs pc, lr, #4
