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

#### Step 2: Allocate and initialize directory pages

#### Step 3: Use more powerful ```allocate``` and ```free``` functions for further allocations
Information about ```struct PageInfo``` can be found in ```inc/memlayout.h```
