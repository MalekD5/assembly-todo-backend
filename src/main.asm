extern WSAStartup
extern WSACleanup
extern socket
extern bind
extern listen
extern accept
extern send
extern shutdown
extern closesocket
extern Sleep
extern printf

section .data
    sockaddr_in:
        dw 2
        dw 0xB80B ; Port 3000
        dd 0
        dd 0
    format_str db "%s", 10, 0                 ; "%s\n"
    server_on db "Server is running on port 3000", 0
    response db "HTTP/1.1 200 OK",13,10,"Content-Length: 12",13,10,13,10,"Hello World!",0
    response_len equ $-response

section .bss
    wsadata resb 400
    listen_socket resq 1
    client_socket resq 1

section .text
global main

main:
    sub rsp, 40

    lea rcx, [rel format_str]
    lea rdx, [rel server_on]
    call printf

    mov ecx, 0x0202
    lea rdx, [rel wsadata]
    call WSAStartup

    mov ecx, 2                 ; AF_INET
    mov edx, 1                 ; SOCK_STREAM
    mov r8d, 6                 ; IPPROTO_TCP
    call socket
    mov [rel listen_socket], rax

    mov rcx, [rel listen_socket]
    lea rdx, [rel sockaddr_in]
    mov r8d, 16
    call bind

    mov rcx, [rel listen_socket]
    mov edx, 5
    call listen

.accept_loop:
    mov rcx, [rel listen_socket]
    xor rdx, rdx              
    xor r8, r8
    call accept
    mov [rel client_socket], rax

    lea rsi, [rel response]
    mov rbx, response_len

.send_loop:
    mov rcx, [rel client_socket]
    mov rdx, rsi
    mov r8d, ebx
    xor r9d, r9d
    call send

    cmp rax, 0
    jl .send_failed

    add rsi, rax

    ; to prevent mixing 32-bit and 64-bit registers
    mov eax, eax
    add esi, eax
    sub ebx, eax
    
    test rbx, rbx
    jnz .send_loop

    mov rcx, [rel client_socket]
    mov edx, 1
    call shutdown

.send_failed:
    mov rcx, [rel client_socket]
    call closesocket

    jmp .accept_loop

    mov rcx, 0
    call WSACleanup

    add rsp, 40
    xor eax, eax
    ret