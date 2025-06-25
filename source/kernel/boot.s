.section .init
.global _start
_start:
    push { lr }
    bl      mmu_Init
    //bl      interrupts_Init
    pop { pc }

.section .text
stack_Init:
    mov       r0, #0xDB       @ Undefined
    msr       cpsr, r0
    ldr       sp, _undefined_stack
    mov       r0, #0xD7       @ Abort
    msr       cpsr, r0
    ldr       sp, _abort_stack
    mov       r0, #0xD1       @ Fast Interrupt Request
    msr       cpsr, r0
    ldr       sp, _fiq_stack
    mov       r0, #0xD2       @ IRQ
    msr       cpsr, r0
    ldr       sp, _irq_stack
    mov       r0, #0xDF       @ SYS
    msr       cpsr, r0
    ldr       sp, _sys_stack
    mov       r0, #0xD3       @ SVC
    msr       cpsr, r0
    ldr       sp, _init_stack
    bx        lr

_undefined_stack: .word _undefined_stack_end
_abort_stack: .word _abort_stack_end
_irq_stack: .word _irq_stack_end
_fiq_stack: .word _fiq_stack_end
_sys_stack: .word _sys_stack_end
_init_stack: .word _init_stack_end

.include "kernel/include.s"
