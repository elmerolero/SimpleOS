.section .text
system_CoreFreqGet:
    ldr     r0, =system_CoreFreq
    ldr     r0, [ r0 ]
    bx      lr

.section .data
system_CoreFreq:
    .word 250000000
