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
    push rsi
    push rcx

    ; rcx = connection*
    mov rsi, rcx

    ; Load body offset
    mov rax, [rsi + connection.body_offset]

    ; rsi = recv_buffer base
    lea rsi, [rsi + connection.recv_buffer]
    add rsi, rax              ; rsi = pointer to JSON body

    mov rcx, rsi              ; arg: char* json_string
    call cJSON_Parse          ; returns cJSON* in rax

    pop rcx
    pop rsi
    ret
