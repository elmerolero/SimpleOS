.section .data
.align 4
terminal_Input:
terminal_InputHead:     .word 0
terminal_InputTail:     .word 0
terminal_InputBuffer:   .skip 4096

.align 4
terminal_Output:
terminal_OutputHead:    .word 0
terminal_OuputTail:     .word 0
terminal_OutputBuffer:  .skip 4096

.section .text
terminal_Main:
    
