.include "system/mmu/constants.s"

.section .init
mmu_init:
    ldr     r0, =_page_table_start
    bl      mmu_setTTBR
    bl      mmu_flushTLB
    mrc     p15, 0, r0, c1, c0, 0   @ leer control register
    orr     r0, r0, #(1 << 0)       @ habilitar MMU (bit 0)
    bic     r0, r0, #(1 << 2)       @ opcional: deshabilita caché
    mcr     p15, 0, r0, c1, c0, 0   @ escribir control register
    bl      main

.section .init
mmu_setTTBR:
    mcr p15, 0, r0, c2, c0, 0 @ tlb base
    mov pc, lr

.section .init
mmu_flushTLB:
    mov r0, #0
    mcr p15, 0, r0, c8, c7, 0   @ invalidate unified TLB
    mov pc, lr

.section .page_table
.global page_table
    page_table: .word  ((MMU_SECOND_TABLE_LOCATION >> 10) << 10 | MMU_TYPE_COARSE)

.section .coarse_table
.global _coarse_table_start
    _coarse_table_start:
        .word (0x00011000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 0 (VA 0x00000000)
        .word (0x00012000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 1 (VA 0x00001000)
        .word (0x00013000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 2 (VA 0x00002000)
        .word (0x00014000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 3 (VA 0x00003000)
        .word (0x00015000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 4 (VA 0x00004000)
        .word (0x20215000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 5 (VA FOR DEVICES TEMPORARY)
        .word (0x00016000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 6 (text)
        .word (0x00017000 & 0xFFFFF000) | MMU_FLAGS  @ entrada 7 (data)
