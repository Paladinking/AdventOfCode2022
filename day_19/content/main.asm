default rel

section .rodata            ; .rodata is best for constants, not .data
	input_file: db '../input/input19.txt', 0

section .bss
	fd: resq 1
	buffer: resq 1
	blueprints: resq 1
	blueprints_len: resq 1
	expensive: resq 3
	to_visit: resq 1
	to_visit_cap: resq 1
	len: resq 1
	initial_brk: resq 1
	prev_brk: resq 1
	cur_brk: resq 1
	err: resq 1

section .text

; prints the (64 bit) integer in rdi
print_int:
	push rax
	push rcx
	push rbx
	push rsi
	push rdx
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	mov rsi, rsp
	sub rsi, 8
	sub rsp, 32
	mov r8, 10
	mov r9, 0
print_int_loop:
	inc r9
	mov rax, rdi
	mov rdx, 0
	div r8
	add rdx, '0'
	mov BYTE [rsi], dl
	cmp r8, rdi
	jg print_int_print
	mov rdi, rax
	dec rsi
	jmp print_int_loop
print_int_print:
	mov rdx, r9
	mov rax, 1 ; syscall write
	mov rdi, 1 ; stdout
	syscall
print_int_exit:
	add rsp, 32
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rdx
	pop rsi
	pop rbx
	pop rcx
	pop rax
	ret

print_ln:
	push rax
	push rcx
	push rbx
	push rsi
	push rdx
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	mov rsi, rsp
	mov BYTE [rsi], 10
	
	mov rax, 1 ; syscall write
	mov rdx, 1 ; 1 byte
	mov rdi, 1 ; stdout
	syscall
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rdx
	pop rsi
	pop rbx
	pop rcx
	pop rax
	ret

global main
main:
    push r12 ; align the stack by 16
	push r13
	push r14

	mov rax, 12				;
	mov rdi, 0				;
	syscall					;
	mov [initial_brk], rax	; Get initial brk
	mov [prev_brk], rax		;
	mov [cur_brk], rax		;

	call read_file
	call parse_file

	mov rax, 11 ; syscall munmap
	mov rdi, [buffer]
	mov rsi, [len]
	syscall
	
	
	mov rcx, 9 * 8 * 100    ; 1 node -> 9 * 8 bytes, start with 100 nodes capacity
	call inc_brk 	
	mov rcx, [prev_brk]
	mov [to_visit], rcx
	mov QWORD [to_visit_cap], 100 * 9 * 8

	
	mov r12, 0
	mov r13, 0
	mov rdi, [blueprints]
	
main_first_loop:
	inc r13
	call find_expensive
	mov rsi, 24
	call find_best
	mul r13
	add r12, rax
	add rdi, 96
	cmp r13, [blueprints_len]
	jl main_first_loop
	mov rdi, r12
	call print_int
	call print_ln

	mov rdi, [blueprints]
	call find_expensive
	mov rsi, 32
	call find_best
	mov r12, rax
	add rdi, 96
	call find_expensive
	mov rsi, 32
	call find_best
	mul r12
	mov r12, rax
	add rdi, 96
	call find_expensive
	mov rsi, 32
	call find_best
	mul r12
	
	mov rdi, rax
	call print_int
	call print_ln

main_exit:
	pop r14
	pop r13
	pop r12
	mov rax, [err]
	ret
	
; rdi = ptr to blueprint
find_expensive:
	push rdi
	mov QWORD [expensive], 0
	mov QWORD [expensive + 8], 0
	mov QWORD [expensive + 16], 0
	mov r8, rdi
	add r8, 8 * 3 * 4
find_expensive_loop:
	mov rcx, [rdi]
	cmp [expensive], rcx 
	jge find_expensive_second
	mov QWORD [expensive], rcx
find_expensive_second:
	add rdi, 8
	mov rcx, [rdi]
	cmp [expensive + 8], rcx 
	jge find_expensive_third
	mov QWORD [expensive + 8], rcx
find_expensive_third:
	add rdi, 8
	mov rcx, [rdi]
	cmp [expensive + 16], rcx
	jge find_expensive_check
	mov QWORD [expensive + 16], rcx
find_expensive_check:
	add rdi, 8
	cmp rdi, r8
	je find_expensive_exit
	jmp find_expensive_loop
find_expensive_exit:
	pop rdi
	ret

; r10 = ore
; r11 = clay
; r12 = obsidian
; rdi = ptr to blueprint
; rsi = offset in blueprint
affords:
	push rdi
	add rdi, rsi
	cmp r10, [rdi]
	jl affords_false
	add rdi, 8
	cmp r11, [rdi]
	jl affords_false
	add rdi, 8
	cmp r12, [rdi]
	jl affords_false
affords_true:
	mov rax, 1
	pop rdi
	ret
affords_false:
	mov rax, 0
	pop rdi
	ret
	
add_robot:
	push rdi
	mov QWORD [rbx + 9 * 8], r13 		;ore_robots
	mov QWORD [rbx + 8 + 9 * 8], r14	;clay_robots
	mov QWORD [rbx + 16 + 9 * 8], r15	;obsidian_robots
	mov QWORD [rbx + 24 + 9 * 8], rdx	;geoide_robots
	mov QWORD [rbx + 32 + 9 * 8], r10	;ore
	add QWORD [rbx + 32 + 9 * 8], r13	;ore += ore_robots
	mov QWORD [rbx + 40 + 9 * 8], r11	;clay
	add QWORD [rbx + 40 + 9 * 8], r14	;clay += clay_robots
	mov QWORD [rbx + 48 + 9 * 8], r12	;obsidian
	add QWORD [rbx + 48 + 9 * 8], r15	;obsidian += obsidian_robots
	mov QWORD [rbx + 56 + 9 * 8], r9	;geoide
	mov QWORD [rbx + 64 + 9 * 8], r8 	;time

	mov rdi, rdx

	cmp rdx, 1
	jl add_robot_check
	;call print_int
	;call print_ln
	;call print_ln
add_robot_check:
	cmp rsi, 255
	je add_robot_none
	add rsi, rbx
	add rsi, 9 * 8
	add QWORD [rsi], 1
add_robot_none:
	cmp rbx, [to_visit_cap]
	add rbx, 9 * 8
	jl add_robot_exit
	push r8
	push r9
	push r10
	push r11
	push rdx
	mov rcx, [to_visit_cap]
	add [to_visit_cap], rcx
	call inc_brk
	pop rdx
	pop r11
	pop r10
	pop r9
	pop r8
add_robot_exit:
	pop rdi
	ret

; rdi = ptr to blueprint
; rsi = total_time 	
find_best:
	push rdi
	push r12 
	push r13
	push r14
	push r15
	push rbx ; rbx = last element in list
	push rbp
	mov rbp, rsp

	sub rsp, 16   ; best = rbp - 8

	mov QWORD [rbp - 8], 0 ; initalize best to 0

	mov rbx, [to_visit]
	mov QWORD [rbx], 1 			; ore robots 
	mov QWORD [rbx + 8], 0		; clay robots
	mov QWORD [rbx + 16], 0		; obsidian robots
	mov QWORD [rbx + 24], 0		; geoide robots
	mov QWORD [rbx + 32], 0		; ore
	mov QWORD [rbx + 40], 0		; clay
	mov QWORD [rbx + 48], 0		; obsidian
	mov QWORD [rbx + 56], 0		; geoide
	mov QWORD [rbx + 64], rsi	; time left

find_best_loop:
	mov r8, [rbx + 64]		; r8 = prev_time - 1
	sub r8, 1				;
	mov r9, [rbx + 56] ;
	add r9, [rbx + 24] ; r9 = geide + geoide_robot
	
	sub rbx, 9 * 8
	cmp r8, 0
	jg find_best_loop_has_time
	cmp r9, [rbp - 8]
	jle find_best_continue
	mov [rbp - 8], r9
	jmp find_best_continue
find_best_loop_has_time:
	mov rax, r8  ;
	mul r8		 ; rxc = time * time // 2
	mov rcx, rax ; 
	shr rcx, 1	 ;
	mov rax, r8
	mul QWORD [rbx + 9 * 8 + 24] ; rax = time * geoide_robots
	add rcx, r9
	add rcx, rax
	cmp rcx, [rbp - 8]
	jl find_best_continue		;  ((time)**2) // 2 < best - geides - geide_robots * time
	mov r10, [rbx + 9 * 8 + 32]			; r10 = ore
	mov r13, [rbx + 9 * 8]		; r13 = ore_robots
	mov r11, [rbx + 9 * 8 + 40]		; r11 = clay
	mov r14, [rbx + 9 * 8 + 8]		; r14 = clay_robots
	mov r12, [rbx + 9 * 8 + 48]		; r12 = obsidian
	mov r15, [rbx + 9 * 8 + 16]		; r15 = obsidian_robots
	mov rdx, [rbx + 9 * 8 + 24]		; rdx = geide_robots
find_best_loop_ore_robot:
	mov rcx, r13
	cmp rcx, [expensive]
	jge find_best_loop_clay_robot
	mov rsi, 0
	call affords
	cmp rax, 0
	je find_best_loop_clay_robot
	; Add node with ore robot
	sub r10, [rdi]
	mov rsi, 0
	call add_robot
	add r10, [rdi]
find_best_loop_clay_robot:
	mov rcx, r14
	cmp rcx, [expensive + 8]
	jge find_best_loop_orbsidan_robot
	mov rsi, 24
	call affords
	cmp rax, 0
	je find_best_loop_orbsidan_robot
	; Add node with clay robot
	sub r10, [rdi + 24]
	mov rsi, 8
	call add_robot
	add r10, [rdi + 24]
find_best_loop_orbsidan_robot:
	mov rcx, r15
	cmp rcx, [expensive + 16]
	jge find_best_loop_geoide_robot
	mov rsi, 48
	call affords
	cmp rax, 0
	je find_best_loop_geoide_robot
	; Add node with obsidian robot
	sub r10, [rdi + 48]
	sub r11, [rdi + 56]
	mov rsi, 16
	call add_robot
	add r10, [rdi + 48]
	add r11, [rdi + 56]
find_best_loop_geoide_robot:
	mov rsi, 72
	call affords
	cmp rax, 0
	je find_best_no_robot
	; Add node with geoide robot
	sub r10, [rdi + 72]
	sub r12, [rdi + 88]
	mov rsi, 24
	call add_robot
	add r10, [rdi + 72]
	add r12, [rdi + 88]
find_best_no_robot:
	; Add node with no extra robot
	mov rcx, [expensive]
	cmp rcx, r10
	jle find_best_continue
	mov rsi, 255
	call add_robot
find_best_continue:
	cmp rbx, [to_visit]
	jge find_best_loop

find_best_exit:
	mov rax, [rbp - 8]
	mov rsp, rbp
	pop rbp
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rdi
	ret

; increases brk by value in rcx
inc_brk: 
	push r12
	push rsi
	push rdi

	mov rdi, [cur_brk]
	mov [prev_brk], rdi
	mov rax, 12
	add rdi, rcx
	syscall
	mov [cur_brk], rax
inc_brk_exit:
	pop rdi
	pop rsi
	pop r12
	ret

; parses the number pointed to by rdi, putting the result in rax and moving rdi past the number
parse_int:
	push rcx
	mov rax, 0
parse_int_loop:
	mov rcx, 0
	mov cl, [rdi]
	sub cl, '0'
	mov rdx, 10
	mul rdx
	add rax, rcx
	inc rdi
	cmp BYTE [rdi], '0'
	jl parse_int_exit
	cmp BYTE [rdi], '9'
	jle parse_int_loop
parse_int_exit:
	pop rcx
	ret
	
parse_file:
	push r12
	; rdi = pos, rsi = end
	mov r12, [cur_brk]
	mov [blueprints], r12

	mov rdi, [buffer]
	mov rsi, rdi
	add rsi, [len]
	mov QWORD [blueprints_len], 0
parse_file_loop:
	mov rcx, 8 * 12
	call inc_brk
	add QWORD [blueprints_len], 1
	add rdi, 34
parse_file_loop_adj:			;
	cmp BYTE [rdi], '0'			;
	jl parse_file_loop_inc		;
	cmp BYTE [rdi], '9'			;
	jle parse_file_loop_good	; Higher blueprints have several digits in their id, skip that.
parse_file_loop_inc:			;
	inc rdi						;
	jmp parse_file_loop_adj		;
parse_file_loop_good:			;
	call parse_int
	mov QWORD [r12], rax
	add r12, 8
	mov QWORD [r12], 0
	add r12, 8
	mov QWORD [r12], 0
	add r12, 8
	add rdi, 28
	call parse_int
	mov QWORD [r12], rax
	add r12, 8
	mov QWORD [r12], 0
	add r12, 8
	mov QWORD [r12], 0
	add r12, 8
	add rdi, 32
	call parse_int
	mov QWORD [r12], rax
	add r12, 8
	add rdi, 9
	call parse_int
	mov QWORD [r12], rax
	add r12, 8
	mov QWORD [r12], 0
	add r12, 8
	add rdi, 30
	call parse_int
	mov QWORD [r12], rax
	add r12, 8
	mov QWORD [r12], 0
	add r12, 8
	add rdi, 9
	call parse_int
	mov QWORD [r12], rax
	add r12, 8
	add rdi, 11
	cmp rdi, rsi
	jl parse_file_loop
parse_file_exit:
	pop r12
	ret
	
read_file:
	sub	rsp, 8
	
	mov rax, 2 ; Open syscall
	lea rdi, [input_file]
	mov rsi, 0 ; O_RD_ONLY
	mov rdx, 0
	syscall
	mov [fd], rax
	
	mov rax, 8 ; lseek syscall
	mov rdi, [fd]
	mov rsi, 0 ; offset = 0
	mov rdx, 2 ; SEEK_END
	syscall
	mov [len], rax
	
	mov rax, 8 ; lseek syscall
	mov rdi, [fd]
	mov rsi, 0 ; offset = 0
	mov rdx, 0 ; SEEK_SET
	syscall
    
	mov rax, 9      ; syscall mmap    ALLOCATE [len] bytes of memory
    xor rdi, rdi    ; addr = NULL
    mov rsi, [len]  ; len = length of file
	inc rsi
    mov rdx, 7      ; prot = PROT_READ|PROT_WRITE
    mov r10, 34     ; flags = MAP_PRIVATE|MAP_ANONYMOUS
    mov r8, -1     ; fd = -1
    mov r9, 0    ; offset = 0
    syscall
	mov [buffer], rax

	mov rax, 0 ; Read syscall
	mov rdi, [fd]
	mov rsi, [buffer] ; address of memory
	mov rdx, [len]
	syscall

	mov rax, 3 ; Close syscall
	mov rdi, [fd]
	syscall

	add	rsp, 8
	ret