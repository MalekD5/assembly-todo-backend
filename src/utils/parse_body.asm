%include "src/macros/conn_struc.inc"

extern cJSON_Parse

; Inputs:
;   RCX = pointer to connection struct, assumes that body offset is already loaded
;
; Output:
;   rax = pointer to cJSON* root (null if failed)

section .text
global parse_json_body

parse_json_body:
    push rbx
    push rsi
    push rdi

    mov rbx, rcx

    lea rsi, [rbx + connection.recv_buffer]

    mov rax, [rbx + connection.bytes_received]

    add rsi, rax
    mov byte [rsi], 0

    mov rax, [rbx + connection.body_offset]
    lea rcx, [rbx + connection.recv_buffer + rax]
    call cJSON_Parse

    mov [rbx + connection.json_root], rax

    pop rdi
    pop rsi
    pop rbx
    ret
