@ ------------------------------------------------------------------------------
@ Output Service - Ismael Salas López - 2025
@ This service is in purpose of take any output and redirect them to requested
@ device that get registered with this service.
@ In current status, this service can receive the input from UART and use it
@ to transmit info from the main process
@ ------------------------------------------------------------------------------
.section .data
.align 4
output_Buffer:   .skip 512

.section .text
output_Set:
    .word uart0_Write

output_Write:
    