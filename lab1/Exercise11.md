## Exercise 11

#### Get ESP values:
First trick in this lab can be concluded from [Exercise 10](https://github.com/JiananDing0/MIT_6.828/edit/master/lab1/Exercise10.md). 
* As we can observe, every time we call a new function, ```push %ebp``` will be executed first. In other words, **all** the ```ebp``` information are pushed on the stack when new function is called. 
* Right after the first command, ```mov %esp,%ebp``` is executed. In other words, ```%ebp``` will be overwritten by the new top address of the stack. At this moment, the first value on top of the stack is the old ```%ebp``` value we just pushed into the stack.
* Finally, we can conclude that when we finally reach ```mon_backtrace```, the information stored in ```%ebp``` will directly point to the old ```ebp``` address. And when we dereference the old ```ebp``` address, we get the previous address. Write a while-loop until we read in 0. Because the very first ```%ebp``` value we pushed into the stack is 0. 

#### Get EIP values: 
With regards to [Stackoverflow](https://stackoverflow.com/questions/33685146/x86-does-call-instruction-always-push-the-address-pointed-by-eip-to-stack), we know that ```EIP``` value can be find 4 bytes away from ```EBP```.

#### Get AGR values:
Based on lab description, we can find the 5 arguments **before function calls**. In other words, we can find them at postion ```%ebp``` + 8, ```%ebp``` + 12, ```%ebp``` + 16, ```%ebp``` + 20 and ```%ebp``` + 24.
