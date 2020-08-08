
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  800054:	e8 37 01 00 00       	call   800190 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 b1 0a 00 00       	call   800b0f <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 57 0a 00 00       	call   800abd <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 ea 0c 00 00       	call   800d64 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800096:	e8 74 0a 00 00       	call   800b0f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b6:	85 f6                	test   %esi,%esi
  8000b8:	7e 07                	jle    8000c1 <libmain+0x39>
		binaryname = argv[0];
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c5:	89 34 24             	mov    %esi,(%esp)
  8000c8:	e8 9b ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0a 00 00 00       	call   8000dc <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    
  8000d9:	00 00                	add    %al,(%eax)
	...

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 cf 09 00 00       	call   800abd <sys_env_destroy>
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 14             	sub    $0x14,%esp
  8000f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fa:	8b 03                	mov    (%ebx),%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800103:	40                   	inc    %eax
  800104:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800106:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010b:	75 19                	jne    800126 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80010d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800114:	00 
  800115:	8d 43 08             	lea    0x8(%ebx),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 60 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800126:	ff 43 04             	incl   0x4(%ebx)
}
  800129:	83 c4 14             	add    $0x14,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800138:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013f:	00 00 00 
	b.cnt = 0;
  800142:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800149:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800153:	8b 45 08             	mov    0x8(%ebp),%eax
  800156:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	c7 04 24 f0 00 80 00 	movl   $0x8000f0,(%esp)
  80016b:	e8 82 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 f8 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 87 ff ff ff       	call   80012f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    
	...

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 3c             	sub    $0x3c,%esp
  8001b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b8:	89 d7                	mov    %edx,%edi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	75 08                	jne    8001d8 <printnum+0x2c>
  8001d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 57                	ja     80022f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001dc:	4b                   	dec    %ebx
  8001dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f7:	00 
  8001f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	e8 76 0c 00 00       	call   800e80 <__udivdi3>
  80020a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 fa                	mov    %edi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 89 ff ff ff       	call   8001ac <printnum>
  800223:	eb 0f                	jmp    800234 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800229:	89 34 24             	mov    %esi,(%esp)
  80022c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022f:	4b                   	dec    %ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f f1                	jg     800225 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800238:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	e8 43 0d 00 00       	call   800fa0 <__umoddi3>
  80025d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800261:	0f be 80 06 11 80 00 	movsbl 0x801106(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 3c             	add    $0x3c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002be:	73 08                	jae    8002c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c3:	88 0a                	mov    %cl,(%edx)
  8002c5:	42                   	inc    %edx
  8002c6:	89 10                	mov    %edx,(%eax)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 02 00 00 00       	call   8002f2 <vprintfmt>
	va_end(ap);
}
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 4c             	sub    $0x4c,%esp
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800301:	eb 12                	jmp    800315 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800303:	85 c0                	test   %eax,%eax
  800305:	0f 84 8b 03 00 00    	je     800696 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80030b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800315:	0f b6 06             	movzbl (%esi),%eax
  800318:	46                   	inc    %esi
  800319:	83 f8 25             	cmp    $0x25,%eax
  80031c:	75 e5                	jne    800303 <vprintfmt+0x11>
  80031e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800329:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80032e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	eb 26                	jmp    800362 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800343:	eb 1d                	jmp    800362 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80034c:	eb 14                	jmp    800362 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800351:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800358:	eb 08                	jmp    800362 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80035d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	0f b6 06             	movzbl (%esi),%eax
  800365:	8d 56 01             	lea    0x1(%esi),%edx
  800368:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80036b:	8a 16                	mov    (%esi),%dl
  80036d:	83 ea 23             	sub    $0x23,%edx
  800370:	80 fa 55             	cmp    $0x55,%dl
  800373:	0f 87 01 03 00 00    	ja     80067a <vprintfmt+0x388>
  800379:	0f b6 d2             	movzbl %dl,%edx
  80037c:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800386:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80038e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800392:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800395:	8d 50 d0             	lea    -0x30(%eax),%edx
  800398:	83 fa 09             	cmp    $0x9,%edx
  80039b:	77 2a                	ja     8003c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80039e:	eb eb                	jmp    80038b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ae:	eb 17                	jmp    8003c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b4:	78 98                	js     80034e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b9:	eb a7                	jmp    800362 <vprintfmt+0x70>
  8003bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003c5:	eb 9b                	jmp    800362 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cb:	79 95                	jns    800362 <vprintfmt+0x70>
  8003cd:	eb 8b                	jmp    80035a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d3:	eb 8d                	jmp    800362 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 50 04             	lea    0x4(%eax),%edx
  8003db:	89 55 14             	mov    %edx,0x14(%ebp)
  8003de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ed:	e9 23 ff ff ff       	jmp    800315 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	79 02                	jns    800403 <vprintfmt+0x111>
  800401:	f7 d8                	neg    %eax
  800403:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800405:	83 f8 08             	cmp    $0x8,%eax
  800408:	7f 0b                	jg     800415 <vprintfmt+0x123>
  80040a:	8b 04 85 20 13 80 00 	mov    0x801320(,%eax,4),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	75 23                	jne    800438 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800415:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800419:	c7 44 24 08 1e 11 80 	movl   $0x80111e,0x8(%esp)
  800420:	00 
  800421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 9a fe ff ff       	call   8002ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800433:	e9 dd fe ff ff       	jmp    800315 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800438:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043c:	c7 44 24 08 27 11 80 	movl   $0x801127,0x8(%esp)
  800443:	00 
  800444:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800448:	8b 55 08             	mov    0x8(%ebp),%edx
  80044b:	89 14 24             	mov    %edx,(%esp)
  80044e:	e8 77 fe ff ff       	call   8002ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800456:	e9 ba fe ff ff       	jmp    800315 <vprintfmt+0x23>
  80045b:	89 f9                	mov    %edi,%ecx
  80045d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800460:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 30                	mov    (%eax),%esi
  80046e:	85 f6                	test   %esi,%esi
  800470:	75 05                	jne    800477 <vprintfmt+0x185>
				p = "(null)";
  800472:	be 17 11 80 00       	mov    $0x801117,%esi
			if (width > 0 && padc != '-')
  800477:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047b:	0f 8e 84 00 00 00    	jle    800505 <vprintfmt+0x213>
  800481:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800485:	74 7e                	je     800505 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80048b:	89 34 24             	mov    %esi,(%esp)
  80048e:	e8 ab 02 00 00       	call   80073e <strnlen>
  800493:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800496:	29 c2                	sub    %eax,%edx
  800498:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80049b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80049f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004a5:	89 de                	mov    %ebx,%esi
  8004a7:	89 d3                	mov    %edx,%ebx
  8004a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	eb 0b                	jmp    8004b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b1:	89 3c 24             	mov    %edi,(%esp)
  8004b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	4b                   	dec    %ebx
  8004b8:	85 db                	test   %ebx,%ebx
  8004ba:	7f f1                	jg     8004ad <vprintfmt+0x1bb>
  8004bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004bf:	89 f3                	mov    %esi,%ebx
  8004c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	79 05                	jns    8004d0 <vprintfmt+0x1de>
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d8:	eb 2b                	jmp    800505 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004de:	74 18                	je     8004f8 <vprintfmt+0x206>
  8004e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e3:	83 fa 5e             	cmp    $0x5e,%edx
  8004e6:	76 10                	jbe    8004f8 <vprintfmt+0x206>
					putch('?', putdat);
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	eb 0a                	jmp    800502 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	ff 4d e4             	decl   -0x1c(%ebp)
  800505:	0f be 06             	movsbl (%esi),%eax
  800508:	46                   	inc    %esi
  800509:	85 c0                	test   %eax,%eax
  80050b:	74 21                	je     80052e <vprintfmt+0x23c>
  80050d:	85 ff                	test   %edi,%edi
  80050f:	78 c9                	js     8004da <vprintfmt+0x1e8>
  800511:	4f                   	dec    %edi
  800512:	79 c6                	jns    8004da <vprintfmt+0x1e8>
  800514:	8b 7d 08             	mov    0x8(%ebp),%edi
  800517:	89 de                	mov    %ebx,%esi
  800519:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051c:	eb 18                	jmp    800536 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800522:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800529:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	4b                   	dec    %ebx
  80052c:	eb 08                	jmp    800536 <vprintfmt+0x244>
  80052e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800531:	89 de                	mov    %ebx,%esi
  800533:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800536:	85 db                	test   %ebx,%ebx
  800538:	7f e4                	jg     80051e <vprintfmt+0x22c>
  80053a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80053d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800542:	e9 ce fd ff ff       	jmp    800315 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 f9 01             	cmp    $0x1,%ecx
  80054a:	7e 10                	jle    80055c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 08             	lea    0x8(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 30                	mov    (%eax),%esi
  800557:	8b 78 04             	mov    0x4(%eax),%edi
  80055a:	eb 26                	jmp    800582 <vprintfmt+0x290>
	else if (lflag)
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	74 12                	je     800572 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 30                	mov    (%eax),%esi
  80056b:	89 f7                	mov    %esi,%edi
  80056d:	c1 ff 1f             	sar    $0x1f,%edi
  800570:	eb 10                	jmp    800582 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 30                	mov    (%eax),%esi
  80057d:	89 f7                	mov    %esi,%edi
  80057f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800582:	85 ff                	test   %edi,%edi
  800584:	78 0a                	js     800590 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058b:	e9 ac 00 00 00       	jmp    80063c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80059e:	f7 de                	neg    %esi
  8005a0:	83 d7 00             	adc    $0x0,%edi
  8005a3:	f7 df                	neg    %edi
			}
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005aa:	e9 8d 00 00 00       	jmp    80063c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005af:	89 ca                	mov    %ecx,%edx
  8005b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b4:	e8 bd fc ff ff       	call   800276 <getuint>
  8005b9:	89 c6                	mov    %eax,%esi
  8005bb:	89 d7                	mov    %edx,%edi
			base = 10;
  8005bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c2:	eb 78                	jmp    80063c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005dd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005f1:	e9 1f fd ff ff       	jmp    800315 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800601:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061b:	8b 30                	mov    (%eax),%esi
  80061d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800622:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800627:	eb 13                	jmp    80063c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 43 fc ff ff       	call   800276 <getuint>
  800633:	89 c6                	mov    %eax,%esi
  800635:	89 d7                	mov    %edx,%edi
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800640:	89 54 24 10          	mov    %edx,0x10(%esp)
  800644:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800647:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064f:	89 34 24             	mov    %esi,(%esp)
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	89 da                	mov    %ebx,%edx
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	e8 4c fb ff ff       	call   8001ac <printnum>
			break;
  800660:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800663:	e9 ad fc ff ff       	jmp    800315 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800675:	e9 9b fc ff ff       	jmp    800315 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800688:	eb 01                	jmp    80068b <vprintfmt+0x399>
  80068a:	4e                   	dec    %esi
  80068b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068f:	75 f9                	jne    80068a <vprintfmt+0x398>
  800691:	e9 7f fc ff ff       	jmp    800315 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800696:	83 c4 4c             	add    $0x4c,%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5f                   	pop    %edi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 28             	sub    $0x28,%esp
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	74 30                	je     8006ef <vsnprintf+0x51>
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	7e 33                	jle    8006f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  8006df:	e8 0e fc ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ed:	eb 0c                	jmp    8006fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f4:	eb 05                	jmp    8006fb <vsnprintf+0x5d>
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070a:	8b 45 10             	mov    0x10(%ebp),%eax
  80070d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 7b ff ff ff       	call   80069e <vsnprintf>
	va_end(ap);

	return rc;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    
  800725:	00 00                	add    %al,(%eax)
	...

00800728 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	eb 01                	jmp    800736 <strlen+0xe>
		n++;
  800735:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f9                	jne    800735 <strlen+0xd>
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 01                	jmp    80074f <strnlen+0x11>
		n++;
  80074e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	39 d0                	cmp    %edx,%eax
  800751:	74 06                	je     800759 <strnlen+0x1b>
  800753:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800757:	75 f5                	jne    80074e <strnlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80076d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800770:	42                   	inc    %edx
  800771:	84 c9                	test   %cl,%cl
  800773:	75 f5                	jne    80076a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800775:	5b                   	pop    %ebx
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800782:	89 1c 24             	mov    %ebx,(%esp)
  800785:	e8 9e ff ff ff       	call   800728 <strlen>
	strcpy(dst + len, src);
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800791:	01 d8                	add    %ebx,%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 c0 ff ff ff       	call   80075b <strcpy>
	return dst;
}
  80079b:	89 d8                	mov    %ebx,%eax
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	5b                   	pop    %ebx
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	eb 0c                	jmp    8007c4 <strncpy+0x21>
		*dst++ = *src;
  8007b8:	8a 1a                	mov    (%edx),%bl
  8007ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c3:	41                   	inc    %ecx
  8007c4:	39 f1                	cmp    %esi,%ecx
  8007c6:	75 f0                	jne    8007b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	75 0a                	jne    8007e8 <strlcpy+0x1c>
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	eb 1a                	jmp    8007fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	88 18                	mov    %bl,(%eax)
  8007e4:	40                   	inc    %eax
  8007e5:	41                   	inc    %ecx
  8007e6:	eb 02                	jmp    8007ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ea:	4a                   	dec    %edx
  8007eb:	74 0a                	je     8007f7 <strlcpy+0x2b>
  8007ed:	8a 19                	mov    (%ecx),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ef                	jne    8007e2 <strlcpy+0x16>
  8007f3:	89 c2                	mov    %eax,%edx
  8007f5:	eb 02                	jmp    8007f9 <strlcpy+0x2d>
  8007f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007fc:	29 f0                	sub    %esi,%eax
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080b:	eb 02                	jmp    80080f <strcmp+0xd>
		p++, q++;
  80080d:	41                   	inc    %ecx
  80080e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080f:	8a 01                	mov    (%ecx),%al
  800811:	84 c0                	test   %al,%al
  800813:	74 04                	je     800819 <strcmp+0x17>
  800815:	3a 02                	cmp    (%edx),%al
  800817:	74 f4                	je     80080d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800819:	0f b6 c0             	movzbl %al,%eax
  80081c:	0f b6 12             	movzbl (%edx),%edx
  80081f:	29 d0                	sub    %edx,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800830:	eb 03                	jmp    800835 <strncmp+0x12>
		n--, p++, q++;
  800832:	4a                   	dec    %edx
  800833:	40                   	inc    %eax
  800834:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <strncmp+0x2a>
  800839:	8a 18                	mov    (%eax),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	74 04                	je     800843 <strncmp+0x20>
  80083f:	3a 19                	cmp    (%ecx),%bl
  800841:	74 ef                	je     800832 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	0f b6 11             	movzbl (%ecx),%edx
  800849:	29 d0                	sub    %edx,%eax
  80084b:	eb 05                	jmp    800852 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085e:	eb 05                	jmp    800865 <strchr+0x10>
		if (*s == c)
  800860:	38 ca                	cmp    %cl,%dl
  800862:	74 0c                	je     800870 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800864:	40                   	inc    %eax
  800865:	8a 10                	mov    (%eax),%dl
  800867:	84 d2                	test   %dl,%dl
  800869:	75 f5                	jne    800860 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087b:	eb 05                	jmp    800882 <strfind+0x10>
		if (*s == c)
  80087d:	38 ca                	cmp    %cl,%dl
  80087f:	74 07                	je     800888 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800881:	40                   	inc    %eax
  800882:	8a 10                	mov    (%eax),%dl
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f5                	jne    80087d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800899:	85 c9                	test   %ecx,%ecx
  80089b:	74 30                	je     8008cd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a3:	75 25                	jne    8008ca <memset+0x40>
  8008a5:	f6 c1 03             	test   $0x3,%cl
  8008a8:	75 20                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ad:	89 d3                	mov    %edx,%ebx
  8008af:	c1 e3 08             	shl    $0x8,%ebx
  8008b2:	89 d6                	mov    %edx,%esi
  8008b4:	c1 e6 18             	shl    $0x18,%esi
  8008b7:	89 d0                	mov    %edx,%eax
  8008b9:	c1 e0 10             	shl    $0x10,%eax
  8008bc:	09 f0                	or     %esi,%eax
  8008be:	09 d0                	or     %edx,%eax
  8008c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 03                	jmp    8008cd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	fc                   	cld    
  8008cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cd:	89 f8                	mov    %edi,%eax
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e2:	39 c6                	cmp    %eax,%esi
  8008e4:	73 34                	jae    80091a <memmove+0x46>
  8008e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e9:	39 d0                	cmp    %edx,%eax
  8008eb:	73 2d                	jae    80091a <memmove+0x46>
		s += n;
		d += n;
  8008ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	f6 c2 03             	test   $0x3,%dl
  8008f3:	75 1b                	jne    800910 <memmove+0x3c>
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 13                	jne    800910 <memmove+0x3c>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0e                	jne    800910 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800902:	83 ef 04             	sub    $0x4,%edi
  800905:	8d 72 fc             	lea    -0x4(%edx),%esi
  800908:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80090b:	fd                   	std    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 07                	jmp    800917 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800910:	4f                   	dec    %edi
  800911:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800914:	fd                   	std    
  800915:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800917:	fc                   	cld    
  800918:	eb 20                	jmp    80093a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800920:	75 13                	jne    800935 <memmove+0x61>
  800922:	a8 03                	test   $0x3,%al
  800924:	75 0f                	jne    800935 <memmove+0x61>
  800926:	f6 c1 03             	test   $0x3,%cl
  800929:	75 0a                	jne    800935 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800933:	eb 05                	jmp    80093a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800935:	89 c7                	mov    %eax,%edi
  800937:	fc                   	cld    
  800938:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800944:	8b 45 10             	mov    0x10(%ebp),%eax
  800947:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 77 ff ff ff       	call   8008d4 <memmove>
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 7d 08             	mov    0x8(%ebp),%edi
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	eb 16                	jmp    80098b <memcmp+0x2c>
		if (*s1 != *s2)
  800975:	8a 04 17             	mov    (%edi,%edx,1),%al
  800978:	42                   	inc    %edx
  800979:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80097d:	38 c8                	cmp    %cl,%al
  80097f:	74 0a                	je     80098b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800981:	0f b6 c0             	movzbl %al,%eax
  800984:	0f b6 c9             	movzbl %cl,%ecx
  800987:	29 c8                	sub    %ecx,%eax
  800989:	eb 09                	jmp    800994 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 e6                	jne    800975 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a7:	eb 05                	jmp    8009ae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	38 08                	cmp    %cl,(%eax)
  8009ab:	74 05                	je     8009b2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	40                   	inc    %eax
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	72 f7                	jb     8009a9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c0:	eb 01                	jmp    8009c3 <strtol+0xf>
		s++;
  8009c2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	8a 02                	mov    (%edx),%al
  8009c5:	3c 20                	cmp    $0x20,%al
  8009c7:	74 f9                	je     8009c2 <strtol+0xe>
  8009c9:	3c 09                	cmp    $0x9,%al
  8009cb:	74 f5                	je     8009c2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cd:	3c 2b                	cmp    $0x2b,%al
  8009cf:	75 08                	jne    8009d9 <strtol+0x25>
		s++;
  8009d1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d7:	eb 13                	jmp    8009ec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d9:	3c 2d                	cmp    $0x2d,%al
  8009db:	75 0a                	jne    8009e7 <strtol+0x33>
		s++, neg = 1;
  8009dd:	8d 52 01             	lea    0x1(%edx),%edx
  8009e0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e5:	eb 05                	jmp    8009ec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ec:	85 db                	test   %ebx,%ebx
  8009ee:	74 05                	je     8009f5 <strtol+0x41>
  8009f0:	83 fb 10             	cmp    $0x10,%ebx
  8009f3:	75 28                	jne    800a1d <strtol+0x69>
  8009f5:	8a 02                	mov    (%edx),%al
  8009f7:	3c 30                	cmp    $0x30,%al
  8009f9:	75 10                	jne    800a0b <strtol+0x57>
  8009fb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ff:	75 0a                	jne    800a0b <strtol+0x57>
		s += 2, base = 16;
  800a01:	83 c2 02             	add    $0x2,%edx
  800a04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a09:	eb 12                	jmp    800a1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a0b:	85 db                	test   %ebx,%ebx
  800a0d:	75 0e                	jne    800a1d <strtol+0x69>
  800a0f:	3c 30                	cmp    $0x30,%al
  800a11:	75 05                	jne    800a18 <strtol+0x64>
		s++, base = 8;
  800a13:	42                   	inc    %edx
  800a14:	b3 08                	mov    $0x8,%bl
  800a16:	eb 05                	jmp    800a1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	8a 0a                	mov    (%edx),%cl
  800a26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a29:	80 fb 09             	cmp    $0x9,%bl
  800a2c:	77 08                	ja     800a36 <strtol+0x82>
			dig = *s - '0';
  800a2e:	0f be c9             	movsbl %cl,%ecx
  800a31:	83 e9 30             	sub    $0x30,%ecx
  800a34:	eb 1e                	jmp    800a54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 57             	sub    $0x57,%ecx
  800a44:	eb 0e                	jmp    800a54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 12                	ja     800a60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a54:	39 f1                	cmp    %esi,%ecx
  800a56:	7d 0c                	jge    800a64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a58:	42                   	inc    %edx
  800a59:	0f af c6             	imul   %esi,%eax
  800a5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a5e:	eb c4                	jmp    800a24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	89 c1                	mov    %eax,%ecx
  800a62:	eb 02                	jmp    800a66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 05                	je     800a71 <strtol+0xbd>
		*endptr = (char *) s;
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a71:	85 ff                	test   %edi,%edi
  800a73:	74 04                	je     800a79 <strtol+0xc5>
  800a75:	89 c8                	mov    %ecx,%eax
  800a77:	f7 d8                	neg    %eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    
	...

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 28                	jle    800b07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ae3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aea:	00 
  800aeb:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800af2:	00 
  800af3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800afa:	00 
  800afb:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800b02:	e8 21 03 00 00       	call   800e28 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b07:	83 c4 2c             	add    $0x2c,%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1f:	89 d1                	mov    %edx,%ecx
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	89 d7                	mov    %edx,%edi
  800b25:	89 d6                	mov    %edx,%esi
  800b27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_yield>:

void
sys_yield(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	be 00 00 00 00       	mov    $0x0,%esi
  800b5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 f7                	mov    %esi,%edi
  800b6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 28                	jle    800b99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800b84:	00 
  800b85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8c:	00 
  800b8d:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800b94:	e8 8f 02 00 00       	call   800e28 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b99:	83 c4 2c             	add    $0x2c,%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b8 05 00 00 00       	mov    $0x5,%eax
  800baf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 28                	jle    800bec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bcf:	00 
  800bd0:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdf:	00 
  800be0:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800be7:	e8 3c 02 00 00       	call   800e28 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bec:	83 c4 2c             	add    $0x2c,%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c02:	b8 06 00 00 00       	mov    $0x6,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 df                	mov    %ebx,%edi
  800c0f:	89 de                	mov    %ebx,%esi
  800c11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 28                	jle    800c3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c22:	00 
  800c23:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800c3a:	e8 e9 01 00 00       	call   800e28 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	83 c4 2c             	add    $0x2c,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 28                	jle    800c92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c75:	00 
  800c76:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c85:	00 
  800c86:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800c8d:	e8 96 01 00 00       	call   800e28 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c92:	83 c4 2c             	add    $0x2c,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 28                	jle    800ce5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd8:	00 
  800cd9:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800ce0:	e8 43 01 00 00       	call   800e28 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce5:	83 c4 2c             	add    $0x2c,%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	be 00 00 00 00       	mov    $0x0,%esi
  800cf8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 cb                	mov    %ecx,%ebx
  800d28:	89 cf                	mov    %ecx,%edi
  800d2a:	89 ce                	mov    %ecx,%esi
  800d2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 28                	jle    800d5a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d36:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 08 44 13 80 	movl   $0x801344,0x8(%esp)
  800d45:	00 
  800d46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4d:	00 
  800d4e:	c7 04 24 61 13 80 00 	movl   $0x801361,(%esp)
  800d55:	e8 ce 00 00 00       	call   800e28 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5a:	83 c4 2c             	add    $0x2c,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
	...

00800d64 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d6a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d71:	0f 85 80 00 00 00    	jne    800df7 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800d77:	a1 04 20 80 00       	mov    0x802004,%eax
  800d7c:	8b 40 48             	mov    0x48(%eax),%eax
  800d7f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800d8e:	ee 
  800d8f:	89 04 24             	mov    %eax,(%esp)
  800d92:	e8 b6 fd ff ff       	call   800b4d <sys_page_alloc>
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 20                	jns    800dbb <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9f:	c7 44 24 08 70 13 80 	movl   $0x801370,0x8(%esp)
  800da6:	00 
  800da7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800dae:	00 
  800daf:	c7 04 24 cc 13 80 00 	movl   $0x8013cc,(%esp)
  800db6:	e8 6d 00 00 00       	call   800e28 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800dbb:	a1 04 20 80 00       	mov    0x802004,%eax
  800dc0:	8b 40 48             	mov    0x48(%eax),%eax
  800dc3:	c7 44 24 04 04 0e 80 	movl   $0x800e04,0x4(%esp)
  800dca:	00 
  800dcb:	89 04 24             	mov    %eax,(%esp)
  800dce:	e8 c7 fe ff ff       	call   800c9a <sys_env_set_pgfault_upcall>
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	79 20                	jns    800df7 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800dd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ddb:	c7 44 24 08 9c 13 80 	movl   $0x80139c,0x8(%esp)
  800de2:	00 
  800de3:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800dea:	00 
  800deb:	c7 04 24 cc 13 80 00 	movl   $0x8013cc,(%esp)
  800df2:	e8 31 00 00 00       	call   800e28 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    
  800e01:	00 00                	add    %al,(%eax)
	...

00800e04 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e04:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e05:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e0a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e0c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  800e0f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800e13:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800e15:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800e18:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800e19:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  800e1c:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  800e1e:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800e21:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800e22:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800e25:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e26:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800e27:	c3                   	ret    

00800e28 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e30:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e33:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e39:	e8 d1 fc ff ff       	call   800b0f <sys_getenvid>
  800e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e41:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e54:	c7 04 24 dc 13 80 00 	movl   $0x8013dc,(%esp)
  800e5b:	e8 30 f3 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e60:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e64:	8b 45 10             	mov    0x10(%ebp),%eax
  800e67:	89 04 24             	mov    %eax,(%esp)
  800e6a:	e8 c0 f2 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  800e6f:	c7 04 24 fa 10 80 00 	movl   $0x8010fa,(%esp)
  800e76:	e8 15 f3 ff ff       	call   800190 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e7b:	cc                   	int3   
  800e7c:	eb fd                	jmp    800e7b <_panic+0x53>
	...

00800e80 <__udivdi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	83 ec 10             	sub    $0x10,%esp
  800e86:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e8a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e92:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800e96:	89 cd                	mov    %ecx,%ebp
  800e98:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	75 2c                	jne    800ecc <__udivdi3+0x4c>
  800ea0:	39 f9                	cmp    %edi,%ecx
  800ea2:	77 68                	ja     800f0c <__udivdi3+0x8c>
  800ea4:	85 c9                	test   %ecx,%ecx
  800ea6:	75 0b                	jne    800eb3 <__udivdi3+0x33>
  800ea8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	f7 f1                	div    %ecx
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	89 f8                	mov    %edi,%eax
  800eb7:	f7 f1                	div    %ecx
  800eb9:	89 c7                	mov    %eax,%edi
  800ebb:	89 f0                	mov    %esi,%eax
  800ebd:	f7 f1                	div    %ecx
  800ebf:	89 c6                	mov    %eax,%esi
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	89 fa                	mov    %edi,%edx
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	39 f8                	cmp    %edi,%eax
  800ece:	77 2c                	ja     800efc <__udivdi3+0x7c>
  800ed0:	0f bd f0             	bsr    %eax,%esi
  800ed3:	83 f6 1f             	xor    $0x1f,%esi
  800ed6:	75 4c                	jne    800f24 <__udivdi3+0xa4>
  800ed8:	39 f8                	cmp    %edi,%eax
  800eda:	bf 00 00 00 00       	mov    $0x0,%edi
  800edf:	72 0a                	jb     800eeb <__udivdi3+0x6b>
  800ee1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ee5:	0f 87 ad 00 00 00    	ja     800f98 <__udivdi3+0x118>
  800eeb:	be 01 00 00 00       	mov    $0x1,%esi
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	89 fa                	mov    %edi,%edx
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
  800efb:	90                   	nop
  800efc:	31 ff                	xor    %edi,%edi
  800efe:	31 f6                	xor    %esi,%esi
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	89 fa                	mov    %edi,%edx
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    
  800f0b:	90                   	nop
  800f0c:	89 fa                	mov    %edi,%edx
  800f0e:	89 f0                	mov    %esi,%eax
  800f10:	f7 f1                	div    %ecx
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 f0                	mov    %esi,%eax
  800f18:	89 fa                	mov    %edi,%edx
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
  800f21:	8d 76 00             	lea    0x0(%esi),%esi
  800f24:	89 f1                	mov    %esi,%ecx
  800f26:	d3 e0                	shl    %cl,%eax
  800f28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f31:	29 f0                	sub    %esi,%eax
  800f33:	89 ea                	mov    %ebp,%edx
  800f35:	88 c1                	mov    %al,%cl
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f3d:	09 ca                	or     %ecx,%edx
  800f3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f43:	89 f1                	mov    %esi,%ecx
  800f45:	d3 e5                	shl    %cl,%ebp
  800f47:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800f4b:	89 fd                	mov    %edi,%ebp
  800f4d:	88 c1                	mov    %al,%cl
  800f4f:	d3 ed                	shr    %cl,%ebp
  800f51:	89 fa                	mov    %edi,%edx
  800f53:	89 f1                	mov    %esi,%ecx
  800f55:	d3 e2                	shl    %cl,%edx
  800f57:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f5b:	88 c1                	mov    %al,%cl
  800f5d:	d3 ef                	shr    %cl,%edi
  800f5f:	09 d7                	or     %edx,%edi
  800f61:	89 f8                	mov    %edi,%eax
  800f63:	89 ea                	mov    %ebp,%edx
  800f65:	f7 74 24 08          	divl   0x8(%esp)
  800f69:	89 d1                	mov    %edx,%ecx
  800f6b:	89 c7                	mov    %eax,%edi
  800f6d:	f7 64 24 0c          	mull   0xc(%esp)
  800f71:	39 d1                	cmp    %edx,%ecx
  800f73:	72 17                	jb     800f8c <__udivdi3+0x10c>
  800f75:	74 09                	je     800f80 <__udivdi3+0x100>
  800f77:	89 fe                	mov    %edi,%esi
  800f79:	31 ff                	xor    %edi,%edi
  800f7b:	e9 41 ff ff ff       	jmp    800ec1 <__udivdi3+0x41>
  800f80:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f84:	89 f1                	mov    %esi,%ecx
  800f86:	d3 e2                	shl    %cl,%edx
  800f88:	39 c2                	cmp    %eax,%edx
  800f8a:	73 eb                	jae    800f77 <__udivdi3+0xf7>
  800f8c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800f8f:	31 ff                	xor    %edi,%edi
  800f91:	e9 2b ff ff ff       	jmp    800ec1 <__udivdi3+0x41>
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	31 f6                	xor    %esi,%esi
  800f9a:	e9 22 ff ff ff       	jmp    800ec1 <__udivdi3+0x41>
	...

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	83 ec 20             	sub    $0x20,%esp
  800fa6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800faa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800fae:	89 44 24 14          	mov    %eax,0x14(%esp)
  800fb2:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fb6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fba:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fbe:	89 c7                	mov    %eax,%edi
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	85 ed                	test   %ebp,%ebp
  800fc4:	75 16                	jne    800fdc <__umoddi3+0x3c>
  800fc6:	39 f1                	cmp    %esi,%ecx
  800fc8:	0f 86 a6 00 00 00    	jbe    801074 <__umoddi3+0xd4>
  800fce:	f7 f1                	div    %ecx
  800fd0:	89 d0                	mov    %edx,%eax
  800fd2:	31 d2                	xor    %edx,%edx
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
  800fdb:	90                   	nop
  800fdc:	39 f5                	cmp    %esi,%ebp
  800fde:	0f 87 ac 00 00 00    	ja     801090 <__umoddi3+0xf0>
  800fe4:	0f bd c5             	bsr    %ebp,%eax
  800fe7:	83 f0 1f             	xor    $0x1f,%eax
  800fea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fee:	0f 84 a8 00 00 00    	je     80109c <__umoddi3+0xfc>
  800ff4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff8:	d3 e5                	shl    %cl,%ebp
  800ffa:	bf 20 00 00 00       	mov    $0x20,%edi
  800fff:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801003:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801007:	89 f9                	mov    %edi,%ecx
  801009:	d3 e8                	shr    %cl,%eax
  80100b:	09 e8                	or     %ebp,%eax
  80100d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801011:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801015:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801019:	d3 e0                	shl    %cl,%eax
  80101b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101f:	89 f2                	mov    %esi,%edx
  801021:	d3 e2                	shl    %cl,%edx
  801023:	8b 44 24 14          	mov    0x14(%esp),%eax
  801027:	d3 e0                	shl    %cl,%eax
  801029:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80102d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801031:	89 f9                	mov    %edi,%ecx
  801033:	d3 e8                	shr    %cl,%eax
  801035:	09 d0                	or     %edx,%eax
  801037:	d3 ee                	shr    %cl,%esi
  801039:	89 f2                	mov    %esi,%edx
  80103b:	f7 74 24 18          	divl   0x18(%esp)
  80103f:	89 d6                	mov    %edx,%esi
  801041:	f7 64 24 0c          	mull   0xc(%esp)
  801045:	89 c5                	mov    %eax,%ebp
  801047:	89 d1                	mov    %edx,%ecx
  801049:	39 d6                	cmp    %edx,%esi
  80104b:	72 67                	jb     8010b4 <__umoddi3+0x114>
  80104d:	74 75                	je     8010c4 <__umoddi3+0x124>
  80104f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801053:	29 e8                	sub    %ebp,%eax
  801055:	19 ce                	sbb    %ecx,%esi
  801057:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	89 f2                	mov    %esi,%edx
  80105f:	89 f9                	mov    %edi,%ecx
  801061:	d3 e2                	shl    %cl,%edx
  801063:	09 d0                	or     %edx,%eax
  801065:	89 f2                	mov    %esi,%edx
  801067:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80106b:	d3 ea                	shr    %cl,%edx
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    
  801074:	85 c9                	test   %ecx,%ecx
  801076:	75 0b                	jne    801083 <__umoddi3+0xe3>
  801078:	b8 01 00 00 00       	mov    $0x1,%eax
  80107d:	31 d2                	xor    %edx,%edx
  80107f:	f7 f1                	div    %ecx
  801081:	89 c1                	mov    %eax,%ecx
  801083:	89 f0                	mov    %esi,%eax
  801085:	31 d2                	xor    %edx,%edx
  801087:	f7 f1                	div    %ecx
  801089:	89 f8                	mov    %edi,%eax
  80108b:	e9 3e ff ff ff       	jmp    800fce <__umoddi3+0x2e>
  801090:	89 f2                	mov    %esi,%edx
  801092:	83 c4 20             	add    $0x20,%esp
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	8d 76 00             	lea    0x0(%esi),%esi
  80109c:	39 f5                	cmp    %esi,%ebp
  80109e:	72 04                	jb     8010a4 <__umoddi3+0x104>
  8010a0:	39 f9                	cmp    %edi,%ecx
  8010a2:	77 06                	ja     8010aa <__umoddi3+0x10a>
  8010a4:	89 f2                	mov    %esi,%edx
  8010a6:	29 cf                	sub    %ecx,%edi
  8010a8:	19 ea                	sbb    %ebp,%edx
  8010aa:	89 f8                	mov    %edi,%eax
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    
  8010b3:	90                   	nop
  8010b4:	89 d1                	mov    %edx,%ecx
  8010b6:	89 c5                	mov    %eax,%ebp
  8010b8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8010bc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8010c0:	eb 8d                	jmp    80104f <__umoddi3+0xaf>
  8010c2:	66 90                	xchg   %ax,%ax
  8010c4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8010c8:	72 ea                	jb     8010b4 <__umoddi3+0x114>
  8010ca:	89 f1                	mov    %esi,%ecx
  8010cc:	eb 81                	jmp    80104f <__umoddi3+0xaf>
