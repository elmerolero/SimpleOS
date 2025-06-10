.include "system/mmu/constants.s"

.section .init
mmu_Init:
    ldr     r0, start_main_addr      @ Page table start
    ldr     r1, main_table           @ Gets main table data and saves it
    str     r1, [ r0 ]
    ldr     r1, start_second_addr    @ Second table start
    ldr     r2, secondary_table      @ Gets second table data
    mov     r4, #0
1:
    ldr     r3, [ r2, r4, lsl #2 ]
    str     r3, [ r1, r4, lsl #2 ]
    add     r4, r4, #1
    cmp     r4, #10
    bls     1b
    bl      mmu_setTTBR
    bl      mmu_flushTLB
    mov r0, #0xFFFFFFFF
    mcr p15, 0, r0, c3, c0, 0       @ DACR = todo en modo manager
    mrc     p15, 0, r0, c1, c0, 0   @ leer control register
    orr     r0, r0, #(1 << 0)       @ habilitar MMU (bit 0)
    bic     r0, r0, #(1 << 2)       @ opcional: deshabilita caché
    mcr     p15, 0, r0, c1, c0, 0   @ escribir control register
    bx      lr

.section .init
mmu_setTTBR:
    mcr p15, 0, r0, c2, c0, 0 @ tlb base
    mov pc, lr

.section .init
mmu_flushTLB:
    mov r0, #0
    mcr p15, 0, r0, c8, c7, 0   @ invalidate unified TLB
    mov pc, lr

start_main_addr:
    .word _page_table_start

start_second_addr:
    .word _coarse_table_start

main_table: 
    .word  MMU_SECOND_TABLE_LOCATION | MMU_TYPE_COARSE
secondary_table:
    .word (0x00017000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 0 (data)
    .word (0x00011000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 1 (VA 0x00001000) (und)
    .word (0x00012000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 2 (VA 0x00002000) (abt)
    .word (0x00013000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 3 (VA 0x00003000) (irq)
    .word (0x00014000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 4 (VA 0x00004000) (fiq)
    .word (0x00015000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 5 (VA 0x00005000) (sys)
    .word (0x00016000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 6 (text)
    .word (0x2000B000 & 0xFFFFF000) | MMU_FLAGS_DEVICE  @ entrada 7 (VA FOR DEVICES TEMPORARY) Interrupts
    .word (0x00008000 & 0xFFFFF000) | MMU_FLAGS_STRONG_ORDER  @ entrada 8 (VA 0x00000000) (.init)
    .word (0x20200000 & 0xFFFFF000) | MMU_FLAGS_DEVICE  @ entrada 9 (VA FOR DEVICES TEMPORARY) GPIO
    .word (0x20215000 & 0xFFFFF000) | MMU_FLAGS_DEVICE  @ entrada A (VA FOR DEVICES TEMPORARY) UART
