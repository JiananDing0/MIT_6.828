
obj/user/stresssched.debug:     file format elf32-i386


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
  80003c:	e8 ae 0b 00 00       	call   800bef <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 5a 0f 00 00       	call   800fa7 <fork>
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
  80005e:	e8 ab 0b 00 00       	call   800c0e <sys_yield>
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
  800092:	e8 77 0b 00 00       	call   800c0e <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 04 40 80 00    	mov    %edx,0x804004
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
  8000af:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 c8 24 80 00 	movl   $0x8024c8,(%esp)
  8000db:	e8 98 00 00 00       	call   800178 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8000e5:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e8:	8b 40 48             	mov    0x48(%eax),%eax
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 db 24 80 00 	movl   $0x8024db,(%esp)
  8000fa:	e8 71 01 00 00       	call   800270 <cprintf>

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
  800116:	e8 d4 0a 00 00       	call   800bef <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 f6                	test   %esi,%esi
  800138:	7e 07                	jle    800141 <libmain+0x39>
		binaryname = argv[0];
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800162:	e8 20 13 00 00       	call   801487 <close_all>
	sys_env_destroy(0);
  800167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016e:	e8 2a 0a 00 00       	call   800b9d <sys_env_destroy>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
  800175:	00 00                	add    %al,(%eax)
	...

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800189:	e8 61 0a 00 00       	call   800bef <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  8001ab:	e8 c0 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 50 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  8001c6:	e8 a5 00 00 00       	call   800270 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x53>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	40                   	inc    %eax
  8001e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001eb:	75 19                	jne    800206 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f4:	00 
  8001f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 60 09 00 00       	call   800b60 <sys_cputs>
		b->idx = 0;
  800200:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800206:	ff 43 04             	incl   0x4(%ebx)
}
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024b:	e8 82 01 00 00       	call   8003d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 f8 08 00 00       	call   800b60 <sys_cputs>

	return b.cnt;
}
  800268:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800276:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	e8 87 ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    
	...

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d7                	mov    %edx,%edi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ac:	85 c0                	test   %eax,%eax
  8002ae:	75 08                	jne    8002b8 <printnum+0x2c>
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	77 57                	ja     80030f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bc:	4b                   	dec    %ebx
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	e8 4e 1f 00 00       	call   802238 <__udivdi3>
  8002ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 fa                	mov    %edi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 89 ff ff ff       	call   80028c <printnum>
  800303:	eb 0f                	jmp    800314 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	89 34 24             	mov    %esi,(%esp)
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	4b                   	dec    %ebx
  800310:	85 db                	test   %ebx,%ebx
  800312:	7f f1                	jg     800305 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800318:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032a:	00 
  80032b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800334:	89 44 24 04          	mov    %eax,0x4(%esp)
  800338:	e8 1b 20 00 00       	call   802358 <__umoddi3>
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	0f be 80 27 25 80 00 	movsbl 0x802527(%eax),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034e:	83 c4 3c             	add    $0x3c,%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800359:	83 fa 01             	cmp    $0x1,%edx
  80035c:	7e 0e                	jle    80036c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 08             	lea    0x8(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	8b 52 04             	mov    0x4(%edx),%edx
  80036a:	eb 22                	jmp    80038e <getuint+0x38>
	else if (lflag)
  80036c:	85 d2                	test   %edx,%edx
  80036e:	74 10                	je     800380 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 0e                	jmp    80038e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800396:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 08                	jae    8003a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	88 0a                	mov    %cl,(%edx)
  8003a5:	42                   	inc    %edx
  8003a6:	89 10                	mov    %edx,(%eax)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	e8 02 00 00 00       	call   8003d2 <vprintfmt>
	va_end(ap);
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 4c             	sub    $0x4c,%esp
  8003db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003de:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e1:	eb 12                	jmp    8003f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	0f 84 8b 03 00 00    	je     800776 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f5:	0f b6 06             	movzbl (%esi),%eax
  8003f8:	46                   	inc    %esi
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	75 e5                	jne    8003e3 <vprintfmt+0x11>
  8003fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800402:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800409:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	eb 26                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800423:	eb 1d                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 14                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800438:	eb 08                	jmp    800442 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80043d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	0f b6 06             	movzbl (%esi),%eax
  800445:	8d 56 01             	lea    0x1(%esi),%edx
  800448:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044b:	8a 16                	mov    (%esi),%dl
  80044d:	83 ea 23             	sub    $0x23,%edx
  800450:	80 fa 55             	cmp    $0x55,%dl
  800453:	0f 87 01 03 00 00    	ja     80075a <vprintfmt+0x388>
  800459:	0f b6 d2             	movzbl %dl,%edx
  80045c:	ff 24 95 60 26 80 00 	jmp    *0x802660(,%edx,4)
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800466:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800472:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800475:	8d 50 d0             	lea    -0x30(%eax),%edx
  800478:	83 fa 09             	cmp    $0x9,%edx
  80047b:	77 2a                	ja     8004a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047e:	eb eb                	jmp    80046b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048e:	eb 17                	jmp    8004a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800490:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800494:	78 98                	js     80042e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800499:	eb a7                	jmp    800442 <vprintfmt+0x70>
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a5:	eb 9b                	jmp    800442 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ab:	79 95                	jns    800442 <vprintfmt+0x70>
  8004ad:	eb 8b                	jmp    80043a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b3:	eb 8d                	jmp    800442 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cd:	e9 23 ff ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	79 02                	jns    8004e3 <vprintfmt+0x111>
  8004e1:	f7 d8                	neg    %eax
  8004e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e5:	83 f8 0f             	cmp    $0xf,%eax
  8004e8:	7f 0b                	jg     8004f5 <vprintfmt+0x123>
  8004ea:	8b 04 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 23                	jne    800518 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f9:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800500:	00 
  800501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 9a fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 dd fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800518:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051c:	c7 44 24 08 1a 2a 80 	movl   $0x802a1a,0x8(%esp)
  800523:	00 
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	8b 55 08             	mov    0x8(%ebp),%edx
  80052b:	89 14 24             	mov    %edx,(%esp)
  80052e:	e8 77 fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800536:	e9 ba fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
  80053b:	89 f9                	mov    %edi,%ecx
  80053d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800540:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 30                	mov    (%eax),%esi
  80054e:	85 f6                	test   %esi,%esi
  800550:	75 05                	jne    800557 <vprintfmt+0x185>
				p = "(null)";
  800552:	be 38 25 80 00       	mov    $0x802538,%esi
			if (width > 0 && padc != '-')
  800557:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055b:	0f 8e 84 00 00 00    	jle    8005e5 <vprintfmt+0x213>
  800561:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800565:	74 7e                	je     8005e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	e8 ab 02 00 00       	call   80081e <strnlen>
  800573:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800576:	29 c2                	sub    %eax,%edx
  800578:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80057f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800582:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800585:	89 de                	mov    %ebx,%esi
  800587:	89 d3                	mov    %edx,%ebx
  800589:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	eb 0b                	jmp    800598 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80058d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800591:	89 3c 24             	mov    %edi,(%esp)
  800594:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	85 db                	test   %ebx,%ebx
  80059a:	7f f1                	jg     80058d <vprintfmt+0x1bb>
  80059c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059f:	89 f3                	mov    %esi,%ebx
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	79 05                	jns    8005b0 <vprintfmt+0x1de>
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b8:	eb 2b                	jmp    8005e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005be:	74 18                	je     8005d8 <vprintfmt+0x206>
  8005c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c3:	83 fa 5e             	cmp    $0x5e,%edx
  8005c6:	76 10                	jbe    8005d8 <vprintfmt+0x206>
					putch('?', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	eb 0a                	jmp    8005e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e5:	0f be 06             	movsbl (%esi),%eax
  8005e8:	46                   	inc    %esi
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	74 21                	je     80060e <vprintfmt+0x23c>
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	78 c9                	js     8005ba <vprintfmt+0x1e8>
  8005f1:	4f                   	dec    %edi
  8005f2:	79 c6                	jns    8005ba <vprintfmt+0x1e8>
  8005f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f7:	89 de                	mov    %ebx,%esi
  8005f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fc:	eb 18                	jmp    800616 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800609:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	4b                   	dec    %ebx
  80060c:	eb 08                	jmp    800616 <vprintfmt+0x244>
  80060e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800611:	89 de                	mov    %ebx,%esi
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800616:	85 db                	test   %ebx,%ebx
  800618:	7f e4                	jg     8005fe <vprintfmt+0x22c>
  80061a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80061d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800622:	e9 ce fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7e 10                	jle    80063c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 30                	mov    (%eax),%esi
  800637:	8b 78 04             	mov    0x4(%eax),%edi
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x290>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 12                	je     800652 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 30                	mov    (%eax),%esi
  80064b:	89 f7                	mov    %esi,%edi
  80064d:	c1 ff 1f             	sar    $0x1f,%edi
  800650:	eb 10                	jmp    800662 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	89 f7                	mov    %esi,%edi
  80065f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800662:	85 ff                	test   %edi,%edi
  800664:	78 0a                	js     800670 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 ac 00 00 00       	jmp    80071c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067e:	f7 de                	neg    %esi
  800680:	83 d7 00             	adc    $0x0,%edi
  800683:	f7 df                	neg    %edi
			}
			base = 10;
  800685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068a:	e9 8d 00 00 00       	jmp    80071c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068f:	89 ca                	mov    %ecx,%edx
  800691:	8d 45 14             	lea    0x14(%ebp),%eax
  800694:	e8 bd fc ff ff       	call   800356 <getuint>
  800699:	89 c6                	mov    %eax,%esi
  80069b:	89 d7                	mov    %edx,%edi
			base = 10;
  80069d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006a2:	eb 78                	jmp    80071c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006d1:	e9 1f fd ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fb:	8b 30                	mov    (%eax),%esi
  8006fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800702:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800707:	eb 13                	jmp    80071c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800709:	89 ca                	mov    %ecx,%edx
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 43 fc ff ff       	call   800356 <getuint>
  800713:	89 c6                	mov    %eax,%esi
  800715:	89 d7                	mov    %edx,%edi
			base = 16;
  800717:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800720:	89 54 24 10          	mov    %edx,0x10(%esp)
  800724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800727:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80072b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072f:	89 34 24             	mov    %esi,(%esp)
  800732:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800736:	89 da                	mov    %ebx,%edx
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	e8 4c fb ff ff       	call   80028c <printnum>
			break;
  800740:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800743:	e9 ad fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800752:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800755:	e9 9b fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800765:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800768:	eb 01                	jmp    80076b <vprintfmt+0x399>
  80076a:	4e                   	dec    %esi
  80076b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80076f:	75 f9                	jne    80076a <vprintfmt+0x398>
  800771:	e9 7f fc ff ff       	jmp    8003f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800776:	83 c4 4c             	add    $0x4c,%esp
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5f                   	pop    %edi
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 28             	sub    $0x28,%esp
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800791:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800794:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079b:	85 c0                	test   %eax,%eax
  80079d:	74 30                	je     8007cf <vsnprintf+0x51>
  80079f:	85 d2                	test   %edx,%edx
  8007a1:	7e 33                	jle    8007d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  8007bf:	e8 0e fc ff ff       	call   8003d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cd:	eb 0c                	jmp    8007db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d4:	eb 05                	jmp    8007db <vsnprintf+0x5d>
  8007d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	e8 7b ff ff ff       	call   80077e <vsnprintf>
	va_end(ap);

	return rc;
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    
  800805:	00 00                	add    %al,(%eax)
	...

00800808 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	eb 01                	jmp    800816 <strlen+0xe>
		n++;
  800815:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081a:	75 f9                	jne    800815 <strlen+0xd>
		n++;
	return n;
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 01                	jmp    80082f <strnlen+0x11>
		n++;
  80082e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082f:	39 d0                	cmp    %edx,%eax
  800831:	74 06                	je     800839 <strnlen+0x1b>
  800833:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800837:	75 f5                	jne    80082e <strnlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
  80084a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80084d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800850:	42                   	inc    %edx
  800851:	84 c9                	test   %cl,%cl
  800853:	75 f5                	jne    80084a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800855:	5b                   	pop    %ebx
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800862:	89 1c 24             	mov    %ebx,(%esp)
  800865:	e8 9e ff ff ff       	call   800808 <strlen>
	strcpy(dst + len, src);
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800871:	01 d8                	add    %ebx,%eax
  800873:	89 04 24             	mov    %eax,(%esp)
  800876:	e8 c0 ff ff ff       	call   80083b <strcpy>
	return dst;
}
  80087b:	89 d8                	mov    %ebx,%eax
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	5b                   	pop    %ebx
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800891:	b9 00 00 00 00       	mov    $0x0,%ecx
  800896:	eb 0c                	jmp    8008a4 <strncpy+0x21>
		*dst++ = *src;
  800898:	8a 1a                	mov    (%edx),%bl
  80089a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089d:	80 3a 01             	cmpb   $0x1,(%edx)
  8008a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a3:	41                   	inc    %ecx
  8008a4:	39 f1                	cmp    %esi,%ecx
  8008a6:	75 f0                	jne    800898 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
  8008b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ba:	85 d2                	test   %edx,%edx
  8008bc:	75 0a                	jne    8008c8 <strlcpy+0x1c>
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	eb 1a                	jmp    8008dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c2:	88 18                	mov    %bl,(%eax)
  8008c4:	40                   	inc    %eax
  8008c5:	41                   	inc    %ecx
  8008c6:	eb 02                	jmp    8008ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008ca:	4a                   	dec    %edx
  8008cb:	74 0a                	je     8008d7 <strlcpy+0x2b>
  8008cd:	8a 19                	mov    (%ecx),%bl
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	75 ef                	jne    8008c2 <strlcpy+0x16>
  8008d3:	89 c2                	mov    %eax,%edx
  8008d5:	eb 02                	jmp    8008d9 <strlcpy+0x2d>
  8008d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008dc:	29 f0                	sub    %esi,%eax
}
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008eb:	eb 02                	jmp    8008ef <strcmp+0xd>
		p++, q++;
  8008ed:	41                   	inc    %ecx
  8008ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ef:	8a 01                	mov    (%ecx),%al
  8008f1:	84 c0                	test   %al,%al
  8008f3:	74 04                	je     8008f9 <strcmp+0x17>
  8008f5:	3a 02                	cmp    (%edx),%al
  8008f7:	74 f4                	je     8008ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f9:	0f b6 c0             	movzbl %al,%eax
  8008fc:	0f b6 12             	movzbl (%edx),%edx
  8008ff:	29 d0                	sub    %edx,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800910:	eb 03                	jmp    800915 <strncmp+0x12>
		n--, p++, q++;
  800912:	4a                   	dec    %edx
  800913:	40                   	inc    %eax
  800914:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800915:	85 d2                	test   %edx,%edx
  800917:	74 14                	je     80092d <strncmp+0x2a>
  800919:	8a 18                	mov    (%eax),%bl
  80091b:	84 db                	test   %bl,%bl
  80091d:	74 04                	je     800923 <strncmp+0x20>
  80091f:	3a 19                	cmp    (%ecx),%bl
  800921:	74 ef                	je     800912 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800923:	0f b6 00             	movzbl (%eax),%eax
  800926:	0f b6 11             	movzbl (%ecx),%edx
  800929:	29 d0                	sub    %edx,%eax
  80092b:	eb 05                	jmp    800932 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800932:	5b                   	pop    %ebx
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093e:	eb 05                	jmp    800945 <strchr+0x10>
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	74 0c                	je     800950 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800944:	40                   	inc    %eax
  800945:	8a 10                	mov    (%eax),%dl
  800947:	84 d2                	test   %dl,%dl
  800949:	75 f5                	jne    800940 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80095b:	eb 05                	jmp    800962 <strfind+0x10>
		if (*s == c)
  80095d:	38 ca                	cmp    %cl,%dl
  80095f:	74 07                	je     800968 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800961:	40                   	inc    %eax
  800962:	8a 10                	mov    (%eax),%dl
  800964:	84 d2                	test   %dl,%dl
  800966:	75 f5                	jne    80095d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 7d 08             	mov    0x8(%ebp),%edi
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800979:	85 c9                	test   %ecx,%ecx
  80097b:	74 30                	je     8009ad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800983:	75 25                	jne    8009aa <memset+0x40>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 20                	jne    8009aa <memset+0x40>
		c &= 0xFF;
  80098a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098d:	89 d3                	mov    %edx,%ebx
  80098f:	c1 e3 08             	shl    $0x8,%ebx
  800992:	89 d6                	mov    %edx,%esi
  800994:	c1 e6 18             	shl    $0x18,%esi
  800997:	89 d0                	mov    %edx,%eax
  800999:	c1 e0 10             	shl    $0x10,%eax
  80099c:	09 f0                	or     %esi,%eax
  80099e:	09 d0                	or     %edx,%eax
  8009a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a5:	fc                   	cld    
  8009a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a8:	eb 03                	jmp    8009ad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009aa:	fc                   	cld    
  8009ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c2:	39 c6                	cmp    %eax,%esi
  8009c4:	73 34                	jae    8009fa <memmove+0x46>
  8009c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c9:	39 d0                	cmp    %edx,%eax
  8009cb:	73 2d                	jae    8009fa <memmove+0x46>
		s += n;
		d += n;
  8009cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	75 1b                	jne    8009f0 <memmove+0x3c>
  8009d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009db:	75 13                	jne    8009f0 <memmove+0x3c>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 0e                	jne    8009f0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e2:	83 ef 04             	sub    $0x4,%edi
  8009e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009eb:	fd                   	std    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 07                	jmp    8009f7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f0:	4f                   	dec    %edi
  8009f1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f4:	fd                   	std    
  8009f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f7:	fc                   	cld    
  8009f8:	eb 20                	jmp    800a1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a00:	75 13                	jne    800a15 <memmove+0x61>
  800a02:	a8 03                	test   $0x3,%al
  800a04:	75 0f                	jne    800a15 <memmove+0x61>
  800a06:	f6 c1 03             	test   $0x3,%cl
  800a09:	75 0a                	jne    800a15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a0e:	89 c7                	mov    %eax,%edi
  800a10:	fc                   	cld    
  800a11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a13:	eb 05                	jmp    800a1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a15:	89 c7                	mov    %eax,%edi
  800a17:	fc                   	cld    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a24:	8b 45 10             	mov    0x10(%ebp),%eax
  800a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 04 24             	mov    %eax,(%esp)
  800a38:	e8 77 ff ff ff       	call   8009b4 <memmove>
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a53:	eb 16                	jmp    800a6b <memcmp+0x2c>
		if (*s1 != *s2)
  800a55:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a58:	42                   	inc    %edx
  800a59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a5d:	38 c8                	cmp    %cl,%al
  800a5f:	74 0a                	je     800a6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a61:	0f b6 c0             	movzbl %al,%eax
  800a64:	0f b6 c9             	movzbl %cl,%ecx
  800a67:	29 c8                	sub    %ecx,%eax
  800a69:	eb 09                	jmp    800a74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6b:	39 da                	cmp    %ebx,%edx
  800a6d:	75 e6                	jne    800a55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a82:	89 c2                	mov    %eax,%edx
  800a84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a87:	eb 05                	jmp    800a8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a89:	38 08                	cmp    %cl,(%eax)
  800a8b:	74 05                	je     800a92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8d:	40                   	inc    %eax
  800a8e:	39 d0                	cmp    %edx,%eax
  800a90:	72 f7                	jb     800a89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa0:	eb 01                	jmp    800aa3 <strtol+0xf>
		s++;
  800aa2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa3:	8a 02                	mov    (%edx),%al
  800aa5:	3c 20                	cmp    $0x20,%al
  800aa7:	74 f9                	je     800aa2 <strtol+0xe>
  800aa9:	3c 09                	cmp    $0x9,%al
  800aab:	74 f5                	je     800aa2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aad:	3c 2b                	cmp    $0x2b,%al
  800aaf:	75 08                	jne    800ab9 <strtol+0x25>
		s++;
  800ab1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab7:	eb 13                	jmp    800acc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab9:	3c 2d                	cmp    $0x2d,%al
  800abb:	75 0a                	jne    800ac7 <strtol+0x33>
		s++, neg = 1;
  800abd:	8d 52 01             	lea    0x1(%edx),%edx
  800ac0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac5:	eb 05                	jmp    800acc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acc:	85 db                	test   %ebx,%ebx
  800ace:	74 05                	je     800ad5 <strtol+0x41>
  800ad0:	83 fb 10             	cmp    $0x10,%ebx
  800ad3:	75 28                	jne    800afd <strtol+0x69>
  800ad5:	8a 02                	mov    (%edx),%al
  800ad7:	3c 30                	cmp    $0x30,%al
  800ad9:	75 10                	jne    800aeb <strtol+0x57>
  800adb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800adf:	75 0a                	jne    800aeb <strtol+0x57>
		s += 2, base = 16;
  800ae1:	83 c2 02             	add    $0x2,%edx
  800ae4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae9:	eb 12                	jmp    800afd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	75 0e                	jne    800afd <strtol+0x69>
  800aef:	3c 30                	cmp    $0x30,%al
  800af1:	75 05                	jne    800af8 <strtol+0x64>
		s++, base = 8;
  800af3:	42                   	inc    %edx
  800af4:	b3 08                	mov    $0x8,%bl
  800af6:	eb 05                	jmp    800afd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800af8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
  800b02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b04:	8a 0a                	mov    (%edx),%cl
  800b06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b09:	80 fb 09             	cmp    $0x9,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0x82>
			dig = *s - '0';
  800b0e:	0f be c9             	movsbl %cl,%ecx
  800b11:	83 e9 30             	sub    $0x30,%ecx
  800b14:	eb 1e                	jmp    800b34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b19:	80 fb 19             	cmp    $0x19,%bl
  800b1c:	77 08                	ja     800b26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b1e:	0f be c9             	movsbl %cl,%ecx
  800b21:	83 e9 57             	sub    $0x57,%ecx
  800b24:	eb 0e                	jmp    800b34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b29:	80 fb 19             	cmp    $0x19,%bl
  800b2c:	77 12                	ja     800b40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b2e:	0f be c9             	movsbl %cl,%ecx
  800b31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b34:	39 f1                	cmp    %esi,%ecx
  800b36:	7d 0c                	jge    800b44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b38:	42                   	inc    %edx
  800b39:	0f af c6             	imul   %esi,%eax
  800b3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b3e:	eb c4                	jmp    800b04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b40:	89 c1                	mov    %eax,%ecx
  800b42:	eb 02                	jmp    800b46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4a:	74 05                	je     800b51 <strtol+0xbd>
		*endptr = (char *) s;
  800b4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b51:	85 ff                	test   %edi,%edi
  800b53:	74 04                	je     800b59 <strtol+0xc5>
  800b55:	89 c8                	mov    %ecx,%eax
  800b57:	f7 d8                	neg    %eax
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    
	...

00800b60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 c3                	mov    %eax,%ebx
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	89 c6                	mov    %eax,%esi
  800b77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bab:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 cb                	mov    %ecx,%ebx
  800bb5:	89 cf                	mov    %ecx,%edi
  800bb7:	89 ce                	mov    %ecx,%esi
  800bb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 28                	jle    800be7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bca:	00 
  800bcb:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bda:	00 
  800bdb:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800be2:	e8 91 f5 ff ff       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be7:	83 c4 2c             	add    $0x2c,%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_yield>:

void
sys_yield(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	be 00 00 00 00       	mov    $0x0,%esi
  800c3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 f7                	mov    %esi,%edi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 28                	jle    800c79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c5c:	00 
  800c5d:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800c64:	00 
  800c65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6c:	00 
  800c6d:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800c74:	e8 ff f4 ff ff       	call   800178 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c79:	83 c4 2c             	add    $0x2c,%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 28                	jle    800ccc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800caf:	00 
  800cb0:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800cb7:	00 
  800cb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cbf:	00 
  800cc0:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800cc7:	e8 ac f4 ff ff       	call   800178 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ccc:	83 c4 2c             	add    $0x2c,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	89 df                	mov    %ebx,%edi
  800cef:	89 de                	mov    %ebx,%esi
  800cf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 28                	jle    800d1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d02:	00 
  800d03:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800d0a:	00 
  800d0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d12:	00 
  800d13:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800d1a:	e8 59 f4 ff ff       	call   800178 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1f:	83 c4 2c             	add    $0x2c,%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 28                	jle    800d72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d55:	00 
  800d56:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800d5d:	00 
  800d5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d65:	00 
  800d66:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800d6d:	e8 06 f4 ff ff       	call   800178 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d72:	83 c4 2c             	add    $0x2c,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	89 df                	mov    %ebx,%edi
  800d95:	89 de                	mov    %ebx,%esi
  800d97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 28                	jle    800dc5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800da8:	00 
  800da9:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800db0:	00 
  800db1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db8:	00 
  800db9:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800dc0:	e8 b3 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc5:	83 c4 2c             	add    $0x2c,%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 28                	jle    800e18 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dfb:	00 
  800dfc:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800e03:	00 
  800e04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0b:	00 
  800e0c:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e13:	e8 60 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e18:	83 c4 2c             	add    $0x2c,%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 28                	jle    800e8d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e69:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e70:	00 
  800e71:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800e78:	00 
  800e79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e80:	00 
  800e81:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e88:	e8 eb f2 ff ff       	call   800178 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8d:	83 c4 2c             	add    $0x2c,%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
  800e95:	00 00                	add    %al,(%eax)
	...

00800e98 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 24             	sub    $0x24,%esp
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800ea4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea8:	75 20                	jne    800eca <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800eaa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eae:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800ec5:	e8 ae f2 ff ff       	call   800178 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800ed5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800edc:	f6 c4 08             	test   $0x8,%ah
  800edf:	75 1c                	jne    800efd <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ee1:	c7 44 24 08 7c 28 80 	movl   $0x80287c,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800ef8:	e8 7b f2 ff ff       	call   800178 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800efd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f04:	00 
  800f05:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f0c:	00 
  800f0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f14:	e8 14 fd ff ff       	call   800c2d <sys_page_alloc>
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 20                	jns    800f3d <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800f1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f21:	c7 44 24 08 d6 28 80 	movl   $0x8028d6,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800f38:	e8 3b f2 ff ff       	call   800178 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800f3d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f44:	00 
  800f45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f49:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f50:	e8 5f fa ff ff       	call   8009b4 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800f55:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f5c:	00 
  800f5d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f68:	00 
  800f69:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f70:	00 
  800f71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f78:	e8 04 fd ff ff       	call   800c81 <sys_page_map>
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 20                	jns    800fa1 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f85:	c7 44 24 08 e9 28 80 	movl   $0x8028e9,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800f9c:	e8 d7 f1 ff ff       	call   800178 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800fa1:	83 c4 24             	add    $0x24,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800fb0:	c7 04 24 98 0e 80 00 	movl   $0x800e98,(%esp)
  800fb7:	e8 5c 10 00 00       	call   802018 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fbc:	ba 07 00 00 00       	mov    $0x7,%edx
  800fc1:	89 d0                	mov    %edx,%eax
  800fc3:	cd 30                	int    $0x30
  800fc5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	79 20                	jns    800fef <fork+0x48>
		panic("sys_exofork: %e", envid);
  800fcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd3:	c7 44 24 08 fa 28 80 	movl   $0x8028fa,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800fea:	e8 89 f1 ff ff       	call   800178 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800fef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ff3:	75 25                	jne    80101a <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff5:	e8 f5 fb ff ff       	call   800bef <sys_getenvid>
  800ffa:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801006:	c1 e0 07             	shl    $0x7,%eax
  801009:	29 d0                	sub    %edx,%eax
  80100b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801010:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801015:	e9 58 02 00 00       	jmp    801272 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  80101a:	bf 00 00 00 00       	mov    $0x0,%edi
  80101f:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801024:	89 f0                	mov    %esi,%eax
  801026:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801030:	a8 01                	test   $0x1,%al
  801032:	0f 84 7a 01 00 00    	je     8011b2 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801038:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80103f:	a8 01                	test   $0x1,%al
  801041:	0f 84 6b 01 00 00    	je     8011b2 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801047:	a1 08 40 80 00       	mov    0x804008,%eax
  80104c:	8b 40 48             	mov    0x48(%eax),%eax
  80104f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801052:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801059:	f6 c4 04             	test   $0x4,%ah
  80105c:	74 52                	je     8010b0 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80105e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801065:	25 07 0e 00 00       	and    $0xe07,%eax
  80106a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801072:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801075:	89 44 24 08          	mov    %eax,0x8(%esp)
  801079:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80107d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801080:	89 04 24             	mov    %eax,(%esp)
  801083:	e8 f9 fb ff ff       	call   800c81 <sys_page_map>
  801088:	85 c0                	test   %eax,%eax
  80108a:	0f 89 22 01 00 00    	jns    8011b2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801090:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801094:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  80109b:	00 
  80109c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8010a3:	00 
  8010a4:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8010ab:	e8 c8 f0 ff ff       	call   800178 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8010b0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b7:	f6 c4 08             	test   $0x8,%ah
  8010ba:	75 0f                	jne    8010cb <fork+0x124>
  8010bc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010c3:	a8 02                	test   $0x2,%al
  8010c5:	0f 84 99 00 00 00    	je     801164 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8010cb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d2:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8010d5:	83 f8 01             	cmp    $0x1,%eax
  8010d8:	19 db                	sbb    %ebx,%ebx
  8010da:	83 e3 fc             	and    $0xfffffffc,%ebx
  8010dd:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f9:	89 04 24             	mov    %eax,(%esp)
  8010fc:	e8 80 fb ff ff       	call   800c81 <sys_page_map>
  801101:	85 c0                	test   %eax,%eax
  801103:	79 20                	jns    801125 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801105:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801109:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  801110:	00 
  801111:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801118:	00 
  801119:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  801120:	e8 53 f0 ff ff       	call   800178 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801125:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801129:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801130:	89 44 24 08          	mov    %eax,0x8(%esp)
  801134:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801138:	89 04 24             	mov    %eax,(%esp)
  80113b:	e8 41 fb ff ff       	call   800c81 <sys_page_map>
  801140:	85 c0                	test   %eax,%eax
  801142:	79 6e                	jns    8011b2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801144:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801148:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  80114f:	00 
  801150:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801157:	00 
  801158:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  80115f:	e8 14 f0 ff ff       	call   800178 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801164:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116b:	25 07 0e 00 00       	and    $0xe07,%eax
  801170:	89 44 24 10          	mov    %eax,0x10(%esp)
  801174:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801178:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80117b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801183:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801186:	89 04 24             	mov    %eax,(%esp)
  801189:	e8 f3 fa ff ff       	call   800c81 <sys_page_map>
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 20                	jns    8011b2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801196:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8011ad:	e8 c6 ef ff ff       	call   800178 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8011b2:	46                   	inc    %esi
  8011b3:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011b9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8011bf:	0f 85 5f fe ff ff    	jne    801024 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8011c5:	c7 44 24 04 b8 20 80 	movl   $0x8020b8,0x4(%esp)
  8011cc:	00 
  8011cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	e8 f5 fb ff ff       	call   800dcd <sys_env_set_pgfault_upcall>
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	79 20                	jns    8011fc <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e0:	c7 44 24 08 ac 28 80 	movl   $0x8028ac,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011ef:	00 
  8011f0:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8011f7:	e8 7c ef ff ff       	call   800178 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8011fc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801203:	00 
  801204:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80120b:	ee 
  80120c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120f:	89 04 24             	mov    %eax,(%esp)
  801212:	e8 16 fa ff ff       	call   800c2d <sys_page_alloc>
  801217:	85 c0                	test   %eax,%eax
  801219:	79 20                	jns    80123b <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80121b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121f:	c7 44 24 08 d6 28 80 	movl   $0x8028d6,0x8(%esp)
  801226:	00 
  801227:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  80122e:	00 
  80122f:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  801236:	e8 3d ef ff ff       	call   800178 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80123b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801242:	00 
  801243:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801246:	89 04 24             	mov    %eax,(%esp)
  801249:	e8 d9 fa ff ff       	call   800d27 <sys_env_set_status>
  80124e:	85 c0                	test   %eax,%eax
  801250:	79 20                	jns    801272 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801252:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801256:	c7 44 24 08 1c 29 80 	movl   $0x80291c,0x8(%esp)
  80125d:	00 
  80125e:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801265:	00 
  801266:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  80126d:	e8 06 ef ff ff       	call   800178 <_panic>
	}
	
	return envid;
}
  801272:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801275:	83 c4 3c             	add    $0x3c,%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sfork>:

// Challenge!
int
sfork(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801283:	c7 44 24 08 33 29 80 	movl   $0x802933,0x8(%esp)
  80128a:	00 
  80128b:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801292:	00 
  801293:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  80129a:	e8 d9 ee ff ff       	call   800178 <_panic>
	...

008012a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b9:	89 04 24             	mov    %eax,(%esp)
  8012bc:	e8 df ff ff ff       	call   8012a0 <fd2num>
  8012c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8012c9:	c9                   	leave  
  8012ca:	c3                   	ret    

008012cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	53                   	push   %ebx
  8012cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012d7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	c1 ea 16             	shr    $0x16,%edx
  8012de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e5:	f6 c2 01             	test   $0x1,%dl
  8012e8:	74 11                	je     8012fb <fd_alloc+0x30>
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	c1 ea 0c             	shr    $0xc,%edx
  8012ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	75 09                	jne    801304 <fd_alloc+0x39>
			*fd_store = fd;
  8012fb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	eb 17                	jmp    80131b <fd_alloc+0x50>
  801304:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801309:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130e:	75 c7                	jne    8012d7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801310:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801316:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131b:	5b                   	pop    %ebx
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801324:	83 f8 1f             	cmp    $0x1f,%eax
  801327:	77 36                	ja     80135f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801329:	05 00 00 0d 00       	add    $0xd0000,%eax
  80132e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 16             	shr    $0x16,%edx
  801336:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 24                	je     801366 <fd_lookup+0x48>
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 0c             	shr    $0xc,%edx
  801347:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	74 1a                	je     80136d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801353:	8b 55 0c             	mov    0xc(%ebp),%edx
  801356:	89 02                	mov    %eax,(%edx)
	return 0;
  801358:	b8 00 00 00 00       	mov    $0x0,%eax
  80135d:	eb 13                	jmp    801372 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801364:	eb 0c                	jmp    801372 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801366:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136b:	eb 05                	jmp    801372 <fd_lookup+0x54>
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 14             	sub    $0x14,%esp
  80137b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	eb 0e                	jmp    801396 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801388:	39 08                	cmp    %ecx,(%eax)
  80138a:	75 09                	jne    801395 <dev_lookup+0x21>
			*dev = devtab[i];
  80138c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	eb 33                	jmp    8013c8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801395:	42                   	inc    %edx
  801396:	8b 04 95 c8 29 80 00 	mov    0x8029c8(,%edx,4),%eax
  80139d:	85 c0                	test   %eax,%eax
  80139f:	75 e7                	jne    801388 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a6:	8b 40 48             	mov    0x48(%eax),%eax
  8013a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  8013b8:	e8 b3 ee ff ff       	call   800270 <cprintf>
	*dev = 0;
  8013bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c8:	83 c4 14             	add    $0x14,%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 30             	sub    $0x30,%esp
  8013d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d9:	8a 45 0c             	mov    0xc(%ebp),%al
  8013dc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013df:	89 34 24             	mov    %esi,(%esp)
  8013e2:	e8 b9 fe ff ff       	call   8012a0 <fd2num>
  8013e7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013ee:	89 04 24             	mov    %eax,(%esp)
  8013f1:	e8 28 ff ff ff       	call   80131e <fd_lookup>
  8013f6:	89 c3                	mov    %eax,%ebx
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 05                	js     801401 <fd_close+0x33>
	    || fd != fd2)
  8013fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ff:	74 0d                	je     80140e <fd_close+0x40>
		return (must_exist ? r : 0);
  801401:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801405:	75 46                	jne    80144d <fd_close+0x7f>
  801407:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140c:	eb 3f                	jmp    80144d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801411:	89 44 24 04          	mov    %eax,0x4(%esp)
  801415:	8b 06                	mov    (%esi),%eax
  801417:	89 04 24             	mov    %eax,(%esp)
  80141a:	e8 55 ff ff ff       	call   801374 <dev_lookup>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	85 c0                	test   %eax,%eax
  801423:	78 18                	js     80143d <fd_close+0x6f>
		if (dev->dev_close)
  801425:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801428:	8b 40 10             	mov    0x10(%eax),%eax
  80142b:	85 c0                	test   %eax,%eax
  80142d:	74 09                	je     801438 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80142f:	89 34 24             	mov    %esi,(%esp)
  801432:	ff d0                	call   *%eax
  801434:	89 c3                	mov    %eax,%ebx
  801436:	eb 05                	jmp    80143d <fd_close+0x6f>
		else
			r = 0;
  801438:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80143d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801448:	e8 87 f8 ff ff       	call   800cd4 <sys_page_unmap>
	return r;
}
  80144d:	89 d8                	mov    %ebx,%eax
  80144f:	83 c4 30             	add    $0x30,%esp
  801452:	5b                   	pop    %ebx
  801453:	5e                   	pop    %esi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	89 04 24             	mov    %eax,(%esp)
  801469:	e8 b0 fe ff ff       	call   80131e <fd_lookup>
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 13                	js     801485 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801472:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801479:	00 
  80147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147d:	89 04 24             	mov    %eax,(%esp)
  801480:	e8 49 ff ff ff       	call   8013ce <fd_close>
}
  801485:	c9                   	leave  
  801486:	c3                   	ret    

00801487 <close_all>:

void
close_all(void)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	53                   	push   %ebx
  80148b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801493:	89 1c 24             	mov    %ebx,(%esp)
  801496:	e8 bb ff ff ff       	call   801456 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149b:	43                   	inc    %ebx
  80149c:	83 fb 20             	cmp    $0x20,%ebx
  80149f:	75 f2                	jne    801493 <close_all+0xc>
		close(i);
}
  8014a1:	83 c4 14             	add    $0x14,%esp
  8014a4:	5b                   	pop    %ebx
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	57                   	push   %edi
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 4c             	sub    $0x4c,%esp
  8014b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	e8 59 fe ff ff       	call   80131e <fd_lookup>
  8014c5:	89 c3                	mov    %eax,%ebx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	0f 88 e1 00 00 00    	js     8015b0 <dup+0x109>
		return r;
	close(newfdnum);
  8014cf:	89 3c 24             	mov    %edi,(%esp)
  8014d2:	e8 7f ff ff ff       	call   801456 <close>

	newfd = INDEX2FD(newfdnum);
  8014d7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014dd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e3:	89 04 24             	mov    %eax,(%esp)
  8014e6:	e8 c5 fd ff ff       	call   8012b0 <fd2data>
  8014eb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014ed:	89 34 24             	mov    %esi,(%esp)
  8014f0:	e8 bb fd ff ff       	call   8012b0 <fd2data>
  8014f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	c1 e8 16             	shr    $0x16,%eax
  8014fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801504:	a8 01                	test   $0x1,%al
  801506:	74 46                	je     80154e <dup+0xa7>
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	c1 e8 0c             	shr    $0xc,%eax
  80150d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801514:	f6 c2 01             	test   $0x1,%dl
  801517:	74 35                	je     80154e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801519:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801520:	25 07 0e 00 00       	and    $0xe07,%eax
  801525:	89 44 24 10          	mov    %eax,0x10(%esp)
  801529:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80152c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801530:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801537:	00 
  801538:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801543:	e8 39 f7 ff ff       	call   800c81 <sys_page_map>
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 3b                	js     801589 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80154e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801551:	89 c2                	mov    %eax,%edx
  801553:	c1 ea 0c             	shr    $0xc,%edx
  801556:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801563:	89 54 24 10          	mov    %edx,0x10(%esp)
  801567:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80156b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801572:	00 
  801573:	89 44 24 04          	mov    %eax,0x4(%esp)
  801577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157e:	e8 fe f6 ff ff       	call   800c81 <sys_page_map>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	85 c0                	test   %eax,%eax
  801587:	79 25                	jns    8015ae <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801589:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801594:	e8 3b f7 ff ff       	call   800cd4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801599:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80159c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a7:	e8 28 f7 ff ff       	call   800cd4 <sys_page_unmap>
	return r;
  8015ac:	eb 02                	jmp    8015b0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015ae:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	83 c4 4c             	add    $0x4c,%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5f                   	pop    %edi
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    

008015ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 24             	sub    $0x24,%esp
  8015c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cb:	89 1c 24             	mov    %ebx,(%esp)
  8015ce:	e8 4b fd ff ff       	call   80131e <fd_lookup>
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 6d                	js     801644 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	8b 00                	mov    (%eax),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 89 fd ff ff       	call   801374 <dev_lookup>
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 55                	js     801644 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	8b 50 08             	mov    0x8(%eax),%edx
  8015f5:	83 e2 03             	and    $0x3,%edx
  8015f8:	83 fa 01             	cmp    $0x1,%edx
  8015fb:	75 23                	jne    801620 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fd:	a1 08 40 80 00       	mov    0x804008,%eax
  801602:	8b 40 48             	mov    0x48(%eax),%eax
  801605:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160d:	c7 04 24 8d 29 80 00 	movl   $0x80298d,(%esp)
  801614:	e8 57 ec ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  801619:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161e:	eb 24                	jmp    801644 <read+0x8a>
	}
	if (!dev->dev_read)
  801620:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801623:	8b 52 08             	mov    0x8(%edx),%edx
  801626:	85 d2                	test   %edx,%edx
  801628:	74 15                	je     80163f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80162a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80162d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801631:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801634:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801638:	89 04 24             	mov    %eax,(%esp)
  80163b:	ff d2                	call   *%edx
  80163d:	eb 05                	jmp    801644 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80163f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801644:	83 c4 24             	add    $0x24,%esp
  801647:	5b                   	pop    %ebx
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	57                   	push   %edi
  80164e:	56                   	push   %esi
  80164f:	53                   	push   %ebx
  801650:	83 ec 1c             	sub    $0x1c,%esp
  801653:	8b 7d 08             	mov    0x8(%ebp),%edi
  801656:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801659:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165e:	eb 23                	jmp    801683 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801660:	89 f0                	mov    %esi,%eax
  801662:	29 d8                	sub    %ebx,%eax
  801664:	89 44 24 08          	mov    %eax,0x8(%esp)
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	01 d8                	add    %ebx,%eax
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	89 3c 24             	mov    %edi,(%esp)
  801674:	e8 41 ff ff ff       	call   8015ba <read>
		if (m < 0)
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 10                	js     80168d <readn+0x43>
			return m;
		if (m == 0)
  80167d:	85 c0                	test   %eax,%eax
  80167f:	74 0a                	je     80168b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801681:	01 c3                	add    %eax,%ebx
  801683:	39 f3                	cmp    %esi,%ebx
  801685:	72 d9                	jb     801660 <readn+0x16>
  801687:	89 d8                	mov    %ebx,%eax
  801689:	eb 02                	jmp    80168d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80168b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80168d:	83 c4 1c             	add    $0x1c,%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 24             	sub    $0x24,%esp
  80169c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	89 1c 24             	mov    %ebx,(%esp)
  8016a9:	e8 70 fc ff ff       	call   80131e <fd_lookup>
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 68                	js     80171a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bc:	8b 00                	mov    (%eax),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 ae fc ff ff       	call   801374 <dev_lookup>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 50                	js     80171a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d1:	75 23                	jne    8016f6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8016d8:	8b 40 48             	mov    0x48(%eax),%eax
  8016db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e3:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
  8016ea:	e8 81 eb ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  8016ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f4:	eb 24                	jmp    80171a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	74 15                	je     801715 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801700:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801703:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	ff d2                	call   *%edx
  801713:	eb 05                	jmp    80171a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801715:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80171a:	83 c4 24             	add    $0x24,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <seek>:

int
seek(int fdnum, off_t offset)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801726:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172d:	8b 45 08             	mov    0x8(%ebp),%eax
  801730:	89 04 24             	mov    %eax,(%esp)
  801733:	e8 e6 fb ff ff       	call   80131e <fd_lookup>
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 0e                	js     80174a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80173c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80173f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801742:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 24             	sub    $0x24,%esp
  801753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	89 1c 24             	mov    %ebx,(%esp)
  801760:	e8 b9 fb ff ff       	call   80131e <fd_lookup>
  801765:	85 c0                	test   %eax,%eax
  801767:	78 61                	js     8017ca <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801773:	8b 00                	mov    (%eax),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 f7 fb ff ff       	call   801374 <dev_lookup>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 49                	js     8017ca <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801788:	75 23                	jne    8017ad <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80178a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80178f:	8b 40 48             	mov    0x48(%eax),%eax
  801792:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179a:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  8017a1:	e8 ca ea ff ff       	call   800270 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ab:	eb 1d                	jmp    8017ca <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b0:	8b 52 18             	mov    0x18(%edx),%edx
  8017b3:	85 d2                	test   %edx,%edx
  8017b5:	74 0e                	je     8017c5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	ff d2                	call   *%edx
  8017c3:	eb 05                	jmp    8017ca <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017ca:	83 c4 24             	add    $0x24,%esp
  8017cd:	5b                   	pop    %ebx
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 24             	sub    $0x24,%esp
  8017d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	89 04 24             	mov    %eax,(%esp)
  8017e7:	e8 32 fb ff ff       	call   80131e <fd_lookup>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 52                	js     801842 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	8b 00                	mov    (%eax),%eax
  8017fc:	89 04 24             	mov    %eax,(%esp)
  8017ff:	e8 70 fb ff ff       	call   801374 <dev_lookup>
  801804:	85 c0                	test   %eax,%eax
  801806:	78 3a                	js     801842 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180f:	74 2c                	je     80183d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801811:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801814:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181b:	00 00 00 
	stat->st_isdir = 0;
  80181e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801825:	00 00 00 
	stat->st_dev = dev;
  801828:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801832:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801835:	89 14 24             	mov    %edx,(%esp)
  801838:	ff 50 14             	call   *0x14(%eax)
  80183b:	eb 05                	jmp    801842 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80183d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801842:	83 c4 24             	add    $0x24,%esp
  801845:	5b                   	pop    %ebx
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801850:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801857:	00 
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 fe 01 00 00       	call   801a61 <open>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	85 c0                	test   %eax,%eax
  801867:	78 1b                	js     801884 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	89 1c 24             	mov    %ebx,(%esp)
  801873:	e8 58 ff ff ff       	call   8017d0 <fstat>
  801878:	89 c6                	mov    %eax,%esi
	close(fd);
  80187a:	89 1c 24             	mov    %ebx,(%esp)
  80187d:	e8 d4 fb ff ff       	call   801456 <close>
	return r;
  801882:	89 f3                	mov    %esi,%ebx
}
  801884:	89 d8                	mov    %ebx,%eax
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	5b                   	pop    %ebx
  80188a:	5e                   	pop    %esi
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    
  80188d:	00 00                	add    %al,(%eax)
	...

00801890 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	83 ec 10             	sub    $0x10,%esp
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80189c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a3:	75 11                	jne    8018b6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018ac:	e8 fc 08 00 00       	call   8021ad <ipc_find_env>
  8018b1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018bd:	00 
  8018be:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018c5:	00 
  8018c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ca:	a1 00 40 80 00       	mov    0x804000,%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 6c 08 00 00       	call   802143 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018de:	00 
  8018df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ea:	e8 ed 07 00 00       	call   8020dc <ipc_recv>
}
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    

008018f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801902:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 02 00 00 00       	mov    $0x2,%eax
  801919:	e8 72 ff ff ff       	call   801890 <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	8b 40 0c             	mov    0xc(%eax),%eax
  80192c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
  801936:	b8 06 00 00 00       	mov    $0x6,%eax
  80193b:	e8 50 ff ff ff       	call   801890 <fsipc>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	53                   	push   %ebx
  801946:	83 ec 14             	sub    $0x14,%esp
  801949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
  80194f:	8b 40 0c             	mov    0xc(%eax),%eax
  801952:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801957:	ba 00 00 00 00       	mov    $0x0,%edx
  80195c:	b8 05 00 00 00       	mov    $0x5,%eax
  801961:	e8 2a ff ff ff       	call   801890 <fsipc>
  801966:	85 c0                	test   %eax,%eax
  801968:	78 2b                	js     801995 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80196a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801971:	00 
  801972:	89 1c 24             	mov    %ebx,(%esp)
  801975:	e8 c1 ee ff ff       	call   80083b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80197a:	a1 80 50 80 00       	mov    0x805080,%eax
  80197f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801985:	a1 84 50 80 00       	mov    0x805084,%eax
  80198a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801995:	83 c4 14             	add    $0x14,%esp
  801998:	5b                   	pop    %ebx
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019a1:	c7 44 24 08 d8 29 80 	movl   $0x8029d8,0x8(%esp)
  8019a8:	00 
  8019a9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8019b0:	00 
  8019b1:	c7 04 24 f6 29 80 00 	movl   $0x8029f6,(%esp)
  8019b8:	e8 bb e7 ff ff       	call   800178 <_panic>

008019bd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	56                   	push   %esi
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 10             	sub    $0x10,%esp
  8019c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e3:	e8 a8 fe ff ff       	call   801890 <fsipc>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 6a                	js     801a58 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019ee:	39 c6                	cmp    %eax,%esi
  8019f0:	73 24                	jae    801a16 <devfile_read+0x59>
  8019f2:	c7 44 24 0c 01 2a 80 	movl   $0x802a01,0xc(%esp)
  8019f9:	00 
  8019fa:	c7 44 24 08 08 2a 80 	movl   $0x802a08,0x8(%esp)
  801a01:	00 
  801a02:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a09:	00 
  801a0a:	c7 04 24 f6 29 80 00 	movl   $0x8029f6,(%esp)
  801a11:	e8 62 e7 ff ff       	call   800178 <_panic>
	assert(r <= PGSIZE);
  801a16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a1b:	7e 24                	jle    801a41 <devfile_read+0x84>
  801a1d:	c7 44 24 0c 1d 2a 80 	movl   $0x802a1d,0xc(%esp)
  801a24:	00 
  801a25:	c7 44 24 08 08 2a 80 	movl   $0x802a08,0x8(%esp)
  801a2c:	00 
  801a2d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a34:	00 
  801a35:	c7 04 24 f6 29 80 00 	movl   $0x8029f6,(%esp)
  801a3c:	e8 37 e7 ff ff       	call   800178 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a41:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a45:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a4c:	00 
  801a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	e8 5c ef ff ff       	call   8009b4 <memmove>
	return r;
}
  801a58:	89 d8                	mov    %ebx,%eax
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	5b                   	pop    %ebx
  801a5e:	5e                   	pop    %esi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	83 ec 20             	sub    $0x20,%esp
  801a69:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a6c:	89 34 24             	mov    %esi,(%esp)
  801a6f:	e8 94 ed ff ff       	call   800808 <strlen>
  801a74:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a79:	7f 60                	jg     801adb <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 45 f8 ff ff       	call   8012cb <fd_alloc>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 54                	js     801ae0 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a90:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a97:	e8 9f ed ff ff       	call   80083b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  801aac:	e8 df fd ff ff       	call   801890 <fsipc>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	79 15                	jns    801acc <open+0x6b>
		fd_close(fd, 0);
  801ab7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801abe:	00 
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 04 f9 ff ff       	call   8013ce <fd_close>
		return r;
  801aca:	eb 14                	jmp    801ae0 <open+0x7f>
	}

	return fd2num(fd);
  801acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 c9 f7 ff ff       	call   8012a0 <fd2num>
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	eb 05                	jmp    801ae0 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801adb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ae0:	89 d8                	mov    %ebx,%eax
  801ae2:	83 c4 20             	add    $0x20,%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 08 00 00 00       	mov    $0x8,%eax
  801af9:	e8 92 fd ff ff       	call   801890 <fsipc>
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	83 ec 10             	sub    $0x10,%esp
  801b08:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 9a f7 ff ff       	call   8012b0 <fd2data>
  801b16:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b18:	c7 44 24 04 29 2a 80 	movl   $0x802a29,0x4(%esp)
  801b1f:	00 
  801b20:	89 34 24             	mov    %esi,(%esp)
  801b23:	e8 13 ed ff ff       	call   80083b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b28:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2b:	2b 03                	sub    (%ebx),%eax
  801b2d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b33:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b3a:	00 00 00 
	stat->st_dev = &devpipe;
  801b3d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b44:	30 80 00 
	return 0;
}
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	83 ec 14             	sub    $0x14,%esp
  801b5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b68:	e8 67 f1 ff ff       	call   800cd4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b6d:	89 1c 24             	mov    %ebx,(%esp)
  801b70:	e8 3b f7 ff ff       	call   8012b0 <fd2data>
  801b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b80:	e8 4f f1 ff ff       	call   800cd4 <sys_page_unmap>
}
  801b85:	83 c4 14             	add    $0x14,%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	57                   	push   %edi
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 2c             	sub    $0x2c,%esp
  801b94:	89 c7                	mov    %eax,%edi
  801b96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b99:	a1 08 40 80 00       	mov    0x804008,%eax
  801b9e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ba1:	89 3c 24             	mov    %edi,(%esp)
  801ba4:	e8 4b 06 00 00       	call   8021f4 <pageref>
  801ba9:	89 c6                	mov    %eax,%esi
  801bab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bae:	89 04 24             	mov    %eax,(%esp)
  801bb1:	e8 3e 06 00 00       	call   8021f4 <pageref>
  801bb6:	39 c6                	cmp    %eax,%esi
  801bb8:	0f 94 c0             	sete   %al
  801bbb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bbe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bc4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc7:	39 cb                	cmp    %ecx,%ebx
  801bc9:	75 08                	jne    801bd3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801bcb:	83 c4 2c             	add    $0x2c,%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801bd3:	83 f8 01             	cmp    $0x1,%eax
  801bd6:	75 c1                	jne    801b99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bd8:	8b 42 58             	mov    0x58(%edx),%eax
  801bdb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801be2:	00 
  801be3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801beb:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801bf2:	e8 79 e6 ff ff       	call   800270 <cprintf>
  801bf7:	eb a0                	jmp    801b99 <_pipeisclosed+0xe>

00801bf9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	57                   	push   %edi
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	83 ec 1c             	sub    $0x1c,%esp
  801c02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c05:	89 34 24             	mov    %esi,(%esp)
  801c08:	e8 a3 f6 ff ff       	call   8012b0 <fd2data>
  801c0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c14:	eb 3c                	jmp    801c52 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c16:	89 da                	mov    %ebx,%edx
  801c18:	89 f0                	mov    %esi,%eax
  801c1a:	e8 6c ff ff ff       	call   801b8b <_pipeisclosed>
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	75 38                	jne    801c5b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c23:	e8 e6 ef ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c28:	8b 43 04             	mov    0x4(%ebx),%eax
  801c2b:	8b 13                	mov    (%ebx),%edx
  801c2d:	83 c2 20             	add    $0x20,%edx
  801c30:	39 d0                	cmp    %edx,%eax
  801c32:	73 e2                	jae    801c16 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c37:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c3a:	89 c2                	mov    %eax,%edx
  801c3c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c42:	79 05                	jns    801c49 <devpipe_write+0x50>
  801c44:	4a                   	dec    %edx
  801c45:	83 ca e0             	or     $0xffffffe0,%edx
  801c48:	42                   	inc    %edx
  801c49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4d:	40                   	inc    %eax
  801c4e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c51:	47                   	inc    %edi
  801c52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c55:	75 d1                	jne    801c28 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c57:	89 f8                	mov    %edi,%eax
  801c59:	eb 05                	jmp    801c60 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 1c             	sub    $0x1c,%esp
  801c71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c74:	89 3c 24             	mov    %edi,(%esp)
  801c77:	e8 34 f6 ff ff       	call   8012b0 <fd2data>
  801c7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7e:	be 00 00 00 00       	mov    $0x0,%esi
  801c83:	eb 3a                	jmp    801cbf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c85:	85 f6                	test   %esi,%esi
  801c87:	74 04                	je     801c8d <devpipe_read+0x25>
				return i;
  801c89:	89 f0                	mov    %esi,%eax
  801c8b:	eb 40                	jmp    801ccd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c8d:	89 da                	mov    %ebx,%edx
  801c8f:	89 f8                	mov    %edi,%eax
  801c91:	e8 f5 fe ff ff       	call   801b8b <_pipeisclosed>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	75 2e                	jne    801cc8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c9a:	e8 6f ef ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c9f:	8b 03                	mov    (%ebx),%eax
  801ca1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ca4:	74 df                	je     801c85 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cab:	79 05                	jns    801cb2 <devpipe_read+0x4a>
  801cad:	48                   	dec    %eax
  801cae:	83 c8 e0             	or     $0xffffffe0,%eax
  801cb1:	40                   	inc    %eax
  801cb2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801cbc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbe:	46                   	inc    %esi
  801cbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cc2:	75 db                	jne    801c9f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc4:	89 f0                	mov    %esi,%eax
  801cc6:	eb 05                	jmp    801ccd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	57                   	push   %edi
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	83 ec 3c             	sub    $0x3c,%esp
  801cde:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ce4:	89 04 24             	mov    %eax,(%esp)
  801ce7:	e8 df f5 ff ff       	call   8012cb <fd_alloc>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	0f 88 45 01 00 00    	js     801e3b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cfd:	00 
  801cfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0c:	e8 1c ef ff ff       	call   800c2d <sys_page_alloc>
  801d11:	89 c3                	mov    %eax,%ebx
  801d13:	85 c0                	test   %eax,%eax
  801d15:	0f 88 20 01 00 00    	js     801e3b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 a5 f5 ff ff       	call   8012cb <fd_alloc>
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	0f 88 f8 00 00 00    	js     801e28 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d30:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d37:	00 
  801d38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d46:	e8 e2 ee ff ff       	call   800c2d <sys_page_alloc>
  801d4b:	89 c3                	mov    %eax,%ebx
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	0f 88 d3 00 00 00    	js     801e28 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d58:	89 04 24             	mov    %eax,(%esp)
  801d5b:	e8 50 f5 ff ff       	call   8012b0 <fd2data>
  801d60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d69:	00 
  801d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d75:	e8 b3 ee ff ff       	call   800c2d <sys_page_alloc>
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	0f 88 91 00 00 00    	js     801e15 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d87:	89 04 24             	mov    %eax,(%esp)
  801d8a:	e8 21 f5 ff ff       	call   8012b0 <fd2data>
  801d8f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d96:	00 
  801d97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801da2:	00 
  801da3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dae:	e8 ce ee ff ff       	call   800c81 <sys_page_map>
  801db3:	89 c3                	mov    %eax,%ebx
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 4c                	js     801e05 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801db9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de6:	89 04 24             	mov    %eax,(%esp)
  801de9:	e8 b2 f4 ff ff       	call   8012a0 <fd2num>
  801dee:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801df0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801df3:	89 04 24             	mov    %eax,(%esp)
  801df6:	e8 a5 f4 ff ff       	call   8012a0 <fd2num>
  801dfb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e03:	eb 36                	jmp    801e3b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e05:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e10:	e8 bf ee ff ff       	call   800cd4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e23:	e8 ac ee ff ff       	call   800cd4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e36:	e8 99 ee ff ff       	call   800cd4 <sys_page_unmap>
    err:
	return r;
}
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	83 c4 3c             	add    $0x3c,%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	89 04 24             	mov    %eax,(%esp)
  801e58:	e8 c1 f4 ff ff       	call   80131e <fd_lookup>
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 15                	js     801e76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e64:	89 04 24             	mov    %eax,(%esp)
  801e67:	e8 44 f4 ff ff       	call   8012b0 <fd2data>
	return _pipeisclosed(fd, p);
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e71:	e8 15 fd ff ff       	call   801b8b <_pipeisclosed>
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    

00801e82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801e88:	c7 44 24 04 48 2a 80 	movl   $0x802a48,0x4(%esp)
  801e8f:	00 
  801e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e93:	89 04 24             	mov    %eax,(%esp)
  801e96:	e8 a0 e9 ff ff       	call   80083b <strcpy>
	return 0;
}
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eae:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb9:	eb 30                	jmp    801eeb <devcons_write+0x49>
		m = n - tot;
  801ebb:	8b 75 10             	mov    0x10(%ebp),%esi
  801ebe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801ec0:	83 fe 7f             	cmp    $0x7f,%esi
  801ec3:	76 05                	jbe    801eca <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801ec5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801eca:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ece:	03 45 0c             	add    0xc(%ebp),%eax
  801ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed5:	89 3c 24             	mov    %edi,(%esp)
  801ed8:	e8 d7 ea ff ff       	call   8009b4 <memmove>
		sys_cputs(buf, m);
  801edd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee1:	89 3c 24             	mov    %edi,(%esp)
  801ee4:	e8 77 ec ff ff       	call   800b60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee9:	01 f3                	add    %esi,%ebx
  801eeb:	89 d8                	mov    %ebx,%eax
  801eed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ef0:	72 c9                	jb     801ebb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ef2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f07:	75 07                	jne    801f10 <devcons_read+0x13>
  801f09:	eb 25                	jmp    801f30 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f0b:	e8 fe ec ff ff       	call   800c0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f10:	e8 69 ec ff ff       	call   800b7e <sys_cgetc>
  801f15:	85 c0                	test   %eax,%eax
  801f17:	74 f2                	je     801f0b <devcons_read+0xe>
  801f19:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 1d                	js     801f3c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f1f:	83 f8 04             	cmp    $0x4,%eax
  801f22:	74 13                	je     801f37 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f27:	88 10                	mov    %dl,(%eax)
	return 1;
  801f29:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2e:	eb 0c                	jmp    801f3c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f30:	b8 00 00 00 00       	mov    $0x0,%eax
  801f35:	eb 05                	jmp    801f3c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f51:	00 
  801f52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 03 ec ff ff       	call   800b60 <sys_cputs>
}
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <getchar>:

int
getchar(void)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f65:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f6c:	00 
  801f6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7b:	e8 3a f6 ff ff       	call   8015ba <read>
	if (r < 0)
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 0f                	js     801f93 <getchar+0x34>
		return r;
	if (r < 1)
  801f84:	85 c0                	test   %eax,%eax
  801f86:	7e 06                	jle    801f8e <getchar+0x2f>
		return -E_EOF;
	return c;
  801f88:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f8c:	eb 05                	jmp    801f93 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f8e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	89 04 24             	mov    %eax,(%esp)
  801fa8:	e8 71 f3 ff ff       	call   80131e <fd_lookup>
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 11                	js     801fc2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fba:	39 10                	cmp    %edx,(%eax)
  801fbc:	0f 94 c0             	sete   %al
  801fbf:	0f b6 c0             	movzbl %al,%eax
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <opencons>:

int
opencons(void)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcd:	89 04 24             	mov    %eax,(%esp)
  801fd0:	e8 f6 f2 ff ff       	call   8012cb <fd_alloc>
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	78 3c                	js     802015 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fe0:	00 
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fef:	e8 39 ec ff ff       	call   800c2d <sys_page_alloc>
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 1d                	js     802015 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802001:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802003:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802006:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80200d:	89 04 24             	mov    %eax,(%esp)
  802010:	e8 8b f2 ff ff       	call   8012a0 <fd2num>
}
  802015:	c9                   	leave  
  802016:	c3                   	ret    
	...

00802018 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80201e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802025:	0f 85 80 00 00 00    	jne    8020ab <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  80202b:	a1 08 40 80 00       	mov    0x804008,%eax
  802030:	8b 40 48             	mov    0x48(%eax),%eax
  802033:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80203a:	00 
  80203b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802042:	ee 
  802043:	89 04 24             	mov    %eax,(%esp)
  802046:	e8 e2 eb ff ff       	call   800c2d <sys_page_alloc>
  80204b:	85 c0                	test   %eax,%eax
  80204d:	79 20                	jns    80206f <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80204f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802053:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  80205a:	00 
  80205b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802062:	00 
  802063:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  80206a:	e8 09 e1 ff ff       	call   800178 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80206f:	a1 08 40 80 00       	mov    0x804008,%eax
  802074:	8b 40 48             	mov    0x48(%eax),%eax
  802077:	c7 44 24 04 b8 20 80 	movl   $0x8020b8,0x4(%esp)
  80207e:	00 
  80207f:	89 04 24             	mov    %eax,(%esp)
  802082:	e8 46 ed ff ff       	call   800dcd <sys_env_set_pgfault_upcall>
  802087:	85 c0                	test   %eax,%eax
  802089:	79 20                	jns    8020ab <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80208b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80208f:	c7 44 24 08 80 2a 80 	movl   $0x802a80,0x8(%esp)
  802096:	00 
  802097:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80209e:	00 
  80209f:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  8020a6:	e8 cd e0 ff ff       	call   800178 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ae:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    
  8020b5:	00 00                	add    %al,(%eax)
	...

008020b8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020b8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020b9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020be:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020c0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8020c3:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8020c7:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8020c9:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8020cc:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8020cd:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8020d0:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8020d2:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8020d5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8020d6:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8020d9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020da:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8020db:	c3                   	ret    

008020dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	56                   	push   %esi
  8020e0:	53                   	push   %ebx
  8020e1:	83 ec 10             	sub    $0x10,%esp
  8020e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8020e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	75 05                	jne    8020f6 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8020f1:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8020f6:	89 04 24             	mov    %eax,(%esp)
  8020f9:	e8 45 ed ff ff       	call   800e43 <sys_ipc_recv>
	if (!err) {
  8020fe:	85 c0                	test   %eax,%eax
  802100:	75 26                	jne    802128 <ipc_recv+0x4c>
		if (from_env_store) {
  802102:	85 f6                	test   %esi,%esi
  802104:	74 0a                	je     802110 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  802106:	a1 08 40 80 00       	mov    0x804008,%eax
  80210b:	8b 40 74             	mov    0x74(%eax),%eax
  80210e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802110:	85 db                	test   %ebx,%ebx
  802112:	74 0a                	je     80211e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802114:	a1 08 40 80 00       	mov    0x804008,%eax
  802119:	8b 40 78             	mov    0x78(%eax),%eax
  80211c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80211e:	a1 08 40 80 00       	mov    0x804008,%eax
  802123:	8b 40 70             	mov    0x70(%eax),%eax
  802126:	eb 14                	jmp    80213c <ipc_recv+0x60>
	}
	if (from_env_store) {
  802128:	85 f6                	test   %esi,%esi
  80212a:	74 06                	je     802132 <ipc_recv+0x56>
		*from_env_store = 0;
  80212c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  802132:	85 db                	test   %ebx,%ebx
  802134:	74 06                	je     80213c <ipc_recv+0x60>
		*perm_store = 0;
  802136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	57                   	push   %edi
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 1c             	sub    $0x1c,%esp
  80214c:	8b 75 10             	mov    0x10(%ebp),%esi
  80214f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802152:	85 f6                	test   %esi,%esi
  802154:	75 05                	jne    80215b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802156:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80215b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80215f:	89 74 24 08          	mov    %esi,0x8(%esp)
  802163:	8b 45 0c             	mov    0xc(%ebp),%eax
  802166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216a:	8b 45 08             	mov    0x8(%ebp),%eax
  80216d:	89 04 24             	mov    %eax,(%esp)
  802170:	e8 ab ec ff ff       	call   800e20 <sys_ipc_try_send>
  802175:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802177:	e8 92 ea ff ff       	call   800c0e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  80217c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80217f:	74 da                	je     80215b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802181:	85 db                	test   %ebx,%ebx
  802183:	74 20                	je     8021a5 <ipc_send+0x62>
		panic("send fail: %e", err);
  802185:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802189:	c7 44 24 08 be 2a 80 	movl   $0x802abe,0x8(%esp)
  802190:	00 
  802191:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802198:	00 
  802199:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  8021a0:	e8 d3 df ff ff       	call   800178 <_panic>
	}
	return;
}
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    

008021ad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	53                   	push   %ebx
  8021b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021c0:	89 c2                	mov    %eax,%edx
  8021c2:	c1 e2 07             	shl    $0x7,%edx
  8021c5:	29 ca                	sub    %ecx,%edx
  8021c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021cd:	8b 52 50             	mov    0x50(%edx),%edx
  8021d0:	39 da                	cmp    %ebx,%edx
  8021d2:	75 0f                	jne    8021e3 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021d4:	c1 e0 07             	shl    $0x7,%eax
  8021d7:	29 c8                	sub    %ecx,%eax
  8021d9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021de:	8b 40 40             	mov    0x40(%eax),%eax
  8021e1:	eb 0c                	jmp    8021ef <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021e3:	40                   	inc    %eax
  8021e4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021e9:	75 ce                	jne    8021b9 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021eb:	66 b8 00 00          	mov    $0x0,%ax
}
  8021ef:	5b                   	pop    %ebx
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
	...

008021f4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021fa:	89 c2                	mov    %eax,%edx
  8021fc:	c1 ea 16             	shr    $0x16,%edx
  8021ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802206:	f6 c2 01             	test   $0x1,%dl
  802209:	74 1e                	je     802229 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80220b:	c1 e8 0c             	shr    $0xc,%eax
  80220e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802215:	a8 01                	test   $0x1,%al
  802217:	74 17                	je     802230 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802219:	c1 e8 0c             	shr    $0xc,%eax
  80221c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802223:	ef 
  802224:	0f b7 c0             	movzwl %ax,%eax
  802227:	eb 0c                	jmp    802235 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802229:	b8 00 00 00 00       	mov    $0x0,%eax
  80222e:	eb 05                	jmp    802235 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802230:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    
	...

00802238 <__udivdi3>:
  802238:	55                   	push   %ebp
  802239:	57                   	push   %edi
  80223a:	56                   	push   %esi
  80223b:	83 ec 10             	sub    $0x10,%esp
  80223e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802242:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80224e:	89 cd                	mov    %ecx,%ebp
  802250:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802254:	85 c0                	test   %eax,%eax
  802256:	75 2c                	jne    802284 <__udivdi3+0x4c>
  802258:	39 f9                	cmp    %edi,%ecx
  80225a:	77 68                	ja     8022c4 <__udivdi3+0x8c>
  80225c:	85 c9                	test   %ecx,%ecx
  80225e:	75 0b                	jne    80226b <__udivdi3+0x33>
  802260:	b8 01 00 00 00       	mov    $0x1,%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	f7 f1                	div    %ecx
  802269:	89 c1                	mov    %eax,%ecx
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	89 f8                	mov    %edi,%eax
  80226f:	f7 f1                	div    %ecx
  802271:	89 c7                	mov    %eax,%edi
  802273:	89 f0                	mov    %esi,%eax
  802275:	f7 f1                	div    %ecx
  802277:	89 c6                	mov    %eax,%esi
  802279:	89 f0                	mov    %esi,%eax
  80227b:	89 fa                	mov    %edi,%edx
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	39 f8                	cmp    %edi,%eax
  802286:	77 2c                	ja     8022b4 <__udivdi3+0x7c>
  802288:	0f bd f0             	bsr    %eax,%esi
  80228b:	83 f6 1f             	xor    $0x1f,%esi
  80228e:	75 4c                	jne    8022dc <__udivdi3+0xa4>
  802290:	39 f8                	cmp    %edi,%eax
  802292:	bf 00 00 00 00       	mov    $0x0,%edi
  802297:	72 0a                	jb     8022a3 <__udivdi3+0x6b>
  802299:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80229d:	0f 87 ad 00 00 00    	ja     802350 <__udivdi3+0x118>
  8022a3:	be 01 00 00 00       	mov    $0x1,%esi
  8022a8:	89 f0                	mov    %esi,%eax
  8022aa:	89 fa                	mov    %edi,%edx
  8022ac:	83 c4 10             	add    $0x10,%esp
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
  8022b3:	90                   	nop
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	31 f6                	xor    %esi,%esi
  8022b8:	89 f0                	mov    %esi,%eax
  8022ba:	89 fa                	mov    %edi,%edx
  8022bc:	83 c4 10             	add    $0x10,%esp
  8022bf:	5e                   	pop    %esi
  8022c0:	5f                   	pop    %edi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
  8022c3:	90                   	nop
  8022c4:	89 fa                	mov    %edi,%edx
  8022c6:	89 f0                	mov    %esi,%eax
  8022c8:	f7 f1                	div    %ecx
  8022ca:	89 c6                	mov    %eax,%esi
  8022cc:	31 ff                	xor    %edi,%edi
  8022ce:	89 f0                	mov    %esi,%eax
  8022d0:	89 fa                	mov    %edi,%edx
  8022d2:	83 c4 10             	add    $0x10,%esp
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d 76 00             	lea    0x0(%esi),%esi
  8022dc:	89 f1                	mov    %esi,%ecx
  8022de:	d3 e0                	shl    %cl,%eax
  8022e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022e4:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e9:	29 f0                	sub    %esi,%eax
  8022eb:	89 ea                	mov    %ebp,%edx
  8022ed:	88 c1                	mov    %al,%cl
  8022ef:	d3 ea                	shr    %cl,%edx
  8022f1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022f5:	09 ca                	or     %ecx,%edx
  8022f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022fb:	89 f1                	mov    %esi,%ecx
  8022fd:	d3 e5                	shl    %cl,%ebp
  8022ff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802303:	89 fd                	mov    %edi,%ebp
  802305:	88 c1                	mov    %al,%cl
  802307:	d3 ed                	shr    %cl,%ebp
  802309:	89 fa                	mov    %edi,%edx
  80230b:	89 f1                	mov    %esi,%ecx
  80230d:	d3 e2                	shl    %cl,%edx
  80230f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802313:	88 c1                	mov    %al,%cl
  802315:	d3 ef                	shr    %cl,%edi
  802317:	09 d7                	or     %edx,%edi
  802319:	89 f8                	mov    %edi,%eax
  80231b:	89 ea                	mov    %ebp,%edx
  80231d:	f7 74 24 08          	divl   0x8(%esp)
  802321:	89 d1                	mov    %edx,%ecx
  802323:	89 c7                	mov    %eax,%edi
  802325:	f7 64 24 0c          	mull   0xc(%esp)
  802329:	39 d1                	cmp    %edx,%ecx
  80232b:	72 17                	jb     802344 <__udivdi3+0x10c>
  80232d:	74 09                	je     802338 <__udivdi3+0x100>
  80232f:	89 fe                	mov    %edi,%esi
  802331:	31 ff                	xor    %edi,%edi
  802333:	e9 41 ff ff ff       	jmp    802279 <__udivdi3+0x41>
  802338:	8b 54 24 04          	mov    0x4(%esp),%edx
  80233c:	89 f1                	mov    %esi,%ecx
  80233e:	d3 e2                	shl    %cl,%edx
  802340:	39 c2                	cmp    %eax,%edx
  802342:	73 eb                	jae    80232f <__udivdi3+0xf7>
  802344:	8d 77 ff             	lea    -0x1(%edi),%esi
  802347:	31 ff                	xor    %edi,%edi
  802349:	e9 2b ff ff ff       	jmp    802279 <__udivdi3+0x41>
  80234e:	66 90                	xchg   %ax,%ax
  802350:	31 f6                	xor    %esi,%esi
  802352:	e9 22 ff ff ff       	jmp    802279 <__udivdi3+0x41>
	...

00802358 <__umoddi3>:
  802358:	55                   	push   %ebp
  802359:	57                   	push   %edi
  80235a:	56                   	push   %esi
  80235b:	83 ec 20             	sub    $0x20,%esp
  80235e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802362:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802366:	89 44 24 14          	mov    %eax,0x14(%esp)
  80236a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80236e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802372:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802376:	89 c7                	mov    %eax,%edi
  802378:	89 f2                	mov    %esi,%edx
  80237a:	85 ed                	test   %ebp,%ebp
  80237c:	75 16                	jne    802394 <__umoddi3+0x3c>
  80237e:	39 f1                	cmp    %esi,%ecx
  802380:	0f 86 a6 00 00 00    	jbe    80242c <__umoddi3+0xd4>
  802386:	f7 f1                	div    %ecx
  802388:	89 d0                	mov    %edx,%eax
  80238a:	31 d2                	xor    %edx,%edx
  80238c:	83 c4 20             	add    $0x20,%esp
  80238f:	5e                   	pop    %esi
  802390:	5f                   	pop    %edi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    
  802393:	90                   	nop
  802394:	39 f5                	cmp    %esi,%ebp
  802396:	0f 87 ac 00 00 00    	ja     802448 <__umoddi3+0xf0>
  80239c:	0f bd c5             	bsr    %ebp,%eax
  80239f:	83 f0 1f             	xor    $0x1f,%eax
  8023a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023a6:	0f 84 a8 00 00 00    	je     802454 <__umoddi3+0xfc>
  8023ac:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b0:	d3 e5                	shl    %cl,%ebp
  8023b2:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023bf:	89 f9                	mov    %edi,%ecx
  8023c1:	d3 e8                	shr    %cl,%eax
  8023c3:	09 e8                	or     %ebp,%eax
  8023c5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023c9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023cd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023d1:	d3 e0                	shl    %cl,%eax
  8023d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d7:	89 f2                	mov    %esi,%edx
  8023d9:	d3 e2                	shl    %cl,%edx
  8023db:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023df:	d3 e0                	shl    %cl,%eax
  8023e1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023e5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e9:	89 f9                	mov    %edi,%ecx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	09 d0                	or     %edx,%eax
  8023ef:	d3 ee                	shr    %cl,%esi
  8023f1:	89 f2                	mov    %esi,%edx
  8023f3:	f7 74 24 18          	divl   0x18(%esp)
  8023f7:	89 d6                	mov    %edx,%esi
  8023f9:	f7 64 24 0c          	mull   0xc(%esp)
  8023fd:	89 c5                	mov    %eax,%ebp
  8023ff:	89 d1                	mov    %edx,%ecx
  802401:	39 d6                	cmp    %edx,%esi
  802403:	72 67                	jb     80246c <__umoddi3+0x114>
  802405:	74 75                	je     80247c <__umoddi3+0x124>
  802407:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80240b:	29 e8                	sub    %ebp,%eax
  80240d:	19 ce                	sbb    %ecx,%esi
  80240f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802413:	d3 e8                	shr    %cl,%eax
  802415:	89 f2                	mov    %esi,%edx
  802417:	89 f9                	mov    %edi,%ecx
  802419:	d3 e2                	shl    %cl,%edx
  80241b:	09 d0                	or     %edx,%eax
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802423:	d3 ea                	shr    %cl,%edx
  802425:	83 c4 20             	add    $0x20,%esp
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    
  80242c:	85 c9                	test   %ecx,%ecx
  80242e:	75 0b                	jne    80243b <__umoddi3+0xe3>
  802430:	b8 01 00 00 00       	mov    $0x1,%eax
  802435:	31 d2                	xor    %edx,%edx
  802437:	f7 f1                	div    %ecx
  802439:	89 c1                	mov    %eax,%ecx
  80243b:	89 f0                	mov    %esi,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	f7 f1                	div    %ecx
  802441:	89 f8                	mov    %edi,%eax
  802443:	e9 3e ff ff ff       	jmp    802386 <__umoddi3+0x2e>
  802448:	89 f2                	mov    %esi,%edx
  80244a:	83 c4 20             	add    $0x20,%esp
  80244d:	5e                   	pop    %esi
  80244e:	5f                   	pop    %edi
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    
  802451:	8d 76 00             	lea    0x0(%esi),%esi
  802454:	39 f5                	cmp    %esi,%ebp
  802456:	72 04                	jb     80245c <__umoddi3+0x104>
  802458:	39 f9                	cmp    %edi,%ecx
  80245a:	77 06                	ja     802462 <__umoddi3+0x10a>
  80245c:	89 f2                	mov    %esi,%edx
  80245e:	29 cf                	sub    %ecx,%edi
  802460:	19 ea                	sbb    %ebp,%edx
  802462:	89 f8                	mov    %edi,%eax
  802464:	83 c4 20             	add    $0x20,%esp
  802467:	5e                   	pop    %esi
  802468:	5f                   	pop    %edi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    
  80246b:	90                   	nop
  80246c:	89 d1                	mov    %edx,%ecx
  80246e:	89 c5                	mov    %eax,%ebp
  802470:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802474:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802478:	eb 8d                	jmp    802407 <__umoddi3+0xaf>
  80247a:	66 90                	xchg   %ax,%ax
  80247c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802480:	72 ea                	jb     80246c <__umoddi3+0x114>
  802482:	89 f1                	mov    %esi,%ecx
  802484:	eb 81                	jmp    802407 <__umoddi3+0xaf>
