
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 88 12 00 00       	call   8012e0 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  800071:	e8 3a 02 00 00       	call   8002b0 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 6c 0f 00 00       	call   800fe7 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 01 29 80 	movl   $0x802901,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  80009c:	e8 17 01 00 00       	call   8001b8 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 20 12 00 00       	call   8012e0 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	99                   	cltd   
  8000c3:	f7 fb                	idiv   %ebx
  8000c5:	85 d2                	test   %edx,%edx
  8000c7:	74 df                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d8:	00 
  8000d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 62 12 00 00       	call   801347 <ipc_send>
  8000e5:	eb c1                	jmp    8000a8 <primeproc+0x74>

008000e7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ef:	e8 f3 0e 00 00       	call   800fe7 <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 01 29 80 	movl   $0x802901,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  800115:	e8 9e 00 00 00       	call   8001b8 <_panic>
	if (id == 0)
  80011a:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011f:	85 c0                	test   %eax,%eax
  800121:	75 05                	jne    800128 <umain+0x41>
		primeproc();
  800123:	e8 0c ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800128:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012f:	00 
  800130:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800137:	00 
  800138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013c:	89 34 24             	mov    %esi,(%esp)
  80013f:	e8 03 12 00 00       	call   801347 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800144:	43                   	inc    %ebx
  800145:	eb e1                	jmp    800128 <umain+0x41>
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800156:	e8 d4 0a 00 00       	call   800c2f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 5a ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a2:	e8 38 14 00 00       	call   8015df <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 2a 0a 00 00       	call   800bdd <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001c9:	e8 61 0a 00 00       	call   800c2f <sys_getenvid>
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  8001eb:	e8 c0 00 00 00       	call   8002b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	e8 50 00 00 00       	call   80024f <vcprintf>
	cprintf("\n");
  8001ff:	c7 04 24 59 2a 80 00 	movl   $0x802a59,(%esp)
  800206:	e8 a5 00 00 00       	call   8002b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020b:	cc                   	int3   
  80020c:	eb fd                	jmp    80020b <_panic+0x53>
	...

00800210 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	53                   	push   %ebx
  800214:	83 ec 14             	sub    $0x14,%esp
  800217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021a:	8b 03                	mov    (%ebx),%eax
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800223:	40                   	inc    %eax
  800224:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800226:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022b:	75 19                	jne    800246 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80022d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800234:	00 
  800235:	8d 43 08             	lea    0x8(%ebx),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 60 09 00 00       	call   800ba0 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800246:	ff 43 04             	incl   0x4(%ebx)
}
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800258:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025f:	00 00 00 
	b.cnt = 0;
  800262:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800269:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 10 02 80 00 	movl   $0x800210,(%esp)
  80028b:	e8 82 01 00 00       	call   800412 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800290:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 f8 08 00 00       	call   800ba0 <sys_cputs>

	return b.cnt;
}
  8002a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 87 ff ff ff       	call   80024f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    
	...

008002cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 3c             	sub    $0x3c,%esp
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	75 08                	jne    8002f8 <printnum+0x2c>
  8002f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f6:	77 57                	ja     80034f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002fc:	4b                   	dec    %ebx
  8002fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800301:	8b 45 10             	mov    0x10(%ebp),%eax
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80030c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 4e 1f 00 00       	call   802278 <__udivdi3>
  80032a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 fa                	mov    %edi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 89 ff ff ff       	call   8002cc <printnum>
  800343:	eb 0f                	jmp    800354 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800345:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800349:	89 34 24             	mov    %esi,(%esp)
  80034c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034f:	4b                   	dec    %ebx
  800350:	85 db                	test   %ebx,%ebx
  800352:	7f f1                	jg     800345 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036a:	00 
  80036b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	89 44 24 04          	mov    %eax,0x4(%esp)
  800378:	e8 1b 20 00 00       	call   802398 <__umoddi3>
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	0f be 80 27 25 80 00 	movsbl 0x802527(%eax),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038e:	83 c4 3c             	add    $0x3c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800399:	83 fa 01             	cmp    $0x1,%edx
  80039c:	7e 0e                	jle    8003ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	8b 52 04             	mov    0x4(%edx),%edx
  8003aa:	eb 22                	jmp    8003ce <getuint+0x38>
	else if (lflag)
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 10                	je     8003c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	eb 0e                	jmp    8003ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 08                	jae    8003e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	42                   	inc    %edx
  8003e6:	89 10                	mov    %edx,(%eax)
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 02 00 00 00       	call   800412 <vprintfmt>
	va_end(ap);
}
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	57                   	push   %edi
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	83 ec 4c             	sub    $0x4c,%esp
  80041b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041e:	8b 75 10             	mov    0x10(%ebp),%esi
  800421:	eb 12                	jmp    800435 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800423:	85 c0                	test   %eax,%eax
  800425:	0f 84 8b 03 00 00    	je     8007b6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800435:	0f b6 06             	movzbl (%esi),%eax
  800438:	46                   	inc    %esi
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e5                	jne    800423 <vprintfmt+0x11>
  80043e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800442:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800449:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80044e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800455:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045a:	eb 26                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80045f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800463:	eb 1d                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800468:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80046c:	eb 14                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800478:	eb 08                	jmp    800482 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80047d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	0f b6 06             	movzbl (%esi),%eax
  800485:	8d 56 01             	lea    0x1(%esi),%edx
  800488:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048b:	8a 16                	mov    (%esi),%dl
  80048d:	83 ea 23             	sub    $0x23,%edx
  800490:	80 fa 55             	cmp    $0x55,%dl
  800493:	0f 87 01 03 00 00    	ja     80079a <vprintfmt+0x388>
  800499:	0f b6 d2             	movzbl %dl,%edx
  80049c:	ff 24 95 60 26 80 00 	jmp    *0x802660(,%edx,4)
  8004a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b8:	83 fa 09             	cmp    $0x9,%edx
  8004bb:	77 2a                	ja     8004e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004be:	eb eb                	jmp    8004ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ce:	eb 17                	jmp    8004e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d4:	78 98                	js     80046e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d9:	eb a7                	jmp    800482 <vprintfmt+0x70>
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004e5:	eb 9b                	jmp    800482 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004eb:	79 95                	jns    800482 <vprintfmt+0x70>
  8004ed:	eb 8b                	jmp    80047a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f3:	eb 8d                	jmp    800482 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 50 04             	lea    0x4(%eax),%edx
  8004fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050d:	e9 23 ff ff ff       	jmp    800435 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	79 02                	jns    800523 <vprintfmt+0x111>
  800521:	f7 d8                	neg    %eax
  800523:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800525:	83 f8 0f             	cmp    $0xf,%eax
  800528:	7f 0b                	jg     800535 <vprintfmt+0x123>
  80052a:	8b 04 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	75 23                	jne    800558 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800535:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800539:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 9a fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800553:	e9 dd fe ff ff       	jmp    800435 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055c:	c7 44 24 08 32 2a 80 	movl   $0x802a32,0x8(%esp)
  800563:	00 
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	8b 55 08             	mov    0x8(%ebp),%edx
  80056b:	89 14 24             	mov    %edx,(%esp)
  80056e:	e8 77 fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800576:	e9 ba fe ff ff       	jmp    800435 <vprintfmt+0x23>
  80057b:	89 f9                	mov    %edi,%ecx
  80057d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800580:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 30                	mov    (%eax),%esi
  80058e:	85 f6                	test   %esi,%esi
  800590:	75 05                	jne    800597 <vprintfmt+0x185>
				p = "(null)";
  800592:	be 38 25 80 00       	mov    $0x802538,%esi
			if (width > 0 && padc != '-')
  800597:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059b:	0f 8e 84 00 00 00    	jle    800625 <vprintfmt+0x213>
  8005a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005a5:	74 7e                	je     800625 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ab:	89 34 24             	mov    %esi,(%esp)
  8005ae:	e8 ab 02 00 00       	call   80085e <strnlen>
  8005b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005b6:	29 c2                	sub    %eax,%edx
  8005b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005c5:	89 de                	mov    %ebx,%esi
  8005c7:	89 d3                	mov    %edx,%ebx
  8005c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	eb 0b                	jmp    8005d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d1:	89 3c 24             	mov    %edi,(%esp)
  8005d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f f1                	jg     8005cd <vprintfmt+0x1bb>
  8005dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005df:	89 f3                	mov    %esi,%ebx
  8005e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 05                	jns    8005f0 <vprintfmt+0x1de>
  8005eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f8:	eb 2b                	jmp    800625 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fe:	74 18                	je     800618 <vprintfmt+0x206>
  800600:	8d 50 e0             	lea    -0x20(%eax),%edx
  800603:	83 fa 5e             	cmp    $0x5e,%edx
  800606:	76 10                	jbe    800618 <vprintfmt+0x206>
					putch('?', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
  800616:	eb 0a                	jmp    800622 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	ff 4d e4             	decl   -0x1c(%ebp)
  800625:	0f be 06             	movsbl (%esi),%eax
  800628:	46                   	inc    %esi
  800629:	85 c0                	test   %eax,%eax
  80062b:	74 21                	je     80064e <vprintfmt+0x23c>
  80062d:	85 ff                	test   %edi,%edi
  80062f:	78 c9                	js     8005fa <vprintfmt+0x1e8>
  800631:	4f                   	dec    %edi
  800632:	79 c6                	jns    8005fa <vprintfmt+0x1e8>
  800634:	8b 7d 08             	mov    0x8(%ebp),%edi
  800637:	89 de                	mov    %ebx,%esi
  800639:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80063c:	eb 18                	jmp    800656 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800649:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	eb 08                	jmp    800656 <vprintfmt+0x244>
  80064e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800651:	89 de                	mov    %ebx,%esi
  800653:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	7f e4                	jg     80063e <vprintfmt+0x22c>
  80065a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80065d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	e9 ce fd ff ff       	jmp    800435 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 10                	jle    80067c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 08             	lea    0x8(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 30                	mov    (%eax),%esi
  800677:	8b 78 04             	mov    0x4(%eax),%edi
  80067a:	eb 26                	jmp    8006a2 <vprintfmt+0x290>
	else if (lflag)
  80067c:	85 c9                	test   %ecx,%ecx
  80067e:	74 12                	je     800692 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	89 f7                	mov    %esi,%edi
  80068d:	c1 ff 1f             	sar    $0x1f,%edi
  800690:	eb 10                	jmp    8006a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	89 f7                	mov    %esi,%edi
  80069f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	78 0a                	js     8006b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 ac 00 00 00       	jmp    80075c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006be:	f7 de                	neg    %esi
  8006c0:	83 d7 00             	adc    $0x0,%edi
  8006c3:	f7 df                	neg    %edi
			}
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	e9 8d 00 00 00       	jmp    80075c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cf:	89 ca                	mov    %ecx,%edx
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 bd fc ff ff       	call   800396 <getuint>
  8006d9:	89 c6                	mov    %eax,%esi
  8006db:	89 d7                	mov    %edx,%edi
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e2:	eb 78                	jmp    80075c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800711:	e9 1f fd ff ff       	jmp    800435 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 04             	lea    0x4(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073b:	8b 30                	mov    (%eax),%esi
  80073d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800742:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800747:	eb 13                	jmp    80075c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800749:	89 ca                	mov    %ecx,%edx
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 43 fc ff ff       	call   800396 <getuint>
  800753:	89 c6                	mov    %eax,%esi
  800755:	89 d7                	mov    %edx,%edi
			base = 16;
  800757:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800760:	89 54 24 10          	mov    %edx,0x10(%esp)
  800764:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800767:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076f:	89 34 24             	mov    %esi,(%esp)
  800772:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800776:	89 da                	mov    %ebx,%edx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	e8 4c fb ff ff       	call   8002cc <printnum>
			break;
  800780:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800783:	e9 ad fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800795:	e9 9b fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a8:	eb 01                	jmp    8007ab <vprintfmt+0x399>
  8007aa:	4e                   	dec    %esi
  8007ab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007af:	75 f9                	jne    8007aa <vprintfmt+0x398>
  8007b1:	e9 7f fc ff ff       	jmp    800435 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007b6:	83 c4 4c             	add    $0x4c,%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5f                   	pop    %edi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 28             	sub    $0x28,%esp
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	74 30                	je     80080f <vsnprintf+0x51>
  8007df:	85 d2                	test   %edx,%edx
  8007e1:	7e 33                	jle    800816 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  8007ff:	e8 0e fc ff ff       	call   800412 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800804:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800807:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080d:	eb 0c                	jmp    80081b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800814:	eb 05                	jmp    80081b <vsnprintf+0x5d>
  800816:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800826:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082a:	8b 45 10             	mov    0x10(%ebp),%eax
  80082d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800831:	8b 45 0c             	mov    0xc(%ebp),%eax
  800834:	89 44 24 04          	mov    %eax,0x4(%esp)
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 7b ff ff ff       	call   8007be <vsnprintf>
	va_end(ap);

	return rc;
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    
  800845:	00 00                	add    %al,(%eax)
	...

00800848 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
  800853:	eb 01                	jmp    800856 <strlen+0xe>
		n++;
  800855:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085a:	75 f9                	jne    800855 <strlen+0xd>
		n++;
	return n;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
  80086c:	eb 01                	jmp    80086f <strnlen+0x11>
		n++;
  80086e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086f:	39 d0                	cmp    %edx,%eax
  800871:	74 06                	je     800879 <strnlen+0x1b>
  800873:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800877:	75 f5                	jne    80086e <strnlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
  80088a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80088d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800890:	42                   	inc    %edx
  800891:	84 c9                	test   %cl,%cl
  800893:	75 f5                	jne    80088a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a2:	89 1c 24             	mov    %ebx,(%esp)
  8008a5:	e8 9e ff ff ff       	call   800848 <strlen>
	strcpy(dst + len, src);
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b1:	01 d8                	add    %ebx,%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 c0 ff ff ff       	call   80087b <strcpy>
	return dst;
}
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	83 c4 08             	add    $0x8,%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d6:	eb 0c                	jmp    8008e4 <strncpy+0x21>
		*dst++ = *src;
  8008d8:	8a 1a                	mov    (%edx),%bl
  8008da:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e3:	41                   	inc    %ecx
  8008e4:	39 f1                	cmp    %esi,%ecx
  8008e6:	75 f0                	jne    8008d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fa:	85 d2                	test   %edx,%edx
  8008fc:	75 0a                	jne    800908 <strlcpy+0x1c>
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	eb 1a                	jmp    80091c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800902:	88 18                	mov    %bl,(%eax)
  800904:	40                   	inc    %eax
  800905:	41                   	inc    %ecx
  800906:	eb 02                	jmp    80090a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800908:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80090a:	4a                   	dec    %edx
  80090b:	74 0a                	je     800917 <strlcpy+0x2b>
  80090d:	8a 19                	mov    (%ecx),%bl
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strlcpy+0x16>
  800913:	89 c2                	mov    %eax,%edx
  800915:	eb 02                	jmp    800919 <strlcpy+0x2d>
  800917:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800919:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80091c:	29 f0                	sub    %esi,%eax
}
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092b:	eb 02                	jmp    80092f <strcmp+0xd>
		p++, q++;
  80092d:	41                   	inc    %ecx
  80092e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092f:	8a 01                	mov    (%ecx),%al
  800931:	84 c0                	test   %al,%al
  800933:	74 04                	je     800939 <strcmp+0x17>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	74 f4                	je     80092d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 c0             	movzbl %al,%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800950:	eb 03                	jmp    800955 <strncmp+0x12>
		n--, p++, q++;
  800952:	4a                   	dec    %edx
  800953:	40                   	inc    %eax
  800954:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800955:	85 d2                	test   %edx,%edx
  800957:	74 14                	je     80096d <strncmp+0x2a>
  800959:	8a 18                	mov    (%eax),%bl
  80095b:	84 db                	test   %bl,%bl
  80095d:	74 04                	je     800963 <strncmp+0x20>
  80095f:	3a 19                	cmp    (%ecx),%bl
  800961:	74 ef                	je     800952 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800963:	0f b6 00             	movzbl (%eax),%eax
  800966:	0f b6 11             	movzbl (%ecx),%edx
  800969:	29 d0                	sub    %edx,%eax
  80096b:	eb 05                	jmp    800972 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800972:	5b                   	pop    %ebx
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097e:	eb 05                	jmp    800985 <strchr+0x10>
		if (*s == c)
  800980:	38 ca                	cmp    %cl,%dl
  800982:	74 0c                	je     800990 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800984:	40                   	inc    %eax
  800985:	8a 10                	mov    (%eax),%dl
  800987:	84 d2                	test   %dl,%dl
  800989:	75 f5                	jne    800980 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099b:	eb 05                	jmp    8009a2 <strfind+0x10>
		if (*s == c)
  80099d:	38 ca                	cmp    %cl,%dl
  80099f:	74 07                	je     8009a8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a1:	40                   	inc    %eax
  8009a2:	8a 10                	mov    (%eax),%dl
  8009a4:	84 d2                	test   %dl,%dl
  8009a6:	75 f5                	jne    80099d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	57                   	push   %edi
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b9:	85 c9                	test   %ecx,%ecx
  8009bb:	74 30                	je     8009ed <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c3:	75 25                	jne    8009ea <memset+0x40>
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 20                	jne    8009ea <memset+0x40>
		c &= 0xFF;
  8009ca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cd:	89 d3                	mov    %edx,%ebx
  8009cf:	c1 e3 08             	shl    $0x8,%ebx
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	c1 e6 18             	shl    $0x18,%esi
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e0 10             	shl    $0x10,%eax
  8009dc:	09 f0                	or     %esi,%eax
  8009de:	09 d0                	or     %edx,%eax
  8009e0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e5:	fc                   	cld    
  8009e6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e8:	eb 03                	jmp    8009ed <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a02:	39 c6                	cmp    %eax,%esi
  800a04:	73 34                	jae    800a3a <memmove+0x46>
  800a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a09:	39 d0                	cmp    %edx,%eax
  800a0b:	73 2d                	jae    800a3a <memmove+0x46>
		s += n;
		d += n;
  800a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	f6 c2 03             	test   $0x3,%dl
  800a13:	75 1b                	jne    800a30 <memmove+0x3c>
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 13                	jne    800a30 <memmove+0x3c>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 0e                	jne    800a30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a22:	83 ef 04             	sub    $0x4,%edi
  800a25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2b:	fd                   	std    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 07                	jmp    800a37 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a30:	4f                   	dec    %edi
  800a31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a34:	fd                   	std    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a37:	fc                   	cld    
  800a38:	eb 20                	jmp    800a5a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a40:	75 13                	jne    800a55 <memmove+0x61>
  800a42:	a8 03                	test   $0x3,%al
  800a44:	75 0f                	jne    800a55 <memmove+0x61>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 0a                	jne    800a55 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4e:	89 c7                	mov    %eax,%edi
  800a50:	fc                   	cld    
  800a51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a53:	eb 05                	jmp    800a5a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
  800a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 77 ff ff ff       	call   8009f4 <memmove>
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a93:	eb 16                	jmp    800aab <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a98:	42                   	inc    %edx
  800a99:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a9d:	38 c8                	cmp    %cl,%al
  800a9f:	74 0a                	je     800aab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800aa1:	0f b6 c0             	movzbl %al,%eax
  800aa4:	0f b6 c9             	movzbl %cl,%ecx
  800aa7:	29 c8                	sub    %ecx,%eax
  800aa9:	eb 09                	jmp    800ab4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aab:	39 da                	cmp    %ebx,%edx
  800aad:	75 e6                	jne    800a95 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac2:	89 c2                	mov    %eax,%edx
  800ac4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac7:	eb 05                	jmp    800ace <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac9:	38 08                	cmp    %cl,(%eax)
  800acb:	74 05                	je     800ad2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acd:	40                   	inc    %eax
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	72 f7                	jb     800ac9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae0:	eb 01                	jmp    800ae3 <strtol+0xf>
		s++;
  800ae2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae3:	8a 02                	mov    (%edx),%al
  800ae5:	3c 20                	cmp    $0x20,%al
  800ae7:	74 f9                	je     800ae2 <strtol+0xe>
  800ae9:	3c 09                	cmp    $0x9,%al
  800aeb:	74 f5                	je     800ae2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aed:	3c 2b                	cmp    $0x2b,%al
  800aef:	75 08                	jne    800af9 <strtol+0x25>
		s++;
  800af1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb 13                	jmp    800b0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af9:	3c 2d                	cmp    $0x2d,%al
  800afb:	75 0a                	jne    800b07 <strtol+0x33>
		s++, neg = 1;
  800afd:	8d 52 01             	lea    0x1(%edx),%edx
  800b00:	bf 01 00 00 00       	mov    $0x1,%edi
  800b05:	eb 05                	jmp    800b0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0c:	85 db                	test   %ebx,%ebx
  800b0e:	74 05                	je     800b15 <strtol+0x41>
  800b10:	83 fb 10             	cmp    $0x10,%ebx
  800b13:	75 28                	jne    800b3d <strtol+0x69>
  800b15:	8a 02                	mov    (%edx),%al
  800b17:	3c 30                	cmp    $0x30,%al
  800b19:	75 10                	jne    800b2b <strtol+0x57>
  800b1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b1f:	75 0a                	jne    800b2b <strtol+0x57>
		s += 2, base = 16;
  800b21:	83 c2 02             	add    $0x2,%edx
  800b24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b29:	eb 12                	jmp    800b3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	75 0e                	jne    800b3d <strtol+0x69>
  800b2f:	3c 30                	cmp    $0x30,%al
  800b31:	75 05                	jne    800b38 <strtol+0x64>
		s++, base = 8;
  800b33:	42                   	inc    %edx
  800b34:	b3 08                	mov    $0x8,%bl
  800b36:	eb 05                	jmp    800b3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b44:	8a 0a                	mov    (%edx),%cl
  800b46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b49:	80 fb 09             	cmp    $0x9,%bl
  800b4c:	77 08                	ja     800b56 <strtol+0x82>
			dig = *s - '0';
  800b4e:	0f be c9             	movsbl %cl,%ecx
  800b51:	83 e9 30             	sub    $0x30,%ecx
  800b54:	eb 1e                	jmp    800b74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b5e:	0f be c9             	movsbl %cl,%ecx
  800b61:	83 e9 57             	sub    $0x57,%ecx
  800b64:	eb 0e                	jmp    800b74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b69:	80 fb 19             	cmp    $0x19,%bl
  800b6c:	77 12                	ja     800b80 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b6e:	0f be c9             	movsbl %cl,%ecx
  800b71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b74:	39 f1                	cmp    %esi,%ecx
  800b76:	7d 0c                	jge    800b84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b78:	42                   	inc    %edx
  800b79:	0f af c6             	imul   %esi,%eax
  800b7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b7e:	eb c4                	jmp    800b44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b80:	89 c1                	mov    %eax,%ecx
  800b82:	eb 02                	jmp    800b86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8a:	74 05                	je     800b91 <strtol+0xbd>
		*endptr = (char *) s;
  800b8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b91:	85 ff                	test   %edi,%edi
  800b93:	74 04                	je     800b99 <strtol+0xc5>
  800b95:	89 c8                	mov    %ecx,%eax
  800b97:	f7 d8                	neg    %eax
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    
	...

00800ba0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 28                	jle    800c27 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800c22:	e8 91 f5 ff ff       	call   8001b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c27:	83 c4 2c             	add    $0x2c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3f:	89 d1                	mov    %edx,%ecx
  800c41:	89 d3                	mov    %edx,%ebx
  800c43:	89 d7                	mov    %edx,%edi
  800c45:	89 d6                	mov    %edx,%esi
  800c47:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_yield>:

void
sys_yield(void)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	ba 00 00 00 00       	mov    $0x0,%edx
  800c59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5e:	89 d1                	mov    %edx,%ecx
  800c60:	89 d3                	mov    %edx,%ebx
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c76:	be 00 00 00 00       	mov    $0x0,%esi
  800c7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 f7                	mov    %esi,%edi
  800c8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 28                	jle    800cb9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cac:	00 
  800cad:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800cb4:	e8 ff f4 ff ff       	call   8001b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb9:	83 c4 2c             	add    $0x2c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 28                	jle    800d0c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cff:	00 
  800d00:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800d07:	e8 ac f4 ff ff       	call   8001b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0c:	83 c4 2c             	add    $0x2c,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	b8 06 00 00 00       	mov    $0x6,%eax
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800d5a:	e8 59 f4 ff ff       	call   8001b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5f:	83 c4 2c             	add    $0x2c,%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 28                	jle    800db2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d95:	00 
  800d96:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da5:	00 
  800da6:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800dad:	e8 06 f4 ff ff       	call   8001b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db2:	83 c4 2c             	add    $0x2c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e00:	e8 b3 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e53:	e8 60 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e58:	83 c4 2c             	add    $0x2c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	be 00 00 00 00       	mov    $0x0,%esi
  800e6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	89 cb                	mov    %ecx,%ebx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	89 ce                	mov    %ecx,%esi
  800e9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800ec8:	e8 eb f2 ff ff       	call   8001b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ecd:	83 c4 2c             	add    $0x2c,%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
  800ed5:	00 00                	add    %al,(%eax)
	...

00800ed8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 24             	sub    $0x24,%esp
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800ee4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee8:	75 20                	jne    800f0a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800eea:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eee:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800f05:	e8 ae f2 ff ff       	call   8001b8 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f0a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1c:	f6 c4 08             	test   $0x8,%ah
  800f1f:	75 1c                	jne    800f3d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f21:	c7 44 24 08 7c 28 80 	movl   $0x80287c,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800f38:	e8 7b f2 ff ff       	call   8001b8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800f3d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f44:	00 
  800f45:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f4c:	00 
  800f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f54:	e8 14 fd ff ff       	call   800c6d <sys_page_alloc>
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	79 20                	jns    800f7d <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f61:	c7 44 24 08 d6 28 80 	movl   $0x8028d6,0x8(%esp)
  800f68:	00 
  800f69:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f70:	00 
  800f71:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800f78:	e8 3b f2 ff ff       	call   8001b8 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800f7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f84:	00 
  800f85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f89:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f90:	e8 5f fa ff ff       	call   8009f4 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800f95:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f9c:	00 
  800f9d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fa1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb8:	e8 04 fd ff ff       	call   800cc1 <sys_page_map>
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 20                	jns    800fe1 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800fc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc5:	c7 44 24 08 e9 28 80 	movl   $0x8028e9,0x8(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800fd4:	00 
  800fd5:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800fdc:	e8 d7 f1 ff ff       	call   8001b8 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800fe1:	83 c4 24             	add    $0x24,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800ff0:	c7 04 24 d8 0e 80 00 	movl   $0x800ed8,(%esp)
  800ff7:	e8 74 11 00 00       	call   802170 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ffc:	ba 07 00 00 00       	mov    $0x7,%edx
  801001:	89 d0                	mov    %edx,%eax
  801003:	cd 30                	int    $0x30
  801005:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801008:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 20                	jns    80102f <fork+0x48>
		panic("sys_exofork: %e", envid);
  80100f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801013:	c7 44 24 08 fa 28 80 	movl   $0x8028fa,0x8(%esp)
  80101a:	00 
  80101b:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801022:	00 
  801023:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  80102a:	e8 89 f1 ff ff       	call   8001b8 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  80102f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801033:	75 25                	jne    80105a <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801035:	e8 f5 fb ff ff       	call   800c2f <sys_getenvid>
  80103a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80103f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801046:	c1 e0 07             	shl    $0x7,%eax
  801049:	29 d0                	sub    %edx,%eax
  80104b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801050:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801055:	e9 58 02 00 00       	jmp    8012b2 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  80105a:	bf 00 00 00 00       	mov    $0x0,%edi
  80105f:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801064:	89 f0                	mov    %esi,%eax
  801066:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801069:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801070:	a8 01                	test   $0x1,%al
  801072:	0f 84 7a 01 00 00    	je     8011f2 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801078:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80107f:	a8 01                	test   $0x1,%al
  801081:	0f 84 6b 01 00 00    	je     8011f2 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801087:	a1 04 40 80 00       	mov    0x804004,%eax
  80108c:	8b 40 48             	mov    0x48(%eax),%eax
  80108f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801092:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801099:	f6 c4 04             	test   $0x4,%ah
  80109c:	74 52                	je     8010f0 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80109e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ae:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c0:	89 04 24             	mov    %eax,(%esp)
  8010c3:	e8 f9 fb ff ff       	call   800cc1 <sys_page_map>
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	0f 89 22 01 00 00    	jns    8011f2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d4:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  8010db:	00 
  8010dc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8010eb:	e8 c8 f0 ff ff       	call   8001b8 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8010f0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f7:	f6 c4 08             	test   $0x8,%ah
  8010fa:	75 0f                	jne    80110b <fork+0x124>
  8010fc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801103:	a8 02                	test   $0x2,%al
  801105:	0f 84 99 00 00 00    	je     8011a4 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80110b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801112:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801115:	83 f8 01             	cmp    $0x1,%eax
  801118:	19 db                	sbb    %ebx,%ebx
  80111a:	83 e3 fc             	and    $0xfffffffc,%ebx
  80111d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801123:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801127:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80112e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801132:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801139:	89 04 24             	mov    %eax,(%esp)
  80113c:	e8 80 fb ff ff       	call   800cc1 <sys_page_map>
  801141:	85 c0                	test   %eax,%eax
  801143:	79 20                	jns    801165 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801145:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801149:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  801160:	e8 53 f0 ff ff       	call   8001b8 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801165:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801169:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801170:	89 44 24 08          	mov    %eax,0x8(%esp)
  801174:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801178:	89 04 24             	mov    %eax,(%esp)
  80117b:	e8 41 fb ff ff       	call   800cc1 <sys_page_map>
  801180:	85 c0                	test   %eax,%eax
  801182:	79 6e                	jns    8011f2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801188:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  80118f:	00 
  801190:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801197:	00 
  801198:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  80119f:	e8 14 f0 ff ff       	call   8001b8 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011a4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c6:	89 04 24             	mov    %eax,(%esp)
  8011c9:	e8 f3 fa ff ff       	call   800cc1 <sys_page_map>
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	79 20                	jns    8011f2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d6:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  8011dd:	00 
  8011de:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8011e5:	00 
  8011e6:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8011ed:	e8 c6 ef ff ff       	call   8001b8 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8011f2:	46                   	inc    %esi
  8011f3:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011f9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8011ff:	0f 85 5f fe ff ff    	jne    801064 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801205:	c7 44 24 04 10 22 80 	movl   $0x802210,0x4(%esp)
  80120c:	00 
  80120d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	e8 f5 fb ff ff       	call   800e0d <sys_env_set_pgfault_upcall>
  801218:	85 c0                	test   %eax,%eax
  80121a:	79 20                	jns    80123c <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  80121c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801220:	c7 44 24 08 ac 28 80 	movl   $0x8028ac,0x8(%esp)
  801227:	00 
  801228:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80122f:	00 
  801230:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  801237:	e8 7c ef ff ff       	call   8001b8 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  80123c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80124b:	ee 
  80124c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 16 fa ff ff       	call   800c6d <sys_page_alloc>
  801257:	85 c0                	test   %eax,%eax
  801259:	79 20                	jns    80127b <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80125b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125f:	c7 44 24 08 d6 28 80 	movl   $0x8028d6,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  80126e:	00 
  80126f:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  801276:	e8 3d ef ff ff       	call   8001b8 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80127b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801282:	00 
  801283:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801286:	89 04 24             	mov    %eax,(%esp)
  801289:	e8 d9 fa ff ff       	call   800d67 <sys_env_set_status>
  80128e:	85 c0                	test   %eax,%eax
  801290:	79 20                	jns    8012b2 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801292:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801296:	c7 44 24 08 1c 29 80 	movl   $0x80291c,0x8(%esp)
  80129d:	00 
  80129e:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8012a5:	00 
  8012a6:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8012ad:	e8 06 ef ff ff       	call   8001b8 <_panic>
	}
	
	return envid;
}
  8012b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012b5:	83 c4 3c             	add    $0x3c,%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <sfork>:

// Challenge!
int
sfork(void)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012c3:	c7 44 24 08 33 29 80 	movl   $0x802933,0x8(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8012d2:	00 
  8012d3:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  8012da:	e8 d9 ee ff ff       	call   8001b8 <_panic>
	...

008012e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 10             	sub    $0x10,%esp
  8012e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	75 05                	jne    8012fa <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8012f5:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8012fa:	89 04 24             	mov    %eax,(%esp)
  8012fd:	e8 81 fb ff ff       	call   800e83 <sys_ipc_recv>
	if (!err) {
  801302:	85 c0                	test   %eax,%eax
  801304:	75 26                	jne    80132c <ipc_recv+0x4c>
		if (from_env_store) {
  801306:	85 f6                	test   %esi,%esi
  801308:	74 0a                	je     801314 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  80130a:	a1 04 40 80 00       	mov    0x804004,%eax
  80130f:	8b 40 74             	mov    0x74(%eax),%eax
  801312:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801314:	85 db                	test   %ebx,%ebx
  801316:	74 0a                	je     801322 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801318:	a1 04 40 80 00       	mov    0x804004,%eax
  80131d:	8b 40 78             	mov    0x78(%eax),%eax
  801320:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801322:	a1 04 40 80 00       	mov    0x804004,%eax
  801327:	8b 40 70             	mov    0x70(%eax),%eax
  80132a:	eb 14                	jmp    801340 <ipc_recv+0x60>
	}
	if (from_env_store) {
  80132c:	85 f6                	test   %esi,%esi
  80132e:	74 06                	je     801336 <ipc_recv+0x56>
		*from_env_store = 0;
  801330:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801336:	85 db                	test   %ebx,%ebx
  801338:	74 06                	je     801340 <ipc_recv+0x60>
		*perm_store = 0;
  80133a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	57                   	push   %edi
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	83 ec 1c             	sub    $0x1c,%esp
  801350:	8b 75 10             	mov    0x10(%ebp),%esi
  801353:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801356:	85 f6                	test   %esi,%esi
  801358:	75 05                	jne    80135f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  80135a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80135f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801363:	89 74 24 08          	mov    %esi,0x8(%esp)
  801367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	89 04 24             	mov    %eax,(%esp)
  801374:	e8 e7 fa ff ff       	call   800e60 <sys_ipc_try_send>
  801379:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80137b:	e8 ce f8 ff ff       	call   800c4e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801380:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801383:	74 da                	je     80135f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801385:	85 db                	test   %ebx,%ebx
  801387:	74 20                	je     8013a9 <ipc_send+0x62>
		panic("send fail: %e", err);
  801389:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80138d:	c7 44 24 08 49 29 80 	movl   $0x802949,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 57 29 80 00 	movl   $0x802957,(%esp)
  8013a4:	e8 0f ee ff ff       	call   8001b8 <_panic>
	}
	return;
}
  8013a9:	83 c4 1c             	add    $0x1c,%esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5e                   	pop    %esi
  8013ae:	5f                   	pop    %edi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	53                   	push   %ebx
  8013b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8013b8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013bd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	c1 e2 07             	shl    $0x7,%edx
  8013c9:	29 ca                	sub    %ecx,%edx
  8013cb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013d1:	8b 52 50             	mov    0x50(%edx),%edx
  8013d4:	39 da                	cmp    %ebx,%edx
  8013d6:	75 0f                	jne    8013e7 <ipc_find_env+0x36>
			return envs[i].env_id;
  8013d8:	c1 e0 07             	shl    $0x7,%eax
  8013db:	29 c8                	sub    %ecx,%eax
  8013dd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013e2:	8b 40 40             	mov    0x40(%eax),%eax
  8013e5:	eb 0c                	jmp    8013f3 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013e7:	40                   	inc    %eax
  8013e8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013ed:	75 ce                	jne    8013bd <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013ef:	66 b8 00 00          	mov    $0x0,%ax
}
  8013f3:	5b                   	pop    %ebx
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    
	...

008013f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 df ff ff ff       	call   8013f8 <fd2num>
  801419:	05 20 00 0d 00       	add    $0xd0020,%eax
  80141e:	c1 e0 0c             	shl    $0xc,%eax
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80142a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80142f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801431:	89 c2                	mov    %eax,%edx
  801433:	c1 ea 16             	shr    $0x16,%edx
  801436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	74 11                	je     801453 <fd_alloc+0x30>
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 0c             	shr    $0xc,%edx
  801447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	75 09                	jne    80145c <fd_alloc+0x39>
			*fd_store = fd;
  801453:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
  80145a:	eb 17                	jmp    801473 <fd_alloc+0x50>
  80145c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801461:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801466:	75 c7                	jne    80142f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80146e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801473:	5b                   	pop    %ebx
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80147c:	83 f8 1f             	cmp    $0x1f,%eax
  80147f:	77 36                	ja     8014b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801481:	05 00 00 0d 00       	add    $0xd0000,%eax
  801486:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801489:	89 c2                	mov    %eax,%edx
  80148b:	c1 ea 16             	shr    $0x16,%edx
  80148e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801495:	f6 c2 01             	test   $0x1,%dl
  801498:	74 24                	je     8014be <fd_lookup+0x48>
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	c1 ea 0c             	shr    $0xc,%edx
  80149f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a6:	f6 c2 01             	test   $0x1,%dl
  8014a9:	74 1a                	je     8014c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b5:	eb 13                	jmp    8014ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014bc:	eb 0c                	jmp    8014ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c3:	eb 05                	jmp    8014ca <fd_lookup+0x54>
  8014c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 14             	sub    $0x14,%esp
  8014d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	eb 0e                	jmp    8014ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014e0:	39 08                	cmp    %ecx,(%eax)
  8014e2:	75 09                	jne    8014ed <dev_lookup+0x21>
			*dev = devtab[i];
  8014e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	eb 33                	jmp    801520 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	42                   	inc    %edx
  8014ee:	8b 04 95 e0 29 80 00 	mov    0x8029e0(,%edx,4),%eax
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	75 e7                	jne    8014e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014fe:	8b 40 48             	mov    0x48(%eax),%eax
  801501:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801505:	89 44 24 04          	mov    %eax,0x4(%esp)
  801509:	c7 04 24 64 29 80 00 	movl   $0x802964,(%esp)
  801510:	e8 9b ed ff ff       	call   8002b0 <cprintf>
	*dev = 0;
  801515:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80151b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801520:	83 c4 14             	add    $0x14,%esp
  801523:	5b                   	pop    %ebx
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    

00801526 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 30             	sub    $0x30,%esp
  80152e:	8b 75 08             	mov    0x8(%ebp),%esi
  801531:	8a 45 0c             	mov    0xc(%ebp),%al
  801534:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801537:	89 34 24             	mov    %esi,(%esp)
  80153a:	e8 b9 fe ff ff       	call   8013f8 <fd2num>
  80153f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801542:	89 54 24 04          	mov    %edx,0x4(%esp)
  801546:	89 04 24             	mov    %eax,(%esp)
  801549:	e8 28 ff ff ff       	call   801476 <fd_lookup>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	85 c0                	test   %eax,%eax
  801552:	78 05                	js     801559 <fd_close+0x33>
	    || fd != fd2)
  801554:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801557:	74 0d                	je     801566 <fd_close+0x40>
		return (must_exist ? r : 0);
  801559:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80155d:	75 46                	jne    8015a5 <fd_close+0x7f>
  80155f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801564:	eb 3f                	jmp    8015a5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156d:	8b 06                	mov    (%esi),%eax
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	e8 55 ff ff ff       	call   8014cc <dev_lookup>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 18                	js     801595 <fd_close+0x6f>
		if (dev->dev_close)
  80157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801580:	8b 40 10             	mov    0x10(%eax),%eax
  801583:	85 c0                	test   %eax,%eax
  801585:	74 09                	je     801590 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801587:	89 34 24             	mov    %esi,(%esp)
  80158a:	ff d0                	call   *%eax
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	eb 05                	jmp    801595 <fd_close+0x6f>
		else
			r = 0;
  801590:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801595:	89 74 24 04          	mov    %esi,0x4(%esp)
  801599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a0:	e8 6f f7 ff ff       	call   800d14 <sys_page_unmap>
	return r;
}
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	83 c4 30             	add    $0x30,%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	89 04 24             	mov    %eax,(%esp)
  8015c1:	e8 b0 fe ff ff       	call   801476 <fd_lookup>
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 13                	js     8015dd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015d1:	00 
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 49 ff ff ff       	call   801526 <fd_close>
}
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <close_all>:

void
close_all(void)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 bb ff ff ff       	call   8015ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f3:	43                   	inc    %ebx
  8015f4:	83 fb 20             	cmp    $0x20,%ebx
  8015f7:	75 f2                	jne    8015eb <close_all+0xc>
		close(i);
}
  8015f9:	83 c4 14             	add    $0x14,%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 4c             	sub    $0x4c,%esp
  801608:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80160b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 59 fe ff ff       	call   801476 <fd_lookup>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	85 c0                	test   %eax,%eax
  801621:	0f 88 e1 00 00 00    	js     801708 <dup+0x109>
		return r;
	close(newfdnum);
  801627:	89 3c 24             	mov    %edi,(%esp)
  80162a:	e8 7f ff ff ff       	call   8015ae <close>

	newfd = INDEX2FD(newfdnum);
  80162f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801635:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163b:	89 04 24             	mov    %eax,(%esp)
  80163e:	e8 c5 fd ff ff       	call   801408 <fd2data>
  801643:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801645:	89 34 24             	mov    %esi,(%esp)
  801648:	e8 bb fd ff ff       	call   801408 <fd2data>
  80164d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801650:	89 d8                	mov    %ebx,%eax
  801652:	c1 e8 16             	shr    $0x16,%eax
  801655:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80165c:	a8 01                	test   $0x1,%al
  80165e:	74 46                	je     8016a6 <dup+0xa7>
  801660:	89 d8                	mov    %ebx,%eax
  801662:	c1 e8 0c             	shr    $0xc,%eax
  801665:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80166c:	f6 c2 01             	test   $0x1,%dl
  80166f:	74 35                	je     8016a6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801671:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801678:	25 07 0e 00 00       	and    $0xe07,%eax
  80167d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801681:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801684:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801688:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168f:	00 
  801690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801694:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169b:	e8 21 f6 ff ff       	call   800cc1 <sys_page_map>
  8016a0:	89 c3                	mov    %eax,%ebx
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 3b                	js     8016e1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a9:	89 c2                	mov    %eax,%edx
  8016ab:	c1 ea 0c             	shr    $0xc,%edx
  8016ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016b5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ca:	00 
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d6:	e8 e6 f5 ff ff       	call   800cc1 <sys_page_map>
  8016db:	89 c3                	mov    %eax,%ebx
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	79 25                	jns    801706 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ec:	e8 23 f6 ff ff       	call   800d14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ff:	e8 10 f6 ff ff       	call   800d14 <sys_page_unmap>
	return r;
  801704:	eb 02                	jmp    801708 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801706:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	83 c4 4c             	add    $0x4c,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	53                   	push   %ebx
  801716:	83 ec 24             	sub    $0x24,%esp
  801719:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 4b fd ff ff       	call   801476 <fd_lookup>
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 6d                	js     80179c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801732:	89 44 24 04          	mov    %eax,0x4(%esp)
  801736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801739:	8b 00                	mov    (%eax),%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 89 fd ff ff       	call   8014cc <dev_lookup>
  801743:	85 c0                	test   %eax,%eax
  801745:	78 55                	js     80179c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	8b 50 08             	mov    0x8(%eax),%edx
  80174d:	83 e2 03             	and    $0x3,%edx
  801750:	83 fa 01             	cmp    $0x1,%edx
  801753:	75 23                	jne    801778 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801755:	a1 04 40 80 00       	mov    0x804004,%eax
  80175a:	8b 40 48             	mov    0x48(%eax),%eax
  80175d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	c7 04 24 a5 29 80 00 	movl   $0x8029a5,(%esp)
  80176c:	e8 3f eb ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  801771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801776:	eb 24                	jmp    80179c <read+0x8a>
	}
	if (!dev->dev_read)
  801778:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177b:	8b 52 08             	mov    0x8(%edx),%edx
  80177e:	85 d2                	test   %edx,%edx
  801780:	74 15                	je     801797 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801782:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801785:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801790:	89 04 24             	mov    %eax,(%esp)
  801793:	ff d2                	call   *%edx
  801795:	eb 05                	jmp    80179c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801797:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80179c:	83 c4 24             	add    $0x24,%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	57                   	push   %edi
  8017a6:	56                   	push   %esi
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 1c             	sub    $0x1c,%esp
  8017ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b6:	eb 23                	jmp    8017db <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b8:	89 f0                	mov    %esi,%eax
  8017ba:	29 d8                	sub    %ebx,%eax
  8017bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c3:	01 d8                	add    %ebx,%eax
  8017c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c9:	89 3c 24             	mov    %edi,(%esp)
  8017cc:	e8 41 ff ff ff       	call   801712 <read>
		if (m < 0)
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 10                	js     8017e5 <readn+0x43>
			return m;
		if (m == 0)
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	74 0a                	je     8017e3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d9:	01 c3                	add    %eax,%ebx
  8017db:	39 f3                	cmp    %esi,%ebx
  8017dd:	72 d9                	jb     8017b8 <readn+0x16>
  8017df:	89 d8                	mov    %ebx,%eax
  8017e1:	eb 02                	jmp    8017e5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017e3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017e5:	83 c4 1c             	add    $0x1c,%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5f                   	pop    %edi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 24             	sub    $0x24,%esp
  8017f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fe:	89 1c 24             	mov    %ebx,(%esp)
  801801:	e8 70 fc ff ff       	call   801476 <fd_lookup>
  801806:	85 c0                	test   %eax,%eax
  801808:	78 68                	js     801872 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	8b 00                	mov    (%eax),%eax
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 ae fc ff ff       	call   8014cc <dev_lookup>
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 50                	js     801872 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801825:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801829:	75 23                	jne    80184e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80182b:	a1 04 40 80 00       	mov    0x804004,%eax
  801830:	8b 40 48             	mov    0x48(%eax),%eax
  801833:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	c7 04 24 c1 29 80 00 	movl   $0x8029c1,(%esp)
  801842:	e8 69 ea ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  801847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184c:	eb 24                	jmp    801872 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80184e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801851:	8b 52 0c             	mov    0xc(%edx),%edx
  801854:	85 d2                	test   %edx,%edx
  801856:	74 15                	je     80186d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801858:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80185b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80185f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801862:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801866:	89 04 24             	mov    %eax,(%esp)
  801869:	ff d2                	call   *%edx
  80186b:	eb 05                	jmp    801872 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80186d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801872:	83 c4 24             	add    $0x24,%esp
  801875:	5b                   	pop    %ebx
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <seek>:

int
seek(int fdnum, off_t offset)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	89 04 24             	mov    %eax,(%esp)
  80188b:	e8 e6 fb ff ff       	call   801476 <fd_lookup>
  801890:	85 c0                	test   %eax,%eax
  801892:	78 0e                	js     8018a2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801894:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 24             	sub    $0x24,%esp
  8018ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b5:	89 1c 24             	mov    %ebx,(%esp)
  8018b8:	e8 b9 fb ff ff       	call   801476 <fd_lookup>
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 61                	js     801922 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cb:	8b 00                	mov    (%eax),%eax
  8018cd:	89 04 24             	mov    %eax,(%esp)
  8018d0:	e8 f7 fb ff ff       	call   8014cc <dev_lookup>
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 49                	js     801922 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e0:	75 23                	jne    801905 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018e2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018e7:	8b 40 48             	mov    0x48(%eax),%eax
  8018ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f2:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  8018f9:	e8 b2 e9 ff ff       	call   8002b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801903:	eb 1d                	jmp    801922 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801905:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801908:	8b 52 18             	mov    0x18(%edx),%edx
  80190b:	85 d2                	test   %edx,%edx
  80190d:	74 0e                	je     80191d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80190f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	ff d2                	call   *%edx
  80191b:	eb 05                	jmp    801922 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80191d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801922:	83 c4 24             	add    $0x24,%esp
  801925:	5b                   	pop    %ebx
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	83 ec 24             	sub    $0x24,%esp
  80192f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801932:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801935:	89 44 24 04          	mov    %eax,0x4(%esp)
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 32 fb ff ff       	call   801476 <fd_lookup>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 52                	js     80199a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801952:	8b 00                	mov    (%eax),%eax
  801954:	89 04 24             	mov    %eax,(%esp)
  801957:	e8 70 fb ff ff       	call   8014cc <dev_lookup>
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 3a                	js     80199a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801967:	74 2c                	je     801995 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801969:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80196c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801973:	00 00 00 
	stat->st_isdir = 0;
  801976:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197d:	00 00 00 
	stat->st_dev = dev;
  801980:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198d:	89 14 24             	mov    %edx,(%esp)
  801990:	ff 50 14             	call   *0x14(%eax)
  801993:	eb 05                	jmp    80199a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801995:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80199a:	83 c4 24             	add    $0x24,%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019af:	00 
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 fe 01 00 00       	call   801bb9 <open>
  8019bb:	89 c3                	mov    %eax,%ebx
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 1b                	js     8019dc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c8:	89 1c 24             	mov    %ebx,(%esp)
  8019cb:	e8 58 ff ff ff       	call   801928 <fstat>
  8019d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d2:	89 1c 24             	mov    %ebx,(%esp)
  8019d5:	e8 d4 fb ff ff       	call   8015ae <close>
	return r;
  8019da:	89 f3                	mov    %esi,%ebx
}
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    
  8019e5:	00 00                	add    %al,(%eax)
	...

008019e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 10             	sub    $0x10,%esp
  8019f0:	89 c3                	mov    %eax,%ebx
  8019f2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019fb:	75 11                	jne    801a0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a04:	e8 a8 f9 ff ff       	call   8013b1 <ipc_find_env>
  801a09:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a15:	00 
  801a16:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a1d:	00 
  801a1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a22:	a1 00 40 80 00       	mov    0x804000,%eax
  801a27:	89 04 24             	mov    %eax,(%esp)
  801a2a:	e8 18 f9 ff ff       	call   801347 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a36:	00 
  801a37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a42:	e8 99 f8 ff ff       	call   8012e0 <ipc_recv>
}
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a71:	e8 72 ff ff ff       	call   8019e8 <fsipc>
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a81:	8b 40 0c             	mov    0xc(%eax),%eax
  801a84:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a89:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a93:	e8 50 ff ff ff       	call   8019e8 <fsipc>
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 14             	sub    $0x14,%esp
  801aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aaa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab4:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab9:	e8 2a ff ff ff       	call   8019e8 <fsipc>
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 2b                	js     801aed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ac9:	00 
  801aca:	89 1c 24             	mov    %ebx,(%esp)
  801acd:	e8 a9 ed ff ff       	call   80087b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad2:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801add:	a1 84 50 80 00       	mov    0x805084,%eax
  801ae2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aed:	83 c4 14             	add    $0x14,%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801af9:	c7 44 24 08 f0 29 80 	movl   $0x8029f0,0x8(%esp)
  801b00:	00 
  801b01:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b08:	00 
  801b09:	c7 04 24 0e 2a 80 00 	movl   $0x802a0e,(%esp)
  801b10:	e8 a3 e6 ff ff       	call   8001b8 <_panic>

00801b15 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	83 ec 10             	sub    $0x10,%esp
  801b1d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
  801b23:	8b 40 0c             	mov    0xc(%eax),%eax
  801b26:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b2b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	b8 03 00 00 00       	mov    $0x3,%eax
  801b3b:	e8 a8 fe ff ff       	call   8019e8 <fsipc>
  801b40:	89 c3                	mov    %eax,%ebx
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 6a                	js     801bb0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b46:	39 c6                	cmp    %eax,%esi
  801b48:	73 24                	jae    801b6e <devfile_read+0x59>
  801b4a:	c7 44 24 0c 19 2a 80 	movl   $0x802a19,0xc(%esp)
  801b51:	00 
  801b52:	c7 44 24 08 20 2a 80 	movl   $0x802a20,0x8(%esp)
  801b59:	00 
  801b5a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b61:	00 
  801b62:	c7 04 24 0e 2a 80 00 	movl   $0x802a0e,(%esp)
  801b69:	e8 4a e6 ff ff       	call   8001b8 <_panic>
	assert(r <= PGSIZE);
  801b6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b73:	7e 24                	jle    801b99 <devfile_read+0x84>
  801b75:	c7 44 24 0c 35 2a 80 	movl   $0x802a35,0xc(%esp)
  801b7c:	00 
  801b7d:	c7 44 24 08 20 2a 80 	movl   $0x802a20,0x8(%esp)
  801b84:	00 
  801b85:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b8c:	00 
  801b8d:	c7 04 24 0e 2a 80 00 	movl   $0x802a0e,(%esp)
  801b94:	e8 1f e6 ff ff       	call   8001b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b99:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ba4:	00 
  801ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba8:	89 04 24             	mov    %eax,(%esp)
  801bab:	e8 44 ee ff ff       	call   8009f4 <memmove>
	return r;
}
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 20             	sub    $0x20,%esp
  801bc1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bc4:	89 34 24             	mov    %esi,(%esp)
  801bc7:	e8 7c ec ff ff       	call   800848 <strlen>
  801bcc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd1:	7f 60                	jg     801c33 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 45 f8 ff ff       	call   801423 <fd_alloc>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 54                	js     801c38 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801be4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801be8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bef:	e8 87 ec ff ff       	call   80087b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bff:	b8 01 00 00 00       	mov    $0x1,%eax
  801c04:	e8 df fd ff ff       	call   8019e8 <fsipc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	79 15                	jns    801c24 <open+0x6b>
		fd_close(fd, 0);
  801c0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c16:	00 
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	89 04 24             	mov    %eax,(%esp)
  801c1d:	e8 04 f9 ff ff       	call   801526 <fd_close>
		return r;
  801c22:	eb 14                	jmp    801c38 <open+0x7f>
	}

	return fd2num(fd);
  801c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c27:	89 04 24             	mov    %eax,(%esp)
  801c2a:	e8 c9 f7 ff ff       	call   8013f8 <fd2num>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	eb 05                	jmp    801c38 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c33:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	83 c4 20             	add    $0x20,%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c47:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c51:	e8 92 fd ff ff       	call   8019e8 <fsipc>
}
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 10             	sub    $0x10,%esp
  801c60:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	89 04 24             	mov    %eax,(%esp)
  801c69:	e8 9a f7 ff ff       	call   801408 <fd2data>
  801c6e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c70:	c7 44 24 04 41 2a 80 	movl   $0x802a41,0x4(%esp)
  801c77:	00 
  801c78:	89 34 24             	mov    %esi,(%esp)
  801c7b:	e8 fb eb ff ff       	call   80087b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c80:	8b 43 04             	mov    0x4(%ebx),%eax
  801c83:	2b 03                	sub    (%ebx),%eax
  801c85:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c8b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c92:	00 00 00 
	stat->st_dev = &devpipe;
  801c95:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c9c:	30 80 00 
	return 0;
}
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	83 ec 14             	sub    $0x14,%esp
  801cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc0:	e8 4f f0 ff ff       	call   800d14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc5:	89 1c 24             	mov    %ebx,(%esp)
  801cc8:	e8 3b f7 ff ff       	call   801408 <fd2data>
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd8:	e8 37 f0 ff ff       	call   800d14 <sys_page_unmap>
}
  801cdd:	83 c4 14             	add    $0x14,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	57                   	push   %edi
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 2c             	sub    $0x2c,%esp
  801cec:	89 c7                	mov    %eax,%edi
  801cee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cf1:	a1 04 40 80 00       	mov    0x804004,%eax
  801cf6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cf9:	89 3c 24             	mov    %edi,(%esp)
  801cfc:	e8 33 05 00 00       	call   802234 <pageref>
  801d01:	89 c6                	mov    %eax,%esi
  801d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d06:	89 04 24             	mov    %eax,(%esp)
  801d09:	e8 26 05 00 00       	call   802234 <pageref>
  801d0e:	39 c6                	cmp    %eax,%esi
  801d10:	0f 94 c0             	sete   %al
  801d13:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d16:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d1f:	39 cb                	cmp    %ecx,%ebx
  801d21:	75 08                	jne    801d2b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d23:	83 c4 2c             	add    $0x2c,%esp
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d2b:	83 f8 01             	cmp    $0x1,%eax
  801d2e:	75 c1                	jne    801cf1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d30:	8b 42 58             	mov    0x58(%edx),%eax
  801d33:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d3a:	00 
  801d3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d43:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  801d4a:	e8 61 e5 ff ff       	call   8002b0 <cprintf>
  801d4f:	eb a0                	jmp    801cf1 <_pipeisclosed+0xe>

00801d51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	57                   	push   %edi
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	83 ec 1c             	sub    $0x1c,%esp
  801d5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d5d:	89 34 24             	mov    %esi,(%esp)
  801d60:	e8 a3 f6 ff ff       	call   801408 <fd2data>
  801d65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d67:	bf 00 00 00 00       	mov    $0x0,%edi
  801d6c:	eb 3c                	jmp    801daa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d6e:	89 da                	mov    %ebx,%edx
  801d70:	89 f0                	mov    %esi,%eax
  801d72:	e8 6c ff ff ff       	call   801ce3 <_pipeisclosed>
  801d77:	85 c0                	test   %eax,%eax
  801d79:	75 38                	jne    801db3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d7b:	e8 ce ee ff ff       	call   800c4e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d80:	8b 43 04             	mov    0x4(%ebx),%eax
  801d83:	8b 13                	mov    (%ebx),%edx
  801d85:	83 c2 20             	add    $0x20,%edx
  801d88:	39 d0                	cmp    %edx,%eax
  801d8a:	73 e2                	jae    801d6e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d92:	89 c2                	mov    %eax,%edx
  801d94:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d9a:	79 05                	jns    801da1 <devpipe_write+0x50>
  801d9c:	4a                   	dec    %edx
  801d9d:	83 ca e0             	or     $0xffffffe0,%edx
  801da0:	42                   	inc    %edx
  801da1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801da5:	40                   	inc    %eax
  801da6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da9:	47                   	inc    %edi
  801daa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dad:	75 d1                	jne    801d80 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	eb 05                	jmp    801db8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801db8:	83 c4 1c             	add    $0x1c,%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	83 ec 1c             	sub    $0x1c,%esp
  801dc9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dcc:	89 3c 24             	mov    %edi,(%esp)
  801dcf:	e8 34 f6 ff ff       	call   801408 <fd2data>
  801dd4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd6:	be 00 00 00 00       	mov    $0x0,%esi
  801ddb:	eb 3a                	jmp    801e17 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ddd:	85 f6                	test   %esi,%esi
  801ddf:	74 04                	je     801de5 <devpipe_read+0x25>
				return i;
  801de1:	89 f0                	mov    %esi,%eax
  801de3:	eb 40                	jmp    801e25 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801de5:	89 da                	mov    %ebx,%edx
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	e8 f5 fe ff ff       	call   801ce3 <_pipeisclosed>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	75 2e                	jne    801e20 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801df2:	e8 57 ee ff ff       	call   800c4e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801df7:	8b 03                	mov    (%ebx),%eax
  801df9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dfc:	74 df                	je     801ddd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dfe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e03:	79 05                	jns    801e0a <devpipe_read+0x4a>
  801e05:	48                   	dec    %eax
  801e06:	83 c8 e0             	or     $0xffffffe0,%eax
  801e09:	40                   	inc    %eax
  801e0a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e11:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e14:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e16:	46                   	inc    %esi
  801e17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1a:	75 db                	jne    801df7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	eb 05                	jmp    801e25 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	57                   	push   %edi
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	83 ec 3c             	sub    $0x3c,%esp
  801e36:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e3c:	89 04 24             	mov    %eax,(%esp)
  801e3f:	e8 df f5 ff ff       	call   801423 <fd_alloc>
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	85 c0                	test   %eax,%eax
  801e48:	0f 88 45 01 00 00    	js     801f93 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e55:	00 
  801e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e64:	e8 04 ee ff ff       	call   800c6d <sys_page_alloc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	0f 88 20 01 00 00    	js     801f93 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e73:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e76:	89 04 24             	mov    %eax,(%esp)
  801e79:	e8 a5 f5 ff ff       	call   801423 <fd_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	85 c0                	test   %eax,%eax
  801e82:	0f 88 f8 00 00 00    	js     801f80 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e88:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e8f:	00 
  801e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9e:	e8 ca ed ff ff       	call   800c6d <sys_page_alloc>
  801ea3:	89 c3                	mov    %eax,%ebx
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	0f 88 d3 00 00 00    	js     801f80 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb0:	89 04 24             	mov    %eax,(%esp)
  801eb3:	e8 50 f5 ff ff       	call   801408 <fd2data>
  801eb8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec1:	00 
  801ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecd:	e8 9b ed ff ff       	call   800c6d <sys_page_alloc>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	0f 88 91 00 00 00    	js     801f6d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801edf:	89 04 24             	mov    %eax,(%esp)
  801ee2:	e8 21 f5 ff ff       	call   801408 <fd2data>
  801ee7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eee:	00 
  801eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801efa:	00 
  801efb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f06:	e8 b6 ed ff ff       	call   800cc1 <sys_page_map>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	78 4c                	js     801f5d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3e:	89 04 24             	mov    %eax,(%esp)
  801f41:	e8 b2 f4 ff ff       	call   8013f8 <fd2num>
  801f46:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f4b:	89 04 24             	mov    %eax,(%esp)
  801f4e:	e8 a5 f4 ff ff       	call   8013f8 <fd2num>
  801f53:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5b:	eb 36                	jmp    801f93 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f68:	e8 a7 ed ff ff       	call   800d14 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7b:	e8 94 ed ff ff       	call   800d14 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8e:	e8 81 ed ff ff       	call   800d14 <sys_page_unmap>
    err:
	return r;
}
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	83 c4 3c             	add    $0x3c,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801faa:	8b 45 08             	mov    0x8(%ebp),%eax
  801fad:	89 04 24             	mov    %eax,(%esp)
  801fb0:	e8 c1 f4 ff ff       	call   801476 <fd_lookup>
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 15                	js     801fce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 44 f4 ff ff       	call   801408 <fd2data>
	return _pipeisclosed(fd, p);
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc9:	e8 15 fd ff ff       	call   801ce3 <_pipeisclosed>
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fe0:	c7 44 24 04 60 2a 80 	movl   $0x802a60,0x4(%esp)
  801fe7:	00 
  801fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801feb:	89 04 24             	mov    %eax,(%esp)
  801fee:	e8 88 e8 ff ff       	call   80087b <strcpy>
	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	57                   	push   %edi
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802006:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802011:	eb 30                	jmp    802043 <devcons_write+0x49>
		m = n - tot;
  802013:	8b 75 10             	mov    0x10(%ebp),%esi
  802016:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802018:	83 fe 7f             	cmp    $0x7f,%esi
  80201b:	76 05                	jbe    802022 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80201d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802022:	89 74 24 08          	mov    %esi,0x8(%esp)
  802026:	03 45 0c             	add    0xc(%ebp),%eax
  802029:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202d:	89 3c 24             	mov    %edi,(%esp)
  802030:	e8 bf e9 ff ff       	call   8009f4 <memmove>
		sys_cputs(buf, m);
  802035:	89 74 24 04          	mov    %esi,0x4(%esp)
  802039:	89 3c 24             	mov    %edi,(%esp)
  80203c:	e8 5f eb ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802041:	01 f3                	add    %esi,%ebx
  802043:	89 d8                	mov    %ebx,%eax
  802045:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802048:	72 c9                	jb     802013 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80204a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    

00802055 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80205b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205f:	75 07                	jne    802068 <devcons_read+0x13>
  802061:	eb 25                	jmp    802088 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802063:	e8 e6 eb ff ff       	call   800c4e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802068:	e8 51 eb ff ff       	call   800bbe <sys_cgetc>
  80206d:	85 c0                	test   %eax,%eax
  80206f:	74 f2                	je     802063 <devcons_read+0xe>
  802071:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802073:	85 c0                	test   %eax,%eax
  802075:	78 1d                	js     802094 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802077:	83 f8 04             	cmp    $0x4,%eax
  80207a:	74 13                	je     80208f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80207c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207f:	88 10                	mov    %dl,(%eax)
	return 1;
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	eb 0c                	jmp    802094 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802088:	b8 00 00 00 00       	mov    $0x0,%eax
  80208d:	eb 05                	jmp    802094 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80208f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020a9:	00 
  8020aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ad:	89 04 24             	mov    %eax,(%esp)
  8020b0:	e8 eb ea ff ff       	call   800ba0 <sys_cputs>
}
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <getchar>:

int
getchar(void)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020c4:	00 
  8020c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d3:	e8 3a f6 ff ff       	call   801712 <read>
	if (r < 0)
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 0f                	js     8020eb <getchar+0x34>
		return r;
	if (r < 1)
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	7e 06                	jle    8020e6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e4:	eb 05                	jmp    8020eb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    

008020ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fd:	89 04 24             	mov    %eax,(%esp)
  802100:	e8 71 f3 ff ff       	call   801476 <fd_lookup>
  802105:	85 c0                	test   %eax,%eax
  802107:	78 11                	js     80211a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802112:	39 10                	cmp    %edx,(%eax)
  802114:	0f 94 c0             	sete   %al
  802117:	0f b6 c0             	movzbl %al,%eax
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <opencons>:

int
opencons(void)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 f6 f2 ff ff       	call   801423 <fd_alloc>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 3c                	js     80216d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802131:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802138:	00 
  802139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802147:	e8 21 eb ff ff       	call   800c6d <sys_page_alloc>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 1d                	js     80216d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802150:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802159:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80215b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 8b f2 ff ff       	call   8013f8 <fd2num>
}
  80216d:	c9                   	leave  
  80216e:	c3                   	ret    
	...

00802170 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802176:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80217d:	0f 85 80 00 00 00    	jne    802203 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  802183:	a1 04 40 80 00       	mov    0x804004,%eax
  802188:	8b 40 48             	mov    0x48(%eax),%eax
  80218b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802192:	00 
  802193:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80219a:	ee 
  80219b:	89 04 24             	mov    %eax,(%esp)
  80219e:	e8 ca ea ff ff       	call   800c6d <sys_page_alloc>
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	79 20                	jns    8021c7 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8021a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ab:	c7 44 24 08 6c 2a 80 	movl   $0x802a6c,0x8(%esp)
  8021b2:	00 
  8021b3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8021ba:	00 
  8021bb:	c7 04 24 c8 2a 80 00 	movl   $0x802ac8,(%esp)
  8021c2:	e8 f1 df ff ff       	call   8001b8 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8021c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8021cc:	8b 40 48             	mov    0x48(%eax),%eax
  8021cf:	c7 44 24 04 10 22 80 	movl   $0x802210,0x4(%esp)
  8021d6:	00 
  8021d7:	89 04 24             	mov    %eax,(%esp)
  8021da:	e8 2e ec ff ff       	call   800e0d <sys_env_set_pgfault_upcall>
  8021df:	85 c0                	test   %eax,%eax
  8021e1:	79 20                	jns    802203 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  8021e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021e7:	c7 44 24 08 98 2a 80 	movl   $0x802a98,0x8(%esp)
  8021ee:	00 
  8021ef:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8021f6:	00 
  8021f7:	c7 04 24 c8 2a 80 00 	movl   $0x802ac8,(%esp)
  8021fe:	e8 b5 df ff ff       	call   8001b8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80220b:	c9                   	leave  
  80220c:	c3                   	ret    
  80220d:	00 00                	add    %al,(%eax)
	...

00802210 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802210:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802211:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802216:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802218:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  80221b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80221f:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802221:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802224:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802225:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802228:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  80222a:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  80222d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80222e:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802231:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802232:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802233:	c3                   	ret    

00802234 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80223a:	89 c2                	mov    %eax,%edx
  80223c:	c1 ea 16             	shr    $0x16,%edx
  80223f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802246:	f6 c2 01             	test   $0x1,%dl
  802249:	74 1e                	je     802269 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80224b:	c1 e8 0c             	shr    $0xc,%eax
  80224e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802255:	a8 01                	test   $0x1,%al
  802257:	74 17                	je     802270 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802259:	c1 e8 0c             	shr    $0xc,%eax
  80225c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802263:	ef 
  802264:	0f b7 c0             	movzwl %ax,%eax
  802267:	eb 0c                	jmp    802275 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	eb 05                	jmp    802275 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802270:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    
	...

00802278 <__udivdi3>:
  802278:	55                   	push   %ebp
  802279:	57                   	push   %edi
  80227a:	56                   	push   %esi
  80227b:	83 ec 10             	sub    $0x10,%esp
  80227e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802282:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80228e:	89 cd                	mov    %ecx,%ebp
  802290:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802294:	85 c0                	test   %eax,%eax
  802296:	75 2c                	jne    8022c4 <__udivdi3+0x4c>
  802298:	39 f9                	cmp    %edi,%ecx
  80229a:	77 68                	ja     802304 <__udivdi3+0x8c>
  80229c:	85 c9                	test   %ecx,%ecx
  80229e:	75 0b                	jne    8022ab <__udivdi3+0x33>
  8022a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a5:	31 d2                	xor    %edx,%edx
  8022a7:	f7 f1                	div    %ecx
  8022a9:	89 c1                	mov    %eax,%ecx
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	89 f8                	mov    %edi,%eax
  8022af:	f7 f1                	div    %ecx
  8022b1:	89 c7                	mov    %eax,%edi
  8022b3:	89 f0                	mov    %esi,%eax
  8022b5:	f7 f1                	div    %ecx
  8022b7:	89 c6                	mov    %eax,%esi
  8022b9:	89 f0                	mov    %esi,%eax
  8022bb:	89 fa                	mov    %edi,%edx
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	39 f8                	cmp    %edi,%eax
  8022c6:	77 2c                	ja     8022f4 <__udivdi3+0x7c>
  8022c8:	0f bd f0             	bsr    %eax,%esi
  8022cb:	83 f6 1f             	xor    $0x1f,%esi
  8022ce:	75 4c                	jne    80231c <__udivdi3+0xa4>
  8022d0:	39 f8                	cmp    %edi,%eax
  8022d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8022d7:	72 0a                	jb     8022e3 <__udivdi3+0x6b>
  8022d9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022dd:	0f 87 ad 00 00 00    	ja     802390 <__udivdi3+0x118>
  8022e3:	be 01 00 00 00       	mov    $0x1,%esi
  8022e8:	89 f0                	mov    %esi,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    
  8022f3:	90                   	nop
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	31 f6                	xor    %esi,%esi
  8022f8:	89 f0                	mov    %esi,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
  802303:	90                   	nop
  802304:	89 fa                	mov    %edi,%edx
  802306:	89 f0                	mov    %esi,%eax
  802308:	f7 f1                	div    %ecx
  80230a:	89 c6                	mov    %eax,%esi
  80230c:	31 ff                	xor    %edi,%edi
  80230e:	89 f0                	mov    %esi,%eax
  802310:	89 fa                	mov    %edi,%edx
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d 76 00             	lea    0x0(%esi),%esi
  80231c:	89 f1                	mov    %esi,%ecx
  80231e:	d3 e0                	shl    %cl,%eax
  802320:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802324:	b8 20 00 00 00       	mov    $0x20,%eax
  802329:	29 f0                	sub    %esi,%eax
  80232b:	89 ea                	mov    %ebp,%edx
  80232d:	88 c1                	mov    %al,%cl
  80232f:	d3 ea                	shr    %cl,%edx
  802331:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802335:	09 ca                	or     %ecx,%edx
  802337:	89 54 24 08          	mov    %edx,0x8(%esp)
  80233b:	89 f1                	mov    %esi,%ecx
  80233d:	d3 e5                	shl    %cl,%ebp
  80233f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802343:	89 fd                	mov    %edi,%ebp
  802345:	88 c1                	mov    %al,%cl
  802347:	d3 ed                	shr    %cl,%ebp
  802349:	89 fa                	mov    %edi,%edx
  80234b:	89 f1                	mov    %esi,%ecx
  80234d:	d3 e2                	shl    %cl,%edx
  80234f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802353:	88 c1                	mov    %al,%cl
  802355:	d3 ef                	shr    %cl,%edi
  802357:	09 d7                	or     %edx,%edi
  802359:	89 f8                	mov    %edi,%eax
  80235b:	89 ea                	mov    %ebp,%edx
  80235d:	f7 74 24 08          	divl   0x8(%esp)
  802361:	89 d1                	mov    %edx,%ecx
  802363:	89 c7                	mov    %eax,%edi
  802365:	f7 64 24 0c          	mull   0xc(%esp)
  802369:	39 d1                	cmp    %edx,%ecx
  80236b:	72 17                	jb     802384 <__udivdi3+0x10c>
  80236d:	74 09                	je     802378 <__udivdi3+0x100>
  80236f:	89 fe                	mov    %edi,%esi
  802371:	31 ff                	xor    %edi,%edi
  802373:	e9 41 ff ff ff       	jmp    8022b9 <__udivdi3+0x41>
  802378:	8b 54 24 04          	mov    0x4(%esp),%edx
  80237c:	89 f1                	mov    %esi,%ecx
  80237e:	d3 e2                	shl    %cl,%edx
  802380:	39 c2                	cmp    %eax,%edx
  802382:	73 eb                	jae    80236f <__udivdi3+0xf7>
  802384:	8d 77 ff             	lea    -0x1(%edi),%esi
  802387:	31 ff                	xor    %edi,%edi
  802389:	e9 2b ff ff ff       	jmp    8022b9 <__udivdi3+0x41>
  80238e:	66 90                	xchg   %ax,%ax
  802390:	31 f6                	xor    %esi,%esi
  802392:	e9 22 ff ff ff       	jmp    8022b9 <__udivdi3+0x41>
	...

00802398 <__umoddi3>:
  802398:	55                   	push   %ebp
  802399:	57                   	push   %edi
  80239a:	56                   	push   %esi
  80239b:	83 ec 20             	sub    $0x20,%esp
  80239e:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023a2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8023a6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023aa:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023b2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8023b6:	89 c7                	mov    %eax,%edi
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	85 ed                	test   %ebp,%ebp
  8023bc:	75 16                	jne    8023d4 <__umoddi3+0x3c>
  8023be:	39 f1                	cmp    %esi,%ecx
  8023c0:	0f 86 a6 00 00 00    	jbe    80246c <__umoddi3+0xd4>
  8023c6:	f7 f1                	div    %ecx
  8023c8:	89 d0                	mov    %edx,%eax
  8023ca:	31 d2                	xor    %edx,%edx
  8023cc:	83 c4 20             	add    $0x20,%esp
  8023cf:	5e                   	pop    %esi
  8023d0:	5f                   	pop    %edi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
  8023d3:	90                   	nop
  8023d4:	39 f5                	cmp    %esi,%ebp
  8023d6:	0f 87 ac 00 00 00    	ja     802488 <__umoddi3+0xf0>
  8023dc:	0f bd c5             	bsr    %ebp,%eax
  8023df:	83 f0 1f             	xor    $0x1f,%eax
  8023e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023e6:	0f 84 a8 00 00 00    	je     802494 <__umoddi3+0xfc>
  8023ec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023f0:	d3 e5                	shl    %cl,%ebp
  8023f2:	bf 20 00 00 00       	mov    $0x20,%edi
  8023f7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ff:	89 f9                	mov    %edi,%ecx
  802401:	d3 e8                	shr    %cl,%eax
  802403:	09 e8                	or     %ebp,%eax
  802405:	89 44 24 18          	mov    %eax,0x18(%esp)
  802409:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80240d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802411:	d3 e0                	shl    %cl,%eax
  802413:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802417:	89 f2                	mov    %esi,%edx
  802419:	d3 e2                	shl    %cl,%edx
  80241b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80241f:	d3 e0                	shl    %cl,%eax
  802421:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802425:	8b 44 24 14          	mov    0x14(%esp),%eax
  802429:	89 f9                	mov    %edi,%ecx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	09 d0                	or     %edx,%eax
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	89 f2                	mov    %esi,%edx
  802433:	f7 74 24 18          	divl   0x18(%esp)
  802437:	89 d6                	mov    %edx,%esi
  802439:	f7 64 24 0c          	mull   0xc(%esp)
  80243d:	89 c5                	mov    %eax,%ebp
  80243f:	89 d1                	mov    %edx,%ecx
  802441:	39 d6                	cmp    %edx,%esi
  802443:	72 67                	jb     8024ac <__umoddi3+0x114>
  802445:	74 75                	je     8024bc <__umoddi3+0x124>
  802447:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80244b:	29 e8                	sub    %ebp,%eax
  80244d:	19 ce                	sbb    %ecx,%esi
  80244f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802453:	d3 e8                	shr    %cl,%eax
  802455:	89 f2                	mov    %esi,%edx
  802457:	89 f9                	mov    %edi,%ecx
  802459:	d3 e2                	shl    %cl,%edx
  80245b:	09 d0                	or     %edx,%eax
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802463:	d3 ea                	shr    %cl,%edx
  802465:	83 c4 20             	add    $0x20,%esp
  802468:	5e                   	pop    %esi
  802469:	5f                   	pop    %edi
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    
  80246c:	85 c9                	test   %ecx,%ecx
  80246e:	75 0b                	jne    80247b <__umoddi3+0xe3>
  802470:	b8 01 00 00 00       	mov    $0x1,%eax
  802475:	31 d2                	xor    %edx,%edx
  802477:	f7 f1                	div    %ecx
  802479:	89 c1                	mov    %eax,%ecx
  80247b:	89 f0                	mov    %esi,%eax
  80247d:	31 d2                	xor    %edx,%edx
  80247f:	f7 f1                	div    %ecx
  802481:	89 f8                	mov    %edi,%eax
  802483:	e9 3e ff ff ff       	jmp    8023c6 <__umoddi3+0x2e>
  802488:	89 f2                	mov    %esi,%edx
  80248a:	83 c4 20             	add    $0x20,%esp
  80248d:	5e                   	pop    %esi
  80248e:	5f                   	pop    %edi
  80248f:	5d                   	pop    %ebp
  802490:	c3                   	ret    
  802491:	8d 76 00             	lea    0x0(%esi),%esi
  802494:	39 f5                	cmp    %esi,%ebp
  802496:	72 04                	jb     80249c <__umoddi3+0x104>
  802498:	39 f9                	cmp    %edi,%ecx
  80249a:	77 06                	ja     8024a2 <__umoddi3+0x10a>
  80249c:	89 f2                	mov    %esi,%edx
  80249e:	29 cf                	sub    %ecx,%edi
  8024a0:	19 ea                	sbb    %ebp,%edx
  8024a2:	89 f8                	mov    %edi,%eax
  8024a4:	83 c4 20             	add    $0x20,%esp
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    
  8024ab:	90                   	nop
  8024ac:	89 d1                	mov    %edx,%ecx
  8024ae:	89 c5                	mov    %eax,%ebp
  8024b0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024b4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024b8:	eb 8d                	jmp    802447 <__umoddi3+0xaf>
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024c0:	72 ea                	jb     8024ac <__umoddi3+0x114>
  8024c2:	89 f1                	mov    %esi,%ecx
  8024c4:	eb 81                	jmp    802447 <__umoddi3+0xaf>
