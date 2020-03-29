.global _start

.text

_start:
  bl main

  //exit
  mov x0, #0
  mov x8, #93
  svc 0
