start 	
	NOOP 

up_count_init
	CER
	LDR R1 #0
	LDR R2 #16
	LSIP R3
	PRESENT R3 up_count_body
	OR R2 R3 #0

up_count_body
	SUBV R2 R2 #1
	PRESENT R2 up_count_init
	SSVOP R1
	ADD R1 R1 #1
	LDR R4 #64

timer1_outer
	SUBV R4 R4 #1
	PRESENT R4 up_count_body
	LDR R5 #65535

timer1_inner
	SUBV R5 R5 #1
	PRESENT R5 timer1_outer
	JMP timer1_inner

down_count_init
	CER
	LDR R8 #23
	LSIP R9
	PRESENT R9 down_count_body
	OR R8 R9 #0

down_count_body
	SUBV R8 R8 #1
	PRESENT R8 down_count_init
	SSVOP R8
	LDR R10 #64

timer2_outer
	SUBV R10 R10 #1
	PRESENT R10 down_count_body
	LDR R11 #65535

timer2_inner
	SUBV R11 R11 #1
	PRESENT R11 timer2_outer
	JMP timer2_inner

ENDPROG
