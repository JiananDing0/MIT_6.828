
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 40 24 80 00 	movl   $0x802440,(%esp)
  800042:	e8 79 01 00 00       	call   8001c0 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 ab 0e 00 00       	call   800ef7 <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  800059:	e8 62 01 00 00       	call   8001c0 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 68 24 80 00 	movl   $0x802468,(%esp)
  800067:	e8 54 01 00 00       	call   8001c0 <cprintf>
	sys_yield();
  80006c:	e8 ed 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  800071:	e8 e8 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  800076:	e8 e3 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  80007b:	e8 de 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  800080:	e8 d9 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  800085:	e8 d4 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  80008a:	e8 cf 0a 00 00       	call   800b5e <sys_yield>
	sys_yield();
  80008f:	e8 ca 0a 00 00       	call   800b5e <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  80009b:	e8 20 01 00 00       	call   8001c0 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 45 0a 00 00       	call   800aed <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000be:	e8 7c 0a 00 00       	call   800b3f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x39>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ed:	89 34 24             	mov    %esi,(%esp)
  8000f0:	e8 3f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010a:	e8 c8 12 00 00       	call   8013d7 <close_all>
	sys_env_destroy(0);
  80010f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800116:	e8 d2 09 00 00       	call   800aed <sys_env_destroy>
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    
  80011d:	00 00                	add    %al,(%eax)
	...

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 19                	jne    800156 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80013d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800144:	00 
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 60 09 00 00       	call   800ab0 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800156:	ff 43 04             	incl   0x4(%ebx)
}
  800159:	83 c4 14             	add    $0x14,%esp
  80015c:	5b                   	pop    %ebx
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019b:	e8 82 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 f8 08 00 00       	call   800ab0 <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 87 ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    
	...

008001dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 3c             	sub    $0x3c,%esp
  8001e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e8:	89 d7                	mov    %edx,%edi
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	75 08                	jne    800208 <printnum+0x2c>
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	39 45 10             	cmp    %eax,0x10(%ebp)
  800206:	77 57                	ja     80025f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800208:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020c:	4b                   	dec    %ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80021c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	e8 a6 1f 00 00       	call   8021e0 <__udivdi3>
  80023a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 fa                	mov    %edi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 89 ff ff ff       	call   8001dc <printnum>
  800253:	eb 0f                	jmp    800264 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f f1                	jg     800255 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	e8 73 20 00 00       	call   802300 <__umoddi3>
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800291:	0f be 80 e0 24 80 00 	movsbl 0x8024e0(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 3c             	add    $0x3c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 08                	jae    8002f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	42                   	inc    %edx
  8002f6:	89 10                	mov    %edx,(%eax)
}
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800300:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800311:	89 44 24 04          	mov    %eax,0x4(%esp)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 02 00 00 00       	call   800322 <vprintfmt>
	va_end(ap);
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 4c             	sub    $0x4c,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032e:	8b 75 10             	mov    0x10(%ebp),%esi
  800331:	eb 12                	jmp    800345 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800333:	85 c0                	test   %eax,%eax
  800335:	0f 84 8b 03 00 00    	je     8006c6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80033b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800345:	0f b6 06             	movzbl (%esi),%eax
  800348:	46                   	inc    %esi
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e5                	jne    800333 <vprintfmt+0x11>
  80034e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800359:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036a:	eb 26                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800373:	eb 1d                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037c:	eb 14                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800388:	eb 08                	jmp    800392 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	0f b6 06             	movzbl (%esi),%eax
  800395:	8d 56 01             	lea    0x1(%esi),%edx
  800398:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80039b:	8a 16                	mov    (%esi),%dl
  80039d:	83 ea 23             	sub    $0x23,%edx
  8003a0:	80 fa 55             	cmp    $0x55,%dl
  8003a3:	0f 87 01 03 00 00    	ja     8006aa <vprintfmt+0x388>
  8003a9:	0f b6 d2             	movzbl %dl,%edx
  8003ac:	ff 24 95 20 26 80 00 	jmp    *0x802620(,%edx,4)
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 2a                	ja     8003f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb eb                	jmp    8003bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 17                	jmp    8003f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e4:	78 98                	js     80037e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e9:	eb a7                	jmp    800392 <vprintfmt+0x70>
  8003eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f5:	eb 9b                	jmp    800392 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	79 95                	jns    800392 <vprintfmt+0x70>
  8003fd:	eb 8b                	jmp    80038a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	eb 8d                	jmp    800392 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041d:	e9 23 ff ff ff       	jmp    800345 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	79 02                	jns    800433 <vprintfmt+0x111>
  800431:	f7 d8                	neg    %eax
  800433:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x123>
  80043a:	8b 04 85 80 27 80 00 	mov    0x802780(,%eax,4),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	75 23                	jne    800468 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800445:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800449:	c7 44 24 08 f8 24 80 	movl   $0x8024f8,0x8(%esp)
  800450:	00 
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 9a fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 dd fe ff ff       	jmp    800345 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 da 29 80 	movl   $0x8029da,0x8(%esp)
  800473:	00 
  800474:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800478:	8b 55 08             	mov    0x8(%ebp),%edx
  80047b:	89 14 24             	mov    %edx,(%esp)
  80047e:	e8 77 fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800486:	e9 ba fe ff ff       	jmp    800345 <vprintfmt+0x23>
  80048b:	89 f9                	mov    %edi,%ecx
  80048d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 30                	mov    (%eax),%esi
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	75 05                	jne    8004a7 <vprintfmt+0x185>
				p = "(null)";
  8004a2:	be f1 24 80 00       	mov    $0x8024f1,%esi
			if (width > 0 && padc != '-')
  8004a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ab:	0f 8e 84 00 00 00    	jle    800535 <vprintfmt+0x213>
  8004b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b5:	74 7e                	je     800535 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bb:	89 34 24             	mov    %esi,(%esp)
  8004be:	e8 ab 02 00 00       	call   80076e <strnlen>
  8004c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c6:	29 c2                	sub    %eax,%edx
  8004c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	89 d3                	mov    %edx,%ebx
  8004d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	89 3c 24             	mov    %edi,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	4b                   	dec    %ebx
  8004e8:	85 db                	test   %ebx,%ebx
  8004ea:	7f f1                	jg     8004dd <vprintfmt+0x1bb>
  8004ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004ef:	89 f3                	mov    %esi,%ebx
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 05                	jns    800500 <vprintfmt+0x1de>
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	eb 2b                	jmp    800535 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050e:	74 18                	je     800528 <vprintfmt+0x206>
  800510:	8d 50 e0             	lea    -0x20(%eax),%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 10                	jbe    800528 <vprintfmt+0x206>
					putch('?', putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	eb 0a                	jmp    800532 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800528:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	ff 4d e4             	decl   -0x1c(%ebp)
  800535:	0f be 06             	movsbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	85 c0                	test   %eax,%eax
  80053b:	74 21                	je     80055e <vprintfmt+0x23c>
  80053d:	85 ff                	test   %edi,%edi
  80053f:	78 c9                	js     80050a <vprintfmt+0x1e8>
  800541:	4f                   	dec    %edi
  800542:	79 c6                	jns    80050a <vprintfmt+0x1e8>
  800544:	8b 7d 08             	mov    0x8(%ebp),%edi
  800547:	89 de                	mov    %ebx,%esi
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800552:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800559:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055b:	4b                   	dec    %ebx
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x244>
  80055e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800561:	89 de                	mov    %ebx,%esi
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800566:	85 db                	test   %ebx,%ebx
  800568:	7f e4                	jg     80054e <vprintfmt+0x22c>
  80056a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	e9 ce fd ff ff       	jmp    800345 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7e 10                	jle    80058c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 08             	lea    0x8(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	8b 78 04             	mov    0x4(%eax),%edi
  80058a:	eb 26                	jmp    8005b2 <vprintfmt+0x290>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 12                	je     8005a2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	c1 ff 1f             	sar    $0x1f,%edi
  8005a0:	eb 10                	jmp    8005b2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 30                	mov    (%eax),%esi
  8005ad:	89 f7                	mov    %esi,%edi
  8005af:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 ac 00 00 00       	jmp    80066c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ce:	f7 de                	neg    %esi
  8005d0:	83 d7 00             	adc    $0x0,%edi
  8005d3:	f7 df                	neg    %edi
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	e9 8d 00 00 00       	jmp    80066c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005df:	89 ca                	mov    %ecx,%edx
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 bd fc ff ff       	call   8002a6 <getuint>
  8005e9:	89 c6                	mov    %eax,%esi
  8005eb:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f2:	eb 78                	jmp    80066c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800602:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800606:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80060d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80061b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800621:	e9 1f fd ff ff       	jmp    800345 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800626:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800631:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064b:	8b 30                	mov    (%eax),%esi
  80064d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800652:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800657:	eb 13                	jmp    80066c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800659:	89 ca                	mov    %ecx,%edx
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 43 fc ff ff       	call   8002a6 <getuint>
  800663:	89 c6                	mov    %eax,%esi
  800665:	89 d7                	mov    %edx,%edi
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800670:	89 54 24 10          	mov    %edx,0x10(%esp)
  800674:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800677:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80067b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067f:	89 34 24             	mov    %esi,(%esp)
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	89 da                	mov    %ebx,%edx
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	e8 4c fb ff ff       	call   8001dc <printnum>
			break;
  800690:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800693:	e9 ad fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	89 04 24             	mov    %eax,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a5:	e9 9b fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b8:	eb 01                	jmp    8006bb <vprintfmt+0x399>
  8006ba:	4e                   	dec    %esi
  8006bb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006bf:	75 f9                	jne    8006ba <vprintfmt+0x398>
  8006c1:	e9 7f fc ff ff       	jmp    800345 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006c6:	83 c4 4c             	add    $0x4c,%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 28             	sub    $0x28,%esp
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	74 30                	je     80071f <vsnprintf+0x51>
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	7e 33                	jle    800726 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	89 44 24 04          	mov    %eax,0x4(%esp)
  800708:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  80070f:	e8 0e fc ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800714:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800717:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071d:	eb 0c                	jmp    80072b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800724:	eb 05                	jmp    80072b <vsnprintf+0x5d>
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800736:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800741:	8b 45 0c             	mov    0xc(%ebp),%eax
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	e8 7b ff ff ff       	call   8006ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    
  800755:	00 00                	add    %al,(%eax)
	...

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 01                	jmp    800766 <strlen+0xe>
		n++;
  800765:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076a:	75 f9                	jne    800765 <strlen+0xd>
		n++;
	return n;
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800774:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
  80077c:	eb 01                	jmp    80077f <strnlen+0x11>
		n++;
  80077e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	39 d0                	cmp    %edx,%eax
  800781:	74 06                	je     800789 <strnlen+0x1b>
  800783:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800787:	75 f5                	jne    80077e <strnlen+0x10>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800795:	ba 00 00 00 00       	mov    $0x0,%edx
  80079a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80079d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a0:	42                   	inc    %edx
  8007a1:	84 c9                	test   %cl,%cl
  8007a3:	75 f5                	jne    80079a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b2:	89 1c 24             	mov    %ebx,(%esp)
  8007b5:	e8 9e ff ff ff       	call   800758 <strlen>
	strcpy(dst + len, src);
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c1:	01 d8                	add    %ebx,%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 c0 ff ff ff       	call   80078b <strcpy>
	return dst;
}
  8007cb:	89 d8                	mov    %ebx,%eax
  8007cd:	83 c4 08             	add    $0x8,%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007de:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e6:	eb 0c                	jmp    8007f4 <strncpy+0x21>
		*dst++ = *src;
  8007e8:	8a 1a                	mov    (%edx),%bl
  8007ea:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ed:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f3:	41                   	inc    %ecx
  8007f4:	39 f1                	cmp    %esi,%ecx
  8007f6:	75 f0                	jne    8007e8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080a:	85 d2                	test   %edx,%edx
  80080c:	75 0a                	jne    800818 <strlcpy+0x1c>
  80080e:	89 f0                	mov    %esi,%eax
  800810:	eb 1a                	jmp    80082c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	88 18                	mov    %bl,(%eax)
  800814:	40                   	inc    %eax
  800815:	41                   	inc    %ecx
  800816:	eb 02                	jmp    80081a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80081a:	4a                   	dec    %edx
  80081b:	74 0a                	je     800827 <strlcpy+0x2b>
  80081d:	8a 19                	mov    (%ecx),%bl
  80081f:	84 db                	test   %bl,%bl
  800821:	75 ef                	jne    800812 <strlcpy+0x16>
  800823:	89 c2                	mov    %eax,%edx
  800825:	eb 02                	jmp    800829 <strlcpy+0x2d>
  800827:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083b:	eb 02                	jmp    80083f <strcmp+0xd>
		p++, q++;
  80083d:	41                   	inc    %ecx
  80083e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083f:	8a 01                	mov    (%ecx),%al
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x17>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	74 f4                	je     80083d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800860:	eb 03                	jmp    800865 <strncmp+0x12>
		n--, p++, q++;
  800862:	4a                   	dec    %edx
  800863:	40                   	inc    %eax
  800864:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800865:	85 d2                	test   %edx,%edx
  800867:	74 14                	je     80087d <strncmp+0x2a>
  800869:	8a 18                	mov    (%eax),%bl
  80086b:	84 db                	test   %bl,%bl
  80086d:	74 04                	je     800873 <strncmp+0x20>
  80086f:	3a 19                	cmp    (%ecx),%bl
  800871:	74 ef                	je     800862 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	0f b6 11             	movzbl (%ecx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb 05                	jmp    800882 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088e:	eb 05                	jmp    800895 <strchr+0x10>
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 0c                	je     8008a0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800894:	40                   	inc    %eax
  800895:	8a 10                	mov    (%eax),%dl
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f5                	jne    800890 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ab:	eb 05                	jmp    8008b2 <strfind+0x10>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 07                	je     8008b8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b1:	40                   	inc    %eax
  8008b2:	8a 10                	mov    (%eax),%dl
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f5                	jne    8008ad <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	74 30                	je     8008fd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d3:	75 25                	jne    8008fa <memset+0x40>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 20                	jne    8008fa <memset+0x40>
		c &= 0xFF;
  8008da:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 08             	shl    $0x8,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 18             	shl    $0x18,%esi
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 10             	shl    $0x10,%eax
  8008ec:	09 f0                	or     %esi,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb 03                	jmp    8008fd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fa:	fc                   	cld    
  8008fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800912:	39 c6                	cmp    %eax,%esi
  800914:	73 34                	jae    80094a <memmove+0x46>
  800916:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800919:	39 d0                	cmp    %edx,%eax
  80091b:	73 2d                	jae    80094a <memmove+0x46>
		s += n;
		d += n;
  80091d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800920:	f6 c2 03             	test   $0x3,%dl
  800923:	75 1b                	jne    800940 <memmove+0x3c>
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 13                	jne    800940 <memmove+0x3c>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 07                	jmp    800947 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800940:	4f                   	dec    %edi
  800941:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	fd                   	std    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800947:	fc                   	cld    
  800948:	eb 20                	jmp    80096a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 13                	jne    800965 <memmove+0x61>
  800952:	a8 03                	test   $0x3,%al
  800954:	75 0f                	jne    800965 <memmove+0x61>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0a                	jne    800965 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 05                	jmp    80096a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800974:	8b 45 10             	mov    0x10(%ebp),%eax
  800977:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 77 ff ff ff       	call   800904 <memmove>
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 7d 08             	mov    0x8(%ebp),%edi
  800998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099e:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a3:	eb 16                	jmp    8009bb <memcmp+0x2c>
		if (*s1 != *s2)
  8009a5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009a8:	42                   	inc    %edx
  8009a9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009ad:	38 c8                	cmp    %cl,%al
  8009af:	74 0a                	je     8009bb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	0f b6 c9             	movzbl %cl,%ecx
  8009b7:	29 c8                	sub    %ecx,%eax
  8009b9:	eb 09                	jmp    8009c4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bb:	39 da                	cmp    %ebx,%edx
  8009bd:	75 e6                	jne    8009a5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d2:	89 c2                	mov    %eax,%edx
  8009d4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d7:	eb 05                	jmp    8009de <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d9:	38 08                	cmp    %cl,(%eax)
  8009db:	74 05                	je     8009e2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dd:	40                   	inc    %eax
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	72 f7                	jb     8009d9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	eb 01                	jmp    8009f3 <strtol+0xf>
		s++;
  8009f2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	8a 02                	mov    (%edx),%al
  8009f5:	3c 20                	cmp    $0x20,%al
  8009f7:	74 f9                	je     8009f2 <strtol+0xe>
  8009f9:	3c 09                	cmp    $0x9,%al
  8009fb:	74 f5                	je     8009f2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fd:	3c 2b                	cmp    $0x2b,%al
  8009ff:	75 08                	jne    800a09 <strtol+0x25>
		s++;
  800a01:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 13                	jmp    800a1c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a09:	3c 2d                	cmp    $0x2d,%al
  800a0b:	75 0a                	jne    800a17 <strtol+0x33>
		s++, neg = 1;
  800a0d:	8d 52 01             	lea    0x1(%edx),%edx
  800a10:	bf 01 00 00 00       	mov    $0x1,%edi
  800a15:	eb 05                	jmp    800a1c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	85 db                	test   %ebx,%ebx
  800a1e:	74 05                	je     800a25 <strtol+0x41>
  800a20:	83 fb 10             	cmp    $0x10,%ebx
  800a23:	75 28                	jne    800a4d <strtol+0x69>
  800a25:	8a 02                	mov    (%edx),%al
  800a27:	3c 30                	cmp    $0x30,%al
  800a29:	75 10                	jne    800a3b <strtol+0x57>
  800a2b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a2f:	75 0a                	jne    800a3b <strtol+0x57>
		s += 2, base = 16;
  800a31:	83 c2 02             	add    $0x2,%edx
  800a34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a39:	eb 12                	jmp    800a4d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 0e                	jne    800a4d <strtol+0x69>
  800a3f:	3c 30                	cmp    $0x30,%al
  800a41:	75 05                	jne    800a48 <strtol+0x64>
		s++, base = 8;
  800a43:	42                   	inc    %edx
  800a44:	b3 08                	mov    $0x8,%bl
  800a46:	eb 05                	jmp    800a4d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a48:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a54:	8a 0a                	mov    (%edx),%cl
  800a56:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a59:	80 fb 09             	cmp    $0x9,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0x82>
			dig = *s - '0';
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 30             	sub    $0x30,%ecx
  800a64:	eb 1e                	jmp    800a84 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a66:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a69:	80 fb 19             	cmp    $0x19,%bl
  800a6c:	77 08                	ja     800a76 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a6e:	0f be c9             	movsbl %cl,%ecx
  800a71:	83 e9 57             	sub    $0x57,%ecx
  800a74:	eb 0e                	jmp    800a84 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a76:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 12                	ja     800a90 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a7e:	0f be c9             	movsbl %cl,%ecx
  800a81:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a84:	39 f1                	cmp    %esi,%ecx
  800a86:	7d 0c                	jge    800a94 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a88:	42                   	inc    %edx
  800a89:	0f af c6             	imul   %esi,%eax
  800a8c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a8e:	eb c4                	jmp    800a54 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a90:	89 c1                	mov    %eax,%ecx
  800a92:	eb 02                	jmp    800a96 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a94:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9a:	74 05                	je     800aa1 <strtol+0xbd>
		*endptr = (char *) s;
  800a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	74 04                	je     800aa9 <strtol+0xc5>
  800aa5:	89 c8                	mov    %ecx,%eax
  800aa7:	f7 d8                	neg    %eax
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    
	...

00800ab0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_cgetc>:

int
sys_cgetc(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	89 d7                	mov    %edx,%edi
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afb:	b8 03 00 00 00       	mov    $0x3,%eax
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 cb                	mov    %ecx,%ebx
  800b05:	89 cf                	mov    %ecx,%edi
  800b07:	89 ce                	mov    %ecx,%esi
  800b09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	7e 28                	jle    800b37 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b13:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b1a:	00 
  800b1b:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800b22:	00 
  800b23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b2a:	00 
  800b2b:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800b32:	e8 31 14 00 00       	call   801f68 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b37:	83 c4 2c             	add    $0x2c,%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_yield>:

void
sys_yield(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	be 00 00 00 00       	mov    $0x0,%esi
  800b8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 f7                	mov    %esi,%edi
  800b9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 28                	jle    800bc9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bac:	00 
  800bad:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800bb4:	00 
  800bb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbc:	00 
  800bbd:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800bc4:	e8 9f 13 00 00       	call   801f68 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc9:	83 c4 2c             	add    $0x2c,%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdf:	8b 75 18             	mov    0x18(%ebp),%esi
  800be2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 28                	jle    800c1c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bff:	00 
  800c00:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800c07:	00 
  800c08:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0f:	00 
  800c10:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800c17:	e8 4c 13 00 00       	call   801f68 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1c:	83 c4 2c             	add    $0x2c,%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 06 00 00 00       	mov    $0x6,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 28                	jle    800c6f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c52:	00 
  800c53:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c62:	00 
  800c63:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800c6a:	e8 f9 12 00 00       	call   801f68 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6f:	83 c4 2c             	add    $0x2c,%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 28                	jle    800cc2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800cad:	00 
  800cae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb5:	00 
  800cb6:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800cbd:	e8 a6 12 00 00       	call   801f68 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc2:	83 c4 2c             	add    $0x2c,%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 28                	jle    800d15 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d10:	e8 53 12 00 00       	call   801f68 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d15:	83 c4 2c             	add    $0x2c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 28                	jle    800d68 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800d63:	e8 00 12 00 00       	call   801f68 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d68:	83 c4 2c             	add    $0x2c,%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	be 00 00 00 00       	mov    $0x0,%esi
  800d7b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 cb                	mov    %ecx,%ebx
  800dab:	89 cf                	mov    %ecx,%edi
  800dad:	89 ce                	mov    %ecx,%esi
  800daf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 28                	jle    800ddd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 08 df 27 80 	movl   $0x8027df,0x8(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd0:	00 
  800dd1:	c7 04 24 fc 27 80 00 	movl   $0x8027fc,(%esp)
  800dd8:	e8 8b 11 00 00       	call   801f68 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddd:	83 c4 2c             	add    $0x2c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	00 00                	add    %al,(%eax)
	...

00800de8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	53                   	push   %ebx
  800dec:	83 ec 24             	sub    $0x24,%esp
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800df4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df8:	75 20                	jne    800e1a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800dfa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dfe:	c7 44 24 08 0c 28 80 	movl   $0x80280c,0x8(%esp)
  800e05:	00 
  800e06:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800e0d:	00 
  800e0e:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  800e15:	e8 4e 11 00 00       	call   801f68 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e1a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2c:	f6 c4 08             	test   $0x8,%ah
  800e2f:	75 1c                	jne    800e4d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e31:	c7 44 24 08 3c 28 80 	movl   $0x80283c,0x8(%esp)
  800e38:	00 
  800e39:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e40:	00 
  800e41:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  800e48:	e8 1b 11 00 00       	call   801f68 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800e4d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e54:	00 
  800e55:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e5c:	00 
  800e5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e64:	e8 14 fd ff ff       	call   800b7d <sys_page_alloc>
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	79 20                	jns    800e8d <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800e6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e71:	c7 44 24 08 96 28 80 	movl   $0x802896,0x8(%esp)
  800e78:	00 
  800e79:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800e80:	00 
  800e81:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  800e88:	e8 db 10 00 00       	call   801f68 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800e8d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e94:	00 
  800e95:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e99:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ea0:	e8 5f fa ff ff       	call   800904 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800ea5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800eac:	00 
  800ead:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec8:	e8 04 fd ff ff       	call   800bd1 <sys_page_map>
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	79 20                	jns    800ef1 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800ed1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed5:	c7 44 24 08 a9 28 80 	movl   $0x8028a9,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  800eec:	e8 77 10 00 00       	call   801f68 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800ef1:	83 c4 24             	add    $0x24,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f00:	c7 04 24 e8 0d 80 00 	movl   $0x800de8,(%esp)
  800f07:	e8 b4 10 00 00       	call   801fc0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f0c:	ba 07 00 00 00       	mov    $0x7,%edx
  800f11:	89 d0                	mov    %edx,%eax
  800f13:	cd 30                	int    $0x30
  800f15:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f18:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	79 20                	jns    800f3f <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f23:	c7 44 24 08 ba 28 80 	movl   $0x8028ba,0x8(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f32:	00 
  800f33:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  800f3a:	e8 29 10 00 00       	call   801f68 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f3f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f43:	75 25                	jne    800f6a <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f45:	e8 f5 fb ff ff       	call   800b3f <sys_getenvid>
  800f4a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f56:	c1 e0 07             	shl    $0x7,%eax
  800f59:	29 d0                	sub    %edx,%eax
  800f5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f60:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f65:	e9 58 02 00 00       	jmp    8011c2 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800f6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6f:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800f74:	89 f0                	mov    %esi,%eax
  800f76:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f80:	a8 01                	test   $0x1,%al
  800f82:	0f 84 7a 01 00 00    	je     801102 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800f88:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f8f:	a8 01                	test   $0x1,%al
  800f91:	0f 84 6b 01 00 00    	je     801102 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800f97:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9c:	8b 40 48             	mov    0x48(%eax),%eax
  800f9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800fa2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa9:	f6 c4 04             	test   $0x4,%ah
  800fac:	74 52                	je     801000 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800fae:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fd0:	89 04 24             	mov    %eax,(%esp)
  800fd3:	e8 f9 fb ff ff       	call   800bd1 <sys_page_map>
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	0f 89 22 01 00 00    	jns    801102 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  800fe0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fe4:	c7 44 24 08 ca 28 80 	movl   $0x8028ca,0x8(%esp)
  800feb:	00 
  800fec:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800ff3:	00 
  800ff4:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  800ffb:	e8 68 0f 00 00       	call   801f68 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801000:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801007:	f6 c4 08             	test   $0x8,%ah
  80100a:	75 0f                	jne    80101b <fork+0x124>
  80100c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801013:	a8 02                	test   $0x2,%al
  801015:	0f 84 99 00 00 00    	je     8010b4 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80101b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801022:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801025:	83 f8 01             	cmp    $0x1,%eax
  801028:	19 db                	sbb    %ebx,%ebx
  80102a:	83 e3 fc             	and    $0xfffffffc,%ebx
  80102d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801033:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801037:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80103b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80103e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801042:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801046:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801049:	89 04 24             	mov    %eax,(%esp)
  80104c:	e8 80 fb ff ff       	call   800bd1 <sys_page_map>
  801051:	85 c0                	test   %eax,%eax
  801053:	79 20                	jns    801075 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801059:	c7 44 24 08 ca 28 80 	movl   $0x8028ca,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  801070:	e8 f3 0e 00 00       	call   801f68 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801075:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801079:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801080:	89 44 24 08          	mov    %eax,0x8(%esp)
  801084:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801088:	89 04 24             	mov    %eax,(%esp)
  80108b:	e8 41 fb ff ff       	call   800bd1 <sys_page_map>
  801090:	85 c0                	test   %eax,%eax
  801092:	79 6e                	jns    801102 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801094:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801098:	c7 44 24 08 ca 28 80 	movl   $0x8028ca,0x8(%esp)
  80109f:	00 
  8010a0:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8010a7:	00 
  8010a8:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  8010af:	e8 b4 0e 00 00       	call   801f68 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010b4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d6:	89 04 24             	mov    %eax,(%esp)
  8010d9:	e8 f3 fa ff ff       	call   800bd1 <sys_page_map>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 20                	jns    801102 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e6:	c7 44 24 08 ca 28 80 	movl   $0x8028ca,0x8(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8010f5:	00 
  8010f6:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  8010fd:	e8 66 0e 00 00       	call   801f68 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801102:	46                   	inc    %esi
  801103:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801109:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80110f:	0f 85 5f fe ff ff    	jne    800f74 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801115:	c7 44 24 04 60 20 80 	movl   $0x802060,0x4(%esp)
  80111c:	00 
  80111d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801120:	89 04 24             	mov    %eax,(%esp)
  801123:	e8 f5 fb ff ff       	call   800d1d <sys_env_set_pgfault_upcall>
  801128:	85 c0                	test   %eax,%eax
  80112a:	79 20                	jns    80114c <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  80112c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801130:	c7 44 24 08 6c 28 80 	movl   $0x80286c,0x8(%esp)
  801137:	00 
  801138:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  801147:	e8 1c 0e 00 00       	call   801f68 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  80114c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801153:	00 
  801154:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80115b:	ee 
  80115c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80115f:	89 04 24             	mov    %eax,(%esp)
  801162:	e8 16 fa ff ff       	call   800b7d <sys_page_alloc>
  801167:	85 c0                	test   %eax,%eax
  801169:	79 20                	jns    80118b <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80116b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116f:	c7 44 24 08 96 28 80 	movl   $0x802896,0x8(%esp)
  801176:	00 
  801177:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  80117e:	00 
  80117f:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  801186:	e8 dd 0d 00 00       	call   801f68 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80118b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801192:	00 
  801193:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801196:	89 04 24             	mov    %eax,(%esp)
  801199:	e8 d9 fa ff ff       	call   800c77 <sys_env_set_status>
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	79 20                	jns    8011c2 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  8011a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a6:	c7 44 24 08 dc 28 80 	movl   $0x8028dc,0x8(%esp)
  8011ad:	00 
  8011ae:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011b5:	00 
  8011b6:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  8011bd:	e8 a6 0d 00 00       	call   801f68 <_panic>
	}
	
	return envid;
}
  8011c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011c5:	83 c4 3c             	add    $0x3c,%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sfork>:

// Challenge!
int
sfork(void)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011d3:	c7 44 24 08 f3 28 80 	movl   $0x8028f3,0x8(%esp)
  8011da:	00 
  8011db:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8011e2:	00 
  8011e3:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  8011ea:	e8 79 0d 00 00       	call   801f68 <_panic>
	...

008011f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 df ff ff ff       	call   8011f0 <fd2num>
  801211:	05 20 00 0d 00       	add    $0xd0020,%eax
  801216:	c1 e0 0c             	shl    $0xc,%eax
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801222:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801227:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 16             	shr    $0x16,%edx
  80122e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 11                	je     80124b <fd_alloc+0x30>
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	c1 ea 0c             	shr    $0xc,%edx
  80123f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801246:	f6 c2 01             	test   $0x1,%dl
  801249:	75 09                	jne    801254 <fd_alloc+0x39>
			*fd_store = fd;
  80124b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	eb 17                	jmp    80126b <fd_alloc+0x50>
  801254:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801259:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125e:	75 c7                	jne    801227 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801260:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801266:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126b:	5b                   	pop    %ebx
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801274:	83 f8 1f             	cmp    $0x1f,%eax
  801277:	77 36                	ja     8012af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801279:	05 00 00 0d 00       	add    $0xd0000,%eax
  80127e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 16             	shr    $0x16,%edx
  801286:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 24                	je     8012b6 <fd_lookup+0x48>
  801292:	89 c2                	mov    %eax,%edx
  801294:	c1 ea 0c             	shr    $0xc,%edx
  801297:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129e:	f6 c2 01             	test   $0x1,%dl
  8012a1:	74 1a                	je     8012bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	eb 13                	jmp    8012c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b4:	eb 0c                	jmp    8012c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bb:	eb 05                	jmp    8012c2 <fd_lookup+0x54>
  8012bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 14             	sub    $0x14,%esp
  8012cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d6:	eb 0e                	jmp    8012e6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012d8:	39 08                	cmp    %ecx,(%eax)
  8012da:	75 09                	jne    8012e5 <dev_lookup+0x21>
			*dev = devtab[i];
  8012dc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e3:	eb 33                	jmp    801318 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e5:	42                   	inc    %edx
  8012e6:	8b 04 95 88 29 80 00 	mov    0x802988(,%edx,4),%eax
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	75 e7                	jne    8012d8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f6:	8b 40 48             	mov    0x48(%eax),%eax
  8012f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801301:	c7 04 24 0c 29 80 00 	movl   $0x80290c,(%esp)
  801308:	e8 b3 ee ff ff       	call   8001c0 <cprintf>
	*dev = 0;
  80130d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801318:	83 c4 14             	add    $0x14,%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
  801323:	83 ec 30             	sub    $0x30,%esp
  801326:	8b 75 08             	mov    0x8(%ebp),%esi
  801329:	8a 45 0c             	mov    0xc(%ebp),%al
  80132c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132f:	89 34 24             	mov    %esi,(%esp)
  801332:	e8 b9 fe ff ff       	call   8011f0 <fd2num>
  801337:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80133a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 28 ff ff ff       	call   80126e <fd_lookup>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 05                	js     801351 <fd_close+0x33>
	    || fd != fd2)
  80134c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80134f:	74 0d                	je     80135e <fd_close+0x40>
		return (must_exist ? r : 0);
  801351:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801355:	75 46                	jne    80139d <fd_close+0x7f>
  801357:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135c:	eb 3f                	jmp    80139d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80135e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	8b 06                	mov    (%esi),%eax
  801367:	89 04 24             	mov    %eax,(%esp)
  80136a:	e8 55 ff ff ff       	call   8012c4 <dev_lookup>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	85 c0                	test   %eax,%eax
  801373:	78 18                	js     80138d <fd_close+0x6f>
		if (dev->dev_close)
  801375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801378:	8b 40 10             	mov    0x10(%eax),%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	74 09                	je     801388 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80137f:	89 34 24             	mov    %esi,(%esp)
  801382:	ff d0                	call   *%eax
  801384:	89 c3                	mov    %eax,%ebx
  801386:	eb 05                	jmp    80138d <fd_close+0x6f>
		else
			r = 0;
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80138d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801391:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801398:	e8 87 f8 ff ff       	call   800c24 <sys_page_unmap>
	return r;
}
  80139d:	89 d8                	mov    %ebx,%eax
  80139f:	83 c4 30             	add    $0x30,%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	89 04 24             	mov    %eax,(%esp)
  8013b9:	e8 b0 fe ff ff       	call   80126e <fd_lookup>
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 13                	js     8013d5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013c9:	00 
  8013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 49 ff ff ff       	call   80131e <fd_close>
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <close_all>:

void
close_all(void)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 bb ff ff ff       	call   8013a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013eb:	43                   	inc    %ebx
  8013ec:	83 fb 20             	cmp    $0x20,%ebx
  8013ef:	75 f2                	jne    8013e3 <close_all+0xc>
		close(i);
}
  8013f1:	83 c4 14             	add    $0x14,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 4c             	sub    $0x4c,%esp
  801400:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801403:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	e8 59 fe ff ff       	call   80126e <fd_lookup>
  801415:	89 c3                	mov    %eax,%ebx
  801417:	85 c0                	test   %eax,%eax
  801419:	0f 88 e1 00 00 00    	js     801500 <dup+0x109>
		return r;
	close(newfdnum);
  80141f:	89 3c 24             	mov    %edi,(%esp)
  801422:	e8 7f ff ff ff       	call   8013a6 <close>

	newfd = INDEX2FD(newfdnum);
  801427:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80142d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 c5 fd ff ff       	call   801200 <fd2data>
  80143b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80143d:	89 34 24             	mov    %esi,(%esp)
  801440:	e8 bb fd ff ff       	call   801200 <fd2data>
  801445:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801448:	89 d8                	mov    %ebx,%eax
  80144a:	c1 e8 16             	shr    $0x16,%eax
  80144d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801454:	a8 01                	test   $0x1,%al
  801456:	74 46                	je     80149e <dup+0xa7>
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	c1 e8 0c             	shr    $0xc,%eax
  80145d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801464:	f6 c2 01             	test   $0x1,%dl
  801467:	74 35                	je     80149e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801469:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801470:	25 07 0e 00 00       	and    $0xe07,%eax
  801475:	89 44 24 10          	mov    %eax,0x10(%esp)
  801479:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80147c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801480:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801487:	00 
  801488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80148c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801493:	e8 39 f7 ff ff       	call   800bd1 <sys_page_map>
  801498:	89 c3                	mov    %eax,%ebx
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 3b                	js     8014d9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	c1 ea 0c             	shr    $0xc,%edx
  8014a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ad:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014b3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c2:	00 
  8014c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ce:	e8 fe f6 ff ff       	call   800bd1 <sys_page_map>
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	79 25                	jns    8014fe <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e4:	e8 3b f7 ff ff       	call   800c24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f7:	e8 28 f7 ff ff       	call   800c24 <sys_page_unmap>
	return r;
  8014fc:	eb 02                	jmp    801500 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014fe:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801500:	89 d8                	mov    %ebx,%eax
  801502:	83 c4 4c             	add    $0x4c,%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	53                   	push   %ebx
  80150e:	83 ec 24             	sub    $0x24,%esp
  801511:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801514:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151b:	89 1c 24             	mov    %ebx,(%esp)
  80151e:	e8 4b fd ff ff       	call   80126e <fd_lookup>
  801523:	85 c0                	test   %eax,%eax
  801525:	78 6d                	js     801594 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801531:	8b 00                	mov    (%eax),%eax
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	e8 89 fd ff ff       	call   8012c4 <dev_lookup>
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 55                	js     801594 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801542:	8b 50 08             	mov    0x8(%eax),%edx
  801545:	83 e2 03             	and    $0x3,%edx
  801548:	83 fa 01             	cmp    $0x1,%edx
  80154b:	75 23                	jne    801570 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80154d:	a1 04 40 80 00       	mov    0x804004,%eax
  801552:	8b 40 48             	mov    0x48(%eax),%eax
  801555:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155d:	c7 04 24 4d 29 80 00 	movl   $0x80294d,(%esp)
  801564:	e8 57 ec ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  801569:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156e:	eb 24                	jmp    801594 <read+0x8a>
	}
	if (!dev->dev_read)
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	8b 52 08             	mov    0x8(%edx),%edx
  801576:	85 d2                	test   %edx,%edx
  801578:	74 15                	je     80158f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80157a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80157d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801581:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801584:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	ff d2                	call   *%edx
  80158d:	eb 05                	jmp    801594 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801594:	83 c4 24             	add    $0x24,%esp
  801597:	5b                   	pop    %ebx
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 1c             	sub    $0x1c,%esp
  8015a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ae:	eb 23                	jmp    8015d3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b0:	89 f0                	mov    %esi,%eax
  8015b2:	29 d8                	sub    %ebx,%eax
  8015b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bb:	01 d8                	add    %ebx,%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	89 3c 24             	mov    %edi,(%esp)
  8015c4:	e8 41 ff ff ff       	call   80150a <read>
		if (m < 0)
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 10                	js     8015dd <readn+0x43>
			return m;
		if (m == 0)
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	74 0a                	je     8015db <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d1:	01 c3                	add    %eax,%ebx
  8015d3:	39 f3                	cmp    %esi,%ebx
  8015d5:	72 d9                	jb     8015b0 <readn+0x16>
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	eb 02                	jmp    8015dd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015db:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015dd:	83 c4 1c             	add    $0x1c,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 24             	sub    $0x24,%esp
  8015ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 70 fc ff ff       	call   80126e <fd_lookup>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 68                	js     80166a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	89 44 24 04          	mov    %eax,0x4(%esp)
  801609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160c:	8b 00                	mov    (%eax),%eax
  80160e:	89 04 24             	mov    %eax,(%esp)
  801611:	e8 ae fc ff ff       	call   8012c4 <dev_lookup>
  801616:	85 c0                	test   %eax,%eax
  801618:	78 50                	js     80166a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801621:	75 23                	jne    801646 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801623:	a1 04 40 80 00       	mov    0x804004,%eax
  801628:	8b 40 48             	mov    0x48(%eax),%eax
  80162b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	c7 04 24 69 29 80 00 	movl   $0x802969,(%esp)
  80163a:	e8 81 eb ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  80163f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801644:	eb 24                	jmp    80166a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801646:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801649:	8b 52 0c             	mov    0xc(%edx),%edx
  80164c:	85 d2                	test   %edx,%edx
  80164e:	74 15                	je     801665 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801650:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801653:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801657:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80165e:	89 04 24             	mov    %eax,(%esp)
  801661:	ff d2                	call   *%edx
  801663:	eb 05                	jmp    80166a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801665:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80166a:	83 c4 24             	add    $0x24,%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <seek>:

int
seek(int fdnum, off_t offset)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801676:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	89 04 24             	mov    %eax,(%esp)
  801683:	e8 e6 fb ff ff       	call   80126e <fd_lookup>
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 0e                	js     80169a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80168c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80168f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801692:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 24             	sub    $0x24,%esp
  8016a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ad:	89 1c 24             	mov    %ebx,(%esp)
  8016b0:	e8 b9 fb ff ff       	call   80126e <fd_lookup>
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 61                	js     80171a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c3:	8b 00                	mov    (%eax),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 f7 fb ff ff       	call   8012c4 <dev_lookup>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 49                	js     80171a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d8:	75 23                	jne    8016fd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016da:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016df:	8b 40 48             	mov    0x48(%eax),%eax
  8016e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ea:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  8016f1:	e8 ca ea ff ff       	call   8001c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fb:	eb 1d                	jmp    80171a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801700:	8b 52 18             	mov    0x18(%edx),%edx
  801703:	85 d2                	test   %edx,%edx
  801705:	74 0e                	je     801715 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	ff d2                	call   *%edx
  801713:	eb 05                	jmp    80171a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801715:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80171a:	83 c4 24             	add    $0x24,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 24             	sub    $0x24,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	89 04 24             	mov    %eax,(%esp)
  801737:	e8 32 fb ff ff       	call   80126e <fd_lookup>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 52                	js     801792 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801743:	89 44 24 04          	mov    %eax,0x4(%esp)
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	8b 00                	mov    (%eax),%eax
  80174c:	89 04 24             	mov    %eax,(%esp)
  80174f:	e8 70 fb ff ff       	call   8012c4 <dev_lookup>
  801754:	85 c0                	test   %eax,%eax
  801756:	78 3a                	js     801792 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175f:	74 2c                	je     80178d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801761:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801764:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80176b:	00 00 00 
	stat->st_isdir = 0;
  80176e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801775:	00 00 00 
	stat->st_dev = dev;
  801778:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801782:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801785:	89 14 24             	mov    %edx,(%esp)
  801788:	ff 50 14             	call   *0x14(%eax)
  80178b:	eb 05                	jmp    801792 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80178d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801792:	83 c4 24             	add    $0x24,%esp
  801795:	5b                   	pop    %ebx
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017a7:	00 
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	89 04 24             	mov    %eax,(%esp)
  8017ae:	e8 fe 01 00 00       	call   8019b1 <open>
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 1b                	js     8017d4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c0:	89 1c 24             	mov    %ebx,(%esp)
  8017c3:	e8 58 ff ff ff       	call   801720 <fstat>
  8017c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ca:	89 1c 24             	mov    %ebx,(%esp)
  8017cd:	e8 d4 fb ff ff       	call   8013a6 <close>
	return r;
  8017d2:	89 f3                	mov    %esi,%ebx
}
  8017d4:	89 d8                	mov    %ebx,%eax
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    
  8017dd:	00 00                	add    %al,(%eax)
	...

008017e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 10             	sub    $0x10,%esp
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f3:	75 11                	jne    801806 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017fc:	e8 54 09 00 00       	call   802155 <ipc_find_env>
  801801:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801806:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80180d:	00 
  80180e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801815:	00 
  801816:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181a:	a1 00 40 80 00       	mov    0x804000,%eax
  80181f:	89 04 24             	mov    %eax,(%esp)
  801822:	e8 c4 08 00 00       	call   8020eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801827:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80182e:	00 
  80182f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183a:	e8 45 08 00 00       	call   802084 <ipc_recv>
}
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 40 0c             	mov    0xc(%eax),%eax
  801852:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 02 00 00 00       	mov    $0x2,%eax
  801869:	e8 72 ff ff ff       	call   8017e0 <fsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 06 00 00 00       	mov    $0x6,%eax
  80188b:	e8 50 ff ff ff       	call   8017e0 <fsipc>
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 14             	sub    $0x14,%esp
  801899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b1:	e8 2a ff ff ff       	call   8017e0 <fsipc>
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 2b                	js     8018e5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018c1:	00 
  8018c2:	89 1c 24             	mov    %ebx,(%esp)
  8018c5:	e8 c1 ee ff ff       	call   80078b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8018cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8018da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e5:	83 c4 14             	add    $0x14,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018f1:	c7 44 24 08 98 29 80 	movl   $0x802998,0x8(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801900:	00 
  801901:	c7 04 24 b6 29 80 00 	movl   $0x8029b6,(%esp)
  801908:	e8 5b 06 00 00       	call   801f68 <_panic>

0080190d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 10             	sub    $0x10,%esp
  801915:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	8b 40 0c             	mov    0xc(%eax),%eax
  80191e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801923:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	b8 03 00 00 00       	mov    $0x3,%eax
  801933:	e8 a8 fe ff ff       	call   8017e0 <fsipc>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 6a                	js     8019a8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80193e:	39 c6                	cmp    %eax,%esi
  801940:	73 24                	jae    801966 <devfile_read+0x59>
  801942:	c7 44 24 0c c1 29 80 	movl   $0x8029c1,0xc(%esp)
  801949:	00 
  80194a:	c7 44 24 08 c8 29 80 	movl   $0x8029c8,0x8(%esp)
  801951:	00 
  801952:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801959:	00 
  80195a:	c7 04 24 b6 29 80 00 	movl   $0x8029b6,(%esp)
  801961:	e8 02 06 00 00       	call   801f68 <_panic>
	assert(r <= PGSIZE);
  801966:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196b:	7e 24                	jle    801991 <devfile_read+0x84>
  80196d:	c7 44 24 0c dd 29 80 	movl   $0x8029dd,0xc(%esp)
  801974:	00 
  801975:	c7 44 24 08 c8 29 80 	movl   $0x8029c8,0x8(%esp)
  80197c:	00 
  80197d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801984:	00 
  801985:	c7 04 24 b6 29 80 00 	movl   $0x8029b6,(%esp)
  80198c:	e8 d7 05 00 00       	call   801f68 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801991:	89 44 24 08          	mov    %eax,0x8(%esp)
  801995:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80199c:	00 
  80199d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a0:	89 04 24             	mov    %eax,(%esp)
  8019a3:	e8 5c ef ff ff       	call   800904 <memmove>
	return r;
}
  8019a8:	89 d8                	mov    %ebx,%eax
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	5b                   	pop    %ebx
  8019ae:	5e                   	pop    %esi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 20             	sub    $0x20,%esp
  8019b9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019bc:	89 34 24             	mov    %esi,(%esp)
  8019bf:	e8 94 ed ff ff       	call   800758 <strlen>
  8019c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c9:	7f 60                	jg     801a2b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 45 f8 ff ff       	call   80121b <fd_alloc>
  8019d6:	89 c3                	mov    %eax,%ebx
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 54                	js     801a30 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019e7:	e8 9f ed ff ff       	call   80078b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fc:	e8 df fd ff ff       	call   8017e0 <fsipc>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	79 15                	jns    801a1c <open+0x6b>
		fd_close(fd, 0);
  801a07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0e:	00 
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 04 f9 ff ff       	call   80131e <fd_close>
		return r;
  801a1a:	eb 14                	jmp    801a30 <open+0x7f>
	}

	return fd2num(fd);
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 c9 f7 ff ff       	call   8011f0 <fd2num>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	eb 05                	jmp    801a30 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a2b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a30:	89 d8                	mov    %ebx,%eax
  801a32:	83 c4 20             	add    $0x20,%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a44:	b8 08 00 00 00       	mov    $0x8,%eax
  801a49:	e8 92 fd ff ff       	call   8017e0 <fsipc>
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	83 ec 10             	sub    $0x10,%esp
  801a58:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	89 04 24             	mov    %eax,(%esp)
  801a61:	e8 9a f7 ff ff       	call   801200 <fd2data>
  801a66:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a68:	c7 44 24 04 e9 29 80 	movl   $0x8029e9,0x4(%esp)
  801a6f:	00 
  801a70:	89 34 24             	mov    %esi,(%esp)
  801a73:	e8 13 ed ff ff       	call   80078b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a78:	8b 43 04             	mov    0x4(%ebx),%eax
  801a7b:	2b 03                	sub    (%ebx),%eax
  801a7d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a83:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a8a:	00 00 00 
	stat->st_dev = &devpipe;
  801a8d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a94:	30 80 00 
	return 0;
}
  801a97:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 14             	sub    $0x14,%esp
  801aaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab8:	e8 67 f1 ff ff       	call   800c24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801abd:	89 1c 24             	mov    %ebx,(%esp)
  801ac0:	e8 3b f7 ff ff       	call   801200 <fd2data>
  801ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad0:	e8 4f f1 ff ff       	call   800c24 <sys_page_unmap>
}
  801ad5:	83 c4 14             	add    $0x14,%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 2c             	sub    $0x2c,%esp
  801ae4:	89 c7                	mov    %eax,%edi
  801ae6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae9:	a1 04 40 80 00       	mov    0x804004,%eax
  801aee:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801af1:	89 3c 24             	mov    %edi,(%esp)
  801af4:	e8 a3 06 00 00       	call   80219c <pageref>
  801af9:	89 c6                	mov    %eax,%esi
  801afb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	e8 96 06 00 00       	call   80219c <pageref>
  801b06:	39 c6                	cmp    %eax,%esi
  801b08:	0f 94 c0             	sete   %al
  801b0b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b14:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b17:	39 cb                	cmp    %ecx,%ebx
  801b19:	75 08                	jne    801b23 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b1b:	83 c4 2c             	add    $0x2c,%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b23:	83 f8 01             	cmp    $0x1,%eax
  801b26:	75 c1                	jne    801ae9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b28:	8b 42 58             	mov    0x58(%edx),%eax
  801b2b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801b32:	00 
  801b33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b3b:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  801b42:	e8 79 e6 ff ff       	call   8001c0 <cprintf>
  801b47:	eb a0                	jmp    801ae9 <_pipeisclosed+0xe>

00801b49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 1c             	sub    $0x1c,%esp
  801b52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b55:	89 34 24             	mov    %esi,(%esp)
  801b58:	e8 a3 f6 ff ff       	call   801200 <fd2data>
  801b5d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b64:	eb 3c                	jmp    801ba2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b66:	89 da                	mov    %ebx,%edx
  801b68:	89 f0                	mov    %esi,%eax
  801b6a:	e8 6c ff ff ff       	call   801adb <_pipeisclosed>
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	75 38                	jne    801bab <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b73:	e8 e6 ef ff ff       	call   800b5e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b78:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7b:	8b 13                	mov    (%ebx),%edx
  801b7d:	83 c2 20             	add    $0x20,%edx
  801b80:	39 d0                	cmp    %edx,%eax
  801b82:	73 e2                	jae    801b66 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b87:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b92:	79 05                	jns    801b99 <devpipe_write+0x50>
  801b94:	4a                   	dec    %edx
  801b95:	83 ca e0             	or     $0xffffffe0,%edx
  801b98:	42                   	inc    %edx
  801b99:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b9d:	40                   	inc    %eax
  801b9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba1:	47                   	inc    %edi
  801ba2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba5:	75 d1                	jne    801b78 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba7:	89 f8                	mov    %edi,%eax
  801ba9:	eb 05                	jmp    801bb0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 1c             	sub    $0x1c,%esp
  801bc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bc4:	89 3c 24             	mov    %edi,(%esp)
  801bc7:	e8 34 f6 ff ff       	call   801200 <fd2data>
  801bcc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bce:	be 00 00 00 00       	mov    $0x0,%esi
  801bd3:	eb 3a                	jmp    801c0f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd5:	85 f6                	test   %esi,%esi
  801bd7:	74 04                	je     801bdd <devpipe_read+0x25>
				return i;
  801bd9:	89 f0                	mov    %esi,%eax
  801bdb:	eb 40                	jmp    801c1d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bdd:	89 da                	mov    %ebx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	e8 f5 fe ff ff       	call   801adb <_pipeisclosed>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	75 2e                	jne    801c18 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bea:	e8 6f ef ff ff       	call   800b5e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bef:	8b 03                	mov    (%ebx),%eax
  801bf1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf4:	74 df                	je     801bd5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bfb:	79 05                	jns    801c02 <devpipe_read+0x4a>
  801bfd:	48                   	dec    %eax
  801bfe:	83 c8 e0             	or     $0xffffffe0,%eax
  801c01:	40                   	inc    %eax
  801c02:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c09:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c0c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0e:	46                   	inc    %esi
  801c0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c12:	75 db                	jne    801bef <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c14:	89 f0                	mov    %esi,%eax
  801c16:	eb 05                	jmp    801c1d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c1d:	83 c4 1c             	add    $0x1c,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	57                   	push   %edi
  801c29:	56                   	push   %esi
  801c2a:	53                   	push   %ebx
  801c2b:	83 ec 3c             	sub    $0x3c,%esp
  801c2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	e8 df f5 ff ff       	call   80121b <fd_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	0f 88 45 01 00 00    	js     801d8b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c4d:	00 
  801c4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5c:	e8 1c ef ff ff       	call   800b7d <sys_page_alloc>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	85 c0                	test   %eax,%eax
  801c65:	0f 88 20 01 00 00    	js     801d8b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 a5 f5 ff ff       	call   80121b <fd_alloc>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	0f 88 f8 00 00 00    	js     801d78 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c80:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c87:	00 
  801c88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c96:	e8 e2 ee ff ff       	call   800b7d <sys_page_alloc>
  801c9b:	89 c3                	mov    %eax,%ebx
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	0f 88 d3 00 00 00    	js     801d78 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca8:	89 04 24             	mov    %eax,(%esp)
  801cab:	e8 50 f5 ff ff       	call   801200 <fd2data>
  801cb0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cb9:	00 
  801cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc5:	e8 b3 ee ff ff       	call   800b7d <sys_page_alloc>
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 88 91 00 00 00    	js     801d65 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cd7:	89 04 24             	mov    %eax,(%esp)
  801cda:	e8 21 f5 ff ff       	call   801200 <fd2data>
  801cdf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ce6:	00 
  801ce7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ceb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cf2:	00 
  801cf3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfe:	e8 ce ee ff ff       	call   800bd1 <sys_page_map>
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 4c                	js     801d55 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d24:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d36:	89 04 24             	mov    %eax,(%esp)
  801d39:	e8 b2 f4 ff ff       	call   8011f0 <fd2num>
  801d3e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d43:	89 04 24             	mov    %eax,(%esp)
  801d46:	e8 a5 f4 ff ff       	call   8011f0 <fd2num>
  801d4b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d53:	eb 36                	jmp    801d8b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801d55:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d60:	e8 bf ee ff ff       	call   800c24 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d73:	e8 ac ee ff ff       	call   800c24 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d86:	e8 99 ee ff ff       	call   800c24 <sys_page_unmap>
    err:
	return r;
}
  801d8b:	89 d8                	mov    %ebx,%eax
  801d8d:	83 c4 3c             	add    $0x3c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	89 04 24             	mov    %eax,(%esp)
  801da8:	e8 c1 f4 ff ff       	call   80126e <fd_lookup>
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 15                	js     801dc6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db4:	89 04 24             	mov    %eax,(%esp)
  801db7:	e8 44 f4 ff ff       	call   801200 <fd2data>
	return _pipeisclosed(fd, p);
  801dbc:	89 c2                	mov    %eax,%edx
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	e8 15 fd ff ff       	call   801adb <_pipeisclosed>
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801dd8:	c7 44 24 04 08 2a 80 	movl   $0x802a08,0x4(%esp)
  801ddf:	00 
  801de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de3:	89 04 24             	mov    %eax,(%esp)
  801de6:	e8 a0 e9 ff ff       	call   80078b <strcpy>
	return 0;
}
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	57                   	push   %edi
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e03:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e09:	eb 30                	jmp    801e3b <devcons_write+0x49>
		m = n - tot;
  801e0b:	8b 75 10             	mov    0x10(%ebp),%esi
  801e0e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801e10:	83 fe 7f             	cmp    $0x7f,%esi
  801e13:	76 05                	jbe    801e1a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801e15:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e1a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801e1e:	03 45 0c             	add    0xc(%ebp),%eax
  801e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e25:	89 3c 24             	mov    %edi,(%esp)
  801e28:	e8 d7 ea ff ff       	call   800904 <memmove>
		sys_cputs(buf, m);
  801e2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e31:	89 3c 24             	mov    %edi,(%esp)
  801e34:	e8 77 ec ff ff       	call   800ab0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e39:	01 f3                	add    %esi,%ebx
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e40:	72 c9                	jb     801e0b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e42:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e57:	75 07                	jne    801e60 <devcons_read+0x13>
  801e59:	eb 25                	jmp    801e80 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e5b:	e8 fe ec ff ff       	call   800b5e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e60:	e8 69 ec ff ff       	call   800ace <sys_cgetc>
  801e65:	85 c0                	test   %eax,%eax
  801e67:	74 f2                	je     801e5b <devcons_read+0xe>
  801e69:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 1d                	js     801e8c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e6f:	83 f8 04             	cmp    $0x4,%eax
  801e72:	74 13                	je     801e87 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	88 10                	mov    %dl,(%eax)
	return 1;
  801e79:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7e:	eb 0c                	jmp    801e8c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
  801e85:	eb 05                	jmp    801e8c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e87:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e94:	8b 45 08             	mov    0x8(%ebp),%eax
  801e97:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ea1:	00 
  801ea2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea5:	89 04 24             	mov    %eax,(%esp)
  801ea8:	e8 03 ec ff ff       	call   800ab0 <sys_cputs>
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <getchar>:

int
getchar(void)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eb5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ebc:	00 
  801ebd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecb:	e8 3a f6 ff ff       	call   80150a <read>
	if (r < 0)
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 0f                	js     801ee3 <getchar+0x34>
		return r;
	if (r < 1)
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	7e 06                	jle    801ede <getchar+0x2f>
		return -E_EOF;
	return c;
  801ed8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801edc:	eb 05                	jmp    801ee3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ede:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	89 04 24             	mov    %eax,(%esp)
  801ef8:	e8 71 f3 ff ff       	call   80126e <fd_lookup>
  801efd:	85 c0                	test   %eax,%eax
  801eff:	78 11                	js     801f12 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f0a:	39 10                	cmp    %edx,(%eax)
  801f0c:	0f 94 c0             	sete   %al
  801f0f:	0f b6 c0             	movzbl %al,%eax
}
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <opencons>:

int
opencons(void)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1d:	89 04 24             	mov    %eax,(%esp)
  801f20:	e8 f6 f2 ff ff       	call   80121b <fd_alloc>
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 3c                	js     801f65 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f29:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f30:	00 
  801f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3f:	e8 39 ec ff ff       	call   800b7d <sys_page_alloc>
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 1d                	js     801f65 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f48:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f5d:	89 04 24             	mov    %eax,(%esp)
  801f60:	e8 8b f2 ff ff       	call   8011f0 <fd2num>
}
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    
	...

00801f68 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	56                   	push   %esi
  801f6c:	53                   	push   %ebx
  801f6d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801f70:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f73:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801f79:	e8 c1 eb ff ff       	call   800b3f <sys_getenvid>
  801f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f81:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f85:	8b 55 08             	mov    0x8(%ebp),%edx
  801f88:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f8c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f94:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  801f9b:	e8 20 e2 ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fa0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa7:	89 04 24             	mov    %eax,(%esp)
  801faa:	e8 b0 e1 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  801faf:	c7 04 24 d4 24 80 00 	movl   $0x8024d4,(%esp)
  801fb6:	e8 05 e2 ff ff       	call   8001c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fbb:	cc                   	int3   
  801fbc:	eb fd                	jmp    801fbb <_panic+0x53>
	...

00801fc0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fc6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fcd:	0f 85 80 00 00 00    	jne    802053 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  801fd3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd8:	8b 40 48             	mov    0x48(%eax),%eax
  801fdb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801fe2:	00 
  801fe3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801fea:	ee 
  801feb:	89 04 24             	mov    %eax,(%esp)
  801fee:	e8 8a eb ff ff       	call   800b7d <sys_page_alloc>
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	79 20                	jns    802017 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  801ff7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffb:	c7 44 24 08 38 2a 80 	movl   $0x802a38,0x8(%esp)
  802002:	00 
  802003:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80200a:	00 
  80200b:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  802012:	e8 51 ff ff ff       	call   801f68 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  802017:	a1 04 40 80 00       	mov    0x804004,%eax
  80201c:	8b 40 48             	mov    0x48(%eax),%eax
  80201f:	c7 44 24 04 60 20 80 	movl   $0x802060,0x4(%esp)
  802026:	00 
  802027:	89 04 24             	mov    %eax,(%esp)
  80202a:	e8 ee ec ff ff       	call   800d1d <sys_env_set_pgfault_upcall>
  80202f:	85 c0                	test   %eax,%eax
  802031:	79 20                	jns    802053 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  802033:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802037:	c7 44 24 08 64 2a 80 	movl   $0x802a64,0x8(%esp)
  80203e:	00 
  80203f:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  802046:	00 
  802047:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  80204e:	e8 15 ff ff ff       	call   801f68 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802053:	8b 45 08             	mov    0x8(%ebp),%eax
  802056:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    
  80205d:	00 00                	add    %al,(%eax)
	...

00802060 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802060:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802061:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802066:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802068:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  80206b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80206f:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802071:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802074:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802075:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802078:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  80207a:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  80207d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80207e:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802081:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802082:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802083:	c3                   	ret    

00802084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 10             	sub    $0x10,%esp
  80208c:	8b 75 08             	mov    0x8(%ebp),%esi
  80208f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802092:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802095:	85 c0                	test   %eax,%eax
  802097:	75 05                	jne    80209e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  802099:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80209e:	89 04 24             	mov    %eax,(%esp)
  8020a1:	e8 ed ec ff ff       	call   800d93 <sys_ipc_recv>
	if (!err) {
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	75 26                	jne    8020d0 <ipc_recv+0x4c>
		if (from_env_store) {
  8020aa:	85 f6                	test   %esi,%esi
  8020ac:	74 0a                	je     8020b8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8020ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8020b3:	8b 40 74             	mov    0x74(%eax),%eax
  8020b6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8020b8:	85 db                	test   %ebx,%ebx
  8020ba:	74 0a                	je     8020c6 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8020bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c1:	8b 40 78             	mov    0x78(%eax),%eax
  8020c4:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8020c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020cb:	8b 40 70             	mov    0x70(%eax),%eax
  8020ce:	eb 14                	jmp    8020e4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8020d0:	85 f6                	test   %esi,%esi
  8020d2:	74 06                	je     8020da <ipc_recv+0x56>
		*from_env_store = 0;
  8020d4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8020da:	85 db                	test   %ebx,%ebx
  8020dc:	74 06                	je     8020e4 <ipc_recv+0x60>
		*perm_store = 0;
  8020de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5d                   	pop    %ebp
  8020ea:	c3                   	ret    

008020eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	57                   	push   %edi
  8020ef:	56                   	push   %esi
  8020f0:	53                   	push   %ebx
  8020f1:	83 ec 1c             	sub    $0x1c,%esp
  8020f4:	8b 75 10             	mov    0x10(%ebp),%esi
  8020f7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8020fa:	85 f6                	test   %esi,%esi
  8020fc:	75 05                	jne    802103 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8020fe:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  802103:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802107:	89 74 24 08          	mov    %esi,0x8(%esp)
  80210b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802112:	8b 45 08             	mov    0x8(%ebp),%eax
  802115:	89 04 24             	mov    %eax,(%esp)
  802118:	e8 53 ec ff ff       	call   800d70 <sys_ipc_try_send>
  80211d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80211f:	e8 3a ea ff ff       	call   800b5e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802124:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802127:	74 da                	je     802103 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802129:	85 db                	test   %ebx,%ebx
  80212b:	74 20                	je     80214d <ipc_send+0x62>
		panic("send fail: %e", err);
  80212d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802131:	c7 44 24 08 a2 2a 80 	movl   $0x802aa2,0x8(%esp)
  802138:	00 
  802139:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802140:	00 
  802141:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  802148:	e8 1b fe ff ff       	call   801f68 <_panic>
	}
	return;
}
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	53                   	push   %ebx
  802159:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80215c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802161:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802168:	89 c2                	mov    %eax,%edx
  80216a:	c1 e2 07             	shl    $0x7,%edx
  80216d:	29 ca                	sub    %ecx,%edx
  80216f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802175:	8b 52 50             	mov    0x50(%edx),%edx
  802178:	39 da                	cmp    %ebx,%edx
  80217a:	75 0f                	jne    80218b <ipc_find_env+0x36>
			return envs[i].env_id;
  80217c:	c1 e0 07             	shl    $0x7,%eax
  80217f:	29 c8                	sub    %ecx,%eax
  802181:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802186:	8b 40 40             	mov    0x40(%eax),%eax
  802189:	eb 0c                	jmp    802197 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80218b:	40                   	inc    %eax
  80218c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802191:	75 ce                	jne    802161 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802193:	66 b8 00 00          	mov    $0x0,%ax
}
  802197:	5b                   	pop    %ebx
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    
	...

0080219c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a2:	89 c2                	mov    %eax,%edx
  8021a4:	c1 ea 16             	shr    $0x16,%edx
  8021a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021ae:	f6 c2 01             	test   $0x1,%dl
  8021b1:	74 1e                	je     8021d1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b3:	c1 e8 0c             	shr    $0xc,%eax
  8021b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021bd:	a8 01                	test   $0x1,%al
  8021bf:	74 17                	je     8021d8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c1:	c1 e8 0c             	shr    $0xc,%eax
  8021c4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8021cb:	ef 
  8021cc:	0f b7 c0             	movzwl %ax,%eax
  8021cf:	eb 0c                	jmp    8021dd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8021d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d6:	eb 05                	jmp    8021dd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021d8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    
	...

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	83 ec 10             	sub    $0x10,%esp
  8021e6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8021ea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8021f6:	89 cd                	mov    %ecx,%ebp
  8021f8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	75 2c                	jne    80222c <__udivdi3+0x4c>
  802200:	39 f9                	cmp    %edi,%ecx
  802202:	77 68                	ja     80226c <__udivdi3+0x8c>
  802204:	85 c9                	test   %ecx,%ecx
  802206:	75 0b                	jne    802213 <__udivdi3+0x33>
  802208:	b8 01 00 00 00       	mov    $0x1,%eax
  80220d:	31 d2                	xor    %edx,%edx
  80220f:	f7 f1                	div    %ecx
  802211:	89 c1                	mov    %eax,%ecx
  802213:	31 d2                	xor    %edx,%edx
  802215:	89 f8                	mov    %edi,%eax
  802217:	f7 f1                	div    %ecx
  802219:	89 c7                	mov    %eax,%edi
  80221b:	89 f0                	mov    %esi,%eax
  80221d:	f7 f1                	div    %ecx
  80221f:	89 c6                	mov    %eax,%esi
  802221:	89 f0                	mov    %esi,%eax
  802223:	89 fa                	mov    %edi,%edx
  802225:	83 c4 10             	add    $0x10,%esp
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	39 f8                	cmp    %edi,%eax
  80222e:	77 2c                	ja     80225c <__udivdi3+0x7c>
  802230:	0f bd f0             	bsr    %eax,%esi
  802233:	83 f6 1f             	xor    $0x1f,%esi
  802236:	75 4c                	jne    802284 <__udivdi3+0xa4>
  802238:	39 f8                	cmp    %edi,%eax
  80223a:	bf 00 00 00 00       	mov    $0x0,%edi
  80223f:	72 0a                	jb     80224b <__udivdi3+0x6b>
  802241:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802245:	0f 87 ad 00 00 00    	ja     8022f8 <__udivdi3+0x118>
  80224b:	be 01 00 00 00       	mov    $0x1,%esi
  802250:	89 f0                	mov    %esi,%eax
  802252:	89 fa                	mov    %edi,%edx
  802254:	83 c4 10             	add    $0x10,%esp
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	90                   	nop
  80225c:	31 ff                	xor    %edi,%edi
  80225e:	31 f6                	xor    %esi,%esi
  802260:	89 f0                	mov    %esi,%eax
  802262:	89 fa                	mov    %edi,%edx
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
  80226b:	90                   	nop
  80226c:	89 fa                	mov    %edi,%edx
  80226e:	89 f0                	mov    %esi,%eax
  802270:	f7 f1                	div    %ecx
  802272:	89 c6                	mov    %eax,%esi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 f0                	mov    %esi,%eax
  802278:	89 fa                	mov    %edi,%edx
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	5e                   	pop    %esi
  80227e:	5f                   	pop    %edi
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    
  802281:	8d 76 00             	lea    0x0(%esi),%esi
  802284:	89 f1                	mov    %esi,%ecx
  802286:	d3 e0                	shl    %cl,%eax
  802288:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228c:	b8 20 00 00 00       	mov    $0x20,%eax
  802291:	29 f0                	sub    %esi,%eax
  802293:	89 ea                	mov    %ebp,%edx
  802295:	88 c1                	mov    %al,%cl
  802297:	d3 ea                	shr    %cl,%edx
  802299:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80229d:	09 ca                	or     %ecx,%edx
  80229f:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022a3:	89 f1                	mov    %esi,%ecx
  8022a5:	d3 e5                	shl    %cl,%ebp
  8022a7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8022ab:	89 fd                	mov    %edi,%ebp
  8022ad:	88 c1                	mov    %al,%cl
  8022af:	d3 ed                	shr    %cl,%ebp
  8022b1:	89 fa                	mov    %edi,%edx
  8022b3:	89 f1                	mov    %esi,%ecx
  8022b5:	d3 e2                	shl    %cl,%edx
  8022b7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022bb:	88 c1                	mov    %al,%cl
  8022bd:	d3 ef                	shr    %cl,%edi
  8022bf:	09 d7                	or     %edx,%edi
  8022c1:	89 f8                	mov    %edi,%eax
  8022c3:	89 ea                	mov    %ebp,%edx
  8022c5:	f7 74 24 08          	divl   0x8(%esp)
  8022c9:	89 d1                	mov    %edx,%ecx
  8022cb:	89 c7                	mov    %eax,%edi
  8022cd:	f7 64 24 0c          	mull   0xc(%esp)
  8022d1:	39 d1                	cmp    %edx,%ecx
  8022d3:	72 17                	jb     8022ec <__udivdi3+0x10c>
  8022d5:	74 09                	je     8022e0 <__udivdi3+0x100>
  8022d7:	89 fe                	mov    %edi,%esi
  8022d9:	31 ff                	xor    %edi,%edi
  8022db:	e9 41 ff ff ff       	jmp    802221 <__udivdi3+0x41>
  8022e0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022e4:	89 f1                	mov    %esi,%ecx
  8022e6:	d3 e2                	shl    %cl,%edx
  8022e8:	39 c2                	cmp    %eax,%edx
  8022ea:	73 eb                	jae    8022d7 <__udivdi3+0xf7>
  8022ec:	8d 77 ff             	lea    -0x1(%edi),%esi
  8022ef:	31 ff                	xor    %edi,%edi
  8022f1:	e9 2b ff ff ff       	jmp    802221 <__udivdi3+0x41>
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	31 f6                	xor    %esi,%esi
  8022fa:	e9 22 ff ff ff       	jmp    802221 <__udivdi3+0x41>
	...

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	83 ec 20             	sub    $0x20,%esp
  802306:	8b 44 24 30          	mov    0x30(%esp),%eax
  80230a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80230e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802312:	8b 74 24 34          	mov    0x34(%esp),%esi
  802316:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80231e:	89 c7                	mov    %eax,%edi
  802320:	89 f2                	mov    %esi,%edx
  802322:	85 ed                	test   %ebp,%ebp
  802324:	75 16                	jne    80233c <__umoddi3+0x3c>
  802326:	39 f1                	cmp    %esi,%ecx
  802328:	0f 86 a6 00 00 00    	jbe    8023d4 <__umoddi3+0xd4>
  80232e:	f7 f1                	div    %ecx
  802330:	89 d0                	mov    %edx,%eax
  802332:	31 d2                	xor    %edx,%edx
  802334:	83 c4 20             	add    $0x20,%esp
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    
  80233b:	90                   	nop
  80233c:	39 f5                	cmp    %esi,%ebp
  80233e:	0f 87 ac 00 00 00    	ja     8023f0 <__umoddi3+0xf0>
  802344:	0f bd c5             	bsr    %ebp,%eax
  802347:	83 f0 1f             	xor    $0x1f,%eax
  80234a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80234e:	0f 84 a8 00 00 00    	je     8023fc <__umoddi3+0xfc>
  802354:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802358:	d3 e5                	shl    %cl,%ebp
  80235a:	bf 20 00 00 00       	mov    $0x20,%edi
  80235f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802363:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802367:	89 f9                	mov    %edi,%ecx
  802369:	d3 e8                	shr    %cl,%eax
  80236b:	09 e8                	or     %ebp,%eax
  80236d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802371:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802375:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802379:	d3 e0                	shl    %cl,%eax
  80237b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80237f:	89 f2                	mov    %esi,%edx
  802381:	d3 e2                	shl    %cl,%edx
  802383:	8b 44 24 14          	mov    0x14(%esp),%eax
  802387:	d3 e0                	shl    %cl,%eax
  802389:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80238d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802391:	89 f9                	mov    %edi,%ecx
  802393:	d3 e8                	shr    %cl,%eax
  802395:	09 d0                	or     %edx,%eax
  802397:	d3 ee                	shr    %cl,%esi
  802399:	89 f2                	mov    %esi,%edx
  80239b:	f7 74 24 18          	divl   0x18(%esp)
  80239f:	89 d6                	mov    %edx,%esi
  8023a1:	f7 64 24 0c          	mull   0xc(%esp)
  8023a5:	89 c5                	mov    %eax,%ebp
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	39 d6                	cmp    %edx,%esi
  8023ab:	72 67                	jb     802414 <__umoddi3+0x114>
  8023ad:	74 75                	je     802424 <__umoddi3+0x124>
  8023af:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023b3:	29 e8                	sub    %ebp,%eax
  8023b5:	19 ce                	sbb    %ecx,%esi
  8023b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023bb:	d3 e8                	shr    %cl,%eax
  8023bd:	89 f2                	mov    %esi,%edx
  8023bf:	89 f9                	mov    %edi,%ecx
  8023c1:	d3 e2                	shl    %cl,%edx
  8023c3:	09 d0                	or     %edx,%eax
  8023c5:	89 f2                	mov    %esi,%edx
  8023c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	83 c4 20             	add    $0x20,%esp
  8023d0:	5e                   	pop    %esi
  8023d1:	5f                   	pop    %edi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    
  8023d4:	85 c9                	test   %ecx,%ecx
  8023d6:	75 0b                	jne    8023e3 <__umoddi3+0xe3>
  8023d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023dd:	31 d2                	xor    %edx,%edx
  8023df:	f7 f1                	div    %ecx
  8023e1:	89 c1                	mov    %eax,%ecx
  8023e3:	89 f0                	mov    %esi,%eax
  8023e5:	31 d2                	xor    %edx,%edx
  8023e7:	f7 f1                	div    %ecx
  8023e9:	89 f8                	mov    %edi,%eax
  8023eb:	e9 3e ff ff ff       	jmp    80232e <__umoddi3+0x2e>
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	83 c4 20             	add    $0x20,%esp
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    
  8023f9:	8d 76 00             	lea    0x0(%esi),%esi
  8023fc:	39 f5                	cmp    %esi,%ebp
  8023fe:	72 04                	jb     802404 <__umoddi3+0x104>
  802400:	39 f9                	cmp    %edi,%ecx
  802402:	77 06                	ja     80240a <__umoddi3+0x10a>
  802404:	89 f2                	mov    %esi,%edx
  802406:	29 cf                	sub    %ecx,%edi
  802408:	19 ea                	sbb    %ebp,%edx
  80240a:	89 f8                	mov    %edi,%eax
  80240c:	83 c4 20             	add    $0x20,%esp
  80240f:	5e                   	pop    %esi
  802410:	5f                   	pop    %edi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    
  802413:	90                   	nop
  802414:	89 d1                	mov    %edx,%ecx
  802416:	89 c5                	mov    %eax,%ebp
  802418:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80241c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802420:	eb 8d                	jmp    8023af <__umoddi3+0xaf>
  802422:	66 90                	xchg   %ax,%ax
  802424:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802428:	72 ea                	jb     802414 <__umoddi3+0x114>
  80242a:	89 f1                	mov    %esi,%ecx
  80242c:	eb 81                	jmp    8023af <__umoddi3+0xaf>
