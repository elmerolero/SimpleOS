.include "devices/dma.inc"

.section .text
dma_Disable:
    push { lr }
    mov     r0, #DMA_DEVICES
    bl      devices_GetAddress
    mov     r4, r0

    mov     r1, #0
    str     r1, [ r0, #DMA_ENABLE_GLOBAL_REG ]
    pop { pc }
