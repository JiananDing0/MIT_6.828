## Exercise 9
Before we start, I will first go through the overall logic on how is the code compiles. According to ```kern/entry.S```. which is the very first file reached by our program when our kernel is loaded, the program first do a bunch of things. At the end of this file, it calls the function ```i386_init``` located in file ```kern/init.c```.
  
We first take a look at the C file. 
```
void
i386_init(void)
{
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();

	cprintf("6828 decimal is %o octal!\n", 6828);

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
}
```
With the help of comments above each line of code, we can easily understand that ```cons_init``` initializes the ```cprintf``` thing we have discussed in [Exercise 8](https://github.com/JiananDing0/MIT_6.828/edit/master/lab1/Exercise8.md). Then it loads a test function for stacks of this operating system, as we listed below: 
```
// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
	cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
}
```
And mon_backtrace is something we need to implement.  
  
After that, it finally calls a function ```monitor```, which corresponds to the ```k>``` thing we find when the system loads. At this point, the whole system has been activated and no other thing is required. 

#### Close analyze to how stack is boot:
After analyze the whole process, we should take a close look on how the stack is booted. 
##### First, the code refresh the value stored in ```%esp``` and ```%ebp``` by using the following code:
```
# Clear the frame pointer register (EBP)
# so that once we get into debugging C code,
# stack backtraces will be terminated properly.
movl	$0x0,%ebp			# nuke frame pointer

# Set the stack pointer
movl	$(bootstacktop),%esp
```
Here, we can observe that 0 is stored to ```%ebp```. On the next line, ```$bootstacktop```, which is an unknown value for now, is stored to ```%esp```. 
* 	```%ebp```: EBP is the base pointer from current stackframe.
* 	```%esp```: ESP is the current stack pointer.
  
Also, we know that the rule of stack and related ideas are all fixed in CPU design. In other words, once we initialize the values for ```%ebp``` and ```%esp```, the system will automatically deal with the following jobs: adding or removing content from the stack as different function call happens.
