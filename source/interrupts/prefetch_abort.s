.extern uart0_write_bytes

.section .data
.align 1
prefetch_abort_message: .ascii "Interrupción de memoria\r\n"

.section .text
.global interrupt_prefetch_abort
interrupt_prefetch_abort:
    push { r0-r12, lr }
    mrs r0, spsr
    push { r0 }

    // Show message
    ldr     r0, =prefetch_abort_message
    mov     r1, #25
    bl      uart0_write_bytes

    // Get memory status
    bl      mmu_ErrorCodeGet
    mov     r1, #16
    bl      utils_u32_write
    mov     r0, #'\r'
    bl      uart0_Write
    mov     r0, #'\n'
    bl      uart0_Write

    // Get memory address
    bl      mmu_ErrorAdressGet
    mov     r1, #16
    bl      utils_u32_write
    mov     r0, #'\r'
    bl      uart0_Write
    mov     r0, #'\n'
    bl      uart0_Write

    pop { r0 }
    msr spsr_cxsf, r0
    pop { r0-r12, lr }
    bx  lr
