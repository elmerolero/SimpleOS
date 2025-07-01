.extern uart0_write_bytes
.extern arm_timer_irq_clear

.section .data
.align 1
irq_message: .ascii "IRQ request\r\n"

.section .text
.global interrupt_request
interrupt_request:
    push { r0-r12, lr }
    mrs r0, spsr
    push { r0 }
    ldr     r0, =irq_message
    mov     r1, #13
    bl      uart0_write_bytes
    //bl      arm_timer_irq_clear
    pop { r0 }
    msr spsr_cxsf, r0
    pop { r0-r12, lr }
    subs pc, lr, #4
