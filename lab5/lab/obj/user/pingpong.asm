
obj/user/pingpong.debug:     file format elf32-i386


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
  80003d:	e8 fd 0e 00 00       	call   800f3f <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 37 0b 00 00       	call   800b87 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  80005f:	e8 a4 01 00 00       	call   800208 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 18 12 00 00       	call   80129f <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 96 11 00 00       	call   801238 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 db 0a 00 00       	call   800b87 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 96 24 80 00 	movl   $0x802496,(%esp)
  8000bf:	e8 44 01 00 00       	call   800208 <cprintf>
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
  8000e4:	e8 b6 11 00 00       	call   80129f <ipc_send>
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
  800106:	e8 7c 0a 00 00       	call   800b87 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800152:	e8 e0 13 00 00       	call   801537 <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 d2 09 00 00       	call   800b35 <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 14             	sub    $0x14,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 19                	jne    80019e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800185:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018c:	00 
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 60 09 00 00       	call   800af8 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019e:	ff 43 04             	incl   0x4(%ebx)
}
  8001a1:	83 c4 14             	add    $0x14,%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	c7 04 24 68 01 80 00 	movl   $0x800168,(%esp)
  8001e3:	e8 82 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 f8 08 00 00       	call   800af8 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 87 ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    
	...

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 3c             	sub    $0x3c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d7                	mov    %edx,%edi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800241:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	85 c0                	test   %eax,%eax
  800246:	75 08                	jne    800250 <printnum+0x2c>
  800248:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024e:	77 57                	ja     8002a7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	89 74 24 10          	mov    %esi,0x10(%esp)
  800254:	4b                   	dec    %ebx
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 45 10             	mov    0x10(%ebp),%eax
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800264:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 a6 1f 00 00       	call   802228 <__udivdi3>
  800282:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800291:	89 fa                	mov    %edi,%edx
  800293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800296:	e8 89 ff ff ff       	call   800224 <printnum>
  80029b:	eb 0f                	jmp    8002ac <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a1:	89 34 24             	mov    %esi,(%esp)
  8002a4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	4b                   	dec    %ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f f1                	jg     80029d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c2:	00 
  8002c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	e8 73 20 00 00       	call   802348 <__umoddi3>
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	0f be 80 b3 24 80 00 	movsbl 0x8024b3(%eax),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e6:	83 c4 3c             	add    $0x3c,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 fa 01             	cmp    $0x1,%edx
  8002f4:	7e 0e                	jle    800304 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	8b 52 04             	mov    0x4(%edx),%edx
  800302:	eb 22                	jmp    800326 <getuint+0x38>
	else if (lflag)
  800304:	85 d2                	test   %edx,%edx
  800306:	74 10                	je     800318 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 0e                	jmp    800326 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800331:	8b 10                	mov    (%eax),%edx
  800333:	3b 50 04             	cmp    0x4(%eax),%edx
  800336:	73 08                	jae    800340 <sprintputch+0x18>
		*b->buf++ = ch;
  800338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033b:	88 0a                	mov    %cl,(%edx)
  80033d:	42                   	inc    %edx
  80033e:	89 10                	mov    %edx,(%eax)
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800348:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034f:	8b 45 10             	mov    0x10(%ebp),%eax
  800352:	89 44 24 08          	mov    %eax,0x8(%esp)
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	e8 02 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 4c             	sub    $0x4c,%esp
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 75 10             	mov    0x10(%ebp),%esi
  800379:	eb 12                	jmp    80038d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037b:	85 c0                	test   %eax,%eax
  80037d:	0f 84 8b 03 00 00    	je     80070e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800383:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	0f b6 06             	movzbl (%esi),%eax
  800390:	46                   	inc    %esi
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e5                	jne    80037b <vprintfmt+0x11>
  800396:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80039a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b2:	eb 26                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003bb:	eb 1d                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c4:	eb 14                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d0:	eb 08                	jmp    8003da <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	0f b6 06             	movzbl (%esi),%eax
  8003dd:	8d 56 01             	lea    0x1(%esi),%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e3:	8a 16                	mov    (%esi),%dl
  8003e5:	83 ea 23             	sub    $0x23,%edx
  8003e8:	80 fa 55             	cmp    $0x55,%dl
  8003eb:	0f 87 01 03 00 00    	ja     8006f2 <vprintfmt+0x388>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	ff 24 95 00 26 80 00 	jmp    *0x802600(,%edx,4)
  8003fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fe:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800403:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800406:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80040a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80040d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800410:	83 fa 09             	cmp    $0x9,%edx
  800413:	77 2a                	ja     80043f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800415:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800416:	eb eb                	jmp    800403 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800426:	eb 17                	jmp    80043f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800428:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042c:	78 98                	js     8003c6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800431:	eb a7                	jmp    8003da <vprintfmt+0x70>
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800436:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80043d:	eb 9b                	jmp    8003da <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800443:	79 95                	jns    8003da <vprintfmt+0x70>
  800445:	eb 8b                	jmp    8003d2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044b:	eb 8d                	jmp    8003da <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800465:	e9 23 ff ff ff       	jmp    80038d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	85 c0                	test   %eax,%eax
  800477:	79 02                	jns    80047b <vprintfmt+0x111>
  800479:	f7 d8                	neg    %eax
  80047b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 0f             	cmp    $0xf,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x123>
  800482:	8b 04 85 60 27 80 00 	mov    0x802760(,%eax,4),%eax
  800489:	85 c0                	test   %eax,%eax
  80048b:	75 23                	jne    8004b0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80048d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800491:	c7 44 24 08 cb 24 80 	movl   $0x8024cb,0x8(%esp)
  800498:	00 
  800499:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 9a fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ab:	e9 dd fe ff ff       	jmp    80038d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b4:	c7 44 24 08 d2 29 80 	movl   $0x8029d2,0x8(%esp)
  8004bb:	00 
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c3:	89 14 24             	mov    %edx,(%esp)
  8004c6:	e8 77 fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ce:	e9 ba fe ff ff       	jmp    80038d <vprintfmt+0x23>
  8004d3:	89 f9                	mov    %edi,%ecx
  8004d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 30                	mov    (%eax),%esi
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	75 05                	jne    8004ef <vprintfmt+0x185>
				p = "(null)";
  8004ea:	be c4 24 80 00       	mov    $0x8024c4,%esi
			if (width > 0 && padc != '-')
  8004ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f3:	0f 8e 84 00 00 00    	jle    80057d <vprintfmt+0x213>
  8004f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004fd:	74 7e                	je     80057d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800503:	89 34 24             	mov    %esi,(%esp)
  800506:	e8 ab 02 00 00       	call   8007b6 <strnlen>
  80050b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800513:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800517:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80051a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80051d:	89 de                	mov    %ebx,%esi
  80051f:	89 d3                	mov    %edx,%ebx
  800521:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	eb 0b                	jmp    800530 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800525:	89 74 24 04          	mov    %esi,0x4(%esp)
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <vprintfmt+0x1bb>
  800534:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800537:	89 f3                	mov    %esi,%ebx
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	79 05                	jns    800548 <vprintfmt+0x1de>
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054b:	29 c2                	sub    %eax,%edx
  80054d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800550:	eb 2b                	jmp    80057d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800556:	74 18                	je     800570 <vprintfmt+0x206>
  800558:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055b:	83 fa 5e             	cmp    $0x5e,%edx
  80055e:	76 10                	jbe    800570 <vprintfmt+0x206>
					putch('?', putdat);
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	eb 0a                	jmp    80057a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	ff 4d e4             	decl   -0x1c(%ebp)
  80057d:	0f be 06             	movsbl (%esi),%eax
  800580:	46                   	inc    %esi
  800581:	85 c0                	test   %eax,%eax
  800583:	74 21                	je     8005a6 <vprintfmt+0x23c>
  800585:	85 ff                	test   %edi,%edi
  800587:	78 c9                	js     800552 <vprintfmt+0x1e8>
  800589:	4f                   	dec    %edi
  80058a:	79 c6                	jns    800552 <vprintfmt+0x1e8>
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 de                	mov    %ebx,%esi
  800591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800594:	eb 18                	jmp    8005ae <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	4b                   	dec    %ebx
  8005a4:	eb 08                	jmp    8005ae <vprintfmt+0x244>
  8005a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a9:	89 de                	mov    %ebx,%esi
  8005ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f e4                	jg     800596 <vprintfmt+0x22c>
  8005b2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ba:	e9 ce fd ff ff       	jmp    80038d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7e 10                	jle    8005d4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
  8005cf:	8b 78 04             	mov    0x4(%eax),%edi
  8005d2:	eb 26                	jmp    8005fa <vprintfmt+0x290>
	else if (lflag)
  8005d4:	85 c9                	test   %ecx,%ecx
  8005d6:	74 12                	je     8005ea <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 30                	mov    (%eax),%esi
  8005e3:	89 f7                	mov    %esi,%edi
  8005e5:	c1 ff 1f             	sar    $0x1f,%edi
  8005e8:	eb 10                	jmp    8005fa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 30                	mov    (%eax),%esi
  8005f5:	89 f7                	mov    %esi,%edi
  8005f7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	78 0a                	js     800608 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	e9 ac 00 00 00       	jmp    8006b4 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800616:	f7 de                	neg    %esi
  800618:	83 d7 00             	adc    $0x0,%edi
  80061b:	f7 df                	neg    %edi
			}
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	e9 8d 00 00 00       	jmp    8006b4 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800627:	89 ca                	mov    %ecx,%edx
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 bd fc ff ff       	call   8002ee <getuint>
  800631:	89 c6                	mov    %eax,%esi
  800633:	89 d7                	mov    %edx,%edi
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80063a:	eb 78                	jmp    8006b4 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800669:	e9 1f fd ff ff       	jmp    80038d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80066e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800672:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800679:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800693:	8b 30                	mov    (%eax),%esi
  800695:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069f:	eb 13                	jmp    8006b4 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 43 fc ff ff       	call   8002ee <getuint>
  8006ab:	89 c6                	mov    %eax,%esi
  8006ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c7:	89 34 24             	mov    %esi,(%esp)
  8006ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	e8 4c fb ff ff       	call   800224 <printnum>
			break;
  8006d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006db:	e9 ad fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9b fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800700:	eb 01                	jmp    800703 <vprintfmt+0x399>
  800702:	4e                   	dec    %esi
  800703:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800707:	75 f9                	jne    800702 <vprintfmt+0x398>
  800709:	e9 7f fc ff ff       	jmp    80038d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80070e:	83 c4 4c             	add    $0x4c,%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 28             	sub    $0x28,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 30                	je     800767 <vsnprintf+0x51>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 33                	jle    80076e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  800757:	e8 0e fc ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800765:	eb 0c                	jmp    800773 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800767:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076c:	eb 05                	jmp    800773 <vsnprintf+0x5d>
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 7b ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    
  80079d:	00 00                	add    %al,(%eax)
	...

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	eb 01                	jmp    8007ae <strlen+0xe>
		n++;
  8007ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b2:	75 f9                	jne    8007ad <strlen+0xd>
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 01                	jmp    8007c7 <strnlen+0x11>
		n++;
  8007c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c7:	39 d0                	cmp    %edx,%eax
  8007c9:	74 06                	je     8007d1 <strnlen+0x1b>
  8007cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cf:	75 f5                	jne    8007c6 <strnlen+0x10>
		n++;
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e8:	42                   	inc    %edx
  8007e9:	84 c9                	test   %cl,%cl
  8007eb:	75 f5                	jne    8007e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fa:	89 1c 24             	mov    %ebx,(%esp)
  8007fd:	e8 9e ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	89 54 24 04          	mov    %edx,0x4(%esp)
  800809:	01 d8                	add    %ebx,%eax
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	e8 c0 ff ff ff       	call   8007d3 <strcpy>
	return dst;
}
  800813:	89 d8                	mov    %ebx,%eax
  800815:	83 c4 08             	add    $0x8,%esp
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	eb 0c                	jmp    80083c <strncpy+0x21>
		*dst++ = *src;
  800830:	8a 1a                	mov    (%edx),%bl
  800832:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800835:	80 3a 01             	cmpb   $0x1,(%edx)
  800838:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	41                   	inc    %ecx
  80083c:	39 f1                	cmp    %esi,%ecx
  80083e:	75 f0                	jne    800830 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800852:	85 d2                	test   %edx,%edx
  800854:	75 0a                	jne    800860 <strlcpy+0x1c>
  800856:	89 f0                	mov    %esi,%eax
  800858:	eb 1a                	jmp    800874 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085a:	88 18                	mov    %bl,(%eax)
  80085c:	40                   	inc    %eax
  80085d:	41                   	inc    %ecx
  80085e:	eb 02                	jmp    800862 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800860:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800862:	4a                   	dec    %edx
  800863:	74 0a                	je     80086f <strlcpy+0x2b>
  800865:	8a 19                	mov    (%ecx),%bl
  800867:	84 db                	test   %bl,%bl
  800869:	75 ef                	jne    80085a <strlcpy+0x16>
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	eb 02                	jmp    800871 <strlcpy+0x2d>
  80086f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800871:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800883:	eb 02                	jmp    800887 <strcmp+0xd>
		p++, q++;
  800885:	41                   	inc    %ecx
  800886:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800887:	8a 01                	mov    (%ecx),%al
  800889:	84 c0                	test   %al,%al
  80088b:	74 04                	je     800891 <strcmp+0x17>
  80088d:	3a 02                	cmp    (%edx),%al
  80088f:	74 f4                	je     800885 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800891:	0f b6 c0             	movzbl %al,%eax
  800894:	0f b6 12             	movzbl (%edx),%edx
  800897:	29 d0                	sub    %edx,%eax
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008a8:	eb 03                	jmp    8008ad <strncmp+0x12>
		n--, p++, q++;
  8008aa:	4a                   	dec    %edx
  8008ab:	40                   	inc    %eax
  8008ac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ad:	85 d2                	test   %edx,%edx
  8008af:	74 14                	je     8008c5 <strncmp+0x2a>
  8008b1:	8a 18                	mov    (%eax),%bl
  8008b3:	84 db                	test   %bl,%bl
  8008b5:	74 04                	je     8008bb <strncmp+0x20>
  8008b7:	3a 19                	cmp    (%ecx),%bl
  8008b9:	74 ef                	je     8008aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	0f b6 11             	movzbl (%ecx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
  8008c3:	eb 05                	jmp    8008ca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d6:	eb 05                	jmp    8008dd <strchr+0x10>
		if (*s == c)
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	74 0c                	je     8008e8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008dc:	40                   	inc    %eax
  8008dd:	8a 10                	mov    (%eax),%dl
  8008df:	84 d2                	test   %dl,%dl
  8008e1:	75 f5                	jne    8008d8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f3:	eb 05                	jmp    8008fa <strfind+0x10>
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 07                	je     800900 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f9:	40                   	inc    %eax
  8008fa:	8a 10                	mov    (%eax),%dl
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	75 f5                	jne    8008f5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 30                	je     800945 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 25                	jne    800942 <memset+0x40>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 20                	jne    800942 <memset+0x40>
		c &= 0xFF;
  800922:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800925:	89 d3                	mov    %edx,%ebx
  800927:	c1 e3 08             	shl    $0x8,%ebx
  80092a:	89 d6                	mov    %edx,%esi
  80092c:	c1 e6 18             	shl    $0x18,%esi
  80092f:	89 d0                	mov    %edx,%eax
  800931:	c1 e0 10             	shl    $0x10,%eax
  800934:	09 f0                	or     %esi,%eax
  800936:	09 d0                	or     %edx,%eax
  800938:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80093d:	fc                   	cld    
  80093e:	f3 ab                	rep stos %eax,%es:(%edi)
  800940:	eb 03                	jmp    800945 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800942:	fc                   	cld    
  800943:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800945:	89 f8                	mov    %edi,%eax
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095a:	39 c6                	cmp    %eax,%esi
  80095c:	73 34                	jae    800992 <memmove+0x46>
  80095e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800961:	39 d0                	cmp    %edx,%eax
  800963:	73 2d                	jae    800992 <memmove+0x46>
		s += n;
		d += n;
  800965:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	f6 c2 03             	test   $0x3,%dl
  80096b:	75 1b                	jne    800988 <memmove+0x3c>
  80096d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800973:	75 13                	jne    800988 <memmove+0x3c>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 0e                	jne    800988 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097a:	83 ef 04             	sub    $0x4,%edi
  80097d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800980:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800983:	fd                   	std    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 07                	jmp    80098f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800988:	4f                   	dec    %edi
  800989:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098c:	fd                   	std    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098f:	fc                   	cld    
  800990:	eb 20                	jmp    8009b2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	75 13                	jne    8009ad <memmove+0x61>
  80099a:	a8 03                	test   $0x3,%al
  80099c:	75 0f                	jne    8009ad <memmove+0x61>
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 0a                	jne    8009ad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a6:	89 c7                	mov    %eax,%edi
  8009a8:	fc                   	cld    
  8009a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ab:	eb 05                	jmp    8009b2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ad:	89 c7                	mov    %eax,%edi
  8009af:	fc                   	cld    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	89 04 24             	mov    %eax,(%esp)
  8009d0:	e8 77 ff ff ff       	call   80094c <memmove>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009eb:	eb 16                	jmp    800a03 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ed:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009f0:	42                   	inc    %edx
  8009f1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009f5:	38 c8                	cmp    %cl,%al
  8009f7:	74 0a                	je     800a03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 c9             	movzbl %cl,%ecx
  8009ff:	29 c8                	sub    %ecx,%eax
  800a01:	eb 09                	jmp    800a0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a03:	39 da                	cmp    %ebx,%edx
  800a05:	75 e6                	jne    8009ed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1f:	eb 05                	jmp    800a26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	38 08                	cmp    %cl,(%eax)
  800a23:	74 05                	je     800a2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a25:	40                   	inc    %eax
  800a26:	39 d0                	cmp    %edx,%eax
  800a28:	72 f7                	jb     800a21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 55 08             	mov    0x8(%ebp),%edx
  800a35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a38:	eb 01                	jmp    800a3b <strtol+0xf>
		s++;
  800a3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3b:	8a 02                	mov    (%edx),%al
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f9                	je     800a3a <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f5                	je     800a3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	75 08                	jne    800a51 <strtol+0x25>
		s++;
  800a49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4f:	eb 13                	jmp    800a64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a51:	3c 2d                	cmp    $0x2d,%al
  800a53:	75 0a                	jne    800a5f <strtol+0x33>
		s++, neg = 1;
  800a55:	8d 52 01             	lea    0x1(%edx),%edx
  800a58:	bf 01 00 00 00       	mov    $0x1,%edi
  800a5d:	eb 05                	jmp    800a64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	74 05                	je     800a6d <strtol+0x41>
  800a68:	83 fb 10             	cmp    $0x10,%ebx
  800a6b:	75 28                	jne    800a95 <strtol+0x69>
  800a6d:	8a 02                	mov    (%edx),%al
  800a6f:	3c 30                	cmp    $0x30,%al
  800a71:	75 10                	jne    800a83 <strtol+0x57>
  800a73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a77:	75 0a                	jne    800a83 <strtol+0x57>
		s += 2, base = 16;
  800a79:	83 c2 02             	add    $0x2,%edx
  800a7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a81:	eb 12                	jmp    800a95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a83:	85 db                	test   %ebx,%ebx
  800a85:	75 0e                	jne    800a95 <strtol+0x69>
  800a87:	3c 30                	cmp    $0x30,%al
  800a89:	75 05                	jne    800a90 <strtol+0x64>
		s++, base = 8;
  800a8b:	42                   	inc    %edx
  800a8c:	b3 08                	mov    $0x8,%bl
  800a8e:	eb 05                	jmp    800a95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9c:	8a 0a                	mov    (%edx),%cl
  800a9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aa1:	80 fb 09             	cmp    $0x9,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x82>
			dig = *s - '0';
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 30             	sub    $0x30,%ecx
  800aac:	eb 1e                	jmp    800acc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x92>
			dig = *s - 'a' + 10;
  800ab6:	0f be c9             	movsbl %cl,%ecx
  800ab9:	83 e9 57             	sub    $0x57,%ecx
  800abc:	eb 0e                	jmp    800acc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 12                	ja     800ad8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800acc:	39 f1                	cmp    %esi,%ecx
  800ace:	7d 0c                	jge    800adc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ad0:	42                   	inc    %edx
  800ad1:	0f af c6             	imul   %esi,%eax
  800ad4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ad6:	eb c4                	jmp    800a9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad8:	89 c1                	mov    %eax,%ecx
  800ada:	eb 02                	jmp    800ade <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800adc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ade:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae2:	74 05                	je     800ae9 <strtol+0xbd>
		*endptr = (char *) s;
  800ae4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	74 04                	je     800af1 <strtol+0xc5>
  800aed:	89 c8                	mov    %ecx,%eax
  800aef:	f7 d8                	neg    %eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    
	...

00800af8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	89 c3                	mov    %eax,%ebx
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 c6                	mov    %eax,%esi
  800b0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b43:	b8 03 00 00 00       	mov    $0x3,%eax
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	89 cb                	mov    %ecx,%ebx
  800b4d:	89 cf                	mov    %ecx,%edi
  800b4f:	89 ce                	mov    %ecx,%esi
  800b51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b53:	85 c0                	test   %eax,%eax
  800b55:	7e 28                	jle    800b7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b62:	00 
  800b63:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800b6a:	00 
  800b6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b72:	00 
  800b73:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800b7a:	e8 49 15 00 00       	call   8020c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7f:	83 c4 2c             	add    $0x2c,%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 02 00 00 00       	mov    $0x2,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_yield>:

void
sys_yield(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	be 00 00 00 00       	mov    $0x0,%esi
  800bd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 f7                	mov    %esi,%edi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 28                	jle    800c11 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bed:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bf4:	00 
  800bf5:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800bfc:	00 
  800bfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c04:	00 
  800c05:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800c0c:	e8 b7 14 00 00       	call   8020c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c11:	83 c4 2c             	add    $0x2c,%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	b8 05 00 00 00       	mov    $0x5,%eax
  800c27:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 28                	jle    800c64 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c40:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c47:	00 
  800c48:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800c4f:	00 
  800c50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c57:	00 
  800c58:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800c5f:	e8 64 14 00 00       	call   8020c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c64:	83 c4 2c             	add    $0x2c,%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 df                	mov    %ebx,%edi
  800c87:	89 de                	mov    %ebx,%esi
  800c89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 28                	jle    800cb7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c93:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c9a:	00 
  800c9b:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800caa:	00 
  800cab:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800cb2:	e8 11 14 00 00       	call   8020c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb7:	83 c4 2c             	add    $0x2c,%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 28                	jle    800d0a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ced:	00 
  800cee:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfd:	00 
  800cfe:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800d05:	e8 be 13 00 00       	call   8020c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0a:	83 c4 2c             	add    $0x2c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	b8 09 00 00 00       	mov    $0x9,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 28                	jle    800d5d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d39:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d40:	00 
  800d41:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800d48:	00 
  800d49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d50:	00 
  800d51:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800d58:	e8 6b 13 00 00       	call   8020c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5d:	83 c4 2c             	add    $0x2c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 28                	jle    800db0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d93:	00 
  800d94:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da3:	00 
  800da4:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800dab:	e8 18 13 00 00       	call   8020c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db0:	83 c4 2c             	add    $0x2c,%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	be 00 00 00 00       	mov    $0x0,%esi
  800dc3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dee:	8b 55 08             	mov    0x8(%ebp),%edx
  800df1:	89 cb                	mov    %ecx,%ebx
  800df3:	89 cf                	mov    %ecx,%edi
  800df5:	89 ce                	mov    %ecx,%esi
  800df7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 28                	jle    800e25 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e01:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e08:	00 
  800e09:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800e10:	00 
  800e11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e18:	00 
  800e19:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800e20:	e8 a3 12 00 00       	call   8020c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e25:	83 c4 2c             	add    $0x2c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
  800e2d:	00 00                	add    %al,(%eax)
	...

00800e30 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	53                   	push   %ebx
  800e34:	83 ec 24             	sub    $0x24,%esp
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e3a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800e3c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e40:	75 20                	jne    800e62 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e42:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e46:	c7 44 24 08 ec 27 80 	movl   $0x8027ec,0x8(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800e55:	00 
  800e56:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  800e5d:	e8 66 12 00 00       	call   8020c8 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e62:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e74:	f6 c4 08             	test   $0x8,%ah
  800e77:	75 1c                	jne    800e95 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e79:	c7 44 24 08 1c 28 80 	movl   $0x80281c,0x8(%esp)
  800e80:	00 
  800e81:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e88:	00 
  800e89:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  800e90:	e8 33 12 00 00       	call   8020c8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800e95:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eac:	e8 14 fd ff ff       	call   800bc5 <sys_page_alloc>
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	79 20                	jns    800ed5 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800eb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eb9:	c7 44 24 08 76 28 80 	movl   $0x802876,0x8(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ec8:	00 
  800ec9:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  800ed0:	e8 f3 11 00 00       	call   8020c8 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800ed5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800edc:	00 
  800edd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ee8:	e8 5f fa ff ff       	call   80094c <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800eed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ef4:	00 
  800ef5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ef9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f00:	00 
  800f01:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f08:	00 
  800f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f10:	e8 04 fd ff ff       	call   800c19 <sys_page_map>
  800f15:	85 c0                	test   %eax,%eax
  800f17:	79 20                	jns    800f39 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1d:	c7 44 24 08 89 28 80 	movl   $0x802889,0x8(%esp)
  800f24:	00 
  800f25:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f2c:	00 
  800f2d:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  800f34:	e8 8f 11 00 00       	call   8020c8 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800f39:	83 c4 24             	add    $0x24,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f48:	c7 04 24 30 0e 80 00 	movl   $0x800e30,(%esp)
  800f4f:	e8 cc 11 00 00       	call   802120 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f54:	ba 07 00 00 00       	mov    $0x7,%edx
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	cd 30                	int    $0x30
  800f5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f60:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 20                	jns    800f87 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6b:	c7 44 24 08 9a 28 80 	movl   $0x80289a,0x8(%esp)
  800f72:	00 
  800f73:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  800f82:	e8 41 11 00 00       	call   8020c8 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f87:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f8b:	75 25                	jne    800fb2 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f8d:	e8 f5 fb ff ff       	call   800b87 <sys_getenvid>
  800f92:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f9e:	c1 e0 07             	shl    $0x7,%eax
  800fa1:	29 d0                	sub    %edx,%eax
  800fa3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fad:	e9 58 02 00 00       	jmp    80120a <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800fb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb7:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fbc:	89 f0                	mov    %esi,%eax
  800fbe:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fc1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc8:	a8 01                	test   $0x1,%al
  800fca:	0f 84 7a 01 00 00    	je     80114a <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800fd0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fd7:	a8 01                	test   $0x1,%al
  800fd9:	0f 84 6b 01 00 00    	je     80114a <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800fdf:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe4:	8b 40 48             	mov    0x48(%eax),%eax
  800fe7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800fea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff1:	f6 c4 04             	test   $0x4,%ah
  800ff4:	74 52                	je     801048 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800ff6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffd:	25 07 0e 00 00       	and    $0xe07,%eax
  801002:	89 44 24 10          	mov    %eax,0x10(%esp)
  801006:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80100a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801011:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801015:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801018:	89 04 24             	mov    %eax,(%esp)
  80101b:	e8 f9 fb ff ff       	call   800c19 <sys_page_map>
  801020:	85 c0                	test   %eax,%eax
  801022:	0f 89 22 01 00 00    	jns    80114a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801028:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80102c:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  801043:	e8 80 10 00 00       	call   8020c8 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801048:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104f:	f6 c4 08             	test   $0x8,%ah
  801052:	75 0f                	jne    801063 <fork+0x124>
  801054:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105b:	a8 02                	test   $0x2,%al
  80105d:	0f 84 99 00 00 00    	je     8010fc <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801063:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80106a:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  80106d:	83 f8 01             	cmp    $0x1,%eax
  801070:	19 db                	sbb    %ebx,%ebx
  801072:	83 e3 fc             	and    $0xfffffffc,%ebx
  801075:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80107b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80107f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801083:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801086:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80108e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801091:	89 04 24             	mov    %eax,(%esp)
  801094:	e8 80 fb ff ff       	call   800c19 <sys_page_map>
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 20                	jns    8010bd <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  80109d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a1:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  8010b8:	e8 0b 10 00 00       	call   8020c8 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010c1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010d0:	89 04 24             	mov    %eax,(%esp)
  8010d3:	e8 41 fb ff ff       	call   800c19 <sys_page_map>
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	79 6e                	jns    80114a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e0:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  8010e7:	00 
  8010e8:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8010ef:	00 
  8010f0:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  8010f7:	e8 cc 0f 00 00       	call   8020c8 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010fc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801103:	25 07 0e 00 00       	and    $0xe07,%eax
  801108:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801110:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801113:	89 44 24 08          	mov    %eax,0x8(%esp)
  801117:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80111b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111e:	89 04 24             	mov    %eax,(%esp)
  801121:	e8 f3 fa ff ff       	call   800c19 <sys_page_map>
  801126:	85 c0                	test   %eax,%eax
  801128:	79 20                	jns    80114a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80112a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112e:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  801135:	00 
  801136:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  80113d:	00 
  80113e:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  801145:	e8 7e 0f 00 00       	call   8020c8 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  80114a:	46                   	inc    %esi
  80114b:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801151:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801157:	0f 85 5f fe ff ff    	jne    800fbc <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  80115d:	c7 44 24 04 c0 21 80 	movl   $0x8021c0,0x4(%esp)
  801164:	00 
  801165:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801168:	89 04 24             	mov    %eax,(%esp)
  80116b:	e8 f5 fb ff ff       	call   800d65 <sys_env_set_pgfault_upcall>
  801170:	85 c0                	test   %eax,%eax
  801172:	79 20                	jns    801194 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801174:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801178:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  80117f:	00 
  801180:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801187:	00 
  801188:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  80118f:	e8 34 0f 00 00       	call   8020c8 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801194:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011a3:	ee 
  8011a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a7:	89 04 24             	mov    %eax,(%esp)
  8011aa:	e8 16 fa ff ff       	call   800bc5 <sys_page_alloc>
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	79 20                	jns    8011d3 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8011b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b7:	c7 44 24 08 76 28 80 	movl   $0x802876,0x8(%esp)
  8011be:	00 
  8011bf:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8011c6:	00 
  8011c7:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  8011ce:	e8 f5 0e 00 00       	call   8020c8 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011d3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011da:	00 
  8011db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	e8 d9 fa ff ff       	call   800cbf <sys_env_set_status>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	79 20                	jns    80120a <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  8011ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ee:	c7 44 24 08 bc 28 80 	movl   $0x8028bc,0x8(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011fd:	00 
  8011fe:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  801205:	e8 be 0e 00 00       	call   8020c8 <_panic>
	}
	
	return envid;
}
  80120a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120d:	83 c4 3c             	add    $0x3c,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sfork>:

// Challenge!
int
sfork(void)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80121b:	c7 44 24 08 d3 28 80 	movl   $0x8028d3,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  801232:	e8 91 0e 00 00       	call   8020c8 <_panic>
	...

00801238 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 10             	sub    $0x10,%esp
  801240:	8b 75 08             	mov    0x8(%ebp),%esi
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
  801246:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801249:	85 c0                	test   %eax,%eax
  80124b:	75 05                	jne    801252 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  80124d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801252:	89 04 24             	mov    %eax,(%esp)
  801255:	e8 81 fb ff ff       	call   800ddb <sys_ipc_recv>
	if (!err) {
  80125a:	85 c0                	test   %eax,%eax
  80125c:	75 26                	jne    801284 <ipc_recv+0x4c>
		if (from_env_store) {
  80125e:	85 f6                	test   %esi,%esi
  801260:	74 0a                	je     80126c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801262:	a1 04 40 80 00       	mov    0x804004,%eax
  801267:	8b 40 74             	mov    0x74(%eax),%eax
  80126a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80126c:	85 db                	test   %ebx,%ebx
  80126e:	74 0a                	je     80127a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801270:	a1 04 40 80 00       	mov    0x804004,%eax
  801275:	8b 40 78             	mov    0x78(%eax),%eax
  801278:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80127a:	a1 04 40 80 00       	mov    0x804004,%eax
  80127f:	8b 40 70             	mov    0x70(%eax),%eax
  801282:	eb 14                	jmp    801298 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801284:	85 f6                	test   %esi,%esi
  801286:	74 06                	je     80128e <ipc_recv+0x56>
		*from_env_store = 0;
  801288:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  80128e:	85 db                	test   %ebx,%ebx
  801290:	74 06                	je     801298 <ipc_recv+0x60>
		*perm_store = 0;
  801292:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 1c             	sub    $0x1c,%esp
  8012a8:	8b 75 10             	mov    0x10(%ebp),%esi
  8012ab:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8012ae:	85 f6                	test   %esi,%esi
  8012b0:	75 05                	jne    8012b7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8012b2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8012b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bb:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	89 04 24             	mov    %eax,(%esp)
  8012cc:	e8 e7 fa ff ff       	call   800db8 <sys_ipc_try_send>
  8012d1:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8012d3:	e8 ce f8 ff ff       	call   800ba6 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8012d8:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8012db:	74 da                	je     8012b7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8012dd:	85 db                	test   %ebx,%ebx
  8012df:	74 20                	je     801301 <ipc_send+0x62>
		panic("send fail: %e", err);
  8012e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012e5:	c7 44 24 08 e9 28 80 	movl   $0x8028e9,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 f7 28 80 00 	movl   $0x8028f7,(%esp)
  8012fc:	e8 c7 0d 00 00       	call   8020c8 <_panic>
	}
	return;
}
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801315:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	c1 e2 07             	shl    $0x7,%edx
  801321:	29 ca                	sub    %ecx,%edx
  801323:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801329:	8b 52 50             	mov    0x50(%edx),%edx
  80132c:	39 da                	cmp    %ebx,%edx
  80132e:	75 0f                	jne    80133f <ipc_find_env+0x36>
			return envs[i].env_id;
  801330:	c1 e0 07             	shl    $0x7,%eax
  801333:	29 c8                	sub    %ecx,%eax
  801335:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80133a:	8b 40 40             	mov    0x40(%eax),%eax
  80133d:	eb 0c                	jmp    80134b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80133f:	40                   	inc    %eax
  801340:	3d 00 04 00 00       	cmp    $0x400,%eax
  801345:	75 ce                	jne    801315 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801347:	66 b8 00 00          	mov    $0x0,%ax
}
  80134b:	5b                   	pop    %ebx
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    
	...

00801350 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	05 00 00 00 30       	add    $0x30000000,%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
}
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	89 04 24             	mov    %eax,(%esp)
  80136c:	e8 df ff ff ff       	call   801350 <fd2num>
  801371:	05 20 00 0d 00       	add    $0xd0020,%eax
  801376:	c1 e0 0c             	shl    $0xc,%eax
}
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	53                   	push   %ebx
  80137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801382:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801387:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801389:	89 c2                	mov    %eax,%edx
  80138b:	c1 ea 16             	shr    $0x16,%edx
  80138e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801395:	f6 c2 01             	test   $0x1,%dl
  801398:	74 11                	je     8013ab <fd_alloc+0x30>
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	c1 ea 0c             	shr    $0xc,%edx
  80139f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a6:	f6 c2 01             	test   $0x1,%dl
  8013a9:	75 09                	jne    8013b4 <fd_alloc+0x39>
			*fd_store = fd;
  8013ab:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b2:	eb 17                	jmp    8013cb <fd_alloc+0x50>
  8013b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013be:	75 c7                	jne    801387 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013cb:	5b                   	pop    %ebx
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d4:	83 f8 1f             	cmp    $0x1f,%eax
  8013d7:	77 36                	ja     80140f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013de:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	c1 ea 16             	shr    $0x16,%edx
  8013e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ed:	f6 c2 01             	test   $0x1,%dl
  8013f0:	74 24                	je     801416 <fd_lookup+0x48>
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	c1 ea 0c             	shr    $0xc,%edx
  8013f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	74 1a                	je     80141d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801403:	8b 55 0c             	mov    0xc(%ebp),%edx
  801406:	89 02                	mov    %eax,(%edx)
	return 0;
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
  80140d:	eb 13                	jmp    801422 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801414:	eb 0c                	jmp    801422 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801416:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141b:	eb 05                	jmp    801422 <fd_lookup+0x54>
  80141d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	53                   	push   %ebx
  801428:	83 ec 14             	sub    $0x14,%esp
  80142b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	eb 0e                	jmp    801446 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801438:	39 08                	cmp    %ecx,(%eax)
  80143a:	75 09                	jne    801445 <dev_lookup+0x21>
			*dev = devtab[i];
  80143c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
  801443:	eb 33                	jmp    801478 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801445:	42                   	inc    %edx
  801446:	8b 04 95 80 29 80 00 	mov    0x802980(,%edx,4),%eax
  80144d:	85 c0                	test   %eax,%eax
  80144f:	75 e7                	jne    801438 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801451:	a1 04 40 80 00       	mov    0x804004,%eax
  801456:	8b 40 48             	mov    0x48(%eax),%eax
  801459:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801461:	c7 04 24 04 29 80 00 	movl   $0x802904,(%esp)
  801468:	e8 9b ed ff ff       	call   800208 <cprintf>
	*dev = 0;
  80146d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801478:	83 c4 14             	add    $0x14,%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    

0080147e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
  801483:	83 ec 30             	sub    $0x30,%esp
  801486:	8b 75 08             	mov    0x8(%ebp),%esi
  801489:	8a 45 0c             	mov    0xc(%ebp),%al
  80148c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148f:	89 34 24             	mov    %esi,(%esp)
  801492:	e8 b9 fe ff ff       	call   801350 <fd2num>
  801497:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80149a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80149e:	89 04 24             	mov    %eax,(%esp)
  8014a1:	e8 28 ff ff ff       	call   8013ce <fd_lookup>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 05                	js     8014b1 <fd_close+0x33>
	    || fd != fd2)
  8014ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014af:	74 0d                	je     8014be <fd_close+0x40>
		return (must_exist ? r : 0);
  8014b1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014b5:	75 46                	jne    8014fd <fd_close+0x7f>
  8014b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bc:	eb 3f                	jmp    8014fd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c5:	8b 06                	mov    (%esi),%eax
  8014c7:	89 04 24             	mov    %eax,(%esp)
  8014ca:	e8 55 ff ff ff       	call   801424 <dev_lookup>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 18                	js     8014ed <fd_close+0x6f>
		if (dev->dev_close)
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	8b 40 10             	mov    0x10(%eax),%eax
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	74 09                	je     8014e8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014df:	89 34 24             	mov    %esi,(%esp)
  8014e2:	ff d0                	call   *%eax
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	eb 05                	jmp    8014ed <fd_close+0x6f>
		else
			r = 0;
  8014e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f8:	e8 6f f7 ff ff       	call   800c6c <sys_page_unmap>
	return r;
}
  8014fd:	89 d8                	mov    %ebx,%eax
  8014ff:	83 c4 30             	add    $0x30,%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	89 04 24             	mov    %eax,(%esp)
  801519:	e8 b0 fe ff ff       	call   8013ce <fd_lookup>
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 13                	js     801535 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801522:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801529:	00 
  80152a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152d:	89 04 24             	mov    %eax,(%esp)
  801530:	e8 49 ff ff ff       	call   80147e <fd_close>
}
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <close_all>:

void
close_all(void)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	53                   	push   %ebx
  80153b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80153e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801543:	89 1c 24             	mov    %ebx,(%esp)
  801546:	e8 bb ff ff ff       	call   801506 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80154b:	43                   	inc    %ebx
  80154c:	83 fb 20             	cmp    $0x20,%ebx
  80154f:	75 f2                	jne    801543 <close_all+0xc>
		close(i);
}
  801551:	83 c4 14             	add    $0x14,%esp
  801554:	5b                   	pop    %ebx
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 4c             	sub    $0x4c,%esp
  801560:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801563:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	89 04 24             	mov    %eax,(%esp)
  801570:	e8 59 fe ff ff       	call   8013ce <fd_lookup>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	85 c0                	test   %eax,%eax
  801579:	0f 88 e1 00 00 00    	js     801660 <dup+0x109>
		return r;
	close(newfdnum);
  80157f:	89 3c 24             	mov    %edi,(%esp)
  801582:	e8 7f ff ff ff       	call   801506 <close>

	newfd = INDEX2FD(newfdnum);
  801587:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80158d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801593:	89 04 24             	mov    %eax,(%esp)
  801596:	e8 c5 fd ff ff       	call   801360 <fd2data>
  80159b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80159d:	89 34 24             	mov    %esi,(%esp)
  8015a0:	e8 bb fd ff ff       	call   801360 <fd2data>
  8015a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	c1 e8 16             	shr    $0x16,%eax
  8015ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b4:	a8 01                	test   $0x1,%al
  8015b6:	74 46                	je     8015fe <dup+0xa7>
  8015b8:	89 d8                	mov    %ebx,%eax
  8015ba:	c1 e8 0c             	shr    $0xc,%eax
  8015bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c4:	f6 c2 01             	test   $0x1,%dl
  8015c7:	74 35                	je     8015fe <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e7:	00 
  8015e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f3:	e8 21 f6 ff ff       	call   800c19 <sys_page_map>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 3b                	js     801639 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801601:	89 c2                	mov    %eax,%edx
  801603:	c1 ea 0c             	shr    $0xc,%edx
  801606:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80160d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801613:	89 54 24 10          	mov    %edx,0x10(%esp)
  801617:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80161b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801622:	00 
  801623:	89 44 24 04          	mov    %eax,0x4(%esp)
  801627:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162e:	e8 e6 f5 ff ff       	call   800c19 <sys_page_map>
  801633:	89 c3                	mov    %eax,%ebx
  801635:	85 c0                	test   %eax,%eax
  801637:	79 25                	jns    80165e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801644:	e8 23 f6 ff ff       	call   800c6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801649:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80164c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801657:	e8 10 f6 ff ff       	call   800c6c <sys_page_unmap>
	return r;
  80165c:	eb 02                	jmp    801660 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80165e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801660:	89 d8                	mov    %ebx,%eax
  801662:	83 c4 4c             	add    $0x4c,%esp
  801665:	5b                   	pop    %ebx
  801666:	5e                   	pop    %esi
  801667:	5f                   	pop    %edi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 24             	sub    $0x24,%esp
  801671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167b:	89 1c 24             	mov    %ebx,(%esp)
  80167e:	e8 4b fd ff ff       	call   8013ce <fd_lookup>
  801683:	85 c0                	test   %eax,%eax
  801685:	78 6d                	js     8016f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801687:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801691:	8b 00                	mov    (%eax),%eax
  801693:	89 04 24             	mov    %eax,(%esp)
  801696:	e8 89 fd ff ff       	call   801424 <dev_lookup>
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 55                	js     8016f4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a2:	8b 50 08             	mov    0x8(%eax),%edx
  8016a5:	83 e2 03             	and    $0x3,%edx
  8016a8:	83 fa 01             	cmp    $0x1,%edx
  8016ab:	75 23                	jne    8016d0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b2:	8b 40 48             	mov    0x48(%eax),%eax
  8016b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bd:	c7 04 24 45 29 80 00 	movl   $0x802945,(%esp)
  8016c4:	e8 3f eb ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8016c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ce:	eb 24                	jmp    8016f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d3:	8b 52 08             	mov    0x8(%edx),%edx
  8016d6:	85 d2                	test   %edx,%edx
  8016d8:	74 15                	je     8016ef <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016e8:	89 04 24             	mov    %eax,(%esp)
  8016eb:	ff d2                	call   *%edx
  8016ed:	eb 05                	jmp    8016f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016f4:	83 c4 24             	add    $0x24,%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 1c             	sub    $0x1c,%esp
  801703:	8b 7d 08             	mov    0x8(%ebp),%edi
  801706:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801709:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170e:	eb 23                	jmp    801733 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801710:	89 f0                	mov    %esi,%eax
  801712:	29 d8                	sub    %ebx,%eax
  801714:	89 44 24 08          	mov    %eax,0x8(%esp)
  801718:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171b:	01 d8                	add    %ebx,%eax
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	89 3c 24             	mov    %edi,(%esp)
  801724:	e8 41 ff ff ff       	call   80166a <read>
		if (m < 0)
  801729:	85 c0                	test   %eax,%eax
  80172b:	78 10                	js     80173d <readn+0x43>
			return m;
		if (m == 0)
  80172d:	85 c0                	test   %eax,%eax
  80172f:	74 0a                	je     80173b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801731:	01 c3                	add    %eax,%ebx
  801733:	39 f3                	cmp    %esi,%ebx
  801735:	72 d9                	jb     801710 <readn+0x16>
  801737:	89 d8                	mov    %ebx,%eax
  801739:	eb 02                	jmp    80173d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80173b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80173d:	83 c4 1c             	add    $0x1c,%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 24             	sub    $0x24,%esp
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	89 1c 24             	mov    %ebx,(%esp)
  801759:	e8 70 fc ff ff       	call   8013ce <fd_lookup>
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 68                	js     8017ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176c:	8b 00                	mov    (%eax),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 ae fc ff ff       	call   801424 <dev_lookup>
  801776:	85 c0                	test   %eax,%eax
  801778:	78 50                	js     8017ca <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801781:	75 23                	jne    8017a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801783:	a1 04 40 80 00       	mov    0x804004,%eax
  801788:	8b 40 48             	mov    0x48(%eax),%eax
  80178b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	c7 04 24 61 29 80 00 	movl   $0x802961,(%esp)
  80179a:	e8 69 ea ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  80179f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a4:	eb 24                	jmp    8017ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ac:	85 d2                	test   %edx,%edx
  8017ae:	74 15                	je     8017c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	ff d2                	call   *%edx
  8017c3:	eb 05                	jmp    8017ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017ca:	83 c4 24             	add    $0x24,%esp
  8017cd:	5b                   	pop    %ebx
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 e6 fb ff ff       	call   8013ce <fd_lookup>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 0e                	js     8017fa <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	53                   	push   %ebx
  801800:	83 ec 24             	sub    $0x24,%esp
  801803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801806:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	89 1c 24             	mov    %ebx,(%esp)
  801810:	e8 b9 fb ff ff       	call   8013ce <fd_lookup>
  801815:	85 c0                	test   %eax,%eax
  801817:	78 61                	js     80187a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801823:	8b 00                	mov    (%eax),%eax
  801825:	89 04 24             	mov    %eax,(%esp)
  801828:	e8 f7 fb ff ff       	call   801424 <dev_lookup>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 49                	js     80187a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801834:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801838:	75 23                	jne    80185d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80183a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80183f:	8b 40 48             	mov    0x48(%eax),%eax
  801842:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184a:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  801851:	e8 b2 e9 ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185b:	eb 1d                	jmp    80187a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80185d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801860:	8b 52 18             	mov    0x18(%edx),%edx
  801863:	85 d2                	test   %edx,%edx
  801865:	74 0e                	je     801875 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	ff d2                	call   *%edx
  801873:	eb 05                	jmp    80187a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801875:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80187a:	83 c4 24             	add    $0x24,%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 24             	sub    $0x24,%esp
  801887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	8b 45 08             	mov    0x8(%ebp),%eax
  801894:	89 04 24             	mov    %eax,(%esp)
  801897:	e8 32 fb ff ff       	call   8013ce <fd_lookup>
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 52                	js     8018f2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018aa:	8b 00                	mov    (%eax),%eax
  8018ac:	89 04 24             	mov    %eax,(%esp)
  8018af:	e8 70 fb ff ff       	call   801424 <dev_lookup>
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 3a                	js     8018f2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018bf:	74 2c                	je     8018ed <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018cb:	00 00 00 
	stat->st_isdir = 0;
  8018ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d5:	00 00 00 
	stat->st_dev = dev;
  8018d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e5:	89 14 24             	mov    %edx,(%esp)
  8018e8:	ff 50 14             	call   *0x14(%eax)
  8018eb:	eb 05                	jmp    8018f2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018f2:	83 c4 24             	add    $0x24,%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801900:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801907:	00 
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	89 04 24             	mov    %eax,(%esp)
  80190e:	e8 fe 01 00 00       	call   801b11 <open>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	85 c0                	test   %eax,%eax
  801917:	78 1b                	js     801934 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801920:	89 1c 24             	mov    %ebx,(%esp)
  801923:	e8 58 ff ff ff       	call   801880 <fstat>
  801928:	89 c6                	mov    %eax,%esi
	close(fd);
  80192a:	89 1c 24             	mov    %ebx,(%esp)
  80192d:	e8 d4 fb ff ff       	call   801506 <close>
	return r;
  801932:	89 f3                	mov    %esi,%ebx
}
  801934:	89 d8                	mov    %ebx,%eax
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    
  80193d:	00 00                	add    %al,(%eax)
	...

00801940 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 10             	sub    $0x10,%esp
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80194c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801953:	75 11                	jne    801966 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801955:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80195c:	e8 a8 f9 ff ff       	call   801309 <ipc_find_env>
  801961:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801966:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80196d:	00 
  80196e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801975:	00 
  801976:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197a:	a1 00 40 80 00       	mov    0x804000,%eax
  80197f:	89 04 24             	mov    %eax,(%esp)
  801982:	e8 18 f9 ff ff       	call   80129f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801987:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80198e:	00 
  80198f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199a:	e8 99 f8 ff ff       	call   801238 <ipc_recv>
}
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c9:	e8 72 ff ff ff       	call   801940 <fsipc>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8019eb:	e8 50 ff ff ff       	call   801940 <fsipc>
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 14             	sub    $0x14,%esp
  8019f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801a02:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a07:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a11:	e8 2a ff ff ff       	call   801940 <fsipc>
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 2b                	js     801a45 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a1a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a21:	00 
  801a22:	89 1c 24             	mov    %ebx,(%esp)
  801a25:	e8 a9 ed ff ff       	call   8007d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a2a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a35:	a1 84 50 80 00       	mov    0x805084,%eax
  801a3a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a45:	83 c4 14             	add    $0x14,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a51:	c7 44 24 08 90 29 80 	movl   $0x802990,0x8(%esp)
  801a58:	00 
  801a59:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a60:	00 
  801a61:	c7 04 24 ae 29 80 00 	movl   $0x8029ae,(%esp)
  801a68:	e8 5b 06 00 00       	call   8020c8 <_panic>

00801a6d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 10             	sub    $0x10,%esp
  801a75:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a83:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a89:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a93:	e8 a8 fe ff ff       	call   801940 <fsipc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	78 6a                	js     801b08 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a9e:	39 c6                	cmp    %eax,%esi
  801aa0:	73 24                	jae    801ac6 <devfile_read+0x59>
  801aa2:	c7 44 24 0c b9 29 80 	movl   $0x8029b9,0xc(%esp)
  801aa9:	00 
  801aaa:	c7 44 24 08 c0 29 80 	movl   $0x8029c0,0x8(%esp)
  801ab1:	00 
  801ab2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ab9:	00 
  801aba:	c7 04 24 ae 29 80 00 	movl   $0x8029ae,(%esp)
  801ac1:	e8 02 06 00 00       	call   8020c8 <_panic>
	assert(r <= PGSIZE);
  801ac6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801acb:	7e 24                	jle    801af1 <devfile_read+0x84>
  801acd:	c7 44 24 0c d5 29 80 	movl   $0x8029d5,0xc(%esp)
  801ad4:	00 
  801ad5:	c7 44 24 08 c0 29 80 	movl   $0x8029c0,0x8(%esp)
  801adc:	00 
  801add:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ae4:	00 
  801ae5:	c7 04 24 ae 29 80 00 	movl   $0x8029ae,(%esp)
  801aec:	e8 d7 05 00 00       	call   8020c8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801af1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801afc:	00 
  801afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b00:	89 04 24             	mov    %eax,(%esp)
  801b03:	e8 44 ee ff ff       	call   80094c <memmove>
	return r;
}
  801b08:	89 d8                	mov    %ebx,%eax
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	83 ec 20             	sub    $0x20,%esp
  801b19:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b1c:	89 34 24             	mov    %esi,(%esp)
  801b1f:	e8 7c ec ff ff       	call   8007a0 <strlen>
  801b24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b29:	7f 60                	jg     801b8b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 45 f8 ff ff       	call   80137b <fd_alloc>
  801b36:	89 c3                	mov    %eax,%ebx
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 54                	js     801b90 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b40:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b47:	e8 87 ec ff ff       	call   8007d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b57:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5c:	e8 df fd ff ff       	call   801940 <fsipc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	79 15                	jns    801b7c <open+0x6b>
		fd_close(fd, 0);
  801b67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b6e:	00 
  801b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 04 f9 ff ff       	call   80147e <fd_close>
		return r;
  801b7a:	eb 14                	jmp    801b90 <open+0x7f>
	}

	return fd2num(fd);
  801b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7f:	89 04 24             	mov    %eax,(%esp)
  801b82:	e8 c9 f7 ff ff       	call   801350 <fd2num>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	eb 05                	jmp    801b90 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b8b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b90:	89 d8                	mov    %ebx,%eax
  801b92:	83 c4 20             	add    $0x20,%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ba9:	e8 92 fd ff ff       	call   801940 <fsipc>
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 10             	sub    $0x10,%esp
  801bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	89 04 24             	mov    %eax,(%esp)
  801bc1:	e8 9a f7 ff ff       	call   801360 <fd2data>
  801bc6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bc8:	c7 44 24 04 e1 29 80 	movl   $0x8029e1,0x4(%esp)
  801bcf:	00 
  801bd0:	89 34 24             	mov    %esi,(%esp)
  801bd3:	e8 fb eb ff ff       	call   8007d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bdb:	2b 03                	sub    (%ebx),%eax
  801bdd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801be3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bea:	00 00 00 
	stat->st_dev = &devpipe;
  801bed:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bf4:	30 80 00 
	return 0;
}
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	53                   	push   %ebx
  801c07:	83 ec 14             	sub    $0x14,%esp
  801c0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c18:	e8 4f f0 ff ff       	call   800c6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c1d:	89 1c 24             	mov    %ebx,(%esp)
  801c20:	e8 3b f7 ff ff       	call   801360 <fd2data>
  801c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c30:	e8 37 f0 ff ff       	call   800c6c <sys_page_unmap>
}
  801c35:	83 c4 14             	add    $0x14,%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 2c             	sub    $0x2c,%esp
  801c44:	89 c7                	mov    %eax,%edi
  801c46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c49:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c51:	89 3c 24             	mov    %edi,(%esp)
  801c54:	e8 8b 05 00 00       	call   8021e4 <pageref>
  801c59:	89 c6                	mov    %eax,%esi
  801c5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5e:	89 04 24             	mov    %eax,(%esp)
  801c61:	e8 7e 05 00 00       	call   8021e4 <pageref>
  801c66:	39 c6                	cmp    %eax,%esi
  801c68:	0f 94 c0             	sete   %al
  801c6b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c6e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c74:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c77:	39 cb                	cmp    %ecx,%ebx
  801c79:	75 08                	jne    801c83 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c7b:	83 c4 2c             	add    $0x2c,%esp
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5f                   	pop    %edi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c83:	83 f8 01             	cmp    $0x1,%eax
  801c86:	75 c1                	jne    801c49 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c88:	8b 42 58             	mov    0x58(%edx),%eax
  801c8b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c92:	00 
  801c93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c9b:	c7 04 24 e8 29 80 00 	movl   $0x8029e8,(%esp)
  801ca2:	e8 61 e5 ff ff       	call   800208 <cprintf>
  801ca7:	eb a0                	jmp    801c49 <_pipeisclosed+0xe>

00801ca9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 1c             	sub    $0x1c,%esp
  801cb2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cb5:	89 34 24             	mov    %esi,(%esp)
  801cb8:	e8 a3 f6 ff ff       	call   801360 <fd2data>
  801cbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbf:	bf 00 00 00 00       	mov    $0x0,%edi
  801cc4:	eb 3c                	jmp    801d02 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cc6:	89 da                	mov    %ebx,%edx
  801cc8:	89 f0                	mov    %esi,%eax
  801cca:	e8 6c ff ff ff       	call   801c3b <_pipeisclosed>
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	75 38                	jne    801d0b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cd3:	e8 ce ee ff ff       	call   800ba6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd8:	8b 43 04             	mov    0x4(%ebx),%eax
  801cdb:	8b 13                	mov    (%ebx),%edx
  801cdd:	83 c2 20             	add    $0x20,%edx
  801ce0:	39 d0                	cmp    %edx,%eax
  801ce2:	73 e2                	jae    801cc6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ce4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cf2:	79 05                	jns    801cf9 <devpipe_write+0x50>
  801cf4:	4a                   	dec    %edx
  801cf5:	83 ca e0             	or     $0xffffffe0,%edx
  801cf8:	42                   	inc    %edx
  801cf9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cfd:	40                   	inc    %eax
  801cfe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d01:	47                   	inc    %edi
  801d02:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d05:	75 d1                	jne    801cd8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d07:	89 f8                	mov    %edi,%eax
  801d09:	eb 05                	jmp    801d10 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    

00801d18 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 1c             	sub    $0x1c,%esp
  801d21:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d24:	89 3c 24             	mov    %edi,(%esp)
  801d27:	e8 34 f6 ff ff       	call   801360 <fd2data>
  801d2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2e:	be 00 00 00 00       	mov    $0x0,%esi
  801d33:	eb 3a                	jmp    801d6f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d35:	85 f6                	test   %esi,%esi
  801d37:	74 04                	je     801d3d <devpipe_read+0x25>
				return i;
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	eb 40                	jmp    801d7d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d3d:	89 da                	mov    %ebx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	e8 f5 fe ff ff       	call   801c3b <_pipeisclosed>
  801d46:	85 c0                	test   %eax,%eax
  801d48:	75 2e                	jne    801d78 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d4a:	e8 57 ee ff ff       	call   800ba6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d4f:	8b 03                	mov    (%ebx),%eax
  801d51:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d54:	74 df                	je     801d35 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d56:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d5b:	79 05                	jns    801d62 <devpipe_read+0x4a>
  801d5d:	48                   	dec    %eax
  801d5e:	83 c8 e0             	or     $0xffffffe0,%eax
  801d61:	40                   	inc    %eax
  801d62:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d69:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d6c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6e:	46                   	inc    %esi
  801d6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d72:	75 db                	jne    801d4f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d74:	89 f0                	mov    %esi,%eax
  801d76:	eb 05                	jmp    801d7d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d7d:	83 c4 1c             	add    $0x1c,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	57                   	push   %edi
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 3c             	sub    $0x3c,%esp
  801d8e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d91:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d94:	89 04 24             	mov    %eax,(%esp)
  801d97:	e8 df f5 ff ff       	call   80137b <fd_alloc>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	0f 88 45 01 00 00    	js     801eeb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dad:	00 
  801dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbc:	e8 04 ee ff ff       	call   800bc5 <sys_page_alloc>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	0f 88 20 01 00 00    	js     801eeb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dcb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dce:	89 04 24             	mov    %eax,(%esp)
  801dd1:	e8 a5 f5 ff ff       	call   80137b <fd_alloc>
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	0f 88 f8 00 00 00    	js     801ed8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de7:	00 
  801de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801def:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df6:	e8 ca ed ff ff       	call   800bc5 <sys_page_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	0f 88 d3 00 00 00    	js     801ed8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 50 f5 ff ff       	call   801360 <fd2data>
  801e10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e19:	00 
  801e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e25:	e8 9b ed ff ff       	call   800bc5 <sys_page_alloc>
  801e2a:	89 c3                	mov    %eax,%ebx
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 91 00 00 00    	js     801ec5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e37:	89 04 24             	mov    %eax,(%esp)
  801e3a:	e8 21 f5 ff ff       	call   801360 <fd2data>
  801e3f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e46:	00 
  801e47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e52:	00 
  801e53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5e:	e8 b6 ed ff ff       	call   800c19 <sys_page_map>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 4c                	js     801eb5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e72:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e87:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e8c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 b2 f4 ff ff       	call   801350 <fd2num>
  801e9e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 a5 f4 ff ff       	call   801350 <fd2num>
  801eab:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801eae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb3:	eb 36                	jmp    801eeb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801eb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec0:	e8 a7 ed ff ff       	call   800c6c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed3:	e8 94 ed ff ff       	call   800c6c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee6:	e8 81 ed ff ff       	call   800c6c <sys_page_unmap>
    err:
	return r;
}
  801eeb:	89 d8                	mov    %ebx,%eax
  801eed:	83 c4 3c             	add    $0x3c,%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	89 04 24             	mov    %eax,(%esp)
  801f08:	e8 c1 f4 ff ff       	call   8013ce <fd_lookup>
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 15                	js     801f26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	89 04 24             	mov    %eax,(%esp)
  801f17:	e8 44 f4 ff ff       	call   801360 <fd2data>
	return _pipeisclosed(fd, p);
  801f1c:	89 c2                	mov    %eax,%edx
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	e8 15 fd ff ff       	call   801c3b <_pipeisclosed>
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f38:	c7 44 24 04 00 2a 80 	movl   $0x802a00,0x4(%esp)
  801f3f:	00 
  801f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 88 e8 ff ff       	call   8007d3 <strcpy>
	return 0;
}
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f69:	eb 30                	jmp    801f9b <devcons_write+0x49>
		m = n - tot;
  801f6b:	8b 75 10             	mov    0x10(%ebp),%esi
  801f6e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f70:	83 fe 7f             	cmp    $0x7f,%esi
  801f73:	76 05                	jbe    801f7a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f75:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f7a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f7e:	03 45 0c             	add    0xc(%ebp),%eax
  801f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f85:	89 3c 24             	mov    %edi,(%esp)
  801f88:	e8 bf e9 ff ff       	call   80094c <memmove>
		sys_cputs(buf, m);
  801f8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f91:	89 3c 24             	mov    %edi,(%esp)
  801f94:	e8 5f eb ff ff       	call   800af8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f99:	01 f3                	add    %esi,%ebx
  801f9b:	89 d8                	mov    %ebx,%eax
  801f9d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fa0:	72 c9                	jb     801f6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fa2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fa8:	5b                   	pop    %ebx
  801fa9:	5e                   	pop    %esi
  801faa:	5f                   	pop    %edi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb7:	75 07                	jne    801fc0 <devcons_read+0x13>
  801fb9:	eb 25                	jmp    801fe0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fbb:	e8 e6 eb ff ff       	call   800ba6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fc0:	e8 51 eb ff ff       	call   800b16 <sys_cgetc>
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	74 f2                	je     801fbb <devcons_read+0xe>
  801fc9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	78 1d                	js     801fec <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fcf:	83 f8 04             	cmp    $0x4,%eax
  801fd2:	74 13                	je     801fe7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd7:	88 10                	mov    %dl,(%eax)
	return 1;
  801fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fde:	eb 0c                	jmp    801fec <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe5:	eb 05                	jmp    801fec <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fe7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ffa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802001:	00 
  802002:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802005:	89 04 24             	mov    %eax,(%esp)
  802008:	e8 eb ea ff ff       	call   800af8 <sys_cputs>
}
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    

0080200f <getchar>:

int
getchar(void)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802015:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80201c:	00 
  80201d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802020:	89 44 24 04          	mov    %eax,0x4(%esp)
  802024:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80202b:	e8 3a f6 ff ff       	call   80166a <read>
	if (r < 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	78 0f                	js     802043 <getchar+0x34>
		return r;
	if (r < 1)
  802034:	85 c0                	test   %eax,%eax
  802036:	7e 06                	jle    80203e <getchar+0x2f>
		return -E_EOF;
	return c;
  802038:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80203c:	eb 05                	jmp    802043 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80203e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    

00802045 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 71 f3 ff ff       	call   8013ce <fd_lookup>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 11                	js     802072 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802064:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80206a:	39 10                	cmp    %edx,(%eax)
  80206c:	0f 94 c0             	sete   %al
  80206f:	0f b6 c0             	movzbl %al,%eax
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <opencons>:

int
opencons(void)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80207a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207d:	89 04 24             	mov    %eax,(%esp)
  802080:	e8 f6 f2 ff ff       	call   80137b <fd_alloc>
  802085:	85 c0                	test   %eax,%eax
  802087:	78 3c                	js     8020c5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802089:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802090:	00 
  802091:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802094:	89 44 24 04          	mov    %eax,0x4(%esp)
  802098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209f:	e8 21 eb ff ff       	call   800bc5 <sys_page_alloc>
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	78 1d                	js     8020c5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020bd:	89 04 24             	mov    %eax,(%esp)
  8020c0:	e8 8b f2 ff ff       	call   801350 <fd2num>
}
  8020c5:	c9                   	leave  
  8020c6:	c3                   	ret    
	...

008020c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8020d0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020d3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8020d9:	e8 a9 ea ff ff       	call   800b87 <sys_getenvid>
  8020de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8020e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f4:	c7 04 24 0c 2a 80 00 	movl   $0x802a0c,(%esp)
  8020fb:	e8 08 e1 ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802100:	89 74 24 04          	mov    %esi,0x4(%esp)
  802104:	8b 45 10             	mov    0x10(%ebp),%eax
  802107:	89 04 24             	mov    %eax,(%esp)
  80210a:	e8 98 e0 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  80210f:	c7 04 24 f9 29 80 00 	movl   $0x8029f9,(%esp)
  802116:	e8 ed e0 ff ff       	call   800208 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80211b:	cc                   	int3   
  80211c:	eb fd                	jmp    80211b <_panic+0x53>
	...

00802120 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802126:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80212d:	0f 85 80 00 00 00    	jne    8021b3 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  802133:	a1 04 40 80 00       	mov    0x804004,%eax
  802138:	8b 40 48             	mov    0x48(%eax),%eax
  80213b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802142:	00 
  802143:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80214a:	ee 
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 72 ea ff ff       	call   800bc5 <sys_page_alloc>
  802153:	85 c0                	test   %eax,%eax
  802155:	79 20                	jns    802177 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  802157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215b:	c7 44 24 08 30 2a 80 	movl   $0x802a30,0x8(%esp)
  802162:	00 
  802163:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80216a:	00 
  80216b:	c7 04 24 8c 2a 80 00 	movl   $0x802a8c,(%esp)
  802172:	e8 51 ff ff ff       	call   8020c8 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  802177:	a1 04 40 80 00       	mov    0x804004,%eax
  80217c:	8b 40 48             	mov    0x48(%eax),%eax
  80217f:	c7 44 24 04 c0 21 80 	movl   $0x8021c0,0x4(%esp)
  802186:	00 
  802187:	89 04 24             	mov    %eax,(%esp)
  80218a:	e8 d6 eb ff ff       	call   800d65 <sys_env_set_pgfault_upcall>
  80218f:	85 c0                	test   %eax,%eax
  802191:	79 20                	jns    8021b3 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  802193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802197:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
  80219e:	00 
  80219f:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8021a6:	00 
  8021a7:	c7 04 24 8c 2a 80 00 	movl   $0x802a8c,(%esp)
  8021ae:	e8 15 ff ff ff       	call   8020c8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    
  8021bd:	00 00                	add    %al,(%eax)
	...

008021c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021c1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021c8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8021cb:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8021cf:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8021d1:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8021d4:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8021d5:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8021d8:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8021da:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8021dd:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8021de:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8021e1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8021e2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8021e3:	c3                   	ret    

008021e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	c1 ea 16             	shr    $0x16,%edx
  8021ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021f6:	f6 c2 01             	test   $0x1,%dl
  8021f9:	74 1e                	je     802219 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fb:	c1 e8 0c             	shr    $0xc,%eax
  8021fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802205:	a8 01                	test   $0x1,%al
  802207:	74 17                	je     802220 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802209:	c1 e8 0c             	shr    $0xc,%eax
  80220c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802213:	ef 
  802214:	0f b7 c0             	movzwl %ax,%eax
  802217:	eb 0c                	jmp    802225 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
  80221e:	eb 05                	jmp    802225 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802220:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    
	...

00802228 <__udivdi3>:
  802228:	55                   	push   %ebp
  802229:	57                   	push   %edi
  80222a:	56                   	push   %esi
  80222b:	83 ec 10             	sub    $0x10,%esp
  80222e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802232:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80223e:	89 cd                	mov    %ecx,%ebp
  802240:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802244:	85 c0                	test   %eax,%eax
  802246:	75 2c                	jne    802274 <__udivdi3+0x4c>
  802248:	39 f9                	cmp    %edi,%ecx
  80224a:	77 68                	ja     8022b4 <__udivdi3+0x8c>
  80224c:	85 c9                	test   %ecx,%ecx
  80224e:	75 0b                	jne    80225b <__udivdi3+0x33>
  802250:	b8 01 00 00 00       	mov    $0x1,%eax
  802255:	31 d2                	xor    %edx,%edx
  802257:	f7 f1                	div    %ecx
  802259:	89 c1                	mov    %eax,%ecx
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	89 f8                	mov    %edi,%eax
  80225f:	f7 f1                	div    %ecx
  802261:	89 c7                	mov    %eax,%edi
  802263:	89 f0                	mov    %esi,%eax
  802265:	f7 f1                	div    %ecx
  802267:	89 c6                	mov    %eax,%esi
  802269:	89 f0                	mov    %esi,%eax
  80226b:	89 fa                	mov    %edi,%edx
  80226d:	83 c4 10             	add    $0x10,%esp
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	39 f8                	cmp    %edi,%eax
  802276:	77 2c                	ja     8022a4 <__udivdi3+0x7c>
  802278:	0f bd f0             	bsr    %eax,%esi
  80227b:	83 f6 1f             	xor    $0x1f,%esi
  80227e:	75 4c                	jne    8022cc <__udivdi3+0xa4>
  802280:	39 f8                	cmp    %edi,%eax
  802282:	bf 00 00 00 00       	mov    $0x0,%edi
  802287:	72 0a                	jb     802293 <__udivdi3+0x6b>
  802289:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80228d:	0f 87 ad 00 00 00    	ja     802340 <__udivdi3+0x118>
  802293:	be 01 00 00 00       	mov    $0x1,%esi
  802298:	89 f0                	mov    %esi,%eax
  80229a:	89 fa                	mov    %edi,%edx
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
  8022a3:	90                   	nop
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	31 f6                	xor    %esi,%esi
  8022a8:	89 f0                	mov    %esi,%eax
  8022aa:	89 fa                	mov    %edi,%edx
  8022ac:	83 c4 10             	add    $0x10,%esp
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
  8022b3:	90                   	nop
  8022b4:	89 fa                	mov    %edi,%edx
  8022b6:	89 f0                	mov    %esi,%eax
  8022b8:	f7 f1                	div    %ecx
  8022ba:	89 c6                	mov    %eax,%esi
  8022bc:	31 ff                	xor    %edi,%edi
  8022be:	89 f0                	mov    %esi,%eax
  8022c0:	89 fa                	mov    %edi,%edx
  8022c2:	83 c4 10             	add    $0x10,%esp
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d 76 00             	lea    0x0(%esi),%esi
  8022cc:	89 f1                	mov    %esi,%ecx
  8022ce:	d3 e0                	shl    %cl,%eax
  8022d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8022d9:	29 f0                	sub    %esi,%eax
  8022db:	89 ea                	mov    %ebp,%edx
  8022dd:	88 c1                	mov    %al,%cl
  8022df:	d3 ea                	shr    %cl,%edx
  8022e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022e5:	09 ca                	or     %ecx,%edx
  8022e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022eb:	89 f1                	mov    %esi,%ecx
  8022ed:	d3 e5                	shl    %cl,%ebp
  8022ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8022f3:	89 fd                	mov    %edi,%ebp
  8022f5:	88 c1                	mov    %al,%cl
  8022f7:	d3 ed                	shr    %cl,%ebp
  8022f9:	89 fa                	mov    %edi,%edx
  8022fb:	89 f1                	mov    %esi,%ecx
  8022fd:	d3 e2                	shl    %cl,%edx
  8022ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802303:	88 c1                	mov    %al,%cl
  802305:	d3 ef                	shr    %cl,%edi
  802307:	09 d7                	or     %edx,%edi
  802309:	89 f8                	mov    %edi,%eax
  80230b:	89 ea                	mov    %ebp,%edx
  80230d:	f7 74 24 08          	divl   0x8(%esp)
  802311:	89 d1                	mov    %edx,%ecx
  802313:	89 c7                	mov    %eax,%edi
  802315:	f7 64 24 0c          	mull   0xc(%esp)
  802319:	39 d1                	cmp    %edx,%ecx
  80231b:	72 17                	jb     802334 <__udivdi3+0x10c>
  80231d:	74 09                	je     802328 <__udivdi3+0x100>
  80231f:	89 fe                	mov    %edi,%esi
  802321:	31 ff                	xor    %edi,%edi
  802323:	e9 41 ff ff ff       	jmp    802269 <__udivdi3+0x41>
  802328:	8b 54 24 04          	mov    0x4(%esp),%edx
  80232c:	89 f1                	mov    %esi,%ecx
  80232e:	d3 e2                	shl    %cl,%edx
  802330:	39 c2                	cmp    %eax,%edx
  802332:	73 eb                	jae    80231f <__udivdi3+0xf7>
  802334:	8d 77 ff             	lea    -0x1(%edi),%esi
  802337:	31 ff                	xor    %edi,%edi
  802339:	e9 2b ff ff ff       	jmp    802269 <__udivdi3+0x41>
  80233e:	66 90                	xchg   %ax,%ax
  802340:	31 f6                	xor    %esi,%esi
  802342:	e9 22 ff ff ff       	jmp    802269 <__udivdi3+0x41>
	...

00802348 <__umoddi3>:
  802348:	55                   	push   %ebp
  802349:	57                   	push   %edi
  80234a:	56                   	push   %esi
  80234b:	83 ec 20             	sub    $0x20,%esp
  80234e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802352:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802356:	89 44 24 14          	mov    %eax,0x14(%esp)
  80235a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80235e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802362:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802366:	89 c7                	mov    %eax,%edi
  802368:	89 f2                	mov    %esi,%edx
  80236a:	85 ed                	test   %ebp,%ebp
  80236c:	75 16                	jne    802384 <__umoddi3+0x3c>
  80236e:	39 f1                	cmp    %esi,%ecx
  802370:	0f 86 a6 00 00 00    	jbe    80241c <__umoddi3+0xd4>
  802376:	f7 f1                	div    %ecx
  802378:	89 d0                	mov    %edx,%eax
  80237a:	31 d2                	xor    %edx,%edx
  80237c:	83 c4 20             	add    $0x20,%esp
  80237f:	5e                   	pop    %esi
  802380:	5f                   	pop    %edi
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    
  802383:	90                   	nop
  802384:	39 f5                	cmp    %esi,%ebp
  802386:	0f 87 ac 00 00 00    	ja     802438 <__umoddi3+0xf0>
  80238c:	0f bd c5             	bsr    %ebp,%eax
  80238f:	83 f0 1f             	xor    $0x1f,%eax
  802392:	89 44 24 10          	mov    %eax,0x10(%esp)
  802396:	0f 84 a8 00 00 00    	je     802444 <__umoddi3+0xfc>
  80239c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023a0:	d3 e5                	shl    %cl,%ebp
  8023a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023af:	89 f9                	mov    %edi,%ecx
  8023b1:	d3 e8                	shr    %cl,%eax
  8023b3:	09 e8                	or     %ebp,%eax
  8023b5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023c1:	d3 e0                	shl    %cl,%eax
  8023c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023c7:	89 f2                	mov    %esi,%edx
  8023c9:	d3 e2                	shl    %cl,%edx
  8023cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023cf:	d3 e0                	shl    %cl,%eax
  8023d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d9:	89 f9                	mov    %edi,%ecx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	09 d0                	or     %edx,%eax
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	89 f2                	mov    %esi,%edx
  8023e3:	f7 74 24 18          	divl   0x18(%esp)
  8023e7:	89 d6                	mov    %edx,%esi
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	89 c5                	mov    %eax,%ebp
  8023ef:	89 d1                	mov    %edx,%ecx
  8023f1:	39 d6                	cmp    %edx,%esi
  8023f3:	72 67                	jb     80245c <__umoddi3+0x114>
  8023f5:	74 75                	je     80246c <__umoddi3+0x124>
  8023f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023fb:	29 e8                	sub    %ebp,%eax
  8023fd:	19 ce                	sbb    %ecx,%esi
  8023ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802403:	d3 e8                	shr    %cl,%eax
  802405:	89 f2                	mov    %esi,%edx
  802407:	89 f9                	mov    %edi,%ecx
  802409:	d3 e2                	shl    %cl,%edx
  80240b:	09 d0                	or     %edx,%eax
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802413:	d3 ea                	shr    %cl,%edx
  802415:	83 c4 20             	add    $0x20,%esp
  802418:	5e                   	pop    %esi
  802419:	5f                   	pop    %edi
  80241a:	5d                   	pop    %ebp
  80241b:	c3                   	ret    
  80241c:	85 c9                	test   %ecx,%ecx
  80241e:	75 0b                	jne    80242b <__umoddi3+0xe3>
  802420:	b8 01 00 00 00       	mov    $0x1,%eax
  802425:	31 d2                	xor    %edx,%edx
  802427:	f7 f1                	div    %ecx
  802429:	89 c1                	mov    %eax,%ecx
  80242b:	89 f0                	mov    %esi,%eax
  80242d:	31 d2                	xor    %edx,%edx
  80242f:	f7 f1                	div    %ecx
  802431:	89 f8                	mov    %edi,%eax
  802433:	e9 3e ff ff ff       	jmp    802376 <__umoddi3+0x2e>
  802438:	89 f2                	mov    %esi,%edx
  80243a:	83 c4 20             	add    $0x20,%esp
  80243d:	5e                   	pop    %esi
  80243e:	5f                   	pop    %edi
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    
  802441:	8d 76 00             	lea    0x0(%esi),%esi
  802444:	39 f5                	cmp    %esi,%ebp
  802446:	72 04                	jb     80244c <__umoddi3+0x104>
  802448:	39 f9                	cmp    %edi,%ecx
  80244a:	77 06                	ja     802452 <__umoddi3+0x10a>
  80244c:	89 f2                	mov    %esi,%edx
  80244e:	29 cf                	sub    %ecx,%edi
  802450:	19 ea                	sbb    %ebp,%edx
  802452:	89 f8                	mov    %edi,%eax
  802454:	83 c4 20             	add    $0x20,%esp
  802457:	5e                   	pop    %esi
  802458:	5f                   	pop    %edi
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    
  80245b:	90                   	nop
  80245c:	89 d1                	mov    %edx,%ecx
  80245e:	89 c5                	mov    %eax,%ebp
  802460:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802464:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802468:	eb 8d                	jmp    8023f7 <__umoddi3+0xaf>
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802470:	72 ea                	jb     80245c <__umoddi3+0x114>
  802472:	89 f1                	mov    %esi,%ecx
  802474:	eb 81                	jmp    8023f7 <__umoddi3+0xaf>
