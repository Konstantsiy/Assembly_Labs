.model tiny
.code
.386
org 100h
start:
    jmp main

    int_1B          dd ?
    int_15          dd ?
    flag            db ?
    error_message   db "Error", 0Dh, 0Ah, '$'
    file_path       db 125 dup (0)
    file_handle     dw ?
    buf             db ?
;========================================
_print      macro str  
        push ax
        push dx
        lea dx, str
        mov ah, 09h
        int 21h
        pop dx
        pop ax 
endm
;========================================
emul_1B macro
    cmp al, 2Eh
    jne handle_15_not_interested
    push ax
    mov ah, 02h
    int 16h; считать состояние клавиш - получаем флаги клавиатуры
    and al, 100b
    cmp al, 100b; 2-й бит - нажата ли люба клавиша Ctrl
    pop ax
    jne handle_15_not_interested

    mov flag, 0
endm
;===============================
handle_15 proc; is called by 09h, al - scancode
    push ds
    pushf
    cmp ah, 4Fh
    jne not_mine
    call cs:int_15
    jc handle_15_fine; c set if handling is needed
    jmp handle_15_end
    handle_15_fine:
    push ax
    and al, 128; 10000000 - if bit 7 is 1, it's key release scancode
    cmp al, 128
    pop ax
    je handle_15_not_interested

    mov flag, 1

    emul_1B

    handle_15_not_interested:
    stc
    jmp handle_15_end
    handle_15_not_c:
    clc
    jmp handle_15_end
    not_mine:
    call cs:int_15
    handle_15_end:
    pop ds
    iret
endp
;===============================
handle_1B proc
    mov flag, 0
    iret
endp
;===============================
parce_command_line proc; c set on error
    push bx
    push cx
    xor ah, ah
    mov al, byte ptr ds:[80h]
    cmp al, 0
    je parce_command_line_error

    xor ch, ch
    mov cl, al
    mov di, 81h; начало ком строки
    call store_file_name
    jc parce_command_line_error
    jmp parce_command_line_end 
    
    parce_command_line_error:
    stc
    
    parce_command_line_end:
    pop cx
    pop bx
    ret
endp
;===============================
store_file_name proc
    push ax
    push si
    mov al, ' '
    repe scasb; пропускаем пробелы
    cmp cx, 0
    je store_file_name_start_error; если только пробелы
    dec di
    inc cx
    push di
    mov si, di
    mov di, offset file_path
    rep movsb; переписываем имя файла
    jmp store_file_name_end
    
    store_file_name_start_error:
    push di        
    
    store_file_name_error:
    stc      
    
    store_file_name_end:
    pop di
    pop si
    pop ax
    ret
endp
;===============================
main:
    mov flag, 1
    call parce_command_line
    jc error

    mov ah, 3Dh        
    mov al, 00h
    ;mov al, 0100000b
    mov dx, offset file_path
    int 21h
    jc error
    mov file_handle, ax
    
    mov ah, 35h
    mov al, 15h
    int 21h
    mov word ptr int_15, bx
    mov word ptr int_15 + 2, es

    mov ah, 35h
    mov al, 1Bh
    int 21h
    mov word ptr int_1B, bx
    mov word ptr int_1B + 2, es

    mov ah, 25h
    mov al, 15h
    mov dx, offset handle_15
    int 21h

    mov ah, 25h
    mov al, 1Bh
    mov dx, offset handle_1B
    int 21h

    mov bx, file_handle
    main_loop:
        mov cx, 1
        mov dx, offset buf
        mov ah, 3Fh
        int 21h; читаем символ из файла
        jc main_loop_end
        cmp ax, 0
        je main_loop_end
        
        mov dl, buf
        mov ah, 02h; функция вывода символа
        
        main_loop_wait:
        cmp flag, 0; ждём
        je main_loop_wait

        int 21h; выводим символ

        mov cx, 0; задержка
        mov dx, 1h
        mov ah, 86h
        int 15h

        jmp main_loop
    
    main_loop_end:
    mov ah, 3Eh; close file
    mov bx, offset file_handle
    int 21h

    mov ah, 25h
    mov al, 15h
    push ds
    push int_15 + 2
    mov dx, word ptr [int_15]
    pop ds
    int 21h
    pop ds

    mov ah, 25h
    mov al, 1Bh
    push ds
    push int_1B + 2
    mov dx, word ptr [int_1B]
    pop ds
    int 21h
    pop ds

    jmp _end

    error:
    _print error_message

    _end:
    mov ax, 4C00h
    int 21h

end start