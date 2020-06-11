# Explanations on Homework 4

### Part One
After we removed the ```growproc``` part of the code and keep the size changes, the code becomes:
```
int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  myproc()->sz += n;
  return addr;
}
```
Now the errors shows up. The reason of errors is that some commands typed in by user may requires ```fork``` and ```exec```. And ```exec``` requires the operating system to allocate some spaces. If the ```growproc()``` function is commented out, the only difference is that the ```allocuvm()``` function will never be called. We can find the definition of ```allocuvm()``` function in ```vm.c```. This function do a bunch of stuff such as map the virtual pages in page table, zero out the memory of the physical page and so on. As a result, if this code is never executed, then the page table entry will be set as invalid, which cause page fault. 
