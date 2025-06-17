extern shutdown, closesocket

section .text
global cleanup_socket

; void cleanup_socket(socket* socket)
; rcx = pointer to client socket
cleanup_socket:
    push rsp 
    sub rsp, 40

    mov r12, rcx

    mov edx, 1
    call shutdown

    mov rcx, r12
    call closesocket
    add rsp, 40
    pop rsp
    ret
