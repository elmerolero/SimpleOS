@ Command indexes (CMD_INDEX)
.equ EMMC_CMD0,     (0 << 24)
.equ EMMC_CMD1,     (1 << 24)
.equ EMMC_CMD2,     (2 << 24)
.equ EMMC_CMD3,     (3 << 24)
.equ EMMC_CMD8,     (8 << 24)
.equ EMMC_CMD41,    (41 << 24)
.equ EMMC_CMD55,    (55 << 24)
.equ EMMC_CMD58,    (58 << 24)

@ Command types (CMD_TYPE flag)
.equ EMMC_CMD_TYPE_NORMAL,           (0x00 << 22)
.equ EMMC_CMD_TYPE_SUSPEND,          (0x01 << 22)
.equ EMMC_CMD_TYPE_RESUME,           (0x02 << 22)
.equ EMMC_CMD_TYPE_ABORT,            (0x03 << 22)

@ Command involves data? (CMD_ISDATA flag)
.equ EMMC_CMD_ISDATA,               (0x01 << 21)

@ Command requires index checking? (CMD_IXCHK_EN flag)
.equ EMMC_CMD_INDEX_CHECK,          (0x01 << 20)

@ Command requires CRC response checking? (CMD_CRCCHK_EN flag)
.equ EMMC_CMD_CRC_CHECK,            (0x01 << 19)

@ Command response type (CMD_RSPNS_TYPE)
.equ EMMC_CMD_RSPNS_TYPE_NONE,      (0x00 << 16)
.equ EMMC_CMD_RSPNS_TYPE_136,       (0x01 << 16)
.equ EMMC_CMD_RSPNS_TYPE_48,        (0x02 << 16)
.equ EMMC_CMD_RSPNS_TYPE_48BUSY,    (0x03 << 16)

@ Command is a multi-block transfer? (TM_MULTI_BLOCK flag)
.equ EMMC_CMD_TRANSFER_MULTIBLOCK,  (0x01 << 5)

@ Data comes from sd card (1) or from host (0)? (TM_DAT_DIR)
.equ EMMC_CMD_DATA_FROM_CARD,       (0x01 << 4)

@ 
