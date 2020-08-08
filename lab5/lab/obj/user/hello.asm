
obj/user/hello.debug:     file format elf32-i386


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
  80003a:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  800041:	e8 2a 01 00 00       	call   800170 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 40 80 00       	mov    0x804004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 2e 1f 80 00 	movl   $0x801f2e,(%esp)
  800059:	e8 12 01 00 00       	call   800170 <cprintf>
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
  80006e:	e8 7c 0a 00 00       	call   800aef <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007f:	c1 e0 07             	shl    $0x7,%eax
  800082:	29 d0                	sub    %edx,%eax
  800084:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800089:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 f6                	test   %esi,%esi
  800090:	7e 07                	jle    800099 <libmain+0x39>
		binaryname = argv[0];
  800092:	8b 03                	mov    (%ebx),%eax
  800094:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800099:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ba:	e8 c0 0e 00 00       	call   800f7f <close_all>
	sys_env_destroy(0);
  8000bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c6:	e8 d2 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    
  8000cd:	00 00                	add    %al,(%eax)
	...

008000d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 14             	sub    $0x14,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	40                   	inc    %eax
  8000e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 19                	jne    800106 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f4:	00 
  8000f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 60 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800100:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800106:	ff 43 04             	incl   0x4(%ebx)
}
  800109:	83 c4 14             	add    $0x14,%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	8b 45 08             	mov    0x8(%ebp),%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 d0 00 80 00 	movl   $0x8000d0,(%esp)
  80014b:	e8 82 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 f8 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  800168:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800176:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017d:	8b 45 08             	mov    0x8(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 87 ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    
	...

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 3c             	sub    $0x3c,%esp
  800195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800198:	89 d7                	mov    %edx,%edi
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	75 08                	jne    8001b8 <printnum+0x2c>
  8001b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b6:	77 57                	ja     80020f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bc:	4b                   	dec    %ebx
  8001bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d7:	00 
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	e8 da 1a 00 00       	call   801cc4 <__udivdi3>
  8001ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 fa                	mov    %edi,%edx
  8001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fe:	e8 89 ff ff ff       	call   80018c <printnum>
  800203:	eb 0f                	jmp    800214 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800209:	89 34 24             	mov    %esi,(%esp)
  80020c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020f:	4b                   	dec    %ebx
  800210:	85 db                	test   %ebx,%ebx
  800212:	7f f1                	jg     800205 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800214:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800218:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021c:	8b 45 10             	mov    0x10(%ebp),%eax
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022a:	00 
  80022b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	e8 a7 1b 00 00       	call   801de4 <__umoddi3>
  80023d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800241:	0f be 80 4f 1f 80 00 	movsbl 0x801f4f(%eax),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024e:	83 c4 3c             	add    $0x3c,%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800259:	83 fa 01             	cmp    $0x1,%edx
  80025c:	7e 0e                	jle    80026c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 08             	lea    0x8(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	8b 52 04             	mov    0x4(%edx),%edx
  80026a:	eb 22                	jmp    80028e <getuint+0x38>
	else if (lflag)
  80026c:	85 d2                	test   %edx,%edx
  80026e:	74 10                	je     800280 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	eb 0e                	jmp    80028e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800296:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	3b 50 04             	cmp    0x4(%eax),%edx
  80029e:	73 08                	jae    8002a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a3:	88 0a                	mov    %cl,(%edx)
  8002a5:	42                   	inc    %edx
  8002a6:	89 10                	mov    %edx,(%eax)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 02 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 4c             	sub    $0x4c,%esp
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e1:	eb 12                	jmp    8002f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	0f 84 8b 03 00 00    	je     800676 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8002eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f5:	0f b6 06             	movzbl (%esi),%eax
  8002f8:	46                   	inc    %esi
  8002f9:	83 f8 25             	cmp    $0x25,%eax
  8002fc:	75 e5                	jne    8002e3 <vprintfmt+0x11>
  8002fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800302:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800309:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	eb 26                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800323:	eb 1d                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80032c:	eb 14                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800331:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800338:	eb 08                	jmp    800342 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	0f b6 06             	movzbl (%esi),%eax
  800345:	8d 56 01             	lea    0x1(%esi),%edx
  800348:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034b:	8a 16                	mov    (%esi),%dl
  80034d:	83 ea 23             	sub    $0x23,%edx
  800350:	80 fa 55             	cmp    $0x55,%dl
  800353:	0f 87 01 03 00 00    	ja     80065a <vprintfmt+0x388>
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	ff 24 95 a0 20 80 00 	jmp    *0x8020a0(,%edx,4)
  800363:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800366:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80036e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800372:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800375:	8d 50 d0             	lea    -0x30(%eax),%edx
  800378:	83 fa 09             	cmp    $0x9,%edx
  80037b:	77 2a                	ja     8003a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037e:	eb eb                	jmp    80036b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 50 04             	lea    0x4(%eax),%edx
  800386:	89 55 14             	mov    %edx,0x14(%ebp)
  800389:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038e:	eb 17                	jmp    8003a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800390:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800394:	78 98                	js     80032e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800399:	eb a7                	jmp    800342 <vprintfmt+0x70>
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a5:	eb 9b                	jmp    800342 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ab:	79 95                	jns    800342 <vprintfmt+0x70>
  8003ad:	eb 8b                	jmp    80033a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b3:	eb 8d                	jmp    800342 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 50 04             	lea    0x4(%eax),%edx
  8003bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cd:	e9 23 ff ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 02                	jns    8003e3 <vprintfmt+0x111>
  8003e1:	f7 d8                	neg    %eax
  8003e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e5:	83 f8 0f             	cmp    $0xf,%eax
  8003e8:	7f 0b                	jg     8003f5 <vprintfmt+0x123>
  8003ea:	8b 04 85 00 22 80 00 	mov    0x802200(,%eax,4),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	75 23                	jne    800418 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f9:	c7 44 24 08 67 1f 80 	movl   $0x801f67,0x8(%esp)
  800400:	00 
  800401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 9a fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 dd fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041c:	c7 44 24 08 5a 23 80 	movl   $0x80235a,0x8(%esp)
  800423:	00 
  800424:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	89 14 24             	mov    %edx,(%esp)
  80042e:	e8 77 fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800436:	e9 ba fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
  80043b:	89 f9                	mov    %edi,%ecx
  80043d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 30                	mov    (%eax),%esi
  80044e:	85 f6                	test   %esi,%esi
  800450:	75 05                	jne    800457 <vprintfmt+0x185>
				p = "(null)";
  800452:	be 60 1f 80 00       	mov    $0x801f60,%esi
			if (width > 0 && padc != '-')
  800457:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045b:	0f 8e 84 00 00 00    	jle    8004e5 <vprintfmt+0x213>
  800461:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800465:	74 7e                	je     8004e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046b:	89 34 24             	mov    %esi,(%esp)
  80046e:	e8 ab 02 00 00       	call   80071e <strnlen>
  800473:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800476:	29 c2                	sub    %eax,%edx
  800478:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80047f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800482:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800485:	89 de                	mov    %ebx,%esi
  800487:	89 d3                	mov    %edx,%ebx
  800489:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0b                	jmp    800498 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80048d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800491:	89 3c 24             	mov    %edi,(%esp)
  800494:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	4b                   	dec    %ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	7f f1                	jg     80048d <vprintfmt+0x1bb>
  80049c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049f:	89 f3                	mov    %esi,%ebx
  8004a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	79 05                	jns    8004b0 <vprintfmt+0x1de>
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b8:	eb 2b                	jmp    8004e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004be:	74 18                	je     8004d8 <vprintfmt+0x206>
  8004c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c3:	83 fa 5e             	cmp    $0x5e,%edx
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x206>
					putch('?', putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	eb 0a                	jmp    8004e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e5:	0f be 06             	movsbl (%esi),%eax
  8004e8:	46                   	inc    %esi
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	74 21                	je     80050e <vprintfmt+0x23c>
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	78 c9                	js     8004ba <vprintfmt+0x1e8>
  8004f1:	4f                   	dec    %edi
  8004f2:	79 c6                	jns    8004ba <vprintfmt+0x1e8>
  8004f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f7:	89 de                	mov    %ebx,%esi
  8004f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fc:	eb 18                	jmp    800516 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800502:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800509:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050b:	4b                   	dec    %ebx
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x244>
  80050e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800511:	89 de                	mov    %ebx,%esi
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800516:	85 db                	test   %ebx,%ebx
  800518:	7f e4                	jg     8004fe <vprintfmt+0x22c>
  80051a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80051d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	e9 ce fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 10                	jle    80053c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 08             	lea    0x8(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	8b 78 04             	mov    0x4(%eax),%edi
  80053a:	eb 26                	jmp    800562 <vprintfmt+0x290>
	else if (lflag)
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	74 12                	je     800552 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	89 f7                	mov    %esi,%edi
  80054d:	c1 ff 1f             	sar    $0x1f,%edi
  800550:	eb 10                	jmp    800562 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 30                	mov    (%eax),%esi
  80055d:	89 f7                	mov    %esi,%edi
  80055f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800562:	85 ff                	test   %edi,%edi
  800564:	78 0a                	js     800570 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 ac 00 00 00       	jmp    80061c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057e:	f7 de                	neg    %esi
  800580:	83 d7 00             	adc    $0x0,%edi
  800583:	f7 df                	neg    %edi
			}
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058a:	e9 8d 00 00 00       	jmp    80061c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058f:	89 ca                	mov    %ecx,%edx
  800591:	8d 45 14             	lea    0x14(%ebp),%eax
  800594:	e8 bd fc ff ff       	call   800256 <getuint>
  800599:	89 c6                	mov    %eax,%esi
  80059b:	89 d7                	mov    %edx,%edi
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a2:	eb 78                	jmp    80061c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d1:	e9 1f fd ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fb:	8b 30                	mov    (%eax),%esi
  8005fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800602:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800607:	eb 13                	jmp    80061c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 43 fc ff ff       	call   800256 <getuint>
  800613:	89 c6                	mov    %eax,%esi
  800615:	89 d7                	mov    %edx,%edi
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800620:	89 54 24 10          	mov    %edx,0x10(%esp)
  800624:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800627:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062f:	89 34 24             	mov    %esi,(%esp)
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	89 da                	mov    %ebx,%edx
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	e8 4c fb ff ff       	call   80018c <printnum>
			break;
  800640:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800643:	e9 ad fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800655:	e9 9b fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800665:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800668:	eb 01                	jmp    80066b <vprintfmt+0x399>
  80066a:	4e                   	dec    %esi
  80066b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066f:	75 f9                	jne    80066a <vprintfmt+0x398>
  800671:	e9 7f fc ff ff       	jmp    8002f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800676:	83 c4 4c             	add    $0x4c,%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 28             	sub    $0x28,%esp
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800691:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069b:	85 c0                	test   %eax,%eax
  80069d:	74 30                	je     8006cf <vsnprintf+0x51>
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	7e 33                	jle    8006d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	c7 04 24 90 02 80 00 	movl   $0x800290,(%esp)
  8006bf:	e8 0e fc ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	eb 0c                	jmp    8006db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb 05                	jmp    8006db <vsnprintf+0x5d>
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	89 04 24             	mov    %eax,(%esp)
  8006fe:	e8 7b ff ff ff       	call   80067e <vsnprintf>
	va_end(ap);

	return rc;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    
  800705:	00 00                	add    %al,(%eax)
	...

00800708 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	eb 01                	jmp    800716 <strlen+0xe>
		n++;
  800715:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071a:	75 f9                	jne    800715 <strlen+0xd>
		n++;
	return n;
}
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 01                	jmp    80072f <strnlen+0x11>
		n++;
  80072e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	39 d0                	cmp    %edx,%eax
  800731:	74 06                	je     800739 <strnlen+0x1b>
  800733:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800737:	75 f5                	jne    80072e <strnlen+0x10>
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80074d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800750:	42                   	inc    %edx
  800751:	84 c9                	test   %cl,%cl
  800753:	75 f5                	jne    80074a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800755:	5b                   	pop    %ebx
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800762:	89 1c 24             	mov    %ebx,(%esp)
  800765:	e8 9e ff ff ff       	call   800708 <strlen>
	strcpy(dst + len, src);
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800771:	01 d8                	add    %ebx,%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 c0 ff ff ff       	call   80073b <strcpy>
	return dst;
}
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	83 c4 08             	add    $0x8,%esp
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	eb 0c                	jmp    8007a4 <strncpy+0x21>
		*dst++ = *src;
  800798:	8a 1a                	mov    (%edx),%bl
  80079a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079d:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	41                   	inc    %ecx
  8007a4:	39 f1                	cmp    %esi,%ecx
  8007a6:	75 f0                	jne    800798 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	75 0a                	jne    8007c8 <strlcpy+0x1c>
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	eb 1a                	jmp    8007dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	88 18                	mov    %bl,(%eax)
  8007c4:	40                   	inc    %eax
  8007c5:	41                   	inc    %ecx
  8007c6:	eb 02                	jmp    8007ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ca:	4a                   	dec    %edx
  8007cb:	74 0a                	je     8007d7 <strlcpy+0x2b>
  8007cd:	8a 19                	mov    (%ecx),%bl
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strlcpy+0x16>
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	eb 02                	jmp    8007d9 <strlcpy+0x2d>
  8007d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007dc:	29 f0                	sub    %esi,%eax
}
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007eb:	eb 02                	jmp    8007ef <strcmp+0xd>
		p++, q++;
  8007ed:	41                   	inc    %ecx
  8007ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ef:	8a 01                	mov    (%ecx),%al
  8007f1:	84 c0                	test   %al,%al
  8007f3:	74 04                	je     8007f9 <strcmp+0x17>
  8007f5:	3a 02                	cmp    (%edx),%al
  8007f7:	74 f4                	je     8007ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f9:	0f b6 c0             	movzbl %al,%eax
  8007fc:	0f b6 12             	movzbl (%edx),%edx
  8007ff:	29 d0                	sub    %edx,%eax
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800810:	eb 03                	jmp    800815 <strncmp+0x12>
		n--, p++, q++;
  800812:	4a                   	dec    %edx
  800813:	40                   	inc    %eax
  800814:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 14                	je     80082d <strncmp+0x2a>
  800819:	8a 18                	mov    (%eax),%bl
  80081b:	84 db                	test   %bl,%bl
  80081d:	74 04                	je     800823 <strncmp+0x20>
  80081f:	3a 19                	cmp    (%ecx),%bl
  800821:	74 ef                	je     800812 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 11             	movzbl (%ecx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083e:	eb 05                	jmp    800845 <strchr+0x10>
		if (*s == c)
  800840:	38 ca                	cmp    %cl,%dl
  800842:	74 0c                	je     800850 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800844:	40                   	inc    %eax
  800845:	8a 10                	mov    (%eax),%dl
  800847:	84 d2                	test   %dl,%dl
  800849:	75 f5                	jne    800840 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085b:	eb 05                	jmp    800862 <strfind+0x10>
		if (*s == c)
  80085d:	38 ca                	cmp    %cl,%dl
  80085f:	74 07                	je     800868 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800861:	40                   	inc    %eax
  800862:	8a 10                	mov    (%eax),%dl
  800864:	84 d2                	test   %dl,%dl
  800866:	75 f5                	jne    80085d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 7d 08             	mov    0x8(%ebp),%edi
  800873:	8b 45 0c             	mov    0xc(%ebp),%eax
  800876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 30                	je     8008ad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800883:	75 25                	jne    8008aa <memset+0x40>
  800885:	f6 c1 03             	test   $0x3,%cl
  800888:	75 20                	jne    8008aa <memset+0x40>
		c &= 0xFF;
  80088a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088d:	89 d3                	mov    %edx,%ebx
  80088f:	c1 e3 08             	shl    $0x8,%ebx
  800892:	89 d6                	mov    %edx,%esi
  800894:	c1 e6 18             	shl    $0x18,%esi
  800897:	89 d0                	mov    %edx,%eax
  800899:	c1 e0 10             	shl    $0x10,%eax
  80089c:	09 f0                	or     %esi,%eax
  80089e:	09 d0                	or     %edx,%eax
  8008a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a5:	fc                   	cld    
  8008a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a8:	eb 03                	jmp    8008ad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ad:	89 f8                	mov    %edi,%eax
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c2:	39 c6                	cmp    %eax,%esi
  8008c4:	73 34                	jae    8008fa <memmove+0x46>
  8008c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c9:	39 d0                	cmp    %edx,%eax
  8008cb:	73 2d                	jae    8008fa <memmove+0x46>
		s += n;
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	f6 c2 03             	test   $0x3,%dl
  8008d3:	75 1b                	jne    8008f0 <memmove+0x3c>
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 13                	jne    8008f0 <memmove+0x3c>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 0e                	jne    8008f0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e2:	83 ef 04             	sub    $0x4,%edi
  8008e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008eb:	fd                   	std    
  8008ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ee:	eb 07                	jmp    8008f7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f0:	4f                   	dec    %edi
  8008f1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f4:	fd                   	std    
  8008f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f7:	fc                   	cld    
  8008f8:	eb 20                	jmp    80091a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800900:	75 13                	jne    800915 <memmove+0x61>
  800902:	a8 03                	test   $0x3,%al
  800904:	75 0f                	jne    800915 <memmove+0x61>
  800906:	f6 c1 03             	test   $0x3,%cl
  800909:	75 0a                	jne    800915 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80090e:	89 c7                	mov    %eax,%edi
  800910:	fc                   	cld    
  800911:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800913:	eb 05                	jmp    80091a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800915:	89 c7                	mov    %eax,%edi
  800917:	fc                   	cld    
  800918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800924:	8b 45 10             	mov    0x10(%ebp),%eax
  800927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	e8 77 ff ff ff       	call   8008b4 <memmove>
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 7d 08             	mov    0x8(%ebp),%edi
  800948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094e:	ba 00 00 00 00       	mov    $0x0,%edx
  800953:	eb 16                	jmp    80096b <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	8a 04 17             	mov    (%edi,%edx,1),%al
  800958:	42                   	inc    %edx
  800959:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80095d:	38 c8                	cmp    %cl,%al
  80095f:	74 0a                	je     80096b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c0             	movzbl %al,%eax
  800964:	0f b6 c9             	movzbl %cl,%ecx
  800967:	29 c8                	sub    %ecx,%eax
  800969:	eb 09                	jmp    800974 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096b:	39 da                	cmp    %ebx,%edx
  80096d:	75 e6                	jne    800955 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800982:	89 c2                	mov    %eax,%edx
  800984:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800987:	eb 05                	jmp    80098e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800989:	38 08                	cmp    %cl,(%eax)
  80098b:	74 05                	je     800992 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098d:	40                   	inc    %eax
  80098e:	39 d0                	cmp    %edx,%eax
  800990:	72 f7                	jb     800989 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
  80099d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	eb 01                	jmp    8009a3 <strtol+0xf>
		s++;
  8009a2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	8a 02                	mov    (%edx),%al
  8009a5:	3c 20                	cmp    $0x20,%al
  8009a7:	74 f9                	je     8009a2 <strtol+0xe>
  8009a9:	3c 09                	cmp    $0x9,%al
  8009ab:	74 f5                	je     8009a2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ad:	3c 2b                	cmp    $0x2b,%al
  8009af:	75 08                	jne    8009b9 <strtol+0x25>
		s++;
  8009b1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b7:	eb 13                	jmp    8009cc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b9:	3c 2d                	cmp    $0x2d,%al
  8009bb:	75 0a                	jne    8009c7 <strtol+0x33>
		s++, neg = 1;
  8009bd:	8d 52 01             	lea    0x1(%edx),%edx
  8009c0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c5:	eb 05                	jmp    8009cc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cc:	85 db                	test   %ebx,%ebx
  8009ce:	74 05                	je     8009d5 <strtol+0x41>
  8009d0:	83 fb 10             	cmp    $0x10,%ebx
  8009d3:	75 28                	jne    8009fd <strtol+0x69>
  8009d5:	8a 02                	mov    (%edx),%al
  8009d7:	3c 30                	cmp    $0x30,%al
  8009d9:	75 10                	jne    8009eb <strtol+0x57>
  8009db:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009df:	75 0a                	jne    8009eb <strtol+0x57>
		s += 2, base = 16;
  8009e1:	83 c2 02             	add    $0x2,%edx
  8009e4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e9:	eb 12                	jmp    8009fd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009eb:	85 db                	test   %ebx,%ebx
  8009ed:	75 0e                	jne    8009fd <strtol+0x69>
  8009ef:	3c 30                	cmp    $0x30,%al
  8009f1:	75 05                	jne    8009f8 <strtol+0x64>
		s++, base = 8;
  8009f3:	42                   	inc    %edx
  8009f4:	b3 08                	mov    $0x8,%bl
  8009f6:	eb 05                	jmp    8009fd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009f8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a04:	8a 0a                	mov    (%edx),%cl
  800a06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a09:	80 fb 09             	cmp    $0x9,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x82>
			dig = *s - '0';
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 30             	sub    $0x30,%ecx
  800a14:	eb 1e                	jmp    800a34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 08                	ja     800a26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a1e:	0f be c9             	movsbl %cl,%ecx
  800a21:	83 e9 57             	sub    $0x57,%ecx
  800a24:	eb 0e                	jmp    800a34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a29:	80 fb 19             	cmp    $0x19,%bl
  800a2c:	77 12                	ja     800a40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a2e:	0f be c9             	movsbl %cl,%ecx
  800a31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a34:	39 f1                	cmp    %esi,%ecx
  800a36:	7d 0c                	jge    800a44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a38:	42                   	inc    %edx
  800a39:	0f af c6             	imul   %esi,%eax
  800a3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a3e:	eb c4                	jmp    800a04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	89 c1                	mov    %eax,%ecx
  800a42:	eb 02                	jmp    800a46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4a:	74 05                	je     800a51 <strtol+0xbd>
		*endptr = (char *) s;
  800a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a51:	85 ff                	test   %edi,%edi
  800a53:	74 04                	je     800a59 <strtol+0xc5>
  800a55:	89 c8                	mov    %ecx,%eax
  800a57:	f7 d8                	neg    %eax
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
	...

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 28                	jle    800ae7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aca:	00 
  800acb:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800ad2:	00 
  800ad3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ada:	00 
  800adb:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800ae2:	e8 29 10 00 00       	call   801b10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae7:	83 c4 2c             	add    $0x2c,%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
  800afa:	b8 02 00 00 00       	mov    $0x2,%eax
  800aff:	89 d1                	mov    %edx,%ecx
  800b01:	89 d3                	mov    %edx,%ebx
  800b03:	89 d7                	mov    %edx,%edi
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_yield>:

void
sys_yield(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	be 00 00 00 00       	mov    $0x0,%esi
  800b3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 f7                	mov    %esi,%edi
  800b4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 28                	jle    800b79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b5c:	00 
  800b5d:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800b64:	00 
  800b65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b6c:	00 
  800b6d:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800b74:	e8 97 0f 00 00       	call   801b10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b79:	83 c4 2c             	add    $0x2c,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 28                	jle    800bcc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800baf:	00 
  800bb0:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800bb7:	00 
  800bb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbf:	00 
  800bc0:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800bc7:	e8 44 0f 00 00       	call   801b10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcc:	83 c4 2c             	add    $0x2c,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	b8 06 00 00 00       	mov    $0x6,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 df                	mov    %ebx,%edi
  800bef:	89 de                	mov    %ebx,%esi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800c1a:	e8 f1 0e 00 00       	call   801b10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	89 df                	mov    %ebx,%edi
  800c42:	89 de                	mov    %ebx,%esi
  800c44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 28                	jle    800c72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c55:	00 
  800c56:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800c5d:	00 
  800c5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c65:	00 
  800c66:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800c6d:	e8 9e 0e 00 00       	call   801b10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c72:	83 c4 2c             	add    $0x2c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 28                	jle    800cc5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb8:	00 
  800cb9:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800cc0:	e8 4b 0e 00 00       	call   801b10 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc5:	83 c4 2c             	add    $0x2c,%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 28                	jle    800d18 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cfb:	00 
  800cfc:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800d03:	00 
  800d04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0b:	00 
  800d0c:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800d13:	e8 f8 0d 00 00       	call   801b10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d18:	83 c4 2c             	add    $0x2c,%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	be 00 00 00 00       	mov    $0x0,%esi
  800d2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 cb                	mov    %ecx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	89 ce                	mov    %ecx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 5f 22 80 	movl   $0x80225f,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 7c 22 80 00 	movl   $0x80227c,(%esp)
  800d88:	e8 83 0d 00 00       	call   801b10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	00 00                	add    %al,(%eax)
	...

00800d98 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	05 00 00 00 30       	add    $0x30000000,%eax
  800da3:	c1 e8 0c             	shr    $0xc,%eax
}
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	89 04 24             	mov    %eax,(%esp)
  800db4:	e8 df ff ff ff       	call   800d98 <fd2num>
  800db9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dbe:	c1 e0 0c             	shl    $0xc,%eax
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	53                   	push   %ebx
  800dc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dca:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800dcf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	c1 ea 16             	shr    $0x16,%edx
  800dd6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ddd:	f6 c2 01             	test   $0x1,%dl
  800de0:	74 11                	je     800df3 <fd_alloc+0x30>
  800de2:	89 c2                	mov    %eax,%edx
  800de4:	c1 ea 0c             	shr    $0xc,%edx
  800de7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dee:	f6 c2 01             	test   $0x1,%dl
  800df1:	75 09                	jne    800dfc <fd_alloc+0x39>
			*fd_store = fd;
  800df3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfa:	eb 17                	jmp    800e13 <fd_alloc+0x50>
  800dfc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e01:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e06:	75 c7                	jne    800dcf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e08:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e0e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e13:	5b                   	pop    %ebx
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e1c:	83 f8 1f             	cmp    $0x1f,%eax
  800e1f:	77 36                	ja     800e57 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e21:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e26:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	c1 ea 16             	shr    $0x16,%edx
  800e2e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e35:	f6 c2 01             	test   $0x1,%dl
  800e38:	74 24                	je     800e5e <fd_lookup+0x48>
  800e3a:	89 c2                	mov    %eax,%edx
  800e3c:	c1 ea 0c             	shr    $0xc,%edx
  800e3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e46:	f6 c2 01             	test   $0x1,%dl
  800e49:	74 1a                	je     800e65 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e50:	b8 00 00 00 00       	mov    $0x0,%eax
  800e55:	eb 13                	jmp    800e6a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e5c:	eb 0c                	jmp    800e6a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e63:	eb 05                	jmp    800e6a <fd_lookup+0x54>
  800e65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 14             	sub    $0x14,%esp
  800e73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7e:	eb 0e                	jmp    800e8e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e80:	39 08                	cmp    %ecx,(%eax)
  800e82:	75 09                	jne    800e8d <dev_lookup+0x21>
			*dev = devtab[i];
  800e84:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 33                	jmp    800ec0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e8d:	42                   	inc    %edx
  800e8e:	8b 04 95 08 23 80 00 	mov    0x802308(,%edx,4),%eax
  800e95:	85 c0                	test   %eax,%eax
  800e97:	75 e7                	jne    800e80 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e99:	a1 04 40 80 00       	mov    0x804004,%eax
  800e9e:	8b 40 48             	mov    0x48(%eax),%eax
  800ea1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea9:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  800eb0:	e8 bb f2 ff ff       	call   800170 <cprintf>
	*dev = 0;
  800eb5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ebb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec0:	83 c4 14             	add    $0x14,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
  800ecb:	83 ec 30             	sub    $0x30,%esp
  800ece:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed1:	8a 45 0c             	mov    0xc(%ebp),%al
  800ed4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed7:	89 34 24             	mov    %esi,(%esp)
  800eda:	e8 b9 fe ff ff       	call   800d98 <fd2num>
  800edf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ee2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee6:	89 04 24             	mov    %eax,(%esp)
  800ee9:	e8 28 ff ff ff       	call   800e16 <fd_lookup>
  800eee:	89 c3                	mov    %eax,%ebx
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 05                	js     800ef9 <fd_close+0x33>
	    || fd != fd2)
  800ef4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef7:	74 0d                	je     800f06 <fd_close+0x40>
		return (must_exist ? r : 0);
  800ef9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800efd:	75 46                	jne    800f45 <fd_close+0x7f>
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f04:	eb 3f                	jmp    800f45 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f0d:	8b 06                	mov    (%esi),%eax
  800f0f:	89 04 24             	mov    %eax,(%esp)
  800f12:	e8 55 ff ff ff       	call   800e6c <dev_lookup>
  800f17:	89 c3                	mov    %eax,%ebx
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 18                	js     800f35 <fd_close+0x6f>
		if (dev->dev_close)
  800f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f20:	8b 40 10             	mov    0x10(%eax),%eax
  800f23:	85 c0                	test   %eax,%eax
  800f25:	74 09                	je     800f30 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f27:	89 34 24             	mov    %esi,(%esp)
  800f2a:	ff d0                	call   *%eax
  800f2c:	89 c3                	mov    %eax,%ebx
  800f2e:	eb 05                	jmp    800f35 <fd_close+0x6f>
		else
			r = 0;
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f40:	e8 8f fc ff ff       	call   800bd4 <sys_page_unmap>
	return r;
}
  800f45:	89 d8                	mov    %ebx,%eax
  800f47:	83 c4 30             	add    $0x30,%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	89 04 24             	mov    %eax,(%esp)
  800f61:	e8 b0 fe ff ff       	call   800e16 <fd_lookup>
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 13                	js     800f7d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f6a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f71:	00 
  800f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f75:	89 04 24             	mov    %eax,(%esp)
  800f78:	e8 49 ff ff ff       	call   800ec6 <fd_close>
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <close_all>:

void
close_all(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	53                   	push   %ebx
  800f83:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f8b:	89 1c 24             	mov    %ebx,(%esp)
  800f8e:	e8 bb ff ff ff       	call   800f4e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f93:	43                   	inc    %ebx
  800f94:	83 fb 20             	cmp    $0x20,%ebx
  800f97:	75 f2                	jne    800f8b <close_all+0xc>
		close(i);
}
  800f99:	83 c4 14             	add    $0x14,%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 4c             	sub    $0x4c,%esp
  800fa8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 59 fe ff ff       	call   800e16 <fd_lookup>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	0f 88 e1 00 00 00    	js     8010a8 <dup+0x109>
		return r;
	close(newfdnum);
  800fc7:	89 3c 24             	mov    %edi,(%esp)
  800fca:	e8 7f ff ff ff       	call   800f4e <close>

	newfd = INDEX2FD(newfdnum);
  800fcf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fd5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 c5 fd ff ff       	call   800da8 <fd2data>
  800fe3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fe5:	89 34 24             	mov    %esi,(%esp)
  800fe8:	e8 bb fd ff ff       	call   800da8 <fd2data>
  800fed:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ff0:	89 d8                	mov    %ebx,%eax
  800ff2:	c1 e8 16             	shr    $0x16,%eax
  800ff5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffc:	a8 01                	test   $0x1,%al
  800ffe:	74 46                	je     801046 <dup+0xa7>
  801000:	89 d8                	mov    %ebx,%eax
  801002:	c1 e8 0c             	shr    $0xc,%eax
  801005:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100c:	f6 c2 01             	test   $0x1,%dl
  80100f:	74 35                	je     801046 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801011:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801018:	25 07 0e 00 00       	and    $0xe07,%eax
  80101d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801021:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801024:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801028:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80102f:	00 
  801030:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801034:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103b:	e8 41 fb ff ff       	call   800b81 <sys_page_map>
  801040:	89 c3                	mov    %eax,%ebx
  801042:	85 c0                	test   %eax,%eax
  801044:	78 3b                	js     801081 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801046:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801049:	89 c2                	mov    %eax,%edx
  80104b:	c1 ea 0c             	shr    $0xc,%edx
  80104e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801055:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80105b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80105f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801063:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106a:	00 
  80106b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801076:	e8 06 fb ff ff       	call   800b81 <sys_page_map>
  80107b:	89 c3                	mov    %eax,%ebx
  80107d:	85 c0                	test   %eax,%eax
  80107f:	79 25                	jns    8010a6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801081:	89 74 24 04          	mov    %esi,0x4(%esp)
  801085:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108c:	e8 43 fb ff ff       	call   800bd4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801091:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801094:	89 44 24 04          	mov    %eax,0x4(%esp)
  801098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109f:	e8 30 fb ff ff       	call   800bd4 <sys_page_unmap>
	return r;
  8010a4:	eb 02                	jmp    8010a8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010a6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010a8:	89 d8                	mov    %ebx,%eax
  8010aa:	83 c4 4c             	add    $0x4c,%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 24             	sub    $0x24,%esp
  8010b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c3:	89 1c 24             	mov    %ebx,(%esp)
  8010c6:	e8 4b fd ff ff       	call   800e16 <fd_lookup>
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 6d                	js     80113c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d9:	8b 00                	mov    (%eax),%eax
  8010db:	89 04 24             	mov    %eax,(%esp)
  8010de:	e8 89 fd ff ff       	call   800e6c <dev_lookup>
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 55                	js     80113c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ea:	8b 50 08             	mov    0x8(%eax),%edx
  8010ed:	83 e2 03             	and    $0x3,%edx
  8010f0:	83 fa 01             	cmp    $0x1,%edx
  8010f3:	75 23                	jne    801118 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fa:	8b 40 48             	mov    0x48(%eax),%eax
  8010fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801101:	89 44 24 04          	mov    %eax,0x4(%esp)
  801105:	c7 04 24 cd 22 80 00 	movl   $0x8022cd,(%esp)
  80110c:	e8 5f f0 ff ff       	call   800170 <cprintf>
		return -E_INVAL;
  801111:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801116:	eb 24                	jmp    80113c <read+0x8a>
	}
	if (!dev->dev_read)
  801118:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111b:	8b 52 08             	mov    0x8(%edx),%edx
  80111e:	85 d2                	test   %edx,%edx
  801120:	74 15                	je     801137 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801122:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801125:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801130:	89 04 24             	mov    %eax,(%esp)
  801133:	ff d2                	call   *%edx
  801135:	eb 05                	jmp    80113c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801137:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80113c:	83 c4 24             	add    $0x24,%esp
  80113f:	5b                   	pop    %ebx
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 1c             	sub    $0x1c,%esp
  80114b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801151:	bb 00 00 00 00       	mov    $0x0,%ebx
  801156:	eb 23                	jmp    80117b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801158:	89 f0                	mov    %esi,%eax
  80115a:	29 d8                	sub    %ebx,%eax
  80115c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801160:	8b 45 0c             	mov    0xc(%ebp),%eax
  801163:	01 d8                	add    %ebx,%eax
  801165:	89 44 24 04          	mov    %eax,0x4(%esp)
  801169:	89 3c 24             	mov    %edi,(%esp)
  80116c:	e8 41 ff ff ff       	call   8010b2 <read>
		if (m < 0)
  801171:	85 c0                	test   %eax,%eax
  801173:	78 10                	js     801185 <readn+0x43>
			return m;
		if (m == 0)
  801175:	85 c0                	test   %eax,%eax
  801177:	74 0a                	je     801183 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801179:	01 c3                	add    %eax,%ebx
  80117b:	39 f3                	cmp    %esi,%ebx
  80117d:	72 d9                	jb     801158 <readn+0x16>
  80117f:	89 d8                	mov    %ebx,%eax
  801181:	eb 02                	jmp    801185 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801183:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801185:	83 c4 1c             	add    $0x1c,%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	53                   	push   %ebx
  801191:	83 ec 24             	sub    $0x24,%esp
  801194:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801197:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119e:	89 1c 24             	mov    %ebx,(%esp)
  8011a1:	e8 70 fc ff ff       	call   800e16 <fd_lookup>
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 68                	js     801212 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b4:	8b 00                	mov    (%eax),%eax
  8011b6:	89 04 24             	mov    %eax,(%esp)
  8011b9:	e8 ae fc ff ff       	call   800e6c <dev_lookup>
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 50                	js     801212 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c9:	75 23                	jne    8011ee <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011db:	c7 04 24 e9 22 80 00 	movl   $0x8022e9,(%esp)
  8011e2:	e8 89 ef ff ff       	call   800170 <cprintf>
		return -E_INVAL;
  8011e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ec:	eb 24                	jmp    801212 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f4:	85 d2                	test   %edx,%edx
  8011f6:	74 15                	je     80120d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801202:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	ff d2                	call   *%edx
  80120b:	eb 05                	jmp    801212 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801212:	83 c4 24             	add    $0x24,%esp
  801215:	5b                   	pop    %ebx
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <seek>:

int
seek(int fdnum, off_t offset)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801221:	89 44 24 04          	mov    %eax,0x4(%esp)
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	89 04 24             	mov    %eax,(%esp)
  80122b:	e8 e6 fb ff ff       	call   800e16 <fd_lookup>
  801230:	85 c0                	test   %eax,%eax
  801232:	78 0e                	js     801242 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801234:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 24             	sub    $0x24,%esp
  80124b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	89 44 24 04          	mov    %eax,0x4(%esp)
  801255:	89 1c 24             	mov    %ebx,(%esp)
  801258:	e8 b9 fb ff ff       	call   800e16 <fd_lookup>
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 61                	js     8012c2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	89 44 24 04          	mov    %eax,0x4(%esp)
  801268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126b:	8b 00                	mov    (%eax),%eax
  80126d:	89 04 24             	mov    %eax,(%esp)
  801270:	e8 f7 fb ff ff       	call   800e6c <dev_lookup>
  801275:	85 c0                	test   %eax,%eax
  801277:	78 49                	js     8012c2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801280:	75 23                	jne    8012a5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801282:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801287:	8b 40 48             	mov    0x48(%eax),%eax
  80128a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80128e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801292:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  801299:	e8 d2 ee ff ff       	call   800170 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a3:	eb 1d                	jmp    8012c2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a8:	8b 52 18             	mov    0x18(%edx),%edx
  8012ab:	85 d2                	test   %edx,%edx
  8012ad:	74 0e                	je     8012bd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012b6:	89 04 24             	mov    %eax,(%esp)
  8012b9:	ff d2                	call   *%edx
  8012bb:	eb 05                	jmp    8012c2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c2:	83 c4 24             	add    $0x24,%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 24             	sub    $0x24,%esp
  8012cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dc:	89 04 24             	mov    %eax,(%esp)
  8012df:	e8 32 fb ff ff       	call   800e16 <fd_lookup>
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 52                	js     80133a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f2:	8b 00                	mov    (%eax),%eax
  8012f4:	89 04 24             	mov    %eax,(%esp)
  8012f7:	e8 70 fb ff ff       	call   800e6c <dev_lookup>
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 3a                	js     80133a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801300:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801303:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801307:	74 2c                	je     801335 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801309:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801313:	00 00 00 
	stat->st_isdir = 0;
  801316:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80131d:	00 00 00 
	stat->st_dev = dev;
  801320:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801326:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80132a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80132d:	89 14 24             	mov    %edx,(%esp)
  801330:	ff 50 14             	call   *0x14(%eax)
  801333:	eb 05                	jmp    80133a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801335:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80133a:	83 c4 24             	add    $0x24,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801348:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80134f:	00 
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	89 04 24             	mov    %eax,(%esp)
  801356:	e8 fe 01 00 00       	call   801559 <open>
  80135b:	89 c3                	mov    %eax,%ebx
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 1b                	js     80137c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801361:	8b 45 0c             	mov    0xc(%ebp),%eax
  801364:	89 44 24 04          	mov    %eax,0x4(%esp)
  801368:	89 1c 24             	mov    %ebx,(%esp)
  80136b:	e8 58 ff ff ff       	call   8012c8 <fstat>
  801370:	89 c6                	mov    %eax,%esi
	close(fd);
  801372:	89 1c 24             	mov    %ebx,(%esp)
  801375:	e8 d4 fb ff ff       	call   800f4e <close>
	return r;
  80137a:	89 f3                	mov    %esi,%ebx
}
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	00 00                	add    %al,(%eax)
	...

00801388 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 10             	sub    $0x10,%esp
  801390:	89 c3                	mov    %eax,%ebx
  801392:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801394:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139b:	75 11                	jne    8013ae <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013a4:	e8 90 08 00 00       	call   801c39 <ipc_find_env>
  8013a9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ae:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013b5:	00 
  8013b6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013bd:	00 
  8013be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	e8 00 08 00 00       	call   801bcf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013d6:	00 
  8013d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e2:	e8 81 07 00 00       	call   801b68 <ipc_recv>
}
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801402:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	b8 02 00 00 00       	mov    $0x2,%eax
  801411:	e8 72 ff ff ff       	call   801388 <fsipc>
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	8b 40 0c             	mov    0xc(%eax),%eax
  801424:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	b8 06 00 00 00       	mov    $0x6,%eax
  801433:	e8 50 ff ff ff       	call   801388 <fsipc>
}
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	53                   	push   %ebx
  80143e:	83 ec 14             	sub    $0x14,%esp
  801441:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	8b 40 0c             	mov    0xc(%eax),%eax
  80144a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	b8 05 00 00 00       	mov    $0x5,%eax
  801459:	e8 2a ff ff ff       	call   801388 <fsipc>
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 2b                	js     80148d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801462:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801469:	00 
  80146a:	89 1c 24             	mov    %ebx,(%esp)
  80146d:	e8 c9 f2 ff ff       	call   80073b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801472:	a1 80 50 80 00       	mov    0x805080,%eax
  801477:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80147d:	a1 84 50 80 00       	mov    0x805084,%eax
  801482:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801488:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148d:	83 c4 14             	add    $0x14,%esp
  801490:	5b                   	pop    %ebx
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801499:	c7 44 24 08 18 23 80 	movl   $0x802318,0x8(%esp)
  8014a0:	00 
  8014a1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8014a8:	00 
  8014a9:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  8014b0:	e8 5b 06 00 00       	call   801b10 <_panic>

008014b5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	56                   	push   %esi
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 10             	sub    $0x10,%esp
  8014bd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014cb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 03 00 00 00       	mov    $0x3,%eax
  8014db:	e8 a8 fe ff ff       	call   801388 <fsipc>
  8014e0:	89 c3                	mov    %eax,%ebx
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 6a                	js     801550 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8014e6:	39 c6                	cmp    %eax,%esi
  8014e8:	73 24                	jae    80150e <devfile_read+0x59>
  8014ea:	c7 44 24 0c 41 23 80 	movl   $0x802341,0xc(%esp)
  8014f1:	00 
  8014f2:	c7 44 24 08 48 23 80 	movl   $0x802348,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  801509:	e8 02 06 00 00       	call   801b10 <_panic>
	assert(r <= PGSIZE);
  80150e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801513:	7e 24                	jle    801539 <devfile_read+0x84>
  801515:	c7 44 24 0c 5d 23 80 	movl   $0x80235d,0xc(%esp)
  80151c:	00 
  80151d:	c7 44 24 08 48 23 80 	movl   $0x802348,0x8(%esp)
  801524:	00 
  801525:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80152c:	00 
  80152d:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  801534:	e8 d7 05 00 00       	call   801b10 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801539:	89 44 24 08          	mov    %eax,0x8(%esp)
  80153d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801544:	00 
  801545:	8b 45 0c             	mov    0xc(%ebp),%eax
  801548:	89 04 24             	mov    %eax,(%esp)
  80154b:	e8 64 f3 ff ff       	call   8008b4 <memmove>
	return r;
}
  801550:	89 d8                	mov    %ebx,%eax
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	83 ec 20             	sub    $0x20,%esp
  801561:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801564:	89 34 24             	mov    %esi,(%esp)
  801567:	e8 9c f1 ff ff       	call   800708 <strlen>
  80156c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801571:	7f 60                	jg     8015d3 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 45 f8 ff ff       	call   800dc3 <fd_alloc>
  80157e:	89 c3                	mov    %eax,%ebx
  801580:	85 c0                	test   %eax,%eax
  801582:	78 54                	js     8015d8 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801584:	89 74 24 04          	mov    %esi,0x4(%esp)
  801588:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80158f:	e8 a7 f1 ff ff       	call   80073b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801594:	8b 45 0c             	mov    0xc(%ebp),%eax
  801597:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a4:	e8 df fd ff ff       	call   801388 <fsipc>
  8015a9:	89 c3                	mov    %eax,%ebx
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	79 15                	jns    8015c4 <open+0x6b>
		fd_close(fd, 0);
  8015af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015b6:	00 
  8015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ba:	89 04 24             	mov    %eax,(%esp)
  8015bd:	e8 04 f9 ff ff       	call   800ec6 <fd_close>
		return r;
  8015c2:	eb 14                	jmp    8015d8 <open+0x7f>
	}

	return fd2num(fd);
  8015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c7:	89 04 24             	mov    %eax,(%esp)
  8015ca:	e8 c9 f7 ff ff       	call   800d98 <fd2num>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	eb 05                	jmp    8015d8 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015d3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015d8:	89 d8                	mov    %ebx,%eax
  8015da:	83 c4 20             	add    $0x20,%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    

008015e1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f1:	e8 92 fd ff ff       	call   801388 <fsipc>
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 10             	sub    $0x10,%esp
  801600:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801603:	8b 45 08             	mov    0x8(%ebp),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 9a f7 ff ff       	call   800da8 <fd2data>
  80160e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801610:	c7 44 24 04 69 23 80 	movl   $0x802369,0x4(%esp)
  801617:	00 
  801618:	89 34 24             	mov    %esi,(%esp)
  80161b:	e8 1b f1 ff ff       	call   80073b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801620:	8b 43 04             	mov    0x4(%ebx),%eax
  801623:	2b 03                	sub    (%ebx),%eax
  801625:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80162b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801632:	00 00 00 
	stat->st_dev = &devpipe;
  801635:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80163c:	30 80 00 
	return 0;
}
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 14             	sub    $0x14,%esp
  801652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801659:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801660:	e8 6f f5 ff ff       	call   800bd4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801665:	89 1c 24             	mov    %ebx,(%esp)
  801668:	e8 3b f7 ff ff       	call   800da8 <fd2data>
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801678:	e8 57 f5 ff ff       	call   800bd4 <sys_page_unmap>
}
  80167d:	83 c4 14             	add    $0x14,%esp
  801680:	5b                   	pop    %ebx
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	57                   	push   %edi
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	83 ec 2c             	sub    $0x2c,%esp
  80168c:	89 c7                	mov    %eax,%edi
  80168e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801691:	a1 04 40 80 00       	mov    0x804004,%eax
  801696:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801699:	89 3c 24             	mov    %edi,(%esp)
  80169c:	e8 df 05 00 00       	call   801c80 <pageref>
  8016a1:	89 c6                	mov    %eax,%esi
  8016a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 d2 05 00 00       	call   801c80 <pageref>
  8016ae:	39 c6                	cmp    %eax,%esi
  8016b0:	0f 94 c0             	sete   %al
  8016b3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016b6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016bc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016bf:	39 cb                	cmp    %ecx,%ebx
  8016c1:	75 08                	jne    8016cb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016c3:	83 c4 2c             	add    $0x2c,%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5f                   	pop    %edi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016cb:	83 f8 01             	cmp    $0x1,%eax
  8016ce:	75 c1                	jne    801691 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d0:	8b 42 58             	mov    0x58(%edx),%eax
  8016d3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016da:	00 
  8016db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e3:	c7 04 24 70 23 80 00 	movl   $0x802370,(%esp)
  8016ea:	e8 81 ea ff ff       	call   800170 <cprintf>
  8016ef:	eb a0                	jmp    801691 <_pipeisclosed+0xe>

008016f1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	57                   	push   %edi
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 1c             	sub    $0x1c,%esp
  8016fa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016fd:	89 34 24             	mov    %esi,(%esp)
  801700:	e8 a3 f6 ff ff       	call   800da8 <fd2data>
  801705:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801707:	bf 00 00 00 00       	mov    $0x0,%edi
  80170c:	eb 3c                	jmp    80174a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80170e:	89 da                	mov    %ebx,%edx
  801710:	89 f0                	mov    %esi,%eax
  801712:	e8 6c ff ff ff       	call   801683 <_pipeisclosed>
  801717:	85 c0                	test   %eax,%eax
  801719:	75 38                	jne    801753 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80171b:	e8 ee f3 ff ff       	call   800b0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801720:	8b 43 04             	mov    0x4(%ebx),%eax
  801723:	8b 13                	mov    (%ebx),%edx
  801725:	83 c2 20             	add    $0x20,%edx
  801728:	39 d0                	cmp    %edx,%eax
  80172a:	73 e2                	jae    80170e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80172c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801732:	89 c2                	mov    %eax,%edx
  801734:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80173a:	79 05                	jns    801741 <devpipe_write+0x50>
  80173c:	4a                   	dec    %edx
  80173d:	83 ca e0             	or     $0xffffffe0,%edx
  801740:	42                   	inc    %edx
  801741:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801745:	40                   	inc    %eax
  801746:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801749:	47                   	inc    %edi
  80174a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80174d:	75 d1                	jne    801720 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80174f:	89 f8                	mov    %edi,%eax
  801751:	eb 05                	jmp    801758 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801758:	83 c4 1c             	add    $0x1c,%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5f                   	pop    %edi
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	57                   	push   %edi
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	83 ec 1c             	sub    $0x1c,%esp
  801769:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80176c:	89 3c 24             	mov    %edi,(%esp)
  80176f:	e8 34 f6 ff ff       	call   800da8 <fd2data>
  801774:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801776:	be 00 00 00 00       	mov    $0x0,%esi
  80177b:	eb 3a                	jmp    8017b7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80177d:	85 f6                	test   %esi,%esi
  80177f:	74 04                	je     801785 <devpipe_read+0x25>
				return i;
  801781:	89 f0                	mov    %esi,%eax
  801783:	eb 40                	jmp    8017c5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801785:	89 da                	mov    %ebx,%edx
  801787:	89 f8                	mov    %edi,%eax
  801789:	e8 f5 fe ff ff       	call   801683 <_pipeisclosed>
  80178e:	85 c0                	test   %eax,%eax
  801790:	75 2e                	jne    8017c0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801792:	e8 77 f3 ff ff       	call   800b0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801797:	8b 03                	mov    (%ebx),%eax
  801799:	3b 43 04             	cmp    0x4(%ebx),%eax
  80179c:	74 df                	je     80177d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80179e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017a3:	79 05                	jns    8017aa <devpipe_read+0x4a>
  8017a5:	48                   	dec    %eax
  8017a6:	83 c8 e0             	or     $0xffffffe0,%eax
  8017a9:	40                   	inc    %eax
  8017aa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017b4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b6:	46                   	inc    %esi
  8017b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017ba:	75 db                	jne    801797 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017bc:	89 f0                	mov    %esi,%eax
  8017be:	eb 05                	jmp    8017c5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017c5:	83 c4 1c             	add    $0x1c,%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5f                   	pop    %edi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	57                   	push   %edi
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 3c             	sub    $0x3c,%esp
  8017d6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017dc:	89 04 24             	mov    %eax,(%esp)
  8017df:	e8 df f5 ff ff       	call   800dc3 <fd_alloc>
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	0f 88 45 01 00 00    	js     801933 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017f5:	00 
  8017f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801804:	e8 24 f3 ff ff       	call   800b2d <sys_page_alloc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	85 c0                	test   %eax,%eax
  80180d:	0f 88 20 01 00 00    	js     801933 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801813:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 a5 f5 ff ff       	call   800dc3 <fd_alloc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	85 c0                	test   %eax,%eax
  801822:	0f 88 f8 00 00 00    	js     801920 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80182f:	00 
  801830:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801833:	89 44 24 04          	mov    %eax,0x4(%esp)
  801837:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183e:	e8 ea f2 ff ff       	call   800b2d <sys_page_alloc>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	85 c0                	test   %eax,%eax
  801847:	0f 88 d3 00 00 00    	js     801920 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80184d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801850:	89 04 24             	mov    %eax,(%esp)
  801853:	e8 50 f5 ff ff       	call   800da8 <fd2data>
  801858:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801861:	00 
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186d:	e8 bb f2 ff ff       	call   800b2d <sys_page_alloc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	85 c0                	test   %eax,%eax
  801876:	0f 88 91 00 00 00    	js     80190d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 21 f5 ff ff       	call   800da8 <fd2data>
  801887:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80188e:	00 
  80188f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801893:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80189a:	00 
  80189b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80189f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a6:	e8 d6 f2 ff ff       	call   800b81 <sys_page_map>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 4c                	js     8018fd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018cf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	e8 b2 f4 ff ff       	call   800d98 <fd2num>
  8018e6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018eb:	89 04 24             	mov    %eax,(%esp)
  8018ee:	e8 a5 f4 ff ff       	call   800d98 <fd2num>
  8018f3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018fb:	eb 36                	jmp    801933 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801908:	e8 c7 f2 ff ff       	call   800bd4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80190d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801910:	89 44 24 04          	mov    %eax,0x4(%esp)
  801914:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191b:	e8 b4 f2 ff ff       	call   800bd4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801920:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801923:	89 44 24 04          	mov    %eax,0x4(%esp)
  801927:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192e:	e8 a1 f2 ff ff       	call   800bd4 <sys_page_unmap>
    err:
	return r;
}
  801933:	89 d8                	mov    %ebx,%eax
  801935:	83 c4 3c             	add    $0x3c,%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5f                   	pop    %edi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	89 04 24             	mov    %eax,(%esp)
  801950:	e8 c1 f4 ff ff       	call   800e16 <fd_lookup>
  801955:	85 c0                	test   %eax,%eax
  801957:	78 15                	js     80196e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801959:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195c:	89 04 24             	mov    %eax,(%esp)
  80195f:	e8 44 f4 ff ff       	call   800da8 <fd2data>
	return _pipeisclosed(fd, p);
  801964:	89 c2                	mov    %eax,%edx
  801966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801969:	e8 15 fd ff ff       	call   801683 <_pipeisclosed>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801980:	c7 44 24 04 88 23 80 	movl   $0x802388,0x4(%esp)
  801987:	00 
  801988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198b:	89 04 24             	mov    %eax,(%esp)
  80198e:	e8 a8 ed ff ff       	call   80073b <strcpy>
	return 0;
}
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	57                   	push   %edi
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b1:	eb 30                	jmp    8019e3 <devcons_write+0x49>
		m = n - tot;
  8019b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8019b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019b8:	83 fe 7f             	cmp    $0x7f,%esi
  8019bb:	76 05                	jbe    8019c2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019bd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019c2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019c6:	03 45 0c             	add    0xc(%ebp),%eax
  8019c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cd:	89 3c 24             	mov    %edi,(%esp)
  8019d0:	e8 df ee ff ff       	call   8008b4 <memmove>
		sys_cputs(buf, m);
  8019d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d9:	89 3c 24             	mov    %edi,(%esp)
  8019dc:	e8 7f f0 ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e1:	01 f3                	add    %esi,%ebx
  8019e3:	89 d8                	mov    %ebx,%eax
  8019e5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019e8:	72 c9                	jb     8019b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ea:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5f                   	pop    %edi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ff:	75 07                	jne    801a08 <devcons_read+0x13>
  801a01:	eb 25                	jmp    801a28 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a03:	e8 06 f1 ff ff       	call   800b0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a08:	e8 71 f0 ff ff       	call   800a7e <sys_cgetc>
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	74 f2                	je     801a03 <devcons_read+0xe>
  801a11:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 1d                	js     801a34 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a17:	83 f8 04             	cmp    $0x4,%eax
  801a1a:	74 13                	je     801a2f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	88 10                	mov    %dl,(%eax)
	return 1;
  801a21:	b8 01 00 00 00       	mov    $0x1,%eax
  801a26:	eb 0c                	jmp    801a34 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2d:	eb 05                	jmp    801a34 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a42:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a49:	00 
  801a4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4d:	89 04 24             	mov    %eax,(%esp)
  801a50:	e8 0b f0 ff ff       	call   800a60 <sys_cputs>
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <getchar>:

int
getchar(void)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a5d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a64:	00 
  801a65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a73:	e8 3a f6 ff ff       	call   8010b2 <read>
	if (r < 0)
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 0f                	js     801a8b <getchar+0x34>
		return r;
	if (r < 1)
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	7e 06                	jle    801a86 <getchar+0x2f>
		return -E_EOF;
	return c;
  801a80:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a84:	eb 05                	jmp    801a8b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a86:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	89 04 24             	mov    %eax,(%esp)
  801aa0:	e8 71 f3 ff ff       	call   800e16 <fd_lookup>
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 11                	js     801aba <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab2:	39 10                	cmp    %edx,(%eax)
  801ab4:	0f 94 c0             	sete   %al
  801ab7:	0f b6 c0             	movzbl %al,%eax
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <opencons>:

int
opencons(void)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 f6 f2 ff ff       	call   800dc3 <fd_alloc>
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 3c                	js     801b0d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ad8:	00 
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae7:	e8 41 f0 ff ff       	call   800b2d <sys_page_alloc>
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 1d                	js     801b0d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b05:	89 04 24             	mov    %eax,(%esp)
  801b08:	e8 8b f2 ff ff       	call   800d98 <fd2num>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    
	...

00801b10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b18:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b1b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b21:	e8 c9 ef ff ff       	call   800aef <sys_getenvid>
  801b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b29:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3c:	c7 04 24 94 23 80 00 	movl   $0x802394,(%esp)
  801b43:	e8 28 e6 ff ff       	call   800170 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 b8 e5 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801b57:	c7 04 24 81 23 80 00 	movl   $0x802381,(%esp)
  801b5e:	e8 0d e6 ff ff       	call   800170 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b63:	cc                   	int3   
  801b64:	eb fd                	jmp    801b63 <_panic+0x53>
	...

00801b68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 10             	sub    $0x10,%esp
  801b70:	8b 75 08             	mov    0x8(%ebp),%esi
  801b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	75 05                	jne    801b82 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b7d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b82:	89 04 24             	mov    %eax,(%esp)
  801b85:	e8 b9 f1 ff ff       	call   800d43 <sys_ipc_recv>
	if (!err) {
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	75 26                	jne    801bb4 <ipc_recv+0x4c>
		if (from_env_store) {
  801b8e:	85 f6                	test   %esi,%esi
  801b90:	74 0a                	je     801b9c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b92:	a1 04 40 80 00       	mov    0x804004,%eax
  801b97:	8b 40 74             	mov    0x74(%eax),%eax
  801b9a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b9c:	85 db                	test   %ebx,%ebx
  801b9e:	74 0a                	je     801baa <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801ba0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba5:	8b 40 78             	mov    0x78(%eax),%eax
  801ba8:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801baa:	a1 04 40 80 00       	mov    0x804004,%eax
  801baf:	8b 40 70             	mov    0x70(%eax),%eax
  801bb2:	eb 14                	jmp    801bc8 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801bb4:	85 f6                	test   %esi,%esi
  801bb6:	74 06                	je     801bbe <ipc_recv+0x56>
		*from_env_store = 0;
  801bb8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801bbe:	85 db                	test   %ebx,%ebx
  801bc0:	74 06                	je     801bc8 <ipc_recv+0x60>
		*perm_store = 0;
  801bc2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	57                   	push   %edi
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 1c             	sub    $0x1c,%esp
  801bd8:	8b 75 10             	mov    0x10(%ebp),%esi
  801bdb:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bde:	85 f6                	test   %esi,%esi
  801be0:	75 05                	jne    801be7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801be2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801be7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801beb:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 1f f1 ff ff       	call   800d20 <sys_ipc_try_send>
  801c01:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801c03:	e8 06 ef ff ff       	call   800b0e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801c08:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801c0b:	74 da                	je     801be7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801c0d:	85 db                	test   %ebx,%ebx
  801c0f:	74 20                	je     801c31 <ipc_send+0x62>
		panic("send fail: %e", err);
  801c11:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c15:	c7 44 24 08 b8 23 80 	movl   $0x8023b8,0x8(%esp)
  801c1c:	00 
  801c1d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c24:	00 
  801c25:	c7 04 24 c6 23 80 00 	movl   $0x8023c6,(%esp)
  801c2c:	e8 df fe ff ff       	call   801b10 <_panic>
	}
	return;
}
  801c31:	83 c4 1c             	add    $0x1c,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5f                   	pop    %edi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	53                   	push   %ebx
  801c3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c45:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c4c:	89 c2                	mov    %eax,%edx
  801c4e:	c1 e2 07             	shl    $0x7,%edx
  801c51:	29 ca                	sub    %ecx,%edx
  801c53:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c59:	8b 52 50             	mov    0x50(%edx),%edx
  801c5c:	39 da                	cmp    %ebx,%edx
  801c5e:	75 0f                	jne    801c6f <ipc_find_env+0x36>
			return envs[i].env_id;
  801c60:	c1 e0 07             	shl    $0x7,%eax
  801c63:	29 c8                	sub    %ecx,%eax
  801c65:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c6a:	8b 40 40             	mov    0x40(%eax),%eax
  801c6d:	eb 0c                	jmp    801c7b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c6f:	40                   	inc    %eax
  801c70:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c75:	75 ce                	jne    801c45 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c77:	66 b8 00 00          	mov    $0x0,%ax
}
  801c7b:	5b                   	pop    %ebx
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    
	...

00801c80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c86:	89 c2                	mov    %eax,%edx
  801c88:	c1 ea 16             	shr    $0x16,%edx
  801c8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c92:	f6 c2 01             	test   $0x1,%dl
  801c95:	74 1e                	je     801cb5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c97:	c1 e8 0c             	shr    $0xc,%eax
  801c9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ca1:	a8 01                	test   $0x1,%al
  801ca3:	74 17                	je     801cbc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ca5:	c1 e8 0c             	shr    $0xc,%eax
  801ca8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801caf:	ef 
  801cb0:	0f b7 c0             	movzwl %ax,%eax
  801cb3:	eb 0c                	jmp    801cc1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	eb 05                	jmp    801cc1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    
	...

00801cc4 <__udivdi3>:
  801cc4:	55                   	push   %ebp
  801cc5:	57                   	push   %edi
  801cc6:	56                   	push   %esi
  801cc7:	83 ec 10             	sub    $0x10,%esp
  801cca:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cce:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cda:	89 cd                	mov    %ecx,%ebp
  801cdc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	75 2c                	jne    801d10 <__udivdi3+0x4c>
  801ce4:	39 f9                	cmp    %edi,%ecx
  801ce6:	77 68                	ja     801d50 <__udivdi3+0x8c>
  801ce8:	85 c9                	test   %ecx,%ecx
  801cea:	75 0b                	jne    801cf7 <__udivdi3+0x33>
  801cec:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf1:	31 d2                	xor    %edx,%edx
  801cf3:	f7 f1                	div    %ecx
  801cf5:	89 c1                	mov    %eax,%ecx
  801cf7:	31 d2                	xor    %edx,%edx
  801cf9:	89 f8                	mov    %edi,%eax
  801cfb:	f7 f1                	div    %ecx
  801cfd:	89 c7                	mov    %eax,%edi
  801cff:	89 f0                	mov    %esi,%eax
  801d01:	f7 f1                	div    %ecx
  801d03:	89 c6                	mov    %eax,%esi
  801d05:	89 f0                	mov    %esi,%eax
  801d07:	89 fa                	mov    %edi,%edx
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	5e                   	pop    %esi
  801d0d:	5f                   	pop    %edi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    
  801d10:	39 f8                	cmp    %edi,%eax
  801d12:	77 2c                	ja     801d40 <__udivdi3+0x7c>
  801d14:	0f bd f0             	bsr    %eax,%esi
  801d17:	83 f6 1f             	xor    $0x1f,%esi
  801d1a:	75 4c                	jne    801d68 <__udivdi3+0xa4>
  801d1c:	39 f8                	cmp    %edi,%eax
  801d1e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d23:	72 0a                	jb     801d2f <__udivdi3+0x6b>
  801d25:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d29:	0f 87 ad 00 00 00    	ja     801ddc <__udivdi3+0x118>
  801d2f:	be 01 00 00 00       	mov    $0x1,%esi
  801d34:	89 f0                	mov    %esi,%eax
  801d36:	89 fa                	mov    %edi,%edx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	5e                   	pop    %esi
  801d3c:	5f                   	pop    %edi
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    
  801d3f:	90                   	nop
  801d40:	31 ff                	xor    %edi,%edi
  801d42:	31 f6                	xor    %esi,%esi
  801d44:	89 f0                	mov    %esi,%eax
  801d46:	89 fa                	mov    %edi,%edx
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    
  801d4f:	90                   	nop
  801d50:	89 fa                	mov    %edi,%edx
  801d52:	89 f0                	mov    %esi,%eax
  801d54:	f7 f1                	div    %ecx
  801d56:	89 c6                	mov    %eax,%esi
  801d58:	31 ff                	xor    %edi,%edi
  801d5a:	89 f0                	mov    %esi,%eax
  801d5c:	89 fa                	mov    %edi,%edx
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	5e                   	pop    %esi
  801d62:	5f                   	pop    %edi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    
  801d65:	8d 76 00             	lea    0x0(%esi),%esi
  801d68:	89 f1                	mov    %esi,%ecx
  801d6a:	d3 e0                	shl    %cl,%eax
  801d6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d70:	b8 20 00 00 00       	mov    $0x20,%eax
  801d75:	29 f0                	sub    %esi,%eax
  801d77:	89 ea                	mov    %ebp,%edx
  801d79:	88 c1                	mov    %al,%cl
  801d7b:	d3 ea                	shr    %cl,%edx
  801d7d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d81:	09 ca                	or     %ecx,%edx
  801d83:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d87:	89 f1                	mov    %esi,%ecx
  801d89:	d3 e5                	shl    %cl,%ebp
  801d8b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d8f:	89 fd                	mov    %edi,%ebp
  801d91:	88 c1                	mov    %al,%cl
  801d93:	d3 ed                	shr    %cl,%ebp
  801d95:	89 fa                	mov    %edi,%edx
  801d97:	89 f1                	mov    %esi,%ecx
  801d99:	d3 e2                	shl    %cl,%edx
  801d9b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d9f:	88 c1                	mov    %al,%cl
  801da1:	d3 ef                	shr    %cl,%edi
  801da3:	09 d7                	or     %edx,%edi
  801da5:	89 f8                	mov    %edi,%eax
  801da7:	89 ea                	mov    %ebp,%edx
  801da9:	f7 74 24 08          	divl   0x8(%esp)
  801dad:	89 d1                	mov    %edx,%ecx
  801daf:	89 c7                	mov    %eax,%edi
  801db1:	f7 64 24 0c          	mull   0xc(%esp)
  801db5:	39 d1                	cmp    %edx,%ecx
  801db7:	72 17                	jb     801dd0 <__udivdi3+0x10c>
  801db9:	74 09                	je     801dc4 <__udivdi3+0x100>
  801dbb:	89 fe                	mov    %edi,%esi
  801dbd:	31 ff                	xor    %edi,%edi
  801dbf:	e9 41 ff ff ff       	jmp    801d05 <__udivdi3+0x41>
  801dc4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dc8:	89 f1                	mov    %esi,%ecx
  801dca:	d3 e2                	shl    %cl,%edx
  801dcc:	39 c2                	cmp    %eax,%edx
  801dce:	73 eb                	jae    801dbb <__udivdi3+0xf7>
  801dd0:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dd3:	31 ff                	xor    %edi,%edi
  801dd5:	e9 2b ff ff ff       	jmp    801d05 <__udivdi3+0x41>
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	31 f6                	xor    %esi,%esi
  801dde:	e9 22 ff ff ff       	jmp    801d05 <__udivdi3+0x41>
	...

00801de4 <__umoddi3>:
  801de4:	55                   	push   %ebp
  801de5:	57                   	push   %edi
  801de6:	56                   	push   %esi
  801de7:	83 ec 20             	sub    $0x20,%esp
  801dea:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dee:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801df2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801df6:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dfa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dfe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e02:	89 c7                	mov    %eax,%edi
  801e04:	89 f2                	mov    %esi,%edx
  801e06:	85 ed                	test   %ebp,%ebp
  801e08:	75 16                	jne    801e20 <__umoddi3+0x3c>
  801e0a:	39 f1                	cmp    %esi,%ecx
  801e0c:	0f 86 a6 00 00 00    	jbe    801eb8 <__umoddi3+0xd4>
  801e12:	f7 f1                	div    %ecx
  801e14:	89 d0                	mov    %edx,%eax
  801e16:	31 d2                	xor    %edx,%edx
  801e18:	83 c4 20             	add    $0x20,%esp
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    
  801e1f:	90                   	nop
  801e20:	39 f5                	cmp    %esi,%ebp
  801e22:	0f 87 ac 00 00 00    	ja     801ed4 <__umoddi3+0xf0>
  801e28:	0f bd c5             	bsr    %ebp,%eax
  801e2b:	83 f0 1f             	xor    $0x1f,%eax
  801e2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e32:	0f 84 a8 00 00 00    	je     801ee0 <__umoddi3+0xfc>
  801e38:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e3c:	d3 e5                	shl    %cl,%ebp
  801e3e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e43:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e47:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e4b:	89 f9                	mov    %edi,%ecx
  801e4d:	d3 e8                	shr    %cl,%eax
  801e4f:	09 e8                	or     %ebp,%eax
  801e51:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e55:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e59:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e5d:	d3 e0                	shl    %cl,%eax
  801e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e63:	89 f2                	mov    %esi,%edx
  801e65:	d3 e2                	shl    %cl,%edx
  801e67:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e6b:	d3 e0                	shl    %cl,%eax
  801e6d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e71:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e75:	89 f9                	mov    %edi,%ecx
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	09 d0                	or     %edx,%eax
  801e7b:	d3 ee                	shr    %cl,%esi
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	f7 74 24 18          	divl   0x18(%esp)
  801e83:	89 d6                	mov    %edx,%esi
  801e85:	f7 64 24 0c          	mull   0xc(%esp)
  801e89:	89 c5                	mov    %eax,%ebp
  801e8b:	89 d1                	mov    %edx,%ecx
  801e8d:	39 d6                	cmp    %edx,%esi
  801e8f:	72 67                	jb     801ef8 <__umoddi3+0x114>
  801e91:	74 75                	je     801f08 <__umoddi3+0x124>
  801e93:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e97:	29 e8                	sub    %ebp,%eax
  801e99:	19 ce                	sbb    %ecx,%esi
  801e9b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e9f:	d3 e8                	shr    %cl,%eax
  801ea1:	89 f2                	mov    %esi,%edx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	d3 e2                	shl    %cl,%edx
  801ea7:	09 d0                	or     %edx,%eax
  801ea9:	89 f2                	mov    %esi,%edx
  801eab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eaf:	d3 ea                	shr    %cl,%edx
  801eb1:	83 c4 20             	add    $0x20,%esp
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	85 c9                	test   %ecx,%ecx
  801eba:	75 0b                	jne    801ec7 <__umoddi3+0xe3>
  801ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec1:	31 d2                	xor    %edx,%edx
  801ec3:	f7 f1                	div    %ecx
  801ec5:	89 c1                	mov    %eax,%ecx
  801ec7:	89 f0                	mov    %esi,%eax
  801ec9:	31 d2                	xor    %edx,%edx
  801ecb:	f7 f1                	div    %ecx
  801ecd:	89 f8                	mov    %edi,%eax
  801ecf:	e9 3e ff ff ff       	jmp    801e12 <__umoddi3+0x2e>
  801ed4:	89 f2                	mov    %esi,%edx
  801ed6:	83 c4 20             	add    $0x20,%esp
  801ed9:	5e                   	pop    %esi
  801eda:	5f                   	pop    %edi
  801edb:	5d                   	pop    %ebp
  801edc:	c3                   	ret    
  801edd:	8d 76 00             	lea    0x0(%esi),%esi
  801ee0:	39 f5                	cmp    %esi,%ebp
  801ee2:	72 04                	jb     801ee8 <__umoddi3+0x104>
  801ee4:	39 f9                	cmp    %edi,%ecx
  801ee6:	77 06                	ja     801eee <__umoddi3+0x10a>
  801ee8:	89 f2                	mov    %esi,%edx
  801eea:	29 cf                	sub    %ecx,%edi
  801eec:	19 ea                	sbb    %ebp,%edx
  801eee:	89 f8                	mov    %edi,%eax
  801ef0:	83 c4 20             	add    $0x20,%esp
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    
  801ef7:	90                   	nop
  801ef8:	89 d1                	mov    %edx,%ecx
  801efa:	89 c5                	mov    %eax,%ebp
  801efc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f00:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f04:	eb 8d                	jmp    801e93 <__umoddi3+0xaf>
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f0c:	72 ea                	jb     801ef8 <__umoddi3+0x114>
  801f0e:	89 f1                	mov    %esi,%ecx
  801f10:	eb 81                	jmp    801e93 <__umoddi3+0xaf>
