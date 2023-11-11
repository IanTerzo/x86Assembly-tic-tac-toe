section .text
    global _start

print:
    mov rax, 1
    mov rdi, 1
    mov rsi, [rsp + 16]
    mov rdx, [rsp + 8]
    syscall
    ret

displayboard:
	mov rsi, char
	
	; Set the counter to 0
	xor r14, r14
	mov r14, 0
	
	; Set registers for write
	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	
	; Write a newline
	mov r9b, 10
	mov [rsi], r9b
	syscall
	
	displayloop:
		; Get the current piece in the board 
		mov r8b, [board + r14]
		
		; Display a square with the piece
		
		mov r9b, 0x5b
		mov [rsi], r9b
		syscall
	
		mov r9b, 0x4F
		mov [rsi], r9b
		cmp r8b, 1
		je log
		
		mov r9b, 0x58
		mov [rsi], r9b
		cmp r8b, -1
		je log
		
		mov r9b, 0x20
		mov [rsi], r9b
		
		log:
			syscall
		
		mov r9b, 0x5d
		mov [rsi], r9b
		syscall
		
		mov r9b, 10
		mov [rsi], r9b
		cmp r14, 2
		je newline
		cmp r14, 5
		je newline
		
		mov r9b, 0
		mov [rsi], r9b
		
		newline:
			syscall
		
		inc r14
		cmp r14, 9
		jne displayloop

	displayloop_end:
		mov r9b, 10
		mov [rsi], r9b
		syscall
		ret

ask_one:
	call displayboard
	
	mov r10, -1
	
	push qword begin_one
	push qword len_begin_one
	call print
	pop r15
	
	jmp main
	
ask_two:
	call displayboard
	
	mov r10, 1
	
	push qword begin_two
	push qword len_begin_two
	call print
	pop r15
	
	jmp main

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
	
victory_one:
	call displayboard
	
	push qword win_one
	push qword len_win_one
	call print
	pop r15
	
	call exit
	
victory_two:
	call displayboard
	
	push qword win_two
	push qword len_win_two
	call print
	pop r15
	
	call exit

tie:
	call displayboard
	
	push qword tie_msg
	push qword len_tie_msg
	call print
	pop r15
	
	call exit
	
badpos:
	push qword invalid
	push qword len_invalid
	call print
	pop r15
	
	jmp main

main:
	; Empty the buffer
	
	mov rdi, buffer
	mov rcx, len_buffer
	
    xor al, al
	rep stosb
	
	; Read user input
	
	mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, len_buffer
    syscall
	
	; Check for invalid positions
	
	mov al, [buffer + 2]
	
	cmp al, 0
	jne badpos
	
	mov al, [buffer]
	
	cmp al, 0x30
	jl badpos
	
	cmp al, 0x39
	jg badpos
	
	sub al, 0x30
	
	cmp al, 0
	je badpos
	
	cmp byte [board + rax -1], 0
	jne badpos
	
	; Overwrite the board
	
	mov byte [board + rax -1], r10b
	
	; Check if there is a winner
	
	; l1 [x][x][x]
	
	mov al, [board + 0]
	add al, [board + 1]
	add al, [board + 2]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; l2 [x][x][x]
	
	mov al, [board + 3]
	add al, [board + 4]
	add al, [board + 5]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; l3 [x][x][x]
	
	mov al, [board + 6]
	add al, [board + 7]
	add al, [board + 8]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; r1 [x]
	;    [x]
	;    [x]
	
	mov al, [board + 0]
	add al, [board + 3]
	add al, [board + 6]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; r2 [x]
	;    [x]
	;    [x]
	
	mov al, [board + 1]
	add al, [board + 4]
	add al, [board + 7]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; r3 [x]
	;    [x]
	;    [x]
	
	mov al, [board + 2]
	add al, [board + 5]
	add al, [board + 8]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; d1 [x]
	;       [x]
	;          [x]
	
	mov al, [board + 0]
	add al, [board + 4]
	add al, [board + 8]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; d2       [x]
	;  	    [x]
	;    [x]
	
	mov al, [board + 2]
	add al, [board + 4]
	add al, [board + 6]
	cmp al, -3
	je victory_one
	cmp al, 3
	je victory_two
	
	; Increment the move counter
	inc r12
	
	; Check if 9 moves have passed
	cmp r12, 9
	je tie
	
	cmp r10, -1
	je ask_two
	
	cmp r10, 1
	je ask_one

_start:
	; Set the move counter to 0
	mov r12, 0
	
	call ask_one
	
section .data
	board: db 0,0,0, 0,0,0 ,0,0,0
	
	char: db 0x00
	
	playarea: db "[ ][ ][ ]", 10, "[ ][ ][ ]", 10, "[ ][ ][ ]", 10, 10
    len_playarea: equ $-playarea
	
	invalid: db "Error: Bad position:  "
    len_invalid: equ $-invalid
	
	begin_one: db "First players turn (X): "
    len_begin_one: equ $-begin_one
	
	begin_two: db "Second players turn (O): "
    len_begin_two: equ $-begin_two
	
	win_one: db "Player one won!", 10
    len_win_one: equ $-win_one
	
	win_two: db "Player two won!", 10
    len_win_two: equ $-win_two
	
	tie_msg: db "Tie!", 10
    len_tie_msg: equ $-tie_msg
	
	buffer: times 64 db 0
	len_buffer: equ 64