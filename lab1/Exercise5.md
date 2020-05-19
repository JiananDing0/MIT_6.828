## Exercise 5

In this exercise, we are required to observe several files and make some changes to them

#### 1. Observe ```boot/Makefrag``` and ```obj/boot/boot.asm```:

* The content of ```boot/Makefrag``` are shown below:
```
# Makefile fragment for the JOS kernel.
# This is NOT a complete makefile;
# you must run GNU make in the top-level directory
# where the GNUmakefile is located.
#

OBJDIRS += boot

BOOT_OBJS := $(OBJDIR)/boot/boot.o $(OBJDIR)/boot/main.o

$(OBJDIR)/boot/%.o: boot/%.c
        @echo + cc -Os $<
        @mkdir -p $(@D)
        $(V)$(CC) -nostdinc $(KERN_CFLAGS) -Os -c -o $@ $<

$(OBJDIR)/boot/%.o: boot/%.S
        @echo + as $<
        @mkdir -p $(@D)
        $(V)$(CC) -nostdinc $(KERN_CFLAGS) -c -o $@ $<

$(OBJDIR)/boot/main.o: boot/main.c
        @echo + cc -Os $<
        $(V)$(CC) -nostdinc $(KERN_CFLAGS) -Os -c -o $(OBJDIR)/boot/main.o boot/main.c

$(OBJDIR)/boot/boot: $(BOOT_OBJS)
        @echo + ld boot/boot
        $(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@.out $^
        $(V)$(OBJDUMP) -S $@.out >$@.asm
        $(V)$(OBJCOPY) -S -O binary -j .text $@.out $@
        $(V)perl boot/sign.pl $(OBJDIR)/boot/boot
```

* Corrspondingly, the starting part of content of ```obj/boot/boot.asm``` are shown below:
```
00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:       fa                      cli
  cld                         # String operations increment
    7c01:       fc                      cld

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:       31 c0                   xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:       8e d8                   mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:       8e c0                   mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:       8e d0                   mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:       e4 64                   in     $0x64,%al
  testb   $0x2,%al
    7c0c:       a8 02                   test   $0x2,%al
  jnz     seta20.1
    7c0e:       75 fa                   jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:       b0 d1                   mov    $0xd1,%al
  outb    %al,$0x64
    7c12:       e6 64                   out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:       e4 64                   in     $0x64,%al
  testb   $0x2,%al
    7c16:       a8 02                   test   $0x2,%al
  jnz     seta20.2
    7c18:       75 fa                   jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:       b0 df                   mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:       e6 60                   out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses
```
Based on what have been provided in the assembly language file, we see something similar to what we get in exercise 3, such as ```set 20.1``` and ```set 20.2```. Also, the addresses presented in this chunk of code start from ```0x7c00```, which is the same as the address we set in ```boot/Makefrag```. As it been mentioned in the lab description, they use ```-Ttext 0x7C00``` to control the loading address of the system to start at ```0x7c00```.

#### 2. Make changes to ```0x7C00``` and recompile:
* Now we try to modify the address presented in ```boot/Makefrag``` from ```0x7C00``` to ```0x7D00```.
* After that, we run ```make clean``` then ```make``` again.
* We can observe that some changes has been made in ```obj/boot/boot.asm```:
```
00007d00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7d00:       fa                      cli
  cld                         # String operations increment
    7d01:       fc                      cld

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7d02:       31 c0                   xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7d04:       8e d8                   mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7d06:       8e c0                   mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7d08:       8e d0                   mov    %eax,%ss
```
As we can observe here, all the content are still the same because the code never changes. However,the corresponding address of these lines of codes change.
* After that, we can recompile and debug ```qemu``` to see what different has been happened. (Please reference to **[Exercise 2](https://github.com/JiananDing0/MIT_6.828/blob/master/lab1/Exercise2.md)** to get related information on how to use GDB to debug the shell)
When we set breakpoint to 0x7c00 as:
```
(gdb) b *0x7c00
Breakpoint 1 at 0x7c00
```
and continue the program, we find the following content:
```
(gdb) c
Continuing.
[   0:7c00] => 0x7c00:	cli    

Breakpoint 1, 0x00007c00 in ?? ()
(gdb) si
[   0:7c01] => 0x7c01:	cld    
0x00007c01 in ?? ()
(gdb) 
[   0:7c02] => 0x7c02:	xor    %eax,%eax
0x00007c02 in ?? ()
(gdb) 
[   0:7c04] => 0x7c04:	mov    %eax,%ds
0x00007c04 in ?? ()
....
....
(gdb) 
[   0:7c2a] => 0x7c2a:	mov    %eax,%cr0
0x00007c2a in ?? ()
(gdb) 
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87d32
0x00007c2d in ?? ()
(gdb) 
[f000:e05b]    0xfe05b:	cmpw   $0xffb8,%cs:(%esi)
0x0000e05b in ?? ()
(gdb) 
[f000:e062]    0xfe062:	jne    0xd241d121
0x0000e062 in ?? ()
(gdb) quit
```
Correspondingly, the output from gdb without any changes should be:
```
(gdb) c
Continuing.
[   0:7c00] => 0x7c00:	cli    

Breakpoint 1, 0x00007c00 in ?? ()
(gdb) si
[   0:7c01] => 0x7c01:	cld    
0x00007c01 in ?? ()
(gdb) si
[   0:7c02] => 0x7c02:	xor    %eax,%eax
0x00007c02 in ?? ()
(gdb) 
[   0:7c04] => 0x7c04:	mov    %eax,%ds
0x00007c04 in ?? ()
(gdb) 
....
....
(gdb) 
[   0:7c2a] => 0x7c2a:	mov    %eax,%cr0
0x00007c2a in ?? ()
(gdb) 
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87c32
0x00007c2d in ?? ()
(gdb) 
The target architecture is assumed to be i386
=> 0x7c32:	mov    $0x10,%ax
0x00007c32 in ?? ()
(gdb) 
=> 0x7c36:	mov    %eax,%ds
0x00007c36 in ?? ()
(gdb) 
=> 0x7c38:	mov    %eax,%es
0x00007c38 in ?? ()
....
....
```
**By comparing the two chunk of results above, we can easily observe that the code went wrong when it comes to ```0x7c2d```, where ```ljmp 0xb866, 0x87c32``` is called. In the code that is compiled incorrectly, the corresponding code is ```ljmp 0xb866, 0x87d32```**

**As a result, we can consume that the link address in this case refers to the 0x7c00, which is converted to 0x87c32 in this case. If we make it to be something else, it will cause error.**
