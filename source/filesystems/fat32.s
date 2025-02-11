.equ FAT32_JUMP_INSTRUCTION,    0x00    // Jump instruction - 3 bytes
.equ FAT32_OEM_NAME,            0x03    // OEM Name - 8 bytes
.equ FAT32_SECTOR_SIZE,         0x0B    // Sector size - 2 bytes
.equ FAT32_RESERVED_SECTORS,    0x0E    // Reserved sectors - 2 bytes


.section .data
.align 4
    bpb_fat32: .skip 92
