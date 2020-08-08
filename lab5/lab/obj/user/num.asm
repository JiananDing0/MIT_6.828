
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 8f 01 00 00       	call   8001c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	eb 7f                	jmp    8000c7 <num+0x93>
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 25                	je     800076 <num+0x42>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  800067:	e8 59 18 00 00       	call   8018c5 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 b7 12 00 00       	call   801345 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 24                	je     8000b7 <num+0x83>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80009b:	c7 44 24 08 c5 21 80 	movl   $0x8021c5,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  8000b2:	e8 79 01 00 00       	call   800230 <_panic>
		if (c == '\n')
  8000b7:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000bb:	75 0a                	jne    8000c7 <num+0x93>
			bol = 1;
  8000bd:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c4:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000ce:	00 
  8000cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d3:	89 34 24             	mov    %esi,(%esp)
  8000d6:	e8 8f 11 00 00       	call   80126a <read>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	0f 8f 65 ff ff ff    	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 24                	jns    80010b <num+0xd7>
		panic("error reading %s: %e", s, n);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ef:	c7 44 24 08 eb 21 80 	movl   $0x8021eb,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  800106:	e8 25 01 00 00       	call   800230 <_panic>
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <umain>:

void
umain(int argc, char **argv)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 3c             	sub    $0x3c,%esp
	int f, i;

	binaryname = "num";
  80011c:	c7 05 04 30 80 00 00 	movl   $0x802200,0x803004
  800123:	22 80 00 
	if (argc == 1)
  800126:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012a:	74 0d                	je     800139 <umain+0x26>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80012f:	83 c3 04             	add    $0x4,%ebx
  800132:	bf 01 00 00 00       	mov    $0x1,%edi
  800137:	eb 74                	jmp    8001ad <umain+0x9a>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800139:	c7 44 24 04 04 22 80 	movl   $0x802204,0x4(%esp)
  800140:	00 
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <num>
  80014d:	eb 63                	jmp    8001b2 <umain+0x9f>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80014f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800159:	00 
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 ad 15 00 00       	call   801711 <open>
  800164:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	79 29                	jns    800193 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800171:	8b 02                	mov    (%edx),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	c7 44 24 08 0c 22 80 	movl   $0x80220c,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  80018e:	e8 9d 00 00 00       	call   800230 <_panic>
			else {
				num(f, argv[i]);
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <num>
				close(f);
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 5d 0f 00 00       	call   801106 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001a9:	47                   	inc    %edi
  8001aa:	83 c3 04             	add    $0x4,%ebx
  8001ad:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b0:	7c 9d                	jl     80014f <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b2:	e8 5d 00 00 00       	call   800214 <exit>
}
  8001b7:	83 c4 3c             	add    $0x3c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
	...

008001c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 10             	sub    $0x10,%esp
  8001c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001ce:	e8 d4 0a 00 00       	call   800ca7 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001df:	c1 e0 07             	shl    $0x7,%eax
  8001e2:	29 d0                	sub    %edx,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 f6                	test   %esi,%esi
  8001f0:	7e 07                	jle    8001f9 <libmain+0x39>
		binaryname = argv[0];
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	e8 0e ff ff ff       	call   800113 <umain>

	// exit gracefully
	exit();
  800205:	e8 0a 00 00 00       	call   800214 <exit>
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80021a:	e8 18 0f 00 00       	call   801137 <close_all>
	sys_env_destroy(0);
  80021f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800226:	e8 2a 0a 00 00       	call   800c55 <sys_env_destroy>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800241:	e8 61 0a 00 00       	call   800ca7 <sys_getenvid>
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 28 22 80 00 	movl   $0x802228,(%esp)
  800263:	e8 c0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 50 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800277:	c7 04 24 65 26 80 00 	movl   $0x802665,(%esp)
  80027e:	e8 a5 00 00 00       	call   800328 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x53>
	...

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	53                   	push   %ebx
  80028c:	83 ec 14             	sub    $0x14,%esp
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800292:	8b 03                	mov    (%ebx),%eax
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029b:	40                   	inc    %eax
  80029c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 19                	jne    8002be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ac:	00 
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 60 09 00 00       	call   800c18 <sys_cputs>
		b->idx = 0;
  8002b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002be:	ff 43 04             	incl   0x4(%ebx)
}
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800303:	e8 82 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 f8 08 00 00       	call   800c18 <sys_cputs>

	return b.cnt;
}
  800320:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 87 ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    
	...

00800344 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	89 d7                	mov    %edx,%edi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800361:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800364:	85 c0                	test   %eax,%eax
  800366:	75 08                	jne    800370 <printnum+0x2c>
  800368:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036e:	77 57                	ja     8003c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	89 74 24 10          	mov    %esi,0x10(%esp)
  800374:	4b                   	dec    %ebx
  800375:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800384:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 ba 1b 00 00       	call   801f5c <__udivdi3>
  8003a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b1:	89 fa                	mov    %edi,%edx
  8003b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b6:	e8 89 ff ff ff       	call   800344 <printnum>
  8003bb:	eb 0f                	jmp    8003cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	89 34 24             	mov    %esi,(%esp)
  8003c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	4b                   	dec    %ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f f1                	jg     8003bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e2:	00 
  8003e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	e8 87 1c 00 00       	call   80207c <__umoddi3>
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	0f be 80 4b 22 80 00 	movsbl 0x80224b(%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800406:	83 c4 3c             	add    $0x3c,%esp
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800411:	83 fa 01             	cmp    $0x1,%edx
  800414:	7e 0e                	jle    800424 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	8b 52 04             	mov    0x4(%edx),%edx
  800422:	eb 22                	jmp    800446 <getuint+0x38>
	else if (lflag)
  800424:	85 d2                	test   %edx,%edx
  800426:	74 10                	je     800438 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 0e                	jmp    800446 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 02                	mov    (%edx),%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800451:	8b 10                	mov    (%eax),%edx
  800453:	3b 50 04             	cmp    0x4(%eax),%edx
  800456:	73 08                	jae    800460 <sprintputch+0x18>
		*b->buf++ = ch;
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	88 0a                	mov    %cl,(%edx)
  80045d:	42                   	inc    %edx
  80045e:	89 10                	mov    %edx,(%eax)
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	8b 45 10             	mov    0x10(%ebp),%eax
  800472:	89 44 24 08          	mov    %eax,0x8(%esp)
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 02 00 00 00       	call   80048a <vprintfmt>
	va_end(ap);
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 4c             	sub    $0x4c,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800496:	8b 75 10             	mov    0x10(%ebp),%esi
  800499:	eb 12                	jmp    8004ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049b:	85 c0                	test   %eax,%eax
  80049d:	0f 84 8b 03 00 00    	je     80082e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ad:	0f b6 06             	movzbl (%esi),%eax
  8004b0:	46                   	inc    %esi
  8004b1:	83 f8 25             	cmp    $0x25,%eax
  8004b4:	75 e5                	jne    80049b <vprintfmt+0x11>
  8004b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	eb 26                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004db:	eb 1d                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e4:	eb 14                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	0f b6 06             	movzbl (%esi),%eax
  8004fd:	8d 56 01             	lea    0x1(%esi),%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	8a 16                	mov    (%esi),%dl
  800505:	83 ea 23             	sub    $0x23,%edx
  800508:	80 fa 55             	cmp    $0x55,%dl
  80050b:	0f 87 01 03 00 00    	ja     800812 <vprintfmt+0x388>
  800511:	0f b6 d2             	movzbl %dl,%edx
  800514:	ff 24 95 80 23 80 00 	jmp    *0x802380(,%edx,4)
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800523:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800526:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80052a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80052d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800530:	83 fa 09             	cmp    $0x9,%edx
  800533:	77 2a                	ja     80055f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800536:	eb eb                	jmp    800523 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800546:	eb 17                	jmp    80055f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800548:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054c:	78 98                	js     8004e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800551:	eb a7                	jmp    8004fa <vprintfmt+0x70>
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80055d:	eb 9b                	jmp    8004fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	79 95                	jns    8004fa <vprintfmt+0x70>
  800565:	eb 8b                	jmp    8004f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800567:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056b:	eb 8d                	jmp    8004fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800585:	e9 23 ff ff ff       	jmp    8004ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	79 02                	jns    80059b <vprintfmt+0x111>
  800599:	f7 d8                	neg    %eax
  80059b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059d:	83 f8 0f             	cmp    $0xf,%eax
  8005a0:	7f 0b                	jg     8005ad <vprintfmt+0x123>
  8005a2:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 23                	jne    8005d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b1:	c7 44 24 08 63 22 80 	movl   $0x802263,0x8(%esp)
  8005b8:	00 
  8005b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 9a fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cb:	e9 dd fe ff ff       	jmp    8004ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d4:	c7 44 24 08 3e 26 80 	movl   $0x80263e,0x8(%esp)
  8005db:	00 
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	89 14 24             	mov    %edx,(%esp)
  8005e6:	e8 77 fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ee:	e9 ba fe ff ff       	jmp    8004ad <vprintfmt+0x23>
  8005f3:	89 f9                	mov    %edi,%ecx
  8005f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 30                	mov    (%eax),%esi
  800606:	85 f6                	test   %esi,%esi
  800608:	75 05                	jne    80060f <vprintfmt+0x185>
				p = "(null)";
  80060a:	be 5c 22 80 00       	mov    $0x80225c,%esi
			if (width > 0 && padc != '-')
  80060f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800613:	0f 8e 84 00 00 00    	jle    80069d <vprintfmt+0x213>
  800619:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80061d:	74 7e                	je     80069d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 ab 02 00 00       	call   8008d6 <strnlen>
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	29 c2                	sub    %eax,%edx
  800630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800633:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800637:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80063a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	eb 0b                	jmp    800650 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	4b                   	dec    %ebx
  800650:	85 db                	test   %ebx,%ebx
  800652:	7f f1                	jg     800645 <vprintfmt+0x1bb>
  800654:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800657:	89 f3                	mov    %esi,%ebx
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	79 05                	jns    800668 <vprintfmt+0x1de>
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	29 c2                	sub    %eax,%edx
  80066d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800670:	eb 2b                	jmp    80069d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800672:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800676:	74 18                	je     800690 <vprintfmt+0x206>
  800678:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067b:	83 fa 5e             	cmp    $0x5e,%edx
  80067e:	76 10                	jbe    800690 <vprintfmt+0x206>
					putch('?', putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	eb 0a                	jmp    80069a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	ff 4d e4             	decl   -0x1c(%ebp)
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	46                   	inc    %esi
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 21                	je     8006c6 <vprintfmt+0x23c>
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	78 c9                	js     800672 <vprintfmt+0x1e8>
  8006a9:	4f                   	dec    %edi
  8006aa:	79 c6                	jns    800672 <vprintfmt+0x1e8>
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	89 de                	mov    %ebx,%esi
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b4:	eb 18                	jmp    8006ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c3:	4b                   	dec    %ebx
  8006c4:	eb 08                	jmp    8006ce <vprintfmt+0x244>
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	89 de                	mov    %ebx,%esi
  8006cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f e4                	jg     8006b6 <vprintfmt+0x22c>
  8006d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006da:	e9 ce fd ff ff       	jmp    8004ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 08             	lea    0x8(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	8b 78 04             	mov    0x4(%eax),%edi
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x290>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	89 f7                	mov    %esi,%edi
  800705:	c1 ff 1f             	sar    $0x1f,%edi
  800708:	eb 10                	jmp    80071a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	89 f7                	mov    %esi,%edi
  800717:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	85 ff                	test   %edi,%edi
  80071c:	78 0a                	js     800728 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800723:	e9 ac 00 00 00       	jmp    8007d4 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800736:	f7 de                	neg    %esi
  800738:	83 d7 00             	adc    $0x0,%edi
  80073b:	f7 df                	neg    %edi
			}
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	e9 8d 00 00 00       	jmp    8007d4 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	89 ca                	mov    %ecx,%edx
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
  80074c:	e8 bd fc ff ff       	call   80040e <getuint>
  800751:	89 c6                	mov    %eax,%esi
  800753:	89 d7                	mov    %edx,%edi
			base = 10;
  800755:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80075a:	eb 78                	jmp    8007d4 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800767:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800789:	e9 1f fd ff ff       	jmp    8004ad <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80078e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800792:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800799:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 04             	lea    0x4(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b3:	8b 30                	mov    (%eax),%esi
  8007b5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007bf:	eb 13                	jmp    8007d4 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c1:	89 ca                	mov    %ecx,%edx
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	e8 43 fc ff ff       	call   80040e <getuint>
  8007cb:	89 c6                	mov    %eax,%esi
  8007cd:	89 d7                	mov    %edx,%edi
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007d8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e7:	89 34 24             	mov    %esi,(%esp)
  8007ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ee:	89 da                	mov    %ebx,%edx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	e8 4c fb ff ff       	call   800344 <printnum>
			break;
  8007f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007fb:	e9 ad fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80080d:	e9 9b fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800812:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800816:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80081d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800820:	eb 01                	jmp    800823 <vprintfmt+0x399>
  800822:	4e                   	dec    %esi
  800823:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800827:	75 f9                	jne    800822 <vprintfmt+0x398>
  800829:	e9 7f fc ff ff       	jmp    8004ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80082e:	83 c4 4c             	add    $0x4c,%esp
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5f                   	pop    %edi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	83 ec 28             	sub    $0x28,%esp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800842:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800845:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800849:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80084c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800853:	85 c0                	test   %eax,%eax
  800855:	74 30                	je     800887 <vsnprintf+0x51>
  800857:	85 d2                	test   %edx,%edx
  800859:	7e 33                	jle    80088e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800862:	8b 45 10             	mov    0x10(%ebp),%eax
  800865:	89 44 24 08          	mov    %eax,0x8(%esp)
  800869:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800870:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  800877:	e8 0e fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	eb 0c                	jmp    800893 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088c:	eb 05                	jmp    800893 <vsnprintf+0x5d>
  80088e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 7b ff ff ff       	call   800836 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    
  8008bd:	00 00                	add    %al,(%eax)
	...

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 01                	jmp    8008ce <strlen+0xe>
		n++;
  8008cd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d2:	75 f9                	jne    8008cd <strlen+0xd>
		n++;
	return n;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	eb 01                	jmp    8008e7 <strnlen+0x11>
		n++;
  8008e6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	39 d0                	cmp    %edx,%eax
  8008e9:	74 06                	je     8008f1 <strnlen+0x1b>
  8008eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ef:	75 f5                	jne    8008e6 <strnlen+0x10>
		n++;
	return n;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800902:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800905:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800908:	42                   	inc    %edx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 f5                	jne    800902 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091a:	89 1c 24             	mov    %ebx,(%esp)
  80091d:	e8 9e ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 54 24 04          	mov    %edx,0x4(%esp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	e8 c0 ff ff ff       	call   8008f3 <strcpy>
	return dst;
}
  800933:	89 d8                	mov    %ebx,%eax
  800935:	83 c4 08             	add    $0x8,%esp
  800938:	5b                   	pop    %ebx
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094e:	eb 0c                	jmp    80095c <strncpy+0x21>
		*dst++ = *src;
  800950:	8a 1a                	mov    (%edx),%bl
  800952:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 3a 01             	cmpb   $0x1,(%edx)
  800958:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	41                   	inc    %ecx
  80095c:	39 f1                	cmp    %esi,%ecx
  80095e:	75 f0                	jne    800950 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800972:	85 d2                	test   %edx,%edx
  800974:	75 0a                	jne    800980 <strlcpy+0x1c>
  800976:	89 f0                	mov    %esi,%eax
  800978:	eb 1a                	jmp    800994 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097a:	88 18                	mov    %bl,(%eax)
  80097c:	40                   	inc    %eax
  80097d:	41                   	inc    %ecx
  80097e:	eb 02                	jmp    800982 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800980:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800982:	4a                   	dec    %edx
  800983:	74 0a                	je     80098f <strlcpy+0x2b>
  800985:	8a 19                	mov    (%ecx),%bl
  800987:	84 db                	test   %bl,%bl
  800989:	75 ef                	jne    80097a <strlcpy+0x16>
  80098b:	89 c2                	mov    %eax,%edx
  80098d:	eb 02                	jmp    800991 <strlcpy+0x2d>
  80098f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800991:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800994:	29 f0                	sub    %esi,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a3:	eb 02                	jmp    8009a7 <strcmp+0xd>
		p++, q++;
  8009a5:	41                   	inc    %ecx
  8009a6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a7:	8a 01                	mov    (%ecx),%al
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 04                	je     8009b1 <strcmp+0x17>
  8009ad:	3a 02                	cmp    (%edx),%al
  8009af:	74 f4                	je     8009a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	0f b6 12             	movzbl (%edx),%edx
  8009b7:	29 d0                	sub    %edx,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009c8:	eb 03                	jmp    8009cd <strncmp+0x12>
		n--, p++, q++;
  8009ca:	4a                   	dec    %edx
  8009cb:	40                   	inc    %eax
  8009cc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cd:	85 d2                	test   %edx,%edx
  8009cf:	74 14                	je     8009e5 <strncmp+0x2a>
  8009d1:	8a 18                	mov    (%eax),%bl
  8009d3:	84 db                	test   %bl,%bl
  8009d5:	74 04                	je     8009db <strncmp+0x20>
  8009d7:	3a 19                	cmp    (%ecx),%bl
  8009d9:	74 ef                	je     8009ca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009db:	0f b6 00             	movzbl (%eax),%eax
  8009de:	0f b6 11             	movzbl (%ecx),%edx
  8009e1:	29 d0                	sub    %edx,%eax
  8009e3:	eb 05                	jmp    8009ea <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f6:	eb 05                	jmp    8009fd <strchr+0x10>
		if (*s == c)
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	74 0c                	je     800a08 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fc:	40                   	inc    %eax
  8009fd:	8a 10                	mov    (%eax),%dl
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f5                	jne    8009f8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a13:	eb 05                	jmp    800a1a <strfind+0x10>
		if (*s == c)
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	74 07                	je     800a20 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a19:	40                   	inc    %eax
  800a1a:	8a 10                	mov    (%eax),%dl
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f5                	jne    800a15 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a31:	85 c9                	test   %ecx,%ecx
  800a33:	74 30                	je     800a65 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3b:	75 25                	jne    800a62 <memset+0x40>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	75 20                	jne    800a62 <memset+0x40>
		c &= 0xFF;
  800a42:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a45:	89 d3                	mov    %edx,%ebx
  800a47:	c1 e3 08             	shl    $0x8,%ebx
  800a4a:	89 d6                	mov    %edx,%esi
  800a4c:	c1 e6 18             	shl    $0x18,%esi
  800a4f:	89 d0                	mov    %edx,%eax
  800a51:	c1 e0 10             	shl    $0x10,%eax
  800a54:	09 f0                	or     %esi,%eax
  800a56:	09 d0                	or     %edx,%eax
  800a58:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a5d:	fc                   	cld    
  800a5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a60:	eb 03                	jmp    800a65 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a62:	fc                   	cld    
  800a63:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a65:	89 f8                	mov    %edi,%eax
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7a:	39 c6                	cmp    %eax,%esi
  800a7c:	73 34                	jae    800ab2 <memmove+0x46>
  800a7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a81:	39 d0                	cmp    %edx,%eax
  800a83:	73 2d                	jae    800ab2 <memmove+0x46>
		s += n;
		d += n;
  800a85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	f6 c2 03             	test   $0x3,%dl
  800a8b:	75 1b                	jne    800aa8 <memmove+0x3c>
  800a8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a93:	75 13                	jne    800aa8 <memmove+0x3c>
  800a95:	f6 c1 03             	test   $0x3,%cl
  800a98:	75 0e                	jne    800aa8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9a:	83 ef 04             	sub    $0x4,%edi
  800a9d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aa3:	fd                   	std    
  800aa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa6:	eb 07                	jmp    800aaf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa8:	4f                   	dec    %edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 20                	jmp    800ad2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	75 13                	jne    800acd <memmove+0x61>
  800aba:	a8 03                	test   $0x3,%al
  800abc:	75 0f                	jne    800acd <memmove+0x61>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 0a                	jne    800acd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acb:	eb 05                	jmp    800ad2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800adc:	8b 45 10             	mov    0x10(%ebp),%eax
  800adf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	89 04 24             	mov    %eax,(%esp)
  800af0:	e8 77 ff ff ff       	call   800a6c <memmove>
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	eb 16                	jmp    800b23 <memcmp+0x2c>
		if (*s1 != *s2)
  800b0d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b10:	42                   	inc    %edx
  800b11:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b15:	38 c8                	cmp    %cl,%al
  800b17:	74 0a                	je     800b23 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b19:	0f b6 c0             	movzbl %al,%eax
  800b1c:	0f b6 c9             	movzbl %cl,%ecx
  800b1f:	29 c8                	sub    %ecx,%eax
  800b21:	eb 09                	jmp    800b2c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	39 da                	cmp    %ebx,%edx
  800b25:	75 e6                	jne    800b0d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3a:	89 c2                	mov    %eax,%edx
  800b3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3f:	eb 05                	jmp    800b46 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b41:	38 08                	cmp    %cl,(%eax)
  800b43:	74 05                	je     800b4a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b45:	40                   	inc    %eax
  800b46:	39 d0                	cmp    %edx,%eax
  800b48:	72 f7                	jb     800b41 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b58:	eb 01                	jmp    800b5b <strtol+0xf>
		s++;
  800b5a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	8a 02                	mov    (%edx),%al
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 f9                	je     800b5a <strtol+0xe>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	74 f5                	je     800b5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b65:	3c 2b                	cmp    $0x2b,%al
  800b67:	75 08                	jne    800b71 <strtol+0x25>
		s++;
  800b69:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6f:	eb 13                	jmp    800b84 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b71:	3c 2d                	cmp    $0x2d,%al
  800b73:	75 0a                	jne    800b7f <strtol+0x33>
		s++, neg = 1;
  800b75:	8d 52 01             	lea    0x1(%edx),%edx
  800b78:	bf 01 00 00 00       	mov    $0x1,%edi
  800b7d:	eb 05                	jmp    800b84 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b84:	85 db                	test   %ebx,%ebx
  800b86:	74 05                	je     800b8d <strtol+0x41>
  800b88:	83 fb 10             	cmp    $0x10,%ebx
  800b8b:	75 28                	jne    800bb5 <strtol+0x69>
  800b8d:	8a 02                	mov    (%edx),%al
  800b8f:	3c 30                	cmp    $0x30,%al
  800b91:	75 10                	jne    800ba3 <strtol+0x57>
  800b93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b97:	75 0a                	jne    800ba3 <strtol+0x57>
		s += 2, base = 16;
  800b99:	83 c2 02             	add    $0x2,%edx
  800b9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba1:	eb 12                	jmp    800bb5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ba3:	85 db                	test   %ebx,%ebx
  800ba5:	75 0e                	jne    800bb5 <strtol+0x69>
  800ba7:	3c 30                	cmp    $0x30,%al
  800ba9:	75 05                	jne    800bb0 <strtol+0x64>
		s++, base = 8;
  800bab:	42                   	inc    %edx
  800bac:	b3 08                	mov    $0x8,%bl
  800bae:	eb 05                	jmp    800bb5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bb0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbc:	8a 0a                	mov    (%edx),%cl
  800bbe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bc1:	80 fb 09             	cmp    $0x9,%bl
  800bc4:	77 08                	ja     800bce <strtol+0x82>
			dig = *s - '0';
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 30             	sub    $0x30,%ecx
  800bcc:	eb 1e                	jmp    800bec <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bce:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 08                	ja     800bde <strtol+0x92>
			dig = *s - 'a' + 10;
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 57             	sub    $0x57,%ecx
  800bdc:	eb 0e                	jmp    800bec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 12                	ja     800bf8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bec:	39 f1                	cmp    %esi,%ecx
  800bee:	7d 0c                	jge    800bfc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bf0:	42                   	inc    %edx
  800bf1:	0f af c6             	imul   %esi,%eax
  800bf4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bf6:	eb c4                	jmp    800bbc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	89 c1                	mov    %eax,%ecx
  800bfa:	eb 02                	jmp    800bfe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bfc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c02:	74 05                	je     800c09 <strtol+0xbd>
		*endptr = (char *) s;
  800c04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c07:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c09:	85 ff                	test   %edi,%edi
  800c0b:	74 04                	je     800c11 <strtol+0xc5>
  800c0d:	89 c8                	mov    %ecx,%eax
  800c0f:	f7 d8                	neg    %eax
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    
	...

00800c18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 c7                	mov    %eax,%edi
  800c2d:	89 c6                	mov    %eax,%esi
  800c2f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 01 00 00 00       	mov    $0x1,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c63:	b8 03 00 00 00       	mov    $0x3,%eax
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 cb                	mov    %ecx,%ebx
  800c6d:	89 cf                	mov    %ecx,%edi
  800c6f:	89 ce                	mov    %ecx,%esi
  800c71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 28                	jle    800c9f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c82:	00 
  800c83:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c92:	00 
  800c93:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800c9a:	e8 91 f5 ff ff       	call   800230 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9f:	83 c4 2c             	add    $0x2c,%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	89 d3                	mov    %edx,%ebx
  800cbb:	89 d7                	mov    %edx,%edi
  800cbd:	89 d6                	mov    %edx,%esi
  800cbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_yield>:

void
sys_yield(void)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd6:	89 d1                	mov    %edx,%ecx
  800cd8:	89 d3                	mov    %edx,%ebx
  800cda:	89 d7                	mov    %edx,%edi
  800cdc:	89 d6                	mov    %edx,%esi
  800cde:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	be 00 00 00 00       	mov    $0x0,%esi
  800cf3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 f7                	mov    %esi,%edi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 28                	jle    800d31 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800d2c:	e8 ff f4 ff ff       	call   800230 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d31:	83 c4 2c             	add    $0x2c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b8 05 00 00 00       	mov    $0x5,%eax
  800d47:	8b 75 18             	mov    0x18(%ebp),%esi
  800d4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800d7f:	e8 ac f4 ff ff       	call   800230 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d84:	83 c4 2c             	add    $0x2c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 28                	jle    800dd7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dba:	00 
  800dbb:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800dd2:	e8 59 f4 ff ff       	call   800230 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd7:	83 c4 2c             	add    $0x2c,%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	b8 08 00 00 00       	mov    $0x8,%eax
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7e 28                	jle    800e2a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e06:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800e15:	00 
  800e16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1d:	00 
  800e1e:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800e25:	e8 06 f4 ff ff       	call   800230 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2a:	83 c4 2c             	add    $0x2c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e40:	b8 09 00 00 00       	mov    $0x9,%eax
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 df                	mov    %ebx,%edi
  800e4d:	89 de                	mov    %ebx,%esi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800e78:	e8 b3 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e7d:	83 c4 2c             	add    $0x2c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 df                	mov    %ebx,%edi
  800ea0:	89 de                	mov    %ebx,%esi
  800ea2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 28                	jle    800ed0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eac:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec3:	00 
  800ec4:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800ecb:	e8 60 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed0:	83 c4 2c             	add    $0x2c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	be 00 00 00 00       	mov    $0x0,%esi
  800ee3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f11:	89 cb                	mov    %ecx,%ebx
  800f13:	89 cf                	mov    %ecx,%edi
  800f15:	89 ce                	mov    %ecx,%esi
  800f17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	7e 28                	jle    800f45 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f21:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f28:	00 
  800f29:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800f30:	00 
  800f31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f38:	00 
  800f39:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800f40:	e8 eb f2 ff ff       	call   800230 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f45:	83 c4 2c             	add    $0x2c,%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	00 00                	add    %al,(%eax)
	...

00800f50 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	05 00 00 00 30       	add    $0x30000000,%eax
  800f5b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f66:	8b 45 08             	mov    0x8(%ebp),%eax
  800f69:	89 04 24             	mov    %eax,(%esp)
  800f6c:	e8 df ff ff ff       	call   800f50 <fd2num>
  800f71:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f76:	c1 e0 0c             	shl    $0xc,%eax
}
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	53                   	push   %ebx
  800f7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f82:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f87:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	c1 ea 16             	shr    $0x16,%edx
  800f8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f95:	f6 c2 01             	test   $0x1,%dl
  800f98:	74 11                	je     800fab <fd_alloc+0x30>
  800f9a:	89 c2                	mov    %eax,%edx
  800f9c:	c1 ea 0c             	shr    $0xc,%edx
  800f9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa6:	f6 c2 01             	test   $0x1,%dl
  800fa9:	75 09                	jne    800fb4 <fd_alloc+0x39>
			*fd_store = fd;
  800fab:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb2:	eb 17                	jmp    800fcb <fd_alloc+0x50>
  800fb4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fb9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fbe:	75 c7                	jne    800f87 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fc0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fc6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fd4:	83 f8 1f             	cmp    $0x1f,%eax
  800fd7:	77 36                	ja     80100f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fd9:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fde:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	c1 ea 16             	shr    $0x16,%edx
  800fe6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fed:	f6 c2 01             	test   $0x1,%dl
  800ff0:	74 24                	je     801016 <fd_lookup+0x48>
  800ff2:	89 c2                	mov    %eax,%edx
  800ff4:	c1 ea 0c             	shr    $0xc,%edx
  800ff7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ffe:	f6 c2 01             	test   $0x1,%dl
  801001:	74 1a                	je     80101d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801003:	8b 55 0c             	mov    0xc(%ebp),%edx
  801006:	89 02                	mov    %eax,(%edx)
	return 0;
  801008:	b8 00 00 00 00       	mov    $0x0,%eax
  80100d:	eb 13                	jmp    801022 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80100f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801014:	eb 0c                	jmp    801022 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801016:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80101b:	eb 05                	jmp    801022 <fd_lookup+0x54>
  80101d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	53                   	push   %ebx
  801028:	83 ec 14             	sub    $0x14,%esp
  80102b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80102e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801031:	ba 00 00 00 00       	mov    $0x0,%edx
  801036:	eb 0e                	jmp    801046 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801038:	39 08                	cmp    %ecx,(%eax)
  80103a:	75 09                	jne    801045 <dev_lookup+0x21>
			*dev = devtab[i];
  80103c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
  801043:	eb 33                	jmp    801078 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801045:	42                   	inc    %edx
  801046:	8b 04 95 ec 25 80 00 	mov    0x8025ec(,%edx,4),%eax
  80104d:	85 c0                	test   %eax,%eax
  80104f:	75 e7                	jne    801038 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801051:	a1 08 40 80 00       	mov    0x804008,%eax
  801056:	8b 40 48             	mov    0x48(%eax),%eax
  801059:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801061:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  801068:	e8 bb f2 ff ff       	call   800328 <cprintf>
	*dev = 0;
  80106d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801073:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801078:	83 c4 14             	add    $0x14,%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 30             	sub    $0x30,%esp
  801086:	8b 75 08             	mov    0x8(%ebp),%esi
  801089:	8a 45 0c             	mov    0xc(%ebp),%al
  80108c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80108f:	89 34 24             	mov    %esi,(%esp)
  801092:	e8 b9 fe ff ff       	call   800f50 <fd2num>
  801097:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80109a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80109e:	89 04 24             	mov    %eax,(%esp)
  8010a1:	e8 28 ff ff ff       	call   800fce <fd_lookup>
  8010a6:	89 c3                	mov    %eax,%ebx
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 05                	js     8010b1 <fd_close+0x33>
	    || fd != fd2)
  8010ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010af:	74 0d                	je     8010be <fd_close+0x40>
		return (must_exist ? r : 0);
  8010b1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010b5:	75 46                	jne    8010fd <fd_close+0x7f>
  8010b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bc:	eb 3f                	jmp    8010fd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c5:	8b 06                	mov    (%esi),%eax
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	e8 55 ff ff ff       	call   801024 <dev_lookup>
  8010cf:	89 c3                	mov    %eax,%ebx
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 18                	js     8010ed <fd_close+0x6f>
		if (dev->dev_close)
  8010d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d8:	8b 40 10             	mov    0x10(%eax),%eax
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	74 09                	je     8010e8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010df:	89 34 24             	mov    %esi,(%esp)
  8010e2:	ff d0                	call   *%eax
  8010e4:	89 c3                	mov    %eax,%ebx
  8010e6:	eb 05                	jmp    8010ed <fd_close+0x6f>
		else
			r = 0;
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f8:	e8 8f fc ff ff       	call   800d8c <sys_page_unmap>
	return r;
}
  8010fd:	89 d8                	mov    %ebx,%eax
  8010ff:	83 c4 30             	add    $0x30,%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80110c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	89 04 24             	mov    %eax,(%esp)
  801119:	e8 b0 fe ff ff       	call   800fce <fd_lookup>
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 13                	js     801135 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801122:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801129:	00 
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	89 04 24             	mov    %eax,(%esp)
  801130:	e8 49 ff ff ff       	call   80107e <fd_close>
}
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <close_all>:

void
close_all(void)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	53                   	push   %ebx
  80113b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80113e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801143:	89 1c 24             	mov    %ebx,(%esp)
  801146:	e8 bb ff ff ff       	call   801106 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80114b:	43                   	inc    %ebx
  80114c:	83 fb 20             	cmp    $0x20,%ebx
  80114f:	75 f2                	jne    801143 <close_all+0xc>
		close(i);
}
  801151:	83 c4 14             	add    $0x14,%esp
  801154:	5b                   	pop    %ebx
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 4c             	sub    $0x4c,%esp
  801160:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801163:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	89 04 24             	mov    %eax,(%esp)
  801170:	e8 59 fe ff ff       	call   800fce <fd_lookup>
  801175:	89 c3                	mov    %eax,%ebx
  801177:	85 c0                	test   %eax,%eax
  801179:	0f 88 e1 00 00 00    	js     801260 <dup+0x109>
		return r;
	close(newfdnum);
  80117f:	89 3c 24             	mov    %edi,(%esp)
  801182:	e8 7f ff ff ff       	call   801106 <close>

	newfd = INDEX2FD(newfdnum);
  801187:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80118d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801190:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801193:	89 04 24             	mov    %eax,(%esp)
  801196:	e8 c5 fd ff ff       	call   800f60 <fd2data>
  80119b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80119d:	89 34 24             	mov    %esi,(%esp)
  8011a0:	e8 bb fd ff ff       	call   800f60 <fd2data>
  8011a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011a8:	89 d8                	mov    %ebx,%eax
  8011aa:	c1 e8 16             	shr    $0x16,%eax
  8011ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b4:	a8 01                	test   $0x1,%al
  8011b6:	74 46                	je     8011fe <dup+0xa7>
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	c1 e8 0c             	shr    $0xc,%eax
  8011bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c4:	f6 c2 01             	test   $0x1,%dl
  8011c7:	74 35                	je     8011fe <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e7:	00 
  8011e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f3:	e8 41 fb ff ff       	call   800d39 <sys_page_map>
  8011f8:	89 c3                	mov    %eax,%ebx
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 3b                	js     801239 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 0c             	shr    $0xc,%edx
  801206:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801213:	89 54 24 10          	mov    %edx,0x10(%esp)
  801217:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80121b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801222:	00 
  801223:	89 44 24 04          	mov    %eax,0x4(%esp)
  801227:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122e:	e8 06 fb ff ff       	call   800d39 <sys_page_map>
  801233:	89 c3                	mov    %eax,%ebx
  801235:	85 c0                	test   %eax,%eax
  801237:	79 25                	jns    80125e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801239:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801244:	e8 43 fb ff ff       	call   800d8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801249:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801257:	e8 30 fb ff ff       	call   800d8c <sys_page_unmap>
	return r;
  80125c:	eb 02                	jmp    801260 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80125e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801260:	89 d8                	mov    %ebx,%eax
  801262:	83 c4 4c             	add    $0x4c,%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5f                   	pop    %edi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 24             	sub    $0x24,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	89 1c 24             	mov    %ebx,(%esp)
  80127e:	e8 4b fd ff ff       	call   800fce <fd_lookup>
  801283:	85 c0                	test   %eax,%eax
  801285:	78 6d                	js     8012f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	8b 00                	mov    (%eax),%eax
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	e8 89 fd ff ff       	call   801024 <dev_lookup>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 55                	js     8012f4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	8b 50 08             	mov    0x8(%eax),%edx
  8012a5:	83 e2 03             	and    $0x3,%edx
  8012a8:	83 fa 01             	cmp    $0x1,%edx
  8012ab:	75 23                	jne    8012d0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b2:	8b 40 48             	mov    0x48(%eax),%eax
  8012b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bd:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8012c4:	e8 5f f0 ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  8012c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ce:	eb 24                	jmp    8012f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8012d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d3:	8b 52 08             	mov    0x8(%edx),%edx
  8012d6:	85 d2                	test   %edx,%edx
  8012d8:	74 15                	je     8012ef <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e8:	89 04 24             	mov    %eax,(%esp)
  8012eb:	ff d2                	call   *%edx
  8012ed:	eb 05                	jmp    8012f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012f4:	83 c4 24             	add    $0x24,%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	57                   	push   %edi
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 1c             	sub    $0x1c,%esp
  801303:	8b 7d 08             	mov    0x8(%ebp),%edi
  801306:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130e:	eb 23                	jmp    801333 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801310:	89 f0                	mov    %esi,%eax
  801312:	29 d8                	sub    %ebx,%eax
  801314:	89 44 24 08          	mov    %eax,0x8(%esp)
  801318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131b:	01 d8                	add    %ebx,%eax
  80131d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801321:	89 3c 24             	mov    %edi,(%esp)
  801324:	e8 41 ff ff ff       	call   80126a <read>
		if (m < 0)
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 10                	js     80133d <readn+0x43>
			return m;
		if (m == 0)
  80132d:	85 c0                	test   %eax,%eax
  80132f:	74 0a                	je     80133b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801331:	01 c3                	add    %eax,%ebx
  801333:	39 f3                	cmp    %esi,%ebx
  801335:	72 d9                	jb     801310 <readn+0x16>
  801337:	89 d8                	mov    %ebx,%eax
  801339:	eb 02                	jmp    80133d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80133b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80133d:	83 c4 1c             	add    $0x1c,%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5f                   	pop    %edi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 24             	sub    $0x24,%esp
  80134c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	89 1c 24             	mov    %ebx,(%esp)
  801359:	e8 70 fc ff ff       	call   800fce <fd_lookup>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 68                	js     8013ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	89 44 24 04          	mov    %eax,0x4(%esp)
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	8b 00                	mov    (%eax),%eax
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	e8 ae fc ff ff       	call   801024 <dev_lookup>
  801376:	85 c0                	test   %eax,%eax
  801378:	78 50                	js     8013ca <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801381:	75 23                	jne    8013a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801383:	a1 08 40 80 00       	mov    0x804008,%eax
  801388:	8b 40 48             	mov    0x48(%eax),%eax
  80138b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80138f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801393:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80139a:	e8 89 ef ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  80139f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a4:	eb 24                	jmp    8013ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ac:	85 d2                	test   %edx,%edx
  8013ae:	74 15                	je     8013c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	ff d2                	call   *%edx
  8013c3:	eb 05                	jmp    8013ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013ca:	83 c4 24             	add    $0x24,%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e0:	89 04 24             	mov    %eax,(%esp)
  8013e3:	e8 e6 fb ff ff       	call   800fce <fd_lookup>
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 0e                	js     8013fa <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	53                   	push   %ebx
  801400:	83 ec 24             	sub    $0x24,%esp
  801403:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801406:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140d:	89 1c 24             	mov    %ebx,(%esp)
  801410:	e8 b9 fb ff ff       	call   800fce <fd_lookup>
  801415:	85 c0                	test   %eax,%eax
  801417:	78 61                	js     80147a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801419:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801420:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801423:	8b 00                	mov    (%eax),%eax
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 f7 fb ff ff       	call   801024 <dev_lookup>
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 49                	js     80147a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801438:	75 23                	jne    80145d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80143a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80143f:	8b 40 48             	mov    0x48(%eax),%eax
  801442:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144a:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  801451:	e8 d2 ee ff ff       	call   800328 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145b:	eb 1d                	jmp    80147a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80145d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801460:	8b 52 18             	mov    0x18(%edx),%edx
  801463:	85 d2                	test   %edx,%edx
  801465:	74 0e                	je     801475 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801467:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80146a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80146e:	89 04 24             	mov    %eax,(%esp)
  801471:	ff d2                	call   *%edx
  801473:	eb 05                	jmp    80147a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801475:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80147a:	83 c4 24             	add    $0x24,%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	53                   	push   %ebx
  801484:	83 ec 24             	sub    $0x24,%esp
  801487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	e8 32 fb ff ff       	call   800fce <fd_lookup>
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 52                	js     8014f2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 70 fb ff ff       	call   801024 <dev_lookup>
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 3a                	js     8014f2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014bf:	74 2c                	je     8014ed <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014cb:	00 00 00 
	stat->st_isdir = 0;
  8014ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014d5:	00 00 00 
	stat->st_dev = dev;
  8014d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e5:	89 14 24             	mov    %edx,(%esp)
  8014e8:	ff 50 14             	call   *0x14(%eax)
  8014eb:	eb 05                	jmp    8014f2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014f2:	83 c4 24             	add    $0x24,%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	56                   	push   %esi
  8014fc:	53                   	push   %ebx
  8014fd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801500:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801507:	00 
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 fe 01 00 00       	call   801711 <open>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	85 c0                	test   %eax,%eax
  801517:	78 1b                	js     801534 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801520:	89 1c 24             	mov    %ebx,(%esp)
  801523:	e8 58 ff ff ff       	call   801480 <fstat>
  801528:	89 c6                	mov    %eax,%esi
	close(fd);
  80152a:	89 1c 24             	mov    %ebx,(%esp)
  80152d:	e8 d4 fb ff ff       	call   801106 <close>
	return r;
  801532:	89 f3                	mov    %esi,%ebx
}
  801534:	89 d8                	mov    %ebx,%eax
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    
  80153d:	00 00                	add    %al,(%eax)
	...

00801540 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 10             	sub    $0x10,%esp
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80154c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801553:	75 11                	jne    801566 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801555:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80155c:	e8 70 09 00 00       	call   801ed1 <ipc_find_env>
  801561:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801566:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80156d:	00 
  80156e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801575:	00 
  801576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80157a:	a1 04 40 80 00       	mov    0x804004,%eax
  80157f:	89 04 24             	mov    %eax,(%esp)
  801582:	e8 e0 08 00 00       	call   801e67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801587:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80158e:	00 
  80158f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159a:	e8 61 08 00 00       	call   801e00 <ipc_recv>
}
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5e                   	pop    %esi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    

008015a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8015c9:	e8 72 ff ff ff       	call   801540 <fsipc>
}
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8015eb:	e8 50 ff ff ff       	call   801540 <fsipc>
}
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 14             	sub    $0x14,%esp
  8015f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801602:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801607:	ba 00 00 00 00       	mov    $0x0,%edx
  80160c:	b8 05 00 00 00       	mov    $0x5,%eax
  801611:	e8 2a ff ff ff       	call   801540 <fsipc>
  801616:	85 c0                	test   %eax,%eax
  801618:	78 2b                	js     801645 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80161a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801621:	00 
  801622:	89 1c 24             	mov    %ebx,(%esp)
  801625:	e8 c9 f2 ff ff       	call   8008f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80162a:	a1 80 50 80 00       	mov    0x805080,%eax
  80162f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801635:	a1 84 50 80 00       	mov    0x805084,%eax
  80163a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	83 c4 14             	add    $0x14,%esp
  801648:	5b                   	pop    %ebx
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801651:	c7 44 24 08 fc 25 80 	movl   $0x8025fc,0x8(%esp)
  801658:	00 
  801659:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801660:	00 
  801661:	c7 04 24 1a 26 80 00 	movl   $0x80261a,(%esp)
  801668:	e8 c3 eb ff ff       	call   800230 <_panic>

0080166d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 10             	sub    $0x10,%esp
  801675:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 40 0c             	mov    0xc(%eax),%eax
  80167e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801683:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 03 00 00 00       	mov    $0x3,%eax
  801693:	e8 a8 fe ff ff       	call   801540 <fsipc>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 6a                	js     801708 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80169e:	39 c6                	cmp    %eax,%esi
  8016a0:	73 24                	jae    8016c6 <devfile_read+0x59>
  8016a2:	c7 44 24 0c 25 26 80 	movl   $0x802625,0xc(%esp)
  8016a9:	00 
  8016aa:	c7 44 24 08 2c 26 80 	movl   $0x80262c,0x8(%esp)
  8016b1:	00 
  8016b2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016b9:	00 
  8016ba:	c7 04 24 1a 26 80 00 	movl   $0x80261a,(%esp)
  8016c1:	e8 6a eb ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  8016c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016cb:	7e 24                	jle    8016f1 <devfile_read+0x84>
  8016cd:	c7 44 24 0c 41 26 80 	movl   $0x802641,0xc(%esp)
  8016d4:	00 
  8016d5:	c7 44 24 08 2c 26 80 	movl   $0x80262c,0x8(%esp)
  8016dc:	00 
  8016dd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016e4:	00 
  8016e5:	c7 04 24 1a 26 80 00 	movl   $0x80261a,(%esp)
  8016ec:	e8 3f eb ff ff       	call   800230 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016fc:	00 
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801700:	89 04 24             	mov    %eax,(%esp)
  801703:	e8 64 f3 ff ff       	call   800a6c <memmove>
	return r;
}
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	83 ec 20             	sub    $0x20,%esp
  801719:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80171c:	89 34 24             	mov    %esi,(%esp)
  80171f:	e8 9c f1 ff ff       	call   8008c0 <strlen>
  801724:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801729:	7f 60                	jg     80178b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	e8 45 f8 ff ff       	call   800f7b <fd_alloc>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 54                	js     801790 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80173c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801740:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801747:	e8 a7 f1 ff ff       	call   8008f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80174c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801754:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801757:	b8 01 00 00 00       	mov    $0x1,%eax
  80175c:	e8 df fd ff ff       	call   801540 <fsipc>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	85 c0                	test   %eax,%eax
  801765:	79 15                	jns    80177c <open+0x6b>
		fd_close(fd, 0);
  801767:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80176e:	00 
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	89 04 24             	mov    %eax,(%esp)
  801775:	e8 04 f9 ff ff       	call   80107e <fd_close>
		return r;
  80177a:	eb 14                	jmp    801790 <open+0x7f>
	}

	return fd2num(fd);
  80177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177f:	89 04 24             	mov    %eax,(%esp)
  801782:	e8 c9 f7 ff ff       	call   800f50 <fd2num>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	eb 05                	jmp    801790 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80178b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801790:	89 d8                	mov    %ebx,%eax
  801792:	83 c4 20             	add    $0x20,%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8017a9:	e8 92 fd ff ff       	call   801540 <fsipc>
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	83 ec 14             	sub    $0x14,%esp
  8017b7:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017b9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017bd:	7e 32                	jle    8017f1 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017bf:	8b 40 04             	mov    0x4(%eax),%eax
  8017c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c6:	8d 43 10             	lea    0x10(%ebx),%eax
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	8b 03                	mov    (%ebx),%eax
  8017cf:	89 04 24             	mov    %eax,(%esp)
  8017d2:	e8 6e fb ff ff       	call   801345 <write>
		if (result > 0)
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	7e 03                	jle    8017de <writebuf+0x2e>
			b->result += result;
  8017db:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017de:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017e1:	74 0e                	je     8017f1 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	7e 05                	jle    8017ee <writebuf+0x3e>
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8017f1:	83 c4 14             	add    $0x14,%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <putch>:

static void
putch(int ch, void *thunk)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801801:	8b 43 04             	mov    0x4(%ebx),%eax
  801804:	8b 55 08             	mov    0x8(%ebp),%edx
  801807:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80180b:	40                   	inc    %eax
  80180c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80180f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801814:	75 0e                	jne    801824 <putch+0x2d>
		writebuf(b);
  801816:	89 d8                	mov    %ebx,%eax
  801818:	e8 93 ff ff ff       	call   8017b0 <writebuf>
		b->idx = 0;
  80181d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801824:	83 c4 04             	add    $0x4,%esp
  801827:	5b                   	pop    %ebx
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80183c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801843:	00 00 00 
	b.result = 0;
  801846:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80184d:	00 00 00 
	b.error = 1;
  801850:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801857:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80185a:	8b 45 10             	mov    0x10(%ebp),%eax
  80185d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	89 44 24 08          	mov    %eax,0x8(%esp)
  801868:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	c7 04 24 f7 17 80 00 	movl   $0x8017f7,(%esp)
  801879:	e8 0c ec ff ff       	call   80048a <vprintfmt>
	if (b.idx > 0)
  80187e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801885:	7e 0b                	jle    801892 <vfprintf+0x68>
		writebuf(&b);
  801887:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80188d:	e8 1e ff ff ff       	call   8017b0 <writebuf>

	return (b.result ? b.result : b.error);
  801892:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801898:	85 c0                	test   %eax,%eax
  80189a:	75 06                	jne    8018a2 <vfprintf+0x78>
  80189c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018aa:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 67 ff ff ff       	call   80182a <vfprintf>
	va_end(ap);

	return cnt;
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <printf>:

int
printf(const char *fmt, ...)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018e0:	e8 45 ff ff ff       	call   80182a <vfprintf>
	va_end(ap);

	return cnt;
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    
	...

008018e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	83 ec 10             	sub    $0x10,%esp
  8018f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f6:	89 04 24             	mov    %eax,(%esp)
  8018f9:	e8 62 f6 ff ff       	call   800f60 <fd2data>
  8018fe:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801900:	c7 44 24 04 4d 26 80 	movl   $0x80264d,0x4(%esp)
  801907:	00 
  801908:	89 34 24             	mov    %esi,(%esp)
  80190b:	e8 e3 ef ff ff       	call   8008f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801910:	8b 43 04             	mov    0x4(%ebx),%eax
  801913:	2b 03                	sub    (%ebx),%eax
  801915:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80191b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801922:	00 00 00 
	stat->st_dev = &devpipe;
  801925:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  80192c:	30 80 00 
	return 0;
}
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	83 ec 14             	sub    $0x14,%esp
  801942:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801945:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801949:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801950:	e8 37 f4 ff ff       	call   800d8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801955:	89 1c 24             	mov    %ebx,(%esp)
  801958:	e8 03 f6 ff ff       	call   800f60 <fd2data>
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801968:	e8 1f f4 ff ff       	call   800d8c <sys_page_unmap>
}
  80196d:	83 c4 14             	add    $0x14,%esp
  801970:	5b                   	pop    %ebx
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	57                   	push   %edi
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	83 ec 2c             	sub    $0x2c,%esp
  80197c:	89 c7                	mov    %eax,%edi
  80197e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801981:	a1 08 40 80 00       	mov    0x804008,%eax
  801986:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801989:	89 3c 24             	mov    %edi,(%esp)
  80198c:	e8 87 05 00 00       	call   801f18 <pageref>
  801991:	89 c6                	mov    %eax,%esi
  801993:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801996:	89 04 24             	mov    %eax,(%esp)
  801999:	e8 7a 05 00 00       	call   801f18 <pageref>
  80199e:	39 c6                	cmp    %eax,%esi
  8019a0:	0f 94 c0             	sete   %al
  8019a3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019a6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019ac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019af:	39 cb                	cmp    %ecx,%ebx
  8019b1:	75 08                	jne    8019bb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019b3:	83 c4 2c             	add    $0x2c,%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5f                   	pop    %edi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019bb:	83 f8 01             	cmp    $0x1,%eax
  8019be:	75 c1                	jne    801981 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019c0:	8b 42 58             	mov    0x58(%edx),%eax
  8019c3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8019ca:	00 
  8019cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d3:	c7 04 24 54 26 80 00 	movl   $0x802654,(%esp)
  8019da:	e8 49 e9 ff ff       	call   800328 <cprintf>
  8019df:	eb a0                	jmp    801981 <_pipeisclosed+0xe>

008019e1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	57                   	push   %edi
  8019e5:	56                   	push   %esi
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 1c             	sub    $0x1c,%esp
  8019ea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019ed:	89 34 24             	mov    %esi,(%esp)
  8019f0:	e8 6b f5 ff ff       	call   800f60 <fd2data>
  8019f5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019fc:	eb 3c                	jmp    801a3a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019fe:	89 da                	mov    %ebx,%edx
  801a00:	89 f0                	mov    %esi,%eax
  801a02:	e8 6c ff ff ff       	call   801973 <_pipeisclosed>
  801a07:	85 c0                	test   %eax,%eax
  801a09:	75 38                	jne    801a43 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a0b:	e8 b6 f2 ff ff       	call   800cc6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a10:	8b 43 04             	mov    0x4(%ebx),%eax
  801a13:	8b 13                	mov    (%ebx),%edx
  801a15:	83 c2 20             	add    $0x20,%edx
  801a18:	39 d0                	cmp    %edx,%eax
  801a1a:	73 e2                	jae    8019fe <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a22:	89 c2                	mov    %eax,%edx
  801a24:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a2a:	79 05                	jns    801a31 <devpipe_write+0x50>
  801a2c:	4a                   	dec    %edx
  801a2d:	83 ca e0             	or     $0xffffffe0,%edx
  801a30:	42                   	inc    %edx
  801a31:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a35:	40                   	inc    %eax
  801a36:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a39:	47                   	inc    %edi
  801a3a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a3d:	75 d1                	jne    801a10 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a3f:	89 f8                	mov    %edi,%eax
  801a41:	eb 05                	jmp    801a48 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a48:	83 c4 1c             	add    $0x1c,%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 1c             	sub    $0x1c,%esp
  801a59:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a5c:	89 3c 24             	mov    %edi,(%esp)
  801a5f:	e8 fc f4 ff ff       	call   800f60 <fd2data>
  801a64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a66:	be 00 00 00 00       	mov    $0x0,%esi
  801a6b:	eb 3a                	jmp    801aa7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a6d:	85 f6                	test   %esi,%esi
  801a6f:	74 04                	je     801a75 <devpipe_read+0x25>
				return i;
  801a71:	89 f0                	mov    %esi,%eax
  801a73:	eb 40                	jmp    801ab5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a75:	89 da                	mov    %ebx,%edx
  801a77:	89 f8                	mov    %edi,%eax
  801a79:	e8 f5 fe ff ff       	call   801973 <_pipeisclosed>
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	75 2e                	jne    801ab0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a82:	e8 3f f2 ff ff       	call   800cc6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a87:	8b 03                	mov    (%ebx),%eax
  801a89:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a8c:	74 df                	je     801a6d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a8e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a93:	79 05                	jns    801a9a <devpipe_read+0x4a>
  801a95:	48                   	dec    %eax
  801a96:	83 c8 e0             	or     $0xffffffe0,%eax
  801a99:	40                   	inc    %eax
  801a9a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801aa4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa6:	46                   	inc    %esi
  801aa7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aaa:	75 db                	jne    801a87 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aac:	89 f0                	mov    %esi,%eax
  801aae:	eb 05                	jmp    801ab5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ab5:	83 c4 1c             	add    $0x1c,%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	57                   	push   %edi
  801ac1:	56                   	push   %esi
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 3c             	sub    $0x3c,%esp
  801ac6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ac9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 a7 f4 ff ff       	call   800f7b <fd_alloc>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	0f 88 45 01 00 00    	js     801c23 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ade:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ae5:	00 
  801ae6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af4:	e8 ec f1 ff ff       	call   800ce5 <sys_page_alloc>
  801af9:	89 c3                	mov    %eax,%ebx
  801afb:	85 c0                	test   %eax,%eax
  801afd:	0f 88 20 01 00 00    	js     801c23 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b03:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b06:	89 04 24             	mov    %eax,(%esp)
  801b09:	e8 6d f4 ff ff       	call   800f7b <fd_alloc>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 f8 00 00 00    	js     801c10 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b1f:	00 
  801b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2e:	e8 b2 f1 ff ff       	call   800ce5 <sys_page_alloc>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	85 c0                	test   %eax,%eax
  801b37:	0f 88 d3 00 00 00    	js     801c10 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b40:	89 04 24             	mov    %eax,(%esp)
  801b43:	e8 18 f4 ff ff       	call   800f60 <fd2data>
  801b48:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b51:	00 
  801b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5d:	e8 83 f1 ff ff       	call   800ce5 <sys_page_alloc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	85 c0                	test   %eax,%eax
  801b66:	0f 88 91 00 00 00    	js     801bfd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b6f:	89 04 24             	mov    %eax,(%esp)
  801b72:	e8 e9 f3 ff ff       	call   800f60 <fd2data>
  801b77:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b7e:	00 
  801b7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b8a:	00 
  801b8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b96:	e8 9e f1 ff ff       	call   800d39 <sys_page_map>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 4c                	js     801bed <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ba1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ba7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801baa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801baf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bb6:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801bbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bbf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bc4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bce:	89 04 24             	mov    %eax,(%esp)
  801bd1:	e8 7a f3 ff ff       	call   800f50 <fd2num>
  801bd6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 6d f3 ff ff       	call   800f50 <fd2num>
  801be3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801be6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801beb:	eb 36                	jmp    801c23 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801bed:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf8:	e8 8f f1 ff ff       	call   800d8c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0b:	e8 7c f1 ff ff       	call   800d8c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1e:	e8 69 f1 ff ff       	call   800d8c <sys_page_unmap>
    err:
	return r;
}
  801c23:	89 d8                	mov    %ebx,%eax
  801c25:	83 c4 3c             	add    $0x3c,%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5f                   	pop    %edi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	89 04 24             	mov    %eax,(%esp)
  801c40:	e8 89 f3 ff ff       	call   800fce <fd_lookup>
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 15                	js     801c5e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 0c f3 ff ff       	call   800f60 <fd2data>
	return _pipeisclosed(fd, p);
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c59:	e8 15 fd ff ff       	call   801973 <_pipeisclosed>
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c70:	c7 44 24 04 6c 26 80 	movl   $0x80266c,0x4(%esp)
  801c77:	00 
  801c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7b:	89 04 24             	mov    %eax,(%esp)
  801c7e:	e8 70 ec ff ff       	call   8008f3 <strcpy>
	return 0;
}
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	57                   	push   %edi
  801c8e:	56                   	push   %esi
  801c8f:	53                   	push   %ebx
  801c90:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c96:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c9b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca1:	eb 30                	jmp    801cd3 <devcons_write+0x49>
		m = n - tot;
  801ca3:	8b 75 10             	mov    0x10(%ebp),%esi
  801ca6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801ca8:	83 fe 7f             	cmp    $0x7f,%esi
  801cab:	76 05                	jbe    801cb2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801cad:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cb2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cb6:	03 45 0c             	add    0xc(%ebp),%eax
  801cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbd:	89 3c 24             	mov    %edi,(%esp)
  801cc0:	e8 a7 ed ff ff       	call   800a6c <memmove>
		sys_cputs(buf, m);
  801cc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc9:	89 3c 24             	mov    %edi,(%esp)
  801ccc:	e8 47 ef ff ff       	call   800c18 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd1:	01 f3                	add    %esi,%ebx
  801cd3:	89 d8                	mov    %ebx,%eax
  801cd5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cd8:	72 c9                	jb     801ca3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cda:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ceb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cef:	75 07                	jne    801cf8 <devcons_read+0x13>
  801cf1:	eb 25                	jmp    801d18 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cf3:	e8 ce ef ff ff       	call   800cc6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cf8:	e8 39 ef ff ff       	call   800c36 <sys_cgetc>
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	74 f2                	je     801cf3 <devcons_read+0xe>
  801d01:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 1d                	js     801d24 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d07:	83 f8 04             	cmp    $0x4,%eax
  801d0a:	74 13                	je     801d1f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0f:	88 10                	mov    %dl,(%eax)
	return 1;
  801d11:	b8 01 00 00 00       	mov    $0x1,%eax
  801d16:	eb 0c                	jmp    801d24 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1d:	eb 05                	jmp    801d24 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d1f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d39:	00 
  801d3a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d3d:	89 04 24             	mov    %eax,(%esp)
  801d40:	e8 d3 ee ff ff       	call   800c18 <sys_cputs>
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <getchar>:

int
getchar(void)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d4d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d54:	00 
  801d55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d63:	e8 02 f5 ff ff       	call   80126a <read>
	if (r < 0)
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 0f                	js     801d7b <getchar+0x34>
		return r;
	if (r < 1)
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	7e 06                	jle    801d76 <getchar+0x2f>
		return -E_EOF;
	return c;
  801d70:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d74:	eb 05                	jmp    801d7b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d76:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 39 f2 ff ff       	call   800fce <fd_lookup>
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 11                	js     801daa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801da2:	39 10                	cmp    %edx,(%eax)
  801da4:	0f 94 c0             	sete   %al
  801da7:	0f b6 c0             	movzbl %al,%eax
}
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <opencons>:

int
opencons(void)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db5:	89 04 24             	mov    %eax,(%esp)
  801db8:	e8 be f1 ff ff       	call   800f7b <fd_alloc>
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	78 3c                	js     801dfd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dc8:	00 
  801dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd7:	e8 09 ef ff ff       	call   800ce5 <sys_page_alloc>
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 1d                	js     801dfd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df5:	89 04 24             	mov    %eax,(%esp)
  801df8:	e8 53 f1 ff ff       	call   800f50 <fd2num>
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    
	...

00801e00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	83 ec 10             	sub    $0x10,%esp
  801e08:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801e11:	85 c0                	test   %eax,%eax
  801e13:	75 05                	jne    801e1a <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801e15:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801e1a:	89 04 24             	mov    %eax,(%esp)
  801e1d:	e8 d9 f0 ff ff       	call   800efb <sys_ipc_recv>
	if (!err) {
  801e22:	85 c0                	test   %eax,%eax
  801e24:	75 26                	jne    801e4c <ipc_recv+0x4c>
		if (from_env_store) {
  801e26:	85 f6                	test   %esi,%esi
  801e28:	74 0a                	je     801e34 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801e2a:	a1 08 40 80 00       	mov    0x804008,%eax
  801e2f:	8b 40 74             	mov    0x74(%eax),%eax
  801e32:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801e34:	85 db                	test   %ebx,%ebx
  801e36:	74 0a                	je     801e42 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801e38:	a1 08 40 80 00       	mov    0x804008,%eax
  801e3d:	8b 40 78             	mov    0x78(%eax),%eax
  801e40:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801e42:	a1 08 40 80 00       	mov    0x804008,%eax
  801e47:	8b 40 70             	mov    0x70(%eax),%eax
  801e4a:	eb 14                	jmp    801e60 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801e4c:	85 f6                	test   %esi,%esi
  801e4e:	74 06                	je     801e56 <ipc_recv+0x56>
		*from_env_store = 0;
  801e50:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801e56:	85 db                	test   %ebx,%ebx
  801e58:	74 06                	je     801e60 <ipc_recv+0x60>
		*perm_store = 0;
  801e5a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	57                   	push   %edi
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 1c             	sub    $0x1c,%esp
  801e70:	8b 75 10             	mov    0x10(%ebp),%esi
  801e73:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801e76:	85 f6                	test   %esi,%esi
  801e78:	75 05                	jne    801e7f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801e7a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801e7f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e83:	89 74 24 08          	mov    %esi,0x8(%esp)
  801e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	89 04 24             	mov    %eax,(%esp)
  801e94:	e8 3f f0 ff ff       	call   800ed8 <sys_ipc_try_send>
  801e99:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801e9b:	e8 26 ee ff ff       	call   800cc6 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801ea0:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801ea3:	74 da                	je     801e7f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801ea5:	85 db                	test   %ebx,%ebx
  801ea7:	74 20                	je     801ec9 <ipc_send+0x62>
		panic("send fail: %e", err);
  801ea9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ead:	c7 44 24 08 78 26 80 	movl   $0x802678,0x8(%esp)
  801eb4:	00 
  801eb5:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801ebc:	00 
  801ebd:	c7 04 24 86 26 80 00 	movl   $0x802686,(%esp)
  801ec4:	e8 67 e3 ff ff       	call   800230 <_panic>
	}
	return;
}
  801ec9:	83 c4 1c             	add    $0x1c,%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	53                   	push   %ebx
  801ed5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801ed8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801edd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	c1 e2 07             	shl    $0x7,%edx
  801ee9:	29 ca                	sub    %ecx,%edx
  801eeb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ef1:	8b 52 50             	mov    0x50(%edx),%edx
  801ef4:	39 da                	cmp    %ebx,%edx
  801ef6:	75 0f                	jne    801f07 <ipc_find_env+0x36>
			return envs[i].env_id;
  801ef8:	c1 e0 07             	shl    $0x7,%eax
  801efb:	29 c8                	sub    %ecx,%eax
  801efd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f02:	8b 40 40             	mov    0x40(%eax),%eax
  801f05:	eb 0c                	jmp    801f13 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f07:	40                   	inc    %eax
  801f08:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f0d:	75 ce                	jne    801edd <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f0f:	66 b8 00 00          	mov    $0x0,%ax
}
  801f13:	5b                   	pop    %ebx
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    
	...

00801f18 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1e:	89 c2                	mov    %eax,%edx
  801f20:	c1 ea 16             	shr    $0x16,%edx
  801f23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f2a:	f6 c2 01             	test   $0x1,%dl
  801f2d:	74 1e                	je     801f4d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f2f:	c1 e8 0c             	shr    $0xc,%eax
  801f32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f39:	a8 01                	test   $0x1,%al
  801f3b:	74 17                	je     801f54 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f3d:	c1 e8 0c             	shr    $0xc,%eax
  801f40:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f47:	ef 
  801f48:	0f b7 c0             	movzwl %ax,%eax
  801f4b:	eb 0c                	jmp    801f59 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f52:	eb 05                	jmp    801f59 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    
	...

00801f5c <__udivdi3>:
  801f5c:	55                   	push   %ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	83 ec 10             	sub    $0x10,%esp
  801f62:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f66:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f72:	89 cd                	mov    %ecx,%ebp
  801f74:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	75 2c                	jne    801fa8 <__udivdi3+0x4c>
  801f7c:	39 f9                	cmp    %edi,%ecx
  801f7e:	77 68                	ja     801fe8 <__udivdi3+0x8c>
  801f80:	85 c9                	test   %ecx,%ecx
  801f82:	75 0b                	jne    801f8f <__udivdi3+0x33>
  801f84:	b8 01 00 00 00       	mov    $0x1,%eax
  801f89:	31 d2                	xor    %edx,%edx
  801f8b:	f7 f1                	div    %ecx
  801f8d:	89 c1                	mov    %eax,%ecx
  801f8f:	31 d2                	xor    %edx,%edx
  801f91:	89 f8                	mov    %edi,%eax
  801f93:	f7 f1                	div    %ecx
  801f95:	89 c7                	mov    %eax,%edi
  801f97:	89 f0                	mov    %esi,%eax
  801f99:	f7 f1                	div    %ecx
  801f9b:	89 c6                	mov    %eax,%esi
  801f9d:	89 f0                	mov    %esi,%eax
  801f9f:	89 fa                	mov    %edi,%edx
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
  801fa8:	39 f8                	cmp    %edi,%eax
  801faa:	77 2c                	ja     801fd8 <__udivdi3+0x7c>
  801fac:	0f bd f0             	bsr    %eax,%esi
  801faf:	83 f6 1f             	xor    $0x1f,%esi
  801fb2:	75 4c                	jne    802000 <__udivdi3+0xa4>
  801fb4:	39 f8                	cmp    %edi,%eax
  801fb6:	bf 00 00 00 00       	mov    $0x0,%edi
  801fbb:	72 0a                	jb     801fc7 <__udivdi3+0x6b>
  801fbd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801fc1:	0f 87 ad 00 00 00    	ja     802074 <__udivdi3+0x118>
  801fc7:	be 01 00 00 00       	mov    $0x1,%esi
  801fcc:	89 f0                	mov    %esi,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
  801fd7:	90                   	nop
  801fd8:	31 ff                	xor    %edi,%edi
  801fda:	31 f6                	xor    %esi,%esi
  801fdc:	89 f0                	mov    %esi,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    
  801fe7:	90                   	nop
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	89 f0                	mov    %esi,%eax
  801fec:	f7 f1                	div    %ecx
  801fee:	89 c6                	mov    %eax,%esi
  801ff0:	31 ff                	xor    %edi,%edi
  801ff2:	89 f0                	mov    %esi,%eax
  801ff4:	89 fa                	mov    %edi,%edx
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    
  801ffd:	8d 76 00             	lea    0x0(%esi),%esi
  802000:	89 f1                	mov    %esi,%ecx
  802002:	d3 e0                	shl    %cl,%eax
  802004:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802008:	b8 20 00 00 00       	mov    $0x20,%eax
  80200d:	29 f0                	sub    %esi,%eax
  80200f:	89 ea                	mov    %ebp,%edx
  802011:	88 c1                	mov    %al,%cl
  802013:	d3 ea                	shr    %cl,%edx
  802015:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802019:	09 ca                	or     %ecx,%edx
  80201b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80201f:	89 f1                	mov    %esi,%ecx
  802021:	d3 e5                	shl    %cl,%ebp
  802023:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802027:	89 fd                	mov    %edi,%ebp
  802029:	88 c1                	mov    %al,%cl
  80202b:	d3 ed                	shr    %cl,%ebp
  80202d:	89 fa                	mov    %edi,%edx
  80202f:	89 f1                	mov    %esi,%ecx
  802031:	d3 e2                	shl    %cl,%edx
  802033:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802037:	88 c1                	mov    %al,%cl
  802039:	d3 ef                	shr    %cl,%edi
  80203b:	09 d7                	or     %edx,%edi
  80203d:	89 f8                	mov    %edi,%eax
  80203f:	89 ea                	mov    %ebp,%edx
  802041:	f7 74 24 08          	divl   0x8(%esp)
  802045:	89 d1                	mov    %edx,%ecx
  802047:	89 c7                	mov    %eax,%edi
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d1                	cmp    %edx,%ecx
  80204f:	72 17                	jb     802068 <__udivdi3+0x10c>
  802051:	74 09                	je     80205c <__udivdi3+0x100>
  802053:	89 fe                	mov    %edi,%esi
  802055:	31 ff                	xor    %edi,%edi
  802057:	e9 41 ff ff ff       	jmp    801f9d <__udivdi3+0x41>
  80205c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802060:	89 f1                	mov    %esi,%ecx
  802062:	d3 e2                	shl    %cl,%edx
  802064:	39 c2                	cmp    %eax,%edx
  802066:	73 eb                	jae    802053 <__udivdi3+0xf7>
  802068:	8d 77 ff             	lea    -0x1(%edi),%esi
  80206b:	31 ff                	xor    %edi,%edi
  80206d:	e9 2b ff ff ff       	jmp    801f9d <__udivdi3+0x41>
  802072:	66 90                	xchg   %ax,%ax
  802074:	31 f6                	xor    %esi,%esi
  802076:	e9 22 ff ff ff       	jmp    801f9d <__udivdi3+0x41>
	...

0080207c <__umoddi3>:
  80207c:	55                   	push   %ebp
  80207d:	57                   	push   %edi
  80207e:	56                   	push   %esi
  80207f:	83 ec 20             	sub    $0x20,%esp
  802082:	8b 44 24 30          	mov    0x30(%esp),%eax
  802086:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80208a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80208e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802092:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802096:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80209a:	89 c7                	mov    %eax,%edi
  80209c:	89 f2                	mov    %esi,%edx
  80209e:	85 ed                	test   %ebp,%ebp
  8020a0:	75 16                	jne    8020b8 <__umoddi3+0x3c>
  8020a2:	39 f1                	cmp    %esi,%ecx
  8020a4:	0f 86 a6 00 00 00    	jbe    802150 <__umoddi3+0xd4>
  8020aa:	f7 f1                	div    %ecx
  8020ac:	89 d0                	mov    %edx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	83 c4 20             	add    $0x20,%esp
  8020b3:	5e                   	pop    %esi
  8020b4:	5f                   	pop    %edi
  8020b5:	5d                   	pop    %ebp
  8020b6:	c3                   	ret    
  8020b7:	90                   	nop
  8020b8:	39 f5                	cmp    %esi,%ebp
  8020ba:	0f 87 ac 00 00 00    	ja     80216c <__umoddi3+0xf0>
  8020c0:	0f bd c5             	bsr    %ebp,%eax
  8020c3:	83 f0 1f             	xor    $0x1f,%eax
  8020c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020ca:	0f 84 a8 00 00 00    	je     802178 <__umoddi3+0xfc>
  8020d0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020d4:	d3 e5                	shl    %cl,%ebp
  8020d6:	bf 20 00 00 00       	mov    $0x20,%edi
  8020db:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8020df:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020e3:	89 f9                	mov    %edi,%ecx
  8020e5:	d3 e8                	shr    %cl,%eax
  8020e7:	09 e8                	or     %ebp,%eax
  8020e9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8020ed:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020f1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020f5:	d3 e0                	shl    %cl,%eax
  8020f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fb:	89 f2                	mov    %esi,%edx
  8020fd:	d3 e2                	shl    %cl,%edx
  8020ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  802103:	d3 e0                	shl    %cl,%eax
  802105:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802109:	8b 44 24 14          	mov    0x14(%esp),%eax
  80210d:	89 f9                	mov    %edi,%ecx
  80210f:	d3 e8                	shr    %cl,%eax
  802111:	09 d0                	or     %edx,%eax
  802113:	d3 ee                	shr    %cl,%esi
  802115:	89 f2                	mov    %esi,%edx
  802117:	f7 74 24 18          	divl   0x18(%esp)
  80211b:	89 d6                	mov    %edx,%esi
  80211d:	f7 64 24 0c          	mull   0xc(%esp)
  802121:	89 c5                	mov    %eax,%ebp
  802123:	89 d1                	mov    %edx,%ecx
  802125:	39 d6                	cmp    %edx,%esi
  802127:	72 67                	jb     802190 <__umoddi3+0x114>
  802129:	74 75                	je     8021a0 <__umoddi3+0x124>
  80212b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80212f:	29 e8                	sub    %ebp,%eax
  802131:	19 ce                	sbb    %ecx,%esi
  802133:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 f2                	mov    %esi,%edx
  80213b:	89 f9                	mov    %edi,%ecx
  80213d:	d3 e2                	shl    %cl,%edx
  80213f:	09 d0                	or     %edx,%eax
  802141:	89 f2                	mov    %esi,%edx
  802143:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802147:	d3 ea                	shr    %cl,%edx
  802149:	83 c4 20             	add    $0x20,%esp
  80214c:	5e                   	pop    %esi
  80214d:	5f                   	pop    %edi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    
  802150:	85 c9                	test   %ecx,%ecx
  802152:	75 0b                	jne    80215f <__umoddi3+0xe3>
  802154:	b8 01 00 00 00       	mov    $0x1,%eax
  802159:	31 d2                	xor    %edx,%edx
  80215b:	f7 f1                	div    %ecx
  80215d:	89 c1                	mov    %eax,%ecx
  80215f:	89 f0                	mov    %esi,%eax
  802161:	31 d2                	xor    %edx,%edx
  802163:	f7 f1                	div    %ecx
  802165:	89 f8                	mov    %edi,%eax
  802167:	e9 3e ff ff ff       	jmp    8020aa <__umoddi3+0x2e>
  80216c:	89 f2                	mov    %esi,%edx
  80216e:	83 c4 20             	add    $0x20,%esp
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi
  802178:	39 f5                	cmp    %esi,%ebp
  80217a:	72 04                	jb     802180 <__umoddi3+0x104>
  80217c:	39 f9                	cmp    %edi,%ecx
  80217e:	77 06                	ja     802186 <__umoddi3+0x10a>
  802180:	89 f2                	mov    %esi,%edx
  802182:	29 cf                	sub    %ecx,%edi
  802184:	19 ea                	sbb    %ebp,%edx
  802186:	89 f8                	mov    %edi,%eax
  802188:	83 c4 20             	add    $0x20,%esp
  80218b:	5e                   	pop    %esi
  80218c:	5f                   	pop    %edi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
  80218f:	90                   	nop
  802190:	89 d1                	mov    %edx,%ecx
  802192:	89 c5                	mov    %eax,%ebp
  802194:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802198:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80219c:	eb 8d                	jmp    80212b <__umoddi3+0xaf>
  80219e:	66 90                	xchg   %ax,%ax
  8021a0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8021a4:	72 ea                	jb     802190 <__umoddi3+0x114>
  8021a6:	89 f1                	mov    %esi,%ecx
  8021a8:	eb 81                	jmp    80212b <__umoddi3+0xaf>
