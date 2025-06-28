; Inputs:
;   RCX = pointer to buffer start (recv_buffer)
;   RDX = length of buffer (2048 bytes)
;
; Output:
;   RAX = offset of body (right after \r\n\r\n), or 0 if not found

section .text
global find_http_body_offset

find_http_body_offset:
    push rsi
    push rcx
    push rdx

    xor rax, rax          ; default return value = 0
    mov rsi, rcx          ; rsi = pointer to buffer
    xor rcx, rcx          ; rcx = offset/index
    sub rdx, 4            ; scan limit = length - 4

.loop_scan:
    cmp rcx, rdx
    jg .not_found

    mov al, [rsi + rcx]
    cmp al, 0x0D
    jne .next

    mov al, [rsi + rcx + 1]
    cmp al, 0x0A
    jne .next

    mov al, [rsi + rcx + 2]
    cmp al, 0x0D
    jne .next

    mov al, [rsi + rcx + 3]
    cmp al, 0x0A
    jne .next

    lea rax, [rcx + 4]    ; offset after \r\n\r\n
    jmp .done

.next:
    inc rcx
    jmp .loop_scan

.not_found:
    xor rax, rax

.done:
    pop rdx
    pop rcx
    pop rsi
    ret
