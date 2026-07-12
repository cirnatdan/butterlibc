.global _start

.text

_start:
  pop %rdi
  mov %rsp, %rsi
  lea 8(%rsp,%rdi,8), %rdx
  xor %rbp, %rbp
  and $-16, %rsp
  call main
  mov %rax, %rdi
  mov $60, %rax
  syscall
