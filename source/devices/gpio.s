.include "utils/assembler.s"

// GPIO pin range
.equ GPIO_PIN_MIN,  0
.equ GPIO_PIN_MAX,  53

// Available pin modes 
.equ GPIO_MODE_INPUT,   0
.equ GPIO_MODE_OUTPUT,  1
.equ GPIO_MODE_ALTF0,   4
.equ GPIO_MODE_ALTF1,   5
.equ GPIO_MODE_ALTF2,   6
.equ GPIO_MODE_ALTF3,   7
.equ GPIO_MODE_ALTF4,   3
.equ GPIO_MODE_ALTF5,   2
.equ GPIO_MODE_MIN,     0
.equ GPIO_MODE_MAX,     7

// Available pull up/down mode
.equ GPIO_PUD_MODE_DISABLE,     0
.equ GPIO_PUD_MODE_DOWN_ENABLE, 1
.equ GPIO_PUD_MODE_UP_ENABLE,   2
.equ GPIO_PUD_MODE_MIN,         0
.equ GPIO_PUD_MODE_MAX,         2

// Registers to set
.equ GPIO_PIN_LOW,      0
.equ GPIO_PIN_HIGH,     1
.equ GPIO_PIN_WRITE_MIN, 0
.equ GPIO_PIN_WRITE_MAX, 1

/* Registers to set pin mode */
.equ GPIO_GPFSEL0,  0x0 
.equ GPIO_GPFSEL1,  0x4
.equ GPIO_GPFSEL2,  0x8
.equ GPIO_GPFSEL3,  0xC
.equ GPIO_GPFSEL4,  0x10
.equ GPIO_GPFSEL5,  0x14

/* Pin Set - To give a positive output */
.equ GPIO_GPSET0,   0x1C
.equ GPIO_GPSET1,   0x20

/* Pin Clear - To give a negative output */
.equ GPIO_GPCLR0,   0x28
.equ GPIO_GPCLR1,   0x2C

/* Niveles del pin */
.equ GPIO_GPLEV0,   0x34
.equ GPIO_GPLEV1,   0x38

/* Estado de evento detectado (Evect Detect Status) */
.equ GPIO_GPEDS0,   0x40
.equ GPIO_GPEDS1,   0x44

/* Rising Edge Detect Enable */
.equ GPIO_GPREN0,   0x4C
.equ GPIO_GPREN1,   0x50

/* FAlling Edge Detect Enable */
.equ GPIO_GPFEN0,   0x58 
.equ GPIO_GPFEN1,   0x5C

/* High Detect Enable */
.equ GPIO_GPHEN0,   0x64
.equ GPIO_GPHEN1,   0x68

/* GPIO Pin Low Detect Enable */
.equ GPIO_GPLEN0,   0x70
.equ GPIO_GPLEN1,   0x74

/* GPIO Pin Async. Rising Edge Detect */
.equ GPIO_GPAREN0,  0x7C
.equ GPIO_GPAREN1,  0x80

/* GPIO Pin Asyn. Falling Edge Detect */
.equ GPIO_GPAFEN0,  0x88
.equ GPIO_GPAFEN1,  0x8C

/* Pin pull-up/down Enable */
.equ GPIO_GPPUD,        0x94
.equ GPIO_GPPUDCLK0,    0x98
.equ GPIO_GPPUDCLK1,    0x9C

// GPIO PUD mode write errors
.equ GPIO_ERROR_INVALID_PIN,        0xFFFFFFFF
.equ GPIO_ERROR_INVALID_PIN_MODE,   0xFFFFFFFE
.equ GPIO_ERROR_INVALID_PUD_MODE,   0xFFFFFFFE

@ ----------------------------------------------------------------------------------------------------------
@ Establece el modo del pin
@ Parameters
@ r0 - Pin Number
@ r1 - Pin mode
@ -1 Error
@  0 Exitoso
@ ----------------------------------------------------------------------------------------------------------
.section .text
gpio_ModeSet:
    cmp         r0, #53             
    cmpls       r1, #GPIO_MODE_MAX
    bhi         3f
    push {r4, lr}            
    mov         r2, r0                  // Pin number
    mov         r3, r1                  // Pin mode
    mov         r0, #GPIO_DEVICES
    bl          devices_GetAddress
1:
    cmp         r2, #10                 // If r2 < 10 goes next step
    bmi         2f                      
    add         r0, #4 
    sub         r2, #10
    b           1b
2:
    add         r2, r2, r2, lsl #1      // r3 << (r2 * 3)
    ldr         r1, [ r0 ]              // r1 = GPIOSELX
    mov         r4, #7              
    mvn         r4, r4, lsl r2      
    and         r1, r1, r4          
    orr         r1, r1, r3, lsl r2      // r1 | (r3 << r2)
    str         r1, [ r0 ]          
    mov         r0, #0  
    b           4f
3:
    mov         r0,     #-1
4:
    pop {r4, pc}            @ Finaliza


@ ----------------------------------------------------------------------------------------------------------
@ Sets the indicated pull up/down mode for specific pin
@ Parameters
@ r0 - Pin Number (0 - 53)
@ r1 - Pull up/down mode (0 - 2)
@ Error codes:
@ 0xFFFFFFFF - pin given is invalid.
@ 0xFFFFFFFE - pud mode given is invalid.
@ ----------------------------------------------------------------------------------------------------------
.section .text
gpio_pud_mode_write:
    cmp     r0, #GPIO_MODE_MAX
    movhi   r0, #GPIO_ERROR_INVALID_PIN
    bxhi    lr
    cmp     r1, #GPIO_PUD_MODE_MAX
    movhi   r1, #GPIO_ERROR_INVALID_PUD_MODE
    bxhi    lr

    push { r4, r5, r6, lr } 

    // Backs up the mode that will be updated
    mov     r4, r1

    // We get the bit for the desired pin and the offset
    mov     r0, r4
    mov     r1, #32
    bl      math_u32_divide
    mov     r5, r0
    mov     r6, r1

    // Gets GPIO address
    mov     r0, #GPIO_DEVICES
    bl      devices_GetAddress
    
    // Set GPPUD mode
    str     r4, [ r0, #GPIO_GPPUD ]
    lsl     r3, r5, #2
    add     r2, r3, #GPIO_GPPUDCLK0
    mov     r3, #1
    lsl     r3, r3, r6
    str     r3, [ r0, r2 ]

    // Wait 150 cycles required again
    mov     r0, #150
    bl      utils_delay

    mov     r0, #GPIO_DEVICES
    bl      devices_GetAddress
    mov     r3, #0
    str     r3, [ r0, #GPIO_GPPUD ]
    str     r3, [ r0, r2 ]
    mov     r0, #0

    pop { r4, r5, r6, pc }


@ ----------------------------------------------------------------------------------------------------------
@ Writes a pin output
@ r0 - Pin number (0 - 53)
@ r1 - Pin output (0 - 1)
@ Error codes:
@ 0xFFFFFFFF - pin given is invalid.
@ ----------------------------------------------------------------------------------------------------------
.section .text
gpio_PinSet:
    cmp     r0, #GPIO_PIN_MAX
    movhi   r0, #GPIO_ERROR_INVALID_PIN
    bxhi    lr

    push { r4, r5, lr } 

    // Makes sure that value to write is zero or one and saves result in r4
    and     r4, r1, #GPIO_PIN_WRITE_MAX

    // We get the bit for the desired pin and the offset
    mov     r1, #32
    bl      math_u32_divide
    
    // Result is multiplied by 4
    lsl     r0, r0, #2

    // Sets the offset for specified pin
    mov     r3, #1
    lsl     r5, r3, r1

    cmp     r4, #GPIO_PIN_LOW
    addeq   r2, r0, #GPIO_GPCLR0
    addne   r2, r0, #GPIO_GPSET0

    // Sets the value
    mov     r0, #GPIO_DEVICES
    bl      devices_GetAddress
    ldr     r3, [ r0, r2 ]
    orr     r3, r3, r5
    str     r3, [ r0, r2 ]
    
    pop { r4, r5, lr }
