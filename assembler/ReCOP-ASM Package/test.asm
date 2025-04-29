start NOOP ;starting the program
		LDR R1 #1
		LDR R8 #1
count	ADD R1 R1 #65535
		SSVOP R8
		LDR R2 #2 ;max register size, 16 bits
time	SUBV R2 R2 #1
		PRESENT R2 count ;if R2=0 go to count
		NOOP
		JMP time
ENDPROG
END