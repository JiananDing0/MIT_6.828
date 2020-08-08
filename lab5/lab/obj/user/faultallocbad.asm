
obj/user/faultallocbad.debug:     file format elf32-i386


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
  800044:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  80004b:	e8 fc 01 00 00       	call   80024c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 9a 0b 00 00       	call   800c09 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 80 20 80 	movl   $0x802080,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 6a 20 80 00 	movl   $0x80206a,(%esp)
  800092:	e8 bd 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ac 20 80 	movl   $0x8020ac,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 06 07 00 00       	call   8007b9 <snprintf>
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
  8000c6:	e8 a9 0d 00 00       	call   800e74 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 5d 0a 00 00       	call   800b3c <sys_cputs>
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
  8000f2:	e8 d4 0a 00 00       	call   800bcb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800103:	c1 e0 07             	shl    $0x7,%eax
  800106:	29 d0                	sub    %edx,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 f6                	test   %esi,%esi
  800114:	7e 07                	jle    80011d <libmain+0x39>
		binaryname = argv[0];
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  80013e:	e8 dc 0f 00 00       	call   80111f <close_all>
	sys_env_destroy(0);
  800143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014a:	e8 2a 0a 00 00       	call   800b79 <sys_env_destroy>
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800165:	e8 61 0a 00 00       	call   800bcb <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  800187:	e8 c0 00 00 00       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 50 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 91 25 80 00 	movl   $0x802591,(%esp)
  8001a2:	e8 a5 00 00 00       	call   80024c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 19                	jne    8001e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d0:	00 
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 60 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  8001dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e2:	ff 43 04             	incl   0x4(%ebx)
}
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  800227:	e8 82 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	e8 f8 08 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 87 ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    
	...

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d7                	mov    %edx,%edi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800285:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800288:	85 c0                	test   %eax,%eax
  80028a:	75 08                	jne    800294 <printnum+0x2c>
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800292:	77 57                	ja     8002eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 74 24 10          	mov    %esi,0x10(%esp)
  800298:	4b                   	dec    %ebx
  800299:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029d:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b3:	00 
  8002b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	e8 46 1b 00 00       	call   801e0c <__udivdi3>
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 89 ff ff ff       	call   800268 <printnum>
  8002df:	eb 0f                	jmp    8002f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	89 34 24             	mov    %esi,(%esp)
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002eb:	4b                   	dec    %ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f f1                	jg     8002e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800306:	00 
  800307:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	e8 13 1c 00 00       	call   801f2c <__umoddi3>
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	0f be 80 fb 20 80 00 	movsbl 0x8020fb(%eax),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032a:	83 c4 3c             	add    $0x3c,%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800335:	83 fa 01             	cmp    $0x1,%edx
  800338:	7e 0e                	jle    800348 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	8b 52 04             	mov    0x4(%edx),%edx
  800346:	eb 22                	jmp    80036a <getuint+0x38>
	else if (lflag)
  800348:	85 d2                	test   %edx,%edx
  80034a:	74 10                	je     80035c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	eb 0e                	jmp    80036a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800372:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800375:	8b 10                	mov    (%eax),%edx
  800377:	3b 50 04             	cmp    0x4(%eax),%edx
  80037a:	73 08                	jae    800384 <sprintputch+0x18>
		*b->buf++ = ch;
  80037c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037f:	88 0a                	mov    %cl,(%edx)
  800381:	42                   	inc    %edx
  800382:	89 10                	mov    %edx,(%eax)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800393:	8b 45 10             	mov    0x10(%ebp),%eax
  800396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 02 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 4c             	sub    $0x4c,%esp
  8003b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8003bd:	eb 12                	jmp    8003d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	0f 84 8b 03 00 00    	je     800752 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	0f b6 06             	movzbl (%esi),%eax
  8003d4:	46                   	inc    %esi
  8003d5:	83 f8 25             	cmp    $0x25,%eax
  8003d8:	75 e5                	jne    8003bf <vprintfmt+0x11>
  8003da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	eb 26                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ff:	eb 1d                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800408:	eb 14                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80040d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800414:	eb 08                	jmp    80041e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800416:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800419:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	0f b6 06             	movzbl (%esi),%eax
  800421:	8d 56 01             	lea    0x1(%esi),%edx
  800424:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800427:	8a 16                	mov    (%esi),%dl
  800429:	83 ea 23             	sub    $0x23,%edx
  80042c:	80 fa 55             	cmp    $0x55,%dl
  80042f:	0f 87 01 03 00 00    	ja     800736 <vprintfmt+0x388>
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	ff 24 95 40 22 80 00 	jmp    *0x802240(,%edx,4)
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800442:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800447:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80044e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800451:	8d 50 d0             	lea    -0x30(%eax),%edx
  800454:	83 fa 09             	cmp    $0x9,%edx
  800457:	77 2a                	ja     800483 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045a:	eb eb                	jmp    800447 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046a:	eb 17                	jmp    800483 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80046c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800470:	78 98                	js     80040a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800475:	eb a7                	jmp    80041e <vprintfmt+0x70>
  800477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800481:	eb 9b                	jmp    80041e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800483:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800487:	79 95                	jns    80041e <vprintfmt+0x70>
  800489:	eb 8b                	jmp    800416 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048f:	eb 8d                	jmp    80041e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a9:	e9 23 ff ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	79 02                	jns    8004bf <vprintfmt+0x111>
  8004bd:	f7 d8                	neg    %eax
  8004bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c1:	83 f8 0f             	cmp    $0xf,%eax
  8004c4:	7f 0b                	jg     8004d1 <vprintfmt+0x123>
  8004c6:	8b 04 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	75 23                	jne    8004f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d5:	c7 44 24 08 13 21 80 	movl   $0x802113,0x8(%esp)
  8004dc:	00 
  8004dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 9a fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ef:	e9 dd fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 6a 25 80 	movl   $0x80256a,0x8(%esp)
  8004ff:	00 
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	89 14 24             	mov    %edx,(%esp)
  80050a:	e8 77 fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	e9 ba fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
  800517:	89 f9                	mov    %edi,%ecx
  800519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 30                	mov    (%eax),%esi
  80052a:	85 f6                	test   %esi,%esi
  80052c:	75 05                	jne    800533 <vprintfmt+0x185>
				p = "(null)";
  80052e:	be 0c 21 80 00       	mov    $0x80210c,%esi
			if (width > 0 && padc != '-')
  800533:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800537:	0f 8e 84 00 00 00    	jle    8005c1 <vprintfmt+0x213>
  80053d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800541:	74 7e                	je     8005c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 ab 02 00 00       	call   8007fa <strnlen>
  80054f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800552:	29 c2                	sub    %eax,%edx
  800554:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800557:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80055e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800561:	89 de                	mov    %ebx,%esi
  800563:	89 d3                	mov    %edx,%ebx
  800565:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	eb 0b                	jmp    800574 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056d:	89 3c 24             	mov    %edi,(%esp)
  800570:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	4b                   	dec    %ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f f1                	jg     800569 <vprintfmt+0x1bb>
  800578:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057b:	89 f3                	mov    %esi,%ebx
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	79 05                	jns    80058c <vprintfmt+0x1de>
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
  80058c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058f:	29 c2                	sub    %eax,%edx
  800591:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800594:	eb 2b                	jmp    8005c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059a:	74 18                	je     8005b4 <vprintfmt+0x206>
  80059c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059f:	83 fa 5e             	cmp    $0x5e,%edx
  8005a2:	76 10                	jbe    8005b4 <vprintfmt+0x206>
					putch('?', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	eb 0a                	jmp    8005be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c1:	0f be 06             	movsbl (%esi),%eax
  8005c4:	46                   	inc    %esi
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	74 21                	je     8005ea <vprintfmt+0x23c>
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	78 c9                	js     800596 <vprintfmt+0x1e8>
  8005cd:	4f                   	dec    %edi
  8005ce:	79 c6                	jns    800596 <vprintfmt+0x1e8>
  8005d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d8:	eb 18                	jmp    8005f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	4b                   	dec    %ebx
  8005e8:	eb 08                	jmp    8005f2 <vprintfmt+0x244>
  8005ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ed:	89 de                	mov    %ebx,%esi
  8005ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	7f e4                	jg     8005da <vprintfmt+0x22c>
  8005f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fe:	e9 ce fd ff ff       	jmp    8003d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 10                	jle    800618 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 08             	lea    0x8(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
  800613:	8b 78 04             	mov    0x4(%eax),%edi
  800616:	eb 26                	jmp    80063e <vprintfmt+0x290>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 12                	je     80062e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	89 f7                	mov    %esi,%edi
  800629:	c1 ff 1f             	sar    $0x1f,%edi
  80062c:	eb 10                	jmp    80063e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 30                	mov    (%eax),%esi
  800639:	89 f7                	mov    %esi,%edi
  80063b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	85 ff                	test   %edi,%edi
  800640:	78 0a                	js     80064c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 ac 00 00 00       	jmp    8006f8 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065a:	f7 de                	neg    %esi
  80065c:	83 d7 00             	adc    $0x0,%edi
  80065f:	f7 df                	neg    %edi
			}
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
  800666:	e9 8d 00 00 00       	jmp    8006f8 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066b:	89 ca                	mov    %ecx,%edx
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 bd fc ff ff       	call   800332 <getuint>
  800675:	89 c6                	mov    %eax,%esi
  800677:	89 d7                	mov    %edx,%edi
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067e:	eb 78                	jmp    8006f8 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80068e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800692:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800699:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006ad:	e9 1f fd ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d7:	8b 30                	mov    (%eax),%esi
  8006d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e3:	eb 13                	jmp    8006f8 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 43 fc ff ff       	call   800332 <getuint>
  8006ef:	89 c6                	mov    %eax,%esi
  8006f1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800700:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800703:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800707:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070b:	89 34 24             	mov    %esi,(%esp)
  80070e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800712:	89 da                	mov    %ebx,%edx
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	e8 4c fb ff ff       	call   800268 <printnum>
			break;
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071f:	e9 ad fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800731:	e9 9b fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	eb 01                	jmp    800747 <vprintfmt+0x399>
  800746:	4e                   	dec    %esi
  800747:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074b:	75 f9                	jne    800746 <vprintfmt+0x398>
  80074d:	e9 7f fc ff ff       	jmp    8003d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800752:	83 c4 4c             	add    $0x4c,%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 28             	sub    $0x28,%esp
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800769:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800777:	85 c0                	test   %eax,%eax
  800779:	74 30                	je     8007ab <vsnprintf+0x51>
  80077b:	85 d2                	test   %edx,%edx
  80077d:	7e 33                	jle    8007b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800786:	8b 45 10             	mov    0x10(%ebp),%eax
  800789:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	c7 04 24 6c 03 80 00 	movl   $0x80036c,(%esp)
  80079b:	e8 0e fc ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	eb 0c                	jmp    8007b7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b0:	eb 05                	jmp    8007b7 <vsnprintf+0x5d>
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 7b ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
  8007e1:	00 00                	add    %al,(%eax)
	...

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	eb 01                	jmp    8007f2 <strlen+0xe>
		n++;
  8007f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f6:	75 f9                	jne    8007f1 <strlen+0xd>
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 01                	jmp    80080b <strnlen+0x11>
		n++;
  80080a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1b>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f5                	jne    80080a <strnlen+0x10>
		n++;
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800829:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80082c:	42                   	inc    %edx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 f5                	jne    800826 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	89 1c 24             	mov    %ebx,(%esp)
  800841:	e8 9e ff ff ff       	call   8007e4 <strlen>
	strcpy(dst + len, src);
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 c0 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  800857:	89 d8                	mov    %ebx,%eax
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	eb 0c                	jmp    800880 <strncpy+0x21>
		*dst++ = *src;
  800874:	8a 1a                	mov    (%edx),%bl
  800876:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800879:	80 3a 01             	cmpb   $0x1,(%edx)
  80087c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087f:	41                   	inc    %ecx
  800880:	39 f1                	cmp    %esi,%ecx
  800882:	75 f0                	jne    800874 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800893:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800896:	85 d2                	test   %edx,%edx
  800898:	75 0a                	jne    8008a4 <strlcpy+0x1c>
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	eb 1a                	jmp    8008b8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	88 18                	mov    %bl,(%eax)
  8008a0:	40                   	inc    %eax
  8008a1:	41                   	inc    %ecx
  8008a2:	eb 02                	jmp    8008a6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a6:	4a                   	dec    %edx
  8008a7:	74 0a                	je     8008b3 <strlcpy+0x2b>
  8008a9:	8a 19                	mov    (%ecx),%bl
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 ef                	jne    80089e <strlcpy+0x16>
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	eb 02                	jmp    8008b5 <strlcpy+0x2d>
  8008b3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c7:	eb 02                	jmp    8008cb <strcmp+0xd>
		p++, q++;
  8008c9:	41                   	inc    %ecx
  8008ca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	8a 01                	mov    (%ecx),%al
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 04                	je     8008d5 <strcmp+0x17>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	74 f4                	je     8008c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d5:	0f b6 c0             	movzbl %al,%eax
  8008d8:	0f b6 12             	movzbl (%edx),%edx
  8008db:	29 d0                	sub    %edx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008ec:	eb 03                	jmp    8008f1 <strncmp+0x12>
		n--, p++, q++;
  8008ee:	4a                   	dec    %edx
  8008ef:	40                   	inc    %eax
  8008f0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	74 14                	je     800909 <strncmp+0x2a>
  8008f5:	8a 18                	mov    (%eax),%bl
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	74 04                	je     8008ff <strncmp+0x20>
  8008fb:	3a 19                	cmp    (%ecx),%bl
  8008fd:	74 ef                	je     8008ee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 00             	movzbl (%eax),%eax
  800902:	0f b6 11             	movzbl (%ecx),%edx
  800905:	29 d0                	sub    %edx,%eax
  800907:	eb 05                	jmp    80090e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091a:	eb 05                	jmp    800921 <strchr+0x10>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 0c                	je     80092c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f5                	jne    80091c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800937:	eb 05                	jmp    80093e <strfind+0x10>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 07                	je     800944 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093d:	40                   	inc    %eax
  80093e:	8a 10                	mov    (%eax),%dl
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f5                	jne    800939 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	57                   	push   %edi
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800955:	85 c9                	test   %ecx,%ecx
  800957:	74 30                	je     800989 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800959:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095f:	75 25                	jne    800986 <memset+0x40>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 20                	jne    800986 <memset+0x40>
		c &= 0xFF;
  800966:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 08             	shl    $0x8,%ebx
  80096e:	89 d6                	mov    %edx,%esi
  800970:	c1 e6 18             	shl    $0x18,%esi
  800973:	89 d0                	mov    %edx,%eax
  800975:	c1 e0 10             	shl    $0x10,%eax
  800978:	09 f0                	or     %esi,%eax
  80097a:	09 d0                	or     %edx,%eax
  80097c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800981:	fc                   	cld    
  800982:	f3 ab                	rep stos %eax,%es:(%edi)
  800984:	eb 03                	jmp    800989 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800986:	fc                   	cld    
  800987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800989:	89 f8                	mov    %edi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099e:	39 c6                	cmp    %eax,%esi
  8009a0:	73 34                	jae    8009d6 <memmove+0x46>
  8009a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a5:	39 d0                	cmp    %edx,%eax
  8009a7:	73 2d                	jae    8009d6 <memmove+0x46>
		s += n;
		d += n;
  8009a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	f6 c2 03             	test   $0x3,%dl
  8009af:	75 1b                	jne    8009cc <memmove+0x3c>
  8009b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b7:	75 13                	jne    8009cc <memmove+0x3c>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0e                	jne    8009cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 07                	jmp    8009d3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cc:	4f                   	dec    %edi
  8009cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d0:	fd                   	std    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d3:	fc                   	cld    
  8009d4:	eb 20                	jmp    8009f6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009dc:	75 13                	jne    8009f1 <memmove+0x61>
  8009de:	a8 03                	test   $0x3,%al
  8009e0:	75 0f                	jne    8009f1 <memmove+0x61>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	75 0a                	jne    8009f1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ea:	89 c7                	mov    %eax,%edi
  8009ec:	fc                   	cld    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 05                	jmp    8009f6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
  800a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 77 ff ff ff       	call   800990 <memmove>
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	eb 16                	jmp    800a47 <memcmp+0x2c>
		if (*s1 != *s2)
  800a31:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a34:	42                   	inc    %edx
  800a35:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a39:	38 c8                	cmp    %cl,%al
  800a3b:	74 0a                	je     800a47 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c0             	movzbl %al,%eax
  800a40:	0f b6 c9             	movzbl %cl,%ecx
  800a43:	29 c8                	sub    %ecx,%eax
  800a45:	eb 09                	jmp    800a50 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	39 da                	cmp    %ebx,%edx
  800a49:	75 e6                	jne    800a31 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a63:	eb 05                	jmp    800a6a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a65:	38 08                	cmp    %cl,(%eax)
  800a67:	74 05                	je     800a6e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a69:	40                   	inc    %eax
  800a6a:	39 d0                	cmp    %edx,%eax
  800a6c:	72 f7                	jb     800a65 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 01                	jmp    800a7f <strtol+0xf>
		s++;
  800a7e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	8a 02                	mov    (%edx),%al
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f9                	je     800a7e <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f5                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	75 08                	jne    800a95 <strtol+0x25>
		s++;
  800a8d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a93:	eb 13                	jmp    800aa8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	75 0a                	jne    800aa3 <strtol+0x33>
		s++, neg = 1;
  800a99:	8d 52 01             	lea    0x1(%edx),%edx
  800a9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa1:	eb 05                	jmp    800aa8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	74 05                	je     800ab1 <strtol+0x41>
  800aac:	83 fb 10             	cmp    $0x10,%ebx
  800aaf:	75 28                	jne    800ad9 <strtol+0x69>
  800ab1:	8a 02                	mov    (%edx),%al
  800ab3:	3c 30                	cmp    $0x30,%al
  800ab5:	75 10                	jne    800ac7 <strtol+0x57>
  800ab7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abb:	75 0a                	jne    800ac7 <strtol+0x57>
		s += 2, base = 16;
  800abd:	83 c2 02             	add    $0x2,%edx
  800ac0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac5:	eb 12                	jmp    800ad9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	75 0e                	jne    800ad9 <strtol+0x69>
  800acb:	3c 30                	cmp    $0x30,%al
  800acd:	75 05                	jne    800ad4 <strtol+0x64>
		s++, base = 8;
  800acf:	42                   	inc    %edx
  800ad0:	b3 08                	mov    $0x8,%bl
  800ad2:	eb 05                	jmp    800ad9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae0:	8a 0a                	mov    (%edx),%cl
  800ae2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae5:	80 fb 09             	cmp    $0x9,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x82>
			dig = *s - '0';
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 30             	sub    $0x30,%ecx
  800af0:	eb 1e                	jmp    800b10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 57             	sub    $0x57,%ecx
  800b00:	eb 0e                	jmp    800b10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 12                	ja     800b1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0a:	0f be c9             	movsbl %cl,%ecx
  800b0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b10:	39 f1                	cmp    %esi,%ecx
  800b12:	7d 0c                	jge    800b20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b14:	42                   	inc    %edx
  800b15:	0f af c6             	imul   %esi,%eax
  800b18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1a:	eb c4                	jmp    800ae0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	89 c1                	mov    %eax,%ecx
  800b1e:	eb 02                	jmp    800b22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b26:	74 05                	je     800b2d <strtol+0xbd>
		*endptr = (char *) s;
  800b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2d:	85 ff                	test   %edi,%edi
  800b2f:	74 04                	je     800b35 <strtol+0xc5>
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	f7 d8                	neg    %eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
	...

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 28                	jle    800bc3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800bae:	00 
  800baf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb6:	00 
  800bb7:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800bbe:	e8 91 f5 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc3:	83 c4 2c             	add    $0x2c,%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdb:	89 d1                	mov    %edx,%ecx
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_yield>:

void
sys_yield(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	be 00 00 00 00       	mov    $0x0,%esi
  800c17:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 f7                	mov    %esi,%edi
  800c27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 28                	jle    800c55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c38:	00 
  800c39:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800c40:	00 
  800c41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c48:	00 
  800c49:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800c50:	e8 ff f4 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c55:	83 c4 2c             	add    $0x2c,%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 28                	jle    800ca8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800c93:	00 
  800c94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9b:	00 
  800c9c:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800ca3:	e8 ac f4 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca8:	83 c4 2c             	add    $0x2c,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 df                	mov    %ebx,%edi
  800ccb:	89 de                	mov    %ebx,%esi
  800ccd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 28                	jle    800cfb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cde:	00 
  800cdf:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cee:	00 
  800cef:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800cf6:	e8 59 f4 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfb:	83 c4 2c             	add    $0x2c,%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 28                	jle    800d4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d31:	00 
  800d32:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800d39:	00 
  800d3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d41:	00 
  800d42:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800d49:	e8 06 f4 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4e:	83 c4 2c             	add    $0x2c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d64:	b8 09 00 00 00       	mov    $0x9,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 df                	mov    %ebx,%edi
  800d71:	89 de                	mov    %ebx,%esi
  800d73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 28                	jle    800da1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d84:	00 
  800d85:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d94:	00 
  800d95:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800d9c:	e8 b3 f3 ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da1:	83 c4 2c             	add    $0x2c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800def:	e8 60 f3 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df4:	83 c4 2c             	add    $0x2c,%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	be 00 00 00 00       	mov    $0x0,%esi
  800e07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	89 cb                	mov    %ecx,%ebx
  800e37:	89 cf                	mov    %ecx,%edi
  800e39:	89 ce                	mov    %ecx,%esi
  800e3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	7e 28                	jle    800e69 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e45:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 08 ff 23 80 	movl   $0x8023ff,0x8(%esp)
  800e54:	00 
  800e55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5c:	00 
  800e5d:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  800e64:	e8 eb f2 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e69:	83 c4 2c             	add    $0x2c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    
  800e71:	00 00                	add    %al,(%eax)
	...

00800e74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e7a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e81:	0f 85 80 00 00 00    	jne    800f07 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800e87:	a1 04 40 80 00       	mov    0x804004,%eax
  800e8c:	8b 40 48             	mov    0x48(%eax),%eax
  800e8f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e9e:	ee 
  800e9f:	89 04 24             	mov    %eax,(%esp)
  800ea2:	e8 62 fd ff ff       	call   800c09 <sys_page_alloc>
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 20                	jns    800ecb <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800eab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eaf:	c7 44 24 08 2c 24 80 	movl   $0x80242c,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800ebe:	00 
  800ebf:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  800ec6:	e8 89 f2 ff ff       	call   800154 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800ecb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ed0:	8b 40 48             	mov    0x48(%eax),%eax
  800ed3:	c7 44 24 04 14 0f 80 	movl   $0x800f14,0x4(%esp)
  800eda:	00 
  800edb:	89 04 24             	mov    %eax,(%esp)
  800ede:	e8 c6 fe ff ff       	call   800da9 <sys_env_set_pgfault_upcall>
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	79 20                	jns    800f07 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800ee7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eeb:	c7 44 24 08 58 24 80 	movl   $0x802458,0x8(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800efa:	00 
  800efb:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  800f02:	e8 4d f2 ff ff       	call   800154 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    
  800f11:	00 00                	add    %al,(%eax)
	...

00800f14 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f14:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f15:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f1a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f1c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  800f1f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800f23:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800f25:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800f28:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800f29:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  800f2c:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  800f2e:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800f31:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800f32:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800f35:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f36:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800f37:	c3                   	ret    

00800f38 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	05 00 00 00 30       	add    $0x30000000,%eax
  800f43:	c1 e8 0c             	shr    $0xc,%eax
}
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	89 04 24             	mov    %eax,(%esp)
  800f54:	e8 df ff ff ff       	call   800f38 <fd2num>
  800f59:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f5e:	c1 e0 0c             	shl    $0xc,%eax
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	53                   	push   %ebx
  800f67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f6a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f6f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f71:	89 c2                	mov    %eax,%edx
  800f73:	c1 ea 16             	shr    $0x16,%edx
  800f76:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f7d:	f6 c2 01             	test   $0x1,%dl
  800f80:	74 11                	je     800f93 <fd_alloc+0x30>
  800f82:	89 c2                	mov    %eax,%edx
  800f84:	c1 ea 0c             	shr    $0xc,%edx
  800f87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8e:	f6 c2 01             	test   $0x1,%dl
  800f91:	75 09                	jne    800f9c <fd_alloc+0x39>
			*fd_store = fd;
  800f93:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f95:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9a:	eb 17                	jmp    800fb3 <fd_alloc+0x50>
  800f9c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fa1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fa6:	75 c7                	jne    800f6f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fb3:	5b                   	pop    %ebx
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fbc:	83 f8 1f             	cmp    $0x1f,%eax
  800fbf:	77 36                	ja     800ff7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fc1:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fc6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	c1 ea 16             	shr    $0x16,%edx
  800fce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fd5:	f6 c2 01             	test   $0x1,%dl
  800fd8:	74 24                	je     800ffe <fd_lookup+0x48>
  800fda:	89 c2                	mov    %eax,%edx
  800fdc:	c1 ea 0c             	shr    $0xc,%edx
  800fdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	74 1a                	je     801005 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800feb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fee:	89 02                	mov    %eax,(%edx)
	return 0;
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff5:	eb 13                	jmp    80100a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ffc:	eb 0c                	jmp    80100a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ffe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801003:	eb 05                	jmp    80100a <fd_lookup+0x54>
  801005:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	53                   	push   %ebx
  801010:	83 ec 14             	sub    $0x14,%esp
  801013:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801016:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801019:	ba 00 00 00 00       	mov    $0x0,%edx
  80101e:	eb 0e                	jmp    80102e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801020:	39 08                	cmp    %ecx,(%eax)
  801022:	75 09                	jne    80102d <dev_lookup+0x21>
			*dev = devtab[i];
  801024:	89 03                	mov    %eax,(%ebx)
			return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 33                	jmp    801060 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80102d:	42                   	inc    %edx
  80102e:	8b 04 95 18 25 80 00 	mov    0x802518(,%edx,4),%eax
  801035:	85 c0                	test   %eax,%eax
  801037:	75 e7                	jne    801020 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801039:	a1 04 40 80 00       	mov    0x804004,%eax
  80103e:	8b 40 48             	mov    0x48(%eax),%eax
  801041:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801045:	89 44 24 04          	mov    %eax,0x4(%esp)
  801049:	c7 04 24 98 24 80 00 	movl   $0x802498,(%esp)
  801050:	e8 f7 f1 ff ff       	call   80024c <cprintf>
	*dev = 0;
  801055:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80105b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801060:	83 c4 14             	add    $0x14,%esp
  801063:	5b                   	pop    %ebx
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
  80106b:	83 ec 30             	sub    $0x30,%esp
  80106e:	8b 75 08             	mov    0x8(%ebp),%esi
  801071:	8a 45 0c             	mov    0xc(%ebp),%al
  801074:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801077:	89 34 24             	mov    %esi,(%esp)
  80107a:	e8 b9 fe ff ff       	call   800f38 <fd2num>
  80107f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801082:	89 54 24 04          	mov    %edx,0x4(%esp)
  801086:	89 04 24             	mov    %eax,(%esp)
  801089:	e8 28 ff ff ff       	call   800fb6 <fd_lookup>
  80108e:	89 c3                	mov    %eax,%ebx
  801090:	85 c0                	test   %eax,%eax
  801092:	78 05                	js     801099 <fd_close+0x33>
	    || fd != fd2)
  801094:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801097:	74 0d                	je     8010a6 <fd_close+0x40>
		return (must_exist ? r : 0);
  801099:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80109d:	75 46                	jne    8010e5 <fd_close+0x7f>
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a4:	eb 3f                	jmp    8010e5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ad:	8b 06                	mov    (%esi),%eax
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 55 ff ff ff       	call   80100c <dev_lookup>
  8010b7:	89 c3                	mov    %eax,%ebx
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 18                	js     8010d5 <fd_close+0x6f>
		if (dev->dev_close)
  8010bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c0:	8b 40 10             	mov    0x10(%eax),%eax
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	74 09                	je     8010d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010c7:	89 34 24             	mov    %esi,(%esp)
  8010ca:	ff d0                	call   *%eax
  8010cc:	89 c3                	mov    %eax,%ebx
  8010ce:	eb 05                	jmp    8010d5 <fd_close+0x6f>
		else
			r = 0;
  8010d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e0:	e8 cb fb ff ff       	call   800cb0 <sys_page_unmap>
	return r;
}
  8010e5:	89 d8                	mov    %ebx,%eax
  8010e7:	83 c4 30             	add    $0x30,%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	89 04 24             	mov    %eax,(%esp)
  801101:	e8 b0 fe ff ff       	call   800fb6 <fd_lookup>
  801106:	85 c0                	test   %eax,%eax
  801108:	78 13                	js     80111d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80110a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801111:	00 
  801112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 49 ff ff ff       	call   801066 <fd_close>
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <close_all>:

void
close_all(void)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	53                   	push   %ebx
  801123:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801126:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80112b:	89 1c 24             	mov    %ebx,(%esp)
  80112e:	e8 bb ff ff ff       	call   8010ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801133:	43                   	inc    %ebx
  801134:	83 fb 20             	cmp    $0x20,%ebx
  801137:	75 f2                	jne    80112b <close_all+0xc>
		close(i);
}
  801139:	83 c4 14             	add    $0x14,%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 4c             	sub    $0x4c,%esp
  801148:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80114b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 59 fe ff ff       	call   800fb6 <fd_lookup>
  80115d:	89 c3                	mov    %eax,%ebx
  80115f:	85 c0                	test   %eax,%eax
  801161:	0f 88 e1 00 00 00    	js     801248 <dup+0x109>
		return r;
	close(newfdnum);
  801167:	89 3c 24             	mov    %edi,(%esp)
  80116a:	e8 7f ff ff ff       	call   8010ee <close>

	newfd = INDEX2FD(newfdnum);
  80116f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801175:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801178:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 c5 fd ff ff       	call   800f48 <fd2data>
  801183:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801185:	89 34 24             	mov    %esi,(%esp)
  801188:	e8 bb fd ff ff       	call   800f48 <fd2data>
  80118d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801190:	89 d8                	mov    %ebx,%eax
  801192:	c1 e8 16             	shr    $0x16,%eax
  801195:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119c:	a8 01                	test   $0x1,%al
  80119e:	74 46                	je     8011e6 <dup+0xa7>
  8011a0:	89 d8                	mov    %ebx,%eax
  8011a2:	c1 e8 0c             	shr    $0xc,%eax
  8011a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ac:	f6 c2 01             	test   $0x1,%dl
  8011af:	74 35                	je     8011e6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cf:	00 
  8011d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011db:	e8 7d fa ff ff       	call   800c5d <sys_page_map>
  8011e0:	89 c3                	mov    %eax,%ebx
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 3b                	js     801221 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 0c             	shr    $0xc,%edx
  8011ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801203:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80120a:	00 
  80120b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801216:	e8 42 fa ff ff       	call   800c5d <sys_page_map>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 25                	jns    801246 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801221:	89 74 24 04          	mov    %esi,0x4(%esp)
  801225:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122c:	e8 7f fa ff ff       	call   800cb0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801231:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123f:	e8 6c fa ff ff       	call   800cb0 <sys_page_unmap>
	return r;
  801244:	eb 02                	jmp    801248 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801246:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801248:	89 d8                	mov    %ebx,%eax
  80124a:	83 c4 4c             	add    $0x4c,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 24             	sub    $0x24,%esp
  801259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	89 1c 24             	mov    %ebx,(%esp)
  801266:	e8 4b fd ff ff       	call   800fb6 <fd_lookup>
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 6d                	js     8012dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	8b 00                	mov    (%eax),%eax
  80127b:	89 04 24             	mov    %eax,(%esp)
  80127e:	e8 89 fd ff ff       	call   80100c <dev_lookup>
  801283:	85 c0                	test   %eax,%eax
  801285:	78 55                	js     8012dc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128a:	8b 50 08             	mov    0x8(%eax),%edx
  80128d:	83 e2 03             	and    $0x3,%edx
  801290:	83 fa 01             	cmp    $0x1,%edx
  801293:	75 23                	jne    8012b8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801295:	a1 04 40 80 00       	mov    0x804004,%eax
  80129a:	8b 40 48             	mov    0x48(%eax),%eax
  80129d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  8012ac:	e8 9b ef ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb 24                	jmp    8012dc <read+0x8a>
	}
	if (!dev->dev_read)
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	8b 52 08             	mov    0x8(%edx),%edx
  8012be:	85 d2                	test   %edx,%edx
  8012c0:	74 15                	je     8012d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	ff d2                	call   *%edx
  8012d5:	eb 05                	jmp    8012dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012dc:	83 c4 24             	add    $0x24,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 1c             	sub    $0x1c,%esp
  8012eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f6:	eb 23                	jmp    80131b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f8:	89 f0                	mov    %esi,%eax
  8012fa:	29 d8                	sub    %ebx,%eax
  8012fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801300:	8b 45 0c             	mov    0xc(%ebp),%eax
  801303:	01 d8                	add    %ebx,%eax
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	89 3c 24             	mov    %edi,(%esp)
  80130c:	e8 41 ff ff ff       	call   801252 <read>
		if (m < 0)
  801311:	85 c0                	test   %eax,%eax
  801313:	78 10                	js     801325 <readn+0x43>
			return m;
		if (m == 0)
  801315:	85 c0                	test   %eax,%eax
  801317:	74 0a                	je     801323 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801319:	01 c3                	add    %eax,%ebx
  80131b:	39 f3                	cmp    %esi,%ebx
  80131d:	72 d9                	jb     8012f8 <readn+0x16>
  80131f:	89 d8                	mov    %ebx,%eax
  801321:	eb 02                	jmp    801325 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801323:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801325:	83 c4 1c             	add    $0x1c,%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 24             	sub    $0x24,%esp
  801334:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133e:	89 1c 24             	mov    %ebx,(%esp)
  801341:	e8 70 fc ff ff       	call   800fb6 <fd_lookup>
  801346:	85 c0                	test   %eax,%eax
  801348:	78 68                	js     8013b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	8b 00                	mov    (%eax),%eax
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	e8 ae fc ff ff       	call   80100c <dev_lookup>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 50                	js     8013b2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801365:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801369:	75 23                	jne    80138e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80136b:	a1 04 40 80 00       	mov    0x804004,%eax
  801370:	8b 40 48             	mov    0x48(%eax),%eax
  801373:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  801382:	e8 c5 ee ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138c:	eb 24                	jmp    8013b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80138e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801391:	8b 52 0c             	mov    0xc(%edx),%edx
  801394:	85 d2                	test   %edx,%edx
  801396:	74 15                	je     8013ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801398:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80139b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a6:	89 04 24             	mov    %eax,(%esp)
  8013a9:	ff d2                	call   *%edx
  8013ab:	eb 05                	jmp    8013b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013b2:	83 c4 24             	add    $0x24,%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 e6 fb ff ff       	call   800fb6 <fd_lookup>
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 0e                	js     8013e2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 24             	sub    $0x24,%esp
  8013eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f5:	89 1c 24             	mov    %ebx,(%esp)
  8013f8:	e8 b9 fb ff ff       	call   800fb6 <fd_lookup>
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 61                	js     801462 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801401:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140b:	8b 00                	mov    (%eax),%eax
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	e8 f7 fb ff ff       	call   80100c <dev_lookup>
  801415:	85 c0                	test   %eax,%eax
  801417:	78 49                	js     801462 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801420:	75 23                	jne    801445 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801422:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801427:	8b 40 48             	mov    0x48(%eax),%eax
  80142a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80142e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801432:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  801439:	e8 0e ee ff ff       	call   80024c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80143e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801443:	eb 1d                	jmp    801462 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801445:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801448:	8b 52 18             	mov    0x18(%edx),%edx
  80144b:	85 d2                	test   %edx,%edx
  80144d:	74 0e                	je     80145d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80144f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801452:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	ff d2                	call   *%edx
  80145b:	eb 05                	jmp    801462 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80145d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801462:	83 c4 24             	add    $0x24,%esp
  801465:	5b                   	pop    %ebx
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 24             	sub    $0x24,%esp
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	89 04 24             	mov    %eax,(%esp)
  80147f:	e8 32 fb ff ff       	call   800fb6 <fd_lookup>
  801484:	85 c0                	test   %eax,%eax
  801486:	78 52                	js     8014da <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	8b 00                	mov    (%eax),%eax
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	e8 70 fb ff ff       	call   80100c <dev_lookup>
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 3a                	js     8014da <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014a7:	74 2c                	je     8014d5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014b3:	00 00 00 
	stat->st_isdir = 0;
  8014b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014bd:	00 00 00 
	stat->st_dev = dev;
  8014c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014cd:	89 14 24             	mov    %edx,(%esp)
  8014d0:	ff 50 14             	call   *0x14(%eax)
  8014d3:	eb 05                	jmp    8014da <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014da:	83 c4 24             	add    $0x24,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ef:	00 
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 fe 01 00 00       	call   8016f9 <open>
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 1b                	js     80151c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	89 1c 24             	mov    %ebx,(%esp)
  80150b:	e8 58 ff ff ff       	call   801468 <fstat>
  801510:	89 c6                	mov    %eax,%esi
	close(fd);
  801512:	89 1c 24             	mov    %ebx,(%esp)
  801515:	e8 d4 fb ff ff       	call   8010ee <close>
	return r;
  80151a:	89 f3                	mov    %esi,%ebx
}
  80151c:	89 d8                	mov    %ebx,%eax
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	5b                   	pop    %ebx
  801522:	5e                   	pop    %esi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    
  801525:	00 00                	add    %al,(%eax)
	...

00801528 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 10             	sub    $0x10,%esp
  801530:	89 c3                	mov    %eax,%ebx
  801532:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801534:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80153b:	75 11                	jne    80154e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80153d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801544:	e8 38 08 00 00       	call   801d81 <ipc_find_env>
  801549:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80154e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801555:	00 
  801556:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80155d:	00 
  80155e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801562:	a1 00 40 80 00       	mov    0x804000,%eax
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	e8 a8 07 00 00       	call   801d17 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80156f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801576:	00 
  801577:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801582:	e8 29 07 00 00       	call   801cb0 <ipc_recv>
}
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801594:	8b 45 08             	mov    0x8(%ebp),%eax
  801597:	8b 40 0c             	mov    0xc(%eax),%eax
  80159a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80159f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8015b1:	e8 72 ff ff ff       	call   801528 <fsipc>
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015be:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8015d3:	e8 50 ff ff ff       	call   801528 <fsipc>
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 14             	sub    $0x14,%esp
  8015e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8015f9:	e8 2a ff ff ff       	call   801528 <fsipc>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 2b                	js     80162d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801602:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801609:	00 
  80160a:	89 1c 24             	mov    %ebx,(%esp)
  80160d:	e8 05 f2 ff ff       	call   800817 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801612:	a1 80 50 80 00       	mov    0x805080,%eax
  801617:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80161d:	a1 84 50 80 00       	mov    0x805084,%eax
  801622:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801628:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162d:	83 c4 14             	add    $0x14,%esp
  801630:	5b                   	pop    %ebx
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801639:	c7 44 24 08 28 25 80 	movl   $0x802528,0x8(%esp)
  801640:	00 
  801641:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801648:	00 
  801649:	c7 04 24 46 25 80 00 	movl   $0x802546,(%esp)
  801650:	e8 ff ea ff ff       	call   800154 <_panic>

00801655 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	83 ec 10             	sub    $0x10,%esp
  80165d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	8b 40 0c             	mov    0xc(%eax),%eax
  801666:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80166b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801671:	ba 00 00 00 00       	mov    $0x0,%edx
  801676:	b8 03 00 00 00       	mov    $0x3,%eax
  80167b:	e8 a8 fe ff ff       	call   801528 <fsipc>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	85 c0                	test   %eax,%eax
  801684:	78 6a                	js     8016f0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801686:	39 c6                	cmp    %eax,%esi
  801688:	73 24                	jae    8016ae <devfile_read+0x59>
  80168a:	c7 44 24 0c 51 25 80 	movl   $0x802551,0xc(%esp)
  801691:	00 
  801692:	c7 44 24 08 58 25 80 	movl   $0x802558,0x8(%esp)
  801699:	00 
  80169a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016a1:	00 
  8016a2:	c7 04 24 46 25 80 00 	movl   $0x802546,(%esp)
  8016a9:	e8 a6 ea ff ff       	call   800154 <_panic>
	assert(r <= PGSIZE);
  8016ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016b3:	7e 24                	jle    8016d9 <devfile_read+0x84>
  8016b5:	c7 44 24 0c 6d 25 80 	movl   $0x80256d,0xc(%esp)
  8016bc:	00 
  8016bd:	c7 44 24 08 58 25 80 	movl   $0x802558,0x8(%esp)
  8016c4:	00 
  8016c5:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016cc:	00 
  8016cd:	c7 04 24 46 25 80 00 	movl   $0x802546,(%esp)
  8016d4:	e8 7b ea ff ff       	call   800154 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016dd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016e4:	00 
  8016e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e8:	89 04 24             	mov    %eax,(%esp)
  8016eb:	e8 a0 f2 ff ff       	call   800990 <memmove>
	return r;
}
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 20             	sub    $0x20,%esp
  801701:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801704:	89 34 24             	mov    %esi,(%esp)
  801707:	e8 d8 f0 ff ff       	call   8007e4 <strlen>
  80170c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801711:	7f 60                	jg     801773 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	89 04 24             	mov    %eax,(%esp)
  801719:	e8 45 f8 ff ff       	call   800f63 <fd_alloc>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	85 c0                	test   %eax,%eax
  801722:	78 54                	js     801778 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801724:	89 74 24 04          	mov    %esi,0x4(%esp)
  801728:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80172f:	e8 e3 f0 ff ff       	call   800817 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801734:	8b 45 0c             	mov    0xc(%ebp),%eax
  801737:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80173c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173f:	b8 01 00 00 00       	mov    $0x1,%eax
  801744:	e8 df fd ff ff       	call   801528 <fsipc>
  801749:	89 c3                	mov    %eax,%ebx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	79 15                	jns    801764 <open+0x6b>
		fd_close(fd, 0);
  80174f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801756:	00 
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	89 04 24             	mov    %eax,(%esp)
  80175d:	e8 04 f9 ff ff       	call   801066 <fd_close>
		return r;
  801762:	eb 14                	jmp    801778 <open+0x7f>
	}

	return fd2num(fd);
  801764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801767:	89 04 24             	mov    %eax,(%esp)
  80176a:	e8 c9 f7 ff ff       	call   800f38 <fd2num>
  80176f:	89 c3                	mov    %eax,%ebx
  801771:	eb 05                	jmp    801778 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801773:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801778:	89 d8                	mov    %ebx,%eax
  80177a:	83 c4 20             	add    $0x20,%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
  80178c:	b8 08 00 00 00       	mov    $0x8,%eax
  801791:	e8 92 fd ff ff       	call   801528 <fsipc>
}
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 10             	sub    $0x10,%esp
  8017a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	e8 9a f7 ff ff       	call   800f48 <fd2data>
  8017ae:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8017b0:	c7 44 24 04 79 25 80 	movl   $0x802579,0x4(%esp)
  8017b7:	00 
  8017b8:	89 34 24             	mov    %esi,(%esp)
  8017bb:	e8 57 f0 ff ff       	call   800817 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c3:	2b 03                	sub    (%ebx),%eax
  8017c5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8017cb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8017d2:	00 00 00 
	stat->st_dev = &devpipe;
  8017d5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8017dc:	30 80 00 
	return 0;
}
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 14             	sub    $0x14,%esp
  8017f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801800:	e8 ab f4 ff ff       	call   800cb0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801805:	89 1c 24             	mov    %ebx,(%esp)
  801808:	e8 3b f7 ff ff       	call   800f48 <fd2data>
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801818:	e8 93 f4 ff ff       	call   800cb0 <sys_page_unmap>
}
  80181d:	83 c4 14             	add    $0x14,%esp
  801820:	5b                   	pop    %ebx
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	57                   	push   %edi
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	83 ec 2c             	sub    $0x2c,%esp
  80182c:	89 c7                	mov    %eax,%edi
  80182e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801831:	a1 04 40 80 00       	mov    0x804004,%eax
  801836:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801839:	89 3c 24             	mov    %edi,(%esp)
  80183c:	e8 87 05 00 00       	call   801dc8 <pageref>
  801841:	89 c6                	mov    %eax,%esi
  801843:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 7a 05 00 00       	call   801dc8 <pageref>
  80184e:	39 c6                	cmp    %eax,%esi
  801850:	0f 94 c0             	sete   %al
  801853:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801856:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80185c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80185f:	39 cb                	cmp    %ecx,%ebx
  801861:	75 08                	jne    80186b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801863:	83 c4 2c             	add    $0x2c,%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5f                   	pop    %edi
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80186b:	83 f8 01             	cmp    $0x1,%eax
  80186e:	75 c1                	jne    801831 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801870:	8b 42 58             	mov    0x58(%edx),%eax
  801873:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80187a:	00 
  80187b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801883:	c7 04 24 80 25 80 00 	movl   $0x802580,(%esp)
  80188a:	e8 bd e9 ff ff       	call   80024c <cprintf>
  80188f:	eb a0                	jmp    801831 <_pipeisclosed+0xe>

00801891 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	57                   	push   %edi
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
  801897:	83 ec 1c             	sub    $0x1c,%esp
  80189a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80189d:	89 34 24             	mov    %esi,(%esp)
  8018a0:	e8 a3 f6 ff ff       	call   800f48 <fd2data>
  8018a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8018ac:	eb 3c                	jmp    8018ea <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018ae:	89 da                	mov    %ebx,%edx
  8018b0:	89 f0                	mov    %esi,%eax
  8018b2:	e8 6c ff ff ff       	call   801823 <_pipeisclosed>
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	75 38                	jne    8018f3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018bb:	e8 2a f3 ff ff       	call   800bea <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8018c3:	8b 13                	mov    (%ebx),%edx
  8018c5:	83 c2 20             	add    $0x20,%edx
  8018c8:	39 d0                	cmp    %edx,%eax
  8018ca:	73 e2                	jae    8018ae <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8018d2:	89 c2                	mov    %eax,%edx
  8018d4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018da:	79 05                	jns    8018e1 <devpipe_write+0x50>
  8018dc:	4a                   	dec    %edx
  8018dd:	83 ca e0             	or     $0xffffffe0,%edx
  8018e0:	42                   	inc    %edx
  8018e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018e5:	40                   	inc    %eax
  8018e6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e9:	47                   	inc    %edi
  8018ea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018ed:	75 d1                	jne    8018c0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018ef:	89 f8                	mov    %edi,%eax
  8018f1:	eb 05                	jmp    8018f8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018f8:	83 c4 1c             	add    $0x1c,%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5f                   	pop    %edi
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	57                   	push   %edi
  801904:	56                   	push   %esi
  801905:	53                   	push   %ebx
  801906:	83 ec 1c             	sub    $0x1c,%esp
  801909:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80190c:	89 3c 24             	mov    %edi,(%esp)
  80190f:	e8 34 f6 ff ff       	call   800f48 <fd2data>
  801914:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801916:	be 00 00 00 00       	mov    $0x0,%esi
  80191b:	eb 3a                	jmp    801957 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80191d:	85 f6                	test   %esi,%esi
  80191f:	74 04                	je     801925 <devpipe_read+0x25>
				return i;
  801921:	89 f0                	mov    %esi,%eax
  801923:	eb 40                	jmp    801965 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801925:	89 da                	mov    %ebx,%edx
  801927:	89 f8                	mov    %edi,%eax
  801929:	e8 f5 fe ff ff       	call   801823 <_pipeisclosed>
  80192e:	85 c0                	test   %eax,%eax
  801930:	75 2e                	jne    801960 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801932:	e8 b3 f2 ff ff       	call   800bea <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801937:	8b 03                	mov    (%ebx),%eax
  801939:	3b 43 04             	cmp    0x4(%ebx),%eax
  80193c:	74 df                	je     80191d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80193e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801943:	79 05                	jns    80194a <devpipe_read+0x4a>
  801945:	48                   	dec    %eax
  801946:	83 c8 e0             	or     $0xffffffe0,%eax
  801949:	40                   	inc    %eax
  80194a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80194e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801951:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801954:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801956:	46                   	inc    %esi
  801957:	3b 75 10             	cmp    0x10(%ebp),%esi
  80195a:	75 db                	jne    801937 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80195c:	89 f0                	mov    %esi,%eax
  80195e:	eb 05                	jmp    801965 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801965:	83 c4 1c             	add    $0x1c,%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5f                   	pop    %edi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	57                   	push   %edi
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 3c             	sub    $0x3c,%esp
  801976:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801979:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 df f5 ff ff       	call   800f63 <fd_alloc>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	85 c0                	test   %eax,%eax
  801988:	0f 88 45 01 00 00    	js     801ad3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801995:	00 
  801996:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a4:	e8 60 f2 ff ff       	call   800c09 <sys_page_alloc>
  8019a9:	89 c3                	mov    %eax,%ebx
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	0f 88 20 01 00 00    	js     801ad3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8019b6:	89 04 24             	mov    %eax,(%esp)
  8019b9:	e8 a5 f5 ff ff       	call   800f63 <fd_alloc>
  8019be:	89 c3                	mov    %eax,%ebx
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	0f 88 f8 00 00 00    	js     801ac0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019cf:	00 
  8019d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019de:	e8 26 f2 ff ff       	call   800c09 <sys_page_alloc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	0f 88 d3 00 00 00    	js     801ac0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f0:	89 04 24             	mov    %eax,(%esp)
  8019f3:	e8 50 f5 ff ff       	call   800f48 <fd2data>
  8019f8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a01:	00 
  801a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0d:	e8 f7 f1 ff ff       	call   800c09 <sys_page_alloc>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 91 00 00 00    	js     801aad <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 21 f5 ff ff       	call   800f48 <fd2data>
  801a27:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a2e:	00 
  801a2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a3a:	00 
  801a3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a46:	e8 12 f2 ff ff       	call   800c5d <sys_page_map>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 4c                	js     801a9d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a51:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a5a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a6f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a74:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 b2 f4 ff ff       	call   800f38 <fd2num>
  801a86:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a8b:	89 04 24             	mov    %eax,(%esp)
  801a8e:	e8 a5 f4 ff ff       	call   800f38 <fd2num>
  801a93:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a96:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a9b:	eb 36                	jmp    801ad3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a9d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa8:	e8 03 f2 ff ff       	call   800cb0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801aad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abb:	e8 f0 f1 ff ff       	call   800cb0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ac0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ace:	e8 dd f1 ff ff       	call   800cb0 <sys_page_unmap>
    err:
	return r;
}
  801ad3:	89 d8                	mov    %ebx,%eax
  801ad5:	83 c4 3c             	add    $0x3c,%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	89 04 24             	mov    %eax,(%esp)
  801af0:	e8 c1 f4 ff ff       	call   800fb6 <fd_lookup>
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 15                	js     801b0e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afc:	89 04 24             	mov    %eax,(%esp)
  801aff:	e8 44 f4 ff ff       	call   800f48 <fd2data>
	return _pipeisclosed(fd, p);
  801b04:	89 c2                	mov    %eax,%edx
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	e8 15 fd ff ff       	call   801823 <_pipeisclosed>
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b20:	c7 44 24 04 98 25 80 	movl   $0x802598,0x4(%esp)
  801b27:	00 
  801b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 e4 ec ff ff       	call   800817 <strcpy>
	return 0;
}
  801b33:	b8 00 00 00 00       	mov    $0x0,%eax
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b46:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b4b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b51:	eb 30                	jmp    801b83 <devcons_write+0x49>
		m = n - tot;
  801b53:	8b 75 10             	mov    0x10(%ebp),%esi
  801b56:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b58:	83 fe 7f             	cmp    $0x7f,%esi
  801b5b:	76 05                	jbe    801b62 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b5d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b62:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b66:	03 45 0c             	add    0xc(%ebp),%eax
  801b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6d:	89 3c 24             	mov    %edi,(%esp)
  801b70:	e8 1b ee ff ff       	call   800990 <memmove>
		sys_cputs(buf, m);
  801b75:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b79:	89 3c 24             	mov    %edi,(%esp)
  801b7c:	e8 bb ef ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b81:	01 f3                	add    %esi,%ebx
  801b83:	89 d8                	mov    %ebx,%eax
  801b85:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b88:	72 c9                	jb     801b53 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b8a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b9f:	75 07                	jne    801ba8 <devcons_read+0x13>
  801ba1:	eb 25                	jmp    801bc8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ba3:	e8 42 f0 ff ff       	call   800bea <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ba8:	e8 ad ef ff ff       	call   800b5a <sys_cgetc>
  801bad:	85 c0                	test   %eax,%eax
  801baf:	74 f2                	je     801ba3 <devcons_read+0xe>
  801bb1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 1d                	js     801bd4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bb7:	83 f8 04             	cmp    $0x4,%eax
  801bba:	74 13                	je     801bcf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbf:	88 10                	mov    %dl,(%eax)
	return 1;
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	eb 0c                	jmp    801bd4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcd:	eb 05                	jmp    801bd4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bcf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801be2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801be9:	00 
  801bea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 47 ef ff ff       	call   800b3c <sys_cputs>
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <getchar>:

int
getchar(void)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bfd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c04:	00 
  801c05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c13:	e8 3a f6 ff ff       	call   801252 <read>
	if (r < 0)
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 0f                	js     801c2b <getchar+0x34>
		return r;
	if (r < 1)
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	7e 06                	jle    801c26 <getchar+0x2f>
		return -E_EOF;
	return c;
  801c20:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c24:	eb 05                	jmp    801c2b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c26:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	89 04 24             	mov    %eax,(%esp)
  801c40:	e8 71 f3 ff ff       	call   800fb6 <fd_lookup>
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 11                	js     801c5a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c52:	39 10                	cmp    %edx,(%eax)
  801c54:	0f 94 c0             	sete   %al
  801c57:	0f b6 c0             	movzbl %al,%eax
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <opencons>:

int
opencons(void)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 f6 f2 ff ff       	call   800f63 <fd_alloc>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 3c                	js     801cad <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c71:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c78:	00 
  801c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c87:	e8 7d ef ff ff       	call   800c09 <sys_page_alloc>
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 1d                	js     801cad <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c99:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ca5:	89 04 24             	mov    %eax,(%esp)
  801ca8:	e8 8b f2 ff ff       	call   800f38 <fd2num>
}
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    
	...

00801cb0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	56                   	push   %esi
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 10             	sub    $0x10,%esp
  801cb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	75 05                	jne    801cca <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801cc5:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801cca:	89 04 24             	mov    %eax,(%esp)
  801ccd:	e8 4d f1 ff ff       	call   800e1f <sys_ipc_recv>
	if (!err) {
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	75 26                	jne    801cfc <ipc_recv+0x4c>
		if (from_env_store) {
  801cd6:	85 f6                	test   %esi,%esi
  801cd8:	74 0a                	je     801ce4 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801cda:	a1 04 40 80 00       	mov    0x804004,%eax
  801cdf:	8b 40 74             	mov    0x74(%eax),%eax
  801ce2:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ce4:	85 db                	test   %ebx,%ebx
  801ce6:	74 0a                	je     801cf2 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801ce8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ced:	8b 40 78             	mov    0x78(%eax),%eax
  801cf0:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801cf2:	a1 04 40 80 00       	mov    0x804004,%eax
  801cf7:	8b 40 70             	mov    0x70(%eax),%eax
  801cfa:	eb 14                	jmp    801d10 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801cfc:	85 f6                	test   %esi,%esi
  801cfe:	74 06                	je     801d06 <ipc_recv+0x56>
		*from_env_store = 0;
  801d00:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801d06:	85 db                	test   %ebx,%ebx
  801d08:	74 06                	je     801d10 <ipc_recv+0x60>
		*perm_store = 0;
  801d0a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	57                   	push   %edi
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 1c             	sub    $0x1c,%esp
  801d20:	8b 75 10             	mov    0x10(%ebp),%esi
  801d23:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801d26:	85 f6                	test   %esi,%esi
  801d28:	75 05                	jne    801d2f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801d2a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801d2f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d33:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d41:	89 04 24             	mov    %eax,(%esp)
  801d44:	e8 b3 f0 ff ff       	call   800dfc <sys_ipc_try_send>
  801d49:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801d4b:	e8 9a ee ff ff       	call   800bea <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801d50:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801d53:	74 da                	je     801d2f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801d55:	85 db                	test   %ebx,%ebx
  801d57:	74 20                	je     801d79 <ipc_send+0x62>
		panic("send fail: %e", err);
  801d59:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d5d:	c7 44 24 08 a4 25 80 	movl   $0x8025a4,0x8(%esp)
  801d64:	00 
  801d65:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801d6c:	00 
  801d6d:	c7 04 24 b2 25 80 00 	movl   $0x8025b2,(%esp)
  801d74:	e8 db e3 ff ff       	call   800154 <_panic>
	}
	return;
}
  801d79:	83 c4 1c             	add    $0x1c,%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	53                   	push   %ebx
  801d85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d8d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d94:	89 c2                	mov    %eax,%edx
  801d96:	c1 e2 07             	shl    $0x7,%edx
  801d99:	29 ca                	sub    %ecx,%edx
  801d9b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801da1:	8b 52 50             	mov    0x50(%edx),%edx
  801da4:	39 da                	cmp    %ebx,%edx
  801da6:	75 0f                	jne    801db7 <ipc_find_env+0x36>
			return envs[i].env_id;
  801da8:	c1 e0 07             	shl    $0x7,%eax
  801dab:	29 c8                	sub    %ecx,%eax
  801dad:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801db2:	8b 40 40             	mov    0x40(%eax),%eax
  801db5:	eb 0c                	jmp    801dc3 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801db7:	40                   	inc    %eax
  801db8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dbd:	75 ce                	jne    801d8d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dbf:	66 b8 00 00          	mov    $0x0,%ax
}
  801dc3:	5b                   	pop    %ebx
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    
	...

00801dc8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dce:	89 c2                	mov    %eax,%edx
  801dd0:	c1 ea 16             	shr    $0x16,%edx
  801dd3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dda:	f6 c2 01             	test   $0x1,%dl
  801ddd:	74 1e                	je     801dfd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ddf:	c1 e8 0c             	shr    $0xc,%eax
  801de2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801de9:	a8 01                	test   $0x1,%al
  801deb:	74 17                	je     801e04 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ded:	c1 e8 0c             	shr    $0xc,%eax
  801df0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801df7:	ef 
  801df8:	0f b7 c0             	movzwl %ax,%eax
  801dfb:	eb 0c                	jmp    801e09 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  801e02:	eb 05                	jmp    801e09 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e04:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    
	...

00801e0c <__udivdi3>:
  801e0c:	55                   	push   %ebp
  801e0d:	57                   	push   %edi
  801e0e:	56                   	push   %esi
  801e0f:	83 ec 10             	sub    $0x10,%esp
  801e12:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e16:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e1e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801e22:	89 cd                	mov    %ecx,%ebp
  801e24:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	75 2c                	jne    801e58 <__udivdi3+0x4c>
  801e2c:	39 f9                	cmp    %edi,%ecx
  801e2e:	77 68                	ja     801e98 <__udivdi3+0x8c>
  801e30:	85 c9                	test   %ecx,%ecx
  801e32:	75 0b                	jne    801e3f <__udivdi3+0x33>
  801e34:	b8 01 00 00 00       	mov    $0x1,%eax
  801e39:	31 d2                	xor    %edx,%edx
  801e3b:	f7 f1                	div    %ecx
  801e3d:	89 c1                	mov    %eax,%ecx
  801e3f:	31 d2                	xor    %edx,%edx
  801e41:	89 f8                	mov    %edi,%eax
  801e43:	f7 f1                	div    %ecx
  801e45:	89 c7                	mov    %eax,%edi
  801e47:	89 f0                	mov    %esi,%eax
  801e49:	f7 f1                	div    %ecx
  801e4b:	89 c6                	mov    %eax,%esi
  801e4d:	89 f0                	mov    %esi,%eax
  801e4f:	89 fa                	mov    %edi,%edx
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    
  801e58:	39 f8                	cmp    %edi,%eax
  801e5a:	77 2c                	ja     801e88 <__udivdi3+0x7c>
  801e5c:	0f bd f0             	bsr    %eax,%esi
  801e5f:	83 f6 1f             	xor    $0x1f,%esi
  801e62:	75 4c                	jne    801eb0 <__udivdi3+0xa4>
  801e64:	39 f8                	cmp    %edi,%eax
  801e66:	bf 00 00 00 00       	mov    $0x0,%edi
  801e6b:	72 0a                	jb     801e77 <__udivdi3+0x6b>
  801e6d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e71:	0f 87 ad 00 00 00    	ja     801f24 <__udivdi3+0x118>
  801e77:	be 01 00 00 00       	mov    $0x1,%esi
  801e7c:	89 f0                	mov    %esi,%eax
  801e7e:	89 fa                	mov    %edi,%edx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    
  801e87:	90                   	nop
  801e88:	31 ff                	xor    %edi,%edi
  801e8a:	31 f6                	xor    %esi,%esi
  801e8c:	89 f0                	mov    %esi,%eax
  801e8e:	89 fa                	mov    %edi,%edx
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	5e                   	pop    %esi
  801e94:	5f                   	pop    %edi
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    
  801e97:	90                   	nop
  801e98:	89 fa                	mov    %edi,%edx
  801e9a:	89 f0                	mov    %esi,%eax
  801e9c:	f7 f1                	div    %ecx
  801e9e:	89 c6                	mov    %eax,%esi
  801ea0:	31 ff                	xor    %edi,%edi
  801ea2:	89 f0                	mov    %esi,%eax
  801ea4:	89 fa                	mov    %edi,%edx
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	89 f1                	mov    %esi,%ecx
  801eb2:	d3 e0                	shl    %cl,%eax
  801eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb8:	b8 20 00 00 00       	mov    $0x20,%eax
  801ebd:	29 f0                	sub    %esi,%eax
  801ebf:	89 ea                	mov    %ebp,%edx
  801ec1:	88 c1                	mov    %al,%cl
  801ec3:	d3 ea                	shr    %cl,%edx
  801ec5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801ec9:	09 ca                	or     %ecx,%edx
  801ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ecf:	89 f1                	mov    %esi,%ecx
  801ed1:	d3 e5                	shl    %cl,%ebp
  801ed3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801ed7:	89 fd                	mov    %edi,%ebp
  801ed9:	88 c1                	mov    %al,%cl
  801edb:	d3 ed                	shr    %cl,%ebp
  801edd:	89 fa                	mov    %edi,%edx
  801edf:	89 f1                	mov    %esi,%ecx
  801ee1:	d3 e2                	shl    %cl,%edx
  801ee3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ee7:	88 c1                	mov    %al,%cl
  801ee9:	d3 ef                	shr    %cl,%edi
  801eeb:	09 d7                	or     %edx,%edi
  801eed:	89 f8                	mov    %edi,%eax
  801eef:	89 ea                	mov    %ebp,%edx
  801ef1:	f7 74 24 08          	divl   0x8(%esp)
  801ef5:	89 d1                	mov    %edx,%ecx
  801ef7:	89 c7                	mov    %eax,%edi
  801ef9:	f7 64 24 0c          	mull   0xc(%esp)
  801efd:	39 d1                	cmp    %edx,%ecx
  801eff:	72 17                	jb     801f18 <__udivdi3+0x10c>
  801f01:	74 09                	je     801f0c <__udivdi3+0x100>
  801f03:	89 fe                	mov    %edi,%esi
  801f05:	31 ff                	xor    %edi,%edi
  801f07:	e9 41 ff ff ff       	jmp    801e4d <__udivdi3+0x41>
  801f0c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f10:	89 f1                	mov    %esi,%ecx
  801f12:	d3 e2                	shl    %cl,%edx
  801f14:	39 c2                	cmp    %eax,%edx
  801f16:	73 eb                	jae    801f03 <__udivdi3+0xf7>
  801f18:	8d 77 ff             	lea    -0x1(%edi),%esi
  801f1b:	31 ff                	xor    %edi,%edi
  801f1d:	e9 2b ff ff ff       	jmp    801e4d <__udivdi3+0x41>
  801f22:	66 90                	xchg   %ax,%ax
  801f24:	31 f6                	xor    %esi,%esi
  801f26:	e9 22 ff ff ff       	jmp    801e4d <__udivdi3+0x41>
	...

00801f2c <__umoddi3>:
  801f2c:	55                   	push   %ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	83 ec 20             	sub    $0x20,%esp
  801f32:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f36:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801f3a:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f3e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f42:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f46:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801f4a:	89 c7                	mov    %eax,%edi
  801f4c:	89 f2                	mov    %esi,%edx
  801f4e:	85 ed                	test   %ebp,%ebp
  801f50:	75 16                	jne    801f68 <__umoddi3+0x3c>
  801f52:	39 f1                	cmp    %esi,%ecx
  801f54:	0f 86 a6 00 00 00    	jbe    802000 <__umoddi3+0xd4>
  801f5a:	f7 f1                	div    %ecx
  801f5c:	89 d0                	mov    %edx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	83 c4 20             	add    $0x20,%esp
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    
  801f67:	90                   	nop
  801f68:	39 f5                	cmp    %esi,%ebp
  801f6a:	0f 87 ac 00 00 00    	ja     80201c <__umoddi3+0xf0>
  801f70:	0f bd c5             	bsr    %ebp,%eax
  801f73:	83 f0 1f             	xor    $0x1f,%eax
  801f76:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f7a:	0f 84 a8 00 00 00    	je     802028 <__umoddi3+0xfc>
  801f80:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f84:	d3 e5                	shl    %cl,%ebp
  801f86:	bf 20 00 00 00       	mov    $0x20,%edi
  801f8b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801f8f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f93:	89 f9                	mov    %edi,%ecx
  801f95:	d3 e8                	shr    %cl,%eax
  801f97:	09 e8                	or     %ebp,%eax
  801f99:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f9d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fa1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fa5:	d3 e0                	shl    %cl,%eax
  801fa7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fab:	89 f2                	mov    %esi,%edx
  801fad:	d3 e2                	shl    %cl,%edx
  801faf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801fb9:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fbd:	89 f9                	mov    %edi,%ecx
  801fbf:	d3 e8                	shr    %cl,%eax
  801fc1:	09 d0                	or     %edx,%eax
  801fc3:	d3 ee                	shr    %cl,%esi
  801fc5:	89 f2                	mov    %esi,%edx
  801fc7:	f7 74 24 18          	divl   0x18(%esp)
  801fcb:	89 d6                	mov    %edx,%esi
  801fcd:	f7 64 24 0c          	mull   0xc(%esp)
  801fd1:	89 c5                	mov    %eax,%ebp
  801fd3:	89 d1                	mov    %edx,%ecx
  801fd5:	39 d6                	cmp    %edx,%esi
  801fd7:	72 67                	jb     802040 <__umoddi3+0x114>
  801fd9:	74 75                	je     802050 <__umoddi3+0x124>
  801fdb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fdf:	29 e8                	sub    %ebp,%eax
  801fe1:	19 ce                	sbb    %ecx,%esi
  801fe3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fe7:	d3 e8                	shr    %cl,%eax
  801fe9:	89 f2                	mov    %esi,%edx
  801feb:	89 f9                	mov    %edi,%ecx
  801fed:	d3 e2                	shl    %cl,%edx
  801fef:	09 d0                	or     %edx,%eax
  801ff1:	89 f2                	mov    %esi,%edx
  801ff3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ff7:	d3 ea                	shr    %cl,%edx
  801ff9:	83 c4 20             	add    $0x20,%esp
  801ffc:	5e                   	pop    %esi
  801ffd:	5f                   	pop    %edi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    
  802000:	85 c9                	test   %ecx,%ecx
  802002:	75 0b                	jne    80200f <__umoddi3+0xe3>
  802004:	b8 01 00 00 00       	mov    $0x1,%eax
  802009:	31 d2                	xor    %edx,%edx
  80200b:	f7 f1                	div    %ecx
  80200d:	89 c1                	mov    %eax,%ecx
  80200f:	89 f0                	mov    %esi,%eax
  802011:	31 d2                	xor    %edx,%edx
  802013:	f7 f1                	div    %ecx
  802015:	89 f8                	mov    %edi,%eax
  802017:	e9 3e ff ff ff       	jmp    801f5a <__umoddi3+0x2e>
  80201c:	89 f2                	mov    %esi,%edx
  80201e:	83 c4 20             	add    $0x20,%esp
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 f5                	cmp    %esi,%ebp
  80202a:	72 04                	jb     802030 <__umoddi3+0x104>
  80202c:	39 f9                	cmp    %edi,%ecx
  80202e:	77 06                	ja     802036 <__umoddi3+0x10a>
  802030:	89 f2                	mov    %esi,%edx
  802032:	29 cf                	sub    %ecx,%edi
  802034:	19 ea                	sbb    %ebp,%edx
  802036:	89 f8                	mov    %edi,%eax
  802038:	83 c4 20             	add    $0x20,%esp
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    
  80203f:	90                   	nop
  802040:	89 d1                	mov    %edx,%ecx
  802042:	89 c5                	mov    %eax,%ebp
  802044:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802048:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80204c:	eb 8d                	jmp    801fdb <__umoddi3+0xaf>
  80204e:	66 90                	xchg   %ax,%ax
  802050:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802054:	72 ea                	jb     802040 <__umoddi3+0x114>
  802056:	89 f1                	mov    %esi,%ecx
  802058:	eb 81                	jmp    801fdb <__umoddi3+0xaf>
