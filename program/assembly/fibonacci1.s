.globl main;
.type main, @function;

main:
  addi t1, x0, 100
  addi t2, x0, 0
  addi t3, x0, 1

again:
  add t2, t2, t3
  add t3, t3, t2
  blt t3, t1, again
