
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  800043:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  80004a:	e8 15 01 00 00       	call   800164 <cprintf>
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
  800062:	e8 7c 0a 00 00       	call   800ae3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000ae:	e8 c0 0e 00 00       	call   800f73 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 d2 09 00 00       	call   800a91 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

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
  8000ef:	e8 60 09 00 00       	call   800a54 <sys_cputs>
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
  800157:	e8 f8 08 00 00       	call   800a54 <sys_cputs>

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
  8001d9:	e8 da 1a 00 00       	call   801cb8 <__udivdi3>
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
  80022c:	e8 a7 1b 00 00       	call   801dd8 <__umoddi3>
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	0f be 80 51 1f 80 00 	movsbl 0x801f51(%eax),%eax
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
  8002d9:	0f 84 8b 03 00 00    	je     80066a <vprintfmt+0x3a4>
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
  800347:	0f 87 01 03 00 00    	ja     80064e <vprintfmt+0x388>
  80034d:	0f b6 d2             	movzbl %dl,%edx
  800350:	ff 24 95 a0 20 80 00 	jmp    *0x8020a0(,%edx,4)
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
  8003d9:	83 f8 0f             	cmp    $0xf,%eax
  8003dc:	7f 0b                	jg     8003e9 <vprintfmt+0x123>
  8003de:	8b 04 85 00 22 80 00 	mov    0x802200(,%eax,4),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	75 23                	jne    80040c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ed:	c7 44 24 08 69 1f 80 	movl   $0x801f69,0x8(%esp)
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
  800410:	c7 44 24 08 5a 23 80 	movl   $0x80235a,0x8(%esp)
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
  800446:	be 62 1f 80 00       	mov    $0x801f62,%esi
			if (width > 0 && padc != '-')
  80044b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044f:	0f 8e 84 00 00 00    	jle    8004d9 <vprintfmt+0x213>
  800455:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800459:	74 7e                	je     8004d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80045f:	89 34 24             	mov    %esi,(%esp)
  800462:	e8 ab 02 00 00       	call   800712 <strnlen>
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
  80055f:	e9 ac 00 00 00       	jmp    800610 <vprintfmt+0x34a>

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
  80057e:	e9 8d 00 00 00       	jmp    800610 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800583:	89 ca                	mov    %ecx,%edx
  800585:	8d 45 14             	lea    0x14(%ebp),%eax
  800588:	e8 bd fc ff ff       	call   80024a <getuint>
  80058d:	89 c6                	mov    %eax,%esi
  80058f:	89 d7                	mov    %edx,%edi
			base = 10;
  800591:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800596:	eb 78                	jmp    800610 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005aa:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005c5:	e9 1f fd ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ef:	8b 30                	mov    (%eax),%esi
  8005f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005fb:	eb 13                	jmp    800610 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fd:	89 ca                	mov    %ecx,%edx
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 43 fc ff ff       	call   80024a <getuint>
  800607:	89 c6                	mov    %eax,%esi
  800609:	89 d7                	mov    %edx,%edi
			base = 16;
  80060b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800610:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800614:	89 54 24 10          	mov    %edx,0x10(%esp)
  800618:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062a:	89 da                	mov    %ebx,%edx
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	e8 4c fb ff ff       	call   800180 <printnum>
			break;
  800634:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800637:	e9 ad fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800649:	e9 9b fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800652:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800659:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065c:	eb 01                	jmp    80065f <vprintfmt+0x399>
  80065e:	4e                   	dec    %esi
  80065f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800663:	75 f9                	jne    80065e <vprintfmt+0x398>
  800665:	e9 7f fc ff ff       	jmp    8002e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80066a:	83 c4 4c             	add    $0x4c,%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5f                   	pop    %edi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 28             	sub    $0x28,%esp
  800678:	8b 45 08             	mov    0x8(%ebp),%eax
  80067b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800681:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800685:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068f:	85 c0                	test   %eax,%eax
  800691:	74 30                	je     8006c3 <vsnprintf+0x51>
  800693:	85 d2                	test   %edx,%edx
  800695:	7e 33                	jle    8006ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069e:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  8006b3:	e8 0e fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c1:	eb 0c                	jmp    8006cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c8:	eb 05                	jmp    8006cf <vsnprintf+0x5d>
  8006ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 7b ff ff ff       	call   800672 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    
  8006f9:	00 00                	add    %al,(%eax)
	...

008006fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	eb 01                	jmp    80070a <strlen+0xe>
		n++;
  800709:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070e:	75 f9                	jne    800709 <strlen+0xd>
		n++;
	return n;
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
  800720:	eb 01                	jmp    800723 <strnlen+0x11>
		n++;
  800722:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	39 d0                	cmp    %edx,%eax
  800725:	74 06                	je     80072d <strnlen+0x1b>
  800727:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072b:	75 f5                	jne    800722 <strnlen+0x10>
		n++;
	return n;
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
  80073e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800741:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800744:	42                   	inc    %edx
  800745:	84 c9                	test   %cl,%cl
  800747:	75 f5                	jne    80073e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800749:	5b                   	pop    %ebx
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	89 1c 24             	mov    %ebx,(%esp)
  800759:	e8 9e ff ff ff       	call   8006fc <strlen>
	strcpy(dst + len, src);
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800761:	89 54 24 04          	mov    %edx,0x4(%esp)
  800765:	01 d8                	add    %ebx,%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 c0 ff ff ff       	call   80072f <strcpy>
	return dst;
}
  80076f:	89 d8                	mov    %ebx,%eax
  800771:	83 c4 08             	add    $0x8,%esp
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800782:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800785:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078a:	eb 0c                	jmp    800798 <strncpy+0x21>
		*dst++ = *src;
  80078c:	8a 1a                	mov    (%edx),%bl
  80078e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800791:	80 3a 01             	cmpb   $0x1,(%edx)
  800794:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	41                   	inc    %ecx
  800798:	39 f1                	cmp    %esi,%ecx
  80079a:	75 f0                	jne    80078c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	56                   	push   %esi
  8007a4:	53                   	push   %ebx
  8007a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	75 0a                	jne    8007bc <strlcpy+0x1c>
  8007b2:	89 f0                	mov    %esi,%eax
  8007b4:	eb 1a                	jmp    8007d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b6:	88 18                	mov    %bl,(%eax)
  8007b8:	40                   	inc    %eax
  8007b9:	41                   	inc    %ecx
  8007ba:	eb 02                	jmp    8007be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007be:	4a                   	dec    %edx
  8007bf:	74 0a                	je     8007cb <strlcpy+0x2b>
  8007c1:	8a 19                	mov    (%ecx),%bl
  8007c3:	84 db                	test   %bl,%bl
  8007c5:	75 ef                	jne    8007b6 <strlcpy+0x16>
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	eb 02                	jmp    8007cd <strlcpy+0x2d>
  8007cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007d0:	29 f0                	sub    %esi,%eax
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007df:	eb 02                	jmp    8007e3 <strcmp+0xd>
		p++, q++;
  8007e1:	41                   	inc    %ecx
  8007e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e3:	8a 01                	mov    (%ecx),%al
  8007e5:	84 c0                	test   %al,%al
  8007e7:	74 04                	je     8007ed <strcmp+0x17>
  8007e9:	3a 02                	cmp    (%edx),%al
  8007eb:	74 f4                	je     8007e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	0f b6 c0             	movzbl %al,%eax
  8007f0:	0f b6 12             	movzbl (%edx),%edx
  8007f3:	29 d0                	sub    %edx,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800804:	eb 03                	jmp    800809 <strncmp+0x12>
		n--, p++, q++;
  800806:	4a                   	dec    %edx
  800807:	40                   	inc    %eax
  800808:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 14                	je     800821 <strncmp+0x2a>
  80080d:	8a 18                	mov    (%eax),%bl
  80080f:	84 db                	test   %bl,%bl
  800811:	74 04                	je     800817 <strncmp+0x20>
  800813:	3a 19                	cmp    (%ecx),%bl
  800815:	74 ef                	je     800806 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 00             	movzbl (%eax),%eax
  80081a:	0f b6 11             	movzbl (%ecx),%edx
  80081d:	29 d0                	sub    %edx,%eax
  80081f:	eb 05                	jmp    800826 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800826:	5b                   	pop    %ebx
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800832:	eb 05                	jmp    800839 <strchr+0x10>
		if (*s == c)
  800834:	38 ca                	cmp    %cl,%dl
  800836:	74 0c                	je     800844 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800838:	40                   	inc    %eax
  800839:	8a 10                	mov    (%eax),%dl
  80083b:	84 d2                	test   %dl,%dl
  80083d:	75 f5                	jne    800834 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084f:	eb 05                	jmp    800856 <strfind+0x10>
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 07                	je     80085c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800855:	40                   	inc    %eax
  800856:	8a 10                	mov    (%eax),%dl
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f5                	jne    800851 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
  800867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 30                	je     8008a1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800871:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800877:	75 25                	jne    80089e <memset+0x40>
  800879:	f6 c1 03             	test   $0x3,%cl
  80087c:	75 20                	jne    80089e <memset+0x40>
		c &= 0xFF;
  80087e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800881:	89 d3                	mov    %edx,%ebx
  800883:	c1 e3 08             	shl    $0x8,%ebx
  800886:	89 d6                	mov    %edx,%esi
  800888:	c1 e6 18             	shl    $0x18,%esi
  80088b:	89 d0                	mov    %edx,%eax
  80088d:	c1 e0 10             	shl    $0x10,%eax
  800890:	09 f0                	or     %esi,%eax
  800892:	09 d0                	or     %edx,%eax
  800894:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800896:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 03                	jmp    8008a1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	fc                   	cld    
  80089f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b6:	39 c6                	cmp    %eax,%esi
  8008b8:	73 34                	jae    8008ee <memmove+0x46>
  8008ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bd:	39 d0                	cmp    %edx,%eax
  8008bf:	73 2d                	jae    8008ee <memmove+0x46>
		s += n;
		d += n;
  8008c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c4:	f6 c2 03             	test   $0x3,%dl
  8008c7:	75 1b                	jne    8008e4 <memmove+0x3c>
  8008c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cf:	75 13                	jne    8008e4 <memmove+0x3c>
  8008d1:	f6 c1 03             	test   $0x3,%cl
  8008d4:	75 0e                	jne    8008e4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d6:	83 ef 04             	sub    $0x4,%edi
  8008d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008dc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008df:	fd                   	std    
  8008e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e2:	eb 07                	jmp    8008eb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e4:	4f                   	dec    %edi
  8008e5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e8:	fd                   	std    
  8008e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008eb:	fc                   	cld    
  8008ec:	eb 20                	jmp    80090e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f4:	75 13                	jne    800909 <memmove+0x61>
  8008f6:	a8 03                	test   $0x3,%al
  8008f8:	75 0f                	jne    800909 <memmove+0x61>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0a                	jne    800909 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 05                	jmp    80090e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800918:	8b 45 10             	mov    0x10(%ebp),%eax
  80091b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	89 04 24             	mov    %eax,(%esp)
  80092c:	e8 77 ff ff ff       	call   8008a8 <memmove>
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800942:	ba 00 00 00 00       	mov    $0x0,%edx
  800947:	eb 16                	jmp    80095f <memcmp+0x2c>
		if (*s1 != *s2)
  800949:	8a 04 17             	mov    (%edi,%edx,1),%al
  80094c:	42                   	inc    %edx
  80094d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800951:	38 c8                	cmp    %cl,%al
  800953:	74 0a                	je     80095f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800955:	0f b6 c0             	movzbl %al,%eax
  800958:	0f b6 c9             	movzbl %cl,%ecx
  80095b:	29 c8                	sub    %ecx,%eax
  80095d:	eb 09                	jmp    800968 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095f:	39 da                	cmp    %ebx,%edx
  800961:	75 e6                	jne    800949 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800976:	89 c2                	mov    %eax,%edx
  800978:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097b:	eb 05                	jmp    800982 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097d:	38 08                	cmp    %cl,(%eax)
  80097f:	74 05                	je     800986 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800981:	40                   	inc    %eax
  800982:	39 d0                	cmp    %edx,%eax
  800984:	72 f7                	jb     80097d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 55 08             	mov    0x8(%ebp),%edx
  800991:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800994:	eb 01                	jmp    800997 <strtol+0xf>
		s++;
  800996:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	8a 02                	mov    (%edx),%al
  800999:	3c 20                	cmp    $0x20,%al
  80099b:	74 f9                	je     800996 <strtol+0xe>
  80099d:	3c 09                	cmp    $0x9,%al
  80099f:	74 f5                	je     800996 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a1:	3c 2b                	cmp    $0x2b,%al
  8009a3:	75 08                	jne    8009ad <strtol+0x25>
		s++;
  8009a5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ab:	eb 13                	jmp    8009c0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ad:	3c 2d                	cmp    $0x2d,%al
  8009af:	75 0a                	jne    8009bb <strtol+0x33>
		s++, neg = 1;
  8009b1:	8d 52 01             	lea    0x1(%edx),%edx
  8009b4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b9:	eb 05                	jmp    8009c0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009bb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c0:	85 db                	test   %ebx,%ebx
  8009c2:	74 05                	je     8009c9 <strtol+0x41>
  8009c4:	83 fb 10             	cmp    $0x10,%ebx
  8009c7:	75 28                	jne    8009f1 <strtol+0x69>
  8009c9:	8a 02                	mov    (%edx),%al
  8009cb:	3c 30                	cmp    $0x30,%al
  8009cd:	75 10                	jne    8009df <strtol+0x57>
  8009cf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009d3:	75 0a                	jne    8009df <strtol+0x57>
		s += 2, base = 16;
  8009d5:	83 c2 02             	add    $0x2,%edx
  8009d8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009dd:	eb 12                	jmp    8009f1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009df:	85 db                	test   %ebx,%ebx
  8009e1:	75 0e                	jne    8009f1 <strtol+0x69>
  8009e3:	3c 30                	cmp    $0x30,%al
  8009e5:	75 05                	jne    8009ec <strtol+0x64>
		s++, base = 8;
  8009e7:	42                   	inc    %edx
  8009e8:	b3 08                	mov    $0x8,%bl
  8009ea:	eb 05                	jmp    8009f1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009ec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f8:	8a 0a                	mov    (%edx),%cl
  8009fa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x82>
			dig = *s - '0';
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 30             	sub    $0x30,%ecx
  800a08:	eb 1e                	jmp    800a28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 08                	ja     800a1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a12:	0f be c9             	movsbl %cl,%ecx
  800a15:	83 e9 57             	sub    $0x57,%ecx
  800a18:	eb 0e                	jmp    800a28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 12                	ja     800a34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a22:	0f be c9             	movsbl %cl,%ecx
  800a25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a28:	39 f1                	cmp    %esi,%ecx
  800a2a:	7d 0c                	jge    800a38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a2c:	42                   	inc    %edx
  800a2d:	0f af c6             	imul   %esi,%eax
  800a30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a32:	eb c4                	jmp    8009f8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a34:	89 c1                	mov    %eax,%ecx
  800a36:	eb 02                	jmp    800a3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3e:	74 05                	je     800a45 <strtol+0xbd>
		*endptr = (char *) s;
  800a40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a45:	85 ff                	test   %edi,%edi
  800a47:	74 04                	je     800a4d <strtol+0xc5>
  800a49:	89 c8                	mov    %ecx,%eax
  800a4b:	f7 d8                	neg    %eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    
	...

00800a54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	89 c6                	mov    %eax,%esi
  800a6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a82:	89 d1                	mov    %edx,%ecx
  800a84:	89 d3                	mov    %edx,%ebx
  800a86:	89 d7                	mov    %edx,%edi
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	89 cb                	mov    %ecx,%ebx
  800aa9:	89 cf                	mov    %ecx,%edi
  800aab:	89 ce                	mov    %ecx,%esi
  800aad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	7e 28                	jle    800adb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ab7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800abe:	00 
  800abf:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800ac6:	00 
  800ac7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ace:	00 
  800acf:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800ad6:	e8 29 10 00 00       	call   801b04 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adb:	83 c4 2c             	add    $0x2c,%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 02 00 00 00       	mov    $0x2,%eax
  800af3:	89 d1                	mov    %edx,%ecx
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	89 d7                	mov    %edx,%edi
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_yield>:

void
sys_yield(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	be 00 00 00 00       	mov    $0x0,%esi
  800b2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 f7                	mov    %esi,%edi
  800b3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 28                	jle    800b6d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b49:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b50:	00 
  800b51:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800b58:	00 
  800b59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b60:	00 
  800b61:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800b68:	e8 97 0f 00 00       	call   801b04 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6d:	83 c4 2c             	add    $0x2c,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b83:	8b 75 18             	mov    0x18(%ebp),%esi
  800b86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 28                	jle    800bc0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ba3:	00 
  800ba4:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800bab:	00 
  800bac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb3:	00 
  800bb4:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800bbb:	e8 44 0f 00 00       	call   801b04 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc0:	83 c4 2c             	add    $0x2c,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 df                	mov    %ebx,%edi
  800be3:	89 de                	mov    %ebx,%esi
  800be5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 28                	jle    800c13 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800c0e:	e8 f1 0e 00 00       	call   801b04 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c13:	83 c4 2c             	add    $0x2c,%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c29:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 df                	mov    %ebx,%edi
  800c36:	89 de                	mov    %ebx,%esi
  800c38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 28                	jle    800c66 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c42:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c49:	00 
  800c4a:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800c51:	00 
  800c52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c59:	00 
  800c5a:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800c61:	e8 9e 0e 00 00       	call   801b04 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c66:	83 c4 2c             	add    $0x2c,%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 28                	jle    800cb9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c95:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cac:	00 
  800cad:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800cb4:	e8 4b 0e 00 00       	call   801b04 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	83 c4 2c             	add    $0x2c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 28                	jle    800d0c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cff:	00 
  800d00:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800d07:	e8 f8 0d 00 00       	call   801b04 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0c:	83 c4 2c             	add    $0x2c,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	be 00 00 00 00       	mov    $0x0,%esi
  800d1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 cb                	mov    %ecx,%ebx
  800d4f:	89 cf                	mov    %ecx,%edi
  800d51:	89 ce                	mov    %ecx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 28                	jle    800d81 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d64:	00 
  800d65:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d74:	00 
  800d75:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800d7c:	e8 83 0d 00 00       	call   801b04 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d81:	83 c4 2c             	add    $0x2c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	00 00                	add    %al,(%eax)
	...

00800d8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	05 00 00 00 30       	add    $0x30000000,%eax
  800d97:	c1 e8 0c             	shr    $0xc,%eax
}
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	89 04 24             	mov    %eax,(%esp)
  800da8:	e8 df ff ff ff       	call   800d8c <fd2num>
  800dad:	05 20 00 0d 00       	add    $0xd0020,%eax
  800db2:	c1 e0 0c             	shl    $0xc,%eax
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	53                   	push   %ebx
  800dbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dbe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800dc3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	c1 ea 16             	shr    $0x16,%edx
  800dca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd1:	f6 c2 01             	test   $0x1,%dl
  800dd4:	74 11                	je     800de7 <fd_alloc+0x30>
  800dd6:	89 c2                	mov    %eax,%edx
  800dd8:	c1 ea 0c             	shr    $0xc,%edx
  800ddb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de2:	f6 c2 01             	test   $0x1,%dl
  800de5:	75 09                	jne    800df0 <fd_alloc+0x39>
			*fd_store = fd;
  800de7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	eb 17                	jmp    800e07 <fd_alloc+0x50>
  800df0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800df5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dfa:	75 c7                	jne    800dc3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dfc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e02:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e10:	83 f8 1f             	cmp    $0x1f,%eax
  800e13:	77 36                	ja     800e4b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e15:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e1a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e1d:	89 c2                	mov    %eax,%edx
  800e1f:	c1 ea 16             	shr    $0x16,%edx
  800e22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e29:	f6 c2 01             	test   $0x1,%dl
  800e2c:	74 24                	je     800e52 <fd_lookup+0x48>
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	c1 ea 0c             	shr    $0xc,%edx
  800e33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3a:	f6 c2 01             	test   $0x1,%dl
  800e3d:	74 1a                	je     800e59 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e42:	89 02                	mov    %eax,(%edx)
	return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
  800e49:	eb 13                	jmp    800e5e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e50:	eb 0c                	jmp    800e5e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e57:	eb 05                	jmp    800e5e <fd_lookup+0x54>
  800e59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	53                   	push   %ebx
  800e64:	83 ec 14             	sub    $0x14,%esp
  800e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	eb 0e                	jmp    800e82 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e74:	39 08                	cmp    %ecx,(%eax)
  800e76:	75 09                	jne    800e81 <dev_lookup+0x21>
			*dev = devtab[i];
  800e78:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	eb 33                	jmp    800eb4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e81:	42                   	inc    %edx
  800e82:	8b 04 95 08 23 80 00 	mov    0x802308(,%edx,4),%eax
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	75 e7                	jne    800e74 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e8d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e92:	8b 40 48             	mov    0x48(%eax),%eax
  800e95:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9d:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  800ea4:	e8 bb f2 ff ff       	call   800164 <cprintf>
	*dev = 0;
  800ea9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800eaf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eb4:	83 c4 14             	add    $0x14,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 30             	sub    $0x30,%esp
  800ec2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec5:	8a 45 0c             	mov    0xc(%ebp),%al
  800ec8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ecb:	89 34 24             	mov    %esi,(%esp)
  800ece:	e8 b9 fe ff ff       	call   800d8c <fd2num>
  800ed3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ed6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eda:	89 04 24             	mov    %eax,(%esp)
  800edd:	e8 28 ff ff ff       	call   800e0a <fd_lookup>
  800ee2:	89 c3                	mov    %eax,%ebx
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	78 05                	js     800eed <fd_close+0x33>
	    || fd != fd2)
  800ee8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eeb:	74 0d                	je     800efa <fd_close+0x40>
		return (must_exist ? r : 0);
  800eed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ef1:	75 46                	jne    800f39 <fd_close+0x7f>
  800ef3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef8:	eb 3f                	jmp    800f39 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800efa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800efd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f01:	8b 06                	mov    (%esi),%eax
  800f03:	89 04 24             	mov    %eax,(%esp)
  800f06:	e8 55 ff ff ff       	call   800e60 <dev_lookup>
  800f0b:	89 c3                	mov    %eax,%ebx
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 18                	js     800f29 <fd_close+0x6f>
		if (dev->dev_close)
  800f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f14:	8b 40 10             	mov    0x10(%eax),%eax
  800f17:	85 c0                	test   %eax,%eax
  800f19:	74 09                	je     800f24 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f1b:	89 34 24             	mov    %esi,(%esp)
  800f1e:	ff d0                	call   *%eax
  800f20:	89 c3                	mov    %eax,%ebx
  800f22:	eb 05                	jmp    800f29 <fd_close+0x6f>
		else
			r = 0;
  800f24:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f29:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f34:	e8 8f fc ff ff       	call   800bc8 <sys_page_unmap>
	return r;
}
  800f39:	89 d8                	mov    %ebx,%eax
  800f3b:	83 c4 30             	add    $0x30,%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	89 04 24             	mov    %eax,(%esp)
  800f55:	e8 b0 fe ff ff       	call   800e0a <fd_lookup>
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 13                	js     800f71 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f5e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f65:	00 
  800f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f69:	89 04 24             	mov    %eax,(%esp)
  800f6c:	e8 49 ff ff ff       	call   800eba <fd_close>
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <close_all>:

void
close_all(void)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	53                   	push   %ebx
  800f77:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f7f:	89 1c 24             	mov    %ebx,(%esp)
  800f82:	e8 bb ff ff ff       	call   800f42 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f87:	43                   	inc    %ebx
  800f88:	83 fb 20             	cmp    $0x20,%ebx
  800f8b:	75 f2                	jne    800f7f <close_all+0xc>
		close(i);
}
  800f8d:	83 c4 14             	add    $0x14,%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 4c             	sub    $0x4c,%esp
  800f9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	89 04 24             	mov    %eax,(%esp)
  800fac:	e8 59 fe ff ff       	call   800e0a <fd_lookup>
  800fb1:	89 c3                	mov    %eax,%ebx
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	0f 88 e1 00 00 00    	js     80109c <dup+0x109>
		return r;
	close(newfdnum);
  800fbb:	89 3c 24             	mov    %edi,(%esp)
  800fbe:	e8 7f ff ff ff       	call   800f42 <close>

	newfd = INDEX2FD(newfdnum);
  800fc3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fc9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fcf:	89 04 24             	mov    %eax,(%esp)
  800fd2:	e8 c5 fd ff ff       	call   800d9c <fd2data>
  800fd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fd9:	89 34 24             	mov    %esi,(%esp)
  800fdc:	e8 bb fd ff ff       	call   800d9c <fd2data>
  800fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 16             	shr    $0x16,%eax
  800fe9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff0:	a8 01                	test   $0x1,%al
  800ff2:	74 46                	je     80103a <dup+0xa7>
  800ff4:	89 d8                	mov    %ebx,%eax
  800ff6:	c1 e8 0c             	shr    $0xc,%eax
  800ff9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801000:	f6 c2 01             	test   $0x1,%dl
  801003:	74 35                	je     80103a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801005:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100c:	25 07 0e 00 00       	and    $0xe07,%eax
  801011:	89 44 24 10          	mov    %eax,0x10(%esp)
  801015:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801018:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801023:	00 
  801024:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801028:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102f:	e8 41 fb ff ff       	call   800b75 <sys_page_map>
  801034:	89 c3                	mov    %eax,%ebx
  801036:	85 c0                	test   %eax,%eax
  801038:	78 3b                	js     801075 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	c1 ea 0c             	shr    $0xc,%edx
  801042:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801049:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80104f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801053:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801057:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80105e:	00 
  80105f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106a:	e8 06 fb ff ff       	call   800b75 <sys_page_map>
  80106f:	89 c3                	mov    %eax,%ebx
  801071:	85 c0                	test   %eax,%eax
  801073:	79 25                	jns    80109a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801075:	89 74 24 04          	mov    %esi,0x4(%esp)
  801079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801080:	e8 43 fb ff ff       	call   800bc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801085:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801093:	e8 30 fb ff ff       	call   800bc8 <sys_page_unmap>
	return r;
  801098:	eb 02                	jmp    80109c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80109a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80109c:	89 d8                	mov    %ebx,%eax
  80109e:	83 c4 4c             	add    $0x4c,%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 24             	sub    $0x24,%esp
  8010ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b7:	89 1c 24             	mov    %ebx,(%esp)
  8010ba:	e8 4b fd ff ff       	call   800e0a <fd_lookup>
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 6d                	js     801130 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cd:	8b 00                	mov    (%eax),%eax
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	e8 89 fd ff ff       	call   800e60 <dev_lookup>
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 55                	js     801130 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010de:	8b 50 08             	mov    0x8(%eax),%edx
  8010e1:	83 e2 03             	and    $0x3,%edx
  8010e4:	83 fa 01             	cmp    $0x1,%edx
  8010e7:	75 23                	jne    80110c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ee:	8b 40 48             	mov    0x48(%eax),%eax
  8010f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	c7 04 24 cd 22 80 00 	movl   $0x8022cd,(%esp)
  801100:	e8 5f f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  801105:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110a:	eb 24                	jmp    801130 <read+0x8a>
	}
	if (!dev->dev_read)
  80110c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80110f:	8b 52 08             	mov    0x8(%edx),%edx
  801112:	85 d2                	test   %edx,%edx
  801114:	74 15                	je     80112b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801116:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801119:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80111d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801120:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	ff d2                	call   *%edx
  801129:	eb 05                	jmp    801130 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80112b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801130:	83 c4 24             	add    $0x24,%esp
  801133:	5b                   	pop    %ebx
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 1c             	sub    $0x1c,%esp
  80113f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801142:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801145:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114a:	eb 23                	jmp    80116f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114c:	89 f0                	mov    %esi,%eax
  80114e:	29 d8                	sub    %ebx,%eax
  801150:	89 44 24 08          	mov    %eax,0x8(%esp)
  801154:	8b 45 0c             	mov    0xc(%ebp),%eax
  801157:	01 d8                	add    %ebx,%eax
  801159:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115d:	89 3c 24             	mov    %edi,(%esp)
  801160:	e8 41 ff ff ff       	call   8010a6 <read>
		if (m < 0)
  801165:	85 c0                	test   %eax,%eax
  801167:	78 10                	js     801179 <readn+0x43>
			return m;
		if (m == 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	74 0a                	je     801177 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116d:	01 c3                	add    %eax,%ebx
  80116f:	39 f3                	cmp    %esi,%ebx
  801171:	72 d9                	jb     80114c <readn+0x16>
  801173:	89 d8                	mov    %ebx,%eax
  801175:	eb 02                	jmp    801179 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801177:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801179:	83 c4 1c             	add    $0x1c,%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	53                   	push   %ebx
  801185:	83 ec 24             	sub    $0x24,%esp
  801188:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801192:	89 1c 24             	mov    %ebx,(%esp)
  801195:	e8 70 fc ff ff       	call   800e0a <fd_lookup>
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 68                	js     801206 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a8:	8b 00                	mov    (%eax),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 ae fc ff ff       	call   800e60 <dev_lookup>
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 50                	js     801206 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bd:	75 23                	jne    8011e2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cf:	c7 04 24 e9 22 80 00 	movl   $0x8022e9,(%esp)
  8011d6:	e8 89 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8011db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e0:	eb 24                	jmp    801206 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e8:	85 d2                	test   %edx,%edx
  8011ea:	74 15                	je     801201 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011fa:	89 04 24             	mov    %eax,(%esp)
  8011fd:	ff d2                	call   *%edx
  8011ff:	eb 05                	jmp    801206 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801201:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801206:	83 c4 24             	add    $0x24,%esp
  801209:	5b                   	pop    %ebx
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <seek>:

int
seek(int fdnum, off_t offset)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801212:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801215:	89 44 24 04          	mov    %eax,0x4(%esp)
  801219:	8b 45 08             	mov    0x8(%ebp),%eax
  80121c:	89 04 24             	mov    %eax,(%esp)
  80121f:	e8 e6 fb ff ff       	call   800e0a <fd_lookup>
  801224:	85 c0                	test   %eax,%eax
  801226:	78 0e                	js     801236 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801228:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80122b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 24             	sub    $0x24,%esp
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801242:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	89 1c 24             	mov    %ebx,(%esp)
  80124c:	e8 b9 fb ff ff       	call   800e0a <fd_lookup>
  801251:	85 c0                	test   %eax,%eax
  801253:	78 61                	js     8012b6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	8b 00                	mov    (%eax),%eax
  801261:	89 04 24             	mov    %eax,(%esp)
  801264:	e8 f7 fb ff ff       	call   800e60 <dev_lookup>
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 49                	js     8012b6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801274:	75 23                	jne    801299 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801276:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  80128d:	e8 d2 ee ff ff       	call   800164 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb 1d                	jmp    8012b6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801299:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129c:	8b 52 18             	mov    0x18(%edx),%edx
  80129f:	85 d2                	test   %edx,%edx
  8012a1:	74 0e                	je     8012b1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012aa:	89 04 24             	mov    %eax,(%esp)
  8012ad:	ff d2                	call   *%edx
  8012af:	eb 05                	jmp    8012b6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b6:	83 c4 24             	add    $0x24,%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 24             	sub    $0x24,%esp
  8012c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 32 fb ff ff       	call   800e0a <fd_lookup>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 52                	js     80132e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e6:	8b 00                	mov    (%eax),%eax
  8012e8:	89 04 24             	mov    %eax,(%esp)
  8012eb:	e8 70 fb ff ff       	call   800e60 <dev_lookup>
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 3a                	js     80132e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8012f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fb:	74 2c                	je     801329 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801300:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801307:	00 00 00 
	stat->st_isdir = 0;
  80130a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801311:	00 00 00 
	stat->st_dev = dev;
  801314:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80131e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801321:	89 14 24             	mov    %edx,(%esp)
  801324:	ff 50 14             	call   *0x14(%eax)
  801327:	eb 05                	jmp    80132e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801329:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80132e:	83 c4 24             	add    $0x24,%esp
  801331:	5b                   	pop    %ebx
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80133c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801343:	00 
  801344:	8b 45 08             	mov    0x8(%ebp),%eax
  801347:	89 04 24             	mov    %eax,(%esp)
  80134a:	e8 fe 01 00 00       	call   80154d <open>
  80134f:	89 c3                	mov    %eax,%ebx
  801351:	85 c0                	test   %eax,%eax
  801353:	78 1b                	js     801370 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801355:	8b 45 0c             	mov    0xc(%ebp),%eax
  801358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135c:	89 1c 24             	mov    %ebx,(%esp)
  80135f:	e8 58 ff ff ff       	call   8012bc <fstat>
  801364:	89 c6                	mov    %eax,%esi
	close(fd);
  801366:	89 1c 24             	mov    %ebx,(%esp)
  801369:	e8 d4 fb ff ff       	call   800f42 <close>
	return r;
  80136e:	89 f3                	mov    %esi,%ebx
}
  801370:	89 d8                	mov    %ebx,%eax
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
  801379:	00 00                	add    %al,(%eax)
	...

0080137c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 10             	sub    $0x10,%esp
  801384:	89 c3                	mov    %eax,%ebx
  801386:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801388:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80138f:	75 11                	jne    8013a2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801391:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801398:	e8 90 08 00 00       	call   801c2d <ipc_find_env>
  80139d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013a9:	00 
  8013aa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013b1:	00 
  8013b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 00 08 00 00       	call   801bc3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013ca:	00 
  8013cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d6:	e8 81 07 00 00       	call   801b5c <ipc_recv>
}
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801400:	b8 02 00 00 00       	mov    $0x2,%eax
  801405:	e8 72 ff ff ff       	call   80137c <fsipc>
}
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801412:	8b 45 08             	mov    0x8(%ebp),%eax
  801415:	8b 40 0c             	mov    0xc(%eax),%eax
  801418:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 06 00 00 00       	mov    $0x6,%eax
  801427:	e8 50 ff ff ff       	call   80137c <fsipc>
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 14             	sub    $0x14,%esp
  801435:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	8b 40 0c             	mov    0xc(%eax),%eax
  80143e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 05 00 00 00       	mov    $0x5,%eax
  80144d:	e8 2a ff ff ff       	call   80137c <fsipc>
  801452:	85 c0                	test   %eax,%eax
  801454:	78 2b                	js     801481 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801456:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80145d:	00 
  80145e:	89 1c 24             	mov    %ebx,(%esp)
  801461:	e8 c9 f2 ff ff       	call   80072f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801466:	a1 80 50 80 00       	mov    0x805080,%eax
  80146b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801471:	a1 84 50 80 00       	mov    0x805084,%eax
  801476:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801481:	83 c4 14             	add    $0x14,%esp
  801484:	5b                   	pop    %ebx
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80148d:	c7 44 24 08 18 23 80 	movl   $0x802318,0x8(%esp)
  801494:	00 
  801495:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80149c:	00 
  80149d:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  8014a4:	e8 5b 06 00 00       	call   801b04 <_panic>

008014a9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 10             	sub    $0x10,%esp
  8014b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014bf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8014cf:	e8 a8 fe ff ff       	call   80137c <fsipc>
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 6a                	js     801544 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8014da:	39 c6                	cmp    %eax,%esi
  8014dc:	73 24                	jae    801502 <devfile_read+0x59>
  8014de:	c7 44 24 0c 41 23 80 	movl   $0x802341,0xc(%esp)
  8014e5:	00 
  8014e6:	c7 44 24 08 48 23 80 	movl   $0x802348,0x8(%esp)
  8014ed:	00 
  8014ee:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8014f5:	00 
  8014f6:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  8014fd:	e8 02 06 00 00       	call   801b04 <_panic>
	assert(r <= PGSIZE);
  801502:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801507:	7e 24                	jle    80152d <devfile_read+0x84>
  801509:	c7 44 24 0c 5d 23 80 	movl   $0x80235d,0xc(%esp)
  801510:	00 
  801511:	c7 44 24 08 48 23 80 	movl   $0x802348,0x8(%esp)
  801518:	00 
  801519:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801520:	00 
  801521:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  801528:	e8 d7 05 00 00       	call   801b04 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80152d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801531:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801538:	00 
  801539:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 64 f3 ff ff       	call   8008a8 <memmove>
	return r;
}
  801544:	89 d8                	mov    %ebx,%eax
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	83 ec 20             	sub    $0x20,%esp
  801555:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801558:	89 34 24             	mov    %esi,(%esp)
  80155b:	e8 9c f1 ff ff       	call   8006fc <strlen>
  801560:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801565:	7f 60                	jg     8015c7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801567:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156a:	89 04 24             	mov    %eax,(%esp)
  80156d:	e8 45 f8 ff ff       	call   800db7 <fd_alloc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	85 c0                	test   %eax,%eax
  801576:	78 54                	js     8015cc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801578:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801583:	e8 a7 f1 ff ff       	call   80072f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801590:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801593:	b8 01 00 00 00       	mov    $0x1,%eax
  801598:	e8 df fd ff ff       	call   80137c <fsipc>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	79 15                	jns    8015b8 <open+0x6b>
		fd_close(fd, 0);
  8015a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015aa:	00 
  8015ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ae:	89 04 24             	mov    %eax,(%esp)
  8015b1:	e8 04 f9 ff ff       	call   800eba <fd_close>
		return r;
  8015b6:	eb 14                	jmp    8015cc <open+0x7f>
	}

	return fd2num(fd);
  8015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bb:	89 04 24             	mov    %eax,(%esp)
  8015be:	e8 c9 f7 ff ff       	call   800d8c <fd2num>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	eb 05                	jmp    8015cc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015c7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	83 c4 20             	add    $0x20,%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015db:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015e5:	e8 92 fd ff ff       	call   80137c <fsipc>
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 10             	sub    $0x10,%esp
  8015f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	89 04 24             	mov    %eax,(%esp)
  8015fd:	e8 9a f7 ff ff       	call   800d9c <fd2data>
  801602:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801604:	c7 44 24 04 69 23 80 	movl   $0x802369,0x4(%esp)
  80160b:	00 
  80160c:	89 34 24             	mov    %esi,(%esp)
  80160f:	e8 1b f1 ff ff       	call   80072f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801614:	8b 43 04             	mov    0x4(%ebx),%eax
  801617:	2b 03                	sub    (%ebx),%eax
  801619:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80161f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801626:	00 00 00 
	stat->st_dev = &devpipe;
  801629:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801630:	30 80 00 
	return 0;
}
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801649:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80164d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801654:	e8 6f f5 ff ff       	call   800bc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801659:	89 1c 24             	mov    %ebx,(%esp)
  80165c:	e8 3b f7 ff ff       	call   800d9c <fd2data>
  801661:	89 44 24 04          	mov    %eax,0x4(%esp)
  801665:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166c:	e8 57 f5 ff ff       	call   800bc8 <sys_page_unmap>
}
  801671:	83 c4 14             	add    $0x14,%esp
  801674:	5b                   	pop    %ebx
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	57                   	push   %edi
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	83 ec 2c             	sub    $0x2c,%esp
  801680:	89 c7                	mov    %eax,%edi
  801682:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801685:	a1 04 40 80 00       	mov    0x804004,%eax
  80168a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80168d:	89 3c 24             	mov    %edi,(%esp)
  801690:	e8 df 05 00 00       	call   801c74 <pageref>
  801695:	89 c6                	mov    %eax,%esi
  801697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80169a:	89 04 24             	mov    %eax,(%esp)
  80169d:	e8 d2 05 00 00       	call   801c74 <pageref>
  8016a2:	39 c6                	cmp    %eax,%esi
  8016a4:	0f 94 c0             	sete   %al
  8016a7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016aa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016b0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016b3:	39 cb                	cmp    %ecx,%ebx
  8016b5:	75 08                	jne    8016bf <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016b7:	83 c4 2c             	add    $0x2c,%esp
  8016ba:	5b                   	pop    %ebx
  8016bb:	5e                   	pop    %esi
  8016bc:	5f                   	pop    %edi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016bf:	83 f8 01             	cmp    $0x1,%eax
  8016c2:	75 c1                	jne    801685 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016c4:	8b 42 58             	mov    0x58(%edx),%eax
  8016c7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016ce:	00 
  8016cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d7:	c7 04 24 70 23 80 00 	movl   $0x802370,(%esp)
  8016de:	e8 81 ea ff ff       	call   800164 <cprintf>
  8016e3:	eb a0                	jmp    801685 <_pipeisclosed+0xe>

008016e5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	57                   	push   %edi
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 1c             	sub    $0x1c,%esp
  8016ee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016f1:	89 34 24             	mov    %esi,(%esp)
  8016f4:	e8 a3 f6 ff ff       	call   800d9c <fd2data>
  8016f9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801700:	eb 3c                	jmp    80173e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801702:	89 da                	mov    %ebx,%edx
  801704:	89 f0                	mov    %esi,%eax
  801706:	e8 6c ff ff ff       	call   801677 <_pipeisclosed>
  80170b:	85 c0                	test   %eax,%eax
  80170d:	75 38                	jne    801747 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80170f:	e8 ee f3 ff ff       	call   800b02 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801714:	8b 43 04             	mov    0x4(%ebx),%eax
  801717:	8b 13                	mov    (%ebx),%edx
  801719:	83 c2 20             	add    $0x20,%edx
  80171c:	39 d0                	cmp    %edx,%eax
  80171e:	73 e2                	jae    801702 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801720:	8b 55 0c             	mov    0xc(%ebp),%edx
  801723:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801726:	89 c2                	mov    %eax,%edx
  801728:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80172e:	79 05                	jns    801735 <devpipe_write+0x50>
  801730:	4a                   	dec    %edx
  801731:	83 ca e0             	or     $0xffffffe0,%edx
  801734:	42                   	inc    %edx
  801735:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801739:	40                   	inc    %eax
  80173a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173d:	47                   	inc    %edi
  80173e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801741:	75 d1                	jne    801714 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801743:	89 f8                	mov    %edi,%eax
  801745:	eb 05                	jmp    80174c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80174c:	83 c4 1c             	add    $0x1c,%esp
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5f                   	pop    %edi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	57                   	push   %edi
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	83 ec 1c             	sub    $0x1c,%esp
  80175d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801760:	89 3c 24             	mov    %edi,(%esp)
  801763:	e8 34 f6 ff ff       	call   800d9c <fd2data>
  801768:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176a:	be 00 00 00 00       	mov    $0x0,%esi
  80176f:	eb 3a                	jmp    8017ab <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801771:	85 f6                	test   %esi,%esi
  801773:	74 04                	je     801779 <devpipe_read+0x25>
				return i;
  801775:	89 f0                	mov    %esi,%eax
  801777:	eb 40                	jmp    8017b9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801779:	89 da                	mov    %ebx,%edx
  80177b:	89 f8                	mov    %edi,%eax
  80177d:	e8 f5 fe ff ff       	call   801677 <_pipeisclosed>
  801782:	85 c0                	test   %eax,%eax
  801784:	75 2e                	jne    8017b4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801786:	e8 77 f3 ff ff       	call   800b02 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80178b:	8b 03                	mov    (%ebx),%eax
  80178d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801790:	74 df                	je     801771 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801792:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801797:	79 05                	jns    80179e <devpipe_read+0x4a>
  801799:	48                   	dec    %eax
  80179a:	83 c8 e0             	or     $0xffffffe0,%eax
  80179d:	40                   	inc    %eax
  80179e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017a8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017aa:	46                   	inc    %esi
  8017ab:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017ae:	75 db                	jne    80178b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017b0:	89 f0                	mov    %esi,%eax
  8017b2:	eb 05                	jmp    8017b9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b9:	83 c4 1c             	add    $0x1c,%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5f                   	pop    %edi
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    

008017c1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	57                   	push   %edi
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 3c             	sub    $0x3c,%esp
  8017ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	e8 df f5 ff ff       	call   800db7 <fd_alloc>
  8017d8:	89 c3                	mov    %eax,%ebx
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	0f 88 45 01 00 00    	js     801927 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017e9:	00 
  8017ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f8:	e8 24 f3 ff ff       	call   800b21 <sys_page_alloc>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	85 c0                	test   %eax,%eax
  801801:	0f 88 20 01 00 00    	js     801927 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801807:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	e8 a5 f5 ff ff       	call   800db7 <fd_alloc>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	85 c0                	test   %eax,%eax
  801816:	0f 88 f8 00 00 00    	js     801914 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801823:	00 
  801824:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801832:	e8 ea f2 ff ff       	call   800b21 <sys_page_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	85 c0                	test   %eax,%eax
  80183b:	0f 88 d3 00 00 00    	js     801914 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801844:	89 04 24             	mov    %eax,(%esp)
  801847:	e8 50 f5 ff ff       	call   800d9c <fd2data>
  80184c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80184e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801855:	00 
  801856:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801861:	e8 bb f2 ff ff       	call   800b21 <sys_page_alloc>
  801866:	89 c3                	mov    %eax,%ebx
  801868:	85 c0                	test   %eax,%eax
  80186a:	0f 88 91 00 00 00    	js     801901 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801870:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 21 f5 ff ff       	call   800d9c <fd2data>
  80187b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801882:	00 
  801883:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801887:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80188e:	00 
  80188f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801893:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80189a:	e8 d6 f2 ff ff       	call   800b75 <sys_page_map>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 4c                	js     8018f1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018a5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018c3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018c8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018d2:	89 04 24             	mov    %eax,(%esp)
  8018d5:	e8 b2 f4 ff ff       	call   800d8c <fd2num>
  8018da:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018df:	89 04 24             	mov    %eax,(%esp)
  8018e2:	e8 a5 f4 ff ff       	call   800d8c <fd2num>
  8018e7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ef:	eb 36                	jmp    801927 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fc:	e8 c7 f2 ff ff       	call   800bc8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801901:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801904:	89 44 24 04          	mov    %eax,0x4(%esp)
  801908:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190f:	e8 b4 f2 ff ff       	call   800bc8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801922:	e8 a1 f2 ff ff       	call   800bc8 <sys_page_unmap>
    err:
	return r;
}
  801927:	89 d8                	mov    %ebx,%eax
  801929:	83 c4 3c             	add    $0x3c,%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5f                   	pop    %edi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801937:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	89 04 24             	mov    %eax,(%esp)
  801944:	e8 c1 f4 ff ff       	call   800e0a <fd_lookup>
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 15                	js     801962 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80194d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801950:	89 04 24             	mov    %eax,(%esp)
  801953:	e8 44 f4 ff ff       	call   800d9c <fd2data>
	return _pipeisclosed(fd, p);
  801958:	89 c2                	mov    %eax,%edx
  80195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195d:	e8 15 fd ff ff       	call   801677 <_pipeisclosed>
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801974:	c7 44 24 04 88 23 80 	movl   $0x802388,0x4(%esp)
  80197b:	00 
  80197c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197f:	89 04 24             	mov    %eax,(%esp)
  801982:	e8 a8 ed ff ff       	call   80072f <strcpy>
	return 0;
}
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80199a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80199f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a5:	eb 30                	jmp    8019d7 <devcons_write+0x49>
		m = n - tot;
  8019a7:	8b 75 10             	mov    0x10(%ebp),%esi
  8019aa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019ac:	83 fe 7f             	cmp    $0x7f,%esi
  8019af:	76 05                	jbe    8019b6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019b1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019b6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019ba:	03 45 0c             	add    0xc(%ebp),%eax
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	89 3c 24             	mov    %edi,(%esp)
  8019c4:	e8 df ee ff ff       	call   8008a8 <memmove>
		sys_cputs(buf, m);
  8019c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019cd:	89 3c 24             	mov    %edi,(%esp)
  8019d0:	e8 7f f0 ff ff       	call   800a54 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d5:	01 f3                	add    %esi,%ebx
  8019d7:	89 d8                	mov    %ebx,%eax
  8019d9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019dc:	72 c9                	jb     8019a7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019de:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5f                   	pop    %edi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019f3:	75 07                	jne    8019fc <devcons_read+0x13>
  8019f5:	eb 25                	jmp    801a1c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019f7:	e8 06 f1 ff ff       	call   800b02 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019fc:	e8 71 f0 ff ff       	call   800a72 <sys_cgetc>
  801a01:	85 c0                	test   %eax,%eax
  801a03:	74 f2                	je     8019f7 <devcons_read+0xe>
  801a05:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 1d                	js     801a28 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a0b:	83 f8 04             	cmp    $0x4,%eax
  801a0e:	74 13                	je     801a23 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a13:	88 10                	mov    %dl,(%eax)
	return 1;
  801a15:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1a:	eb 0c                	jmp    801a28 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a21:	eb 05                	jmp    801a28 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a3d:	00 
  801a3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a41:	89 04 24             	mov    %eax,(%esp)
  801a44:	e8 0b f0 ff ff       	call   800a54 <sys_cputs>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <getchar>:

int
getchar(void)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a51:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a58:	00 
  801a59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a67:	e8 3a f6 ff ff       	call   8010a6 <read>
	if (r < 0)
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 0f                	js     801a7f <getchar+0x34>
		return r;
	if (r < 1)
  801a70:	85 c0                	test   %eax,%eax
  801a72:	7e 06                	jle    801a7a <getchar+0x2f>
		return -E_EOF;
	return c;
  801a74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a78:	eb 05                	jmp    801a7f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 71 f3 ff ff       	call   800e0a <fd_lookup>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 11                	js     801aae <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aa6:	39 10                	cmp    %edx,(%eax)
  801aa8:	0f 94 c0             	sete   %al
  801aab:	0f b6 c0             	movzbl %al,%eax
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <opencons>:

int
opencons(void)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab9:	89 04 24             	mov    %eax,(%esp)
  801abc:	e8 f6 f2 ff ff       	call   800db7 <fd_alloc>
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	78 3c                	js     801b01 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ac5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801acc:	00 
  801acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801adb:	e8 41 f0 ff ff       	call   800b21 <sys_page_alloc>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 1d                	js     801b01 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ae4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801af9:	89 04 24             	mov    %eax,(%esp)
  801afc:	e8 8b f2 ff ff       	call   800d8c <fd2num>
}
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    
	...

00801b04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b0c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b0f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b15:	e8 c9 ef ff ff       	call   800ae3 <sys_getenvid>
  801b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b21:	8b 55 08             	mov    0x8(%ebp),%edx
  801b24:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b30:	c7 04 24 94 23 80 00 	movl   $0x802394,(%esp)
  801b37:	e8 28 e6 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b40:	8b 45 10             	mov    0x10(%ebp),%eax
  801b43:	89 04 24             	mov    %eax,(%esp)
  801b46:	e8 b8 e5 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  801b4b:	c7 04 24 81 23 80 00 	movl   $0x802381,(%esp)
  801b52:	e8 0d e6 ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b57:	cc                   	int3   
  801b58:	eb fd                	jmp    801b57 <_panic+0x53>
	...

00801b5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	83 ec 10             	sub    $0x10,%esp
  801b64:	8b 75 08             	mov    0x8(%ebp),%esi
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	75 05                	jne    801b76 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b71:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 b9 f1 ff ff       	call   800d37 <sys_ipc_recv>
	if (!err) {
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	75 26                	jne    801ba8 <ipc_recv+0x4c>
		if (from_env_store) {
  801b82:	85 f6                	test   %esi,%esi
  801b84:	74 0a                	je     801b90 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b86:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8b:	8b 40 74             	mov    0x74(%eax),%eax
  801b8e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b90:	85 db                	test   %ebx,%ebx
  801b92:	74 0a                	je     801b9e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801b94:	a1 04 40 80 00       	mov    0x804004,%eax
  801b99:	8b 40 78             	mov    0x78(%eax),%eax
  801b9c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801b9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba3:	8b 40 70             	mov    0x70(%eax),%eax
  801ba6:	eb 14                	jmp    801bbc <ipc_recv+0x60>
	}
	if (from_env_store) {
  801ba8:	85 f6                	test   %esi,%esi
  801baa:	74 06                	je     801bb2 <ipc_recv+0x56>
		*from_env_store = 0;
  801bac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801bb2:	85 db                	test   %ebx,%ebx
  801bb4:	74 06                	je     801bbc <ipc_recv+0x60>
		*perm_store = 0;
  801bb6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	57                   	push   %edi
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	83 ec 1c             	sub    $0x1c,%esp
  801bcc:	8b 75 10             	mov    0x10(%ebp),%esi
  801bcf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bd2:	85 f6                	test   %esi,%esi
  801bd4:	75 05                	jne    801bdb <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801bd6:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801bdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bdf:	89 74 24 08          	mov    %esi,0x8(%esp)
  801be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 1f f1 ff ff       	call   800d14 <sys_ipc_try_send>
  801bf5:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801bf7:	e8 06 ef ff ff       	call   800b02 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801bfc:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801bff:	74 da                	je     801bdb <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801c01:	85 db                	test   %ebx,%ebx
  801c03:	74 20                	je     801c25 <ipc_send+0x62>
		panic("send fail: %e", err);
  801c05:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c09:	c7 44 24 08 b8 23 80 	movl   $0x8023b8,0x8(%esp)
  801c10:	00 
  801c11:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c18:	00 
  801c19:	c7 04 24 c6 23 80 00 	movl   $0x8023c6,(%esp)
  801c20:	e8 df fe ff ff       	call   801b04 <_panic>
	}
	return;
}
  801c25:	83 c4 1c             	add    $0x1c,%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5f                   	pop    %edi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	53                   	push   %ebx
  801c31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c39:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	c1 e2 07             	shl    $0x7,%edx
  801c45:	29 ca                	sub    %ecx,%edx
  801c47:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c4d:	8b 52 50             	mov    0x50(%edx),%edx
  801c50:	39 da                	cmp    %ebx,%edx
  801c52:	75 0f                	jne    801c63 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c54:	c1 e0 07             	shl    $0x7,%eax
  801c57:	29 c8                	sub    %ecx,%eax
  801c59:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c5e:	8b 40 40             	mov    0x40(%eax),%eax
  801c61:	eb 0c                	jmp    801c6f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c63:	40                   	inc    %eax
  801c64:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c69:	75 ce                	jne    801c39 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c6b:	66 b8 00 00          	mov    $0x0,%ax
}
  801c6f:	5b                   	pop    %ebx
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
	...

00801c74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c7a:	89 c2                	mov    %eax,%edx
  801c7c:	c1 ea 16             	shr    $0x16,%edx
  801c7f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c86:	f6 c2 01             	test   $0x1,%dl
  801c89:	74 1e                	je     801ca9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c8b:	c1 e8 0c             	shr    $0xc,%eax
  801c8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c95:	a8 01                	test   $0x1,%al
  801c97:	74 17                	je     801cb0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c99:	c1 e8 0c             	shr    $0xc,%eax
  801c9c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ca3:	ef 
  801ca4:	0f b7 c0             	movzwl %ax,%eax
  801ca7:	eb 0c                	jmp    801cb5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cae:	eb 05                	jmp    801cb5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    
	...

00801cb8 <__udivdi3>:
  801cb8:	55                   	push   %ebp
  801cb9:	57                   	push   %edi
  801cba:	56                   	push   %esi
  801cbb:	83 ec 10             	sub    $0x10,%esp
  801cbe:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cce:	89 cd                	mov    %ecx,%ebp
  801cd0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	75 2c                	jne    801d04 <__udivdi3+0x4c>
  801cd8:	39 f9                	cmp    %edi,%ecx
  801cda:	77 68                	ja     801d44 <__udivdi3+0x8c>
  801cdc:	85 c9                	test   %ecx,%ecx
  801cde:	75 0b                	jne    801ceb <__udivdi3+0x33>
  801ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce5:	31 d2                	xor    %edx,%edx
  801ce7:	f7 f1                	div    %ecx
  801ce9:	89 c1                	mov    %eax,%ecx
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	89 f8                	mov    %edi,%eax
  801cef:	f7 f1                	div    %ecx
  801cf1:	89 c7                	mov    %eax,%edi
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	f7 f1                	div    %ecx
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	89 fa                	mov    %edi,%edx
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    
  801d04:	39 f8                	cmp    %edi,%eax
  801d06:	77 2c                	ja     801d34 <__udivdi3+0x7c>
  801d08:	0f bd f0             	bsr    %eax,%esi
  801d0b:	83 f6 1f             	xor    $0x1f,%esi
  801d0e:	75 4c                	jne    801d5c <__udivdi3+0xa4>
  801d10:	39 f8                	cmp    %edi,%eax
  801d12:	bf 00 00 00 00       	mov    $0x0,%edi
  801d17:	72 0a                	jb     801d23 <__udivdi3+0x6b>
  801d19:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d1d:	0f 87 ad 00 00 00    	ja     801dd0 <__udivdi3+0x118>
  801d23:	be 01 00 00 00       	mov    $0x1,%esi
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    
  801d33:	90                   	nop
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	31 f6                	xor    %esi,%esi
  801d38:	89 f0                	mov    %esi,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    
  801d43:	90                   	nop
  801d44:	89 fa                	mov    %edi,%edx
  801d46:	89 f0                	mov    %esi,%eax
  801d48:	f7 f1                	div    %ecx
  801d4a:	89 c6                	mov    %eax,%esi
  801d4c:	31 ff                	xor    %edi,%edi
  801d4e:	89 f0                	mov    %esi,%eax
  801d50:	89 fa                	mov    %edi,%edx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d 76 00             	lea    0x0(%esi),%esi
  801d5c:	89 f1                	mov    %esi,%ecx
  801d5e:	d3 e0                	shl    %cl,%eax
  801d60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d64:	b8 20 00 00 00       	mov    $0x20,%eax
  801d69:	29 f0                	sub    %esi,%eax
  801d6b:	89 ea                	mov    %ebp,%edx
  801d6d:	88 c1                	mov    %al,%cl
  801d6f:	d3 ea                	shr    %cl,%edx
  801d71:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d75:	09 ca                	or     %ecx,%edx
  801d77:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d7b:	89 f1                	mov    %esi,%ecx
  801d7d:	d3 e5                	shl    %cl,%ebp
  801d7f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d83:	89 fd                	mov    %edi,%ebp
  801d85:	88 c1                	mov    %al,%cl
  801d87:	d3 ed                	shr    %cl,%ebp
  801d89:	89 fa                	mov    %edi,%edx
  801d8b:	89 f1                	mov    %esi,%ecx
  801d8d:	d3 e2                	shl    %cl,%edx
  801d8f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d93:	88 c1                	mov    %al,%cl
  801d95:	d3 ef                	shr    %cl,%edi
  801d97:	09 d7                	or     %edx,%edi
  801d99:	89 f8                	mov    %edi,%eax
  801d9b:	89 ea                	mov    %ebp,%edx
  801d9d:	f7 74 24 08          	divl   0x8(%esp)
  801da1:	89 d1                	mov    %edx,%ecx
  801da3:	89 c7                	mov    %eax,%edi
  801da5:	f7 64 24 0c          	mull   0xc(%esp)
  801da9:	39 d1                	cmp    %edx,%ecx
  801dab:	72 17                	jb     801dc4 <__udivdi3+0x10c>
  801dad:	74 09                	je     801db8 <__udivdi3+0x100>
  801daf:	89 fe                	mov    %edi,%esi
  801db1:	31 ff                	xor    %edi,%edi
  801db3:	e9 41 ff ff ff       	jmp    801cf9 <__udivdi3+0x41>
  801db8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dbc:	89 f1                	mov    %esi,%ecx
  801dbe:	d3 e2                	shl    %cl,%edx
  801dc0:	39 c2                	cmp    %eax,%edx
  801dc2:	73 eb                	jae    801daf <__udivdi3+0xf7>
  801dc4:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dc7:	31 ff                	xor    %edi,%edi
  801dc9:	e9 2b ff ff ff       	jmp    801cf9 <__udivdi3+0x41>
  801dce:	66 90                	xchg   %ax,%ax
  801dd0:	31 f6                	xor    %esi,%esi
  801dd2:	e9 22 ff ff ff       	jmp    801cf9 <__udivdi3+0x41>
	...

00801dd8 <__umoddi3>:
  801dd8:	55                   	push   %ebp
  801dd9:	57                   	push   %edi
  801dda:	56                   	push   %esi
  801ddb:	83 ec 20             	sub    $0x20,%esp
  801dde:	8b 44 24 30          	mov    0x30(%esp),%eax
  801de2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801de6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dea:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801df2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801df6:	89 c7                	mov    %eax,%edi
  801df8:	89 f2                	mov    %esi,%edx
  801dfa:	85 ed                	test   %ebp,%ebp
  801dfc:	75 16                	jne    801e14 <__umoddi3+0x3c>
  801dfe:	39 f1                	cmp    %esi,%ecx
  801e00:	0f 86 a6 00 00 00    	jbe    801eac <__umoddi3+0xd4>
  801e06:	f7 f1                	div    %ecx
  801e08:	89 d0                	mov    %edx,%eax
  801e0a:	31 d2                	xor    %edx,%edx
  801e0c:	83 c4 20             	add    $0x20,%esp
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
  801e13:	90                   	nop
  801e14:	39 f5                	cmp    %esi,%ebp
  801e16:	0f 87 ac 00 00 00    	ja     801ec8 <__umoddi3+0xf0>
  801e1c:	0f bd c5             	bsr    %ebp,%eax
  801e1f:	83 f0 1f             	xor    $0x1f,%eax
  801e22:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e26:	0f 84 a8 00 00 00    	je     801ed4 <__umoddi3+0xfc>
  801e2c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e30:	d3 e5                	shl    %cl,%ebp
  801e32:	bf 20 00 00 00       	mov    $0x20,%edi
  801e37:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e3f:	89 f9                	mov    %edi,%ecx
  801e41:	d3 e8                	shr    %cl,%eax
  801e43:	09 e8                	or     %ebp,%eax
  801e45:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e49:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e4d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e51:	d3 e0                	shl    %cl,%eax
  801e53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e57:	89 f2                	mov    %esi,%edx
  801e59:	d3 e2                	shl    %cl,%edx
  801e5b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e5f:	d3 e0                	shl    %cl,%eax
  801e61:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e65:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e69:	89 f9                	mov    %edi,%ecx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	09 d0                	or     %edx,%eax
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	89 f2                	mov    %esi,%edx
  801e73:	f7 74 24 18          	divl   0x18(%esp)
  801e77:	89 d6                	mov    %edx,%esi
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	89 c5                	mov    %eax,%ebp
  801e7f:	89 d1                	mov    %edx,%ecx
  801e81:	39 d6                	cmp    %edx,%esi
  801e83:	72 67                	jb     801eec <__umoddi3+0x114>
  801e85:	74 75                	je     801efc <__umoddi3+0x124>
  801e87:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e8b:	29 e8                	sub    %ebp,%eax
  801e8d:	19 ce                	sbb    %ecx,%esi
  801e8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e93:	d3 e8                	shr    %cl,%eax
  801e95:	89 f2                	mov    %esi,%edx
  801e97:	89 f9                	mov    %edi,%ecx
  801e99:	d3 e2                	shl    %cl,%edx
  801e9b:	09 d0                	or     %edx,%eax
  801e9d:	89 f2                	mov    %esi,%edx
  801e9f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea3:	d3 ea                	shr    %cl,%edx
  801ea5:	83 c4 20             	add    $0x20,%esp
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    
  801eac:	85 c9                	test   %ecx,%ecx
  801eae:	75 0b                	jne    801ebb <__umoddi3+0xe3>
  801eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb5:	31 d2                	xor    %edx,%edx
  801eb7:	f7 f1                	div    %ecx
  801eb9:	89 c1                	mov    %eax,%ecx
  801ebb:	89 f0                	mov    %esi,%eax
  801ebd:	31 d2                	xor    %edx,%edx
  801ebf:	f7 f1                	div    %ecx
  801ec1:	89 f8                	mov    %edi,%eax
  801ec3:	e9 3e ff ff ff       	jmp    801e06 <__umoddi3+0x2e>
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	83 c4 20             	add    $0x20,%esp
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    
  801ed1:	8d 76 00             	lea    0x0(%esi),%esi
  801ed4:	39 f5                	cmp    %esi,%ebp
  801ed6:	72 04                	jb     801edc <__umoddi3+0x104>
  801ed8:	39 f9                	cmp    %edi,%ecx
  801eda:	77 06                	ja     801ee2 <__umoddi3+0x10a>
  801edc:	89 f2                	mov    %esi,%edx
  801ede:	29 cf                	sub    %ecx,%edi
  801ee0:	19 ea                	sbb    %ebp,%edx
  801ee2:	89 f8                	mov    %edi,%eax
  801ee4:	83 c4 20             	add    $0x20,%esp
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    
  801eeb:	90                   	nop
  801eec:	89 d1                	mov    %edx,%ecx
  801eee:	89 c5                	mov    %eax,%ebp
  801ef0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ef4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ef8:	eb 8d                	jmp    801e87 <__umoddi3+0xaf>
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f00:	72 ea                	jb     801eec <__umoddi3+0x114>
  801f02:	89 f1                	mov    %esi,%ecx
  801f04:	eb 81                	jmp    801e87 <__umoddi3+0xaf>
