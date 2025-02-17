.equ PWM_BASE,  0x2020C000

.equ PWM_CTL_REG,   0x00
.equ PWM_STA_REG,   0x04
.equ PWM_DMAC_REG,  0x08
.equ PWM_RNG1_REG,  0x10
.equ PWM_DAT1_REG,  0x14
.equ PWM_FIF1_REG,  0x18
.equ PWM_RNG2_REG,  0x20
.equ PWM_DAT2_REG,  0x24

.equ PWM_ENABLE_1,  0x01
.equ PWM_CLR_FIFO,  0x40
.equ PWM_ENABLE_2,  0x100

.section .text
pwm_init:
    push { lr }
    mov     r0, #41
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write
    mov     r0, #45
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write
    
    ldr     r0, =PWM_BASE
    ldr     r1, =0x2C48
    str     r1, [ r0, #PWM_RNG1_REG ]
    str     r1, [ r0, #PWM_RNG2_REG ]

    mov     r1, #(PWM_ENABLE_1 | PWM_CLR_FIFO)
    mov     r2, #PWM_ENABLE_2
    orr     r1, r1, r2
    str     r1, [ r0, #PWM_CTL_REG ]

    pop { pc }

.section .text
pwm_write_byte:
    push { lr }

    ldr     r1, =PWM_BASE
1:
    ldr     r2, [ r1, #PWM_STA_REG ]
    and     r2, #0x01
    cmp     r2, #0x01
    bne     1b
    str     r0, [ r1, #PWM_FIF1_REG ]

    pop { pc }
