;MACRO
;-------------------------------
    DISPLAY_MESSAGE MACRO   MESSAGE
        MOV     DX, OFFSET MESSAGE
        MOV     AH, 09H
        INT     21H
    ENDM

    SET_CURSOR  MACRO   ROW COL
        MOV     AH, 02H
        MOV     BH, 0   
        MOV     DH, ROW 
        MOV     DL, COL 
        INT     10H     
    ENDM

    CLEAR_SCREEN    MACRO 
        MOV     AH, 07H         
        MOV     DH, 25          
        MOV     DL, 40          
        MOV     AL, 00H         
        INT     10H   
    ENDM

    FILL_PIXEL      MACRO   COLOR
        MOV     AL, COLOR
        MOV     AH, 0CH
        INT     10H
    ENDM

    DRAW_COLOR_BOX  MACRO   COLOR, START_ROW, END_ROW
        LOCAL   ROW_LOOP, COL_LOOP
        MOV     DX, START_ROW
    ROW_LOOP:
        MOV     CX, 0           
    COL_LOOP:
        FILL_PIXEL  COLOR      
        INC     CX             
        CMP     CX, 15        
        JB      COL_LOOP       
        INC     DX             
        CMP     DX, END_ROW     
        JB      ROW_LOOP        
    ENDM

    CHOSE_COLOR    MACRO
        LOCAL   C1, C2, C3, C4, END_CHOOSE

        CMP     DX, 20          
        JB      C1
        CMP     DX, 40          
        JB      C2
        CMP     DX, 60          
        JB      C3
        CMP     DX, 80          
        JB      C4
        JMP     END_CHOOSE      

    C1:
        MOV     PAINT_COLOR, WHITE
        JMP     END_CHOOSE
    C2:
        MOV     PAINT_COLOR, BLUE
        JMP     END_CHOOSE
    C3:
        MOV     PAINT_COLOR, GREEN
        JMP     END_CHOOSE
    C4:
        MOV     PAINT_COLOR, RED
    END_CHOOSE:
    ENDM
;-------------------------------


;PROGRAM
;-------------------------------
.MODEL SMALL
.STACK 64

.DATA
    WHITE           EQU  0FH
    BLUE            EQU  09H
    GREEN           EQU  0AH
    RED             EQU  0CH
    BLACK           EQU  00H

    START_MSG1      DB  '=-----= WELCOME =-----=$'
    START_MSG2      DB  'Paint ProjecT$'
    START_MSG3      DB  'BY : SAEED MAZAHERY$'
    START_MSG4      DB  '<-press any key to start->$'

    PAINT_COLOR     DB  WHITE   ;default color = white

.CODE

    MAIN    PROC    FAR
        MOV     AX, @DATA
        MOV     DS, AX
    
    ; start page
        CLEAR_SCREEN
        SET_CURSOR  9, 29
        DISPLAY_MESSAGE START_MSG1
        SET_CURSOR  11, 34
        DISPLAY_MESSAGE START_MSG2
        SET_CURSOR  12, 32
        DISPLAY_MESSAGE START_MSG3
        SET_CURSOR  20, 28
        DISPLAY_MESSAGE START_MSG4

    ;wait for key to skip start page
    CHECK_KEY:
        MOV     AH, 01
        INT     16H
        JZ      CHECK_KEY

    ;init paint
        CLEAR_SCREEN

        ; set video mode
        MOV     AH, 0                   
        MOV     AL, 13H
        INT     10H         

        DRAW_COLOR_BOX  WHITE, 0,  20
        DRAW_COLOR_BOX  BLUE,  20, 40
        DRAW_COLOR_BOX  GREEN, 40, 60
        DRAW_COLOR_BOX  RED,   60, 80

        ; mouse initialization
        MOV     AX, 00H  
        INT     33H 
        CMP     AX, 00H        
        JE      EXIT 
        MOV     AX, 01H    
        INT     33H     

    PAINT_LOOP:
    
        ; get mouse button status
        MOV     AX, 03H      
        INT     33H
        AND     BX, 03H     
        JZ      PAINT_LOOP  
        
        ;in 320*200 video mode cx is doubled so:
        SHR     CX, 1

        ; check for chose color in menu
        CMP     CX, 0FH
        JA      HANDLE_CLICK
        CMP     DX, 81
        JB      SELECT_COLOR

    HANDLE_CLICK:

        ;check for left or right click
        CMP     BX, 01H
        JE      RIGHT_CLICK
        
        CMP     BX, 02H
        JE      LEFT_CLICK

    SELECT_COLOR:
        CHOSE_COLOR
        JMP     PAINT_LOOP

    RIGHT_CLICK:

        ; store start mouse position for drawing
        MOV     SI, CX      
        MOV     DI, DX

        ; Wait for button release
    WAIT_RELEASE:
        MOV     AX, 3
        INT     33H
        CMP     BX, 01H
        JE      WAIT_RELEASE

        ;draw line with: start point(DI, SI) to end point(DX, CX)
        CALL    DRAW_LINE
        JMP     PAINT_LOOP
    LEFT_CLICK:
        FILL_PIXEL   BLACK
        JMP PAINT_LOOP

    EXIT:
        MOV     AH, 00H
        MOV     AL, 03H
        INT     10H

        MOV     AH, 4CH
        INT     21H
    MAIN    ENDP
;----------------------------------

;PROCEDURE
;----------------------------------

;----------------------------------
; PROCEDURE: DRAW_LINE
; Input: SI = start X, DI = start Y, CX = end X, DX = end Y
; Output: Draws a line from (SI, DI) to (CX, DX)
;----------------------------------
DRAW_LINE   PROC    NEAR

DRAW_LINE   ENDP    

;----------------------------------