.model small
.stack 100h
.data

;�������
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

consoleCageSize   equ   2; ����� ������ �������
scoreSize         equ   4; ����� ����� �����

videoStart        dw   0B800h; �������� ������ �����������
dataStart    dw 0000h        
timeStart    dw 0040h       
timePosition dw 006Ch        

;�����
;------------------------------------ 
verticalWall            equ     0FBAh;
horizontalWall          equ     0FCDh;
upperLeftCorner         equ     0FC9h;
upperRightCorner        equ     0FBBh;
bottomLeftCorner        equ     0FC8h;
bottomRightCorner       equ     0FBCh; 
wallCrossing            equ     0FCAh;
;------------------------------------ 

space                   equ     0020h;  ������ ���� � ������ �����
snakeBodySymbol         equ     0A6Fh;  ������ ���� ������
appleSymbol             equ     0B0Fh;  ������ ������
wallSymbol              equ     6023h;   

;�����
;------------------------------------
vtSpc   equ     05F20h; ������ �� ���������� ���� 
blSpc   equ     03F20h; ������ �� ����� ����
;------------------------------------

;�����
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

;����������
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
	push ax ;               ��������� �������� ax
	mov ax, 0003h;          00 - ���������� ����������, �������� �����. 03h - ����� 80x25
	int 10h;                ����� ���������� ��� ���������� �������
	pop ax;                 ��������������� �������� �������� ax
endm  
;=================================================================
;############################################################
main:
	mov ax, @data	       
	mov ds, ax              
	mov dataStart, ax;             ��������� ��������� ������
	mov ax, videoStart;            ��������� � ax ��� ������ ������ � �����������
	mov es, ax            
	xor ax, ax            
                            
	_clearScreen;                  ������� �������
                            
	call ScreenInitialization;     �������������� �����
                            
	call MainGameCycle;            ��������� � �������� ���� ����
                          
to_close:    
	mov ah,7h;                     7h - ���������� ���� ��� ��� (������� ������� ������� ��� ������ �� ����������)
        int 21h                

esc_exit:    
	_clearScreen            
	mov ah, 4ch            
	int 21h               
;############################################################    
;=================================================================
;ZF = 1 - ����� ����      
;AH = scan-code            
_checkBuffer macro;      ��������� - ��� �� ������ ������ � ����������
	mov ah, 01h;               
	int 16h;                 
endm
;=================================================================
;=================================================================
_readFromBuffer macro;   ��������� ������� �������
	mov ah, 00h;             
	int 16h;                 
endm 
;=================================================================
;=================================================================
;��������� � cx:dx          
_getTimerValue macro         
	push ax;        ��������� �������� �������� ax             
	mov ax, 00h;    �������� �������� �������
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
	mov bx, [si];   ��������� � si ��������� ������ 
	add si, pointSize 
	                      ;   �������� ������� � ������������
	call CalcOffsetByPoint;   �������� �������� ���������� ������� � ������������
	mov di, bx;               ��������� � di �������
	mov ax, wallSymbol;       ��������� � ax ��������� ������
	stosw;                    �������
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
	mov bx, [si];           ��������� � si ��������� ������
	add si, pointSize        
	
	call CalcOffsetByPoint; �������� �������� ���������� ������� � ������������
	mov di, bx;             ��������� � di �������
	mov ax, space;          ������� � ax ������
	stosw;                  �������
	loop loopDestroyWall    
 pop cx
 ret   
endp
;=================================================================
;=================================================================
ScreenInitialization proc          
	mov si, offset screen;  � si ��������� 
	xor di, di;             �������� di
                  ;             ds:si ��������� �� �������, ������� �� ����� ��������
                  ;             es:di ��������� �� di-�� ������ �������  
                  
	mov cx, consoleSizeX*consoleSizeY;      ��������� � cx ���-�� �������� � �������                                   
	rep movsw;              ������������ ��������������� ��� ������� �� ds:si � ������� es:di 
	xor ch, ch;                     
	mov cl, snakeCurrentSize;               ��������� � cl ������ ������
	mov si, offset snakeBody;               � si ��������� �������� ������ ���� ������
               
loopInitSnake:;                 ����, � ������� �� ������� ���� ������
	mov bx, [si];           ��������� � bx ��������� ������ ���� ������
	add si, pointSize;      ��������� � si PointSize, �.�. ������ ����� �������� 2 ����� (���� + ������)
	
	call CalcOffsetByPoint; �������� �������� ���������� ������� � ������������ 
	
	mov di, bx;             ��������� � di �������
	mov ax, snakeBodySymbol;��������� � ax ��������� ������
	stosw;                  ������� (��������� ������ �� ������ es:di)
	loop loopInitSnake
     
	call GenerateRandomApple; ���������� ������ � ��������� �����������
	ret                     
endp             
;=================================================================
;================================================================= 
;�������� �������� ������������ ��� (bh + (bl * 80)) * 2
;���������� (x,y) � bx
CalcOffsetByPoint proc     
	push ax                
	push dx

	xor ah, ah;             
	mov al, bl;             
	mov dl, consoleSizeX;   � dl ��������� xSize - ������ ������
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
;�������� ���� ������ � ������� � ����������� ��������� �������
MoveSnake proc              
	push ax                 
	push bx                 
	push cx                 
	push si                
	push di                 
	push es                 
         
	mov al, snakeCurrentSize; � al ��������� ����� ������
	xor ah, ah;            
	mov cx, ax;             
	mov bx, pointSize;      
	mul bx;                 ������ � ax �������� ������� � ������ ������������ ������ �������
	mov di, offset snakeBody; ��������� � di �������� ������ ������
	add di, ax;             di - ����� ���������� ����� ���������� �������� �������
	mov si, di;             �������� di � si
	sub si, pointSize;      si - ����� ���������� �������� �������
                       
	push di           
	                       ;������� ����� ������ � ������
	mov es, videoStart;     ��������� � es �������� ������������
	mov bx, ds:[si];        ��������� � bx ��������� ������� ������ 
	
	call CalcOffsetByPoint; ��������� �� ������� �� ������  
	
	mov di, bx;             ������� �������, ������� ����� ������� � di
	mov ax, space;          ��������� � ax ������ ������ (������)
	stosw;                  ���������� (���������� ����������� ax � es:di)
                            
	pop di
                           
	mov es, dataStart;      ��� ������ � ������� (�� ����� es �������� �� �����������)
	std;                    ���� �� ����� � ������
	rep movsw;              ������������ ������� �� ds:si � es:di (si - ������������� ������� ������, di - ��������� �������)
	         ;              ����� ������� ������� ��� ������ �� 1 ���
	mov bx, snakeBody;      ��������� � bx ������� ������ ������
                    
	add bh, moveAlongX;     ��������� ���������� ������
	add bl, moveAlongY
	mov snakeBody, bx;      ��������� ����� ������� ������
	                                           
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
         
	_checkBuffer;            ��������� - ��� �� ������ ������
	jnz skipJmp1               
	jmp far ptr noSymbolInBuff   
	                    
skipJmp1:                       
	_readFromBuffer;         ��������� ������ �� �������
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
	mov ax, waitTime;       ��������� � ax �������� ��������
	cmp ax, waitTimeMin;    ���������� ��� � �����������
	je noSymbolInBuff;      ���� ����� ������������ - ���������� 
	                             
	sub ax, deltaTime;      ��������� ����� ��������
	mov waitTime, ax;       ��������� �������� ��������
                                 
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
	call MoveSnake;                 ����������� ������ �� ������
	mov bx, snakeBody;              �������� � bx ������ ����
checkSymbolAgain:                
	call CalcOffsetByPoint;         � bx ������ �������� ������ ������� � ����� ������� ������
                                 
	mov es, videoStart;             ��������� � es �������� ������������
	mov ax, es:[bx];                ��������� � ax ������ ���� ������ ����� ������
                                 
	cmp ax, appleSymbol;            ���� ���� ������ - ������
	je AppleIsNext;                 
                                 
	cmp ax, snakeBodySymbol;        ���� ���� ������ - ���� ������
	je SnakeIsNext;                 
                                 
	cmp ax, horizontalWall;         ���� ���� ������ - �������������� �����
	je PortalUpDown;               
                                  
	cmp ax, verticalWall;           ���� ���� ������ - ������������ �����
	je PortalLeftRight;              
	                            
	cmp ax, wallSymbol;             ���� ���� ������ - �������������� �����
	je SnakeIsNext                   
                                 
	cmp ax, wallCrossing    
	je PortalUpDown         
                                 
	jmp GoNextIteration          
                                
AppleIsNext:                       
        call DestroyWall
	call IncSnake;                  ����������� ����� ������
	call GenerateRandomApple;       ���������� ����� ������ 
	call IncScore;                  ����������� ����
	jmp GoNextIteration;            ��������� � ��������� ��������
SnakeIsNext:                     
	jmp endLoop;                    ����������� ����
PortalUpDown:                    
	mov bx, snakeBody;              ��������� � bx ������ ������
	sub bl, fieldSizeY;             �������� �� y ���������� ������ ������� 
	cmp bl, 0;                      ���������� ������� ��� ��� ������ �������
	jg writeNewHeadPos;             �������������� ������ ������
                                 
	                    ;           ���� ��� ���� ������� �����
	add bl, fieldSizeY*2;           ������������ ���������� 
                                 
writeNewHeadPos:                 
	mov snakeBody, bx;              ���������� ����� �������� ������
	jmp checkSymbolAgain;           � ���������� ��� ������ �� ���������
                                 
PortalLeftRight:                
	mov bx, snakeBody            
	sub bh, fieldSizeX              
	cmp bh, 0		             
	jg writeNewHeadPos;             ���������� ������������ ������ � ������������ ������
                                 
	add bh, fieldSizeX*2             
	jmp writeNewHeadPos         
                                 
GoNextIteration:                 
	mov bx, snakeBody;              ��������� � bx ����� ������ ������
	call CalcOffsetByPoint;         ��������� �� �������
	mov di, bx;                     ������ � di �������� ������� bx � �������
	mov ax, snakeBodySymbol;        ���������� � ax ������ ������ 
	stosw;                          ���������� � �������
                                
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
                                 
	_getTimerValue;          �������� ������� �������� ������� � dx
                                 
	add dx, waitTime;       ��������� � dx �������� ��������
	mov bx, dx;             dx -> bx
                                 
checkTimeLoop:                   
	_getTimerValue;          �������� ������� �������� �������
	cmp dx, bx;             ax - current value, bx - needed value
	jl CheckTimeLoop;       ���� ��� ���� - ������ �� ��������� �������� 
                                 
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
	                    
	mov ah, 2Ch;    ��������� ������� �����
	int 21h;        ch - ���, cl - ������, dh - �������, dl - ����
	
	mov al, dl                     
        mul dh;         ������ � ax ����� ��� �������
	             
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
	mov ah, 2Ch;            ��������� ������� �����
	int 21h;                ch - ���, cl - ������, dh - �������, dl - ����
	
	mov al, dl;             �������� ��������� �����
	mul dh;                 ������ � ax ����� ��� �������
                          
	xor dx, dx;             �������� dx
	mov cx, fieldSizeX;     � cx ��������� ������ ����
	div cx;                 �������� ����� ������ ������
	add dx, 2;              ��������� �������� �� ������ ���
	mov bh, dl;             ��������� ���������� x
                          
	xor dx, dx            
	mov cx, fieldSizeY        
	div cx;                 ���������� �������� y ����������
	add dx, 2			  
	mov bl, dl;             ������ � bx ��������� ���������� ������
                                         
        push bx                      
	call CalcOffsetByPoint; ����������� ��������
	mov es, videoStart;     ��������� � es ������ ������������
	mov ax, es:[bx];        � ax ��������� ������, ������� ���������� �� �����������, � ������� �� ����� ����������� ������
        pop bx       
                     
	cmp ax, space;          ���������� �� � �������� (������ �������)
	jne loop_random;        ���� � ������ ���-�� ���� - ���������� ����� ����������  
;---------------------------------------------------------------------               
    mov cx, wallSize             
    mov si, offset wallForm            
    loopRandomWall:            
        push bx;               
	add bx, [si];                
        push bx                      
	call CalcOffsetByPoint; ����������� ��������
	mov es, videoStart;     ��������� � es ������ ������������
        mov ax, es:[bx];        � ax ��������� ������, ������� ���������� �� �����������, � ������� �� ����� ����������� ������
        pop bx 
        pop bx
	cmp ax, space  
	jne loop_random              
	add si, pointSize;      ��������� � si PointSize, �.�. ������ ����� �������� 2 ����� (���� + ������)
	loop loopRandomWall
	
    mov cx, wallSize            
    mov si, offset wallForm
    mov di, offset realWall
    loopCreateWall:            
        push ax;                ����, � ������� �� ������� ���� �����
	mov ax, [si];           ��������� � si ��������� ������ ���� ����� 
	add ax, bx 
	mov [di], ax                      
	add si, pointSize
	add di, pointSize
	pop ax;                 �������
	loop loopCreateWall    
	
	call DrawWall                                    
	                
	push bx                      
	call CalcOffsetByPoint; ����������� ��������
	mov es, videoStart;     ��������� � es ������ ������������
	mov ax, appleSymbol; 
	mov es:[bx], ax;        ������� ������ ������
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
                         
	mov al, snakeCurrentSize;       ��������� � ax ������� ������ ������
	cmp al, snakeMaxSize;           ���������� ��� � ������������� �������� ������
	je return;                      ���� �������� ��������� - �������
                          
	      ;                         ����������� ����� ������ � �������
	inc al;                         ����������� al �� 1
	mov snakeCurrentSize, al;       ��������� ������ ������
	dec al;                         ��������� al �� 1 (�������)
                          
	                      
	mov bl, pointSize;              ��������������� �����
	mul bl;                         �������� � ax ������ ��� �������������� ��������  
                         
	mov di, offset snakeBody
	add di, ax;                     di ������ �������� �� ����� ��� ��������������
                          
	mov es, dataStart;              ��������� � es ������
	mov bx, es:[di];                ��������� � bx ����������������� �����
	call CalcOffsetByPoint;         �������� �� ����������
                          
	mov es, videoStart;             ��������� � es �������� ������������
	mov es:[bx], snakeBodySymbol;   ���������� � ����� ������ ���� ������
	                      
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
	cmp al, 39h;    ������ '9'
	jne skip                            
	sub al, 9			 
	mov es:[di], ax                      
	sub di, consoleCageSize;        ������������ ����� �� ���� ������                  
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