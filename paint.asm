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
        MOV     CX, 16           
    COL_LOOP:
        FILL_PIXEL  COLOR                         
        LOOP      COL_LOOP       
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
;=============
.MODEL SMALL
.STACK 64
;=============
.DATA
    START_MSG1      DB  '=----------= WELCOME =----------=$'
    START_MSG2      DB  '~ Paint Project ~$'
    START_MSG3      DB  'BY : SAEED MAZAHERY$'
    START_MSG4      DB  '<-press any key to start->$'

    ;colors
    WHITE           EQU  0FH
    BLUE            EQU  09H
    GREEN           EQU  0AH
    RED             EQU  0CH
    BLACK           EQU  00H
    PAINT_COLOR     DB  WHITE   ;default color = white

    ;for draw line
    POS_X1          DW  ?
    POS_Y1          DW  ?
    POS_X2          DW  ?
    POS_Y2          DW  ?
    DELTA_X         DW  ?
    DELTA_Y         DW  ? 
    X_DIR           DW  ?
    Y_DIR           DW  ?
    DECISION        DW  ?
;=============
.CODE

    MAIN    PROC    FAR
        MOV     AX, @DATA
        MOV     DS, AX
    
    ; start page
        CLEAR_SCREEN
        SET_CURSOR  9, 24
        DISPLAY_MESSAGE START_MSG1
        SET_CURSOR  11, 33
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
        MOV [POS_X1], CX
        MOV [POS_Y1], DX

        ; Wait for button release
    WAIT_RELEASE:
        MOV     AX, 3
        INT     33H
        CMP     BX, 01H
        JE      WAIT_RELEASE

        ;in 320*200 video mode cx is doubled so:
        SHR     CX, 1

        ; store start mouse position for drawing
        MOV [POS_X2], CX
        MOV [POS_Y2], DX

        ;draw line with: start point(SI, DI) to end point(CX, DX)
        CALL    DRAW_LINE
        JMP     PAINT_LOOP
    LEFT_CLICK:

        ;erases a 3x3 square around the clicked pixel.
        CALL    ERASER
        JMP     PAINT_LOOP

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
; PROCEDURE: ERASER
; Input: CX, DX = center point  
; Output: Erases a 3x3 square around the clicked pixel.
;----------------------------------
ERASER  PROC    NEAR
        
        FILL_PIXEL  BLACK
        INC         CX
        FILL_PIXEL  BLACK
        INC         DX
        FILL_PIXEL  BLACK
        DEC         DX 
        DEC         DX         
        FILL_PIXEL  BLACK
        DEC         CX
        FILL_PIXEL  BLACK
        DEC         CX
        FILL_PIXEL  BLACK
        INC         DX         
        FILL_PIXEL  BLACK
        INC         DX         
        FILL_PIXEL  BLACK
        INC         CX         
        FILL_PIXEL  BLACK

        RET 
ERASER  ENDP
;=============
;----------------------------------
; PROCEDURE: DRAW_LINE (Main Entry Point)
; Input: POS_X1, POS_Y1 - Start coordinates
;        POS_X2, POS_Y2 - End coordinates
;----------------------------------
DRAW_LINE   PROC    NEAR
        ; Save all registers
        PUSHA               

        ; Calculate absolute deltas
        MOV AX, [POS_X2]
        SUB AX, [POS_X1]
        JNC CALC_DELTA_X
        NEG AX
    CALC_DELTA_X:
        MOV [DELTA_X], AX

        MOV AX, [POS_Y2]
        SUB AX, [POS_Y1]
        JNC CALC_DELTA_Y
        NEG AX
    CALC_DELTA_Y:
        MOV [DELTA_Y], AX

        ; Choose algorithm based on slope
        MOV AX, [DELTA_X]
        CMP AX, [DELTA_Y]
        JG DRAW_HORIZONTAL

        CALL DRAW_VERTICAL
        JMP DRAW_EXIT

    DRAW_HORIZONTAL:
        CALL DRAW_HLINE

    DRAW_EXIT:
        ; Restore all registers
        POPA         

        RET
DRAW_LINE ENDP

;----------------------------------
; HORIZONTAL LINE ALGORITHM (|dx| > |dy|)
;----------------------------------
DRAW_HLINE  PROC    NEAR
        PUSHA

        ; Swap points if needed
        MOV AX, [POS_X1]
        CMP AX, [POS_X2]
        JL NO_SWAP_X
        XCHG AX, [POS_X2]
        MOV [POS_X1], AX
        MOV AX, [POS_Y1]
        XCHG AX, [POS_Y2]
        MOV [POS_Y1], AX

    NO_SWAP_X:
        ; Calculate dx and dy
        MOV AX, [POS_X2]
        SUB AX, [POS_X1]
        MOV [DELTA_X], AX
        
        MOV AX, [POS_Y2]
        SUB AX, [POS_Y1]
        MOV [DELTA_Y], AX

        ; Determine Y direction
        MOV BX, 1
        CMP AX, 0
        JGE Y_POSITIVE
        NEG BX
        NEG AX
    Y_POSITIVE:
        MOV [Y_DIR], BX
        MOV [DELTA_Y], AX

        ; Initialize decision parameter
        MOV AX, [DELTA_Y]
        SHL AX, 1
        SUB AX, [DELTA_X]
        MOV [DECISION], AX

        ; Initialize coordinates
        MOV CX, [POS_X1]
        MOV DX, [POS_Y1]

    DRAW_LOOP_H:
        ; Plot pixel
        FILL_PIXEL PAINT_COLOR

        ; Check end condition
        CMP CX, [POS_X2]
        JE END_HLINE

        ; Update decision parameter
        MOV AX, [DECISION]
        CMP AX, 0
        JL UPDATE_X

        ; Move in Y direction
        ADD DX, [Y_DIR]
        SUB AX, [DELTA_X]
        SUB AX, [DELTA_X]
        MOV [DECISION], AX

    UPDATE_X:
        ; Move in X direction
        INC CX
        ADD AX, [DELTA_Y]
        ADD AX, [DELTA_Y]
        MOV [DECISION], AX
        JMP DRAW_LOOP_H

    END_HLINE:
        POPA
        RET
DRAW_HLINE ENDP

;----------------------------------
; VERTICAL LINE ALGORITHM (|dy| >= |dx|)
;----------------------------------
DRAW_VERTICAL   PROC    NEAR
        PUSHA

        ; Swap points if needed
        MOV AX, [POS_Y1]
        CMP AX, [POS_Y2]
        JL NO_SWAP_Y
        XCHG AX, [POS_Y2]
        MOV [POS_Y1], AX
        MOV AX, [POS_X1]
        XCHG AX, [POS_X2]
        MOV [POS_X1], AX

    NO_SWAP_Y:
        ; Calculate dx and dy
        MOV AX, [POS_Y2]
        SUB AX, [POS_Y1]
        MOV [DELTA_Y], AX
        
        MOV AX, [POS_X2]
        SUB AX, [POS_X1]
        MOV [DELTA_X], AX

        ; Determine X direction
        MOV BX, 1
        CMP AX, 0
        JGE X_POSITIVE
        NEG BX
        NEG AX
    X_POSITIVE:
        MOV [X_DIR], BX
        MOV [DELTA_X], AX

        ; Initialize decision parameter
        MOV AX, [DELTA_X]
        SHL AX, 1
        SUB AX, [DELTA_Y]
        MOV [DECISION], AX

        ; Initialize coordinates
        MOV CX, [POS_X1]
        MOV DX, [POS_Y1]

    DRAW_LOOP_V:
        ; Plot pixel
        FILL_PIXEL PAINT_COLOR

        ; Check end condition
        CMP DX, [POS_Y2]
        JE END_VLINE

        ; Update decision parameter
        MOV AX, [DECISION]
        CMP AX, 0
        JL UPDATE_Y

        ; Move in X direction
        ADD CX, [X_DIR]
        SUB AX, [DELTA_Y]
        SUB AX, [DELTA_Y]
        MOV [DECISION], AX

    UPDATE_Y:
        ; Move in Y direction
        INC DX
        ADD AX, [DELTA_X]
        ADD AX, [DELTA_X]
        MOV [DECISION], AX
        JMP DRAW_LOOP_V

    END_VLINE:
        POPA
        RET
DRAW_VERTICAL ENDP
;=============
;----------------------------------