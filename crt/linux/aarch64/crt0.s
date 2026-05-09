.global _start

.text

_start:
  b main

  // exit
  mov x0, #0
  mov x8, #93
  svc #0
