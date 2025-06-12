.section .init
.global _start
_start:
    bl      stack_Init
    //bl      mmu_Init
    //bl      interrupts_Init
    //bl      clock_manager_init
    
    /*ldr     r0, =main
    mov     r1, #16
    bl      uart0_u32_write
    mov     r0, #'\n'
    mov     r1, #0
    bl      uart0_write
    mov     r0, #'\r'
    mov     r1, #0
    bl      uart0_write*/

    mov     r0, #0xC000      @ Page table start
    ldr     r1, main_table           @ Gets main table data and saves it
    str     r1, [ r0 ]
    mov     r1, #0x10000    @ Second table start
    ldr     r2, secondary_table_addr @ Gets second table data
    mov     r4, #0
1:
    ldr     r3, [ r2, r4, lsl #2 ]
    str     r3, [ r1, r4, lsl #2 ]
    add     r4, r4, #1
    cmp     r4, #11
    bls     1b

    mov     r0, #0
    mcr     p15, 0, r0, c2, c0, 2           @ TTBCR = 0 → usar solo TTBR0
    mov     r0, #0xC000                     @ Page table start
    mcr     p15, 0, r0, c2, c0, 0           @ tlb base
    mov     r0, #0
    mcr     p15, 0, r0, c8, c7, 0           @ invalidate unified TLB
    mov     r0, #0xFFFFFFFF
    mcr     p15, 0, r0, c3, c0, 0           @ DACR = todo en modo manager
    mrc     p15, 0, r0, c1, c0, 0           @ leer control register
    mov     r0, #0
    mcr     p15, 0, r0, c7, c5, 0           @ Invalidate I-cache
    bic     r0, r0, #(1 << 12)              @ opcional: deshabilita cachés
    bic     r0, r0, #(1 << 2)
    bic     r0, r0, #(1 << 28)              @ TEX remap OFF (bit 28 = 0)
    orr     r0, r0, #MMU_C1_MBIT_ENABLE     @ habilitar MMU (bit 0)
    mcr     p15, 0, r0, c1, c0, 0           @ escribir control register
    
    ldr     r0, baudrate_speed
    mov     r1, #3
    mov     r2, #(MU_TRANSMITER_ENABLE | MU_RECEIVER_ENABLE)
    mov     r3, #0
    bl      uart0_Init
    bl      loop


baudrate_speed:
    .word 9600

palabra_addr:
    .word 0x17000

start_main_addr:
    .word 0xC000

start_second_addr:
    .word 0x10000

secondary_table_addr:
    .word secondary_table

main_table: 
    .word  0x10000 | MMU_L1_COARSE_ENTRY

secondary_table:
    .word (0x00011000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 0 (VA 0x00001000) (und)
    .word (0x00012000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 1 (VA 0x00002000) (abt)
    .word (0x00013000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 2 (VA 0x00003000) (irq)
    .word (0x00014000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 3 (VA 0x00004000) (fiq)
    .word (0x00015000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 4 (VA 0x00005000) (sys)
    .word (0x00016000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 5 (text)
    .word (0x00017000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 6 (data)
    .word (0x00007000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 7 (VA 0x00007000) (init_stack)
    .word (0x00008000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 8 (VA 0x00008000) (.init)
    .word (0x2000B000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 9 (VA FOR DEVICES TEMPORARY) Interrupts & Mailbox
    .word (0x20200000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada A (VA FOR DEVICES TEMPORARY) GPIO
    .word (0x20215000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada B (VA FOR DEVICES TEMPORARY) UART
    .word (0x20215000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada B (VA FOR DEVICES TEMPORARY) UART

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
.include "system/mmu/constants.s"
