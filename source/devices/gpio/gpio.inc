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
