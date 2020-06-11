# Homework 2 explanations:

* Any changes happens in child process will never influence the parent process. Including the modifications on file descriptors. As a result, remember to use ```fork``` every time you want to modifies the file descriptor.
