.include "lib/utils.s"
.include "lib/math.s"
.include "devices/gpio.s"
.include "devices/uart0.s"
.include "devices/arm_timer.s"
.include "graphics/frame_buffer.s"
.include "interrupts/interrupts.s"
.include "lib/posix.s"

.section .data

.section .init
.global _start
_start:
    mov     sp, #0x8000
    bl      stack_Init
    bl      interrupts_Init
    b       main

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

.section .text
main:
    ldr     r0, =96153
    mov     r1, #3
    mov     r2, #(MU_RECEIVE_INTERRUPT_ENABLE | MU_TRANSMIT_INTERRUPT_ENABLE)
    bl      uart0_Init

    ldr     r0, =uart0_write
    ldr     r1, =buffer0
    mov     r2, #5
    bl      write

    mov     r1, #10
    bl      uart0_u32_write

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
