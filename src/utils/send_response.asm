extern client_socket
extern send
extern fail_send_message

section .text
global send_response

; void send_response(char* buffer)
; rsi = pointer to null-terminated response string

send_response:
    push rbx               ; preserve rbx
    push rdi               ; preserve rdi (callee-saved)
    push r12               ; we'll use r12 as length

    ; Compute length with null-terminator check
    xor r12, r12           ; r12 = total length counter
.len_loop:
    mov al, [rsi + r12]
    test al, al
    je .len_done
    inc r12
    jmp .len_loop
.len_done:

    mov rdi, rsi           ; rdi = pointer to start of buffer
.send_loop:
    mov rcx, [rel client_socket] ; socket
    mov rdx, rdi           ; pointer to current buffer position
    mov r8d, r12d          ; number of bytes left to send
    xor r9d, r9d           ; flags = 0
    call send

    cmp rax, 0
    jl .send_failed        ; send failed
    test rax, rax
    je .send_failed        ; connection closed

    add rdi, rax           ; advance buffer pointer
    sub r12, rax           ; subtract bytes sent
    test r12, r12
    jnz .send_loop         ; send remaining bytes

    pop r12
    pop rdi
    pop rbx
    ret

.send_failed:
    call fail_send_message
    ; Still clean stack before return
    pop r12
    pop rdi
    pop rbx
    ret
