@ Mini UART
.equ AUX_MU_IO_REG,         0x00
.equ AUX_MU_IER_REG,        0x04
.equ AUX_MU_IIR_REG,        0x08
.equ AUX_MU_LCR_REG,        0x0C
.equ AUX_MU_MCR_REG,        0x10
.equ AUX_MU_LSR_REG,        0x14
.equ AUX_MU_MSR_REG,        0x18
.equ AUX_MU_SCRATCH_REG,    0x1C
.equ AUX_MU_CNTL_REG,       0x20
.equ AUX_MU_STAT_REG,       0x24
.equ AUX_MU_BAUD_REG,       0x28 

.equ MU_DATA_SIZE_7,        0x01
.equ MU_DATA_SIZE_8,        0x03

.equ MU_DISABLE,            0x00
.equ MU_RECEIVER,           0x01
.equ MU_TRANSMITER,         0x02

.equ MU_INTERRUPTS_DISABLE, 0x00
.equ MU_RECEIVE_INTERRUPT,  0x01
.equ MU_TRANSMIT_INTERRUPT, 0x02

@ Interrupt status
.equ AUX_MU_NO_INTERRUPT_PENDING,   0x01
.equ AUX_MU_TRANSMITER_AVAILABLE,   0x02
.equ AUX_MU_RECEIVER_PENDING,       0x04

.equ GPIO_MODE_ALTF5,       2
.equ GPIO_PUD_MODE_DISABLE, 0

.equ AUX_MU_BUFFER_SIZE, 1024
