# Assembly Paint Program
This is a simple paint program written in x86 assembly language. It uses BIOS and DOS interrupts to handle graphics, mouse input, and screen manipulation. The program allows users to draw lines, erase pixels, and select colors from a menu.

# Features
- Color Menu: Choose from four colors (white, blue, green, red) by clicking in the menu area.

- Line Tool: Draw lines between two points using the right mouse button.

- Eraser Tool: Erase a 3x3 area using the left mouse button.

- Efficient Line Drawing: Uses Bresenham's line algorithm for smooth and fast line rendering
  
# Program Structure
- MACROS
  - DISPLAY_MESSAGE
  - SET_CURSOR
  - CLEAR_SCREEN
  - FILL_PIXEL
  - DRAW_COLOR_BOX
  - CHOSE_COLOR

- DATA SEGMENT
  - Messages
  - Colors
  - Variables for line drawing

- CODE SEGMENT
  - MAIN PROCEDURE
    - Start Page
    - Initialize Paint Mode
    - Mouse Initialization
    - Main Paint Loop
      - Handle Mouse Input
      - Draw Lines or Erase
  - PROCEDURES
    - ERASER
    - DRAW_LINE
    - DRAW_HLINE
    - DRAW_VERTICAL

# View
![image](https://github.com/user-attachments/assets/5cb45c5e-c0b7-453d-a656-4128d843cc5c) ![image](https://github.com/user-attachments/assets/7645300b-ccf1-4350-96ab-110e983635ee)

