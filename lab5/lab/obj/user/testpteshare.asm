
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80004a:	e8 a0 08 00 00       	call   8008ef <strcpy>
	exit();
  80004f:	e8 bc 01 00 00       	call   800210 <exit>
}
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	53                   	push   %ebx
  80005a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800061:	74 05                	je     800068 <umain+0x12>
		childofspawn();
  800063:	e8 cc ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800068:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800077:	a0 
  800078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007f:	e8 5d 0c 00 00       	call   800ce1 <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 8c 2b 80 	movl   $0x802b8c,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 9f 2b 80 00 	movl   $0x802b9f,(%esp)
  8000a3:	e8 84 01 00 00       	call   80022c <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 ae 0f 00 00       	call   80105b <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 2e 30 80 	movl   $0x80302e,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 9f 2b 80 00 	movl   $0x802b9f,(%esp)
  8000ce:	e8 59 01 00 00       	call   80022c <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 03 08 00 00       	call   8008ef <strcpy>
		exit();
  8000ec:	e8 1f 01 00 00       	call   800210 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 ff 23 00 00       	call   8024f8 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 88 08 00 00       	call   800996 <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	75 07                	jne    800119 <umain+0xc3>
  800112:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  800117:	eb 05                	jmp    80011e <umain+0xc8>
  800119:	b8 86 2b 80 00       	mov    $0x802b86,%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 b3 2b 80 00 	movl   $0x802bb3,(%esp)
  800129:	e8 f6 01 00 00       	call   800324 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800135:	00 
  800136:	c7 44 24 08 ce 2b 80 	movl   $0x802bce,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 d3 2b 80 	movl   $0x802bd3,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 d2 2b 80 00 	movl   $0x802bd2,(%esp)
  80014d:	e8 be 1f 00 00       	call   802110 <spawnl>
  800152:	85 c0                	test   %eax,%eax
  800154:	79 20                	jns    800176 <umain+0x120>
		panic("spawn: %e", r);
  800156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015a:	c7 44 24 08 e0 2b 80 	movl   $0x802be0,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 9f 2b 80 00 	movl   $0x802b9f,(%esp)
  800171:	e8 b6 00 00 00       	call   80022c <_panic>
	wait(r);
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 7a 23 00 00       	call   8024f8 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017e:	a1 00 40 80 00       	mov    0x804000,%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018e:	e8 03 08 00 00       	call   800996 <strcmp>
  800193:	85 c0                	test   %eax,%eax
  800195:	75 07                	jne    80019e <umain+0x148>
  800197:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  80019c:	eb 05                	jmp    8001a3 <umain+0x14d>
  80019e:	b8 86 2b 80 00       	mov    $0x802b86,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 ea 2b 80 00 	movl   $0x802bea,(%esp)
  8001ae:	e8 71 01 00 00       	call   800324 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001b3:	cc                   	int3   

	breakpoint();
}
  8001b4:	83 c4 14             	add    $0x14,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 10             	sub    $0x10,%esp
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001ca:	e8 d4 0a 00 00       	call   800ca3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001db:	c1 e0 07             	shl    $0x7,%eax
  8001de:	29 d0                	sub    %edx,%eax
  8001e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e5:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ea:	85 f6                	test   %esi,%esi
  8001ec:	7e 07                	jle    8001f5 <libmain+0x39>
		binaryname = argv[0];
  8001ee:	8b 03                	mov    (%ebx),%eax
  8001f0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f9:	89 34 24             	mov    %esi,(%esp)
  8001fc:	e8 55 fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  800201:	e8 0a 00 00 00       	call   800210 <exit>
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
  80020d:	00 00                	add    %al,(%eax)
	...

00800210 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800216:	e8 20 13 00 00       	call   80153b <close_all>
	sys_env_destroy(0);
  80021b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800222:	e8 2a 0a 00 00       	call   800c51 <sys_env_destroy>
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    
  800229:	00 00                	add    %al,(%eax)
	...

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800234:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800237:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80023d:	e8 61 0a 00 00       	call   800ca3 <sys_getenvid>
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 54 24 10          	mov    %edx,0x10(%esp)
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800250:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	c7 04 24 30 2c 80 00 	movl   $0x802c30,(%esp)
  80025f:	e8 c0 00 00 00       	call   800324 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800264:	89 74 24 04          	mov    %esi,0x4(%esp)
  800268:	8b 45 10             	mov    0x10(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 50 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  800273:	c7 04 24 f2 31 80 00 	movl   $0x8031f2,(%esp)
  80027a:	e8 a5 00 00 00       	call   800324 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027f:	cc                   	int3   
  800280:	eb fd                	jmp    80027f <_panic+0x53>
	...

00800284 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	83 ec 14             	sub    $0x14,%esp
  80028b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028e:	8b 03                	mov    (%ebx),%eax
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800297:	40                   	inc    %eax
  800298:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029f:	75 19                	jne    8002ba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a8:	00 
  8002a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 60 09 00 00       	call   800c14 <sys_cputs>
		b->idx = 0;
  8002b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002ba:	ff 43 04             	incl   0x4(%ebx)
}
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  8002ff:	e8 82 01 00 00       	call   800486 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800304:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 f8 08 00 00       	call   800c14 <sys_cputs>

	return b.cnt;
}
  80031c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 87 ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    
	...

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d7                	mov    %edx,%edi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800360:	85 c0                	test   %eax,%eax
  800362:	75 08                	jne    80036c <printnum+0x2c>
  800364:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800367:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036a:	77 57                	ja     8003c3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800370:	4b                   	dec    %ebx
  800371:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800380:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800384:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038b:	00 
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	e8 86 25 00 00       	call   802924 <__udivdi3>
  80039e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ad:	89 fa                	mov    %edi,%edx
  8003af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b2:	e8 89 ff ff ff       	call   800340 <printnum>
  8003b7:	eb 0f                	jmp    8003c8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bd:	89 34 24             	mov    %esi,(%esp)
  8003c0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c3:	4b                   	dec    %ebx
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	7f f1                	jg     8003b9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003de:	00 
  8003df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e2:	89 04 24             	mov    %eax,(%esp)
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ec:	e8 53 26 00 00       	call   802a44 <__umoddi3>
  8003f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f5:	0f be 80 53 2c 80 00 	movsbl 0x802c53(%eax),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800402:	83 c4 3c             	add    $0x3c,%esp
  800405:	5b                   	pop    %ebx
  800406:	5e                   	pop    %esi
  800407:	5f                   	pop    %edi
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80040d:	83 fa 01             	cmp    $0x1,%edx
  800410:	7e 0e                	jle    800420 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800412:	8b 10                	mov    (%eax),%edx
  800414:	8d 4a 08             	lea    0x8(%edx),%ecx
  800417:	89 08                	mov    %ecx,(%eax)
  800419:	8b 02                	mov    (%edx),%eax
  80041b:	8b 52 04             	mov    0x4(%edx),%edx
  80041e:	eb 22                	jmp    800442 <getuint+0x38>
	else if (lflag)
  800420:	85 d2                	test   %edx,%edx
  800422:	74 10                	je     800434 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800424:	8b 10                	mov    (%eax),%edx
  800426:	8d 4a 04             	lea    0x4(%edx),%ecx
  800429:	89 08                	mov    %ecx,(%eax)
  80042b:	8b 02                	mov    (%edx),%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	eb 0e                	jmp    800442 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 04             	lea    0x4(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80044d:	8b 10                	mov    (%eax),%edx
  80044f:	3b 50 04             	cmp    0x4(%eax),%edx
  800452:	73 08                	jae    80045c <sprintputch+0x18>
		*b->buf++ = ch;
  800454:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800457:	88 0a                	mov    %cl,(%edx)
  800459:	42                   	inc    %edx
  80045a:	89 10                	mov    %edx,(%eax)
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800464:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046b:	8b 45 10             	mov    0x10(%ebp),%eax
  80046e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	89 44 24 04          	mov    %eax,0x4(%esp)
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 02 00 00 00       	call   800486 <vprintfmt>
	va_end(ap);
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	57                   	push   %edi
  80048a:	56                   	push   %esi
  80048b:	53                   	push   %ebx
  80048c:	83 ec 4c             	sub    $0x4c,%esp
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800492:	8b 75 10             	mov    0x10(%ebp),%esi
  800495:	eb 12                	jmp    8004a9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 84 8b 03 00 00    	je     80082a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a9:	0f b6 06             	movzbl (%esi),%eax
  8004ac:	46                   	inc    %esi
  8004ad:	83 f8 25             	cmp    $0x25,%eax
  8004b0:	75 e5                	jne    800497 <vprintfmt+0x11>
  8004b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ce:	eb 26                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004d7:	eb 1d                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004dc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e0:	eb 14                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004ec:	eb 08                	jmp    8004f6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	0f b6 06             	movzbl (%esi),%eax
  8004f9:	8d 56 01             	lea    0x1(%esi),%edx
  8004fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ff:	8a 16                	mov    (%esi),%dl
  800501:	83 ea 23             	sub    $0x23,%edx
  800504:	80 fa 55             	cmp    $0x55,%dl
  800507:	0f 87 01 03 00 00    	ja     80080e <vprintfmt+0x388>
  80050d:	0f b6 d2             	movzbl %dl,%edx
  800510:	ff 24 95 a0 2d 80 00 	jmp    *0x802da0(,%edx,4)
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800522:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800526:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800529:	8d 50 d0             	lea    -0x30(%eax),%edx
  80052c:	83 fa 09             	cmp    $0x9,%edx
  80052f:	77 2a                	ja     80055b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800531:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800532:	eb eb                	jmp    80051f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800542:	eb 17                	jmp    80055b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	78 98                	js     8004e2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054d:	eb a7                	jmp    8004f6 <vprintfmt+0x70>
  80054f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800552:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800559:	eb 9b                	jmp    8004f6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055f:	79 95                	jns    8004f6 <vprintfmt+0x70>
  800561:	eb 8b                	jmp    8004ee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800563:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800567:	eb 8d                	jmp    8004f6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800581:	e9 23 ff ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	79 02                	jns    800597 <vprintfmt+0x111>
  800595:	f7 d8                	neg    %eax
  800597:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800599:	83 f8 0f             	cmp    $0xf,%eax
  80059c:	7f 0b                	jg     8005a9 <vprintfmt+0x123>
  80059e:	8b 04 85 00 2f 80 00 	mov    0x802f00(,%eax,4),%eax
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	75 23                	jne    8005cc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ad:	c7 44 24 08 6b 2c 80 	movl   $0x802c6b,0x8(%esp)
  8005b4:	00 
  8005b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	e8 9a fe ff ff       	call   80045e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c7:	e9 dd fe ff ff       	jmp    8004a9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d0:	c7 44 24 08 46 31 80 	movl   $0x803146,0x8(%esp)
  8005d7:	00 
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005df:	89 14 24             	mov    %edx,(%esp)
  8005e2:	e8 77 fe ff ff       	call   80045e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ea:	e9 ba fe ff ff       	jmp    8004a9 <vprintfmt+0x23>
  8005ef:	89 f9                	mov    %edi,%ecx
  8005f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 30                	mov    (%eax),%esi
  800602:	85 f6                	test   %esi,%esi
  800604:	75 05                	jne    80060b <vprintfmt+0x185>
				p = "(null)";
  800606:	be 64 2c 80 00       	mov    $0x802c64,%esi
			if (width > 0 && padc != '-')
  80060b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060f:	0f 8e 84 00 00 00    	jle    800699 <vprintfmt+0x213>
  800615:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800619:	74 7e                	je     800699 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	e8 ab 02 00 00       	call   8008d2 <strnlen>
  800627:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062a:	29 c2                	sub    %eax,%edx
  80062c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80062f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800633:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800636:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800639:	89 de                	mov    %ebx,%esi
  80063b:	89 d3                	mov    %edx,%ebx
  80063d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	eb 0b                	jmp    80064c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800641:	89 74 24 04          	mov    %esi,0x4(%esp)
  800645:	89 3c 24             	mov    %edi,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f f1                	jg     800641 <vprintfmt+0x1bb>
  800650:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800653:	89 f3                	mov    %esi,%ebx
  800655:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065b:	85 c0                	test   %eax,%eax
  80065d:	79 05                	jns    800664 <vprintfmt+0x1de>
  80065f:	b8 00 00 00 00       	mov    $0x0,%eax
  800664:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800667:	29 c2                	sub    %eax,%edx
  800669:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80066c:	eb 2b                	jmp    800699 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800672:	74 18                	je     80068c <vprintfmt+0x206>
  800674:	8d 50 e0             	lea    -0x20(%eax),%edx
  800677:	83 fa 5e             	cmp    $0x5e,%edx
  80067a:	76 10                	jbe    80068c <vprintfmt+0x206>
					putch('?', putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
  80068a:	eb 0a                	jmp    800696 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800696:	ff 4d e4             	decl   -0x1c(%ebp)
  800699:	0f be 06             	movsbl (%esi),%eax
  80069c:	46                   	inc    %esi
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 21                	je     8006c2 <vprintfmt+0x23c>
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	78 c9                	js     80066e <vprintfmt+0x1e8>
  8006a5:	4f                   	dec    %edi
  8006a6:	79 c6                	jns    80066e <vprintfmt+0x1e8>
  8006a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ab:	89 de                	mov    %ebx,%esi
  8006ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b0:	eb 18                	jmp    8006ca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	4b                   	dec    %ebx
  8006c0:	eb 08                	jmp    8006ca <vprintfmt+0x244>
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ca:	85 db                	test   %ebx,%ebx
  8006cc:	7f e4                	jg     8006b2 <vprintfmt+0x22c>
  8006ce:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d6:	e9 ce fd ff ff       	jmp    8004a9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 f9 01             	cmp    $0x1,%ecx
  8006de:	7e 10                	jle    8006f0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 08             	lea    0x8(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 30                	mov    (%eax),%esi
  8006eb:	8b 78 04             	mov    0x4(%eax),%edi
  8006ee:	eb 26                	jmp    800716 <vprintfmt+0x290>
	else if (lflag)
  8006f0:	85 c9                	test   %ecx,%ecx
  8006f2:	74 12                	je     800706 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 30                	mov    (%eax),%esi
  8006ff:	89 f7                	mov    %esi,%edi
  800701:	c1 ff 1f             	sar    $0x1f,%edi
  800704:	eb 10                	jmp    800716 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 30                	mov    (%eax),%esi
  800711:	89 f7                	mov    %esi,%edi
  800713:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800716:	85 ff                	test   %edi,%edi
  800718:	78 0a                	js     800724 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071f:	e9 ac 00 00 00       	jmp    8007d0 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800732:	f7 de                	neg    %esi
  800734:	83 d7 00             	adc    $0x0,%edi
  800737:	f7 df                	neg    %edi
			}
			base = 10;
  800739:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073e:	e9 8d 00 00 00       	jmp    8007d0 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800743:	89 ca                	mov    %ecx,%edx
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
  800748:	e8 bd fc ff ff       	call   80040a <getuint>
  80074d:	89 c6                	mov    %eax,%esi
  80074f:	89 d7                	mov    %edx,%edi
			base = 10;
  800751:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800756:	eb 78                	jmp    8007d0 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800758:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800763:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800771:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800785:	e9 1f fd ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80078a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007af:	8b 30                	mov    (%eax),%esi
  8007b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007bb:	eb 13                	jmp    8007d0 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bd:	89 ca                	mov    %ecx,%edx
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 43 fc ff ff       	call   80040a <getuint>
  8007c7:	89 c6                	mov    %eax,%esi
  8007c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8007cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	89 34 24             	mov    %esi,(%esp)
  8007e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ea:	89 da                	mov    %ebx,%edx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	e8 4c fb ff ff       	call   800340 <printnum>
			break;
  8007f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007f7:	e9 ad fc ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800809:	e9 9b fc ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800812:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800819:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081c:	eb 01                	jmp    80081f <vprintfmt+0x399>
  80081e:	4e                   	dec    %esi
  80081f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800823:	75 f9                	jne    80081e <vprintfmt+0x398>
  800825:	e9 7f fc ff ff       	jmp    8004a9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80082a:	83 c4 4c             	add    $0x4c,%esp
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 28             	sub    $0x28,%esp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800841:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800845:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800848:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084f:	85 c0                	test   %eax,%eax
  800851:	74 30                	je     800883 <vsnprintf+0x51>
  800853:	85 d2                	test   %edx,%edx
  800855:	7e 33                	jle    80088a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
  800861:	89 44 24 08          	mov    %eax,0x8(%esp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	c7 04 24 44 04 80 00 	movl   $0x800444,(%esp)
  800873:	e8 0e fc ff ff       	call   800486 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	eb 0c                	jmp    80088f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800888:	eb 05                	jmp    80088f <vsnprintf+0x5d>
  80088a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 7b ff ff ff       	call   800832 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    
  8008b9:	00 00                	add    %al,(%eax)
	...

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 01                	jmp    8008ca <strlen+0xe>
		n++;
  8008c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ce:	75 f9                	jne    8008c9 <strlen+0xd>
		n++;
	return n;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	eb 01                	jmp    8008e3 <strnlen+0x11>
		n++;
  8008e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	74 06                	je     8008ed <strnlen+0x1b>
  8008e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008eb:	75 f5                	jne    8008e2 <strnlen+0x10>
		n++;
	return n;
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800901:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800904:	42                   	inc    %edx
  800905:	84 c9                	test   %cl,%cl
  800907:	75 f5                	jne    8008fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800916:	89 1c 24             	mov    %ebx,(%esp)
  800919:	e8 9e ff ff ff       	call   8008bc <strlen>
	strcpy(dst + len, src);
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 54 24 04          	mov    %edx,0x4(%esp)
  800925:	01 d8                	add    %ebx,%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 c0 ff ff ff       	call   8008ef <strcpy>
	return dst;
}
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	83 c4 08             	add    $0x8,%esp
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800945:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094a:	eb 0c                	jmp    800958 <strncpy+0x21>
		*dst++ = *src;
  80094c:	8a 1a                	mov    (%edx),%bl
  80094e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800951:	80 3a 01             	cmpb   $0x1,(%edx)
  800954:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800957:	41                   	inc    %ecx
  800958:	39 f1                	cmp    %esi,%ecx
  80095a:	75 f0                	jne    80094c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 75 08             	mov    0x8(%ebp),%esi
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096e:	85 d2                	test   %edx,%edx
  800970:	75 0a                	jne    80097c <strlcpy+0x1c>
  800972:	89 f0                	mov    %esi,%eax
  800974:	eb 1a                	jmp    800990 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800976:	88 18                	mov    %bl,(%eax)
  800978:	40                   	inc    %eax
  800979:	41                   	inc    %ecx
  80097a:	eb 02                	jmp    80097e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80097e:	4a                   	dec    %edx
  80097f:	74 0a                	je     80098b <strlcpy+0x2b>
  800981:	8a 19                	mov    (%ecx),%bl
  800983:	84 db                	test   %bl,%bl
  800985:	75 ef                	jne    800976 <strlcpy+0x16>
  800987:	89 c2                	mov    %eax,%edx
  800989:	eb 02                	jmp    80098d <strlcpy+0x2d>
  80098b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80098d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 02                	jmp    8009a3 <strcmp+0xd>
		p++, q++;
  8009a1:	41                   	inc    %ecx
  8009a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a3:	8a 01                	mov    (%ecx),%al
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 04                	je     8009ad <strcmp+0x17>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	74 f4                	je     8009a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 c0             	movzbl %al,%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009c4:	eb 03                	jmp    8009c9 <strncmp+0x12>
		n--, p++, q++;
  8009c6:	4a                   	dec    %edx
  8009c7:	40                   	inc    %eax
  8009c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 14                	je     8009e1 <strncmp+0x2a>
  8009cd:	8a 18                	mov    (%eax),%bl
  8009cf:	84 db                	test   %bl,%bl
  8009d1:	74 04                	je     8009d7 <strncmp+0x20>
  8009d3:	3a 19                	cmp    (%ecx),%bl
  8009d5:	74 ef                	je     8009c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 11             	movzbl (%ecx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
  8009df:	eb 05                	jmp    8009e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f2:	eb 05                	jmp    8009f9 <strchr+0x10>
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 0c                	je     800a04 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f8:	40                   	inc    %eax
  8009f9:	8a 10                	mov    (%eax),%dl
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f5                	jne    8009f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a0f:	eb 05                	jmp    800a16 <strfind+0x10>
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 07                	je     800a1c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a15:	40                   	inc    %eax
  800a16:	8a 10                	mov    (%eax),%dl
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	75 f5                	jne    800a11 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2d:	85 c9                	test   %ecx,%ecx
  800a2f:	74 30                	je     800a61 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a37:	75 25                	jne    800a5e <memset+0x40>
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 20                	jne    800a5e <memset+0x40>
		c &= 0xFF;
  800a3e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a41:	89 d3                	mov    %edx,%ebx
  800a43:	c1 e3 08             	shl    $0x8,%ebx
  800a46:	89 d6                	mov    %edx,%esi
  800a48:	c1 e6 18             	shl    $0x18,%esi
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	c1 e0 10             	shl    $0x10,%eax
  800a50:	09 f0                	or     %esi,%eax
  800a52:	09 d0                	or     %edx,%eax
  800a54:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a56:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a59:	fc                   	cld    
  800a5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5c:	eb 03                	jmp    800a61 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5e:	fc                   	cld    
  800a5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a61:	89 f8                	mov    %edi,%eax
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a76:	39 c6                	cmp    %eax,%esi
  800a78:	73 34                	jae    800aae <memmove+0x46>
  800a7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7d:	39 d0                	cmp    %edx,%eax
  800a7f:	73 2d                	jae    800aae <memmove+0x46>
		s += n;
		d += n;
  800a81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f6 c2 03             	test   $0x3,%dl
  800a87:	75 1b                	jne    800aa4 <memmove+0x3c>
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 13                	jne    800aa4 <memmove+0x3c>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 0e                	jne    800aa4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a96:	83 ef 04             	sub    $0x4,%edi
  800a99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb 07                	jmp    800aab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa4:	4f                   	dec    %edi
  800aa5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa8:	fd                   	std    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aab:	fc                   	cld    
  800aac:	eb 20                	jmp    800ace <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab4:	75 13                	jne    800ac9 <memmove+0x61>
  800ab6:	a8 03                	test   $0x3,%al
  800ab8:	75 0f                	jne    800ac9 <memmove+0x61>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	75 0a                	jne    800ac9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	fc                   	cld    
  800ac5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac7:	eb 05                	jmp    800ace <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	fc                   	cld    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  800adb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	89 04 24             	mov    %eax,(%esp)
  800aec:	e8 77 ff ff ff       	call   800a68 <memmove>
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	eb 16                	jmp    800b1f <memcmp+0x2c>
		if (*s1 != *s2)
  800b09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b0c:	42                   	inc    %edx
  800b0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b11:	38 c8                	cmp    %cl,%al
  800b13:	74 0a                	je     800b1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 c9             	movzbl %cl,%ecx
  800b1b:	29 c8                	sub    %ecx,%eax
  800b1d:	eb 09                	jmp    800b28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	39 da                	cmp    %ebx,%edx
  800b21:	75 e6                	jne    800b09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3b:	eb 05                	jmp    800b42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3d:	38 08                	cmp    %cl,(%eax)
  800b3f:	74 05                	je     800b46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b41:	40                   	inc    %eax
  800b42:	39 d0                	cmp    %edx,%eax
  800b44:	72 f7                	jb     800b3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b54:	eb 01                	jmp    800b57 <strtol+0xf>
		s++;
  800b56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	8a 02                	mov    (%edx),%al
  800b59:	3c 20                	cmp    $0x20,%al
  800b5b:	74 f9                	je     800b56 <strtol+0xe>
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	74 f5                	je     800b56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b61:	3c 2b                	cmp    $0x2b,%al
  800b63:	75 08                	jne    800b6d <strtol+0x25>
		s++;
  800b65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b66:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6b:	eb 13                	jmp    800b80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b6d:	3c 2d                	cmp    $0x2d,%al
  800b6f:	75 0a                	jne    800b7b <strtol+0x33>
		s++, neg = 1;
  800b71:	8d 52 01             	lea    0x1(%edx),%edx
  800b74:	bf 01 00 00 00       	mov    $0x1,%edi
  800b79:	eb 05                	jmp    800b80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	74 05                	je     800b89 <strtol+0x41>
  800b84:	83 fb 10             	cmp    $0x10,%ebx
  800b87:	75 28                	jne    800bb1 <strtol+0x69>
  800b89:	8a 02                	mov    (%edx),%al
  800b8b:	3c 30                	cmp    $0x30,%al
  800b8d:	75 10                	jne    800b9f <strtol+0x57>
  800b8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b93:	75 0a                	jne    800b9f <strtol+0x57>
		s += 2, base = 16;
  800b95:	83 c2 02             	add    $0x2,%edx
  800b98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9d:	eb 12                	jmp    800bb1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 0e                	jne    800bb1 <strtol+0x69>
  800ba3:	3c 30                	cmp    $0x30,%al
  800ba5:	75 05                	jne    800bac <strtol+0x64>
		s++, base = 8;
  800ba7:	42                   	inc    %edx
  800ba8:	b3 08                	mov    $0x8,%bl
  800baa:	eb 05                	jmp    800bb1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb8:	8a 0a                	mov    (%edx),%cl
  800bba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bbd:	80 fb 09             	cmp    $0x9,%bl
  800bc0:	77 08                	ja     800bca <strtol+0x82>
			dig = *s - '0';
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 30             	sub    $0x30,%ecx
  800bc8:	eb 1e                	jmp    800be8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 08                	ja     800bda <strtol+0x92>
			dig = *s - 'a' + 10;
  800bd2:	0f be c9             	movsbl %cl,%ecx
  800bd5:	83 e9 57             	sub    $0x57,%ecx
  800bd8:	eb 0e                	jmp    800be8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bdd:	80 fb 19             	cmp    $0x19,%bl
  800be0:	77 12                	ja     800bf4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800be2:	0f be c9             	movsbl %cl,%ecx
  800be5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be8:	39 f1                	cmp    %esi,%ecx
  800bea:	7d 0c                	jge    800bf8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bec:	42                   	inc    %edx
  800bed:	0f af c6             	imul   %esi,%eax
  800bf0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bf2:	eb c4                	jmp    800bb8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bf4:	89 c1                	mov    %eax,%ecx
  800bf6:	eb 02                	jmp    800bfa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfe:	74 05                	je     800c05 <strtol+0xbd>
		*endptr = (char *) s;
  800c00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c05:	85 ff                	test   %edi,%edi
  800c07:	74 04                	je     800c0d <strtol+0xc5>
  800c09:	89 c8                	mov    %ecx,%eax
  800c0b:	f7 d8                	neg    %eax
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
	...

00800c14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 c3                	mov    %eax,%ebx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	89 c6                	mov    %eax,%esi
  800c2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c42:	89 d1                	mov    %edx,%ecx
  800c44:	89 d3                	mov    %edx,%ebx
  800c46:	89 d7                	mov    %edx,%edi
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 cb                	mov    %ecx,%ebx
  800c69:	89 cf                	mov    %ecx,%edi
  800c6b:	89 ce                	mov    %ecx,%esi
  800c6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 28                	jle    800c9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800c86:	00 
  800c87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8e:	00 
  800c8f:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800c96:	e8 91 f5 ff ff       	call   80022c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9b:	83 c4 2c             	add    $0x2c,%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_yield>:

void
sys_yield(void)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 f7                	mov    %esi,%edi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 28                	jle    800d2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d10:	00 
  800d11:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800d18:	00 
  800d19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d20:	00 
  800d21:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800d28:	e8 ff f4 ff ff       	call   80022c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2d:	83 c4 2c             	add    $0x2c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d43:	8b 75 18             	mov    0x18(%ebp),%esi
  800d46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 28                	jle    800d80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d63:	00 
  800d64:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d73:	00 
  800d74:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800d7b:	e8 ac f4 ff ff       	call   80022c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d80:	83 c4 2c             	add    $0x2c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 28                	jle    800dd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800db6:	00 
  800db7:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800dce:	e8 59 f4 ff ff       	call   80022c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd3:	83 c4 2c             	add    $0x2c,%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	89 de                	mov    %ebx,%esi
  800df8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800e21:	e8 06 f4 ff ff       	call   80022c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e26:	83 c4 2c             	add    $0x2c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800e74:	e8 b3 f3 ff ff       	call   80022c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e79:	83 c4 2c             	add    $0x2c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 28                	jle    800ecc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800ec7:	e8 60 f3 ff ff       	call   80022c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ecc:	83 c4 2c             	add    $0x2c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eda:	be 00 00 00 00       	mov    $0x0,%esi
  800edf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	89 cb                	mov    %ecx,%ebx
  800f0f:	89 cf                	mov    %ecx,%edi
  800f11:	89 ce                	mov    %ecx,%esi
  800f13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 28                	jle    800f41 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  800f3c:	e8 eb f2 ff ff       	call   80022c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f41:	83 c4 2c             	add    $0x2c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	00 00                	add    %al,(%eax)
	...

00800f4c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 24             	sub    $0x24,%esp
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f56:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800f58:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5c:	75 20                	jne    800f7e <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f5e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f62:	c7 44 24 08 8c 2f 80 	movl   $0x802f8c,0x8(%esp)
  800f69:	00 
  800f6a:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800f71:	00 
  800f72:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  800f79:	e8 ae f2 ff ff       	call   80022c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f7e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f84:	89 d8                	mov    %ebx,%eax
  800f86:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f90:	f6 c4 08             	test   $0x8,%ah
  800f93:	75 1c                	jne    800fb1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f95:	c7 44 24 08 bc 2f 80 	movl   $0x802fbc,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  800fac:	e8 7b f2 ff ff       	call   80022c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800fb1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc8:	e8 14 fd ff ff       	call   800ce1 <sys_page_alloc>
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 20                	jns    800ff1 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800fd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd5:	c7 44 24 08 8c 2b 80 	movl   $0x802b8c,0x8(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800fe4:	00 
  800fe5:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  800fec:	e8 3b f2 ff ff       	call   80022c <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800ff1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ff8:	00 
  800ff9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ffd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801004:	e8 5f fa ff ff       	call   800a68 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  801009:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801010:	00 
  801011:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801015:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80101c:	00 
  80101d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801024:	00 
  801025:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102c:	e8 04 fd ff ff       	call   800d35 <sys_page_map>
  801031:	85 c0                	test   %eax,%eax
  801033:	79 20                	jns    801055 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  801035:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801039:	c7 44 24 08 16 30 80 	movl   $0x803016,0x8(%esp)
  801040:	00 
  801041:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  801050:	e8 d7 f1 ff ff       	call   80022c <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  801055:	83 c4 24             	add    $0x24,%esp
  801058:	5b                   	pop    %ebx
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  801064:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  80106b:	e8 94 16 00 00       	call   802704 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801070:	ba 07 00 00 00       	mov    $0x7,%edx
  801075:	89 d0                	mov    %edx,%eax
  801077:	cd 30                	int    $0x30
  801079:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80107c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 20                	jns    8010a3 <fork+0x48>
		panic("sys_exofork: %e", envid);
  801083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801087:	c7 44 24 08 27 30 80 	movl   $0x803027,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  80109e:	e8 89 f1 ff ff       	call   80022c <_panic>
	}
	
	// Child process
	if (envid == 0) {
  8010a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010a7:	75 25                	jne    8010ce <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010a9:	e8 f5 fb ff ff       	call   800ca3 <sys_getenvid>
  8010ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010ba:	c1 e0 07             	shl    $0x7,%eax
  8010bd:	29 d0                	sub    %edx,%eax
  8010bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c4:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  8010c9:	e9 58 02 00 00       	jmp    801326 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  8010ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d3:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010d8:	89 f0                	mov    %esi,%eax
  8010da:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010dd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e4:	a8 01                	test   $0x1,%al
  8010e6:	0f 84 7a 01 00 00    	je     801266 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8010ec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010f3:	a8 01                	test   $0x1,%al
  8010f5:	0f 84 6b 01 00 00    	je     801266 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8010fb:	a1 04 50 80 00       	mov    0x805004,%eax
  801100:	8b 40 48             	mov    0x48(%eax),%eax
  801103:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801106:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110d:	f6 c4 04             	test   $0x4,%ah
  801110:	74 52                	je     801164 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801112:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801119:	25 07 0e 00 00       	and    $0xe07,%eax
  80111e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801122:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801126:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801134:	89 04 24             	mov    %eax,(%esp)
  801137:	e8 f9 fb ff ff       	call   800d35 <sys_page_map>
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 89 22 01 00 00    	jns    801266 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801144:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801148:	c7 44 24 08 37 30 80 	movl   $0x803037,0x8(%esp)
  80114f:	00 
  801150:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801157:	00 
  801158:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  80115f:	e8 c8 f0 ff ff       	call   80022c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801164:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116b:	f6 c4 08             	test   $0x8,%ah
  80116e:	75 0f                	jne    80117f <fork+0x124>
  801170:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801177:	a8 02                	test   $0x2,%al
  801179:	0f 84 99 00 00 00    	je     801218 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80117f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801186:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801189:	83 f8 01             	cmp    $0x1,%eax
  80118c:	19 db                	sbb    %ebx,%ebx
  80118e:	83 e3 fc             	and    $0xfffffffc,%ebx
  801191:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801197:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80119b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80119f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ad:	89 04 24             	mov    %eax,(%esp)
  8011b0:	e8 80 fb ff ff       	call   800d35 <sys_page_map>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	79 20                	jns    8011d9 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8011b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bd:	c7 44 24 08 37 30 80 	movl   $0x803037,0x8(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  8011d4:	e8 53 f0 ff ff       	call   80022c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011d9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ec:	89 04 24             	mov    %eax,(%esp)
  8011ef:	e8 41 fb ff ff       	call   800d35 <sys_page_map>
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	79 6e                	jns    801266 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fc:	c7 44 24 08 37 30 80 	movl   $0x803037,0x8(%esp)
  801203:	00 
  801204:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80120b:	00 
  80120c:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  801213:	e8 14 f0 ff ff       	call   80022c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801218:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80121f:	25 07 0e 00 00       	and    $0xe07,%eax
  801224:	89 44 24 10          	mov    %eax,0x10(%esp)
  801228:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80122f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801233:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123a:	89 04 24             	mov    %eax,(%esp)
  80123d:	e8 f3 fa ff ff       	call   800d35 <sys_page_map>
  801242:	85 c0                	test   %eax,%eax
  801244:	79 20                	jns    801266 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801246:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124a:	c7 44 24 08 37 30 80 	movl   $0x803037,0x8(%esp)
  801251:	00 
  801252:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801259:	00 
  80125a:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  801261:	e8 c6 ef ff ff       	call   80022c <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801266:	46                   	inc    %esi
  801267:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80126d:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801273:	0f 85 5f fe ff ff    	jne    8010d8 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801279:	c7 44 24 04 a4 27 80 	movl   $0x8027a4,0x4(%esp)
  801280:	00 
  801281:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801284:	89 04 24             	mov    %eax,(%esp)
  801287:	e8 f5 fb ff ff       	call   800e81 <sys_env_set_pgfault_upcall>
  80128c:	85 c0                	test   %eax,%eax
  80128e:	79 20                	jns    8012b0 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801290:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801294:	c7 44 24 08 ec 2f 80 	movl   $0x802fec,0x8(%esp)
  80129b:	00 
  80129c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012a3:	00 
  8012a4:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  8012ab:	e8 7c ef ff ff       	call   80022c <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8012b0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b7:	00 
  8012b8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012bf:	ee 
  8012c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c3:	89 04 24             	mov    %eax,(%esp)
  8012c6:	e8 16 fa ff ff       	call   800ce1 <sys_page_alloc>
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	79 20                	jns    8012ef <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8012cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d3:	c7 44 24 08 8c 2b 80 	movl   $0x802b8c,0x8(%esp)
  8012da:	00 
  8012db:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8012e2:	00 
  8012e3:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  8012ea:	e8 3d ef ff ff       	call   80022c <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8012ef:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012f6:	00 
  8012f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fa:	89 04 24             	mov    %eax,(%esp)
  8012fd:	e8 d9 fa ff ff       	call   800ddb <sys_env_set_status>
  801302:	85 c0                	test   %eax,%eax
  801304:	79 20                	jns    801326 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801306:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130a:	c7 44 24 08 49 30 80 	movl   $0x803049,0x8(%esp)
  801311:	00 
  801312:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801319:	00 
  80131a:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  801321:	e8 06 ef ff ff       	call   80022c <_panic>
	}
	
	return envid;
}
  801326:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801329:	83 c4 3c             	add    $0x3c,%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5e                   	pop    %esi
  80132e:	5f                   	pop    %edi
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <sfork>:

// Challenge!
int
sfork(void)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801337:	c7 44 24 08 60 30 80 	movl   $0x803060,0x8(%esp)
  80133e:	00 
  80133f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801346:	00 
  801347:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  80134e:	e8 d9 ee ff ff       	call   80022c <_panic>
	...

00801354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801357:	8b 45 08             	mov    0x8(%ebp),%eax
  80135a:	05 00 00 00 30       	add    $0x30000000,%eax
  80135f:	c1 e8 0c             	shr    $0xc,%eax
}
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    

00801364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	89 04 24             	mov    %eax,(%esp)
  801370:	e8 df ff ff ff       	call   801354 <fd2num>
  801375:	05 20 00 0d 00       	add    $0xd0020,%eax
  80137a:	c1 e0 0c             	shl    $0xc,%eax
}
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801386:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80138b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	c1 ea 16             	shr    $0x16,%edx
  801392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801399:	f6 c2 01             	test   $0x1,%dl
  80139c:	74 11                	je     8013af <fd_alloc+0x30>
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	c1 ea 0c             	shr    $0xc,%edx
  8013a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	75 09                	jne    8013b8 <fd_alloc+0x39>
			*fd_store = fd;
  8013af:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b6:	eb 17                	jmp    8013cf <fd_alloc+0x50>
  8013b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c2:	75 c7                	jne    80138b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013cf:	5b                   	pop    %ebx
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d8:	83 f8 1f             	cmp    $0x1f,%eax
  8013db:	77 36                	ja     801413 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013dd:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013e2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	c1 ea 16             	shr    $0x16,%edx
  8013ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f1:	f6 c2 01             	test   $0x1,%dl
  8013f4:	74 24                	je     80141a <fd_lookup+0x48>
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	c1 ea 0c             	shr    $0xc,%edx
  8013fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801402:	f6 c2 01             	test   $0x1,%dl
  801405:	74 1a                	je     801421 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140a:	89 02                	mov    %eax,(%edx)
	return 0;
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
  801411:	eb 13                	jmp    801426 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801418:	eb 0c                	jmp    801426 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141f:	eb 05                	jmp    801426 <fd_lookup+0x54>
  801421:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 14             	sub    $0x14,%esp
  80142f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801432:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801435:	ba 00 00 00 00       	mov    $0x0,%edx
  80143a:	eb 0e                	jmp    80144a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80143c:	39 08                	cmp    %ecx,(%eax)
  80143e:	75 09                	jne    801449 <dev_lookup+0x21>
			*dev = devtab[i];
  801440:	89 03                	mov    %eax,(%ebx)
			return 0;
  801442:	b8 00 00 00 00       	mov    $0x0,%eax
  801447:	eb 33                	jmp    80147c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801449:	42                   	inc    %edx
  80144a:	8b 04 95 f4 30 80 00 	mov    0x8030f4(,%edx,4),%eax
  801451:	85 c0                	test   %eax,%eax
  801453:	75 e7                	jne    80143c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801455:	a1 04 50 80 00       	mov    0x805004,%eax
  80145a:	8b 40 48             	mov    0x48(%eax),%eax
  80145d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801461:	89 44 24 04          	mov    %eax,0x4(%esp)
  801465:	c7 04 24 78 30 80 00 	movl   $0x803078,(%esp)
  80146c:	e8 b3 ee ff ff       	call   800324 <cprintf>
	*dev = 0;
  801471:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80147c:	83 c4 14             	add    $0x14,%esp
  80147f:	5b                   	pop    %ebx
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	56                   	push   %esi
  801486:	53                   	push   %ebx
  801487:	83 ec 30             	sub    $0x30,%esp
  80148a:	8b 75 08             	mov    0x8(%ebp),%esi
  80148d:	8a 45 0c             	mov    0xc(%ebp),%al
  801490:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801493:	89 34 24             	mov    %esi,(%esp)
  801496:	e8 b9 fe ff ff       	call   801354 <fd2num>
  80149b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80149e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a2:	89 04 24             	mov    %eax,(%esp)
  8014a5:	e8 28 ff ff ff       	call   8013d2 <fd_lookup>
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 05                	js     8014b5 <fd_close+0x33>
	    || fd != fd2)
  8014b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b3:	74 0d                	je     8014c2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014b5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014b9:	75 46                	jne    801501 <fd_close+0x7f>
  8014bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c0:	eb 3f                	jmp    801501 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	8b 06                	mov    (%esi),%eax
  8014cb:	89 04 24             	mov    %eax,(%esp)
  8014ce:	e8 55 ff ff ff       	call   801428 <dev_lookup>
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 18                	js     8014f1 <fd_close+0x6f>
		if (dev->dev_close)
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	8b 40 10             	mov    0x10(%eax),%eax
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	74 09                	je     8014ec <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e3:	89 34 24             	mov    %esi,(%esp)
  8014e6:	ff d0                	call   *%eax
  8014e8:	89 c3                	mov    %eax,%ebx
  8014ea:	eb 05                	jmp    8014f1 <fd_close+0x6f>
		else
			r = 0;
  8014ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fc:	e8 87 f8 ff ff       	call   800d88 <sys_page_unmap>
	return r;
}
  801501:	89 d8                	mov    %ebx,%eax
  801503:	83 c4 30             	add    $0x30,%esp
  801506:	5b                   	pop    %ebx
  801507:	5e                   	pop    %esi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	8b 45 08             	mov    0x8(%ebp),%eax
  80151a:	89 04 24             	mov    %eax,(%esp)
  80151d:	e8 b0 fe ff ff       	call   8013d2 <fd_lookup>
  801522:	85 c0                	test   %eax,%eax
  801524:	78 13                	js     801539 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801526:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80152d:	00 
  80152e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801531:	89 04 24             	mov    %eax,(%esp)
  801534:	e8 49 ff ff ff       	call   801482 <fd_close>
}
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <close_all>:

void
close_all(void)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801542:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801547:	89 1c 24             	mov    %ebx,(%esp)
  80154a:	e8 bb ff ff ff       	call   80150a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80154f:	43                   	inc    %ebx
  801550:	83 fb 20             	cmp    $0x20,%ebx
  801553:	75 f2                	jne    801547 <close_all+0xc>
		close(i);
}
  801555:	83 c4 14             	add    $0x14,%esp
  801558:	5b                   	pop    %ebx
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 4c             	sub    $0x4c,%esp
  801564:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801567:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80156a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
  801571:	89 04 24             	mov    %eax,(%esp)
  801574:	e8 59 fe ff ff       	call   8013d2 <fd_lookup>
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	85 c0                	test   %eax,%eax
  80157d:	0f 88 e1 00 00 00    	js     801664 <dup+0x109>
		return r;
	close(newfdnum);
  801583:	89 3c 24             	mov    %edi,(%esp)
  801586:	e8 7f ff ff ff       	call   80150a <close>

	newfd = INDEX2FD(newfdnum);
  80158b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801591:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801597:	89 04 24             	mov    %eax,(%esp)
  80159a:	e8 c5 fd ff ff       	call   801364 <fd2data>
  80159f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015a1:	89 34 24             	mov    %esi,(%esp)
  8015a4:	e8 bb fd ff ff       	call   801364 <fd2data>
  8015a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ac:	89 d8                	mov    %ebx,%eax
  8015ae:	c1 e8 16             	shr    $0x16,%eax
  8015b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b8:	a8 01                	test   $0x1,%al
  8015ba:	74 46                	je     801602 <dup+0xa7>
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	c1 e8 0c             	shr    $0xc,%eax
  8015c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c8:	f6 c2 01             	test   $0x1,%dl
  8015cb:	74 35                	je     801602 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015eb:	00 
  8015ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f7:	e8 39 f7 ff ff       	call   800d35 <sys_page_map>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 3b                	js     80163d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801605:	89 c2                	mov    %eax,%edx
  801607:	c1 ea 0c             	shr    $0xc,%edx
  80160a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801611:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801617:	89 54 24 10          	mov    %edx,0x10(%esp)
  80161b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80161f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801626:	00 
  801627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801632:	e8 fe f6 ff ff       	call   800d35 <sys_page_map>
  801637:	89 c3                	mov    %eax,%ebx
  801639:	85 c0                	test   %eax,%eax
  80163b:	79 25                	jns    801662 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80163d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801641:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801648:	e8 3b f7 ff ff       	call   800d88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80164d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801650:	89 44 24 04          	mov    %eax,0x4(%esp)
  801654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165b:	e8 28 f7 ff ff       	call   800d88 <sys_page_unmap>
	return r;
  801660:	eb 02                	jmp    801664 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801662:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801664:	89 d8                	mov    %ebx,%eax
  801666:	83 c4 4c             	add    $0x4c,%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 24             	sub    $0x24,%esp
  801675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167f:	89 1c 24             	mov    %ebx,(%esp)
  801682:	e8 4b fd ff ff       	call   8013d2 <fd_lookup>
  801687:	85 c0                	test   %eax,%eax
  801689:	78 6d                	js     8016f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	8b 00                	mov    (%eax),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 89 fd ff ff       	call   801428 <dev_lookup>
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 55                	js     8016f8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	8b 50 08             	mov    0x8(%eax),%edx
  8016a9:	83 e2 03             	and    $0x3,%edx
  8016ac:	83 fa 01             	cmp    $0x1,%edx
  8016af:	75 23                	jne    8016d4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b1:	a1 04 50 80 00       	mov    0x805004,%eax
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	c7 04 24 b9 30 80 00 	movl   $0x8030b9,(%esp)
  8016c8:	e8 57 ec ff ff       	call   800324 <cprintf>
		return -E_INVAL;
  8016cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d2:	eb 24                	jmp    8016f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8016d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d7:	8b 52 08             	mov    0x8(%edx),%edx
  8016da:	85 d2                	test   %edx,%edx
  8016dc:	74 15                	je     8016f3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	ff d2                	call   *%edx
  8016f1:	eb 05                	jmp    8016f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016f8:	83 c4 24             	add    $0x24,%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	83 ec 1c             	sub    $0x1c,%esp
  801707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801712:	eb 23                	jmp    801737 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801714:	89 f0                	mov    %esi,%eax
  801716:	29 d8                	sub    %ebx,%eax
  801718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171f:	01 d8                	add    %ebx,%eax
  801721:	89 44 24 04          	mov    %eax,0x4(%esp)
  801725:	89 3c 24             	mov    %edi,(%esp)
  801728:	e8 41 ff ff ff       	call   80166e <read>
		if (m < 0)
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 10                	js     801741 <readn+0x43>
			return m;
		if (m == 0)
  801731:	85 c0                	test   %eax,%eax
  801733:	74 0a                	je     80173f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801735:	01 c3                	add    %eax,%ebx
  801737:	39 f3                	cmp    %esi,%ebx
  801739:	72 d9                	jb     801714 <readn+0x16>
  80173b:	89 d8                	mov    %ebx,%eax
  80173d:	eb 02                	jmp    801741 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80173f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801741:	83 c4 1c             	add    $0x1c,%esp
  801744:	5b                   	pop    %ebx
  801745:	5e                   	pop    %esi
  801746:	5f                   	pop    %edi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 24             	sub    $0x24,%esp
  801750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175a:	89 1c 24             	mov    %ebx,(%esp)
  80175d:	e8 70 fc ff ff       	call   8013d2 <fd_lookup>
  801762:	85 c0                	test   %eax,%eax
  801764:	78 68                	js     8017ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801770:	8b 00                	mov    (%eax),%eax
  801772:	89 04 24             	mov    %eax,(%esp)
  801775:	e8 ae fc ff ff       	call   801428 <dev_lookup>
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 50                	js     8017ce <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801781:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801785:	75 23                	jne    8017aa <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801787:	a1 04 50 80 00       	mov    0x805004,%eax
  80178c:	8b 40 48             	mov    0x48(%eax),%eax
  80178f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801793:	89 44 24 04          	mov    %eax,0x4(%esp)
  801797:	c7 04 24 d5 30 80 00 	movl   $0x8030d5,(%esp)
  80179e:	e8 81 eb ff ff       	call   800324 <cprintf>
		return -E_INVAL;
  8017a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a8:	eb 24                	jmp    8017ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b0:	85 d2                	test   %edx,%edx
  8017b2:	74 15                	je     8017c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017c2:	89 04 24             	mov    %eax,(%esp)
  8017c5:	ff d2                	call   *%edx
  8017c7:	eb 05                	jmp    8017ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017ce:	83 c4 24             	add    $0x24,%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	89 04 24             	mov    %eax,(%esp)
  8017e7:	e8 e6 fb ff ff       	call   8013d2 <fd_lookup>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 0e                	js     8017fe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 24             	sub    $0x24,%esp
  801807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	89 1c 24             	mov    %ebx,(%esp)
  801814:	e8 b9 fb ff ff       	call   8013d2 <fd_lookup>
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 61                	js     80187e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801820:	89 44 24 04          	mov    %eax,0x4(%esp)
  801824:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801827:	8b 00                	mov    (%eax),%eax
  801829:	89 04 24             	mov    %eax,(%esp)
  80182c:	e8 f7 fb ff ff       	call   801428 <dev_lookup>
  801831:	85 c0                	test   %eax,%eax
  801833:	78 49                	js     80187e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801838:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183c:	75 23                	jne    801861 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80183e:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801843:	8b 40 48             	mov    0x48(%eax),%eax
  801846:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80184a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184e:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  801855:	e8 ca ea ff ff       	call   800324 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80185a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185f:	eb 1d                	jmp    80187e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801861:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801864:	8b 52 18             	mov    0x18(%edx),%edx
  801867:	85 d2                	test   %edx,%edx
  801869:	74 0e                	je     801879 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80186b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801872:	89 04 24             	mov    %eax,(%esp)
  801875:	ff d2                	call   *%edx
  801877:	eb 05                	jmp    80187e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801879:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80187e:	83 c4 24             	add    $0x24,%esp
  801881:	5b                   	pop    %ebx
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	53                   	push   %ebx
  801888:	83 ec 24             	sub    $0x24,%esp
  80188b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801891:	89 44 24 04          	mov    %eax,0x4(%esp)
  801895:	8b 45 08             	mov    0x8(%ebp),%eax
  801898:	89 04 24             	mov    %eax,(%esp)
  80189b:	e8 32 fb ff ff       	call   8013d2 <fd_lookup>
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	78 52                	js     8018f6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ae:	8b 00                	mov    (%eax),%eax
  8018b0:	89 04 24             	mov    %eax,(%esp)
  8018b3:	e8 70 fb ff ff       	call   801428 <dev_lookup>
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 3a                	js     8018f6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018c3:	74 2c                	je     8018f1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018cf:	00 00 00 
	stat->st_isdir = 0;
  8018d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d9:	00 00 00 
	stat->st_dev = dev;
  8018dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e9:	89 14 24             	mov    %edx,(%esp)
  8018ec:	ff 50 14             	call   *0x14(%eax)
  8018ef:	eb 05                	jmp    8018f6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018f6:	83 c4 24             	add    $0x24,%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	56                   	push   %esi
  801900:	53                   	push   %ebx
  801901:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801904:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80190b:	00 
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 fe 01 00 00       	call   801b15 <open>
  801917:	89 c3                	mov    %eax,%ebx
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 1b                	js     801938 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	89 44 24 04          	mov    %eax,0x4(%esp)
  801924:	89 1c 24             	mov    %ebx,(%esp)
  801927:	e8 58 ff ff ff       	call   801884 <fstat>
  80192c:	89 c6                	mov    %eax,%esi
	close(fd);
  80192e:	89 1c 24             	mov    %ebx,(%esp)
  801931:	e8 d4 fb ff ff       	call   80150a <close>
	return r;
  801936:	89 f3                	mov    %esi,%ebx
}
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    
  801941:	00 00                	add    %al,(%eax)
	...

00801944 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	83 ec 10             	sub    $0x10,%esp
  80194c:	89 c3                	mov    %eax,%ebx
  80194e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801950:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801957:	75 11                	jne    80196a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801959:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801960:	e8 34 0f 00 00       	call   802899 <ipc_find_env>
  801965:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80196a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801971:	00 
  801972:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801979:	00 
  80197a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197e:	a1 00 50 80 00       	mov    0x805000,%eax
  801983:	89 04 24             	mov    %eax,(%esp)
  801986:	e8 a4 0e 00 00       	call   80282f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80198b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801992:	00 
  801993:	89 74 24 04          	mov    %esi,0x4(%esp)
  801997:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199e:	e8 25 0e 00 00       	call   8027c8 <ipc_recv>
}
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	5b                   	pop    %ebx
  8019a7:	5e                   	pop    %esi
  8019a8:	5d                   	pop    %ebp
  8019a9:	c3                   	ret    

008019aa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019be:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019cd:	e8 72 ff ff ff       	call   801944 <fsipc>
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019da:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ef:	e8 50 ff ff ff       	call   801944 <fsipc>
}
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 14             	sub    $0x14,%esp
  8019fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	8b 40 0c             	mov    0xc(%eax),%eax
  801a06:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	b8 05 00 00 00       	mov    $0x5,%eax
  801a15:	e8 2a ff ff ff       	call   801944 <fsipc>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 2b                	js     801a49 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a1e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a25:	00 
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 c1 ee ff ff       	call   8008ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a2e:	a1 80 60 80 00       	mov    0x806080,%eax
  801a33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a39:	a1 84 60 80 00       	mov    0x806084,%eax
  801a3e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a49:	83 c4 14             	add    $0x14,%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a55:	c7 44 24 08 04 31 80 	movl   $0x803104,0x8(%esp)
  801a5c:	00 
  801a5d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a64:	00 
  801a65:	c7 04 24 22 31 80 00 	movl   $0x803122,(%esp)
  801a6c:	e8 bb e7 ff ff       	call   80022c <_panic>

00801a71 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 10             	sub    $0x10,%esp
  801a79:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a82:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a87:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a92:	b8 03 00 00 00       	mov    $0x3,%eax
  801a97:	e8 a8 fe ff ff       	call   801944 <fsipc>
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 6a                	js     801b0c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801aa2:	39 c6                	cmp    %eax,%esi
  801aa4:	73 24                	jae    801aca <devfile_read+0x59>
  801aa6:	c7 44 24 0c 2d 31 80 	movl   $0x80312d,0xc(%esp)
  801aad:	00 
  801aae:	c7 44 24 08 34 31 80 	movl   $0x803134,0x8(%esp)
  801ab5:	00 
  801ab6:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801abd:	00 
  801abe:	c7 04 24 22 31 80 00 	movl   $0x803122,(%esp)
  801ac5:	e8 62 e7 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801aca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801acf:	7e 24                	jle    801af5 <devfile_read+0x84>
  801ad1:	c7 44 24 0c 49 31 80 	movl   $0x803149,0xc(%esp)
  801ad8:	00 
  801ad9:	c7 44 24 08 34 31 80 	movl   $0x803134,0x8(%esp)
  801ae0:	00 
  801ae1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ae8:	00 
  801ae9:	c7 04 24 22 31 80 00 	movl   $0x803122,(%esp)
  801af0:	e8 37 e7 ff ff       	call   80022c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af9:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b00:	00 
  801b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b04:	89 04 24             	mov    %eax,(%esp)
  801b07:	e8 5c ef ff ff       	call   800a68 <memmove>
	return r;
}
  801b0c:	89 d8                	mov    %ebx,%eax
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	83 ec 20             	sub    $0x20,%esp
  801b1d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b20:	89 34 24             	mov    %esi,(%esp)
  801b23:	e8 94 ed ff ff       	call   8008bc <strlen>
  801b28:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b2d:	7f 60                	jg     801b8f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b32:	89 04 24             	mov    %eax,(%esp)
  801b35:	e8 45 f8 ff ff       	call   80137f <fd_alloc>
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 54                	js     801b94 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b40:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b44:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801b4b:	e8 9f ed ff ff       	call   8008ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b53:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801b60:	e8 df fd ff ff       	call   801944 <fsipc>
  801b65:	89 c3                	mov    %eax,%ebx
  801b67:	85 c0                	test   %eax,%eax
  801b69:	79 15                	jns    801b80 <open+0x6b>
		fd_close(fd, 0);
  801b6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b72:	00 
  801b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 04 f9 ff ff       	call   801482 <fd_close>
		return r;
  801b7e:	eb 14                	jmp    801b94 <open+0x7f>
	}

	return fd2num(fd);
  801b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b83:	89 04 24             	mov    %eax,(%esp)
  801b86:	e8 c9 f7 ff ff       	call   801354 <fd2num>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	eb 05                	jmp    801b94 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b8f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	83 c4 20             	add    $0x20,%esp
  801b99:	5b                   	pop    %ebx
  801b9a:	5e                   	pop    %esi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba8:	b8 08 00 00 00       	mov    $0x8,%eax
  801bad:	e8 92 fd ff ff       	call   801944 <fsipc>
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	57                   	push   %edi
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bc7:	00 
  801bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcb:	89 04 24             	mov    %eax,(%esp)
  801bce:	e8 42 ff ff ff       	call   801b15 <open>
  801bd3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 05 05 00 00    	js     8020e6 <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801be1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801be8:	00 
  801be9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 fd fa ff ff       	call   8016fe <readn>
  801c01:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c06:	75 0c                	jne    801c14 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801c08:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c0f:	45 4c 46 
  801c12:	74 3b                	je     801c4f <spawn+0x9b>
		close(fd);
  801c14:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c1a:	89 04 24             	mov    %eax,(%esp)
  801c1d:	e8 e8 f8 ff ff       	call   80150a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c22:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801c29:	46 
  801c2a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c34:	c7 04 24 55 31 80 00 	movl   $0x803155,(%esp)
  801c3b:	e8 e4 e6 ff ff       	call   800324 <cprintf>
		return -E_NOT_EXEC;
  801c40:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801c47:	ff ff ff 
  801c4a:	e9 a3 04 00 00       	jmp    8020f2 <spawn+0x53e>
  801c4f:	ba 07 00 00 00       	mov    $0x7,%edx
  801c54:	89 d0                	mov    %edx,%eax
  801c56:	cd 30                	int    $0x30
  801c58:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c5e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c64:	85 c0                	test   %eax,%eax
  801c66:	0f 88 86 04 00 00    	js     8020f2 <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c6c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801c78:	c1 e0 07             	shl    $0x7,%eax
  801c7b:	29 d0                	sub    %edx,%eax
  801c7d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801c83:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c89:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c90:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c96:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c9c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ca9:	eb 0d                	jmp    801cb8 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801cab:	89 04 24             	mov    %eax,(%esp)
  801cae:	e8 09 ec ff ff       	call   8008bc <strlen>
  801cb3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cb7:	46                   	inc    %esi
  801cb8:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801cba:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cc1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	75 e3                	jne    801cab <spawn+0xf7>
  801cc8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801cce:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801cd4:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cd9:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cdb:	89 f8                	mov    %edi,%eax
  801cdd:	83 e0 fc             	and    $0xfffffffc,%eax
  801ce0:	f7 d2                	not    %edx
  801ce2:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801ce5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	83 e8 08             	sub    $0x8,%eax
  801cf0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cf5:	0f 86 08 04 00 00    	jbe    802103 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cfb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d02:	00 
  801d03:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d0a:	00 
  801d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d12:	e8 ca ef ff ff       	call   800ce1 <sys_page_alloc>
  801d17:	85 c0                	test   %eax,%eax
  801d19:	0f 88 e9 03 00 00    	js     802108 <spawn+0x554>
  801d1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d24:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801d2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d2d:	eb 2e                	jmp    801d5d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d2f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d35:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d3b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801d3e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d45:	89 3c 24             	mov    %edi,(%esp)
  801d48:	e8 a2 eb ff ff       	call   8008ef <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d4d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801d50:	89 04 24             	mov    %eax,(%esp)
  801d53:	e8 64 eb ff ff       	call   8008bc <strlen>
  801d58:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d5c:	43                   	inc    %ebx
  801d5d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d63:	7c ca                	jl     801d2f <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d65:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d6b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801d71:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d78:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d7e:	74 24                	je     801da4 <spawn+0x1f0>
  801d80:	c7 44 24 0c b4 31 80 	movl   $0x8031b4,0xc(%esp)
  801d87:	00 
  801d88:	c7 44 24 08 34 31 80 	movl   $0x803134,0x8(%esp)
  801d8f:	00 
  801d90:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801d97:	00 
  801d98:	c7 04 24 6f 31 80 00 	movl   $0x80316f,(%esp)
  801d9f:	e8 88 e4 ff ff       	call   80022c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801da4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801daa:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801daf:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801db5:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801db8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801dbe:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801dc1:	89 d0                	mov    %edx,%eax
  801dc3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801dc8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801dce:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801dd5:	00 
  801dd6:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801ddd:	ee 
  801dde:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801de4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801def:	00 
  801df0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df7:	e8 39 ef ff ff       	call   800d35 <sys_page_map>
  801dfc:	89 c3                	mov    %eax,%ebx
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 1a                	js     801e1c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e02:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e09:	00 
  801e0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e11:	e8 72 ef ff ff       	call   800d88 <sys_page_unmap>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	79 1f                	jns    801e3b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e1c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e23:	00 
  801e24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2b:	e8 58 ef ff ff       	call   800d88 <sys_page_unmap>
	return r;
  801e30:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801e36:	e9 b7 02 00 00       	jmp    8020f2 <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e3b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801e41:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801e47:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e4d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801e54:	00 00 00 
  801e57:	e9 bb 01 00 00       	jmp    802017 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801e5c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e62:	83 38 01             	cmpl   $0x1,(%eax)
  801e65:	0f 85 9f 01 00 00    	jne    80200a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e6b:	89 c2                	mov    %eax,%edx
  801e6d:	8b 40 18             	mov    0x18(%eax),%eax
  801e70:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801e73:	83 f8 01             	cmp    $0x1,%eax
  801e76:	19 c0                	sbb    %eax,%eax
  801e78:	83 e0 fe             	and    $0xfffffffe,%eax
  801e7b:	83 c0 07             	add    $0x7,%eax
  801e7e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e84:	8b 52 04             	mov    0x4(%edx),%edx
  801e87:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801e8d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e93:	8b 40 10             	mov    0x10(%eax),%eax
  801e96:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e9c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ea2:	8b 52 14             	mov    0x14(%edx),%edx
  801ea5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801eab:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801eb1:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ebb:	74 16                	je     801ed3 <spawn+0x31f>
		va -= i;
  801ebd:	29 c7                	sub    %eax,%edi
		memsz += i;
  801ebf:	01 c2                	add    %eax,%edx
  801ec1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801ec7:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ecd:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed8:	e9 1f 01 00 00       	jmp    801ffc <spawn+0x448>
		if (i >= filesz) {
  801edd:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801ee3:	77 2b                	ja     801f10 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ee5:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ef3:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ef9:	89 04 24             	mov    %eax,(%esp)
  801efc:	e8 e0 ed ff ff       	call   800ce1 <sys_page_alloc>
  801f01:	85 c0                	test   %eax,%eax
  801f03:	0f 89 e7 00 00 00    	jns    801ff0 <spawn+0x43c>
  801f09:	89 c6                	mov    %eax,%esi
  801f0b:	e9 b2 01 00 00       	jmp    8020c2 <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f10:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801f17:	00 
  801f18:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f1f:	00 
  801f20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f27:	e8 b5 ed ff ff       	call   800ce1 <sys_page_alloc>
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	0f 88 84 01 00 00    	js     8020b8 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801f34:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801f3a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f40:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f46:	89 04 24             	mov    %eax,(%esp)
  801f49:	e8 86 f8 ff ff       	call   8017d4 <seek>
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	0f 88 66 01 00 00    	js     8020bc <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801f56:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f5c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f5e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f63:	76 05                	jbe    801f6a <spawn+0x3b6>
  801f65:	b8 00 10 00 00       	mov    $0x1000,%eax
  801f6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f6e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f75:	00 
  801f76:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f7c:	89 04 24             	mov    %eax,(%esp)
  801f7f:	e8 7a f7 ff ff       	call   8016fe <readn>
  801f84:	85 c0                	test   %eax,%eax
  801f86:	0f 88 34 01 00 00    	js     8020c0 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f8c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801f92:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f96:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f9a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fa0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fab:	00 
  801fac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb3:	e8 7d ed ff ff       	call   800d35 <sys_page_map>
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	79 20                	jns    801fdc <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc0:	c7 44 24 08 7b 31 80 	movl   $0x80317b,0x8(%esp)
  801fc7:	00 
  801fc8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801fcf:	00 
  801fd0:	c7 04 24 6f 31 80 00 	movl   $0x80316f,(%esp)
  801fd7:	e8 50 e2 ff ff       	call   80022c <_panic>
			sys_page_unmap(0, UTEMP);
  801fdc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fe3:	00 
  801fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801feb:	e8 98 ed ff ff       	call   800d88 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ff0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ff6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801ffc:	89 de                	mov    %ebx,%esi
  801ffe:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802004:	0f 87 d3 fe ff ff    	ja     801edd <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80200a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802010:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802017:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80201e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802024:	0f 8c 32 fe ff ff    	jl     801e5c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80202a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802030:	89 04 24             	mov    %eax,(%esp)
  802033:	e8 d2 f4 ff ff       	call   80150a <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802038:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80203f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802042:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802052:	89 04 24             	mov    %eax,(%esp)
  802055:	e8 d4 ed ff ff       	call   800e2e <sys_env_set_trapframe>
  80205a:	85 c0                	test   %eax,%eax
  80205c:	79 20                	jns    80207e <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  80205e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802062:	c7 44 24 08 98 31 80 	movl   $0x803198,0x8(%esp)
  802069:	00 
  80206a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802071:	00 
  802072:	c7 04 24 6f 31 80 00 	movl   $0x80316f,(%esp)
  802079:	e8 ae e1 ff ff       	call   80022c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80207e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802085:	00 
  802086:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 47 ed ff ff       	call   800ddb <sys_env_set_status>
  802094:	85 c0                	test   %eax,%eax
  802096:	79 5a                	jns    8020f2 <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  802098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209c:	c7 44 24 08 49 30 80 	movl   $0x803049,0x8(%esp)
  8020a3:	00 
  8020a4:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8020ab:	00 
  8020ac:	c7 04 24 6f 31 80 00 	movl   $0x80316f,(%esp)
  8020b3:	e8 74 e1 ff ff       	call   80022c <_panic>
  8020b8:	89 c6                	mov    %eax,%esi
  8020ba:	eb 06                	jmp    8020c2 <spawn+0x50e>
  8020bc:	89 c6                	mov    %eax,%esi
  8020be:	eb 02                	jmp    8020c2 <spawn+0x50e>
  8020c0:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8020c2:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8020c8:	89 04 24             	mov    %eax,(%esp)
  8020cb:	e8 81 eb ff ff       	call   800c51 <sys_env_destroy>
	close(fd);
  8020d0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020d6:	89 04 24             	mov    %eax,(%esp)
  8020d9:	e8 2c f4 ff ff       	call   80150a <close>
	return r;
  8020de:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8020e4:	eb 0c                	jmp    8020f2 <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020e6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020ec:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8020f2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8020f8:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8020fe:	5b                   	pop    %ebx
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802103:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802108:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  80210e:	eb e2                	jmp    8020f2 <spawn+0x53e>

00802110 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	57                   	push   %edi
  802114:	56                   	push   %esi
  802115:	53                   	push   %ebx
  802116:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802119:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80211c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802121:	eb 03                	jmp    802126 <spawnl+0x16>
		argc++;
  802123:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802124:	89 d0                	mov    %edx,%eax
  802126:	8d 50 04             	lea    0x4(%eax),%edx
  802129:	83 38 00             	cmpl   $0x0,(%eax)
  80212c:	75 f5                	jne    802123 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80212e:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802135:	83 e0 f0             	and    $0xfffffff0,%eax
  802138:	29 c4                	sub    %eax,%esp
  80213a:	8d 7c 24 17          	lea    0x17(%esp),%edi
  80213e:	83 e7 f0             	and    $0xfffffff0,%edi
  802141:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802143:	8b 45 0c             	mov    0xc(%ebp),%eax
  802146:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802148:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  80214f:	00 

	va_start(vl, arg0);
  802150:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
  802158:	eb 09                	jmp    802163 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80215a:	40                   	inc    %eax
  80215b:	8b 1a                	mov    (%edx),%ebx
  80215d:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802160:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802163:	39 c8                	cmp    %ecx,%eax
  802165:	75 f3                	jne    80215a <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802167:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
  80216e:	89 04 24             	mov    %eax,(%esp)
  802171:	e8 3e fa ff ff       	call   801bb4 <spawn>
}
  802176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802179:	5b                   	pop    %ebx
  80217a:	5e                   	pop    %esi
  80217b:	5f                   	pop    %edi
  80217c:	5d                   	pop    %ebp
  80217d:	c3                   	ret    
	...

00802180 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	56                   	push   %esi
  802184:	53                   	push   %ebx
  802185:	83 ec 10             	sub    $0x10,%esp
  802188:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80218b:	8b 45 08             	mov    0x8(%ebp),%eax
  80218e:	89 04 24             	mov    %eax,(%esp)
  802191:	e8 ce f1 ff ff       	call   801364 <fd2data>
  802196:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802198:	c7 44 24 04 da 31 80 	movl   $0x8031da,0x4(%esp)
  80219f:	00 
  8021a0:	89 34 24             	mov    %esi,(%esp)
  8021a3:	e8 47 e7 ff ff       	call   8008ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8021ab:	2b 03                	sub    (%ebx),%eax
  8021ad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021b3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021ba:	00 00 00 
	stat->st_dev = &devpipe;
  8021bd:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  8021c4:	40 80 00 
	return 0;
}
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cc:	83 c4 10             	add    $0x10,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    

008021d3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	53                   	push   %ebx
  8021d7:	83 ec 14             	sub    $0x14,%esp
  8021da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e8:	e8 9b eb ff ff       	call   800d88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021ed:	89 1c 24             	mov    %ebx,(%esp)
  8021f0:	e8 6f f1 ff ff       	call   801364 <fd2data>
  8021f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802200:	e8 83 eb ff ff       	call   800d88 <sys_page_unmap>
}
  802205:	83 c4 14             	add    $0x14,%esp
  802208:	5b                   	pop    %ebx
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    

0080220b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	57                   	push   %edi
  80220f:	56                   	push   %esi
  802210:	53                   	push   %ebx
  802211:	83 ec 2c             	sub    $0x2c,%esp
  802214:	89 c7                	mov    %eax,%edi
  802216:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802219:	a1 04 50 80 00       	mov    0x805004,%eax
  80221e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802221:	89 3c 24             	mov    %edi,(%esp)
  802224:	e8 b7 06 00 00       	call   8028e0 <pageref>
  802229:	89 c6                	mov    %eax,%esi
  80222b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80222e:	89 04 24             	mov    %eax,(%esp)
  802231:	e8 aa 06 00 00       	call   8028e0 <pageref>
  802236:	39 c6                	cmp    %eax,%esi
  802238:	0f 94 c0             	sete   %al
  80223b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80223e:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802244:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802247:	39 cb                	cmp    %ecx,%ebx
  802249:	75 08                	jne    802253 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80224b:	83 c4 2c             	add    $0x2c,%esp
  80224e:	5b                   	pop    %ebx
  80224f:	5e                   	pop    %esi
  802250:	5f                   	pop    %edi
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802253:	83 f8 01             	cmp    $0x1,%eax
  802256:	75 c1                	jne    802219 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802258:	8b 42 58             	mov    0x58(%edx),%eax
  80225b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802262:	00 
  802263:	89 44 24 08          	mov    %eax,0x8(%esp)
  802267:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80226b:	c7 04 24 e1 31 80 00 	movl   $0x8031e1,(%esp)
  802272:	e8 ad e0 ff ff       	call   800324 <cprintf>
  802277:	eb a0                	jmp    802219 <_pipeisclosed+0xe>

00802279 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	57                   	push   %edi
  80227d:	56                   	push   %esi
  80227e:	53                   	push   %ebx
  80227f:	83 ec 1c             	sub    $0x1c,%esp
  802282:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802285:	89 34 24             	mov    %esi,(%esp)
  802288:	e8 d7 f0 ff ff       	call   801364 <fd2data>
  80228d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80228f:	bf 00 00 00 00       	mov    $0x0,%edi
  802294:	eb 3c                	jmp    8022d2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802296:	89 da                	mov    %ebx,%edx
  802298:	89 f0                	mov    %esi,%eax
  80229a:	e8 6c ff ff ff       	call   80220b <_pipeisclosed>
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	75 38                	jne    8022db <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022a3:	e8 1a ea ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8022ab:	8b 13                	mov    (%ebx),%edx
  8022ad:	83 c2 20             	add    $0x20,%edx
  8022b0:	39 d0                	cmp    %edx,%eax
  8022b2:	73 e2                	jae    802296 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022b7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8022ba:	89 c2                	mov    %eax,%edx
  8022bc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022c2:	79 05                	jns    8022c9 <devpipe_write+0x50>
  8022c4:	4a                   	dec    %edx
  8022c5:	83 ca e0             	or     $0xffffffe0,%edx
  8022c8:	42                   	inc    %edx
  8022c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022cd:	40                   	inc    %eax
  8022ce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d1:	47                   	inc    %edi
  8022d2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022d5:	75 d1                	jne    8022a8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022d7:	89 f8                	mov    %edi,%eax
  8022d9:	eb 05                	jmp    8022e0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022db:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    

008022e8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	57                   	push   %edi
  8022ec:	56                   	push   %esi
  8022ed:	53                   	push   %ebx
  8022ee:	83 ec 1c             	sub    $0x1c,%esp
  8022f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022f4:	89 3c 24             	mov    %edi,(%esp)
  8022f7:	e8 68 f0 ff ff       	call   801364 <fd2data>
  8022fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fe:	be 00 00 00 00       	mov    $0x0,%esi
  802303:	eb 3a                	jmp    80233f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802305:	85 f6                	test   %esi,%esi
  802307:	74 04                	je     80230d <devpipe_read+0x25>
				return i;
  802309:	89 f0                	mov    %esi,%eax
  80230b:	eb 40                	jmp    80234d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80230d:	89 da                	mov    %ebx,%edx
  80230f:	89 f8                	mov    %edi,%eax
  802311:	e8 f5 fe ff ff       	call   80220b <_pipeisclosed>
  802316:	85 c0                	test   %eax,%eax
  802318:	75 2e                	jne    802348 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80231a:	e8 a3 e9 ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80231f:	8b 03                	mov    (%ebx),%eax
  802321:	3b 43 04             	cmp    0x4(%ebx),%eax
  802324:	74 df                	je     802305 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802326:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80232b:	79 05                	jns    802332 <devpipe_read+0x4a>
  80232d:	48                   	dec    %eax
  80232e:	83 c8 e0             	or     $0xffffffe0,%eax
  802331:	40                   	inc    %eax
  802332:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802336:	8b 55 0c             	mov    0xc(%ebp),%edx
  802339:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80233c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233e:	46                   	inc    %esi
  80233f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802342:	75 db                	jne    80231f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802344:	89 f0                	mov    %esi,%eax
  802346:	eb 05                	jmp    80234d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802348:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80234d:	83 c4 1c             	add    $0x1c,%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    

00802355 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	57                   	push   %edi
  802359:	56                   	push   %esi
  80235a:	53                   	push   %ebx
  80235b:	83 ec 3c             	sub    $0x3c,%esp
  80235e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802361:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802364:	89 04 24             	mov    %eax,(%esp)
  802367:	e8 13 f0 ff ff       	call   80137f <fd_alloc>
  80236c:	89 c3                	mov    %eax,%ebx
  80236e:	85 c0                	test   %eax,%eax
  802370:	0f 88 45 01 00 00    	js     8024bb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802376:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80237d:	00 
  80237e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802381:	89 44 24 04          	mov    %eax,0x4(%esp)
  802385:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80238c:	e8 50 e9 ff ff       	call   800ce1 <sys_page_alloc>
  802391:	89 c3                	mov    %eax,%ebx
  802393:	85 c0                	test   %eax,%eax
  802395:	0f 88 20 01 00 00    	js     8024bb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80239b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80239e:	89 04 24             	mov    %eax,(%esp)
  8023a1:	e8 d9 ef ff ff       	call   80137f <fd_alloc>
  8023a6:	89 c3                	mov    %eax,%ebx
  8023a8:	85 c0                	test   %eax,%eax
  8023aa:	0f 88 f8 00 00 00    	js     8024a8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023b0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023b7:	00 
  8023b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c6:	e8 16 e9 ff ff       	call   800ce1 <sys_page_alloc>
  8023cb:	89 c3                	mov    %eax,%ebx
  8023cd:	85 c0                	test   %eax,%eax
  8023cf:	0f 88 d3 00 00 00    	js     8024a8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d8:	89 04 24             	mov    %eax,(%esp)
  8023db:	e8 84 ef ff ff       	call   801364 <fd2data>
  8023e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023e9:	00 
  8023ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f5:	e8 e7 e8 ff ff       	call   800ce1 <sys_page_alloc>
  8023fa:	89 c3                	mov    %eax,%ebx
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	0f 88 91 00 00 00    	js     802495 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802407:	89 04 24             	mov    %eax,(%esp)
  80240a:	e8 55 ef ff ff       	call   801364 <fd2data>
  80240f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802416:	00 
  802417:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80241b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802422:	00 
  802423:	89 74 24 04          	mov    %esi,0x4(%esp)
  802427:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242e:	e8 02 e9 ff ff       	call   800d35 <sys_page_map>
  802433:	89 c3                	mov    %eax,%ebx
  802435:	85 c0                	test   %eax,%eax
  802437:	78 4c                	js     802485 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802439:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80243f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802442:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802444:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802447:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80244e:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802454:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802457:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80245c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802466:	89 04 24             	mov    %eax,(%esp)
  802469:	e8 e6 ee ff ff       	call   801354 <fd2num>
  80246e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802470:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802473:	89 04 24             	mov    %eax,(%esp)
  802476:	e8 d9 ee ff ff       	call   801354 <fd2num>
  80247b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80247e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802483:	eb 36                	jmp    8024bb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802485:	89 74 24 04          	mov    %esi,0x4(%esp)
  802489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802490:	e8 f3 e8 ff ff       	call   800d88 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802495:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a3:	e8 e0 e8 ff ff       	call   800d88 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8024a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b6:	e8 cd e8 ff ff       	call   800d88 <sys_page_unmap>
    err:
	return r;
}
  8024bb:	89 d8                	mov    %ebx,%eax
  8024bd:	83 c4 3c             	add    $0x3c,%esp
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    

008024c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d5:	89 04 24             	mov    %eax,(%esp)
  8024d8:	e8 f5 ee ff ff       	call   8013d2 <fd_lookup>
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	78 15                	js     8024f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e4:	89 04 24             	mov    %eax,(%esp)
  8024e7:	e8 78 ee ff ff       	call   801364 <fd2data>
	return _pipeisclosed(fd, p);
  8024ec:	89 c2                	mov    %eax,%edx
  8024ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f1:	e8 15 fd ff ff       	call   80220b <_pipeisclosed>
}
  8024f6:	c9                   	leave  
  8024f7:	c3                   	ret    

008024f8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	56                   	push   %esi
  8024fc:	53                   	push   %ebx
  8024fd:	83 ec 10             	sub    $0x10,%esp
  802500:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802503:	85 f6                	test   %esi,%esi
  802505:	75 24                	jne    80252b <wait+0x33>
  802507:	c7 44 24 0c f9 31 80 	movl   $0x8031f9,0xc(%esp)
  80250e:	00 
  80250f:	c7 44 24 08 34 31 80 	movl   $0x803134,0x8(%esp)
  802516:	00 
  802517:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80251e:	00 
  80251f:	c7 04 24 04 32 80 00 	movl   $0x803204,(%esp)
  802526:	e8 01 dd ff ff       	call   80022c <_panic>
	e = &envs[ENVX(envid)];
  80252b:	89 f3                	mov    %esi,%ebx
  80252d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802533:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80253a:	c1 e3 07             	shl    $0x7,%ebx
  80253d:	29 c3                	sub    %eax,%ebx
  80253f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802545:	eb 05                	jmp    80254c <wait+0x54>
		sys_yield();
  802547:	e8 76 e7 ff ff       	call   800cc2 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80254c:	8b 43 48             	mov    0x48(%ebx),%eax
  80254f:	39 f0                	cmp    %esi,%eax
  802551:	75 07                	jne    80255a <wait+0x62>
  802553:	8b 43 54             	mov    0x54(%ebx),%eax
  802556:	85 c0                	test   %eax,%eax
  802558:	75 ed                	jne    802547 <wait+0x4f>
		sys_yield();
}
  80255a:	83 c4 10             	add    $0x10,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
  802561:	00 00                	add    %al,(%eax)
	...

00802564 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802567:	b8 00 00 00 00       	mov    $0x0,%eax
  80256c:	5d                   	pop    %ebp
  80256d:	c3                   	ret    

0080256e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802574:	c7 44 24 04 0f 32 80 	movl   $0x80320f,0x4(%esp)
  80257b:	00 
  80257c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257f:	89 04 24             	mov    %eax,(%esp)
  802582:	e8 68 e3 ff ff       	call   8008ef <strcpy>
	return 0;
}
  802587:	b8 00 00 00 00       	mov    $0x0,%eax
  80258c:	c9                   	leave  
  80258d:	c3                   	ret    

0080258e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80258e:	55                   	push   %ebp
  80258f:	89 e5                	mov    %esp,%ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80259a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80259f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025a5:	eb 30                	jmp    8025d7 <devcons_write+0x49>
		m = n - tot;
  8025a7:	8b 75 10             	mov    0x10(%ebp),%esi
  8025aa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025ac:	83 fe 7f             	cmp    $0x7f,%esi
  8025af:	76 05                	jbe    8025b6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8025b1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8025b6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025ba:	03 45 0c             	add    0xc(%ebp),%eax
  8025bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025c1:	89 3c 24             	mov    %edi,(%esp)
  8025c4:	e8 9f e4 ff ff       	call   800a68 <memmove>
		sys_cputs(buf, m);
  8025c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025cd:	89 3c 24             	mov    %edi,(%esp)
  8025d0:	e8 3f e6 ff ff       	call   800c14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025d5:	01 f3                	add    %esi,%ebx
  8025d7:	89 d8                	mov    %ebx,%eax
  8025d9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025dc:	72 c9                	jb     8025a7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025de:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    

008025e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025e9:	55                   	push   %ebp
  8025ea:	89 e5                	mov    %esp,%ebp
  8025ec:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025f3:	75 07                	jne    8025fc <devcons_read+0x13>
  8025f5:	eb 25                	jmp    80261c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025f7:	e8 c6 e6 ff ff       	call   800cc2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025fc:	e8 31 e6 ff ff       	call   800c32 <sys_cgetc>
  802601:	85 c0                	test   %eax,%eax
  802603:	74 f2                	je     8025f7 <devcons_read+0xe>
  802605:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802607:	85 c0                	test   %eax,%eax
  802609:	78 1d                	js     802628 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80260b:	83 f8 04             	cmp    $0x4,%eax
  80260e:	74 13                	je     802623 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802610:	8b 45 0c             	mov    0xc(%ebp),%eax
  802613:	88 10                	mov    %dl,(%eax)
	return 1;
  802615:	b8 01 00 00 00       	mov    $0x1,%eax
  80261a:	eb 0c                	jmp    802628 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80261c:	b8 00 00 00 00       	mov    $0x0,%eax
  802621:	eb 05                	jmp    802628 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802623:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802628:	c9                   	leave  
  802629:	c3                   	ret    

0080262a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80262a:	55                   	push   %ebp
  80262b:	89 e5                	mov    %esp,%ebp
  80262d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802630:	8b 45 08             	mov    0x8(%ebp),%eax
  802633:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802636:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80263d:	00 
  80263e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802641:	89 04 24             	mov    %eax,(%esp)
  802644:	e8 cb e5 ff ff       	call   800c14 <sys_cputs>
}
  802649:	c9                   	leave  
  80264a:	c3                   	ret    

0080264b <getchar>:

int
getchar(void)
{
  80264b:	55                   	push   %ebp
  80264c:	89 e5                	mov    %esp,%ebp
  80264e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802651:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802658:	00 
  802659:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80265c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802660:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802667:	e8 02 f0 ff ff       	call   80166e <read>
	if (r < 0)
  80266c:	85 c0                	test   %eax,%eax
  80266e:	78 0f                	js     80267f <getchar+0x34>
		return r;
	if (r < 1)
  802670:	85 c0                	test   %eax,%eax
  802672:	7e 06                	jle    80267a <getchar+0x2f>
		return -E_EOF;
	return c;
  802674:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802678:	eb 05                	jmp    80267f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80267a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80267f:	c9                   	leave  
  802680:	c3                   	ret    

00802681 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802681:	55                   	push   %ebp
  802682:	89 e5                	mov    %esp,%ebp
  802684:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802687:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80268a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80268e:	8b 45 08             	mov    0x8(%ebp),%eax
  802691:	89 04 24             	mov    %eax,(%esp)
  802694:	e8 39 ed ff ff       	call   8013d2 <fd_lookup>
  802699:	85 c0                	test   %eax,%eax
  80269b:	78 11                	js     8026ae <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80269d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a0:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026a6:	39 10                	cmp    %edx,(%eax)
  8026a8:	0f 94 c0             	sete   %al
  8026ab:	0f b6 c0             	movzbl %al,%eax
}
  8026ae:	c9                   	leave  
  8026af:	c3                   	ret    

008026b0 <opencons>:

int
opencons(void)
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
  8026b3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026b9:	89 04 24             	mov    %eax,(%esp)
  8026bc:	e8 be ec ff ff       	call   80137f <fd_alloc>
  8026c1:	85 c0                	test   %eax,%eax
  8026c3:	78 3c                	js     802701 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026c5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026cc:	00 
  8026cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026db:	e8 01 e6 ff ff       	call   800ce1 <sys_page_alloc>
  8026e0:	85 c0                	test   %eax,%eax
  8026e2:	78 1d                	js     802701 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026e4:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026ed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026f9:	89 04 24             	mov    %eax,(%esp)
  8026fc:	e8 53 ec ff ff       	call   801354 <fd2num>
}
  802701:	c9                   	leave  
  802702:	c3                   	ret    
	...

00802704 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802704:	55                   	push   %ebp
  802705:	89 e5                	mov    %esp,%ebp
  802707:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80270a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802711:	0f 85 80 00 00 00    	jne    802797 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  802717:	a1 04 50 80 00       	mov    0x805004,%eax
  80271c:	8b 40 48             	mov    0x48(%eax),%eax
  80271f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802726:	00 
  802727:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80272e:	ee 
  80272f:	89 04 24             	mov    %eax,(%esp)
  802732:	e8 aa e5 ff ff       	call   800ce1 <sys_page_alloc>
  802737:	85 c0                	test   %eax,%eax
  802739:	79 20                	jns    80275b <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80273b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273f:	c7 44 24 08 1c 32 80 	movl   $0x80321c,0x8(%esp)
  802746:	00 
  802747:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80274e:	00 
  80274f:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  802756:	e8 d1 da ff ff       	call   80022c <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80275b:	a1 04 50 80 00       	mov    0x805004,%eax
  802760:	8b 40 48             	mov    0x48(%eax),%eax
  802763:	c7 44 24 04 a4 27 80 	movl   $0x8027a4,0x4(%esp)
  80276a:	00 
  80276b:	89 04 24             	mov    %eax,(%esp)
  80276e:	e8 0e e7 ff ff       	call   800e81 <sys_env_set_pgfault_upcall>
  802773:	85 c0                	test   %eax,%eax
  802775:	79 20                	jns    802797 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  802777:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80277b:	c7 44 24 08 48 32 80 	movl   $0x803248,0x8(%esp)
  802782:	00 
  802783:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80278a:	00 
  80278b:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  802792:	e8 95 da ff ff       	call   80022c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802797:	8b 45 08             	mov    0x8(%ebp),%eax
  80279a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80279f:	c9                   	leave  
  8027a0:	c3                   	ret    
  8027a1:	00 00                	add    %al,(%eax)
	...

008027a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027a5:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8027aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027ac:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8027af:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8027b3:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8027b5:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8027b8:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8027b9:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8027bc:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8027be:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8027c1:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8027c2:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8027c5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027c6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8027c7:	c3                   	ret    

008027c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027c8:	55                   	push   %ebp
  8027c9:	89 e5                	mov    %esp,%ebp
  8027cb:	56                   	push   %esi
  8027cc:	53                   	push   %ebx
  8027cd:	83 ec 10             	sub    $0x10,%esp
  8027d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8027d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8027d9:	85 c0                	test   %eax,%eax
  8027db:	75 05                	jne    8027e2 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8027dd:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8027e2:	89 04 24             	mov    %eax,(%esp)
  8027e5:	e8 0d e7 ff ff       	call   800ef7 <sys_ipc_recv>
	if (!err) {
  8027ea:	85 c0                	test   %eax,%eax
  8027ec:	75 26                	jne    802814 <ipc_recv+0x4c>
		if (from_env_store) {
  8027ee:	85 f6                	test   %esi,%esi
  8027f0:	74 0a                	je     8027fc <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8027f2:	a1 04 50 80 00       	mov    0x805004,%eax
  8027f7:	8b 40 74             	mov    0x74(%eax),%eax
  8027fa:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8027fc:	85 db                	test   %ebx,%ebx
  8027fe:	74 0a                	je     80280a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802800:	a1 04 50 80 00       	mov    0x805004,%eax
  802805:	8b 40 78             	mov    0x78(%eax),%eax
  802808:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80280a:	a1 04 50 80 00       	mov    0x805004,%eax
  80280f:	8b 40 70             	mov    0x70(%eax),%eax
  802812:	eb 14                	jmp    802828 <ipc_recv+0x60>
	}
	if (from_env_store) {
  802814:	85 f6                	test   %esi,%esi
  802816:	74 06                	je     80281e <ipc_recv+0x56>
		*from_env_store = 0;
  802818:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  80281e:	85 db                	test   %ebx,%ebx
  802820:	74 06                	je     802828 <ipc_recv+0x60>
		*perm_store = 0;
  802822:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802828:	83 c4 10             	add    $0x10,%esp
  80282b:	5b                   	pop    %ebx
  80282c:	5e                   	pop    %esi
  80282d:	5d                   	pop    %ebp
  80282e:	c3                   	ret    

0080282f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80282f:	55                   	push   %ebp
  802830:	89 e5                	mov    %esp,%ebp
  802832:	57                   	push   %edi
  802833:	56                   	push   %esi
  802834:	53                   	push   %ebx
  802835:	83 ec 1c             	sub    $0x1c,%esp
  802838:	8b 75 10             	mov    0x10(%ebp),%esi
  80283b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  80283e:	85 f6                	test   %esi,%esi
  802840:	75 05                	jne    802847 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802842:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  802847:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80284b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80284f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802852:	89 44 24 04          	mov    %eax,0x4(%esp)
  802856:	8b 45 08             	mov    0x8(%ebp),%eax
  802859:	89 04 24             	mov    %eax,(%esp)
  80285c:	e8 73 e6 ff ff       	call   800ed4 <sys_ipc_try_send>
  802861:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802863:	e8 5a e4 ff ff       	call   800cc2 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802868:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80286b:	74 da                	je     802847 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  80286d:	85 db                	test   %ebx,%ebx
  80286f:	74 20                	je     802891 <ipc_send+0x62>
		panic("send fail: %e", err);
  802871:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802875:	c7 44 24 08 86 32 80 	movl   $0x803286,0x8(%esp)
  80287c:	00 
  80287d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802884:	00 
  802885:	c7 04 24 94 32 80 00 	movl   $0x803294,(%esp)
  80288c:	e8 9b d9 ff ff       	call   80022c <_panic>
	}
	return;
}
  802891:	83 c4 1c             	add    $0x1c,%esp
  802894:	5b                   	pop    %ebx
  802895:	5e                   	pop    %esi
  802896:	5f                   	pop    %edi
  802897:	5d                   	pop    %ebp
  802898:	c3                   	ret    

00802899 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802899:	55                   	push   %ebp
  80289a:	89 e5                	mov    %esp,%ebp
  80289c:	53                   	push   %ebx
  80289d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8028a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028a5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8028ac:	89 c2                	mov    %eax,%edx
  8028ae:	c1 e2 07             	shl    $0x7,%edx
  8028b1:	29 ca                	sub    %ecx,%edx
  8028b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028b9:	8b 52 50             	mov    0x50(%edx),%edx
  8028bc:	39 da                	cmp    %ebx,%edx
  8028be:	75 0f                	jne    8028cf <ipc_find_env+0x36>
			return envs[i].env_id;
  8028c0:	c1 e0 07             	shl    $0x7,%eax
  8028c3:	29 c8                	sub    %ecx,%eax
  8028c5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8028ca:	8b 40 40             	mov    0x40(%eax),%eax
  8028cd:	eb 0c                	jmp    8028db <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028cf:	40                   	inc    %eax
  8028d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028d5:	75 ce                	jne    8028a5 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028d7:	66 b8 00 00          	mov    $0x0,%ax
}
  8028db:	5b                   	pop    %ebx
  8028dc:	5d                   	pop    %ebp
  8028dd:	c3                   	ret    
	...

008028e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028e0:	55                   	push   %ebp
  8028e1:	89 e5                	mov    %esp,%ebp
  8028e3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028e6:	89 c2                	mov    %eax,%edx
  8028e8:	c1 ea 16             	shr    $0x16,%edx
  8028eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028f2:	f6 c2 01             	test   $0x1,%dl
  8028f5:	74 1e                	je     802915 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028f7:	c1 e8 0c             	shr    $0xc,%eax
  8028fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802901:	a8 01                	test   $0x1,%al
  802903:	74 17                	je     80291c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802905:	c1 e8 0c             	shr    $0xc,%eax
  802908:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80290f:	ef 
  802910:	0f b7 c0             	movzwl %ax,%eax
  802913:	eb 0c                	jmp    802921 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802915:	b8 00 00 00 00       	mov    $0x0,%eax
  80291a:	eb 05                	jmp    802921 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80291c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802921:	5d                   	pop    %ebp
  802922:	c3                   	ret    
	...

00802924 <__udivdi3>:
  802924:	55                   	push   %ebp
  802925:	57                   	push   %edi
  802926:	56                   	push   %esi
  802927:	83 ec 10             	sub    $0x10,%esp
  80292a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80292e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802932:	89 74 24 04          	mov    %esi,0x4(%esp)
  802936:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80293a:	89 cd                	mov    %ecx,%ebp
  80293c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802940:	85 c0                	test   %eax,%eax
  802942:	75 2c                	jne    802970 <__udivdi3+0x4c>
  802944:	39 f9                	cmp    %edi,%ecx
  802946:	77 68                	ja     8029b0 <__udivdi3+0x8c>
  802948:	85 c9                	test   %ecx,%ecx
  80294a:	75 0b                	jne    802957 <__udivdi3+0x33>
  80294c:	b8 01 00 00 00       	mov    $0x1,%eax
  802951:	31 d2                	xor    %edx,%edx
  802953:	f7 f1                	div    %ecx
  802955:	89 c1                	mov    %eax,%ecx
  802957:	31 d2                	xor    %edx,%edx
  802959:	89 f8                	mov    %edi,%eax
  80295b:	f7 f1                	div    %ecx
  80295d:	89 c7                	mov    %eax,%edi
  80295f:	89 f0                	mov    %esi,%eax
  802961:	f7 f1                	div    %ecx
  802963:	89 c6                	mov    %eax,%esi
  802965:	89 f0                	mov    %esi,%eax
  802967:	89 fa                	mov    %edi,%edx
  802969:	83 c4 10             	add    $0x10,%esp
  80296c:	5e                   	pop    %esi
  80296d:	5f                   	pop    %edi
  80296e:	5d                   	pop    %ebp
  80296f:	c3                   	ret    
  802970:	39 f8                	cmp    %edi,%eax
  802972:	77 2c                	ja     8029a0 <__udivdi3+0x7c>
  802974:	0f bd f0             	bsr    %eax,%esi
  802977:	83 f6 1f             	xor    $0x1f,%esi
  80297a:	75 4c                	jne    8029c8 <__udivdi3+0xa4>
  80297c:	39 f8                	cmp    %edi,%eax
  80297e:	bf 00 00 00 00       	mov    $0x0,%edi
  802983:	72 0a                	jb     80298f <__udivdi3+0x6b>
  802985:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802989:	0f 87 ad 00 00 00    	ja     802a3c <__udivdi3+0x118>
  80298f:	be 01 00 00 00       	mov    $0x1,%esi
  802994:	89 f0                	mov    %esi,%eax
  802996:	89 fa                	mov    %edi,%edx
  802998:	83 c4 10             	add    $0x10,%esp
  80299b:	5e                   	pop    %esi
  80299c:	5f                   	pop    %edi
  80299d:	5d                   	pop    %ebp
  80299e:	c3                   	ret    
  80299f:	90                   	nop
  8029a0:	31 ff                	xor    %edi,%edi
  8029a2:	31 f6                	xor    %esi,%esi
  8029a4:	89 f0                	mov    %esi,%eax
  8029a6:	89 fa                	mov    %edi,%edx
  8029a8:	83 c4 10             	add    $0x10,%esp
  8029ab:	5e                   	pop    %esi
  8029ac:	5f                   	pop    %edi
  8029ad:	5d                   	pop    %ebp
  8029ae:	c3                   	ret    
  8029af:	90                   	nop
  8029b0:	89 fa                	mov    %edi,%edx
  8029b2:	89 f0                	mov    %esi,%eax
  8029b4:	f7 f1                	div    %ecx
  8029b6:	89 c6                	mov    %eax,%esi
  8029b8:	31 ff                	xor    %edi,%edi
  8029ba:	89 f0                	mov    %esi,%eax
  8029bc:	89 fa                	mov    %edi,%edx
  8029be:	83 c4 10             	add    $0x10,%esp
  8029c1:	5e                   	pop    %esi
  8029c2:	5f                   	pop    %edi
  8029c3:	5d                   	pop    %ebp
  8029c4:	c3                   	ret    
  8029c5:	8d 76 00             	lea    0x0(%esi),%esi
  8029c8:	89 f1                	mov    %esi,%ecx
  8029ca:	d3 e0                	shl    %cl,%eax
  8029cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029d0:	b8 20 00 00 00       	mov    $0x20,%eax
  8029d5:	29 f0                	sub    %esi,%eax
  8029d7:	89 ea                	mov    %ebp,%edx
  8029d9:	88 c1                	mov    %al,%cl
  8029db:	d3 ea                	shr    %cl,%edx
  8029dd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8029e1:	09 ca                	or     %ecx,%edx
  8029e3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8029e7:	89 f1                	mov    %esi,%ecx
  8029e9:	d3 e5                	shl    %cl,%ebp
  8029eb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8029ef:	89 fd                	mov    %edi,%ebp
  8029f1:	88 c1                	mov    %al,%cl
  8029f3:	d3 ed                	shr    %cl,%ebp
  8029f5:	89 fa                	mov    %edi,%edx
  8029f7:	89 f1                	mov    %esi,%ecx
  8029f9:	d3 e2                	shl    %cl,%edx
  8029fb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029ff:	88 c1                	mov    %al,%cl
  802a01:	d3 ef                	shr    %cl,%edi
  802a03:	09 d7                	or     %edx,%edi
  802a05:	89 f8                	mov    %edi,%eax
  802a07:	89 ea                	mov    %ebp,%edx
  802a09:	f7 74 24 08          	divl   0x8(%esp)
  802a0d:	89 d1                	mov    %edx,%ecx
  802a0f:	89 c7                	mov    %eax,%edi
  802a11:	f7 64 24 0c          	mull   0xc(%esp)
  802a15:	39 d1                	cmp    %edx,%ecx
  802a17:	72 17                	jb     802a30 <__udivdi3+0x10c>
  802a19:	74 09                	je     802a24 <__udivdi3+0x100>
  802a1b:	89 fe                	mov    %edi,%esi
  802a1d:	31 ff                	xor    %edi,%edi
  802a1f:	e9 41 ff ff ff       	jmp    802965 <__udivdi3+0x41>
  802a24:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a28:	89 f1                	mov    %esi,%ecx
  802a2a:	d3 e2                	shl    %cl,%edx
  802a2c:	39 c2                	cmp    %eax,%edx
  802a2e:	73 eb                	jae    802a1b <__udivdi3+0xf7>
  802a30:	8d 77 ff             	lea    -0x1(%edi),%esi
  802a33:	31 ff                	xor    %edi,%edi
  802a35:	e9 2b ff ff ff       	jmp    802965 <__udivdi3+0x41>
  802a3a:	66 90                	xchg   %ax,%ax
  802a3c:	31 f6                	xor    %esi,%esi
  802a3e:	e9 22 ff ff ff       	jmp    802965 <__udivdi3+0x41>
	...

00802a44 <__umoddi3>:
  802a44:	55                   	push   %ebp
  802a45:	57                   	push   %edi
  802a46:	56                   	push   %esi
  802a47:	83 ec 20             	sub    $0x20,%esp
  802a4a:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802a52:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a56:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802a62:	89 c7                	mov    %eax,%edi
  802a64:	89 f2                	mov    %esi,%edx
  802a66:	85 ed                	test   %ebp,%ebp
  802a68:	75 16                	jne    802a80 <__umoddi3+0x3c>
  802a6a:	39 f1                	cmp    %esi,%ecx
  802a6c:	0f 86 a6 00 00 00    	jbe    802b18 <__umoddi3+0xd4>
  802a72:	f7 f1                	div    %ecx
  802a74:	89 d0                	mov    %edx,%eax
  802a76:	31 d2                	xor    %edx,%edx
  802a78:	83 c4 20             	add    $0x20,%esp
  802a7b:	5e                   	pop    %esi
  802a7c:	5f                   	pop    %edi
  802a7d:	5d                   	pop    %ebp
  802a7e:	c3                   	ret    
  802a7f:	90                   	nop
  802a80:	39 f5                	cmp    %esi,%ebp
  802a82:	0f 87 ac 00 00 00    	ja     802b34 <__umoddi3+0xf0>
  802a88:	0f bd c5             	bsr    %ebp,%eax
  802a8b:	83 f0 1f             	xor    $0x1f,%eax
  802a8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a92:	0f 84 a8 00 00 00    	je     802b40 <__umoddi3+0xfc>
  802a98:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a9c:	d3 e5                	shl    %cl,%ebp
  802a9e:	bf 20 00 00 00       	mov    $0x20,%edi
  802aa3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802aa7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802aab:	89 f9                	mov    %edi,%ecx
  802aad:	d3 e8                	shr    %cl,%eax
  802aaf:	09 e8                	or     %ebp,%eax
  802ab1:	89 44 24 18          	mov    %eax,0x18(%esp)
  802ab5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ab9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802abd:	d3 e0                	shl    %cl,%eax
  802abf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ac3:	89 f2                	mov    %esi,%edx
  802ac5:	d3 e2                	shl    %cl,%edx
  802ac7:	8b 44 24 14          	mov    0x14(%esp),%eax
  802acb:	d3 e0                	shl    %cl,%eax
  802acd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802ad1:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ad5:	89 f9                	mov    %edi,%ecx
  802ad7:	d3 e8                	shr    %cl,%eax
  802ad9:	09 d0                	or     %edx,%eax
  802adb:	d3 ee                	shr    %cl,%esi
  802add:	89 f2                	mov    %esi,%edx
  802adf:	f7 74 24 18          	divl   0x18(%esp)
  802ae3:	89 d6                	mov    %edx,%esi
  802ae5:	f7 64 24 0c          	mull   0xc(%esp)
  802ae9:	89 c5                	mov    %eax,%ebp
  802aeb:	89 d1                	mov    %edx,%ecx
  802aed:	39 d6                	cmp    %edx,%esi
  802aef:	72 67                	jb     802b58 <__umoddi3+0x114>
  802af1:	74 75                	je     802b68 <__umoddi3+0x124>
  802af3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802af7:	29 e8                	sub    %ebp,%eax
  802af9:	19 ce                	sbb    %ecx,%esi
  802afb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802aff:	d3 e8                	shr    %cl,%eax
  802b01:	89 f2                	mov    %esi,%edx
  802b03:	89 f9                	mov    %edi,%ecx
  802b05:	d3 e2                	shl    %cl,%edx
  802b07:	09 d0                	or     %edx,%eax
  802b09:	89 f2                	mov    %esi,%edx
  802b0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b0f:	d3 ea                	shr    %cl,%edx
  802b11:	83 c4 20             	add    $0x20,%esp
  802b14:	5e                   	pop    %esi
  802b15:	5f                   	pop    %edi
  802b16:	5d                   	pop    %ebp
  802b17:	c3                   	ret    
  802b18:	85 c9                	test   %ecx,%ecx
  802b1a:	75 0b                	jne    802b27 <__umoddi3+0xe3>
  802b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  802b21:	31 d2                	xor    %edx,%edx
  802b23:	f7 f1                	div    %ecx
  802b25:	89 c1                	mov    %eax,%ecx
  802b27:	89 f0                	mov    %esi,%eax
  802b29:	31 d2                	xor    %edx,%edx
  802b2b:	f7 f1                	div    %ecx
  802b2d:	89 f8                	mov    %edi,%eax
  802b2f:	e9 3e ff ff ff       	jmp    802a72 <__umoddi3+0x2e>
  802b34:	89 f2                	mov    %esi,%edx
  802b36:	83 c4 20             	add    $0x20,%esp
  802b39:	5e                   	pop    %esi
  802b3a:	5f                   	pop    %edi
  802b3b:	5d                   	pop    %ebp
  802b3c:	c3                   	ret    
  802b3d:	8d 76 00             	lea    0x0(%esi),%esi
  802b40:	39 f5                	cmp    %esi,%ebp
  802b42:	72 04                	jb     802b48 <__umoddi3+0x104>
  802b44:	39 f9                	cmp    %edi,%ecx
  802b46:	77 06                	ja     802b4e <__umoddi3+0x10a>
  802b48:	89 f2                	mov    %esi,%edx
  802b4a:	29 cf                	sub    %ecx,%edi
  802b4c:	19 ea                	sbb    %ebp,%edx
  802b4e:	89 f8                	mov    %edi,%eax
  802b50:	83 c4 20             	add    $0x20,%esp
  802b53:	5e                   	pop    %esi
  802b54:	5f                   	pop    %edi
  802b55:	5d                   	pop    %ebp
  802b56:	c3                   	ret    
  802b57:	90                   	nop
  802b58:	89 d1                	mov    %edx,%ecx
  802b5a:	89 c5                	mov    %eax,%ebp
  802b5c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b60:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b64:	eb 8d                	jmp    802af3 <__umoddi3+0xaf>
  802b66:	66 90                	xchg   %ax,%ax
  802b68:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b6c:	72 ea                	jb     802b58 <__umoddi3+0x114>
  802b6e:	89 f1                	mov    %esi,%ecx
  802b70:	eb 81                	jmp    802af3 <__umoddi3+0xaf>
