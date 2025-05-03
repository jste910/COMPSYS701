start
    ; Load values
    LDR R1 #10          ; Immediate load
    LDR R2 R1           ; Register indirect load
    LDR R3 $100         ; Memory load

    ; Store values
    STR R1 #20          ; Immediate store
    STR R2 R1           ; Register indirect store
    STR R3 $200         ; Memory store

    ; Logical operations
    AND R4 R1 #15       ; R4 = R1 AND 15
    AND R4 R4 R2        ; R4 = R4 AND R2
    OR R5 R1 #3         ; R5 = R1 OR 3
    OR R5 R5 R2         ; R5 = R5 OR R2

    ; Arithmetic
    ADD R6 R1 #5        ; R6 = R1 + 5
    ADD R6 R6 R2        ; R6 = R6 + R2
    SUBV R7 R6 #2       ; R7 = R6 - 2 with overflow check
    SUB R7 #1           ; R7 = R7 - 1

    ; Jumps
    JMP loopstart             ; Jump to address 50
loopstart
    JMP R1              ; Jump to address in R1

    ; ; Output
    PRESENT R1 presjmp       ; Display R1 in format 1
presjmp

    ; ; Data and control flow
    DATACALL R1         ; Data call using R1
    DATACALL R2 #5      ; Data call with parameter
    SZ szjmp               ; Set if zero, compare with 3
szjmp
    CLFZ                ; Clear flag zero
    CER                 ; Clear error register
    CEOT                ; Clear end of transmission
    SEOT                ; Set end of transmission

    ; System and logic
    LER R3              ; Load error register into R3
    SSVOP R1            ; Save system value
    LSIP R2             ; Load system input pointer
    SSOP R3             ; Save system operation

    ; Miscellaneous
    NOOP                ; Do nothing
    MAX R4 #99          ; Max compare with 99
    STRPC $300          ; Store PC to memory
    HALT
ENDPROG
END