
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 c7 11 00 00       	call   801209 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 7b 0b 00 00       	call   800bcf <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  800063:	e8 e8 01 00 00       	call   800250 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 5f 0b 00 00       	call   800bcf <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 da 16 80 00 	movl   $0x8016da,(%esp)
  80007f:	e8 cc 01 00 00       	call   800250 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 ec 11 00 00       	call   801293 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 6a 11 00 00       	call   80122c <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 f3 0a 00 00       	call   800bcf <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  8000fa:	e8 51 01 00 00       	call   800250 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 61 11 00 00       	call   801293 <ipc_send>
		if (val == 10)
  800132:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  800139:	0f 85 68 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 4c             	add    $0x4c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800156:	e8 74 0a 00 00       	call   800bcf <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 cf 09 00 00       	call   800b7d <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	40                   	inc    %eax
  8001c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cb:	75 19                	jne    8001e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d4:	00 
  8001d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 60 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e6:	ff 43 04             	incl   0x4(%ebx)
}
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ff:	00 00 00 
	b.cnt = 0;
  800202:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800209:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800213:	8b 45 08             	mov    0x8(%ebp),%eax
  800216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022b:	e8 82 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 f8 08 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800248:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800256:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 87 ff ff ff       	call   8001ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    
	...

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d7                	mov    %edx,%edi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800289:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	85 c0                	test   %eax,%eax
  80028e:	75 08                	jne    800298 <printnum+0x2c>
  800290:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800293:	39 45 10             	cmp    %eax,0x10(%ebp)
  800296:	77 57                	ja     8002ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800298:	89 74 24 10          	mov    %esi,0x10(%esp)
  80029c:	4b                   	dec    %ebx
  80029d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b7:	00 
  8002b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	e8 96 11 00 00       	call   801460 <__udivdi3>
  8002ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d9:	89 fa                	mov    %edi,%edx
  8002db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002de:	e8 89 ff ff ff       	call   80026c <printnum>
  8002e3:	eb 0f                	jmp    8002f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ef:	4b                   	dec    %ebx
  8002f0:	85 db                	test   %ebx,%ebx
  8002f2:	7f f1                	jg     8002e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030a:	00 
  80030b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	e8 63 12 00 00       	call   801580 <__umoddi3>
  80031d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800321:	0f be 80 20 17 80 00 	movsbl 0x801720(%eax),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032e:	83 c4 3c             	add    $0x3c,%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800339:	83 fa 01             	cmp    $0x1,%edx
  80033c:	7e 0e                	jle    80034c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 08             	lea    0x8(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	8b 52 04             	mov    0x4(%edx),%edx
  80034a:	eb 22                	jmp    80036e <getuint+0x38>
	else if (lflag)
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 10                	je     800360 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 0e                	jmp    80036e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800376:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 08                	jae    800388 <sprintputch+0x18>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	42                   	inc    %edx
  800386:	89 10                	mov    %edx,(%eax)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 02 00 00 00       	call   8003b2 <vprintfmt>
	va_end(ap);
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 4c             	sub    $0x4c,%esp
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003be:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c1:	eb 12                	jmp    8003d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	0f 84 8b 03 00 00    	je     800756 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d5:	0f b6 06             	movzbl (%esi),%eax
  8003d8:	46                   	inc    %esi
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	75 e5                	jne    8003c3 <vprintfmt+0x11>
  8003de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	eb 26                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800403:	eb 1d                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80040c:	eb 14                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800418:	eb 08                	jmp    800422 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80041d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	0f b6 06             	movzbl (%esi),%eax
  800425:	8d 56 01             	lea    0x1(%esi),%edx
  800428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042b:	8a 16                	mov    (%esi),%dl
  80042d:	83 ea 23             	sub    $0x23,%edx
  800430:	80 fa 55             	cmp    $0x55,%dl
  800433:	0f 87 01 03 00 00    	ja     80073a <vprintfmt+0x388>
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	ff 24 95 e0 17 80 00 	jmp    *0x8017e0(,%edx,4)
  800443:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800446:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800452:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800455:	8d 50 d0             	lea    -0x30(%eax),%edx
  800458:	83 fa 09             	cmp    $0x9,%edx
  80045b:	77 2a                	ja     800487 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb eb                	jmp    80044b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046e:	eb 17                	jmp    800487 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	78 98                	js     80040e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800479:	eb a7                	jmp    800422 <vprintfmt+0x70>
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800485:	eb 9b                	jmp    800422 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800487:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048b:	79 95                	jns    800422 <vprintfmt+0x70>
  80048d:	eb 8b                	jmp    80041a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	eb 8d                	jmp    800422 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ad:	e9 23 ff ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	79 02                	jns    8004c3 <vprintfmt+0x111>
  8004c1:	f7 d8                	neg    %eax
  8004c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c5:	83 f8 08             	cmp    $0x8,%eax
  8004c8:	7f 0b                	jg     8004d5 <vprintfmt+0x123>
  8004ca:	8b 04 85 40 19 80 00 	mov    0x801940(,%eax,4),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 23                	jne    8004f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d9:	c7 44 24 08 38 17 80 	movl   $0x801738,0x8(%esp)
  8004e0:	00 
  8004e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 9a fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 dd fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 41 17 80 	movl   $0x801741,0x8(%esp)
  800503:	00 
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 14 24             	mov    %edx,(%esp)
  80050e:	e8 77 fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ba fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
  80051b:	89 f9                	mov    %edi,%ecx
  80051d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800520:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 30                	mov    (%eax),%esi
  80052e:	85 f6                	test   %esi,%esi
  800530:	75 05                	jne    800537 <vprintfmt+0x185>
				p = "(null)";
  800532:	be 31 17 80 00       	mov    $0x801731,%esi
			if (width > 0 && padc != '-')
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	0f 8e 84 00 00 00    	jle    8005c5 <vprintfmt+0x213>
  800541:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800545:	74 7e                	je     8005c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054b:	89 34 24             	mov    %esi,(%esp)
  80054e:	e8 ab 02 00 00       	call   8007fe <strnlen>
  800553:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800556:	29 c2                	sub    %eax,%edx
  800558:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80055b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800562:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800565:	89 de                	mov    %ebx,%esi
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	eb 0b                	jmp    800578 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80056d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800571:	89 3c 24             	mov    %edi,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f f1                	jg     80056d <vprintfmt+0x1bb>
  80057c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057f:	89 f3                	mov    %esi,%ebx
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	79 05                	jns    800590 <vprintfmt+0x1de>
  80058b:	b8 00 00 00 00       	mov    $0x0,%eax
  800590:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800598:	eb 2b                	jmp    8005c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059e:	74 18                	je     8005b8 <vprintfmt+0x206>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x206>
					putch('?', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	eb 0a                	jmp    8005c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	46                   	inc    %esi
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	74 21                	je     8005ee <vprintfmt+0x23c>
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	78 c9                	js     80059a <vprintfmt+0x1e8>
  8005d1:	4f                   	dec    %edi
  8005d2:	79 c6                	jns    80059a <vprintfmt+0x1e8>
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	89 de                	mov    %ebx,%esi
  8005d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005dc:	eb 18                	jmp    8005f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x244>
  8005ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	7f e4                	jg     8005de <vprintfmt+0x22c>
  8005fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800602:	e9 ce fd ff ff       	jmp    8003d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7e 10                	jle    80061c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 08             	lea    0x8(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
  800617:	8b 78 04             	mov    0x4(%eax),%edi
  80061a:	eb 26                	jmp    800642 <vprintfmt+0x290>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 12                	je     800632 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	c1 ff 1f             	sar    $0x1f,%edi
  800630:	eb 10                	jmp    800642 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 30                	mov    (%eax),%esi
  80063d:	89 f7                	mov    %esi,%edi
  80063f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	85 ff                	test   %edi,%edi
  800644:	78 0a                	js     800650 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 ac 00 00 00       	jmp    8006fc <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	f7 de                	neg    %esi
  800660:	83 d7 00             	adc    $0x0,%edi
  800663:	f7 df                	neg    %edi
			}
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	e9 8d 00 00 00       	jmp    8006fc <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066f:	89 ca                	mov    %ecx,%edx
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 bd fc ff ff       	call   800336 <getuint>
  800679:	89 c6                	mov    %eax,%esi
  80067b:	89 d7                	mov    %edx,%edi
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800682:	eb 78                	jmp    8006fc <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b1:	e9 1f fd ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e7:	eb 13                	jmp    8006fc <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 43 fc ff ff       	call   800336 <getuint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800700:	89 54 24 10          	mov    %edx,0x10(%esp)
  800704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800707:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070f:	89 34 24             	mov    %esi,(%esp)
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	89 da                	mov    %ebx,%edx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	e8 4c fb ff ff       	call   80026c <printnum>
			break;
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800723:	e9 ad fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800735:	e9 9b fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	eb 01                	jmp    80074b <vprintfmt+0x399>
  80074a:	4e                   	dec    %esi
  80074b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074f:	75 f9                	jne    80074a <vprintfmt+0x398>
  800751:	e9 7f fc ff ff       	jmp    8003d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800756:	83 c4 4c             	add    $0x4c,%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 28             	sub    $0x28,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 30                	je     8007af <vsnprintf+0x51>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 33                	jle    8007b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	c7 04 24 70 03 80 00 	movl   $0x800370,(%esp)
  80079f:	e8 0e fc ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ad:	eb 0c                	jmp    8007bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb 05                	jmp    8007bb <vsnprintf+0x5d>
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	e8 7b ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
  8007e5:	00 00                	add    %al,(%eax)
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	ba 00 00 00 00       	mov    $0x0,%edx
  80082a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80082d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800830:	42                   	inc    %edx
  800831:	84 c9                	test   %cl,%cl
  800833:	75 f5                	jne    80082a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800842:	89 1c 24             	mov    %ebx,(%esp)
  800845:	e8 9e ff ff ff       	call   8007e8 <strlen>
	strcpy(dst + len, src);
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800851:	01 d8                	add    %ebx,%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 c0 ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	83 c4 08             	add    $0x8,%esp
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
  800876:	eb 0c                	jmp    800884 <strncpy+0x21>
		*dst++ = *src;
  800878:	8a 1a                	mov    (%edx),%bl
  80087a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087d:	80 3a 01             	cmpb   $0x1,(%edx)
  800880:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800883:	41                   	inc    %ecx
  800884:	39 f1                	cmp    %esi,%ecx
  800886:	75 f0                	jne    800878 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 d2                	test   %edx,%edx
  80089c:	75 0a                	jne    8008a8 <strlcpy+0x1c>
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	eb 1a                	jmp    8008bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a2:	88 18                	mov    %bl,(%eax)
  8008a4:	40                   	inc    %eax
  8008a5:	41                   	inc    %ecx
  8008a6:	eb 02                	jmp    8008aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008aa:	4a                   	dec    %edx
  8008ab:	74 0a                	je     8008b7 <strlcpy+0x2b>
  8008ad:	8a 19                	mov    (%ecx),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strlcpy+0x16>
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	eb 02                	jmp    8008b9 <strlcpy+0x2d>
  8008b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008bc:	29 f0                	sub    %esi,%eax
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	eb 02                	jmp    8008cf <strcmp+0xd>
		p++, q++;
  8008cd:	41                   	inc    %ecx
  8008ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	8a 01                	mov    (%ecx),%al
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x17>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 f4                	je     8008cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 03                	jmp    8008f5 <strncmp+0x12>
		n--, p++, q++;
  8008f2:	4a                   	dec    %edx
  8008f3:	40                   	inc    %eax
  8008f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 14                	je     80090d <strncmp+0x2a>
  8008f9:	8a 18                	mov    (%eax),%bl
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	74 04                	je     800903 <strncmp+0x20>
  8008ff:	3a 19                	cmp    (%ecx),%bl
  800901:	74 ef                	je     8008f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800903:	0f b6 00             	movzbl (%eax),%eax
  800906:	0f b6 11             	movzbl (%ecx),%edx
  800909:	29 d0                	sub    %edx,%eax
  80090b:	eb 05                	jmp    800912 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091e:	eb 05                	jmp    800925 <strchr+0x10>
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 0c                	je     800930 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800924:	40                   	inc    %eax
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f5                	jne    800920 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093b:	eb 05                	jmp    800942 <strfind+0x10>
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 07                	je     800948 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800941:	40                   	inc    %eax
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f5                	jne    80093d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 7d 08             	mov    0x8(%ebp),%edi
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 30                	je     80098d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800963:	75 25                	jne    80098a <memset+0x40>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 20                	jne    80098a <memset+0x40>
		c &= 0xFF;
  80096a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 d0                	or     %edx,%eax
  800980:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 03                	jmp    80098d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 34                	jae    8009da <memmove+0x46>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 2d                	jae    8009da <memmove+0x46>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 1b                	jne    8009d0 <memmove+0x3c>
  8009b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bb:	75 13                	jne    8009d0 <memmove+0x3c>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0e                	jne    8009d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c2:	83 ef 04             	sub    $0x4,%edi
  8009c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 07                	jmp    8009d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d0:	4f                   	dec    %edi
  8009d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d7:	fc                   	cld    
  8009d8:	eb 20                	jmp    8009fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e0:	75 13                	jne    8009f5 <memmove+0x61>
  8009e2:	a8 03                	test   $0x3,%al
  8009e4:	75 0f                	jne    8009f5 <memmove+0x61>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 0a                	jne    8009f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f3:	eb 05                	jmp    8009fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a04:	8b 45 10             	mov    0x10(%ebp),%eax
  800a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 77 ff ff ff       	call   800994 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	eb 16                	jmp    800a4b <memcmp+0x2c>
		if (*s1 != *s2)
  800a35:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a38:	42                   	inc    %edx
  800a39:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a3d:	38 c8                	cmp    %cl,%al
  800a3f:	74 0a                	je     800a4b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a41:	0f b6 c0             	movzbl %al,%eax
  800a44:	0f b6 c9             	movzbl %cl,%ecx
  800a47:	29 c8                	sub    %ecx,%eax
  800a49:	eb 09                	jmp    800a54 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 da                	cmp    %ebx,%edx
  800a4d:	75 e6                	jne    800a35 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	eb 05                	jmp    800a6e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	74 05                	je     800a72 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6d:	40                   	inc    %eax
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	72 f7                	jb     800a69 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a80:	eb 01                	jmp    800a83 <strtol+0xf>
		s++;
  800a82:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	8a 02                	mov    (%edx),%al
  800a85:	3c 20                	cmp    $0x20,%al
  800a87:	74 f9                	je     800a82 <strtol+0xe>
  800a89:	3c 09                	cmp    $0x9,%al
  800a8b:	74 f5                	je     800a82 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8d:	3c 2b                	cmp    $0x2b,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x25>
		s++;
  800a91:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
  800a97:	eb 13                	jmp    800aac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a99:	3c 2d                	cmp    $0x2d,%al
  800a9b:	75 0a                	jne    800aa7 <strtol+0x33>
		s++, neg = 1;
  800a9d:	8d 52 01             	lea    0x1(%edx),%edx
  800aa0:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa5:	eb 05                	jmp    800aac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 05                	je     800ab5 <strtol+0x41>
  800ab0:	83 fb 10             	cmp    $0x10,%ebx
  800ab3:	75 28                	jne    800add <strtol+0x69>
  800ab5:	8a 02                	mov    (%edx),%al
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 10                	jne    800acb <strtol+0x57>
  800abb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abf:	75 0a                	jne    800acb <strtol+0x57>
		s += 2, base = 16;
  800ac1:	83 c2 02             	add    $0x2,%edx
  800ac4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac9:	eb 12                	jmp    800add <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	75 0e                	jne    800add <strtol+0x69>
  800acf:	3c 30                	cmp    $0x30,%al
  800ad1:	75 05                	jne    800ad8 <strtol+0x64>
		s++, base = 8;
  800ad3:	42                   	inc    %edx
  800ad4:	b3 08                	mov    $0x8,%bl
  800ad6:	eb 05                	jmp    800add <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae4:	8a 0a                	mov    (%edx),%cl
  800ae6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x82>
			dig = *s - '0';
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 30             	sub    $0x30,%ecx
  800af4:	eb 1e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 57             	sub    $0x57,%ecx
  800b04:	eb 0e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 12                	ja     800b20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0e:	0f be c9             	movsbl %cl,%ecx
  800b11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b14:	39 f1                	cmp    %esi,%ecx
  800b16:	7d 0c                	jge    800b24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b18:	42                   	inc    %edx
  800b19:	0f af c6             	imul   %esi,%eax
  800b1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb c4                	jmp    800ae4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	89 c1                	mov    %eax,%ecx
  800b22:	eb 02                	jmp    800b26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 05                	je     800b31 <strtol+0xbd>
		*endptr = (char *) s;
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b31:	85 ff                	test   %edi,%edi
  800b33:	74 04                	je     800b39 <strtol+0xc5>
  800b35:	89 c8                	mov    %ecx,%eax
  800b37:	f7 d8                	neg    %eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    
	...

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 28                	jle    800bc7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800bc2:	e8 7d 07 00 00       	call   801344 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc7:	83 c4 2c             	add    $0x2c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_yield>:

void
sys_yield(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfe:	89 d1                	mov    %edx,%ecx
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	89 d7                	mov    %edx,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	be 00 00 00 00       	mov    $0x0,%esi
  800c1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 f7                	mov    %esi,%edi
  800c2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 28                	jle    800c59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800c44:	00 
  800c45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4c:	00 
  800c4d:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800c54:	e8 eb 06 00 00       	call   801344 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	83 c4 2c             	add    $0x2c,%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 28                	jle    800cac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8f:	00 
  800c90:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800ca7:	e8 98 06 00 00       	call   801344 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cac:	83 c4 2c             	add    $0x2c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800cfa:	e8 45 06 00 00       	call   801344 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800d4d:	e8 f2 05 00 00       	call   801344 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800da0:	e8 9f 05 00 00       	call   801344 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	be 00 00 00 00       	mov    $0x0,%esi
  800db8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 cb                	mov    %ecx,%ebx
  800de8:	89 cf                	mov    %ecx,%edi
  800dea:	89 ce                	mov    %ecx,%esi
  800dec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7e 28                	jle    800e1a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800e05:	00 
  800e06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0d:	00 
  800e0e:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800e15:	e8 2a 05 00 00       	call   801344 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1a:	83 c4 2c             	add    $0x2c,%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
	...

00800e24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	83 ec 24             	sub    $0x24,%esp
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800e30:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e34:	75 20                	jne    800e56 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e36:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e3a:	c7 44 24 08 90 19 80 	movl   $0x801990,0x8(%esp)
  800e41:	00 
  800e42:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800e49:	00 
  800e4a:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  800e51:	e8 ee 04 00 00       	call   801344 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e68:	f6 c4 08             	test   $0x8,%ah
  800e6b:	75 1c                	jne    800e89 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e6d:	c7 44 24 08 c0 19 80 	movl   $0x8019c0,0x8(%esp)
  800e74:	00 
  800e75:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e7c:	00 
  800e7d:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  800e84:	e8 bb 04 00 00       	call   801344 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800e89:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea0:	e8 68 fd ff ff       	call   800c0d <sys_page_alloc>
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	79 20                	jns    800ec9 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ead:	c7 44 24 08 1a 1a 80 	movl   $0x801a1a,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  800ec4:	e8 7b 04 00 00       	call   801344 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800ec9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ed0:	00 
  800ed1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800edc:	e8 b3 fa ff ff       	call   800994 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800ee1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ee8:	00 
  800ee9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800efc:	00 
  800efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f04:	e8 58 fd ff ff       	call   800c61 <sys_page_map>
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	79 20                	jns    800f2d <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f11:	c7 44 24 08 2d 1a 80 	movl   $0x801a2d,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  800f28:	e8 17 04 00 00       	call   801344 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800f2d:	83 c4 24             	add    $0x24,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f3c:	c7 04 24 24 0e 80 00 	movl   $0x800e24,(%esp)
  800f43:	e8 54 04 00 00       	call   80139c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f48:	ba 07 00 00 00       	mov    $0x7,%edx
  800f4d:	89 d0                	mov    %edx,%eax
  800f4f:	cd 30                	int    $0x30
  800f51:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f57:	85 c0                	test   %eax,%eax
  800f59:	79 20                	jns    800f7b <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5f:	c7 44 24 08 3e 1a 80 	movl   $0x801a3e,0x8(%esp)
  800f66:	00 
  800f67:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f6e:	00 
  800f6f:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  800f76:	e8 c9 03 00 00       	call   801344 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f7b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f7f:	75 25                	jne    800fa6 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f81:	e8 49 fc ff ff       	call   800bcf <sys_getenvid>
  800f86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f92:	c1 e0 07             	shl    $0x7,%eax
  800f95:	29 d0                	sub    %edx,%eax
  800f97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9c:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800fa1:	e9 58 02 00 00       	jmp    8011fe <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800fa6:	bf 00 00 00 00       	mov    $0x0,%edi
  800fab:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fb0:	89 f0                	mov    %esi,%eax
  800fb2:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbc:	a8 01                	test   $0x1,%al
  800fbe:	0f 84 7a 01 00 00    	je     80113e <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800fc4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	0f 84 6b 01 00 00    	je     80113e <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800fd3:	a1 08 20 80 00       	mov    0x802008,%eax
  800fd8:	8b 40 48             	mov    0x48(%eax),%eax
  800fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800fde:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe5:	f6 c4 04             	test   $0x4,%ah
  800fe8:	74 52                	je     80103c <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800fea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff1:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801001:	89 44 24 08          	mov    %eax,0x8(%esp)
  801005:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801009:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100c:	89 04 24             	mov    %eax,(%esp)
  80100f:	e8 4d fc ff ff       	call   800c61 <sys_page_map>
  801014:	85 c0                	test   %eax,%eax
  801016:	0f 89 22 01 00 00    	jns    80113e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80101c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801020:	c7 44 24 08 4e 1a 80 	movl   $0x801a4e,0x8(%esp)
  801027:	00 
  801028:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80102f:	00 
  801030:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801037:	e8 08 03 00 00       	call   801344 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80103c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801043:	f6 c4 08             	test   $0x8,%ah
  801046:	75 0f                	jne    801057 <fork+0x124>
  801048:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104f:	a8 02                	test   $0x2,%al
  801051:	0f 84 99 00 00 00    	je     8010f0 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801057:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105e:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801061:	83 f8 01             	cmp    $0x1,%eax
  801064:	19 db                	sbb    %ebx,%ebx
  801066:	83 e3 fc             	and    $0xfffffffc,%ebx
  801069:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80106f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801073:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801077:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80107a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80107e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801082:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801085:	89 04 24             	mov    %eax,(%esp)
  801088:	e8 d4 fb ff ff       	call   800c61 <sys_page_map>
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 20                	jns    8010b1 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801091:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801095:	c7 44 24 08 4e 1a 80 	movl   $0x801a4e,0x8(%esp)
  80109c:	00 
  80109d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010a4:	00 
  8010a5:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8010ac:	e8 93 02 00 00       	call   801344 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010b1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010c4:	89 04 24             	mov    %eax,(%esp)
  8010c7:	e8 95 fb ff ff       	call   800c61 <sys_page_map>
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 6e                	jns    80113e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d4:	c7 44 24 08 4e 1a 80 	movl   $0x801a4e,0x8(%esp)
  8010db:	00 
  8010dc:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8010eb:	e8 54 02 00 00       	call   801344 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010f0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801100:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801107:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80110f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801112:	89 04 24             	mov    %eax,(%esp)
  801115:	e8 47 fb ff ff       	call   800c61 <sys_page_map>
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 20                	jns    80113e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80111e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801122:	c7 44 24 08 4e 1a 80 	movl   $0x801a4e,0x8(%esp)
  801129:	00 
  80112a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801131:	00 
  801132:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801139:	e8 06 02 00 00       	call   801344 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  80113e:	46                   	inc    %esi
  80113f:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801145:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80114b:	0f 85 5f fe ff ff    	jne    800fb0 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801151:	c7 44 24 04 3c 14 80 	movl   $0x80143c,0x4(%esp)
  801158:	00 
  801159:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80115c:	89 04 24             	mov    %eax,(%esp)
  80115f:	e8 f6 fb ff ff       	call   800d5a <sys_env_set_pgfault_upcall>
  801164:	85 c0                	test   %eax,%eax
  801166:	79 20                	jns    801188 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801168:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116c:	c7 44 24 08 f0 19 80 	movl   $0x8019f0,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801183:	e8 bc 01 00 00       	call   801344 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801188:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80118f:	00 
  801190:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801197:	ee 
  801198:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 6a fa ff ff       	call   800c0d <sys_page_alloc>
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	79 20                	jns    8011c7 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8011a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ab:	c7 44 24 08 1a 1a 80 	movl   $0x801a1a,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8011c2:	e8 7d 01 00 00       	call   801344 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011c7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011ce:	00 
  8011cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d2:	89 04 24             	mov    %eax,(%esp)
  8011d5:	e8 2d fb ff ff       	call   800d07 <sys_env_set_status>
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	79 20                	jns    8011fe <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  8011de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e2:	c7 44 24 08 60 1a 80 	movl   $0x801a60,0x8(%esp)
  8011e9:	00 
  8011ea:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011f1:	00 
  8011f2:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8011f9:	e8 46 01 00 00       	call   801344 <_panic>
	}
	
	return envid;
}
  8011fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801201:	83 c4 3c             	add    $0x3c,%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <sfork>:

// Challenge!
int
sfork(void)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80120f:	c7 44 24 08 77 1a 80 	movl   $0x801a77,0x8(%esp)
  801216:	00 
  801217:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  80121e:	00 
  80121f:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  801226:	e8 19 01 00 00       	call   801344 <_panic>
	...

0080122c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 10             	sub    $0x10,%esp
  801234:	8b 75 08             	mov    0x8(%ebp),%esi
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  80123d:	85 c0                	test   %eax,%eax
  80123f:	75 05                	jne    801246 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801241:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801246:	89 04 24             	mov    %eax,(%esp)
  801249:	e8 82 fb ff ff       	call   800dd0 <sys_ipc_recv>
	if (!err) {
  80124e:	85 c0                	test   %eax,%eax
  801250:	75 26                	jne    801278 <ipc_recv+0x4c>
		if (from_env_store) {
  801252:	85 f6                	test   %esi,%esi
  801254:	74 0a                	je     801260 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801256:	a1 08 20 80 00       	mov    0x802008,%eax
  80125b:	8b 40 74             	mov    0x74(%eax),%eax
  80125e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801260:	85 db                	test   %ebx,%ebx
  801262:	74 0a                	je     80126e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801264:	a1 08 20 80 00       	mov    0x802008,%eax
  801269:	8b 40 78             	mov    0x78(%eax),%eax
  80126c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80126e:	a1 08 20 80 00       	mov    0x802008,%eax
  801273:	8b 40 70             	mov    0x70(%eax),%eax
  801276:	eb 14                	jmp    80128c <ipc_recv+0x60>
	}
	if (from_env_store) {
  801278:	85 f6                	test   %esi,%esi
  80127a:	74 06                	je     801282 <ipc_recv+0x56>
		*from_env_store = 0;
  80127c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801282:	85 db                	test   %ebx,%ebx
  801284:	74 06                	je     80128c <ipc_recv+0x60>
		*perm_store = 0;
  801286:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	57                   	push   %edi
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 1c             	sub    $0x1c,%esp
  80129c:	8b 75 10             	mov    0x10(%ebp),%esi
  80129f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8012a2:	85 f6                	test   %esi,%esi
  8012a4:	75 05                	jne    8012ab <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8012a6:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8012ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012af:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	89 04 24             	mov    %eax,(%esp)
  8012c0:	e8 e8 fa ff ff       	call   800dad <sys_ipc_try_send>
  8012c5:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8012c7:	e8 22 f9 ff ff       	call   800bee <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8012cc:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8012cf:	74 da                	je     8012ab <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8012d1:	85 db                	test   %ebx,%ebx
  8012d3:	74 20                	je     8012f5 <ipc_send+0x62>
		panic("send fail: %e", err);
  8012d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012d9:	c7 44 24 08 8d 1a 80 	movl   $0x801a8d,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 9b 1a 80 00 	movl   $0x801a9b,(%esp)
  8012f0:	e8 4f 00 00 00       	call   801344 <_panic>
	}
	return;
}
  8012f5:	83 c4 1c             	add    $0x1c,%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801309:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801310:	89 c2                	mov    %eax,%edx
  801312:	c1 e2 07             	shl    $0x7,%edx
  801315:	29 ca                	sub    %ecx,%edx
  801317:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80131d:	8b 52 50             	mov    0x50(%edx),%edx
  801320:	39 da                	cmp    %ebx,%edx
  801322:	75 0f                	jne    801333 <ipc_find_env+0x36>
			return envs[i].env_id;
  801324:	c1 e0 07             	shl    $0x7,%eax
  801327:	29 c8                	sub    %ecx,%eax
  801329:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80132e:	8b 40 40             	mov    0x40(%eax),%eax
  801331:	eb 0c                	jmp    80133f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801333:	40                   	inc    %eax
  801334:	3d 00 04 00 00       	cmp    $0x400,%eax
  801339:	75 ce                	jne    801309 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80133b:	66 b8 00 00          	mov    $0x0,%ax
}
  80133f:	5b                   	pop    %ebx
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
	...

00801344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
  801349:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80134c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80134f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801355:	e8 75 f8 ff ff       	call   800bcf <sys_getenvid>
  80135a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801361:	8b 55 08             	mov    0x8(%ebp),%edx
  801364:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801368:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801370:	c7 04 24 a8 1a 80 00 	movl   $0x801aa8,(%esp)
  801377:	e8 d4 ee ff ff       	call   800250 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80137c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801380:	8b 45 10             	mov    0x10(%ebp),%eax
  801383:	89 04 24             	mov    %eax,(%esp)
  801386:	e8 64 ee ff ff       	call   8001ef <vcprintf>
	cprintf("\n");
  80138b:	c7 04 24 5e 1a 80 00 	movl   $0x801a5e,(%esp)
  801392:	e8 b9 ee ff ff       	call   800250 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801397:	cc                   	int3   
  801398:	eb fd                	jmp    801397 <_panic+0x53>
	...

0080139c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013a2:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8013a9:	0f 85 80 00 00 00    	jne    80142f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8013af:	a1 08 20 80 00       	mov    0x802008,%eax
  8013b4:	8b 40 48             	mov    0x48(%eax),%eax
  8013b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013c6:	ee 
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	e8 3e f8 ff ff       	call   800c0d <sys_page_alloc>
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 20                	jns    8013f3 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8013d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d7:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  8013de:	00 
  8013df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013e6:	00 
  8013e7:	c7 04 24 28 1b 80 00 	movl   $0x801b28,(%esp)
  8013ee:	e8 51 ff ff ff       	call   801344 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8013f3:	a1 08 20 80 00       	mov    0x802008,%eax
  8013f8:	8b 40 48             	mov    0x48(%eax),%eax
  8013fb:	c7 44 24 04 3c 14 80 	movl   $0x80143c,0x4(%esp)
  801402:	00 
  801403:	89 04 24             	mov    %eax,(%esp)
  801406:	e8 4f f9 ff ff       	call   800d5a <sys_env_set_pgfault_upcall>
  80140b:	85 c0                	test   %eax,%eax
  80140d:	79 20                	jns    80142f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80140f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801413:	c7 44 24 08 f8 1a 80 	movl   $0x801af8,0x8(%esp)
  80141a:	00 
  80141b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801422:	00 
  801423:	c7 04 24 28 1b 80 00 	movl   $0x801b28,(%esp)
  80142a:	e8 15 ff ff ff       	call   801344 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    
  801439:	00 00                	add    %al,(%eax)
	...

0080143c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80143c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80143d:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801442:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801444:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  801447:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80144b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80144d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  801450:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  801451:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  801454:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  801456:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  801459:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80145a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80145d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80145e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80145f:	c3                   	ret    

00801460 <__udivdi3>:
  801460:	55                   	push   %ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	83 ec 10             	sub    $0x10,%esp
  801466:	8b 74 24 20          	mov    0x20(%esp),%esi
  80146a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80146e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801472:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801476:	89 cd                	mov    %ecx,%ebp
  801478:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80147c:	85 c0                	test   %eax,%eax
  80147e:	75 2c                	jne    8014ac <__udivdi3+0x4c>
  801480:	39 f9                	cmp    %edi,%ecx
  801482:	77 68                	ja     8014ec <__udivdi3+0x8c>
  801484:	85 c9                	test   %ecx,%ecx
  801486:	75 0b                	jne    801493 <__udivdi3+0x33>
  801488:	b8 01 00 00 00       	mov    $0x1,%eax
  80148d:	31 d2                	xor    %edx,%edx
  80148f:	f7 f1                	div    %ecx
  801491:	89 c1                	mov    %eax,%ecx
  801493:	31 d2                	xor    %edx,%edx
  801495:	89 f8                	mov    %edi,%eax
  801497:	f7 f1                	div    %ecx
  801499:	89 c7                	mov    %eax,%edi
  80149b:	89 f0                	mov    %esi,%eax
  80149d:	f7 f1                	div    %ecx
  80149f:	89 c6                	mov    %eax,%esi
  8014a1:	89 f0                	mov    %esi,%eax
  8014a3:	89 fa                	mov    %edi,%edx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	5e                   	pop    %esi
  8014a9:	5f                   	pop    %edi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    
  8014ac:	39 f8                	cmp    %edi,%eax
  8014ae:	77 2c                	ja     8014dc <__udivdi3+0x7c>
  8014b0:	0f bd f0             	bsr    %eax,%esi
  8014b3:	83 f6 1f             	xor    $0x1f,%esi
  8014b6:	75 4c                	jne    801504 <__udivdi3+0xa4>
  8014b8:	39 f8                	cmp    %edi,%eax
  8014ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8014bf:	72 0a                	jb     8014cb <__udivdi3+0x6b>
  8014c1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8014c5:	0f 87 ad 00 00 00    	ja     801578 <__udivdi3+0x118>
  8014cb:	be 01 00 00 00       	mov    $0x1,%esi
  8014d0:	89 f0                	mov    %esi,%eax
  8014d2:	89 fa                	mov    %edi,%edx
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
  8014dc:	31 ff                	xor    %edi,%edi
  8014de:	31 f6                	xor    %esi,%esi
  8014e0:	89 f0                	mov    %esi,%eax
  8014e2:	89 fa                	mov    %edi,%edx
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    
  8014eb:	90                   	nop
  8014ec:	89 fa                	mov    %edi,%edx
  8014ee:	89 f0                	mov    %esi,%eax
  8014f0:	f7 f1                	div    %ecx
  8014f2:	89 c6                	mov    %eax,%esi
  8014f4:	31 ff                	xor    %edi,%edi
  8014f6:	89 f0                	mov    %esi,%eax
  8014f8:	89 fa                	mov    %edi,%edx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
  801501:	8d 76 00             	lea    0x0(%esi),%esi
  801504:	89 f1                	mov    %esi,%ecx
  801506:	d3 e0                	shl    %cl,%eax
  801508:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150c:	b8 20 00 00 00       	mov    $0x20,%eax
  801511:	29 f0                	sub    %esi,%eax
  801513:	89 ea                	mov    %ebp,%edx
  801515:	88 c1                	mov    %al,%cl
  801517:	d3 ea                	shr    %cl,%edx
  801519:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80151d:	09 ca                	or     %ecx,%edx
  80151f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801523:	89 f1                	mov    %esi,%ecx
  801525:	d3 e5                	shl    %cl,%ebp
  801527:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80152b:	89 fd                	mov    %edi,%ebp
  80152d:	88 c1                	mov    %al,%cl
  80152f:	d3 ed                	shr    %cl,%ebp
  801531:	89 fa                	mov    %edi,%edx
  801533:	89 f1                	mov    %esi,%ecx
  801535:	d3 e2                	shl    %cl,%edx
  801537:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80153b:	88 c1                	mov    %al,%cl
  80153d:	d3 ef                	shr    %cl,%edi
  80153f:	09 d7                	or     %edx,%edi
  801541:	89 f8                	mov    %edi,%eax
  801543:	89 ea                	mov    %ebp,%edx
  801545:	f7 74 24 08          	divl   0x8(%esp)
  801549:	89 d1                	mov    %edx,%ecx
  80154b:	89 c7                	mov    %eax,%edi
  80154d:	f7 64 24 0c          	mull   0xc(%esp)
  801551:	39 d1                	cmp    %edx,%ecx
  801553:	72 17                	jb     80156c <__udivdi3+0x10c>
  801555:	74 09                	je     801560 <__udivdi3+0x100>
  801557:	89 fe                	mov    %edi,%esi
  801559:	31 ff                	xor    %edi,%edi
  80155b:	e9 41 ff ff ff       	jmp    8014a1 <__udivdi3+0x41>
  801560:	8b 54 24 04          	mov    0x4(%esp),%edx
  801564:	89 f1                	mov    %esi,%ecx
  801566:	d3 e2                	shl    %cl,%edx
  801568:	39 c2                	cmp    %eax,%edx
  80156a:	73 eb                	jae    801557 <__udivdi3+0xf7>
  80156c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80156f:	31 ff                	xor    %edi,%edi
  801571:	e9 2b ff ff ff       	jmp    8014a1 <__udivdi3+0x41>
  801576:	66 90                	xchg   %ax,%ax
  801578:	31 f6                	xor    %esi,%esi
  80157a:	e9 22 ff ff ff       	jmp    8014a1 <__udivdi3+0x41>
	...

00801580 <__umoddi3>:
  801580:	55                   	push   %ebp
  801581:	57                   	push   %edi
  801582:	56                   	push   %esi
  801583:	83 ec 20             	sub    $0x20,%esp
  801586:	8b 44 24 30          	mov    0x30(%esp),%eax
  80158a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80158e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801592:	8b 74 24 34          	mov    0x34(%esp),%esi
  801596:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80159a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80159e:	89 c7                	mov    %eax,%edi
  8015a0:	89 f2                	mov    %esi,%edx
  8015a2:	85 ed                	test   %ebp,%ebp
  8015a4:	75 16                	jne    8015bc <__umoddi3+0x3c>
  8015a6:	39 f1                	cmp    %esi,%ecx
  8015a8:	0f 86 a6 00 00 00    	jbe    801654 <__umoddi3+0xd4>
  8015ae:	f7 f1                	div    %ecx
  8015b0:	89 d0                	mov    %edx,%eax
  8015b2:	31 d2                	xor    %edx,%edx
  8015b4:	83 c4 20             	add    $0x20,%esp
  8015b7:	5e                   	pop    %esi
  8015b8:	5f                   	pop    %edi
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    
  8015bb:	90                   	nop
  8015bc:	39 f5                	cmp    %esi,%ebp
  8015be:	0f 87 ac 00 00 00    	ja     801670 <__umoddi3+0xf0>
  8015c4:	0f bd c5             	bsr    %ebp,%eax
  8015c7:	83 f0 1f             	xor    $0x1f,%eax
  8015ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ce:	0f 84 a8 00 00 00    	je     80167c <__umoddi3+0xfc>
  8015d4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015d8:	d3 e5                	shl    %cl,%ebp
  8015da:	bf 20 00 00 00       	mov    $0x20,%edi
  8015df:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8015e3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015e7:	89 f9                	mov    %edi,%ecx
  8015e9:	d3 e8                	shr    %cl,%eax
  8015eb:	09 e8                	or     %ebp,%eax
  8015ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8015f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015f5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015f9:	d3 e0                	shl    %cl,%eax
  8015fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ff:	89 f2                	mov    %esi,%edx
  801601:	d3 e2                	shl    %cl,%edx
  801603:	8b 44 24 14          	mov    0x14(%esp),%eax
  801607:	d3 e0                	shl    %cl,%eax
  801609:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80160d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801611:	89 f9                	mov    %edi,%ecx
  801613:	d3 e8                	shr    %cl,%eax
  801615:	09 d0                	or     %edx,%eax
  801617:	d3 ee                	shr    %cl,%esi
  801619:	89 f2                	mov    %esi,%edx
  80161b:	f7 74 24 18          	divl   0x18(%esp)
  80161f:	89 d6                	mov    %edx,%esi
  801621:	f7 64 24 0c          	mull   0xc(%esp)
  801625:	89 c5                	mov    %eax,%ebp
  801627:	89 d1                	mov    %edx,%ecx
  801629:	39 d6                	cmp    %edx,%esi
  80162b:	72 67                	jb     801694 <__umoddi3+0x114>
  80162d:	74 75                	je     8016a4 <__umoddi3+0x124>
  80162f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801633:	29 e8                	sub    %ebp,%eax
  801635:	19 ce                	sbb    %ecx,%esi
  801637:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80163b:	d3 e8                	shr    %cl,%eax
  80163d:	89 f2                	mov    %esi,%edx
  80163f:	89 f9                	mov    %edi,%ecx
  801641:	d3 e2                	shl    %cl,%edx
  801643:	09 d0                	or     %edx,%eax
  801645:	89 f2                	mov    %esi,%edx
  801647:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80164b:	d3 ea                	shr    %cl,%edx
  80164d:	83 c4 20             	add    $0x20,%esp
  801650:	5e                   	pop    %esi
  801651:	5f                   	pop    %edi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    
  801654:	85 c9                	test   %ecx,%ecx
  801656:	75 0b                	jne    801663 <__umoddi3+0xe3>
  801658:	b8 01 00 00 00       	mov    $0x1,%eax
  80165d:	31 d2                	xor    %edx,%edx
  80165f:	f7 f1                	div    %ecx
  801661:	89 c1                	mov    %eax,%ecx
  801663:	89 f0                	mov    %esi,%eax
  801665:	31 d2                	xor    %edx,%edx
  801667:	f7 f1                	div    %ecx
  801669:	89 f8                	mov    %edi,%eax
  80166b:	e9 3e ff ff ff       	jmp    8015ae <__umoddi3+0x2e>
  801670:	89 f2                	mov    %esi,%edx
  801672:	83 c4 20             	add    $0x20,%esp
  801675:	5e                   	pop    %esi
  801676:	5f                   	pop    %edi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    
  801679:	8d 76 00             	lea    0x0(%esi),%esi
  80167c:	39 f5                	cmp    %esi,%ebp
  80167e:	72 04                	jb     801684 <__umoddi3+0x104>
  801680:	39 f9                	cmp    %edi,%ecx
  801682:	77 06                	ja     80168a <__umoddi3+0x10a>
  801684:	89 f2                	mov    %esi,%edx
  801686:	29 cf                	sub    %ecx,%edi
  801688:	19 ea                	sbb    %ebp,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	83 c4 20             	add    $0x20,%esp
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    
  801693:	90                   	nop
  801694:	89 d1                	mov    %edx,%ecx
  801696:	89 c5                	mov    %eax,%ebp
  801698:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80169c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8016a0:	eb 8d                	jmp    80162f <__umoddi3+0xaf>
  8016a2:	66 90                	xchg   %ax,%ax
  8016a4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8016a8:	72 ea                	jb     801694 <__umoddi3+0x114>
  8016aa:	89 f1                	mov    %esi,%ecx
  8016ac:	eb 81                	jmp    80162f <__umoddi3+0xaf>
