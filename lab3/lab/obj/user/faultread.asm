
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
  800043:	c7 04 24 7c 0d 80 00 	movl   $0x800d7c,(%esp)
  80004a:	e8 05 01 00 00       	call   800154 <cprintf>
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
  800062:	e8 4c 0a 00 00       	call   800ab3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006f:	c1 e0 05             	shl    $0x5,%eax
  800072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800077:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 f6                	test   %esi,%esi
  80007e:	7e 07                	jle    800087 <libmain+0x33>
		binaryname = argv[0];
  800080:	8b 03                	mov    (%ebx),%eax
  800082:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008b:	89 34 24             	mov    %esi,(%esp)
  80008e:	e8 a1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800093:	e8 08 00 00 00       	call   8000a0 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 af 09 00 00       	call   800a61 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 14             	sub    $0x14,%esp
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000be:	8b 03                	mov    (%ebx),%eax
  8000c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c7:	40                   	inc    %eax
  8000c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cf:	75 19                	jne    8000ea <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000d1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d8:	00 
  8000d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 40 09 00 00       	call   800a24 <sys_cputs>
		b->idx = 0;
  8000e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000ea:	ff 43 04             	incl   0x4(%ebx)
}
  8000ed:	83 c4 14             	add    $0x14,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800103:	00 00 00 
	b.cnt = 0;
  800106:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800110:	8b 45 0c             	mov    0xc(%ebp),%eax
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	8b 45 08             	mov    0x8(%ebp),%eax
  80011a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 b4 00 80 00 	movl   $0x8000b4,(%esp)
  80012f:	e8 82 01 00 00       	call   8002b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 d8 08 00 00       	call   800a24 <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8b 45 08             	mov    0x8(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 87 ff ff ff       	call   8000f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
	...

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80018d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800190:	85 c0                	test   %eax,%eax
  800192:	75 08                	jne    80019c <printnum+0x2c>
  800194:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800197:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019a:	77 57                	ja     8001f3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001a0:	4b                   	dec    %ebx
  8001a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ac:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bb:	00 
  8001bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c9:	e8 5e 09 00 00       	call   800b2c <__udivdi3>
  8001ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001dd:	89 fa                	mov    %edi,%edx
  8001df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e2:	e8 89 ff ff ff       	call   800170 <printnum>
  8001e7:	eb 0f                	jmp    8001f8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001ed:	89 34 24             	mov    %esi,(%esp)
  8001f0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f3:	4b                   	dec    %ebx
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7f f1                	jg     8001e9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800200:	8b 45 10             	mov    0x10(%ebp),%eax
  800203:	89 44 24 08          	mov    %eax,0x8(%esp)
  800207:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020e:	00 
  80020f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021c:	e8 2b 0a 00 00       	call   800c4c <__umoddi3>
  800221:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800225:	0f be 80 a4 0d 80 00 	movsbl 0x800da4(%eax),%eax
  80022c:	89 04 24             	mov    %eax,(%esp)
  80022f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800232:	83 c4 3c             	add    $0x3c,%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023d:	83 fa 01             	cmp    $0x1,%edx
  800240:	7e 0e                	jle    800250 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 08             	lea    0x8(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	8b 52 04             	mov    0x4(%edx),%edx
  80024e:	eb 22                	jmp    800272 <getuint+0x38>
	else if (lflag)
  800250:	85 d2                	test   %edx,%edx
  800252:	74 10                	je     800264 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 04             	lea    0x4(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	ba 00 00 00 00       	mov    $0x0,%edx
  800262:	eb 0e                	jmp    800272 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	3b 50 04             	cmp    0x4(%eax),%edx
  800282:	73 08                	jae    80028c <sprintputch+0x18>
		*b->buf++ = ch;
  800284:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800287:	88 0a                	mov    %cl,(%edx)
  800289:	42                   	inc    %edx
  80028a:	89 10                	mov    %edx,(%eax)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800294:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800297:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029b:	8b 45 10             	mov    0x10(%ebp),%eax
  80029e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 02 00 00 00       	call   8002b6 <vprintfmt>
	va_end(ap);
}
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	83 ec 4c             	sub    $0x4c,%esp
  8002bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c5:	eb 12                	jmp    8002d9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	0f 84 6b 03 00 00    	je     80063a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d9:	0f b6 06             	movzbl (%esi),%eax
  8002dc:	46                   	inc    %esi
  8002dd:	83 f8 25             	cmp    $0x25,%eax
  8002e0:	75 e5                	jne    8002c7 <vprintfmt+0x11>
  8002e2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002f2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fe:	eb 26                	jmp    800326 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800307:	eb 1d                	jmp    800326 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800310:	eb 14                	jmp    800326 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800315:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80031c:	eb 08                	jmp    800326 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80031e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800321:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	0f b6 06             	movzbl (%esi),%eax
  800329:	8d 56 01             	lea    0x1(%esi),%edx
  80032c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032f:	8a 16                	mov    (%esi),%dl
  800331:	83 ea 23             	sub    $0x23,%edx
  800334:	80 fa 55             	cmp    $0x55,%dl
  800337:	0f 87 e1 02 00 00    	ja     80061e <vprintfmt+0x368>
  80033d:	0f b6 d2             	movzbl %dl,%edx
  800340:	ff 24 95 34 0e 80 00 	jmp    *0x800e34(,%edx,4)
  800347:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80034a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800352:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800356:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800359:	8d 50 d0             	lea    -0x30(%eax),%edx
  80035c:	83 fa 09             	cmp    $0x9,%edx
  80035f:	77 2a                	ja     80038b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800361:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800362:	eb eb                	jmp    80034f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8d 50 04             	lea    0x4(%eax),%edx
  80036a:	89 55 14             	mov    %edx,0x14(%ebp)
  80036d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800372:	eb 17                	jmp    80038b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800374:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800378:	78 98                	js     800312 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80037d:	eb a7                	jmp    800326 <vprintfmt+0x70>
  80037f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800382:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800389:	eb 9b                	jmp    800326 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80038b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038f:	79 95                	jns    800326 <vprintfmt+0x70>
  800391:	eb 8b                	jmp    80031e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800393:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800397:	eb 8d                	jmp    800326 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 50 04             	lea    0x4(%eax),%edx
  80039f:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b1:	e9 23 ff ff ff       	jmp    8002d9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 50 04             	lea    0x4(%eax),%edx
  8003bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	79 02                	jns    8003c7 <vprintfmt+0x111>
  8003c5:	f7 d8                	neg    %eax
  8003c7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c9:	83 f8 06             	cmp    $0x6,%eax
  8003cc:	7f 0b                	jg     8003d9 <vprintfmt+0x123>
  8003ce:	8b 04 85 8c 0f 80 00 	mov    0x800f8c(,%eax,4),%eax
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	75 23                	jne    8003fc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003dd:	c7 44 24 08 bc 0d 80 	movl   $0x800dbc,0x8(%esp)
  8003e4:	00 
  8003e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	e8 9a fe ff ff       	call   80028e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f7:	e9 dd fe ff ff       	jmp    8002d9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8003fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800400:	c7 44 24 08 c5 0d 80 	movl   $0x800dc5,0x8(%esp)
  800407:	00 
  800408:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040c:	8b 55 08             	mov    0x8(%ebp),%edx
  80040f:	89 14 24             	mov    %edx,(%esp)
  800412:	e8 77 fe ff ff       	call   80028e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80041a:	e9 ba fe ff ff       	jmp    8002d9 <vprintfmt+0x23>
  80041f:	89 f9                	mov    %edi,%ecx
  800421:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800424:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 50 04             	lea    0x4(%eax),%edx
  80042d:	89 55 14             	mov    %edx,0x14(%ebp)
  800430:	8b 30                	mov    (%eax),%esi
  800432:	85 f6                	test   %esi,%esi
  800434:	75 05                	jne    80043b <vprintfmt+0x185>
				p = "(null)";
  800436:	be b5 0d 80 00       	mov    $0x800db5,%esi
			if (width > 0 && padc != '-')
  80043b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80043f:	0f 8e 84 00 00 00    	jle    8004c9 <vprintfmt+0x213>
  800445:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800449:	74 7e                	je     8004c9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80044f:	89 34 24             	mov    %esi,(%esp)
  800452:	e8 8b 02 00 00       	call   8006e2 <strnlen>
  800457:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80045a:	29 c2                	sub    %eax,%edx
  80045c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80045f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800463:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800466:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800469:	89 de                	mov    %ebx,%esi
  80046b:	89 d3                	mov    %edx,%ebx
  80046d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	eb 0b                	jmp    80047c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800471:	89 74 24 04          	mov    %esi,0x4(%esp)
  800475:	89 3c 24             	mov    %edi,(%esp)
  800478:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	4b                   	dec    %ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	7f f1                	jg     800471 <vprintfmt+0x1bb>
  800480:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800483:	89 f3                	mov    %esi,%ebx
  800485:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800488:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	79 05                	jns    800494 <vprintfmt+0x1de>
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800497:	29 c2                	sub    %eax,%edx
  800499:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80049c:	eb 2b                	jmp    8004c9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004a2:	74 18                	je     8004bc <vprintfmt+0x206>
  8004a4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004a7:	83 fa 5e             	cmp    $0x5e,%edx
  8004aa:	76 10                	jbe    8004bc <vprintfmt+0x206>
					putch('?', putdat);
  8004ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	eb 0a                	jmp    8004c6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004c9:	0f be 06             	movsbl (%esi),%eax
  8004cc:	46                   	inc    %esi
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	74 21                	je     8004f2 <vprintfmt+0x23c>
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	78 c9                	js     80049e <vprintfmt+0x1e8>
  8004d5:	4f                   	dec    %edi
  8004d6:	79 c6                	jns    80049e <vprintfmt+0x1e8>
  8004d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004db:	89 de                	mov    %ebx,%esi
  8004dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004e0:	eb 18                	jmp    8004fa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004ed:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ef:	4b                   	dec    %ebx
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x244>
  8004f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f5:	89 de                	mov    %ebx,%esi
  8004f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fa:	85 db                	test   %ebx,%ebx
  8004fc:	7f e4                	jg     8004e2 <vprintfmt+0x22c>
  8004fe:	89 7d 08             	mov    %edi,0x8(%ebp)
  800501:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800506:	e9 ce fd ff ff       	jmp    8002d9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050b:	83 f9 01             	cmp    $0x1,%ecx
  80050e:	7e 10                	jle    800520 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 08             	lea    0x8(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 30                	mov    (%eax),%esi
  80051b:	8b 78 04             	mov    0x4(%eax),%edi
  80051e:	eb 26                	jmp    800546 <vprintfmt+0x290>
	else if (lflag)
  800520:	85 c9                	test   %ecx,%ecx
  800522:	74 12                	je     800536 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 04             	lea    0x4(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 30                	mov    (%eax),%esi
  80052f:	89 f7                	mov    %esi,%edi
  800531:	c1 ff 1f             	sar    $0x1f,%edi
  800534:	eb 10                	jmp    800546 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	8b 30                	mov    (%eax),%esi
  800541:	89 f7                	mov    %esi,%edi
  800543:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800546:	85 ff                	test   %edi,%edi
  800548:	78 0a                	js     800554 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054f:	e9 8c 00 00 00       	jmp    8005e0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800558:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800562:	f7 de                	neg    %esi
  800564:	83 d7 00             	adc    $0x0,%edi
  800567:	f7 df                	neg    %edi
			}
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	eb 70                	jmp    8005e0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800570:	89 ca                	mov    %ecx,%edx
  800572:	8d 45 14             	lea    0x14(%ebp),%eax
  800575:	e8 c0 fc ff ff       	call   80023a <getuint>
  80057a:	89 c6                	mov    %eax,%esi
  80057c:	89 d7                	mov    %edx,%edi
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800583:	eb 5b                	jmp    8005e0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800585:	89 ca                	mov    %ecx,%edx
  800587:	8d 45 14             	lea    0x14(%ebp),%eax
  80058a:	e8 ab fc ff ff       	call   80023a <getuint>
  80058f:	89 c6                	mov    %eax,%esi
  800591:	89 d7                	mov    %edx,%edi
			base = 8;
  800593:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800598:	eb 46                	jmp    8005e0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80059a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005a5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bf:	8b 30                	mov    (%eax),%esi
  8005c1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005cb:	eb 13                	jmp    8005e0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cd:	89 ca                	mov    %ecx,%edx
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 63 fc ff ff       	call   80023a <getuint>
  8005d7:	89 c6                	mov    %eax,%esi
  8005d9:	89 d7                	mov    %edx,%edi
			base = 16;
  8005db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005e4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f3:	89 34 24             	mov    %esi,(%esp)
  8005f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fa:	89 da                	mov    %ebx,%edx
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	e8 6c fb ff ff       	call   800170 <printnum>
			break;
  800604:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800607:	e9 cd fc ff ff       	jmp    8002d9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800619:	e9 bb fc ff ff       	jmp    8002d9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800622:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800629:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062c:	eb 01                	jmp    80062f <vprintfmt+0x379>
  80062e:	4e                   	dec    %esi
  80062f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800633:	75 f9                	jne    80062e <vprintfmt+0x378>
  800635:	e9 9f fc ff ff       	jmp    8002d9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80063a:	83 c4 4c             	add    $0x4c,%esp
  80063d:	5b                   	pop    %ebx
  80063e:	5e                   	pop    %esi
  80063f:	5f                   	pop    %edi
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	83 ec 28             	sub    $0x28,%esp
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800651:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800655:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800658:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80065f:	85 c0                	test   %eax,%eax
  800661:	74 30                	je     800693 <vsnprintf+0x51>
  800663:	85 d2                	test   %edx,%edx
  800665:	7e 33                	jle    80069a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80066e:	8b 45 10             	mov    0x10(%ebp),%eax
  800671:	89 44 24 08          	mov    %eax,0x8(%esp)
  800675:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800678:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067c:	c7 04 24 74 02 80 00 	movl   $0x800274,(%esp)
  800683:	e8 2e fc ff ff       	call   8002b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800691:	eb 0c                	jmp    80069f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800698:	eb 05                	jmp    80069f <vsnprintf+0x5d>
  80069a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    

008006a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	89 04 24             	mov    %eax,(%esp)
  8006c2:	e8 7b ff ff ff       	call   800642 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    
  8006c9:	00 00                	add    %al,(%eax)
	...

008006cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d7:	eb 01                	jmp    8006da <strlen+0xe>
		n++;
  8006d9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006de:	75 f9                	jne    8006d9 <strlen+0xd>
		n++;
	return n;
}
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	eb 01                	jmp    8006f3 <strnlen+0x11>
		n++;
  8006f2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f3:	39 d0                	cmp    %edx,%eax
  8006f5:	74 06                	je     8006fd <strnlen+0x1b>
  8006f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006fb:	75 f5                	jne    8006f2 <strnlen+0x10>
		n++;
	return n;
}
  8006fd:	5d                   	pop    %ebp
  8006fe:	c3                   	ret    

008006ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	53                   	push   %ebx
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800709:	ba 00 00 00 00       	mov    $0x0,%edx
  80070e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800711:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800714:	42                   	inc    %edx
  800715:	84 c9                	test   %cl,%cl
  800717:	75 f5                	jne    80070e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800719:	5b                   	pop    %ebx
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800726:	89 1c 24             	mov    %ebx,(%esp)
  800729:	e8 9e ff ff ff       	call   8006cc <strlen>
	strcpy(dst + len, src);
  80072e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800731:	89 54 24 04          	mov    %edx,0x4(%esp)
  800735:	01 d8                	add    %ebx,%eax
  800737:	89 04 24             	mov    %eax,(%esp)
  80073a:	e8 c0 ff ff ff       	call   8006ff <strcpy>
	return dst;
}
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	83 c4 08             	add    $0x8,%esp
  800744:	5b                   	pop    %ebx
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800752:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	eb 0c                	jmp    800768 <strncpy+0x21>
		*dst++ = *src;
  80075c:	8a 1a                	mov    (%edx),%bl
  80075e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800761:	80 3a 01             	cmpb   $0x1,(%edx)
  800764:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800767:	41                   	inc    %ecx
  800768:	39 f1                	cmp    %esi,%ecx
  80076a:	75 f0                	jne    80075c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077e:	85 d2                	test   %edx,%edx
  800780:	75 0a                	jne    80078c <strlcpy+0x1c>
  800782:	89 f0                	mov    %esi,%eax
  800784:	eb 1a                	jmp    8007a0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800786:	88 18                	mov    %bl,(%eax)
  800788:	40                   	inc    %eax
  800789:	41                   	inc    %ecx
  80078a:	eb 02                	jmp    80078e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80078e:	4a                   	dec    %edx
  80078f:	74 0a                	je     80079b <strlcpy+0x2b>
  800791:	8a 19                	mov    (%ecx),%bl
  800793:	84 db                	test   %bl,%bl
  800795:	75 ef                	jne    800786 <strlcpy+0x16>
  800797:	89 c2                	mov    %eax,%edx
  800799:	eb 02                	jmp    80079d <strlcpy+0x2d>
  80079b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80079d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007a0:	29 f0                	sub    %esi,%eax
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007af:	eb 02                	jmp    8007b3 <strcmp+0xd>
		p++, q++;
  8007b1:	41                   	inc    %ecx
  8007b2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	8a 01                	mov    (%ecx),%al
  8007b5:	84 c0                	test   %al,%al
  8007b7:	74 04                	je     8007bd <strcmp+0x17>
  8007b9:	3a 02                	cmp    (%edx),%al
  8007bb:	74 f4                	je     8007b1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bd:	0f b6 c0             	movzbl %al,%eax
  8007c0:	0f b6 12             	movzbl (%edx),%edx
  8007c3:	29 d0                	sub    %edx,%eax
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007d4:	eb 03                	jmp    8007d9 <strncmp+0x12>
		n--, p++, q++;
  8007d6:	4a                   	dec    %edx
  8007d7:	40                   	inc    %eax
  8007d8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 14                	je     8007f1 <strncmp+0x2a>
  8007dd:	8a 18                	mov    (%eax),%bl
  8007df:	84 db                	test   %bl,%bl
  8007e1:	74 04                	je     8007e7 <strncmp+0x20>
  8007e3:	3a 19                	cmp    (%ecx),%bl
  8007e5:	74 ef                	je     8007d6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e7:	0f b6 00             	movzbl (%eax),%eax
  8007ea:	0f b6 11             	movzbl (%ecx),%edx
  8007ed:	29 d0                	sub    %edx,%eax
  8007ef:	eb 05                	jmp    8007f6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800802:	eb 05                	jmp    800809 <strchr+0x10>
		if (*s == c)
  800804:	38 ca                	cmp    %cl,%dl
  800806:	74 0c                	je     800814 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800808:	40                   	inc    %eax
  800809:	8a 10                	mov    (%eax),%dl
  80080b:	84 d2                	test   %dl,%dl
  80080d:	75 f5                	jne    800804 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081f:	eb 05                	jmp    800826 <strfind+0x10>
		if (*s == c)
  800821:	38 ca                	cmp    %cl,%dl
  800823:	74 07                	je     80082c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800825:	40                   	inc    %eax
  800826:	8a 10                	mov    (%eax),%dl
  800828:	84 d2                	test   %dl,%dl
  80082a:	75 f5                	jne    800821 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	57                   	push   %edi
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 7d 08             	mov    0x8(%ebp),%edi
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80083d:	85 c9                	test   %ecx,%ecx
  80083f:	74 30                	je     800871 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800841:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800847:	75 25                	jne    80086e <memset+0x40>
  800849:	f6 c1 03             	test   $0x3,%cl
  80084c:	75 20                	jne    80086e <memset+0x40>
		c &= 0xFF;
  80084e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800851:	89 d3                	mov    %edx,%ebx
  800853:	c1 e3 08             	shl    $0x8,%ebx
  800856:	89 d6                	mov    %edx,%esi
  800858:	c1 e6 18             	shl    $0x18,%esi
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	c1 e0 10             	shl    $0x10,%eax
  800860:	09 f0                	or     %esi,%eax
  800862:	09 d0                	or     %edx,%eax
  800864:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800866:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800869:	fc                   	cld    
  80086a:	f3 ab                	rep stos %eax,%es:(%edi)
  80086c:	eb 03                	jmp    800871 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086e:	fc                   	cld    
  80086f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800871:	89 f8                	mov    %edi,%eax
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5f                   	pop    %edi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	57                   	push   %edi
  80087c:	56                   	push   %esi
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 75 0c             	mov    0xc(%ebp),%esi
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800886:	39 c6                	cmp    %eax,%esi
  800888:	73 34                	jae    8008be <memmove+0x46>
  80088a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088d:	39 d0                	cmp    %edx,%eax
  80088f:	73 2d                	jae    8008be <memmove+0x46>
		s += n;
		d += n;
  800891:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800894:	f6 c2 03             	test   $0x3,%dl
  800897:	75 1b                	jne    8008b4 <memmove+0x3c>
  800899:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089f:	75 13                	jne    8008b4 <memmove+0x3c>
  8008a1:	f6 c1 03             	test   $0x3,%cl
  8008a4:	75 0e                	jne    8008b4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008a6:	83 ef 04             	sub    $0x4,%edi
  8008a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008af:	fd                   	std    
  8008b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b2:	eb 07                	jmp    8008bb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008b4:	4f                   	dec    %edi
  8008b5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b8:	fd                   	std    
  8008b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bb:	fc                   	cld    
  8008bc:	eb 20                	jmp    8008de <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c4:	75 13                	jne    8008d9 <memmove+0x61>
  8008c6:	a8 03                	test   $0x3,%al
  8008c8:	75 0f                	jne    8008d9 <memmove+0x61>
  8008ca:	f6 c1 03             	test   $0x3,%cl
  8008cd:	75 0a                	jne    8008d9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008cf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008d2:	89 c7                	mov    %eax,%edi
  8008d4:	fc                   	cld    
  8008d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d7:	eb 05                	jmp    8008de <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d9:	89 c7                	mov    %eax,%edi
  8008db:	fc                   	cld    
  8008dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008de:	5e                   	pop    %esi
  8008df:	5f                   	pop    %edi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	89 04 24             	mov    %eax,(%esp)
  8008fc:	e8 77 ff ff ff       	call   800878 <memmove>
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800912:	ba 00 00 00 00       	mov    $0x0,%edx
  800917:	eb 16                	jmp    80092f <memcmp+0x2c>
		if (*s1 != *s2)
  800919:	8a 04 17             	mov    (%edi,%edx,1),%al
  80091c:	42                   	inc    %edx
  80091d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800921:	38 c8                	cmp    %cl,%al
  800923:	74 0a                	je     80092f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800925:	0f b6 c0             	movzbl %al,%eax
  800928:	0f b6 c9             	movzbl %cl,%ecx
  80092b:	29 c8                	sub    %ecx,%eax
  80092d:	eb 09                	jmp    800938 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	39 da                	cmp    %ebx,%edx
  800931:	75 e6                	jne    800919 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800946:	89 c2                	mov    %eax,%edx
  800948:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094b:	eb 05                	jmp    800952 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094d:	38 08                	cmp    %cl,(%eax)
  80094f:	74 05                	je     800956 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800951:	40                   	inc    %eax
  800952:	39 d0                	cmp    %edx,%eax
  800954:	72 f7                	jb     80094d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 55 08             	mov    0x8(%ebp),%edx
  800961:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800964:	eb 01                	jmp    800967 <strtol+0xf>
		s++;
  800966:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800967:	8a 02                	mov    (%edx),%al
  800969:	3c 20                	cmp    $0x20,%al
  80096b:	74 f9                	je     800966 <strtol+0xe>
  80096d:	3c 09                	cmp    $0x9,%al
  80096f:	74 f5                	je     800966 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800971:	3c 2b                	cmp    $0x2b,%al
  800973:	75 08                	jne    80097d <strtol+0x25>
		s++;
  800975:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800976:	bf 00 00 00 00       	mov    $0x0,%edi
  80097b:	eb 13                	jmp    800990 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097d:	3c 2d                	cmp    $0x2d,%al
  80097f:	75 0a                	jne    80098b <strtol+0x33>
		s++, neg = 1;
  800981:	8d 52 01             	lea    0x1(%edx),%edx
  800984:	bf 01 00 00 00       	mov    $0x1,%edi
  800989:	eb 05                	jmp    800990 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800990:	85 db                	test   %ebx,%ebx
  800992:	74 05                	je     800999 <strtol+0x41>
  800994:	83 fb 10             	cmp    $0x10,%ebx
  800997:	75 28                	jne    8009c1 <strtol+0x69>
  800999:	8a 02                	mov    (%edx),%al
  80099b:	3c 30                	cmp    $0x30,%al
  80099d:	75 10                	jne    8009af <strtol+0x57>
  80099f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009a3:	75 0a                	jne    8009af <strtol+0x57>
		s += 2, base = 16;
  8009a5:	83 c2 02             	add    $0x2,%edx
  8009a8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ad:	eb 12                	jmp    8009c1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009af:	85 db                	test   %ebx,%ebx
  8009b1:	75 0e                	jne    8009c1 <strtol+0x69>
  8009b3:	3c 30                	cmp    $0x30,%al
  8009b5:	75 05                	jne    8009bc <strtol+0x64>
		s++, base = 8;
  8009b7:	42                   	inc    %edx
  8009b8:	b3 08                	mov    $0x8,%bl
  8009ba:	eb 05                	jmp    8009c1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009bc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c8:	8a 0a                	mov    (%edx),%cl
  8009ca:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009cd:	80 fb 09             	cmp    $0x9,%bl
  8009d0:	77 08                	ja     8009da <strtol+0x82>
			dig = *s - '0';
  8009d2:	0f be c9             	movsbl %cl,%ecx
  8009d5:	83 e9 30             	sub    $0x30,%ecx
  8009d8:	eb 1e                	jmp    8009f8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009da:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009dd:	80 fb 19             	cmp    $0x19,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x92>
			dig = *s - 'a' + 10;
  8009e2:	0f be c9             	movsbl %cl,%ecx
  8009e5:	83 e9 57             	sub    $0x57,%ecx
  8009e8:	eb 0e                	jmp    8009f8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009ea:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 12                	ja     800a04 <strtol+0xac>
			dig = *s - 'A' + 10;
  8009f2:	0f be c9             	movsbl %cl,%ecx
  8009f5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8009f8:	39 f1                	cmp    %esi,%ecx
  8009fa:	7d 0c                	jge    800a08 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009fc:	42                   	inc    %edx
  8009fd:	0f af c6             	imul   %esi,%eax
  800a00:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a02:	eb c4                	jmp    8009c8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a04:	89 c1                	mov    %eax,%ecx
  800a06:	eb 02                	jmp    800a0a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a08:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0e:	74 05                	je     800a15 <strtol+0xbd>
		*endptr = (char *) s;
  800a10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a13:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a15:	85 ff                	test   %edi,%edi
  800a17:	74 04                	je     800a1d <strtol+0xc5>
  800a19:	89 c8                	mov    %ecx,%eax
  800a1b:	f7 d8                	neg    %eax
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    
	...

00800a24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a32:	8b 55 08             	mov    0x8(%ebp),%edx
  800a35:	89 c3                	mov    %eax,%ebx
  800a37:	89 c7                	mov    %eax,%edi
  800a39:	89 c6                	mov    %eax,%esi
  800a3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a52:	89 d1                	mov    %edx,%ecx
  800a54:	89 d3                	mov    %edx,%ebx
  800a56:	89 d7                	mov    %edx,%edi
  800a58:	89 d6                	mov    %edx,%esi
  800a5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	89 cb                	mov    %ecx,%ebx
  800a79:	89 cf                	mov    %ecx,%edi
  800a7b:	89 ce                	mov    %ecx,%esi
  800a7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	7e 28                	jle    800aab <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a87:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a8e:	00 
  800a8f:	c7 44 24 08 a8 0f 80 	movl   $0x800fa8,0x8(%esp)
  800a96:	00 
  800a97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800a9e:	00 
  800a9f:	c7 04 24 c5 0f 80 00 	movl   $0x800fc5,(%esp)
  800aa6:	e8 29 00 00 00       	call   800ad4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aab:	83 c4 2c             	add    $0x2c,%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac3:	89 d1                	mov    %edx,%ecx
  800ac5:	89 d3                	mov    %edx,%ebx
  800ac7:	89 d7                	mov    %edx,%edi
  800ac9:	89 d6                	mov    %edx,%esi
  800acb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	...

00800ad4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800adc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800adf:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800ae5:	e8 c9 ff ff ff       	call   800ab3 <sys_getenvid>
  800aea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aed:	89 54 24 10          	mov    %edx,0x10(%esp)
  800af1:	8b 55 08             	mov    0x8(%ebp),%edx
  800af4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800af8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	c7 04 24 d4 0f 80 00 	movl   $0x800fd4,(%esp)
  800b07:	e8 48 f6 ff ff       	call   800154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b10:	8b 45 10             	mov    0x10(%ebp),%eax
  800b13:	89 04 24             	mov    %eax,(%esp)
  800b16:	e8 d8 f5 ff ff       	call   8000f3 <vcprintf>
	cprintf("\n");
  800b1b:	c7 04 24 98 0d 80 00 	movl   $0x800d98,(%esp)
  800b22:	e8 2d f6 ff ff       	call   800154 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b27:	cc                   	int3   
  800b28:	eb fd                	jmp    800b27 <_panic+0x53>
	...

00800b2c <__udivdi3>:
  800b2c:	55                   	push   %ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	83 ec 10             	sub    $0x10,%esp
  800b32:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b36:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b42:	89 cd                	mov    %ecx,%ebp
  800b44:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	75 2c                	jne    800b78 <__udivdi3+0x4c>
  800b4c:	39 f9                	cmp    %edi,%ecx
  800b4e:	77 68                	ja     800bb8 <__udivdi3+0x8c>
  800b50:	85 c9                	test   %ecx,%ecx
  800b52:	75 0b                	jne    800b5f <__udivdi3+0x33>
  800b54:	b8 01 00 00 00       	mov    $0x1,%eax
  800b59:	31 d2                	xor    %edx,%edx
  800b5b:	f7 f1                	div    %ecx
  800b5d:	89 c1                	mov    %eax,%ecx
  800b5f:	31 d2                	xor    %edx,%edx
  800b61:	89 f8                	mov    %edi,%eax
  800b63:	f7 f1                	div    %ecx
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	89 f0                	mov    %esi,%eax
  800b69:	f7 f1                	div    %ecx
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	89 fa                	mov    %edi,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    
  800b78:	39 f8                	cmp    %edi,%eax
  800b7a:	77 2c                	ja     800ba8 <__udivdi3+0x7c>
  800b7c:	0f bd f0             	bsr    %eax,%esi
  800b7f:	83 f6 1f             	xor    $0x1f,%esi
  800b82:	75 4c                	jne    800bd0 <__udivdi3+0xa4>
  800b84:	39 f8                	cmp    %edi,%eax
  800b86:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8b:	72 0a                	jb     800b97 <__udivdi3+0x6b>
  800b8d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b91:	0f 87 ad 00 00 00    	ja     800c44 <__udivdi3+0x118>
  800b97:	be 01 00 00 00       	mov    $0x1,%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	83 c4 10             	add    $0x10,%esp
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    
  800ba7:	90                   	nop
  800ba8:	31 ff                	xor    %edi,%edi
  800baa:	31 f6                	xor    %esi,%esi
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	89 fa                	mov    %edi,%edx
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
  800bb7:	90                   	nop
  800bb8:	89 fa                	mov    %edi,%edx
  800bba:	89 f0                	mov    %esi,%eax
  800bbc:	f7 f1                	div    %ecx
  800bbe:	89 c6                	mov    %eax,%esi
  800bc0:	31 ff                	xor    %edi,%edi
  800bc2:	89 f0                	mov    %esi,%eax
  800bc4:	89 fa                	mov    %edi,%edx
  800bc6:	83 c4 10             	add    $0x10,%esp
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	89 f1                	mov    %esi,%ecx
  800bd2:	d3 e0                	shl    %cl,%eax
  800bd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bdd:	29 f0                	sub    %esi,%eax
  800bdf:	89 ea                	mov    %ebp,%edx
  800be1:	88 c1                	mov    %al,%cl
  800be3:	d3 ea                	shr    %cl,%edx
  800be5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800be9:	09 ca                	or     %ecx,%edx
  800beb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bef:	89 f1                	mov    %esi,%ecx
  800bf1:	d3 e5                	shl    %cl,%ebp
  800bf3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bf7:	89 fd                	mov    %edi,%ebp
  800bf9:	88 c1                	mov    %al,%cl
  800bfb:	d3 ed                	shr    %cl,%ebp
  800bfd:	89 fa                	mov    %edi,%edx
  800bff:	89 f1                	mov    %esi,%ecx
  800c01:	d3 e2                	shl    %cl,%edx
  800c03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c07:	88 c1                	mov    %al,%cl
  800c09:	d3 ef                	shr    %cl,%edi
  800c0b:	09 d7                	or     %edx,%edi
  800c0d:	89 f8                	mov    %edi,%eax
  800c0f:	89 ea                	mov    %ebp,%edx
  800c11:	f7 74 24 08          	divl   0x8(%esp)
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 c7                	mov    %eax,%edi
  800c19:	f7 64 24 0c          	mull   0xc(%esp)
  800c1d:	39 d1                	cmp    %edx,%ecx
  800c1f:	72 17                	jb     800c38 <__udivdi3+0x10c>
  800c21:	74 09                	je     800c2c <__udivdi3+0x100>
  800c23:	89 fe                	mov    %edi,%esi
  800c25:	31 ff                	xor    %edi,%edi
  800c27:	e9 41 ff ff ff       	jmp    800b6d <__udivdi3+0x41>
  800c2c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c30:	89 f1                	mov    %esi,%ecx
  800c32:	d3 e2                	shl    %cl,%edx
  800c34:	39 c2                	cmp    %eax,%edx
  800c36:	73 eb                	jae    800c23 <__udivdi3+0xf7>
  800c38:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c3b:	31 ff                	xor    %edi,%edi
  800c3d:	e9 2b ff ff ff       	jmp    800b6d <__udivdi3+0x41>
  800c42:	66 90                	xchg   %ax,%ax
  800c44:	31 f6                	xor    %esi,%esi
  800c46:	e9 22 ff ff ff       	jmp    800b6d <__udivdi3+0x41>
	...

00800c4c <__umoddi3>:
  800c4c:	55                   	push   %ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	83 ec 20             	sub    $0x20,%esp
  800c52:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c56:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c5a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c5e:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c66:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	89 f2                	mov    %esi,%edx
  800c6e:	85 ed                	test   %ebp,%ebp
  800c70:	75 16                	jne    800c88 <__umoddi3+0x3c>
  800c72:	39 f1                	cmp    %esi,%ecx
  800c74:	0f 86 a6 00 00 00    	jbe    800d20 <__umoddi3+0xd4>
  800c7a:	f7 f1                	div    %ecx
  800c7c:	89 d0                	mov    %edx,%eax
  800c7e:	31 d2                	xor    %edx,%edx
  800c80:	83 c4 20             	add    $0x20,%esp
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    
  800c87:	90                   	nop
  800c88:	39 f5                	cmp    %esi,%ebp
  800c8a:	0f 87 ac 00 00 00    	ja     800d3c <__umoddi3+0xf0>
  800c90:	0f bd c5             	bsr    %ebp,%eax
  800c93:	83 f0 1f             	xor    $0x1f,%eax
  800c96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9a:	0f 84 a8 00 00 00    	je     800d48 <__umoddi3+0xfc>
  800ca0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ca4:	d3 e5                	shl    %cl,%ebp
  800ca6:	bf 20 00 00 00       	mov    $0x20,%edi
  800cab:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800caf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cb3:	89 f9                	mov    %edi,%ecx
  800cb5:	d3 e8                	shr    %cl,%eax
  800cb7:	09 e8                	or     %ebp,%eax
  800cb9:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cbd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cc1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cc5:	d3 e0                	shl    %cl,%eax
  800cc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	d3 e2                	shl    %cl,%edx
  800ccf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cd3:	d3 e0                	shl    %cl,%eax
  800cd5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cd9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cdd:	89 f9                	mov    %edi,%ecx
  800cdf:	d3 e8                	shr    %cl,%eax
  800ce1:	09 d0                	or     %edx,%eax
  800ce3:	d3 ee                	shr    %cl,%esi
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	f7 74 24 18          	divl   0x18(%esp)
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	f7 64 24 0c          	mull   0xc(%esp)
  800cf1:	89 c5                	mov    %eax,%ebp
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	39 d6                	cmp    %edx,%esi
  800cf7:	72 67                	jb     800d60 <__umoddi3+0x114>
  800cf9:	74 75                	je     800d70 <__umoddi3+0x124>
  800cfb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cff:	29 e8                	sub    %ebp,%eax
  800d01:	19 ce                	sbb    %ecx,%esi
  800d03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 f2                	mov    %esi,%edx
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	d3 e2                	shl    %cl,%edx
  800d0f:	09 d0                	or     %edx,%eax
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d17:	d3 ea                	shr    %cl,%edx
  800d19:	83 c4 20             	add    $0x20,%esp
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
  800d20:	85 c9                	test   %ecx,%ecx
  800d22:	75 0b                	jne    800d2f <__umoddi3+0xe3>
  800d24:	b8 01 00 00 00       	mov    $0x1,%eax
  800d29:	31 d2                	xor    %edx,%edx
  800d2b:	f7 f1                	div    %ecx
  800d2d:	89 c1                	mov    %eax,%ecx
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	f7 f1                	div    %ecx
  800d35:	89 f8                	mov    %edi,%eax
  800d37:	e9 3e ff ff ff       	jmp    800c7a <__umoddi3+0x2e>
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	83 c4 20             	add    $0x20,%esp
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 f5                	cmp    %esi,%ebp
  800d4a:	72 04                	jb     800d50 <__umoddi3+0x104>
  800d4c:	39 f9                	cmp    %edi,%ecx
  800d4e:	77 06                	ja     800d56 <__umoddi3+0x10a>
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	29 cf                	sub    %ecx,%edi
  800d54:	19 ea                	sbb    %ebp,%edx
  800d56:	89 f8                	mov    %edi,%eax
  800d58:	83 c4 20             	add    $0x20,%esp
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    
  800d5f:	90                   	nop
  800d60:	89 d1                	mov    %edx,%ecx
  800d62:	89 c5                	mov    %eax,%ebp
  800d64:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d68:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d6c:	eb 8d                	jmp    800cfb <__umoddi3+0xaf>
  800d6e:	66 90                	xchg   %ax,%ax
  800d70:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d74:	72 ea                	jb     800d60 <__umoddi3+0x114>
  800d76:	89 f1                	mov    %esi,%ecx
  800d78:	eb 81                	jmp    800cfb <__umoddi3+0xaf>
