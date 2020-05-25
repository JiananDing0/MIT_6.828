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
```
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
	outb(0x378+0, c);
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
```
As we can observe here, the operations in this function are pretty similar to the last one. The difference is that this function uses different ports. But the idea is the same, wait for a bunch of cpu cycles then do output, send the character to corresponding port.
  
* cga_putc:
```
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;

	switch (c & 0xff) {
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
		break;
	case '\t':
		cons_putc(' ');
		cons_putc(' ');
		cons_putc(' ');
		cons_putc(' ');
		cons_putc(' ');
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
	outb(addr_6845 + 1, crt_pos >> 8);
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
```
This function will output the character to CGA/VGA devices, such as the screen of the computer. You can notice something interesting happen here. Notice that ```c & 0xff``` get the first character, nothing else changes. As we can observe, for `\n` case, it increment the position by a whole colomn. For `\t` case, it output a bunch of spaces by using ```cons_puts```.
  
In conclusion, this the ```cputchar``` function output the single character received by the function to many other ports on PC.

### 2. Explain the following code from ```kern/console.c```
```
1      if (crt_pos >= CRT_SIZE) {
2              int i;
3              memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
4              for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
5                      crt_buf[i] = 0x0700 | ' ';
6              crt_pos -= CRT_COLS;
7      }
```
* ```memmove``` function:
Based on [Linux Manpage](http://man7.org/linux/man-pages/man3/memmove.3.html), 3 parameters are **destination** of the movement, **source** of the movement, and **size** of the memory been moved. As a result, we can infer that the move is to overwrite the content that exceed the CRT buffer, move the content backwards to the front.

### 3. Explain the compiling process of the following code:
```
int x = 1, y = 3, z = 4;
cprintf("x %d, y %x, z %d\n", x, y, z);
```
Based on definition of ```cprintf```, the parameters are passed into the funtions as a constant string ```fmt``` and ```...```. The ```...``` expression seems new to me. With regards to the following [webpage](http://www.cplusplus.com/reference/cstdarg/va_start/), I have a better understanding on how does it works.
1. ```va_list``` related functions
	* ```va_start(a, b)```: In this function, ```a``` should be in type ```va_list```, which is a special type for infinite input argument. ```b``` should be the first argument passed into the ```printf``` function. So in case of ```kernel/printf.c```, ```a``` refers to ```ap```, which is a ```va_list``` typed variable that is initialized in ```cprintf``` and further used in ```vcprintf```. ```b``` refers to ```fmt```, which is the first parameter passed into this function.
	* ```va_arg(a, type)```: The main usage of this function is to get the parameter in ```...``` part from ```printf``` function. This function requires 2 parameters. ```a``` is a ```va_list``` typed parameter and ```type``` should be the corresponding type of the input. For example, when ```cprintf("%d, %c", a, b)``` is called, the ```va_arg``` function will be called twice. The first time should be ```va_arg(a, int)``` and the second time should be ```va_arg(a, char)```. This function is frequently called in ```lib/printfmt.c```.
	* ```va_end(a)```: The parameter ```a``` refers to the ```va_list``` typed parameter we frequently used. This function ends the reading process of ```va_start``` and ```va_arg```. When it is called, it means all the arguments passed into ```cprintf``` function have already been correctly received and showed on screen. In that case, the ```va_list``` typed variable is not needed anymore.
2. The whole ```cprintf``` process
Based on what we have discussed above, my understanding to the whole printing process is below:
	1. ```cprintf``` initializes a ```va_list``` typed variable to receive all the parameters after the fixed string.
	2. ```cprintf``` calls ```vcprintf``` function, which passed the following to ```vprintfmt``` function:
		* ```putch```: a function that uses ```cputchar``` function we have just discussed.
		* ```cnt```: local integer variable passed as a reference.
		* ```fmt```: variable represent the content that is going to displayed.
		* ```ap```: the ```va_list``` typed variable.
	3. ```vprintfmt``` function will keep calling ```putch```, which calls ```vcputchar```, output all the characters in the string to different memory and devices by using the ```cons_putc``` function. However, once the "%" character is reached, the function will go to **switch** case, get the value by using ```va_arg``` function from the ```va_list```. Then output those value to corresponding devices or memory by using ```cons_putc```. The function keep doing the same thing until the whole string is went through.
  
### 4. Compile the following code:
```
unsigned int i = 0x00646c72;
cprintf("H%x Wo%s", 57616, &i);
```
We can simply add these lines of code to ```kern/monitor.c``` to compile because that file output the prompt lines. After the compile, we can see the output is ```He110 World```.
* ```57616``` converted to ```e110```  
Based on the code of dealing with ```case x:``` in ```lib/printfmt.c```
```
case 'x':
	num = getuint(&ap, lflag);
	base = 16;
number:
	printnum(putch, putdat, num, base, width, padc);
	break;
```
We can observe that it directly set base to 16, and get the corresponding value from ```va_list``` **ap**. After that, it print the number in base 16 with the help of ```putch``` function and other variables. As we know, ```57626``` is equal to ```0xE110``` in hex. So it seems reasonable to get the output like that.
  
* ```0x00646c72``` converted to ```rld```  
```%s``` means string. In C programming language, string is passed as an array of characters, that explains why we need to use ```&i``` instead of ```i``` directly in the printing statement.  
  
Based on the code of dealing with strings, the program simply read the information bytes by bytes. As a result, ```0x00646c72``` will be converted to `\0`, `d`, `l` and `r`, which is reverse from ```rld``` we have seen. As we have discussed in [Exercise 4](https://github.com/JiananDing0/MIT_6.828/edit/master/lab1/Exercise4), the numbers are stored in **little endien** in our operating system. In fact, the number ```0x00646c72``` is stored as:
```
 ---------------------------------------
|0111|0010|0110|1100|0110|0100|0000|0000|
 ---------------------------------------
|   7|   2|   6|   c|   6|   4|   0|   0|
```
  
As a result, what we see is `r`, `l`, `d` and `\0` instead of `\0`, `d`, `l` and `r`. Little endien **will not** influence the actual value of variables, it is just a different storage method.
