.equ CLOCK_MANAGER_BASE,     0x20101000

.equ CLOCK_MANAGER_PWMCTL_REG,      0xA0
.equ CLOCK_MANAGER_PWMDIV,          0xA4

.equ CLOCK_MANAGER_PASSWORD,        0x5A000000
.equ CLOCK_MANAGER_SRC_OSCILLATOR,  0x01
.equ CLOCK_MANAGER_SRC_PLLCPER,     0x05
.equ CLOCK_MANAGER_ENABLE,          0x10


.section .text
clock_manager_init:
    push { lr }
    imm32   r0, CLOCK_MANAGER_BASE
    mov     r1, #0
    str     r1, [ r0, #CLOCK_MANAGER_PWMCTL_REG ]
    /*imm32   r1, (CLOCK_MANAGER_PASSWORD | (0x4000))
    str     r1, [ r0, #CLOCK_MANAGER_PWMDIV ]
    imm32   r1, (CLOCK_MANAGER_ENABLE | CLOCK_MANAGER_PASSWORD | CLOCK_MANAGER_SRC_PLLCPER)
    str     r1, [ r0, #CLOCK_MANAGER_PWMCTL_REG ]*/
    pop  { pc }


