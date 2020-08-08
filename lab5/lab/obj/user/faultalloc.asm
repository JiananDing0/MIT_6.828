
obj/user/faultalloc.debug:     file format elf32-i386


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
  800044:	c7 04 24 80 20 80 00 	movl   $0x802080,(%esp)
  80004b:	e8 10 02 00 00       	call   800260 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 ae 0b 00 00       	call   800c1d <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 8a 20 80 00 	movl   $0x80208a,(%esp)
  800092:	e8 d1 00 00 00       	call   800168 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 cc 20 80 	movl   $0x8020cc,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 1a 07 00 00       	call   8007cd <snprintf>
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
  8000c6:	e8 bd 0d 00 00       	call   800e88 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  8000da:	e8 81 01 00 00       	call   800260 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  8000ee:	e8 6d 01 00 00       	call   800260 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
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
  800106:	e8 d4 0a 00 00       	call   800bdf <sys_getenvid>
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
  800138:	e8 7c ff ff ff       	call   8000b9 <umain>

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
  800152:	e8 dc 0f 00 00       	call   801133 <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 2a 0a 00 00       	call   800b8d <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800170:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800173:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800179:	e8 61 0a 00 00       	call   800bdf <sys_getenvid>
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800181:	89 54 24 10          	mov    %edx,0x10(%esp)
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80018c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 f8 20 80 00 	movl   $0x8020f8,(%esp)
  80019b:	e8 c0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 50 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  8001af:	c7 04 24 b1 25 80 00 	movl   $0x8025b1,(%esp)
  8001b6:	e8 a5 00 00 00       	call   800260 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x53>
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	40                   	inc    %eax
  8001d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 60 09 00 00       	call   800b50 <sys_cputs>
		b->idx = 0;
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f6:	ff 43 04             	incl   0x4(%ebx)
}
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023b:	e8 82 01 00 00       	call   8003c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 f8 08 00 00       	call   800b50 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 87 ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    
	...

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 3c             	sub    $0x3c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d7                	mov    %edx,%edi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	85 c0                	test   %eax,%eax
  80029e:	75 08                	jne    8002a8 <printnum+0x2c>
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a6:	77 57                	ja     8002ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ac:	4b                   	dec    %ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	e8 46 1b 00 00       	call   801e20 <__udivdi3>
  8002da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 fa                	mov    %edi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 89 ff ff ff       	call   80027c <printnum>
  8002f3:	eb 0f                	jmp    800304 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	4b                   	dec    %ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f f1                	jg     8002f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	e8 13 1c 00 00       	call   801f40 <__umoddi3>
  80032d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800331:	0f be 80 1b 21 80 00 	movsbl 0x80211b(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 3c             	add    $0x3c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800386:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 08                	jae    800398 <sprintputch+0x18>
		*b->buf++ = ch;
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	88 0a                	mov    %cl,(%edx)
  800395:	42                   	inc    %edx
  800396:	89 10                	mov    %edx,(%eax)
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 02 00 00 00       	call   8003c2 <vprintfmt>
	va_end(ap);
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	57                   	push   %edi
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 4c             	sub    $0x4c,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d1:	eb 12                	jmp    8003e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	0f 84 8b 03 00 00    	je     800766 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	0f b6 06             	movzbl (%esi),%eax
  8003e8:	46                   	inc    %esi
  8003e9:	83 f8 25             	cmp    $0x25,%eax
  8003ec:	75 e5                	jne    8003d3 <vprintfmt+0x11>
  8003ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	eb 26                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800413:	eb 1d                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80041c:	eb 14                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800428:	eb 08                	jmp    800432 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80042d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	0f b6 06             	movzbl (%esi),%eax
  800435:	8d 56 01             	lea    0x1(%esi),%edx
  800438:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043b:	8a 16                	mov    (%esi),%dl
  80043d:	83 ea 23             	sub    $0x23,%edx
  800440:	80 fa 55             	cmp    $0x55,%dl
  800443:	0f 87 01 03 00 00    	ja     80074a <vprintfmt+0x388>
  800449:	0f b6 d2             	movzbl %dl,%edx
  80044c:	ff 24 95 60 22 80 00 	jmp    *0x802260(,%edx,4)
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800456:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800462:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800465:	8d 50 d0             	lea    -0x30(%eax),%edx
  800468:	83 fa 09             	cmp    $0x9,%edx
  80046b:	77 2a                	ja     800497 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046e:	eb eb                	jmp    80045b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047e:	eb 17                	jmp    800497 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800480:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800484:	78 98                	js     80041e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800489:	eb a7                	jmp    800432 <vprintfmt+0x70>
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800495:	eb 9b                	jmp    800432 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	79 95                	jns    800432 <vprintfmt+0x70>
  80049d:	eb 8b                	jmp    80042a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a3:	eb 8d                	jmp    800432 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bd:	e9 23 ff ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 02                	jns    8004d3 <vprintfmt+0x111>
  8004d1:	f7 d8                	neg    %eax
  8004d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x123>
  8004da:	8b 04 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 23                	jne    800508 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e9:	c7 44 24 08 33 21 80 	movl   $0x802133,0x8(%esp)
  8004f0:	00 
  8004f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 9a fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 dd fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800508:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050c:	c7 44 24 08 8a 25 80 	movl   $0x80258a,0x8(%esp)
  800513:	00 
  800514:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800518:	8b 55 08             	mov    0x8(%ebp),%edx
  80051b:	89 14 24             	mov    %edx,(%esp)
  80051e:	e8 77 fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ba fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
  80052b:	89 f9                	mov    %edi,%ecx
  80052d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 30                	mov    (%eax),%esi
  80053e:	85 f6                	test   %esi,%esi
  800540:	75 05                	jne    800547 <vprintfmt+0x185>
				p = "(null)";
  800542:	be 2c 21 80 00       	mov    $0x80212c,%esi
			if (width > 0 && padc != '-')
  800547:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054b:	0f 8e 84 00 00 00    	jle    8005d5 <vprintfmt+0x213>
  800551:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800555:	74 7e                	je     8005d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055b:	89 34 24             	mov    %esi,(%esp)
  80055e:	e8 ab 02 00 00       	call   80080e <strnlen>
  800563:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80056f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800572:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800575:	89 de                	mov    %ebx,%esi
  800577:	89 d3                	mov    %edx,%ebx
  800579:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0b                	jmp    800588 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80057d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800581:	89 3c 24             	mov    %edi,(%esp)
  800584:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	4b                   	dec    %ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f f1                	jg     80057d <vprintfmt+0x1bb>
  80058c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	79 05                	jns    8005a0 <vprintfmt+0x1de>
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a8:	eb 2b                	jmp    8005d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	74 18                	je     8005c8 <vprintfmt+0x206>
  8005b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b3:	83 fa 5e             	cmp    $0x5e,%edx
  8005b6:	76 10                	jbe    8005c8 <vprintfmt+0x206>
					putch('?', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
  8005c6:	eb 0a                	jmp    8005d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d5:	0f be 06             	movsbl (%esi),%eax
  8005d8:	46                   	inc    %esi
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	74 21                	je     8005fe <vprintfmt+0x23c>
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	78 c9                	js     8005aa <vprintfmt+0x1e8>
  8005e1:	4f                   	dec    %edi
  8005e2:	79 c6                	jns    8005aa <vprintfmt+0x1e8>
  8005e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e7:	89 de                	mov    %ebx,%esi
  8005e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ec:	eb 18                	jmp    800606 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fb:	4b                   	dec    %ebx
  8005fc:	eb 08                	jmp    800606 <vprintfmt+0x244>
  8005fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800601:	89 de                	mov    %ebx,%esi
  800603:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f e4                	jg     8005ee <vprintfmt+0x22c>
  80060a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80060d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800612:	e9 ce fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800617:	83 f9 01             	cmp    $0x1,%ecx
  80061a:	7e 10                	jle    80062c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 08             	lea    0x8(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	8b 78 04             	mov    0x4(%eax),%edi
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x290>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 12                	je     800642 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 30                	mov    (%eax),%esi
  80063b:	89 f7                	mov    %esi,%edi
  80063d:	c1 ff 1f             	sar    $0x1f,%edi
  800640:	eb 10                	jmp    800652 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 30                	mov    (%eax),%esi
  80064d:	89 f7                	mov    %esi,%edi
  80064f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800652:	85 ff                	test   %edi,%edi
  800654:	78 0a                	js     800660 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 ac 00 00 00       	jmp    80070c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800664:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066e:	f7 de                	neg    %esi
  800670:	83 d7 00             	adc    $0x0,%edi
  800673:	f7 df                	neg    %edi
			}
			base = 10;
  800675:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067a:	e9 8d 00 00 00       	jmp    80070c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067f:	89 ca                	mov    %ecx,%edx
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
  800684:	e8 bd fc ff ff       	call   800346 <getuint>
  800689:	89 c6                	mov    %eax,%esi
  80068b:	89 d7                	mov    %edx,%edi
			base = 10;
  80068d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800692:	eb 78                	jmp    80070c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c1:	e9 1f fd ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006eb:	8b 30                	mov    (%eax),%esi
  8006ed:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f7:	eb 13                	jmp    80070c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f9:	89 ca                	mov    %ecx,%edx
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 43 fc ff ff       	call   800346 <getuint>
  800703:	89 c6                	mov    %eax,%esi
  800705:	89 d7                	mov    %edx,%edi
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800710:	89 54 24 10          	mov    %edx,0x10(%esp)
  800714:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800717:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80071b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071f:	89 34 24             	mov    %esi,(%esp)
  800722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800726:	89 da                	mov    %ebx,%edx
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	e8 4c fb ff ff       	call   80027c <printnum>
			break;
  800730:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800733:	e9 ad fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800745:	e9 9b fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800755:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	eb 01                	jmp    80075b <vprintfmt+0x399>
  80075a:	4e                   	dec    %esi
  80075b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80075f:	75 f9                	jne    80075a <vprintfmt+0x398>
  800761:	e9 7f fc ff ff       	jmp    8003e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800766:	83 c4 4c             	add    $0x4c,%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 28             	sub    $0x28,%esp
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800781:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078b:	85 c0                	test   %eax,%eax
  80078d:	74 30                	je     8007bf <vsnprintf+0x51>
  80078f:	85 d2                	test   %edx,%edx
  800791:	7e 33                	jle    8007c6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079a:	8b 45 10             	mov    0x10(%ebp),%eax
  80079d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	c7 04 24 80 03 80 00 	movl   $0x800380,(%esp)
  8007af:	e8 0e fc ff ff       	call   8003c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bd:	eb 0c                	jmp    8007cb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb 05                	jmp    8007cb <vsnprintf+0x5d>
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	e8 7b ff ff ff       	call   80076e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    
  8007f5:	00 00                	add    %al,(%eax)
	...

008007f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	eb 01                	jmp    800806 <strlen+0xe>
		n++;
  800805:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080a:	75 f9                	jne    800805 <strlen+0xd>
		n++;
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
  80081c:	eb 01                	jmp    80081f <strnlen+0x11>
		n++;
  80081e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	39 d0                	cmp    %edx,%eax
  800821:	74 06                	je     800829 <strnlen+0x1b>
  800823:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800827:	75 f5                	jne    80081e <strnlen+0x10>
		n++;
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
  80083a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80083d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800840:	42                   	inc    %edx
  800841:	84 c9                	test   %cl,%cl
  800843:	75 f5                	jne    80083a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800845:	5b                   	pop    %ebx
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800852:	89 1c 24             	mov    %ebx,(%esp)
  800855:	e8 9e ff ff ff       	call   8007f8 <strlen>
	strcpy(dst + len, src);
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800861:	01 d8                	add    %ebx,%eax
  800863:	89 04 24             	mov    %eax,(%esp)
  800866:	e8 c0 ff ff ff       	call   80082b <strcpy>
	return dst;
}
  80086b:	89 d8                	mov    %ebx,%eax
  80086d:	83 c4 08             	add    $0x8,%esp
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
  800886:	eb 0c                	jmp    800894 <strncpy+0x21>
		*dst++ = *src;
  800888:	8a 1a                	mov    (%edx),%bl
  80088a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088d:	80 3a 01             	cmpb   $0x1,(%edx)
  800890:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800893:	41                   	inc    %ecx
  800894:	39 f1                	cmp    %esi,%ecx
  800896:	75 f0                	jne    800888 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	75 0a                	jne    8008b8 <strlcpy+0x1c>
  8008ae:	89 f0                	mov    %esi,%eax
  8008b0:	eb 1a                	jmp    8008cc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b2:	88 18                	mov    %bl,(%eax)
  8008b4:	40                   	inc    %eax
  8008b5:	41                   	inc    %ecx
  8008b6:	eb 02                	jmp    8008ba <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008ba:	4a                   	dec    %edx
  8008bb:	74 0a                	je     8008c7 <strlcpy+0x2b>
  8008bd:	8a 19                	mov    (%ecx),%bl
  8008bf:	84 db                	test   %bl,%bl
  8008c1:	75 ef                	jne    8008b2 <strlcpy+0x16>
  8008c3:	89 c2                	mov    %eax,%edx
  8008c5:	eb 02                	jmp    8008c9 <strlcpy+0x2d>
  8008c7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008c9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008cc:	29 f0                	sub    %esi,%eax
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008db:	eb 02                	jmp    8008df <strcmp+0xd>
		p++, q++;
  8008dd:	41                   	inc    %ecx
  8008de:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008df:	8a 01                	mov    (%ecx),%al
  8008e1:	84 c0                	test   %al,%al
  8008e3:	74 04                	je     8008e9 <strcmp+0x17>
  8008e5:	3a 02                	cmp    (%edx),%al
  8008e7:	74 f4                	je     8008dd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 c0             	movzbl %al,%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800900:	eb 03                	jmp    800905 <strncmp+0x12>
		n--, p++, q++;
  800902:	4a                   	dec    %edx
  800903:	40                   	inc    %eax
  800904:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800905:	85 d2                	test   %edx,%edx
  800907:	74 14                	je     80091d <strncmp+0x2a>
  800909:	8a 18                	mov    (%eax),%bl
  80090b:	84 db                	test   %bl,%bl
  80090d:	74 04                	je     800913 <strncmp+0x20>
  80090f:	3a 19                	cmp    (%ecx),%bl
  800911:	74 ef                	je     800902 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 00             	movzbl (%eax),%eax
  800916:	0f b6 11             	movzbl (%ecx),%edx
  800919:	29 d0                	sub    %edx,%eax
  80091b:	eb 05                	jmp    800922 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092e:	eb 05                	jmp    800935 <strchr+0x10>
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 0c                	je     800940 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800934:	40                   	inc    %eax
  800935:	8a 10                	mov    (%eax),%dl
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f5                	jne    800930 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094b:	eb 05                	jmp    800952 <strfind+0x10>
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 07                	je     800958 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800951:	40                   	inc    %eax
  800952:	8a 10                	mov    (%eax),%dl
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f5                	jne    80094d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 7d 08             	mov    0x8(%ebp),%edi
  800963:	8b 45 0c             	mov    0xc(%ebp),%eax
  800966:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800969:	85 c9                	test   %ecx,%ecx
  80096b:	74 30                	je     80099d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800973:	75 25                	jne    80099a <memset+0x40>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 20                	jne    80099a <memset+0x40>
		c &= 0xFF;
  80097a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	c1 e3 08             	shl    $0x8,%ebx
  800982:	89 d6                	mov    %edx,%esi
  800984:	c1 e6 18             	shl    $0x18,%esi
  800987:	89 d0                	mov    %edx,%eax
  800989:	c1 e0 10             	shl    $0x10,%eax
  80098c:	09 f0                	or     %esi,%eax
  80098e:	09 d0                	or     %edx,%eax
  800990:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800992:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800995:	fc                   	cld    
  800996:	f3 ab                	rep stos %eax,%es:(%edi)
  800998:	eb 03                	jmp    80099d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099a:	fc                   	cld    
  80099b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	57                   	push   %edi
  8009a8:	56                   	push   %esi
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b2:	39 c6                	cmp    %eax,%esi
  8009b4:	73 34                	jae    8009ea <memmove+0x46>
  8009b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b9:	39 d0                	cmp    %edx,%eax
  8009bb:	73 2d                	jae    8009ea <memmove+0x46>
		s += n;
		d += n;
  8009bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c0:	f6 c2 03             	test   $0x3,%dl
  8009c3:	75 1b                	jne    8009e0 <memmove+0x3c>
  8009c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cb:	75 13                	jne    8009e0 <memmove+0x3c>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 0e                	jne    8009e0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d2:	83 ef 04             	sub    $0x4,%edi
  8009d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009db:	fd                   	std    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 07                	jmp    8009e7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e0:	4f                   	dec    %edi
  8009e1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e4:	fd                   	std    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e7:	fc                   	cld    
  8009e8:	eb 20                	jmp    800a0a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f0:	75 13                	jne    800a05 <memmove+0x61>
  8009f2:	a8 03                	test   $0x3,%al
  8009f4:	75 0f                	jne    800a05 <memmove+0x61>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 0a                	jne    800a05 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb 05                	jmp    800a0a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
  800a17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	89 04 24             	mov    %eax,(%esp)
  800a28:	e8 77 ff ff ff       	call   8009a4 <memmove>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a43:	eb 16                	jmp    800a5b <memcmp+0x2c>
		if (*s1 != *s2)
  800a45:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a48:	42                   	inc    %edx
  800a49:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a4d:	38 c8                	cmp    %cl,%al
  800a4f:	74 0a                	je     800a5b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a51:	0f b6 c0             	movzbl %al,%eax
  800a54:	0f b6 c9             	movzbl %cl,%ecx
  800a57:	29 c8                	sub    %ecx,%eax
  800a59:	eb 09                	jmp    800a64 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 da                	cmp    %ebx,%edx
  800a5d:	75 e6                	jne    800a45 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a77:	eb 05                	jmp    800a7e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a79:	38 08                	cmp    %cl,(%eax)
  800a7b:	74 05                	je     800a82 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7d:	40                   	inc    %eax
  800a7e:	39 d0                	cmp    %edx,%eax
  800a80:	72 f7                	jb     800a79 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a90:	eb 01                	jmp    800a93 <strtol+0xf>
		s++;
  800a92:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a93:	8a 02                	mov    (%edx),%al
  800a95:	3c 20                	cmp    $0x20,%al
  800a97:	74 f9                	je     800a92 <strtol+0xe>
  800a99:	3c 09                	cmp    $0x9,%al
  800a9b:	74 f5                	je     800a92 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9d:	3c 2b                	cmp    $0x2b,%al
  800a9f:	75 08                	jne    800aa9 <strtol+0x25>
		s++;
  800aa1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb 13                	jmp    800abc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	75 0a                	jne    800ab7 <strtol+0x33>
		s++, neg = 1;
  800aad:	8d 52 01             	lea    0x1(%edx),%edx
  800ab0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab5:	eb 05                	jmp    800abc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abc:	85 db                	test   %ebx,%ebx
  800abe:	74 05                	je     800ac5 <strtol+0x41>
  800ac0:	83 fb 10             	cmp    $0x10,%ebx
  800ac3:	75 28                	jne    800aed <strtol+0x69>
  800ac5:	8a 02                	mov    (%edx),%al
  800ac7:	3c 30                	cmp    $0x30,%al
  800ac9:	75 10                	jne    800adb <strtol+0x57>
  800acb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acf:	75 0a                	jne    800adb <strtol+0x57>
		s += 2, base = 16;
  800ad1:	83 c2 02             	add    $0x2,%edx
  800ad4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad9:	eb 12                	jmp    800aed <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800adb:	85 db                	test   %ebx,%ebx
  800add:	75 0e                	jne    800aed <strtol+0x69>
  800adf:	3c 30                	cmp    $0x30,%al
  800ae1:	75 05                	jne    800ae8 <strtol+0x64>
		s++, base = 8;
  800ae3:	42                   	inc    %edx
  800ae4:	b3 08                	mov    $0x8,%bl
  800ae6:	eb 05                	jmp    800aed <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ae8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
  800af2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af4:	8a 0a                	mov    (%edx),%cl
  800af6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af9:	80 fb 09             	cmp    $0x9,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x82>
			dig = *s - '0';
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 30             	sub    $0x30,%ecx
  800b04:	eb 1e                	jmp    800b24 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b06:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b0e:	0f be c9             	movsbl %cl,%ecx
  800b11:	83 e9 57             	sub    $0x57,%ecx
  800b14:	eb 0e                	jmp    800b24 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b16:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b19:	80 fb 19             	cmp    $0x19,%bl
  800b1c:	77 12                	ja     800b30 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b1e:	0f be c9             	movsbl %cl,%ecx
  800b21:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b24:	39 f1                	cmp    %esi,%ecx
  800b26:	7d 0c                	jge    800b34 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b28:	42                   	inc    %edx
  800b29:	0f af c6             	imul   %esi,%eax
  800b2c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b2e:	eb c4                	jmp    800af4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	89 c1                	mov    %eax,%ecx
  800b32:	eb 02                	jmp    800b36 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b34:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3a:	74 05                	je     800b41 <strtol+0xbd>
		*endptr = (char *) s;
  800b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b41:	85 ff                	test   %edi,%edi
  800b43:	74 04                	je     800b49 <strtol+0xc5>
  800b45:	89 c8                	mov    %ecx,%eax
  800b47:	f7 d8                	neg    %eax
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    
	...

00800b50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	89 c3                	mov    %eax,%ebx
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	89 c6                	mov    %eax,%esi
  800b67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	89 cb                	mov    %ecx,%ebx
  800ba5:	89 cf                	mov    %ecx,%edi
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 28                	jle    800bd7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bba:	00 
  800bbb:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800bc2:	00 
  800bc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bca:	00 
  800bcb:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800bd2:	e8 91 f5 ff ff       	call   800168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd7:	83 c4 2c             	add    $0x2c,%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	b8 02 00 00 00       	mov    $0x2,%eax
  800bef:	89 d1                	mov    %edx,%ecx
  800bf1:	89 d3                	mov    %edx,%ebx
  800bf3:	89 d7                	mov    %edx,%edi
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_yield>:

void
sys_yield(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	be 00 00 00 00       	mov    $0x0,%esi
  800c2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 f7                	mov    %esi,%edi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 28                	jle    800c69 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c45:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c4c:	00 
  800c4d:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800c54:	00 
  800c55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5c:	00 
  800c5d:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800c64:	e8 ff f4 ff ff       	call   800168 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c69:	83 c4 2c             	add    $0x2c,%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7e 28                	jle    800cbc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c9f:	00 
  800ca0:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800ca7:	00 
  800ca8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800caf:	00 
  800cb0:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800cb7:	e8 ac f4 ff ff       	call   800168 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbc:	83 c4 2c             	add    $0x2c,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800d0a:	e8 59 f4 ff ff       	call   800168 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0f:	83 c4 2c             	add    $0x2c,%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d25:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 df                	mov    %ebx,%edi
  800d32:	89 de                	mov    %ebx,%esi
  800d34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 28                	jle    800d62 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d45:	00 
  800d46:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d55:	00 
  800d56:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800d5d:	e8 06 f4 ff ff       	call   800168 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d62:	83 c4 2c             	add    $0x2c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d78:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 df                	mov    %ebx,%edi
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800db0:	e8 b3 f3 ff ff       	call   800168 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 28                	jle    800e08 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800deb:	00 
  800dec:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800df3:	00 
  800df4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfb:	00 
  800dfc:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800e03:	e8 60 f3 ff ff       	call   800168 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e08:	83 c4 2c             	add    $0x2c,%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	be 00 00 00 00       	mov    $0x0,%esi
  800e1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 cb                	mov    %ecx,%ebx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	89 ce                	mov    %ecx,%esi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800e78:	e8 eb f2 ff ff       	call   800168 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7d:	83 c4 2c             	add    $0x2c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	00 00                	add    %al,(%eax)
	...

00800e88 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e8e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e95:	0f 85 80 00 00 00    	jne    800f1b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800e9b:	a1 04 40 80 00       	mov    0x804004,%eax
  800ea0:	8b 40 48             	mov    0x48(%eax),%eax
  800ea3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eaa:	00 
  800eab:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800eb2:	ee 
  800eb3:	89 04 24             	mov    %eax,(%esp)
  800eb6:	e8 62 fd ff ff       	call   800c1d <sys_page_alloc>
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	79 20                	jns    800edf <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800ebf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec3:	c7 44 24 08 4c 24 80 	movl   $0x80244c,0x8(%esp)
  800eca:	00 
  800ecb:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800ed2:	00 
  800ed3:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  800eda:	e8 89 f2 ff ff       	call   800168 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800edf:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee4:	8b 40 48             	mov    0x48(%eax),%eax
  800ee7:	c7 44 24 04 28 0f 80 	movl   $0x800f28,0x4(%esp)
  800eee:	00 
  800eef:	89 04 24             	mov    %eax,(%esp)
  800ef2:	e8 c6 fe ff ff       	call   800dbd <sys_env_set_pgfault_upcall>
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	79 20                	jns    800f1b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800efb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eff:	c7 44 24 08 78 24 80 	movl   $0x802478,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  800f16:	e8 4d f2 ff ff       	call   800168 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    
  800f25:	00 00                	add    %al,(%eax)
	...

00800f28 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f28:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f29:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f2e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f30:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  800f33:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800f37:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800f39:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800f3c:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800f3d:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  800f40:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  800f42:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800f45:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800f46:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800f49:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f4a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800f4b:	c3                   	ret    

00800f4c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	05 00 00 00 30       	add    $0x30000000,%eax
  800f57:	c1 e8 0c             	shr    $0xc,%eax
}
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	89 04 24             	mov    %eax,(%esp)
  800f68:	e8 df ff ff ff       	call   800f4c <fd2num>
  800f6d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f72:	c1 e0 0c             	shl    $0xc,%eax
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	53                   	push   %ebx
  800f7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f7e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f83:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f85:	89 c2                	mov    %eax,%edx
  800f87:	c1 ea 16             	shr    $0x16,%edx
  800f8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f91:	f6 c2 01             	test   $0x1,%dl
  800f94:	74 11                	je     800fa7 <fd_alloc+0x30>
  800f96:	89 c2                	mov    %eax,%edx
  800f98:	c1 ea 0c             	shr    $0xc,%edx
  800f9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa2:	f6 c2 01             	test   $0x1,%dl
  800fa5:	75 09                	jne    800fb0 <fd_alloc+0x39>
			*fd_store = fd;
  800fa7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	eb 17                	jmp    800fc7 <fd_alloc+0x50>
  800fb0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fb5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fba:	75 c7                	jne    800f83 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fbc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fc2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fc7:	5b                   	pop    %ebx
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fd0:	83 f8 1f             	cmp    $0x1f,%eax
  800fd3:	77 36                	ja     80100b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fd5:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fda:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	c1 ea 16             	shr    $0x16,%edx
  800fe2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe9:	f6 c2 01             	test   $0x1,%dl
  800fec:	74 24                	je     801012 <fd_lookup+0x48>
  800fee:	89 c2                	mov    %eax,%edx
  800ff0:	c1 ea 0c             	shr    $0xc,%edx
  800ff3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ffa:	f6 c2 01             	test   $0x1,%dl
  800ffd:	74 1a                	je     801019 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	89 02                	mov    %eax,(%edx)
	return 0;
  801004:	b8 00 00 00 00       	mov    $0x0,%eax
  801009:	eb 13                	jmp    80101e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80100b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801010:	eb 0c                	jmp    80101e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801012:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801017:	eb 05                	jmp    80101e <fd_lookup+0x54>
  801019:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	53                   	push   %ebx
  801024:	83 ec 14             	sub    $0x14,%esp
  801027:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80102a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80102d:	ba 00 00 00 00       	mov    $0x0,%edx
  801032:	eb 0e                	jmp    801042 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801034:	39 08                	cmp    %ecx,(%eax)
  801036:	75 09                	jne    801041 <dev_lookup+0x21>
			*dev = devtab[i];
  801038:	89 03                	mov    %eax,(%ebx)
			return 0;
  80103a:	b8 00 00 00 00       	mov    $0x0,%eax
  80103f:	eb 33                	jmp    801074 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801041:	42                   	inc    %edx
  801042:	8b 04 95 38 25 80 00 	mov    0x802538(,%edx,4),%eax
  801049:	85 c0                	test   %eax,%eax
  80104b:	75 e7                	jne    801034 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80104d:	a1 04 40 80 00       	mov    0x804004,%eax
  801052:	8b 40 48             	mov    0x48(%eax),%eax
  801055:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105d:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  801064:	e8 f7 f1 ff ff       	call   800260 <cprintf>
	*dev = 0;
  801069:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80106f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801074:	83 c4 14             	add    $0x14,%esp
  801077:	5b                   	pop    %ebx
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 30             	sub    $0x30,%esp
  801082:	8b 75 08             	mov    0x8(%ebp),%esi
  801085:	8a 45 0c             	mov    0xc(%ebp),%al
  801088:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80108b:	89 34 24             	mov    %esi,(%esp)
  80108e:	e8 b9 fe ff ff       	call   800f4c <fd2num>
  801093:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801096:	89 54 24 04          	mov    %edx,0x4(%esp)
  80109a:	89 04 24             	mov    %eax,(%esp)
  80109d:	e8 28 ff ff ff       	call   800fca <fd_lookup>
  8010a2:	89 c3                	mov    %eax,%ebx
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 05                	js     8010ad <fd_close+0x33>
	    || fd != fd2)
  8010a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010ab:	74 0d                	je     8010ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8010ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010b1:	75 46                	jne    8010f9 <fd_close+0x7f>
  8010b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b8:	eb 3f                	jmp    8010f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c1:	8b 06                	mov    (%esi),%eax
  8010c3:	89 04 24             	mov    %eax,(%esp)
  8010c6:	e8 55 ff ff ff       	call   801020 <dev_lookup>
  8010cb:	89 c3                	mov    %eax,%ebx
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 18                	js     8010e9 <fd_close+0x6f>
		if (dev->dev_close)
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	8b 40 10             	mov    0x10(%eax),%eax
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	74 09                	je     8010e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010db:	89 34 24             	mov    %esi,(%esp)
  8010de:	ff d0                	call   *%eax
  8010e0:	89 c3                	mov    %eax,%ebx
  8010e2:	eb 05                	jmp    8010e9 <fd_close+0x6f>
		else
			r = 0;
  8010e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f4:	e8 cb fb ff ff       	call   800cc4 <sys_page_unmap>
	return r;
}
  8010f9:	89 d8                	mov    %ebx,%eax
  8010fb:	83 c4 30             	add    $0x30,%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801108:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	89 04 24             	mov    %eax,(%esp)
  801115:	e8 b0 fe ff ff       	call   800fca <fd_lookup>
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 13                	js     801131 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80111e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801125:	00 
  801126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	e8 49 ff ff ff       	call   80107a <fd_close>
}
  801131:	c9                   	leave  
  801132:	c3                   	ret    

00801133 <close_all>:

void
close_all(void)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	53                   	push   %ebx
  801137:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80113a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80113f:	89 1c 24             	mov    %ebx,(%esp)
  801142:	e8 bb ff ff ff       	call   801102 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801147:	43                   	inc    %ebx
  801148:	83 fb 20             	cmp    $0x20,%ebx
  80114b:	75 f2                	jne    80113f <close_all+0xc>
		close(i);
}
  80114d:	83 c4 14             	add    $0x14,%esp
  801150:	5b                   	pop    %ebx
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 4c             	sub    $0x4c,%esp
  80115c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80115f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801162:	89 44 24 04          	mov    %eax,0x4(%esp)
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	89 04 24             	mov    %eax,(%esp)
  80116c:	e8 59 fe ff ff       	call   800fca <fd_lookup>
  801171:	89 c3                	mov    %eax,%ebx
  801173:	85 c0                	test   %eax,%eax
  801175:	0f 88 e1 00 00 00    	js     80125c <dup+0x109>
		return r;
	close(newfdnum);
  80117b:	89 3c 24             	mov    %edi,(%esp)
  80117e:	e8 7f ff ff ff       	call   801102 <close>

	newfd = INDEX2FD(newfdnum);
  801183:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801189:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80118c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 c5 fd ff ff       	call   800f5c <fd2data>
  801197:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801199:	89 34 24             	mov    %esi,(%esp)
  80119c:	e8 bb fd ff ff       	call   800f5c <fd2data>
  8011a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	c1 e8 16             	shr    $0x16,%eax
  8011a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b0:	a8 01                	test   $0x1,%al
  8011b2:	74 46                	je     8011fa <dup+0xa7>
  8011b4:	89 d8                	mov    %ebx,%eax
  8011b6:	c1 e8 0c             	shr    $0xc,%eax
  8011b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c0:	f6 c2 01             	test   $0x1,%dl
  8011c3:	74 35                	je     8011fa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e3:	00 
  8011e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ef:	e8 7d fa ff ff       	call   800c71 <sys_page_map>
  8011f4:	89 c3                	mov    %eax,%ebx
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 3b                	js     801235 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	c1 ea 0c             	shr    $0xc,%edx
  801202:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801209:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80120f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801213:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801217:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80121e:	00 
  80121f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122a:	e8 42 fa ff ff       	call   800c71 <sys_page_map>
  80122f:	89 c3                	mov    %eax,%ebx
  801231:	85 c0                	test   %eax,%eax
  801233:	79 25                	jns    80125a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801235:	89 74 24 04          	mov    %esi,0x4(%esp)
  801239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801240:	e8 7f fa ff ff       	call   800cc4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801245:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801253:	e8 6c fa ff ff       	call   800cc4 <sys_page_unmap>
	return r;
  801258:	eb 02                	jmp    80125c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80125a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	83 c4 4c             	add    $0x4c,%esp
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 24             	sub    $0x24,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	89 44 24 04          	mov    %eax,0x4(%esp)
  801277:	89 1c 24             	mov    %ebx,(%esp)
  80127a:	e8 4b fd ff ff       	call   800fca <fd_lookup>
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 6d                	js     8012f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	8b 00                	mov    (%eax),%eax
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 89 fd ff ff       	call   801020 <dev_lookup>
  801297:	85 c0                	test   %eax,%eax
  801299:	78 55                	js     8012f0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	8b 50 08             	mov    0x8(%eax),%edx
  8012a1:	83 e2 03             	and    $0x3,%edx
  8012a4:	83 fa 01             	cmp    $0x1,%edx
  8012a7:	75 23                	jne    8012cc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ae:	8b 40 48             	mov    0x48(%eax),%eax
  8012b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b9:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  8012c0:	e8 9b ef ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  8012c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ca:	eb 24                	jmp    8012f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	8b 52 08             	mov    0x8(%edx),%edx
  8012d2:	85 d2                	test   %edx,%edx
  8012d4:	74 15                	je     8012eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	ff d2                	call   *%edx
  8012e9:	eb 05                	jmp    8012f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012f0:	83 c4 24             	add    $0x24,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 1c             	sub    $0x1c,%esp
  8012ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801302:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801305:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130a:	eb 23                	jmp    80132f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80130c:	89 f0                	mov    %esi,%eax
  80130e:	29 d8                	sub    %ebx,%eax
  801310:	89 44 24 08          	mov    %eax,0x8(%esp)
  801314:	8b 45 0c             	mov    0xc(%ebp),%eax
  801317:	01 d8                	add    %ebx,%eax
  801319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131d:	89 3c 24             	mov    %edi,(%esp)
  801320:	e8 41 ff ff ff       	call   801266 <read>
		if (m < 0)
  801325:	85 c0                	test   %eax,%eax
  801327:	78 10                	js     801339 <readn+0x43>
			return m;
		if (m == 0)
  801329:	85 c0                	test   %eax,%eax
  80132b:	74 0a                	je     801337 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80132d:	01 c3                	add    %eax,%ebx
  80132f:	39 f3                	cmp    %esi,%ebx
  801331:	72 d9                	jb     80130c <readn+0x16>
  801333:	89 d8                	mov    %ebx,%eax
  801335:	eb 02                	jmp    801339 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801337:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801339:	83 c4 1c             	add    $0x1c,%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5f                   	pop    %edi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	53                   	push   %ebx
  801345:	83 ec 24             	sub    $0x24,%esp
  801348:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801352:	89 1c 24             	mov    %ebx,(%esp)
  801355:	e8 70 fc ff ff       	call   800fca <fd_lookup>
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 68                	js     8013c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801368:	8b 00                	mov    (%eax),%eax
  80136a:	89 04 24             	mov    %eax,(%esp)
  80136d:	e8 ae fc ff ff       	call   801020 <dev_lookup>
  801372:	85 c0                	test   %eax,%eax
  801374:	78 50                	js     8013c6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801376:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801379:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80137d:	75 23                	jne    8013a2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80137f:	a1 04 40 80 00       	mov    0x804004,%eax
  801384:	8b 40 48             	mov    0x48(%eax),%eax
  801387:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	c7 04 24 18 25 80 00 	movl   $0x802518,(%esp)
  801396:	e8 c5 ee ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  80139b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a0:	eb 24                	jmp    8013c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a8:	85 d2                	test   %edx,%edx
  8013aa:	74 15                	je     8013c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	ff d2                	call   *%edx
  8013bf:	eb 05                	jmp    8013c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013c6:	83 c4 24             	add    $0x24,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dc:	89 04 24             	mov    %eax,(%esp)
  8013df:	e8 e6 fb ff ff       	call   800fca <fd_lookup>
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 0e                	js     8013f6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 24             	sub    $0x24,%esp
  8013ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801402:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801405:	89 44 24 04          	mov    %eax,0x4(%esp)
  801409:	89 1c 24             	mov    %ebx,(%esp)
  80140c:	e8 b9 fb ff ff       	call   800fca <fd_lookup>
  801411:	85 c0                	test   %eax,%eax
  801413:	78 61                	js     801476 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801415:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141f:	8b 00                	mov    (%eax),%eax
  801421:	89 04 24             	mov    %eax,(%esp)
  801424:	e8 f7 fb ff ff       	call   801020 <dev_lookup>
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 49                	js     801476 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80142d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801430:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801434:	75 23                	jne    801459 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801436:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80143b:	8b 40 48             	mov    0x48(%eax),%eax
  80143e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  80144d:	e8 0e ee ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801452:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801457:	eb 1d                	jmp    801476 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801459:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145c:	8b 52 18             	mov    0x18(%edx),%edx
  80145f:	85 d2                	test   %edx,%edx
  801461:	74 0e                	je     801471 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801463:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801466:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80146a:	89 04 24             	mov    %eax,(%esp)
  80146d:	ff d2                	call   *%edx
  80146f:	eb 05                	jmp    801476 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801471:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801476:	83 c4 24             	add    $0x24,%esp
  801479:	5b                   	pop    %ebx
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 24             	sub    $0x24,%esp
  801483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	89 04 24             	mov    %eax,(%esp)
  801493:	e8 32 fb ff ff       	call   800fca <fd_lookup>
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 52                	js     8014ee <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	8b 00                	mov    (%eax),%eax
  8014a8:	89 04 24             	mov    %eax,(%esp)
  8014ab:	e8 70 fb ff ff       	call   801020 <dev_lookup>
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 3a                	js     8014ee <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014bb:	74 2c                	je     8014e9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014c7:	00 00 00 
	stat->st_isdir = 0;
  8014ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014d1:	00 00 00 
	stat->st_dev = dev;
  8014d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e1:	89 14 24             	mov    %edx,(%esp)
  8014e4:	ff 50 14             	call   *0x14(%eax)
  8014e7:	eb 05                	jmp    8014ee <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014ee:	83 c4 24             	add    $0x24,%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801503:	00 
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	89 04 24             	mov    %eax,(%esp)
  80150a:	e8 fe 01 00 00       	call   80170d <open>
  80150f:	89 c3                	mov    %eax,%ebx
  801511:	85 c0                	test   %eax,%eax
  801513:	78 1b                	js     801530 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801515:	8b 45 0c             	mov    0xc(%ebp),%eax
  801518:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151c:	89 1c 24             	mov    %ebx,(%esp)
  80151f:	e8 58 ff ff ff       	call   80147c <fstat>
  801524:	89 c6                	mov    %eax,%esi
	close(fd);
  801526:	89 1c 24             	mov    %ebx,(%esp)
  801529:	e8 d4 fb ff ff       	call   801102 <close>
	return r;
  80152e:	89 f3                	mov    %esi,%ebx
}
  801530:	89 d8                	mov    %ebx,%eax
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	5b                   	pop    %ebx
  801536:	5e                   	pop    %esi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    
  801539:	00 00                	add    %al,(%eax)
	...

0080153c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
  801541:	83 ec 10             	sub    $0x10,%esp
  801544:	89 c3                	mov    %eax,%ebx
  801546:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801548:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80154f:	75 11                	jne    801562 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801551:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801558:	e8 38 08 00 00       	call   801d95 <ipc_find_env>
  80155d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801562:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801569:	00 
  80156a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801571:	00 
  801572:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801576:	a1 00 40 80 00       	mov    0x804000,%eax
  80157b:	89 04 24             	mov    %eax,(%esp)
  80157e:	e8 a8 07 00 00       	call   801d2b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801583:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80158a:	00 
  80158b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801596:	e8 29 07 00 00       	call   801cc4 <ipc_recv>
}
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8015c5:	e8 72 ff ff ff       	call   80153c <fsipc>
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8015e7:	e8 50 ff ff ff       	call   80153c <fsipc>
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 14             	sub    $0x14,%esp
  8015f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801603:	ba 00 00 00 00       	mov    $0x0,%edx
  801608:	b8 05 00 00 00       	mov    $0x5,%eax
  80160d:	e8 2a ff ff ff       	call   80153c <fsipc>
  801612:	85 c0                	test   %eax,%eax
  801614:	78 2b                	js     801641 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801616:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80161d:	00 
  80161e:	89 1c 24             	mov    %ebx,(%esp)
  801621:	e8 05 f2 ff ff       	call   80082b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801626:	a1 80 50 80 00       	mov    0x805080,%eax
  80162b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801631:	a1 84 50 80 00       	mov    0x805084,%eax
  801636:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801641:	83 c4 14             	add    $0x14,%esp
  801644:	5b                   	pop    %ebx
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80164d:	c7 44 24 08 48 25 80 	movl   $0x802548,0x8(%esp)
  801654:	00 
  801655:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80165c:	00 
  80165d:	c7 04 24 66 25 80 00 	movl   $0x802566,(%esp)
  801664:	e8 ff ea ff ff       	call   800168 <_panic>

00801669 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	56                   	push   %esi
  80166d:	53                   	push   %ebx
  80166e:	83 ec 10             	sub    $0x10,%esp
  801671:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801674:	8b 45 08             	mov    0x8(%ebp),%eax
  801677:	8b 40 0c             	mov    0xc(%eax),%eax
  80167a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80167f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 03 00 00 00       	mov    $0x3,%eax
  80168f:	e8 a8 fe ff ff       	call   80153c <fsipc>
  801694:	89 c3                	mov    %eax,%ebx
  801696:	85 c0                	test   %eax,%eax
  801698:	78 6a                	js     801704 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80169a:	39 c6                	cmp    %eax,%esi
  80169c:	73 24                	jae    8016c2 <devfile_read+0x59>
  80169e:	c7 44 24 0c 71 25 80 	movl   $0x802571,0xc(%esp)
  8016a5:	00 
  8016a6:	c7 44 24 08 78 25 80 	movl   $0x802578,0x8(%esp)
  8016ad:	00 
  8016ae:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016b5:	00 
  8016b6:	c7 04 24 66 25 80 00 	movl   $0x802566,(%esp)
  8016bd:	e8 a6 ea ff ff       	call   800168 <_panic>
	assert(r <= PGSIZE);
  8016c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016c7:	7e 24                	jle    8016ed <devfile_read+0x84>
  8016c9:	c7 44 24 0c 8d 25 80 	movl   $0x80258d,0xc(%esp)
  8016d0:	00 
  8016d1:	c7 44 24 08 78 25 80 	movl   $0x802578,0x8(%esp)
  8016d8:	00 
  8016d9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016e0:	00 
  8016e1:	c7 04 24 66 25 80 00 	movl   $0x802566,(%esp)
  8016e8:	e8 7b ea ff ff       	call   800168 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f1:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016f8:	00 
  8016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fc:	89 04 24             	mov    %eax,(%esp)
  8016ff:	e8 a0 f2 ff ff       	call   8009a4 <memmove>
	return r;
}
  801704:	89 d8                	mov    %ebx,%eax
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	56                   	push   %esi
  801711:	53                   	push   %ebx
  801712:	83 ec 20             	sub    $0x20,%esp
  801715:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801718:	89 34 24             	mov    %esi,(%esp)
  80171b:	e8 d8 f0 ff ff       	call   8007f8 <strlen>
  801720:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801725:	7f 60                	jg     801787 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172a:	89 04 24             	mov    %eax,(%esp)
  80172d:	e8 45 f8 ff ff       	call   800f77 <fd_alloc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	85 c0                	test   %eax,%eax
  801736:	78 54                	js     80178c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801738:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801743:	e8 e3 f0 ff ff       	call   80082b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801748:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801750:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801753:	b8 01 00 00 00       	mov    $0x1,%eax
  801758:	e8 df fd ff ff       	call   80153c <fsipc>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	85 c0                	test   %eax,%eax
  801761:	79 15                	jns    801778 <open+0x6b>
		fd_close(fd, 0);
  801763:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80176a:	00 
  80176b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 04 f9 ff ff       	call   80107a <fd_close>
		return r;
  801776:	eb 14                	jmp    80178c <open+0x7f>
	}

	return fd2num(fd);
  801778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 c9 f7 ff ff       	call   800f4c <fd2num>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	eb 05                	jmp    80178c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801787:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80178c:	89 d8                	mov    %ebx,%eax
  80178e:	83 c4 20             	add    $0x20,%esp
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017a5:	e8 92 fd ff ff       	call   80153c <fsipc>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 10             	sub    $0x10,%esp
  8017b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	e8 9a f7 ff ff       	call   800f5c <fd2data>
  8017c2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8017c4:	c7 44 24 04 99 25 80 	movl   $0x802599,0x4(%esp)
  8017cb:	00 
  8017cc:	89 34 24             	mov    %esi,(%esp)
  8017cf:	e8 57 f0 ff ff       	call   80082b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8017d7:	2b 03                	sub    (%ebx),%eax
  8017d9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8017df:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8017e6:	00 00 00 
	stat->st_dev = &devpipe;
  8017e9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8017f0:	30 80 00 
	return 0;
}
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	83 ec 14             	sub    $0x14,%esp
  801806:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801809:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80180d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801814:	e8 ab f4 ff ff       	call   800cc4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801819:	89 1c 24             	mov    %ebx,(%esp)
  80181c:	e8 3b f7 ff ff       	call   800f5c <fd2data>
  801821:	89 44 24 04          	mov    %eax,0x4(%esp)
  801825:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182c:	e8 93 f4 ff ff       	call   800cc4 <sys_page_unmap>
}
  801831:	83 c4 14             	add    $0x14,%esp
  801834:	5b                   	pop    %ebx
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 2c             	sub    $0x2c,%esp
  801840:	89 c7                	mov    %eax,%edi
  801842:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801845:	a1 04 40 80 00       	mov    0x804004,%eax
  80184a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80184d:	89 3c 24             	mov    %edi,(%esp)
  801850:	e8 87 05 00 00       	call   801ddc <pageref>
  801855:	89 c6                	mov    %eax,%esi
  801857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80185a:	89 04 24             	mov    %eax,(%esp)
  80185d:	e8 7a 05 00 00       	call   801ddc <pageref>
  801862:	39 c6                	cmp    %eax,%esi
  801864:	0f 94 c0             	sete   %al
  801867:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80186a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801870:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801873:	39 cb                	cmp    %ecx,%ebx
  801875:	75 08                	jne    80187f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801877:	83 c4 2c             	add    $0x2c,%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5f                   	pop    %edi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80187f:	83 f8 01             	cmp    $0x1,%eax
  801882:	75 c1                	jne    801845 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801884:	8b 42 58             	mov    0x58(%edx),%eax
  801887:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80188e:	00 
  80188f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801893:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801897:	c7 04 24 a0 25 80 00 	movl   $0x8025a0,(%esp)
  80189e:	e8 bd e9 ff ff       	call   800260 <cprintf>
  8018a3:	eb a0                	jmp    801845 <_pipeisclosed+0xe>

008018a5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	57                   	push   %edi
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 1c             	sub    $0x1c,%esp
  8018ae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018b1:	89 34 24             	mov    %esi,(%esp)
  8018b4:	e8 a3 f6 ff ff       	call   800f5c <fd2data>
  8018b9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8018c0:	eb 3c                	jmp    8018fe <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018c2:	89 da                	mov    %ebx,%edx
  8018c4:	89 f0                	mov    %esi,%eax
  8018c6:	e8 6c ff ff ff       	call   801837 <_pipeisclosed>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	75 38                	jne    801907 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018cf:	e8 2a f3 ff ff       	call   800bfe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8018d7:	8b 13                	mov    (%ebx),%edx
  8018d9:	83 c2 20             	add    $0x20,%edx
  8018dc:	39 d0                	cmp    %edx,%eax
  8018de:	73 e2                	jae    8018c2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8018e6:	89 c2                	mov    %eax,%edx
  8018e8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018ee:	79 05                	jns    8018f5 <devpipe_write+0x50>
  8018f0:	4a                   	dec    %edx
  8018f1:	83 ca e0             	or     $0xffffffe0,%edx
  8018f4:	42                   	inc    %edx
  8018f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018f9:	40                   	inc    %eax
  8018fa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fd:	47                   	inc    %edi
  8018fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801901:	75 d1                	jne    8018d4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801903:	89 f8                	mov    %edi,%eax
  801905:	eb 05                	jmp    80190c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801907:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80190c:	83 c4 1c             	add    $0x1c,%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	57                   	push   %edi
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 1c             	sub    $0x1c,%esp
  80191d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801920:	89 3c 24             	mov    %edi,(%esp)
  801923:	e8 34 f6 ff ff       	call   800f5c <fd2data>
  801928:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192a:	be 00 00 00 00       	mov    $0x0,%esi
  80192f:	eb 3a                	jmp    80196b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801931:	85 f6                	test   %esi,%esi
  801933:	74 04                	je     801939 <devpipe_read+0x25>
				return i;
  801935:	89 f0                	mov    %esi,%eax
  801937:	eb 40                	jmp    801979 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801939:	89 da                	mov    %ebx,%edx
  80193b:	89 f8                	mov    %edi,%eax
  80193d:	e8 f5 fe ff ff       	call   801837 <_pipeisclosed>
  801942:	85 c0                	test   %eax,%eax
  801944:	75 2e                	jne    801974 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801946:	e8 b3 f2 ff ff       	call   800bfe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80194b:	8b 03                	mov    (%ebx),%eax
  80194d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801950:	74 df                	je     801931 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801952:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801957:	79 05                	jns    80195e <devpipe_read+0x4a>
  801959:	48                   	dec    %eax
  80195a:	83 c8 e0             	or     $0xffffffe0,%eax
  80195d:	40                   	inc    %eax
  80195e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801962:	8b 55 0c             	mov    0xc(%ebp),%edx
  801965:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801968:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196a:	46                   	inc    %esi
  80196b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80196e:	75 db                	jne    80194b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801970:	89 f0                	mov    %esi,%eax
  801972:	eb 05                	jmp    801979 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801974:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801979:	83 c4 1c             	add    $0x1c,%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5f                   	pop    %edi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	57                   	push   %edi
  801985:	56                   	push   %esi
  801986:	53                   	push   %ebx
  801987:	83 ec 3c             	sub    $0x3c,%esp
  80198a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80198d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801990:	89 04 24             	mov    %eax,(%esp)
  801993:	e8 df f5 ff ff       	call   800f77 <fd_alloc>
  801998:	89 c3                	mov    %eax,%ebx
  80199a:	85 c0                	test   %eax,%eax
  80199c:	0f 88 45 01 00 00    	js     801ae7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019a9:	00 
  8019aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b8:	e8 60 f2 ff ff       	call   800c1d <sys_page_alloc>
  8019bd:	89 c3                	mov    %eax,%ebx
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	0f 88 20 01 00 00    	js     801ae7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8019ca:	89 04 24             	mov    %eax,(%esp)
  8019cd:	e8 a5 f5 ff ff       	call   800f77 <fd_alloc>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	0f 88 f8 00 00 00    	js     801ad4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019dc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019e3:	00 
  8019e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f2:	e8 26 f2 ff ff       	call   800c1d <sys_page_alloc>
  8019f7:	89 c3                	mov    %eax,%ebx
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	0f 88 d3 00 00 00    	js     801ad4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	e8 50 f5 ff ff       	call   800f5c <fd2data>
  801a0c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a15:	00 
  801a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a21:	e8 f7 f1 ff ff       	call   800c1d <sys_page_alloc>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	0f 88 91 00 00 00    	js     801ac1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a33:	89 04 24             	mov    %eax,(%esp)
  801a36:	e8 21 f5 ff ff       	call   800f5c <fd2data>
  801a3b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a42:	00 
  801a43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a4e:	00 
  801a4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a5a:	e8 12 f2 ff ff       	call   800c71 <sys_page_map>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 4c                	js     801ab1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a65:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a7a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a83:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a88:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 b2 f4 ff ff       	call   800f4c <fd2num>
  801a9a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 a5 f4 ff ff       	call   800f4c <fd2num>
  801aa7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801aaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aaf:	eb 36                	jmp    801ae7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801ab1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abc:	e8 03 f2 ff ff       	call   800cc4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ac1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801acf:	e8 f0 f1 ff ff       	call   800cc4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae2:	e8 dd f1 ff ff       	call   800cc4 <sys_page_unmap>
    err:
	return r;
}
  801ae7:	89 d8                	mov    %ebx,%eax
  801ae9:	83 c4 3c             	add    $0x3c,%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	89 04 24             	mov    %eax,(%esp)
  801b04:	e8 c1 f4 ff ff       	call   800fca <fd_lookup>
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 15                	js     801b22 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	89 04 24             	mov    %eax,(%esp)
  801b13:	e8 44 f4 ff ff       	call   800f5c <fd2data>
	return _pipeisclosed(fd, p);
  801b18:	89 c2                	mov    %eax,%edx
  801b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1d:	e8 15 fd ff ff       	call   801837 <_pipeisclosed>
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b34:	c7 44 24 04 b8 25 80 	movl   $0x8025b8,0x4(%esp)
  801b3b:	00 
  801b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3f:	89 04 24             	mov    %eax,(%esp)
  801b42:	e8 e4 ec ff ff       	call   80082b <strcpy>
	return 0;
}
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    

00801b4e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b5a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b5f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b65:	eb 30                	jmp    801b97 <devcons_write+0x49>
		m = n - tot;
  801b67:	8b 75 10             	mov    0x10(%ebp),%esi
  801b6a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b6c:	83 fe 7f             	cmp    $0x7f,%esi
  801b6f:	76 05                	jbe    801b76 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b71:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b76:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b7a:	03 45 0c             	add    0xc(%ebp),%eax
  801b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b81:	89 3c 24             	mov    %edi,(%esp)
  801b84:	e8 1b ee ff ff       	call   8009a4 <memmove>
		sys_cputs(buf, m);
  801b89:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8d:	89 3c 24             	mov    %edi,(%esp)
  801b90:	e8 bb ef ff ff       	call   800b50 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b95:	01 f3                	add    %esi,%ebx
  801b97:	89 d8                	mov    %ebx,%eax
  801b99:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b9c:	72 c9                	jb     801b67 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b9e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801baf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb3:	75 07                	jne    801bbc <devcons_read+0x13>
  801bb5:	eb 25                	jmp    801bdc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bb7:	e8 42 f0 ff ff       	call   800bfe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bbc:	e8 ad ef ff ff       	call   800b6e <sys_cgetc>
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	74 f2                	je     801bb7 <devcons_read+0xe>
  801bc5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 1d                	js     801be8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bcb:	83 f8 04             	cmp    $0x4,%eax
  801bce:	74 13                	je     801be3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd3:	88 10                	mov    %dl,(%eax)
	return 1;
  801bd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801bda:	eb 0c                	jmp    801be8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801be1:	eb 05                	jmp    801be8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bf6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bfd:	00 
  801bfe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c01:	89 04 24             	mov    %eax,(%esp)
  801c04:	e8 47 ef ff ff       	call   800b50 <sys_cputs>
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <getchar>:

int
getchar(void)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c11:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c18:	00 
  801c19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c27:	e8 3a f6 ff ff       	call   801266 <read>
	if (r < 0)
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 0f                	js     801c3f <getchar+0x34>
		return r;
	if (r < 1)
  801c30:	85 c0                	test   %eax,%eax
  801c32:	7e 06                	jle    801c3a <getchar+0x2f>
		return -E_EOF;
	return c;
  801c34:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c38:	eb 05                	jmp    801c3f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c3a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 71 f3 ff ff       	call   800fca <fd_lookup>
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 11                	js     801c6e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c66:	39 10                	cmp    %edx,(%eax)
  801c68:	0f 94 c0             	sete   %al
  801c6b:	0f b6 c0             	movzbl %al,%eax
}
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    

00801c70 <opencons>:

int
opencons(void)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c79:	89 04 24             	mov    %eax,(%esp)
  801c7c:	e8 f6 f2 ff ff       	call   800f77 <fd_alloc>
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 3c                	js     801cc1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c85:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c8c:	00 
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9b:	e8 7d ef ff ff       	call   800c1d <sys_page_alloc>
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 1d                	js     801cc1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ca4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cb9:	89 04 24             	mov    %eax,(%esp)
  801cbc:	e8 8b f2 ff ff       	call   800f4c <fd2num>
}
  801cc1:	c9                   	leave  
  801cc2:	c3                   	ret    
	...

00801cc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 10             	sub    $0x10,%esp
  801ccc:	8b 75 08             	mov    0x8(%ebp),%esi
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	75 05                	jne    801cde <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801cd9:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 4d f1 ff ff       	call   800e33 <sys_ipc_recv>
	if (!err) {
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	75 26                	jne    801d10 <ipc_recv+0x4c>
		if (from_env_store) {
  801cea:	85 f6                	test   %esi,%esi
  801cec:	74 0a                	je     801cf8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801cee:	a1 04 40 80 00       	mov    0x804004,%eax
  801cf3:	8b 40 74             	mov    0x74(%eax),%eax
  801cf6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801cf8:	85 db                	test   %ebx,%ebx
  801cfa:	74 0a                	je     801d06 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801cfc:	a1 04 40 80 00       	mov    0x804004,%eax
  801d01:	8b 40 78             	mov    0x78(%eax),%eax
  801d04:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801d06:	a1 04 40 80 00       	mov    0x804004,%eax
  801d0b:	8b 40 70             	mov    0x70(%eax),%eax
  801d0e:	eb 14                	jmp    801d24 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801d10:	85 f6                	test   %esi,%esi
  801d12:	74 06                	je     801d1a <ipc_recv+0x56>
		*from_env_store = 0;
  801d14:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801d1a:	85 db                	test   %ebx,%ebx
  801d1c:	74 06                	je     801d24 <ipc_recv+0x60>
		*perm_store = 0;
  801d1e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	57                   	push   %edi
  801d2f:	56                   	push   %esi
  801d30:	53                   	push   %ebx
  801d31:	83 ec 1c             	sub    $0x1c,%esp
  801d34:	8b 75 10             	mov    0x10(%ebp),%esi
  801d37:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801d3a:	85 f6                	test   %esi,%esi
  801d3c:	75 05                	jne    801d43 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801d3e:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801d43:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d47:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	89 04 24             	mov    %eax,(%esp)
  801d58:	e8 b3 f0 ff ff       	call   800e10 <sys_ipc_try_send>
  801d5d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801d5f:	e8 9a ee ff ff       	call   800bfe <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801d64:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801d67:	74 da                	je     801d43 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801d69:	85 db                	test   %ebx,%ebx
  801d6b:	74 20                	je     801d8d <ipc_send+0x62>
		panic("send fail: %e", err);
  801d6d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d71:	c7 44 24 08 c4 25 80 	movl   $0x8025c4,0x8(%esp)
  801d78:	00 
  801d79:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801d80:	00 
  801d81:	c7 04 24 d2 25 80 00 	movl   $0x8025d2,(%esp)
  801d88:	e8 db e3 ff ff       	call   800168 <_panic>
	}
	return;
}
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	53                   	push   %ebx
  801d99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801da1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801da8:	89 c2                	mov    %eax,%edx
  801daa:	c1 e2 07             	shl    $0x7,%edx
  801dad:	29 ca                	sub    %ecx,%edx
  801daf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801db5:	8b 52 50             	mov    0x50(%edx),%edx
  801db8:	39 da                	cmp    %ebx,%edx
  801dba:	75 0f                	jne    801dcb <ipc_find_env+0x36>
			return envs[i].env_id;
  801dbc:	c1 e0 07             	shl    $0x7,%eax
  801dbf:	29 c8                	sub    %ecx,%eax
  801dc1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801dc6:	8b 40 40             	mov    0x40(%eax),%eax
  801dc9:	eb 0c                	jmp    801dd7 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dcb:	40                   	inc    %eax
  801dcc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dd1:	75 ce                	jne    801da1 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dd3:	66 b8 00 00          	mov    $0x0,%ax
}
  801dd7:	5b                   	pop    %ebx
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    
	...

00801ddc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801de2:	89 c2                	mov    %eax,%edx
  801de4:	c1 ea 16             	shr    $0x16,%edx
  801de7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dee:	f6 c2 01             	test   $0x1,%dl
  801df1:	74 1e                	je     801e11 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801df3:	c1 e8 0c             	shr    $0xc,%eax
  801df6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801dfd:	a8 01                	test   $0x1,%al
  801dff:	74 17                	je     801e18 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e01:	c1 e8 0c             	shr    $0xc,%eax
  801e04:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e0b:	ef 
  801e0c:	0f b7 c0             	movzwl %ax,%eax
  801e0f:	eb 0c                	jmp    801e1d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e11:	b8 00 00 00 00       	mov    $0x0,%eax
  801e16:	eb 05                	jmp    801e1d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    
	...

00801e20 <__udivdi3>:
  801e20:	55                   	push   %ebp
  801e21:	57                   	push   %edi
  801e22:	56                   	push   %esi
  801e23:	83 ec 10             	sub    $0x10,%esp
  801e26:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e2a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e32:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801e36:	89 cd                	mov    %ecx,%ebp
  801e38:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	75 2c                	jne    801e6c <__udivdi3+0x4c>
  801e40:	39 f9                	cmp    %edi,%ecx
  801e42:	77 68                	ja     801eac <__udivdi3+0x8c>
  801e44:	85 c9                	test   %ecx,%ecx
  801e46:	75 0b                	jne    801e53 <__udivdi3+0x33>
  801e48:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4d:	31 d2                	xor    %edx,%edx
  801e4f:	f7 f1                	div    %ecx
  801e51:	89 c1                	mov    %eax,%ecx
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	89 f8                	mov    %edi,%eax
  801e57:	f7 f1                	div    %ecx
  801e59:	89 c7                	mov    %eax,%edi
  801e5b:	89 f0                	mov    %esi,%eax
  801e5d:	f7 f1                	div    %ecx
  801e5f:	89 c6                	mov    %eax,%esi
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	89 fa                	mov    %edi,%edx
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	39 f8                	cmp    %edi,%eax
  801e6e:	77 2c                	ja     801e9c <__udivdi3+0x7c>
  801e70:	0f bd f0             	bsr    %eax,%esi
  801e73:	83 f6 1f             	xor    $0x1f,%esi
  801e76:	75 4c                	jne    801ec4 <__udivdi3+0xa4>
  801e78:	39 f8                	cmp    %edi,%eax
  801e7a:	bf 00 00 00 00       	mov    $0x0,%edi
  801e7f:	72 0a                	jb     801e8b <__udivdi3+0x6b>
  801e81:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e85:	0f 87 ad 00 00 00    	ja     801f38 <__udivdi3+0x118>
  801e8b:	be 01 00 00 00       	mov    $0x1,%esi
  801e90:	89 f0                	mov    %esi,%eax
  801e92:	89 fa                	mov    %edi,%edx
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    
  801e9b:	90                   	nop
  801e9c:	31 ff                	xor    %edi,%edi
  801e9e:	31 f6                	xor    %esi,%esi
  801ea0:	89 f0                	mov    %esi,%eax
  801ea2:	89 fa                	mov    %edi,%edx
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	5e                   	pop    %esi
  801ea8:	5f                   	pop    %edi
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    
  801eab:	90                   	nop
  801eac:	89 fa                	mov    %edi,%edx
  801eae:	89 f0                	mov    %esi,%eax
  801eb0:	f7 f1                	div    %ecx
  801eb2:	89 c6                	mov    %eax,%esi
  801eb4:	31 ff                	xor    %edi,%edi
  801eb6:	89 f0                	mov    %esi,%eax
  801eb8:	89 fa                	mov    %edi,%edx
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	5e                   	pop    %esi
  801ebe:	5f                   	pop    %edi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    
  801ec1:	8d 76 00             	lea    0x0(%esi),%esi
  801ec4:	89 f1                	mov    %esi,%ecx
  801ec6:	d3 e0                	shl    %cl,%eax
  801ec8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecc:	b8 20 00 00 00       	mov    $0x20,%eax
  801ed1:	29 f0                	sub    %esi,%eax
  801ed3:	89 ea                	mov    %ebp,%edx
  801ed5:	88 c1                	mov    %al,%cl
  801ed7:	d3 ea                	shr    %cl,%edx
  801ed9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801edd:	09 ca                	or     %ecx,%edx
  801edf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ee3:	89 f1                	mov    %esi,%ecx
  801ee5:	d3 e5                	shl    %cl,%ebp
  801ee7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801eeb:	89 fd                	mov    %edi,%ebp
  801eed:	88 c1                	mov    %al,%cl
  801eef:	d3 ed                	shr    %cl,%ebp
  801ef1:	89 fa                	mov    %edi,%edx
  801ef3:	89 f1                	mov    %esi,%ecx
  801ef5:	d3 e2                	shl    %cl,%edx
  801ef7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801efb:	88 c1                	mov    %al,%cl
  801efd:	d3 ef                	shr    %cl,%edi
  801eff:	09 d7                	or     %edx,%edi
  801f01:	89 f8                	mov    %edi,%eax
  801f03:	89 ea                	mov    %ebp,%edx
  801f05:	f7 74 24 08          	divl   0x8(%esp)
  801f09:	89 d1                	mov    %edx,%ecx
  801f0b:	89 c7                	mov    %eax,%edi
  801f0d:	f7 64 24 0c          	mull   0xc(%esp)
  801f11:	39 d1                	cmp    %edx,%ecx
  801f13:	72 17                	jb     801f2c <__udivdi3+0x10c>
  801f15:	74 09                	je     801f20 <__udivdi3+0x100>
  801f17:	89 fe                	mov    %edi,%esi
  801f19:	31 ff                	xor    %edi,%edi
  801f1b:	e9 41 ff ff ff       	jmp    801e61 <__udivdi3+0x41>
  801f20:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f24:	89 f1                	mov    %esi,%ecx
  801f26:	d3 e2                	shl    %cl,%edx
  801f28:	39 c2                	cmp    %eax,%edx
  801f2a:	73 eb                	jae    801f17 <__udivdi3+0xf7>
  801f2c:	8d 77 ff             	lea    -0x1(%edi),%esi
  801f2f:	31 ff                	xor    %edi,%edi
  801f31:	e9 2b ff ff ff       	jmp    801e61 <__udivdi3+0x41>
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	31 f6                	xor    %esi,%esi
  801f3a:	e9 22 ff ff ff       	jmp    801e61 <__udivdi3+0x41>
	...

00801f40 <__umoddi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	83 ec 20             	sub    $0x20,%esp
  801f46:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f4a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801f4e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f52:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f5a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801f5e:	89 c7                	mov    %eax,%edi
  801f60:	89 f2                	mov    %esi,%edx
  801f62:	85 ed                	test   %ebp,%ebp
  801f64:	75 16                	jne    801f7c <__umoddi3+0x3c>
  801f66:	39 f1                	cmp    %esi,%ecx
  801f68:	0f 86 a6 00 00 00    	jbe    802014 <__umoddi3+0xd4>
  801f6e:	f7 f1                	div    %ecx
  801f70:	89 d0                	mov    %edx,%eax
  801f72:	31 d2                	xor    %edx,%edx
  801f74:	83 c4 20             	add    $0x20,%esp
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
  801f7b:	90                   	nop
  801f7c:	39 f5                	cmp    %esi,%ebp
  801f7e:	0f 87 ac 00 00 00    	ja     802030 <__umoddi3+0xf0>
  801f84:	0f bd c5             	bsr    %ebp,%eax
  801f87:	83 f0 1f             	xor    $0x1f,%eax
  801f8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f8e:	0f 84 a8 00 00 00    	je     80203c <__umoddi3+0xfc>
  801f94:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f98:	d3 e5                	shl    %cl,%ebp
  801f9a:	bf 20 00 00 00       	mov    $0x20,%edi
  801f9f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801fa3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fa7:	89 f9                	mov    %edi,%ecx
  801fa9:	d3 e8                	shr    %cl,%eax
  801fab:	09 e8                	or     %ebp,%eax
  801fad:	89 44 24 18          	mov    %eax,0x18(%esp)
  801fb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fb5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fb9:	d3 e0                	shl    %cl,%eax
  801fbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbf:	89 f2                	mov    %esi,%edx
  801fc1:	d3 e2                	shl    %cl,%edx
  801fc3:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fc7:	d3 e0                	shl    %cl,%eax
  801fc9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801fcd:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	d3 e8                	shr    %cl,%eax
  801fd5:	09 d0                	or     %edx,%eax
  801fd7:	d3 ee                	shr    %cl,%esi
  801fd9:	89 f2                	mov    %esi,%edx
  801fdb:	f7 74 24 18          	divl   0x18(%esp)
  801fdf:	89 d6                	mov    %edx,%esi
  801fe1:	f7 64 24 0c          	mull   0xc(%esp)
  801fe5:	89 c5                	mov    %eax,%ebp
  801fe7:	89 d1                	mov    %edx,%ecx
  801fe9:	39 d6                	cmp    %edx,%esi
  801feb:	72 67                	jb     802054 <__umoddi3+0x114>
  801fed:	74 75                	je     802064 <__umoddi3+0x124>
  801fef:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ff3:	29 e8                	sub    %ebp,%eax
  801ff5:	19 ce                	sbb    %ecx,%esi
  801ff7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	89 f2                	mov    %esi,%edx
  801fff:	89 f9                	mov    %edi,%ecx
  802001:	d3 e2                	shl    %cl,%edx
  802003:	09 d0                	or     %edx,%eax
  802005:	89 f2                	mov    %esi,%edx
  802007:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80200b:	d3 ea                	shr    %cl,%edx
  80200d:	83 c4 20             	add    $0x20,%esp
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    
  802014:	85 c9                	test   %ecx,%ecx
  802016:	75 0b                	jne    802023 <__umoddi3+0xe3>
  802018:	b8 01 00 00 00       	mov    $0x1,%eax
  80201d:	31 d2                	xor    %edx,%edx
  80201f:	f7 f1                	div    %ecx
  802021:	89 c1                	mov    %eax,%ecx
  802023:	89 f0                	mov    %esi,%eax
  802025:	31 d2                	xor    %edx,%edx
  802027:	f7 f1                	div    %ecx
  802029:	89 f8                	mov    %edi,%eax
  80202b:	e9 3e ff ff ff       	jmp    801f6e <__umoddi3+0x2e>
  802030:	89 f2                	mov    %esi,%edx
  802032:	83 c4 20             	add    $0x20,%esp
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	8d 76 00             	lea    0x0(%esi),%esi
  80203c:	39 f5                	cmp    %esi,%ebp
  80203e:	72 04                	jb     802044 <__umoddi3+0x104>
  802040:	39 f9                	cmp    %edi,%ecx
  802042:	77 06                	ja     80204a <__umoddi3+0x10a>
  802044:	89 f2                	mov    %esi,%edx
  802046:	29 cf                	sub    %ecx,%edi
  802048:	19 ea                	sbb    %ebp,%edx
  80204a:	89 f8                	mov    %edi,%eax
  80204c:	83 c4 20             	add    $0x20,%esp
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    
  802053:	90                   	nop
  802054:	89 d1                	mov    %edx,%ecx
  802056:	89 c5                	mov    %eax,%ebp
  802058:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80205c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802060:	eb 8d                	jmp    801fef <__umoddi3+0xaf>
  802062:	66 90                	xchg   %ax,%ax
  802064:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802068:	72 ea                	jb     802054 <__umoddi3+0x114>
  80206a:	89 f1                	mov    %esi,%ecx
  80206c:	eb 81                	jmp    801fef <__umoddi3+0xaf>
