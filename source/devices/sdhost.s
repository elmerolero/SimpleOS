.equ SD_CMD,    0x00
.equ SD_ARG,    0x04
.equ SD_TOUT,   0x08
.equ SD_CDIV,   0x0C
.equ SD_RSP0,   0x10
.equ SD_RSP1,   0x14
.equ SD_RSP2,   0x18
.equ SD_RSP3,   0x1C
.equ SD_HSTS,   0x20
.equ SD_VDD,    0x30
.equ SD_EDM,    0x34
.equ SD_HCFG,   0x38
.equ SD_HBCT,   0x3C
.equ SD_DATA,   0x40
.equ SD_HCBLC,  0x50

.align 4
.section .text
sdhost_Init:
    push { lr }
    // Turns off power
    
    pop { pc }
