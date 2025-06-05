extern todo_total
extern client_socket
extern send
extern sprintf
extern printf
extern strlen

section .data
    a db "Test", 0
    count_response_fmt db "HTTP/1.1 200 OK",13,10
                       db "Content-Type: text/plain",13,10
                       db "Content-Length: %d",13,10
                       db "Connection: close",13,10,13,10
                       db "%d",0
    debug_msg db "Sending count response",10,0

section .bss
    response_buffer resb 256
    body_buffer     resb 16

section .text
global get_todos_count

get_todos_count:
    sub rsp, 40

    call todo_total
    mov ecx, eax
    mov edx, eax
    mov r9d, eax

    lea rcx, [rel response_buffer]
    lea rdx, [rel count_response_fmt]
    mov r8d, 1
    xor r9d, eax
    call sprintf

    lea rcx, [rel debug_msg]
    call printf

    lea rsi, [rel response_buffer]
    xor ecx, ecx
.len_loop:
    mov al, [rsi + rcx]
    test al, al
    je .len_done
    inc ecx
    jmp .len_loop
.len_done:
    lea rcx, [rel a]
    call printf

    lea rcx, [rel response_buffer]
    call printf

    lea rcx, [rel response_buffer]
    call strlen
    mov r8d, eax

    mov rcx, [rel client_socket]
    lea rdx, [rel response_buffer]
    xor r9d, r9d
    call send

    add rsp, 40
    ret
