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
Also, if the following error information shows up:
```
gdb -n -x .gdbinit
make: gdb: No such file or directory
make: *** [gdb] Error 1
```
Please check the **Environment Setting** part of [README.md](https://github.com/JiananDing0/MIT_6.828/blob/master/README.md) on the first page of this repository.
