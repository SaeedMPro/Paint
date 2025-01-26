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
        CMP     CX, 10        
        JB      COL_LOOP       
        INC     DX             
        CMP     DX, END_ROW     
        JB      ROW_LOOP        
    ENDM
;-------------------------------


.MODEL SMALL
.STACK 64

.DATA
    WHITE           EQU  0FH
    BLUE            EQU  09H
    GREEN           EQU  0AH
    RED             EQU  0CH

    START_MSG1      DB  '=-----= WELCOME =-----=$'
    START_MSG2      DB  'Paint ProjecT$'
    START_MSG3      DB  'BY : SAEED MAZAHERY$'
    START_MSG4      DB  '<-press any key to start->$'

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

        DRAW_COLOR_BOX  WHITE, 0,  15
        DRAW_COLOR_BOX  BLUE,  20, 35
        DRAW_COLOR_BOX  GREEN, 40, 55
        DRAW_COLOR_BOX  RED,   60, 75

        ; mouse initialization
        MOV     AX, 00H  
        INT     33H 
        CMP     AX, 00H        
        JE      EXIT 
        MOV     AX, 01H    
        INT     33H     

    EXIT:
        MOV     AH, 4CH
        INT     21H
    MAIN    ENDP
    END     MAIN
    