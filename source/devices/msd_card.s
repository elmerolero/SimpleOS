.include "devices/spi0.s"
.include "filesystems/fat32.s"

.section .data
.align 1
    cmd0:       .byte 0x40, 0x00, 0x00, 0x00, 0x00, 0x95
.align 1
    cmd8:       .byte 0x48, 0x00, 0x00, 0x01, 0xAA, 0x87
.align 1
    cmd1:       .byte 0x41, 0x00, 0x00, 0x00, 0x00, 0xFF
.align 1
    cmd55:      .byte 0x77, 0x00, 0x00, 0x00, 0x00, 0x65
.align 1
    cmd41:      .byte 0x69, 0x40, 0x00, 0x00, 0x00, 0x77
.align 1
    cmd58:      .byte 0x7A, 0x00, 0x00, 0x00, 0x00, 0xFD
.align 1
    cmd17:      .byte 0x51, 0x00, 0x00, 0x00, 0x00, 0xFF

.section .text
msd_card_init:
    push { r4, lr }
    ldr     r0, =40000
    mov     r1, #0
    bl      spi0_init

    // Wake up SD Card
    mov     r4, #10
1:
    mov     r0, #0xFF
    bl      spi0_byte_write
    subs    r4, #1
    bge     1b

    // CMD0
    ldr     r0, =cmd0
    mov     r1, #6
    bl      spi0_bytes_write
2:
    cmp     r0, #1
    beq     3f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       2b

    // CMD8
3:
    ldr     r0, =cmd8
    mov     r1, #6
    bl      spi0_bytes_write
4:
    cmp     r0, #1
    beq     5f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       4b

    // CMD1
5:
    ldr     r0, =cmd1
    mov     r1, #6
    bl      spi0_bytes_write
6:
    cmp     r0, #1
    beq     5b
    cmp     r0, #0
    beq     7f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       6b

    // CMD55 y ACMD41
7:
    ldr     r0, =cmd55
    mov     r1, #6
    bl      spi0_bytes_write
8:
    cmp     r0, #0
    beq     9f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       8b

    9:
    ldr     r0, =cmd41
    mov     r1, #6
    bl      spi0_bytes_write
10:
    cmp     r0, #1
    beq     9b
    cmp     r0, #0
    beq     11f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       10b
11:
    pop { r4, pc }

.section .text
msd_card_sector_index_write:
    push { lr }
    ldr     r1, =cmd17
    mov     r2, #0
    mov     r3, #0
1:
    add     r2, #1
    strb    r3, [ r1, r2 ]
    cmp     r2, #4
    blo     1b
2:
    and     r3, r0, #0xFF
    strb    r3, [ r1, r2 ]
    lsr     r0, r0, #8
    sub     r2, #1
    cmp     r2, #0
    bhi     2b
    pop { pc }

.section .text
msd_card_fat32_init:
    push { r4, r5, lr }
    mov     r0, #0x800
    bl      msd_card_sector_index_write
    ldr     r0, =cmd17
    mov     r1, #6
    bl      spi0_bytes_write

1:
    cmp     r0, #0xFE
    beq     2f
    mov     r0, #0xFF
    bl      spi0_byte_write
    b       1b
    
2:
    mov     r4, #0
3:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #FAT32_BYTES_PER_SECTOR
    add     r4, r4, #1
    bne     3b

    // Bytes per sector
    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #8
    ldr     r6, =fat32_bpb_bytesPerSector
    str     r0, [ r6 ]
    add     r4, #1

4:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #FAT32_SECS_PER_CLUSTER
    add     r4, r4, #1
    bne     4b

    // Sectors per cluster
    add     r6, r6, #4
    str     r0, [ r6 ]

5:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #FAT32_RESERVED_SECTORS
    add     r4, r4, #1
    bne     5b

    // Reserved sectors
    add     r6, r6, #4
    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #8
    ldr     r6, =fat32_bpb_reservedSectors
    str     r0, [ r6 ]
    add     r4, #1

    // Num of fats
    mov     r0, #0xFF
    bl      spi0_byte_write
    add     r6, r6, #4
    str     r0, [ r6 ]
    add     r4, #1

    // Root entry count
    mov     r0, #0xFF
    bl      spi0_byte_write
    add     r4, #1
    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    add     r4, #1
    orr     r0, r5, r0, lsl #8
    add     r6, r6, #4
    str     r0, [ r6 ]

    // Continues reading until get to total sectors FAT32
6:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #FAT32_TOTAL_SECTORS
    add     r4, #1
    bne     6b

    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r5, r5, r0, lsl #8
    add     r4, r4, #1

    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r5, r5, r0, lsl #16
    add     r4, r4, #1

    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #24
    add     r6, #4
    str     r0, [ r6 ] 
    add     r4, r4, #1

    // FAT Size
    mov     r0, #0xFF
    bl      spi0_byte_write
    mov     r5, r0
    add     r4, r4, #1
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r5, r5, r0, lsl #8
    add     r4, r4, #1

    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r5, r5, r0, lsl #16
    add     r4, r4, #1

    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #24
    add     r6, #4
    str     r0, [ r6 ] 
    add     r4, r4, #1

    // Continues reading until get first byte of Root cluster
7:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #FAT32_ROOT_CLUSTER
    add     r4, #1
    bne     7b

    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r5, r5, r0, lsl #8
    add     r4, r4, #1

    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r5, r5, r0, lsl #16
    add     r4, r4, #1

    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #24
    add     r6, #8
    str     r0, [ r6 ] 
    add     r4, r4, #1

    // Read the remaining bytes
8:
    mov     r0, #0xFF
    bl      spi0_byte_write
    add     r4, r4, #1
    cmp     r4, #512
    blo     8b

    // Calculates root directory 
    bl      fat32_calulate_root_directory

    pop { r4, r5, pc }

.section .text
msd_card_list_directories:
    push { lr }

    pop { pc }
