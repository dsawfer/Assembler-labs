;12345678.123
;+---------------------------------------------------------------------------
code_seg segment
        ASSUME  CS:CODE_SEG,DS:code_seg,ES:code_seg
	org 100h
start:
;----------------------------------------------------------------------------
		mov CL,ES:80h       ; ����� 墮�� � PSP
        cmp CL,0            ; ����� 墮��=0?
        je  no_params   	; ��, �ணࠬ�� ����饭� ��� ��ࠬ��஢,
                            ; ���஡㥬 ��⠭�����
        xor CH,CH       	; CX=CL= ����� 墮��
        cld             	; DF=0 - 䫠� ���ࠢ����� ���।
        mov DI, 81h     	; ES:DI-> ��砫� 墮�� � PSP
        mov AL, ' '         ; ���६ �஡��� �� ��砫� 墮��
		
repe    scasb   	; ������㥬 墮�� ���� �஡���
					; AL - (ES:DI) -> 䫠�� ������
					; �������� ���� ������ ࠢ��
				
        dec DI          	; DI-> �� ���� ᨬ��� ��᫥ �஡����
		inc CL
		
		mov BL, CL			; �㦥� ��� ����� '$' � ����� filename
		;xor CX,CX
		;mov CL, ES:80h				; ����� 墮�� � PSP
		mov SI, DI					; ��㤠 ��६�����
		mov DI, offset filename		; �㤠
		rep movsb
		
		mov filename[BX], '$'		; ������ asciz ��ப�
		
		mov DX, offset filename
		xor AL, AL
		mov AH, 41h
		int 21h
		jc error
		
		lea DX, success
		call PRINT
		int 20h
		
		no_params:
        lea DX,	nparams          	; �뢮� �� �࠭ ᮮ�饭��: error, no parametrs
        call PRINT
        int 20h
		
		error:
		cmp AX, 02h
		je no_file
		cmp AX, 03h
		je no_path
		cmp AX, 04h
		je no_access
		
		lea DX, denied
		call PRINT
		int 20h
		
		no_file:
		lea DX, nfile
		call PRINT
		int 20h
		
		no_path:
		lea DX, npath
		call PRINT
		int 20h
		
		no_access:
		lea DX, naccess
		call PRINT
		int 20h

;----------------------------------------------------------------------------
filename	DB	14 dup (0)

naccess		DB	'you cannot delete this type of file', 13,10,'$'
nparams		DB	'error, no parametrs', 13,10,'$'
nfile		DB	'error, no file', 13,10,'$'
npath		DB	'error, not correct path', 13,10,'$'
denied		DB	'error, access is denied', 13,10,'$'
success		DB	'delete successfull', 13,10,'$'
;============================================================================
PRINT       PROC NEAR
    MOV AH,09H
    INT 21H
    RET
PRINT       ENDP
;;============================================================================
code_seg ends
         end start
