## Exercise 1
This lab is far more difficult in comparison to the previous one. We need to implement 5 functions in the first exercise.

#### Overall process:
In terms of initialize the paging and some related functionalities, we have several steps below:
1. Calculate the memory of our system, and convert the number of memory into number of pages by using PGSIZE defined by ourselves.
2. Allocate some pages to store page table directories and page information array for future use.
...
More elaborted description will be listed below:

#### Step 1: Calculate memory
