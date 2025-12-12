###############################################################################
#	Makefile for GPIO Driver
#
###############################################################################

# The toolchain to use. arm-none-eabi works, but there does exist 
# arm-bcm2708-linux-gnueabi.
ARMGNU ?= arm-none-eabi

# The intermediate directory for compiled object files.
BUILD = build/

# The directory in which source files are stored.
SOURCE = ./

# The name of the output file to generate.
TARGET = gpio.sod

# The name of the assembler listing file to generate.
LIST = gpio.list

# The name of the map file to generate.
MAP = gpio.map

# The name of the linker script to use.
LINKER = gpio.ld

# Flags
FLAGS = -march=armv6 -mfpu=vfp -mfloat-abi=hard

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS := $(patsubst $(SOURCE)%.s,$(BUILD)%.o,$(wildcard $(SOURCE)*.s))

# Rule to make everything.
all: $(TARGET) $(LIST)

# Rule to remake everything. Does not include clean.
rebuild: all

# Rule to make the listing file.
$(LIST) : $(BUILD)gpio.elf
	$(ARMGNU)-objdump -d $(BUILD)gpio.elf > $(LIST)

# Rule to make the image file.
$(TARGET) : $(BUILD)gpio.elf
	$(ARMGNU)-objcopy $(BUILD)gpio.elf -g -O binary $(TARGET) 

# Rule to make the elf file.
$(BUILD)gpio.elf : $(OBJECTS) $(LINKER)
	$(ARMGNU)-ld --no-undefined $(OBJECTS) -Map $(MAP) -g -o $(BUILD)gpio.elf -T $(LINKER)

# Rule to make the object files.
$(BUILD)%.o: $(SOURCE)%.s $(BUILD)
	$(ARMGNU)-as $(FLAGS) -g -I $(SOURCE) $(wildcard) $< -o $@

$(BUILD):
	mkdir $@

# Rule to clean files.
clean : 
	-rm -rf $(BUILD)
	-rm -f $(TARGET)
	-rm -f $(LIST)
	-rm -f $(MAP)
