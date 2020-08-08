
obj/user/divzero.debug:     file format elf32-i386


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
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  80005c:	e8 13 01 00 00       	call   800174 <cprintf>
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
  800072:	e8 7c 0a 00 00       	call   800af3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 07                	jle    80009d <libmain+0x39>
		binaryname = argv[0];
  800096:	8b 03                	mov    (%ebx),%eax
  800098:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000be:	e8 c0 0e 00 00       	call   800f83 <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 d2 09 00 00       	call   800aa1 <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    
  8000d1:	00 00                	add    %al,(%eax)
	...

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e7:	40                   	inc    %eax
  8000e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	75 19                	jne    80010a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000f1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f8:	00 
  8000f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fc:	89 04 24             	mov    %eax,(%esp)
  8000ff:	e8 60 09 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  800104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010a:	ff 43 04             	incl   0x4(%ebx)
}
  80010d:	83 c4 14             	add    $0x14,%esp
  800110:	5b                   	pop    %ebx
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800137:	8b 45 08             	mov    0x8(%ebp),%eax
  80013a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800144:	89 44 24 04          	mov    %eax,0x4(%esp)
  800148:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  80014f:	e8 82 01 00 00       	call   8002d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800154:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 f8 08 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
}
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 87 ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	75 08                	jne    8001bc <printnum+0x2c>
  8001b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ba:	77 57                	ja     800213 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c0:	4b                   	dec    %ebx
  8001c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001db:	00 
  8001dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	e8 da 1a 00 00       	call   801cc8 <__udivdi3>
  8001ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f6:	89 04 24             	mov    %eax,(%esp)
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	89 fa                	mov    %edi,%edx
  8001ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800202:	e8 89 ff ff ff       	call   800190 <printnum>
  800207:	eb 0f                	jmp    800218 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020d:	89 34 24             	mov    %esi,(%esp)
  800210:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800213:	4b                   	dec    %ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f f1                	jg     800209 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800220:	8b 45 10             	mov    0x10(%ebp),%eax
  800223:	89 44 24 08          	mov    %eax,0x8(%esp)
  800227:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022e:	00 
  80022f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	e8 a7 1b 00 00       	call   801de8 <__umoddi3>
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	0f be 80 38 1f 80 00 	movsbl 0x801f38(%eax),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800252:	83 c4 3c             	add    $0x3c,%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7e 0e                	jle    800270 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 08             	lea    0x8(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x38>
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 10                	je     800284 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 08                	jae    8002ac <sprintputch+0x18>
		*b->buf++ = ch;
  8002a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a7:	88 0a                	mov    %cl,(%edx)
  8002a9:	42                   	inc    %edx
  8002aa:	89 10                	mov    %edx,(%eax)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 02 00 00 00       	call   8002d6 <vprintfmt>
	va_end(ap);
}
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 4c             	sub    $0x4c,%esp
  8002df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e5:	eb 12                	jmp    8002f9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	0f 84 8b 03 00 00    	je     80067a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8002ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 06             	movzbl (%esi),%eax
  8002fc:	46                   	inc    %esi
  8002fd:	83 f8 25             	cmp    $0x25,%eax
  800300:	75 e5                	jne    8002e7 <vprintfmt+0x11>
  800302:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800306:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80030d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800312:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031e:	eb 26                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800327:	eb 1d                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800330:	eb 14                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800335:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033c:	eb 08                	jmp    800346 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800341:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	0f b6 06             	movzbl (%esi),%eax
  800349:	8d 56 01             	lea    0x1(%esi),%edx
  80034c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034f:	8a 16                	mov    (%esi),%dl
  800351:	83 ea 23             	sub    $0x23,%edx
  800354:	80 fa 55             	cmp    $0x55,%dl
  800357:	0f 87 01 03 00 00    	ja     80065e <vprintfmt+0x388>
  80035d:	0f b6 d2             	movzbl %dl,%edx
  800360:	ff 24 95 80 20 80 00 	jmp    *0x802080(,%edx,4)
  800367:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80036a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800372:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800376:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800379:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037c:	83 fa 09             	cmp    $0x9,%edx
  80037f:	77 2a                	ja     8003ab <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb eb                	jmp    80036f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 50 04             	lea    0x4(%eax),%edx
  80038a:	89 55 14             	mov    %edx,0x14(%ebp)
  80038d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800392:	eb 17                	jmp    8003ab <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800394:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800398:	78 98                	js     800332 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80039d:	eb a7                	jmp    800346 <vprintfmt+0x70>
  80039f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a9:	eb 9b                	jmp    800346 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003af:	79 95                	jns    800346 <vprintfmt+0x70>
  8003b1:	eb 8b                	jmp    80033e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b7:	eb 8d                	jmp    800346 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 23 ff ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 50 04             	lea    0x4(%eax),%edx
  8003dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	79 02                	jns    8003e7 <vprintfmt+0x111>
  8003e5:	f7 d8                	neg    %eax
  8003e7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 0f             	cmp    $0xf,%eax
  8003ec:	7f 0b                	jg     8003f9 <vprintfmt+0x123>
  8003ee:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	75 23                	jne    80041c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fd:	c7 44 24 08 50 1f 80 	movl   $0x801f50,0x8(%esp)
  800404:	00 
  800405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 9a fe ff ff       	call   8002ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800417:	e9 dd fe ff ff       	jmp    8002f9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80041c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800420:	c7 44 24 08 3a 23 80 	movl   $0x80233a,0x8(%esp)
  800427:	00 
  800428:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042c:	8b 55 08             	mov    0x8(%ebp),%edx
  80042f:	89 14 24             	mov    %edx,(%esp)
  800432:	e8 77 fe ff ff       	call   8002ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	e9 ba fe ff ff       	jmp    8002f9 <vprintfmt+0x23>
  80043f:	89 f9                	mov    %edi,%ecx
  800441:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800444:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 30                	mov    (%eax),%esi
  800452:	85 f6                	test   %esi,%esi
  800454:	75 05                	jne    80045b <vprintfmt+0x185>
				p = "(null)";
  800456:	be 49 1f 80 00       	mov    $0x801f49,%esi
			if (width > 0 && padc != '-')
  80045b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045f:	0f 8e 84 00 00 00    	jle    8004e9 <vprintfmt+0x213>
  800465:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800469:	74 7e                	je     8004e9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046f:	89 34 24             	mov    %esi,(%esp)
  800472:	e8 ab 02 00 00       	call   800722 <strnlen>
  800477:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80047a:	29 c2                	sub    %eax,%edx
  80047c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800483:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800486:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800489:	89 de                	mov    %ebx,%esi
  80048b:	89 d3                	mov    %edx,%ebx
  80048d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	eb 0b                	jmp    80049c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800491:	89 74 24 04          	mov    %esi,0x4(%esp)
  800495:	89 3c 24             	mov    %edi,(%esp)
  800498:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	4b                   	dec    %ebx
  80049c:	85 db                	test   %ebx,%ebx
  80049e:	7f f1                	jg     800491 <vprintfmt+0x1bb>
  8004a0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004a3:	89 f3                	mov    %esi,%ebx
  8004a5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	79 05                	jns    8004b4 <vprintfmt+0x1de>
  8004af:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b7:	29 c2                	sub    %eax,%edx
  8004b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004bc:	eb 2b                	jmp    8004e9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c2:	74 18                	je     8004dc <vprintfmt+0x206>
  8004c4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ca:	76 10                	jbe    8004dc <vprintfmt+0x206>
					putch('?', putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	eb 0a                	jmp    8004e6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e9:	0f be 06             	movsbl (%esi),%eax
  8004ec:	46                   	inc    %esi
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 21                	je     800512 <vprintfmt+0x23c>
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	78 c9                	js     8004be <vprintfmt+0x1e8>
  8004f5:	4f                   	dec    %edi
  8004f6:	79 c6                	jns    8004be <vprintfmt+0x1e8>
  8004f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004fb:	89 de                	mov    %ebx,%esi
  8004fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800500:	eb 18                	jmp    80051a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800502:	89 74 24 04          	mov    %esi,0x4(%esp)
  800506:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80050d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050f:	4b                   	dec    %ebx
  800510:	eb 08                	jmp    80051a <vprintfmt+0x244>
  800512:	8b 7d 08             	mov    0x8(%ebp),%edi
  800515:	89 de                	mov    %ebx,%esi
  800517:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051a:	85 db                	test   %ebx,%ebx
  80051c:	7f e4                	jg     800502 <vprintfmt+0x22c>
  80051e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800521:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ce fd ff ff       	jmp    8002f9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7e 10                	jle    800540 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 08             	lea    0x8(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 30                	mov    (%eax),%esi
  80053b:	8b 78 04             	mov    0x4(%eax),%edi
  80053e:	eb 26                	jmp    800566 <vprintfmt+0x290>
	else if (lflag)
  800540:	85 c9                	test   %ecx,%ecx
  800542:	74 12                	je     800556 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 30                	mov    (%eax),%esi
  80054f:	89 f7                	mov    %esi,%edi
  800551:	c1 ff 1f             	sar    $0x1f,%edi
  800554:	eb 10                	jmp    800566 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 30                	mov    (%eax),%esi
  800561:	89 f7                	mov    %esi,%edi
  800563:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800566:	85 ff                	test   %edi,%edi
  800568:	78 0a                	js     800574 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 ac 00 00 00       	jmp    800620 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800574:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800578:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800582:	f7 de                	neg    %esi
  800584:	83 d7 00             	adc    $0x0,%edi
  800587:	f7 df                	neg    %edi
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	e9 8d 00 00 00       	jmp    800620 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800593:	89 ca                	mov    %ecx,%edx
  800595:	8d 45 14             	lea    0x14(%ebp),%eax
  800598:	e8 bd fc ff ff       	call   80025a <getuint>
  80059d:	89 c6                	mov    %eax,%esi
  80059f:	89 d7                	mov    %edx,%edi
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a6:	eb 78                	jmp    800620 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ba:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d5:	e9 1f fd ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ff:	8b 30                	mov    (%eax),%esi
  800601:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060b:	eb 13                	jmp    800620 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	89 ca                	mov    %ecx,%edx
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	e8 43 fc ff ff       	call   80025a <getuint>
  800617:	89 c6                	mov    %eax,%esi
  800619:	89 d7                	mov    %edx,%edi
			base = 16;
  80061b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800620:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800624:	89 54 24 10          	mov    %edx,0x10(%esp)
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800633:	89 34 24             	mov    %esi,(%esp)
  800636:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063a:	89 da                	mov    %ebx,%edx
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	e8 4c fb ff ff       	call   800190 <printnum>
			break;
  800644:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800647:	e9 ad fc ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800659:	e9 9b fc ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800662:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800669:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066c:	eb 01                	jmp    80066f <vprintfmt+0x399>
  80066e:	4e                   	dec    %esi
  80066f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800673:	75 f9                	jne    80066e <vprintfmt+0x398>
  800675:	e9 7f fc ff ff       	jmp    8002f9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80067a:	83 c4 4c             	add    $0x4c,%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5e                   	pop    %esi
  80067f:	5f                   	pop    %edi
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 28             	sub    $0x28,%esp
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800691:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800695:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800698:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	74 30                	je     8006d3 <vsnprintf+0x51>
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	7e 33                	jle    8006da <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	c7 04 24 94 02 80 00 	movl   $0x800294,(%esp)
  8006c3:	e8 0e fc ff ff       	call   8002d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	eb 0c                	jmp    8006df <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d8:	eb 05                	jmp    8006df <vsnprintf+0x5d>
  8006da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    

008006e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 7b ff ff ff       	call   800682 <vsnprintf>
	va_end(ap);

	return rc;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    
  800709:	00 00                	add    %al,(%eax)
	...

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 01                	jmp    80071a <strlen+0xe>
		n++;
  800719:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071e:	75 f9                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	eb 01                	jmp    800733 <strnlen+0x11>
		n++;
  800732:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	39 d0                	cmp    %edx,%eax
  800735:	74 06                	je     80073d <strnlen+0x1b>
  800737:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073b:	75 f5                	jne    800732 <strnlen+0x10>
		n++;
	return n;
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
  80074e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800751:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800754:	42                   	inc    %edx
  800755:	84 c9                	test   %cl,%cl
  800757:	75 f5                	jne    80074e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800759:	5b                   	pop    %ebx
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800766:	89 1c 24             	mov    %ebx,(%esp)
  800769:	e8 9e ff ff ff       	call   80070c <strlen>
	strcpy(dst + len, src);
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	89 54 24 04          	mov    %edx,0x4(%esp)
  800775:	01 d8                	add    %ebx,%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 c0 ff ff ff       	call   80073f <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	83 c4 08             	add    $0x8,%esp
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800795:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079a:	eb 0c                	jmp    8007a8 <strncpy+0x21>
		*dst++ = *src;
  80079c:	8a 1a                	mov    (%edx),%bl
  80079e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a7:	41                   	inc    %ecx
  8007a8:	39 f1                	cmp    %esi,%ecx
  8007aa:	75 f0                	jne    80079c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	75 0a                	jne    8007cc <strlcpy+0x1c>
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	eb 1a                	jmp    8007e0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c6:	88 18                	mov    %bl,(%eax)
  8007c8:	40                   	inc    %eax
  8007c9:	41                   	inc    %ecx
  8007ca:	eb 02                	jmp    8007ce <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ce:	4a                   	dec    %edx
  8007cf:	74 0a                	je     8007db <strlcpy+0x2b>
  8007d1:	8a 19                	mov    (%ecx),%bl
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ef                	jne    8007c6 <strlcpy+0x16>
  8007d7:	89 c2                	mov    %eax,%edx
  8007d9:	eb 02                	jmp    8007dd <strlcpy+0x2d>
  8007db:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007dd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e0:	29 f0                	sub    %esi,%eax
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ef:	eb 02                	jmp    8007f3 <strcmp+0xd>
		p++, q++;
  8007f1:	41                   	inc    %ecx
  8007f2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f3:	8a 01                	mov    (%ecx),%al
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x17>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 f4                	je     8007f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800814:	eb 03                	jmp    800819 <strncmp+0x12>
		n--, p++, q++;
  800816:	4a                   	dec    %edx
  800817:	40                   	inc    %eax
  800818:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 14                	je     800831 <strncmp+0x2a>
  80081d:	8a 18                	mov    (%eax),%bl
  80081f:	84 db                	test   %bl,%bl
  800821:	74 04                	je     800827 <strncmp+0x20>
  800823:	3a 19                	cmp    (%ecx),%bl
  800825:	74 ef                	je     800816 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800827:	0f b6 00             	movzbl (%eax),%eax
  80082a:	0f b6 11             	movzbl (%ecx),%edx
  80082d:	29 d0                	sub    %edx,%eax
  80082f:	eb 05                	jmp    800836 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800836:	5b                   	pop    %ebx
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800842:	eb 05                	jmp    800849 <strchr+0x10>
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	74 0c                	je     800854 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800848:	40                   	inc    %eax
  800849:	8a 10                	mov    (%eax),%dl
  80084b:	84 d2                	test   %dl,%dl
  80084d:	75 f5                	jne    800844 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085f:	eb 05                	jmp    800866 <strfind+0x10>
		if (*s == c)
  800861:	38 ca                	cmp    %cl,%dl
  800863:	74 07                	je     80086c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800865:	40                   	inc    %eax
  800866:	8a 10                	mov    (%eax),%dl
  800868:	84 d2                	test   %dl,%dl
  80086a:	75 f5                	jne    800861 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	57                   	push   %edi
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 7d 08             	mov    0x8(%ebp),%edi
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	74 30                	je     8008b1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800881:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800887:	75 25                	jne    8008ae <memset+0x40>
  800889:	f6 c1 03             	test   $0x3,%cl
  80088c:	75 20                	jne    8008ae <memset+0x40>
		c &= 0xFF;
  80088e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800891:	89 d3                	mov    %edx,%ebx
  800893:	c1 e3 08             	shl    $0x8,%ebx
  800896:	89 d6                	mov    %edx,%esi
  800898:	c1 e6 18             	shl    $0x18,%esi
  80089b:	89 d0                	mov    %edx,%eax
  80089d:	c1 e0 10             	shl    $0x10,%eax
  8008a0:	09 f0                	or     %esi,%eax
  8008a2:	09 d0                	or     %edx,%eax
  8008a4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a9:	fc                   	cld    
  8008aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ac:	eb 03                	jmp    8008b1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ae:	fc                   	cld    
  8008af:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5f                   	pop    %edi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c6:	39 c6                	cmp    %eax,%esi
  8008c8:	73 34                	jae    8008fe <memmove+0x46>
  8008ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cd:	39 d0                	cmp    %edx,%eax
  8008cf:	73 2d                	jae    8008fe <memmove+0x46>
		s += n;
		d += n;
  8008d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	f6 c2 03             	test   $0x3,%dl
  8008d7:	75 1b                	jne    8008f4 <memmove+0x3c>
  8008d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008df:	75 13                	jne    8008f4 <memmove+0x3c>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 0e                	jne    8008f4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e6:	83 ef 04             	sub    $0x4,%edi
  8008e9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ef:	fd                   	std    
  8008f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f2:	eb 07                	jmp    8008fb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f4:	4f                   	dec    %edi
  8008f5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f8:	fd                   	std    
  8008f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fb:	fc                   	cld    
  8008fc:	eb 20                	jmp    80091e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800904:	75 13                	jne    800919 <memmove+0x61>
  800906:	a8 03                	test   $0x3,%al
  800908:	75 0f                	jne    800919 <memmove+0x61>
  80090a:	f6 c1 03             	test   $0x3,%cl
  80090d:	75 0a                	jne    800919 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800912:	89 c7                	mov    %eax,%edi
  800914:	fc                   	cld    
  800915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800917:	eb 05                	jmp    80091e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800919:	89 c7                	mov    %eax,%edi
  80091b:	fc                   	cld    
  80091c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800928:	8b 45 10             	mov    0x10(%ebp),%eax
  80092b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	89 44 24 04          	mov    %eax,0x4(%esp)
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	89 04 24             	mov    %eax,(%esp)
  80093c:	e8 77 ff ff ff       	call   8008b8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	ba 00 00 00 00       	mov    $0x0,%edx
  800957:	eb 16                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800959:	8a 04 17             	mov    (%edi,%edx,1),%al
  80095c:	42                   	inc    %edx
  80095d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800961:	38 c8                	cmp    %cl,%al
  800963:	74 0a                	je     80096f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800965:	0f b6 c0             	movzbl %al,%eax
  800968:	0f b6 c9             	movzbl %cl,%ecx
  80096b:	29 c8                	sub    %ecx,%eax
  80096d:	eb 09                	jmp    800978 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 da                	cmp    %ebx,%edx
  800971:	75 e6                	jne    800959 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800986:	89 c2                	mov    %eax,%edx
  800988:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098b:	eb 05                	jmp    800992 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098d:	38 08                	cmp    %cl,(%eax)
  80098f:	74 05                	je     800996 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800991:	40                   	inc    %eax
  800992:	39 d0                	cmp    %edx,%eax
  800994:	72 f7                	jb     80098d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a4:	eb 01                	jmp    8009a7 <strtol+0xf>
		s++;
  8009a6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	8a 02                	mov    (%edx),%al
  8009a9:	3c 20                	cmp    $0x20,%al
  8009ab:	74 f9                	je     8009a6 <strtol+0xe>
  8009ad:	3c 09                	cmp    $0x9,%al
  8009af:	74 f5                	je     8009a6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b1:	3c 2b                	cmp    $0x2b,%al
  8009b3:	75 08                	jne    8009bd <strtol+0x25>
		s++;
  8009b5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bb:	eb 13                	jmp    8009d0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009bd:	3c 2d                	cmp    $0x2d,%al
  8009bf:	75 0a                	jne    8009cb <strtol+0x33>
		s++, neg = 1;
  8009c1:	8d 52 01             	lea    0x1(%edx),%edx
  8009c4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c9:	eb 05                	jmp    8009d0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d0:	85 db                	test   %ebx,%ebx
  8009d2:	74 05                	je     8009d9 <strtol+0x41>
  8009d4:	83 fb 10             	cmp    $0x10,%ebx
  8009d7:	75 28                	jne    800a01 <strtol+0x69>
  8009d9:	8a 02                	mov    (%edx),%al
  8009db:	3c 30                	cmp    $0x30,%al
  8009dd:	75 10                	jne    8009ef <strtol+0x57>
  8009df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e3:	75 0a                	jne    8009ef <strtol+0x57>
		s += 2, base = 16;
  8009e5:	83 c2 02             	add    $0x2,%edx
  8009e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ed:	eb 12                	jmp    800a01 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	75 0e                	jne    800a01 <strtol+0x69>
  8009f3:	3c 30                	cmp    $0x30,%al
  8009f5:	75 05                	jne    8009fc <strtol+0x64>
		s++, base = 8;
  8009f7:	42                   	inc    %edx
  8009f8:	b3 08                	mov    $0x8,%bl
  8009fa:	eb 05                	jmp    800a01 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
  800a06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a08:	8a 0a                	mov    (%edx),%cl
  800a0a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a0d:	80 fb 09             	cmp    $0x9,%bl
  800a10:	77 08                	ja     800a1a <strtol+0x82>
			dig = *s - '0';
  800a12:	0f be c9             	movsbl %cl,%ecx
  800a15:	83 e9 30             	sub    $0x30,%ecx
  800a18:	eb 1e                	jmp    800a38 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a1a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a22:	0f be c9             	movsbl %cl,%ecx
  800a25:	83 e9 57             	sub    $0x57,%ecx
  800a28:	eb 0e                	jmp    800a38 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a2a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 12                	ja     800a44 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a32:	0f be c9             	movsbl %cl,%ecx
  800a35:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a38:	39 f1                	cmp    %esi,%ecx
  800a3a:	7d 0c                	jge    800a48 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a3c:	42                   	inc    %edx
  800a3d:	0f af c6             	imul   %esi,%eax
  800a40:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a42:	eb c4                	jmp    800a08 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a44:	89 c1                	mov    %eax,%ecx
  800a46:	eb 02                	jmp    800a4a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a48:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4e:	74 05                	je     800a55 <strtol+0xbd>
		*endptr = (char *) s;
  800a50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a53:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a55:	85 ff                	test   %edi,%edi
  800a57:	74 04                	je     800a5d <strtol+0xc5>
  800a59:	89 c8                	mov    %ecx,%eax
  800a5b:	f7 d8                	neg    %eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    
	...

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	89 d1                	mov    %edx,%ecx
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 cb                	mov    %ecx,%ebx
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	89 ce                	mov    %ecx,%esi
  800abd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	7e 28                	jle    800aeb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ace:	00 
  800acf:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800ad6:	00 
  800ad7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ade:	00 
  800adf:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800ae6:	e8 29 10 00 00       	call   801b14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aeb:	83 c4 2c             	add    $0x2c,%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 02 00 00 00       	mov    $0x2,%eax
  800b03:	89 d1                	mov    %edx,%ecx
  800b05:	89 d3                	mov    %edx,%ebx
  800b07:	89 d7                	mov    %edx,%edi
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_yield>:

void
sys_yield(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	be 00 00 00 00       	mov    $0x0,%esi
  800b3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 f7                	mov    %esi,%edi
  800b4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	7e 28                	jle    800b7d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b59:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b60:	00 
  800b61:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800b68:	00 
  800b69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b70:	00 
  800b71:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800b78:	e8 97 0f 00 00       	call   801b14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7d:	83 c4 2c             	add    $0x2c,%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b93:	8b 75 18             	mov    0x18(%ebp),%esi
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7e 28                	jle    800bd0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bac:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bb3:	00 
  800bb4:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800bbb:	00 
  800bbc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc3:	00 
  800bc4:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800bcb:	e8 44 0f 00 00       	call   801b14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd0:	83 c4 2c             	add    $0x2c,%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	b8 06 00 00 00       	mov    $0x6,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 28                	jle    800c23 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bff:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800c1e:	e8 f1 0e 00 00       	call   801b14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c23:	83 c4 2c             	add    $0x2c,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 28                	jle    800c76 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c52:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c59:	00 
  800c5a:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800c61:	00 
  800c62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c69:	00 
  800c6a:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800c71:	e8 9e 0e 00 00       	call   801b14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c76:	83 c4 2c             	add    $0x2c,%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 df                	mov    %ebx,%edi
  800c99:	89 de                	mov    %ebx,%esi
  800c9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 28                	jle    800cc9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cac:	00 
  800cad:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cbc:	00 
  800cbd:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800cc4:	e8 4b 0e 00 00       	call   801b14 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc9:	83 c4 2c             	add    $0x2c,%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 28                	jle    800d1c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cff:	00 
  800d00:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800d07:	00 
  800d08:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0f:	00 
  800d10:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800d17:	e8 f8 0d 00 00       	call   801b14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	83 c4 2c             	add    $0x2c,%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 cb                	mov    %ecx,%ebx
  800d5f:	89 cf                	mov    %ecx,%edi
  800d61:	89 ce                	mov    %ecx,%esi
  800d63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 28                	jle    800d91 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d74:	00 
  800d75:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d84:	00 
  800d85:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800d8c:	e8 83 0d 00 00       	call   801b14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d91:	83 c4 2c             	add    $0x2c,%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
  800d99:	00 00                	add    %al,(%eax)
	...

00800d9c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	05 00 00 00 30       	add    $0x30000000,%eax
  800da7:	c1 e8 0c             	shr    $0xc,%eax
}
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	89 04 24             	mov    %eax,(%esp)
  800db8:	e8 df ff ff ff       	call   800d9c <fd2num>
  800dbd:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dc2:	c1 e0 0c             	shl    $0xc,%eax
}
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	53                   	push   %ebx
  800dcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800dd3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 16             	shr    $0x16,%edx
  800dda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de1:	f6 c2 01             	test   $0x1,%dl
  800de4:	74 11                	je     800df7 <fd_alloc+0x30>
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 0c             	shr    $0xc,%edx
  800deb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	75 09                	jne    800e00 <fd_alloc+0x39>
			*fd_store = fd;
  800df7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	eb 17                	jmp    800e17 <fd_alloc+0x50>
  800e00:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e05:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e0a:	75 c7                	jne    800dd3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e0c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e12:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e17:	5b                   	pop    %ebx
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e20:	83 f8 1f             	cmp    $0x1f,%eax
  800e23:	77 36                	ja     800e5b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e25:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e2a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	c1 ea 16             	shr    $0x16,%edx
  800e32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e39:	f6 c2 01             	test   $0x1,%dl
  800e3c:	74 24                	je     800e62 <fd_lookup+0x48>
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	c1 ea 0c             	shr    $0xc,%edx
  800e43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	74 1a                	je     800e69 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e52:	89 02                	mov    %eax,(%edx)
	return 0;
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
  800e59:	eb 13                	jmp    800e6e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e60:	eb 0c                	jmp    800e6e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e67:	eb 05                	jmp    800e6e <fd_lookup+0x54>
  800e69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	53                   	push   %ebx
  800e74:	83 ec 14             	sub    $0x14,%esp
  800e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	eb 0e                	jmp    800e92 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e84:	39 08                	cmp    %ecx,(%eax)
  800e86:	75 09                	jne    800e91 <dev_lookup+0x21>
			*dev = devtab[i];
  800e88:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8f:	eb 33                	jmp    800ec4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e91:	42                   	inc    %edx
  800e92:	8b 04 95 e8 22 80 00 	mov    0x8022e8(,%edx,4),%eax
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	75 e7                	jne    800e84 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e9d:	a1 08 40 80 00       	mov    0x804008,%eax
  800ea2:	8b 40 48             	mov    0x48(%eax),%eax
  800ea5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ead:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  800eb4:	e8 bb f2 ff ff       	call   800174 <cprintf>
	*dev = 0;
  800eb9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ebf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec4:	83 c4 14             	add    $0x14,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 30             	sub    $0x30,%esp
  800ed2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed5:	8a 45 0c             	mov    0xc(%ebp),%al
  800ed8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800edb:	89 34 24             	mov    %esi,(%esp)
  800ede:	e8 b9 fe ff ff       	call   800d9c <fd2num>
  800ee3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ee6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eea:	89 04 24             	mov    %eax,(%esp)
  800eed:	e8 28 ff ff ff       	call   800e1a <fd_lookup>
  800ef2:	89 c3                	mov    %eax,%ebx
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 05                	js     800efd <fd_close+0x33>
	    || fd != fd2)
  800ef8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800efb:	74 0d                	je     800f0a <fd_close+0x40>
		return (must_exist ? r : 0);
  800efd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f01:	75 46                	jne    800f49 <fd_close+0x7f>
  800f03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f08:	eb 3f                	jmp    800f49 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f11:	8b 06                	mov    (%esi),%eax
  800f13:	89 04 24             	mov    %eax,(%esp)
  800f16:	e8 55 ff ff ff       	call   800e70 <dev_lookup>
  800f1b:	89 c3                	mov    %eax,%ebx
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	78 18                	js     800f39 <fd_close+0x6f>
		if (dev->dev_close)
  800f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f24:	8b 40 10             	mov    0x10(%eax),%eax
  800f27:	85 c0                	test   %eax,%eax
  800f29:	74 09                	je     800f34 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f2b:	89 34 24             	mov    %esi,(%esp)
  800f2e:	ff d0                	call   *%eax
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	eb 05                	jmp    800f39 <fd_close+0x6f>
		else
			r = 0;
  800f34:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f39:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f44:	e8 8f fc ff ff       	call   800bd8 <sys_page_unmap>
	return r;
}
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	83 c4 30             	add    $0x30,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	89 04 24             	mov    %eax,(%esp)
  800f65:	e8 b0 fe ff ff       	call   800e1a <fd_lookup>
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 13                	js     800f81 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f75:	00 
  800f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f79:	89 04 24             	mov    %eax,(%esp)
  800f7c:	e8 49 ff ff ff       	call   800eca <fd_close>
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <close_all>:

void
close_all(void)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	53                   	push   %ebx
  800f87:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f8f:	89 1c 24             	mov    %ebx,(%esp)
  800f92:	e8 bb ff ff ff       	call   800f52 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f97:	43                   	inc    %ebx
  800f98:	83 fb 20             	cmp    $0x20,%ebx
  800f9b:	75 f2                	jne    800f8f <close_all+0xc>
		close(i);
}
  800f9d:	83 c4 14             	add    $0x14,%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 4c             	sub    $0x4c,%esp
  800fac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800faf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	89 04 24             	mov    %eax,(%esp)
  800fbc:	e8 59 fe ff ff       	call   800e1a <fd_lookup>
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	0f 88 e1 00 00 00    	js     8010ac <dup+0x109>
		return r;
	close(newfdnum);
  800fcb:	89 3c 24             	mov    %edi,(%esp)
  800fce:	e8 7f ff ff ff       	call   800f52 <close>

	newfd = INDEX2FD(newfdnum);
  800fd3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fd9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 c5 fd ff ff       	call   800dac <fd2data>
  800fe7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fe9:	89 34 24             	mov    %esi,(%esp)
  800fec:	e8 bb fd ff ff       	call   800dac <fd2data>
  800ff1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ff4:	89 d8                	mov    %ebx,%eax
  800ff6:	c1 e8 16             	shr    $0x16,%eax
  800ff9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801000:	a8 01                	test   $0x1,%al
  801002:	74 46                	je     80104a <dup+0xa7>
  801004:	89 d8                	mov    %ebx,%eax
  801006:	c1 e8 0c             	shr    $0xc,%eax
  801009:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801010:	f6 c2 01             	test   $0x1,%dl
  801013:	74 35                	je     80104a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	25 07 0e 00 00       	and    $0xe07,%eax
  801021:	89 44 24 10          	mov    %eax,0x10(%esp)
  801025:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801028:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80102c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801033:	00 
  801034:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801038:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103f:	e8 41 fb ff ff       	call   800b85 <sys_page_map>
  801044:	89 c3                	mov    %eax,%ebx
  801046:	85 c0                	test   %eax,%eax
  801048:	78 3b                	js     801085 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104d:	89 c2                	mov    %eax,%edx
  80104f:	c1 ea 0c             	shr    $0xc,%edx
  801052:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801059:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80105f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801063:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106e:	00 
  80106f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107a:	e8 06 fb ff ff       	call   800b85 <sys_page_map>
  80107f:	89 c3                	mov    %eax,%ebx
  801081:	85 c0                	test   %eax,%eax
  801083:	79 25                	jns    8010aa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801085:	89 74 24 04          	mov    %esi,0x4(%esp)
  801089:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801090:	e8 43 fb ff ff       	call   800bd8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801095:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801098:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a3:	e8 30 fb ff ff       	call   800bd8 <sys_page_unmap>
	return r;
  8010a8:	eb 02                	jmp    8010ac <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010aa:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	83 c4 4c             	add    $0x4c,%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 24             	sub    $0x24,%esp
  8010bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c7:	89 1c 24             	mov    %ebx,(%esp)
  8010ca:	e8 4b fd ff ff       	call   800e1a <fd_lookup>
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 6d                	js     801140 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010dd:	8b 00                	mov    (%eax),%eax
  8010df:	89 04 24             	mov    %eax,(%esp)
  8010e2:	e8 89 fd ff ff       	call   800e70 <dev_lookup>
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 55                	js     801140 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ee:	8b 50 08             	mov    0x8(%eax),%edx
  8010f1:	83 e2 03             	and    $0x3,%edx
  8010f4:	83 fa 01             	cmp    $0x1,%edx
  8010f7:	75 23                	jne    80111c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010fe:	8b 40 48             	mov    0x48(%eax),%eax
  801101:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801105:	89 44 24 04          	mov    %eax,0x4(%esp)
  801109:	c7 04 24 ad 22 80 00 	movl   $0x8022ad,(%esp)
  801110:	e8 5f f0 ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  801115:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111a:	eb 24                	jmp    801140 <read+0x8a>
	}
	if (!dev->dev_read)
  80111c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111f:	8b 52 08             	mov    0x8(%edx),%edx
  801122:	85 d2                	test   %edx,%edx
  801124:	74 15                	je     80113b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801126:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801129:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80112d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801130:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801134:	89 04 24             	mov    %eax,(%esp)
  801137:	ff d2                	call   *%edx
  801139:	eb 05                	jmp    801140 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80113b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801140:	83 c4 24             	add    $0x24,%esp
  801143:	5b                   	pop    %ebx
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
  80114c:	83 ec 1c             	sub    $0x1c,%esp
  80114f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801152:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801155:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115a:	eb 23                	jmp    80117f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80115c:	89 f0                	mov    %esi,%eax
  80115e:	29 d8                	sub    %ebx,%eax
  801160:	89 44 24 08          	mov    %eax,0x8(%esp)
  801164:	8b 45 0c             	mov    0xc(%ebp),%eax
  801167:	01 d8                	add    %ebx,%eax
  801169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116d:	89 3c 24             	mov    %edi,(%esp)
  801170:	e8 41 ff ff ff       	call   8010b6 <read>
		if (m < 0)
  801175:	85 c0                	test   %eax,%eax
  801177:	78 10                	js     801189 <readn+0x43>
			return m;
		if (m == 0)
  801179:	85 c0                	test   %eax,%eax
  80117b:	74 0a                	je     801187 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117d:	01 c3                	add    %eax,%ebx
  80117f:	39 f3                	cmp    %esi,%ebx
  801181:	72 d9                	jb     80115c <readn+0x16>
  801183:	89 d8                	mov    %ebx,%eax
  801185:	eb 02                	jmp    801189 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801187:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801189:	83 c4 1c             	add    $0x1c,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	53                   	push   %ebx
  801195:	83 ec 24             	sub    $0x24,%esp
  801198:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a2:	89 1c 24             	mov    %ebx,(%esp)
  8011a5:	e8 70 fc ff ff       	call   800e1a <fd_lookup>
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 68                	js     801216 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b8:	8b 00                	mov    (%eax),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 ae fc ff ff       	call   800e70 <dev_lookup>
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 50                	js     801216 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cd:	75 23                	jne    8011f2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d4:	8b 40 48             	mov    0x48(%eax),%eax
  8011d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011df:	c7 04 24 c9 22 80 00 	movl   $0x8022c9,(%esp)
  8011e6:	e8 89 ef ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f0:	eb 24                	jmp    801216 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f8:	85 d2                	test   %edx,%edx
  8011fa:	74 15                	je     801211 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801206:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80120a:	89 04 24             	mov    %eax,(%esp)
  80120d:	ff d2                	call   *%edx
  80120f:	eb 05                	jmp    801216 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801211:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801216:	83 c4 24             	add    $0x24,%esp
  801219:	5b                   	pop    %ebx
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <seek>:

int
seek(int fdnum, off_t offset)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801222:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801225:	89 44 24 04          	mov    %eax,0x4(%esp)
  801229:	8b 45 08             	mov    0x8(%ebp),%eax
  80122c:	89 04 24             	mov    %eax,(%esp)
  80122f:	e8 e6 fb ff ff       	call   800e1a <fd_lookup>
  801234:	85 c0                	test   %eax,%eax
  801236:	78 0e                	js     801246 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801238:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80123b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801241:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 24             	sub    $0x24,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	89 1c 24             	mov    %ebx,(%esp)
  80125c:	e8 b9 fb ff ff       	call   800e1a <fd_lookup>
  801261:	85 c0                	test   %eax,%eax
  801263:	78 61                	js     8012c6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	8b 00                	mov    (%eax),%eax
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 f7 fb ff ff       	call   800e70 <dev_lookup>
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 49                	js     8012c6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801280:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801284:	75 23                	jne    8012a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801286:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128b:	8b 40 48             	mov    0x48(%eax),%eax
  80128e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801292:	89 44 24 04          	mov    %eax,0x4(%esp)
  801296:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  80129d:	e8 d2 ee ff ff       	call   800174 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a7:	eb 1d                	jmp    8012c6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ac:	8b 52 18             	mov    0x18(%edx),%edx
  8012af:	85 d2                	test   %edx,%edx
  8012b1:	74 0e                	je     8012c1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ba:	89 04 24             	mov    %eax,(%esp)
  8012bd:	ff d2                	call   *%edx
  8012bf:	eb 05                	jmp    8012c6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c6:	83 c4 24             	add    $0x24,%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 24             	sub    $0x24,%esp
  8012d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	e8 32 fb ff ff       	call   800e1a <fd_lookup>
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 52                	js     80133e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	8b 00                	mov    (%eax),%eax
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	e8 70 fb ff ff       	call   800e70 <dev_lookup>
  801300:	85 c0                	test   %eax,%eax
  801302:	78 3a                	js     80133e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801307:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130b:	74 2c                	je     801339 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80130d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801310:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801317:	00 00 00 
	stat->st_isdir = 0;
  80131a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801321:	00 00 00 
	stat->st_dev = dev;
  801324:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80132e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801331:	89 14 24             	mov    %edx,(%esp)
  801334:	ff 50 14             	call   *0x14(%eax)
  801337:	eb 05                	jmp    80133e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801339:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80133e:	83 c4 24             	add    $0x24,%esp
  801341:	5b                   	pop    %ebx
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
  801349:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801353:	00 
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
  801357:	89 04 24             	mov    %eax,(%esp)
  80135a:	e8 fe 01 00 00       	call   80155d <open>
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	85 c0                	test   %eax,%eax
  801363:	78 1b                	js     801380 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801365:	8b 45 0c             	mov    0xc(%ebp),%eax
  801368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136c:	89 1c 24             	mov    %ebx,(%esp)
  80136f:	e8 58 ff ff ff       	call   8012cc <fstat>
  801374:	89 c6                	mov    %eax,%esi
	close(fd);
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	e8 d4 fb ff ff       	call   800f52 <close>
	return r;
  80137e:	89 f3                	mov    %esi,%ebx
}
  801380:	89 d8                	mov    %ebx,%eax
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    
  801389:	00 00                	add    %al,(%eax)
	...

0080138c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 10             	sub    $0x10,%esp
  801394:	89 c3                	mov    %eax,%ebx
  801396:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801398:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139f:	75 11                	jne    8013b2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013a8:	e8 90 08 00 00       	call   801c3d <ipc_find_env>
  8013ad:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013b9:	00 
  8013ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013c1:	00 
  8013c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 00 08 00 00       	call   801bd3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013da:	00 
  8013db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e6:	e8 81 07 00 00       	call   801b6c <ipc_recv>
}
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	5b                   	pop    %ebx
  8013ef:	5e                   	pop    %esi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801403:	8b 45 0c             	mov    0xc(%ebp),%eax
  801406:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	b8 02 00 00 00       	mov    $0x2,%eax
  801415:	e8 72 ff ff ff       	call   80138c <fsipc>
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	8b 40 0c             	mov    0xc(%eax),%eax
  801428:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	b8 06 00 00 00       	mov    $0x6,%eax
  801437:	e8 50 ff ff ff       	call   80138c <fsipc>
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 14             	sub    $0x14,%esp
  801445:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801448:	8b 45 08             	mov    0x8(%ebp),%eax
  80144b:	8b 40 0c             	mov    0xc(%eax),%eax
  80144e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	b8 05 00 00 00       	mov    $0x5,%eax
  80145d:	e8 2a ff ff ff       	call   80138c <fsipc>
  801462:	85 c0                	test   %eax,%eax
  801464:	78 2b                	js     801491 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801466:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80146d:	00 
  80146e:	89 1c 24             	mov    %ebx,(%esp)
  801471:	e8 c9 f2 ff ff       	call   80073f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801476:	a1 80 50 80 00       	mov    0x805080,%eax
  80147b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801481:	a1 84 50 80 00       	mov    0x805084,%eax
  801486:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801491:	83 c4 14             	add    $0x14,%esp
  801494:	5b                   	pop    %ebx
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80149d:	c7 44 24 08 f8 22 80 	movl   $0x8022f8,0x8(%esp)
  8014a4:	00 
  8014a5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8014ac:	00 
  8014ad:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  8014b4:	e8 5b 06 00 00       	call   801b14 <_panic>

008014b9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 10             	sub    $0x10,%esp
  8014c1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014cf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014da:	b8 03 00 00 00       	mov    $0x3,%eax
  8014df:	e8 a8 fe ff ff       	call   80138c <fsipc>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 6a                	js     801554 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8014ea:	39 c6                	cmp    %eax,%esi
  8014ec:	73 24                	jae    801512 <devfile_read+0x59>
  8014ee:	c7 44 24 0c 21 23 80 	movl   $0x802321,0xc(%esp)
  8014f5:	00 
  8014f6:	c7 44 24 08 28 23 80 	movl   $0x802328,0x8(%esp)
  8014fd:	00 
  8014fe:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801505:	00 
  801506:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  80150d:	e8 02 06 00 00       	call   801b14 <_panic>
	assert(r <= PGSIZE);
  801512:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801517:	7e 24                	jle    80153d <devfile_read+0x84>
  801519:	c7 44 24 0c 3d 23 80 	movl   $0x80233d,0xc(%esp)
  801520:	00 
  801521:	c7 44 24 08 28 23 80 	movl   $0x802328,0x8(%esp)
  801528:	00 
  801529:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801530:	00 
  801531:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  801538:	e8 d7 05 00 00       	call   801b14 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80153d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801541:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801548:	00 
  801549:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 64 f3 ff ff       	call   8008b8 <memmove>
	return r;
}
  801554:	89 d8                	mov    %ebx,%eax
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	56                   	push   %esi
  801561:	53                   	push   %ebx
  801562:	83 ec 20             	sub    $0x20,%esp
  801565:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801568:	89 34 24             	mov    %esi,(%esp)
  80156b:	e8 9c f1 ff ff       	call   80070c <strlen>
  801570:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801575:	7f 60                	jg     8015d7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	e8 45 f8 ff ff       	call   800dc7 <fd_alloc>
  801582:	89 c3                	mov    %eax,%ebx
  801584:	85 c0                	test   %eax,%eax
  801586:	78 54                	js     8015dc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801588:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801593:	e8 a7 f1 ff ff       	call   80073f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801598:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a8:	e8 df fd ff ff       	call   80138c <fsipc>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	79 15                	jns    8015c8 <open+0x6b>
		fd_close(fd, 0);
  8015b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ba:	00 
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	89 04 24             	mov    %eax,(%esp)
  8015c1:	e8 04 f9 ff ff       	call   800eca <fd_close>
		return r;
  8015c6:	eb 14                	jmp    8015dc <open+0x7f>
	}

	return fd2num(fd);
  8015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 c9 f7 ff ff       	call   800d9c <fd2num>
  8015d3:	89 c3                	mov    %eax,%ebx
  8015d5:	eb 05                	jmp    8015dc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015d7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015dc:	89 d8                	mov    %ebx,%eax
  8015de:	83 c4 20             	add    $0x20,%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f5:	e8 92 fd ff ff       	call   80138c <fsipc>
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	83 ec 10             	sub    $0x10,%esp
  801604:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801607:	8b 45 08             	mov    0x8(%ebp),%eax
  80160a:	89 04 24             	mov    %eax,(%esp)
  80160d:	e8 9a f7 ff ff       	call   800dac <fd2data>
  801612:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801614:	c7 44 24 04 49 23 80 	movl   $0x802349,0x4(%esp)
  80161b:	00 
  80161c:	89 34 24             	mov    %esi,(%esp)
  80161f:	e8 1b f1 ff ff       	call   80073f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801624:	8b 43 04             	mov    0x4(%ebx),%eax
  801627:	2b 03                	sub    (%ebx),%eax
  801629:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80162f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801636:	00 00 00 
	stat->st_dev = &devpipe;
  801639:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801640:	30 80 00 
	return 0;
}
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	83 ec 14             	sub    $0x14,%esp
  801656:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801659:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 6f f5 ff ff       	call   800bd8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801669:	89 1c 24             	mov    %ebx,(%esp)
  80166c:	e8 3b f7 ff ff       	call   800dac <fd2data>
  801671:	89 44 24 04          	mov    %eax,0x4(%esp)
  801675:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167c:	e8 57 f5 ff ff       	call   800bd8 <sys_page_unmap>
}
  801681:	83 c4 14             	add    $0x14,%esp
  801684:	5b                   	pop    %ebx
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 2c             	sub    $0x2c,%esp
  801690:	89 c7                	mov    %eax,%edi
  801692:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801695:	a1 08 40 80 00       	mov    0x804008,%eax
  80169a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80169d:	89 3c 24             	mov    %edi,(%esp)
  8016a0:	e8 df 05 00 00       	call   801c84 <pageref>
  8016a5:	89 c6                	mov    %eax,%esi
  8016a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016aa:	89 04 24             	mov    %eax,(%esp)
  8016ad:	e8 d2 05 00 00       	call   801c84 <pageref>
  8016b2:	39 c6                	cmp    %eax,%esi
  8016b4:	0f 94 c0             	sete   %al
  8016b7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016ba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016c0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016c3:	39 cb                	cmp    %ecx,%ebx
  8016c5:	75 08                	jne    8016cf <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016c7:	83 c4 2c             	add    $0x2c,%esp
  8016ca:	5b                   	pop    %ebx
  8016cb:	5e                   	pop    %esi
  8016cc:	5f                   	pop    %edi
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016cf:	83 f8 01             	cmp    $0x1,%eax
  8016d2:	75 c1                	jne    801695 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d4:	8b 42 58             	mov    0x58(%edx),%eax
  8016d7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016de:	00 
  8016df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e7:	c7 04 24 50 23 80 00 	movl   $0x802350,(%esp)
  8016ee:	e8 81 ea ff ff       	call   800174 <cprintf>
  8016f3:	eb a0                	jmp    801695 <_pipeisclosed+0xe>

008016f5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	57                   	push   %edi
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 1c             	sub    $0x1c,%esp
  8016fe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801701:	89 34 24             	mov    %esi,(%esp)
  801704:	e8 a3 f6 ff ff       	call   800dac <fd2data>
  801709:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170b:	bf 00 00 00 00       	mov    $0x0,%edi
  801710:	eb 3c                	jmp    80174e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801712:	89 da                	mov    %ebx,%edx
  801714:	89 f0                	mov    %esi,%eax
  801716:	e8 6c ff ff ff       	call   801687 <_pipeisclosed>
  80171b:	85 c0                	test   %eax,%eax
  80171d:	75 38                	jne    801757 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80171f:	e8 ee f3 ff ff       	call   800b12 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801724:	8b 43 04             	mov    0x4(%ebx),%eax
  801727:	8b 13                	mov    (%ebx),%edx
  801729:	83 c2 20             	add    $0x20,%edx
  80172c:	39 d0                	cmp    %edx,%eax
  80172e:	73 e2                	jae    801712 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801730:	8b 55 0c             	mov    0xc(%ebp),%edx
  801733:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801736:	89 c2                	mov    %eax,%edx
  801738:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80173e:	79 05                	jns    801745 <devpipe_write+0x50>
  801740:	4a                   	dec    %edx
  801741:	83 ca e0             	or     $0xffffffe0,%edx
  801744:	42                   	inc    %edx
  801745:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801749:	40                   	inc    %eax
  80174a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174d:	47                   	inc    %edi
  80174e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801751:	75 d1                	jne    801724 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801753:	89 f8                	mov    %edi,%eax
  801755:	eb 05                	jmp    80175c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80175c:	83 c4 1c             	add    $0x1c,%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	57                   	push   %edi
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	83 ec 1c             	sub    $0x1c,%esp
  80176d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801770:	89 3c 24             	mov    %edi,(%esp)
  801773:	e8 34 f6 ff ff       	call   800dac <fd2data>
  801778:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177a:	be 00 00 00 00       	mov    $0x0,%esi
  80177f:	eb 3a                	jmp    8017bb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801781:	85 f6                	test   %esi,%esi
  801783:	74 04                	je     801789 <devpipe_read+0x25>
				return i;
  801785:	89 f0                	mov    %esi,%eax
  801787:	eb 40                	jmp    8017c9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801789:	89 da                	mov    %ebx,%edx
  80178b:	89 f8                	mov    %edi,%eax
  80178d:	e8 f5 fe ff ff       	call   801687 <_pipeisclosed>
  801792:	85 c0                	test   %eax,%eax
  801794:	75 2e                	jne    8017c4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801796:	e8 77 f3 ff ff       	call   800b12 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80179b:	8b 03                	mov    (%ebx),%eax
  80179d:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017a0:	74 df                	je     801781 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017a7:	79 05                	jns    8017ae <devpipe_read+0x4a>
  8017a9:	48                   	dec    %eax
  8017aa:	83 c8 e0             	or     $0xffffffe0,%eax
  8017ad:	40                   	inc    %eax
  8017ae:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017b8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ba:	46                   	inc    %esi
  8017bb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017be:	75 db                	jne    80179b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017c0:	89 f0                	mov    %esi,%eax
  8017c2:	eb 05                	jmp    8017c9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017c9:	83 c4 1c             	add    $0x1c,%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5f                   	pop    %edi
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	57                   	push   %edi
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 3c             	sub    $0x3c,%esp
  8017da:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 df f5 ff ff       	call   800dc7 <fd_alloc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	0f 88 45 01 00 00    	js     801937 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017f9:	00 
  8017fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801808:	e8 24 f3 ff ff       	call   800b31 <sys_page_alloc>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	85 c0                	test   %eax,%eax
  801811:	0f 88 20 01 00 00    	js     801937 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801817:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80181a:	89 04 24             	mov    %eax,(%esp)
  80181d:	e8 a5 f5 ff ff       	call   800dc7 <fd_alloc>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	85 c0                	test   %eax,%eax
  801826:	0f 88 f8 00 00 00    	js     801924 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801833:	00 
  801834:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801842:	e8 ea f2 ff ff       	call   800b31 <sys_page_alloc>
  801847:	89 c3                	mov    %eax,%ebx
  801849:	85 c0                	test   %eax,%eax
  80184b:	0f 88 d3 00 00 00    	js     801924 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801854:	89 04 24             	mov    %eax,(%esp)
  801857:	e8 50 f5 ff ff       	call   800dac <fd2data>
  80185c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801865:	00 
  801866:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801871:	e8 bb f2 ff ff       	call   800b31 <sys_page_alloc>
  801876:	89 c3                	mov    %eax,%ebx
  801878:	85 c0                	test   %eax,%eax
  80187a:	0f 88 91 00 00 00    	js     801911 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801880:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 21 f5 ff ff       	call   800dac <fd2data>
  80188b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801892:	00 
  801893:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801897:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80189e:	00 
  80189f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018aa:	e8 d6 f2 ff ff       	call   800b85 <sys_page_map>
  8018af:	89 c3                	mov    %eax,%ebx
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 4c                	js     801901 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018be:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	e8 b2 f4 ff ff       	call   800d9c <fd2num>
  8018ea:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 a5 f4 ff ff       	call   800d9c <fd2num>
  8018f7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ff:	eb 36                	jmp    801937 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801901:	89 74 24 04          	mov    %esi,0x4(%esp)
  801905:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190c:	e8 c7 f2 ff ff       	call   800bd8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801911:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801914:	89 44 24 04          	mov    %eax,0x4(%esp)
  801918:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191f:	e8 b4 f2 ff ff       	call   800bd8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801924:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801932:	e8 a1 f2 ff ff       	call   800bd8 <sys_page_unmap>
    err:
	return r;
}
  801937:	89 d8                	mov    %ebx,%eax
  801939:	83 c4 3c             	add    $0x3c,%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5e                   	pop    %esi
  80193e:	5f                   	pop    %edi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	89 04 24             	mov    %eax,(%esp)
  801954:	e8 c1 f4 ff ff       	call   800e1a <fd_lookup>
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 15                	js     801972 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80195d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801960:	89 04 24             	mov    %eax,(%esp)
  801963:	e8 44 f4 ff ff       	call   800dac <fd2data>
	return _pipeisclosed(fd, p);
  801968:	89 c2                	mov    %eax,%edx
  80196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196d:	e8 15 fd ff ff       	call   801687 <_pipeisclosed>
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801984:	c7 44 24 04 68 23 80 	movl   $0x802368,0x4(%esp)
  80198b:	00 
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 a8 ed ff ff       	call   80073f <strcpy>
	return 0;
}
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019af:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b5:	eb 30                	jmp    8019e7 <devcons_write+0x49>
		m = n - tot;
  8019b7:	8b 75 10             	mov    0x10(%ebp),%esi
  8019ba:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019bc:	83 fe 7f             	cmp    $0x7f,%esi
  8019bf:	76 05                	jbe    8019c6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019c1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019c6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019ca:	03 45 0c             	add    0xc(%ebp),%eax
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	89 3c 24             	mov    %edi,(%esp)
  8019d4:	e8 df ee ff ff       	call   8008b8 <memmove>
		sys_cputs(buf, m);
  8019d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019dd:	89 3c 24             	mov    %edi,(%esp)
  8019e0:	e8 7f f0 ff ff       	call   800a64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e5:	01 f3                	add    %esi,%ebx
  8019e7:	89 d8                	mov    %ebx,%eax
  8019e9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019ec:	72 c9                	jb     8019b7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ee:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5f                   	pop    %edi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a03:	75 07                	jne    801a0c <devcons_read+0x13>
  801a05:	eb 25                	jmp    801a2c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a07:	e8 06 f1 ff ff       	call   800b12 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a0c:	e8 71 f0 ff ff       	call   800a82 <sys_cgetc>
  801a11:	85 c0                	test   %eax,%eax
  801a13:	74 f2                	je     801a07 <devcons_read+0xe>
  801a15:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 1d                	js     801a38 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a1b:	83 f8 04             	cmp    $0x4,%eax
  801a1e:	74 13                	je     801a33 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a23:	88 10                	mov    %dl,(%eax)
	return 1;
  801a25:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2a:	eb 0c                	jmp    801a38 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a31:	eb 05                	jmp    801a38 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a46:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a4d:	00 
  801a4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a51:	89 04 24             	mov    %eax,(%esp)
  801a54:	e8 0b f0 ff ff       	call   800a64 <sys_cputs>
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <getchar>:

int
getchar(void)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a61:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a68:	00 
  801a69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a77:	e8 3a f6 ff ff       	call   8010b6 <read>
	if (r < 0)
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	78 0f                	js     801a8f <getchar+0x34>
		return r;
	if (r < 1)
  801a80:	85 c0                	test   %eax,%eax
  801a82:	7e 06                	jle    801a8a <getchar+0x2f>
		return -E_EOF;
	return c;
  801a84:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a88:	eb 05                	jmp    801a8f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a8a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 71 f3 ff ff       	call   800e1a <fd_lookup>
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 11                	js     801abe <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab6:	39 10                	cmp    %edx,(%eax)
  801ab8:	0f 94 c0             	sete   %al
  801abb:	0f b6 c0             	movzbl %al,%eax
}
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <opencons>:

int
opencons(void)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 f6 f2 ff ff       	call   800dc7 <fd_alloc>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 3c                	js     801b11 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801adc:	00 
  801add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aeb:	e8 41 f0 ff ff       	call   800b31 <sys_page_alloc>
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 1d                	js     801b11 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b09:	89 04 24             	mov    %eax,(%esp)
  801b0c:	e8 8b f2 ff ff       	call   800d9c <fd2num>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    
	...

00801b14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b1c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b1f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b25:	e8 c9 ef ff ff       	call   800af3 <sys_getenvid>
  801b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b31:	8b 55 08             	mov    0x8(%ebp),%edx
  801b34:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b38:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b40:	c7 04 24 74 23 80 00 	movl   $0x802374,(%esp)
  801b47:	e8 28 e6 ff ff       	call   800174 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b50:	8b 45 10             	mov    0x10(%ebp),%eax
  801b53:	89 04 24             	mov    %eax,(%esp)
  801b56:	e8 b8 e5 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801b5b:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  801b62:	e8 0d e6 ff ff       	call   800174 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b67:	cc                   	int3   
  801b68:	eb fd                	jmp    801b67 <_panic+0x53>
	...

00801b6c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	83 ec 10             	sub    $0x10,%esp
  801b74:	8b 75 08             	mov    0x8(%ebp),%esi
  801b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	75 05                	jne    801b86 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b81:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 b9 f1 ff ff       	call   800d47 <sys_ipc_recv>
	if (!err) {
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	75 26                	jne    801bb8 <ipc_recv+0x4c>
		if (from_env_store) {
  801b92:	85 f6                	test   %esi,%esi
  801b94:	74 0a                	je     801ba0 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b96:	a1 08 40 80 00       	mov    0x804008,%eax
  801b9b:	8b 40 74             	mov    0x74(%eax),%eax
  801b9e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ba0:	85 db                	test   %ebx,%ebx
  801ba2:	74 0a                	je     801bae <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801ba4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba9:	8b 40 78             	mov    0x78(%eax),%eax
  801bac:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801bae:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb3:	8b 40 70             	mov    0x70(%eax),%eax
  801bb6:	eb 14                	jmp    801bcc <ipc_recv+0x60>
	}
	if (from_env_store) {
  801bb8:	85 f6                	test   %esi,%esi
  801bba:	74 06                	je     801bc2 <ipc_recv+0x56>
		*from_env_store = 0;
  801bbc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801bc2:	85 db                	test   %ebx,%ebx
  801bc4:	74 06                	je     801bcc <ipc_recv+0x60>
		*perm_store = 0;
  801bc6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	57                   	push   %edi
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 1c             	sub    $0x1c,%esp
  801bdc:	8b 75 10             	mov    0x10(%ebp),%esi
  801bdf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801be2:	85 f6                	test   %esi,%esi
  801be4:	75 05                	jne    801beb <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801be6:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801beb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bef:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	89 04 24             	mov    %eax,(%esp)
  801c00:	e8 1f f1 ff ff       	call   800d24 <sys_ipc_try_send>
  801c05:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801c07:	e8 06 ef ff ff       	call   800b12 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801c0c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801c0f:	74 da                	je     801beb <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801c11:	85 db                	test   %ebx,%ebx
  801c13:	74 20                	je     801c35 <ipc_send+0x62>
		panic("send fail: %e", err);
  801c15:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c19:	c7 44 24 08 98 23 80 	movl   $0x802398,0x8(%esp)
  801c20:	00 
  801c21:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c28:	00 
  801c29:	c7 04 24 a6 23 80 00 	movl   $0x8023a6,(%esp)
  801c30:	e8 df fe ff ff       	call   801b14 <_panic>
	}
	return;
}
  801c35:	83 c4 1c             	add    $0x1c,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5f                   	pop    %edi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	53                   	push   %ebx
  801c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c49:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c50:	89 c2                	mov    %eax,%edx
  801c52:	c1 e2 07             	shl    $0x7,%edx
  801c55:	29 ca                	sub    %ecx,%edx
  801c57:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c5d:	8b 52 50             	mov    0x50(%edx),%edx
  801c60:	39 da                	cmp    %ebx,%edx
  801c62:	75 0f                	jne    801c73 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c64:	c1 e0 07             	shl    $0x7,%eax
  801c67:	29 c8                	sub    %ecx,%eax
  801c69:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c6e:	8b 40 40             	mov    0x40(%eax),%eax
  801c71:	eb 0c                	jmp    801c7f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c73:	40                   	inc    %eax
  801c74:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c79:	75 ce                	jne    801c49 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c7b:	66 b8 00 00          	mov    $0x0,%ax
}
  801c7f:	5b                   	pop    %ebx
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
	...

00801c84 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	c1 ea 16             	shr    $0x16,%edx
  801c8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c96:	f6 c2 01             	test   $0x1,%dl
  801c99:	74 1e                	je     801cb9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c9b:	c1 e8 0c             	shr    $0xc,%eax
  801c9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ca5:	a8 01                	test   $0x1,%al
  801ca7:	74 17                	je     801cc0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ca9:	c1 e8 0c             	shr    $0xc,%eax
  801cac:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cb3:	ef 
  801cb4:	0f b7 c0             	movzwl %ax,%eax
  801cb7:	eb 0c                	jmp    801cc5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	eb 05                	jmp    801cc5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    
	...

00801cc8 <__udivdi3>:
  801cc8:	55                   	push   %ebp
  801cc9:	57                   	push   %edi
  801cca:	56                   	push   %esi
  801ccb:	83 ec 10             	sub    $0x10,%esp
  801cce:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cd2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cde:	89 cd                	mov    %ecx,%ebp
  801ce0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	75 2c                	jne    801d14 <__udivdi3+0x4c>
  801ce8:	39 f9                	cmp    %edi,%ecx
  801cea:	77 68                	ja     801d54 <__udivdi3+0x8c>
  801cec:	85 c9                	test   %ecx,%ecx
  801cee:	75 0b                	jne    801cfb <__udivdi3+0x33>
  801cf0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf5:	31 d2                	xor    %edx,%edx
  801cf7:	f7 f1                	div    %ecx
  801cf9:	89 c1                	mov    %eax,%ecx
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	89 f8                	mov    %edi,%eax
  801cff:	f7 f1                	div    %ecx
  801d01:	89 c7                	mov    %eax,%edi
  801d03:	89 f0                	mov    %esi,%eax
  801d05:	f7 f1                	div    %ecx
  801d07:	89 c6                	mov    %eax,%esi
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	89 fa                	mov    %edi,%edx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	39 f8                	cmp    %edi,%eax
  801d16:	77 2c                	ja     801d44 <__udivdi3+0x7c>
  801d18:	0f bd f0             	bsr    %eax,%esi
  801d1b:	83 f6 1f             	xor    $0x1f,%esi
  801d1e:	75 4c                	jne    801d6c <__udivdi3+0xa4>
  801d20:	39 f8                	cmp    %edi,%eax
  801d22:	bf 00 00 00 00       	mov    $0x0,%edi
  801d27:	72 0a                	jb     801d33 <__udivdi3+0x6b>
  801d29:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d2d:	0f 87 ad 00 00 00    	ja     801de0 <__udivdi3+0x118>
  801d33:	be 01 00 00 00       	mov    $0x1,%esi
  801d38:	89 f0                	mov    %esi,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    
  801d43:	90                   	nop
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	31 f6                	xor    %esi,%esi
  801d48:	89 f0                	mov    %esi,%eax
  801d4a:	89 fa                	mov    %edi,%edx
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    
  801d53:	90                   	nop
  801d54:	89 fa                	mov    %edi,%edx
  801d56:	89 f0                	mov    %esi,%eax
  801d58:	f7 f1                	div    %ecx
  801d5a:	89 c6                	mov    %eax,%esi
  801d5c:	31 ff                	xor    %edi,%edi
  801d5e:	89 f0                	mov    %esi,%eax
  801d60:	89 fa                	mov    %edi,%edx
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d 76 00             	lea    0x0(%esi),%esi
  801d6c:	89 f1                	mov    %esi,%ecx
  801d6e:	d3 e0                	shl    %cl,%eax
  801d70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d74:	b8 20 00 00 00       	mov    $0x20,%eax
  801d79:	29 f0                	sub    %esi,%eax
  801d7b:	89 ea                	mov    %ebp,%edx
  801d7d:	88 c1                	mov    %al,%cl
  801d7f:	d3 ea                	shr    %cl,%edx
  801d81:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d85:	09 ca                	or     %ecx,%edx
  801d87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d8b:	89 f1                	mov    %esi,%ecx
  801d8d:	d3 e5                	shl    %cl,%ebp
  801d8f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d93:	89 fd                	mov    %edi,%ebp
  801d95:	88 c1                	mov    %al,%cl
  801d97:	d3 ed                	shr    %cl,%ebp
  801d99:	89 fa                	mov    %edi,%edx
  801d9b:	89 f1                	mov    %esi,%ecx
  801d9d:	d3 e2                	shl    %cl,%edx
  801d9f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801da3:	88 c1                	mov    %al,%cl
  801da5:	d3 ef                	shr    %cl,%edi
  801da7:	09 d7                	or     %edx,%edi
  801da9:	89 f8                	mov    %edi,%eax
  801dab:	89 ea                	mov    %ebp,%edx
  801dad:	f7 74 24 08          	divl   0x8(%esp)
  801db1:	89 d1                	mov    %edx,%ecx
  801db3:	89 c7                	mov    %eax,%edi
  801db5:	f7 64 24 0c          	mull   0xc(%esp)
  801db9:	39 d1                	cmp    %edx,%ecx
  801dbb:	72 17                	jb     801dd4 <__udivdi3+0x10c>
  801dbd:	74 09                	je     801dc8 <__udivdi3+0x100>
  801dbf:	89 fe                	mov    %edi,%esi
  801dc1:	31 ff                	xor    %edi,%edi
  801dc3:	e9 41 ff ff ff       	jmp    801d09 <__udivdi3+0x41>
  801dc8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dcc:	89 f1                	mov    %esi,%ecx
  801dce:	d3 e2                	shl    %cl,%edx
  801dd0:	39 c2                	cmp    %eax,%edx
  801dd2:	73 eb                	jae    801dbf <__udivdi3+0xf7>
  801dd4:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dd7:	31 ff                	xor    %edi,%edi
  801dd9:	e9 2b ff ff ff       	jmp    801d09 <__udivdi3+0x41>
  801dde:	66 90                	xchg   %ax,%ax
  801de0:	31 f6                	xor    %esi,%esi
  801de2:	e9 22 ff ff ff       	jmp    801d09 <__udivdi3+0x41>
	...

00801de8 <__umoddi3>:
  801de8:	55                   	push   %ebp
  801de9:	57                   	push   %edi
  801dea:	56                   	push   %esi
  801deb:	83 ec 20             	sub    $0x20,%esp
  801dee:	8b 44 24 30          	mov    0x30(%esp),%eax
  801df2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801df6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dfa:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dfe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e02:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e06:	89 c7                	mov    %eax,%edi
  801e08:	89 f2                	mov    %esi,%edx
  801e0a:	85 ed                	test   %ebp,%ebp
  801e0c:	75 16                	jne    801e24 <__umoddi3+0x3c>
  801e0e:	39 f1                	cmp    %esi,%ecx
  801e10:	0f 86 a6 00 00 00    	jbe    801ebc <__umoddi3+0xd4>
  801e16:	f7 f1                	div    %ecx
  801e18:	89 d0                	mov    %edx,%eax
  801e1a:	31 d2                	xor    %edx,%edx
  801e1c:	83 c4 20             	add    $0x20,%esp
  801e1f:	5e                   	pop    %esi
  801e20:	5f                   	pop    %edi
  801e21:	5d                   	pop    %ebp
  801e22:	c3                   	ret    
  801e23:	90                   	nop
  801e24:	39 f5                	cmp    %esi,%ebp
  801e26:	0f 87 ac 00 00 00    	ja     801ed8 <__umoddi3+0xf0>
  801e2c:	0f bd c5             	bsr    %ebp,%eax
  801e2f:	83 f0 1f             	xor    $0x1f,%eax
  801e32:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e36:	0f 84 a8 00 00 00    	je     801ee4 <__umoddi3+0xfc>
  801e3c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e40:	d3 e5                	shl    %cl,%ebp
  801e42:	bf 20 00 00 00       	mov    $0x20,%edi
  801e47:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e4f:	89 f9                	mov    %edi,%ecx
  801e51:	d3 e8                	shr    %cl,%eax
  801e53:	09 e8                	or     %ebp,%eax
  801e55:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e59:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e5d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e61:	d3 e0                	shl    %cl,%eax
  801e63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e67:	89 f2                	mov    %esi,%edx
  801e69:	d3 e2                	shl    %cl,%edx
  801e6b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e6f:	d3 e0                	shl    %cl,%eax
  801e71:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e75:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e79:	89 f9                	mov    %edi,%ecx
  801e7b:	d3 e8                	shr    %cl,%eax
  801e7d:	09 d0                	or     %edx,%eax
  801e7f:	d3 ee                	shr    %cl,%esi
  801e81:	89 f2                	mov    %esi,%edx
  801e83:	f7 74 24 18          	divl   0x18(%esp)
  801e87:	89 d6                	mov    %edx,%esi
  801e89:	f7 64 24 0c          	mull   0xc(%esp)
  801e8d:	89 c5                	mov    %eax,%ebp
  801e8f:	89 d1                	mov    %edx,%ecx
  801e91:	39 d6                	cmp    %edx,%esi
  801e93:	72 67                	jb     801efc <__umoddi3+0x114>
  801e95:	74 75                	je     801f0c <__umoddi3+0x124>
  801e97:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e9b:	29 e8                	sub    %ebp,%eax
  801e9d:	19 ce                	sbb    %ecx,%esi
  801e9f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea3:	d3 e8                	shr    %cl,%eax
  801ea5:	89 f2                	mov    %esi,%edx
  801ea7:	89 f9                	mov    %edi,%ecx
  801ea9:	d3 e2                	shl    %cl,%edx
  801eab:	09 d0                	or     %edx,%eax
  801ead:	89 f2                	mov    %esi,%edx
  801eaf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eb3:	d3 ea                	shr    %cl,%edx
  801eb5:	83 c4 20             	add    $0x20,%esp
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    
  801ebc:	85 c9                	test   %ecx,%ecx
  801ebe:	75 0b                	jne    801ecb <__umoddi3+0xe3>
  801ec0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec5:	31 d2                	xor    %edx,%edx
  801ec7:	f7 f1                	div    %ecx
  801ec9:	89 c1                	mov    %eax,%ecx
  801ecb:	89 f0                	mov    %esi,%eax
  801ecd:	31 d2                	xor    %edx,%edx
  801ecf:	f7 f1                	div    %ecx
  801ed1:	89 f8                	mov    %edi,%eax
  801ed3:	e9 3e ff ff ff       	jmp    801e16 <__umoddi3+0x2e>
  801ed8:	89 f2                	mov    %esi,%edx
  801eda:	83 c4 20             	add    $0x20,%esp
  801edd:	5e                   	pop    %esi
  801ede:	5f                   	pop    %edi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    
  801ee1:	8d 76 00             	lea    0x0(%esi),%esi
  801ee4:	39 f5                	cmp    %esi,%ebp
  801ee6:	72 04                	jb     801eec <__umoddi3+0x104>
  801ee8:	39 f9                	cmp    %edi,%ecx
  801eea:	77 06                	ja     801ef2 <__umoddi3+0x10a>
  801eec:	89 f2                	mov    %esi,%edx
  801eee:	29 cf                	sub    %ecx,%edi
  801ef0:	19 ea                	sbb    %ebp,%edx
  801ef2:	89 f8                	mov    %edi,%eax
  801ef4:	83 c4 20             	add    $0x20,%esp
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    
  801efb:	90                   	nop
  801efc:	89 d1                	mov    %edx,%ecx
  801efe:	89 c5                	mov    %eax,%ebp
  801f00:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f04:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f08:	eb 8d                	jmp    801e97 <__umoddi3+0xaf>
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f10:	72 ea                	jb     801efc <__umoddi3+0x114>
  801f12:	89 f1                	mov    %esi,%ecx
  801f14:	eb 81                	jmp    801e97 <__umoddi3+0xaf>
