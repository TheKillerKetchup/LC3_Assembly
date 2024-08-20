; Unfortunately we have not YET installed Windows or Linux on the LC-3,
; so we are going to have to write some operating system code to enable
; keyboard interrupts. The OS code does three things:
;
;    (1) Initializes the interrupt vector table with the starting
;        address of the interrupt service routine. The keyboard
;        interrupt vector is x80. The keyboard interrupt service routine
;        begins at x1000. 
;    (2) Sets bit 14 of the KBSR to enable interrupts.
;    (3) Pushes a PSR and PC to the system stack so that it can jump
;        to the user program at x3000 using an RTI instruction.

        .ORIG x0800
        ; (1) Initialize the interrupt vector table.
        LD R0, ISR
        LD R1, VEC
        STR R0, R1, #0
        
        ; (2) Set bit 14 of KBSR.
        LDI R0, KBSR 
        LD R1, MASK
        NOT R1, R1 
        AND R0, R0, R1 ;bit 14 = 0
        LD R1, MASK
        ADD R0, R0, R1 ;bit 14 = 1 
        STI R0, KBSR

        ; (3) Set up the system stack to enter user space.
        LD R0, PSR
        ADD R6, R6, #-1
        STR R0, R6, #0
        LD R0, PC
        ADD R6, R6, #-1
        STR R0, R6, #0
        ; Enter user space.
        RTI
        
; Fill out these values to init the machine properly
VEC     .FILL x0080
ISR     .FILL x1000
KBSR    .FILL xFE00
MASK    .FILL x4000
PSR     .FILL x8002
PC      .FILL x3000
        .END


.ORIG x3000 
LDI R2, PeeSR
LD R3, INTMASK
AND R2, R2, R3 ;R2 = PSR, but bit 14 is 0 
ADD R4, R2, #0 ;R4 = PSR, but bit 14 is 0 
NOT R3, R3 
ADD R2, R2, R3 ;R2 = PSR, but bit 14 is 1 

LOOP LEA R0, LINE1
PUTS
JSR DELAY
BRnzp LOOP 

;R3 = PSR with interrupts disabled

DELAY   ST  R1, SaveR1
        LD  R1, COUNT
REP     STI R2, PeeSR
        STI R4, PeeSR
        ADD R1, R1, #-1
        BRnp REP
        LD  R1, SaveR1
        RET

INTERRUPT_LOC .FILL x1000

COUNT   .FILL x7FFF 
SaveR1  .BLKW #1
SaveR2  .BLKW #1
SaveR3  .BLKW #1
INTMASK .FILL xBFFF
PeeSR .FILL xFFFC

.END

.ORIG x3100
LINE1 .STRINGZ "\n====================\n*    *  *******\n*    *     *\n*    *     *\n*    *     *\n ****      *\n\n****   ****  ****\n*     *      *\n****  *      ****\n*     *      *\n****   ****  ****\n====================\n"
.END
.ORIG x3200
NOT_DECIMAL_STRING .STRINGZ " is not a decimal digit."
.END

.ORIG x1000
INTERRUPT
        ST R0, SAVE_R0
        ST R1, SAVE_R1
        ST R2, SAVE_R2
        ST R3, SAVE_R3
        ST R4, SAVE_R4
        LD R0, NEWLINE
        OUT
        LDI R0, KBDR 
        LD R3, NEGONE
        LD R4, NEGNINE
        ADD R1, R0, R3;R1 = INPUT-(ascii value of 1)
        BRn NOT_DECIMAL
        ADD R2, R0, R4;R2 = INPUT-(ascii value of 9)
        BRp NOT_DECIMAL
        BRnzp PRINT_NUMBERS
    NOT_DECIMAL
        LD R0, NOT_DECIMAL_STRING_POINTER 
        PUTS
        LD R0, NEWLINE
        OUT
        BRnzp FINISH
    PRINT_NUMBERS
        ADD R1, R0, #0
        NOT R1, R1
        ADD R1, R1, #1
        
        LD R0, ONE
        AND R3, R3, #0 
        ADD R3, R3, #-1 
        LOOP_NUMBER 
            BRp FINISH
            OUT
            ADD R0, R0, #1
            ADD R2, R0, R1 ;R2=R0-R1, if pos then too far
            BRnzp LOOP_NUMBER
            
    FINISH
        LD R0, SAVE_R0
        LD R1, SAVE_R1
        LD R2, SAVE_R2
        LD R3, SAVE_R3
        LD R4, SAVE_R4
        RTI
SAVE_R0  .BLKW #1
SAVE_R1  .BLKW #1
SAVE_R2  .BLKW #1
SAVE_R3  .BLKW #1
SAVE_R4  .BLKW #1

ONE .FILL x0031
NEGONE .FILL xFFCF
NEGNINE .FILL xFFC7
NOT_DECIMAL_STRING_POINTER .FILL x3200
NEWLINE .FILL x000A

KBDR .FILL xFE02

.END
