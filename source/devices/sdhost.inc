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
.equ SD_HBLC,   0x50

.equ SDHOST_CMD0,   0
.equ SDHOST_CMD1,   1
.equ SDHOST_CMD2,   2
.equ SDHOST_CMD3,   3
.equ SDHOST_CMD6,   6
.equ SDHOST_CMD7,   7
.equ SDHOST_CMD8,   8
.equ SDHOST_CMD9,   9
.equ SDHOST_CMD13,  13
.equ SDHOST_CMD16,  16
.equ SDHOST_CMD17,  17
.equ SDHOST_CMD41,  41
.equ SDHOST_CMD55,  55

@ Command options
.equ SDHOST_CMD_NEW,            1 << 15
.equ SDHOST_CMD_BUSYWAIT,       1 << 11
.equ SDHOST_CMD_NO_RESPONSE,    1 << 10
.equ SDHOST_CMD_LONG_RESPONSE,  1 << 9

@ FIFO options
.equ FIFO_READ_THRESHOLD,   4 << 14
.equ FIFO_WRITE_THRESHOLD,  4 << 9

