
obj/user/pingpongs.debug:     file format elf32-i386


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
  80003d:	e8 23 12 00 00       	call   801265 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 83 0b 00 00       	call   800bd7 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  800063:	e8 f0 01 00 00       	call   800258 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 67 0b 00 00       	call   800bd7 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 fa 24 80 00 	movl   $0x8024fa,(%esp)
  80007f:	e8 d4 01 00 00       	call   800258 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 48 12 00 00       	call   8012ef <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 c6 11 00 00       	call   801288 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 fb 0a 00 00       	call   800bd7 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 10 25 80 00 	movl   $0x802510,(%esp)
  8000fa:	e8 59 01 00 00       	call   800258 <cprintf>
		if (val == 10)
  8000ff:	a1 04 40 80 00       	mov    0x804004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 bd 11 00 00       	call   8012ef <ipc_send>
		if (val == 10)
  800132:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  800156:	e8 7c 0a 00 00       	call   800bd7 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8001a2:	e8 e0 13 00 00       	call   801587 <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 d2 09 00 00       	call   800b85 <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 14             	sub    $0x14,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	40                   	inc    %eax
  8001cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	75 19                	jne    8001ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001dc:	00 
  8001dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 60 09 00 00       	call   800b48 <sys_cputs>
		b->idx = 0;
  8001e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ee:	ff 43 04             	incl   0x4(%ebx)
}
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 b8 01 80 00 	movl   $0x8001b8,(%esp)
  800233:	e8 82 01 00 00       	call   8003ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 f8 08 00 00       	call   800b48 <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 87 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
	...

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 3c             	sub    $0x3c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d7                	mov    %edx,%edi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800291:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800294:	85 c0                	test   %eax,%eax
  800296:	75 08                	jne    8002a0 <printnum+0x2c>
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029e:	77 57                	ja     8002f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a4:	4b                   	dec    %ebx
  8002a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bf:	00 
  8002c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	e8 a6 1f 00 00       	call   802278 <__udivdi3>
  8002d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e1:	89 fa                	mov    %edi,%edx
  8002e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e6:	e8 89 ff ff ff       	call   800274 <printnum>
  8002eb:	eb 0f                	jmp    8002fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f1:	89 34 24             	mov    %esi,(%esp)
  8002f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f7:	4b                   	dec    %ebx
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7f f1                	jg     8002ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 10             	mov    0x10(%ebp),%eax
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800312:	00 
  800313:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800320:	e8 73 20 00 00       	call   802398 <__umoddi3>
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	0f be 80 40 25 80 00 	movsbl 0x802540(%eax),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800336:	83 c4 3c             	add    $0x3c,%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800381:	8b 10                	mov    (%eax),%edx
  800383:	3b 50 04             	cmp    0x4(%eax),%edx
  800386:	73 08                	jae    800390 <sprintputch+0x18>
		*b->buf++ = ch;
  800388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038b:	88 0a                	mov    %cl,(%edx)
  80038d:	42                   	inc    %edx
  80038e:	89 10                	mov    %edx,(%eax)
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80039f:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 02 00 00 00       	call   8003ba <vprintfmt>
	va_end(ap);
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	83 ec 4c             	sub    $0x4c,%esp
  8003c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c9:	eb 12                	jmp    8003dd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	0f 84 8b 03 00 00    	je     80075e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dd:	0f b6 06             	movzbl (%esi),%eax
  8003e0:	46                   	inc    %esi
  8003e1:	83 f8 25             	cmp    $0x25,%eax
  8003e4:	75 e5                	jne    8003cb <vprintfmt+0x11>
  8003e6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800402:	eb 26                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800407:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80040b:	eb 1d                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800410:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800414:	eb 14                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	eb 08                	jmp    80042a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800422:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800425:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 06             	movzbl (%esi),%eax
  80042d:	8d 56 01             	lea    0x1(%esi),%edx
  800430:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800433:	8a 16                	mov    (%esi),%dl
  800435:	83 ea 23             	sub    $0x23,%edx
  800438:	80 fa 55             	cmp    $0x55,%dl
  80043b:	0f 87 01 03 00 00    	ja     800742 <vprintfmt+0x388>
  800441:	0f b6 d2             	movzbl %dl,%edx
  800444:	ff 24 95 80 26 80 00 	jmp    *0x802680(,%edx,4)
  80044b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800453:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800456:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80045a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80045d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800460:	83 fa 09             	cmp    $0x9,%edx
  800463:	77 2a                	ja     80048f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800465:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb eb                	jmp    800453 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800476:	eb 17                	jmp    80048f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047c:	78 98                	js     800416 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800481:	eb a7                	jmp    80042a <vprintfmt+0x70>
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800486:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80048d:	eb 9b                	jmp    80042a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80048f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800493:	79 95                	jns    80042a <vprintfmt+0x70>
  800495:	eb 8b                	jmp    800422 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049b:	eb 8d                	jmp    80042a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b5:	e9 23 ff ff ff       	jmp    8003dd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	79 02                	jns    8004cb <vprintfmt+0x111>
  8004c9:	f7 d8                	neg    %eax
  8004cb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cd:	83 f8 0f             	cmp    $0xf,%eax
  8004d0:	7f 0b                	jg     8004dd <vprintfmt+0x123>
  8004d2:	8b 04 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	75 23                	jne    800500 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e1:	c7 44 24 08 58 25 80 	movl   $0x802558,0x8(%esp)
  8004e8:	00 
  8004e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 9a fe ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004fb:	e9 dd fe ff ff       	jmp    8003dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800500:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800504:	c7 44 24 08 52 2a 80 	movl   $0x802a52,0x8(%esp)
  80050b:	00 
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	8b 55 08             	mov    0x8(%ebp),%edx
  800513:	89 14 24             	mov    %edx,(%esp)
  800516:	e8 77 fe ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	e9 ba fe ff ff       	jmp    8003dd <vprintfmt+0x23>
  800523:	89 f9                	mov    %edi,%ecx
  800525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800528:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	85 f6                	test   %esi,%esi
  800538:	75 05                	jne    80053f <vprintfmt+0x185>
				p = "(null)";
  80053a:	be 51 25 80 00       	mov    $0x802551,%esi
			if (width > 0 && padc != '-')
  80053f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800543:	0f 8e 84 00 00 00    	jle    8005cd <vprintfmt+0x213>
  800549:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80054d:	74 7e                	je     8005cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800553:	89 34 24             	mov    %esi,(%esp)
  800556:	e8 ab 02 00 00       	call   800806 <strnlen>
  80055b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80055e:	29 c2                	sub    %eax,%edx
  800560:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800563:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800567:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80056a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	89 d3                	mov    %edx,%ebx
  800571:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	eb 0b                	jmp    800580 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800575:	89 74 24 04          	mov    %esi,0x4(%esp)
  800579:	89 3c 24             	mov    %edi,(%esp)
  80057c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	4b                   	dec    %ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	7f f1                	jg     800575 <vprintfmt+0x1bb>
  800584:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800587:	89 f3                	mov    %esi,%ebx
  800589:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80058c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	79 05                	jns    800598 <vprintfmt+0x1de>
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059b:	29 c2                	sub    %eax,%edx
  80059d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a0:	eb 2b                	jmp    8005cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a6:	74 18                	je     8005c0 <vprintfmt+0x206>
  8005a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ab:	83 fa 5e             	cmp    $0x5e,%edx
  8005ae:	76 10                	jbe    8005c0 <vprintfmt+0x206>
					putch('?', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	eb 0a                	jmp    8005ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8005cd:	0f be 06             	movsbl (%esi),%eax
  8005d0:	46                   	inc    %esi
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	74 21                	je     8005f6 <vprintfmt+0x23c>
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	78 c9                	js     8005a2 <vprintfmt+0x1e8>
  8005d9:	4f                   	dec    %edi
  8005da:	79 c6                	jns    8005a2 <vprintfmt+0x1e8>
  8005dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005df:	89 de                	mov    %ebx,%esi
  8005e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e4:	eb 18                	jmp    8005fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	eb 08                	jmp    8005fe <vprintfmt+0x244>
  8005f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fe:	85 db                	test   %ebx,%ebx
  800600:	7f e4                	jg     8005e6 <vprintfmt+0x22c>
  800602:	89 7d 08             	mov    %edi,0x8(%ebp)
  800605:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 ce fd ff ff       	jmp    8003dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060f:	83 f9 01             	cmp    $0x1,%ecx
  800612:	7e 10                	jle    800624 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 08             	lea    0x8(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	8b 78 04             	mov    0x4(%eax),%edi
  800622:	eb 26                	jmp    80064a <vprintfmt+0x290>
	else if (lflag)
  800624:	85 c9                	test   %ecx,%ecx
  800626:	74 12                	je     80063a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 30                	mov    (%eax),%esi
  800633:	89 f7                	mov    %esi,%edi
  800635:	c1 ff 1f             	sar    $0x1f,%edi
  800638:	eb 10                	jmp    80064a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	89 f7                	mov    %esi,%edi
  800647:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064a:	85 ff                	test   %edi,%edi
  80064c:	78 0a                	js     800658 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800653:	e9 ac 00 00 00       	jmp    800704 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800666:	f7 de                	neg    %esi
  800668:	83 d7 00             	adc    $0x0,%edi
  80066b:	f7 df                	neg    %edi
			}
			base = 10;
  80066d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800672:	e9 8d 00 00 00       	jmp    800704 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800677:	89 ca                	mov    %ecx,%edx
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 bd fc ff ff       	call   80033e <getuint>
  800681:	89 c6                	mov    %eax,%esi
  800683:	89 d7                	mov    %edx,%edi
			base = 10;
  800685:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068a:	eb 78                	jmp    800704 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ac:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b9:	e9 1f fd ff ff       	jmp    8003dd <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 50 04             	lea    0x4(%eax),%edx
  8006e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e3:	8b 30                	mov    (%eax),%esi
  8006e5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ef:	eb 13                	jmp    800704 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f1:	89 ca                	mov    %ecx,%edx
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 43 fc ff ff       	call   80033e <getuint>
  8006fb:	89 c6                	mov    %eax,%esi
  8006fd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800704:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800708:	89 54 24 10          	mov    %edx,0x10(%esp)
  80070c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800713:	89 44 24 08          	mov    %eax,0x8(%esp)
  800717:	89 34 24             	mov    %esi,(%esp)
  80071a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071e:	89 da                	mov    %ebx,%edx
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	e8 4c fb ff ff       	call   800274 <printnum>
			break;
  800728:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072b:	e9 ad fc ff ff       	jmp    8003dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073d:	e9 9b fc ff ff       	jmp    8003dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800742:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800746:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800750:	eb 01                	jmp    800753 <vprintfmt+0x399>
  800752:	4e                   	dec    %esi
  800753:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800757:	75 f9                	jne    800752 <vprintfmt+0x398>
  800759:	e9 7f fc ff ff       	jmp    8003dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80075e:	83 c4 4c             	add    $0x4c,%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 28             	sub    $0x28,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 30                	je     8007b7 <vsnprintf+0x51>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 33                	jle    8007be <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800792:	8b 45 10             	mov    0x10(%ebp),%eax
  800795:	89 44 24 08          	mov    %eax,0x8(%esp)
  800799:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	c7 04 24 78 03 80 00 	movl   $0x800378,(%esp)
  8007a7:	e8 0e fc ff ff       	call   8003ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b5:	eb 0c                	jmp    8007c3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bc:	eb 05                	jmp    8007c3 <vsnprintf+0x5d>
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	e8 7b ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
  8007ed:	00 00                	add    %al,(%eax)
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 01                	jmp    8007fe <strlen+0xe>
		n++;
  8007fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800802:	75 f9                	jne    8007fd <strlen+0xd>
		n++;
	return n;
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	eb 01                	jmp    800817 <strnlen+0x11>
		n++;
  800816:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	39 d0                	cmp    %edx,%eax
  800819:	74 06                	je     800821 <strnlen+0x1b>
  80081b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081f:	75 f5                	jne    800816 <strnlen+0x10>
		n++;
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
  800832:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800835:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800838:	42                   	inc    %edx
  800839:	84 c9                	test   %cl,%cl
  80083b:	75 f5                	jne    800832 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80083d:	5b                   	pop    %ebx
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084a:	89 1c 24             	mov    %ebx,(%esp)
  80084d:	e8 9e ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 54 24 04          	mov    %edx,0x4(%esp)
  800859:	01 d8                	add    %ebx,%eax
  80085b:	89 04 24             	mov    %eax,(%esp)
  80085e:	e8 c0 ff ff ff       	call   800823 <strcpy>
	return dst;
}
  800863:	89 d8                	mov    %ebx,%eax
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087e:	eb 0c                	jmp    80088c <strncpy+0x21>
		*dst++ = *src;
  800880:	8a 1a                	mov    (%edx),%bl
  800882:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800885:	80 3a 01             	cmpb   $0x1,(%edx)
  800888:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088b:	41                   	inc    %ecx
  80088c:	39 f1                	cmp    %esi,%ecx
  80088e:	75 f0                	jne    800880 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	75 0a                	jne    8008b0 <strlcpy+0x1c>
  8008a6:	89 f0                	mov    %esi,%eax
  8008a8:	eb 1a                	jmp    8008c4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008aa:	88 18                	mov    %bl,(%eax)
  8008ac:	40                   	inc    %eax
  8008ad:	41                   	inc    %ecx
  8008ae:	eb 02                	jmp    8008b2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008b2:	4a                   	dec    %edx
  8008b3:	74 0a                	je     8008bf <strlcpy+0x2b>
  8008b5:	8a 19                	mov    (%ecx),%bl
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	75 ef                	jne    8008aa <strlcpy+0x16>
  8008bb:	89 c2                	mov    %eax,%edx
  8008bd:	eb 02                	jmp    8008c1 <strlcpy+0x2d>
  8008bf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008c1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c4:	29 f0                	sub    %esi,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d3:	eb 02                	jmp    8008d7 <strcmp+0xd>
		p++, q++;
  8008d5:	41                   	inc    %ecx
  8008d6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d7:	8a 01                	mov    (%ecx),%al
  8008d9:	84 c0                	test   %al,%al
  8008db:	74 04                	je     8008e1 <strcmp+0x17>
  8008dd:	3a 02                	cmp    (%edx),%al
  8008df:	74 f4                	je     8008d5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 c0             	movzbl %al,%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008f8:	eb 03                	jmp    8008fd <strncmp+0x12>
		n--, p++, q++;
  8008fa:	4a                   	dec    %edx
  8008fb:	40                   	inc    %eax
  8008fc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fd:	85 d2                	test   %edx,%edx
  8008ff:	74 14                	je     800915 <strncmp+0x2a>
  800901:	8a 18                	mov    (%eax),%bl
  800903:	84 db                	test   %bl,%bl
  800905:	74 04                	je     80090b <strncmp+0x20>
  800907:	3a 19                	cmp    (%ecx),%bl
  800909:	74 ef                	je     8008fa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 00             	movzbl (%eax),%eax
  80090e:	0f b6 11             	movzbl (%ecx),%edx
  800911:	29 d0                	sub    %edx,%eax
  800913:	eb 05                	jmp    80091a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800926:	eb 05                	jmp    80092d <strchr+0x10>
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	74 0c                	je     800938 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092c:	40                   	inc    %eax
  80092d:	8a 10                	mov    (%eax),%dl
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f5                	jne    800928 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800943:	eb 05                	jmp    80094a <strfind+0x10>
		if (*s == c)
  800945:	38 ca                	cmp    %cl,%dl
  800947:	74 07                	je     800950 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800949:	40                   	inc    %eax
  80094a:	8a 10                	mov    (%eax),%dl
  80094c:	84 d2                	test   %dl,%dl
  80094e:	75 f5                	jne    800945 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800961:	85 c9                	test   %ecx,%ecx
  800963:	74 30                	je     800995 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800965:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096b:	75 25                	jne    800992 <memset+0x40>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 20                	jne    800992 <memset+0x40>
		c &= 0xFF;
  800972:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d6                	mov    %edx,%esi
  80097c:	c1 e6 18             	shl    $0x18,%esi
  80097f:	89 d0                	mov    %edx,%eax
  800981:	c1 e0 10             	shl    $0x10,%eax
  800984:	09 f0                	or     %esi,%eax
  800986:	09 d0                	or     %edx,%eax
  800988:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80098d:	fc                   	cld    
  80098e:	f3 ab                	rep stos %eax,%es:(%edi)
  800990:	eb 03                	jmp    800995 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800992:	fc                   	cld    
  800993:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800995:	89 f8                	mov    %edi,%eax
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009aa:	39 c6                	cmp    %eax,%esi
  8009ac:	73 34                	jae    8009e2 <memmove+0x46>
  8009ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b1:	39 d0                	cmp    %edx,%eax
  8009b3:	73 2d                	jae    8009e2 <memmove+0x46>
		s += n;
		d += n;
  8009b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b8:	f6 c2 03             	test   $0x3,%dl
  8009bb:	75 1b                	jne    8009d8 <memmove+0x3c>
  8009bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c3:	75 13                	jne    8009d8 <memmove+0x3c>
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 0e                	jne    8009d8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ca:	83 ef 04             	sub    $0x4,%edi
  8009cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d3:	fd                   	std    
  8009d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d6:	eb 07                	jmp    8009df <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d8:	4f                   	dec    %edi
  8009d9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009dc:	fd                   	std    
  8009dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009df:	fc                   	cld    
  8009e0:	eb 20                	jmp    800a02 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e8:	75 13                	jne    8009fd <memmove+0x61>
  8009ea:	a8 03                	test   $0x3,%al
  8009ec:	75 0f                	jne    8009fd <memmove+0x61>
  8009ee:	f6 c1 03             	test   $0x3,%cl
  8009f1:	75 0a                	jne    8009fd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fb:	eb 05                	jmp    800a02 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	fc                   	cld    
  800a00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	89 04 24             	mov    %eax,(%esp)
  800a20:	e8 77 ff ff ff       	call   80099c <memmove>
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a36:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3b:	eb 16                	jmp    800a53 <memcmp+0x2c>
		if (*s1 != *s2)
  800a3d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a40:	42                   	inc    %edx
  800a41:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a45:	38 c8                	cmp    %cl,%al
  800a47:	74 0a                	je     800a53 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a49:	0f b6 c0             	movzbl %al,%eax
  800a4c:	0f b6 c9             	movzbl %cl,%ecx
  800a4f:	29 c8                	sub    %ecx,%eax
  800a51:	eb 09                	jmp    800a5c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	39 da                	cmp    %ebx,%edx
  800a55:	75 e6                	jne    800a3d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6a:	89 c2                	mov    %eax,%edx
  800a6c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6f:	eb 05                	jmp    800a76 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a71:	38 08                	cmp    %cl,(%eax)
  800a73:	74 05                	je     800a7a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a75:	40                   	inc    %eax
  800a76:	39 d0                	cmp    %edx,%eax
  800a78:	72 f7                	jb     800a71 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a88:	eb 01                	jmp    800a8b <strtol+0xf>
		s++;
  800a8a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	8a 02                	mov    (%edx),%al
  800a8d:	3c 20                	cmp    $0x20,%al
  800a8f:	74 f9                	je     800a8a <strtol+0xe>
  800a91:	3c 09                	cmp    $0x9,%al
  800a93:	74 f5                	je     800a8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a95:	3c 2b                	cmp    $0x2b,%al
  800a97:	75 08                	jne    800aa1 <strtol+0x25>
		s++;
  800a99:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9f:	eb 13                	jmp    800ab4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa1:	3c 2d                	cmp    $0x2d,%al
  800aa3:	75 0a                	jne    800aaf <strtol+0x33>
		s++, neg = 1;
  800aa5:	8d 52 01             	lea    0x1(%edx),%edx
  800aa8:	bf 01 00 00 00       	mov    $0x1,%edi
  800aad:	eb 05                	jmp    800ab4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab4:	85 db                	test   %ebx,%ebx
  800ab6:	74 05                	je     800abd <strtol+0x41>
  800ab8:	83 fb 10             	cmp    $0x10,%ebx
  800abb:	75 28                	jne    800ae5 <strtol+0x69>
  800abd:	8a 02                	mov    (%edx),%al
  800abf:	3c 30                	cmp    $0x30,%al
  800ac1:	75 10                	jne    800ad3 <strtol+0x57>
  800ac3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac7:	75 0a                	jne    800ad3 <strtol+0x57>
		s += 2, base = 16;
  800ac9:	83 c2 02             	add    $0x2,%edx
  800acc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad1:	eb 12                	jmp    800ae5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad3:	85 db                	test   %ebx,%ebx
  800ad5:	75 0e                	jne    800ae5 <strtol+0x69>
  800ad7:	3c 30                	cmp    $0x30,%al
  800ad9:	75 05                	jne    800ae0 <strtol+0x64>
		s++, base = 8;
  800adb:	42                   	inc    %edx
  800adc:	b3 08                	mov    $0x8,%bl
  800ade:	eb 05                	jmp    800ae5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ae0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aec:	8a 0a                	mov    (%edx),%cl
  800aee:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af1:	80 fb 09             	cmp    $0x9,%bl
  800af4:	77 08                	ja     800afe <strtol+0x82>
			dig = *s - '0';
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 30             	sub    $0x30,%ecx
  800afc:	eb 1e                	jmp    800b1c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800afe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 08                	ja     800b0e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 57             	sub    $0x57,%ecx
  800b0c:	eb 0e                	jmp    800b1c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b0e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b11:	80 fb 19             	cmp    $0x19,%bl
  800b14:	77 12                	ja     800b28 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b16:	0f be c9             	movsbl %cl,%ecx
  800b19:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b1c:	39 f1                	cmp    %esi,%ecx
  800b1e:	7d 0c                	jge    800b2c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b20:	42                   	inc    %edx
  800b21:	0f af c6             	imul   %esi,%eax
  800b24:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b26:	eb c4                	jmp    800aec <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b28:	89 c1                	mov    %eax,%ecx
  800b2a:	eb 02                	jmp    800b2e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b32:	74 05                	je     800b39 <strtol+0xbd>
		*endptr = (char *) s;
  800b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b37:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b39:	85 ff                	test   %edi,%edi
  800b3b:	74 04                	je     800b41 <strtol+0xc5>
  800b3d:	89 c8                	mov    %ecx,%eax
  800b3f:	f7 d8                	neg    %eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
	...

00800b48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	89 c3                	mov    %eax,%ebx
  800b5b:	89 c7                	mov    %eax,%edi
  800b5d:	89 c6                	mov    %eax,%esi
  800b5f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b93:	b8 03 00 00 00       	mov    $0x3,%eax
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	89 cb                	mov    %ecx,%ebx
  800b9d:	89 cf                	mov    %ecx,%edi
  800b9f:	89 ce                	mov    %ecx,%esi
  800ba1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 28                	jle    800bcf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bab:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800bba:	00 
  800bbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc2:	00 
  800bc3:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800bca:	e8 49 15 00 00       	call   802118 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcf:	83 c4 2c             	add    $0x2c,%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 02 00 00 00       	mov    $0x2,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_yield>:

void
sys_yield(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	be 00 00 00 00       	mov    $0x0,%esi
  800c23:	b8 04 00 00 00       	mov    $0x4,%eax
  800c28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 f7                	mov    %esi,%edi
  800c33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 28                	jle    800c61 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c44:	00 
  800c45:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800c4c:	00 
  800c4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c54:	00 
  800c55:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800c5c:	e8 b7 14 00 00       	call   802118 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c61:	83 c4 2c             	add    $0x2c,%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 28                	jle    800cb4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c90:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c97:	00 
  800c98:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800c9f:	00 
  800ca0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca7:	00 
  800ca8:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800caf:	e8 64 14 00 00       	call   802118 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb4:	83 c4 2c             	add    $0x2c,%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 28                	jle    800d07 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cea:	00 
  800ceb:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfa:	00 
  800cfb:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800d02:	e8 11 14 00 00       	call   802118 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d07:	83 c4 2c             	add    $0x2c,%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 df                	mov    %ebx,%edi
  800d2a:	89 de                	mov    %ebx,%esi
  800d2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 28                	jle    800d5a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d36:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800d45:	00 
  800d46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4d:	00 
  800d4e:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800d55:	e8 be 13 00 00       	call   802118 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5a:	83 c4 2c             	add    $0x2c,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	b8 09 00 00 00       	mov    $0x9,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800da8:	e8 6b 13 00 00       	call   802118 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7e 28                	jle    800e00 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800de3:	00 
  800de4:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800deb:	00 
  800dec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df3:	00 
  800df4:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800dfb:	e8 18 13 00 00       	call   802118 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e00:	83 c4 2c             	add    $0x2c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	be 00 00 00 00       	mov    $0x0,%esi
  800e13:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e39:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	89 cb                	mov    %ecx,%ebx
  800e43:	89 cf                	mov    %ecx,%edi
  800e45:	89 ce                	mov    %ecx,%esi
  800e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 28                	jle    800e75 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e51:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e58:	00 
  800e59:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e70:	e8 a3 12 00 00       	call   802118 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e75:	83 c4 2c             	add    $0x2c,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
  800e7d:	00 00                	add    %al,(%eax)
	...

00800e80 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	53                   	push   %ebx
  800e84:	83 ec 24             	sub    $0x24,%esp
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800e8c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e90:	75 20                	jne    800eb2 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e92:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e96:	c7 44 24 08 6c 28 80 	movl   $0x80286c,0x8(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800ea5:	00 
  800ea6:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  800ead:	e8 66 12 00 00       	call   802118 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eb2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800ebd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec4:	f6 c4 08             	test   $0x8,%ah
  800ec7:	75 1c                	jne    800ee5 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ec9:	c7 44 24 08 9c 28 80 	movl   $0x80289c,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  800ee0:	e8 33 12 00 00       	call   802118 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800ee5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eec:	00 
  800eed:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ef4:	00 
  800ef5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efc:	e8 14 fd ff ff       	call   800c15 <sys_page_alloc>
  800f01:	85 c0                	test   %eax,%eax
  800f03:	79 20                	jns    800f25 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800f05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f09:	c7 44 24 08 f6 28 80 	movl   $0x8028f6,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  800f20:	e8 f3 11 00 00       	call   802118 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800f25:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f2c:	00 
  800f2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f31:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f38:	e8 5f fa ff ff       	call   80099c <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800f3d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f44:	00 
  800f45:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f60:	e8 04 fd ff ff       	call   800c69 <sys_page_map>
  800f65:	85 c0                	test   %eax,%eax
  800f67:	79 20                	jns    800f89 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6d:	c7 44 24 08 09 29 80 	movl   $0x802909,0x8(%esp)
  800f74:	00 
  800f75:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f7c:	00 
  800f7d:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  800f84:	e8 8f 11 00 00       	call   802118 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800f89:	83 c4 24             	add    $0x24,%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	53                   	push   %ebx
  800f95:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f98:	c7 04 24 80 0e 80 00 	movl   $0x800e80,(%esp)
  800f9f:	e8 cc 11 00 00       	call   802170 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa4:	ba 07 00 00 00       	mov    $0x7,%edx
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	cd 30                	int    $0x30
  800fad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 20                	jns    800fd7 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800fb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fbb:	c7 44 24 08 1a 29 80 	movl   $0x80291a,0x8(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800fca:	00 
  800fcb:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  800fd2:	e8 41 11 00 00       	call   802118 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800fd7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fdb:	75 25                	jne    801002 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fdd:	e8 f5 fb ff ff       	call   800bd7 <sys_getenvid>
  800fe2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fee:	c1 e0 07             	shl    $0x7,%eax
  800ff1:	29 d0                	sub    %edx,%eax
  800ff3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ff8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ffd:	e9 58 02 00 00       	jmp    80125a <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  801002:	bf 00 00 00 00       	mov    $0x0,%edi
  801007:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80100c:	89 f0                	mov    %esi,%eax
  80100e:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801011:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801018:	a8 01                	test   $0x1,%al
  80101a:	0f 84 7a 01 00 00    	je     80119a <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801020:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801027:	a8 01                	test   $0x1,%al
  801029:	0f 84 6b 01 00 00    	je     80119a <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80102f:	a1 08 40 80 00       	mov    0x804008,%eax
  801034:	8b 40 48             	mov    0x48(%eax),%eax
  801037:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  80103a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801041:	f6 c4 04             	test   $0x4,%ah
  801044:	74 52                	je     801098 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801046:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104d:	25 07 0e 00 00       	and    $0xe07,%eax
  801052:	89 44 24 10          	mov    %eax,0x10(%esp)
  801056:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80105d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801061:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801068:	89 04 24             	mov    %eax,(%esp)
  80106b:	e8 f9 fb ff ff       	call   800c69 <sys_page_map>
  801070:	85 c0                	test   %eax,%eax
  801072:	0f 89 22 01 00 00    	jns    80119a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801078:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80107c:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  801083:	00 
  801084:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80108b:	00 
  80108c:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  801093:	e8 80 10 00 00       	call   802118 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801098:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109f:	f6 c4 08             	test   $0x8,%ah
  8010a2:	75 0f                	jne    8010b3 <fork+0x124>
  8010a4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ab:	a8 02                	test   $0x2,%al
  8010ad:	0f 84 99 00 00 00    	je     80114c <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8010b3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ba:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8010bd:	83 f8 01             	cmp    $0x1,%eax
  8010c0:	19 db                	sbb    %ebx,%ebx
  8010c2:	83 e3 fc             	and    $0xfffffffc,%ebx
  8010c5:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010cb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010cf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	e8 80 fb ff ff       	call   800c69 <sys_page_map>
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 20                	jns    80110d <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8010ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f1:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  801108:	e8 0b 10 00 00       	call   802118 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80110d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801111:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801118:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801120:	89 04 24             	mov    %eax,(%esp)
  801123:	e8 41 fb ff ff       	call   800c69 <sys_page_map>
  801128:	85 c0                	test   %eax,%eax
  80112a:	79 6e                	jns    80119a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80112c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801130:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  801137:	00 
  801138:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  801147:	e8 cc 0f 00 00       	call   802118 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80114c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801153:	25 07 0e 00 00       	and    $0xe07,%eax
  801158:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801160:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801163:	89 44 24 08          	mov    %eax,0x8(%esp)
  801167:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80116b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116e:	89 04 24             	mov    %eax,(%esp)
  801171:	e8 f3 fa ff ff       	call   800c69 <sys_page_map>
  801176:	85 c0                	test   %eax,%eax
  801178:	79 20                	jns    80119a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80117a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117e:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  801185:	00 
  801186:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  80118d:	00 
  80118e:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  801195:	e8 7e 0f 00 00       	call   802118 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  80119a:	46                   	inc    %esi
  80119b:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011a1:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8011a7:	0f 85 5f fe ff ff    	jne    80100c <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8011ad:	c7 44 24 04 10 22 80 	movl   $0x802210,0x4(%esp)
  8011b4:	00 
  8011b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b8:	89 04 24             	mov    %eax,(%esp)
  8011bb:	e8 f5 fb ff ff       	call   800db5 <sys_env_set_pgfault_upcall>
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 20                	jns    8011e4 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c8:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011d7:	00 
  8011d8:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  8011df:	e8 34 0f 00 00       	call   802118 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8011e4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011f3:	ee 
  8011f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	e8 16 fa ff ff       	call   800c15 <sys_page_alloc>
  8011ff:	85 c0                	test   %eax,%eax
  801201:	79 20                	jns    801223 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  801203:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801207:	c7 44 24 08 f6 28 80 	movl   $0x8028f6,0x8(%esp)
  80120e:	00 
  80120f:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801216:	00 
  801217:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  80121e:	e8 f5 0e 00 00       	call   802118 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801223:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80122a:	00 
  80122b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80122e:	89 04 24             	mov    %eax,(%esp)
  801231:	e8 d9 fa ff ff       	call   800d0f <sys_env_set_status>
  801236:	85 c0                	test   %eax,%eax
  801238:	79 20                	jns    80125a <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  80123a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123e:	c7 44 24 08 3c 29 80 	movl   $0x80293c,0x8(%esp)
  801245:	00 
  801246:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80124d:	00 
  80124e:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  801255:	e8 be 0e 00 00       	call   802118 <_panic>
	}
	
	return envid;
}
  80125a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80125d:	83 c4 3c             	add    $0x3c,%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <sfork>:

// Challenge!
int
sfork(void)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80126b:	c7 44 24 08 53 29 80 	movl   $0x802953,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  80127a:	00 
  80127b:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  801282:	e8 91 0e 00 00       	call   802118 <_panic>
	...

00801288 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 10             	sub    $0x10,%esp
  801290:	8b 75 08             	mov    0x8(%ebp),%esi
  801293:	8b 45 0c             	mov    0xc(%ebp),%eax
  801296:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801299:	85 c0                	test   %eax,%eax
  80129b:	75 05                	jne    8012a2 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  80129d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 81 fb ff ff       	call   800e2b <sys_ipc_recv>
	if (!err) {
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	75 26                	jne    8012d4 <ipc_recv+0x4c>
		if (from_env_store) {
  8012ae:	85 f6                	test   %esi,%esi
  8012b0:	74 0a                	je     8012bc <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8012b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b7:	8b 40 74             	mov    0x74(%eax),%eax
  8012ba:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8012bc:	85 db                	test   %ebx,%ebx
  8012be:	74 0a                	je     8012ca <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8012c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c5:	8b 40 78             	mov    0x78(%eax),%eax
  8012c8:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8012ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8012cf:	8b 40 70             	mov    0x70(%eax),%eax
  8012d2:	eb 14                	jmp    8012e8 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8012d4:	85 f6                	test   %esi,%esi
  8012d6:	74 06                	je     8012de <ipc_recv+0x56>
		*from_env_store = 0;
  8012d8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8012de:	85 db                	test   %ebx,%ebx
  8012e0:	74 06                	je     8012e8 <ipc_recv+0x60>
		*perm_store = 0;
  8012e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	57                   	push   %edi
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 1c             	sub    $0x1c,%esp
  8012f8:	8b 75 10             	mov    0x10(%ebp),%esi
  8012fb:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8012fe:	85 f6                	test   %esi,%esi
  801300:	75 05                	jne    801307 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801302:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801307:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80130b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80130f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801312:	89 44 24 04          	mov    %eax,0x4(%esp)
  801316:	8b 45 08             	mov    0x8(%ebp),%eax
  801319:	89 04 24             	mov    %eax,(%esp)
  80131c:	e8 e7 fa ff ff       	call   800e08 <sys_ipc_try_send>
  801321:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801323:	e8 ce f8 ff ff       	call   800bf6 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801328:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80132b:	74 da                	je     801307 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  80132d:	85 db                	test   %ebx,%ebx
  80132f:	74 20                	je     801351 <ipc_send+0x62>
		panic("send fail: %e", err);
  801331:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801335:	c7 44 24 08 69 29 80 	movl   $0x802969,0x8(%esp)
  80133c:	00 
  80133d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801344:	00 
  801345:	c7 04 24 77 29 80 00 	movl   $0x802977,(%esp)
  80134c:	e8 c7 0d 00 00       	call   802118 <_panic>
	}
	return;
}
  801351:	83 c4 1c             	add    $0x1c,%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	53                   	push   %ebx
  80135d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801360:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801365:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	c1 e2 07             	shl    $0x7,%edx
  801371:	29 ca                	sub    %ecx,%edx
  801373:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801379:	8b 52 50             	mov    0x50(%edx),%edx
  80137c:	39 da                	cmp    %ebx,%edx
  80137e:	75 0f                	jne    80138f <ipc_find_env+0x36>
			return envs[i].env_id;
  801380:	c1 e0 07             	shl    $0x7,%eax
  801383:	29 c8                	sub    %ecx,%eax
  801385:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80138a:	8b 40 40             	mov    0x40(%eax),%eax
  80138d:	eb 0c                	jmp    80139b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80138f:	40                   	inc    %eax
  801390:	3d 00 04 00 00       	cmp    $0x400,%eax
  801395:	75 ce                	jne    801365 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801397:	66 b8 00 00          	mov    $0x0,%ax
}
  80139b:	5b                   	pop    %ebx
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    
	...

008013a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b9:	89 04 24             	mov    %eax,(%esp)
  8013bc:	e8 df ff ff ff       	call   8013a0 <fd2num>
  8013c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013d2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013d7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	c1 ea 16             	shr    $0x16,%edx
  8013de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e5:	f6 c2 01             	test   $0x1,%dl
  8013e8:	74 11                	je     8013fb <fd_alloc+0x30>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 0c             	shr    $0xc,%edx
  8013ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	75 09                	jne    801404 <fd_alloc+0x39>
			*fd_store = fd;
  8013fb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801402:	eb 17                	jmp    80141b <fd_alloc+0x50>
  801404:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801409:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140e:	75 c7                	jne    8013d7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801416:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141b:	5b                   	pop    %ebx
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801424:	83 f8 1f             	cmp    $0x1f,%eax
  801427:	77 36                	ja     80145f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801429:	05 00 00 0d 00       	add    $0xd0000,%eax
  80142e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801431:	89 c2                	mov    %eax,%edx
  801433:	c1 ea 16             	shr    $0x16,%edx
  801436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	74 24                	je     801466 <fd_lookup+0x48>
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 0c             	shr    $0xc,%edx
  801447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 1a                	je     80146d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801453:	8b 55 0c             	mov    0xc(%ebp),%edx
  801456:	89 02                	mov    %eax,(%edx)
	return 0;
  801458:	b8 00 00 00 00       	mov    $0x0,%eax
  80145d:	eb 13                	jmp    801472 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801464:	eb 0c                	jmp    801472 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146b:	eb 05                	jmp    801472 <fd_lookup+0x54>
  80146d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 14             	sub    $0x14,%esp
  80147b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	ba 00 00 00 00       	mov    $0x0,%edx
  801486:	eb 0e                	jmp    801496 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801488:	39 08                	cmp    %ecx,(%eax)
  80148a:	75 09                	jne    801495 <dev_lookup+0x21>
			*dev = devtab[i];
  80148c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	eb 33                	jmp    8014c8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801495:	42                   	inc    %edx
  801496:	8b 04 95 00 2a 80 00 	mov    0x802a00(,%edx,4),%eax
  80149d:	85 c0                	test   %eax,%eax
  80149f:	75 e7                	jne    801488 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a6:	8b 40 48             	mov    0x48(%eax),%eax
  8014a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b1:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  8014b8:	e8 9b ed ff ff       	call   800258 <cprintf>
	*dev = 0;
  8014bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c8:	83 c4 14             	add    $0x14,%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 30             	sub    $0x30,%esp
  8014d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d9:	8a 45 0c             	mov    0xc(%ebp),%al
  8014dc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014df:	89 34 24             	mov    %esi,(%esp)
  8014e2:	e8 b9 fe ff ff       	call   8013a0 <fd2num>
  8014e7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 28 ff ff ff       	call   80141e <fd_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 05                	js     801501 <fd_close+0x33>
	    || fd != fd2)
  8014fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ff:	74 0d                	je     80150e <fd_close+0x40>
		return (must_exist ? r : 0);
  801501:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801505:	75 46                	jne    80154d <fd_close+0x7f>
  801507:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150c:	eb 3f                	jmp    80154d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80150e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801511:	89 44 24 04          	mov    %eax,0x4(%esp)
  801515:	8b 06                	mov    (%esi),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 55 ff ff ff       	call   801474 <dev_lookup>
  80151f:	89 c3                	mov    %eax,%ebx
  801521:	85 c0                	test   %eax,%eax
  801523:	78 18                	js     80153d <fd_close+0x6f>
		if (dev->dev_close)
  801525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801528:	8b 40 10             	mov    0x10(%eax),%eax
  80152b:	85 c0                	test   %eax,%eax
  80152d:	74 09                	je     801538 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80152f:	89 34 24             	mov    %esi,(%esp)
  801532:	ff d0                	call   *%eax
  801534:	89 c3                	mov    %eax,%ebx
  801536:	eb 05                	jmp    80153d <fd_close+0x6f>
		else
			r = 0;
  801538:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80153d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801541:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801548:	e8 6f f7 ff ff       	call   800cbc <sys_page_unmap>
	return r;
}
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	83 c4 30             	add    $0x30,%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	89 04 24             	mov    %eax,(%esp)
  801569:	e8 b0 fe ff ff       	call   80141e <fd_lookup>
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 13                	js     801585 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801572:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801579:	00 
  80157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157d:	89 04 24             	mov    %eax,(%esp)
  801580:	e8 49 ff ff ff       	call   8014ce <fd_close>
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <close_all>:

void
close_all(void)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80158e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801593:	89 1c 24             	mov    %ebx,(%esp)
  801596:	e8 bb ff ff ff       	call   801556 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80159b:	43                   	inc    %ebx
  80159c:	83 fb 20             	cmp    $0x20,%ebx
  80159f:	75 f2                	jne    801593 <close_all+0xc>
		close(i);
}
  8015a1:	83 c4 14             	add    $0x14,%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 4c             	sub    $0x4c,%esp
  8015b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	89 04 24             	mov    %eax,(%esp)
  8015c0:	e8 59 fe ff ff       	call   80141e <fd_lookup>
  8015c5:	89 c3                	mov    %eax,%ebx
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	0f 88 e1 00 00 00    	js     8016b0 <dup+0x109>
		return r;
	close(newfdnum);
  8015cf:	89 3c 24             	mov    %edi,(%esp)
  8015d2:	e8 7f ff ff ff       	call   801556 <close>

	newfd = INDEX2FD(newfdnum);
  8015d7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015dd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 c5 fd ff ff       	call   8013b0 <fd2data>
  8015eb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015ed:	89 34 24             	mov    %esi,(%esp)
  8015f0:	e8 bb fd ff ff       	call   8013b0 <fd2data>
  8015f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015f8:	89 d8                	mov    %ebx,%eax
  8015fa:	c1 e8 16             	shr    $0x16,%eax
  8015fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801604:	a8 01                	test   $0x1,%al
  801606:	74 46                	je     80164e <dup+0xa7>
  801608:	89 d8                	mov    %ebx,%eax
  80160a:	c1 e8 0c             	shr    $0xc,%eax
  80160d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801614:	f6 c2 01             	test   $0x1,%dl
  801617:	74 35                	je     80164e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801619:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801620:	25 07 0e 00 00       	and    $0xe07,%eax
  801625:	89 44 24 10          	mov    %eax,0x10(%esp)
  801629:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80162c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801630:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801637:	00 
  801638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80163c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801643:	e8 21 f6 ff ff       	call   800c69 <sys_page_map>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 3b                	js     801689 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80164e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801651:	89 c2                	mov    %eax,%edx
  801653:	c1 ea 0c             	shr    $0xc,%edx
  801656:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80165d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801663:	89 54 24 10          	mov    %edx,0x10(%esp)
  801667:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80166b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801672:	00 
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167e:	e8 e6 f5 ff ff       	call   800c69 <sys_page_map>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	85 c0                	test   %eax,%eax
  801687:	79 25                	jns    8016ae <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801689:	89 74 24 04          	mov    %esi,0x4(%esp)
  80168d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801694:	e8 23 f6 ff ff       	call   800cbc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801699:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80169c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a7:	e8 10 f6 ff ff       	call   800cbc <sys_page_unmap>
	return r;
  8016ac:	eb 02                	jmp    8016b0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016ae:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016b0:	89 d8                	mov    %ebx,%eax
  8016b2:	83 c4 4c             	add    $0x4c,%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5f                   	pop    %edi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 24             	sub    $0x24,%esp
  8016c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	89 1c 24             	mov    %ebx,(%esp)
  8016ce:	e8 4b fd ff ff       	call   80141e <fd_lookup>
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 6d                	js     801744 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e1:	8b 00                	mov    (%eax),%eax
  8016e3:	89 04 24             	mov    %eax,(%esp)
  8016e6:	e8 89 fd ff ff       	call   801474 <dev_lookup>
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 55                	js     801744 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f2:	8b 50 08             	mov    0x8(%eax),%edx
  8016f5:	83 e2 03             	and    $0x3,%edx
  8016f8:	83 fa 01             	cmp    $0x1,%edx
  8016fb:	75 23                	jne    801720 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fd:	a1 08 40 80 00       	mov    0x804008,%eax
  801702:	8b 40 48             	mov    0x48(%eax),%eax
  801705:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170d:	c7 04 24 c5 29 80 00 	movl   $0x8029c5,(%esp)
  801714:	e8 3f eb ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  801719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171e:	eb 24                	jmp    801744 <read+0x8a>
	}
	if (!dev->dev_read)
  801720:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801723:	8b 52 08             	mov    0x8(%edx),%edx
  801726:	85 d2                	test   %edx,%edx
  801728:	74 15                	je     80173f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80172a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80172d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801738:	89 04 24             	mov    %eax,(%esp)
  80173b:	ff d2                	call   *%edx
  80173d:	eb 05                	jmp    801744 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80173f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801744:	83 c4 24             	add    $0x24,%esp
  801747:	5b                   	pop    %ebx
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	57                   	push   %edi
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 1c             	sub    $0x1c,%esp
  801753:	8b 7d 08             	mov    0x8(%ebp),%edi
  801756:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801759:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175e:	eb 23                	jmp    801783 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801760:	89 f0                	mov    %esi,%eax
  801762:	29 d8                	sub    %ebx,%eax
  801764:	89 44 24 08          	mov    %eax,0x8(%esp)
  801768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176b:	01 d8                	add    %ebx,%eax
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	89 3c 24             	mov    %edi,(%esp)
  801774:	e8 41 ff ff ff       	call   8016ba <read>
		if (m < 0)
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 10                	js     80178d <readn+0x43>
			return m;
		if (m == 0)
  80177d:	85 c0                	test   %eax,%eax
  80177f:	74 0a                	je     80178b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801781:	01 c3                	add    %eax,%ebx
  801783:	39 f3                	cmp    %esi,%ebx
  801785:	72 d9                	jb     801760 <readn+0x16>
  801787:	89 d8                	mov    %ebx,%eax
  801789:	eb 02                	jmp    80178d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80178b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80178d:	83 c4 1c             	add    $0x1c,%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5f                   	pop    %edi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	83 ec 24             	sub    $0x24,%esp
  80179c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a6:	89 1c 24             	mov    %ebx,(%esp)
  8017a9:	e8 70 fc ff ff       	call   80141e <fd_lookup>
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 68                	js     80181a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	8b 00                	mov    (%eax),%eax
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	e8 ae fc ff ff       	call   801474 <dev_lookup>
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 50                	js     80181a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d1:	75 23                	jne    8017f6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8017d8:	8b 40 48             	mov    0x48(%eax),%eax
  8017db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e3:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  8017ea:	e8 69 ea ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  8017ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f4:	eb 24                	jmp    80181a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fc:	85 d2                	test   %edx,%edx
  8017fe:	74 15                	je     801815 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801800:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801803:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	ff d2                	call   *%edx
  801813:	eb 05                	jmp    80181a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801815:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80181a:	83 c4 24             	add    $0x24,%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <seek>:

int
seek(int fdnum, off_t offset)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801826:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	89 04 24             	mov    %eax,(%esp)
  801833:	e8 e6 fb ff ff       	call   80141e <fd_lookup>
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 0e                	js     80184a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80183c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80183f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801842:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801845:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 24             	sub    $0x24,%esp
  801853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801856:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185d:	89 1c 24             	mov    %ebx,(%esp)
  801860:	e8 b9 fb ff ff       	call   80141e <fd_lookup>
  801865:	85 c0                	test   %eax,%eax
  801867:	78 61                	js     8018ca <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801873:	8b 00                	mov    (%eax),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 f7 fb ff ff       	call   801474 <dev_lookup>
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 49                	js     8018ca <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801888:	75 23                	jne    8018ad <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80188a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188f:	8b 40 48             	mov    0x48(%eax),%eax
  801892:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189a:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  8018a1:	e8 b2 e9 ff ff       	call   800258 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018ab:	eb 1d                	jmp    8018ca <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b0:	8b 52 18             	mov    0x18(%edx),%edx
  8018b3:	85 d2                	test   %edx,%edx
  8018b5:	74 0e                	je     8018c5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	ff d2                	call   *%edx
  8018c3:	eb 05                	jmp    8018ca <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018ca:	83 c4 24             	add    $0x24,%esp
  8018cd:	5b                   	pop    %ebx
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 24             	sub    $0x24,%esp
  8018d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	89 04 24             	mov    %eax,(%esp)
  8018e7:	e8 32 fb ff ff       	call   80141e <fd_lookup>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 52                	js     801942 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fa:	8b 00                	mov    (%eax),%eax
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 70 fb ff ff       	call   801474 <dev_lookup>
  801904:	85 c0                	test   %eax,%eax
  801906:	78 3a                	js     801942 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80190f:	74 2c                	je     80193d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801911:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801914:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80191b:	00 00 00 
	stat->st_isdir = 0;
  80191e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801925:	00 00 00 
	stat->st_dev = dev;
  801928:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80192e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801932:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801935:	89 14 24             	mov    %edx,(%esp)
  801938:	ff 50 14             	call   *0x14(%eax)
  80193b:	eb 05                	jmp    801942 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80193d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801942:	83 c4 24             	add    $0x24,%esp
  801945:	5b                   	pop    %ebx
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801950:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801957:	00 
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
  80195b:	89 04 24             	mov    %eax,(%esp)
  80195e:	e8 fe 01 00 00       	call   801b61 <open>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	85 c0                	test   %eax,%eax
  801967:	78 1b                	js     801984 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801969:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801970:	89 1c 24             	mov    %ebx,(%esp)
  801973:	e8 58 ff ff ff       	call   8018d0 <fstat>
  801978:	89 c6                	mov    %eax,%esi
	close(fd);
  80197a:	89 1c 24             	mov    %ebx,(%esp)
  80197d:	e8 d4 fb ff ff       	call   801556 <close>
	return r;
  801982:	89 f3                	mov    %esi,%ebx
}
  801984:	89 d8                	mov    %ebx,%eax
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	5b                   	pop    %ebx
  80198a:	5e                   	pop    %esi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    
  80198d:	00 00                	add    %al,(%eax)
	...

00801990 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 10             	sub    $0x10,%esp
  801998:	89 c3                	mov    %eax,%ebx
  80199a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80199c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019a3:	75 11                	jne    8019b6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ac:	e8 a8 f9 ff ff       	call   801359 <ipc_find_env>
  8019b1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019bd:	00 
  8019be:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019c5:	00 
  8019c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ca:	a1 00 40 80 00       	mov    0x804000,%eax
  8019cf:	89 04 24             	mov    %eax,(%esp)
  8019d2:	e8 18 f9 ff ff       	call   8012ef <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019de:	00 
  8019df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ea:	e8 99 f8 ff ff       	call   801288 <ipc_recv>
}
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5e                   	pop    %esi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801a02:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 02 00 00 00       	mov    $0x2,%eax
  801a19:	e8 72 ff ff ff       	call   801990 <fsipc>
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a26:	8b 45 08             	mov    0x8(%ebp),%eax
  801a29:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	b8 06 00 00 00       	mov    $0x6,%eax
  801a3b:	e8 50 ff ff ff       	call   801990 <fsipc>
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	53                   	push   %ebx
  801a46:	83 ec 14             	sub    $0x14,%esp
  801a49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a52:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a61:	e8 2a ff ff ff       	call   801990 <fsipc>
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 2b                	js     801a95 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a6a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a71:	00 
  801a72:	89 1c 24             	mov    %ebx,(%esp)
  801a75:	e8 a9 ed ff ff       	call   800823 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a7a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a85:	a1 84 50 80 00       	mov    0x805084,%eax
  801a8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a95:	83 c4 14             	add    $0x14,%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801aa1:	c7 44 24 08 10 2a 80 	movl   $0x802a10,0x8(%esp)
  801aa8:	00 
  801aa9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ab0:	00 
  801ab1:	c7 04 24 2e 2a 80 00 	movl   $0x802a2e,(%esp)
  801ab8:	e8 5b 06 00 00       	call   802118 <_panic>

00801abd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 10             	sub    $0x10,%esp
  801ac5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	8b 40 0c             	mov    0xc(%eax),%eax
  801ace:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ad3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ade:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae3:	e8 a8 fe ff ff       	call   801990 <fsipc>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 6a                	js     801b58 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801aee:	39 c6                	cmp    %eax,%esi
  801af0:	73 24                	jae    801b16 <devfile_read+0x59>
  801af2:	c7 44 24 0c 39 2a 80 	movl   $0x802a39,0xc(%esp)
  801af9:	00 
  801afa:	c7 44 24 08 40 2a 80 	movl   $0x802a40,0x8(%esp)
  801b01:	00 
  801b02:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b09:	00 
  801b0a:	c7 04 24 2e 2a 80 00 	movl   $0x802a2e,(%esp)
  801b11:	e8 02 06 00 00       	call   802118 <_panic>
	assert(r <= PGSIZE);
  801b16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b1b:	7e 24                	jle    801b41 <devfile_read+0x84>
  801b1d:	c7 44 24 0c 55 2a 80 	movl   $0x802a55,0xc(%esp)
  801b24:	00 
  801b25:	c7 44 24 08 40 2a 80 	movl   $0x802a40,0x8(%esp)
  801b2c:	00 
  801b2d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b34:	00 
  801b35:	c7 04 24 2e 2a 80 00 	movl   $0x802a2e,(%esp)
  801b3c:	e8 d7 05 00 00       	call   802118 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b41:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b45:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b4c:	00 
  801b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b50:	89 04 24             	mov    %eax,(%esp)
  801b53:	e8 44 ee ff ff       	call   80099c <memmove>
	return r;
}
  801b58:	89 d8                	mov    %ebx,%eax
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	83 ec 20             	sub    $0x20,%esp
  801b69:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b6c:	89 34 24             	mov    %esi,(%esp)
  801b6f:	e8 7c ec ff ff       	call   8007f0 <strlen>
  801b74:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b79:	7f 60                	jg     801bdb <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7e:	89 04 24             	mov    %eax,(%esp)
  801b81:	e8 45 f8 ff ff       	call   8013cb <fd_alloc>
  801b86:	89 c3                	mov    %eax,%ebx
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 54                	js     801be0 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b90:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b97:	e8 87 ec ff ff       	call   800823 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bac:	e8 df fd ff ff       	call   801990 <fsipc>
  801bb1:	89 c3                	mov    %eax,%ebx
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	79 15                	jns    801bcc <open+0x6b>
		fd_close(fd, 0);
  801bb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bbe:	00 
  801bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 04 f9 ff ff       	call   8014ce <fd_close>
		return r;
  801bca:	eb 14                	jmp    801be0 <open+0x7f>
	}

	return fd2num(fd);
  801bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcf:	89 04 24             	mov    %eax,(%esp)
  801bd2:	e8 c9 f7 ff ff       	call   8013a0 <fd2num>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	eb 05                	jmp    801be0 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bdb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	83 c4 20             	add    $0x20,%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bef:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf4:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf9:	e8 92 fd ff ff       	call   801990 <fsipc>
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 10             	sub    $0x10,%esp
  801c08:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	e8 9a f7 ff ff       	call   8013b0 <fd2data>
  801c16:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c18:	c7 44 24 04 61 2a 80 	movl   $0x802a61,0x4(%esp)
  801c1f:	00 
  801c20:	89 34 24             	mov    %esi,(%esp)
  801c23:	e8 fb eb ff ff       	call   800823 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c28:	8b 43 04             	mov    0x4(%ebx),%eax
  801c2b:	2b 03                	sub    (%ebx),%eax
  801c2d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c33:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c3a:	00 00 00 
	stat->st_dev = &devpipe;
  801c3d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c44:	30 80 00 
	return 0;
}
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	53                   	push   %ebx
  801c57:	83 ec 14             	sub    $0x14,%esp
  801c5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c68:	e8 4f f0 ff ff       	call   800cbc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c6d:	89 1c 24             	mov    %ebx,(%esp)
  801c70:	e8 3b f7 ff ff       	call   8013b0 <fd2data>
  801c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c80:	e8 37 f0 ff ff       	call   800cbc <sys_page_unmap>
}
  801c85:	83 c4 14             	add    $0x14,%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	57                   	push   %edi
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	83 ec 2c             	sub    $0x2c,%esp
  801c94:	89 c7                	mov    %eax,%edi
  801c96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c99:	a1 08 40 80 00       	mov    0x804008,%eax
  801c9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ca1:	89 3c 24             	mov    %edi,(%esp)
  801ca4:	e8 8b 05 00 00       	call   802234 <pageref>
  801ca9:	89 c6                	mov    %eax,%esi
  801cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cae:	89 04 24             	mov    %eax,(%esp)
  801cb1:	e8 7e 05 00 00       	call   802234 <pageref>
  801cb6:	39 c6                	cmp    %eax,%esi
  801cb8:	0f 94 c0             	sete   %al
  801cbb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cbe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801cc4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cc7:	39 cb                	cmp    %ecx,%ebx
  801cc9:	75 08                	jne    801cd3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ccb:	83 c4 2c             	add    $0x2c,%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5f                   	pop    %edi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cd3:	83 f8 01             	cmp    $0x1,%eax
  801cd6:	75 c1                	jne    801c99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cd8:	8b 42 58             	mov    0x58(%edx),%eax
  801cdb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ce2:	00 
  801ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ceb:	c7 04 24 68 2a 80 00 	movl   $0x802a68,(%esp)
  801cf2:	e8 61 e5 ff ff       	call   800258 <cprintf>
  801cf7:	eb a0                	jmp    801c99 <_pipeisclosed+0xe>

00801cf9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	57                   	push   %edi
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 1c             	sub    $0x1c,%esp
  801d02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d05:	89 34 24             	mov    %esi,(%esp)
  801d08:	e8 a3 f6 ff ff       	call   8013b0 <fd2data>
  801d0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d14:	eb 3c                	jmp    801d52 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d16:	89 da                	mov    %ebx,%edx
  801d18:	89 f0                	mov    %esi,%eax
  801d1a:	e8 6c ff ff ff       	call   801c8b <_pipeisclosed>
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	75 38                	jne    801d5b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d23:	e8 ce ee ff ff       	call   800bf6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d28:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2b:	8b 13                	mov    (%ebx),%edx
  801d2d:	83 c2 20             	add    $0x20,%edx
  801d30:	39 d0                	cmp    %edx,%eax
  801d32:	73 e2                	jae    801d16 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d37:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d3a:	89 c2                	mov    %eax,%edx
  801d3c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d42:	79 05                	jns    801d49 <devpipe_write+0x50>
  801d44:	4a                   	dec    %edx
  801d45:	83 ca e0             	or     $0xffffffe0,%edx
  801d48:	42                   	inc    %edx
  801d49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d4d:	40                   	inc    %eax
  801d4e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d51:	47                   	inc    %edi
  801d52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d55:	75 d1                	jne    801d28 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d57:	89 f8                	mov    %edi,%eax
  801d59:	eb 05                	jmp    801d60 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 1c             	sub    $0x1c,%esp
  801d71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d74:	89 3c 24             	mov    %edi,(%esp)
  801d77:	e8 34 f6 ff ff       	call   8013b0 <fd2data>
  801d7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7e:	be 00 00 00 00       	mov    $0x0,%esi
  801d83:	eb 3a                	jmp    801dbf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d85:	85 f6                	test   %esi,%esi
  801d87:	74 04                	je     801d8d <devpipe_read+0x25>
				return i;
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	eb 40                	jmp    801dcd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d8d:	89 da                	mov    %ebx,%edx
  801d8f:	89 f8                	mov    %edi,%eax
  801d91:	e8 f5 fe ff ff       	call   801c8b <_pipeisclosed>
  801d96:	85 c0                	test   %eax,%eax
  801d98:	75 2e                	jne    801dc8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d9a:	e8 57 ee ff ff       	call   800bf6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d9f:	8b 03                	mov    (%ebx),%eax
  801da1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801da4:	74 df                	je     801d85 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dab:	79 05                	jns    801db2 <devpipe_read+0x4a>
  801dad:	48                   	dec    %eax
  801dae:	83 c8 e0             	or     $0xffffffe0,%eax
  801db1:	40                   	inc    %eax
  801db2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dbc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbe:	46                   	inc    %esi
  801dbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc2:	75 db                	jne    801d9f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	eb 05                	jmp    801dcd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 3c             	sub    $0x3c,%esp
  801dde:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801de4:	89 04 24             	mov    %eax,(%esp)
  801de7:	e8 df f5 ff ff       	call   8013cb <fd_alloc>
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	85 c0                	test   %eax,%eax
  801df0:	0f 88 45 01 00 00    	js     801f3b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dfd:	00 
  801dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 04 ee ff ff       	call   800c15 <sys_page_alloc>
  801e11:	89 c3                	mov    %eax,%ebx
  801e13:	85 c0                	test   %eax,%eax
  801e15:	0f 88 20 01 00 00    	js     801f3b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e1b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e1e:	89 04 24             	mov    %eax,(%esp)
  801e21:	e8 a5 f5 ff ff       	call   8013cb <fd_alloc>
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	0f 88 f8 00 00 00    	js     801f28 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e30:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e37:	00 
  801e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e46:	e8 ca ed ff ff       	call   800c15 <sys_page_alloc>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	0f 88 d3 00 00 00    	js     801f28 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e58:	89 04 24             	mov    %eax,(%esp)
  801e5b:	e8 50 f5 ff ff       	call   8013b0 <fd2data>
  801e60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e69:	00 
  801e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e75:	e8 9b ed ff ff       	call   800c15 <sys_page_alloc>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	0f 88 91 00 00 00    	js     801f15 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e87:	89 04 24             	mov    %eax,(%esp)
  801e8a:	e8 21 f5 ff ff       	call   8013b0 <fd2data>
  801e8f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e96:	00 
  801e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ea2:	00 
  801ea3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eae:	e8 b6 ed ff ff       	call   800c69 <sys_page_map>
  801eb3:	89 c3                	mov    %eax,%ebx
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 4c                	js     801f05 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eb9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ece:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ed7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ed9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801edc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 b2 f4 ff ff       	call   8013a0 <fd2num>
  801eee:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef3:	89 04 24             	mov    %eax,(%esp)
  801ef6:	e8 a5 f4 ff ff       	call   8013a0 <fd2num>
  801efb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f03:	eb 36                	jmp    801f3b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f05:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 a7 ed ff ff       	call   800cbc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f23:	e8 94 ed ff ff       	call   800cbc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f36:	e8 81 ed ff ff       	call   800cbc <sys_page_unmap>
    err:
	return r;
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	83 c4 3c             	add    $0x3c,%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f52:	8b 45 08             	mov    0x8(%ebp),%eax
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 c1 f4 ff ff       	call   80141e <fd_lookup>
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 15                	js     801f76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 44 f4 ff ff       	call   8013b0 <fd2data>
	return _pipeisclosed(fd, p);
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f71:	e8 15 fd ff ff       	call   801c8b <_pipeisclosed>
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f88:	c7 44 24 04 80 2a 80 	movl   $0x802a80,0x4(%esp)
  801f8f:	00 
  801f90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f93:	89 04 24             	mov    %eax,(%esp)
  801f96:	e8 88 e8 ff ff       	call   800823 <strcpy>
	return 0;
}
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fae:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fb3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb9:	eb 30                	jmp    801feb <devcons_write+0x49>
		m = n - tot;
  801fbb:	8b 75 10             	mov    0x10(%ebp),%esi
  801fbe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fc0:	83 fe 7f             	cmp    $0x7f,%esi
  801fc3:	76 05                	jbe    801fca <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fc5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fca:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fce:	03 45 0c             	add    0xc(%ebp),%eax
  801fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd5:	89 3c 24             	mov    %edi,(%esp)
  801fd8:	e8 bf e9 ff ff       	call   80099c <memmove>
		sys_cputs(buf, m);
  801fdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe1:	89 3c 24             	mov    %edi,(%esp)
  801fe4:	e8 5f eb ff ff       	call   800b48 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe9:	01 f3                	add    %esi,%ebx
  801feb:	89 d8                	mov    %ebx,%eax
  801fed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff0:	72 c9                	jb     801fbb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ff2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802003:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802007:	75 07                	jne    802010 <devcons_read+0x13>
  802009:	eb 25                	jmp    802030 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80200b:	e8 e6 eb ff ff       	call   800bf6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802010:	e8 51 eb ff ff       	call   800b66 <sys_cgetc>
  802015:	85 c0                	test   %eax,%eax
  802017:	74 f2                	je     80200b <devcons_read+0xe>
  802019:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 1d                	js     80203c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80201f:	83 f8 04             	cmp    $0x4,%eax
  802022:	74 13                	je     802037 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802024:	8b 45 0c             	mov    0xc(%ebp),%eax
  802027:	88 10                	mov    %dl,(%eax)
	return 1;
  802029:	b8 01 00 00 00       	mov    $0x1,%eax
  80202e:	eb 0c                	jmp    80203c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802030:	b8 00 00 00 00       	mov    $0x0,%eax
  802035:	eb 05                	jmp    80203c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80204a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802051:	00 
  802052:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 eb ea ff ff       	call   800b48 <sys_cputs>
}
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    

0080205f <getchar>:

int
getchar(void)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802065:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80206c:	00 
  80206d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802070:	89 44 24 04          	mov    %eax,0x4(%esp)
  802074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207b:	e8 3a f6 ff ff       	call   8016ba <read>
	if (r < 0)
  802080:	85 c0                	test   %eax,%eax
  802082:	78 0f                	js     802093 <getchar+0x34>
		return r;
	if (r < 1)
  802084:	85 c0                	test   %eax,%eax
  802086:	7e 06                	jle    80208e <getchar+0x2f>
		return -E_EOF;
	return c;
  802088:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80208c:	eb 05                	jmp    802093 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80208e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 71 f3 ff ff       	call   80141e <fd_lookup>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 11                	js     8020c2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ba:	39 10                	cmp    %edx,(%eax)
  8020bc:	0f 94 c0             	sete   %al
  8020bf:	0f b6 c0             	movzbl %al,%eax
}
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <opencons>:

int
opencons(void)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cd:	89 04 24             	mov    %eax,(%esp)
  8020d0:	e8 f6 f2 ff ff       	call   8013cb <fd_alloc>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	78 3c                	js     802115 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020e0:	00 
  8020e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ef:	e8 21 eb ff ff       	call   800c15 <sys_page_alloc>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 1d                	js     802115 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020f8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802106:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80210d:	89 04 24             	mov    %eax,(%esp)
  802110:	e8 8b f2 ff ff       	call   8013a0 <fd2num>
}
  802115:	c9                   	leave  
  802116:	c3                   	ret    
	...

00802118 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	56                   	push   %esi
  80211c:	53                   	push   %ebx
  80211d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802120:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802123:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802129:	e8 a9 ea ff ff       	call   800bd7 <sys_getenvid>
  80212e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802131:	89 54 24 10          	mov    %edx,0x10(%esp)
  802135:	8b 55 08             	mov    0x8(%ebp),%edx
  802138:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80213c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802140:	89 44 24 04          	mov    %eax,0x4(%esp)
  802144:	c7 04 24 8c 2a 80 00 	movl   $0x802a8c,(%esp)
  80214b:	e8 08 e1 ff ff       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802150:	89 74 24 04          	mov    %esi,0x4(%esp)
  802154:	8b 45 10             	mov    0x10(%ebp),%eax
  802157:	89 04 24             	mov    %eax,(%esp)
  80215a:	e8 98 e0 ff ff       	call   8001f7 <vcprintf>
	cprintf("\n");
  80215f:	c7 04 24 79 2a 80 00 	movl   $0x802a79,(%esp)
  802166:	e8 ed e0 ff ff       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80216b:	cc                   	int3   
  80216c:	eb fd                	jmp    80216b <_panic+0x53>
	...

00802170 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802176:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80217d:	0f 85 80 00 00 00    	jne    802203 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  802183:	a1 08 40 80 00       	mov    0x804008,%eax
  802188:	8b 40 48             	mov    0x48(%eax),%eax
  80218b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802192:	00 
  802193:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80219a:	ee 
  80219b:	89 04 24             	mov    %eax,(%esp)
  80219e:	e8 72 ea ff ff       	call   800c15 <sys_page_alloc>
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	79 20                	jns    8021c7 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8021a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ab:	c7 44 24 08 b0 2a 80 	movl   $0x802ab0,0x8(%esp)
  8021b2:	00 
  8021b3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8021ba:	00 
  8021bb:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  8021c2:	e8 51 ff ff ff       	call   802118 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8021c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8021cc:	8b 40 48             	mov    0x48(%eax),%eax
  8021cf:	c7 44 24 04 10 22 80 	movl   $0x802210,0x4(%esp)
  8021d6:	00 
  8021d7:	89 04 24             	mov    %eax,(%esp)
  8021da:	e8 d6 eb ff ff       	call   800db5 <sys_env_set_pgfault_upcall>
  8021df:	85 c0                	test   %eax,%eax
  8021e1:	79 20                	jns    802203 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  8021e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021e7:	c7 44 24 08 dc 2a 80 	movl   $0x802adc,0x8(%esp)
  8021ee:	00 
  8021ef:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8021f6:	00 
  8021f7:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  8021fe:	e8 15 ff ff ff       	call   802118 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80220b:	c9                   	leave  
  80220c:	c3                   	ret    
  80220d:	00 00                	add    %al,(%eax)
	...

00802210 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802210:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802211:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802216:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802218:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  80221b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80221f:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802221:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802224:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802225:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802228:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  80222a:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  80222d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80222e:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802231:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802232:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802233:	c3                   	ret    

00802234 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80223a:	89 c2                	mov    %eax,%edx
  80223c:	c1 ea 16             	shr    $0x16,%edx
  80223f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802246:	f6 c2 01             	test   $0x1,%dl
  802249:	74 1e                	je     802269 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80224b:	c1 e8 0c             	shr    $0xc,%eax
  80224e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802255:	a8 01                	test   $0x1,%al
  802257:	74 17                	je     802270 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802259:	c1 e8 0c             	shr    $0xc,%eax
  80225c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802263:	ef 
  802264:	0f b7 c0             	movzwl %ax,%eax
  802267:	eb 0c                	jmp    802275 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	eb 05                	jmp    802275 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802270:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    
	...

00802278 <__udivdi3>:
  802278:	55                   	push   %ebp
  802279:	57                   	push   %edi
  80227a:	56                   	push   %esi
  80227b:	83 ec 10             	sub    $0x10,%esp
  80227e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802282:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80228e:	89 cd                	mov    %ecx,%ebp
  802290:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802294:	85 c0                	test   %eax,%eax
  802296:	75 2c                	jne    8022c4 <__udivdi3+0x4c>
  802298:	39 f9                	cmp    %edi,%ecx
  80229a:	77 68                	ja     802304 <__udivdi3+0x8c>
  80229c:	85 c9                	test   %ecx,%ecx
  80229e:	75 0b                	jne    8022ab <__udivdi3+0x33>
  8022a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a5:	31 d2                	xor    %edx,%edx
  8022a7:	f7 f1                	div    %ecx
  8022a9:	89 c1                	mov    %eax,%ecx
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	89 f8                	mov    %edi,%eax
  8022af:	f7 f1                	div    %ecx
  8022b1:	89 c7                	mov    %eax,%edi
  8022b3:	89 f0                	mov    %esi,%eax
  8022b5:	f7 f1                	div    %ecx
  8022b7:	89 c6                	mov    %eax,%esi
  8022b9:	89 f0                	mov    %esi,%eax
  8022bb:	89 fa                	mov    %edi,%edx
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	39 f8                	cmp    %edi,%eax
  8022c6:	77 2c                	ja     8022f4 <__udivdi3+0x7c>
  8022c8:	0f bd f0             	bsr    %eax,%esi
  8022cb:	83 f6 1f             	xor    $0x1f,%esi
  8022ce:	75 4c                	jne    80231c <__udivdi3+0xa4>
  8022d0:	39 f8                	cmp    %edi,%eax
  8022d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8022d7:	72 0a                	jb     8022e3 <__udivdi3+0x6b>
  8022d9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022dd:	0f 87 ad 00 00 00    	ja     802390 <__udivdi3+0x118>
  8022e3:	be 01 00 00 00       	mov    $0x1,%esi
  8022e8:	89 f0                	mov    %esi,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    
  8022f3:	90                   	nop
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	31 f6                	xor    %esi,%esi
  8022f8:	89 f0                	mov    %esi,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
  802303:	90                   	nop
  802304:	89 fa                	mov    %edi,%edx
  802306:	89 f0                	mov    %esi,%eax
  802308:	f7 f1                	div    %ecx
  80230a:	89 c6                	mov    %eax,%esi
  80230c:	31 ff                	xor    %edi,%edi
  80230e:	89 f0                	mov    %esi,%eax
  802310:	89 fa                	mov    %edi,%edx
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d 76 00             	lea    0x0(%esi),%esi
  80231c:	89 f1                	mov    %esi,%ecx
  80231e:	d3 e0                	shl    %cl,%eax
  802320:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802324:	b8 20 00 00 00       	mov    $0x20,%eax
  802329:	29 f0                	sub    %esi,%eax
  80232b:	89 ea                	mov    %ebp,%edx
  80232d:	88 c1                	mov    %al,%cl
  80232f:	d3 ea                	shr    %cl,%edx
  802331:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802335:	09 ca                	or     %ecx,%edx
  802337:	89 54 24 08          	mov    %edx,0x8(%esp)
  80233b:	89 f1                	mov    %esi,%ecx
  80233d:	d3 e5                	shl    %cl,%ebp
  80233f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802343:	89 fd                	mov    %edi,%ebp
  802345:	88 c1                	mov    %al,%cl
  802347:	d3 ed                	shr    %cl,%ebp
  802349:	89 fa                	mov    %edi,%edx
  80234b:	89 f1                	mov    %esi,%ecx
  80234d:	d3 e2                	shl    %cl,%edx
  80234f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802353:	88 c1                	mov    %al,%cl
  802355:	d3 ef                	shr    %cl,%edi
  802357:	09 d7                	or     %edx,%edi
  802359:	89 f8                	mov    %edi,%eax
  80235b:	89 ea                	mov    %ebp,%edx
  80235d:	f7 74 24 08          	divl   0x8(%esp)
  802361:	89 d1                	mov    %edx,%ecx
  802363:	89 c7                	mov    %eax,%edi
  802365:	f7 64 24 0c          	mull   0xc(%esp)
  802369:	39 d1                	cmp    %edx,%ecx
  80236b:	72 17                	jb     802384 <__udivdi3+0x10c>
  80236d:	74 09                	je     802378 <__udivdi3+0x100>
  80236f:	89 fe                	mov    %edi,%esi
  802371:	31 ff                	xor    %edi,%edi
  802373:	e9 41 ff ff ff       	jmp    8022b9 <__udivdi3+0x41>
  802378:	8b 54 24 04          	mov    0x4(%esp),%edx
  80237c:	89 f1                	mov    %esi,%ecx
  80237e:	d3 e2                	shl    %cl,%edx
  802380:	39 c2                	cmp    %eax,%edx
  802382:	73 eb                	jae    80236f <__udivdi3+0xf7>
  802384:	8d 77 ff             	lea    -0x1(%edi),%esi
  802387:	31 ff                	xor    %edi,%edi
  802389:	e9 2b ff ff ff       	jmp    8022b9 <__udivdi3+0x41>
  80238e:	66 90                	xchg   %ax,%ax
  802390:	31 f6                	xor    %esi,%esi
  802392:	e9 22 ff ff ff       	jmp    8022b9 <__udivdi3+0x41>
	...

00802398 <__umoddi3>:
  802398:	55                   	push   %ebp
  802399:	57                   	push   %edi
  80239a:	56                   	push   %esi
  80239b:	83 ec 20             	sub    $0x20,%esp
  80239e:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023a2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8023a6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023aa:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023b2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8023b6:	89 c7                	mov    %eax,%edi
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	85 ed                	test   %ebp,%ebp
  8023bc:	75 16                	jne    8023d4 <__umoddi3+0x3c>
  8023be:	39 f1                	cmp    %esi,%ecx
  8023c0:	0f 86 a6 00 00 00    	jbe    80246c <__umoddi3+0xd4>
  8023c6:	f7 f1                	div    %ecx
  8023c8:	89 d0                	mov    %edx,%eax
  8023ca:	31 d2                	xor    %edx,%edx
  8023cc:	83 c4 20             	add    $0x20,%esp
  8023cf:	5e                   	pop    %esi
  8023d0:	5f                   	pop    %edi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
  8023d3:	90                   	nop
  8023d4:	39 f5                	cmp    %esi,%ebp
  8023d6:	0f 87 ac 00 00 00    	ja     802488 <__umoddi3+0xf0>
  8023dc:	0f bd c5             	bsr    %ebp,%eax
  8023df:	83 f0 1f             	xor    $0x1f,%eax
  8023e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023e6:	0f 84 a8 00 00 00    	je     802494 <__umoddi3+0xfc>
  8023ec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023f0:	d3 e5                	shl    %cl,%ebp
  8023f2:	bf 20 00 00 00       	mov    $0x20,%edi
  8023f7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ff:	89 f9                	mov    %edi,%ecx
  802401:	d3 e8                	shr    %cl,%eax
  802403:	09 e8                	or     %ebp,%eax
  802405:	89 44 24 18          	mov    %eax,0x18(%esp)
  802409:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80240d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802411:	d3 e0                	shl    %cl,%eax
  802413:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802417:	89 f2                	mov    %esi,%edx
  802419:	d3 e2                	shl    %cl,%edx
  80241b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80241f:	d3 e0                	shl    %cl,%eax
  802421:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802425:	8b 44 24 14          	mov    0x14(%esp),%eax
  802429:	89 f9                	mov    %edi,%ecx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	09 d0                	or     %edx,%eax
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	89 f2                	mov    %esi,%edx
  802433:	f7 74 24 18          	divl   0x18(%esp)
  802437:	89 d6                	mov    %edx,%esi
  802439:	f7 64 24 0c          	mull   0xc(%esp)
  80243d:	89 c5                	mov    %eax,%ebp
  80243f:	89 d1                	mov    %edx,%ecx
  802441:	39 d6                	cmp    %edx,%esi
  802443:	72 67                	jb     8024ac <__umoddi3+0x114>
  802445:	74 75                	je     8024bc <__umoddi3+0x124>
  802447:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80244b:	29 e8                	sub    %ebp,%eax
  80244d:	19 ce                	sbb    %ecx,%esi
  80244f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802453:	d3 e8                	shr    %cl,%eax
  802455:	89 f2                	mov    %esi,%edx
  802457:	89 f9                	mov    %edi,%ecx
  802459:	d3 e2                	shl    %cl,%edx
  80245b:	09 d0                	or     %edx,%eax
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802463:	d3 ea                	shr    %cl,%edx
  802465:	83 c4 20             	add    $0x20,%esp
  802468:	5e                   	pop    %esi
  802469:	5f                   	pop    %edi
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    
  80246c:	85 c9                	test   %ecx,%ecx
  80246e:	75 0b                	jne    80247b <__umoddi3+0xe3>
  802470:	b8 01 00 00 00       	mov    $0x1,%eax
  802475:	31 d2                	xor    %edx,%edx
  802477:	f7 f1                	div    %ecx
  802479:	89 c1                	mov    %eax,%ecx
  80247b:	89 f0                	mov    %esi,%eax
  80247d:	31 d2                	xor    %edx,%edx
  80247f:	f7 f1                	div    %ecx
  802481:	89 f8                	mov    %edi,%eax
  802483:	e9 3e ff ff ff       	jmp    8023c6 <__umoddi3+0x2e>
  802488:	89 f2                	mov    %esi,%edx
  80248a:	83 c4 20             	add    $0x20,%esp
  80248d:	5e                   	pop    %esi
  80248e:	5f                   	pop    %edi
  80248f:	5d                   	pop    %ebp
  802490:	c3                   	ret    
  802491:	8d 76 00             	lea    0x0(%esi),%esi
  802494:	39 f5                	cmp    %esi,%ebp
  802496:	72 04                	jb     80249c <__umoddi3+0x104>
  802498:	39 f9                	cmp    %edi,%ecx
  80249a:	77 06                	ja     8024a2 <__umoddi3+0x10a>
  80249c:	89 f2                	mov    %esi,%edx
  80249e:	29 cf                	sub    %ecx,%edi
  8024a0:	19 ea                	sbb    %ebp,%edx
  8024a2:	89 f8                	mov    %edi,%eax
  8024a4:	83 c4 20             	add    $0x20,%esp
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    
  8024ab:	90                   	nop
  8024ac:	89 d1                	mov    %edx,%ecx
  8024ae:	89 c5                	mov    %eax,%ebp
  8024b0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024b4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024b8:	eb 8d                	jmp    802447 <__umoddi3+0xaf>
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024c0:	72 ea                	jb     8024ac <__umoddi3+0x114>
  8024c2:	89 f1                	mov    %esi,%ecx
  8024c4:	eb 81                	jmp    802447 <__umoddi3+0xaf>
