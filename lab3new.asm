.model small
 
.stack 100h
 
.data
        mes             db      0Dh, 0Ah, 'element: $'
        flag            db      0
        bracket1        db      'array[', '$'
        bracket2        db      ']=', '$'
        CrLf            db      0Dh, 0Ah, '$'
        arraySize         equ     30  
        array               dw     arraySize dup (0)
 
        numberBuffer       db      7, 0, 7 dup(0)


        result          db      0dh, 0ah, "Array median: $"
        emptyArrayError   db      0dh, 0ah, "Error: array is empty.$"
        errorNumberMessage      db  "Error: incorrect number.", 0dh, 0ah, '$'
 
.code
;=========================================
_end macro
        mov ah, 4ch
        int 21h
endm    
;=========================================
_print      macro str
        lea dx, str
        mov ah, 09h
        int 21h 
endm 
;=========================================
_input      macro str
      lea dx, str
      mov ah, 0ah
      int 21h 
endm 
;=========================================
_terminate macro errorMessage
        _print errorMessage
        ;_end
endm
;========================================= 
main    proc       
        mov     ax,     @data
        mov     ds,     ax
        ;ввод масива
        mov     cx,     arraySize
        lea     dx,     [array]
        call    InputArray
        ;сортировка массива 
        call    HoarSort
        ;вывод массива
        call    ShowArray
        _print CrLf  
        call _findMedian
        mov     ax, 4ch
        int     21h
main    endp
;=========================================  
InputArray      proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
 
        jcxz    @@Exit          ;если массив пустой - завершить
 
        mov     si,     1       ;индекс элемента массива
        mov     di,     dx      ;адрес текущего элемента массива
        mov cx, arraySize
        @@ForI:
                ;вывод приглашения ввода элемента
                _print bracket1
                mov     ax,     si
                call    Show_AX
                _print bracket2
                ;ввод числа
                _input numberBuffer; ввод элемента массива
                _print CrLf; '\n'
 
                push    si
                lea     si, numberBuffer+1 ; преобразование строки в число
                ;lea     di, Numer
                call    Str2Num
                pop     si
 
                ; проверка на ошибку
                jnc     @@NoError
 
                ; если есть ошибка ввода - повторить ввод
                jmp     @@ForI
 
                ; если нет ошибки ввода - сохранить число
                @@NoError:
                ;сохранение введённого числоа в массиве
                ;mov    [di],   ax
                ;переход к следующему элементу
                inc     si
                add     di,     2
        loop    @@ForI
@@Exit:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
InputArray      endp
;======================
_invert         macro 
        neg ax
        shr ax, 1
        neg ax 
        mov flag, 1
endm 
;======================
_findMedian     proc
        mov si, 28 
        mov ax, array[si]
        mov flag, 0 
        cmp ax, 0 
        jnle @@next1
        _invert
        @@next1:
        cmp flag, 1
        je @@justMov1
        shr ax, 1
        @@justMov1:
        mov flag, 0 
        mov bx, ax
        mov ax, array[si + 2]
        cmp ax, 0
        jnle @@next2
        _invert
        @@next2: 
        cmp flag, 1
        je @@justMov2
        shr ax, 1
        @@justMov2:
        add ax, bx
        push ax
        _print result
        pop ax
        call Show_AX                
_findMedian     endp
;====================== 

ShowArray       proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
 
        jcxz    @@Exit1          ;если массив пустой - завершить
 
        mov     si,     1       ;индекс элемента массива
        mov     di,     dx      ;адрес текущего элемента массива
        @@ForI2:
                mov     ax,     [di]
                call    Show_AX
                mov     ah,     02h
                mov     dl,     ' '
                int     21h
                ;переход к следующему элементу
                inc     si
                add     di,     2
        loop    @@ForI2
@@Exit1:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        
        ret
ShowArray       endp
 
; выводит знаковое 16-разрядное число из регистра AX на экран
; входные данные:
; ax - число для отображения
Show_AX proc
        push ax
        push bx
        push cx
        push dx
        push di
 
        mov cx, 10
        xor di, di      ; di - кол. цифр в числе
 
        ; если число в ax отрицательное, то
        ;1) напечатать '-'
        ;2) сделать ax положительным
        or ax, ax
        jns @@Conv
        push ax
        mov dx, '-'
        mov ah, 2       ; ah - функция вывода символа на экран
        int 21h
        pop ax
 
        neg ax
 
@@Conv:
        xor dx, dx
        div cx           ; в dl идёт остаток от деления на 10
        add dl, '0'     ; перевод в символьный формат
        inc di
        push dx              ; складываем в стек
        or ax, ax
        jnz @@Conv
        ; выводим из стека на экран
@@Show:
        pop dx              ; dl = очередной выводимый символ
        mov ah, 2       ; ah - функция вывода символа на экран
        int 21h
        dec di              ; повторяем пока di != 0
        jnz @@Show
 
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
Show_AX endp
 
; преобразования строки в знаковое число
;si - строка с числом
; di - адрес числа
; на выходе
; di - число
Str2Num proc
        push ax
        push bx
        push cx
        push dx
        push ds
        push es
        push si
 
        push ds
        pop es
 
        mov cl, ds:[si]
        xor ch, ch
 
        inc si
 
        cmp [si], byte ptr '-'
        jne @@IsPositive
        inc si
        dec cx
@@IsPositive:
        jcxz @@Error; если после '-' ничего не идет либо если нет вообще ничего
 
        mov bx, 10
        xor ax, ax
 
@@Loop:
        mul bx         ; умножаем ax на 10 ( dx:ax=ax*bx )
        mov [di], ax   ; игнорируем старшее слово
        cmp dx, 0      ; проверяем, результат на переполнение
        jnz @@Error
 
        mov al, [si]   ; Преобразуем следующий символ в число
        cmp al, '0'
        jb @@Error
        cmp al, '9'
        ja @@Error
        sub al, '0'
        xor ah, ah
        add ax, [di]
        jc @@Error    ; Если сумма больше 65535
        inc si
 
        loop @@Loop
 
        pop si
        push si
        or ax, ax
        js @@Error
        cmp [si+1], byte ptr '-'
        jne @@Positive
        neg ax
        or ax, ax
        jns  @@Error
@@Positive:
        mov  [di], ax
        clc
        pop  si
        pop  es
        pop  ds
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
@@Error:
        _terminate errorNumberMessage
        xor  ax, ax
        mov  [di], ax
        stc
        pop  si
        pop  es
        pop  ds
        pop  dx
        pop  cx
        pop  bx
        pop  ax
        ret
Str2Num endp
 
;Сортировка массива слов (word)
;cx - количество элементов в массиве
;dx - адрес массива слов
HoarSort       proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        ;HoarSort(array, 0, arraySize-1)
        mov     bx,     dx
        mov     si,     0
        mov     di,     cx
        dec     di
        shl     di,     1
        call    _HoarSort
 
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
HoarSort       endp
;  si    - адрес левой границы массива
;  di    - адрес правой границы массива
_HoarSort   proc                   
        push    ax             
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        
        cmp     si,     di   
        jae     @@StopQSort 
        push    di
        push    si
    
        mov     dx, di    
        mov     cx, si
        shr     si, 1
        shr     di, 1
        sub     di, si
        shr     di, 1
        add     si, di
        shl     si, 1
        mov     ax, [bx+si]
        mov     si, cx
        mov     di, dx
        @@DoWhile:     
                sub si, 2
                @@WhileLeft:
                        add si, 2
                        mov cx, [bx+si]
                        cmp ax, [bx+si]
                jg @@WhileLeft
            
                add di, 2
                @@WhileRight:
                        sub di, 2
                        mov cx, [bx+di]
                        cmp ax, [bx+di]
                jl      @@WhileRight
                                ;          
                cmp si, di
                ja  @@BreakDoWhile
                            
                mov cx, [bx+si]
                mov dx, [bx+di]
                mov [bx+si], dx
                mov [bx+di], cx  
 
                               
                add  si, 2
                               
                sub  di, 2
                               
                                
                cmp  si, di
                jbe  @@DoWhile
        @@BreakDoWhile:
                                
        mov cx, si
        pop si
        call  _HoarSort
                                 
        mov si, cx
        pop di
        call  _HoarSort
                                
@@StopQSort:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
_HoarSort   endp                    ;} 
;====================================
end     main