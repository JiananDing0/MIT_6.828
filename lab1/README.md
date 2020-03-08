# Lab 1 Explanation
This lab introduces the process of booting a PC. Please make sure you have read through the text and understand it.

### Common problems
#### Excecise 2:
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

#### Exercise 3:
According to the problem, we need to analyze the assembly code in boot.S and main.c under the __boot__ folder. 
##### boot.S
Analyze the code below:
```
seta20.1:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.1

```
```inb```: Composed of **in** and **b**, **in** means input from port. Here, 0x64 represent:(Referenced from [website](https://www.win.tue.nl/~aeb/linux/kbd/scancodes-11.html))
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
```testb```: Composed of **test** and **b**, **test** means do bitwise AND to the two numbers. 
