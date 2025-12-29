/* MMU OPTIONS */
.equ MMU_DOMAIN_0,           (0 << 5)
.equ MMU_C1_MBIT_ENABLE,     0x01       // MMU Enable (0 bit)
.equ MMU_C1_MBIT_DISABLE,    0x00       // MMU Disable
.equ MMU_C1_TEXBIT_ENABLE,   0x10000000 // Enable Type Extension remap bit -TEX- (28 bit)
.equ MMU_C1_TEXBIT_DISABLE,  0x00000000 // Disable Type Extension remap bit -TEX-

/* PAGE AND ENTRIES OPTIONS */
.equ MMU_L1_FAULT_ENTRY,    0x00    // L1 Fault
.equ MMU_L1_COARSE_ENTRY,   0x01    // L1 Coarse table
.equ MMU_L1_SECTION_ENTRY,  0x02    // L1 Section
.equ MMU_L2_FAULT_PAGE,     0x00    // L2 Fault
.equ MMU_L2_LARGE_PAGE,     0x01    // L2 64KB
.equ MMU_L2_SMALL_PAGE,     0x02    // L2 4KB

.equ MMU_SP_APX,                (1 << 9)     // APX Bit
.equ MMU_SP_AP_NO_ACCESS,       (0x00 << 4)  // No access (priv and user)
.equ MMU_SP_AP_RW_PRIV_ONLY,    (0x01 << 4)  // RW privileged, no access user
.equ MMU_SP_AP_RW_USER_RO,      (0x02 << 4)  // RW privileged, RO user
.equ MMU_SP_AP_RW_RW,           (0x03 << 4)  // RW for all

.equ MMU_DATA_CACHE_CBIT_ENABLE,            0x04 // Enable data cache (2 bit)
.equ MMU_DATA_CACHE_CBIT_DISABLE,           0x00 // Disable data cache

.equ MMU_INSTRUCTION_CACHE_IBIT_ENABLE,     0x1000  // Enable instruction cache (12 bit)
.equ MMU_INSTRUCTION_CACHE_IBIT_DISABLE,    0x0000  // Disable instruction cache

@ ------------------------------------------------------------------------------
@ Initializes MMU (no parameters yet)
@ ------------------------------------------------------------------------------
.section .text
mmu_Init:
    push { lr }
    bl      systemMemory_Init

    mov     r0, #0                          // TTBCR = 0 - Use TTBR0 only
    mcr     p15, 0, r0, c2, c0, 2           
    ldr     r0, =_system_level1_table_start          // Page table start
    bl      mmu_SetTTBR0
    mov     r0, #0
    mcr     p15, 0, r0, c8, c7, 0           // invalidate unified TLB
    mov     r0, #0xFFFFFFFF
    mcr     p15, 0, r0, c3, c0, 0           // DACR = todo en modo manager
    mrc     p15, 0, r0, c1, c0, 0           // leer control register
    mov     r0, #0
    mcr     p15, 0, r0, c7, c5, 0           // Invalidate I-cache
    bic     r0, r0, #(1 << 12)              // opcional: deshabilita cachés
    bic     r0, r0, #(1 << 2)
    orr     r0, r0, #MMU_C1_TEXBIT_ENABLE   // TEX remap ON (bit 28 = 1)
    orr     r0, r0, #MMU_C1_MBIT_ENABLE     // habilitar MMU (bit 0 = 1)
    mcr     p15, 0, r0, c1, c0, 0           // escribir control register
    pop { pc }

mmu_SetTTBR0:
    mcr     p15, 0, r0, c2, c0, 0
    bx      lr

mmu_ErrorCodeGet:
    mrc p15, 0, r0, c5, c0, 0
    bx      lr

mmu_ErrorAdressGet:
    mrc p15, 0, r0, c6, c0, 0
    bx      lr

systemMemory_Init:
    push { lr }
    // Clear page tables for system level 1 table
    ldr     r0, =_system_level1_table_start      
    mov     r1, #0
    mov     r2, #0x4000
    bl      memset

    // Copies the entries for system's level 1 table
    ldr     r1, level1_table_entries_addr
    mov     r2, #8
    bl      memcpy_safe

    // Clear page tables for system level 2 table
    ldr     r0, =_system_level2_table_start           // Second table start
    mov     r1, #0
    mov     r2, #0x400
    bl      memset

    // Gets first level 2 table entries and copies its content in in system's level 2 table
    ldr     r1, level2_table_entries_addr   // Gets second table data
    mov     r2, #108
    bl      memcpy_safe

    // Clear for system level 2 table 2
    ldr     r0, =_system_level2_table2_start
    mov     r1, #0
    mov     r2, #0x400
    bl      memset

    // Gets second level 2 table entries and copies its content in system's level 2 table
    ldr     r1, level2_table2_entries_addr
    mov     r2, #28
    bl      memcpy_safe

    pop { pc }

level1_table_entries_addr:
    .word level1_table_entries

level2_table_entries_addr:
    .word level2_table_entries

level2_table2_entries_addr:
    .word level2_table2_entries

level1_table_entries: 
    .word  (0x14000 | MMU_L1_COARSE_ENTRY)
    .word  (0x14400 | MMU_L1_COARSE_ENTRY)

level2_table_entries:
    .word (0x00000000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ Points to 0x00000000
    .word (0x00015000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 1 (VA 0x00001000) (und)
    .word (0x00016000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 2 (VA 0x00002000) (abt)
    .word (0x00017000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 3 (VA 0x00003000) (irq)
    .word (0x00018000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 4 (VA 0x00004000) (fiq)
    .word (0x00019000 & 0xFFFFF000) | (MMU_SP_AP_RW_RW | MMU_L2_SMALL_PAGE)  @ entrada 5 (VA 0x00005000) (sys)
    .word (0x00000000) // 0x06
    .word (0x00000000) // 0x07
    .word (0x00008000 & 0xFFFFF000) | (MMU_SP_APX | MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ entrada 8 (VA 0x00008000) (.text)
    .word (0x00009000 & 0xFFFFF000) | (MMU_SP_APX | MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ entrada 9 (VA 0x00008000) (.text)
    .word (0x0000A000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY| MMU_L2_SMALL_PAGE)  @ entrada A (.data)
    .word (0x0000B000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ entrada B (.data)
    .word (0x0000C000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ entrada C (VA 0x00007000) (init_stack)
    .word (0x2000D000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x0D Interrupts & Mailbox
    .word (0x20200000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x0E GPIO
    .word (0x20215000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x0F UART
    .word (0x00000000) // 0x10
    .word (0x00000000) // 0x11
    .word (0x00000000) // 0x12
    .word (0x00000000) // 0x13
    .word (0x00000000) // 0x14
    .word (0x00000000) // 0x15
    .word (0x00000000) // 0x16
    .word (0x00000000) // 0x17
    .word (0x00000000) // 0x18
    .word (0x00000000) // 0x19
    .word (0x0001A000 & 0xFFFFF000) | (MMU_SP_APX | MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE) // Entrada 0x1A000 (.init)

level2_table2_entries:
    .word (0x20007000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x00 DMA
    .word (0x2000B000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x01 Interrupts, Mailbox, ARM_TIMER
    .word (0x20101000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x02 Clock manager
    .word (0x20200000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x03 GPIO
    .word (0x20202000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x03 SD HOST
    .word (0x20215000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x04 Auxiliaries
    .word (0x20300000 & 0xFFFFF000) | (MMU_SP_AP_RW_PRIV_ONLY | MMU_L2_SMALL_PAGE)  @ 0x05 EMMC
