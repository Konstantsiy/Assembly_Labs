.286
.model small
.stack 100h

.data
        bufferSize equ 256
        buffer db bufferSize dup('$')
        bufferLast dw 0; последний символ ком строки

        sizeWordBuffer equ 50
        wordBuffer db sizeWordBuffer + 1 dup('$')
        lastWordBuffer dw 0

        fileName db 256 dup(0)
        numberBuffer db 256 dup(0)

        wordNumber dw 0
        wordCounter dw 0

        fd dw 0
        readPointer dd 0
        writePointer dd 0
        base dw 10

        openingFileError        db    0dh, 0ah, "Error opening file.", 0dh, 0ah, '$'
        incorrectArgumentsError db    0dh, 0ah, "Error: incorrect cmd arguments.", 0dh, 0ah,"You need to set path and number of word to delate.", 0dh, 0ah, '$'
        incorrectNumberError    db    0dh, 0ah, 'Error: incorrect number.', 0dh, 0ah, '$'
        successMessage          db    0dh, 0ah, "Success!", 0dh, 0ah, '$'
        goodPathValidation      db    0dh, 0ah, "File path checked successfully.", 0dh, 0ah, '$'
        emptyCmdError           db    0dh, 0ah, "Error: command line is empty.", 0dh, 0ah, '$'
        negativeNumberError     db    0dh, 0ah, "Error: the number must not be negative.", 0dh, 0ah, '$'
        emptyFilePathError      db    0dh, 0ah, "Error: file path is empty.", 0dh, 0ah, '$'
        
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

mov bl, es:[80h]; длина ком строки
add bx, 80h; последний символ ком строки
mov si, 82h; начао ком строки
mov di, offset fileName

cmp si, bx
ja emptyCmd 

parse_path:

cmp byte ptr es:[si], ' '
je parsed_path

mov al, es:[si]; помещаем имя файла из командной строки в переменную fileName
mov [di], al

inc di
inc si
cmp si, bx 
jbe parse_path; продолжаем парсинг, пока мы не дошли до конца ком строки

parsed_path:
mov di, offset numberBuffer
inc si
cmp si, bx; если начало < конца кс
ja bad_arguments ;если неверные аргументы, то переходим по меке bad_arguments
;если нет, то продолжаем работать с введёнными в кс параметрами

parse_number:
cmp byte ptr es:[si], ' ' ; проверяем, не пробел ли
je parsed_number
mov al, es:[si] ; помещаем из командной строки данные в bufNumber
mov [di], al

inc di
inc si
inc cx
cmp si, bx; если всё хорошо, то продолжаем работать
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
pop ax; error

cmp ax, 1; если ошибка
je bad_number

cmp wordNumber, 0; если число отрицательное
jl negativeNumber
_print goodPathValidation
call process_file 
_print successMessage
;mov ax, offset successMessage;смещение строки done_msg
;push ax ; сохраняем значение в стеке
;call print_str ; функция вывода сообщения
;pop ax ;достаём из стека ax

exit: 
        _end

emptyCmd:
        _print emptyCmdError
        _end
        
negativeNumber:
        _print negativeNumberError
        _end

bad_file:
        _print openingFileError 
        _end 

bad_arguments:
        _print incorrectArgumentsError 
        _end

bad_number:
        _print incorrectNumberError
        _end
;==============================================================
;==============================================================
process_file:
;открыть существующий файл
mov dx, offset fileName; адрес строки с полным именем файла
mov ah, 3Dh
mov al, 02h ;режим доступа(и для чтениия, и для записи)
int 21h ; открываем файл
mov fd, ax ;в ax-код ошибки или дескриптор файла если всё хорошо
;---------------------------------------------
mov bx, ax  ;помещаем код ошибки в bx
jnc read_file_buffer ; переход, если перенос не установлен (ЕСЛИ ПРОИЗОШЛА ОШИБКА, CX = 1)
jmp bad_file; если ошибка произошла и перенос установлен, то файл не открыт, переходим по метке и сообщаем об этом

read_file_buffer:
;--------------------------------------------- ПЕРЕМЕЩЕНИЕ УКАЗАТЕЛЯ ФАЙЛА
mov ah, 42h ; переместить указатель чтения-записи (на первой итерации в начало файла)
mov cx, word ptr [offset readPointer] ; cx:dx- расстояние, на которое надо переместить указатель (знаковое число)
mov dx, word ptr [offset readPointer + 2]
mov al, 0 ; перемещение относительно начала файла
mov bx, fd ;файловый дескрипрор
int 21h ; перемещаем указатель файла в начало
;--------------------------------------------- СЧИТЫВАЕМ БУФЕР ИЗ ФАЙЛА
mov cx, bufferSize ; число байт для чтения
mov dx, offset buffer ; адрес буфера для приема данных
mov ah, 3Fh ; чтение из файла или устройства
mov bx, fd ; идентификатор файла
int 21h ; читаем из файла 
;---------------------------------------------
jc close_file ;если флаг CF был поднят, то ошибка
;если операция выполнена успешно, то в ax число считанных байт
cmp ax, 0 ;сравниваем с 0 cимволом
je close_file ;если файл пуст, то переходим по метке close_file и закрываем его
                                                                         
mov cx, word ptr [offset readPointer] ; если файл не пустой или мы что-то смогли прочитать то запоминаем позицию
mov dx, word ptr [offset readPointer + 2]
 
add dx, ax; добавляем к смещению число считанных байт
adc cx, 0 ; сложение с переносом
mov word ptr [offset readPointer], cx ;новое смещение чтения-записи
mov word ptr [offset readPointer + 2], dx

mov bufferLast, ax; помещаем число считанных байт
call process_buffer ; обработка блока считанных данных

jmp read_file_buffer

close_file:
;check word buffer
call check_word

mov ah, 40h ;запись в файл
mov cx, 0 ;кол-во байт для записи
mov bx, fd ;идентификатор файла
mov dx, offset wordBuffer ;адрес буффера с данными
int 21h

mov ah, 3Eh ;функция закрытия файла
mov bx, fd ;файловый дескриптор
int 21h
ret
;==============================================================
;==============================================================
process_buffer: ; обработка буфера со считанными данными
pusha
xor si, si

process_buffer_loop:

mov al, [buffer + si] ; в al очередной символ буфера

mov di, lastWordBuffer ; последнее слово
mov [wordBuffer + di], al ; помещаем в новый буффер символ строки
inc di
mov lastWordBuffer, di ; запоминаем символ, чтобы подобраться к последнему символу

call check_border ;сравниваем, не конец ли строки или не пробел ли
cmp bx, 1 ;если что-то из вышеперечисленного
jne process_buffer_loop_end ;если ничего из этого

call check_word

cmp al, 13
jne process_buffer_loop_end
mov wordCounter, 0

process_buffer_loop_end:
inc si
cmp si, bufferLast; сравниваем с числом считанных байт
jb process_buffer_loop; если не дошли до конца строки то продолжаем

popa
ret
;==============================================================
;==============================================================
check_border:
;al - char
mov bx, 1;separator flag

cmp al, ' '
je check_border_exit

cmp al, 13 ;/n
je check_border_exit

cmp al, '.'
je check_border_exit

cmp al, ','
je check_border_exit

cmp al, 10;/r
je check_border_exit

mov bx, 0

check_border_exit:
ret
;==============================================================
;==============================================================
check_word:
mov bx, lastWordBuffer
dec bx ;становимся на последний символ слова
cmp bx, 0; если ниже или равно (CF = 1 или ZF = 1)
jbe check_word_end

mov bx, wordCounter; cчётчик слов
inc bx
mov wordCounter, bx ; увеличили счетчик слов  

cmp bx, wordNumber ;номер слова, которое надо удалить из строки
jne check_word_end ; если счётчик слова не равен номеру слова в строке, то завершаем проц

mov di, lastWordBuffer ;индекс после последнего символа слова
dec di ;индекс последнего символа слова
mov bl, [wordBuffer + di] ;перемещаем символ по этому индексу в начало wordb
mov [wordBuffer], bl
mov lastWordBuffer, 1

check_word_end:
call print_to_file
ret
;==============================================================
;==============================================================
print_to_file:
;записать в файл и очистить слово
pusha
;-----------------------------------------------
mov ah, 42h ; переместить указатель чтения-записи
mov cx, word ptr [offset writePointer] ; смещение
mov dx, word ptr [offset writePointer + 2]
mov al, 0 ;от начала файла
mov bx, fd ; дескриптор
int 21h
;-----------------------------------------------
mov ah, 40h ;запись в файл или устройство
mov cx, lastWordBuffer; число байтов для записи
mov bx, fd; дескриптор
mov dx, offset wordBuffer ;адрес буффера с данными
int 21h
;-----------------------------------------------
mov ax, lastWordBuffer ; перенос указателя чтения-записи
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
;first - result code, second - string start, third - 16-bit number address
atoi:
push bp
mov bp, sp
pusha

;[ss:bp+4+0] - адрес числа
;[ss:bp+4+2] - адрес строки
;[ss:bp+4+4] - ошибка, если 1
mov di, [ss:bp+4+2]

xor bx, bx
xor ax, ax
xor cx, cx
xor dx, dx

cmp byte ptr [di + bx], '-'
jne atoi_loop

inc cx; set negative after loop
inc bx

;парсить до ошибки
atoi_loop:

cmp byte ptr [di + bx], '0' ;проверка на то, является ли числом вводимое значение
jb atoi_error; если ниже
cmp byte ptr [di + bx], '9'
ja atoi_error; если выше

mul base ;умножаем на 10
mov dh, 0
mov dl, [di + bx]
sub dl, '0' ;преващаем в число, отнимая ascii код 0
add ax, dx ;добавляем к основному числу
jo atoi_error ;если был поднят флаг переполнения, то выводим ошибку

inc bx
cmp byte ptr [di + bx], 0 ;если переполнения не было и строка не закончилась, то продолжаем, пока не конец
jne atoi_loop

jmp atoi_result

atoi_error: ;ошибка, выход и процедуры
mov byte ptr [ss:bp+4+4], 1
jmp atoi_end

atoi_result:
mov byte ptr [ss:bp+4+4], 0 ;без ошибок
cmp cx, 1 ;проверяем, был ли минус перед числом
jne atoi_end ;если нет, то завершаем программу
neg ax ; если нет, то меняем знак на противоположный

atoi_end:
mov di, [ss:bp+4+0]
mov [di], ax ;помещаем число по заданному адресу

popa ;завершаем процедуру
pop bp
ret
;==============================================================
;==============================================================
end main
