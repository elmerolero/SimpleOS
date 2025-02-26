.equ FAT32_PARTITION_BOOT_PARAMETER_SECTOR, 0x800
.equ FAT32_RESERVED_SECTORS,    0x00
.equ FAT32_SECTORS_PER_CLUSTER, 0x04
.equ FAT32_RESERVED_SECTORS,     0x08
.equ FAT32_NUMBER_FATS,         0x0C
.equ FAT32_ROOT_ENTRY,          0x10
.equ FAT32_TOTAL_SECTORS,       0x14
.equ FAT32_FAT_SIZE,            0x18
.equ FAT32_HIDDEN_SECTORS,      0x1C
.equ FAT32_ROOT_CLUSTER,        0x20
.equ FAT32_ROOT_SECTOR,         0x24

.section .data
.align 4
    fat32_bpb_bytesPerSector:   .word 0
    fat32_bpb_secsPerCluster:   .word 0
    fat32_bpb_reservedSectors:  .word 0
    fat32_bpb_numFATs:          .word 0
    fat32_bpb_rootEntry:        .word 0
    fat32_bpb_totalSectors:     .word 0
    fat32_bpb_FATSize:          .word 0
    fat32_bpb_hiddenSectors:    .word 0
    fat32_bpb_rootCluster:      .word 0
    fat32_root_sector:          .word 0

.section .text
fat32_calculate_root_directory:
    push { lr }
    ldr     r0, =fat32_bpb_bytesPerSector
    ldr     r1, [ r0, #FAT32_RESERVED_SECTORS ] // r1 - Reserved sectors
    ldr     r2, [ r0, #FAT32_NUMBER_FATS ]      // r2 - Num of FATS
    ldr     r3, [ r0, #FAT32_FAT_SIZE ]         // r3 - FAT size
    ldr     r0, [ r0, #FAT32_ROOT_CLUSTER ]     // r0 - Root cluster
    sub     r0, #2                              // r0 = r0 -2
    mla     r0, r2, r3, r0                      // r0 = r2 * r3 + r0
    add     r0, r0, r1                          // r0 = r0 + r1
    add     r0, r0, #FAT32_PARTITION_BOOT_PARAMETER_SECTOR         
    ldr     r1, =fat32_root_sector
    str     r0, [ r1 ]
    pop { pc }

@ ------------------------------------------------------------------------------
@ Sector is calculated from a given cluster according the following fórmula:
@ sector = (cluster - 2) + bpb block sector + (number of FATS * FAT size)
@ Input
@   r0: Cluster
@ Output
@   r0: Calculated sector
@ ------------------------------------------------------------------------------
.section .text
fat32_calculate_sector_from_cluster:
    push { r4, lr }
    ldr     r4, =fat32_bpb_bytesPerSector
    ldr     r1, [ r4, #FAT32_RESERVED_SECTORS ]
    ldr     r2, [ r4, #FAT32_NUMBER_FATS ]
    ldr     r3, [ r4, #FAT32_FAT_SIZE ]
    ldr     r4, [ r4, #FAT32_SECTORS_PER_CLUSTER ]
    sub     r0, #2                              
    mul     r0, r0, r4
    mla     r0, r2, r3, r0 
    add     r0, r0, r1                          
    add     r0, r0, #FAT32_PARTITION_BOOT_PARAMETER_SECTOR
    pop { r4, pc }
