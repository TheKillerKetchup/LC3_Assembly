;connect 4 
;game state is 6x6 grid, O for player1, X for player2
;6 arrays running left to right(1 array = 1 row)
;there should be a counter for each column, AKA what array it goes to 
;so we need basically a 6x6 matrix

;the main challenge seems to be defining win conditions 
;idea: look in all 4 cardinal directions and 4 diagonal directions
    ;then, extend left and right, and if |right-left| is 3 or more, game ends 
        ;it's 3 or more b/c if chips occupy indicies 1,2,3,4, 4-1 = 3, but it occupies 4 spaces
        ;i.e if its occuping index 1, 1-1 = 0, so the line is always |diff|+1 or deltaIndex+1

.ORIG x3000

JSR SET_AXIS_DIFFERENCE_ARRAY

GAME_LOOP
    JSR CHECK_GAME_OVER
    LD R1, GAME_OVER_BOOL
    ADD R1, R1, #-1
    BRz END_GAME
    JSR PRINT_BOARD
    LD R2, PLAYER_TURN ;this is temp and will be overwritten
    ADD R2, R2, #-1 
    BRz PLAYER1_TURN
    BRp PLAYER2_TURN
    PLAYER1_TURN 
        LEA R0, PLAYER1_PROMPT
        PUTS 
        GETC 
        OUT
        BR GENERAL_TURN_LOGIC
    PLAYER2_TURN
        LEA R0, PLAYER2_PROMPT
        PUTS 
        GETC 
        OUT
        BR GENERAL_TURN_LOGIC
    GENERAL_TURN_LOGIC
        LD R1, ASCII_NEGATIVE_SEVEN
        ADD R1, R0, R1 ;must be less than this 
        BRzp INVALID_INPUT
        LD R1, ASCII_NEGATIVE_ZERO
        ADD R1, R0, R1 ;must be greater than this
        BRnz INVALID_INPUT
        LD R1, BOARD_ARRAY_POINTER
        LD R2, NUM_COLS
        ADD R2, R2, #1 ;to account for \n 
        LD R4, ASCII_NEGATIVE_ZERO
        ADD R1, R1, R0
        ADD R1, R1, R4 ;R0 -> (1,6)
        ADD R1, R1, #-1 ;R1 is now at top row of correct column
        LD R3, COLUMN_BOTTOM_POINTER 
        ADD R3, R3, #-1 ;-1 to account for the fact that col1 is at x3500, and ascii negative zero is x30 not x31
        ADD R3, R3, R0 ;cant touch R0 in prev b/c its used here
        ADD R3, R3, R4 ;ascii
        LDR R5, R3, #0 ;R5 is now x3500-x3505, column_bottoms
        BRz INVALID_INPUT ;if column_bottom is 0, there is no such col
        ADD R5, R5, #-1
        STR R5, R3, #0 ;update column_bottom 
        ADD R3, R5, #0
        AND R4, R4, #0
        JSR MULTIPLY
        ;multiply R2*R3 and place in R4
        ;multiply NUM_COLS * (COLUMN_BOTTOM-1) ;column_bottom-1 b/c if bottom is 1, you don't move
        ADD R1, R1, R4
        ADD R1, R1, #1 ;R1 is now at the correct index, b/c first char is \n
        JSR PLACE_CHIP
        ;check if the current player, p1 or p2, won. Do this by extending along both diagonal, as well as both
        ;the vertical and horizontal axises, and then checking if top-bottom is >=3. 
        ;its 3 rather than 4, because if a chip is in pos1, top-bottom = 0, but the line is 1 chip long
        ;remember to check bounds when extending! Game_array runs from x4000 to x4041, terminated by NULL at x4042
        
        JSR CHECK_IF_WINNER ;if winner, will place ID of winner in WINNER_ID
        ;now if there is a winner, print the winner message and HALT
        LD R2, WINNER_BOOL
        ADD R2, R2, #-1 
        BRz END_GAME
        BR END_TURN
    END_TURN
        ;swap player_turn
        ;logic:if r2 = 2, 2-1 = 1, so do nothing.
        ;if r2 = 1, 1-1 = 0, so add 2 
        LD R2, PLAYER_TURN
        ADD R2, R2, #-1
        BRp SET_PLAYER1_TURN 
        ADD R2, R2, #2
        SET_PLAYER1_TURN
        ST R2, PLAYER_TURN
        BR GAME_LOOP
    INVALID_INPUT
        LEA R0, INVALID_INPUT_STRING
        PUTS
        BR GAME_LOOP
    END_GAME
        JSR PRINT_BOARD
        JSR END_GAME_SUBROUTINE
        HALT
PRINT_BOARD
    LD R0, BOARD_ARRAY_POINTER
    PUTS
    RET
PLACE_CHIP
    ST R2, Save_R2
    LD R2, PLAYER_TURN
    ADD R2, R2, #-1
    BRz PLAYER1_PLACE_CHIP
    BRp PLAYER2_PLACE_CHIP
    PLAYER1_PLACE_CHIP
        LD R2, PLAYER1_CHIP 
        STR R2, R1, #0 
        BR END_PLACE_CHIP
    PLAYER2_PLACE_CHIP
        LD R2, PLAYER2_CHIP 
        STR R2, R1, #0 
        BR END_PLACE_CHIP
    END_PLACE_CHIP
        LD R2, Save_R2
        RET
MULTIPLY ;multiply r2*r3 and place res in r4
    ADD R3, R3, #-1
    BRn FINISH_MULTIPLY
    ADD R4, R2, R4 
    BR MULTIPLY
    FINISH_MULTIPLY
        RET
CHECK_IF_WINNER ;R1 points to current chip location
    ST R1, Save_R1
    ST R2, Save_R2
    ST R3, Save_R3
    ST R4, Save_R4
    ST R5, Save_R5
    ST R6, Save_R6
    
    LDR R2, R1, #0 ;R2 is either 'O' or 'X', current_chip_value
    ;R3 = diff_array_pointer, R4 = diff_array_value, R5 = chip_to_check_position, R6 = chip_to_check_value,
    ;4 axises -> {1: (NORTH,SOUTH), 2: (EAST,WEST), 3:(NORTHEAST,SOUTHWEST), 4:(NORTHWEST,SOUTHEAST)}
    LD R3, AXIS_DIFFERENCE_ARRAY_POINTER
    ADD R5, R1, #0
    
    LOOP_THROUGH_DIFF_ARRAY
        ADD R5, R1, #0
        LDR R4, R3, #0 
        BRz END_CHECK_IF_WINNER
        EXTEND_BOTTOM_LOOP ;diff is positive
            ADD R5, R5, R4
            LDR R6, R5, #0
            NOT R6, R6
            ADD R6, R6, #1
            ADD R6, R2, R6 ;R6 = R2-R6, if not zero, then don't extend
            BRnp BEGIN_EXTEND_TOP
            ;if correct chip, then add 1 to bottom
            LD R6, BOTTOM
            ADD R6, R6, #1
            ST R6, BOTTOM 
            BR EXTEND_BOTTOM_LOOP
        BEGIN_EXTEND_TOP
            ;invert R4
            NOT R4, R4
            ADD R4, R4, #1
            ADD R5, R1, #0 
        EXTEND_TOP_LOOP
            ADD R5, R5, R4
            LDR R6, R5, #0
            NOT R6, R6
            ADD R6, R6, #1
            ADD R6, R2, R6 ;R6 = R2-R6, if not zero, then don't extend
            BRnp FINISH_DIFF_ARRAY_LOOP
            ;if correct chip, then add 1 to top
            LD R6, TOP
            ADD R6, R6, #1
            ST R6, TOP 
            BR EXTEND_TOP_LOOP
        FINISH_DIFF_ARRAY_LOOP
        ;check top-bottom, then reset top, bottom if not sufficient
        ;we can use R4, R6 safely
        LD R4, TOP
        LD R6, BOTTOM
        ADD R4, R4, R6 
        ADD R4, R4, #-3
        BRzp WINNER_WINNER_CHICKEN_DINNER
        ;reset top/bottom
        AND R4, R4, #0
        ST R4, TOP
        ST R4, BOTTOM
        ADD R3, R3, #1
        BR LOOP_THROUGH_DIFF_ARRAY
    
    WINNER_WINNER_CHICKEN_DINNER
        AND R1, R1, #0
        ADD R1, R1, #1
        ST R1, WINNER_BOOL
        
    ;br not needed here b/c it will naturally move to end
    END_CHECK_IF_WINNER
        LD R1, Save_R1
        LD R2, Save_R2
        LD R3, Save_R3
        LD R4, Save_R4
        LD R5, Save_R5
        LD R6, Save_R6
        RET

SET_AXIS_DIFFERENCE_ARRAY
    LD R2, AXIS_DIFFERENCE_ARRAY_POINTER
    AND R3, R3, #0
    ADD R3, R3, #1
    STR R3, R2, #1 ;east-west diff = 1
    LD R3, NUM_COLS
    STR R3, R2, #2 ;northeast-southwest diff = n
    ADD R3, R3, #1
    STR R3, R2, #0 ;north-south diff = n+1
    ADD R3, R3, #1
    STR R3, R2, #3 ;northwest-southeast diff = n+2
    RET
END_GAME_SUBROUTINE
    LD R1, PLAYER_TURN
    ADD R1, R1, #-1 
    BRz PLAYER1_WON
    PLAYER2_WON
        LEA R0, PLAYER2_WON_STRING
        PUTS
        RET
    PLAYER1_WON
        LEA R0, PLAYER1_WON_STRING
        PUTS
        RET
CHECK_GAME_OVER
    ST R1, Save_R1
    ST R2, Save_R2
    ST R3, Save_R3
    LD R1, COLUMN_BOTTOM_POINTER
    LD R2, NUM_COLS
    CHECK_GAME_OVER_LOOP
        BRz GAME_IS_OVER
        LDR R3, R1, #0
        BRp END_CHECK_GAME_OVER
        ADD R1, R1, #1
        ADD R2, R2, #-1
        BR CHECK_GAME_OVER_LOOP
    GAME_IS_OVER
        AND R1, R1, #0 
        ADD R1, R1, #1
        ST R1, GAME_OVER_BOOL
    END_CHECK_GAME_OVER
        LD R1, Save_R1
        LD R2, Save_R2
        LD R3, Save_R3
        RET
GAME_OVER_BOOL .FILL #0
;top prioritizes north, then east
TOP .FILL x0 ;relative absolute difference to current_chip_loc, must be zero or positive
;bottom prioritizes south, then west
BOTTOM .FILL x0 ;relative absolute difference to current_chip_loc, must be zero or positive
AXIS_DIFFERENCE_ARRAY_POINTER .FILL x3300
WINNER_BOOL .FILL #0
Save_R1 .FILL x0
Save_R2 .FILL x0
Save_R3 .FILL x0
Save_R4 .FILL x0
Save_R5 .FILL x0
Save_R6 .FILL x0
PLAYER1_CHIP .FILL x004F ;'O'
PLAYER2_CHIP .FILL x0058 ;'X' 
PLAYER_TURN .FILL #1 ;player1 begins
ASCII_NEGATIVE_ZERO .FILL xFFD0
ASCII_NEGATIVE_SEVEN .FILL xFFC7
COLUMN_BOTTOM_POINTER .FILL x3500 
BOARD_ARRAY_POINTER .FILL x4000 ;b/c first char is \n
NUM_COLS .FILL #6
PLAYER1_PROMPT .STRINGZ "Player 1, choose a column: "
PLAYER2_PROMPT .STRINGZ "Player 2, choose a column: "
PLAYER1_WON_STRING .STRINGZ "\n\nPlayer 1 wins."
PLAYER2_WON_STRING .STRINGZ "\n\nPlayer 2 wins."
INVALID_INPUT_STRING .STRINGZ "\nInvalid move. Try again.\n"
.END

.ORIG x3300 
;axis_difference_array
;north-south, east-west, northeast-southwest, northwest-southeast
.END

.ORIG x3500
COLUMN1_BOTTOM .FILL #6 ;this designates what array a chip going into column1 falls into, 1-indexed
COLUMN2_BOTTOM .FILL #6
COLUMN3_BOTTOM .FILL #6
COLUMN4_BOTTOM .FILL #6
COLUMN5_BOTTOM .FILL #6
COLUMN6_BOTTOM .FILL #6
.END

.ORIG x4000
BOARD_ARRAY .STRINGZ "\n------\n------\n------\n------\n------\n------\n" ;arrays 1-6 are actually 7 characters, they just print and terminate at null
.END