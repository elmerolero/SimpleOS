.section .text
.global interrupt_reset
interrupt_reset:
    b interrupt_reset

.section .text
.global interrupt_unused
interrupt_unused:
    b interrupt_unused
