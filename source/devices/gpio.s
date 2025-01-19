/*  */
.equ GPIO_BASE,  0x20200000 

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
gpio_setMode:
    cmp         r0, #53             @ Compara el pin indicado (r0) con 53
    cmpls       r1, #7
    bhi         gpio_setModeError   @ If r0 > 53 then setModeError
    push        {r4, lr}            @ 
    ldr         r2, =GPIO_BASE      @ Carga la dirección base
gpio_setModeLoop:
    cmp         r0, #10             @ Se verifica que sea menor que diez
    bmi         gpio_mode           @ Sale del bucle
    add         r2, #4              @ Incrementa la dirección base en dos (cambiará en )
    sub         r0, #10
    b           gpio_setModeLoop
gpio_mode:
    add         r0, r0, r0, lsl #1  @ r0 = r0 * 3 (each pin mode is represented by 3 bits)
    lsl         r1, r1, r0          @ Se desplaza ALTFX hacia el campo correspondiente indicado por r0
    ldr         r3, [ r2 ]          @ Carga en r3 el contenido de r2 (los cuatro bytes de GPFSELX)
    mov         r4, #7              @ Se mueve el numero 7 en r4
    mvn         r4, r4, lsl r0      @ Se desplaza y su valor negado seguarda ahí mismo
    and         r3, r3, r4          @ Limpia el espacio que se desea establecer
    orr         r1, r1, r3          @ Graba el nuevo modo en el espacio 
    str         r1, [ r2 ]          @ Se guarda la nueva configuración en el espacio al que apunta r2
    mov         r0, #0              @ Indica que finalizó correctamente 
    b           gpio_setModeEnd
gpio_setModeError:
    mov         r0,     #-1
    mov         pc,     lr
gpio_setModeEnd:
    pop         {r4, pc}            @ Finaliza


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

    push { r4, lr } 

    // Backs up the mode that will be updated
    mov     r4, r1

    // We get the bit for the desired pin and the offset
    mov     r1, #32
    bl      math_u32_divide
    
    // Select d

    // Prepares the PUD mode the pin will receive
    ldr     r2, =GPIO_BASE
    str     r4, [ r2, #GPIO_GPPUD ]

    lsl     r3, #2
    add     r0, r3, #GPIO_GPPUDCLK0
    mov     r3, #1
    lsl     r3, r3, r1
    str     r3, [ r2, r0 ]
    mov     r1, r0

    // Wait 150 cycles required again
    mov     r0, #150
    bl      utils_delay

    mov     r3, #0
    str     r3, [ r2, #GPIO_GPPUD ]
    str     r3, [ r2, r1 ]
    mov     r0, #0

    pop { r4, pc }


@ ----------------------------------------------------------------------------------------------------------
@ Sets the 
@ Parameters
@ r0 - Pin Number (0 - 53)
@ r1 - Pull up/down mode (0 - 2)
@ Error codes:
@ 0xFFFFFFFF - pin given is invalid.
@ ----------------------------------------------------------------------------------------------------------
.section .text
gpio_pin_write:
    cmp     r0, #GPIO_PIN_MAX
    movhi   r0, #GPIO_ERROR_INVALID_PIN
    bxhi    lr

    push { r4, lr } 

    // Makes sure that value to write is zero or one and saves result in r4
    and     r4, r1, #GPIO_PIN_WRITE_MAX

    // We get the bit for the desired pin and the offset
    mov     r1, #32
    bl      math_u32_divide
    
    // Result is multiplied by 4
    lsl     r0, r0, #2

    // Sets the offset for specified pin
    mov     r3, #1
    lsl     r1, r3, r1

    cmp     r4, #GPIO_PIN_LOW
    addeq   r0, r0, #GPIO_GPCLR0
    addne   r0, r0, #GPIO_GPSET0

    // Sets the value
    ldr     r2, =GPIO_BASE
    ldr     r3, [ r2, r0 ]
    orr     r3, r3, r1
    str     r3, [ r2, r0 ]
    
    pop { r4, lr }
