CC	= arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

#SRCS = main.c stm32f4xx_it.c system_stm32f4xx.c

PROJECT_NAME=has
PROJECT_SRC = src
STM_SRC = lib/src/peripherals
OBJ_DIR = build

vpath %.c $(PROJECT_SRC)
vpath %.c $(STM_SRC)#%.a lib
vpath %.a lib

SRCS = main.c
SRCS += stm32f4xx_it.c
SRCS += system_stm32f4xx.c
SRCS += lib/startup_stm32f4xx.s # add startup file to build

OBJS = $(SRCS:.c=.o)


INC_DIRS = src/
INC_DIRS +=inc/
INC_DIRS +=lib/
INC_DIRS +=lib/inc/
INC_DIRS +=lib/inc/core
INC_DIRS +=lib/inc/peripherals

INCLUDE = $(addprefix -I,$(INC_DIRS))


CFLAGS  = -g -O2 -Wall -Tstm32_flash.ld 
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16

###################################################


#ROOT=$(shell pwd)

#CFLAGS += -Iinc -Ilib -Ilib/inc 
#CFLAGS += -Ilib/inc/core -Ilib/inc/peripherals 


#OBJS = $(addprefix $(OBJ_DIR)/, $(SRCS:.c=.o))

###################################################

# Create a directory for object files
$(shell mkdir $(OBJ_DIR) > /dev/null 2>&1)

.PHONY: lib proj

all: lib proj

lib:
	$(MAKE) -C lib
proj: $(PROJECT_NAME).elf

#.PHONY: $(PROJECT_NAME)
#$(PROJECT_NAME):	$(PROJECT_NAME).elf

#.PHONY: all
#all: $(PROJECT_NAME)

#.PHONY: $(PROJECT_NAME)
#$(PROJECT_NAME): $(PROJECT_NAME).elf

$(PROJECT_NAME).elf: $(SRCS)
	$(CC) $(INCLUDE) $(CFLAGS) $^ -o $@ -Llib -lstm32f4
	$(OBJCOPY) -O ihex $(PROJECT_NAME).elf $(PROJECT_NAME).hex
	$(OBJCOPY) -O binary $(PROJECT_NAME).elf $(PROJECT_NAME).bin

$(OBJ_DIR)/%.o: %.c
	$(CC) -c -o $@ $(INCLUDE) $(CFLAGS) $^

clean:
	$(MAKE) -C lib clean
	rm -f $(PROJECT_NAME).elf
	rm -f $(PROJECT_NAME).hex
	rm -f $(PROJECT_NAME).bin

flash: $(PROJECT_NAME).elf
	openocd -f interface/stlink-v2.cfg -f target/stm32f4x_stlink.cfg -f scripts/flash.cfg
