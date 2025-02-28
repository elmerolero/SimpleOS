.include "devices/spi0.s"
.include "filesystems/fat32.s"

// These values are used to read the offset when reading bytes from spi
.equ MSD_FAT32_BYTES_PER_SECTOR,    0x0B    // Sector size - 2 bytes
.equ MSD_FAT32_SECS_PER_CLUSTER,    0x0D    // Sectors per cluster - 1 byte
.equ MSD_FAT32_RESERVED_SECTORS,    0x0E    // Reserved sector count - 2 bytes
.equ MSD_FAT32_FATS_NUMBER,         0x10    // Num of FATs - 1
.equ MSD_FAT32_TOTAL_SECTORS,       0x20    // Total of available sectors - 4 bytes
.equ MSD_FAT32_FAT_SIZE,            0x24    // FAT Size
.equ MSD_FAT32_HIDDEN_SECTORS,      0x1C    // Hidden sectors
.equ MSD_FAT32_ROOT_CLUSTER,        0x2C    // Root cluster


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

.align 1
    sector_buffer:  .skip 512
.align 1
    eos:        .byte 0

.align 4
    number_of_files: .word 2

.align 4
    files:      .skip 40

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
    cmp     r4, #MSD_FAT32_BYTES_PER_SECTOR
    add     r4, r4, #1
    bne     3b

    // Bytes per sector
    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #8
    ldr     r6, =fat32_bpb_bytesPerSector
    str     r0, [ r6 ], #4
    add     r4, #1

4:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #MSD_FAT32_SECS_PER_CLUSTER
    add     r4, r4, #1
    bne     4b

    // Sectors per cluster
    str     r0, [ r6 ], #4

5:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #MSD_FAT32_RESERVED_SECTORS
    add     r4, r4, #1
    bne     5b

    // Reserved sectors
    mov     r5, r0
    mov     r0, #0xFF
    bl      spi0_byte_write
    orr     r0, r5, r0, lsl #8
    str     r0, [ r6 ], #4
    add     r4, #1

    // Num of fats
    mov     r0, #0xFF
    bl      spi0_byte_write
    str     r0, [ r6 ], #4
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
    str     r0, [ r6 ], #4

    // Continues reading until get to total sectors FAT32
6:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #MSD_FAT32_TOTAL_SECTORS
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
    str     r0, [ r6 ], #4
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
    str     r0, [ r6 ], #8
    add     r4, r4, #1

    // Continues reading until get first byte of Root cluster
7:
    mov     r0, #0xFF
    bl      spi0_byte_write
    cmp     r4, #MSD_FAT32_ROOT_CLUSTER
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
    bl      fat32_calculate_root_directory

    pop { r4, r5, pc }


@ ------------------------------------------------------------------------------
@ Read an specific sector 
@ R0: Sector address
@ ------------------------------------------------------------------------------
.section .text
msd_card_sector_read:
    push { r4, r5, r6, lr }
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
    mov     r4, #512
    sub     r4, r4, #1
    ldr     r5, =sector_buffer
3:
    mov     r0, #0xFF
    bl      spi0_byte_write
    strb    r0, [ r5 ]
    add     r5, r5, #1
    subs    r4, r4, #1
    bhs     3b
    
    ldr     r4, =sector_buffer
    mov     r5, #0
4:
    ldrb    r0, [ r4, r5 ]
    mov     r1, #16
    bl      aux_mini_uart_u32_write
    mov     r0, #','
    bl      aux_mini_uart_byte_write
    add     r5, #1
    cmp     r5, #512
    blo     4b
    pop { r4, r5, r6, pc }

.section .text
msd_card_list_directories:
    push { r4, r5, r6, r7, r8, r9, r10, r11, lr }
    mov     r5, #0
    mov     r8, #0
    mov     r9, #0
    mov     r11, #0
1:
    ldr     r0, =fat32_root_sector
    ldr     r0, [ r0 ]
    add     r0, r0, r8
    bl      msd_card_sector_read
 
    ldr     r4, =sector_buffer
    mov     r5, #0
2:
    ldrb    r0, [ r4, r5 ]      // Looks for an entry
    cmp     r0, #0x00
    beq     5f
    cmp     r0, #0xE5           // Is it a deleted entry?
    beq     4f
    add     r6, r5, #11
    ldrb    r0, [ r4, r6 ]
    cmp     r0, #0x0F           // LNF?
    beq     4f

    ldr     r10, =files
    mov     r6, #0
3:
    add     r7, r5, r6
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    add     r6, r6, #1
    cmp     r6, #8
    blo     3b
    mov     r0, #'.'
    bl      aux_mini_uart_byte_write
    add     r7, r5, #8
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    add     r7, r5, #9
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    add     r7, r5, #10
    ldrb    r0, [ r4, r7 ]
    add     r7, r6, r11  
    strb    r0, [ r10, r7 ]
    bl      aux_mini_uart_byte_write
    mov     r0, #' '
    bl      aux_mini_uart_byte_write

    // Read cluster msb
    add     r6, r5, #0x15
    ldrb    r1, [ r4, r6 ]
    add     r6, r5, #0x14
    ldrb    r0, [ r4, r6 ]
    orr     r1, r0, r1, lsl #8

    // Read cluster lsb
    add     r6, r5, #0x1B
    ldrb    r2, [ r4, r6 ]
    add     r6, r5, #0x1A
    ldrb    r0, [ r4, r6 ]
    orr     r2, r0, r2, lsl #8
    orr     r1, r2, r1, lsl #16

    // Read file size from msb to lsb
    add     r6, r5, #0x1C
    ldrb    r2, [ r4, r6 ]
    add     r6, r5, #0x1D
    ldrb    r0, [ r4, r6 ]
    orr     r2, r2, r0, lsl #8
    add     r6, r5, #0x1E
    ldrb    r0, [ r4, r6 ]
    orr     r2, r2, r0, lsl #16
    add     r6, r5, #0x1F
    ldrb    r0, [ r4, r6 ]
    orr     r2, r2, r0, lsl #24
    
    add     r6, r11, #0x0C
    str     r1, [ r10, r6 ]

    add     r6, r11, #0x10
    str     r2, [ r10, r6 ]   

    mov     r0, r1
    mov     r1, #16
    mov     r7, r2
    bl      aux_mini_uart_u32_write
    mov     r0, #' '
    bl      aux_mini_uart_byte_write

    mov     r0, r7
    mov     r1, #16
    bl      aux_mini_uart_u32_write

    mov     r0, #'\r'
    bl      aux_mini_uart_byte_write
    mov     r0, #'\n'
    bl      aux_mini_uart_byte_write

    add     r11, r11, #20
4:                                          // Next entry
    add     r5, r5, #32
    b       2b
5:
    add     r8, r8, #1
    cmp     r5, #512
    beq     1b
    pop { r4, r5, r6, r7, r8, r9, r10, r11, pc }

.section .text
msd_card_buffer_read:
    push { r4, lr }
    ldr     r4, =sector_buffer
    add     r4, r4, r0
    mov     r3, r1
    mov     r2, #0
    mov     r0, #0
1:
    ldrb    r1, [ r4 ], #1
    orr     r0, r0, r1, lsl r2
    add     r2, r2, #8
    subs    r3, r3, #1
    bhi     1b
    pop { r4, pc }
