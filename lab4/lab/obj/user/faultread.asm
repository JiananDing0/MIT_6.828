
obj/user/faultread:     file format elf32-i386


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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  80004a:	e8 0d 01 00 00       	call   80015c <cprintf>
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
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800062:	e8 74 0a 00 00       	call   800adb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 cf 09 00 00       	call   800a89 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 14             	sub    $0x14,%esp
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cf:	40                   	inc    %eax
  8000d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d7:	75 19                	jne    8000f2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e0:	00 
  8000e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e4:	89 04 24             	mov    %eax,(%esp)
  8000e7:	e8 60 09 00 00       	call   800a4c <sys_cputs>
		b->idx = 0;
  8000ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f2:	ff 43 04             	incl   0x4(%ebx)
}
  8000f5:	83 c4 14             	add    $0x14,%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011f:	8b 45 08             	mov    0x8(%ebp),%eax
  800122:	89 44 24 08          	mov    %eax,0x8(%esp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 bc 00 80 00 	movl   $0x8000bc,(%esp)
  800137:	e8 82 01 00 00       	call   8002be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 f8 08 00 00       	call   800a4c <sys_cputs>

	return b.cnt;
}
  800154:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800162:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	8b 45 08             	mov    0x8(%ebp),%eax
  80016c:	89 04 24             	mov    %eax,(%esp)
  80016f:	e8 87 ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    
	...

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 3c             	sub    $0x3c,%esp
  800181:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800184:	89 d7                	mov    %edx,%edi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80018c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800192:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800195:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	85 c0                	test   %eax,%eax
  80019a:	75 08                	jne    8001a4 <printnum+0x2c>
  80019c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 57                	ja     8001fb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001a8:	4b                   	dec    %ebx
  8001a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c3:	00 
  8001c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d1:	e8 b2 0b 00 00       	call   800d88 <__udivdi3>
  8001d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e5:	89 fa                	mov    %edi,%edx
  8001e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ea:	e8 89 ff ff ff       	call   800178 <printnum>
  8001ef:	eb 0f                	jmp    800200 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f5:	89 34 24             	mov    %esi,(%esp)
  8001f8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fb:	4b                   	dec    %ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7f f1                	jg     8001f1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800200:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800204:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800216:	00 
  800217:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	e8 7f 0c 00 00       	call   800ea8 <__umoddi3>
  800229:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022d:	0f be 80 08 10 80 00 	movsbl 0x801008(%eax),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80023a:	83 c4 3c             	add    $0x3c,%esp
  80023d:	5b                   	pop    %ebx
  80023e:	5e                   	pop    %esi
  80023f:	5f                   	pop    %edi
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    

00800242 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800245:	83 fa 01             	cmp    $0x1,%edx
  800248:	7e 0e                	jle    800258 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024a:	8b 10                	mov    (%eax),%edx
  80024c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024f:	89 08                	mov    %ecx,(%eax)
  800251:	8b 02                	mov    (%edx),%eax
  800253:	8b 52 04             	mov    0x4(%edx),%edx
  800256:	eb 22                	jmp    80027a <getuint+0x38>
	else if (lflag)
  800258:	85 d2                	test   %edx,%edx
  80025a:	74 10                	je     80026c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
  80026a:	eb 0e                	jmp    80027a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800282:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800285:	8b 10                	mov    (%eax),%edx
  800287:	3b 50 04             	cmp    0x4(%eax),%edx
  80028a:	73 08                	jae    800294 <sprintputch+0x18>
		*b->buf++ = ch;
  80028c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028f:	88 0a                	mov    %cl,(%edx)
  800291:	42                   	inc    %edx
  800292:	89 10                	mov    %edx,(%eax)
}
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80029c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 02 00 00 00       	call   8002be <vprintfmt>
	va_end(ap);
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 4c             	sub    $0x4c,%esp
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ca:	8b 75 10             	mov    0x10(%ebp),%esi
  8002cd:	eb 12                	jmp    8002e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	0f 84 8b 03 00 00    	je     800662 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8002d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e1:	0f b6 06             	movzbl (%esi),%eax
  8002e4:	46                   	inc    %esi
  8002e5:	83 f8 25             	cmp    $0x25,%eax
  8002e8:	75 e5                	jne    8002cf <vprintfmt+0x11>
  8002ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800301:	b9 00 00 00 00       	mov    $0x0,%ecx
  800306:	eb 26                	jmp    80032e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80030f:	eb 1d                	jmp    80032e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800314:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800318:	eb 14                	jmp    80032e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80031d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800324:	eb 08                	jmp    80032e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800326:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800329:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	0f b6 06             	movzbl (%esi),%eax
  800331:	8d 56 01             	lea    0x1(%esi),%edx
  800334:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800337:	8a 16                	mov    (%esi),%dl
  800339:	83 ea 23             	sub    $0x23,%edx
  80033c:	80 fa 55             	cmp    $0x55,%dl
  80033f:	0f 87 01 03 00 00    	ja     800646 <vprintfmt+0x388>
  800345:	0f b6 d2             	movzbl %dl,%edx
  800348:	ff 24 95 c0 10 80 00 	jmp    *0x8010c0(,%edx,4)
  80034f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800352:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800357:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80035a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80035e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800361:	8d 50 d0             	lea    -0x30(%eax),%edx
  800364:	83 fa 09             	cmp    $0x9,%edx
  800367:	77 2a                	ja     800393 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800369:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036a:	eb eb                	jmp    800357 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	8d 50 04             	lea    0x4(%eax),%edx
  800372:	89 55 14             	mov    %edx,0x14(%ebp)
  800375:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 17                	jmp    800393 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80037c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800380:	78 98                	js     80031a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800385:	eb a7                	jmp    80032e <vprintfmt+0x70>
  800387:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800391:	eb 9b                	jmp    80032e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800393:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800397:	79 95                	jns    80032e <vprintfmt+0x70>
  800399:	eb 8b                	jmp    800326 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039f:	eb 8d                	jmp    80032e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 50 04             	lea    0x4(%eax),%edx
  8003a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b9:	e9 23 ff ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 50 04             	lea    0x4(%eax),%edx
  8003c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c7:	8b 00                	mov    (%eax),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	79 02                	jns    8003cf <vprintfmt+0x111>
  8003cd:	f7 d8                	neg    %eax
  8003cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 08             	cmp    $0x8,%eax
  8003d4:	7f 0b                	jg     8003e1 <vprintfmt+0x123>
  8003d6:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	75 23                	jne    800404 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e5:	c7 44 24 08 20 10 80 	movl   $0x801020,0x8(%esp)
  8003ec:	00 
  8003ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 9a fe ff ff       	call   800296 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 dd fe ff ff       	jmp    8002e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800408:	c7 44 24 08 29 10 80 	movl   $0x801029,0x8(%esp)
  80040f:	00 
  800410:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800414:	8b 55 08             	mov    0x8(%ebp),%edx
  800417:	89 14 24             	mov    %edx,(%esp)
  80041a:	e8 77 fe ff ff       	call   800296 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800422:	e9 ba fe ff ff       	jmp    8002e1 <vprintfmt+0x23>
  800427:	89 f9                	mov    %edi,%ecx
  800429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	8b 30                	mov    (%eax),%esi
  80043a:	85 f6                	test   %esi,%esi
  80043c:	75 05                	jne    800443 <vprintfmt+0x185>
				p = "(null)";
  80043e:	be 19 10 80 00       	mov    $0x801019,%esi
			if (width > 0 && padc != '-')
  800443:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800447:	0f 8e 84 00 00 00    	jle    8004d1 <vprintfmt+0x213>
  80044d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800451:	74 7e                	je     8004d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800457:	89 34 24             	mov    %esi,(%esp)
  80045a:	e8 ab 02 00 00       	call   80070a <strnlen>
  80045f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800462:	29 c2                	sub    %eax,%edx
  800464:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800467:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80046b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80046e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800471:	89 de                	mov    %ebx,%esi
  800473:	89 d3                	mov    %edx,%ebx
  800475:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	eb 0b                	jmp    800484 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800479:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047d:	89 3c 24             	mov    %edi,(%esp)
  800480:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	4b                   	dec    %ebx
  800484:	85 db                	test   %ebx,%ebx
  800486:	7f f1                	jg     800479 <vprintfmt+0x1bb>
  800488:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80048b:	89 f3                	mov    %esi,%ebx
  80048d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800490:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	79 05                	jns    80049c <vprintfmt+0x1de>
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	29 c2                	sub    %eax,%edx
  8004a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a4:	eb 2b                	jmp    8004d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004aa:	74 18                	je     8004c4 <vprintfmt+0x206>
  8004ac:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004af:	83 fa 5e             	cmp    $0x5e,%edx
  8004b2:	76 10                	jbe    8004c4 <vprintfmt+0x206>
					putch('?', putdat);
  8004b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
  8004c2:	eb 0a                	jmp    8004ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d1:	0f be 06             	movsbl (%esi),%eax
  8004d4:	46                   	inc    %esi
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 21                	je     8004fa <vprintfmt+0x23c>
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	78 c9                	js     8004a6 <vprintfmt+0x1e8>
  8004dd:	4f                   	dec    %edi
  8004de:	79 c6                	jns    8004a6 <vprintfmt+0x1e8>
  8004e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e3:	89 de                	mov    %ebx,%esi
  8004e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f7:	4b                   	dec    %ebx
  8004f8:	eb 08                	jmp    800502 <vprintfmt+0x244>
  8004fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004fd:	89 de                	mov    %ebx,%esi
  8004ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800502:	85 db                	test   %ebx,%ebx
  800504:	7f e4                	jg     8004ea <vprintfmt+0x22c>
  800506:	89 7d 08             	mov    %edi,0x8(%ebp)
  800509:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050e:	e9 ce fd ff ff       	jmp    8002e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800513:	83 f9 01             	cmp    $0x1,%ecx
  800516:	7e 10                	jle    800528 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 08             	lea    0x8(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 30                	mov    (%eax),%esi
  800523:	8b 78 04             	mov    0x4(%eax),%edi
  800526:	eb 26                	jmp    80054e <vprintfmt+0x290>
	else if (lflag)
  800528:	85 c9                	test   %ecx,%ecx
  80052a:	74 12                	je     80053e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	89 f7                	mov    %esi,%edi
  800539:	c1 ff 1f             	sar    $0x1f,%edi
  80053c:	eb 10                	jmp    80054e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 30                	mov    (%eax),%esi
  800549:	89 f7                	mov    %esi,%edi
  80054b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80054e:	85 ff                	test   %edi,%edi
  800550:	78 0a                	js     80055c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 ac 00 00 00       	jmp    800608 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80056a:	f7 de                	neg    %esi
  80056c:	83 d7 00             	adc    $0x0,%edi
  80056f:	f7 df                	neg    %edi
			}
			base = 10;
  800571:	b8 0a 00 00 00       	mov    $0xa,%eax
  800576:	e9 8d 00 00 00       	jmp    800608 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057b:	89 ca                	mov    %ecx,%edx
  80057d:	8d 45 14             	lea    0x14(%ebp),%eax
  800580:	e8 bd fc ff ff       	call   800242 <getuint>
  800585:	89 c6                	mov    %eax,%esi
  800587:	89 d7                	mov    %edx,%edi
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80058e:	eb 78                	jmp    800608 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80059e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005a9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005bd:	e9 1f fd ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f3:	eb 13                	jmp    800608 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f5:	89 ca                	mov    %ecx,%edx
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 43 fc ff ff       	call   800242 <getuint>
  8005ff:	89 c6                	mov    %eax,%esi
  800601:	89 d7                	mov    %edx,%edi
			base = 16;
  800603:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800608:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80060c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800617:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061b:	89 34 24             	mov    %esi,(%esp)
  80061e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800622:	89 da                	mov    %ebx,%edx
  800624:	8b 45 08             	mov    0x8(%ebp),%eax
  800627:	e8 4c fb ff ff       	call   800178 <printnum>
			break;
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062f:	e9 ad fc ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800641:	e9 9b fc ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800646:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800651:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800654:	eb 01                	jmp    800657 <vprintfmt+0x399>
  800656:	4e                   	dec    %esi
  800657:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80065b:	75 f9                	jne    800656 <vprintfmt+0x398>
  80065d:	e9 7f fc ff ff       	jmp    8002e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800662:	83 c4 4c             	add    $0x4c,%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	83 ec 28             	sub    $0x28,%esp
  800670:	8b 45 08             	mov    0x8(%ebp),%eax
  800673:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800676:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800679:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800680:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800687:	85 c0                	test   %eax,%eax
  800689:	74 30                	je     8006bb <vsnprintf+0x51>
  80068b:	85 d2                	test   %edx,%edx
  80068d:	7e 33                	jle    8006c2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800696:	8b 45 10             	mov    0x10(%ebp),%eax
  800699:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a4:	c7 04 24 7c 02 80 00 	movl   $0x80027c,(%esp)
  8006ab:	e8 0e fc ff ff       	call   8002be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	eb 0c                	jmp    8006c7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c0:	eb 05                	jmp    8006c7 <vsnprintf+0x5d>
  8006c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 7b ff ff ff       	call   80066a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    
  8006f1:	00 00                	add    %al,(%eax)
	...

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	eb 01                	jmp    800702 <strlen+0xe>
		n++;
  800701:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800702:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800706:	75 f9                	jne    800701 <strlen+0xd>
		n++;
	return n;
}
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  800718:	eb 01                	jmp    80071b <strnlen+0x11>
		n++;
  80071a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071b:	39 d0                	cmp    %edx,%eax
  80071d:	74 06                	je     800725 <strnlen+0x1b>
  80071f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800723:	75 f5                	jne    80071a <strnlen+0x10>
		n++;
	return n;
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
  800736:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800739:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80073c:	42                   	inc    %edx
  80073d:	84 c9                	test   %cl,%cl
  80073f:	75 f5                	jne    800736 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800741:	5b                   	pop    %ebx
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074e:	89 1c 24             	mov    %ebx,(%esp)
  800751:	e8 9e ff ff ff       	call   8006f4 <strlen>
	strcpy(dst + len, src);
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
  800759:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075d:	01 d8                	add    %ebx,%eax
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	e8 c0 ff ff ff       	call   800727 <strcpy>
	return dst;
}
  800767:	89 d8                	mov    %ebx,%eax
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	eb 0c                	jmp    800790 <strncpy+0x21>
		*dst++ = *src;
  800784:	8a 1a                	mov    (%edx),%bl
  800786:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800789:	80 3a 01             	cmpb   $0x1,(%edx)
  80078c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078f:	41                   	inc    %ecx
  800790:	39 f1                	cmp    %esi,%ecx
  800792:	75 f0                	jne    800784 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5e                   	pop    %esi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	75 0a                	jne    8007b4 <strlcpy+0x1c>
  8007aa:	89 f0                	mov    %esi,%eax
  8007ac:	eb 1a                	jmp    8007c8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ae:	88 18                	mov    %bl,(%eax)
  8007b0:	40                   	inc    %eax
  8007b1:	41                   	inc    %ecx
  8007b2:	eb 02                	jmp    8007b6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007b6:	4a                   	dec    %edx
  8007b7:	74 0a                	je     8007c3 <strlcpy+0x2b>
  8007b9:	8a 19                	mov    (%ecx),%bl
  8007bb:	84 db                	test   %bl,%bl
  8007bd:	75 ef                	jne    8007ae <strlcpy+0x16>
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	eb 02                	jmp    8007c5 <strlcpy+0x2d>
  8007c3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007c5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007c8:	29 f0                	sub    %esi,%eax
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d7:	eb 02                	jmp    8007db <strcmp+0xd>
		p++, q++;
  8007d9:	41                   	inc    %ecx
  8007da:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007db:	8a 01                	mov    (%ecx),%al
  8007dd:	84 c0                	test   %al,%al
  8007df:	74 04                	je     8007e5 <strcmp+0x17>
  8007e1:	3a 02                	cmp    (%edx),%al
  8007e3:	74 f4                	je     8007d9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e5:	0f b6 c0             	movzbl %al,%eax
  8007e8:	0f b6 12             	movzbl (%edx),%edx
  8007eb:	29 d0                	sub    %edx,%eax
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007fc:	eb 03                	jmp    800801 <strncmp+0x12>
		n--, p++, q++;
  8007fe:	4a                   	dec    %edx
  8007ff:	40                   	inc    %eax
  800800:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800801:	85 d2                	test   %edx,%edx
  800803:	74 14                	je     800819 <strncmp+0x2a>
  800805:	8a 18                	mov    (%eax),%bl
  800807:	84 db                	test   %bl,%bl
  800809:	74 04                	je     80080f <strncmp+0x20>
  80080b:	3a 19                	cmp    (%ecx),%bl
  80080d:	74 ef                	je     8007fe <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 00             	movzbl (%eax),%eax
  800812:	0f b6 11             	movzbl (%ecx),%edx
  800815:	29 d0                	sub    %edx,%eax
  800817:	eb 05                	jmp    80081e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082a:	eb 05                	jmp    800831 <strchr+0x10>
		if (*s == c)
  80082c:	38 ca                	cmp    %cl,%dl
  80082e:	74 0c                	je     80083c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800830:	40                   	inc    %eax
  800831:	8a 10                	mov    (%eax),%dl
  800833:	84 d2                	test   %dl,%dl
  800835:	75 f5                	jne    80082c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800847:	eb 05                	jmp    80084e <strfind+0x10>
		if (*s == c)
  800849:	38 ca                	cmp    %cl,%dl
  80084b:	74 07                	je     800854 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80084d:	40                   	inc    %eax
  80084e:	8a 10                	mov    (%eax),%dl
  800850:	84 d2                	test   %dl,%dl
  800852:	75 f5                	jne    800849 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800862:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800865:	85 c9                	test   %ecx,%ecx
  800867:	74 30                	je     800899 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800869:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086f:	75 25                	jne    800896 <memset+0x40>
  800871:	f6 c1 03             	test   $0x3,%cl
  800874:	75 20                	jne    800896 <memset+0x40>
		c &= 0xFF;
  800876:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800879:	89 d3                	mov    %edx,%ebx
  80087b:	c1 e3 08             	shl    $0x8,%ebx
  80087e:	89 d6                	mov    %edx,%esi
  800880:	c1 e6 18             	shl    $0x18,%esi
  800883:	89 d0                	mov    %edx,%eax
  800885:	c1 e0 10             	shl    $0x10,%eax
  800888:	09 f0                	or     %esi,%eax
  80088a:	09 d0                	or     %edx,%eax
  80088c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80088e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800891:	fc                   	cld    
  800892:	f3 ab                	rep stos %eax,%es:(%edi)
  800894:	eb 03                	jmp    800899 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800896:	fc                   	cld    
  800897:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800899:	89 f8                	mov    %edi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	57                   	push   %edi
  8008a4:	56                   	push   %esi
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ae:	39 c6                	cmp    %eax,%esi
  8008b0:	73 34                	jae    8008e6 <memmove+0x46>
  8008b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b5:	39 d0                	cmp    %edx,%eax
  8008b7:	73 2d                	jae    8008e6 <memmove+0x46>
		s += n;
		d += n;
  8008b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bc:	f6 c2 03             	test   $0x3,%dl
  8008bf:	75 1b                	jne    8008dc <memmove+0x3c>
  8008c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c7:	75 13                	jne    8008dc <memmove+0x3c>
  8008c9:	f6 c1 03             	test   $0x3,%cl
  8008cc:	75 0e                	jne    8008dc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ce:	83 ef 04             	sub    $0x4,%edi
  8008d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008d7:	fd                   	std    
  8008d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008da:	eb 07                	jmp    8008e3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008dc:	4f                   	dec    %edi
  8008dd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e0:	fd                   	std    
  8008e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e3:	fc                   	cld    
  8008e4:	eb 20                	jmp    800906 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ec:	75 13                	jne    800901 <memmove+0x61>
  8008ee:	a8 03                	test   $0x3,%al
  8008f0:	75 0f                	jne    800901 <memmove+0x61>
  8008f2:	f6 c1 03             	test   $0x3,%cl
  8008f5:	75 0a                	jne    800901 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008fa:	89 c7                	mov    %eax,%edi
  8008fc:	fc                   	cld    
  8008fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ff:	eb 05                	jmp    800906 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800901:	89 c7                	mov    %eax,%edi
  800903:	fc                   	cld    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800910:	8b 45 10             	mov    0x10(%ebp),%eax
  800913:	89 44 24 08          	mov    %eax,0x8(%esp)
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	e8 77 ff ff ff       	call   8008a0 <memmove>
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 7d 08             	mov    0x8(%ebp),%edi
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093a:	ba 00 00 00 00       	mov    $0x0,%edx
  80093f:	eb 16                	jmp    800957 <memcmp+0x2c>
		if (*s1 != *s2)
  800941:	8a 04 17             	mov    (%edi,%edx,1),%al
  800944:	42                   	inc    %edx
  800945:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800949:	38 c8                	cmp    %cl,%al
  80094b:	74 0a                	je     800957 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80094d:	0f b6 c0             	movzbl %al,%eax
  800950:	0f b6 c9             	movzbl %cl,%ecx
  800953:	29 c8                	sub    %ecx,%eax
  800955:	eb 09                	jmp    800960 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800957:	39 da                	cmp    %ebx,%edx
  800959:	75 e6                	jne    800941 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80096e:	89 c2                	mov    %eax,%edx
  800970:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800973:	eb 05                	jmp    80097a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800975:	38 08                	cmp    %cl,(%eax)
  800977:	74 05                	je     80097e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800979:	40                   	inc    %eax
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	72 f7                	jb     800975 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 55 08             	mov    0x8(%ebp),%edx
  800989:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	eb 01                	jmp    80098f <strtol+0xf>
		s++;
  80098e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098f:	8a 02                	mov    (%edx),%al
  800991:	3c 20                	cmp    $0x20,%al
  800993:	74 f9                	je     80098e <strtol+0xe>
  800995:	3c 09                	cmp    $0x9,%al
  800997:	74 f5                	je     80098e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800999:	3c 2b                	cmp    $0x2b,%al
  80099b:	75 08                	jne    8009a5 <strtol+0x25>
		s++;
  80099d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a3:	eb 13                	jmp    8009b8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a5:	3c 2d                	cmp    $0x2d,%al
  8009a7:	75 0a                	jne    8009b3 <strtol+0x33>
		s++, neg = 1;
  8009a9:	8d 52 01             	lea    0x1(%edx),%edx
  8009ac:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b1:	eb 05                	jmp    8009b8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b8:	85 db                	test   %ebx,%ebx
  8009ba:	74 05                	je     8009c1 <strtol+0x41>
  8009bc:	83 fb 10             	cmp    $0x10,%ebx
  8009bf:	75 28                	jne    8009e9 <strtol+0x69>
  8009c1:	8a 02                	mov    (%edx),%al
  8009c3:	3c 30                	cmp    $0x30,%al
  8009c5:	75 10                	jne    8009d7 <strtol+0x57>
  8009c7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009cb:	75 0a                	jne    8009d7 <strtol+0x57>
		s += 2, base = 16;
  8009cd:	83 c2 02             	add    $0x2,%edx
  8009d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d5:	eb 12                	jmp    8009e9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	75 0e                	jne    8009e9 <strtol+0x69>
  8009db:	3c 30                	cmp    $0x30,%al
  8009dd:	75 05                	jne    8009e4 <strtol+0x64>
		s++, base = 8;
  8009df:	42                   	inc    %edx
  8009e0:	b3 08                	mov    $0x8,%bl
  8009e2:	eb 05                	jmp    8009e9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009e4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f0:	8a 0a                	mov    (%edx),%cl
  8009f2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009f5:	80 fb 09             	cmp    $0x9,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0x82>
			dig = *s - '0';
  8009fa:	0f be c9             	movsbl %cl,%ecx
  8009fd:	83 e9 30             	sub    $0x30,%ecx
  800a00:	eb 1e                	jmp    800a20 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a02:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a05:	80 fb 19             	cmp    $0x19,%bl
  800a08:	77 08                	ja     800a12 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a0a:	0f be c9             	movsbl %cl,%ecx
  800a0d:	83 e9 57             	sub    $0x57,%ecx
  800a10:	eb 0e                	jmp    800a20 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a12:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 12                	ja     800a2c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a1a:	0f be c9             	movsbl %cl,%ecx
  800a1d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a20:	39 f1                	cmp    %esi,%ecx
  800a22:	7d 0c                	jge    800a30 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a24:	42                   	inc    %edx
  800a25:	0f af c6             	imul   %esi,%eax
  800a28:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a2a:	eb c4                	jmp    8009f0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a2c:	89 c1                	mov    %eax,%ecx
  800a2e:	eb 02                	jmp    800a32 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a30:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a36:	74 05                	je     800a3d <strtol+0xbd>
		*endptr = (char *) s;
  800a38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	74 04                	je     800a45 <strtol+0xc5>
  800a41:	89 c8                	mov    %ecx,%eax
  800a43:	f7 d8                	neg    %eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    
	...

00800a4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	89 c3                	mov    %eax,%ebx
  800a5f:	89 c7                	mov    %eax,%edi
  800a61:	89 c6                	mov    %eax,%esi
  800a63:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7a:	89 d1                	mov    %edx,%ecx
  800a7c:	89 d3                	mov    %edx,%ebx
  800a7e:	89 d7                	mov    %edx,%edi
  800a80:	89 d6                	mov    %edx,%esi
  800a82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5f                   	pop    %edi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a97:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9f:	89 cb                	mov    %ecx,%ebx
  800aa1:	89 cf                	mov    %ecx,%edi
  800aa3:	89 ce                	mov    %ecx,%esi
  800aa5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	7e 28                	jle    800ad3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aaf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ab6:	00 
  800ab7:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800abe:	00 
  800abf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ac6:	00 
  800ac7:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800ace:	e8 5d 02 00 00       	call   800d30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad3:	83 c4 2c             	add    $0x2c,%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_yield>:

void
sys_yield(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	be 00 00 00 00       	mov    $0x0,%esi
  800b27:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	89 f7                	mov    %esi,%edi
  800b37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 28                	jle    800b65 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b41:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b48:	00 
  800b49:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800b50:	00 
  800b51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b58:	00 
  800b59:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800b60:	e8 cb 01 00 00       	call   800d30 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b65:	83 c4 2c             	add    $0x2c,%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 28                	jle    800bb8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b94:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b9b:	00 
  800b9c:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800ba3:	00 
  800ba4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bab:	00 
  800bac:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800bb3:	e8 78 01 00 00       	call   800d30 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb8:	83 c4 2c             	add    $0x2c,%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bce:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 df                	mov    %ebx,%edi
  800bdb:	89 de                	mov    %ebx,%esi
  800bdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 28                	jle    800c0b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bee:	00 
  800bef:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfe:	00 
  800bff:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800c06:	e8 25 01 00 00       	call   800d30 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0b:	83 c4 2c             	add    $0x2c,%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c21:	b8 08 00 00 00       	mov    $0x8,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	89 df                	mov    %ebx,%edi
  800c2e:	89 de                	mov    %ebx,%esi
  800c30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 28                	jle    800c5e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c41:	00 
  800c42:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800c49:	00 
  800c4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c51:	00 
  800c52:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800c59:	e8 d2 00 00 00       	call   800d30 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5e:	83 c4 2c             	add    $0x2c,%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	b8 09 00 00 00       	mov    $0x9,%eax
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 28                	jle    800cb1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c94:	00 
  800c95:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca4:	00 
  800ca5:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800cac:	e8 7f 00 00 00       	call   800d30 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb1:	83 c4 2c             	add    $0x2c,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	be 00 00 00 00       	mov    $0x0,%esi
  800cc4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 cb                	mov    %ecx,%ebx
  800cf4:	89 cf                	mov    %ecx,%edi
  800cf6:	89 ce                	mov    %ecx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800d21:	e8 0a 00 00 00       	call   800d30 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d26:	83 c4 2c             	add    $0x2c,%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    
	...

00800d30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d38:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d3b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d41:	e8 95 fd ff ff       	call   800adb <sys_getenvid>
  800d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d49:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5c:	c7 04 24 70 12 80 00 	movl   $0x801270,(%esp)
  800d63:	e8 f4 f3 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d68:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6f:	89 04 24             	mov    %eax,(%esp)
  800d72:	e8 84 f3 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800d77:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800d7e:	e8 d9 f3 ff ff       	call   80015c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d83:	cc                   	int3   
  800d84:	eb fd                	jmp    800d83 <_panic+0x53>
	...

00800d88 <__udivdi3>:
  800d88:	55                   	push   %ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	83 ec 10             	sub    $0x10,%esp
  800d8e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d9a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d9e:	89 cd                	mov    %ecx,%ebp
  800da0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800da4:	85 c0                	test   %eax,%eax
  800da6:	75 2c                	jne    800dd4 <__udivdi3+0x4c>
  800da8:	39 f9                	cmp    %edi,%ecx
  800daa:	77 68                	ja     800e14 <__udivdi3+0x8c>
  800dac:	85 c9                	test   %ecx,%ecx
  800dae:	75 0b                	jne    800dbb <__udivdi3+0x33>
  800db0:	b8 01 00 00 00       	mov    $0x1,%eax
  800db5:	31 d2                	xor    %edx,%edx
  800db7:	f7 f1                	div    %ecx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	89 f8                	mov    %edi,%eax
  800dbf:	f7 f1                	div    %ecx
  800dc1:	89 c7                	mov    %eax,%edi
  800dc3:	89 f0                	mov    %esi,%eax
  800dc5:	f7 f1                	div    %ecx
  800dc7:	89 c6                	mov    %eax,%esi
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
  800dd4:	39 f8                	cmp    %edi,%eax
  800dd6:	77 2c                	ja     800e04 <__udivdi3+0x7c>
  800dd8:	0f bd f0             	bsr    %eax,%esi
  800ddb:	83 f6 1f             	xor    $0x1f,%esi
  800dde:	75 4c                	jne    800e2c <__udivdi3+0xa4>
  800de0:	39 f8                	cmp    %edi,%eax
  800de2:	bf 00 00 00 00       	mov    $0x0,%edi
  800de7:	72 0a                	jb     800df3 <__udivdi3+0x6b>
  800de9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ded:	0f 87 ad 00 00 00    	ja     800ea0 <__udivdi3+0x118>
  800df3:	be 01 00 00 00       	mov    $0x1,%esi
  800df8:	89 f0                	mov    %esi,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	31 f6                	xor    %esi,%esi
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	89 fa                	mov    %edi,%edx
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	f7 f1                	div    %ecx
  800e1a:	89 c6                	mov    %eax,%esi
  800e1c:	31 ff                	xor    %edi,%edi
  800e1e:	89 f0                	mov    %esi,%eax
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
  800e29:	8d 76 00             	lea    0x0(%esi),%esi
  800e2c:	89 f1                	mov    %esi,%ecx
  800e2e:	d3 e0                	shl    %cl,%eax
  800e30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e34:	b8 20 00 00 00       	mov    $0x20,%eax
  800e39:	29 f0                	sub    %esi,%eax
  800e3b:	89 ea                	mov    %ebp,%edx
  800e3d:	88 c1                	mov    %al,%cl
  800e3f:	d3 ea                	shr    %cl,%edx
  800e41:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e45:	09 ca                	or     %ecx,%edx
  800e47:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4b:	89 f1                	mov    %esi,%ecx
  800e4d:	d3 e5                	shl    %cl,%ebp
  800e4f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e53:	89 fd                	mov    %edi,%ebp
  800e55:	88 c1                	mov    %al,%cl
  800e57:	d3 ed                	shr    %cl,%ebp
  800e59:	89 fa                	mov    %edi,%edx
  800e5b:	89 f1                	mov    %esi,%ecx
  800e5d:	d3 e2                	shl    %cl,%edx
  800e5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e63:	88 c1                	mov    %al,%cl
  800e65:	d3 ef                	shr    %cl,%edi
  800e67:	09 d7                	or     %edx,%edi
  800e69:	89 f8                	mov    %edi,%eax
  800e6b:	89 ea                	mov    %ebp,%edx
  800e6d:	f7 74 24 08          	divl   0x8(%esp)
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 c7                	mov    %eax,%edi
  800e75:	f7 64 24 0c          	mull   0xc(%esp)
  800e79:	39 d1                	cmp    %edx,%ecx
  800e7b:	72 17                	jb     800e94 <__udivdi3+0x10c>
  800e7d:	74 09                	je     800e88 <__udivdi3+0x100>
  800e7f:	89 fe                	mov    %edi,%esi
  800e81:	31 ff                	xor    %edi,%edi
  800e83:	e9 41 ff ff ff       	jmp    800dc9 <__udivdi3+0x41>
  800e88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e8c:	89 f1                	mov    %esi,%ecx
  800e8e:	d3 e2                	shl    %cl,%edx
  800e90:	39 c2                	cmp    %eax,%edx
  800e92:	73 eb                	jae    800e7f <__udivdi3+0xf7>
  800e94:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e97:	31 ff                	xor    %edi,%edi
  800e99:	e9 2b ff ff ff       	jmp    800dc9 <__udivdi3+0x41>
  800e9e:	66 90                	xchg   %ax,%ax
  800ea0:	31 f6                	xor    %esi,%esi
  800ea2:	e9 22 ff ff ff       	jmp    800dc9 <__udivdi3+0x41>
	...

00800ea8 <__umoddi3>:
  800ea8:	55                   	push   %ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	83 ec 20             	sub    $0x20,%esp
  800eae:	8b 44 24 30          	mov    0x30(%esp),%eax
  800eb2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800eb6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eba:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ebe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ec2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ec6:	89 c7                	mov    %eax,%edi
  800ec8:	89 f2                	mov    %esi,%edx
  800eca:	85 ed                	test   %ebp,%ebp
  800ecc:	75 16                	jne    800ee4 <__umoddi3+0x3c>
  800ece:	39 f1                	cmp    %esi,%ecx
  800ed0:	0f 86 a6 00 00 00    	jbe    800f7c <__umoddi3+0xd4>
  800ed6:	f7 f1                	div    %ecx
  800ed8:	89 d0                	mov    %edx,%eax
  800eda:	31 d2                	xor    %edx,%edx
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
  800ee4:	39 f5                	cmp    %esi,%ebp
  800ee6:	0f 87 ac 00 00 00    	ja     800f98 <__umoddi3+0xf0>
  800eec:	0f bd c5             	bsr    %ebp,%eax
  800eef:	83 f0 1f             	xor    $0x1f,%eax
  800ef2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef6:	0f 84 a8 00 00 00    	je     800fa4 <__umoddi3+0xfc>
  800efc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f00:	d3 e5                	shl    %cl,%ebp
  800f02:	bf 20 00 00 00       	mov    $0x20,%edi
  800f07:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f0f:	89 f9                	mov    %edi,%ecx
  800f11:	d3 e8                	shr    %cl,%eax
  800f13:	09 e8                	or     %ebp,%eax
  800f15:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f19:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f21:	d3 e0                	shl    %cl,%eax
  800f23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f27:	89 f2                	mov    %esi,%edx
  800f29:	d3 e2                	shl    %cl,%edx
  800f2b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f2f:	d3 e0                	shl    %cl,%eax
  800f31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f35:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f39:	89 f9                	mov    %edi,%ecx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	09 d0                	or     %edx,%eax
  800f3f:	d3 ee                	shr    %cl,%esi
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	f7 74 24 18          	divl   0x18(%esp)
  800f47:	89 d6                	mov    %edx,%esi
  800f49:	f7 64 24 0c          	mull   0xc(%esp)
  800f4d:	89 c5                	mov    %eax,%ebp
  800f4f:	89 d1                	mov    %edx,%ecx
  800f51:	39 d6                	cmp    %edx,%esi
  800f53:	72 67                	jb     800fbc <__umoddi3+0x114>
  800f55:	74 75                	je     800fcc <__umoddi3+0x124>
  800f57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f5b:	29 e8                	sub    %ebp,%eax
  800f5d:	19 ce                	sbb    %ecx,%esi
  800f5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f63:	d3 e8                	shr    %cl,%eax
  800f65:	89 f2                	mov    %esi,%edx
  800f67:	89 f9                	mov    %edi,%ecx
  800f69:	d3 e2                	shl    %cl,%edx
  800f6b:	09 d0                	or     %edx,%eax
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f73:	d3 ea                	shr    %cl,%edx
  800f75:	83 c4 20             	add    $0x20,%esp
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	85 c9                	test   %ecx,%ecx
  800f7e:	75 0b                	jne    800f8b <__umoddi3+0xe3>
  800f80:	b8 01 00 00 00       	mov    $0x1,%eax
  800f85:	31 d2                	xor    %edx,%edx
  800f87:	f7 f1                	div    %ecx
  800f89:	89 c1                	mov    %eax,%ecx
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	f7 f1                	div    %ecx
  800f91:	89 f8                	mov    %edi,%eax
  800f93:	e9 3e ff ff ff       	jmp    800ed6 <__umoddi3+0x2e>
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	83 c4 20             	add    $0x20,%esp
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    
  800fa1:	8d 76 00             	lea    0x0(%esi),%esi
  800fa4:	39 f5                	cmp    %esi,%ebp
  800fa6:	72 04                	jb     800fac <__umoddi3+0x104>
  800fa8:	39 f9                	cmp    %edi,%ecx
  800faa:	77 06                	ja     800fb2 <__umoddi3+0x10a>
  800fac:	89 f2                	mov    %esi,%edx
  800fae:	29 cf                	sub    %ecx,%edi
  800fb0:	19 ea                	sbb    %ebp,%edx
  800fb2:	89 f8                	mov    %edi,%eax
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
  800fbc:	89 d1                	mov    %edx,%ecx
  800fbe:	89 c5                	mov    %eax,%ebp
  800fc0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fc4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fc8:	eb 8d                	jmp    800f57 <__umoddi3+0xaf>
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fd0:	72 ea                	jb     800fbc <__umoddi3+0x114>
  800fd2:	89 f1                	mov    %esi,%ecx
  800fd4:	eb 81                	jmp    800f57 <__umoddi3+0xaf>
