
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ff 01 00 00       	call   800230 <libmain>
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
  800039:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  800043:	e8 50 03 00 00       	call   800398 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 06 1f 00 00       	call   801f59 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 d9 25 80 	movl   $0x8025d9,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 e2 25 80 00 	movl   $0x8025e2,(%esp)
  800072:	e8 29 02 00 00       	call   8002a0 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800077:	e8 53 10 00 00       	call   8010cf <fork>
  80007c:	89 c6                	mov    %eax,%esi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 c1 2a 80 	movl   $0x802ac1,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 e2 25 80 00 	movl   $0x8025e2,(%esp)
  80009d:	e8 fe 01 00 00       	call   8002a0 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 54                	jne    8000fa <umain+0xc6>
		close(p[1]);
  8000a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 e5 15 00 00       	call   801696 <close>
  8000b1:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 08 20 00 00       	call   8020c9 <pipeisclosed>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	74 11                	je     8000d6 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000c5:	c7 04 24 f6 25 80 00 	movl   $0x8025f6,(%esp)
  8000cc:	e8 c7 02 00 00       	call   800398 <cprintf>
				exit();
  8000d1:	e8 ae 01 00 00       	call   800284 <exit>
			}
			sys_yield();
  8000d6:	e8 5b 0c 00 00       	call   800d36 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000db:	4b                   	dec    %ebx
  8000dc:	75 d8                	jne    8000b6 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 ce 12 00 00       	call   8013c8 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fe:	c7 04 24 11 26 80 00 	movl   $0x802611,(%esp)
  800105:	e8 8e 02 00 00       	call   800398 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  80010a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800110:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800117:	c1 e6 07             	shl    $0x7,%esi
  80011a:	29 c6                	sub    %eax,%esi
	cprintf("kid is %d\n", kid-envs);
  80011c:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800122:	c1 fe 02             	sar    $0x2,%esi
  800125:	89 f2                	mov    %esi,%edx
  800127:	c1 e2 05             	shl    $0x5,%edx
  80012a:	89 f0                	mov    %esi,%eax
  80012c:	c1 e0 0a             	shl    $0xa,%eax
  80012f:	01 d0                	add    %edx,%eax
  800131:	01 f0                	add    %esi,%eax
  800133:	89 c2                	mov    %eax,%edx
  800135:	c1 e2 0f             	shl    $0xf,%edx
  800138:	01 d0                	add    %edx,%eax
  80013a:	c1 e0 05             	shl    $0x5,%eax
  80013d:	01 c6                	add    %eax,%esi
  80013f:	f7 de                	neg    %esi
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  80014c:	e8 47 02 00 00       	call   800398 <cprintf>
	dup(p[0], 10);
  800151:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800158:	00 
  800159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 83 15 00 00       	call   8016e7 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800164:	eb 13                	jmp    800179 <umain+0x145>
		dup(p[0], 10);
  800166:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80016d:	00 
  80016e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 6e 15 00 00       	call   8016e7 <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800179:	8b 43 54             	mov    0x54(%ebx),%eax
  80017c:	83 f8 02             	cmp    $0x2,%eax
  80017f:	74 e5                	je     800166 <umain+0x132>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800181:	c7 04 24 27 26 80 00 	movl   $0x802627,(%esp)
  800188:	e8 0b 02 00 00       	call   800398 <cprintf>
	if (pipeisclosed(p[0]))
  80018d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 31 1f 00 00       	call   8020c9 <pipeisclosed>
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 1c                	je     8001b8 <umain+0x184>
		panic("somehow the other end of p[0] got closed!");
  80019c:	c7 44 24 08 80 26 80 	movl   $0x802680,0x8(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8001ab:	00 
  8001ac:	c7 04 24 e2 25 80 00 	movl   $0x8025e2,(%esp)
  8001b3:	e8 e8 00 00 00       	call   8002a0 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 94 13 00 00       	call   80155e <fd_lookup>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <umain+0x1ba>
		panic("cannot look up p[0]: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 3d 26 80 	movl   $0x80263d,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 e2 25 80 00 	movl   $0x8025e2,(%esp)
  8001e9:	e8 b2 00 00 00       	call   8002a0 <_panic>
	va = fd2data(fd);
  8001ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 f7 12 00 00       	call   8014f0 <fd2data>
	if (pageref(va) != 3+1)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 3f 1b 00 00       	call   801d40 <pageref>
  800201:	83 f8 04             	cmp    $0x4,%eax
  800204:	74 0e                	je     800214 <umain+0x1e0>
		cprintf("\nchild detected race\n");
  800206:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  80020d:	e8 86 01 00 00       	call   800398 <cprintf>
  800212:	eb 14                	jmp    800228 <umain+0x1f4>
	else
		cprintf("\nrace didn't happen\n", max);
  800214:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 6b 26 80 00 	movl   $0x80266b,(%esp)
  800223:	e8 70 01 00 00       	call   800398 <cprintf>
}
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
	...

00800230 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 10             	sub    $0x10,%esp
  800238:	8b 75 08             	mov    0x8(%ebp),%esi
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80023e:	e8 d4 0a 00 00       	call   800d17 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800243:	25 ff 03 00 00       	and    $0x3ff,%eax
  800248:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80024f:	c1 e0 07             	shl    $0x7,%eax
  800252:	29 d0                	sub    %edx,%eax
  800254:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800259:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025e:	85 f6                	test   %esi,%esi
  800260:	7e 07                	jle    800269 <libmain+0x39>
		binaryname = argv[0];
  800262:	8b 03                	mov    (%ebx),%eax
  800264:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800269:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 bf fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800275:	e8 0a 00 00 00       	call   800284 <exit>
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	00 00                	add    %al,(%eax)
	...

00800284 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80028a:	e8 38 14 00 00       	call   8016c7 <close_all>
	sys_env_destroy(0);
  80028f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800296:	e8 2a 0a 00 00       	call   800cc5 <sys_env_destroy>
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ab:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002b1:	e8 61 0a 00 00       	call   800d17 <sys_getenvid>
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	c7 04 24 b4 26 80 00 	movl   $0x8026b4,(%esp)
  8002d3:	e8 c0 00 00 00       	call   800398 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	e8 50 00 00 00       	call   800337 <vcprintf>
	cprintf("\n");
  8002e7:	c7 04 24 d7 25 80 00 	movl   $0x8025d7,(%esp)
  8002ee:	e8 a5 00 00 00       	call   800398 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f3:	cc                   	int3   
  8002f4:	eb fd                	jmp    8002f3 <_panic+0x53>
	...

008002f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 14             	sub    $0x14,%esp
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800302:	8b 03                	mov    (%ebx),%eax
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030b:	40                   	inc    %eax
  80030c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800313:	75 19                	jne    80032e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800315:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80031c:	00 
  80031d:	8d 43 08             	lea    0x8(%ebx),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	e8 60 09 00 00       	call   800c88 <sys_cputs>
		b->idx = 0;
  800328:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80032e:	ff 43 04             	incl   0x4(%ebx)
}
  800331:	83 c4 14             	add    $0x14,%esp
  800334:	5b                   	pop    %ebx
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800340:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800347:	00 00 00 
	b.cnt = 0;
  80034a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800351:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800362:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036c:	c7 04 24 f8 02 80 00 	movl   $0x8002f8,(%esp)
  800373:	e8 82 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800378:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80037e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800382:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 f8 08 00 00       	call   800c88 <sys_cputs>

	return b.cnt;
}
  800390:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 87 ff ff ff       	call   800337 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    
	...

008003b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 3c             	sub    $0x3c,%esp
  8003bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c0:	89 d7                	mov    %edx,%edi
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	75 08                	jne    8003e0 <printnum+0x2c>
  8003d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003de:	77 57                	ja     800437 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003e4:	4b                   	dec    %ebx
  8003e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ff:	00 
  800400:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	e8 4e 1f 00 00       	call   802360 <__udivdi3>
  800412:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800416:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800421:	89 fa                	mov    %edi,%edx
  800423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800426:	e8 89 ff ff ff       	call   8003b4 <printnum>
  80042b:	eb 0f                	jmp    80043c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800431:	89 34 24             	mov    %esi,(%esp)
  800434:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800437:	4b                   	dec    %ebx
  800438:	85 db                	test   %ebx,%ebx
  80043a:	7f f1                	jg     80042d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800440:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800444:	8b 45 10             	mov    0x10(%ebp),%eax
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800452:	00 
  800453:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800456:	89 04 24             	mov    %eax,(%esp)
  800459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	e8 1b 20 00 00       	call   802480 <__umoddi3>
  800465:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800469:	0f be 80 d7 26 80 00 	movsbl 0x8026d7(%eax),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800476:	83 c4 3c             	add    $0x3c,%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7e 0e                	jle    800494 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800486:	8b 10                	mov    (%eax),%edx
  800488:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048b:	89 08                	mov    %ecx,(%eax)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	8b 52 04             	mov    0x4(%edx),%edx
  800492:	eb 22                	jmp    8004b6 <getuint+0x38>
	else if (lflag)
  800494:	85 d2                	test   %edx,%edx
  800496:	74 10                	je     8004a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 0e                	jmp    8004b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c6:	73 08                	jae    8004d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8004c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cb:	88 0a                	mov    %cl,(%edx)
  8004cd:	42                   	inc    %edx
  8004ce:	89 10                	mov    %edx,(%eax)
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 02 00 00 00       	call   8004fa <vprintfmt>
	va_end(ap);
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 4c             	sub    $0x4c,%esp
  800503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800506:	8b 75 10             	mov    0x10(%ebp),%esi
  800509:	eb 12                	jmp    80051d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050b:	85 c0                	test   %eax,%eax
  80050d:	0f 84 8b 03 00 00    	je     80089e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800513:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800517:	89 04 24             	mov    %eax,(%esp)
  80051a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80051d:	0f b6 06             	movzbl (%esi),%eax
  800520:	46                   	inc    %esi
  800521:	83 f8 25             	cmp    $0x25,%eax
  800524:	75 e5                	jne    80050b <vprintfmt+0x11>
  800526:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80052a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800531:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800536:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80053d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800542:	eb 26                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800547:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80054b:	eb 1d                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800550:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800554:	eb 14                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800559:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800560:	eb 08                	jmp    80056a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800562:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800565:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	0f b6 06             	movzbl (%esi),%eax
  80056d:	8d 56 01             	lea    0x1(%esi),%edx
  800570:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800573:	8a 16                	mov    (%esi),%dl
  800575:	83 ea 23             	sub    $0x23,%edx
  800578:	80 fa 55             	cmp    $0x55,%dl
  80057b:	0f 87 01 03 00 00    	ja     800882 <vprintfmt+0x388>
  800581:	0f b6 d2             	movzbl %dl,%edx
  800584:	ff 24 95 20 28 80 00 	jmp    *0x802820(,%edx,4)
  80058b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800593:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800596:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80059a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005a0:	83 fa 09             	cmp    $0x9,%edx
  8005a3:	77 2a                	ja     8005cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a6:	eb eb                	jmp    800593 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b6:	eb 17                	jmp    8005cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bc:	78 98                	js     800556 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c1:	eb a7                	jmp    80056a <vprintfmt+0x70>
  8005c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005cd:	eb 9b                	jmp    80056a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d3:	79 95                	jns    80056a <vprintfmt+0x70>
  8005d5:	eb 8b                	jmp    800562 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005db:	eb 8d                	jmp    80056a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f5:	e9 23 ff ff ff       	jmp    80051d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	79 02                	jns    80060b <vprintfmt+0x111>
  800609:	f7 d8                	neg    %eax
  80060b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060d:	83 f8 0f             	cmp    $0xf,%eax
  800610:	7f 0b                	jg     80061d <vprintfmt+0x123>
  800612:	8b 04 85 80 29 80 00 	mov    0x802980(,%eax,4),%eax
  800619:	85 c0                	test   %eax,%eax
  80061b:	75 23                	jne    800640 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80061d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800621:	c7 44 24 08 ef 26 80 	movl   $0x8026ef,0x8(%esp)
  800628:	00 
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 9a fe ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063b:	e9 dd fe ff ff       	jmp    80051d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800640:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800644:	c7 44 24 08 f2 2b 80 	movl   $0x802bf2,0x8(%esp)
  80064b:	00 
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	8b 55 08             	mov    0x8(%ebp),%edx
  800653:	89 14 24             	mov    %edx,(%esp)
  800656:	e8 77 fe ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065e:	e9 ba fe ff ff       	jmp    80051d <vprintfmt+0x23>
  800663:	89 f9                	mov    %edi,%ecx
  800665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800668:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 30                	mov    (%eax),%esi
  800676:	85 f6                	test   %esi,%esi
  800678:	75 05                	jne    80067f <vprintfmt+0x185>
				p = "(null)";
  80067a:	be e8 26 80 00       	mov    $0x8026e8,%esi
			if (width > 0 && padc != '-')
  80067f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800683:	0f 8e 84 00 00 00    	jle    80070d <vprintfmt+0x213>
  800689:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80068d:	74 7e                	je     80070d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800693:	89 34 24             	mov    %esi,(%esp)
  800696:	e8 ab 02 00 00       	call   800946 <strnlen>
  80069b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069e:	29 c2                	sub    %eax,%edx
  8006a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006ad:	89 de                	mov    %ebx,%esi
  8006af:	89 d3                	mov    %edx,%ebx
  8006b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	eb 0b                	jmp    8006c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b9:	89 3c 24             	mov    %edi,(%esp)
  8006bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	4b                   	dec    %ebx
  8006c0:	85 db                	test   %ebx,%ebx
  8006c2:	7f f1                	jg     8006b5 <vprintfmt+0x1bb>
  8006c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006c7:	89 f3                	mov    %esi,%ebx
  8006c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	79 05                	jns    8006d8 <vprintfmt+0x1de>
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006db:	29 c2                	sub    %eax,%edx
  8006dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006e0:	eb 2b                	jmp    80070d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e6:	74 18                	je     800700 <vprintfmt+0x206>
  8006e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006eb:	83 fa 5e             	cmp    $0x5e,%edx
  8006ee:	76 10                	jbe    800700 <vprintfmt+0x206>
					putch('?', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	eb 0a                	jmp    80070a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070a:	ff 4d e4             	decl   -0x1c(%ebp)
  80070d:	0f be 06             	movsbl (%esi),%eax
  800710:	46                   	inc    %esi
  800711:	85 c0                	test   %eax,%eax
  800713:	74 21                	je     800736 <vprintfmt+0x23c>
  800715:	85 ff                	test   %edi,%edi
  800717:	78 c9                	js     8006e2 <vprintfmt+0x1e8>
  800719:	4f                   	dec    %edi
  80071a:	79 c6                	jns    8006e2 <vprintfmt+0x1e8>
  80071c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071f:	89 de                	mov    %ebx,%esi
  800721:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800724:	eb 18                	jmp    80073e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800731:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800733:	4b                   	dec    %ebx
  800734:	eb 08                	jmp    80073e <vprintfmt+0x244>
  800736:	8b 7d 08             	mov    0x8(%ebp),%edi
  800739:	89 de                	mov    %ebx,%esi
  80073b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073e:	85 db                	test   %ebx,%ebx
  800740:	7f e4                	jg     800726 <vprintfmt+0x22c>
  800742:	89 7d 08             	mov    %edi,0x8(%ebp)
  800745:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074a:	e9 ce fd ff ff       	jmp    80051d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074f:	83 f9 01             	cmp    $0x1,%ecx
  800752:	7e 10                	jle    800764 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 08             	lea    0x8(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 30                	mov    (%eax),%esi
  80075f:	8b 78 04             	mov    0x4(%eax),%edi
  800762:	eb 26                	jmp    80078a <vprintfmt+0x290>
	else if (lflag)
  800764:	85 c9                	test   %ecx,%ecx
  800766:	74 12                	je     80077a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 30                	mov    (%eax),%esi
  800773:	89 f7                	mov    %esi,%edi
  800775:	c1 ff 1f             	sar    $0x1f,%edi
  800778:	eb 10                	jmp    80078a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 30                	mov    (%eax),%esi
  800785:	89 f7                	mov    %esi,%edi
  800787:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078a:	85 ff                	test   %edi,%edi
  80078c:	78 0a                	js     800798 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80078e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800793:	e9 ac 00 00 00       	jmp    800844 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a6:	f7 de                	neg    %esi
  8007a8:	83 d7 00             	adc    $0x0,%edi
  8007ab:	f7 df                	neg    %edi
			}
			base = 10;
  8007ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b2:	e9 8d 00 00 00       	jmp    800844 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b7:	89 ca                	mov    %ecx,%edx
  8007b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bc:	e8 bd fc ff ff       	call   80047e <getuint>
  8007c1:	89 c6                	mov    %eax,%esi
  8007c3:	89 d7                	mov    %edx,%edi
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007ca:	eb 78                	jmp    800844 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007d7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8007da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007de:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007f9:	e9 1f fd ff ff       	jmp    80051d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8007fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800802:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800809:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80080c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800810:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800817:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8d 50 04             	lea    0x4(%eax),%edx
  800820:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800823:	8b 30                	mov    (%eax),%esi
  800825:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80082f:	eb 13                	jmp    800844 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800831:	89 ca                	mov    %ecx,%edx
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	e8 43 fc ff ff       	call   80047e <getuint>
  80083b:	89 c6                	mov    %eax,%esi
  80083d:	89 d7                	mov    %edx,%edi
			base = 16;
  80083f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800844:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800848:	89 54 24 10          	mov    %edx,0x10(%esp)
  80084c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80084f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800853:	89 44 24 08          	mov    %eax,0x8(%esp)
  800857:	89 34 24             	mov    %esi,(%esp)
  80085a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085e:	89 da                	mov    %ebx,%edx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	e8 4c fb ff ff       	call   8003b4 <printnum>
			break;
  800868:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80086b:	e9 ad fc ff ff       	jmp    80051d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80087d:	e9 9b fc ff ff       	jmp    80051d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800882:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800886:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80088d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800890:	eb 01                	jmp    800893 <vprintfmt+0x399>
  800892:	4e                   	dec    %esi
  800893:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800897:	75 f9                	jne    800892 <vprintfmt+0x398>
  800899:	e9 7f fc ff ff       	jmp    80051d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80089e:	83 c4 4c             	add    $0x4c,%esp
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5f                   	pop    %edi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 28             	sub    $0x28,%esp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	74 30                	je     8008f7 <vsnprintf+0x51>
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	7e 33                	jle    8008fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e0:	c7 04 24 b8 04 80 00 	movl   $0x8004b8,(%esp)
  8008e7:	e8 0e fc ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f5:	eb 0c                	jmp    800903 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008fc:	eb 05                	jmp    800903 <vsnprintf+0x5d>
  8008fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800912:	8b 45 10             	mov    0x10(%ebp),%eax
  800915:	89 44 24 08          	mov    %eax,0x8(%esp)
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	89 04 24             	mov    %eax,(%esp)
  800926:	e8 7b ff ff ff       	call   8008a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    
  80092d:	00 00                	add    %al,(%eax)
	...

00800930 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 01                	jmp    80093e <strlen+0xe>
		n++;
  80093d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80093e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800942:	75 f9                	jne    80093d <strlen+0xd>
		n++;
	return n;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 01                	jmp    800957 <strnlen+0x11>
		n++;
  800956:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800957:	39 d0                	cmp    %edx,%eax
  800959:	74 06                	je     800961 <strnlen+0x1b>
  80095b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80095f:	75 f5                	jne    800956 <strnlen+0x10>
		n++;
	return n;
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80096d:	ba 00 00 00 00       	mov    $0x0,%edx
  800972:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800975:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800978:	42                   	inc    %edx
  800979:	84 c9                	test   %cl,%cl
  80097b:	75 f5                	jne    800972 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 08             	sub    $0x8,%esp
  800987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80098a:	89 1c 24             	mov    %ebx,(%esp)
  80098d:	e8 9e ff ff ff       	call   800930 <strlen>
	strcpy(dst + len, src);
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 54 24 04          	mov    %edx,0x4(%esp)
  800999:	01 d8                	add    %ebx,%eax
  80099b:	89 04 24             	mov    %eax,(%esp)
  80099e:	e8 c0 ff ff ff       	call   800963 <strcpy>
	return dst;
}
  8009a3:	89 d8                	mov    %ebx,%eax
  8009a5:	83 c4 08             	add    $0x8,%esp
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009be:	eb 0c                	jmp    8009cc <strncpy+0x21>
		*dst++ = *src;
  8009c0:	8a 1a                	mov    (%edx),%bl
  8009c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cb:	41                   	inc    %ecx
  8009cc:	39 f1                	cmp    %esi,%ecx
  8009ce:	75 f0                	jne    8009c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e2:	85 d2                	test   %edx,%edx
  8009e4:	75 0a                	jne    8009f0 <strlcpy+0x1c>
  8009e6:	89 f0                	mov    %esi,%eax
  8009e8:	eb 1a                	jmp    800a04 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ea:	88 18                	mov    %bl,(%eax)
  8009ec:	40                   	inc    %eax
  8009ed:	41                   	inc    %ecx
  8009ee:	eb 02                	jmp    8009f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009f2:	4a                   	dec    %edx
  8009f3:	74 0a                	je     8009ff <strlcpy+0x2b>
  8009f5:	8a 19                	mov    (%ecx),%bl
  8009f7:	84 db                	test   %bl,%bl
  8009f9:	75 ef                	jne    8009ea <strlcpy+0x16>
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	eb 02                	jmp    800a01 <strlcpy+0x2d>
  8009ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a01:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a04:	29 f0                	sub    %esi,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a13:	eb 02                	jmp    800a17 <strcmp+0xd>
		p++, q++;
  800a15:	41                   	inc    %ecx
  800a16:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a17:	8a 01                	mov    (%ecx),%al
  800a19:	84 c0                	test   %al,%al
  800a1b:	74 04                	je     800a21 <strcmp+0x17>
  800a1d:	3a 02                	cmp    (%edx),%al
  800a1f:	74 f4                	je     800a15 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 12             	movzbl (%edx),%edx
  800a27:	29 d0                	sub    %edx,%eax
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a38:	eb 03                	jmp    800a3d <strncmp+0x12>
		n--, p++, q++;
  800a3a:	4a                   	dec    %edx
  800a3b:	40                   	inc    %eax
  800a3c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3d:	85 d2                	test   %edx,%edx
  800a3f:	74 14                	je     800a55 <strncmp+0x2a>
  800a41:	8a 18                	mov    (%eax),%bl
  800a43:	84 db                	test   %bl,%bl
  800a45:	74 04                	je     800a4b <strncmp+0x20>
  800a47:	3a 19                	cmp    (%ecx),%bl
  800a49:	74 ef                	je     800a3a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4b:	0f b6 00             	movzbl (%eax),%eax
  800a4e:	0f b6 11             	movzbl (%ecx),%edx
  800a51:	29 d0                	sub    %edx,%eax
  800a53:	eb 05                	jmp    800a5a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a66:	eb 05                	jmp    800a6d <strchr+0x10>
		if (*s == c)
  800a68:	38 ca                	cmp    %cl,%dl
  800a6a:	74 0c                	je     800a78 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6c:	40                   	inc    %eax
  800a6d:	8a 10                	mov    (%eax),%dl
  800a6f:	84 d2                	test   %dl,%dl
  800a71:	75 f5                	jne    800a68 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a83:	eb 05                	jmp    800a8a <strfind+0x10>
		if (*s == c)
  800a85:	38 ca                	cmp    %cl,%dl
  800a87:	74 07                	je     800a90 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a89:	40                   	inc    %eax
  800a8a:	8a 10                	mov    (%eax),%dl
  800a8c:	84 d2                	test   %dl,%dl
  800a8e:	75 f5                	jne    800a85 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 30                	je     800ad5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aab:	75 25                	jne    800ad2 <memset+0x40>
  800aad:	f6 c1 03             	test   $0x3,%cl
  800ab0:	75 20                	jne    800ad2 <memset+0x40>
		c &= 0xFF;
  800ab2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab5:	89 d3                	mov    %edx,%ebx
  800ab7:	c1 e3 08             	shl    $0x8,%ebx
  800aba:	89 d6                	mov    %edx,%esi
  800abc:	c1 e6 18             	shl    $0x18,%esi
  800abf:	89 d0                	mov    %edx,%eax
  800ac1:	c1 e0 10             	shl    $0x10,%eax
  800ac4:	09 f0                	or     %esi,%eax
  800ac6:	09 d0                	or     %edx,%eax
  800ac8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800acd:	fc                   	cld    
  800ace:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad0:	eb 03                	jmp    800ad5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad2:	fc                   	cld    
  800ad3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad5:	89 f8                	mov    %edi,%eax
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aea:	39 c6                	cmp    %eax,%esi
  800aec:	73 34                	jae    800b22 <memmove+0x46>
  800aee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af1:	39 d0                	cmp    %edx,%eax
  800af3:	73 2d                	jae    800b22 <memmove+0x46>
		s += n;
		d += n;
  800af5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af8:	f6 c2 03             	test   $0x3,%dl
  800afb:	75 1b                	jne    800b18 <memmove+0x3c>
  800afd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b03:	75 13                	jne    800b18 <memmove+0x3c>
  800b05:	f6 c1 03             	test   $0x3,%cl
  800b08:	75 0e                	jne    800b18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b0a:	83 ef 04             	sub    $0x4,%edi
  800b0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b13:	fd                   	std    
  800b14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b16:	eb 07                	jmp    800b1f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b18:	4f                   	dec    %edi
  800b19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1c:	fd                   	std    
  800b1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1f:	fc                   	cld    
  800b20:	eb 20                	jmp    800b42 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x61>
  800b2a:	a8 03                	test   $0x3,%al
  800b2c:	75 0f                	jne    800b3d <memmove+0x61>
  800b2e:	f6 c1 03             	test   $0x3,%cl
  800b31:	75 0a                	jne    800b3d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	fc                   	cld    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 05                	jmp    800b42 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	fc                   	cld    
  800b40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	89 04 24             	mov    %eax,(%esp)
  800b60:	e8 77 ff ff ff       	call   800adc <memmove>
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	eb 16                	jmp    800b93 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b80:	42                   	inc    %edx
  800b81:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b85:	38 c8                	cmp    %cl,%al
  800b87:	74 0a                	je     800b93 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b89:	0f b6 c0             	movzbl %al,%eax
  800b8c:	0f b6 c9             	movzbl %cl,%ecx
  800b8f:	29 c8                	sub    %ecx,%eax
  800b91:	eb 09                	jmp    800b9c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b93:	39 da                	cmp    %ebx,%edx
  800b95:	75 e6                	jne    800b7d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800baf:	eb 05                	jmp    800bb6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb1:	38 08                	cmp    %cl,(%eax)
  800bb3:	74 05                	je     800bba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb5:	40                   	inc    %eax
  800bb6:	39 d0                	cmp    %edx,%eax
  800bb8:	72 f7                	jb     800bb1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc8:	eb 01                	jmp    800bcb <strtol+0xf>
		s++;
  800bca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcb:	8a 02                	mov    (%edx),%al
  800bcd:	3c 20                	cmp    $0x20,%al
  800bcf:	74 f9                	je     800bca <strtol+0xe>
  800bd1:	3c 09                	cmp    $0x9,%al
  800bd3:	74 f5                	je     800bca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd5:	3c 2b                	cmp    $0x2b,%al
  800bd7:	75 08                	jne    800be1 <strtol+0x25>
		s++;
  800bd9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bda:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdf:	eb 13                	jmp    800bf4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be1:	3c 2d                	cmp    $0x2d,%al
  800be3:	75 0a                	jne    800bef <strtol+0x33>
		s++, neg = 1;
  800be5:	8d 52 01             	lea    0x1(%edx),%edx
  800be8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bed:	eb 05                	jmp    800bf4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf4:	85 db                	test   %ebx,%ebx
  800bf6:	74 05                	je     800bfd <strtol+0x41>
  800bf8:	83 fb 10             	cmp    $0x10,%ebx
  800bfb:	75 28                	jne    800c25 <strtol+0x69>
  800bfd:	8a 02                	mov    (%edx),%al
  800bff:	3c 30                	cmp    $0x30,%al
  800c01:	75 10                	jne    800c13 <strtol+0x57>
  800c03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c07:	75 0a                	jne    800c13 <strtol+0x57>
		s += 2, base = 16;
  800c09:	83 c2 02             	add    $0x2,%edx
  800c0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c11:	eb 12                	jmp    800c25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c13:	85 db                	test   %ebx,%ebx
  800c15:	75 0e                	jne    800c25 <strtol+0x69>
  800c17:	3c 30                	cmp    $0x30,%al
  800c19:	75 05                	jne    800c20 <strtol+0x64>
		s++, base = 8;
  800c1b:	42                   	inc    %edx
  800c1c:	b3 08                	mov    $0x8,%bl
  800c1e:	eb 05                	jmp    800c25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c2c:	8a 0a                	mov    (%edx),%cl
  800c2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c31:	80 fb 09             	cmp    $0x9,%bl
  800c34:	77 08                	ja     800c3e <strtol+0x82>
			dig = *s - '0';
  800c36:	0f be c9             	movsbl %cl,%ecx
  800c39:	83 e9 30             	sub    $0x30,%ecx
  800c3c:	eb 1e                	jmp    800c5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c41:	80 fb 19             	cmp    $0x19,%bl
  800c44:	77 08                	ja     800c4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800c46:	0f be c9             	movsbl %cl,%ecx
  800c49:	83 e9 57             	sub    $0x57,%ecx
  800c4c:	eb 0e                	jmp    800c5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c51:	80 fb 19             	cmp    $0x19,%bl
  800c54:	77 12                	ja     800c68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c56:	0f be c9             	movsbl %cl,%ecx
  800c59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5c:	39 f1                	cmp    %esi,%ecx
  800c5e:	7d 0c                	jge    800c6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c60:	42                   	inc    %edx
  800c61:	0f af c6             	imul   %esi,%eax
  800c64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c66:	eb c4                	jmp    800c2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c68:	89 c1                	mov    %eax,%ecx
  800c6a:	eb 02                	jmp    800c6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 05                	je     800c79 <strtol+0xbd>
		*endptr = (char *) s;
  800c74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c79:	85 ff                	test   %edi,%edi
  800c7b:	74 04                	je     800c81 <strtol+0xc5>
  800c7d:	89 c8                	mov    %ecx,%eax
  800c7f:	f7 d8                	neg    %eax
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    
	...

00800c88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 c3                	mov    %eax,%ebx
  800c9b:	89 c7                	mov    %eax,%edi
  800c9d:	89 c6                	mov    %eax,%esi
  800c9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d0a:	e8 91 f5 ff ff       	call   8002a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0f:	83 c4 2c             	add    $0x2c,%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 02 00 00 00       	mov    $0x2,%eax
  800d27:	89 d1                	mov    %edx,%ecx
  800d29:	89 d3                	mov    %edx,%ebx
  800d2b:	89 d7                	mov    %edx,%edi
  800d2d:	89 d6                	mov    %edx,%esi
  800d2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_yield>:

void
sys_yield(void)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d46:	89 d1                	mov    %edx,%ecx
  800d48:	89 d3                	mov    %edx,%ebx
  800d4a:	89 d7                	mov    %edx,%edi
  800d4c:	89 d6                	mov    %edx,%esi
  800d4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d5e:	be 00 00 00 00       	mov    $0x0,%esi
  800d63:	b8 04 00 00 00       	mov    $0x4,%eax
  800d68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 f7                	mov    %esi,%edi
  800d73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 28                	jle    800da1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d84:	00 
  800d85:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d94:	00 
  800d95:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d9c:	e8 ff f4 ff ff       	call   8002a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da1:	83 c4 2c             	add    $0x2c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	b8 05 00 00 00       	mov    $0x5,%eax
  800db7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800def:	e8 ac f4 ff ff       	call   8002a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df4:	83 c4 2c             	add    $0x2c,%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 df                	mov    %ebx,%edi
  800e17:	89 de                	mov    %ebx,%esi
  800e19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	7e 28                	jle    800e47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e42:	e8 59 f4 ff ff       	call   8002a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e47:	83 c4 2c             	add    $0x2c,%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	89 df                	mov    %ebx,%edi
  800e6a:	89 de                	mov    %ebx,%esi
  800e6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	7e 28                	jle    800e9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e85:	00 
  800e86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8d:	00 
  800e8e:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e95:	e8 06 f4 ff ff       	call   8002a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9a:	83 c4 2c             	add    $0x2c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	89 df                	mov    %ebx,%edi
  800ebd:	89 de                	mov    %ebx,%esi
  800ebf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	7e 28                	jle    800eed <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800ee8:	e8 b3 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eed:	83 c4 2c             	add    $0x2c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	89 df                	mov    %ebx,%edi
  800f10:	89 de                	mov    %ebx,%esi
  800f12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	7e 28                	jle    800f40 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f23:	00 
  800f24:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800f3b:	e8 60 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f40:	83 c4 2c             	add    $0x2c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f81:	89 cb                	mov    %ecx,%ebx
  800f83:	89 cf                	mov    %ecx,%edi
  800f85:	89 ce                	mov    %ecx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800fb0:	e8 eb f2 ff ff       	call   8002a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb5:	83 c4 2c             	add    $0x2c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
  800fbd:	00 00                	add    %al,(%eax)
	...

00800fc0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 24             	sub    $0x24,%esp
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fca:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800fcc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd0:	75 20                	jne    800ff2 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800fd2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fd6:	c7 44 24 08 0c 2a 80 	movl   $0x802a0c,0x8(%esp)
  800fdd:	00 
  800fde:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800fe5:	00 
  800fe6:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  800fed:	e8 ae f2 ff ff       	call   8002a0 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800ff2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800ffd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801004:	f6 c4 08             	test   $0x8,%ah
  801007:	75 1c                	jne    801025 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801009:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  801010:	00 
  801011:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801020:	e8 7b f2 ff ff       	call   8002a0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  801025:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103c:	e8 14 fd ff ff       	call   800d55 <sys_page_alloc>
  801041:	85 c0                	test   %eax,%eax
  801043:	79 20                	jns    801065 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  801045:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801049:	c7 44 24 08 96 2a 80 	movl   $0x802a96,0x8(%esp)
  801050:	00 
  801051:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801058:	00 
  801059:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801060:	e8 3b f2 ff ff       	call   8002a0 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  801065:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80106c:	00 
  80106d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801071:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801078:	e8 5f fa ff ff       	call   800adc <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  80107d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801084:	00 
  801085:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801089:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801090:	00 
  801091:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a0:	e8 04 fd ff ff       	call   800da9 <sys_page_map>
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	79 20                	jns    8010c9 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  8010a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ad:	c7 44 24 08 a9 2a 80 	movl   $0x802aa9,0x8(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8010bc:	00 
  8010bd:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  8010c4:	e8 d7 f1 ff ff       	call   8002a0 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  8010c9:	83 c4 24             	add    $0x24,%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  8010d8:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  8010df:	e8 b8 11 00 00       	call   80229c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010e4:	ba 07 00 00 00       	mov    $0x7,%edx
  8010e9:	89 d0                	mov    %edx,%eax
  8010eb:	cd 30                	int    $0x30
  8010ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 20                	jns    801117 <fork+0x48>
		panic("sys_exofork: %e", envid);
  8010f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010fb:	c7 44 24 08 ba 2a 80 	movl   $0x802aba,0x8(%esp)
  801102:	00 
  801103:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  80110a:	00 
  80110b:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801112:	e8 89 f1 ff ff       	call   8002a0 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  801117:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80111b:	75 25                	jne    801142 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  80111d:	e8 f5 fb ff ff       	call   800d17 <sys_getenvid>
  801122:	25 ff 03 00 00       	and    $0x3ff,%eax
  801127:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80112e:	c1 e0 07             	shl    $0x7,%eax
  801131:	29 d0                	sub    %edx,%eax
  801133:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801138:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80113d:	e9 58 02 00 00       	jmp    80139a <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  801142:	bf 00 00 00 00       	mov    $0x0,%edi
  801147:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80114c:	89 f0                	mov    %esi,%eax
  80114e:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801151:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801158:	a8 01                	test   $0x1,%al
  80115a:	0f 84 7a 01 00 00    	je     8012da <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801160:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801167:	a8 01                	test   $0x1,%al
  801169:	0f 84 6b 01 00 00    	je     8012da <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80116f:	a1 04 40 80 00       	mov    0x804004,%eax
  801174:	8b 40 48             	mov    0x48(%eax),%eax
  801177:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  80117a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801181:	f6 c4 04             	test   $0x4,%ah
  801184:	74 52                	je     8011d8 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801186:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80118d:	25 07 0e 00 00       	and    $0xe07,%eax
  801192:	89 44 24 10          	mov    %eax,0x10(%esp)
  801196:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80119a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80119d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a8:	89 04 24             	mov    %eax,(%esp)
  8011ab:	e8 f9 fb ff ff       	call   800da9 <sys_page_map>
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	0f 89 22 01 00 00    	jns    8012da <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bc:	c7 44 24 08 ca 2a 80 	movl   $0x802aca,0x8(%esp)
  8011c3:	00 
  8011c4:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8011cb:	00 
  8011cc:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  8011d3:	e8 c8 f0 ff ff       	call   8002a0 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8011d8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011df:	f6 c4 08             	test   $0x8,%ah
  8011e2:	75 0f                	jne    8011f3 <fork+0x124>
  8011e4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011eb:	a8 02                	test   $0x2,%al
  8011ed:	0f 84 99 00 00 00    	je     80128c <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8011f3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011fa:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011fd:	83 f8 01             	cmp    $0x1,%eax
  801200:	19 db                	sbb    %ebx,%ebx
  801202:	83 e3 fc             	and    $0xfffffffc,%ebx
  801205:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80120b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80120f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801213:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80121a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80121e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801221:	89 04 24             	mov    %eax,(%esp)
  801224:	e8 80 fb ff ff       	call   800da9 <sys_page_map>
  801229:	85 c0                	test   %eax,%eax
  80122b:	79 20                	jns    80124d <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  80122d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801231:	c7 44 24 08 ca 2a 80 	movl   $0x802aca,0x8(%esp)
  801238:	00 
  801239:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801240:	00 
  801241:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801248:	e8 53 f0 ff ff       	call   8002a0 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80124d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801251:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801255:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801260:	89 04 24             	mov    %eax,(%esp)
  801263:	e8 41 fb ff ff       	call   800da9 <sys_page_map>
  801268:	85 c0                	test   %eax,%eax
  80126a:	79 6e                	jns    8012da <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80126c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801270:	c7 44 24 08 ca 2a 80 	movl   $0x802aca,0x8(%esp)
  801277:	00 
  801278:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80127f:	00 
  801280:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801287:	e8 14 f0 ff ff       	call   8002a0 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80128c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801293:	25 07 0e 00 00       	and    $0xe07,%eax
  801298:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ae:	89 04 24             	mov    %eax,(%esp)
  8012b1:	e8 f3 fa ff ff       	call   800da9 <sys_page_map>
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	79 20                	jns    8012da <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8012ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012be:	c7 44 24 08 ca 2a 80 	movl   $0x802aca,0x8(%esp)
  8012c5:	00 
  8012c6:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8012cd:	00 
  8012ce:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  8012d5:	e8 c6 ef ff ff       	call   8002a0 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8012da:	46                   	inc    %esi
  8012db:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012e1:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8012e7:	0f 85 5f fe ff ff    	jne    80114c <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8012ed:	c7 44 24 04 3c 23 80 	movl   $0x80233c,0x4(%esp)
  8012f4:	00 
  8012f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	e8 f5 fb ff ff       	call   800ef5 <sys_env_set_pgfault_upcall>
  801300:	85 c0                	test   %eax,%eax
  801302:	79 20                	jns    801324 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801304:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801308:	c7 44 24 08 6c 2a 80 	movl   $0x802a6c,0x8(%esp)
  80130f:	00 
  801310:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801317:	00 
  801318:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  80131f:	e8 7c ef ff ff       	call   8002a0 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801324:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80132b:	00 
  80132c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801333:	ee 
  801334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 16 fa ff ff       	call   800d55 <sys_page_alloc>
  80133f:	85 c0                	test   %eax,%eax
  801341:	79 20                	jns    801363 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  801343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801347:	c7 44 24 08 96 2a 80 	movl   $0x802a96,0x8(%esp)
  80134e:	00 
  80134f:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801356:	00 
  801357:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  80135e:	e8 3d ef ff ff       	call   8002a0 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801363:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80136a:	00 
  80136b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	e8 d9 fa ff ff       	call   800e4f <sys_env_set_status>
  801376:	85 c0                	test   %eax,%eax
  801378:	79 20                	jns    80139a <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  80137a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137e:	c7 44 24 08 dc 2a 80 	movl   $0x802adc,0x8(%esp)
  801385:	00 
  801386:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80138d:	00 
  80138e:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801395:	e8 06 ef ff ff       	call   8002a0 <_panic>
	}
	
	return envid;
}
  80139a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80139d:	83 c4 3c             	add    $0x3c,%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <sfork>:

// Challenge!
int
sfork(void)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013ab:	c7 44 24 08 f3 2a 80 	movl   $0x802af3,0x8(%esp)
  8013b2:	00 
  8013b3:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8013ba:	00 
  8013bb:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  8013c2:	e8 d9 ee ff ff       	call   8002a0 <_panic>
	...

008013c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 10             	sub    $0x10,%esp
  8013d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	75 05                	jne    8013e2 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8013dd:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	e8 81 fb ff ff       	call   800f6b <sys_ipc_recv>
	if (!err) {
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	75 26                	jne    801414 <ipc_recv+0x4c>
		if (from_env_store) {
  8013ee:	85 f6                	test   %esi,%esi
  8013f0:	74 0a                	je     8013fc <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8013f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f7:	8b 40 74             	mov    0x74(%eax),%eax
  8013fa:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8013fc:	85 db                	test   %ebx,%ebx
  8013fe:	74 0a                	je     80140a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801400:	a1 04 40 80 00       	mov    0x804004,%eax
  801405:	8b 40 78             	mov    0x78(%eax),%eax
  801408:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80140a:	a1 04 40 80 00       	mov    0x804004,%eax
  80140f:	8b 40 70             	mov    0x70(%eax),%eax
  801412:	eb 14                	jmp    801428 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801414:	85 f6                	test   %esi,%esi
  801416:	74 06                	je     80141e <ipc_recv+0x56>
		*from_env_store = 0;
  801418:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  80141e:	85 db                	test   %ebx,%ebx
  801420:	74 06                	je     801428 <ipc_recv+0x60>
		*perm_store = 0;
  801422:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	57                   	push   %edi
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	83 ec 1c             	sub    $0x1c,%esp
  801438:	8b 75 10             	mov    0x10(%ebp),%esi
  80143b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  80143e:	85 f6                	test   %esi,%esi
  801440:	75 05                	jne    801447 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801442:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801447:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80144f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	89 04 24             	mov    %eax,(%esp)
  80145c:	e8 e7 fa ff ff       	call   800f48 <sys_ipc_try_send>
  801461:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801463:	e8 ce f8 ff ff       	call   800d36 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801468:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80146b:	74 da                	je     801447 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  80146d:	85 db                	test   %ebx,%ebx
  80146f:	74 20                	je     801491 <ipc_send+0x62>
		panic("send fail: %e", err);
  801471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801475:	c7 44 24 08 09 2b 80 	movl   $0x802b09,0x8(%esp)
  80147c:	00 
  80147d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801484:	00 
  801485:	c7 04 24 17 2b 80 00 	movl   $0x802b17,(%esp)
  80148c:	e8 0f ee ff ff       	call   8002a0 <_panic>
	}
	return;
}
  801491:	83 c4 1c             	add    $0x1c,%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	5f                   	pop    %edi
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    

00801499 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014a5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	c1 e2 07             	shl    $0x7,%edx
  8014b1:	29 ca                	sub    %ecx,%edx
  8014b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014b9:	8b 52 50             	mov    0x50(%edx),%edx
  8014bc:	39 da                	cmp    %ebx,%edx
  8014be:	75 0f                	jne    8014cf <ipc_find_env+0x36>
			return envs[i].env_id;
  8014c0:	c1 e0 07             	shl    $0x7,%eax
  8014c3:	29 c8                	sub    %ecx,%eax
  8014c5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014ca:	8b 40 40             	mov    0x40(%eax),%eax
  8014cd:	eb 0c                	jmp    8014db <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014cf:	40                   	inc    %eax
  8014d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014d5:	75 ce                	jne    8014a5 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014d7:	66 b8 00 00          	mov    $0x0,%ax
}
  8014db:	5b                   	pop    %ebx
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    
	...

008014e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	89 04 24             	mov    %eax,(%esp)
  8014fc:	e8 df ff ff ff       	call   8014e0 <fd2num>
  801501:	05 20 00 0d 00       	add    $0xd0020,%eax
  801506:	c1 e0 0c             	shl    $0xc,%eax
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	53                   	push   %ebx
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801512:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801517:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801519:	89 c2                	mov    %eax,%edx
  80151b:	c1 ea 16             	shr    $0x16,%edx
  80151e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801525:	f6 c2 01             	test   $0x1,%dl
  801528:	74 11                	je     80153b <fd_alloc+0x30>
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 ea 0c             	shr    $0xc,%edx
  80152f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	75 09                	jne    801544 <fd_alloc+0x39>
			*fd_store = fd;
  80153b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
  801542:	eb 17                	jmp    80155b <fd_alloc+0x50>
  801544:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801549:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80154e:	75 c7                	jne    801517 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801550:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801556:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80155b:	5b                   	pop    %ebx
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801564:	83 f8 1f             	cmp    $0x1f,%eax
  801567:	77 36                	ja     80159f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801569:	05 00 00 0d 00       	add    $0xd0000,%eax
  80156e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801571:	89 c2                	mov    %eax,%edx
  801573:	c1 ea 16             	shr    $0x16,%edx
  801576:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157d:	f6 c2 01             	test   $0x1,%dl
  801580:	74 24                	je     8015a6 <fd_lookup+0x48>
  801582:	89 c2                	mov    %eax,%edx
  801584:	c1 ea 0c             	shr    $0xc,%edx
  801587:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158e:	f6 c2 01             	test   $0x1,%dl
  801591:	74 1a                	je     8015ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801593:	8b 55 0c             	mov    0xc(%ebp),%edx
  801596:	89 02                	mov    %eax,(%edx)
	return 0;
  801598:	b8 00 00 00 00       	mov    $0x0,%eax
  80159d:	eb 13                	jmp    8015b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a4:	eb 0c                	jmp    8015b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ab:	eb 05                	jmp    8015b2 <fd_lookup+0x54>
  8015ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c6:	eb 0e                	jmp    8015d6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015c8:	39 08                	cmp    %ecx,(%eax)
  8015ca:	75 09                	jne    8015d5 <dev_lookup+0x21>
			*dev = devtab[i];
  8015cc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d3:	eb 33                	jmp    801608 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015d5:	42                   	inc    %edx
  8015d6:	8b 04 95 a0 2b 80 00 	mov    0x802ba0(,%edx,4),%eax
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	75 e7                	jne    8015c8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e6:	8b 40 48             	mov    0x48(%eax),%eax
  8015e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	c7 04 24 24 2b 80 00 	movl   $0x802b24,(%esp)
  8015f8:	e8 9b ed ff ff       	call   800398 <cprintf>
	*dev = 0;
  8015fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801608:	83 c4 14             	add    $0x14,%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	56                   	push   %esi
  801612:	53                   	push   %ebx
  801613:	83 ec 30             	sub    $0x30,%esp
  801616:	8b 75 08             	mov    0x8(%ebp),%esi
  801619:	8a 45 0c             	mov    0xc(%ebp),%al
  80161c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80161f:	89 34 24             	mov    %esi,(%esp)
  801622:	e8 b9 fe ff ff       	call   8014e0 <fd2num>
  801627:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80162a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80162e:	89 04 24             	mov    %eax,(%esp)
  801631:	e8 28 ff ff ff       	call   80155e <fd_lookup>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 05                	js     801641 <fd_close+0x33>
	    || fd != fd2)
  80163c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80163f:	74 0d                	je     80164e <fd_close+0x40>
		return (must_exist ? r : 0);
  801641:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801645:	75 46                	jne    80168d <fd_close+0x7f>
  801647:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164c:	eb 3f                	jmp    80168d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80164e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801651:	89 44 24 04          	mov    %eax,0x4(%esp)
  801655:	8b 06                	mov    (%esi),%eax
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 55 ff ff ff       	call   8015b4 <dev_lookup>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 18                	js     80167d <fd_close+0x6f>
		if (dev->dev_close)
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	8b 40 10             	mov    0x10(%eax),%eax
  80166b:	85 c0                	test   %eax,%eax
  80166d:	74 09                	je     801678 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80166f:	89 34 24             	mov    %esi,(%esp)
  801672:	ff d0                	call   *%eax
  801674:	89 c3                	mov    %eax,%ebx
  801676:	eb 05                	jmp    80167d <fd_close+0x6f>
		else
			r = 0;
  801678:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80167d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801681:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801688:	e8 6f f7 ff ff       	call   800dfc <sys_page_unmap>
	return r;
}
  80168d:	89 d8                	mov    %ebx,%eax
  80168f:	83 c4 30             	add    $0x30,%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 b0 fe ff ff       	call   80155e <fd_lookup>
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 13                	js     8016c5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016b9:	00 
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 49 ff ff ff       	call   80160e <fd_close>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <close_all>:

void
close_all(void)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016d3:	89 1c 24             	mov    %ebx,(%esp)
  8016d6:	e8 bb ff ff ff       	call   801696 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016db:	43                   	inc    %ebx
  8016dc:	83 fb 20             	cmp    $0x20,%ebx
  8016df:	75 f2                	jne    8016d3 <close_all+0xc>
		close(i);
}
  8016e1:	83 c4 14             	add    $0x14,%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 4c             	sub    $0x4c,%esp
  8016f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	89 04 24             	mov    %eax,(%esp)
  801700:	e8 59 fe ff ff       	call   80155e <fd_lookup>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	85 c0                	test   %eax,%eax
  801709:	0f 88 e1 00 00 00    	js     8017f0 <dup+0x109>
		return r;
	close(newfdnum);
  80170f:	89 3c 24             	mov    %edi,(%esp)
  801712:	e8 7f ff ff ff       	call   801696 <close>

	newfd = INDEX2FD(newfdnum);
  801717:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80171d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801720:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 c5 fd ff ff       	call   8014f0 <fd2data>
  80172b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80172d:	89 34 24             	mov    %esi,(%esp)
  801730:	e8 bb fd ff ff       	call   8014f0 <fd2data>
  801735:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	c1 e8 16             	shr    $0x16,%eax
  80173d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801744:	a8 01                	test   $0x1,%al
  801746:	74 46                	je     80178e <dup+0xa7>
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	c1 e8 0c             	shr    $0xc,%eax
  80174d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801754:	f6 c2 01             	test   $0x1,%dl
  801757:	74 35                	je     80178e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801759:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801760:	25 07 0e 00 00       	and    $0xe07,%eax
  801765:	89 44 24 10          	mov    %eax,0x10(%esp)
  801769:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80176c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801770:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801777:	00 
  801778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801783:	e8 21 f6 ff ff       	call   800da9 <sys_page_map>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 3b                	js     8017c9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80178e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801791:	89 c2                	mov    %eax,%edx
  801793:	c1 ea 0c             	shr    $0xc,%edx
  801796:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80179d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017a3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b2:	00 
  8017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017be:	e8 e6 f5 ff ff       	call   800da9 <sys_page_map>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	79 25                	jns    8017ee <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d4:	e8 23 f6 ff ff       	call   800dfc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e7:	e8 10 f6 ff ff       	call   800dfc <sys_page_unmap>
	return r;
  8017ec:	eb 02                	jmp    8017f0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017ee:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017f0:	89 d8                	mov    %ebx,%eax
  8017f2:	83 c4 4c             	add    $0x4c,%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 24             	sub    $0x24,%esp
  801801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	89 1c 24             	mov    %ebx,(%esp)
  80180e:	e8 4b fd ff ff       	call   80155e <fd_lookup>
  801813:	85 c0                	test   %eax,%eax
  801815:	78 6d                	js     801884 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801817:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	8b 00                	mov    (%eax),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 89 fd ff ff       	call   8015b4 <dev_lookup>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 55                	js     801884 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801832:	8b 50 08             	mov    0x8(%eax),%edx
  801835:	83 e2 03             	and    $0x3,%edx
  801838:	83 fa 01             	cmp    $0x1,%edx
  80183b:	75 23                	jne    801860 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80183d:	a1 04 40 80 00       	mov    0x804004,%eax
  801842:	8b 40 48             	mov    0x48(%eax),%eax
  801845:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184d:	c7 04 24 65 2b 80 00 	movl   $0x802b65,(%esp)
  801854:	e8 3f eb ff ff       	call   800398 <cprintf>
		return -E_INVAL;
  801859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185e:	eb 24                	jmp    801884 <read+0x8a>
	}
	if (!dev->dev_read)
  801860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801863:	8b 52 08             	mov    0x8(%edx),%edx
  801866:	85 d2                	test   %edx,%edx
  801868:	74 15                	je     80187f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80186a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80186d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801874:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801878:	89 04 24             	mov    %eax,(%esp)
  80187b:	ff d2                	call   *%edx
  80187d:	eb 05                	jmp    801884 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80187f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801884:	83 c4 24             	add    $0x24,%esp
  801887:	5b                   	pop    %ebx
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
  801890:	83 ec 1c             	sub    $0x1c,%esp
  801893:	8b 7d 08             	mov    0x8(%ebp),%edi
  801896:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801899:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189e:	eb 23                	jmp    8018c3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018a0:	89 f0                	mov    %esi,%eax
  8018a2:	29 d8                	sub    %ebx,%eax
  8018a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ab:	01 d8                	add    %ebx,%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	89 3c 24             	mov    %edi,(%esp)
  8018b4:	e8 41 ff ff ff       	call   8017fa <read>
		if (m < 0)
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 10                	js     8018cd <readn+0x43>
			return m;
		if (m == 0)
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	74 0a                	je     8018cb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018c1:	01 c3                	add    %eax,%ebx
  8018c3:	39 f3                	cmp    %esi,%ebx
  8018c5:	72 d9                	jb     8018a0 <readn+0x16>
  8018c7:	89 d8                	mov    %ebx,%eax
  8018c9:	eb 02                	jmp    8018cd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018cb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018cd:	83 c4 1c             	add    $0x1c,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 24             	sub    $0x24,%esp
  8018dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	89 1c 24             	mov    %ebx,(%esp)
  8018e9:	e8 70 fc ff ff       	call   80155e <fd_lookup>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 68                	js     80195a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	8b 00                	mov    (%eax),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 ae fc ff ff       	call   8015b4 <dev_lookup>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 50                	js     80195a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801911:	75 23                	jne    801936 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801913:	a1 04 40 80 00       	mov    0x804004,%eax
  801918:	8b 40 48             	mov    0x48(%eax),%eax
  80191b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	c7 04 24 81 2b 80 00 	movl   $0x802b81,(%esp)
  80192a:	e8 69 ea ff ff       	call   800398 <cprintf>
		return -E_INVAL;
  80192f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801934:	eb 24                	jmp    80195a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801936:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801939:	8b 52 0c             	mov    0xc(%edx),%edx
  80193c:	85 d2                	test   %edx,%edx
  80193e:	74 15                	je     801955 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801940:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801943:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	ff d2                	call   *%edx
  801953:	eb 05                	jmp    80195a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801955:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80195a:	83 c4 24             	add    $0x24,%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <seek>:

int
seek(int fdnum, off_t offset)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801966:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	89 04 24             	mov    %eax,(%esp)
  801973:	e8 e6 fb ff ff       	call   80155e <fd_lookup>
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 0e                	js     80198a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80197c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80197f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801982:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	53                   	push   %ebx
  801990:	83 ec 24             	sub    $0x24,%esp
  801993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801996:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199d:	89 1c 24             	mov    %ebx,(%esp)
  8019a0:	e8 b9 fb ff ff       	call   80155e <fd_lookup>
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 61                	js     801a0a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b3:	8b 00                	mov    (%eax),%eax
  8019b5:	89 04 24             	mov    %eax,(%esp)
  8019b8:	e8 f7 fb ff ff       	call   8015b4 <dev_lookup>
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 49                	js     801a0a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019c8:	75 23                	jne    8019ed <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019ca:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019cf:	8b 40 48             	mov    0x48(%eax),%eax
  8019d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019da:	c7 04 24 44 2b 80 00 	movl   $0x802b44,(%esp)
  8019e1:	e8 b2 e9 ff ff       	call   800398 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019eb:	eb 1d                	jmp    801a0a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f0:	8b 52 18             	mov    0x18(%edx),%edx
  8019f3:	85 d2                	test   %edx,%edx
  8019f5:	74 0e                	je     801a05 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	ff d2                	call   *%edx
  801a03:	eb 05                	jmp    801a0a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a05:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a0a:	83 c4 24             	add    $0x24,%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 24             	sub    $0x24,%esp
  801a17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	89 04 24             	mov    %eax,(%esp)
  801a27:	e8 32 fb ff ff       	call   80155e <fd_lookup>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 52                	js     801a82 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3a:	8b 00                	mov    (%eax),%eax
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	e8 70 fb ff ff       	call   8015b4 <dev_lookup>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	78 3a                	js     801a82 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a4f:	74 2c                	je     801a7d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a51:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a54:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a5b:	00 00 00 
	stat->st_isdir = 0;
  801a5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a65:	00 00 00 
	stat->st_dev = dev;
  801a68:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a75:	89 14 24             	mov    %edx,(%esp)
  801a78:	ff 50 14             	call   *0x14(%eax)
  801a7b:	eb 05                	jmp    801a82 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a82:	83 c4 24             	add    $0x24,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a97:	00 
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	89 04 24             	mov    %eax,(%esp)
  801a9e:	e8 fe 01 00 00       	call   801ca1 <open>
  801aa3:	89 c3                	mov    %eax,%ebx
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 1b                	js     801ac4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	89 1c 24             	mov    %ebx,(%esp)
  801ab3:	e8 58 ff ff ff       	call   801a10 <fstat>
  801ab8:	89 c6                	mov    %eax,%esi
	close(fd);
  801aba:	89 1c 24             	mov    %ebx,(%esp)
  801abd:	e8 d4 fb ff ff       	call   801696 <close>
	return r;
  801ac2:	89 f3                	mov    %esi,%ebx
}
  801ac4:	89 d8                	mov    %ebx,%eax
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    
  801acd:	00 00                	add    %al,(%eax)
	...

00801ad0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 10             	sub    $0x10,%esp
  801ad8:	89 c3                	mov    %eax,%ebx
  801ada:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801adc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ae3:	75 11                	jne    801af6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ae5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aec:	e8 a8 f9 ff ff       	call   801499 <ipc_find_env>
  801af1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801af6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801afd:	00 
  801afe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b05:	00 
  801b06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b0a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 18 f9 ff ff       	call   80142f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b1e:	00 
  801b1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2a:	e8 99 f8 ff ff       	call   8013c8 <ipc_recv>
}
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b54:	b8 02 00 00 00       	mov    $0x2,%eax
  801b59:	e8 72 ff ff ff       	call   801ad0 <fsipc>
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 06 00 00 00       	mov    $0x6,%eax
  801b7b:	e8 50 ff ff ff       	call   801ad0 <fsipc>
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	53                   	push   %ebx
  801b86:	83 ec 14             	sub    $0x14,%esp
  801b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b92:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9c:	b8 05 00 00 00       	mov    $0x5,%eax
  801ba1:	e8 2a ff ff ff       	call   801ad0 <fsipc>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 2b                	js     801bd5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801baa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bb1:	00 
  801bb2:	89 1c 24             	mov    %ebx,(%esp)
  801bb5:	e8 a9 ed ff ff       	call   800963 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bba:	a1 80 50 80 00       	mov    0x805080,%eax
  801bbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bc5:	a1 84 50 80 00       	mov    0x805084,%eax
  801bca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd5:	83 c4 14             	add    $0x14,%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801be1:	c7 44 24 08 b0 2b 80 	movl   $0x802bb0,0x8(%esp)
  801be8:	00 
  801be9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801bf0:	00 
  801bf1:	c7 04 24 ce 2b 80 00 	movl   $0x802bce,(%esp)
  801bf8:	e8 a3 e6 ff ff       	call   8002a0 <_panic>

00801bfd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 10             	sub    $0x10,%esp
  801c05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c19:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1e:	b8 03 00 00 00       	mov    $0x3,%eax
  801c23:	e8 a8 fe ff ff       	call   801ad0 <fsipc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 6a                	js     801c98 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c2e:	39 c6                	cmp    %eax,%esi
  801c30:	73 24                	jae    801c56 <devfile_read+0x59>
  801c32:	c7 44 24 0c d9 2b 80 	movl   $0x802bd9,0xc(%esp)
  801c39:	00 
  801c3a:	c7 44 24 08 e0 2b 80 	movl   $0x802be0,0x8(%esp)
  801c41:	00 
  801c42:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c49:	00 
  801c4a:	c7 04 24 ce 2b 80 00 	movl   $0x802bce,(%esp)
  801c51:	e8 4a e6 ff ff       	call   8002a0 <_panic>
	assert(r <= PGSIZE);
  801c56:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c5b:	7e 24                	jle    801c81 <devfile_read+0x84>
  801c5d:	c7 44 24 0c f5 2b 80 	movl   $0x802bf5,0xc(%esp)
  801c64:	00 
  801c65:	c7 44 24 08 e0 2b 80 	movl   $0x802be0,0x8(%esp)
  801c6c:	00 
  801c6d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c74:	00 
  801c75:	c7 04 24 ce 2b 80 00 	movl   $0x802bce,(%esp)
  801c7c:	e8 1f e6 ff ff       	call   8002a0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c85:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c8c:	00 
  801c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c90:	89 04 24             	mov    %eax,(%esp)
  801c93:	e8 44 ee ff ff       	call   800adc <memmove>
	return r;
}
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 20             	sub    $0x20,%esp
  801ca9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cac:	89 34 24             	mov    %esi,(%esp)
  801caf:	e8 7c ec ff ff       	call   800930 <strlen>
  801cb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cb9:	7f 60                	jg     801d1b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	89 04 24             	mov    %eax,(%esp)
  801cc1:	e8 45 f8 ff ff       	call   80150b <fd_alloc>
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 54                	js     801d20 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ccc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cd7:	e8 87 ec ff ff       	call   800963 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cec:	e8 df fd ff ff       	call   801ad0 <fsipc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	79 15                	jns    801d0c <open+0x6b>
		fd_close(fd, 0);
  801cf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cfe:	00 
  801cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d02:	89 04 24             	mov    %eax,(%esp)
  801d05:	e8 04 f9 ff ff       	call   80160e <fd_close>
		return r;
  801d0a:	eb 14                	jmp    801d20 <open+0x7f>
	}

	return fd2num(fd);
  801d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0f:	89 04 24             	mov    %eax,(%esp)
  801d12:	e8 c9 f7 ff ff       	call   8014e0 <fd2num>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	eb 05                	jmp    801d20 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d1b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	83 c4 20             	add    $0x20,%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d34:	b8 08 00 00 00       	mov    $0x8,%eax
  801d39:	e8 92 fd ff ff       	call   801ad0 <fsipc>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	c1 ea 16             	shr    $0x16,%edx
  801d4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d52:	f6 c2 01             	test   $0x1,%dl
  801d55:	74 1e                	je     801d75 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d57:	c1 e8 0c             	shr    $0xc,%eax
  801d5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d61:	a8 01                	test   $0x1,%al
  801d63:	74 17                	je     801d7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d65:	c1 e8 0c             	shr    $0xc,%eax
  801d68:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d6f:	ef 
  801d70:	0f b7 c0             	movzwl %ax,%eax
  801d73:	eb 0c                	jmp    801d81 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7a:	eb 05                	jmp    801d81 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
	...

00801d84 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	83 ec 10             	sub    $0x10,%esp
  801d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	89 04 24             	mov    %eax,(%esp)
  801d95:	e8 56 f7 ff ff       	call   8014f0 <fd2data>
  801d9a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d9c:	c7 44 24 04 01 2c 80 	movl   $0x802c01,0x4(%esp)
  801da3:	00 
  801da4:	89 34 24             	mov    %esi,(%esp)
  801da7:	e8 b7 eb ff ff       	call   800963 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dac:	8b 43 04             	mov    0x4(%ebx),%eax
  801daf:	2b 03                	sub    (%ebx),%eax
  801db1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801db7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801dbe:	00 00 00 
	stat->st_dev = &devpipe;
  801dc1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801dc8:	30 80 00 
	return 0;
}
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 14             	sub    $0x14,%esp
  801dde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801de1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801de5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dec:	e8 0b f0 ff ff       	call   800dfc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801df1:	89 1c 24             	mov    %ebx,(%esp)
  801df4:	e8 f7 f6 ff ff       	call   8014f0 <fd2data>
  801df9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e04:	e8 f3 ef ff ff       	call   800dfc <sys_page_unmap>
}
  801e09:	83 c4 14             	add    $0x14,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	57                   	push   %edi
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	83 ec 2c             	sub    $0x2c,%esp
  801e18:	89 c7                	mov    %eax,%edi
  801e1a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e22:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e25:	89 3c 24             	mov    %edi,(%esp)
  801e28:	e8 13 ff ff ff       	call   801d40 <pageref>
  801e2d:	89 c6                	mov    %eax,%esi
  801e2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e32:	89 04 24             	mov    %eax,(%esp)
  801e35:	e8 06 ff ff ff       	call   801d40 <pageref>
  801e3a:	39 c6                	cmp    %eax,%esi
  801e3c:	0f 94 c0             	sete   %al
  801e3f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e42:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e48:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e4b:	39 cb                	cmp    %ecx,%ebx
  801e4d:	75 08                	jne    801e57 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e4f:	83 c4 2c             	add    $0x2c,%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e57:	83 f8 01             	cmp    $0x1,%eax
  801e5a:	75 c1                	jne    801e1d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e5c:	8b 42 58             	mov    0x58(%edx),%eax
  801e5f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801e66:	00 
  801e67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e6f:	c7 04 24 08 2c 80 00 	movl   $0x802c08,(%esp)
  801e76:	e8 1d e5 ff ff       	call   800398 <cprintf>
  801e7b:	eb a0                	jmp    801e1d <_pipeisclosed+0xe>

00801e7d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	57                   	push   %edi
  801e81:	56                   	push   %esi
  801e82:	53                   	push   %ebx
  801e83:	83 ec 1c             	sub    $0x1c,%esp
  801e86:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e89:	89 34 24             	mov    %esi,(%esp)
  801e8c:	e8 5f f6 ff ff       	call   8014f0 <fd2data>
  801e91:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e93:	bf 00 00 00 00       	mov    $0x0,%edi
  801e98:	eb 3c                	jmp    801ed6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e9a:	89 da                	mov    %ebx,%edx
  801e9c:	89 f0                	mov    %esi,%eax
  801e9e:	e8 6c ff ff ff       	call   801e0f <_pipeisclosed>
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	75 38                	jne    801edf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ea7:	e8 8a ee ff ff       	call   800d36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eac:	8b 43 04             	mov    0x4(%ebx),%eax
  801eaf:	8b 13                	mov    (%ebx),%edx
  801eb1:	83 c2 20             	add    $0x20,%edx
  801eb4:	39 d0                	cmp    %edx,%eax
  801eb6:	73 e2                	jae    801e9a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801eb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801ebe:	89 c2                	mov    %eax,%edx
  801ec0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ec6:	79 05                	jns    801ecd <devpipe_write+0x50>
  801ec8:	4a                   	dec    %edx
  801ec9:	83 ca e0             	or     $0xffffffe0,%edx
  801ecc:	42                   	inc    %edx
  801ecd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ed1:	40                   	inc    %eax
  801ed2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed5:	47                   	inc    %edi
  801ed6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ed9:	75 d1                	jne    801eac <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801edb:	89 f8                	mov    %edi,%eax
  801edd:	eb 05                	jmp    801ee4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801edf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ee4:	83 c4 1c             	add    $0x1c,%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
  801ef2:	83 ec 1c             	sub    $0x1c,%esp
  801ef5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ef8:	89 3c 24             	mov    %edi,(%esp)
  801efb:	e8 f0 f5 ff ff       	call   8014f0 <fd2data>
  801f00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f02:	be 00 00 00 00       	mov    $0x0,%esi
  801f07:	eb 3a                	jmp    801f43 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f09:	85 f6                	test   %esi,%esi
  801f0b:	74 04                	je     801f11 <devpipe_read+0x25>
				return i;
  801f0d:	89 f0                	mov    %esi,%eax
  801f0f:	eb 40                	jmp    801f51 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f11:	89 da                	mov    %ebx,%edx
  801f13:	89 f8                	mov    %edi,%eax
  801f15:	e8 f5 fe ff ff       	call   801e0f <_pipeisclosed>
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	75 2e                	jne    801f4c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f1e:	e8 13 ee ff ff       	call   800d36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f23:	8b 03                	mov    (%ebx),%eax
  801f25:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f28:	74 df                	je     801f09 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f2a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f2f:	79 05                	jns    801f36 <devpipe_read+0x4a>
  801f31:	48                   	dec    %eax
  801f32:	83 c8 e0             	or     $0xffffffe0,%eax
  801f35:	40                   	inc    %eax
  801f36:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f40:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f42:	46                   	inc    %esi
  801f43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f46:	75 db                	jne    801f23 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f48:	89 f0                	mov    %esi,%eax
  801f4a:	eb 05                	jmp    801f51 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f51:	83 c4 1c             	add    $0x1c,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	57                   	push   %edi
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
  801f5f:	83 ec 3c             	sub    $0x3c,%esp
  801f62:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f68:	89 04 24             	mov    %eax,(%esp)
  801f6b:	e8 9b f5 ff ff       	call   80150b <fd_alloc>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	85 c0                	test   %eax,%eax
  801f74:	0f 88 45 01 00 00    	js     8020bf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f7a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f81:	00 
  801f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f90:	e8 c0 ed ff ff       	call   800d55 <sys_page_alloc>
  801f95:	89 c3                	mov    %eax,%ebx
  801f97:	85 c0                	test   %eax,%eax
  801f99:	0f 88 20 01 00 00    	js     8020bf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f9f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fa2:	89 04 24             	mov    %eax,(%esp)
  801fa5:	e8 61 f5 ff ff       	call   80150b <fd_alloc>
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	85 c0                	test   %eax,%eax
  801fae:	0f 88 f8 00 00 00    	js     8020ac <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fbb:	00 
  801fbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fca:	e8 86 ed ff ff       	call   800d55 <sys_page_alloc>
  801fcf:	89 c3                	mov    %eax,%ebx
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	0f 88 d3 00 00 00    	js     8020ac <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fdc:	89 04 24             	mov    %eax,(%esp)
  801fdf:	e8 0c f5 ff ff       	call   8014f0 <fd2data>
  801fe4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fed:	00 
  801fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff9:	e8 57 ed ff ff       	call   800d55 <sys_page_alloc>
  801ffe:	89 c3                	mov    %eax,%ebx
  802000:	85 c0                	test   %eax,%eax
  802002:	0f 88 91 00 00 00    	js     802099 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802008:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 dd f4 ff ff       	call   8014f0 <fd2data>
  802013:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80201a:	00 
  80201b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802026:	00 
  802027:	89 74 24 04          	mov    %esi,0x4(%esp)
  80202b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802032:	e8 72 ed ff ff       	call   800da9 <sys_page_map>
  802037:	89 c3                	mov    %eax,%ebx
  802039:	85 c0                	test   %eax,%eax
  80203b:	78 4c                	js     802089 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80203d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802043:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802046:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802048:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80204b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802052:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802058:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80205b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80205d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802060:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206a:	89 04 24             	mov    %eax,(%esp)
  80206d:	e8 6e f4 ff ff       	call   8014e0 <fd2num>
  802072:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802074:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802077:	89 04 24             	mov    %eax,(%esp)
  80207a:	e8 61 f4 ff ff       	call   8014e0 <fd2num>
  80207f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802082:	bb 00 00 00 00       	mov    $0x0,%ebx
  802087:	eb 36                	jmp    8020bf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802094:	e8 63 ed ff ff       	call   800dfc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802099:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80209c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a7:	e8 50 ed ff ff       	call   800dfc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ba:	e8 3d ed ff ff       	call   800dfc <sys_page_unmap>
    err:
	return r;
}
  8020bf:	89 d8                	mov    %ebx,%eax
  8020c1:	83 c4 3c             	add    $0x3c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    

008020c9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 7d f4 ff ff       	call   80155e <fd_lookup>
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 15                	js     8020fa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e8:	89 04 24             	mov    %eax,(%esp)
  8020eb:	e8 00 f4 ff ff       	call   8014f0 <fd2data>
	return _pipeisclosed(fd, p);
  8020f0:	89 c2                	mov    %eax,%edx
  8020f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f5:	e8 15 fd ff ff       	call   801e0f <_pipeisclosed>
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    

00802106 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80210c:	c7 44 24 04 20 2c 80 	movl   $0x802c20,0x4(%esp)
  802113:	00 
  802114:	8b 45 0c             	mov    0xc(%ebp),%eax
  802117:	89 04 24             	mov    %eax,(%esp)
  80211a:	e8 44 e8 ff ff       	call   800963 <strcpy>
	return 0;
}
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802132:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802137:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213d:	eb 30                	jmp    80216f <devcons_write+0x49>
		m = n - tot;
  80213f:	8b 75 10             	mov    0x10(%ebp),%esi
  802142:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802144:	83 fe 7f             	cmp    $0x7f,%esi
  802147:	76 05                	jbe    80214e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802149:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80214e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802152:	03 45 0c             	add    0xc(%ebp),%eax
  802155:	89 44 24 04          	mov    %eax,0x4(%esp)
  802159:	89 3c 24             	mov    %edi,(%esp)
  80215c:	e8 7b e9 ff ff       	call   800adc <memmove>
		sys_cputs(buf, m);
  802161:	89 74 24 04          	mov    %esi,0x4(%esp)
  802165:	89 3c 24             	mov    %edi,(%esp)
  802168:	e8 1b eb ff ff       	call   800c88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80216d:	01 f3                	add    %esi,%ebx
  80216f:	89 d8                	mov    %ebx,%eax
  802171:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802174:	72 c9                	jb     80213f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802176:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    

00802181 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802187:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80218b:	75 07                	jne    802194 <devcons_read+0x13>
  80218d:	eb 25                	jmp    8021b4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80218f:	e8 a2 eb ff ff       	call   800d36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802194:	e8 0d eb ff ff       	call   800ca6 <sys_cgetc>
  802199:	85 c0                	test   %eax,%eax
  80219b:	74 f2                	je     80218f <devcons_read+0xe>
  80219d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	78 1d                	js     8021c0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021a3:	83 f8 04             	cmp    $0x4,%eax
  8021a6:	74 13                	je     8021bb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ab:	88 10                	mov    %dl,(%eax)
	return 1;
  8021ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b2:	eb 0c                	jmp    8021c0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b9:	eb 05                	jmp    8021c0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021bb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021d5:	00 
  8021d6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d9:	89 04 24             	mov    %eax,(%esp)
  8021dc:	e8 a7 ea ff ff       	call   800c88 <sys_cputs>
}
  8021e1:	c9                   	leave  
  8021e2:	c3                   	ret    

008021e3 <getchar>:

int
getchar(void)
{
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021f0:	00 
  8021f1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ff:	e8 f6 f5 ff ff       	call   8017fa <read>
	if (r < 0)
  802204:	85 c0                	test   %eax,%eax
  802206:	78 0f                	js     802217 <getchar+0x34>
		return r;
	if (r < 1)
  802208:	85 c0                	test   %eax,%eax
  80220a:	7e 06                	jle    802212 <getchar+0x2f>
		return -E_EOF;
	return c;
  80220c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802210:	eb 05                	jmp    802217 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802212:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802217:	c9                   	leave  
  802218:	c3                   	ret    

00802219 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80221f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802222:	89 44 24 04          	mov    %eax,0x4(%esp)
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	89 04 24             	mov    %eax,(%esp)
  80222c:	e8 2d f3 ff ff       	call   80155e <fd_lookup>
  802231:	85 c0                	test   %eax,%eax
  802233:	78 11                	js     802246 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80223e:	39 10                	cmp    %edx,(%eax)
  802240:	0f 94 c0             	sete   %al
  802243:	0f b6 c0             	movzbl %al,%eax
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <opencons>:

int
opencons(void)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80224e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802251:	89 04 24             	mov    %eax,(%esp)
  802254:	e8 b2 f2 ff ff       	call   80150b <fd_alloc>
  802259:	85 c0                	test   %eax,%eax
  80225b:	78 3c                	js     802299 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80225d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802264:	00 
  802265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802273:	e8 dd ea ff ff       	call   800d55 <sys_page_alloc>
  802278:	85 c0                	test   %eax,%eax
  80227a:	78 1d                	js     802299 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80227c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802285:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802287:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802291:	89 04 24             	mov    %eax,(%esp)
  802294:	e8 47 f2 ff ff       	call   8014e0 <fd2num>
}
  802299:	c9                   	leave  
  80229a:	c3                   	ret    
	...

0080229c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022a2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022a9:	0f 85 80 00 00 00    	jne    80232f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8022af:	a1 04 40 80 00       	mov    0x804004,%eax
  8022b4:	8b 40 48             	mov    0x48(%eax),%eax
  8022b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022be:	00 
  8022bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8022c6:	ee 
  8022c7:	89 04 24             	mov    %eax,(%esp)
  8022ca:	e8 86 ea ff ff       	call   800d55 <sys_page_alloc>
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	79 20                	jns    8022f3 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8022d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d7:	c7 44 24 08 2c 2c 80 	movl   $0x802c2c,0x8(%esp)
  8022de:	00 
  8022df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8022e6:	00 
  8022e7:	c7 04 24 88 2c 80 00 	movl   $0x802c88,(%esp)
  8022ee:	e8 ad df ff ff       	call   8002a0 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8022f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8022f8:	8b 40 48             	mov    0x48(%eax),%eax
  8022fb:	c7 44 24 04 3c 23 80 	movl   $0x80233c,0x4(%esp)
  802302:	00 
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 ea eb ff ff       	call   800ef5 <sys_env_set_pgfault_upcall>
  80230b:	85 c0                	test   %eax,%eax
  80230d:	79 20                	jns    80232f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80230f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802313:	c7 44 24 08 58 2c 80 	movl   $0x802c58,0x8(%esp)
  80231a:	00 
  80231b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  802322:	00 
  802323:	c7 04 24 88 2c 80 00 	movl   $0x802c88,(%esp)
  80232a:	e8 71 df ff ff       	call   8002a0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80232f:	8b 45 08             	mov    0x8(%ebp),%eax
  802332:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802337:	c9                   	leave  
  802338:	c3                   	ret    
  802339:	00 00                	add    %al,(%eax)
	...

0080233c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80233c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80233d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802342:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802344:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802347:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80234b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80234d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802350:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802351:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802354:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  802356:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802359:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80235a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80235d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80235e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80235f:	c3                   	ret    

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	83 ec 10             	sub    $0x10,%esp
  802366:	8b 74 24 20          	mov    0x20(%esp),%esi
  80236a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80236e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802372:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802376:	89 cd                	mov    %ecx,%ebp
  802378:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80237c:	85 c0                	test   %eax,%eax
  80237e:	75 2c                	jne    8023ac <__udivdi3+0x4c>
  802380:	39 f9                	cmp    %edi,%ecx
  802382:	77 68                	ja     8023ec <__udivdi3+0x8c>
  802384:	85 c9                	test   %ecx,%ecx
  802386:	75 0b                	jne    802393 <__udivdi3+0x33>
  802388:	b8 01 00 00 00       	mov    $0x1,%eax
  80238d:	31 d2                	xor    %edx,%edx
  80238f:	f7 f1                	div    %ecx
  802391:	89 c1                	mov    %eax,%ecx
  802393:	31 d2                	xor    %edx,%edx
  802395:	89 f8                	mov    %edi,%eax
  802397:	f7 f1                	div    %ecx
  802399:	89 c7                	mov    %eax,%edi
  80239b:	89 f0                	mov    %esi,%eax
  80239d:	f7 f1                	div    %ecx
  80239f:	89 c6                	mov    %eax,%esi
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	89 fa                	mov    %edi,%edx
  8023a5:	83 c4 10             	add    $0x10,%esp
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	39 f8                	cmp    %edi,%eax
  8023ae:	77 2c                	ja     8023dc <__udivdi3+0x7c>
  8023b0:	0f bd f0             	bsr    %eax,%esi
  8023b3:	83 f6 1f             	xor    $0x1f,%esi
  8023b6:	75 4c                	jne    802404 <__udivdi3+0xa4>
  8023b8:	39 f8                	cmp    %edi,%eax
  8023ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8023bf:	72 0a                	jb     8023cb <__udivdi3+0x6b>
  8023c1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023c5:	0f 87 ad 00 00 00    	ja     802478 <__udivdi3+0x118>
  8023cb:	be 01 00 00 00       	mov    $0x1,%esi
  8023d0:	89 f0                	mov    %esi,%eax
  8023d2:	89 fa                	mov    %edi,%edx
  8023d4:	83 c4 10             	add    $0x10,%esp
  8023d7:	5e                   	pop    %esi
  8023d8:	5f                   	pop    %edi
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    
  8023db:	90                   	nop
  8023dc:	31 ff                	xor    %edi,%edi
  8023de:	31 f6                	xor    %esi,%esi
  8023e0:	89 f0                	mov    %esi,%eax
  8023e2:	89 fa                	mov    %edi,%edx
  8023e4:	83 c4 10             	add    $0x10,%esp
  8023e7:	5e                   	pop    %esi
  8023e8:	5f                   	pop    %edi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    
  8023eb:	90                   	nop
  8023ec:	89 fa                	mov    %edi,%edx
  8023ee:	89 f0                	mov    %esi,%eax
  8023f0:	f7 f1                	div    %ecx
  8023f2:	89 c6                	mov    %eax,%esi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 f0                	mov    %esi,%eax
  8023f8:	89 fa                	mov    %edi,%edx
  8023fa:	83 c4 10             	add    $0x10,%esp
  8023fd:	5e                   	pop    %esi
  8023fe:	5f                   	pop    %edi
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    
  802401:	8d 76 00             	lea    0x0(%esi),%esi
  802404:	89 f1                	mov    %esi,%ecx
  802406:	d3 e0                	shl    %cl,%eax
  802408:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240c:	b8 20 00 00 00       	mov    $0x20,%eax
  802411:	29 f0                	sub    %esi,%eax
  802413:	89 ea                	mov    %ebp,%edx
  802415:	88 c1                	mov    %al,%cl
  802417:	d3 ea                	shr    %cl,%edx
  802419:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80241d:	09 ca                	or     %ecx,%edx
  80241f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802423:	89 f1                	mov    %esi,%ecx
  802425:	d3 e5                	shl    %cl,%ebp
  802427:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80242b:	89 fd                	mov    %edi,%ebp
  80242d:	88 c1                	mov    %al,%cl
  80242f:	d3 ed                	shr    %cl,%ebp
  802431:	89 fa                	mov    %edi,%edx
  802433:	89 f1                	mov    %esi,%ecx
  802435:	d3 e2                	shl    %cl,%edx
  802437:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80243b:	88 c1                	mov    %al,%cl
  80243d:	d3 ef                	shr    %cl,%edi
  80243f:	09 d7                	or     %edx,%edi
  802441:	89 f8                	mov    %edi,%eax
  802443:	89 ea                	mov    %ebp,%edx
  802445:	f7 74 24 08          	divl   0x8(%esp)
  802449:	89 d1                	mov    %edx,%ecx
  80244b:	89 c7                	mov    %eax,%edi
  80244d:	f7 64 24 0c          	mull   0xc(%esp)
  802451:	39 d1                	cmp    %edx,%ecx
  802453:	72 17                	jb     80246c <__udivdi3+0x10c>
  802455:	74 09                	je     802460 <__udivdi3+0x100>
  802457:	89 fe                	mov    %edi,%esi
  802459:	31 ff                	xor    %edi,%edi
  80245b:	e9 41 ff ff ff       	jmp    8023a1 <__udivdi3+0x41>
  802460:	8b 54 24 04          	mov    0x4(%esp),%edx
  802464:	89 f1                	mov    %esi,%ecx
  802466:	d3 e2                	shl    %cl,%edx
  802468:	39 c2                	cmp    %eax,%edx
  80246a:	73 eb                	jae    802457 <__udivdi3+0xf7>
  80246c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80246f:	31 ff                	xor    %edi,%edi
  802471:	e9 2b ff ff ff       	jmp    8023a1 <__udivdi3+0x41>
  802476:	66 90                	xchg   %ax,%ax
  802478:	31 f6                	xor    %esi,%esi
  80247a:	e9 22 ff ff ff       	jmp    8023a1 <__udivdi3+0x41>
	...

00802480 <__umoddi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	83 ec 20             	sub    $0x20,%esp
  802486:	8b 44 24 30          	mov    0x30(%esp),%eax
  80248a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80248e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802492:	8b 74 24 34          	mov    0x34(%esp),%esi
  802496:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80249a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80249e:	89 c7                	mov    %eax,%edi
  8024a0:	89 f2                	mov    %esi,%edx
  8024a2:	85 ed                	test   %ebp,%ebp
  8024a4:	75 16                	jne    8024bc <__umoddi3+0x3c>
  8024a6:	39 f1                	cmp    %esi,%ecx
  8024a8:	0f 86 a6 00 00 00    	jbe    802554 <__umoddi3+0xd4>
  8024ae:	f7 f1                	div    %ecx
  8024b0:	89 d0                	mov    %edx,%eax
  8024b2:	31 d2                	xor    %edx,%edx
  8024b4:	83 c4 20             	add    $0x20,%esp
  8024b7:	5e                   	pop    %esi
  8024b8:	5f                   	pop    %edi
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    
  8024bb:	90                   	nop
  8024bc:	39 f5                	cmp    %esi,%ebp
  8024be:	0f 87 ac 00 00 00    	ja     802570 <__umoddi3+0xf0>
  8024c4:	0f bd c5             	bsr    %ebp,%eax
  8024c7:	83 f0 1f             	xor    $0x1f,%eax
  8024ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024ce:	0f 84 a8 00 00 00    	je     80257c <__umoddi3+0xfc>
  8024d4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d8:	d3 e5                	shl    %cl,%ebp
  8024da:	bf 20 00 00 00       	mov    $0x20,%edi
  8024df:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8024e3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024e7:	89 f9                	mov    %edi,%ecx
  8024e9:	d3 e8                	shr    %cl,%eax
  8024eb:	09 e8                	or     %ebp,%eax
  8024ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8024f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024f5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024f9:	d3 e0                	shl    %cl,%eax
  8024fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ff:	89 f2                	mov    %esi,%edx
  802501:	d3 e2                	shl    %cl,%edx
  802503:	8b 44 24 14          	mov    0x14(%esp),%eax
  802507:	d3 e0                	shl    %cl,%eax
  802509:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80250d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802511:	89 f9                	mov    %edi,%ecx
  802513:	d3 e8                	shr    %cl,%eax
  802515:	09 d0                	or     %edx,%eax
  802517:	d3 ee                	shr    %cl,%esi
  802519:	89 f2                	mov    %esi,%edx
  80251b:	f7 74 24 18          	divl   0x18(%esp)
  80251f:	89 d6                	mov    %edx,%esi
  802521:	f7 64 24 0c          	mull   0xc(%esp)
  802525:	89 c5                	mov    %eax,%ebp
  802527:	89 d1                	mov    %edx,%ecx
  802529:	39 d6                	cmp    %edx,%esi
  80252b:	72 67                	jb     802594 <__umoddi3+0x114>
  80252d:	74 75                	je     8025a4 <__umoddi3+0x124>
  80252f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802533:	29 e8                	sub    %ebp,%eax
  802535:	19 ce                	sbb    %ecx,%esi
  802537:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	89 f2                	mov    %esi,%edx
  80253f:	89 f9                	mov    %edi,%ecx
  802541:	d3 e2                	shl    %cl,%edx
  802543:	09 d0                	or     %edx,%eax
  802545:	89 f2                	mov    %esi,%edx
  802547:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80254b:	d3 ea                	shr    %cl,%edx
  80254d:	83 c4 20             	add    $0x20,%esp
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	85 c9                	test   %ecx,%ecx
  802556:	75 0b                	jne    802563 <__umoddi3+0xe3>
  802558:	b8 01 00 00 00       	mov    $0x1,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	f7 f1                	div    %ecx
  802561:	89 c1                	mov    %eax,%ecx
  802563:	89 f0                	mov    %esi,%eax
  802565:	31 d2                	xor    %edx,%edx
  802567:	f7 f1                	div    %ecx
  802569:	89 f8                	mov    %edi,%eax
  80256b:	e9 3e ff ff ff       	jmp    8024ae <__umoddi3+0x2e>
  802570:	89 f2                	mov    %esi,%edx
  802572:	83 c4 20             	add    $0x20,%esp
  802575:	5e                   	pop    %esi
  802576:	5f                   	pop    %edi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    
  802579:	8d 76 00             	lea    0x0(%esi),%esi
  80257c:	39 f5                	cmp    %esi,%ebp
  80257e:	72 04                	jb     802584 <__umoddi3+0x104>
  802580:	39 f9                	cmp    %edi,%ecx
  802582:	77 06                	ja     80258a <__umoddi3+0x10a>
  802584:	89 f2                	mov    %esi,%edx
  802586:	29 cf                	sub    %ecx,%edi
  802588:	19 ea                	sbb    %ebp,%edx
  80258a:	89 f8                	mov    %edi,%eax
  80258c:	83 c4 20             	add    $0x20,%esp
  80258f:	5e                   	pop    %esi
  802590:	5f                   	pop    %edi
  802591:	5d                   	pop    %ebp
  802592:	c3                   	ret    
  802593:	90                   	nop
  802594:	89 d1                	mov    %edx,%ecx
  802596:	89 c5                	mov    %eax,%ebp
  802598:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80259c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025a0:	eb 8d                	jmp    80252f <__umoddi3+0xaf>
  8025a2:	66 90                	xchg   %ax,%ax
  8025a4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025a8:	72 ea                	jb     802594 <__umoddi3+0x114>
  8025aa:	89 f1                	mov    %esi,%ecx
  8025ac:	eb 81                	jmp    80252f <__umoddi3+0xaf>
