@ 
@ This file is adapted from PetterLemon, you can check it out from:
@ https://github.com/PeterLemon/RaspberryPi/blob/master/HelloWorld/DMA/LIB/R_PI.INC
@

@ Bus address
.equ PERIPHERAL_BASE,               0x20000000 @ Peripheral Base address
.equ BUS_ADDRESS_L2CACHE_ENABLED,   0x40000000 @ Bus Addresses: disable_l2CACHE = 0
.equ BUS_ADDRESS_L2CACHE_DISABLE,   0xC0000000 @ Bus Addresses: disable_l2cache = 1

@ Mailbox
.equ MAIL_BASE,     0xB880 
.equ MAIL_READ,     0x00
.equ MAIL_CONFIG,   0x1C
.equ MAIL_STATUS,   0x18
.equ MAIL_WRITE,    0x20

.equ MAIL_EMPTY,    0x40000000  @ Mailbox Status Register: Mailbox Empty (There is nothing to read from the mailbox)
.equ MAIL_FULL,     0x80000000  @ Mailbox Status Register: Mailbox Full (There is no space to write into the mailbox)

.equ MAIL_POWER,    0x00 @ Mailbox Channel 0: Power Management Interface
.equ MAIL_FB,       0x01 @ Mailbox Channel 1: Frame Buffer
.equ MAIL_VUART,    0x02 @ Mailbox Channel 2: Virtual UART
.equ MAIL_VCHIQ,    0x03 @ Mailbox Channel 3: VCHIQ Interface
.equ MAIL_LEDS,     0x04 @ Mailbox Channel 4: LEDs Interface
.equ MAIL_BUTTONS,  0x05 @ Mailbox Channel 5: Buttons Interface
.equ MAIL_TOUCH,    0x06 @ Mailbox Channel 6: Touchscreen Interface
.equ MAIL_COUNT,    0x07 @ Mailbox Channel 7: Counter
.equ MAIL_TAGS,     0x08 @ Mailbox Channel 8: Tags (ARM to VC)

