# Homework 6 explanation

This homework requires us to solve a problem about why the keys disapper. In order to solve this problem, we need to fully understand this code.
* First, we need to know that the function ```__sync_fetch_and_add()``` is same as ```pthread_barrier```. With the help of this function, all threads have to complete the work above the ```barrier``` in order to reach the part below the ```barrier```. This function get rid of the possibility that some threads may reach the ```get``` part before all insertions completed, which causes a miss.
* However, another possibility of the key missing, which is the problem here, is that the ```insertion``` process is not protected. Each ```entry``` element is inserted to a linked list without any protection. So it is possible that several threads link to a same bucket at the same time, which cause problems.
  
The solution is pretty simple, we can add locks to the ```put``` function to make sure all elements are linked correctly. There is no need to add locks to ```get``` function, because it makes no change to the linked list. No protection wouldn't cause problems here.
