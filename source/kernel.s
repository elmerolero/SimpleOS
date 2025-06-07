.section .init
.global _start
_start:
    mov     sp, #0x8000
    //bl      mmu_Init
    bl      stack_Init
    bl      interrupts_Init
    mov     r0, #8192
    add     r0, #1024
    add     r0, #384
    add     r0, #256
    add     r0, #128
    mov     r1, #3
    mov     r2, #(MU_RECEIVE_INTERRUPT_ENABLE | MU_TRANSMIT_INTERRUPT_ENABLE)
    bl      uart0_Init

    mov     r0, #'A'
    bl      uart0_write
    mov     r0, #'\r'
    bl      uart0_write
    mov     r0, #'\n'
    bl      uart0_write

    mov     r0, #10
    mov     r1, #10
    bl      uart0_u32_write

    b       loop

loop:
    bl      uart0_read
    cmp     r0, #13
    blne    uart0_write
    bne     loop
    mov     r0, #'\r'
    bl      uart0_write
    mov     r0, #'\n'
    bl      uart0_write
    b       loop

.section .init
stack_Init:
    mov       r0, #0xDB       @ Undefined
    msr       cpsr, r0
    ldr       sp, =_undefined_stack_end
    mov       r0, #0xD7       @ Abort
    msr       cpsr, r0
    ldr       sp, =_abort_stack_end
    mov       r0, #0xD1       @ Fast Interrupt Request
    msr       cpsr, r0
    ldr       sp, =_fiq_stack_end
    mov       r0, #0xD2       @ IRQ
    msr       cpsr, r0
    ldr       sp, =_irq_stack_end
    mov       r0, #0xDF       @ SYS
    msr       cpsr, r0
    ldr       sp, =_sys_stack_end
    mov       r0, #0xD3       @ SVC
    msr       cpsr, r0
    bx        lr

//start_addr:
  //  .word start_second_addr

.include "lib/math.s"
.include "lib/utils.s"
.include "devices/gpio.s"
.include "devices/uart0.s"
.include "interrupts/interrupts.s"
.include "devices/arm_timer.s"
