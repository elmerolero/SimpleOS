.equ CMD0,   0    @ GO_IDLE_STATE         Goes to idle state
.equ CMD1,   1    @ SEND_OP_COND          Initializes eMMC and returns OCR
.equ CMD2,   2    @ ALL_SEND_CID          Retuns CID
.equ CMD3,   3    @ SET_RELATIVE_ADDR     Assigns or queries the RCA
.equ CMD6,   6    @ SWITCH                Changes operation mode or set registers
.equ CMD7,   7    @ SELECT/DESELECT_CARD  Selects and unselects a card
.equ CMD8,   8    @ IF_COND               Checks if card works with given voltage
.equ CMD9,   9    @ SEND_CSD              Asks for card-specific data CSD
.equ CMD13, 13    @ SEND_STATUS           Checks card status
.equ CMD17, 17    @ READ_SINGLE_BLOCK     Reads a block
.equ CMD18, 18    @ READ_MULTIPLE_BLOCK   Reads multiple blocks
.equ CMD24, 24    @ WRITE_SINGLE_BLOCK    Writes only one block
.equ CMD25, 25    @ WRITE_MULTIPLE_BLOCK  Writes multiple blocks
.equ CMD55, 55    @ APP_CMD (SD)          Prepara comando ACMD (solo en tarjetas SD)
.equ CMD58, 58    @ READ_OCR (SDIO/SDHC)  Read OCR in SD Cards
