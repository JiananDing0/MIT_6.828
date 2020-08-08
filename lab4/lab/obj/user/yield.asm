
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 40 10 80 00 	movl   $0x801040,(%esp)
  80004e:	e8 55 01 00 00       	call   8001a8 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 e9 0a 00 00       	call   800b46 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 60 10 80 00 	movl   $0x801060,(%esp)
  800074:	e8 2f 01 00 00       	call   8001a8 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	43                   	inc    %ebx
  80007a:	83 fb 05             	cmp    $0x5,%ebx
  80007d:	75 d9                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007f:	a1 04 20 80 00       	mov    0x802004,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  800092:	e8 11 01 00 00       	call   8001a8 <cprintf>
}
  800097:	83 c4 14             	add    $0x14,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000ae:	e8 74 0a 00 00       	call   800b27 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000bf:	c1 e0 07             	shl    $0x7,%eax
  8000c2:	29 d0                	sub    %edx,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 f6                	test   %esi,%esi
  8000d0:	7e 07                	jle    8000d9 <libmain+0x39>
		binaryname = argv[0];
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dd:	89 34 24             	mov    %esi,(%esp)
  8000e0:	e8 4f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e5:	e8 0a 00 00 00       	call   8000f4 <exit>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    
  8000f1:	00 00                	add    %al,(%eax)
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800101:	e8 cf 09 00 00       	call   800ad5 <sys_env_destroy>
}
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 14             	sub    $0x14,%esp
  80010f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800112:	8b 03                	mov    (%ebx),%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011b:	40                   	inc    %eax
  80011c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800123:	75 19                	jne    80013e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800125:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012c:	00 
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	89 04 24             	mov    %eax,(%esp)
  800133:	e8 60 09 00 00       	call   800a98 <sys_cputs>
		b->idx = 0;
  800138:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013e:	ff 43 04             	incl   0x4(%ebx)
}
  800141:	83 c4 14             	add    $0x14,%esp
  800144:	5b                   	pop    %ebx
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800150:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800157:	00 00 00 
	b.cnt = 0;
  80015a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800161:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800164:	8b 45 0c             	mov    0xc(%ebp),%eax
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	8b 45 08             	mov    0x8(%ebp),%eax
  80016e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 08 01 80 00 	movl   $0x800108,(%esp)
  800183:	e8 82 01 00 00       	call   80030a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800188:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 f8 08 00 00       	call   800a98 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 87 ff ff ff       	call   800147 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
	...

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 3c             	sub    $0x3c,%esp
  8001cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d0:	89 d7                	mov    %edx,%edi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001de:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	85 c0                	test   %eax,%eax
  8001e6:	75 08                	jne    8001f0 <printnum+0x2c>
  8001e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ee:	77 57                	ja     800247 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f4:	4b                   	dec    %ebx
  8001f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800200:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800204:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	e8 b2 0b 00 00       	call   800dd4 <__udivdi3>
  800222:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800226:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800231:	89 fa                	mov    %edi,%edx
  800233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800236:	e8 89 ff ff ff       	call   8001c4 <printnum>
  80023b:	eb 0f                	jmp    80024c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800241:	89 34 24             	mov    %esi,(%esp)
  800244:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	4b                   	dec    %ebx
  800248:	85 db                	test   %ebx,%ebx
  80024a:	7f f1                	jg     80023d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800250:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800254:	8b 45 10             	mov    0x10(%ebp),%eax
  800257:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800262:	00 
  800263:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	e8 7f 0c 00 00       	call   800ef4 <__umoddi3>
  800275:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800279:	0f be 80 b5 10 80 00 	movsbl 0x8010b5(%eax),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800286:	83 c4 3c             	add    $0x3c,%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800291:	83 fa 01             	cmp    $0x1,%edx
  800294:	7e 0e                	jle    8002a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	8b 52 04             	mov    0x4(%edx),%edx
  8002a2:	eb 22                	jmp    8002c6 <getuint+0x38>
	else if (lflag)
  8002a4:	85 d2                	test   %edx,%edx
  8002a6:	74 10                	je     8002b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b6:	eb 0e                	jmp    8002c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ce:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d6:	73 08                	jae    8002e0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002db:	88 0a                	mov    %cl,(%edx)
  8002dd:	42                   	inc    %edx
  8002de:	89 10                	mov    %edx,(%eax)
}
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 02 00 00 00       	call   80030a <vprintfmt>
	va_end(ap);
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 4c             	sub    $0x4c,%esp
  800313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800316:	8b 75 10             	mov    0x10(%ebp),%esi
  800319:	eb 12                	jmp    80032d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031b:	85 c0                	test   %eax,%eax
  80031d:	0f 84 8b 03 00 00    	je     8006ae <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032d:	0f b6 06             	movzbl (%esi),%eax
  800330:	46                   	inc    %esi
  800331:	83 f8 25             	cmp    $0x25,%eax
  800334:	75 e5                	jne    80031b <vprintfmt+0x11>
  800336:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80033a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800341:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800346:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	eb 26                	jmp    80037a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800357:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80035b:	eb 1d                	jmp    80037a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800364:	eb 14                	jmp    80037a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800369:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800370:	eb 08                	jmp    80037a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800372:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800375:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	0f b6 06             	movzbl (%esi),%eax
  80037d:	8d 56 01             	lea    0x1(%esi),%edx
  800380:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800383:	8a 16                	mov    (%esi),%dl
  800385:	83 ea 23             	sub    $0x23,%edx
  800388:	80 fa 55             	cmp    $0x55,%dl
  80038b:	0f 87 01 03 00 00    	ja     800692 <vprintfmt+0x388>
  800391:	0f b6 d2             	movzbl %dl,%edx
  800394:	ff 24 95 80 11 80 00 	jmp    *0x801180(,%edx,4)
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80039e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003a6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003aa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ad:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b0:	83 fa 09             	cmp    $0x9,%edx
  8003b3:	77 2a                	ja     8003df <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b6:	eb eb                	jmp    8003a3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 50 04             	lea    0x4(%eax),%edx
  8003be:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c6:	eb 17                	jmp    8003df <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cc:	78 98                	js     800366 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003d1:	eb a7                	jmp    80037a <vprintfmt+0x70>
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003dd:	eb 9b                	jmp    80037a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e3:	79 95                	jns    80037a <vprintfmt+0x70>
  8003e5:	eb 8b                	jmp    800372 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003eb:	eb 8d                	jmp    80037a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 23 ff ff ff       	jmp    80032d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	85 c0                	test   %eax,%eax
  800417:	79 02                	jns    80041b <vprintfmt+0x111>
  800419:	f7 d8                	neg    %eax
  80041b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 08             	cmp    $0x8,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x123>
  800422:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  800429:	85 c0                	test   %eax,%eax
  80042b:	75 23                	jne    800450 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80042d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800431:	c7 44 24 08 cd 10 80 	movl   $0x8010cd,0x8(%esp)
  800438:	00 
  800439:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 9a fe ff ff       	call   8002e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044b:	e9 dd fe ff ff       	jmp    80032d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800450:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800454:	c7 44 24 08 d6 10 80 	movl   $0x8010d6,0x8(%esp)
  80045b:	00 
  80045c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800460:	8b 55 08             	mov    0x8(%ebp),%edx
  800463:	89 14 24             	mov    %edx,(%esp)
  800466:	e8 77 fe ff ff       	call   8002e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046e:	e9 ba fe ff ff       	jmp    80032d <vprintfmt+0x23>
  800473:	89 f9                	mov    %edi,%ecx
  800475:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800478:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 30                	mov    (%eax),%esi
  800486:	85 f6                	test   %esi,%esi
  800488:	75 05                	jne    80048f <vprintfmt+0x185>
				p = "(null)";
  80048a:	be c6 10 80 00       	mov    $0x8010c6,%esi
			if (width > 0 && padc != '-')
  80048f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800493:	0f 8e 84 00 00 00    	jle    80051d <vprintfmt+0x213>
  800499:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80049d:	74 7e                	je     80051d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a3:	89 34 24             	mov    %esi,(%esp)
  8004a6:	e8 ab 02 00 00       	call   800756 <strnlen>
  8004ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ae:	29 c2                	sub    %eax,%edx
  8004b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004b3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004b7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004bd:	89 de                	mov    %ebx,%esi
  8004bf:	89 d3                	mov    %edx,%ebx
  8004c1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	eb 0b                	jmp    8004d0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c9:	89 3c 24             	mov    %edi,(%esp)
  8004cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	4b                   	dec    %ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f f1                	jg     8004c5 <vprintfmt+0x1bb>
  8004d4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004d7:	89 f3                	mov    %esi,%ebx
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	79 05                	jns    8004e8 <vprintfmt+0x1de>
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004eb:	29 c2                	sub    %eax,%edx
  8004ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f0:	eb 2b                	jmp    80051d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f6:	74 18                	je     800510 <vprintfmt+0x206>
  8004f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fb:	83 fa 5e             	cmp    $0x5e,%edx
  8004fe:	76 10                	jbe    800510 <vprintfmt+0x206>
					putch('?', putdat);
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050b:	ff 55 08             	call   *0x8(%ebp)
  80050e:	eb 0a                	jmp    80051a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	ff 4d e4             	decl   -0x1c(%ebp)
  80051d:	0f be 06             	movsbl (%esi),%eax
  800520:	46                   	inc    %esi
  800521:	85 c0                	test   %eax,%eax
  800523:	74 21                	je     800546 <vprintfmt+0x23c>
  800525:	85 ff                	test   %edi,%edi
  800527:	78 c9                	js     8004f2 <vprintfmt+0x1e8>
  800529:	4f                   	dec    %edi
  80052a:	79 c6                	jns    8004f2 <vprintfmt+0x1e8>
  80052c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80052f:	89 de                	mov    %ebx,%esi
  800531:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800534:	eb 18                	jmp    80054e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800541:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800543:	4b                   	dec    %ebx
  800544:	eb 08                	jmp    80054e <vprintfmt+0x244>
  800546:	8b 7d 08             	mov    0x8(%ebp),%edi
  800549:	89 de                	mov    %ebx,%esi
  80054b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054e:	85 db                	test   %ebx,%ebx
  800550:	7f e4                	jg     800536 <vprintfmt+0x22c>
  800552:	89 7d 08             	mov    %edi,0x8(%ebp)
  800555:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80055a:	e9 ce fd ff ff       	jmp    80032d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055f:	83 f9 01             	cmp    $0x1,%ecx
  800562:	7e 10                	jle    800574 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 08             	lea    0x8(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 30                	mov    (%eax),%esi
  80056f:	8b 78 04             	mov    0x4(%eax),%edi
  800572:	eb 26                	jmp    80059a <vprintfmt+0x290>
	else if (lflag)
  800574:	85 c9                	test   %ecx,%ecx
  800576:	74 12                	je     80058a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 04             	lea    0x4(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	8b 30                	mov    (%eax),%esi
  800583:	89 f7                	mov    %esi,%edi
  800585:	c1 ff 1f             	sar    $0x1f,%edi
  800588:	eb 10                	jmp    80059a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 30                	mov    (%eax),%esi
  800595:	89 f7                	mov    %esi,%edi
  800597:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059a:	85 ff                	test   %edi,%edi
  80059c:	78 0a                	js     8005a8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 ac 00 00 00       	jmp    800654 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b6:	f7 de                	neg    %esi
  8005b8:	83 d7 00             	adc    $0x0,%edi
  8005bb:	f7 df                	neg    %edi
			}
			base = 10;
  8005bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c2:	e9 8d 00 00 00       	jmp    800654 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c7:	89 ca                	mov    %ecx,%edx
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 bd fc ff ff       	call   80028e <getuint>
  8005d1:	89 c6                	mov    %eax,%esi
  8005d3:	89 d7                	mov    %edx,%edi
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005da:	eb 78                	jmp    800654 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ee:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005f5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800609:	e9 1f fd ff ff       	jmp    80032d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80060e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800612:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800619:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800633:	8b 30                	mov    (%eax),%esi
  800635:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063f:	eb 13                	jmp    800654 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800641:	89 ca                	mov    %ecx,%edx
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 43 fc ff ff       	call   80028e <getuint>
  80064b:	89 c6                	mov    %eax,%esi
  80064d:	89 d7                	mov    %edx,%edi
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800654:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800658:	89 54 24 10          	mov    %edx,0x10(%esp)
  80065c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800663:	89 44 24 08          	mov    %eax,0x8(%esp)
  800667:	89 34 24             	mov    %esi,(%esp)
  80066a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066e:	89 da                	mov    %ebx,%edx
  800670:	8b 45 08             	mov    0x8(%ebp),%eax
  800673:	e8 4c fb ff ff       	call   8001c4 <printnum>
			break;
  800678:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067b:	e9 ad fc ff ff       	jmp    80032d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068d:	e9 9b fc ff ff       	jmp    80032d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a0:	eb 01                	jmp    8006a3 <vprintfmt+0x399>
  8006a2:	4e                   	dec    %esi
  8006a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006a7:	75 f9                	jne    8006a2 <vprintfmt+0x398>
  8006a9:	e9 7f fc ff ff       	jmp    80032d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ae:	83 c4 4c             	add    $0x4c,%esp
  8006b1:	5b                   	pop    %ebx
  8006b2:	5e                   	pop    %esi
  8006b3:	5f                   	pop    %edi
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 28             	sub    $0x28,%esp
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 30                	je     800707 <vsnprintf+0x51>
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	7e 33                	jle    80070e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f0:	c7 04 24 c8 02 80 00 	movl   $0x8002c8,(%esp)
  8006f7:	e8 0e fc ff ff       	call   80030a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	eb 0c                	jmp    800713 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070c:	eb 05                	jmp    800713 <vsnprintf+0x5d>
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800722:	8b 45 10             	mov    0x10(%ebp),%eax
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	e8 7b ff ff ff       	call   8006b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    
  80073d:	00 00                	add    %al,(%eax)
	...

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 01                	jmp    80074e <strlen+0xe>
		n++;
  80074d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f9                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	eb 01                	jmp    800767 <strnlen+0x11>
		n++;
  800766:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 d0                	cmp    %edx,%eax
  800769:	74 06                	je     800771 <strnlen+0x1b>
  80076b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076f:	75 f5                	jne    800766 <strnlen+0x10>
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
  800782:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800785:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800788:	42                   	inc    %edx
  800789:	84 c9                	test   %cl,%cl
  80078b:	75 f5                	jne    800782 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80078d:	5b                   	pop    %ebx
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	89 1c 24             	mov    %ebx,(%esp)
  80079d:	e8 9e ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	89 04 24             	mov    %eax,(%esp)
  8007ae:	e8 c0 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	83 c4 08             	add    $0x8,%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ce:	eb 0c                	jmp    8007dc <strncpy+0x21>
		*dst++ = *src;
  8007d0:	8a 1a                	mov    (%edx),%bl
  8007d2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	41                   	inc    %ecx
  8007dc:	39 f1                	cmp    %esi,%ecx
  8007de:	75 f0                	jne    8007d0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	75 0a                	jne    800800 <strlcpy+0x1c>
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	eb 1a                	jmp    800814 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fa:	88 18                	mov    %bl,(%eax)
  8007fc:	40                   	inc    %eax
  8007fd:	41                   	inc    %ecx
  8007fe:	eb 02                	jmp    800802 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800800:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800802:	4a                   	dec    %edx
  800803:	74 0a                	je     80080f <strlcpy+0x2b>
  800805:	8a 19                	mov    (%ecx),%bl
  800807:	84 db                	test   %bl,%bl
  800809:	75 ef                	jne    8007fa <strlcpy+0x16>
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	eb 02                	jmp    800811 <strlcpy+0x2d>
  80080f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800811:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800814:	29 f0                	sub    %esi,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800823:	eb 02                	jmp    800827 <strcmp+0xd>
		p++, q++;
  800825:	41                   	inc    %ecx
  800826:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800827:	8a 01                	mov    (%ecx),%al
  800829:	84 c0                	test   %al,%al
  80082b:	74 04                	je     800831 <strcmp+0x17>
  80082d:	3a 02                	cmp    (%edx),%al
  80082f:	74 f4                	je     800825 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800831:	0f b6 c0             	movzbl %al,%eax
  800834:	0f b6 12             	movzbl (%edx),%edx
  800837:	29 d0                	sub    %edx,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800848:	eb 03                	jmp    80084d <strncmp+0x12>
		n--, p++, q++;
  80084a:	4a                   	dec    %edx
  80084b:	40                   	inc    %eax
  80084c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084d:	85 d2                	test   %edx,%edx
  80084f:	74 14                	je     800865 <strncmp+0x2a>
  800851:	8a 18                	mov    (%eax),%bl
  800853:	84 db                	test   %bl,%bl
  800855:	74 04                	je     80085b <strncmp+0x20>
  800857:	3a 19                	cmp    (%ecx),%bl
  800859:	74 ef                	je     80084a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085b:	0f b6 00             	movzbl (%eax),%eax
  80085e:	0f b6 11             	movzbl (%ecx),%edx
  800861:	29 d0                	sub    %edx,%eax
  800863:	eb 05                	jmp    80086a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80086a:	5b                   	pop    %ebx
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800876:	eb 05                	jmp    80087d <strchr+0x10>
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 0c                	je     800888 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80087c:	40                   	inc    %eax
  80087d:	8a 10                	mov    (%eax),%dl
  80087f:	84 d2                	test   %dl,%dl
  800881:	75 f5                	jne    800878 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800893:	eb 05                	jmp    80089a <strfind+0x10>
		if (*s == c)
  800895:	38 ca                	cmp    %cl,%dl
  800897:	74 07                	je     8008a0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800899:	40                   	inc    %eax
  80089a:	8a 10                	mov    (%eax),%dl
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f5                	jne    800895 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	74 30                	je     8008e5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bb:	75 25                	jne    8008e2 <memset+0x40>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	75 20                	jne    8008e2 <memset+0x40>
		c &= 0xFF;
  8008c2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c5:	89 d3                	mov    %edx,%ebx
  8008c7:	c1 e3 08             	shl    $0x8,%ebx
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	c1 e6 18             	shl    $0x18,%esi
  8008cf:	89 d0                	mov    %edx,%eax
  8008d1:	c1 e0 10             	shl    $0x10,%eax
  8008d4:	09 f0                	or     %esi,%eax
  8008d6:	09 d0                	or     %edx,%eax
  8008d8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008da:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008dd:	fc                   	cld    
  8008de:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e0:	eb 03                	jmp    8008e5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e2:	fc                   	cld    
  8008e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e5:	89 f8                	mov    %edi,%eax
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5f                   	pop    %edi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	57                   	push   %edi
  8008f0:	56                   	push   %esi
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fa:	39 c6                	cmp    %eax,%esi
  8008fc:	73 34                	jae    800932 <memmove+0x46>
  8008fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800901:	39 d0                	cmp    %edx,%eax
  800903:	73 2d                	jae    800932 <memmove+0x46>
		s += n;
		d += n;
  800905:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800908:	f6 c2 03             	test   $0x3,%dl
  80090b:	75 1b                	jne    800928 <memmove+0x3c>
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 13                	jne    800928 <memmove+0x3c>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 0e                	jne    800928 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091a:	83 ef 04             	sub    $0x4,%edi
  80091d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800920:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800923:	fd                   	std    
  800924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800926:	eb 07                	jmp    80092f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800928:	4f                   	dec    %edi
  800929:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092c:	fd                   	std    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092f:	fc                   	cld    
  800930:	eb 20                	jmp    800952 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800932:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800938:	75 13                	jne    80094d <memmove+0x61>
  80093a:	a8 03                	test   $0x3,%al
  80093c:	75 0f                	jne    80094d <memmove+0x61>
  80093e:	f6 c1 03             	test   $0x3,%cl
  800941:	75 0a                	jne    80094d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800943:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800946:	89 c7                	mov    %eax,%edi
  800948:	fc                   	cld    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 05                	jmp    800952 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	fc                   	cld    
  800950:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800952:	5e                   	pop    %esi
  800953:	5f                   	pop    %edi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80095c:	8b 45 10             	mov    0x10(%ebp),%eax
  80095f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800963:	8b 45 0c             	mov    0xc(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	e8 77 ff ff ff       	call   8008ec <memmove>
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
  800983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	eb 16                	jmp    8009a3 <memcmp+0x2c>
		if (*s1 != *s2)
  80098d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800990:	42                   	inc    %edx
  800991:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800995:	38 c8                	cmp    %cl,%al
  800997:	74 0a                	je     8009a3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800999:	0f b6 c0             	movzbl %al,%eax
  80099c:	0f b6 c9             	movzbl %cl,%ecx
  80099f:	29 c8                	sub    %ecx,%eax
  8009a1:	eb 09                	jmp    8009ac <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a3:	39 da                	cmp    %ebx,%edx
  8009a5:	75 e6                	jne    80098d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ba:	89 c2                	mov    %eax,%edx
  8009bc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009bf:	eb 05                	jmp    8009c6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c1:	38 08                	cmp    %cl,(%eax)
  8009c3:	74 05                	je     8009ca <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c5:	40                   	inc    %eax
  8009c6:	39 d0                	cmp    %edx,%eax
  8009c8:	72 f7                	jb     8009c1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d8:	eb 01                	jmp    8009db <strtol+0xf>
		s++;
  8009da:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009db:	8a 02                	mov    (%edx),%al
  8009dd:	3c 20                	cmp    $0x20,%al
  8009df:	74 f9                	je     8009da <strtol+0xe>
  8009e1:	3c 09                	cmp    $0x9,%al
  8009e3:	74 f5                	je     8009da <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e5:	3c 2b                	cmp    $0x2b,%al
  8009e7:	75 08                	jne    8009f1 <strtol+0x25>
		s++;
  8009e9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ef:	eb 13                	jmp    800a04 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f1:	3c 2d                	cmp    $0x2d,%al
  8009f3:	75 0a                	jne    8009ff <strtol+0x33>
		s++, neg = 1;
  8009f5:	8d 52 01             	lea    0x1(%edx),%edx
  8009f8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009fd:	eb 05                	jmp    800a04 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a04:	85 db                	test   %ebx,%ebx
  800a06:	74 05                	je     800a0d <strtol+0x41>
  800a08:	83 fb 10             	cmp    $0x10,%ebx
  800a0b:	75 28                	jne    800a35 <strtol+0x69>
  800a0d:	8a 02                	mov    (%edx),%al
  800a0f:	3c 30                	cmp    $0x30,%al
  800a11:	75 10                	jne    800a23 <strtol+0x57>
  800a13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a17:	75 0a                	jne    800a23 <strtol+0x57>
		s += 2, base = 16;
  800a19:	83 c2 02             	add    $0x2,%edx
  800a1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a21:	eb 12                	jmp    800a35 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a23:	85 db                	test   %ebx,%ebx
  800a25:	75 0e                	jne    800a35 <strtol+0x69>
  800a27:	3c 30                	cmp    $0x30,%al
  800a29:	75 05                	jne    800a30 <strtol+0x64>
		s++, base = 8;
  800a2b:	42                   	inc    %edx
  800a2c:	b3 08                	mov    $0x8,%bl
  800a2e:	eb 05                	jmp    800a35 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a30:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3c:	8a 0a                	mov    (%edx),%cl
  800a3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a41:	80 fb 09             	cmp    $0x9,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x82>
			dig = *s - '0';
  800a46:	0f be c9             	movsbl %cl,%ecx
  800a49:	83 e9 30             	sub    $0x30,%ecx
  800a4c:	eb 1e                	jmp    800a6c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 08                	ja     800a5e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 57             	sub    $0x57,%ecx
  800a5c:	eb 0e                	jmp    800a6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a61:	80 fb 19             	cmp    $0x19,%bl
  800a64:	77 12                	ja     800a78 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a66:	0f be c9             	movsbl %cl,%ecx
  800a69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a6c:	39 f1                	cmp    %esi,%ecx
  800a6e:	7d 0c                	jge    800a7c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a70:	42                   	inc    %edx
  800a71:	0f af c6             	imul   %esi,%eax
  800a74:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a76:	eb c4                	jmp    800a3c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a78:	89 c1                	mov    %eax,%ecx
  800a7a:	eb 02                	jmp    800a7e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a82:	74 05                	je     800a89 <strtol+0xbd>
		*endptr = (char *) s;
  800a84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a87:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a89:	85 ff                	test   %edi,%edi
  800a8b:	74 04                	je     800a91 <strtol+0xc5>
  800a8d:	89 c8                	mov    %ecx,%eax
  800a8f:	f7 d8                	neg    %eax
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    
	...

00800a98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	89 c6                	mov    %eax,%esi
  800aaf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac6:	89 d1                	mov    %edx,%ecx
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	89 d7                	mov    %edx,%edi
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	89 cb                	mov    %ecx,%ebx
  800aed:	89 cf                	mov    %ecx,%edi
  800aef:	89 ce                	mov    %ecx,%esi
  800af1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 28                	jle    800b1f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800afb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b02:	00 
  800b03:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800b0a:	00 
  800b0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b12:	00 
  800b13:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800b1a:	e8 5d 02 00 00       	call   800d7c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1f:	83 c4 2c             	add    $0x2c,%esp
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 02 00 00 00       	mov    $0x2,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_yield>:

void
sys_yield(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	be 00 00 00 00       	mov    $0x0,%esi
  800b73:	b8 04 00 00 00       	mov    $0x4,%eax
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	89 f7                	mov    %esi,%edi
  800b83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7e 28                	jle    800bb1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b94:	00 
  800b95:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800b9c:	00 
  800b9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba4:	00 
  800ba5:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800bac:	e8 cb 01 00 00       	call   800d7c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	83 c4 2c             	add    $0x2c,%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 28                	jle    800c04 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800be7:	00 
  800be8:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800bef:	00 
  800bf0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf7:	00 
  800bf8:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800bff:	e8 78 01 00 00       	call   800d7c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c04:	83 c4 2c             	add    $0x2c,%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 df                	mov    %ebx,%edi
  800c27:	89 de                	mov    %ebx,%esi
  800c29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	7e 28                	jle    800c57 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c33:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800c42:	00 
  800c43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4a:	00 
  800c4b:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800c52:	e8 25 01 00 00       	call   800d7c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c57:	83 c4 2c             	add    $0x2c,%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 df                	mov    %ebx,%edi
  800c7a:	89 de                	mov    %ebx,%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 28                	jle    800caa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c86:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800c95:	00 
  800c96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9d:	00 
  800c9e:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800ca5:	e8 d2 00 00 00       	call   800d7c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caa:	83 c4 2c             	add    $0x2c,%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 28                	jle    800cfd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf0:	00 
  800cf1:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800cf8:	e8 7f 00 00 00       	call   800d7c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfd:	83 c4 2c             	add    $0x2c,%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	be 00 00 00 00       	mov    $0x0,%esi
  800d10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 cb                	mov    %ecx,%ebx
  800d40:	89 cf                	mov    %ecx,%edi
  800d42:	89 ce                	mov    %ecx,%esi
  800d44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 28                	jle    800d72 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d55:	00 
  800d56:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800d5d:	00 
  800d5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d65:	00 
  800d66:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800d6d:	e8 0a 00 00 00       	call   800d7c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d72:	83 c4 2c             	add    $0x2c,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
	...

00800d7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d84:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d87:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d8d:	e8 95 fd ff ff       	call   800b27 <sys_getenvid>
  800d92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d95:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da8:	c7 04 24 30 13 80 00 	movl   $0x801330,(%esp)
  800daf:	e8 f4 f3 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbb:	89 04 24             	mov    %eax,(%esp)
  800dbe:	e8 84 f3 ff ff       	call   800147 <vcprintf>
	cprintf("\n");
  800dc3:	c7 04 24 54 13 80 00 	movl   $0x801354,(%esp)
  800dca:	e8 d9 f3 ff ff       	call   8001a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dcf:	cc                   	int3   
  800dd0:	eb fd                	jmp    800dcf <_panic+0x53>
	...

00800dd4 <__udivdi3>:
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	83 ec 10             	sub    $0x10,%esp
  800dda:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dde:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800de2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800de6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dea:	89 cd                	mov    %ecx,%ebp
  800dec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800df0:	85 c0                	test   %eax,%eax
  800df2:	75 2c                	jne    800e20 <__udivdi3+0x4c>
  800df4:	39 f9                	cmp    %edi,%ecx
  800df6:	77 68                	ja     800e60 <__udivdi3+0x8c>
  800df8:	85 c9                	test   %ecx,%ecx
  800dfa:	75 0b                	jne    800e07 <__udivdi3+0x33>
  800dfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800e01:	31 d2                	xor    %edx,%edx
  800e03:	f7 f1                	div    %ecx
  800e05:	89 c1                	mov    %eax,%ecx
  800e07:	31 d2                	xor    %edx,%edx
  800e09:	89 f8                	mov    %edi,%eax
  800e0b:	f7 f1                	div    %ecx
  800e0d:	89 c7                	mov    %eax,%edi
  800e0f:	89 f0                	mov    %esi,%eax
  800e11:	f7 f1                	div    %ecx
  800e13:	89 c6                	mov    %eax,%esi
  800e15:	89 f0                	mov    %esi,%eax
  800e17:	89 fa                	mov    %edi,%edx
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    
  800e20:	39 f8                	cmp    %edi,%eax
  800e22:	77 2c                	ja     800e50 <__udivdi3+0x7c>
  800e24:	0f bd f0             	bsr    %eax,%esi
  800e27:	83 f6 1f             	xor    $0x1f,%esi
  800e2a:	75 4c                	jne    800e78 <__udivdi3+0xa4>
  800e2c:	39 f8                	cmp    %edi,%eax
  800e2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e33:	72 0a                	jb     800e3f <__udivdi3+0x6b>
  800e35:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e39:	0f 87 ad 00 00 00    	ja     800eec <__udivdi3+0x118>
  800e3f:	be 01 00 00 00       	mov    $0x1,%esi
  800e44:	89 f0                	mov    %esi,%eax
  800e46:	89 fa                	mov    %edi,%edx
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    
  800e4f:	90                   	nop
  800e50:	31 ff                	xor    %edi,%edi
  800e52:	31 f6                	xor    %esi,%esi
  800e54:	89 f0                	mov    %esi,%eax
  800e56:	89 fa                	mov    %edi,%edx
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    
  800e5f:	90                   	nop
  800e60:	89 fa                	mov    %edi,%edx
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	f7 f1                	div    %ecx
  800e66:	89 c6                	mov    %eax,%esi
  800e68:	31 ff                	xor    %edi,%edi
  800e6a:	89 f0                	mov    %esi,%eax
  800e6c:	89 fa                	mov    %edi,%edx
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	89 f1                	mov    %esi,%ecx
  800e7a:	d3 e0                	shl    %cl,%eax
  800e7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e80:	b8 20 00 00 00       	mov    $0x20,%eax
  800e85:	29 f0                	sub    %esi,%eax
  800e87:	89 ea                	mov    %ebp,%edx
  800e89:	88 c1                	mov    %al,%cl
  800e8b:	d3 ea                	shr    %cl,%edx
  800e8d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e91:	09 ca                	or     %ecx,%edx
  800e93:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e97:	89 f1                	mov    %esi,%ecx
  800e99:	d3 e5                	shl    %cl,%ebp
  800e9b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e9f:	89 fd                	mov    %edi,%ebp
  800ea1:	88 c1                	mov    %al,%cl
  800ea3:	d3 ed                	shr    %cl,%ebp
  800ea5:	89 fa                	mov    %edi,%edx
  800ea7:	89 f1                	mov    %esi,%ecx
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eaf:	88 c1                	mov    %al,%cl
  800eb1:	d3 ef                	shr    %cl,%edi
  800eb3:	09 d7                	or     %edx,%edi
  800eb5:	89 f8                	mov    %edi,%eax
  800eb7:	89 ea                	mov    %ebp,%edx
  800eb9:	f7 74 24 08          	divl   0x8(%esp)
  800ebd:	89 d1                	mov    %edx,%ecx
  800ebf:	89 c7                	mov    %eax,%edi
  800ec1:	f7 64 24 0c          	mull   0xc(%esp)
  800ec5:	39 d1                	cmp    %edx,%ecx
  800ec7:	72 17                	jb     800ee0 <__udivdi3+0x10c>
  800ec9:	74 09                	je     800ed4 <__udivdi3+0x100>
  800ecb:	89 fe                	mov    %edi,%esi
  800ecd:	31 ff                	xor    %edi,%edi
  800ecf:	e9 41 ff ff ff       	jmp    800e15 <__udivdi3+0x41>
  800ed4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ed8:	89 f1                	mov    %esi,%ecx
  800eda:	d3 e2                	shl    %cl,%edx
  800edc:	39 c2                	cmp    %eax,%edx
  800ede:	73 eb                	jae    800ecb <__udivdi3+0xf7>
  800ee0:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ee3:	31 ff                	xor    %edi,%edi
  800ee5:	e9 2b ff ff ff       	jmp    800e15 <__udivdi3+0x41>
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	31 f6                	xor    %esi,%esi
  800eee:	e9 22 ff ff ff       	jmp    800e15 <__udivdi3+0x41>
	...

00800ef4 <__umoddi3>:
  800ef4:	55                   	push   %ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	83 ec 20             	sub    $0x20,%esp
  800efa:	8b 44 24 30          	mov    0x30(%esp),%eax
  800efe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800f02:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f06:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f0a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f12:	89 c7                	mov    %eax,%edi
  800f14:	89 f2                	mov    %esi,%edx
  800f16:	85 ed                	test   %ebp,%ebp
  800f18:	75 16                	jne    800f30 <__umoddi3+0x3c>
  800f1a:	39 f1                	cmp    %esi,%ecx
  800f1c:	0f 86 a6 00 00 00    	jbe    800fc8 <__umoddi3+0xd4>
  800f22:	f7 f1                	div    %ecx
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	83 c4 20             	add    $0x20,%esp
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    
  800f2f:	90                   	nop
  800f30:	39 f5                	cmp    %esi,%ebp
  800f32:	0f 87 ac 00 00 00    	ja     800fe4 <__umoddi3+0xf0>
  800f38:	0f bd c5             	bsr    %ebp,%eax
  800f3b:	83 f0 1f             	xor    $0x1f,%eax
  800f3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f42:	0f 84 a8 00 00 00    	je     800ff0 <__umoddi3+0xfc>
  800f48:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4c:	d3 e5                	shl    %cl,%ebp
  800f4e:	bf 20 00 00 00       	mov    $0x20,%edi
  800f53:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f57:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f5b:	89 f9                	mov    %edi,%ecx
  800f5d:	d3 e8                	shr    %cl,%eax
  800f5f:	09 e8                	or     %ebp,%eax
  800f61:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f65:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f69:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f6d:	d3 e0                	shl    %cl,%eax
  800f6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	d3 e2                	shl    %cl,%edx
  800f77:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f7b:	d3 e0                	shl    %cl,%eax
  800f7d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f81:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f85:	89 f9                	mov    %edi,%ecx
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	09 d0                	or     %edx,%eax
  800f8b:	d3 ee                	shr    %cl,%esi
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	f7 74 24 18          	divl   0x18(%esp)
  800f93:	89 d6                	mov    %edx,%esi
  800f95:	f7 64 24 0c          	mull   0xc(%esp)
  800f99:	89 c5                	mov    %eax,%ebp
  800f9b:	89 d1                	mov    %edx,%ecx
  800f9d:	39 d6                	cmp    %edx,%esi
  800f9f:	72 67                	jb     801008 <__umoddi3+0x114>
  800fa1:	74 75                	je     801018 <__umoddi3+0x124>
  800fa3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fa7:	29 e8                	sub    %ebp,%eax
  800fa9:	19 ce                	sbb    %ecx,%esi
  800fab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800faf:	d3 e8                	shr    %cl,%eax
  800fb1:	89 f2                	mov    %esi,%edx
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	d3 e2                	shl    %cl,%edx
  800fb7:	09 d0                	or     %edx,%eax
  800fb9:	89 f2                	mov    %esi,%edx
  800fbb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fbf:	d3 ea                	shr    %cl,%edx
  800fc1:	83 c4 20             	add    $0x20,%esp
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    
  800fc8:	85 c9                	test   %ecx,%ecx
  800fca:	75 0b                	jne    800fd7 <__umoddi3+0xe3>
  800fcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	f7 f1                	div    %ecx
  800fd5:	89 c1                	mov    %eax,%ecx
  800fd7:	89 f0                	mov    %esi,%eax
  800fd9:	31 d2                	xor    %edx,%edx
  800fdb:	f7 f1                	div    %ecx
  800fdd:	89 f8                	mov    %edi,%eax
  800fdf:	e9 3e ff ff ff       	jmp    800f22 <__umoddi3+0x2e>
  800fe4:	89 f2                	mov    %esi,%edx
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	39 f5                	cmp    %esi,%ebp
  800ff2:	72 04                	jb     800ff8 <__umoddi3+0x104>
  800ff4:	39 f9                	cmp    %edi,%ecx
  800ff6:	77 06                	ja     800ffe <__umoddi3+0x10a>
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	29 cf                	sub    %ecx,%edi
  800ffc:	19 ea                	sbb    %ebp,%edx
  800ffe:	89 f8                	mov    %edi,%eax
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    
  801007:	90                   	nop
  801008:	89 d1                	mov    %edx,%ecx
  80100a:	89 c5                	mov    %eax,%ebp
  80100c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801010:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801014:	eb 8d                	jmp    800fa3 <__umoddi3+0xaf>
  801016:	66 90                	xchg   %ax,%ax
  801018:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80101c:	72 ea                	jb     801008 <__umoddi3+0x114>
  80101e:	89 f1                	mov    %esi,%ecx
  801020:	eb 81                	jmp    800fa3 <__umoddi3+0xaf>
