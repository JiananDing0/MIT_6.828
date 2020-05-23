## Exercise 2
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


#### Process of booting:
* BIOS(Basic input/output system) is first reached. It located at physical address 0xffff0. It initializes some basic settings such as VGA display. Then it searches for bootable disk.
* Bootable disk has boot sector (512 bytes). A sector is the disk's minimum transfer granularity. When it is find the BIOS will load the 512 bytes to physical address 0x7c00 to 0x7dff.
* The control then passed to boot loader.
* 
