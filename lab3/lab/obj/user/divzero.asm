
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 8c 0d 80 00 	movl   $0x800d8c,(%esp)
  80005c:	e8 03 01 00 00       	call   800164 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 10             	sub    $0x10,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800072:	e8 4c 0a 00 00       	call   800ac3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80007f:	c1 e0 05             	shl    $0x5,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 08 10 80 00       	mov    %eax,0x801008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 f6                	test   %esi,%esi
  80008e:	7e 07                	jle    800097 <libmain+0x33>
		binaryname = argv[0];
  800090:	8b 03                	mov    (%ebx),%eax
  800092:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800097:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009b:	89 34 24             	mov    %esi,(%esp)
  80009e:	e8 91 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a3:	e8 08 00 00 00       	call   8000b0 <exit>
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 af 09 00 00       	call   800a71 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	40                   	inc    %eax
  8000d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 19                	jne    8000fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e8:	00 
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	89 04 24             	mov    %eax,(%esp)
  8000ef:	e8 40 09 00 00       	call   800a34 <sys_cputs>
		b->idx = 0;
  8000f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fa:	ff 43 04             	incl   0x4(%ebx)
}
  8000fd:	83 c4 14             	add    $0x14,%esp
  800100:	5b                   	pop    %ebx
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	8b 45 08             	mov    0x8(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  80013f:	e8 82 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 d8 08 00 00       	call   800a34 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	8b 45 08             	mov    0x8(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 87 ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	75 08                	jne    8001ac <printnum+0x2c>
  8001a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 57                	ja     800203 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b0:	4b                   	dec    %ebx
  8001b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cb:	00 
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	e8 5e 09 00 00       	call   800b3c <__udivdi3>
  8001de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ed:	89 fa                	mov    %edi,%edx
  8001ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f2:	e8 89 ff ff ff       	call   800180 <printnum>
  8001f7:	eb 0f                	jmp    800208 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f f1                	jg     8001f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 44 24 08          	mov    %eax,0x8(%esp)
  800217:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021e:	00 
  80021f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	e8 2b 0a 00 00       	call   800c5c <__umoddi3>
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	0f be 80 a4 0d 80 00 	movsbl 0x800da4(%eax),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800242:	83 c4 3c             	add    $0x3c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024d:	83 fa 01             	cmp    $0x1,%edx
  800250:	7e 0e                	jle    800260 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 08             	lea    0x8(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x38>
	else if (lflag)
  800260:	85 d2                	test   %edx,%edx
  800262:	74 10                	je     800274 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	3b 50 04             	cmp    0x4(%eax),%edx
  800292:	73 08                	jae    80029c <sprintputch+0x18>
		*b->buf++ = ch;
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	88 0a                	mov    %cl,(%edx)
  800299:	42                   	inc    %edx
  80029a:	89 10                	mov    %edx,(%eax)
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 02 00 00 00       	call   8002c6 <vprintfmt>
	va_end(ap);
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 4c             	sub    $0x4c,%esp
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 6b 03 00 00    	je     80064a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	0f b6 06             	movzbl (%esi),%eax
  8002ec:	46                   	inc    %esi
  8002ed:	83 f8 25             	cmp    $0x25,%eax
  8002f0:	75 e5                	jne    8002d7 <vprintfmt+0x11>
  8002f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800302:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800309:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030e:	eb 26                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800313:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800317:	eb 1d                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800320:	eb 14                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800325:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80032c:	eb 08                	jmp    800336 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	0f b6 06             	movzbl (%esi),%eax
  800339:	8d 56 01             	lea    0x1(%esi),%edx
  80033c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033f:	8a 16                	mov    (%esi),%dl
  800341:	83 ea 23             	sub    $0x23,%edx
  800344:	80 fa 55             	cmp    $0x55,%dl
  800347:	0f 87 e1 02 00 00    	ja     80062e <vprintfmt+0x368>
  80034d:	0f b6 d2             	movzbl %dl,%edx
  800350:	ff 24 95 34 0e 80 00 	jmp    *0x800e34(,%edx,4)
  800357:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80035a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800362:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800366:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800369:	8d 50 d0             	lea    -0x30(%eax),%edx
  80036c:	83 fa 09             	cmp    $0x9,%edx
  80036f:	77 2a                	ja     80039b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800372:	eb eb                	jmp    80035f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 50 04             	lea    0x4(%eax),%edx
  80037a:	89 55 14             	mov    %edx,0x14(%ebp)
  80037d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800382:	eb 17                	jmp    80039b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800384:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800388:	78 98                	js     800322 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038d:	eb a7                	jmp    800336 <vprintfmt+0x70>
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800392:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800399:	eb 9b                	jmp    800336 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80039b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039f:	79 95                	jns    800336 <vprintfmt+0x70>
  8003a1:	eb 8b                	jmp    80032e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a7:	eb 8d                	jmp    800336 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 50 04             	lea    0x4(%eax),%edx
  8003af:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c1:	e9 23 ff ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 50 04             	lea    0x4(%eax),%edx
  8003cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	79 02                	jns    8003d7 <vprintfmt+0x111>
  8003d5:	f7 d8                	neg    %eax
  8003d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d9:	83 f8 06             	cmp    $0x6,%eax
  8003dc:	7f 0b                	jg     8003e9 <vprintfmt+0x123>
  8003de:	8b 04 85 8c 0f 80 00 	mov    0x800f8c(,%eax,4),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	75 23                	jne    80040c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ed:	c7 44 24 08 bc 0d 80 	movl   $0x800dbc,0x8(%esp)
  8003f4:	00 
  8003f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	e8 9a fe ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800407:	e9 dd fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80040c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800410:	c7 44 24 08 c5 0d 80 	movl   $0x800dc5,0x8(%esp)
  800417:	00 
  800418:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	89 14 24             	mov    %edx,(%esp)
  800422:	e8 77 fe ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042a:	e9 ba fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
  80042f:	89 f9                	mov    %edi,%ecx
  800431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	8b 30                	mov    (%eax),%esi
  800442:	85 f6                	test   %esi,%esi
  800444:	75 05                	jne    80044b <vprintfmt+0x185>
				p = "(null)";
  800446:	be b5 0d 80 00       	mov    $0x800db5,%esi
			if (width > 0 && padc != '-')
  80044b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044f:	0f 8e 84 00 00 00    	jle    8004d9 <vprintfmt+0x213>
  800455:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800459:	74 7e                	je     8004d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80045f:	89 34 24             	mov    %esi,(%esp)
  800462:	e8 8b 02 00 00       	call   8006f2 <strnlen>
  800467:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046a:	29 c2                	sub    %eax,%edx
  80046c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80046f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800473:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800476:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800479:	89 de                	mov    %ebx,%esi
  80047b:	89 d3                	mov    %edx,%ebx
  80047d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	eb 0b                	jmp    80048c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800481:	89 74 24 04          	mov    %esi,0x4(%esp)
  800485:	89 3c 24             	mov    %edi,(%esp)
  800488:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	4b                   	dec    %ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f f1                	jg     800481 <vprintfmt+0x1bb>
  800490:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800493:	89 f3                	mov    %esi,%ebx
  800495:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 05                	jns    8004a4 <vprintfmt+0x1de>
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a7:	29 c2                	sub    %eax,%edx
  8004a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ac:	eb 2b                	jmp    8004d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b2:	74 18                	je     8004cc <vprintfmt+0x206>
  8004b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ba:	76 10                	jbe    8004cc <vprintfmt+0x206>
					putch('?', putdat);
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	eb 0a                	jmp    8004d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d9:	0f be 06             	movsbl (%esi),%eax
  8004dc:	46                   	inc    %esi
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	74 21                	je     800502 <vprintfmt+0x23c>
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	78 c9                	js     8004ae <vprintfmt+0x1e8>
  8004e5:	4f                   	dec    %edi
  8004e6:	79 c6                	jns    8004ae <vprintfmt+0x1e8>
  8004e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004eb:	89 de                	mov    %ebx,%esi
  8004ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f0:	eb 18                	jmp    80050a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ff:	4b                   	dec    %ebx
  800500:	eb 08                	jmp    80050a <vprintfmt+0x244>
  800502:	8b 7d 08             	mov    0x8(%ebp),%edi
  800505:	89 de                	mov    %ebx,%esi
  800507:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050a:	85 db                	test   %ebx,%ebx
  80050c:	7f e4                	jg     8004f2 <vprintfmt+0x22c>
  80050e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800511:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ce fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051b:	83 f9 01             	cmp    $0x1,%ecx
  80051e:	7e 10                	jle    800530 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 08             	lea    0x8(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 30                	mov    (%eax),%esi
  80052b:	8b 78 04             	mov    0x4(%eax),%edi
  80052e:	eb 26                	jmp    800556 <vprintfmt+0x290>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 12                	je     800546 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 30                	mov    (%eax),%esi
  80053f:	89 f7                	mov    %esi,%edi
  800541:	c1 ff 1f             	sar    $0x1f,%edi
  800544:	eb 10                	jmp    800556 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 30                	mov    (%eax),%esi
  800551:	89 f7                	mov    %esi,%edi
  800553:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800556:	85 ff                	test   %edi,%edi
  800558:	78 0a                	js     800564 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055f:	e9 8c 00 00 00       	jmp    8005f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800572:	f7 de                	neg    %esi
  800574:	83 d7 00             	adc    $0x0,%edi
  800577:	f7 df                	neg    %edi
			}
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 70                	jmp    8005f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800580:	89 ca                	mov    %ecx,%edx
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
  800585:	e8 c0 fc ff ff       	call   80024a <getuint>
  80058a:	89 c6                	mov    %eax,%esi
  80058c:	89 d7                	mov    %edx,%edi
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800593:	eb 5b                	jmp    8005f0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800595:	89 ca                	mov    %ecx,%edx
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 ab fc ff ff       	call   80024a <getuint>
  80059f:	89 c6                	mov    %eax,%esi
  8005a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005a8:	eb 46                	jmp    8005f0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cf:	8b 30                	mov    (%eax),%esi
  8005d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005db:	eb 13                	jmp    8005f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dd:	89 ca                	mov    %ecx,%edx
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 63 fc ff ff       	call   80024a <getuint>
  8005e7:	89 c6                	mov    %eax,%esi
  8005e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8005eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	89 34 24             	mov    %esi,(%esp)
  800606:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060a:	89 da                	mov    %ebx,%edx
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	e8 6c fb ff ff       	call   800180 <printnum>
			break;
  800614:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800617:	e9 cd fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800629:	e9 bb fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	eb 01                	jmp    80063f <vprintfmt+0x379>
  80063e:	4e                   	dec    %esi
  80063f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800643:	75 f9                	jne    80063e <vprintfmt+0x378>
  800645:	e9 9f fc ff ff       	jmp    8002e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80064a:	83 c4 4c             	add    $0x4c,%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	83 ec 28             	sub    $0x28,%esp
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800661:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800665:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800668:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066f:	85 c0                	test   %eax,%eax
  800671:	74 30                	je     8006a3 <vsnprintf+0x51>
  800673:	85 d2                	test   %edx,%edx
  800675:	7e 33                	jle    8006aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067e:	8b 45 10             	mov    0x10(%ebp),%eax
  800681:	89 44 24 08          	mov    %eax,0x8(%esp)
  800685:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068c:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  800693:	e8 2e fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800698:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a1:	eb 0c                	jmp    8006af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a8:	eb 05                	jmp    8006af <vsnprintf+0x5d>
  8006aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006be:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	e8 7b ff ff ff       	call   800652 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    
  8006d9:	00 00                	add    %al,(%eax)
	...

008006dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e7:	eb 01                	jmp    8006ea <strlen+0xe>
		n++;
  8006e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ee:	75 f9                	jne    8006e9 <strlen+0xd>
		n++;
	return n;
}
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 01                	jmp    800703 <strnlen+0x11>
		n++;
  800702:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 d0                	cmp    %edx,%eax
  800705:	74 06                	je     80070d <strnlen+0x1b>
  800707:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070b:	75 f5                	jne    800702 <strnlen+0x10>
		n++;
	return n;
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	53                   	push   %ebx
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800719:	ba 00 00 00 00       	mov    $0x0,%edx
  80071e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800721:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800724:	42                   	inc    %edx
  800725:	84 c9                	test   %cl,%cl
  800727:	75 f5                	jne    80071e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800729:	5b                   	pop    %ebx
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800736:	89 1c 24             	mov    %ebx,(%esp)
  800739:	e8 9e ff ff ff       	call   8006dc <strlen>
	strcpy(dst + len, src);
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	89 54 24 04          	mov    %edx,0x4(%esp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	e8 c0 ff ff ff       	call   80070f <strcpy>
	return dst;
}
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	5b                   	pop    %ebx
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	56                   	push   %esi
  80075b:	53                   	push   %ebx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800762:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800765:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076a:	eb 0c                	jmp    800778 <strncpy+0x21>
		*dst++ = *src;
  80076c:	8a 1a                	mov    (%edx),%bl
  80076e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 3a 01             	cmpb   $0x1,(%edx)
  800774:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	41                   	inc    %ecx
  800778:	39 f1                	cmp    %esi,%ecx
  80077a:	75 f0                	jne    80076c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078e:	85 d2                	test   %edx,%edx
  800790:	75 0a                	jne    80079c <strlcpy+0x1c>
  800792:	89 f0                	mov    %esi,%eax
  800794:	eb 1a                	jmp    8007b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800796:	88 18                	mov    %bl,(%eax)
  800798:	40                   	inc    %eax
  800799:	41                   	inc    %ecx
  80079a:	eb 02                	jmp    80079e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80079e:	4a                   	dec    %edx
  80079f:	74 0a                	je     8007ab <strlcpy+0x2b>
  8007a1:	8a 19                	mov    (%ecx),%bl
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ef                	jne    800796 <strlcpy+0x16>
  8007a7:	89 c2                	mov    %eax,%edx
  8007a9:	eb 02                	jmp    8007ad <strlcpy+0x2d>
  8007ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b0:	29 f0                	sub    %esi,%eax
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bf:	eb 02                	jmp    8007c3 <strcmp+0xd>
		p++, q++;
  8007c1:	41                   	inc    %ecx
  8007c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c3:	8a 01                	mov    (%ecx),%al
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x17>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	74 f4                	je     8007c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e4:	eb 03                	jmp    8007e9 <strncmp+0x12>
		n--, p++, q++;
  8007e6:	4a                   	dec    %edx
  8007e7:	40                   	inc    %eax
  8007e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 14                	je     800801 <strncmp+0x2a>
  8007ed:	8a 18                	mov    (%eax),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	74 04                	je     8007f7 <strncmp+0x20>
  8007f3:	3a 19                	cmp    (%ecx),%bl
  8007f5:	74 ef                	je     8007e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f7:	0f b6 00             	movzbl (%eax),%eax
  8007fa:	0f b6 11             	movzbl (%ecx),%edx
  8007fd:	29 d0                	sub    %edx,%eax
  8007ff:	eb 05                	jmp    800806 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800812:	eb 05                	jmp    800819 <strchr+0x10>
		if (*s == c)
  800814:	38 ca                	cmp    %cl,%dl
  800816:	74 0c                	je     800824 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800818:	40                   	inc    %eax
  800819:	8a 10                	mov    (%eax),%dl
  80081b:	84 d2                	test   %dl,%dl
  80081d:	75 f5                	jne    800814 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082f:	eb 05                	jmp    800836 <strfind+0x10>
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 07                	je     80083c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800835:	40                   	inc    %eax
  800836:	8a 10                	mov    (%eax),%dl
  800838:	84 d2                	test   %dl,%dl
  80083a:	75 f5                	jne    800831 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	57                   	push   %edi
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 7d 08             	mov    0x8(%ebp),%edi
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 30                	je     800881 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800851:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800857:	75 25                	jne    80087e <memset+0x40>
  800859:	f6 c1 03             	test   $0x3,%cl
  80085c:	75 20                	jne    80087e <memset+0x40>
		c &= 0xFF;
  80085e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800861:	89 d3                	mov    %edx,%ebx
  800863:	c1 e3 08             	shl    $0x8,%ebx
  800866:	89 d6                	mov    %edx,%esi
  800868:	c1 e6 18             	shl    $0x18,%esi
  80086b:	89 d0                	mov    %edx,%eax
  80086d:	c1 e0 10             	shl    $0x10,%eax
  800870:	09 f0                	or     %esi,%eax
  800872:	09 d0                	or     %edx,%eax
  800874:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800876:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800879:	fc                   	cld    
  80087a:	f3 ab                	rep stos %eax,%es:(%edi)
  80087c:	eb 03                	jmp    800881 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087e:	fc                   	cld    
  80087f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800881:	89 f8                	mov    %edi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 75 0c             	mov    0xc(%ebp),%esi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800896:	39 c6                	cmp    %eax,%esi
  800898:	73 34                	jae    8008ce <memmove+0x46>
  80089a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089d:	39 d0                	cmp    %edx,%eax
  80089f:	73 2d                	jae    8008ce <memmove+0x46>
		s += n;
		d += n;
  8008a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a4:	f6 c2 03             	test   $0x3,%dl
  8008a7:	75 1b                	jne    8008c4 <memmove+0x3c>
  8008a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008af:	75 13                	jne    8008c4 <memmove+0x3c>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 0e                	jne    8008c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b6:	83 ef 04             	sub    $0x4,%edi
  8008b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008bf:	fd                   	std    
  8008c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c2:	eb 07                	jmp    8008cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c4:	4f                   	dec    %edi
  8008c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c8:	fd                   	std    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cb:	fc                   	cld    
  8008cc:	eb 20                	jmp    8008ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d4:	75 13                	jne    8008e9 <memmove+0x61>
  8008d6:	a8 03                	test   $0x3,%al
  8008d8:	75 0f                	jne    8008e9 <memmove+0x61>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800902:	89 44 24 04          	mov    %eax,0x4(%esp)
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	89 04 24             	mov    %eax,(%esp)
  80090c:	e8 77 ff ff ff       	call   800888 <memmove>
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800922:	ba 00 00 00 00       	mov    $0x0,%edx
  800927:	eb 16                	jmp    80093f <memcmp+0x2c>
		if (*s1 != *s2)
  800929:	8a 04 17             	mov    (%edi,%edx,1),%al
  80092c:	42                   	inc    %edx
  80092d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800931:	38 c8                	cmp    %cl,%al
  800933:	74 0a                	je     80093f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800935:	0f b6 c0             	movzbl %al,%eax
  800938:	0f b6 c9             	movzbl %cl,%ecx
  80093b:	29 c8                	sub    %ecx,%eax
  80093d:	eb 09                	jmp    800948 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093f:	39 da                	cmp    %ebx,%edx
  800941:	75 e6                	jne    800929 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800956:	89 c2                	mov    %eax,%edx
  800958:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095b:	eb 05                	jmp    800962 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095d:	38 08                	cmp    %cl,(%eax)
  80095f:	74 05                	je     800966 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800961:	40                   	inc    %eax
  800962:	39 d0                	cmp    %edx,%eax
  800964:	72 f7                	jb     80095d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 55 08             	mov    0x8(%ebp),%edx
  800971:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800974:	eb 01                	jmp    800977 <strtol+0xf>
		s++;
  800976:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800977:	8a 02                	mov    (%edx),%al
  800979:	3c 20                	cmp    $0x20,%al
  80097b:	74 f9                	je     800976 <strtol+0xe>
  80097d:	3c 09                	cmp    $0x9,%al
  80097f:	74 f5                	je     800976 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800981:	3c 2b                	cmp    $0x2b,%al
  800983:	75 08                	jne    80098d <strtol+0x25>
		s++;
  800985:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800986:	bf 00 00 00 00       	mov    $0x0,%edi
  80098b:	eb 13                	jmp    8009a0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098d:	3c 2d                	cmp    $0x2d,%al
  80098f:	75 0a                	jne    80099b <strtol+0x33>
		s++, neg = 1;
  800991:	8d 52 01             	lea    0x1(%edx),%edx
  800994:	bf 01 00 00 00       	mov    $0x1,%edi
  800999:	eb 05                	jmp    8009a0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a0:	85 db                	test   %ebx,%ebx
  8009a2:	74 05                	je     8009a9 <strtol+0x41>
  8009a4:	83 fb 10             	cmp    $0x10,%ebx
  8009a7:	75 28                	jne    8009d1 <strtol+0x69>
  8009a9:	8a 02                	mov    (%edx),%al
  8009ab:	3c 30                	cmp    $0x30,%al
  8009ad:	75 10                	jne    8009bf <strtol+0x57>
  8009af:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b3:	75 0a                	jne    8009bf <strtol+0x57>
		s += 2, base = 16;
  8009b5:	83 c2 02             	add    $0x2,%edx
  8009b8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bd:	eb 12                	jmp    8009d1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	75 0e                	jne    8009d1 <strtol+0x69>
  8009c3:	3c 30                	cmp    $0x30,%al
  8009c5:	75 05                	jne    8009cc <strtol+0x64>
		s++, base = 8;
  8009c7:	42                   	inc    %edx
  8009c8:	b3 08                	mov    $0x8,%bl
  8009ca:	eb 05                	jmp    8009d1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009cc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d8:	8a 0a                	mov    (%edx),%cl
  8009da:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009dd:	80 fb 09             	cmp    $0x9,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x82>
			dig = *s - '0';
  8009e2:	0f be c9             	movsbl %cl,%ecx
  8009e5:	83 e9 30             	sub    $0x30,%ecx
  8009e8:	eb 1e                	jmp    800a08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009ea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0x92>
			dig = *s - 'a' + 10;
  8009f2:	0f be c9             	movsbl %cl,%ecx
  8009f5:	83 e9 57             	sub    $0x57,%ecx
  8009f8:	eb 0e                	jmp    800a08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009fa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009fd:	80 fb 19             	cmp    $0x19,%bl
  800a00:	77 12                	ja     800a14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a08:	39 f1                	cmp    %esi,%ecx
  800a0a:	7d 0c                	jge    800a18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a0c:	42                   	inc    %edx
  800a0d:	0f af c6             	imul   %esi,%eax
  800a10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a12:	eb c4                	jmp    8009d8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a14:	89 c1                	mov    %eax,%ecx
  800a16:	eb 02                	jmp    800a1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1e:	74 05                	je     800a25 <strtol+0xbd>
		*endptr = (char *) s;
  800a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a25:	85 ff                	test   %edi,%edi
  800a27:	74 04                	je     800a2d <strtol+0xc5>
  800a29:	89 c8                	mov    %ecx,%eax
  800a2b:	f7 d8                	neg    %eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    
	...

00800a34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	89 c6                	mov    %eax,%esi
  800a4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a62:	89 d1                	mov    %edx,%ecx
  800a64:	89 d3                	mov    %edx,%ebx
  800a66:	89 d7                	mov    %edx,%edi
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 cb                	mov    %ecx,%ebx
  800a89:	89 cf                	mov    %ecx,%edi
  800a8b:	89 ce                	mov    %ecx,%esi
  800a8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	7e 28                	jle    800abb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a9e:	00 
  800a9f:	c7 44 24 08 a8 0f 80 	movl   $0x800fa8,0x8(%esp)
  800aa6:	00 
  800aa7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aae:	00 
  800aaf:	c7 04 24 c5 0f 80 00 	movl   $0x800fc5,(%esp)
  800ab6:	e8 29 00 00 00       	call   800ae4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abb:	83 c4 2c             	add    $0x2c,%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad3:	89 d1                	mov    %edx,%ecx
  800ad5:	89 d3                	mov    %edx,%ebx
  800ad7:	89 d7                	mov    %edx,%edi
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    
	...

00800ae4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800aec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aef:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800af5:	e8 c9 ff ff ff       	call   800ac3 <sys_getenvid>
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	c7 04 24 d4 0f 80 00 	movl   $0x800fd4,(%esp)
  800b17:	e8 48 f6 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b20:	8b 45 10             	mov    0x10(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 d8 f5 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800b2b:	c7 04 24 98 0d 80 00 	movl   $0x800d98,(%esp)
  800b32:	e8 2d f6 ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b37:	cc                   	int3   
  800b38:	eb fd                	jmp    800b37 <_panic+0x53>
	...

00800b3c <__udivdi3>:
  800b3c:	55                   	push   %ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	83 ec 10             	sub    $0x10,%esp
  800b42:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b46:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b4e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b52:	89 cd                	mov    %ecx,%ebp
  800b54:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	75 2c                	jne    800b88 <__udivdi3+0x4c>
  800b5c:	39 f9                	cmp    %edi,%ecx
  800b5e:	77 68                	ja     800bc8 <__udivdi3+0x8c>
  800b60:	85 c9                	test   %ecx,%ecx
  800b62:	75 0b                	jne    800b6f <__udivdi3+0x33>
  800b64:	b8 01 00 00 00       	mov    $0x1,%eax
  800b69:	31 d2                	xor    %edx,%edx
  800b6b:	f7 f1                	div    %ecx
  800b6d:	89 c1                	mov    %eax,%ecx
  800b6f:	31 d2                	xor    %edx,%edx
  800b71:	89 f8                	mov    %edi,%eax
  800b73:	f7 f1                	div    %ecx
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	89 f0                	mov    %esi,%eax
  800b79:	f7 f1                	div    %ecx
  800b7b:	89 c6                	mov    %eax,%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	89 fa                	mov    %edi,%edx
  800b81:	83 c4 10             	add    $0x10,%esp
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    
  800b88:	39 f8                	cmp    %edi,%eax
  800b8a:	77 2c                	ja     800bb8 <__udivdi3+0x7c>
  800b8c:	0f bd f0             	bsr    %eax,%esi
  800b8f:	83 f6 1f             	xor    $0x1f,%esi
  800b92:	75 4c                	jne    800be0 <__udivdi3+0xa4>
  800b94:	39 f8                	cmp    %edi,%eax
  800b96:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9b:	72 0a                	jb     800ba7 <__udivdi3+0x6b>
  800b9d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ba1:	0f 87 ad 00 00 00    	ja     800c54 <__udivdi3+0x118>
  800ba7:	be 01 00 00 00       	mov    $0x1,%esi
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	89 fa                	mov    %edi,%edx
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
  800bb7:	90                   	nop
  800bb8:	31 ff                	xor    %edi,%edi
  800bba:	31 f6                	xor    %esi,%esi
  800bbc:	89 f0                	mov    %esi,%eax
  800bbe:	89 fa                	mov    %edi,%edx
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    
  800bc7:	90                   	nop
  800bc8:	89 fa                	mov    %edi,%edx
  800bca:	89 f0                	mov    %esi,%eax
  800bcc:	f7 f1                	div    %ecx
  800bce:	89 c6                	mov    %eax,%esi
  800bd0:	31 ff                	xor    %edi,%edi
  800bd2:	89 f0                	mov    %esi,%eax
  800bd4:	89 fa                	mov    %edi,%edx
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	89 f1                	mov    %esi,%ecx
  800be2:	d3 e0                	shl    %cl,%eax
  800be4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bed:	29 f0                	sub    %esi,%eax
  800bef:	89 ea                	mov    %ebp,%edx
  800bf1:	88 c1                	mov    %al,%cl
  800bf3:	d3 ea                	shr    %cl,%edx
  800bf5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bf9:	09 ca                	or     %ecx,%edx
  800bfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bff:	89 f1                	mov    %esi,%ecx
  800c01:	d3 e5                	shl    %cl,%ebp
  800c03:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800c07:	89 fd                	mov    %edi,%ebp
  800c09:	88 c1                	mov    %al,%cl
  800c0b:	d3 ed                	shr    %cl,%ebp
  800c0d:	89 fa                	mov    %edi,%edx
  800c0f:	89 f1                	mov    %esi,%ecx
  800c11:	d3 e2                	shl    %cl,%edx
  800c13:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c17:	88 c1                	mov    %al,%cl
  800c19:	d3 ef                	shr    %cl,%edi
  800c1b:	09 d7                	or     %edx,%edi
  800c1d:	89 f8                	mov    %edi,%eax
  800c1f:	89 ea                	mov    %ebp,%edx
  800c21:	f7 74 24 08          	divl   0x8(%esp)
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	f7 64 24 0c          	mull   0xc(%esp)
  800c2d:	39 d1                	cmp    %edx,%ecx
  800c2f:	72 17                	jb     800c48 <__udivdi3+0x10c>
  800c31:	74 09                	je     800c3c <__udivdi3+0x100>
  800c33:	89 fe                	mov    %edi,%esi
  800c35:	31 ff                	xor    %edi,%edi
  800c37:	e9 41 ff ff ff       	jmp    800b7d <__udivdi3+0x41>
  800c3c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c40:	89 f1                	mov    %esi,%ecx
  800c42:	d3 e2                	shl    %cl,%edx
  800c44:	39 c2                	cmp    %eax,%edx
  800c46:	73 eb                	jae    800c33 <__udivdi3+0xf7>
  800c48:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c4b:	31 ff                	xor    %edi,%edi
  800c4d:	e9 2b ff ff ff       	jmp    800b7d <__udivdi3+0x41>
  800c52:	66 90                	xchg   %ax,%ax
  800c54:	31 f6                	xor    %esi,%esi
  800c56:	e9 22 ff ff ff       	jmp    800b7d <__udivdi3+0x41>
	...

00800c5c <__umoddi3>:
  800c5c:	55                   	push   %ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	83 ec 20             	sub    $0x20,%esp
  800c62:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c66:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c6a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c6e:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c72:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c76:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c7a:	89 c7                	mov    %eax,%edi
  800c7c:	89 f2                	mov    %esi,%edx
  800c7e:	85 ed                	test   %ebp,%ebp
  800c80:	75 16                	jne    800c98 <__umoddi3+0x3c>
  800c82:	39 f1                	cmp    %esi,%ecx
  800c84:	0f 86 a6 00 00 00    	jbe    800d30 <__umoddi3+0xd4>
  800c8a:	f7 f1                	div    %ecx
  800c8c:	89 d0                	mov    %edx,%eax
  800c8e:	31 d2                	xor    %edx,%edx
  800c90:	83 c4 20             	add    $0x20,%esp
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    
  800c97:	90                   	nop
  800c98:	39 f5                	cmp    %esi,%ebp
  800c9a:	0f 87 ac 00 00 00    	ja     800d4c <__umoddi3+0xf0>
  800ca0:	0f bd c5             	bsr    %ebp,%eax
  800ca3:	83 f0 1f             	xor    $0x1f,%eax
  800ca6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caa:	0f 84 a8 00 00 00    	je     800d58 <__umoddi3+0xfc>
  800cb0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cb4:	d3 e5                	shl    %cl,%ebp
  800cb6:	bf 20 00 00 00       	mov    $0x20,%edi
  800cbb:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800cbf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cc3:	89 f9                	mov    %edi,%ecx
  800cc5:	d3 e8                	shr    %cl,%eax
  800cc7:	09 e8                	or     %ebp,%eax
  800cc9:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ccd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cd1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cd5:	d3 e0                	shl    %cl,%eax
  800cd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	d3 e2                	shl    %cl,%edx
  800cdf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ce3:	d3 e0                	shl    %cl,%eax
  800ce5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800ce9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ced:	89 f9                	mov    %edi,%ecx
  800cef:	d3 e8                	shr    %cl,%eax
  800cf1:	09 d0                	or     %edx,%eax
  800cf3:	d3 ee                	shr    %cl,%esi
  800cf5:	89 f2                	mov    %esi,%edx
  800cf7:	f7 74 24 18          	divl   0x18(%esp)
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	f7 64 24 0c          	mull   0xc(%esp)
  800d01:	89 c5                	mov    %eax,%ebp
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	39 d6                	cmp    %edx,%esi
  800d07:	72 67                	jb     800d70 <__umoddi3+0x114>
  800d09:	74 75                	je     800d80 <__umoddi3+0x124>
  800d0b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d0f:	29 e8                	sub    %ebp,%eax
  800d11:	19 ce                	sbb    %ecx,%esi
  800d13:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	d3 e2                	shl    %cl,%edx
  800d1f:	09 d0                	or     %edx,%eax
  800d21:	89 f2                	mov    %esi,%edx
  800d23:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d27:	d3 ea                	shr    %cl,%edx
  800d29:	83 c4 20             	add    $0x20,%esp
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
  800d30:	85 c9                	test   %ecx,%ecx
  800d32:	75 0b                	jne    800d3f <__umoddi3+0xe3>
  800d34:	b8 01 00 00 00       	mov    $0x1,%eax
  800d39:	31 d2                	xor    %edx,%edx
  800d3b:	f7 f1                	div    %ecx
  800d3d:	89 c1                	mov    %eax,%ecx
  800d3f:	89 f0                	mov    %esi,%eax
  800d41:	31 d2                	xor    %edx,%edx
  800d43:	f7 f1                	div    %ecx
  800d45:	89 f8                	mov    %edi,%eax
  800d47:	e9 3e ff ff ff       	jmp    800c8a <__umoddi3+0x2e>
  800d4c:	89 f2                	mov    %esi,%edx
  800d4e:	83 c4 20             	add    $0x20,%esp
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	39 f5                	cmp    %esi,%ebp
  800d5a:	72 04                	jb     800d60 <__umoddi3+0x104>
  800d5c:	39 f9                	cmp    %edi,%ecx
  800d5e:	77 06                	ja     800d66 <__umoddi3+0x10a>
  800d60:	89 f2                	mov    %esi,%edx
  800d62:	29 cf                	sub    %ecx,%edi
  800d64:	19 ea                	sbb    %ebp,%edx
  800d66:	89 f8                	mov    %edi,%eax
  800d68:	83 c4 20             	add    $0x20,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
  800d70:	89 d1                	mov    %edx,%ecx
  800d72:	89 c5                	mov    %eax,%ebp
  800d74:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d78:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d7c:	eb 8d                	jmp    800d0b <__umoddi3+0xaf>
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d84:	72 ea                	jb     800d70 <__umoddi3+0x114>
  800d86:	89 f1                	mov    %esi,%ecx
  800d88:	eb 81                	jmp    800d0b <__umoddi3+0xaf>
