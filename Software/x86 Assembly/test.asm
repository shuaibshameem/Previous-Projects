INCLUDE Irvine32.inc
.code



Proc1 PROC
push ebp
mov esi, esp
mov ecx, 6
mov ebx, TYPE DWORD
call DumpMem
pop ebp
ret
Proc1 ENDP

Main PROC
push ebp
mov ebp, esp
sub esp, 8
mov eax,0ABCD1234h
mov [ebp-8],eax
mov eax,00000005h
mov [ebp-4],eax
mov ebp,12345678h
call Proc1
mov esp, ebp
exit
pop ebp
Main ENDP

END main