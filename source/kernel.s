
.section .init
.global _start
_start:
    ldr     sp, und_stack
    bl      mmu_Init
    //bl      stack_Init
    //bl      interrupts_Init
    ldr     r0, speed
    mov     r1, #3
    bl      uart0A_Init
    ldr     r0, secondary_table
    mov     r1, #16
    bl      uart0A_u32_write

    b       loop

loop:
    bl      uart0A_read
    cmp     r0, #13
    blne    uart0A_write
    bne     loop
    mov     r0, #'\r'
    bl      uart0A_write
    mov     r0, #'\n'
    bl      uart0A_write
    b       loop
    /*ldr     r0, =mmu_Init
    add     r0, r0, #0x8000
    mov     lr, pc
    bx      r0
    ldr     sp, =_sys_stack_end
    bl      stack_Init
    bl      interrupts_Init
    bl      main*/

speed: .word 96153
und_stack: .word 0x8000//_undefined_stack_end

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

.include "system/mmu/mmu.s"
.include "lib/math.s"
.include "devices/uart0_absolute.s"
.include "interrupts/interrupts.s"
.include "devices/arm_timer.s"


/* .section .text
main:
    ldr     r0, =96153
    mov     r1, #3
    mov     r2, #(MU_RECEIVE_INTERRUPT_ENABLE | MU_TRANSMIT_INTERRUPT_ENABLE)
    bl      uart0A_Init

    //ldr     r0, =uart0_write
    //ldr     r1, =buffer0
    //mov     r2, #5
    //bl      write

    ldr     r0, =_page_table_start
    ldr     r0, [r0]
    mov     r1, #16
    bl      uart0A_u32_write*/
