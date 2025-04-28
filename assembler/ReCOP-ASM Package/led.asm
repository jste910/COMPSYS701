start: 
  ldr R1 #15;

outer_loop_init:
  noop;
  ssop R1;
  ldr R2 #100;

inner_loop_init:
  noop;
  ldr R3 #20000;

inner_loop:
  noop;
  subvr R3 R3 #1;
  present R3 continue_outer;
  noop;
  jmp inner_loop;
  noop;

continue_outer:
  noop;
  subvr R2 R2 #1;
  present R2 outer_exit;
  noop;
  jmp inner_loop_init;
  noop;

outer_exit:
  noop;
  subvr R1 R1 #1;
  present R1 reset;
  noop;
  jmp outer_loop_init;
  noop;

reset:
  noop;
  ldr R1 #15;
  jmp outer_loop_init;
  noop;