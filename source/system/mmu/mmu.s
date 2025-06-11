.include "system/mmu/constants.s"

.section .init
mmu_Init:
    ldr     r0, start_main_addr      @ Page table start
    ldr     r1, main_table           @ Gets main table data and saves it
    str     r1, [ r0 ]
    ldr     r1, start_second_addr    @ Second table start
    ldr     r2, secondary_table_addr @ Gets second table data
    mov     r4, #0
1:
    ldr     r3, [ r2, r4, lsl #2 ]
    str     r3, [ r1, r4, lsl #2 ]
    add     r4, r4, #1
    cmp     r4, #10
    bls     1b
    mov     r0, #0
    mcr     p15, 0, r0, c2, c0, 2  @ TTBCR = 0 → usar solo TTBR0
    ldr     r0, start_main_addr      @ Page table start
    mcr     p15, 0, r0, c2, c0, 0 @ tlb base
    mov     r0, #0
    mcr     p15, 0, r0, c8, c7, 0   @ invalidate unified TLB
    mov     r0, #0xFFFFFFFF
    mcr     p15, 0, r0, c3, c0, 0       @ DACR = todo en modo manager
    mrc     p15, 0, r0, c1, c0, 0   @ leer control register
    orr     r0, r0, #MMU_C1_MBIT_ENABLE       @ habilitar MMU (bit 0)
    bic     r0, r0, #(1 << 12)       @ opcional: deshabilita caché
    bic     r0, r0, #(1 << 2)
    mcr     p15, 0, r0, c1, c0, 0   @ escribir control register
    bx      lr

start_main_addr:
    .word _page_table_start

start_second_addr:
    .word _coarse_table_start

secondary_table_addr:
    .word secondary_table

main_table: 
    .word  MMU_SECOND_TABLE_LOCATION | MMU_L1_COARSE_ENTRY

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
