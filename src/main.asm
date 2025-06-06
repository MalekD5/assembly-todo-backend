extern WSAStartup
extern WSACleanup
extern socket
extern bind
extern listen
extern accept
extern send
extern shutdown
extern closesocket
extern printf
extern recv 
extern lookup
extern ExitProcess

extern fail_socket
extern fail_bind
extern fail_listen
extern fail_404
extern format_str

extern register_routes

global wsadata
global listen_socket

section .bss
    global client_socket
    wsadata resb 400
    listen_socket resq 1
    client_socket resq 1
    recv_buffer resb 2048
    method_buffer resb 8
    route_buffer resb 2048

section .data
    sockaddr_in:
        dw 2
        dw 0xB80B
        dd 0
        dd 0

    cleanup db "cleanup", 10, 0
    loop_enter db "entering loop", 10, 0 
    server_on db "Server is running on port 3000", 0

section .text
global main

main:
    sub rsp, 40

    call register_routes

    mov ecx, 0x0202
    lea rdx, [rel wsadata]
    call WSAStartup

    mov ecx, 2
    mov edx, 1
    mov r8d, 6
    call socket
    cmp rax, -1
    je .fail_socket_ins
    mov [rel listen_socket], rax

    mov rcx, [rel listen_socket]
    lea rdx, [rel sockaddr_in]
    mov r8d, 16
    call bind
    cmp rax, -1
    je .fail_bind_ins

    mov rcx, [rel listen_socket]
    mov edx, 100
    call listen
    cmp rax, -1
    je .fail_listen_ins

    lea rcx, [rel format_str]
    lea rdx, [rel server_on]
    call printf

.accept_loop:
    lea rcx, [rel cleanup]
    call printf

    mov rcx, [rel listen_socket]
    xor rdx, rdx
    xor r8, r8
    call accept
    mov [rel client_socket], rax

    mov rcx, [rel client_socket]
    lea rdx, [rel recv_buffer]
    mov r8d, 2048
    xor r9d, r9d
    call recv

    lea rsi, [rel recv_buffer]
    lea rdi, [rel method_buffer]
    mov rcx, 7
.copy_method:
    lodsb
    cmp al, ' '
    je .end_method
    stosb
    loop .copy_method
.end_method:
    mov byte [rdi], 0

    lea rdi, [rel route_buffer]
    mov rcx, 64
.copy_path:
    lodsb
    cmp al, ' '
    je .end_path
    stosb
    loop .copy_path
.end_path:
    mov byte [rdi], 0

    lea rcx, [rel format_str]
    lea rdx, [rel method_buffer]
    call printf
    lea rcx, [rel format_str]
    lea rdx, [rel route_buffer]
    call printf

     mov al, byte [rel method_buffer]
    test al, al
    je .accept_loop

    mov al, byte [rel route_buffer]
    test al, al
    je .accept_loop

    lea rcx, [rel method_buffer]
    lea rdx, [rel route_buffer]
    call lookup
    test rax, rax
    jnz .call_handler

    call fail_404
    jmp .cleanup

.call_handler:
    call rax

.cleanup:
    lea rcx, [rel cleanup]
    call printf
    
    mov rcx, [rel client_socket]

    mov edx, 1
    call shutdown

    mov rcx, [rel client_socket]
    call closesocket

    lea rcx, [rel cleanup]
    call printf

    jmp .accept_loop

    ret

.fail_socket_ins:
    call fail_socket
    jmp .exit

.fail_bind_ins:
    call fail_bind
    jmp .exit

.fail_listen_ins:
    call fail_listen
    jmp .exit

.exit:
    xor ecx, ecx
    call ExitProcess
