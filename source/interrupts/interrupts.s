.include "interrupts/reset.s"
.include "interrupts/undefined.s"
.include "interrupts/software.s"
.include "interrupts/prefetch_abort.s"
.include "interrupts/data_abort.s"
.include "interrupts/interrupt_request.s"
.include "interrupts/fast_interrupt_request.s"

.equ INTERRUPT_BASE,        0x2000B200
.equ IRQ_BASIC_PENDING,     0x00
.equ IRQ_PENDING_1,         0x04
.equ IRQ_PENDING_2,         0x08
.equ FIQ_CONTROL,           0x0C
.equ ENABLE_IRQS_1,         0x10
.equ ENABLE_IRQS_2,         0x14
.equ ENABLE_BASIC_IRQS,     0x18
.equ DISABLE_IRQS_1,        0x1C
.equ DISABLE_IRQS_2,        0x20
.equ DISABLE_BASIC_IRQS,    0x24

.equ ARM_TIMER_IRQ_PENDING,             0x01
.equ ARM_MAILBOX_IRQ_PENDING,           0x02
.equ ARM_DOORBEL0_IRQ_PENDING,          0x03
.equ ARM_DOORBEL1_IRQ_PENDING,          0x04
.equ GPU0_HALTED_IRQ_PENDING,           0x05
.equ GPU1_HALTED_IRQ_PENDING,           0x06
.equ ILLEGAL_ACCESS_TYPE0_IRQ_PENDING,  0x07
.equ ILLEGAL_ACCESS_TYPE1_IRQ_PENDING,  0x08

.section .text
.global interrupts_init
interrupts_init:
    ldr     r0, =interrupt_vector_table
    ldr     r1, =0x00
    
    ldmia   r0!, { r2, r3, r4, r5, r6, r7, r8, r9 }
    stmia   r1!, { r2, r3, r4, r5, r6, r7, r8, r9 }   
    ldmia   r0!, { r2, r3, r4, r5, r6, r7, r8, r9 }
    stmia   r1!, { r2, r3, r4, r5, r6, r7, r8, r9 }  

    ldr     r0, =INTERRUPT_BASE
    mov     r1, #1
    lsl     r1, r1, #ARM_TIMER_IRQ_PENDING
    str     r1, [r0, #ENABLE_BASIC_IRQS]

    bx      lr

.section .text
interrupt_vector_table:
    ldr     pc, _interrupt_reset
    ldr     pc, _interrupt_undefined
    ldr     pc, _interrupt_software
    ldr     pc, _interrupt_prefetch_abort
    ldr     pc, _interrupt_data_abort
    ldr     pc, _interrupt_unused
    ldr     pc, _interrupt_request
    ldr     pc, _interrupt_fast_request


_interrupt_reset:          
    .word interrupt_reset
_interrupt_undefined:      
    .word interrupt_undefined
_interrupt_software:        
    .word interrupt_software
_interrupt_prefetch_abort:  
    .word interrupt_prefetch_abort
_interrupt_data_abort:      
    .word interrupt_data_abort
_interrupt_unused:
    .word interrupt_unused
_interrupt_request:         
    .word interrupt_request
_interrupt_fast_request:    
    .word interrupt_fast_request
