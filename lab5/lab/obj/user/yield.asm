
obj/user/yield.debug:     file format elf32-i386


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
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 60 1f 80 00 	movl   $0x801f60,(%esp)
  80004e:	e8 5d 01 00 00       	call   8001b0 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 f1 0a 00 00       	call   800b4e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  800074:	e8 37 01 00 00       	call   8001b0 <cprintf>
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
  80007f:	a1 04 40 80 00       	mov    0x804004,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  800092:	e8 19 01 00 00       	call   8001b0 <cprintf>
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
  8000ae:	e8 7c 0a 00 00       	call   800b2f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000bf:	c1 e0 07             	shl    $0x7,%eax
  8000c2:	29 d0                	sub    %edx,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 f6                	test   %esi,%esi
  8000d0:	7e 07                	jle    8000d9 <libmain+0x39>
		binaryname = argv[0];
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000fa:	e8 c0 0e 00 00       	call   800fbf <close_all>
	sys_env_destroy(0);
  8000ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800106:	e8 d2 09 00 00       	call   800add <sys_env_destroy>
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    
  80010d:	00 00                	add    %al,(%eax)
	...

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 14             	sub    $0x14,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800123:	40                   	inc    %eax
  800124:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 19                	jne    800146 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80012d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800134:	00 
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	89 04 24             	mov    %eax,(%esp)
  80013b:	e8 60 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800140:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800146:	ff 43 04             	incl   0x4(%ebx)
}
  800149:	83 c4 14             	add    $0x14,%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	c7 04 24 10 01 80 00 	movl   $0x800110,(%esp)
  80018b:	e8 82 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 f8 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 87 ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    
	...

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 3c             	sub    $0x3c,%esp
  8001d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d8:	89 d7                	mov    %edx,%edi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	75 08                	jne    8001f8 <printnum+0x2c>
  8001f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 57                	ja     80024f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001fc:	4b                   	dec    %ebx
  8001fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800201:	8b 45 10             	mov    0x10(%ebp),%eax
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80020c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800210:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800217:	00 
  800218:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021b:	89 04 24             	mov    %eax,(%esp)
  80021e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	e8 da 1a 00 00       	call   801d04 <__udivdi3>
  80022a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	89 54 24 04          	mov    %edx,0x4(%esp)
  800239:	89 fa                	mov    %edi,%edx
  80023b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023e:	e8 89 ff ff ff       	call   8001cc <printnum>
  800243:	eb 0f                	jmp    800254 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800245:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800249:	89 34 24             	mov    %esi,(%esp)
  80024c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	4b                   	dec    %ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f f1                	jg     800245 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80025c:	8b 45 10             	mov    0x10(%ebp),%eax
  80025f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800263:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026a:	00 
  80026b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	e8 a7 1b 00 00       	call   801e24 <__umoddi3>
  80027d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800281:	0f be 80 d5 1f 80 00 	movsbl 0x801fd5(%eax),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028e:	83 c4 3c             	add    $0x3c,%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800299:	83 fa 01             	cmp    $0x1,%edx
  80029c:	7e 0e                	jle    8002ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	8b 52 04             	mov    0x4(%edx),%edx
  8002aa:	eb 22                	jmp    8002ce <getuint+0x38>
	else if (lflag)
  8002ac:	85 d2                	test   %edx,%edx
  8002ae:	74 10                	je     8002c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 0e                	jmp    8002ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 08                	jae    8002e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	88 0a                	mov    %cl,(%edx)
  8002e5:	42                   	inc    %edx
  8002e6:	89 10                	mov    %edx,(%eax)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 02 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 4c             	sub    $0x4c,%esp
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031e:	8b 75 10             	mov    0x10(%ebp),%esi
  800321:	eb 12                	jmp    800335 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800323:	85 c0                	test   %eax,%eax
  800325:	0f 84 8b 03 00 00    	je     8006b6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80032b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800335:	0f b6 06             	movzbl (%esi),%eax
  800338:	46                   	inc    %esi
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e5                	jne    800323 <vprintfmt+0x11>
  80033e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800342:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800349:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80034e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	eb 26                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800363:	eb 1d                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80036c:	eb 14                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800371:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800378:	eb 08                	jmp    800382 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80037d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	0f b6 06             	movzbl (%esi),%eax
  800385:	8d 56 01             	lea    0x1(%esi),%edx
  800388:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80038b:	8a 16                	mov    (%esi),%dl
  80038d:	83 ea 23             	sub    $0x23,%edx
  800390:	80 fa 55             	cmp    $0x55,%dl
  800393:	0f 87 01 03 00 00    	ja     80069a <vprintfmt+0x388>
  800399:	0f b6 d2             	movzbl %dl,%edx
  80039c:	ff 24 95 20 21 80 00 	jmp    *0x802120(,%edx,4)
  8003a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b8:	83 fa 09             	cmp    $0x9,%edx
  8003bb:	77 2a                	ja     8003e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003be:	eb eb                	jmp    8003ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ce:	eb 17                	jmp    8003e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d4:	78 98                	js     80036e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003d9:	eb a7                	jmp    800382 <vprintfmt+0x70>
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003e5:	eb 9b                	jmp    800382 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	79 95                	jns    800382 <vprintfmt+0x70>
  8003ed:	eb 8b                	jmp    80037a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f3:	eb 8d                	jmp    800382 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040d:	e9 23 ff ff ff       	jmp    800335 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	79 02                	jns    800423 <vprintfmt+0x111>
  800421:	f7 d8                	neg    %eax
  800423:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800425:	83 f8 0f             	cmp    $0xf,%eax
  800428:	7f 0b                	jg     800435 <vprintfmt+0x123>
  80042a:	8b 04 85 80 22 80 00 	mov    0x802280(,%eax,4),%eax
  800431:	85 c0                	test   %eax,%eax
  800433:	75 23                	jne    800458 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800435:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800439:	c7 44 24 08 ed 1f 80 	movl   $0x801fed,0x8(%esp)
  800440:	00 
  800441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 9a fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800453:	e9 dd fe ff ff       	jmp    800335 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800458:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045c:	c7 44 24 08 da 23 80 	movl   $0x8023da,0x8(%esp)
  800463:	00 
  800464:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800468:	8b 55 08             	mov    0x8(%ebp),%edx
  80046b:	89 14 24             	mov    %edx,(%esp)
  80046e:	e8 77 fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800476:	e9 ba fe ff ff       	jmp    800335 <vprintfmt+0x23>
  80047b:	89 f9                	mov    %edi,%ecx
  80047d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800480:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 30                	mov    (%eax),%esi
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 05                	jne    800497 <vprintfmt+0x185>
				p = "(null)";
  800492:	be e6 1f 80 00       	mov    $0x801fe6,%esi
			if (width > 0 && padc != '-')
  800497:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049b:	0f 8e 84 00 00 00    	jle    800525 <vprintfmt+0x213>
  8004a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004a5:	74 7e                	je     800525 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ab:	89 34 24             	mov    %esi,(%esp)
  8004ae:	e8 ab 02 00 00       	call   80075e <strnlen>
  8004b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b6:	29 c2                	sub    %eax,%edx
  8004b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	89 d3                	mov    %edx,%ebx
  8004c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	eb 0b                	jmp    8004d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d1:	89 3c 24             	mov    %edi,(%esp)
  8004d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	4b                   	dec    %ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7f f1                	jg     8004cd <vprintfmt+0x1bb>
  8004dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004df:	89 f3                	mov    %esi,%ebx
  8004e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	79 05                	jns    8004f0 <vprintfmt+0x1de>
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f8:	eb 2b                	jmp    800525 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fe:	74 18                	je     800518 <vprintfmt+0x206>
  800500:	8d 50 e0             	lea    -0x20(%eax),%edx
  800503:	83 fa 5e             	cmp    $0x5e,%edx
  800506:	76 10                	jbe    800518 <vprintfmt+0x206>
					putch('?', putdat);
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
  800516:	eb 0a                	jmp    800522 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800522:	ff 4d e4             	decl   -0x1c(%ebp)
  800525:	0f be 06             	movsbl (%esi),%eax
  800528:	46                   	inc    %esi
  800529:	85 c0                	test   %eax,%eax
  80052b:	74 21                	je     80054e <vprintfmt+0x23c>
  80052d:	85 ff                	test   %edi,%edi
  80052f:	78 c9                	js     8004fa <vprintfmt+0x1e8>
  800531:	4f                   	dec    %edi
  800532:	79 c6                	jns    8004fa <vprintfmt+0x1e8>
  800534:	8b 7d 08             	mov    0x8(%ebp),%edi
  800537:	89 de                	mov    %ebx,%esi
  800539:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053c:	eb 18                	jmp    800556 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800542:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800549:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054b:	4b                   	dec    %ebx
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x244>
  80054e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800551:	89 de                	mov    %ebx,%esi
  800553:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800556:	85 db                	test   %ebx,%ebx
  800558:	7f e4                	jg     80053e <vprintfmt+0x22c>
  80055a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80055d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800562:	e9 ce fd ff ff       	jmp    800335 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 10                	jle    80057c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 08             	lea    0x8(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 30                	mov    (%eax),%esi
  800577:	8b 78 04             	mov    0x4(%eax),%edi
  80057a:	eb 26                	jmp    8005a2 <vprintfmt+0x290>
	else if (lflag)
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	74 12                	je     800592 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 30                	mov    (%eax),%esi
  80058b:	89 f7                	mov    %esi,%edi
  80058d:	c1 ff 1f             	sar    $0x1f,%edi
  800590:	eb 10                	jmp    8005a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 30                	mov    (%eax),%esi
  80059d:	89 f7                	mov    %esi,%edi
  80059f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a2:	85 ff                	test   %edi,%edi
  8005a4:	78 0a                	js     8005b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 ac 00 00 00       	jmp    80065c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005be:	f7 de                	neg    %esi
  8005c0:	83 d7 00             	adc    $0x0,%edi
  8005c3:	f7 df                	neg    %edi
			}
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	e9 8d 00 00 00       	jmp    80065c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cf:	89 ca                	mov    %ecx,%edx
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 bd fc ff ff       	call   800296 <getuint>
  8005d9:	89 c6                	mov    %eax,%esi
  8005db:	89 d7                	mov    %edx,%edi
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e2:	eb 78                	jmp    80065c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800611:	e9 1f fd ff ff       	jmp    800335 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800616:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800621:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063b:	8b 30                	mov    (%eax),%esi
  80063d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800642:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800647:	eb 13                	jmp    80065c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800649:	89 ca                	mov    %ecx,%edx
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 43 fc ff ff       	call   800296 <getuint>
  800653:	89 c6                	mov    %eax,%esi
  800655:	89 d7                	mov    %edx,%edi
			base = 16;
  800657:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800660:	89 54 24 10          	mov    %edx,0x10(%esp)
  800664:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800667:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066f:	89 34 24             	mov    %esi,(%esp)
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800676:	89 da                	mov    %ebx,%edx
  800678:	8b 45 08             	mov    0x8(%ebp),%eax
  80067b:	e8 4c fb ff ff       	call   8001cc <printnum>
			break;
  800680:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800683:	e9 ad fc ff ff       	jmp    800335 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800688:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800695:	e9 9b fc ff ff       	jmp    800335 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a8:	eb 01                	jmp    8006ab <vprintfmt+0x399>
  8006aa:	4e                   	dec    %esi
  8006ab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006af:	75 f9                	jne    8006aa <vprintfmt+0x398>
  8006b1:	e9 7f fc ff ff       	jmp    800335 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006b6:	83 c4 4c             	add    $0x4c,%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 28             	sub    $0x28,%esp
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	74 30                	je     80070f <vsnprintf+0x51>
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	7e 33                	jle    800716 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  8006ff:	e8 0e fc ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	eb 0c                	jmp    80071b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800714:	eb 05                	jmp    80071b <vsnprintf+0x5d>
  800716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    

0080071d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800726:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800731:	8b 45 0c             	mov    0xc(%ebp),%eax
  800734:	89 44 24 04          	mov    %eax,0x4(%esp)
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	e8 7b ff ff ff       	call   8006be <vsnprintf>
	va_end(ap);

	return rc;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    
  800745:	00 00                	add    %al,(%eax)
	...

00800748 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	eb 01                	jmp    800756 <strlen+0xe>
		n++;
  800755:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075a:	75 f9                	jne    800755 <strlen+0xd>
		n++;
	return n;
}
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 01                	jmp    80076f <strnlen+0x11>
		n++;
  80076e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	39 d0                	cmp    %edx,%eax
  800771:	74 06                	je     800779 <strnlen+0x1b>
  800773:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800777:	75 f5                	jne    80076e <strnlen+0x10>
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
  80078a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80078d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800790:	42                   	inc    %edx
  800791:	84 c9                	test   %cl,%cl
  800793:	75 f5                	jne    80078a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800795:	5b                   	pop    %ebx
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a2:	89 1c 24             	mov    %ebx,(%esp)
  8007a5:	e8 9e ff ff ff       	call   800748 <strlen>
	strcpy(dst + len, src);
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b1:	01 d8                	add    %ebx,%eax
  8007b3:	89 04 24             	mov    %eax,(%esp)
  8007b6:	e8 c0 ff ff ff       	call   80077b <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	83 c4 08             	add    $0x8,%esp
  8007c0:	5b                   	pop    %ebx
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	56                   	push   %esi
  8007c7:	53                   	push   %ebx
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	eb 0c                	jmp    8007e4 <strncpy+0x21>
		*dst++ = *src;
  8007d8:	8a 1a                	mov    (%edx),%bl
  8007da:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	41                   	inc    %ecx
  8007e4:	39 f1                	cmp    %esi,%ecx
  8007e6:	75 f0                	jne    8007d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	75 0a                	jne    800808 <strlcpy+0x1c>
  8007fe:	89 f0                	mov    %esi,%eax
  800800:	eb 1a                	jmp    80081c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	88 18                	mov    %bl,(%eax)
  800804:	40                   	inc    %eax
  800805:	41                   	inc    %ecx
  800806:	eb 02                	jmp    80080a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800808:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80080a:	4a                   	dec    %edx
  80080b:	74 0a                	je     800817 <strlcpy+0x2b>
  80080d:	8a 19                	mov    (%ecx),%bl
  80080f:	84 db                	test   %bl,%bl
  800811:	75 ef                	jne    800802 <strlcpy+0x16>
  800813:	89 c2                	mov    %eax,%edx
  800815:	eb 02                	jmp    800819 <strlcpy+0x2d>
  800817:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800819:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80081c:	29 f0                	sub    %esi,%eax
}
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082b:	eb 02                	jmp    80082f <strcmp+0xd>
		p++, q++;
  80082d:	41                   	inc    %ecx
  80082e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082f:	8a 01                	mov    (%ecx),%al
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x17>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 f4                	je     80082d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800850:	eb 03                	jmp    800855 <strncmp+0x12>
		n--, p++, q++;
  800852:	4a                   	dec    %edx
  800853:	40                   	inc    %eax
  800854:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <strncmp+0x2a>
  800859:	8a 18                	mov    (%eax),%bl
  80085b:	84 db                	test   %bl,%bl
  80085d:	74 04                	je     800863 <strncmp+0x20>
  80085f:	3a 19                	cmp    (%ecx),%bl
  800861:	74 ef                	je     800852 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 00             	movzbl (%eax),%eax
  800866:	0f b6 11             	movzbl (%ecx),%edx
  800869:	29 d0                	sub    %edx,%eax
  80086b:	eb 05                	jmp    800872 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087e:	eb 05                	jmp    800885 <strchr+0x10>
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 0c                	je     800890 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800884:	40                   	inc    %eax
  800885:	8a 10                	mov    (%eax),%dl
  800887:	84 d2                	test   %dl,%dl
  800889:	75 f5                	jne    800880 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089b:	eb 05                	jmp    8008a2 <strfind+0x10>
		if (*s == c)
  80089d:	38 ca                	cmp    %cl,%dl
  80089f:	74 07                	je     8008a8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a1:	40                   	inc    %eax
  8008a2:	8a 10                	mov    (%eax),%dl
  8008a4:	84 d2                	test   %dl,%dl
  8008a6:	75 f5                	jne    80089d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	57                   	push   %edi
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b9:	85 c9                	test   %ecx,%ecx
  8008bb:	74 30                	je     8008ed <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c3:	75 25                	jne    8008ea <memset+0x40>
  8008c5:	f6 c1 03             	test   $0x3,%cl
  8008c8:	75 20                	jne    8008ea <memset+0x40>
		c &= 0xFF;
  8008ca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cd:	89 d3                	mov    %edx,%ebx
  8008cf:	c1 e3 08             	shl    $0x8,%ebx
  8008d2:	89 d6                	mov    %edx,%esi
  8008d4:	c1 e6 18             	shl    $0x18,%esi
  8008d7:	89 d0                	mov    %edx,%eax
  8008d9:	c1 e0 10             	shl    $0x10,%eax
  8008dc:	09 f0                	or     %esi,%eax
  8008de:	09 d0                	or     %edx,%eax
  8008e0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e5:	fc                   	cld    
  8008e6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e8:	eb 03                	jmp    8008ed <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ea:	fc                   	cld    
  8008eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ed:	89 f8                	mov    %edi,%eax
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5f                   	pop    %edi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	57                   	push   %edi
  8008f8:	56                   	push   %esi
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800902:	39 c6                	cmp    %eax,%esi
  800904:	73 34                	jae    80093a <memmove+0x46>
  800906:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800909:	39 d0                	cmp    %edx,%eax
  80090b:	73 2d                	jae    80093a <memmove+0x46>
		s += n;
		d += n;
  80090d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800910:	f6 c2 03             	test   $0x3,%dl
  800913:	75 1b                	jne    800930 <memmove+0x3c>
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 13                	jne    800930 <memmove+0x3c>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 0e                	jne    800930 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800922:	83 ef 04             	sub    $0x4,%edi
  800925:	8d 72 fc             	lea    -0x4(%edx),%esi
  800928:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80092b:	fd                   	std    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 07                	jmp    800937 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800930:	4f                   	dec    %edi
  800931:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800934:	fd                   	std    
  800935:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800937:	fc                   	cld    
  800938:	eb 20                	jmp    80095a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800940:	75 13                	jne    800955 <memmove+0x61>
  800942:	a8 03                	test   $0x3,%al
  800944:	75 0f                	jne    800955 <memmove+0x61>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 0a                	jne    800955 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80094e:	89 c7                	mov    %eax,%edi
  800950:	fc                   	cld    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 05                	jmp    80095a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800955:	89 c7                	mov    %eax,%edi
  800957:	fc                   	cld    
  800958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800964:	8b 45 10             	mov    0x10(%ebp),%eax
  800967:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	e8 77 ff ff ff       	call   8008f4 <memmove>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 7d 08             	mov    0x8(%ebp),%edi
  800988:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	eb 16                	jmp    8009ab <memcmp+0x2c>
		if (*s1 != *s2)
  800995:	8a 04 17             	mov    (%edi,%edx,1),%al
  800998:	42                   	inc    %edx
  800999:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80099d:	38 c8                	cmp    %cl,%al
  80099f:	74 0a                	je     8009ab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009a1:	0f b6 c0             	movzbl %al,%eax
  8009a4:	0f b6 c9             	movzbl %cl,%ecx
  8009a7:	29 c8                	sub    %ecx,%eax
  8009a9:	eb 09                	jmp    8009b4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ab:	39 da                	cmp    %ebx,%edx
  8009ad:	75 e6                	jne    800995 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5f                   	pop    %edi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c2:	89 c2                	mov    %eax,%edx
  8009c4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c7:	eb 05                	jmp    8009ce <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	38 08                	cmp    %cl,(%eax)
  8009cb:	74 05                	je     8009d2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cd:	40                   	inc    %eax
  8009ce:	39 d0                	cmp    %edx,%eax
  8009d0:	72 f7                	jb     8009c9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 55 08             	mov    0x8(%ebp),%edx
  8009dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e0:	eb 01                	jmp    8009e3 <strtol+0xf>
		s++;
  8009e2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e3:	8a 02                	mov    (%edx),%al
  8009e5:	3c 20                	cmp    $0x20,%al
  8009e7:	74 f9                	je     8009e2 <strtol+0xe>
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	74 f5                	je     8009e2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ed:	3c 2b                	cmp    $0x2b,%al
  8009ef:	75 08                	jne    8009f9 <strtol+0x25>
		s++;
  8009f1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f7:	eb 13                	jmp    800a0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f9:	3c 2d                	cmp    $0x2d,%al
  8009fb:	75 0a                	jne    800a07 <strtol+0x33>
		s++, neg = 1;
  8009fd:	8d 52 01             	lea    0x1(%edx),%edx
  800a00:	bf 01 00 00 00       	mov    $0x1,%edi
  800a05:	eb 05                	jmp    800a0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0c:	85 db                	test   %ebx,%ebx
  800a0e:	74 05                	je     800a15 <strtol+0x41>
  800a10:	83 fb 10             	cmp    $0x10,%ebx
  800a13:	75 28                	jne    800a3d <strtol+0x69>
  800a15:	8a 02                	mov    (%edx),%al
  800a17:	3c 30                	cmp    $0x30,%al
  800a19:	75 10                	jne    800a2b <strtol+0x57>
  800a1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a1f:	75 0a                	jne    800a2b <strtol+0x57>
		s += 2, base = 16;
  800a21:	83 c2 02             	add    $0x2,%edx
  800a24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a29:	eb 12                	jmp    800a3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	75 0e                	jne    800a3d <strtol+0x69>
  800a2f:	3c 30                	cmp    $0x30,%al
  800a31:	75 05                	jne    800a38 <strtol+0x64>
		s++, base = 8;
  800a33:	42                   	inc    %edx
  800a34:	b3 08                	mov    $0x8,%bl
  800a36:	eb 05                	jmp    800a3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a44:	8a 0a                	mov    (%edx),%cl
  800a46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a49:	80 fb 09             	cmp    $0x9,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0x82>
			dig = *s - '0';
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 30             	sub    $0x30,%ecx
  800a54:	eb 1e                	jmp    800a74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 57             	sub    $0x57,%ecx
  800a64:	eb 0e                	jmp    800a74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a69:	80 fb 19             	cmp    $0x19,%bl
  800a6c:	77 12                	ja     800a80 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a6e:	0f be c9             	movsbl %cl,%ecx
  800a71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a74:	39 f1                	cmp    %esi,%ecx
  800a76:	7d 0c                	jge    800a84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a78:	42                   	inc    %edx
  800a79:	0f af c6             	imul   %esi,%eax
  800a7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a7e:	eb c4                	jmp    800a44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	89 c1                	mov    %eax,%ecx
  800a82:	eb 02                	jmp    800a86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8a:	74 05                	je     800a91 <strtol+0xbd>
		*endptr = (char *) s;
  800a8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a91:	85 ff                	test   %edi,%edi
  800a93:	74 04                	je     800a99 <strtol+0xc5>
  800a95:	89 c8                	mov    %ecx,%eax
  800a97:	f7 d8                	neg    %eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    
	...

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 28                	jle    800b27 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b0a:	00 
  800b0b:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800b12:	00 
  800b13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b1a:	00 
  800b1b:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800b22:	e8 29 10 00 00       	call   801b50 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b27:	83 c4 2c             	add    $0x2c,%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_yield>:

void
sys_yield(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	be 00 00 00 00       	mov    $0x0,%esi
  800b7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 f7                	mov    %esi,%edi
  800b8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7e 28                	jle    800bb9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b9c:	00 
  800b9d:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800ba4:	00 
  800ba5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bac:	00 
  800bad:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800bb4:	e8 97 0f 00 00       	call   801b50 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb9:	83 c4 2c             	add    $0x2c,%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 28                	jle    800c0c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bef:	00 
  800bf0:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800bf7:	00 
  800bf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bff:	00 
  800c00:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c07:	e8 44 0f 00 00       	call   801b50 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0c:	83 c4 2c             	add    $0x2c,%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 06 00 00 00       	mov    $0x6,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 28                	jle    800c5f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c42:	00 
  800c43:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c52:	00 
  800c53:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c5a:	e8 f1 0e 00 00       	call   801b50 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5f:	83 c4 2c             	add    $0x2c,%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 28                	jle    800cb2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c95:	00 
  800c96:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca5:	00 
  800ca6:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800cad:	e8 9e 0e 00 00       	call   801b50 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb2:	83 c4 2c             	add    $0x2c,%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 df                	mov    %ebx,%edi
  800cd5:	89 de                	mov    %ebx,%esi
  800cd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 28                	jle    800d05 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf8:	00 
  800cf9:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800d00:	e8 4b 0e 00 00       	call   801b50 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d05:	83 c4 2c             	add    $0x2c,%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 28                	jle    800d58 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d34:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d3b:	00 
  800d3c:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800d43:	00 
  800d44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4b:	00 
  800d4c:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800d53:	e8 f8 0d 00 00       	call   801b50 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d58:	83 c4 2c             	add    $0x2c,%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	be 00 00 00 00       	mov    $0x0,%esi
  800d6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 cb                	mov    %ecx,%ebx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	89 ce                	mov    %ecx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 28                	jle    800dcd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800db0:	00 
  800db1:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800db8:	00 
  800db9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc0:	00 
  800dc1:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800dc8:	e8 83 0d 00 00       	call   801b50 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dcd:	83 c4 2c             	add    $0x2c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	00 00                	add    %al,(%eax)
	...

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	05 00 00 00 30       	add    $0x30000000,%eax
  800de3:	c1 e8 0c             	shr    $0xc,%eax
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 df ff ff ff       	call   800dd8 <fd2num>
  800df9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dfe:	c1 e0 0c             	shl    $0xc,%eax
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	53                   	push   %ebx
  800e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e0f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	c1 ea 16             	shr    $0x16,%edx
  800e16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1d:	f6 c2 01             	test   $0x1,%dl
  800e20:	74 11                	je     800e33 <fd_alloc+0x30>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	c1 ea 0c             	shr    $0xc,%edx
  800e27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2e:	f6 c2 01             	test   $0x1,%dl
  800e31:	75 09                	jne    800e3c <fd_alloc+0x39>
			*fd_store = fd;
  800e33:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3a:	eb 17                	jmp    800e53 <fd_alloc+0x50>
  800e3c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e41:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e46:	75 c7                	jne    800e0f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e53:	5b                   	pop    %ebx
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5c:	83 f8 1f             	cmp    $0x1f,%eax
  800e5f:	77 36                	ja     800e97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e61:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e66:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 16             	shr    $0x16,%edx
  800e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	74 24                	je     800e9e <fd_lookup+0x48>
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 0c             	shr    $0xc,%edx
  800e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	74 1a                	je     800ea5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	eb 13                	jmp    800eaa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9c:	eb 0c                	jmp    800eaa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea3:	eb 05                	jmp    800eaa <fd_lookup+0x54>
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 14             	sub    $0x14,%esp
  800eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	eb 0e                	jmp    800ece <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ec0:	39 08                	cmp    %ecx,(%eax)
  800ec2:	75 09                	jne    800ecd <dev_lookup+0x21>
			*dev = devtab[i];
  800ec4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	eb 33                	jmp    800f00 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ecd:	42                   	inc    %edx
  800ece:	8b 04 95 88 23 80 00 	mov    0x802388(,%edx,4),%eax
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	75 e7                	jne    800ec0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ede:	8b 40 48             	mov    0x48(%eax),%eax
  800ee1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee9:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  800ef0:	e8 bb f2 ff ff       	call   8001b0 <cprintf>
	*dev = 0;
  800ef5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f00:	83 c4 14             	add    $0x14,%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 30             	sub    $0x30,%esp
  800f0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f11:	8a 45 0c             	mov    0xc(%ebp),%al
  800f14:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f17:	89 34 24             	mov    %esi,(%esp)
  800f1a:	e8 b9 fe ff ff       	call   800dd8 <fd2num>
  800f1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f22:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f26:	89 04 24             	mov    %eax,(%esp)
  800f29:	e8 28 ff ff ff       	call   800e56 <fd_lookup>
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 05                	js     800f39 <fd_close+0x33>
	    || fd != fd2)
  800f34:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f37:	74 0d                	je     800f46 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f39:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f3d:	75 46                	jne    800f85 <fd_close+0x7f>
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f44:	eb 3f                	jmp    800f85 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4d:	8b 06                	mov    (%esi),%eax
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 55 ff ff ff       	call   800eac <dev_lookup>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 18                	js     800f75 <fd_close+0x6f>
		if (dev->dev_close)
  800f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f60:	8b 40 10             	mov    0x10(%eax),%eax
  800f63:	85 c0                	test   %eax,%eax
  800f65:	74 09                	je     800f70 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f67:	89 34 24             	mov    %esi,(%esp)
  800f6a:	ff d0                	call   *%eax
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	eb 05                	jmp    800f75 <fd_close+0x6f>
		else
			r = 0;
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f80:	e8 8f fc ff ff       	call   800c14 <sys_page_unmap>
	return r;
}
  800f85:	89 d8                	mov    %ebx,%eax
  800f87:	83 c4 30             	add    $0x30,%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	89 04 24             	mov    %eax,(%esp)
  800fa1:	e8 b0 fe ff ff       	call   800e56 <fd_lookup>
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 13                	js     800fbd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800faa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb1:	00 
  800fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 49 ff ff ff       	call   800f06 <fd_close>
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <close_all>:

void
close_all(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fcb:	89 1c 24             	mov    %ebx,(%esp)
  800fce:	e8 bb ff ff ff       	call   800f8e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd3:	43                   	inc    %ebx
  800fd4:	83 fb 20             	cmp    $0x20,%ebx
  800fd7:	75 f2                	jne    800fcb <close_all+0xc>
		close(i);
}
  800fd9:	83 c4 14             	add    $0x14,%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 4c             	sub    $0x4c,%esp
  800fe8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800feb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff5:	89 04 24             	mov    %eax,(%esp)
  800ff8:	e8 59 fe ff ff       	call   800e56 <fd_lookup>
  800ffd:	89 c3                	mov    %eax,%ebx
  800fff:	85 c0                	test   %eax,%eax
  801001:	0f 88 e1 00 00 00    	js     8010e8 <dup+0x109>
		return r;
	close(newfdnum);
  801007:	89 3c 24             	mov    %edi,(%esp)
  80100a:	e8 7f ff ff ff       	call   800f8e <close>

	newfd = INDEX2FD(newfdnum);
  80100f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801015:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101b:	89 04 24             	mov    %eax,(%esp)
  80101e:	e8 c5 fd ff ff       	call   800de8 <fd2data>
  801023:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801025:	89 34 24             	mov    %esi,(%esp)
  801028:	e8 bb fd ff ff       	call   800de8 <fd2data>
  80102d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801030:	89 d8                	mov    %ebx,%eax
  801032:	c1 e8 16             	shr    $0x16,%eax
  801035:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103c:	a8 01                	test   $0x1,%al
  80103e:	74 46                	je     801086 <dup+0xa7>
  801040:	89 d8                	mov    %ebx,%eax
  801042:	c1 e8 0c             	shr    $0xc,%eax
  801045:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104c:	f6 c2 01             	test   $0x1,%dl
  80104f:	74 35                	je     801086 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801051:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801058:	25 07 0e 00 00       	and    $0xe07,%eax
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801064:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801068:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106f:	00 
  801070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107b:	e8 41 fb ff ff       	call   800bc1 <sys_page_map>
  801080:	89 c3                	mov    %eax,%ebx
  801082:	85 c0                	test   %eax,%eax
  801084:	78 3b                	js     8010c1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801086:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801089:	89 c2                	mov    %eax,%edx
  80108b:	c1 ea 0c             	shr    $0xc,%edx
  80108e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801095:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80109b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80109f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010aa:	00 
  8010ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b6:	e8 06 fb ff ff       	call   800bc1 <sys_page_map>
  8010bb:	89 c3                	mov    %eax,%ebx
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 25                	jns    8010e6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cc:	e8 43 fb ff ff       	call   800c14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010df:	e8 30 fb ff ff       	call   800c14 <sys_page_unmap>
	return r;
  8010e4:	eb 02                	jmp    8010e8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010e6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	83 c4 4c             	add    $0x4c,%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 24             	sub    $0x24,%esp
  8010f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801103:	89 1c 24             	mov    %ebx,(%esp)
  801106:	e8 4b fd ff ff       	call   800e56 <fd_lookup>
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 6d                	js     80117c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801112:	89 44 24 04          	mov    %eax,0x4(%esp)
  801116:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801119:	8b 00                	mov    (%eax),%eax
  80111b:	89 04 24             	mov    %eax,(%esp)
  80111e:	e8 89 fd ff ff       	call   800eac <dev_lookup>
  801123:	85 c0                	test   %eax,%eax
  801125:	78 55                	js     80117c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801127:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112a:	8b 50 08             	mov    0x8(%eax),%edx
  80112d:	83 e2 03             	and    $0x3,%edx
  801130:	83 fa 01             	cmp    $0x1,%edx
  801133:	75 23                	jne    801158 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801135:	a1 04 40 80 00       	mov    0x804004,%eax
  80113a:	8b 40 48             	mov    0x48(%eax),%eax
  80113d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801141:	89 44 24 04          	mov    %eax,0x4(%esp)
  801145:	c7 04 24 4d 23 80 00 	movl   $0x80234d,(%esp)
  80114c:	e8 5f f0 ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801151:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801156:	eb 24                	jmp    80117c <read+0x8a>
	}
	if (!dev->dev_read)
  801158:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80115b:	8b 52 08             	mov    0x8(%edx),%edx
  80115e:	85 d2                	test   %edx,%edx
  801160:	74 15                	je     801177 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801162:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801165:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801170:	89 04 24             	mov    %eax,(%esp)
  801173:	ff d2                	call   *%edx
  801175:	eb 05                	jmp    80117c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801177:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80117c:	83 c4 24             	add    $0x24,%esp
  80117f:	5b                   	pop    %ebx
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	57                   	push   %edi
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	83 ec 1c             	sub    $0x1c,%esp
  80118b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801191:	bb 00 00 00 00       	mov    $0x0,%ebx
  801196:	eb 23                	jmp    8011bb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801198:	89 f0                	mov    %esi,%eax
  80119a:	29 d8                	sub    %ebx,%eax
  80119c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a3:	01 d8                	add    %ebx,%eax
  8011a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a9:	89 3c 24             	mov    %edi,(%esp)
  8011ac:	e8 41 ff ff ff       	call   8010f2 <read>
		if (m < 0)
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 10                	js     8011c5 <readn+0x43>
			return m;
		if (m == 0)
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	74 0a                	je     8011c3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b9:	01 c3                	add    %eax,%ebx
  8011bb:	39 f3                	cmp    %esi,%ebx
  8011bd:	72 d9                	jb     801198 <readn+0x16>
  8011bf:	89 d8                	mov    %ebx,%eax
  8011c1:	eb 02                	jmp    8011c5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011c3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011c5:	83 c4 1c             	add    $0x1c,%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 24             	sub    $0x24,%esp
  8011d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011de:	89 1c 24             	mov    %ebx,(%esp)
  8011e1:	e8 70 fc ff ff       	call   800e56 <fd_lookup>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 68                	js     801252 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	8b 00                	mov    (%eax),%eax
  8011f6:	89 04 24             	mov    %eax,(%esp)
  8011f9:	e8 ae fc ff ff       	call   800eac <dev_lookup>
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 50                	js     801252 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801209:	75 23                	jne    80122e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80120b:	a1 04 40 80 00       	mov    0x804004,%eax
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121b:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
  801222:	e8 89 ef ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122c:	eb 24                	jmp    801252 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80122e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801231:	8b 52 0c             	mov    0xc(%edx),%edx
  801234:	85 d2                	test   %edx,%edx
  801236:	74 15                	je     80124d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801238:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80123b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80123f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801242:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801246:	89 04 24             	mov    %eax,(%esp)
  801249:	ff d2                	call   *%edx
  80124b:	eb 05                	jmp    801252 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80124d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801252:	83 c4 24             	add    $0x24,%esp
  801255:	5b                   	pop    %ebx
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <seek>:

int
seek(int fdnum, off_t offset)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	89 04 24             	mov    %eax,(%esp)
  80126b:	e8 e6 fb ff ff       	call   800e56 <fd_lookup>
  801270:	85 c0                	test   %eax,%eax
  801272:	78 0e                	js     801282 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801274:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801282:	c9                   	leave  
  801283:	c3                   	ret    

00801284 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	53                   	push   %ebx
  801288:	83 ec 24             	sub    $0x24,%esp
  80128b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801291:	89 44 24 04          	mov    %eax,0x4(%esp)
  801295:	89 1c 24             	mov    %ebx,(%esp)
  801298:	e8 b9 fb ff ff       	call   800e56 <fd_lookup>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 61                	js     801302 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	8b 00                	mov    (%eax),%eax
  8012ad:	89 04 24             	mov    %eax,(%esp)
  8012b0:	e8 f7 fb ff ff       	call   800eac <dev_lookup>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 49                	js     801302 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c0:	75 23                	jne    8012e5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012c2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d2:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  8012d9:	e8 d2 ee ff ff       	call   8001b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e3:	eb 1d                	jmp    801302 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e8:	8b 52 18             	mov    0x18(%edx),%edx
  8012eb:	85 d2                	test   %edx,%edx
  8012ed:	74 0e                	je     8012fd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012f6:	89 04 24             	mov    %eax,(%esp)
  8012f9:	ff d2                	call   *%edx
  8012fb:	eb 05                	jmp    801302 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801302:	83 c4 24             	add    $0x24,%esp
  801305:	5b                   	pop    %ebx
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 24             	sub    $0x24,%esp
  80130f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801312:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	89 04 24             	mov    %eax,(%esp)
  80131f:	e8 32 fb ff ff       	call   800e56 <fd_lookup>
  801324:	85 c0                	test   %eax,%eax
  801326:	78 52                	js     80137a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801332:	8b 00                	mov    (%eax),%eax
  801334:	89 04 24             	mov    %eax,(%esp)
  801337:	e8 70 fb ff ff       	call   800eac <dev_lookup>
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 3a                	js     80137a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801343:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801347:	74 2c                	je     801375 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801349:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801353:	00 00 00 
	stat->st_isdir = 0;
  801356:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135d:	00 00 00 
	stat->st_dev = dev;
  801360:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801366:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80136a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136d:	89 14 24             	mov    %edx,(%esp)
  801370:	ff 50 14             	call   *0x14(%eax)
  801373:	eb 05                	jmp    80137a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801375:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80137a:	83 c4 24             	add    $0x24,%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801388:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80138f:	00 
  801390:	8b 45 08             	mov    0x8(%ebp),%eax
  801393:	89 04 24             	mov    %eax,(%esp)
  801396:	e8 fe 01 00 00       	call   801599 <open>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 1b                	js     8013bc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	89 1c 24             	mov    %ebx,(%esp)
  8013ab:	e8 58 ff ff ff       	call   801308 <fstat>
  8013b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b2:	89 1c 24             	mov    %ebx,(%esp)
  8013b5:	e8 d4 fb ff ff       	call   800f8e <close>
	return r;
  8013ba:	89 f3                	mov    %esi,%ebx
}
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
  8013c5:	00 00                	add    %al,(%eax)
	...

008013c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 10             	sub    $0x10,%esp
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013db:	75 11                	jne    8013ee <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013e4:	e8 90 08 00 00       	call   801c79 <ipc_find_env>
  8013e9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013f5:	00 
  8013f6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013fd:	00 
  8013fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801402:	a1 00 40 80 00       	mov    0x804000,%eax
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	e8 00 08 00 00       	call   801c0f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801416:	00 
  801417:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801422:	e8 81 07 00 00       	call   801ba8 <ipc_recv>
}
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801442:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	b8 02 00 00 00       	mov    $0x2,%eax
  801451:	e8 72 ff ff ff       	call   8013c8 <fsipc>
}
  801456:	c9                   	leave  
  801457:	c3                   	ret    

00801458 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
  801461:	8b 40 0c             	mov    0xc(%eax),%eax
  801464:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801469:	ba 00 00 00 00       	mov    $0x0,%edx
  80146e:	b8 06 00 00 00       	mov    $0x6,%eax
  801473:	e8 50 ff ff ff       	call   8013c8 <fsipc>
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 14             	sub    $0x14,%esp
  801481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148f:	ba 00 00 00 00       	mov    $0x0,%edx
  801494:	b8 05 00 00 00       	mov    $0x5,%eax
  801499:	e8 2a ff ff ff       	call   8013c8 <fsipc>
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 2b                	js     8014cd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014a9:	00 
  8014aa:	89 1c 24             	mov    %ebx,(%esp)
  8014ad:	e8 c9 f2 ff ff       	call   80077b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cd:	83 c4 14             	add    $0x14,%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8014d9:	c7 44 24 08 98 23 80 	movl   $0x802398,0x8(%esp)
  8014e0:	00 
  8014e1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8014e8:	00 
  8014e9:	c7 04 24 b6 23 80 00 	movl   $0x8023b6,(%esp)
  8014f0:	e8 5b 06 00 00       	call   801b50 <_panic>

008014f5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 10             	sub    $0x10,%esp
  8014fd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	8b 40 0c             	mov    0xc(%eax),%eax
  801506:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80150b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 03 00 00 00       	mov    $0x3,%eax
  80151b:	e8 a8 fe ff ff       	call   8013c8 <fsipc>
  801520:	89 c3                	mov    %eax,%ebx
  801522:	85 c0                	test   %eax,%eax
  801524:	78 6a                	js     801590 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801526:	39 c6                	cmp    %eax,%esi
  801528:	73 24                	jae    80154e <devfile_read+0x59>
  80152a:	c7 44 24 0c c1 23 80 	movl   $0x8023c1,0xc(%esp)
  801531:	00 
  801532:	c7 44 24 08 c8 23 80 	movl   $0x8023c8,0x8(%esp)
  801539:	00 
  80153a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801541:	00 
  801542:	c7 04 24 b6 23 80 00 	movl   $0x8023b6,(%esp)
  801549:	e8 02 06 00 00       	call   801b50 <_panic>
	assert(r <= PGSIZE);
  80154e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801553:	7e 24                	jle    801579 <devfile_read+0x84>
  801555:	c7 44 24 0c dd 23 80 	movl   $0x8023dd,0xc(%esp)
  80155c:	00 
  80155d:	c7 44 24 08 c8 23 80 	movl   $0x8023c8,0x8(%esp)
  801564:	00 
  801565:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80156c:	00 
  80156d:	c7 04 24 b6 23 80 00 	movl   $0x8023b6,(%esp)
  801574:	e8 d7 05 00 00       	call   801b50 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801579:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801584:	00 
  801585:	8b 45 0c             	mov    0xc(%ebp),%eax
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	e8 64 f3 ff ff       	call   8008f4 <memmove>
	return r;
}
  801590:	89 d8                	mov    %ebx,%eax
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    

00801599 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 20             	sub    $0x20,%esp
  8015a1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a4:	89 34 24             	mov    %esi,(%esp)
  8015a7:	e8 9c f1 ff ff       	call   800748 <strlen>
  8015ac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b1:	7f 60                	jg     801613 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 45 f8 ff ff       	call   800e03 <fd_alloc>
  8015be:	89 c3                	mov    %eax,%ebx
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 54                	js     801618 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015cf:	e8 a7 f1 ff ff       	call   80077b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e4:	e8 df fd ff ff       	call   8013c8 <fsipc>
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	79 15                	jns    801604 <open+0x6b>
		fd_close(fd, 0);
  8015ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015f6:	00 
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	89 04 24             	mov    %eax,(%esp)
  8015fd:	e8 04 f9 ff ff       	call   800f06 <fd_close>
		return r;
  801602:	eb 14                	jmp    801618 <open+0x7f>
	}

	return fd2num(fd);
  801604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	e8 c9 f7 ff ff       	call   800dd8 <fd2num>
  80160f:	89 c3                	mov    %eax,%ebx
  801611:	eb 05                	jmp    801618 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801613:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801618:	89 d8                	mov    %ebx,%eax
  80161a:	83 c4 20             	add    $0x20,%esp
  80161d:	5b                   	pop    %ebx
  80161e:	5e                   	pop    %esi
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 08 00 00 00       	mov    $0x8,%eax
  801631:	e8 92 fd ff ff       	call   8013c8 <fsipc>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	83 ec 10             	sub    $0x10,%esp
  801640:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 9a f7 ff ff       	call   800de8 <fd2data>
  80164e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801650:	c7 44 24 04 e9 23 80 	movl   $0x8023e9,0x4(%esp)
  801657:	00 
  801658:	89 34 24             	mov    %esi,(%esp)
  80165b:	e8 1b f1 ff ff       	call   80077b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801660:	8b 43 04             	mov    0x4(%ebx),%eax
  801663:	2b 03                	sub    (%ebx),%eax
  801665:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80166b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801672:	00 00 00 
	stat->st_dev = &devpipe;
  801675:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80167c:	30 80 00 
	return 0;
}
  80167f:	b8 00 00 00 00       	mov    $0x0,%eax
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 14             	sub    $0x14,%esp
  801692:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801695:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801699:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a0:	e8 6f f5 ff ff       	call   800c14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 3b f7 ff ff       	call   800de8 <fd2data>
  8016ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b8:	e8 57 f5 ff ff       	call   800c14 <sys_page_unmap>
}
  8016bd:	83 c4 14             	add    $0x14,%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	57                   	push   %edi
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 2c             	sub    $0x2c,%esp
  8016cc:	89 c7                	mov    %eax,%edi
  8016ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016d9:	89 3c 24             	mov    %edi,(%esp)
  8016dc:	e8 df 05 00 00       	call   801cc0 <pageref>
  8016e1:	89 c6                	mov    %eax,%esi
  8016e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e6:	89 04 24             	mov    %eax,(%esp)
  8016e9:	e8 d2 05 00 00       	call   801cc0 <pageref>
  8016ee:	39 c6                	cmp    %eax,%esi
  8016f0:	0f 94 c0             	sete   %al
  8016f3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016f6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ff:	39 cb                	cmp    %ecx,%ebx
  801701:	75 08                	jne    80170b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801703:	83 c4 2c             	add    $0x2c,%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5f                   	pop    %edi
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80170b:	83 f8 01             	cmp    $0x1,%eax
  80170e:	75 c1                	jne    8016d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801710:	8b 42 58             	mov    0x58(%edx),%eax
  801713:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80171a:	00 
  80171b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801723:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  80172a:	e8 81 ea ff ff       	call   8001b0 <cprintf>
  80172f:	eb a0                	jmp    8016d1 <_pipeisclosed+0xe>

00801731 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	57                   	push   %edi
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 1c             	sub    $0x1c,%esp
  80173a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80173d:	89 34 24             	mov    %esi,(%esp)
  801740:	e8 a3 f6 ff ff       	call   800de8 <fd2data>
  801745:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801747:	bf 00 00 00 00       	mov    $0x0,%edi
  80174c:	eb 3c                	jmp    80178a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80174e:	89 da                	mov    %ebx,%edx
  801750:	89 f0                	mov    %esi,%eax
  801752:	e8 6c ff ff ff       	call   8016c3 <_pipeisclosed>
  801757:	85 c0                	test   %eax,%eax
  801759:	75 38                	jne    801793 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80175b:	e8 ee f3 ff ff       	call   800b4e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801760:	8b 43 04             	mov    0x4(%ebx),%eax
  801763:	8b 13                	mov    (%ebx),%edx
  801765:	83 c2 20             	add    $0x20,%edx
  801768:	39 d0                	cmp    %edx,%eax
  80176a:	73 e2                	jae    80174e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80176c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801772:	89 c2                	mov    %eax,%edx
  801774:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80177a:	79 05                	jns    801781 <devpipe_write+0x50>
  80177c:	4a                   	dec    %edx
  80177d:	83 ca e0             	or     $0xffffffe0,%edx
  801780:	42                   	inc    %edx
  801781:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801785:	40                   	inc    %eax
  801786:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801789:	47                   	inc    %edi
  80178a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80178d:	75 d1                	jne    801760 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80178f:	89 f8                	mov    %edi,%eax
  801791:	eb 05                	jmp    801798 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801793:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801798:	83 c4 1c             	add    $0x1c,%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5f                   	pop    %edi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	57                   	push   %edi
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 1c             	sub    $0x1c,%esp
  8017a9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ac:	89 3c 24             	mov    %edi,(%esp)
  8017af:	e8 34 f6 ff ff       	call   800de8 <fd2data>
  8017b4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b6:	be 00 00 00 00       	mov    $0x0,%esi
  8017bb:	eb 3a                	jmp    8017f7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017bd:	85 f6                	test   %esi,%esi
  8017bf:	74 04                	je     8017c5 <devpipe_read+0x25>
				return i;
  8017c1:	89 f0                	mov    %esi,%eax
  8017c3:	eb 40                	jmp    801805 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017c5:	89 da                	mov    %ebx,%edx
  8017c7:	89 f8                	mov    %edi,%eax
  8017c9:	e8 f5 fe ff ff       	call   8016c3 <_pipeisclosed>
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	75 2e                	jne    801800 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017d2:	e8 77 f3 ff ff       	call   800b4e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017d7:	8b 03                	mov    (%ebx),%eax
  8017d9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017dc:	74 df                	je     8017bd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017de:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017e3:	79 05                	jns    8017ea <devpipe_read+0x4a>
  8017e5:	48                   	dec    %eax
  8017e6:	83 c8 e0             	or     $0xffffffe0,%eax
  8017e9:	40                   	inc    %eax
  8017ea:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017f4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f6:	46                   	inc    %esi
  8017f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017fa:	75 db                	jne    8017d7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017fc:	89 f0                	mov    %esi,%eax
  8017fe:	eb 05                	jmp    801805 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801800:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801805:	83 c4 1c             	add    $0x1c,%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5f                   	pop    %edi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	83 ec 3c             	sub    $0x3c,%esp
  801816:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801819:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 df f5 ff ff       	call   800e03 <fd_alloc>
  801824:	89 c3                	mov    %eax,%ebx
  801826:	85 c0                	test   %eax,%eax
  801828:	0f 88 45 01 00 00    	js     801973 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801835:	00 
  801836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801844:	e8 24 f3 ff ff       	call   800b6d <sys_page_alloc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	85 c0                	test   %eax,%eax
  80184d:	0f 88 20 01 00 00    	js     801973 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801853:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801856:	89 04 24             	mov    %eax,(%esp)
  801859:	e8 a5 f5 ff ff       	call   800e03 <fd_alloc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	85 c0                	test   %eax,%eax
  801862:	0f 88 f8 00 00 00    	js     801960 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801868:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80186f:	00 
  801870:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187e:	e8 ea f2 ff ff       	call   800b6d <sys_page_alloc>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 d3 00 00 00    	js     801960 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80188d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	e8 50 f5 ff ff       	call   800de8 <fd2data>
  801898:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018a1:	00 
  8018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ad:	e8 bb f2 ff ff       	call   800b6d <sys_page_alloc>
  8018b2:	89 c3                	mov    %eax,%ebx
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	0f 88 91 00 00 00    	js     80194d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018bf:	89 04 24             	mov    %eax,(%esp)
  8018c2:	e8 21 f5 ff ff       	call   800de8 <fd2data>
  8018c7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8018ce:	00 
  8018cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018da:	00 
  8018db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e6:	e8 d6 f2 ff ff       	call   800bc1 <sys_page_map>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 4c                	js     80193d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018f1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801906:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80190c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80190f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801911:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801914:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80191b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	e8 b2 f4 ff ff       	call   800dd8 <fd2num>
  801926:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801928:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	e8 a5 f4 ff ff       	call   800dd8 <fd2num>
  801933:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801936:	bb 00 00 00 00       	mov    $0x0,%ebx
  80193b:	eb 36                	jmp    801973 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80193d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801941:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801948:	e8 c7 f2 ff ff       	call   800c14 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80194d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801950:	89 44 24 04          	mov    %eax,0x4(%esp)
  801954:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195b:	e8 b4 f2 ff ff       	call   800c14 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801960:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801963:	89 44 24 04          	mov    %eax,0x4(%esp)
  801967:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196e:	e8 a1 f2 ff ff       	call   800c14 <sys_page_unmap>
    err:
	return r;
}
  801973:	89 d8                	mov    %ebx,%eax
  801975:	83 c4 3c             	add    $0x3c,%esp
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5f                   	pop    %edi
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198a:	8b 45 08             	mov    0x8(%ebp),%eax
  80198d:	89 04 24             	mov    %eax,(%esp)
  801990:	e8 c1 f4 ff ff       	call   800e56 <fd_lookup>
  801995:	85 c0                	test   %eax,%eax
  801997:	78 15                	js     8019ae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 44 f4 ff ff       	call   800de8 <fd2data>
	return _pipeisclosed(fd, p);
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a9:	e8 15 fd ff ff       	call   8016c3 <_pipeisclosed>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8019c0:	c7 44 24 04 08 24 80 	movl   $0x802408,0x4(%esp)
  8019c7:	00 
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 a8 ed ff ff       	call   80077b <strcpy>
	return 0;
}
  8019d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	57                   	push   %edi
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f1:	eb 30                	jmp    801a23 <devcons_write+0x49>
		m = n - tot;
  8019f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8019f6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019f8:	83 fe 7f             	cmp    $0x7f,%esi
  8019fb:	76 05                	jbe    801a02 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019fd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a02:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a06:	03 45 0c             	add    0xc(%ebp),%eax
  801a09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0d:	89 3c 24             	mov    %edi,(%esp)
  801a10:	e8 df ee ff ff       	call   8008f4 <memmove>
		sys_cputs(buf, m);
  801a15:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a19:	89 3c 24             	mov    %edi,(%esp)
  801a1c:	e8 7f f0 ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a21:	01 f3                	add    %esi,%ebx
  801a23:	89 d8                	mov    %ebx,%eax
  801a25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a28:	72 c9                	jb     8019f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a2a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	5f                   	pop    %edi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a3f:	75 07                	jne    801a48 <devcons_read+0x13>
  801a41:	eb 25                	jmp    801a68 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a43:	e8 06 f1 ff ff       	call   800b4e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a48:	e8 71 f0 ff ff       	call   800abe <sys_cgetc>
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	74 f2                	je     801a43 <devcons_read+0xe>
  801a51:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 1d                	js     801a74 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a57:	83 f8 04             	cmp    $0x4,%eax
  801a5a:	74 13                	je     801a6f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	88 10                	mov    %dl,(%eax)
	return 1;
  801a61:	b8 01 00 00 00       	mov    $0x1,%eax
  801a66:	eb 0c                	jmp    801a74 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6d:	eb 05                	jmp    801a74 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a89:	00 
  801a8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a8d:	89 04 24             	mov    %eax,(%esp)
  801a90:	e8 0b f0 ff ff       	call   800aa0 <sys_cputs>
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <getchar>:

int
getchar(void)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a9d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801aa4:	00 
  801aa5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab3:	e8 3a f6 ff ff       	call   8010f2 <read>
	if (r < 0)
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	78 0f                	js     801acb <getchar+0x34>
		return r;
	if (r < 1)
  801abc:	85 c0                	test   %eax,%eax
  801abe:	7e 06                	jle    801ac6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801ac0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ac4:	eb 05                	jmp    801acb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ac6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	89 04 24             	mov    %eax,(%esp)
  801ae0:	e8 71 f3 ff ff       	call   800e56 <fd_lookup>
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 11                	js     801afa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af2:	39 10                	cmp    %edx,(%eax)
  801af4:	0f 94 c0             	sete   %al
  801af7:	0f b6 c0             	movzbl %al,%eax
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <opencons>:

int
opencons(void)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	89 04 24             	mov    %eax,(%esp)
  801b08:	e8 f6 f2 ff ff       	call   800e03 <fd_alloc>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 3c                	js     801b4d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b11:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b18:	00 
  801b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b27:	e8 41 f0 ff ff       	call   800b6d <sys_page_alloc>
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 1d                	js     801b4d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b30:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 8b f2 ff ff       	call   800dd8 <fd2num>
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    
	...

00801b50 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b58:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b5b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b61:	e8 c9 ef ff ff       	call   800b2f <sys_getenvid>
  801b66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b69:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b70:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b74:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7c:	c7 04 24 14 24 80 00 	movl   $0x802414,(%esp)
  801b83:	e8 28 e6 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b88:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 b8 e5 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  801b97:	c7 04 24 01 24 80 00 	movl   $0x802401,(%esp)
  801b9e:	e8 0d e6 ff ff       	call   8001b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ba3:	cc                   	int3   
  801ba4:	eb fd                	jmp    801ba3 <_panic+0x53>
	...

00801ba8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 10             	sub    $0x10,%esp
  801bb0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	75 05                	jne    801bc2 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801bbd:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 b9 f1 ff ff       	call   800d83 <sys_ipc_recv>
	if (!err) {
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	75 26                	jne    801bf4 <ipc_recv+0x4c>
		if (from_env_store) {
  801bce:	85 f6                	test   %esi,%esi
  801bd0:	74 0a                	je     801bdc <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801bd2:	a1 04 40 80 00       	mov    0x804004,%eax
  801bd7:	8b 40 74             	mov    0x74(%eax),%eax
  801bda:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801bdc:	85 db                	test   %ebx,%ebx
  801bde:	74 0a                	je     801bea <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801be0:	a1 04 40 80 00       	mov    0x804004,%eax
  801be5:	8b 40 78             	mov    0x78(%eax),%eax
  801be8:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801bea:	a1 04 40 80 00       	mov    0x804004,%eax
  801bef:	8b 40 70             	mov    0x70(%eax),%eax
  801bf2:	eb 14                	jmp    801c08 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801bf4:	85 f6                	test   %esi,%esi
  801bf6:	74 06                	je     801bfe <ipc_recv+0x56>
		*from_env_store = 0;
  801bf8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801bfe:	85 db                	test   %ebx,%ebx
  801c00:	74 06                	je     801c08 <ipc_recv+0x60>
		*perm_store = 0;
  801c02:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	57                   	push   %edi
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	83 ec 1c             	sub    $0x1c,%esp
  801c18:	8b 75 10             	mov    0x10(%ebp),%esi
  801c1b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801c1e:	85 f6                	test   %esi,%esi
  801c20:	75 05                	jne    801c27 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801c22:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801c27:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c2b:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	89 04 24             	mov    %eax,(%esp)
  801c3c:	e8 1f f1 ff ff       	call   800d60 <sys_ipc_try_send>
  801c41:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801c43:	e8 06 ef ff ff       	call   800b4e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801c48:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801c4b:	74 da                	je     801c27 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801c4d:	85 db                	test   %ebx,%ebx
  801c4f:	74 20                	je     801c71 <ipc_send+0x62>
		panic("send fail: %e", err);
  801c51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c55:	c7 44 24 08 38 24 80 	movl   $0x802438,0x8(%esp)
  801c5c:	00 
  801c5d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c64:	00 
  801c65:	c7 04 24 46 24 80 00 	movl   $0x802446,(%esp)
  801c6c:	e8 df fe ff ff       	call   801b50 <_panic>
	}
	return;
}
  801c71:	83 c4 1c             	add    $0x1c,%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	53                   	push   %ebx
  801c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c85:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	c1 e2 07             	shl    $0x7,%edx
  801c91:	29 ca                	sub    %ecx,%edx
  801c93:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c99:	8b 52 50             	mov    0x50(%edx),%edx
  801c9c:	39 da                	cmp    %ebx,%edx
  801c9e:	75 0f                	jne    801caf <ipc_find_env+0x36>
			return envs[i].env_id;
  801ca0:	c1 e0 07             	shl    $0x7,%eax
  801ca3:	29 c8                	sub    %ecx,%eax
  801ca5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801caa:	8b 40 40             	mov    0x40(%eax),%eax
  801cad:	eb 0c                	jmp    801cbb <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801caf:	40                   	inc    %eax
  801cb0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cb5:	75 ce                	jne    801c85 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cb7:	66 b8 00 00          	mov    $0x0,%ax
}
  801cbb:	5b                   	pop    %ebx
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    
	...

00801cc0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	c1 ea 16             	shr    $0x16,%edx
  801ccb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cd2:	f6 c2 01             	test   $0x1,%dl
  801cd5:	74 1e                	je     801cf5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cd7:	c1 e8 0c             	shr    $0xc,%eax
  801cda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ce1:	a8 01                	test   $0x1,%al
  801ce3:	74 17                	je     801cfc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ce5:	c1 e8 0c             	shr    $0xc,%eax
  801ce8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cef:	ef 
  801cf0:	0f b7 c0             	movzwl %ax,%eax
  801cf3:	eb 0c                	jmp    801d01 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfa:	eb 05                	jmp    801d01 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
	...

00801d04 <__udivdi3>:
  801d04:	55                   	push   %ebp
  801d05:	57                   	push   %edi
  801d06:	56                   	push   %esi
  801d07:	83 ec 10             	sub    $0x10,%esp
  801d0a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d0e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d12:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d16:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d1a:	89 cd                	mov    %ecx,%ebp
  801d1c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d20:	85 c0                	test   %eax,%eax
  801d22:	75 2c                	jne    801d50 <__udivdi3+0x4c>
  801d24:	39 f9                	cmp    %edi,%ecx
  801d26:	77 68                	ja     801d90 <__udivdi3+0x8c>
  801d28:	85 c9                	test   %ecx,%ecx
  801d2a:	75 0b                	jne    801d37 <__udivdi3+0x33>
  801d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d31:	31 d2                	xor    %edx,%edx
  801d33:	f7 f1                	div    %ecx
  801d35:	89 c1                	mov    %eax,%ecx
  801d37:	31 d2                	xor    %edx,%edx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	f7 f1                	div    %ecx
  801d3d:	89 c7                	mov    %eax,%edi
  801d3f:	89 f0                	mov    %esi,%eax
  801d41:	f7 f1                	div    %ecx
  801d43:	89 c6                	mov    %eax,%esi
  801d45:	89 f0                	mov    %esi,%eax
  801d47:	89 fa                	mov    %edi,%edx
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    
  801d50:	39 f8                	cmp    %edi,%eax
  801d52:	77 2c                	ja     801d80 <__udivdi3+0x7c>
  801d54:	0f bd f0             	bsr    %eax,%esi
  801d57:	83 f6 1f             	xor    $0x1f,%esi
  801d5a:	75 4c                	jne    801da8 <__udivdi3+0xa4>
  801d5c:	39 f8                	cmp    %edi,%eax
  801d5e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d63:	72 0a                	jb     801d6f <__udivdi3+0x6b>
  801d65:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d69:	0f 87 ad 00 00 00    	ja     801e1c <__udivdi3+0x118>
  801d6f:	be 01 00 00 00       	mov    $0x1,%esi
  801d74:	89 f0                	mov    %esi,%eax
  801d76:	89 fa                	mov    %edi,%edx
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	5e                   	pop    %esi
  801d7c:	5f                   	pop    %edi
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    
  801d7f:	90                   	nop
  801d80:	31 ff                	xor    %edi,%edi
  801d82:	31 f6                	xor    %esi,%esi
  801d84:	89 f0                	mov    %esi,%eax
  801d86:	89 fa                	mov    %edi,%edx
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    
  801d8f:	90                   	nop
  801d90:	89 fa                	mov    %edi,%edx
  801d92:	89 f0                	mov    %esi,%eax
  801d94:	f7 f1                	div    %ecx
  801d96:	89 c6                	mov    %eax,%esi
  801d98:	31 ff                	xor    %edi,%edi
  801d9a:	89 f0                	mov    %esi,%eax
  801d9c:	89 fa                	mov    %edi,%edx
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 f1                	mov    %esi,%ecx
  801daa:	d3 e0                	shl    %cl,%eax
  801dac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db0:	b8 20 00 00 00       	mov    $0x20,%eax
  801db5:	29 f0                	sub    %esi,%eax
  801db7:	89 ea                	mov    %ebp,%edx
  801db9:	88 c1                	mov    %al,%cl
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801dc1:	09 ca                	or     %ecx,%edx
  801dc3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dc7:	89 f1                	mov    %esi,%ecx
  801dc9:	d3 e5                	shl    %cl,%ebp
  801dcb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801dcf:	89 fd                	mov    %edi,%ebp
  801dd1:	88 c1                	mov    %al,%cl
  801dd3:	d3 ed                	shr    %cl,%ebp
  801dd5:	89 fa                	mov    %edi,%edx
  801dd7:	89 f1                	mov    %esi,%ecx
  801dd9:	d3 e2                	shl    %cl,%edx
  801ddb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ddf:	88 c1                	mov    %al,%cl
  801de1:	d3 ef                	shr    %cl,%edi
  801de3:	09 d7                	or     %edx,%edi
  801de5:	89 f8                	mov    %edi,%eax
  801de7:	89 ea                	mov    %ebp,%edx
  801de9:	f7 74 24 08          	divl   0x8(%esp)
  801ded:	89 d1                	mov    %edx,%ecx
  801def:	89 c7                	mov    %eax,%edi
  801df1:	f7 64 24 0c          	mull   0xc(%esp)
  801df5:	39 d1                	cmp    %edx,%ecx
  801df7:	72 17                	jb     801e10 <__udivdi3+0x10c>
  801df9:	74 09                	je     801e04 <__udivdi3+0x100>
  801dfb:	89 fe                	mov    %edi,%esi
  801dfd:	31 ff                	xor    %edi,%edi
  801dff:	e9 41 ff ff ff       	jmp    801d45 <__udivdi3+0x41>
  801e04:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e08:	89 f1                	mov    %esi,%ecx
  801e0a:	d3 e2                	shl    %cl,%edx
  801e0c:	39 c2                	cmp    %eax,%edx
  801e0e:	73 eb                	jae    801dfb <__udivdi3+0xf7>
  801e10:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e13:	31 ff                	xor    %edi,%edi
  801e15:	e9 2b ff ff ff       	jmp    801d45 <__udivdi3+0x41>
  801e1a:	66 90                	xchg   %ax,%ax
  801e1c:	31 f6                	xor    %esi,%esi
  801e1e:	e9 22 ff ff ff       	jmp    801d45 <__udivdi3+0x41>
	...

00801e24 <__umoddi3>:
  801e24:	55                   	push   %ebp
  801e25:	57                   	push   %edi
  801e26:	56                   	push   %esi
  801e27:	83 ec 20             	sub    $0x20,%esp
  801e2a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e2e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e32:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e36:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e3a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e3e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e42:	89 c7                	mov    %eax,%edi
  801e44:	89 f2                	mov    %esi,%edx
  801e46:	85 ed                	test   %ebp,%ebp
  801e48:	75 16                	jne    801e60 <__umoddi3+0x3c>
  801e4a:	39 f1                	cmp    %esi,%ecx
  801e4c:	0f 86 a6 00 00 00    	jbe    801ef8 <__umoddi3+0xd4>
  801e52:	f7 f1                	div    %ecx
  801e54:	89 d0                	mov    %edx,%eax
  801e56:	31 d2                	xor    %edx,%edx
  801e58:	83 c4 20             	add    $0x20,%esp
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    
  801e5f:	90                   	nop
  801e60:	39 f5                	cmp    %esi,%ebp
  801e62:	0f 87 ac 00 00 00    	ja     801f14 <__umoddi3+0xf0>
  801e68:	0f bd c5             	bsr    %ebp,%eax
  801e6b:	83 f0 1f             	xor    $0x1f,%eax
  801e6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e72:	0f 84 a8 00 00 00    	je     801f20 <__umoddi3+0xfc>
  801e78:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e7c:	d3 e5                	shl    %cl,%ebp
  801e7e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e83:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e87:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e8b:	89 f9                	mov    %edi,%ecx
  801e8d:	d3 e8                	shr    %cl,%eax
  801e8f:	09 e8                	or     %ebp,%eax
  801e91:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e95:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e99:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e9d:	d3 e0                	shl    %cl,%eax
  801e9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea3:	89 f2                	mov    %esi,%edx
  801ea5:	d3 e2                	shl    %cl,%edx
  801ea7:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eab:	d3 e0                	shl    %cl,%eax
  801ead:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801eb1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eb5:	89 f9                	mov    %edi,%ecx
  801eb7:	d3 e8                	shr    %cl,%eax
  801eb9:	09 d0                	or     %edx,%eax
  801ebb:	d3 ee                	shr    %cl,%esi
  801ebd:	89 f2                	mov    %esi,%edx
  801ebf:	f7 74 24 18          	divl   0x18(%esp)
  801ec3:	89 d6                	mov    %edx,%esi
  801ec5:	f7 64 24 0c          	mull   0xc(%esp)
  801ec9:	89 c5                	mov    %eax,%ebp
  801ecb:	89 d1                	mov    %edx,%ecx
  801ecd:	39 d6                	cmp    %edx,%esi
  801ecf:	72 67                	jb     801f38 <__umoddi3+0x114>
  801ed1:	74 75                	je     801f48 <__umoddi3+0x124>
  801ed3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ed7:	29 e8                	sub    %ebp,%eax
  801ed9:	19 ce                	sbb    %ecx,%esi
  801edb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801edf:	d3 e8                	shr    %cl,%eax
  801ee1:	89 f2                	mov    %esi,%edx
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	d3 e2                	shl    %cl,%edx
  801ee7:	09 d0                	or     %edx,%eax
  801ee9:	89 f2                	mov    %esi,%edx
  801eeb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eef:	d3 ea                	shr    %cl,%edx
  801ef1:	83 c4 20             	add    $0x20,%esp
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    
  801ef8:	85 c9                	test   %ecx,%ecx
  801efa:	75 0b                	jne    801f07 <__umoddi3+0xe3>
  801efc:	b8 01 00 00 00       	mov    $0x1,%eax
  801f01:	31 d2                	xor    %edx,%edx
  801f03:	f7 f1                	div    %ecx
  801f05:	89 c1                	mov    %eax,%ecx
  801f07:	89 f0                	mov    %esi,%eax
  801f09:	31 d2                	xor    %edx,%edx
  801f0b:	f7 f1                	div    %ecx
  801f0d:	89 f8                	mov    %edi,%eax
  801f0f:	e9 3e ff ff ff       	jmp    801e52 <__umoddi3+0x2e>
  801f14:	89 f2                	mov    %esi,%edx
  801f16:	83 c4 20             	add    $0x20,%esp
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
  801f1d:	8d 76 00             	lea    0x0(%esi),%esi
  801f20:	39 f5                	cmp    %esi,%ebp
  801f22:	72 04                	jb     801f28 <__umoddi3+0x104>
  801f24:	39 f9                	cmp    %edi,%ecx
  801f26:	77 06                	ja     801f2e <__umoddi3+0x10a>
  801f28:	89 f2                	mov    %esi,%edx
  801f2a:	29 cf                	sub    %ecx,%edi
  801f2c:	19 ea                	sbb    %ebp,%edx
  801f2e:	89 f8                	mov    %edi,%eax
  801f30:	83 c4 20             	add    $0x20,%esp
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
  801f37:	90                   	nop
  801f38:	89 d1                	mov    %edx,%ecx
  801f3a:	89 c5                	mov    %eax,%ebp
  801f3c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f40:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f44:	eb 8d                	jmp    801ed3 <__umoddi3+0xaf>
  801f46:	66 90                	xchg   %ax,%ax
  801f48:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f4c:	72 ea                	jb     801f38 <__umoddi3+0x114>
  801f4e:	89 f1                	mov    %esi,%ecx
  801f50:	eb 81                	jmp    801ed3 <__umoddi3+0xaf>
