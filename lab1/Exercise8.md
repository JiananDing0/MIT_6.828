## Exercise 8
### 1. Figure out the relationship between ```kern/console.c``` and ```kern/printf.c```
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
```
static void
serial_putc(int c)
{
	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	outb(COM1 + COM_TX, c);
}
```
1. Based on descriptions on [StackOverflow](https://stackoverflow.com/questions/27775517/why-do-we-need-to-delay-when-sending-char-to-serial-port), the ```delay``` function keep reads from port ```0x84```. This operation itself is not meaningful. However, this read operation will consume cpu cycles, which causes delay.
2. With reagards to [Wikipedia](https://wiki.osdev.org/Serial_Ports), we find the following example function: 
```
int is_transmit_empty() {
   return inb(PORT + 5) & 0x20;
}
```
	We can figure out the usage of ```!(inb(COM1 + COM_LSR) & COM_LSR_TXRDY)``` based on the function above. We can determine whether the transmit is empty or not by using it. When it is not empty, ```!(inb(COM1 + COM_LSR) & COM_LSR_TXRDY)``` = 1, 0 otherwise. As a result, the for-loop will execute **at least** 12000 times to wait for the transmit to become empty.  
3. ```outb(COM1 + COM_TX, c)``` is the same as ```outb(0x3F8, c)```. Based on the code below, we can regard this as write a single character.
```
void write_serial(char a) {
   while (is_transmit_empty() == 0);
 
   outb(PORT,a);
}
```
  
* lpt_putc:
* cga_putc:
