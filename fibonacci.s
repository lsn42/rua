// 100左右的斐波那契数列
.globl _start;

_start:
  addi r1, r0, 100
  addi r2, r0, 0
  addi r3, r0, 1

again:
  addi r2, r2, r3
  // output r2
  addi r3, r3, r2
  // output r3
  blt r3, r1, again