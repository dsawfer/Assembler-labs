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
	cmp AL, 3Bh				;нажата F1?
	je f1_protect			;да, но окно выведено?
	jmp skip
	
	f1_protect:
	cmp CS:win_signal, 0	;окна нет, нужно вывести
	je hotkey				;прыгаем на вывод окна
	
	skip:
	pop AX					;нажата не F1
	popf
	jmp dword ptr CS:[old_09h]
	
	hotkey:
	sti						;Разрешим дальнейшую работу клавиатуры
	in 		AL, 	61h 	;Введем содержимое порта В
	or 		AL, 	80h 	;Установим старший бит jmp $+2
	out 	61h, 	AL 		;И вернем в порт В
	and 	AL, 	7Fh 	;Снова разрешим работу клавиатуры
	out 	61h, 	AL 		;Сбросив старший бит в порту В
		push    BX
        push    CX
        push    DX
		push	DS
		push	CS
		pop		DS
		
	mov BH, 70h				;серый цвет
	inc CS:win_signal		;сигнализируем, что окно выведено
	
	win_pr:
	mov     AX, 0600h		;вывод цветного квадрата
    mov     CH, CS:high_Y
    mov     CL, CS:left_X
    mov     DH, CS:low_Y
    mov     DL, CS:right_X
    int 10h
	
;--------------------Вывод меню---------------------
menu:
	mov CX,	CS:menu_size
next_word:
    mov AH, 02h          	; Функция позиционирования
    mov BH, 0h  			; Видеостраница
    mov DH, CS:coord_Y   	; Строка
    mov DL, CS:coord_X   	; Столбец
	int 10h
	
	mov BX, offset CS:type_names	; Выводим имена типов файлов из массива type_names
	add BX, CS:array_lem

	mov DX, BX
	mov AH, 09h
	int 21h
	
	add CS:array_lem, 5		; Каждое новое имя лежит каждые 5 символов
	inc CS:coord_Y			; Опускаемся на строчку ниже
	
    loop    next_word 
;---------------------------------------------------

	mov CS:coord_Y, 9		; Восстанавление координат
	mov CS:array_lem, 0
	
;----------------Вывод управления-------------------
	add CS:coord_X, -2		; Позиционируем курсор для стрелки >
	mov AH, CS:scroll_const
	add CS:coord_Y, AH
	mov AH, 02h          	; Функция позиционирования
    mov BH, 0h  			; Видеостраница
    mov DH, CS:coord_Y   	; Строка
    mov DL, CS:coord_X   	; Столбец
	int 10h
	
	mov AX,093Eh			; Печатает стрелку
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	pushf 					; В системный обработчик
	call CS:old_09h	
	control:
	mov AH, 00
    int 16h
	
	cmp ah, 48h				; Стрелка вверх
	je move_up
	cmp ah, 50h				; Стрелка вниз
	je move_down
	cmp ah, 1Ch				; Энтер
	je entered
	
	jmp control
	
	entered:
	mov Al, CS:scroll_const	; Выставляем тип файлов, которые нельзя удалять
	mov CS:ban_type, AL
	jmp exit
	
	move_up:
	cmp CS:scroll_const, 0
	je control
	mov AX,0920h			; Удаляет стрелку по текущим координатам
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	dec CS:coord_Y
	mov AH, 02h          	; Функция позиционирования
    mov BH, 0h  			; Видеостраница
    mov DH, CS:coord_Y   	; Строка
    mov DL, CS:coord_X      ; Столбец
	int 10h
	
	mov AX, 093Eh			; Печатает стрелку
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
	mov AX,0920h			; Удаляет стрелку по текущим координатам
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	inc CS:coord_Y
	mov AH, 02h          	; Функция позиционирования
    mov BH, 0h  			; Видеостраница
    mov DH, CS:coord_Y   	; Строка
    mov DL, CS:coord_X      ; Столбец
	int 10h
	
	mov AX,093Eh			; Печатает стрелку
	mov BX, 0070h
	mov CX, 0001h
	int 10h
	
	inc CS:scroll_const
	mov AX, 0000h
	out 60h, AX
	jmp control
	
;---------------------------------------------------
exit:
	mov AH, 02h          	; Функция позиционирования
    mov BH, 0h  			; Видеостраница
    mov DH, 22   			; Строка
    mov DL, CS:coord_X      ; Столбец
	int 10h
	
	mov CS:coord_Y, 9		; Восстанавление координат
	mov CS:coord_X, 60
	mov CS:array_lem, 0
	
	mov BH, 00h				; Выключение окна
	dec CS:win_signal
	
	mov     AX, 0600h		; Выключение окна
    mov     CH, CS:high_Y
    mov     CL, CS:left_X
    mov     DH, CS:low_Y
    mov     DL, CS:right_X
    int 10h
	
	pop		DS				; Восстанавливаем регистры
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
	cmp     AH, 82h		;наш номер?
    jne     Pass_2Fh	;нет, на выход
    cmp     AL, 00h
    je      inst
    cmp     AL, 01h
    je      unins
    jmp     short Pass_2Fh
inst:
    mov     AL, 0FFh	;возвращает FF
    iret
pass_2Fh:
	jmp dword ptr CS:[old_2Fh]
unins:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   	; Пригодится для сравнения, т.к. с CS сравнивать нельзя
	
    mov     AX, 3509h   ; Проверить вектор 09h
    int     21h 		; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_09h
    jne     Not_remove
;
    mov     AX, 352Fh   ; Проверить вектор 2Fh
    int     21h 		; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_2Fh
    jne     Not_remove
	
	mov     AX, 3521h   ; Проверить вектор 21h
    int     21h 		; Функция 35h в AL - номер прерывания. Возврат-вектор в ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_21h
    jne     Not_remove
; ---------------------- Выгрузка программы из памяти ---------------------
    push    DS
	
    lds     DX, CS:old_09h
    mov     AX,2509h        ; Заполнение вектора старым содержимым
    int     21h

    lds     DX, CS:old_2Fh
    mov     AX,252Fh
    int     21h
	
	lds     DX, CS:old_21h
    mov     AX,2521h
    int     21h

    pop     DS

    mov     ES,CS:2Ch       ; ES -> окружение
    mov     AH, 49h         ; Функция освобождения блока памяти
    int     21h

    mov     AX, CS
    mov     ES, AX          ; ES -> PSP выгрузим саму программу
    mov     AH, 49h         ; Функция освобождения блока памяти
    int     21h

    mov     AL,0Fh          ; Признак успешной выгрузки
    jmp     short pop_ret
Not_remove:
    mov     AL,0F0h         ; Признак - выгружать нельзя
pop_ret:
    pop     ES
    pop     DX
    pop     CX
    pop     BX

    iret
new_2Fh endp


new_21h proc far
	cmp AH, 41h			; проверяем, это функция удаления или нет
	je ok_41h
	
	jmp dword ptr CS:[old_21h]
	
	ok_41h:
	push ax				; сохраняем нужные значения
	push dx
	push ds
    push dx
    push cs
    pop ds
	
	cld             	; DF=0 - флаг направления вперед
	mov CX, 0Bh
    mov DI, DX     		; в DX название файла
    mov AL, '.'         ; оставим только тип файла (к примеру .txt)
	
	repne    scasb 		; повторять пока элементы не равны
    dec DI          	; DI-> встать на точку
	
	cmp CX, 0
	je not_equal
	
	mov AH, 00h			; на всякий случай чистим AH
	mov AL, CS:ban_type	; находим нужное место в массиве type_names с именем запрещенного типа
	mov BL, 5			;
	mul BL				;
	
	lea bx, CS:type_names
	add BX, AX			; находим нужное место в массиве type_names с именем запрещенного типа
	
	mov CX, 4			; сравниваем тип файла и текст в массиве type_names
	mov SI, BX
	repe cmpsb
	jne not_equal		; если какие то символы не равны, значит выходим

	pop dx
    pop ds
	pop dx
	pop ax
	
	mov bp, sp			; ставим флаг CF равным 1
	mov ax, [bp+4]
	or ax, 1
	mov [bp+4], ax
	
	mov ax, 04h			; загружаем код ошибки в AX
	
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
	mov AX,3509h					;изменяется вектор 09h
	int 21h
	mov word ptr old_09h, BX
    mov word ptr old_09h+2, ES
    mov DX,offset new_09h
    mov AX,2509h
    int 21h
	
	mov AX,352Fh					;изменяется вектор 2Fh
	int 21h
	mov word ptr old_2Fh, BX
    mov word ptr old_2Fh+2, ES
    mov DX,offset new_2Fh
    mov AX,252Fh
    int 21h
	
	mov AX,3521h					;изменяется вектор 21h
	int 21h
	mov word ptr old_21h, BX
    mov word ptr old_21h+2, ES
    mov DX,offset new_21h
    mov AX,2521h
    int 21h
	
	mov DX, offset msg1
    call print
    mov DX,offset begin
    int 27h							;резидентный выход
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