;.386
code_seg segment
        ASSUME  CS:CODE_SEG,DS:code_seg,ES:code_seg
	org 100h
start:
	jmp begin
old_09h	DD	?
old_2Fh	DD	?
old_21h	DD	?

high_Y	DB  08
left_X	DB  54
low_Y	DB  15
right_X	DB  69

win_signal 		DB 0
ban_type		DB 0
scroll_const	DB 0

coord_Y     DB  9
coord_X     DB  60
menu_size	DW	6

type_names	DB	'none$.exe$.txt$.pdf$.asm$.com$'
array_lem	DW	0

new_09h proc far
	pushf
	push AX
	in AL, 60h
	cmp AL, 3Bh				;����� F1?
	je f1_protect			;��, �� ���� �뢥����?
	jmp skip
	
	f1_protect:
	cmp CS:win_signal, 0	;���� ���, �㦭� �뢥��
	je hotkey				;��룠�� �� �뢮� ����
	
	skip:
	pop AX					;����� �� F1
	popf
	jmp dword ptr CS:[old_09h]
	
	hotkey:
	sti						;����訬 ���쭥���� ࠡ��� ����������
	in 		AL, 	61h 	;������ ᮤ�ন��� ���� �
	or 		AL, 	80h 	;��⠭���� ���訩 ��� jmp $+2
	out 	61h, 	AL 		;� ��୥� � ���� �
	and 	AL, 	7Fh 	;����� ࠧ�訬 ࠡ��� ����������
	out 	61h, 	AL 		;���ᨢ ���訩 ��� � ����� �
		push    BX
        push    CX
        push    DX
		push	DS
		push	CS
		pop		DS
		
	mov BH, 70h				;��� 梥�
	inc CS:win_signal		;ᨣ�������㥬, �� ���� �뢥����
	
	win_pr:
	mov     AX, 0600h		;�뢮� 梥⭮�� ������
    mov     CH, CS:high_Y
    mov     CL, CS:left_X
    mov     DH, CS:low_Y
    mov     DL, CS:right_X
    int 10h
	
;--------------------�뢮� ����---------------------
menu:
	mov CX,	CS:menu_size
next_word:
    mov AH, 02h          	; �㭪�� ����樮��஢����
    mov BH, 0h  			; �������࠭��
    mov DH, CS:coord_Y   	; ��ப�
    mov DL, CS:coord_X   	; �⮫���
	int 10h
	
	mov BX, offset CS:type_names	; �뢮��� ����� ⨯�� 䠩��� �� ���ᨢ� type_names
	add BX, CS:array_lem

	mov DX, BX
	mov AH, 09h
	int 21h
	
	add CS:array_lem, 5		; ������ ����� ��� ����� ����� 5 ᨬ�����
	inc CS:coord_Y			; ���᪠���� �� ����� ����
	
    loop    next_word 
;---------------------------------------------------

	mov CS:coord_Y, 9		; ����⠭������� ���न���
	mov CS:array_lem, 0
	
;----------------�뢮� �ࠢ�����-------------------
	add CS:coord_X, -2		; ����樮���㥬 ����� ��� ��५�� >
	mov AH, CS:scroll_const
	add CS:coord_Y, AH
	mov AH, 02h          	; �㭪�� ����樮��஢����
    mov BH, 0h  			; �������࠭��
    mov DH, CS:coord_Y   	; ��ப�
    mov DL, CS:coord_X   	; �⮫���
	int 10h
	
	mov AX,093Eh			; ���⠥� ��५��
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	pushf 					; � ��⥬�� ��ࠡ��稪
	call CS:old_09h	
	control:
	mov AH, 00
    int 16h
	
	cmp ah, 48h				; ��५�� �����
	je move_up
	cmp ah, 50h				; ��५�� ����
	je move_down
	cmp ah, 1Ch				; ����
	je entered
	
	jmp control
	
	entered:
	mov Al, CS:scroll_const	; ���⠢�塞 ⨯ 䠩���, ����� ����� 㤠����
	mov CS:ban_type, AL
	jmp exit
	
	move_up:
	cmp CS:scroll_const, 0
	je control
	mov AX,0920h			; ������ ��५�� �� ⥪�騬 ���न��⠬
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	dec CS:coord_Y
	mov AH, 02h          	; �㭪�� ����樮��஢����
    mov BH, 0h  			; �������࠭��
    mov DH, CS:coord_Y   	; ��ப�
    mov DL, CS:coord_X      ; �⮫���
	int 10h
	
	mov AX, 093Eh			; ���⠥� ��५��
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	dec CS:scroll_const
	mov AX, 0000h
	out 60h, AX
	jmp control
	
	move_down:
	cmp CS:scroll_const, 5
	je control
	mov AX,0920h			; ������ ��५�� �� ⥪�騬 ���न��⠬
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	inc CS:coord_Y
	mov AH, 02h          	; �㭪�� ����樮��஢����
    mov BH, 0h  			; �������࠭��
    mov DH, CS:coord_Y   	; ��ப�
    mov DL, CS:coord_X      ; �⮫���
	int 10h
	
	mov AX,093Eh			; ���⠥� ��५��
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	inc CS:scroll_const
	mov AX, 0000h
	out 60h, AX
	jmp control
	
;---------------------------------------------------
exit:
	mov AH, 02h          	; �㭪�� ����樮��஢����
    mov BH, 0h  			; �������࠭��
    mov DH, 22   			; ��ப�
    mov DL, CS:coord_X      ; �⮫���
	int 10h
	
	mov CS:coord_Y, 9		; ����⠭������� ���न���
	mov CS:coord_X, 60
	mov CS:array_lem, 0
	
	mov BH, 00h				; �몫�祭�� ����
	dec CS:win_signal
	
	mov     AX, 0600h		; �몫�祭�� ����
    mov     CH, CS:high_Y
    mov     CL, CS:left_X
    mov     DH, CS:low_Y
    mov     DL, CS:right_X
    int 10h
	
	pop		DS				; ����⠭�������� ॣ�����
    pop     DX
    pop     CX
    pop     BX
		
	cli
	mov     AL, 20h
	out     20h,AL
	
	pop AX
	popf
	jmp dword ptr CS:[old_09h]
new_09h     endp


new_2Fh proc far
	cmp     AH, 82h		;��� �����?
    jne     Pass_2Fh	;���, �� ��室
    cmp     AL, 00h
    je      inst
    cmp     AL, 01h
    je      unins
    jmp     short Pass_2Fh
inst:
    mov     AL, 0FFh	;�����頥� FF
    iret
pass_2Fh:
	jmp dword ptr CS:[old_2Fh]
unins:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   	; �ਣ������ ��� �ࠢ�����, �.�. � CS �ࠢ������ �����
	
    mov     AX, 3509h   ; �஢���� ����� 09h
    int     21h 		; �㭪�� 35h � AL - ����� ���뢠���. ������-����� � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_09h
    jne     Not_remove
;
    mov     AX, 352Fh   ; �஢���� ����� 2Fh
    int     21h 		; �㭪�� 35h � AL - ����� ���뢠���. ������-����� � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_2Fh
    jne     Not_remove
	
	mov     AX, 3521h   ; �஢���� ����� 21h
    int     21h 		; �㭪�� 35h � AL - ����� ���뢠���. ������-����� � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_21h
    jne     Not_remove
; ---------------------- ���㧪� �ணࠬ�� �� ����� ---------------------
    push    DS
	
    lds     DX, CS:old_09h
    mov     AX,2509h        ; ���������� ����� ���� ᮤ�ন��
    int     21h

    lds     DX, CS:old_2Fh
    mov     AX,252Fh
    int     21h
	
	lds     DX, CS:old_21h
    mov     AX,2521h
    int     21h

    pop     DS

    mov     ES,CS:2Ch       ; ES -> ���㦥���
    mov     AH, 49h         ; �㭪�� �᢮�������� ����� �����
    int     21h

    mov     AX, CS
    mov     ES, AX          ; ES -> PSP ���㧨� ᠬ� �ணࠬ��
    mov     AH, 49h         ; �㭪�� �᢮�������� ����� �����
    int     21h

    mov     AL,0Fh          ; �ਧ��� �ᯥ譮� ���㧪�
    jmp     short pop_ret
Not_remove:
    mov     AL,0F0h         ; �ਧ��� - ���㦠�� �����
pop_ret:
    pop     ES
    pop     DX
    pop     CX
    pop     BX

    iret
new_2Fh endp


new_21h proc far
	cmp AH, 41h			; �஢��塞, �� �㭪�� 㤠����� ��� ���
	je ok_41h
	
	jmp dword ptr CS:[old_21h]
	
	ok_41h:
	push ax				; ��࠭塞 �㦭� ���祭��
	push dx
	push ds
    push dx
    push cs
    pop ds
	
	cld             	; DF=0 - 䫠� ���ࠢ����� ���।
	mov CX, 0Bh
    mov DI, DX     		; � DX �������� 䠩��
    mov AL, '.'         ; ��⠢�� ⮫쪮 ⨯ 䠩�� (� �ਬ��� .txt)
	
	repne    scasb 		; �������� ���� ������ �� ࠢ��
    dec DI          	; DI-> ����� �� ���
	
	cmp CX, 0
	je not_equal
	
	mov AH, 00h			; �� ��直� ��砩 ��⨬ AH
	mov AL, CS:ban_type	; ��室�� �㦭�� ���� � ���ᨢ� type_names � ������ ����饭���� ⨯�
	mov BL, 5			;
	mul BL				;
	
	lea bx, CS:type_names
	add BX, AX			; ��室�� �㦭�� ���� � ���ᨢ� type_names � ������ ����饭���� ⨯�
	
	mov CX, 4			; �ࠢ������ ⨯ 䠩�� � ⥪�� � ���ᨢ� type_names
	mov SI, BX
	repe cmpsb
	jne not_equal		; �᫨ ����� � ᨬ���� �� ࠢ��, ����� ��室��

	pop dx
    pop ds
	pop dx
	pop ax
	
	mov bp, sp			; �⠢�� 䫠� CF ࠢ�� 1
	mov ax, [bp+4]
	or ax, 1
	mov [bp+4], ax
	
	mov ax, 04h			; ����㦠�� ��� �訡�� � AX
	
	iret
	
	not_equal:
	pop dx
    pop ds
	pop dx
	pop ax
	jmp dword ptr CS:[old_21h]
new_21h endp

begin:
	mov CL,ES:80h
    cmp CL,0
    je  check_install
	
    xor CH,CH
    cld
    mov DI, 81h
    mov SI,	offset key
    mov AL,' '
	
	repe scasb
    dec DI
    mov CX, 4
	
	repe cmpsb
    jne check_install
    inc flag_off
	
	check_install:
        mov AX,8200h
        int 2Fh
        cmp AL,0FFh
        je  already_ins
		
	cmp flag_off,1
    je  xm_stranno
;---------------------------------------------------	
	mov AX,3509h					;��������� ����� 09h
	int 21h
	mov word ptr old_09h, BX
    mov word ptr old_09h+2, ES
    mov DX,offset new_09h
    mov AX,2509h
    int 21h
	
	mov AX,352Fh					;��������� ����� 2Fh
	int 21h
	mov word ptr old_2Fh, BX
    mov word ptr old_2Fh+2, ES
    mov DX,offset new_2Fh
    mov AX,252Fh
    int 21h
	
	mov AX,3521h					;��������� ����� 21h
	int 21h
	mov word ptr old_21h, BX
    mov word ptr old_21h+2, ES
    mov DX,offset new_21h
    mov AX,2521h
    int 21h
	
	mov DX, offset msg1
    call print
    mov DX,offset begin
    int 27h							;१������ ��室
;---------------------------------------------------	
already_ins:
    cmp flag_off,1
    je uninstall 
    lea DX, msg
    call print
    int 20h
uninstall:
    mov AX,8201h
    int 2Fh
    cmp AL,0F0h
    je  not_sucsess
    cmp AL,0Fh
    jne not_sucsess
    mov DX,offset msg2
    call    print
    int 20h
not_sucsess:
    mov DX,offset msg3
    call    print
    int 20h
xm_stranno:
    mov DX,offset msg4
    call    print
    int 20h

PRINT PROC NEAR
MOV AH,09H
INT 21H
RET
PRINT ENDP
	
key         DB  '/off'
flag_off    DB  0
msg         DB  'already '
msg1        DB  'installed',13,10,'$'
msg4        DB  'just '
msg3        DB  'not '
msg2        DB  'uninstalled',13,10,'$'

code_seg ends
         end start	