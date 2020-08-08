
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 e0 	movl   $0x8025e0,0x803000
  800046:	25 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 e6 25 80 00 	movl   $0x8025e6,(%esp)
  800050:	e8 6f 02 00 00       	call   8002c4 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 f5 25 80 00 	movl   $0x8025f5,(%esp)
  80005c:	e8 63 02 00 00       	call   8002c4 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 08 26 80 00 	movl   $0x802608,(%esp)
  800070:	e8 38 16 00 00       	call   8016ad <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 0e 26 80 	movl   $0x80260e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 24 26 80 00 	movl   $0x802624,(%esp)
  800096:	e8 31 01 00 00       	call   8001cc <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 31 26 80 00 	movl   $0x802631,(%esp)
  8000a2:	e8 1d 02 00 00       	call   8002c4 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 f9 0a 00 00       	call   800bb4 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 37 11 00 00       	call   801206 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 44 26 80 00 	movl   $0x802644,(%esp)
  8000da:	e8 e5 01 00 00       	call   8002c4 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 bb 0f 00 00       	call   8010a2 <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 58 26 80 00 	movl   $0x802658,(%esp)
  8000ee:	e8 d1 01 00 00       	call   8002c4 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 6c 26 80 	movl   $0x80266c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 75 26 80 	movl   $0x802675,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 7f 26 80 	movl   $0x80267f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 7e 26 80 00 	movl   $0x80267e,(%esp)
  80011a:	e8 89 1b 00 00       	call   801ca8 <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 84 26 80 	movl   $0x802684,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 24 26 80 00 	movl   $0x802624,(%esp)
  80013e:	e8 89 00 00 00       	call   8001cc <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 9b 26 80 00 	movl   $0x80269b,(%esp)
  80014a:	e8 75 01 00 00       	call   8002c4 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 10             	sub    $0x10,%esp
  800164:	8b 75 08             	mov    0x8(%ebp),%esi
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80016a:	e8 d4 0a 00 00       	call   800c43 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80016f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80017b:	c1 e0 07             	shl    $0x7,%eax
  80017e:	29 d0                	sub    %edx,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018a:	85 f6                	test   %esi,%esi
  80018c:	7e 07                	jle    800195 <libmain+0x39>
		binaryname = argv[0];
  80018e:	8b 03                	mov    (%ebx),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800195:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a1:	e8 0a 00 00 00       	call   8001b0 <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
  8001ad:	00 00                	add    %al,(%eax)
	...

008001b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b6:	e8 18 0f 00 00       	call   8010d3 <close_all>
	sys_env_destroy(0);
  8001bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c2:	e8 2a 0a 00 00       	call   800bf1 <sys_env_destroy>
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
  8001c9:	00 00                	add    %al,(%eax)
	...

008001cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001dd:	e8 61 0a 00 00       	call   800c43 <sys_getenvid>
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 b8 26 80 00 	movl   $0x8026b8,(%esp)
  8001ff:	e8 c0 00 00 00       	call   8002c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	89 74 24 04          	mov    %esi,0x4(%esp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 50 00 00 00       	call   800263 <vcprintf>
	cprintf("\n");
  800213:	c7 04 24 a0 2b 80 00 	movl   $0x802ba0,(%esp)
  80021a:	e8 a5 00 00 00       	call   8002c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021f:	cc                   	int3   
  800220:	eb fd                	jmp    80021f <_panic+0x53>
	...

00800224 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 14             	sub    $0x14,%esp
  80022b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022e:	8b 03                	mov    (%ebx),%eax
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800237:	40                   	inc    %eax
  800238:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80023a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023f:	75 19                	jne    80025a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800241:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800248:	00 
  800249:	8d 43 08             	lea    0x8(%ebx),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 60 09 00 00       	call   800bb4 <sys_cputs>
		b->idx = 0;
  800254:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80025a:	ff 43 04             	incl   0x4(%ebx)
}
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	5b                   	pop    %ebx
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80026c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800273:	00 00 00 
	b.cnt = 0;
  800276:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800294:	89 44 24 04          	mov    %eax,0x4(%esp)
  800298:	c7 04 24 24 02 80 00 	movl   $0x800224,(%esp)
  80029f:	e8 82 01 00 00       	call   800426 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 f8 08 00 00       	call   800bb4 <sys_cputs>

	return b.cnt;
}
  8002bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 87 ff ff ff       	call   800263 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800300:	85 c0                	test   %eax,%eax
  800302:	75 08                	jne    80030c <printnum+0x2c>
  800304:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800307:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030a:	77 57                	ja     800363 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800310:	4b                   	dec    %ebx
  800311:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800315:	8b 45 10             	mov    0x10(%ebp),%eax
  800318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800320:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032b:	00 
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	e8 4e 20 00 00       	call   80238c <__udivdi3>
  80033e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800342:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	89 fa                	mov    %edi,%edx
  80034f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800352:	e8 89 ff ff ff       	call   8002e0 <printnum>
  800357:	eb 0f                	jmp    800368 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800359:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035d:	89 34 24             	mov    %esi,(%esp)
  800360:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800363:	4b                   	dec    %ebx
  800364:	85 db                	test   %ebx,%ebx
  800366:	7f f1                	jg     800359 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800368:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800370:	8b 45 10             	mov    0x10(%ebp),%eax
  800373:	89 44 24 08          	mov    %eax,0x8(%esp)
  800377:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037e:	00 
  80037f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038c:	e8 1b 21 00 00       	call   8024ac <__umoddi3>
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	0f be 80 db 26 80 00 	movsbl 0x8026db(%eax),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003a2:	83 c4 3c             	add    $0x3c,%esp
  8003a5:	5b                   	pop    %ebx
  8003a6:	5e                   	pop    %esi
  8003a7:	5f                   	pop    %edi
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ad:	83 fa 01             	cmp    $0x1,%edx
  8003b0:	7e 0e                	jle    8003c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	8b 52 04             	mov    0x4(%edx),%edx
  8003be:	eb 22                	jmp    8003e2 <getuint+0x38>
	else if (lflag)
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	74 10                	je     8003d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c9:	89 08                	mov    %ecx,(%eax)
  8003cb:	8b 02                	mov    (%edx),%eax
  8003cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d2:	eb 0e                	jmp    8003e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d9:	89 08                	mov    %ecx,(%eax)
  8003db:	8b 02                	mov    (%edx),%eax
  8003dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ea:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f2:	73 08                	jae    8003fc <sprintputch+0x18>
		*b->buf++ = ch;
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 0a                	mov    %cl,(%edx)
  8003f9:	42                   	inc    %edx
  8003fa:	89 10                	mov    %edx,(%eax)
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800407:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040b:	8b 45 10             	mov    0x10(%ebp),%eax
  80040e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
  800415:	89 44 24 04          	mov    %eax,0x4(%esp)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 02 00 00 00       	call   800426 <vprintfmt>
	va_end(ap);
}
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	57                   	push   %edi
  80042a:	56                   	push   %esi
  80042b:	53                   	push   %ebx
  80042c:	83 ec 4c             	sub    $0x4c,%esp
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 75 10             	mov    0x10(%ebp),%esi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 8b 03 00 00    	je     8007ca <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80043f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 06             	movzbl (%esi),%eax
  80044c:	46                   	inc    %esi
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e5                	jne    800437 <vprintfmt+0x11>
  800452:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800456:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80045d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800462:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800469:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046e:	eb 26                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800473:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800477:	eb 1d                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800480:	eb 14                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800485:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048c:	eb 08                	jmp    800496 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800491:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	0f b6 06             	movzbl (%esi),%eax
  800499:	8d 56 01             	lea    0x1(%esi),%edx
  80049c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049f:	8a 16                	mov    (%esi),%dl
  8004a1:	83 ea 23             	sub    $0x23,%edx
  8004a4:	80 fa 55             	cmp    $0x55,%dl
  8004a7:	0f 87 01 03 00 00    	ja     8007ae <vprintfmt+0x388>
  8004ad:	0f b6 d2             	movzbl %dl,%edx
  8004b0:	ff 24 95 20 28 80 00 	jmp    *0x802820(,%edx,4)
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ba:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004cc:	83 fa 09             	cmp    $0x9,%edx
  8004cf:	77 2a                	ja     8004fb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d2:	eb eb                	jmp    8004bf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e2:	eb 17                	jmp    8004fb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e8:	78 98                	js     800482 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ed:	eb a7                	jmp    800496 <vprintfmt+0x70>
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004f9:	eb 9b                	jmp    800496 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ff:	79 95                	jns    800496 <vprintfmt+0x70>
  800501:	eb 8b                	jmp    80048e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800503:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800507:	eb 8d                	jmp    800496 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 04 24             	mov    %eax,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800521:	e9 23 ff ff ff       	jmp    800449 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	79 02                	jns    800537 <vprintfmt+0x111>
  800535:	f7 d8                	neg    %eax
  800537:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800539:	83 f8 0f             	cmp    $0xf,%eax
  80053c:	7f 0b                	jg     800549 <vprintfmt+0x123>
  80053e:	8b 04 85 80 29 80 00 	mov    0x802980(,%eax,4),%eax
  800545:	85 c0                	test   %eax,%eax
  800547:	75 23                	jne    80056c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800549:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054d:	c7 44 24 08 f3 26 80 	movl   $0x8026f3,0x8(%esp)
  800554:	00 
  800555:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 9a fe ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 dd fe ff ff       	jmp    800449 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800570:	c7 44 24 08 da 2a 80 	movl   $0x802ada,0x8(%esp)
  800577:	00 
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	8b 55 08             	mov    0x8(%ebp),%edx
  80057f:	89 14 24             	mov    %edx,(%esp)
  800582:	e8 77 fe ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058a:	e9 ba fe ff ff       	jmp    800449 <vprintfmt+0x23>
  80058f:	89 f9                	mov    %edi,%ecx
  800591:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	8b 30                	mov    (%eax),%esi
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	75 05                	jne    8005ab <vprintfmt+0x185>
				p = "(null)";
  8005a6:	be ec 26 80 00       	mov    $0x8026ec,%esi
			if (width > 0 && padc != '-')
  8005ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005af:	0f 8e 84 00 00 00    	jle    800639 <vprintfmt+0x213>
  8005b5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005b9:	74 7e                	je     800639 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005bf:	89 34 24             	mov    %esi,(%esp)
  8005c2:	e8 ab 02 00 00       	call   800872 <strnlen>
  8005c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ca:	29 c2                	sub    %eax,%edx
  8005cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005cf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005d3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005d6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005d9:	89 de                	mov    %ebx,%esi
  8005db:	89 d3                	mov    %edx,%ebx
  8005dd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	eb 0b                	jmp    8005ec <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	89 3c 24             	mov    %edi,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <vprintfmt+0x1bb>
  8005f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f3:	89 f3                	mov    %esi,%ebx
  8005f5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	79 05                	jns    800604 <vprintfmt+0x1de>
  8005ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	29 c2                	sub    %eax,%edx
  800609:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80060c:	eb 2b                	jmp    800639 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800612:	74 18                	je     80062c <vprintfmt+0x206>
  800614:	8d 50 e0             	lea    -0x20(%eax),%edx
  800617:	83 fa 5e             	cmp    $0x5e,%edx
  80061a:	76 10                	jbe    80062c <vprintfmt+0x206>
					putch('?', putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
  80062a:	eb 0a                	jmp    800636 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800636:	ff 4d e4             	decl   -0x1c(%ebp)
  800639:	0f be 06             	movsbl (%esi),%eax
  80063c:	46                   	inc    %esi
  80063d:	85 c0                	test   %eax,%eax
  80063f:	74 21                	je     800662 <vprintfmt+0x23c>
  800641:	85 ff                	test   %edi,%edi
  800643:	78 c9                	js     80060e <vprintfmt+0x1e8>
  800645:	4f                   	dec    %edi
  800646:	79 c6                	jns    80060e <vprintfmt+0x1e8>
  800648:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064b:	89 de                	mov    %ebx,%esi
  80064d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800650:	eb 18                	jmp    80066a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800652:	89 74 24 04          	mov    %esi,0x4(%esp)
  800656:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	4b                   	dec    %ebx
  800660:	eb 08                	jmp    80066a <vprintfmt+0x244>
  800662:	8b 7d 08             	mov    0x8(%ebp),%edi
  800665:	89 de                	mov    %ebx,%esi
  800667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80066a:	85 db                	test   %ebx,%ebx
  80066c:	7f e4                	jg     800652 <vprintfmt+0x22c>
  80066e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800671:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 ce fd ff ff       	jmp    800449 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067b:	83 f9 01             	cmp    $0x1,%ecx
  80067e:	7e 10                	jle    800690 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 08             	lea    0x8(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	8b 78 04             	mov    0x4(%eax),%edi
  80068e:	eb 26                	jmp    8006b6 <vprintfmt+0x290>
	else if (lflag)
  800690:	85 c9                	test   %ecx,%ecx
  800692:	74 12                	je     8006a6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 30                	mov    (%eax),%esi
  80069f:	89 f7                	mov    %esi,%edi
  8006a1:	c1 ff 1f             	sar    $0x1f,%edi
  8006a4:	eb 10                	jmp    8006b6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	89 f7                	mov    %esi,%edi
  8006b3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b6:	85 ff                	test   %edi,%edi
  8006b8:	78 0a                	js     8006c4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bf:	e9 ac 00 00 00       	jmp    800770 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d2:	f7 de                	neg    %esi
  8006d4:	83 d7 00             	adc    $0x0,%edi
  8006d7:	f7 df                	neg    %edi
			}
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	e9 8d 00 00 00       	jmp    800770 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e3:	89 ca                	mov    %ecx,%edx
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e8:	e8 bd fc ff ff       	call   8003aa <getuint>
  8006ed:	89 c6                	mov    %eax,%esi
  8006ef:	89 d7                	mov    %edx,%edi
			base = 10;
  8006f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006f6:	eb 78                	jmp    800770 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800711:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800725:	e9 1f fd ff ff       	jmp    800449 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8d 50 04             	lea    0x4(%eax),%edx
  80074c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074f:	8b 30                	mov    (%eax),%esi
  800751:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800756:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075b:	eb 13                	jmp    800770 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075d:	89 ca                	mov    %ecx,%edx
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 43 fc ff ff       	call   8003aa <getuint>
  800767:	89 c6                	mov    %eax,%esi
  800769:	89 d7                	mov    %edx,%edi
			base = 16;
  80076b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800770:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800774:	89 54 24 10          	mov    %edx,0x10(%esp)
  800778:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80077b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	89 34 24             	mov    %esi,(%esp)
  800786:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078a:	89 da                	mov    %ebx,%edx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	e8 4c fb ff ff       	call   8002e0 <printnum>
			break;
  800794:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800797:	e9 ad fc ff ff       	jmp    800449 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a9:	e9 9b fc ff ff       	jmp    800449 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bc:	eb 01                	jmp    8007bf <vprintfmt+0x399>
  8007be:	4e                   	dec    %esi
  8007bf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c3:	75 f9                	jne    8007be <vprintfmt+0x398>
  8007c5:	e9 7f fc ff ff       	jmp    800449 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007ca:	83 c4 4c             	add    $0x4c,%esp
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5f                   	pop    %edi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 28             	sub    $0x28,%esp
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	74 30                	je     800823 <vsnprintf+0x51>
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	7e 33                	jle    80082a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800801:	89 44 24 08          	mov    %eax,0x8(%esp)
  800805:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  800813:	e8 0e fc ff ff       	call   800426 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800821:	eb 0c                	jmp    80082f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800823:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800828:	eb 05                	jmp    80082f <vsnprintf+0x5d>
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800837:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083e:	8b 45 10             	mov    0x10(%ebp),%eax
  800841:	89 44 24 08          	mov    %eax,0x8(%esp)
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 7b ff ff ff       	call   8007d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    
  800859:	00 00                	add    %al,(%eax)
	...

0080085c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
  800867:	eb 01                	jmp    80086a <strlen+0xe>
		n++;
  800869:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086e:	75 f9                	jne    800869 <strlen+0xd>
		n++;
	return n;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
  800880:	eb 01                	jmp    800883 <strnlen+0x11>
		n++;
  800882:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800883:	39 d0                	cmp    %edx,%eax
  800885:	74 06                	je     80088d <strnlen+0x1b>
  800887:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088b:	75 f5                	jne    800882 <strnlen+0x10>
		n++;
	return n;
}
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800899:	ba 00 00 00 00       	mov    $0x0,%edx
  80089e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008a1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a4:	42                   	inc    %edx
  8008a5:	84 c9                	test   %cl,%cl
  8008a7:	75 f5                	jne    80089e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b6:	89 1c 24             	mov    %ebx,(%esp)
  8008b9:	e8 9e ff ff ff       	call   80085c <strlen>
	strcpy(dst + len, src);
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c5:	01 d8                	add    %ebx,%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 c0 ff ff ff       	call   80088f <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	83 c4 08             	add    $0x8,%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ea:	eb 0c                	jmp    8008f8 <strncpy+0x21>
		*dst++ = *src;
  8008ec:	8a 1a                	mov    (%edx),%bl
  8008ee:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f1:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f7:	41                   	inc    %ecx
  8008f8:	39 f1                	cmp    %esi,%ecx
  8008fa:	75 f0                	jne    8008ec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 75 08             	mov    0x8(%ebp),%esi
  800908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090e:	85 d2                	test   %edx,%edx
  800910:	75 0a                	jne    80091c <strlcpy+0x1c>
  800912:	89 f0                	mov    %esi,%eax
  800914:	eb 1a                	jmp    800930 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800916:	88 18                	mov    %bl,(%eax)
  800918:	40                   	inc    %eax
  800919:	41                   	inc    %ecx
  80091a:	eb 02                	jmp    80091e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80091e:	4a                   	dec    %edx
  80091f:	74 0a                	je     80092b <strlcpy+0x2b>
  800921:	8a 19                	mov    (%ecx),%bl
  800923:	84 db                	test   %bl,%bl
  800925:	75 ef                	jne    800916 <strlcpy+0x16>
  800927:	89 c2                	mov    %eax,%edx
  800929:	eb 02                	jmp    80092d <strlcpy+0x2d>
  80092b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80092d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800930:	29 f0                	sub    %esi,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093f:	eb 02                	jmp    800943 <strcmp+0xd>
		p++, q++;
  800941:	41                   	inc    %ecx
  800942:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800943:	8a 01                	mov    (%ecx),%al
  800945:	84 c0                	test   %al,%al
  800947:	74 04                	je     80094d <strcmp+0x17>
  800949:	3a 02                	cmp    (%edx),%al
  80094b:	74 f4                	je     800941 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094d:	0f b6 c0             	movzbl %al,%eax
  800950:	0f b6 12             	movzbl (%edx),%edx
  800953:	29 d0                	sub    %edx,%eax
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800961:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800964:	eb 03                	jmp    800969 <strncmp+0x12>
		n--, p++, q++;
  800966:	4a                   	dec    %edx
  800967:	40                   	inc    %eax
  800968:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800969:	85 d2                	test   %edx,%edx
  80096b:	74 14                	je     800981 <strncmp+0x2a>
  80096d:	8a 18                	mov    (%eax),%bl
  80096f:	84 db                	test   %bl,%bl
  800971:	74 04                	je     800977 <strncmp+0x20>
  800973:	3a 19                	cmp    (%ecx),%bl
  800975:	74 ef                	je     800966 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800977:	0f b6 00             	movzbl (%eax),%eax
  80097a:	0f b6 11             	movzbl (%ecx),%edx
  80097d:	29 d0                	sub    %edx,%eax
  80097f:	eb 05                	jmp    800986 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800986:	5b                   	pop    %ebx
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800992:	eb 05                	jmp    800999 <strchr+0x10>
		if (*s == c)
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 0c                	je     8009a4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800998:	40                   	inc    %eax
  800999:	8a 10                	mov    (%eax),%dl
  80099b:	84 d2                	test   %dl,%dl
  80099d:	75 f5                	jne    800994 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009af:	eb 05                	jmp    8009b6 <strfind+0x10>
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 07                	je     8009bc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b5:	40                   	inc    %eax
  8009b6:	8a 10                	mov    (%eax),%dl
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	75 f5                	jne    8009b1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cd:	85 c9                	test   %ecx,%ecx
  8009cf:	74 30                	je     800a01 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d7:	75 25                	jne    8009fe <memset+0x40>
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 20                	jne    8009fe <memset+0x40>
		c &= 0xFF;
  8009de:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e1:	89 d3                	mov    %edx,%ebx
  8009e3:	c1 e3 08             	shl    $0x8,%ebx
  8009e6:	89 d6                	mov    %edx,%esi
  8009e8:	c1 e6 18             	shl    $0x18,%esi
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	c1 e0 10             	shl    $0x10,%eax
  8009f0:	09 f0                	or     %esi,%eax
  8009f2:	09 d0                	or     %edx,%eax
  8009f4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f9:	fc                   	cld    
  8009fa:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fc:	eb 03                	jmp    800a01 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 34                	jae    800a4e <memmove+0x46>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2d                	jae    800a4e <memmove+0x46>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	f6 c2 03             	test   $0x3,%dl
  800a27:	75 1b                	jne    800a44 <memmove+0x3c>
  800a29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2f:	75 13                	jne    800a44 <memmove+0x3c>
  800a31:	f6 c1 03             	test   $0x3,%cl
  800a34:	75 0e                	jne    800a44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a36:	83 ef 04             	sub    $0x4,%edi
  800a39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3f:	fd                   	std    
  800a40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a42:	eb 07                	jmp    800a4b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a44:	4f                   	dec    %edi
  800a45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a48:	fd                   	std    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4b:	fc                   	cld    
  800a4c:	eb 20                	jmp    800a6e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a54:	75 13                	jne    800a69 <memmove+0x61>
  800a56:	a8 03                	test   $0x3,%al
  800a58:	75 0f                	jne    800a69 <memmove+0x61>
  800a5a:	f6 c1 03             	test   $0x3,%cl
  800a5d:	75 0a                	jne    800a69 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a67:	eb 05                	jmp    800a6e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a69:	89 c7                	mov    %eax,%edi
  800a6b:	fc                   	cld    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a78:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	89 04 24             	mov    %eax,(%esp)
  800a8c:	e8 77 ff ff ff       	call   800a08 <memmove>
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	eb 16                	jmp    800abf <memcmp+0x2c>
		if (*s1 != *s2)
  800aa9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800aac:	42                   	inc    %edx
  800aad:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ab1:	38 c8                	cmp    %cl,%al
  800ab3:	74 0a                	je     800abf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 c9             	movzbl %cl,%ecx
  800abb:	29 c8                	sub    %ecx,%eax
  800abd:	eb 09                	jmp    800ac8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	39 da                	cmp    %ebx,%edx
  800ac1:	75 e6                	jne    800aa9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adb:	eb 05                	jmp    800ae2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800add:	38 08                	cmp    %cl,(%eax)
  800adf:	74 05                	je     800ae6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae1:	40                   	inc    %eax
  800ae2:	39 d0                	cmp    %edx,%eax
  800ae4:	72 f7                	jb     800add <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af4:	eb 01                	jmp    800af7 <strtol+0xf>
		s++;
  800af6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af7:	8a 02                	mov    (%edx),%al
  800af9:	3c 20                	cmp    $0x20,%al
  800afb:	74 f9                	je     800af6 <strtol+0xe>
  800afd:	3c 09                	cmp    $0x9,%al
  800aff:	74 f5                	je     800af6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b01:	3c 2b                	cmp    $0x2b,%al
  800b03:	75 08                	jne    800b0d <strtol+0x25>
		s++;
  800b05:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b06:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0b:	eb 13                	jmp    800b20 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0d:	3c 2d                	cmp    $0x2d,%al
  800b0f:	75 0a                	jne    800b1b <strtol+0x33>
		s++, neg = 1;
  800b11:	8d 52 01             	lea    0x1(%edx),%edx
  800b14:	bf 01 00 00 00       	mov    $0x1,%edi
  800b19:	eb 05                	jmp    800b20 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b20:	85 db                	test   %ebx,%ebx
  800b22:	74 05                	je     800b29 <strtol+0x41>
  800b24:	83 fb 10             	cmp    $0x10,%ebx
  800b27:	75 28                	jne    800b51 <strtol+0x69>
  800b29:	8a 02                	mov    (%edx),%al
  800b2b:	3c 30                	cmp    $0x30,%al
  800b2d:	75 10                	jne    800b3f <strtol+0x57>
  800b2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b33:	75 0a                	jne    800b3f <strtol+0x57>
		s += 2, base = 16;
  800b35:	83 c2 02             	add    $0x2,%edx
  800b38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3d:	eb 12                	jmp    800b51 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b3f:	85 db                	test   %ebx,%ebx
  800b41:	75 0e                	jne    800b51 <strtol+0x69>
  800b43:	3c 30                	cmp    $0x30,%al
  800b45:	75 05                	jne    800b4c <strtol+0x64>
		s++, base = 8;
  800b47:	42                   	inc    %edx
  800b48:	b3 08                	mov    $0x8,%bl
  800b4a:	eb 05                	jmp    800b51 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b58:	8a 0a                	mov    (%edx),%cl
  800b5a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x82>
			dig = *s - '0';
  800b62:	0f be c9             	movsbl %cl,%ecx
  800b65:	83 e9 30             	sub    $0x30,%ecx
  800b68:	eb 1e                	jmp    800b88 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6d:	80 fb 19             	cmp    $0x19,%bl
  800b70:	77 08                	ja     800b7a <strtol+0x92>
			dig = *s - 'a' + 10;
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 57             	sub    $0x57,%ecx
  800b78:	eb 0e                	jmp    800b88 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7d:	80 fb 19             	cmp    $0x19,%bl
  800b80:	77 12                	ja     800b94 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b82:	0f be c9             	movsbl %cl,%ecx
  800b85:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b88:	39 f1                	cmp    %esi,%ecx
  800b8a:	7d 0c                	jge    800b98 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b8c:	42                   	inc    %edx
  800b8d:	0f af c6             	imul   %esi,%eax
  800b90:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b92:	eb c4                	jmp    800b58 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b94:	89 c1                	mov    %eax,%ecx
  800b96:	eb 02                	jmp    800b9a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b98:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9e:	74 05                	je     800ba5 <strtol+0xbd>
		*endptr = (char *) s;
  800ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba5:	85 ff                	test   %edi,%edi
  800ba7:	74 04                	je     800bad <strtol+0xc5>
  800ba9:	89 c8                	mov    %ecx,%eax
  800bab:	f7 d8                	neg    %eax
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    
	...

00800bb4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	89 c3                	mov    %eax,%ebx
  800bc7:	89 c7                	mov    %eax,%edi
  800bc9:	89 c6                	mov    %eax,%esi
  800bcb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bff:	b8 03 00 00 00       	mov    $0x3,%eax
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 cb                	mov    %ecx,%ebx
  800c09:	89 cf                	mov    %ecx,%edi
  800c0b:	89 ce                	mov    %ecx,%esi
  800c0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 28                	jle    800c3b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c17:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c1e:	00 
  800c1f:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800c26:	00 
  800c27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2e:	00 
  800c2f:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800c36:	e8 91 f5 ff ff       	call   8001cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3b:	83 c4 2c             	add    $0x2c,%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_yield>:

void
sys_yield(void)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c72:	89 d1                	mov    %edx,%ecx
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	89 d7                	mov    %edx,%edi
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	be 00 00 00 00       	mov    $0x0,%esi
  800c8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 f7                	mov    %esi,%edi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 28                	jle    800ccd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc0:	00 
  800cc1:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800cc8:	e8 ff f4 ff ff       	call   8001cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccd:	83 c4 2c             	add    $0x2c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 28                	jle    800d20 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d03:	00 
  800d04:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d13:	00 
  800d14:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d1b:	e8 ac f4 ff ff       	call   8001cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d20:	83 c4 2c             	add    $0x2c,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d36:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	89 df                	mov    %ebx,%edi
  800d43:	89 de                	mov    %ebx,%esi
  800d45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 28                	jle    800d73 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d56:	00 
  800d57:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d66:	00 
  800d67:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d6e:	e8 59 f4 ff ff       	call   8001cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d73:	83 c4 2c             	add    $0x2c,%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 28                	jle    800dc6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800da9:	00 
  800daa:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800db1:	00 
  800db2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db9:	00 
  800dba:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800dc1:	e8 06 f4 ff ff       	call   8001cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc6:	83 c4 2c             	add    $0x2c,%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	b8 09 00 00 00       	mov    $0x9,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	89 de                	mov    %ebx,%esi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 28                	jle    800e19 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e04:	00 
  800e05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0c:	00 
  800e0d:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e14:	e8 b3 f3 ff ff       	call   8001cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e19:	83 c4 2c             	add    $0x2c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	89 df                	mov    %ebx,%edi
  800e3c:	89 de                	mov    %ebx,%esi
  800e3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e67:	e8 60 f3 ff ff       	call   8001cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6c:	83 c4 2c             	add    $0x2c,%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	be 00 00 00 00       	mov    $0x0,%esi
  800e7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ead:	89 cb                	mov    %ecx,%ebx
  800eaf:	89 cf                	mov    %ecx,%edi
  800eb1:	89 ce                	mov    %ecx,%esi
  800eb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7e 28                	jle    800ee1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800edc:	e8 eb f2 ff ff       	call   8001cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee1:	83 c4 2c             	add    $0x2c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	00 00                	add    %al,(%eax)
	...

00800eec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef7:	c1 e8 0c             	shr    $0xc,%eax
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	89 04 24             	mov    %eax,(%esp)
  800f08:	e8 df ff ff ff       	call   800eec <fd2num>
  800f0d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f12:	c1 e0 0c             	shl    $0xc,%eax
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	53                   	push   %ebx
  800f1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f1e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f23:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	c1 ea 16             	shr    $0x16,%edx
  800f2a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f31:	f6 c2 01             	test   $0x1,%dl
  800f34:	74 11                	je     800f47 <fd_alloc+0x30>
  800f36:	89 c2                	mov    %eax,%edx
  800f38:	c1 ea 0c             	shr    $0xc,%edx
  800f3b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f42:	f6 c2 01             	test   $0x1,%dl
  800f45:	75 09                	jne    800f50 <fd_alloc+0x39>
			*fd_store = fd;
  800f47:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	eb 17                	jmp    800f67 <fd_alloc+0x50>
  800f50:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f55:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f5a:	75 c7                	jne    800f23 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f62:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f67:	5b                   	pop    %ebx
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f70:	83 f8 1f             	cmp    $0x1f,%eax
  800f73:	77 36                	ja     800fab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f75:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f7a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f7d:	89 c2                	mov    %eax,%edx
  800f7f:	c1 ea 16             	shr    $0x16,%edx
  800f82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f89:	f6 c2 01             	test   $0x1,%dl
  800f8c:	74 24                	je     800fb2 <fd_lookup+0x48>
  800f8e:	89 c2                	mov    %eax,%edx
  800f90:	c1 ea 0c             	shr    $0xc,%edx
  800f93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9a:	f6 c2 01             	test   $0x1,%dl
  800f9d:	74 1a                	je     800fb9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa2:	89 02                	mov    %eax,(%edx)
	return 0;
  800fa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa9:	eb 13                	jmp    800fbe <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb0:	eb 0c                	jmp    800fbe <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb7:	eb 05                	jmp    800fbe <fd_lookup+0x54>
  800fb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 14             	sub    $0x14,%esp
  800fc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd2:	eb 0e                	jmp    800fe2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fd4:	39 08                	cmp    %ecx,(%eax)
  800fd6:	75 09                	jne    800fe1 <dev_lookup+0x21>
			*dev = devtab[i];
  800fd8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	eb 33                	jmp    801014 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fe1:	42                   	inc    %edx
  800fe2:	8b 04 95 88 2a 80 00 	mov    0x802a88(,%edx,4),%eax
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	75 e7                	jne    800fd4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fed:	a1 04 40 80 00       	mov    0x804004,%eax
  800ff2:	8b 40 48             	mov    0x48(%eax),%eax
  800ff5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffd:	c7 04 24 0c 2a 80 00 	movl   $0x802a0c,(%esp)
  801004:	e8 bb f2 ff ff       	call   8002c4 <cprintf>
	*dev = 0;
  801009:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80100f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801014:	83 c4 14             	add    $0x14,%esp
  801017:	5b                   	pop    %ebx
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	83 ec 30             	sub    $0x30,%esp
  801022:	8b 75 08             	mov    0x8(%ebp),%esi
  801025:	8a 45 0c             	mov    0xc(%ebp),%al
  801028:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80102b:	89 34 24             	mov    %esi,(%esp)
  80102e:	e8 b9 fe ff ff       	call   800eec <fd2num>
  801033:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801036:	89 54 24 04          	mov    %edx,0x4(%esp)
  80103a:	89 04 24             	mov    %eax,(%esp)
  80103d:	e8 28 ff ff ff       	call   800f6a <fd_lookup>
  801042:	89 c3                	mov    %eax,%ebx
  801044:	85 c0                	test   %eax,%eax
  801046:	78 05                	js     80104d <fd_close+0x33>
	    || fd != fd2)
  801048:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80104b:	74 0d                	je     80105a <fd_close+0x40>
		return (must_exist ? r : 0);
  80104d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801051:	75 46                	jne    801099 <fd_close+0x7f>
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	eb 3f                	jmp    801099 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80105a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80105d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801061:	8b 06                	mov    (%esi),%eax
  801063:	89 04 24             	mov    %eax,(%esp)
  801066:	e8 55 ff ff ff       	call   800fc0 <dev_lookup>
  80106b:	89 c3                	mov    %eax,%ebx
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 18                	js     801089 <fd_close+0x6f>
		if (dev->dev_close)
  801071:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801074:	8b 40 10             	mov    0x10(%eax),%eax
  801077:	85 c0                	test   %eax,%eax
  801079:	74 09                	je     801084 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80107b:	89 34 24             	mov    %esi,(%esp)
  80107e:	ff d0                	call   *%eax
  801080:	89 c3                	mov    %eax,%ebx
  801082:	eb 05                	jmp    801089 <fd_close+0x6f>
		else
			r = 0;
  801084:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80108d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801094:	e8 8f fc ff ff       	call   800d28 <sys_page_unmap>
	return r;
}
  801099:	89 d8                	mov    %ebx,%eax
  80109b:	83 c4 30             	add    $0x30,%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	89 04 24             	mov    %eax,(%esp)
  8010b5:	e8 b0 fe ff ff       	call   800f6a <fd_lookup>
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 13                	js     8010d1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c5:	00 
  8010c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c9:	89 04 24             	mov    %eax,(%esp)
  8010cc:	e8 49 ff ff ff       	call   80101a <fd_close>
}
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <close_all>:

void
close_all(void)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010da:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010df:	89 1c 24             	mov    %ebx,(%esp)
  8010e2:	e8 bb ff ff ff       	call   8010a2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e7:	43                   	inc    %ebx
  8010e8:	83 fb 20             	cmp    $0x20,%ebx
  8010eb:	75 f2                	jne    8010df <close_all+0xc>
		close(i);
}
  8010ed:	83 c4 14             	add    $0x14,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 4c             	sub    $0x4c,%esp
  8010fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801102:	89 44 24 04          	mov    %eax,0x4(%esp)
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	89 04 24             	mov    %eax,(%esp)
  80110c:	e8 59 fe ff ff       	call   800f6a <fd_lookup>
  801111:	89 c3                	mov    %eax,%ebx
  801113:	85 c0                	test   %eax,%eax
  801115:	0f 88 e1 00 00 00    	js     8011fc <dup+0x109>
		return r;
	close(newfdnum);
  80111b:	89 3c 24             	mov    %edi,(%esp)
  80111e:	e8 7f ff ff ff       	call   8010a2 <close>

	newfd = INDEX2FD(newfdnum);
  801123:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801129:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80112c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112f:	89 04 24             	mov    %eax,(%esp)
  801132:	e8 c5 fd ff ff       	call   800efc <fd2data>
  801137:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801139:	89 34 24             	mov    %esi,(%esp)
  80113c:	e8 bb fd ff ff       	call   800efc <fd2data>
  801141:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801144:	89 d8                	mov    %ebx,%eax
  801146:	c1 e8 16             	shr    $0x16,%eax
  801149:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801150:	a8 01                	test   $0x1,%al
  801152:	74 46                	je     80119a <dup+0xa7>
  801154:	89 d8                	mov    %ebx,%eax
  801156:	c1 e8 0c             	shr    $0xc,%eax
  801159:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801160:	f6 c2 01             	test   $0x1,%dl
  801163:	74 35                	je     80119a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801165:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116c:	25 07 0e 00 00       	and    $0xe07,%eax
  801171:	89 44 24 10          	mov    %eax,0x10(%esp)
  801175:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801178:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801183:	00 
  801184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801188:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80118f:	e8 41 fb ff ff       	call   800cd5 <sys_page_map>
  801194:	89 c3                	mov    %eax,%ebx
  801196:	85 c0                	test   %eax,%eax
  801198:	78 3b                	js     8011d5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 0c             	shr    $0xc,%edx
  8011a2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011af:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011be:	00 
  8011bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ca:	e8 06 fb ff ff       	call   800cd5 <sys_page_map>
  8011cf:	89 c3                	mov    %eax,%ebx
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 25                	jns    8011fa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e0:	e8 43 fb ff ff       	call   800d28 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f3:	e8 30 fb ff ff       	call   800d28 <sys_page_unmap>
	return r;
  8011f8:	eb 02                	jmp    8011fc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011fa:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011fc:	89 d8                	mov    %ebx,%eax
  8011fe:	83 c4 4c             	add    $0x4c,%esp
  801201:	5b                   	pop    %ebx
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	53                   	push   %ebx
  80120a:	83 ec 24             	sub    $0x24,%esp
  80120d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801210:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801213:	89 44 24 04          	mov    %eax,0x4(%esp)
  801217:	89 1c 24             	mov    %ebx,(%esp)
  80121a:	e8 4b fd ff ff       	call   800f6a <fd_lookup>
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 6d                	js     801290 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801223:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122d:	8b 00                	mov    (%eax),%eax
  80122f:	89 04 24             	mov    %eax,(%esp)
  801232:	e8 89 fd ff ff       	call   800fc0 <dev_lookup>
  801237:	85 c0                	test   %eax,%eax
  801239:	78 55                	js     801290 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80123b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123e:	8b 50 08             	mov    0x8(%eax),%edx
  801241:	83 e2 03             	and    $0x3,%edx
  801244:	83 fa 01             	cmp    $0x1,%edx
  801247:	75 23                	jne    80126c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801249:	a1 04 40 80 00       	mov    0x804004,%eax
  80124e:	8b 40 48             	mov    0x48(%eax),%eax
  801251:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	c7 04 24 4d 2a 80 00 	movl   $0x802a4d,(%esp)
  801260:	e8 5f f0 ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126a:	eb 24                	jmp    801290 <read+0x8a>
	}
	if (!dev->dev_read)
  80126c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126f:	8b 52 08             	mov    0x8(%edx),%edx
  801272:	85 d2                	test   %edx,%edx
  801274:	74 15                	je     80128b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801276:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801279:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801284:	89 04 24             	mov    %eax,(%esp)
  801287:	ff d2                	call   *%edx
  801289:	eb 05                	jmp    801290 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80128b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801290:	83 c4 24             	add    $0x24,%esp
  801293:	5b                   	pop    %ebx
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 1c             	sub    $0x1c,%esp
  80129f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012aa:	eb 23                	jmp    8012cf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ac:	89 f0                	mov    %esi,%eax
  8012ae:	29 d8                	sub    %ebx,%eax
  8012b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b7:	01 d8                	add    %ebx,%eax
  8012b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bd:	89 3c 24             	mov    %edi,(%esp)
  8012c0:	e8 41 ff ff ff       	call   801206 <read>
		if (m < 0)
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 10                	js     8012d9 <readn+0x43>
			return m;
		if (m == 0)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	74 0a                	je     8012d7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012cd:	01 c3                	add    %eax,%ebx
  8012cf:	39 f3                	cmp    %esi,%ebx
  8012d1:	72 d9                	jb     8012ac <readn+0x16>
  8012d3:	89 d8                	mov    %ebx,%eax
  8012d5:	eb 02                	jmp    8012d9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012d7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012d9:	83 c4 1c             	add    $0x1c,%esp
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 24             	sub    $0x24,%esp
  8012e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f2:	89 1c 24             	mov    %ebx,(%esp)
  8012f5:	e8 70 fc ff ff       	call   800f6a <fd_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 68                	js     801366 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	89 44 24 04          	mov    %eax,0x4(%esp)
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	8b 00                	mov    (%eax),%eax
  80130a:	89 04 24             	mov    %eax,(%esp)
  80130d:	e8 ae fc ff ff       	call   800fc0 <dev_lookup>
  801312:	85 c0                	test   %eax,%eax
  801314:	78 50                	js     801366 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131d:	75 23                	jne    801342 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80131f:	a1 04 40 80 00       	mov    0x804004,%eax
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	c7 04 24 69 2a 80 00 	movl   $0x802a69,(%esp)
  801336:	e8 89 ef ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  80133b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801340:	eb 24                	jmp    801366 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801342:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801345:	8b 52 0c             	mov    0xc(%edx),%edx
  801348:	85 d2                	test   %edx,%edx
  80134a:	74 15                	je     801361 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80134c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80134f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801353:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801356:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80135a:	89 04 24             	mov    %eax,(%esp)
  80135d:	ff d2                	call   *%edx
  80135f:	eb 05                	jmp    801366 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801361:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801366:	83 c4 24             	add    $0x24,%esp
  801369:	5b                   	pop    %ebx
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <seek>:

int
seek(int fdnum, off_t offset)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801372:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	89 04 24             	mov    %eax,(%esp)
  80137f:	e8 e6 fb ff ff       	call   800f6a <fd_lookup>
  801384:	85 c0                	test   %eax,%eax
  801386:	78 0e                	js     801396 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801388:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80138b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801391:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 24             	sub    $0x24,%esp
  80139f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	89 1c 24             	mov    %ebx,(%esp)
  8013ac:	e8 b9 fb ff ff       	call   800f6a <fd_lookup>
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 61                	js     801416 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bf:	8b 00                	mov    (%eax),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 f7 fb ff ff       	call   800fc0 <dev_lookup>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 49                	js     801416 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d4:	75 23                	jne    8013f9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013d6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013db:	8b 40 48             	mov    0x48(%eax),%eax
  8013de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	c7 04 24 2c 2a 80 00 	movl   $0x802a2c,(%esp)
  8013ed:	e8 d2 ee ff ff       	call   8002c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f7:	eb 1d                	jmp    801416 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fc:	8b 52 18             	mov    0x18(%edx),%edx
  8013ff:	85 d2                	test   %edx,%edx
  801401:	74 0e                	je     801411 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801406:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80140a:	89 04 24             	mov    %eax,(%esp)
  80140d:	ff d2                	call   *%edx
  80140f:	eb 05                	jmp    801416 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801411:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801416:	83 c4 24             	add    $0x24,%esp
  801419:	5b                   	pop    %ebx
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	53                   	push   %ebx
  801420:	83 ec 24             	sub    $0x24,%esp
  801423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801426:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	e8 32 fb ff ff       	call   800f6a <fd_lookup>
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 52                	js     80148e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801446:	8b 00                	mov    (%eax),%eax
  801448:	89 04 24             	mov    %eax,(%esp)
  80144b:	e8 70 fb ff ff       	call   800fc0 <dev_lookup>
  801450:	85 c0                	test   %eax,%eax
  801452:	78 3a                	js     80148e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801457:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80145b:	74 2c                	je     801489 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80145d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801460:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801467:	00 00 00 
	stat->st_isdir = 0;
  80146a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801471:	00 00 00 
	stat->st_dev = dev;
  801474:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80147a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80147e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801481:	89 14 24             	mov    %edx,(%esp)
  801484:	ff 50 14             	call   *0x14(%eax)
  801487:	eb 05                	jmp    80148e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801489:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80148e:	83 c4 24             	add    $0x24,%esp
  801491:	5b                   	pop    %ebx
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    

00801494 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80149c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014a3:	00 
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	89 04 24             	mov    %eax,(%esp)
  8014aa:	e8 fe 01 00 00       	call   8016ad <open>
  8014af:	89 c3                	mov    %eax,%ebx
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 1b                	js     8014d0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bc:	89 1c 24             	mov    %ebx,(%esp)
  8014bf:	e8 58 ff ff ff       	call   80141c <fstat>
  8014c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c6:	89 1c 24             	mov    %ebx,(%esp)
  8014c9:	e8 d4 fb ff ff       	call   8010a2 <close>
	return r;
  8014ce:	89 f3                	mov    %esi,%ebx
}
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    
  8014d9:	00 00                	add    %al,(%eax)
	...

008014dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 10             	sub    $0x10,%esp
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014ef:	75 11                	jne    801502 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014f8:	e8 04 0e 00 00       	call   802301 <ipc_find_env>
  8014fd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801502:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801509:	00 
  80150a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801511:	00 
  801512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801516:	a1 00 40 80 00       	mov    0x804000,%eax
  80151b:	89 04 24             	mov    %eax,(%esp)
  80151e:	e8 74 0d 00 00       	call   802297 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801523:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152a:	00 
  80152b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80152f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801536:	e8 f5 0c 00 00       	call   802230 <ipc_recv>
}
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    

00801542 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801548:	8b 45 08             	mov    0x8(%ebp),%eax
  80154b:	8b 40 0c             	mov    0xc(%eax),%eax
  80154e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801553:	8b 45 0c             	mov    0xc(%ebp),%eax
  801556:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80155b:	ba 00 00 00 00       	mov    $0x0,%edx
  801560:	b8 02 00 00 00       	mov    $0x2,%eax
  801565:	e8 72 ff ff ff       	call   8014dc <fsipc>
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	8b 40 0c             	mov    0xc(%eax),%eax
  801578:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	b8 06 00 00 00       	mov    $0x6,%eax
  801587:	e8 50 ff ff ff       	call   8014dc <fsipc>
}
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 14             	sub    $0x14,%esp
  801595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	8b 40 0c             	mov    0xc(%eax),%eax
  80159e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ad:	e8 2a ff ff ff       	call   8014dc <fsipc>
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 2b                	js     8015e1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015b6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015bd:	00 
  8015be:	89 1c 24             	mov    %ebx,(%esp)
  8015c1:	e8 c9 f2 ff ff       	call   80088f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015c6:	a1 80 50 80 00       	mov    0x805080,%eax
  8015cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015d1:	a1 84 50 80 00       	mov    0x805084,%eax
  8015d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e1:	83 c4 14             	add    $0x14,%esp
  8015e4:	5b                   	pop    %ebx
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015ed:	c7 44 24 08 98 2a 80 	movl   $0x802a98,0x8(%esp)
  8015f4:	00 
  8015f5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8015fc:	00 
  8015fd:	c7 04 24 b6 2a 80 00 	movl   $0x802ab6,(%esp)
  801604:	e8 c3 eb ff ff       	call   8001cc <_panic>

00801609 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	56                   	push   %esi
  80160d:	53                   	push   %ebx
  80160e:	83 ec 10             	sub    $0x10,%esp
  801611:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	8b 40 0c             	mov    0xc(%eax),%eax
  80161a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80161f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801625:	ba 00 00 00 00       	mov    $0x0,%edx
  80162a:	b8 03 00 00 00       	mov    $0x3,%eax
  80162f:	e8 a8 fe ff ff       	call   8014dc <fsipc>
  801634:	89 c3                	mov    %eax,%ebx
  801636:	85 c0                	test   %eax,%eax
  801638:	78 6a                	js     8016a4 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80163a:	39 c6                	cmp    %eax,%esi
  80163c:	73 24                	jae    801662 <devfile_read+0x59>
  80163e:	c7 44 24 0c c1 2a 80 	movl   $0x802ac1,0xc(%esp)
  801645:	00 
  801646:	c7 44 24 08 c8 2a 80 	movl   $0x802ac8,0x8(%esp)
  80164d:	00 
  80164e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801655:	00 
  801656:	c7 04 24 b6 2a 80 00 	movl   $0x802ab6,(%esp)
  80165d:	e8 6a eb ff ff       	call   8001cc <_panic>
	assert(r <= PGSIZE);
  801662:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801667:	7e 24                	jle    80168d <devfile_read+0x84>
  801669:	c7 44 24 0c dd 2a 80 	movl   $0x802add,0xc(%esp)
  801670:	00 
  801671:	c7 44 24 08 c8 2a 80 	movl   $0x802ac8,0x8(%esp)
  801678:	00 
  801679:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801680:	00 
  801681:	c7 04 24 b6 2a 80 00 	movl   $0x802ab6,(%esp)
  801688:	e8 3f eb ff ff       	call   8001cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80168d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801691:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801698:	00 
  801699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 64 f3 ff ff       	call   800a08 <memmove>
	return r;
}
  8016a4:	89 d8                	mov    %ebx,%eax
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 20             	sub    $0x20,%esp
  8016b5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016b8:	89 34 24             	mov    %esi,(%esp)
  8016bb:	e8 9c f1 ff ff       	call   80085c <strlen>
  8016c0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016c5:	7f 60                	jg     801727 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ca:	89 04 24             	mov    %eax,(%esp)
  8016cd:	e8 45 f8 ff ff       	call   800f17 <fd_alloc>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 54                	js     80172c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016dc:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016e3:	e8 a7 f1 ff ff       	call   80088f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016eb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f8:	e8 df fd ff ff       	call   8014dc <fsipc>
  8016fd:	89 c3                	mov    %eax,%ebx
  8016ff:	85 c0                	test   %eax,%eax
  801701:	79 15                	jns    801718 <open+0x6b>
		fd_close(fd, 0);
  801703:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80170a:	00 
  80170b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 04 f9 ff ff       	call   80101a <fd_close>
		return r;
  801716:	eb 14                	jmp    80172c <open+0x7f>
	}

	return fd2num(fd);
  801718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	e8 c9 f7 ff ff       	call   800eec <fd2num>
  801723:	89 c3                	mov    %eax,%ebx
  801725:	eb 05                	jmp    80172c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801727:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80172c:	89 d8                	mov    %ebx,%eax
  80172e:	83 c4 20             	add    $0x20,%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80173b:	ba 00 00 00 00       	mov    $0x0,%edx
  801740:	b8 08 00 00 00       	mov    $0x8,%eax
  801745:	e8 92 fd ff ff       	call   8014dc <fsipc>
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801758:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80175f:	00 
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 42 ff ff ff       	call   8016ad <open>
  80176b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801771:	85 c0                	test   %eax,%eax
  801773:	0f 88 05 05 00 00    	js     801c7e <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801779:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801780:	00 
  801781:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 fd fa ff ff       	call   801296 <readn>
  801799:	3d 00 02 00 00       	cmp    $0x200,%eax
  80179e:	75 0c                	jne    8017ac <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8017a0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8017a7:	45 4c 46 
  8017aa:	74 3b                	je     8017e7 <spawn+0x9b>
		close(fd);
  8017ac:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	e8 e8 f8 ff ff       	call   8010a2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8017ba:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8017c1:	46 
  8017c2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	c7 04 24 e9 2a 80 00 	movl   $0x802ae9,(%esp)
  8017d3:	e8 ec ea ff ff       	call   8002c4 <cprintf>
		return -E_NOT_EXEC;
  8017d8:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  8017df:	ff ff ff 
  8017e2:	e9 a3 04 00 00       	jmp    801c8a <spawn+0x53e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8017e7:	ba 07 00 00 00       	mov    $0x7,%edx
  8017ec:	89 d0                	mov    %edx,%eax
  8017ee:	cd 30                	int    $0x30
  8017f0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8017f6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	0f 88 86 04 00 00    	js     801c8a <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801804:	25 ff 03 00 00       	and    $0x3ff,%eax
  801809:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801810:	c1 e0 07             	shl    $0x7,%eax
  801813:	29 d0                	sub    %edx,%eax
  801815:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  80181b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801821:	b9 11 00 00 00       	mov    $0x11,%ecx
  801826:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801828:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80182e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801834:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801839:	bb 00 00 00 00       	mov    $0x0,%ebx
  80183e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801841:	eb 0d                	jmp    801850 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 11 f0 ff ff       	call   80085c <strlen>
  80184b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80184f:	46                   	inc    %esi
  801850:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801852:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801859:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  80185c:	85 c0                	test   %eax,%eax
  80185e:	75 e3                	jne    801843 <spawn+0xf7>
  801860:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801866:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80186c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801871:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801873:	89 f8                	mov    %edi,%eax
  801875:	83 e0 fc             	and    $0xfffffffc,%eax
  801878:	f7 d2                	not    %edx
  80187a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80187d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801883:	89 d0                	mov    %edx,%eax
  801885:	83 e8 08             	sub    $0x8,%eax
  801888:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80188d:	0f 86 08 04 00 00    	jbe    801c9b <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801893:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80189a:	00 
  80189b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018a2:	00 
  8018a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018aa:	e8 d2 f3 ff ff       	call   800c81 <sys_page_alloc>
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	0f 88 e9 03 00 00    	js     801ca0 <spawn+0x554>
  8018b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018bc:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8018c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c5:	eb 2e                	jmp    8018f5 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8018c7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8018cd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8018d3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8018d6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8018d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dd:	89 3c 24             	mov    %edi,(%esp)
  8018e0:	e8 aa ef ff ff       	call   80088f <strcpy>
		string_store += strlen(argv[i]) + 1;
  8018e5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8018e8:	89 04 24             	mov    %eax,(%esp)
  8018eb:	e8 6c ef ff ff       	call   80085c <strlen>
  8018f0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8018f4:	43                   	inc    %ebx
  8018f5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8018fb:	7c ca                	jl     8018c7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8018fd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801903:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801909:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801910:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801916:	74 24                	je     80193c <spawn+0x1f0>
  801918:	c7 44 24 0c 60 2b 80 	movl   $0x802b60,0xc(%esp)
  80191f:	00 
  801920:	c7 44 24 08 c8 2a 80 	movl   $0x802ac8,0x8(%esp)
  801927:	00 
  801928:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80192f:	00 
  801930:	c7 04 24 03 2b 80 00 	movl   $0x802b03,(%esp)
  801937:	e8 90 e8 ff ff       	call   8001cc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80193c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801942:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801947:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80194d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801950:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801956:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801959:	89 d0                	mov    %edx,%eax
  80195b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801960:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801966:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80196d:	00 
  80196e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801975:	ee 
  801976:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80197c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801980:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801987:	00 
  801988:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198f:	e8 41 f3 ff ff       	call   800cd5 <sys_page_map>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	85 c0                	test   %eax,%eax
  801998:	78 1a                	js     8019b4 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80199a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019a1:	00 
  8019a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a9:	e8 7a f3 ff ff       	call   800d28 <sys_page_unmap>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	79 1f                	jns    8019d3 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8019b4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019bb:	00 
  8019bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c3:	e8 60 f3 ff ff       	call   800d28 <sys_page_unmap>
	return r;
  8019c8:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8019ce:	e9 b7 02 00 00       	jmp    801c8a <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8019d3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8019d9:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8019df:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019e5:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8019ec:	00 00 00 
  8019ef:	e9 bb 01 00 00       	jmp    801baf <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8019f4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019fa:	83 38 01             	cmpl   $0x1,(%eax)
  8019fd:	0f 85 9f 01 00 00    	jne    801ba2 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	8b 40 18             	mov    0x18(%eax),%eax
  801a08:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a0b:	83 f8 01             	cmp    $0x1,%eax
  801a0e:	19 c0                	sbb    %eax,%eax
  801a10:	83 e0 fe             	and    $0xfffffffe,%eax
  801a13:	83 c0 07             	add    $0x7,%eax
  801a16:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a1c:	8b 52 04             	mov    0x4(%edx),%edx
  801a1f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801a25:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a2b:	8b 40 10             	mov    0x10(%eax),%eax
  801a2e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a34:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801a3a:	8b 52 14             	mov    0x14(%edx),%edx
  801a3d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801a43:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a49:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801a4c:	89 f8                	mov    %edi,%eax
  801a4e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a53:	74 16                	je     801a6b <spawn+0x31f>
		va -= i;
  801a55:	29 c7                	sub    %eax,%edi
		memsz += i;
  801a57:	01 c2                	add    %eax,%edx
  801a59:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801a5f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801a65:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a70:	e9 1f 01 00 00       	jmp    801b94 <spawn+0x448>
		if (i >= filesz) {
  801a75:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801a7b:	77 2b                	ja     801aa8 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801a7d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801a83:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a8b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 e8 f1 ff ff       	call   800c81 <sys_page_alloc>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	0f 89 e7 00 00 00    	jns    801b88 <spawn+0x43c>
  801aa1:	89 c6                	mov    %eax,%esi
  801aa3:	e9 b2 01 00 00       	jmp    801c5a <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aa8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801aaf:	00 
  801ab0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ab7:	00 
  801ab8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abf:	e8 bd f1 ff ff       	call   800c81 <sys_page_alloc>
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	0f 88 84 01 00 00    	js     801c50 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801acc:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801ad2:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ade:	89 04 24             	mov    %eax,(%esp)
  801ae1:	e8 86 f8 ff ff       	call   80136c <seek>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 66 01 00 00    	js     801c54 <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801aee:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801af4:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801af6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801afb:	76 05                	jbe    801b02 <spawn+0x3b6>
  801afd:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b06:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b0d:	00 
  801b0e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b14:	89 04 24             	mov    %eax,(%esp)
  801b17:	e8 7a f7 ff ff       	call   801296 <readn>
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	0f 88 34 01 00 00    	js     801c58 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b24:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801b2a:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b2e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b32:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b3c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b43:	00 
  801b44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4b:	e8 85 f1 ff ff       	call   800cd5 <sys_page_map>
  801b50:	85 c0                	test   %eax,%eax
  801b52:	79 20                	jns    801b74 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801b54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b58:	c7 44 24 08 0f 2b 80 	movl   $0x802b0f,0x8(%esp)
  801b5f:	00 
  801b60:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801b67:	00 
  801b68:	c7 04 24 03 2b 80 00 	movl   $0x802b03,(%esp)
  801b6f:	e8 58 e6 ff ff       	call   8001cc <_panic>
			sys_page_unmap(0, UTEMP);
  801b74:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b7b:	00 
  801b7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b83:	e8 a0 f1 ff ff       	call   800d28 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b8e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801b94:	89 de                	mov    %ebx,%esi
  801b96:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801b9c:	0f 87 d3 fe ff ff    	ja     801a75 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ba2:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801ba8:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801baf:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801bb6:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801bbc:	0f 8c 32 fe ff ff    	jl     8019f4 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801bc2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bc8:	89 04 24             	mov    %eax,(%esp)
  801bcb:	e8 d2 f4 ff ff       	call   8010a2 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801bd0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801bd7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801bda:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be4:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 dc f1 ff ff       	call   800dce <sys_env_set_trapframe>
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	79 20                	jns    801c16 <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  801bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfa:	c7 44 24 08 2c 2b 80 	movl   $0x802b2c,0x8(%esp)
  801c01:	00 
  801c02:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 03 2b 80 00 	movl   $0x802b03,(%esp)
  801c11:	e8 b6 e5 ff ff       	call   8001cc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c16:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c1d:	00 
  801c1e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c24:	89 04 24             	mov    %eax,(%esp)
  801c27:	e8 4f f1 ff ff       	call   800d7b <sys_env_set_status>
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	79 5a                	jns    801c8a <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  801c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c34:	c7 44 24 08 46 2b 80 	movl   $0x802b46,0x8(%esp)
  801c3b:	00 
  801c3c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801c43:	00 
  801c44:	c7 04 24 03 2b 80 00 	movl   $0x802b03,(%esp)
  801c4b:	e8 7c e5 ff ff       	call   8001cc <_panic>
  801c50:	89 c6                	mov    %eax,%esi
  801c52:	eb 06                	jmp    801c5a <spawn+0x50e>
  801c54:	89 c6                	mov    %eax,%esi
  801c56:	eb 02                	jmp    801c5a <spawn+0x50e>
  801c58:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801c5a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c60:	89 04 24             	mov    %eax,(%esp)
  801c63:	e8 89 ef ff ff       	call   800bf1 <sys_env_destroy>
	close(fd);
  801c68:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 2c f4 ff ff       	call   8010a2 <close>
	return r;
  801c76:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801c7c:	eb 0c                	jmp    801c8a <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801c7e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c84:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801c8a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c90:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801c96:	5b                   	pop    %ebx
  801c97:	5e                   	pop    %esi
  801c98:	5f                   	pop    %edi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801c9b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801ca0:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801ca6:	eb e2                	jmp    801c8a <spawn+0x53e>

00801ca8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	57                   	push   %edi
  801cac:	56                   	push   %esi
  801cad:	53                   	push   %ebx
  801cae:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801cb1:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cb9:	eb 03                	jmp    801cbe <spawnl+0x16>
		argc++;
  801cbb:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cbc:	89 d0                	mov    %edx,%eax
  801cbe:	8d 50 04             	lea    0x4(%eax),%edx
  801cc1:	83 38 00             	cmpl   $0x0,(%eax)
  801cc4:	75 f5                	jne    801cbb <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801cc6:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801ccd:	83 e0 f0             	and    $0xfffffff0,%eax
  801cd0:	29 c4                	sub    %eax,%esp
  801cd2:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801cd6:	83 e7 f0             	and    $0xfffffff0,%edi
  801cd9:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cde:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801ce0:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801ce7:	00 

	va_start(vl, arg0);
  801ce8:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf0:	eb 09                	jmp    801cfb <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801cf2:	40                   	inc    %eax
  801cf3:	8b 1a                	mov    (%edx),%ebx
  801cf5:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801cf8:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801cfb:	39 c8                	cmp    %ecx,%eax
  801cfd:	75 f3                	jne    801cf2 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801cff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d03:	8b 45 08             	mov    0x8(%ebp),%eax
  801d06:	89 04 24             	mov    %eax,(%esp)
  801d09:	e8 3e fa ff ff       	call   80174c <spawn>
}
  801d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
	...

00801d18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 10             	sub    $0x10,%esp
  801d20:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 ce f1 ff ff       	call   800efc <fd2data>
  801d2e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d30:	c7 44 24 04 88 2b 80 	movl   $0x802b88,0x4(%esp)
  801d37:	00 
  801d38:	89 34 24             	mov    %esi,(%esp)
  801d3b:	e8 4f eb ff ff       	call   80088f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d40:	8b 43 04             	mov    0x4(%ebx),%eax
  801d43:	2b 03                	sub    (%ebx),%eax
  801d45:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d4b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d52:	00 00 00 
	stat->st_dev = &devpipe;
  801d55:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801d5c:	30 80 00 
	return 0;
}
  801d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 14             	sub    $0x14,%esp
  801d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d80:	e8 a3 ef ff ff       	call   800d28 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d85:	89 1c 24             	mov    %ebx,(%esp)
  801d88:	e8 6f f1 ff ff       	call   800efc <fd2data>
  801d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d98:	e8 8b ef ff ff       	call   800d28 <sys_page_unmap>
}
  801d9d:	83 c4 14             	add    $0x14,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 2c             	sub    $0x2c,%esp
  801dac:	89 c7                	mov    %eax,%edi
  801dae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801db1:	a1 04 40 80 00       	mov    0x804004,%eax
  801db6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801db9:	89 3c 24             	mov    %edi,(%esp)
  801dbc:	e8 87 05 00 00       	call   802348 <pageref>
  801dc1:	89 c6                	mov    %eax,%esi
  801dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 7a 05 00 00       	call   802348 <pageref>
  801dce:	39 c6                	cmp    %eax,%esi
  801dd0:	0f 94 c0             	sete   %al
  801dd3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dd6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ddc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ddf:	39 cb                	cmp    %ecx,%ebx
  801de1:	75 08                	jne    801deb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801de3:	83 c4 2c             	add    $0x2c,%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801deb:	83 f8 01             	cmp    $0x1,%eax
  801dee:	75 c1                	jne    801db1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801df0:	8b 42 58             	mov    0x58(%edx),%eax
  801df3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801dfa:	00 
  801dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e03:	c7 04 24 8f 2b 80 00 	movl   $0x802b8f,(%esp)
  801e0a:	e8 b5 e4 ff ff       	call   8002c4 <cprintf>
  801e0f:	eb a0                	jmp    801db1 <_pipeisclosed+0xe>

00801e11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	57                   	push   %edi
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	83 ec 1c             	sub    $0x1c,%esp
  801e1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e1d:	89 34 24             	mov    %esi,(%esp)
  801e20:	e8 d7 f0 ff ff       	call   800efc <fd2data>
  801e25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e27:	bf 00 00 00 00       	mov    $0x0,%edi
  801e2c:	eb 3c                	jmp    801e6a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e2e:	89 da                	mov    %ebx,%edx
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	e8 6c ff ff ff       	call   801da3 <_pipeisclosed>
  801e37:	85 c0                	test   %eax,%eax
  801e39:	75 38                	jne    801e73 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e3b:	e8 22 ee ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e40:	8b 43 04             	mov    0x4(%ebx),%eax
  801e43:	8b 13                	mov    (%ebx),%edx
  801e45:	83 c2 20             	add    $0x20,%edx
  801e48:	39 d0                	cmp    %edx,%eax
  801e4a:	73 e2                	jae    801e2e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e52:	89 c2                	mov    %eax,%edx
  801e54:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e5a:	79 05                	jns    801e61 <devpipe_write+0x50>
  801e5c:	4a                   	dec    %edx
  801e5d:	83 ca e0             	or     $0xffffffe0,%edx
  801e60:	42                   	inc    %edx
  801e61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e65:	40                   	inc    %eax
  801e66:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e69:	47                   	inc    %edi
  801e6a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6d:	75 d1                	jne    801e40 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e6f:	89 f8                	mov    %edi,%eax
  801e71:	eb 05                	jmp    801e78 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e78:	83 c4 1c             	add    $0x1c,%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5f                   	pop    %edi
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 1c             	sub    $0x1c,%esp
  801e89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e8c:	89 3c 24             	mov    %edi,(%esp)
  801e8f:	e8 68 f0 ff ff       	call   800efc <fd2data>
  801e94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e96:	be 00 00 00 00       	mov    $0x0,%esi
  801e9b:	eb 3a                	jmp    801ed7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e9d:	85 f6                	test   %esi,%esi
  801e9f:	74 04                	je     801ea5 <devpipe_read+0x25>
				return i;
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	eb 40                	jmp    801ee5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ea5:	89 da                	mov    %ebx,%edx
  801ea7:	89 f8                	mov    %edi,%eax
  801ea9:	e8 f5 fe ff ff       	call   801da3 <_pipeisclosed>
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	75 2e                	jne    801ee0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eb2:	e8 ab ed ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eb7:	8b 03                	mov    (%ebx),%eax
  801eb9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ebc:	74 df                	je     801e9d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ebe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ec3:	79 05                	jns    801eca <devpipe_read+0x4a>
  801ec5:	48                   	dec    %eax
  801ec6:	83 c8 e0             	or     $0xffffffe0,%eax
  801ec9:	40                   	inc    %eax
  801eca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ed4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed6:	46                   	inc    %esi
  801ed7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eda:	75 db                	jne    801eb7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801edc:	89 f0                	mov    %esi,%eax
  801ede:	eb 05                	jmp    801ee5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	57                   	push   %edi
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 3c             	sub    $0x3c,%esp
  801ef6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ef9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 13 f0 ff ff       	call   800f17 <fd_alloc>
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	85 c0                	test   %eax,%eax
  801f08:	0f 88 45 01 00 00    	js     802053 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f15:	00 
  801f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f24:	e8 58 ed ff ff       	call   800c81 <sys_page_alloc>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	0f 88 20 01 00 00    	js     802053 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f33:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f36:	89 04 24             	mov    %eax,(%esp)
  801f39:	e8 d9 ef ff ff       	call   800f17 <fd_alloc>
  801f3e:	89 c3                	mov    %eax,%ebx
  801f40:	85 c0                	test   %eax,%eax
  801f42:	0f 88 f8 00 00 00    	js     802040 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f48:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f4f:	00 
  801f50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f5e:	e8 1e ed ff ff       	call   800c81 <sys_page_alloc>
  801f63:	89 c3                	mov    %eax,%ebx
  801f65:	85 c0                	test   %eax,%eax
  801f67:	0f 88 d3 00 00 00    	js     802040 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	e8 84 ef ff ff       	call   800efc <fd2data>
  801f78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f7a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f81:	00 
  801f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8d:	e8 ef ec ff ff       	call   800c81 <sys_page_alloc>
  801f92:	89 c3                	mov    %eax,%ebx
  801f94:	85 c0                	test   %eax,%eax
  801f96:	0f 88 91 00 00 00    	js     80202d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 55 ef ff ff       	call   800efc <fd2data>
  801fa7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801fae:	00 
  801faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fba:	00 
  801fbb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc6:	e8 0a ed ff ff       	call   800cd5 <sys_page_map>
  801fcb:	89 c3                	mov    %eax,%ebx
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	78 4c                	js     80201d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fd1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fdf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fe6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ff1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ff4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ffe:	89 04 24             	mov    %eax,(%esp)
  802001:	e8 e6 ee ff ff       	call   800eec <fd2num>
  802006:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802008:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 d9 ee ff ff       	call   800eec <fd2num>
  802013:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802016:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201b:	eb 36                	jmp    802053 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80201d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802028:	e8 fb ec ff ff       	call   800d28 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80202d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802030:	89 44 24 04          	mov    %eax,0x4(%esp)
  802034:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203b:	e8 e8 ec ff ff       	call   800d28 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802040:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802043:	89 44 24 04          	mov    %eax,0x4(%esp)
  802047:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204e:	e8 d5 ec ff ff       	call   800d28 <sys_page_unmap>
    err:
	return r;
}
  802053:	89 d8                	mov    %ebx,%eax
  802055:	83 c4 3c             	add    $0x3c,%esp
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5f                   	pop    %edi
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    

0080205d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
  80206d:	89 04 24             	mov    %eax,(%esp)
  802070:	e8 f5 ee ff ff       	call   800f6a <fd_lookup>
  802075:	85 c0                	test   %eax,%eax
  802077:	78 15                	js     80208e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	e8 78 ee ff ff       	call   800efc <fd2data>
	return _pipeisclosed(fd, p);
  802084:	89 c2                	mov    %eax,%edx
  802086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802089:	e8 15 fd ff ff       	call   801da3 <_pipeisclosed>
}
  80208e:	c9                   	leave  
  80208f:	c3                   	ret    

00802090 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    

0080209a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8020a0:	c7 44 24 04 a7 2b 80 	movl   $0x802ba7,0x4(%esp)
  8020a7:	00 
  8020a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ab:	89 04 24             	mov    %eax,(%esp)
  8020ae:	e8 dc e7 ff ff       	call   80088f <strcpy>
	return 0;
}
  8020b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	57                   	push   %edi
  8020be:	56                   	push   %esi
  8020bf:	53                   	push   %ebx
  8020c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d1:	eb 30                	jmp    802103 <devcons_write+0x49>
		m = n - tot;
  8020d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8020d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020d8:	83 fe 7f             	cmp    $0x7f,%esi
  8020db:	76 05                	jbe    8020e2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8020dd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020e6:	03 45 0c             	add    0xc(%ebp),%eax
  8020e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ed:	89 3c 24             	mov    %edi,(%esp)
  8020f0:	e8 13 e9 ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  8020f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f9:	89 3c 24             	mov    %edi,(%esp)
  8020fc:	e8 b3 ea ff ff       	call   800bb4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802101:	01 f3                	add    %esi,%ebx
  802103:	89 d8                	mov    %ebx,%eax
  802105:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802108:	72 c9                	jb     8020d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80210a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80211b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80211f:	75 07                	jne    802128 <devcons_read+0x13>
  802121:	eb 25                	jmp    802148 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802123:	e8 3a eb ff ff       	call   800c62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802128:	e8 a5 ea ff ff       	call   800bd2 <sys_cgetc>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	74 f2                	je     802123 <devcons_read+0xe>
  802131:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802133:	85 c0                	test   %eax,%eax
  802135:	78 1d                	js     802154 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802137:	83 f8 04             	cmp    $0x4,%eax
  80213a:	74 13                	je     80214f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80213c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213f:	88 10                	mov    %dl,(%eax)
	return 1;
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	eb 0c                	jmp    802154 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
  80214d:	eb 05                	jmp    802154 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80214f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802162:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802169:	00 
  80216a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216d:	89 04 24             	mov    %eax,(%esp)
  802170:	e8 3f ea ff ff       	call   800bb4 <sys_cputs>
}
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <getchar>:

int
getchar(void)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80217d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802184:	00 
  802185:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802193:	e8 6e f0 ff ff       	call   801206 <read>
	if (r < 0)
  802198:	85 c0                	test   %eax,%eax
  80219a:	78 0f                	js     8021ab <getchar+0x34>
		return r;
	if (r < 1)
  80219c:	85 c0                	test   %eax,%eax
  80219e:	7e 06                	jle    8021a6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8021a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021a4:	eb 05                	jmp    8021ab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021ab:	c9                   	leave  
  8021ac:	c3                   	ret    

008021ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bd:	89 04 24             	mov    %eax,(%esp)
  8021c0:	e8 a5 ed ff ff       	call   800f6a <fd_lookup>
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	78 11                	js     8021da <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021d2:	39 10                	cmp    %edx,(%eax)
  8021d4:	0f 94 c0             	sete   %al
  8021d7:	0f b6 c0             	movzbl %al,%eax
}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <opencons>:

int
opencons(void)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 2a ed ff ff       	call   800f17 <fd_alloc>
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	78 3c                	js     80222d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021f1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021f8:	00 
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802200:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802207:	e8 75 ea ff ff       	call   800c81 <sys_page_alloc>
  80220c:	85 c0                	test   %eax,%eax
  80220e:	78 1d                	js     80222d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802210:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802216:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802219:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80221b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802225:	89 04 24             	mov    %eax,(%esp)
  802228:	e8 bf ec ff ff       	call   800eec <fd2num>
}
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    
	...

00802230 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 10             	sub    $0x10,%esp
  802238:	8b 75 08             	mov    0x8(%ebp),%esi
  80223b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802241:	85 c0                	test   %eax,%eax
  802243:	75 05                	jne    80224a <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  802245:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80224a:	89 04 24             	mov    %eax,(%esp)
  80224d:	e8 45 ec ff ff       	call   800e97 <sys_ipc_recv>
	if (!err) {
  802252:	85 c0                	test   %eax,%eax
  802254:	75 26                	jne    80227c <ipc_recv+0x4c>
		if (from_env_store) {
  802256:	85 f6                	test   %esi,%esi
  802258:	74 0a                	je     802264 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  80225a:	a1 04 40 80 00       	mov    0x804004,%eax
  80225f:	8b 40 74             	mov    0x74(%eax),%eax
  802262:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802264:	85 db                	test   %ebx,%ebx
  802266:	74 0a                	je     802272 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802268:	a1 04 40 80 00       	mov    0x804004,%eax
  80226d:	8b 40 78             	mov    0x78(%eax),%eax
  802270:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  802272:	a1 04 40 80 00       	mov    0x804004,%eax
  802277:	8b 40 70             	mov    0x70(%eax),%eax
  80227a:	eb 14                	jmp    802290 <ipc_recv+0x60>
	}
	if (from_env_store) {
  80227c:	85 f6                	test   %esi,%esi
  80227e:	74 06                	je     802286 <ipc_recv+0x56>
		*from_env_store = 0;
  802280:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  802286:	85 db                	test   %ebx,%ebx
  802288:	74 06                	je     802290 <ipc_recv+0x60>
		*perm_store = 0;
  80228a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	5b                   	pop    %ebx
  802294:	5e                   	pop    %esi
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    

00802297 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	57                   	push   %edi
  80229b:	56                   	push   %esi
  80229c:	53                   	push   %ebx
  80229d:	83 ec 1c             	sub    $0x1c,%esp
  8022a0:	8b 75 10             	mov    0x10(%ebp),%esi
  8022a3:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8022a6:	85 f6                	test   %esi,%esi
  8022a8:	75 05                	jne    8022af <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8022aa:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8022af:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022be:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c1:	89 04 24             	mov    %eax,(%esp)
  8022c4:	e8 ab eb ff ff       	call   800e74 <sys_ipc_try_send>
  8022c9:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8022cb:	e8 92 e9 ff ff       	call   800c62 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8022d0:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8022d3:	74 da                	je     8022af <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8022d5:	85 db                	test   %ebx,%ebx
  8022d7:	74 20                	je     8022f9 <ipc_send+0x62>
		panic("send fail: %e", err);
  8022d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022dd:	c7 44 24 08 b3 2b 80 	movl   $0x802bb3,0x8(%esp)
  8022e4:	00 
  8022e5:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8022ec:	00 
  8022ed:	c7 04 24 c1 2b 80 00 	movl   $0x802bc1,(%esp)
  8022f4:	e8 d3 de ff ff       	call   8001cc <_panic>
	}
	return;
}
  8022f9:	83 c4 1c             	add    $0x1c,%esp
  8022fc:	5b                   	pop    %ebx
  8022fd:	5e                   	pop    %esi
  8022fe:	5f                   	pop    %edi
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    

00802301 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	53                   	push   %ebx
  802305:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802308:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80230d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802314:	89 c2                	mov    %eax,%edx
  802316:	c1 e2 07             	shl    $0x7,%edx
  802319:	29 ca                	sub    %ecx,%edx
  80231b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802321:	8b 52 50             	mov    0x50(%edx),%edx
  802324:	39 da                	cmp    %ebx,%edx
  802326:	75 0f                	jne    802337 <ipc_find_env+0x36>
			return envs[i].env_id;
  802328:	c1 e0 07             	shl    $0x7,%eax
  80232b:	29 c8                	sub    %ecx,%eax
  80232d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802332:	8b 40 40             	mov    0x40(%eax),%eax
  802335:	eb 0c                	jmp    802343 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802337:	40                   	inc    %eax
  802338:	3d 00 04 00 00       	cmp    $0x400,%eax
  80233d:	75 ce                	jne    80230d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80233f:	66 b8 00 00          	mov    $0x0,%ax
}
  802343:	5b                   	pop    %ebx
  802344:	5d                   	pop    %ebp
  802345:	c3                   	ret    
	...

00802348 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80234e:	89 c2                	mov    %eax,%edx
  802350:	c1 ea 16             	shr    $0x16,%edx
  802353:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80235a:	f6 c2 01             	test   $0x1,%dl
  80235d:	74 1e                	je     80237d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80235f:	c1 e8 0c             	shr    $0xc,%eax
  802362:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802369:	a8 01                	test   $0x1,%al
  80236b:	74 17                	je     802384 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80236d:	c1 e8 0c             	shr    $0xc,%eax
  802370:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802377:	ef 
  802378:	0f b7 c0             	movzwl %ax,%eax
  80237b:	eb 0c                	jmp    802389 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80237d:	b8 00 00 00 00       	mov    $0x0,%eax
  802382:	eb 05                	jmp    802389 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802384:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    
	...

0080238c <__udivdi3>:
  80238c:	55                   	push   %ebp
  80238d:	57                   	push   %edi
  80238e:	56                   	push   %esi
  80238f:	83 ec 10             	sub    $0x10,%esp
  802392:	8b 74 24 20          	mov    0x20(%esp),%esi
  802396:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80239a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80239e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8023a2:	89 cd                	mov    %ecx,%ebp
  8023a4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8023a8:	85 c0                	test   %eax,%eax
  8023aa:	75 2c                	jne    8023d8 <__udivdi3+0x4c>
  8023ac:	39 f9                	cmp    %edi,%ecx
  8023ae:	77 68                	ja     802418 <__udivdi3+0x8c>
  8023b0:	85 c9                	test   %ecx,%ecx
  8023b2:	75 0b                	jne    8023bf <__udivdi3+0x33>
  8023b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b9:	31 d2                	xor    %edx,%edx
  8023bb:	f7 f1                	div    %ecx
  8023bd:	89 c1                	mov    %eax,%ecx
  8023bf:	31 d2                	xor    %edx,%edx
  8023c1:	89 f8                	mov    %edi,%eax
  8023c3:	f7 f1                	div    %ecx
  8023c5:	89 c7                	mov    %eax,%edi
  8023c7:	89 f0                	mov    %esi,%eax
  8023c9:	f7 f1                	div    %ecx
  8023cb:	89 c6                	mov    %eax,%esi
  8023cd:	89 f0                	mov    %esi,%eax
  8023cf:	89 fa                	mov    %edi,%edx
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	39 f8                	cmp    %edi,%eax
  8023da:	77 2c                	ja     802408 <__udivdi3+0x7c>
  8023dc:	0f bd f0             	bsr    %eax,%esi
  8023df:	83 f6 1f             	xor    $0x1f,%esi
  8023e2:	75 4c                	jne    802430 <__udivdi3+0xa4>
  8023e4:	39 f8                	cmp    %edi,%eax
  8023e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8023eb:	72 0a                	jb     8023f7 <__udivdi3+0x6b>
  8023ed:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023f1:	0f 87 ad 00 00 00    	ja     8024a4 <__udivdi3+0x118>
  8023f7:	be 01 00 00 00       	mov    $0x1,%esi
  8023fc:	89 f0                	mov    %esi,%eax
  8023fe:	89 fa                	mov    %edi,%edx
  802400:	83 c4 10             	add    $0x10,%esp
  802403:	5e                   	pop    %esi
  802404:	5f                   	pop    %edi
  802405:	5d                   	pop    %ebp
  802406:	c3                   	ret    
  802407:	90                   	nop
  802408:	31 ff                	xor    %edi,%edi
  80240a:	31 f6                	xor    %esi,%esi
  80240c:	89 f0                	mov    %esi,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	5e                   	pop    %esi
  802414:	5f                   	pop    %edi
  802415:	5d                   	pop    %ebp
  802416:	c3                   	ret    
  802417:	90                   	nop
  802418:	89 fa                	mov    %edi,%edx
  80241a:	89 f0                	mov    %esi,%eax
  80241c:	f7 f1                	div    %ecx
  80241e:	89 c6                	mov    %eax,%esi
  802420:	31 ff                	xor    %edi,%edi
  802422:	89 f0                	mov    %esi,%eax
  802424:	89 fa                	mov    %edi,%edx
  802426:	83 c4 10             	add    $0x10,%esp
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	89 f1                	mov    %esi,%ecx
  802432:	d3 e0                	shl    %cl,%eax
  802434:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802438:	b8 20 00 00 00       	mov    $0x20,%eax
  80243d:	29 f0                	sub    %esi,%eax
  80243f:	89 ea                	mov    %ebp,%edx
  802441:	88 c1                	mov    %al,%cl
  802443:	d3 ea                	shr    %cl,%edx
  802445:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802449:	09 ca                	or     %ecx,%edx
  80244b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80244f:	89 f1                	mov    %esi,%ecx
  802451:	d3 e5                	shl    %cl,%ebp
  802453:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802457:	89 fd                	mov    %edi,%ebp
  802459:	88 c1                	mov    %al,%cl
  80245b:	d3 ed                	shr    %cl,%ebp
  80245d:	89 fa                	mov    %edi,%edx
  80245f:	89 f1                	mov    %esi,%ecx
  802461:	d3 e2                	shl    %cl,%edx
  802463:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802467:	88 c1                	mov    %al,%cl
  802469:	d3 ef                	shr    %cl,%edi
  80246b:	09 d7                	or     %edx,%edi
  80246d:	89 f8                	mov    %edi,%eax
  80246f:	89 ea                	mov    %ebp,%edx
  802471:	f7 74 24 08          	divl   0x8(%esp)
  802475:	89 d1                	mov    %edx,%ecx
  802477:	89 c7                	mov    %eax,%edi
  802479:	f7 64 24 0c          	mull   0xc(%esp)
  80247d:	39 d1                	cmp    %edx,%ecx
  80247f:	72 17                	jb     802498 <__udivdi3+0x10c>
  802481:	74 09                	je     80248c <__udivdi3+0x100>
  802483:	89 fe                	mov    %edi,%esi
  802485:	31 ff                	xor    %edi,%edi
  802487:	e9 41 ff ff ff       	jmp    8023cd <__udivdi3+0x41>
  80248c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802490:	89 f1                	mov    %esi,%ecx
  802492:	d3 e2                	shl    %cl,%edx
  802494:	39 c2                	cmp    %eax,%edx
  802496:	73 eb                	jae    802483 <__udivdi3+0xf7>
  802498:	8d 77 ff             	lea    -0x1(%edi),%esi
  80249b:	31 ff                	xor    %edi,%edi
  80249d:	e9 2b ff ff ff       	jmp    8023cd <__udivdi3+0x41>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	31 f6                	xor    %esi,%esi
  8024a6:	e9 22 ff ff ff       	jmp    8023cd <__udivdi3+0x41>
	...

008024ac <__umoddi3>:
  8024ac:	55                   	push   %ebp
  8024ad:	57                   	push   %edi
  8024ae:	56                   	push   %esi
  8024af:	83 ec 20             	sub    $0x20,%esp
  8024b2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024b6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8024ba:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024be:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024c6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8024ca:	89 c7                	mov    %eax,%edi
  8024cc:	89 f2                	mov    %esi,%edx
  8024ce:	85 ed                	test   %ebp,%ebp
  8024d0:	75 16                	jne    8024e8 <__umoddi3+0x3c>
  8024d2:	39 f1                	cmp    %esi,%ecx
  8024d4:	0f 86 a6 00 00 00    	jbe    802580 <__umoddi3+0xd4>
  8024da:	f7 f1                	div    %ecx
  8024dc:	89 d0                	mov    %edx,%eax
  8024de:	31 d2                	xor    %edx,%edx
  8024e0:	83 c4 20             	add    $0x20,%esp
  8024e3:	5e                   	pop    %esi
  8024e4:	5f                   	pop    %edi
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    
  8024e7:	90                   	nop
  8024e8:	39 f5                	cmp    %esi,%ebp
  8024ea:	0f 87 ac 00 00 00    	ja     80259c <__umoddi3+0xf0>
  8024f0:	0f bd c5             	bsr    %ebp,%eax
  8024f3:	83 f0 1f             	xor    $0x1f,%eax
  8024f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024fa:	0f 84 a8 00 00 00    	je     8025a8 <__umoddi3+0xfc>
  802500:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802504:	d3 e5                	shl    %cl,%ebp
  802506:	bf 20 00 00 00       	mov    $0x20,%edi
  80250b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80250f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802513:	89 f9                	mov    %edi,%ecx
  802515:	d3 e8                	shr    %cl,%eax
  802517:	09 e8                	or     %ebp,%eax
  802519:	89 44 24 18          	mov    %eax,0x18(%esp)
  80251d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802521:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802525:	d3 e0                	shl    %cl,%eax
  802527:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80252b:	89 f2                	mov    %esi,%edx
  80252d:	d3 e2                	shl    %cl,%edx
  80252f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802533:	d3 e0                	shl    %cl,%eax
  802535:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802539:	8b 44 24 14          	mov    0x14(%esp),%eax
  80253d:	89 f9                	mov    %edi,%ecx
  80253f:	d3 e8                	shr    %cl,%eax
  802541:	09 d0                	or     %edx,%eax
  802543:	d3 ee                	shr    %cl,%esi
  802545:	89 f2                	mov    %esi,%edx
  802547:	f7 74 24 18          	divl   0x18(%esp)
  80254b:	89 d6                	mov    %edx,%esi
  80254d:	f7 64 24 0c          	mull   0xc(%esp)
  802551:	89 c5                	mov    %eax,%ebp
  802553:	89 d1                	mov    %edx,%ecx
  802555:	39 d6                	cmp    %edx,%esi
  802557:	72 67                	jb     8025c0 <__umoddi3+0x114>
  802559:	74 75                	je     8025d0 <__umoddi3+0x124>
  80255b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80255f:	29 e8                	sub    %ebp,%eax
  802561:	19 ce                	sbb    %ecx,%esi
  802563:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802567:	d3 e8                	shr    %cl,%eax
  802569:	89 f2                	mov    %esi,%edx
  80256b:	89 f9                	mov    %edi,%ecx
  80256d:	d3 e2                	shl    %cl,%edx
  80256f:	09 d0                	or     %edx,%eax
  802571:	89 f2                	mov    %esi,%edx
  802573:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802577:	d3 ea                	shr    %cl,%edx
  802579:	83 c4 20             	add    $0x20,%esp
  80257c:	5e                   	pop    %esi
  80257d:	5f                   	pop    %edi
  80257e:	5d                   	pop    %ebp
  80257f:	c3                   	ret    
  802580:	85 c9                	test   %ecx,%ecx
  802582:	75 0b                	jne    80258f <__umoddi3+0xe3>
  802584:	b8 01 00 00 00       	mov    $0x1,%eax
  802589:	31 d2                	xor    %edx,%edx
  80258b:	f7 f1                	div    %ecx
  80258d:	89 c1                	mov    %eax,%ecx
  80258f:	89 f0                	mov    %esi,%eax
  802591:	31 d2                	xor    %edx,%edx
  802593:	f7 f1                	div    %ecx
  802595:	89 f8                	mov    %edi,%eax
  802597:	e9 3e ff ff ff       	jmp    8024da <__umoddi3+0x2e>
  80259c:	89 f2                	mov    %esi,%edx
  80259e:	83 c4 20             	add    $0x20,%esp
  8025a1:	5e                   	pop    %esi
  8025a2:	5f                   	pop    %edi
  8025a3:	5d                   	pop    %ebp
  8025a4:	c3                   	ret    
  8025a5:	8d 76 00             	lea    0x0(%esi),%esi
  8025a8:	39 f5                	cmp    %esi,%ebp
  8025aa:	72 04                	jb     8025b0 <__umoddi3+0x104>
  8025ac:	39 f9                	cmp    %edi,%ecx
  8025ae:	77 06                	ja     8025b6 <__umoddi3+0x10a>
  8025b0:	89 f2                	mov    %esi,%edx
  8025b2:	29 cf                	sub    %ecx,%edi
  8025b4:	19 ea                	sbb    %ebp,%edx
  8025b6:	89 f8                	mov    %edi,%eax
  8025b8:	83 c4 20             	add    $0x20,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	89 d1                	mov    %edx,%ecx
  8025c2:	89 c5                	mov    %eax,%ebp
  8025c4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025c8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025cc:	eb 8d                	jmp    80255b <__umoddi3+0xaf>
  8025ce:	66 90                	xchg   %ax,%ax
  8025d0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025d4:	72 ea                	jb     8025c0 <__umoddi3+0x114>
  8025d6:	89 f1                	mov    %esi,%ecx
  8025d8:	eb 81                	jmp    80255b <__umoddi3+0xaf>
