
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
  80003a:	c7 04 24 24 0e 80 00 	movl   $0x800e24,(%esp)
  800041:	e8 0e 02 00 00       	call   800254 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 9f 0e 80 	movl   $0x800e9f,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  800070:	e8 e7 00 00 00       	call   80015c <_panic>
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
  8000a3:	c7 44 24 08 44 0e 80 	movl   $0x800e44,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8000ba:	e8 9d 00 00 00       	call   80015c <_panic>
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
  8000c7:	c7 04 24 6c 0e 80 00 	movl   $0x800e6c,(%esp)
  8000ce:	e8 81 01 00 00       	call   800254 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 cb 0e 80 	movl   $0x800ecb,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  8000f4:	e8 63 00 00 00       	call   80015c <_panic>
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
  80010a:	e8 a4 0a 00 00       	call   800bb3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800117:	c1 e0 05             	shl    $0x5,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 f6                	test   %esi,%esi
  800126:	7e 07                	jle    80012f <libmain+0x33>
		binaryname = argv[0];
  800128:	8b 03                	mov    (%ebx),%eax
  80012a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800133:	89 34 24             	mov    %esi,(%esp)
  800136:	e8 f9 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013b:	e8 08 00 00 00       	call   800148 <exit>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 07 0a 00 00       	call   800b61 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016d:	e8 41 0a 00 00       	call   800bb3 <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 ec 0e 80 00 	movl   $0x800eec,(%esp)
  80018f:	e8 c0 00 00 00       	call   800254 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 74 24 04          	mov    %esi,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 50 00 00 00       	call   8001f3 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 ba 0e 80 00 	movl   $0x800eba,(%esp)
  8001aa:	e8 a5 00 00 00       	call   800254 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	40                   	inc    %eax
  8001c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cf:	75 19                	jne    8001ea <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d8:	00 
  8001d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001dc:	89 04 24             	mov    %eax,(%esp)
  8001df:	e8 40 09 00 00       	call   800b24 <sys_cputs>
		b->idx = 0;
  8001e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ea:	ff 43 04             	incl   0x4(%ebx)
}
  8001ed:	83 c4 14             	add    $0x14,%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800203:	00 00 00 
	b.cnt = 0;
  800206:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800210:	8b 45 0c             	mov    0xc(%ebp),%eax
  800213:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800217:	8b 45 08             	mov    0x8(%ebp),%eax
  80021a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  80022f:	e8 82 01 00 00       	call   8003b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800234:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	e8 d8 08 00 00       	call   800b24 <sys_cputs>

	return b.cnt;
}
  80024c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	89 04 24             	mov    %eax,(%esp)
  800267:	e8 87 ff ff ff       	call   8001f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	85 c0                	test   %eax,%eax
  800292:	75 08                	jne    80029c <printnum+0x2c>
  800294:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800297:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029a:	77 57                	ja     8002f3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a0:	4b                   	dec    %ebx
  8002a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ac:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bb:	00 
  8002bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	e8 06 09 00 00       	call   800bd4 <__udivdi3>
  8002ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d6:	89 04 24             	mov    %eax,(%esp)
  8002d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002dd:	89 fa                	mov    %edi,%edx
  8002df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e2:	e8 89 ff ff ff       	call   800270 <printnum>
  8002e7:	eb 0f                	jmp    8002f8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ed:	89 34 24             	mov    %esi,(%esp)
  8002f0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f3:	4b                   	dec    %ebx
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7f f1                	jg     8002e9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	89 44 24 08          	mov    %eax,0x8(%esp)
  800307:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030e:	00 
  80030f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	e8 d3 09 00 00       	call   800cf4 <__umoddi3>
  800321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800325:	0f be 80 10 0f 80 00 	movsbl 0x800f10(%eax),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800332:	83 c4 3c             	add    $0x3c,%esp
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033d:	83 fa 01             	cmp    $0x1,%edx
  800340:	7e 0e                	jle    800350 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 08             	lea    0x8(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	8b 52 04             	mov    0x4(%edx),%edx
  80034e:	eb 22                	jmp    800372 <getuint+0x38>
	else if (lflag)
  800350:	85 d2                	test   %edx,%edx
  800352:	74 10                	je     800364 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 0e                	jmp    800372 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	3b 50 04             	cmp    0x4(%eax),%edx
  800382:	73 08                	jae    80038c <sprintputch+0x18>
		*b->buf++ = ch;
  800384:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800387:	88 0a                	mov    %cl,(%edx)
  800389:	42                   	inc    %edx
  80038a:	89 10                	mov    %edx,(%eax)
}
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80039b:	8b 45 10             	mov    0x10(%ebp),%eax
  80039e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 02 00 00 00       	call   8003b6 <vprintfmt>
	va_end(ap);
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	57                   	push   %edi
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 4c             	sub    $0x4c,%esp
  8003bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c5:	eb 12                	jmp    8003d9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c7:	85 c0                	test   %eax,%eax
  8003c9:	0f 84 6b 03 00 00    	je     80073a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d3:	89 04 24             	mov    %eax,(%esp)
  8003d6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d9:	0f b6 06             	movzbl (%esi),%eax
  8003dc:	46                   	inc    %esi
  8003dd:	83 f8 25             	cmp    $0x25,%eax
  8003e0:	75 e5                	jne    8003c7 <vprintfmt+0x11>
  8003e2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	eb 26                	jmp    800426 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800403:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800407:	eb 1d                	jmp    800426 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80040c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800410:	eb 14                	jmp    800426 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800415:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041c:	eb 08                	jmp    800426 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800421:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	0f b6 06             	movzbl (%esi),%eax
  800429:	8d 56 01             	lea    0x1(%esi),%edx
  80042c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042f:	8a 16                	mov    (%esi),%dl
  800431:	83 ea 23             	sub    $0x23,%edx
  800434:	80 fa 55             	cmp    $0x55,%dl
  800437:	0f 87 e1 02 00 00    	ja     80071e <vprintfmt+0x368>
  80043d:	0f b6 d2             	movzbl %dl,%edx
  800440:	ff 24 95 a0 0f 80 00 	jmp    *0x800fa0(,%edx,4)
  800447:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800452:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800456:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800459:	8d 50 d0             	lea    -0x30(%eax),%edx
  80045c:	83 fa 09             	cmp    $0x9,%edx
  80045f:	77 2a                	ja     80048b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800461:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800462:	eb eb                	jmp    80044f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800472:	eb 17                	jmp    80048b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800474:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800478:	78 98                	js     800412 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80047d:	eb a7                	jmp    800426 <vprintfmt+0x70>
  80047f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800482:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800489:	eb 9b                	jmp    800426 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80048b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048f:	79 95                	jns    800426 <vprintfmt+0x70>
  800491:	eb 8b                	jmp    80041e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800493:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800497:	eb 8d                	jmp    800426 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a6:	8b 00                	mov    (%eax),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b1:	e9 23 ff ff ff       	jmp    8003d9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	79 02                	jns    8004c7 <vprintfmt+0x111>
  8004c5:	f7 d8                	neg    %eax
  8004c7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 06             	cmp    $0x6,%eax
  8004cc:	7f 0b                	jg     8004d9 <vprintfmt+0x123>
  8004ce:	8b 04 85 f8 10 80 00 	mov    0x8010f8(,%eax,4),%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	75 23                	jne    8004fc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004dd:	c7 44 24 08 28 0f 80 	movl   $0x800f28,0x8(%esp)
  8004e4:	00 
  8004e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	e8 9a fe ff ff       	call   80038e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f7:	e9 dd fe ff ff       	jmp    8003d9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800500:	c7 44 24 08 31 0f 80 	movl   $0x800f31,0x8(%esp)
  800507:	00 
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	8b 55 08             	mov    0x8(%ebp),%edx
  80050f:	89 14 24             	mov    %edx,(%esp)
  800512:	e8 77 fe ff ff       	call   80038e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 ba fe ff ff       	jmp    8003d9 <vprintfmt+0x23>
  80051f:	89 f9                	mov    %edi,%ecx
  800521:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800524:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 50 04             	lea    0x4(%eax),%edx
  80052d:	89 55 14             	mov    %edx,0x14(%ebp)
  800530:	8b 30                	mov    (%eax),%esi
  800532:	85 f6                	test   %esi,%esi
  800534:	75 05                	jne    80053b <vprintfmt+0x185>
				p = "(null)";
  800536:	be 21 0f 80 00       	mov    $0x800f21,%esi
			if (width > 0 && padc != '-')
  80053b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053f:	0f 8e 84 00 00 00    	jle    8005c9 <vprintfmt+0x213>
  800545:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800549:	74 7e                	je     8005c9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054f:	89 34 24             	mov    %esi,(%esp)
  800552:	e8 8b 02 00 00       	call   8007e2 <strnlen>
  800557:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80055a:	29 c2                	sub    %eax,%edx
  80055c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80055f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800563:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800566:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800569:	89 de                	mov    %ebx,%esi
  80056b:	89 d3                	mov    %edx,%ebx
  80056d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	eb 0b                	jmp    80057c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800571:	89 74 24 04          	mov    %esi,0x4(%esp)
  800575:	89 3c 24             	mov    %edi,(%esp)
  800578:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	4b                   	dec    %ebx
  80057c:	85 db                	test   %ebx,%ebx
  80057e:	7f f1                	jg     800571 <vprintfmt+0x1bb>
  800580:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800583:	89 f3                	mov    %esi,%ebx
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058b:	85 c0                	test   %eax,%eax
  80058d:	79 05                	jns    800594 <vprintfmt+0x1de>
  80058f:	b8 00 00 00 00       	mov    $0x0,%eax
  800594:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800597:	29 c2                	sub    %eax,%edx
  800599:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80059c:	eb 2b                	jmp    8005c9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a2:	74 18                	je     8005bc <vprintfmt+0x206>
  8005a4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a7:	83 fa 5e             	cmp    $0x5e,%edx
  8005aa:	76 10                	jbe    8005bc <vprintfmt+0x206>
					putch('?', putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
  8005ba:	eb 0a                	jmp    8005c6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c9:	0f be 06             	movsbl (%esi),%eax
  8005cc:	46                   	inc    %esi
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	74 21                	je     8005f2 <vprintfmt+0x23c>
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	78 c9                	js     80059e <vprintfmt+0x1e8>
  8005d5:	4f                   	dec    %edi
  8005d6:	79 c6                	jns    80059e <vprintfmt+0x1e8>
  8005d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005db:	89 de                	mov    %ebx,%esi
  8005dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e0:	eb 18                	jmp    8005fa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ed:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ef:	4b                   	dec    %ebx
  8005f0:	eb 08                	jmp    8005fa <vprintfmt+0x244>
  8005f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f5:	89 de                	mov    %ebx,%esi
  8005f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fa:	85 db                	test   %ebx,%ebx
  8005fc:	7f e4                	jg     8005e2 <vprintfmt+0x22c>
  8005fe:	89 7d 08             	mov    %edi,0x8(%ebp)
  800601:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800606:	e9 ce fd ff ff       	jmp    8003d9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060b:	83 f9 01             	cmp    $0x1,%ecx
  80060e:	7e 10                	jle    800620 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 08             	lea    0x8(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 30                	mov    (%eax),%esi
  80061b:	8b 78 04             	mov    0x4(%eax),%edi
  80061e:	eb 26                	jmp    800646 <vprintfmt+0x290>
	else if (lflag)
  800620:	85 c9                	test   %ecx,%ecx
  800622:	74 12                	je     800636 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	89 f7                	mov    %esi,%edi
  800631:	c1 ff 1f             	sar    $0x1f,%edi
  800634:	eb 10                	jmp    800646 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)
  80063f:	8b 30                	mov    (%eax),%esi
  800641:	89 f7                	mov    %esi,%edi
  800643:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800646:	85 ff                	test   %edi,%edi
  800648:	78 0a                	js     800654 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064f:	e9 8c 00 00 00       	jmp    8006e0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800662:	f7 de                	neg    %esi
  800664:	83 d7 00             	adc    $0x0,%edi
  800667:	f7 df                	neg    %edi
			}
			base = 10;
  800669:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066e:	eb 70                	jmp    8006e0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800670:	89 ca                	mov    %ecx,%edx
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 c0 fc ff ff       	call   80033a <getuint>
  80067a:	89 c6                	mov    %eax,%esi
  80067c:	89 d7                	mov    %edx,%edi
			base = 10;
  80067e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800683:	eb 5b                	jmp    8006e0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800685:	89 ca                	mov    %ecx,%edx
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 ab fc ff ff       	call   80033a <getuint>
  80068f:	89 c6                	mov    %eax,%esi
  800691:	89 d7                	mov    %edx,%edi
			base = 8;
  800693:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800698:	eb 46                	jmp    8006e0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ac:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bf:	8b 30                	mov    (%eax),%esi
  8006c1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cb:	eb 13                	jmp    8006e0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cd:	89 ca                	mov    %ecx,%edx
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d2:	e8 63 fc ff ff       	call   80033a <getuint>
  8006d7:	89 c6                	mov    %eax,%esi
  8006d9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f3:	89 34 24             	mov    %esi,(%esp)
  8006f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fa:	89 da                	mov    %ebx,%edx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	e8 6c fb ff ff       	call   800270 <printnum>
			break;
  800704:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800707:	e9 cd fc ff ff       	jmp    8003d9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800719:	e9 bb fc ff ff       	jmp    8003d9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800722:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800729:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072c:	eb 01                	jmp    80072f <vprintfmt+0x379>
  80072e:	4e                   	dec    %esi
  80072f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800733:	75 f9                	jne    80072e <vprintfmt+0x378>
  800735:	e9 9f fc ff ff       	jmp    8003d9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80073a:	83 c4 4c             	add    $0x4c,%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5f                   	pop    %edi
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	83 ec 28             	sub    $0x28,%esp
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800751:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800755:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800758:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075f:	85 c0                	test   %eax,%eax
  800761:	74 30                	je     800793 <vsnprintf+0x51>
  800763:	85 d2                	test   %edx,%edx
  800765:	7e 33                	jle    80079a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076e:	8b 45 10             	mov    0x10(%ebp),%eax
  800771:	89 44 24 08          	mov    %eax,0x8(%esp)
  800775:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077c:	c7 04 24 74 03 80 00 	movl   $0x800374,(%esp)
  800783:	e8 2e fc ff ff       	call   8003b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	eb 0c                	jmp    80079f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800793:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800798:	eb 05                	jmp    80079f <vsnprintf+0x5d>
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	89 04 24             	mov    %eax,(%esp)
  8007c2:	e8 7b ff ff ff       	call   800742 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    
  8007c9:	00 00                	add    %al,(%eax)
	...

008007cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d7:	eb 01                	jmp    8007da <strlen+0xe>
		n++;
  8007d9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007de:	75 f9                	jne    8007d9 <strlen+0xd>
		n++;
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f0:	eb 01                	jmp    8007f3 <strnlen+0x11>
		n++;
  8007f2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	39 d0                	cmp    %edx,%eax
  8007f5:	74 06                	je     8007fd <strnlen+0x1b>
  8007f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007fb:	75 f5                	jne    8007f2 <strnlen+0x10>
		n++;
	return n;
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800809:	ba 00 00 00 00       	mov    $0x0,%edx
  80080e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800811:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800814:	42                   	inc    %edx
  800815:	84 c9                	test   %cl,%cl
  800817:	75 f5                	jne    80080e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800819:	5b                   	pop    %ebx
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800826:	89 1c 24             	mov    %ebx,(%esp)
  800829:	e8 9e ff ff ff       	call   8007cc <strlen>
	strcpy(dst + len, src);
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 54 24 04          	mov    %edx,0x4(%esp)
  800835:	01 d8                	add    %ebx,%eax
  800837:	89 04 24             	mov    %eax,(%esp)
  80083a:	e8 c0 ff ff ff       	call   8007ff <strcpy>
	return dst;
}
  80083f:	89 d8                	mov    %ebx,%eax
  800841:	83 c4 08             	add    $0x8,%esp
  800844:	5b                   	pop    %ebx
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085a:	eb 0c                	jmp    800868 <strncpy+0x21>
		*dst++ = *src;
  80085c:	8a 1a                	mov    (%edx),%bl
  80085e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800861:	80 3a 01             	cmpb   $0x1,(%edx)
  800864:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800867:	41                   	inc    %ecx
  800868:	39 f1                	cmp    %esi,%ecx
  80086a:	75 f0                	jne    80085c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	8b 75 08             	mov    0x8(%ebp),%esi
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087e:	85 d2                	test   %edx,%edx
  800880:	75 0a                	jne    80088c <strlcpy+0x1c>
  800882:	89 f0                	mov    %esi,%eax
  800884:	eb 1a                	jmp    8008a0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800886:	88 18                	mov    %bl,(%eax)
  800888:	40                   	inc    %eax
  800889:	41                   	inc    %ecx
  80088a:	eb 02                	jmp    80088e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80088e:	4a                   	dec    %edx
  80088f:	74 0a                	je     80089b <strlcpy+0x2b>
  800891:	8a 19                	mov    (%ecx),%bl
  800893:	84 db                	test   %bl,%bl
  800895:	75 ef                	jne    800886 <strlcpy+0x16>
  800897:	89 c2                	mov    %eax,%edx
  800899:	eb 02                	jmp    80089d <strlcpy+0x2d>
  80089b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80089d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a0:	29 f0                	sub    %esi,%eax
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008af:	eb 02                	jmp    8008b3 <strcmp+0xd>
		p++, q++;
  8008b1:	41                   	inc    %ecx
  8008b2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b3:	8a 01                	mov    (%ecx),%al
  8008b5:	84 c0                	test   %al,%al
  8008b7:	74 04                	je     8008bd <strcmp+0x17>
  8008b9:	3a 02                	cmp    (%edx),%al
  8008bb:	74 f4                	je     8008b1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bd:	0f b6 c0             	movzbl %al,%eax
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 03                	jmp    8008d9 <strncmp+0x12>
		n--, p++, q++;
  8008d6:	4a                   	dec    %edx
  8008d7:	40                   	inc    %eax
  8008d8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 14                	je     8008f1 <strncmp+0x2a>
  8008dd:	8a 18                	mov    (%eax),%bl
  8008df:	84 db                	test   %bl,%bl
  8008e1:	74 04                	je     8008e7 <strncmp+0x20>
  8008e3:	3a 19                	cmp    (%ecx),%bl
  8008e5:	74 ef                	je     8008d6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 00             	movzbl (%eax),%eax
  8008ea:	0f b6 11             	movzbl (%ecx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb 05                	jmp    8008f6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800902:	eb 05                	jmp    800909 <strchr+0x10>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 0c                	je     800914 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800908:	40                   	inc    %eax
  800909:	8a 10                	mov    (%eax),%dl
  80090b:	84 d2                	test   %dl,%dl
  80090d:	75 f5                	jne    800904 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091f:	eb 05                	jmp    800926 <strfind+0x10>
		if (*s == c)
  800921:	38 ca                	cmp    %cl,%dl
  800923:	74 07                	je     80092c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800925:	40                   	inc    %eax
  800926:	8a 10                	mov    (%eax),%dl
  800928:	84 d2                	test   %dl,%dl
  80092a:	75 f5                	jne    800921 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 7d 08             	mov    0x8(%ebp),%edi
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	74 30                	je     800971 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 25                	jne    80096e <memset+0x40>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 20                	jne    80096e <memset+0x40>
		c &= 0xFF;
  80094e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800951:	89 d3                	mov    %edx,%ebx
  800953:	c1 e3 08             	shl    $0x8,%ebx
  800956:	89 d6                	mov    %edx,%esi
  800958:	c1 e6 18             	shl    $0x18,%esi
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	c1 e0 10             	shl    $0x10,%eax
  800960:	09 f0                	or     %esi,%eax
  800962:	09 d0                	or     %edx,%eax
  800964:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800966:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800969:	fc                   	cld    
  80096a:	f3 ab                	rep stos %eax,%es:(%edi)
  80096c:	eb 03                	jmp    800971 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096e:	fc                   	cld    
  80096f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800971:	89 f8                	mov    %edi,%eax
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
  800983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800986:	39 c6                	cmp    %eax,%esi
  800988:	73 34                	jae    8009be <memmove+0x46>
  80098a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098d:	39 d0                	cmp    %edx,%eax
  80098f:	73 2d                	jae    8009be <memmove+0x46>
		s += n;
		d += n;
  800991:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	f6 c2 03             	test   $0x3,%dl
  800997:	75 1b                	jne    8009b4 <memmove+0x3c>
  800999:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099f:	75 13                	jne    8009b4 <memmove+0x3c>
  8009a1:	f6 c1 03             	test   $0x3,%cl
  8009a4:	75 0e                	jne    8009b4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a6:	83 ef 04             	sub    $0x4,%edi
  8009a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009af:	fd                   	std    
  8009b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b2:	eb 07                	jmp    8009bb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b4:	4f                   	dec    %edi
  8009b5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b8:	fd                   	std    
  8009b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bb:	fc                   	cld    
  8009bc:	eb 20                	jmp    8009de <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c4:	75 13                	jne    8009d9 <memmove+0x61>
  8009c6:	a8 03                	test   $0x3,%al
  8009c8:	75 0f                	jne    8009d9 <memmove+0x61>
  8009ca:	f6 c1 03             	test   $0x3,%cl
  8009cd:	75 0a                	jne    8009d9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	fc                   	cld    
  8009d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d7:	eb 05                	jmp    8009de <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	89 04 24             	mov    %eax,(%esp)
  8009fc:	e8 77 ff ff ff       	call   800978 <memmove>
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	eb 16                	jmp    800a2f <memcmp+0x2c>
		if (*s1 != *s2)
  800a19:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a1c:	42                   	inc    %edx
  800a1d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a21:	38 c8                	cmp    %cl,%al
  800a23:	74 0a                	je     800a2f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a25:	0f b6 c0             	movzbl %al,%eax
  800a28:	0f b6 c9             	movzbl %cl,%ecx
  800a2b:	29 c8                	sub    %ecx,%eax
  800a2d:	eb 09                	jmp    800a38 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2f:	39 da                	cmp    %ebx,%edx
  800a31:	75 e6                	jne    800a19 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a46:	89 c2                	mov    %eax,%edx
  800a48:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4b:	eb 05                	jmp    800a52 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	38 08                	cmp    %cl,(%eax)
  800a4f:	74 05                	je     800a56 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	40                   	inc    %eax
  800a52:	39 d0                	cmp    %edx,%eax
  800a54:	72 f7                	jb     800a4d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	eb 01                	jmp    800a67 <strtol+0xf>
		s++;
  800a66:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	8a 02                	mov    (%edx),%al
  800a69:	3c 20                	cmp    $0x20,%al
  800a6b:	74 f9                	je     800a66 <strtol+0xe>
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	74 f5                	je     800a66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a71:	3c 2b                	cmp    $0x2b,%al
  800a73:	75 08                	jne    800a7d <strtol+0x25>
		s++;
  800a75:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb 13                	jmp    800a90 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7d:	3c 2d                	cmp    $0x2d,%al
  800a7f:	75 0a                	jne    800a8b <strtol+0x33>
		s++, neg = 1;
  800a81:	8d 52 01             	lea    0x1(%edx),%edx
  800a84:	bf 01 00 00 00       	mov    $0x1,%edi
  800a89:	eb 05                	jmp    800a90 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	74 05                	je     800a99 <strtol+0x41>
  800a94:	83 fb 10             	cmp    $0x10,%ebx
  800a97:	75 28                	jne    800ac1 <strtol+0x69>
  800a99:	8a 02                	mov    (%edx),%al
  800a9b:	3c 30                	cmp    $0x30,%al
  800a9d:	75 10                	jne    800aaf <strtol+0x57>
  800a9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa3:	75 0a                	jne    800aaf <strtol+0x57>
		s += 2, base = 16;
  800aa5:	83 c2 02             	add    $0x2,%edx
  800aa8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aad:	eb 12                	jmp    800ac1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aaf:	85 db                	test   %ebx,%ebx
  800ab1:	75 0e                	jne    800ac1 <strtol+0x69>
  800ab3:	3c 30                	cmp    $0x30,%al
  800ab5:	75 05                	jne    800abc <strtol+0x64>
		s++, base = 8;
  800ab7:	42                   	inc    %edx
  800ab8:	b3 08                	mov    $0x8,%bl
  800aba:	eb 05                	jmp    800ac1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800abc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac8:	8a 0a                	mov    (%edx),%cl
  800aca:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800acd:	80 fb 09             	cmp    $0x9,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x82>
			dig = *s - '0';
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 30             	sub    $0x30,%ecx
  800ad8:	eb 1e                	jmp    800af8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ada:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 57             	sub    $0x57,%ecx
  800ae8:	eb 0e                	jmp    800af8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 12                	ja     800b04 <strtol+0xac>
			dig = *s - 'A' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af8:	39 f1                	cmp    %esi,%ecx
  800afa:	7d 0c                	jge    800b08 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800afc:	42                   	inc    %edx
  800afd:	0f af c6             	imul   %esi,%eax
  800b00:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b02:	eb c4                	jmp    800ac8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	89 c1                	mov    %eax,%ecx
  800b06:	eb 02                	jmp    800b0a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b08:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0e:	74 05                	je     800b15 <strtol+0xbd>
		*endptr = (char *) s;
  800b10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b13:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b15:	85 ff                	test   %edi,%edi
  800b17:	74 04                	je     800b1d <strtol+0xc5>
  800b19:	89 c8                	mov    %ecx,%eax
  800b1b:	f7 d8                	neg    %eax
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    
	...

00800b24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	89 c7                	mov    %eax,%edi
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 28                	jle    800bab <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b87:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8e:	00 
  800b8f:	c7 44 24 08 14 11 80 	movl   $0x801114,0x8(%esp)
  800b96:	00 
  800b97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9e:	00 
  800b9f:	c7 04 24 31 11 80 00 	movl   $0x801131,(%esp)
  800ba6:	e8 b1 f5 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	83 c4 2c             	add    $0x2c,%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc3:	89 d1                	mov    %edx,%ecx
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	89 d7                	mov    %edx,%edi
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
	...

00800bd4 <__udivdi3>:
  800bd4:	55                   	push   %ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	83 ec 10             	sub    $0x10,%esp
  800bda:	8b 74 24 20          	mov    0x20(%esp),%esi
  800bde:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800be2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800bea:	89 cd                	mov    %ecx,%ebp
  800bec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	75 2c                	jne    800c20 <__udivdi3+0x4c>
  800bf4:	39 f9                	cmp    %edi,%ecx
  800bf6:	77 68                	ja     800c60 <__udivdi3+0x8c>
  800bf8:	85 c9                	test   %ecx,%ecx
  800bfa:	75 0b                	jne    800c07 <__udivdi3+0x33>
  800bfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800c01:	31 d2                	xor    %edx,%edx
  800c03:	f7 f1                	div    %ecx
  800c05:	89 c1                	mov    %eax,%ecx
  800c07:	31 d2                	xor    %edx,%edx
  800c09:	89 f8                	mov    %edi,%eax
  800c0b:	f7 f1                	div    %ecx
  800c0d:	89 c7                	mov    %eax,%edi
  800c0f:	89 f0                	mov    %esi,%eax
  800c11:	f7 f1                	div    %ecx
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	89 f0                	mov    %esi,%eax
  800c17:	89 fa                	mov    %edi,%edx
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    
  800c20:	39 f8                	cmp    %edi,%eax
  800c22:	77 2c                	ja     800c50 <__udivdi3+0x7c>
  800c24:	0f bd f0             	bsr    %eax,%esi
  800c27:	83 f6 1f             	xor    $0x1f,%esi
  800c2a:	75 4c                	jne    800c78 <__udivdi3+0xa4>
  800c2c:	39 f8                	cmp    %edi,%eax
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c33:	72 0a                	jb     800c3f <__udivdi3+0x6b>
  800c35:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c39:	0f 87 ad 00 00 00    	ja     800cec <__udivdi3+0x118>
  800c3f:	be 01 00 00 00       	mov    $0x1,%esi
  800c44:	89 f0                	mov    %esi,%eax
  800c46:	89 fa                	mov    %edi,%edx
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    
  800c4f:	90                   	nop
  800c50:	31 ff                	xor    %edi,%edi
  800c52:	31 f6                	xor    %esi,%esi
  800c54:	89 f0                	mov    %esi,%eax
  800c56:	89 fa                	mov    %edi,%edx
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
  800c5f:	90                   	nop
  800c60:	89 fa                	mov    %edi,%edx
  800c62:	89 f0                	mov    %esi,%eax
  800c64:	f7 f1                	div    %ecx
  800c66:	89 c6                	mov    %eax,%esi
  800c68:	31 ff                	xor    %edi,%edi
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	89 fa                	mov    %edi,%edx
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
  800c75:	8d 76 00             	lea    0x0(%esi),%esi
  800c78:	89 f1                	mov    %esi,%ecx
  800c7a:	d3 e0                	shl    %cl,%eax
  800c7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c80:	b8 20 00 00 00       	mov    $0x20,%eax
  800c85:	29 f0                	sub    %esi,%eax
  800c87:	89 ea                	mov    %ebp,%edx
  800c89:	88 c1                	mov    %al,%cl
  800c8b:	d3 ea                	shr    %cl,%edx
  800c8d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800c91:	09 ca                	or     %ecx,%edx
  800c93:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c97:	89 f1                	mov    %esi,%ecx
  800c99:	d3 e5                	shl    %cl,%ebp
  800c9b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800c9f:	89 fd                	mov    %edi,%ebp
  800ca1:	88 c1                	mov    %al,%cl
  800ca3:	d3 ed                	shr    %cl,%ebp
  800ca5:	89 fa                	mov    %edi,%edx
  800ca7:	89 f1                	mov    %esi,%ecx
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800caf:	88 c1                	mov    %al,%cl
  800cb1:	d3 ef                	shr    %cl,%edi
  800cb3:	09 d7                	or     %edx,%edi
  800cb5:	89 f8                	mov    %edi,%eax
  800cb7:	89 ea                	mov    %ebp,%edx
  800cb9:	f7 74 24 08          	divl   0x8(%esp)
  800cbd:	89 d1                	mov    %edx,%ecx
  800cbf:	89 c7                	mov    %eax,%edi
  800cc1:	f7 64 24 0c          	mull   0xc(%esp)
  800cc5:	39 d1                	cmp    %edx,%ecx
  800cc7:	72 17                	jb     800ce0 <__udivdi3+0x10c>
  800cc9:	74 09                	je     800cd4 <__udivdi3+0x100>
  800ccb:	89 fe                	mov    %edi,%esi
  800ccd:	31 ff                	xor    %edi,%edi
  800ccf:	e9 41 ff ff ff       	jmp    800c15 <__udivdi3+0x41>
  800cd4:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cd8:	89 f1                	mov    %esi,%ecx
  800cda:	d3 e2                	shl    %cl,%edx
  800cdc:	39 c2                	cmp    %eax,%edx
  800cde:	73 eb                	jae    800ccb <__udivdi3+0xf7>
  800ce0:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ce3:	31 ff                	xor    %edi,%edi
  800ce5:	e9 2b ff ff ff       	jmp    800c15 <__udivdi3+0x41>
  800cea:	66 90                	xchg   %ax,%ax
  800cec:	31 f6                	xor    %esi,%esi
  800cee:	e9 22 ff ff ff       	jmp    800c15 <__udivdi3+0x41>
	...

00800cf4 <__umoddi3>:
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	83 ec 20             	sub    $0x20,%esp
  800cfa:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cfe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800d02:	89 44 24 14          	mov    %eax,0x14(%esp)
  800d06:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d0a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d0e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d12:	89 c7                	mov    %eax,%edi
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	85 ed                	test   %ebp,%ebp
  800d18:	75 16                	jne    800d30 <__umoddi3+0x3c>
  800d1a:	39 f1                	cmp    %esi,%ecx
  800d1c:	0f 86 a6 00 00 00    	jbe    800dc8 <__umoddi3+0xd4>
  800d22:	f7 f1                	div    %ecx
  800d24:	89 d0                	mov    %edx,%eax
  800d26:	31 d2                	xor    %edx,%edx
  800d28:	83 c4 20             	add    $0x20,%esp
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    
  800d2f:	90                   	nop
  800d30:	39 f5                	cmp    %esi,%ebp
  800d32:	0f 87 ac 00 00 00    	ja     800de4 <__umoddi3+0xf0>
  800d38:	0f bd c5             	bsr    %ebp,%eax
  800d3b:	83 f0 1f             	xor    $0x1f,%eax
  800d3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d42:	0f 84 a8 00 00 00    	je     800df0 <__umoddi3+0xfc>
  800d48:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d4c:	d3 e5                	shl    %cl,%ebp
  800d4e:	bf 20 00 00 00       	mov    $0x20,%edi
  800d53:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800d57:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d5b:	89 f9                	mov    %edi,%ecx
  800d5d:	d3 e8                	shr    %cl,%eax
  800d5f:	09 e8                	or     %ebp,%eax
  800d61:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d65:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d69:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d6d:	d3 e0                	shl    %cl,%eax
  800d6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d73:	89 f2                	mov    %esi,%edx
  800d75:	d3 e2                	shl    %cl,%edx
  800d77:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d7b:	d3 e0                	shl    %cl,%eax
  800d7d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800d81:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e8                	shr    %cl,%eax
  800d89:	09 d0                	or     %edx,%eax
  800d8b:	d3 ee                	shr    %cl,%esi
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	f7 74 24 18          	divl   0x18(%esp)
  800d93:	89 d6                	mov    %edx,%esi
  800d95:	f7 64 24 0c          	mull   0xc(%esp)
  800d99:	89 c5                	mov    %eax,%ebp
  800d9b:	89 d1                	mov    %edx,%ecx
  800d9d:	39 d6                	cmp    %edx,%esi
  800d9f:	72 67                	jb     800e08 <__umoddi3+0x114>
  800da1:	74 75                	je     800e18 <__umoddi3+0x124>
  800da3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800da7:	29 e8                	sub    %ebp,%eax
  800da9:	19 ce                	sbb    %ecx,%esi
  800dab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800daf:	d3 e8                	shr    %cl,%eax
  800db1:	89 f2                	mov    %esi,%edx
  800db3:	89 f9                	mov    %edi,%ecx
  800db5:	d3 e2                	shl    %cl,%edx
  800db7:	09 d0                	or     %edx,%eax
  800db9:	89 f2                	mov    %esi,%edx
  800dbb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800dbf:	d3 ea                	shr    %cl,%edx
  800dc1:	83 c4 20             	add    $0x20,%esp
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
  800dc8:	85 c9                	test   %ecx,%ecx
  800dca:	75 0b                	jne    800dd7 <__umoddi3+0xe3>
  800dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd1:	31 d2                	xor    %edx,%edx
  800dd3:	f7 f1                	div    %ecx
  800dd5:	89 c1                	mov    %eax,%ecx
  800dd7:	89 f0                	mov    %esi,%eax
  800dd9:	31 d2                	xor    %edx,%edx
  800ddb:	f7 f1                	div    %ecx
  800ddd:	89 f8                	mov    %edi,%eax
  800ddf:	e9 3e ff ff ff       	jmp    800d22 <__umoddi3+0x2e>
  800de4:	89 f2                	mov    %esi,%edx
  800de6:	83 c4 20             	add    $0x20,%esp
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    
  800ded:	8d 76 00             	lea    0x0(%esi),%esi
  800df0:	39 f5                	cmp    %esi,%ebp
  800df2:	72 04                	jb     800df8 <__umoddi3+0x104>
  800df4:	39 f9                	cmp    %edi,%ecx
  800df6:	77 06                	ja     800dfe <__umoddi3+0x10a>
  800df8:	89 f2                	mov    %esi,%edx
  800dfa:	29 cf                	sub    %ecx,%edi
  800dfc:	19 ea                	sbb    %ebp,%edx
  800dfe:	89 f8                	mov    %edi,%eax
  800e00:	83 c4 20             	add    $0x20,%esp
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    
  800e07:	90                   	nop
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 c5                	mov    %eax,%ebp
  800e0c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800e10:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800e14:	eb 8d                	jmp    800da3 <__umoddi3+0xaf>
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800e1c:	72 ea                	jb     800e08 <__umoddi3+0x114>
  800e1e:	89 f1                	mov    %esi,%ecx
  800e20:	eb 81                	jmp    800da3 <__umoddi3+0xaf>
