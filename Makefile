# === Project Settings ===
TARGET = firmware.elf
BUILD_DIR = build

# === Toolchain ===
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size

# === Compiler Flags ===
MCU = cortex-m4
FPU = fpv4-sp-d16
FLOAT-ABI = hard

CPU = -mcpu=$(MCU) -mfpu=$(FPU) -mfloat-abi=$(FLOAT-ABI) -mthumb

CFLAGS = $(CPU) -Wall -O2 -ffunction-sections -fdata-sections -g -std=c11
ASFLAGS = $(CPU) -g
LDFLAGS = $(CPU) -Wl,--gc-sections -T linker.ld

# === Include Paths ===
INCLUDES = \
  -ICore/Inc \
  -IDrivers/STM32F4xx_HAL_Driver/Inc \
  -IDrivers/STM32F4xx_HAL_Driver/Inc/Legacy \
  -IFreeRTOS/include \
  -IFreeRTOS/Source/include \
  -IFreeRTOS/Source/portable/GCC/ARM_CM4F

# Add path to system_stm32f4xx.c and HAL
SRC = \
  Core/Src/main.c \
  system_stm32f4xx.c \
  startup_stm32f411xe.s \
  $(wildcard Drivers/STM32F4xx_HAL_Driver/Src/*.c) \
  $(wildcard FreeRTOS/Source/*.c) \
  $(wildcard FreeRTOS/Source/portable/GCC/ARM_CM4F/*.c)

OBJ = $(SRC:%.c=$(BUILD_DIR)/%.o)
OBJ := $(OBJ:%.s=$(BUILD_DIR)/%.o)

# === Build Rules ===
all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/$(TARGET): $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(ASFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

flash: all
	st-flash write $(BUILD_DIR)/$(TARGET) 0x8000000

.PHONY: all clean flash
