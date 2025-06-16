/* MMU OPTIONS */
.equ MMU_DOMAIN_0,         (0 << 5)
.equ MMU_C1_MBIT_ENABLE,     0x01       // MMU Enable (0 bit)
.equ MMU_C1_MBIT_DISABLE,    0x00       // MMU Disable
.equ MMU_C1_TEXBIT_ENABLE,   0x10000000 // Enable Type Extension remap bit -TEX- (28 bit)
.equ MMU_C1_TEXBIT_DISABLE,  0x00000000 // Disable Type Extension remap bit -TEX-

/* PAGE AND ENTRIES OPTIONS */
.equ MMU_L1_FAULT_ENTRY,    0x00    // L1 Fault
.equ MMU_L1_COARSE_ENTRY,   0x01    // L1 Coarse table
.equ MMU_L1_SECTION_ENTRY,  0x02    // L1 Section
.equ MMU_L2_FAULT_PAGE,    0x00     // L2 Fault
.equ MMU_L2_LARGE_PAGE,    0x01     // L2 64KB
.equ MMU_L2_SMALL_PAGE,    0x02     // L2 4KB

.equ MMU_SP_AP_NO_ACCESS,       (0x00 << 10)  // No access (priv and user)
.equ MMU_SP_AP_RW_PRIV_ONLY,    (0x01 << 10)  // RW privileged, no access user
.equ MMU_SP_AP_RW_USER_RO,      (0x02 << 10)  // RW privileged, RO user
.equ MMU_SP_AP_RW_RW,           (0x03 << 10)  // RW for all

.equ MMU_DATA_CACHE_CBIT_ENABLE,            0x04 // Enable data cache (2 bit)
.equ MMU_DATA_CACHE_CBIT_DISABLE,           0x00 // Disable data cache

.equ MMU_INSTRUCTION_CACHE_IBIT_ENABLE,     0x1000  // Enable instruction cache (12 bit)
.equ MMU_INSTRUCTION_CACHE_IBIT_DISABLE,    0x0000  // Disable instruction cache

// Default direction
.equ MMU_SECOND_TABLE_LOCATION, 0x14000
