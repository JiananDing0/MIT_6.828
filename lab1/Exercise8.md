## Exercise 8
#### 1. Figure out the relationship between ```kern/console.c``` and ```kern/printf.c```
Based on what have been provided in comment of ```kern/printf.c```, the function ```cputchar``` implemented in ```kern/console.c``` is the one related to ```kern/printf.c```. As a result, we should first take a look at the function ```cputchar()```. Here is the code of it.
```
void
cputchar(int c)
{
	cons_putc(c);
}
```
Then we should take a look at cons_putc(c):
```
// output a character to the console
static void
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
```
Then we take a look at all 3 functions respectively:
* Serial_putc:
