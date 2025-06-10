.section .init
.global _start
_start:
    mov     sp, #0x8000
    bl      interrupts_Init
    bl      stack_Init
    bl      clock_manager_init
    bl      main

.section .text
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
    ldr     r0, baudrate_speed
    mov     r1, #MU_DATA_SIZE_8
    mov     r2, #(MU_RECEIVER_ENABLE | MU_TRANSMITER_ENABLE)
    mov     r3, #MU_INTERRUPTS_DISABLE
    bl      uart0_Init

    bl      frameBuffer_GetDimmensions

    mov     r4, r1
    mov     r1, #16
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

baudrate_speed:
    .word 9600


//start_addr:
  //  .word start_second_addr
.include "devices/mailbox_interface/mailbox_interface.s"
.include "devices/mailbox_interface/mailbox_tags.s"
.include "lib/math.s"
.include "lib/utils.s"
.include "devices/gpio.s"
.include "devices/uart0.s"
.include "interrupts/interrupts.s"
.include "devices/arm_timer.s"
.include "devices/clock_manager.s"
.include "graphics/frame_buffer.s"
