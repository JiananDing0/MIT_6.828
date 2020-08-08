
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
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 00 10 80 00 	movl   $0x801000,(%esp)
  80005c:	e8 0b 01 00 00       	call   80016c <cprintf>
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
  800072:	e8 74 0a 00 00       	call   800aeb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 07                	jle    80009d <libmain+0x39>
		binaryname = argv[0];
  800096:	8b 03                	mov    (%ebx),%eax
  800098:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	89 34 24             	mov    %esi,(%esp)
  8000a4:	e8 8b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a9:	e8 0a 00 00 00       	call   8000b8 <exit>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    
  8000b5:	00 00                	add    %al,(%eax)
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 cf 09 00 00       	call   800a99 <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 14             	sub    $0x14,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	40                   	inc    %eax
  8000e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e7:	75 19                	jne    800102 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f0:	00 
  8000f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f4:	89 04 24             	mov    %eax,(%esp)
  8000f7:	e8 60 09 00 00       	call   800a5c <sys_cputs>
		b->idx = 0;
  8000fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800102:	ff 43 04             	incl   0x4(%ebx)
}
  800105:	83 c4 14             	add    $0x14,%esp
  800108:	5b                   	pop    %ebx
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800114:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011b:	00 00 00 
	b.cnt = 0;
  80011e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800125:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012f:	8b 45 08             	mov    0x8(%ebp),%eax
  800132:	89 44 24 08          	mov    %eax,0x8(%esp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 cc 00 80 00 	movl   $0x8000cc,(%esp)
  800147:	e8 82 01 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800152:	89 44 24 04          	mov    %eax,0x4(%esp)
  800156:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 f8 08 00 00       	call   800a5c <sys_cputs>

	return b.cnt;
}
  800164:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800172:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	e8 87 ff ff ff       	call   80010b <vcprintf>
	va_end(ap);

	return cnt;
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    
	...

00800188 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 3c             	sub    $0x3c,%esp
  800191:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800194:	89 d7                	mov    %edx,%edi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	75 08                	jne    8001b4 <printnum+0x2c>
  8001ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b2:	77 57                	ja     80020b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b8:	4b                   	dec    %ebx
  8001b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d3:	00 
  8001d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	e8 b2 0b 00 00       	call   800d98 <__udivdi3>
  8001e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	89 fa                	mov    %edi,%edx
  8001f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fa:	e8 89 ff ff ff       	call   800188 <printnum>
  8001ff:	eb 0f                	jmp    800210 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800205:	89 34 24             	mov    %esi,(%esp)
  800208:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020b:	4b                   	dec    %ebx
  80020c:	85 db                	test   %ebx,%ebx
  80020e:	7f f1                	jg     800201 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800210:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800214:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800218:	8b 45 10             	mov    0x10(%ebp),%eax
  80021b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800226:	00 
  800227:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	e8 7f 0c 00 00       	call   800eb8 <__umoddi3>
  800239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023d:	0f be 80 18 10 80 00 	movsbl 0x801018(%eax),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024a:	83 c4 3c             	add    $0x3c,%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800255:	83 fa 01             	cmp    $0x1,%edx
  800258:	7e 0e                	jle    800268 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	8b 52 04             	mov    0x4(%edx),%edx
  800266:	eb 22                	jmp    80028a <getuint+0x38>
	else if (lflag)
  800268:	85 d2                	test   %edx,%edx
  80026a:	74 10                	je     80027c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	eb 0e                	jmp    80028a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800292:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800295:	8b 10                	mov    (%eax),%edx
  800297:	3b 50 04             	cmp    0x4(%eax),%edx
  80029a:	73 08                	jae    8002a4 <sprintputch+0x18>
		*b->buf++ = ch;
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	88 0a                	mov    %cl,(%edx)
  8002a1:	42                   	inc    %edx
  8002a2:	89 10                	mov    %edx,(%eax)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c4:	89 04 24             	mov    %eax,(%esp)
  8002c7:	e8 02 00 00 00       	call   8002ce <vprintfmt>
	va_end(ap);
}
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 4c             	sub    $0x4c,%esp
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 75 10             	mov    0x10(%ebp),%esi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 8b 03 00 00    	je     800672 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8002e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	0f b6 06             	movzbl (%esi),%eax
  8002f4:	46                   	inc    %esi
  8002f5:	83 f8 25             	cmp    $0x25,%eax
  8002f8:	75 e5                	jne    8002df <vprintfmt+0x11>
  8002fa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800305:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800311:	b9 00 00 00 00       	mov    $0x0,%ecx
  800316:	eb 26                	jmp    80033e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80031f:	eb 1d                	jmp    80033e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800324:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800328:	eb 14                	jmp    80033e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80032d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800334:	eb 08                	jmp    80033e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800336:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800339:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	0f b6 06             	movzbl (%esi),%eax
  800341:	8d 56 01             	lea    0x1(%esi),%edx
  800344:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800347:	8a 16                	mov    (%esi),%dl
  800349:	83 ea 23             	sub    $0x23,%edx
  80034c:	80 fa 55             	cmp    $0x55,%dl
  80034f:	0f 87 01 03 00 00    	ja     800656 <vprintfmt+0x388>
  800355:	0f b6 d2             	movzbl %dl,%edx
  800358:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  80035f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800362:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800367:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80036a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80036e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800371:	8d 50 d0             	lea    -0x30(%eax),%edx
  800374:	83 fa 09             	cmp    $0x9,%edx
  800377:	77 2a                	ja     8003a3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800379:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037a:	eb eb                	jmp    800367 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 50 04             	lea    0x4(%eax),%edx
  800382:	89 55 14             	mov    %edx,0x14(%ebp)
  800385:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 17                	jmp    8003a3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80038c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800390:	78 98                	js     80032a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800395:	eb a7                	jmp    80033e <vprintfmt+0x70>
  800397:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a1:	eb 9b                	jmp    80033e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a7:	79 95                	jns    80033e <vprintfmt+0x70>
  8003a9:	eb 8b                	jmp    800336 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003af:	eb 8d                	jmp    80033e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 50 04             	lea    0x4(%eax),%edx
  8003b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c9:	e9 23 ff ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	79 02                	jns    8003df <vprintfmt+0x111>
  8003dd:	f7 d8                	neg    %eax
  8003df:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e1:	83 f8 08             	cmp    $0x8,%eax
  8003e4:	7f 0b                	jg     8003f1 <vprintfmt+0x123>
  8003e6:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	75 23                	jne    800414 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f5:	c7 44 24 08 30 10 80 	movl   $0x801030,0x8(%esp)
  8003fc:	00 
  8003fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	e8 9a fe ff ff       	call   8002a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040f:	e9 dd fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800414:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800418:	c7 44 24 08 39 10 80 	movl   $0x801039,0x8(%esp)
  80041f:	00 
  800420:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	89 14 24             	mov    %edx,(%esp)
  80042a:	e8 77 fe ff ff       	call   8002a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800432:	e9 ba fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
  800437:	89 f9                	mov    %edi,%ecx
  800439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 30                	mov    (%eax),%esi
  80044a:	85 f6                	test   %esi,%esi
  80044c:	75 05                	jne    800453 <vprintfmt+0x185>
				p = "(null)";
  80044e:	be 29 10 80 00       	mov    $0x801029,%esi
			if (width > 0 && padc != '-')
  800453:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800457:	0f 8e 84 00 00 00    	jle    8004e1 <vprintfmt+0x213>
  80045d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800461:	74 7e                	je     8004e1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800467:	89 34 24             	mov    %esi,(%esp)
  80046a:	e8 ab 02 00 00       	call   80071a <strnlen>
  80046f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800472:	29 c2                	sub    %eax,%edx
  800474:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800477:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80047b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80047e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800481:	89 de                	mov    %ebx,%esi
  800483:	89 d3                	mov    %edx,%ebx
  800485:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	eb 0b                	jmp    800494 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800489:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048d:	89 3c 24             	mov    %edi,(%esp)
  800490:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	4b                   	dec    %ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	7f f1                	jg     800489 <vprintfmt+0x1bb>
  800498:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049b:	89 f3                	mov    %esi,%ebx
  80049d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	79 05                	jns    8004ac <vprintfmt+0x1de>
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004af:	29 c2                	sub    %eax,%edx
  8004b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b4:	eb 2b                	jmp    8004e1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ba:	74 18                	je     8004d4 <vprintfmt+0x206>
  8004bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bf:	83 fa 5e             	cmp    $0x5e,%edx
  8004c2:	76 10                	jbe    8004d4 <vprintfmt+0x206>
					putch('?', putdat);
  8004c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	eb 0a                	jmp    8004de <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e1:	0f be 06             	movsbl (%esi),%eax
  8004e4:	46                   	inc    %esi
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	74 21                	je     80050a <vprintfmt+0x23c>
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	78 c9                	js     8004b6 <vprintfmt+0x1e8>
  8004ed:	4f                   	dec    %edi
  8004ee:	79 c6                	jns    8004b6 <vprintfmt+0x1e8>
  8004f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f3:	89 de                	mov    %ebx,%esi
  8004f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f8:	eb 18                	jmp    800512 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800505:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800507:	4b                   	dec    %ebx
  800508:	eb 08                	jmp    800512 <vprintfmt+0x244>
  80050a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050d:	89 de                	mov    %ebx,%esi
  80050f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800512:	85 db                	test   %ebx,%ebx
  800514:	7f e4                	jg     8004fa <vprintfmt+0x22c>
  800516:	89 7d 08             	mov    %edi,0x8(%ebp)
  800519:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	e9 ce fd ff ff       	jmp    8002f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800523:	83 f9 01             	cmp    $0x1,%ecx
  800526:	7e 10                	jle    800538 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 08             	lea    0x8(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 30                	mov    (%eax),%esi
  800533:	8b 78 04             	mov    0x4(%eax),%edi
  800536:	eb 26                	jmp    80055e <vprintfmt+0x290>
	else if (lflag)
  800538:	85 c9                	test   %ecx,%ecx
  80053a:	74 12                	je     80054e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 30                	mov    (%eax),%esi
  800547:	89 f7                	mov    %esi,%edi
  800549:	c1 ff 1f             	sar    $0x1f,%edi
  80054c:	eb 10                	jmp    80055e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 30                	mov    (%eax),%esi
  800559:	89 f7                	mov    %esi,%edi
  80055b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055e:	85 ff                	test   %edi,%edi
  800560:	78 0a                	js     80056c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	e9 ac 00 00 00       	jmp    800618 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057a:	f7 de                	neg    %esi
  80057c:	83 d7 00             	adc    $0x0,%edi
  80057f:	f7 df                	neg    %edi
			}
			base = 10;
  800581:	b8 0a 00 00 00       	mov    $0xa,%eax
  800586:	e9 8d 00 00 00       	jmp    800618 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058b:	89 ca                	mov    %ecx,%edx
  80058d:	8d 45 14             	lea    0x14(%ebp),%eax
  800590:	e8 bd fc ff ff       	call   800252 <getuint>
  800595:	89 c6                	mov    %eax,%esi
  800597:	89 d7                	mov    %edx,%edi
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059e:	eb 78                	jmp    800618 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ab:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005cd:	e9 1f fd ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f7:	8b 30                	mov    (%eax),%esi
  8005f9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800603:	eb 13                	jmp    800618 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800605:	89 ca                	mov    %ecx,%edx
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 43 fc ff ff       	call   800252 <getuint>
  80060f:	89 c6                	mov    %eax,%esi
  800611:	89 d7                	mov    %edx,%edi
			base = 16;
  800613:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800618:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80061c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800620:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800623:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800627:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062b:	89 34 24             	mov    %esi,(%esp)
  80062e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800632:	89 da                	mov    %ebx,%edx
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	e8 4c fb ff ff       	call   800188 <printnum>
			break;
  80063c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80063f:	e9 ad fc ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800651:	e9 9b fc ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800656:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800661:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800664:	eb 01                	jmp    800667 <vprintfmt+0x399>
  800666:	4e                   	dec    %esi
  800667:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066b:	75 f9                	jne    800666 <vprintfmt+0x398>
  80066d:	e9 7f fc ff ff       	jmp    8002f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800672:	83 c4 4c             	add    $0x4c,%esp
  800675:	5b                   	pop    %ebx
  800676:	5e                   	pop    %esi
  800677:	5f                   	pop    %edi
  800678:	5d                   	pop    %ebp
  800679:	c3                   	ret    

0080067a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 28             	sub    $0x28,%esp
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800686:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800689:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800697:	85 c0                	test   %eax,%eax
  800699:	74 30                	je     8006cb <vsnprintf+0x51>
  80069b:	85 d2                	test   %edx,%edx
  80069d:	7e 33                	jle    8006d2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b4:	c7 04 24 8c 02 80 00 	movl   $0x80028c,(%esp)
  8006bb:	e8 0e fc ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c9:	eb 0c                	jmp    8006d7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d0:	eb 05                	jmp    8006d7 <vsnprintf+0x5d>
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	89 04 24             	mov    %eax,(%esp)
  8006fa:	e8 7b ff ff ff       	call   80067a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    
  800701:	00 00                	add    %al,(%eax)
	...

00800704 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	eb 01                	jmp    800712 <strlen+0xe>
		n++;
  800711:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800716:	75 f9                	jne    800711 <strlen+0xd>
		n++;
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	eb 01                	jmp    80072b <strnlen+0x11>
		n++;
  80072a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 d0                	cmp    %edx,%eax
  80072d:	74 06                	je     800735 <strnlen+0x1b>
  80072f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800733:	75 f5                	jne    80072a <strnlen+0x10>
		n++;
	return n;
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	53                   	push   %ebx
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800749:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80074c:	42                   	inc    %edx
  80074d:	84 c9                	test   %cl,%cl
  80074f:	75 f5                	jne    800746 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800751:	5b                   	pop    %ebx
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075e:	89 1c 24             	mov    %ebx,(%esp)
  800761:	e8 9e ff ff ff       	call   800704 <strlen>
	strcpy(dst + len, src);
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
  800769:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076d:	01 d8                	add    %ebx,%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 c0 ff ff ff       	call   800737 <strcpy>
	return dst;
}
  800777:	89 d8                	mov    %ebx,%eax
  800779:	83 c4 08             	add    $0x8,%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800792:	eb 0c                	jmp    8007a0 <strncpy+0x21>
		*dst++ = *src;
  800794:	8a 1a                	mov    (%edx),%bl
  800796:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800799:	80 3a 01             	cmpb   $0x1,(%edx)
  80079c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079f:	41                   	inc    %ecx
  8007a0:	39 f1                	cmp    %esi,%ecx
  8007a2:	75 f0                	jne    800794 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	75 0a                	jne    8007c4 <strlcpy+0x1c>
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	eb 1a                	jmp    8007d8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007be:	88 18                	mov    %bl,(%eax)
  8007c0:	40                   	inc    %eax
  8007c1:	41                   	inc    %ecx
  8007c2:	eb 02                	jmp    8007c6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007c6:	4a                   	dec    %edx
  8007c7:	74 0a                	je     8007d3 <strlcpy+0x2b>
  8007c9:	8a 19                	mov    (%ecx),%bl
  8007cb:	84 db                	test   %bl,%bl
  8007cd:	75 ef                	jne    8007be <strlcpy+0x16>
  8007cf:	89 c2                	mov    %eax,%edx
  8007d1:	eb 02                	jmp    8007d5 <strlcpy+0x2d>
  8007d3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007d5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007d8:	29 f0                	sub    %esi,%eax
}
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e7:	eb 02                	jmp    8007eb <strcmp+0xd>
		p++, q++;
  8007e9:	41                   	inc    %ecx
  8007ea:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007eb:	8a 01                	mov    (%ecx),%al
  8007ed:	84 c0                	test   %al,%al
  8007ef:	74 04                	je     8007f5 <strcmp+0x17>
  8007f1:	3a 02                	cmp    (%edx),%al
  8007f3:	74 f4                	je     8007e9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f5:	0f b6 c0             	movzbl %al,%eax
  8007f8:	0f b6 12             	movzbl (%edx),%edx
  8007fb:	29 d0                	sub    %edx,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800809:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80080c:	eb 03                	jmp    800811 <strncmp+0x12>
		n--, p++, q++;
  80080e:	4a                   	dec    %edx
  80080f:	40                   	inc    %eax
  800810:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800811:	85 d2                	test   %edx,%edx
  800813:	74 14                	je     800829 <strncmp+0x2a>
  800815:	8a 18                	mov    (%eax),%bl
  800817:	84 db                	test   %bl,%bl
  800819:	74 04                	je     80081f <strncmp+0x20>
  80081b:	3a 19                	cmp    (%ecx),%bl
  80081d:	74 ef                	je     80080e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 00             	movzbl (%eax),%eax
  800822:	0f b6 11             	movzbl (%ecx),%edx
  800825:	29 d0                	sub    %edx,%eax
  800827:	eb 05                	jmp    80082e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083a:	eb 05                	jmp    800841 <strchr+0x10>
		if (*s == c)
  80083c:	38 ca                	cmp    %cl,%dl
  80083e:	74 0c                	je     80084c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800840:	40                   	inc    %eax
  800841:	8a 10                	mov    (%eax),%dl
  800843:	84 d2                	test   %dl,%dl
  800845:	75 f5                	jne    80083c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800857:	eb 05                	jmp    80085e <strfind+0x10>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 07                	je     800864 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80085d:	40                   	inc    %eax
  80085e:	8a 10                	mov    (%eax),%dl
  800860:	84 d2                	test   %dl,%dl
  800862:	75 f5                	jne    800859 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	57                   	push   %edi
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 30                	je     8008a9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800879:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087f:	75 25                	jne    8008a6 <memset+0x40>
  800881:	f6 c1 03             	test   $0x3,%cl
  800884:	75 20                	jne    8008a6 <memset+0x40>
		c &= 0xFF;
  800886:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800889:	89 d3                	mov    %edx,%ebx
  80088b:	c1 e3 08             	shl    $0x8,%ebx
  80088e:	89 d6                	mov    %edx,%esi
  800890:	c1 e6 18             	shl    $0x18,%esi
  800893:	89 d0                	mov    %edx,%eax
  800895:	c1 e0 10             	shl    $0x10,%eax
  800898:	09 f0                	or     %esi,%eax
  80089a:	09 d0                	or     %edx,%eax
  80089c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80089e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a1:	fc                   	cld    
  8008a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a4:	eb 03                	jmp    8008a9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a6:	fc                   	cld    
  8008a7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a9:	89 f8                	mov    %edi,%eax
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5f                   	pop    %edi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	57                   	push   %edi
  8008b4:	56                   	push   %esi
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008be:	39 c6                	cmp    %eax,%esi
  8008c0:	73 34                	jae    8008f6 <memmove+0x46>
  8008c2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c5:	39 d0                	cmp    %edx,%eax
  8008c7:	73 2d                	jae    8008f6 <memmove+0x46>
		s += n;
		d += n;
  8008c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cc:	f6 c2 03             	test   $0x3,%dl
  8008cf:	75 1b                	jne    8008ec <memmove+0x3c>
  8008d1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d7:	75 13                	jne    8008ec <memmove+0x3c>
  8008d9:	f6 c1 03             	test   $0x3,%cl
  8008dc:	75 0e                	jne    8008ec <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008de:	83 ef 04             	sub    $0x4,%edi
  8008e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008e7:	fd                   	std    
  8008e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ea:	eb 07                	jmp    8008f3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ec:	4f                   	dec    %edi
  8008ed:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f0:	fd                   	std    
  8008f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f3:	fc                   	cld    
  8008f4:	eb 20                	jmp    800916 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fc:	75 13                	jne    800911 <memmove+0x61>
  8008fe:	a8 03                	test   $0x3,%al
  800900:	75 0f                	jne    800911 <memmove+0x61>
  800902:	f6 c1 03             	test   $0x3,%cl
  800905:	75 0a                	jne    800911 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800907:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80090a:	89 c7                	mov    %eax,%edi
  80090c:	fc                   	cld    
  80090d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090f:	eb 05                	jmp    800916 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800911:	89 c7                	mov    %eax,%edi
  800913:	fc                   	cld    
  800914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800920:	8b 45 10             	mov    0x10(%ebp),%eax
  800923:	89 44 24 08          	mov    %eax,0x8(%esp)
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	89 04 24             	mov    %eax,(%esp)
  800934:	e8 77 ff ff ff       	call   8008b0 <memmove>
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 7d 08             	mov    0x8(%ebp),%edi
  800944:	8b 75 0c             	mov    0xc(%ebp),%esi
  800947:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	ba 00 00 00 00       	mov    $0x0,%edx
  80094f:	eb 16                	jmp    800967 <memcmp+0x2c>
		if (*s1 != *s2)
  800951:	8a 04 17             	mov    (%edi,%edx,1),%al
  800954:	42                   	inc    %edx
  800955:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800959:	38 c8                	cmp    %cl,%al
  80095b:	74 0a                	je     800967 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80095d:	0f b6 c0             	movzbl %al,%eax
  800960:	0f b6 c9             	movzbl %cl,%ecx
  800963:	29 c8                	sub    %ecx,%eax
  800965:	eb 09                	jmp    800970 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800967:	39 da                	cmp    %ebx,%edx
  800969:	75 e6                	jne    800951 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097e:	89 c2                	mov    %eax,%edx
  800980:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800983:	eb 05                	jmp    80098a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	38 08                	cmp    %cl,(%eax)
  800987:	74 05                	je     80098e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800989:	40                   	inc    %eax
  80098a:	39 d0                	cmp    %edx,%eax
  80098c:	72 f7                	jb     800985 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 55 08             	mov    0x8(%ebp),%edx
  800999:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099c:	eb 01                	jmp    80099f <strtol+0xf>
		s++;
  80099e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099f:	8a 02                	mov    (%edx),%al
  8009a1:	3c 20                	cmp    $0x20,%al
  8009a3:	74 f9                	je     80099e <strtol+0xe>
  8009a5:	3c 09                	cmp    $0x9,%al
  8009a7:	74 f5                	je     80099e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a9:	3c 2b                	cmp    $0x2b,%al
  8009ab:	75 08                	jne    8009b5 <strtol+0x25>
		s++;
  8009ad:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b3:	eb 13                	jmp    8009c8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b5:	3c 2d                	cmp    $0x2d,%al
  8009b7:	75 0a                	jne    8009c3 <strtol+0x33>
		s++, neg = 1;
  8009b9:	8d 52 01             	lea    0x1(%edx),%edx
  8009bc:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c1:	eb 05                	jmp    8009c8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	74 05                	je     8009d1 <strtol+0x41>
  8009cc:	83 fb 10             	cmp    $0x10,%ebx
  8009cf:	75 28                	jne    8009f9 <strtol+0x69>
  8009d1:	8a 02                	mov    (%edx),%al
  8009d3:	3c 30                	cmp    $0x30,%al
  8009d5:	75 10                	jne    8009e7 <strtol+0x57>
  8009d7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009db:	75 0a                	jne    8009e7 <strtol+0x57>
		s += 2, base = 16;
  8009dd:	83 c2 02             	add    $0x2,%edx
  8009e0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e5:	eb 12                	jmp    8009f9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009e7:	85 db                	test   %ebx,%ebx
  8009e9:	75 0e                	jne    8009f9 <strtol+0x69>
  8009eb:	3c 30                	cmp    $0x30,%al
  8009ed:	75 05                	jne    8009f4 <strtol+0x64>
		s++, base = 8;
  8009ef:	42                   	inc    %edx
  8009f0:	b3 08                	mov    $0x8,%bl
  8009f2:	eb 05                	jmp    8009f9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009f4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a00:	8a 0a                	mov    (%edx),%cl
  800a02:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a05:	80 fb 09             	cmp    $0x9,%bl
  800a08:	77 08                	ja     800a12 <strtol+0x82>
			dig = *s - '0';
  800a0a:	0f be c9             	movsbl %cl,%ecx
  800a0d:	83 e9 30             	sub    $0x30,%ecx
  800a10:	eb 1e                	jmp    800a30 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a12:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a1a:	0f be c9             	movsbl %cl,%ecx
  800a1d:	83 e9 57             	sub    $0x57,%ecx
  800a20:	eb 0e                	jmp    800a30 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a22:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 12                	ja     800a3c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a2a:	0f be c9             	movsbl %cl,%ecx
  800a2d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a30:	39 f1                	cmp    %esi,%ecx
  800a32:	7d 0c                	jge    800a40 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a34:	42                   	inc    %edx
  800a35:	0f af c6             	imul   %esi,%eax
  800a38:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a3a:	eb c4                	jmp    800a00 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	89 c1                	mov    %eax,%ecx
  800a3e:	eb 02                	jmp    800a42 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a40:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a46:	74 05                	je     800a4d <strtol+0xbd>
		*endptr = (char *) s;
  800a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a4d:	85 ff                	test   %edi,%edi
  800a4f:	74 04                	je     800a55 <strtol+0xc5>
  800a51:	89 c8                	mov    %ecx,%eax
  800a53:	f7 d8                	neg    %eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    
	...

00800a5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	89 c3                	mov    %eax,%ebx
  800a6f:	89 c7                	mov    %eax,%edi
  800a71:	89 c6                	mov    %eax,%esi
  800a73:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a80:	ba 00 00 00 00       	mov    $0x0,%edx
  800a85:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8a:	89 d1                	mov    %edx,%ecx
  800a8c:	89 d3                	mov    %edx,%ebx
  800a8e:	89 d7                	mov    %edx,%edi
  800a90:	89 d6                	mov    %edx,%esi
  800a92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	89 cb                	mov    %ecx,%ebx
  800ab1:	89 cf                	mov    %ecx,%edi
  800ab3:	89 ce                	mov    %ecx,%esi
  800ab5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	7e 28                	jle    800ae3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800abf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ac6:	00 
  800ac7:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800ace:	00 
  800acf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ad6:	00 
  800ad7:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800ade:	e8 5d 02 00 00       	call   800d40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae3:	83 c4 2c             	add    $0x2c,%esp
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	b8 02 00 00 00       	mov    $0x2,%eax
  800afb:	89 d1                	mov    %edx,%ecx
  800afd:	89 d3                	mov    %edx,%ebx
  800aff:	89 d7                	mov    %edx,%edi
  800b01:	89 d6                	mov    %edx,%esi
  800b03:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_yield>:

void
sys_yield(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	be 00 00 00 00       	mov    $0x0,%esi
  800b37:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 f7                	mov    %esi,%edi
  800b47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	7e 28                	jle    800b75 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b51:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b58:	00 
  800b59:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800b60:	00 
  800b61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b68:	00 
  800b69:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800b70:	e8 cb 01 00 00       	call   800d40 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b75:	83 c4 2c             	add    $0x2c,%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b86:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 28                	jle    800bc8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bab:	00 
  800bac:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800bb3:	00 
  800bb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbb:	00 
  800bbc:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800bc3:	e8 78 01 00 00       	call   800d40 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc8:	83 c4 2c             	add    $0x2c,%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bde:	b8 06 00 00 00       	mov    $0x6,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	89 df                	mov    %ebx,%edi
  800beb:	89 de                	mov    %ebx,%esi
  800bed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 28                	jle    800c1b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800c16:	e8 25 01 00 00       	call   800d40 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1b:	83 c4 2c             	add    $0x2c,%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 08 00 00 00       	mov    $0x8,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 28                	jle    800c6e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c51:	00 
  800c52:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800c59:	00 
  800c5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c61:	00 
  800c62:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800c69:	e8 d2 00 00 00       	call   800d40 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6e:	83 c4 2c             	add    $0x2c,%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	b8 09 00 00 00       	mov    $0x9,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 28                	jle    800cc1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800cac:	00 
  800cad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb4:	00 
  800cb5:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800cbc:	e8 7f 00 00 00       	call   800d40 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	83 c4 2c             	add    $0x2c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 28                	jle    800d36 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d12:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d19:	00 
  800d1a:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800d21:	00 
  800d22:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d29:	00 
  800d2a:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800d31:	e8 0a 00 00 00       	call   800d40 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d36:	83 c4 2c             	add    $0x2c,%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
	...

00800d40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d48:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d4b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d51:	e8 95 fd ff ff       	call   800aeb <sys_getenvid>
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d59:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6c:	c7 04 24 90 12 80 00 	movl   $0x801290,(%esp)
  800d73:	e8 f4 f3 ff ff       	call   80016c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7f:	89 04 24             	mov    %eax,(%esp)
  800d82:	e8 84 f3 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  800d87:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  800d8e:	e8 d9 f3 ff ff       	call   80016c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d93:	cc                   	int3   
  800d94:	eb fd                	jmp    800d93 <_panic+0x53>
	...

00800d98 <__udivdi3>:
  800d98:	55                   	push   %ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	83 ec 10             	sub    $0x10,%esp
  800d9e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800da2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800da6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800daa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dae:	89 cd                	mov    %ecx,%ebp
  800db0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800db4:	85 c0                	test   %eax,%eax
  800db6:	75 2c                	jne    800de4 <__udivdi3+0x4c>
  800db8:	39 f9                	cmp    %edi,%ecx
  800dba:	77 68                	ja     800e24 <__udivdi3+0x8c>
  800dbc:	85 c9                	test   %ecx,%ecx
  800dbe:	75 0b                	jne    800dcb <__udivdi3+0x33>
  800dc0:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc5:	31 d2                	xor    %edx,%edx
  800dc7:	f7 f1                	div    %ecx
  800dc9:	89 c1                	mov    %eax,%ecx
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	89 f8                	mov    %edi,%eax
  800dcf:	f7 f1                	div    %ecx
  800dd1:	89 c7                	mov    %eax,%edi
  800dd3:	89 f0                	mov    %esi,%eax
  800dd5:	f7 f1                	div    %ecx
  800dd7:	89 c6                	mov    %eax,%esi
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	89 fa                	mov    %edi,%edx
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    
  800de4:	39 f8                	cmp    %edi,%eax
  800de6:	77 2c                	ja     800e14 <__udivdi3+0x7c>
  800de8:	0f bd f0             	bsr    %eax,%esi
  800deb:	83 f6 1f             	xor    $0x1f,%esi
  800dee:	75 4c                	jne    800e3c <__udivdi3+0xa4>
  800df0:	39 f8                	cmp    %edi,%eax
  800df2:	bf 00 00 00 00       	mov    $0x0,%edi
  800df7:	72 0a                	jb     800e03 <__udivdi3+0x6b>
  800df9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dfd:	0f 87 ad 00 00 00    	ja     800eb0 <__udivdi3+0x118>
  800e03:	be 01 00 00 00       	mov    $0x1,%esi
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	31 f6                	xor    %esi,%esi
  800e18:	89 f0                	mov    %esi,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	f7 f1                	div    %ecx
  800e2a:	89 c6                	mov    %eax,%esi
  800e2c:	31 ff                	xor    %edi,%edi
  800e2e:	89 f0                	mov    %esi,%eax
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d 76 00             	lea    0x0(%esi),%esi
  800e3c:	89 f1                	mov    %esi,%ecx
  800e3e:	d3 e0                	shl    %cl,%eax
  800e40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e44:	b8 20 00 00 00       	mov    $0x20,%eax
  800e49:	29 f0                	sub    %esi,%eax
  800e4b:	89 ea                	mov    %ebp,%edx
  800e4d:	88 c1                	mov    %al,%cl
  800e4f:	d3 ea                	shr    %cl,%edx
  800e51:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e55:	09 ca                	or     %ecx,%edx
  800e57:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5b:	89 f1                	mov    %esi,%ecx
  800e5d:	d3 e5                	shl    %cl,%ebp
  800e5f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e63:	89 fd                	mov    %edi,%ebp
  800e65:	88 c1                	mov    %al,%cl
  800e67:	d3 ed                	shr    %cl,%ebp
  800e69:	89 fa                	mov    %edi,%edx
  800e6b:	89 f1                	mov    %esi,%ecx
  800e6d:	d3 e2                	shl    %cl,%edx
  800e6f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e73:	88 c1                	mov    %al,%cl
  800e75:	d3 ef                	shr    %cl,%edi
  800e77:	09 d7                	or     %edx,%edi
  800e79:	89 f8                	mov    %edi,%eax
  800e7b:	89 ea                	mov    %ebp,%edx
  800e7d:	f7 74 24 08          	divl   0x8(%esp)
  800e81:	89 d1                	mov    %edx,%ecx
  800e83:	89 c7                	mov    %eax,%edi
  800e85:	f7 64 24 0c          	mull   0xc(%esp)
  800e89:	39 d1                	cmp    %edx,%ecx
  800e8b:	72 17                	jb     800ea4 <__udivdi3+0x10c>
  800e8d:	74 09                	je     800e98 <__udivdi3+0x100>
  800e8f:	89 fe                	mov    %edi,%esi
  800e91:	31 ff                	xor    %edi,%edi
  800e93:	e9 41 ff ff ff       	jmp    800dd9 <__udivdi3+0x41>
  800e98:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e9c:	89 f1                	mov    %esi,%ecx
  800e9e:	d3 e2                	shl    %cl,%edx
  800ea0:	39 c2                	cmp    %eax,%edx
  800ea2:	73 eb                	jae    800e8f <__udivdi3+0xf7>
  800ea4:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ea7:	31 ff                	xor    %edi,%edi
  800ea9:	e9 2b ff ff ff       	jmp    800dd9 <__udivdi3+0x41>
  800eae:	66 90                	xchg   %ax,%ax
  800eb0:	31 f6                	xor    %esi,%esi
  800eb2:	e9 22 ff ff ff       	jmp    800dd9 <__udivdi3+0x41>
	...

00800eb8 <__umoddi3>:
  800eb8:	55                   	push   %ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	83 ec 20             	sub    $0x20,%esp
  800ebe:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ec2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ec6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eca:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ece:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ed2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ed6:	89 c7                	mov    %eax,%edi
  800ed8:	89 f2                	mov    %esi,%edx
  800eda:	85 ed                	test   %ebp,%ebp
  800edc:	75 16                	jne    800ef4 <__umoddi3+0x3c>
  800ede:	39 f1                	cmp    %esi,%ecx
  800ee0:	0f 86 a6 00 00 00    	jbe    800f8c <__umoddi3+0xd4>
  800ee6:	f7 f1                	div    %ecx
  800ee8:	89 d0                	mov    %edx,%eax
  800eea:	31 d2                	xor    %edx,%edx
  800eec:	83 c4 20             	add    $0x20,%esp
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
  800ef3:	90                   	nop
  800ef4:	39 f5                	cmp    %esi,%ebp
  800ef6:	0f 87 ac 00 00 00    	ja     800fa8 <__umoddi3+0xf0>
  800efc:	0f bd c5             	bsr    %ebp,%eax
  800eff:	83 f0 1f             	xor    $0x1f,%eax
  800f02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f06:	0f 84 a8 00 00 00    	je     800fb4 <__umoddi3+0xfc>
  800f0c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f10:	d3 e5                	shl    %cl,%ebp
  800f12:	bf 20 00 00 00       	mov    $0x20,%edi
  800f17:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f1b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f1f:	89 f9                	mov    %edi,%ecx
  800f21:	d3 e8                	shr    %cl,%eax
  800f23:	09 e8                	or     %ebp,%eax
  800f25:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f29:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f2d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f31:	d3 e0                	shl    %cl,%eax
  800f33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f37:	89 f2                	mov    %esi,%edx
  800f39:	d3 e2                	shl    %cl,%edx
  800f3b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f3f:	d3 e0                	shl    %cl,%eax
  800f41:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f45:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f49:	89 f9                	mov    %edi,%ecx
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	09 d0                	or     %edx,%eax
  800f4f:	d3 ee                	shr    %cl,%esi
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	f7 74 24 18          	divl   0x18(%esp)
  800f57:	89 d6                	mov    %edx,%esi
  800f59:	f7 64 24 0c          	mull   0xc(%esp)
  800f5d:	89 c5                	mov    %eax,%ebp
  800f5f:	89 d1                	mov    %edx,%ecx
  800f61:	39 d6                	cmp    %edx,%esi
  800f63:	72 67                	jb     800fcc <__umoddi3+0x114>
  800f65:	74 75                	je     800fdc <__umoddi3+0x124>
  800f67:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f6b:	29 e8                	sub    %ebp,%eax
  800f6d:	19 ce                	sbb    %ecx,%esi
  800f6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f73:	d3 e8                	shr    %cl,%eax
  800f75:	89 f2                	mov    %esi,%edx
  800f77:	89 f9                	mov    %edi,%ecx
  800f79:	d3 e2                	shl    %cl,%edx
  800f7b:	09 d0                	or     %edx,%eax
  800f7d:	89 f2                	mov    %esi,%edx
  800f7f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f83:	d3 ea                	shr    %cl,%edx
  800f85:	83 c4 20             	add    $0x20,%esp
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    
  800f8c:	85 c9                	test   %ecx,%ecx
  800f8e:	75 0b                	jne    800f9b <__umoddi3+0xe3>
  800f90:	b8 01 00 00 00       	mov    $0x1,%eax
  800f95:	31 d2                	xor    %edx,%edx
  800f97:	f7 f1                	div    %ecx
  800f99:	89 c1                	mov    %eax,%ecx
  800f9b:	89 f0                	mov    %esi,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	f7 f1                	div    %ecx
  800fa1:	89 f8                	mov    %edi,%eax
  800fa3:	e9 3e ff ff ff       	jmp    800ee6 <__umoddi3+0x2e>
  800fa8:	89 f2                	mov    %esi,%edx
  800faa:	83 c4 20             	add    $0x20,%esp
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
  800fb1:	8d 76 00             	lea    0x0(%esi),%esi
  800fb4:	39 f5                	cmp    %esi,%ebp
  800fb6:	72 04                	jb     800fbc <__umoddi3+0x104>
  800fb8:	39 f9                	cmp    %edi,%ecx
  800fba:	77 06                	ja     800fc2 <__umoddi3+0x10a>
  800fbc:	89 f2                	mov    %esi,%edx
  800fbe:	29 cf                	sub    %ecx,%edi
  800fc0:	19 ea                	sbb    %ebp,%edx
  800fc2:	89 f8                	mov    %edi,%eax
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    
  800fcb:	90                   	nop
  800fcc:	89 d1                	mov    %edx,%ecx
  800fce:	89 c5                	mov    %eax,%ebp
  800fd0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fd4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fd8:	eb 8d                	jmp    800f67 <__umoddi3+0xaf>
  800fda:	66 90                	xchg   %ax,%ax
  800fdc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fe0:	72 ea                	jb     800fcc <__umoddi3+0x114>
  800fe2:	89 f1                	mov    %esi,%ecx
  800fe4:	eb 81                	jmp    800f67 <__umoddi3+0xaf>
