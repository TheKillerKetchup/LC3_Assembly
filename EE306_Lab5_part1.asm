.ORIG x3000

LOOP LEA R0, LINE1
PUTS
GETC
LD R3, NEGONE
LD R4, NEGNINE
ADD R1, R0, R3
BRn NOTDECIMAL
ADD R2, R0, R4
BRp NOTDECIMAL

;R0 starts as x0031
AND R2, R2, #0
ADD R2, R2, R0
LD R0, ONE
AND R5, R5, #0

PRINTNUMBER BRn LOOP 
OUT
ADD R0, R0, #1
NOT R1, R0
ADD R1, R1, #1
ADD R1, R2, R1 ;R1 = R2-R0
BRnzp PRINTNUMBER

NOTDECIMAL
OUT
LD R0, NOTADECIMALSTRINGPOINTER
PUTS
BRnzp LOOP

ONE .FILL x0031
NEGONE .FILL xFFCF
NEGNINE .FILL xFFC7
NOTADECIMALSTRINGPOINTER .FILL x3200

.END

.ORIG x3100
LINE1 .STRINGZ "\n====================\n*    *  *******\n*    *     *\n*    *     *\n*    *     *\n ****      *\n\n****   ****  ****\n*     *      *\n****  *      ****\n*     *      *\n****   ****  ****\n====================\n"
.END
.ORIG x3200
NOTDECIMALSTRING .STRINGZ " is not a decimal digit."
.END