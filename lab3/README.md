# Lab 3
### System calls, exceptions and interrupts on x86
##### Interrupt handler:
* In order to process the system call, programs use ```int``` instruction to generate an interrupt.
* In order to raise an exception, the kernel or the program use ```int``` instruction to generate an interrupt.
In other words, once we have our ```interrupt handler```, we are able to handle interrupts, exceptions and system calls. Here, x86 system is able to deal with up to 256 different interrupts, system call is only one possible interrupt among them. All 256 interrupt cases are stored in IDT(interrupt descriptor table).  
**An operating system can use the iret instruction to return from an int instruction. It pops the saved values during the int instruction from the stack, and resumes execution at the saved %eip.**
