code_seg segment
        ASSUME  CS:CODE_SEG,DS:code_seg,ES:code_seg
	org 100h
;
CR		EQU		13
LF		EQU		10
Space	EQU		20h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_letter	macro	letter
	push	AX
	push	DX
	mov	DL, letter
	mov	AH,	02
	int	21h
	pop	DX
	pop	AX
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_mes	macro	message
	local	msg, nxt
	push	AX
	push	DX
	mov	DX, offset msg
	mov	AH,	09h
	int	21h
	pop	DX
	pop	AX
	jmp nxt
	msg	DB message,'$'
	nxt:
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_screen	macro
    push ax
    push bx
    push cx
    push dx
    
	mov ax,600h
	mov bh,7
	xor cx,cx
	mov dx,184Fh
	int 10h
	
	mov ah, 02h
	mov dx, 0000h
	mov bh, 0h
	int 10h
	
	pop dx
	pop cx
	pop dx
	pop ax
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_page1	macro
    local pr1, lp1, lp2, exit
	push ax
    push bx
    push cx
    push dx
	                
	mov dx,offset Letters1  ;0
	mov ah,9
	int 21h
print_letter	CR
print_letter	LF	
	mov dx,offset Percents
	mov ah,9
	int 21h
;=========================
    mov cx, 0013
    mov bx, 0000
    mov dh, 00 
    
    lp1:
	mov dl, 02
	;mov bh, 0
	mov ah, 2
	int 10h
    print_line
    inc dh
    inc bx
    loop lp1

	pop dx
	pop cx
	pop bx
	pop ax
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_page2	macro
    local pr1, lp1, lp2, exit
	push ax
    push bx
    push cx
    push dx
	
	mov dx,offset Letters2  ;13
	mov ah,9
	int 21h
print_letter	CR
print_letter	LF	
	mov dx,offset Percents
	mov ah,9
	int 21h
;=========================
    mov cx, 0013
    mov bx, 0013
    mov dh, 00 
    
    lp2:
	mov dl, 02
	;mov bh, 0
	mov ah, 2
	int 10h
    print_line
    inc dh
    inc bx
    loop lp2
	
	pop dx
	pop cx
	pop bx
	pop ax
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_line	macro
	push ax
    push bx
    push cx
    push dx
     
	xor cx, cx
	mov cl, Alphabet[bx]
	mov ax, 0920h
	mov bx, 0050h
    int 10h  
	
	pop dx
	pop cx
	pop bx
	pop ax
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
print_mes	'Input File Name > '	
	mov		AH,	0Ah
	mov		DX,	offset	FileName
	int		21h
print_letter	CR
print_letter	LF

	xor	BH,	BH
	mov	BL,  FileName[1]
	mov	FileName[BX+2],	0

	mov	AX,	3D00h
	mov	DX, offset FileName+2
	int	21h
	jnc	openOK
print_letter	CR
print_letter	LF
print_mes	'File do not exist. Open error.'
    int 20h
;=========================================================================
    openOK:
print_letter	CR
print_letter	LF
print_mes	'Open success. Please, wait for scaning...'
    mov Handler, ax
    
    mov ah, 3Fh
    mov bx, Handler
    mov cx, 00C8h
    mov dx, offset Buffer
    int 21h
	
	cld
	xor ax, ax
	xor bx, bx
	mov si, offset Buffer
	mov cx, 00C8h
	mov dx, 0061h               ;ascii code of letter 'a'
	load: 
	lodsb
    cmp al, 7Bh                 ;checking for letters from 'a' to 'z'
    jg looper                   ;if it not a letter, continue loop
    cmp al, 60h                 ;
    jl looper                   ;
    
    mov bl, al
    sub bl, dl                  ;al = al - bl
    inc Alphabet[bx]            ;inc value of current letter
    looper:
    loop load
    
    xor ax, ax
    xor bx, bx
    mov al, 0C8h                ;200 (size of input) - if the input size changes, change this value
    mov bl, 64h                 ;100
    div bl                      ;find value of 1% (ax = ax/bx)
    xor dl, dl
    mov dl, al                  ;move value of 1% in dl
        
    mov cx, 001Ah               ;move 26 in cx for loop 26 times
    xor bx, bx
    xor ax, ax
    calc:
    xor ax, ax
    mov al, Alphabet[bx]
    div dl                      ;find percentage of each letter in Alphabet
    mov Alphabet[bx], al
    inc bx
    loop calc
    
    clear_screen
    print_page1
    
	for1:	
	mov ax, 0000
	int 16h                     ;waiting for a key press 
	jmp com
	
	fin:
    int 20h
	
	com:
	cmp ah, 48h
	je page1
	cmp ah, 49h
	je page1
	cmp ah, 50h
	je page2
	cmp ah, 51h
	je page2
	cmp al, 66h
	je fin
	jmp for1
	
	page1:
	clear_screen
	print_page1
	jmp for1
	
	page2:
	clear_screen
	print_page2
	jmp for1
;
FileName	DB		14,0,14 dup (0)
Letters1 db 'a',13,10,'b',13,10,'c',13,10,'d',13,10,'e',13,10,'f',13,10,'g',13,10,'h',13,10,'i',13,10,'j',13,10,'k',13,10,'l',13,10,'m','$'
Letters2 db 'n',13,10,'o',13,10,'p',13,10,'q',13,10,'r',13,10,'s',13,10,'t',13,10,'u',13,10,'v',13,10,'w',13,10,'x',13,10,'y',13,10,'z','$'
Percents db '  00   10   20   30   40   50   60   70   80   90   100','$'
Handler dw ?
Buffer db 201 dup  ('$')
Alphabet db 26 dup (0)

	code_seg ends
         end start
	
	