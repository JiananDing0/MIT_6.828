
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 a6 0b 00 00       	call   800be7 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 fe 0e 00 00       	call   800f4b <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 05                	jmp    80005e <umain+0x2a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	75 0e                	jne    80006c <umain+0x38>
		sys_yield();
  80005e:	e8 a3 0b 00 00       	call   800c06 <sys_yield>
		return;
  800063:	e9 97 00 00 00       	jmp    8000ff <umain+0xcb>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800068:	f3 90                	pause  
  80006a:	eb 1a                	jmp    800086 <umain+0x52>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800079:	89 f2                	mov    %esi,%edx
  80007b:	c1 e2 07             	shl    $0x7,%edx
  80007e:	29 c2                	sub    %eax,%edx
  800080:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800086:	8b 42 50             	mov    0x50(%edx),%eax
  800089:	85 c0                	test   %eax,%eax
  80008b:	75 db                	jne    800068 <umain+0x34>
  80008d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800092:	e8 6f 0b 00 00       	call   800c06 <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a9:	48                   	dec    %eax
  8000aa:	75 f0                	jne    80009c <umain+0x68>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ac:	4b                   	dec    %ebx
  8000ad:	75 e3                	jne    800092 <umain+0x5e>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000af:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 04 20 80 00       	mov    0x802004,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 60 15 80 	movl   $0x801560,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 88 15 80 00 	movl   $0x801588,(%esp)
  8000db:	e8 90 00 00 00       	call   800170 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 08 20 80 00       	mov    0x802008,%eax
  8000e5:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e8:	8b 40 48             	mov    0x48(%eax),%eax
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 9b 15 80 00 	movl   $0x80159b,(%esp)
  8000fa:	e8 69 01 00 00       	call   800268 <cprintf>

}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
	...

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 10             	sub    $0x10,%esp
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800116:	e8 cc 0a 00 00       	call   800be7 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 f6                	test   %esi,%esi
  800138:	7e 07                	jle    800141 <libmain+0x39>
		binaryname = argv[0];
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014d:	e8 0a 00 00 00       	call   80015c <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800169:	e8 27 0a 00 00       	call   800b95 <sys_env_destroy>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800178:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800181:	e8 61 0a 00 00       	call   800be7 <sys_getenvid>
  800186:	8b 55 0c             	mov    0xc(%ebp),%edx
  800189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800194:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  8001a3:	e8 c0 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 50 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001b7:	c7 04 24 b7 15 80 00 	movl   $0x8015b7,(%esp)
  8001be:	e8 a5 00 00 00       	call   800268 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x53>
	...

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 03                	mov    (%ebx),%eax
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001db:	40                   	inc    %eax
  8001dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	75 19                	jne    8001fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ec:	00 
  8001ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 60 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fe:	ff 43 04             	incl   0x4(%ebx)
}
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	5b                   	pop    %ebx
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800217:	00 00 00 
	b.cnt = 0;
  80021a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800243:	e8 82 01 00 00       	call   8003ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800248:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 f8 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 87 ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    
	...

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	75 08                	jne    8002b0 <printnum+0x2c>
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 57                	ja     800307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b4:	4b                   	dec    %ebx
  8002b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 26 10 00 00       	call   801308 <__udivdi3>
  8002e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f1:	89 fa                	mov    %edi,%edx
  8002f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f6:	e8 89 ff ff ff       	call   800284 <printnum>
  8002fb:	eb 0f                	jmp    80030c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	89 34 24             	mov    %esi,(%esp)
  800304:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800307:	4b                   	dec    %ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f f1                	jg     8002fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	e8 f3 10 00 00       	call   801428 <__umoddi3>
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	0f be 80 e7 15 80 00 	movsbl 0x8015e7(%eax),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800346:	83 c4 3c             	add    $0x3c,%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800391:	8b 10                	mov    (%eax),%edx
  800393:	3b 50 04             	cmp    0x4(%eax),%edx
  800396:	73 08                	jae    8003a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 0a                	mov    %cl,(%edx)
  80039d:	42                   	inc    %edx
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 02 00 00 00       	call   8003ca <vprintfmt>
	va_end(ap);
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 4c             	sub    $0x4c,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 8b 03 00 00    	je     80076e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	46                   	inc    %esi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e5                	jne    8003db <vprintfmt+0x11>
  8003f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	eb 26                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800417:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041b:	eb 1d                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800424:	eb 14                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	eb 08                	jmp    80043a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800432:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	0f b6 06             	movzbl (%esi),%eax
  80043d:	8d 56 01             	lea    0x1(%esi),%edx
  800440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800443:	8a 16                	mov    (%esi),%dl
  800445:	83 ea 23             	sub    $0x23,%edx
  800448:	80 fa 55             	cmp    $0x55,%dl
  80044b:	0f 87 01 03 00 00    	ja     800752 <vprintfmt+0x388>
  800451:	0f b6 d2             	movzbl %dl,%edx
  800454:	ff 24 95 a0 16 80 00 	jmp    *0x8016a0(,%edx,4)
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800463:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800466:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800470:	83 fa 09             	cmp    $0x9,%edx
  800473:	77 2a                	ja     80049f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb eb                	jmp    800463 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800486:	eb 17                	jmp    80049f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048c:	78 98                	js     800426 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800491:	eb a7                	jmp    80043a <vprintfmt+0x70>
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80049d:	eb 9b                	jmp    80043a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a3:	79 95                	jns    80043a <vprintfmt+0x70>
  8004a5:	eb 8b                	jmp    800432 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ab:	eb 8d                	jmp    80043a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c5:	e9 23 ff ff ff       	jmp    8003ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 50 04             	lea    0x4(%eax),%edx
  8004d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	79 02                	jns    8004db <vprintfmt+0x111>
  8004d9:	f7 d8                	neg    %eax
  8004db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004dd:	83 f8 08             	cmp    $0x8,%eax
  8004e0:	7f 0b                	jg     8004ed <vprintfmt+0x123>
  8004e2:	8b 04 85 00 18 80 00 	mov    0x801800(,%eax,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 23                	jne    800510 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f1:	c7 44 24 08 ff 15 80 	movl   $0x8015ff,0x8(%esp)
  8004f8:	00 
  8004f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 9a fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050b:	e9 dd fe ff ff       	jmp    8003ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  80051b:	00 
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 14 24             	mov    %edx,(%esp)
  800526:	e8 77 fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052e:	e9 ba fe ff ff       	jmp    8003ed <vprintfmt+0x23>
  800533:	89 f9                	mov    %edi,%ecx
  800535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	85 f6                	test   %esi,%esi
  800548:	75 05                	jne    80054f <vprintfmt+0x185>
				p = "(null)";
  80054a:	be f8 15 80 00       	mov    $0x8015f8,%esi
			if (width > 0 && padc != '-')
  80054f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800553:	0f 8e 84 00 00 00    	jle    8005dd <vprintfmt+0x213>
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	74 7e                	je     8005dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 ab 02 00 00       	call   800816 <strnlen>
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800573:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800577:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80057d:	89 de                	mov    %ebx,%esi
  80057f:	89 d3                	mov    %edx,%ebx
  800581:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0b                	jmp    800590 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f f1                	jg     800585 <vprintfmt+0x1bb>
  800594:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800597:	89 f3                	mov    %esi,%ebx
  800599:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80059c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	79 05                	jns    8005a8 <vprintfmt+0x1de>
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ab:	29 c2                	sub    %eax,%edx
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b6:	74 18                	je     8005d0 <vprintfmt+0x206>
  8005b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bb:	83 fa 5e             	cmp    $0x5e,%edx
  8005be:	76 10                	jbe    8005d0 <vprintfmt+0x206>
					putch('?', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	eb 0a                	jmp    8005da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	ff 4d e4             	decl   -0x1c(%ebp)
  8005dd:	0f be 06             	movsbl (%esi),%eax
  8005e0:	46                   	inc    %esi
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	74 21                	je     800606 <vprintfmt+0x23c>
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	78 c9                	js     8005b2 <vprintfmt+0x1e8>
  8005e9:	4f                   	dec    %edi
  8005ea:	79 c6                	jns    8005b2 <vprintfmt+0x1e8>
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 de                	mov    %ebx,%esi
  8005f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f4:	eb 18                	jmp    80060e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800601:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800603:	4b                   	dec    %ebx
  800604:	eb 08                	jmp    80060e <vprintfmt+0x244>
  800606:	8b 7d 08             	mov    0x8(%ebp),%edi
  800609:	89 de                	mov    %ebx,%esi
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f e4                	jg     8005f6 <vprintfmt+0x22c>
  800612:	89 7d 08             	mov    %edi,0x8(%ebp)
  800615:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	e9 ce fd ff ff       	jmp    8003ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 10                	jle    800634 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 08             	lea    0x8(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	8b 78 04             	mov    0x4(%eax),%edi
  800632:	eb 26                	jmp    80065a <vprintfmt+0x290>
	else if (lflag)
  800634:	85 c9                	test   %ecx,%ecx
  800636:	74 12                	je     80064a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 30                	mov    (%eax),%esi
  800643:	89 f7                	mov    %esi,%edi
  800645:	c1 ff 1f             	sar    $0x1f,%edi
  800648:	eb 10                	jmp    80065a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	89 f7                	mov    %esi,%edi
  800657:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065a:	85 ff                	test   %edi,%edi
  80065c:	78 0a                	js     800668 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 ac 00 00 00       	jmp    800714 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800676:	f7 de                	neg    %esi
  800678:	83 d7 00             	adc    $0x0,%edi
  80067b:	f7 df                	neg    %edi
			}
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	e9 8d 00 00 00       	jmp    800714 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800687:	89 ca                	mov    %ecx,%edx
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
  80068c:	e8 bd fc ff ff       	call   80034e <getuint>
  800691:	89 c6                	mov    %eax,%esi
  800693:	89 d7                	mov    %edx,%edi
			base = 10;
  800695:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069a:	eb 78                	jmp    800714 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c9:	e9 1f fd ff ff       	jmp    8003ed <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f3:	8b 30                	mov    (%eax),%esi
  8006f5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ff:	eb 13                	jmp    800714 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800701:	89 ca                	mov    %ecx,%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 43 fc ff ff       	call   80034e <getuint>
  80070b:	89 c6                	mov    %eax,%esi
  80070d:	89 d7                	mov    %edx,%edi
			base = 16;
  80070f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800714:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800718:	89 54 24 10          	mov    %edx,0x10(%esp)
  80071c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80071f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800723:	89 44 24 08          	mov    %eax,0x8(%esp)
  800727:	89 34 24             	mov    %esi,(%esp)
  80072a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072e:	89 da                	mov    %ebx,%edx
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	e8 4c fb ff ff       	call   800284 <printnum>
			break;
  800738:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073b:	e9 ad fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800744:	89 04 24             	mov    %eax,(%esp)
  800747:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074d:	e9 9b fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800756:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80075d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800760:	eb 01                	jmp    800763 <vprintfmt+0x399>
  800762:	4e                   	dec    %esi
  800763:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800767:	75 f9                	jne    800762 <vprintfmt+0x398>
  800769:	e9 7f fc ff ff       	jmp    8003ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80076e:	83 c4 4c             	add    $0x4c,%esp
  800771:	5b                   	pop    %ebx
  800772:	5e                   	pop    %esi
  800773:	5f                   	pop    %edi
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 28             	sub    $0x28,%esp
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800782:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800785:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800789:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800793:	85 c0                	test   %eax,%eax
  800795:	74 30                	je     8007c7 <vsnprintf+0x51>
  800797:	85 d2                	test   %edx,%edx
  800799:	7e 33                	jle    8007ce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  8007b7:	e8 0e fc ff ff       	call   8003ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c5:	eb 0c                	jmp    8007d3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cc:	eb 05                	jmp    8007d3 <vsnprintf+0x5d>
  8007ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	89 04 24             	mov    %eax,(%esp)
  8007f6:	e8 7b ff ff ff       	call   800776 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    
  8007fd:	00 00                	add    %al,(%eax)
	...

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 01                	jmp    80080e <strlen+0xe>
		n++;
  80080d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800812:	75 f9                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb 01                	jmp    800827 <strnlen+0x11>
		n++;
  800826:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	39 d0                	cmp    %edx,%eax
  800829:	74 06                	je     800831 <strnlen+0x1b>
  80082b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082f:	75 f5                	jne    800826 <strnlen+0x10>
		n++;
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
  800842:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800845:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800848:	42                   	inc    %edx
  800849:	84 c9                	test   %cl,%cl
  80084b:	75 f5                	jne    800842 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80084d:	5b                   	pop    %ebx
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085a:	89 1c 24             	mov    %ebx,(%esp)
  80085d:	e8 9e ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	89 54 24 04          	mov    %edx,0x4(%esp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 c0 ff ff ff       	call   800833 <strcpy>
	return dst;
}
  800873:	89 d8                	mov    %ebx,%eax
  800875:	83 c4 08             	add    $0x8,%esp
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088e:	eb 0c                	jmp    80089c <strncpy+0x21>
		*dst++ = *src;
  800890:	8a 1a                	mov    (%edx),%bl
  800892:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 3a 01             	cmpb   $0x1,(%edx)
  800898:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	41                   	inc    %ecx
  80089c:	39 f1                	cmp    %esi,%ecx
  80089e:	75 f0                	jne    800890 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008af:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b2:	85 d2                	test   %edx,%edx
  8008b4:	75 0a                	jne    8008c0 <strlcpy+0x1c>
  8008b6:	89 f0                	mov    %esi,%eax
  8008b8:	eb 1a                	jmp    8008d4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ba:	88 18                	mov    %bl,(%eax)
  8008bc:	40                   	inc    %eax
  8008bd:	41                   	inc    %ecx
  8008be:	eb 02                	jmp    8008c2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008c2:	4a                   	dec    %edx
  8008c3:	74 0a                	je     8008cf <strlcpy+0x2b>
  8008c5:	8a 19                	mov    (%ecx),%bl
  8008c7:	84 db                	test   %bl,%bl
  8008c9:	75 ef                	jne    8008ba <strlcpy+0x16>
  8008cb:	89 c2                	mov    %eax,%edx
  8008cd:	eb 02                	jmp    8008d1 <strlcpy+0x2d>
  8008cf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008d1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d4:	29 f0                	sub    %esi,%eax
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5e                   	pop    %esi
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e3:	eb 02                	jmp    8008e7 <strcmp+0xd>
		p++, q++;
  8008e5:	41                   	inc    %ecx
  8008e6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e7:	8a 01                	mov    (%ecx),%al
  8008e9:	84 c0                	test   %al,%al
  8008eb:	74 04                	je     8008f1 <strcmp+0x17>
  8008ed:	3a 02                	cmp    (%edx),%al
  8008ef:	74 f4                	je     8008e5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f1:	0f b6 c0             	movzbl %al,%eax
  8008f4:	0f b6 12             	movzbl (%edx),%edx
  8008f7:	29 d0                	sub    %edx,%eax
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800908:	eb 03                	jmp    80090d <strncmp+0x12>
		n--, p++, q++;
  80090a:	4a                   	dec    %edx
  80090b:	40                   	inc    %eax
  80090c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090d:	85 d2                	test   %edx,%edx
  80090f:	74 14                	je     800925 <strncmp+0x2a>
  800911:	8a 18                	mov    (%eax),%bl
  800913:	84 db                	test   %bl,%bl
  800915:	74 04                	je     80091b <strncmp+0x20>
  800917:	3a 19                	cmp    (%ecx),%bl
  800919:	74 ef                	je     80090a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091b:	0f b6 00             	movzbl (%eax),%eax
  80091e:	0f b6 11             	movzbl (%ecx),%edx
  800921:	29 d0                	sub    %edx,%eax
  800923:	eb 05                	jmp    80092a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092a:	5b                   	pop    %ebx
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800936:	eb 05                	jmp    80093d <strchr+0x10>
		if (*s == c)
  800938:	38 ca                	cmp    %cl,%dl
  80093a:	74 0c                	je     800948 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093c:	40                   	inc    %eax
  80093d:	8a 10                	mov    (%eax),%dl
  80093f:	84 d2                	test   %dl,%dl
  800941:	75 f5                	jne    800938 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800953:	eb 05                	jmp    80095a <strfind+0x10>
		if (*s == c)
  800955:	38 ca                	cmp    %cl,%dl
  800957:	74 07                	je     800960 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800959:	40                   	inc    %eax
  80095a:	8a 10                	mov    (%eax),%dl
  80095c:	84 d2                	test   %dl,%dl
  80095e:	75 f5                	jne    800955 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800971:	85 c9                	test   %ecx,%ecx
  800973:	74 30                	je     8009a5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097b:	75 25                	jne    8009a2 <memset+0x40>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 20                	jne    8009a2 <memset+0x40>
		c &= 0xFF;
  800982:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800985:	89 d3                	mov    %edx,%ebx
  800987:	c1 e3 08             	shl    $0x8,%ebx
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	c1 e6 18             	shl    $0x18,%esi
  80098f:	89 d0                	mov    %edx,%eax
  800991:	c1 e0 10             	shl    $0x10,%eax
  800994:	09 f0                	or     %esi,%eax
  800996:	09 d0                	or     %edx,%eax
  800998:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099d:	fc                   	cld    
  80099e:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a0:	eb 03                	jmp    8009a5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a2:	fc                   	cld    
  8009a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5f                   	pop    %edi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ba:	39 c6                	cmp    %eax,%esi
  8009bc:	73 34                	jae    8009f2 <memmove+0x46>
  8009be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c1:	39 d0                	cmp    %edx,%eax
  8009c3:	73 2d                	jae    8009f2 <memmove+0x46>
		s += n;
		d += n;
  8009c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	f6 c2 03             	test   $0x3,%dl
  8009cb:	75 1b                	jne    8009e8 <memmove+0x3c>
  8009cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d3:	75 13                	jne    8009e8 <memmove+0x3c>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0e                	jne    8009e8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009da:	83 ef 04             	sub    $0x4,%edi
  8009dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e3:	fd                   	std    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb 07                	jmp    8009ef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e8:	4f                   	dec    %edi
  8009e9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ef:	fc                   	cld    
  8009f0:	eb 20                	jmp    800a12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f8:	75 13                	jne    800a0d <memmove+0x61>
  8009fa:	a8 03                	test   $0x3,%al
  8009fc:	75 0f                	jne    800a0d <memmove+0x61>
  8009fe:	f6 c1 03             	test   $0x3,%cl
  800a01:	75 0a                	jne    800a0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	fc                   	cld    
  800a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0b:	eb 05                	jmp    800a12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0d:	89 c7                	mov    %eax,%edi
  800a0f:	fc                   	cld    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	89 04 24             	mov    %eax,(%esp)
  800a30:	e8 77 ff ff ff       	call   8009ac <memmove>
}
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4b:	eb 16                	jmp    800a63 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a50:	42                   	inc    %edx
  800a51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a55:	38 c8                	cmp    %cl,%al
  800a57:	74 0a                	je     800a63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a59:	0f b6 c0             	movzbl %al,%eax
  800a5c:	0f b6 c9             	movzbl %cl,%ecx
  800a5f:	29 c8                	sub    %ecx,%eax
  800a61:	eb 09                	jmp    800a6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	39 da                	cmp    %ebx,%edx
  800a65:	75 e6                	jne    800a4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7a:	89 c2                	mov    %eax,%edx
  800a7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7f:	eb 05                	jmp    800a86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a81:	38 08                	cmp    %cl,(%eax)
  800a83:	74 05                	je     800a8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a85:	40                   	inc    %eax
  800a86:	39 d0                	cmp    %edx,%eax
  800a88:	72 f7                	jb     800a81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a98:	eb 01                	jmp    800a9b <strtol+0xf>
		s++;
  800a9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9b:	8a 02                	mov    (%edx),%al
  800a9d:	3c 20                	cmp    $0x20,%al
  800a9f:	74 f9                	je     800a9a <strtol+0xe>
  800aa1:	3c 09                	cmp    $0x9,%al
  800aa3:	74 f5                	je     800a9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa5:	3c 2b                	cmp    $0x2b,%al
  800aa7:	75 08                	jne    800ab1 <strtol+0x25>
		s++;
  800aa9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aaa:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaf:	eb 13                	jmp    800ac4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab1:	3c 2d                	cmp    $0x2d,%al
  800ab3:	75 0a                	jne    800abf <strtol+0x33>
		s++, neg = 1;
  800ab5:	8d 52 01             	lea    0x1(%edx),%edx
  800ab8:	bf 01 00 00 00       	mov    $0x1,%edi
  800abd:	eb 05                	jmp    800ac4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	85 db                	test   %ebx,%ebx
  800ac6:	74 05                	je     800acd <strtol+0x41>
  800ac8:	83 fb 10             	cmp    $0x10,%ebx
  800acb:	75 28                	jne    800af5 <strtol+0x69>
  800acd:	8a 02                	mov    (%edx),%al
  800acf:	3c 30                	cmp    $0x30,%al
  800ad1:	75 10                	jne    800ae3 <strtol+0x57>
  800ad3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad7:	75 0a                	jne    800ae3 <strtol+0x57>
		s += 2, base = 16;
  800ad9:	83 c2 02             	add    $0x2,%edx
  800adc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae1:	eb 12                	jmp    800af5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ae3:	85 db                	test   %ebx,%ebx
  800ae5:	75 0e                	jne    800af5 <strtol+0x69>
  800ae7:	3c 30                	cmp    $0x30,%al
  800ae9:	75 05                	jne    800af0 <strtol+0x64>
		s++, base = 8;
  800aeb:	42                   	inc    %edx
  800aec:	b3 08                	mov    $0x8,%bl
  800aee:	eb 05                	jmp    800af5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800af0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afc:	8a 0a                	mov    (%edx),%cl
  800afe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b01:	80 fb 09             	cmp    $0x9,%bl
  800b04:	77 08                	ja     800b0e <strtol+0x82>
			dig = *s - '0';
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 30             	sub    $0x30,%ecx
  800b0c:	eb 1e                	jmp    800b2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b11:	80 fb 19             	cmp    $0x19,%bl
  800b14:	77 08                	ja     800b1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b16:	0f be c9             	movsbl %cl,%ecx
  800b19:	83 e9 57             	sub    $0x57,%ecx
  800b1c:	eb 0e                	jmp    800b2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b21:	80 fb 19             	cmp    $0x19,%bl
  800b24:	77 12                	ja     800b38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b26:	0f be c9             	movsbl %cl,%ecx
  800b29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2c:	39 f1                	cmp    %esi,%ecx
  800b2e:	7d 0c                	jge    800b3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b30:	42                   	inc    %edx
  800b31:	0f af c6             	imul   %esi,%eax
  800b34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b36:	eb c4                	jmp    800afc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b38:	89 c1                	mov    %eax,%ecx
  800b3a:	eb 02                	jmp    800b3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b42:	74 05                	je     800b49 <strtol+0xbd>
		*endptr = (char *) s;
  800b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b49:	85 ff                	test   %edi,%edi
  800b4b:	74 04                	je     800b51 <strtol+0xc5>
  800b4d:	89 c8                	mov    %ecx,%eax
  800b4f:	f7 d8                	neg    %eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    
	...

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 28                	jle    800bdf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bc2:	00 
  800bc3:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800bca:	00 
  800bcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd2:	00 
  800bd3:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800bda:	e8 91 f5 ff ff       	call   800170 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdf:	83 c4 2c             	add    $0x2c,%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf7:	89 d1                	mov    %edx,%ecx
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	89 d7                	mov    %edx,%edi
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_yield>:

void
sys_yield(void)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c16:	89 d1                	mov    %edx,%ecx
  800c18:	89 d3                	mov    %edx,%ebx
  800c1a:	89 d7                	mov    %edx,%edi
  800c1c:	89 d6                	mov    %edx,%esi
  800c1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	be 00 00 00 00       	mov    $0x0,%esi
  800c33:	b8 04 00 00 00       	mov    $0x4,%eax
  800c38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 f7                	mov    %esi,%edi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 28                	jle    800c71 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c54:	00 
  800c55:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800c5c:	00 
  800c5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c64:	00 
  800c65:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800c6c:	e8 ff f4 ff ff       	call   800170 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c71:	83 c4 2c             	add    $0x2c,%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	b8 05 00 00 00       	mov    $0x5,%eax
  800c87:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 28                	jle    800cc4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ca7:	00 
  800ca8:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800caf:	00 
  800cb0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb7:	00 
  800cb8:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800cbf:	e8 ac f4 ff ff       	call   800170 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc4:	83 c4 2c             	add    $0x2c,%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 28                	jle    800d17 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800d02:	00 
  800d03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0a:	00 
  800d0b:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800d12:	e8 59 f4 ff ff       	call   800170 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d17:	83 c4 2c             	add    $0x2c,%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	89 df                	mov    %ebx,%edi
  800d3a:	89 de                	mov    %ebx,%esi
  800d3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7e 28                	jle    800d6a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d46:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800d55:	00 
  800d56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5d:	00 
  800d5e:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800d65:	e8 06 f4 ff ff       	call   800170 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d6a:	83 c4 2c             	add    $0x2c,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d80:	b8 09 00 00 00       	mov    $0x9,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 df                	mov    %ebx,%edi
  800d8d:	89 de                	mov    %ebx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 28                	jle    800dbd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d99:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800da0:	00 
  800da1:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800da8:	00 
  800da9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db0:	00 
  800db1:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800db8:	e8 b3 f3 ff ff       	call   800170 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbd:	83 c4 2c             	add    $0x2c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 28                	jle    800e32 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e15:	00 
  800e16:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800e2d:	e8 3e f3 ff ff       	call   800170 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e32:	83 c4 2c             	add    $0x2c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
	...

00800e3c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 24             	sub    $0x24,%esp
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e46:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800e48:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e4c:	75 20                	jne    800e6e <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e4e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e52:	c7 44 24 08 50 18 80 	movl   $0x801850,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  800e69:	e8 02 f3 ff ff       	call   800170 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e6e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e80:	f6 c4 08             	test   $0x8,%ah
  800e83:	75 1c                	jne    800ea1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e85:	c7 44 24 08 80 18 80 	movl   $0x801880,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  800e9c:	e8 cf f2 ff ff       	call   800170 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800ea1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eb0:	00 
  800eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb8:	e8 68 fd ff ff       	call   800c25 <sys_page_alloc>
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	79 20                	jns    800ee1 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800ec1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec5:	c7 44 24 08 da 18 80 	movl   $0x8018da,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  800edc:	e8 8f f2 ff ff       	call   800170 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800ee1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ee8:	00 
  800ee9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eed:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ef4:	e8 b3 fa ff ff       	call   8009ac <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800ef9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f00:	00 
  800f01:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1c:	e8 58 fd ff ff       	call   800c79 <sys_page_map>
  800f21:	85 c0                	test   %eax,%eax
  800f23:	79 20                	jns    800f45 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f29:	c7 44 24 08 ed 18 80 	movl   $0x8018ed,0x8(%esp)
  800f30:	00 
  800f31:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f38:	00 
  800f39:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  800f40:	e8 2b f2 ff ff       	call   800170 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800f45:	83 c4 24             	add    $0x24,%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f54:	c7 04 24 3c 0e 80 00 	movl   $0x800e3c,(%esp)
  800f5b:	e8 e4 02 00 00       	call   801244 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f60:	ba 07 00 00 00       	mov    $0x7,%edx
  800f65:	89 d0                	mov    %edx,%eax
  800f67:	cd 30                	int    $0x30
  800f69:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	79 20                	jns    800f93 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f77:	c7 44 24 08 fe 18 80 	movl   $0x8018fe,0x8(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  800f8e:	e8 dd f1 ff ff       	call   800170 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f93:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f97:	75 25                	jne    800fbe <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f99:	e8 49 fc ff ff       	call   800be7 <sys_getenvid>
  800f9e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800faa:	c1 e0 07             	shl    $0x7,%eax
  800fad:	29 d0                	sub    %edx,%eax
  800faf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb4:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800fb9:	e9 58 02 00 00       	jmp    801216 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800fbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc3:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fc8:	89 f0                	mov    %esi,%eax
  800fca:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fcd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd4:	a8 01                	test   $0x1,%al
  800fd6:	0f 84 7a 01 00 00    	je     801156 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800fdc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fe3:	a8 01                	test   $0x1,%al
  800fe5:	0f 84 6b 01 00 00    	je     801156 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800feb:	a1 08 20 80 00       	mov    0x802008,%eax
  800ff0:	8b 40 48             	mov    0x48(%eax),%eax
  800ff3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800ff6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffd:	f6 c4 04             	test   $0x4,%ah
  801000:	74 52                	je     801054 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801002:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801009:	25 07 0e 00 00       	and    $0xe07,%eax
  80100e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801012:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801016:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801019:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801024:	89 04 24             	mov    %eax,(%esp)
  801027:	e8 4d fc ff ff       	call   800c79 <sys_page_map>
  80102c:	85 c0                	test   %eax,%eax
  80102e:	0f 89 22 01 00 00    	jns    801156 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801034:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801038:	c7 44 24 08 0e 19 80 	movl   $0x80190e,0x8(%esp)
  80103f:	00 
  801040:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801047:	00 
  801048:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  80104f:	e8 1c f1 ff ff       	call   800170 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801054:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105b:	f6 c4 08             	test   $0x8,%ah
  80105e:	75 0f                	jne    80106f <fork+0x124>
  801060:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801067:	a8 02                	test   $0x2,%al
  801069:	0f 84 99 00 00 00    	je     801108 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80106f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801076:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801079:	83 f8 01             	cmp    $0x1,%eax
  80107c:	19 db                	sbb    %ebx,%ebx
  80107e:	83 e3 fc             	and    $0xfffffffc,%ebx
  801081:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801087:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80108b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801092:	89 44 24 08          	mov    %eax,0x8(%esp)
  801096:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80109a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109d:	89 04 24             	mov    %eax,(%esp)
  8010a0:	e8 d4 fb ff ff       	call   800c79 <sys_page_map>
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	79 20                	jns    8010c9 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8010a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ad:	c7 44 24 08 0e 19 80 	movl   $0x80190e,0x8(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010bc:	00 
  8010bd:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  8010c4:	e8 a7 f0 ff ff       	call   800170 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010c9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010dc:	89 04 24             	mov    %eax,(%esp)
  8010df:	e8 95 fb ff ff       	call   800c79 <sys_page_map>
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	79 6e                	jns    801156 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ec:	c7 44 24 08 0e 19 80 	movl   $0x80190e,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  801103:	e8 68 f0 ff ff       	call   800170 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801108:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110f:	25 07 0e 00 00       	and    $0xe07,%eax
  801114:	89 44 24 10          	mov    %eax,0x10(%esp)
  801118:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80111f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801123:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112a:	89 04 24             	mov    %eax,(%esp)
  80112d:	e8 47 fb ff ff       	call   800c79 <sys_page_map>
  801132:	85 c0                	test   %eax,%eax
  801134:	79 20                	jns    801156 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801136:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80113a:	c7 44 24 08 0e 19 80 	movl   $0x80190e,0x8(%esp)
  801141:	00 
  801142:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801149:	00 
  80114a:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  801151:	e8 1a f0 ff ff       	call   800170 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801156:	46                   	inc    %esi
  801157:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80115d:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801163:	0f 85 5f fe ff ff    	jne    800fc8 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801169:	c7 44 24 04 e4 12 80 	movl   $0x8012e4,0x4(%esp)
  801170:	00 
  801171:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801174:	89 04 24             	mov    %eax,(%esp)
  801177:	e8 f6 fb ff ff       	call   800d72 <sys_env_set_pgfault_upcall>
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 20                	jns    8011a0 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 b0 18 80 	movl   $0x8018b0,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  80119b:	e8 d0 ef ff ff       	call   800170 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8011a0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011af:	ee 
  8011b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b3:	89 04 24             	mov    %eax,(%esp)
  8011b6:	e8 6a fa ff ff       	call   800c25 <sys_page_alloc>
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	79 20                	jns    8011df <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8011bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c3:	c7 44 24 08 da 18 80 	movl   $0x8018da,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  8011da:	e8 91 ef ff ff       	call   800170 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011df:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011e6:	00 
  8011e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ea:	89 04 24             	mov    %eax,(%esp)
  8011ed:	e8 2d fb ff ff       	call   800d1f <sys_env_set_status>
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	79 20                	jns    801216 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  8011f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fa:	c7 44 24 08 20 19 80 	movl   $0x801920,0x8(%esp)
  801201:	00 
  801202:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801209:	00 
  80120a:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  801211:	e8 5a ef ff ff       	call   800170 <_panic>
	}
	
	return envid;
}
  801216:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801219:	83 c4 3c             	add    $0x3c,%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <sfork>:

// Challenge!
int
sfork(void)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801227:	c7 44 24 08 37 19 80 	movl   $0x801937,0x8(%esp)
  80122e:	00 
  80122f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801236:	00 
  801237:	c7 04 24 cf 18 80 00 	movl   $0x8018cf,(%esp)
  80123e:	e8 2d ef ff ff       	call   800170 <_panic>
	...

00801244 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80124a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801251:	0f 85 80 00 00 00    	jne    8012d7 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  801257:	a1 08 20 80 00       	mov    0x802008,%eax
  80125c:	8b 40 48             	mov    0x48(%eax),%eax
  80125f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126e:	ee 
  80126f:	89 04 24             	mov    %eax,(%esp)
  801272:	e8 ae f9 ff ff       	call   800c25 <sys_page_alloc>
  801277:	85 c0                	test   %eax,%eax
  801279:	79 20                	jns    80129b <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80127b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127f:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  801286:	00 
  801287:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80128e:	00 
  80128f:	c7 04 24 ac 19 80 00 	movl   $0x8019ac,(%esp)
  801296:	e8 d5 ee ff ff       	call   800170 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80129b:	a1 08 20 80 00       	mov    0x802008,%eax
  8012a0:	8b 40 48             	mov    0x48(%eax),%eax
  8012a3:	c7 44 24 04 e4 12 80 	movl   $0x8012e4,0x4(%esp)
  8012aa:	00 
  8012ab:	89 04 24             	mov    %eax,(%esp)
  8012ae:	e8 bf fa ff ff       	call   800d72 <sys_env_set_pgfault_upcall>
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	79 20                	jns    8012d7 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  8012b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012bb:	c7 44 24 08 7c 19 80 	movl   $0x80197c,0x8(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8012ca:	00 
  8012cb:	c7 04 24 ac 19 80 00 	movl   $0x8019ac,(%esp)
  8012d2:	e8 99 ee ff ff       	call   800170 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    
  8012e1:	00 00                	add    %al,(%eax)
	...

008012e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012e5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8012ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012ec:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8012ef:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8012f3:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8012f5:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8012f8:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8012f9:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8012fc:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8012fe:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  801301:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  801302:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  801305:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801306:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801307:	c3                   	ret    

00801308 <__udivdi3>:
  801308:	55                   	push   %ebp
  801309:	57                   	push   %edi
  80130a:	56                   	push   %esi
  80130b:	83 ec 10             	sub    $0x10,%esp
  80130e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801312:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80131e:	89 cd                	mov    %ecx,%ebp
  801320:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801324:	85 c0                	test   %eax,%eax
  801326:	75 2c                	jne    801354 <__udivdi3+0x4c>
  801328:	39 f9                	cmp    %edi,%ecx
  80132a:	77 68                	ja     801394 <__udivdi3+0x8c>
  80132c:	85 c9                	test   %ecx,%ecx
  80132e:	75 0b                	jne    80133b <__udivdi3+0x33>
  801330:	b8 01 00 00 00       	mov    $0x1,%eax
  801335:	31 d2                	xor    %edx,%edx
  801337:	f7 f1                	div    %ecx
  801339:	89 c1                	mov    %eax,%ecx
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	89 f8                	mov    %edi,%eax
  80133f:	f7 f1                	div    %ecx
  801341:	89 c7                	mov    %eax,%edi
  801343:	89 f0                	mov    %esi,%eax
  801345:	f7 f1                	div    %ecx
  801347:	89 c6                	mov    %eax,%esi
  801349:	89 f0                	mov    %esi,%eax
  80134b:	89 fa                	mov    %edi,%edx
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	5e                   	pop    %esi
  801351:	5f                   	pop    %edi
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    
  801354:	39 f8                	cmp    %edi,%eax
  801356:	77 2c                	ja     801384 <__udivdi3+0x7c>
  801358:	0f bd f0             	bsr    %eax,%esi
  80135b:	83 f6 1f             	xor    $0x1f,%esi
  80135e:	75 4c                	jne    8013ac <__udivdi3+0xa4>
  801360:	39 f8                	cmp    %edi,%eax
  801362:	bf 00 00 00 00       	mov    $0x0,%edi
  801367:	72 0a                	jb     801373 <__udivdi3+0x6b>
  801369:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80136d:	0f 87 ad 00 00 00    	ja     801420 <__udivdi3+0x118>
  801373:	be 01 00 00 00       	mov    $0x1,%esi
  801378:	89 f0                	mov    %esi,%eax
  80137a:	89 fa                	mov    %edi,%edx
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    
  801383:	90                   	nop
  801384:	31 ff                	xor    %edi,%edi
  801386:	31 f6                	xor    %esi,%esi
  801388:	89 f0                	mov    %esi,%eax
  80138a:	89 fa                	mov    %edi,%edx
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	5e                   	pop    %esi
  801390:	5f                   	pop    %edi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    
  801393:	90                   	nop
  801394:	89 fa                	mov    %edi,%edx
  801396:	89 f0                	mov    %esi,%eax
  801398:	f7 f1                	div    %ecx
  80139a:	89 c6                	mov    %eax,%esi
  80139c:	31 ff                	xor    %edi,%edi
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	89 fa                	mov    %edi,%edx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    
  8013a9:	8d 76 00             	lea    0x0(%esi),%esi
  8013ac:	89 f1                	mov    %esi,%ecx
  8013ae:	d3 e0                	shl    %cl,%eax
  8013b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b4:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b9:	29 f0                	sub    %esi,%eax
  8013bb:	89 ea                	mov    %ebp,%edx
  8013bd:	88 c1                	mov    %al,%cl
  8013bf:	d3 ea                	shr    %cl,%edx
  8013c1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013c5:	09 ca                	or     %ecx,%edx
  8013c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013cb:	89 f1                	mov    %esi,%ecx
  8013cd:	d3 e5                	shl    %cl,%ebp
  8013cf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013d3:	89 fd                	mov    %edi,%ebp
  8013d5:	88 c1                	mov    %al,%cl
  8013d7:	d3 ed                	shr    %cl,%ebp
  8013d9:	89 fa                	mov    %edi,%edx
  8013db:	89 f1                	mov    %esi,%ecx
  8013dd:	d3 e2                	shl    %cl,%edx
  8013df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013e3:	88 c1                	mov    %al,%cl
  8013e5:	d3 ef                	shr    %cl,%edi
  8013e7:	09 d7                	or     %edx,%edi
  8013e9:	89 f8                	mov    %edi,%eax
  8013eb:	89 ea                	mov    %ebp,%edx
  8013ed:	f7 74 24 08          	divl   0x8(%esp)
  8013f1:	89 d1                	mov    %edx,%ecx
  8013f3:	89 c7                	mov    %eax,%edi
  8013f5:	f7 64 24 0c          	mull   0xc(%esp)
  8013f9:	39 d1                	cmp    %edx,%ecx
  8013fb:	72 17                	jb     801414 <__udivdi3+0x10c>
  8013fd:	74 09                	je     801408 <__udivdi3+0x100>
  8013ff:	89 fe                	mov    %edi,%esi
  801401:	31 ff                	xor    %edi,%edi
  801403:	e9 41 ff ff ff       	jmp    801349 <__udivdi3+0x41>
  801408:	8b 54 24 04          	mov    0x4(%esp),%edx
  80140c:	89 f1                	mov    %esi,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	39 c2                	cmp    %eax,%edx
  801412:	73 eb                	jae    8013ff <__udivdi3+0xf7>
  801414:	8d 77 ff             	lea    -0x1(%edi),%esi
  801417:	31 ff                	xor    %edi,%edi
  801419:	e9 2b ff ff ff       	jmp    801349 <__udivdi3+0x41>
  80141e:	66 90                	xchg   %ax,%ax
  801420:	31 f6                	xor    %esi,%esi
  801422:	e9 22 ff ff ff       	jmp    801349 <__udivdi3+0x41>
	...

00801428 <__umoddi3>:
  801428:	55                   	push   %ebp
  801429:	57                   	push   %edi
  80142a:	56                   	push   %esi
  80142b:	83 ec 20             	sub    $0x20,%esp
  80142e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801432:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801436:	89 44 24 14          	mov    %eax,0x14(%esp)
  80143a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80143e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801442:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801446:	89 c7                	mov    %eax,%edi
  801448:	89 f2                	mov    %esi,%edx
  80144a:	85 ed                	test   %ebp,%ebp
  80144c:	75 16                	jne    801464 <__umoddi3+0x3c>
  80144e:	39 f1                	cmp    %esi,%ecx
  801450:	0f 86 a6 00 00 00    	jbe    8014fc <__umoddi3+0xd4>
  801456:	f7 f1                	div    %ecx
  801458:	89 d0                	mov    %edx,%eax
  80145a:	31 d2                	xor    %edx,%edx
  80145c:	83 c4 20             	add    $0x20,%esp
  80145f:	5e                   	pop    %esi
  801460:	5f                   	pop    %edi
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    
  801463:	90                   	nop
  801464:	39 f5                	cmp    %esi,%ebp
  801466:	0f 87 ac 00 00 00    	ja     801518 <__umoddi3+0xf0>
  80146c:	0f bd c5             	bsr    %ebp,%eax
  80146f:	83 f0 1f             	xor    $0x1f,%eax
  801472:	89 44 24 10          	mov    %eax,0x10(%esp)
  801476:	0f 84 a8 00 00 00    	je     801524 <__umoddi3+0xfc>
  80147c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801480:	d3 e5                	shl    %cl,%ebp
  801482:	bf 20 00 00 00       	mov    $0x20,%edi
  801487:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80148b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80148f:	89 f9                	mov    %edi,%ecx
  801491:	d3 e8                	shr    %cl,%eax
  801493:	09 e8                	or     %ebp,%eax
  801495:	89 44 24 18          	mov    %eax,0x18(%esp)
  801499:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80149d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014a1:	d3 e0                	shl    %cl,%eax
  8014a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a7:	89 f2                	mov    %esi,%edx
  8014a9:	d3 e2                	shl    %cl,%edx
  8014ab:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014af:	d3 e0                	shl    %cl,%eax
  8014b1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8014b5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014b9:	89 f9                	mov    %edi,%ecx
  8014bb:	d3 e8                	shr    %cl,%eax
  8014bd:	09 d0                	or     %edx,%eax
  8014bf:	d3 ee                	shr    %cl,%esi
  8014c1:	89 f2                	mov    %esi,%edx
  8014c3:	f7 74 24 18          	divl   0x18(%esp)
  8014c7:	89 d6                	mov    %edx,%esi
  8014c9:	f7 64 24 0c          	mull   0xc(%esp)
  8014cd:	89 c5                	mov    %eax,%ebp
  8014cf:	89 d1                	mov    %edx,%ecx
  8014d1:	39 d6                	cmp    %edx,%esi
  8014d3:	72 67                	jb     80153c <__umoddi3+0x114>
  8014d5:	74 75                	je     80154c <__umoddi3+0x124>
  8014d7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014db:	29 e8                	sub    %ebp,%eax
  8014dd:	19 ce                	sbb    %ecx,%esi
  8014df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014e3:	d3 e8                	shr    %cl,%eax
  8014e5:	89 f2                	mov    %esi,%edx
  8014e7:	89 f9                	mov    %edi,%ecx
  8014e9:	d3 e2                	shl    %cl,%edx
  8014eb:	09 d0                	or     %edx,%eax
  8014ed:	89 f2                	mov    %esi,%edx
  8014ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014f3:	d3 ea                	shr    %cl,%edx
  8014f5:	83 c4 20             	add    $0x20,%esp
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    
  8014fc:	85 c9                	test   %ecx,%ecx
  8014fe:	75 0b                	jne    80150b <__umoddi3+0xe3>
  801500:	b8 01 00 00 00       	mov    $0x1,%eax
  801505:	31 d2                	xor    %edx,%edx
  801507:	f7 f1                	div    %ecx
  801509:	89 c1                	mov    %eax,%ecx
  80150b:	89 f0                	mov    %esi,%eax
  80150d:	31 d2                	xor    %edx,%edx
  80150f:	f7 f1                	div    %ecx
  801511:	89 f8                	mov    %edi,%eax
  801513:	e9 3e ff ff ff       	jmp    801456 <__umoddi3+0x2e>
  801518:	89 f2                	mov    %esi,%edx
  80151a:	83 c4 20             	add    $0x20,%esp
  80151d:	5e                   	pop    %esi
  80151e:	5f                   	pop    %edi
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    
  801521:	8d 76 00             	lea    0x0(%esi),%esi
  801524:	39 f5                	cmp    %esi,%ebp
  801526:	72 04                	jb     80152c <__umoddi3+0x104>
  801528:	39 f9                	cmp    %edi,%ecx
  80152a:	77 06                	ja     801532 <__umoddi3+0x10a>
  80152c:	89 f2                	mov    %esi,%edx
  80152e:	29 cf                	sub    %ecx,%edi
  801530:	19 ea                	sbb    %ebp,%edx
  801532:	89 f8                	mov    %edi,%eax
  801534:	83 c4 20             	add    $0x20,%esp
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    
  80153b:	90                   	nop
  80153c:	89 d1                	mov    %edx,%ecx
  80153e:	89 c5                	mov    %eax,%ebp
  801540:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801544:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801548:	eb 8d                	jmp    8014d7 <__umoddi3+0xaf>
  80154a:	66 90                	xchg   %ax,%ax
  80154c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801550:	72 ea                	jb     80153c <__umoddi3+0x114>
  801552:	89 f1                	mov    %esi,%ecx
  801554:	eb 81                	jmp    8014d7 <__umoddi3+0xaf>
