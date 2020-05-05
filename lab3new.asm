.model small
.stack 100h
.data
        flag                    db      0
        bracket1                db      'array[', '$'
        bracket2                db      ']=', '$'
        CrLf                    db      0Dh, 0Ah, '$'
        arraySize               equ     30
        array                   dw      arraySize dup (0)
 
        numberBuffer            db      7, 0, 7 dup(0)


        result                  db      0dh, 0ah, "Array median: $"
        emptyArrayError         db      0dh, 0ah, "Error: array is empty.$"
        errorNumberMessage      db      "Error: incorrect number.", 0dh, 0ah, '$'
 
.code
;=========================================
_end macro
        mov ah, 4ch
        int 21h
endm    
;=========================================
_print      macro str  
        ;push ax
        lea dx, str
        mov ah, 09h
        int 21h
        ;pop ax 
endm 
;=========================================
_input      macro str
      lea dx, str
      mov ah, 0ah
      int 21h 
endm 
;=========================================
;_error macro errorMessage
;        _print errorMessage
;endm
;========================================= 
main    proc       
        mov     ax,     @data
        mov     ds,     ax      
        
        mov     cx,     arraySize
        lea     dx,     [array]
        call    InputArray
        call    HoarSort
        call    ShowArray
        _print CrLf  
        call _findMedian   
        
        mov     ax, 4ch
        int     21h
main    endp
;=========================================  
InputArray      proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
 
        ;jcxz @@Exit;         ���� ������ ������ (cx = 0) - ���������
 
        mov si, 0;      ������ �������� �������
        mov di, dx;     ����� �������� �������� �������
        mov cx, arraySize
        @@ForI:
                _print bracket1
                mov ax, si
                call    Show_AX
                _print bracket2
                _input numberBuffer;    ���� �������� �������
                _print CrLf; '\n'
 
                push si
                lea si, numberBuffer+1; �������������� ������ � �����
                call Str2Num
                pop si
 
                
                jnc @@NoError;          �������� �� ������
                jmp @@ForI;             ���� ���� ������ ����� - ��������� ����
                @@NoError:
                ;                       ���������� ��������� ������ � �������
                ;mov [di], ax
                inc si;                 ������� � ���������� ��������
                add di, 2
        loop    @@ForI
@@Exit:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
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
        _end               
_findMedian     endp
;====================== 

ShowArray       proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
 
        jcxz @@Exit1 ;���� ������ ������ - ���������
 
        mov si, 1  ;������ �������� �������
        mov di, dx ;����� �������� �������� �������
        @@ForI2:
                mov ax, [di]
                call Show_AX
                mov ah, 02h
                mov dl, ' '
                int 21h
                ;������� � ���������� ��������
                inc si
                add di, 2
        loop    @@ForI2
@@Exit1:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
ShowArray       endp
 
; ax - ����� ��� �����������
Show_AX proc
        push ax
        push bx
        push cx
        push dx
        push di
 
        mov cx, 10
        xor di, di;     di - ���������� ���� � �����
 
        ; ���� ����� � ax �������������, �� ������ ����� � ������ ����� � ax �������������
        or ax, ax;      ���� < 0, �� � SF ��������� 1
        jns @@Conv;     ��������� SF
        push ax
        mov dx, '-'
        mov ah, 2;      ������� ������ ������� �� �����
        int 21h
        pop ax
 
        neg ax
 
@@Conv:
        xor dx, dx
        div cx;         � dl ��� ������� �� ������� �� 10
        add dl, '0';    ������� � ���������� ������
        inc di
        push dx;        ���������� � ����
        or ax, ax
        jnz @@Conv
        ; ������� �� ����� �� �����
@@Show:
        pop dx;         dl = ��������� ��������� ������
        mov ah, 2;      ah - ������� ������ ������� �� �����
        int 21h
        dec di;         ��������� ���� di != 0
        jnz @@Show
 
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
Show_AX endp

; si - �������������� ����� �������� ������ � ������ 
; di - ����� �����
; �������� ����� ��������� � di
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
        jcxz @@Error;   ���� ����� '-' ������ �� ���� ���� ���� ��� ������ ������
 
        mov bx, 10
        xor ax, ax
 
@@Loop:
        mul bx;         �������� ax �� 10 (������� ����� ������������ � dx)
        mov [di], ax;   ���������� ������� �����
        cmp dx, 0;      ��������� ��������� �� ������������
        jnz @@Error
 
        mov al, [si];   ����������� ��������� ������ � �����
        cmp al, '0'
        jb @@Error
        cmp al, '9'
        ja @@Error
        sub al, '0'
        xor ah, ah
        add ax, [di]
        jc @@Error;     ���� ����� ������ 65535
        inc si
        loop @@Loop
 
        pop si
        push si
        or ax, ax
        js @@Error;     ��������� SF (���� ���� ����)
        cmp [si+1], byte ptr '-'
        jne @@Positive
        neg ax
        or ax, ax
        jns  @@Error
@@Positive:
        mov  [di], ax
        clc;            ������� ����� ��������         
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        ret
@@Error:
        _print errorNumberMessage
        xor ax, ax
        mov [di], ax
        stc
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        ret
Str2Num endp
 
;cx - ���������� ��������� � �������
;dx - ����� ������� ����
HoarSort       proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        ;HoarSort(array, 0, arraySize-1)
        mov bx, dx
        mov si, 0
        mov di, cx
        dec di
        shl di, 1
        call _HoarSort
 
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
HoarSort       endp
;  si    - ����� ����� ������� �������
;  di    - ����� ������ ������� �������
; (��������� �������� � ����������� di)
_HoarSort   proc                   
        push ax             
        push bx
        push cx
        push dx
        push si
        push di
        
        cmp si, di   
        jae @@StopHoarSort;     ���� >= 
        push di
        push si
        ;               int middle = (left + right) / 2 - ����� �� 2, �.�. � ����� 2 �����;
        mov dx, di    
        mov cx, si
        shr si, 1
        shr di, 1
        sub di, si;             ������� ���������� ����� ���������� �������� ������� (����� ���������� ����� �������)
        shr di, 1;              ����� ��� ���, ����� ����� ���������� �������� ���������� ����� �������
        add si, di;             ���������� �� ����������� ����� �������� �������� ���������� ����� 
        shl si, 1 ; * 2
        mov ax, [bx+si];        ��������� ��������� �������� �������� �������� ���������� �����
        mov si, cx;             ����� �������
        mov di, dx;             ������ �������
        @@DoWhile:     
                sub si, 2;      ��������, ����� �������� ������� ����������
                @@WhileLeft:;   ���� ������ �������, ������� ����� ������ ��������
                        add si, 2;��������� ��������
                        mov cx, [bx+si]; 
                        cmp ax, cx 
                        jg @@WhileLeft; ���������� ����, ���� ax > cx
            
                add di, 2 
                @@WhileRight:;  ���� ������ �������, ������� ����� ������ ��������
                        sub di, 2
                        mov cx, [bx+di]
                        cmp ax, [bx+di]
                        jl @@WhileRight; ���������� ���� ���� ax < cx
                                   
                cmp si, di;     ���� �� ����� ������ ���������, ������ ���� ������� ������������
                ja  @@BreakDoWhile
                            
                mov cx, [bx+si];������ ������� ��������� ��������
                mov dx, [bx+di]
                mov [bx+si], dx
                mov [bx+di], cx  
 
                               
                add  si, 2
                cmp  di, 0
                je   Mark1;     �������� �������������� �������� ������� ������� ����� ������              
                sub  di, 2;     ����� ���������� ������������ ��� ������� DI � ����������� ������������;
                               
                Mark1:    
                cmp  si, di
                jbe  @@DoWhile; ���� ������� ���������� ���� �� �����, �� ���������� ���������� (���� ���� ��� �����)
        @@BreakDoWhile:
                                
        mov cx, si
        pop si
        call  _HoarSort
                                 
        mov si, cx
        pop di
        call  _HoarSort
                                
@@StopHoarSort:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
_HoarSort   endp                    
end     main