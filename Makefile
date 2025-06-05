build:
	nasm -f win64 src/main.asm -o dist/main.o
	nasm -f win64 src/errors.asm -o dist/errors.o
	nasm -f win64 src/handlers/get_routes.asm -o dist/get_routes.o
	gcc -c src/helpers/hashtable.c -o dist/hashtable.o
	gcc -c src/helpers/todo.c -o dist/todo.o
	gcc -o dist/backend.exe dist/get_routes.o dist/errors.o dist/hashtable.o dist/todo.o dist/main.o -lws2_32 -lmsvcrt

clean:
	rm -rf dist

run:
	./dist/backend.exe