# Exercise 5
This part of code is not that difficult. but to understand why we are doing this is very important.

### What is UVPT:
With regards to this [website](https://courses.cs.washington.edu/courses/cse451/16au/labs/uvpt.html), I have some basic idea about UVPT. As a result, we are able to understand the code below:
```
// Permissions: kernel R, user R
kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
```
