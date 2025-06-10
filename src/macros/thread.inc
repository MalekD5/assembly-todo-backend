%macro align_thread_stack 0
    sub rsp, 40
%endmacro

%macro exit_thread_stack 0
    add rsp, 40
%endmacro

%macro align_thread_shadow_space 0
    sub rsp, 20h
%endmacro

%macro exit_thread_shadow_space 0
    add rsp, 20h    
%endmacro