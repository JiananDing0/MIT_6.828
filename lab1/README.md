# Lab 1 Explanation
This lab introduces the process of booting a PC. Please make sure you have read through the text and understand it.

### Common problems
In excecise 2, ```make gdb``` actually requires us to start 2 terminal pages. We need first run ```make qemu-gdb``` in one terminal page, until we see the following information shows up on the screen:
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
```
Take a look at the lab tools guide, especially the section on GDB commands. Even if you're familiar with GDB, this includes some esoteric GDB commands that are useful for OS work.

Set a breakpoint at address 0x7c00, which is where the boot sector will be loaded. Continue execution until that breakpoint. Trace through the code in boot/boot.S, using the source code and the disassembly file obj/boot/boot.asm to keep track of where you are. Also use the x/i command in GDB to disassemble sequences of instructions in the boot loader, and compare the original boot loader source code with both the disassembly in obj/boot/boot.asm and GDB.

Trace into bootmain() in boot/main.c, and then into readsect(). Identify the exact assembly instructions that correspond to each of the statements in readsect(). Trace through the rest of readsect() and back out into bootmain(), and identify the begin and end of the for loop that reads the remaining sectors of the kernel from the disk. Find out what code will run when the loop is finished, set a breakpoint there, and continue to that breakpoint. Then step through the remainder of the boot loader.
```
