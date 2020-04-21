.model small
 
.stack 100h
 
.data
        mes                 db      0Dh, 0Ah, 'element: $'
        flag                db      0
        bracket1            db      'array[', '$'
        bracket2            db      ']=', '$'
        CrLf                db      0Dh, 0Ah, '$'
        arraySize           equ     30  
        array               dw     arraySize dup (0)
 
        numberBuffer        db      7, 0, 7 dup(0)


        result              db      0dh, 0ah, "Array median: $"
        emptyArrayError     db      0dh, 0ah, "Error: array is empty.$"
        errorNumberMessage  db  "Error: incorrect number.", 0dh, 0ah, '$'
 
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
        ;ââîä ìàñèâà
        mov     cx,     arraySize
        lea     dx,     [array]
        call    InputArray
        ;ñîðòèðîâêà ìàññèâà 
        call    HoarSort
        ;âûâîä ìàññèâà
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
 
        jcxz    @@Exit          ;åñëè ìàññèâ ïóñòîé - çàâåðøèòü
 
        mov     si,     1       ;èíäåêñ ýëåìåíòà ìàññèâà
        mov     di,     dx      ;àäðåñ òåêóùåãî ýëåìåíòà ìàññèâà
        mov cx, arraySize
        @@ForI:
                ;âûâîä ïðèãëàøåíèÿ ââîäà ýëåìåíòà
                _print bracket1
                mov     ax,     si
                call    Show_AX
                _print bracket2
                ;ââîä ÷èñëà
                _input numberBuffer; ââîä ýëåìåíòà ìàññèâà
                _print CrLf; '\n'
 
                push    si
                lea     si, numberBuffer+1 ; ïðåîáðàçîâàíèå ñòðîêè â ÷èñëî
                ;lea     di, Numer
                call    Str2Num
                pop     si
 
                ; ïðîâåðêà íà îøèáêó
                jnc     @@NoError
 
                ; åñëè åñòü îøèáêà ââîäà - ïîâòîðèòü ââîä
                jmp     @@ForI
 
                ; åñëè íåò îøèáêè ââîäà - ñîõðàíèòü ÷èñëî
                @@NoError:
                ;ñîõðàíåíèå ââåä¸ííîãî ÷èñëîà â ìàññèâå
                ;mov    [di],   ax
                ;ïåðåõîä ê ñëåäóþùåìó ýëåìåíòó
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
 
        jcxz    @@Exit1          ;åñëè ìàññèâ ïóñòîé - çàâåðøèòü
 
        mov     si,     1       ;èíäåêñ ýëåìåíòà ìàññèâà
        mov     di,     dx      ;àäðåñ òåêóùåãî ýëåìåíòà ìàññèâà
        @@ForI2:
                mov     ax,     [di]
                call    Show_AX
                mov     ah,     02h
                mov     dl,     ' '
                int     21h
                ;ïåðåõîä ê ñëåäóþùåìó ýëåìåíòó
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
 
; âûâîäèò çíàêîâîå 16-ðàçðÿäíîå ÷èñëî èç ðåãèñòðà AX íà ýêðàí
; âõîäíûå äàííûå:
; ax - ÷èñëî äëÿ îòîáðàæåíèÿ
Show_AX proc
        push ax
        push bx
        push cx
        push dx
        push di
 
        mov cx, 10
        xor di, di      ; di - êîë. öèôð â ÷èñëå
 
        ; åñëè ÷èñëî â ax îòðèöàòåëüíîå, òî
        ;1) íàïå÷àòàòü '-'
        ;2) ñäåëàòü ax ïîëîæèòåëüíûì
        or ax, ax
        jns @@Conv
        push ax
        mov dx, '-'
        mov ah, 2       ; ah - ôóíêöèÿ âûâîäà ñèìâîëà íà ýêðàí
        int 21h
        pop ax
 
        neg ax
 
@@Conv:
        xor dx, dx
        div cx           ; â dl èä¸ò îñòàòîê îò äåëåíèÿ íà 10
        add dl, '0'     ; ïåðåâîä â ñèìâîëüíûé ôîðìàò
        inc di
        push dx              ; ñêëàäûâàåì â ñòåê
        or ax, ax
        jnz @@Conv
        ; âûâîäèì èç ñòåêà íà ýêðàí
@@Show:
        pop dx              ; dl = î÷åðåäíîé âûâîäèìûé ñèìâîë
        mov ah, 2       ; ah - ôóíêöèÿ âûâîäà ñèìâîëà íà ýêðàí
        int 21h
        dec di              ; ïîâòîðÿåì ïîêà di != 0
        jnz @@Show
 
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
Show_AX endp
 
; ïðåîáðàçîâàíèÿ ñòðîêè â çíàêîâîå ÷èñëî
;si - ñòðîêà ñ ÷èñëîì
; di - àäðåñ ÷èñëà
; íà âûõîäå
; di - ÷èñëî
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
        jcxz @@Error; åñëè ïîñëå '-' íè÷åãî íå èäåò ëèáî åñëè íåò âîîáùå íè÷åãî
 
        mov bx, 10
        xor ax, ax
 
@@Loop:
        mul bx         ; óìíîæàåì ax íà 10 ( dx:ax=ax*bx )
        mov [di], ax   ; èãíîðèðóåì ñòàðøåå ñëîâî
        cmp dx, 0      ; ïðîâåðÿåì, ðåçóëüòàò íà ïåðåïîëíåíèå
        jnz @@Error
 
        mov al, [si]   ; Ïðåîáðàçóåì ñëåäóþùèé ñèìâîë â ÷èñëî
        cmp al, '0'
        jb @@Error
        cmp al, '9'
        ja @@Error
        sub al, '0'
        xor ah, ah
        add ax, [di]
        jc @@Error    ; Åñëè ñóììà áîëüøå 65535
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
 
;Ñîðòèðîâêà ìàññèâà ñëîâ (word)
;cx - êîëè÷åñòâî ýëåìåíòîâ â ìàññèâå
;dx - àäðåñ ìàññèâà ñëîâ
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
;  si    - àäðåñ ëåâîé ãðàíèöû ìàññèâà
;  di    - àäðåñ ïðàâîé ãðàíèöû ìàññèâà
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
