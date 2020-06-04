# Exercise 5
This part of code is not that difficult. but to understand why we are doing this is very important.

### What is UVPT:
With regards to this [website](https://courses.cs.washington.edu/courses/cse451/16au/labs/uvpt.html), I have some basic idea about UVPT. As a result, we are able to understand the code below:
```
kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
```
UVPT is the virtual address refers to the page table directory itself. As a result, this line of code is basically set up the directory of the page table itself in the page table directory. It changes the address of ```kern_pgdir``` into physical adddress and store it at position ```PDX(UVPT)``` of the page table. 

### Idea of booting the memory:
According to the code provided, the PGSIZE is set to 4096. Both ```pte_t``` and ```pde_t``` are defined as ```uint32_t```, which occupies 4 bytes each. As a result, we can infer that the **maximum capacity** for both page directory and page tables is **1024**. On the other hand, we can also detect that the maximum amount of pages can be mapped in this page directory is **1024 * 1024 = 1048576**, which is **0x100000** in hex. In other words, the total amount of memory we can map is **0x100000 * PGSIZE = 0x100000000 = 4GB**.  
  
Here is the steps of mapping required by our code:
1. 
