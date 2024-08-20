.ORIG x3000 

;creating the testcase
LD R0, BASE_ADDRESS
LD R1, LENGTH
LD R2, BASE_ADDRESS_LOC
LD R3, LENGTH_LOC
STR R0, R2, #0 
STR R1, R3, #0 

LD R3, i0 
STR R3, R0, #0 
ADD R0, R0, #1
LD R3, i1 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i2 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i3 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i4 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i5 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i6 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i7 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i8 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i9 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i10 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i11 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i12 
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i13
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i14
STR R3, R0, #0
ADD R0, R0, #1
LD R3, i15
STR R3, R0, #0
ADD R0, R0, #1


;init of actual program
AND R6, R6, #0
LDI R0, BASE_ADDRESS_LOC
LDI R1, LENGTH_LOC

LOOP
    BRnz TERMINATE
; init R2 = R4 = BASE_ADDRESS(R0) + INDEX(R6)
    AND R2, R2, #0 
    AND R4, R4, #0
    ADD R2, R6, R0 
    ADD R4, R6, R0
    
    INNER_LOOP
        BRnz CONTINUE
        LDR R3, R2, #0 
        LDR R5, R4, #0 
        
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R3, R5 
        BRzp END_OF_INNER_LOOP
        
        AND R2, R2, #0
        ADD R2, R2, R4 

; check if current_index(R4) out of bounds
        END_OF_INNER_LOOP 
        
        
        NOT R7, R0
        ADD R7, R7, #1
        ADD R4, R4, R7
        NOT R7, R4
        ADD R4, R4, #1 ;this is placed in the middle so that it doesn't interrupt the process nor the branch
        ADD R4, R4, R0
        ADD R7, R7, #1
        ADD R7, R7, R1
        
        BRnzp INNER_LOOP
    CONTINUE
    
    ADD R7, R6, R0 
    LDR R7, R7, #0
    LDR R3, R2, #0
    STR R7, R2, #0
    ADD R7, R6, R0
    STR R3, R7, #0 
    
    ADD R6, R6, #1 
    AND R7, R7, #0 
    
    ADD R7, R7, R6
    NOT R7, R7
    ADD R7, R7, #1
    ADD R7, R7, R1
    
BRnzp LOOP

BASE_ADDRESS_LOC  .FILL x3200
LENGTH_LOC .FILL x3201

BASE_ADDRESS .FILL x33F0 
LENGTH .FILL x0010 

i0 .FILL xFFFF
i1 .FILL x0062
i2 .FILL x0A73
i3 .FILL x006C
i4 .FILL x0070
i5 .FILL x0001
i6 .FILL x0063
i7 .FILL x0065
i8 .FILL x0062
i9 .FILL x0073
i10 .FILL x006E
i11 .FILL x006B
i12 .FILL xFF76
i13 .FILL x0F7A
i14 .FILL x0068
i15 .FILL x006D





TERMINATE

.END