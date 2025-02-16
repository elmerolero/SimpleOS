.section .text
pwm_init:
    push { lr }
    mov     r0, #41
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write
    mov     r0, #45
    mov     r1, #GPIO_MODE_ALTF0
    bl      gpio_mode_write
    
    pop { pc }