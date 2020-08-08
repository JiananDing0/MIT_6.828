
obj/user/faultalloc:     file format elf32-i386


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
  800044:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  80004b:	e8 08 02 00 00       	call   800258 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 a6 0b 00 00       	call   800c15 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 60 11 80 	movl   $0x801160,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 4a 11 80 00 	movl   $0x80114a,(%esp)
  800092:	e8 c9 00 00 00       	call   800160 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 8c 11 80 	movl   $0x80118c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 12 07 00 00       	call   8007c5 <snprintf>
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
  8000c6:	e8 61 0d 00 00       	call   800e2c <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 5c 11 80 00 	movl   $0x80115c,(%esp)
  8000da:	e8 79 01 00 00       	call   800258 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 5c 11 80 00 	movl   $0x80115c,(%esp)
  8000ee:	e8 65 01 00 00       	call   800258 <cprintf>
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
  800106:	e8 cc 0a 00 00       	call   800bd7 <sys_getenvid>
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
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 27 0a 00 00       	call   800b85 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800168:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800171:	e8 61 0a 00 00       	call   800bd7 <sys_getenvid>
  800176:	8b 55 0c             	mov    0xc(%ebp),%edx
  800179:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017d:	8b 55 08             	mov    0x8(%ebp),%edx
  800180:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800184:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	c7 04 24 b8 11 80 00 	movl   $0x8011b8,(%esp)
  800193:	e8 c0 00 00 00       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800198:	89 74 24 04          	mov    %esi,0x4(%esp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 50 00 00 00       	call   8001f7 <vcprintf>
	cprintf("\n");
  8001a7:	c7 04 24 5e 11 80 00 	movl   $0x80115e,(%esp)
  8001ae:	e8 a5 00 00 00       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x53>
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
  8002cd:	e8 1e 0c 00 00       	call   800ef0 <__udivdi3>
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
  800320:	e8 eb 0c 00 00       	call   801010 <__umoddi3>
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	0f be 80 db 11 80 00 	movsbl 0x8011db(%eax),%eax
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
  800444:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
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
  8004cd:	83 f8 08             	cmp    $0x8,%eax
  8004d0:	7f 0b                	jg     8004dd <vprintfmt+0x123>
  8004d2:	8b 04 85 00 14 80 00 	mov    0x801400(,%eax,4),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	75 23                	jne    800500 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e1:	c7 44 24 08 f3 11 80 	movl   $0x8011f3,0x8(%esp)
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
  800504:	c7 44 24 08 fc 11 80 	movl   $0x8011fc,0x8(%esp)
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
  80053a:	be ec 11 80 00       	mov    $0x8011ec,%esi
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
  800bb3:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800bba:	00 
  800bbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc2:	00 
  800bc3:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800bca:	e8 91 f5 ff ff       	call   800160 <_panic>

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
  800c01:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c45:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c4c:	00 
  800c4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c54:	00 
  800c55:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800c5c:	e8 ff f4 ff ff       	call   800160 <_panic>

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
  800c98:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c9f:	00 
  800ca0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca7:	00 
  800ca8:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800caf:	e8 ac f4 ff ff       	call   800160 <_panic>

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
  800ceb:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfa:	00 
  800cfb:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d02:	e8 59 f4 ff ff       	call   800160 <_panic>

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
  800d3e:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d45:	00 
  800d46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4d:	00 
  800d4e:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d55:	e8 06 f4 ff ff       	call   800160 <_panic>

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

00800d62 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d83:	7e 28                	jle    800dad <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800da8:	e8 b3 f3 ff ff       	call   800160 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 cb                	mov    %ecx,%ebx
  800df0:	89 cf                	mov    %ecx,%edi
  800df2:	89 ce                	mov    %ecx,%esi
  800df4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800e1d:	e8 3e f3 ff ff       	call   800160 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	83 c4 2c             	add    $0x2c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
	...

00800e2c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e32:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e39:	0f 85 80 00 00 00    	jne    800ebf <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800e3f:	a1 04 20 80 00       	mov    0x802004,%eax
  800e44:	8b 40 48             	mov    0x48(%eax),%eax
  800e47:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e56:	ee 
  800e57:	89 04 24             	mov    %eax,(%esp)
  800e5a:	e8 b6 fd ff ff       	call   800c15 <sys_page_alloc>
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 20                	jns    800e83 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800e63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e67:	c7 44 24 08 50 14 80 	movl   $0x801450,0x8(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800e76:	00 
  800e77:	c7 04 24 ac 14 80 00 	movl   $0x8014ac,(%esp)
  800e7e:	e8 dd f2 ff ff       	call   800160 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800e83:	a1 04 20 80 00       	mov    0x802004,%eax
  800e88:	8b 40 48             	mov    0x48(%eax),%eax
  800e8b:	c7 44 24 04 cc 0e 80 	movl   $0x800ecc,0x4(%esp)
  800e92:	00 
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 c7 fe ff ff       	call   800d62 <sys_env_set_pgfault_upcall>
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 20                	jns    800ebf <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800e9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ea3:	c7 44 24 08 7c 14 80 	movl   $0x80147c,0x8(%esp)
  800eaa:	00 
  800eab:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800eb2:	00 
  800eb3:	c7 04 24 ac 14 80 00 	movl   $0x8014ac,(%esp)
  800eba:	e8 a1 f2 ff ff       	call   800160 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    
  800ec9:	00 00                	add    %al,(%eax)
	...

00800ecc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ecc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ecd:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ed2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ed4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  800ed7:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800edb:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800edd:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800ee0:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800ee1:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  800ee4:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  800ee6:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800ee9:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800eea:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800eed:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800eee:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800eef:	c3                   	ret    

00800ef0 <__udivdi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	83 ec 10             	sub    $0x10,%esp
  800ef6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800efa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800efe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f02:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800f06:	89 cd                	mov    %ecx,%ebp
  800f08:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	75 2c                	jne    800f3c <__udivdi3+0x4c>
  800f10:	39 f9                	cmp    %edi,%ecx
  800f12:	77 68                	ja     800f7c <__udivdi3+0x8c>
  800f14:	85 c9                	test   %ecx,%ecx
  800f16:	75 0b                	jne    800f23 <__udivdi3+0x33>
  800f18:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1d:	31 d2                	xor    %edx,%edx
  800f1f:	f7 f1                	div    %ecx
  800f21:	89 c1                	mov    %eax,%ecx
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	89 f8                	mov    %edi,%eax
  800f27:	f7 f1                	div    %ecx
  800f29:	89 c7                	mov    %eax,%edi
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	f7 f1                	div    %ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	89 f0                	mov    %esi,%eax
  800f33:	89 fa                	mov    %edi,%edx
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
  800f3c:	39 f8                	cmp    %edi,%eax
  800f3e:	77 2c                	ja     800f6c <__udivdi3+0x7c>
  800f40:	0f bd f0             	bsr    %eax,%esi
  800f43:	83 f6 1f             	xor    $0x1f,%esi
  800f46:	75 4c                	jne    800f94 <__udivdi3+0xa4>
  800f48:	39 f8                	cmp    %edi,%eax
  800f4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f4f:	72 0a                	jb     800f5b <__udivdi3+0x6b>
  800f51:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f55:	0f 87 ad 00 00 00    	ja     801008 <__udivdi3+0x118>
  800f5b:	be 01 00 00 00       	mov    $0x1,%esi
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	89 fa                	mov    %edi,%edx
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    
  800f6b:	90                   	nop
  800f6c:	31 ff                	xor    %edi,%edi
  800f6e:	31 f6                	xor    %esi,%esi
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	89 fa                	mov    %edi,%edx
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    
  800f7b:	90                   	nop
  800f7c:	89 fa                	mov    %edi,%edx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	f7 f1                	div    %ecx
  800f82:	89 c6                	mov    %eax,%esi
  800f84:	31 ff                	xor    %edi,%edi
  800f86:	89 f0                	mov    %esi,%eax
  800f88:	89 fa                	mov    %edi,%edx
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
  800f91:	8d 76 00             	lea    0x0(%esi),%esi
  800f94:	89 f1                	mov    %esi,%ecx
  800f96:	d3 e0                	shl    %cl,%eax
  800f98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa1:	29 f0                	sub    %esi,%eax
  800fa3:	89 ea                	mov    %ebp,%edx
  800fa5:	88 c1                	mov    %al,%cl
  800fa7:	d3 ea                	shr    %cl,%edx
  800fa9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800fad:	09 ca                	or     %ecx,%edx
  800faf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fb3:	89 f1                	mov    %esi,%ecx
  800fb5:	d3 e5                	shl    %cl,%ebp
  800fb7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800fbb:	89 fd                	mov    %edi,%ebp
  800fbd:	88 c1                	mov    %al,%cl
  800fbf:	d3 ed                	shr    %cl,%ebp
  800fc1:	89 fa                	mov    %edi,%edx
  800fc3:	89 f1                	mov    %esi,%ecx
  800fc5:	d3 e2                	shl    %cl,%edx
  800fc7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fcb:	88 c1                	mov    %al,%cl
  800fcd:	d3 ef                	shr    %cl,%edi
  800fcf:	09 d7                	or     %edx,%edi
  800fd1:	89 f8                	mov    %edi,%eax
  800fd3:	89 ea                	mov    %ebp,%edx
  800fd5:	f7 74 24 08          	divl   0x8(%esp)
  800fd9:	89 d1                	mov    %edx,%ecx
  800fdb:	89 c7                	mov    %eax,%edi
  800fdd:	f7 64 24 0c          	mull   0xc(%esp)
  800fe1:	39 d1                	cmp    %edx,%ecx
  800fe3:	72 17                	jb     800ffc <__udivdi3+0x10c>
  800fe5:	74 09                	je     800ff0 <__udivdi3+0x100>
  800fe7:	89 fe                	mov    %edi,%esi
  800fe9:	31 ff                	xor    %edi,%edi
  800feb:	e9 41 ff ff ff       	jmp    800f31 <__udivdi3+0x41>
  800ff0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ff4:	89 f1                	mov    %esi,%ecx
  800ff6:	d3 e2                	shl    %cl,%edx
  800ff8:	39 c2                	cmp    %eax,%edx
  800ffa:	73 eb                	jae    800fe7 <__udivdi3+0xf7>
  800ffc:	8d 77 ff             	lea    -0x1(%edi),%esi
  800fff:	31 ff                	xor    %edi,%edi
  801001:	e9 2b ff ff ff       	jmp    800f31 <__udivdi3+0x41>
  801006:	66 90                	xchg   %ax,%ax
  801008:	31 f6                	xor    %esi,%esi
  80100a:	e9 22 ff ff ff       	jmp    800f31 <__udivdi3+0x41>
	...

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	83 ec 20             	sub    $0x20,%esp
  801016:	8b 44 24 30          	mov    0x30(%esp),%eax
  80101a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80101e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801022:	8b 74 24 34          	mov    0x34(%esp),%esi
  801026:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80102a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80102e:	89 c7                	mov    %eax,%edi
  801030:	89 f2                	mov    %esi,%edx
  801032:	85 ed                	test   %ebp,%ebp
  801034:	75 16                	jne    80104c <__umoddi3+0x3c>
  801036:	39 f1                	cmp    %esi,%ecx
  801038:	0f 86 a6 00 00 00    	jbe    8010e4 <__umoddi3+0xd4>
  80103e:	f7 f1                	div    %ecx
  801040:	89 d0                	mov    %edx,%eax
  801042:	31 d2                	xor    %edx,%edx
  801044:	83 c4 20             	add    $0x20,%esp
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    
  80104b:	90                   	nop
  80104c:	39 f5                	cmp    %esi,%ebp
  80104e:	0f 87 ac 00 00 00    	ja     801100 <__umoddi3+0xf0>
  801054:	0f bd c5             	bsr    %ebp,%eax
  801057:	83 f0 1f             	xor    $0x1f,%eax
  80105a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80105e:	0f 84 a8 00 00 00    	je     80110c <__umoddi3+0xfc>
  801064:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801068:	d3 e5                	shl    %cl,%ebp
  80106a:	bf 20 00 00 00       	mov    $0x20,%edi
  80106f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801073:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801077:	89 f9                	mov    %edi,%ecx
  801079:	d3 e8                	shr    %cl,%eax
  80107b:	09 e8                	or     %ebp,%eax
  80107d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801081:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801085:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801089:	d3 e0                	shl    %cl,%eax
  80108b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108f:	89 f2                	mov    %esi,%edx
  801091:	d3 e2                	shl    %cl,%edx
  801093:	8b 44 24 14          	mov    0x14(%esp),%eax
  801097:	d3 e0                	shl    %cl,%eax
  801099:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80109d:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010a1:	89 f9                	mov    %edi,%ecx
  8010a3:	d3 e8                	shr    %cl,%eax
  8010a5:	09 d0                	or     %edx,%eax
  8010a7:	d3 ee                	shr    %cl,%esi
  8010a9:	89 f2                	mov    %esi,%edx
  8010ab:	f7 74 24 18          	divl   0x18(%esp)
  8010af:	89 d6                	mov    %edx,%esi
  8010b1:	f7 64 24 0c          	mull   0xc(%esp)
  8010b5:	89 c5                	mov    %eax,%ebp
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	39 d6                	cmp    %edx,%esi
  8010bb:	72 67                	jb     801124 <__umoddi3+0x114>
  8010bd:	74 75                	je     801134 <__umoddi3+0x124>
  8010bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010c3:	29 e8                	sub    %ebp,%eax
  8010c5:	19 ce                	sbb    %ecx,%esi
  8010c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010cb:	d3 e8                	shr    %cl,%eax
  8010cd:	89 f2                	mov    %esi,%edx
  8010cf:	89 f9                	mov    %edi,%ecx
  8010d1:	d3 e2                	shl    %cl,%edx
  8010d3:	09 d0                	or     %edx,%eax
  8010d5:	89 f2                	mov    %esi,%edx
  8010d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010db:	d3 ea                	shr    %cl,%edx
  8010dd:	83 c4 20             	add    $0x20,%esp
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    
  8010e4:	85 c9                	test   %ecx,%ecx
  8010e6:	75 0b                	jne    8010f3 <__umoddi3+0xe3>
  8010e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ed:	31 d2                	xor    %edx,%edx
  8010ef:	f7 f1                	div    %ecx
  8010f1:	89 c1                	mov    %eax,%ecx
  8010f3:	89 f0                	mov    %esi,%eax
  8010f5:	31 d2                	xor    %edx,%edx
  8010f7:	f7 f1                	div    %ecx
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	e9 3e ff ff ff       	jmp    80103e <__umoddi3+0x2e>
  801100:	89 f2                	mov    %esi,%edx
  801102:	83 c4 20             	add    $0x20,%esp
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    
  801109:	8d 76 00             	lea    0x0(%esi),%esi
  80110c:	39 f5                	cmp    %esi,%ebp
  80110e:	72 04                	jb     801114 <__umoddi3+0x104>
  801110:	39 f9                	cmp    %edi,%ecx
  801112:	77 06                	ja     80111a <__umoddi3+0x10a>
  801114:	89 f2                	mov    %esi,%edx
  801116:	29 cf                	sub    %ecx,%edi
  801118:	19 ea                	sbb    %ebp,%edx
  80111a:	89 f8                	mov    %edi,%eax
  80111c:	83 c4 20             	add    $0x20,%esp
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
  801123:	90                   	nop
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 c5                	mov    %eax,%ebp
  801128:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80112c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801130:	eb 8d                	jmp    8010bf <__umoddi3+0xaf>
  801132:	66 90                	xchg   %ax,%ax
  801134:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801138:	72 ea                	jb     801124 <__umoddi3+0x114>
  80113a:	89 f1                	mov    %esi,%ecx
  80113c:	eb 81                	jmp    8010bf <__umoddi3+0xaf>
