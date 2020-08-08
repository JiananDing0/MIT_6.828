
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 ab 01 00 00       	call   8001dc <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  800044:	e8 fb 02 00 00       	call   800344 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 55 1d 00 00       	call   801da9 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 ae 25 80 	movl   $0x8025ae,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 b7 25 80 00 	movl   $0x8025b7,(%esp)
  800073:	e8 d4 01 00 00       	call   80024c <_panic>
	if ((r = fork()) < 0)
  800078:	e8 fe 0f 00 00       	call   80107b <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 41 2a 80 	movl   $0x802a41,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 b7 25 80 00 	movl   $0x8025b7,(%esp)
  80009e:	e8 a9 01 00 00       	call   80024c <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 5d                	jne    800104 <umain+0xd0>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 78 14 00 00       	call   80152a <close>
		for (i = 0; i < 200; i++) {
  8000b2:	be 00 00 00 00       	mov    $0x0,%esi
			if (i % 10 == 0)
  8000b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8000bc:	89 f0                	mov    %esi,%eax
  8000be:	99                   	cltd   
  8000bf:	f7 fb                	idiv   %ebx
  8000c1:	85 d2                	test   %edx,%edx
  8000c3:	75 10                	jne    8000d5 <umain+0xa1>
				cprintf("%d.", i);
  8000c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c9:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  8000d0:	e8 6f 02 00 00       	call   800344 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 97 14 00 00       	call   80157b <dup>
			sys_yield();
  8000e4:	e8 f9 0b 00 00       	call   800ce2 <sys_yield>
			close(10);
  8000e9:	89 1c 24             	mov    %ebx,(%esp)
  8000ec:	e8 39 14 00 00       	call   80152a <close>
			sys_yield();
  8000f1:	e8 ec 0b 00 00       	call   800ce2 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000f6:	46                   	inc    %esi
  8000f7:	81 fe c8 00 00 00    	cmp    $0xc8,%esi
  8000fd:	75 bd                	jne    8000bc <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ff:	e8 2c 01 00 00       	call   800230 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800104:	89 f8                	mov    %edi,%eax
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	eb 28                	jmp    800147 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  80011f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 ef 1d 00 00       	call   801f19 <pipeisclosed>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	74 19                	je     800147 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  80012e:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  800135:	e8 0a 02 00 00       	call   800344 <cprintf>
			sys_env_destroy(r);
  80013a:	89 3c 24             	mov    %edi,(%esp)
  80013d:	e8 2f 0b 00 00       	call   800c71 <sys_env_destroy>
			exit();
  800142:	e8 e9 00 00 00       	call   800230 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800147:	8b 43 54             	mov    0x54(%ebx),%eax
  80014a:	83 f8 02             	cmp    $0x2,%eax
  80014d:	74 d0                	je     80011f <umain+0xeb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80014f:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  800156:	e8 e9 01 00 00       	call   800344 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 b3 1d 00 00       	call   801f19 <pipeisclosed>
  800166:	85 c0                	test   %eax,%eax
  800168:	74 1c                	je     800186 <umain+0x152>
		panic("somehow the other end of p[0] got closed!");
  80016a:	c7 44 24 08 84 25 80 	movl   $0x802584,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 b7 25 80 00 	movl   $0x8025b7,(%esp)
  800181:	e8 c6 00 00 00       	call   80024c <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800186:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 5a 12 00 00       	call   8013f2 <fd_lookup>
  800198:	85 c0                	test   %eax,%eax
  80019a:	79 20                	jns    8001bc <umain+0x188>
		panic("cannot look up p[0]: %e", r);
  80019c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a0:	c7 44 24 08 02 26 80 	movl   $0x802602,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 b7 25 80 00 	movl   $0x8025b7,(%esp)
  8001b7:	e8 90 00 00 00       	call   80024c <_panic>
	(void) fd2data(fd);
  8001bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 bd 11 00 00       	call   801384 <fd2data>
	cprintf("race didn't happen\n");
  8001c7:	c7 04 24 1a 26 80 00 	movl   $0x80261a,(%esp)
  8001ce:	e8 71 01 00 00       	call   800344 <cprintf>
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
	...

008001dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 10             	sub    $0x10,%esp
  8001e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001ea:	e8 d4 0a 00 00       	call   800cc3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001fb:	c1 e0 07             	shl    $0x7,%eax
  8001fe:	29 d0                	sub    %edx,%eax
  800200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800205:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020a:	85 f6                	test   %esi,%esi
  80020c:	7e 07                	jle    800215 <libmain+0x39>
		binaryname = argv[0];
  80020e:	8b 03                	mov    (%ebx),%eax
  800210:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800215:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800219:	89 34 24             	mov    %esi,(%esp)
  80021c:	e8 13 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800221:	e8 0a 00 00 00       	call   800230 <exit>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800236:	e8 20 13 00 00       	call   80155b <close_all>
	sys_env_destroy(0);
  80023b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800242:	e8 2a 0a 00 00       	call   800c71 <sys_env_destroy>
}
  800247:	c9                   	leave  
  800248:	c3                   	ret    
  800249:	00 00                	add    %al,(%eax)
	...

0080024c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800254:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800257:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80025d:	e8 61 0a 00 00       	call   800cc3 <sys_getenvid>
  800262:	8b 55 0c             	mov    0xc(%ebp),%edx
  800265:	89 54 24 10          	mov    %edx,0x10(%esp)
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800270:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  80027f:	e8 c0 00 00 00       	call   800344 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 45 10             	mov    0x10(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	e8 50 00 00 00       	call   8002e3 <vcprintf>
	cprintf("\n");
  800293:	c7 04 24 81 2b 80 00 	movl   $0x802b81,(%esp)
  80029a:	e8 a5 00 00 00       	call   800344 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029f:	cc                   	int3   
  8002a0:	eb fd                	jmp    80029f <_panic+0x53>
	...

008002a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 14             	sub    $0x14,%esp
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ae:	8b 03                	mov    (%ebx),%eax
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b7:	40                   	inc    %eax
  8002b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bf:	75 19                	jne    8002da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c8:	00 
  8002c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 60 09 00 00       	call   800c34 <sys_cputs>
		b->idx = 0;
  8002d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002da:	ff 43 04             	incl   0x4(%ebx)
}
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f3:	00 00 00 
	b.cnt = 0;
  8002f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	c7 04 24 a4 02 80 00 	movl   $0x8002a4,(%esp)
  80031f:	e8 82 01 00 00       	call   8004a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800324:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 f8 08 00 00       	call   800c34 <sys_cputs>

	return b.cnt;
}
  80033c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 87 ff ff ff       	call   8002e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    
	...

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
  800377:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800380:	85 c0                	test   %eax,%eax
  800382:	75 08                	jne    80038c <printnum+0x2c>
  800384:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800387:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038a:	77 57                	ja     8003e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800390:	4b                   	dec    %ebx
  800391:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800395:	8b 45 10             	mov    0x10(%ebp),%eax
  800398:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ab:	00 
  8003ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	e8 4e 1f 00 00       	call   80230c <__udivdi3>
  8003be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cd:	89 fa                	mov    %edi,%edx
  8003cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d2:	e8 89 ff ff ff       	call   800360 <printnum>
  8003d7:	eb 0f                	jmp    8003e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003dd:	89 34 24             	mov    %esi,(%esp)
  8003e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e3:	4b                   	dec    %ebx
  8003e4:	85 db                	test   %ebx,%ebx
  8003e6:	7f f1                	jg     8003d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003fe:	00 
  8003ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040c:	e8 1b 20 00 00       	call   80242c <__umoddi3>
  800411:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800415:	0f be 80 5b 26 80 00 	movsbl 0x80265b(%eax),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800422:	83 c4 3c             	add    $0x3c,%esp
  800425:	5b                   	pop    %ebx
  800426:	5e                   	pop    %esi
  800427:	5f                   	pop    %edi
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042d:	83 fa 01             	cmp    $0x1,%edx
  800430:	7e 0e                	jle    800440 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800432:	8b 10                	mov    (%eax),%edx
  800434:	8d 4a 08             	lea    0x8(%edx),%ecx
  800437:	89 08                	mov    %ecx,(%eax)
  800439:	8b 02                	mov    (%edx),%eax
  80043b:	8b 52 04             	mov    0x4(%edx),%edx
  80043e:	eb 22                	jmp    800462 <getuint+0x38>
	else if (lflag)
  800440:	85 d2                	test   %edx,%edx
  800442:	74 10                	je     800454 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 04             	lea    0x4(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	eb 0e                	jmp    800462 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800454:	8b 10                	mov    (%eax),%edx
  800456:	8d 4a 04             	lea    0x4(%edx),%ecx
  800459:	89 08                	mov    %ecx,(%eax)
  80045b:	8b 02                	mov    (%edx),%eax
  80045d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80046d:	8b 10                	mov    (%eax),%edx
  80046f:	3b 50 04             	cmp    0x4(%eax),%edx
  800472:	73 08                	jae    80047c <sprintputch+0x18>
		*b->buf++ = ch;
  800474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800477:	88 0a                	mov    %cl,(%edx)
  800479:	42                   	inc    %edx
  80047a:	89 10                	mov    %edx,(%eax)
}
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800484:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	8b 45 10             	mov    0x10(%ebp),%eax
  80048e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800492:	8b 45 0c             	mov    0xc(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 02 00 00 00       	call   8004a6 <vprintfmt>
	va_end(ap);
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	57                   	push   %edi
  8004aa:	56                   	push   %esi
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 4c             	sub    $0x4c,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004b5:	eb 12                	jmp    8004c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	0f 84 8b 03 00 00    	je     80084a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c9:	0f b6 06             	movzbl (%esi),%eax
  8004cc:	46                   	inc    %esi
  8004cd:	83 f8 25             	cmp    $0x25,%eax
  8004d0:	75 e5                	jne    8004b7 <vprintfmt+0x11>
  8004d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ee:	eb 26                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004f7:	eb 1d                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800500:	eb 14                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800505:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80050e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800511:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	0f b6 06             	movzbl (%esi),%eax
  800519:	8d 56 01             	lea    0x1(%esi),%edx
  80051c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051f:	8a 16                	mov    (%esi),%dl
  800521:	83 ea 23             	sub    $0x23,%edx
  800524:	80 fa 55             	cmp    $0x55,%dl
  800527:	0f 87 01 03 00 00    	ja     80082e <vprintfmt+0x388>
  80052d:	0f b6 d2             	movzbl %dl,%edx
  800530:	ff 24 95 a0 27 80 00 	jmp    *0x8027a0(,%edx,4)
  800537:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80053f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800542:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800546:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800549:	8d 50 d0             	lea    -0x30(%eax),%edx
  80054c:	83 fa 09             	cmp    $0x9,%edx
  80054f:	77 2a                	ja     80057b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800551:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800552:	eb eb                	jmp    80053f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800562:	eb 17                	jmp    80057b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800564:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800568:	78 98                	js     800502 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056d:	eb a7                	jmp    800516 <vprintfmt+0x70>
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800572:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800579:	eb 9b                	jmp    800516 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80057b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057f:	79 95                	jns    800516 <vprintfmt+0x70>
  800581:	eb 8b                	jmp    80050e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800583:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800587:	eb 8d                	jmp    800516 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a1:	e9 23 ff ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	79 02                	jns    8005b7 <vprintfmt+0x111>
  8005b5:	f7 d8                	neg    %eax
  8005b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b9:	83 f8 0f             	cmp    $0xf,%eax
  8005bc:	7f 0b                	jg     8005c9 <vprintfmt+0x123>
  8005be:	8b 04 85 00 29 80 00 	mov    0x802900(,%eax,4),%eax
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	75 23                	jne    8005ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cd:	c7 44 24 08 73 26 80 	movl   $0x802673,0x8(%esp)
  8005d4:	00 
  8005d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 9a fe ff ff       	call   80047e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e7:	e9 dd fe ff ff       	jmp    8004c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f0:	c7 44 24 08 5a 2b 80 	movl   $0x802b5a,0x8(%esp)
  8005f7:	00 
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ff:	89 14 24             	mov    %edx,(%esp)
  800602:	e8 77 fe ff ff       	call   80047e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 ba fe ff ff       	jmp    8004c9 <vprintfmt+0x23>
  80060f:	89 f9                	mov    %edi,%ecx
  800611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800614:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	85 f6                	test   %esi,%esi
  800624:	75 05                	jne    80062b <vprintfmt+0x185>
				p = "(null)";
  800626:	be 6c 26 80 00       	mov    $0x80266c,%esi
			if (width > 0 && padc != '-')
  80062b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062f:	0f 8e 84 00 00 00    	jle    8006b9 <vprintfmt+0x213>
  800635:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800639:	74 7e                	je     8006b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063f:	89 34 24             	mov    %esi,(%esp)
  800642:	e8 ab 02 00 00       	call   8008f2 <strnlen>
  800647:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80064a:	29 c2                	sub    %eax,%edx
  80064c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80064f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800653:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800656:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800659:	89 de                	mov    %ebx,%esi
  80065b:	89 d3                	mov    %edx,%ebx
  80065d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065f:	eb 0b                	jmp    80066c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	89 3c 24             	mov    %edi,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066b:	4b                   	dec    %ebx
  80066c:	85 db                	test   %ebx,%ebx
  80066e:	7f f1                	jg     800661 <vprintfmt+0x1bb>
  800670:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800673:	89 f3                	mov    %esi,%ebx
  800675:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	79 05                	jns    800684 <vprintfmt+0x1de>
  80067f:	b8 00 00 00 00       	mov    $0x0,%eax
  800684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800687:	29 c2                	sub    %eax,%edx
  800689:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80068c:	eb 2b                	jmp    8006b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80068e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800692:	74 18                	je     8006ac <vprintfmt+0x206>
  800694:	8d 50 e0             	lea    -0x20(%eax),%edx
  800697:	83 fa 5e             	cmp    $0x5e,%edx
  80069a:	76 10                	jbe    8006ac <vprintfmt+0x206>
					putch('?', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
  8006aa:	eb 0a                	jmp    8006b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8006b9:	0f be 06             	movsbl (%esi),%eax
  8006bc:	46                   	inc    %esi
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	74 21                	je     8006e2 <vprintfmt+0x23c>
  8006c1:	85 ff                	test   %edi,%edi
  8006c3:	78 c9                	js     80068e <vprintfmt+0x1e8>
  8006c5:	4f                   	dec    %edi
  8006c6:	79 c6                	jns    80068e <vprintfmt+0x1e8>
  8006c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cb:	89 de                	mov    %ebx,%esi
  8006cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d0:	eb 18                	jmp    8006ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006df:	4b                   	dec    %ebx
  8006e0:	eb 08                	jmp    8006ea <vprintfmt+0x244>
  8006e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e5:	89 de                	mov    %ebx,%esi
  8006e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ea:	85 db                	test   %ebx,%ebx
  8006ec:	7f e4                	jg     8006d2 <vprintfmt+0x22c>
  8006ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f6:	e9 ce fd ff ff       	jmp    8004c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7e 10                	jle    800710 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 08             	lea    0x8(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 30                	mov    (%eax),%esi
  80070b:	8b 78 04             	mov    0x4(%eax),%edi
  80070e:	eb 26                	jmp    800736 <vprintfmt+0x290>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	74 12                	je     800726 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 30                	mov    (%eax),%esi
  80071f:	89 f7                	mov    %esi,%edi
  800721:	c1 ff 1f             	sar    $0x1f,%edi
  800724:	eb 10                	jmp    800736 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 30                	mov    (%eax),%esi
  800731:	89 f7                	mov    %esi,%edi
  800733:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800736:	85 ff                	test   %edi,%edi
  800738:	78 0a                	js     800744 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073f:	e9 ac 00 00 00       	jmp    8007f0 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800752:	f7 de                	neg    %esi
  800754:	83 d7 00             	adc    $0x0,%edi
  800757:	f7 df                	neg    %edi
			}
			base = 10;
  800759:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075e:	e9 8d 00 00 00       	jmp    8007f0 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800763:	89 ca                	mov    %ecx,%edx
  800765:	8d 45 14             	lea    0x14(%ebp),%eax
  800768:	e8 bd fc ff ff       	call   80042a <getuint>
  80076d:	89 c6                	mov    %eax,%esi
  80076f:	89 d7                	mov    %edx,%edi
			base = 10;
  800771:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800776:	eb 78                	jmp    8007f0 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800786:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800791:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800794:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800798:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80079f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007a5:	e9 1f fd ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8007aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 50 04             	lea    0x4(%eax),%edx
  8007cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007cf:	8b 30                	mov    (%eax),%esi
  8007d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007db:	eb 13                	jmp    8007f0 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007dd:	89 ca                	mov    %ecx,%edx
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e2:	e8 43 fc ff ff       	call   80042a <getuint>
  8007e7:	89 c6                	mov    %eax,%esi
  8007e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8007eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800803:	89 34 24             	mov    %esi,(%esp)
  800806:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80080a:	89 da                	mov    %ebx,%edx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	e8 4c fb ff ff       	call   800360 <printnum>
			break;
  800814:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800817:	e9 ad fc ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800829:	e9 9b fc ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800832:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800839:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083c:	eb 01                	jmp    80083f <vprintfmt+0x399>
  80083e:	4e                   	dec    %esi
  80083f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800843:	75 f9                	jne    80083e <vprintfmt+0x398>
  800845:	e9 7f fc ff ff       	jmp    8004c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80084a:	83 c4 4c             	add    $0x4c,%esp
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5f                   	pop    %edi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 28             	sub    $0x28,%esp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800861:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800865:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800868:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086f:	85 c0                	test   %eax,%eax
  800871:	74 30                	je     8008a3 <vsnprintf+0x51>
  800873:	85 d2                	test   %edx,%edx
  800875:	7e 33                	jle    8008aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087e:	8b 45 10             	mov    0x10(%ebp),%eax
  800881:	89 44 24 08          	mov    %eax,0x8(%esp)
  800885:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	c7 04 24 64 04 80 00 	movl   $0x800464,(%esp)
  800893:	e8 0e fc ff ff       	call   8004a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800898:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a1:	eb 0c                	jmp    8008af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a8:	eb 05                	jmp    8008af <vsnprintf+0x5d>
  8008aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008be:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	89 04 24             	mov    %eax,(%esp)
  8008d2:	e8 7b ff ff ff       	call   800852 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d7:	c9                   	leave  
  8008d8:	c3                   	ret    
  8008d9:	00 00                	add    %al,(%eax)
	...

008008dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e7:	eb 01                	jmp    8008ea <strlen+0xe>
		n++;
  8008e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ee:	75 f9                	jne    8008e9 <strlen+0xd>
		n++;
	return n;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800900:	eb 01                	jmp    800903 <strnlen+0x11>
		n++;
  800902:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800903:	39 d0                	cmp    %edx,%eax
  800905:	74 06                	je     80090d <strnlen+0x1b>
  800907:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80090b:	75 f5                	jne    800902 <strnlen+0x10>
		n++;
	return n;
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800919:	ba 00 00 00 00       	mov    $0x0,%edx
  80091e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800921:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800924:	42                   	inc    %edx
  800925:	84 c9                	test   %cl,%cl
  800927:	75 f5                	jne    80091e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800929:	5b                   	pop    %ebx
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800936:	89 1c 24             	mov    %ebx,(%esp)
  800939:	e8 9e ff ff ff       	call   8008dc <strlen>
	strcpy(dst + len, src);
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	89 54 24 04          	mov    %edx,0x4(%esp)
  800945:	01 d8                	add    %ebx,%eax
  800947:	89 04 24             	mov    %eax,(%esp)
  80094a:	e8 c0 ff ff ff       	call   80090f <strcpy>
	return dst;
}
  80094f:	89 d8                	mov    %ebx,%eax
  800951:	83 c4 08             	add    $0x8,%esp
  800954:	5b                   	pop    %ebx
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800962:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096a:	eb 0c                	jmp    800978 <strncpy+0x21>
		*dst++ = *src;
  80096c:	8a 1a                	mov    (%edx),%bl
  80096e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800971:	80 3a 01             	cmpb   $0x1,(%edx)
  800974:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800977:	41                   	inc    %ecx
  800978:	39 f1                	cmp    %esi,%ecx
  80097a:	75 f0                	jne    80096c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 75 08             	mov    0x8(%ebp),%esi
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098e:	85 d2                	test   %edx,%edx
  800990:	75 0a                	jne    80099c <strlcpy+0x1c>
  800992:	89 f0                	mov    %esi,%eax
  800994:	eb 1a                	jmp    8009b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800996:	88 18                	mov    %bl,(%eax)
  800998:	40                   	inc    %eax
  800999:	41                   	inc    %ecx
  80099a:	eb 02                	jmp    80099e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80099c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80099e:	4a                   	dec    %edx
  80099f:	74 0a                	je     8009ab <strlcpy+0x2b>
  8009a1:	8a 19                	mov    (%ecx),%bl
  8009a3:	84 db                	test   %bl,%bl
  8009a5:	75 ef                	jne    800996 <strlcpy+0x16>
  8009a7:	89 c2                	mov    %eax,%edx
  8009a9:	eb 02                	jmp    8009ad <strlcpy+0x2d>
  8009ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009b0:	29 f0                	sub    %esi,%eax
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009bf:	eb 02                	jmp    8009c3 <strcmp+0xd>
		p++, q++;
  8009c1:	41                   	inc    %ecx
  8009c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c3:	8a 01                	mov    (%ecx),%al
  8009c5:	84 c0                	test   %al,%al
  8009c7:	74 04                	je     8009cd <strcmp+0x17>
  8009c9:	3a 02                	cmp    (%edx),%al
  8009cb:	74 f4                	je     8009c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cd:	0f b6 c0             	movzbl %al,%eax
  8009d0:	0f b6 12             	movzbl (%edx),%edx
  8009d3:	29 d0                	sub    %edx,%eax
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009e4:	eb 03                	jmp    8009e9 <strncmp+0x12>
		n--, p++, q++;
  8009e6:	4a                   	dec    %edx
  8009e7:	40                   	inc    %eax
  8009e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e9:	85 d2                	test   %edx,%edx
  8009eb:	74 14                	je     800a01 <strncmp+0x2a>
  8009ed:	8a 18                	mov    (%eax),%bl
  8009ef:	84 db                	test   %bl,%bl
  8009f1:	74 04                	je     8009f7 <strncmp+0x20>
  8009f3:	3a 19                	cmp    (%ecx),%bl
  8009f5:	74 ef                	je     8009e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f7:	0f b6 00             	movzbl (%eax),%eax
  8009fa:	0f b6 11             	movzbl (%ecx),%edx
  8009fd:	29 d0                	sub    %edx,%eax
  8009ff:	eb 05                	jmp    800a06 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a06:	5b                   	pop    %ebx
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a12:	eb 05                	jmp    800a19 <strchr+0x10>
		if (*s == c)
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	74 0c                	je     800a24 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a18:	40                   	inc    %eax
  800a19:	8a 10                	mov    (%eax),%dl
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	75 f5                	jne    800a14 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a2f:	eb 05                	jmp    800a36 <strfind+0x10>
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 07                	je     800a3c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a35:	40                   	inc    %eax
  800a36:	8a 10                	mov    (%eax),%dl
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	75 f5                	jne    800a31 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4d:	85 c9                	test   %ecx,%ecx
  800a4f:	74 30                	je     800a81 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a51:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a57:	75 25                	jne    800a7e <memset+0x40>
  800a59:	f6 c1 03             	test   $0x3,%cl
  800a5c:	75 20                	jne    800a7e <memset+0x40>
		c &= 0xFF;
  800a5e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a61:	89 d3                	mov    %edx,%ebx
  800a63:	c1 e3 08             	shl    $0x8,%ebx
  800a66:	89 d6                	mov    %edx,%esi
  800a68:	c1 e6 18             	shl    $0x18,%esi
  800a6b:	89 d0                	mov    %edx,%eax
  800a6d:	c1 e0 10             	shl    $0x10,%eax
  800a70:	09 f0                	or     %esi,%eax
  800a72:	09 d0                	or     %edx,%eax
  800a74:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a76:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a79:	fc                   	cld    
  800a7a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7c:	eb 03                	jmp    800a81 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7e:	fc                   	cld    
  800a7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a81:	89 f8                	mov    %edi,%eax
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 34                	jae    800ace <memmove+0x46>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2d                	jae    800ace <memmove+0x46>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f6 c2 03             	test   $0x3,%dl
  800aa7:	75 1b                	jne    800ac4 <memmove+0x3c>
  800aa9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaf:	75 13                	jne    800ac4 <memmove+0x3c>
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 0e                	jne    800ac4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab6:	83 ef 04             	sub    $0x4,%edi
  800ab9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800abf:	fd                   	std    
  800ac0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac2:	eb 07                	jmp    800acb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac4:	4f                   	dec    %edi
  800ac5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac8:	fd                   	std    
  800ac9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acb:	fc                   	cld    
  800acc:	eb 20                	jmp    800aee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad4:	75 13                	jne    800ae9 <memmove+0x61>
  800ad6:	a8 03                	test   $0x3,%al
  800ad8:	75 0f                	jne    800ae9 <memmove+0x61>
  800ada:	f6 c1 03             	test   $0x3,%cl
  800add:	75 0a                	jne    800ae9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	fc                   	cld    
  800ae5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae7:	eb 05                	jmp    800aee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	fc                   	cld    
  800aec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af8:	8b 45 10             	mov    0x10(%ebp),%eax
  800afb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	89 04 24             	mov    %eax,(%esp)
  800b0c:	e8 77 ff ff ff       	call   800a88 <memmove>
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	eb 16                	jmp    800b3f <memcmp+0x2c>
		if (*s1 != *s2)
  800b29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b2c:	42                   	inc    %edx
  800b2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b31:	38 c8                	cmp    %cl,%al
  800b33:	74 0a                	je     800b3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b35:	0f b6 c0             	movzbl %al,%eax
  800b38:	0f b6 c9             	movzbl %cl,%ecx
  800b3b:	29 c8                	sub    %ecx,%eax
  800b3d:	eb 09                	jmp    800b48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	39 da                	cmp    %ebx,%edx
  800b41:	75 e6                	jne    800b29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5b:	eb 05                	jmp    800b62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5d:	38 08                	cmp    %cl,(%eax)
  800b5f:	74 05                	je     800b66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b61:	40                   	inc    %eax
  800b62:	39 d0                	cmp    %edx,%eax
  800b64:	72 f7                	jb     800b5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b74:	eb 01                	jmp    800b77 <strtol+0xf>
		s++;
  800b76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b77:	8a 02                	mov    (%edx),%al
  800b79:	3c 20                	cmp    $0x20,%al
  800b7b:	74 f9                	je     800b76 <strtol+0xe>
  800b7d:	3c 09                	cmp    $0x9,%al
  800b7f:	74 f5                	je     800b76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b81:	3c 2b                	cmp    $0x2b,%al
  800b83:	75 08                	jne    800b8d <strtol+0x25>
		s++;
  800b85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b86:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8b:	eb 13                	jmp    800ba0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8d:	3c 2d                	cmp    $0x2d,%al
  800b8f:	75 0a                	jne    800b9b <strtol+0x33>
		s++, neg = 1;
  800b91:	8d 52 01             	lea    0x1(%edx),%edx
  800b94:	bf 01 00 00 00       	mov    $0x1,%edi
  800b99:	eb 05                	jmp    800ba0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba0:	85 db                	test   %ebx,%ebx
  800ba2:	74 05                	je     800ba9 <strtol+0x41>
  800ba4:	83 fb 10             	cmp    $0x10,%ebx
  800ba7:	75 28                	jne    800bd1 <strtol+0x69>
  800ba9:	8a 02                	mov    (%edx),%al
  800bab:	3c 30                	cmp    $0x30,%al
  800bad:	75 10                	jne    800bbf <strtol+0x57>
  800baf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb3:	75 0a                	jne    800bbf <strtol+0x57>
		s += 2, base = 16;
  800bb5:	83 c2 02             	add    $0x2,%edx
  800bb8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbd:	eb 12                	jmp    800bd1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bbf:	85 db                	test   %ebx,%ebx
  800bc1:	75 0e                	jne    800bd1 <strtol+0x69>
  800bc3:	3c 30                	cmp    $0x30,%al
  800bc5:	75 05                	jne    800bcc <strtol+0x64>
		s++, base = 8;
  800bc7:	42                   	inc    %edx
  800bc8:	b3 08                	mov    $0x8,%bl
  800bca:	eb 05                	jmp    800bd1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bcc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd8:	8a 0a                	mov    (%edx),%cl
  800bda:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 08                	ja     800bea <strtol+0x82>
			dig = *s - '0';
  800be2:	0f be c9             	movsbl %cl,%ecx
  800be5:	83 e9 30             	sub    $0x30,%ecx
  800be8:	eb 1e                	jmp    800c08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bed:	80 fb 19             	cmp    $0x19,%bl
  800bf0:	77 08                	ja     800bfa <strtol+0x92>
			dig = *s - 'a' + 10;
  800bf2:	0f be c9             	movsbl %cl,%ecx
  800bf5:	83 e9 57             	sub    $0x57,%ecx
  800bf8:	eb 0e                	jmp    800c08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bfa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bfd:	80 fb 19             	cmp    $0x19,%bl
  800c00:	77 12                	ja     800c14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c02:	0f be c9             	movsbl %cl,%ecx
  800c05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c08:	39 f1                	cmp    %esi,%ecx
  800c0a:	7d 0c                	jge    800c18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c0c:	42                   	inc    %edx
  800c0d:	0f af c6             	imul   %esi,%eax
  800c10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c12:	eb c4                	jmp    800bd8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c14:	89 c1                	mov    %eax,%ecx
  800c16:	eb 02                	jmp    800c1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1e:	74 05                	je     800c25 <strtol+0xbd>
		*endptr = (char *) s;
  800c20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c25:	85 ff                	test   %edi,%edi
  800c27:	74 04                	je     800c2d <strtol+0xc5>
  800c29:	89 c8                	mov    %ecx,%eax
  800c2b:	f7 d8                	neg    %eax
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
	...

00800c34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 c3                	mov    %eax,%ebx
  800c47:	89 c7                	mov    %eax,%edi
  800c49:	89 c6                	mov    %eax,%esi
  800c4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	89 d3                	mov    %edx,%ebx
  800c66:	89 d7                	mov    %edx,%edi
  800c68:	89 d6                	mov    %edx,%esi
  800c6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 cb                	mov    %ecx,%ebx
  800c89:	89 cf                	mov    %ecx,%edi
  800c8b:	89 ce                	mov    %ecx,%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 28                	jle    800cbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800ca6:	00 
  800ca7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cae:	00 
  800caf:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800cb6:	e8 91 f5 ff ff       	call   80024c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbb:	83 c4 2c             	add    $0x2c,%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	89 d3                	mov    %edx,%ebx
  800cd7:	89 d7                	mov    %edx,%edi
  800cd9:	89 d6                	mov    %edx,%esi
  800cdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_yield>:

void
sys_yield(void)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf2:	89 d1                	mov    %edx,%ecx
  800cf4:	89 d3                	mov    %edx,%ebx
  800cf6:	89 d7                	mov    %edx,%edi
  800cf8:	89 d6                	mov    %edx,%esi
  800cfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 f7                	mov    %esi,%edi
  800d1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7e 28                	jle    800d4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d30:	00 
  800d31:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d38:	00 
  800d39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d40:	00 
  800d41:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d48:	e8 ff f4 ff ff       	call   80024c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d4d:	83 c4 2c             	add    $0x2c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d63:	8b 75 18             	mov    0x18(%ebp),%esi
  800d66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 28                	jle    800da0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d83:	00 
  800d84:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d8b:	00 
  800d8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d93:	00 
  800d94:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d9b:	e8 ac f4 ff ff       	call   80024c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da0:	83 c4 2c             	add    $0x2c,%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 28                	jle    800df3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800dde:	00 
  800ddf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de6:	00 
  800de7:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800dee:	e8 59 f4 ff ff       	call   80024c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df3:	83 c4 2c             	add    $0x2c,%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e09:	b8 08 00 00 00       	mov    $0x8,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	89 df                	mov    %ebx,%edi
  800e16:	89 de                	mov    %ebx,%esi
  800e18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	7e 28                	jle    800e46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e29:	00 
  800e2a:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e31:	00 
  800e32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e39:	00 
  800e3a:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e41:	e8 06 f4 ff ff       	call   80024c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e46:	83 c4 2c             	add    $0x2c,%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	89 de                	mov    %ebx,%esi
  800e6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 28                	jle    800e99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e84:	00 
  800e85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8c:	00 
  800e8d:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e94:	e8 b3 f3 ff ff       	call   80024c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e99:	83 c4 2c             	add    $0x2c,%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	89 df                	mov    %ebx,%edi
  800ebc:	89 de                	mov    %ebx,%esi
  800ebe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	7e 28                	jle    800eec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edf:	00 
  800ee0:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800ee7:	e8 60 f3 ff ff       	call   80024c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eec:	83 c4 2c             	add    $0x2c,%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	be 00 00 00 00       	mov    $0x0,%esi
  800eff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2d:	89 cb                	mov    %ecx,%ebx
  800f2f:	89 cf                	mov    %ecx,%edi
  800f31:	89 ce                	mov    %ecx,%esi
  800f33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	7e 28                	jle    800f61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f44:	00 
  800f45:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f5c:	e8 eb f2 ff ff       	call   80024c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f61:	83 c4 2c             	add    $0x2c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	00 00                	add    %al,(%eax)
	...

00800f6c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 24             	sub    $0x24,%esp
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f76:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800f78:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f7c:	75 20                	jne    800f9e <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f7e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f82:	c7 44 24 08 8c 29 80 	movl   $0x80298c,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  800f99:	e8 ae f2 ff ff       	call   80024c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800fa4:	89 d8                	mov    %ebx,%eax
  800fa6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fa9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb0:	f6 c4 08             	test   $0x8,%ah
  800fb3:	75 1c                	jne    800fd1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800fb5:	c7 44 24 08 bc 29 80 	movl   $0x8029bc,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  800fcc:	e8 7b f2 ff ff       	call   80024c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800fd1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe0:	00 
  800fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe8:	e8 14 fd ff ff       	call   800d01 <sys_page_alloc>
  800fed:	85 c0                	test   %eax,%eax
  800fef:	79 20                	jns    801011 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800ff1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff5:	c7 44 24 08 16 2a 80 	movl   $0x802a16,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  80100c:	e8 3b f2 ff ff       	call   80024c <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  801011:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801018:	00 
  801019:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80101d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801024:	e8 5f fa ff ff       	call   800a88 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  801029:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801030:	00 
  801031:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801035:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104c:	e8 04 fd ff ff       	call   800d55 <sys_page_map>
  801051:	85 c0                	test   %eax,%eax
  801053:	79 20                	jns    801075 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  801055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801059:	c7 44 24 08 29 2a 80 	movl   $0x802a29,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  801070:	e8 d7 f1 ff ff       	call   80024c <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  801075:	83 c4 24             	add    $0x24,%esp
  801078:	5b                   	pop    %ebx
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  801084:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  80108b:	e8 5c 10 00 00       	call   8020ec <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801090:	ba 07 00 00 00       	mov    $0x7,%edx
  801095:	89 d0                	mov    %edx,%eax
  801097:	cd 30                	int    $0x30
  801099:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80109c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 20                	jns    8010c3 <fork+0x48>
		panic("sys_exofork: %e", envid);
  8010a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a7:	c7 44 24 08 3a 2a 80 	movl   $0x802a3a,0x8(%esp)
  8010ae:	00 
  8010af:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  8010be:	e8 89 f1 ff ff       	call   80024c <_panic>
	}
	
	// Child process
	if (envid == 0) {
  8010c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010c7:	75 25                	jne    8010ee <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c9:	e8 f5 fb ff ff       	call   800cc3 <sys_getenvid>
  8010ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010da:	c1 e0 07             	shl    $0x7,%eax
  8010dd:	29 d0                	sub    %edx,%eax
  8010df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010e9:	e9 58 02 00 00       	jmp    801346 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  8010ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f3:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010f8:	89 f0                	mov    %esi,%eax
  8010fa:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801104:	a8 01                	test   $0x1,%al
  801106:	0f 84 7a 01 00 00    	je     801286 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80110c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801113:	a8 01                	test   $0x1,%al
  801115:	0f 84 6b 01 00 00    	je     801286 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80111b:	a1 04 40 80 00       	mov    0x804004,%eax
  801120:	8b 40 48             	mov    0x48(%eax),%eax
  801123:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801126:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112d:	f6 c4 04             	test   $0x4,%ah
  801130:	74 52                	je     801184 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801132:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801139:	25 07 0e 00 00       	and    $0xe07,%eax
  80113e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801142:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801146:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801149:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801154:	89 04 24             	mov    %eax,(%esp)
  801157:	e8 f9 fb ff ff       	call   800d55 <sys_page_map>
  80115c:	85 c0                	test   %eax,%eax
  80115e:	0f 89 22 01 00 00    	jns    801286 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801164:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801168:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  80116f:	00 
  801170:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801177:	00 
  801178:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  80117f:	e8 c8 f0 ff ff       	call   80024c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801184:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80118b:	f6 c4 08             	test   $0x8,%ah
  80118e:	75 0f                	jne    80119f <fork+0x124>
  801190:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801197:	a8 02                	test   $0x2,%al
  801199:	0f 84 99 00 00 00    	je     801238 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80119f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011a6:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011a9:	83 f8 01             	cmp    $0x1,%eax
  8011ac:	19 db                	sbb    %ebx,%ebx
  8011ae:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011b1:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011b7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	e8 80 fb ff ff       	call   800d55 <sys_page_map>
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	79 20                	jns    8011f9 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8011d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011dd:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  8011e4:	00 
  8011e5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8011ec:	00 
  8011ed:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  8011f4:	e8 53 f0 ff ff       	call   80024c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011f9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801204:	89 44 24 08          	mov    %eax,0x8(%esp)
  801208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120c:	89 04 24             	mov    %eax,(%esp)
  80120f:	e8 41 fb ff ff       	call   800d55 <sys_page_map>
  801214:	85 c0                	test   %eax,%eax
  801216:	79 6e                	jns    801286 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801218:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121c:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  801223:	00 
  801224:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80122b:	00 
  80122c:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  801233:	e8 14 f0 ff ff       	call   80024c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801238:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80123f:	25 07 0e 00 00       	and    $0xe07,%eax
  801244:	89 44 24 10          	mov    %eax,0x10(%esp)
  801248:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80124c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80124f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801253:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125a:	89 04 24             	mov    %eax,(%esp)
  80125d:	e8 f3 fa ff ff       	call   800d55 <sys_page_map>
  801262:	85 c0                	test   %eax,%eax
  801264:	79 20                	jns    801286 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801266:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126a:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  801271:	00 
  801272:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801279:	00 
  80127a:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  801281:	e8 c6 ef ff ff       	call   80024c <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801286:	46                   	inc    %esi
  801287:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80128d:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801293:	0f 85 5f fe ff ff    	jne    8010f8 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801299:	c7 44 24 04 8c 21 80 	movl   $0x80218c,0x4(%esp)
  8012a0:	00 
  8012a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a4:	89 04 24             	mov    %eax,(%esp)
  8012a7:	e8 f5 fb ff ff       	call   800ea1 <sys_env_set_pgfault_upcall>
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	79 20                	jns    8012d0 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8012b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b4:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  8012bb:	00 
  8012bc:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012c3:	00 
  8012c4:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  8012cb:	e8 7c ef ff ff       	call   80024c <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8012d0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d7:	00 
  8012d8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012df:	ee 
  8012e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012e3:	89 04 24             	mov    %eax,(%esp)
  8012e6:	e8 16 fa ff ff       	call   800d01 <sys_page_alloc>
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	79 20                	jns    80130f <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8012ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f3:	c7 44 24 08 16 2a 80 	movl   $0x802a16,0x8(%esp)
  8012fa:	00 
  8012fb:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801302:	00 
  801303:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  80130a:	e8 3d ef ff ff       	call   80024c <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80130f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801316:	00 
  801317:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80131a:	89 04 24             	mov    %eax,(%esp)
  80131d:	e8 d9 fa ff ff       	call   800dfb <sys_env_set_status>
  801322:	85 c0                	test   %eax,%eax
  801324:	79 20                	jns    801346 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801326:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132a:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
  801331:	00 
  801332:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801339:	00 
  80133a:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  801341:	e8 06 ef ff ff       	call   80024c <_panic>
	}
	
	return envid;
}
  801346:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801349:	83 c4 3c             	add    $0x3c,%esp
  80134c:	5b                   	pop    %ebx
  80134d:	5e                   	pop    %esi
  80134e:	5f                   	pop    %edi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <sfork>:

// Challenge!
int
sfork(void)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801357:	c7 44 24 08 73 2a 80 	movl   $0x802a73,0x8(%esp)
  80135e:	00 
  80135f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801366:	00 
  801367:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  80136e:	e8 d9 ee ff ff       	call   80024c <_panic>
	...

00801374 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	05 00 00 00 30       	add    $0x30000000,%eax
  80137f:	c1 e8 0c             	shr    $0xc,%eax
}
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 df ff ff ff       	call   801374 <fd2num>
  801395:	05 20 00 0d 00       	add    $0xd0020,%eax
  80139a:	c1 e0 0c             	shl    $0xc,%eax
}
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013a6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013ab:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	c1 ea 16             	shr    $0x16,%edx
  8013b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b9:	f6 c2 01             	test   $0x1,%dl
  8013bc:	74 11                	je     8013cf <fd_alloc+0x30>
  8013be:	89 c2                	mov    %eax,%edx
  8013c0:	c1 ea 0c             	shr    $0xc,%edx
  8013c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ca:	f6 c2 01             	test   $0x1,%dl
  8013cd:	75 09                	jne    8013d8 <fd_alloc+0x39>
			*fd_store = fd;
  8013cf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d6:	eb 17                	jmp    8013ef <fd_alloc+0x50>
  8013d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e2:	75 c7                	jne    8013ab <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013ef:	5b                   	pop    %ebx
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013f8:	83 f8 1f             	cmp    $0x1f,%eax
  8013fb:	77 36                	ja     801433 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013fd:	05 00 00 0d 00       	add    $0xd0000,%eax
  801402:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801405:	89 c2                	mov    %eax,%edx
  801407:	c1 ea 16             	shr    $0x16,%edx
  80140a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801411:	f6 c2 01             	test   $0x1,%dl
  801414:	74 24                	je     80143a <fd_lookup+0x48>
  801416:	89 c2                	mov    %eax,%edx
  801418:	c1 ea 0c             	shr    $0xc,%edx
  80141b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801422:	f6 c2 01             	test   $0x1,%dl
  801425:	74 1a                	je     801441 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142a:	89 02                	mov    %eax,(%edx)
	return 0;
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	eb 13                	jmp    801446 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801438:	eb 0c                	jmp    801446 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80143a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143f:	eb 05                	jmp    801446 <fd_lookup+0x54>
  801441:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	53                   	push   %ebx
  80144c:	83 ec 14             	sub    $0x14,%esp
  80144f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	eb 0e                	jmp    80146a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80145c:	39 08                	cmp    %ecx,(%eax)
  80145e:	75 09                	jne    801469 <dev_lookup+0x21>
			*dev = devtab[i];
  801460:	89 03                	mov    %eax,(%ebx)
			return 0;
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	eb 33                	jmp    80149c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801469:	42                   	inc    %edx
  80146a:	8b 04 95 08 2b 80 00 	mov    0x802b08(,%edx,4),%eax
  801471:	85 c0                	test   %eax,%eax
  801473:	75 e7                	jne    80145c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801475:	a1 04 40 80 00       	mov    0x804004,%eax
  80147a:	8b 40 48             	mov    0x48(%eax),%eax
  80147d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801481:	89 44 24 04          	mov    %eax,0x4(%esp)
  801485:	c7 04 24 8c 2a 80 00 	movl   $0x802a8c,(%esp)
  80148c:	e8 b3 ee ff ff       	call   800344 <cprintf>
	*dev = 0;
  801491:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80149c:	83 c4 14             	add    $0x14,%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 30             	sub    $0x30,%esp
  8014aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ad:	8a 45 0c             	mov    0xc(%ebp),%al
  8014b0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b3:	89 34 24             	mov    %esi,(%esp)
  8014b6:	e8 b9 fe ff ff       	call   801374 <fd2num>
  8014bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	e8 28 ff ff ff       	call   8013f2 <fd_lookup>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 05                	js     8014d5 <fd_close+0x33>
	    || fd != fd2)
  8014d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014d3:	74 0d                	je     8014e2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014d5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014d9:	75 46                	jne    801521 <fd_close+0x7f>
  8014db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e0:	eb 3f                	jmp    801521 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e9:	8b 06                	mov    (%esi),%eax
  8014eb:	89 04 24             	mov    %eax,(%esp)
  8014ee:	e8 55 ff ff ff       	call   801448 <dev_lookup>
  8014f3:	89 c3                	mov    %eax,%ebx
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 18                	js     801511 <fd_close+0x6f>
		if (dev->dev_close)
  8014f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fc:	8b 40 10             	mov    0x10(%eax),%eax
  8014ff:	85 c0                	test   %eax,%eax
  801501:	74 09                	je     80150c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801503:	89 34 24             	mov    %esi,(%esp)
  801506:	ff d0                	call   *%eax
  801508:	89 c3                	mov    %eax,%ebx
  80150a:	eb 05                	jmp    801511 <fd_close+0x6f>
		else
			r = 0;
  80150c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801511:	89 74 24 04          	mov    %esi,0x4(%esp)
  801515:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151c:	e8 87 f8 ff ff       	call   800da8 <sys_page_unmap>
	return r;
}
  801521:	89 d8                	mov    %ebx,%eax
  801523:	83 c4 30             	add    $0x30,%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	89 44 24 04          	mov    %eax,0x4(%esp)
  801537:	8b 45 08             	mov    0x8(%ebp),%eax
  80153a:	89 04 24             	mov    %eax,(%esp)
  80153d:	e8 b0 fe ff ff       	call   8013f2 <fd_lookup>
  801542:	85 c0                	test   %eax,%eax
  801544:	78 13                	js     801559 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801546:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80154d:	00 
  80154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801551:	89 04 24             	mov    %eax,(%esp)
  801554:	e8 49 ff ff ff       	call   8014a2 <fd_close>
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <close_all>:

void
close_all(void)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801562:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801567:	89 1c 24             	mov    %ebx,(%esp)
  80156a:	e8 bb ff ff ff       	call   80152a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80156f:	43                   	inc    %ebx
  801570:	83 fb 20             	cmp    $0x20,%ebx
  801573:	75 f2                	jne    801567 <close_all+0xc>
		close(i);
}
  801575:	83 c4 14             	add    $0x14,%esp
  801578:	5b                   	pop    %ebx
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 4c             	sub    $0x4c,%esp
  801584:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801587:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158e:	8b 45 08             	mov    0x8(%ebp),%eax
  801591:	89 04 24             	mov    %eax,(%esp)
  801594:	e8 59 fe ff ff       	call   8013f2 <fd_lookup>
  801599:	89 c3                	mov    %eax,%ebx
  80159b:	85 c0                	test   %eax,%eax
  80159d:	0f 88 e1 00 00 00    	js     801684 <dup+0x109>
		return r;
	close(newfdnum);
  8015a3:	89 3c 24             	mov    %edi,(%esp)
  8015a6:	e8 7f ff ff ff       	call   80152a <close>

	newfd = INDEX2FD(newfdnum);
  8015ab:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015b1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b7:	89 04 24             	mov    %eax,(%esp)
  8015ba:	e8 c5 fd ff ff       	call   801384 <fd2data>
  8015bf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015c1:	89 34 24             	mov    %esi,(%esp)
  8015c4:	e8 bb fd ff ff       	call   801384 <fd2data>
  8015c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	c1 e8 16             	shr    $0x16,%eax
  8015d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015d8:	a8 01                	test   $0x1,%al
  8015da:	74 46                	je     801622 <dup+0xa7>
  8015dc:	89 d8                	mov    %ebx,%eax
  8015de:	c1 e8 0c             	shr    $0xc,%eax
  8015e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015e8:	f6 c2 01             	test   $0x1,%dl
  8015eb:	74 35                	je     801622 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801600:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801604:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80160b:	00 
  80160c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801610:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801617:	e8 39 f7 ff ff       	call   800d55 <sys_page_map>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 3b                	js     80165d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801625:	89 c2                	mov    %eax,%edx
  801627:	c1 ea 0c             	shr    $0xc,%edx
  80162a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801631:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801637:	89 54 24 10          	mov    %edx,0x10(%esp)
  80163b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80163f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801646:	00 
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801652:	e8 fe f6 ff ff       	call   800d55 <sys_page_map>
  801657:	89 c3                	mov    %eax,%ebx
  801659:	85 c0                	test   %eax,%eax
  80165b:	79 25                	jns    801682 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80165d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801661:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801668:	e8 3b f7 ff ff       	call   800da8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801670:	89 44 24 04          	mov    %eax,0x4(%esp)
  801674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167b:	e8 28 f7 ff ff       	call   800da8 <sys_page_unmap>
	return r;
  801680:	eb 02                	jmp    801684 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801682:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801684:	89 d8                	mov    %ebx,%eax
  801686:	83 c4 4c             	add    $0x4c,%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 24             	sub    $0x24,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169f:	89 1c 24             	mov    %ebx,(%esp)
  8016a2:	e8 4b fd ff ff       	call   8013f2 <fd_lookup>
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 6d                	js     801718 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	8b 00                	mov    (%eax),%eax
  8016b7:	89 04 24             	mov    %eax,(%esp)
  8016ba:	e8 89 fd ff ff       	call   801448 <dev_lookup>
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 55                	js     801718 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	8b 50 08             	mov    0x8(%eax),%edx
  8016c9:	83 e2 03             	and    $0x3,%edx
  8016cc:	83 fa 01             	cmp    $0x1,%edx
  8016cf:	75 23                	jne    8016f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d6:	8b 40 48             	mov    0x48(%eax),%eax
  8016d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	c7 04 24 cd 2a 80 00 	movl   $0x802acd,(%esp)
  8016e8:	e8 57 ec ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  8016ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f2:	eb 24                	jmp    801718 <read+0x8a>
	}
	if (!dev->dev_read)
  8016f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f7:	8b 52 08             	mov    0x8(%edx),%edx
  8016fa:	85 d2                	test   %edx,%edx
  8016fc:	74 15                	je     801713 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801701:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801708:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80170c:	89 04 24             	mov    %eax,(%esp)
  80170f:	ff d2                	call   *%edx
  801711:	eb 05                	jmp    801718 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801713:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801718:	83 c4 24             	add    $0x24,%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 1c             	sub    $0x1c,%esp
  801727:	8b 7d 08             	mov    0x8(%ebp),%edi
  80172a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801732:	eb 23                	jmp    801757 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801734:	89 f0                	mov    %esi,%eax
  801736:	29 d8                	sub    %ebx,%eax
  801738:	89 44 24 08          	mov    %eax,0x8(%esp)
  80173c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173f:	01 d8                	add    %ebx,%eax
  801741:	89 44 24 04          	mov    %eax,0x4(%esp)
  801745:	89 3c 24             	mov    %edi,(%esp)
  801748:	e8 41 ff ff ff       	call   80168e <read>
		if (m < 0)
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 10                	js     801761 <readn+0x43>
			return m;
		if (m == 0)
  801751:	85 c0                	test   %eax,%eax
  801753:	74 0a                	je     80175f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801755:	01 c3                	add    %eax,%ebx
  801757:	39 f3                	cmp    %esi,%ebx
  801759:	72 d9                	jb     801734 <readn+0x16>
  80175b:	89 d8                	mov    %ebx,%eax
  80175d:	eb 02                	jmp    801761 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80175f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801761:	83 c4 1c             	add    $0x1c,%esp
  801764:	5b                   	pop    %ebx
  801765:	5e                   	pop    %esi
  801766:	5f                   	pop    %edi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	53                   	push   %ebx
  80176d:	83 ec 24             	sub    $0x24,%esp
  801770:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801773:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177a:	89 1c 24             	mov    %ebx,(%esp)
  80177d:	e8 70 fc ff ff       	call   8013f2 <fd_lookup>
  801782:	85 c0                	test   %eax,%eax
  801784:	78 68                	js     8017ee <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801786:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801790:	8b 00                	mov    (%eax),%eax
  801792:	89 04 24             	mov    %eax,(%esp)
  801795:	e8 ae fc ff ff       	call   801448 <dev_lookup>
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 50                	js     8017ee <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a5:	75 23                	jne    8017ca <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ac:	8b 40 48             	mov    0x48(%eax),%eax
  8017af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b7:	c7 04 24 e9 2a 80 00 	movl   $0x802ae9,(%esp)
  8017be:	e8 81 eb ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  8017c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c8:	eb 24                	jmp    8017ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d0:	85 d2                	test   %edx,%edx
  8017d2:	74 15                	je     8017e9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	ff d2                	call   *%edx
  8017e7:	eb 05                	jmp    8017ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017ee:	83 c4 24             	add    $0x24,%esp
  8017f1:	5b                   	pop    %ebx
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 e6 fb ff ff       	call   8013f2 <fd_lookup>
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 0e                	js     80181e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801810:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801813:	8b 55 0c             	mov    0xc(%ebp),%edx
  801816:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 24             	sub    $0x24,%esp
  801827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	89 1c 24             	mov    %ebx,(%esp)
  801834:	e8 b9 fb ff ff       	call   8013f2 <fd_lookup>
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 61                	js     80189e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801840:	89 44 24 04          	mov    %eax,0x4(%esp)
  801844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801847:	8b 00                	mov    (%eax),%eax
  801849:	89 04 24             	mov    %eax,(%esp)
  80184c:	e8 f7 fb ff ff       	call   801448 <dev_lookup>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 49                	js     80189e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801858:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185c:	75 23                	jne    801881 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80185e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801863:	8b 40 48             	mov    0x48(%eax),%eax
  801866:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186e:	c7 04 24 ac 2a 80 00 	movl   $0x802aac,(%esp)
  801875:	e8 ca ea ff ff       	call   800344 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80187a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187f:	eb 1d                	jmp    80189e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801881:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801884:	8b 52 18             	mov    0x18(%edx),%edx
  801887:	85 d2                	test   %edx,%edx
  801889:	74 0e                	je     801899 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	ff d2                	call   *%edx
  801897:	eb 05                	jmp    80189e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801899:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80189e:	83 c4 24             	add    $0x24,%esp
  8018a1:	5b                   	pop    %ebx
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 24             	sub    $0x24,%esp
  8018ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	89 04 24             	mov    %eax,(%esp)
  8018bb:	e8 32 fb ff ff       	call   8013f2 <fd_lookup>
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 52                	js     801916 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ce:	8b 00                	mov    (%eax),%eax
  8018d0:	89 04 24             	mov    %eax,(%esp)
  8018d3:	e8 70 fb ff ff       	call   801448 <dev_lookup>
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 3a                	js     801916 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e3:	74 2c                	je     801911 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ef:	00 00 00 
	stat->st_isdir = 0;
  8018f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f9:	00 00 00 
	stat->st_dev = dev;
  8018fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801902:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801906:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801909:	89 14 24             	mov    %edx,(%esp)
  80190c:	ff 50 14             	call   *0x14(%eax)
  80190f:	eb 05                	jmp    801916 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801911:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801916:	83 c4 24             	add    $0x24,%esp
  801919:	5b                   	pop    %ebx
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801924:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192b:	00 
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 fe 01 00 00       	call   801b35 <open>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 1b                	js     801958 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80193d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801940:	89 44 24 04          	mov    %eax,0x4(%esp)
  801944:	89 1c 24             	mov    %ebx,(%esp)
  801947:	e8 58 ff ff ff       	call   8018a4 <fstat>
  80194c:	89 c6                	mov    %eax,%esi
	close(fd);
  80194e:	89 1c 24             	mov    %ebx,(%esp)
  801951:	e8 d4 fb ff ff       	call   80152a <close>
	return r;
  801956:	89 f3                	mov    %esi,%ebx
}
  801958:	89 d8                	mov    %ebx,%eax
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    
  801961:	00 00                	add    %al,(%eax)
	...

00801964 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	56                   	push   %esi
  801968:	53                   	push   %ebx
  801969:	83 ec 10             	sub    $0x10,%esp
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801970:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801977:	75 11                	jne    80198a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801979:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801980:	e8 fc 08 00 00       	call   802281 <ipc_find_env>
  801985:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801991:	00 
  801992:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801999:	00 
  80199a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199e:	a1 00 40 80 00       	mov    0x804000,%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 6c 08 00 00       	call   802217 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019b2:	00 
  8019b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019be:	e8 ed 07 00 00       	call   8021b0 <ipc_recv>
}
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ed:	e8 72 ff ff ff       	call   801964 <fsipc>
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801a00:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a05:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a0f:	e8 50 ff ff ff       	call   801964 <fsipc>
}
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	53                   	push   %ebx
  801a1a:	83 ec 14             	sub    $0x14,%esp
  801a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	8b 40 0c             	mov    0xc(%eax),%eax
  801a26:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	b8 05 00 00 00       	mov    $0x5,%eax
  801a35:	e8 2a ff ff ff       	call   801964 <fsipc>
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 2b                	js     801a69 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a3e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a45:	00 
  801a46:	89 1c 24             	mov    %ebx,(%esp)
  801a49:	e8 c1 ee ff ff       	call   80090f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a4e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a53:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a59:	a1 84 50 80 00       	mov    0x805084,%eax
  801a5e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a69:	83 c4 14             	add    $0x14,%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a75:	c7 44 24 08 18 2b 80 	movl   $0x802b18,0x8(%esp)
  801a7c:	00 
  801a7d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a84:	00 
  801a85:	c7 04 24 36 2b 80 00 	movl   $0x802b36,(%esp)
  801a8c:	e8 bb e7 ff ff       	call   80024c <_panic>

00801a91 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 10             	sub    $0x10,%esp
  801a99:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aa7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab7:	e8 a8 fe ff ff       	call   801964 <fsipc>
  801abc:	89 c3                	mov    %eax,%ebx
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 6a                	js     801b2c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ac2:	39 c6                	cmp    %eax,%esi
  801ac4:	73 24                	jae    801aea <devfile_read+0x59>
  801ac6:	c7 44 24 0c 41 2b 80 	movl   $0x802b41,0xc(%esp)
  801acd:	00 
  801ace:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  801ad5:	00 
  801ad6:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801add:	00 
  801ade:	c7 04 24 36 2b 80 00 	movl   $0x802b36,(%esp)
  801ae5:	e8 62 e7 ff ff       	call   80024c <_panic>
	assert(r <= PGSIZE);
  801aea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aef:	7e 24                	jle    801b15 <devfile_read+0x84>
  801af1:	c7 44 24 0c 5d 2b 80 	movl   $0x802b5d,0xc(%esp)
  801af8:	00 
  801af9:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  801b00:	00 
  801b01:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b08:	00 
  801b09:	c7 04 24 36 2b 80 00 	movl   $0x802b36,(%esp)
  801b10:	e8 37 e7 ff ff       	call   80024c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b19:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b20:	00 
  801b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b24:	89 04 24             	mov    %eax,(%esp)
  801b27:	e8 5c ef ff ff       	call   800a88 <memmove>
	return r;
}
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	83 ec 20             	sub    $0x20,%esp
  801b3d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b40:	89 34 24             	mov    %esi,(%esp)
  801b43:	e8 94 ed ff ff       	call   8008dc <strlen>
  801b48:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b4d:	7f 60                	jg     801baf <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 45 f8 ff ff       	call   80139f <fd_alloc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 54                	js     801bb4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b60:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b64:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b6b:	e8 9f ed ff ff       	call   80090f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b73:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b7b:	b8 01 00 00 00       	mov    $0x1,%eax
  801b80:	e8 df fd ff ff       	call   801964 <fsipc>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	85 c0                	test   %eax,%eax
  801b89:	79 15                	jns    801ba0 <open+0x6b>
		fd_close(fd, 0);
  801b8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b92:	00 
  801b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b96:	89 04 24             	mov    %eax,(%esp)
  801b99:	e8 04 f9 ff ff       	call   8014a2 <fd_close>
		return r;
  801b9e:	eb 14                	jmp    801bb4 <open+0x7f>
	}

	return fd2num(fd);
  801ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba3:	89 04 24             	mov    %eax,(%esp)
  801ba6:	e8 c9 f7 ff ff       	call   801374 <fd2num>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	eb 05                	jmp    801bb4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801baf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	83 c4 20             	add    $0x20,%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc8:	b8 08 00 00 00       	mov    $0x8,%eax
  801bcd:	e8 92 fd ff ff       	call   801964 <fsipc>
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 10             	sub    $0x10,%esp
  801bdc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	89 04 24             	mov    %eax,(%esp)
  801be5:	e8 9a f7 ff ff       	call   801384 <fd2data>
  801bea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bec:	c7 44 24 04 69 2b 80 	movl   $0x802b69,0x4(%esp)
  801bf3:	00 
  801bf4:	89 34 24             	mov    %esi,(%esp)
  801bf7:	e8 13 ed ff ff       	call   80090f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bfc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bff:	2b 03                	sub    (%ebx),%eax
  801c01:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c07:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c0e:	00 00 00 
	stat->st_dev = &devpipe;
  801c11:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c18:	30 80 00 
	return 0;
}
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	53                   	push   %ebx
  801c2b:	83 ec 14             	sub    $0x14,%esp
  801c2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c3c:	e8 67 f1 ff ff       	call   800da8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c41:	89 1c 24             	mov    %ebx,(%esp)
  801c44:	e8 3b f7 ff ff       	call   801384 <fd2data>
  801c49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c54:	e8 4f f1 ff ff       	call   800da8 <sys_page_unmap>
}
  801c59:	83 c4 14             	add    $0x14,%esp
  801c5c:	5b                   	pop    %ebx
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	57                   	push   %edi
  801c63:	56                   	push   %esi
  801c64:	53                   	push   %ebx
  801c65:	83 ec 2c             	sub    $0x2c,%esp
  801c68:	89 c7                	mov    %eax,%edi
  801c6a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c72:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c75:	89 3c 24             	mov    %edi,(%esp)
  801c78:	e8 4b 06 00 00       	call   8022c8 <pageref>
  801c7d:	89 c6                	mov    %eax,%esi
  801c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c82:	89 04 24             	mov    %eax,(%esp)
  801c85:	e8 3e 06 00 00       	call   8022c8 <pageref>
  801c8a:	39 c6                	cmp    %eax,%esi
  801c8c:	0f 94 c0             	sete   %al
  801c8f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c92:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9b:	39 cb                	cmp    %ecx,%ebx
  801c9d:	75 08                	jne    801ca7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c9f:	83 c4 2c             	add    $0x2c,%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ca7:	83 f8 01             	cmp    $0x1,%eax
  801caa:	75 c1                	jne    801c6d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cac:	8b 42 58             	mov    0x58(%edx),%eax
  801caf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cb6:	00 
  801cb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cbf:	c7 04 24 70 2b 80 00 	movl   $0x802b70,(%esp)
  801cc6:	e8 79 e6 ff ff       	call   800344 <cprintf>
  801ccb:	eb a0                	jmp    801c6d <_pipeisclosed+0xe>

00801ccd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	57                   	push   %edi
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	83 ec 1c             	sub    $0x1c,%esp
  801cd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cd9:	89 34 24             	mov    %esi,(%esp)
  801cdc:	e8 a3 f6 ff ff       	call   801384 <fd2data>
  801ce1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce8:	eb 3c                	jmp    801d26 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cea:	89 da                	mov    %ebx,%edx
  801cec:	89 f0                	mov    %esi,%eax
  801cee:	e8 6c ff ff ff       	call   801c5f <_pipeisclosed>
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	75 38                	jne    801d2f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cf7:	e8 e6 ef ff ff       	call   800ce2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cfc:	8b 43 04             	mov    0x4(%ebx),%eax
  801cff:	8b 13                	mov    (%ebx),%edx
  801d01:	83 c2 20             	add    $0x20,%edx
  801d04:	39 d0                	cmp    %edx,%eax
  801d06:	73 e2                	jae    801cea <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d16:	79 05                	jns    801d1d <devpipe_write+0x50>
  801d18:	4a                   	dec    %edx
  801d19:	83 ca e0             	or     $0xffffffe0,%edx
  801d1c:	42                   	inc    %edx
  801d1d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d21:	40                   	inc    %eax
  801d22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d25:	47                   	inc    %edi
  801d26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d29:	75 d1                	jne    801cfc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d2b:	89 f8                	mov    %edi,%eax
  801d2d:	eb 05                	jmp    801d34 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	83 ec 1c             	sub    $0x1c,%esp
  801d45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d48:	89 3c 24             	mov    %edi,(%esp)
  801d4b:	e8 34 f6 ff ff       	call   801384 <fd2data>
  801d50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d52:	be 00 00 00 00       	mov    $0x0,%esi
  801d57:	eb 3a                	jmp    801d93 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d59:	85 f6                	test   %esi,%esi
  801d5b:	74 04                	je     801d61 <devpipe_read+0x25>
				return i;
  801d5d:	89 f0                	mov    %esi,%eax
  801d5f:	eb 40                	jmp    801da1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d61:	89 da                	mov    %ebx,%edx
  801d63:	89 f8                	mov    %edi,%eax
  801d65:	e8 f5 fe ff ff       	call   801c5f <_pipeisclosed>
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	75 2e                	jne    801d9c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d6e:	e8 6f ef ff ff       	call   800ce2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d73:	8b 03                	mov    (%ebx),%eax
  801d75:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d78:	74 df                	je     801d59 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d7a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d7f:	79 05                	jns    801d86 <devpipe_read+0x4a>
  801d81:	48                   	dec    %eax
  801d82:	83 c8 e0             	or     $0xffffffe0,%eax
  801d85:	40                   	inc    %eax
  801d86:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d90:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d92:	46                   	inc    %esi
  801d93:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d96:	75 db                	jne    801d73 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d98:	89 f0                	mov    %esi,%eax
  801d9a:	eb 05                	jmp    801da1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da1:	83 c4 1c             	add    $0x1c,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	57                   	push   %edi
  801dad:	56                   	push   %esi
  801dae:	53                   	push   %ebx
  801daf:	83 ec 3c             	sub    $0x3c,%esp
  801db2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db8:	89 04 24             	mov    %eax,(%esp)
  801dbb:	e8 df f5 ff ff       	call   80139f <fd_alloc>
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	0f 88 45 01 00 00    	js     801f0f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd1:	00 
  801dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de0:	e8 1c ef ff ff       	call   800d01 <sys_page_alloc>
  801de5:	89 c3                	mov    %eax,%ebx
  801de7:	85 c0                	test   %eax,%eax
  801de9:	0f 88 20 01 00 00    	js     801f0f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801def:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801df2:	89 04 24             	mov    %eax,(%esp)
  801df5:	e8 a5 f5 ff ff       	call   80139f <fd_alloc>
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	0f 88 f8 00 00 00    	js     801efc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e04:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e0b:	00 
  801e0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1a:	e8 e2 ee ff ff       	call   800d01 <sys_page_alloc>
  801e1f:	89 c3                	mov    %eax,%ebx
  801e21:	85 c0                	test   %eax,%eax
  801e23:	0f 88 d3 00 00 00    	js     801efc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 50 f5 ff ff       	call   801384 <fd2data>
  801e34:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e3d:	00 
  801e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e49:	e8 b3 ee ff ff       	call   800d01 <sys_page_alloc>
  801e4e:	89 c3                	mov    %eax,%ebx
  801e50:	85 c0                	test   %eax,%eax
  801e52:	0f 88 91 00 00 00    	js     801ee9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 21 f5 ff ff       	call   801384 <fd2data>
  801e63:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e6a:	00 
  801e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e76:	00 
  801e77:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e82:	e8 ce ee ff ff       	call   800d55 <sys_page_map>
  801e87:	89 c3                	mov    %eax,%ebx
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	78 4c                	js     801ed9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e8d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e96:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ea2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ea8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ead:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eba:	89 04 24             	mov    %eax,(%esp)
  801ebd:	e8 b2 f4 ff ff       	call   801374 <fd2num>
  801ec2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec7:	89 04 24             	mov    %eax,(%esp)
  801eca:	e8 a5 f4 ff ff       	call   801374 <fd2num>
  801ecf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed7:	eb 36                	jmp    801f0f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801ed9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801edd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee4:	e8 bf ee ff ff       	call   800da8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ee9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef7:	e8 ac ee ff ff       	call   800da8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0a:	e8 99 ee ff ff       	call   800da8 <sys_page_unmap>
    err:
	return r;
}
  801f0f:	89 d8                	mov    %ebx,%eax
  801f11:	83 c4 3c             	add    $0x3c,%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5f                   	pop    %edi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f26:	8b 45 08             	mov    0x8(%ebp),%eax
  801f29:	89 04 24             	mov    %eax,(%esp)
  801f2c:	e8 c1 f4 ff ff       	call   8013f2 <fd_lookup>
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 15                	js     801f4a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f38:	89 04 24             	mov    %eax,(%esp)
  801f3b:	e8 44 f4 ff ff       	call   801384 <fd2data>
	return _pipeisclosed(fd, p);
  801f40:	89 c2                	mov    %eax,%edx
  801f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f45:	e8 15 fd ff ff       	call   801c5f <_pipeisclosed>
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f5c:	c7 44 24 04 88 2b 80 	movl   $0x802b88,0x4(%esp)
  801f63:	00 
  801f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f67:	89 04 24             	mov    %eax,(%esp)
  801f6a:	e8 a0 e9 ff ff       	call   80090f <strcpy>
	return 0;
}
  801f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	57                   	push   %edi
  801f7a:	56                   	push   %esi
  801f7b:	53                   	push   %ebx
  801f7c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f82:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f87:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8d:	eb 30                	jmp    801fbf <devcons_write+0x49>
		m = n - tot;
  801f8f:	8b 75 10             	mov    0x10(%ebp),%esi
  801f92:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f94:	83 fe 7f             	cmp    $0x7f,%esi
  801f97:	76 05                	jbe    801f9e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f99:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f9e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fa2:	03 45 0c             	add    0xc(%ebp),%eax
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	89 3c 24             	mov    %edi,(%esp)
  801fac:	e8 d7 ea ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  801fb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb5:	89 3c 24             	mov    %edi,(%esp)
  801fb8:	e8 77 ec ff ff       	call   800c34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fbd:	01 f3                	add    %esi,%ebx
  801fbf:	89 d8                	mov    %ebx,%eax
  801fc1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fc4:	72 c9                	jb     801f8f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fc6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5f                   	pop    %edi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fdb:	75 07                	jne    801fe4 <devcons_read+0x13>
  801fdd:	eb 25                	jmp    802004 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fdf:	e8 fe ec ff ff       	call   800ce2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fe4:	e8 69 ec ff ff       	call   800c52 <sys_cgetc>
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	74 f2                	je     801fdf <devcons_read+0xe>
  801fed:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 1d                	js     802010 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ff3:	83 f8 04             	cmp    $0x4,%eax
  801ff6:	74 13                	je     80200b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffb:	88 10                	mov    %dl,(%eax)
	return 1;
  801ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  802002:	eb 0c                	jmp    802010 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802004:	b8 00 00 00 00       	mov    $0x0,%eax
  802009:	eb 05                	jmp    802010 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802018:	8b 45 08             	mov    0x8(%ebp),%eax
  80201b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80201e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802025:	00 
  802026:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802029:	89 04 24             	mov    %eax,(%esp)
  80202c:	e8 03 ec ff ff       	call   800c34 <sys_cputs>
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <getchar>:

int
getchar(void)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802039:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802040:	00 
  802041:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802044:	89 44 24 04          	mov    %eax,0x4(%esp)
  802048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204f:	e8 3a f6 ff ff       	call   80168e <read>
	if (r < 0)
  802054:	85 c0                	test   %eax,%eax
  802056:	78 0f                	js     802067 <getchar+0x34>
		return r;
	if (r < 1)
  802058:	85 c0                	test   %eax,%eax
  80205a:	7e 06                	jle    802062 <getchar+0x2f>
		return -E_EOF;
	return c;
  80205c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802060:	eb 05                	jmp    802067 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802062:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802072:	89 44 24 04          	mov    %eax,0x4(%esp)
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	89 04 24             	mov    %eax,(%esp)
  80207c:	e8 71 f3 ff ff       	call   8013f2 <fd_lookup>
  802081:	85 c0                	test   %eax,%eax
  802083:	78 11                	js     802096 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802085:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802088:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208e:	39 10                	cmp    %edx,(%eax)
  802090:	0f 94 c0             	sete   %al
  802093:	0f b6 c0             	movzbl %al,%eax
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <opencons>:

int
opencons(void)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80209e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a1:	89 04 24             	mov    %eax,(%esp)
  8020a4:	e8 f6 f2 ff ff       	call   80139f <fd_alloc>
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 3c                	js     8020e9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ad:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020b4:	00 
  8020b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c3:	e8 39 ec ff ff       	call   800d01 <sys_page_alloc>
  8020c8:	85 c0                	test   %eax,%eax
  8020ca:	78 1d                	js     8020e9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e1:	89 04 24             	mov    %eax,(%esp)
  8020e4:	e8 8b f2 ff ff       	call   801374 <fd2num>
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    
	...

008020ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020f2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020f9:	0f 85 80 00 00 00    	jne    80217f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8020ff:	a1 04 40 80 00       	mov    0x804004,%eax
  802104:	8b 40 48             	mov    0x48(%eax),%eax
  802107:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80210e:	00 
  80210f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802116:	ee 
  802117:	89 04 24             	mov    %eax,(%esp)
  80211a:	e8 e2 eb ff ff       	call   800d01 <sys_page_alloc>
  80211f:	85 c0                	test   %eax,%eax
  802121:	79 20                	jns    802143 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  802123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802127:	c7 44 24 08 94 2b 80 	movl   $0x802b94,0x8(%esp)
  80212e:	00 
  80212f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802136:	00 
  802137:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  80213e:	e8 09 e1 ff ff       	call   80024c <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  802143:	a1 04 40 80 00       	mov    0x804004,%eax
  802148:	8b 40 48             	mov    0x48(%eax),%eax
  80214b:	c7 44 24 04 8c 21 80 	movl   $0x80218c,0x4(%esp)
  802152:	00 
  802153:	89 04 24             	mov    %eax,(%esp)
  802156:	e8 46 ed ff ff       	call   800ea1 <sys_env_set_pgfault_upcall>
  80215b:	85 c0                	test   %eax,%eax
  80215d:	79 20                	jns    80217f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80215f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802163:	c7 44 24 08 c0 2b 80 	movl   $0x802bc0,0x8(%esp)
  80216a:	00 
  80216b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  802172:	00 
  802173:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  80217a:	e8 cd e0 ff ff       	call   80024c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80217f:	8b 45 08             	mov    0x8(%ebp),%eax
  802182:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802187:	c9                   	leave  
  802188:	c3                   	ret    
  802189:	00 00                	add    %al,(%eax)
	...

0080218c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80218c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80218d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802192:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802194:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802197:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80219b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80219d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8021a0:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8021a1:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8021a4:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8021a6:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8021a9:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8021aa:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8021ad:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8021ae:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8021af:	c3                   	ret    

008021b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	56                   	push   %esi
  8021b4:	53                   	push   %ebx
  8021b5:	83 ec 10             	sub    $0x10,%esp
  8021b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	75 05                	jne    8021ca <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8021c5:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8021ca:	89 04 24             	mov    %eax,(%esp)
  8021cd:	e8 45 ed ff ff       	call   800f17 <sys_ipc_recv>
	if (!err) {
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	75 26                	jne    8021fc <ipc_recv+0x4c>
		if (from_env_store) {
  8021d6:	85 f6                	test   %esi,%esi
  8021d8:	74 0a                	je     8021e4 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8021da:	a1 04 40 80 00       	mov    0x804004,%eax
  8021df:	8b 40 74             	mov    0x74(%eax),%eax
  8021e2:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8021e4:	85 db                	test   %ebx,%ebx
  8021e6:	74 0a                	je     8021f2 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8021e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8021ed:	8b 40 78             	mov    0x78(%eax),%eax
  8021f0:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8021f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8021f7:	8b 40 70             	mov    0x70(%eax),%eax
  8021fa:	eb 14                	jmp    802210 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8021fc:	85 f6                	test   %esi,%esi
  8021fe:	74 06                	je     802206 <ipc_recv+0x56>
		*from_env_store = 0;
  802200:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  802206:	85 db                	test   %ebx,%ebx
  802208:	74 06                	je     802210 <ipc_recv+0x60>
		*perm_store = 0;
  80220a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	57                   	push   %edi
  80221b:	56                   	push   %esi
  80221c:	53                   	push   %ebx
  80221d:	83 ec 1c             	sub    $0x1c,%esp
  802220:	8b 75 10             	mov    0x10(%ebp),%esi
  802223:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802226:	85 f6                	test   %esi,%esi
  802228:	75 05                	jne    80222f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  80222a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80222f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802233:	89 74 24 08          	mov    %esi,0x8(%esp)
  802237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223e:	8b 45 08             	mov    0x8(%ebp),%eax
  802241:	89 04 24             	mov    %eax,(%esp)
  802244:	e8 ab ec ff ff       	call   800ef4 <sys_ipc_try_send>
  802249:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80224b:	e8 92 ea ff ff       	call   800ce2 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802250:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802253:	74 da                	je     80222f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802255:	85 db                	test   %ebx,%ebx
  802257:	74 20                	je     802279 <ipc_send+0x62>
		panic("send fail: %e", err);
  802259:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80225d:	c7 44 24 08 fe 2b 80 	movl   $0x802bfe,0x8(%esp)
  802264:	00 
  802265:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80226c:	00 
  80226d:	c7 04 24 0c 2c 80 00 	movl   $0x802c0c,(%esp)
  802274:	e8 d3 df ff ff       	call   80024c <_panic>
	}
	return;
}
  802279:	83 c4 1c             	add    $0x1c,%esp
  80227c:	5b                   	pop    %ebx
  80227d:	5e                   	pop    %esi
  80227e:	5f                   	pop    %edi
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    

00802281 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	53                   	push   %ebx
  802285:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802288:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802294:	89 c2                	mov    %eax,%edx
  802296:	c1 e2 07             	shl    $0x7,%edx
  802299:	29 ca                	sub    %ecx,%edx
  80229b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022a1:	8b 52 50             	mov    0x50(%edx),%edx
  8022a4:	39 da                	cmp    %ebx,%edx
  8022a6:	75 0f                	jne    8022b7 <ipc_find_env+0x36>
			return envs[i].env_id;
  8022a8:	c1 e0 07             	shl    $0x7,%eax
  8022ab:	29 c8                	sub    %ecx,%eax
  8022ad:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022b2:	8b 40 40             	mov    0x40(%eax),%eax
  8022b5:	eb 0c                	jmp    8022c3 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022b7:	40                   	inc    %eax
  8022b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022bd:	75 ce                	jne    80228d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022bf:	66 b8 00 00          	mov    $0x0,%ax
}
  8022c3:	5b                   	pop    %ebx
  8022c4:	5d                   	pop    %ebp
  8022c5:	c3                   	ret    
	...

008022c8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ce:	89 c2                	mov    %eax,%edx
  8022d0:	c1 ea 16             	shr    $0x16,%edx
  8022d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022da:	f6 c2 01             	test   $0x1,%dl
  8022dd:	74 1e                	je     8022fd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022df:	c1 e8 0c             	shr    $0xc,%eax
  8022e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022e9:	a8 01                	test   $0x1,%al
  8022eb:	74 17                	je     802304 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022ed:	c1 e8 0c             	shr    $0xc,%eax
  8022f0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022f7:	ef 
  8022f8:	0f b7 c0             	movzwl %ax,%eax
  8022fb:	eb 0c                	jmp    802309 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802302:	eb 05                	jmp    802309 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802304:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    
	...

0080230c <__udivdi3>:
  80230c:	55                   	push   %ebp
  80230d:	57                   	push   %edi
  80230e:	56                   	push   %esi
  80230f:	83 ec 10             	sub    $0x10,%esp
  802312:	8b 74 24 20          	mov    0x20(%esp),%esi
  802316:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80231a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802322:	89 cd                	mov    %ecx,%ebp
  802324:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802328:	85 c0                	test   %eax,%eax
  80232a:	75 2c                	jne    802358 <__udivdi3+0x4c>
  80232c:	39 f9                	cmp    %edi,%ecx
  80232e:	77 68                	ja     802398 <__udivdi3+0x8c>
  802330:	85 c9                	test   %ecx,%ecx
  802332:	75 0b                	jne    80233f <__udivdi3+0x33>
  802334:	b8 01 00 00 00       	mov    $0x1,%eax
  802339:	31 d2                	xor    %edx,%edx
  80233b:	f7 f1                	div    %ecx
  80233d:	89 c1                	mov    %eax,%ecx
  80233f:	31 d2                	xor    %edx,%edx
  802341:	89 f8                	mov    %edi,%eax
  802343:	f7 f1                	div    %ecx
  802345:	89 c7                	mov    %eax,%edi
  802347:	89 f0                	mov    %esi,%eax
  802349:	f7 f1                	div    %ecx
  80234b:	89 c6                	mov    %eax,%esi
  80234d:	89 f0                	mov    %esi,%eax
  80234f:	89 fa                	mov    %edi,%edx
  802351:	83 c4 10             	add    $0x10,%esp
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	39 f8                	cmp    %edi,%eax
  80235a:	77 2c                	ja     802388 <__udivdi3+0x7c>
  80235c:	0f bd f0             	bsr    %eax,%esi
  80235f:	83 f6 1f             	xor    $0x1f,%esi
  802362:	75 4c                	jne    8023b0 <__udivdi3+0xa4>
  802364:	39 f8                	cmp    %edi,%eax
  802366:	bf 00 00 00 00       	mov    $0x0,%edi
  80236b:	72 0a                	jb     802377 <__udivdi3+0x6b>
  80236d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802371:	0f 87 ad 00 00 00    	ja     802424 <__udivdi3+0x118>
  802377:	be 01 00 00 00       	mov    $0x1,%esi
  80237c:	89 f0                	mov    %esi,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 10             	add    $0x10,%esp
  802383:	5e                   	pop    %esi
  802384:	5f                   	pop    %edi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    
  802387:	90                   	nop
  802388:	31 ff                	xor    %edi,%edi
  80238a:	31 f6                	xor    %esi,%esi
  80238c:	89 f0                	mov    %esi,%eax
  80238e:	89 fa                	mov    %edi,%edx
  802390:	83 c4 10             	add    $0x10,%esp
  802393:	5e                   	pop    %esi
  802394:	5f                   	pop    %edi
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    
  802397:	90                   	nop
  802398:	89 fa                	mov    %edi,%edx
  80239a:	89 f0                	mov    %esi,%eax
  80239c:	f7 f1                	div    %ecx
  80239e:	89 c6                	mov    %eax,%esi
  8023a0:	31 ff                	xor    %edi,%edi
  8023a2:	89 f0                	mov    %esi,%eax
  8023a4:	89 fa                	mov    %edi,%edx
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	89 f1                	mov    %esi,%ecx
  8023b2:	d3 e0                	shl    %cl,%eax
  8023b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023b8:	b8 20 00 00 00       	mov    $0x20,%eax
  8023bd:	29 f0                	sub    %esi,%eax
  8023bf:	89 ea                	mov    %ebp,%edx
  8023c1:	88 c1                	mov    %al,%cl
  8023c3:	d3 ea                	shr    %cl,%edx
  8023c5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023c9:	09 ca                	or     %ecx,%edx
  8023cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023cf:	89 f1                	mov    %esi,%ecx
  8023d1:	d3 e5                	shl    %cl,%ebp
  8023d3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8023d7:	89 fd                	mov    %edi,%ebp
  8023d9:	88 c1                	mov    %al,%cl
  8023db:	d3 ed                	shr    %cl,%ebp
  8023dd:	89 fa                	mov    %edi,%edx
  8023df:	89 f1                	mov    %esi,%ecx
  8023e1:	d3 e2                	shl    %cl,%edx
  8023e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023e7:	88 c1                	mov    %al,%cl
  8023e9:	d3 ef                	shr    %cl,%edi
  8023eb:	09 d7                	or     %edx,%edi
  8023ed:	89 f8                	mov    %edi,%eax
  8023ef:	89 ea                	mov    %ebp,%edx
  8023f1:	f7 74 24 08          	divl   0x8(%esp)
  8023f5:	89 d1                	mov    %edx,%ecx
  8023f7:	89 c7                	mov    %eax,%edi
  8023f9:	f7 64 24 0c          	mull   0xc(%esp)
  8023fd:	39 d1                	cmp    %edx,%ecx
  8023ff:	72 17                	jb     802418 <__udivdi3+0x10c>
  802401:	74 09                	je     80240c <__udivdi3+0x100>
  802403:	89 fe                	mov    %edi,%esi
  802405:	31 ff                	xor    %edi,%edi
  802407:	e9 41 ff ff ff       	jmp    80234d <__udivdi3+0x41>
  80240c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802410:	89 f1                	mov    %esi,%ecx
  802412:	d3 e2                	shl    %cl,%edx
  802414:	39 c2                	cmp    %eax,%edx
  802416:	73 eb                	jae    802403 <__udivdi3+0xf7>
  802418:	8d 77 ff             	lea    -0x1(%edi),%esi
  80241b:	31 ff                	xor    %edi,%edi
  80241d:	e9 2b ff ff ff       	jmp    80234d <__udivdi3+0x41>
  802422:	66 90                	xchg   %ax,%ax
  802424:	31 f6                	xor    %esi,%esi
  802426:	e9 22 ff ff ff       	jmp    80234d <__udivdi3+0x41>
	...

0080242c <__umoddi3>:
  80242c:	55                   	push   %ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	83 ec 20             	sub    $0x20,%esp
  802432:	8b 44 24 30          	mov    0x30(%esp),%eax
  802436:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80243a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80243e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802442:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802446:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80244a:	89 c7                	mov    %eax,%edi
  80244c:	89 f2                	mov    %esi,%edx
  80244e:	85 ed                	test   %ebp,%ebp
  802450:	75 16                	jne    802468 <__umoddi3+0x3c>
  802452:	39 f1                	cmp    %esi,%ecx
  802454:	0f 86 a6 00 00 00    	jbe    802500 <__umoddi3+0xd4>
  80245a:	f7 f1                	div    %ecx
  80245c:	89 d0                	mov    %edx,%eax
  80245e:	31 d2                	xor    %edx,%edx
  802460:	83 c4 20             	add    $0x20,%esp
  802463:	5e                   	pop    %esi
  802464:	5f                   	pop    %edi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    
  802467:	90                   	nop
  802468:	39 f5                	cmp    %esi,%ebp
  80246a:	0f 87 ac 00 00 00    	ja     80251c <__umoddi3+0xf0>
  802470:	0f bd c5             	bsr    %ebp,%eax
  802473:	83 f0 1f             	xor    $0x1f,%eax
  802476:	89 44 24 10          	mov    %eax,0x10(%esp)
  80247a:	0f 84 a8 00 00 00    	je     802528 <__umoddi3+0xfc>
  802480:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802484:	d3 e5                	shl    %cl,%ebp
  802486:	bf 20 00 00 00       	mov    $0x20,%edi
  80248b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80248f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802493:	89 f9                	mov    %edi,%ecx
  802495:	d3 e8                	shr    %cl,%eax
  802497:	09 e8                	or     %ebp,%eax
  802499:	89 44 24 18          	mov    %eax,0x18(%esp)
  80249d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024a1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024a5:	d3 e0                	shl    %cl,%eax
  8024a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ab:	89 f2                	mov    %esi,%edx
  8024ad:	d3 e2                	shl    %cl,%edx
  8024af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8024b9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024bd:	89 f9                	mov    %edi,%ecx
  8024bf:	d3 e8                	shr    %cl,%eax
  8024c1:	09 d0                	or     %edx,%eax
  8024c3:	d3 ee                	shr    %cl,%esi
  8024c5:	89 f2                	mov    %esi,%edx
  8024c7:	f7 74 24 18          	divl   0x18(%esp)
  8024cb:	89 d6                	mov    %edx,%esi
  8024cd:	f7 64 24 0c          	mull   0xc(%esp)
  8024d1:	89 c5                	mov    %eax,%ebp
  8024d3:	89 d1                	mov    %edx,%ecx
  8024d5:	39 d6                	cmp    %edx,%esi
  8024d7:	72 67                	jb     802540 <__umoddi3+0x114>
  8024d9:	74 75                	je     802550 <__umoddi3+0x124>
  8024db:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024df:	29 e8                	sub    %ebp,%eax
  8024e1:	19 ce                	sbb    %ecx,%esi
  8024e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024e7:	d3 e8                	shr    %cl,%eax
  8024e9:	89 f2                	mov    %esi,%edx
  8024eb:	89 f9                	mov    %edi,%ecx
  8024ed:	d3 e2                	shl    %cl,%edx
  8024ef:	09 d0                	or     %edx,%eax
  8024f1:	89 f2                	mov    %esi,%edx
  8024f3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024f7:	d3 ea                	shr    %cl,%edx
  8024f9:	83 c4 20             	add    $0x20,%esp
  8024fc:	5e                   	pop    %esi
  8024fd:	5f                   	pop    %edi
  8024fe:	5d                   	pop    %ebp
  8024ff:	c3                   	ret    
  802500:	85 c9                	test   %ecx,%ecx
  802502:	75 0b                	jne    80250f <__umoddi3+0xe3>
  802504:	b8 01 00 00 00       	mov    $0x1,%eax
  802509:	31 d2                	xor    %edx,%edx
  80250b:	f7 f1                	div    %ecx
  80250d:	89 c1                	mov    %eax,%ecx
  80250f:	89 f0                	mov    %esi,%eax
  802511:	31 d2                	xor    %edx,%edx
  802513:	f7 f1                	div    %ecx
  802515:	89 f8                	mov    %edi,%eax
  802517:	e9 3e ff ff ff       	jmp    80245a <__umoddi3+0x2e>
  80251c:	89 f2                	mov    %esi,%edx
  80251e:	83 c4 20             	add    $0x20,%esp
  802521:	5e                   	pop    %esi
  802522:	5f                   	pop    %edi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    
  802525:	8d 76 00             	lea    0x0(%esi),%esi
  802528:	39 f5                	cmp    %esi,%ebp
  80252a:	72 04                	jb     802530 <__umoddi3+0x104>
  80252c:	39 f9                	cmp    %edi,%ecx
  80252e:	77 06                	ja     802536 <__umoddi3+0x10a>
  802530:	89 f2                	mov    %esi,%edx
  802532:	29 cf                	sub    %ecx,%edi
  802534:	19 ea                	sbb    %ebp,%edx
  802536:	89 f8                	mov    %edi,%eax
  802538:	83 c4 20             	add    $0x20,%esp
  80253b:	5e                   	pop    %esi
  80253c:	5f                   	pop    %edi
  80253d:	5d                   	pop    %ebp
  80253e:	c3                   	ret    
  80253f:	90                   	nop
  802540:	89 d1                	mov    %edx,%ecx
  802542:	89 c5                	mov    %eax,%ebp
  802544:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802548:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80254c:	eb 8d                	jmp    8024db <__umoddi3+0xaf>
  80254e:	66 90                	xchg   %ax,%ax
  802550:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802554:	72 ea                	jb     802540 <__umoddi3+0x114>
  802556:	89 f1                	mov    %esi,%ecx
  802558:	eb 81                	jmp    8024db <__umoddi3+0xaf>
