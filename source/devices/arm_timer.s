// Time base
.equ ARM_TIMER_LOAD,        0x00
.equ ARM_TIMER_VALUE,       0x04
.equ ARM_TIMER_CONTROL,     0x08
.equ ARM_TIMER_IRQ_CLEAR,   0x0C
.equ ARM_TIMER_RAW_IRQ,     0x10
.equ ARM_TIMER_MASKED_IRQ,  0x14
.equ ARM_TIMER_RELOAD,      0x18
.equ ARM_TIMER_PREDIVIDER,  0x1C
.equ ARM_TIMER_FREE_RUNNING_COUNTER, 0x20

.equ ARM_TIMER_CTRL_16BIT, 0x00
.equ ARM_TIMER_CTRL_32BIT, 0x02

.equ ARM_TIMER_CTRL_PRESCALE_1,     0x00
.equ ARM_TIMER_CTRL_PRESCALE_16,    0x04
.equ ARM_TIMER_CTRL_PRESCALE_256,   0x08

.equ ARM_TIMER_CTRL_INT_ENABLE, 0x20
.equ ARM_TIMER_CTRL_INT_DISABLE, 0x00

.equ ARM_TIMER_CTRL_ENABLE, 0x80
.equ ARM_TIMER_CTRL_DISABLE, 0x00

.section .text
.global arm_timer_init
arm_timer_init:
    push { lr }
    mov     r0, #ARM_TIMER_DEVICES
    bl      devices_AddressGet
    mov     r1, #0x400
    str     r1, [ r0, #ARM_TIMER_LOAD ]
    mov     r1, #(ARM_TIMER_CTRL_32BIT | ARM_TIMER_CTRL_ENABLE | ARM_TIMER_CTRL_INT_ENABLE | ARM_TIMER_CTRL_PRESCALE_256)
    str     r1, [ r0, #ARM_TIMER_CONTROL ]
    pop { pc }

.section .text
.global arm_timer_value_read
arm_timer_value_read:
    push { lr }
    mov     r0, #ARM_TIMER_DEVICES
    bl      devices_AddressGet
    ldr     r0, [ r0, #ARM_TIMER_VALUE ]
    pop  { pc }

.section .text
.global arm_timer_irq_clear
arm_timer_irq_clear:
    push { lr }
    mov     r0, #ARM_TIMER_DEVICES
    bl      devices_AddressGet
    mov     r1, #1
    str     r1, [ r0, #ARM_TIMER_IRQ_CLEAR ]
    pop { pc }
