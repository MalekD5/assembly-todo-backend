extern todo_total

extern GetProcessHeap, HeapAlloc, HeapFree

extern client_socket, send_response
extern sprintf, printf, strlen, strcat

struc response_struc
    .json_response_buffer: resb 256
    .response_buffer: resb 2048
endstruc

section .data
    a db "Test", 0
    count_response_fmt db "HTTP/1.1 200 OK",13,10
                       db "Content-Type: application/json",13,10
                       db "Content-Length: %d",13,10
                       db "Connection: close",13,10,13,10,0
    json_response_fmt  db '{ "count": %d }',0
    debug_msg db "Sending count response",10,0
    heap_fail_msg db "Failed to allocate heap memory", 10, 0

section .text
global get_todos_count

get_todos_count:
    sub rsp, 40

    call GetProcessHeap

    mov rcx, rax
    xor rdx, rdx
    mov r8, response_struc_size
    call HeapAlloc
    
    test rax, rax
    jz .fail_heap_alloc

    mov r15, rax ; store the pointer to the response struct in r15

    call todo_total
    mov ecx, eax
    mov edx, eax

    sub rsp, 40
    lea rcx, [r15 + response_struc.json_response_buffer]
    lea rdx, [rel json_response_fmt]
    mov r8d, eax
    xor r9d, r9d
    call sprintf
    add rsp, 40

    lea rcx, [r15 + response_struc.json_response_buffer]
    call strlen

    lea rcx, [r15 + response_struc.response_buffer]
    lea rdx, [rel count_response_fmt]
    mov r8d, eax
    call sprintf

    lea rcx, [r15 + response_struc.response_buffer]
    lea rdx, [r15 + response_struc.json_response_buffer]
    call strcat

    lea rcx, [rel debug_msg]
    call printf

    lea rsi, [r15 + response_struc.response_buffer]
    xor ecx, ecx

    lea rcx, [r15 + response_struc.response_buffer]
    call printf

    lea rcx, [r15 + response_struc.response_buffer]
    call strlen
    mov r8d, eax

    lea rdx, [r15 + response_struc.response_buffer]
    xor r9d, r9d
    call send_response

    call GetProcessHeap
    mov rcx, rax
    mov rdx, 0
    mov r8, r15
    call HeapFree

    add rsp, 40
    ret

.fail_heap_alloc:
    lea rcx, [rel heap_fail_msg]
    call printf
    xor ecx, ecx
    ret
