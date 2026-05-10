.global _start

.text

_start:
  call main

  //exit
  mov $60, %rax
  mov $0, %rdi
  syscall
