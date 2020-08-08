
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
  80003a:	c7 04 24 00 10 80 00 	movl   $0x801000,(%esp)
  800041:	e8 22 01 00 00       	call   800168 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 0e 10 80 00 	movl   $0x80100e,(%esp)
  800059:	e8 0a 01 00 00       	call   800168 <cprintf>
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
  80006e:	e8 74 0a 00 00       	call   800ae7 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007f:	c1 e0 07             	shl    $0x7,%eax
  800082:	29 d0                	sub    %edx,%eax
  800084:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800089:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 f6                	test   %esi,%esi
  800090:	7e 07                	jle    800099 <libmain+0x39>
		binaryname = argv[0];
  800092:	8b 03                	mov    (%ebx),%eax
  800094:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 cf 09 00 00       	call   800a95 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 60 09 00 00       	call   800a58 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	ff 43 04             	incl   0x4(%ebx)
}
  800101:	83 c4 14             	add    $0x14,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013c:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800143:	e8 82 01 00 00       	call   8002ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800158:	89 04 24             	mov    %eax,(%esp)
  80015b:	e8 f8 08 00 00       	call   800a58 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 87 ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	75 08                	jne    8001b0 <printnum+0x2c>
  8001a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ae:	77 57                	ja     800207 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b4:	4b                   	dec    %ebx
  8001b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cf:	00 
  8001d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dd:	e8 b2 0b 00 00       	call   800d94 <__udivdi3>
  8001e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f1:	89 fa                	mov    %edi,%edx
  8001f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f6:	e8 89 ff ff ff       	call   800184 <printnum>
  8001fb:	eb 0f                	jmp    80020c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800201:	89 34 24             	mov    %esi,(%esp)
  800204:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800207:	4b                   	dec    %ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f f1                	jg     8001fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800210:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800222:	00 
  800223:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	e8 7f 0c 00 00       	call   800eb4 <__umoddi3>
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800239:	0f be 80 2f 10 80 00 	movsbl 0x80102f(%eax),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800246:	83 c4 3c             	add    $0x3c,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
  800262:	eb 22                	jmp    800286 <getuint+0x38>
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	74 10                	je     800278 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	eb 0e                	jmp    800286 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800291:	8b 10                	mov    (%eax),%edx
  800293:	3b 50 04             	cmp    0x4(%eax),%edx
  800296:	73 08                	jae    8002a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029b:	88 0a                	mov    %cl,(%edx)
  80029d:	42                   	inc    %edx
  80029e:	89 10                	mov    %edx,(%eax)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 02 00 00 00       	call   8002ca <vprintfmt>
	va_end(ap);
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 4c             	sub    $0x4c,%esp
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d9:	eb 12                	jmp    8002ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	0f 84 8b 03 00 00    	je     80066e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8002e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ed:	0f b6 06             	movzbl (%esi),%eax
  8002f0:	46                   	inc    %esi
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e5                	jne    8002db <vprintfmt+0x11>
  8002f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800301:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800306:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	eb 26                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800317:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80031b:	eb 1d                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800320:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800324:	eb 14                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	eb 08                	jmp    80033a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800332:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800335:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 06             	movzbl (%esi),%eax
  80033d:	8d 56 01             	lea    0x1(%esi),%edx
  800340:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800343:	8a 16                	mov    (%esi),%dl
  800345:	83 ea 23             	sub    $0x23,%edx
  800348:	80 fa 55             	cmp    $0x55,%dl
  80034b:	0f 87 01 03 00 00    	ja     800652 <vprintfmt+0x388>
  800351:	0f b6 d2             	movzbl %dl,%edx
  800354:	ff 24 95 00 11 80 00 	jmp    *0x801100(,%edx,4)
  80035b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80035e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800363:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800366:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80036a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80036d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800370:	83 fa 09             	cmp    $0x9,%edx
  800373:	77 2a                	ja     80039f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800375:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800376:	eb eb                	jmp    800363 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 50 04             	lea    0x4(%eax),%edx
  80037e:	89 55 14             	mov    %edx,0x14(%ebp)
  800381:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800386:	eb 17                	jmp    80039f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800388:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038c:	78 98                	js     800326 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800391:	eb a7                	jmp    80033a <vprintfmt+0x70>
  800393:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800396:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80039d:	eb 9b                	jmp    80033a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80039f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a3:	79 95                	jns    80033a <vprintfmt+0x70>
  8003a5:	eb 8b                	jmp    800332 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	eb 8d                	jmp    80033a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c5:	e9 23 ff ff ff       	jmp    8002ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	79 02                	jns    8003db <vprintfmt+0x111>
  8003d9:	f7 d8                	neg    %eax
  8003db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 08             	cmp    $0x8,%eax
  8003e0:	7f 0b                	jg     8003ed <vprintfmt+0x123>
  8003e2:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	75 23                	jne    800410 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f1:	c7 44 24 08 47 10 80 	movl   $0x801047,0x8(%esp)
  8003f8:	00 
  8003f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 9a fe ff ff       	call   8002a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040b:	e9 dd fe ff ff       	jmp    8002ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800414:	c7 44 24 08 50 10 80 	movl   $0x801050,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	8b 55 08             	mov    0x8(%ebp),%edx
  800423:	89 14 24             	mov    %edx,(%esp)
  800426:	e8 77 fe ff ff       	call   8002a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042e:	e9 ba fe ff ff       	jmp    8002ed <vprintfmt+0x23>
  800433:	89 f9                	mov    %edi,%ecx
  800435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800438:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	8b 30                	mov    (%eax),%esi
  800446:	85 f6                	test   %esi,%esi
  800448:	75 05                	jne    80044f <vprintfmt+0x185>
				p = "(null)";
  80044a:	be 40 10 80 00       	mov    $0x801040,%esi
			if (width > 0 && padc != '-')
  80044f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800453:	0f 8e 84 00 00 00    	jle    8004dd <vprintfmt+0x213>
  800459:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80045d:	74 7e                	je     8004dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800463:	89 34 24             	mov    %esi,(%esp)
  800466:	e8 ab 02 00 00       	call   800716 <strnlen>
  80046b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046e:	29 c2                	sub    %eax,%edx
  800470:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800473:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800477:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80047a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80047d:	89 de                	mov    %ebx,%esi
  80047f:	89 d3                	mov    %edx,%ebx
  800481:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	eb 0b                	jmp    800490 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800485:	89 74 24 04          	mov    %esi,0x4(%esp)
  800489:	89 3c 24             	mov    %edi,(%esp)
  80048c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	4b                   	dec    %ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f f1                	jg     800485 <vprintfmt+0x1bb>
  800494:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800497:	89 f3                	mov    %esi,%ebx
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80049c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	79 05                	jns    8004a8 <vprintfmt+0x1de>
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ab:	29 c2                	sub    %eax,%edx
  8004ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b0:	eb 2b                	jmp    8004dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b6:	74 18                	je     8004d0 <vprintfmt+0x206>
  8004b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bb:	83 fa 5e             	cmp    $0x5e,%edx
  8004be:	76 10                	jbe    8004d0 <vprintfmt+0x206>
					putch('?', putdat);
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	eb 0a                	jmp    8004da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	ff 4d e4             	decl   -0x1c(%ebp)
  8004dd:	0f be 06             	movsbl (%esi),%eax
  8004e0:	46                   	inc    %esi
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	74 21                	je     800506 <vprintfmt+0x23c>
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	78 c9                	js     8004b2 <vprintfmt+0x1e8>
  8004e9:	4f                   	dec    %edi
  8004ea:	79 c6                	jns    8004b2 <vprintfmt+0x1e8>
  8004ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ef:	89 de                	mov    %ebx,%esi
  8004f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f4:	eb 18                	jmp    80050e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800501:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800503:	4b                   	dec    %ebx
  800504:	eb 08                	jmp    80050e <vprintfmt+0x244>
  800506:	8b 7d 08             	mov    0x8(%ebp),%edi
  800509:	89 de                	mov    %ebx,%esi
  80050b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050e:	85 db                	test   %ebx,%ebx
  800510:	7f e4                	jg     8004f6 <vprintfmt+0x22c>
  800512:	89 7d 08             	mov    %edi,0x8(%ebp)
  800515:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 ce fd ff ff       	jmp    8002ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051f:	83 f9 01             	cmp    $0x1,%ecx
  800522:	7e 10                	jle    800534 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 08             	lea    0x8(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 30                	mov    (%eax),%esi
  80052f:	8b 78 04             	mov    0x4(%eax),%edi
  800532:	eb 26                	jmp    80055a <vprintfmt+0x290>
	else if (lflag)
  800534:	85 c9                	test   %ecx,%ecx
  800536:	74 12                	je     80054a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 30                	mov    (%eax),%esi
  800543:	89 f7                	mov    %esi,%edi
  800545:	c1 ff 1f             	sar    $0x1f,%edi
  800548:	eb 10                	jmp    80055a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 30                	mov    (%eax),%esi
  800555:	89 f7                	mov    %esi,%edi
  800557:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	85 ff                	test   %edi,%edi
  80055c:	78 0a                	js     800568 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 ac 00 00 00       	jmp    800614 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800576:	f7 de                	neg    %esi
  800578:	83 d7 00             	adc    $0x0,%edi
  80057b:	f7 df                	neg    %edi
			}
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800582:	e9 8d 00 00 00       	jmp    800614 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800587:	89 ca                	mov    %ecx,%edx
  800589:	8d 45 14             	lea    0x14(%ebp),%eax
  80058c:	e8 bd fc ff ff       	call   80024e <getuint>
  800591:	89 c6                	mov    %eax,%esi
  800593:	89 d7                	mov    %edx,%edi
			base = 10;
  800595:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059a:	eb 78                	jmp    800614 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ae:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005c9:	e9 1f fd ff ff       	jmp    8002ed <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f3:	8b 30                	mov    (%eax),%esi
  8005f5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005ff:	eb 13                	jmp    800614 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800601:	89 ca                	mov    %ecx,%edx
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 43 fc ff ff       	call   80024e <getuint>
  80060b:	89 c6                	mov    %eax,%esi
  80060d:	89 d7                	mov    %edx,%edi
			base = 16;
  80060f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800614:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800618:	89 54 24 10          	mov    %edx,0x10(%esp)
  80061c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800623:	89 44 24 08          	mov    %eax,0x8(%esp)
  800627:	89 34 24             	mov    %esi,(%esp)
  80062a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062e:	89 da                	mov    %ebx,%edx
  800630:	8b 45 08             	mov    0x8(%ebp),%eax
  800633:	e8 4c fb ff ff       	call   800184 <printnum>
			break;
  800638:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80063b:	e9 ad fc ff ff       	jmp    8002ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064d:	e9 9b fc ff ff       	jmp    8002ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800652:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800656:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80065d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800660:	eb 01                	jmp    800663 <vprintfmt+0x399>
  800662:	4e                   	dec    %esi
  800663:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800667:	75 f9                	jne    800662 <vprintfmt+0x398>
  800669:	e9 7f fc ff ff       	jmp    8002ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80066e:	83 c4 4c             	add    $0x4c,%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	83 ec 28             	sub    $0x28,%esp
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800682:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800685:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800689:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800693:	85 c0                	test   %eax,%eax
  800695:	74 30                	je     8006c7 <vsnprintf+0x51>
  800697:	85 d2                	test   %edx,%edx
  800699:	7e 33                	jle    8006ce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  8006b7:	e8 0e fc ff ff       	call   8002ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c5:	eb 0c                	jmp    8006d3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006cc:	eb 05                	jmp    8006d3 <vsnprintf+0x5d>
  8006ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	89 04 24             	mov    %eax,(%esp)
  8006f6:	e8 7b ff ff ff       	call   800676 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    
  8006fd:	00 00                	add    %al,(%eax)
	...

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 01                	jmp    80070e <strlen+0xe>
		n++;
  80070d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800712:	75 f9                	jne    80070d <strlen+0xd>
		n++;
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80071c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
  800724:	eb 01                	jmp    800727 <strnlen+0x11>
		n++;
  800726:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	39 d0                	cmp    %edx,%eax
  800729:	74 06                	je     800731 <strnlen+0x1b>
  80072b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072f:	75 f5                	jne    800726 <strnlen+0x10>
		n++;
	return n;
}
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	53                   	push   %ebx
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073d:	ba 00 00 00 00       	mov    $0x0,%edx
  800742:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800745:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800748:	42                   	inc    %edx
  800749:	84 c9                	test   %cl,%cl
  80074b:	75 f5                	jne    800742 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80074d:	5b                   	pop    %ebx
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075a:	89 1c 24             	mov    %ebx,(%esp)
  80075d:	e8 9e ff ff ff       	call   800700 <strlen>
	strcpy(dst + len, src);
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
  800765:	89 54 24 04          	mov    %edx,0x4(%esp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	89 04 24             	mov    %eax,(%esp)
  80076e:	e8 c0 ff ff ff       	call   800733 <strcpy>
	return dst;
}
  800773:	89 d8                	mov    %ebx,%eax
  800775:	83 c4 08             	add    $0x8,%esp
  800778:	5b                   	pop    %ebx
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
  800786:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800789:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078e:	eb 0c                	jmp    80079c <strncpy+0x21>
		*dst++ = *src;
  800790:	8a 1a                	mov    (%edx),%bl
  800792:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 3a 01             	cmpb   $0x1,(%edx)
  800798:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	41                   	inc    %ecx
  80079c:	39 f1                	cmp    %esi,%ecx
  80079e:	75 f0                	jne    800790 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007af:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	75 0a                	jne    8007c0 <strlcpy+0x1c>
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	eb 1a                	jmp    8007d4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ba:	88 18                	mov    %bl,(%eax)
  8007bc:	40                   	inc    %eax
  8007bd:	41                   	inc    %ecx
  8007be:	eb 02                	jmp    8007c2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007c2:	4a                   	dec    %edx
  8007c3:	74 0a                	je     8007cf <strlcpy+0x2b>
  8007c5:	8a 19                	mov    (%ecx),%bl
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 ef                	jne    8007ba <strlcpy+0x16>
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	eb 02                	jmp    8007d1 <strlcpy+0x2d>
  8007cf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007d1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007d4:	29 f0                	sub    %esi,%eax
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e3:	eb 02                	jmp    8007e7 <strcmp+0xd>
		p++, q++;
  8007e5:	41                   	inc    %ecx
  8007e6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e7:	8a 01                	mov    (%ecx),%al
  8007e9:	84 c0                	test   %al,%al
  8007eb:	74 04                	je     8007f1 <strcmp+0x17>
  8007ed:	3a 02                	cmp    (%edx),%al
  8007ef:	74 f4                	je     8007e5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f1:	0f b6 c0             	movzbl %al,%eax
  8007f4:	0f b6 12             	movzbl (%edx),%edx
  8007f7:	29 d0                	sub    %edx,%eax
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800808:	eb 03                	jmp    80080d <strncmp+0x12>
		n--, p++, q++;
  80080a:	4a                   	dec    %edx
  80080b:	40                   	inc    %eax
  80080c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 14                	je     800825 <strncmp+0x2a>
  800811:	8a 18                	mov    (%eax),%bl
  800813:	84 db                	test   %bl,%bl
  800815:	74 04                	je     80081b <strncmp+0x20>
  800817:	3a 19                	cmp    (%ecx),%bl
  800819:	74 ef                	je     80080a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 00             	movzbl (%eax),%eax
  80081e:	0f b6 11             	movzbl (%ecx),%edx
  800821:	29 d0                	sub    %edx,%eax
  800823:	eb 05                	jmp    80082a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082a:	5b                   	pop    %ebx
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800836:	eb 05                	jmp    80083d <strchr+0x10>
		if (*s == c)
  800838:	38 ca                	cmp    %cl,%dl
  80083a:	74 0c                	je     800848 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083c:	40                   	inc    %eax
  80083d:	8a 10                	mov    (%eax),%dl
  80083f:	84 d2                	test   %dl,%dl
  800841:	75 f5                	jne    800838 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800853:	eb 05                	jmp    80085a <strfind+0x10>
		if (*s == c)
  800855:	38 ca                	cmp    %cl,%dl
  800857:	74 07                	je     800860 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800859:	40                   	inc    %eax
  80085a:	8a 10                	mov    (%eax),%dl
  80085c:	84 d2                	test   %dl,%dl
  80085e:	75 f5                	jne    800855 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800871:	85 c9                	test   %ecx,%ecx
  800873:	74 30                	je     8008a5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800875:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087b:	75 25                	jne    8008a2 <memset+0x40>
  80087d:	f6 c1 03             	test   $0x3,%cl
  800880:	75 20                	jne    8008a2 <memset+0x40>
		c &= 0xFF;
  800882:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800885:	89 d3                	mov    %edx,%ebx
  800887:	c1 e3 08             	shl    $0x8,%ebx
  80088a:	89 d6                	mov    %edx,%esi
  80088c:	c1 e6 18             	shl    $0x18,%esi
  80088f:	89 d0                	mov    %edx,%eax
  800891:	c1 e0 10             	shl    $0x10,%eax
  800894:	09 f0                	or     %esi,%eax
  800896:	09 d0                	or     %edx,%eax
  800898:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80089a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80089d:	fc                   	cld    
  80089e:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a0:	eb 03                	jmp    8008a5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a2:	fc                   	cld    
  8008a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a5:	89 f8                	mov    %edi,%eax
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5f                   	pop    %edi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	57                   	push   %edi
  8008b0:	56                   	push   %esi
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ba:	39 c6                	cmp    %eax,%esi
  8008bc:	73 34                	jae    8008f2 <memmove+0x46>
  8008be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c1:	39 d0                	cmp    %edx,%eax
  8008c3:	73 2d                	jae    8008f2 <memmove+0x46>
		s += n;
		d += n;
  8008c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c8:	f6 c2 03             	test   $0x3,%dl
  8008cb:	75 1b                	jne    8008e8 <memmove+0x3c>
  8008cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d3:	75 13                	jne    8008e8 <memmove+0x3c>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 0e                	jne    8008e8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008da:	83 ef 04             	sub    $0x4,%edi
  8008dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008e3:	fd                   	std    
  8008e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e6:	eb 07                	jmp    8008ef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e8:	4f                   	dec    %edi
  8008e9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ec:	fd                   	std    
  8008ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ef:	fc                   	cld    
  8008f0:	eb 20                	jmp    800912 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f8:	75 13                	jne    80090d <memmove+0x61>
  8008fa:	a8 03                	test   $0x3,%al
  8008fc:	75 0f                	jne    80090d <memmove+0x61>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 0a                	jne    80090d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800903:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800906:	89 c7                	mov    %eax,%edi
  800908:	fc                   	cld    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 05                	jmp    800912 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80091c:	8b 45 10             	mov    0x10(%ebp),%eax
  80091f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	89 04 24             	mov    %eax,(%esp)
  800930:	e8 77 ff ff ff       	call   8008ac <memmove>
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 75 0c             	mov    0xc(%ebp),%esi
  800943:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800946:	ba 00 00 00 00       	mov    $0x0,%edx
  80094b:	eb 16                	jmp    800963 <memcmp+0x2c>
		if (*s1 != *s2)
  80094d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800950:	42                   	inc    %edx
  800951:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800955:	38 c8                	cmp    %cl,%al
  800957:	74 0a                	je     800963 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800959:	0f b6 c0             	movzbl %al,%eax
  80095c:	0f b6 c9             	movzbl %cl,%ecx
  80095f:	29 c8                	sub    %ecx,%eax
  800961:	eb 09                	jmp    80096c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800963:	39 da                	cmp    %ebx,%edx
  800965:	75 e6                	jne    80094d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097f:	eb 05                	jmp    800986 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800981:	38 08                	cmp    %cl,(%eax)
  800983:	74 05                	je     80098a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800985:	40                   	inc    %eax
  800986:	39 d0                	cmp    %edx,%eax
  800988:	72 f7                	jb     800981 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 55 08             	mov    0x8(%ebp),%edx
  800995:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800998:	eb 01                	jmp    80099b <strtol+0xf>
		s++;
  80099a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099b:	8a 02                	mov    (%edx),%al
  80099d:	3c 20                	cmp    $0x20,%al
  80099f:	74 f9                	je     80099a <strtol+0xe>
  8009a1:	3c 09                	cmp    $0x9,%al
  8009a3:	74 f5                	je     80099a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a5:	3c 2b                	cmp    $0x2b,%al
  8009a7:	75 08                	jne    8009b1 <strtol+0x25>
		s++;
  8009a9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009af:	eb 13                	jmp    8009c4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b1:	3c 2d                	cmp    $0x2d,%al
  8009b3:	75 0a                	jne    8009bf <strtol+0x33>
		s++, neg = 1;
  8009b5:	8d 52 01             	lea    0x1(%edx),%edx
  8009b8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009bd:	eb 05                	jmp    8009c4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009bf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	74 05                	je     8009cd <strtol+0x41>
  8009c8:	83 fb 10             	cmp    $0x10,%ebx
  8009cb:	75 28                	jne    8009f5 <strtol+0x69>
  8009cd:	8a 02                	mov    (%edx),%al
  8009cf:	3c 30                	cmp    $0x30,%al
  8009d1:	75 10                	jne    8009e3 <strtol+0x57>
  8009d3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009d7:	75 0a                	jne    8009e3 <strtol+0x57>
		s += 2, base = 16;
  8009d9:	83 c2 02             	add    $0x2,%edx
  8009dc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e1:	eb 12                	jmp    8009f5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009e3:	85 db                	test   %ebx,%ebx
  8009e5:	75 0e                	jne    8009f5 <strtol+0x69>
  8009e7:	3c 30                	cmp    $0x30,%al
  8009e9:	75 05                	jne    8009f0 <strtol+0x64>
		s++, base = 8;
  8009eb:	42                   	inc    %edx
  8009ec:	b3 08                	mov    $0x8,%bl
  8009ee:	eb 05                	jmp    8009f5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009f0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fc:	8a 0a                	mov    (%edx),%cl
  8009fe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a01:	80 fb 09             	cmp    $0x9,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x82>
			dig = *s - '0';
  800a06:	0f be c9             	movsbl %cl,%ecx
  800a09:	83 e9 30             	sub    $0x30,%ecx
  800a0c:	eb 1e                	jmp    800a2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a11:	80 fb 19             	cmp    $0x19,%bl
  800a14:	77 08                	ja     800a1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a16:	0f be c9             	movsbl %cl,%ecx
  800a19:	83 e9 57             	sub    $0x57,%ecx
  800a1c:	eb 0e                	jmp    800a2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 12                	ja     800a38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a26:	0f be c9             	movsbl %cl,%ecx
  800a29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a2c:	39 f1                	cmp    %esi,%ecx
  800a2e:	7d 0c                	jge    800a3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a30:	42                   	inc    %edx
  800a31:	0f af c6             	imul   %esi,%eax
  800a34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a36:	eb c4                	jmp    8009fc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a38:	89 c1                	mov    %eax,%ecx
  800a3a:	eb 02                	jmp    800a3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a42:	74 05                	je     800a49 <strtol+0xbd>
		*endptr = (char *) s;
  800a44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a49:	85 ff                	test   %edi,%edi
  800a4b:	74 04                	je     800a51 <strtol+0xc5>
  800a4d:	89 c8                	mov    %ecx,%eax
  800a4f:	f7 d8                	neg    %eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    
	...

00800a58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	89 c3                	mov    %eax,%ebx
  800a6b:	89 c7                	mov    %eax,%edi
  800a6d:	89 c6                	mov    %eax,%esi
  800a6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a81:	b8 01 00 00 00       	mov    $0x1,%eax
  800a86:	89 d1                	mov    %edx,%ecx
  800a88:	89 d3                	mov    %edx,%ebx
  800a8a:	89 d7                	mov    %edx,%edi
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa3:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	89 cb                	mov    %ecx,%ebx
  800aad:	89 cf                	mov    %ecx,%edi
  800aaf:	89 ce                	mov    %ecx,%esi
  800ab1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	7e 28                	jle    800adf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800abb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ac2:	00 
  800ac3:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800aca:	00 
  800acb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ad2:	00 
  800ad3:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800ada:	e8 5d 02 00 00       	call   800d3c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adf:	83 c4 2c             	add    $0x2c,%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 02 00 00 00       	mov    $0x2,%eax
  800af7:	89 d1                	mov    %edx,%ecx
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	89 d7                	mov    %edx,%edi
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_yield>:

void
sys_yield(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	be 00 00 00 00       	mov    $0x0,%esi
  800b33:	b8 04 00 00 00       	mov    $0x4,%eax
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	89 f7                	mov    %esi,%edi
  800b43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 28                	jle    800b71 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b4d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b54:	00 
  800b55:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800b5c:	00 
  800b5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b64:	00 
  800b65:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800b6c:	e8 cb 01 00 00       	call   800d3c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b71:	83 c4 2c             	add    $0x2c,%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b8 05 00 00 00       	mov    $0x5,%eax
  800b87:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7e 28                	jle    800bc4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ba7:	00 
  800ba8:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800baf:	00 
  800bb0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb7:	00 
  800bb8:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800bbf:	e8 78 01 00 00       	call   800d3c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc4:	83 c4 2c             	add    $0x2c,%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bda:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	89 df                	mov    %ebx,%edi
  800be7:	89 de                	mov    %ebx,%esi
  800be9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7e 28                	jle    800c17 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800c02:	00 
  800c03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0a:	00 
  800c0b:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800c12:	e8 25 01 00 00       	call   800d3c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c17:	83 c4 2c             	add    $0x2c,%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 28                	jle    800c6a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c46:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c4d:	00 
  800c4e:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800c55:	00 
  800c56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5d:	00 
  800c5e:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800c65:	e8 d2 00 00 00       	call   800d3c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6a:	83 c4 2c             	add    $0x2c,%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	b8 09 00 00 00       	mov    $0x9,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 28                	jle    800cbd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c99:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb0:	00 
  800cb1:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800cb8:	e8 7f 00 00 00       	call   800d3c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbd:	83 c4 2c             	add    $0x2c,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 cb                	mov    %ecx,%ebx
  800d00:	89 cf                	mov    %ecx,%edi
  800d02:	89 ce                	mov    %ecx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 84 12 80 	movl   $0x801284,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 a1 12 80 00 	movl   $0x8012a1,(%esp)
  800d2d:	e8 0a 00 00 00       	call   800d3c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
	...

00800d3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d44:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d47:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d4d:	e8 95 fd ff ff       	call   800ae7 <sys_getenvid>
  800d52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d55:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d60:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d68:	c7 04 24 b0 12 80 00 	movl   $0x8012b0,(%esp)
  800d6f:	e8 f4 f3 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d78:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7b:	89 04 24             	mov    %eax,(%esp)
  800d7e:	e8 84 f3 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800d83:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  800d8a:	e8 d9 f3 ff ff       	call   800168 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d8f:	cc                   	int3   
  800d90:	eb fd                	jmp    800d8f <_panic+0x53>
	...

00800d94 <__udivdi3>:
  800d94:	55                   	push   %ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	83 ec 10             	sub    $0x10,%esp
  800d9a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d9e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800da2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800daa:	89 cd                	mov    %ecx,%ebp
  800dac:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800db0:	85 c0                	test   %eax,%eax
  800db2:	75 2c                	jne    800de0 <__udivdi3+0x4c>
  800db4:	39 f9                	cmp    %edi,%ecx
  800db6:	77 68                	ja     800e20 <__udivdi3+0x8c>
  800db8:	85 c9                	test   %ecx,%ecx
  800dba:	75 0b                	jne    800dc7 <__udivdi3+0x33>
  800dbc:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc1:	31 d2                	xor    %edx,%edx
  800dc3:	f7 f1                	div    %ecx
  800dc5:	89 c1                	mov    %eax,%ecx
  800dc7:	31 d2                	xor    %edx,%edx
  800dc9:	89 f8                	mov    %edi,%eax
  800dcb:	f7 f1                	div    %ecx
  800dcd:	89 c7                	mov    %eax,%edi
  800dcf:	89 f0                	mov    %esi,%eax
  800dd1:	f7 f1                	div    %ecx
  800dd3:	89 c6                	mov    %eax,%esi
  800dd5:	89 f0                	mov    %esi,%eax
  800dd7:	89 fa                	mov    %edi,%edx
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
  800de0:	39 f8                	cmp    %edi,%eax
  800de2:	77 2c                	ja     800e10 <__udivdi3+0x7c>
  800de4:	0f bd f0             	bsr    %eax,%esi
  800de7:	83 f6 1f             	xor    $0x1f,%esi
  800dea:	75 4c                	jne    800e38 <__udivdi3+0xa4>
  800dec:	39 f8                	cmp    %edi,%eax
  800dee:	bf 00 00 00 00       	mov    $0x0,%edi
  800df3:	72 0a                	jb     800dff <__udivdi3+0x6b>
  800df5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800df9:	0f 87 ad 00 00 00    	ja     800eac <__udivdi3+0x118>
  800dff:	be 01 00 00 00       	mov    $0x1,%esi
  800e04:	89 f0                	mov    %esi,%eax
  800e06:	89 fa                	mov    %edi,%edx
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    
  800e0f:	90                   	nop
  800e10:	31 ff                	xor    %edi,%edi
  800e12:	31 f6                	xor    %esi,%esi
  800e14:	89 f0                	mov    %esi,%eax
  800e16:	89 fa                	mov    %edi,%edx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	89 f0                	mov    %esi,%eax
  800e24:	f7 f1                	div    %ecx
  800e26:	89 c6                	mov    %eax,%esi
  800e28:	31 ff                	xor    %edi,%edi
  800e2a:	89 f0                	mov    %esi,%eax
  800e2c:	89 fa                	mov    %edi,%edx
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	89 f1                	mov    %esi,%ecx
  800e3a:	d3 e0                	shl    %cl,%eax
  800e3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e40:	b8 20 00 00 00       	mov    $0x20,%eax
  800e45:	29 f0                	sub    %esi,%eax
  800e47:	89 ea                	mov    %ebp,%edx
  800e49:	88 c1                	mov    %al,%cl
  800e4b:	d3 ea                	shr    %cl,%edx
  800e4d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e51:	09 ca                	or     %ecx,%edx
  800e53:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e57:	89 f1                	mov    %esi,%ecx
  800e59:	d3 e5                	shl    %cl,%ebp
  800e5b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e5f:	89 fd                	mov    %edi,%ebp
  800e61:	88 c1                	mov    %al,%cl
  800e63:	d3 ed                	shr    %cl,%ebp
  800e65:	89 fa                	mov    %edi,%edx
  800e67:	89 f1                	mov    %esi,%ecx
  800e69:	d3 e2                	shl    %cl,%edx
  800e6b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e6f:	88 c1                	mov    %al,%cl
  800e71:	d3 ef                	shr    %cl,%edi
  800e73:	09 d7                	or     %edx,%edi
  800e75:	89 f8                	mov    %edi,%eax
  800e77:	89 ea                	mov    %ebp,%edx
  800e79:	f7 74 24 08          	divl   0x8(%esp)
  800e7d:	89 d1                	mov    %edx,%ecx
  800e7f:	89 c7                	mov    %eax,%edi
  800e81:	f7 64 24 0c          	mull   0xc(%esp)
  800e85:	39 d1                	cmp    %edx,%ecx
  800e87:	72 17                	jb     800ea0 <__udivdi3+0x10c>
  800e89:	74 09                	je     800e94 <__udivdi3+0x100>
  800e8b:	89 fe                	mov    %edi,%esi
  800e8d:	31 ff                	xor    %edi,%edi
  800e8f:	e9 41 ff ff ff       	jmp    800dd5 <__udivdi3+0x41>
  800e94:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e98:	89 f1                	mov    %esi,%ecx
  800e9a:	d3 e2                	shl    %cl,%edx
  800e9c:	39 c2                	cmp    %eax,%edx
  800e9e:	73 eb                	jae    800e8b <__udivdi3+0xf7>
  800ea0:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ea3:	31 ff                	xor    %edi,%edi
  800ea5:	e9 2b ff ff ff       	jmp    800dd5 <__udivdi3+0x41>
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	31 f6                	xor    %esi,%esi
  800eae:	e9 22 ff ff ff       	jmp    800dd5 <__udivdi3+0x41>
	...

00800eb4 <__umoddi3>:
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	83 ec 20             	sub    $0x20,%esp
  800eba:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ebe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ec2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ec6:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ece:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ed2:	89 c7                	mov    %eax,%edi
  800ed4:	89 f2                	mov    %esi,%edx
  800ed6:	85 ed                	test   %ebp,%ebp
  800ed8:	75 16                	jne    800ef0 <__umoddi3+0x3c>
  800eda:	39 f1                	cmp    %esi,%ecx
  800edc:	0f 86 a6 00 00 00    	jbe    800f88 <__umoddi3+0xd4>
  800ee2:	f7 f1                	div    %ecx
  800ee4:	89 d0                	mov    %edx,%eax
  800ee6:	31 d2                	xor    %edx,%edx
  800ee8:	83 c4 20             	add    $0x20,%esp
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    
  800eef:	90                   	nop
  800ef0:	39 f5                	cmp    %esi,%ebp
  800ef2:	0f 87 ac 00 00 00    	ja     800fa4 <__umoddi3+0xf0>
  800ef8:	0f bd c5             	bsr    %ebp,%eax
  800efb:	83 f0 1f             	xor    $0x1f,%eax
  800efe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f02:	0f 84 a8 00 00 00    	je     800fb0 <__umoddi3+0xfc>
  800f08:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f0c:	d3 e5                	shl    %cl,%ebp
  800f0e:	bf 20 00 00 00       	mov    $0x20,%edi
  800f13:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f17:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f1b:	89 f9                	mov    %edi,%ecx
  800f1d:	d3 e8                	shr    %cl,%eax
  800f1f:	09 e8                	or     %ebp,%eax
  800f21:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f25:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f29:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	d3 e2                	shl    %cl,%edx
  800f37:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f3b:	d3 e0                	shl    %cl,%eax
  800f3d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f41:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f45:	89 f9                	mov    %edi,%ecx
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	09 d0                	or     %edx,%eax
  800f4b:	d3 ee                	shr    %cl,%esi
  800f4d:	89 f2                	mov    %esi,%edx
  800f4f:	f7 74 24 18          	divl   0x18(%esp)
  800f53:	89 d6                	mov    %edx,%esi
  800f55:	f7 64 24 0c          	mull   0xc(%esp)
  800f59:	89 c5                	mov    %eax,%ebp
  800f5b:	89 d1                	mov    %edx,%ecx
  800f5d:	39 d6                	cmp    %edx,%esi
  800f5f:	72 67                	jb     800fc8 <__umoddi3+0x114>
  800f61:	74 75                	je     800fd8 <__umoddi3+0x124>
  800f63:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f67:	29 e8                	sub    %ebp,%eax
  800f69:	19 ce                	sbb    %ecx,%esi
  800f6b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f6f:	d3 e8                	shr    %cl,%eax
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	d3 e2                	shl    %cl,%edx
  800f77:	09 d0                	or     %edx,%eax
  800f79:	89 f2                	mov    %esi,%edx
  800f7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f7f:	d3 ea                	shr    %cl,%edx
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    
  800f88:	85 c9                	test   %ecx,%ecx
  800f8a:	75 0b                	jne    800f97 <__umoddi3+0xe3>
  800f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
  800f95:	89 c1                	mov    %eax,%ecx
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	31 d2                	xor    %edx,%edx
  800f9b:	f7 f1                	div    %ecx
  800f9d:	89 f8                	mov    %edi,%eax
  800f9f:	e9 3e ff ff ff       	jmp    800ee2 <__umoddi3+0x2e>
  800fa4:	89 f2                	mov    %esi,%edx
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	39 f5                	cmp    %esi,%ebp
  800fb2:	72 04                	jb     800fb8 <__umoddi3+0x104>
  800fb4:	39 f9                	cmp    %edi,%ecx
  800fb6:	77 06                	ja     800fbe <__umoddi3+0x10a>
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	29 cf                	sub    %ecx,%edi
  800fbc:	19 ea                	sbb    %ebp,%edx
  800fbe:	89 f8                	mov    %edi,%eax
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    
  800fc7:	90                   	nop
  800fc8:	89 d1                	mov    %edx,%ecx
  800fca:	89 c5                	mov    %eax,%ebp
  800fcc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fd0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fd4:	eb 8d                	jmp    800f63 <__umoddi3+0xaf>
  800fd6:	66 90                	xchg   %ax,%ax
  800fd8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fdc:	72 ea                	jb     800fc8 <__umoddi3+0x114>
  800fde:	89 f1                	mov    %esi,%ecx
  800fe0:	eb 81                	jmp    800f63 <__umoddi3+0xaf>
