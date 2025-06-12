.section .init
.global _start
_start:
    bl      stack_Init
    bl      mmu_Init
    //bl      interrupts_Init
    //bl      clock_manager_init
    
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER_ENABLE | MU_RECEIVER_ENABLE)
    mov     r3, #0
    bl      uart0_Init
    bl      loop


baudrate_speed:
    .word 9600

.section .init
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

.section .data
.align 4
    palabra: .word 24

.section .text
loop:
    mov     r0, #1 
    bl      uart0_read
    cmp     r0, #13
    movne   r1, #1 
    blne    uart0_write
    bne     loop
    mov     r0, #'\r'
    mov     r1, #1 
    bl      uart0_write
    mov     r0, #'\n'
    mov     r1, #1 
    bl      uart0_write
    b       loop

//start_addr:
  //  .word start_second_addr
//.include "devices/uart0_absolute.s"
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
.include "system/mmu/mmu.s"
.include "system/mmu/constants.s"
