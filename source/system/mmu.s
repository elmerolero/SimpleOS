
.section .text
mmu_init:
    mov r0, #0x4000
    lsl r0, #2

.section .text
mmu_setTTBR:
    mcr p15, 0, r0, c2, c0, 0 ;@ tlb base
    mov pc, lr

