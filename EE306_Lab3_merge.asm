.ORIG x3000

LD R0, LIST1_STARTING_NODE
LD R1, LIST2_STARTING_NODE
LDR R2, R0, #0

LDR R1, R1, #0 
BRz FINALIZE
STR R2, R0, #2
LDR R0, R0, #0
BRz ADD_LIST2

LOOP_THROUGH_LIST
    LDR R2, R0, #0 ;this is the next node location, AKA list1_pointer
    LDR R3, R1, #0 ;this is the next node location, AKA list2_pointer
    ;what is this is x0000 

    ADD R4, R0, #1 ;this the pointer for the list1_node_word, for the node in list 1
    ADD R5, R1, #1 ;pointer for list2_node_word, node of list2 
    
    ;should we resolve these pointers as the object they point to? 
    LDR R4, R4, #0
    LDR R5, R5, #0
    
    ;R6 will read list1_word's actual characters
    ;R7 will read list2_word's actual characters
    LOOP_THROUGH_WORD;BR{conditions}
        ;if either of the words end, then they are first alphabetically, b/c we can work under the assumption
        ;that their other chars are equal, and therefore, because "Fin" comes before "Finn", the one that terminates first 
        ;is the first one alphabetically
        LDR R6, R4, #0
        BRz APPEND_LIST1_NODE ;if we reach end of list1_node's word
        LDR R7, R5, #0
        BRz APPEND_LIST2_NODE ;if we reach end of list2_node's word
        
        ;this works under the assumption R7 and R6 are both not null chars
        NOT R6, R6
        ADD R6, R6, #1
        ADD R7, R7, R6 ;R7 = R7-R6
        ;if n, R7<R6
        ;if z, R7=R6
        ;if p, R7>R6
        BRn APPEND_LIST2_NODE
        BRp APPEND_LIST1_NODE
        ;keep going
        ADD R4, R4, #1
        ADD R5, R5, #1
        BRnzp LOOP_THROUGH_WORD
        
    ;these should be subops no?
    APPEND_LIST1_NODE
        ST R0, LIST1_LAST_NODE_LOC
        ADD R0, R2, #0
        ;if R0 is x0000, that means only list2 has more elements
        BRz ADD_LIST2
        BRnzp LOOP_THROUGH_LIST
    APPEND_LIST2_NODE
        STR R1, R2, #0
        STR R0, R1, #0 
        ADD R1, R3, #0
        ;if R1 is x0000, that means only list1 has more elements
        BRnzp LOOP_THROUGH_LIST
    ;nothing left to add, since it's list 1 by default
ADD_LIST2
    LD R0, LIST1_LAST_NODE_LOC
    STR R1, R0, #0
FINALIZE
    HALT


LIST1_STARTING_NODE .FILL x4000 
LIST2_STARTING_NODE .FILL x4001
LIST1_LAST_NODE_LOC .FILL x4002
FINAL_LIST_STARTING_NODE .FILL x4002

.END

.ORIG x4000
.FILL x0000
.FILL x4050
.END

.ORIG x4050
.FILL x0000
.FILL x4025
.END

.ORIG x4025
.STRINGZ "Ben"
.END


;testcase 2 
;list1 -> "ben" -> "fred" -> "jacky" -> "lincoln" -> "mellon" -> "squish" -> "zorgs"
;list2 -> "fred" -> "fredd" -> "lincolen" -> "melllon" -> "squuuish" -> "zorgs" -> "corgs"

;testcase 3
;list1 -> x0000
;list2 -> "Ben"

;testcase 4
;list1 -> "Ben"
;list2 -> x0000

;testcase 5 
;list 1 -> x0000
;list 2 -> x0000