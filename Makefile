build:
	nasm -f win64 src/main.asm -o main.obj
	gcc main.obj -o main.exe -lws2_32 -lmsvcrt

run:
	./main.exe