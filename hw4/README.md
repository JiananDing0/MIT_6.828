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

### Part Two
Two solutions are available for this part. One of them might disobey the rule of the homework but it still works.
1. This solution copies code from allocuvm, just like the description of this homework said.
```
// Lazy allocation first
if (tf->trapno == T_PGFLT) {
  uint a = PGROUNDDOWN(rcr2());
  for(; a < myproc()->sz; a += PGSIZE){
    char *mem = kalloc();
    if(mem == 0){
      panic("out of memory\n");
    }
    memset(mem, 0, PGSIZE);
    if(mappages(myproc()->pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      panic("allocuvm out of memory (2)\n");
    }
  }
  return;
}
// In user space, assume process misbehaved.
cprintf("pid %d %s: trap %d err %d on cpu %d "
        "eip 0x%x addr 0x%x--kill proc\n",
        myproc()->pid, myproc()->name, tf->trapno,
        tf->err, cpuid(), tf->eip, rcr2());
myproc()->killed = 1;
```
2. This solution directly calls allocuvm(), which also works.
```
// Lazy allocation first
if (allocuvm(myproc()->pgdir, PGROUNDDOWN(rcr2()), myproc()->sz) < 0) {
  // In user space, assume process misbehaved.
  cprintf("pid %d %s: trap %d err %d on cpu %d "
          "eip 0x%x addr 0x%x--kill proc\n",
          myproc()->pid, myproc()->name, tf->trapno,
          tf->err, cpuid(), tf->eip, rcr2());
  myproc()->killed = 1;
}
```
