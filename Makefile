# Copied from E:\PROJECTS\_Electronics_PROJECTs\AC14B3K_battery\Makefile
# 16:07 Friday, December 11, 2020

########   EDIT THIS ONLY  #############
DEV = atmega16a
BAUD = 38400
APP = $(shell basename $(abspath $(dir $$PWD)))
SYMBOL = -DF_CPU=16000000UL -DBAUD=$(BAUD) -DDEBUG -DTW_DEBUG
COM?=
########################################

CC = avr-gcc
LD = avr-gcc
AS = avr-gcc

DBGDIR = ./debug
BINDIR	= ./bin
BUILDDIR = ./build
#LIBDIR = /mnt/e/PROJECTS/user_library/avr/lib

#C_LIBSRCS = $(shell find $(LIBDIR) -name '*.c')
#S_LIBSRCS = $(shell find $(LIBDIR) -name '*.S')
#C_LIBSRCS = $(LIBDIR)/utils/DEBUG.c \
			$(LIBDIR)/utils/TWI.c \
			$(LIBDIR)/utils/UART.c
#S_LIBSRCS = 
C_SRCS = $(shell find ./src/ -name '*.c')
S_SRCS = $(shell find ./src/ -name '*.S')

BIN = $(BINDIR)/$(APP)
DBG = $(DBGDIR)/$(APP)
OBJS = $(C_SRCS:./%.c=$(BUILDDIR)/%.o) $(S_SRCS:./%.S=$(BUILDDIR)/%.o) \
$(C_LIBSRCS:$(LIBDIR)/%.c=$(BUILDDIR)/lib/%.o) $(S_LIBSRCS:$(LIBDIR)/%.S=$(BUILDDIR)/lib/%.o)
INC = \
$(patsubst %,-I%,$(shell find . -type f -name '*.h' -printf "%h\n" | sort -u)) \
$(patsubst %,-I%,$(shell find $(LIBDIR) -type f -name '*.h' -printf "%h\n" | sort -u))
WARNING = -Wall -Wextra -Werror=format -Wfatal-errors #-Werror=conversion
OPTIMIZE = -g2 -O1 -ffunction-sections -fdata-sections -fpack-struct
#OPTIMIZE = -g1 -O3 -ffunction-sections -fdata-sections -fpack-struct -fshort-enums -mrelax


CFLAGS = -c -std=gnu99 -fsigned-char -MMD $(INC) $(WARNING) $(SYMBOL) $(OPTIMIZE) -mmcu=$(DEV)
ASFLAGS = $(CFLAGS)
LDFLAGS = -fsigned-char -Xlinker --gc-sections -Xlinker -Map=$(DBG).map $(OPTIMIZE) -mmcu=$(DEV)


.PHONY: all clean flash rebuild test uart
all: post-build

post-build: main-build
	@echo POST
#	@echo THE NEWER VERSION OF THIS MAKEFILE IS LOCATED AT 
#	@echo /mnt/e/PROJECTS/_Electronics_PROJECTs/test-mega/Makefile
#	@echo AS A TEAMPLATE, PLEASE COPY THE NEWER TO YOUR NEW AVR PROJECTS
	@echo THIS TEAMPLATE Copied from E:\PROJECTS\_Electronics_PROJECTs\AC14B3K_battery\Makefile
	@echo 16:07 Friday, December 11, 2020
main-build: pre-build
	@$(MAKE) --no-print-directory target
pre-build:
	@clear


target: $(BIN).elf $(BIN).hex $(DBG).lss $(APP).sz

$(BIN).elf: $(OBJS)
	@echo Linking object files ...
	@mkdir -pv $(dir $@)
	@mkdir -pv $(DBGDIR)
	@$(LD) $(LDFLAGS) -o $@ $^
$(BIN).hex: $(BIN).elf 
	@echo Creating hex ...
	@mkdir -pv $(dir $@)
	@avr-objcopy -O ihex $< $@
$(DBG).lss: $(BIN).elf
	@echo Creating .lss ...
	@mkdir -pv $(dir $@)
	@avr-objdump -S $< > $@
$(APP).sz: $(BIN).elf
	@avr-size $< -C --mcu=$(DEV)


$(BUILDDIR)/lib/%.o: lib/%.c
	@echo Compiling $< ...
	@mkdir -pv $(dir $@)
	@$(CC) $(CFLAGS) -o $@ $<
$(BUILDDIR)/lib/%.o: lib/%.S
	@echo Compiling $< ...
	@mkdir -pv $(dir $@)
	@$(AS) $(ASFLAGS) -o $@ $<
	
$(BUILDDIR)/lib/%.o: $(LIBDIR)/%.c
	@echo Compiling $< ...
	@mkdir -pv $(dir $@)
	@$(CC) $(CFLAGS) -o $@ $<
$(BUILDDIR)/lib/%.o: $(LIBDIR)/%.S
	@echo Compiling $< ...
	@mkdir -pv $(dir $@)
	@$(AS) $(ASFLAGS) -o $@ $<
	
$(BUILDDIR)/src/%.o: src/%.c
	@echo Compiling $< ...
	@mkdir -pv $(dir $@)
	@$(CC) $(CFLAGS) -o $@ $<

clean:
	@rm -vrf $(OBJS) $(OBJS:%.o=%.d) $(BINDIR) $(DBGDIR) $(BUILDDIR)

flash: all
	 avrdude.exe -cusbasp -p$(DEV) -U flash:w:$(BIN).hex:i -v
arduino: all
	avrdude -v -pm16 -c arduino -P /dev/ttyUSB0 -b $(BAUD) -U flash:w:$(BIN).hex:i
uart: arduino
	putty /dev/ttyUSB0 -serial -sercfg 38400,8,n,1,N
test:
	@echo $(C_SRCS)
	@echo $(S_SRCS)
	@echo $(C_LIBSRCS)
	@echo $(S_LIBSRCS)
	@echo $(OBJS)
	@echo $(INC)
rebuild: clean all
cls:
	clear
-include $(OBJS:%.o=%.d)