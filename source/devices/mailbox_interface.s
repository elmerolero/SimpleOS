/* Operating System for Raspberry Pi */
/* Mailbox Interface */
/* Ismael Salas López */

// Mailbox address and offsets
.equ MAILBOX_BASE,      0x2000B880
.equ MAILBOX_READ,      0x00
.equ MAILBOX_POLL,      0x10
.equ MAILBOX_SENDER,    0x14
.equ MAILBOX_STATUS,    0x18
.equ MAILBOX_CONFIG,    0x1C
.equ MAILBOX_WRITE,     0x20

// Videocore
.equ TAG_GET_FIRMWARE_VERSION,      0x1

// Hardware
.equ TAG_GET_BOARD_MODEL,           0x10001
.equ TAG_GET_BOARD_REVISION,        0x10002
.equ TAG_GET_BOARD_MAC_ADDRESS,     0x10003
.equ TAG_GET_BOARD_SERIAL,          0x10004
.equ TAG_GET_ARM_MEMORY,            0x10005
.equ TAG_GET_VC_MEMORY,             0x10006
.equ TAG_GET_CLOCKS,                0x10007

// Config
.equ TAG_GET_COMMAND_LINE,          0x50001

// Shared resource management
.equ TAG_GET_DMA_CHANNELS,          0x60001

// Power
.equ TAG_GET_POWER_STATE,           0x20001
.equ TAG_GET_TIMING,                0x20002
.equ TAG_SET_POWER_STATE,           0x28001

    /* Clocks */
.equ TAG_GET_CLOCK_STATE,           0x30001
.equ TAG_SET_CLOCK_STATE,           0x38001
.equ TAG_GET_CLOCK_RATE,            0x30002
.equ TAG_SET_CLOCK_RATE,            0x38002
.equ TAG_GET_MAX_CLOCK_RATE,        0x30004
.equ TAG_GET_MIN_CLOCK_RATE,        0x30007
.equ TAG_GET_TURBO,                 0x30009
.equ TAG_SET_TURBO,                 0x38009

    /* Voltage */
.equ TAG_GET_VOLTAGE,               0x30003
.equ TAG_SET_VOLTAGE,               0x38003
.equ TAG_GET_MAX_VOLTAGE,           0x30005
.equ TAG_GET_MIN_VOLTAGE,           0x30008
.equ TAG_GET_TEMPERATURE,           0x30006
.equ TAG_GET_MAX_TEMPERATURE,       0x3000A
.equ TAG_ALLOCATE_MEMORY,           0x3000C
.equ TAG_LOCK_MEMORY,               0x3000D
.equ TAG_UNLOCK_MEMORY,             0x3000E
.equ TAG_RELEASE_MEMORY,            0x3000F
.equ TAG_EXECUTE_CODE,              0x30010
.equ TAG_GET_DISPMANX_MEM_HANDLE,   0x30014
.equ TAG_GET_EDID_BLOCK,            0x30020

    /* Framebuffer */
.equ TAG_ALLOCATE_BUFFER,       0x40001
.equ TAG_RELEASE_BUFFER,        0x48001
.equ TAG_BLANK_SCREEN,          0x40002
.equ TAG_GET_PHYSICAL_SIZE,     0x40003
.equ TAG_TEST_PHYSICAL_SIZE,    0x44003
.equ TAG_SET_PHYSICAL_SIZE,     0x48003
.equ TAG_GET_VIRTUAL_SIZE,      0x40004
.equ TAG_TEST_VIRTUAL_SIZE,     0x44004
.equ TAG_SET_VIRTUAL_SIZE,      0x48004
.equ TAG_GET_DEPTH,             0x40005
.equ TAG_TEST_DEPTH,            0x44005
.equ TAG_SET_DEPTH,             0x48005
.equ TAG_GET_PIXEL_ORDER,       0x40006
.equ TAG_TEST_PIXEL_ORDER,      0x44006
.equ TAG_SET_PIXEL_ORDER,       0x48006
.equ TAG_GET_ALPHA_MODE,        0x40007
.equ TAG_TEST_ALPHA_MODE,       0x44007
.equ TAG_SET_ALPHA_MODE,        0x48007
.equ TAG_GET_PITCH,             0x40008
.equ TAG_GET_VIRTUAL_OFFSET,    0x40009
.equ TAG_TEST_VIRTUAL_OFFSET,   0x44009
.equ TAG_SET_VIRTUAL_OFFSET,    0x48009
.equ TAG_GET_OVERSCAN,          0x4000A
.equ TAG_TEST_OVERSCAN,         0x4400A
.equ TAG_SET_OVERSCAN,          0x4800A
.equ TAG_GET_PALETTE,           0x4000B
.equ TAG_TEST_PALETTE,          0x4400B
.equ TAG_SET_PALETTE,           0x4800B
.equ TAG_SET_CURSOR_INFO,       0x8011
.equ TAG_SET_CURSOR_STATE,      0x8010

// Mailbox status
.equ MAILBOX_STATUS_FULL,      0x80000000
.equ MAILBOX_STATUS_EMPTY,     0x40000000
.equ MAILBOX_STATUS_LEVEL,     0x400000FF

@ ------------------------------------------------------------------------------
@ Writes into mailbox 0
@ r0: Message to send through mailbox
@ r1: Channel
@ ------------------------------------------------------------------------------
.section .text
mailbox_write:
    tst     r0, #0x0F
    bxne    lr
    cmp     r1, #0x0F
    bxhi    lr

    push { lr }
    mov     r2, r0
    ldr     r0, =MAILBOX_BASE
1:
    ldr     r3, [ r0, #MAILBOX_STATUS ]
    tst     r3, #MAILBOX_STATUS_FULL
    bne     1b
    add     r2, r1
    str     r2, [ r0, #MAILBOX_WRITE ]
    pop  { pc }

@ ------------------------------------------------------------------------------
@ Reads from mailbox 0
@ r0: Channel
@ ------------------------------------------------------------------------------
.section .text
mailbox_read:
    cmp     r0, #0x0F
    bxhi    lr
    
    push { lr }
    mov     r1, r0
    ldr     r0, =MAILBOX_BASE
1:
    ldr     r3, [ r0, #MAILBOX_STATUS ]
    tst     r3, #MAILBOX_STATUS_EMPTY
    bne     1b
    ldr     r3, [ r0, #MAILBOX_READ ]
    and     r2, r3, #0x0F
    teq     r2, r1 
    bne     1b
    and     r0, r3, #0xfffffff0
    pop  { pc }
