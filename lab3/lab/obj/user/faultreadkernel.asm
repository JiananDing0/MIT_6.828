
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 68 0d 80 00 	movl   $0x800d68,(%esp)
  80004a:	e8 f1 00 00 00       	call   800140 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 af 09 00 00       	call   800a4d <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 14             	sub    $0x14,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000b3:	40                   	inc    %eax
  8000b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bb:	75 19                	jne    8000d6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000bd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000c4:	00 
  8000c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c8:	89 04 24             	mov    %eax,(%esp)
  8000cb:	e8 40 09 00 00       	call   800a10 <sys_cputs>
		b->idx = 0;
  8000d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000d6:	ff 43 04             	incl   0x4(%ebx)
}
  8000d9:	83 c4 14             	add    $0x14,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000ef:	00 00 00 
	b.cnt = 0;
  8000f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800103:	8b 45 08             	mov    0x8(%ebp),%eax
  800106:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800110:	89 44 24 04          	mov    %eax,0x4(%esp)
  800114:	c7 04 24 a0 00 80 00 	movl   $0x8000a0,(%esp)
  80011b:	e8 82 01 00 00       	call   8002a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800120:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800130:	89 04 24             	mov    %eax,(%esp)
  800133:	e8 d8 08 00 00       	call   800a10 <sys_cputs>

	return b.cnt;
}
  800138:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800146:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014d:	8b 45 08             	mov    0x8(%ebp),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 87 ff ff ff       	call   8000df <vcprintf>
	va_end(ap);

	return cnt;
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    
	...

0080015c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 3c             	sub    $0x3c,%esp
  800165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800168:	89 d7                	mov    %edx,%edi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800176:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800179:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017c:	85 c0                	test   %eax,%eax
  80017e:	75 08                	jne    800188 <printnum+0x2c>
  800180:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800183:	39 45 10             	cmp    %eax,0x10(%ebp)
  800186:	77 57                	ja     8001df <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800188:	89 74 24 10          	mov    %esi,0x10(%esp)
  80018c:	4b                   	dec    %ebx
  80018d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800191:	8b 45 10             	mov    0x10(%ebp),%eax
  800194:	89 44 24 08          	mov    %eax,0x8(%esp)
  800198:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80019c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a7:	00 
  8001a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	e8 5e 09 00 00       	call   800b18 <__udivdi3>
  8001ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001c9:	89 fa                	mov    %edi,%edx
  8001cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ce:	e8 89 ff ff ff       	call   80015c <printnum>
  8001d3:	eb 0f                	jmp    8001e4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001d9:	89 34 24             	mov    %esi,(%esp)
  8001dc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	4b                   	dec    %ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f f1                	jg     8001d5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fa:	00 
  8001fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800204:	89 44 24 04          	mov    %eax,0x4(%esp)
  800208:	e8 2b 0a 00 00       	call   800c38 <__umoddi3>
  80020d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800211:	0f be 80 99 0d 80 00 	movsbl 0x800d99(%eax),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80021e:	83 c4 3c             	add    $0x3c,%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800229:	83 fa 01             	cmp    $0x1,%edx
  80022c:	7e 0e                	jle    80023c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 08             	lea    0x8(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	8b 52 04             	mov    0x4(%edx),%edx
  80023a:	eb 22                	jmp    80025e <getuint+0x38>
	else if (lflag)
  80023c:	85 d2                	test   %edx,%edx
  80023e:	74 10                	je     800250 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
  80024e:	eb 0e                	jmp    80025e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800266:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	3b 50 04             	cmp    0x4(%eax),%edx
  80026e:	73 08                	jae    800278 <sprintputch+0x18>
		*b->buf++ = ch;
  800270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800273:	88 0a                	mov    %cl,(%edx)
  800275:	42                   	inc    %edx
  800276:	89 10                	mov    %edx,(%eax)
}
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800280:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800283:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800287:	8b 45 10             	mov    0x10(%ebp),%eax
  80028a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800291:	89 44 24 04          	mov    %eax,0x4(%esp)
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 02 00 00 00       	call   8002a2 <vprintfmt>
	va_end(ap);
}
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 4c             	sub    $0x4c,%esp
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8002b1:	eb 12                	jmp    8002c5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	0f 84 6b 03 00 00    	je     800626 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c5:	0f b6 06             	movzbl (%esi),%eax
  8002c8:	46                   	inc    %esi
  8002c9:	83 f8 25             	cmp    $0x25,%eax
  8002cc:	75 e5                	jne    8002b3 <vprintfmt+0x11>
  8002ce:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002d9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ea:	eb 26                	jmp    800312 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ec:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ef:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8002f3:	eb 1d                	jmp    800312 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8002fc:	eb 14                	jmp    800312 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800301:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800308:	eb 08                	jmp    800312 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80030a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80030d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	0f b6 06             	movzbl (%esi),%eax
  800315:	8d 56 01             	lea    0x1(%esi),%edx
  800318:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80031b:	8a 16                	mov    (%esi),%dl
  80031d:	83 ea 23             	sub    $0x23,%edx
  800320:	80 fa 55             	cmp    $0x55,%dl
  800323:	0f 87 e1 02 00 00    	ja     80060a <vprintfmt+0x368>
  800329:	0f b6 d2             	movzbl %dl,%edx
  80032c:	ff 24 95 28 0e 80 00 	jmp    *0x800e28(,%edx,4)
  800333:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800336:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80033e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800342:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800345:	8d 50 d0             	lea    -0x30(%eax),%edx
  800348:	83 fa 09             	cmp    $0x9,%edx
  80034b:	77 2a                	ja     800377 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034e:	eb eb                	jmp    80033b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 50 04             	lea    0x4(%eax),%edx
  800356:	89 55 14             	mov    %edx,0x14(%ebp)
  800359:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035e:	eb 17                	jmp    800377 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800360:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800364:	78 98                	js     8002fe <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800369:	eb a7                	jmp    800312 <vprintfmt+0x70>
  80036b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800375:	eb 9b                	jmp    800312 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800377:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80037b:	79 95                	jns    800312 <vprintfmt+0x70>
  80037d:	eb 8b                	jmp    80030a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800383:	eb 8d                	jmp    800312 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 50 04             	lea    0x4(%eax),%edx
  80038b:	89 55 14             	mov    %edx,0x14(%ebp)
  80038e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800392:	8b 00                	mov    (%eax),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039d:	e9 23 ff ff ff       	jmp    8002c5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 50 04             	lea    0x4(%eax),%edx
  8003a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	79 02                	jns    8003b3 <vprintfmt+0x111>
  8003b1:	f7 d8                	neg    %eax
  8003b3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b5:	83 f8 06             	cmp    $0x6,%eax
  8003b8:	7f 0b                	jg     8003c5 <vprintfmt+0x123>
  8003ba:	8b 04 85 80 0f 80 00 	mov    0x800f80(,%eax,4),%eax
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	75 23                	jne    8003e8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c9:	c7 44 24 08 b1 0d 80 	movl   $0x800db1,0x8(%esp)
  8003d0:	00 
  8003d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	e8 9a fe ff ff       	call   80027a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e3:	e9 dd fe ff ff       	jmp    8002c5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8003e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ec:	c7 44 24 08 ba 0d 80 	movl   $0x800dba,0x8(%esp)
  8003f3:	00 
  8003f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	89 14 24             	mov    %edx,(%esp)
  8003fe:	e8 77 fe ff ff       	call   80027a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800406:	e9 ba fe ff ff       	jmp    8002c5 <vprintfmt+0x23>
  80040b:	89 f9                	mov    %edi,%ecx
  80040d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800410:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 50 04             	lea    0x4(%eax),%edx
  800419:	89 55 14             	mov    %edx,0x14(%ebp)
  80041c:	8b 30                	mov    (%eax),%esi
  80041e:	85 f6                	test   %esi,%esi
  800420:	75 05                	jne    800427 <vprintfmt+0x185>
				p = "(null)";
  800422:	be aa 0d 80 00       	mov    $0x800daa,%esi
			if (width > 0 && padc != '-')
  800427:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80042b:	0f 8e 84 00 00 00    	jle    8004b5 <vprintfmt+0x213>
  800431:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800435:	74 7e                	je     8004b5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800437:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80043b:	89 34 24             	mov    %esi,(%esp)
  80043e:	e8 8b 02 00 00       	call   8006ce <strnlen>
  800443:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800446:	29 c2                	sub    %eax,%edx
  800448:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80044b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80044f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800452:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800455:	89 de                	mov    %ebx,%esi
  800457:	89 d3                	mov    %edx,%ebx
  800459:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	eb 0b                	jmp    800468 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80045d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800461:	89 3c 24             	mov    %edi,(%esp)
  800464:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	4b                   	dec    %ebx
  800468:	85 db                	test   %ebx,%ebx
  80046a:	7f f1                	jg     80045d <vprintfmt+0x1bb>
  80046c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80046f:	89 f3                	mov    %esi,%ebx
  800471:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800477:	85 c0                	test   %eax,%eax
  800479:	79 05                	jns    800480 <vprintfmt+0x1de>
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800483:	29 c2                	sub    %eax,%edx
  800485:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800488:	eb 2b                	jmp    8004b5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80048e:	74 18                	je     8004a8 <vprintfmt+0x206>
  800490:	8d 50 e0             	lea    -0x20(%eax),%edx
  800493:	83 fa 5e             	cmp    $0x5e,%edx
  800496:	76 10                	jbe    8004a8 <vprintfmt+0x206>
					putch('?', putdat);
  800498:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004a3:	ff 55 08             	call   *0x8(%ebp)
  8004a6:	eb 0a                	jmp    8004b2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004b5:	0f be 06             	movsbl (%esi),%eax
  8004b8:	46                   	inc    %esi
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	74 21                	je     8004de <vprintfmt+0x23c>
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	78 c9                	js     80048a <vprintfmt+0x1e8>
  8004c1:	4f                   	dec    %edi
  8004c2:	79 c6                	jns    80048a <vprintfmt+0x1e8>
  8004c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004c7:	89 de                	mov    %ebx,%esi
  8004c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004cc:	eb 18                	jmp    8004e6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004db:	4b                   	dec    %ebx
  8004dc:	eb 08                	jmp    8004e6 <vprintfmt+0x244>
  8004de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e1:	89 de                	mov    %ebx,%esi
  8004e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004e6:	85 db                	test   %ebx,%ebx
  8004e8:	7f e4                	jg     8004ce <vprintfmt+0x22c>
  8004ea:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004ed:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f2:	e9 ce fd ff ff       	jmp    8002c5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f7:	83 f9 01             	cmp    $0x1,%ecx
  8004fa:	7e 10                	jle    80050c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 50 08             	lea    0x8(%eax),%edx
  800502:	89 55 14             	mov    %edx,0x14(%ebp)
  800505:	8b 30                	mov    (%eax),%esi
  800507:	8b 78 04             	mov    0x4(%eax),%edi
  80050a:	eb 26                	jmp    800532 <vprintfmt+0x290>
	else if (lflag)
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	74 12                	je     800522 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 30                	mov    (%eax),%esi
  80051b:	89 f7                	mov    %esi,%edi
  80051d:	c1 ff 1f             	sar    $0x1f,%edi
  800520:	eb 10                	jmp    800532 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 30                	mov    (%eax),%esi
  80052d:	89 f7                	mov    %esi,%edi
  80052f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800532:	85 ff                	test   %edi,%edi
  800534:	78 0a                	js     800540 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800536:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053b:	e9 8c 00 00 00       	jmp    8005cc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800544:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80054b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80054e:	f7 de                	neg    %esi
  800550:	83 d7 00             	adc    $0x0,%edi
  800553:	f7 df                	neg    %edi
			}
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055a:	eb 70                	jmp    8005cc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80055c:	89 ca                	mov    %ecx,%edx
  80055e:	8d 45 14             	lea    0x14(%ebp),%eax
  800561:	e8 c0 fc ff ff       	call   800226 <getuint>
  800566:	89 c6                	mov    %eax,%esi
  800568:	89 d7                	mov    %edx,%edi
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80056f:	eb 5b                	jmp    8005cc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800571:	89 ca                	mov    %ecx,%edx
  800573:	8d 45 14             	lea    0x14(%ebp),%eax
  800576:	e8 ab fc ff ff       	call   800226 <getuint>
  80057b:	89 c6                	mov    %eax,%esi
  80057d:	89 d7                	mov    %edx,%edi
			base = 8;
  80057f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800584:	eb 46                	jmp    8005cc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800586:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800591:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800598:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ab:	8b 30                	mov    (%eax),%esi
  8005ad:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005b2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005b7:	eb 13                	jmp    8005cc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005b9:	89 ca                	mov    %ecx,%edx
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 63 fc ff ff       	call   800226 <getuint>
  8005c3:	89 c6                	mov    %eax,%esi
  8005c5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005c7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005cc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005d0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005df:	89 34 24             	mov    %esi,(%esp)
  8005e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e6:	89 da                	mov    %ebx,%edx
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	e8 6c fb ff ff       	call   80015c <printnum>
			break;
  8005f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f3:	e9 cd fc ff ff       	jmp    8002c5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	89 04 24             	mov    %eax,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800605:	e9 bb fc ff ff       	jmp    8002c5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800615:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800618:	eb 01                	jmp    80061b <vprintfmt+0x379>
  80061a:	4e                   	dec    %esi
  80061b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80061f:	75 f9                	jne    80061a <vprintfmt+0x378>
  800621:	e9 9f fc ff ff       	jmp    8002c5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800626:	83 c4 4c             	add    $0x4c,%esp
  800629:	5b                   	pop    %ebx
  80062a:	5e                   	pop    %esi
  80062b:	5f                   	pop    %edi
  80062c:	5d                   	pop    %ebp
  80062d:	c3                   	ret    

0080062e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	83 ec 28             	sub    $0x28,%esp
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800641:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800644:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064b:	85 c0                	test   %eax,%eax
  80064d:	74 30                	je     80067f <vsnprintf+0x51>
  80064f:	85 d2                	test   %edx,%edx
  800651:	7e 33                	jle    800686 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065a:	8b 45 10             	mov    0x10(%ebp),%eax
  80065d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800661:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800664:	89 44 24 04          	mov    %eax,0x4(%esp)
  800668:	c7 04 24 60 02 80 00 	movl   $0x800260,(%esp)
  80066f:	e8 2e fc ff ff       	call   8002a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800674:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800677:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80067a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067d:	eb 0c                	jmp    80068b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800684:	eb 05                	jmp    80068b <vsnprintf+0x5d>
  800686:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800696:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069a:	8b 45 10             	mov    0x10(%ebp),%eax
  80069d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	e8 7b ff ff ff       	call   80062e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    
  8006b5:	00 00                	add    %al,(%eax)
	...

008006b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006be:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c3:	eb 01                	jmp    8006c6 <strlen+0xe>
		n++;
  8006c5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ca:	75 f9                	jne    8006c5 <strlen+0xd>
		n++;
	return n;
}
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	eb 01                	jmp    8006df <strnlen+0x11>
		n++;
  8006de:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006df:	39 d0                	cmp    %edx,%eax
  8006e1:	74 06                	je     8006e9 <strnlen+0x1b>
  8006e3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006e7:	75 f5                	jne    8006de <strnlen+0x10>
		n++;
	return n;
}
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	53                   	push   %ebx
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8006fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800700:	42                   	inc    %edx
  800701:	84 c9                	test   %cl,%cl
  800703:	75 f5                	jne    8006fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800705:	5b                   	pop    %ebx
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	53                   	push   %ebx
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800712:	89 1c 24             	mov    %ebx,(%esp)
  800715:	e8 9e ff ff ff       	call   8006b8 <strlen>
	strcpy(dst + len, src);
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800721:	01 d8                	add    %ebx,%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 c0 ff ff ff       	call   8006eb <strcpy>
	return dst;
}
  80072b:	89 d8                	mov    %ebx,%eax
  80072d:	83 c4 08             	add    $0x8,%esp
  800730:	5b                   	pop    %ebx
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	56                   	push   %esi
  800737:	53                   	push   %ebx
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	eb 0c                	jmp    800754 <strncpy+0x21>
		*dst++ = *src;
  800748:	8a 1a                	mov    (%edx),%bl
  80074a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074d:	80 3a 01             	cmpb   $0x1,(%edx)
  800750:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800753:	41                   	inc    %ecx
  800754:	39 f1                	cmp    %esi,%ecx
  800756:	75 f0                	jne    800748 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80076a:	85 d2                	test   %edx,%edx
  80076c:	75 0a                	jne    800778 <strlcpy+0x1c>
  80076e:	89 f0                	mov    %esi,%eax
  800770:	eb 1a                	jmp    80078c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800772:	88 18                	mov    %bl,(%eax)
  800774:	40                   	inc    %eax
  800775:	41                   	inc    %ecx
  800776:	eb 02                	jmp    80077a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800778:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80077a:	4a                   	dec    %edx
  80077b:	74 0a                	je     800787 <strlcpy+0x2b>
  80077d:	8a 19                	mov    (%ecx),%bl
  80077f:	84 db                	test   %bl,%bl
  800781:	75 ef                	jne    800772 <strlcpy+0x16>
  800783:	89 c2                	mov    %eax,%edx
  800785:	eb 02                	jmp    800789 <strlcpy+0x2d>
  800787:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800789:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80078c:	29 f0                	sub    %esi,%eax
}
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079b:	eb 02                	jmp    80079f <strcmp+0xd>
		p++, q++;
  80079d:	41                   	inc    %ecx
  80079e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80079f:	8a 01                	mov    (%ecx),%al
  8007a1:	84 c0                	test   %al,%al
  8007a3:	74 04                	je     8007a9 <strcmp+0x17>
  8007a5:	3a 02                	cmp    (%edx),%al
  8007a7:	74 f4                	je     80079d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a9:	0f b6 c0             	movzbl %al,%eax
  8007ac:	0f b6 12             	movzbl (%edx),%edx
  8007af:	29 d0                	sub    %edx,%eax
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007c0:	eb 03                	jmp    8007c5 <strncmp+0x12>
		n--, p++, q++;
  8007c2:	4a                   	dec    %edx
  8007c3:	40                   	inc    %eax
  8007c4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 14                	je     8007dd <strncmp+0x2a>
  8007c9:	8a 18                	mov    (%eax),%bl
  8007cb:	84 db                	test   %bl,%bl
  8007cd:	74 04                	je     8007d3 <strncmp+0x20>
  8007cf:	3a 19                	cmp    (%ecx),%bl
  8007d1:	74 ef                	je     8007c2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d3:	0f b6 00             	movzbl (%eax),%eax
  8007d6:	0f b6 11             	movzbl (%ecx),%edx
  8007d9:	29 d0                	sub    %edx,%eax
  8007db:	eb 05                	jmp    8007e2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007ee:	eb 05                	jmp    8007f5 <strchr+0x10>
		if (*s == c)
  8007f0:	38 ca                	cmp    %cl,%dl
  8007f2:	74 0c                	je     800800 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007f4:	40                   	inc    %eax
  8007f5:	8a 10                	mov    (%eax),%dl
  8007f7:	84 d2                	test   %dl,%dl
  8007f9:	75 f5                	jne    8007f0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80080b:	eb 05                	jmp    800812 <strfind+0x10>
		if (*s == c)
  80080d:	38 ca                	cmp    %cl,%dl
  80080f:	74 07                	je     800818 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800811:	40                   	inc    %eax
  800812:	8a 10                	mov    (%eax),%dl
  800814:	84 d2                	test   %dl,%dl
  800816:	75 f5                	jne    80080d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	57                   	push   %edi
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 7d 08             	mov    0x8(%ebp),%edi
  800823:	8b 45 0c             	mov    0xc(%ebp),%eax
  800826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	74 30                	je     80085d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800833:	75 25                	jne    80085a <memset+0x40>
  800835:	f6 c1 03             	test   $0x3,%cl
  800838:	75 20                	jne    80085a <memset+0x40>
		c &= 0xFF;
  80083a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083d:	89 d3                	mov    %edx,%ebx
  80083f:	c1 e3 08             	shl    $0x8,%ebx
  800842:	89 d6                	mov    %edx,%esi
  800844:	c1 e6 18             	shl    $0x18,%esi
  800847:	89 d0                	mov    %edx,%eax
  800849:	c1 e0 10             	shl    $0x10,%eax
  80084c:	09 f0                	or     %esi,%eax
  80084e:	09 d0                	or     %edx,%eax
  800850:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800852:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800855:	fc                   	cld    
  800856:	f3 ab                	rep stos %eax,%es:(%edi)
  800858:	eb 03                	jmp    80085d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085a:	fc                   	cld    
  80085b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085d:	89 f8                	mov    %edi,%eax
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5f                   	pop    %edi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800872:	39 c6                	cmp    %eax,%esi
  800874:	73 34                	jae    8008aa <memmove+0x46>
  800876:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800879:	39 d0                	cmp    %edx,%eax
  80087b:	73 2d                	jae    8008aa <memmove+0x46>
		s += n;
		d += n;
  80087d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800880:	f6 c2 03             	test   $0x3,%dl
  800883:	75 1b                	jne    8008a0 <memmove+0x3c>
  800885:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088b:	75 13                	jne    8008a0 <memmove+0x3c>
  80088d:	f6 c1 03             	test   $0x3,%cl
  800890:	75 0e                	jne    8008a0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800892:	83 ef 04             	sub    $0x4,%edi
  800895:	8d 72 fc             	lea    -0x4(%edx),%esi
  800898:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80089b:	fd                   	std    
  80089c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089e:	eb 07                	jmp    8008a7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a0:	4f                   	dec    %edi
  8008a1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a4:	fd                   	std    
  8008a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a7:	fc                   	cld    
  8008a8:	eb 20                	jmp    8008ca <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x61>
  8008b2:	a8 03                	test   $0x3,%al
  8008b4:	75 0f                	jne    8008c5 <memmove+0x61>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 0a                	jne    8008c5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008bb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008be:	89 c7                	mov    %eax,%edi
  8008c0:	fc                   	cld    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 05                	jmp    8008ca <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c5:	89 c7                	mov    %eax,%edi
  8008c7:	fc                   	cld    
  8008c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	89 04 24             	mov    %eax,(%esp)
  8008e8:	e8 77 ff ff ff       	call   800864 <memmove>
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	57                   	push   %edi
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
  8008f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800903:	eb 16                	jmp    80091b <memcmp+0x2c>
		if (*s1 != *s2)
  800905:	8a 04 17             	mov    (%edi,%edx,1),%al
  800908:	42                   	inc    %edx
  800909:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80090d:	38 c8                	cmp    %cl,%al
  80090f:	74 0a                	je     80091b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800911:	0f b6 c0             	movzbl %al,%eax
  800914:	0f b6 c9             	movzbl %cl,%ecx
  800917:	29 c8                	sub    %ecx,%eax
  800919:	eb 09                	jmp    800924 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091b:	39 da                	cmp    %ebx,%edx
  80091d:	75 e6                	jne    800905 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800932:	89 c2                	mov    %eax,%edx
  800934:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800937:	eb 05                	jmp    80093e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800939:	38 08                	cmp    %cl,(%eax)
  80093b:	74 05                	je     800942 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093d:	40                   	inc    %eax
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	72 f7                	jb     800939 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 55 08             	mov    0x8(%ebp),%edx
  80094d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800950:	eb 01                	jmp    800953 <strtol+0xf>
		s++;
  800952:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800953:	8a 02                	mov    (%edx),%al
  800955:	3c 20                	cmp    $0x20,%al
  800957:	74 f9                	je     800952 <strtol+0xe>
  800959:	3c 09                	cmp    $0x9,%al
  80095b:	74 f5                	je     800952 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80095d:	3c 2b                	cmp    $0x2b,%al
  80095f:	75 08                	jne    800969 <strtol+0x25>
		s++;
  800961:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800962:	bf 00 00 00 00       	mov    $0x0,%edi
  800967:	eb 13                	jmp    80097c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800969:	3c 2d                	cmp    $0x2d,%al
  80096b:	75 0a                	jne    800977 <strtol+0x33>
		s++, neg = 1;
  80096d:	8d 52 01             	lea    0x1(%edx),%edx
  800970:	bf 01 00 00 00       	mov    $0x1,%edi
  800975:	eb 05                	jmp    80097c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800977:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80097c:	85 db                	test   %ebx,%ebx
  80097e:	74 05                	je     800985 <strtol+0x41>
  800980:	83 fb 10             	cmp    $0x10,%ebx
  800983:	75 28                	jne    8009ad <strtol+0x69>
  800985:	8a 02                	mov    (%edx),%al
  800987:	3c 30                	cmp    $0x30,%al
  800989:	75 10                	jne    80099b <strtol+0x57>
  80098b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80098f:	75 0a                	jne    80099b <strtol+0x57>
		s += 2, base = 16;
  800991:	83 c2 02             	add    $0x2,%edx
  800994:	bb 10 00 00 00       	mov    $0x10,%ebx
  800999:	eb 12                	jmp    8009ad <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80099b:	85 db                	test   %ebx,%ebx
  80099d:	75 0e                	jne    8009ad <strtol+0x69>
  80099f:	3c 30                	cmp    $0x30,%al
  8009a1:	75 05                	jne    8009a8 <strtol+0x64>
		s++, base = 8;
  8009a3:	42                   	inc    %edx
  8009a4:	b3 08                	mov    $0x8,%bl
  8009a6:	eb 05                	jmp    8009ad <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009a8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b4:	8a 0a                	mov    (%edx),%cl
  8009b6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009b9:	80 fb 09             	cmp    $0x9,%bl
  8009bc:	77 08                	ja     8009c6 <strtol+0x82>
			dig = *s - '0';
  8009be:	0f be c9             	movsbl %cl,%ecx
  8009c1:	83 e9 30             	sub    $0x30,%ecx
  8009c4:	eb 1e                	jmp    8009e4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009c6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009c9:	80 fb 19             	cmp    $0x19,%bl
  8009cc:	77 08                	ja     8009d6 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009ce:	0f be c9             	movsbl %cl,%ecx
  8009d1:	83 e9 57             	sub    $0x57,%ecx
  8009d4:	eb 0e                	jmp    8009e4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009d6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009d9:	80 fb 19             	cmp    $0x19,%bl
  8009dc:	77 12                	ja     8009f0 <strtol+0xac>
			dig = *s - 'A' + 10;
  8009de:	0f be c9             	movsbl %cl,%ecx
  8009e1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8009e4:	39 f1                	cmp    %esi,%ecx
  8009e6:	7d 0c                	jge    8009f4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009e8:	42                   	inc    %edx
  8009e9:	0f af c6             	imul   %esi,%eax
  8009ec:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8009ee:	eb c4                	jmp    8009b4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8009f0:	89 c1                	mov    %eax,%ecx
  8009f2:	eb 02                	jmp    8009f6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009f4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8009f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fa:	74 05                	je     800a01 <strtol+0xbd>
		*endptr = (char *) s;
  8009fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ff:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a01:	85 ff                	test   %edi,%edi
  800a03:	74 04                	je     800a09 <strtol+0xc5>
  800a05:	89 c8                	mov    %ecx,%eax
  800a07:	f7 d8                	neg    %eax
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    
	...

00800a10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a21:	89 c3                	mov    %eax,%ebx
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	89 c6                	mov    %eax,%esi
  800a27:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a34:	ba 00 00 00 00       	mov    $0x0,%edx
  800a39:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3e:	89 d1                	mov    %edx,%ecx
  800a40:	89 d3                	mov    %edx,%ebx
  800a42:	89 d7                	mov    %edx,%edi
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	89 cb                	mov    %ecx,%ebx
  800a65:	89 cf                	mov    %ecx,%edi
  800a67:	89 ce                	mov    %ecx,%esi
  800a69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	7e 28                	jle    800a97 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a73:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a7a:	00 
  800a7b:	c7 44 24 08 9c 0f 80 	movl   $0x800f9c,0x8(%esp)
  800a82:	00 
  800a83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800a8a:	00 
  800a8b:	c7 04 24 b9 0f 80 00 	movl   $0x800fb9,(%esp)
  800a92:	e8 29 00 00 00       	call   800ac0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a97:	83 c4 2c             	add    $0x2c,%esp
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	b8 02 00 00 00       	mov    $0x2,%eax
  800aaf:	89 d1                	mov    %edx,%ecx
  800ab1:	89 d3                	mov    %edx,%ebx
  800ab3:	89 d7                	mov    %edx,%edi
  800ab5:	89 d6                	mov    %edx,%esi
  800ab7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    
	...

00800ac0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ac8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800acb:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800ad1:	e8 c9 ff ff ff       	call   800a9f <sys_getenvid>
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	89 54 24 10          	mov    %edx,0x10(%esp)
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ae4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aec:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  800af3:	e8 48 f6 ff ff       	call   800140 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800af8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  800aff:	89 04 24             	mov    %eax,(%esp)
  800b02:	e8 d8 f5 ff ff       	call   8000df <vcprintf>
	cprintf("\n");
  800b07:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800b0e:	e8 2d f6 ff ff       	call   800140 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b13:	cc                   	int3   
  800b14:	eb fd                	jmp    800b13 <_panic+0x53>
	...

00800b18 <__udivdi3>:
  800b18:	55                   	push   %ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	83 ec 10             	sub    $0x10,%esp
  800b1e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b2e:	89 cd                	mov    %ecx,%ebp
  800b30:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b34:	85 c0                	test   %eax,%eax
  800b36:	75 2c                	jne    800b64 <__udivdi3+0x4c>
  800b38:	39 f9                	cmp    %edi,%ecx
  800b3a:	77 68                	ja     800ba4 <__udivdi3+0x8c>
  800b3c:	85 c9                	test   %ecx,%ecx
  800b3e:	75 0b                	jne    800b4b <__udivdi3+0x33>
  800b40:	b8 01 00 00 00       	mov    $0x1,%eax
  800b45:	31 d2                	xor    %edx,%edx
  800b47:	f7 f1                	div    %ecx
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	31 d2                	xor    %edx,%edx
  800b4d:	89 f8                	mov    %edi,%eax
  800b4f:	f7 f1                	div    %ecx
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	89 f0                	mov    %esi,%eax
  800b55:	f7 f1                	div    %ecx
  800b57:	89 c6                	mov    %eax,%esi
  800b59:	89 f0                	mov    %esi,%eax
  800b5b:	89 fa                	mov    %edi,%edx
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    
  800b64:	39 f8                	cmp    %edi,%eax
  800b66:	77 2c                	ja     800b94 <__udivdi3+0x7c>
  800b68:	0f bd f0             	bsr    %eax,%esi
  800b6b:	83 f6 1f             	xor    $0x1f,%esi
  800b6e:	75 4c                	jne    800bbc <__udivdi3+0xa4>
  800b70:	39 f8                	cmp    %edi,%eax
  800b72:	bf 00 00 00 00       	mov    $0x0,%edi
  800b77:	72 0a                	jb     800b83 <__udivdi3+0x6b>
  800b79:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b7d:	0f 87 ad 00 00 00    	ja     800c30 <__udivdi3+0x118>
  800b83:	be 01 00 00 00       	mov    $0x1,%esi
  800b88:	89 f0                	mov    %esi,%eax
  800b8a:	89 fa                	mov    %edi,%edx
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    
  800b93:	90                   	nop
  800b94:	31 ff                	xor    %edi,%edi
  800b96:	31 f6                	xor    %esi,%esi
  800b98:	89 f0                	mov    %esi,%eax
  800b9a:	89 fa                	mov    %edi,%edx
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
  800ba3:	90                   	nop
  800ba4:	89 fa                	mov    %edi,%edx
  800ba6:	89 f0                	mov    %esi,%eax
  800ba8:	f7 f1                	div    %ecx
  800baa:	89 c6                	mov    %eax,%esi
  800bac:	31 ff                	xor    %edi,%edi
  800bae:	89 f0                	mov    %esi,%eax
  800bb0:	89 fa                	mov    %edi,%edx
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
  800bb9:	8d 76 00             	lea    0x0(%esi),%esi
  800bbc:	89 f1                	mov    %esi,%ecx
  800bbe:	d3 e0                	shl    %cl,%eax
  800bc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc4:	b8 20 00 00 00       	mov    $0x20,%eax
  800bc9:	29 f0                	sub    %esi,%eax
  800bcb:	89 ea                	mov    %ebp,%edx
  800bcd:	88 c1                	mov    %al,%cl
  800bcf:	d3 ea                	shr    %cl,%edx
  800bd1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bd5:	09 ca                	or     %ecx,%edx
  800bd7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bdb:	89 f1                	mov    %esi,%ecx
  800bdd:	d3 e5                	shl    %cl,%ebp
  800bdf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800be3:	89 fd                	mov    %edi,%ebp
  800be5:	88 c1                	mov    %al,%cl
  800be7:	d3 ed                	shr    %cl,%ebp
  800be9:	89 fa                	mov    %edi,%edx
  800beb:	89 f1                	mov    %esi,%ecx
  800bed:	d3 e2                	shl    %cl,%edx
  800bef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf3:	88 c1                	mov    %al,%cl
  800bf5:	d3 ef                	shr    %cl,%edi
  800bf7:	09 d7                	or     %edx,%edi
  800bf9:	89 f8                	mov    %edi,%eax
  800bfb:	89 ea                	mov    %ebp,%edx
  800bfd:	f7 74 24 08          	divl   0x8(%esp)
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	f7 64 24 0c          	mull   0xc(%esp)
  800c09:	39 d1                	cmp    %edx,%ecx
  800c0b:	72 17                	jb     800c24 <__udivdi3+0x10c>
  800c0d:	74 09                	je     800c18 <__udivdi3+0x100>
  800c0f:	89 fe                	mov    %edi,%esi
  800c11:	31 ff                	xor    %edi,%edi
  800c13:	e9 41 ff ff ff       	jmp    800b59 <__udivdi3+0x41>
  800c18:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c1c:	89 f1                	mov    %esi,%ecx
  800c1e:	d3 e2                	shl    %cl,%edx
  800c20:	39 c2                	cmp    %eax,%edx
  800c22:	73 eb                	jae    800c0f <__udivdi3+0xf7>
  800c24:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c27:	31 ff                	xor    %edi,%edi
  800c29:	e9 2b ff ff ff       	jmp    800b59 <__udivdi3+0x41>
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	31 f6                	xor    %esi,%esi
  800c32:	e9 22 ff ff ff       	jmp    800b59 <__udivdi3+0x41>
	...

00800c38 <__umoddi3>:
  800c38:	55                   	push   %ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	83 ec 20             	sub    $0x20,%esp
  800c3e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c42:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c46:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c4a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c4e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c52:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	89 f2                	mov    %esi,%edx
  800c5a:	85 ed                	test   %ebp,%ebp
  800c5c:	75 16                	jne    800c74 <__umoddi3+0x3c>
  800c5e:	39 f1                	cmp    %esi,%ecx
  800c60:	0f 86 a6 00 00 00    	jbe    800d0c <__umoddi3+0xd4>
  800c66:	f7 f1                	div    %ecx
  800c68:	89 d0                	mov    %edx,%eax
  800c6a:	31 d2                	xor    %edx,%edx
  800c6c:	83 c4 20             	add    $0x20,%esp
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
  800c73:	90                   	nop
  800c74:	39 f5                	cmp    %esi,%ebp
  800c76:	0f 87 ac 00 00 00    	ja     800d28 <__umoddi3+0xf0>
  800c7c:	0f bd c5             	bsr    %ebp,%eax
  800c7f:	83 f0 1f             	xor    $0x1f,%eax
  800c82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c86:	0f 84 a8 00 00 00    	je     800d34 <__umoddi3+0xfc>
  800c8c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c90:	d3 e5                	shl    %cl,%ebp
  800c92:	bf 20 00 00 00       	mov    $0x20,%edi
  800c97:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800c9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c9f:	89 f9                	mov    %edi,%ecx
  800ca1:	d3 e8                	shr    %cl,%eax
  800ca3:	09 e8                	or     %ebp,%eax
  800ca5:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ca9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cad:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cb1:	d3 e0                	shl    %cl,%eax
  800cb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb7:	89 f2                	mov    %esi,%edx
  800cb9:	d3 e2                	shl    %cl,%edx
  800cbb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cbf:	d3 e0                	shl    %cl,%eax
  800cc1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cc5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	d3 e8                	shr    %cl,%eax
  800ccd:	09 d0                	or     %edx,%eax
  800ccf:	d3 ee                	shr    %cl,%esi
  800cd1:	89 f2                	mov    %esi,%edx
  800cd3:	f7 74 24 18          	divl   0x18(%esp)
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	f7 64 24 0c          	mull   0xc(%esp)
  800cdd:	89 c5                	mov    %eax,%ebp
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	39 d6                	cmp    %edx,%esi
  800ce3:	72 67                	jb     800d4c <__umoddi3+0x114>
  800ce5:	74 75                	je     800d5c <__umoddi3+0x124>
  800ce7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ceb:	29 e8                	sub    %ebp,%eax
  800ced:	19 ce                	sbb    %ecx,%esi
  800cef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cf3:	d3 e8                	shr    %cl,%eax
  800cf5:	89 f2                	mov    %esi,%edx
  800cf7:	89 f9                	mov    %edi,%ecx
  800cf9:	d3 e2                	shl    %cl,%edx
  800cfb:	09 d0                	or     %edx,%eax
  800cfd:	89 f2                	mov    %esi,%edx
  800cff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d03:	d3 ea                	shr    %cl,%edx
  800d05:	83 c4 20             	add    $0x20,%esp
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
  800d0c:	85 c9                	test   %ecx,%ecx
  800d0e:	75 0b                	jne    800d1b <__umoddi3+0xe3>
  800d10:	b8 01 00 00 00       	mov    $0x1,%eax
  800d15:	31 d2                	xor    %edx,%edx
  800d17:	f7 f1                	div    %ecx
  800d19:	89 c1                	mov    %eax,%ecx
  800d1b:	89 f0                	mov    %esi,%eax
  800d1d:	31 d2                	xor    %edx,%edx
  800d1f:	f7 f1                	div    %ecx
  800d21:	89 f8                	mov    %edi,%eax
  800d23:	e9 3e ff ff ff       	jmp    800c66 <__umoddi3+0x2e>
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	83 c4 20             	add    $0x20,%esp
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    
  800d31:	8d 76 00             	lea    0x0(%esi),%esi
  800d34:	39 f5                	cmp    %esi,%ebp
  800d36:	72 04                	jb     800d3c <__umoddi3+0x104>
  800d38:	39 f9                	cmp    %edi,%ecx
  800d3a:	77 06                	ja     800d42 <__umoddi3+0x10a>
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	29 cf                	sub    %ecx,%edi
  800d40:	19 ea                	sbb    %ebp,%edx
  800d42:	89 f8                	mov    %edi,%eax
  800d44:	83 c4 20             	add    $0x20,%esp
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
  800d4b:	90                   	nop
  800d4c:	89 d1                	mov    %edx,%ecx
  800d4e:	89 c5                	mov    %eax,%ebp
  800d50:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d54:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d58:	eb 8d                	jmp    800ce7 <__umoddi3+0xaf>
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d60:	72 ea                	jb     800d4c <__umoddi3+0x114>
  800d62:	89 f1                	mov    %esi,%ecx
  800d64:	eb 81                	jmp    800ce7 <__umoddi3+0xaf>
