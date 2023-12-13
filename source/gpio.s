.equ GPIO_BASE,  0x20200000 

/* Funciones alternativas (Alternate functions) */
.equ GPIO_GPFSEL0,  0x0 
.equ GPIO_GPFSEL1,  0x4
.equ GPIO_GPFSEL2,  0x8
.equ GPIO_GPFSEL3,  0xC
.equ GPIO_GPFSEL4,  0x10
.equ GPIO_GPFSEL5,  0x14

/* Funciones de los pines */
.equ GPIO_INPUT,    0x00
.equ GPIO_OUTPUT,   0x01
.equ GPIO_ALTF0,    0x04
.equ GPIO_ALTF1,    0x05
.equ GPIO_ALTF2,    0x06
.equ GPIO_ALTF3,    0x07
.equ GPIO_ALTF4,    0x03
.equ GPIO_ALTF5,    0x02

/* Establecer pin (Pin Set) Enciende el pin */
.equ GPIO_GPSET0,   0x1C
.equ GPIO_GPSET1,   0x20

/* Limpiar pin (Pin Clear) Apaga el pin */
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
.equ GPIO_GPPUD,    0x94
.equ GPIO_GPPUDCLK0,    0x98
.equ GPIO_GPPUDCLK1,    0x9C

@ ----------------------------------------------------------------------------------------------------------
@ Establece el modo del pin
@ -1 Error
@  0 Exitoso
@ ----------------------------------------------------------------------------------------------------------
.section .text
gpio_setMode:
    cmp         r0, #53             @ Compara el pin indicado (r0) con 53
    cmpls       r1, #7
    bhi         gpio_setModeError   @ Si el pin indicado (r0) es mayor que 53 salta hacia setModeError
    push        {r4, lr}            @ 
    ldr         r2, =GPIO_BASE      @ Carga la dirección base
gpio_setModeLoop:
    cmp         r0, #10             @ Se verifica que sea menor que diez
    bmi         gpio_mode           @ Sale del bucle
    add         r2, #4              @ Incrementa la dirección base en dos (cambiará en )
    sub         r0, #10
    b           gpio_setModeLoop
gpio_mode:
    add         r0, r0, r0, lsl #1  @ Multiplica por tres el digito que se quiere establecer
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
