
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 a1 0e 00 00       	call   800ee3 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 2f 0b 00 00       	call   800b7f <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 60 16 80 00 	movl   $0x801660,(%esp)
  80005f:	e8 9c 01 00 00       	call   800200 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 bc 11 00 00       	call   801243 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 3a 11 00 00       	call   8011dc <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 d3 0a 00 00       	call   800b7f <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 76 16 80 00 	movl   $0x801676,(%esp)
  8000bf:	e8 3c 01 00 00       	call   800200 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 5a 11 00 00       	call   801243 <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800106:	e8 74 0a 00 00       	call   800b7f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 cf 09 00 00       	call   800b2d <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 14             	sub    $0x14,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800173:	40                   	inc    %eax
  800174:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 19                	jne    800196 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80017d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800184:	00 
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 60 09 00 00       	call   800af0 <sys_cputs>
		b->idx = 0;
  800190:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800196:	ff 43 04             	incl   0x4(%ebx)
}
  800199:	83 c4 14             	add    $0x14,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d4:	c7 04 24 60 01 80 00 	movl   $0x800160,(%esp)
  8001db:	e8 82 01 00 00       	call   800362 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 f8 08 00 00       	call   800af0 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 87 ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    
	...

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 3c             	sub    $0x3c,%esp
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	89 d7                	mov    %edx,%edi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800230:	8b 45 0c             	mov    0xc(%ebp),%eax
  800233:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800236:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800239:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	85 c0                	test   %eax,%eax
  80023e:	75 08                	jne    800248 <printnum+0x2c>
  800240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800243:	39 45 10             	cmp    %eax,0x10(%ebp)
  800246:	77 57                	ja     80029f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800248:	89 74 24 10          	mov    %esi,0x10(%esp)
  80024c:	4b                   	dec    %ebx
  80024d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800251:	8b 45 10             	mov    0x10(%ebp),%eax
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80025c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800260:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800267:	00 
  800268:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	e8 96 11 00 00       	call   801410 <__udivdi3>
  80027a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800282:	89 04 24             	mov    %eax,(%esp)
  800285:	89 54 24 04          	mov    %edx,0x4(%esp)
  800289:	89 fa                	mov    %edi,%edx
  80028b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028e:	e8 89 ff ff ff       	call   80021c <printnum>
  800293:	eb 0f                	jmp    8002a4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800299:	89 34 24             	mov    %esi,(%esp)
  80029c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	4b                   	dec    %ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f f1                	jg     800295 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ba:	00 
  8002bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	e8 63 12 00 00       	call   801530 <__umoddi3>
  8002cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d1:	0f be 80 93 16 80 00 	movsbl 0x801693(%eax),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002de:	83 c4 3c             	add    $0x3c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 08                	jae    800338 <sprintputch+0x18>
		*b->buf++ = ch;
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 0a                	mov    %cl,(%edx)
  800335:	42                   	inc    %edx
  800336:	89 10                	mov    %edx,(%eax)
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800347:	8b 45 10             	mov    0x10(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	e8 02 00 00 00       	call   800362 <vprintfmt>
	va_end(ap);
}
  800360:	c9                   	leave  
  800361:	c3                   	ret    

00800362 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
  800368:	83 ec 4c             	sub    $0x4c,%esp
  80036b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036e:	8b 75 10             	mov    0x10(%ebp),%esi
  800371:	eb 12                	jmp    800385 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800373:	85 c0                	test   %eax,%eax
  800375:	0f 84 8b 03 00 00    	je     800706 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80037b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037f:	89 04 24             	mov    %eax,(%esp)
  800382:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800385:	0f b6 06             	movzbl (%esi),%eax
  800388:	46                   	inc    %esi
  800389:	83 f8 25             	cmp    $0x25,%eax
  80038c:	75 e5                	jne    800373 <vprintfmt+0x11>
  80038e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800392:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800399:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	eb 26                	jmp    8003d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003af:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003b3:	eb 1d                	jmp    8003d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003bc:	eb 14                	jmp    8003d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c8:	eb 08                	jmp    8003d2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003cd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	0f b6 06             	movzbl (%esi),%eax
  8003d5:	8d 56 01             	lea    0x1(%esi),%edx
  8003d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003db:	8a 16                	mov    (%esi),%dl
  8003dd:	83 ea 23             	sub    $0x23,%edx
  8003e0:	80 fa 55             	cmp    $0x55,%dl
  8003e3:	0f 87 01 03 00 00    	ja     8006ea <vprintfmt+0x388>
  8003e9:	0f b6 d2             	movzbl %dl,%edx
  8003ec:	ff 24 95 60 17 80 00 	jmp    *0x801760(,%edx,4)
  8003f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fe:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800402:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800405:	8d 50 d0             	lea    -0x30(%eax),%edx
  800408:	83 fa 09             	cmp    $0x9,%edx
  80040b:	77 2a                	ja     800437 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040e:	eb eb                	jmp    8003fb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 17                	jmp    800437 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800420:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800424:	78 98                	js     8003be <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800429:	eb a7                	jmp    8003d2 <vprintfmt+0x70>
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800435:	eb 9b                	jmp    8003d2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800437:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043b:	79 95                	jns    8003d2 <vprintfmt+0x70>
  80043d:	eb 8b                	jmp    8003ca <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800443:	eb 8d                	jmp    8003d2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045d:	e9 23 ff ff ff       	jmp    800385 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	85 c0                	test   %eax,%eax
  80046f:	79 02                	jns    800473 <vprintfmt+0x111>
  800471:	f7 d8                	neg    %eax
  800473:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800475:	83 f8 08             	cmp    $0x8,%eax
  800478:	7f 0b                	jg     800485 <vprintfmt+0x123>
  80047a:	8b 04 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%eax
  800481:	85 c0                	test   %eax,%eax
  800483:	75 23                	jne    8004a8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800485:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800489:	c7 44 24 08 ab 16 80 	movl   $0x8016ab,0x8(%esp)
  800490:	00 
  800491:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 9a fe ff ff       	call   80033a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a3:	e9 dd fe ff ff       	jmp    800385 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ac:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  8004b3:	00 
  8004b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	89 14 24             	mov    %edx,(%esp)
  8004be:	e8 77 fe ff ff       	call   80033a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c6:	e9 ba fe ff ff       	jmp    800385 <vprintfmt+0x23>
  8004cb:	89 f9                	mov    %edi,%ecx
  8004cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 30                	mov    (%eax),%esi
  8004de:	85 f6                	test   %esi,%esi
  8004e0:	75 05                	jne    8004e7 <vprintfmt+0x185>
				p = "(null)";
  8004e2:	be a4 16 80 00       	mov    $0x8016a4,%esi
			if (width > 0 && padc != '-')
  8004e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004eb:	0f 8e 84 00 00 00    	jle    800575 <vprintfmt+0x213>
  8004f1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f5:	74 7e                	je     800575 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004fb:	89 34 24             	mov    %esi,(%esp)
  8004fe:	e8 ab 02 00 00       	call   8007ae <strnlen>
  800503:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800506:	29 c2                	sub    %eax,%edx
  800508:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80050f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800512:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800515:	89 de                	mov    %ebx,%esi
  800517:	89 d3                	mov    %edx,%ebx
  800519:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0b                	jmp    800528 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80051d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800521:	89 3c 24             	mov    %edi,(%esp)
  800524:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	4b                   	dec    %ebx
  800528:	85 db                	test   %ebx,%ebx
  80052a:	7f f1                	jg     80051d <vprintfmt+0x1bb>
  80052c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052f:	89 f3                	mov    %esi,%ebx
  800531:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800537:	85 c0                	test   %eax,%eax
  800539:	79 05                	jns    800540 <vprintfmt+0x1de>
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800543:	29 c2                	sub    %eax,%edx
  800545:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800548:	eb 2b                	jmp    800575 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054e:	74 18                	je     800568 <vprintfmt+0x206>
  800550:	8d 50 e0             	lea    -0x20(%eax),%edx
  800553:	83 fa 5e             	cmp    $0x5e,%edx
  800556:	76 10                	jbe    800568 <vprintfmt+0x206>
					putch('?', putdat);
  800558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	eb 0a                	jmp    800572 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800572:	ff 4d e4             	decl   -0x1c(%ebp)
  800575:	0f be 06             	movsbl (%esi),%eax
  800578:	46                   	inc    %esi
  800579:	85 c0                	test   %eax,%eax
  80057b:	74 21                	je     80059e <vprintfmt+0x23c>
  80057d:	85 ff                	test   %edi,%edi
  80057f:	78 c9                	js     80054a <vprintfmt+0x1e8>
  800581:	4f                   	dec    %edi
  800582:	79 c6                	jns    80054a <vprintfmt+0x1e8>
  800584:	8b 7d 08             	mov    0x8(%ebp),%edi
  800587:	89 de                	mov    %ebx,%esi
  800589:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80058c:	eb 18                	jmp    8005a6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800592:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800599:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059b:	4b                   	dec    %ebx
  80059c:	eb 08                	jmp    8005a6 <vprintfmt+0x244>
  80059e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a1:	89 de                	mov    %ebx,%esi
  8005a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a6:	85 db                	test   %ebx,%ebx
  8005a8:	7f e4                	jg     80058e <vprintfmt+0x22c>
  8005aa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005ad:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b2:	e9 ce fd ff ff       	jmp    800385 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b7:	83 f9 01             	cmp    $0x1,%ecx
  8005ba:	7e 10                	jle    8005cc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 08             	lea    0x8(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 30                	mov    (%eax),%esi
  8005c7:	8b 78 04             	mov    0x4(%eax),%edi
  8005ca:	eb 26                	jmp    8005f2 <vprintfmt+0x290>
	else if (lflag)
  8005cc:	85 c9                	test   %ecx,%ecx
  8005ce:	74 12                	je     8005e2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 30                	mov    (%eax),%esi
  8005db:	89 f7                	mov    %esi,%edi
  8005dd:	c1 ff 1f             	sar    $0x1f,%edi
  8005e0:	eb 10                	jmp    8005f2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 30                	mov    (%eax),%esi
  8005ed:	89 f7                	mov    %esi,%edi
  8005ef:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	78 0a                	js     800600 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fb:	e9 ac 00 00 00       	jmp    8006ac <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060e:	f7 de                	neg    %esi
  800610:	83 d7 00             	adc    $0x0,%edi
  800613:	f7 df                	neg    %edi
			}
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061a:	e9 8d 00 00 00       	jmp    8006ac <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061f:	89 ca                	mov    %ecx,%edx
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	e8 bd fc ff ff       	call   8002e6 <getuint>
  800629:	89 c6                	mov    %eax,%esi
  80062b:	89 d7                	mov    %edx,%edi
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800632:	eb 78                	jmp    8006ac <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800646:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800661:	e9 1f fd ff ff       	jmp    800385 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800671:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800674:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800678:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068b:	8b 30                	mov    (%eax),%esi
  80068d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800692:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800697:	eb 13                	jmp    8006ac <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 43 fc ff ff       	call   8002e6 <getuint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ac:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bf:	89 34 24             	mov    %esi,(%esp)
  8006c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c6:	89 da                	mov    %ebx,%edx
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	e8 4c fb ff ff       	call   80021c <printnum>
			break;
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d3:	e9 ad fc ff ff       	jmp    800385 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e5:	e9 9b fc ff ff       	jmp    800385 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f8:	eb 01                	jmp    8006fb <vprintfmt+0x399>
  8006fa:	4e                   	dec    %esi
  8006fb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ff:	75 f9                	jne    8006fa <vprintfmt+0x398>
  800701:	e9 7f fc ff ff       	jmp    800385 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800706:	83 c4 4c             	add    $0x4c,%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	83 ec 28             	sub    $0x28,%esp
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800721:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800724:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072b:	85 c0                	test   %eax,%eax
  80072d:	74 30                	je     80075f <vsnprintf+0x51>
  80072f:	85 d2                	test   %edx,%edx
  800731:	7e 33                	jle    800766 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	c7 04 24 20 03 80 00 	movl   $0x800320,(%esp)
  80074f:	e8 0e fc ff ff       	call   800362 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800754:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800757:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075d:	eb 0c                	jmp    80076b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb 05                	jmp    80076b <vsnprintf+0x5d>
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8b 45 0c             	mov    0xc(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	e8 7b ff ff ff       	call   80070e <vsnprintf>
	va_end(ap);

	return rc;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    
  800795:	00 00                	add    %al,(%eax)
	...

00800798 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079e:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a3:	eb 01                	jmp    8007a6 <strlen+0xe>
		n++;
  8007a5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007aa:	75 f9                	jne    8007a5 <strlen+0xd>
		n++;
	return n;
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	eb 01                	jmp    8007bf <strnlen+0x11>
		n++;
  8007be:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	39 d0                	cmp    %edx,%eax
  8007c1:	74 06                	je     8007c9 <strnlen+0x1b>
  8007c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c7:	75 f5                	jne    8007be <strnlen+0x10>
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007da:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e0:	42                   	inc    %edx
  8007e1:	84 c9                	test   %cl,%cl
  8007e3:	75 f5                	jne    8007da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e5:	5b                   	pop    %ebx
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f2:	89 1c 24             	mov    %ebx,(%esp)
  8007f5:	e8 9e ff ff ff       	call   800798 <strlen>
	strcpy(dst + len, src);
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800801:	01 d8                	add    %ebx,%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	e8 c0 ff ff ff       	call   8007cb <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	83 c4 08             	add    $0x8,%esp
  800810:	5b                   	pop    %ebx
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
  800826:	eb 0c                	jmp    800834 <strncpy+0x21>
		*dst++ = *src;
  800828:	8a 1a                	mov    (%edx),%bl
  80082a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082d:	80 3a 01             	cmpb   $0x1,(%edx)
  800830:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800833:	41                   	inc    %ecx
  800834:	39 f1                	cmp    %esi,%ecx
  800836:	75 f0                	jne    800828 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 75 08             	mov    0x8(%ebp),%esi
  800844:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800847:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084a:	85 d2                	test   %edx,%edx
  80084c:	75 0a                	jne    800858 <strlcpy+0x1c>
  80084e:	89 f0                	mov    %esi,%eax
  800850:	eb 1a                	jmp    80086c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800852:	88 18                	mov    %bl,(%eax)
  800854:	40                   	inc    %eax
  800855:	41                   	inc    %ecx
  800856:	eb 02                	jmp    80085a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800858:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80085a:	4a                   	dec    %edx
  80085b:	74 0a                	je     800867 <strlcpy+0x2b>
  80085d:	8a 19                	mov    (%ecx),%bl
  80085f:	84 db                	test   %bl,%bl
  800861:	75 ef                	jne    800852 <strlcpy+0x16>
  800863:	89 c2                	mov    %eax,%edx
  800865:	eb 02                	jmp    800869 <strlcpy+0x2d>
  800867:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800869:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80086c:	29 f0                	sub    %esi,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087b:	eb 02                	jmp    80087f <strcmp+0xd>
		p++, q++;
  80087d:	41                   	inc    %ecx
  80087e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087f:	8a 01                	mov    (%ecx),%al
  800881:	84 c0                	test   %al,%al
  800883:	74 04                	je     800889 <strcmp+0x17>
  800885:	3a 02                	cmp    (%edx),%al
  800887:	74 f4                	je     80087d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 c0             	movzbl %al,%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008a0:	eb 03                	jmp    8008a5 <strncmp+0x12>
		n--, p++, q++;
  8008a2:	4a                   	dec    %edx
  8008a3:	40                   	inc    %eax
  8008a4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	74 14                	je     8008bd <strncmp+0x2a>
  8008a9:	8a 18                	mov    (%eax),%bl
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	74 04                	je     8008b3 <strncmp+0x20>
  8008af:	3a 19                	cmp    (%ecx),%bl
  8008b1:	74 ef                	je     8008a2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	0f b6 11             	movzbl (%ecx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
  8008bb:	eb 05                	jmp    8008c2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ce:	eb 05                	jmp    8008d5 <strchr+0x10>
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	74 0c                	je     8008e0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d4:	40                   	inc    %eax
  8008d5:	8a 10                	mov    (%eax),%dl
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f5                	jne    8008d0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008eb:	eb 05                	jmp    8008f2 <strfind+0x10>
		if (*s == c)
  8008ed:	38 ca                	cmp    %cl,%dl
  8008ef:	74 07                	je     8008f8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f1:	40                   	inc    %eax
  8008f2:	8a 10                	mov    (%eax),%dl
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f5                	jne    8008ed <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 30                	je     80093d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 25                	jne    80093a <memset+0x40>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 20                	jne    80093a <memset+0x40>
		c &= 0xFF;
  80091a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091d:	89 d3                	mov    %edx,%ebx
  80091f:	c1 e3 08             	shl    $0x8,%ebx
  800922:	89 d6                	mov    %edx,%esi
  800924:	c1 e6 18             	shl    $0x18,%esi
  800927:	89 d0                	mov    %edx,%eax
  800929:	c1 e0 10             	shl    $0x10,%eax
  80092c:	09 f0                	or     %esi,%eax
  80092e:	09 d0                	or     %edx,%eax
  800930:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800932:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800935:	fc                   	cld    
  800936:	f3 ab                	rep stos %eax,%es:(%edi)
  800938:	eb 03                	jmp    80093d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	fc                   	cld    
  80093b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5f                   	pop    %edi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800952:	39 c6                	cmp    %eax,%esi
  800954:	73 34                	jae    80098a <memmove+0x46>
  800956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800959:	39 d0                	cmp    %edx,%eax
  80095b:	73 2d                	jae    80098a <memmove+0x46>
		s += n;
		d += n;
  80095d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	f6 c2 03             	test   $0x3,%dl
  800963:	75 1b                	jne    800980 <memmove+0x3c>
  800965:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096b:	75 13                	jne    800980 <memmove+0x3c>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 0e                	jne    800980 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800972:	83 ef 04             	sub    $0x4,%edi
  800975:	8d 72 fc             	lea    -0x4(%edx),%esi
  800978:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097b:	fd                   	std    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 07                	jmp    800987 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800980:	4f                   	dec    %edi
  800981:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800984:	fd                   	std    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800987:	fc                   	cld    
  800988:	eb 20                	jmp    8009aa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 13                	jne    8009a5 <memmove+0x61>
  800992:	a8 03                	test   $0x3,%al
  800994:	75 0f                	jne    8009a5 <memmove+0x61>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 0a                	jne    8009a5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 05                	jmp    8009aa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	fc                   	cld    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009aa:	5e                   	pop    %esi
  8009ab:	5f                   	pop    %edi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 77 ff ff ff       	call   800944 <memmove>
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e3:	eb 16                	jmp    8009fb <memcmp+0x2c>
		if (*s1 != *s2)
  8009e5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009e8:	42                   	inc    %edx
  8009e9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009ed:	38 c8                	cmp    %cl,%al
  8009ef:	74 0a                	je     8009fb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009f1:	0f b6 c0             	movzbl %al,%eax
  8009f4:	0f b6 c9             	movzbl %cl,%ecx
  8009f7:	29 c8                	sub    %ecx,%eax
  8009f9:	eb 09                	jmp    800a04 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fb:	39 da                	cmp    %ebx,%edx
  8009fd:	75 e6                	jne    8009e5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5b                   	pop    %ebx
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a17:	eb 05                	jmp    800a1e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a19:	38 08                	cmp    %cl,(%eax)
  800a1b:	74 05                	je     800a22 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1d:	40                   	inc    %eax
  800a1e:	39 d0                	cmp    %edx,%eax
  800a20:	72 f7                	jb     800a19 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	eb 01                	jmp    800a33 <strtol+0xf>
		s++;
  800a32:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	8a 02                	mov    (%edx),%al
  800a35:	3c 20                	cmp    $0x20,%al
  800a37:	74 f9                	je     800a32 <strtol+0xe>
  800a39:	3c 09                	cmp    $0x9,%al
  800a3b:	74 f5                	je     800a32 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3d:	3c 2b                	cmp    $0x2b,%al
  800a3f:	75 08                	jne    800a49 <strtol+0x25>
		s++;
  800a41:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 13                	jmp    800a5c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a49:	3c 2d                	cmp    $0x2d,%al
  800a4b:	75 0a                	jne    800a57 <strtol+0x33>
		s++, neg = 1;
  800a4d:	8d 52 01             	lea    0x1(%edx),%edx
  800a50:	bf 01 00 00 00       	mov    $0x1,%edi
  800a55:	eb 05                	jmp    800a5c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	85 db                	test   %ebx,%ebx
  800a5e:	74 05                	je     800a65 <strtol+0x41>
  800a60:	83 fb 10             	cmp    $0x10,%ebx
  800a63:	75 28                	jne    800a8d <strtol+0x69>
  800a65:	8a 02                	mov    (%edx),%al
  800a67:	3c 30                	cmp    $0x30,%al
  800a69:	75 10                	jne    800a7b <strtol+0x57>
  800a6b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a6f:	75 0a                	jne    800a7b <strtol+0x57>
		s += 2, base = 16;
  800a71:	83 c2 02             	add    $0x2,%edx
  800a74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a79:	eb 12                	jmp    800a8d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	75 0e                	jne    800a8d <strtol+0x69>
  800a7f:	3c 30                	cmp    $0x30,%al
  800a81:	75 05                	jne    800a88 <strtol+0x64>
		s++, base = 8;
  800a83:	42                   	inc    %edx
  800a84:	b3 08                	mov    $0x8,%bl
  800a86:	eb 05                	jmp    800a8d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a88:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a94:	8a 0a                	mov    (%edx),%cl
  800a96:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a99:	80 fb 09             	cmp    $0x9,%bl
  800a9c:	77 08                	ja     800aa6 <strtol+0x82>
			dig = *s - '0';
  800a9e:	0f be c9             	movsbl %cl,%ecx
  800aa1:	83 e9 30             	sub    $0x30,%ecx
  800aa4:	eb 1e                	jmp    800ac4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aa6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aa9:	80 fb 19             	cmp    $0x19,%bl
  800aac:	77 08                	ja     800ab6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aae:	0f be c9             	movsbl %cl,%ecx
  800ab1:	83 e9 57             	sub    $0x57,%ecx
  800ab4:	eb 0e                	jmp    800ac4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ab6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 12                	ja     800ad0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800abe:	0f be c9             	movsbl %cl,%ecx
  800ac1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac4:	39 f1                	cmp    %esi,%ecx
  800ac6:	7d 0c                	jge    800ad4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ac8:	42                   	inc    %edx
  800ac9:	0f af c6             	imul   %esi,%eax
  800acc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ace:	eb c4                	jmp    800a94 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad0:	89 c1                	mov    %eax,%ecx
  800ad2:	eb 02                	jmp    800ad6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ada:	74 05                	je     800ae1 <strtol+0xbd>
		*endptr = (char *) s;
  800adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800adf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae1:	85 ff                	test   %edi,%edi
  800ae3:	74 04                	je     800ae9 <strtol+0xc5>
  800ae5:	89 c8                	mov    %ecx,%eax
  800ae7:	f7 d8                	neg    %eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    
	...

00800af0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	89 c6                	mov    %eax,%esi
  800b07:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	89 cb                	mov    %ecx,%ebx
  800b45:	89 cf                	mov    %ecx,%edi
  800b47:	89 ce                	mov    %ecx,%esi
  800b49:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7e 28                	jle    800b77 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b53:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b5a:	00 
  800b5b:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800b62:	00 
  800b63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b6a:	00 
  800b6b:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800b72:	e8 7d 07 00 00       	call   8012f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b77:	83 c4 2c             	add    $0x2c,%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_yield>:

void
sys_yield(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	be 00 00 00 00       	mov    $0x0,%esi
  800bcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 f7                	mov    %esi,%edi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 28                	jle    800c09 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bec:	00 
  800bed:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800bf4:	00 
  800bf5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfc:	00 
  800bfd:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800c04:	e8 eb 06 00 00       	call   8012f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c09:	83 c4 2c             	add    $0x2c,%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7e 28                	jle    800c5c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c3f:	00 
  800c40:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800c47:	00 
  800c48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4f:	00 
  800c50:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800c57:	e8 98 06 00 00       	call   8012f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5c:	83 c4 2c             	add    $0x2c,%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 06 00 00 00       	mov    $0x6,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 28                	jle    800caf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c92:	00 
  800c93:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800c9a:	00 
  800c9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca2:	00 
  800ca3:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800caa:	e8 45 06 00 00       	call   8012f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800caf:	83 c4 2c             	add    $0x2c,%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 28                	jle    800d02 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cde:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ce5:	00 
  800ce6:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800ced:	00 
  800cee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf5:	00 
  800cf6:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800cfd:	e8 f2 05 00 00       	call   8012f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d02:	83 c4 2c             	add    $0x2c,%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 28                	jle    800d55 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d31:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d38:	00 
  800d39:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800d40:	00 
  800d41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d48:	00 
  800d49:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800d50:	e8 9f 05 00 00       	call   8012f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d55:	83 c4 2c             	add    $0x2c,%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	be 00 00 00 00       	mov    $0x0,%esi
  800d68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 cb                	mov    %ecx,%ebx
  800d98:	89 cf                	mov    %ecx,%edi
  800d9a:	89 ce                	mov    %ecx,%esi
  800d9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 28                	jle    800dca <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dad:	00 
  800dae:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800db5:	00 
  800db6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbd:	00 
  800dbe:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800dc5:	e8 2a 05 00 00       	call   8012f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dca:	83 c4 2c             	add    $0x2c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
	...

00800dd4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 24             	sub    $0x24,%esp
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dde:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800de0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de4:	75 20                	jne    800e06 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800de6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dea:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  800df1:	00 
  800df2:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800df9:	00 
  800dfa:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  800e01:	e8 ee 04 00 00       	call   8012f4 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e06:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e11:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e18:	f6 c4 08             	test   $0x8,%ah
  800e1b:	75 1c                	jne    800e39 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e1d:	c7 44 24 08 40 19 80 	movl   $0x801940,0x8(%esp)
  800e24:	00 
  800e25:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e2c:	00 
  800e2d:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  800e34:	e8 bb 04 00 00       	call   8012f4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800e39:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e50:	e8 68 fd ff ff       	call   800bbd <sys_page_alloc>
  800e55:	85 c0                	test   %eax,%eax
  800e57:	79 20                	jns    800e79 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5d:	c7 44 24 08 9a 19 80 	movl   $0x80199a,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  800e74:	e8 7b 04 00 00       	call   8012f4 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800e79:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e80:	00 
  800e81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e85:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e8c:	e8 b3 fa ff ff       	call   800944 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800e91:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e98:	00 
  800e99:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb4:	e8 58 fd ff ff       	call   800c11 <sys_page_map>
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	79 20                	jns    800edd <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800ebd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec1:	c7 44 24 08 ad 19 80 	movl   $0x8019ad,0x8(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800ed0:	00 
  800ed1:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  800ed8:	e8 17 04 00 00       	call   8012f4 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800edd:	83 c4 24             	add    $0x24,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800eec:	c7 04 24 d4 0d 80 00 	movl   $0x800dd4,(%esp)
  800ef3:	e8 54 04 00 00       	call   80134c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef8:	ba 07 00 00 00       	mov    $0x7,%edx
  800efd:	89 d0                	mov    %edx,%eax
  800eff:	cd 30                	int    $0x30
  800f01:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f04:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f07:	85 c0                	test   %eax,%eax
  800f09:	79 20                	jns    800f2b <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0f:	c7 44 24 08 be 19 80 	movl   $0x8019be,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f1e:	00 
  800f1f:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  800f26:	e8 c9 03 00 00       	call   8012f4 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f2b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f2f:	75 25                	jne    800f56 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f31:	e8 49 fc ff ff       	call   800b7f <sys_getenvid>
  800f36:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f42:	c1 e0 07             	shl    $0x7,%eax
  800f45:	29 d0                	sub    %edx,%eax
  800f47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4c:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f51:	e9 58 02 00 00       	jmp    8011ae <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800f56:	bf 00 00 00 00       	mov    $0x0,%edi
  800f5b:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f65:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6c:	a8 01                	test   $0x1,%al
  800f6e:	0f 84 7a 01 00 00    	je     8010ee <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800f74:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f7b:	a8 01                	test   $0x1,%al
  800f7d:	0f 84 6b 01 00 00    	je     8010ee <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800f83:	a1 04 20 80 00       	mov    0x802004,%eax
  800f88:	8b 40 48             	mov    0x48(%eax),%eax
  800f8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800f8e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f95:	f6 c4 04             	test   $0x4,%ah
  800f98:	74 52                	je     800fec <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800f9a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800faa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fbc:	89 04 24             	mov    %eax,(%esp)
  800fbf:	e8 4d fc ff ff       	call   800c11 <sys_page_map>
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	0f 89 22 01 00 00    	jns    8010ee <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  800fcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd0:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800fdf:	00 
  800fe0:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  800fe7:	e8 08 03 00 00       	call   8012f4 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  800fec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff3:	f6 c4 08             	test   $0x8,%ah
  800ff6:	75 0f                	jne    801007 <fork+0x124>
  800ff8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fff:	a8 02                	test   $0x2,%al
  801001:	0f 84 99 00 00 00    	je     8010a0 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801007:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100e:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801011:	83 f8 01             	cmp    $0x1,%eax
  801014:	19 db                	sbb    %ebx,%ebx
  801016:	83 e3 fc             	and    $0xfffffffc,%ebx
  801019:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80101f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801023:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801027:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801032:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801035:	89 04 24             	mov    %eax,(%esp)
  801038:	e8 d4 fb ff ff       	call   800c11 <sys_page_map>
  80103d:	85 c0                	test   %eax,%eax
  80103f:	79 20                	jns    801061 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801041:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801045:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  80105c:	e8 93 02 00 00       	call   8012f4 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801061:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80106c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801070:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801074:	89 04 24             	mov    %eax,(%esp)
  801077:	e8 95 fb ff ff       	call   800c11 <sys_page_map>
  80107c:	85 c0                	test   %eax,%eax
  80107e:	79 6e                	jns    8010ee <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801084:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  80108b:	00 
  80108c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801093:	00 
  801094:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  80109b:	e8 54 02 00 00       	call   8012f4 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010a0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c2:	89 04 24             	mov    %eax,(%esp)
  8010c5:	e8 47 fb ff ff       	call   800c11 <sys_page_map>
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	79 20                	jns    8010ee <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d2:	c7 44 24 08 ce 19 80 	movl   $0x8019ce,0x8(%esp)
  8010d9:	00 
  8010da:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8010e1:	00 
  8010e2:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  8010e9:	e8 06 02 00 00       	call   8012f4 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8010ee:	46                   	inc    %esi
  8010ef:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010f5:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010fb:	0f 85 5f fe ff ff    	jne    800f60 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801101:	c7 44 24 04 ec 13 80 	movl   $0x8013ec,0x4(%esp)
  801108:	00 
  801109:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 f6 fb ff ff       	call   800d0a <sys_env_set_pgfault_upcall>
  801114:	85 c0                	test   %eax,%eax
  801116:	79 20                	jns    801138 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111c:	c7 44 24 08 70 19 80 	movl   $0x801970,0x8(%esp)
  801123:	00 
  801124:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  801133:	e8 bc 01 00 00       	call   8012f4 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801138:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113f:	00 
  801140:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801147:	ee 
  801148:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80114b:	89 04 24             	mov    %eax,(%esp)
  80114e:	e8 6a fa ff ff       	call   800bbd <sys_page_alloc>
  801153:	85 c0                	test   %eax,%eax
  801155:	79 20                	jns    801177 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  801157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115b:	c7 44 24 08 9a 19 80 	movl   $0x80199a,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  801172:	e8 7d 01 00 00       	call   8012f4 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801177:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80117e:	00 
  80117f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801182:	89 04 24             	mov    %eax,(%esp)
  801185:	e8 2d fb ff ff       	call   800cb7 <sys_env_set_status>
  80118a:	85 c0                	test   %eax,%eax
  80118c:	79 20                	jns    8011ae <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  80118e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801192:	c7 44 24 08 e0 19 80 	movl   $0x8019e0,0x8(%esp)
  801199:	00 
  80119a:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011a1:	00 
  8011a2:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  8011a9:	e8 46 01 00 00       	call   8012f4 <_panic>
	}
	
	return envid;
}
  8011ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b1:	83 c4 3c             	add    $0x3c,%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011bf:	c7 44 24 08 f7 19 80 	movl   $0x8019f7,0x8(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8011ce:	00 
  8011cf:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  8011d6:	e8 19 01 00 00       	call   8012f4 <_panic>
	...

008011dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 10             	sub    $0x10,%esp
  8011e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	75 05                	jne    8011f6 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8011f1:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8011f6:	89 04 24             	mov    %eax,(%esp)
  8011f9:	e8 82 fb ff ff       	call   800d80 <sys_ipc_recv>
	if (!err) {
  8011fe:	85 c0                	test   %eax,%eax
  801200:	75 26                	jne    801228 <ipc_recv+0x4c>
		if (from_env_store) {
  801202:	85 f6                	test   %esi,%esi
  801204:	74 0a                	je     801210 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801206:	a1 04 20 80 00       	mov    0x802004,%eax
  80120b:	8b 40 74             	mov    0x74(%eax),%eax
  80120e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801210:	85 db                	test   %ebx,%ebx
  801212:	74 0a                	je     80121e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801214:	a1 04 20 80 00       	mov    0x802004,%eax
  801219:	8b 40 78             	mov    0x78(%eax),%eax
  80121c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80121e:	a1 04 20 80 00       	mov    0x802004,%eax
  801223:	8b 40 70             	mov    0x70(%eax),%eax
  801226:	eb 14                	jmp    80123c <ipc_recv+0x60>
	}
	if (from_env_store) {
  801228:	85 f6                	test   %esi,%esi
  80122a:	74 06                	je     801232 <ipc_recv+0x56>
		*from_env_store = 0;
  80122c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801232:	85 db                	test   %ebx,%ebx
  801234:	74 06                	je     80123c <ipc_recv+0x60>
		*perm_store = 0;
  801236:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	57                   	push   %edi
  801247:	56                   	push   %esi
  801248:	53                   	push   %ebx
  801249:	83 ec 1c             	sub    $0x1c,%esp
  80124c:	8b 75 10             	mov    0x10(%ebp),%esi
  80124f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801252:	85 f6                	test   %esi,%esi
  801254:	75 05                	jne    80125b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801256:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80125b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80125f:	89 74 24 08          	mov    %esi,0x8(%esp)
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
  801266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
  80126d:	89 04 24             	mov    %eax,(%esp)
  801270:	e8 e8 fa ff ff       	call   800d5d <sys_ipc_try_send>
  801275:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801277:	e8 22 f9 ff ff       	call   800b9e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  80127c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80127f:	74 da                	je     80125b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801281:	85 db                	test   %ebx,%ebx
  801283:	74 20                	je     8012a5 <ipc_send+0x62>
		panic("send fail: %e", err);
  801285:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801289:	c7 44 24 08 0d 1a 80 	movl   $0x801a0d,0x8(%esp)
  801290:	00 
  801291:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801298:	00 
  801299:	c7 04 24 1b 1a 80 00 	movl   $0x801a1b,(%esp)
  8012a0:	e8 4f 00 00 00       	call   8012f4 <_panic>
	}
	return;
}
  8012a5:	83 c4 1c             	add    $0x1c,%esp
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5f                   	pop    %edi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	53                   	push   %ebx
  8012b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8012b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012b9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	c1 e2 07             	shl    $0x7,%edx
  8012c5:	29 ca                	sub    %ecx,%edx
  8012c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012cd:	8b 52 50             	mov    0x50(%edx),%edx
  8012d0:	39 da                	cmp    %ebx,%edx
  8012d2:	75 0f                	jne    8012e3 <ipc_find_env+0x36>
			return envs[i].env_id;
  8012d4:	c1 e0 07             	shl    $0x7,%eax
  8012d7:	29 c8                	sub    %ecx,%eax
  8012d9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8012de:	8b 40 40             	mov    0x40(%eax),%eax
  8012e1:	eb 0c                	jmp    8012ef <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012e3:	40                   	inc    %eax
  8012e4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012e9:	75 ce                	jne    8012b9 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012eb:	66 b8 00 00          	mov    $0x0,%ax
}
  8012ef:	5b                   	pop    %ebx
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
	...

008012f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012fc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ff:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801305:	e8 75 f8 ff ff       	call   800b7f <sys_getenvid>
  80130a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801311:	8b 55 08             	mov    0x8(%ebp),%edx
  801314:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801320:	c7 04 24 28 1a 80 00 	movl   $0x801a28,(%esp)
  801327:	e8 d4 ee ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80132c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801330:	8b 45 10             	mov    0x10(%ebp),%eax
  801333:	89 04 24             	mov    %eax,(%esp)
  801336:	e8 64 ee ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  80133b:	c7 04 24 de 19 80 00 	movl   $0x8019de,(%esp)
  801342:	e8 b9 ee ff ff       	call   800200 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801347:	cc                   	int3   
  801348:	eb fd                	jmp    801347 <_panic+0x53>
	...

0080134c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801352:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801359:	0f 85 80 00 00 00    	jne    8013df <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  80135f:	a1 04 20 80 00       	mov    0x802004,%eax
  801364:	8b 40 48             	mov    0x48(%eax),%eax
  801367:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801376:	ee 
  801377:	89 04 24             	mov    %eax,(%esp)
  80137a:	e8 3e f8 ff ff       	call   800bbd <sys_page_alloc>
  80137f:	85 c0                	test   %eax,%eax
  801381:	79 20                	jns    8013a3 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  801383:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801387:	c7 44 24 08 4c 1a 80 	movl   $0x801a4c,0x8(%esp)
  80138e:	00 
  80138f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801396:	00 
  801397:	c7 04 24 a8 1a 80 00 	movl   $0x801aa8,(%esp)
  80139e:	e8 51 ff ff ff       	call   8012f4 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8013a3:	a1 04 20 80 00       	mov    0x802004,%eax
  8013a8:	8b 40 48             	mov    0x48(%eax),%eax
  8013ab:	c7 44 24 04 ec 13 80 	movl   $0x8013ec,0x4(%esp)
  8013b2:	00 
  8013b3:	89 04 24             	mov    %eax,(%esp)
  8013b6:	e8 4f f9 ff ff       	call   800d0a <sys_env_set_pgfault_upcall>
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	79 20                	jns    8013df <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  8013bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c3:	c7 44 24 08 78 1a 80 	movl   $0x801a78,0x8(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 a8 1a 80 00 	movl   $0x801aa8,(%esp)
  8013da:	e8 15 ff ff ff       	call   8012f4 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    
  8013e9:	00 00                	add    %al,(%eax)
	...

008013ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013ed:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013f4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8013f7:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8013fb:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8013fd:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  801400:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  801401:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  801404:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  801406:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  801409:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80140a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80140d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80140e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80140f:	c3                   	ret    

00801410 <__udivdi3>:
  801410:	55                   	push   %ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	83 ec 10             	sub    $0x10,%esp
  801416:	8b 74 24 20          	mov    0x20(%esp),%esi
  80141a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80141e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801422:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801426:	89 cd                	mov    %ecx,%ebp
  801428:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80142c:	85 c0                	test   %eax,%eax
  80142e:	75 2c                	jne    80145c <__udivdi3+0x4c>
  801430:	39 f9                	cmp    %edi,%ecx
  801432:	77 68                	ja     80149c <__udivdi3+0x8c>
  801434:	85 c9                	test   %ecx,%ecx
  801436:	75 0b                	jne    801443 <__udivdi3+0x33>
  801438:	b8 01 00 00 00       	mov    $0x1,%eax
  80143d:	31 d2                	xor    %edx,%edx
  80143f:	f7 f1                	div    %ecx
  801441:	89 c1                	mov    %eax,%ecx
  801443:	31 d2                	xor    %edx,%edx
  801445:	89 f8                	mov    %edi,%eax
  801447:	f7 f1                	div    %ecx
  801449:	89 c7                	mov    %eax,%edi
  80144b:	89 f0                	mov    %esi,%eax
  80144d:	f7 f1                	div    %ecx
  80144f:	89 c6                	mov    %eax,%esi
  801451:	89 f0                	mov    %esi,%eax
  801453:	89 fa                	mov    %edi,%edx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    
  80145c:	39 f8                	cmp    %edi,%eax
  80145e:	77 2c                	ja     80148c <__udivdi3+0x7c>
  801460:	0f bd f0             	bsr    %eax,%esi
  801463:	83 f6 1f             	xor    $0x1f,%esi
  801466:	75 4c                	jne    8014b4 <__udivdi3+0xa4>
  801468:	39 f8                	cmp    %edi,%eax
  80146a:	bf 00 00 00 00       	mov    $0x0,%edi
  80146f:	72 0a                	jb     80147b <__udivdi3+0x6b>
  801471:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801475:	0f 87 ad 00 00 00    	ja     801528 <__udivdi3+0x118>
  80147b:	be 01 00 00 00       	mov    $0x1,%esi
  801480:	89 f0                	mov    %esi,%eax
  801482:	89 fa                	mov    %edi,%edx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    
  80148b:	90                   	nop
  80148c:	31 ff                	xor    %edi,%edi
  80148e:	31 f6                	xor    %esi,%esi
  801490:	89 f0                	mov    %esi,%eax
  801492:	89 fa                	mov    %edi,%edx
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	5e                   	pop    %esi
  801498:	5f                   	pop    %edi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
  80149b:	90                   	nop
  80149c:	89 fa                	mov    %edi,%edx
  80149e:	89 f0                	mov    %esi,%eax
  8014a0:	f7 f1                	div    %ecx
  8014a2:	89 c6                	mov    %eax,%esi
  8014a4:	31 ff                	xor    %edi,%edi
  8014a6:	89 f0                	mov    %esi,%eax
  8014a8:	89 fa                	mov    %edi,%edx
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	5e                   	pop    %esi
  8014ae:	5f                   	pop    %edi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    
  8014b1:	8d 76 00             	lea    0x0(%esi),%esi
  8014b4:	89 f1                	mov    %esi,%ecx
  8014b6:	d3 e0                	shl    %cl,%eax
  8014b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c1:	29 f0                	sub    %esi,%eax
  8014c3:	89 ea                	mov    %ebp,%edx
  8014c5:	88 c1                	mov    %al,%cl
  8014c7:	d3 ea                	shr    %cl,%edx
  8014c9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8014cd:	09 ca                	or     %ecx,%edx
  8014cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014d3:	89 f1                	mov    %esi,%ecx
  8014d5:	d3 e5                	shl    %cl,%ebp
  8014d7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8014db:	89 fd                	mov    %edi,%ebp
  8014dd:	88 c1                	mov    %al,%cl
  8014df:	d3 ed                	shr    %cl,%ebp
  8014e1:	89 fa                	mov    %edi,%edx
  8014e3:	89 f1                	mov    %esi,%ecx
  8014e5:	d3 e2                	shl    %cl,%edx
  8014e7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014eb:	88 c1                	mov    %al,%cl
  8014ed:	d3 ef                	shr    %cl,%edi
  8014ef:	09 d7                	or     %edx,%edi
  8014f1:	89 f8                	mov    %edi,%eax
  8014f3:	89 ea                	mov    %ebp,%edx
  8014f5:	f7 74 24 08          	divl   0x8(%esp)
  8014f9:	89 d1                	mov    %edx,%ecx
  8014fb:	89 c7                	mov    %eax,%edi
  8014fd:	f7 64 24 0c          	mull   0xc(%esp)
  801501:	39 d1                	cmp    %edx,%ecx
  801503:	72 17                	jb     80151c <__udivdi3+0x10c>
  801505:	74 09                	je     801510 <__udivdi3+0x100>
  801507:	89 fe                	mov    %edi,%esi
  801509:	31 ff                	xor    %edi,%edi
  80150b:	e9 41 ff ff ff       	jmp    801451 <__udivdi3+0x41>
  801510:	8b 54 24 04          	mov    0x4(%esp),%edx
  801514:	89 f1                	mov    %esi,%ecx
  801516:	d3 e2                	shl    %cl,%edx
  801518:	39 c2                	cmp    %eax,%edx
  80151a:	73 eb                	jae    801507 <__udivdi3+0xf7>
  80151c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80151f:	31 ff                	xor    %edi,%edi
  801521:	e9 2b ff ff ff       	jmp    801451 <__udivdi3+0x41>
  801526:	66 90                	xchg   %ax,%ax
  801528:	31 f6                	xor    %esi,%esi
  80152a:	e9 22 ff ff ff       	jmp    801451 <__udivdi3+0x41>
	...

00801530 <__umoddi3>:
  801530:	55                   	push   %ebp
  801531:	57                   	push   %edi
  801532:	56                   	push   %esi
  801533:	83 ec 20             	sub    $0x20,%esp
  801536:	8b 44 24 30          	mov    0x30(%esp),%eax
  80153a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80153e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801542:	8b 74 24 34          	mov    0x34(%esp),%esi
  801546:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80154a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80154e:	89 c7                	mov    %eax,%edi
  801550:	89 f2                	mov    %esi,%edx
  801552:	85 ed                	test   %ebp,%ebp
  801554:	75 16                	jne    80156c <__umoddi3+0x3c>
  801556:	39 f1                	cmp    %esi,%ecx
  801558:	0f 86 a6 00 00 00    	jbe    801604 <__umoddi3+0xd4>
  80155e:	f7 f1                	div    %ecx
  801560:	89 d0                	mov    %edx,%eax
  801562:	31 d2                	xor    %edx,%edx
  801564:	83 c4 20             	add    $0x20,%esp
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
  80156b:	90                   	nop
  80156c:	39 f5                	cmp    %esi,%ebp
  80156e:	0f 87 ac 00 00 00    	ja     801620 <__umoddi3+0xf0>
  801574:	0f bd c5             	bsr    %ebp,%eax
  801577:	83 f0 1f             	xor    $0x1f,%eax
  80157a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80157e:	0f 84 a8 00 00 00    	je     80162c <__umoddi3+0xfc>
  801584:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801588:	d3 e5                	shl    %cl,%ebp
  80158a:	bf 20 00 00 00       	mov    $0x20,%edi
  80158f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801593:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801597:	89 f9                	mov    %edi,%ecx
  801599:	d3 e8                	shr    %cl,%eax
  80159b:	09 e8                	or     %ebp,%eax
  80159d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8015a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015a9:	d3 e0                	shl    %cl,%eax
  8015ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015af:	89 f2                	mov    %esi,%edx
  8015b1:	d3 e2                	shl    %cl,%edx
  8015b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015b7:	d3 e0                	shl    %cl,%eax
  8015b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8015bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015c1:	89 f9                	mov    %edi,%ecx
  8015c3:	d3 e8                	shr    %cl,%eax
  8015c5:	09 d0                	or     %edx,%eax
  8015c7:	d3 ee                	shr    %cl,%esi
  8015c9:	89 f2                	mov    %esi,%edx
  8015cb:	f7 74 24 18          	divl   0x18(%esp)
  8015cf:	89 d6                	mov    %edx,%esi
  8015d1:	f7 64 24 0c          	mull   0xc(%esp)
  8015d5:	89 c5                	mov    %eax,%ebp
  8015d7:	89 d1                	mov    %edx,%ecx
  8015d9:	39 d6                	cmp    %edx,%esi
  8015db:	72 67                	jb     801644 <__umoddi3+0x114>
  8015dd:	74 75                	je     801654 <__umoddi3+0x124>
  8015df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8015e3:	29 e8                	sub    %ebp,%eax
  8015e5:	19 ce                	sbb    %ecx,%esi
  8015e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015eb:	d3 e8                	shr    %cl,%eax
  8015ed:	89 f2                	mov    %esi,%edx
  8015ef:	89 f9                	mov    %edi,%ecx
  8015f1:	d3 e2                	shl    %cl,%edx
  8015f3:	09 d0                	or     %edx,%eax
  8015f5:	89 f2                	mov    %esi,%edx
  8015f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015fb:	d3 ea                	shr    %cl,%edx
  8015fd:	83 c4 20             	add    $0x20,%esp
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    
  801604:	85 c9                	test   %ecx,%ecx
  801606:	75 0b                	jne    801613 <__umoddi3+0xe3>
  801608:	b8 01 00 00 00       	mov    $0x1,%eax
  80160d:	31 d2                	xor    %edx,%edx
  80160f:	f7 f1                	div    %ecx
  801611:	89 c1                	mov    %eax,%ecx
  801613:	89 f0                	mov    %esi,%eax
  801615:	31 d2                	xor    %edx,%edx
  801617:	f7 f1                	div    %ecx
  801619:	89 f8                	mov    %edi,%eax
  80161b:	e9 3e ff ff ff       	jmp    80155e <__umoddi3+0x2e>
  801620:	89 f2                	mov    %esi,%edx
  801622:	83 c4 20             	add    $0x20,%esp
  801625:	5e                   	pop    %esi
  801626:	5f                   	pop    %edi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    
  801629:	8d 76 00             	lea    0x0(%esi),%esi
  80162c:	39 f5                	cmp    %esi,%ebp
  80162e:	72 04                	jb     801634 <__umoddi3+0x104>
  801630:	39 f9                	cmp    %edi,%ecx
  801632:	77 06                	ja     80163a <__umoddi3+0x10a>
  801634:	89 f2                	mov    %esi,%edx
  801636:	29 cf                	sub    %ecx,%edi
  801638:	19 ea                	sbb    %ebp,%edx
  80163a:	89 f8                	mov    %edi,%eax
  80163c:	83 c4 20             	add    $0x20,%esp
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    
  801643:	90                   	nop
  801644:	89 d1                	mov    %edx,%ecx
  801646:	89 c5                	mov    %eax,%ebp
  801648:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80164c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801650:	eb 8d                	jmp    8015df <__umoddi3+0xaf>
  801652:	66 90                	xchg   %ax,%ax
  801654:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801658:	72 ea                	jb     801644 <__umoddi3+0x114>
  80165a:	89 f1                	mov    %esi,%ecx
  80165c:	eb 81                	jmp    8015df <__umoddi3+0xaf>
