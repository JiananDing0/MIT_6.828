
obj/user/testbss:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 10 0e 80 00 	movl   $0x800e10,(%esp)
  800041:	e8 fa 01 00 00       	call   800240 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 8b 0e 80 	movl   $0x800e8b,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 a8 0e 80 00 	movl   $0x800ea8,(%esp)
  800070:	e8 d3 00 00 00       	call   800148 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 30 0e 80 	movl   $0x800e30,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 a8 0e 80 00 	movl   $0x800ea8,(%esp)
  8000ba:	e8 89 00 00 00       	call   800148 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 58 0e 80 00 	movl   $0x800e58,(%esp)
  8000ce:	e8 6d 01 00 00       	call   800240 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 b7 0e 80 	movl   $0x800eb7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 a8 0e 80 00 	movl   $0x800ea8,(%esp)
  8000f4:	e8 4f 00 00 00       	call   800148 <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	8b 45 08             	mov    0x8(%ebp),%eax
  800105:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800108:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  80010f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7e 08                	jle    80011e <libmain+0x22>
		binaryname = argv[0];
  800116:	8b 0a                	mov    (%edx),%ecx
  800118:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80011e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 0a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80012a:	e8 05 00 00 00       	call   800134 <exit>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 07 0a 00 00       	call   800b4d <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800159:	e8 41 0a 00 00       	call   800b9f <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 d8 0e 80 00 	movl   $0x800ed8,(%esp)
  80017b:	e8 c0 00 00 00       	call   800240 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 50 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 a6 0e 80 00 	movl   $0x800ea6,(%esp)
  800196:	e8 a5 00 00 00       	call   800240 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	40                   	inc    %eax
  8001b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 19                	jne    8001d6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001bd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c4:	00 
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 40 09 00 00       	call   800b10 <sys_cputs>
		b->idx = 0;
  8001d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d6:	ff 43 04             	incl   0x4(%ebx)
}
  8001d9:	83 c4 14             	add    $0x14,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800203:	8b 45 08             	mov    0x8(%ebp),%eax
  800206:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021b:	e8 82 01 00 00       	call   8003a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800220:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 d8 08 00 00       	call   800b10 <sys_cputs>

	return b.cnt;
}
  800238:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800246:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	8b 45 08             	mov    0x8(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 87 ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    
	...

0080025c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 3c             	sub    $0x3c,%esp
  800265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800268:	89 d7                	mov    %edx,%edi
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
  800273:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800276:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800279:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027c:	85 c0                	test   %eax,%eax
  80027e:	75 08                	jne    800288 <printnum+0x2c>
  800280:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800283:	39 45 10             	cmp    %eax,0x10(%ebp)
  800286:	77 57                	ja     8002df <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800288:	89 74 24 10          	mov    %esi,0x10(%esp)
  80028c:	4b                   	dec    %ebx
  80028d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800291:	8b 45 10             	mov    0x10(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80029c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a7:	00 
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	e8 06 09 00 00       	call   800bc0 <__udivdi3>
  8002ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c9:	89 fa                	mov    %edi,%edx
  8002cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ce:	e8 89 ff ff ff       	call   80025c <printnum>
  8002d3:	eb 0f                	jmp    8002e4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	89 34 24             	mov    %esi,(%esp)
  8002dc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002df:	4b                   	dec    %ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f f1                	jg     8002d5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fa:	00 
  8002fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800304:	89 44 24 04          	mov    %eax,0x4(%esp)
  800308:	e8 d3 09 00 00       	call   800ce0 <__umoddi3>
  80030d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800311:	0f be 80 fc 0e 80 00 	movsbl 0x800efc(%eax),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031e:	83 c4 3c             	add    $0x3c,%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0e                	jle    80033c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x38>
	else if (lflag)
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 10                	je     800350 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800366:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	3b 50 04             	cmp    0x4(%eax),%edx
  80036e:	73 08                	jae    800378 <sprintputch+0x18>
		*b->buf++ = ch;
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	88 0a                	mov    %cl,(%edx)
  800375:	42                   	inc    %edx
  800376:	89 10                	mov    %edx,(%eax)
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800380:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800383:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800387:	8b 45 10             	mov    0x10(%ebp),%eax
  80038a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 02 00 00 00       	call   8003a2 <vprintfmt>
	va_end(ap);
}
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	56                   	push   %esi
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 4c             	sub    $0x4c,%esp
  8003ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b1:	eb 12                	jmp    8003c5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b3:	85 c0                	test   %eax,%eax
  8003b5:	0f 84 6b 03 00 00    	je     800726 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c5:	0f b6 06             	movzbl (%esi),%eax
  8003c8:	46                   	inc    %esi
  8003c9:	83 f8 25             	cmp    $0x25,%eax
  8003cc:	75 e5                	jne    8003b3 <vprintfmt+0x11>
  8003ce:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003d9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	eb 26                	jmp    800412 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ef:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003f3:	eb 1d                	jmp    800412 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003fc:	eb 14                	jmp    800412 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800401:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800408:	eb 08                	jmp    800412 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80040a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80040d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	0f b6 06             	movzbl (%esi),%eax
  800415:	8d 56 01             	lea    0x1(%esi),%edx
  800418:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041b:	8a 16                	mov    (%esi),%dl
  80041d:	83 ea 23             	sub    $0x23,%edx
  800420:	80 fa 55             	cmp    $0x55,%dl
  800423:	0f 87 e1 02 00 00    	ja     80070a <vprintfmt+0x368>
  800429:	0f b6 d2             	movzbl %dl,%edx
  80042c:	ff 24 95 8c 0f 80 00 	jmp    *0x800f8c(,%edx,4)
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800436:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80043e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800442:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800445:	8d 50 d0             	lea    -0x30(%eax),%edx
  800448:	83 fa 09             	cmp    $0x9,%edx
  80044b:	77 2a                	ja     800477 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80044e:	eb eb                	jmp    80043b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045e:	eb 17                	jmp    800477 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800460:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800464:	78 98                	js     8003fe <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800469:	eb a7                	jmp    800412 <vprintfmt+0x70>
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800475:	eb 9b                	jmp    800412 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800477:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047b:	79 95                	jns    800412 <vprintfmt+0x70>
  80047d:	eb 8b                	jmp    80040a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800483:	eb 8d                	jmp    800412 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049d:	e9 23 ff ff ff       	jmp    8003c5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 50 04             	lea    0x4(%eax),%edx
  8004a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	79 02                	jns    8004b3 <vprintfmt+0x111>
  8004b1:	f7 d8                	neg    %eax
  8004b3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b5:	83 f8 06             	cmp    $0x6,%eax
  8004b8:	7f 0b                	jg     8004c5 <vprintfmt+0x123>
  8004ba:	8b 04 85 e4 10 80 00 	mov    0x8010e4(,%eax,4),%eax
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	75 23                	jne    8004e8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c9:	c7 44 24 08 14 0f 80 	movl   $0x800f14,0x8(%esp)
  8004d0:	00 
  8004d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 9a fe ff ff       	call   80037a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e3:	e9 dd fe ff ff       	jmp    8003c5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ec:	c7 44 24 08 1d 0f 80 	movl   $0x800f1d,0x8(%esp)
  8004f3:	00 
  8004f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fb:	89 14 24             	mov    %edx,(%esp)
  8004fe:	e8 77 fe ff ff       	call   80037a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800506:	e9 ba fe ff ff       	jmp    8003c5 <vprintfmt+0x23>
  80050b:	89 f9                	mov    %edi,%ecx
  80050d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800510:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 04             	lea    0x4(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 30                	mov    (%eax),%esi
  80051e:	85 f6                	test   %esi,%esi
  800520:	75 05                	jne    800527 <vprintfmt+0x185>
				p = "(null)";
  800522:	be 0d 0f 80 00       	mov    $0x800f0d,%esi
			if (width > 0 && padc != '-')
  800527:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052b:	0f 8e 84 00 00 00    	jle    8005b5 <vprintfmt+0x213>
  800531:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800535:	74 7e                	je     8005b5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053b:	89 34 24             	mov    %esi,(%esp)
  80053e:	e8 8b 02 00 00       	call   8007ce <strnlen>
  800543:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800546:	29 c2                	sub    %eax,%edx
  800548:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80054b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80054f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800552:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800555:	89 de                	mov    %ebx,%esi
  800557:	89 d3                	mov    %edx,%ebx
  800559:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	eb 0b                	jmp    800568 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80055d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800561:	89 3c 24             	mov    %edi,(%esp)
  800564:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	4b                   	dec    %ebx
  800568:	85 db                	test   %ebx,%ebx
  80056a:	7f f1                	jg     80055d <vprintfmt+0x1bb>
  80056c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80056f:	89 f3                	mov    %esi,%ebx
  800571:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800577:	85 c0                	test   %eax,%eax
  800579:	79 05                	jns    800580 <vprintfmt+0x1de>
  80057b:	b8 00 00 00 00       	mov    $0x0,%eax
  800580:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800583:	29 c2                	sub    %eax,%edx
  800585:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800588:	eb 2b                	jmp    8005b5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058e:	74 18                	je     8005a8 <vprintfmt+0x206>
  800590:	8d 50 e0             	lea    -0x20(%eax),%edx
  800593:	83 fa 5e             	cmp    $0x5e,%edx
  800596:	76 10                	jbe    8005a8 <vprintfmt+0x206>
					putch('?', putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
  8005a6:	eb 0a                	jmp    8005b2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b5:	0f be 06             	movsbl (%esi),%eax
  8005b8:	46                   	inc    %esi
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	74 21                	je     8005de <vprintfmt+0x23c>
  8005bd:	85 ff                	test   %edi,%edi
  8005bf:	78 c9                	js     80058a <vprintfmt+0x1e8>
  8005c1:	4f                   	dec    %edi
  8005c2:	79 c6                	jns    80058a <vprintfmt+0x1e8>
  8005c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c7:	89 de                	mov    %ebx,%esi
  8005c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005cc:	eb 18                	jmp    8005e6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005db:	4b                   	dec    %ebx
  8005dc:	eb 08                	jmp    8005e6 <vprintfmt+0x244>
  8005de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e1:	89 de                	mov    %ebx,%esi
  8005e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e6:	85 db                	test   %ebx,%ebx
  8005e8:	7f e4                	jg     8005ce <vprintfmt+0x22c>
  8005ea:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005ed:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f2:	e9 ce fd ff ff       	jmp    8003c5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f7:	83 f9 01             	cmp    $0x1,%ecx
  8005fa:	7e 10                	jle    80060c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 08             	lea    0x8(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 30                	mov    (%eax),%esi
  800607:	8b 78 04             	mov    0x4(%eax),%edi
  80060a:	eb 26                	jmp    800632 <vprintfmt+0x290>
	else if (lflag)
  80060c:	85 c9                	test   %ecx,%ecx
  80060e:	74 12                	je     800622 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 30                	mov    (%eax),%esi
  80061b:	89 f7                	mov    %esi,%edi
  80061d:	c1 ff 1f             	sar    $0x1f,%edi
  800620:	eb 10                	jmp    800632 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 30                	mov    (%eax),%esi
  80062d:	89 f7                	mov    %esi,%edi
  80062f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800632:	85 ff                	test   %edi,%edi
  800634:	78 0a                	js     800640 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 8c 00 00 00       	jmp    8006cc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064e:	f7 de                	neg    %esi
  800650:	83 d7 00             	adc    $0x0,%edi
  800653:	f7 df                	neg    %edi
			}
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065a:	eb 70                	jmp    8006cc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065c:	89 ca                	mov    %ecx,%edx
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 c0 fc ff ff       	call   800326 <getuint>
  800666:	89 c6                	mov    %eax,%esi
  800668:	89 d7                	mov    %edx,%edi
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80066f:	eb 5b                	jmp    8006cc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800671:	89 ca                	mov    %ecx,%edx
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 ab fc ff ff       	call   800326 <getuint>
  80067b:	89 c6                	mov    %eax,%esi
  80067d:	89 d7                	mov    %edx,%edi
			base = 8;
  80067f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800684:	eb 46                	jmp    8006cc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800691:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ab:	8b 30                	mov    (%eax),%esi
  8006ad:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b7:	eb 13                	jmp    8006cc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 63 fc ff ff       	call   800326 <getuint>
  8006c3:	89 c6                	mov    %eax,%esi
  8006c5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006c7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006df:	89 34 24             	mov    %esi,(%esp)
  8006e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e6:	89 da                	mov    %ebx,%edx
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	e8 6c fb ff ff       	call   80025c <printnum>
			break;
  8006f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f3:	e9 cd fc ff ff       	jmp    8003c5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800705:	e9 bb fc ff ff       	jmp    8003c5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800715:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800718:	eb 01                	jmp    80071b <vprintfmt+0x379>
  80071a:	4e                   	dec    %esi
  80071b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071f:	75 f9                	jne    80071a <vprintfmt+0x378>
  800721:	e9 9f fc ff ff       	jmp    8003c5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800726:	83 c4 4c             	add    $0x4c,%esp
  800729:	5b                   	pop    %ebx
  80072a:	5e                   	pop    %esi
  80072b:	5f                   	pop    %edi
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	83 ec 28             	sub    $0x28,%esp
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800741:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800744:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074b:	85 c0                	test   %eax,%eax
  80074d:	74 30                	je     80077f <vsnprintf+0x51>
  80074f:	85 d2                	test   %edx,%edx
  800751:	7e 33                	jle    800786 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075a:	8b 45 10             	mov    0x10(%ebp),%eax
  80075d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	89 44 24 04          	mov    %eax,0x4(%esp)
  800768:	c7 04 24 60 03 80 00 	movl   $0x800360,(%esp)
  80076f:	e8 2e fc ff ff       	call   8003a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800774:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800777:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077d:	eb 0c                	jmp    80078b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800784:	eb 05                	jmp    80078b <vsnprintf+0x5d>
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800796:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079a:	8b 45 10             	mov    0x10(%ebp),%eax
  80079d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	89 04 24             	mov    %eax,(%esp)
  8007ae:	e8 7b ff ff ff       	call   80072e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    
  8007b5:	00 00                	add    %al,(%eax)
	...

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 01                	jmp    8007c6 <strlen+0xe>
		n++;
  8007c5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ca:	75 f9                	jne    8007c5 <strlen+0xd>
		n++;
	return n;
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	eb 01                	jmp    8007df <strnlen+0x11>
		n++;
  8007de:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007df:	39 d0                	cmp    %edx,%eax
  8007e1:	74 06                	je     8007e9 <strnlen+0x1b>
  8007e3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e7:	75 f5                	jne    8007de <strnlen+0x10>
		n++;
	return n;
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800800:	42                   	inc    %edx
  800801:	84 c9                	test   %cl,%cl
  800803:	75 f5                	jne    8007fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800805:	5b                   	pop    %ebx
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800812:	89 1c 24             	mov    %ebx,(%esp)
  800815:	e8 9e ff ff ff       	call   8007b8 <strlen>
	strcpy(dst + len, src);
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800821:	01 d8                	add    %ebx,%eax
  800823:	89 04 24             	mov    %eax,(%esp)
  800826:	e8 c0 ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	83 c4 08             	add    $0x8,%esp
  800830:	5b                   	pop    %ebx
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	eb 0c                	jmp    800854 <strncpy+0x21>
		*dst++ = *src;
  800848:	8a 1a                	mov    (%edx),%bl
  80084a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084d:	80 3a 01             	cmpb   $0x1,(%edx)
  800850:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800853:	41                   	inc    %ecx
  800854:	39 f1                	cmp    %esi,%ecx
  800856:	75 f0                	jne    800848 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 75 08             	mov    0x8(%ebp),%esi
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086a:	85 d2                	test   %edx,%edx
  80086c:	75 0a                	jne    800878 <strlcpy+0x1c>
  80086e:	89 f0                	mov    %esi,%eax
  800870:	eb 1a                	jmp    80088c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800872:	88 18                	mov    %bl,(%eax)
  800874:	40                   	inc    %eax
  800875:	41                   	inc    %ecx
  800876:	eb 02                	jmp    80087a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800878:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80087a:	4a                   	dec    %edx
  80087b:	74 0a                	je     800887 <strlcpy+0x2b>
  80087d:	8a 19                	mov    (%ecx),%bl
  80087f:	84 db                	test   %bl,%bl
  800881:	75 ef                	jne    800872 <strlcpy+0x16>
  800883:	89 c2                	mov    %eax,%edx
  800885:	eb 02                	jmp    800889 <strlcpy+0x2d>
  800887:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800889:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80088c:	29 f0                	sub    %esi,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089b:	eb 02                	jmp    80089f <strcmp+0xd>
		p++, q++;
  80089d:	41                   	inc    %ecx
  80089e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089f:	8a 01                	mov    (%ecx),%al
  8008a1:	84 c0                	test   %al,%al
  8008a3:	74 04                	je     8008a9 <strcmp+0x17>
  8008a5:	3a 02                	cmp    (%edx),%al
  8008a7:	74 f4                	je     80089d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a9:	0f b6 c0             	movzbl %al,%eax
  8008ac:	0f b6 12             	movzbl (%edx),%edx
  8008af:	29 d0                	sub    %edx,%eax
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c0:	eb 03                	jmp    8008c5 <strncmp+0x12>
		n--, p++, q++;
  8008c2:	4a                   	dec    %edx
  8008c3:	40                   	inc    %eax
  8008c4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c5:	85 d2                	test   %edx,%edx
  8008c7:	74 14                	je     8008dd <strncmp+0x2a>
  8008c9:	8a 18                	mov    (%eax),%bl
  8008cb:	84 db                	test   %bl,%bl
  8008cd:	74 04                	je     8008d3 <strncmp+0x20>
  8008cf:	3a 19                	cmp    (%ecx),%bl
  8008d1:	74 ef                	je     8008c2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d3:	0f b6 00             	movzbl (%eax),%eax
  8008d6:	0f b6 11             	movzbl (%ecx),%edx
  8008d9:	29 d0                	sub    %edx,%eax
  8008db:	eb 05                	jmp    8008e2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ee:	eb 05                	jmp    8008f5 <strchr+0x10>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 0c                	je     800900 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	40                   	inc    %eax
  8008f5:	8a 10                	mov    (%eax),%dl
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f5                	jne    8008f0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090b:	eb 05                	jmp    800912 <strfind+0x10>
		if (*s == c)
  80090d:	38 ca                	cmp    %cl,%dl
  80090f:	74 07                	je     800918 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800911:	40                   	inc    %eax
  800912:	8a 10                	mov    (%eax),%dl
  800914:	84 d2                	test   %dl,%dl
  800916:	75 f5                	jne    80090d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 7d 08             	mov    0x8(%ebp),%edi
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 30                	je     80095d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 25                	jne    80095a <memset+0x40>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 20                	jne    80095a <memset+0x40>
		c &= 0xFF;
  80093a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093d:	89 d3                	mov    %edx,%ebx
  80093f:	c1 e3 08             	shl    $0x8,%ebx
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 18             	shl    $0x18,%esi
  800947:	89 d0                	mov    %edx,%eax
  800949:	c1 e0 10             	shl    $0x10,%eax
  80094c:	09 f0                	or     %esi,%eax
  80094e:	09 d0                	or     %edx,%eax
  800950:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800952:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800955:	fc                   	cld    
  800956:	f3 ab                	rep stos %eax,%es:(%edi)
  800958:	eb 03                	jmp    80095d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095a:	fc                   	cld    
  80095b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800972:	39 c6                	cmp    %eax,%esi
  800974:	73 34                	jae    8009aa <memmove+0x46>
  800976:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800979:	39 d0                	cmp    %edx,%eax
  80097b:	73 2d                	jae    8009aa <memmove+0x46>
		s += n;
		d += n;
  80097d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800980:	f6 c2 03             	test   $0x3,%dl
  800983:	75 1b                	jne    8009a0 <memmove+0x3c>
  800985:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098b:	75 13                	jne    8009a0 <memmove+0x3c>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0e                	jne    8009a0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800992:	83 ef 04             	sub    $0x4,%edi
  800995:	8d 72 fc             	lea    -0x4(%edx),%esi
  800998:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099b:	fd                   	std    
  80099c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099e:	eb 07                	jmp    8009a7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a0:	4f                   	dec    %edi
  8009a1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a4:	fd                   	std    
  8009a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a7:	fc                   	cld    
  8009a8:	eb 20                	jmp    8009ca <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b0:	75 13                	jne    8009c5 <memmove+0x61>
  8009b2:	a8 03                	test   $0x3,%al
  8009b4:	75 0f                	jne    8009c5 <memmove+0x61>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 0a                	jne    8009c5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	fc                   	cld    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb 05                	jmp    8009ca <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ca:	5e                   	pop    %esi
  8009cb:	5f                   	pop    %edi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	89 04 24             	mov    %eax,(%esp)
  8009e8:	e8 77 ff ff ff       	call   800964 <memmove>
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800a03:	eb 16                	jmp    800a1b <memcmp+0x2c>
		if (*s1 != *s2)
  800a05:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a08:	42                   	inc    %edx
  800a09:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a0d:	38 c8                	cmp    %cl,%al
  800a0f:	74 0a                	je     800a1b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a11:	0f b6 c0             	movzbl %al,%eax
  800a14:	0f b6 c9             	movzbl %cl,%ecx
  800a17:	29 c8                	sub    %ecx,%eax
  800a19:	eb 09                	jmp    800a24 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	39 da                	cmp    %ebx,%edx
  800a1d:	75 e6                	jne    800a05 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a37:	eb 05                	jmp    800a3e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a39:	38 08                	cmp    %cl,(%eax)
  800a3b:	74 05                	je     800a42 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3d:	40                   	inc    %eax
  800a3e:	39 d0                	cmp    %edx,%eax
  800a40:	72 f7                	jb     800a39 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a50:	eb 01                	jmp    800a53 <strtol+0xf>
		s++;
  800a52:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a53:	8a 02                	mov    (%edx),%al
  800a55:	3c 20                	cmp    $0x20,%al
  800a57:	74 f9                	je     800a52 <strtol+0xe>
  800a59:	3c 09                	cmp    $0x9,%al
  800a5b:	74 f5                	je     800a52 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5d:	3c 2b                	cmp    $0x2b,%al
  800a5f:	75 08                	jne    800a69 <strtol+0x25>
		s++;
  800a61:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
  800a67:	eb 13                	jmp    800a7c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a69:	3c 2d                	cmp    $0x2d,%al
  800a6b:	75 0a                	jne    800a77 <strtol+0x33>
		s++, neg = 1;
  800a6d:	8d 52 01             	lea    0x1(%edx),%edx
  800a70:	bf 01 00 00 00       	mov    $0x1,%edi
  800a75:	eb 05                	jmp    800a7c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	74 05                	je     800a85 <strtol+0x41>
  800a80:	83 fb 10             	cmp    $0x10,%ebx
  800a83:	75 28                	jne    800aad <strtol+0x69>
  800a85:	8a 02                	mov    (%edx),%al
  800a87:	3c 30                	cmp    $0x30,%al
  800a89:	75 10                	jne    800a9b <strtol+0x57>
  800a8b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a8f:	75 0a                	jne    800a9b <strtol+0x57>
		s += 2, base = 16;
  800a91:	83 c2 02             	add    $0x2,%edx
  800a94:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a99:	eb 12                	jmp    800aad <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	75 0e                	jne    800aad <strtol+0x69>
  800a9f:	3c 30                	cmp    $0x30,%al
  800aa1:	75 05                	jne    800aa8 <strtol+0x64>
		s++, base = 8;
  800aa3:	42                   	inc    %edx
  800aa4:	b3 08                	mov    $0x8,%bl
  800aa6:	eb 05                	jmp    800aad <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab4:	8a 0a                	mov    (%edx),%cl
  800ab6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab9:	80 fb 09             	cmp    $0x9,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x82>
			dig = *s - '0';
  800abe:	0f be c9             	movsbl %cl,%ecx
  800ac1:	83 e9 30             	sub    $0x30,%ecx
  800ac4:	eb 1e                	jmp    800ae4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ac6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 57             	sub    $0x57,%ecx
  800ad4:	eb 0e                	jmp    800ae4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ad6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 12                	ja     800af0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae4:	39 f1                	cmp    %esi,%ecx
  800ae6:	7d 0c                	jge    800af4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ae8:	42                   	inc    %edx
  800ae9:	0f af c6             	imul   %esi,%eax
  800aec:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aee:	eb c4                	jmp    800ab4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	89 c1                	mov    %eax,%ecx
  800af2:	eb 02                	jmp    800af6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afa:	74 05                	je     800b01 <strtol+0xbd>
		*endptr = (char *) s;
  800afc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aff:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b01:	85 ff                	test   %edi,%edi
  800b03:	74 04                	je     800b09 <strtol+0xc5>
  800b05:	89 c8                	mov    %ecx,%eax
  800b07:	f7 d8                	neg    %eax
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    
	...

00800b10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	89 c3                	mov    %eax,%ebx
  800b23:	89 c7                	mov    %eax,%edi
  800b25:	89 c6                	mov    %eax,%esi
  800b27:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	89 cb                	mov    %ecx,%ebx
  800b65:	89 cf                	mov    %ecx,%edi
  800b67:	89 ce                	mov    %ecx,%esi
  800b69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7e 28                	jle    800b97 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b73:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7a:	00 
  800b7b:	c7 44 24 08 00 11 80 	movl   $0x801100,0x8(%esp)
  800b82:	00 
  800b83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8a:	00 
  800b8b:	c7 04 24 1d 11 80 00 	movl   $0x80111d,(%esp)
  800b92:	e8 b1 f5 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b97:	83 c4 2c             	add    $0x2c,%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 02 00 00 00       	mov    $0x2,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    
	...

00800bc0 <__udivdi3>:
  800bc0:	55                   	push   %ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	83 ec 10             	sub    $0x10,%esp
  800bc6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800bca:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800bce:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800bd6:	89 cd                	mov    %ecx,%ebp
  800bd8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	75 2c                	jne    800c0c <__udivdi3+0x4c>
  800be0:	39 f9                	cmp    %edi,%ecx
  800be2:	77 68                	ja     800c4c <__udivdi3+0x8c>
  800be4:	85 c9                	test   %ecx,%ecx
  800be6:	75 0b                	jne    800bf3 <__udivdi3+0x33>
  800be8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bed:	31 d2                	xor    %edx,%edx
  800bef:	f7 f1                	div    %ecx
  800bf1:	89 c1                	mov    %eax,%ecx
  800bf3:	31 d2                	xor    %edx,%edx
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	f7 f1                	div    %ecx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 f0                	mov    %esi,%eax
  800bfd:	f7 f1                	div    %ecx
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	89 f0                	mov    %esi,%eax
  800c03:	89 fa                	mov    %edi,%edx
  800c05:	83 c4 10             	add    $0x10,%esp
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    
  800c0c:	39 f8                	cmp    %edi,%eax
  800c0e:	77 2c                	ja     800c3c <__udivdi3+0x7c>
  800c10:	0f bd f0             	bsr    %eax,%esi
  800c13:	83 f6 1f             	xor    $0x1f,%esi
  800c16:	75 4c                	jne    800c64 <__udivdi3+0xa4>
  800c18:	39 f8                	cmp    %edi,%eax
  800c1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1f:	72 0a                	jb     800c2b <__udivdi3+0x6b>
  800c21:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c25:	0f 87 ad 00 00 00    	ja     800cd8 <__udivdi3+0x118>
  800c2b:	be 01 00 00 00       	mov    $0x1,%esi
  800c30:	89 f0                	mov    %esi,%eax
  800c32:	89 fa                	mov    %edi,%edx
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    
  800c3b:	90                   	nop
  800c3c:	31 ff                	xor    %edi,%edi
  800c3e:	31 f6                	xor    %esi,%esi
  800c40:	89 f0                	mov    %esi,%eax
  800c42:	89 fa                	mov    %edi,%edx
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    
  800c4b:	90                   	nop
  800c4c:	89 fa                	mov    %edi,%edx
  800c4e:	89 f0                	mov    %esi,%eax
  800c50:	f7 f1                	div    %ecx
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	31 ff                	xor    %edi,%edi
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	89 fa                	mov    %edi,%edx
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    
  800c61:	8d 76 00             	lea    0x0(%esi),%esi
  800c64:	89 f1                	mov    %esi,%ecx
  800c66:	d3 e0                	shl    %cl,%eax
  800c68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c6c:	b8 20 00 00 00       	mov    $0x20,%eax
  800c71:	29 f0                	sub    %esi,%eax
  800c73:	89 ea                	mov    %ebp,%edx
  800c75:	88 c1                	mov    %al,%cl
  800c77:	d3 ea                	shr    %cl,%edx
  800c79:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800c7d:	09 ca                	or     %ecx,%edx
  800c7f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c83:	89 f1                	mov    %esi,%ecx
  800c85:	d3 e5                	shl    %cl,%ebp
  800c87:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800c8b:	89 fd                	mov    %edi,%ebp
  800c8d:	88 c1                	mov    %al,%cl
  800c8f:	d3 ed                	shr    %cl,%ebp
  800c91:	89 fa                	mov    %edi,%edx
  800c93:	89 f1                	mov    %esi,%ecx
  800c95:	d3 e2                	shl    %cl,%edx
  800c97:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c9b:	88 c1                	mov    %al,%cl
  800c9d:	d3 ef                	shr    %cl,%edi
  800c9f:	09 d7                	or     %edx,%edi
  800ca1:	89 f8                	mov    %edi,%eax
  800ca3:	89 ea                	mov    %ebp,%edx
  800ca5:	f7 74 24 08          	divl   0x8(%esp)
  800ca9:	89 d1                	mov    %edx,%ecx
  800cab:	89 c7                	mov    %eax,%edi
  800cad:	f7 64 24 0c          	mull   0xc(%esp)
  800cb1:	39 d1                	cmp    %edx,%ecx
  800cb3:	72 17                	jb     800ccc <__udivdi3+0x10c>
  800cb5:	74 09                	je     800cc0 <__udivdi3+0x100>
  800cb7:	89 fe                	mov    %edi,%esi
  800cb9:	31 ff                	xor    %edi,%edi
  800cbb:	e9 41 ff ff ff       	jmp    800c01 <__udivdi3+0x41>
  800cc0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cc4:	89 f1                	mov    %esi,%ecx
  800cc6:	d3 e2                	shl    %cl,%edx
  800cc8:	39 c2                	cmp    %eax,%edx
  800cca:	73 eb                	jae    800cb7 <__udivdi3+0xf7>
  800ccc:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ccf:	31 ff                	xor    %edi,%edi
  800cd1:	e9 2b ff ff ff       	jmp    800c01 <__udivdi3+0x41>
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	31 f6                	xor    %esi,%esi
  800cda:	e9 22 ff ff ff       	jmp    800c01 <__udivdi3+0x41>
	...

00800ce0 <__umoddi3>:
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	83 ec 20             	sub    $0x20,%esp
  800ce6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cea:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800cee:	89 44 24 14          	mov    %eax,0x14(%esp)
  800cf2:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cf6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cfa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800cfe:	89 c7                	mov    %eax,%edi
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	85 ed                	test   %ebp,%ebp
  800d04:	75 16                	jne    800d1c <__umoddi3+0x3c>
  800d06:	39 f1                	cmp    %esi,%ecx
  800d08:	0f 86 a6 00 00 00    	jbe    800db4 <__umoddi3+0xd4>
  800d0e:	f7 f1                	div    %ecx
  800d10:	89 d0                	mov    %edx,%eax
  800d12:	31 d2                	xor    %edx,%edx
  800d14:	83 c4 20             	add    $0x20,%esp
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
  800d1b:	90                   	nop
  800d1c:	39 f5                	cmp    %esi,%ebp
  800d1e:	0f 87 ac 00 00 00    	ja     800dd0 <__umoddi3+0xf0>
  800d24:	0f bd c5             	bsr    %ebp,%eax
  800d27:	83 f0 1f             	xor    $0x1f,%eax
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	0f 84 a8 00 00 00    	je     800ddc <__umoddi3+0xfc>
  800d34:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d38:	d3 e5                	shl    %cl,%ebp
  800d3a:	bf 20 00 00 00       	mov    $0x20,%edi
  800d3f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800d43:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d47:	89 f9                	mov    %edi,%ecx
  800d49:	d3 e8                	shr    %cl,%eax
  800d4b:	09 e8                	or     %ebp,%eax
  800d4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d55:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d59:	d3 e0                	shl    %cl,%eax
  800d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5f:	89 f2                	mov    %esi,%edx
  800d61:	d3 e2                	shl    %cl,%edx
  800d63:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d67:	d3 e0                	shl    %cl,%eax
  800d69:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800d6d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e8                	shr    %cl,%eax
  800d75:	09 d0                	or     %edx,%eax
  800d77:	d3 ee                	shr    %cl,%esi
  800d79:	89 f2                	mov    %esi,%edx
  800d7b:	f7 74 24 18          	divl   0x18(%esp)
  800d7f:	89 d6                	mov    %edx,%esi
  800d81:	f7 64 24 0c          	mull   0xc(%esp)
  800d85:	89 c5                	mov    %eax,%ebp
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	39 d6                	cmp    %edx,%esi
  800d8b:	72 67                	jb     800df4 <__umoddi3+0x114>
  800d8d:	74 75                	je     800e04 <__umoddi3+0x124>
  800d8f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d93:	29 e8                	sub    %ebp,%eax
  800d95:	19 ce                	sbb    %ecx,%esi
  800d97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	89 f2                	mov    %esi,%edx
  800d9f:	89 f9                	mov    %edi,%ecx
  800da1:	d3 e2                	shl    %cl,%edx
  800da3:	09 d0                	or     %edx,%eax
  800da5:	89 f2                	mov    %esi,%edx
  800da7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800dab:	d3 ea                	shr    %cl,%edx
  800dad:	83 c4 20             	add    $0x20,%esp
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
  800db4:	85 c9                	test   %ecx,%ecx
  800db6:	75 0b                	jne    800dc3 <__umoddi3+0xe3>
  800db8:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbd:	31 d2                	xor    %edx,%edx
  800dbf:	f7 f1                	div    %ecx
  800dc1:	89 c1                	mov    %eax,%ecx
  800dc3:	89 f0                	mov    %esi,%eax
  800dc5:	31 d2                	xor    %edx,%edx
  800dc7:	f7 f1                	div    %ecx
  800dc9:	89 f8                	mov    %edi,%eax
  800dcb:	e9 3e ff ff ff       	jmp    800d0e <__umoddi3+0x2e>
  800dd0:	89 f2                	mov    %esi,%edx
  800dd2:	83 c4 20             	add    $0x20,%esp
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    
  800dd9:	8d 76 00             	lea    0x0(%esi),%esi
  800ddc:	39 f5                	cmp    %esi,%ebp
  800dde:	72 04                	jb     800de4 <__umoddi3+0x104>
  800de0:	39 f9                	cmp    %edi,%ecx
  800de2:	77 06                	ja     800dea <__umoddi3+0x10a>
  800de4:	89 f2                	mov    %esi,%edx
  800de6:	29 cf                	sub    %ecx,%edi
  800de8:	19 ea                	sbb    %ebp,%edx
  800dea:	89 f8                	mov    %edi,%eax
  800dec:	83 c4 20             	add    $0x20,%esp
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
  800df3:	90                   	nop
  800df4:	89 d1                	mov    %edx,%ecx
  800df6:	89 c5                	mov    %eax,%ebp
  800df8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800dfc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800e00:	eb 8d                	jmp    800d8f <__umoddi3+0xaf>
  800e02:	66 90                	xchg   %ax,%ax
  800e04:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800e08:	72 ea                	jb     800df4 <__umoddi3+0x114>
  800e0a:	89 f1                	mov    %esi,%ecx
  800e0c:	eb 81                	jmp    800d8f <__umoddi3+0xaf>
