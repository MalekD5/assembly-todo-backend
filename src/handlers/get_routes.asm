extern todo_total
extern client_socket
extern send_response
extern sprintf
extern printf
extern strlen
extern strcat

section .data
    a db "Test", 0
    count_response_fmt db "HTTP/1.1 200 OK",13,10
                       db "Content-Type: application/json",13,10
                       db "Content-Length: %d",13,10
                       db "Connection: close",13,10,13,10,0
    json_response_fmt  db '{ "count": %d }',0
    debug_msg db "Sending count response",10,0

section .bss
    json_response_buffer resb 256
    response_buffer resb 2048
    body_buffer     resb 16

section .text
global get_todos_count

get_todos_count:
    sub rsp, 40

    call todo_total
    mov ecx, eax
    mov edx, eax

    lea rcx, [rel json_response_buffer]
    lea rdx, [rel json_response_fmt]
    mov r8d, eax
    xor r9d, r9d
    call sprintf

    lea  rcx, [rel json_response_buffer]
    call strlen

    lea rcx, [rel response_buffer]
    lea rdx, [rel count_response_fmt]
    mov r8d, eax
    call sprintf

    lea rcx, [rel response_buffer]
    lea rdx, [rel json_response_buffer]
    call strcat

    lea rcx, [rel debug_msg]
    call printf

    lea rsi, [rel response_buffer]
    xor ecx, ecx

    lea rcx, [rel response_buffer]
    call printf

    lea rcx, [rel response_buffer]
    call strlen
    mov r8d, eax

    lea rdx, [rel response_buffer]
    xor r9d, r9d
    call send_response

    add rsp, 40

    ret
