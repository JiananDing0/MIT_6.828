
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 eb 01 00 00       	call   80021c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800044:	00 
  800045:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  80004c:	e8 24 1b 00 00       	call   801b75 <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 25 26 80 	movl   $0x802625,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 33 26 80 00 	movl   $0x802633,(%esp)
  800072:	e8 15 02 00 00       	call   80028c <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 ad 17 00 00       	call   801834 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 bf 16 00 00       	call   80175e <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 48 26 80 	movl   $0x802648,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 33 26 80 00 	movl   $0x802633,(%esp)
  8000c0:	e8 c7 01 00 00       	call   80028c <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 f1 0f 00 00       	call   8010bb <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 61 2b 80 	movl   $0x802b61,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 33 26 80 00 	movl   $0x802633,(%esp)
  8000eb:	e8 9c 01 00 00       	call   80028c <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 2c 17 00 00       	call   801834 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 88 26 80 00 	movl   $0x802688,(%esp)
  80010f:	e8 70 02 00 00       	call   800384 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 32 16 00 00       	call   80175e <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 cc 26 80 	movl   $0x8026cc,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 33 26 80 00 	movl   $0x802633,(%esp)
  80014f:	e8 38 01 00 00       	call   80028c <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  800167:	e8 e7 09 00 00       	call   800b53 <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 f8 26 80 	movl   $0x8026f8,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 33 26 80 00 	movl   $0x802633,(%esp)
  800187:	e8 00 01 00 00       	call   80028c <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 52 26 80 00 	movl   $0x802652,(%esp)
  800193:	e8 ec 01 00 00       	call   800384 <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 8c 16 00 00       	call   801834 <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 ba 13 00 00       	call   80156a <close>
		exit();
  8001b0:	e8 bb 00 00 00       	call   800270 <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 cf 1d 00 00       	call   801f8c <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 89 15 00 00       	call   80175e <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 30 27 80 	movl   $0x802730,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 33 26 80 00 	movl   $0x802633,(%esp)
  8001f8:	e8 8f 00 00 00       	call   80028c <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 6b 26 80 00 	movl   $0x80266b,(%esp)
  800204:	e8 7b 01 00 00       	call   800384 <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 59 13 00 00       	call   80156a <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800211:	cc                   	int3   

	breakpoint();
}
  800212:	83 c4 2c             	add    $0x2c,%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
	...

0080021c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 10             	sub    $0x10,%esp
  800224:	8b 75 08             	mov    0x8(%ebp),%esi
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80022a:	e8 d4 0a 00 00       	call   800d03 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80022f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80023b:	c1 e0 07             	shl    $0x7,%eax
  80023e:	29 d0                	sub    %edx,%eax
  800240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800245:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80024a:	85 f6                	test   %esi,%esi
  80024c:	7e 07                	jle    800255 <libmain+0x39>
		binaryname = argv[0];
  80024e:	8b 03                	mov    (%ebx),%eax
  800250:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	e8 d3 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800261:	e8 0a 00 00 00       	call   800270 <exit>
}
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800276:	e8 20 13 00 00       	call   80159b <close_all>
	sys_env_destroy(0);
  80027b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800282:	e8 2a 0a 00 00       	call   800cb1 <sys_env_destroy>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    
  800289:	00 00                	add    %al,(%eax)
	...

0080028c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800294:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800297:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80029d:	e8 61 0a 00 00       	call   800d03 <sys_getenvid>
  8002a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  8002bf:	e8 c0 00 00 00       	call   800384 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 50 00 00 00       	call   800323 <vcprintf>
	cprintf("\n");
  8002d3:	c7 04 24 69 26 80 00 	movl   $0x802669,(%esp)
  8002da:	e8 a5 00 00 00       	call   800384 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002df:	cc                   	int3   
  8002e0:	eb fd                	jmp    8002df <_panic+0x53>
	...

008002e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 14             	sub    $0x14,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f7:	40                   	inc    %eax
  8002f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ff:	75 19                	jne    80031a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800301:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800308:	00 
  800309:	8d 43 08             	lea    0x8(%ebx),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	e8 60 09 00 00       	call   800c74 <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031a:	ff 43 04             	incl   0x4(%ebx)
}
  80031d:	83 c4 14             	add    $0x14,%esp
  800320:	5b                   	pop    %ebx
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80032c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800333:	00 00 00 
	b.cnt = 0;
  800336:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	c7 04 24 e4 02 80 00 	movl   $0x8002e4,(%esp)
  80035f:	e8 82 01 00 00       	call   8004e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800364:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	e8 f8 08 00 00       	call   800c74 <sys_cputs>

	return b.cnt;
}
  80037c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	e8 87 ff ff ff       	call   800323 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    
	...

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	75 08                	jne    8003cc <printnum+0x2c>
  8003c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ca:	77 57                	ja     800423 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003d0:	4b                   	dec    %ebx
  8003d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003eb:	00 
  8003ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f9:	e8 ba 1f 00 00       	call   8023b8 <__udivdi3>
  8003fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800402:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	89 54 24 04          	mov    %edx,0x4(%esp)
  80040d:	89 fa                	mov    %edi,%edx
  80040f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800412:	e8 89 ff ff ff       	call   8003a0 <printnum>
  800417:	eb 0f                	jmp    800428 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800419:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041d:	89 34 24             	mov    %esi,(%esp)
  800420:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800423:	4b                   	dec    %ebx
  800424:	85 db                	test   %ebx,%ebx
  800426:	7f f1                	jg     800419 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800428:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800430:	8b 45 10             	mov    0x10(%ebp),%eax
  800433:	89 44 24 08          	mov    %eax,0x8(%esp)
  800437:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043e:	00 
  80043f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	e8 87 20 00 00       	call   8024d8 <__umoddi3>
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800455:	0f be 80 83 27 80 00 	movsbl 0x802783(%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800462:	83 c4 3c             	add    $0x3c,%esp
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046d:	83 fa 01             	cmp    $0x1,%edx
  800470:	7e 0e                	jle    800480 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 08             	lea    0x8(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	8b 52 04             	mov    0x4(%edx),%edx
  80047e:	eb 22                	jmp    8004a2 <getuint+0x38>
	else if (lflag)
  800480:	85 d2                	test   %edx,%edx
  800482:	74 10                	je     800494 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 04             	lea    0x4(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	eb 0e                	jmp    8004a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 4a 04             	lea    0x4(%edx),%ecx
  800499:	89 08                	mov    %ecx,(%eax)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    

008004a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004ad:	8b 10                	mov    (%eax),%edx
  8004af:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b2:	73 08                	jae    8004bc <sprintputch+0x18>
		*b->buf++ = ch;
  8004b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b7:	88 0a                	mov    %cl,(%edx)
  8004b9:	42                   	inc    %edx
  8004ba:	89 10                	mov    %edx,(%eax)
}
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 02 00 00 00       	call   8004e6 <vprintfmt>
	va_end(ap);
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 4c             	sub    $0x4c,%esp
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f5:	eb 12                	jmp    800509 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	0f 84 8b 03 00 00    	je     80088a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800509:	0f b6 06             	movzbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	83 f8 25             	cmp    $0x25,%eax
  800510:	75 e5                	jne    8004f7 <vprintfmt+0x11>
  800512:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800516:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80051d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800522:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800529:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052e:	eb 26                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800533:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800537:	eb 1d                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800540:	eb 14                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800545:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80054e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800551:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	0f b6 06             	movzbl (%esi),%eax
  800559:	8d 56 01             	lea    0x1(%esi),%edx
  80055c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055f:	8a 16                	mov    (%esi),%dl
  800561:	83 ea 23             	sub    $0x23,%edx
  800564:	80 fa 55             	cmp    $0x55,%dl
  800567:	0f 87 01 03 00 00    	ja     80086e <vprintfmt+0x388>
  80056d:	0f b6 d2             	movzbl %dl,%edx
  800570:	ff 24 95 c0 28 80 00 	jmp    *0x8028c0(,%edx,4)
  800577:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800582:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800586:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800589:	8d 50 d0             	lea    -0x30(%eax),%edx
  80058c:	83 fa 09             	cmp    $0x9,%edx
  80058f:	77 2a                	ja     8005bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800591:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800592:	eb eb                	jmp    80057f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a2:	eb 17                	jmp    8005bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a8:	78 98                	js     800542 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ad:	eb a7                	jmp    800556 <vprintfmt+0x70>
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005b9:	eb 9b                	jmp    800556 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bf:	79 95                	jns    800556 <vprintfmt+0x70>
  8005c1:	eb 8b                	jmp    80054e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005c7:	eb 8d                	jmp    800556 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e1:	e9 23 ff ff ff       	jmp    800509 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	79 02                	jns    8005f7 <vprintfmt+0x111>
  8005f5:	f7 d8                	neg    %eax
  8005f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f9:	83 f8 0f             	cmp    $0xf,%eax
  8005fc:	7f 0b                	jg     800609 <vprintfmt+0x123>
  8005fe:	8b 04 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	75 23                	jne    80062c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800609:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060d:	c7 44 24 08 9b 27 80 	movl   $0x80279b,0x8(%esp)
  800614:	00 
  800615:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 9a fe ff ff       	call   8004be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800627:	e9 dd fe ff ff       	jmp    800509 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80062c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800630:	c7 44 24 08 7a 2c 80 	movl   $0x802c7a,0x8(%esp)
  800637:	00 
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	8b 55 08             	mov    0x8(%ebp),%edx
  80063f:	89 14 24             	mov    %edx,(%esp)
  800642:	e8 77 fe ff ff       	call   8004be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064a:	e9 ba fe ff ff       	jmp    800509 <vprintfmt+0x23>
  80064f:	89 f9                	mov    %edi,%ecx
  800651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800654:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 30                	mov    (%eax),%esi
  800662:	85 f6                	test   %esi,%esi
  800664:	75 05                	jne    80066b <vprintfmt+0x185>
				p = "(null)";
  800666:	be 94 27 80 00       	mov    $0x802794,%esi
			if (width > 0 && padc != '-')
  80066b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80066f:	0f 8e 84 00 00 00    	jle    8006f9 <vprintfmt+0x213>
  800675:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800679:	74 7e                	je     8006f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067f:	89 34 24             	mov    %esi,(%esp)
  800682:	e8 ab 02 00 00       	call   800932 <strnlen>
  800687:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80068a:	29 c2                	sub    %eax,%edx
  80068c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80068f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800693:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800696:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800699:	89 de                	mov    %ebx,%esi
  80069b:	89 d3                	mov    %edx,%ebx
  80069d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	eb 0b                	jmp    8006ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a5:	89 3c 24             	mov    %edi,(%esp)
  8006a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	4b                   	dec    %ebx
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	7f f1                	jg     8006a1 <vprintfmt+0x1bb>
  8006b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006b3:	89 f3                	mov    %esi,%ebx
  8006b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	79 05                	jns    8006c4 <vprintfmt+0x1de>
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	29 c2                	sub    %eax,%edx
  8006c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006cc:	eb 2b                	jmp    8006f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d2:	74 18                	je     8006ec <vprintfmt+0x206>
  8006d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006d7:	83 fa 5e             	cmp    $0x5e,%edx
  8006da:	76 10                	jbe    8006ec <vprintfmt+0x206>
					putch('?', putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	eb 0a                	jmp    8006f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	89 04 24             	mov    %eax,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8006f9:	0f be 06             	movsbl (%esi),%eax
  8006fc:	46                   	inc    %esi
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 21                	je     800722 <vprintfmt+0x23c>
  800701:	85 ff                	test   %edi,%edi
  800703:	78 c9                	js     8006ce <vprintfmt+0x1e8>
  800705:	4f                   	dec    %edi
  800706:	79 c6                	jns    8006ce <vprintfmt+0x1e8>
  800708:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070b:	89 de                	mov    %ebx,%esi
  80070d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800710:	eb 18                	jmp    80072a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80071d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071f:	4b                   	dec    %ebx
  800720:	eb 08                	jmp    80072a <vprintfmt+0x244>
  800722:	8b 7d 08             	mov    0x8(%ebp),%edi
  800725:	89 de                	mov    %ebx,%esi
  800727:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80072a:	85 db                	test   %ebx,%ebx
  80072c:	7f e4                	jg     800712 <vprintfmt+0x22c>
  80072e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800731:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800736:	e9 ce fd ff ff       	jmp    800509 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073b:	83 f9 01             	cmp    $0x1,%ecx
  80073e:	7e 10                	jle    800750 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 08             	lea    0x8(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	8b 30                	mov    (%eax),%esi
  80074b:	8b 78 04             	mov    0x4(%eax),%edi
  80074e:	eb 26                	jmp    800776 <vprintfmt+0x290>
	else if (lflag)
  800750:	85 c9                	test   %ecx,%ecx
  800752:	74 12                	je     800766 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 30                	mov    (%eax),%esi
  80075f:	89 f7                	mov    %esi,%edi
  800761:	c1 ff 1f             	sar    $0x1f,%edi
  800764:	eb 10                	jmp    800776 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 50 04             	lea    0x4(%eax),%edx
  80076c:	89 55 14             	mov    %edx,0x14(%ebp)
  80076f:	8b 30                	mov    (%eax),%esi
  800771:	89 f7                	mov    %esi,%edi
  800773:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800776:	85 ff                	test   %edi,%edi
  800778:	78 0a                	js     800784 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 ac 00 00 00       	jmp    800830 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800792:	f7 de                	neg    %esi
  800794:	83 d7 00             	adc    $0x0,%edi
  800797:	f7 df                	neg    %edi
			}
			base = 10;
  800799:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079e:	e9 8d 00 00 00       	jmp    800830 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a3:	89 ca                	mov    %ecx,%edx
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a8:	e8 bd fc ff ff       	call   80046a <getuint>
  8007ad:	89 c6                	mov    %eax,%esi
  8007af:	89 d7                	mov    %edx,%edi
			base = 10;
  8007b1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b6:	eb 78                	jmp    800830 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8007c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ca:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007d1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8007d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007e5:	e9 1f fd ff ff       	jmp    800509 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80080f:	8b 30                	mov    (%eax),%esi
  800811:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800816:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80081b:	eb 13                	jmp    800830 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80081d:	89 ca                	mov    %ecx,%edx
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
  800822:	e8 43 fc ff ff       	call   80046a <getuint>
  800827:	89 c6                	mov    %eax,%esi
  800829:	89 d7                	mov    %edx,%edi
			base = 16;
  80082b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800830:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800834:	89 54 24 10          	mov    %edx,0x10(%esp)
  800838:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80083b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80083f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800843:	89 34 24             	mov    %esi,(%esp)
  800846:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084a:	89 da                	mov    %ebx,%edx
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	e8 4c fb ff ff       	call   8003a0 <printnum>
			break;
  800854:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800857:	e9 ad fc ff ff       	jmp    800509 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800866:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800869:	e9 9b fc ff ff       	jmp    800509 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800872:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800879:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087c:	eb 01                	jmp    80087f <vprintfmt+0x399>
  80087e:	4e                   	dec    %esi
  80087f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800883:	75 f9                	jne    80087e <vprintfmt+0x398>
  800885:	e9 7f fc ff ff       	jmp    800509 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80088a:	83 c4 4c             	add    $0x4c,%esp
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5f                   	pop    %edi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	83 ec 28             	sub    $0x28,%esp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	74 30                	je     8008e3 <vsnprintf+0x51>
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	7e 33                	jle    8008ea <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008be:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cc:	c7 04 24 a4 04 80 00 	movl   $0x8004a4,(%esp)
  8008d3:	e8 0e fc ff ff       	call   8004e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e1:	eb 0c                	jmp    8008ef <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e8:	eb 05                	jmp    8008ef <vsnprintf+0x5d>
  8008ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800901:	89 44 24 08          	mov    %eax,0x8(%esp)
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	e8 7b ff ff ff       	call   800892 <vsnprintf>
	va_end(ap);

	return rc;
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    
  800919:	00 00                	add    %al,(%eax)
	...

0080091c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 01                	jmp    80092a <strlen+0xe>
		n++;
  800929:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80092e:	75 f9                	jne    800929 <strlen+0xd>
		n++;
	return n;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	eb 01                	jmp    800943 <strnlen+0x11>
		n++;
  800942:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800943:	39 d0                	cmp    %edx,%eax
  800945:	74 06                	je     80094d <strnlen+0x1b>
  800947:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80094b:	75 f5                	jne    800942 <strnlen+0x10>
		n++;
	return n;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800961:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800964:	42                   	inc    %edx
  800965:	84 c9                	test   %cl,%cl
  800967:	75 f5                	jne    80095e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800969:	5b                   	pop    %ebx
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	53                   	push   %ebx
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800976:	89 1c 24             	mov    %ebx,(%esp)
  800979:	e8 9e ff ff ff       	call   80091c <strlen>
	strcpy(dst + len, src);
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	89 54 24 04          	mov    %edx,0x4(%esp)
  800985:	01 d8                	add    %ebx,%eax
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	e8 c0 ff ff ff       	call   80094f <strcpy>
	return dst;
}
  80098f:	89 d8                	mov    %ebx,%eax
  800991:	83 c4 08             	add    $0x8,%esp
  800994:	5b                   	pop    %ebx
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009aa:	eb 0c                	jmp    8009b8 <strncpy+0x21>
		*dst++ = *src;
  8009ac:	8a 1a                	mov    (%edx),%bl
  8009ae:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b1:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b7:	41                   	inc    %ecx
  8009b8:	39 f1                	cmp    %esi,%ecx
  8009ba:	75 f0                	jne    8009ac <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	75 0a                	jne    8009dc <strlcpy+0x1c>
  8009d2:	89 f0                	mov    %esi,%eax
  8009d4:	eb 1a                	jmp    8009f0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d6:	88 18                	mov    %bl,(%eax)
  8009d8:	40                   	inc    %eax
  8009d9:	41                   	inc    %ecx
  8009da:	eb 02                	jmp    8009de <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009dc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009de:	4a                   	dec    %edx
  8009df:	74 0a                	je     8009eb <strlcpy+0x2b>
  8009e1:	8a 19                	mov    (%ecx),%bl
  8009e3:	84 db                	test   %bl,%bl
  8009e5:	75 ef                	jne    8009d6 <strlcpy+0x16>
  8009e7:	89 c2                	mov    %eax,%edx
  8009e9:	eb 02                	jmp    8009ed <strlcpy+0x2d>
  8009eb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009ed:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009f0:	29 f0                	sub    %esi,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ff:	eb 02                	jmp    800a03 <strcmp+0xd>
		p++, q++;
  800a01:	41                   	inc    %ecx
  800a02:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a03:	8a 01                	mov    (%ecx),%al
  800a05:	84 c0                	test   %al,%al
  800a07:	74 04                	je     800a0d <strcmp+0x17>
  800a09:	3a 02                	cmp    (%edx),%al
  800a0b:	74 f4                	je     800a01 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0d:	0f b6 c0             	movzbl %al,%eax
  800a10:	0f b6 12             	movzbl (%edx),%edx
  800a13:	29 d0                	sub    %edx,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a21:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a24:	eb 03                	jmp    800a29 <strncmp+0x12>
		n--, p++, q++;
  800a26:	4a                   	dec    %edx
  800a27:	40                   	inc    %eax
  800a28:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a29:	85 d2                	test   %edx,%edx
  800a2b:	74 14                	je     800a41 <strncmp+0x2a>
  800a2d:	8a 18                	mov    (%eax),%bl
  800a2f:	84 db                	test   %bl,%bl
  800a31:	74 04                	je     800a37 <strncmp+0x20>
  800a33:	3a 19                	cmp    (%ecx),%bl
  800a35:	74 ef                	je     800a26 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	0f b6 00             	movzbl (%eax),%eax
  800a3a:	0f b6 11             	movzbl (%ecx),%edx
  800a3d:	29 d0                	sub    %edx,%eax
  800a3f:	eb 05                	jmp    800a46 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a52:	eb 05                	jmp    800a59 <strchr+0x10>
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 0c                	je     800a64 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a58:	40                   	inc    %eax
  800a59:	8a 10                	mov    (%eax),%dl
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	75 f5                	jne    800a54 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6f:	eb 05                	jmp    800a76 <strfind+0x10>
		if (*s == c)
  800a71:	38 ca                	cmp    %cl,%dl
  800a73:	74 07                	je     800a7c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a75:	40                   	inc    %eax
  800a76:	8a 10                	mov    (%eax),%dl
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f5                	jne    800a71 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8d:	85 c9                	test   %ecx,%ecx
  800a8f:	74 30                	je     800ac1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a97:	75 25                	jne    800abe <memset+0x40>
  800a99:	f6 c1 03             	test   $0x3,%cl
  800a9c:	75 20                	jne    800abe <memset+0x40>
		c &= 0xFF;
  800a9e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa1:	89 d3                	mov    %edx,%ebx
  800aa3:	c1 e3 08             	shl    $0x8,%ebx
  800aa6:	89 d6                	mov    %edx,%esi
  800aa8:	c1 e6 18             	shl    $0x18,%esi
  800aab:	89 d0                	mov    %edx,%eax
  800aad:	c1 e0 10             	shl    $0x10,%eax
  800ab0:	09 f0                	or     %esi,%eax
  800ab2:	09 d0                	or     %edx,%eax
  800ab4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab9:	fc                   	cld    
  800aba:	f3 ab                	rep stos %eax,%es:(%edi)
  800abc:	eb 03                	jmp    800ac1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abe:	fc                   	cld    
  800abf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac1:	89 f8                	mov    %edi,%eax
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad6:	39 c6                	cmp    %eax,%esi
  800ad8:	73 34                	jae    800b0e <memmove+0x46>
  800ada:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	73 2d                	jae    800b0e <memmove+0x46>
		s += n;
		d += n;
  800ae1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae4:	f6 c2 03             	test   $0x3,%dl
  800ae7:	75 1b                	jne    800b04 <memmove+0x3c>
  800ae9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aef:	75 13                	jne    800b04 <memmove+0x3c>
  800af1:	f6 c1 03             	test   $0x3,%cl
  800af4:	75 0e                	jne    800b04 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af6:	83 ef 04             	sub    $0x4,%edi
  800af9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aff:	fd                   	std    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 07                	jmp    800b0b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b04:	4f                   	dec    %edi
  800b05:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b08:	fd                   	std    
  800b09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0b:	fc                   	cld    
  800b0c:	eb 20                	jmp    800b2e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b14:	75 13                	jne    800b29 <memmove+0x61>
  800b16:	a8 03                	test   $0x3,%al
  800b18:	75 0f                	jne    800b29 <memmove+0x61>
  800b1a:	f6 c1 03             	test   $0x3,%cl
  800b1d:	75 0a                	jne    800b29 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b22:	89 c7                	mov    %eax,%edi
  800b24:	fc                   	cld    
  800b25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b27:	eb 05                	jmp    800b2e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	fc                   	cld    
  800b2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b38:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	89 04 24             	mov    %eax,(%esp)
  800b4c:	e8 77 ff ff ff       	call   800ac8 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	eb 16                	jmp    800b7f <memcmp+0x2c>
		if (*s1 != *s2)
  800b69:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b6c:	42                   	inc    %edx
  800b6d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b71:	38 c8                	cmp    %cl,%al
  800b73:	74 0a                	je     800b7f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b75:	0f b6 c0             	movzbl %al,%eax
  800b78:	0f b6 c9             	movzbl %cl,%ecx
  800b7b:	29 c8                	sub    %ecx,%eax
  800b7d:	eb 09                	jmp    800b88 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7f:	39 da                	cmp    %ebx,%edx
  800b81:	75 e6                	jne    800b69 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9b:	eb 05                	jmp    800ba2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9d:	38 08                	cmp    %cl,(%eax)
  800b9f:	74 05                	je     800ba6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba1:	40                   	inc    %eax
  800ba2:	39 d0                	cmp    %edx,%eax
  800ba4:	72 f7                	jb     800b9d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb4:	eb 01                	jmp    800bb7 <strtol+0xf>
		s++;
  800bb6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb7:	8a 02                	mov    (%edx),%al
  800bb9:	3c 20                	cmp    $0x20,%al
  800bbb:	74 f9                	je     800bb6 <strtol+0xe>
  800bbd:	3c 09                	cmp    $0x9,%al
  800bbf:	74 f5                	je     800bb6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc1:	3c 2b                	cmp    $0x2b,%al
  800bc3:	75 08                	jne    800bcd <strtol+0x25>
		s++;
  800bc5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcb:	eb 13                	jmp    800be0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bcd:	3c 2d                	cmp    $0x2d,%al
  800bcf:	75 0a                	jne    800bdb <strtol+0x33>
		s++, neg = 1;
  800bd1:	8d 52 01             	lea    0x1(%edx),%edx
  800bd4:	bf 01 00 00 00       	mov    $0x1,%edi
  800bd9:	eb 05                	jmp    800be0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be0:	85 db                	test   %ebx,%ebx
  800be2:	74 05                	je     800be9 <strtol+0x41>
  800be4:	83 fb 10             	cmp    $0x10,%ebx
  800be7:	75 28                	jne    800c11 <strtol+0x69>
  800be9:	8a 02                	mov    (%edx),%al
  800beb:	3c 30                	cmp    $0x30,%al
  800bed:	75 10                	jne    800bff <strtol+0x57>
  800bef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf3:	75 0a                	jne    800bff <strtol+0x57>
		s += 2, base = 16;
  800bf5:	83 c2 02             	add    $0x2,%edx
  800bf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfd:	eb 12                	jmp    800c11 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bff:	85 db                	test   %ebx,%ebx
  800c01:	75 0e                	jne    800c11 <strtol+0x69>
  800c03:	3c 30                	cmp    $0x30,%al
  800c05:	75 05                	jne    800c0c <strtol+0x64>
		s++, base = 8;
  800c07:	42                   	inc    %edx
  800c08:	b3 08                	mov    $0x8,%bl
  800c0a:	eb 05                	jmp    800c11 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
  800c16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c18:	8a 0a                	mov    (%edx),%cl
  800c1a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c1d:	80 fb 09             	cmp    $0x9,%bl
  800c20:	77 08                	ja     800c2a <strtol+0x82>
			dig = *s - '0';
  800c22:	0f be c9             	movsbl %cl,%ecx
  800c25:	83 e9 30             	sub    $0x30,%ecx
  800c28:	eb 1e                	jmp    800c48 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c2a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c2d:	80 fb 19             	cmp    $0x19,%bl
  800c30:	77 08                	ja     800c3a <strtol+0x92>
			dig = *s - 'a' + 10;
  800c32:	0f be c9             	movsbl %cl,%ecx
  800c35:	83 e9 57             	sub    $0x57,%ecx
  800c38:	eb 0e                	jmp    800c48 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c3a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 12                	ja     800c54 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c42:	0f be c9             	movsbl %cl,%ecx
  800c45:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c48:	39 f1                	cmp    %esi,%ecx
  800c4a:	7d 0c                	jge    800c58 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c4c:	42                   	inc    %edx
  800c4d:	0f af c6             	imul   %esi,%eax
  800c50:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c52:	eb c4                	jmp    800c18 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c54:	89 c1                	mov    %eax,%ecx
  800c56:	eb 02                	jmp    800c5a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c58:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5e:	74 05                	je     800c65 <strtol+0xbd>
		*endptr = (char *) s;
  800c60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c63:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c65:	85 ff                	test   %edi,%edi
  800c67:	74 04                	je     800c6d <strtol+0xc5>
  800c69:	89 c8                	mov    %ecx,%eax
  800c6b:	f7 d8                	neg    %eax
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
	...

00800c74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 c3                	mov    %eax,%ebx
  800c87:	89 c7                	mov    %eax,%edi
  800c89:	89 c6                	mov    %eax,%esi
  800c8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 cb                	mov    %ecx,%ebx
  800cc9:	89 cf                	mov    %ecx,%edi
  800ccb:	89 ce                	mov    %ecx,%esi
  800ccd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 28                	jle    800cfb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cde:	00 
  800cdf:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cee:	00 
  800cef:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800cf6:	e8 91 f5 ff ff       	call   80028c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfb:	83 c4 2c             	add    $0x2c,%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	89 d3                	mov    %edx,%ebx
  800d17:	89 d7                	mov    %edx,%edi
  800d19:	89 d6                	mov    %edx,%esi
  800d1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_yield>:

void
sys_yield(void)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	be 00 00 00 00       	mov    $0x0,%esi
  800d4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 f7                	mov    %esi,%edi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800d88:	e8 ff f4 ff ff       	call   80028c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800da3:	8b 75 18             	mov    0x18(%ebp),%esi
  800da6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7e 28                	jle    800de0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd3:	00 
  800dd4:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800ddb:	e8 ac f4 ff ff       	call   80028c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de0:	83 c4 2c             	add    $0x2c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 28                	jle    800e33 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e16:	00 
  800e17:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e26:	00 
  800e27:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e2e:	e8 59 f4 ff ff       	call   80028c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e33:	83 c4 2c             	add    $0x2c,%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e49:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	89 df                	mov    %ebx,%edi
  800e56:	89 de                	mov    %ebx,%esi
  800e58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	7e 28                	jle    800e86 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e62:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e69:	00 
  800e6a:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e71:	00 
  800e72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e79:	00 
  800e7a:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e81:	e8 06 f4 ff ff       	call   80028c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e86:	83 c4 2c             	add    $0x2c,%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 28                	jle    800ed9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800ed4:	e8 b3 f3 ff ff       	call   80028c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed9:	83 c4 2c             	add    $0x2c,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 df                	mov    %ebx,%edi
  800efc:	89 de                	mov    %ebx,%esi
  800efe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	7e 28                	jle    800f2c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f08:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f0f:	00 
  800f10:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1f:	00 
  800f20:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800f27:	e8 60 f3 ff ff       	call   80028c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2c:	83 c4 2c             	add    $0x2c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3a:	be 00 00 00 00       	mov    $0x0,%esi
  800f3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f65:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6d:	89 cb                	mov    %ecx,%ebx
  800f6f:	89 cf                	mov    %ecx,%edi
  800f71:	89 ce                	mov    %ecx,%esi
  800f73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	7e 28                	jle    800fa1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800f9c:	e8 eb f2 ff ff       	call   80028c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa1:	83 c4 2c             	add    $0x2c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	00 00                	add    %al,(%eax)
	...

00800fac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 24             	sub    $0x24,%esp
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fb6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800fb8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbc:	75 20                	jne    800fde <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800fbe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fc2:	c7 44 24 08 ac 2a 80 	movl   $0x802aac,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  800fd9:	e8 ae f2 ff ff       	call   80028c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fde:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff0:	f6 c4 08             	test   $0x8,%ah
  800ff3:	75 1c                	jne    801011 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ff5:	c7 44 24 08 dc 2a 80 	movl   $0x802adc,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  80100c:	e8 7b f2 ff ff       	call   80028c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  801011:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801028:	e8 14 fd ff ff       	call   800d41 <sys_page_alloc>
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 20                	jns    801051 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  801031:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801035:	c7 44 24 08 36 2b 80 	movl   $0x802b36,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  80104c:	e8 3b f2 ff ff       	call   80028c <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  801051:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801058:	00 
  801059:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80105d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801064:	e8 5f fa ff ff       	call   800ac8 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  801069:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801070:	00 
  801071:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801075:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107c:	00 
  80107d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801084:	00 
  801085:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108c:	e8 04 fd ff ff       	call   800d95 <sys_page_map>
  801091:	85 c0                	test   %eax,%eax
  801093:	79 20                	jns    8010b5 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  801095:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801099:	c7 44 24 08 49 2b 80 	movl   $0x802b49,0x8(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  8010b0:	e8 d7 f1 ff ff       	call   80028c <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  8010b5:	83 c4 24             	add    $0x24,%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  8010c4:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  8010cb:	e8 c8 10 00 00       	call   802198 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010d0:	ba 07 00 00 00       	mov    $0x7,%edx
  8010d5:	89 d0                	mov    %edx,%eax
  8010d7:	cd 30                	int    $0x30
  8010d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	79 20                	jns    801103 <fork+0x48>
		panic("sys_exofork: %e", envid);
  8010e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e7:	c7 44 24 08 5a 2b 80 	movl   $0x802b5a,0x8(%esp)
  8010ee:	00 
  8010ef:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8010f6:	00 
  8010f7:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  8010fe:	e8 89 f1 ff ff       	call   80028c <_panic>
	}
	
	// Child process
	if (envid == 0) {
  801103:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801107:	75 25                	jne    80112e <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801109:	e8 f5 fb ff ff       	call   800d03 <sys_getenvid>
  80110e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801113:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80111a:	c1 e0 07             	shl    $0x7,%eax
  80111d:	29 d0                	sub    %edx,%eax
  80111f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801124:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  801129:	e9 58 02 00 00       	jmp    801386 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  80112e:	bf 00 00 00 00       	mov    $0x0,%edi
  801133:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801138:	89 f0                	mov    %esi,%eax
  80113a:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80113d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801144:	a8 01                	test   $0x1,%al
  801146:	0f 84 7a 01 00 00    	je     8012c6 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80114c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801153:	a8 01                	test   $0x1,%al
  801155:	0f 84 6b 01 00 00    	je     8012c6 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80115b:	a1 20 44 80 00       	mov    0x804420,%eax
  801160:	8b 40 48             	mov    0x48(%eax),%eax
  801163:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801166:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116d:	f6 c4 04             	test   $0x4,%ah
  801170:	74 52                	je     8011c4 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801172:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801179:	25 07 0e 00 00       	and    $0xe07,%eax
  80117e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801182:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801186:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801189:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801191:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801194:	89 04 24             	mov    %eax,(%esp)
  801197:	e8 f9 fb ff ff       	call   800d95 <sys_page_map>
  80119c:	85 c0                	test   %eax,%eax
  80119e:	0f 89 22 01 00 00    	jns    8012c6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a8:	c7 44 24 08 6a 2b 80 	movl   $0x802b6a,0x8(%esp)
  8011af:	00 
  8011b0:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8011b7:	00 
  8011b8:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  8011bf:	e8 c8 f0 ff ff       	call   80028c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8011c4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011cb:	f6 c4 08             	test   $0x8,%ah
  8011ce:	75 0f                	jne    8011df <fork+0x124>
  8011d0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d7:	a8 02                	test   $0x2,%al
  8011d9:	0f 84 99 00 00 00    	je     801278 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8011df:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011e6:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011e9:	83 f8 01             	cmp    $0x1,%eax
  8011ec:	19 db                	sbb    %ebx,%ebx
  8011ee:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011f1:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011f7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801202:	89 44 24 08          	mov    %eax,0x8(%esp)
  801206:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120d:	89 04 24             	mov    %eax,(%esp)
  801210:	e8 80 fb ff ff       	call   800d95 <sys_page_map>
  801215:	85 c0                	test   %eax,%eax
  801217:	79 20                	jns    801239 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121d:	c7 44 24 08 6a 2b 80 	movl   $0x802b6a,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80122c:	00 
  80122d:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  801234:	e8 53 f0 ff ff       	call   80028c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801239:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80123d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801244:	89 44 24 08          	mov    %eax,0x8(%esp)
  801248:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80124c:	89 04 24             	mov    %eax,(%esp)
  80124f:	e8 41 fb ff ff       	call   800d95 <sys_page_map>
  801254:	85 c0                	test   %eax,%eax
  801256:	79 6e                	jns    8012c6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801258:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125c:	c7 44 24 08 6a 2b 80 	movl   $0x802b6a,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  801273:	e8 14 f0 ff ff       	call   80028c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801278:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80127f:	25 07 0e 00 00       	and    $0xe07,%eax
  801284:	89 44 24 10          	mov    %eax,0x10(%esp)
  801288:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80128c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801293:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	e8 f3 fa ff ff       	call   800d95 <sys_page_map>
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	79 20                	jns    8012c6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8012a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012aa:	c7 44 24 08 6a 2b 80 	movl   $0x802b6a,0x8(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8012b9:	00 
  8012ba:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  8012c1:	e8 c6 ef ff ff       	call   80028c <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8012c6:	46                   	inc    %esi
  8012c7:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012cd:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8012d3:	0f 85 5f fe ff ff    	jne    801138 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8012d9:	c7 44 24 04 38 22 80 	movl   $0x802238,0x4(%esp)
  8012e0:	00 
  8012e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	e8 f5 fb ff ff       	call   800ee1 <sys_env_set_pgfault_upcall>
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	79 20                	jns    801310 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8012f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f4:	c7 44 24 08 0c 2b 80 	movl   $0x802b0c,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  80130b:	e8 7c ef ff ff       	call   80028c <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801310:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80131f:	ee 
  801320:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801323:	89 04 24             	mov    %eax,(%esp)
  801326:	e8 16 fa ff ff       	call   800d41 <sys_page_alloc>
  80132b:	85 c0                	test   %eax,%eax
  80132d:	79 20                	jns    80134f <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80132f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801333:	c7 44 24 08 36 2b 80 	movl   $0x802b36,0x8(%esp)
  80133a:	00 
  80133b:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801342:	00 
  801343:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  80134a:	e8 3d ef ff ff       	call   80028c <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80134f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801356:	00 
  801357:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80135a:	89 04 24             	mov    %eax,(%esp)
  80135d:	e8 d9 fa ff ff       	call   800e3b <sys_env_set_status>
  801362:	85 c0                	test   %eax,%eax
  801364:	79 20                	jns    801386 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801366:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136a:	c7 44 24 08 7c 2b 80 	movl   $0x802b7c,0x8(%esp)
  801371:	00 
  801372:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801379:	00 
  80137a:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  801381:	e8 06 ef ff ff       	call   80028c <_panic>
	}
	
	return envid;
}
  801386:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801389:	83 c4 3c             	add    $0x3c,%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <sfork>:

// Challenge!
int
sfork(void)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801397:	c7 44 24 08 93 2b 80 	movl   $0x802b93,0x8(%esp)
  80139e:	00 
  80139f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8013a6:	00 
  8013a7:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  8013ae:	e8 d9 ee ff ff       	call   80028c <_panic>
	...

008013b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8013bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 df ff ff ff       	call   8013b4 <fd2num>
  8013d5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013da:	c1 e0 0c             	shl    $0xc,%eax
}
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013eb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	c1 ea 16             	shr    $0x16,%edx
  8013f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f9:	f6 c2 01             	test   $0x1,%dl
  8013fc:	74 11                	je     80140f <fd_alloc+0x30>
  8013fe:	89 c2                	mov    %eax,%edx
  801400:	c1 ea 0c             	shr    $0xc,%edx
  801403:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140a:	f6 c2 01             	test   $0x1,%dl
  80140d:	75 09                	jne    801418 <fd_alloc+0x39>
			*fd_store = fd;
  80140f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
  801416:	eb 17                	jmp    80142f <fd_alloc+0x50>
  801418:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80141d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801422:	75 c7                	jne    8013eb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801424:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80142a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80142f:	5b                   	pop    %ebx
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801438:	83 f8 1f             	cmp    $0x1f,%eax
  80143b:	77 36                	ja     801473 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80143d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801442:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 16             	shr    $0x16,%edx
  80144a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 24                	je     80147a <fd_lookup+0x48>
  801456:	89 c2                	mov    %eax,%edx
  801458:	c1 ea 0c             	shr    $0xc,%edx
  80145b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801462:	f6 c2 01             	test   $0x1,%dl
  801465:	74 1a                	je     801481 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146a:	89 02                	mov    %eax,(%edx)
	return 0;
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	eb 13                	jmp    801486 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801478:	eb 0c                	jmp    801486 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147f:	eb 05                	jmp    801486 <fd_lookup+0x54>
  801481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	eb 0e                	jmp    8014aa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80149c:	39 08                	cmp    %ecx,(%eax)
  80149e:	75 09                	jne    8014a9 <dev_lookup+0x21>
			*dev = devtab[i];
  8014a0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a7:	eb 33                	jmp    8014dc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a9:	42                   	inc    %edx
  8014aa:	8b 04 95 28 2c 80 00 	mov    0x802c28(,%edx,4),%eax
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	75 e7                	jne    80149c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b5:	a1 20 44 80 00       	mov    0x804420,%eax
  8014ba:	8b 40 48             	mov    0x48(%eax),%eax
  8014bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c5:	c7 04 24 ac 2b 80 00 	movl   $0x802bac,(%esp)
  8014cc:	e8 b3 ee ff ff       	call   800384 <cprintf>
	*dev = 0;
  8014d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014dc:	83 c4 14             	add    $0x14,%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	56                   	push   %esi
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 30             	sub    $0x30,%esp
  8014ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ed:	8a 45 0c             	mov    0xc(%ebp),%al
  8014f0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f3:	89 34 24             	mov    %esi,(%esp)
  8014f6:	e8 b9 fe ff ff       	call   8013b4 <fd2num>
  8014fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801502:	89 04 24             	mov    %eax,(%esp)
  801505:	e8 28 ff ff ff       	call   801432 <fd_lookup>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 05                	js     801515 <fd_close+0x33>
	    || fd != fd2)
  801510:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801513:	74 0d                	je     801522 <fd_close+0x40>
		return (must_exist ? r : 0);
  801515:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801519:	75 46                	jne    801561 <fd_close+0x7f>
  80151b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801520:	eb 3f                	jmp    801561 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801522:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801525:	89 44 24 04          	mov    %eax,0x4(%esp)
  801529:	8b 06                	mov    (%esi),%eax
  80152b:	89 04 24             	mov    %eax,(%esp)
  80152e:	e8 55 ff ff ff       	call   801488 <dev_lookup>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 18                	js     801551 <fd_close+0x6f>
		if (dev->dev_close)
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	8b 40 10             	mov    0x10(%eax),%eax
  80153f:	85 c0                	test   %eax,%eax
  801541:	74 09                	je     80154c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801543:	89 34 24             	mov    %esi,(%esp)
  801546:	ff d0                	call   *%eax
  801548:	89 c3                	mov    %eax,%ebx
  80154a:	eb 05                	jmp    801551 <fd_close+0x6f>
		else
			r = 0;
  80154c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801551:	89 74 24 04          	mov    %esi,0x4(%esp)
  801555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80155c:	e8 87 f8 ff ff       	call   800de8 <sys_page_unmap>
	return r;
}
  801561:	89 d8                	mov    %ebx,%eax
  801563:	83 c4 30             	add    $0x30,%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	89 44 24 04          	mov    %eax,0x4(%esp)
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	e8 b0 fe ff ff       	call   801432 <fd_lookup>
  801582:	85 c0                	test   %eax,%eax
  801584:	78 13                	js     801599 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801586:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80158d:	00 
  80158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801591:	89 04 24             	mov    %eax,(%esp)
  801594:	e8 49 ff ff ff       	call   8014e2 <fd_close>
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <close_all>:

void
close_all(void)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	53                   	push   %ebx
  80159f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a7:	89 1c 24             	mov    %ebx,(%esp)
  8015aa:	e8 bb ff ff ff       	call   80156a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015af:	43                   	inc    %ebx
  8015b0:	83 fb 20             	cmp    $0x20,%ebx
  8015b3:	75 f2                	jne    8015a7 <close_all+0xc>
		close(i);
}
  8015b5:	83 c4 14             	add    $0x14,%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    

008015bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 4c             	sub    $0x4c,%esp
  8015c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d1:	89 04 24             	mov    %eax,(%esp)
  8015d4:	e8 59 fe ff ff       	call   801432 <fd_lookup>
  8015d9:	89 c3                	mov    %eax,%ebx
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	0f 88 e1 00 00 00    	js     8016c4 <dup+0x109>
		return r;
	close(newfdnum);
  8015e3:	89 3c 24             	mov    %edi,(%esp)
  8015e6:	e8 7f ff ff ff       	call   80156a <close>

	newfd = INDEX2FD(newfdnum);
  8015eb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015f1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f7:	89 04 24             	mov    %eax,(%esp)
  8015fa:	e8 c5 fd ff ff       	call   8013c4 <fd2data>
  8015ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801601:	89 34 24             	mov    %esi,(%esp)
  801604:	e8 bb fd ff ff       	call   8013c4 <fd2data>
  801609:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	c1 e8 16             	shr    $0x16,%eax
  801611:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801618:	a8 01                	test   $0x1,%al
  80161a:	74 46                	je     801662 <dup+0xa7>
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801628:	f6 c2 01             	test   $0x1,%dl
  80162b:	74 35                	je     801662 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80162d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801634:	25 07 0e 00 00       	and    $0xe07,%eax
  801639:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801640:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801644:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164b:	00 
  80164c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801657:	e8 39 f7 ff ff       	call   800d95 <sys_page_map>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 3b                	js     80169d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801665:	89 c2                	mov    %eax,%edx
  801667:	c1 ea 0c             	shr    $0xc,%edx
  80166a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801671:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801677:	89 54 24 10          	mov    %edx,0x10(%esp)
  80167b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80167f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801686:	00 
  801687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801692:	e8 fe f6 ff ff       	call   800d95 <sys_page_map>
  801697:	89 c3                	mov    %eax,%ebx
  801699:	85 c0                	test   %eax,%eax
  80169b:	79 25                	jns    8016c2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80169d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a8:	e8 3b f7 ff ff       	call   800de8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bb:	e8 28 f7 ff ff       	call   800de8 <sys_page_unmap>
	return r;
  8016c0:	eb 02                	jmp    8016c4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016c2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	83 c4 4c             	add    $0x4c,%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 24             	sub    $0x24,%esp
  8016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016df:	89 1c 24             	mov    %ebx,(%esp)
  8016e2:	e8 4b fd ff ff       	call   801432 <fd_lookup>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 6d                	js     801758 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	8b 00                	mov    (%eax),%eax
  8016f7:	89 04 24             	mov    %eax,(%esp)
  8016fa:	e8 89 fd ff ff       	call   801488 <dev_lookup>
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 55                	js     801758 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801706:	8b 50 08             	mov    0x8(%eax),%edx
  801709:	83 e2 03             	and    $0x3,%edx
  80170c:	83 fa 01             	cmp    $0x1,%edx
  80170f:	75 23                	jne    801734 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801711:	a1 20 44 80 00       	mov    0x804420,%eax
  801716:	8b 40 48             	mov    0x48(%eax),%eax
  801719:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	c7 04 24 ed 2b 80 00 	movl   $0x802bed,(%esp)
  801728:	e8 57 ec ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  80172d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801732:	eb 24                	jmp    801758 <read+0x8a>
	}
	if (!dev->dev_read)
  801734:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801737:	8b 52 08             	mov    0x8(%edx),%edx
  80173a:	85 d2                	test   %edx,%edx
  80173c:	74 15                	je     801753 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80173e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801741:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801748:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80174c:	89 04 24             	mov    %eax,(%esp)
  80174f:	ff d2                	call   *%edx
  801751:	eb 05                	jmp    801758 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801753:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801758:	83 c4 24             	add    $0x24,%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	57                   	push   %edi
  801762:	56                   	push   %esi
  801763:	53                   	push   %ebx
  801764:	83 ec 1c             	sub    $0x1c,%esp
  801767:	8b 7d 08             	mov    0x8(%ebp),%edi
  80176a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80176d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801772:	eb 23                	jmp    801797 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801774:	89 f0                	mov    %esi,%eax
  801776:	29 d8                	sub    %ebx,%eax
  801778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	01 d8                	add    %ebx,%eax
  801781:	89 44 24 04          	mov    %eax,0x4(%esp)
  801785:	89 3c 24             	mov    %edi,(%esp)
  801788:	e8 41 ff ff ff       	call   8016ce <read>
		if (m < 0)
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 10                	js     8017a1 <readn+0x43>
			return m;
		if (m == 0)
  801791:	85 c0                	test   %eax,%eax
  801793:	74 0a                	je     80179f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801795:	01 c3                	add    %eax,%ebx
  801797:	39 f3                	cmp    %esi,%ebx
  801799:	72 d9                	jb     801774 <readn+0x16>
  80179b:	89 d8                	mov    %ebx,%eax
  80179d:	eb 02                	jmp    8017a1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80179f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017a1:	83 c4 1c             	add    $0x1c,%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5e                   	pop    %esi
  8017a6:	5f                   	pop    %edi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 24             	sub    $0x24,%esp
  8017b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ba:	89 1c 24             	mov    %ebx,(%esp)
  8017bd:	e8 70 fc ff ff       	call   801432 <fd_lookup>
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 68                	js     80182e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	8b 00                	mov    (%eax),%eax
  8017d2:	89 04 24             	mov    %eax,(%esp)
  8017d5:	e8 ae fc ff ff       	call   801488 <dev_lookup>
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 50                	js     80182e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e5:	75 23                	jne    80180a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e7:	a1 20 44 80 00       	mov    0x804420,%eax
  8017ec:	8b 40 48             	mov    0x48(%eax),%eax
  8017ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	c7 04 24 09 2c 80 00 	movl   $0x802c09,(%esp)
  8017fe:	e8 81 eb ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  801803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801808:	eb 24                	jmp    80182e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80180a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180d:	8b 52 0c             	mov    0xc(%edx),%edx
  801810:	85 d2                	test   %edx,%edx
  801812:	74 15                	je     801829 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801814:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801817:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	ff d2                	call   *%edx
  801827:	eb 05                	jmp    80182e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801829:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80182e:	83 c4 24             	add    $0x24,%esp
  801831:	5b                   	pop    %ebx
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <seek>:

int
seek(int fdnum, off_t offset)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	89 04 24             	mov    %eax,(%esp)
  801847:	e8 e6 fb ff ff       	call   801432 <fd_lookup>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 0e                	js     80185e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801850:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801853:	8b 55 0c             	mov    0xc(%ebp),%edx
  801856:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801859:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 24             	sub    $0x24,%esp
  801867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801871:	89 1c 24             	mov    %ebx,(%esp)
  801874:	e8 b9 fb ff ff       	call   801432 <fd_lookup>
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 61                	js     8018de <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801880:	89 44 24 04          	mov    %eax,0x4(%esp)
  801884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801887:	8b 00                	mov    (%eax),%eax
  801889:	89 04 24             	mov    %eax,(%esp)
  80188c:	e8 f7 fb ff ff       	call   801488 <dev_lookup>
  801891:	85 c0                	test   %eax,%eax
  801893:	78 49                	js     8018de <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801898:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189c:	75 23                	jne    8018c1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80189e:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a3:	8b 40 48             	mov    0x48(%eax),%eax
  8018a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ae:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  8018b5:	e8 ca ea ff ff       	call   800384 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018bf:	eb 1d                	jmp    8018de <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c4:	8b 52 18             	mov    0x18(%edx),%edx
  8018c7:	85 d2                	test   %edx,%edx
  8018c9:	74 0e                	je     8018d9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018d2:	89 04 24             	mov    %eax,(%esp)
  8018d5:	ff d2                	call   *%edx
  8018d7:	eb 05                	jmp    8018de <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018de:	83 c4 24             	add    $0x24,%esp
  8018e1:	5b                   	pop    %ebx
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 24             	sub    $0x24,%esp
  8018eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	89 04 24             	mov    %eax,(%esp)
  8018fb:	e8 32 fb ff ff       	call   801432 <fd_lookup>
  801900:	85 c0                	test   %eax,%eax
  801902:	78 52                	js     801956 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801904:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	8b 00                	mov    (%eax),%eax
  801910:	89 04 24             	mov    %eax,(%esp)
  801913:	e8 70 fb ff ff       	call   801488 <dev_lookup>
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 3a                	js     801956 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801923:	74 2c                	je     801951 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801925:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801928:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80192f:	00 00 00 
	stat->st_isdir = 0;
  801932:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801939:	00 00 00 
	stat->st_dev = dev;
  80193c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801942:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801946:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801949:	89 14 24             	mov    %edx,(%esp)
  80194c:	ff 50 14             	call   *0x14(%eax)
  80194f:	eb 05                	jmp    801956 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801951:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801956:	83 c4 24             	add    $0x24,%esp
  801959:	5b                   	pop    %ebx
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801964:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80196b:	00 
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	e8 fe 01 00 00       	call   801b75 <open>
  801977:	89 c3                	mov    %eax,%ebx
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 1b                	js     801998 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80197d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801980:	89 44 24 04          	mov    %eax,0x4(%esp)
  801984:	89 1c 24             	mov    %ebx,(%esp)
  801987:	e8 58 ff ff ff       	call   8018e4 <fstat>
  80198c:	89 c6                	mov    %eax,%esi
	close(fd);
  80198e:	89 1c 24             	mov    %ebx,(%esp)
  801991:	e8 d4 fb ff ff       	call   80156a <close>
	return r;
  801996:	89 f3                	mov    %esi,%ebx
}
  801998:	89 d8                	mov    %ebx,%eax
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5d                   	pop    %ebp
  8019a0:	c3                   	ret    
  8019a1:	00 00                	add    %al,(%eax)
	...

008019a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 10             	sub    $0x10,%esp
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019b7:	75 11                	jne    8019ca <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019c0:	e8 68 09 00 00       	call   80232d <ipc_find_env>
  8019c5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019d1:	00 
  8019d2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019d9:	00 
  8019da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019de:	a1 00 40 80 00       	mov    0x804000,%eax
  8019e3:	89 04 24             	mov    %eax,(%esp)
  8019e6:	e8 d8 08 00 00       	call   8022c3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f2:	00 
  8019f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fe:	e8 59 08 00 00       	call   80225c <ipc_recv>
}
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	8b 40 0c             	mov    0xc(%eax),%eax
  801a16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a23:	ba 00 00 00 00       	mov    $0x0,%edx
  801a28:	b8 02 00 00 00       	mov    $0x2,%eax
  801a2d:	e8 72 ff ff ff       	call   8019a4 <fsipc>
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a40:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a45:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4f:	e8 50 ff ff ff       	call   8019a4 <fsipc>
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 14             	sub    $0x14,%esp
  801a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 40 0c             	mov    0xc(%eax),%eax
  801a66:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a70:	b8 05 00 00 00       	mov    $0x5,%eax
  801a75:	e8 2a ff ff ff       	call   8019a4 <fsipc>
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 2b                	js     801aa9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a85:	00 
  801a86:	89 1c 24             	mov    %ebx,(%esp)
  801a89:	e8 c1 ee ff ff       	call   80094f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a99:	a1 84 50 80 00       	mov    0x805084,%eax
  801a9e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa9:	83 c4 14             	add    $0x14,%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801ab5:	c7 44 24 08 38 2c 80 	movl   $0x802c38,0x8(%esp)
  801abc:	00 
  801abd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ac4:	00 
  801ac5:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  801acc:	e8 bb e7 ff ff       	call   80028c <_panic>

00801ad1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 10             	sub    $0x10,%esp
  801ad9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801adc:	8b 45 08             	mov    0x8(%ebp),%eax
  801adf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ae7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	b8 03 00 00 00       	mov    $0x3,%eax
  801af7:	e8 a8 fe ff ff       	call   8019a4 <fsipc>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 6a                	js     801b6c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b02:	39 c6                	cmp    %eax,%esi
  801b04:	73 24                	jae    801b2a <devfile_read+0x59>
  801b06:	c7 44 24 0c 61 2c 80 	movl   $0x802c61,0xc(%esp)
  801b0d:	00 
  801b0e:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  801b15:	00 
  801b16:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b1d:	00 
  801b1e:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  801b25:	e8 62 e7 ff ff       	call   80028c <_panic>
	assert(r <= PGSIZE);
  801b2a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2f:	7e 24                	jle    801b55 <devfile_read+0x84>
  801b31:	c7 44 24 0c 7d 2c 80 	movl   $0x802c7d,0xc(%esp)
  801b38:	00 
  801b39:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  801b40:	00 
  801b41:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b48:	00 
  801b49:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  801b50:	e8 37 e7 ff ff       	call   80028c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b59:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b60:	00 
  801b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b64:	89 04 24             	mov    %eax,(%esp)
  801b67:	e8 5c ef ff ff       	call   800ac8 <memmove>
	return r;
}
  801b6c:	89 d8                	mov    %ebx,%eax
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 20             	sub    $0x20,%esp
  801b7d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b80:	89 34 24             	mov    %esi,(%esp)
  801b83:	e8 94 ed ff ff       	call   80091c <strlen>
  801b88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b8d:	7f 60                	jg     801bef <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 45 f8 ff ff       	call   8013df <fd_alloc>
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 54                	js     801bf4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ba0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ba4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bab:	e8 9f ed ff ff       	call   80094f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc0:	e8 df fd ff ff       	call   8019a4 <fsipc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	79 15                	jns    801be0 <open+0x6b>
		fd_close(fd, 0);
  801bcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bd2:	00 
  801bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 04 f9 ff ff       	call   8014e2 <fd_close>
		return r;
  801bde:	eb 14                	jmp    801bf4 <open+0x7f>
	}

	return fd2num(fd);
  801be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 c9 f7 ff ff       	call   8013b4 <fd2num>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	eb 05                	jmp    801bf4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bef:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	83 c4 20             	add    $0x20,%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c03:	ba 00 00 00 00       	mov    $0x0,%edx
  801c08:	b8 08 00 00 00       	mov    $0x8,%eax
  801c0d:	e8 92 fd ff ff       	call   8019a4 <fsipc>
}
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 10             	sub    $0x10,%esp
  801c1c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 9a f7 ff ff       	call   8013c4 <fd2data>
  801c2a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c2c:	c7 44 24 04 89 2c 80 	movl   $0x802c89,0x4(%esp)
  801c33:	00 
  801c34:	89 34 24             	mov    %esi,(%esp)
  801c37:	e8 13 ed ff ff       	call   80094f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c3f:	2b 03                	sub    (%ebx),%eax
  801c41:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c47:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c4e:	00 00 00 
	stat->st_dev = &devpipe;
  801c51:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c58:	30 80 00 
	return 0;
}
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	53                   	push   %ebx
  801c6b:	83 ec 14             	sub    $0x14,%esp
  801c6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7c:	e8 67 f1 ff ff       	call   800de8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c81:	89 1c 24             	mov    %ebx,(%esp)
  801c84:	e8 3b f7 ff ff       	call   8013c4 <fd2data>
  801c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c94:	e8 4f f1 ff ff       	call   800de8 <sys_page_unmap>
}
  801c99:	83 c4 14             	add    $0x14,%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	57                   	push   %edi
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	83 ec 2c             	sub    $0x2c,%esp
  801ca8:	89 c7                	mov    %eax,%edi
  801caa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cad:	a1 20 44 80 00       	mov    0x804420,%eax
  801cb2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb5:	89 3c 24             	mov    %edi,(%esp)
  801cb8:	e8 b7 06 00 00       	call   802374 <pageref>
  801cbd:	89 c6                	mov    %eax,%esi
  801cbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc2:	89 04 24             	mov    %eax,(%esp)
  801cc5:	e8 aa 06 00 00       	call   802374 <pageref>
  801cca:	39 c6                	cmp    %eax,%esi
  801ccc:	0f 94 c0             	sete   %al
  801ccf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cd2:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801cd8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cdb:	39 cb                	cmp    %ecx,%ebx
  801cdd:	75 08                	jne    801ce7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801cdf:	83 c4 2c             	add    $0x2c,%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5f                   	pop    %edi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ce7:	83 f8 01             	cmp    $0x1,%eax
  801cea:	75 c1                	jne    801cad <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cec:	8b 42 58             	mov    0x58(%edx),%eax
  801cef:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cf6:	00 
  801cf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cff:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  801d06:	e8 79 e6 ff ff       	call   800384 <cprintf>
  801d0b:	eb a0                	jmp    801cad <_pipeisclosed+0xe>

00801d0d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	57                   	push   %edi
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	83 ec 1c             	sub    $0x1c,%esp
  801d16:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d19:	89 34 24             	mov    %esi,(%esp)
  801d1c:	e8 a3 f6 ff ff       	call   8013c4 <fd2data>
  801d21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d23:	bf 00 00 00 00       	mov    $0x0,%edi
  801d28:	eb 3c                	jmp    801d66 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d2a:	89 da                	mov    %ebx,%edx
  801d2c:	89 f0                	mov    %esi,%eax
  801d2e:	e8 6c ff ff ff       	call   801c9f <_pipeisclosed>
  801d33:	85 c0                	test   %eax,%eax
  801d35:	75 38                	jne    801d6f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d37:	e8 e6 ef ff ff       	call   800d22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801d3f:	8b 13                	mov    (%ebx),%edx
  801d41:	83 c2 20             	add    $0x20,%edx
  801d44:	39 d0                	cmp    %edx,%eax
  801d46:	73 e2                	jae    801d2a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d4e:	89 c2                	mov    %eax,%edx
  801d50:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d56:	79 05                	jns    801d5d <devpipe_write+0x50>
  801d58:	4a                   	dec    %edx
  801d59:	83 ca e0             	or     $0xffffffe0,%edx
  801d5c:	42                   	inc    %edx
  801d5d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d61:	40                   	inc    %eax
  801d62:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d65:	47                   	inc    %edi
  801d66:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d69:	75 d1                	jne    801d3c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d6b:	89 f8                	mov    %edi,%eax
  801d6d:	eb 05                	jmp    801d74 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d6f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    

00801d7c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 1c             	sub    $0x1c,%esp
  801d85:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d88:	89 3c 24             	mov    %edi,(%esp)
  801d8b:	e8 34 f6 ff ff       	call   8013c4 <fd2data>
  801d90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d92:	be 00 00 00 00       	mov    $0x0,%esi
  801d97:	eb 3a                	jmp    801dd3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d99:	85 f6                	test   %esi,%esi
  801d9b:	74 04                	je     801da1 <devpipe_read+0x25>
				return i;
  801d9d:	89 f0                	mov    %esi,%eax
  801d9f:	eb 40                	jmp    801de1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801da1:	89 da                	mov    %ebx,%edx
  801da3:	89 f8                	mov    %edi,%eax
  801da5:	e8 f5 fe ff ff       	call   801c9f <_pipeisclosed>
  801daa:	85 c0                	test   %eax,%eax
  801dac:	75 2e                	jne    801ddc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dae:	e8 6f ef ff ff       	call   800d22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801db3:	8b 03                	mov    (%ebx),%eax
  801db5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801db8:	74 df                	je     801d99 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dba:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dbf:	79 05                	jns    801dc6 <devpipe_read+0x4a>
  801dc1:	48                   	dec    %eax
  801dc2:	83 c8 e0             	or     $0xffffffe0,%eax
  801dc5:	40                   	inc    %eax
  801dc6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dd0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd2:	46                   	inc    %esi
  801dd3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd6:	75 db                	jne    801db3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dd8:	89 f0                	mov    %esi,%eax
  801dda:	eb 05                	jmp    801de1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	57                   	push   %edi
  801ded:	56                   	push   %esi
  801dee:	53                   	push   %ebx
  801def:	83 ec 3c             	sub    $0x3c,%esp
  801df2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801df5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 df f5 ff ff       	call   8013df <fd_alloc>
  801e00:	89 c3                	mov    %eax,%ebx
  801e02:	85 c0                	test   %eax,%eax
  801e04:	0f 88 45 01 00 00    	js     801f4f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e11:	00 
  801e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e20:	e8 1c ef ff ff       	call   800d41 <sys_page_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	85 c0                	test   %eax,%eax
  801e29:	0f 88 20 01 00 00    	js     801f4f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e2f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e32:	89 04 24             	mov    %eax,(%esp)
  801e35:	e8 a5 f5 ff ff       	call   8013df <fd_alloc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	0f 88 f8 00 00 00    	js     801f3c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e44:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e4b:	00 
  801e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5a:	e8 e2 ee ff ff       	call   800d41 <sys_page_alloc>
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	85 c0                	test   %eax,%eax
  801e63:	0f 88 d3 00 00 00    	js     801f3c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6c:	89 04 24             	mov    %eax,(%esp)
  801e6f:	e8 50 f5 ff ff       	call   8013c4 <fd2data>
  801e74:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e7d:	00 
  801e7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e89:	e8 b3 ee ff ff       	call   800d41 <sys_page_alloc>
  801e8e:	89 c3                	mov    %eax,%ebx
  801e90:	85 c0                	test   %eax,%eax
  801e92:	0f 88 91 00 00 00    	js     801f29 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e9b:	89 04 24             	mov    %eax,(%esp)
  801e9e:	e8 21 f5 ff ff       	call   8013c4 <fd2data>
  801ea3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eaa:	00 
  801eab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eaf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eb6:	00 
  801eb7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ebb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec2:	e8 ce ee ff ff       	call   800d95 <sys_page_map>
  801ec7:	89 c3                	mov    %eax,%ebx
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	78 4c                	js     801f19 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ecd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ee2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eeb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801efa:	89 04 24             	mov    %eax,(%esp)
  801efd:	e8 b2 f4 ff ff       	call   8013b4 <fd2num>
  801f02:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f07:	89 04 24             	mov    %eax,(%esp)
  801f0a:	e8 a5 f4 ff ff       	call   8013b4 <fd2num>
  801f0f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f17:	eb 36                	jmp    801f4f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f19:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f24:	e8 bf ee ff ff       	call   800de8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f37:	e8 ac ee ff ff       	call   800de8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4a:	e8 99 ee ff ff       	call   800de8 <sys_page_unmap>
    err:
	return r;
}
  801f4f:	89 d8                	mov    %ebx,%eax
  801f51:	83 c4 3c             	add    $0x3c,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	89 04 24             	mov    %eax,(%esp)
  801f6c:	e8 c1 f4 ff ff       	call   801432 <fd_lookup>
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 15                	js     801f8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f78:	89 04 24             	mov    %eax,(%esp)
  801f7b:	e8 44 f4 ff ff       	call   8013c4 <fd2data>
	return _pipeisclosed(fd, p);
  801f80:	89 c2                	mov    %eax,%edx
  801f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f85:	e8 15 fd ff ff       	call   801c9f <_pipeisclosed>
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	56                   	push   %esi
  801f90:	53                   	push   %ebx
  801f91:	83 ec 10             	sub    $0x10,%esp
  801f94:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f97:	85 f6                	test   %esi,%esi
  801f99:	75 24                	jne    801fbf <wait+0x33>
  801f9b:	c7 44 24 0c a8 2c 80 	movl   $0x802ca8,0xc(%esp)
  801fa2:	00 
  801fa3:	c7 44 24 08 68 2c 80 	movl   $0x802c68,0x8(%esp)
  801faa:	00 
  801fab:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801fb2:	00 
  801fb3:	c7 04 24 b3 2c 80 00 	movl   $0x802cb3,(%esp)
  801fba:	e8 cd e2 ff ff       	call   80028c <_panic>
	e = &envs[ENVX(envid)];
  801fbf:	89 f3                	mov    %esi,%ebx
  801fc1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801fc7:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  801fce:	c1 e3 07             	shl    $0x7,%ebx
  801fd1:	29 c3                	sub    %eax,%ebx
  801fd3:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801fd9:	eb 05                	jmp    801fe0 <wait+0x54>
		sys_yield();
  801fdb:	e8 42 ed ff ff       	call   800d22 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801fe0:	8b 43 48             	mov    0x48(%ebx),%eax
  801fe3:	39 f0                	cmp    %esi,%eax
  801fe5:	75 07                	jne    801fee <wait+0x62>
  801fe7:	8b 43 54             	mov    0x54(%ebx),%eax
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 ed                	jne    801fdb <wait+0x4f>
		sys_yield();
}
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	00 00                	add    %al,(%eax)
	...

00801ff8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802008:	c7 44 24 04 be 2c 80 	movl   $0x802cbe,0x4(%esp)
  80200f:	00 
  802010:	8b 45 0c             	mov    0xc(%ebp),%eax
  802013:	89 04 24             	mov    %eax,(%esp)
  802016:	e8 34 e9 ff ff       	call   80094f <strcpy>
	return 0;
}
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	57                   	push   %edi
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802033:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802039:	eb 30                	jmp    80206b <devcons_write+0x49>
		m = n - tot;
  80203b:	8b 75 10             	mov    0x10(%ebp),%esi
  80203e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802040:	83 fe 7f             	cmp    $0x7f,%esi
  802043:	76 05                	jbe    80204a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802045:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80204a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80204e:	03 45 0c             	add    0xc(%ebp),%eax
  802051:	89 44 24 04          	mov    %eax,0x4(%esp)
  802055:	89 3c 24             	mov    %edi,(%esp)
  802058:	e8 6b ea ff ff       	call   800ac8 <memmove>
		sys_cputs(buf, m);
  80205d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802061:	89 3c 24             	mov    %edi,(%esp)
  802064:	e8 0b ec ff ff       	call   800c74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802069:	01 f3                	add    %esi,%ebx
  80206b:	89 d8                	mov    %ebx,%eax
  80206d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802070:	72 c9                	jb     80203b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802072:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802078:	5b                   	pop    %ebx
  802079:	5e                   	pop    %esi
  80207a:	5f                   	pop    %edi
  80207b:	5d                   	pop    %ebp
  80207c:	c3                   	ret    

0080207d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802083:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802087:	75 07                	jne    802090 <devcons_read+0x13>
  802089:	eb 25                	jmp    8020b0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80208b:	e8 92 ec ff ff       	call   800d22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802090:	e8 fd eb ff ff       	call   800c92 <sys_cgetc>
  802095:	85 c0                	test   %eax,%eax
  802097:	74 f2                	je     80208b <devcons_read+0xe>
  802099:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80209b:	85 c0                	test   %eax,%eax
  80209d:	78 1d                	js     8020bc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80209f:	83 f8 04             	cmp    $0x4,%eax
  8020a2:	74 13                	je     8020b7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a7:	88 10                	mov    %dl,(%eax)
	return 1;
  8020a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ae:	eb 0c                	jmp    8020bc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b5:	eb 05                	jmp    8020bc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020d1:	00 
  8020d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d5:	89 04 24             	mov    %eax,(%esp)
  8020d8:	e8 97 eb ff ff       	call   800c74 <sys_cputs>
}
  8020dd:	c9                   	leave  
  8020de:	c3                   	ret    

008020df <getchar>:

int
getchar(void)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020ec:	00 
  8020ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020fb:	e8 ce f5 ff ff       	call   8016ce <read>
	if (r < 0)
  802100:	85 c0                	test   %eax,%eax
  802102:	78 0f                	js     802113 <getchar+0x34>
		return r;
	if (r < 1)
  802104:	85 c0                	test   %eax,%eax
  802106:	7e 06                	jle    80210e <getchar+0x2f>
		return -E_EOF;
	return c;
  802108:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80210c:	eb 05                	jmp    802113 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80210e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802113:	c9                   	leave  
  802114:	c3                   	ret    

00802115 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802122:	8b 45 08             	mov    0x8(%ebp),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 05 f3 ff ff       	call   801432 <fd_lookup>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 11                	js     802142 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802134:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80213a:	39 10                	cmp    %edx,(%eax)
  80213c:	0f 94 c0             	sete   %al
  80213f:	0f b6 c0             	movzbl %al,%eax
}
  802142:	c9                   	leave  
  802143:	c3                   	ret    

00802144 <opencons>:

int
opencons(void)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80214a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214d:	89 04 24             	mov    %eax,(%esp)
  802150:	e8 8a f2 ff ff       	call   8013df <fd_alloc>
  802155:	85 c0                	test   %eax,%eax
  802157:	78 3c                	js     802195 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802159:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802160:	00 
  802161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802164:	89 44 24 04          	mov    %eax,0x4(%esp)
  802168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216f:	e8 cd eb ff ff       	call   800d41 <sys_page_alloc>
  802174:	85 c0                	test   %eax,%eax
  802176:	78 1d                	js     802195 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802178:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802186:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80218d:	89 04 24             	mov    %eax,(%esp)
  802190:	e8 1f f2 ff ff       	call   8013b4 <fd2num>
}
  802195:	c9                   	leave  
  802196:	c3                   	ret    
	...

00802198 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80219e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021a5:	0f 85 80 00 00 00    	jne    80222b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8021ab:	a1 20 44 80 00       	mov    0x804420,%eax
  8021b0:	8b 40 48             	mov    0x48(%eax),%eax
  8021b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021ba:	00 
  8021bb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021c2:	ee 
  8021c3:	89 04 24             	mov    %eax,(%esp)
  8021c6:	e8 76 eb ff ff       	call   800d41 <sys_page_alloc>
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	79 20                	jns    8021ef <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8021cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021d3:	c7 44 24 08 cc 2c 80 	movl   $0x802ccc,0x8(%esp)
  8021da:	00 
  8021db:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8021e2:	00 
  8021e3:	c7 04 24 28 2d 80 00 	movl   $0x802d28,(%esp)
  8021ea:	e8 9d e0 ff ff       	call   80028c <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8021ef:	a1 20 44 80 00       	mov    0x804420,%eax
  8021f4:	8b 40 48             	mov    0x48(%eax),%eax
  8021f7:	c7 44 24 04 38 22 80 	movl   $0x802238,0x4(%esp)
  8021fe:	00 
  8021ff:	89 04 24             	mov    %eax,(%esp)
  802202:	e8 da ec ff ff       	call   800ee1 <sys_env_set_pgfault_upcall>
  802207:	85 c0                	test   %eax,%eax
  802209:	79 20                	jns    80222b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80220b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220f:	c7 44 24 08 f8 2c 80 	movl   $0x802cf8,0x8(%esp)
  802216:	00 
  802217:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80221e:	00 
  80221f:	c7 04 24 28 2d 80 00 	movl   $0x802d28,(%esp)
  802226:	e8 61 e0 ff ff       	call   80028c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80222b:	8b 45 08             	mov    0x8(%ebp),%eax
  80222e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    
  802235:	00 00                	add    %al,(%eax)
	...

00802238 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802238:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802239:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80223e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802240:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802243:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  802247:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802249:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  80224c:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  80224d:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802250:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  802252:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802255:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  802256:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802259:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80225a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80225b:	c3                   	ret    

0080225c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 10             	sub    $0x10,%esp
  802264:	8b 75 08             	mov    0x8(%ebp),%esi
  802267:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  80226d:	85 c0                	test   %eax,%eax
  80226f:	75 05                	jne    802276 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  802271:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  802276:	89 04 24             	mov    %eax,(%esp)
  802279:	e8 d9 ec ff ff       	call   800f57 <sys_ipc_recv>
	if (!err) {
  80227e:	85 c0                	test   %eax,%eax
  802280:	75 26                	jne    8022a8 <ipc_recv+0x4c>
		if (from_env_store) {
  802282:	85 f6                	test   %esi,%esi
  802284:	74 0a                	je     802290 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  802286:	a1 20 44 80 00       	mov    0x804420,%eax
  80228b:	8b 40 74             	mov    0x74(%eax),%eax
  80228e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802290:	85 db                	test   %ebx,%ebx
  802292:	74 0a                	je     80229e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802294:	a1 20 44 80 00       	mov    0x804420,%eax
  802299:	8b 40 78             	mov    0x78(%eax),%eax
  80229c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80229e:	a1 20 44 80 00       	mov    0x804420,%eax
  8022a3:	8b 40 70             	mov    0x70(%eax),%eax
  8022a6:	eb 14                	jmp    8022bc <ipc_recv+0x60>
	}
	if (from_env_store) {
  8022a8:	85 f6                	test   %esi,%esi
  8022aa:	74 06                	je     8022b2 <ipc_recv+0x56>
		*from_env_store = 0;
  8022ac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8022b2:	85 db                	test   %ebx,%ebx
  8022b4:	74 06                	je     8022bc <ipc_recv+0x60>
		*perm_store = 0;
  8022b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8022bc:	83 c4 10             	add    $0x10,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    

008022c3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	57                   	push   %edi
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	83 ec 1c             	sub    $0x1c,%esp
  8022cc:	8b 75 10             	mov    0x10(%ebp),%esi
  8022cf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8022d2:	85 f6                	test   %esi,%esi
  8022d4:	75 05                	jne    8022db <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8022d6:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8022db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022df:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ed:	89 04 24             	mov    %eax,(%esp)
  8022f0:	e8 3f ec ff ff       	call   800f34 <sys_ipc_try_send>
  8022f5:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8022f7:	e8 26 ea ff ff       	call   800d22 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8022fc:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8022ff:	74 da                	je     8022db <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802301:	85 db                	test   %ebx,%ebx
  802303:	74 20                	je     802325 <ipc_send+0x62>
		panic("send fail: %e", err);
  802305:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802309:	c7 44 24 08 36 2d 80 	movl   $0x802d36,0x8(%esp)
  802310:	00 
  802311:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802318:	00 
  802319:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  802320:	e8 67 df ff ff       	call   80028c <_panic>
	}
	return;
}
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    

0080232d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80232d:	55                   	push   %ebp
  80232e:	89 e5                	mov    %esp,%ebp
  802330:	53                   	push   %ebx
  802331:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802334:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802339:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802340:	89 c2                	mov    %eax,%edx
  802342:	c1 e2 07             	shl    $0x7,%edx
  802345:	29 ca                	sub    %ecx,%edx
  802347:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80234d:	8b 52 50             	mov    0x50(%edx),%edx
  802350:	39 da                	cmp    %ebx,%edx
  802352:	75 0f                	jne    802363 <ipc_find_env+0x36>
			return envs[i].env_id;
  802354:	c1 e0 07             	shl    $0x7,%eax
  802357:	29 c8                	sub    %ecx,%eax
  802359:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80235e:	8b 40 40             	mov    0x40(%eax),%eax
  802361:	eb 0c                	jmp    80236f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802363:	40                   	inc    %eax
  802364:	3d 00 04 00 00       	cmp    $0x400,%eax
  802369:	75 ce                	jne    802339 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80236b:	66 b8 00 00          	mov    $0x0,%ax
}
  80236f:	5b                   	pop    %ebx
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
	...

00802374 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80237a:	89 c2                	mov    %eax,%edx
  80237c:	c1 ea 16             	shr    $0x16,%edx
  80237f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802386:	f6 c2 01             	test   $0x1,%dl
  802389:	74 1e                	je     8023a9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80238b:	c1 e8 0c             	shr    $0xc,%eax
  80238e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802395:	a8 01                	test   $0x1,%al
  802397:	74 17                	je     8023b0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802399:	c1 e8 0c             	shr    $0xc,%eax
  80239c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023a3:	ef 
  8023a4:	0f b7 c0             	movzwl %ax,%eax
  8023a7:	eb 0c                	jmp    8023b5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ae:	eb 05                	jmp    8023b5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023b0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023b5:	5d                   	pop    %ebp
  8023b6:	c3                   	ret    
	...

008023b8 <__udivdi3>:
  8023b8:	55                   	push   %ebp
  8023b9:	57                   	push   %edi
  8023ba:	56                   	push   %esi
  8023bb:	83 ec 10             	sub    $0x10,%esp
  8023be:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8023ce:	89 cd                	mov    %ecx,%ebp
  8023d0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8023d4:	85 c0                	test   %eax,%eax
  8023d6:	75 2c                	jne    802404 <__udivdi3+0x4c>
  8023d8:	39 f9                	cmp    %edi,%ecx
  8023da:	77 68                	ja     802444 <__udivdi3+0x8c>
  8023dc:	85 c9                	test   %ecx,%ecx
  8023de:	75 0b                	jne    8023eb <__udivdi3+0x33>
  8023e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e5:	31 d2                	xor    %edx,%edx
  8023e7:	f7 f1                	div    %ecx
  8023e9:	89 c1                	mov    %eax,%ecx
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	89 f8                	mov    %edi,%eax
  8023ef:	f7 f1                	div    %ecx
  8023f1:	89 c7                	mov    %eax,%edi
  8023f3:	89 f0                	mov    %esi,%eax
  8023f5:	f7 f1                	div    %ecx
  8023f7:	89 c6                	mov    %eax,%esi
  8023f9:	89 f0                	mov    %esi,%eax
  8023fb:	89 fa                	mov    %edi,%edx
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	39 f8                	cmp    %edi,%eax
  802406:	77 2c                	ja     802434 <__udivdi3+0x7c>
  802408:	0f bd f0             	bsr    %eax,%esi
  80240b:	83 f6 1f             	xor    $0x1f,%esi
  80240e:	75 4c                	jne    80245c <__udivdi3+0xa4>
  802410:	39 f8                	cmp    %edi,%eax
  802412:	bf 00 00 00 00       	mov    $0x0,%edi
  802417:	72 0a                	jb     802423 <__udivdi3+0x6b>
  802419:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80241d:	0f 87 ad 00 00 00    	ja     8024d0 <__udivdi3+0x118>
  802423:	be 01 00 00 00       	mov    $0x1,%esi
  802428:	89 f0                	mov    %esi,%eax
  80242a:	89 fa                	mov    %edi,%edx
  80242c:	83 c4 10             	add    $0x10,%esp
  80242f:	5e                   	pop    %esi
  802430:	5f                   	pop    %edi
  802431:	5d                   	pop    %ebp
  802432:	c3                   	ret    
  802433:	90                   	nop
  802434:	31 ff                	xor    %edi,%edi
  802436:	31 f6                	xor    %esi,%esi
  802438:	89 f0                	mov    %esi,%eax
  80243a:	89 fa                	mov    %edi,%edx
  80243c:	83 c4 10             	add    $0x10,%esp
  80243f:	5e                   	pop    %esi
  802440:	5f                   	pop    %edi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    
  802443:	90                   	nop
  802444:	89 fa                	mov    %edi,%edx
  802446:	89 f0                	mov    %esi,%eax
  802448:	f7 f1                	div    %ecx
  80244a:	89 c6                	mov    %eax,%esi
  80244c:	31 ff                	xor    %edi,%edi
  80244e:	89 f0                	mov    %esi,%eax
  802450:	89 fa                	mov    %edi,%edx
  802452:	83 c4 10             	add    $0x10,%esp
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d 76 00             	lea    0x0(%esi),%esi
  80245c:	89 f1                	mov    %esi,%ecx
  80245e:	d3 e0                	shl    %cl,%eax
  802460:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802464:	b8 20 00 00 00       	mov    $0x20,%eax
  802469:	29 f0                	sub    %esi,%eax
  80246b:	89 ea                	mov    %ebp,%edx
  80246d:	88 c1                	mov    %al,%cl
  80246f:	d3 ea                	shr    %cl,%edx
  802471:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802475:	09 ca                	or     %ecx,%edx
  802477:	89 54 24 08          	mov    %edx,0x8(%esp)
  80247b:	89 f1                	mov    %esi,%ecx
  80247d:	d3 e5                	shl    %cl,%ebp
  80247f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802483:	89 fd                	mov    %edi,%ebp
  802485:	88 c1                	mov    %al,%cl
  802487:	d3 ed                	shr    %cl,%ebp
  802489:	89 fa                	mov    %edi,%edx
  80248b:	89 f1                	mov    %esi,%ecx
  80248d:	d3 e2                	shl    %cl,%edx
  80248f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802493:	88 c1                	mov    %al,%cl
  802495:	d3 ef                	shr    %cl,%edi
  802497:	09 d7                	or     %edx,%edi
  802499:	89 f8                	mov    %edi,%eax
  80249b:	89 ea                	mov    %ebp,%edx
  80249d:	f7 74 24 08          	divl   0x8(%esp)
  8024a1:	89 d1                	mov    %edx,%ecx
  8024a3:	89 c7                	mov    %eax,%edi
  8024a5:	f7 64 24 0c          	mull   0xc(%esp)
  8024a9:	39 d1                	cmp    %edx,%ecx
  8024ab:	72 17                	jb     8024c4 <__udivdi3+0x10c>
  8024ad:	74 09                	je     8024b8 <__udivdi3+0x100>
  8024af:	89 fe                	mov    %edi,%esi
  8024b1:	31 ff                	xor    %edi,%edi
  8024b3:	e9 41 ff ff ff       	jmp    8023f9 <__udivdi3+0x41>
  8024b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024bc:	89 f1                	mov    %esi,%ecx
  8024be:	d3 e2                	shl    %cl,%edx
  8024c0:	39 c2                	cmp    %eax,%edx
  8024c2:	73 eb                	jae    8024af <__udivdi3+0xf7>
  8024c4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8024c7:	31 ff                	xor    %edi,%edi
  8024c9:	e9 2b ff ff ff       	jmp    8023f9 <__udivdi3+0x41>
  8024ce:	66 90                	xchg   %ax,%ax
  8024d0:	31 f6                	xor    %esi,%esi
  8024d2:	e9 22 ff ff ff       	jmp    8023f9 <__udivdi3+0x41>
	...

008024d8 <__umoddi3>:
  8024d8:	55                   	push   %ebp
  8024d9:	57                   	push   %edi
  8024da:	56                   	push   %esi
  8024db:	83 ec 20             	sub    $0x20,%esp
  8024de:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024e2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8024e6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024ea:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024f2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8024f6:	89 c7                	mov    %eax,%edi
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	85 ed                	test   %ebp,%ebp
  8024fc:	75 16                	jne    802514 <__umoddi3+0x3c>
  8024fe:	39 f1                	cmp    %esi,%ecx
  802500:	0f 86 a6 00 00 00    	jbe    8025ac <__umoddi3+0xd4>
  802506:	f7 f1                	div    %ecx
  802508:	89 d0                	mov    %edx,%eax
  80250a:	31 d2                	xor    %edx,%edx
  80250c:	83 c4 20             	add    $0x20,%esp
  80250f:	5e                   	pop    %esi
  802510:	5f                   	pop    %edi
  802511:	5d                   	pop    %ebp
  802512:	c3                   	ret    
  802513:	90                   	nop
  802514:	39 f5                	cmp    %esi,%ebp
  802516:	0f 87 ac 00 00 00    	ja     8025c8 <__umoddi3+0xf0>
  80251c:	0f bd c5             	bsr    %ebp,%eax
  80251f:	83 f0 1f             	xor    $0x1f,%eax
  802522:	89 44 24 10          	mov    %eax,0x10(%esp)
  802526:	0f 84 a8 00 00 00    	je     8025d4 <__umoddi3+0xfc>
  80252c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802530:	d3 e5                	shl    %cl,%ebp
  802532:	bf 20 00 00 00       	mov    $0x20,%edi
  802537:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80253b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80253f:	89 f9                	mov    %edi,%ecx
  802541:	d3 e8                	shr    %cl,%eax
  802543:	09 e8                	or     %ebp,%eax
  802545:	89 44 24 18          	mov    %eax,0x18(%esp)
  802549:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80254d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802551:	d3 e0                	shl    %cl,%eax
  802553:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802557:	89 f2                	mov    %esi,%edx
  802559:	d3 e2                	shl    %cl,%edx
  80255b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80255f:	d3 e0                	shl    %cl,%eax
  802561:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802565:	8b 44 24 14          	mov    0x14(%esp),%eax
  802569:	89 f9                	mov    %edi,%ecx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	09 d0                	or     %edx,%eax
  80256f:	d3 ee                	shr    %cl,%esi
  802571:	89 f2                	mov    %esi,%edx
  802573:	f7 74 24 18          	divl   0x18(%esp)
  802577:	89 d6                	mov    %edx,%esi
  802579:	f7 64 24 0c          	mull   0xc(%esp)
  80257d:	89 c5                	mov    %eax,%ebp
  80257f:	89 d1                	mov    %edx,%ecx
  802581:	39 d6                	cmp    %edx,%esi
  802583:	72 67                	jb     8025ec <__umoddi3+0x114>
  802585:	74 75                	je     8025fc <__umoddi3+0x124>
  802587:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80258b:	29 e8                	sub    %ebp,%eax
  80258d:	19 ce                	sbb    %ecx,%esi
  80258f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802593:	d3 e8                	shr    %cl,%eax
  802595:	89 f2                	mov    %esi,%edx
  802597:	89 f9                	mov    %edi,%ecx
  802599:	d3 e2                	shl    %cl,%edx
  80259b:	09 d0                	or     %edx,%eax
  80259d:	89 f2                	mov    %esi,%edx
  80259f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025a3:	d3 ea                	shr    %cl,%edx
  8025a5:	83 c4 20             	add    $0x20,%esp
  8025a8:	5e                   	pop    %esi
  8025a9:	5f                   	pop    %edi
  8025aa:	5d                   	pop    %ebp
  8025ab:	c3                   	ret    
  8025ac:	85 c9                	test   %ecx,%ecx
  8025ae:	75 0b                	jne    8025bb <__umoddi3+0xe3>
  8025b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 f1                	div    %ecx
  8025b9:	89 c1                	mov    %eax,%ecx
  8025bb:	89 f0                	mov    %esi,%eax
  8025bd:	31 d2                	xor    %edx,%edx
  8025bf:	f7 f1                	div    %ecx
  8025c1:	89 f8                	mov    %edi,%eax
  8025c3:	e9 3e ff ff ff       	jmp    802506 <__umoddi3+0x2e>
  8025c8:	89 f2                	mov    %esi,%edx
  8025ca:	83 c4 20             	add    $0x20,%esp
  8025cd:	5e                   	pop    %esi
  8025ce:	5f                   	pop    %edi
  8025cf:	5d                   	pop    %ebp
  8025d0:	c3                   	ret    
  8025d1:	8d 76 00             	lea    0x0(%esi),%esi
  8025d4:	39 f5                	cmp    %esi,%ebp
  8025d6:	72 04                	jb     8025dc <__umoddi3+0x104>
  8025d8:	39 f9                	cmp    %edi,%ecx
  8025da:	77 06                	ja     8025e2 <__umoddi3+0x10a>
  8025dc:	89 f2                	mov    %esi,%edx
  8025de:	29 cf                	sub    %ecx,%edi
  8025e0:	19 ea                	sbb    %ebp,%edx
  8025e2:	89 f8                	mov    %edi,%eax
  8025e4:	83 c4 20             	add    $0x20,%esp
  8025e7:	5e                   	pop    %esi
  8025e8:	5f                   	pop    %edi
  8025e9:	5d                   	pop    %ebp
  8025ea:	c3                   	ret    
  8025eb:	90                   	nop
  8025ec:	89 d1                	mov    %edx,%ecx
  8025ee:	89 c5                	mov    %eax,%ebp
  8025f0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025f4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025f8:	eb 8d                	jmp    802587 <__umoddi3+0xaf>
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802600:	72 ea                	jb     8025ec <__umoddi3+0x114>
  802602:	89 f1                	mov    %esi,%ecx
  802604:	eb 81                	jmp    802587 <__umoddi3+0xaf>
