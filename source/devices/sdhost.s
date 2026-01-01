.include "devices/sdhost.inc"

.align 4
.section .data
sdhost_Commands:
    .word SDHOST_CMD0 | SDHOST_CMD_NO_RESPONSE | SDHOST_CMD_NEW
    .word SDHOST_CMD1
    .word SDHOST_CMD2
    .word SDHOST_CMD3
    .word SDHOST_CMD6
    .word SDHOST_CMD7
    .word SDHOST_CMD8 | SDHOST_CMD_NEW
    .word SDHOST_CMD9 
    .word SDHOST_CMD13 
    .word SDHOST_CMD16 
    .word SDHOST_CMD17
    .word SDHOST_CMD41
    .word SDHOST_CMD55 | SDHOST_CMD_NEW

.align 4
.section .text
sdhost_Init:
    push { r4, lr }

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
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_SetMode

    mov     r0, #49
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_SetMode

    mov     r0, #50
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_SetMode

    mov     r0, #51
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_SetMode

    mov     r0, #52
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_SetMode

    mov     r0, #53
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_SetMode

    mov     r0, #SD_HOST_DEVICES
    bl      devices_GetAddress
    mov     r4, r0

    // Turns off power
    mov     r0, #0
    str     r0, [ r4, #SD_VDD ]
    str     r0, [ r4, #SD_CMD ]
    str     r0, [ r4, #SD_ARG ]
    str     r0, [ r4, #SD_CDIV ]
    str     r0, [ r4, #SD_HCFG ]
    str     r0, [ r4, #SD_HBCT ]
    str     r0, [ r4, #SD_HBLC ]

    mov     r0, #0xF00000
    str     r0, [ r4, #SD_TOUT ]
    mov     r0, #0xF8
    orr     r0, r0, #0x700
    str     r0, [ r4, #SD_HSTS ]
    
    ldr     r0, [ r4, #SD_EDM ]
    mov     r1, #0x1F
    lsl     r1, r1, #9
    bic     r0, r0, r1
    orr     r0, #FIFO_READ_THRESHOLD
    lsl     r1, r1, #5
    bic     r0, r1
    orr     r0, #FIFO_WRITE_THRESHOLD
    str     r0, [ r4, #SD_EDM ]

    mov     r0, #0xFF00
    bl      utils_delay
    mov     r0, #1
    str     r0, [ r4, #SD_VDD ]
    mov     r0, #0xFF00
    bl      utils_delay

    mov     r0, #0xFF
    orr     r0, #0x700
    str     r0, [ r4, #SD_CDIV ]

    pop { r4, pc }

/*
    r0, command
    r1, argument
 */
.section .text
sdhost_SendCommand:
    push { r4, r5, r6, lr }
    mov     r6, r1
    @ Gets the command and saves it in r5
    bl      emmc_GetCommandFromIndex
    mov     r5, r0
    mov     r0, #SD_HOST_DEVICES
    bl      devices_GetAddress
    mov     r4, r0
1:
    ldr     r0, [ r4, #SD_CMD ]
    tst     r0, #(1 << 15)
    bne     1b

    ldr     r0, [ r4, #SD_HSTS ]
    mov     r1, #(0x1f << 3)
    tst     r0, r1
    strne   r1, [ r4, #SD_HSTS ]

    str     r6, [ r4, #SD_ARG ]
    str     r5, [ r4, #SD_CMD ]

2:
    ldr     r0, [ r4, #SD_CMD ]
    tst     r0, #(1 << 15)
    bne     2b

    ldr     r0, [ r4, #SD_HSTS ]
    mov     r1, #(0x1f << 3)
    tst     r0, #EMMC_RESP1_REG
    mov     r0, #'S'
    movne   r0, #'E'

    pop { r4, r5, r6, pc }

@ ------------------------------------------------------------------------------
@ Reads a response.
@ Inputs
@   r0 - Response index
@ Outputs
@   r0 - Response from the SD HOST
@ ------------------------------------------------------------------------------
.section .text
sdhost_GetResponse:
    push { r4, lr }
    mov     r0, #SD_HOST_DEVICES
    bl      devices_GetAddress
    mov     r4, r0
    ldr     r0, [ r4, #EMMC_RESP0_REG ]
    ldr     r1, [ r4, #EMMC_RESP1_REG ]
    ldr     r2, [ r4, #EMMC_RESP2_REG ]
    ldr     r3, [ r4, #EMMC_RESP3_REG ]
    pop { r4, pc }
