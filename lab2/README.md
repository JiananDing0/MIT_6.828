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
As we know, virtual address mapping is **not** to divide the physical address into several parts and mirroring what was happening at low memory into high memory. The actual virtual address mapping is to convert the whole physical memory into virtual memory. The size of virtual memory should be the same as physical memory, which is 4GB in this case. With the help of mapping, we want to access or allocate any free page at anytime. In order to do that, we need to understand the following things.
  
Before start, we should first know, **xv6 sets up segments to make virtual and linear addresses always identical**.
  
##### Figure 5-9: Page translation process
![](image/Figure5-9.png)  
  
This picture effeciently explain how is a two-level page table looks like. This picture named the 3 components of virtual address as DIR, PAGE and OFFSET. Correspondingly, the first level of the page table is called page directories. The second level is called page tables. The steps of page translation is:  
1. Use the DIR part, which is the first 10 bits of the linear address (also called virtual address in our lab) to find the page table address.  
2. Use the PAGE part, which corresponds to 11-20 bits of the linear address to find the physical address without actual offset.  
3. Add the OFFSET part of our linear address to the physical address without offset we just got in step 2. We get out final physical address.  However, this part is not necessary in our lab, because we use pages, and page size is 4096, which means the last 12 bits of all our physical addresses is 0.
  
#### Figure 5-13: Page directory and page table structures.
![](image/Figure5-13.png)  
  
This picture provide more details on this process. Make it easier to implement in code.  
1. According to the picture, the abbreviation of page directory is PDE. We should relate this information to ```pde_t```, which is a variable type frequently shows up in our lab code.  
2. According to the picture, the abbreviation of page table is PTE. We can also relate this information to ```pte_t```, which is another variable type shows up in our lab code.  
3. Both PDE and PTE are stored as arrays. We can use PDE[index] to find a specific element stored in it. By definition, this "element" should be the address of a page table. We can also do similar thing at page table arrays to find the physical address.  
4. Some information not covered in picture: the number of entries in PDE is 1024, which means we have 1024 PTEs, and each PTE will also have 1024 entries, each corresponds to a physical page. So **1024 * 1024 * PGSIZE = 4GB** in total.

### Exercise 5:
After implementation of functionaloties such as insertion or remove pages, the next thing is to initialize some fixed pages , such as pages to store page directories, page tables, or kernel codes in virtual memory. 
* **Page directory**: this intialization has been done by provided code ```kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P``` at line 151 of ```kern/pmap.c```.
* **Page table entries**: 1024 pages are required to construct the map. We need to map from ```PADDR(pages)``` to ```UPAGES```. This information can be found in ```inc/memlayout.h```.
* **Kernel stack**: Kernel stack is the stack only accessible by kernel. We need 8 pages to map the kernel from ```PADDR(bootstack)``` to ```KSTACKTOP - KSTKSIZE```. This information can be found in ```inc/memlayout.h```.
* **Kernel codes**: Kernel code refers to the code we analyze in lab 1. The lab requires us to allocate ```2^32 - KERNBASE``` bytes of memory from ```KERNBASE``` to ```0xFFFFFFFF (4GB - 1)```. This information can be found in ```inc/memlayout.h```.
  
#### Premission of page table entries.
Based on content of lecture 4, when ```PTE_W``` of the entry is set to 1, kernel will be allowed to access this entry. When ```PTE_U``` of the entry is set to 1, users will be allowed to access the entry. When ```PTE_P``` is set to 1, it represent the information stored in this entry is valid.
