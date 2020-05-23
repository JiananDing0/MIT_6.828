## Exercise 3:
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
* ```lgdt```: Store Global Description Table (GDT) information 
* ```ljmp    $PROT_MODE_CSEG, $protcseg```: Switches processor into 32-bit mode.
##### Conclusion:
* The processor start executing code in 32bit mode when ```ljmp    $PROT_MODE_CSEG, $protcseg``` is processed. At physical address 0x7c2d.
* According to what we have discussed in exercise 2, we can figure out that the kernel will be loaded in ```boot/main.c```.
