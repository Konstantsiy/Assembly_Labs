.286
.model small
.stack 100h

.data
bufferSize equ 256; ������ ��� ������
buffer db bufferSize dup('$'); ���� ��� ������
bufferLast dw 0; ��������� ������ ��� ������

sizeWordBuffer equ 50; ����������� ��������� ������ �����
wordBuffer db sizeWordBuffer + 1 dup('$')
lastWordBuffer dw 0

fileName db 256 dup(0); ��� �����
numberBuffer db 256 dup(0); ����� �� �����

wordNumber dw 0
wordCounter dw 0

fd dw 0
readPointer dd 0
writePointer dd 0
base dw 10

errorFileMessage db 'File is not open$'
errorArgsMessage db 'Wrong arguments', 10, 13, 'Input: file.txt and word number$'
errorNumMessage db 'Word number should [0, 32767]$'
successMessage db 'All done! All ok!$'
endl db 10, 13, '$'
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
mov ax, @data ; �������� �������� ������
mov ds, ax

mov bl, es:[80h]; ��������� ����� ��� ������
add bx, 80h; ������������ �� ��������� ������ ��� ������ (��� �������� �� ������� ��� ������, ����� ��������)
mov si, 82h; si - ����� ��� ������
mov di, offset fileName; �������� ����� �����

cmp si, bx ;���� ������ < ����� ��
ja bad_arguments ;���� �������� ���������, �� ��������� �� ���� bad_arguments
;���� ���, �� ���������� �������� � ��������� � �� �����������
parse_path:

cmp byte ptr es:[si], ' ' ; ���������, �� ������ ��
je parsed_path

mov al, es:[si] ;�������� �� ��������� ������ ��� ����� � ���������� fileName
mov [di], al

inc di
inc si
cmp si, bx ;���� �� ������, �� ���������� ��������
jbe parse_path ; ���������� �������, ���� �� �� ����� �� ����� ��� ������

parsed_path:
mov di, offset numberBuffer
inc si
cmp si, bx; ���� ������ < ����� ��
ja bad_arguments ;���� �������� ���������, �� ��������� �� ���� bad_arguments
;���� ���, �� ���������� �������� � ��������� � �� �����������

parse_number:
cmp byte ptr es:[si], ' ' ; ���������, �� ������ ��
je parsed_number
mov al, es:[si] ; �������� �� ��������� ������ ������ � bufNumber
mov [di], al

inc di
inc si
inc cx
cmp si, bx; ���� �� ������, �� ���������� ��������
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
pop ax;error

cmp ax, 1 ;���� ������
je bad_number

cmp wordNumber, 0; ���� ����� �������������
jl bad_number

call process_file 

mov ax, offset successMessage;�������� ������ done_msg
push ax ; ��������� �������� � �����
call print_str ; ������� ������ ���������
pop ax ;������ �� ����� ax

exit: ;����� �� ���������
      _end

bad_file:
mov ax, offset errorFileMessage ;�������� ������ errorFileMessage
push ax ; ��������� �������� � �����
call print_str ; ������� ������ ���������
pop ax ;������ �� ����� ax
jmp exit ;��������� ���������

bad_arguments:
mov ax, offset errorArgsMessage 
push ax 
call print_str ; ������� ������ ���������
pop ax 
jmp exit ;��������� ���������

bad_number:
mov ax, offset errorNumMessage
push ax 
call print_str ; ������� ������ ���������
pop ax 
jmp exit ; ��������� ���������
;==============================================================
;==============================================================
process_file:
;������� ������������ ����
mov dx, offset fileName; ����� ������ � ������ ������ �����
mov ah, 3Dh
mov al, 02h ;����� �������(� ��� �������, � ��� ������)
int 21h ; ��������� ����
mov fd, ax ;� ax-��� ������ ��� ���������� ����� ���� �� ������
;---------------------------------------------
mov bx, ax  ;�������� ��� ������ � bx
jnc read_file_buffer ; �������, ���� ������� �� ���������� (���� ��������� ������, CX = 1)
jmp bad_file; ���� ������ ��������� � ������� ����������, �� ���� �� ������, ��������� �� ����� � �������� �� ����

read_file_buffer:
;--------------------------------------------- ����������� ��������� �����
mov ah, 42h ; ����������� ��������� ������-������ (�� ������ �������� � ������ �����)
mov cx, word ptr [offset readPointer] ; cx:dx- ����������, �� ������� ���� ����������� ��������� (�������� �����)
mov dx, word ptr [offset readPointer + 2]
mov al, 0 ; ����������� ������������ ������ �����
mov bx, fd ;�������� ����������
int 21h ; ���������� ��������� ����� � ������
;--------------------------------------------- ��������� ����� �� �����
mov cx, bufferSize ; ����� ���� ��� ������
mov dx, offset buffer ; ����� ������ ��� ������ ������
mov ah, 3Fh ; ������ �� ����� ��� ����������
mov bx, fd ; ������������� �����
int 21h ; ������ �� ����� 
;---------------------------------------------
jc close_file ;���� ���� CF ��� ������, �� ������
;���� �������� ��������� �������, �� � ax ����� ��������� ����
cmp ax, 0 ;���������� � 0 c�������
je close_file ;���� ���� ����, �� ��������� �� ����� close_file � ��������� ���
                                                                         
mov cx, word ptr [offset readPointer] ; ���� ���� �� ������ ��� �� ���-�� ������ ��������� �� ���������� �������
mov dx, word ptr [offset readPointer + 2]
 
add dx, ax; ��������� � �������� ����� ��������� ����
adc cx, 0 ; �������� � ���������
mov word ptr [offset readPointer], cx ;����� �������� ������-������
mov word ptr [offset readPointer + 2], dx

mov bufferLast, ax; �������� ����� ��������� ����
call process_buffer ; ��������� ����� ��������� ������

jmp read_file_buffer

close_file:
;check word buffer
call check_word

mov ah, 40h ;������ � ����
mov cx, 0 ;���-�� ���� ��� ������
mov bx, fd ;������������� �����
mov dx, offset wordBuffer ;����� ������� � �������
int 21h

mov ah, 3Eh ;������� �������� �����
mov bx, fd ;�������� ����������
int 21h
ret
;==============================================================
;==============================================================
process_buffer: ; ��������� ������ �� ���������� �������
pusha
xor si, si

process_buffer_loop:

mov al, [buffer + si] ; � al ��������� ������ ������

mov di, lastWordBuffer ; ��������� �����
mov [wordBuffer + di], al ; �������� � ����� ������ ������ ������
inc di
mov lastWordBuffer, di ; ���������� ������, ����� ����������� � ���������� �������

call check_border ;����������, �� ����� �� ������ ��� �� ������ ��
cmp bx, 1 ;���� ���-�� �� ������������������
jne process_buffer_loop_end ;���� ������ �� �����

call check_word

cmp al, 13
jne process_buffer_loop_end
mov wordCounter, 0

process_buffer_loop_end:
inc si
cmp si, bufferLast; ���������� � ������ ��������� ����
jb process_buffer_loop; ���� �� ����� �� ����� ������ �� ����������

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
dec bx ;���������� �� ��������� ������ �����
cmp bx, 0; ���� ���� ��� ����� (CF = 1 ��� ZF = 1)
jbe check_word_end

mov bx, wordCounter; c������ ����
inc bx
mov wordCounter, bx ; ��������� ������� ����  

cmp bx, wordNumber ;����� �����, ������� ���� ������� �� ������
jne check_word_end ; ���� ������� ����� �� ����� ������ ����� � ������, �� ��������� ����

mov di, lastWordBuffer ;������ ����� ���������� ������� �����
dec di ;������ ���������� ������� �����
mov bl, [wordBuffer + di] ;���������� ������ �� ����� ������� � ������ wordb
mov [wordBuffer], bl
mov lastWordBuffer, 1

check_word_end:
call print_to_file
ret
;==============================================================
;==============================================================
print_to_file:
;�������� � ���� � �������� �����
pusha
;-----------------------------------------------
mov ah, 42h ; ����������� ��������� ������-������
mov cx, word ptr [offset writePointer] ; ��������
mov dx, word ptr [offset writePointer + 2]
mov al, 0 ;�� ������ �����
mov bx, fd ; ����������
int 21h
;-----------------------------------------------
mov ah, 40h ;������ � ���� ��� ����������
mov cx, lastWordBuffer; ����� ������ ��� ������
mov bx, fd; ����������
mov dx, offset wordBuffer ;����� ������� � �������
int 21h
;-----------------------------------------------
mov ax, lastWordBuffer ; ������� ��������� ������-������
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

;[ss:bp+4+0] - ����� �����
;[ss:bp+4+2] - ����� ������
;[ss:bp+4+4] - ������, ���� 1
mov di, [ss:bp+4+2]

xor bx, bx
xor ax, ax
xor cx, cx
xor dx, dx

cmp byte ptr [di + bx], '-'
jne atoi_loop

inc cx; set negative after loop
inc bx

;������� �� ������
atoi_loop:

cmp byte ptr [di + bx], '0' ;�������� �� ��, �������� �� ������ �������� ��������
jb atoi_error; ���� ����
cmp byte ptr [di + bx], '9'
ja atoi_error; ���� ����

mul base ;�������� �� 10
mov dh, 0
mov dl, [di + bx]
sub dl, '0' ;��������� � �����, ������� ascii ��� 0
add ax, dx ;��������� � ��������� �����
jo atoi_error ;���� ��� ������ ���� ������������, �� ������� ������

inc bx
cmp byte ptr [di + bx], 0 ;���� ������������ �� ���� � ������ �� �����������, �� ����������, ���� �� �����
jne atoi_loop

jmp atoi_result

atoi_error: ;������, ����� � ���������
mov byte ptr [ss:bp+4+4], 1
jmp atoi_end

atoi_result:
mov BYTE PTR [ss:bp+4+4], 0 ;��� ������
cmp cx, 1 ;���������, ��� �� ����� ����� ������
jne atoi_end ;���� ���, �� ��������� ���������
neg ax ; ���� ���, �� ������ ���� �� ���������������

atoi_end:
mov di, [ss:bp+4+0]
mov [di], ax ;�������� ����� �� ��������� ������

popa ;��������� ���������
pop bp
ret
;==============================================================
;==============================================================
print_str:
push bp
mov bp, sp
pusha

mov dx, [ss:bp+4+0]
mov ax, 0900h
int 21h

mov dx, offset endl ;������� ����� ������
mov ax, 0900h
int 21h

popa
pop bp
ret
end main