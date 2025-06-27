%include "src/macros/conn_struc.inc"
%include "src/macros/thread.inc"

extern WSAStartup, WSACleanup, socket, bind, listen, accept, send, shutdown, closesocket, printf, recv, lookup, ExitProcess

extern GetProcessHeap, HeapAlloc, HeapFree, CreateThread

extern fail_socket, fail_bind, fail_listen, format_str, fail_404

extern register_routes, cleanup_socket, find_http_body_offset

global wsadata
global listen_socket

section .bss
    wsadata resb 400
    listen_socket resq 1

section .data
    sockaddr_in:
        dw 2
        dw 0xB80B
        dd 0
        dd 0

    cleanup db "cleanup", 10, 0
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
    mov rcx, [rel listen_socket]
    xor rdx, rdx
    xor r8, r8
    call accept

    mov r12, rax ; store the client_socket in r12 temporarily, preparing for HeapAlloc call so we don't lose the socket context

    call GetProcessHeap
    mov rbx, rax

    mov rcx, rbx
    xor rdx, rdx
    mov r8, connection_size
    call HeapAlloc

    test rax, rax ; if HeapAlloc failed, we're done
    jz .exit

    mov r15, rax ; store the pointer to the conn struct in r11
    mov [r15 + connection.client_socket], r12 ; store the client_socket in the conn struct

    sub rsp, 20h

    xor rcx, rcx
    xor rdx, rdx
    mov r8, .thread_proc
    mov r9, r15
    mov qword [rsp], 0
    call CreateThread

    add rsp, 20h

    jmp .accept_loop

.thread_proc:
    sub rsp, 40
    mov r15, rcx

    mov rcx, [r15 + connection.client_socket]
    lea rdx, [r15 + connection.recv_buffer]
    mov r8d, 2048
    xor r9d, r9d
    call recv

    mov [r15 + connection.bytes_received], rax

    lea rcx, [r15 + connection.recv_buffer] 
    mov rdx, 2048
    call find_http_body_offset

    mov [r15 + connection.body_offset], rax

    lea rsi, [r15 + connection.recv_buffer]
    lea rdi, [r15 + connection.method]
    mov rcx, 7
.copy_method:
    lodsb
    cmp al, ' '
    je .end_method
    stosb
    loop .copy_method
.end_method:
    mov byte [rdi], 0

    lea rdi, [r15 + connection.path]
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
    lea rdx, [r15 + connection.method] 
    call printf
    lea rcx, [rel format_str]
    lea rdx, [r15 + connection.path]
    call printf

    mov al, byte [r15 + connection.method]
    test al, al
    je .accept_loop

    mov al, byte [r15 + connection.path]
    test al, al
    je .accept_loop

    lea rcx, [r15 + connection.method]
    lea rdx, [r15 + connection.path]
    call lookup
    test rax, rax
    jnz .call_handler

    mov rcx, [r15 + connection.client_socket]
    call fail_404

    sub rsp, 16
    mov rcx, [r15 + connection.client_socket]
    call cleanup_socket
    add rsp, 16

    mov eax, 0
    add rsp, 40
    ret

.call_handler:
    ; we call the route handler, and because of the shadow space alignment issue we need to add 40 to the stack pointer (windows calling convention)
    mov r12, rax ; pointer to route handler

    sub rsp, 40
    mov rcx, [r15 + connection.client_socket]
    call r12
    add rsp, 40

    mov rcx, [r15 + connection.client_socket]
    call cleanup_socket

    mov eax, 0
    add rsp, 40
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
