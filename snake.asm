.model small
.stack 100h
.data

;клавиши
;-----------------------------
exitKey           equ   01h;  Esc
moveUpKey         equ   11h;  W
moveDownKey       equ   1Fh;  S
moveLeftKey       equ   1Eh;  A
moveRightKey      equ   20h;  D
speedUpKey        equ   48h;  Up
speedDownKey      equ   50h;  Down 
;-----------------------------
     
fieldSizeX        equ   76;
fieldSizeY        equ   19;  

consoleSizeX      equ   80;
consoleSizeY      equ   25;

consoleCageSize   equ   2; длина клетки консоли
scoreSize         equ   4; длина блока счёта

videoStart        dw   0B800h; смещение начала видеобуфера
dataStart    dw 0000h        
timeStart    dw 0040h       
timePosition dw 006Ch        

;стена
;------------------------------------ 
verticalWall            equ     0FBAh;
horizontalWall          equ     0FCDh;
upperLeftCorner         equ     0FC9h;
upperRightCorner        equ     0FBBh;
bottomLeftCorner        equ     0FC8h;
bottomRightCorner       equ     0FBCh; 
wallCrossing            equ     0FCAh;
;------------------------------------ 

space                   equ     0020h;  Пустой блок с черным фоном
snakeBodySymbol         equ     0A6Fh;  Символ тела змейки
appleSymbol             equ     0B0Fh;  Символ яблока
wallSymbol              equ     6023h;   

;блоки
;------------------------------------
vtSpc   equ     05F20h; пробел на фиолетовом фоне 
blSpc   equ     03F20h; пробел на синем фоне
;------------------------------------

;экран
;----------------------------------------------------------------------------------
screen          dw consoleSizeX dup(space) 
                dw space, upperLeftCorner, 13 dup(horizontalWall), 0FCBh, 10 dup(horizontalWall), 0FCBh, 9 dup(horizontalWall), 0FCBh, 11 dup(horizontalWall), 0FCBh, 11 dup(horizontalWall), 0FCBh, 17 dup(horizontalWall), upperRightCorner, space
                dw space, verticalWall, vtSpc, 05F53h, 05F63h, 05F6Fh, 05F72h, 05F65h, 05F3Ah, vtSpc
          score dw scoreSize dup(05F30h), vtSpc, verticalWall  
                dw vtSpc, 05F53h, 05F70h, 2 dup(05F65h), 05F64h, 05F3Ah, vtSpc
          speed dw 05F31h, vtSpc, verticalWall         
                dw blSpc, 03F57h, blSpc, 03FC4h, blSpc, 03F55h, 03F70h, 03F18h, blSpc, verticalWall
                dw blSpc, 03F53h, blSpc, 03FC4h, blSpc, 03F44h, 03F6Fh, 03F77h ,03F6Eh, 03F19h, blSpc, verticalWall
                dw blSpc, 03F41h, blSpc, 03FC4h, blSpc, 03F4Ch, 03F65h, 03F66h ,03F74h, 03F1Bh, blSpc, verticalWall
                dw blSpc, 03F44h, blSpc, 03FC4h, blSpc, 03F52h, 03F69h, 03F67h ,03F68h, 03F74h, 03F1Ah, 6 dup(blSpc), verticalWall, space
                
                dw space, 0FCCh, 13 dup(horizontalWall), 0FCAh, 10 dup(horizontalWall), 0FCAh, 9 dup(horizontalWall), 0FCAh, 11 dup(horizontalWall), 0FCAh, 11 dup(horizontalWall), 0FCAh, 17 dup(horizontalWall), 0FB9h, space  
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space   
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space   
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space   
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space  
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space   
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, verticalWall, fieldSizeX dup(space), verticalWall, space 
                dw space, bottomLeftCorner, fieldSizeX dup(horizontalWall), bottomRightCorner, space
                dw consoleSizeX dup(space)             
;----------------------------------------------------------------------------------       

snakeMaxSize     equ     30
snakeCurrentSize db      3
pointSize        equ     2

snakeBody       dw 1D0Dh, 1C0Dh, 1B0Dh, snakeMaxSize-2 dup(0000h); 0000h = null

wallSize        equ     15 

wall1 dw 0FEFEh, 0FFFEh, 00FEh, 01FEh, 02FEh, 03FEh, 03FFh, 0400h, 0401h, 0402h, 0302h, 0202h, 0102h, 00002h, 0FF02h   
wall2 dw 0FDFCh, 0FDFDh, 0FDFEh, 0FDFFh, 0FE00h, 0FE01h, 0FE02h, 0FE02h, 0FF02h, 0002h, 0102h, 0202h, 0302h, 0402h, 0401h
wall3 dw 0FD02h, 0FD01h, 0FD00h, 0FCFFh, 0FCFEh, 0FDFEh, 0FEFEh, 0FFFEh, 00FEh, 01FEh, 02FEh, 03FEh, 04FEh, 0501h, 0502h 
wall4 dw 0FCFEh, 0FDFEh, 0FEFEh, 0FEFFh, 0FF00h, 0FF01h, 0FF02h, 0002h, 0102h, 0202h, 0302h, 0402h, 0502h, 0501h, 0500h 

wallForm        dw      wallSize dup(0)
realWall        dw      wallSize dup(0)

;управление
;--------------
positiveValue     equ   01h;
stopValue         equ   00h; 
negativeValue     equ   -1;

moveAlongX      db   01h;   
moveAlongY      db   00h;
;---------------

waitTimeMin       equ   1;
waitTimeMax       equ   9;
waitTime          dw    waitTimeMax;
deltaTime         equ   1; 

.code        
;================================================================= 
_clearScreen macro          
	push ax ;               Сохраняем значение ax
	mov ax, 0003h;          00 - установить видеорежим, очистить экран. 03h - режим 80x25
	int 10h;                Вызов прерывания для исполнения команды
	pop ax;                 Восстанавливаем значение регистра ax
endm  
;=================================================================
;############################################################
main:
	mov ax, @data	       
	mov ds, ax              
	mov dataStart, ax;             загружаем начальные данные
	mov ax, videoStart;            загружаем в ax код начала вывода в видеобуффер
	mov es, ax            
	xor ax, ax            
                            
	_clearScreen;                  очищаем консоль
                            
	call ScreenInitialization;     инициализируем экран
                            
	call MainGameCycle;            переходим в основной цикл игры
                          
to_close:    
	mov ah,7h;                     7h - консольный ввод без эха (ожидаем нажатия клавиши для выхода из приложения)
        int 21h                

esc_exit:    
	_clearScreen            
	mov ah, 4ch            
	int 21h               
;############################################################    
;=================================================================
;ZF = 1 - буфер пуст      
;AH = scan-code            
_checkBuffer macro;      проверяем - был ли введен символ с клавиатуры
	mov ah, 01h;               
	int 16h;                 
endm
;=================================================================
;=================================================================
_readFromBuffer macro;   считываем нажатую клавишу
	mov ah, 00h;             
	int 16h;                 
endm 
;=================================================================
;=================================================================
;Результат в cx:dx          
_getTimerValue macro         
	push ax;        Сохраняем значения регистра ax             
	mov ax, 00h;    Получаем значение времени
	int 1Ah;                                
	pop ax   
endm  
;=================================================================
;=================================================================
DrawWall proc 
 push cx
 push bx
 mov cx, wallSize      
 mov si, offset realWall            
 loopDrawWall:              
	mov bx, [si];   загружаем в si очередной символ 
	add si, pointSize 
	                      ;   получаем позицию в видеобуффере
	call CalcOffsetByPoint;   получаем смещение выводимого символа в видеобуффере
	mov di, bx;               загружаем в di позицию
	mov ax, wallSymbol;       загружаем в ax выводимый символ
	stosw;                    выводим
	loop loopDrawWall    
 pop bx	
 pop cx
 ret
endp
;=================================================================
;=================================================================
DestroyWall proc
 push cx
 mov cx, wallSize
 mov si, offset realWall            
 loopDestroyWall:           
	mov bx, [si];           загружаем в si очередной символ
	add si, pointSize        
	
	call CalcOffsetByPoint; получаем смещение выводимого символа в видеобуффере
	mov di, bx;             загружаем в di позицию
	mov ax, space;          заносим в ax пробел
	stosw;                  выводим
	loop loopDestroyWall    
 pop cx
 ret   
endp
;=================================================================
;=================================================================
ScreenInitialization proc          
	mov si, offset screen;  в si загружаем 
	xor di, di;             обнуляем di
                  ;             ds:si указывает на символы, которые мы будем выводить
                  ;             es:di указывает на di-ый символ консоли  
                  
	mov cx, consoleSizeX*consoleSizeY;      загружаем в cx кол-во символов в консоли                                   
	rep movsw;              переписываем последовательно все символы из ds:si в консоль es:di 
	xor ch, ch;                     
	mov cl, snakeCurrentSize;               загружаем в cl размер змейки
	mov si, offset snakeBody;               в si загружаем смещения начала тела змейки
               
loopInitSnake:;                 цикл, в котором мы выводим тело змейки
	mov bx, [si];           загружаем в bx очередной символ тела змейки
	add si, pointSize;      добавляем к si PointSize, т.к. каждая точка занимает 2 байта (цвет + символ)
	
	call CalcOffsetByPoint; получаем смещение выводимого символа в видеобуффере 
	
	mov di, bx;             загружаем в di позицию
	mov ax, snakeBodySymbol;загружаем в ax выводимый символ
	stosw;                  выводим (сохраняем символ по адресу es:di)
	loop loopInitSnake
     
	call GenerateRandomApple; генерируем яблоко в случайных координатах
	ret                     
endp             
;=================================================================
;================================================================= 
;получаем смещение видеобуффера как (bh + (bl * 80)) * 2
;координаты (x,y) в bx
CalcOffsetByPoint proc     
	push ax                
	push dx

	xor ah, ah;             
	mov al, bl;             
	mov dl, consoleSizeX;   в dl загружаем xSize - размер строки
	mul dl;              
	mov dl, bh;           
	xor dh, dh;           
	add ax, dx;            
	mov dx, consoleCageSize
	mul dx;                
	mov bx, ax;          
                            
	pop dx
	pop ax                  
	ret                     
endp                            
;=================================================================
;=================================================================
;сдвигаем тело змейки в массиве и закрашиваем последний элемент
MoveSnake proc              
	push ax                 
	push bx                 
	push cx                 
	push si                
	push di                 
	push es                 
         
	mov al, snakeCurrentSize; в al загружаем длину змейки
	xor ah, ah;            
	mov cx, ax;             
	mov bx, pointSize;      
	mul bx;                 теперь в ax реальная позиция в памяти относительно начала массива
	mov di, offset snakeBody; загружаем в di смещение головы змейки
	add di, ax;             di - адрес следующего после последнего элемента массива
	mov si, di;             згружаем di в si
	sub si, pointSize;      si - адрес последнего элемента массива
                       
	push di           
	                       ;удаляем конец змейки с экрана
	mov es, videoStart;     загружаем в es смещение видеобуффера
	mov bx, ds:[si];        загружаем в bx последний элемент змейки 
	
	call CalcOffsetByPoint; вычисляем ее позицию на экране  
	
	mov di, bx;             заносим позицию, которую будем очищать в di
	mov ax, space;          загружаем в ax пустую клетку (пробел)
	stosw;                  записываем (пересылаем содерджимое ax в es:di)
                            
	pop di
                           
	mov es, dataStart;      для работы с данными (до этого es указывал на видеобуффер)
	std;                    идем от конца к началу
	rep movsw;              переписываем символы из ds:si в es:di (si - предпоследний элемент змейки, di - последний элемент)
	         ;              таким образом смещаем всю змейку на 1 шаг
	mov bx, snakeBody;      загружаем в bx позицию головы змейки
                    
	add bh, moveAlongX;     обновляем координаты головы
	add bl, moveAlongY
	mov snakeBody, bx;      сохраняем новую позицию головы
	                                           
	pop es                  
	pop di                  
	pop si                  
	pop cx                  
	pop bx                  
	pop ax                  
	ret                     
endp                         
;=================================================================
;=================================================================
MainGameCycle proc
	push ax                      
	push bx                      
	push cx                      
	push dx                     
	push ds                      
	push es                      
                       
checkAndMoveLoop: 
         
	_checkBuffer;            проверяем - был ли введен символ
	jnz skipJmp1               
	jmp far ptr noSymbolInBuff   
	                    
skipJmp1:                       
	_readFromBuffer;         считываем символ из буффера
	cmp ah, exitKey
	jne skipJmp2                                   
	jmp far ptr esc_exit
                                 
skipJmp2:                         
	cmp ah, moveLeftKey	       
	je setMoveLeft               
                                 
	cmp ah, moveRightKey	      
	je setMoveRight              
                                 
	cmp ah, moveUpKey		      
	je setMoveUp                 
                                 
	cmp ah, moveDownKey	        
	je setMoveDown              
                                
	cmp ah, speedUpKey		  
	je setSpeedUp                
                                 
	cmp ah, speedDownKey	   
	je setSpeedDown              
                                
	jmp noSymbolInBuff          
                                 
setMoveLeft:              
	mov moveAlongX, negativeValue
	mov moveAlongY,  stopValue
	jmp noSymbolInBuff           
                                 
setMoveRight:                                             
	mov moveAlongX, positiveValue 
	mov moveAlongY, stopValue     
	jmp noSymbolInBuff       
                                 
setMoveUp:                
	mov moveAlongX, stopValue 
	mov moveAlongY, negativeValue   
	jmp noSymbolInBuff           
                                 
setMoveDown:             
	mov moveAlongX, stopValue     
	mov moveAlongY, positiveValue    
	jmp noSymbolInBuff           
                                 
setSpeedUp:                      
	mov ax, waitTime;       загружаем в ax значение задержки
	cmp ax, waitTimeMin;    сравниваем его с минимальным
	je noSymbolInBuff;      если равно минимальному - пропускаем 
	                             
	sub ax, deltaTime;      уменьшаем время задержки
	mov waitTime, ax;       обновляем значение задержки
                                 
	mov es, videoStart           
	mov di, offset speed - offset screen	
	mov ax, es:[di]              
	inc ax                       
	mov es:[di], ax                                       
	jmp noSymbolInBuff           
                                 
setSpeedDown:                    
	mov ax, waitTime             
	cmp ax, waitTimeMax         
	je noSymbolInBuff			 
	                             
	add ax, deltaTime           
	mov waitTime, ax 			 
                                 
	mov es, videoStart           
	mov di, offset speed - offset screen	
	mov ax, es:[di]              
	dec ax                       
	mov es:[di], ax                                       
	jmp noSymbolInBuff           
                                 
noSymbolInBuff:                  
	call MoveSnake;                 передвигаем змейку на экране
	mov bx, snakeBody;              помещаем в bx голову змеи
checkSymbolAgain:                
	call CalcOffsetByPoint;         в bx теперь смещение ячейки консоли с новой головой змейки
                                 
	mov es, videoStart;             загружаем в es смещение видеобуффера
	mov ax, es:[bx];                загружаем в ax символ куда должна СТАТЬ змейка
                                 
	cmp ax, appleSymbol;            если этот символ - яблоко
	je AppleIsNext;                 
                                 
	cmp ax, snakeBodySymbol;        если этот символ - тело змейки
	je SnakeIsNext;                 
                                 
	cmp ax, horizontalWall;         если этот символ - горизонтальная стена
	je PortalUpDown;               
                                  
	cmp ax, verticalWall;           если этот символ - верникальная стена
	je PortalLeftRight;              
	                            
	cmp ax, wallSymbol;             если этот символ - горизонтальная стена
	je SnakeIsNext                   
                                 
	cmp ax, wallCrossing    
	je PortalUpDown         
                                 
	jmp GoNextIteration          
                                
AppleIsNext:                       
        call DestroyWall
	call IncSnake;                  увеличиваем длину змейки
	call GenerateRandomApple;       генерируем новое яблоко 
	call IncScore;                  увеличиваем счет
	jmp GoNextIteration;            переходим к следующей итерации
SnakeIsNext:                     
	jmp endLoop;                    заканчиваем игру
PortalUpDown:                    
	mov bx, snakeBody;              загружаем в bx голову змейки
	sub bl, fieldSizeY;             отнимаем от y координаты высоту консоли 
	cmp bl, 0;                      определяем верхняя это или нижняя граница
	jg writeNewHeadPos;             перерисовываем голову змейки
                                 
	                    ;           если это была верхняя стена
	add bl, fieldSizeY*2;           корректируем координаты 
                                 
writeNewHeadPos:                 
	mov snakeBody, bx;              записываем новое значение головы
	jmp checkSymbolAgain;           и отправляем его заново на сравнение
                                 
PortalLeftRight:                
	mov bx, snakeBody            
	sub bh, fieldSizeX              
	cmp bh, 0		             
	jg writeNewHeadPos;             аналогично обрабатываем случай с вертикальной стеной
                                 
	add bh, fieldSizeX*2             
	jmp writeNewHeadPos         
                                 
GoNextIteration:                 
	mov bx, snakeBody;              загружаем в bx новое начало змейки
	call CalcOffsetByPoint;         вычисляем ее позицию
	mov di, bx;                     теперь в di смещение позиции bx в консоли
	mov ax, snakeBodySymbol;        записываем в ax символ змейки 
	stosw;                          записываем в консоль
                                
	call MakeDelay;                    
                                 
	jmp checkAndMoveLoop       
                                
endLoop:                         
	pop es                       
	pop ds                       
	pop dx                      
	pop cx                       
	pop bx                       
	pop ax                       
	ret                          
endp 
;=================================================================
;=================================================================
MakeDelay proc                       
	push ax                      
	push bx                      
	push cx                      
	push dx                      
                                 
	_getTimerValue;          получаем текущее значение времени в dx
                                 
	add dx, waitTime;       добавляем к dx значение задержки
	mov bx, dx;             dx -> bx
                                 
checkTimeLoop:                   
	_getTimerValue;          получаем текузее значение времени
	cmp dx, bx;             ax - current value, bx - needed value
	jl CheckTimeLoop;       если еще рано - уходим на следующую итерацию 
                                 
	pop dx                       
	pop cx                       
	pop bx                       
	pop ax                       
	ret                          
endp     
;=================================================================
;=================================================================
GenerateRandomApple proc  
	push ax               
	push bx               
	push cx             
	push dx               
	push es               
	                    
	mov ah, 2Ch;    считываем текущее время
	int 21h;        ch - час, cl - минуты, dh - секунды, dl - мсек
	
	mov al, dl                     
        mul dh;         теперь в ax число для рандома
	             
	xor dx, dx             
	             
	mov cx, 04h
	div cx
	mov bh, dl
	
	cmp bh, 0
	jne rnd1  
	mov si, offset wall1                      
	jmp writeToForm
	
	rnd1:	
	cmp bh, 1
	jne rnd2  
	mov si, offset wall2                      
	jmp writeToForm
	
	rnd2:
	cmp bh, 2
	jne rnd3  
	mov si, offset wall3                      
	jmp writeToForm
	
	rnd3:                    
	mov si, offset wall4                      
	jmp writeToForm  
	            
	writeToForm:
	mov di, offset wallForm
	mov cx, wallSize
	
	toForm:
	  push ax
	  mov ax, [si]
	  mov [di],ax
	  pop ax 
	  add di, pointSize
	  add si, pointSize
	  loop toForm                    
;---------------------------------------------------------------------	                      
loop_random:              
	mov ah, 2Ch;            считываем текущее время
	int 21h;                ch - час, cl - минуты, dh - секунды, dl - мсек
	
	mov al, dl;             получаем случайное число
	mul dh;                 теперь в ax число для рандома
                          
	xor dx, dx;             обнуляем dx
	mov cx, fieldSizeX;     в cx загружаем ширину поля
	div cx;                 получаем номер строки яблока
	add dx, 2;              добавляем смещение от начала оси
	mov bh, dl;             сохраняем координату x
                          
	xor dx, dx            
	mov cx, fieldSizeY        
	div cx;                 аналогично получаем y координату
	add dx, 2			  
	mov bl, dl;             теперь в bx находится координата яблока
                                         
        push bx                      
	call CalcOffsetByPoint; расситываем смещение
	mov es, videoStart;     загружаем в es начало видеобуффера
	mov ax, es:[bx];        в ax загружаем символ, который расположен по координатам, в которых мы хотим расположить яблоко
        pop bx       
                     
	cmp ax, space;          сравниваем их с пробелом (пустой клеткой)
	jne loop_random;        если в клетке что-то есть - генерируем новые координаты  
;---------------------------------------------------------------------               
    mov cx, wallSize             
    mov si, offset wallForm            
    loopRandomWall:            
        push bx;               
	add bx, [si];                
        push bx                      
	call CalcOffsetByPoint; расситываем смещение
	mov es, videoStart;     загружаем в es начало видеобуффера
        mov ax, es:[bx];        в ax загружаем символ, который расположен по координатам, в которых мы хотим расположить яблоко
        pop bx 
        pop bx
	cmp ax, space  
	jne loop_random              
	add si, pointSize;      добавляем к si PointSize, т.к. каждая точка занимает 2 байта (цвет + символ)
	loop loopRandomWall
	
    mov cx, wallSize            
    mov si, offset wallForm
    mov di, offset realWall
    loopCreateWall:            
        push ax;                цикл, в котором мы выводим тело стены
	mov ax, [si];           загружаем в si очередной символ тела стены 
	add ax, bx 
	mov [di], ax                      
	add si, pointSize
	add di, pointSize
	pop ax;                 выводим
	loop loopCreateWall    
	
	call DrawWall                                    
	                
	push bx                      
	call CalcOffsetByPoint; расситываем смещение
	mov es, videoStart;     загружаем в es начало видеобуффера
	mov ax, appleSymbol; 
	mov es:[bx], ax;        выводим символ яблока
        pop bx                 
                          
	pop es                
	pop dx                
	pop cx                
	pop bx                
	pop ax                
	ret                   
endp    
;=================================================================
;=================================================================
IncSnake proc             
	push ax              
	push bx              
	push di               
	push es               
                         
	mov al, snakeCurrentSize;       загружаем в ax текущий размер змейки
	cmp al, snakeMaxSize;           сравниваем его с макисимальным размером змейки
	je return;                      если достигли максимума - выходим
                          
	      ;                         увеличиваем длину змейки в массиве
	inc al;                         увеличиваем al на 1
	mov snakeCurrentSize, al;       обновляем размер змейки
	dec al;                         уменьшаем al на 1 (удобнее)
                          
	                      
	mov bl, pointSize;              восстанавливаем конец
	mul bl;                         получили в ax нужное для восстановления смещение  
                         
	mov di, offset snakeBody
	add di, ax;                     di теперь укаывает на точку для восстановления
                          
	mov es, dataStart;              загружаем в es данные
	mov bx, es:[di];                загружаем в bx восстанавливаемую точку
	call CalcOffsetByPoint;         получаем ее координаты
                          
	mov es, videoStart;             загружаем в es смещение видеобуффера
	mov es:[bx], snakeBodySymbol;   записываем в точку символ тела змейки
	                      
return:                  
	pop es                
	pop di               
	pop bx                
	pop ax                
	ret                   
endp      
;=================================================================
;=================================================================
incScore proc             
	push ax               
	push es               
	push si               
	push di
	               
	mov es, videoStart    
	mov cx, scoreSize;  
	mov di, offset score + (scoreSize - 1)*consoleCageSize - offset screen;
                          
loop_score:	              
	mov ax, es:[di]       
	cmp al, 39h;    символ '9'
	jne skip                            
	sub al, 9			 
	mov es:[di], ax                      
	sub di, consoleCageSize;        возвращаемся назад на один символ                  
	loop loop_score 
	      
	jmp return_incScore   
                          
skip:               
	inc ax                
	mov es:[di], ax       
return_incScore:         
	pop di                
	pop si                
	pop es                
	pop ax                
	ret                   
endp                      
end main    