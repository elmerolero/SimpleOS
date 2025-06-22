.equ FILE_DESCRIPTOR_SIZE               0x24
.equ FILE_DESCRIPTOR_ID,                0x00
.equ FILE_DESCRIPTOR_FLAGS,             0x04
.equ FILE_DESCRIPTOR_TYPE,              0x08
.equ FILE_DESCRIPTOR_ADDRESS,           0x0C
.equ FILE_DESCRIPTOR_READ_FUNCTION,     0x10
.equ FILE_DESCRIPTOR_WRITE_FUNCTION,    0x14
.equ FILE_DESCRIPTOR_CLOSE_FUNCTION,    0x18
.equ FILE_DESCRIPTOR_IOCTL_FUNCTION,    0x1C
.equ FILE_DESCRIPTOR_PROCESS_ID,        0x20

.section .data
.align 4
fileDescriptor_Index: .word 0
fileDescriptors_Descriptors: .skip 1152
