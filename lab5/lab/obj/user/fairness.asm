
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 12 0b 00 00       	call   800b53 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 92 0d 00 00       	call   800dfc <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  80007c:	e8 53 01 00 00       	call   8001d4 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 91 1f 80 00 	movl   $0x801f91,(%esp)
  800097:	e8 38 01 00 00       	call   8001d4 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 a2 0d 00 00       	call   800e63 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000d2:	e8 7c 0a 00 00       	call   800b53 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	29 d0                	sub    %edx,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 f6                	test   %esi,%esi
  8000f4:	7e 07                	jle    8000fd <libmain+0x39>
		binaryname = argv[0];
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	89 34 24             	mov    %esi,(%esp)
  800104:	e8 2b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
  800115:	00 00                	add    %al,(%eax)
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80011e:	e8 d8 0f 00 00       	call   8010fb <close_all>
	sys_env_destroy(0);
  800123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012a:	e8 d2 09 00 00       	call   800b01 <sys_env_destroy>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 14             	sub    $0x14,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 03                	mov    (%ebx),%eax
  800140:	8b 55 08             	mov    0x8(%ebp),%edx
  800143:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800147:	40                   	inc    %eax
  800148:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014f:	75 19                	jne    80016a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800151:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800158:	00 
  800159:	8d 43 08             	lea    0x8(%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 60 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  800164:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016a:	ff 43 04             	incl   0x4(%ebx)
}
  80016d:	83 c4 14             	add    $0x14,%esp
  800170:	5b                   	pop    %ebx
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800183:	00 00 00 
	b.cnt = 0;
  800186:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800197:	8b 45 08             	mov    0x8(%ebp),%eax
  80019a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	c7 04 24 34 01 80 00 	movl   $0x800134,(%esp)
  8001af:	e8 82 01 00 00       	call   800336 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 f8 08 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 87 ff ff ff       	call   800173 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	85 c0                	test   %eax,%eax
  800212:	75 08                	jne    80021c <printnum+0x2c>
  800214:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 57                	ja     800273 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800220:	4b                   	dec    %ebx
  800221:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800225:	8b 45 10             	mov    0x10(%ebp),%eax
  800228:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800230:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800234:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023b:	00 
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	e8 da 1a 00 00       	call   801d28 <__udivdi3>
  80024e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800252:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025d:	89 fa                	mov    %edi,%edx
  80025f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800262:	e8 89 ff ff ff       	call   8001f0 <printnum>
  800267:	eb 0f                	jmp    800278 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800273:	4b                   	dec    %ebx
  800274:	85 db                	test   %ebx,%ebx
  800276:	7f f1                	jg     800269 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800280:	8b 45 10             	mov    0x10(%ebp),%eax
  800283:	89 44 24 08          	mov    %eax,0x8(%esp)
  800287:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028e:	00 
  80028f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	e8 a7 1b 00 00       	call   801e48 <__umoddi3>
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	0f be 80 b2 1f 80 00 	movsbl 0x801fb2(%eax),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b2:	83 c4 3c             	add    $0x3c,%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 08                	jae    80030c <sprintputch+0x18>
		*b->buf++ = ch;
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	88 0a                	mov    %cl,(%edx)
  800309:	42                   	inc    %edx
  80030a:	89 10                	mov    %edx,(%eax)
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800314:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031b:	8b 45 10             	mov    0x10(%ebp),%eax
  80031e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	e8 02 00 00 00       	call   800336 <vprintfmt>
	va_end(ap);
}
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 4c             	sub    $0x4c,%esp
  80033f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800342:	8b 75 10             	mov    0x10(%ebp),%esi
  800345:	eb 12                	jmp    800359 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800347:	85 c0                	test   %eax,%eax
  800349:	0f 84 8b 03 00 00    	je     8006da <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80034f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	0f b6 06             	movzbl (%esi),%eax
  80035c:	46                   	inc    %esi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e5                	jne    800347 <vprintfmt+0x11>
  800362:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800366:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80036d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800372:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	eb 26                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800387:	eb 1d                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800390:	eb 14                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800395:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039c:	eb 08                	jmp    8003a6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	0f b6 06             	movzbl (%esi),%eax
  8003a9:	8d 56 01             	lea    0x1(%esi),%edx
  8003ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003af:	8a 16                	mov    (%esi),%dl
  8003b1:	83 ea 23             	sub    $0x23,%edx
  8003b4:	80 fa 55             	cmp    $0x55,%dl
  8003b7:	0f 87 01 03 00 00    	ja     8006be <vprintfmt+0x388>
  8003bd:	0f b6 d2             	movzbl %dl,%edx
  8003c0:	ff 24 95 00 21 80 00 	jmp    *0x802100(,%edx,4)
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ca:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003d2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003d6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003dc:	83 fa 09             	cmp    $0x9,%edx
  8003df:	77 2a                	ja     80040b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e2:	eb eb                	jmp    8003cf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f2:	eb 17                	jmp    80040b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f8:	78 98                	js     800392 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fd:	eb a7                	jmp    8003a6 <vprintfmt+0x70>
  8003ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800409:	eb 9b                	jmp    8003a6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80040b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040f:	79 95                	jns    8003a6 <vprintfmt+0x70>
  800411:	eb 8b                	jmp    80039e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800413:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800417:	eb 8d                	jmp    8003a6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800426:	8b 00                	mov    (%eax),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800431:	e9 23 ff ff ff       	jmp    800359 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	79 02                	jns    800447 <vprintfmt+0x111>
  800445:	f7 d8                	neg    %eax
  800447:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 0f             	cmp    $0xf,%eax
  80044c:	7f 0b                	jg     800459 <vprintfmt+0x123>
  80044e:	8b 04 85 60 22 80 00 	mov    0x802260(,%eax,4),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	75 23                	jne    80047c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800459:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045d:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  800464:	00 
  800465:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 9a fe ff ff       	call   80030e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 dd fe ff ff       	jmp    800359 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80047c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800480:	c7 44 24 08 d2 23 80 	movl   $0x8023d2,0x8(%esp)
  800487:	00 
  800488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048c:	8b 55 08             	mov    0x8(%ebp),%edx
  80048f:	89 14 24             	mov    %edx,(%esp)
  800492:	e8 77 fe ff ff       	call   80030e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049a:	e9 ba fe ff ff       	jmp    800359 <vprintfmt+0x23>
  80049f:	89 f9                	mov    %edi,%ecx
  8004a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 30                	mov    (%eax),%esi
  8004b2:	85 f6                	test   %esi,%esi
  8004b4:	75 05                	jne    8004bb <vprintfmt+0x185>
				p = "(null)";
  8004b6:	be c3 1f 80 00       	mov    $0x801fc3,%esi
			if (width > 0 && padc != '-')
  8004bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bf:	0f 8e 84 00 00 00    	jle    800549 <vprintfmt+0x213>
  8004c5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c9:	74 7e                	je     800549 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004cf:	89 34 24             	mov    %esi,(%esp)
  8004d2:	e8 ab 02 00 00       	call   800782 <strnlen>
  8004d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004e9:	89 de                	mov    %ebx,%esi
  8004eb:	89 d3                	mov    %edx,%ebx
  8004ed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	eb 0b                	jmp    8004fc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f5:	89 3c 24             	mov    %edi,(%esp)
  8004f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	4b                   	dec    %ebx
  8004fc:	85 db                	test   %ebx,%ebx
  8004fe:	7f f1                	jg     8004f1 <vprintfmt+0x1bb>
  800500:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800503:	89 f3                	mov    %esi,%ebx
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 05                	jns    800514 <vprintfmt+0x1de>
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800517:	29 c2                	sub    %eax,%edx
  800519:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051c:	eb 2b                	jmp    800549 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800522:	74 18                	je     80053c <vprintfmt+0x206>
  800524:	8d 50 e0             	lea    -0x20(%eax),%edx
  800527:	83 fa 5e             	cmp    $0x5e,%edx
  80052a:	76 10                	jbe    80053c <vprintfmt+0x206>
					putch('?', putdat);
  80052c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800530:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	eb 0a                	jmp    800546 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80053c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	ff 4d e4             	decl   -0x1c(%ebp)
  800549:	0f be 06             	movsbl (%esi),%eax
  80054c:	46                   	inc    %esi
  80054d:	85 c0                	test   %eax,%eax
  80054f:	74 21                	je     800572 <vprintfmt+0x23c>
  800551:	85 ff                	test   %edi,%edi
  800553:	78 c9                	js     80051e <vprintfmt+0x1e8>
  800555:	4f                   	dec    %edi
  800556:	79 c6                	jns    80051e <vprintfmt+0x1e8>
  800558:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055b:	89 de                	mov    %ebx,%esi
  80055d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800560:	eb 18                	jmp    80057a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800562:	89 74 24 04          	mov    %esi,0x4(%esp)
  800566:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056f:	4b                   	dec    %ebx
  800570:	eb 08                	jmp    80057a <vprintfmt+0x244>
  800572:	8b 7d 08             	mov    0x8(%ebp),%edi
  800575:	89 de                	mov    %ebx,%esi
  800577:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80057a:	85 db                	test   %ebx,%ebx
  80057c:	7f e4                	jg     800562 <vprintfmt+0x22c>
  80057e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800581:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800586:	e9 ce fd ff ff       	jmp    800359 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058b:	83 f9 01             	cmp    $0x1,%ecx
  80058e:	7e 10                	jle    8005a0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 08             	lea    0x8(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	8b 78 04             	mov    0x4(%eax),%edi
  80059e:	eb 26                	jmp    8005c6 <vprintfmt+0x290>
	else if (lflag)
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	74 12                	je     8005b6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
  8005af:	89 f7                	mov    %esi,%edi
  8005b1:	c1 ff 1f             	sar    $0x1f,%edi
  8005b4:	eb 10                	jmp    8005c6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 30                	mov    (%eax),%esi
  8005c1:	89 f7                	mov    %esi,%edi
  8005c3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	78 0a                	js     8005d4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 ac 00 00 00       	jmp    800680 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e2:	f7 de                	neg    %esi
  8005e4:	83 d7 00             	adc    $0x0,%edi
  8005e7:	f7 df                	neg    %edi
			}
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	e9 8d 00 00 00       	jmp    800680 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f3:	89 ca                	mov    %ecx,%edx
  8005f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f8:	e8 bd fc ff ff       	call   8002ba <getuint>
  8005fd:	89 c6                	mov    %eax,%esi
  8005ff:	89 d7                	mov    %edx,%edi
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800606:	eb 78                	jmp    800680 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800616:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800621:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800635:	e9 1f fd ff ff       	jmp    800359 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80063a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 30                	mov    (%eax),%esi
  800661:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800666:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80066b:	eb 13                	jmp    800680 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066d:	89 ca                	mov    %ecx,%edx
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 43 fc ff ff       	call   8002ba <getuint>
  800677:	89 c6                	mov    %eax,%esi
  800679:	89 d7                	mov    %edx,%edi
			base = 16;
  80067b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800680:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800684:	89 54 24 10          	mov    %edx,0x10(%esp)
  800688:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800693:	89 34 24             	mov    %esi,(%esp)
  800696:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069a:	89 da                	mov    %ebx,%edx
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	e8 4c fb ff ff       	call   8001f0 <printnum>
			break;
  8006a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a7:	e9 ad fc ff ff       	jmp    800359 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b9:	e9 9b fc ff ff       	jmp    800359 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cc:	eb 01                	jmp    8006cf <vprintfmt+0x399>
  8006ce:	4e                   	dec    %esi
  8006cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d3:	75 f9                	jne    8006ce <vprintfmt+0x398>
  8006d5:	e9 7f fc ff ff       	jmp    800359 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006da:	83 c4 4c             	add    $0x4c,%esp
  8006dd:	5b                   	pop    %ebx
  8006de:	5e                   	pop    %esi
  8006df:	5f                   	pop    %edi
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 28             	sub    $0x28,%esp
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	74 30                	je     800733 <vsnprintf+0x51>
  800703:	85 d2                	test   %edx,%edx
  800705:	7e 33                	jle    80073a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070e:	8b 45 10             	mov    0x10(%ebp),%eax
  800711:	89 44 24 08          	mov    %eax,0x8(%esp)
  800715:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071c:	c7 04 24 f4 02 80 00 	movl   $0x8002f4,(%esp)
  800723:	e8 0e fc ff ff       	call   800336 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	eb 0c                	jmp    80073f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800738:	eb 05                	jmp    80073f <vsnprintf+0x5d>
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8b 45 0c             	mov    0xc(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	e8 7b ff ff ff       	call   8006e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    
  800769:	00 00                	add    %al,(%eax)
	...

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 01                	jmp    80077a <strlen+0xe>
		n++;
  800779:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	75 f9                	jne    800779 <strlen+0xd>
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 01                	jmp    800793 <strnlen+0x11>
		n++;
  800792:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	39 d0                	cmp    %edx,%eax
  800795:	74 06                	je     80079d <strnlen+0x1b>
  800797:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079b:	75 f5                	jne    800792 <strnlen+0x10>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b4:	42                   	inc    %edx
  8007b5:	84 c9                	test   %cl,%cl
  8007b7:	75 f5                	jne    8007ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c6:	89 1c 24             	mov    %ebx,(%esp)
  8007c9:	e8 9e ff ff ff       	call   80076c <strlen>
	strcpy(dst + len, src);
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d5:	01 d8                	add    %ebx,%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 c0 ff ff ff       	call   80079f <strcpy>
	return dst;
}
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	83 c4 08             	add    $0x8,%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fa:	eb 0c                	jmp    800808 <strncpy+0x21>
		*dst++ = *src;
  8007fc:	8a 1a                	mov    (%edx),%bl
  8007fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800801:	80 3a 01             	cmpb   $0x1,(%edx)
  800804:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	41                   	inc    %ecx
  800808:	39 f1                	cmp    %esi,%ecx
  80080a:	75 f0                	jne    8007fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	56                   	push   %esi
  800814:	53                   	push   %ebx
  800815:	8b 75 08             	mov    0x8(%ebp),%esi
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081e:	85 d2                	test   %edx,%edx
  800820:	75 0a                	jne    80082c <strlcpy+0x1c>
  800822:	89 f0                	mov    %esi,%eax
  800824:	eb 1a                	jmp    800840 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800826:	88 18                	mov    %bl,(%eax)
  800828:	40                   	inc    %eax
  800829:	41                   	inc    %ecx
  80082a:	eb 02                	jmp    80082e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80082e:	4a                   	dec    %edx
  80082f:	74 0a                	je     80083b <strlcpy+0x2b>
  800831:	8a 19                	mov    (%ecx),%bl
  800833:	84 db                	test   %bl,%bl
  800835:	75 ef                	jne    800826 <strlcpy+0x16>
  800837:	89 c2                	mov    %eax,%edx
  800839:	eb 02                	jmp    80083d <strlcpy+0x2d>
  80083b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80083d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800840:	29 f0                	sub    %esi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084f:	eb 02                	jmp    800853 <strcmp+0xd>
		p++, q++;
  800851:	41                   	inc    %ecx
  800852:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800853:	8a 01                	mov    (%ecx),%al
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x17>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 f4                	je     800851 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800871:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800874:	eb 03                	jmp    800879 <strncmp+0x12>
		n--, p++, q++;
  800876:	4a                   	dec    %edx
  800877:	40                   	inc    %eax
  800878:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 14                	je     800891 <strncmp+0x2a>
  80087d:	8a 18                	mov    (%eax),%bl
  80087f:	84 db                	test   %bl,%bl
  800881:	74 04                	je     800887 <strncmp+0x20>
  800883:	3a 19                	cmp    (%ecx),%bl
  800885:	74 ef                	je     800876 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 11             	movzbl (%ecx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb 05                	jmp    800896 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a2:	eb 05                	jmp    8008a9 <strchr+0x10>
		if (*s == c)
  8008a4:	38 ca                	cmp    %cl,%dl
  8008a6:	74 0c                	je     8008b4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a8:	40                   	inc    %eax
  8008a9:	8a 10                	mov    (%eax),%dl
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f5                	jne    8008a4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bf:	eb 05                	jmp    8008c6 <strfind+0x10>
		if (*s == c)
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	74 07                	je     8008cc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c5:	40                   	inc    %eax
  8008c6:	8a 10                	mov    (%eax),%dl
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	75 f5                	jne    8008c1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	74 30                	je     800911 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e7:	75 25                	jne    80090e <memset+0x40>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 20                	jne    80090e <memset+0x40>
		c &= 0xFF;
  8008ee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f1:	89 d3                	mov    %edx,%ebx
  8008f3:	c1 e3 08             	shl    $0x8,%ebx
  8008f6:	89 d6                	mov    %edx,%esi
  8008f8:	c1 e6 18             	shl    $0x18,%esi
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	c1 e0 10             	shl    $0x10,%eax
  800900:	09 f0                	or     %esi,%eax
  800902:	09 d0                	or     %edx,%eax
  800904:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800906:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800909:	fc                   	cld    
  80090a:	f3 ab                	rep stos %eax,%es:(%edi)
  80090c:	eb 03                	jmp    800911 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090e:	fc                   	cld    
  80090f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800911:	89 f8                	mov    %edi,%eax
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	57                   	push   %edi
  80091c:	56                   	push   %esi
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 75 0c             	mov    0xc(%ebp),%esi
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800926:	39 c6                	cmp    %eax,%esi
  800928:	73 34                	jae    80095e <memmove+0x46>
  80092a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092d:	39 d0                	cmp    %edx,%eax
  80092f:	73 2d                	jae    80095e <memmove+0x46>
		s += n;
		d += n;
  800931:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	f6 c2 03             	test   $0x3,%dl
  800937:	75 1b                	jne    800954 <memmove+0x3c>
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 13                	jne    800954 <memmove+0x3c>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0e                	jne    800954 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800946:	83 ef 04             	sub    $0x4,%edi
  800949:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094f:	fd                   	std    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 07                	jmp    80095b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800954:	4f                   	dec    %edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 20                	jmp    80097e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x61>
  800966:	a8 03                	test   $0x3,%al
  800968:	75 0f                	jne    800979 <memmove+0x61>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0a                	jne    800979 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800988:	8b 45 10             	mov    0x10(%ebp),%eax
  80098b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800992:	89 44 24 04          	mov    %eax,0x4(%esp)
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	e8 77 ff ff ff       	call   800918 <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	eb 16                	jmp    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
  8009b9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009bc:	42                   	inc    %edx
  8009bd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009c1:	38 c8                	cmp    %cl,%al
  8009c3:	74 0a                	je     8009cf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009c5:	0f b6 c0             	movzbl %al,%eax
  8009c8:	0f b6 c9             	movzbl %cl,%ecx
  8009cb:	29 c8                	sub    %ecx,%eax
  8009cd:	eb 09                	jmp    8009d8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 da                	cmp    %ebx,%edx
  8009d1:	75 e6                	jne    8009b9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5f                   	pop    %edi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009eb:	eb 05                	jmp    8009f2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	74 05                	je     8009f6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f1:	40                   	inc    %eax
  8009f2:	39 d0                	cmp    %edx,%eax
  8009f4:	72 f7                	jb     8009ed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a04:	eb 01                	jmp    800a07 <strtol+0xf>
		s++;
  800a06:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a07:	8a 02                	mov    (%edx),%al
  800a09:	3c 20                	cmp    $0x20,%al
  800a0b:	74 f9                	je     800a06 <strtol+0xe>
  800a0d:	3c 09                	cmp    $0x9,%al
  800a0f:	74 f5                	je     800a06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a11:	3c 2b                	cmp    $0x2b,%al
  800a13:	75 08                	jne    800a1d <strtol+0x25>
		s++;
  800a15:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a16:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1b:	eb 13                	jmp    800a30 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1d:	3c 2d                	cmp    $0x2d,%al
  800a1f:	75 0a                	jne    800a2b <strtol+0x33>
		s++, neg = 1;
  800a21:	8d 52 01             	lea    0x1(%edx),%edx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi
  800a29:	eb 05                	jmp    800a30 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	74 05                	je     800a39 <strtol+0x41>
  800a34:	83 fb 10             	cmp    $0x10,%ebx
  800a37:	75 28                	jne    800a61 <strtol+0x69>
  800a39:	8a 02                	mov    (%edx),%al
  800a3b:	3c 30                	cmp    $0x30,%al
  800a3d:	75 10                	jne    800a4f <strtol+0x57>
  800a3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a43:	75 0a                	jne    800a4f <strtol+0x57>
		s += 2, base = 16;
  800a45:	83 c2 02             	add    $0x2,%edx
  800a48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4d:	eb 12                	jmp    800a61 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	75 0e                	jne    800a61 <strtol+0x69>
  800a53:	3c 30                	cmp    $0x30,%al
  800a55:	75 05                	jne    800a5c <strtol+0x64>
		s++, base = 8;
  800a57:	42                   	inc    %edx
  800a58:	b3 08                	mov    $0x8,%bl
  800a5a:	eb 05                	jmp    800a61 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
  800a66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a68:	8a 0a                	mov    (%edx),%cl
  800a6a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a6d:	80 fb 09             	cmp    $0x9,%bl
  800a70:	77 08                	ja     800a7a <strtol+0x82>
			dig = *s - '0';
  800a72:	0f be c9             	movsbl %cl,%ecx
  800a75:	83 e9 30             	sub    $0x30,%ecx
  800a78:	eb 1e                	jmp    800a98 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a7a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a7d:	80 fb 19             	cmp    $0x19,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 57             	sub    $0x57,%ecx
  800a88:	eb 0e                	jmp    800a98 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a8a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 12                	ja     800aa4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a98:	39 f1                	cmp    %esi,%ecx
  800a9a:	7d 0c                	jge    800aa8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a9c:	42                   	inc    %edx
  800a9d:	0f af c6             	imul   %esi,%eax
  800aa0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aa2:	eb c4                	jmp    800a68 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aa4:	89 c1                	mov    %eax,%ecx
  800aa6:	eb 02                	jmp    800aaa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aaa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aae:	74 05                	je     800ab5 <strtol+0xbd>
		*endptr = (char *) s;
  800ab0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ab5:	85 ff                	test   %edi,%edi
  800ab7:	74 04                	je     800abd <strtol+0xc5>
  800ab9:	89 c8                	mov    %ecx,%eax
  800abb:	f7 d8                	neg    %eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    
	...

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 28                	jle    800b4b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b27:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b2e:	00 
  800b2f:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800b36:	00 
  800b37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b3e:	00 
  800b3f:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800b46:	e8 41 11 00 00       	call   801c8c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4b:	83 c4 2c             	add    $0x2c,%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_yield>:

void
sys_yield(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	be 00 00 00 00       	mov    $0x0,%esi
  800b9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 f7                	mov    %esi,%edi
  800baf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 28                	jle    800bdd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc0:	00 
  800bc1:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd0:	00 
  800bd1:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800bd8:	e8 af 10 00 00       	call   801c8c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdd:	83 c4 2c             	add    $0x2c,%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	7e 28                	jle    800c30 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c13:	00 
  800c14:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c23:	00 
  800c24:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c2b:	e8 5c 10 00 00       	call   801c8c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c30:	83 c4 2c             	add    $0x2c,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c46:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 df                	mov    %ebx,%edi
  800c53:	89 de                	mov    %ebx,%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 28                	jle    800c83 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c66:	00 
  800c67:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c7e:	e8 09 10 00 00       	call   801c8c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c83:	83 c4 2c             	add    $0x2c,%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 28                	jle    800cd6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cb9:	00 
  800cba:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc9:	00 
  800cca:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800cd1:	e8 b6 0f 00 00       	call   801c8c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd6:	83 c4 2c             	add    $0x2c,%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 28                	jle    800d29 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d05:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d14:	00 
  800d15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1c:	00 
  800d1d:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d24:	e8 63 0f 00 00       	call   801c8c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d29:	83 c4 2c             	add    $0x2c,%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7e 28                	jle    800d7c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d58:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d5f:	00 
  800d60:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d67:	00 
  800d68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6f:	00 
  800d70:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d77:	e8 10 0f 00 00       	call   801c8c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7c:	83 c4 2c             	add    $0x2c,%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	be 00 00 00 00       	mov    $0x0,%esi
  800d8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 cb                	mov    %ecx,%ebx
  800dbf:	89 cf                	mov    %ecx,%edi
  800dc1:	89 ce                	mov    %ecx,%esi
  800dc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 28                	jle    800df1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dd4:	00 
  800dd5:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800dec:	e8 9b 0e 00 00       	call   801c8c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df1:	83 c4 2c             	add    $0x2c,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	00 00                	add    %al,(%eax)
	...

00800dfc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 10             	sub    $0x10,%esp
  800e04:	8b 75 08             	mov    0x8(%ebp),%esi
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	75 05                	jne    800e16 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  800e11:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  800e16:	89 04 24             	mov    %eax,(%esp)
  800e19:	e8 89 ff ff ff       	call   800da7 <sys_ipc_recv>
	if (!err) {
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	75 26                	jne    800e48 <ipc_recv+0x4c>
		if (from_env_store) {
  800e22:	85 f6                	test   %esi,%esi
  800e24:	74 0a                	je     800e30 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  800e26:	a1 04 40 80 00       	mov    0x804004,%eax
  800e2b:	8b 40 74             	mov    0x74(%eax),%eax
  800e2e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  800e30:	85 db                	test   %ebx,%ebx
  800e32:	74 0a                	je     800e3e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  800e34:	a1 04 40 80 00       	mov    0x804004,%eax
  800e39:	8b 40 78             	mov    0x78(%eax),%eax
  800e3c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  800e3e:	a1 04 40 80 00       	mov    0x804004,%eax
  800e43:	8b 40 70             	mov    0x70(%eax),%eax
  800e46:	eb 14                	jmp    800e5c <ipc_recv+0x60>
	}
	if (from_env_store) {
  800e48:	85 f6                	test   %esi,%esi
  800e4a:	74 06                	je     800e52 <ipc_recv+0x56>
		*from_env_store = 0;
  800e4c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  800e52:	85 db                	test   %ebx,%ebx
  800e54:	74 06                	je     800e5c <ipc_recv+0x60>
		*perm_store = 0;
  800e56:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 1c             	sub    $0x1c,%esp
  800e6c:	8b 75 10             	mov    0x10(%ebp),%esi
  800e6f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  800e72:	85 f6                	test   %esi,%esi
  800e74:	75 05                	jne    800e7b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  800e76:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  800e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e7f:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 ef fe ff ff       	call   800d84 <sys_ipc_try_send>
  800e95:	89 c3                	mov    %eax,%ebx
		sys_yield();
  800e97:	e8 d6 fc ff ff       	call   800b72 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  800e9c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  800e9f:	74 da                	je     800e7b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  800ea1:	85 db                	test   %ebx,%ebx
  800ea3:	74 20                	je     800ec5 <ipc_send+0x62>
		panic("send fail: %e", err);
  800ea5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ea9:	c7 44 24 08 ea 22 80 	movl   $0x8022ea,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 f8 22 80 00 	movl   $0x8022f8,(%esp)
  800ec0:	e8 c7 0d 00 00       	call   801c8c <_panic>
	}
	return;
}
  800ec5:	83 c4 1c             	add    $0x1c,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	53                   	push   %ebx
  800ed1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ed9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800ee0:	89 c2                	mov    %eax,%edx
  800ee2:	c1 e2 07             	shl    $0x7,%edx
  800ee5:	29 ca                	sub    %ecx,%edx
  800ee7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800eed:	8b 52 50             	mov    0x50(%edx),%edx
  800ef0:	39 da                	cmp    %ebx,%edx
  800ef2:	75 0f                	jne    800f03 <ipc_find_env+0x36>
			return envs[i].env_id;
  800ef4:	c1 e0 07             	shl    $0x7,%eax
  800ef7:	29 c8                	sub    %ecx,%eax
  800ef9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800efe:	8b 40 40             	mov    0x40(%eax),%eax
  800f01:	eb 0c                	jmp    800f0f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f03:	40                   	inc    %eax
  800f04:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f09:	75 ce                	jne    800ed9 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f0b:	66 b8 00 00          	mov    $0x0,%ax
}
  800f0f:	5b                   	pop    %ebx
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
	...

00800f14 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f1f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	89 04 24             	mov    %eax,(%esp)
  800f30:	e8 df ff ff ff       	call   800f14 <fd2num>
  800f35:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f3a:	c1 e0 0c             	shl    $0xc,%eax
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	53                   	push   %ebx
  800f43:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f46:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f4b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4d:	89 c2                	mov    %eax,%edx
  800f4f:	c1 ea 16             	shr    $0x16,%edx
  800f52:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f59:	f6 c2 01             	test   $0x1,%dl
  800f5c:	74 11                	je     800f6f <fd_alloc+0x30>
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	c1 ea 0c             	shr    $0xc,%edx
  800f63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	75 09                	jne    800f78 <fd_alloc+0x39>
			*fd_store = fd;
  800f6f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	eb 17                	jmp    800f8f <fd_alloc+0x50>
  800f78:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f7d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f82:	75 c7                	jne    800f4b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f8a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f8f:	5b                   	pop    %ebx
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f98:	83 f8 1f             	cmp    $0x1f,%eax
  800f9b:	77 36                	ja     800fd3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f9d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fa2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa5:	89 c2                	mov    %eax,%edx
  800fa7:	c1 ea 16             	shr    $0x16,%edx
  800faa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb1:	f6 c2 01             	test   $0x1,%dl
  800fb4:	74 24                	je     800fda <fd_lookup+0x48>
  800fb6:	89 c2                	mov    %eax,%edx
  800fb8:	c1 ea 0c             	shr    $0xc,%edx
  800fbb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc2:	f6 c2 01             	test   $0x1,%dl
  800fc5:	74 1a                	je     800fe1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fca:	89 02                	mov    %eax,(%edx)
	return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	eb 13                	jmp    800fe6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd8:	eb 0c                	jmp    800fe6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fdf:	eb 05                	jmp    800fe6 <fd_lookup+0x54>
  800fe1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	53                   	push   %ebx
  800fec:	83 ec 14             	sub    $0x14,%esp
  800fef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffa:	eb 0e                	jmp    80100a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ffc:	39 08                	cmp    %ecx,(%eax)
  800ffe:	75 09                	jne    801009 <dev_lookup+0x21>
			*dev = devtab[i];
  801000:	89 03                	mov    %eax,(%ebx)
			return 0;
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
  801007:	eb 33                	jmp    80103c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801009:	42                   	inc    %edx
  80100a:	8b 04 95 80 23 80 00 	mov    0x802380(,%edx,4),%eax
  801011:	85 c0                	test   %eax,%eax
  801013:	75 e7                	jne    800ffc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801015:	a1 04 40 80 00       	mov    0x804004,%eax
  80101a:	8b 40 48             	mov    0x48(%eax),%eax
  80101d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801021:	89 44 24 04          	mov    %eax,0x4(%esp)
  801025:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  80102c:	e8 a3 f1 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801031:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801037:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103c:	83 c4 14             	add    $0x14,%esp
  80103f:	5b                   	pop    %ebx
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 30             	sub    $0x30,%esp
  80104a:	8b 75 08             	mov    0x8(%ebp),%esi
  80104d:	8a 45 0c             	mov    0xc(%ebp),%al
  801050:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801053:	89 34 24             	mov    %esi,(%esp)
  801056:	e8 b9 fe ff ff       	call   800f14 <fd2num>
  80105b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80105e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801062:	89 04 24             	mov    %eax,(%esp)
  801065:	e8 28 ff ff ff       	call   800f92 <fd_lookup>
  80106a:	89 c3                	mov    %eax,%ebx
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 05                	js     801075 <fd_close+0x33>
	    || fd != fd2)
  801070:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801073:	74 0d                	je     801082 <fd_close+0x40>
		return (must_exist ? r : 0);
  801075:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801079:	75 46                	jne    8010c1 <fd_close+0x7f>
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801080:	eb 3f                	jmp    8010c1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801082:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801085:	89 44 24 04          	mov    %eax,0x4(%esp)
  801089:	8b 06                	mov    (%esi),%eax
  80108b:	89 04 24             	mov    %eax,(%esp)
  80108e:	e8 55 ff ff ff       	call   800fe8 <dev_lookup>
  801093:	89 c3                	mov    %eax,%ebx
  801095:	85 c0                	test   %eax,%eax
  801097:	78 18                	js     8010b1 <fd_close+0x6f>
		if (dev->dev_close)
  801099:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109c:	8b 40 10             	mov    0x10(%eax),%eax
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	74 09                	je     8010ac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010a3:	89 34 24             	mov    %esi,(%esp)
  8010a6:	ff d0                	call   *%eax
  8010a8:	89 c3                	mov    %eax,%ebx
  8010aa:	eb 05                	jmp    8010b1 <fd_close+0x6f>
		else
			r = 0;
  8010ac:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bc:	e8 77 fb ff ff       	call   800c38 <sys_page_unmap>
	return r;
}
  8010c1:	89 d8                	mov    %ebx,%eax
  8010c3:	83 c4 30             	add    $0x30,%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	89 04 24             	mov    %eax,(%esp)
  8010dd:	e8 b0 fe ff ff       	call   800f92 <fd_lookup>
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	78 13                	js     8010f9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ed:	00 
  8010ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f1:	89 04 24             	mov    %eax,(%esp)
  8010f4:	e8 49 ff ff ff       	call   801042 <fd_close>
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <close_all>:

void
close_all(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801102:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801107:	89 1c 24             	mov    %ebx,(%esp)
  80110a:	e8 bb ff ff ff       	call   8010ca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80110f:	43                   	inc    %ebx
  801110:	83 fb 20             	cmp    $0x20,%ebx
  801113:	75 f2                	jne    801107 <close_all+0xc>
		close(i);
}
  801115:	83 c4 14             	add    $0x14,%esp
  801118:	5b                   	pop    %ebx
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 4c             	sub    $0x4c,%esp
  801124:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801127:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80112a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	89 04 24             	mov    %eax,(%esp)
  801134:	e8 59 fe ff ff       	call   800f92 <fd_lookup>
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	85 c0                	test   %eax,%eax
  80113d:	0f 88 e1 00 00 00    	js     801224 <dup+0x109>
		return r;
	close(newfdnum);
  801143:	89 3c 24             	mov    %edi,(%esp)
  801146:	e8 7f ff ff ff       	call   8010ca <close>

	newfd = INDEX2FD(newfdnum);
  80114b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801151:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 c5 fd ff ff       	call   800f24 <fd2data>
  80115f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801161:	89 34 24             	mov    %esi,(%esp)
  801164:	e8 bb fd ff ff       	call   800f24 <fd2data>
  801169:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80116c:	89 d8                	mov    %ebx,%eax
  80116e:	c1 e8 16             	shr    $0x16,%eax
  801171:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801178:	a8 01                	test   $0x1,%al
  80117a:	74 46                	je     8011c2 <dup+0xa7>
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	c1 e8 0c             	shr    $0xc,%eax
  801181:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801188:	f6 c2 01             	test   $0x1,%dl
  80118b:	74 35                	je     8011c2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80118d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801194:	25 07 0e 00 00       	and    $0xe07,%eax
  801199:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ab:	00 
  8011ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b7:	e8 29 fa ff ff       	call   800be5 <sys_page_map>
  8011bc:	89 c3                	mov    %eax,%ebx
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 3b                	js     8011fd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	c1 ea 0c             	shr    $0xc,%edx
  8011ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e6:	00 
  8011e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f2:	e8 ee f9 ff ff       	call   800be5 <sys_page_map>
  8011f7:	89 c3                	mov    %eax,%ebx
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	79 25                	jns    801222 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801201:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801208:	e8 2b fa ff ff       	call   800c38 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801210:	89 44 24 04          	mov    %eax,0x4(%esp)
  801214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121b:	e8 18 fa ff ff       	call   800c38 <sys_page_unmap>
	return r;
  801220:	eb 02                	jmp    801224 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801222:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801224:	89 d8                	mov    %ebx,%eax
  801226:	83 c4 4c             	add    $0x4c,%esp
  801229:	5b                   	pop    %ebx
  80122a:	5e                   	pop    %esi
  80122b:	5f                   	pop    %edi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	53                   	push   %ebx
  801232:	83 ec 24             	sub    $0x24,%esp
  801235:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801238:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123f:	89 1c 24             	mov    %ebx,(%esp)
  801242:	e8 4b fd ff ff       	call   800f92 <fd_lookup>
  801247:	85 c0                	test   %eax,%eax
  801249:	78 6d                	js     8012b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801255:	8b 00                	mov    (%eax),%eax
  801257:	89 04 24             	mov    %eax,(%esp)
  80125a:	e8 89 fd ff ff       	call   800fe8 <dev_lookup>
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 55                	js     8012b8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801266:	8b 50 08             	mov    0x8(%eax),%edx
  801269:	83 e2 03             	and    $0x3,%edx
  80126c:	83 fa 01             	cmp    $0x1,%edx
  80126f:	75 23                	jne    801294 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801271:	a1 04 40 80 00       	mov    0x804004,%eax
  801276:	8b 40 48             	mov    0x48(%eax),%eax
  801279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80127d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801281:	c7 04 24 45 23 80 00 	movl   $0x802345,(%esp)
  801288:	e8 47 ef ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801292:	eb 24                	jmp    8012b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 08             	mov    0x8(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 15                	je     8012b3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80129e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	ff d2                	call   *%edx
  8012b1:	eb 05                	jmp    8012b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012b8:	83 c4 24             	add    $0x24,%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d2:	eb 23                	jmp    8012f7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d4:	89 f0                	mov    %esi,%eax
  8012d6:	29 d8                	sub    %ebx,%eax
  8012d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012df:	01 d8                	add    %ebx,%eax
  8012e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e5:	89 3c 24             	mov    %edi,(%esp)
  8012e8:	e8 41 ff ff ff       	call   80122e <read>
		if (m < 0)
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 10                	js     801301 <readn+0x43>
			return m;
		if (m == 0)
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	74 0a                	je     8012ff <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f5:	01 c3                	add    %eax,%ebx
  8012f7:	39 f3                	cmp    %esi,%ebx
  8012f9:	72 d9                	jb     8012d4 <readn+0x16>
  8012fb:	89 d8                	mov    %ebx,%eax
  8012fd:	eb 02                	jmp    801301 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012ff:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 24             	sub    $0x24,%esp
  801310:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131a:	89 1c 24             	mov    %ebx,(%esp)
  80131d:	e8 70 fc ff ff       	call   800f92 <fd_lookup>
  801322:	85 c0                	test   %eax,%eax
  801324:	78 68                	js     80138e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	8b 00                	mov    (%eax),%eax
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 ae fc ff ff       	call   800fe8 <dev_lookup>
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 50                	js     80138e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801341:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801345:	75 23                	jne    80136a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801347:	a1 04 40 80 00       	mov    0x804004,%eax
  80134c:	8b 40 48             	mov    0x48(%eax),%eax
  80134f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801353:	89 44 24 04          	mov    %eax,0x4(%esp)
  801357:	c7 04 24 61 23 80 00 	movl   $0x802361,(%esp)
  80135e:	e8 71 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801368:	eb 24                	jmp    80138e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80136a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136d:	8b 52 0c             	mov    0xc(%edx),%edx
  801370:	85 d2                	test   %edx,%edx
  801372:	74 15                	je     801389 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801374:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801377:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	ff d2                	call   *%edx
  801387:	eb 05                	jmp    80138e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801389:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80138e:	83 c4 24             	add    $0x24,%esp
  801391:	5b                   	pop    %ebx
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <seek>:

int
seek(int fdnum, off_t offset)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80139a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80139d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	89 04 24             	mov    %eax,(%esp)
  8013a7:	e8 e6 fb ff ff       	call   800f92 <fd_lookup>
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 0e                	js     8013be <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 24             	sub    $0x24,%esp
  8013c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	89 1c 24             	mov    %ebx,(%esp)
  8013d4:	e8 b9 fb ff ff       	call   800f92 <fd_lookup>
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 61                	js     80143e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	8b 00                	mov    (%eax),%eax
  8013e9:	89 04 24             	mov    %eax,(%esp)
  8013ec:	e8 f7 fb ff ff       	call   800fe8 <dev_lookup>
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 49                	js     80143e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fc:	75 23                	jne    801421 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013fe:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801403:	8b 40 48             	mov    0x48(%eax),%eax
  801406:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80140a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140e:	c7 04 24 24 23 80 00 	movl   $0x802324,(%esp)
  801415:	e8 ba ed ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80141a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141f:	eb 1d                	jmp    80143e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801421:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801424:	8b 52 18             	mov    0x18(%edx),%edx
  801427:	85 d2                	test   %edx,%edx
  801429:	74 0e                	je     801439 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80142b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801432:	89 04 24             	mov    %eax,(%esp)
  801435:	ff d2                	call   *%edx
  801437:	eb 05                	jmp    80143e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801439:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80143e:	83 c4 24             	add    $0x24,%esp
  801441:	5b                   	pop    %ebx
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	53                   	push   %ebx
  801448:	83 ec 24             	sub    $0x24,%esp
  80144b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801451:	89 44 24 04          	mov    %eax,0x4(%esp)
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	89 04 24             	mov    %eax,(%esp)
  80145b:	e8 32 fb ff ff       	call   800f92 <fd_lookup>
  801460:	85 c0                	test   %eax,%eax
  801462:	78 52                	js     8014b6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801464:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146e:	8b 00                	mov    (%eax),%eax
  801470:	89 04 24             	mov    %eax,(%esp)
  801473:	e8 70 fb ff ff       	call   800fe8 <dev_lookup>
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 3a                	js     8014b6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801483:	74 2c                	je     8014b1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801485:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801488:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80148f:	00 00 00 
	stat->st_isdir = 0;
  801492:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801499:	00 00 00 
	stat->st_dev = dev;
  80149c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a9:	89 14 24             	mov    %edx,(%esp)
  8014ac:	ff 50 14             	call   *0x14(%eax)
  8014af:	eb 05                	jmp    8014b6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014b6:	83 c4 24             	add    $0x24,%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014cb:	00 
  8014cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cf:	89 04 24             	mov    %eax,(%esp)
  8014d2:	e8 fe 01 00 00       	call   8016d5 <open>
  8014d7:	89 c3                	mov    %eax,%ebx
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 1b                	js     8014f8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e4:	89 1c 24             	mov    %ebx,(%esp)
  8014e7:	e8 58 ff ff ff       	call   801444 <fstat>
  8014ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ee:	89 1c 24             	mov    %ebx,(%esp)
  8014f1:	e8 d4 fb ff ff       	call   8010ca <close>
	return r;
  8014f6:	89 f3                	mov    %esi,%ebx
}
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5e                   	pop    %esi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
  801501:	00 00                	add    %al,(%eax)
	...

00801504 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	83 ec 10             	sub    $0x10,%esp
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801510:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801517:	75 11                	jne    80152a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801519:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801520:	e8 a8 f9 ff ff       	call   800ecd <ipc_find_env>
  801525:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80152a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801531:	00 
  801532:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801539:	00 
  80153a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153e:	a1 00 40 80 00       	mov    0x804000,%eax
  801543:	89 04 24             	mov    %eax,(%esp)
  801546:	e8 18 f9 ff ff       	call   800e63 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80154b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801552:	00 
  801553:	89 74 24 04          	mov    %esi,0x4(%esp)
  801557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80155e:	e8 99 f8 ff ff       	call   800dfc <ipc_recv>
}
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	8b 40 0c             	mov    0xc(%eax),%eax
  801576:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80157b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801583:	ba 00 00 00 00       	mov    $0x0,%edx
  801588:	b8 02 00 00 00       	mov    $0x2,%eax
  80158d:	e8 72 ff ff ff       	call   801504 <fsipc>
}
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8015af:	e8 50 ff ff ff       	call   801504 <fsipc>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 14             	sub    $0x14,%esp
  8015bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d5:	e8 2a ff ff ff       	call   801504 <fsipc>
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 2b                	js     801609 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015de:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015e5:	00 
  8015e6:	89 1c 24             	mov    %ebx,(%esp)
  8015e9:	e8 b1 f1 ff ff       	call   80079f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8015f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8015fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801609:	83 c4 14             	add    $0x14,%esp
  80160c:	5b                   	pop    %ebx
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801615:	c7 44 24 08 90 23 80 	movl   $0x802390,0x8(%esp)
  80161c:	00 
  80161d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801624:	00 
  801625:	c7 04 24 ae 23 80 00 	movl   $0x8023ae,(%esp)
  80162c:	e8 5b 06 00 00       	call   801c8c <_panic>

00801631 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 10             	sub    $0x10,%esp
  801639:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 40 0c             	mov    0xc(%eax),%eax
  801642:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801647:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80164d:	ba 00 00 00 00       	mov    $0x0,%edx
  801652:	b8 03 00 00 00       	mov    $0x3,%eax
  801657:	e8 a8 fe ff ff       	call   801504 <fsipc>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 6a                	js     8016cc <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801662:	39 c6                	cmp    %eax,%esi
  801664:	73 24                	jae    80168a <devfile_read+0x59>
  801666:	c7 44 24 0c b9 23 80 	movl   $0x8023b9,0xc(%esp)
  80166d:	00 
  80166e:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801675:	00 
  801676:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80167d:	00 
  80167e:	c7 04 24 ae 23 80 00 	movl   $0x8023ae,(%esp)
  801685:	e8 02 06 00 00       	call   801c8c <_panic>
	assert(r <= PGSIZE);
  80168a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80168f:	7e 24                	jle    8016b5 <devfile_read+0x84>
  801691:	c7 44 24 0c d5 23 80 	movl   $0x8023d5,0xc(%esp)
  801698:	00 
  801699:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  8016a0:	00 
  8016a1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016a8:	00 
  8016a9:	c7 04 24 ae 23 80 00 	movl   $0x8023ae,(%esp)
  8016b0:	e8 d7 05 00 00       	call   801c8c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016b9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016c0:	00 
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 4c f2 ff ff       	call   800918 <memmove>
	return r;
}
  8016cc:	89 d8                	mov    %ebx,%eax
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 20             	sub    $0x20,%esp
  8016dd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016e0:	89 34 24             	mov    %esi,(%esp)
  8016e3:	e8 84 f0 ff ff       	call   80076c <strlen>
  8016e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016ed:	7f 60                	jg     80174f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	89 04 24             	mov    %eax,(%esp)
  8016f5:	e8 45 f8 ff ff       	call   800f3f <fd_alloc>
  8016fa:	89 c3                	mov    %eax,%ebx
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 54                	js     801754 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801700:	89 74 24 04          	mov    %esi,0x4(%esp)
  801704:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80170b:	e8 8f f0 ff ff       	call   80079f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801710:	8b 45 0c             	mov    0xc(%ebp),%eax
  801713:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801718:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171b:	b8 01 00 00 00       	mov    $0x1,%eax
  801720:	e8 df fd ff ff       	call   801504 <fsipc>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	85 c0                	test   %eax,%eax
  801729:	79 15                	jns    801740 <open+0x6b>
		fd_close(fd, 0);
  80172b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801732:	00 
  801733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 04 f9 ff ff       	call   801042 <fd_close>
		return r;
  80173e:	eb 14                	jmp    801754 <open+0x7f>
	}

	return fd2num(fd);
  801740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801743:	89 04 24             	mov    %eax,(%esp)
  801746:	e8 c9 f7 ff ff       	call   800f14 <fd2num>
  80174b:	89 c3                	mov    %eax,%ebx
  80174d:	eb 05                	jmp    801754 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80174f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801754:	89 d8                	mov    %ebx,%eax
  801756:	83 c4 20             	add    $0x20,%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	b8 08 00 00 00       	mov    $0x8,%eax
  80176d:	e8 92 fd ff ff       	call   801504 <fsipc>
}
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	56                   	push   %esi
  801778:	53                   	push   %ebx
  801779:	83 ec 10             	sub    $0x10,%esp
  80177c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	89 04 24             	mov    %eax,(%esp)
  801785:	e8 9a f7 ff ff       	call   800f24 <fd2data>
  80178a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80178c:	c7 44 24 04 e1 23 80 	movl   $0x8023e1,0x4(%esp)
  801793:	00 
  801794:	89 34 24             	mov    %esi,(%esp)
  801797:	e8 03 f0 ff ff       	call   80079f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80179c:	8b 43 04             	mov    0x4(%ebx),%eax
  80179f:	2b 03                	sub    (%ebx),%eax
  8017a1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8017a7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8017ae:	00 00 00 
	stat->st_dev = &devpipe;
  8017b1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8017b8:	30 80 00 
	return 0;
}
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 14             	sub    $0x14,%esp
  8017ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017dc:	e8 57 f4 ff ff       	call   800c38 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017e1:	89 1c 24             	mov    %ebx,(%esp)
  8017e4:	e8 3b f7 ff ff       	call   800f24 <fd2data>
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f4:	e8 3f f4 ff ff       	call   800c38 <sys_page_unmap>
}
  8017f9:	83 c4 14             	add    $0x14,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	57                   	push   %edi
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	83 ec 2c             	sub    $0x2c,%esp
  801808:	89 c7                	mov    %eax,%edi
  80180a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80180d:	a1 04 40 80 00       	mov    0x804004,%eax
  801812:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801815:	89 3c 24             	mov    %edi,(%esp)
  801818:	e8 c7 04 00 00       	call   801ce4 <pageref>
  80181d:	89 c6                	mov    %eax,%esi
  80181f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	e8 ba 04 00 00       	call   801ce4 <pageref>
  80182a:	39 c6                	cmp    %eax,%esi
  80182c:	0f 94 c0             	sete   %al
  80182f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801832:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801838:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80183b:	39 cb                	cmp    %ecx,%ebx
  80183d:	75 08                	jne    801847 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80183f:	83 c4 2c             	add    $0x2c,%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801847:	83 f8 01             	cmp    $0x1,%eax
  80184a:	75 c1                	jne    80180d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80184c:	8b 42 58             	mov    0x58(%edx),%eax
  80184f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801856:	00 
  801857:	89 44 24 08          	mov    %eax,0x8(%esp)
  80185b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185f:	c7 04 24 e8 23 80 00 	movl   $0x8023e8,(%esp)
  801866:	e8 69 e9 ff ff       	call   8001d4 <cprintf>
  80186b:	eb a0                	jmp    80180d <_pipeisclosed+0xe>

0080186d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	57                   	push   %edi
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
  801873:	83 ec 1c             	sub    $0x1c,%esp
  801876:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801879:	89 34 24             	mov    %esi,(%esp)
  80187c:	e8 a3 f6 ff ff       	call   800f24 <fd2data>
  801881:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801883:	bf 00 00 00 00       	mov    $0x0,%edi
  801888:	eb 3c                	jmp    8018c6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80188a:	89 da                	mov    %ebx,%edx
  80188c:	89 f0                	mov    %esi,%eax
  80188e:	e8 6c ff ff ff       	call   8017ff <_pipeisclosed>
  801893:	85 c0                	test   %eax,%eax
  801895:	75 38                	jne    8018cf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801897:	e8 d6 f2 ff ff       	call   800b72 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80189c:	8b 43 04             	mov    0x4(%ebx),%eax
  80189f:	8b 13                	mov    (%ebx),%edx
  8018a1:	83 c2 20             	add    $0x20,%edx
  8018a4:	39 d0                	cmp    %edx,%eax
  8018a6:	73 e2                	jae    80188a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ab:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018b6:	79 05                	jns    8018bd <devpipe_write+0x50>
  8018b8:	4a                   	dec    %edx
  8018b9:	83 ca e0             	or     $0xffffffe0,%edx
  8018bc:	42                   	inc    %edx
  8018bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018c1:	40                   	inc    %eax
  8018c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c5:	47                   	inc    %edi
  8018c6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018c9:	75 d1                	jne    80189c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018cb:	89 f8                	mov    %edi,%eax
  8018cd:	eb 05                	jmp    8018d4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018d4:	83 c4 1c             	add    $0x1c,%esp
  8018d7:	5b                   	pop    %ebx
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 1c             	sub    $0x1c,%esp
  8018e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018e8:	89 3c 24             	mov    %edi,(%esp)
  8018eb:	e8 34 f6 ff ff       	call   800f24 <fd2data>
  8018f0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f2:	be 00 00 00 00       	mov    $0x0,%esi
  8018f7:	eb 3a                	jmp    801933 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018f9:	85 f6                	test   %esi,%esi
  8018fb:	74 04                	je     801901 <devpipe_read+0x25>
				return i;
  8018fd:	89 f0                	mov    %esi,%eax
  8018ff:	eb 40                	jmp    801941 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801901:	89 da                	mov    %ebx,%edx
  801903:	89 f8                	mov    %edi,%eax
  801905:	e8 f5 fe ff ff       	call   8017ff <_pipeisclosed>
  80190a:	85 c0                	test   %eax,%eax
  80190c:	75 2e                	jne    80193c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80190e:	e8 5f f2 ff ff       	call   800b72 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801913:	8b 03                	mov    (%ebx),%eax
  801915:	3b 43 04             	cmp    0x4(%ebx),%eax
  801918:	74 df                	je     8018f9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80191a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80191f:	79 05                	jns    801926 <devpipe_read+0x4a>
  801921:	48                   	dec    %eax
  801922:	83 c8 e0             	or     $0xffffffe0,%eax
  801925:	40                   	inc    %eax
  801926:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80192a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801930:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801932:	46                   	inc    %esi
  801933:	3b 75 10             	cmp    0x10(%ebp),%esi
  801936:	75 db                	jne    801913 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801938:	89 f0                	mov    %esi,%eax
  80193a:	eb 05                	jmp    801941 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80193c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801941:	83 c4 1c             	add    $0x1c,%esp
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5f                   	pop    %edi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	57                   	push   %edi
  80194d:	56                   	push   %esi
  80194e:	53                   	push   %ebx
  80194f:	83 ec 3c             	sub    $0x3c,%esp
  801952:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801955:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801958:	89 04 24             	mov    %eax,(%esp)
  80195b:	e8 df f5 ff ff       	call   800f3f <fd_alloc>
  801960:	89 c3                	mov    %eax,%ebx
  801962:	85 c0                	test   %eax,%eax
  801964:	0f 88 45 01 00 00    	js     801aaf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801971:	00 
  801972:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801980:	e8 0c f2 ff ff       	call   800b91 <sys_page_alloc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 20 01 00 00    	js     801aaf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80198f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 a5 f5 ff ff       	call   800f3f <fd_alloc>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	85 c0                	test   %eax,%eax
  80199e:	0f 88 f8 00 00 00    	js     801a9c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019ab:	00 
  8019ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ba:	e8 d2 f1 ff ff       	call   800b91 <sys_page_alloc>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	0f 88 d3 00 00 00    	js     801a9c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	e8 50 f5 ff ff       	call   800f24 <fd2data>
  8019d4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019dd:	00 
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e9:	e8 a3 f1 ff ff       	call   800b91 <sys_page_alloc>
  8019ee:	89 c3                	mov    %eax,%ebx
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	0f 88 91 00 00 00    	js     801a89 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019fb:	89 04 24             	mov    %eax,(%esp)
  8019fe:	e8 21 f5 ff ff       	call   800f24 <fd2data>
  801a03:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a0a:	00 
  801a0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a16:	00 
  801a17:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a22:	e8 be f1 ff ff       	call   800be5 <sys_page_map>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 4c                	js     801a79 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a36:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a4b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a50:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a5a:	89 04 24             	mov    %eax,(%esp)
  801a5d:	e8 b2 f4 ff ff       	call   800f14 <fd2num>
  801a62:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a64:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a67:	89 04 24             	mov    %eax,(%esp)
  801a6a:	e8 a5 f4 ff ff       	call   800f14 <fd2num>
  801a6f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a72:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a77:	eb 36                	jmp    801aaf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a79:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a84:	e8 af f1 ff ff       	call   800c38 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a97:	e8 9c f1 ff ff       	call   800c38 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aaa:	e8 89 f1 ff ff       	call   800c38 <sys_page_unmap>
    err:
	return r;
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	83 c4 3c             	add    $0x3c,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5f                   	pop    %edi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801abf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 c1 f4 ff ff       	call   800f92 <fd_lookup>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 15                	js     801aea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad8:	89 04 24             	mov    %eax,(%esp)
  801adb:	e8 44 f4 ff ff       	call   800f24 <fd2data>
	return _pipeisclosed(fd, p);
  801ae0:	89 c2                	mov    %eax,%edx
  801ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae5:	e8 15 fd ff ff       	call   8017ff <_pipeisclosed>
}
  801aea:	c9                   	leave  
  801aeb:	c3                   	ret    

00801aec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801afc:	c7 44 24 04 00 24 80 	movl   $0x802400,0x4(%esp)
  801b03:	00 
  801b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 90 ec ff ff       	call   80079f <strcpy>
	return 0;
}
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	57                   	push   %edi
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b22:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b2d:	eb 30                	jmp    801b5f <devcons_write+0x49>
		m = n - tot;
  801b2f:	8b 75 10             	mov    0x10(%ebp),%esi
  801b32:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b34:	83 fe 7f             	cmp    $0x7f,%esi
  801b37:	76 05                	jbe    801b3e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b39:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b3e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b42:	03 45 0c             	add    0xc(%ebp),%eax
  801b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b49:	89 3c 24             	mov    %edi,(%esp)
  801b4c:	e8 c7 ed ff ff       	call   800918 <memmove>
		sys_cputs(buf, m);
  801b51:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b55:	89 3c 24             	mov    %edi,(%esp)
  801b58:	e8 67 ef ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b5d:	01 f3                	add    %esi,%ebx
  801b5f:	89 d8                	mov    %ebx,%eax
  801b61:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b64:	72 c9                	jb     801b2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b66:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5f                   	pop    %edi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b7b:	75 07                	jne    801b84 <devcons_read+0x13>
  801b7d:	eb 25                	jmp    801ba4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b7f:	e8 ee ef ff ff       	call   800b72 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b84:	e8 59 ef ff ff       	call   800ae2 <sys_cgetc>
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	74 f2                	je     801b7f <devcons_read+0xe>
  801b8d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 1d                	js     801bb0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b93:	83 f8 04             	cmp    $0x4,%eax
  801b96:	74 13                	je     801bab <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9b:	88 10                	mov    %dl,(%eax)
	return 1;
  801b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba2:	eb 0c                	jmp    801bb0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	eb 05                	jmp    801bb0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bbe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bc5:	00 
  801bc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bc9:	89 04 24             	mov    %eax,(%esp)
  801bcc:	e8 f3 ee ff ff       	call   800ac4 <sys_cputs>
}
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <getchar>:

int
getchar(void)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bd9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801be0:	00 
  801be1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bef:	e8 3a f6 ff ff       	call   80122e <read>
	if (r < 0)
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 0f                	js     801c07 <getchar+0x34>
		return r;
	if (r < 1)
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	7e 06                	jle    801c02 <getchar+0x2f>
		return -E_EOF;
	return c;
  801bfc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c00:	eb 05                	jmp    801c07 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c02:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c16:	8b 45 08             	mov    0x8(%ebp),%eax
  801c19:	89 04 24             	mov    %eax,(%esp)
  801c1c:	e8 71 f3 ff ff       	call   800f92 <fd_lookup>
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 11                	js     801c36 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c28:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2e:	39 10                	cmp    %edx,(%eax)
  801c30:	0f 94 c0             	sete   %al
  801c33:	0f b6 c0             	movzbl %al,%eax
}
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <opencons>:

int
opencons(void)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c41:	89 04 24             	mov    %eax,(%esp)
  801c44:	e8 f6 f2 ff ff       	call   800f3f <fd_alloc>
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 3c                	js     801c89 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c4d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c54:	00 
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c63:	e8 29 ef ff ff       	call   800b91 <sys_page_alloc>
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 1d                	js     801c89 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 8b f2 ff ff       	call   800f14 <fd2num>
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    
	...

00801c8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c94:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c97:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801c9d:	e8 b1 ee ff ff       	call   800b53 <sys_getenvid>
  801ca2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca5:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  801cac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cb0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb8:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801cbf:	e8 10 e5 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 a0 e4 ff ff       	call   800173 <vcprintf>
	cprintf("\n");
  801cd3:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  801cda:	e8 f5 e4 ff ff       	call   8001d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cdf:	cc                   	int3   
  801ce0:	eb fd                	jmp    801cdf <_panic+0x53>
	...

00801ce4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	c1 ea 16             	shr    $0x16,%edx
  801cef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cf6:	f6 c2 01             	test   $0x1,%dl
  801cf9:	74 1e                	je     801d19 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cfb:	c1 e8 0c             	shr    $0xc,%eax
  801cfe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d05:	a8 01                	test   $0x1,%al
  801d07:	74 17                	je     801d20 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d09:	c1 e8 0c             	shr    $0xc,%eax
  801d0c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d13:	ef 
  801d14:	0f b7 c0             	movzwl %ax,%eax
  801d17:	eb 0c                	jmp    801d25 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d19:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1e:	eb 05                	jmp    801d25 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    
	...

00801d28 <__udivdi3>:
  801d28:	55                   	push   %ebp
  801d29:	57                   	push   %edi
  801d2a:	56                   	push   %esi
  801d2b:	83 ec 10             	sub    $0x10,%esp
  801d2e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d32:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d3e:	89 cd                	mov    %ecx,%ebp
  801d40:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d44:	85 c0                	test   %eax,%eax
  801d46:	75 2c                	jne    801d74 <__udivdi3+0x4c>
  801d48:	39 f9                	cmp    %edi,%ecx
  801d4a:	77 68                	ja     801db4 <__udivdi3+0x8c>
  801d4c:	85 c9                	test   %ecx,%ecx
  801d4e:	75 0b                	jne    801d5b <__udivdi3+0x33>
  801d50:	b8 01 00 00 00       	mov    $0x1,%eax
  801d55:	31 d2                	xor    %edx,%edx
  801d57:	f7 f1                	div    %ecx
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	89 f8                	mov    %edi,%eax
  801d5f:	f7 f1                	div    %ecx
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	89 f0                	mov    %esi,%eax
  801d65:	f7 f1                	div    %ecx
  801d67:	89 c6                	mov    %eax,%esi
  801d69:	89 f0                	mov    %esi,%eax
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	5e                   	pop    %esi
  801d71:	5f                   	pop    %edi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    
  801d74:	39 f8                	cmp    %edi,%eax
  801d76:	77 2c                	ja     801da4 <__udivdi3+0x7c>
  801d78:	0f bd f0             	bsr    %eax,%esi
  801d7b:	83 f6 1f             	xor    $0x1f,%esi
  801d7e:	75 4c                	jne    801dcc <__udivdi3+0xa4>
  801d80:	39 f8                	cmp    %edi,%eax
  801d82:	bf 00 00 00 00       	mov    $0x0,%edi
  801d87:	72 0a                	jb     801d93 <__udivdi3+0x6b>
  801d89:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d8d:	0f 87 ad 00 00 00    	ja     801e40 <__udivdi3+0x118>
  801d93:	be 01 00 00 00       	mov    $0x1,%esi
  801d98:	89 f0                	mov    %esi,%eax
  801d9a:	89 fa                	mov    %edi,%edx
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    
  801da3:	90                   	nop
  801da4:	31 ff                	xor    %edi,%edi
  801da6:	31 f6                	xor    %esi,%esi
  801da8:	89 f0                	mov    %esi,%eax
  801daa:	89 fa                	mov    %edi,%edx
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    
  801db3:	90                   	nop
  801db4:	89 fa                	mov    %edi,%edx
  801db6:	89 f0                	mov    %esi,%eax
  801db8:	f7 f1                	div    %ecx
  801dba:	89 c6                	mov    %eax,%esi
  801dbc:	31 ff                	xor    %edi,%edi
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	89 fa                	mov    %edi,%edx
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    
  801dc9:	8d 76 00             	lea    0x0(%esi),%esi
  801dcc:	89 f1                	mov    %esi,%ecx
  801dce:	d3 e0                	shl    %cl,%eax
  801dd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd4:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd9:	29 f0                	sub    %esi,%eax
  801ddb:	89 ea                	mov    %ebp,%edx
  801ddd:	88 c1                	mov    %al,%cl
  801ddf:	d3 ea                	shr    %cl,%edx
  801de1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801de5:	09 ca                	or     %ecx,%edx
  801de7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801deb:	89 f1                	mov    %esi,%ecx
  801ded:	d3 e5                	shl    %cl,%ebp
  801def:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801df3:	89 fd                	mov    %edi,%ebp
  801df5:	88 c1                	mov    %al,%cl
  801df7:	d3 ed                	shr    %cl,%ebp
  801df9:	89 fa                	mov    %edi,%edx
  801dfb:	89 f1                	mov    %esi,%ecx
  801dfd:	d3 e2                	shl    %cl,%edx
  801dff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e03:	88 c1                	mov    %al,%cl
  801e05:	d3 ef                	shr    %cl,%edi
  801e07:	09 d7                	or     %edx,%edi
  801e09:	89 f8                	mov    %edi,%eax
  801e0b:	89 ea                	mov    %ebp,%edx
  801e0d:	f7 74 24 08          	divl   0x8(%esp)
  801e11:	89 d1                	mov    %edx,%ecx
  801e13:	89 c7                	mov    %eax,%edi
  801e15:	f7 64 24 0c          	mull   0xc(%esp)
  801e19:	39 d1                	cmp    %edx,%ecx
  801e1b:	72 17                	jb     801e34 <__udivdi3+0x10c>
  801e1d:	74 09                	je     801e28 <__udivdi3+0x100>
  801e1f:	89 fe                	mov    %edi,%esi
  801e21:	31 ff                	xor    %edi,%edi
  801e23:	e9 41 ff ff ff       	jmp    801d69 <__udivdi3+0x41>
  801e28:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e2c:	89 f1                	mov    %esi,%ecx
  801e2e:	d3 e2                	shl    %cl,%edx
  801e30:	39 c2                	cmp    %eax,%edx
  801e32:	73 eb                	jae    801e1f <__udivdi3+0xf7>
  801e34:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e37:	31 ff                	xor    %edi,%edi
  801e39:	e9 2b ff ff ff       	jmp    801d69 <__udivdi3+0x41>
  801e3e:	66 90                	xchg   %ax,%ax
  801e40:	31 f6                	xor    %esi,%esi
  801e42:	e9 22 ff ff ff       	jmp    801d69 <__udivdi3+0x41>
	...

00801e48 <__umoddi3>:
  801e48:	55                   	push   %ebp
  801e49:	57                   	push   %edi
  801e4a:	56                   	push   %esi
  801e4b:	83 ec 20             	sub    $0x20,%esp
  801e4e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e52:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e56:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e5a:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e5e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e62:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e66:	89 c7                	mov    %eax,%edi
  801e68:	89 f2                	mov    %esi,%edx
  801e6a:	85 ed                	test   %ebp,%ebp
  801e6c:	75 16                	jne    801e84 <__umoddi3+0x3c>
  801e6e:	39 f1                	cmp    %esi,%ecx
  801e70:	0f 86 a6 00 00 00    	jbe    801f1c <__umoddi3+0xd4>
  801e76:	f7 f1                	div    %ecx
  801e78:	89 d0                	mov    %edx,%eax
  801e7a:	31 d2                	xor    %edx,%edx
  801e7c:	83 c4 20             	add    $0x20,%esp
  801e7f:	5e                   	pop    %esi
  801e80:	5f                   	pop    %edi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    
  801e83:	90                   	nop
  801e84:	39 f5                	cmp    %esi,%ebp
  801e86:	0f 87 ac 00 00 00    	ja     801f38 <__umoddi3+0xf0>
  801e8c:	0f bd c5             	bsr    %ebp,%eax
  801e8f:	83 f0 1f             	xor    $0x1f,%eax
  801e92:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e96:	0f 84 a8 00 00 00    	je     801f44 <__umoddi3+0xfc>
  801e9c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea0:	d3 e5                	shl    %cl,%ebp
  801ea2:	bf 20 00 00 00       	mov    $0x20,%edi
  801ea7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801eab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eaf:	89 f9                	mov    %edi,%ecx
  801eb1:	d3 e8                	shr    %cl,%eax
  801eb3:	09 e8                	or     %ebp,%eax
  801eb5:	89 44 24 18          	mov    %eax,0x18(%esp)
  801eb9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ebd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ec1:	d3 e0                	shl    %cl,%eax
  801ec3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ec7:	89 f2                	mov    %esi,%edx
  801ec9:	d3 e2                	shl    %cl,%edx
  801ecb:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ecf:	d3 e0                	shl    %cl,%eax
  801ed1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801ed5:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed9:	89 f9                	mov    %edi,%ecx
  801edb:	d3 e8                	shr    %cl,%eax
  801edd:	09 d0                	or     %edx,%eax
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	89 f2                	mov    %esi,%edx
  801ee3:	f7 74 24 18          	divl   0x18(%esp)
  801ee7:	89 d6                	mov    %edx,%esi
  801ee9:	f7 64 24 0c          	mull   0xc(%esp)
  801eed:	89 c5                	mov    %eax,%ebp
  801eef:	89 d1                	mov    %edx,%ecx
  801ef1:	39 d6                	cmp    %edx,%esi
  801ef3:	72 67                	jb     801f5c <__umoddi3+0x114>
  801ef5:	74 75                	je     801f6c <__umoddi3+0x124>
  801ef7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801efb:	29 e8                	sub    %ebp,%eax
  801efd:	19 ce                	sbb    %ecx,%esi
  801eff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f03:	d3 e8                	shr    %cl,%eax
  801f05:	89 f2                	mov    %esi,%edx
  801f07:	89 f9                	mov    %edi,%ecx
  801f09:	d3 e2                	shl    %cl,%edx
  801f0b:	09 d0                	or     %edx,%eax
  801f0d:	89 f2                	mov    %esi,%edx
  801f0f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f13:	d3 ea                	shr    %cl,%edx
  801f15:	83 c4 20             	add    $0x20,%esp
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    
  801f1c:	85 c9                	test   %ecx,%ecx
  801f1e:	75 0b                	jne    801f2b <__umoddi3+0xe3>
  801f20:	b8 01 00 00 00       	mov    $0x1,%eax
  801f25:	31 d2                	xor    %edx,%edx
  801f27:	f7 f1                	div    %ecx
  801f29:	89 c1                	mov    %eax,%ecx
  801f2b:	89 f0                	mov    %esi,%eax
  801f2d:	31 d2                	xor    %edx,%edx
  801f2f:	f7 f1                	div    %ecx
  801f31:	89 f8                	mov    %edi,%eax
  801f33:	e9 3e ff ff ff       	jmp    801e76 <__umoddi3+0x2e>
  801f38:	89 f2                	mov    %esi,%edx
  801f3a:	83 c4 20             	add    $0x20,%esp
  801f3d:	5e                   	pop    %esi
  801f3e:	5f                   	pop    %edi
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    
  801f41:	8d 76 00             	lea    0x0(%esi),%esi
  801f44:	39 f5                	cmp    %esi,%ebp
  801f46:	72 04                	jb     801f4c <__umoddi3+0x104>
  801f48:	39 f9                	cmp    %edi,%ecx
  801f4a:	77 06                	ja     801f52 <__umoddi3+0x10a>
  801f4c:	89 f2                	mov    %esi,%edx
  801f4e:	29 cf                	sub    %ecx,%edi
  801f50:	19 ea                	sbb    %ebp,%edx
  801f52:	89 f8                	mov    %edi,%eax
  801f54:	83 c4 20             	add    $0x20,%esp
  801f57:	5e                   	pop    %esi
  801f58:	5f                   	pop    %edi
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    
  801f5b:	90                   	nop
  801f5c:	89 d1                	mov    %edx,%ecx
  801f5e:	89 c5                	mov    %eax,%ebp
  801f60:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f64:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f68:	eb 8d                	jmp    801ef7 <__umoddi3+0xaf>
  801f6a:	66 90                	xchg   %ax,%ax
  801f6c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f70:	72 ea                	jb     801f5c <__umoddi3+0x114>
  801f72:	89 f1                	mov    %esi,%ecx
  801f74:	eb 81                	jmp    801ef7 <__umoddi3+0xaf>
