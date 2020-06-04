# Lab 2 Explanation

### Introduction
Most of this lab is about coding, so we just need to understand the idea of virtual memory and mapping to complete this lab. You may easily search for "Why we use virtual memory" or "How to map from physical address to virtual address" from Internet. So I will not explain this part. However, some differences exist between our OS and the most recent OS:
* In our OS, there is no MMU(Memory Management Unit) exist that help us to do memory mapping. As a result, we have to implement that part by ourselves. 
* Based on what we have in lab 1, the total amount of physical memory we have for our OS is 4GB. 
  
In lab 1, we have already implemented a kind of virtual address mapping, which automatically increment our physical address by KERNBASE to get the virtual address. However, it is not a complete mapping. This kind of mapping is only executable for the first 256MB memory (from 0x0 to 0xFFFFFFF). Once the physical memory exceeds this limit, we will get a number greater than 4G, which is not a valid address anymore.

### Exercise 1: Mark the physical pages in physical memory
Exercise 1 introduce the idea of paging. In order to do that, we should first mark the physical memories that are been used in our ```struct PageInfo``` array. Implementation of ```struct PageInfo``` can be found in ```inc/memlayout.h```. Based on the image provided in lab 1, I have made a more clear physical memory layout to help understanding the first task. 
```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  <- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  <------------------------
|   PageInfo for   |                          |
|     all pages    |                          |
+------------------+                          |
| Page Directories |                          |
+------------------+  <- 0x00102b84           |
|    Kernel Code   |                          |
+------------------+  <- 0x00100000 (1MB)     | (This part should be marked as used)
|     BIOS ROM     |                          |
+------------------+  <- 0x000F0000 (960KB)   |
|  16-bit devices, |                          |
|  expansion ROMs  |                          |
+------------------+  <- 0x000C0000 (768KB)   |
|   VGA Display    |                          |
+------------------+  <- 0x000A0000 (640KB)  <-
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00001000 (4KB) <----
|                  |                          | (This part should be marked as used)
+------------------+  <- 0x00000000  <---------
```
Variable ```end[]``` marks the end of kernel code. However, it is written in kernel virtual address. We should convert it back to physical address to use it. 

### Exercise 2-4: Build the paging and mapping system:
As we know, virtual address mapping is **not** to divide the physical address into several parts and mirroring what was happening at low memory into high memory, that action is meaningless. The actual virtual address mapping is to convert the whole physical memory into virtual memory. The size of virtual memory should be the same as physical memory, which is 4GB in this case. We are able to map any free pages at any time. 
