
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 88 0d 80 00 	movl   $0x800d88,(%esp)
  800041:	e8 1a 01 00 00       	call   800160 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 96 0d 80 00 	movl   $0x800d96,(%esp)
  800059:	e8 02 01 00 00       	call   800160 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80006e:	e8 4c 0a 00 00       	call   800abf <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80007b:	c1 e0 05             	shl    $0x5,%eax
  80007e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 f6                	test   %esi,%esi
  80008a:	7e 07                	jle    800093 <libmain+0x33>
		binaryname = argv[0];
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800097:	89 34 24             	mov    %esi,(%esp)
  80009a:	e8 95 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009f:	e8 08 00 00 00       	call   8000ac <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 af 09 00 00       	call   800a6d <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 14             	sub    $0x14,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d3:	40                   	inc    %eax
  8000d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 19                	jne    8000f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e4:	00 
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	89 04 24             	mov    %eax,(%esp)
  8000eb:	e8 40 09 00 00       	call   800a30 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f6:	ff 43 04             	incl   0x4(%ebx)
}
  8000f9:	83 c4 14             	add    $0x14,%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010f:	00 00 00 
	b.cnt = 0;
  800112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800123:	8b 45 08             	mov    0x8(%ebp),%eax
  800126:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	89 44 24 04          	mov    %eax,0x4(%esp)
  800134:	c7 04 24 c0 00 80 00 	movl   $0x8000c0,(%esp)
  80013b:	e8 82 01 00 00       	call   8002c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800140:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 d8 08 00 00       	call   800a30 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	89 04 24             	mov    %eax,(%esp)
  800173:	e8 87 ff ff ff       	call   8000ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800178:	c9                   	leave  
  800179:	c3                   	ret    
	...

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 3c             	sub    $0x3c,%esp
  800185:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800188:	89 d7                	mov    %edx,%edi
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800196:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800199:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019c:	85 c0                	test   %eax,%eax
  80019e:	75 08                	jne    8001a8 <printnum+0x2c>
  8001a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a6:	77 57                	ja     8001ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ac:	4b                   	dec    %ebx
  8001ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c7:	00 
  8001c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	e8 5e 09 00 00       	call   800b38 <__udivdi3>
  8001da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e9:	89 fa                	mov    %edi,%edx
  8001eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ee:	e8 89 ff ff ff       	call   80017c <printnum>
  8001f3:	eb 0f                	jmp    800204 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f9:	89 34 24             	mov    %esi,(%esp)
  8001fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	4b                   	dec    %ebx
  800200:	85 db                	test   %ebx,%ebx
  800202:	7f f1                	jg     8001f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800204:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800208:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80020c:	8b 45 10             	mov    0x10(%ebp),%eax
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021a:	00 
  80021b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	e8 2b 0a 00 00       	call   800c58 <__umoddi3>
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	0f be 80 b7 0d 80 00 	movsbl 0x800db7(%eax),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80023e:	83 c4 3c             	add    $0x3c,%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800249:	83 fa 01             	cmp    $0x1,%edx
  80024c:	7e 0e                	jle    80025c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 08             	lea    0x8(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	8b 52 04             	mov    0x4(%edx),%edx
  80025a:	eb 22                	jmp    80027e <getuint+0x38>
	else if (lflag)
  80025c:	85 d2                	test   %edx,%edx
  80025e:	74 10                	je     800270 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
  80026e:	eb 0e                	jmp    80027e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800286:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	3b 50 04             	cmp    0x4(%eax),%edx
  80028e:	73 08                	jae    800298 <sprintputch+0x18>
		*b->buf++ = ch;
  800290:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800293:	88 0a                	mov    %cl,(%edx)
  800295:	42                   	inc    %edx
  800296:	89 10                	mov    %edx,(%eax)
}
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 02 00 00 00       	call   8002c2 <vprintfmt>
	va_end(ap);
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 4c             	sub    $0x4c,%esp
  8002cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d1:	eb 12                	jmp    8002e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	0f 84 6b 03 00 00    	je     800646 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e5:	0f b6 06             	movzbl (%esi),%eax
  8002e8:	46                   	inc    %esi
  8002e9:	83 f8 25             	cmp    $0x25,%eax
  8002ec:	75 e5                	jne    8002d3 <vprintfmt+0x11>
  8002ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030a:	eb 26                	jmp    800332 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800313:	eb 1d                	jmp    800332 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800318:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80031c:	eb 14                	jmp    800332 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800321:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800328:	eb 08                	jmp    800332 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80032d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	0f b6 06             	movzbl (%esi),%eax
  800335:	8d 56 01             	lea    0x1(%esi),%edx
  800338:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033b:	8a 16                	mov    (%esi),%dl
  80033d:	83 ea 23             	sub    $0x23,%edx
  800340:	80 fa 55             	cmp    $0x55,%dl
  800343:	0f 87 e1 02 00 00    	ja     80062a <vprintfmt+0x368>
  800349:	0f b6 d2             	movzbl %dl,%edx
  80034c:	ff 24 95 44 0e 80 00 	jmp    *0x800e44(,%edx,4)
  800353:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800356:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80035e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800362:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800365:	8d 50 d0             	lea    -0x30(%eax),%edx
  800368:	83 fa 09             	cmp    $0x9,%edx
  80036b:	77 2a                	ja     800397 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb eb                	jmp    80035b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 50 04             	lea    0x4(%eax),%edx
  800376:	89 55 14             	mov    %edx,0x14(%ebp)
  800379:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037e:	eb 17                	jmp    800397 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800380:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800384:	78 98                	js     80031e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800389:	eb a7                	jmp    800332 <vprintfmt+0x70>
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800395:	eb 9b                	jmp    800332 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800397:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039b:	79 95                	jns    800332 <vprintfmt+0x70>
  80039d:	eb 8b                	jmp    80032a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a3:	eb 8d                	jmp    800332 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 50 04             	lea    0x4(%eax),%edx
  8003ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b2:	8b 00                	mov    (%eax),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bd:	e9 23 ff ff ff       	jmp    8002e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 50 04             	lea    0x4(%eax),%edx
  8003c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	79 02                	jns    8003d3 <vprintfmt+0x111>
  8003d1:	f7 d8                	neg    %eax
  8003d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d5:	83 f8 06             	cmp    $0x6,%eax
  8003d8:	7f 0b                	jg     8003e5 <vprintfmt+0x123>
  8003da:	8b 04 85 9c 0f 80 00 	mov    0x800f9c(,%eax,4),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	75 23                	jne    800408 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e9:	c7 44 24 08 cf 0d 80 	movl   $0x800dcf,0x8(%esp)
  8003f0:	00 
  8003f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 9a fe ff ff       	call   80029a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800403:	e9 dd fe ff ff       	jmp    8002e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800408:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040c:	c7 44 24 08 d8 0d 80 	movl   $0x800dd8,0x8(%esp)
  800413:	00 
  800414:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800418:	8b 55 08             	mov    0x8(%ebp),%edx
  80041b:	89 14 24             	mov    %edx,(%esp)
  80041e:	e8 77 fe ff ff       	call   80029a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800426:	e9 ba fe ff ff       	jmp    8002e5 <vprintfmt+0x23>
  80042b:	89 f9                	mov    %edi,%ecx
  80042d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800430:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 50 04             	lea    0x4(%eax),%edx
  800439:	89 55 14             	mov    %edx,0x14(%ebp)
  80043c:	8b 30                	mov    (%eax),%esi
  80043e:	85 f6                	test   %esi,%esi
  800440:	75 05                	jne    800447 <vprintfmt+0x185>
				p = "(null)";
  800442:	be c8 0d 80 00       	mov    $0x800dc8,%esi
			if (width > 0 && padc != '-')
  800447:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044b:	0f 8e 84 00 00 00    	jle    8004d5 <vprintfmt+0x213>
  800451:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800455:	74 7e                	je     8004d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80045b:	89 34 24             	mov    %esi,(%esp)
  80045e:	e8 8b 02 00 00       	call   8006ee <strnlen>
  800463:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800466:	29 c2                	sub    %eax,%edx
  800468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80046b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80046f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800472:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800475:	89 de                	mov    %ebx,%esi
  800477:	89 d3                	mov    %edx,%ebx
  800479:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	eb 0b                	jmp    800488 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80047d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800481:	89 3c 24             	mov    %edi,(%esp)
  800484:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	4b                   	dec    %ebx
  800488:	85 db                	test   %ebx,%ebx
  80048a:	7f f1                	jg     80047d <vprintfmt+0x1bb>
  80048c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80048f:	89 f3                	mov    %esi,%ebx
  800491:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	79 05                	jns    8004a0 <vprintfmt+0x1de>
  80049b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a3:	29 c2                	sub    %eax,%edx
  8004a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a8:	eb 2b                	jmp    8004d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ae:	74 18                	je     8004c8 <vprintfmt+0x206>
  8004b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b3:	83 fa 5e             	cmp    $0x5e,%edx
  8004b6:	76 10                	jbe    8004c8 <vprintfmt+0x206>
					putch('?', putdat);
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
  8004c6:	eb 0a                	jmp    8004d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d5:	0f be 06             	movsbl (%esi),%eax
  8004d8:	46                   	inc    %esi
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	74 21                	je     8004fe <vprintfmt+0x23c>
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	78 c9                	js     8004aa <vprintfmt+0x1e8>
  8004e1:	4f                   	dec    %edi
  8004e2:	79 c6                	jns    8004aa <vprintfmt+0x1e8>
  8004e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e7:	89 de                	mov    %ebx,%esi
  8004e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004ec:	eb 18                	jmp    800506 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fb:	4b                   	dec    %ebx
  8004fc:	eb 08                	jmp    800506 <vprintfmt+0x244>
  8004fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800501:	89 de                	mov    %ebx,%esi
  800503:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800506:	85 db                	test   %ebx,%ebx
  800508:	7f e4                	jg     8004ee <vprintfmt+0x22c>
  80050a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80050d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	e9 ce fd ff ff       	jmp    8002e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800517:	83 f9 01             	cmp    $0x1,%ecx
  80051a:	7e 10                	jle    80052c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 50 08             	lea    0x8(%eax),%edx
  800522:	89 55 14             	mov    %edx,0x14(%ebp)
  800525:	8b 30                	mov    (%eax),%esi
  800527:	8b 78 04             	mov    0x4(%eax),%edi
  80052a:	eb 26                	jmp    800552 <vprintfmt+0x290>
	else if (lflag)
  80052c:	85 c9                	test   %ecx,%ecx
  80052e:	74 12                	je     800542 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 30                	mov    (%eax),%esi
  80053b:	89 f7                	mov    %esi,%edi
  80053d:	c1 ff 1f             	sar    $0x1f,%edi
  800540:	eb 10                	jmp    800552 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 30                	mov    (%eax),%esi
  80054d:	89 f7                	mov    %esi,%edi
  80054f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800552:	85 ff                	test   %edi,%edi
  800554:	78 0a                	js     800560 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055b:	e9 8c 00 00 00       	jmp    8005ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80056e:	f7 de                	neg    %esi
  800570:	83 d7 00             	adc    $0x0,%edi
  800573:	f7 df                	neg    %edi
			}
			base = 10;
  800575:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057a:	eb 70                	jmp    8005ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057c:	89 ca                	mov    %ecx,%edx
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 c0 fc ff ff       	call   800246 <getuint>
  800586:	89 c6                	mov    %eax,%esi
  800588:	89 d7                	mov    %edx,%edi
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80058f:	eb 5b                	jmp    8005ec <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800591:	89 ca                	mov    %ecx,%edx
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	e8 ab fc ff ff       	call   800246 <getuint>
  80059b:	89 c6                	mov    %eax,%esi
  80059d:	89 d7                	mov    %edx,%edi
			base = 8;
  80059f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005a4:	eb 46                	jmp    8005ec <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cb:	8b 30                	mov    (%eax),%esi
  8005cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005d7:	eb 13                	jmp    8005ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d9:	89 ca                	mov    %ecx,%edx
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 63 fc ff ff       	call   800246 <getuint>
  8005e3:	89 c6                	mov    %eax,%esi
  8005e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ff:	89 34 24             	mov    %esi,(%esp)
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	89 da                	mov    %ebx,%edx
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	e8 6c fb ff ff       	call   80017c <printnum>
			break;
  800610:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800613:	e9 cd fc ff ff       	jmp    8002e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800625:	e9 bb fc ff ff       	jmp    8002e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800635:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800638:	eb 01                	jmp    80063b <vprintfmt+0x379>
  80063a:	4e                   	dec    %esi
  80063b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80063f:	75 f9                	jne    80063a <vprintfmt+0x378>
  800641:	e9 9f fc ff ff       	jmp    8002e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800646:	83 c4 4c             	add    $0x4c,%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	83 ec 28             	sub    $0x28,%esp
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800661:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066b:	85 c0                	test   %eax,%eax
  80066d:	74 30                	je     80069f <vsnprintf+0x51>
  80066f:	85 d2                	test   %edx,%edx
  800671:	7e 33                	jle    8006a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067a:	8b 45 10             	mov    0x10(%ebp),%eax
  80067d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800681:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	c7 04 24 80 02 80 00 	movl   $0x800280,(%esp)
  80068f:	e8 2e fc ff ff       	call   8002c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800694:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800697:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	eb 0c                	jmp    8006ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a4:	eb 05                	jmp    8006ab <vsnprintf+0x5d>
  8006a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    

008006ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8006bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	e8 7b ff ff ff       	call   80064e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    
  8006d5:	00 00                	add    %al,(%eax)
	...

008006d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	eb 01                	jmp    8006e6 <strlen+0xe>
		n++;
  8006e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ea:	75 f9                	jne    8006e5 <strlen+0xd>
		n++;
	return n;
}
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    

008006ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	eb 01                	jmp    8006ff <strnlen+0x11>
		n++;
  8006fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	39 d0                	cmp    %edx,%eax
  800701:	74 06                	je     800709 <strnlen+0x1b>
  800703:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800707:	75 f5                	jne    8006fe <strnlen+0x10>
		n++;
	return n;
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	8b 45 08             	mov    0x8(%ebp),%eax
  800712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80071d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800720:	42                   	inc    %edx
  800721:	84 c9                	test   %cl,%cl
  800723:	75 f5                	jne    80071a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800725:	5b                   	pop    %ebx
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800732:	89 1c 24             	mov    %ebx,(%esp)
  800735:	e8 9e ff ff ff       	call   8006d8 <strlen>
	strcpy(dst + len, src);
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800741:	01 d8                	add    %ebx,%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	e8 c0 ff ff ff       	call   80070b <strcpy>
	return dst;
}
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	83 c4 08             	add    $0x8,%esp
  800750:	5b                   	pop    %ebx
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800761:	b9 00 00 00 00       	mov    $0x0,%ecx
  800766:	eb 0c                	jmp    800774 <strncpy+0x21>
		*dst++ = *src;
  800768:	8a 1a                	mov    (%edx),%bl
  80076a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076d:	80 3a 01             	cmpb   $0x1,(%edx)
  800770:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800773:	41                   	inc    %ecx
  800774:	39 f1                	cmp    %esi,%ecx
  800776:	75 f0                	jne    800768 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	56                   	push   %esi
  800780:	53                   	push   %ebx
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078a:	85 d2                	test   %edx,%edx
  80078c:	75 0a                	jne    800798 <strlcpy+0x1c>
  80078e:	89 f0                	mov    %esi,%eax
  800790:	eb 1a                	jmp    8007ac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800792:	88 18                	mov    %bl,(%eax)
  800794:	40                   	inc    %eax
  800795:	41                   	inc    %ecx
  800796:	eb 02                	jmp    80079a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80079a:	4a                   	dec    %edx
  80079b:	74 0a                	je     8007a7 <strlcpy+0x2b>
  80079d:	8a 19                	mov    (%ecx),%bl
  80079f:	84 db                	test   %bl,%bl
  8007a1:	75 ef                	jne    800792 <strlcpy+0x16>
  8007a3:	89 c2                	mov    %eax,%edx
  8007a5:	eb 02                	jmp    8007a9 <strlcpy+0x2d>
  8007a7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007a9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007ac:	29 f0                	sub    %esi,%eax
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bb:	eb 02                	jmp    8007bf <strcmp+0xd>
		p++, q++;
  8007bd:	41                   	inc    %ecx
  8007be:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bf:	8a 01                	mov    (%ecx),%al
  8007c1:	84 c0                	test   %al,%al
  8007c3:	74 04                	je     8007c9 <strcmp+0x17>
  8007c5:	3a 02                	cmp    (%edx),%al
  8007c7:	74 f4                	je     8007bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c9:	0f b6 c0             	movzbl %al,%eax
  8007cc:	0f b6 12             	movzbl (%edx),%edx
  8007cf:	29 d0                	sub    %edx,%eax
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e0:	eb 03                	jmp    8007e5 <strncmp+0x12>
		n--, p++, q++;
  8007e2:	4a                   	dec    %edx
  8007e3:	40                   	inc    %eax
  8007e4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	74 14                	je     8007fd <strncmp+0x2a>
  8007e9:	8a 18                	mov    (%eax),%bl
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	74 04                	je     8007f3 <strncmp+0x20>
  8007ef:	3a 19                	cmp    (%ecx),%bl
  8007f1:	74 ef                	je     8007e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 00             	movzbl (%eax),%eax
  8007f6:	0f b6 11             	movzbl (%ecx),%edx
  8007f9:	29 d0                	sub    %edx,%eax
  8007fb:	eb 05                	jmp    800802 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800802:	5b                   	pop    %ebx
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80080e:	eb 05                	jmp    800815 <strchr+0x10>
		if (*s == c)
  800810:	38 ca                	cmp    %cl,%dl
  800812:	74 0c                	je     800820 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800814:	40                   	inc    %eax
  800815:	8a 10                	mov    (%eax),%dl
  800817:	84 d2                	test   %dl,%dl
  800819:	75 f5                	jne    800810 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082b:	eb 05                	jmp    800832 <strfind+0x10>
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 07                	je     800838 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800831:	40                   	inc    %eax
  800832:	8a 10                	mov    (%eax),%dl
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f5                	jne    80082d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	57                   	push   %edi
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 7d 08             	mov    0x8(%ebp),%edi
  800843:	8b 45 0c             	mov    0xc(%ebp),%eax
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 30                	je     80087d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 25                	jne    80087a <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 20                	jne    80087a <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085d:	89 d3                	mov    %edx,%ebx
  80085f:	c1 e3 08             	shl    $0x8,%ebx
  800862:	89 d6                	mov    %edx,%esi
  800864:	c1 e6 18             	shl    $0x18,%esi
  800867:	89 d0                	mov    %edx,%eax
  800869:	c1 e0 10             	shl    $0x10,%eax
  80086c:	09 f0                	or     %esi,%eax
  80086e:	09 d0                	or     %edx,%eax
  800870:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800872:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800875:	fc                   	cld    
  800876:	f3 ab                	rep stos %eax,%es:(%edi)
  800878:	eb 03                	jmp    80087d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087a:	fc                   	cld    
  80087b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80087d:	89 f8                	mov    %edi,%eax
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5f                   	pop    %edi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800892:	39 c6                	cmp    %eax,%esi
  800894:	73 34                	jae    8008ca <memmove+0x46>
  800896:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800899:	39 d0                	cmp    %edx,%eax
  80089b:	73 2d                	jae    8008ca <memmove+0x46>
		s += n;
		d += n;
  80089d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a0:	f6 c2 03             	test   $0x3,%dl
  8008a3:	75 1b                	jne    8008c0 <memmove+0x3c>
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 13                	jne    8008c0 <memmove+0x3c>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 0e                	jne    8008c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b2:	83 ef 04             	sub    $0x4,%edi
  8008b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008bb:	fd                   	std    
  8008bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008be:	eb 07                	jmp    8008c7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c0:	4f                   	dec    %edi
  8008c1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c4:	fd                   	std    
  8008c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c7:	fc                   	cld    
  8008c8:	eb 20                	jmp    8008ea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d0:	75 13                	jne    8008e5 <memmove+0x61>
  8008d2:	a8 03                	test   $0x3,%al
  8008d4:	75 0f                	jne    8008e5 <memmove+0x61>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 0a                	jne    8008e5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008db:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008de:	89 c7                	mov    %eax,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 05                	jmp    8008ea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	fc                   	cld    
  8008e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	89 04 24             	mov    %eax,(%esp)
  800908:	e8 77 ff ff ff       	call   800884 <memmove>
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 7d 08             	mov    0x8(%ebp),%edi
  800918:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	eb 16                	jmp    80093b <memcmp+0x2c>
		if (*s1 != *s2)
  800925:	8a 04 17             	mov    (%edi,%edx,1),%al
  800928:	42                   	inc    %edx
  800929:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80092d:	38 c8                	cmp    %cl,%al
  80092f:	74 0a                	je     80093b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800931:	0f b6 c0             	movzbl %al,%eax
  800934:	0f b6 c9             	movzbl %cl,%ecx
  800937:	29 c8                	sub    %ecx,%eax
  800939:	eb 09                	jmp    800944 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093b:	39 da                	cmp    %ebx,%edx
  80093d:	75 e6                	jne    800925 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800952:	89 c2                	mov    %eax,%edx
  800954:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800957:	eb 05                	jmp    80095e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800959:	38 08                	cmp    %cl,(%eax)
  80095b:	74 05                	je     800962 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095d:	40                   	inc    %eax
  80095e:	39 d0                	cmp    %edx,%eax
  800960:	72 f7                	jb     800959 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 55 08             	mov    0x8(%ebp),%edx
  80096d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800970:	eb 01                	jmp    800973 <strtol+0xf>
		s++;
  800972:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800973:	8a 02                	mov    (%edx),%al
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f9                	je     800972 <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f5                	je     800972 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 08                	jne    800989 <strtol+0x25>
		s++;
  800981:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800982:	bf 00 00 00 00       	mov    $0x0,%edi
  800987:	eb 13                	jmp    80099c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800989:	3c 2d                	cmp    $0x2d,%al
  80098b:	75 0a                	jne    800997 <strtol+0x33>
		s++, neg = 1;
  80098d:	8d 52 01             	lea    0x1(%edx),%edx
  800990:	bf 01 00 00 00       	mov    $0x1,%edi
  800995:	eb 05                	jmp    80099c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800997:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	85 db                	test   %ebx,%ebx
  80099e:	74 05                	je     8009a5 <strtol+0x41>
  8009a0:	83 fb 10             	cmp    $0x10,%ebx
  8009a3:	75 28                	jne    8009cd <strtol+0x69>
  8009a5:	8a 02                	mov    (%edx),%al
  8009a7:	3c 30                	cmp    $0x30,%al
  8009a9:	75 10                	jne    8009bb <strtol+0x57>
  8009ab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009af:	75 0a                	jne    8009bb <strtol+0x57>
		s += 2, base = 16;
  8009b1:	83 c2 02             	add    $0x2,%edx
  8009b4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b9:	eb 12                	jmp    8009cd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009bb:	85 db                	test   %ebx,%ebx
  8009bd:	75 0e                	jne    8009cd <strtol+0x69>
  8009bf:	3c 30                	cmp    $0x30,%al
  8009c1:	75 05                	jne    8009c8 <strtol+0x64>
		s++, base = 8;
  8009c3:	42                   	inc    %edx
  8009c4:	b3 08                	mov    $0x8,%bl
  8009c6:	eb 05                	jmp    8009cd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d4:	8a 0a                	mov    (%edx),%cl
  8009d6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009d9:	80 fb 09             	cmp    $0x9,%bl
  8009dc:	77 08                	ja     8009e6 <strtol+0x82>
			dig = *s - '0';
  8009de:	0f be c9             	movsbl %cl,%ecx
  8009e1:	83 e9 30             	sub    $0x30,%ecx
  8009e4:	eb 1e                	jmp    800a04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009e6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009ee:	0f be c9             	movsbl %cl,%ecx
  8009f1:	83 e9 57             	sub    $0x57,%ecx
  8009f4:	eb 0e                	jmp    800a04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009f6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 12                	ja     800a10 <strtol+0xac>
			dig = *s - 'A' + 10;
  8009fe:	0f be c9             	movsbl %cl,%ecx
  800a01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a04:	39 f1                	cmp    %esi,%ecx
  800a06:	7d 0c                	jge    800a14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a08:	42                   	inc    %edx
  800a09:	0f af c6             	imul   %esi,%eax
  800a0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a0e:	eb c4                	jmp    8009d4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a10:	89 c1                	mov    %eax,%ecx
  800a12:	eb 02                	jmp    800a16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1a:	74 05                	je     800a21 <strtol+0xbd>
		*endptr = (char *) s;
  800a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a21:	85 ff                	test   %edi,%edi
  800a23:	74 04                	je     800a29 <strtol+0xc5>
  800a25:	89 c8                	mov    %ecx,%eax
  800a27:	f7 d8                	neg    %eax
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    
	...

00800a30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	89 c6                	mov    %eax,%esi
  800a47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
  800a59:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5e:	89 d1                	mov    %edx,%ecx
  800a60:	89 d3                	mov    %edx,%ebx
  800a62:	89 d7                	mov    %edx,%edi
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
  800a83:	89 cb                	mov    %ecx,%ebx
  800a85:	89 cf                	mov    %ecx,%edi
  800a87:	89 ce                	mov    %ecx,%esi
  800a89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	7e 28                	jle    800ab7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a93:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a9a:	00 
  800a9b:	c7 44 24 08 b8 0f 80 	movl   $0x800fb8,0x8(%esp)
  800aa2:	00 
  800aa3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aaa:	00 
  800aab:	c7 04 24 d5 0f 80 00 	movl   $0x800fd5,(%esp)
  800ab2:	e8 29 00 00 00       	call   800ae0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab7:	83 c4 2c             	add    $0x2c,%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 02 00 00 00       	mov    $0x2,%eax
  800acf:	89 d1                	mov    %edx,%ecx
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	89 d7                	mov    %edx,%edi
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    
	...

00800ae0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ae8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aeb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800af1:	e8 c9 ff ff ff       	call   800abf <sys_getenvid>
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 54 24 10          	mov    %edx,0x10(%esp)
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0c:	c7 04 24 e4 0f 80 00 	movl   $0x800fe4,(%esp)
  800b13:	e8 48 f6 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b18:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1f:	89 04 24             	mov    %eax,(%esp)
  800b22:	e8 d8 f5 ff ff       	call   8000ff <vcprintf>
	cprintf("\n");
  800b27:	c7 04 24 94 0d 80 00 	movl   $0x800d94,(%esp)
  800b2e:	e8 2d f6 ff ff       	call   800160 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b33:	cc                   	int3   
  800b34:	eb fd                	jmp    800b33 <_panic+0x53>
	...

00800b38 <__udivdi3>:
  800b38:	55                   	push   %ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	83 ec 10             	sub    $0x10,%esp
  800b3e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b4a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b4e:	89 cd                	mov    %ecx,%ebp
  800b50:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b54:	85 c0                	test   %eax,%eax
  800b56:	75 2c                	jne    800b84 <__udivdi3+0x4c>
  800b58:	39 f9                	cmp    %edi,%ecx
  800b5a:	77 68                	ja     800bc4 <__udivdi3+0x8c>
  800b5c:	85 c9                	test   %ecx,%ecx
  800b5e:	75 0b                	jne    800b6b <__udivdi3+0x33>
  800b60:	b8 01 00 00 00       	mov    $0x1,%eax
  800b65:	31 d2                	xor    %edx,%edx
  800b67:	f7 f1                	div    %ecx
  800b69:	89 c1                	mov    %eax,%ecx
  800b6b:	31 d2                	xor    %edx,%edx
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	f7 f1                	div    %ecx
  800b71:	89 c7                	mov    %eax,%edi
  800b73:	89 f0                	mov    %esi,%eax
  800b75:	f7 f1                	div    %ecx
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	89 f0                	mov    %esi,%eax
  800b7b:	89 fa                	mov    %edi,%edx
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    
  800b84:	39 f8                	cmp    %edi,%eax
  800b86:	77 2c                	ja     800bb4 <__udivdi3+0x7c>
  800b88:	0f bd f0             	bsr    %eax,%esi
  800b8b:	83 f6 1f             	xor    $0x1f,%esi
  800b8e:	75 4c                	jne    800bdc <__udivdi3+0xa4>
  800b90:	39 f8                	cmp    %edi,%eax
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi
  800b97:	72 0a                	jb     800ba3 <__udivdi3+0x6b>
  800b99:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b9d:	0f 87 ad 00 00 00    	ja     800c50 <__udivdi3+0x118>
  800ba3:	be 01 00 00 00       	mov    $0x1,%esi
  800ba8:	89 f0                	mov    %esi,%eax
  800baa:	89 fa                	mov    %edi,%edx
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
  800bb3:	90                   	nop
  800bb4:	31 ff                	xor    %edi,%edi
  800bb6:	31 f6                	xor    %esi,%esi
  800bb8:	89 f0                	mov    %esi,%eax
  800bba:	89 fa                	mov    %edi,%edx
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    
  800bc3:	90                   	nop
  800bc4:	89 fa                	mov    %edi,%edx
  800bc6:	89 f0                	mov    %esi,%eax
  800bc8:	f7 f1                	div    %ecx
  800bca:	89 c6                	mov    %eax,%esi
  800bcc:	31 ff                	xor    %edi,%edi
  800bce:	89 f0                	mov    %esi,%eax
  800bd0:	89 fa                	mov    %edi,%edx
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	8d 76 00             	lea    0x0(%esi),%esi
  800bdc:	89 f1                	mov    %esi,%ecx
  800bde:	d3 e0                	shl    %cl,%eax
  800be0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be4:	b8 20 00 00 00       	mov    $0x20,%eax
  800be9:	29 f0                	sub    %esi,%eax
  800beb:	89 ea                	mov    %ebp,%edx
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ea                	shr    %cl,%edx
  800bf1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bf5:	09 ca                	or     %ecx,%edx
  800bf7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bfb:	89 f1                	mov    %esi,%ecx
  800bfd:	d3 e5                	shl    %cl,%ebp
  800bff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800c03:	89 fd                	mov    %edi,%ebp
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ed                	shr    %cl,%ebp
  800c09:	89 fa                	mov    %edi,%edx
  800c0b:	89 f1                	mov    %esi,%ecx
  800c0d:	d3 e2                	shl    %cl,%edx
  800c0f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c13:	88 c1                	mov    %al,%cl
  800c15:	d3 ef                	shr    %cl,%edi
  800c17:	09 d7                	or     %edx,%edi
  800c19:	89 f8                	mov    %edi,%eax
  800c1b:	89 ea                	mov    %ebp,%edx
  800c1d:	f7 74 24 08          	divl   0x8(%esp)
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 c7                	mov    %eax,%edi
  800c25:	f7 64 24 0c          	mull   0xc(%esp)
  800c29:	39 d1                	cmp    %edx,%ecx
  800c2b:	72 17                	jb     800c44 <__udivdi3+0x10c>
  800c2d:	74 09                	je     800c38 <__udivdi3+0x100>
  800c2f:	89 fe                	mov    %edi,%esi
  800c31:	31 ff                	xor    %edi,%edi
  800c33:	e9 41 ff ff ff       	jmp    800b79 <__udivdi3+0x41>
  800c38:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c3c:	89 f1                	mov    %esi,%ecx
  800c3e:	d3 e2                	shl    %cl,%edx
  800c40:	39 c2                	cmp    %eax,%edx
  800c42:	73 eb                	jae    800c2f <__udivdi3+0xf7>
  800c44:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c47:	31 ff                	xor    %edi,%edi
  800c49:	e9 2b ff ff ff       	jmp    800b79 <__udivdi3+0x41>
  800c4e:	66 90                	xchg   %ax,%ax
  800c50:	31 f6                	xor    %esi,%esi
  800c52:	e9 22 ff ff ff       	jmp    800b79 <__udivdi3+0x41>
	...

00800c58 <__umoddi3>:
  800c58:	55                   	push   %ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	83 ec 20             	sub    $0x20,%esp
  800c5e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c62:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c66:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c6a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c72:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	89 f2                	mov    %esi,%edx
  800c7a:	85 ed                	test   %ebp,%ebp
  800c7c:	75 16                	jne    800c94 <__umoddi3+0x3c>
  800c7e:	39 f1                	cmp    %esi,%ecx
  800c80:	0f 86 a6 00 00 00    	jbe    800d2c <__umoddi3+0xd4>
  800c86:	f7 f1                	div    %ecx
  800c88:	89 d0                	mov    %edx,%eax
  800c8a:	31 d2                	xor    %edx,%edx
  800c8c:	83 c4 20             	add    $0x20,%esp
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	90                   	nop
  800c94:	39 f5                	cmp    %esi,%ebp
  800c96:	0f 87 ac 00 00 00    	ja     800d48 <__umoddi3+0xf0>
  800c9c:	0f bd c5             	bsr    %ebp,%eax
  800c9f:	83 f0 1f             	xor    $0x1f,%eax
  800ca2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca6:	0f 84 a8 00 00 00    	je     800d54 <__umoddi3+0xfc>
  800cac:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cb0:	d3 e5                	shl    %cl,%ebp
  800cb2:	bf 20 00 00 00       	mov    $0x20,%edi
  800cb7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800cbb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cbf:	89 f9                	mov    %edi,%ecx
  800cc1:	d3 e8                	shr    %cl,%eax
  800cc3:	09 e8                	or     %ebp,%eax
  800cc5:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cc9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ccd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cd1:	d3 e0                	shl    %cl,%eax
  800cd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd7:	89 f2                	mov    %esi,%edx
  800cd9:	d3 e2                	shl    %cl,%edx
  800cdb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cdf:	d3 e0                	shl    %cl,%eax
  800ce1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800ce5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ce9:	89 f9                	mov    %edi,%ecx
  800ceb:	d3 e8                	shr    %cl,%eax
  800ced:	09 d0                	or     %edx,%eax
  800cef:	d3 ee                	shr    %cl,%esi
  800cf1:	89 f2                	mov    %esi,%edx
  800cf3:	f7 74 24 18          	divl   0x18(%esp)
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	f7 64 24 0c          	mull   0xc(%esp)
  800cfd:	89 c5                	mov    %eax,%ebp
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	39 d6                	cmp    %edx,%esi
  800d03:	72 67                	jb     800d6c <__umoddi3+0x114>
  800d05:	74 75                	je     800d7c <__umoddi3+0x124>
  800d07:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d0b:	29 e8                	sub    %ebp,%eax
  800d0d:	19 ce                	sbb    %ecx,%esi
  800d0f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 f2                	mov    %esi,%edx
  800d17:	89 f9                	mov    %edi,%ecx
  800d19:	d3 e2                	shl    %cl,%edx
  800d1b:	09 d0                	or     %edx,%eax
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d23:	d3 ea                	shr    %cl,%edx
  800d25:	83 c4 20             	add    $0x20,%esp
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
  800d2c:	85 c9                	test   %ecx,%ecx
  800d2e:	75 0b                	jne    800d3b <__umoddi3+0xe3>
  800d30:	b8 01 00 00 00       	mov    $0x1,%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f1                	div    %ecx
  800d39:	89 c1                	mov    %eax,%ecx
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	31 d2                	xor    %edx,%edx
  800d3f:	f7 f1                	div    %ecx
  800d41:	89 f8                	mov    %edi,%eax
  800d43:	e9 3e ff ff ff       	jmp    800c86 <__umoddi3+0x2e>
  800d48:	89 f2                	mov    %esi,%edx
  800d4a:	83 c4 20             	add    $0x20,%esp
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
  800d51:	8d 76 00             	lea    0x0(%esi),%esi
  800d54:	39 f5                	cmp    %esi,%ebp
  800d56:	72 04                	jb     800d5c <__umoddi3+0x104>
  800d58:	39 f9                	cmp    %edi,%ecx
  800d5a:	77 06                	ja     800d62 <__umoddi3+0x10a>
  800d5c:	89 f2                	mov    %esi,%edx
  800d5e:	29 cf                	sub    %ecx,%edi
  800d60:	19 ea                	sbb    %ebp,%edx
  800d62:	89 f8                	mov    %edi,%eax
  800d64:	83 c4 20             	add    $0x20,%esp
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    
  800d6b:	90                   	nop
  800d6c:	89 d1                	mov    %edx,%ecx
  800d6e:	89 c5                	mov    %eax,%ebp
  800d70:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d74:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d78:	eb 8d                	jmp    800d07 <__umoddi3+0xaf>
  800d7a:	66 90                	xchg   %ax,%ax
  800d7c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d80:	72 ea                	jb     800d6c <__umoddi3+0x114>
  800d82:	89 f1                	mov    %esi,%ecx
  800d84:	eb 81                	jmp    800d07 <__umoddi3+0xaf>
