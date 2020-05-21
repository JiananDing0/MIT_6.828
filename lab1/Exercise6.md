## Exercise 6
Before we start this exercise, I am going to go through the code at ```boot/main.c``` to better understand this lab. The link to corresponding code is [here](https://github.com/JiananDing0/MIT_6.828/blob/master/lab1/boot/main.c). 

### Understand ```readsect``` function (line 106-124):
As we can observe, there is a bunch of ```outb``` functions from line 112 to line 117
* ```outb``` function: Based on descriptions from [Linux Manual Page](http://man7.org/linux/man-pages/man2/outb.2.html), the definition of ```outb``` function can be either ```void outb(unsigned char value, unsigned short int port)``` or ```void outb(unsigned short int port, unsigned char value)```. In this case, the latter seems to be more reasonable.
