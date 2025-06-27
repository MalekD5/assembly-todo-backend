struc connection
    .client_socket: resq 1
    .method: resb 8
    .path: resb 2048
    .recv_buffer: resb 2048
    .body_offset resq 1
    .json_root resq 1
endstruc