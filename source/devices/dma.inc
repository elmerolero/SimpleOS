// Global DMA registers
.equ DMA_INTERRUPT_STATUS_GLOBAL_REG,   0xFE0
.equ DMA_ENABLE_GLOBAL_REG,             0xFF0

// Offsets per each DMA channel
.equ DMA_CONTROL_STATUS_REG,            0x00
.equ DMA_CONTROL_BLOCK_ADDRESS_REG,     0x04
.equ DMA_CB_TRANSFER_INFORMATION_REG,   0x08
.equ DMA_CB_SOURCE_ADDRESS_REG,         0x0C
.equ DMA_CB_DESTINATION_ADDRESS_REG,    0x10
.equ DMA_CB_TRANSFER_LENGTH_REG,        0x14
.equ DMA_CB_STRIDE_REG,                 0x18
.equ DMA_CB_NEXT_ADDRESS,               0x1C
.equ DMC_CB_DEBUG,                      0x20
