## Exercise 7

Based on the description of this exercise, we are required to analyze what was happening based on gdb output. Here are the compiling results of this part.  
```
(gdb) si
=> 0x100025:	mov    %eax,%cr0
0x00100025 in ?? ()
(gdb) x/10x 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x7000b812	0x220f0011	0xc0200fd8
0x100020:	0x0100010d	0xc0220f80
(gdb) x/10x 0xf0100000
0xf0100000 <_start-268435468>:	0x00000000	0x00000000	0x00000000	0x00000000
0xf0100010 <entry+4>:	0x00000000	0x00000000	0x00000000	0x00000000
0xf0100020 <entry+20>:	0x00000000	0x00000000
(gdb) si
=> 0x100028:	mov    $0xf010002f,%eax
0x00100028 in ?? ()
(gdb) x/10x 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x7000b812	0x220f0011	0xc0200fd8
0x100020:	0x0100010d	0xc0220f80
(gdb) x/10x 0xf0100000
0xf0100000 <_start-268435468>:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0xf0100010 <entry+4>:	0x34000004	0x7000b812	0x220f0011	0xc0200fd8
0xf0100020 <entry+20>:	0x0100010d	0xc0220f80
```

In order to explain this condition, we should first figure out the corresponding codes that cause this happening. In this process, I have noticed a line of assembly code in ```kernel/entry.S```:
```
orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
```
This line of code located right before the line we are going to comment out. As a result, I reference from [Wikipedia](https://en.wikipedia.org/wiki/Control_register) and get the following information:
```
Bit	Name	Full Name	              Description
0	  PE	  Protected Mode Enable	  If 1, system is in protected mode, else system is in real mode
1	  MP	  Monitor co-processor	  Controls interaction of WAIT/FWAIT instructions with TS flag in CR0
2	  EM	  Emulation	              If set, no x87 floating-point unit present, if clear, x87 FPU present
3	  TS	  Task switched	          Allows saving x87 task context upon a task switch only after x87 instruction used
4	  ET	  Extension type	        On the 386, it allowed to specify whether the external math coprocessor was an 80287 or 80387
5	  NE	  Numeric error           Enable internal x87 floating point error reporting when set, else enables PC style x87 error detection
16	WP	  Write protect	          When set, the CPU can't write to read-only pages when privilege level is 0
18	AM	  Alignment mask	        Alignment check enabled if AM set, AC flag (in EFLAGS register) set, and privilege level is 3
29	NW	  Not-write through	      Globally enables/disable write-through caching
30	CD	  Cache disable	Globally enables/disable the memory cache
31	PG	  Paging	If 1, enable paging and use the § CR3 register, else disable paging.
```
