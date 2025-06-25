@ ------------------------------------------------------------------------------
@ Input Service - Ismael Salas López - 2025
@ This service is in purpose of take any entry and redirect them to requested
@ device that get registered with this service.
@ In current status, this service can receive the input from UART and use it
@ to receive info from the main process
@ ------------------------------------------------------------------------------
.section .data
.align 4
input_Buffer:   .skip 512

.section .text
input_Read: .word 0
