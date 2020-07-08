# Homework 6 explanation

This homework requires us to solve a problem about why the keys disapper. In order to solve this problem, we need to fully understand this code.
* First, we need to know that the function ```__sync_fetch_and_add()``` is same as ```pthread_barrier```. With the help of this function, all threads have to complete the 
