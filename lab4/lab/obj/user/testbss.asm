
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  800041:	e8 16 02 00 00       	call   80025c <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 fb 10 80 	movl   $0x8010fb,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  800070:	e8 ef 00 00 00       	call   800164 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 a0 10 80 	movl   $0x8010a0,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  8000ba:	e8 a5 00 00 00       	call   800164 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 c8 10 80 00 	movl   $0x8010c8,(%esp)
  8000ce:	e8 89 01 00 00       	call   80025c <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 27 11 80 	movl   $0x801127,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  8000f4:	e8 6b 00 00 00       	call   800164 <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80010a:	e8 cc 0a 00 00       	call   800bdb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011b:	c1 e0 07             	shl    $0x7,%eax
  80011e:	29 d0                	sub    %edx,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 f6                	test   %esi,%esi
  80012c:	7e 07                	jle    800135 <libmain+0x39>
		binaryname = argv[0];
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 f3 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800141:	e8 0a 00 00 00       	call   800150 <exit>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015d:	e8 27 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80016c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800175:	e8 61 0a 00 00       	call   800bdb <sys_getenvid>
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800190:	c7 04 24 48 11 80 00 	movl   $0x801148,(%esp)
  800197:	e8 c0 00 00 00       	call   80025c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 50 00 00 00       	call   8001fb <vcprintf>
	cprintf("\n");
  8001ab:	c7 04 24 16 11 80 00 	movl   $0x801116,(%esp)
  8001b2:	e8 a5 00 00 00       	call   80025c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x53>
	...

008001bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 14             	sub    $0x14,%esp
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c6:	8b 03                	mov    (%ebx),%eax
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cf:	40                   	inc    %eax
  8001d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d7:	75 19                	jne    8001f2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e0:	00 
  8001e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 60 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  8001ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f2:	ff 43 04             	incl   0x4(%ebx)
}
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	5b                   	pop    %ebx
  8001f9:	5d                   	pop    %ebp
  8001fa:	c3                   	ret    

008001fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800204:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020b:	00 00 00 
	b.cnt = 0;
  80020e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800215:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021f:	8b 45 08             	mov    0x8(%ebp),%eax
  800222:	89 44 24 08          	mov    %eax,0x8(%esp)
  800226:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	c7 04 24 bc 01 80 00 	movl   $0x8001bc,(%esp)
  800237:	e8 82 01 00 00       	call   8003be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 f8 08 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  800254:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800262:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 87 ff ff ff       	call   8001fb <vcprintf>
	va_end(ap);

	return cnt;
}
  800274:	c9                   	leave  
  800275:	c3                   	ret    
	...

00800278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 3c             	sub    $0x3c,%esp
  800281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800284:	89 d7                	mov    %edx,%edi
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800292:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800295:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800298:	85 c0                	test   %eax,%eax
  80029a:	75 08                	jne    8002a4 <printnum+0x2c>
  80029c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a2:	77 57                	ja     8002fb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a8:	4b                   	dec    %ebx
  8002a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c3:	00 
  8002c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	e8 5a 0b 00 00       	call   800e30 <__udivdi3>
  8002d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 89 ff ff ff       	call   800278 <printnum>
  8002ef:	eb 0f                	jmp    800300 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	89 34 24             	mov    %esi,(%esp)
  8002f8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fb:	4b                   	dec    %ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f f1                	jg     8002f1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800304:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800308:	8b 45 10             	mov    0x10(%ebp),%eax
  80030b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800316:	00 
  800317:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	e8 27 0c 00 00       	call   800f50 <__umoddi3>
  800329:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032d:	0f be 80 6c 11 80 00 	movsbl 0x80116c(%eax),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033a:	83 c4 3c             	add    $0x3c,%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getuint+0x38>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 0e                	jmp    80037a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800382:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800385:	8b 10                	mov    (%eax),%edx
  800387:	3b 50 04             	cmp    0x4(%eax),%edx
  80038a:	73 08                	jae    800394 <sprintputch+0x18>
		*b->buf++ = ch;
  80038c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038f:	88 0a                	mov    %cl,(%edx)
  800391:	42                   	inc    %edx
  800392:	89 10                	mov    %edx,(%eax)
}
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80039c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 02 00 00 00       	call   8003be <vprintfmt>
	va_end(ap);
}
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 4c             	sub    $0x4c,%esp
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 75 10             	mov    0x10(%ebp),%esi
  8003cd:	eb 12                	jmp    8003e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 8b 03 00 00    	je     800762 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	0f b6 06             	movzbl (%esi),%eax
  8003e4:	46                   	inc    %esi
  8003e5:	83 f8 25             	cmp    $0x25,%eax
  8003e8:	75 e5                	jne    8003cf <vprintfmt+0x11>
  8003ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800401:	b9 00 00 00 00       	mov    $0x0,%ecx
  800406:	eb 26                	jmp    80042e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80040f:	eb 1d                	jmp    80042e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800414:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800418:	eb 14                	jmp    80042e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80041d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800424:	eb 08                	jmp    80042e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800426:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800429:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	0f b6 06             	movzbl (%esi),%eax
  800431:	8d 56 01             	lea    0x1(%esi),%edx
  800434:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800437:	8a 16                	mov    (%esi),%dl
  800439:	83 ea 23             	sub    $0x23,%edx
  80043c:	80 fa 55             	cmp    $0x55,%dl
  80043f:	0f 87 01 03 00 00    	ja     800746 <vprintfmt+0x388>
  800445:	0f b6 d2             	movzbl %dl,%edx
  800448:	ff 24 95 40 12 80 00 	jmp    *0x801240(,%edx,4)
  80044f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800452:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800457:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80045e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800461:	8d 50 d0             	lea    -0x30(%eax),%edx
  800464:	83 fa 09             	cmp    $0x9,%edx
  800467:	77 2a                	ja     800493 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800469:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046a:	eb eb                	jmp    800457 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047a:	eb 17                	jmp    800493 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80047c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800480:	78 98                	js     80041a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800485:	eb a7                	jmp    80042e <vprintfmt+0x70>
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800491:	eb 9b                	jmp    80042e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800493:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800497:	79 95                	jns    80042e <vprintfmt+0x70>
  800499:	eb 8b                	jmp    800426 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049f:	eb 8d                	jmp    80042e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	89 04 24             	mov    %eax,(%esp)
  8004b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b9:	e9 23 ff ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	79 02                	jns    8004cf <vprintfmt+0x111>
  8004cd:	f7 d8                	neg    %eax
  8004cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d1:	83 f8 08             	cmp    $0x8,%eax
  8004d4:	7f 0b                	jg     8004e1 <vprintfmt+0x123>
  8004d6:	8b 04 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	75 23                	jne    800504 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e5:	c7 44 24 08 84 11 80 	movl   $0x801184,0x8(%esp)
  8004ec:	00 
  8004ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 9a fe ff ff       	call   800396 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ff:	e9 dd fe ff ff       	jmp    8003e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800504:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800508:	c7 44 24 08 8d 11 80 	movl   $0x80118d,0x8(%esp)
  80050f:	00 
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 14 24             	mov    %edx,(%esp)
  80051a:	e8 77 fe ff ff       	call   800396 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	e9 ba fe ff ff       	jmp    8003e1 <vprintfmt+0x23>
  800527:	89 f9                	mov    %edi,%ecx
  800529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 30                	mov    (%eax),%esi
  80053a:	85 f6                	test   %esi,%esi
  80053c:	75 05                	jne    800543 <vprintfmt+0x185>
				p = "(null)";
  80053e:	be 7d 11 80 00       	mov    $0x80117d,%esi
			if (width > 0 && padc != '-')
  800543:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800547:	0f 8e 84 00 00 00    	jle    8005d1 <vprintfmt+0x213>
  80054d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800551:	74 7e                	je     8005d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800557:	89 34 24             	mov    %esi,(%esp)
  80055a:	e8 ab 02 00 00       	call   80080a <strnlen>
  80055f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800562:	29 c2                	sub    %eax,%edx
  800564:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800567:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80056b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80056e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800571:	89 de                	mov    %ebx,%esi
  800573:	89 d3                	mov    %edx,%ebx
  800575:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	eb 0b                	jmp    800584 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057d:	89 3c 24             	mov    %edi,(%esp)
  800580:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	4b                   	dec    %ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f f1                	jg     800579 <vprintfmt+0x1bb>
  800588:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058b:	89 f3                	mov    %esi,%ebx
  80058d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	79 05                	jns    80059c <vprintfmt+0x1de>
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059f:	29 c2                	sub    %eax,%edx
  8005a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a4:	eb 2b                	jmp    8005d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005aa:	74 18                	je     8005c4 <vprintfmt+0x206>
  8005ac:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005af:	83 fa 5e             	cmp    $0x5e,%edx
  8005b2:	76 10                	jbe    8005c4 <vprintfmt+0x206>
					putch('?', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
  8005c2:	eb 0a                	jmp    8005ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d1:	0f be 06             	movsbl (%esi),%eax
  8005d4:	46                   	inc    %esi
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	74 21                	je     8005fa <vprintfmt+0x23c>
  8005d9:	85 ff                	test   %edi,%edi
  8005db:	78 c9                	js     8005a6 <vprintfmt+0x1e8>
  8005dd:	4f                   	dec    %edi
  8005de:	79 c6                	jns    8005a6 <vprintfmt+0x1e8>
  8005e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e3:	89 de                	mov    %ebx,%esi
  8005e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e8:	eb 18                	jmp    800602 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f7:	4b                   	dec    %ebx
  8005f8:	eb 08                	jmp    800602 <vprintfmt+0x244>
  8005fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800602:	85 db                	test   %ebx,%ebx
  800604:	7f e4                	jg     8005ea <vprintfmt+0x22c>
  800606:	89 7d 08             	mov    %edi,0x8(%ebp)
  800609:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060e:	e9 ce fd ff ff       	jmp    8003e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7e 10                	jle    800628 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 08             	lea    0x8(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 30                	mov    (%eax),%esi
  800623:	8b 78 04             	mov    0x4(%eax),%edi
  800626:	eb 26                	jmp    80064e <vprintfmt+0x290>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	74 12                	je     80063e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 30                	mov    (%eax),%esi
  800637:	89 f7                	mov    %esi,%edi
  800639:	c1 ff 1f             	sar    $0x1f,%edi
  80063c:	eb 10                	jmp    80064e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 30                	mov    (%eax),%esi
  800649:	89 f7                	mov    %esi,%edi
  80064b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064e:	85 ff                	test   %edi,%edi
  800650:	78 0a                	js     80065c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 ac 00 00 00       	jmp    800708 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066a:	f7 de                	neg    %esi
  80066c:	83 d7 00             	adc    $0x0,%edi
  80066f:	f7 df                	neg    %edi
			}
			base = 10;
  800671:	b8 0a 00 00 00       	mov    $0xa,%eax
  800676:	e9 8d 00 00 00       	jmp    800708 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067b:	89 ca                	mov    %ecx,%edx
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
  800680:	e8 bd fc ff ff       	call   800342 <getuint>
  800685:	89 c6                	mov    %eax,%esi
  800687:	89 d7                	mov    %edx,%edi
			base = 10;
  800689:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068e:	eb 78                	jmp    800708 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006bd:	e9 1f fd ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e7:	8b 30                	mov    (%eax),%esi
  8006e9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f3:	eb 13                	jmp    800708 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f5:	89 ca                	mov    %ecx,%edx
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 43 fc ff ff       	call   800342 <getuint>
  8006ff:	89 c6                	mov    %eax,%esi
  800701:	89 d7                	mov    %edx,%edi
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80070c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800710:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800713:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800717:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071b:	89 34 24             	mov    %esi,(%esp)
  80071e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800722:	89 da                	mov    %ebx,%edx
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	e8 4c fb ff ff       	call   800278 <printnum>
			break;
  80072c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072f:	e9 ad fc ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800741:	e9 9b fc ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800746:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800751:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	eb 01                	jmp    800757 <vprintfmt+0x399>
  800756:	4e                   	dec    %esi
  800757:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80075b:	75 f9                	jne    800756 <vprintfmt+0x398>
  80075d:	e9 7f fc ff ff       	jmp    8003e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800762:	83 c4 4c             	add    $0x4c,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 28             	sub    $0x28,%esp
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800776:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800779:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800787:	85 c0                	test   %eax,%eax
  800789:	74 30                	je     8007bb <vsnprintf+0x51>
  80078b:	85 d2                	test   %edx,%edx
  80078d:	7e 33                	jle    8007c2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	c7 04 24 7c 03 80 00 	movl   $0x80037c,(%esp)
  8007ab:	e8 0e fc ff ff       	call   8003be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	eb 0c                	jmp    8007c7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c0:	eb 05                	jmp    8007c7 <vsnprintf+0x5d>
  8007c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 7b ff ff ff       	call   80076a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    
  8007f1:	00 00                	add    %al,(%eax)
	...

008007f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	eb 01                	jmp    800802 <strlen+0xe>
		n++;
  800801:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800806:	75 f9                	jne    800801 <strlen+0xd>
		n++;
	return n;
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	eb 01                	jmp    80081b <strnlen+0x11>
		n++;
  80081a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	39 d0                	cmp    %edx,%eax
  80081d:	74 06                	je     800825 <strnlen+0x1b>
  80081f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800823:	75 f5                	jne    80081a <strnlen+0x10>
		n++;
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800831:	ba 00 00 00 00       	mov    $0x0,%edx
  800836:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800839:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80083c:	42                   	inc    %edx
  80083d:	84 c9                	test   %cl,%cl
  80083f:	75 f5                	jne    800836 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084e:	89 1c 24             	mov    %ebx,(%esp)
  800851:	e8 9e ff ff ff       	call   8007f4 <strlen>
	strcpy(dst + len, src);
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085d:	01 d8                	add    %ebx,%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 c0 ff ff ff       	call   800827 <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	5b                   	pop    %ebx
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800882:	eb 0c                	jmp    800890 <strncpy+0x21>
		*dst++ = *src;
  800884:	8a 1a                	mov    (%edx),%bl
  800886:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 3a 01             	cmpb   $0x1,(%edx)
  80088c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088f:	41                   	inc    %ecx
  800890:	39 f1                	cmp    %esi,%ecx
  800892:	75 f0                	jne    800884 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	75 0a                	jne    8008b4 <strlcpy+0x1c>
  8008aa:	89 f0                	mov    %esi,%eax
  8008ac:	eb 1a                	jmp    8008c8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ae:	88 18                	mov    %bl,(%eax)
  8008b0:	40                   	inc    %eax
  8008b1:	41                   	inc    %ecx
  8008b2:	eb 02                	jmp    8008b6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008b6:	4a                   	dec    %edx
  8008b7:	74 0a                	je     8008c3 <strlcpy+0x2b>
  8008b9:	8a 19                	mov    (%ecx),%bl
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strlcpy+0x16>
  8008bf:	89 c2                	mov    %eax,%edx
  8008c1:	eb 02                	jmp    8008c5 <strlcpy+0x2d>
  8008c3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008c5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c8:	29 f0                	sub    %esi,%eax
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d7:	eb 02                	jmp    8008db <strcmp+0xd>
		p++, q++;
  8008d9:	41                   	inc    %ecx
  8008da:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008db:	8a 01                	mov    (%ecx),%al
  8008dd:	84 c0                	test   %al,%al
  8008df:	74 04                	je     8008e5 <strcmp+0x17>
  8008e1:	3a 02                	cmp    (%edx),%al
  8008e3:	74 f4                	je     8008d9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e5:	0f b6 c0             	movzbl %al,%eax
  8008e8:	0f b6 12             	movzbl (%edx),%edx
  8008eb:	29 d0                	sub    %edx,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008fc:	eb 03                	jmp    800901 <strncmp+0x12>
		n--, p++, q++;
  8008fe:	4a                   	dec    %edx
  8008ff:	40                   	inc    %eax
  800900:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800901:	85 d2                	test   %edx,%edx
  800903:	74 14                	je     800919 <strncmp+0x2a>
  800905:	8a 18                	mov    (%eax),%bl
  800907:	84 db                	test   %bl,%bl
  800909:	74 04                	je     80090f <strncmp+0x20>
  80090b:	3a 19                	cmp    (%ecx),%bl
  80090d:	74 ef                	je     8008fe <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 00             	movzbl (%eax),%eax
  800912:	0f b6 11             	movzbl (%ecx),%edx
  800915:	29 d0                	sub    %edx,%eax
  800917:	eb 05                	jmp    80091e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092a:	eb 05                	jmp    800931 <strchr+0x10>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 0c                	je     80093c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800930:	40                   	inc    %eax
  800931:	8a 10                	mov    (%eax),%dl
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f5                	jne    80092c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800947:	eb 05                	jmp    80094e <strfind+0x10>
		if (*s == c)
  800949:	38 ca                	cmp    %cl,%dl
  80094b:	74 07                	je     800954 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094d:	40                   	inc    %eax
  80094e:	8a 10                	mov    (%eax),%dl
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f5                	jne    800949 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 30                	je     800999 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 25                	jne    800996 <memset+0x40>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 20                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800976:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800979:	89 d3                	mov    %edx,%ebx
  80097b:	c1 e3 08             	shl    $0x8,%ebx
  80097e:	89 d6                	mov    %edx,%esi
  800980:	c1 e6 18             	shl    $0x18,%esi
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e0 10             	shl    $0x10,%eax
  800988:	09 f0                	or     %esi,%eax
  80098a:	09 d0                	or     %edx,%eax
  80098c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 03                	jmp    800999 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	fc                   	cld    
  800997:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800999:	89 f8                	mov    %edi,%eax
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ae:	39 c6                	cmp    %eax,%esi
  8009b0:	73 34                	jae    8009e6 <memmove+0x46>
  8009b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b5:	39 d0                	cmp    %edx,%eax
  8009b7:	73 2d                	jae    8009e6 <memmove+0x46>
		s += n;
		d += n;
  8009b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bc:	f6 c2 03             	test   $0x3,%dl
  8009bf:	75 1b                	jne    8009dc <memmove+0x3c>
  8009c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c7:	75 13                	jne    8009dc <memmove+0x3c>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0e                	jne    8009dc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 07                	jmp    8009e3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009dc:	4f                   	dec    %edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 20                	jmp    800a06 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ec:	75 13                	jne    800a01 <memmove+0x61>
  8009ee:	a8 03                	test   $0x3,%al
  8009f0:	75 0f                	jne    800a01 <memmove+0x61>
  8009f2:	f6 c1 03             	test   $0x3,%cl
  8009f5:	75 0a                	jne    800a01 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fa:	89 c7                	mov    %eax,%edi
  8009fc:	fc                   	cld    
  8009fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ff:	eb 05                	jmp    800a06 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
  800a13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	89 04 24             	mov    %eax,(%esp)
  800a24:	e8 77 ff ff ff       	call   8009a0 <memmove>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3f:	eb 16                	jmp    800a57 <memcmp+0x2c>
		if (*s1 != *s2)
  800a41:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a44:	42                   	inc    %edx
  800a45:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a49:	38 c8                	cmp    %cl,%al
  800a4b:	74 0a                	je     800a57 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a4d:	0f b6 c0             	movzbl %al,%eax
  800a50:	0f b6 c9             	movzbl %cl,%ecx
  800a53:	29 c8                	sub    %ecx,%eax
  800a55:	eb 09                	jmp    800a60 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	39 da                	cmp    %ebx,%edx
  800a59:	75 e6                	jne    800a41 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6e:	89 c2                	mov    %eax,%edx
  800a70:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a73:	eb 05                	jmp    800a7a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a75:	38 08                	cmp    %cl,(%eax)
  800a77:	74 05                	je     800a7e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a79:	40                   	inc    %eax
  800a7a:	39 d0                	cmp    %edx,%eax
  800a7c:	72 f7                	jb     800a75 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 55 08             	mov    0x8(%ebp),%edx
  800a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8c:	eb 01                	jmp    800a8f <strtol+0xf>
		s++;
  800a8e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	8a 02                	mov    (%edx),%al
  800a91:	3c 20                	cmp    $0x20,%al
  800a93:	74 f9                	je     800a8e <strtol+0xe>
  800a95:	3c 09                	cmp    $0x9,%al
  800a97:	74 f5                	je     800a8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a99:	3c 2b                	cmp    $0x2b,%al
  800a9b:	75 08                	jne    800aa5 <strtol+0x25>
		s++;
  800a9d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa3:	eb 13                	jmp    800ab8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa5:	3c 2d                	cmp    $0x2d,%al
  800aa7:	75 0a                	jne    800ab3 <strtol+0x33>
		s++, neg = 1;
  800aa9:	8d 52 01             	lea    0x1(%edx),%edx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb 05                	jmp    800ab8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 05                	je     800ac1 <strtol+0x41>
  800abc:	83 fb 10             	cmp    $0x10,%ebx
  800abf:	75 28                	jne    800ae9 <strtol+0x69>
  800ac1:	8a 02                	mov    (%edx),%al
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 10                	jne    800ad7 <strtol+0x57>
  800ac7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acb:	75 0a                	jne    800ad7 <strtol+0x57>
		s += 2, base = 16;
  800acd:	83 c2 02             	add    $0x2,%edx
  800ad0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad5:	eb 12                	jmp    800ae9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 0e                	jne    800ae9 <strtol+0x69>
  800adb:	3c 30                	cmp    $0x30,%al
  800add:	75 05                	jne    800ae4 <strtol+0x64>
		s++, base = 8;
  800adf:	42                   	inc    %edx
  800ae0:	b3 08                	mov    $0x8,%bl
  800ae2:	eb 05                	jmp    800ae9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ae4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	8a 0a                	mov    (%edx),%cl
  800af2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af5:	80 fb 09             	cmp    $0x9,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x82>
			dig = *s - '0';
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 30             	sub    $0x30,%ecx
  800b00:	eb 1e                	jmp    800b20 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b02:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 08                	ja     800b12 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b0a:	0f be c9             	movsbl %cl,%ecx
  800b0d:	83 e9 57             	sub    $0x57,%ecx
  800b10:	eb 0e                	jmp    800b20 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b12:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b15:	80 fb 19             	cmp    $0x19,%bl
  800b18:	77 12                	ja     800b2c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b1a:	0f be c9             	movsbl %cl,%ecx
  800b1d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b20:	39 f1                	cmp    %esi,%ecx
  800b22:	7d 0c                	jge    800b30 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b24:	42                   	inc    %edx
  800b25:	0f af c6             	imul   %esi,%eax
  800b28:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b2a:	eb c4                	jmp    800af0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b2c:	89 c1                	mov    %eax,%ecx
  800b2e:	eb 02                	jmp    800b32 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b30:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b36:	74 05                	je     800b3d <strtol+0xbd>
		*endptr = (char *) s;
  800b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b3d:	85 ff                	test   %edi,%edi
  800b3f:	74 04                	je     800b45 <strtol+0xc5>
  800b41:	89 c8                	mov    %ecx,%eax
  800b43:	f7 d8                	neg    %eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
	...

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7e 28                	jle    800bd3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800baf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb6:	00 
  800bb7:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800bbe:	00 
  800bbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc6:	00 
  800bc7:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800bce:	e8 91 f5 ff ff       	call   800164 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd3:	83 c4 2c             	add    $0x2c,%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 02 00 00 00       	mov    $0x2,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_yield>:

void
sys_yield(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c22:	be 00 00 00 00       	mov    $0x0,%esi
  800c27:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 f7                	mov    %esi,%edi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 28                	jle    800c65 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c41:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c48:	00 
  800c49:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800c50:	00 
  800c51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c58:	00 
  800c59:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800c60:	e8 ff f4 ff ff       	call   800164 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c65:	83 c4 2c             	add    $0x2c,%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 28                	jle    800cb8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c94:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c9b:	00 
  800c9c:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800ca3:	00 
  800ca4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cab:	00 
  800cac:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800cb3:	e8 ac f4 ff ff       	call   800164 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb8:	83 c4 2c             	add    $0x2c,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 28                	jle    800d0b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cee:	00 
  800cef:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfe:	00 
  800cff:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800d06:	e8 59 f4 ff ff       	call   800164 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0b:	83 c4 2c             	add    $0x2c,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 08 00 00 00       	mov    $0x8,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 28                	jle    800d5e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d41:	00 
  800d42:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800d49:	00 
  800d4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d51:	00 
  800d52:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800d59:	e8 06 f4 ff ff       	call   800164 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5e:	83 c4 2c             	add    $0x2c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	b8 09 00 00 00       	mov    $0x9,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 28                	jle    800db1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d94:	00 
  800d95:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da4:	00 
  800da5:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800dac:	e8 b3 f3 ff ff       	call   800164 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db1:	83 c4 2c             	add    $0x2c,%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	be 00 00 00 00       	mov    $0x0,%esi
  800dc4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 cb                	mov    %ecx,%ebx
  800df4:	89 cf                	mov    %ecx,%edi
  800df6:	89 ce                	mov    %ecx,%esi
  800df8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800e21:	e8 3e f3 ff ff       	call   800164 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e26:	83 c4 2c             	add    $0x2c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
	...

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	83 ec 10             	sub    $0x10,%esp
  800e36:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e3a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e42:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800e46:	89 cd                	mov    %ecx,%ebp
  800e48:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	75 2c                	jne    800e7c <__udivdi3+0x4c>
  800e50:	39 f9                	cmp    %edi,%ecx
  800e52:	77 68                	ja     800ebc <__udivdi3+0x8c>
  800e54:	85 c9                	test   %ecx,%ecx
  800e56:	75 0b                	jne    800e63 <__udivdi3+0x33>
  800e58:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5d:	31 d2                	xor    %edx,%edx
  800e5f:	f7 f1                	div    %ecx
  800e61:	89 c1                	mov    %eax,%ecx
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	89 f8                	mov    %edi,%eax
  800e67:	f7 f1                	div    %ecx
  800e69:	89 c7                	mov    %eax,%edi
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 c6                	mov    %eax,%esi
  800e71:	89 f0                	mov    %esi,%eax
  800e73:	89 fa                	mov    %edi,%edx
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
  800e7c:	39 f8                	cmp    %edi,%eax
  800e7e:	77 2c                	ja     800eac <__udivdi3+0x7c>
  800e80:	0f bd f0             	bsr    %eax,%esi
  800e83:	83 f6 1f             	xor    $0x1f,%esi
  800e86:	75 4c                	jne    800ed4 <__udivdi3+0xa4>
  800e88:	39 f8                	cmp    %edi,%eax
  800e8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e8f:	72 0a                	jb     800e9b <__udivdi3+0x6b>
  800e91:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e95:	0f 87 ad 00 00 00    	ja     800f48 <__udivdi3+0x118>
  800e9b:	be 01 00 00 00       	mov    $0x1,%esi
  800ea0:	89 f0                	mov    %esi,%eax
  800ea2:	89 fa                	mov    %edi,%edx
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    
  800eab:	90                   	nop
  800eac:	31 ff                	xor    %edi,%edi
  800eae:	31 f6                	xor    %esi,%esi
  800eb0:	89 f0                	mov    %esi,%eax
  800eb2:	89 fa                	mov    %edi,%edx
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
  800ebc:	89 fa                	mov    %edi,%edx
  800ebe:	89 f0                	mov    %esi,%eax
  800ec0:	f7 f1                	div    %ecx
  800ec2:	89 c6                	mov    %eax,%esi
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 f0                	mov    %esi,%eax
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
  800ed1:	8d 76 00             	lea    0x0(%esi),%esi
  800ed4:	89 f1                	mov    %esi,%ecx
  800ed6:	d3 e0                	shl    %cl,%eax
  800ed8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	29 f0                	sub    %esi,%eax
  800ee3:	89 ea                	mov    %ebp,%edx
  800ee5:	88 c1                	mov    %al,%cl
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800eed:	09 ca                	or     %ecx,%edx
  800eef:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ef3:	89 f1                	mov    %esi,%ecx
  800ef5:	d3 e5                	shl    %cl,%ebp
  800ef7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800efb:	89 fd                	mov    %edi,%ebp
  800efd:	88 c1                	mov    %al,%cl
  800eff:	d3 ed                	shr    %cl,%ebp
  800f01:	89 fa                	mov    %edi,%edx
  800f03:	89 f1                	mov    %esi,%ecx
  800f05:	d3 e2                	shl    %cl,%edx
  800f07:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f0b:	88 c1                	mov    %al,%cl
  800f0d:	d3 ef                	shr    %cl,%edi
  800f0f:	09 d7                	or     %edx,%edi
  800f11:	89 f8                	mov    %edi,%eax
  800f13:	89 ea                	mov    %ebp,%edx
  800f15:	f7 74 24 08          	divl   0x8(%esp)
  800f19:	89 d1                	mov    %edx,%ecx
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	f7 64 24 0c          	mull   0xc(%esp)
  800f21:	39 d1                	cmp    %edx,%ecx
  800f23:	72 17                	jb     800f3c <__udivdi3+0x10c>
  800f25:	74 09                	je     800f30 <__udivdi3+0x100>
  800f27:	89 fe                	mov    %edi,%esi
  800f29:	31 ff                	xor    %edi,%edi
  800f2b:	e9 41 ff ff ff       	jmp    800e71 <__udivdi3+0x41>
  800f30:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f34:	89 f1                	mov    %esi,%ecx
  800f36:	d3 e2                	shl    %cl,%edx
  800f38:	39 c2                	cmp    %eax,%edx
  800f3a:	73 eb                	jae    800f27 <__udivdi3+0xf7>
  800f3c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800f3f:	31 ff                	xor    %edi,%edi
  800f41:	e9 2b ff ff ff       	jmp    800e71 <__udivdi3+0x41>
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	31 f6                	xor    %esi,%esi
  800f4a:	e9 22 ff ff ff       	jmp    800e71 <__udivdi3+0x41>
	...

00800f50 <__umoddi3>:
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	83 ec 20             	sub    $0x20,%esp
  800f56:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f5a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800f5e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f62:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f6a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f6e:	89 c7                	mov    %eax,%edi
  800f70:	89 f2                	mov    %esi,%edx
  800f72:	85 ed                	test   %ebp,%ebp
  800f74:	75 16                	jne    800f8c <__umoddi3+0x3c>
  800f76:	39 f1                	cmp    %esi,%ecx
  800f78:	0f 86 a6 00 00 00    	jbe    801024 <__umoddi3+0xd4>
  800f7e:	f7 f1                	div    %ecx
  800f80:	89 d0                	mov    %edx,%eax
  800f82:	31 d2                	xor    %edx,%edx
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    
  800f8b:	90                   	nop
  800f8c:	39 f5                	cmp    %esi,%ebp
  800f8e:	0f 87 ac 00 00 00    	ja     801040 <__umoddi3+0xf0>
  800f94:	0f bd c5             	bsr    %ebp,%eax
  800f97:	83 f0 1f             	xor    $0x1f,%eax
  800f9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9e:	0f 84 a8 00 00 00    	je     80104c <__umoddi3+0xfc>
  800fa4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa8:	d3 e5                	shl    %cl,%ebp
  800faa:	bf 20 00 00 00       	mov    $0x20,%edi
  800faf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800fb3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb7:	89 f9                	mov    %edi,%ecx
  800fb9:	d3 e8                	shr    %cl,%eax
  800fbb:	09 e8                	or     %ebp,%eax
  800fbd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800fc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fc5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fc9:	d3 e0                	shl    %cl,%eax
  800fcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fcf:	89 f2                	mov    %esi,%edx
  800fd1:	d3 e2                	shl    %cl,%edx
  800fd3:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd7:	d3 e0                	shl    %cl,%eax
  800fd9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800fdd:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fe1:	89 f9                	mov    %edi,%ecx
  800fe3:	d3 e8                	shr    %cl,%eax
  800fe5:	09 d0                	or     %edx,%eax
  800fe7:	d3 ee                	shr    %cl,%esi
  800fe9:	89 f2                	mov    %esi,%edx
  800feb:	f7 74 24 18          	divl   0x18(%esp)
  800fef:	89 d6                	mov    %edx,%esi
  800ff1:	f7 64 24 0c          	mull   0xc(%esp)
  800ff5:	89 c5                	mov    %eax,%ebp
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	39 d6                	cmp    %edx,%esi
  800ffb:	72 67                	jb     801064 <__umoddi3+0x114>
  800ffd:	74 75                	je     801074 <__umoddi3+0x124>
  800fff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801003:	29 e8                	sub    %ebp,%eax
  801005:	19 ce                	sbb    %ecx,%esi
  801007:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	89 f9                	mov    %edi,%ecx
  801011:	d3 e2                	shl    %cl,%edx
  801013:	09 d0                	or     %edx,%eax
  801015:	89 f2                	mov    %esi,%edx
  801017:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	83 c4 20             	add    $0x20,%esp
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    
  801024:	85 c9                	test   %ecx,%ecx
  801026:	75 0b                	jne    801033 <__umoddi3+0xe3>
  801028:	b8 01 00 00 00       	mov    $0x1,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	f7 f1                	div    %ecx
  801031:	89 c1                	mov    %eax,%ecx
  801033:	89 f0                	mov    %esi,%eax
  801035:	31 d2                	xor    %edx,%edx
  801037:	f7 f1                	div    %ecx
  801039:	89 f8                	mov    %edi,%eax
  80103b:	e9 3e ff ff ff       	jmp    800f7e <__umoddi3+0x2e>
  801040:	89 f2                	mov    %esi,%edx
  801042:	83 c4 20             	add    $0x20,%esp
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    
  801049:	8d 76 00             	lea    0x0(%esi),%esi
  80104c:	39 f5                	cmp    %esi,%ebp
  80104e:	72 04                	jb     801054 <__umoddi3+0x104>
  801050:	39 f9                	cmp    %edi,%ecx
  801052:	77 06                	ja     80105a <__umoddi3+0x10a>
  801054:	89 f2                	mov    %esi,%edx
  801056:	29 cf                	sub    %ecx,%edi
  801058:	19 ea                	sbb    %ebp,%edx
  80105a:	89 f8                	mov    %edi,%eax
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    
  801063:	90                   	nop
  801064:	89 d1                	mov    %edx,%ecx
  801066:	89 c5                	mov    %eax,%ebp
  801068:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80106c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801070:	eb 8d                	jmp    800fff <__umoddi3+0xaf>
  801072:	66 90                	xchg   %ax,%ax
  801074:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801078:	72 ea                	jb     801064 <__umoddi3+0x114>
  80107a:	89 f1                	mov    %esi,%ecx
  80107c:	eb 81                	jmp    800fff <__umoddi3+0xaf>
