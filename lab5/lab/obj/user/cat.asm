
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 33 01 00 00       	call   800164 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 40                	jmp    800085 <cat+0x51>
		if ((r = write(1, buf, n)) != n)
  800045:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800049:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800050:	00 
  800051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800058:	e8 8c 12 00 00       	call   8012e9 <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 60 21 80 	movl   $0x802160,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 7b 21 80 00 	movl   $0x80217b,(%esp)
  800080:	e8 4f 01 00 00       	call   8001d4 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800085:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800094:	00 
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 71 11 00 00       	call   80120e <read>
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	85 c0                	test   %eax,%eax
  8000a1:	7f a2                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 24                	jns    8000cb <cat+0x97>
		panic("error reading %s: %e", s, n);
  8000a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	c7 44 24 08 86 21 80 	movl   $0x802186,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 7b 21 80 00 	movl   $0x80217b,(%esp)
  8000c6:	e8 09 01 00 00       	call   8001d4 <_panic>
}
  8000cb:	83 c4 2c             	add    $0x2c,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 9b 	movl   $0x80219b,0x803000
  8000e6:	21 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	75 62                	jne    800151 <umain+0x7e>
		cat(0, "<stdin>");
  8000ef:	c7 44 24 04 9f 21 80 	movl   $0x80219f,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fe:	e8 31 ff ff ff       	call   800034 <cat>
  800103:	eb 56                	jmp    80015b <umain+0x88>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010c:	00 
  80010d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 9d 15 00 00       	call   8016b5 <open>
  800118:	89 c7                	mov    %eax,%edi
			if (f < 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	79 19                	jns    800137 <umain+0x64>
				printf("can't open %s: %e\n", argv[i], f);
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  800130:	e8 34 17 00 00       	call   801869 <printf>
  800135:	eb 17                	jmp    80014e <umain+0x7b>
			else {
				cat(f, argv[i]);
  800137:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 3c 24             	mov    %edi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <cat>
				close(f);
  800146:	89 3c 24             	mov    %edi,(%esp)
  800149:	e8 5c 0f 00 00       	call   8010aa <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80014e:	43                   	inc    %ebx
  80014f:	eb 05                	jmp    800156 <umain+0x83>
umain(int argc, char **argv)
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
  800151:	bb 01 00 00 00       	mov    $0x1,%ebx
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800156:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800159:	7c aa                	jl     800105 <umain+0x32>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015b:	83 c4 1c             	add    $0x1c,%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 10             	sub    $0x10,%esp
  80016c:	8b 75 08             	mov    0x8(%ebp),%esi
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800172:	e8 d4 0a 00 00       	call   800c4b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800177:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800183:	c1 e0 07             	shl    $0x7,%eax
  800186:	29 d0                	sub    %edx,%eax
  800188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018d:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800192:	85 f6                	test   %esi,%esi
  800194:	7e 07                	jle    80019d <libmain+0x39>
		binaryname = argv[0];
  800196:	8b 03                	mov    (%ebx),%eax
  800198:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80019d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 2a ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a9:	e8 0a 00 00 00       	call   8001b8 <exit>
}
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001be:	e8 18 0f 00 00       	call   8010db <close_all>
	sys_env_destroy(0);
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	e8 2a 0a 00 00       	call   800bf9 <sys_env_destroy>
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    
  8001d1:	00 00                	add    %al,(%eax)
	...

008001d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001dc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001df:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e5:	e8 61 0a 00 00       	call   800c4b <sys_getenvid>
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800200:	c7 04 24 c4 21 80 00 	movl   $0x8021c4,(%esp)
  800207:	e8 c0 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 50 00 00 00       	call   80026b <vcprintf>
	cprintf("\n");
  80021b:	c7 04 24 05 26 80 00 	movl   $0x802605,(%esp)
  800222:	e8 a5 00 00 00       	call   8002cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800227:	cc                   	int3   
  800228:	eb fd                	jmp    800227 <_panic+0x53>
	...

0080022c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	53                   	push   %ebx
  800230:	83 ec 14             	sub    $0x14,%esp
  800233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800236:	8b 03                	mov    (%ebx),%eax
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023f:	40                   	inc    %eax
  800240:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800242:	3d ff 00 00 00       	cmp    $0xff,%eax
  800247:	75 19                	jne    800262 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800249:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800250:	00 
  800251:	8d 43 08             	lea    0x8(%ebx),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 60 09 00 00       	call   800bbc <sys_cputs>
		b->idx = 0;
  80025c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800262:	ff 43 04             	incl   0x4(%ebx)
}
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	5b                   	pop    %ebx
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800274:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027b:	00 00 00 
	b.cnt = 0;
  80027e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800285:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	89 44 24 08          	mov    %eax,0x8(%esp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	c7 04 24 2c 02 80 00 	movl   $0x80022c,(%esp)
  8002a7:	e8 82 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 f8 08 00 00       	call   800bbc <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 87 ff ff ff       	call   80026b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
	...

008002e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 3c             	sub    $0x3c,%esp
  8002f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f4:	89 d7                	mov    %edx,%edi
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800302:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800305:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800308:	85 c0                	test   %eax,%eax
  80030a:	75 08                	jne    800314 <printnum+0x2c>
  80030c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800312:	77 57                	ja     80036b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 74 24 10          	mov    %esi,0x10(%esp)
  800318:	4b                   	dec    %ebx
  800319:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031d:	8b 45 10             	mov    0x10(%ebp),%eax
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800328:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80032c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800333:	00 
  800334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	e8 ba 1b 00 00       	call   801f00 <__udivdi3>
  800346:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	89 54 24 04          	mov    %edx,0x4(%esp)
  800355:	89 fa                	mov    %edi,%edx
  800357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035a:	e8 89 ff ff ff       	call   8002e8 <printnum>
  80035f:	eb 0f                	jmp    800370 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800361:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036b:	4b                   	dec    %ebx
  80036c:	85 db                	test   %ebx,%ebx
  80036e:	7f f1                	jg     800361 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800370:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800374:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800378:	8b 45 10             	mov    0x10(%ebp),%eax
  80037b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800386:	00 
  800387:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	e8 87 1c 00 00       	call   802020 <__umoddi3>
  800399:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039d:	0f be 80 e7 21 80 00 	movsbl 0x8021e7(%eax),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003aa:	83 c4 3c             	add    $0x3c,%esp
  8003ad:	5b                   	pop    %ebx
  8003ae:	5e                   	pop    %esi
  8003af:	5f                   	pop    %edi
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b5:	83 fa 01             	cmp    $0x1,%edx
  8003b8:	7e 0e                	jle    8003c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bf:	89 08                	mov    %ecx,(%eax)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	8b 52 04             	mov    0x4(%edx),%edx
  8003c6:	eb 22                	jmp    8003ea <getuint+0x38>
	else if (lflag)
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	74 10                	je     8003dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003da:	eb 0e                	jmp    8003ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fa:	73 08                	jae    800404 <sprintputch+0x18>
		*b->buf++ = ch;
  8003fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ff:	88 0a                	mov    %cl,(%edx)
  800401:	42                   	inc    %edx
  800402:	89 10                	mov    %edx,(%eax)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
	va_end(ap);
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 4c             	sub    $0x4c,%esp
  800437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043a:	8b 75 10             	mov    0x10(%ebp),%esi
  80043d:	eb 12                	jmp    800451 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043f:	85 c0                	test   %eax,%eax
  800441:	0f 84 8b 03 00 00    	je     8007d2 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800447:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	0f b6 06             	movzbl (%esi),%eax
  800454:	46                   	inc    %esi
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e5                	jne    80043f <vprintfmt+0x11>
  80045a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80045e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800465:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80046a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800471:	b9 00 00 00 00       	mov    $0x0,%ecx
  800476:	eb 26                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80047f:	eb 1d                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800484:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800488:	eb 14                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80048d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800494:	eb 08                	jmp    80049e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800496:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800499:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	0f b6 06             	movzbl (%esi),%eax
  8004a1:	8d 56 01             	lea    0x1(%esi),%edx
  8004a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a7:	8a 16                	mov    (%esi),%dl
  8004a9:	83 ea 23             	sub    $0x23,%edx
  8004ac:	80 fa 55             	cmp    $0x55,%dl
  8004af:	0f 87 01 03 00 00    	ja     8007b6 <vprintfmt+0x388>
  8004b5:	0f b6 d2             	movzbl %dl,%edx
  8004b8:	ff 24 95 20 23 80 00 	jmp    *0x802320(,%edx,4)
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ca:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ce:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d4:	83 fa 09             	cmp    $0x9,%edx
  8004d7:	77 2a                	ja     800503 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004da:	eb eb                	jmp    8004c7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ea:	eb 17                	jmp    800503 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f0:	78 98                	js     80048a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f5:	eb a7                	jmp    80049e <vprintfmt+0x70>
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800501:	eb 9b                	jmp    80049e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800503:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800507:	79 95                	jns    80049e <vprintfmt+0x70>
  800509:	eb 8b                	jmp    800496 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050f:	eb 8d                	jmp    80049e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800529:	e9 23 ff ff ff       	jmp    800451 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	85 c0                	test   %eax,%eax
  80053b:	79 02                	jns    80053f <vprintfmt+0x111>
  80053d:	f7 d8                	neg    %eax
  80053f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 0f             	cmp    $0xf,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x123>
  800546:	8b 04 85 80 24 80 00 	mov    0x802480(,%eax,4),%eax
  80054d:	85 c0                	test   %eax,%eax
  80054f:	75 23                	jne    800574 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800551:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800555:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  80055c:	00 
  80055d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	e8 9a fe ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 dd fe ff ff       	jmp    800451 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800578:	c7 44 24 08 de 25 80 	movl   $0x8025de,0x8(%esp)
  80057f:	00 
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	8b 55 08             	mov    0x8(%ebp),%edx
  800587:	89 14 24             	mov    %edx,(%esp)
  80058a:	e8 77 fe ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800592:	e9 ba fe ff ff       	jmp    800451 <vprintfmt+0x23>
  800597:	89 f9                	mov    %edi,%ecx
  800599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 30                	mov    (%eax),%esi
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	75 05                	jne    8005b3 <vprintfmt+0x185>
				p = "(null)";
  8005ae:	be f8 21 80 00       	mov    $0x8021f8,%esi
			if (width > 0 && padc != '-')
  8005b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b7:	0f 8e 84 00 00 00    	jle    800641 <vprintfmt+0x213>
  8005bd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c1:	74 7e                	je     800641 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c7:	89 34 24             	mov    %esi,(%esp)
  8005ca:	e8 ab 02 00 00       	call   80087a <strnlen>
  8005cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d2:	29 c2                	sub    %eax,%edx
  8005d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005d7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005db:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005de:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005e1:	89 de                	mov    %ebx,%esi
  8005e3:	89 d3                	mov    %edx,%ebx
  8005e5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	eb 0b                	jmp    8005f4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ed:	89 3c 24             	mov    %edi,(%esp)
  8005f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f f1                	jg     8005e9 <vprintfmt+0x1bb>
  8005f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005fb:	89 f3                	mov    %esi,%ebx
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	79 05                	jns    80060c <vprintfmt+0x1de>
  800607:	b8 00 00 00 00       	mov    $0x0,%eax
  80060c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060f:	29 c2                	sub    %eax,%edx
  800611:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800614:	eb 2b                	jmp    800641 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	74 18                	je     800634 <vprintfmt+0x206>
  80061c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061f:	83 fa 5e             	cmp    $0x5e,%edx
  800622:	76 10                	jbe    800634 <vprintfmt+0x206>
					putch('?', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
  800632:	eb 0a                	jmp    80063e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063e:	ff 4d e4             	decl   -0x1c(%ebp)
  800641:	0f be 06             	movsbl (%esi),%eax
  800644:	46                   	inc    %esi
  800645:	85 c0                	test   %eax,%eax
  800647:	74 21                	je     80066a <vprintfmt+0x23c>
  800649:	85 ff                	test   %edi,%edi
  80064b:	78 c9                	js     800616 <vprintfmt+0x1e8>
  80064d:	4f                   	dec    %edi
  80064e:	79 c6                	jns    800616 <vprintfmt+0x1e8>
  800650:	8b 7d 08             	mov    0x8(%ebp),%edi
  800653:	89 de                	mov    %ebx,%esi
  800655:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800665:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	4b                   	dec    %ebx
  800668:	eb 08                	jmp    800672 <vprintfmt+0x244>
  80066a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066d:	89 de                	mov    %ebx,%esi
  80066f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800672:	85 db                	test   %ebx,%ebx
  800674:	7f e4                	jg     80065a <vprintfmt+0x22c>
  800676:	89 7d 08             	mov    %edi,0x8(%ebp)
  800679:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067e:	e9 ce fd ff ff       	jmp    800451 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800683:	83 f9 01             	cmp    $0x1,%ecx
  800686:	7e 10                	jle    800698 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 08             	lea    0x8(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 30                	mov    (%eax),%esi
  800693:	8b 78 04             	mov    0x4(%eax),%edi
  800696:	eb 26                	jmp    8006be <vprintfmt+0x290>
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 12                	je     8006ae <vprintfmt+0x280>
		return va_arg(*ap, long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 30                	mov    (%eax),%esi
  8006a7:	89 f7                	mov    %esi,%edi
  8006a9:	c1 ff 1f             	sar    $0x1f,%edi
  8006ac:	eb 10                	jmp    8006be <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 30                	mov    (%eax),%esi
  8006b9:	89 f7                	mov    %esi,%edi
  8006bb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	78 0a                	js     8006cc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	e9 ac 00 00 00       	jmp    800778 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006da:	f7 de                	neg    %esi
  8006dc:	83 d7 00             	adc    $0x0,%edi
  8006df:	f7 df                	neg    %edi
			}
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e6:	e9 8d 00 00 00       	jmp    800778 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006eb:	89 ca                	mov    %ecx,%edx
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 bd fc ff ff       	call   8003b2 <getuint>
  8006f5:	89 c6                	mov    %eax,%esi
  8006f7:	89 d7                	mov    %edx,%edi
			base = 10;
  8006f9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006fe:	eb 78                	jmp    800778 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80072d:	e9 1f fd ff ff       	jmp    800451 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800744:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8d 50 04             	lea    0x4(%eax),%edx
  800754:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800757:	8b 30                	mov    (%eax),%esi
  800759:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800763:	eb 13                	jmp    800778 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800765:	89 ca                	mov    %ecx,%edx
  800767:	8d 45 14             	lea    0x14(%ebp),%eax
  80076a:	e8 43 fc ff ff       	call   8003b2 <getuint>
  80076f:	89 c6                	mov    %eax,%esi
  800771:	89 d7                	mov    %edx,%edi
			base = 16;
  800773:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800778:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80077c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800780:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800783:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800787:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078b:	89 34 24             	mov    %esi,(%esp)
  80078e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800792:	89 da                	mov    %ebx,%edx
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	e8 4c fb ff ff       	call   8002e8 <printnum>
			break;
  80079c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80079f:	e9 ad fc ff ff       	jmp    800451 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b1:	e9 9b fc ff ff       	jmp    800451 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ba:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c4:	eb 01                	jmp    8007c7 <vprintfmt+0x399>
  8007c6:	4e                   	dec    %esi
  8007c7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007cb:	75 f9                	jne    8007c6 <vprintfmt+0x398>
  8007cd:	e9 7f fc ff ff       	jmp    800451 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d2:	83 c4 4c             	add    $0x4c,%esp
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5f                   	pop    %edi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	83 ec 28             	sub    $0x28,%esp
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	74 30                	je     80082b <vsnprintf+0x51>
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	7e 33                	jle    800832 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800806:	8b 45 10             	mov    0x10(%ebp),%eax
  800809:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	c7 04 24 ec 03 80 00 	movl   $0x8003ec,(%esp)
  80081b:	e8 0e fc ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800820:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800823:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800826:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800829:	eb 0c                	jmp    800837 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800830:	eb 05                	jmp    800837 <vsnprintf+0x5d>
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800850:	89 44 24 04          	mov    %eax,0x4(%esp)
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 7b ff ff ff       	call   8007da <vsnprintf>
	va_end(ap);

	return rc;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    
  800861:	00 00                	add    %al,(%eax)
	...

00800864 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	eb 01                	jmp    800872 <strlen+0xe>
		n++;
  800871:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800872:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800876:	75 f9                	jne    800871 <strlen+0xd>
		n++;
	return n;
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	eb 01                	jmp    80088b <strnlen+0x11>
		n++;
  80088a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1b>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f5                	jne    80088a <strnlen+0x10>
		n++;
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008a9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008ac:	42                   	inc    %edx
  8008ad:	84 c9                	test   %cl,%cl
  8008af:	75 f5                	jne    8008a6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008be:	89 1c 24             	mov    %ebx,(%esp)
  8008c1:	e8 9e ff ff ff       	call   800864 <strlen>
	strcpy(dst + len, src);
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008cd:	01 d8                	add    %ebx,%eax
  8008cf:	89 04 24             	mov    %eax,(%esp)
  8008d2:	e8 c0 ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008d7:	89 d8                	mov    %ebx,%eax
  8008d9:	83 c4 08             	add    $0x8,%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f2:	eb 0c                	jmp    800900 <strncpy+0x21>
		*dst++ = *src;
  8008f4:	8a 1a                	mov    (%edx),%bl
  8008f6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008fc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ff:	41                   	inc    %ecx
  800900:	39 f1                	cmp    %esi,%ecx
  800902:	75 f0                	jne    8008f4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800916:	85 d2                	test   %edx,%edx
  800918:	75 0a                	jne    800924 <strlcpy+0x1c>
  80091a:	89 f0                	mov    %esi,%eax
  80091c:	eb 1a                	jmp    800938 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091e:	88 18                	mov    %bl,(%eax)
  800920:	40                   	inc    %eax
  800921:	41                   	inc    %ecx
  800922:	eb 02                	jmp    800926 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800924:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800926:	4a                   	dec    %edx
  800927:	74 0a                	je     800933 <strlcpy+0x2b>
  800929:	8a 19                	mov    (%ecx),%bl
  80092b:	84 db                	test   %bl,%bl
  80092d:	75 ef                	jne    80091e <strlcpy+0x16>
  80092f:	89 c2                	mov    %eax,%edx
  800931:	eb 02                	jmp    800935 <strlcpy+0x2d>
  800933:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 02                	jmp    80094b <strcmp+0xd>
		p++, q++;
  800949:	41                   	inc    %ecx
  80094a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094b:	8a 01                	mov    (%ecx),%al
  80094d:	84 c0                	test   %al,%al
  80094f:	74 04                	je     800955 <strcmp+0x17>
  800951:	3a 02                	cmp    (%edx),%al
  800953:	74 f4                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800955:	0f b6 c0             	movzbl %al,%eax
  800958:	0f b6 12             	movzbl (%edx),%edx
  80095b:	29 d0                	sub    %edx,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800969:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80096c:	eb 03                	jmp    800971 <strncmp+0x12>
		n--, p++, q++;
  80096e:	4a                   	dec    %edx
  80096f:	40                   	inc    %eax
  800970:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800971:	85 d2                	test   %edx,%edx
  800973:	74 14                	je     800989 <strncmp+0x2a>
  800975:	8a 18                	mov    (%eax),%bl
  800977:	84 db                	test   %bl,%bl
  800979:	74 04                	je     80097f <strncmp+0x20>
  80097b:	3a 19                	cmp    (%ecx),%bl
  80097d:	74 ef                	je     80096e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097f:	0f b6 00             	movzbl (%eax),%eax
  800982:	0f b6 11             	movzbl (%ecx),%edx
  800985:	29 d0                	sub    %edx,%eax
  800987:	eb 05                	jmp    80098e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098e:	5b                   	pop    %ebx
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099a:	eb 05                	jmp    8009a1 <strchr+0x10>
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	74 0c                	je     8009ac <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a0:	40                   	inc    %eax
  8009a1:	8a 10                	mov    (%eax),%dl
  8009a3:	84 d2                	test   %dl,%dl
  8009a5:	75 f5                	jne    80099c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009b7:	eb 05                	jmp    8009be <strfind+0x10>
		if (*s == c)
  8009b9:	38 ca                	cmp    %cl,%dl
  8009bb:	74 07                	je     8009c4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009bd:	40                   	inc    %eax
  8009be:	8a 10                	mov    (%eax),%dl
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f5                	jne    8009b9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	74 30                	je     800a09 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009df:	75 25                	jne    800a06 <memset+0x40>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 20                	jne    800a06 <memset+0x40>
		c &= 0xFF;
  8009e6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e9:	89 d3                	mov    %edx,%ebx
  8009eb:	c1 e3 08             	shl    $0x8,%ebx
  8009ee:	89 d6                	mov    %edx,%esi
  8009f0:	c1 e6 18             	shl    $0x18,%esi
  8009f3:	89 d0                	mov    %edx,%eax
  8009f5:	c1 e0 10             	shl    $0x10,%eax
  8009f8:	09 f0                	or     %esi,%eax
  8009fa:	09 d0                	or     %edx,%eax
  8009fc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a01:	fc                   	cld    
  800a02:	f3 ab                	rep stos %eax,%es:(%edi)
  800a04:	eb 03                	jmp    800a09 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a06:	fc                   	cld    
  800a07:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a09:	89 f8                	mov    %edi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5f                   	pop    %edi
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1e:	39 c6                	cmp    %eax,%esi
  800a20:	73 34                	jae    800a56 <memmove+0x46>
  800a22:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 2d                	jae    800a56 <memmove+0x46>
		s += n;
		d += n;
  800a29:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2c:	f6 c2 03             	test   $0x3,%dl
  800a2f:	75 1b                	jne    800a4c <memmove+0x3c>
  800a31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a37:	75 13                	jne    800a4c <memmove+0x3c>
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 0e                	jne    800a4c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3e:	83 ef 04             	sub    $0x4,%edi
  800a41:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a44:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a47:	fd                   	std    
  800a48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4a:	eb 07                	jmp    800a53 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4c:	4f                   	dec    %edi
  800a4d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a50:	fd                   	std    
  800a51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a53:	fc                   	cld    
  800a54:	eb 20                	jmp    800a76 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5c:	75 13                	jne    800a71 <memmove+0x61>
  800a5e:	a8 03                	test   $0x3,%al
  800a60:	75 0f                	jne    800a71 <memmove+0x61>
  800a62:	f6 c1 03             	test   $0x3,%cl
  800a65:	75 0a                	jne    800a71 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a67:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a6a:	89 c7                	mov    %eax,%edi
  800a6c:	fc                   	cld    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 05                	jmp    800a76 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	fc                   	cld    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a80:	8b 45 10             	mov    0x10(%ebp),%eax
  800a83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	89 04 24             	mov    %eax,(%esp)
  800a94:	e8 77 ff ff ff       	call   800a10 <memmove>
}
  800a99:	c9                   	leave  
  800a9a:	c3                   	ret    

00800a9b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaf:	eb 16                	jmp    800ac7 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ab4:	42                   	inc    %edx
  800ab5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ab9:	38 c8                	cmp    %cl,%al
  800abb:	74 0a                	je     800ac7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c0             	movzbl %al,%eax
  800ac0:	0f b6 c9             	movzbl %cl,%ecx
  800ac3:	29 c8                	sub    %ecx,%eax
  800ac5:	eb 09                	jmp    800ad0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac7:	39 da                	cmp    %ebx,%edx
  800ac9:	75 e6                	jne    800ab1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ade:	89 c2                	mov    %eax,%edx
  800ae0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae3:	eb 05                	jmp    800aea <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae5:	38 08                	cmp    %cl,(%eax)
  800ae7:	74 05                	je     800aee <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae9:	40                   	inc    %eax
  800aea:	39 d0                	cmp    %edx,%eax
  800aec:	72 f7                	jb     800ae5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afc:	eb 01                	jmp    800aff <strtol+0xf>
		s++;
  800afe:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	8a 02                	mov    (%edx),%al
  800b01:	3c 20                	cmp    $0x20,%al
  800b03:	74 f9                	je     800afe <strtol+0xe>
  800b05:	3c 09                	cmp    $0x9,%al
  800b07:	74 f5                	je     800afe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b09:	3c 2b                	cmp    $0x2b,%al
  800b0b:	75 08                	jne    800b15 <strtol+0x25>
		s++;
  800b0d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b13:	eb 13                	jmp    800b28 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b15:	3c 2d                	cmp    $0x2d,%al
  800b17:	75 0a                	jne    800b23 <strtol+0x33>
		s++, neg = 1;
  800b19:	8d 52 01             	lea    0x1(%edx),%edx
  800b1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b21:	eb 05                	jmp    800b28 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	74 05                	je     800b31 <strtol+0x41>
  800b2c:	83 fb 10             	cmp    $0x10,%ebx
  800b2f:	75 28                	jne    800b59 <strtol+0x69>
  800b31:	8a 02                	mov    (%edx),%al
  800b33:	3c 30                	cmp    $0x30,%al
  800b35:	75 10                	jne    800b47 <strtol+0x57>
  800b37:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3b:	75 0a                	jne    800b47 <strtol+0x57>
		s += 2, base = 16;
  800b3d:	83 c2 02             	add    $0x2,%edx
  800b40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b45:	eb 12                	jmp    800b59 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b47:	85 db                	test   %ebx,%ebx
  800b49:	75 0e                	jne    800b59 <strtol+0x69>
  800b4b:	3c 30                	cmp    $0x30,%al
  800b4d:	75 05                	jne    800b54 <strtol+0x64>
		s++, base = 8;
  800b4f:	42                   	inc    %edx
  800b50:	b3 08                	mov    $0x8,%bl
  800b52:	eb 05                	jmp    800b59 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b54:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b59:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b60:	8a 0a                	mov    (%edx),%cl
  800b62:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b65:	80 fb 09             	cmp    $0x9,%bl
  800b68:	77 08                	ja     800b72 <strtol+0x82>
			dig = *s - '0';
  800b6a:	0f be c9             	movsbl %cl,%ecx
  800b6d:	83 e9 30             	sub    $0x30,%ecx
  800b70:	eb 1e                	jmp    800b90 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b72:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b75:	80 fb 19             	cmp    $0x19,%bl
  800b78:	77 08                	ja     800b82 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b7a:	0f be c9             	movsbl %cl,%ecx
  800b7d:	83 e9 57             	sub    $0x57,%ecx
  800b80:	eb 0e                	jmp    800b90 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b82:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b85:	80 fb 19             	cmp    $0x19,%bl
  800b88:	77 12                	ja     800b9c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b8a:	0f be c9             	movsbl %cl,%ecx
  800b8d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b90:	39 f1                	cmp    %esi,%ecx
  800b92:	7d 0c                	jge    800ba0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b94:	42                   	inc    %edx
  800b95:	0f af c6             	imul   %esi,%eax
  800b98:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb c4                	jmp    800b60 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b9c:	89 c1                	mov    %eax,%ecx
  800b9e:	eb 02                	jmp    800ba2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba6:	74 05                	je     800bad <strtol+0xbd>
		*endptr = (char *) s;
  800ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bab:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bad:	85 ff                	test   %edi,%edi
  800baf:	74 04                	je     800bb5 <strtol+0xc5>
  800bb1:	89 c8                	mov    %ecx,%eax
  800bb3:	f7 d8                	neg    %eax
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    
	...

00800bbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 c3                	mov    %eax,%ebx
  800bcf:	89 c7                	mov    %eax,%edi
  800bd1:	89 c6                	mov    %eax,%esi
  800bd3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_cgetc>:

int
sys_cgetc(void)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 cb                	mov    %ecx,%ebx
  800c11:	89 cf                	mov    %ecx,%edi
  800c13:	89 ce                	mov    %ecx,%esi
  800c15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	7e 28                	jle    800c43 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c26:	00 
  800c27:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800c2e:	00 
  800c2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c36:	00 
  800c37:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800c3e:	e8 91 f5 ff ff       	call   8001d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c43:	83 c4 2c             	add    $0x2c,%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5b:	89 d1                	mov    %edx,%ecx
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	89 d7                	mov    %edx,%edi
  800c61:	89 d6                	mov    %edx,%esi
  800c63:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_yield>:

void
sys_yield(void)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7a:	89 d1                	mov    %edx,%ecx
  800c7c:	89 d3                	mov    %edx,%ebx
  800c7e:	89 d7                	mov    %edx,%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	be 00 00 00 00       	mov    $0x0,%esi
  800c97:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 f7                	mov    %esi,%edi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 28                	jle    800cd5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc8:	00 
  800cc9:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800cd0:	e8 ff f4 ff ff       	call   8001d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd5:	83 c4 2c             	add    $0x2c,%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ceb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 28                	jle    800d28 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d04:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800d13:	00 
  800d14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1b:	00 
  800d1c:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800d23:	e8 ac f4 ff ff       	call   8001d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d28:	83 c4 2c             	add    $0x2c,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 28                	jle    800d7b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d57:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800d66:	00 
  800d67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6e:	00 
  800d6f:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800d76:	e8 59 f4 ff ff       	call   8001d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7b:	83 c4 2c             	add    $0x2c,%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 08 00 00 00       	mov    $0x8,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 28                	jle    800dce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc1:	00 
  800dc2:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800dc9:	e8 06 f4 ff ff       	call   8001d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dce:	83 c4 2c             	add    $0x2c,%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de4:	b8 09 00 00 00       	mov    $0x9,%eax
  800de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	89 df                	mov    %ebx,%edi
  800df1:	89 de                	mov    %ebx,%esi
  800df3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7e 28                	jle    800e21 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e04:	00 
  800e05:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800e0c:	00 
  800e0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e14:	00 
  800e15:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800e1c:	e8 b3 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e21:	83 c4 2c             	add    $0x2c,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e37:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 df                	mov    %ebx,%edi
  800e44:	89 de                	mov    %ebx,%esi
  800e46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7e 28                	jle    800e74 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e50:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e57:	00 
  800e58:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800e5f:	00 
  800e60:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e67:	00 
  800e68:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800e6f:	e8 60 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e74:	83 c4 2c             	add    $0x2c,%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e82:	be 00 00 00 00       	mov    $0x0,%esi
  800e87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ead:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 cb                	mov    %ecx,%ebx
  800eb7:	89 cf                	mov    %ecx,%edi
  800eb9:	89 ce                	mov    %ecx,%esi
  800ebb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7e 28                	jle    800ee9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edc:	00 
  800edd:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800ee4:	e8 eb f2 ff ff       	call   8001d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee9:	83 c4 2c             	add    $0x2c,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    
  800ef1:	00 00                	add    %al,(%eax)
	...

00800ef4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	05 00 00 00 30       	add    $0x30000000,%eax
  800eff:	c1 e8 0c             	shr    $0xc,%eax
}
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	89 04 24             	mov    %eax,(%esp)
  800f10:	e8 df ff ff ff       	call   800ef4 <fd2num>
  800f15:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f1a:	c1 e0 0c             	shl    $0xc,%eax
}
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	53                   	push   %ebx
  800f23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f26:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f2b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 16             	shr    $0x16,%edx
  800f32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 11                	je     800f4f <fd_alloc+0x30>
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 0c             	shr    $0xc,%edx
  800f43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	75 09                	jne    800f58 <fd_alloc+0x39>
			*fd_store = fd;
  800f4f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	eb 17                	jmp    800f6f <fd_alloc+0x50>
  800f58:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f5d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f62:	75 c7                	jne    800f2b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f64:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f6a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f6f:	5b                   	pop    %ebx
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f78:	83 f8 1f             	cmp    $0x1f,%eax
  800f7b:	77 36                	ja     800fb3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f7d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f82:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f85:	89 c2                	mov    %eax,%edx
  800f87:	c1 ea 16             	shr    $0x16,%edx
  800f8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f91:	f6 c2 01             	test   $0x1,%dl
  800f94:	74 24                	je     800fba <fd_lookup+0x48>
  800f96:	89 c2                	mov    %eax,%edx
  800f98:	c1 ea 0c             	shr    $0xc,%edx
  800f9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa2:	f6 c2 01             	test   $0x1,%dl
  800fa5:	74 1a                	je     800fc1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800faa:	89 02                	mov    %eax,(%edx)
	return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	eb 13                	jmp    800fc6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb8:	eb 0c                	jmp    800fc6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fbf:	eb 05                	jmp    800fc6 <fd_lookup+0x54>
  800fc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 14             	sub    $0x14,%esp
  800fcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fda:	eb 0e                	jmp    800fea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fdc:	39 08                	cmp    %ecx,(%eax)
  800fde:	75 09                	jne    800fe9 <dev_lookup+0x21>
			*dev = devtab[i];
  800fe0:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	eb 33                	jmp    80101c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fe9:	42                   	inc    %edx
  800fea:	8b 04 95 8c 25 80 00 	mov    0x80258c(,%edx,4),%eax
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	75 e7                	jne    800fdc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ff5:	a1 20 60 80 00       	mov    0x806020,%eax
  800ffa:	8b 40 48             	mov    0x48(%eax),%eax
  800ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801001:	89 44 24 04          	mov    %eax,0x4(%esp)
  801005:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  80100c:	e8 bb f2 ff ff       	call   8002cc <cprintf>
	*dev = 0;
  801011:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801017:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80101c:	83 c4 14             	add    $0x14,%esp
  80101f:	5b                   	pop    %ebx
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 30             	sub    $0x30,%esp
  80102a:	8b 75 08             	mov    0x8(%ebp),%esi
  80102d:	8a 45 0c             	mov    0xc(%ebp),%al
  801030:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801033:	89 34 24             	mov    %esi,(%esp)
  801036:	e8 b9 fe ff ff       	call   800ef4 <fd2num>
  80103b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80103e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801042:	89 04 24             	mov    %eax,(%esp)
  801045:	e8 28 ff ff ff       	call   800f72 <fd_lookup>
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 05                	js     801055 <fd_close+0x33>
	    || fd != fd2)
  801050:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801053:	74 0d                	je     801062 <fd_close+0x40>
		return (must_exist ? r : 0);
  801055:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801059:	75 46                	jne    8010a1 <fd_close+0x7f>
  80105b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801060:	eb 3f                	jmp    8010a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801062:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801065:	89 44 24 04          	mov    %eax,0x4(%esp)
  801069:	8b 06                	mov    (%esi),%eax
  80106b:	89 04 24             	mov    %eax,(%esp)
  80106e:	e8 55 ff ff ff       	call   800fc8 <dev_lookup>
  801073:	89 c3                	mov    %eax,%ebx
  801075:	85 c0                	test   %eax,%eax
  801077:	78 18                	js     801091 <fd_close+0x6f>
		if (dev->dev_close)
  801079:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107c:	8b 40 10             	mov    0x10(%eax),%eax
  80107f:	85 c0                	test   %eax,%eax
  801081:	74 09                	je     80108c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801083:	89 34 24             	mov    %esi,(%esp)
  801086:	ff d0                	call   *%eax
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	eb 05                	jmp    801091 <fd_close+0x6f>
		else
			r = 0;
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801091:	89 74 24 04          	mov    %esi,0x4(%esp)
  801095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109c:	e8 8f fc ff ff       	call   800d30 <sys_page_unmap>
	return r;
}
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	83 c4 30             	add    $0x30,%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	89 04 24             	mov    %eax,(%esp)
  8010bd:	e8 b0 fe ff ff       	call   800f72 <fd_lookup>
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 13                	js     8010d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010cd:	00 
  8010ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d1:	89 04 24             	mov    %eax,(%esp)
  8010d4:	e8 49 ff ff ff       	call   801022 <fd_close>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <close_all>:

void
close_all(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e7:	89 1c 24             	mov    %ebx,(%esp)
  8010ea:	e8 bb ff ff ff       	call   8010aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ef:	43                   	inc    %ebx
  8010f0:	83 fb 20             	cmp    $0x20,%ebx
  8010f3:	75 f2                	jne    8010e7 <close_all+0xc>
		close(i);
}
  8010f5:	83 c4 14             	add    $0x14,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 4c             	sub    $0x4c,%esp
  801104:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801107:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 59 fe ff ff       	call   800f72 <fd_lookup>
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	0f 88 e1 00 00 00    	js     801204 <dup+0x109>
		return r;
	close(newfdnum);
  801123:	89 3c 24             	mov    %edi,(%esp)
  801126:	e8 7f ff ff ff       	call   8010aa <close>

	newfd = INDEX2FD(newfdnum);
  80112b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801131:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	e8 c5 fd ff ff       	call   800f04 <fd2data>
  80113f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801141:	89 34 24             	mov    %esi,(%esp)
  801144:	e8 bb fd ff ff       	call   800f04 <fd2data>
  801149:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80114c:	89 d8                	mov    %ebx,%eax
  80114e:	c1 e8 16             	shr    $0x16,%eax
  801151:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801158:	a8 01                	test   $0x1,%al
  80115a:	74 46                	je     8011a2 <dup+0xa7>
  80115c:	89 d8                	mov    %ebx,%eax
  80115e:	c1 e8 0c             	shr    $0xc,%eax
  801161:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801168:	f6 c2 01             	test   $0x1,%dl
  80116b:	74 35                	je     8011a2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801174:	25 07 0e 00 00       	and    $0xe07,%eax
  801179:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80118b:	00 
  80118c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801190:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801197:	e8 41 fb ff ff       	call   800cdd <sys_page_map>
  80119c:	89 c3                	mov    %eax,%ebx
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 3b                	js     8011dd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 0c             	shr    $0xc,%edx
  8011aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c6:	00 
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d2:	e8 06 fb ff ff       	call   800cdd <sys_page_map>
  8011d7:	89 c3                	mov    %eax,%ebx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	79 25                	jns    801202 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e8:	e8 43 fb ff ff       	call   800d30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011fb:	e8 30 fb ff ff       	call   800d30 <sys_page_unmap>
	return r;
  801200:	eb 02                	jmp    801204 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801202:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801204:	89 d8                	mov    %ebx,%eax
  801206:	83 c4 4c             	add    $0x4c,%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5f                   	pop    %edi
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	83 ec 24             	sub    $0x24,%esp
  801215:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801218:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121f:	89 1c 24             	mov    %ebx,(%esp)
  801222:	e8 4b fd ff ff       	call   800f72 <fd_lookup>
  801227:	85 c0                	test   %eax,%eax
  801229:	78 6d                	js     801298 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801235:	8b 00                	mov    (%eax),%eax
  801237:	89 04 24             	mov    %eax,(%esp)
  80123a:	e8 89 fd ff ff       	call   800fc8 <dev_lookup>
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 55                	js     801298 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801246:	8b 50 08             	mov    0x8(%eax),%edx
  801249:	83 e2 03             	and    $0x3,%edx
  80124c:	83 fa 01             	cmp    $0x1,%edx
  80124f:	75 23                	jne    801274 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801251:	a1 20 60 80 00       	mov    0x806020,%eax
  801256:	8b 40 48             	mov    0x48(%eax),%eax
  801259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	c7 04 24 50 25 80 00 	movl   $0x802550,(%esp)
  801268:	e8 5f f0 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801272:	eb 24                	jmp    801298 <read+0x8a>
	}
	if (!dev->dev_read)
  801274:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801277:	8b 52 08             	mov    0x8(%edx),%edx
  80127a:	85 d2                	test   %edx,%edx
  80127c:	74 15                	je     801293 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80127e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801281:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801288:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80128c:	89 04 24             	mov    %eax,(%esp)
  80128f:	ff d2                	call   *%edx
  801291:	eb 05                	jmp    801298 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801293:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801298:	83 c4 24             	add    $0x24,%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b2:	eb 23                	jmp    8012d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b4:	89 f0                	mov    %esi,%eax
  8012b6:	29 d8                	sub    %ebx,%eax
  8012b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bf:	01 d8                	add    %ebx,%eax
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	89 3c 24             	mov    %edi,(%esp)
  8012c8:	e8 41 ff ff ff       	call   80120e <read>
		if (m < 0)
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 10                	js     8012e1 <readn+0x43>
			return m;
		if (m == 0)
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	74 0a                	je     8012df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d5:	01 c3                	add    %eax,%ebx
  8012d7:	39 f3                	cmp    %esi,%ebx
  8012d9:	72 d9                	jb     8012b4 <readn+0x16>
  8012db:	89 d8                	mov    %ebx,%eax
  8012dd:	eb 02                	jmp    8012e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 24             	sub    $0x24,%esp
  8012f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	89 1c 24             	mov    %ebx,(%esp)
  8012fd:	e8 70 fc ff ff       	call   800f72 <fd_lookup>
  801302:	85 c0                	test   %eax,%eax
  801304:	78 68                	js     80136e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	8b 00                	mov    (%eax),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 ae fc ff ff       	call   800fc8 <dev_lookup>
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 50                	js     80136e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801325:	75 23                	jne    80134a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801327:	a1 20 60 80 00       	mov    0x806020,%eax
  80132c:	8b 40 48             	mov    0x48(%eax),%eax
  80132f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801333:	89 44 24 04          	mov    %eax,0x4(%esp)
  801337:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  80133e:	e8 89 ef ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  801343:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801348:	eb 24                	jmp    80136e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80134a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134d:	8b 52 0c             	mov    0xc(%edx),%edx
  801350:	85 d2                	test   %edx,%edx
  801352:	74 15                	je     801369 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801354:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801357:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801362:	89 04 24             	mov    %eax,(%esp)
  801365:	ff d2                	call   *%edx
  801367:	eb 05                	jmp    80136e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801369:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80136e:	83 c4 24             	add    $0x24,%esp
  801371:	5b                   	pop    %ebx
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <seek>:

int
seek(int fdnum, off_t offset)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80137d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	e8 e6 fb ff ff       	call   800f72 <fd_lookup>
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 0e                	js     80139e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801390:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801393:	8b 55 0c             	mov    0xc(%ebp),%edx
  801396:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 24             	sub    $0x24,%esp
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 b9 fb ff ff       	call   800f72 <fd_lookup>
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 61                	js     80141e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	8b 00                	mov    (%eax),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 f7 fb ff ff       	call   800fc8 <dev_lookup>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 49                	js     80141e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013dc:	75 23                	jne    801401 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013de:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013e3:	8b 40 48             	mov    0x48(%eax),%eax
  8013e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ee:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
  8013f5:	e8 d2 ee ff ff       	call   8002cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ff:	eb 1d                	jmp    80141e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801401:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801404:	8b 52 18             	mov    0x18(%edx),%edx
  801407:	85 d2                	test   %edx,%edx
  801409:	74 0e                	je     801419 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80140b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	ff d2                	call   *%edx
  801417:	eb 05                	jmp    80141e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801419:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80141e:	83 c4 24             	add    $0x24,%esp
  801421:	5b                   	pop    %ebx
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	53                   	push   %ebx
  801428:	83 ec 24             	sub    $0x24,%esp
  80142b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 32 fb ff ff       	call   800f72 <fd_lookup>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 52                	js     801496 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144e:	8b 00                	mov    (%eax),%eax
  801450:	89 04 24             	mov    %eax,(%esp)
  801453:	e8 70 fb ff ff       	call   800fc8 <dev_lookup>
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 3a                	js     801496 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80145c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801463:	74 2c                	je     801491 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801465:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801468:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146f:	00 00 00 
	stat->st_isdir = 0;
  801472:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801479:	00 00 00 
	stat->st_dev = dev;
  80147c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801486:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801489:	89 14 24             	mov    %edx,(%esp)
  80148c:	ff 50 14             	call   *0x14(%eax)
  80148f:	eb 05                	jmp    801496 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801491:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801496:	83 c4 24             	add    $0x24,%esp
  801499:	5b                   	pop    %ebx
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ab:	00 
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	89 04 24             	mov    %eax,(%esp)
  8014b2:	e8 fe 01 00 00       	call   8016b5 <open>
  8014b7:	89 c3                	mov    %eax,%ebx
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 1b                	js     8014d8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c4:	89 1c 24             	mov    %ebx,(%esp)
  8014c7:	e8 58 ff ff ff       	call   801424 <fstat>
  8014cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ce:	89 1c 24             	mov    %ebx,(%esp)
  8014d1:	e8 d4 fb ff ff       	call   8010aa <close>
	return r;
  8014d6:	89 f3                	mov    %esi,%ebx
}
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5e                   	pop    %esi
  8014df:	5d                   	pop    %ebp
  8014e0:	c3                   	ret    
  8014e1:	00 00                	add    %al,(%eax)
	...

008014e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 10             	sub    $0x10,%esp
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f7:	75 11                	jne    80150a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801500:	e8 70 09 00 00       	call   801e75 <ipc_find_env>
  801505:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80150a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801511:	00 
  801512:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801519:	00 
  80151a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151e:	a1 00 40 80 00       	mov    0x804000,%eax
  801523:	89 04 24             	mov    %eax,(%esp)
  801526:	e8 e0 08 00 00       	call   801e0b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80152b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801532:	00 
  801533:	89 74 24 04          	mov    %esi,0x4(%esp)
  801537:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153e:	e8 61 08 00 00       	call   801da4 <ipc_recv>
}
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801550:	8b 45 08             	mov    0x8(%ebp),%eax
  801553:	8b 40 0c             	mov    0xc(%eax),%eax
  801556:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80155b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155e:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 02 00 00 00       	mov    $0x2,%eax
  80156d:	e8 72 ff ff ff       	call   8014e4 <fsipc>
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80157a:	8b 45 08             	mov    0x8(%ebp),%eax
  80157d:	8b 40 0c             	mov    0xc(%eax),%eax
  801580:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801585:	ba 00 00 00 00       	mov    $0x0,%edx
  80158a:	b8 06 00 00 00       	mov    $0x6,%eax
  80158f:	e8 50 ff ff ff       	call   8014e4 <fsipc>
}
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a6:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015b5:	e8 2a ff ff ff       	call   8014e4 <fsipc>
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 2b                	js     8015e9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015be:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8015c5:	00 
  8015c6:	89 1c 24             	mov    %ebx,(%esp)
  8015c9:	e8 c9 f2 ff ff       	call   800897 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ce:	a1 80 70 80 00       	mov    0x807080,%eax
  8015d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015d9:	a1 84 70 80 00       	mov    0x807084,%eax
  8015de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e9:	83 c4 14             	add    $0x14,%esp
  8015ec:	5b                   	pop    %ebx
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015f5:	c7 44 24 08 9c 25 80 	movl   $0x80259c,0x8(%esp)
  8015fc:	00 
  8015fd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801604:	00 
  801605:	c7 04 24 ba 25 80 00 	movl   $0x8025ba,(%esp)
  80160c:	e8 c3 eb ff ff       	call   8001d4 <_panic>

00801611 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
  801616:	83 ec 10             	sub    $0x10,%esp
  801619:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80161c:	8b 45 08             	mov    0x8(%ebp),%eax
  80161f:	8b 40 0c             	mov    0xc(%eax),%eax
  801622:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801627:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 03 00 00 00       	mov    $0x3,%eax
  801637:	e8 a8 fe ff ff       	call   8014e4 <fsipc>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 6a                	js     8016ac <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801642:	39 c6                	cmp    %eax,%esi
  801644:	73 24                	jae    80166a <devfile_read+0x59>
  801646:	c7 44 24 0c c5 25 80 	movl   $0x8025c5,0xc(%esp)
  80164d:	00 
  80164e:	c7 44 24 08 cc 25 80 	movl   $0x8025cc,0x8(%esp)
  801655:	00 
  801656:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80165d:	00 
  80165e:	c7 04 24 ba 25 80 00 	movl   $0x8025ba,(%esp)
  801665:	e8 6a eb ff ff       	call   8001d4 <_panic>
	assert(r <= PGSIZE);
  80166a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80166f:	7e 24                	jle    801695 <devfile_read+0x84>
  801671:	c7 44 24 0c e1 25 80 	movl   $0x8025e1,0xc(%esp)
  801678:	00 
  801679:	c7 44 24 08 cc 25 80 	movl   $0x8025cc,0x8(%esp)
  801680:	00 
  801681:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801688:	00 
  801689:	c7 04 24 ba 25 80 00 	movl   $0x8025ba,(%esp)
  801690:	e8 3f eb ff ff       	call   8001d4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801695:	89 44 24 08          	mov    %eax,0x8(%esp)
  801699:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8016a0:	00 
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 64 f3 ff ff       	call   800a10 <memmove>
	return r;
}
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 20             	sub    $0x20,%esp
  8016bd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c0:	89 34 24             	mov    %esi,(%esp)
  8016c3:	e8 9c f1 ff ff       	call   800864 <strlen>
  8016c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016cd:	7f 60                	jg     80172f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d2:	89 04 24             	mov    %eax,(%esp)
  8016d5:	e8 45 f8 ff ff       	call   800f1f <fd_alloc>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 54                	js     801734 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e4:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8016eb:	e8 a7 f1 ff ff       	call   800897 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f3:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801700:	e8 df fd ff ff       	call   8014e4 <fsipc>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	85 c0                	test   %eax,%eax
  801709:	79 15                	jns    801720 <open+0x6b>
		fd_close(fd, 0);
  80170b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801712:	00 
  801713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801716:	89 04 24             	mov    %eax,(%esp)
  801719:	e8 04 f9 ff ff       	call   801022 <fd_close>
		return r;
  80171e:	eb 14                	jmp    801734 <open+0x7f>
	}

	return fd2num(fd);
  801720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 c9 f7 ff ff       	call   800ef4 <fd2num>
  80172b:	89 c3                	mov    %eax,%ebx
  80172d:	eb 05                	jmp    801734 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80172f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801734:	89 d8                	mov    %ebx,%eax
  801736:	83 c4 20             	add    $0x20,%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 08 00 00 00       	mov    $0x8,%eax
  80174d:	e8 92 fd ff ff       	call   8014e4 <fsipc>
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	53                   	push   %ebx
  801758:	83 ec 14             	sub    $0x14,%esp
  80175b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80175d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801761:	7e 32                	jle    801795 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801763:	8b 40 04             	mov    0x4(%eax),%eax
  801766:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176a:	8d 43 10             	lea    0x10(%ebx),%eax
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	8b 03                	mov    (%ebx),%eax
  801773:	89 04 24             	mov    %eax,(%esp)
  801776:	e8 6e fb ff ff       	call   8012e9 <write>
		if (result > 0)
  80177b:	85 c0                	test   %eax,%eax
  80177d:	7e 03                	jle    801782 <writebuf+0x2e>
			b->result += result;
  80177f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801782:	39 43 04             	cmp    %eax,0x4(%ebx)
  801785:	74 0e                	je     801795 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801787:	89 c2                	mov    %eax,%edx
  801789:	85 c0                	test   %eax,%eax
  80178b:	7e 05                	jle    801792 <writebuf+0x3e>
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801795:	83 c4 14             	add    $0x14,%esp
  801798:	5b                   	pop    %ebx
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    

0080179b <putch>:

static void
putch(int ch, void *thunk)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	53                   	push   %ebx
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8017a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ab:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8017af:	40                   	inc    %eax
  8017b0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8017b3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017b8:	75 0e                	jne    8017c8 <putch+0x2d>
		writebuf(b);
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	e8 93 ff ff ff       	call   801754 <writebuf>
		b->idx = 0;
  8017c1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017c8:	83 c4 04             	add    $0x4,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017e0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017e7:	00 00 00 
	b.result = 0;
  8017ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017f1:	00 00 00 
	b.error = 1;
  8017f4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017fb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801805:	8b 45 0c             	mov    0xc(%ebp),%eax
  801808:	89 44 24 08          	mov    %eax,0x8(%esp)
  80180c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	c7 04 24 9b 17 80 00 	movl   $0x80179b,(%esp)
  80181d:	e8 0c ec ff ff       	call   80042e <vprintfmt>
	if (b.idx > 0)
  801822:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801829:	7e 0b                	jle    801836 <vfprintf+0x68>
		writebuf(&b);
  80182b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801831:	e8 1e ff ff ff       	call   801754 <writebuf>

	return (b.result ? b.result : b.error);
  801836:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80183c:	85 c0                	test   %eax,%eax
  80183e:	75 06                	jne    801846 <vfprintf+0x78>
  801840:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80184e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801851:	89 44 24 08          	mov    %eax,0x8(%esp)
  801855:	8b 45 0c             	mov    0xc(%ebp),%eax
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	e8 67 ff ff ff       	call   8017ce <vfprintf>
	va_end(ap);

	return cnt;
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <printf>:

int
printf(const char *fmt, ...)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80186f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801872:	89 44 24 08          	mov    %eax,0x8(%esp)
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801884:	e8 45 ff ff ff       	call   8017ce <vfprintf>
	va_end(ap);

	return cnt;
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    
	...

0080188c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
  801891:	83 ec 10             	sub    $0x10,%esp
  801894:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	89 04 24             	mov    %eax,(%esp)
  80189d:	e8 62 f6 ff ff       	call   800f04 <fd2data>
  8018a2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8018a4:	c7 44 24 04 ed 25 80 	movl   $0x8025ed,0x4(%esp)
  8018ab:	00 
  8018ac:	89 34 24             	mov    %esi,(%esp)
  8018af:	e8 e3 ef ff ff       	call   800897 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8018b7:	2b 03                	sub    (%ebx),%eax
  8018b9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018bf:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018c6:	00 00 00 
	stat->st_dev = &devpipe;
  8018c9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018d0:	30 80 00 
	return 0;
}
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	53                   	push   %ebx
  8018e3:	83 ec 14             	sub    $0x14,%esp
  8018e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f4:	e8 37 f4 ff ff       	call   800d30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018f9:	89 1c 24             	mov    %ebx,(%esp)
  8018fc:	e8 03 f6 ff ff       	call   800f04 <fd2data>
  801901:	89 44 24 04          	mov    %eax,0x4(%esp)
  801905:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190c:	e8 1f f4 ff ff       	call   800d30 <sys_page_unmap>
}
  801911:	83 c4 14             	add    $0x14,%esp
  801914:	5b                   	pop    %ebx
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	57                   	push   %edi
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	83 ec 2c             	sub    $0x2c,%esp
  801920:	89 c7                	mov    %eax,%edi
  801922:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801925:	a1 20 60 80 00       	mov    0x806020,%eax
  80192a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80192d:	89 3c 24             	mov    %edi,(%esp)
  801930:	e8 87 05 00 00       	call   801ebc <pageref>
  801935:	89 c6                	mov    %eax,%esi
  801937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193a:	89 04 24             	mov    %eax,(%esp)
  80193d:	e8 7a 05 00 00       	call   801ebc <pageref>
  801942:	39 c6                	cmp    %eax,%esi
  801944:	0f 94 c0             	sete   %al
  801947:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80194a:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801950:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801953:	39 cb                	cmp    %ecx,%ebx
  801955:	75 08                	jne    80195f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801957:	83 c4 2c             	add    $0x2c,%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5f                   	pop    %edi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80195f:	83 f8 01             	cmp    $0x1,%eax
  801962:	75 c1                	jne    801925 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801964:	8b 42 58             	mov    0x58(%edx),%eax
  801967:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80196e:	00 
  80196f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801973:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801977:	c7 04 24 f4 25 80 00 	movl   $0x8025f4,(%esp)
  80197e:	e8 49 e9 ff ff       	call   8002cc <cprintf>
  801983:	eb a0                	jmp    801925 <_pipeisclosed+0xe>

00801985 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	57                   	push   %edi
  801989:	56                   	push   %esi
  80198a:	53                   	push   %ebx
  80198b:	83 ec 1c             	sub    $0x1c,%esp
  80198e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801991:	89 34 24             	mov    %esi,(%esp)
  801994:	e8 6b f5 ff ff       	call   800f04 <fd2data>
  801999:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199b:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a0:	eb 3c                	jmp    8019de <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019a2:	89 da                	mov    %ebx,%edx
  8019a4:	89 f0                	mov    %esi,%eax
  8019a6:	e8 6c ff ff ff       	call   801917 <_pipeisclosed>
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	75 38                	jne    8019e7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019af:	e8 b6 f2 ff ff       	call   800c6a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8019b7:	8b 13                	mov    (%ebx),%edx
  8019b9:	83 c2 20             	add    $0x20,%edx
  8019bc:	39 d0                	cmp    %edx,%eax
  8019be:	73 e2                	jae    8019a2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8019c6:	89 c2                	mov    %eax,%edx
  8019c8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019ce:	79 05                	jns    8019d5 <devpipe_write+0x50>
  8019d0:	4a                   	dec    %edx
  8019d1:	83 ca e0             	or     $0xffffffe0,%edx
  8019d4:	42                   	inc    %edx
  8019d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019d9:	40                   	inc    %eax
  8019da:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019dd:	47                   	inc    %edi
  8019de:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019e1:	75 d1                	jne    8019b4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019e3:	89 f8                	mov    %edi,%eax
  8019e5:	eb 05                	jmp    8019ec <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019ec:	83 c4 1c             	add    $0x1c,%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5f                   	pop    %edi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	57                   	push   %edi
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 1c             	sub    $0x1c,%esp
  8019fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a00:	89 3c 24             	mov    %edi,(%esp)
  801a03:	e8 fc f4 ff ff       	call   800f04 <fd2data>
  801a08:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0a:	be 00 00 00 00       	mov    $0x0,%esi
  801a0f:	eb 3a                	jmp    801a4b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a11:	85 f6                	test   %esi,%esi
  801a13:	74 04                	je     801a19 <devpipe_read+0x25>
				return i;
  801a15:	89 f0                	mov    %esi,%eax
  801a17:	eb 40                	jmp    801a59 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a19:	89 da                	mov    %ebx,%edx
  801a1b:	89 f8                	mov    %edi,%eax
  801a1d:	e8 f5 fe ff ff       	call   801917 <_pipeisclosed>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	75 2e                	jne    801a54 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a26:	e8 3f f2 ff ff       	call   800c6a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a2b:	8b 03                	mov    (%ebx),%eax
  801a2d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a30:	74 df                	je     801a11 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a32:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a37:	79 05                	jns    801a3e <devpipe_read+0x4a>
  801a39:	48                   	dec    %eax
  801a3a:	83 c8 e0             	or     $0xffffffe0,%eax
  801a3d:	40                   	inc    %eax
  801a3e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a45:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a48:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4a:	46                   	inc    %esi
  801a4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a4e:	75 db                	jne    801a2b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a50:	89 f0                	mov    %esi,%eax
  801a52:	eb 05                	jmp    801a59 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a59:	83 c4 1c             	add    $0x1c,%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5f                   	pop    %edi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	57                   	push   %edi
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	83 ec 3c             	sub    $0x3c,%esp
  801a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	e8 a7 f4 ff ff       	call   800f1f <fd_alloc>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	0f 88 45 01 00 00    	js     801bc7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a89:	00 
  801a8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a98:	e8 ec f1 ff ff       	call   800c89 <sys_page_alloc>
  801a9d:	89 c3                	mov    %eax,%ebx
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	0f 88 20 01 00 00    	js     801bc7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aa7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 6d f4 ff ff       	call   800f1f <fd_alloc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 f8 00 00 00    	js     801bb4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ac3:	00 
  801ac4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad2:	e8 b2 f1 ff ff       	call   800c89 <sys_page_alloc>
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	0f 88 d3 00 00 00    	js     801bb4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae4:	89 04 24             	mov    %eax,(%esp)
  801ae7:	e8 18 f4 ff ff       	call   800f04 <fd2data>
  801aec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801af5:	00 
  801af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b01:	e8 83 f1 ff ff       	call   800c89 <sys_page_alloc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 91 00 00 00    	js     801ba1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b13:	89 04 24             	mov    %eax,(%esp)
  801b16:	e8 e9 f3 ff ff       	call   800f04 <fd2data>
  801b1b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b22:	00 
  801b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b2e:	00 
  801b2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3a:	e8 9e f1 ff ff       	call   800cdd <sys_page_map>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 4c                	js     801b91 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b5a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 7a f3 ff ff       	call   800ef4 <fd2num>
  801b7a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b7f:	89 04 24             	mov    %eax,(%esp)
  801b82:	e8 6d f3 ff ff       	call   800ef4 <fd2num>
  801b87:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b8f:	eb 36                	jmp    801bc7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b91:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b9c:	e8 8f f1 ff ff       	call   800d30 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ba1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baf:	e8 7c f1 ff ff       	call   800d30 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801bb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc2:	e8 69 f1 ff ff       	call   800d30 <sys_page_unmap>
    err:
	return r;
}
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	83 c4 3c             	add    $0x3c,%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	89 04 24             	mov    %eax,(%esp)
  801be4:	e8 89 f3 ff ff       	call   800f72 <fd_lookup>
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 15                	js     801c02 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	89 04 24             	mov    %eax,(%esp)
  801bf3:	e8 0c f3 ff ff       	call   800f04 <fd2data>
	return _pipeisclosed(fd, p);
  801bf8:	89 c2                	mov    %eax,%edx
  801bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfd:	e8 15 fd ff ff       	call   801917 <_pipeisclosed>
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c14:	c7 44 24 04 0c 26 80 	movl   $0x80260c,0x4(%esp)
  801c1b:	00 
  801c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1f:	89 04 24             	mov    %eax,(%esp)
  801c22:	e8 70 ec ff ff       	call   800897 <strcpy>
	return 0;
}
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c45:	eb 30                	jmp    801c77 <devcons_write+0x49>
		m = n - tot;
  801c47:	8b 75 10             	mov    0x10(%ebp),%esi
  801c4a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801c4c:	83 fe 7f             	cmp    $0x7f,%esi
  801c4f:	76 05                	jbe    801c56 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801c51:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c56:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c5a:	03 45 0c             	add    0xc(%ebp),%eax
  801c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c61:	89 3c 24             	mov    %edi,(%esp)
  801c64:	e8 a7 ed ff ff       	call   800a10 <memmove>
		sys_cputs(buf, m);
  801c69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6d:	89 3c 24             	mov    %edi,(%esp)
  801c70:	e8 47 ef ff ff       	call   800bbc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c75:	01 f3                	add    %esi,%ebx
  801c77:	89 d8                	mov    %ebx,%eax
  801c79:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c7c:	72 c9                	jb     801c47 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c7e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c93:	75 07                	jne    801c9c <devcons_read+0x13>
  801c95:	eb 25                	jmp    801cbc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c97:	e8 ce ef ff ff       	call   800c6a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c9c:	e8 39 ef ff ff       	call   800bda <sys_cgetc>
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	74 f2                	je     801c97 <devcons_read+0xe>
  801ca5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 1d                	js     801cc8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cab:	83 f8 04             	cmp    $0x4,%eax
  801cae:	74 13                	je     801cc3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb3:	88 10                	mov    %dl,(%eax)
	return 1;
  801cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cba:	eb 0c                	jmp    801cc8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc1:	eb 05                	jmp    801cc8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cd6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cdd:	00 
  801cde:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce1:	89 04 24             	mov    %eax,(%esp)
  801ce4:	e8 d3 ee ff ff       	call   800bbc <sys_cputs>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <getchar>:

int
getchar(void)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cf1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801cf8:	00 
  801cf9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d07:	e8 02 f5 ff ff       	call   80120e <read>
	if (r < 0)
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 0f                	js     801d1f <getchar+0x34>
		return r;
	if (r < 1)
  801d10:	85 c0                	test   %eax,%eax
  801d12:	7e 06                	jle    801d1a <getchar+0x2f>
		return -E_EOF;
	return c;
  801d14:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d18:	eb 05                	jmp    801d1f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d1a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d31:	89 04 24             	mov    %eax,(%esp)
  801d34:	e8 39 f2 ff ff       	call   800f72 <fd_lookup>
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 11                	js     801d4e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d40:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d46:	39 10                	cmp    %edx,(%eax)
  801d48:	0f 94 c0             	sete   %al
  801d4b:	0f b6 c0             	movzbl %al,%eax
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <opencons>:

int
opencons(void)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d59:	89 04 24             	mov    %eax,(%esp)
  801d5c:	e8 be f1 ff ff       	call   800f1f <fd_alloc>
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 3c                	js     801da1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d65:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d6c:	00 
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7b:	e8 09 ef ff ff       	call   800c89 <sys_page_alloc>
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 1d                	js     801da1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d84:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d99:	89 04 24             	mov    %eax,(%esp)
  801d9c:	e8 53 f1 ff ff       	call   800ef4 <fd2num>
}
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    
	...

00801da4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 10             	sub    $0x10,%esp
  801dac:	8b 75 08             	mov    0x8(%ebp),%esi
  801daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801db5:	85 c0                	test   %eax,%eax
  801db7:	75 05                	jne    801dbe <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801db9:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801dbe:	89 04 24             	mov    %eax,(%esp)
  801dc1:	e8 d9 f0 ff ff       	call   800e9f <sys_ipc_recv>
	if (!err) {
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	75 26                	jne    801df0 <ipc_recv+0x4c>
		if (from_env_store) {
  801dca:	85 f6                	test   %esi,%esi
  801dcc:	74 0a                	je     801dd8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801dce:	a1 20 60 80 00       	mov    0x806020,%eax
  801dd3:	8b 40 74             	mov    0x74(%eax),%eax
  801dd6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801dd8:	85 db                	test   %ebx,%ebx
  801dda:	74 0a                	je     801de6 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801ddc:	a1 20 60 80 00       	mov    0x806020,%eax
  801de1:	8b 40 78             	mov    0x78(%eax),%eax
  801de4:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801de6:	a1 20 60 80 00       	mov    0x806020,%eax
  801deb:	8b 40 70             	mov    0x70(%eax),%eax
  801dee:	eb 14                	jmp    801e04 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801df0:	85 f6                	test   %esi,%esi
  801df2:	74 06                	je     801dfa <ipc_recv+0x56>
		*from_env_store = 0;
  801df4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801dfa:	85 db                	test   %ebx,%ebx
  801dfc:	74 06                	je     801e04 <ipc_recv+0x60>
		*perm_store = 0;
  801dfe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	57                   	push   %edi
  801e0f:	56                   	push   %esi
  801e10:	53                   	push   %ebx
  801e11:	83 ec 1c             	sub    $0x1c,%esp
  801e14:	8b 75 10             	mov    0x10(%ebp),%esi
  801e17:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801e1a:	85 f6                	test   %esi,%esi
  801e1c:	75 05                	jne    801e23 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801e1e:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801e23:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e27:	89 74 24 08          	mov    %esi,0x8(%esp)
  801e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	89 04 24             	mov    %eax,(%esp)
  801e38:	e8 3f f0 ff ff       	call   800e7c <sys_ipc_try_send>
  801e3d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801e3f:	e8 26 ee ff ff       	call   800c6a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801e44:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801e47:	74 da                	je     801e23 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801e49:	85 db                	test   %ebx,%ebx
  801e4b:	74 20                	je     801e6d <ipc_send+0x62>
		panic("send fail: %e", err);
  801e4d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e51:	c7 44 24 08 18 26 80 	movl   $0x802618,0x8(%esp)
  801e58:	00 
  801e59:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801e60:	00 
  801e61:	c7 04 24 26 26 80 00 	movl   $0x802626,(%esp)
  801e68:	e8 67 e3 ff ff       	call   8001d4 <_panic>
	}
	return;
}
  801e6d:	83 c4 1c             	add    $0x1c,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    

00801e75 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	53                   	push   %ebx
  801e79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e81:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e88:	89 c2                	mov    %eax,%edx
  801e8a:	c1 e2 07             	shl    $0x7,%edx
  801e8d:	29 ca                	sub    %ecx,%edx
  801e8f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e95:	8b 52 50             	mov    0x50(%edx),%edx
  801e98:	39 da                	cmp    %ebx,%edx
  801e9a:	75 0f                	jne    801eab <ipc_find_env+0x36>
			return envs[i].env_id;
  801e9c:	c1 e0 07             	shl    $0x7,%eax
  801e9f:	29 c8                	sub    %ecx,%eax
  801ea1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ea6:	8b 40 40             	mov    0x40(%eax),%eax
  801ea9:	eb 0c                	jmp    801eb7 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eab:	40                   	inc    %eax
  801eac:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eb1:	75 ce                	jne    801e81 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eb3:	66 b8 00 00          	mov    $0x0,%ax
}
  801eb7:	5b                   	pop    %ebx
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    
	...

00801ebc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ec2:	89 c2                	mov    %eax,%edx
  801ec4:	c1 ea 16             	shr    $0x16,%edx
  801ec7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ece:	f6 c2 01             	test   $0x1,%dl
  801ed1:	74 1e                	je     801ef1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ed3:	c1 e8 0c             	shr    $0xc,%eax
  801ed6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801edd:	a8 01                	test   $0x1,%al
  801edf:	74 17                	je     801ef8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ee1:	c1 e8 0c             	shr    $0xc,%eax
  801ee4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801eeb:	ef 
  801eec:	0f b7 c0             	movzwl %ax,%eax
  801eef:	eb 0c                	jmp    801efd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef6:	eb 05                	jmp    801efd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    
	...

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	83 ec 10             	sub    $0x10,%esp
  801f06:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f0a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f12:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f16:	89 cd                	mov    %ecx,%ebp
  801f18:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	75 2c                	jne    801f4c <__udivdi3+0x4c>
  801f20:	39 f9                	cmp    %edi,%ecx
  801f22:	77 68                	ja     801f8c <__udivdi3+0x8c>
  801f24:	85 c9                	test   %ecx,%ecx
  801f26:	75 0b                	jne    801f33 <__udivdi3+0x33>
  801f28:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2d:	31 d2                	xor    %edx,%edx
  801f2f:	f7 f1                	div    %ecx
  801f31:	89 c1                	mov    %eax,%ecx
  801f33:	31 d2                	xor    %edx,%edx
  801f35:	89 f8                	mov    %edi,%eax
  801f37:	f7 f1                	div    %ecx
  801f39:	89 c7                	mov    %eax,%edi
  801f3b:	89 f0                	mov    %esi,%eax
  801f3d:	f7 f1                	div    %ecx
  801f3f:	89 c6                	mov    %eax,%esi
  801f41:	89 f0                	mov    %esi,%eax
  801f43:	89 fa                	mov    %edi,%edx
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    
  801f4c:	39 f8                	cmp    %edi,%eax
  801f4e:	77 2c                	ja     801f7c <__udivdi3+0x7c>
  801f50:	0f bd f0             	bsr    %eax,%esi
  801f53:	83 f6 1f             	xor    $0x1f,%esi
  801f56:	75 4c                	jne    801fa4 <__udivdi3+0xa4>
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5f:	72 0a                	jb     801f6b <__udivdi3+0x6b>
  801f61:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f65:	0f 87 ad 00 00 00    	ja     802018 <__udivdi3+0x118>
  801f6b:	be 01 00 00 00       	mov    $0x1,%esi
  801f70:	89 f0                	mov    %esi,%eax
  801f72:	89 fa                	mov    %edi,%edx
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
  801f7b:	90                   	nop
  801f7c:	31 ff                	xor    %edi,%edi
  801f7e:	31 f6                	xor    %esi,%esi
  801f80:	89 f0                	mov    %esi,%eax
  801f82:	89 fa                	mov    %edi,%edx
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	5e                   	pop    %esi
  801f88:	5f                   	pop    %edi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
  801f8b:	90                   	nop
  801f8c:	89 fa                	mov    %edi,%edx
  801f8e:	89 f0                	mov    %esi,%eax
  801f90:	f7 f1                	div    %ecx
  801f92:	89 c6                	mov    %eax,%esi
  801f94:	31 ff                	xor    %edi,%edi
  801f96:	89 f0                	mov    %esi,%eax
  801f98:	89 fa                	mov    %edi,%edx
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    
  801fa1:	8d 76 00             	lea    0x0(%esi),%esi
  801fa4:	89 f1                	mov    %esi,%ecx
  801fa6:	d3 e0                	shl    %cl,%eax
  801fa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fac:	b8 20 00 00 00       	mov    $0x20,%eax
  801fb1:	29 f0                	sub    %esi,%eax
  801fb3:	89 ea                	mov    %ebp,%edx
  801fb5:	88 c1                	mov    %al,%cl
  801fb7:	d3 ea                	shr    %cl,%edx
  801fb9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801fbd:	09 ca                	or     %ecx,%edx
  801fbf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fc3:	89 f1                	mov    %esi,%ecx
  801fc5:	d3 e5                	shl    %cl,%ebp
  801fc7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801fcb:	89 fd                	mov    %edi,%ebp
  801fcd:	88 c1                	mov    %al,%cl
  801fcf:	d3 ed                	shr    %cl,%ebp
  801fd1:	89 fa                	mov    %edi,%edx
  801fd3:	89 f1                	mov    %esi,%ecx
  801fd5:	d3 e2                	shl    %cl,%edx
  801fd7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fdb:	88 c1                	mov    %al,%cl
  801fdd:	d3 ef                	shr    %cl,%edi
  801fdf:	09 d7                	or     %edx,%edi
  801fe1:	89 f8                	mov    %edi,%eax
  801fe3:	89 ea                	mov    %ebp,%edx
  801fe5:	f7 74 24 08          	divl   0x8(%esp)
  801fe9:	89 d1                	mov    %edx,%ecx
  801feb:	89 c7                	mov    %eax,%edi
  801fed:	f7 64 24 0c          	mull   0xc(%esp)
  801ff1:	39 d1                	cmp    %edx,%ecx
  801ff3:	72 17                	jb     80200c <__udivdi3+0x10c>
  801ff5:	74 09                	je     802000 <__udivdi3+0x100>
  801ff7:	89 fe                	mov    %edi,%esi
  801ff9:	31 ff                	xor    %edi,%edi
  801ffb:	e9 41 ff ff ff       	jmp    801f41 <__udivdi3+0x41>
  802000:	8b 54 24 04          	mov    0x4(%esp),%edx
  802004:	89 f1                	mov    %esi,%ecx
  802006:	d3 e2                	shl    %cl,%edx
  802008:	39 c2                	cmp    %eax,%edx
  80200a:	73 eb                	jae    801ff7 <__udivdi3+0xf7>
  80200c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80200f:	31 ff                	xor    %edi,%edi
  802011:	e9 2b ff ff ff       	jmp    801f41 <__udivdi3+0x41>
  802016:	66 90                	xchg   %ax,%ax
  802018:	31 f6                	xor    %esi,%esi
  80201a:	e9 22 ff ff ff       	jmp    801f41 <__udivdi3+0x41>
	...

00802020 <__umoddi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	83 ec 20             	sub    $0x20,%esp
  802026:	8b 44 24 30          	mov    0x30(%esp),%eax
  80202a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80202e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802032:	8b 74 24 34          	mov    0x34(%esp),%esi
  802036:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80203a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80203e:	89 c7                	mov    %eax,%edi
  802040:	89 f2                	mov    %esi,%edx
  802042:	85 ed                	test   %ebp,%ebp
  802044:	75 16                	jne    80205c <__umoddi3+0x3c>
  802046:	39 f1                	cmp    %esi,%ecx
  802048:	0f 86 a6 00 00 00    	jbe    8020f4 <__umoddi3+0xd4>
  80204e:	f7 f1                	div    %ecx
  802050:	89 d0                	mov    %edx,%eax
  802052:	31 d2                	xor    %edx,%edx
  802054:	83 c4 20             	add    $0x20,%esp
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    
  80205b:	90                   	nop
  80205c:	39 f5                	cmp    %esi,%ebp
  80205e:	0f 87 ac 00 00 00    	ja     802110 <__umoddi3+0xf0>
  802064:	0f bd c5             	bsr    %ebp,%eax
  802067:	83 f0 1f             	xor    $0x1f,%eax
  80206a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80206e:	0f 84 a8 00 00 00    	je     80211c <__umoddi3+0xfc>
  802074:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802078:	d3 e5                	shl    %cl,%ebp
  80207a:	bf 20 00 00 00       	mov    $0x20,%edi
  80207f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802083:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802087:	89 f9                	mov    %edi,%ecx
  802089:	d3 e8                	shr    %cl,%eax
  80208b:	09 e8                	or     %ebp,%eax
  80208d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802091:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802095:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802099:	d3 e0                	shl    %cl,%eax
  80209b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209f:	89 f2                	mov    %esi,%edx
  8020a1:	d3 e2                	shl    %cl,%edx
  8020a3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020a7:	d3 e0                	shl    %cl,%eax
  8020a9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8020ad:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e8                	shr    %cl,%eax
  8020b5:	09 d0                	or     %edx,%eax
  8020b7:	d3 ee                	shr    %cl,%esi
  8020b9:	89 f2                	mov    %esi,%edx
  8020bb:	f7 74 24 18          	divl   0x18(%esp)
  8020bf:	89 d6                	mov    %edx,%esi
  8020c1:	f7 64 24 0c          	mull   0xc(%esp)
  8020c5:	89 c5                	mov    %eax,%ebp
  8020c7:	89 d1                	mov    %edx,%ecx
  8020c9:	39 d6                	cmp    %edx,%esi
  8020cb:	72 67                	jb     802134 <__umoddi3+0x114>
  8020cd:	74 75                	je     802144 <__umoddi3+0x124>
  8020cf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8020d3:	29 e8                	sub    %ebp,%eax
  8020d5:	19 ce                	sbb    %ecx,%esi
  8020d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	89 f9                	mov    %edi,%ecx
  8020e1:	d3 e2                	shl    %cl,%edx
  8020e3:	09 d0                	or     %edx,%eax
  8020e5:	89 f2                	mov    %esi,%edx
  8020e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020eb:	d3 ea                	shr    %cl,%edx
  8020ed:	83 c4 20             	add    $0x20,%esp
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	85 c9                	test   %ecx,%ecx
  8020f6:	75 0b                	jne    802103 <__umoddi3+0xe3>
  8020f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fd:	31 d2                	xor    %edx,%edx
  8020ff:	f7 f1                	div    %ecx
  802101:	89 c1                	mov    %eax,%ecx
  802103:	89 f0                	mov    %esi,%eax
  802105:	31 d2                	xor    %edx,%edx
  802107:	f7 f1                	div    %ecx
  802109:	89 f8                	mov    %edi,%eax
  80210b:	e9 3e ff ff ff       	jmp    80204e <__umoddi3+0x2e>
  802110:	89 f2                	mov    %esi,%edx
  802112:	83 c4 20             	add    $0x20,%esp
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d 76 00             	lea    0x0(%esi),%esi
  80211c:	39 f5                	cmp    %esi,%ebp
  80211e:	72 04                	jb     802124 <__umoddi3+0x104>
  802120:	39 f9                	cmp    %edi,%ecx
  802122:	77 06                	ja     80212a <__umoddi3+0x10a>
  802124:	89 f2                	mov    %esi,%edx
  802126:	29 cf                	sub    %ecx,%edi
  802128:	19 ea                	sbb    %ebp,%edx
  80212a:	89 f8                	mov    %edi,%eax
  80212c:	83 c4 20             	add    $0x20,%esp
  80212f:	5e                   	pop    %esi
  802130:	5f                   	pop    %edi
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    
  802133:	90                   	nop
  802134:	89 d1                	mov    %edx,%ecx
  802136:	89 c5                	mov    %eax,%ebp
  802138:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80213c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802140:	eb 8d                	jmp    8020cf <__umoddi3+0xaf>
  802142:	66 90                	xchg   %ax,%ax
  802144:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802148:	72 ea                	jb     802134 <__umoddi3+0x114>
  80214a:	89 f1                	mov    %esi,%ecx
  80214c:	eb 81                	jmp    8020cf <__umoddi3+0xaf>
