## Exercise 10
According to ```obj/kernel/kernel.asm```, we find that the address of ```test_backtrace``` function is 0xF0100040. As a result, we can set breakpoint as ```b *0xf0100040``` and start this exercise.
#### Analyze the process
Based on observation, the first 4 lines of assembly code should be related to registers that involves stack information, because these lines of code modifies the value stored in two stack-related registers. And start from line 5, the code only use the registers but do not modify the values in them.
```
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
```
These lines of code represent the basic steps of how do we deal with function calls in terms of stack. 
1. Push original value in ```%ebp```, the basic address information of the last function, to stack
2. Move the current stack pointer information, which stored in ```%esp```, to ```%ebp``` and overwrite the original value in it. Don't worry, we have just store the original value.
3. Push information in ```%ebx``` to stack, it is usually some parameter passed into the function. Notice that in this process, the value stored in ```%esp``` is continuously renewed. It always points to the top of the stack.
4. Subtract the value in ```%esp``` by 0x14, which means move the top of the stack by 0x14. This operation leave some blank space for sub-functions.
  
  
By using the steps above, we figure out how the ```test_backtrace``` renew the values.
