.include "devices/gpio/gpio.inc"

.extern utils_delay
.extern utils_u32_divide

.section .text
.align 1
module_Entry:   .ascii "simple_driver"

.align 4
module_MappingStart:        .word 0x20200000
module_MappingSize:         .word 0x2C
module_InterruptId:         .word 0x1D
module_InterruptHandler:    .word 0
module_Read:                .word 0
module_Write:               .word 0
module_ModeWrite:           .word gpio_ModeWrite
module_PUDModeWrite:        .word gpio_PUDModeWrite
module_PinWrite:            .word gpio_PinWrite
module_End:                 .word 0x0C

@ ----------------------------------------------------------------------------------------------------------
@ Establece el modo del pin
@ Parameters
@ r0 - Pin Number
@ r1 - Pin mode
@ -1 Error
@  0 Exitoso
@ ----------------------------------------------------------------------------------------------------------
.section .text
gpio_ModeWrite:
    cmp         r0, #53             
    cmpls       r1, #GPIO_MODE_MAX
    bhi         3f
    push {r4, lr}            
    mov         r2, r0                  // Pin number
    mov         r3, r1                  // Pin mode
    ldr         r0, gpio_Entry
    ldr         r0, [ r0 ]
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
gpio_PUDModeWrite:
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
    ldr         r0, gpio_Entry
    ldr         r0, [ r0 ]
    
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

    ldr     r0, gpio_Entry
    ldr     r0, [ r0 ]
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
gpio_PinWrite:
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
    ldr     r0, gpio_Entry
    ldr     r0, [ r0 ]
    ldr     r3, [ r0, r2 ]
    orr     r3, r3, r5
    str     r3, [ r0, r2 ]
    
    pop { r4, r5, lr }

gpio_Entry: .word module_Entry
