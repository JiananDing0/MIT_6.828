# Explanation on Homework 3

This homework actually requires large amount of code review. Here is some important stuff that needs to be known.
### Basic steps of system call
System calls are not directly executed. Here are the steps of it being executed in xv6
1. An exception will be raised
2. Corresponding system call value will be stored into ```$eax```
3. Function ```syscall(void)``` implemented in ```syscall.c``` is called and the corresponding system function will be found.
4. Execute the system function, this step includes extract the parameters passed with the system call and deal with the parameters to get the results.

### Argument extraction functions
These functions can be found in both ```syscall.c``` and ```sysfile.c```, such as ```argptr``` or ```argint```. Check the comments above those functions to decide which to use.
