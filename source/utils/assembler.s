.macro imm32 reg, value
    mov \reg, #(\value & 0xFF)
    orr \reg, #(\value & 0xFF00)
    orr \reg, #(\value & 0xFF0000)
    orr \reg, #(\value & 0xFF000000)
.endm
