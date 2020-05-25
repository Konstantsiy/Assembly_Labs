.286
.model small
.stack 100h

.data
        bufferSize equ 126
        buffer db bufferSize dup('$')
        bufferLast dw 0  

        sizeWordBuffer equ 50
        wordBuffer db sizeWordBuffer + 1 dup('$')
        lastWordBuffer dw 0

        fileName db 126 dup(0)
        
        numberBuffer db 10 dup(0)

        wordNumber dw 0
        wordCounter dw 0

        fd dw 0
        readPointer dd 0
        writePointer dd 0
        base dw 10

        openingFileError        db    0dh, 0ah, "Error opening file.", 0dh, 0ah, '$'
        incorrectArgumentsError db    0dh, 0ah, "Error: incorrect cmd arguments.", 0dh, 0ah,"You need to set path and number of word to delate.", 0dh, 0ah, '$'
        incorrectNumberError    db    0dh, 0ah, 'Error: you need to enter a positive integer number.', 0dh, 0ah, '$'
        successMessage          db    0dh, 0ah, "Success!", 0dh, 0ah, '$'
        goodPathValidation      db    0dh, 0ah, "File path checked successfully.", 0dh, 0ah, '$'
        emptyCmdError           db    0dh, 0ah, "Error: command line is empty.", 0dh, 0ah, '$'
        emptyFilePathError      db    0dh, 0ah, "Error: file path is empty.", 0dh, 0ah, '$' 
        isNUL                   db    0dh, 0ah, "NUL detected.", 0dh, 0ah, '$'
        
.code
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
_end macro
        mov ah, 4ch
        int 21h
endm
;========================================
main:
mov ax, @data
mov ds, ax

mov bl, es:[80h]; äëèíà êîì ñòðîêè
add bx, 80h; ïîñëåäíèé ñèìâîë êîì ñòðîêè
mov si, 82h; íà÷àëî êîì ñòðîêè
mov di, offset fileName

cmp si, bx
ja emptyCmd 

parse_path:
        cmp byte ptr es:[si], ' '
        je parsed_path

        mov al, es:[si]; ïîìåùàåì èìÿ ôàéëà èç êîìàíäíîé ñòðîêè â ïåðåìåííóþ fileName
        mov [di], al

        inc di
        inc si
        cmp si, bx 
        jbe parse_path; ïðîäîëæàåì ïàðñèíã, ïîêà ìû íå äîøëè äî êîíöà êîì ñòðîêè (<=)

parsed_path:
        mov di, offset numberBuffer
        inc si
        cmp si, bx; åñëè íà÷àëî < êîíöà êñ
        ja incorrectArguments
            
parse_number:
        cmp byte ptr es:[si], ' ' ; ïðîâåðÿåì, íå ïðîáåë ëè
        je parsed_number
        mov al, es:[si] ; ïîìåùàåì èç êîìàíäíîé ñòðîêè äàííûå â numberBuffer
        mov [di], al

        inc di
        inc si
        inc cx
        cmp si, bx; åñëè âñ¸ õîðîøî, òî ïðîäîëæàåì ðàáîòàòü
        jbe parse_number

parsed_number:
        push 0
        mov di, offset numberBuffer
        push di
        mov di, offset wordNumber 
        push di
        call atoi
        pop ax
        pop ax
        pop ax; â ax ôëàã îøèáêè

        cmp ax, 1
        je incorrectNumber

        cmp wordNumber, 1; åñëè ÷èñëî <= 0
        jl incorrectNumber 
        _print goodPathValidation
        call process_file
        _print successMessage

exit: 
        _end

emptyCmd:
        _print emptyCmdError
        _end

errorOpening:
        _print openingFileError 
        _end 

incorrectArguments:
        _print incorrectArgumentsError 
        _end

incorrectNumber:
        _print incorrectNumberError
        _end   
;==============================================================
;==============================================================
process_file: 
        mov dx, offset fileName
        mov ah, 3Dh
        mov al, 02h ;ðåæèì äîñòóïà
        int 21h
        mov fd, ax ;â ax - êîä îøèáêè èëè äåñêðèïòîð ôàéëà, åñëè âñ¸ õîðîøî

        jnc read_file_buffer ; ïåðåõîä, åñëè ïåðåíîñ íå óñòàíîâëåí (ÅÑËÈ ÏÐÎÈÇÎØËÀ ÎØÈÁÊÀ, CX = 1)
        jmp errorOpening

read_file_buffer:
;--------------------------------------------- 
        mov ah, 42h ; ïåðåìåñòèòü óêàçàòåëü ÷òåíèÿ-çàïèñè
        mov cx, word ptr [offset readPointer] ; cx:dx- ðàññòîÿíèå, íà êîòîðîå íàäî ïåðåìåñòèòü óêàçàòåëü
        mov dx, word ptr [offset readPointer + 2]
        mov al, 0 ; ïåðåìåùåíèå îòíîñèòåëüíî íà÷àëà ôàéëà
        mov bx, fd
        int 21h ; ïåðåìåùàåì óêàçàòåëü ôàéëà â íà÷àëî
;--------------------------------------------- 
        mov cx, bufferSize ; ÷èñëî áàéò äëÿ ÷òåíèÿ
        mov dx, offset buffer ; àäðåñ áóôåðà äëÿ ïðèåìà äàííûõ
        mov ah, 3Fh ; ÷òåíèå èç ôàéëà èëè óñòðîéñòâà
        mov bx, fd
        int 21h ; ÷èòàåì èç ôàéëà 
;---------------------------------------------
        jc close_file ;åñëè ôëàã CF áûë ïîäíÿò, òî îøèáêà
        cmp ax, 0
        je close_file
                                                                         
        mov cx, word ptr [offset readPointer] ; åñëè ôàéë íå ïóñòîé èëè ìû ÷òî-òî ñìîãëè ïðî÷èòàòü, òî çàïîìèíàåì ïîçèöèþ
        mov dx, word ptr [offset readPointer + 2]
 
        add dx, ax; äîáàâëÿåì ê ñìåùåíèþ ÷èñëî ñ÷èòàííûõ áàéò
        adc cx, 0 ; ñëîæåíèå ñ ïåðåíîñîì
        mov word ptr [offset readPointer], cx ;íîâîå ñìåùåíèå ÷òåíèÿ-çàïèñè
        mov word ptr [offset readPointer + 2], dx

        mov bufferLast, ax; ïîìåùàåì ÷èñëî ñ÷èòàííûõ áàéò
        call process_buffer ; îáðàáîòêà áóôåðà ñ÷èòàííûõ äàííûõ
        jmp read_file_buffer
        

close_file:
        ; ïðîâåðÿåì áóôåð
        call check_word
        mov ah, 40h ;çàïèñü â ôàéë
        mov cx, 0 ;êîë-âî áàéò äëÿ çàïèñè
        mov bx, fd ;èäåíòèôèêàòîð ôàéëà
        mov dx, offset wordBuffer ;àäðåñ áóôåðà ñ äàííûìè
        int 21h
        close:
        mov ah, 3Eh ;ôóíêöèÿ çàêðûòèÿ ôàéëà
        mov bx, fd ;ôàéëîâûé äåñêðèïòîð
        int 21h
ret
;==============================================================
;==============================================================
process_buffer: ; îáðàáîòêà áóôåðà ñî ñ÷èòàííûìè äàííûìè
        pusha
        xor si, si
        process_buffer_loop:
                mov al, [buffer + si] ; â al î÷åðåäíîé ñèìâîë áóôåðà
                mov di, lastWordBuffer ; ïîñëåäíåå ñëîâî
                mov [wordBuffer + di], al ; ïîìåùàåì â íîâûé áóôåð ñèìâîë ñòðîêè
                inc di
                mov lastWordBuffer, di ; çàïîìèíàåì ñèìâîë, ÷òîáû ïîäîáðàòüñÿ ê ïîñëåäíåìó ñèìâîëó

                call check_border
                cmp bx, 1
                jne process_buffer_loop_end

                call check_word

                cmp al, 13
                jne process_buffer_loop_end
                mov wordCounter, 0

        process_buffer_loop_end:
        inc si
        cmp si, bufferLast; ñðàâíèâàåì ñ ÷èñëîì ñ÷èòàííûõ áàéò
        jb process_buffer_loop; åñëè íå äîøëè äî êîíöà ñòðîêè òî ïðîäîëæàåì
        popa
ret
;==============================================================
;==============================================================
check_border:; ñèìâîë â al
        mov bx, 1

        cmp al, ' '
        je check_border_exit

        cmp al, 13 ;/n
        je check_border_exit

        cmp al, '.'
        je check_border_exit 
        
        cmp al, '!'
        je check_border_exit
        
        cmp al, '?'
        je check_border_exit

        cmp al, ','
        je check_border_exit
        
        cmp al, 10
        je check_border_exit

        mov bx, 0

        check_border_exit:
ret
;==============================================================
;==============================================================
check_word:
        mov bx, lastWordBuffer
        dec bx ;ñòàíîâèìñÿ íà ïîñëåäíèé ñèìâîë ñëîâà
        cmp bx, 0; åñëè íèæå èëè ðàâíî
        jbe check_word_end

        mov bx, wordCounter; c÷¸ò÷èê ñëîâ
        inc bx
        mov wordCounter, bx ; óâåëè÷èëè ñ÷åò÷èê ñëîâ  

        cmp bx, wordNumber ; íîìåð ñëîâà, êîòîðîå íàäî óäàëèòü èç ñòðîêè
        jne check_word_end ; åñëè ñ÷¸ò÷èê ñëîâà íå ðàâåí íîìåðó ñëîâà â ñòðîêå, òî âûõîäèì  
        
        ;---------- îáíóëåíèå ñ÷¸ò÷èêà, ÷òîáû óäàëÿëîñü êàæäîå N-å ñëîâî â ñòðîêå       
        push bx
        mov bx, 0
        mov wordCounter, bx
        pop bx
        ;----------

        mov di, lastWordBuffer ; èíäåêñ ïîñëå ïîñëåäíåãî ñèìâîëà ñëîâà 
        
        ;---------- ïðîâåðêà íà NUL â êîíöå ôàéëà
        cmp di, 00h    
        je check_word_end
        ;----------     
        
        dec di ; èíäåêñ ïîñëåäíåãî ñèìâîëà ñëîâà
        mov bl, [wordBuffer + di] ; ïåðåìåùàåì ñèìâîë ïî ýòîìó èíäåêñó â íà÷àëî wordb
        mov [wordBuffer], bl
        mov lastWordBuffer, 1

        check_word_end:
        call print_to_file
ret
;==============================================================
;==============================================================
print_to_file:; çàïèñàòü â ôàéë è î÷èñòèòü ñëîâî
        pusha
;-----------------------------------------------
        mov ah, 42h ; ïåðåìåñòèòü óêàçàòåëü ÷òåíèÿ-çàïèñè
        mov cx, word ptr [offset writePointer] ; ñìåùåíèå
        mov dx, word ptr [offset writePointer + 2]
        mov al, 0 ;îò íà÷àëà ôàéëà
        mov bx, fd ; äåñêðèïòîð
        int 21h
;-----------------------------------------------
        mov ah, 40h ;çàïèñü â ôàéë èëè óñòðîéñòâî
        mov cx, lastWordBuffer; ÷èñëî áàéòîâ äëÿ çàïèñè
        mov bx, fd; äåñêðèïòîð
        mov dx, offset wordBuffer ;àäðåñ áóôôåðà ñ äàííûìè
        int 21h
;-----------------------------------------------
        mov ax, lastWordBuffer ; ïåðåíîñ óêàçàòåëÿ ÷òåíèÿ-çàïèñè
        mov cx, word ptr [offset writePointer]
        mov dx, word ptr [offset writePointer + 2]
        add dx, ax
        adc cx, 0
        mov word ptr [offset writePointer], cx
        mov word ptr [offset writePointer + 2], dx

        mov lastWordBuffer, 0
        popa
ret
;==============================================================
;==============================================================
atoi:
        push bp
        mov bp, sp
        pusha
        
        mov di, [ss:bp+4+2]

        xor bx, bx
        xor ax, ax
        xor cx, cx
        xor dx, dx

        cmp byte ptr [di + bx], '-'
        jne atoi_loop

        inc cx; óñòàíîâèòü ôëàã îòðèöàòåëüíîãî ÷èñëà
        inc bx
        jmp atoi_result

        ;ïàðñèòü äî îøèáêè
        atoi_loop:

        cmp byte ptr [di + bx], '0' 
        jb atoi_error; åñëè íèæå
        cmp byte ptr [di + bx], '9'
        ja atoi_error; åñëè âûøå

        mul base; óìíîæàåì íà 10
        mov dh, 0
        mov dl, [di + bx]
        sub dl, '0'
        add ax, dx; äîáàâëÿåì ê îñíîâíîìó ÷èñëó
        jo atoi_error; åñëè åñòü ïåðåïîëíåíèå

        inc bx
        cmp byte ptr [di + bx], 0; åñëè ïåðåïîëíåíèÿ íå áûëî è ñòðîêà íå çàêîí÷èëàñü, òî ïðîäîëæàåì, ïîêà íå êîíåö
        jne atoi_loop

        jmp atoi_result

        atoi_error:; îøèáêà, âûõîä è ïðîöåäóðû
        mov byte ptr [ss:bp+4+4], 1
        jmp atoi_end

        atoi_result:
        mov byte ptr [ss:bp+4+4], 0 ;áåç îøèáîê
        cmp cx, 1 ;ïðîâåðÿåì, áûë ëè ìèíóñ ïåðåä ÷èñëîì
        jne atoi_end ;åñëè íåò, òî çàâåðøàåì ïðîãðàììó
        neg ax ; åñëè áûë, òî ìåíÿåì çíàê íà ïðîòèâîïîëîæíûé

        atoi_end:
        mov di, [ss:bp+4+0]
        mov [di], ax ;ïîìåùàåì ÷èñëî ïî çàäàííîìó àäðåñó

        popa ;çàâåðøàåì ïðîöåäóðó
        pop bp
ret
;==============================================================
end main
