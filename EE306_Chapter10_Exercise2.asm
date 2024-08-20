.ORIG x3000

;R0 = char, R1 = sum, R2 = multiplier, R3 = digits, R4 = GPR
LD R3, DIGITS
LOOP
    BRz END
    TRAP x23 
    AND R0, R0, x0F
    JSR MUL ;multiplies r0 and r2, and adds it to r4
    ADD R1, R1, R4
    AND R4, R4, #0
    LD R0, BASE_VALUE
    JSR MUL 
    ADD R2, R4, #0 
    ADD R3, R3, #-1
    BR LOOP
END
    ADD R0, R1, #0
    HALT
MUL
    MUL_LOOP
        BRn END_MUL
        ADD R4, R4, R2
        ADD R0, R0, #-1
        BR MUL_LOOP
    END_MUL
        RET
BASE_VALUE .FILL #10
DIGITS .FILL #4

.END