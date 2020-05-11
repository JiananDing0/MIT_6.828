# Lab 1 Explanation
This lab introduces the process of booting a PC. Please make sure you have read through the text and understand it.

### Excecise 2:
```make gdb``` actually requires us to start 2 terminal pages. We need first run ```make qemu-gdb``` in one terminal page, until we see the following information shows up on the screen:
```
***
*** Now run 'make gdb'.
***
```
After that, we can then run ```make gdb``` on the other terminal page, and follow the instructions to explore.
Also, if the following error information shows up when you try to run "make gdb":
```
gdb -n -x .gdbinit
make: gdb: No such file or directory
make: *** [gdb] Error 1
```
Please check the **Environment Setting** part of [README.md](https://github.com/JiananDing0/MIT_6.828/blob/master/README.md) on the first page of this repository.

### Exercise 3:
According to the problem, we need to analyze the assembly code in boot.S and main.c under the __boot__ folder. 
#### boot.S
Analyze the code below:
```
11  # Enable A20:
12  #   For backwards compatibility with the earliest PCs, physical
13  #   address line 20 is tied low, so that addresses higher than
14  #   1MB wrap around to zero by default.  This code undoes this.
15 seta20.1:
16  inb     $0x64,%al               # Wait for not busy
17  testb   $0x2,%al
18  jnz     seta20.1

19  movb    $0xd1,%al               # 0xd1 -> port 0x64
20  outb    %al,$0x64

21 seta20.2:
22  inb     $0x64,%al               # Wait for not busy
23  testb   $0x2,%al
24  jnz     seta20.2

25  movb    $0xdf,%al               # 0xdf -> port 0x60
26  outb    %al,$0x60

```
##### Assembly code:
* ```inb```: Composed of **in** and **b**, **in** means input from port. 
* ```testb```: Composed of **test** and **b**, **test** means do bitwise AND to the two numbers. set Zero Flag (ZF) to 1 if the result is 0 and set to 0 otherwise.
* ```jnz```: Same as ```jne```, jumps to the specified location if the Zero Flag (ZF) is cleared (0).
##### Special numbers: (Referenced from [website](https://www.win.tue.nl/~aeb/linux/kbd/scancodes-11.html))
* ```0x64```: Keyboard controller
```
The keyboard controller has an 8-bit status register. It can be inspected by the CPU by reading port 0x64.
(Typically, it has the value 0x14: keyboard not locked, self-test completed.)
* Bit 7: Parity error
0: OK. 1: Parity error with last byte.
* Bit 6: Timeout
0: OK. 1: Timeout. On PS/2 systems: General timeout. On AT systems: Timeout on transmission from keyboard to keyboard controller. Possibly parity error (in which case both bits 6 and 7 are set).
* Bit 5: Auxiliary output buffer full
On PS/2 systems: Bit 0 tells whether a read from port 0x60 will be valid. If it is valid, this bit 5 tells what data will be read from port 0x60. 0: Keyboard data. 1: Mouse data.
On AT systems: 0: OK. 1: Timeout on transmission from keyboard controller to keyboard. This may indicate that no keyboard is present.
* Bit 4: Keyboard lock
0: Locked. 1: Not locked.
* Bit 3: Command/Data
0: Last write to input buffer was data (written via port 0x60). 1: Last write to input buffer was a command (written via port 0x64). (This bit is also referred to as Address Line A2.)
* Bit 2: System flag
Set to 0 after power on reset. Set to 1 after successful completion of the keyboard controller self-test (Basic Assurance Test, BAT). Can also be set by command (see below).
* Bit 1: Input buffer status
0: Input buffer empty, can be written. 1: Input buffer full, don't write yet.
* Bit 0: Output buffer status
0: Output buffer empty, don't read yet. 1: Output buffer full, can be read. (In the PS/2 situation bit 5 tells whether the available data is from keyboard or mouse.) This bit is cleared when port 0x60 is read.
```
* ```0xd1```: Write output port
* ```0xdf```: Enable A20 address line (protected mode)
##### Conclusion:
So basically the first part of both 20.1 and 20.2 do the same thing. Check whether the input buffer of keyboard is full or not. If free, then continue to write either ```0xd1``` or ```0xdf```, if not, wait until it is free. Notice that ```0xd1``` can be regarded as a preparation for ```0xdf```.
----------------------------------------------------- --------------------------------------------------------------
Then we analyze the code below:
```
# Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses
  # identical to their physical addresses, so that the
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
 
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
```
##### Assembly code:
* ```lgdt````: Store Global Description Table (GDT) information 
* ```ljmp    $PROT_MODE_CSEG, $protcseg```: Switches processor into 32-bit mode.
##### Conclusion:
The processor start executing code in 32bit mode when ```ljmp    $PROT_MODE_CSEG, $protcseg``` is processed.

### [Exercise 4](https://github.com/JiananDing0/MIT_6.828/edit/master/lab1/Exercise4):
* In order to solve this problem, we should first create a ```Makefile``` with the basic c++ command ```gcc pointers.c -o pointers```in order to compile the *pointer.c* file.
* After it compiles, we can directly execute the file by execute ```./pointers"``` and the following content shows up:
```
1: a = 0x7ffee62f18a0, b = 0x7ff560405860, c = 0x7ffee62f1908
2: a[0] = 200, a[1] = 101, a[2] = 102, a[3] = 103
3: a[0] = 200, a[1] = 300, a[2] = 301, a[3] = 302
4: a[0] = 200, a[1] = 400, a[2] = 301, a[3] = 302
5: a[0] = 200, a[1] = 128144, a[2] = 256, a[3] = 302
6: a = 0x7ffee62f18a0, b = 0x7ffee62f18a4, c = 0x7ffee62f18a1
```

#### 1. Initialization:
```
int a[4];
int *b = malloc(16);
int *c;
int i;
```
In this part, we can easily observe that variable ```a``` and variable ```b``` should correspond to the same amount of memory occupation: 16 bytes, which is 128 bits; variable ```c``` is an unintialized pointer. In addition, both ```a``` and ```c``` should be stored in stack as local variables, ```b``` should be stored in heap.

#### 2. Code corresponds to the first printing statement is:
```
printf("1: a = %p, b = %p, c = %p\n", a, b, c);
```
which results in:
```
1: a = 0x7ffee62f18a0, b = 0x7ff560405860, c = 0x7ffee62f1908
```
In this part, we can observe ```c - a``` is 0x68

#### 3. Code corresponds to the second printing statement is:
```
c = a;
for (i = 0; i < 4; i++)
    a[i] = 100 + i;
c[0] = 200;
printf("2: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
2: a[0] = 200, a[1] = 101, a[2] = 102, a[3] = 103
```
This part seems to be normal. ```c=a```result in c and a point to a same array sturcture. As a result, we can directly change value in array ```a``` by using ```c[i] = n```

#### 4. Code corresponds to the third printing statement is:
```
c[1] = 300;
*(c + 2) = 301;
3[c] = 302;
printf("3: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
3: a[0] = 200, a[1] = 300, a[2] = 301, a[3] = 302
```
This part provide some useful application of pointer: 
* ```c[i]```is the same as ```i[c]```
* Pointer can be increamented in the unit of its data type. For example```c + 2``` result in increament of 8 because c is an integer pointer.

#### 5. Code corresponds to the forth printing statement is:
```
c = c + 1;
*c = 400;
printf("4: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
4: a[0] = 200, a[1] = 400, a[2] = 301, a[3] = 302
```
No explanations required here

#### 6. Code corresponds to the fifth printing statement is:
```
c = (int *) ((char *) c + 1);
*c = 500;
printf("5: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
5: a[0] = 200, a[1] = 128144, a[2] = 256, a[3] = 302
```
No explanations required here

#### 7. Code corresponds to the sixth printing statement is:
```
b = (int *) a + 1;
c = (int *) ((char *) a + 1);
printf("6: a = %p, b = %p, c = %p\n", a, b, c);
```
which results in:
```
6: a = 0x7ffee62f18a0, b = 0x7ffee62f18a4, c = 0x7ffee62f18a1
```
No explanations required here
