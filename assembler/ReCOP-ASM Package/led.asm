start  LDR R1 #15;

outer_loop_init  NOOP;
  SSOP R1;
  SSVOP R1;
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
ENDPROG
