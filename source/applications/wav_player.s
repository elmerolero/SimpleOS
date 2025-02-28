.equ WAV_FILE_SIZE,         0x00
.equ WAV_BLOCK_SIZE,        0x04
.equ WAV_FORMAT,            0x08
.equ WAV_CHANNELS,          0x0C
.equ WAV_FREQUENCY,         0x10
.equ WAV_BYTE_RATE,         0x14
.equ WAV_FREQUENCY,         0x18
.equ WAV_BYTE_RATE,         0x1C
.equ WAV_BLOCK_ALIGN,       0x20
.equ WAV_BITS_PER_SAMPLE,   0x24
.equ WAV_DATA_SIZE,         0x28

.section .data
start_song:
.incbin "applications/Sample.bin"
end_song:
    .word 0

.section .data
    wav_data:   .skip 44

