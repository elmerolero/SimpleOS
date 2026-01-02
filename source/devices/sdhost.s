/* BCM2835 SD host driver
 * Author: Ismael Salas López
 * Based on:
 * bcm2835-sdhost.c by Phil Elwell
 * which is, in turn based on
 *  mmc-bcm2835.c by Gellert Weisz
 * which is, in turn, based on
 *  sdhci-bcm2708.c by Broadcom
 *  sdhci-bcm2835.c by Stephen Warren and Oleksandr Tymoshenko
 *  sdhci.c and sdhci-pci.c by Pierre Ossman
 *
 * This fragment of this program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 */

.include "devices/sdhost.inc"

.align 4
.section .data
sdhost_Commands:
    .word SDHOST_CMD0 | SDHOST_CMD_NO_RESPONSE | SDHOST_CMD_NEW
    .word SDHOST_CMD1 | SDHOST_CMD_NEW
    .word SDHOST_CMD2 | SDHOST_CMD_LONG_RESPONSE | SDHOST_CMD_NEW
    .word SDHOST_CMD3 | SDHOST_CMD_NEW
    .word SDHOST_CMD6 | SDHOST_CMD_NEW
    .word SDHOST_CMD7 | SDHOST_CMD_NEW
    .word SDHOST_CMD8 | SDHOST_CMD_NEW
    .word SDHOST_CMD9 | SDHOST_CMD_NEW
    .word SDHOST_CMD13 | SDHOST_CMD_NEW
    .word SDHOST_CMD16 | SDHOST_CMD_NEW
    .word SDHOST_CMD17 | SDHOST_CMD_NEW
    .word SDHOST_CMD41 |SDHOST_CMD_NEW
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

    ldr     r0, [ r4, #SD_VDD ]

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
    bl      sdhost_GetCommandFromIndex
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
    orr     r0, r0, r1
    strne   r0, [ r4, #SD_HSTS ]

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
    ldr     r0, [ r4, #SD_RSP0 ]
    ldr     r1, [ r4, #SD_RSP1 ]
    ldr     r2, [ r4, #SD_RSP2 ]
    ldr     r3, [ r4, #SD_RSP3 ]
    pop { r4, pc }

.section .text
sdhost_GetStatus:
    push { lr }
    mov     r0, #SD_HOST_DEVICES
    bl      devices_GetAddress

    ldr     r0, [ r0, #SD_HSTS ]
    pop { pc }

.align 4
.section .text
sdhost_GetCommandFromIndex:
    push { lr }
    ldr     r1, =sdhost_Commands
    ldr     r0, [ r1, r0, lsl #2 ]
    pop { pc }
