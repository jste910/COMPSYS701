<<<<<<< HEAD
start  LDR R1 #15;

outer_loop_init  NOOP;
	SSOP R1;
  	LDR R2 #100;

inner_loop_init  NOOP;
	LDR R3 #20000;

inner_loop  NOOP;
	SUBV R3 R3 #1;
	PRESENT R3 continue_outer;
	NOOP;
	JMP inner_loop;
	NOOP;

continue_outer  NOOP;
	SUBV R2 R2 #1;
	PRESENT R2 outer_exit;
	NOOP;
	JMP inner_loop_init;
	NOOP;

outer_exit  NOOP;
	SUBV R1 R1 #1;
	PRESENT R1 reset;
	NOOP;
	JMP outer_loop_init;
	NOOP;

reset  NOOP;
	LDR R1 #15;
	JMP outer_loop_init;
	NOOP;
=======
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
>>>>>>> 632ffa73dc53347d9628cb80eee307ccee57ab14
ENDPROG
