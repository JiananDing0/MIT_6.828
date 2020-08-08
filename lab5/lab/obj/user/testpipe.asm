
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e7 02 00 00       	call   800318 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 30 80 00 20 	movl   $0x802720,0x803004
  800043:	27 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 94 1e 00 00       	call   801ee5 <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  800072:	e8 11 03 00 00       	call   800388 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 3b 11 00 00       	call   8011b7 <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 81 2c 80 	movl   $0x802c81,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  80009d:	e8 e6 02 00 00       	call   800388 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d5 00 00 00    	jne    80017f <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 45 27 80 00 	movl   $0x802745,(%esp)
  8000c4:	e8 b7 03 00 00       	call   800480 <cprintf>
		close(p[1]);
  8000c9:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 92 15 00 00       	call   801666 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d9:	8b 40 48             	mov    0x48(%eax),%eax
  8000dc:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e7:	c7 04 24 62 27 80 00 	movl   $0x802762,(%esp)
  8000ee:	e8 8d 03 00 00       	call   800480 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f3:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fa:	00 
  8000fb:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 4d 17 00 00       	call   80185a <readn>
  80010d:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0xff>
			panic("read: %e", i);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 7f 27 80 	movl   $0x80277f,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  80012e:	e8 55 02 00 00       	call   800388 <_panic>
		buf[i] = 0;
  800133:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800138:	a1 00 30 80 00       	mov    0x803000,%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 a6 09 00 00       	call   800af2 <strcmp>
  80014c:	85 c0                	test   %eax,%eax
  80014e:	75 0e                	jne    80015e <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  800150:	c7 04 24 88 27 80 00 	movl   $0x802788,(%esp)
  800157:	e8 24 03 00 00       	call   800480 <cprintf>
  80015c:	eb 17                	jmp    800175 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015e:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	89 74 24 04          	mov    %esi,0x4(%esp)
  800169:	c7 04 24 a4 27 80 00 	movl   $0x8027a4,(%esp)
  800170:	e8 0b 03 00 00       	call   800480 <cprintf>
		exit();
  800175:	e8 f2 01 00 00       	call   80036c <exit>
  80017a:	e9 ac 00 00 00       	jmp    80022b <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017f:	a1 04 40 80 00       	mov    0x804004,%eax
  800184:	8b 40 48             	mov    0x48(%eax),%eax
  800187:	8b 55 8c             	mov    -0x74(%ebp),%edx
  80018a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 45 27 80 00 	movl   $0x802745,(%esp)
  800199:	e8 e2 02 00 00       	call   800480 <cprintf>
		close(p[0]);
  80019e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 bd 14 00 00       	call   801666 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8001ae:	8b 40 48             	mov    0x48(%eax),%eax
  8001b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 b7 27 80 00 	movl   $0x8027b7,(%esp)
  8001c3:	e8 b8 02 00 00       	call   800480 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 43 08 00 00       	call   800a18 <strlen>
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 30 80 00       	mov    0x803000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 b8 16 00 00       	call   8018a5 <write>
  8001ed:	89 c6                	mov    %eax,%esi
  8001ef:	a1 00 30 80 00       	mov    0x803000,%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 1c 08 00 00       	call   800a18 <strlen>
  8001fc:	39 c6                	cmp    %eax,%esi
  8001fe:	74 20                	je     800220 <umain+0x1ec>
			panic("write: %e", i);
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	c7 44 24 08 d4 27 80 	movl   $0x8027d4,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  80021b:	e8 68 01 00 00       	call   800388 <_panic>
		close(p[1]);
  800220:	8b 45 90             	mov    -0x70(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 3b 14 00 00       	call   801666 <close>
	}
	wait(pid);
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	e8 55 1e 00 00       	call   802088 <wait>

	binaryname = "pipewriteeof";
  800233:	c7 05 04 30 80 00 de 	movl   $0x8027de,0x803004
  80023a:	27 80 00 
	if ((i = pipe(p)) < 0)
  80023d:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 9d 1c 00 00       	call   801ee5 <pipe>
  800248:	89 c6                	mov    %eax,%esi
  80024a:	85 c0                	test   %eax,%eax
  80024c:	79 20                	jns    80026e <umain+0x23a>
		panic("pipe: %e", i);
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  800269:	e8 1a 01 00 00       	call   800388 <_panic>

	if ((pid = fork()) < 0)
  80026e:	e8 44 0f 00 00       	call   8011b7 <fork>
  800273:	89 c3                	mov    %eax,%ebx
  800275:	85 c0                	test   %eax,%eax
  800277:	79 20                	jns    800299 <umain+0x265>
		panic("fork: %e", i);
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	c7 44 24 08 81 2c 80 	movl   $0x802c81,0x8(%esp)
  800284:	00 
  800285:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028c:	00 
  80028d:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  800294:	e8 ef 00 00 00       	call   800388 <_panic>

	if (pid == 0) {
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 48                	jne    8002e5 <umain+0x2b1>
		close(p[0]);
  80029d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 be 13 00 00       	call   801666 <close>
		while (1) {
			cprintf(".");
  8002a8:	c7 04 24 eb 27 80 00 	movl   $0x8027eb,(%esp)
  8002af:	e8 cc 01 00 00       	call   800480 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002bb:	00 
  8002bc:	c7 44 24 04 ed 27 80 	movl   $0x8027ed,0x4(%esp)
  8002c3:	00 
  8002c4:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 d6 15 00 00       	call   8018a5 <write>
  8002cf:	83 f8 01             	cmp    $0x1,%eax
  8002d2:	74 d4                	je     8002a8 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d4:	c7 04 24 ef 27 80 00 	movl   $0x8027ef,(%esp)
  8002db:	e8 a0 01 00 00       	call   800480 <cprintf>
		exit();
  8002e0:	e8 87 00 00 00       	call   80036c <exit>
	}
	close(p[0]);
  8002e5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 76 13 00 00       	call   801666 <close>
	close(p[1]);
  8002f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 6b 13 00 00       	call   801666 <close>
	wait(pid);
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	e8 85 1d 00 00       	call   802088 <wait>

	cprintf("pipe tests passed\n");
  800303:	c7 04 24 0c 28 80 00 	movl   $0x80280c,(%esp)
  80030a:	e8 71 01 00 00       	call   800480 <cprintf>
}
  80030f:	83 ec 80             	sub    $0xffffff80,%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    
	...

00800318 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	83 ec 10             	sub    $0x10,%esp
  800320:	8b 75 08             	mov    0x8(%ebp),%esi
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800326:	e8 d4 0a 00 00       	call   800dff <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80032b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800330:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800337:	c1 e0 07             	shl    $0x7,%eax
  80033a:	29 d0                	sub    %edx,%eax
  80033c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800341:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800346:	85 f6                	test   %esi,%esi
  800348:	7e 07                	jle    800351 <libmain+0x39>
		binaryname = argv[0];
  80034a:	8b 03                	mov    (%ebx),%eax
  80034c:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	89 34 24             	mov    %esi,(%esp)
  800358:	e8 d7 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80035d:	e8 0a 00 00 00       	call   80036c <exit>
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    
  800369:	00 00                	add    %al,(%eax)
	...

0080036c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800372:	e8 20 13 00 00       	call   801697 <close_all>
	sys_env_destroy(0);
  800377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80037e:	e8 2a 0a 00 00       	call   800dad <sys_env_destroy>
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    
  800385:	00 00                	add    %al,(%eax)
	...

00800388 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800393:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800399:	e8 61 0a 00 00       	call   800dff <sys_getenvid>
  80039e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  8003bb:	e8 c0 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	e8 50 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003cf:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  8003d6:	e8 a5 00 00 00       	call   800480 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003db:	cc                   	int3   
  8003dc:	eb fd                	jmp    8003db <_panic+0x53>
	...

008003e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 14             	sub    $0x14,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ea:	8b 03                	mov    (%ebx),%eax
  8003ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f3:	40                   	inc    %eax
  8003f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fb:	75 19                	jne    800416 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800404:	00 
  800405:	8d 43 08             	lea    0x8(%ebx),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 60 09 00 00       	call   800d70 <sys_cputs>
		b->idx = 0;
  800410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800416:	ff 43 04             	incl   0x4(%ebx)
}
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  80045b:	e8 82 01 00 00       	call   8005e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 f8 08 00 00       	call   800d70 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800486:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 87 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    
	...

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 3c             	sub    $0x3c,%esp
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	89 d7                	mov    %edx,%edi
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	75 08                	jne    8004c8 <printnum+0x2c>
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004c6:	77 57                	ja     80051f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004cc:	4b                   	dec    %ebx
  8004cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e7:	00 
  8004e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	e8 ba 1f 00 00       	call   8024b4 <__udivdi3>
  8004fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	89 fa                	mov    %edi,%edx
  80050b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050e:	e8 89 ff ff ff       	call   80049c <printnum>
  800513:	eb 0f                	jmp    800524 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 34 24             	mov    %esi,(%esp)
  80051c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051f:	4b                   	dec    %ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f f1                	jg     800515 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800524:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800528:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80052c:	8b 45 10             	mov    0x10(%ebp),%eax
  80052f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800533:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053a:	00 
  80053b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	89 44 24 04          	mov    %eax,0x4(%esp)
  800548:	e8 87 20 00 00       	call   8025d4 <__umoddi3>
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	0f be 80 93 28 80 00 	movsbl 0x802893(%eax),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80055e:	83 c4 3c             	add    $0x3c,%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 0e                	jle    80057c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8d 4a 08             	lea    0x8(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 22                	jmp    80059e <getuint+0x38>
	else if (lflag)
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 10                	je     800590 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800580:	8b 10                	mov    (%eax),%edx
  800582:	8d 4a 04             	lea    0x4(%edx),%ecx
  800585:	89 08                	mov    %ecx,(%eax)
  800587:	8b 02                	mov    (%edx),%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 0e                	jmp    80059e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ae:	73 08                	jae    8005b8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b3:	88 0a                	mov    %cl,(%edx)
  8005b5:	42                   	inc    %edx
  8005b6:	89 10                	mov    %edx,(%eax)
}
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    

008005ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	e8 02 00 00 00       	call   8005e2 <vprintfmt>
	va_end(ap);
}
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	57                   	push   %edi
  8005e6:	56                   	push   %esi
  8005e7:	53                   	push   %ebx
  8005e8:	83 ec 4c             	sub    $0x4c,%esp
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f1:	eb 12                	jmp    800605 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	0f 84 8b 03 00 00    	je     800986 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8005fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800605:	0f b6 06             	movzbl (%esi),%eax
  800608:	46                   	inc    %esi
  800609:	83 f8 25             	cmp    $0x25,%eax
  80060c:	75 e5                	jne    8005f3 <vprintfmt+0x11>
  80060e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800612:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800619:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80061e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800633:	eb 1d                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800638:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80063c:	eb 14                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800641:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800648:	eb 08                	jmp    800652 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80064a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80064d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	0f b6 06             	movzbl (%esi),%eax
  800655:	8d 56 01             	lea    0x1(%esi),%edx
  800658:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065b:	8a 16                	mov    (%esi),%dl
  80065d:	83 ea 23             	sub    $0x23,%edx
  800660:	80 fa 55             	cmp    $0x55,%dl
  800663:	0f 87 01 03 00 00    	ja     80096a <vprintfmt+0x388>
  800669:	0f b6 d2             	movzbl %dl,%edx
  80066c:	ff 24 95 e0 29 80 00 	jmp    *0x8029e0(,%edx,4)
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80067e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800682:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800685:	8d 50 d0             	lea    -0x30(%eax),%edx
  800688:	83 fa 09             	cmp    $0x9,%edx
  80068b:	77 2a                	ja     8006b7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80068d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80068e:	eb eb                	jmp    80067b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069e:	eb 17                	jmp    8006b7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a4:	78 98                	js     80063e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a9:	eb a7                	jmp    800652 <vprintfmt+0x70>
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b5:	eb 9b                	jmp    800652 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bb:	79 95                	jns    800652 <vprintfmt+0x70>
  8006bd:	eb 8b                	jmp    80064a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006bf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c3:	eb 8d                	jmp    800652 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006dd:	e9 23 ff ff ff       	jmp    800605 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	79 02                	jns    8006f3 <vprintfmt+0x111>
  8006f1:	f7 d8                	neg    %eax
  8006f3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f5:	83 f8 0f             	cmp    $0xf,%eax
  8006f8:	7f 0b                	jg     800705 <vprintfmt+0x123>
  8006fa:	8b 04 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	75 23                	jne    800728 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800705:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800709:	c7 44 24 08 ab 28 80 	movl   $0x8028ab,0x8(%esp)
  800710:	00 
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	e8 9a fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800723:	e9 dd fe ff ff       	jmp    800605 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800728:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072c:	c7 44 24 08 9a 2d 80 	movl   $0x802d9a,0x8(%esp)
  800733:	00 
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	89 14 24             	mov    %edx,(%esp)
  80073e:	e8 77 fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800746:	e9 ba fe ff ff       	jmp    800605 <vprintfmt+0x23>
  80074b:	89 f9                	mov    %edi,%ecx
  80074d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800750:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	8b 30                	mov    (%eax),%esi
  80075e:	85 f6                	test   %esi,%esi
  800760:	75 05                	jne    800767 <vprintfmt+0x185>
				p = "(null)";
  800762:	be a4 28 80 00       	mov    $0x8028a4,%esi
			if (width > 0 && padc != '-')
  800767:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076b:	0f 8e 84 00 00 00    	jle    8007f5 <vprintfmt+0x213>
  800771:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800775:	74 7e                	je     8007f5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800777:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077b:	89 34 24             	mov    %esi,(%esp)
  80077e:	e8 ab 02 00 00       	call   800a2e <strnlen>
  800783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800786:	29 c2                	sub    %eax,%edx
  800788:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80078b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80078f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800792:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800795:	89 de                	mov    %ebx,%esi
  800797:	89 d3                	mov    %edx,%ebx
  800799:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079b:	eb 0b                	jmp    8007a8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	89 3c 24             	mov    %edi,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a7:	4b                   	dec    %ebx
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7f f1                	jg     80079d <vprintfmt+0x1bb>
  8007ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007af:	89 f3                	mov    %esi,%ebx
  8007b1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	79 05                	jns    8007c0 <vprintfmt+0x1de>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c3:	29 c2                	sub    %eax,%edx
  8007c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c8:	eb 2b                	jmp    8007f5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ce:	74 18                	je     8007e8 <vprintfmt+0x206>
  8007d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007d3:	83 fa 5e             	cmp    $0x5e,%edx
  8007d6:	76 10                	jbe    8007e8 <vprintfmt+0x206>
					putch('?', putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
  8007e6:	eb 0a                	jmp    8007f2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f5:	0f be 06             	movsbl (%esi),%eax
  8007f8:	46                   	inc    %esi
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 21                	je     80081e <vprintfmt+0x23c>
  8007fd:	85 ff                	test   %edi,%edi
  8007ff:	78 c9                	js     8007ca <vprintfmt+0x1e8>
  800801:	4f                   	dec    %edi
  800802:	79 c6                	jns    8007ca <vprintfmt+0x1e8>
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
  800807:	89 de                	mov    %ebx,%esi
  800809:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80080c:	eb 18                	jmp    800826 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800812:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800819:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081b:	4b                   	dec    %ebx
  80081c:	eb 08                	jmp    800826 <vprintfmt+0x244>
  80081e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800821:	89 de                	mov    %ebx,%esi
  800823:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800826:	85 db                	test   %ebx,%ebx
  800828:	7f e4                	jg     80080e <vprintfmt+0x22c>
  80082a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80082d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800832:	e9 ce fd ff ff       	jmp    800605 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800837:	83 f9 01             	cmp    $0x1,%ecx
  80083a:	7e 10                	jle    80084c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 08             	lea    0x8(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 30                	mov    (%eax),%esi
  800847:	8b 78 04             	mov    0x4(%eax),%edi
  80084a:	eb 26                	jmp    800872 <vprintfmt+0x290>
	else if (lflag)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 12                	je     800862 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 30                	mov    (%eax),%esi
  80085b:	89 f7                	mov    %esi,%edi
  80085d:	c1 ff 1f             	sar    $0x1f,%edi
  800860:	eb 10                	jmp    800872 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 30                	mov    (%eax),%esi
  80086d:	89 f7                	mov    %esi,%edi
  80086f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800872:	85 ff                	test   %edi,%edi
  800874:	78 0a                	js     800880 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800876:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087b:	e9 ac 00 00 00       	jmp    80092c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80088e:	f7 de                	neg    %esi
  800890:	83 d7 00             	adc    $0x0,%edi
  800893:	f7 df                	neg    %edi
			}
			base = 10;
  800895:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089a:	e9 8d 00 00 00       	jmp    80092c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089f:	89 ca                	mov    %ecx,%edx
  8008a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a4:	e8 bd fc ff ff       	call   800566 <getuint>
  8008a9:	89 c6                	mov    %eax,%esi
  8008ab:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ad:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008b2:	eb 78                	jmp    80092c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008bf:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008cd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008de:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008e1:	e9 1f fd ff ff       	jmp    800605 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ff:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80090b:	8b 30                	mov    (%eax),%esi
  80090d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800912:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800917:	eb 13                	jmp    80092c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800919:	89 ca                	mov    %ecx,%edx
  80091b:	8d 45 14             	lea    0x14(%ebp),%eax
  80091e:	e8 43 fc ff ff       	call   800566 <getuint>
  800923:	89 c6                	mov    %eax,%esi
  800925:	89 d7                	mov    %edx,%edi
			base = 16;
  800927:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80092c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800930:	89 54 24 10          	mov    %edx,0x10(%esp)
  800934:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800937:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80093b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093f:	89 34 24             	mov    %esi,(%esp)
  800942:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800946:	89 da                	mov    %ebx,%edx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	e8 4c fb ff ff       	call   80049c <printnum>
			break;
  800950:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800953:	e9 ad fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800958:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800965:	e9 9b fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800975:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800978:	eb 01                	jmp    80097b <vprintfmt+0x399>
  80097a:	4e                   	dec    %esi
  80097b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80097f:	75 f9                	jne    80097a <vprintfmt+0x398>
  800981:	e9 7f fc ff ff       	jmp    800605 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800986:	83 c4 4c             	add    $0x4c,%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 28             	sub    $0x28,%esp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	74 30                	je     8009df <vsnprintf+0x51>
  8009af:	85 d2                	test   %edx,%edx
  8009b1:	7e 33                	jle    8009e6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c8:	c7 04 24 a0 05 80 00 	movl   $0x8005a0,(%esp)
  8009cf:	e8 0e fc ff ff       	call   8005e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009dd:	eb 0c                	jmp    8009eb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e4:	eb 05                	jmp    8009eb <vsnprintf+0x5d>
  8009e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 7b ff ff ff       	call   80098e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    
  800a15:	00 00                	add    %al,(%eax)
	...

00800a18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a23:	eb 01                	jmp    800a26 <strlen+0xe>
		n++;
  800a25:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a26:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a2a:	75 f9                	jne    800a25 <strlen+0xd>
		n++;
	return n;
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	eb 01                	jmp    800a3f <strnlen+0x11>
		n++;
  800a3e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	74 06                	je     800a49 <strnlen+0x1b>
  800a43:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a47:	75 f5                	jne    800a3e <strnlen+0x10>
		n++;
	return n;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a60:	42                   	inc    %edx
  800a61:	84 c9                	test   %cl,%cl
  800a63:	75 f5                	jne    800a5a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a65:	5b                   	pop    %ebx
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a72:	89 1c 24             	mov    %ebx,(%esp)
  800a75:	e8 9e ff ff ff       	call   800a18 <strlen>
	strcpy(dst + len, src);
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a81:	01 d8                	add    %ebx,%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 c0 ff ff ff       	call   800a4b <strcpy>
	return dst;
}
  800a8b:	89 d8                	mov    %ebx,%eax
  800a8d:	83 c4 08             	add    $0x8,%esp
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa6:	eb 0c                	jmp    800ab4 <strncpy+0x21>
		*dst++ = *src;
  800aa8:	8a 1a                	mov    (%edx),%bl
  800aaa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aad:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab3:	41                   	inc    %ecx
  800ab4:	39 f1                	cmp    %esi,%ecx
  800ab6:	75 f0                	jne    800aa8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aca:	85 d2                	test   %edx,%edx
  800acc:	75 0a                	jne    800ad8 <strlcpy+0x1c>
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	eb 1a                	jmp    800aec <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ad2:	88 18                	mov    %bl,(%eax)
  800ad4:	40                   	inc    %eax
  800ad5:	41                   	inc    %ecx
  800ad6:	eb 02                	jmp    800ada <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ada:	4a                   	dec    %edx
  800adb:	74 0a                	je     800ae7 <strlcpy+0x2b>
  800add:	8a 19                	mov    (%ecx),%bl
  800adf:	84 db                	test   %bl,%bl
  800ae1:	75 ef                	jne    800ad2 <strlcpy+0x16>
  800ae3:	89 c2                	mov    %eax,%edx
  800ae5:	eb 02                	jmp    800ae9 <strlcpy+0x2d>
  800ae7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ae9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800aec:	29 f0                	sub    %esi,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afb:	eb 02                	jmp    800aff <strcmp+0xd>
		p++, q++;
  800afd:	41                   	inc    %ecx
  800afe:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aff:	8a 01                	mov    (%ecx),%al
  800b01:	84 c0                	test   %al,%al
  800b03:	74 04                	je     800b09 <strcmp+0x17>
  800b05:	3a 02                	cmp    (%edx),%al
  800b07:	74 f4                	je     800afd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b09:	0f b6 c0             	movzbl %al,%eax
  800b0c:	0f b6 12             	movzbl (%edx),%edx
  800b0f:	29 d0                	sub    %edx,%eax
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	53                   	push   %ebx
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b20:	eb 03                	jmp    800b25 <strncmp+0x12>
		n--, p++, q++;
  800b22:	4a                   	dec    %edx
  800b23:	40                   	inc    %eax
  800b24:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b25:	85 d2                	test   %edx,%edx
  800b27:	74 14                	je     800b3d <strncmp+0x2a>
  800b29:	8a 18                	mov    (%eax),%bl
  800b2b:	84 db                	test   %bl,%bl
  800b2d:	74 04                	je     800b33 <strncmp+0x20>
  800b2f:	3a 19                	cmp    (%ecx),%bl
  800b31:	74 ef                	je     800b22 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b33:	0f b6 00             	movzbl (%eax),%eax
  800b36:	0f b6 11             	movzbl (%ecx),%edx
  800b39:	29 d0                	sub    %edx,%eax
  800b3b:	eb 05                	jmp    800b42 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b4e:	eb 05                	jmp    800b55 <strchr+0x10>
		if (*s == c)
  800b50:	38 ca                	cmp    %cl,%dl
  800b52:	74 0c                	je     800b60 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b54:	40                   	inc    %eax
  800b55:	8a 10                	mov    (%eax),%dl
  800b57:	84 d2                	test   %dl,%dl
  800b59:	75 f5                	jne    800b50 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b6b:	eb 05                	jmp    800b72 <strfind+0x10>
		if (*s == c)
  800b6d:	38 ca                	cmp    %cl,%dl
  800b6f:	74 07                	je     800b78 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b71:	40                   	inc    %eax
  800b72:	8a 10                	mov    (%eax),%dl
  800b74:	84 d2                	test   %dl,%dl
  800b76:	75 f5                	jne    800b6d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	74 30                	je     800bbd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b93:	75 25                	jne    800bba <memset+0x40>
  800b95:	f6 c1 03             	test   $0x3,%cl
  800b98:	75 20                	jne    800bba <memset+0x40>
		c &= 0xFF;
  800b9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	c1 e3 08             	shl    $0x8,%ebx
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	c1 e6 18             	shl    $0x18,%esi
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	c1 e0 10             	shl    $0x10,%eax
  800bac:	09 f0                	or     %esi,%eax
  800bae:	09 d0                	or     %edx,%eax
  800bb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb5:	fc                   	cld    
  800bb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb8:	eb 03                	jmp    800bbd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bba:	fc                   	cld    
  800bbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd2:	39 c6                	cmp    %eax,%esi
  800bd4:	73 34                	jae    800c0a <memmove+0x46>
  800bd6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd9:	39 d0                	cmp    %edx,%eax
  800bdb:	73 2d                	jae    800c0a <memmove+0x46>
		s += n;
		d += n;
  800bdd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be0:	f6 c2 03             	test   $0x3,%dl
  800be3:	75 1b                	jne    800c00 <memmove+0x3c>
  800be5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800beb:	75 13                	jne    800c00 <memmove+0x3c>
  800bed:	f6 c1 03             	test   $0x3,%cl
  800bf0:	75 0e                	jne    800c00 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf2:	83 ef 04             	sub    $0x4,%edi
  800bf5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bfb:	fd                   	std    
  800bfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfe:	eb 07                	jmp    800c07 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c00:	4f                   	dec    %edi
  800c01:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c04:	fd                   	std    
  800c05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c07:	fc                   	cld    
  800c08:	eb 20                	jmp    800c2a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c10:	75 13                	jne    800c25 <memmove+0x61>
  800c12:	a8 03                	test   $0x3,%al
  800c14:	75 0f                	jne    800c25 <memmove+0x61>
  800c16:	f6 c1 03             	test   $0x3,%cl
  800c19:	75 0a                	jne    800c25 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	fc                   	cld    
  800c21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c23:	eb 05                	jmp    800c2a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c25:	89 c7                	mov    %eax,%edi
  800c27:	fc                   	cld    
  800c28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c34:	8b 45 10             	mov    0x10(%ebp),%eax
  800c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	e8 77 ff ff ff       	call   800bc4 <memmove>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	eb 16                	jmp    800c7b <memcmp+0x2c>
		if (*s1 != *s2)
  800c65:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c68:	42                   	inc    %edx
  800c69:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c6d:	38 c8                	cmp    %cl,%al
  800c6f:	74 0a                	je     800c7b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c71:	0f b6 c0             	movzbl %al,%eax
  800c74:	0f b6 c9             	movzbl %cl,%ecx
  800c77:	29 c8                	sub    %ecx,%eax
  800c79:	eb 09                	jmp    800c84 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7b:	39 da                	cmp    %ebx,%edx
  800c7d:	75 e6                	jne    800c65 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c97:	eb 05                	jmp    800c9e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c99:	38 08                	cmp    %cl,(%eax)
  800c9b:	74 05                	je     800ca2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c9d:	40                   	inc    %eax
  800c9e:	39 d0                	cmp    %edx,%eax
  800ca0:	72 f7                	jb     800c99 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	eb 01                	jmp    800cb3 <strtol+0xf>
		s++;
  800cb2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb3:	8a 02                	mov    (%edx),%al
  800cb5:	3c 20                	cmp    $0x20,%al
  800cb7:	74 f9                	je     800cb2 <strtol+0xe>
  800cb9:	3c 09                	cmp    $0x9,%al
  800cbb:	74 f5                	je     800cb2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cbd:	3c 2b                	cmp    $0x2b,%al
  800cbf:	75 08                	jne    800cc9 <strtol+0x25>
		s++;
  800cc1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc7:	eb 13                	jmp    800cdc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc9:	3c 2d                	cmp    $0x2d,%al
  800ccb:	75 0a                	jne    800cd7 <strtol+0x33>
		s++, neg = 1;
  800ccd:	8d 52 01             	lea    0x1(%edx),%edx
  800cd0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd5:	eb 05                	jmp    800cdc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	74 05                	je     800ce5 <strtol+0x41>
  800ce0:	83 fb 10             	cmp    $0x10,%ebx
  800ce3:	75 28                	jne    800d0d <strtol+0x69>
  800ce5:	8a 02                	mov    (%edx),%al
  800ce7:	3c 30                	cmp    $0x30,%al
  800ce9:	75 10                	jne    800cfb <strtol+0x57>
  800ceb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cef:	75 0a                	jne    800cfb <strtol+0x57>
		s += 2, base = 16;
  800cf1:	83 c2 02             	add    $0x2,%edx
  800cf4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf9:	eb 12                	jmp    800d0d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	75 0e                	jne    800d0d <strtol+0x69>
  800cff:	3c 30                	cmp    $0x30,%al
  800d01:	75 05                	jne    800d08 <strtol+0x64>
		s++, base = 8;
  800d03:	42                   	inc    %edx
  800d04:	b3 08                	mov    $0x8,%bl
  800d06:	eb 05                	jmp    800d0d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d08:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d14:	8a 0a                	mov    (%edx),%cl
  800d16:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d19:	80 fb 09             	cmp    $0x9,%bl
  800d1c:	77 08                	ja     800d26 <strtol+0x82>
			dig = *s - '0';
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 30             	sub    $0x30,%ecx
  800d24:	eb 1e                	jmp    800d44 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d26:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d29:	80 fb 19             	cmp    $0x19,%bl
  800d2c:	77 08                	ja     800d36 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 57             	sub    $0x57,%ecx
  800d34:	eb 0e                	jmp    800d44 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d36:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d39:	80 fb 19             	cmp    $0x19,%bl
  800d3c:	77 12                	ja     800d50 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d3e:	0f be c9             	movsbl %cl,%ecx
  800d41:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d44:	39 f1                	cmp    %esi,%ecx
  800d46:	7d 0c                	jge    800d54 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d48:	42                   	inc    %edx
  800d49:	0f af c6             	imul   %esi,%eax
  800d4c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d4e:	eb c4                	jmp    800d14 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d50:	89 c1                	mov    %eax,%ecx
  800d52:	eb 02                	jmp    800d56 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d54:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5a:	74 05                	je     800d61 <strtol+0xbd>
		*endptr = (char *) s;
  800d5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d5f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d61:	85 ff                	test   %edi,%edi
  800d63:	74 04                	je     800d69 <strtol+0xc5>
  800d65:	89 c8                	mov    %ecx,%eax
  800d67:	f7 d8                	neg    %eax
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    
	...

00800d70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 c3                	mov    %eax,%ebx
  800d83:	89 c7                	mov    %eax,%edi
  800d85:	89 c6                	mov    %eax,%esi
  800d87:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	ba 00 00 00 00       	mov    $0x0,%edx
  800d99:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9e:	89 d1                	mov    %edx,%ecx
  800da0:	89 d3                	mov    %edx,%ebx
  800da2:	89 d7                	mov    %edx,%edi
  800da4:	89 d6                	mov    %edx,%esi
  800da6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	89 ce                	mov    %ecx,%esi
  800dc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 28                	jle    800df7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dda:	00 
  800ddb:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800de2:	00 
  800de3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dea:	00 
  800deb:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800df2:	e8 91 f5 ff ff       	call   800388 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800df7:	83 c4 2c             	add    $0x2c,%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e0f:	89 d1                	mov    %edx,%ecx
  800e11:	89 d3                	mov    %edx,%ebx
  800e13:	89 d7                	mov    %edx,%edi
  800e15:	89 d6                	mov    %edx,%esi
  800e17:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <sys_yield>:

void
sys_yield(void)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	ba 00 00 00 00       	mov    $0x0,%edx
  800e29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e2e:	89 d1                	mov    %edx,%ecx
  800e30:	89 d3                	mov    %edx,%ebx
  800e32:	89 d7                	mov    %edx,%edi
  800e34:	89 d6                	mov    %edx,%esi
  800e36:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
  800e43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	be 00 00 00 00       	mov    $0x0,%esi
  800e4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 f7                	mov    %esi,%edi
  800e5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	7e 28                	jle    800e89 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e65:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e74:	00 
  800e75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7c:	00 
  800e7d:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e84:	e8 ff f4 ff ff       	call   800388 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e89:	83 c4 2c             	add    $0x2c,%esp
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800ea2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7e 28                	jle    800edc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecf:	00 
  800ed0:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800ed7:	e8 ac f4 ff ff       	call   800388 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edc:	83 c4 2c             	add    $0x2c,%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	89 df                	mov    %ebx,%edi
  800eff:	89 de                	mov    %ebx,%esi
  800f01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	7e 28                	jle    800f2f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f12:	00 
  800f13:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f22:	00 
  800f23:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f2a:	e8 59 f4 ff ff       	call   800388 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f2f:	83 c4 2c             	add    $0x2c,%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f45:	b8 08 00 00 00       	mov    $0x8,%eax
  800f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	89 df                	mov    %ebx,%edi
  800f52:	89 de                	mov    %ebx,%esi
  800f54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7e 28                	jle    800f82 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f65:	00 
  800f66:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f7d:	e8 06 f4 ff ff       	call   800388 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f82:	83 c4 2c             	add    $0x2c,%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f98:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 df                	mov    %ebx,%edi
  800fa5:	89 de                	mov    %ebx,%esi
  800fa7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 28                	jle    800fd5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800fd0:	e8 b3 f3 ff ff       	call   800388 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fd5:	83 c4 2c             	add    $0x2c,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800feb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ff0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff6:	89 df                	mov    %ebx,%edi
  800ff8:	89 de                	mov    %ebx,%esi
  800ffa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	7e 28                	jle    801028 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801000:	89 44 24 10          	mov    %eax,0x10(%esp)
  801004:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80100b:	00 
  80100c:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801013:	00 
  801014:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101b:	00 
  80101c:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801023:	e8 60 f3 ff ff       	call   800388 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801028:	83 c4 2c             	add    $0x2c,%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	be 00 00 00 00       	mov    $0x0,%esi
  80103b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801040:	8b 7d 14             	mov    0x14(%ebp),%edi
  801043:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801046:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801061:	b8 0d 00 00 00       	mov    $0xd,%eax
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	89 cb                	mov    %ecx,%ebx
  80106b:	89 cf                	mov    %ecx,%edi
  80106d:	89 ce                	mov    %ecx,%esi
  80106f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 28                	jle    80109d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801098:	e8 eb f2 ff ff       	call   800388 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80109d:	83 c4 2c             	add    $0x2c,%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    
  8010a5:	00 00                	add    %al,(%eax)
	...

008010a8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 24             	sub    $0x24,%esp
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010b2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  8010b4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010b8:	75 20                	jne    8010da <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  8010ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010be:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8010d5:	e8 ae f2 ff ff       	call   800388 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8010da:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8010e0:	89 d8                	mov    %ebx,%eax
  8010e2:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  8010e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ec:	f6 c4 08             	test   $0x8,%ah
  8010ef:	75 1c                	jne    80110d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8010f1:	c7 44 24 08 fc 2b 80 	movl   $0x802bfc,0x8(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  801108:	e8 7b f2 ff ff       	call   800388 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  80110d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801114:	00 
  801115:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80111c:	00 
  80111d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801124:	e8 14 fd ff ff       	call   800e3d <sys_page_alloc>
  801129:	85 c0                	test   %eax,%eax
  80112b:	79 20                	jns    80114d <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  80112d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801131:	c7 44 24 08 56 2c 80 	movl   $0x802c56,0x8(%esp)
  801138:	00 
  801139:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  801148:	e8 3b f2 ff ff       	call   800388 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  80114d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801154:	00 
  801155:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801159:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801160:	e8 5f fa ff ff       	call   800bc4 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  801165:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80116c:	00 
  80116d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801171:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801178:	00 
  801179:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801188:	e8 04 fd ff ff       	call   800e91 <sys_page_map>
  80118d:	85 c0                	test   %eax,%eax
  80118f:	79 20                	jns    8011b1 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  801191:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801195:	c7 44 24 08 69 2c 80 	movl   $0x802c69,0x8(%esp)
  80119c:	00 
  80119d:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8011a4:	00 
  8011a5:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8011ac:	e8 d7 f1 ff ff       	call   800388 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  8011b1:	83 c4 24             	add    $0x24,%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  8011c0:	c7 04 24 a8 10 80 00 	movl   $0x8010a8,(%esp)
  8011c7:	e8 c8 10 00 00       	call   802294 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011cc:	ba 07 00 00 00       	mov    $0x7,%edx
  8011d1:	89 d0                	mov    %edx,%eax
  8011d3:	cd 30                	int    $0x30
  8011d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	79 20                	jns    8011ff <fork+0x48>
		panic("sys_exofork: %e", envid);
  8011df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e3:	c7 44 24 08 7a 2c 80 	movl   $0x802c7a,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8011f2:	00 
  8011f3:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8011fa:	e8 89 f1 ff ff       	call   800388 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  8011ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801203:	75 25                	jne    80122a <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801205:	e8 f5 fb ff ff       	call   800dff <sys_getenvid>
  80120a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80120f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801216:	c1 e0 07             	shl    $0x7,%eax
  801219:	29 d0                	sub    %edx,%eax
  80121b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801220:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801225:	e9 58 02 00 00       	jmp    801482 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  80122a:	bf 00 00 00 00       	mov    $0x0,%edi
  80122f:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801234:	89 f0                	mov    %esi,%eax
  801236:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801239:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801240:	a8 01                	test   $0x1,%al
  801242:	0f 84 7a 01 00 00    	je     8013c2 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801248:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80124f:	a8 01                	test   $0x1,%al
  801251:	0f 84 6b 01 00 00    	je     8013c2 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801257:	a1 04 40 80 00       	mov    0x804004,%eax
  80125c:	8b 40 48             	mov    0x48(%eax),%eax
  80125f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801262:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801269:	f6 c4 04             	test   $0x4,%ah
  80126c:	74 52                	je     8012c0 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80126e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801275:	25 07 0e 00 00       	and    $0xe07,%eax
  80127a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80127e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801285:	89 44 24 08          	mov    %eax,0x8(%esp)
  801289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801290:	89 04 24             	mov    %eax,(%esp)
  801293:	e8 f9 fb ff ff       	call   800e91 <sys_page_map>
  801298:	85 c0                	test   %eax,%eax
  80129a:	0f 89 22 01 00 00    	jns    8013c2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8012a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a4:	c7 44 24 08 8a 2c 80 	movl   $0x802c8a,0x8(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8012b3:	00 
  8012b4:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8012bb:	e8 c8 f0 ff ff       	call   800388 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8012c0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012c7:	f6 c4 08             	test   $0x8,%ah
  8012ca:	75 0f                	jne    8012db <fork+0x124>
  8012cc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012d3:	a8 02                	test   $0x2,%al
  8012d5:	0f 84 99 00 00 00    	je     801374 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8012db:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012e2:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8012e5:	83 f8 01             	cmp    $0x1,%eax
  8012e8:	19 db                	sbb    %ebx,%ebx
  8012ea:	83 e3 fc             	and    $0xfffffffc,%ebx
  8012ed:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8012f3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801302:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 80 fb ff ff       	call   800e91 <sys_page_map>
  801311:	85 c0                	test   %eax,%eax
  801313:	79 20                	jns    801335 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801315:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801319:	c7 44 24 08 8a 2c 80 	movl   $0x802c8a,0x8(%esp)
  801320:	00 
  801321:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801328:	00 
  801329:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  801330:	e8 53 f0 ff ff       	call   800388 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801335:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801339:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80133d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801340:	89 44 24 08          	mov    %eax,0x8(%esp)
  801344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 41 fb ff ff       	call   800e91 <sys_page_map>
  801350:	85 c0                	test   %eax,%eax
  801352:	79 6e                	jns    8013c2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801354:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801358:	c7 44 24 08 8a 2c 80 	movl   $0x802c8a,0x8(%esp)
  80135f:	00 
  801360:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801367:	00 
  801368:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  80136f:	e8 14 f0 ff ff       	call   800388 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801374:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80137b:	25 07 0e 00 00       	and    $0xe07,%eax
  801380:	89 44 24 10          	mov    %eax,0x10(%esp)
  801384:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801396:	89 04 24             	mov    %eax,(%esp)
  801399:	e8 f3 fa ff ff       	call   800e91 <sys_page_map>
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	79 20                	jns    8013c2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8013a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a6:	c7 44 24 08 8a 2c 80 	movl   $0x802c8a,0x8(%esp)
  8013ad:	00 
  8013ae:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8013b5:	00 
  8013b6:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8013bd:	e8 c6 ef ff ff       	call   800388 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8013c2:	46                   	inc    %esi
  8013c3:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8013c9:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8013cf:	0f 85 5f fe ff ff    	jne    801234 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8013d5:	c7 44 24 04 34 23 80 	movl   $0x802334,0x4(%esp)
  8013dc:	00 
  8013dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013e0:	89 04 24             	mov    %eax,(%esp)
  8013e3:	e8 f5 fb ff ff       	call   800fdd <sys_env_set_pgfault_upcall>
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	79 20                	jns    80140c <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8013ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f0:	c7 44 24 08 2c 2c 80 	movl   $0x802c2c,0x8(%esp)
  8013f7:	00 
  8013f8:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8013ff:	00 
  801400:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  801407:	e8 7c ef ff ff       	call   800388 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  80140c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801413:	00 
  801414:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80141b:	ee 
  80141c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 16 fa ff ff       	call   800e3d <sys_page_alloc>
  801427:	85 c0                	test   %eax,%eax
  801429:	79 20                	jns    80144b <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80142b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80142f:	c7 44 24 08 56 2c 80 	movl   $0x802c56,0x8(%esp)
  801436:	00 
  801437:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  80143e:	00 
  80143f:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  801446:	e8 3d ef ff ff       	call   800388 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80144b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801452:	00 
  801453:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	e8 d9 fa ff ff       	call   800f37 <sys_env_set_status>
  80145e:	85 c0                	test   %eax,%eax
  801460:	79 20                	jns    801482 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801466:	c7 44 24 08 9c 2c 80 	movl   $0x802c9c,0x8(%esp)
  80146d:	00 
  80146e:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801475:	00 
  801476:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  80147d:	e8 06 ef ff ff       	call   800388 <_panic>
	}
	
	return envid;
}
  801482:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801485:	83 c4 3c             	add    $0x3c,%esp
  801488:	5b                   	pop    %ebx
  801489:	5e                   	pop    %esi
  80148a:	5f                   	pop    %edi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <sfork>:

// Challenge!
int
sfork(void)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801493:	c7 44 24 08 b3 2c 80 	movl   $0x802cb3,0x8(%esp)
  80149a:	00 
  80149b:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8014a2:	00 
  8014a3:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8014aa:	e8 d9 ee ff ff       	call   800388 <_panic>
	...

008014b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	89 04 24             	mov    %eax,(%esp)
  8014cc:	e8 df ff ff ff       	call   8014b0 <fd2num>
  8014d1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014d6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014e7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	c1 ea 16             	shr    $0x16,%edx
  8014ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014f5:	f6 c2 01             	test   $0x1,%dl
  8014f8:	74 11                	je     80150b <fd_alloc+0x30>
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	c1 ea 0c             	shr    $0xc,%edx
  8014ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801506:	f6 c2 01             	test   $0x1,%dl
  801509:	75 09                	jne    801514 <fd_alloc+0x39>
			*fd_store = fd;
  80150b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80150d:	b8 00 00 00 00       	mov    $0x0,%eax
  801512:	eb 17                	jmp    80152b <fd_alloc+0x50>
  801514:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801519:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80151e:	75 c7                	jne    8014e7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801520:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801526:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80152b:	5b                   	pop    %ebx
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801534:	83 f8 1f             	cmp    $0x1f,%eax
  801537:	77 36                	ja     80156f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801539:	05 00 00 0d 00       	add    $0xd0000,%eax
  80153e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801541:	89 c2                	mov    %eax,%edx
  801543:	c1 ea 16             	shr    $0x16,%edx
  801546:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80154d:	f6 c2 01             	test   $0x1,%dl
  801550:	74 24                	je     801576 <fd_lookup+0x48>
  801552:	89 c2                	mov    %eax,%edx
  801554:	c1 ea 0c             	shr    $0xc,%edx
  801557:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155e:	f6 c2 01             	test   $0x1,%dl
  801561:	74 1a                	je     80157d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801563:	8b 55 0c             	mov    0xc(%ebp),%edx
  801566:	89 02                	mov    %eax,(%edx)
	return 0;
  801568:	b8 00 00 00 00       	mov    $0x0,%eax
  80156d:	eb 13                	jmp    801582 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80156f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801574:	eb 0c                	jmp    801582 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157b:	eb 05                	jmp    801582 <fd_lookup+0x54>
  80157d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 14             	sub    $0x14,%esp
  80158b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80158e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	eb 0e                	jmp    8015a6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801598:	39 08                	cmp    %ecx,(%eax)
  80159a:	75 09                	jne    8015a5 <dev_lookup+0x21>
			*dev = devtab[i];
  80159c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a3:	eb 33                	jmp    8015d8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015a5:	42                   	inc    %edx
  8015a6:	8b 04 95 48 2d 80 00 	mov    0x802d48(,%edx,4),%eax
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	75 e7                	jne    801598 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  8015c8:	e8 b3 ee ff ff       	call   800480 <cprintf>
	*dev = 0;
  8015cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015d8:	83 c4 14             	add    $0x14,%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 30             	sub    $0x30,%esp
  8015e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015e9:	8a 45 0c             	mov    0xc(%ebp),%al
  8015ec:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015ef:	89 34 24             	mov    %esi,(%esp)
  8015f2:	e8 b9 fe ff ff       	call   8014b0 <fd2num>
  8015f7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 28 ff ff ff       	call   80152e <fd_lookup>
  801606:	89 c3                	mov    %eax,%ebx
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 05                	js     801611 <fd_close+0x33>
	    || fd != fd2)
  80160c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80160f:	74 0d                	je     80161e <fd_close+0x40>
		return (must_exist ? r : 0);
  801611:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801615:	75 46                	jne    80165d <fd_close+0x7f>
  801617:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161c:	eb 3f                	jmp    80165d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80161e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801621:	89 44 24 04          	mov    %eax,0x4(%esp)
  801625:	8b 06                	mov    (%esi),%eax
  801627:	89 04 24             	mov    %eax,(%esp)
  80162a:	e8 55 ff ff ff       	call   801584 <dev_lookup>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	85 c0                	test   %eax,%eax
  801633:	78 18                	js     80164d <fd_close+0x6f>
		if (dev->dev_close)
  801635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801638:	8b 40 10             	mov    0x10(%eax),%eax
  80163b:	85 c0                	test   %eax,%eax
  80163d:	74 09                	je     801648 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80163f:	89 34 24             	mov    %esi,(%esp)
  801642:	ff d0                	call   *%eax
  801644:	89 c3                	mov    %eax,%ebx
  801646:	eb 05                	jmp    80164d <fd_close+0x6f>
		else
			r = 0;
  801648:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80164d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801658:	e8 87 f8 ff ff       	call   800ee4 <sys_page_unmap>
	return r;
}
  80165d:	89 d8                	mov    %ebx,%eax
  80165f:	83 c4 30             	add    $0x30,%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 b0 fe ff ff       	call   80152e <fd_lookup>
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 13                	js     801695 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801682:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801689:	00 
  80168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168d:	89 04 24             	mov    %eax,(%esp)
  801690:	e8 49 ff ff ff       	call   8015de <fd_close>
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <close_all>:

void
close_all(void)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80169e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016a3:	89 1c 24             	mov    %ebx,(%esp)
  8016a6:	e8 bb ff ff ff       	call   801666 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ab:	43                   	inc    %ebx
  8016ac:	83 fb 20             	cmp    $0x20,%ebx
  8016af:	75 f2                	jne    8016a3 <close_all+0xc>
		close(i);
}
  8016b1:	83 c4 14             	add    $0x14,%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	57                   	push   %edi
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 4c             	sub    $0x4c,%esp
  8016c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	89 04 24             	mov    %eax,(%esp)
  8016d0:	e8 59 fe ff ff       	call   80152e <fd_lookup>
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	0f 88 e1 00 00 00    	js     8017c0 <dup+0x109>
		return r;
	close(newfdnum);
  8016df:	89 3c 24             	mov    %edi,(%esp)
  8016e2:	e8 7f ff ff ff       	call   801666 <close>

	newfd = INDEX2FD(newfdnum);
  8016e7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016ed:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f3:	89 04 24             	mov    %eax,(%esp)
  8016f6:	e8 c5 fd ff ff       	call   8014c0 <fd2data>
  8016fb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016fd:	89 34 24             	mov    %esi,(%esp)
  801700:	e8 bb fd ff ff       	call   8014c0 <fd2data>
  801705:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	c1 e8 16             	shr    $0x16,%eax
  80170d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801714:	a8 01                	test   $0x1,%al
  801716:	74 46                	je     80175e <dup+0xa7>
  801718:	89 d8                	mov    %ebx,%eax
  80171a:	c1 e8 0c             	shr    $0xc,%eax
  80171d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801724:	f6 c2 01             	test   $0x1,%dl
  801727:	74 35                	je     80175e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801729:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801730:	25 07 0e 00 00       	and    $0xe07,%eax
  801735:	89 44 24 10          	mov    %eax,0x10(%esp)
  801739:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80173c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801740:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801747:	00 
  801748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801753:	e8 39 f7 ff ff       	call   800e91 <sys_page_map>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 3b                	js     801799 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801761:	89 c2                	mov    %eax,%edx
  801763:	c1 ea 0c             	shr    $0xc,%edx
  801766:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801773:	89 54 24 10          	mov    %edx,0x10(%esp)
  801777:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80177b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801782:	00 
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178e:	e8 fe f6 ff ff       	call   800e91 <sys_page_map>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	85 c0                	test   %eax,%eax
  801797:	79 25                	jns    8017be <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801799:	89 74 24 04          	mov    %esi,0x4(%esp)
  80179d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a4:	e8 3b f7 ff ff       	call   800ee4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b7:	e8 28 f7 ff ff       	call   800ee4 <sys_page_unmap>
	return r;
  8017bc:	eb 02                	jmp    8017c0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017be:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017c0:	89 d8                	mov    %ebx,%eax
  8017c2:	83 c4 4c             	add    $0x4c,%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5e                   	pop    %esi
  8017c7:	5f                   	pop    %edi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 24             	sub    $0x24,%esp
  8017d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017db:	89 1c 24             	mov    %ebx,(%esp)
  8017de:	e8 4b fd ff ff       	call   80152e <fd_lookup>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 6d                	js     801854 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f1:	8b 00                	mov    (%eax),%eax
  8017f3:	89 04 24             	mov    %eax,(%esp)
  8017f6:	e8 89 fd ff ff       	call   801584 <dev_lookup>
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 55                	js     801854 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801802:	8b 50 08             	mov    0x8(%eax),%edx
  801805:	83 e2 03             	and    $0x3,%edx
  801808:	83 fa 01             	cmp    $0x1,%edx
  80180b:	75 23                	jne    801830 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180d:	a1 04 40 80 00       	mov    0x804004,%eax
  801812:	8b 40 48             	mov    0x48(%eax),%eax
  801815:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181d:	c7 04 24 0d 2d 80 00 	movl   $0x802d0d,(%esp)
  801824:	e8 57 ec ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  801829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182e:	eb 24                	jmp    801854 <read+0x8a>
	}
	if (!dev->dev_read)
  801830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801833:	8b 52 08             	mov    0x8(%edx),%edx
  801836:	85 d2                	test   %edx,%edx
  801838:	74 15                	je     80184f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80183a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80183d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801844:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801848:	89 04 24             	mov    %eax,(%esp)
  80184b:	ff d2                	call   *%edx
  80184d:	eb 05                	jmp    801854 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80184f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801854:	83 c4 24             	add    $0x24,%esp
  801857:	5b                   	pop    %ebx
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	57                   	push   %edi
  80185e:	56                   	push   %esi
  80185f:	53                   	push   %ebx
  801860:	83 ec 1c             	sub    $0x1c,%esp
  801863:	8b 7d 08             	mov    0x8(%ebp),%edi
  801866:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801869:	bb 00 00 00 00       	mov    $0x0,%ebx
  80186e:	eb 23                	jmp    801893 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801870:	89 f0                	mov    %esi,%eax
  801872:	29 d8                	sub    %ebx,%eax
  801874:	89 44 24 08          	mov    %eax,0x8(%esp)
  801878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187b:	01 d8                	add    %ebx,%eax
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	89 3c 24             	mov    %edi,(%esp)
  801884:	e8 41 ff ff ff       	call   8017ca <read>
		if (m < 0)
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 10                	js     80189d <readn+0x43>
			return m;
		if (m == 0)
  80188d:	85 c0                	test   %eax,%eax
  80188f:	74 0a                	je     80189b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801891:	01 c3                	add    %eax,%ebx
  801893:	39 f3                	cmp    %esi,%ebx
  801895:	72 d9                	jb     801870 <readn+0x16>
  801897:	89 d8                	mov    %ebx,%eax
  801899:	eb 02                	jmp    80189d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80189b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80189d:	83 c4 1c             	add    $0x1c,%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 24             	sub    $0x24,%esp
  8018ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b6:	89 1c 24             	mov    %ebx,(%esp)
  8018b9:	e8 70 fc ff ff       	call   80152e <fd_lookup>
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 68                	js     80192a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cc:	8b 00                	mov    (%eax),%eax
  8018ce:	89 04 24             	mov    %eax,(%esp)
  8018d1:	e8 ae fc ff ff       	call   801584 <dev_lookup>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 50                	js     80192a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e1:	75 23                	jne    801906 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e8:	8b 40 48             	mov    0x48(%eax),%eax
  8018eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f3:	c7 04 24 29 2d 80 00 	movl   $0x802d29,(%esp)
  8018fa:	e8 81 eb ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  8018ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801904:	eb 24                	jmp    80192a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801906:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801909:	8b 52 0c             	mov    0xc(%edx),%edx
  80190c:	85 d2                	test   %edx,%edx
  80190e:	74 15                	je     801925 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801910:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801913:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	ff d2                	call   *%edx
  801923:	eb 05                	jmp    80192a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801925:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80192a:	83 c4 24             	add    $0x24,%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <seek>:

int
seek(int fdnum, off_t offset)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801936:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	89 04 24             	mov    %eax,(%esp)
  801943:	e8 e6 fb ff ff       	call   80152e <fd_lookup>
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 0e                	js     80195a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80194c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80194f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801952:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 24             	sub    $0x24,%esp
  801963:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196d:	89 1c 24             	mov    %ebx,(%esp)
  801970:	e8 b9 fb ff ff       	call   80152e <fd_lookup>
  801975:	85 c0                	test   %eax,%eax
  801977:	78 61                	js     8019da <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801979:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801980:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801983:	8b 00                	mov    (%eax),%eax
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 f7 fb ff ff       	call   801584 <dev_lookup>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 49                	js     8019da <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801991:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801994:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801998:	75 23                	jne    8019bd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80199a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80199f:	8b 40 48             	mov    0x48(%eax),%eax
  8019a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019aa:	c7 04 24 ec 2c 80 00 	movl   $0x802cec,(%esp)
  8019b1:	e8 ca ea ff ff       	call   800480 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019bb:	eb 1d                	jmp    8019da <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c0:	8b 52 18             	mov    0x18(%edx),%edx
  8019c3:	85 d2                	test   %edx,%edx
  8019c5:	74 0e                	je     8019d5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	ff d2                	call   *%edx
  8019d3:	eb 05                	jmp    8019da <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019da:	83 c4 24             	add    $0x24,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 24             	sub    $0x24,%esp
  8019e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	89 04 24             	mov    %eax,(%esp)
  8019f7:	e8 32 fb ff ff       	call   80152e <fd_lookup>
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 52                	js     801a52 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0a:	8b 00                	mov    (%eax),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 70 fb ff ff       	call   801584 <dev_lookup>
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 3a                	js     801a52 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a1f:	74 2c                	je     801a4d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a21:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a24:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a2b:	00 00 00 
	stat->st_isdir = 0;
  801a2e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a35:	00 00 00 
	stat->st_dev = dev;
  801a38:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a45:	89 14 24             	mov    %edx,(%esp)
  801a48:	ff 50 14             	call   *0x14(%eax)
  801a4b:	eb 05                	jmp    801a52 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a52:	83 c4 24             	add    $0x24,%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a67:	00 
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	89 04 24             	mov    %eax,(%esp)
  801a6e:	e8 fe 01 00 00       	call   801c71 <open>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 1b                	js     801a94 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 58 ff ff ff       	call   8019e0 <fstat>
  801a88:	89 c6                	mov    %eax,%esi
	close(fd);
  801a8a:	89 1c 24             	mov    %ebx,(%esp)
  801a8d:	e8 d4 fb ff ff       	call   801666 <close>
	return r;
  801a92:	89 f3                	mov    %esi,%ebx
}
  801a94:	89 d8                	mov    %ebx,%eax
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    
  801a9d:	00 00                	add    %al,(%eax)
	...

00801aa0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	83 ec 10             	sub    $0x10,%esp
  801aa8:	89 c3                	mov    %eax,%ebx
  801aaa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801aac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ab3:	75 11                	jne    801ac6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ab5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801abc:	e8 68 09 00 00       	call   802429 <ipc_find_env>
  801ac1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ac6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801acd:	00 
  801ace:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ad5:	00 
  801ad6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ada:	a1 00 40 80 00       	mov    0x804000,%eax
  801adf:	89 04 24             	mov    %eax,(%esp)
  801ae2:	e8 d8 08 00 00       	call   8023bf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ae7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aee:	00 
  801aef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801af3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afa:	e8 59 08 00 00       	call   802358 <ipc_recv>
}
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b12:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b24:	b8 02 00 00 00       	mov    $0x2,%eax
  801b29:	e8 72 ff ff ff       	call   801aa0 <fsipc>
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
  801b39:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b41:	ba 00 00 00 00       	mov    $0x0,%edx
  801b46:	b8 06 00 00 00       	mov    $0x6,%eax
  801b4b:	e8 50 ff ff ff       	call   801aa0 <fsipc>
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 14             	sub    $0x14,%esp
  801b59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b62:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b67:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b71:	e8 2a ff ff ff       	call   801aa0 <fsipc>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 2b                	js     801ba5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b7a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b81:	00 
  801b82:	89 1c 24             	mov    %ebx,(%esp)
  801b85:	e8 c1 ee ff ff       	call   800a4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b8a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b8f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b95:	a1 84 50 80 00       	mov    0x805084,%eax
  801b9a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba5:	83 c4 14             	add    $0x14,%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801bb1:	c7 44 24 08 58 2d 80 	movl   $0x802d58,0x8(%esp)
  801bb8:	00 
  801bb9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801bc0:	00 
  801bc1:	c7 04 24 76 2d 80 00 	movl   $0x802d76,(%esp)
  801bc8:	e8 bb e7 ff ff       	call   800388 <_panic>

00801bcd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 10             	sub    $0x10,%esp
  801bd5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	8b 40 0c             	mov    0xc(%eax),%eax
  801bde:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801be3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801be9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bee:	b8 03 00 00 00       	mov    $0x3,%eax
  801bf3:	e8 a8 fe ff ff       	call   801aa0 <fsipc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	78 6a                	js     801c68 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bfe:	39 c6                	cmp    %eax,%esi
  801c00:	73 24                	jae    801c26 <devfile_read+0x59>
  801c02:	c7 44 24 0c 81 2d 80 	movl   $0x802d81,0xc(%esp)
  801c09:	00 
  801c0a:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  801c11:	00 
  801c12:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c19:	00 
  801c1a:	c7 04 24 76 2d 80 00 	movl   $0x802d76,(%esp)
  801c21:	e8 62 e7 ff ff       	call   800388 <_panic>
	assert(r <= PGSIZE);
  801c26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c2b:	7e 24                	jle    801c51 <devfile_read+0x84>
  801c2d:	c7 44 24 0c 9d 2d 80 	movl   $0x802d9d,0xc(%esp)
  801c34:	00 
  801c35:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  801c3c:	00 
  801c3d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c44:	00 
  801c45:	c7 04 24 76 2d 80 00 	movl   $0x802d76,(%esp)
  801c4c:	e8 37 e7 ff ff       	call   800388 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c55:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c5c:	00 
  801c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c60:	89 04 24             	mov    %eax,(%esp)
  801c63:	e8 5c ef ff ff       	call   800bc4 <memmove>
	return r;
}
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	56                   	push   %esi
  801c75:	53                   	push   %ebx
  801c76:	83 ec 20             	sub    $0x20,%esp
  801c79:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c7c:	89 34 24             	mov    %esi,(%esp)
  801c7f:	e8 94 ed ff ff       	call   800a18 <strlen>
  801c84:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c89:	7f 60                	jg     801ceb <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8e:	89 04 24             	mov    %eax,(%esp)
  801c91:	e8 45 f8 ff ff       	call   8014db <fd_alloc>
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 54                	js     801cf0 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ca7:	e8 9f ed ff ff       	call   800a4b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbc:	e8 df fd ff ff       	call   801aa0 <fsipc>
  801cc1:	89 c3                	mov    %eax,%ebx
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	79 15                	jns    801cdc <open+0x6b>
		fd_close(fd, 0);
  801cc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cce:	00 
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	89 04 24             	mov    %eax,(%esp)
  801cd5:	e8 04 f9 ff ff       	call   8015de <fd_close>
		return r;
  801cda:	eb 14                	jmp    801cf0 <open+0x7f>
	}

	return fd2num(fd);
  801cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 c9 f7 ff ff       	call   8014b0 <fd2num>
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	eb 05                	jmp    801cf0 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ceb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	83 c4 20             	add    $0x20,%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cff:	ba 00 00 00 00       	mov    $0x0,%edx
  801d04:	b8 08 00 00 00       	mov    $0x8,%eax
  801d09:	e8 92 fd ff ff       	call   801aa0 <fsipc>
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
  801d15:	83 ec 10             	sub    $0x10,%esp
  801d18:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 9a f7 ff ff       	call   8014c0 <fd2data>
  801d26:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d28:	c7 44 24 04 a9 2d 80 	movl   $0x802da9,0x4(%esp)
  801d2f:	00 
  801d30:	89 34 24             	mov    %esi,(%esp)
  801d33:	e8 13 ed ff ff       	call   800a4b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d38:	8b 43 04             	mov    0x4(%ebx),%eax
  801d3b:	2b 03                	sub    (%ebx),%eax
  801d3d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d43:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d4a:	00 00 00 
	stat->st_dev = &devpipe;
  801d4d:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801d54:	30 80 00 
	return 0;
}
  801d57:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	53                   	push   %ebx
  801d67:	83 ec 14             	sub    $0x14,%esp
  801d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d78:	e8 67 f1 ff ff       	call   800ee4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d7d:	89 1c 24             	mov    %ebx,(%esp)
  801d80:	e8 3b f7 ff ff       	call   8014c0 <fd2data>
  801d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d90:	e8 4f f1 ff ff       	call   800ee4 <sys_page_unmap>
}
  801d95:	83 c4 14             	add    $0x14,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	83 ec 2c             	sub    $0x2c,%esp
  801da4:	89 c7                	mov    %eax,%edi
  801da6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801da9:	a1 04 40 80 00       	mov    0x804004,%eax
  801dae:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801db1:	89 3c 24             	mov    %edi,(%esp)
  801db4:	e8 b7 06 00 00       	call   802470 <pageref>
  801db9:	89 c6                	mov    %eax,%esi
  801dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbe:	89 04 24             	mov    %eax,(%esp)
  801dc1:	e8 aa 06 00 00       	call   802470 <pageref>
  801dc6:	39 c6                	cmp    %eax,%esi
  801dc8:	0f 94 c0             	sete   %al
  801dcb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dd4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dd7:	39 cb                	cmp    %ecx,%ebx
  801dd9:	75 08                	jne    801de3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ddb:	83 c4 2c             	add    $0x2c,%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801de3:	83 f8 01             	cmp    $0x1,%eax
  801de6:	75 c1                	jne    801da9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801de8:	8b 42 58             	mov    0x58(%edx),%eax
  801deb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801df2:	00 
  801df3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dfb:	c7 04 24 b0 2d 80 00 	movl   $0x802db0,(%esp)
  801e02:	e8 79 e6 ff ff       	call   800480 <cprintf>
  801e07:	eb a0                	jmp    801da9 <_pipeisclosed+0xe>

00801e09 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	57                   	push   %edi
  801e0d:	56                   	push   %esi
  801e0e:	53                   	push   %ebx
  801e0f:	83 ec 1c             	sub    $0x1c,%esp
  801e12:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e15:	89 34 24             	mov    %esi,(%esp)
  801e18:	e8 a3 f6 ff ff       	call   8014c0 <fd2data>
  801e1d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e24:	eb 3c                	jmp    801e62 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e26:	89 da                	mov    %ebx,%edx
  801e28:	89 f0                	mov    %esi,%eax
  801e2a:	e8 6c ff ff ff       	call   801d9b <_pipeisclosed>
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	75 38                	jne    801e6b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e33:	e8 e6 ef ff ff       	call   800e1e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e38:	8b 43 04             	mov    0x4(%ebx),%eax
  801e3b:	8b 13                	mov    (%ebx),%edx
  801e3d:	83 c2 20             	add    $0x20,%edx
  801e40:	39 d0                	cmp    %edx,%eax
  801e42:	73 e2                	jae    801e26 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e47:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e4a:	89 c2                	mov    %eax,%edx
  801e4c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e52:	79 05                	jns    801e59 <devpipe_write+0x50>
  801e54:	4a                   	dec    %edx
  801e55:	83 ca e0             	or     $0xffffffe0,%edx
  801e58:	42                   	inc    %edx
  801e59:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e5d:	40                   	inc    %eax
  801e5e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e61:	47                   	inc    %edi
  801e62:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e65:	75 d1                	jne    801e38 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e67:	89 f8                	mov    %edi,%eax
  801e69:	eb 05                	jmp    801e70 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e70:	83 c4 1c             	add    $0x1c,%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	57                   	push   %edi
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	83 ec 1c             	sub    $0x1c,%esp
  801e81:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e84:	89 3c 24             	mov    %edi,(%esp)
  801e87:	e8 34 f6 ff ff       	call   8014c0 <fd2data>
  801e8c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e8e:	be 00 00 00 00       	mov    $0x0,%esi
  801e93:	eb 3a                	jmp    801ecf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e95:	85 f6                	test   %esi,%esi
  801e97:	74 04                	je     801e9d <devpipe_read+0x25>
				return i;
  801e99:	89 f0                	mov    %esi,%eax
  801e9b:	eb 40                	jmp    801edd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e9d:	89 da                	mov    %ebx,%edx
  801e9f:	89 f8                	mov    %edi,%eax
  801ea1:	e8 f5 fe ff ff       	call   801d9b <_pipeisclosed>
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	75 2e                	jne    801ed8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eaa:	e8 6f ef ff ff       	call   800e1e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eaf:	8b 03                	mov    (%ebx),%eax
  801eb1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801eb4:	74 df                	je     801e95 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eb6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ebb:	79 05                	jns    801ec2 <devpipe_read+0x4a>
  801ebd:	48                   	dec    %eax
  801ebe:	83 c8 e0             	or     $0xffffffe0,%eax
  801ec1:	40                   	inc    %eax
  801ec2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ec6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ecc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ece:	46                   	inc    %esi
  801ecf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed2:	75 db                	jne    801eaf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ed4:	89 f0                	mov    %esi,%eax
  801ed6:	eb 05                	jmp    801edd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ed8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801edd:	83 c4 1c             	add    $0x1c,%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    

00801ee5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	57                   	push   %edi
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 3c             	sub    $0x3c,%esp
  801eee:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ef1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ef4:	89 04 24             	mov    %eax,(%esp)
  801ef7:	e8 df f5 ff ff       	call   8014db <fd_alloc>
  801efc:	89 c3                	mov    %eax,%ebx
  801efe:	85 c0                	test   %eax,%eax
  801f00:	0f 88 45 01 00 00    	js     80204b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f0d:	00 
  801f0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1c:	e8 1c ef ff ff       	call   800e3d <sys_page_alloc>
  801f21:	89 c3                	mov    %eax,%ebx
  801f23:	85 c0                	test   %eax,%eax
  801f25:	0f 88 20 01 00 00    	js     80204b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f2b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f2e:	89 04 24             	mov    %eax,(%esp)
  801f31:	e8 a5 f5 ff ff       	call   8014db <fd_alloc>
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	0f 88 f8 00 00 00    	js     802038 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f47:	00 
  801f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f56:	e8 e2 ee ff ff       	call   800e3d <sys_page_alloc>
  801f5b:	89 c3                	mov    %eax,%ebx
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	0f 88 d3 00 00 00    	js     802038 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f68:	89 04 24             	mov    %eax,(%esp)
  801f6b:	e8 50 f5 ff ff       	call   8014c0 <fd2data>
  801f70:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f79:	00 
  801f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f85:	e8 b3 ee ff ff       	call   800e3d <sys_page_alloc>
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	0f 88 91 00 00 00    	js     802025 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f97:	89 04 24             	mov    %eax,(%esp)
  801f9a:	e8 21 f5 ff ff       	call   8014c0 <fd2data>
  801f9f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801fa6:	00 
  801fa7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fb2:	00 
  801fb3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fbe:	e8 ce ee ff ff       	call   800e91 <sys_page_map>
  801fc3:	89 c3                	mov    %eax,%ebx
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 4c                	js     802015 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fc9:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fde:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fe4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fe7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fe9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ff3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff6:	89 04 24             	mov    %eax,(%esp)
  801ff9:	e8 b2 f4 ff ff       	call   8014b0 <fd2num>
  801ffe:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802000:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802003:	89 04 24             	mov    %eax,(%esp)
  802006:	e8 a5 f4 ff ff       	call   8014b0 <fd2num>
  80200b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80200e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802013:	eb 36                	jmp    80204b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802015:	89 74 24 04          	mov    %esi,0x4(%esp)
  802019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802020:	e8 bf ee ff ff       	call   800ee4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802025:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802028:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802033:	e8 ac ee ff ff       	call   800ee4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802038:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80203b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802046:	e8 99 ee ff ff       	call   800ee4 <sys_page_unmap>
    err:
	return r;
}
  80204b:	89 d8                	mov    %ebx,%eax
  80204d:	83 c4 3c             	add    $0x3c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    

00802055 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80205b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802062:	8b 45 08             	mov    0x8(%ebp),%eax
  802065:	89 04 24             	mov    %eax,(%esp)
  802068:	e8 c1 f4 ff ff       	call   80152e <fd_lookup>
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 15                	js     802086 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802074:	89 04 24             	mov    %eax,(%esp)
  802077:	e8 44 f4 ff ff       	call   8014c0 <fd2data>
	return _pipeisclosed(fd, p);
  80207c:	89 c2                	mov    %eax,%edx
  80207e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802081:	e8 15 fd ff ff       	call   801d9b <_pipeisclosed>
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	56                   	push   %esi
  80208c:	53                   	push   %ebx
  80208d:	83 ec 10             	sub    $0x10,%esp
  802090:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802093:	85 f6                	test   %esi,%esi
  802095:	75 24                	jne    8020bb <wait+0x33>
  802097:	c7 44 24 0c c8 2d 80 	movl   $0x802dc8,0xc(%esp)
  80209e:	00 
  80209f:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  8020a6:	00 
  8020a7:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8020ae:	00 
  8020af:	c7 04 24 d3 2d 80 00 	movl   $0x802dd3,(%esp)
  8020b6:	e8 cd e2 ff ff       	call   800388 <_panic>
	e = &envs[ENVX(envid)];
  8020bb:	89 f3                	mov    %esi,%ebx
  8020bd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8020c3:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8020ca:	c1 e3 07             	shl    $0x7,%ebx
  8020cd:	29 c3                	sub    %eax,%ebx
  8020cf:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8020d5:	eb 05                	jmp    8020dc <wait+0x54>
		sys_yield();
  8020d7:	e8 42 ed ff ff       	call   800e1e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8020dc:	8b 43 48             	mov    0x48(%ebx),%eax
  8020df:	39 f0                	cmp    %esi,%eax
  8020e1:	75 07                	jne    8020ea <wait+0x62>
  8020e3:	8b 43 54             	mov    0x54(%ebx),%eax
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	75 ed                	jne    8020d7 <wait+0x4f>
		sys_yield();
}
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    
  8020f1:	00 00                	add    %al,(%eax)
	...

008020f4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    

008020fe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802104:	c7 44 24 04 de 2d 80 	movl   $0x802dde,0x4(%esp)
  80210b:	00 
  80210c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210f:	89 04 24             	mov    %eax,(%esp)
  802112:	e8 34 e9 ff ff       	call   800a4b <strcpy>
	return 0;
}
  802117:	b8 00 00 00 00       	mov    $0x0,%eax
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80212a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80212f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802135:	eb 30                	jmp    802167 <devcons_write+0x49>
		m = n - tot;
  802137:	8b 75 10             	mov    0x10(%ebp),%esi
  80213a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80213c:	83 fe 7f             	cmp    $0x7f,%esi
  80213f:	76 05                	jbe    802146 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802141:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802146:	89 74 24 08          	mov    %esi,0x8(%esp)
  80214a:	03 45 0c             	add    0xc(%ebp),%eax
  80214d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802151:	89 3c 24             	mov    %edi,(%esp)
  802154:	e8 6b ea ff ff       	call   800bc4 <memmove>
		sys_cputs(buf, m);
  802159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215d:	89 3c 24             	mov    %edi,(%esp)
  802160:	e8 0b ec ff ff       	call   800d70 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802165:	01 f3                	add    %esi,%ebx
  802167:	89 d8                	mov    %ebx,%eax
  802169:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80216c:	72 c9                	jb     802137 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80216e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    

00802179 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80217f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802183:	75 07                	jne    80218c <devcons_read+0x13>
  802185:	eb 25                	jmp    8021ac <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802187:	e8 92 ec ff ff       	call   800e1e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80218c:	e8 fd eb ff ff       	call   800d8e <sys_cgetc>
  802191:	85 c0                	test   %eax,%eax
  802193:	74 f2                	je     802187 <devcons_read+0xe>
  802195:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802197:	85 c0                	test   %eax,%eax
  802199:	78 1d                	js     8021b8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80219b:	83 f8 04             	cmp    $0x4,%eax
  80219e:	74 13                	je     8021b3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021a3:	88 10                	mov    %dl,(%eax)
	return 1;
  8021a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8021aa:	eb 0c                	jmp    8021b8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b1:	eb 05                	jmp    8021b8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021b3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021cd:	00 
  8021ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 97 eb ff ff       	call   800d70 <sys_cputs>
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <getchar>:

int
getchar(void)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021e8:	00 
  8021e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f7:	e8 ce f5 ff ff       	call   8017ca <read>
	if (r < 0)
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	78 0f                	js     80220f <getchar+0x34>
		return r;
	if (r < 1)
  802200:	85 c0                	test   %eax,%eax
  802202:	7e 06                	jle    80220a <getchar+0x2f>
		return -E_EOF;
	return c;
  802204:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802208:	eb 05                	jmp    80220f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80220a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80220f:	c9                   	leave  
  802210:	c3                   	ret    

00802211 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802217:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80221a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80221e:	8b 45 08             	mov    0x8(%ebp),%eax
  802221:	89 04 24             	mov    %eax,(%esp)
  802224:	e8 05 f3 ff ff       	call   80152e <fd_lookup>
  802229:	85 c0                	test   %eax,%eax
  80222b:	78 11                	js     80223e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80222d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802230:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802236:	39 10                	cmp    %edx,(%eax)
  802238:	0f 94 c0             	sete   %al
  80223b:	0f b6 c0             	movzbl %al,%eax
}
  80223e:	c9                   	leave  
  80223f:	c3                   	ret    

00802240 <opencons>:

int
opencons(void)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802249:	89 04 24             	mov    %eax,(%esp)
  80224c:	e8 8a f2 ff ff       	call   8014db <fd_alloc>
  802251:	85 c0                	test   %eax,%eax
  802253:	78 3c                	js     802291 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802255:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80225c:	00 
  80225d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802260:	89 44 24 04          	mov    %eax,0x4(%esp)
  802264:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80226b:	e8 cd eb ff ff       	call   800e3d <sys_page_alloc>
  802270:	85 c0                	test   %eax,%eax
  802272:	78 1d                	js     802291 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802274:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80227a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80227f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802282:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802289:	89 04 24             	mov    %eax,(%esp)
  80228c:	e8 1f f2 ff ff       	call   8014b0 <fd2num>
}
  802291:	c9                   	leave  
  802292:	c3                   	ret    
	...

00802294 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80229a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022a1:	0f 85 80 00 00 00    	jne    802327 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8022a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022ac:	8b 40 48             	mov    0x48(%eax),%eax
  8022af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022b6:	00 
  8022b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8022be:	ee 
  8022bf:	89 04 24             	mov    %eax,(%esp)
  8022c2:	e8 76 eb ff ff       	call   800e3d <sys_page_alloc>
  8022c7:	85 c0                	test   %eax,%eax
  8022c9:	79 20                	jns    8022eb <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8022cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022cf:	c7 44 24 08 ec 2d 80 	movl   $0x802dec,0x8(%esp)
  8022d6:	00 
  8022d7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8022de:	00 
  8022df:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  8022e6:	e8 9d e0 ff ff       	call   800388 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8022eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8022f0:	8b 40 48             	mov    0x48(%eax),%eax
  8022f3:	c7 44 24 04 34 23 80 	movl   $0x802334,0x4(%esp)
  8022fa:	00 
  8022fb:	89 04 24             	mov    %eax,(%esp)
  8022fe:	e8 da ec ff ff       	call   800fdd <sys_env_set_pgfault_upcall>
  802303:	85 c0                	test   %eax,%eax
  802305:	79 20                	jns    802327 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  802307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230b:	c7 44 24 08 18 2e 80 	movl   $0x802e18,0x8(%esp)
  802312:	00 
  802313:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80231a:	00 
  80231b:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  802322:	e8 61 e0 ff ff       	call   800388 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802327:	8b 45 08             	mov    0x8(%ebp),%eax
  80232a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80232f:	c9                   	leave  
  802330:	c3                   	ret    
  802331:	00 00                	add    %al,(%eax)
	...

00802334 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802334:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802335:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80233a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80233c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  80233f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  802343:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802345:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802348:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802349:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  80234c:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  80234e:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802351:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  802352:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802355:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802356:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802357:	c3                   	ret    

00802358 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	56                   	push   %esi
  80235c:	53                   	push   %ebx
  80235d:	83 ec 10             	sub    $0x10,%esp
  802360:	8b 75 08             	mov    0x8(%ebp),%esi
  802363:	8b 45 0c             	mov    0xc(%ebp),%eax
  802366:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802369:	85 c0                	test   %eax,%eax
  80236b:	75 05                	jne    802372 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  80236d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  802372:	89 04 24             	mov    %eax,(%esp)
  802375:	e8 d9 ec ff ff       	call   801053 <sys_ipc_recv>
	if (!err) {
  80237a:	85 c0                	test   %eax,%eax
  80237c:	75 26                	jne    8023a4 <ipc_recv+0x4c>
		if (from_env_store) {
  80237e:	85 f6                	test   %esi,%esi
  802380:	74 0a                	je     80238c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  802382:	a1 04 40 80 00       	mov    0x804004,%eax
  802387:	8b 40 74             	mov    0x74(%eax),%eax
  80238a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80238c:	85 db                	test   %ebx,%ebx
  80238e:	74 0a                	je     80239a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802390:	a1 04 40 80 00       	mov    0x804004,%eax
  802395:	8b 40 78             	mov    0x78(%eax),%eax
  802398:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80239a:	a1 04 40 80 00       	mov    0x804004,%eax
  80239f:	8b 40 70             	mov    0x70(%eax),%eax
  8023a2:	eb 14                	jmp    8023b8 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8023a4:	85 f6                	test   %esi,%esi
  8023a6:	74 06                	je     8023ae <ipc_recv+0x56>
		*from_env_store = 0;
  8023a8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8023ae:	85 db                	test   %ebx,%ebx
  8023b0:	74 06                	je     8023b8 <ipc_recv+0x60>
		*perm_store = 0;
  8023b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	5b                   	pop    %ebx
  8023bc:	5e                   	pop    %esi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    

008023bf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	57                   	push   %edi
  8023c3:	56                   	push   %esi
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 1c             	sub    $0x1c,%esp
  8023c8:	8b 75 10             	mov    0x10(%ebp),%esi
  8023cb:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8023ce:	85 f6                	test   %esi,%esi
  8023d0:	75 05                	jne    8023d7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8023d2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023d7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023db:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e9:	89 04 24             	mov    %eax,(%esp)
  8023ec:	e8 3f ec ff ff       	call   801030 <sys_ipc_try_send>
  8023f1:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8023f3:	e8 26 ea ff ff       	call   800e1e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8023f8:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8023fb:	74 da                	je     8023d7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8023fd:	85 db                	test   %ebx,%ebx
  8023ff:	74 20                	je     802421 <ipc_send+0x62>
		panic("send fail: %e", err);
  802401:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802405:	c7 44 24 08 56 2e 80 	movl   $0x802e56,0x8(%esp)
  80240c:	00 
  80240d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802414:	00 
  802415:	c7 04 24 64 2e 80 00 	movl   $0x802e64,(%esp)
  80241c:	e8 67 df ff ff       	call   800388 <_panic>
	}
	return;
}
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    

00802429 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	53                   	push   %ebx
  80242d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802430:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802435:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80243c:	89 c2                	mov    %eax,%edx
  80243e:	c1 e2 07             	shl    $0x7,%edx
  802441:	29 ca                	sub    %ecx,%edx
  802443:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802449:	8b 52 50             	mov    0x50(%edx),%edx
  80244c:	39 da                	cmp    %ebx,%edx
  80244e:	75 0f                	jne    80245f <ipc_find_env+0x36>
			return envs[i].env_id;
  802450:	c1 e0 07             	shl    $0x7,%eax
  802453:	29 c8                	sub    %ecx,%eax
  802455:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80245a:	8b 40 40             	mov    0x40(%eax),%eax
  80245d:	eb 0c                	jmp    80246b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80245f:	40                   	inc    %eax
  802460:	3d 00 04 00 00       	cmp    $0x400,%eax
  802465:	75 ce                	jne    802435 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802467:	66 b8 00 00          	mov    $0x0,%ax
}
  80246b:	5b                   	pop    %ebx
  80246c:	5d                   	pop    %ebp
  80246d:	c3                   	ret    
	...

00802470 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802476:	89 c2                	mov    %eax,%edx
  802478:	c1 ea 16             	shr    $0x16,%edx
  80247b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802482:	f6 c2 01             	test   $0x1,%dl
  802485:	74 1e                	je     8024a5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802487:	c1 e8 0c             	shr    $0xc,%eax
  80248a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802491:	a8 01                	test   $0x1,%al
  802493:	74 17                	je     8024ac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802495:	c1 e8 0c             	shr    $0xc,%eax
  802498:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80249f:	ef 
  8024a0:	0f b7 c0             	movzwl %ax,%eax
  8024a3:	eb 0c                	jmp    8024b1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8024aa:	eb 05                	jmp    8024b1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024ac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024b1:	5d                   	pop    %ebp
  8024b2:	c3                   	ret    
	...

008024b4 <__udivdi3>:
  8024b4:	55                   	push   %ebp
  8024b5:	57                   	push   %edi
  8024b6:	56                   	push   %esi
  8024b7:	83 ec 10             	sub    $0x10,%esp
  8024ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024be:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8024ca:	89 cd                	mov    %ecx,%ebp
  8024cc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	75 2c                	jne    802500 <__udivdi3+0x4c>
  8024d4:	39 f9                	cmp    %edi,%ecx
  8024d6:	77 68                	ja     802540 <__udivdi3+0x8c>
  8024d8:	85 c9                	test   %ecx,%ecx
  8024da:	75 0b                	jne    8024e7 <__udivdi3+0x33>
  8024dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e1:	31 d2                	xor    %edx,%edx
  8024e3:	f7 f1                	div    %ecx
  8024e5:	89 c1                	mov    %eax,%ecx
  8024e7:	31 d2                	xor    %edx,%edx
  8024e9:	89 f8                	mov    %edi,%eax
  8024eb:	f7 f1                	div    %ecx
  8024ed:	89 c7                	mov    %eax,%edi
  8024ef:	89 f0                	mov    %esi,%eax
  8024f1:	f7 f1                	div    %ecx
  8024f3:	89 c6                	mov    %eax,%esi
  8024f5:	89 f0                	mov    %esi,%eax
  8024f7:	89 fa                	mov    %edi,%edx
  8024f9:	83 c4 10             	add    $0x10,%esp
  8024fc:	5e                   	pop    %esi
  8024fd:	5f                   	pop    %edi
  8024fe:	5d                   	pop    %ebp
  8024ff:	c3                   	ret    
  802500:	39 f8                	cmp    %edi,%eax
  802502:	77 2c                	ja     802530 <__udivdi3+0x7c>
  802504:	0f bd f0             	bsr    %eax,%esi
  802507:	83 f6 1f             	xor    $0x1f,%esi
  80250a:	75 4c                	jne    802558 <__udivdi3+0xa4>
  80250c:	39 f8                	cmp    %edi,%eax
  80250e:	bf 00 00 00 00       	mov    $0x0,%edi
  802513:	72 0a                	jb     80251f <__udivdi3+0x6b>
  802515:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802519:	0f 87 ad 00 00 00    	ja     8025cc <__udivdi3+0x118>
  80251f:	be 01 00 00 00       	mov    $0x1,%esi
  802524:	89 f0                	mov    %esi,%eax
  802526:	89 fa                	mov    %edi,%edx
  802528:	83 c4 10             	add    $0x10,%esp
  80252b:	5e                   	pop    %esi
  80252c:	5f                   	pop    %edi
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    
  80252f:	90                   	nop
  802530:	31 ff                	xor    %edi,%edi
  802532:	31 f6                	xor    %esi,%esi
  802534:	89 f0                	mov    %esi,%eax
  802536:	89 fa                	mov    %edi,%edx
  802538:	83 c4 10             	add    $0x10,%esp
  80253b:	5e                   	pop    %esi
  80253c:	5f                   	pop    %edi
  80253d:	5d                   	pop    %ebp
  80253e:	c3                   	ret    
  80253f:	90                   	nop
  802540:	89 fa                	mov    %edi,%edx
  802542:	89 f0                	mov    %esi,%eax
  802544:	f7 f1                	div    %ecx
  802546:	89 c6                	mov    %eax,%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	89 f0                	mov    %esi,%eax
  80254c:	89 fa                	mov    %edi,%edx
  80254e:	83 c4 10             	add    $0x10,%esp
  802551:	5e                   	pop    %esi
  802552:	5f                   	pop    %edi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    
  802555:	8d 76 00             	lea    0x0(%esi),%esi
  802558:	89 f1                	mov    %esi,%ecx
  80255a:	d3 e0                	shl    %cl,%eax
  80255c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802560:	b8 20 00 00 00       	mov    $0x20,%eax
  802565:	29 f0                	sub    %esi,%eax
  802567:	89 ea                	mov    %ebp,%edx
  802569:	88 c1                	mov    %al,%cl
  80256b:	d3 ea                	shr    %cl,%edx
  80256d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802571:	09 ca                	or     %ecx,%edx
  802573:	89 54 24 08          	mov    %edx,0x8(%esp)
  802577:	89 f1                	mov    %esi,%ecx
  802579:	d3 e5                	shl    %cl,%ebp
  80257b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80257f:	89 fd                	mov    %edi,%ebp
  802581:	88 c1                	mov    %al,%cl
  802583:	d3 ed                	shr    %cl,%ebp
  802585:	89 fa                	mov    %edi,%edx
  802587:	89 f1                	mov    %esi,%ecx
  802589:	d3 e2                	shl    %cl,%edx
  80258b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80258f:	88 c1                	mov    %al,%cl
  802591:	d3 ef                	shr    %cl,%edi
  802593:	09 d7                	or     %edx,%edi
  802595:	89 f8                	mov    %edi,%eax
  802597:	89 ea                	mov    %ebp,%edx
  802599:	f7 74 24 08          	divl   0x8(%esp)
  80259d:	89 d1                	mov    %edx,%ecx
  80259f:	89 c7                	mov    %eax,%edi
  8025a1:	f7 64 24 0c          	mull   0xc(%esp)
  8025a5:	39 d1                	cmp    %edx,%ecx
  8025a7:	72 17                	jb     8025c0 <__udivdi3+0x10c>
  8025a9:	74 09                	je     8025b4 <__udivdi3+0x100>
  8025ab:	89 fe                	mov    %edi,%esi
  8025ad:	31 ff                	xor    %edi,%edi
  8025af:	e9 41 ff ff ff       	jmp    8024f5 <__udivdi3+0x41>
  8025b4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b8:	89 f1                	mov    %esi,%ecx
  8025ba:	d3 e2                	shl    %cl,%edx
  8025bc:	39 c2                	cmp    %eax,%edx
  8025be:	73 eb                	jae    8025ab <__udivdi3+0xf7>
  8025c0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8025c3:	31 ff                	xor    %edi,%edi
  8025c5:	e9 2b ff ff ff       	jmp    8024f5 <__udivdi3+0x41>
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	31 f6                	xor    %esi,%esi
  8025ce:	e9 22 ff ff ff       	jmp    8024f5 <__udivdi3+0x41>
	...

008025d4 <__umoddi3>:
  8025d4:	55                   	push   %ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	83 ec 20             	sub    $0x20,%esp
  8025da:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025de:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8025e2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025e6:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025ea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8025f2:	89 c7                	mov    %eax,%edi
  8025f4:	89 f2                	mov    %esi,%edx
  8025f6:	85 ed                	test   %ebp,%ebp
  8025f8:	75 16                	jne    802610 <__umoddi3+0x3c>
  8025fa:	39 f1                	cmp    %esi,%ecx
  8025fc:	0f 86 a6 00 00 00    	jbe    8026a8 <__umoddi3+0xd4>
  802602:	f7 f1                	div    %ecx
  802604:	89 d0                	mov    %edx,%eax
  802606:	31 d2                	xor    %edx,%edx
  802608:	83 c4 20             	add    $0x20,%esp
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    
  80260f:	90                   	nop
  802610:	39 f5                	cmp    %esi,%ebp
  802612:	0f 87 ac 00 00 00    	ja     8026c4 <__umoddi3+0xf0>
  802618:	0f bd c5             	bsr    %ebp,%eax
  80261b:	83 f0 1f             	xor    $0x1f,%eax
  80261e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802622:	0f 84 a8 00 00 00    	je     8026d0 <__umoddi3+0xfc>
  802628:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80262c:	d3 e5                	shl    %cl,%ebp
  80262e:	bf 20 00 00 00       	mov    $0x20,%edi
  802633:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802637:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80263b:	89 f9                	mov    %edi,%ecx
  80263d:	d3 e8                	shr    %cl,%eax
  80263f:	09 e8                	or     %ebp,%eax
  802641:	89 44 24 18          	mov    %eax,0x18(%esp)
  802645:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802649:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80264d:	d3 e0                	shl    %cl,%eax
  80264f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802653:	89 f2                	mov    %esi,%edx
  802655:	d3 e2                	shl    %cl,%edx
  802657:	8b 44 24 14          	mov    0x14(%esp),%eax
  80265b:	d3 e0                	shl    %cl,%eax
  80265d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802661:	8b 44 24 14          	mov    0x14(%esp),%eax
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e8                	shr    %cl,%eax
  802669:	09 d0                	or     %edx,%eax
  80266b:	d3 ee                	shr    %cl,%esi
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	f7 74 24 18          	divl   0x18(%esp)
  802673:	89 d6                	mov    %edx,%esi
  802675:	f7 64 24 0c          	mull   0xc(%esp)
  802679:	89 c5                	mov    %eax,%ebp
  80267b:	89 d1                	mov    %edx,%ecx
  80267d:	39 d6                	cmp    %edx,%esi
  80267f:	72 67                	jb     8026e8 <__umoddi3+0x114>
  802681:	74 75                	je     8026f8 <__umoddi3+0x124>
  802683:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802687:	29 e8                	sub    %ebp,%eax
  802689:	19 ce                	sbb    %ecx,%esi
  80268b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80268f:	d3 e8                	shr    %cl,%eax
  802691:	89 f2                	mov    %esi,%edx
  802693:	89 f9                	mov    %edi,%ecx
  802695:	d3 e2                	shl    %cl,%edx
  802697:	09 d0                	or     %edx,%eax
  802699:	89 f2                	mov    %esi,%edx
  80269b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80269f:	d3 ea                	shr    %cl,%edx
  8026a1:	83 c4 20             	add    $0x20,%esp
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	85 c9                	test   %ecx,%ecx
  8026aa:	75 0b                	jne    8026b7 <__umoddi3+0xe3>
  8026ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8026b1:	31 d2                	xor    %edx,%edx
  8026b3:	f7 f1                	div    %ecx
  8026b5:	89 c1                	mov    %eax,%ecx
  8026b7:	89 f0                	mov    %esi,%eax
  8026b9:	31 d2                	xor    %edx,%edx
  8026bb:	f7 f1                	div    %ecx
  8026bd:	89 f8                	mov    %edi,%eax
  8026bf:	e9 3e ff ff ff       	jmp    802602 <__umoddi3+0x2e>
  8026c4:	89 f2                	mov    %esi,%edx
  8026c6:	83 c4 20             	add    $0x20,%esp
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	5d                   	pop    %ebp
  8026cc:	c3                   	ret    
  8026cd:	8d 76 00             	lea    0x0(%esi),%esi
  8026d0:	39 f5                	cmp    %esi,%ebp
  8026d2:	72 04                	jb     8026d8 <__umoddi3+0x104>
  8026d4:	39 f9                	cmp    %edi,%ecx
  8026d6:	77 06                	ja     8026de <__umoddi3+0x10a>
  8026d8:	89 f2                	mov    %esi,%edx
  8026da:	29 cf                	sub    %ecx,%edi
  8026dc:	19 ea                	sbb    %ebp,%edx
  8026de:	89 f8                	mov    %edi,%eax
  8026e0:	83 c4 20             	add    $0x20,%esp
  8026e3:	5e                   	pop    %esi
  8026e4:	5f                   	pop    %edi
  8026e5:	5d                   	pop    %ebp
  8026e6:	c3                   	ret    
  8026e7:	90                   	nop
  8026e8:	89 d1                	mov    %edx,%ecx
  8026ea:	89 c5                	mov    %eax,%ebp
  8026ec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026f0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8026f4:	eb 8d                	jmp    802683 <__umoddi3+0xaf>
  8026f6:	66 90                	xchg   %ax,%ax
  8026f8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8026fc:	72 ea                	jb     8026e8 <__umoddi3+0x114>
  8026fe:	89 f1                	mov    %esi,%ecx
  802700:	eb 81                	jmp    802683 <__umoddi3+0xaf>
