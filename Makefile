ASM_SRCS := $(wildcard src/**/*.asm) $(wildcard src/*.asm)
C_SRCS   := $(wildcard src/**/*.c) $(wildcard src/*.c)

ASM_OBJS := $(patsubst src/%.asm, dist/%.o, $(ASM_SRCS))
C_OBJS   := $(patsubst src/%.c, dist/%.o, $(C_SRCS))
OBJS     := $(ASM_OBJS) $(C_OBJS)

NASM_FLAGS := -f win64
GCC_FLAGS  := -c
TARGET := dist/backend-win64.exe

build: $(TARGET)

$(TARGET): $(OBJS)
	@echo Linking...
	gcc -o $@ $^ -lws2_32 -lmsvcrt

dist/%.o: src/%.asm
	@mkdir -p $(dir $@)
	nasm $(NASM_FLAGS) $< -o $@

dist/%.o: src/%.c
	@mkdir -p $(dir $@)
	gcc $(GCC_FLAGS) $< -o $@

clean:
	rm -rf dist


clean-build: clean build

run:
	./dist/backend-win64.exe

debug:
	gdb ./dist/backend-win64.exe