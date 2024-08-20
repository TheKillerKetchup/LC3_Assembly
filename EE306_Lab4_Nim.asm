.ORIG x3000 

AND R4, R4, #0 ;R4 = player_turn, 1 -> player1's turn, 2 -> player2's turn
ADD R4, R4, #1

LD R1, ASCII_ZERO
LD R2, ASCII_ZERO
LD R3, ASCII_ZERO

ADD R1, R1, #3
ADD R2, R2, #5
ADD R3, R3, #8 

ASCII_ZERO .FILL #48   
PLAYER_TURN .FILL #1
;x000A -> \n
;we need to check that the first char is A, B, or C, and that the second one is a number.
GAME_LOOP 
    LD R5, GAME_OVER_BOOL
    ADD R5, R5, #-1
    BRz END_GAME
    JSR PRINT_BOARD
    ;check if GAME_OVER_BOOL is 1, and if so, end game
    LD R4, PLAYER_TURN
    ADD R4, R4, #-1 
    BRz PLAYER_1_TURN
    BRp PLAYER_2_TURN
    PLAYER_1_TURN
        JSR PRINT_PROMPT_1
        BR GENERAL_TURN_LOGIC
    PLAYER_2_TURN
        JSR PRINT_PROMPT_2
    GENERAL_TURN_LOGIC
        LEA R4, INPUT
        GETC
        OUT
        STR R0, R4, #0
        GETC
        OUT
        STR R0, R4, #1
        ;test if input[0] = A,B,or C
        ;test if input[1] <= # of rocks in that row
        LD R5, ASCII_NEGATIVE_A
        LD R6, ASCII_NEGATIVE_ZERO
        ADD R6, R0, R6 ;if its nz, that means R0 is less than or equal to zero, so its not decimal
        BRnz INVALID_INPUT
        ROW_A_TEST
            LDR R0, R4, #0 
            ADD R0, R0, R5 ;-(ascii value of A) 
            BRnp ROW_B_TEST
            LDR R0, R4, #1
            ;before reversing, take x30 away
            NOT R0, R0
            ADD R0, R0, #1
            ADD R0, R1, R0 ;R0 = R1-R0, R1 must be >= R0, so it must be zp
            BRn INVALID_INPUT
            LD R1, ASCII_ZERO
            ADD R1, R0, R1 ;R1 = R0 
            BR FINISH_GAME_LOOP
        ROW_B_TEST
            LDR R0, R4, #0 
            ADD R5, R5, #-1
            ADD R0, R0, R5 ;-(ascii value of B) 
            BRnp ROW_C_TEST
            LDR R0, R4, #1
            NOT R0, R0
            ADD R0, R0, #1
            ADD R0, R2, R0 ;R0 = R2-R0, R2 must be >= R0, so it must be zp
            BRn INVALID_INPUT
            LD R2, ASCII_ZERO
            ADD R2, R0, R2 ;R2 = R0 
            BR FINISH_GAME_LOOP
        ROW_C_TEST
            LDR R0, R4, #0 
            ADD R5, R5, #-1
            ADD R0, R0, R5 ;-(ascii value of C) 
            BRnp INVALID_INPUT
            LDR R0, R4, #1
            NOT R0, R0
            ADD R0, R0, #1
            ADD R0, R3, R0 ;R0 = R3-R0, R3 must be >= R0, so it must be zp
            BRn INVALID_INPUT
            LD R3, ASCII_ZERO
            ADD R3, R0, R3 ;R3 = R0 
            BR FINISH_GAME_LOOP
        FINISH_GAME_LOOP
            JSR CHECK_GAME_OVER
            ;check who's turn it is 
            LD R4, PLAYER_TURN ;1 or 2 
            ADD R4, R4, #-1 ;0 or 1 
            BRp SET_PLAYER1_TURN ;if P, R4 is now 1, else R4 is now 0 
            ADD R4, R4, #2 ;
            SET_PLAYER1_TURN 
                ST R4, PLAYER_TURN
                BR GAME_LOOP
        INVALID_INPUT
        LD R0, INVALID_INPUT_STRING_POINTER
        PUTS
        ;check who's turn it is 
        BR GAME_LOOP
    END_GAME
        LD R4, PLAYER_TURN
        ADD R4, R4, #-1
        BRz PLAYER1_WON
        BRnp PLAYER2_WON
        PLAYER1_WON
            LD R0, PLAYER1_WON_POINTER
            PUTS
            HALT
        PLAYER2_WON
            LD R0, PLAYER2_WON_POINTER
            PUTS
            HALT
CHECK_GAME_OVER
    ST R5, SAVE_R5
    LD R5, ASCII_NEGATIVE_ZERO
    ADD R5, R1, R5
    BRnp CHECK_GAME_OVER_END
    LD R5, ASCII_NEGATIVE_ZERO
    ADD R5, R2, R5
    BRnp CHECK_GAME_OVER_END
    LD R5, ASCII_NEGATIVE_ZERO
    ADD R5, R3, R5
    BRz GAME_OVER
    BRnp CHECK_GAME_OVER_END
    GAME_OVER
        AND R5, R5, #0
        ADD R5, R5, #1
        ST R5, GAME_OVER_BOOL
    CHECK_GAME_OVER_END
        LD R5, SAVE_R5
    RET
GAME_OVER_BOOL .FILL x0000 ;0 = not over, 1 = over
INVALID_INPUT_STRING_POINTER .FILL x3500
;R4 = 0, R0 = rock
PRINT_BOARD
    ST R7, SAVE_R7
    ST R4, SAVE_R4
    LEA R0, ROW_A
    PUTS
    LD R4, ASCII_NEGATIVE_ZERO
    ADD R4, R1, R4
    JSR PRINT_ROCKS
    LEA R0, ROW_B
    PUTS
    LD R4, ASCII_NEGATIVE_ZERO
    ADD R4, R2, R4
    JSR PRINT_ROCKS
    LEA R0, ROW_C
    PUTS
    LD R4, ASCII_NEGATIVE_ZERO
    ADD R4, R3, R4
    JSR PRINT_ROCKS
    LD R4, SAVE_R4
    LD R7, SAVE_R7
    RET
;R4 is the # of rocks, always ends as 0, R0 -> x006F(ascii value for o)
PRINT_ROCKS
    BRz RETURN_ROCKS ;if there are no rocks, it should just return
    LD R0, rock
    LOOP_ROCKS 
        BRz RETURN_ROCKS
        OUT
        ADD R4, R4, #-1
        BRnzp LOOP_ROCKS
    RETURN_ROCKS
        LD R0, new_line
        OUT
        RET
    
PRINT_PROMPT_1
    ST R0, SAVE_R0
    LEA R0, PLAYER_PROMPT_1
    PUTS
    LD R0, SAVE_R0
    RET
PRINT_PROMPT_2
    ST R0, SAVE_R0
    LEA R0, PLAYER_PROMPT_2
    PUTS
    LD R0, SAVE_R0
    RET
SAVE_R0 .BLKW 1
SAVE_R1 .BLKW 1
SAVE_R2 .BLKW 1
SAVE_R3 .BLKW 1
SAVE_R4 .BLKW 1
SAVE_R5 .BLKW 1
SAVE_R6 .BLKW 1
SAVE_R7 .BLKW 1
ASCII_NEGATIVE_A .FILL xFFBF
ASCII_NEGATIVE_ZERO .FILL xFFD0
PLAYER1_WON_POINTER .FILL x3200
PLAYER2_WON_POINTER .FILL x3300
rock .FILL x006F
new_line .FILL x000A
INPUT .BLKW 2
ROW_A .STRINGZ "\nROW A: "
ROW_B .STRINGZ "ROW B: "
ROW_C .STRINGZ "ROW C: "
PLAYER_PROMPT_1 .STRINGZ "Player 1, choose a row and a number of rocks:"
PLAYER_PROMPT_2 .STRINGZ "Player 2, choose a row and a number of rocks:"

.END

.ORIG x3200
PLAYER1_WON_STRING .STRINGZ "\n\nPlayer 1 Wins.\n"
.END
.ORIG x3300
PLAYER2_WON_STRING .STRINGZ "\n\nPlayer 2 Wins.\n"
.END
.ORIG x3500
INVALID_INPUT_STRING .STRINGZ "\nInvalid move. Try again\n"
.END