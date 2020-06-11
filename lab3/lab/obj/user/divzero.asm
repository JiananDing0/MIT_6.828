
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
  800055:	c7 04 24 78 0d 80 00 	movl   $0x800d78,(%esp)
  80005c:	e8 ef 00 00 00       	call   800150 <cprintf>
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
  800067:	83 ec 18             	sub    $0x18,%esp
  80006a:	8b 45 08             	mov    0x8(%ebp),%eax
  80006d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800070:	c7 05 08 10 80 00 00 	movl   $0x0,0x801008
  800077:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 c0                	test   %eax,%eax
  80007c:	7e 08                	jle    800086 <libmain+0x22>
		binaryname = argv[0];
  80007e:	8b 0a                	mov    (%edx),%ecx
  800080:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800086:	89 54 24 04          	mov    %edx,0x4(%esp)
  80008a:	89 04 24             	mov    %eax,(%esp)
  80008d:	e8 a2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800092:	e8 05 00 00 00       	call   80009c <exit>
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 af 09 00 00       	call   800a5d <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 14             	sub    $0x14,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c3:	40                   	inc    %eax
  8000c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 19                	jne    8000e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d4:	00 
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	89 04 24             	mov    %eax,(%esp)
  8000db:	e8 40 09 00 00       	call   800a20 <sys_cputs>
		b->idx = 0;
  8000e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e6:	ff 43 04             	incl   0x4(%ebx)
}
  8000e9:	83 c4 14             	add    $0x14,%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000ff:	00 00 00 
	b.cnt = 0;
  800102:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800109:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800113:	8b 45 08             	mov    0x8(%ebp),%eax
  800116:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800120:	89 44 24 04          	mov    %eax,0x4(%esp)
  800124:	c7 04 24 b0 00 80 00 	movl   $0x8000b0,(%esp)
  80012b:	e8 82 01 00 00       	call   8002b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800130:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800140:	89 04 24             	mov    %eax,(%esp)
  800143:	e8 d8 08 00 00       	call   800a20 <sys_cputs>

	return b.cnt;
}
  800148:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800156:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800159:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015d:	8b 45 08             	mov    0x8(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 87 ff ff ff       	call   8000ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    
	...

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 3c             	sub    $0x3c,%esp
  800175:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800178:	89 d7                	mov    %edx,%edi
  80017a:	8b 45 08             	mov    0x8(%ebp),%eax
  80017d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800180:	8b 45 0c             	mov    0xc(%ebp),%eax
  800183:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800186:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800189:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018c:	85 c0                	test   %eax,%eax
  80018e:	75 08                	jne    800198 <printnum+0x2c>
  800190:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800193:	39 45 10             	cmp    %eax,0x10(%ebp)
  800196:	77 57                	ja     8001ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800198:	89 74 24 10          	mov    %esi,0x10(%esp)
  80019c:	4b                   	dec    %ebx
  80019d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b7:	00 
  8001b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	e8 5e 09 00 00       	call   800b28 <__udivdi3>
  8001ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d9:	89 fa                	mov    %edi,%edx
  8001db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001de:	e8 89 ff ff ff       	call   80016c <printnum>
  8001e3:	eb 0f                	jmp    8001f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001e9:	89 34 24             	mov    %esi,(%esp)
  8001ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ef:	4b                   	dec    %ebx
  8001f0:	85 db                	test   %ebx,%ebx
  8001f2:	7f f1                	jg     8001e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020a:	00 
  80020b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	e8 2b 0a 00 00       	call   800c48 <__umoddi3>
  80021d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800221:	0f be 80 90 0d 80 00 	movsbl 0x800d90(%eax),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80022e:	83 c4 3c             	add    $0x3c,%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 08                	jae    800288 <sprintputch+0x18>
		*b->buf++ = ch;
  800280:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800283:	88 0a                	mov    %cl,(%edx)
  800285:	42                   	inc    %edx
  800286:	89 10                	mov    %edx,(%eax)
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800290:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	8b 45 10             	mov    0x10(%ebp),%eax
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	e8 02 00 00 00       	call   8002b2 <vprintfmt>
	va_end(ap);
}
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 4c             	sub    $0x4c,%esp
  8002bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002be:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c1:	eb 12                	jmp    8002d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	0f 84 6b 03 00 00    	je     800636 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d5:	0f b6 06             	movzbl (%esi),%eax
  8002d8:	46                   	inc    %esi
  8002d9:	83 f8 25             	cmp    $0x25,%eax
  8002dc:	75 e5                	jne    8002c3 <vprintfmt+0x11>
  8002de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fa:	eb 26                	jmp    800322 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800303:	eb 1d                	jmp    800322 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800308:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80030c:	eb 14                	jmp    800322 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800311:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800318:	eb 08                	jmp    800322 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80031a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80031d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	0f b6 06             	movzbl (%esi),%eax
  800325:	8d 56 01             	lea    0x1(%esi),%edx
  800328:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032b:	8a 16                	mov    (%esi),%dl
  80032d:	83 ea 23             	sub    $0x23,%edx
  800330:	80 fa 55             	cmp    $0x55,%dl
  800333:	0f 87 e1 02 00 00    	ja     80061a <vprintfmt+0x368>
  800339:	0f b6 d2             	movzbl %dl,%edx
  80033c:	ff 24 95 20 0e 80 00 	jmp    *0x800e20(,%edx,4)
  800343:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800346:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80034e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800352:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800355:	8d 50 d0             	lea    -0x30(%eax),%edx
  800358:	83 fa 09             	cmp    $0x9,%edx
  80035b:	77 2a                	ja     800387 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035e:	eb eb                	jmp    80034b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 50 04             	lea    0x4(%eax),%edx
  800366:	89 55 14             	mov    %edx,0x14(%ebp)
  800369:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036e:	eb 17                	jmp    800387 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800370:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800374:	78 98                	js     80030e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800379:	eb a7                	jmp    800322 <vprintfmt+0x70>
  80037b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800385:	eb 9b                	jmp    800322 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800387:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038b:	79 95                	jns    800322 <vprintfmt+0x70>
  80038d:	eb 8b                	jmp    80031a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800393:	eb 8d                	jmp    800322 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 50 04             	lea    0x4(%eax),%edx
  80039b:	89 55 14             	mov    %edx,0x14(%ebp)
  80039e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a2:	8b 00                	mov    (%eax),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ad:	e9 23 ff ff ff       	jmp    8002d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 50 04             	lea    0x4(%eax),%edx
  8003b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bb:	8b 00                	mov    (%eax),%eax
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	79 02                	jns    8003c3 <vprintfmt+0x111>
  8003c1:	f7 d8                	neg    %eax
  8003c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c5:	83 f8 06             	cmp    $0x6,%eax
  8003c8:	7f 0b                	jg     8003d5 <vprintfmt+0x123>
  8003ca:	8b 04 85 78 0f 80 00 	mov    0x800f78(,%eax,4),%eax
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	75 23                	jne    8003f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d9:	c7 44 24 08 a8 0d 80 	movl   $0x800da8,0x8(%esp)
  8003e0:	00 
  8003e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	e8 9a fe ff ff       	call   80028a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f3:	e9 dd fe ff ff       	jmp    8002d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8003f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fc:	c7 44 24 08 b1 0d 80 	movl   $0x800db1,0x8(%esp)
  800403:	00 
  800404:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800408:	8b 55 08             	mov    0x8(%ebp),%edx
  80040b:	89 14 24             	mov    %edx,(%esp)
  80040e:	e8 77 fe ff ff       	call   80028a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800416:	e9 ba fe ff ff       	jmp    8002d5 <vprintfmt+0x23>
  80041b:	89 f9                	mov    %edi,%ecx
  80041d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800420:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 50 04             	lea    0x4(%eax),%edx
  800429:	89 55 14             	mov    %edx,0x14(%ebp)
  80042c:	8b 30                	mov    (%eax),%esi
  80042e:	85 f6                	test   %esi,%esi
  800430:	75 05                	jne    800437 <vprintfmt+0x185>
				p = "(null)";
  800432:	be a1 0d 80 00       	mov    $0x800da1,%esi
			if (width > 0 && padc != '-')
  800437:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80043b:	0f 8e 84 00 00 00    	jle    8004c5 <vprintfmt+0x213>
  800441:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800445:	74 7e                	je     8004c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80044b:	89 34 24             	mov    %esi,(%esp)
  80044e:	e8 8b 02 00 00       	call   8006de <strnlen>
  800453:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800456:	29 c2                	sub    %eax,%edx
  800458:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80045b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80045f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800462:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800465:	89 de                	mov    %ebx,%esi
  800467:	89 d3                	mov    %edx,%ebx
  800469:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	eb 0b                	jmp    800478 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80046d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800471:	89 3c 24             	mov    %edi,(%esp)
  800474:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	4b                   	dec    %ebx
  800478:	85 db                	test   %ebx,%ebx
  80047a:	7f f1                	jg     80046d <vprintfmt+0x1bb>
  80047c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80047f:	89 f3                	mov    %esi,%ebx
  800481:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800484:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800487:	85 c0                	test   %eax,%eax
  800489:	79 05                	jns    800490 <vprintfmt+0x1de>
  80048b:	b8 00 00 00 00       	mov    $0x0,%eax
  800490:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800493:	29 c2                	sub    %eax,%edx
  800495:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800498:	eb 2b                	jmp    8004c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80049e:	74 18                	je     8004b8 <vprintfmt+0x206>
  8004a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004a3:	83 fa 5e             	cmp    $0x5e,%edx
  8004a6:	76 10                	jbe    8004b8 <vprintfmt+0x206>
					putch('?', putdat);
  8004a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004b3:	ff 55 08             	call   *0x8(%ebp)
  8004b6:	eb 0a                	jmp    8004c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004c5:	0f be 06             	movsbl (%esi),%eax
  8004c8:	46                   	inc    %esi
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 21                	je     8004ee <vprintfmt+0x23c>
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	78 c9                	js     80049a <vprintfmt+0x1e8>
  8004d1:	4f                   	dec    %edi
  8004d2:	79 c6                	jns    80049a <vprintfmt+0x1e8>
  8004d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004d7:	89 de                	mov    %ebx,%esi
  8004d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004dc:	eb 18                	jmp    8004f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004eb:	4b                   	dec    %ebx
  8004ec:	eb 08                	jmp    8004f6 <vprintfmt+0x244>
  8004ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f1:	89 de                	mov    %ebx,%esi
  8004f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f6:	85 db                	test   %ebx,%ebx
  8004f8:	7f e4                	jg     8004de <vprintfmt+0x22c>
  8004fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800502:	e9 ce fd ff ff       	jmp    8002d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800507:	83 f9 01             	cmp    $0x1,%ecx
  80050a:	7e 10                	jle    80051c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8d 50 08             	lea    0x8(%eax),%edx
  800512:	89 55 14             	mov    %edx,0x14(%ebp)
  800515:	8b 30                	mov    (%eax),%esi
  800517:	8b 78 04             	mov    0x4(%eax),%edi
  80051a:	eb 26                	jmp    800542 <vprintfmt+0x290>
	else if (lflag)
  80051c:	85 c9                	test   %ecx,%ecx
  80051e:	74 12                	je     800532 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 30                	mov    (%eax),%esi
  80052b:	89 f7                	mov    %esi,%edi
  80052d:	c1 ff 1f             	sar    $0x1f,%edi
  800530:	eb 10                	jmp    800542 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 04             	lea    0x4(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 30                	mov    (%eax),%esi
  80053d:	89 f7                	mov    %esi,%edi
  80053f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800542:	85 ff                	test   %edi,%edi
  800544:	78 0a                	js     800550 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800546:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054b:	e9 8c 00 00 00       	jmp    8005dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800554:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80055b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80055e:	f7 de                	neg    %esi
  800560:	83 d7 00             	adc    $0x0,%edi
  800563:	f7 df                	neg    %edi
			}
			base = 10;
  800565:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056a:	eb 70                	jmp    8005dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80056c:	89 ca                	mov    %ecx,%edx
  80056e:	8d 45 14             	lea    0x14(%ebp),%eax
  800571:	e8 c0 fc ff ff       	call   800236 <getuint>
  800576:	89 c6                	mov    %eax,%esi
  800578:	89 d7                	mov    %edx,%edi
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80057f:	eb 5b                	jmp    8005dc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800581:	89 ca                	mov    %ecx,%edx
  800583:	8d 45 14             	lea    0x14(%ebp),%eax
  800586:	e8 ab fc ff ff       	call   800236 <getuint>
  80058b:	89 c6                	mov    %eax,%esi
  80058d:	89 d7                	mov    %edx,%edi
			base = 8;
  80058f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800594:	eb 46                	jmp    8005dc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800596:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bb:	8b 30                	mov    (%eax),%esi
  8005bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005c7:	eb 13                	jmp    8005dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c9:	89 ca                	mov    %ecx,%edx
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 63 fc ff ff       	call   800236 <getuint>
  8005d3:	89 c6                	mov    %eax,%esi
  8005d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ef:	89 34 24             	mov    %esi,(%esp)
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	89 da                	mov    %ebx,%edx
  8005f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fb:	e8 6c fb ff ff       	call   80016c <printnum>
			break;
  800600:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800603:	e9 cd fc ff ff       	jmp    8002d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	89 04 24             	mov    %eax,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800615:	e9 bb fc ff ff       	jmp    8002d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800628:	eb 01                	jmp    80062b <vprintfmt+0x379>
  80062a:	4e                   	dec    %esi
  80062b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80062f:	75 f9                	jne    80062a <vprintfmt+0x378>
  800631:	e9 9f fc ff ff       	jmp    8002d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800636:	83 c4 4c             	add    $0x4c,%esp
  800639:	5b                   	pop    %ebx
  80063a:	5e                   	pop    %esi
  80063b:	5f                   	pop    %edi
  80063c:	5d                   	pop    %ebp
  80063d:	c3                   	ret    

0080063e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
  800641:	83 ec 28             	sub    $0x28,%esp
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80064d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800651:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80065b:	85 c0                	test   %eax,%eax
  80065d:	74 30                	je     80068f <vsnprintf+0x51>
  80065f:	85 d2                	test   %edx,%edx
  800661:	7e 33                	jle    800696 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80066a:	8b 45 10             	mov    0x10(%ebp),%eax
  80066d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800671:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800674:	89 44 24 04          	mov    %eax,0x4(%esp)
  800678:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  80067f:	e8 2e fc ff ff       	call   8002b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800684:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800687:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068d:	eb 0c                	jmp    80069b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800694:	eb 05                	jmp    80069b <vsnprintf+0x5d>
  800696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	e8 7b ff ff ff       	call   80063e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    
  8006c5:	00 00                	add    %al,(%eax)
	...

008006c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d3:	eb 01                	jmp    8006d6 <strlen+0xe>
		n++;
  8006d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006da:	75 f9                	jne    8006d5 <strlen+0xd>
		n++;
	return n;
}
  8006dc:	5d                   	pop    %ebp
  8006dd:	c3                   	ret    

008006de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	eb 01                	jmp    8006ef <strnlen+0x11>
		n++;
  8006ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ef:	39 d0                	cmp    %edx,%eax
  8006f1:	74 06                	je     8006f9 <strnlen+0x1b>
  8006f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f7:	75 f5                	jne    8006ee <strnlen+0x10>
		n++;
	return n;
}
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	53                   	push   %ebx
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800705:	ba 00 00 00 00       	mov    $0x0,%edx
  80070a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80070d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800710:	42                   	inc    %edx
  800711:	84 c9                	test   %cl,%cl
  800713:	75 f5                	jne    80070a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800722:	89 1c 24             	mov    %ebx,(%esp)
  800725:	e8 9e ff ff ff       	call   8006c8 <strlen>
	strcpy(dst + len, src);
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800731:	01 d8                	add    %ebx,%eax
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	e8 c0 ff ff ff       	call   8006fb <strcpy>
	return dst;
}
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	83 c4 08             	add    $0x8,%esp
  800740:	5b                   	pop    %ebx
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	56                   	push   %esi
  800747:	53                   	push   %ebx
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	eb 0c                	jmp    800764 <strncpy+0x21>
		*dst++ = *src;
  800758:	8a 1a                	mov    (%edx),%bl
  80075a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075d:	80 3a 01             	cmpb   $0x1,(%edx)
  800760:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800763:	41                   	inc    %ecx
  800764:	39 f1                	cmp    %esi,%ecx
  800766:	75 f0                	jne    800758 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	8b 75 08             	mov    0x8(%ebp),%esi
  800774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800777:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077a:	85 d2                	test   %edx,%edx
  80077c:	75 0a                	jne    800788 <strlcpy+0x1c>
  80077e:	89 f0                	mov    %esi,%eax
  800780:	eb 1a                	jmp    80079c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800782:	88 18                	mov    %bl,(%eax)
  800784:	40                   	inc    %eax
  800785:	41                   	inc    %ecx
  800786:	eb 02                	jmp    80078a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800788:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80078a:	4a                   	dec    %edx
  80078b:	74 0a                	je     800797 <strlcpy+0x2b>
  80078d:	8a 19                	mov    (%ecx),%bl
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ef                	jne    800782 <strlcpy+0x16>
  800793:	89 c2                	mov    %eax,%edx
  800795:	eb 02                	jmp    800799 <strlcpy+0x2d>
  800797:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 02                	jmp    8007af <strcmp+0xd>
		p++, q++;
  8007ad:	41                   	inc    %ecx
  8007ae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007af:	8a 01                	mov    (%ecx),%al
  8007b1:	84 c0                	test   %al,%al
  8007b3:	74 04                	je     8007b9 <strcmp+0x17>
  8007b5:	3a 02                	cmp    (%edx),%al
  8007b7:	74 f4                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b9:	0f b6 c0             	movzbl %al,%eax
  8007bc:	0f b6 12             	movzbl (%edx),%edx
  8007bf:	29 d0                	sub    %edx,%eax
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007d0:	eb 03                	jmp    8007d5 <strncmp+0x12>
		n--, p++, q++;
  8007d2:	4a                   	dec    %edx
  8007d3:	40                   	inc    %eax
  8007d4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 14                	je     8007ed <strncmp+0x2a>
  8007d9:	8a 18                	mov    (%eax),%bl
  8007db:	84 db                	test   %bl,%bl
  8007dd:	74 04                	je     8007e3 <strncmp+0x20>
  8007df:	3a 19                	cmp    (%ecx),%bl
  8007e1:	74 ef                	je     8007d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e3:	0f b6 00             	movzbl (%eax),%eax
  8007e6:	0f b6 11             	movzbl (%ecx),%edx
  8007e9:	29 d0                	sub    %edx,%eax
  8007eb:	eb 05                	jmp    8007f2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007fe:	eb 05                	jmp    800805 <strchr+0x10>
		if (*s == c)
  800800:	38 ca                	cmp    %cl,%dl
  800802:	74 0c                	je     800810 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800804:	40                   	inc    %eax
  800805:	8a 10                	mov    (%eax),%dl
  800807:	84 d2                	test   %dl,%dl
  800809:	75 f5                	jne    800800 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081b:	eb 05                	jmp    800822 <strfind+0x10>
		if (*s == c)
  80081d:	38 ca                	cmp    %cl,%dl
  80081f:	74 07                	je     800828 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800821:	40                   	inc    %eax
  800822:	8a 10                	mov    (%eax),%dl
  800824:	84 d2                	test   %dl,%dl
  800826:	75 f5                	jne    80081d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	57                   	push   %edi
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 7d 08             	mov    0x8(%ebp),%edi
  800833:	8b 45 0c             	mov    0xc(%ebp),%eax
  800836:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800839:	85 c9                	test   %ecx,%ecx
  80083b:	74 30                	je     80086d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800843:	75 25                	jne    80086a <memset+0x40>
  800845:	f6 c1 03             	test   $0x3,%cl
  800848:	75 20                	jne    80086a <memset+0x40>
		c &= 0xFF;
  80084a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084d:	89 d3                	mov    %edx,%ebx
  80084f:	c1 e3 08             	shl    $0x8,%ebx
  800852:	89 d6                	mov    %edx,%esi
  800854:	c1 e6 18             	shl    $0x18,%esi
  800857:	89 d0                	mov    %edx,%eax
  800859:	c1 e0 10             	shl    $0x10,%eax
  80085c:	09 f0                	or     %esi,%eax
  80085e:	09 d0                	or     %edx,%eax
  800860:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800862:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800865:	fc                   	cld    
  800866:	f3 ab                	rep stos %eax,%es:(%edi)
  800868:	eb 03                	jmp    80086d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086a:	fc                   	cld    
  80086b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80086d:	89 f8                	mov    %edi,%eax
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5f                   	pop    %edi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80087f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800882:	39 c6                	cmp    %eax,%esi
  800884:	73 34                	jae    8008ba <memmove+0x46>
  800886:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800889:	39 d0                	cmp    %edx,%eax
  80088b:	73 2d                	jae    8008ba <memmove+0x46>
		s += n;
		d += n;
  80088d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800890:	f6 c2 03             	test   $0x3,%dl
  800893:	75 1b                	jne    8008b0 <memmove+0x3c>
  800895:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089b:	75 13                	jne    8008b0 <memmove+0x3c>
  80089d:	f6 c1 03             	test   $0x3,%cl
  8008a0:	75 0e                	jne    8008b0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008a2:	83 ef 04             	sub    $0x4,%edi
  8008a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ab:	fd                   	std    
  8008ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ae:	eb 07                	jmp    8008b7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008b0:	4f                   	dec    %edi
  8008b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b4:	fd                   	std    
  8008b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b7:	fc                   	cld    
  8008b8:	eb 20                	jmp    8008da <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c0:	75 13                	jne    8008d5 <memmove+0x61>
  8008c2:	a8 03                	test   $0x3,%al
  8008c4:	75 0f                	jne    8008d5 <memmove+0x61>
  8008c6:	f6 c1 03             	test   $0x3,%cl
  8008c9:	75 0a                	jne    8008d5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008cb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ce:	89 c7                	mov    %eax,%edi
  8008d0:	fc                   	cld    
  8008d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d3:	eb 05                	jmp    8008da <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d5:	89 c7                	mov    %eax,%edi
  8008d7:	fc                   	cld    
  8008d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	89 04 24             	mov    %eax,(%esp)
  8008f8:	e8 77 ff ff ff       	call   800874 <memmove>
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 7d 08             	mov    0x8(%ebp),%edi
  800908:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090e:	ba 00 00 00 00       	mov    $0x0,%edx
  800913:	eb 16                	jmp    80092b <memcmp+0x2c>
		if (*s1 != *s2)
  800915:	8a 04 17             	mov    (%edi,%edx,1),%al
  800918:	42                   	inc    %edx
  800919:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80091d:	38 c8                	cmp    %cl,%al
  80091f:	74 0a                	je     80092b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c0             	movzbl %al,%eax
  800924:	0f b6 c9             	movzbl %cl,%ecx
  800927:	29 c8                	sub    %ecx,%eax
  800929:	eb 09                	jmp    800934 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092b:	39 da                	cmp    %ebx,%edx
  80092d:	75 e6                	jne    800915 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800942:	89 c2                	mov    %eax,%edx
  800944:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800947:	eb 05                	jmp    80094e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800949:	38 08                	cmp    %cl,(%eax)
  80094b:	74 05                	je     800952 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094d:	40                   	inc    %eax
  80094e:	39 d0                	cmp    %edx,%eax
  800950:	72 f7                	jb     800949 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 55 08             	mov    0x8(%ebp),%edx
  80095d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800960:	eb 01                	jmp    800963 <strtol+0xf>
		s++;
  800962:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800963:	8a 02                	mov    (%edx),%al
  800965:	3c 20                	cmp    $0x20,%al
  800967:	74 f9                	je     800962 <strtol+0xe>
  800969:	3c 09                	cmp    $0x9,%al
  80096b:	74 f5                	je     800962 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096d:	3c 2b                	cmp    $0x2b,%al
  80096f:	75 08                	jne    800979 <strtol+0x25>
		s++;
  800971:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800972:	bf 00 00 00 00       	mov    $0x0,%edi
  800977:	eb 13                	jmp    80098c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800979:	3c 2d                	cmp    $0x2d,%al
  80097b:	75 0a                	jne    800987 <strtol+0x33>
		s++, neg = 1;
  80097d:	8d 52 01             	lea    0x1(%edx),%edx
  800980:	bf 01 00 00 00       	mov    $0x1,%edi
  800985:	eb 05                	jmp    80098c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800987:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098c:	85 db                	test   %ebx,%ebx
  80098e:	74 05                	je     800995 <strtol+0x41>
  800990:	83 fb 10             	cmp    $0x10,%ebx
  800993:	75 28                	jne    8009bd <strtol+0x69>
  800995:	8a 02                	mov    (%edx),%al
  800997:	3c 30                	cmp    $0x30,%al
  800999:	75 10                	jne    8009ab <strtol+0x57>
  80099b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80099f:	75 0a                	jne    8009ab <strtol+0x57>
		s += 2, base = 16;
  8009a1:	83 c2 02             	add    $0x2,%edx
  8009a4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a9:	eb 12                	jmp    8009bd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009ab:	85 db                	test   %ebx,%ebx
  8009ad:	75 0e                	jne    8009bd <strtol+0x69>
  8009af:	3c 30                	cmp    $0x30,%al
  8009b1:	75 05                	jne    8009b8 <strtol+0x64>
		s++, base = 8;
  8009b3:	42                   	inc    %edx
  8009b4:	b3 08                	mov    $0x8,%bl
  8009b6:	eb 05                	jmp    8009bd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009b8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c4:	8a 0a                	mov    (%edx),%cl
  8009c6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009c9:	80 fb 09             	cmp    $0x9,%bl
  8009cc:	77 08                	ja     8009d6 <strtol+0x82>
			dig = *s - '0';
  8009ce:	0f be c9             	movsbl %cl,%ecx
  8009d1:	83 e9 30             	sub    $0x30,%ecx
  8009d4:	eb 1e                	jmp    8009f4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009d6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009d9:	80 fb 19             	cmp    $0x19,%bl
  8009dc:	77 08                	ja     8009e6 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009de:	0f be c9             	movsbl %cl,%ecx
  8009e1:	83 e9 57             	sub    $0x57,%ecx
  8009e4:	eb 0e                	jmp    8009f4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009e6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 12                	ja     800a00 <strtol+0xac>
			dig = *s - 'A' + 10;
  8009ee:	0f be c9             	movsbl %cl,%ecx
  8009f1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8009f4:	39 f1                	cmp    %esi,%ecx
  8009f6:	7d 0c                	jge    800a04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009f8:	42                   	inc    %edx
  8009f9:	0f af c6             	imul   %esi,%eax
  8009fc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8009fe:	eb c4                	jmp    8009c4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a00:	89 c1                	mov    %eax,%ecx
  800a02:	eb 02                	jmp    800a06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0a:	74 05                	je     800a11 <strtol+0xbd>
		*endptr = (char *) s;
  800a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a11:	85 ff                	test   %edi,%edi
  800a13:	74 04                	je     800a19 <strtol+0xc5>
  800a15:	89 c8                	mov    %ecx,%eax
  800a17:	f7 d8                	neg    %eax
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    
	...

00800a20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a31:	89 c3                	mov    %eax,%ebx
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	89 c6                	mov    %eax,%esi
  800a37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4e:	89 d1                	mov    %edx,%ecx
  800a50:	89 d3                	mov    %edx,%ebx
  800a52:	89 d7                	mov    %edx,%edi
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	89 cb                	mov    %ecx,%ebx
  800a75:	89 cf                	mov    %ecx,%edi
  800a77:	89 ce                	mov    %ecx,%esi
  800a79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	7e 28                	jle    800aa7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a8a:	00 
  800a8b:	c7 44 24 08 94 0f 80 	movl   $0x800f94,0x8(%esp)
  800a92:	00 
  800a93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800a9a:	00 
  800a9b:	c7 04 24 b1 0f 80 00 	movl   $0x800fb1,(%esp)
  800aa2:	e8 29 00 00 00       	call   800ad0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa7:	83 c4 2c             	add    $0x2c,%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	b8 02 00 00 00       	mov    $0x2,%eax
  800abf:	89 d1                	mov    %edx,%ecx
  800ac1:	89 d3                	mov    %edx,%ebx
  800ac3:	89 d7                	mov    %edx,%edi
  800ac5:	89 d6                	mov    %edx,%esi
  800ac7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    
	...

00800ad0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ad8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800adb:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800ae1:	e8 c9 ff ff ff       	call   800aaf <sys_getenvid>
  800ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae9:	89 54 24 10          	mov    %edx,0x10(%esp)
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800af4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800af8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afc:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  800b03:	e8 48 f6 ff ff       	call   800150 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b08:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0f:	89 04 24             	mov    %eax,(%esp)
  800b12:	e8 d8 f5 ff ff       	call   8000ef <vcprintf>
	cprintf("\n");
  800b17:	c7 04 24 84 0d 80 00 	movl   $0x800d84,(%esp)
  800b1e:	e8 2d f6 ff ff       	call   800150 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b23:	cc                   	int3   
  800b24:	eb fd                	jmp    800b23 <_panic+0x53>
	...

00800b28 <__udivdi3>:
  800b28:	55                   	push   %ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	83 ec 10             	sub    $0x10,%esp
  800b2e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b32:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b3a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b3e:	89 cd                	mov    %ecx,%ebp
  800b40:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b44:	85 c0                	test   %eax,%eax
  800b46:	75 2c                	jne    800b74 <__udivdi3+0x4c>
  800b48:	39 f9                	cmp    %edi,%ecx
  800b4a:	77 68                	ja     800bb4 <__udivdi3+0x8c>
  800b4c:	85 c9                	test   %ecx,%ecx
  800b4e:	75 0b                	jne    800b5b <__udivdi3+0x33>
  800b50:	b8 01 00 00 00       	mov    $0x1,%eax
  800b55:	31 d2                	xor    %edx,%edx
  800b57:	f7 f1                	div    %ecx
  800b59:	89 c1                	mov    %eax,%ecx
  800b5b:	31 d2                	xor    %edx,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	f7 f1                	div    %ecx
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 f0                	mov    %esi,%eax
  800b65:	f7 f1                	div    %ecx
  800b67:	89 c6                	mov    %eax,%esi
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	89 fa                	mov    %edi,%edx
  800b6d:	83 c4 10             	add    $0x10,%esp
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    
  800b74:	39 f8                	cmp    %edi,%eax
  800b76:	77 2c                	ja     800ba4 <__udivdi3+0x7c>
  800b78:	0f bd f0             	bsr    %eax,%esi
  800b7b:	83 f6 1f             	xor    $0x1f,%esi
  800b7e:	75 4c                	jne    800bcc <__udivdi3+0xa4>
  800b80:	39 f8                	cmp    %edi,%eax
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	72 0a                	jb     800b93 <__udivdi3+0x6b>
  800b89:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b8d:	0f 87 ad 00 00 00    	ja     800c40 <__udivdi3+0x118>
  800b93:	be 01 00 00 00       	mov    $0x1,%esi
  800b98:	89 f0                	mov    %esi,%eax
  800b9a:	89 fa                	mov    %edi,%edx
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
  800ba3:	90                   	nop
  800ba4:	31 ff                	xor    %edi,%edi
  800ba6:	31 f6                	xor    %esi,%esi
  800ba8:	89 f0                	mov    %esi,%eax
  800baa:	89 fa                	mov    %edi,%edx
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
  800bb3:	90                   	nop
  800bb4:	89 fa                	mov    %edi,%edx
  800bb6:	89 f0                	mov    %esi,%eax
  800bb8:	f7 f1                	div    %ecx
  800bba:	89 c6                	mov    %eax,%esi
  800bbc:	31 ff                	xor    %edi,%edi
  800bbe:	89 f0                	mov    %esi,%eax
  800bc0:	89 fa                	mov    %edi,%edx
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
  800bc9:	8d 76 00             	lea    0x0(%esi),%esi
  800bcc:	89 f1                	mov    %esi,%ecx
  800bce:	d3 e0                	shl    %cl,%eax
  800bd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd4:	b8 20 00 00 00       	mov    $0x20,%eax
  800bd9:	29 f0                	sub    %esi,%eax
  800bdb:	89 ea                	mov    %ebp,%edx
  800bdd:	88 c1                	mov    %al,%cl
  800bdf:	d3 ea                	shr    %cl,%edx
  800be1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800be5:	09 ca                	or     %ecx,%edx
  800be7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800beb:	89 f1                	mov    %esi,%ecx
  800bed:	d3 e5                	shl    %cl,%ebp
  800bef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bf3:	89 fd                	mov    %edi,%ebp
  800bf5:	88 c1                	mov    %al,%cl
  800bf7:	d3 ed                	shr    %cl,%ebp
  800bf9:	89 fa                	mov    %edi,%edx
  800bfb:	89 f1                	mov    %esi,%ecx
  800bfd:	d3 e2                	shl    %cl,%edx
  800bff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c03:	88 c1                	mov    %al,%cl
  800c05:	d3 ef                	shr    %cl,%edi
  800c07:	09 d7                	or     %edx,%edi
  800c09:	89 f8                	mov    %edi,%eax
  800c0b:	89 ea                	mov    %ebp,%edx
  800c0d:	f7 74 24 08          	divl   0x8(%esp)
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 c7                	mov    %eax,%edi
  800c15:	f7 64 24 0c          	mull   0xc(%esp)
  800c19:	39 d1                	cmp    %edx,%ecx
  800c1b:	72 17                	jb     800c34 <__udivdi3+0x10c>
  800c1d:	74 09                	je     800c28 <__udivdi3+0x100>
  800c1f:	89 fe                	mov    %edi,%esi
  800c21:	31 ff                	xor    %edi,%edi
  800c23:	e9 41 ff ff ff       	jmp    800b69 <__udivdi3+0x41>
  800c28:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c2c:	89 f1                	mov    %esi,%ecx
  800c2e:	d3 e2                	shl    %cl,%edx
  800c30:	39 c2                	cmp    %eax,%edx
  800c32:	73 eb                	jae    800c1f <__udivdi3+0xf7>
  800c34:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c37:	31 ff                	xor    %edi,%edi
  800c39:	e9 2b ff ff ff       	jmp    800b69 <__udivdi3+0x41>
  800c3e:	66 90                	xchg   %ax,%ax
  800c40:	31 f6                	xor    %esi,%esi
  800c42:	e9 22 ff ff ff       	jmp    800b69 <__udivdi3+0x41>
	...

00800c48 <__umoddi3>:
  800c48:	55                   	push   %ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	83 ec 20             	sub    $0x20,%esp
  800c4e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c52:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c56:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c5a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c5e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c62:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	89 f2                	mov    %esi,%edx
  800c6a:	85 ed                	test   %ebp,%ebp
  800c6c:	75 16                	jne    800c84 <__umoddi3+0x3c>
  800c6e:	39 f1                	cmp    %esi,%ecx
  800c70:	0f 86 a6 00 00 00    	jbe    800d1c <__umoddi3+0xd4>
  800c76:	f7 f1                	div    %ecx
  800c78:	89 d0                	mov    %edx,%eax
  800c7a:	31 d2                	xor    %edx,%edx
  800c7c:	83 c4 20             	add    $0x20,%esp
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
  800c83:	90                   	nop
  800c84:	39 f5                	cmp    %esi,%ebp
  800c86:	0f 87 ac 00 00 00    	ja     800d38 <__umoddi3+0xf0>
  800c8c:	0f bd c5             	bsr    %ebp,%eax
  800c8f:	83 f0 1f             	xor    $0x1f,%eax
  800c92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c96:	0f 84 a8 00 00 00    	je     800d44 <__umoddi3+0xfc>
  800c9c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ca0:	d3 e5                	shl    %cl,%ebp
  800ca2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ca7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800cab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800caf:	89 f9                	mov    %edi,%ecx
  800cb1:	d3 e8                	shr    %cl,%eax
  800cb3:	09 e8                	or     %ebp,%eax
  800cb5:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cb9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cbd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cc1:	d3 e0                	shl    %cl,%eax
  800cc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc7:	89 f2                	mov    %esi,%edx
  800cc9:	d3 e2                	shl    %cl,%edx
  800ccb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ccf:	d3 e0                	shl    %cl,%eax
  800cd1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cd5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	d3 e8                	shr    %cl,%eax
  800cdd:	09 d0                	or     %edx,%eax
  800cdf:	d3 ee                	shr    %cl,%esi
  800ce1:	89 f2                	mov    %esi,%edx
  800ce3:	f7 74 24 18          	divl   0x18(%esp)
  800ce7:	89 d6                	mov    %edx,%esi
  800ce9:	f7 64 24 0c          	mull   0xc(%esp)
  800ced:	89 c5                	mov    %eax,%ebp
  800cef:	89 d1                	mov    %edx,%ecx
  800cf1:	39 d6                	cmp    %edx,%esi
  800cf3:	72 67                	jb     800d5c <__umoddi3+0x114>
  800cf5:	74 75                	je     800d6c <__umoddi3+0x124>
  800cf7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cfb:	29 e8                	sub    %ebp,%eax
  800cfd:	19 ce                	sbb    %ecx,%esi
  800cff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	89 f2                	mov    %esi,%edx
  800d07:	89 f9                	mov    %edi,%ecx
  800d09:	d3 e2                	shl    %cl,%edx
  800d0b:	09 d0                	or     %edx,%eax
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	83 c4 20             	add    $0x20,%esp
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
  800d1c:	85 c9                	test   %ecx,%ecx
  800d1e:	75 0b                	jne    800d2b <__umoddi3+0xe3>
  800d20:	b8 01 00 00 00       	mov    $0x1,%eax
  800d25:	31 d2                	xor    %edx,%edx
  800d27:	f7 f1                	div    %ecx
  800d29:	89 c1                	mov    %eax,%ecx
  800d2b:	89 f0                	mov    %esi,%eax
  800d2d:	31 d2                	xor    %edx,%edx
  800d2f:	f7 f1                	div    %ecx
  800d31:	89 f8                	mov    %edi,%eax
  800d33:	e9 3e ff ff ff       	jmp    800c76 <__umoddi3+0x2e>
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	83 c4 20             	add    $0x20,%esp
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    
  800d41:	8d 76 00             	lea    0x0(%esi),%esi
  800d44:	39 f5                	cmp    %esi,%ebp
  800d46:	72 04                	jb     800d4c <__umoddi3+0x104>
  800d48:	39 f9                	cmp    %edi,%ecx
  800d4a:	77 06                	ja     800d52 <__umoddi3+0x10a>
  800d4c:	89 f2                	mov    %esi,%edx
  800d4e:	29 cf                	sub    %ecx,%edi
  800d50:	19 ea                	sbb    %ebp,%edx
  800d52:	89 f8                	mov    %edi,%eax
  800d54:	83 c4 20             	add    $0x20,%esp
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
  800d5b:	90                   	nop
  800d5c:	89 d1                	mov    %edx,%ecx
  800d5e:	89 c5                	mov    %eax,%ebp
  800d60:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d64:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d68:	eb 8d                	jmp    800cf7 <__umoddi3+0xaf>
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d70:	72 ea                	jb     800d5c <__umoddi3+0x114>
  800d72:	89 f1                	mov    %esi,%ecx
  800d74:	eb 81                	jmp    800cf7 <__umoddi3+0xaf>
