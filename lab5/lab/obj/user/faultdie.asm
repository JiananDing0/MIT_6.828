
obj/user/faultdie.debug:     file format elf32-i386


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
  80004d:	c7 04 24 00 20 80 00 	movl   $0x802000,(%esp)
  800054:	e8 3f 01 00 00       	call   800198 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 b9 0a 00 00       	call   800b17 <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 5f 0a 00 00       	call   800ac5 <sys_env_destroy>
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
  800075:	e8 46 0d 00 00       	call   800dc0 <set_pgfault_handler>
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
  800096:	e8 7c 0a 00 00       	call   800b17 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b6:	85 f6                	test   %esi,%esi
  8000b8:	7e 07                	jle    8000c1 <libmain+0x39>
		binaryname = argv[0];
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000e2:	e8 84 0f 00 00       	call   80106b <close_all>
	sys_env_destroy(0);
  8000e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ee:	e8 d2 09 00 00       	call   800ac5 <sys_env_destroy>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	40                   	inc    %eax
  80010c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	75 19                	jne    80012e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800115:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011c:	00 
  80011d:	8d 43 08             	lea    0x8(%ebx),%eax
  800120:	89 04 24             	mov    %eax,(%esp)
  800123:	e8 60 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  800128:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012e:	ff 43 04             	incl   0x4(%ebx)
}
  800131:	83 c4 14             	add    $0x14,%esp
  800134:	5b                   	pop    %ebx
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800140:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800147:	00 00 00 
	b.cnt = 0;
  80014a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800151:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
  800157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015b:	8b 45 08             	mov    0x8(%ebp),%eax
  80015e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800173:	e8 82 01 00 00       	call   8002fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 f8 08 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 87 ff ff ff       	call   800137 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    
	...

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 3c             	sub    $0x3c,%esp
  8001bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c0:	89 d7                	mov    %edx,%edi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	75 08                	jne    8001e0 <printnum+0x2c>
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001de:	77 57                	ja     800237 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e4:	4b                   	dec    %ebx
  8001e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	e8 9e 1b 00 00       	call   801db0 <__udivdi3>
  800212:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800216:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800221:	89 fa                	mov    %edi,%edx
  800223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800226:	e8 89 ff ff ff       	call   8001b4 <printnum>
  80022b:	eb 0f                	jmp    80023c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	89 34 24             	mov    %esi,(%esp)
  800234:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800237:	4b                   	dec    %ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f f1                	jg     80022d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 10             	mov    0x10(%ebp),%eax
  800247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800252:	00 
  800253:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	e8 6b 1c 00 00       	call   801ed0 <__umoddi3>
  800265:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800269:	0f be 80 26 20 80 00 	movsbl 0x802026(%eax),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800276:	83 c4 3c             	add    $0x3c,%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x38>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c6:	73 08                	jae    8002d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cb:	88 0a                	mov    %cl,(%edx)
  8002cd:	42                   	inc    %edx
  8002ce:	89 10                	mov    %edx,(%eax)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002df:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	e8 02 00 00 00       	call   8002fa <vprintfmt>
	va_end(ap);
}
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	83 ec 4c             	sub    $0x4c,%esp
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800306:	8b 75 10             	mov    0x10(%ebp),%esi
  800309:	eb 12                	jmp    80031d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030b:	85 c0                	test   %eax,%eax
  80030d:	0f 84 8b 03 00 00    	je     80069e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800313:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	0f b6 06             	movzbl (%esi),%eax
  800320:	46                   	inc    %esi
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	75 e5                	jne    80030b <vprintfmt+0x11>
  800326:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800336:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	eb 26                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034b:	eb 1d                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800350:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800354:	eb 14                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800359:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800360:	eb 08                	jmp    80036a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800362:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800365:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 06             	movzbl (%esi),%eax
  80036d:	8d 56 01             	lea    0x1(%esi),%edx
  800370:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800373:	8a 16                	mov    (%esi),%dl
  800375:	83 ea 23             	sub    $0x23,%edx
  800378:	80 fa 55             	cmp    $0x55,%dl
  80037b:	0f 87 01 03 00 00    	ja     800682 <vprintfmt+0x388>
  800381:	0f b6 d2             	movzbl %dl,%edx
  800384:	ff 24 95 60 21 80 00 	jmp    *0x802160(,%edx,4)
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800393:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800396:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a0:	83 fa 09             	cmp    $0x9,%edx
  8003a3:	77 2a                	ja     8003cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb eb                	jmp    800393 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b6:	eb 17                	jmp    8003cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bc:	78 98                	js     800356 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c1:	eb a7                	jmp    80036a <vprintfmt+0x70>
  8003c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003cd:	eb 9b                	jmp    80036a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d3:	79 95                	jns    80036a <vprintfmt+0x70>
  8003d5:	eb 8b                	jmp    800362 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003db:	eb 8d                	jmp    80036a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f5:	e9 23 ff ff ff       	jmp    80031d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	79 02                	jns    80040b <vprintfmt+0x111>
  800409:	f7 d8                	neg    %eax
  80040b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040d:	83 f8 0f             	cmp    $0xf,%eax
  800410:	7f 0b                	jg     80041d <vprintfmt+0x123>
  800412:	8b 04 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%eax
  800419:	85 c0                	test   %eax,%eax
  80041b:	75 23                	jne    800440 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80041d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800421:	c7 44 24 08 3e 20 80 	movl   $0x80203e,0x8(%esp)
  800428:	00 
  800429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	e8 9a fe ff ff       	call   8002d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043b:	e9 dd fe ff ff       	jmp    80031d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	c7 44 24 08 86 24 80 	movl   $0x802486,0x8(%esp)
  80044b:	00 
  80044c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800450:	8b 55 08             	mov    0x8(%ebp),%edx
  800453:	89 14 24             	mov    %edx,(%esp)
  800456:	e8 77 fe ff ff       	call   8002d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	e9 ba fe ff ff       	jmp    80031d <vprintfmt+0x23>
  800463:	89 f9                	mov    %edi,%ecx
  800465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800468:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 30                	mov    (%eax),%esi
  800476:	85 f6                	test   %esi,%esi
  800478:	75 05                	jne    80047f <vprintfmt+0x185>
				p = "(null)";
  80047a:	be 37 20 80 00       	mov    $0x802037,%esi
			if (width > 0 && padc != '-')
  80047f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800483:	0f 8e 84 00 00 00    	jle    80050d <vprintfmt+0x213>
  800489:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048d:	74 7e                	je     80050d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800493:	89 34 24             	mov    %esi,(%esp)
  800496:	e8 ab 02 00 00       	call   800746 <strnlen>
  80049b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049e:	29 c2                	sub    %eax,%edx
  8004a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004ad:	89 de                	mov    %ebx,%esi
  8004af:	89 d3                	mov    %edx,%ebx
  8004b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	eb 0b                	jmp    8004c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b9:	89 3c 24             	mov    %edi,(%esp)
  8004bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	4b                   	dec    %ebx
  8004c0:	85 db                	test   %ebx,%ebx
  8004c2:	7f f1                	jg     8004b5 <vprintfmt+0x1bb>
  8004c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c7:	89 f3                	mov    %esi,%ebx
  8004c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	79 05                	jns    8004d8 <vprintfmt+0x1de>
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e0:	eb 2b                	jmp    80050d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e6:	74 18                	je     800500 <vprintfmt+0x206>
  8004e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004eb:	83 fa 5e             	cmp    $0x5e,%edx
  8004ee:	76 10                	jbe    800500 <vprintfmt+0x206>
					putch('?', putdat);
  8004f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fb:	ff 55 08             	call   *0x8(%ebp)
  8004fe:	eb 0a                	jmp    80050a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	ff 4d e4             	decl   -0x1c(%ebp)
  80050d:	0f be 06             	movsbl (%esi),%eax
  800510:	46                   	inc    %esi
  800511:	85 c0                	test   %eax,%eax
  800513:	74 21                	je     800536 <vprintfmt+0x23c>
  800515:	85 ff                	test   %edi,%edi
  800517:	78 c9                	js     8004e2 <vprintfmt+0x1e8>
  800519:	4f                   	dec    %edi
  80051a:	79 c6                	jns    8004e2 <vprintfmt+0x1e8>
  80051c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051f:	89 de                	mov    %ebx,%esi
  800521:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800524:	eb 18                	jmp    80053e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800531:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	4b                   	dec    %ebx
  800534:	eb 08                	jmp    80053e <vprintfmt+0x244>
  800536:	8b 7d 08             	mov    0x8(%ebp),%edi
  800539:	89 de                	mov    %ebx,%esi
  80053b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053e:	85 db                	test   %ebx,%ebx
  800540:	7f e4                	jg     800526 <vprintfmt+0x22c>
  800542:	89 7d 08             	mov    %edi,0x8(%ebp)
  800545:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054a:	e9 ce fd ff ff       	jmp    80031d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 f9 01             	cmp    $0x1,%ecx
  800552:	7e 10                	jle    800564 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 30                	mov    (%eax),%esi
  80055f:	8b 78 04             	mov    0x4(%eax),%edi
  800562:	eb 26                	jmp    80058a <vprintfmt+0x290>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	74 12                	je     80057a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 30                	mov    (%eax),%esi
  800573:	89 f7                	mov    %esi,%edi
  800575:	c1 ff 1f             	sar    $0x1f,%edi
  800578:	eb 10                	jmp    80058a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 30                	mov    (%eax),%esi
  800585:	89 f7                	mov    %esi,%edi
  800587:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058a:	85 ff                	test   %edi,%edi
  80058c:	78 0a                	js     800598 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 ac 00 00 00       	jmp    800644 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a6:	f7 de                	neg    %esi
  8005a8:	83 d7 00             	adc    $0x0,%edi
  8005ab:	f7 df                	neg    %edi
			}
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b2:	e9 8d 00 00 00       	jmp    800644 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b7:	89 ca                	mov    %ecx,%edx
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	e8 bd fc ff ff       	call   80027e <getuint>
  8005c1:	89 c6                	mov    %eax,%esi
  8005c3:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ca:	eb 78                	jmp    800644 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005de:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005e5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005f9:	e9 1f fd ff ff       	jmp    80031d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800609:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800610:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 30                	mov    (%eax),%esi
  800625:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062f:	eb 13                	jmp    800644 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 43 fc ff ff       	call   80027e <getuint>
  80063b:	89 c6                	mov    %eax,%esi
  80063d:	89 d7                	mov    %edx,%edi
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800644:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800648:	89 54 24 10          	mov    %edx,0x10(%esp)
  80064c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800653:	89 44 24 08          	mov    %eax,0x8(%esp)
  800657:	89 34 24             	mov    %esi,(%esp)
  80065a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065e:	89 da                	mov    %ebx,%edx
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	e8 4c fb ff ff       	call   8001b4 <printnum>
			break;
  800668:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066b:	e9 ad fc ff ff       	jmp    80031d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067d:	e9 9b fc ff ff       	jmp    80031d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800690:	eb 01                	jmp    800693 <vprintfmt+0x399>
  800692:	4e                   	dec    %esi
  800693:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800697:	75 f9                	jne    800692 <vprintfmt+0x398>
  800699:	e9 7f fc ff ff       	jmp    80031d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80069e:	83 c4 4c             	add    $0x4c,%esp
  8006a1:	5b                   	pop    %ebx
  8006a2:	5e                   	pop    %esi
  8006a3:	5f                   	pop    %edi
  8006a4:	5d                   	pop    %ebp
  8006a5:	c3                   	ret    

008006a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	83 ec 28             	sub    $0x28,%esp
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	74 30                	je     8006f7 <vsnprintf+0x51>
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	7e 33                	jle    8006fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	c7 04 24 b8 02 80 00 	movl   $0x8002b8,(%esp)
  8006e7:	e8 0e fc ff ff       	call   8002fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	eb 0c                	jmp    800703 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x5d>
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 44 24 08          	mov    %eax,0x8(%esp)
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 7b ff ff ff       	call   8006a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    
  80072d:	00 00                	add    %al,(%eax)
	...

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	eb 01                	jmp    80073e <strlen+0xe>
		n++;
  80073d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800742:	75 f9                	jne    80073d <strlen+0xd>
		n++;
	return n;
}
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 01                	jmp    800757 <strnlen+0x11>
		n++;
  800756:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 06                	je     800761 <strnlen+0x1b>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	75 f5                	jne    800756 <strnlen+0x10>
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800775:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800778:	42                   	inc    %edx
  800779:	84 c9                	test   %cl,%cl
  80077b:	75 f5                	jne    800772 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	89 1c 24             	mov    %ebx,(%esp)
  80078d:	e8 9e ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	01 d8                	add    %ebx,%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 c0 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007be:	eb 0c                	jmp    8007cc <strncpy+0x21>
		*dst++ = *src;
  8007c0:	8a 1a                	mov    (%edx),%bl
  8007c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	41                   	inc    %ecx
  8007cc:	39 f1                	cmp    %esi,%ecx
  8007ce:	75 f0                	jne    8007c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	75 0a                	jne    8007f0 <strlcpy+0x1c>
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	eb 1a                	jmp    800804 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ea:	88 18                	mov    %bl,(%eax)
  8007ec:	40                   	inc    %eax
  8007ed:	41                   	inc    %ecx
  8007ee:	eb 02                	jmp    8007f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007f2:	4a                   	dec    %edx
  8007f3:	74 0a                	je     8007ff <strlcpy+0x2b>
  8007f5:	8a 19                	mov    (%ecx),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	75 ef                	jne    8007ea <strlcpy+0x16>
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	eb 02                	jmp    800801 <strlcpy+0x2d>
  8007ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800801:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800804:	29 f0                	sub    %esi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800813:	eb 02                	jmp    800817 <strcmp+0xd>
		p++, q++;
  800815:	41                   	inc    %ecx
  800816:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800817:	8a 01                	mov    (%ecx),%al
  800819:	84 c0                	test   %al,%al
  80081b:	74 04                	je     800821 <strcmp+0x17>
  80081d:	3a 02                	cmp    (%edx),%al
  80081f:	74 f4                	je     800815 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800821:	0f b6 c0             	movzbl %al,%eax
  800824:	0f b6 12             	movzbl (%edx),%edx
  800827:	29 d0                	sub    %edx,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800838:	eb 03                	jmp    80083d <strncmp+0x12>
		n--, p++, q++;
  80083a:	4a                   	dec    %edx
  80083b:	40                   	inc    %eax
  80083c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 14                	je     800855 <strncmp+0x2a>
  800841:	8a 18                	mov    (%eax),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	74 04                	je     80084b <strncmp+0x20>
  800847:	3a 19                	cmp    (%ecx),%bl
  800849:	74 ef                	je     80083a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 11             	movzbl (%ecx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb 05                	jmp    80085a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800866:	eb 05                	jmp    80086d <strchr+0x10>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0c                	je     800878 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	40                   	inc    %eax
  80086d:	8a 10                	mov    (%eax),%dl
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f5                	jne    800868 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800883:	eb 05                	jmp    80088a <strfind+0x10>
		if (*s == c)
  800885:	38 ca                	cmp    %cl,%dl
  800887:	74 07                	je     800890 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800889:	40                   	inc    %eax
  80088a:	8a 10                	mov    (%eax),%dl
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f5                	jne    800885 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a1:	85 c9                	test   %ecx,%ecx
  8008a3:	74 30                	je     8008d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 25                	jne    8008d2 <memset+0x40>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 20                	jne    8008d2 <memset+0x40>
		c &= 0xFF;
  8008b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b5:	89 d3                	mov    %edx,%ebx
  8008b7:	c1 e3 08             	shl    $0x8,%ebx
  8008ba:	89 d6                	mov    %edx,%esi
  8008bc:	c1 e6 18             	shl    $0x18,%esi
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	c1 e0 10             	shl    $0x10,%eax
  8008c4:	09 f0                	or     %esi,%eax
  8008c6:	09 d0                	or     %edx,%eax
  8008c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008cd:	fc                   	cld    
  8008ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d0:	eb 03                	jmp    8008d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d2:	fc                   	cld    
  8008d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5f                   	pop    %edi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ea:	39 c6                	cmp    %eax,%esi
  8008ec:	73 34                	jae    800922 <memmove+0x46>
  8008ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f1:	39 d0                	cmp    %edx,%eax
  8008f3:	73 2d                	jae    800922 <memmove+0x46>
		s += n;
		d += n;
  8008f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	f6 c2 03             	test   $0x3,%dl
  8008fb:	75 1b                	jne    800918 <memmove+0x3c>
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 13                	jne    800918 <memmove+0x3c>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0e                	jne    800918 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80090a:	83 ef 04             	sub    $0x4,%edi
  80090d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800910:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800913:	fd                   	std    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 07                	jmp    80091f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800918:	4f                   	dec    %edi
  800919:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091c:	fd                   	std    
  80091d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091f:	fc                   	cld    
  800920:	eb 20                	jmp    800942 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800928:	75 13                	jne    80093d <memmove+0x61>
  80092a:	a8 03                	test   $0x3,%al
  80092c:	75 0f                	jne    80093d <memmove+0x61>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 0a                	jne    80093d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800933:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093b:	eb 05                	jmp    800942 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093d:	89 c7                	mov    %eax,%edi
  80093f:	fc                   	cld    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80094c:	8b 45 10             	mov    0x10(%ebp),%eax
  80094f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 77 ff ff ff       	call   8008dc <memmove>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
  80097b:	eb 16                	jmp    800993 <memcmp+0x2c>
		if (*s1 != *s2)
  80097d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800980:	42                   	inc    %edx
  800981:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800985:	38 c8                	cmp    %cl,%al
  800987:	74 0a                	je     800993 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800989:	0f b6 c0             	movzbl %al,%eax
  80098c:	0f b6 c9             	movzbl %cl,%ecx
  80098f:	29 c8                	sub    %ecx,%eax
  800991:	eb 09                	jmp    80099c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 da                	cmp    %ebx,%edx
  800995:	75 e6                	jne    80097d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009af:	eb 05                	jmp    8009b6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	74 05                	je     8009ba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	40                   	inc    %eax
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	72 f7                	jb     8009b1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c8:	eb 01                	jmp    8009cb <strtol+0xf>
		s++;
  8009ca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	8a 02                	mov    (%edx),%al
  8009cd:	3c 20                	cmp    $0x20,%al
  8009cf:	74 f9                	je     8009ca <strtol+0xe>
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	74 f5                	je     8009ca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d5:	3c 2b                	cmp    $0x2b,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x25>
		s++;
  8009d9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009da:	bf 00 00 00 00       	mov    $0x0,%edi
  8009df:	eb 13                	jmp    8009f4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e1:	3c 2d                	cmp    $0x2d,%al
  8009e3:	75 0a                	jne    8009ef <strtol+0x33>
		s++, neg = 1;
  8009e5:	8d 52 01             	lea    0x1(%edx),%edx
  8009e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ed:	eb 05                	jmp    8009f4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	85 db                	test   %ebx,%ebx
  8009f6:	74 05                	je     8009fd <strtol+0x41>
  8009f8:	83 fb 10             	cmp    $0x10,%ebx
  8009fb:	75 28                	jne    800a25 <strtol+0x69>
  8009fd:	8a 02                	mov    (%edx),%al
  8009ff:	3c 30                	cmp    $0x30,%al
  800a01:	75 10                	jne    800a13 <strtol+0x57>
  800a03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a07:	75 0a                	jne    800a13 <strtol+0x57>
		s += 2, base = 16;
  800a09:	83 c2 02             	add    $0x2,%edx
  800a0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a11:	eb 12                	jmp    800a25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a13:	85 db                	test   %ebx,%ebx
  800a15:	75 0e                	jne    800a25 <strtol+0x69>
  800a17:	3c 30                	cmp    $0x30,%al
  800a19:	75 05                	jne    800a20 <strtol+0x64>
		s++, base = 8;
  800a1b:	42                   	inc    %edx
  800a1c:	b3 08                	mov    $0x8,%bl
  800a1e:	eb 05                	jmp    800a25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2c:	8a 0a                	mov    (%edx),%cl
  800a2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a31:	80 fb 09             	cmp    $0x9,%bl
  800a34:	77 08                	ja     800a3e <strtol+0x82>
			dig = *s - '0';
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 30             	sub    $0x30,%ecx
  800a3c:	eb 1e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a46:	0f be c9             	movsbl %cl,%ecx
  800a49:	83 e9 57             	sub    $0x57,%ecx
  800a4c:	eb 0e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 12                	ja     800a68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5c:	39 f1                	cmp    %esi,%ecx
  800a5e:	7d 0c                	jge    800a6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a60:	42                   	inc    %edx
  800a61:	0f af c6             	imul   %esi,%eax
  800a64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a66:	eb c4                	jmp    800a2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a68:	89 c1                	mov    %eax,%ecx
  800a6a:	eb 02                	jmp    800a6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a72:	74 05                	je     800a79 <strtol+0xbd>
		*endptr = (char *) s;
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	74 04                	je     800a81 <strtol+0xc5>
  800a7d:	89 c8                	mov    %ecx,%eax
  800a7f:	f7 d8                	neg    %eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    
	...

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 28                	jle    800b0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aeb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800af2:	00 
  800af3:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800afa:	00 
  800afb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b02:	00 
  800b03:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800b0a:	e8 ed 10 00 00       	call   801bfc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0f:	83 c4 2c             	add    $0x2c,%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 02 00 00 00       	mov    $0x2,%eax
  800b27:	89 d1                	mov    %edx,%ecx
  800b29:	89 d3                	mov    %edx,%ebx
  800b2b:	89 d7                	mov    %edx,%edi
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_yield>:

void
sys_yield(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	be 00 00 00 00       	mov    $0x0,%esi
  800b63:	b8 04 00 00 00       	mov    $0x4,%eax
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 f7                	mov    %esi,%edi
  800b73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 28                	jle    800ba1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b84:	00 
  800b85:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b94:	00 
  800b95:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800b9c:	e8 5b 10 00 00       	call   801bfc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba1:	83 c4 2c             	add    $0x2c,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 28                	jle    800bf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800bdf:	00 
  800be0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be7:	00 
  800be8:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800bef:	e8 08 10 00 00       	call   801bfc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	83 c4 2c             	add    $0x2c,%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 28                	jle    800c47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800c42:	e8 b5 0f 00 00       	call   801bfc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	83 c4 2c             	add    $0x2c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 28                	jle    800c9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800c85:	00 
  800c86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8d:	00 
  800c8e:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800c95:	e8 62 0f 00 00       	call   801bfc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	83 c4 2c             	add    $0x2c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 28                	jle    800ced <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce0:	00 
  800ce1:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800ce8:	e8 0f 0f 00 00       	call   801bfc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ced:	83 c4 2c             	add    $0x2c,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 28                	jle    800d40 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d23:	00 
  800d24:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d33:	00 
  800d34:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800d3b:	e8 bc 0e 00 00       	call   801bfc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	83 c4 2c             	add    $0x2c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 1f 23 80 	movl   $0x80231f,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 3c 23 80 00 	movl   $0x80233c,(%esp)
  800db0:	e8 47 0e 00 00       	call   801bfc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	00 00                	add    %al,(%eax)
	...

00800dc0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dc6:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dcd:	0f 85 80 00 00 00    	jne    800e53 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800dd3:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd8:	8b 40 48             	mov    0x48(%eax),%eax
  800ddb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800de2:	00 
  800de3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dea:	ee 
  800deb:	89 04 24             	mov    %eax,(%esp)
  800dee:	e8 62 fd ff ff       	call   800b55 <sys_page_alloc>
  800df3:	85 c0                	test   %eax,%eax
  800df5:	79 20                	jns    800e17 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800df7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dfb:	c7 44 24 08 4c 23 80 	movl   $0x80234c,0x8(%esp)
  800e02:	00 
  800e03:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800e0a:	00 
  800e0b:	c7 04 24 a8 23 80 00 	movl   $0x8023a8,(%esp)
  800e12:	e8 e5 0d 00 00       	call   801bfc <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800e17:	a1 04 40 80 00       	mov    0x804004,%eax
  800e1c:	8b 40 48             	mov    0x48(%eax),%eax
  800e1f:	c7 44 24 04 60 0e 80 	movl   $0x800e60,0x4(%esp)
  800e26:	00 
  800e27:	89 04 24             	mov    %eax,(%esp)
  800e2a:	e8 c6 fe ff ff       	call   800cf5 <sys_env_set_pgfault_upcall>
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	79 20                	jns    800e53 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800e33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e37:	c7 44 24 08 78 23 80 	movl   $0x802378,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 a8 23 80 00 	movl   $0x8023a8,(%esp)
  800e4e:	e8 a9 0d 00 00       	call   801bfc <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    
  800e5d:	00 00                	add    %al,(%eax)
	...

00800e60 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e60:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e61:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e66:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e68:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  800e6b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800e6f:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800e71:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800e74:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800e75:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  800e78:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  800e7a:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800e7d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800e7e:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800e81:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e82:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800e83:	c3                   	ret    

00800e84 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	89 04 24             	mov    %eax,(%esp)
  800ea0:	e8 df ff ff ff       	call   800e84 <fd2num>
  800ea5:	05 20 00 0d 00       	add    $0xd0020,%eax
  800eaa:	c1 e0 0c             	shl    $0xc,%eax
}
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    

00800eaf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	53                   	push   %ebx
  800eb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800eb6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ebb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	c1 ea 16             	shr    $0x16,%edx
  800ec2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	74 11                	je     800edf <fd_alloc+0x30>
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	c1 ea 0c             	shr    $0xc,%edx
  800ed3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eda:	f6 c2 01             	test   $0x1,%dl
  800edd:	75 09                	jne    800ee8 <fd_alloc+0x39>
			*fd_store = fd;
  800edf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 17                	jmp    800eff <fd_alloc+0x50>
  800ee8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef2:	75 c7                	jne    800ebb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800efa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eff:	5b                   	pop    %ebx
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f08:	83 f8 1f             	cmp    $0x1f,%eax
  800f0b:	77 36                	ja     800f43 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f12:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f15:	89 c2                	mov    %eax,%edx
  800f17:	c1 ea 16             	shr    $0x16,%edx
  800f1a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f21:	f6 c2 01             	test   $0x1,%dl
  800f24:	74 24                	je     800f4a <fd_lookup+0x48>
  800f26:	89 c2                	mov    %eax,%edx
  800f28:	c1 ea 0c             	shr    $0xc,%edx
  800f2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f32:	f6 c2 01             	test   $0x1,%dl
  800f35:	74 1a                	je     800f51 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f41:	eb 13                	jmp    800f56 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f48:	eb 0c                	jmp    800f56 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4f:	eb 05                	jmp    800f56 <fd_lookup+0x54>
  800f51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 14             	sub    $0x14,%esp
  800f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f65:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6a:	eb 0e                	jmp    800f7a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f6c:	39 08                	cmp    %ecx,(%eax)
  800f6e:	75 09                	jne    800f79 <dev_lookup+0x21>
			*dev = devtab[i];
  800f70:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	eb 33                	jmp    800fac <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f79:	42                   	inc    %edx
  800f7a:	8b 04 95 34 24 80 00 	mov    0x802434(,%edx,4),%eax
  800f81:	85 c0                	test   %eax,%eax
  800f83:	75 e7                	jne    800f6c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f85:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8a:	8b 40 48             	mov    0x48(%eax),%eax
  800f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f95:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  800f9c:	e8 f7 f1 ff ff       	call   800198 <cprintf>
	*dev = 0;
  800fa1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fa7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fac:	83 c4 14             	add    $0x14,%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 30             	sub    $0x30,%esp
  800fba:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbd:	8a 45 0c             	mov    0xc(%ebp),%al
  800fc0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc3:	89 34 24             	mov    %esi,(%esp)
  800fc6:	e8 b9 fe ff ff       	call   800e84 <fd2num>
  800fcb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fce:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	e8 28 ff ff ff       	call   800f02 <fd_lookup>
  800fda:	89 c3                	mov    %eax,%ebx
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 05                	js     800fe5 <fd_close+0x33>
	    || fd != fd2)
  800fe0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fe3:	74 0d                	je     800ff2 <fd_close+0x40>
		return (must_exist ? r : 0);
  800fe5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fe9:	75 46                	jne    801031 <fd_close+0x7f>
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff0:	eb 3f                	jmp    801031 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff9:	8b 06                	mov    (%esi),%eax
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 55 ff ff ff       	call   800f58 <dev_lookup>
  801003:	89 c3                	mov    %eax,%ebx
  801005:	85 c0                	test   %eax,%eax
  801007:	78 18                	js     801021 <fd_close+0x6f>
		if (dev->dev_close)
  801009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100c:	8b 40 10             	mov    0x10(%eax),%eax
  80100f:	85 c0                	test   %eax,%eax
  801011:	74 09                	je     80101c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801013:	89 34 24             	mov    %esi,(%esp)
  801016:	ff d0                	call   *%eax
  801018:	89 c3                	mov    %eax,%ebx
  80101a:	eb 05                	jmp    801021 <fd_close+0x6f>
		else
			r = 0;
  80101c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801021:	89 74 24 04          	mov    %esi,0x4(%esp)
  801025:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102c:	e8 cb fb ff ff       	call   800bfc <sys_page_unmap>
	return r;
}
  801031:	89 d8                	mov    %ebx,%eax
  801033:	83 c4 30             	add    $0x30,%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801040:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	89 04 24             	mov    %eax,(%esp)
  80104d:	e8 b0 fe ff ff       	call   800f02 <fd_lookup>
  801052:	85 c0                	test   %eax,%eax
  801054:	78 13                	js     801069 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801056:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80105d:	00 
  80105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801061:	89 04 24             	mov    %eax,(%esp)
  801064:	e8 49 ff ff ff       	call   800fb2 <fd_close>
}
  801069:	c9                   	leave  
  80106a:	c3                   	ret    

0080106b <close_all>:

void
close_all(void)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	53                   	push   %ebx
  80106f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801072:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801077:	89 1c 24             	mov    %ebx,(%esp)
  80107a:	e8 bb ff ff ff       	call   80103a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80107f:	43                   	inc    %ebx
  801080:	83 fb 20             	cmp    $0x20,%ebx
  801083:	75 f2                	jne    801077 <close_all+0xc>
		close(i);
}
  801085:	83 c4 14             	add    $0x14,%esp
  801088:	5b                   	pop    %ebx
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	83 ec 4c             	sub    $0x4c,%esp
  801094:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801097:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80109a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 59 fe ff ff       	call   800f02 <fd_lookup>
  8010a9:	89 c3                	mov    %eax,%ebx
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	0f 88 e1 00 00 00    	js     801194 <dup+0x109>
		return r;
	close(newfdnum);
  8010b3:	89 3c 24             	mov    %edi,(%esp)
  8010b6:	e8 7f ff ff ff       	call   80103a <close>

	newfd = INDEX2FD(newfdnum);
  8010bb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010c1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	e8 c5 fd ff ff       	call   800e94 <fd2data>
  8010cf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010d1:	89 34 24             	mov    %esi,(%esp)
  8010d4:	e8 bb fd ff ff       	call   800e94 <fd2data>
  8010d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	c1 e8 16             	shr    $0x16,%eax
  8010e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e8:	a8 01                	test   $0x1,%al
  8010ea:	74 46                	je     801132 <dup+0xa7>
  8010ec:	89 d8                	mov    %ebx,%eax
  8010ee:	c1 e8 0c             	shr    $0xc,%eax
  8010f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f8:	f6 c2 01             	test   $0x1,%dl
  8010fb:	74 35                	je     801132 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801104:	25 07 0e 00 00       	and    $0xe07,%eax
  801109:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801110:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801114:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80111b:	00 
  80111c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801120:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801127:	e8 7d fa ff ff       	call   800ba9 <sys_page_map>
  80112c:	89 c3                	mov    %eax,%ebx
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 3b                	js     80116d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 0c             	shr    $0xc,%edx
  80113a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801141:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801147:	89 54 24 10          	mov    %edx,0x10(%esp)
  80114b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80114f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801156:	00 
  801157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801162:	e8 42 fa ff ff       	call   800ba9 <sys_page_map>
  801167:	89 c3                	mov    %eax,%ebx
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 25                	jns    801192 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80116d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801178:	e8 7f fa ff ff       	call   800bfc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80117d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801180:	89 44 24 04          	mov    %eax,0x4(%esp)
  801184:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80118b:	e8 6c fa ff ff       	call   800bfc <sys_page_unmap>
	return r;
  801190:	eb 02                	jmp    801194 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801192:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801194:	89 d8                	mov    %ebx,%eax
  801196:	83 c4 4c             	add    $0x4c,%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 24             	sub    $0x24,%esp
  8011a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011af:	89 1c 24             	mov    %ebx,(%esp)
  8011b2:	e8 4b fd ff ff       	call   800f02 <fd_lookup>
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 6d                	js     801228 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	8b 00                	mov    (%eax),%eax
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	e8 89 fd ff ff       	call   800f58 <dev_lookup>
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 55                	js     801228 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	8b 50 08             	mov    0x8(%eax),%edx
  8011d9:	83 e2 03             	and    $0x3,%edx
  8011dc:	83 fa 01             	cmp    $0x1,%edx
  8011df:	75 23                	jne    801204 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e6:	8b 40 48             	mov    0x48(%eax),%eax
  8011e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f1:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  8011f8:	e8 9b ef ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  8011fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801202:	eb 24                	jmp    801228 <read+0x8a>
	}
	if (!dev->dev_read)
  801204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801207:	8b 52 08             	mov    0x8(%edx),%edx
  80120a:	85 d2                	test   %edx,%edx
  80120c:	74 15                	je     801223 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801211:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801218:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80121c:	89 04 24             	mov    %eax,(%esp)
  80121f:	ff d2                	call   *%edx
  801221:	eb 05                	jmp    801228 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801223:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801228:	83 c4 24             	add    $0x24,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 1c             	sub    $0x1c,%esp
  801237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	eb 23                	jmp    801267 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801244:	89 f0                	mov    %esi,%eax
  801246:	29 d8                	sub    %ebx,%eax
  801248:	89 44 24 08          	mov    %eax,0x8(%esp)
  80124c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124f:	01 d8                	add    %ebx,%eax
  801251:	89 44 24 04          	mov    %eax,0x4(%esp)
  801255:	89 3c 24             	mov    %edi,(%esp)
  801258:	e8 41 ff ff ff       	call   80119e <read>
		if (m < 0)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 10                	js     801271 <readn+0x43>
			return m;
		if (m == 0)
  801261:	85 c0                	test   %eax,%eax
  801263:	74 0a                	je     80126f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801265:	01 c3                	add    %eax,%ebx
  801267:	39 f3                	cmp    %esi,%ebx
  801269:	72 d9                	jb     801244 <readn+0x16>
  80126b:	89 d8                	mov    %ebx,%eax
  80126d:	eb 02                	jmp    801271 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80126f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801271:	83 c4 1c             	add    $0x1c,%esp
  801274:	5b                   	pop    %ebx
  801275:	5e                   	pop    %esi
  801276:	5f                   	pop    %edi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	53                   	push   %ebx
  80127d:	83 ec 24             	sub    $0x24,%esp
  801280:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801283:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128a:	89 1c 24             	mov    %ebx,(%esp)
  80128d:	e8 70 fc ff ff       	call   800f02 <fd_lookup>
  801292:	85 c0                	test   %eax,%eax
  801294:	78 68                	js     8012fe <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801296:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	8b 00                	mov    (%eax),%eax
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 ae fc ff ff       	call   800f58 <dev_lookup>
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 50                	js     8012fe <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b5:	75 23                	jne    8012da <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8012bc:	8b 40 48             	mov    0x48(%eax),%eax
  8012bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c7:	c7 04 24 15 24 80 00 	movl   $0x802415,(%esp)
  8012ce:	e8 c5 ee ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  8012d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d8:	eb 24                	jmp    8012fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e0:	85 d2                	test   %edx,%edx
  8012e2:	74 15                	je     8012f9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	ff d2                	call   *%edx
  8012f7:	eb 05                	jmp    8012fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012fe:	83 c4 24             	add    $0x24,%esp
  801301:	5b                   	pop    %ebx
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <seek>:

int
seek(int fdnum, off_t offset)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	89 04 24             	mov    %eax,(%esp)
  801317:	e8 e6 fb ff ff       	call   800f02 <fd_lookup>
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 0e                	js     80132e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801320:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801323:	8b 55 0c             	mov    0xc(%ebp),%edx
  801326:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80132e:	c9                   	leave  
  80132f:	c3                   	ret    

00801330 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 24             	sub    $0x24,%esp
  801337:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	89 1c 24             	mov    %ebx,(%esp)
  801344:	e8 b9 fb ff ff       	call   800f02 <fd_lookup>
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 61                	js     8013ae <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	89 44 24 04          	mov    %eax,0x4(%esp)
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	8b 00                	mov    (%eax),%eax
  801359:	89 04 24             	mov    %eax,(%esp)
  80135c:	e8 f7 fb ff ff       	call   800f58 <dev_lookup>
  801361:	85 c0                	test   %eax,%eax
  801363:	78 49                	js     8013ae <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801368:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80136c:	75 23                	jne    801391 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80136e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801373:	8b 40 48             	mov    0x48(%eax),%eax
  801376:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80137a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137e:	c7 04 24 d8 23 80 00 	movl   $0x8023d8,(%esp)
  801385:	e8 0e ee ff ff       	call   800198 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80138a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138f:	eb 1d                	jmp    8013ae <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801391:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801394:	8b 52 18             	mov    0x18(%edx),%edx
  801397:	85 d2                	test   %edx,%edx
  801399:	74 0e                	je     8013a9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80139b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a2:	89 04 24             	mov    %eax,(%esp)
  8013a5:	ff d2                	call   *%edx
  8013a7:	eb 05                	jmp    8013ae <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013ae:	83 c4 24             	add    $0x24,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 24             	sub    $0x24,%esp
  8013bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 32 fb ff ff       	call   800f02 <fd_lookup>
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 52                	js     801426 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013de:	8b 00                	mov    (%eax),%eax
  8013e0:	89 04 24             	mov    %eax,(%esp)
  8013e3:	e8 70 fb ff ff       	call   800f58 <dev_lookup>
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 3a                	js     801426 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f3:	74 2c                	je     801421 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ff:	00 00 00 
	stat->st_isdir = 0;
  801402:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801409:	00 00 00 
	stat->st_dev = dev;
  80140c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801412:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801416:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801419:	89 14 24             	mov    %edx,(%esp)
  80141c:	ff 50 14             	call   *0x14(%eax)
  80141f:	eb 05                	jmp    801426 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801421:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801426:	83 c4 24             	add    $0x24,%esp
  801429:	5b                   	pop    %ebx
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801434:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80143b:	00 
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	e8 fe 01 00 00       	call   801645 <open>
  801447:	89 c3                	mov    %eax,%ebx
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 1b                	js     801468 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80144d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801450:	89 44 24 04          	mov    %eax,0x4(%esp)
  801454:	89 1c 24             	mov    %ebx,(%esp)
  801457:	e8 58 ff ff ff       	call   8013b4 <fstat>
  80145c:	89 c6                	mov    %eax,%esi
	close(fd);
  80145e:	89 1c 24             	mov    %ebx,(%esp)
  801461:	e8 d4 fb ff ff       	call   80103a <close>
	return r;
  801466:	89 f3                	mov    %esi,%ebx
}
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    
  801471:	00 00                	add    %al,(%eax)
	...

00801474 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 10             	sub    $0x10,%esp
  80147c:	89 c3                	mov    %eax,%ebx
  80147e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801480:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801487:	75 11                	jne    80149a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801489:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801490:	e8 90 08 00 00       	call   801d25 <ipc_find_env>
  801495:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80149a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014a1:	00 
  8014a2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014a9:	00 
  8014aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ae:	a1 00 40 80 00       	mov    0x804000,%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 00 08 00 00       	call   801cbb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c2:	00 
  8014c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ce:	e8 81 07 00 00       	call   801c54 <ipc_recv>
}
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ee:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8014fd:	e8 72 ff ff ff       	call   801474 <fsipc>
}
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80150a:	8b 45 08             	mov    0x8(%ebp),%eax
  80150d:	8b 40 0c             	mov    0xc(%eax),%eax
  801510:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801515:	ba 00 00 00 00       	mov    $0x0,%edx
  80151a:	b8 06 00 00 00       	mov    $0x6,%eax
  80151f:	e8 50 ff ff ff       	call   801474 <fsipc>
}
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 14             	sub    $0x14,%esp
  80152d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	8b 40 0c             	mov    0xc(%eax),%eax
  801536:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 05 00 00 00       	mov    $0x5,%eax
  801545:	e8 2a ff ff ff       	call   801474 <fsipc>
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 2b                	js     801579 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80154e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801555:	00 
  801556:	89 1c 24             	mov    %ebx,(%esp)
  801559:	e8 05 f2 ff ff       	call   800763 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80155e:	a1 80 50 80 00       	mov    0x805080,%eax
  801563:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801569:	a1 84 50 80 00       	mov    0x805084,%eax
  80156e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801574:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801579:	83 c4 14             	add    $0x14,%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801585:	c7 44 24 08 44 24 80 	movl   $0x802444,0x8(%esp)
  80158c:	00 
  80158d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801594:	00 
  801595:	c7 04 24 62 24 80 00 	movl   $0x802462,(%esp)
  80159c:	e8 5b 06 00 00       	call   801bfc <_panic>

008015a1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 10             	sub    $0x10,%esp
  8015a9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c7:	e8 a8 fe ff ff       	call   801474 <fsipc>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 6a                	js     80163c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015d2:	39 c6                	cmp    %eax,%esi
  8015d4:	73 24                	jae    8015fa <devfile_read+0x59>
  8015d6:	c7 44 24 0c 6d 24 80 	movl   $0x80246d,0xc(%esp)
  8015dd:	00 
  8015de:	c7 44 24 08 74 24 80 	movl   $0x802474,0x8(%esp)
  8015e5:	00 
  8015e6:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015ed:	00 
  8015ee:	c7 04 24 62 24 80 00 	movl   $0x802462,(%esp)
  8015f5:	e8 02 06 00 00       	call   801bfc <_panic>
	assert(r <= PGSIZE);
  8015fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ff:	7e 24                	jle    801625 <devfile_read+0x84>
  801601:	c7 44 24 0c 89 24 80 	movl   $0x802489,0xc(%esp)
  801608:	00 
  801609:	c7 44 24 08 74 24 80 	movl   $0x802474,0x8(%esp)
  801610:	00 
  801611:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801618:	00 
  801619:	c7 04 24 62 24 80 00 	movl   $0x802462,(%esp)
  801620:	e8 d7 05 00 00       	call   801bfc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801625:	89 44 24 08          	mov    %eax,0x8(%esp)
  801629:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801630:	00 
  801631:	8b 45 0c             	mov    0xc(%ebp),%eax
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	e8 a0 f2 ff ff       	call   8008dc <memmove>
	return r;
}
  80163c:	89 d8                	mov    %ebx,%eax
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	83 ec 20             	sub    $0x20,%esp
  80164d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801650:	89 34 24             	mov    %esi,(%esp)
  801653:	e8 d8 f0 ff ff       	call   800730 <strlen>
  801658:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80165d:	7f 60                	jg     8016bf <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	89 04 24             	mov    %eax,(%esp)
  801665:	e8 45 f8 ff ff       	call   800eaf <fd_alloc>
  80166a:	89 c3                	mov    %eax,%ebx
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 54                	js     8016c4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801670:	89 74 24 04          	mov    %esi,0x4(%esp)
  801674:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80167b:	e8 e3 f0 ff ff       	call   800763 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801680:	8b 45 0c             	mov    0xc(%ebp),%eax
  801683:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801688:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168b:	b8 01 00 00 00       	mov    $0x1,%eax
  801690:	e8 df fd ff ff       	call   801474 <fsipc>
  801695:	89 c3                	mov    %eax,%ebx
  801697:	85 c0                	test   %eax,%eax
  801699:	79 15                	jns    8016b0 <open+0x6b>
		fd_close(fd, 0);
  80169b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016a2:	00 
  8016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 04 f9 ff ff       	call   800fb2 <fd_close>
		return r;
  8016ae:	eb 14                	jmp    8016c4 <open+0x7f>
	}

	return fd2num(fd);
  8016b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b3:	89 04 24             	mov    %eax,(%esp)
  8016b6:	e8 c9 f7 ff ff       	call   800e84 <fd2num>
  8016bb:	89 c3                	mov    %eax,%ebx
  8016bd:	eb 05                	jmp    8016c4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016bf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	83 c4 20             	add    $0x20,%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016dd:	e8 92 fd ff ff       	call   801474 <fsipc>
}
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 10             	sub    $0x10,%esp
  8016ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	89 04 24             	mov    %eax,(%esp)
  8016f5:	e8 9a f7 ff ff       	call   800e94 <fd2data>
  8016fa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8016fc:	c7 44 24 04 95 24 80 	movl   $0x802495,0x4(%esp)
  801703:	00 
  801704:	89 34 24             	mov    %esi,(%esp)
  801707:	e8 57 f0 ff ff       	call   800763 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80170c:	8b 43 04             	mov    0x4(%ebx),%eax
  80170f:	2b 03                	sub    (%ebx),%eax
  801711:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801717:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80171e:	00 00 00 
	stat->st_dev = &devpipe;
  801721:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801728:	30 80 00 
	return 0;
}
  80172b:	b8 00 00 00 00       	mov    $0x0,%eax
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 14             	sub    $0x14,%esp
  80173e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801741:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801745:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174c:	e8 ab f4 ff ff       	call   800bfc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801751:	89 1c 24             	mov    %ebx,(%esp)
  801754:	e8 3b f7 ff ff       	call   800e94 <fd2data>
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801764:	e8 93 f4 ff ff       	call   800bfc <sys_page_unmap>
}
  801769:	83 c4 14             	add    $0x14,%esp
  80176c:	5b                   	pop    %ebx
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	57                   	push   %edi
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	83 ec 2c             	sub    $0x2c,%esp
  801778:	89 c7                	mov    %eax,%edi
  80177a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80177d:	a1 04 40 80 00       	mov    0x804004,%eax
  801782:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801785:	89 3c 24             	mov    %edi,(%esp)
  801788:	e8 df 05 00 00       	call   801d6c <pageref>
  80178d:	89 c6                	mov    %eax,%esi
  80178f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801792:	89 04 24             	mov    %eax,(%esp)
  801795:	e8 d2 05 00 00       	call   801d6c <pageref>
  80179a:	39 c6                	cmp    %eax,%esi
  80179c:	0f 94 c0             	sete   %al
  80179f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017a2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017a8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017ab:	39 cb                	cmp    %ecx,%ebx
  8017ad:	75 08                	jne    8017b7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8017af:	83 c4 2c             	add    $0x2c,%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5f                   	pop    %edi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017b7:	83 f8 01             	cmp    $0x1,%eax
  8017ba:	75 c1                	jne    80177d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017bc:	8b 42 58             	mov    0x58(%edx),%eax
  8017bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8017c6:	00 
  8017c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017cf:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  8017d6:	e8 bd e9 ff ff       	call   800198 <cprintf>
  8017db:	eb a0                	jmp    80177d <_pipeisclosed+0xe>

008017dd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	57                   	push   %edi
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 1c             	sub    $0x1c,%esp
  8017e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017e9:	89 34 24             	mov    %esi,(%esp)
  8017ec:	e8 a3 f6 ff ff       	call   800e94 <fd2data>
  8017f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8017f8:	eb 3c                	jmp    801836 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017fa:	89 da                	mov    %ebx,%edx
  8017fc:	89 f0                	mov    %esi,%eax
  8017fe:	e8 6c ff ff ff       	call   80176f <_pipeisclosed>
  801803:	85 c0                	test   %eax,%eax
  801805:	75 38                	jne    80183f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801807:	e8 2a f3 ff ff       	call   800b36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80180c:	8b 43 04             	mov    0x4(%ebx),%eax
  80180f:	8b 13                	mov    (%ebx),%edx
  801811:	83 c2 20             	add    $0x20,%edx
  801814:	39 d0                	cmp    %edx,%eax
  801816:	73 e2                	jae    8017fa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801818:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80181e:	89 c2                	mov    %eax,%edx
  801820:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801826:	79 05                	jns    80182d <devpipe_write+0x50>
  801828:	4a                   	dec    %edx
  801829:	83 ca e0             	or     $0xffffffe0,%edx
  80182c:	42                   	inc    %edx
  80182d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801831:	40                   	inc    %eax
  801832:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801835:	47                   	inc    %edi
  801836:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801839:	75 d1                	jne    80180c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80183b:	89 f8                	mov    %edi,%eax
  80183d:	eb 05                	jmp    801844 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801844:	83 c4 1c             	add    $0x1c,%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5f                   	pop    %edi
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	57                   	push   %edi
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
  801852:	83 ec 1c             	sub    $0x1c,%esp
  801855:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801858:	89 3c 24             	mov    %edi,(%esp)
  80185b:	e8 34 f6 ff ff       	call   800e94 <fd2data>
  801860:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801862:	be 00 00 00 00       	mov    $0x0,%esi
  801867:	eb 3a                	jmp    8018a3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801869:	85 f6                	test   %esi,%esi
  80186b:	74 04                	je     801871 <devpipe_read+0x25>
				return i;
  80186d:	89 f0                	mov    %esi,%eax
  80186f:	eb 40                	jmp    8018b1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801871:	89 da                	mov    %ebx,%edx
  801873:	89 f8                	mov    %edi,%eax
  801875:	e8 f5 fe ff ff       	call   80176f <_pipeisclosed>
  80187a:	85 c0                	test   %eax,%eax
  80187c:	75 2e                	jne    8018ac <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80187e:	e8 b3 f2 ff ff       	call   800b36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801883:	8b 03                	mov    (%ebx),%eax
  801885:	3b 43 04             	cmp    0x4(%ebx),%eax
  801888:	74 df                	je     801869 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80188a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80188f:	79 05                	jns    801896 <devpipe_read+0x4a>
  801891:	48                   	dec    %eax
  801892:	83 c8 e0             	or     $0xffffffe0,%eax
  801895:	40                   	inc    %eax
  801896:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80189a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018a0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a2:	46                   	inc    %esi
  8018a3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018a6:	75 db                	jne    801883 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018a8:	89 f0                	mov    %esi,%eax
  8018aa:	eb 05                	jmp    8018b1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018b1:	83 c4 1c             	add    $0x1c,%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5f                   	pop    %edi
  8018b7:	5d                   	pop    %ebp
  8018b8:	c3                   	ret    

008018b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	57                   	push   %edi
  8018bd:	56                   	push   %esi
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 3c             	sub    $0x3c,%esp
  8018c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	e8 df f5 ff ff       	call   800eaf <fd_alloc>
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	0f 88 45 01 00 00    	js     801a1f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018da:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018e1:	00 
  8018e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f0:	e8 60 f2 ff ff       	call   800b55 <sys_page_alloc>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	0f 88 20 01 00 00    	js     801a1f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	e8 a5 f5 ff ff       	call   800eaf <fd_alloc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	0f 88 f8 00 00 00    	js     801a0c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801914:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80191b:	00 
  80191c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192a:	e8 26 f2 ff ff       	call   800b55 <sys_page_alloc>
  80192f:	89 c3                	mov    %eax,%ebx
  801931:	85 c0                	test   %eax,%eax
  801933:	0f 88 d3 00 00 00    	js     801a0c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801939:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 50 f5 ff ff       	call   800e94 <fd2data>
  801944:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801946:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80194d:	00 
  80194e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801952:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801959:	e8 f7 f1 ff ff       	call   800b55 <sys_page_alloc>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	85 c0                	test   %eax,%eax
  801962:	0f 88 91 00 00 00    	js     8019f9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801968:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80196b:	89 04 24             	mov    %eax,(%esp)
  80196e:	e8 21 f5 ff ff       	call   800e94 <fd2data>
  801973:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80197a:	00 
  80197b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80197f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801986:	00 
  801987:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801992:	e8 12 f2 ff ff       	call   800ba9 <sys_page_map>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 4c                	js     8019e9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80199d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019b2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019bb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ca:	89 04 24             	mov    %eax,(%esp)
  8019cd:	e8 b2 f4 ff ff       	call   800e84 <fd2num>
  8019d2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019d7:	89 04 24             	mov    %eax,(%esp)
  8019da:	e8 a5 f4 ff ff       	call   800e84 <fd2num>
  8019df:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e7:	eb 36                	jmp    801a1f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8019e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f4:	e8 03 f2 ff ff       	call   800bfc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8019f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a07:	e8 f0 f1 ff ff       	call   800bfc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a1a:	e8 dd f1 ff ff       	call   800bfc <sys_page_unmap>
    err:
	return r;
}
  801a1f:	89 d8                	mov    %ebx,%eax
  801a21:	83 c4 3c             	add    $0x3c,%esp
  801a24:	5b                   	pop    %ebx
  801a25:	5e                   	pop    %esi
  801a26:	5f                   	pop    %edi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a36:	8b 45 08             	mov    0x8(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 c1 f4 ff ff       	call   800f02 <fd_lookup>
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 15                	js     801a5a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a48:	89 04 24             	mov    %eax,(%esp)
  801a4b:	e8 44 f4 ff ff       	call   800e94 <fd2data>
	return _pipeisclosed(fd, p);
  801a50:	89 c2                	mov    %eax,%edx
  801a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a55:	e8 15 fd ff ff       	call   80176f <_pipeisclosed>
}
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a6c:	c7 44 24 04 b4 24 80 	movl   $0x8024b4,0x4(%esp)
  801a73:	00 
  801a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a77:	89 04 24             	mov    %eax,(%esp)
  801a7a:	e8 e4 ec ff ff       	call   800763 <strcpy>
	return 0;
}
  801a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a92:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a97:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a9d:	eb 30                	jmp    801acf <devcons_write+0x49>
		m = n - tot;
  801a9f:	8b 75 10             	mov    0x10(%ebp),%esi
  801aa2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801aa4:	83 fe 7f             	cmp    $0x7f,%esi
  801aa7:	76 05                	jbe    801aae <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801aa9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801aae:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ab2:	03 45 0c             	add    0xc(%ebp),%eax
  801ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab9:	89 3c 24             	mov    %edi,(%esp)
  801abc:	e8 1b ee ff ff       	call   8008dc <memmove>
		sys_cputs(buf, m);
  801ac1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac5:	89 3c 24             	mov    %edi,(%esp)
  801ac8:	e8 bb ef ff ff       	call   800a88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801acd:	01 f3                	add    %esi,%ebx
  801acf:	89 d8                	mov    %ebx,%eax
  801ad1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ad4:	72 c9                	jb     801a9f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ad6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ae7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aeb:	75 07                	jne    801af4 <devcons_read+0x13>
  801aed:	eb 25                	jmp    801b14 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801aef:	e8 42 f0 ff ff       	call   800b36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801af4:	e8 ad ef ff ff       	call   800aa6 <sys_cgetc>
  801af9:	85 c0                	test   %eax,%eax
  801afb:	74 f2                	je     801aef <devcons_read+0xe>
  801afd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 1d                	js     801b20 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b03:	83 f8 04             	cmp    $0x4,%eax
  801b06:	74 13                	je     801b1b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0b:	88 10                	mov    %dl,(%eax)
	return 1;
  801b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b12:	eb 0c                	jmp    801b20 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
  801b19:	eb 05                	jmp    801b20 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b35:	00 
  801b36:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b39:	89 04 24             	mov    %eax,(%esp)
  801b3c:	e8 47 ef ff ff       	call   800a88 <sys_cputs>
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <getchar>:

int
getchar(void)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b49:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801b50:	00 
  801b51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5f:	e8 3a f6 ff ff       	call   80119e <read>
	if (r < 0)
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 0f                	js     801b77 <getchar+0x34>
		return r;
	if (r < 1)
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	7e 06                	jle    801b72 <getchar+0x2f>
		return -E_EOF;
	return c;
  801b6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b70:	eb 05                	jmp    801b77 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b72:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	89 04 24             	mov    %eax,(%esp)
  801b8c:	e8 71 f3 ff ff       	call   800f02 <fd_lookup>
  801b91:	85 c0                	test   %eax,%eax
  801b93:	78 11                	js     801ba6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b98:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b9e:	39 10                	cmp    %edx,(%eax)
  801ba0:	0f 94 c0             	sete   %al
  801ba3:	0f b6 c0             	movzbl %al,%eax
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <opencons>:

int
opencons(void)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb1:	89 04 24             	mov    %eax,(%esp)
  801bb4:	e8 f6 f2 ff ff       	call   800eaf <fd_alloc>
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 3c                	js     801bf9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bbd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bc4:	00 
  801bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd3:	e8 7d ef ff ff       	call   800b55 <sys_page_alloc>
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 1d                	js     801bf9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bdc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 8b f2 ff ff       	call   800e84 <fd2num>
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    
	...

00801bfc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c04:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c07:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801c0d:	e8 05 ef ff ff       	call   800b17 <sys_getenvid>
  801c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c15:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c19:	8b 55 08             	mov    0x8(%ebp),%edx
  801c1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c28:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801c2f:	e8 64 e5 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c38:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 f4 e4 ff ff       	call   800137 <vcprintf>
	cprintf("\n");
  801c43:	c7 04 24 ad 24 80 00 	movl   $0x8024ad,(%esp)
  801c4a:	e8 49 e5 ff ff       	call   800198 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c4f:	cc                   	int3   
  801c50:	eb fd                	jmp    801c4f <_panic+0x53>
	...

00801c54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	56                   	push   %esi
  801c58:	53                   	push   %ebx
  801c59:	83 ec 10             	sub    $0x10,%esp
  801c5c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801c65:	85 c0                	test   %eax,%eax
  801c67:	75 05                	jne    801c6e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801c69:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 f5 f0 ff ff       	call   800d6b <sys_ipc_recv>
	if (!err) {
  801c76:	85 c0                	test   %eax,%eax
  801c78:	75 26                	jne    801ca0 <ipc_recv+0x4c>
		if (from_env_store) {
  801c7a:	85 f6                	test   %esi,%esi
  801c7c:	74 0a                	je     801c88 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801c7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801c83:	8b 40 74             	mov    0x74(%eax),%eax
  801c86:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801c88:	85 db                	test   %ebx,%ebx
  801c8a:	74 0a                	je     801c96 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801c8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c91:	8b 40 78             	mov    0x78(%eax),%eax
  801c94:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801c96:	a1 04 40 80 00       	mov    0x804004,%eax
  801c9b:	8b 40 70             	mov    0x70(%eax),%eax
  801c9e:	eb 14                	jmp    801cb4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801ca0:	85 f6                	test   %esi,%esi
  801ca2:	74 06                	je     801caa <ipc_recv+0x56>
		*from_env_store = 0;
  801ca4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801caa:	85 db                	test   %ebx,%ebx
  801cac:	74 06                	je     801cb4 <ipc_recv+0x60>
		*perm_store = 0;
  801cae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	57                   	push   %edi
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 1c             	sub    $0x1c,%esp
  801cc4:	8b 75 10             	mov    0x10(%ebp),%esi
  801cc7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801cca:	85 f6                	test   %esi,%esi
  801ccc:	75 05                	jne    801cd3 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801cce:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801cd3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cd7:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	89 04 24             	mov    %eax,(%esp)
  801ce8:	e8 5b f0 ff ff       	call   800d48 <sys_ipc_try_send>
  801ced:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801cef:	e8 42 ee ff ff       	call   800b36 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801cf4:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801cf7:	74 da                	je     801cd3 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801cf9:	85 db                	test   %ebx,%ebx
  801cfb:	74 20                	je     801d1d <ipc_send+0x62>
		panic("send fail: %e", err);
  801cfd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d01:	c7 44 24 08 e4 24 80 	movl   $0x8024e4,0x8(%esp)
  801d08:	00 
  801d09:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801d10:	00 
  801d11:	c7 04 24 f2 24 80 00 	movl   $0x8024f2,(%esp)
  801d18:	e8 df fe ff ff       	call   801bfc <_panic>
	}
	return;
}
  801d1d:	83 c4 1c             	add    $0x1c,%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	53                   	push   %ebx
  801d29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d31:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	c1 e2 07             	shl    $0x7,%edx
  801d3d:	29 ca                	sub    %ecx,%edx
  801d3f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d45:	8b 52 50             	mov    0x50(%edx),%edx
  801d48:	39 da                	cmp    %ebx,%edx
  801d4a:	75 0f                	jne    801d5b <ipc_find_env+0x36>
			return envs[i].env_id;
  801d4c:	c1 e0 07             	shl    $0x7,%eax
  801d4f:	29 c8                	sub    %ecx,%eax
  801d51:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d56:	8b 40 40             	mov    0x40(%eax),%eax
  801d59:	eb 0c                	jmp    801d67 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d5b:	40                   	inc    %eax
  801d5c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d61:	75 ce                	jne    801d31 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d63:	66 b8 00 00          	mov    $0x0,%ax
}
  801d67:	5b                   	pop    %ebx
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    
	...

00801d6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	c1 ea 16             	shr    $0x16,%edx
  801d77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d7e:	f6 c2 01             	test   $0x1,%dl
  801d81:	74 1e                	je     801da1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d83:	c1 e8 0c             	shr    $0xc,%eax
  801d86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d8d:	a8 01                	test   $0x1,%al
  801d8f:	74 17                	je     801da8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d91:	c1 e8 0c             	shr    $0xc,%eax
  801d94:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d9b:	ef 
  801d9c:	0f b7 c0             	movzwl %ax,%eax
  801d9f:	eb 0c                	jmp    801dad <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
  801da6:	eb 05                	jmp    801dad <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
	...

00801db0 <__udivdi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	83 ec 10             	sub    $0x10,%esp
  801db6:	8b 74 24 20          	mov    0x20(%esp),%esi
  801dba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801dbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801dc6:	89 cd                	mov    %ecx,%ebp
  801dc8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	75 2c                	jne    801dfc <__udivdi3+0x4c>
  801dd0:	39 f9                	cmp    %edi,%ecx
  801dd2:	77 68                	ja     801e3c <__udivdi3+0x8c>
  801dd4:	85 c9                	test   %ecx,%ecx
  801dd6:	75 0b                	jne    801de3 <__udivdi3+0x33>
  801dd8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddd:	31 d2                	xor    %edx,%edx
  801ddf:	f7 f1                	div    %ecx
  801de1:	89 c1                	mov    %eax,%ecx
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	89 f8                	mov    %edi,%eax
  801de7:	f7 f1                	div    %ecx
  801de9:	89 c7                	mov    %eax,%edi
  801deb:	89 f0                	mov    %esi,%eax
  801ded:	f7 f1                	div    %ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	89 fa                	mov    %edi,%edx
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	5e                   	pop    %esi
  801df9:	5f                   	pop    %edi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    
  801dfc:	39 f8                	cmp    %edi,%eax
  801dfe:	77 2c                	ja     801e2c <__udivdi3+0x7c>
  801e00:	0f bd f0             	bsr    %eax,%esi
  801e03:	83 f6 1f             	xor    $0x1f,%esi
  801e06:	75 4c                	jne    801e54 <__udivdi3+0xa4>
  801e08:	39 f8                	cmp    %edi,%eax
  801e0a:	bf 00 00 00 00       	mov    $0x0,%edi
  801e0f:	72 0a                	jb     801e1b <__udivdi3+0x6b>
  801e11:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e15:	0f 87 ad 00 00 00    	ja     801ec8 <__udivdi3+0x118>
  801e1b:	be 01 00 00 00       	mov    $0x1,%esi
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	89 fa                	mov    %edi,%edx
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    
  801e2b:	90                   	nop
  801e2c:	31 ff                	xor    %edi,%edi
  801e2e:	31 f6                	xor    %esi,%esi
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	89 fa                	mov    %edi,%edx
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	5e                   	pop    %esi
  801e38:	5f                   	pop    %edi
  801e39:	5d                   	pop    %ebp
  801e3a:	c3                   	ret    
  801e3b:	90                   	nop
  801e3c:	89 fa                	mov    %edi,%edx
  801e3e:	89 f0                	mov    %esi,%eax
  801e40:	f7 f1                	div    %ecx
  801e42:	89 c6                	mov    %eax,%esi
  801e44:	31 ff                	xor    %edi,%edi
  801e46:	89 f0                	mov    %esi,%eax
  801e48:	89 fa                	mov    %edi,%edx
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	5e                   	pop    %esi
  801e4e:	5f                   	pop    %edi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    
  801e51:	8d 76 00             	lea    0x0(%esi),%esi
  801e54:	89 f1                	mov    %esi,%ecx
  801e56:	d3 e0                	shl    %cl,%eax
  801e58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5c:	b8 20 00 00 00       	mov    $0x20,%eax
  801e61:	29 f0                	sub    %esi,%eax
  801e63:	89 ea                	mov    %ebp,%edx
  801e65:	88 c1                	mov    %al,%cl
  801e67:	d3 ea                	shr    %cl,%edx
  801e69:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e6d:	09 ca                	or     %ecx,%edx
  801e6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e73:	89 f1                	mov    %esi,%ecx
  801e75:	d3 e5                	shl    %cl,%ebp
  801e77:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e7b:	89 fd                	mov    %edi,%ebp
  801e7d:	88 c1                	mov    %al,%cl
  801e7f:	d3 ed                	shr    %cl,%ebp
  801e81:	89 fa                	mov    %edi,%edx
  801e83:	89 f1                	mov    %esi,%ecx
  801e85:	d3 e2                	shl    %cl,%edx
  801e87:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e8b:	88 c1                	mov    %al,%cl
  801e8d:	d3 ef                	shr    %cl,%edi
  801e8f:	09 d7                	or     %edx,%edi
  801e91:	89 f8                	mov    %edi,%eax
  801e93:	89 ea                	mov    %ebp,%edx
  801e95:	f7 74 24 08          	divl   0x8(%esp)
  801e99:	89 d1                	mov    %edx,%ecx
  801e9b:	89 c7                	mov    %eax,%edi
  801e9d:	f7 64 24 0c          	mull   0xc(%esp)
  801ea1:	39 d1                	cmp    %edx,%ecx
  801ea3:	72 17                	jb     801ebc <__udivdi3+0x10c>
  801ea5:	74 09                	je     801eb0 <__udivdi3+0x100>
  801ea7:	89 fe                	mov    %edi,%esi
  801ea9:	31 ff                	xor    %edi,%edi
  801eab:	e9 41 ff ff ff       	jmp    801df1 <__udivdi3+0x41>
  801eb0:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eb4:	89 f1                	mov    %esi,%ecx
  801eb6:	d3 e2                	shl    %cl,%edx
  801eb8:	39 c2                	cmp    %eax,%edx
  801eba:	73 eb                	jae    801ea7 <__udivdi3+0xf7>
  801ebc:	8d 77 ff             	lea    -0x1(%edi),%esi
  801ebf:	31 ff                	xor    %edi,%edi
  801ec1:	e9 2b ff ff ff       	jmp    801df1 <__udivdi3+0x41>
  801ec6:	66 90                	xchg   %ax,%ax
  801ec8:	31 f6                	xor    %esi,%esi
  801eca:	e9 22 ff ff ff       	jmp    801df1 <__udivdi3+0x41>
	...

00801ed0 <__umoddi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	83 ec 20             	sub    $0x20,%esp
  801ed6:	8b 44 24 30          	mov    0x30(%esp),%eax
  801eda:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801ede:	89 44 24 14          	mov    %eax,0x14(%esp)
  801ee2:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ee6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801eea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801eee:	89 c7                	mov    %eax,%edi
  801ef0:	89 f2                	mov    %esi,%edx
  801ef2:	85 ed                	test   %ebp,%ebp
  801ef4:	75 16                	jne    801f0c <__umoddi3+0x3c>
  801ef6:	39 f1                	cmp    %esi,%ecx
  801ef8:	0f 86 a6 00 00 00    	jbe    801fa4 <__umoddi3+0xd4>
  801efe:	f7 f1                	div    %ecx
  801f00:	89 d0                	mov    %edx,%eax
  801f02:	31 d2                	xor    %edx,%edx
  801f04:	83 c4 20             	add    $0x20,%esp
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
  801f0b:	90                   	nop
  801f0c:	39 f5                	cmp    %esi,%ebp
  801f0e:	0f 87 ac 00 00 00    	ja     801fc0 <__umoddi3+0xf0>
  801f14:	0f bd c5             	bsr    %ebp,%eax
  801f17:	83 f0 1f             	xor    $0x1f,%eax
  801f1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f1e:	0f 84 a8 00 00 00    	je     801fcc <__umoddi3+0xfc>
  801f24:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f28:	d3 e5                	shl    %cl,%ebp
  801f2a:	bf 20 00 00 00       	mov    $0x20,%edi
  801f2f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801f33:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f37:	89 f9                	mov    %edi,%ecx
  801f39:	d3 e8                	shr    %cl,%eax
  801f3b:	09 e8                	or     %ebp,%eax
  801f3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f45:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f49:	d3 e0                	shl    %cl,%eax
  801f4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4f:	89 f2                	mov    %esi,%edx
  801f51:	d3 e2                	shl    %cl,%edx
  801f53:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f57:	d3 e0                	shl    %cl,%eax
  801f59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801f5d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e8                	shr    %cl,%eax
  801f65:	09 d0                	or     %edx,%eax
  801f67:	d3 ee                	shr    %cl,%esi
  801f69:	89 f2                	mov    %esi,%edx
  801f6b:	f7 74 24 18          	divl   0x18(%esp)
  801f6f:	89 d6                	mov    %edx,%esi
  801f71:	f7 64 24 0c          	mull   0xc(%esp)
  801f75:	89 c5                	mov    %eax,%ebp
  801f77:	89 d1                	mov    %edx,%ecx
  801f79:	39 d6                	cmp    %edx,%esi
  801f7b:	72 67                	jb     801fe4 <__umoddi3+0x114>
  801f7d:	74 75                	je     801ff4 <__umoddi3+0x124>
  801f7f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f83:	29 e8                	sub    %ebp,%eax
  801f85:	19 ce                	sbb    %ecx,%esi
  801f87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f8b:	d3 e8                	shr    %cl,%eax
  801f8d:	89 f2                	mov    %esi,%edx
  801f8f:	89 f9                	mov    %edi,%ecx
  801f91:	d3 e2                	shl    %cl,%edx
  801f93:	09 d0                	or     %edx,%eax
  801f95:	89 f2                	mov    %esi,%edx
  801f97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f9b:	d3 ea                	shr    %cl,%edx
  801f9d:	83 c4 20             	add    $0x20,%esp
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    
  801fa4:	85 c9                	test   %ecx,%ecx
  801fa6:	75 0b                	jne    801fb3 <__umoddi3+0xe3>
  801fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fad:	31 d2                	xor    %edx,%edx
  801faf:	f7 f1                	div    %ecx
  801fb1:	89 c1                	mov    %eax,%ecx
  801fb3:	89 f0                	mov    %esi,%eax
  801fb5:	31 d2                	xor    %edx,%edx
  801fb7:	f7 f1                	div    %ecx
  801fb9:	89 f8                	mov    %edi,%eax
  801fbb:	e9 3e ff ff ff       	jmp    801efe <__umoddi3+0x2e>
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	83 c4 20             	add    $0x20,%esp
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
  801fc9:	8d 76 00             	lea    0x0(%esi),%esi
  801fcc:	39 f5                	cmp    %esi,%ebp
  801fce:	72 04                	jb     801fd4 <__umoddi3+0x104>
  801fd0:	39 f9                	cmp    %edi,%ecx
  801fd2:	77 06                	ja     801fda <__umoddi3+0x10a>
  801fd4:	89 f2                	mov    %esi,%edx
  801fd6:	29 cf                	sub    %ecx,%edi
  801fd8:	19 ea                	sbb    %ebp,%edx
  801fda:	89 f8                	mov    %edi,%eax
  801fdc:	83 c4 20             	add    $0x20,%esp
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    
  801fe3:	90                   	nop
  801fe4:	89 d1                	mov    %edx,%ecx
  801fe6:	89 c5                	mov    %eax,%ebp
  801fe8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ff0:	eb 8d                	jmp    801f7f <__umoddi3+0xaf>
  801ff2:	66 90                	xchg   %ax,%ax
  801ff4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ff8:	72 ea                	jb     801fe4 <__umoddi3+0x114>
  801ffa:	89 f1                	mov    %esi,%ecx
  801ffc:	eb 81                	jmp    801f7f <__umoddi3+0xaf>
