.include "./devices/sd.s"

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

@ Command types
.equ EMMC_CMDTYPE_NORMAL,   0x00
.equ EMMC_CMDTYPE_SUSPEND,  0x01
.equ EMMC_CMDTYPE_RESUME,   0x02
.equ EMMC_CMDTYPE_ABORT,    0x02

@ Command status
.equ EMMC_INTERRUPT_CBAD_ERR, (0x01 << 20)
.equ EMMC_INTERRUPT_CBAD_ERR, (0x01 << 19)
.equ EMMC_INTERRUPT_CEND_ERR, (0x01 << 18)
.equ EMMC_INTERRUPT_CMD_DONE, (0x01 << 0)

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
    mov     r0, #(EMMC_INTERRUPT_CEND_ERR | EMMC_INTERRUPT_CBAD_ERR)
    orr     r0, #EMMC_INTERRUPT_CMD_DONE
    str     r0, [ r1, #EMMC_IRPT_MASK_REG ]

    @ Set settings and enables
    ldr     r0, [ r1, #EMMC_CONTROL1_REG ]
    str     r0, [ r1, #EMMC_CONTROL1_REG ]
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
@ Send a command.
@ Inputs
@   r0 - Command
@   r1 - Arguments
@ Outputs
@   None
@ ------------------------------------------------------------------------------
.section .text
emmc_CmdSend:
    push { r4, lr }
    @ Backs up r0 and r1
    lsl     r3, r0, #24
    mov     r4, r1
    mov     r0, #EMMC_DEVICES
    bl      devices_AddressGet
    
    @ Writes argument into ARG1 register
    str     r4, [ r0, #EMMC_ARG1_REG ]
    @ Writes the command into CMDTM register
    str     r3, [ r0, #EMMC_CMDTM_REG ]
    @
    mov     r1, #0
    str     r1, [ r0, #EMMC_INTERRUPT_REG ]
1:
    @ Waits for CMD_DONE_STATUS
    ldr     r1, [ r0, #EMMC_INTERRUPT_REG ]
    tst     r1, #EMMC_INTERRUPT_CMD_DONE
    bne     2f
    tst     r1, #(EMMC_INTERRUPT_CEND_ERR | EMMC_INTERRUPT_CBAD_ERR)
    bne     3f
    b       1b
2:
    mov     r1, #EMMC_INTERRUPT_CMD_DONE
    str     r1, [ r0, #EMMC_INTERRUPT_REG ]
    mov     r0, #'S'
    b       4f
3:
    mov     r1, #1
    str     r1, [ r0, #EMMC_INTERRUPT_REG ]
    mov     r0, #'E'
4:
    pop { r4, pc }
    
