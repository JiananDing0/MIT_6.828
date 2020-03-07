# The UNIX Operating System

### A Unix system is made up of 3 layers:

  - Kernel: The center of the system that controls the resourses of the machine
  - Shell: Wrapped around the kernel. An interface between users and the kernel
  - Utilities: Programs build by people based on the system functions

### Advantages of UNIX System:

* Pipelining
> A bunch of programs connected end-to-end. Data flow through the programs for the final result. The system looks at the synchronization to make sure the data go through the process. However, the programs themselves cannot recognize this.
* File System
> A hierarchy of directories. Directory is basically a file that either contains other directories or files. The whole thing goes on recursively. Notice that even devices connect to the computer, such as keyboard, are represented as files.
* Spline
> Users are able to store a bunch of commands into a file and request the shell to run the commands inside that specific file, which safe time for repetitive works
* Input/Output Redirection
> Instead input from keyboard and output to screen, UNIX are able to receive input from a file and redirect the output into another file. This function is handled by the shell.
 
