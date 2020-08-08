
obj/user/testbss.debug:     file format elf32-i386


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
  80003a:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  800041:	e8 1e 02 00 00       	call   800264 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 3b 20 80 	movl   $0x80203b,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 58 20 80 00 	movl   $0x802058,(%esp)
  800070:	e8 f7 00 00 00       	call   80016c <_panic>
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
  800082:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

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
  800096:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 e0 1f 80 	movl   $0x801fe0,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 58 20 80 00 	movl   $0x802058,(%esp)
  8000ba:	e8 ad 00 00 00       	call   80016c <_panic>
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
  8000c7:	c7 04 24 08 20 80 00 	movl   $0x802008,(%esp)
  8000ce:	e8 91 01 00 00       	call   800264 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 67 20 80 	movl   $0x802067,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 58 20 80 00 	movl   $0x802058,(%esp)
  8000f4:	e8 73 00 00 00       	call   80016c <_panic>
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
  80010a:	e8 d4 0a 00 00       	call   800be3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011b:	c1 e0 07             	shl    $0x7,%eax
  80011e:	29 d0                	sub    %edx,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 f6                	test   %esi,%esi
  80012c:	7e 07                	jle    800135 <libmain+0x39>
		binaryname = argv[0];
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800156:	e8 18 0f 00 00       	call   801073 <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 2a 0a 00 00       	call   800b91 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80017d:	e8 61 0a 00 00       	call   800be3 <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 88 20 80 00 	movl   $0x802088,(%esp)
  80019f:	e8 c0 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 50 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 56 20 80 00 	movl   $0x802056,(%esp)
  8001ba:	e8 a5 00 00 00       	call   800264 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	40                   	inc    %eax
  8001d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 19                	jne    8001fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e8:	00 
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 60 09 00 00       	call   800b54 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fa:	ff 43 04             	incl   0x4(%ebx)
}
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	5b                   	pop    %ebx
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  80023f:	e8 82 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 f8 08 00 00       	call   800b54 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 87 ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	75 08                	jne    8002ac <printnum+0x2c>
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002aa:	77 57                	ja     800303 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b0:	4b                   	dec    %ebx
  8002b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cb:	00 
  8002cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 82 1a 00 00       	call   801d60 <__udivdi3>
  8002de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	89 fa                	mov    %edi,%edx
  8002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f2:	e8 89 ff ff ff       	call   800280 <printnum>
  8002f7:	eb 0f                	jmp    800308 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	89 34 24             	mov    %esi,(%esp)
  800300:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	4b                   	dec    %ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f f1                	jg     8002f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031e:	00 
  80031f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	e8 4f 1b 00 00       	call   801e80 <__umoddi3>
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	0f be 80 ab 20 80 00 	movsbl 0x8020ab(%eax),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800342:	83 c4 3c             	add    $0x3c,%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	3b 50 04             	cmp    0x4(%eax),%edx
  800392:	73 08                	jae    80039c <sprintputch+0x18>
		*b->buf++ = ch;
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 0a                	mov    %cl,(%edx)
  800399:	42                   	inc    %edx
  80039a:	89 10                	mov    %edx,(%eax)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 02 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 4c             	sub    $0x4c,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 8b 03 00 00    	je     80076a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e5                	jne    8003d7 <vprintfmt+0x11>
  8003f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	eb 26                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800413:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800417:	eb 1d                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800420:	eb 14                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042c:	eb 08                	jmp    800436 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	0f b6 06             	movzbl (%esi),%eax
  800439:	8d 56 01             	lea    0x1(%esi),%edx
  80043c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043f:	8a 16                	mov    (%esi),%dl
  800441:	83 ea 23             	sub    $0x23,%edx
  800444:	80 fa 55             	cmp    $0x55,%dl
  800447:	0f 87 01 03 00 00    	ja     80074e <vprintfmt+0x388>
  80044d:	0f b6 d2             	movzbl %dl,%edx
  800450:	ff 24 95 e0 21 80 00 	jmp    *0x8021e0(,%edx,4)
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800462:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	77 2a                	ja     80049b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800472:	eb eb                	jmp    80045f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800482:	eb 17                	jmp    80049b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	78 98                	js     800422 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048d:	eb a7                	jmp    800436 <vprintfmt+0x70>
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800499:	eb 9b                	jmp    800436 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049f:	79 95                	jns    800436 <vprintfmt+0x70>
  8004a1:	eb 8b                	jmp    80042e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a7:	eb 8d                	jmp    800436 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 23 ff ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <vprintfmt+0x111>
  8004d5:	f7 d8                	neg    %eax
  8004d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 0f             	cmp    $0xf,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x123>
  8004de:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 23                	jne    80050c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ed:	c7 44 24 08 c3 20 80 	movl   $0x8020c3,0x8(%esp)
  8004f4:	00 
  8004f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 9a fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800507:	e9 dd fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 9e 24 80 	movl   $0x80249e,0x8(%esp)
  800517:	00 
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 55 08             	mov    0x8(%ebp),%edx
  80051f:	89 14 24             	mov    %edx,(%esp)
  800522:	e8 77 fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 ba fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
  80052f:	89 f9                	mov    %edi,%ecx
  800531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 30                	mov    (%eax),%esi
  800542:	85 f6                	test   %esi,%esi
  800544:	75 05                	jne    80054b <vprintfmt+0x185>
				p = "(null)";
  800546:	be bc 20 80 00       	mov    $0x8020bc,%esi
			if (width > 0 && padc != '-')
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	0f 8e 84 00 00 00    	jle    8005d9 <vprintfmt+0x213>
  800555:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800559:	74 7e                	je     8005d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 ab 02 00 00       	call   800812 <strnlen>
  800567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800573:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800576:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800579:	89 de                	mov    %ebx,%esi
  80057b:	89 d3                	mov    %edx,%ebx
  80057d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	89 3c 24             	mov    %edi,(%esp)
  800588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f f1                	jg     800581 <vprintfmt+0x1bb>
  800590:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800593:	89 f3                	mov    %esi,%ebx
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059b:	85 c0                	test   %eax,%eax
  80059d:	79 05                	jns    8005a4 <vprintfmt+0x1de>
  80059f:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a7:	29 c2                	sub    %eax,%edx
  8005a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ac:	eb 2b                	jmp    8005d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b2:	74 18                	je     8005cc <vprintfmt+0x206>
  8005b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ba:	76 10                	jbe    8005cc <vprintfmt+0x206>
					putch('?', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
  8005ca:	eb 0a                	jmp    8005d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	46                   	inc    %esi
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	74 21                	je     800602 <vprintfmt+0x23c>
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	78 c9                	js     8005ae <vprintfmt+0x1e8>
  8005e5:	4f                   	dec    %edi
  8005e6:	79 c6                	jns    8005ae <vprintfmt+0x1e8>
  8005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005eb:	89 de                	mov    %ebx,%esi
  8005ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f0:	eb 18                	jmp    80060a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	4b                   	dec    %ebx
  800600:	eb 08                	jmp    80060a <vprintfmt+0x244>
  800602:	8b 7d 08             	mov    0x8(%ebp),%edi
  800605:	89 de                	mov    %ebx,%esi
  800607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7f e4                	jg     8005f2 <vprintfmt+0x22c>
  80060e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800611:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800616:	e9 ce fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7e 10                	jle    800630 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	8b 78 04             	mov    0x4(%eax),%edi
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x290>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 12                	je     800646 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	89 f7                	mov    %esi,%edi
  800641:	c1 ff 1f             	sar    $0x1f,%edi
  800644:	eb 10                	jmp    800656 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	89 f7                	mov    %esi,%edi
  800653:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800656:	85 ff                	test   %edi,%edi
  800658:	78 0a                	js     800664 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 ac 00 00 00       	jmp    800710 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800672:	f7 de                	neg    %esi
  800674:	83 d7 00             	adc    $0x0,%edi
  800677:	f7 df                	neg    %edi
			}
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	e9 8d 00 00 00       	jmp    800710 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800683:	89 ca                	mov    %ecx,%edx
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	e8 bd fc ff ff       	call   80034a <getuint>
  80068d:	89 c6                	mov    %eax,%esi
  80068f:	89 d7                	mov    %edx,%edi
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800696:	eb 78                	jmp    800710 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006aa:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c5:	e9 1f fd ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ef:	8b 30                	mov    (%eax),%esi
  8006f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006fb:	eb 13                	jmp    800710 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006fd:	89 ca                	mov    %ecx,%edx
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 43 fc ff ff       	call   80034a <getuint>
  800707:	89 c6                	mov    %eax,%esi
  800709:	89 d7                	mov    %edx,%edi
			base = 16;
  80070b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800710:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800714:	89 54 24 10          	mov    %edx,0x10(%esp)
  800718:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80071b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80071f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800723:	89 34 24             	mov    %esi,(%esp)
  800726:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072a:	89 da                	mov    %ebx,%edx
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	e8 4c fb ff ff       	call   800280 <printnum>
			break;
  800734:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800737:	e9 ad fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	89 04 24             	mov    %eax,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800749:	e9 9b fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800752:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800759:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075c:	eb 01                	jmp    80075f <vprintfmt+0x399>
  80075e:	4e                   	dec    %esi
  80075f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800763:	75 f9                	jne    80075e <vprintfmt+0x398>
  800765:	e9 7f fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80076a:	83 c4 4c             	add    $0x4c,%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 28             	sub    $0x28,%esp
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800781:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800785:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800788:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078f:	85 c0                	test   %eax,%eax
  800791:	74 30                	je     8007c3 <vsnprintf+0x51>
  800793:	85 d2                	test   %edx,%edx
  800795:	7e 33                	jle    8007ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ac:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  8007b3:	e8 0e fc ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c1:	eb 0c                	jmp    8007cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c8:	eb 05                	jmp    8007cf <vsnprintf+0x5d>
  8007ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	e8 7b ff ff ff       	call   800772 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    
  8007f9:	00 00                	add    %al,(%eax)
	...

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 01                	jmp    80080a <strlen+0xe>
		n++;
  800809:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080e:	75 f9                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 01                	jmp    800823 <strnlen+0x11>
		n++;
  800822:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800823:	39 d0                	cmp    %edx,%eax
  800825:	74 06                	je     80082d <strnlen+0x1b>
  800827:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082b:	75 f5                	jne    800822 <strnlen+0x10>
		n++;
	return n;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
  80083e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800841:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800844:	42                   	inc    %edx
  800845:	84 c9                	test   %cl,%cl
  800847:	75 f5                	jne    80083e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800856:	89 1c 24             	mov    %ebx,(%esp)
  800859:	e8 9e ff ff ff       	call   8007fc <strlen>
	strcpy(dst + len, src);
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 54 24 04          	mov    %edx,0x4(%esp)
  800865:	01 d8                	add    %ebx,%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 c0 ff ff ff       	call   80082f <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	83 c4 08             	add    $0x8,%esp
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800882:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800885:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088a:	eb 0c                	jmp    800898 <strncpy+0x21>
		*dst++ = *src;
  80088c:	8a 1a                	mov    (%edx),%bl
  80088e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800891:	80 3a 01             	cmpb   $0x1,(%edx)
  800894:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800897:	41                   	inc    %ecx
  800898:	39 f1                	cmp    %esi,%ecx
  80089a:	75 f0                	jne    80088c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089c:	5b                   	pop    %ebx
  80089d:	5e                   	pop    %esi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	75 0a                	jne    8008bc <strlcpy+0x1c>
  8008b2:	89 f0                	mov    %esi,%eax
  8008b4:	eb 1a                	jmp    8008d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b6:	88 18                	mov    %bl,(%eax)
  8008b8:	40                   	inc    %eax
  8008b9:	41                   	inc    %ecx
  8008ba:	eb 02                	jmp    8008be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008be:	4a                   	dec    %edx
  8008bf:	74 0a                	je     8008cb <strlcpy+0x2b>
  8008c1:	8a 19                	mov    (%ecx),%bl
  8008c3:	84 db                	test   %bl,%bl
  8008c5:	75 ef                	jne    8008b6 <strlcpy+0x16>
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	eb 02                	jmp    8008cd <strlcpy+0x2d>
  8008cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d0:	29 f0                	sub    %esi,%eax
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008df:	eb 02                	jmp    8008e3 <strcmp+0xd>
		p++, q++;
  8008e1:	41                   	inc    %ecx
  8008e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e3:	8a 01                	mov    (%ecx),%al
  8008e5:	84 c0                	test   %al,%al
  8008e7:	74 04                	je     8008ed <strcmp+0x17>
  8008e9:	3a 02                	cmp    (%edx),%al
  8008eb:	74 f4                	je     8008e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ed:	0f b6 c0             	movzbl %al,%eax
  8008f0:	0f b6 12             	movzbl (%edx),%edx
  8008f3:	29 d0                	sub    %edx,%eax
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800901:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800904:	eb 03                	jmp    800909 <strncmp+0x12>
		n--, p++, q++;
  800906:	4a                   	dec    %edx
  800907:	40                   	inc    %eax
  800908:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800909:	85 d2                	test   %edx,%edx
  80090b:	74 14                	je     800921 <strncmp+0x2a>
  80090d:	8a 18                	mov    (%eax),%bl
  80090f:	84 db                	test   %bl,%bl
  800911:	74 04                	je     800917 <strncmp+0x20>
  800913:	3a 19                	cmp    (%ecx),%bl
  800915:	74 ef                	je     800906 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800917:	0f b6 00             	movzbl (%eax),%eax
  80091a:	0f b6 11             	movzbl (%ecx),%edx
  80091d:	29 d0                	sub    %edx,%eax
  80091f:	eb 05                	jmp    800926 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800926:	5b                   	pop    %ebx
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800932:	eb 05                	jmp    800939 <strchr+0x10>
		if (*s == c)
  800934:	38 ca                	cmp    %cl,%dl
  800936:	74 0c                	je     800944 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800938:	40                   	inc    %eax
  800939:	8a 10                	mov    (%eax),%dl
  80093b:	84 d2                	test   %dl,%dl
  80093d:	75 f5                	jne    800934 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094f:	eb 05                	jmp    800956 <strfind+0x10>
		if (*s == c)
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 07                	je     80095c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800955:	40                   	inc    %eax
  800956:	8a 10                	mov    (%eax),%dl
  800958:	84 d2                	test   %dl,%dl
  80095a:	75 f5                	jne    800951 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	57                   	push   %edi
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 7d 08             	mov    0x8(%ebp),%edi
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096d:	85 c9                	test   %ecx,%ecx
  80096f:	74 30                	je     8009a1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800971:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800977:	75 25                	jne    80099e <memset+0x40>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 20                	jne    80099e <memset+0x40>
		c &= 0xFF;
  80097e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800981:	89 d3                	mov    %edx,%ebx
  800983:	c1 e3 08             	shl    $0x8,%ebx
  800986:	89 d6                	mov    %edx,%esi
  800988:	c1 e6 18             	shl    $0x18,%esi
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	c1 e0 10             	shl    $0x10,%eax
  800990:	09 f0                	or     %esi,%eax
  800992:	09 d0                	or     %edx,%eax
  800994:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800996:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb 03                	jmp    8009a1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099e:	fc                   	cld    
  80099f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a1:	89 f8                	mov    %edi,%eax
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b6:	39 c6                	cmp    %eax,%esi
  8009b8:	73 34                	jae    8009ee <memmove+0x46>
  8009ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bd:	39 d0                	cmp    %edx,%eax
  8009bf:	73 2d                	jae    8009ee <memmove+0x46>
		s += n;
		d += n;
  8009c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	f6 c2 03             	test   $0x3,%dl
  8009c7:	75 1b                	jne    8009e4 <memmove+0x3c>
  8009c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cf:	75 13                	jne    8009e4 <memmove+0x3c>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 0e                	jne    8009e4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d6:	83 ef 04             	sub    $0x4,%edi
  8009d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009df:	fd                   	std    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 07                	jmp    8009eb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e4:	4f                   	dec    %edi
  8009e5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e8:	fd                   	std    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009eb:	fc                   	cld    
  8009ec:	eb 20                	jmp    800a0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f4:	75 13                	jne    800a09 <memmove+0x61>
  8009f6:	a8 03                	test   $0x3,%al
  8009f8:	75 0f                	jne    800a09 <memmove+0x61>
  8009fa:	f6 c1 03             	test   $0x3,%cl
  8009fd:	75 0a                	jne    800a09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a07:	eb 05                	jmp    800a0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a09:	89 c7                	mov    %eax,%edi
  800a0b:	fc                   	cld    
  800a0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a18:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	89 04 24             	mov    %eax,(%esp)
  800a2c:	e8 77 ff ff ff       	call   8009a8 <memmove>
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a42:	ba 00 00 00 00       	mov    $0x0,%edx
  800a47:	eb 16                	jmp    800a5f <memcmp+0x2c>
		if (*s1 != *s2)
  800a49:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a4c:	42                   	inc    %edx
  800a4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a51:	38 c8                	cmp    %cl,%al
  800a53:	74 0a                	je     800a5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a55:	0f b6 c0             	movzbl %al,%eax
  800a58:	0f b6 c9             	movzbl %cl,%ecx
  800a5b:	29 c8                	sub    %ecx,%eax
  800a5d:	eb 09                	jmp    800a68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5f:	39 da                	cmp    %ebx,%edx
  800a61:	75 e6                	jne    800a49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a76:	89 c2                	mov    %eax,%edx
  800a78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7b:	eb 05                	jmp    800a82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7d:	38 08                	cmp    %cl,(%eax)
  800a7f:	74 05                	je     800a86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a81:	40                   	inc    %eax
  800a82:	39 d0                	cmp    %edx,%eax
  800a84:	72 f7                	jb     800a7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a94:	eb 01                	jmp    800a97 <strtol+0xf>
		s++;
  800a96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a97:	8a 02                	mov    (%edx),%al
  800a99:	3c 20                	cmp    $0x20,%al
  800a9b:	74 f9                	je     800a96 <strtol+0xe>
  800a9d:	3c 09                	cmp    $0x9,%al
  800a9f:	74 f5                	je     800a96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa1:	3c 2b                	cmp    $0x2b,%al
  800aa3:	75 08                	jne    800aad <strtol+0x25>
		s++;
  800aa5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aab:	eb 13                	jmp    800ac0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aad:	3c 2d                	cmp    $0x2d,%al
  800aaf:	75 0a                	jne    800abb <strtol+0x33>
		s++, neg = 1;
  800ab1:	8d 52 01             	lea    0x1(%edx),%edx
  800ab4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab9:	eb 05                	jmp    800ac0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	85 db                	test   %ebx,%ebx
  800ac2:	74 05                	je     800ac9 <strtol+0x41>
  800ac4:	83 fb 10             	cmp    $0x10,%ebx
  800ac7:	75 28                	jne    800af1 <strtol+0x69>
  800ac9:	8a 02                	mov    (%edx),%al
  800acb:	3c 30                	cmp    $0x30,%al
  800acd:	75 10                	jne    800adf <strtol+0x57>
  800acf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad3:	75 0a                	jne    800adf <strtol+0x57>
		s += 2, base = 16;
  800ad5:	83 c2 02             	add    $0x2,%edx
  800ad8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800add:	eb 12                	jmp    800af1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	75 0e                	jne    800af1 <strtol+0x69>
  800ae3:	3c 30                	cmp    $0x30,%al
  800ae5:	75 05                	jne    800aec <strtol+0x64>
		s++, base = 8;
  800ae7:	42                   	inc    %edx
  800ae8:	b3 08                	mov    $0x8,%bl
  800aea:	eb 05                	jmp    800af1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af8:	8a 0a                	mov    (%edx),%cl
  800afa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800afd:	80 fb 09             	cmp    $0x9,%bl
  800b00:	77 08                	ja     800b0a <strtol+0x82>
			dig = *s - '0';
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 30             	sub    $0x30,%ecx
  800b08:	eb 1e                	jmp    800b28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b0d:	80 fb 19             	cmp    $0x19,%bl
  800b10:	77 08                	ja     800b1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800b12:	0f be c9             	movsbl %cl,%ecx
  800b15:	83 e9 57             	sub    $0x57,%ecx
  800b18:	eb 0e                	jmp    800b28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b1d:	80 fb 19             	cmp    $0x19,%bl
  800b20:	77 12                	ja     800b34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b22:	0f be c9             	movsbl %cl,%ecx
  800b25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b28:	39 f1                	cmp    %esi,%ecx
  800b2a:	7d 0c                	jge    800b38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b2c:	42                   	inc    %edx
  800b2d:	0f af c6             	imul   %esi,%eax
  800b30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b32:	eb c4                	jmp    800af8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b34:	89 c1                	mov    %eax,%ecx
  800b36:	eb 02                	jmp    800b3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3e:	74 05                	je     800b45 <strtol+0xbd>
		*endptr = (char *) s;
  800b40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b45:	85 ff                	test   %edi,%edi
  800b47:	74 04                	je     800b4d <strtol+0xc5>
  800b49:	89 c8                	mov    %ecx,%eax
  800b4b:	f7 d8                	neg    %eax
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    
	...

00800b54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	89 c3                	mov    %eax,%ebx
  800b67:	89 c7                	mov    %eax,%edi
  800b69:	89 c6                	mov    %eax,%esi
  800b6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	89 cb                	mov    %ecx,%ebx
  800ba9:	89 cf                	mov    %ecx,%edi
  800bab:	89 ce                	mov    %ecx,%esi
  800bad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7e 28                	jle    800bdb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bbe:	00 
  800bbf:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800bc6:	00 
  800bc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bce:	00 
  800bcf:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800bd6:	e8 91 f5 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdb:	83 c4 2c             	add    $0x2c,%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bee:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf3:	89 d1                	mov    %edx,%ecx
  800bf5:	89 d3                	mov    %edx,%ebx
  800bf7:	89 d7                	mov    %edx,%edi
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_yield>:

void
sys_yield(void)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c12:	89 d1                	mov    %edx,%ecx
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	89 d7                	mov    %edx,%edi
  800c18:	89 d6                	mov    %edx,%esi
  800c1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	be 00 00 00 00       	mov    $0x0,%esi
  800c2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 f7                	mov    %esi,%edi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 28                	jle    800c6d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c49:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c50:	00 
  800c51:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c58:	00 
  800c59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c60:	00 
  800c61:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c68:	e8 ff f4 ff ff       	call   80016c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6d:	83 c4 2c             	add    $0x2c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c83:	8b 75 18             	mov    0x18(%ebp),%esi
  800c86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 28                	jle    800cc0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ca3:	00 
  800ca4:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800cab:	00 
  800cac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb3:	00 
  800cb4:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800cbb:	e8 ac f4 ff ff       	call   80016c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc0:	83 c4 2c             	add    $0x2c,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 28                	jle    800d13 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800cfe:	00 
  800cff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d06:	00 
  800d07:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d0e:	e8 59 f4 ff ff       	call   80016c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d13:	83 c4 2c             	add    $0x2c,%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 28                	jle    800d66 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d42:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d49:	00 
  800d4a:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d51:	00 
  800d52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d59:	00 
  800d5a:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d61:	e8 06 f4 ff ff       	call   80016c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d66:	83 c4 2c             	add    $0x2c,%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7e 28                	jle    800db9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d95:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800da4:	00 
  800da5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dac:	00 
  800dad:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800db4:	e8 b3 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db9:	83 c4 2c             	add    $0x2c,%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 28                	jle    800e0c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800def:	00 
  800df0:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800df7:	00 
  800df8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dff:	00 
  800e00:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800e07:	e8 60 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0c:	83 c4 2c             	add    $0x2c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	be 00 00 00 00       	mov    $0x0,%esi
  800e1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4d:	89 cb                	mov    %ecx,%ebx
  800e4f:	89 cf                	mov    %ecx,%edi
  800e51:	89 ce                	mov    %ecx,%esi
  800e53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e55:	85 c0                	test   %eax,%eax
  800e57:	7e 28                	jle    800e81 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e64:	00 
  800e65:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e74:	00 
  800e75:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800e7c:	e8 eb f2 ff ff       	call   80016c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e81:	83 c4 2c             	add    $0x2c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	00 00                	add    %al,(%eax)
	...

00800e8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	05 00 00 00 30       	add    $0x30000000,%eax
  800e97:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	89 04 24             	mov    %eax,(%esp)
  800ea8:	e8 df ff ff ff       	call   800e8c <fd2num>
  800ead:	05 20 00 0d 00       	add    $0xd0020,%eax
  800eb2:	c1 e0 0c             	shl    $0xc,%eax
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	53                   	push   %ebx
  800ebb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ebe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ec3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 16             	shr    $0x16,%edx
  800eca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	74 11                	je     800ee7 <fd_alloc+0x30>
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 0c             	shr    $0xc,%edx
  800edb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	75 09                	jne    800ef0 <fd_alloc+0x39>
			*fd_store = fd;
  800ee7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	eb 17                	jmp    800f07 <fd_alloc+0x50>
  800ef0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800efa:	75 c7                	jne    800ec3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f02:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f07:	5b                   	pop    %ebx
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f10:	83 f8 1f             	cmp    $0x1f,%eax
  800f13:	77 36                	ja     800f4b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f15:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f1a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1d:	89 c2                	mov    %eax,%edx
  800f1f:	c1 ea 16             	shr    $0x16,%edx
  800f22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	74 24                	je     800f52 <fd_lookup+0x48>
  800f2e:	89 c2                	mov    %eax,%edx
  800f30:	c1 ea 0c             	shr    $0xc,%edx
  800f33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3a:	f6 c2 01             	test   $0x1,%dl
  800f3d:	74 1a                	je     800f59 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f42:	89 02                	mov    %eax,(%edx)
	return 0;
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
  800f49:	eb 13                	jmp    800f5e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f50:	eb 0c                	jmp    800f5e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f57:	eb 05                	jmp    800f5e <fd_lookup+0x54>
  800f59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	53                   	push   %ebx
  800f64:	83 ec 14             	sub    $0x14,%esp
  800f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	eb 0e                	jmp    800f82 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f74:	39 08                	cmp    %ecx,(%eax)
  800f76:	75 09                	jne    800f81 <dev_lookup+0x21>
			*dev = devtab[i];
  800f78:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7f:	eb 33                	jmp    800fb4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f81:	42                   	inc    %edx
  800f82:	8b 04 95 4c 24 80 00 	mov    0x80244c(,%edx,4),%eax
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	75 e7                	jne    800f74 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f8d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f92:	8b 40 48             	mov    0x48(%eax),%eax
  800f95:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9d:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  800fa4:	e8 bb f2 ff ff       	call   800264 <cprintf>
	*dev = 0;
  800fa9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800faf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb4:	83 c4 14             	add    $0x14,%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 30             	sub    $0x30,%esp
  800fc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc5:	8a 45 0c             	mov    0xc(%ebp),%al
  800fc8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcb:	89 34 24             	mov    %esi,(%esp)
  800fce:	e8 b9 fe ff ff       	call   800e8c <fd2num>
  800fd3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fd6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fda:	89 04 24             	mov    %eax,(%esp)
  800fdd:	e8 28 ff ff ff       	call   800f0a <fd_lookup>
  800fe2:	89 c3                	mov    %eax,%ebx
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 05                	js     800fed <fd_close+0x33>
	    || fd != fd2)
  800fe8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800feb:	74 0d                	je     800ffa <fd_close+0x40>
		return (must_exist ? r : 0);
  800fed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ff1:	75 46                	jne    801039 <fd_close+0x7f>
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	eb 3f                	jmp    801039 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801001:	8b 06                	mov    (%esi),%eax
  801003:	89 04 24             	mov    %eax,(%esp)
  801006:	e8 55 ff ff ff       	call   800f60 <dev_lookup>
  80100b:	89 c3                	mov    %eax,%ebx
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 18                	js     801029 <fd_close+0x6f>
		if (dev->dev_close)
  801011:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801014:	8b 40 10             	mov    0x10(%eax),%eax
  801017:	85 c0                	test   %eax,%eax
  801019:	74 09                	je     801024 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80101b:	89 34 24             	mov    %esi,(%esp)
  80101e:	ff d0                	call   *%eax
  801020:	89 c3                	mov    %eax,%ebx
  801022:	eb 05                	jmp    801029 <fd_close+0x6f>
		else
			r = 0;
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801029:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801034:	e8 8f fc ff ff       	call   800cc8 <sys_page_unmap>
	return r;
}
  801039:	89 d8                	mov    %ebx,%eax
  80103b:	83 c4 30             	add    $0x30,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	89 04 24             	mov    %eax,(%esp)
  801055:	e8 b0 fe ff ff       	call   800f0a <fd_lookup>
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 13                	js     801071 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80105e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801065:	00 
  801066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801069:	89 04 24             	mov    %eax,(%esp)
  80106c:	e8 49 ff ff ff       	call   800fba <fd_close>
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <close_all>:

void
close_all(void)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	53                   	push   %ebx
  801077:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107f:	89 1c 24             	mov    %ebx,(%esp)
  801082:	e8 bb ff ff ff       	call   801042 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801087:	43                   	inc    %ebx
  801088:	83 fb 20             	cmp    $0x20,%ebx
  80108b:	75 f2                	jne    80107f <close_all+0xc>
		close(i);
}
  80108d:	83 c4 14             	add    $0x14,%esp
  801090:	5b                   	pop    %ebx
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 4c             	sub    $0x4c,%esp
  80109c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80109f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 59 fe ff ff       	call   800f0a <fd_lookup>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	0f 88 e1 00 00 00    	js     80119c <dup+0x109>
		return r;
	close(newfdnum);
  8010bb:	89 3c 24             	mov    %edi,(%esp)
  8010be:	e8 7f ff ff ff       	call   801042 <close>

	newfd = INDEX2FD(newfdnum);
  8010c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	e8 c5 fd ff ff       	call   800e9c <fd2data>
  8010d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010d9:	89 34 24             	mov    %esi,(%esp)
  8010dc:	e8 bb fd ff ff       	call   800e9c <fd2data>
  8010e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e4:	89 d8                	mov    %ebx,%eax
  8010e6:	c1 e8 16             	shr    $0x16,%eax
  8010e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f0:	a8 01                	test   $0x1,%al
  8010f2:	74 46                	je     80113a <dup+0xa7>
  8010f4:	89 d8                	mov    %ebx,%eax
  8010f6:	c1 e8 0c             	shr    $0xc,%eax
  8010f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801100:	f6 c2 01             	test   $0x1,%dl
  801103:	74 35                	je     80113a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801105:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110c:	25 07 0e 00 00       	and    $0xe07,%eax
  801111:	89 44 24 10          	mov    %eax,0x10(%esp)
  801115:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801123:	00 
  801124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112f:	e8 41 fb ff ff       	call   800c75 <sys_page_map>
  801134:	89 c3                	mov    %eax,%ebx
  801136:	85 c0                	test   %eax,%eax
  801138:	78 3b                	js     801175 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 0c             	shr    $0xc,%edx
  801142:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801149:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80114f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801153:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801157:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80115e:	00 
  80115f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801163:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116a:	e8 06 fb ff ff       	call   800c75 <sys_page_map>
  80116f:	89 c3                	mov    %eax,%ebx
  801171:	85 c0                	test   %eax,%eax
  801173:	79 25                	jns    80119a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801175:	89 74 24 04          	mov    %esi,0x4(%esp)
  801179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801180:	e8 43 fb ff ff       	call   800cc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801185:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801193:	e8 30 fb ff ff       	call   800cc8 <sys_page_unmap>
	return r;
  801198:	eb 02                	jmp    80119c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80119a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	83 c4 4c             	add    $0x4c,%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 24             	sub    $0x24,%esp
  8011ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b7:	89 1c 24             	mov    %ebx,(%esp)
  8011ba:	e8 4b fd ff ff       	call   800f0a <fd_lookup>
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 6d                	js     801230 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	8b 00                	mov    (%eax),%eax
  8011cf:	89 04 24             	mov    %eax,(%esp)
  8011d2:	e8 89 fd ff ff       	call   800f60 <dev_lookup>
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 55                	js     801230 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	8b 50 08             	mov    0x8(%eax),%edx
  8011e1:	83 e2 03             	and    $0x3,%edx
  8011e4:	83 fa 01             	cmp    $0x1,%edx
  8011e7:	75 23                	jne    80120c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f9:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801200:	e8 5f f0 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  801205:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120a:	eb 24                	jmp    801230 <read+0x8a>
	}
	if (!dev->dev_read)
  80120c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120f:	8b 52 08             	mov    0x8(%edx),%edx
  801212:	85 d2                	test   %edx,%edx
  801214:	74 15                	je     80122b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801216:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801219:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80121d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801220:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801224:	89 04 24             	mov    %eax,(%esp)
  801227:	ff d2                	call   *%edx
  801229:	eb 05                	jmp    801230 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80122b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801230:	83 c4 24             	add    $0x24,%esp
  801233:	5b                   	pop    %ebx
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	57                   	push   %edi
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	83 ec 1c             	sub    $0x1c,%esp
  80123f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801242:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124a:	eb 23                	jmp    80126f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124c:	89 f0                	mov    %esi,%eax
  80124e:	29 d8                	sub    %ebx,%eax
  801250:	89 44 24 08          	mov    %eax,0x8(%esp)
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
  801257:	01 d8                	add    %ebx,%eax
  801259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125d:	89 3c 24             	mov    %edi,(%esp)
  801260:	e8 41 ff ff ff       	call   8011a6 <read>
		if (m < 0)
  801265:	85 c0                	test   %eax,%eax
  801267:	78 10                	js     801279 <readn+0x43>
			return m;
		if (m == 0)
  801269:	85 c0                	test   %eax,%eax
  80126b:	74 0a                	je     801277 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126d:	01 c3                	add    %eax,%ebx
  80126f:	39 f3                	cmp    %esi,%ebx
  801271:	72 d9                	jb     80124c <readn+0x16>
  801273:	89 d8                	mov    %ebx,%eax
  801275:	eb 02                	jmp    801279 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801277:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801279:	83 c4 1c             	add    $0x1c,%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5f                   	pop    %edi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	53                   	push   %ebx
  801285:	83 ec 24             	sub    $0x24,%esp
  801288:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801292:	89 1c 24             	mov    %ebx,(%esp)
  801295:	e8 70 fc ff ff       	call   800f0a <fd_lookup>
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 68                	js     801306 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a8:	8b 00                	mov    (%eax),%eax
  8012aa:	89 04 24             	mov    %eax,(%esp)
  8012ad:	e8 ae fc ff ff       	call   800f60 <dev_lookup>
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 50                	js     801306 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012bd:	75 23                	jne    8012e2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bf:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012c4:	8b 40 48             	mov    0x48(%eax),%eax
  8012c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  8012d6:	e8 89 ef ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb 24                	jmp    801306 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e8:	85 d2                	test   %edx,%edx
  8012ea:	74 15                	je     801301 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012fa:	89 04 24             	mov    %eax,(%esp)
  8012fd:	ff d2                	call   *%edx
  8012ff:	eb 05                	jmp    801306 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801301:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801306:	83 c4 24             	add    $0x24,%esp
  801309:	5b                   	pop    %ebx
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <seek>:

int
seek(int fdnum, off_t offset)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801312:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	89 04 24             	mov    %eax,(%esp)
  80131f:	e8 e6 fb ff ff       	call   800f0a <fd_lookup>
  801324:	85 c0                	test   %eax,%eax
  801326:	78 0e                	js     801336 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801328:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 24             	sub    $0x24,%esp
  80133f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	89 44 24 04          	mov    %eax,0x4(%esp)
  801349:	89 1c 24             	mov    %ebx,(%esp)
  80134c:	e8 b9 fb ff ff       	call   800f0a <fd_lookup>
  801351:	85 c0                	test   %eax,%eax
  801353:	78 61                	js     8013b6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135f:	8b 00                	mov    (%eax),%eax
  801361:	89 04 24             	mov    %eax,(%esp)
  801364:	e8 f7 fb ff ff       	call   800f60 <dev_lookup>
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 49                	js     8013b6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801374:	75 23                	jne    801399 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801376:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80137b:	8b 40 48             	mov    0x48(%eax),%eax
  80137e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  80138d:	e8 d2 ee ff ff       	call   800264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801397:	eb 1d                	jmp    8013b6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801399:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139c:	8b 52 18             	mov    0x18(%edx),%edx
  80139f:	85 d2                	test   %edx,%edx
  8013a1:	74 0e                	je     8013b1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013aa:	89 04 24             	mov    %eax,(%esp)
  8013ad:	ff d2                	call   *%edx
  8013af:	eb 05                	jmp    8013b6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013b6:	83 c4 24             	add    $0x24,%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 24             	sub    $0x24,%esp
  8013c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 32 fb ff ff       	call   800f0a <fd_lookup>
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 52                	js     80142e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e6:	8b 00                	mov    (%eax),%eax
  8013e8:	89 04 24             	mov    %eax,(%esp)
  8013eb:	e8 70 fb ff ff       	call   800f60 <dev_lookup>
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 3a                	js     80142e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013fb:	74 2c                	je     801429 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801400:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801407:	00 00 00 
	stat->st_isdir = 0;
  80140a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801411:	00 00 00 
	stat->st_dev = dev;
  801414:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80141a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80141e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801421:	89 14 24             	mov    %edx,(%esp)
  801424:	ff 50 14             	call   *0x14(%eax)
  801427:	eb 05                	jmp    80142e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801429:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80142e:	83 c4 24             	add    $0x24,%esp
  801431:	5b                   	pop    %ebx
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	56                   	push   %esi
  801438:	53                   	push   %ebx
  801439:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80143c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801443:	00 
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 fe 01 00 00       	call   80164d <open>
  80144f:	89 c3                	mov    %eax,%ebx
  801451:	85 c0                	test   %eax,%eax
  801453:	78 1b                	js     801470 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801455:	8b 45 0c             	mov    0xc(%ebp),%eax
  801458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145c:	89 1c 24             	mov    %ebx,(%esp)
  80145f:	e8 58 ff ff ff       	call   8013bc <fstat>
  801464:	89 c6                	mov    %eax,%esi
	close(fd);
  801466:	89 1c 24             	mov    %ebx,(%esp)
  801469:	e8 d4 fb ff ff       	call   801042 <close>
	return r;
  80146e:	89 f3                	mov    %esi,%ebx
}
  801470:	89 d8                	mov    %ebx,%eax
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    
  801479:	00 00                	add    %al,(%eax)
	...

0080147c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	83 ec 10             	sub    $0x10,%esp
  801484:	89 c3                	mov    %eax,%ebx
  801486:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801488:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80148f:	75 11                	jne    8014a2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801491:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801498:	e8 38 08 00 00       	call   801cd5 <ipc_find_env>
  80149d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014a9:	00 
  8014aa:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  8014b1:	00 
  8014b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 a8 07 00 00       	call   801c6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014ca:	00 
  8014cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d6:	e8 29 07 00 00       	call   801c04 <ipc_recv>
}
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ee:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f6:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801500:	b8 02 00 00 00       	mov    $0x2,%eax
  801505:	e8 72 ff ff ff       	call   80147c <fsipc>
}
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	8b 40 0c             	mov    0xc(%eax),%eax
  801518:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80151d:	ba 00 00 00 00       	mov    $0x0,%edx
  801522:	b8 06 00 00 00       	mov    $0x6,%eax
  801527:	e8 50 ff ff ff       	call   80147c <fsipc>
}
  80152c:	c9                   	leave  
  80152d:	c3                   	ret    

0080152e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 14             	sub    $0x14,%esp
  801535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801538:	8b 45 08             	mov    0x8(%ebp),%eax
  80153b:	8b 40 0c             	mov    0xc(%eax),%eax
  80153e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801543:	ba 00 00 00 00       	mov    $0x0,%edx
  801548:	b8 05 00 00 00       	mov    $0x5,%eax
  80154d:	e8 2a ff ff ff       	call   80147c <fsipc>
  801552:	85 c0                	test   %eax,%eax
  801554:	78 2b                	js     801581 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801556:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  80155d:	00 
  80155e:	89 1c 24             	mov    %ebx,(%esp)
  801561:	e8 c9 f2 ff ff       	call   80082f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801566:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80156b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801571:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801576:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80157c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801581:	83 c4 14             	add    $0x14,%esp
  801584:	5b                   	pop    %ebx
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80158d:	c7 44 24 08 5c 24 80 	movl   $0x80245c,0x8(%esp)
  801594:	00 
  801595:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80159c:	00 
  80159d:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  8015a4:	e8 c3 eb ff ff       	call   80016c <_panic>

008015a9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 10             	sub    $0x10,%esp
  8015b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ba:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8015bf:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8015cf:	e8 a8 fe ff ff       	call   80147c <fsipc>
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 6a                	js     801644 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015da:	39 c6                	cmp    %eax,%esi
  8015dc:	73 24                	jae    801602 <devfile_read+0x59>
  8015de:	c7 44 24 0c 85 24 80 	movl   $0x802485,0xc(%esp)
  8015e5:	00 
  8015e6:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  8015ed:	00 
  8015ee:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015f5:	00 
  8015f6:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  8015fd:	e8 6a eb ff ff       	call   80016c <_panic>
	assert(r <= PGSIZE);
  801602:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801607:	7e 24                	jle    80162d <devfile_read+0x84>
  801609:	c7 44 24 0c a1 24 80 	movl   $0x8024a1,0xc(%esp)
  801610:	00 
  801611:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  801618:	00 
  801619:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801620:	00 
  801621:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  801628:	e8 3f eb ff ff       	call   80016c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80162d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801631:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801638:	00 
  801639:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 64 f3 ff ff       	call   8009a8 <memmove>
	return r;
}
  801644:	89 d8                	mov    %ebx,%eax
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	83 ec 20             	sub    $0x20,%esp
  801655:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801658:	89 34 24             	mov    %esi,(%esp)
  80165b:	e8 9c f1 ff ff       	call   8007fc <strlen>
  801660:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801665:	7f 60                	jg     8016c7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	e8 45 f8 ff ff       	call   800eb7 <fd_alloc>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	85 c0                	test   %eax,%eax
  801676:	78 54                	js     8016cc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801678:	89 74 24 04          	mov    %esi,0x4(%esp)
  80167c:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  801683:	e8 a7 f1 ff ff       	call   80082f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168b:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801690:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801693:	b8 01 00 00 00       	mov    $0x1,%eax
  801698:	e8 df fd ff ff       	call   80147c <fsipc>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	79 15                	jns    8016b8 <open+0x6b>
		fd_close(fd, 0);
  8016a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016aa:	00 
  8016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ae:	89 04 24             	mov    %eax,(%esp)
  8016b1:	e8 04 f9 ff ff       	call   800fba <fd_close>
		return r;
  8016b6:	eb 14                	jmp    8016cc <open+0x7f>
	}

	return fd2num(fd);
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	89 04 24             	mov    %eax,(%esp)
  8016be:	e8 c9 f7 ff ff       	call   800e8c <fd2num>
  8016c3:	89 c3                	mov    %eax,%ebx
  8016c5:	eb 05                	jmp    8016cc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016c7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016cc:	89 d8                	mov    %ebx,%eax
  8016ce:	83 c4 20             	add    $0x20,%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e5:	e8 92 fd ff ff       	call   80147c <fsipc>
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	83 ec 10             	sub    $0x10,%esp
  8016f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	89 04 24             	mov    %eax,(%esp)
  8016fd:	e8 9a f7 ff ff       	call   800e9c <fd2data>
  801702:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801704:	c7 44 24 04 ad 24 80 	movl   $0x8024ad,0x4(%esp)
  80170b:	00 
  80170c:	89 34 24             	mov    %esi,(%esp)
  80170f:	e8 1b f1 ff ff       	call   80082f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801714:	8b 43 04             	mov    0x4(%ebx),%eax
  801717:	2b 03                	sub    (%ebx),%eax
  801719:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80171f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801726:	00 00 00 
	stat->st_dev = &devpipe;
  801729:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801730:	30 80 00 
	return 0;
}
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    

0080173f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	53                   	push   %ebx
  801743:	83 ec 14             	sub    $0x14,%esp
  801746:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801749:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801754:	e8 6f f5 ff ff       	call   800cc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801759:	89 1c 24             	mov    %ebx,(%esp)
  80175c:	e8 3b f7 ff ff       	call   800e9c <fd2data>
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176c:	e8 57 f5 ff ff       	call   800cc8 <sys_page_unmap>
}
  801771:	83 c4 14             	add    $0x14,%esp
  801774:	5b                   	pop    %ebx
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	57                   	push   %edi
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	83 ec 2c             	sub    $0x2c,%esp
  801780:	89 c7                	mov    %eax,%edi
  801782:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801785:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80178a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80178d:	89 3c 24             	mov    %edi,(%esp)
  801790:	e8 87 05 00 00       	call   801d1c <pageref>
  801795:	89 c6                	mov    %eax,%esi
  801797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80179a:	89 04 24             	mov    %eax,(%esp)
  80179d:	e8 7a 05 00 00       	call   801d1c <pageref>
  8017a2:	39 c6                	cmp    %eax,%esi
  8017a4:	0f 94 c0             	sete   %al
  8017a7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017aa:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8017b0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017b3:	39 cb                	cmp    %ecx,%ebx
  8017b5:	75 08                	jne    8017bf <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8017b7:	83 c4 2c             	add    $0x2c,%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	5f                   	pop    %edi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017bf:	83 f8 01             	cmp    $0x1,%eax
  8017c2:	75 c1                	jne    801785 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017c4:	8b 42 58             	mov    0x58(%edx),%eax
  8017c7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8017ce:	00 
  8017cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d7:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  8017de:	e8 81 ea ff ff       	call   800264 <cprintf>
  8017e3:	eb a0                	jmp    801785 <_pipeisclosed+0xe>

008017e5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	57                   	push   %edi
  8017e9:	56                   	push   %esi
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 1c             	sub    $0x1c,%esp
  8017ee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017f1:	89 34 24             	mov    %esi,(%esp)
  8017f4:	e8 a3 f6 ff ff       	call   800e9c <fd2data>
  8017f9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801800:	eb 3c                	jmp    80183e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801802:	89 da                	mov    %ebx,%edx
  801804:	89 f0                	mov    %esi,%eax
  801806:	e8 6c ff ff ff       	call   801777 <_pipeisclosed>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	75 38                	jne    801847 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80180f:	e8 ee f3 ff ff       	call   800c02 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801814:	8b 43 04             	mov    0x4(%ebx),%eax
  801817:	8b 13                	mov    (%ebx),%edx
  801819:	83 c2 20             	add    $0x20,%edx
  80181c:	39 d0                	cmp    %edx,%eax
  80181e:	73 e2                	jae    801802 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801820:	8b 55 0c             	mov    0xc(%ebp),%edx
  801823:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801826:	89 c2                	mov    %eax,%edx
  801828:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80182e:	79 05                	jns    801835 <devpipe_write+0x50>
  801830:	4a                   	dec    %edx
  801831:	83 ca e0             	or     $0xffffffe0,%edx
  801834:	42                   	inc    %edx
  801835:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801839:	40                   	inc    %eax
  80183a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183d:	47                   	inc    %edi
  80183e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801841:	75 d1                	jne    801814 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801843:	89 f8                	mov    %edi,%eax
  801845:	eb 05                	jmp    80184c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801847:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80184c:	83 c4 1c             	add    $0x1c,%esp
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	5f                   	pop    %edi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	57                   	push   %edi
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 1c             	sub    $0x1c,%esp
  80185d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801860:	89 3c 24             	mov    %edi,(%esp)
  801863:	e8 34 f6 ff ff       	call   800e9c <fd2data>
  801868:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186a:	be 00 00 00 00       	mov    $0x0,%esi
  80186f:	eb 3a                	jmp    8018ab <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801871:	85 f6                	test   %esi,%esi
  801873:	74 04                	je     801879 <devpipe_read+0x25>
				return i;
  801875:	89 f0                	mov    %esi,%eax
  801877:	eb 40                	jmp    8018b9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801879:	89 da                	mov    %ebx,%edx
  80187b:	89 f8                	mov    %edi,%eax
  80187d:	e8 f5 fe ff ff       	call   801777 <_pipeisclosed>
  801882:	85 c0                	test   %eax,%eax
  801884:	75 2e                	jne    8018b4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801886:	e8 77 f3 ff ff       	call   800c02 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80188b:	8b 03                	mov    (%ebx),%eax
  80188d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801890:	74 df                	je     801871 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801892:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801897:	79 05                	jns    80189e <devpipe_read+0x4a>
  801899:	48                   	dec    %eax
  80189a:	83 c8 e0             	or     $0xffffffe0,%eax
  80189d:	40                   	inc    %eax
  80189e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018a8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018aa:	46                   	inc    %esi
  8018ab:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018ae:	75 db                	jne    80188b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018b0:	89 f0                	mov    %esi,%eax
  8018b2:	eb 05                	jmp    8018b9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018b4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018b9:	83 c4 1c             	add    $0x1c,%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5e                   	pop    %esi
  8018be:	5f                   	pop    %edi
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    

008018c1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	57                   	push   %edi
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 3c             	sub    $0x3c,%esp
  8018ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018d0:	89 04 24             	mov    %eax,(%esp)
  8018d3:	e8 df f5 ff ff       	call   800eb7 <fd_alloc>
  8018d8:	89 c3                	mov    %eax,%ebx
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 88 45 01 00 00    	js     801a27 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018e9:	00 
  8018ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f8:	e8 24 f3 ff ff       	call   800c21 <sys_page_alloc>
  8018fd:	89 c3                	mov    %eax,%ebx
  8018ff:	85 c0                	test   %eax,%eax
  801901:	0f 88 20 01 00 00    	js     801a27 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801907:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80190a:	89 04 24             	mov    %eax,(%esp)
  80190d:	e8 a5 f5 ff ff       	call   800eb7 <fd_alloc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	0f 88 f8 00 00 00    	js     801a14 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801923:	00 
  801924:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801932:	e8 ea f2 ff ff       	call   800c21 <sys_page_alloc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	85 c0                	test   %eax,%eax
  80193b:	0f 88 d3 00 00 00    	js     801a14 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 50 f5 ff ff       	call   800e9c <fd2data>
  80194c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801955:	00 
  801956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801961:	e8 bb f2 ff ff       	call   800c21 <sys_page_alloc>
  801966:	89 c3                	mov    %eax,%ebx
  801968:	85 c0                	test   %eax,%eax
  80196a:	0f 88 91 00 00 00    	js     801a01 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801970:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801973:	89 04 24             	mov    %eax,(%esp)
  801976:	e8 21 f5 ff ff       	call   800e9c <fd2data>
  80197b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801982:	00 
  801983:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801987:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80198e:	00 
  80198f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199a:	e8 d6 f2 ff ff       	call   800c75 <sys_page_map>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 4c                	js     8019f1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019a5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019ba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019d2:	89 04 24             	mov    %eax,(%esp)
  8019d5:	e8 b2 f4 ff ff       	call   800e8c <fd2num>
  8019da:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019df:	89 04 24             	mov    %eax,(%esp)
  8019e2:	e8 a5 f4 ff ff       	call   800e8c <fd2num>
  8019e7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ef:	eb 36                	jmp    801a27 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8019f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fc:	e8 c7 f2 ff ff       	call   800cc8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0f:	e8 b4 f2 ff ff       	call   800cc8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a22:	e8 a1 f2 ff ff       	call   800cc8 <sys_page_unmap>
    err:
	return r;
}
  801a27:	89 d8                	mov    %ebx,%eax
  801a29:	83 c4 3c             	add    $0x3c,%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	89 04 24             	mov    %eax,(%esp)
  801a44:	e8 c1 f4 ff ff       	call   800f0a <fd_lookup>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 15                	js     801a62 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	e8 44 f4 ff ff       	call   800e9c <fd2data>
	return _pipeisclosed(fd, p);
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5d:	e8 15 fd ff ff       	call   801777 <_pipeisclosed>
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a67:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a74:	c7 44 24 04 cc 24 80 	movl   $0x8024cc,0x4(%esp)
  801a7b:	00 
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	89 04 24             	mov    %eax,(%esp)
  801a82:	e8 a8 ed ff ff       	call   80082f <strcpy>
	return 0;
}
  801a87:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	57                   	push   %edi
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a9a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a9f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa5:	eb 30                	jmp    801ad7 <devcons_write+0x49>
		m = n - tot;
  801aa7:	8b 75 10             	mov    0x10(%ebp),%esi
  801aaa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801aac:	83 fe 7f             	cmp    $0x7f,%esi
  801aaf:	76 05                	jbe    801ab6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801ab1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ab6:	89 74 24 08          	mov    %esi,0x8(%esp)
  801aba:	03 45 0c             	add    0xc(%ebp),%eax
  801abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac1:	89 3c 24             	mov    %edi,(%esp)
  801ac4:	e8 df ee ff ff       	call   8009a8 <memmove>
		sys_cputs(buf, m);
  801ac9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801acd:	89 3c 24             	mov    %edi,(%esp)
  801ad0:	e8 7f f0 ff ff       	call   800b54 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ad5:	01 f3                	add    %esi,%ebx
  801ad7:	89 d8                	mov    %ebx,%eax
  801ad9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801adc:	72 c9                	jb     801aa7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ade:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801aef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af3:	75 07                	jne    801afc <devcons_read+0x13>
  801af5:	eb 25                	jmp    801b1c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801af7:	e8 06 f1 ff ff       	call   800c02 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801afc:	e8 71 f0 ff ff       	call   800b72 <sys_cgetc>
  801b01:	85 c0                	test   %eax,%eax
  801b03:	74 f2                	je     801af7 <devcons_read+0xe>
  801b05:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 1d                	js     801b28 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b0b:	83 f8 04             	cmp    $0x4,%eax
  801b0e:	74 13                	je     801b23 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b13:	88 10                	mov    %dl,(%eax)
	return 1;
  801b15:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1a:	eb 0c                	jmp    801b28 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b21:	eb 05                	jmp    801b28 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b30:	8b 45 08             	mov    0x8(%ebp),%eax
  801b33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b3d:	00 
  801b3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 0b f0 ff ff       	call   800b54 <sys_cputs>
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <getchar>:

int
getchar(void)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b51:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801b58:	00 
  801b59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b67:	e8 3a f6 ff ff       	call   8011a6 <read>
	if (r < 0)
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 0f                	js     801b7f <getchar+0x34>
		return r;
	if (r < 1)
  801b70:	85 c0                	test   %eax,%eax
  801b72:	7e 06                	jle    801b7a <getchar+0x2f>
		return -E_EOF;
	return c;
  801b74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b78:	eb 05                	jmp    801b7f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	89 04 24             	mov    %eax,(%esp)
  801b94:	e8 71 f3 ff ff       	call   800f0a <fd_lookup>
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 11                	js     801bae <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba6:	39 10                	cmp    %edx,(%eax)
  801ba8:	0f 94 c0             	sete   %al
  801bab:	0f b6 c0             	movzbl %al,%eax
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <opencons>:

int
opencons(void)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb9:	89 04 24             	mov    %eax,(%esp)
  801bbc:	e8 f6 f2 ff ff       	call   800eb7 <fd_alloc>
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	78 3c                	js     801c01 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bc5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bcc:	00 
  801bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bdb:	e8 41 f0 ff ff       	call   800c21 <sys_page_alloc>
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 1d                	js     801c01 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801be4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 8b f2 ff ff       	call   800e8c <fd2num>
}
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    
	...

00801c04 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	83 ec 10             	sub    $0x10,%esp
  801c0c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801c15:	85 c0                	test   %eax,%eax
  801c17:	75 05                	jne    801c1e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801c19:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 11 f2 ff ff       	call   800e37 <sys_ipc_recv>
	if (!err) {
  801c26:	85 c0                	test   %eax,%eax
  801c28:	75 26                	jne    801c50 <ipc_recv+0x4c>
		if (from_env_store) {
  801c2a:	85 f6                	test   %esi,%esi
  801c2c:	74 0a                	je     801c38 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801c2e:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c33:	8b 40 74             	mov    0x74(%eax),%eax
  801c36:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801c38:	85 db                	test   %ebx,%ebx
  801c3a:	74 0a                	je     801c46 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801c3c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c41:	8b 40 78             	mov    0x78(%eax),%eax
  801c44:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801c46:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c4b:	8b 40 70             	mov    0x70(%eax),%eax
  801c4e:	eb 14                	jmp    801c64 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801c50:	85 f6                	test   %esi,%esi
  801c52:	74 06                	je     801c5a <ipc_recv+0x56>
		*from_env_store = 0;
  801c54:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801c5a:	85 db                	test   %ebx,%ebx
  801c5c:	74 06                	je     801c64 <ipc_recv+0x60>
		*perm_store = 0;
  801c5e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	57                   	push   %edi
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 1c             	sub    $0x1c,%esp
  801c74:	8b 75 10             	mov    0x10(%ebp),%esi
  801c77:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801c7a:	85 f6                	test   %esi,%esi
  801c7c:	75 05                	jne    801c83 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801c7e:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801c83:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c87:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	89 04 24             	mov    %eax,(%esp)
  801c98:	e8 77 f1 ff ff       	call   800e14 <sys_ipc_try_send>
  801c9d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801c9f:	e8 5e ef ff ff       	call   800c02 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801ca4:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801ca7:	74 da                	je     801c83 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801ca9:	85 db                	test   %ebx,%ebx
  801cab:	74 20                	je     801ccd <ipc_send+0x62>
		panic("send fail: %e", err);
  801cad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cb1:	c7 44 24 08 d8 24 80 	movl   $0x8024d8,0x8(%esp)
  801cb8:	00 
  801cb9:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801cc0:	00 
  801cc1:	c7 04 24 e6 24 80 00 	movl   $0x8024e6,(%esp)
  801cc8:	e8 9f e4 ff ff       	call   80016c <_panic>
	}
	return;
}
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	53                   	push   %ebx
  801cd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cdc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ce1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ce8:	89 c2                	mov    %eax,%edx
  801cea:	c1 e2 07             	shl    $0x7,%edx
  801ced:	29 ca                	sub    %ecx,%edx
  801cef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cf5:	8b 52 50             	mov    0x50(%edx),%edx
  801cf8:	39 da                	cmp    %ebx,%edx
  801cfa:	75 0f                	jne    801d0b <ipc_find_env+0x36>
			return envs[i].env_id;
  801cfc:	c1 e0 07             	shl    $0x7,%eax
  801cff:	29 c8                	sub    %ecx,%eax
  801d01:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d06:	8b 40 40             	mov    0x40(%eax),%eax
  801d09:	eb 0c                	jmp    801d17 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d0b:	40                   	inc    %eax
  801d0c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d11:	75 ce                	jne    801ce1 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d13:	66 b8 00 00          	mov    $0x0,%ax
}
  801d17:	5b                   	pop    %ebx
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    
	...

00801d1c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d22:	89 c2                	mov    %eax,%edx
  801d24:	c1 ea 16             	shr    $0x16,%edx
  801d27:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d2e:	f6 c2 01             	test   $0x1,%dl
  801d31:	74 1e                	je     801d51 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d33:	c1 e8 0c             	shr    $0xc,%eax
  801d36:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d3d:	a8 01                	test   $0x1,%al
  801d3f:	74 17                	je     801d58 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d41:	c1 e8 0c             	shr    $0xc,%eax
  801d44:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d4b:	ef 
  801d4c:	0f b7 c0             	movzwl %ax,%eax
  801d4f:	eb 0c                	jmp    801d5d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	eb 05                	jmp    801d5d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d58:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    
	...

00801d60 <__udivdi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	83 ec 10             	sub    $0x10,%esp
  801d66:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d6a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d72:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d76:	89 cd                	mov    %ecx,%ebp
  801d78:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	75 2c                	jne    801dac <__udivdi3+0x4c>
  801d80:	39 f9                	cmp    %edi,%ecx
  801d82:	77 68                	ja     801dec <__udivdi3+0x8c>
  801d84:	85 c9                	test   %ecx,%ecx
  801d86:	75 0b                	jne    801d93 <__udivdi3+0x33>
  801d88:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8d:	31 d2                	xor    %edx,%edx
  801d8f:	f7 f1                	div    %ecx
  801d91:	89 c1                	mov    %eax,%ecx
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	89 f8                	mov    %edi,%eax
  801d97:	f7 f1                	div    %ecx
  801d99:	89 c7                	mov    %eax,%edi
  801d9b:	89 f0                	mov    %esi,%eax
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	89 fa                	mov    %edi,%edx
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	39 f8                	cmp    %edi,%eax
  801dae:	77 2c                	ja     801ddc <__udivdi3+0x7c>
  801db0:	0f bd f0             	bsr    %eax,%esi
  801db3:	83 f6 1f             	xor    $0x1f,%esi
  801db6:	75 4c                	jne    801e04 <__udivdi3+0xa4>
  801db8:	39 f8                	cmp    %edi,%eax
  801dba:	bf 00 00 00 00       	mov    $0x0,%edi
  801dbf:	72 0a                	jb     801dcb <__udivdi3+0x6b>
  801dc1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801dc5:	0f 87 ad 00 00 00    	ja     801e78 <__udivdi3+0x118>
  801dcb:	be 01 00 00 00       	mov    $0x1,%esi
  801dd0:	89 f0                	mov    %esi,%eax
  801dd2:	89 fa                	mov    %edi,%edx
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	5e                   	pop    %esi
  801dd8:	5f                   	pop    %edi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    
  801ddb:	90                   	nop
  801ddc:	31 ff                	xor    %edi,%edi
  801dde:	31 f6                	xor    %esi,%esi
  801de0:	89 f0                	mov    %esi,%eax
  801de2:	89 fa                	mov    %edi,%edx
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    
  801deb:	90                   	nop
  801dec:	89 fa                	mov    %edi,%edx
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	f7 f1                	div    %ecx
  801df2:	89 c6                	mov    %eax,%esi
  801df4:	31 ff                	xor    %edi,%edi
  801df6:	89 f0                	mov    %esi,%eax
  801df8:	89 fa                	mov    %edi,%edx
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    
  801e01:	8d 76 00             	lea    0x0(%esi),%esi
  801e04:	89 f1                	mov    %esi,%ecx
  801e06:	d3 e0                	shl    %cl,%eax
  801e08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  801e11:	29 f0                	sub    %esi,%eax
  801e13:	89 ea                	mov    %ebp,%edx
  801e15:	88 c1                	mov    %al,%cl
  801e17:	d3 ea                	shr    %cl,%edx
  801e19:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e1d:	09 ca                	or     %ecx,%edx
  801e1f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e23:	89 f1                	mov    %esi,%ecx
  801e25:	d3 e5                	shl    %cl,%ebp
  801e27:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e2b:	89 fd                	mov    %edi,%ebp
  801e2d:	88 c1                	mov    %al,%cl
  801e2f:	d3 ed                	shr    %cl,%ebp
  801e31:	89 fa                	mov    %edi,%edx
  801e33:	89 f1                	mov    %esi,%ecx
  801e35:	d3 e2                	shl    %cl,%edx
  801e37:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e3b:	88 c1                	mov    %al,%cl
  801e3d:	d3 ef                	shr    %cl,%edi
  801e3f:	09 d7                	or     %edx,%edi
  801e41:	89 f8                	mov    %edi,%eax
  801e43:	89 ea                	mov    %ebp,%edx
  801e45:	f7 74 24 08          	divl   0x8(%esp)
  801e49:	89 d1                	mov    %edx,%ecx
  801e4b:	89 c7                	mov    %eax,%edi
  801e4d:	f7 64 24 0c          	mull   0xc(%esp)
  801e51:	39 d1                	cmp    %edx,%ecx
  801e53:	72 17                	jb     801e6c <__udivdi3+0x10c>
  801e55:	74 09                	je     801e60 <__udivdi3+0x100>
  801e57:	89 fe                	mov    %edi,%esi
  801e59:	31 ff                	xor    %edi,%edi
  801e5b:	e9 41 ff ff ff       	jmp    801da1 <__udivdi3+0x41>
  801e60:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e64:	89 f1                	mov    %esi,%ecx
  801e66:	d3 e2                	shl    %cl,%edx
  801e68:	39 c2                	cmp    %eax,%edx
  801e6a:	73 eb                	jae    801e57 <__udivdi3+0xf7>
  801e6c:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e6f:	31 ff                	xor    %edi,%edi
  801e71:	e9 2b ff ff ff       	jmp    801da1 <__udivdi3+0x41>
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	31 f6                	xor    %esi,%esi
  801e7a:	e9 22 ff ff ff       	jmp    801da1 <__udivdi3+0x41>
	...

00801e80 <__umoddi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	83 ec 20             	sub    $0x20,%esp
  801e86:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e8a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e8e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e92:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e96:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e9a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e9e:	89 c7                	mov    %eax,%edi
  801ea0:	89 f2                	mov    %esi,%edx
  801ea2:	85 ed                	test   %ebp,%ebp
  801ea4:	75 16                	jne    801ebc <__umoddi3+0x3c>
  801ea6:	39 f1                	cmp    %esi,%ecx
  801ea8:	0f 86 a6 00 00 00    	jbe    801f54 <__umoddi3+0xd4>
  801eae:	f7 f1                	div    %ecx
  801eb0:	89 d0                	mov    %edx,%eax
  801eb2:	31 d2                	xor    %edx,%edx
  801eb4:	83 c4 20             	add    $0x20,%esp
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    
  801ebb:	90                   	nop
  801ebc:	39 f5                	cmp    %esi,%ebp
  801ebe:	0f 87 ac 00 00 00    	ja     801f70 <__umoddi3+0xf0>
  801ec4:	0f bd c5             	bsr    %ebp,%eax
  801ec7:	83 f0 1f             	xor    $0x1f,%eax
  801eca:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ece:	0f 84 a8 00 00 00    	je     801f7c <__umoddi3+0xfc>
  801ed4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ed8:	d3 e5                	shl    %cl,%ebp
  801eda:	bf 20 00 00 00       	mov    $0x20,%edi
  801edf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801ee3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ee7:	89 f9                	mov    %edi,%ecx
  801ee9:	d3 e8                	shr    %cl,%eax
  801eeb:	09 e8                	or     %ebp,%eax
  801eed:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ef1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ef5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ef9:	d3 e0                	shl    %cl,%eax
  801efb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eff:	89 f2                	mov    %esi,%edx
  801f01:	d3 e2                	shl    %cl,%edx
  801f03:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f07:	d3 e0                	shl    %cl,%eax
  801f09:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801f0d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f11:	89 f9                	mov    %edi,%ecx
  801f13:	d3 e8                	shr    %cl,%eax
  801f15:	09 d0                	or     %edx,%eax
  801f17:	d3 ee                	shr    %cl,%esi
  801f19:	89 f2                	mov    %esi,%edx
  801f1b:	f7 74 24 18          	divl   0x18(%esp)
  801f1f:	89 d6                	mov    %edx,%esi
  801f21:	f7 64 24 0c          	mull   0xc(%esp)
  801f25:	89 c5                	mov    %eax,%ebp
  801f27:	89 d1                	mov    %edx,%ecx
  801f29:	39 d6                	cmp    %edx,%esi
  801f2b:	72 67                	jb     801f94 <__umoddi3+0x114>
  801f2d:	74 75                	je     801fa4 <__umoddi3+0x124>
  801f2f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f33:	29 e8                	sub    %ebp,%eax
  801f35:	19 ce                	sbb    %ecx,%esi
  801f37:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f3b:	d3 e8                	shr    %cl,%eax
  801f3d:	89 f2                	mov    %esi,%edx
  801f3f:	89 f9                	mov    %edi,%ecx
  801f41:	d3 e2                	shl    %cl,%edx
  801f43:	09 d0                	or     %edx,%eax
  801f45:	89 f2                	mov    %esi,%edx
  801f47:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f4b:	d3 ea                	shr    %cl,%edx
  801f4d:	83 c4 20             	add    $0x20,%esp
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    
  801f54:	85 c9                	test   %ecx,%ecx
  801f56:	75 0b                	jne    801f63 <__umoddi3+0xe3>
  801f58:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5d:	31 d2                	xor    %edx,%edx
  801f5f:	f7 f1                	div    %ecx
  801f61:	89 c1                	mov    %eax,%ecx
  801f63:	89 f0                	mov    %esi,%eax
  801f65:	31 d2                	xor    %edx,%edx
  801f67:	f7 f1                	div    %ecx
  801f69:	89 f8                	mov    %edi,%eax
  801f6b:	e9 3e ff ff ff       	jmp    801eae <__umoddi3+0x2e>
  801f70:	89 f2                	mov    %esi,%edx
  801f72:	83 c4 20             	add    $0x20,%esp
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    
  801f79:	8d 76 00             	lea    0x0(%esi),%esi
  801f7c:	39 f5                	cmp    %esi,%ebp
  801f7e:	72 04                	jb     801f84 <__umoddi3+0x104>
  801f80:	39 f9                	cmp    %edi,%ecx
  801f82:	77 06                	ja     801f8a <__umoddi3+0x10a>
  801f84:	89 f2                	mov    %esi,%edx
  801f86:	29 cf                	sub    %ecx,%edi
  801f88:	19 ea                	sbb    %ebp,%edx
  801f8a:	89 f8                	mov    %edi,%eax
  801f8c:	83 c4 20             	add    $0x20,%esp
  801f8f:	5e                   	pop    %esi
  801f90:	5f                   	pop    %edi
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    
  801f93:	90                   	nop
  801f94:	89 d1                	mov    %edx,%ecx
  801f96:	89 c5                	mov    %eax,%ebp
  801f98:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f9c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801fa0:	eb 8d                	jmp    801f2f <__umoddi3+0xaf>
  801fa2:	66 90                	xchg   %ax,%ax
  801fa4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fa8:	72 ea                	jb     801f94 <__umoddi3+0x114>
  801faa:	89 f1                	mov    %esi,%ecx
  801fac:	eb 81                	jmp    801f2f <__umoddi3+0xaf>
