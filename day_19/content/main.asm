default rel          ; RIP-relative addressing instead of 32-bit absolute by default; makes the [rel ...] optional

section .rodata            ; .rodata is best for constants, not .data
message:
	db 'foo() called', 0
input_file:
	db '../input/input_test.txt', 0
  
section .data
	fd: dq 0
	
segment .bss
	buffer: resb 70
	len: resq 1

section .text
extern puts

global main
main:
    sub    rsp, 8                ; align the stack by 16

    ; PIE with -fno-plt style code, skips the PLT indirection
    

	mov rax, 2 ; Open syscall
	lea rdi, [input_file]
	mov rsi, 0 ; O_RD_ONLY
	mov rdx, 0
	syscall
	mov [fd], rax
	

	
	call read_file
	; mov BYTE [buffer + 64], 0 ; Add null terminator
	
	lea   rdi, [rel buffer]
    call  [rel  puts wrt ..got]
	
	
	mov rax, 3 ; Close syscall
	mov rdi, [fd]
	syscall
	
	
	add   rsp, 8
	mov   rax, [len]
	ret
	
read_file:
	sub		rsp, 8
	    
	mov rax, 9      ; syscall mmap    ALLOCATE 4096 bytes of memory
    xor rdi, rdi    ; addr = NULL
    mov rsi, 4096   ; len = 4096
    mov rdx, 7      ; prot = PROT_READ|PROT_WRITE|PROT_EXEC
    mov r10, 34     ; flags = MAP_PRIVATE|MAP_ANONYMOUS
    mov r9, -1     ; fd = -1
    xor r8, r8    ; offset = 0 (4096*0)
    syscall         ; make call
	mov [buffer], rax

	mov rax, 0 ; Read syscall
	mov rdi, [fd]
	lea rsi, [buffer] ; address of memore
	mov rdx, 4095
	syscall
	mov [len], rax
	
	add		rsp, 8
	ret