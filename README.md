# Simple OS
Simple OS is an Operating System designed for the Raspberry Pi Model A+ V1.1, Its goal is to enable the use of graphical interfaces.  Although it might not work, I'm still willing to give it a try..

## Data types

- u8: Used as a byte without sign, represents an unsigned char.
- s8: Used as a byte with sign, represents a char.
- u16: Two bytes without sign, represents an unsigned short.
- s16: Two bytes with sign, represents a short.
- u32: 4 bytes without sign, represents an unsigned int.
- s32: 4 bytes with sign, represents an int.

## Compilation instructions

In order to compile this project, I use MSYS2 MinGW x64 downloading the following packages that can be installed using pacman.
mingw-w64-ucrt-x86_64-toolchain base-devel
mingw-w64-arm-none-eabi-gcc

Once installed, access to the path where project is located and run make command. If you want to run from power shell in VSCode or CMD, you will need to set the path variables.

For any suggestion or concern, you can send me an email to isma.salas24 at gmail.com

## Credits

I want to reference the followings repos that helped me to accomplish the current progress and I thank them a lot.

- [Dwelch67] (/dwelch67/raspberrypi)
- [PeterLemon] (https://github.com/PeterLemon/RaspberryPi)
