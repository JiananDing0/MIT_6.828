## Exercise 1

#### Overall process:
In terms of initialize the paging and some related functionalities, we have several steps below:
#### Step 1: Calculate the amount of memory we have in system
In lab 1, a memory layout picture has already been provided. And I think it is necessary to add some information to this picture to make it more clear and matches the information provided by our lab.
```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
+------------------+  <- 0xf0000000 + total amount of RAM
|                  |
|                  |
|  Virtual Memory  |
|                  |
|                  |
+------------------+  <- 0xf0000000 
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
+------------------+  <- 0x00102b84
|    Kernel Code   |
+------------------+  <- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000
```
Basically, everthing happens below the unused memory will be duplicated to virtual memory part, and vice versa. However, in terms of calculating the memory, we only count the space of RAM, which only includes those below the usused. Notice that we use ```KADDR``` function to convert from physical address to kernel virtual address, and use ```PADDR``` function to convert from kernel virtual address back to physical address. You may find the implementations in ```lab/kern/pmap.h```.

#### Step 2: Allocate and initialize directory pages
Now, we are required to allocate some pages. Add some information to the picture we have above:
```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
+------------------+  <- 0xf0000000 + total amount of RAM
|                  |
|                  |
|  Virtual Memory  |
|                  |
|                  |
+------------------+  <- 0xf0000000 
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
It should be not hard by using the function we have implemented in step one. The only thing we want to care about is that the variable ```end[]``` is written in kernel virtual address. We should convert it back to physical address in order to figure out the correct page it belongs to. Also, implementation of ```struct PageInfo``` can be found in ```inc/memlayout.h```.

#### Step 3: Use more powerful ```allocate``` and ```free``` functions for further allocations
This one should be straightforward. 
