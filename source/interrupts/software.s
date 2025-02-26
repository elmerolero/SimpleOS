.extern aux_mini_uart_write_bytes

.section .data
.align 1
.global interrupt_message
software_interrupt_message: .ascii "Software interrupt\r\n"

.section .text
.global interrupt_software
interrupt_software:
    push { r0-r12, lr }

    ldr     r0, =software_interrupt_message
    mov     r1, #20
    bl      aux_mini_uart_write_bytes

    pop { r0-r12, pc }
