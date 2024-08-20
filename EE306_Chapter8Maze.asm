;Bit[4]=1 if there is a door to the outside world; Bit[4]=0 if no door.
;Bit[3]=1 if there is a door to the cell to the north; Bit[3]=0 if no door.
;Bit[2]=1 if there is a door to the cell to the east; Bit[2]=0 if no door.
;Bit[1]=1 if there is a door to the cell to the south; Bit[1]=0 if no door.
;Bit[0]=1 if there is a door to the cell to the west; Bit[0]=0 if no door.

.ORIG x5000
MAZE .FILL x0006
.FILL x0007
.FILL x0005
.FILL x0005
.FILL x0003
.FILL x0000
; second row: indices 6 to 11
.FILL x0008
.FILL x000A
.FILL x0004
.FILL x0003
.FILL x000C
.FILL x0015
; third row: indices 12 to 17
.FILL x0000
.FILL x000C
.FILL x0001
.FILL x000A
.FILL x0002
.FILL x0002
; fourth row: indices 18 to 23
.FILL x0006
.FILL x0005
.FILL x0007
.FILL x000D
.FILL x000B
.FILL x000A
; fifth row: indices 24 to 29
.FILL x000A
.FILL x0000
.FILL x000A
.FILL x0002
.FILL x0008
.FILL x000A
; sixth row: indices 30 to 35
.FILL x0008
.FILL x0000
.FILL x001A
.FILL x000C
.FILL x0001
.FILL x0008
.END
