# Lab 4
Lab 4 introduce a brand new idea of multiprocessing. It is a bit difficult to fully understand it. Here provides some personal interpretation of this lab.
  
  
### Part A: Multiprocessor Support and Cooperative Multitasking
Part A of this lab introduces some important prerequisite for multiprocessing, such as the LAPIC units, which are responsible for delivering interrupts throughout the system.
##### Struct ```mpconf``` and zero length array
An interesting structure ```mpconf``` implemented in ```kern/mpconfig.c``` uses a 0-sized ```uint8_t``` array ```entries```. In order to figure out the reason of using it, I have found an [article](https://www.forbes.com/sites/quora/2013/05/14/what-is-the-advantage-of-using-zero-length-arrays-in-c/#50b05774213a) online and here is the explanation:
```
An astute reader is now asking, Why not just return a pointer to an email body of dynamic length? If doing so is possible, that is absolutely preferred. Indeed, 
zero-length arrays are useful only in cases where you have a large structure, which contains a field of dynamic length, and you need to share that structure across 
program or even computer boundaries. For example, I used a zero-length array in the Linux kernel's implementation of inotify. It was actually the first zero-length 
array I had ever seen!
************************
struct inotify_event {
  int wd;
  uint32_t mask;
  uint32_t cookie;
  uint32_t len;
  char name[0];
};
************************
This structure represents an inotify event, which is an action such as was written to and a target filename such as /home/rlove/wolf.txt. You can see the problem: 
How big should I have made name? Filenames can be any size. Worse, filesystems vary in their maximum filename length ( PATH_MAX isn't a limit, just a lazy man's 
constant). Now, if I was only returning the filename, I could have simply returned a dynamically-allocated char *. But I had to return this giant structure. 
Moreover, I was implementing a system call, so I couldn't allocate pointers inside of the structure, since they wouldn't point at memory in the user's address 
space. My options were limited. A zero-length array was a perfect solution.
```

##### Answer to question 1 and 2
* Question 1
In ```boot/boot.s```, we have:
```
  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment

  # Enable A20:
  # ....
  # A bunch of code skipped

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
 ```
 In ```kern/mpentry.S```, we have:
 ```
  xorw    %ax, %ax
  movw    %ax, %ds
	movw    %ax, %es
	movw    %ax, %ss

	lgdt    MPBOOTPHYS(gdtdesc)
	movl    %cr0, %eax
	orl     $CR0_PE, %eax
	movl    %eax, %cr0
 ```
 So we can easily figure out that the macro is designed to calculate the new global descriptor table address.
 
