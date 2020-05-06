.model small
.stack 100h
.data

;êëàâèøè
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

consoleCageSize   equ   2; äëèíà êëåòêè êîíñîëè
scoreSize         equ   4; äëèíà áëîêà ñ÷¸òà

videoMemoryStart        dw   0B800h; ñìåùåíèå íà÷àëà âèäåîáóôåðà
dataStart    dw 0000h             

;ñòåíà
;------------------------------------ 
verticalWall            equ     0FBAh;
horizontalWall          equ     0FCDh;
upperLeftCorner         equ     0FC9h;
upperRightCorner        equ     0FBBh;
bottomLeftCorner        equ     0FC8h;
bottomRightCorner       equ     0FBCh; 
wallCrossing            equ     0FCAh;
;------------------------------------ 

space                   equ     0020h;  Ïóñòîé áëîê ñ ÷åðíûì ôîíîì
snakeBodySymbol         equ     0A6Fh;  Ñèìâîë òåëà çìåéêè
appleSymbol             equ     0B0Fh;  Ñèìâîë ÿáëîêà
wallSymbol              equ     6023h;   

;áëîêè
;------------------------------------
vtSpc   equ     05F20h; ïðîáåë íà ôèîëåòîâîì ôîíå 
blSpc   equ     03F20h; ïðîáåë íà ñèíåì ôîíå
;------------------------------------

;ýêðàí
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

snakeBody       dw 1D0Dh, 1C0Dh, 1B0Dh, snakeMaxSize-3 dup(0000h); 0000h = null

wallSize        equ     15 

wall1 dw 0FEFEh, 0FFFEh, 00FEh, 01FEh, 02FEh, 03FEh, 03FFh, 0400h, 0401h, 0402h, 0302h, 0202h, 0102h, 00002h, 0FF02h   
wall2 dw 0FDFCh, 0FDFDh, 0FDFEh, 0FDFFh, 0FE00h, 0FE01h, 0FE02h, 0FE02h, 0FF02h, 0002h, 0102h, 0202h, 0302h, 0402h, 0401h
wall3 dw 0FD02h, 0FD01h, 0FD00h, 0FCFFh, 0FCFEh, 0FDFEh, 0FEFEh, 0FFFEh, 00FEh, 01FEh, 02FEh, 03FEh, 04FEh, 0501h, 0502h 
wall4 dw 0FCFEh, 0FDFEh, 0FEFEh, 0FEFFh, 0FF00h, 0FF01h, 0FF02h, 0002h, 0102h, 0202h, 0302h, 0402h, 0502h, 0501h, 0500h 

wallForm        dw      wallSize dup(0)
realWall        dw      wallSize dup(0)

;óïðàâëåíèå
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
	push ax ;               Ñîõðàíÿåì çíà÷åíèå ax
	mov ax, 0003h;          00 - óñòàíîâèòü âèäåîðåæèì, î÷èñòèòü ýêðàí. 03h - ðåæèì 80x25
	int 10h;                Âûçîâ ïðåðûâàíèÿ äëÿ èñïîëíåíèÿ êîìàíäû
	pop ax;                 Âîññòàíàâëèâàåì çíà÷åíèå ðåãèñòðà ax
endm  
;=================================================================
;############################################################
main:
	mov ax, @data	       
	mov ds, ax              
	mov dataStart, ax;             çàãðóæàåì íà÷àëüíûå äàííûå
	mov ax, videoMemoryStart;            çàãðóæàåì â ax êîä íà÷àëà âûâîäà â âèäåîáóôôåð
	mov es, ax            
	xor ax, ax            
                            
	_clearScreen;                  î÷èùàåì êîíñîëü
                            
	call ScreenInitialization;     èíèöèàëèçèðóåì ýêðàí
                            
	call MainGameCycle;            ïåðåõîäèì â îñíîâíîé öèêë èãðû
                          
to_close:    
	mov ah,7h;                     7h - êîíñîëüíûé ââîä áåç ýõà (îæèäàåì íàæàòèÿ êëàâèøè äëÿ âûõîäà èç ïðèëîæåíèÿ)
        int 21h                

esc_exit:    
	_clearScreen            
	mov ah, 4ch            
	int 21h               
;############################################################    
;=================================================================
; ZF = 1 - áóôåð ïóñò      
; ñêàí-êîä â ah       
_checkBuffer macro;      ïðîâåðÿåì - áûë ëè ââåäåí ñèìâîë ñ êëàâèàòóðû
	mov ah, 01h;               
	int 16h;                 
endm
;=================================================================
;=================================================================
_readFromBuffer macro;   ñ÷èòûâàåì íàæàòóþ êëàâèøó
	mov ah, 00h;             
	int 16h;                 
endm 
;=================================================================
;=================================================================
;Ðåçóëüòàò â cx:dx          
_getTimerValue macro         
	push ax;        Ñîõðàíÿåì çíà÷åíèÿ ðåãèñòðà ax             
	mov ax, 00h;    Ïîëó÷àåì çíà÷åíèå âðåìåíè
	int 1Ah;                                
	pop ax   
endm  
;=================================================================
;=================================================================
SpawnWall proc 
 push cx
 push bx
 mov cx, wallSize      
 mov si, offset realWall            
 loopSpawnWall:              
	mov bx, [si];             çàãðóæàåì â si î÷åðåäíîé ñèìâîë 
	add si, pointSize 
	              ;           ïîëó÷àåì ïîçèöèþ â âèäåîáóôôåðå
	call GetOffset;           ïîëó÷àåì ñìåùåíèå âûâîäèìîãî ñèìâîëà â âèäåîáóôôåðå
	mov di, bx;               çàãðóæàåì â di ïîçèöèþ
	mov ax, wallSymbol;       çàãðóæàåì â ax âûâîäèìûé ñèìâîë
	stosw;                    âûâîäèì
	loop loopSpawnWall    
 pop bx	
 pop cx
 ret
endp
;=================================================================
;=================================================================
DeleteWall proc
 push cx
 mov cx, wallSize
 mov si, offset realWall            
 loopDeleteWall:           
	mov bx, [si];           çàãðóæàåì â si î÷åðåäíîé ñèìâîë
	add si, pointSize        
	
	call GetOffset;         ïîëó÷àåì ñìåùåíèå âûâîäèìîãî ñèìâîëà â âèäåîáóôôåðå
	mov di, bx;             çàãðóæàåì â di ïîçèöèþ
	mov ax, space;          çàíîñèì â ax ïðîáåë
	stosw;                  âûâîäèì
	loop loopDeleteWall    
 pop cx
 ret   
endp
;=================================================================
;=================================================================
ScreenInitialization proc          
	mov si, offset screen;  â si çàãðóæàåì 
	xor di, di;             îáíóëÿåì di
                  ;             ds:si óêàçûâàåò íà ñèìâîëû, êîòîðûå ìû áóäåì âûâîäèòü
                  ;             es:di óêàçûâàåò íà di-ûé ñèìâîë êîíñîëè  
                  
	mov cx, consoleSizeX*consoleSizeY;      çàãðóæàåì â cx êîë-âî ñèìâîëîâ â êîíñîëè                                   
	rep movsw;              ïåðåïèñûâàåì ïîñëåäîâàòåëüíî âñå ñèìâîëû èç ds:si â êîíñîëü es:di 
	xor ch, ch;                     
	mov cl, snakeCurrentSize;               çàãðóæàåì â cl ðàçìåð çìåéêè
	mov si, offset snakeBody;               â si çàãðóæàåì ñìåùåíèÿ íà÷àëà òåëà çìåéêè
               
loopInitSnake:;                 öèêë, â êîòîðîì ìû âûâîäèì òåëî çìåéêè
	mov bx, [si];           çàãðóæàåì â bx î÷åðåäíîé ñèìâîë òåëà çìåéêè
	add si, pointSize;      äîáàâëÿåì ê si PointSize, ò.ê. êàæäàÿ òî÷êà çàíèìàåò 2 áàéòà (öâåò + ñèìâîë)
	
	call getOffset;         ïîëó÷àåì ñìåùåíèå âûâîäèìîãî ñèìâîëà â âèäåîáóôôåðå 
	
	mov di, bx;             çàãðóæàåì â di ïîçèöèþ
	mov ax, snakeBodySymbol;çàãðóæàåì â ax âûâîäèìûé ñèìâîë
	stosw;                  âûâîäèì (ñîõðàíÿåì ñèìâîë ïî àäðåñó es:di)
	loop loopInitSnake
     
	call SpawnApple; ãåíåðèðóåì ÿáëîêî â ñëó÷àéíûõ êîîðäèíàòàõ
	ret                     
endp             
;=================================================================
;================================================================= 
;ïîëó÷àåì ñìåùåíèå âèäåîáóôôåðà êàê (bh + (bl * 80)) * 2
;êîîðäèíàòû (x,y) â bx
GetOffset proc     
	push ax                
	push dx

	xor ah, ah;             
	mov al, bl;             
	mov dl, consoleSizeX;   â dl çàãðóæàåì xSize - ðàçìåð ñòðîêè
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
;ñäâèãàåì òåëî çìåéêè â ìàññèâå è çàêðàøèâàåì ïîñëåäíèé ýëåìåíò
MoveSnake proc              
	push ax                 
	push bx                 
	push cx                 
	push si                
	push di                 
	push es                 
         
	mov al, snakeCurrentSize; â al çàãðóæàåì äëèíó çìåéêè
	xor ah, ah;            
	mov cx, ax;             
	mov bx, pointSize;      
	mul bx;                 òåïåðü â ax ðåàëüíàÿ ïîçèöèÿ â ïàìÿòè îòíîñèòåëüíî íà÷àëà ìàññèâà
	mov di, offset snakeBody; çàãðóæàåì â di ñìåùåíèå ãîëîâû çìåéêè
	add di, ax;             di - àäðåñ ñëåäóþùåãî ïîñëå ïîñëåäíåãî ýëåìåíòà ìàññèâà
	mov si, di;             çãðóæàåì di â si
	sub si, pointSize;      si - àäðåñ ïîñëåäíåãî ýëåìåíòà ìàññèâà
                       
	push di           
	                       ;óäàëÿåì êîíåö çìåéêè ñ ýêðàíà
	mov es, videoMemoryStart;     çàãðóæàåì â es ñìåùåíèå âèäåîáóôôåðà
	mov bx, ds:[si];        çàãðóæàåì â bx ïîñëåäíèé ýëåìåíò çìåéêè 
	
	call GetOffset;         âû÷èñëÿåì åå ïîçèöèþ íà ýêðàíå  
	
	mov di, bx;             çàíîñèì ïîçèöèþ, êîòîðóþ áóäåì î÷èùàòü â di
	mov ax, space;          çàãðóæàåì â ax ïóñòóþ êëåòêó (ïðîáåë)
	stosw;                  çàïèñûâàåì (ïåðåñûëàåì ñîäåðäæèìîå ax â es:di)
                            
	pop di
                           
	mov es, dataStart;      äëÿ ðàáîòû ñ äàííûìè (äî ýòîãî es óêàçûâàë íà âèäåîáóôôåð)
	std;                    èäåì îò êîíöà ê íà÷àëó
	rep movsw;              ïåðåïèñûâàåì ñèìâîëû èç ds:si â es:di (si - ïðåäïîñëåäíèé ýëåìåíò çìåéêè, di - ïîñëåäíèé ýëåìåíò)
	         ;              òàêèì îáðàçîì ñìåùàåì âñþ çìåéêó íà 1 øàã
	mov bx, snakeBody;      çàãðóæàåì â bx ïîçèöèþ ãîëîâû çìåéêè
                    
	add bh, moveAlongX;     îáíîâëÿåì êîîðäèíàòû ãîëîâû
	add bl, moveAlongY
	mov snakeBody, bx;      ñîõðàíÿåì íîâóþ ïîçèöèþ ãîëîâû
	                                           
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
         
	_checkBuffer;            ïðîâåðÿåì - áûë ëè ââåäåí ñèìâîë
	jnz skipJmp1               
	jmp far ptr noSymbolInBuff   
	                    
skipJmp1:                       
	_readFromBuffer;         ñ÷èòûâàåì ñèìâîë èç áóôôåðà
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
	mov ax, waitTime;       çàãðóæàåì â ax çíà÷åíèå çàäåðæêè
	cmp ax, waitTimeMin;    ñðàâíèâàåì åãî ñ ìèíèìàëüíûì
	je noSymbolInBuff;      åñëè ðàâíî ìèíèìàëüíîìó - ïðîïóñêàåì 
	                             
	sub ax, deltaTime;      óìåíüøàåì âðåìÿ çàäåðæêè
	mov waitTime, ax;       îáíîâëÿåì çíà÷åíèå çàäåðæêè
                                 
	mov es, videoMemoryStart           
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
                                 
	mov es, videoMemoryStart           
	mov di, offset speed - offset screen	
	mov ax, es:[di]              
	dec ax                       
	mov es:[di], ax                                       
	jmp noSymbolInBuff           
                                 
noSymbolInBuff:                  
	call MoveSnake;                 ïåðåäâèãàåì çìåéêó íà ýêðàíå
	mov bx, snakeBody;              ïîìåùàåì â bx ãîëîâó çìåè
checkSymbolAgain:                
	call GetOffset;                 â bx òåïåðü ñìåùåíèå ÿ÷åéêè êîíñîëè ñ íîâîé ãîëîâîé çìåéêè
                                 
	mov es, videoMemoryStart;             çàãðóæàåì â es ñìåùåíèå âèäåîáóôôåðà
	mov ax, es:[bx];                çàãðóæàåì â ax ñèìâîë êóäà äîëæíà ÑÒÀÒÜ çìåéêà
                                 
	cmp ax, appleSymbol;            åñëè ýòîò ñèìâîë - ÿáëîêî
	je AppleIsNext;                 
                                 
	cmp ax, snakeBodySymbol;        åñëè ýòîò ñèìâîë - òåëî çìåéêè
	je SnakeIsNext;                 
                                 
	cmp ax, horizontalWall;         åñëè ýòîò ñèìâîë - ãîðèçîíòàëüíàÿ ñòåíà
	je PortalUpDown;               
                                  
	cmp ax, verticalWall;           åñëè ýòîò ñèìâîë - âåðíèêàëüíàÿ ñòåíà
	je PortalLeftRight;              
	                            
	cmp ax, wallSymbol;             åñëè ýòîò ñèìâîë - ãîðèçîíòàëüíàÿ ñòåíà
	je SnakeIsNext                   
                                 
	cmp ax, wallCrossing    
	je PortalUpDown         
                                 
	jmp GoNextIteration          
                                
AppleIsNext:                       
        call DeleteWall
	call IncSnake;                  óâåëè÷èâàåì äëèíó çìåéêè
	call SpawnApple;                ãåíåðèðóåì íîâîå ÿáëîêî 
	call IncScore;                  óâåëè÷èâàåì ñ÷åò
	jmp GoNextIteration;            ïåðåõîäèì ê ñëåäóþùåé èòåðàöèè
SnakeIsNext:                     
	jmp endLoop;                    çàêàí÷èâàåì èãðó
PortalUpDown:                    
	mov bx, snakeBody;              çàãðóæàåì â bx ãîëîâó çìåéêè
	sub bl, fieldSizeY;             îòíèìàåì îò y êîîðäèíàòû âûñîòó êîíñîëè 
	cmp bl, 0;                      îïðåäåëÿåì âåðõíÿÿ ýòî èëè íèæíÿÿ ãðàíèöà
	jg writeNewHeadPos;             ïåðåðèñîâûâàåì ãîëîâó çìåéêè
                                 
	                    ;           åñëè ýòî áûëà âåðõíÿÿ ñòåíà
	add bl, fieldSizeY*2;           êîððåêòèðóåì êîîðäèíàòû 
                                 
writeNewHeadPos:                 
	mov snakeBody, bx;              çàïèñûâàåì íîâîå çíà÷åíèå ãîëîâû
	jmp checkSymbolAgain;           è îòïðàâëÿåì åãî çàíîâî íà ñðàâíåíèå
                                 
PortalLeftRight:                
	mov bx, snakeBody            
	sub bh, fieldSizeX              
	cmp bh, 0		             
	jg writeNewHeadPos;             àíàëîãè÷íî îáðàáàòûâàåì ñëó÷àé ñ âåðòèêàëüíîé ñòåíîé
                                 
	add bh, fieldSizeX*2             
	jmp writeNewHeadPos         
                                 
GoNextIteration:                 
	mov bx, snakeBody;              çàãðóæàåì â bx íîâîå íà÷àëî çìåéêè
	call GetOffset;                 âû÷èñëÿåì åå ïîçèöèþ
	mov di, bx;                     òåïåðü â di ñìåùåíèå ïîçèöèè bx â êîíñîëè
	mov ax, snakeBodySymbol;        çàïèñûâàåì â ax ñèìâîë çìåéêè 
	stosw;                          çàïèñûâàåì â êîíñîëü
                                
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
                                 
	_getTimerValue;          ïîëó÷àåì òåêóùåå çíà÷åíèå âðåìåíè â dx
                                 
	add dx, waitTime;       äîáàâëÿåì ê dx çíà÷åíèå çàäåðæêè
	mov bx, dx;             dx -> bx
                                 
checkTimeLoop:                   
	_getTimerValue;          ïîëó÷àåì òåêóçåå çíà÷åíèå âðåìåíè
	cmp dx, bx;             ax - current value, bx - needed value
	jl CheckTimeLoop;       åñëè åùå ðàíî - óõîäèì íà ñëåäóþùóþ èòåðàöèþ 
                                 
	pop dx                       
	pop cx                       
	pop bx                       
	pop ax                       
	ret                          
endp     
;=================================================================
;=================================================================
SpawnApple proc  
	push ax               
	push bx               
	push cx             
	push dx               
	push es               
	                    
	mov ah, 2Ch;    ñ÷èòûâàåì òåêóùåå âðåìÿ
	int 21h;        ch - ÷àñ, cl - ìèíóòû, dh - ñåêóíäû, dl - ìñåê
	
	mov al, dl                     
        mul dh;         òåïåðü â ax ÷èñëî äëÿ ðàíäîìà
	             
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
	mov ah, 2Ch;            ñ÷èòûâàåì òåêóùåå âðåìÿ
	int 21h;                ch - ÷àñ, cl - ìèíóòû, dh - ñåêóíäû, dl - ìñåê
	
	mov al, dl;             ïîëó÷àåì ñëó÷àéíîå ÷èñëî
	mul dh;                 òåïåðü â ax ÷èñëî äëÿ ðàíäîìà
                          
	xor dx, dx;             îáíóëÿåì dx
	mov cx, fieldSizeX;     â cx çàãðóæàåì øèðèíó ïîëÿ
	div cx;                 ïîëó÷àåì íîìåð ñòðîêè ÿáëîêà
	add dx, 2;              äîáàâëÿåì ñìåùåíèå îò íà÷àëà îñè
	mov bh, dl;             ñîõðàíÿåì êîîðäèíàòó x
                          
	xor dx, dx            
	mov cx, fieldSizeY        
	div cx;                 àíàëîãè÷íî ïîëó÷àåì y êîîðäèíàòó
	add dx, 2			  
	mov bl, dl;             òåïåðü â bx íàõîäèòñÿ êîîðäèíàòà ÿáëîêà
                                         
        push bx                      
	call GetOffset;         ðàññèòûâàåì ñìåùåíèå
	mov es, videoMemoryStart;     çàãðóæàåì â es íà÷àëî âèäåîáóôôåðà
	mov ax, es:[bx];        â ax çàãðóæàåì ñèìâîë, êîòîðûé ðàñïîëîæåí ïî êîîðäèíàòàì, â êîòîðûõ ìû õîòèì ðàñïîëîæèòü ÿáëîêî
        pop bx       
                     
	cmp ax, space;          ñðàâíèâàåì èõ ñ ïðîáåëîì (ïóñòîé êëåòêîé)
	jne loop_random;        åñëè â êëåòêå ÷òî-òî åñòü - ãåíåðèðóåì íîâûå êîîðäèíàòû  
;---------------------------------------------------------------------               
    mov cx, wallSize             
    mov si, offset wallForm            
    loopRandomWall:            
        push bx;               
	add bx, [si];                
        push bx                      
	call GetOffset;               ðàññèòûâàåì ñìåùåíèå
	mov es, videoMemoryStart;     çàãðóæàåì â es íà÷àëî âèäåîáóôôåðà
        mov ax, es:[bx];        â ax çàãðóæàåì ñèìâîë, êîòîðûé ðàñïîëîæåí ïî êîîðäèíàòàì, â êîòîðûõ ìû õîòèì ðàñïîëîæèòü ÿáëîêî
        pop bx 
        pop bx
	cmp ax, space  
	jne loop_random              
	add si, pointSize;      äîáàâëÿåì ê si PointSize, ò.ê. êàæäàÿ òî÷êà çàíèìàåò 2 áàéòà (öâåò + ñèìâîë)
	loop loopRandomWall
	
    mov cx, wallSize            
    mov si, offset wallForm
    mov di, offset realWall
    loopCreateWall:            
        push ax;                öèêë, â êîòîðîì ìû âûâîäèì òåëî ñòåíû
	mov ax, [si];           çàãðóæàåì â si î÷åðåäíîé ñèìâîë òåëà ñòåíû 
	add ax, bx 
	mov [di], ax                      
	add si, pointSize
	add di, pointSize
	pop ax;                 âûâîäèì
	loop loopCreateWall    
	
	call SpawnWall                                    
	                
	push bx                      
	call GetOffset;         ðàññèòûâàåì ñìåùåíèå
	mov es, videoMemoryStart;     çàãðóæàåì â es íà÷àëî âèäåîáóôôåðà
	mov ax, appleSymbol; 
	mov es:[bx], ax;        âûâîäèì ñèìâîë ÿáëîêà
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
                         
	mov al, snakeCurrentSize;       çàãðóæàåì â ax òåêóùèé ðàçìåð çìåéêè
	cmp al, snakeMaxSize;           ñðàâíèâàåì åãî ñ ìàêèñèìàëüíûì ðàçìåðîì çìåéêè
	je return;                      åñëè äîñòèãëè ìàêñèìóìà - âûõîäèì
                          
	      ;                         óâåëè÷èâàåì äëèíó çìåéêè â ìàññèâå
	inc al;                         óâåëè÷èâàåì al íà 1
	mov snakeCurrentSize, al;       îáíîâëÿåì ðàçìåð çìåéêè
	dec al;                         óìåíüøàåì al íà 1 (óäîáíåå)
                          
	                      
	mov bl, pointSize;              âîññòàíàâëèâàåì êîíåö
	mul bl;                         ïîëó÷èëè â ax íóæíîå äëÿ âîññòàíîâëåíèÿ ñìåùåíèå  
                         
	mov di, offset snakeBody
	add di, ax;                     di òåïåðü óêàûâàåò íà òî÷êó äëÿ âîññòàíîâëåíèÿ
                          
	mov es, dataStart;              çàãðóæàåì â es äàííûå
	mov bx, es:[di];                çàãðóæàåì â bx âîññòàíàâëèâàåìóþ òî÷êó
	call GetOffset;                 ïîëó÷àåì åå êîîðäèíàòû
                          
	mov es, videoMemoryStart;             çàãðóæàåì â es ñìåùåíèå âèäåîáóôôåðà
	mov es:[bx], snakeBodySymbol;   çàïèñûâàåì â òî÷êó ñèìâîë òåëà çìåéêè
	                      
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
	               
	mov es, videoMemoryStart    
	mov cx, scoreSize;  
	mov di, offset score + (scoreSize - 1)*consoleCageSize - offset screen;
                          
loop_score:	              
	mov ax, es:[di]       
	cmp al, 39h;    ñèìâîë '9'
	jne skip                            
	sub al, 9			 
	mov es:[di], ax                      
	sub di, consoleCageSize;        âîçâðàùàåìñÿ íàçàä íà îäèí ñèìâîë                  
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
