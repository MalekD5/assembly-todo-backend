# Tools
CC := gcc
NASM := nasm

# Flags
CFLAGS := -Wall -Wextra -O2 -g
NASMFLAGS := -f win64

LDFLAGS := -g
LIB_DIR := lib
LIBS := -L$(LIB_DIR) -lws2_32 -lcjson -lmsvcrt

# Sources
INC_FILES := $(wildcard src/*.inc src/*/*.inc)
C_SRCS := $(wildcard src/*.c src/*/*.c)
ASM_SRCS := $(wildcard src/*.asm src/*/*.asm)

C_OBJS := $(patsubst src/%.c, dist/%.o, $(C_SRCS))
ASM_OBJS := $(patsubst src/%.asm, dist/%.o, $(ASM_SRCS))

OBJS := $(C_OBJS) $(ASM_OBJS)

TARGET := dist/backend-win64.exe

.PHONY: all clean run inc_first

all: inc_first $(TARGET)

# Dummy target for inc files (priority)
inc_first:
	@echo "Checking .inc files first..."
	@for f in $(INC_FILES); do \
		echo "Header: $$f"; \
	done

# Link
$(TARGET): $(OBJS)
	@echo Linking...
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

# Compile C files (depend on inc files)
dist/%.o: src/%.c $(INC_FILES)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble ASM files (depend on inc files)
dist/%.o: src/%.asm $(INC_FILES)
	@mkdir -p $(dir $@)
	$(NASM) $(NASMFLAGS) $< -o $@

clean:
	rm -rf dist

run: $(TARGET)
	./$(TARGET)

debug:
	gdb ./dist/backend-win64.exe

cbd:
	make clean
	make
	make debug