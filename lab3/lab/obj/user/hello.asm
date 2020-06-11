
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
  80003a:	c7 04 24 74 0d 80 00 	movl   $0x800d74,(%esp)
  800041:	e8 06 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 10 80 00       	mov    0x801004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 82 0d 80 00 	movl   $0x800d82,(%esp)
  800059:	e8 ee 00 00 00       	call   80014c <cprintf>
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
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800082:	89 54 24 04          	mov    %edx,0x4(%esp)
  800086:	89 04 24             	mov    %eax,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 05 00 00 00       	call   800098 <exit>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 af 09 00 00       	call   800a59 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 03                	mov    (%ebx),%eax
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000bf:	40                   	inc    %eax
  8000c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c7:	75 19                	jne    8000e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d0:	00 
  8000d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d4:	89 04 24             	mov    %eax,(%esp)
  8000d7:	e8 40 09 00 00       	call   800a1c <sys_cputs>
		b->idx = 0;
  8000dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e2:	ff 43 04             	incl   0x4(%ebx)
}
  8000e5:	83 c4 14             	add    $0x14,%esp
  8000e8:	5b                   	pop    %ebx
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010f:	8b 45 08             	mov    0x8(%ebp),%eax
  800112:	89 44 24 08          	mov    %eax,0x8(%esp)
  800116:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800120:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  800127:	e8 82 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013c:	89 04 24             	mov    %eax,(%esp)
  80013f:	e8 d8 08 00 00       	call   800a1c <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	8b 45 08             	mov    0x8(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 87 ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    
	...

00800168 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 3c             	sub    $0x3c,%esp
  800171:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800174:	89 d7                	mov    %edx,%edi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800182:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800185:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800188:	85 c0                	test   %eax,%eax
  80018a:	75 08                	jne    800194 <printnum+0x2c>
  80018c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80018f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800192:	77 57                	ja     8001eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800194:	89 74 24 10          	mov    %esi,0x10(%esp)
  800198:	4b                   	dec    %ebx
  800199:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80019d:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b3:	00 
  8001b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	e8 5e 09 00 00       	call   800b24 <__udivdi3>
  8001c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d5:	89 fa                	mov    %edi,%edx
  8001d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001da:	e8 89 ff ff ff       	call   800168 <printnum>
  8001df:	eb 0f                	jmp    8001f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001e5:	89 34 24             	mov    %esi,(%esp)
  8001e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001eb:	4b                   	dec    %ebx
  8001ec:	85 db                	test   %ebx,%ebx
  8001ee:	7f f1                	jg     8001e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800206:	00 
  800207:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020a:	89 04 24             	mov    %eax,(%esp)
  80020d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	e8 2b 0a 00 00       	call   800c44 <__umoddi3>
  800219:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021d:	0f be 80 a3 0d 80 00 	movsbl 0x800da3(%eax),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80022a:	83 c4 3c             	add    $0x3c,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5f                   	pop    %edi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800235:	83 fa 01             	cmp    $0x1,%edx
  800238:	7e 0e                	jle    800248 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023a:	8b 10                	mov    (%eax),%edx
  80023c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023f:	89 08                	mov    %ecx,(%eax)
  800241:	8b 02                	mov    (%edx),%eax
  800243:	8b 52 04             	mov    0x4(%edx),%edx
  800246:	eb 22                	jmp    80026a <getuint+0x38>
	else if (lflag)
  800248:	85 d2                	test   %edx,%edx
  80024a:	74 10                	je     80025c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80024c:	8b 10                	mov    (%eax),%edx
  80024e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800251:	89 08                	mov    %ecx,(%eax)
  800253:	8b 02                	mov    (%edx),%eax
  800255:	ba 00 00 00 00       	mov    $0x0,%edx
  80025a:	eb 0e                	jmp    80026a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800272:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 08                	jae    800284 <sprintputch+0x18>
		*b->buf++ = ch;
  80027c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027f:	88 0a                	mov    %cl,(%edx)
  800281:	42                   	inc    %edx
  800282:	89 10                	mov    %edx,(%eax)
}
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80028c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800293:	8b 45 10             	mov    0x10(%ebp),%eax
  800296:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a4:	89 04 24             	mov    %eax,(%esp)
  8002a7:	e8 02 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 4c             	sub    $0x4c,%esp
  8002b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8002bd:	eb 12                	jmp    8002d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	0f 84 6b 03 00 00    	je     800632 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d1:	0f b6 06             	movzbl (%esi),%eax
  8002d4:	46                   	inc    %esi
  8002d5:	83 f8 25             	cmp    $0x25,%eax
  8002d8:	75 e5                	jne    8002bf <vprintfmt+0x11>
  8002da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f6:	eb 26                	jmp    80031e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8002ff:	eb 1d                	jmp    80031e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800304:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800308:	eb 14                	jmp    80031e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80030d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800314:	eb 08                	jmp    80031e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800316:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800319:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	0f b6 06             	movzbl (%esi),%eax
  800321:	8d 56 01             	lea    0x1(%esi),%edx
  800324:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800327:	8a 16                	mov    (%esi),%dl
  800329:	83 ea 23             	sub    $0x23,%edx
  80032c:	80 fa 55             	cmp    $0x55,%dl
  80032f:	0f 87 e1 02 00 00    	ja     800616 <vprintfmt+0x368>
  800335:	0f b6 d2             	movzbl %dl,%edx
  800338:	ff 24 95 30 0e 80 00 	jmp    *0x800e30(,%edx,4)
  80033f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800342:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800347:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80034a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80034e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800351:	8d 50 d0             	lea    -0x30(%eax),%edx
  800354:	83 fa 09             	cmp    $0x9,%edx
  800357:	77 2a                	ja     800383 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800359:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035a:	eb eb                	jmp    800347 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 50 04             	lea    0x4(%eax),%edx
  800362:	89 55 14             	mov    %edx,0x14(%ebp)
  800365:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036a:	eb 17                	jmp    800383 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80036c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800370:	78 98                	js     80030a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800375:	eb a7                	jmp    80031e <vprintfmt+0x70>
  800377:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800381:	eb 9b                	jmp    80031e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800383:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800387:	79 95                	jns    80031e <vprintfmt+0x70>
  800389:	eb 8b                	jmp    800316 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038f:	eb 8d                	jmp    80031e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 50 04             	lea    0x4(%eax),%edx
  800397:	89 55 14             	mov    %edx,0x14(%ebp)
  80039a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a9:	e9 23 ff ff ff       	jmp    8002d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8d 50 04             	lea    0x4(%eax),%edx
  8003b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b7:	8b 00                	mov    (%eax),%eax
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	79 02                	jns    8003bf <vprintfmt+0x111>
  8003bd:	f7 d8                	neg    %eax
  8003bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c1:	83 f8 06             	cmp    $0x6,%eax
  8003c4:	7f 0b                	jg     8003d1 <vprintfmt+0x123>
  8003c6:	8b 04 85 88 0f 80 00 	mov    0x800f88(,%eax,4),%eax
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	75 23                	jne    8003f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d5:	c7 44 24 08 bb 0d 80 	movl   $0x800dbb,0x8(%esp)
  8003dc:	00 
  8003dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	e8 9a fe ff ff       	call   800286 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ef:	e9 dd fe ff ff       	jmp    8002d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8003f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f8:	c7 44 24 08 c4 0d 80 	movl   $0x800dc4,0x8(%esp)
  8003ff:	00 
  800400:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800404:	8b 55 08             	mov    0x8(%ebp),%edx
  800407:	89 14 24             	mov    %edx,(%esp)
  80040a:	e8 77 fe ff ff       	call   800286 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800412:	e9 ba fe ff ff       	jmp    8002d1 <vprintfmt+0x23>
  800417:	89 f9                	mov    %edi,%ecx
  800419:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	8b 30                	mov    (%eax),%esi
  80042a:	85 f6                	test   %esi,%esi
  80042c:	75 05                	jne    800433 <vprintfmt+0x185>
				p = "(null)";
  80042e:	be b4 0d 80 00       	mov    $0x800db4,%esi
			if (width > 0 && padc != '-')
  800433:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800437:	0f 8e 84 00 00 00    	jle    8004c1 <vprintfmt+0x213>
  80043d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800441:	74 7e                	je     8004c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800447:	89 34 24             	mov    %esi,(%esp)
  80044a:	e8 8b 02 00 00       	call   8006da <strnlen>
  80044f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800452:	29 c2                	sub    %eax,%edx
  800454:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800457:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80045b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80045e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800461:	89 de                	mov    %ebx,%esi
  800463:	89 d3                	mov    %edx,%ebx
  800465:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	eb 0b                	jmp    800474 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800469:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046d:	89 3c 24             	mov    %edi,(%esp)
  800470:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	4b                   	dec    %ebx
  800474:	85 db                	test   %ebx,%ebx
  800476:	7f f1                	jg     800469 <vprintfmt+0x1bb>
  800478:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80047b:	89 f3                	mov    %esi,%ebx
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800483:	85 c0                	test   %eax,%eax
  800485:	79 05                	jns    80048c <vprintfmt+0x1de>
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048f:	29 c2                	sub    %eax,%edx
  800491:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800494:	eb 2b                	jmp    8004c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800496:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80049a:	74 18                	je     8004b4 <vprintfmt+0x206>
  80049c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80049f:	83 fa 5e             	cmp    $0x5e,%edx
  8004a2:	76 10                	jbe    8004b4 <vprintfmt+0x206>
					putch('?', putdat);
  8004a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004af:	ff 55 08             	call   *0x8(%ebp)
  8004b2:	eb 0a                	jmp    8004be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	ff 4d e4             	decl   -0x1c(%ebp)
  8004c1:	0f be 06             	movsbl (%esi),%eax
  8004c4:	46                   	inc    %esi
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 21                	je     8004ea <vprintfmt+0x23c>
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	78 c9                	js     800496 <vprintfmt+0x1e8>
  8004cd:	4f                   	dec    %edi
  8004ce:	79 c6                	jns    800496 <vprintfmt+0x1e8>
  8004d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004d3:	89 de                	mov    %ebx,%esi
  8004d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004d8:	eb 18                	jmp    8004f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e7:	4b                   	dec    %ebx
  8004e8:	eb 08                	jmp    8004f2 <vprintfmt+0x244>
  8004ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ed:	89 de                	mov    %ebx,%esi
  8004ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f2:	85 db                	test   %ebx,%ebx
  8004f4:	7f e4                	jg     8004da <vprintfmt+0x22c>
  8004f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8004f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fe:	e9 ce fd ff ff       	jmp    8002d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800503:	83 f9 01             	cmp    $0x1,%ecx
  800506:	7e 10                	jle    800518 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 08             	lea    0x8(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 30                	mov    (%eax),%esi
  800513:	8b 78 04             	mov    0x4(%eax),%edi
  800516:	eb 26                	jmp    80053e <vprintfmt+0x290>
	else if (lflag)
  800518:	85 c9                	test   %ecx,%ecx
  80051a:	74 12                	je     80052e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 50 04             	lea    0x4(%eax),%edx
  800522:	89 55 14             	mov    %edx,0x14(%ebp)
  800525:	8b 30                	mov    (%eax),%esi
  800527:	89 f7                	mov    %esi,%edi
  800529:	c1 ff 1f             	sar    $0x1f,%edi
  80052c:	eb 10                	jmp    80053e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 30                	mov    (%eax),%esi
  800539:	89 f7                	mov    %esi,%edi
  80053b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80053e:	85 ff                	test   %edi,%edi
  800540:	78 0a                	js     80054c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800542:	b8 0a 00 00 00       	mov    $0xa,%eax
  800547:	e9 8c 00 00 00       	jmp    8005d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80054c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800550:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800557:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80055a:	f7 de                	neg    %esi
  80055c:	83 d7 00             	adc    $0x0,%edi
  80055f:	f7 df                	neg    %edi
			}
			base = 10;
  800561:	b8 0a 00 00 00       	mov    $0xa,%eax
  800566:	eb 70                	jmp    8005d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800568:	89 ca                	mov    %ecx,%edx
  80056a:	8d 45 14             	lea    0x14(%ebp),%eax
  80056d:	e8 c0 fc ff ff       	call   800232 <getuint>
  800572:	89 c6                	mov    %eax,%esi
  800574:	89 d7                	mov    %edx,%edi
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80057b:	eb 5b                	jmp    8005d8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80057d:	89 ca                	mov    %ecx,%edx
  80057f:	8d 45 14             	lea    0x14(%ebp),%eax
  800582:	e8 ab fc ff ff       	call   800232 <getuint>
  800587:	89 c6                	mov    %eax,%esi
  800589:	89 d7                	mov    %edx,%edi
			base = 8;
  80058b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800590:	eb 46                	jmp    8005d8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800596:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80059d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b7:	8b 30                	mov    (%eax),%esi
  8005b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005c3:	eb 13                	jmp    8005d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c5:	89 ca                	mov    %ecx,%edx
  8005c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ca:	e8 63 fc ff ff       	call   800232 <getuint>
  8005cf:	89 c6                	mov    %eax,%esi
  8005d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8005d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f2:	89 da                	mov    %ebx,%edx
  8005f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f7:	e8 6c fb ff ff       	call   800168 <printnum>
			break;
  8005fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ff:	e9 cd fc ff ff       	jmp    8002d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	89 04 24             	mov    %eax,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800611:	e9 bb fc ff ff       	jmp    8002d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800616:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800621:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800624:	eb 01                	jmp    800627 <vprintfmt+0x379>
  800626:	4e                   	dec    %esi
  800627:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80062b:	75 f9                	jne    800626 <vprintfmt+0x378>
  80062d:	e9 9f fc ff ff       	jmp    8002d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800632:	83 c4 4c             	add    $0x4c,%esp
  800635:	5b                   	pop    %ebx
  800636:	5e                   	pop    %esi
  800637:	5f                   	pop    %edi
  800638:	5d                   	pop    %ebp
  800639:	c3                   	ret    

0080063a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	83 ec 28             	sub    $0x28,%esp
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800646:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800649:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800650:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800657:	85 c0                	test   %eax,%eax
  800659:	74 30                	je     80068b <vsnprintf+0x51>
  80065b:	85 d2                	test   %edx,%edx
  80065d:	7e 33                	jle    800692 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800666:	8b 45 10             	mov    0x10(%ebp),%eax
  800669:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 6c 02 80 00 	movl   $0x80026c,(%esp)
  80067b:	e8 2e fc ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800680:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800683:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	eb 0c                	jmp    800697 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800690:	eb 05                	jmp    800697 <vsnprintf+0x5d>
  800692:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	e8 7b ff ff ff       	call   80063a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    
  8006c1:	00 00                	add    %al,(%eax)
	...

008006c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cf:	eb 01                	jmp    8006d2 <strlen+0xe>
		n++;
  8006d1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d6:	75 f9                	jne    8006d1 <strlen+0xd>
		n++;
	return n;
}
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006e0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	eb 01                	jmp    8006eb <strnlen+0x11>
		n++;
  8006ea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006eb:	39 d0                	cmp    %edx,%eax
  8006ed:	74 06                	je     8006f5 <strnlen+0x1b>
  8006ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006f3:	75 f5                	jne    8006ea <strnlen+0x10>
		n++;
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
  800706:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800709:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80070c:	42                   	inc    %edx
  80070d:	84 c9                	test   %cl,%cl
  80070f:	75 f5                	jne    800706 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800711:	5b                   	pop    %ebx
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071e:	89 1c 24             	mov    %ebx,(%esp)
  800721:	e8 9e ff ff ff       	call   8006c4 <strlen>
	strcpy(dst + len, src);
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
  800729:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072d:	01 d8                	add    %ebx,%eax
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	e8 c0 ff ff ff       	call   8006f7 <strcpy>
	return dst;
}
  800737:	89 d8                	mov    %ebx,%eax
  800739:	83 c4 08             	add    $0x8,%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	56                   	push   %esi
  800743:	53                   	push   %ebx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	eb 0c                	jmp    800760 <strncpy+0x21>
		*dst++ = *src;
  800754:	8a 1a                	mov    (%edx),%bl
  800756:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800759:	80 3a 01             	cmpb   $0x1,(%edx)
  80075c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075f:	41                   	inc    %ecx
  800760:	39 f1                	cmp    %esi,%ecx
  800762:	75 f0                	jne    800754 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800764:	5b                   	pop    %ebx
  800765:	5e                   	pop    %esi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800773:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800776:	85 d2                	test   %edx,%edx
  800778:	75 0a                	jne    800784 <strlcpy+0x1c>
  80077a:	89 f0                	mov    %esi,%eax
  80077c:	eb 1a                	jmp    800798 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80077e:	88 18                	mov    %bl,(%eax)
  800780:	40                   	inc    %eax
  800781:	41                   	inc    %ecx
  800782:	eb 02                	jmp    800786 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800784:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800786:	4a                   	dec    %edx
  800787:	74 0a                	je     800793 <strlcpy+0x2b>
  800789:	8a 19                	mov    (%ecx),%bl
  80078b:	84 db                	test   %bl,%bl
  80078d:	75 ef                	jne    80077e <strlcpy+0x16>
  80078f:	89 c2                	mov    %eax,%edx
  800791:	eb 02                	jmp    800795 <strlcpy+0x2d>
  800793:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800795:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800798:	29 f0                	sub    %esi,%eax
}
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a7:	eb 02                	jmp    8007ab <strcmp+0xd>
		p++, q++;
  8007a9:	41                   	inc    %ecx
  8007aa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ab:	8a 01                	mov    (%ecx),%al
  8007ad:	84 c0                	test   %al,%al
  8007af:	74 04                	je     8007b5 <strcmp+0x17>
  8007b1:	3a 02                	cmp    (%edx),%al
  8007b3:	74 f4                	je     8007a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b5:	0f b6 c0             	movzbl %al,%eax
  8007b8:	0f b6 12             	movzbl (%edx),%edx
  8007bb:	29 d0                	sub    %edx,%eax
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007cc:	eb 03                	jmp    8007d1 <strncmp+0x12>
		n--, p++, q++;
  8007ce:	4a                   	dec    %edx
  8007cf:	40                   	inc    %eax
  8007d0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	74 14                	je     8007e9 <strncmp+0x2a>
  8007d5:	8a 18                	mov    (%eax),%bl
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	74 04                	je     8007df <strncmp+0x20>
  8007db:	3a 19                	cmp    (%ecx),%bl
  8007dd:	74 ef                	je     8007ce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 00             	movzbl (%eax),%eax
  8007e2:	0f b6 11             	movzbl (%ecx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
  8007e7:	eb 05                	jmp    8007ee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ee:	5b                   	pop    %ebx
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8007fa:	eb 05                	jmp    800801 <strchr+0x10>
		if (*s == c)
  8007fc:	38 ca                	cmp    %cl,%dl
  8007fe:	74 0c                	je     80080c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800800:	40                   	inc    %eax
  800801:	8a 10                	mov    (%eax),%dl
  800803:	84 d2                	test   %dl,%dl
  800805:	75 f5                	jne    8007fc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800817:	eb 05                	jmp    80081e <strfind+0x10>
		if (*s == c)
  800819:	38 ca                	cmp    %cl,%dl
  80081b:	74 07                	je     800824 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80081d:	40                   	inc    %eax
  80081e:	8a 10                	mov    (%eax),%dl
  800820:	84 d2                	test   %dl,%dl
  800822:	75 f5                	jne    800819 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	57                   	push   %edi
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800832:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 30                	je     800869 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800839:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80083f:	75 25                	jne    800866 <memset+0x40>
  800841:	f6 c1 03             	test   $0x3,%cl
  800844:	75 20                	jne    800866 <memset+0x40>
		c &= 0xFF;
  800846:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800849:	89 d3                	mov    %edx,%ebx
  80084b:	c1 e3 08             	shl    $0x8,%ebx
  80084e:	89 d6                	mov    %edx,%esi
  800850:	c1 e6 18             	shl    $0x18,%esi
  800853:	89 d0                	mov    %edx,%eax
  800855:	c1 e0 10             	shl    $0x10,%eax
  800858:	09 f0                	or     %esi,%eax
  80085a:	09 d0                	or     %edx,%eax
  80085c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80085e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800861:	fc                   	cld    
  800862:	f3 ab                	rep stos %eax,%es:(%edi)
  800864:	eb 03                	jmp    800869 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800866:	fc                   	cld    
  800867:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800869:	89 f8                	mov    %edi,%eax
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5f                   	pop    %edi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	57                   	push   %edi
  800874:	56                   	push   %esi
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 75 0c             	mov    0xc(%ebp),%esi
  80087b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80087e:	39 c6                	cmp    %eax,%esi
  800880:	73 34                	jae    8008b6 <memmove+0x46>
  800882:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800885:	39 d0                	cmp    %edx,%eax
  800887:	73 2d                	jae    8008b6 <memmove+0x46>
		s += n;
		d += n;
  800889:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088c:	f6 c2 03             	test   $0x3,%dl
  80088f:	75 1b                	jne    8008ac <memmove+0x3c>
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 13                	jne    8008ac <memmove+0x3c>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	75 0e                	jne    8008ac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80089e:	83 ef 04             	sub    $0x4,%edi
  8008a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008a4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008a7:	fd                   	std    
  8008a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008aa:	eb 07                	jmp    8008b3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ac:	4f                   	dec    %edi
  8008ad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b0:	fd                   	std    
  8008b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b3:	fc                   	cld    
  8008b4:	eb 20                	jmp    8008d6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008bc:	75 13                	jne    8008d1 <memmove+0x61>
  8008be:	a8 03                	test   $0x3,%al
  8008c0:	75 0f                	jne    8008d1 <memmove+0x61>
  8008c2:	f6 c1 03             	test   $0x3,%cl
  8008c5:	75 0a                	jne    8008d1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008c7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ca:	89 c7                	mov    %eax,%edi
  8008cc:	fc                   	cld    
  8008cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cf:	eb 05                	jmp    8008d6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d1:	89 c7                	mov    %eax,%edi
  8008d3:	fc                   	cld    
  8008d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d6:	5e                   	pop    %esi
  8008d7:	5f                   	pop    %edi
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	89 04 24             	mov    %eax,(%esp)
  8008f4:	e8 77 ff ff ff       	call   800870 <memmove>
}
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 75 0c             	mov    0xc(%ebp),%esi
  800907:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090a:	ba 00 00 00 00       	mov    $0x0,%edx
  80090f:	eb 16                	jmp    800927 <memcmp+0x2c>
		if (*s1 != *s2)
  800911:	8a 04 17             	mov    (%edi,%edx,1),%al
  800914:	42                   	inc    %edx
  800915:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800919:	38 c8                	cmp    %cl,%al
  80091b:	74 0a                	je     800927 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80091d:	0f b6 c0             	movzbl %al,%eax
  800920:	0f b6 c9             	movzbl %cl,%ecx
  800923:	29 c8                	sub    %ecx,%eax
  800925:	eb 09                	jmp    800930 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800927:	39 da                	cmp    %ebx,%edx
  800929:	75 e6                	jne    800911 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80093e:	89 c2                	mov    %eax,%edx
  800940:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800943:	eb 05                	jmp    80094a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800945:	38 08                	cmp    %cl,(%eax)
  800947:	74 05                	je     80094e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800949:	40                   	inc    %eax
  80094a:	39 d0                	cmp    %edx,%eax
  80094c:	72 f7                	jb     800945 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 55 08             	mov    0x8(%ebp),%edx
  800959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095c:	eb 01                	jmp    80095f <strtol+0xf>
		s++;
  80095e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095f:	8a 02                	mov    (%edx),%al
  800961:	3c 20                	cmp    $0x20,%al
  800963:	74 f9                	je     80095e <strtol+0xe>
  800965:	3c 09                	cmp    $0x9,%al
  800967:	74 f5                	je     80095e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800969:	3c 2b                	cmp    $0x2b,%al
  80096b:	75 08                	jne    800975 <strtol+0x25>
		s++;
  80096d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80096e:	bf 00 00 00 00       	mov    $0x0,%edi
  800973:	eb 13                	jmp    800988 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800975:	3c 2d                	cmp    $0x2d,%al
  800977:	75 0a                	jne    800983 <strtol+0x33>
		s++, neg = 1;
  800979:	8d 52 01             	lea    0x1(%edx),%edx
  80097c:	bf 01 00 00 00       	mov    $0x1,%edi
  800981:	eb 05                	jmp    800988 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800983:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800988:	85 db                	test   %ebx,%ebx
  80098a:	74 05                	je     800991 <strtol+0x41>
  80098c:	83 fb 10             	cmp    $0x10,%ebx
  80098f:	75 28                	jne    8009b9 <strtol+0x69>
  800991:	8a 02                	mov    (%edx),%al
  800993:	3c 30                	cmp    $0x30,%al
  800995:	75 10                	jne    8009a7 <strtol+0x57>
  800997:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80099b:	75 0a                	jne    8009a7 <strtol+0x57>
		s += 2, base = 16;
  80099d:	83 c2 02             	add    $0x2,%edx
  8009a0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a5:	eb 12                	jmp    8009b9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009a7:	85 db                	test   %ebx,%ebx
  8009a9:	75 0e                	jne    8009b9 <strtol+0x69>
  8009ab:	3c 30                	cmp    $0x30,%al
  8009ad:	75 05                	jne    8009b4 <strtol+0x64>
		s++, base = 8;
  8009af:	42                   	inc    %edx
  8009b0:	b3 08                	mov    $0x8,%bl
  8009b2:	eb 05                	jmp    8009b9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009b4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009be:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c0:	8a 0a                	mov    (%edx),%cl
  8009c2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009c5:	80 fb 09             	cmp    $0x9,%bl
  8009c8:	77 08                	ja     8009d2 <strtol+0x82>
			dig = *s - '0';
  8009ca:	0f be c9             	movsbl %cl,%ecx
  8009cd:	83 e9 30             	sub    $0x30,%ecx
  8009d0:	eb 1e                	jmp    8009f0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009d2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009d5:	80 fb 19             	cmp    $0x19,%bl
  8009d8:	77 08                	ja     8009e2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009da:	0f be c9             	movsbl %cl,%ecx
  8009dd:	83 e9 57             	sub    $0x57,%ecx
  8009e0:	eb 0e                	jmp    8009f0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009e2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009e5:	80 fb 19             	cmp    $0x19,%bl
  8009e8:	77 12                	ja     8009fc <strtol+0xac>
			dig = *s - 'A' + 10;
  8009ea:	0f be c9             	movsbl %cl,%ecx
  8009ed:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8009f0:	39 f1                	cmp    %esi,%ecx
  8009f2:	7d 0c                	jge    800a00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8009f4:	42                   	inc    %edx
  8009f5:	0f af c6             	imul   %esi,%eax
  8009f8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8009fa:	eb c4                	jmp    8009c0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8009fc:	89 c1                	mov    %eax,%ecx
  8009fe:	eb 02                	jmp    800a02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a06:	74 05                	je     800a0d <strtol+0xbd>
		*endptr = (char *) s;
  800a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a0d:	85 ff                	test   %edi,%edi
  800a0f:	74 04                	je     800a15 <strtol+0xc5>
  800a11:	89 c8                	mov    %ecx,%eax
  800a13:	f7 d8                	neg    %eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5f                   	pop    %edi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    
	...

00800a1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2d:	89 c3                	mov    %eax,%ebx
  800a2f:	89 c7                	mov    %eax,%edi
  800a31:	89 c6                	mov    %eax,%esi
  800a33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4a:	89 d1                	mov    %edx,%ecx
  800a4c:	89 d3                	mov    %edx,%ebx
  800a4e:	89 d7                	mov    %edx,%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a67:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6f:	89 cb                	mov    %ecx,%ebx
  800a71:	89 cf                	mov    %ecx,%edi
  800a73:	89 ce                	mov    %ecx,%esi
  800a75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a77:	85 c0                	test   %eax,%eax
  800a79:	7e 28                	jle    800aa3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a7f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a86:	00 
  800a87:	c7 44 24 08 a4 0f 80 	movl   $0x800fa4,0x8(%esp)
  800a8e:	00 
  800a8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800a96:	00 
  800a97:	c7 04 24 c1 0f 80 00 	movl   $0x800fc1,(%esp)
  800a9e:	e8 29 00 00 00       	call   800acc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa3:	83 c4 2c             	add    $0x2c,%esp
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	b8 02 00 00 00       	mov    $0x2,%eax
  800abb:	89 d1                	mov    %edx,%ecx
  800abd:	89 d3                	mov    %edx,%ebx
  800abf:	89 d7                	mov    %edx,%edi
  800ac1:	89 d6                	mov    %edx,%esi
  800ac3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    
	...

00800acc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ad4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ad7:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800add:	e8 c9 ff ff ff       	call   800aab <sys_getenvid>
  800ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800af0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af8:	c7 04 24 d0 0f 80 00 	movl   $0x800fd0,(%esp)
  800aff:	e8 48 f6 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b08:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0b:	89 04 24             	mov    %eax,(%esp)
  800b0e:	e8 d8 f5 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800b13:	c7 04 24 80 0d 80 00 	movl   $0x800d80,(%esp)
  800b1a:	e8 2d f6 ff ff       	call   80014c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b1f:	cc                   	int3   
  800b20:	eb fd                	jmp    800b1f <_panic+0x53>
	...

00800b24 <__udivdi3>:
  800b24:	55                   	push   %ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	83 ec 10             	sub    $0x10,%esp
  800b2a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b2e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b36:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b3a:	89 cd                	mov    %ecx,%ebp
  800b3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b40:	85 c0                	test   %eax,%eax
  800b42:	75 2c                	jne    800b70 <__udivdi3+0x4c>
  800b44:	39 f9                	cmp    %edi,%ecx
  800b46:	77 68                	ja     800bb0 <__udivdi3+0x8c>
  800b48:	85 c9                	test   %ecx,%ecx
  800b4a:	75 0b                	jne    800b57 <__udivdi3+0x33>
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	31 d2                	xor    %edx,%edx
  800b53:	f7 f1                	div    %ecx
  800b55:	89 c1                	mov    %eax,%ecx
  800b57:	31 d2                	xor    %edx,%edx
  800b59:	89 f8                	mov    %edi,%eax
  800b5b:	f7 f1                	div    %ecx
  800b5d:	89 c7                	mov    %eax,%edi
  800b5f:	89 f0                	mov    %esi,%eax
  800b61:	f7 f1                	div    %ecx
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	89 f0                	mov    %esi,%eax
  800b67:	89 fa                	mov    %edi,%edx
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    
  800b70:	39 f8                	cmp    %edi,%eax
  800b72:	77 2c                	ja     800ba0 <__udivdi3+0x7c>
  800b74:	0f bd f0             	bsr    %eax,%esi
  800b77:	83 f6 1f             	xor    $0x1f,%esi
  800b7a:	75 4c                	jne    800bc8 <__udivdi3+0xa4>
  800b7c:	39 f8                	cmp    %edi,%eax
  800b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b83:	72 0a                	jb     800b8f <__udivdi3+0x6b>
  800b85:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b89:	0f 87 ad 00 00 00    	ja     800c3c <__udivdi3+0x118>
  800b8f:	be 01 00 00 00       	mov    $0x1,%esi
  800b94:	89 f0                	mov    %esi,%eax
  800b96:	89 fa                	mov    %edi,%edx
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    
  800b9f:	90                   	nop
  800ba0:	31 ff                	xor    %edi,%edi
  800ba2:	31 f6                	xor    %esi,%esi
  800ba4:	89 f0                	mov    %esi,%eax
  800ba6:	89 fa                	mov    %edi,%edx
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    
  800baf:	90                   	nop
  800bb0:	89 fa                	mov    %edi,%edx
  800bb2:	89 f0                	mov    %esi,%eax
  800bb4:	f7 f1                	div    %ecx
  800bb6:	89 c6                	mov    %eax,%esi
  800bb8:	31 ff                	xor    %edi,%edi
  800bba:	89 f0                	mov    %esi,%eax
  800bbc:	89 fa                	mov    %edi,%edx
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	8d 76 00             	lea    0x0(%esi),%esi
  800bc8:	89 f1                	mov    %esi,%ecx
  800bca:	d3 e0                	shl    %cl,%eax
  800bcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd0:	b8 20 00 00 00       	mov    $0x20,%eax
  800bd5:	29 f0                	sub    %esi,%eax
  800bd7:	89 ea                	mov    %ebp,%edx
  800bd9:	88 c1                	mov    %al,%cl
  800bdb:	d3 ea                	shr    %cl,%edx
  800bdd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800be1:	09 ca                	or     %ecx,%edx
  800be3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800be7:	89 f1                	mov    %esi,%ecx
  800be9:	d3 e5                	shl    %cl,%ebp
  800beb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bef:	89 fd                	mov    %edi,%ebp
  800bf1:	88 c1                	mov    %al,%cl
  800bf3:	d3 ed                	shr    %cl,%ebp
  800bf5:	89 fa                	mov    %edi,%edx
  800bf7:	89 f1                	mov    %esi,%ecx
  800bf9:	d3 e2                	shl    %cl,%edx
  800bfb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bff:	88 c1                	mov    %al,%cl
  800c01:	d3 ef                	shr    %cl,%edi
  800c03:	09 d7                	or     %edx,%edi
  800c05:	89 f8                	mov    %edi,%eax
  800c07:	89 ea                	mov    %ebp,%edx
  800c09:	f7 74 24 08          	divl   0x8(%esp)
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	f7 64 24 0c          	mull   0xc(%esp)
  800c15:	39 d1                	cmp    %edx,%ecx
  800c17:	72 17                	jb     800c30 <__udivdi3+0x10c>
  800c19:	74 09                	je     800c24 <__udivdi3+0x100>
  800c1b:	89 fe                	mov    %edi,%esi
  800c1d:	31 ff                	xor    %edi,%edi
  800c1f:	e9 41 ff ff ff       	jmp    800b65 <__udivdi3+0x41>
  800c24:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c28:	89 f1                	mov    %esi,%ecx
  800c2a:	d3 e2                	shl    %cl,%edx
  800c2c:	39 c2                	cmp    %eax,%edx
  800c2e:	73 eb                	jae    800c1b <__udivdi3+0xf7>
  800c30:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c33:	31 ff                	xor    %edi,%edi
  800c35:	e9 2b ff ff ff       	jmp    800b65 <__udivdi3+0x41>
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	31 f6                	xor    %esi,%esi
  800c3e:	e9 22 ff ff ff       	jmp    800b65 <__udivdi3+0x41>
	...

00800c44 <__umoddi3>:
  800c44:	55                   	push   %ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	83 ec 20             	sub    $0x20,%esp
  800c4a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c52:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c56:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	89 f2                	mov    %esi,%edx
  800c66:	85 ed                	test   %ebp,%ebp
  800c68:	75 16                	jne    800c80 <__umoddi3+0x3c>
  800c6a:	39 f1                	cmp    %esi,%ecx
  800c6c:	0f 86 a6 00 00 00    	jbe    800d18 <__umoddi3+0xd4>
  800c72:	f7 f1                	div    %ecx
  800c74:	89 d0                	mov    %edx,%eax
  800c76:	31 d2                	xor    %edx,%edx
  800c78:	83 c4 20             	add    $0x20,%esp
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
  800c7f:	90                   	nop
  800c80:	39 f5                	cmp    %esi,%ebp
  800c82:	0f 87 ac 00 00 00    	ja     800d34 <__umoddi3+0xf0>
  800c88:	0f bd c5             	bsr    %ebp,%eax
  800c8b:	83 f0 1f             	xor    $0x1f,%eax
  800c8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c92:	0f 84 a8 00 00 00    	je     800d40 <__umoddi3+0xfc>
  800c98:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c9c:	d3 e5                	shl    %cl,%ebp
  800c9e:	bf 20 00 00 00       	mov    $0x20,%edi
  800ca3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800ca7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cab:	89 f9                	mov    %edi,%ecx
  800cad:	d3 e8                	shr    %cl,%eax
  800caf:	09 e8                	or     %ebp,%eax
  800cb1:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cb5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cb9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cbd:	d3 e0                	shl    %cl,%eax
  800cbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc3:	89 f2                	mov    %esi,%edx
  800cc5:	d3 e2                	shl    %cl,%edx
  800cc7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ccb:	d3 e0                	shl    %cl,%eax
  800ccd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cd1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cd5:	89 f9                	mov    %edi,%ecx
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	09 d0                	or     %edx,%eax
  800cdb:	d3 ee                	shr    %cl,%esi
  800cdd:	89 f2                	mov    %esi,%edx
  800cdf:	f7 74 24 18          	divl   0x18(%esp)
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	f7 64 24 0c          	mull   0xc(%esp)
  800ce9:	89 c5                	mov    %eax,%ebp
  800ceb:	89 d1                	mov    %edx,%ecx
  800ced:	39 d6                	cmp    %edx,%esi
  800cef:	72 67                	jb     800d58 <__umoddi3+0x114>
  800cf1:	74 75                	je     800d68 <__umoddi3+0x124>
  800cf3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cf7:	29 e8                	sub    %ebp,%eax
  800cf9:	19 ce                	sbb    %ecx,%esi
  800cfb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cff:	d3 e8                	shr    %cl,%eax
  800d01:	89 f2                	mov    %esi,%edx
  800d03:	89 f9                	mov    %edi,%ecx
  800d05:	d3 e2                	shl    %cl,%edx
  800d07:	09 d0                	or     %edx,%eax
  800d09:	89 f2                	mov    %esi,%edx
  800d0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d0f:	d3 ea                	shr    %cl,%edx
  800d11:	83 c4 20             	add    $0x20,%esp
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
  800d18:	85 c9                	test   %ecx,%ecx
  800d1a:	75 0b                	jne    800d27 <__umoddi3+0xe3>
  800d1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	f7 f1                	div    %ecx
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	89 f0                	mov    %esi,%eax
  800d29:	31 d2                	xor    %edx,%edx
  800d2b:	f7 f1                	div    %ecx
  800d2d:	89 f8                	mov    %edi,%eax
  800d2f:	e9 3e ff ff ff       	jmp    800c72 <__umoddi3+0x2e>
  800d34:	89 f2                	mov    %esi,%edx
  800d36:	83 c4 20             	add    $0x20,%esp
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
  800d3d:	8d 76 00             	lea    0x0(%esi),%esi
  800d40:	39 f5                	cmp    %esi,%ebp
  800d42:	72 04                	jb     800d48 <__umoddi3+0x104>
  800d44:	39 f9                	cmp    %edi,%ecx
  800d46:	77 06                	ja     800d4e <__umoddi3+0x10a>
  800d48:	89 f2                	mov    %esi,%edx
  800d4a:	29 cf                	sub    %ecx,%edi
  800d4c:	19 ea                	sbb    %ebp,%edx
  800d4e:	89 f8                	mov    %edi,%eax
  800d50:	83 c4 20             	add    $0x20,%esp
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    
  800d57:	90                   	nop
  800d58:	89 d1                	mov    %edx,%ecx
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d60:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d64:	eb 8d                	jmp    800cf3 <__umoddi3+0xaf>
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d6c:	72 ea                	jb     800d58 <__umoddi3+0x114>
  800d6e:	89 f1                	mov    %esi,%ecx
  800d70:	eb 81                	jmp    800cf3 <__umoddi3+0xaf>
