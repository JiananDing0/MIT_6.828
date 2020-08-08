
obj/user/primes:     file format elf32-i386


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
  800053:	e8 2c 12 00 00       	call   801284 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  800071:	e8 32 02 00 00       	call   8002a8 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 10 0f 00 00       	call   800f8b <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 25 1a 80 	movl   $0x801a25,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 cc 16 80 00 	movl   $0x8016cc,(%esp)
  80009c:	e8 0f 01 00 00       	call   8001b0 <_panic>
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
  8000bb:	e8 c4 11 00 00       	call   801284 <ipc_recv>
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
  8000e0:	e8 06 12 00 00       	call   8012eb <ipc_send>
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
  8000ef:	e8 97 0e 00 00       	call   800f8b <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 25 1a 80 	movl   $0x801a25,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 cc 16 80 00 	movl   $0x8016cc,(%esp)
  800115:	e8 96 00 00 00       	call   8001b0 <_panic>
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
  80013f:	e8 a7 11 00 00       	call   8012eb <ipc_send>
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
  800156:	e8 cc 0a 00 00       	call   800c27 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 27 0a 00 00       	call   800bd5 <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c1:	e8 61 0a 00 00       	call   800c27 <sys_getenvid>
  8001c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	c7 04 24 e4 16 80 00 	movl   $0x8016e4,(%esp)
  8001e3:	e8 c0 00 00 00       	call   8002a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	e8 50 00 00 00       	call   800247 <vcprintf>
	cprintf("\n");
  8001f7:	c7 04 24 3e 1a 80 00 	movl   $0x801a3e,(%esp)
  8001fe:	e8 a5 00 00 00       	call   8002a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800203:	cc                   	int3   
  800204:	eb fd                	jmp    800203 <_panic+0x53>
	...

00800208 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	53                   	push   %ebx
  80020c:	83 ec 14             	sub    $0x14,%esp
  80020f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021b:	40                   	inc    %eax
  80021c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80021e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800223:	75 19                	jne    80023e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800225:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80022c:	00 
  80022d:	8d 43 08             	lea    0x8(%ebx),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 60 09 00 00       	call   800b98 <sys_cputs>
		b->idx = 0;
  800238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80023e:	ff 43 04             	incl   0x4(%ebx)
}
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	5b                   	pop    %ebx
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800250:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800257:	00 00 00 
	b.cnt = 0;
  80025a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800261:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800272:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027c:	c7 04 24 08 02 80 00 	movl   $0x800208,(%esp)
  800283:	e8 82 01 00 00       	call   80040a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800288:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800292:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 f8 08 00 00       	call   800b98 <sys_cputs>

	return b.cnt;
}
  8002a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 87 ff ff ff       	call   800247 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    
	...

008002c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 3c             	sub    $0x3c,%esp
  8002cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d0:	89 d7                	mov    %edx,%edi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002de:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	75 08                	jne    8002f0 <printnum+0x2c>
  8002e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ee:	77 57                	ja     800347 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002f4:	4b                   	dec    %ebx
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800304:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800308:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030f:	00 
  800310:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	e8 3e 11 00 00       	call   801460 <__udivdi3>
  800322:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800326:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800331:	89 fa                	mov    %edi,%edx
  800333:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800336:	e8 89 ff ff ff       	call   8002c4 <printnum>
  80033b:	eb 0f                	jmp    80034c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	89 34 24             	mov    %esi,(%esp)
  800344:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800347:	4b                   	dec    %ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f f1                	jg     80033d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800350:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800354:	8b 45 10             	mov    0x10(%ebp),%eax
  800357:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800362:	00 
  800363:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800366:	89 04 24             	mov    %eax,(%esp)
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800370:	e8 0b 12 00 00       	call   801580 <__umoddi3>
  800375:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800379:	0f be 80 07 17 80 00 	movsbl 0x801707(%eax),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800386:	83 c4 3c             	add    $0x3c,%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800391:	83 fa 01             	cmp    $0x1,%edx
  800394:	7e 0e                	jle    8003a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	8b 52 04             	mov    0x4(%edx),%edx
  8003a2:	eb 22                	jmp    8003c6 <getuint+0x38>
	else if (lflag)
  8003a4:	85 d2                	test   %edx,%edx
  8003a6:	74 10                	je     8003b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a8:	8b 10                	mov    (%eax),%edx
  8003aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 02                	mov    (%edx),%eax
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	eb 0e                	jmp    8003c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ce:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d1:	8b 10                	mov    (%eax),%edx
  8003d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d6:	73 08                	jae    8003e0 <sprintputch+0x18>
		*b->buf++ = ch;
  8003d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003db:	88 0a                	mov    %cl,(%edx)
  8003dd:	42                   	inc    %edx
  8003de:	89 10                	mov    %edx,(%eax)
}
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 02 00 00 00       	call   80040a <vprintfmt>
	va_end(ap);
}
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 4c             	sub    $0x4c,%esp
  800413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800416:	8b 75 10             	mov    0x10(%ebp),%esi
  800419:	eb 12                	jmp    80042d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80041b:	85 c0                	test   %eax,%eax
  80041d:	0f 84 8b 03 00 00    	je     8007ae <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800423:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042d:	0f b6 06             	movzbl (%esi),%eax
  800430:	46                   	inc    %esi
  800431:	83 f8 25             	cmp    $0x25,%eax
  800434:	75 e5                	jne    80041b <vprintfmt+0x11>
  800436:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80043a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800441:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800446:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80044d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800452:	eb 26                	jmp    80047a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800457:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80045b:	eb 1d                	jmp    80047a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800460:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800464:	eb 14                	jmp    80047a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800469:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800470:	eb 08                	jmp    80047a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800472:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800475:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	0f b6 06             	movzbl (%esi),%eax
  80047d:	8d 56 01             	lea    0x1(%esi),%edx
  800480:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800483:	8a 16                	mov    (%esi),%dl
  800485:	83 ea 23             	sub    $0x23,%edx
  800488:	80 fa 55             	cmp    $0x55,%dl
  80048b:	0f 87 01 03 00 00    	ja     800792 <vprintfmt+0x388>
  800491:	0f b6 d2             	movzbl %dl,%edx
  800494:	ff 24 95 c0 17 80 00 	jmp    *0x8017c0(,%edx,4)
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004a6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004aa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ad:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b0:	83 fa 09             	cmp    $0x9,%edx
  8004b3:	77 2a                	ja     8004df <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b6:	eb eb                	jmp    8004a3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c6:	eb 17                	jmp    8004df <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cc:	78 98                	js     800466 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d1:	eb a7                	jmp    80047a <vprintfmt+0x70>
  8004d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004dd:	eb 9b                	jmp    80047a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e3:	79 95                	jns    80047a <vprintfmt+0x70>
  8004e5:	eb 8b                	jmp    800472 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004eb:	eb 8d                	jmp    80047a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 23 ff ff ff       	jmp    80042d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	85 c0                	test   %eax,%eax
  800517:	79 02                	jns    80051b <vprintfmt+0x111>
  800519:	f7 d8                	neg    %eax
  80051b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 08             	cmp    $0x8,%eax
  800520:	7f 0b                	jg     80052d <vprintfmt+0x123>
  800522:	8b 04 85 20 19 80 00 	mov    0x801920(,%eax,4),%eax
  800529:	85 c0                	test   %eax,%eax
  80052b:	75 23                	jne    800550 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80052d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800531:	c7 44 24 08 1f 17 80 	movl   $0x80171f,0x8(%esp)
  800538:	00 
  800539:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053d:	8b 45 08             	mov    0x8(%ebp),%eax
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 9a fe ff ff       	call   8003e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054b:	e9 dd fe ff ff       	jmp    80042d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800550:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800554:	c7 44 24 08 28 17 80 	movl   $0x801728,0x8(%esp)
  80055b:	00 
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	8b 55 08             	mov    0x8(%ebp),%edx
  800563:	89 14 24             	mov    %edx,(%esp)
  800566:	e8 77 fe ff ff       	call   8003e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056e:	e9 ba fe ff ff       	jmp    80042d <vprintfmt+0x23>
  800573:	89 f9                	mov    %edi,%ecx
  800575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800578:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 30                	mov    (%eax),%esi
  800586:	85 f6                	test   %esi,%esi
  800588:	75 05                	jne    80058f <vprintfmt+0x185>
				p = "(null)";
  80058a:	be 18 17 80 00       	mov    $0x801718,%esi
			if (width > 0 && padc != '-')
  80058f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800593:	0f 8e 84 00 00 00    	jle    80061d <vprintfmt+0x213>
  800599:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80059d:	74 7e                	je     80061d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a3:	89 34 24             	mov    %esi,(%esp)
  8005a6:	e8 ab 02 00 00       	call   800856 <strnlen>
  8005ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ae:	29 c2                	sub    %eax,%edx
  8005b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005b3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005b7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005bd:	89 de                	mov    %ebx,%esi
  8005bf:	89 d3                	mov    %edx,%ebx
  8005c1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	eb 0b                	jmp    8005d0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c9:	89 3c 24             	mov    %edi,(%esp)
  8005cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	4b                   	dec    %ebx
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	7f f1                	jg     8005c5 <vprintfmt+0x1bb>
  8005d4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005d7:	89 f3                	mov    %esi,%ebx
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	79 05                	jns    8005e8 <vprintfmt+0x1de>
  8005e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005eb:	29 c2                	sub    %eax,%edx
  8005ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f0:	eb 2b                	jmp    80061d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f6:	74 18                	je     800610 <vprintfmt+0x206>
  8005f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fb:	83 fa 5e             	cmp    $0x5e,%edx
  8005fe:	76 10                	jbe    800610 <vprintfmt+0x206>
					putch('?', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
  80060e:	eb 0a                	jmp    80061a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	ff 4d e4             	decl   -0x1c(%ebp)
  80061d:	0f be 06             	movsbl (%esi),%eax
  800620:	46                   	inc    %esi
  800621:	85 c0                	test   %eax,%eax
  800623:	74 21                	je     800646 <vprintfmt+0x23c>
  800625:	85 ff                	test   %edi,%edi
  800627:	78 c9                	js     8005f2 <vprintfmt+0x1e8>
  800629:	4f                   	dec    %edi
  80062a:	79 c6                	jns    8005f2 <vprintfmt+0x1e8>
  80062c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062f:	89 de                	mov    %ebx,%esi
  800631:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800634:	eb 18                	jmp    80064e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800636:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800641:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800643:	4b                   	dec    %ebx
  800644:	eb 08                	jmp    80064e <vprintfmt+0x244>
  800646:	8b 7d 08             	mov    0x8(%ebp),%edi
  800649:	89 de                	mov    %ebx,%esi
  80064b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80064e:	85 db                	test   %ebx,%ebx
  800650:	7f e4                	jg     800636 <vprintfmt+0x22c>
  800652:	89 7d 08             	mov    %edi,0x8(%ebp)
  800655:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065a:	e9 ce fd ff ff       	jmp    80042d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065f:	83 f9 01             	cmp    $0x1,%ecx
  800662:	7e 10                	jle    800674 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 08             	lea    0x8(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 30                	mov    (%eax),%esi
  80066f:	8b 78 04             	mov    0x4(%eax),%edi
  800672:	eb 26                	jmp    80069a <vprintfmt+0x290>
	else if (lflag)
  800674:	85 c9                	test   %ecx,%ecx
  800676:	74 12                	je     80068a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 30                	mov    (%eax),%esi
  800683:	89 f7                	mov    %esi,%edi
  800685:	c1 ff 1f             	sar    $0x1f,%edi
  800688:	eb 10                	jmp    80069a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 30                	mov    (%eax),%esi
  800695:	89 f7                	mov    %esi,%edi
  800697:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069a:	85 ff                	test   %edi,%edi
  80069c:	78 0a                	js     8006a8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a3:	e9 ac 00 00 00       	jmp    800754 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ac:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b6:	f7 de                	neg    %esi
  8006b8:	83 d7 00             	adc    $0x0,%edi
  8006bb:	f7 df                	neg    %edi
			}
			base = 10;
  8006bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c2:	e9 8d 00 00 00       	jmp    800754 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c7:	89 ca                	mov    %ecx,%edx
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 bd fc ff ff       	call   80038e <getuint>
  8006d1:	89 c6                	mov    %eax,%esi
  8006d3:	89 d7                	mov    %edx,%edi
			base = 10;
  8006d5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006da:	eb 78                	jmp    800754 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006f5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800709:	e9 1f fd ff ff       	jmp    80042d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800733:	8b 30                	mov    (%eax),%esi
  800735:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80073f:	eb 13                	jmp    800754 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800741:	89 ca                	mov    %ecx,%edx
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 43 fc ff ff       	call   80038e <getuint>
  80074b:	89 c6                	mov    %eax,%esi
  80074d:	89 d7                	mov    %edx,%edi
			base = 16;
  80074f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800754:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800758:	89 54 24 10          	mov    %edx,0x10(%esp)
  80075c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800763:	89 44 24 08          	mov    %eax,0x8(%esp)
  800767:	89 34 24             	mov    %esi,(%esp)
  80076a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076e:	89 da                	mov    %ebx,%edx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	e8 4c fb ff ff       	call   8002c4 <printnum>
			break;
  800778:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077b:	e9 ad fc ff ff       	jmp    80042d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078d:	e9 9b fc ff ff       	jmp    80042d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800796:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80079d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a0:	eb 01                	jmp    8007a3 <vprintfmt+0x399>
  8007a2:	4e                   	dec    %esi
  8007a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a7:	75 f9                	jne    8007a2 <vprintfmt+0x398>
  8007a9:	e9 7f fc ff ff       	jmp    80042d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007ae:	83 c4 4c             	add    $0x4c,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	83 ec 28             	sub    $0x28,%esp
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	74 30                	je     800807 <vsnprintf+0x51>
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	7e 33                	jle    80080e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f0:	c7 04 24 c8 03 80 00 	movl   $0x8003c8,(%esp)
  8007f7:	e8 0e fc ff ff       	call   80040a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800805:	eb 0c                	jmp    800813 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080c:	eb 05                	jmp    800813 <vsnprintf+0x5d>
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
  800825:	89 44 24 08          	mov    %eax,0x8(%esp)
  800829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 7b ff ff ff       	call   8007b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    
  80083d:	00 00                	add    %al,(%eax)
	...

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 01                	jmp    80084e <strlen+0xe>
		n++;
  80084d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800852:	75 f9                	jne    80084d <strlen+0xd>
		n++;
	return n;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
  800864:	eb 01                	jmp    800867 <strnlen+0x11>
		n++;
  800866:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800867:	39 d0                	cmp    %edx,%eax
  800869:	74 06                	je     800871 <strnlen+0x1b>
  80086b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086f:	75 f5                	jne    800866 <strnlen+0x10>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
  800882:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800885:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800888:	42                   	inc    %edx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 f5                	jne    800882 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089a:	89 1c 24             	mov    %ebx,(%esp)
  80089d:	e8 9e ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	89 04 24             	mov    %eax,(%esp)
  8008ae:	e8 c0 ff ff ff       	call   800873 <strcpy>
	return dst;
}
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	83 c4 08             	add    $0x8,%esp
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ce:	eb 0c                	jmp    8008dc <strncpy+0x21>
		*dst++ = *src;
  8008d0:	8a 1a                	mov    (%edx),%bl
  8008d2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	41                   	inc    %ecx
  8008dc:	39 f1                	cmp    %esi,%ecx
  8008de:	75 f0                	jne    8008d0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f2:	85 d2                	test   %edx,%edx
  8008f4:	75 0a                	jne    800900 <strlcpy+0x1c>
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	eb 1a                	jmp    800914 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fa:	88 18                	mov    %bl,(%eax)
  8008fc:	40                   	inc    %eax
  8008fd:	41                   	inc    %ecx
  8008fe:	eb 02                	jmp    800902 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800900:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800902:	4a                   	dec    %edx
  800903:	74 0a                	je     80090f <strlcpy+0x2b>
  800905:	8a 19                	mov    (%ecx),%bl
  800907:	84 db                	test   %bl,%bl
  800909:	75 ef                	jne    8008fa <strlcpy+0x16>
  80090b:	89 c2                	mov    %eax,%edx
  80090d:	eb 02                	jmp    800911 <strlcpy+0x2d>
  80090f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800911:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800914:	29 f0                	sub    %esi,%eax
}
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800923:	eb 02                	jmp    800927 <strcmp+0xd>
		p++, q++;
  800925:	41                   	inc    %ecx
  800926:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800927:	8a 01                	mov    (%ecx),%al
  800929:	84 c0                	test   %al,%al
  80092b:	74 04                	je     800931 <strcmp+0x17>
  80092d:	3a 02                	cmp    (%edx),%al
  80092f:	74 f4                	je     800925 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800931:	0f b6 c0             	movzbl %al,%eax
  800934:	0f b6 12             	movzbl (%edx),%edx
  800937:	29 d0                	sub    %edx,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800945:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800948:	eb 03                	jmp    80094d <strncmp+0x12>
		n--, p++, q++;
  80094a:	4a                   	dec    %edx
  80094b:	40                   	inc    %eax
  80094c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094d:	85 d2                	test   %edx,%edx
  80094f:	74 14                	je     800965 <strncmp+0x2a>
  800951:	8a 18                	mov    (%eax),%bl
  800953:	84 db                	test   %bl,%bl
  800955:	74 04                	je     80095b <strncmp+0x20>
  800957:	3a 19                	cmp    (%ecx),%bl
  800959:	74 ef                	je     80094a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095b:	0f b6 00             	movzbl (%eax),%eax
  80095e:	0f b6 11             	movzbl (%ecx),%edx
  800961:	29 d0                	sub    %edx,%eax
  800963:	eb 05                	jmp    80096a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096a:	5b                   	pop    %ebx
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800976:	eb 05                	jmp    80097d <strchr+0x10>
		if (*s == c)
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	74 0c                	je     800988 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097c:	40                   	inc    %eax
  80097d:	8a 10                	mov    (%eax),%dl
  80097f:	84 d2                	test   %dl,%dl
  800981:	75 f5                	jne    800978 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800993:	eb 05                	jmp    80099a <strfind+0x10>
		if (*s == c)
  800995:	38 ca                	cmp    %cl,%dl
  800997:	74 07                	je     8009a0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800999:	40                   	inc    %eax
  80099a:	8a 10                	mov    (%eax),%dl
  80099c:	84 d2                	test   %dl,%dl
  80099e:	75 f5                	jne    800995 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	74 30                	je     8009e5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bb:	75 25                	jne    8009e2 <memset+0x40>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 20                	jne    8009e2 <memset+0x40>
		c &= 0xFF;
  8009c2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c5:	89 d3                	mov    %edx,%ebx
  8009c7:	c1 e3 08             	shl    $0x8,%ebx
  8009ca:	89 d6                	mov    %edx,%esi
  8009cc:	c1 e6 18             	shl    $0x18,%esi
  8009cf:	89 d0                	mov    %edx,%eax
  8009d1:	c1 e0 10             	shl    $0x10,%eax
  8009d4:	09 f0                	or     %esi,%eax
  8009d6:	09 d0                	or     %edx,%eax
  8009d8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009da:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009dd:	fc                   	cld    
  8009de:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e0:	eb 03                	jmp    8009e5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e2:	fc                   	cld    
  8009e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e5:	89 f8                	mov    %edi,%eax
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fa:	39 c6                	cmp    %eax,%esi
  8009fc:	73 34                	jae    800a32 <memmove+0x46>
  8009fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 2d                	jae    800a32 <memmove+0x46>
		s += n;
		d += n;
  800a05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	f6 c2 03             	test   $0x3,%dl
  800a0b:	75 1b                	jne    800a28 <memmove+0x3c>
  800a0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a13:	75 13                	jne    800a28 <memmove+0x3c>
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 0e                	jne    800a28 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1a:	83 ef 04             	sub    $0x4,%edi
  800a1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a20:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a23:	fd                   	std    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb 07                	jmp    800a2f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a28:	4f                   	dec    %edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 20                	jmp    800a52 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a38:	75 13                	jne    800a4d <memmove+0x61>
  800a3a:	a8 03                	test   $0x3,%al
  800a3c:	75 0f                	jne    800a4d <memmove+0x61>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 0a                	jne    800a4d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4b:	eb 05                	jmp    800a52 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	89 04 24             	mov    %eax,(%esp)
  800a70:	e8 77 ff ff ff       	call   8009ec <memmove>
}
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a86:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8b:	eb 16                	jmp    800aa3 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a90:	42                   	inc    %edx
  800a91:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a95:	38 c8                	cmp    %cl,%al
  800a97:	74 0a                	je     800aa3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 c9             	movzbl %cl,%ecx
  800a9f:	29 c8                	sub    %ecx,%eax
  800aa1:	eb 09                	jmp    800aac <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa3:	39 da                	cmp    %ebx,%edx
  800aa5:	75 e6                	jne    800a8d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abf:	eb 05                	jmp    800ac6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac1:	38 08                	cmp    %cl,(%eax)
  800ac3:	74 05                	je     800aca <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac5:	40                   	inc    %eax
  800ac6:	39 d0                	cmp    %edx,%eax
  800ac8:	72 f7                	jb     800ac1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad8:	eb 01                	jmp    800adb <strtol+0xf>
		s++;
  800ada:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	8a 02                	mov    (%edx),%al
  800add:	3c 20                	cmp    $0x20,%al
  800adf:	74 f9                	je     800ada <strtol+0xe>
  800ae1:	3c 09                	cmp    $0x9,%al
  800ae3:	74 f5                	je     800ada <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae5:	3c 2b                	cmp    $0x2b,%al
  800ae7:	75 08                	jne    800af1 <strtol+0x25>
		s++;
  800ae9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aea:	bf 00 00 00 00       	mov    $0x0,%edi
  800aef:	eb 13                	jmp    800b04 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	75 0a                	jne    800aff <strtol+0x33>
		s++, neg = 1;
  800af5:	8d 52 01             	lea    0x1(%edx),%edx
  800af8:	bf 01 00 00 00       	mov    $0x1,%edi
  800afd:	eb 05                	jmp    800b04 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	74 05                	je     800b0d <strtol+0x41>
  800b08:	83 fb 10             	cmp    $0x10,%ebx
  800b0b:	75 28                	jne    800b35 <strtol+0x69>
  800b0d:	8a 02                	mov    (%edx),%al
  800b0f:	3c 30                	cmp    $0x30,%al
  800b11:	75 10                	jne    800b23 <strtol+0x57>
  800b13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b17:	75 0a                	jne    800b23 <strtol+0x57>
		s += 2, base = 16;
  800b19:	83 c2 02             	add    $0x2,%edx
  800b1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b21:	eb 12                	jmp    800b35 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b23:	85 db                	test   %ebx,%ebx
  800b25:	75 0e                	jne    800b35 <strtol+0x69>
  800b27:	3c 30                	cmp    $0x30,%al
  800b29:	75 05                	jne    800b30 <strtol+0x64>
		s++, base = 8;
  800b2b:	42                   	inc    %edx
  800b2c:	b3 08                	mov    $0x8,%bl
  800b2e:	eb 05                	jmp    800b35 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b30:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3c:	8a 0a                	mov    (%edx),%cl
  800b3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x82>
			dig = *s - '0';
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 30             	sub    $0x30,%ecx
  800b4c:	eb 1e                	jmp    800b6c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 08                	ja     800b5e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b56:	0f be c9             	movsbl %cl,%ecx
  800b59:	83 e9 57             	sub    $0x57,%ecx
  800b5c:	eb 0e                	jmp    800b6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b61:	80 fb 19             	cmp    $0x19,%bl
  800b64:	77 12                	ja     800b78 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b66:	0f be c9             	movsbl %cl,%ecx
  800b69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6c:	39 f1                	cmp    %esi,%ecx
  800b6e:	7d 0c                	jge    800b7c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b70:	42                   	inc    %edx
  800b71:	0f af c6             	imul   %esi,%eax
  800b74:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b76:	eb c4                	jmp    800b3c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b78:	89 c1                	mov    %eax,%ecx
  800b7a:	eb 02                	jmp    800b7e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b82:	74 05                	je     800b89 <strtol+0xbd>
		*endptr = (char *) s;
  800b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b87:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b89:	85 ff                	test   %edi,%edi
  800b8b:	74 04                	je     800b91 <strtol+0xc5>
  800b8d:	89 c8                	mov    %ecx,%eax
  800b8f:	f7 d8                	neg    %eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    
	...

00800b98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 c3                	mov    %eax,%ebx
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	89 c6                	mov    %eax,%esi
  800baf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be3:	b8 03 00 00 00       	mov    $0x3,%eax
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 cb                	mov    %ecx,%ebx
  800bed:	89 cf                	mov    %ecx,%edi
  800bef:	89 ce                	mov    %ecx,%esi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800c1a:	e8 91 f5 ff ff       	call   8001b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 02 00 00 00       	mov    $0x2,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_yield>:

void
sys_yield(void)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c56:	89 d1                	mov    %edx,%ecx
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	89 d7                	mov    %edx,%edi
  800c5c:	89 d6                	mov    %edx,%esi
  800c5e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	be 00 00 00 00       	mov    $0x0,%esi
  800c73:	b8 04 00 00 00       	mov    $0x4,%eax
  800c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 f7                	mov    %esi,%edi
  800c83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 28                	jle    800cb1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c94:	00 
  800c95:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca4:	00 
  800ca5:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800cac:	e8 ff f4 ff ff       	call   8001b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb1:	83 c4 2c             	add    $0x2c,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 28                	jle    800d04 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800cef:	00 
  800cf0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf7:	00 
  800cf8:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800cff:	e8 ac f4 ff ff       	call   8001b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d04:	83 c4 2c             	add    $0x2c,%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 28                	jle    800d57 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d33:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800d42:	00 
  800d43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4a:	00 
  800d4b:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800d52:	e8 59 f4 ff ff       	call   8001b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d57:	83 c4 2c             	add    $0x2c,%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 28                	jle    800daa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d86:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800da5:	e8 06 f4 ff ff       	call   8001b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800daa:	83 c4 2c             	add    $0x2c,%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 df                	mov    %ebx,%edi
  800dcd:	89 de                	mov    %ebx,%esi
  800dcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 28                	jle    800dfd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de0:	00 
  800de1:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800de8:	00 
  800de9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df0:	00 
  800df1:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800df8:	e8 b3 f3 ff ff       	call   8001b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfd:	83 c4 2c             	add    $0x2c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	be 00 00 00 00       	mov    $0x0,%esi
  800e10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 cb                	mov    %ecx,%ebx
  800e40:	89 cf                	mov    %ecx,%edi
  800e42:	89 ce                	mov    %ecx,%esi
  800e44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 28                	jle    800e72 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e55:	00 
  800e56:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e65:	00 
  800e66:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800e6d:	e8 3e f3 ff ff       	call   8001b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e72:	83 c4 2c             	add    $0x2c,%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
	...

00800e7c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 24             	sub    $0x24,%esp
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e86:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800e88:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e8c:	75 20                	jne    800eae <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e92:	c7 44 24 08 70 19 80 	movl   $0x801970,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  800ea9:	e8 02 f3 ff ff       	call   8001b0 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800eb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec0:	f6 c4 08             	test   $0x8,%ah
  800ec3:	75 1c                	jne    800ee1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ec5:	c7 44 24 08 a0 19 80 	movl   $0x8019a0,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  800edc:	e8 cf f2 ff ff       	call   8001b0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800ee1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef8:	e8 68 fd ff ff       	call   800c65 <sys_page_alloc>
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 20                	jns    800f21 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800f01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f05:	c7 44 24 08 fa 19 80 	movl   $0x8019fa,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  800f1c:	e8 8f f2 ff ff       	call   8001b0 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800f21:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f28:	00 
  800f29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f2d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f34:	e8 b3 fa ff ff       	call   8009ec <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800f39:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f40:	00 
  800f41:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5c:	e8 58 fd ff ff       	call   800cb9 <sys_page_map>
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 20                	jns    800f85 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f69:	c7 44 24 08 0d 1a 80 	movl   $0x801a0d,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  800f80:	e8 2b f2 ff ff       	call   8001b0 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800f85:	83 c4 24             	add    $0x24,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f94:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  800f9b:	e8 fc 03 00 00       	call   80139c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa0:	ba 07 00 00 00       	mov    $0x7,%edx
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	cd 30                	int    $0x30
  800fa9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fac:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 20                	jns    800fd3 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb7:	c7 44 24 08 1e 1a 80 	movl   $0x801a1e,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  800fce:	e8 dd f1 ff ff       	call   8001b0 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800fd3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fd7:	75 25                	jne    800ffe <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd9:	e8 49 fc ff ff       	call   800c27 <sys_getenvid>
  800fde:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fea:	c1 e0 07             	shl    $0x7,%eax
  800fed:	29 d0                	sub    %edx,%eax
  800fef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ff4:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ff9:	e9 58 02 00 00       	jmp    801256 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800ffe:	bf 00 00 00 00       	mov    $0x0,%edi
  801003:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801008:	89 f0                	mov    %esi,%eax
  80100a:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80100d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801014:	a8 01                	test   $0x1,%al
  801016:	0f 84 7a 01 00 00    	je     801196 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80101c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801023:	a8 01                	test   $0x1,%al
  801025:	0f 84 6b 01 00 00    	je     801196 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80102b:	a1 04 20 80 00       	mov    0x802004,%eax
  801030:	8b 40 48             	mov    0x48(%eax),%eax
  801033:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801036:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103d:	f6 c4 04             	test   $0x4,%ah
  801040:	74 52                	je     801094 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801042:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801049:	25 07 0e 00 00       	and    $0xe07,%eax
  80104e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801052:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801056:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801059:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801064:	89 04 24             	mov    %eax,(%esp)
  801067:	e8 4d fc ff ff       	call   800cb9 <sys_page_map>
  80106c:	85 c0                	test   %eax,%eax
  80106e:	0f 89 22 01 00 00    	jns    801196 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801074:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801078:	c7 44 24 08 2e 1a 80 	movl   $0x801a2e,0x8(%esp)
  80107f:	00 
  801080:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801087:	00 
  801088:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  80108f:	e8 1c f1 ff ff       	call   8001b0 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801094:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109b:	f6 c4 08             	test   $0x8,%ah
  80109e:	75 0f                	jne    8010af <fork+0x124>
  8010a0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a7:	a8 02                	test   $0x2,%al
  8010a9:	0f 84 99 00 00 00    	je     801148 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8010af:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b6:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8010b9:	83 f8 01             	cmp    $0x1,%eax
  8010bc:	19 db                	sbb    %ebx,%ebx
  8010be:	83 e3 fc             	and    $0xfffffffc,%ebx
  8010c1:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010c7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010dd:	89 04 24             	mov    %eax,(%esp)
  8010e0:	e8 d4 fb ff ff       	call   800cb9 <sys_page_map>
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	79 20                	jns    801109 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8010e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ed:	c7 44 24 08 2e 1a 80 	movl   $0x801a2e,0x8(%esp)
  8010f4:	00 
  8010f5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010fc:	00 
  8010fd:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  801104:	e8 a7 f0 ff ff       	call   8001b0 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801109:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80110d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801114:	89 44 24 08          	mov    %eax,0x8(%esp)
  801118:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80111c:	89 04 24             	mov    %eax,(%esp)
  80111f:	e8 95 fb ff ff       	call   800cb9 <sys_page_map>
  801124:	85 c0                	test   %eax,%eax
  801126:	79 6e                	jns    801196 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112c:	c7 44 24 08 2e 1a 80 	movl   $0x801a2e,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80113b:	00 
  80113c:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  801143:	e8 68 f0 ff ff       	call   8001b0 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801148:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80114f:	25 07 0e 00 00       	and    $0xe07,%eax
  801154:	89 44 24 10          	mov    %eax,0x10(%esp)
  801158:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80115f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801163:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116a:	89 04 24             	mov    %eax,(%esp)
  80116d:	e8 47 fb ff ff       	call   800cb9 <sys_page_map>
  801172:	85 c0                	test   %eax,%eax
  801174:	79 20                	jns    801196 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801176:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117a:	c7 44 24 08 2e 1a 80 	movl   $0x801a2e,0x8(%esp)
  801181:	00 
  801182:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801189:	00 
  80118a:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  801191:	e8 1a f0 ff ff       	call   8001b0 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801196:	46                   	inc    %esi
  801197:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80119d:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8011a3:	0f 85 5f fe ff ff    	jne    801008 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8011a9:	c7 44 24 04 3c 14 80 	movl   $0x80143c,0x4(%esp)
  8011b0:	00 
  8011b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b4:	89 04 24             	mov    %eax,(%esp)
  8011b7:	e8 f6 fb ff ff       	call   800db2 <sys_env_set_pgfault_upcall>
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	79 20                	jns    8011e0 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c4:	c7 44 24 08 d0 19 80 	movl   $0x8019d0,0x8(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011d3:	00 
  8011d4:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  8011db:	e8 d0 ef ff ff       	call   8001b0 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8011e0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011ef:	ee 
  8011f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f3:	89 04 24             	mov    %eax,(%esp)
  8011f6:	e8 6a fa ff ff       	call   800c65 <sys_page_alloc>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 20                	jns    80121f <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8011ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801203:	c7 44 24 08 fa 19 80 	movl   $0x8019fa,0x8(%esp)
  80120a:	00 
  80120b:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801212:	00 
  801213:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  80121a:	e8 91 ef ff ff       	call   8001b0 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80121f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801226:	00 
  801227:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80122a:	89 04 24             	mov    %eax,(%esp)
  80122d:	e8 2d fb ff ff       	call   800d5f <sys_env_set_status>
  801232:	85 c0                	test   %eax,%eax
  801234:	79 20                	jns    801256 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801236:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123a:	c7 44 24 08 40 1a 80 	movl   $0x801a40,0x8(%esp)
  801241:	00 
  801242:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801249:	00 
  80124a:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  801251:	e8 5a ef ff ff       	call   8001b0 <_panic>
	}
	
	return envid;
}
  801256:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801259:	83 c4 3c             	add    $0x3c,%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5e                   	pop    %esi
  80125e:	5f                   	pop    %edi
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <sfork>:

// Challenge!
int
sfork(void)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801267:	c7 44 24 08 57 1a 80 	movl   $0x801a57,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  80127e:	e8 2d ef ff ff       	call   8001b0 <_panic>
	...

00801284 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 10             	sub    $0x10,%esp
  80128c:	8b 75 08             	mov    0x8(%ebp),%esi
  80128f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801292:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801295:	85 c0                	test   %eax,%eax
  801297:	75 05                	jne    80129e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801299:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80129e:	89 04 24             	mov    %eax,(%esp)
  8012a1:	e8 82 fb ff ff       	call   800e28 <sys_ipc_recv>
	if (!err) {
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	75 26                	jne    8012d0 <ipc_recv+0x4c>
		if (from_env_store) {
  8012aa:	85 f6                	test   %esi,%esi
  8012ac:	74 0a                	je     8012b8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8012ae:	a1 04 20 80 00       	mov    0x802004,%eax
  8012b3:	8b 40 74             	mov    0x74(%eax),%eax
  8012b6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8012b8:	85 db                	test   %ebx,%ebx
  8012ba:	74 0a                	je     8012c6 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8012bc:	a1 04 20 80 00       	mov    0x802004,%eax
  8012c1:	8b 40 78             	mov    0x78(%eax),%eax
  8012c4:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8012c6:	a1 04 20 80 00       	mov    0x802004,%eax
  8012cb:	8b 40 70             	mov    0x70(%eax),%eax
  8012ce:	eb 14                	jmp    8012e4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8012d0:	85 f6                	test   %esi,%esi
  8012d2:	74 06                	je     8012da <ipc_recv+0x56>
		*from_env_store = 0;
  8012d4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8012da:	85 db                	test   %ebx,%ebx
  8012dc:	74 06                	je     8012e4 <ipc_recv+0x60>
		*perm_store = 0;
  8012de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	57                   	push   %edi
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 1c             	sub    $0x1c,%esp
  8012f4:	8b 75 10             	mov    0x10(%ebp),%esi
  8012f7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8012fa:	85 f6                	test   %esi,%esi
  8012fc:	75 05                	jne    801303 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8012fe:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801303:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801307:	89 74 24 08          	mov    %esi,0x8(%esp)
  80130b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	e8 e8 fa ff ff       	call   800e05 <sys_ipc_try_send>
  80131d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80131f:	e8 22 f9 ff ff       	call   800c46 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801324:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801327:	74 da                	je     801303 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801329:	85 db                	test   %ebx,%ebx
  80132b:	74 20                	je     80134d <ipc_send+0x62>
		panic("send fail: %e", err);
  80132d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801331:	c7 44 24 08 6d 1a 80 	movl   $0x801a6d,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 7b 1a 80 00 	movl   $0x801a7b,(%esp)
  801348:	e8 63 ee ff ff       	call   8001b0 <_panic>
	}
	return;
}
  80134d:	83 c4 1c             	add    $0x1c,%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	53                   	push   %ebx
  801359:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80135c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801361:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801368:	89 c2                	mov    %eax,%edx
  80136a:	c1 e2 07             	shl    $0x7,%edx
  80136d:	29 ca                	sub    %ecx,%edx
  80136f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801375:	8b 52 50             	mov    0x50(%edx),%edx
  801378:	39 da                	cmp    %ebx,%edx
  80137a:	75 0f                	jne    80138b <ipc_find_env+0x36>
			return envs[i].env_id;
  80137c:	c1 e0 07             	shl    $0x7,%eax
  80137f:	29 c8                	sub    %ecx,%eax
  801381:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801386:	8b 40 40             	mov    0x40(%eax),%eax
  801389:	eb 0c                	jmp    801397 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80138b:	40                   	inc    %eax
  80138c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801391:	75 ce                	jne    801361 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801393:	66 b8 00 00          	mov    $0x0,%ax
}
  801397:	5b                   	pop    %ebx
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    
	...

0080139c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013a2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013a9:	0f 85 80 00 00 00    	jne    80142f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8013af:	a1 04 20 80 00       	mov    0x802004,%eax
  8013b4:	8b 40 48             	mov    0x48(%eax),%eax
  8013b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013c6:	ee 
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	e8 96 f8 ff ff       	call   800c65 <sys_page_alloc>
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 20                	jns    8013f3 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8013d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d7:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  8013de:	00 
  8013df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8013e6:	00 
  8013e7:	c7 04 24 e4 1a 80 00 	movl   $0x801ae4,(%esp)
  8013ee:	e8 bd ed ff ff       	call   8001b0 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8013f3:	a1 04 20 80 00       	mov    0x802004,%eax
  8013f8:	8b 40 48             	mov    0x48(%eax),%eax
  8013fb:	c7 44 24 04 3c 14 80 	movl   $0x80143c,0x4(%esp)
  801402:	00 
  801403:	89 04 24             	mov    %eax,(%esp)
  801406:	e8 a7 f9 ff ff       	call   800db2 <sys_env_set_pgfault_upcall>
  80140b:	85 c0                	test   %eax,%eax
  80140d:	79 20                	jns    80142f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80140f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801413:	c7 44 24 08 b4 1a 80 	movl   $0x801ab4,0x8(%esp)
  80141a:	00 
  80141b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801422:	00 
  801423:	c7 04 24 e4 1a 80 00 	movl   $0x801ae4,(%esp)
  80142a:	e8 81 ed ff ff       	call   8001b0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    
  801439:	00 00                	add    %al,(%eax)
	...

0080143c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80143c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80143d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801442:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801444:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  801447:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80144b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80144d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  801450:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  801451:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  801454:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  801456:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  801459:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80145a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80145d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80145e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80145f:	c3                   	ret    

00801460 <__udivdi3>:
  801460:	55                   	push   %ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	83 ec 10             	sub    $0x10,%esp
  801466:	8b 74 24 20          	mov    0x20(%esp),%esi
  80146a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80146e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801472:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801476:	89 cd                	mov    %ecx,%ebp
  801478:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80147c:	85 c0                	test   %eax,%eax
  80147e:	75 2c                	jne    8014ac <__udivdi3+0x4c>
  801480:	39 f9                	cmp    %edi,%ecx
  801482:	77 68                	ja     8014ec <__udivdi3+0x8c>
  801484:	85 c9                	test   %ecx,%ecx
  801486:	75 0b                	jne    801493 <__udivdi3+0x33>
  801488:	b8 01 00 00 00       	mov    $0x1,%eax
  80148d:	31 d2                	xor    %edx,%edx
  80148f:	f7 f1                	div    %ecx
  801491:	89 c1                	mov    %eax,%ecx
  801493:	31 d2                	xor    %edx,%edx
  801495:	89 f8                	mov    %edi,%eax
  801497:	f7 f1                	div    %ecx
  801499:	89 c7                	mov    %eax,%edi
  80149b:	89 f0                	mov    %esi,%eax
  80149d:	f7 f1                	div    %ecx
  80149f:	89 c6                	mov    %eax,%esi
  8014a1:	89 f0                	mov    %esi,%eax
  8014a3:	89 fa                	mov    %edi,%edx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	5e                   	pop    %esi
  8014a9:	5f                   	pop    %edi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    
  8014ac:	39 f8                	cmp    %edi,%eax
  8014ae:	77 2c                	ja     8014dc <__udivdi3+0x7c>
  8014b0:	0f bd f0             	bsr    %eax,%esi
  8014b3:	83 f6 1f             	xor    $0x1f,%esi
  8014b6:	75 4c                	jne    801504 <__udivdi3+0xa4>
  8014b8:	39 f8                	cmp    %edi,%eax
  8014ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8014bf:	72 0a                	jb     8014cb <__udivdi3+0x6b>
  8014c1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8014c5:	0f 87 ad 00 00 00    	ja     801578 <__udivdi3+0x118>
  8014cb:	be 01 00 00 00       	mov    $0x1,%esi
  8014d0:	89 f0                	mov    %esi,%eax
  8014d2:	89 fa                	mov    %edi,%edx
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
  8014dc:	31 ff                	xor    %edi,%edi
  8014de:	31 f6                	xor    %esi,%esi
  8014e0:	89 f0                	mov    %esi,%eax
  8014e2:	89 fa                	mov    %edi,%edx
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    
  8014eb:	90                   	nop
  8014ec:	89 fa                	mov    %edi,%edx
  8014ee:	89 f0                	mov    %esi,%eax
  8014f0:	f7 f1                	div    %ecx
  8014f2:	89 c6                	mov    %eax,%esi
  8014f4:	31 ff                	xor    %edi,%edi
  8014f6:	89 f0                	mov    %esi,%eax
  8014f8:	89 fa                	mov    %edi,%edx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
  801501:	8d 76 00             	lea    0x0(%esi),%esi
  801504:	89 f1                	mov    %esi,%ecx
  801506:	d3 e0                	shl    %cl,%eax
  801508:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150c:	b8 20 00 00 00       	mov    $0x20,%eax
  801511:	29 f0                	sub    %esi,%eax
  801513:	89 ea                	mov    %ebp,%edx
  801515:	88 c1                	mov    %al,%cl
  801517:	d3 ea                	shr    %cl,%edx
  801519:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80151d:	09 ca                	or     %ecx,%edx
  80151f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801523:	89 f1                	mov    %esi,%ecx
  801525:	d3 e5                	shl    %cl,%ebp
  801527:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80152b:	89 fd                	mov    %edi,%ebp
  80152d:	88 c1                	mov    %al,%cl
  80152f:	d3 ed                	shr    %cl,%ebp
  801531:	89 fa                	mov    %edi,%edx
  801533:	89 f1                	mov    %esi,%ecx
  801535:	d3 e2                	shl    %cl,%edx
  801537:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80153b:	88 c1                	mov    %al,%cl
  80153d:	d3 ef                	shr    %cl,%edi
  80153f:	09 d7                	or     %edx,%edi
  801541:	89 f8                	mov    %edi,%eax
  801543:	89 ea                	mov    %ebp,%edx
  801545:	f7 74 24 08          	divl   0x8(%esp)
  801549:	89 d1                	mov    %edx,%ecx
  80154b:	89 c7                	mov    %eax,%edi
  80154d:	f7 64 24 0c          	mull   0xc(%esp)
  801551:	39 d1                	cmp    %edx,%ecx
  801553:	72 17                	jb     80156c <__udivdi3+0x10c>
  801555:	74 09                	je     801560 <__udivdi3+0x100>
  801557:	89 fe                	mov    %edi,%esi
  801559:	31 ff                	xor    %edi,%edi
  80155b:	e9 41 ff ff ff       	jmp    8014a1 <__udivdi3+0x41>
  801560:	8b 54 24 04          	mov    0x4(%esp),%edx
  801564:	89 f1                	mov    %esi,%ecx
  801566:	d3 e2                	shl    %cl,%edx
  801568:	39 c2                	cmp    %eax,%edx
  80156a:	73 eb                	jae    801557 <__udivdi3+0xf7>
  80156c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80156f:	31 ff                	xor    %edi,%edi
  801571:	e9 2b ff ff ff       	jmp    8014a1 <__udivdi3+0x41>
  801576:	66 90                	xchg   %ax,%ax
  801578:	31 f6                	xor    %esi,%esi
  80157a:	e9 22 ff ff ff       	jmp    8014a1 <__udivdi3+0x41>
	...

00801580 <__umoddi3>:
  801580:	55                   	push   %ebp
  801581:	57                   	push   %edi
  801582:	56                   	push   %esi
  801583:	83 ec 20             	sub    $0x20,%esp
  801586:	8b 44 24 30          	mov    0x30(%esp),%eax
  80158a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80158e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801592:	8b 74 24 34          	mov    0x34(%esp),%esi
  801596:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80159a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80159e:	89 c7                	mov    %eax,%edi
  8015a0:	89 f2                	mov    %esi,%edx
  8015a2:	85 ed                	test   %ebp,%ebp
  8015a4:	75 16                	jne    8015bc <__umoddi3+0x3c>
  8015a6:	39 f1                	cmp    %esi,%ecx
  8015a8:	0f 86 a6 00 00 00    	jbe    801654 <__umoddi3+0xd4>
  8015ae:	f7 f1                	div    %ecx
  8015b0:	89 d0                	mov    %edx,%eax
  8015b2:	31 d2                	xor    %edx,%edx
  8015b4:	83 c4 20             	add    $0x20,%esp
  8015b7:	5e                   	pop    %esi
  8015b8:	5f                   	pop    %edi
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    
  8015bb:	90                   	nop
  8015bc:	39 f5                	cmp    %esi,%ebp
  8015be:	0f 87 ac 00 00 00    	ja     801670 <__umoddi3+0xf0>
  8015c4:	0f bd c5             	bsr    %ebp,%eax
  8015c7:	83 f0 1f             	xor    $0x1f,%eax
  8015ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ce:	0f 84 a8 00 00 00    	je     80167c <__umoddi3+0xfc>
  8015d4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015d8:	d3 e5                	shl    %cl,%ebp
  8015da:	bf 20 00 00 00       	mov    $0x20,%edi
  8015df:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8015e3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015e7:	89 f9                	mov    %edi,%ecx
  8015e9:	d3 e8                	shr    %cl,%eax
  8015eb:	09 e8                	or     %ebp,%eax
  8015ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8015f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015f5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015f9:	d3 e0                	shl    %cl,%eax
  8015fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ff:	89 f2                	mov    %esi,%edx
  801601:	d3 e2                	shl    %cl,%edx
  801603:	8b 44 24 14          	mov    0x14(%esp),%eax
  801607:	d3 e0                	shl    %cl,%eax
  801609:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80160d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801611:	89 f9                	mov    %edi,%ecx
  801613:	d3 e8                	shr    %cl,%eax
  801615:	09 d0                	or     %edx,%eax
  801617:	d3 ee                	shr    %cl,%esi
  801619:	89 f2                	mov    %esi,%edx
  80161b:	f7 74 24 18          	divl   0x18(%esp)
  80161f:	89 d6                	mov    %edx,%esi
  801621:	f7 64 24 0c          	mull   0xc(%esp)
  801625:	89 c5                	mov    %eax,%ebp
  801627:	89 d1                	mov    %edx,%ecx
  801629:	39 d6                	cmp    %edx,%esi
  80162b:	72 67                	jb     801694 <__umoddi3+0x114>
  80162d:	74 75                	je     8016a4 <__umoddi3+0x124>
  80162f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801633:	29 e8                	sub    %ebp,%eax
  801635:	19 ce                	sbb    %ecx,%esi
  801637:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80163b:	d3 e8                	shr    %cl,%eax
  80163d:	89 f2                	mov    %esi,%edx
  80163f:	89 f9                	mov    %edi,%ecx
  801641:	d3 e2                	shl    %cl,%edx
  801643:	09 d0                	or     %edx,%eax
  801645:	89 f2                	mov    %esi,%edx
  801647:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80164b:	d3 ea                	shr    %cl,%edx
  80164d:	83 c4 20             	add    $0x20,%esp
  801650:	5e                   	pop    %esi
  801651:	5f                   	pop    %edi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    
  801654:	85 c9                	test   %ecx,%ecx
  801656:	75 0b                	jne    801663 <__umoddi3+0xe3>
  801658:	b8 01 00 00 00       	mov    $0x1,%eax
  80165d:	31 d2                	xor    %edx,%edx
  80165f:	f7 f1                	div    %ecx
  801661:	89 c1                	mov    %eax,%ecx
  801663:	89 f0                	mov    %esi,%eax
  801665:	31 d2                	xor    %edx,%edx
  801667:	f7 f1                	div    %ecx
  801669:	89 f8                	mov    %edi,%eax
  80166b:	e9 3e ff ff ff       	jmp    8015ae <__umoddi3+0x2e>
  801670:	89 f2                	mov    %esi,%edx
  801672:	83 c4 20             	add    $0x20,%esp
  801675:	5e                   	pop    %esi
  801676:	5f                   	pop    %edi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    
  801679:	8d 76 00             	lea    0x0(%esi),%esi
  80167c:	39 f5                	cmp    %esi,%ebp
  80167e:	72 04                	jb     801684 <__umoddi3+0x104>
  801680:	39 f9                	cmp    %edi,%ecx
  801682:	77 06                	ja     80168a <__umoddi3+0x10a>
  801684:	89 f2                	mov    %esi,%edx
  801686:	29 cf                	sub    %ecx,%edi
  801688:	19 ea                	sbb    %ebp,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	83 c4 20             	add    $0x20,%esp
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    
  801693:	90                   	nop
  801694:	89 d1                	mov    %edx,%ecx
  801696:	89 c5                	mov    %eax,%ebp
  801698:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80169c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8016a0:	eb 8d                	jmp    80162f <__umoddi3+0xaf>
  8016a2:	66 90                	xchg   %ax,%ax
  8016a4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8016a8:	72 ea                	jb     801694 <__umoddi3+0x114>
  8016aa:	89 f1                	mov    %esi,%ecx
  8016ac:	eb 81                	jmp    80162f <__umoddi3+0xaf>
