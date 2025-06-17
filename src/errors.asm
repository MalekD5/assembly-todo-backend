extern send
extern printf

global format_str

section .data
    format_str db "%s", 10, 0
    socket_fail_msg db "Socket creation failed", 0
    bind_fail_msg db "Bind failed", 0
    listen_fail_msg db "Listen failed", 0
    send_failed_msg db "Unable to send response", 0
    response_404 db "HTTP/1.1 404 Not Found",13,10
                 db "Content-Type: text/html; charset=UTF-8",13,10
                 db "Content-Length: 75",13,10
                 db "Connection: close",13,10,13,10
                 db "<html><head><title>404 Not Found</title></head><body>Not Found</body></html>",0
    response_404_len equ $ - response_404

section .text
global fail_socket
global fail_bind
global fail_listen
global fail_send_message

fail_socket:
    lea rcx, [rel format_str]
    lea rdx, [rel socket_fail_msg]
    call printf
    ret

fail_bind:
    lea rcx, [rel format_str]
    lea rdx, [rel bind_fail_msg]
    call printf
    ret 

fail_listen:
    lea rcx, [rel format_str]
    lea rdx, [rel listen_fail_msg]
    call printf
    ret 

fail_send_message:
    lea rcx, [rel format_str]
    lea rdx, [rel send_failed_msg]
    call printf