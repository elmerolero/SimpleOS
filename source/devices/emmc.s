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
.equ EMMC_CONTROL1_DATA_TOUNIT,  (0x0F << 16)
.equ EMMC_CONTROL1_CLK_EN,       (0x01 << 2)
.equ EMMC_CONTROL1_CLK_STABLE,   (0x01 << 1)
.equ EMMC_CONTROL1_CLK_INTLEN,   (0x01 << 0)

@ Command status
.equ EMMC_INTERRUPT_DTO_ERR, (0x01 << 20)
.equ EMMC_INTERRUPT_CBAD_ERR, (0x01 << 19)
.equ EMMC_INTERRUPT_CEND_ERR, (0x01 << 18)
.equ EMMC_INTERRUPT_CMD_DONE, (0x01 << 0)

.section .data
.align 4
emmc_Commands:
    .word EMMC_CMD0 | EMMC_CMD_INDEX_CHECK
    .word EMMC_CMD1 | EMMC_CMD_CRC_CHECK | EMMC_CMD_INDEX_CHECK
    .word EMMC_CMD2 | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_136
    .word EMMC_CMD3 | EMMC_CMD_CRC_CHECK | EMMC_CMD_INDEX_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word CMD6
    .word EMMC_CMD7 | EMMC_CMD_CRC_CHECK | EMMC_CMD_INDEX_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD8 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD9 | EMMC_CMD_RSPNS_TYPE_136
    .word EMMC_CMD13 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD16 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48
    .word EMMC_CMD17 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_ISDATA | EMMC_CMD_IS_DATA_FROM_CARD | EMMC_CMD_RSPNS_TYPE_48 | EMMC_CMD_COUNT_ENABLE
    .word EMMC_CMD41 | EMMC_CMD_RSPNS_TYPE_48BUSY
    .word EMMC_CMD55 | EMMC_CMD_INDEX_CHECK | EMMC_CMD_CRC_CHECK | EMMC_CMD_RSPNS_TYPE_48

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
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet
    mov     r1, r0

    @ Resets the controller
    mov     r0, #(EMMC_CONTROL1_SRST_DATA | EMMC_CONTROL1_SRST_CMD | EMMC_CONTROL1_SRST_HC)
    orr     r0, r0, #EMMC_CONTROL1_DATA_TOUNIT
    str     r0, [ r1, #EMMC_CONTROL1_REG ]

    @Waits for reset
1:
    ldr     r0, [ r1, #EMMC_CONTROL1_REG ]
    tst     r0, #EMMC_CONTROL1_SRST_HC
    bne     1b

    @ Clear status register
    mov     r0, #0
    str     r0, [ r1, #EMMC_CONTROL0_REG ]
    str     r0, [ r1, #EMMC_STATUS_REG ]
    str     r0, [ r1, #EMMC_INTERRUPT_REG ]
    str     r0, [ r1, #EMMC_IRPT_MASK_REG ]
    str     r0, [ r1, #EMMC_IRPT_EN_REG ]

    @ Enables interrupts mask
    mov     r0, #0xFFFFFFFF
    str     r0, [ r1, #EMMC_IRPT_MASK_REG ]

    @ Set settings and enables
    ldr     r0, [ r1, #EMMC_CONTROL1_REG ]
    orr     r0, r0, #EMMC_CONTROL1_DATA_TOUNIT
    orr     r0, r0, #EMMC_CONTROL1_CLK_EN
    orr     r0, r0, #(32 << 8)
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
emmc_CmdSend:
    push { r4, lr }

    @ Backs up the argument (r1)
    mov     r4, r1

    @ Gets the command and saves it in r3
    bl      emmc_CmdRead
    mov     r3, r0

    mov     r0, #256
    bl      utils_delay

    @ Gets the device
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet

    @
    mov     r1, #0xFFFFFFFF
    str     r1, [ r0, #EMMC_INTERRUPT_REG ]

    @ Writes argument into ARG1 register
    str     r4, [ r0, #EMMC_ARG1_REG ]

    @ Writes the command into CMDTM register
    str     r3, [ r0, #EMMC_CMDTM_REG ]

1:
    @ Waits for CMD_DONE_STATUS
    ldr     r1, [ r0, #EMMC_INTERRUPT_REG ]
    tst     r1, #EMMC_INTERRUPT_CMD_DONE
    bne     2f
    tst     r1, #(EMMC_INTERRUPT_CEND_ERR | EMMC_INTERRUPT_CBAD_ERR | EMMC_INTERRUPT_DTO_ERR)
    bne     3f
    b       1b
2:
    mov     r4, r0
    mov     r0, #'S'
    b       4f
3:
    mov     r4, r0
    mov     r0, #'E'
4:
    pop { r4, pc }

@-------------------------------------------------------------------------------
@ Gets status
@ Inputs
@   None
@ Outputs
@   r0 - Status from eMMC
@-------------------------------------------------------------------------------
.section .text
emmc_StatusRead:
    push { lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet
    ldr     r0, [ r0, #EMMC_INTERRUPT_REG ]
    pop  { pc }

@-------------------------------------------------------------------------------
@ Waits for a completed sending or error
@ Inputs
@   None
@ Outputs
@   r0 - Status
@-------------------------------------------------------------------------------
.section .text
emmc_DoneErrorWait:
    push { lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet

1:
    ldr     r1, [ r0, #EMMC_INTERRUPT_REG ]
    @ Checks for CMD_DONE_STATUS
    tst     r1, #EMMC_INTERRUPT_CMD_DONE
    bne     2f

    @ Checks for CMD_ERR
    tst     r1, #(1 << 15)
    beq     1b
2:
    pop { pc }
@ ------------------------------------------------------------------------------
@ Reads a response.
@ Inputs
@   r0 - Response index
@ Outputs
@   r0 - Response from eMMC
@ ------------------------------------------------------------------------------
.section .text
emmc_ResponseRead:
    push { r4, lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet
    mov     r4, r0
    ldr     r0, [ r4, #EMMC_RESP0_REG ]
    ldr     r1, [ r4, #EMMC_RESP1_REG ]
    ldr     r2, [ r4, #EMMC_RESP2_REG ]
    ldr     r3, [ r4, #EMMC_RESP3_REG ]
    pop { r4, pc }

.section .text
emmc_BlockSizeWrite:
    push { lr }
        mov     r2, r0
        orr     r2, r2, r1, lsl #16
        mov     r0, #EMMC_DEVICES
        bl      devices_AddressGet
        str     r2, [ r0, #EMMC_BLKSIZECNT_REG ]
    pop { pc }

.section .text
emmc_DataRead:
    push { r4, r5, lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet
    mov     r4, r0

    mov     r1, #0xFFFFFFFF
    str     r1, [ r4, #EMMC_INTERRUPT_REG ]

1:
    ldr     r5, [ r4, #EMMC_INTERRUPT_REG ]
    tst     r5, #(1 << 5)
    beq     1b

    ldr     r0, [ r4, #EMMC_DATA_REG ]
    mov     r1, #16
    bl      utils_u32_write
    bl      next_line
    tst     r5, #(1 << 1)
    beq     1b

    pop { r4, r5, pc }

.section .text
emmc_ResponseClear:
    push { lr }
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet
    mov     r1, #0
    str     r1, [ r0, #EMMC_RESP0_REG ]
    str     r1, [ r0, #EMMC_RESP1_REG ]
    str     r1, [ r0, #EMMC_RESP2_REG ]
    str     r1, [ r0, #EMMC_RESP3_REG ]
    pop { pc }

.section .text
emmc_CmdRead:
    push { lr }
    ldr     r1, =emmc_Commands
    ldr     r0, [ r1, r0, lsl #2 ]
    pop { pc }
