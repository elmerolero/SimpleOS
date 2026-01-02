.include "./devices/sd.s"
.include "./devices/emmc.inc"

@ EMMC Controller Registers
.equ EMMC_ARG2_REG,         0x00
.equ EMMC_BLKSIZECNT_REG,   0x04
.equ EMMC_ARG1_REG,         0x08
.equ EMMC_CMDTM_REG,        0x0C
.equ EMMC_RESP0_REG,        0x10
.equ EMMC_RESP1_REG,        0x14
.equ EMMC_RESP2_REG,        0x18
.equ EMMC_RESP3_REG,        0x1C
.equ EMMC_DATA_REG,         0x20
.equ EMMC_STATUS_REG,       0x24
.equ EMMC_CONTROL0_REG,     0x28
.equ EMMC_CONTROL1_REG,     0x2C
.equ EMMC_INTERRUPT_REG,    0x30
.equ EMMC_IRPT_MASK_REG,    0x34
.equ EMMC_IRPT_EN_REG,      0x38
.equ EMMC_CONTROL2_REG,     0x3C
.equ EMMC_FORCE_IRPT_REG,   0x50
.equ EMMC_BOOT_TIMEOUT_REG, 0x70
.equ EMMC_DBG_SEL_REG,      0x74
.equ EMMC_EXRDFIFO_CFG_REG, 0x80
.equ EMMC_EXRDFIFO_EN_REG,  0x84
.equ EMMC_TUNE_STEP_REG,    0x88
.equ EMMC_TUNE_STEPS_STD,   0x8C
.equ EMMC_TUNE_STEPS_DDR,   0x90
.equ EMMC_SPI_INT_SPT,      0xF0
.equ EMMC_SLOTISR_VER,      0xFC

@ eMMC Control 1 Options
.equ EMMC_CONTROL1_SRST_DATA,    (0x01 << 26)
.equ EMMC_CONTROL1_SRST_CMD,     (0x01 << 25)
.equ EMMC_CONTROL1_SRST_HC,      (0x01 << 24)
.equ EMMC_CONTROL1_DATA_TOUNIT,  (0x08 << 16)
.equ EMMC_CONTROL1_CLK_EN,       (0x01 << 2)
.equ EMMC_CONTROL1_CLK_STABLE,   (0x01 << 1)
.equ EMMC_CONTROL1_CLK_INTLEN,   (0x01 << 0)

@ Command status
.equ EMMC_INTERRUPT_DTO_ERR,    1 << 20
.equ EMMC_INTERRUPT_CBAD_ERR,   1 << 19
.equ EMMC_INTERRUPT_CEND_ERR,   1 << 18
.equ EMMC_STATUS_COMMAND_ERROR, 1 << 15
.equ EMMC_STATUS_READ_READY,    1 << 5
.equ EMMC_STATUS_WRITE_READY,   1 << 4
.equ EMMC_STATUS_DATA_DONE,     1 << 1
.equ EMMC_STATUS_COMMAND_DONE,  1 << 0

.section .data
.align 4
emmc_Commands:
    .word EMMC_CMD0 | EMMC_CMD_INDEX_CHECK
    .word EMMC_CMD1 | EMMC_CMD_CRC_CHECK | EMMC_CMD_INDEX_CHECK
    .word EMMC_CMD2 | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_136
    .word EMMC_CMD3 | EMMC_CMD_CRC_CHECK | EMMC_CMD_INDEX_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD6 | EMMC_CMD_RSPNS_TYPE_48 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK
    .word EMMC_CMD7 | EMMC_CMD_CRC_CHECK | EMMC_CMD_INDEX_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD8 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD9 | EMMC_CMD_RSPNS_TYPE_136
    .word EMMC_CMD13 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD16 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD17 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_ISDATA | EMMC_CMD_IS_DATA_FROM_CARD | EMMC_CMD_RSPNS_TYPE_48 | EMMC_CMD_COUNT_ENABLE
    .word EMMC_CMD41 | EMMC_CMD_RSPNS_TYPE_48BUSY
    .word EMMC_CMD55 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48

.align 4
.section .text
emmc_GetCommandFromIndex:
    push { lr }
    ldr     r1, =emmc_Commands
    ldr     r0, [ r1, r0, lsl #2 ]
    pop { pc }

@ ------------------------------------------------------------------------------
@ Initializes eMMC Host Controller.
@ Inputs
@   None
@ Outputs
@   None
@ ------------------------------------------------------------------------------
.section .text
emmc_Init:
    push { r4, r5, lr }
    mov     r0, #34
    mov     r1, #GPIO_MODE_INPUT
    bl      gpio_SetMode

    mov     r0, #35
    mov     r1, #GPIO_MODE_INPUT
    bl      gpio_SetMode

    mov     r0, #36
    mov     r1, #GPIO_MODE_INPUT
    bl      gpio_SetMode

    mov     r0, #37
    mov     r1, #GPIO_MODE_INPUT
    bl      gpio_SetMode

    mov     r0, #38
    mov     r1, #GPIO_MODE_INPUT
    bl      gpio_SetMode
    
    mov     r0, #39
    mov     r1, #GPIO_MODE_INPUT
    bl      gpio_SetMode

    mov     r0, #48
    mov     r1, #GPIO_PUD_MODE_DISABLE
    bl      gpio_SetPudMode

    mov     r0, #49
    mov     r1, #GPIO_PUD_MODE_UP_ENABLE
    bl      gpio_SetPudMode

    mov     r0, #50
    mov     r1, #GPIO_PUD_MODE_UP_ENABLE
    bl      gpio_SetPudMode

    mov     r0, #51
    mov     r1, #GPIO_PUD_MODE_UP_ENABLE
    bl      gpio_SetPudMode

    mov     r0, #52
    mov     r1, #GPIO_PUD_MODE_UP_ENABLE
    bl      gpio_SetPudMode

    mov     r0, #53
    mov     r1, #GPIO_PUD_MODE_UP_ENABLE
    bl      gpio_SetPudMode

    mov     r0, #48
    mov     r1, #GPIO_MODE_ALTF3
    bl      gpio_SetMode

    mov     r0, #49
    mov     r1, #GPIO_MODE_ALTF3
    bl      gpio_SetMode

    mov     r0, #50
    mov     r1, #GPIO_MODE_ALTF3
    bl      gpio_SetMode

    mov     r0, #51
    mov     r1, #GPIO_MODE_ALTF3
    bl      gpio_SetMode

    mov     r0, #52
    mov     r1, #GPIO_MODE_ALTF3
    bl      gpio_SetMode

    mov     r0, #53
    mov     r1, #GPIO_MODE_ALTF3
    bl      gpio_SetMode


    mov     r0, #EMMC_DEVICES
    bl      devices_GetAddress
    mov     r1, r0

    @ Resets the controller
    mov     r0, #(EMMC_CONTROL1_SRST_DATA | EMMC_CONTROL1_SRST_CMD | EMMC_CONTROL1_SRST_HC)
    str     r0, [ r1, #EMMC_CONTROL1_REG ]

    @Waits for reset
1:
    ldr     r0, [ r1, #EMMC_CONTROL1_REG ]
    tst     r0, #(EMMC_CONTROL1_SRST_DATA | EMMC_CONTROL1_SRST_CMD | EMMC_CONTROL1_SRST_HC)
    bne     1b

    @ Clear status register
    mov     r0, #0xFFFFFFFF
    str     r0, [ r1, #EMMC_INTERRUPT_REG ]
    mov     r0, #0
    str     r0, [ r1, #EMMC_IRPT_EN_REG ]
    str     r0, [ r1, #EMMC_EXRDFIFO_EN_REG ]

    @ Enables interrupts mask
    mov     r0, #0xFFFFFFFF
    str     r0, [ r1, #EMMC_IRPT_MASK_REG ]

    @ Set settings and enables
    ldr     r0, [ r1, #EMMC_CONTROL1_REG ]
    push    { r0-r3 }
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    pop     { r0-r3 }
    orr     r0, r0, #EMMC_CONTROL1_DATA_TOUNIT
    orr     r0, r0, #EMMC_CONTROL1_CLK_EN
    orr     r0, r0, #(2 << 6)
    orr     r0, r0, #EMMC_CONTROL1_CLK_INTLEN
    str     r0, [ r1, #EMMC_CONTROL1_REG ]

    @ Waits for stable
2:
    ldr     r0, [ r1, #EMMC_CONTROL1_REG ]
    tst     r0, #EMMC_CONTROL1_CLK_STABLE
    beq     2b

    pop { r4, r5, pc }

@ ------------------------------------------------------------------------------
@ Sends a command.
@ Inputs
@   r0 - Command index
@   r1 - Arguments
@ Outputs
@   None
@ ------------------------------------------------------------------------------
.section .text
emmc_SendCommand:
    push { r4, r5, lr }

    @ Backs up the argument (r1)
    mov     r5, r1

    @ Gets the command and saves it in r3
    bl      emmc_GetCommandFromIndex
    mov     r3, r0

    mov     r0, #256
    bl      utils_delay

    @ Gets the device
    mov     r0, #EMMC_DEVICES
    bl      devices_GetAddress
    mov     r4, r0

    @ Clear status
    mov     r1, #0xFFFFFFFF
    str     r1, [ r4, #EMMC_INTERRUPT_REG ]

    @ Sets the argument and command
    str     r5, [ r4, #EMMC_ARG1_REG ]
    str     r3, [ r4, #EMMC_CMDTM_REG ]
    
    @ Waits for status
1:
    ldr     r1, [ r4, #EMMC_INTERRUPT_REG ]
    tst     r1, #EMMC_STATUS_COMMAND_ERROR       // Looks for command error
    bne     2f
    tst     r1, #EMMC_STATUS_COMMAND_DONE       // Looks for command done
    beq     1b

    @ Reads response
    ldr     r0, [ r4, #EMMC_RESP0_REG ]
    ldr     r1, [ r4, #EMMC_RESP1_REG ]
    ldr     r2, [ r4, #EMMC_RESP2_REG ]
    ldr     r3, [ r4, #EMMC_RESP3_REG ]
2:
    pop { r4, r5, pc }

@-------------------------------------------------------------------------------
@ Waits for a completed sending or error status
@ Inputs
@   None
@ Outputs
@   r0 - Status
@-------------------------------------------------------------------------------
.section .text
emmc_WaitStatus:
    push { r4, lr }
1:
    ldr     r1, [ r4, #EMMC_INTERRUPT_REG ]
    push { r0, r1, r2, r3 }
    mov     r0, #0xFF00
    bl      utils_delay
    mov     r0, r1
    mov     r1, #16
    bl      utils_u32_write
    mov     r0, #'W'
    bl      uart0_PutByte
    mov     r0, #' '
    bl      uart0_PutByte
    pop { r0, r1, r2, r3 }

    @ Looks for command done
    tst     r1, #EMMC_STATUS_COMMAND_DONE
    bne     2f

    @ Looks for command error
    tst     r1, #EMMC_STATUS_COMMAND_ERROR
    beq     1b
2:
    mov     r4, r1
    bl      next_line
    mov     r0, r4
    pop { r4, pc }

@ ------------------------------------------------------------------------------
@ Reads a response.
@ Inputs
@   r0 - Response index
@ Outputs
@   r0 - Response from eMMC
@ ------------------------------------------------------------------------------
.section .text
emmc_GetResponse:
    push { r4, lr }
    ldr     r0, [ r4, #EMMC_RESP0_REG ]
    ldr     r1, [ r4, #EMMC_RESP1_REG ]
    ldr     r2, [ r4, #EMMC_RESP2_REG ]
    ldr     r3, [ r4, #EMMC_RESP3_REG ]
    pop { r4, pc }

.section .text
emmc_SetBlockSize:
    push { lr }
        mov     r2, r0
        orr     r2, r2, r1, lsl #16
        mov     r0, #EMMC_DEVICES
        bl      devices_GetAddress
        str     r2, [ r0, #EMMC_BLKSIZECNT_REG ]
    pop { pc }

.section .text
emmc_GetData:
    push { r4, r5, lr }

    lsr     r5, r0, #2

    mov     r0, #EMMC_DEVICES
    bl      devices_GetAddress
    mov     r4, r0

    ldr     r0, [r4, #EMMC_STATUS_REG]
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r1, #0xFFFFFFFF
    str     r1, [ r4, #EMMC_INTERRUPT_REG ]
1:
    ldr     r1, [ r4, #EMMC_INTERRUPT_REG ]
    tst     r1, #EMMC_STATUS_READ_READY
    beq     1b

    ldr     r0, [ r4, #EMMC_DATA_REG ]

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    subs    r5, r5, #1
    bhi     1b
2:
    ldr     r5, [ r4, #EMMC_INTERRUPT_REG ]
    tst     r5, #EMMC_STATUS_DATA_DONE
    beq     2b

    ldr     r0, [r4, #EMMC_STATUS_REG]
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    pop { r4, r5, pc }

.section .text
emmc_IncreaseClock:
    push { lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_GetAddress
    
    // Disables clock
    ldr     r1, [ r0, #EMMC_CONTROL1_REG ]
    bic     r1, #(EMMC_CONTROL1_CLK_EN | EMMC_CONTROL1_CLK_INTLEN)
    str     r1, [ r0, #EMMC_CONTROL1_REG ]

1:
    ldr     r1, [ r0, #EMMC_CONTROL1_REG ]
    tst     r1, #EMMC_CONTROL1_CLK_STABLE
    bne     1b

    // Sets the new clock
    ldr     r1, [ r0, #EMMC_CONTROL1_REG ]
    mov     r2, #0xFF
    orr     r2, #0x300
    bic     r1, r1, r2, lsl #6
    orr     r1, #(10 << 8)
    orr     r1, #EMMC_CONTROL1_CLK_EN
    orr     r1, #EMMC_CONTROL1_CLK_INTLEN
    str     r1, [ r0, #EMMC_CONTROL1_REG ]

    // Waits for clock stable
2:
    ldr     r1, [ r0, #EMMC_CONTROL1_REG ]
    tst     r1, #EMMC_CONTROL1_CLK_STABLE
    beq     2b

    // Updates clock div
    pop { pc }

.section .text
emmc_IncreaseBandWidth:
    push { lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_GetAddress

    ldr     r1, [ r0, #EMMC_CONTROL0_REG ]
    bic     r1, #(1 << 1)
    orr     r1, r1, #(1 << 1)
    str     r1, [ r0, #EMMC_CONTROL0_REG ]

    ldr     r1, [ r0, #EMMC_CONTROL1_REG ]
    orr     r1, #EMMC_CONTROL1_SRST_DATA
    str     r1, [ r0, #EMMC_CONTROL1_REG ]
1:
    ldr     r1, [ r0, #EMMC_CONTROL1_REG ]
    tst     r1, #EMMC_CONTROL1_SRST_DATA
    bne     1b
    mov     r0, #0
    pop { pc }

/*bl      emmc_Init
 
    @ Send CMD0
    mov     r0, #0
    mov     r1, #0
    bl      emmc_SendCommand

    @ Sends CMD8
    mov     r0, #6
    mov     r2, #0x100
    mov     r1, #0x0AA
    orr     r1, r1, r2
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Sends ACMD55
1:
    mov     r0, #12
    mov     r1, #0
    bl      emmc_SendCommand

    @ Send an ACMD41
    mov     r0, #11
    mov     r1, #0x40000000
    orr     r1, #0xFF0000
    orr     r1, #0x8000
    bl      emmc_SendCommand
    tst     r0, #0x80000000
    beq     1b

    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    @ Send CMD2
    mov     r0, #2
    mov     r1, #0
    bl      emmc_SendCommand

    // Sends CMD3
    mov     r0, #3
    mov     r1, #0
    bl      emmc_SendCommand
    lsr     r0, r0, #16
    lsl     r0, r0, #16
    mov     r4, r0
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    mov     r0, #8
    mov     r1, r4
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends CMD7
    mov     r0, #5
    mov     r1, r4
    bl      emmc_SendCommand
    bl      emmc_IncreaseClock

    // Sends CMD13
2:
    mov     r0, #8
    mov     r1, r4
    bl      emmc_SendCommand
    mov     r5, r0
    mov     r1, #16
    bl      utils_u32_write
    tst     r5, #(1 << 8)
    beq     2b

    @ CMD16
    mov     r0, #9
    mov     r1, #512
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    // Sends ACMD55
    mov     r0, #12
    mov     r1, r4
    bl      emmc_SendCommand

    mov     r0, #'A'
    bl      uart0_PutByte
    bl      next_line

    @ Send an ACMD6
    mov     r0, #4
    mov     r1, #2
    bl      emmc_SendCommand
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line

    bl    emmc_IncreaseBandWidth
    
    mov     r0, #'B'
    bl      uart0_PutByte
    bl      next_line
4:
    // Sets the block size
    mov     r0, #512
    mov     r1, #1
    bl      emmc_SetBlockSize

    // Sends CMD17
    mov     r0, #10
    mov     r1, #0
    bl      emmc_SendCommand
    tst     r0, #0x800
    beq     5f

    mov     r0, #512
    bl      emmc_GetData
5:
    mov     r0, #'C'
    bl      uart0_PutByte
    bl      next_line

    // Sets the block size
    mov     r0, #512
    mov     r1, #1
    bl      emmc_SetBlockSize

    // Sends CMD17
    mov     r0, #10
    mov     r1, #0
    bl      emmc_SendCommand

    mov     r0, #512
    bl      emmc_GetData*/
