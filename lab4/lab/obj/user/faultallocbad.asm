
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  80004b:	e8 f4 01 00 00       	call   800244 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 92 0b 00 00       	call   800c01 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 60 11 80 	movl   $0x801160,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 4a 11 80 00 	movl   $0x80114a,(%esp)
  800092:	e8 b5 00 00 00       	call   80014c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 8c 11 80 	movl   $0x80118c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 fe 06 00 00       	call   8007b1 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 4d 0d 00 00       	call   800e18 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 55 0a 00 00       	call   800b34 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 10             	sub    $0x10,%esp
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000f2:	e8 cc 0a 00 00       	call   800bc3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800103:	c1 e0 07             	shl    $0x7,%eax
  800106:	29 d0                	sub    %edx,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 f6                	test   %esi,%esi
  800114:	7e 07                	jle    80011d <libmain+0x39>
		binaryname = argv[0];
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800121:	89 34 24             	mov    %esi,(%esp)
  800124:	e8 90 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800129:	e8 0a 00 00 00       	call   800138 <exit>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800145:	e8 27 0a 00 00       	call   800b71 <sys_env_destroy>
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800154:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800157:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80015d:	e8 61 0a 00 00       	call   800bc3 <sys_getenvid>
  800162:	8b 55 0c             	mov    0xc(%ebp),%edx
  800165:	89 54 24 10          	mov    %edx,0x10(%esp)
  800169:	8b 55 08             	mov    0x8(%ebp),%edx
  80016c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800170:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 b8 11 80 00 	movl   $0x8011b8,(%esp)
  80017f:	e8 c0 00 00 00       	call   800244 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800184:	89 74 24 04          	mov    %esi,0x4(%esp)
  800188:	8b 45 10             	mov    0x10(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 50 00 00 00       	call   8001e3 <vcprintf>
	cprintf("\n");
  800193:	c7 04 24 48 11 80 00 	movl   $0x801148,(%esp)
  80019a:	e8 a5 00 00 00       	call   800244 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019f:	cc                   	int3   
  8001a0:	eb fd                	jmp    80019f <_panic+0x53>
	...

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b7:	40                   	inc    %eax
  8001b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 19                	jne    8001da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c8:	00 
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 60 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001da:	ff 43 04             	incl   0x4(%ebx)
}
  8001dd:	83 c4 14             	add    $0x14,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 a4 01 80 00 	movl   $0x8001a4,(%esp)
  80021f:	e8 82 01 00 00       	call   8003a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800224:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	e8 f8 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  80023c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 87 ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	85 c0                	test   %eax,%eax
  800282:	75 08                	jne    80028c <printnum+0x2c>
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 57                	ja     8002e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800290:	4b                   	dec    %ebx
  800291:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ab:	00 
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	e8 1e 0c 00 00       	call   800edc <__udivdi3>
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	89 fa                	mov    %edi,%edx
  8002cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d2:	e8 89 ff ff ff       	call   800260 <printnum>
  8002d7:	eb 0f                	jmp    8002e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dd:	89 34 24             	mov    %esi,(%esp)
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e3:	4b                   	dec    %ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f f1                	jg     8002d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fe:	00 
  8002ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	e8 eb 0c 00 00       	call   800ffc <__umoddi3>
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	0f be 80 db 11 80 00 	movsbl 0x8011db(%eax),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800322:	83 c4 3c             	add    $0x3c,%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 08                	jae    80037c <sprintputch+0x18>
		*b->buf++ = ch;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 0a                	mov    %cl,(%edx)
  800379:	42                   	inc    %edx
  80037a:	89 10                	mov    %edx,(%eax)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038b:	8b 45 10             	mov    0x10(%ebp),%eax
  80038e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 02 00 00 00       	call   8003a6 <vprintfmt>
	va_end(ap);
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	57                   	push   %edi
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 4c             	sub    $0x4c,%esp
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 8b 03 00 00    	je     80074a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 06             	movzbl (%esi),%eax
  8003cc:	46                   	inc    %esi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e5                	jne    8003b7 <vprintfmt+0x11>
  8003d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	eb 26                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003f7:	eb 1d                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800400:	eb 14                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800405:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80040c:	eb 08                	jmp    800416 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80040e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800411:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	0f b6 06             	movzbl (%esi),%eax
  800419:	8d 56 01             	lea    0x1(%esi),%edx
  80041c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041f:	8a 16                	mov    (%esi),%dl
  800421:	83 ea 23             	sub    $0x23,%edx
  800424:	80 fa 55             	cmp    $0x55,%dl
  800427:	0f 87 01 03 00 00    	ja     80072e <vprintfmt+0x388>
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800442:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800446:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800449:	8d 50 d0             	lea    -0x30(%eax),%edx
  80044c:	83 fa 09             	cmp    $0x9,%edx
  80044f:	77 2a                	ja     80047b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800451:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800452:	eb eb                	jmp    80043f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 17                	jmp    80047b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800464:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800468:	78 98                	js     800402 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046d:	eb a7                	jmp    800416 <vprintfmt+0x70>
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800472:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800479:	eb 9b                	jmp    800416 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047f:	79 95                	jns    800416 <vprintfmt+0x70>
  800481:	eb 8b                	jmp    80040e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800487:	eb 8d                	jmp    800416 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a1:	e9 23 ff ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	79 02                	jns    8004b7 <vprintfmt+0x111>
  8004b5:	f7 d8                	neg    %eax
  8004b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 08             	cmp    $0x8,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x123>
  8004be:	8b 04 85 00 14 80 00 	mov    0x801400(,%eax,4),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cd:	c7 44 24 08 f3 11 80 	movl   $0x8011f3,0x8(%esp)
  8004d4:	00 
  8004d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 9a fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e7:	e9 dd fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 fc 11 80 	movl   $0x8011fc,0x8(%esp)
  8004f7:	00 
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 14 24             	mov    %edx,(%esp)
  800502:	e8 77 fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 ba fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
  80050f:	89 f9                	mov    %edi,%ecx
  800511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800514:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 30                	mov    (%eax),%esi
  800522:	85 f6                	test   %esi,%esi
  800524:	75 05                	jne    80052b <vprintfmt+0x185>
				p = "(null)";
  800526:	be ec 11 80 00       	mov    $0x8011ec,%esi
			if (width > 0 && padc != '-')
  80052b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052f:	0f 8e 84 00 00 00    	jle    8005b9 <vprintfmt+0x213>
  800535:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800539:	74 7e                	je     8005b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053f:	89 34 24             	mov    %esi,(%esp)
  800542:	e8 ab 02 00 00       	call   8007f2 <strnlen>
  800547:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80054f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800553:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800556:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800559:	89 de                	mov    %ebx,%esi
  80055b:	89 d3                	mov    %edx,%ebx
  80055d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 0b                	jmp    80056c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	89 3c 24             	mov    %edi,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4b                   	dec    %ebx
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f f1                	jg     800561 <vprintfmt+0x1bb>
  800570:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800573:	89 f3                	mov    %esi,%ebx
  800575:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057b:	85 c0                	test   %eax,%eax
  80057d:	79 05                	jns    800584 <vprintfmt+0x1de>
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800587:	29 c2                	sub    %eax,%edx
  800589:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058c:	eb 2b                	jmp    8005b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800592:	74 18                	je     8005ac <vprintfmt+0x206>
  800594:	8d 50 e0             	lea    -0x20(%eax),%edx
  800597:	83 fa 5e             	cmp    $0x5e,%edx
  80059a:	76 10                	jbe    8005ac <vprintfmt+0x206>
					putch('?', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	eb 0a                	jmp    8005b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b9:	0f be 06             	movsbl (%esi),%eax
  8005bc:	46                   	inc    %esi
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	74 21                	je     8005e2 <vprintfmt+0x23c>
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	78 c9                	js     80058e <vprintfmt+0x1e8>
  8005c5:	4f                   	dec    %edi
  8005c6:	79 c6                	jns    80058e <vprintfmt+0x1e8>
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x244>
  8005e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x22c>
  8005ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f6:	e9 ce fd ff ff       	jmp    8003c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7e 10                	jle    800610 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 08             	lea    0x8(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	8b 78 04             	mov    0x4(%eax),%edi
  80060e:	eb 26                	jmp    800636 <vprintfmt+0x290>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 12                	je     800626 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 f7                	mov    %esi,%edi
  800621:	c1 ff 1f             	sar    $0x1f,%edi
  800624:	eb 10                	jmp    800636 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	89 f7                	mov    %esi,%edi
  800633:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	85 ff                	test   %edi,%edi
  800638:	78 0a                	js     800644 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 ac 00 00 00       	jmp    8006f0 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	f7 de                	neg    %esi
  800654:	83 d7 00             	adc    $0x0,%edi
  800657:	f7 df                	neg    %edi
			}
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 8d 00 00 00       	jmp    8006f0 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800663:	89 ca                	mov    %ecx,%edx
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 bd fc ff ff       	call   80032a <getuint>
  80066d:	89 c6                	mov    %eax,%esi
  80066f:	89 d7                	mov    %edx,%edi
			base = 10;
  800671:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800676:	eb 78                	jmp    8006f0 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800691:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a5:	e9 1f fd ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 43 fc ff ff       	call   80032a <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 4c fb ff ff       	call   800260 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 ad fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 9b fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x399>
  80073e:	4e                   	dec    %esi
  80073f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800743:	75 f9                	jne    80073e <vprintfmt+0x398>
  800745:	e9 7f fc ff ff       	jmp    8003c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 4c             	add    $0x4c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 33                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 64 03 80 00 	movl   $0x800364,(%esp)
  800793:	e8 0e fc ff ff       	call   8003a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 0c                	jmp    8007af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x5d>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 7b ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800bb6:	e8 91 f5 ff ff       	call   80014c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	83 c4 2c             	add    $0x2c,%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800c48:	e8 ff f4 ff ff       	call   80014c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 75 18             	mov    0x18(%ebp),%esi
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 28                	jle    800ca0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c83:	00 
  800c84:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800c9b:	e8 ac f4 ff ff       	call   80014c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	83 c4 2c             	add    $0x2c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800cee:	e8 59 f4 ff ff       	call   80014c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d41:	e8 06 f4 ff ff       	call   80014c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	83 c4 2c             	add    $0x2c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d94:	e8 b3 f3 ff ff       	call   80014c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800e09:	e8 3e f3 ff ff       	call   80014c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
	...

00800e18 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e1e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e25:	0f 85 80 00 00 00    	jne    800eab <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800e2b:	a1 04 20 80 00       	mov    0x802004,%eax
  800e30:	8b 40 48             	mov    0x48(%eax),%eax
  800e33:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e42:	ee 
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	e8 b6 fd ff ff       	call   800c01 <sys_page_alloc>
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 20                	jns    800e6f <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800e4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e53:	c7 44 24 08 50 14 80 	movl   $0x801450,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 ac 14 80 00 	movl   $0x8014ac,(%esp)
  800e6a:	e8 dd f2 ff ff       	call   80014c <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800e6f:	a1 04 20 80 00       	mov    0x802004,%eax
  800e74:	8b 40 48             	mov    0x48(%eax),%eax
  800e77:	c7 44 24 04 b8 0e 80 	movl   $0x800eb8,0x4(%esp)
  800e7e:	00 
  800e7f:	89 04 24             	mov    %eax,(%esp)
  800e82:	e8 c7 fe ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 20                	jns    800eab <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800e8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8f:	c7 44 24 08 7c 14 80 	movl   $0x80147c,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 ac 14 80 00 	movl   $0x8014ac,(%esp)
  800ea6:	e8 a1 f2 ff ff       	call   80014c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    
  800eb5:	00 00                	add    %al,(%eax)
	...

00800eb8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eb8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eb9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ebe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ec0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  800ec3:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800ec7:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800ec9:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800ecc:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800ecd:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  800ed0:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  800ed2:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800ed5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800ed6:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800ed9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800eda:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800edb:	c3                   	ret    

00800edc <__udivdi3>:
  800edc:	55                   	push   %ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	83 ec 10             	sub    $0x10,%esp
  800ee2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800ee6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800eea:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800ef2:	89 cd                	mov    %ecx,%ebp
  800ef4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	75 2c                	jne    800f28 <__udivdi3+0x4c>
  800efc:	39 f9                	cmp    %edi,%ecx
  800efe:	77 68                	ja     800f68 <__udivdi3+0x8c>
  800f00:	85 c9                	test   %ecx,%ecx
  800f02:	75 0b                	jne    800f0f <__udivdi3+0x33>
  800f04:	b8 01 00 00 00       	mov    $0x1,%eax
  800f09:	31 d2                	xor    %edx,%edx
  800f0b:	f7 f1                	div    %ecx
  800f0d:	89 c1                	mov    %eax,%ecx
  800f0f:	31 d2                	xor    %edx,%edx
  800f11:	89 f8                	mov    %edi,%eax
  800f13:	f7 f1                	div    %ecx
  800f15:	89 c7                	mov    %eax,%edi
  800f17:	89 f0                	mov    %esi,%eax
  800f19:	f7 f1                	div    %ecx
  800f1b:	89 c6                	mov    %eax,%esi
  800f1d:	89 f0                	mov    %esi,%eax
  800f1f:	89 fa                	mov    %edi,%edx
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
  800f28:	39 f8                	cmp    %edi,%eax
  800f2a:	77 2c                	ja     800f58 <__udivdi3+0x7c>
  800f2c:	0f bd f0             	bsr    %eax,%esi
  800f2f:	83 f6 1f             	xor    $0x1f,%esi
  800f32:	75 4c                	jne    800f80 <__udivdi3+0xa4>
  800f34:	39 f8                	cmp    %edi,%eax
  800f36:	bf 00 00 00 00       	mov    $0x0,%edi
  800f3b:	72 0a                	jb     800f47 <__udivdi3+0x6b>
  800f3d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f41:	0f 87 ad 00 00 00    	ja     800ff4 <__udivdi3+0x118>
  800f47:	be 01 00 00 00       	mov    $0x1,%esi
  800f4c:	89 f0                	mov    %esi,%eax
  800f4e:	89 fa                	mov    %edi,%edx
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    
  800f57:	90                   	nop
  800f58:	31 ff                	xor    %edi,%edi
  800f5a:	31 f6                	xor    %esi,%esi
  800f5c:	89 f0                	mov    %esi,%eax
  800f5e:	89 fa                	mov    %edi,%edx
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    
  800f67:	90                   	nop
  800f68:	89 fa                	mov    %edi,%edx
  800f6a:	89 f0                	mov    %esi,%eax
  800f6c:	f7 f1                	div    %ecx
  800f6e:	89 c6                	mov    %eax,%esi
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	89 f0                	mov    %esi,%eax
  800f74:	89 fa                	mov    %edi,%edx
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 f1                	mov    %esi,%ecx
  800f82:	d3 e0                	shl    %cl,%eax
  800f84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f88:	b8 20 00 00 00       	mov    $0x20,%eax
  800f8d:	29 f0                	sub    %esi,%eax
  800f8f:	89 ea                	mov    %ebp,%edx
  800f91:	88 c1                	mov    %al,%cl
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f99:	09 ca                	or     %ecx,%edx
  800f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f9f:	89 f1                	mov    %esi,%ecx
  800fa1:	d3 e5                	shl    %cl,%ebp
  800fa3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800fa7:	89 fd                	mov    %edi,%ebp
  800fa9:	88 c1                	mov    %al,%cl
  800fab:	d3 ed                	shr    %cl,%ebp
  800fad:	89 fa                	mov    %edi,%edx
  800faf:	89 f1                	mov    %esi,%ecx
  800fb1:	d3 e2                	shl    %cl,%edx
  800fb3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb7:	88 c1                	mov    %al,%cl
  800fb9:	d3 ef                	shr    %cl,%edi
  800fbb:	09 d7                	or     %edx,%edi
  800fbd:	89 f8                	mov    %edi,%eax
  800fbf:	89 ea                	mov    %ebp,%edx
  800fc1:	f7 74 24 08          	divl   0x8(%esp)
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 c7                	mov    %eax,%edi
  800fc9:	f7 64 24 0c          	mull   0xc(%esp)
  800fcd:	39 d1                	cmp    %edx,%ecx
  800fcf:	72 17                	jb     800fe8 <__udivdi3+0x10c>
  800fd1:	74 09                	je     800fdc <__udivdi3+0x100>
  800fd3:	89 fe                	mov    %edi,%esi
  800fd5:	31 ff                	xor    %edi,%edi
  800fd7:	e9 41 ff ff ff       	jmp    800f1d <__udivdi3+0x41>
  800fdc:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fe0:	89 f1                	mov    %esi,%ecx
  800fe2:	d3 e2                	shl    %cl,%edx
  800fe4:	39 c2                	cmp    %eax,%edx
  800fe6:	73 eb                	jae    800fd3 <__udivdi3+0xf7>
  800fe8:	8d 77 ff             	lea    -0x1(%edi),%esi
  800feb:	31 ff                	xor    %edi,%edi
  800fed:	e9 2b ff ff ff       	jmp    800f1d <__udivdi3+0x41>
  800ff2:	66 90                	xchg   %ax,%ax
  800ff4:	31 f6                	xor    %esi,%esi
  800ff6:	e9 22 ff ff ff       	jmp    800f1d <__udivdi3+0x41>
	...

00800ffc <__umoddi3>:
  800ffc:	55                   	push   %ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	83 ec 20             	sub    $0x20,%esp
  801002:	8b 44 24 30          	mov    0x30(%esp),%eax
  801006:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80100a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80100e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801012:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801016:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80101a:	89 c7                	mov    %eax,%edi
  80101c:	89 f2                	mov    %esi,%edx
  80101e:	85 ed                	test   %ebp,%ebp
  801020:	75 16                	jne    801038 <__umoddi3+0x3c>
  801022:	39 f1                	cmp    %esi,%ecx
  801024:	0f 86 a6 00 00 00    	jbe    8010d0 <__umoddi3+0xd4>
  80102a:	f7 f1                	div    %ecx
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	31 d2                	xor    %edx,%edx
  801030:	83 c4 20             	add    $0x20,%esp
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    
  801037:	90                   	nop
  801038:	39 f5                	cmp    %esi,%ebp
  80103a:	0f 87 ac 00 00 00    	ja     8010ec <__umoddi3+0xf0>
  801040:	0f bd c5             	bsr    %ebp,%eax
  801043:	83 f0 1f             	xor    $0x1f,%eax
  801046:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104a:	0f 84 a8 00 00 00    	je     8010f8 <__umoddi3+0xfc>
  801050:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801054:	d3 e5                	shl    %cl,%ebp
  801056:	bf 20 00 00 00       	mov    $0x20,%edi
  80105b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80105f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801063:	89 f9                	mov    %edi,%ecx
  801065:	d3 e8                	shr    %cl,%eax
  801067:	09 e8                	or     %ebp,%eax
  801069:	89 44 24 18          	mov    %eax,0x18(%esp)
  80106d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801071:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801075:	d3 e0                	shl    %cl,%eax
  801077:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80107b:	89 f2                	mov    %esi,%edx
  80107d:	d3 e2                	shl    %cl,%edx
  80107f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801083:	d3 e0                	shl    %cl,%eax
  801085:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801089:	8b 44 24 14          	mov    0x14(%esp),%eax
  80108d:	89 f9                	mov    %edi,%ecx
  80108f:	d3 e8                	shr    %cl,%eax
  801091:	09 d0                	or     %edx,%eax
  801093:	d3 ee                	shr    %cl,%esi
  801095:	89 f2                	mov    %esi,%edx
  801097:	f7 74 24 18          	divl   0x18(%esp)
  80109b:	89 d6                	mov    %edx,%esi
  80109d:	f7 64 24 0c          	mull   0xc(%esp)
  8010a1:	89 c5                	mov    %eax,%ebp
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	39 d6                	cmp    %edx,%esi
  8010a7:	72 67                	jb     801110 <__umoddi3+0x114>
  8010a9:	74 75                	je     801120 <__umoddi3+0x124>
  8010ab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010af:	29 e8                	sub    %ebp,%eax
  8010b1:	19 ce                	sbb    %ecx,%esi
  8010b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	89 f2                	mov    %esi,%edx
  8010bb:	89 f9                	mov    %edi,%ecx
  8010bd:	d3 e2                	shl    %cl,%edx
  8010bf:	09 d0                	or     %edx,%eax
  8010c1:	89 f2                	mov    %esi,%edx
  8010c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010c7:	d3 ea                	shr    %cl,%edx
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    
  8010d0:	85 c9                	test   %ecx,%ecx
  8010d2:	75 0b                	jne    8010df <__umoddi3+0xe3>
  8010d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d9:	31 d2                	xor    %edx,%edx
  8010db:	f7 f1                	div    %ecx
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	89 f0                	mov    %esi,%eax
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	f7 f1                	div    %ecx
  8010e5:	89 f8                	mov    %edi,%eax
  8010e7:	e9 3e ff ff ff       	jmp    80102a <__umoddi3+0x2e>
  8010ec:	89 f2                	mov    %esi,%edx
  8010ee:	83 c4 20             	add    $0x20,%esp
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    
  8010f5:	8d 76 00             	lea    0x0(%esi),%esi
  8010f8:	39 f5                	cmp    %esi,%ebp
  8010fa:	72 04                	jb     801100 <__umoddi3+0x104>
  8010fc:	39 f9                	cmp    %edi,%ecx
  8010fe:	77 06                	ja     801106 <__umoddi3+0x10a>
  801100:	89 f2                	mov    %esi,%edx
  801102:	29 cf                	sub    %ecx,%edi
  801104:	19 ea                	sbb    %ebp,%edx
  801106:	89 f8                	mov    %edi,%eax
  801108:	83 c4 20             	add    $0x20,%esp
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    
  80110f:	90                   	nop
  801110:	89 d1                	mov    %edx,%ecx
  801112:	89 c5                	mov    %eax,%ebp
  801114:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801118:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80111c:	eb 8d                	jmp    8010ab <__umoddi3+0xaf>
  80111e:	66 90                	xchg   %ax,%ax
  801120:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801124:	72 ea                	jb     801110 <__umoddi3+0x114>
  801126:	89 f1                	mov    %esi,%ecx
  801128:	eb 81                	jmp    8010ab <__umoddi3+0xaf>
