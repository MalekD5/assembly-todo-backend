%include "src/macros/response_struc.inc"
%include "src/macros/conn_struc.inc"

extern todo_total, todo_add, get_todos_array, send_response, parse_json_body

extern sprintf, printf, strlen, strcat, strcpy, free, sizeof, puts

extern GetProcessHeap, HeapAlloc, HeapFree

extern cJSON_GetObjectItemCaseSensitive, cJSON_GetStringValue, cJSON_Print, cJSON_CreateObject, cJSON_CreateArray, cJSON_AddItemToObject, cJSON_PrintUnformatted, cJSON_AddItemToArray, cJSON_CreateString, cJSON_AddNumberToObject, cJSON_AddStringToObject, cJSON_CreateNumber

struc todos_struc
    .json_root resq 1
    .json_array resq 1
    .list resq 1
    .response_body resb 2048
    .response resb 2048
endstruc 

section .data
    post_response_fmt   db "HTTP/1.1 200 OK",13,10
                        db "Content-Type: application/json",13,10
                        db "Content-Length: %d",13,10
                        db "Connection: close",13,10,13,10
                        db "%s",0
    empty_response_fmt  db "HTTP/1.1 204 No Content",13,10
                        db "Content-Type: text/plain",13,10
                        db "Content-Length: 0",13,10
                        db "Connection: close",13,10,13,10
                        db "%s",0
    heap_fail_msg db "Failed to allocate heap memory", 10, 0
    msg_parse_fail db "JSON parse failed", 10, 0
    ok_response db "OK", 10, 0

section .rodata
    key_name db "data", 0
    id_key    db "id", 0
    text_key  db "text", 0

section .text
global get_todos

get_todos:
    push r15
    push r13
    push r14
    push r12 
    sub rsp, 40

    mov r14, rcx ; client connection 

    call GetProcessHeap

    mov rcx, rax
    xor rdx, rdx
    mov r8, todos_struc_size
    call HeapAlloc
    
    test rax, rax
    jz .fail_heap_alloc

    mov r13, rax ; store the pointer to todos struct

    call get_todos_array   ; returns pointer in rax
    test rax, rax
    jz .empty_array
    
    mov [r13 + todos_struc.list], rax

    call cJSON_CreateObject
    mov [r13 + todos_struc.json_root], rax

    call cJSON_CreateArray
    mov [r13 + todos_struc.json_array], rax

    mov rbx, [r13 + todos_struc.list] ; load pointer to array

.array_loop:
    mov rax, [rbx]               ; rax = pointer to TodoItem
    test rax, rax
    je .stop_array_loop

    mov rsi, rax
    ; Create JSON object for each item
    call cJSON_CreateObject
    mov r12, rax                 ; save cJSON * for this item

    ; Add ID field: rcx = cJSON*, rdx = key, r8 = value
    mov rcx, r12
    lea rdx, [rel id_key]        ; "id"
    mov r8d, [rsi]               ; load int id from [TodoItem.id]
    call cJSON_AddStringToObject

    ; Add text field
    mov rcx, r12
    lea rdx, [rel text_key]      ; "text"
    mov rsi, [rsi + 8]           ; text pointer from [TodoItem.text]
    mov r8, rsi
    call cJSON_AddStringToObject

    ; Append this object to the array
    mov rcx, [r13 + todos_struc.json_array]
    mov rdx, r12
    call cJSON_AddItemToArray

    add rbx, 8                   ; next TodoItem*
    jmp .array_loop

.stop_array_loop:
    mov rcx, [r13 + todos_struc.json_root]
    lea rdx, [rel key_name]
    mov r8, [r13 + todos_struc.json_array]
    call cJSON_AddItemToObject

    mov rcx, [r13 + todos_struc.json_root]
    call cJSON_PrintUnformatted

    lea  rcx, [r13 + todos_struc.response_body]  ; destination buffer
    mov  rdx, rax                                ; source string
    call strcpy

    lea rcx, [r13 + todos_struc.response_body]
    call strlen

    lea rcx, [r13 + todos_struc.response]
    lea rdx, [rel post_response_fmt]
    mov r8, rax
    lea r9, [r13 + todos_struc.response_body]
    call sprintf

    mov rcx, r14 ; connection
    lea rsi, [r13 + todos_struc.response]
    xor r9d, r9d
    call send_response

    call GetProcessHeap
    mov rbx, rax

    mov rcx, [r13 + todos_struc.list]
    call free

    mov rcx, rbx
    mov rdx, 0
    mov r8, r13
    call HeapFree

    ; clear up todos array from get_todos_array
    ;lea rcx, []
    ;call free

    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    ret

.fail_heap_alloc:
    lea rcx, [rel heap_fail_msg]
    call printf
    xor ecx, ecx
    
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    ret

.bad_json:
    lea rcx, [rel msg_parse_fail]
    call printf
    
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    ret

.empty_array:
    mov rcx, r14 ; connection
    lea rsi, [rel empty_response_fmt]
    xor r9d, r9d
    call send_response

    call GetProcessHeap
    mov rbx, rax

    mov rcx, rbx
    mov rdx, 0
    mov r8, r13
    call HeapFree

    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    ret