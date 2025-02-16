.equ FAT32_BYTES_PER_SECTOR,    0x0B    // Sector size - 2 bytes
.equ FAT32_SECS_PER_CLUSTER,    0x0D    // Sectors per cluster - 1 byte
.equ FAT32_RESERVED_SECTORS,    0x0E    // Reserved sector count - 2 bytes
.equ FAT32_FATS_NUMBER,         0x10    // Num of FATs - 1
.equ FAT32_TOTAL_SECTORS,       0x20    // Total of available sectors - 4 bytes
.equ FAT32_FAT_SIZE,            0x24    // FAT Size
.equ FAT32_HIDDEN_SECTORS,      0x1C    // Hidden sectors
.equ FAT32_ROOT_CLUSTER,        0x2C    // Root cluster

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
