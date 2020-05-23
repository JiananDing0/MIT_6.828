## Exercise 6
Before we start this exercise, I am going to go through the code at ```boot/main.c``` to better understand this lab. The link to corresponding code is [here](https://github.com/JiananDing0/MIT_6.828/blob/master/lab1/boot/main.c). 

### Understand ```readsect``` function (line 106-124):
First, according to the parameters passed into this function, we know that ```dst``` is the physical address the sectors will be copied to, and ```offset``` is the value represent the number of sectors from the start of kernel file, where the origin of the files come from. 
As we can observe, there is a bunch of ```outb``` functions from line 112 to line 117
* ```outb``` function: Based on descriptions from [Linux Manual Page](http://man7.org/linux/man-pages/man2/outb.2.html), the definition of ```outb``` function can be either ```void outb(unsigned char value, unsigned short int port)``` or ```void outb(unsigned short int port, unsigned char value)```. In this case, the latter seems to be more reasonable.
However, this part still seems confusing. With regards to the following [page](https://wiki.osdev.org/ATA_PIO_Mode), I find a chunk of process description which is pretty similar to the process that have been done in ```boot/main.c```.
```
An example of a 28 bit LBA PIO mode read on the Primary bus:
Send 0xE0 for the "master" or 0xF0 for the "slave", ORed with the highest 4 bits of the LBA to port 0x1F6: outb(0x1F6, 0xE0 | (slavebit << 4) | ((LBA >> 24) & 0x0F))
Send a NULL byte to port 0x1F1, if you like (it is ignored and wastes lots of CPU time): outb(0x1F1, 0x00)
Send the sectorcount to port 0x1F2: outb(0x1F2, (unsigned char) count)
Send the low 8 bits of the LBA to port 0x1F3: outb(0x1F3, (unsigned char) LBA))
Send the next 8 bits of the LBA to port 0x1F4: outb(0x1F4, (unsigned char)(LBA >> 8))
Send the next 8 bits of the LBA to port 0x1F5: outb(0x1F5, (unsigned char)(LBA >> 16))
Send the "READ SECTORS" command (0x20) to port 0x1F7: outb(0x1F7, 0x20)
Wait for an IRQ or poll.
Transfer 256 16-bit values, a uint16_t at a time, into your buffer from I/O port 0x1F0. (In assembler, REP INSW works well for this.)
Then loop back to waiting for the next IRQ (or poll again -- see next note) for each successive sector.
```
As a result, we can temporarily regard this part as something fixed in hardware programming, we just send signals and call functions to do that. Overall, the main point of this chunk of code is to get the sectors loaded. 

### Understand ```readseg``` function (line 72-96):


### Understand ```bootmain``` function (line 39-67):
This function can be easily understand by the comment above it.

