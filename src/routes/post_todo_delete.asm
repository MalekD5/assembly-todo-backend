%include "src/macros/response_struc.inc"
%include "src/macros/conn_struc.inc"

extern todo_delete, send_response, parse_json_body

extern sprintf, printf, strlen, strcat

extern GetProcessHeap, HeapAlloc, HeapFree

extern cJSON_GetObjectItemCaseSensitive, cJSON_GetStringValue, cJSON_Print

section .data
    post_response_fmt  db "HTTP/1.1 200 OK",13,10
                       db "Content-Type: text/plain",13,10
                       db "Content-Length: 0",13,10
                       db "Connection: close",13,10,13,10,0
    heap_fail_msg db "Failed to allocate heap memory", 10, 0
    msg_parse_fail db "JSON parse failed", 10, 0
    ok_response db "OK", 10, 0

section .rodata
    key_name db "id", 0

section .text
global post_todo_delete

post_todo_delete:
    push r15
    sub rsp, 40

    mov r14, rcx ; client connection 

    mov rcx, r15
    call parse_json_body
    test rax, rax
    jz .bad_json

    mov rcx, [r15 + connection.json_root]    ; rcx = cJSON *

    call cJSON_Print                ; rax = const char* to string

    lea rcx, [rel rax]
    call printf

    mov rcx, [r15 + connection.json_root]
    lea rdx, [rel key_name]
    call cJSON_GetObjectItemCaseSensitive

    mov rcx, rax
    call cJSON_GetStringValue

    mov rcx, rax
    call todo_delete
    mov ecx, eax
    mov edx, eax

    mov rcx, r14 ; connection
    lea rsi, [rel post_response_fmt]
    xor r9d, r9d
    call send_response

    add rsp, 40
    pop r15
    ret

.bad_json:
    lea rcx, [rel msg_parse_fail]
    call printf
    ret