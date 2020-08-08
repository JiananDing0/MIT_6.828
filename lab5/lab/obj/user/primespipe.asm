
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004d:	00 
  80004e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800052:	89 1c 24             	mov    %ebx,(%esp)
  800055:	e8 b0 17 00 00       	call   80180a <readn>
  80005a:	83 f8 04             	cmp    $0x4,%eax
  80005d:	74 30                	je     80008f <primeproc+0x5b>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005f:	85 c0                	test   %eax,%eax
  800061:	0f 9e c2             	setle  %dl
  800064:	0f b6 d2             	movzbl %dl,%edx
  800067:	f7 da                	neg    %edx
  800069:	21 c2                	and    %eax,%edx
  80006b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800073:	c7 44 24 08 60 26 80 	movl   $0x802660,0x8(%esp)
  80007a:	00 
  80007b:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800082:	00 
  800083:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  80008a:	e8 a9 02 00 00       	call   800338 <_panic>

	cprintf("%d\n", p);
  80008f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  80009d:	e8 8e 03 00 00       	call   800430 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a2:	89 3c 24             	mov    %edi,(%esp)
  8000a5:	e8 eb 1d 00 00       	call   801e95 <pipe>
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	79 20                	jns    8000d1 <primeproc+0x9d>
		panic("pipe: %e", i);
  8000b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b5:	c7 44 24 08 a5 26 80 	movl   $0x8026a5,0x8(%esp)
  8000bc:	00 
  8000bd:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  8000cc:	e8 67 02 00 00       	call   800338 <_panic>
	if ((id = fork()) < 0)
  8000d1:	e8 91 10 00 00       	call   801167 <fork>
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	79 20                	jns    8000fa <primeproc+0xc6>
		panic("fork: %e", id);
  8000da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000de:	c7 44 24 08 21 2b 80 	movl   $0x802b21,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  8000f5:	e8 3e 02 00 00       	call   800338 <_panic>
	if (id == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1b                	jne    800119 <primeproc+0xe5>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 10 15 00 00       	call   801616 <close>
		close(pfd[1]);
  800106:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 05 15 00 00       	call   801616 <close>
		fd = pfd[0];
  800111:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800114:	e9 2d ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800119:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 f2 14 00 00       	call   801616 <close>
	wfd = pfd[1];
  800124:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800127:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80012a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800131:	00 
  800132:	89 74 24 04          	mov    %esi,0x4(%esp)
  800136:	89 1c 24             	mov    %ebx,(%esp)
  800139:	e8 cc 16 00 00       	call   80180a <readn>
  80013e:	83 f8 04             	cmp    $0x4,%eax
  800141:	74 3b                	je     80017e <primeproc+0x14a>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800143:	85 c0                	test   %eax,%eax
  800145:	0f 9e c2             	setle  %dl
  800148:	0f b6 d2             	movzbl %dl,%edx
  80014b:	f7 da                	neg    %edx
  80014d:	21 c2                	and    %eax,%edx
  80014f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800153:	89 44 24 14          	mov    %eax,0x14(%esp)
  800157:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 ae 26 80 	movl   $0x8026ae,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  800179:	e8 ba 01 00 00       	call   800338 <_panic>
		if (i%p)
  80017e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800181:	99                   	cltd   
  800182:	f7 7d e0             	idivl  -0x20(%ebp)
  800185:	85 d2                	test   %edx,%edx
  800187:	74 a1                	je     80012a <primeproc+0xf6>
			if ((r=write(wfd, &i, 4)) != 4)
  800189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800190:	00 
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 3c 24             	mov    %edi,(%esp)
  800198:	e8 b8 16 00 00       	call   801855 <write>
  80019d:	83 f8 04             	cmp    $0x4,%eax
  8001a0:	74 88                	je     80012a <primeproc+0xf6>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	0f 9e c2             	setle  %dl
  8001a7:	0f b6 d2             	movzbl %dl,%edx
  8001aa:	f7 da                	neg    %edx
  8001ac:	21 c2                	and    %eax,%edx
  8001ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bd:	c7 44 24 08 ca 26 80 	movl   $0x8026ca,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  8001d4:	e8 5f 01 00 00       	call   800338 <_panic>

008001d9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001e0:	c7 05 00 30 80 00 e4 	movl   $0x8026e4,0x803000
  8001e7:	26 80 00 

	if ((i=pipe(p)) < 0)
  8001ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 a0 1c 00 00       	call   801e95 <pipe>
  8001f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	79 20                	jns    80021c <umain+0x43>
		panic("pipe: %e", i);
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	c7 44 24 08 a5 26 80 	movl   $0x8026a5,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  800217:	e8 1c 01 00 00       	call   800338 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021c:	e8 46 0f 00 00       	call   801167 <fork>
  800221:	85 c0                	test   %eax,%eax
  800223:	79 20                	jns    800245 <umain+0x6c>
		panic("fork: %e", id);
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	c7 44 24 08 21 2b 80 	movl   $0x802b21,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  800240:	e8 f3 00 00 00       	call   800338 <_panic>

	if (id == 0) {
  800245:	85 c0                	test   %eax,%eax
  800247:	75 16                	jne    80025f <umain+0x86>
		close(p[1]);
  800249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 c2 13 00 00       	call   801616 <close>
		primeproc(p[0]);
  800254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 d5 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 ac 13 00 00       	call   801616 <close>

	// feed all the integers through
	for (i=2;; i++)
  80026a:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800271:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800274:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80027b:	00 
  80027c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 ca 15 00 00       	call   801855 <write>
  80028b:	83 f8 04             	cmp    $0x4,%eax
  80028e:	74 30                	je     8002c0 <umain+0xe7>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800290:	85 c0                	test   %eax,%eax
  800292:	0f 9e c2             	setle  %dl
  800295:	0f b6 d2             	movzbl %dl,%edx
  800298:	f7 da                	neg    %edx
  80029a:	21 c2                	and    %eax,%edx
  80029c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a4:	c7 44 24 08 ef 26 80 	movl   $0x8026ef,0x8(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002b3:	00 
  8002b4:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  8002bb:	e8 78 00 00 00       	call   800338 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002c0:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002c3:	eb af                	jmp    800274 <umain+0x9b>
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 10             	sub    $0x10,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8002d6:	e8 d4 0a 00 00       	call   800daf <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e7:	c1 e0 07             	shl    $0x7,%eax
  8002ea:	29 d0                	sub    %edx,%eax
  8002ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f6:	85 f6                	test   %esi,%esi
  8002f8:	7e 07                	jle    800301 <libmain+0x39>
		binaryname = argv[0];
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800301:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800305:	89 34 24             	mov    %esi,(%esp)
  800308:	e8 cc fe ff ff       	call   8001d9 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    
  800319:	00 00                	add    %al,(%eax)
	...

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800322:	e8 20 13 00 00       	call   801647 <close_all>
	sys_env_destroy(0);
  800327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80032e:	e8 2a 0a 00 00       	call   800d5d <sys_env_destroy>
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    
  800335:	00 00                	add    %al,(%eax)
	...

00800338 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800349:	e8 61 0a 00 00       	call   800daf <sys_getenvid>
  80034e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800351:	89 54 24 10          	mov    %edx,0x10(%esp)
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  80036b:	e8 c0 00 00 00       	call   800430 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800370:	89 74 24 04          	mov    %esi,0x4(%esp)
  800374:	8b 45 10             	mov    0x10(%ebp),%eax
  800377:	89 04 24             	mov    %eax,(%esp)
  80037a:	e8 50 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037f:	c7 04 24 a3 26 80 00 	movl   $0x8026a3,(%esp)
  800386:	e8 a5 00 00 00       	call   800430 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038b:	cc                   	int3   
  80038c:	eb fd                	jmp    80038b <_panic+0x53>
	...

00800390 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 14             	sub    $0x14,%esp
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039a:	8b 03                	mov    (%ebx),%eax
  80039c:	8b 55 08             	mov    0x8(%ebp),%edx
  80039f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003a3:	40                   	inc    %eax
  8003a4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ab:	75 19                	jne    8003c6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003b4:	00 
  8003b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 60 09 00 00       	call   800d20 <sys_cputs>
		b->idx = 0;
  8003c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003c6:	ff 43 04             	incl   0x4(%ebx)
}
  8003c9:	83 c4 14             	add    $0x14,%esp
  8003cc:	5b                   	pop    %ebx
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003df:	00 00 00 
	b.cnt = 0;
  8003e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  80040b:	e8 82 01 00 00       	call   800592 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800410:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 f8 08 00 00       	call   800d20 <sys_cputs>

	return b.cnt;
}
  800428:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800436:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 87 ff ff ff       	call   8003cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    
	...

0080044c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 3c             	sub    $0x3c,%esp
  800455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800458:	89 d7                	mov    %edx,%edi
  80045a:	8b 45 08             	mov    0x8(%ebp),%eax
  80045d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800469:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046c:	85 c0                	test   %eax,%eax
  80046e:	75 08                	jne    800478 <printnum+0x2c>
  800470:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800473:	39 45 10             	cmp    %eax,0x10(%ebp)
  800476:	77 57                	ja     8004cf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800478:	89 74 24 10          	mov    %esi,0x10(%esp)
  80047c:	4b                   	dec    %ebx
  80047d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800481:	8b 45 10             	mov    0x10(%ebp),%eax
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80048c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800497:	00 
  800498:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	e8 4e 1f 00 00       	call   8023f8 <__udivdi3>
  8004aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004b2:	89 04 24             	mov    %eax,(%esp)
  8004b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b9:	89 fa                	mov    %edi,%edx
  8004bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004be:	e8 89 ff ff ff       	call   80044c <printnum>
  8004c3:	eb 0f                	jmp    8004d4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c9:	89 34 24             	mov    %esi,(%esp)
  8004cc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cf:	4b                   	dec    %ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f f1                	jg     8004c5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ea:	00 
  8004eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	e8 1b 20 00 00       	call   802518 <__umoddi3>
  8004fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800501:	0f be 80 37 27 80 00 	movsbl 0x802737(%eax),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80050e:	83 c4 3c             	add    $0x3c,%esp
  800511:	5b                   	pop    %ebx
  800512:	5e                   	pop    %esi
  800513:	5f                   	pop    %edi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800519:	83 fa 01             	cmp    $0x1,%edx
  80051c:	7e 0e                	jle    80052c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80051e:	8b 10                	mov    (%eax),%edx
  800520:	8d 4a 08             	lea    0x8(%edx),%ecx
  800523:	89 08                	mov    %ecx,(%eax)
  800525:	8b 02                	mov    (%edx),%eax
  800527:	8b 52 04             	mov    0x4(%edx),%edx
  80052a:	eb 22                	jmp    80054e <getuint+0x38>
	else if (lflag)
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 10                	je     800540 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800530:	8b 10                	mov    (%eax),%edx
  800532:	8d 4a 04             	lea    0x4(%edx),%ecx
  800535:	89 08                	mov    %ecx,(%eax)
  800537:	8b 02                	mov    (%edx),%eax
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
  80053e:	eb 0e                	jmp    80054e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800540:	8b 10                	mov    (%eax),%edx
  800542:	8d 4a 04             	lea    0x4(%edx),%ecx
  800545:	89 08                	mov    %ecx,(%eax)
  800547:	8b 02                	mov    (%edx),%eax
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800556:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	3b 50 04             	cmp    0x4(%eax),%edx
  80055e:	73 08                	jae    800568 <sprintputch+0x18>
		*b->buf++ = ch;
  800560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800563:	88 0a                	mov    %cl,(%edx)
  800565:	42                   	inc    %edx
  800566:	89 10                	mov    %edx,(%eax)
}
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800573:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800577:	8b 45 10             	mov    0x10(%ebp),%eax
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 02 00 00 00       	call   800592 <vprintfmt>
	va_end(ap);
}
  800590:	c9                   	leave  
  800591:	c3                   	ret    

00800592 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	57                   	push   %edi
  800596:	56                   	push   %esi
  800597:	53                   	push   %ebx
  800598:	83 ec 4c             	sub    $0x4c,%esp
  80059b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059e:	8b 75 10             	mov    0x10(%ebp),%esi
  8005a1:	eb 12                	jmp    8005b5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	0f 84 8b 03 00 00    	je     800936 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8005ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b5:	0f b6 06             	movzbl (%esi),%eax
  8005b8:	46                   	inc    %esi
  8005b9:	83 f8 25             	cmp    $0x25,%eax
  8005bc:	75 e5                	jne    8005a3 <vprintfmt+0x11>
  8005be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	eb 26                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005df:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005e3:	eb 1d                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005ec:	eb 14                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f8:	eb 08                	jmp    800602 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005fa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	0f b6 06             	movzbl (%esi),%eax
  800605:	8d 56 01             	lea    0x1(%esi),%edx
  800608:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060b:	8a 16                	mov    (%esi),%dl
  80060d:	83 ea 23             	sub    $0x23,%edx
  800610:	80 fa 55             	cmp    $0x55,%dl
  800613:	0f 87 01 03 00 00    	ja     80091a <vprintfmt+0x388>
  800619:	0f b6 d2             	movzbl %dl,%edx
  80061c:	ff 24 95 80 28 80 00 	jmp    *0x802880(,%edx,4)
  800623:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800626:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80062b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80062e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800632:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800635:	8d 50 d0             	lea    -0x30(%eax),%edx
  800638:	83 fa 09             	cmp    $0x9,%edx
  80063b:	77 2a                	ja     800667 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80063d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80063e:	eb eb                	jmp    80062b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80064e:	eb 17                	jmp    800667 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800650:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800654:	78 98                	js     8005ee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800659:	eb a7                	jmp    800602 <vprintfmt+0x70>
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800665:	eb 9b                	jmp    800602 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	79 95                	jns    800602 <vprintfmt+0x70>
  80066d:	eb 8b                	jmp    8005fa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80066f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800673:	eb 8d                	jmp    800602 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80068d:	e9 23 ff ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	79 02                	jns    8006a3 <vprintfmt+0x111>
  8006a1:	f7 d8                	neg    %eax
  8006a3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a5:	83 f8 0f             	cmp    $0xf,%eax
  8006a8:	7f 0b                	jg     8006b5 <vprintfmt+0x123>
  8006aa:	8b 04 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%eax
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	75 23                	jne    8006d8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b9:	c7 44 24 08 4f 27 80 	movl   $0x80274f,0x8(%esp)
  8006c0:	00 
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	e8 9a fe ff ff       	call   80056a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d3:	e9 dd fe ff ff       	jmp    8005b5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006dc:	c7 44 24 08 3a 2c 80 	movl   $0x802c3a,0x8(%esp)
  8006e3:	00 
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006eb:	89 14 24             	mov    %edx,(%esp)
  8006ee:	e8 77 fe ff ff       	call   80056a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f6:	e9 ba fe ff ff       	jmp    8005b5 <vprintfmt+0x23>
  8006fb:	89 f9                	mov    %edi,%ecx
  8006fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800700:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 30                	mov    (%eax),%esi
  80070e:	85 f6                	test   %esi,%esi
  800710:	75 05                	jne    800717 <vprintfmt+0x185>
				p = "(null)";
  800712:	be 48 27 80 00       	mov    $0x802748,%esi
			if (width > 0 && padc != '-')
  800717:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071b:	0f 8e 84 00 00 00    	jle    8007a5 <vprintfmt+0x213>
  800721:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800725:	74 7e                	je     8007a5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800727:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80072b:	89 34 24             	mov    %esi,(%esp)
  80072e:	e8 ab 02 00 00       	call   8009de <strnlen>
  800733:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800736:	29 c2                	sub    %eax,%edx
  800738:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80073b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80073f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800742:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800745:	89 de                	mov    %ebx,%esi
  800747:	89 d3                	mov    %edx,%ebx
  800749:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	eb 0b                	jmp    800758 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80074d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800751:	89 3c 24             	mov    %edi,(%esp)
  800754:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800757:	4b                   	dec    %ebx
  800758:	85 db                	test   %ebx,%ebx
  80075a:	7f f1                	jg     80074d <vprintfmt+0x1bb>
  80075c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800767:	85 c0                	test   %eax,%eax
  800769:	79 05                	jns    800770 <vprintfmt+0x1de>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800773:	29 c2                	sub    %eax,%edx
  800775:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800778:	eb 2b                	jmp    8007a5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80077a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80077e:	74 18                	je     800798 <vprintfmt+0x206>
  800780:	8d 50 e0             	lea    -0x20(%eax),%edx
  800783:	83 fa 5e             	cmp    $0x5e,%edx
  800786:	76 10                	jbe    800798 <vprintfmt+0x206>
					putch('?', putdat);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
  800796:	eb 0a                	jmp    8007a2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	89 04 24             	mov    %eax,(%esp)
  80079f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007a5:	0f be 06             	movsbl (%esi),%eax
  8007a8:	46                   	inc    %esi
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	74 21                	je     8007ce <vprintfmt+0x23c>
  8007ad:	85 ff                	test   %edi,%edi
  8007af:	78 c9                	js     80077a <vprintfmt+0x1e8>
  8007b1:	4f                   	dec    %edi
  8007b2:	79 c6                	jns    80077a <vprintfmt+0x1e8>
  8007b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b7:	89 de                	mov    %ebx,%esi
  8007b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007bc:	eb 18                	jmp    8007d6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cb:	4b                   	dec    %ebx
  8007cc:	eb 08                	jmp    8007d6 <vprintfmt+0x244>
  8007ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d1:	89 de                	mov    %ebx,%esi
  8007d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007d6:	85 db                	test   %ebx,%ebx
  8007d8:	7f e4                	jg     8007be <vprintfmt+0x22c>
  8007da:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007dd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007e2:	e9 ce fd ff ff       	jmp    8005b5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e7:	83 f9 01             	cmp    $0x1,%ecx
  8007ea:	7e 10                	jle    8007fc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 08             	lea    0x8(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	8b 30                	mov    (%eax),%esi
  8007f7:	8b 78 04             	mov    0x4(%eax),%edi
  8007fa:	eb 26                	jmp    800822 <vprintfmt+0x290>
	else if (lflag)
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	74 12                	je     800812 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 30                	mov    (%eax),%esi
  80080b:	89 f7                	mov    %esi,%edi
  80080d:	c1 ff 1f             	sar    $0x1f,%edi
  800810:	eb 10                	jmp    800822 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 30                	mov    (%eax),%esi
  80081d:	89 f7                	mov    %esi,%edi
  80081f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800822:	85 ff                	test   %edi,%edi
  800824:	78 0a                	js     800830 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082b:	e9 ac 00 00 00       	jmp    8008dc <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80083b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80083e:	f7 de                	neg    %esi
  800840:	83 d7 00             	adc    $0x0,%edi
  800843:	f7 df                	neg    %edi
			}
			base = 10;
  800845:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084a:	e9 8d 00 00 00       	jmp    8008dc <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084f:	89 ca                	mov    %ecx,%edx
  800851:	8d 45 14             	lea    0x14(%ebp),%eax
  800854:	e8 bd fc ff ff       	call   800516 <getuint>
  800859:	89 c6                	mov    %eax,%esi
  80085b:	89 d7                	mov    %edx,%edi
			base = 10;
  80085d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800862:	eb 78                	jmp    8008dc <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800864:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800868:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80086f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800876:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80087d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800891:	e9 1f fd ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800896:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008bb:	8b 30                	mov    (%eax),%esi
  8008bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008c7:	eb 13                	jmp    8008dc <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c9:	89 ca                	mov    %ecx,%edx
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ce:	e8 43 fc ff ff       	call   800516 <getuint>
  8008d3:	89 c6                	mov    %eax,%esi
  8008d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8008d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ef:	89 34 24             	mov    %esi,(%esp)
  8008f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f6:	89 da                	mov    %ebx,%edx
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	e8 4c fb ff ff       	call   80044c <printnum>
			break;
  800900:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800903:	e9 ad fc ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800908:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090c:	89 04 24             	mov    %eax,(%esp)
  80090f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800912:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800915:	e9 9b fc ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800925:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800928:	eb 01                	jmp    80092b <vprintfmt+0x399>
  80092a:	4e                   	dec    %esi
  80092b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80092f:	75 f9                	jne    80092a <vprintfmt+0x398>
  800931:	e9 7f fc ff ff       	jmp    8005b5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800936:	83 c4 4c             	add    $0x4c,%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 28             	sub    $0x28,%esp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800951:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800954:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095b:	85 c0                	test   %eax,%eax
  80095d:	74 30                	je     80098f <vsnprintf+0x51>
  80095f:	85 d2                	test   %edx,%edx
  800961:	7e 33                	jle    800996 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096a:	8b 45 10             	mov    0x10(%ebp),%eax
  80096d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800971:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800974:	89 44 24 04          	mov    %eax,0x4(%esp)
  800978:	c7 04 24 50 05 80 00 	movl   $0x800550,(%esp)
  80097f:	e8 0e fc ff ff       	call   800592 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800984:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800987:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098d:	eb 0c                	jmp    80099b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80098f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800994:	eb 05                	jmp    80099b <vsnprintf+0x5d>
  800996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	89 04 24             	mov    %eax,(%esp)
  8009be:	e8 7b ff ff ff       	call   80093e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    
  8009c5:	00 00                	add    %al,(%eax)
	...

008009c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d3:	eb 01                	jmp    8009d6 <strlen+0xe>
		n++;
  8009d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009da:	75 f9                	jne    8009d5 <strlen+0xd>
		n++;
	return n;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ec:	eb 01                	jmp    8009ef <strnlen+0x11>
		n++;
  8009ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ef:	39 d0                	cmp    %edx,%eax
  8009f1:	74 06                	je     8009f9 <strnlen+0x1b>
  8009f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009f7:	75 f5                	jne    8009ee <strnlen+0x10>
		n++;
	return n;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a10:	42                   	inc    %edx
  800a11:	84 c9                	test   %cl,%cl
  800a13:	75 f5                	jne    800a0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a15:	5b                   	pop    %ebx
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	53                   	push   %ebx
  800a1c:	83 ec 08             	sub    $0x8,%esp
  800a1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a22:	89 1c 24             	mov    %ebx,(%esp)
  800a25:	e8 9e ff ff ff       	call   8009c8 <strlen>
	strcpy(dst + len, src);
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a31:	01 d8                	add    %ebx,%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 c0 ff ff ff       	call   8009fb <strcpy>
	return dst;
}
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	83 c4 08             	add    $0x8,%esp
  800a40:	5b                   	pop    %ebx
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a56:	eb 0c                	jmp    800a64 <strncpy+0x21>
		*dst++ = *src;
  800a58:	8a 1a                	mov    (%edx),%bl
  800a5a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a5d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a60:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a63:	41                   	inc    %ecx
  800a64:	39 f1                	cmp    %esi,%ecx
  800a66:	75 f0                	jne    800a58 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 75 08             	mov    0x8(%ebp),%esi
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a77:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a7a:	85 d2                	test   %edx,%edx
  800a7c:	75 0a                	jne    800a88 <strlcpy+0x1c>
  800a7e:	89 f0                	mov    %esi,%eax
  800a80:	eb 1a                	jmp    800a9c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a82:	88 18                	mov    %bl,(%eax)
  800a84:	40                   	inc    %eax
  800a85:	41                   	inc    %ecx
  800a86:	eb 02                	jmp    800a8a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a88:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a8a:	4a                   	dec    %edx
  800a8b:	74 0a                	je     800a97 <strlcpy+0x2b>
  800a8d:	8a 19                	mov    (%ecx),%bl
  800a8f:	84 db                	test   %bl,%bl
  800a91:	75 ef                	jne    800a82 <strlcpy+0x16>
  800a93:	89 c2                	mov    %eax,%edx
  800a95:	eb 02                	jmp    800a99 <strlcpy+0x2d>
  800a97:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a99:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a9c:	29 f0                	sub    %esi,%eax
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aab:	eb 02                	jmp    800aaf <strcmp+0xd>
		p++, q++;
  800aad:	41                   	inc    %ecx
  800aae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaf:	8a 01                	mov    (%ecx),%al
  800ab1:	84 c0                	test   %al,%al
  800ab3:	74 04                	je     800ab9 <strcmp+0x17>
  800ab5:	3a 02                	cmp    (%edx),%al
  800ab7:	74 f4                	je     800aad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 12             	movzbl (%edx),%edx
  800abf:	29 d0                	sub    %edx,%eax
}
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ad0:	eb 03                	jmp    800ad5 <strncmp+0x12>
		n--, p++, q++;
  800ad2:	4a                   	dec    %edx
  800ad3:	40                   	inc    %eax
  800ad4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad5:	85 d2                	test   %edx,%edx
  800ad7:	74 14                	je     800aed <strncmp+0x2a>
  800ad9:	8a 18                	mov    (%eax),%bl
  800adb:	84 db                	test   %bl,%bl
  800add:	74 04                	je     800ae3 <strncmp+0x20>
  800adf:	3a 19                	cmp    (%ecx),%bl
  800ae1:	74 ef                	je     800ad2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae3:	0f b6 00             	movzbl (%eax),%eax
  800ae6:	0f b6 11             	movzbl (%ecx),%edx
  800ae9:	29 d0                	sub    %edx,%eax
  800aeb:	eb 05                	jmp    800af2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800afe:	eb 05                	jmp    800b05 <strchr+0x10>
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 0c                	je     800b10 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b04:	40                   	inc    %eax
  800b05:	8a 10                	mov    (%eax),%dl
  800b07:	84 d2                	test   %dl,%dl
  800b09:	75 f5                	jne    800b00 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b1b:	eb 05                	jmp    800b22 <strfind+0x10>
		if (*s == c)
  800b1d:	38 ca                	cmp    %cl,%dl
  800b1f:	74 07                	je     800b28 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b21:	40                   	inc    %eax
  800b22:	8a 10                	mov    (%eax),%dl
  800b24:	84 d2                	test   %dl,%dl
  800b26:	75 f5                	jne    800b1d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b39:	85 c9                	test   %ecx,%ecx
  800b3b:	74 30                	je     800b6d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b43:	75 25                	jne    800b6a <memset+0x40>
  800b45:	f6 c1 03             	test   $0x3,%cl
  800b48:	75 20                	jne    800b6a <memset+0x40>
		c &= 0xFF;
  800b4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	c1 e3 08             	shl    $0x8,%ebx
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	c1 e6 18             	shl    $0x18,%esi
  800b57:	89 d0                	mov    %edx,%eax
  800b59:	c1 e0 10             	shl    $0x10,%eax
  800b5c:	09 f0                	or     %esi,%eax
  800b5e:	09 d0                	or     %edx,%eax
  800b60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b65:	fc                   	cld    
  800b66:	f3 ab                	rep stos %eax,%es:(%edi)
  800b68:	eb 03                	jmp    800b6d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b82:	39 c6                	cmp    %eax,%esi
  800b84:	73 34                	jae    800bba <memmove+0x46>
  800b86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b89:	39 d0                	cmp    %edx,%eax
  800b8b:	73 2d                	jae    800bba <memmove+0x46>
		s += n;
		d += n;
  800b8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	f6 c2 03             	test   $0x3,%dl
  800b93:	75 1b                	jne    800bb0 <memmove+0x3c>
  800b95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9b:	75 13                	jne    800bb0 <memmove+0x3c>
  800b9d:	f6 c1 03             	test   $0x3,%cl
  800ba0:	75 0e                	jne    800bb0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba2:	83 ef 04             	sub    $0x4,%edi
  800ba5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bab:	fd                   	std    
  800bac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bae:	eb 07                	jmp    800bb7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb0:	4f                   	dec    %edi
  800bb1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb4:	fd                   	std    
  800bb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb7:	fc                   	cld    
  800bb8:	eb 20                	jmp    800bda <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bc0:	75 13                	jne    800bd5 <memmove+0x61>
  800bc2:	a8 03                	test   $0x3,%al
  800bc4:	75 0f                	jne    800bd5 <memmove+0x61>
  800bc6:	f6 c1 03             	test   $0x3,%cl
  800bc9:	75 0a                	jne    800bd5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bcb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bce:	89 c7                	mov    %eax,%edi
  800bd0:	fc                   	cld    
  800bd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd3:	eb 05                	jmp    800bda <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd5:	89 c7                	mov    %eax,%edi
  800bd7:	fc                   	cld    
  800bd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be4:	8b 45 10             	mov    0x10(%ebp),%eax
  800be7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf5:	89 04 24             	mov    %eax,(%esp)
  800bf8:	e8 77 ff ff ff       	call   800b74 <memmove>
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	eb 16                	jmp    800c2b <memcmp+0x2c>
		if (*s1 != *s2)
  800c15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c18:	42                   	inc    %edx
  800c19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c1d:	38 c8                	cmp    %cl,%al
  800c1f:	74 0a                	je     800c2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c21:	0f b6 c0             	movzbl %al,%eax
  800c24:	0f b6 c9             	movzbl %cl,%ecx
  800c27:	29 c8                	sub    %ecx,%eax
  800c29:	eb 09                	jmp    800c34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2b:	39 da                	cmp    %ebx,%edx
  800c2d:	75 e6                	jne    800c15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c42:	89 c2                	mov    %eax,%edx
  800c44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c47:	eb 05                	jmp    800c4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c49:	38 08                	cmp    %cl,(%eax)
  800c4b:	74 05                	je     800c52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4d:	40                   	inc    %eax
  800c4e:	39 d0                	cmp    %edx,%eax
  800c50:	72 f7                	jb     800c49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c60:	eb 01                	jmp    800c63 <strtol+0xf>
		s++;
  800c62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c63:	8a 02                	mov    (%edx),%al
  800c65:	3c 20                	cmp    $0x20,%al
  800c67:	74 f9                	je     800c62 <strtol+0xe>
  800c69:	3c 09                	cmp    $0x9,%al
  800c6b:	74 f5                	je     800c62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c6d:	3c 2b                	cmp    $0x2b,%al
  800c6f:	75 08                	jne    800c79 <strtol+0x25>
		s++;
  800c71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c72:	bf 00 00 00 00       	mov    $0x0,%edi
  800c77:	eb 13                	jmp    800c8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c79:	3c 2d                	cmp    $0x2d,%al
  800c7b:	75 0a                	jne    800c87 <strtol+0x33>
		s++, neg = 1;
  800c7d:	8d 52 01             	lea    0x1(%edx),%edx
  800c80:	bf 01 00 00 00       	mov    $0x1,%edi
  800c85:	eb 05                	jmp    800c8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8c:	85 db                	test   %ebx,%ebx
  800c8e:	74 05                	je     800c95 <strtol+0x41>
  800c90:	83 fb 10             	cmp    $0x10,%ebx
  800c93:	75 28                	jne    800cbd <strtol+0x69>
  800c95:	8a 02                	mov    (%edx),%al
  800c97:	3c 30                	cmp    $0x30,%al
  800c99:	75 10                	jne    800cab <strtol+0x57>
  800c9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c9f:	75 0a                	jne    800cab <strtol+0x57>
		s += 2, base = 16;
  800ca1:	83 c2 02             	add    $0x2,%edx
  800ca4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca9:	eb 12                	jmp    800cbd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cab:	85 db                	test   %ebx,%ebx
  800cad:	75 0e                	jne    800cbd <strtol+0x69>
  800caf:	3c 30                	cmp    $0x30,%al
  800cb1:	75 05                	jne    800cb8 <strtol+0x64>
		s++, base = 8;
  800cb3:	42                   	inc    %edx
  800cb4:	b3 08                	mov    $0x8,%bl
  800cb6:	eb 05                	jmp    800cbd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cb8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc4:	8a 0a                	mov    (%edx),%cl
  800cc6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cc9:	80 fb 09             	cmp    $0x9,%bl
  800ccc:	77 08                	ja     800cd6 <strtol+0x82>
			dig = *s - '0';
  800cce:	0f be c9             	movsbl %cl,%ecx
  800cd1:	83 e9 30             	sub    $0x30,%ecx
  800cd4:	eb 1e                	jmp    800cf4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cd6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cd9:	80 fb 19             	cmp    $0x19,%bl
  800cdc:	77 08                	ja     800ce6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cde:	0f be c9             	movsbl %cl,%ecx
  800ce1:	83 e9 57             	sub    $0x57,%ecx
  800ce4:	eb 0e                	jmp    800cf4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ce6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ce9:	80 fb 19             	cmp    $0x19,%bl
  800cec:	77 12                	ja     800d00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800cee:	0f be c9             	movsbl %cl,%ecx
  800cf1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cf4:	39 f1                	cmp    %esi,%ecx
  800cf6:	7d 0c                	jge    800d04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cf8:	42                   	inc    %edx
  800cf9:	0f af c6             	imul   %esi,%eax
  800cfc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cfe:	eb c4                	jmp    800cc4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d00:	89 c1                	mov    %eax,%ecx
  800d02:	eb 02                	jmp    800d06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d0a:	74 05                	je     800d11 <strtol+0xbd>
		*endptr = (char *) s;
  800d0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d11:	85 ff                	test   %edi,%edi
  800d13:	74 04                	je     800d19 <strtol+0xc5>
  800d15:	89 c8                	mov    %ecx,%eax
  800d17:	f7 d8                	neg    %eax
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
	...

00800d20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 c3                	mov    %eax,%ebx
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	89 c6                	mov    %eax,%esi
  800d37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
  800d49:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4e:	89 d1                	mov    %edx,%ecx
  800d50:	89 d3                	mov    %edx,%ebx
  800d52:	89 d7                	mov    %edx,%edi
  800d54:	89 d6                	mov    %edx,%esi
  800d56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 cb                	mov    %ecx,%ebx
  800d75:	89 cf                	mov    %ecx,%edi
  800d77:	89 ce                	mov    %ecx,%esi
  800d79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7e 28                	jle    800da7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800d92:	00 
  800d93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9a:	00 
  800d9b:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800da2:	e8 91 f5 ff ff       	call   800338 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800da7:	83 c4 2c             	add    $0x2c,%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dba:	b8 02 00 00 00       	mov    $0x2,%eax
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 d3                	mov    %edx,%ebx
  800dc3:	89 d7                	mov    %edx,%edi
  800dc5:	89 d6                	mov    %edx,%esi
  800dc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_yield>:

void
sys_yield(void)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dde:	89 d1                	mov    %edx,%ecx
  800de0:	89 d3                	mov    %edx,%ebx
  800de2:	89 d7                	mov    %edx,%edi
  800de4:	89 d6                	mov    %edx,%esi
  800de6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	be 00 00 00 00       	mov    $0x0,%esi
  800dfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800e00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 f7                	mov    %esi,%edi
  800e0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	7e 28                	jle    800e39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800e24:	00 
  800e25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2c:	00 
  800e2d:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800e34:	e8 ff f4 ff ff       	call   800338 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e39:	83 c4 2c             	add    $0x2c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7e 28                	jle    800e8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e6f:	00 
  800e70:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800e77:	00 
  800e78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7f:	00 
  800e80:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800e87:	e8 ac f4 ff ff       	call   800338 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8c:	83 c4 2c             	add    $0x2c,%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ea7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ead:	89 df                	mov    %ebx,%edi
  800eaf:	89 de                	mov    %ebx,%esi
  800eb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	7e 28                	jle    800edf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800eca:	00 
  800ecb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed2:	00 
  800ed3:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800eda:	e8 59 f4 ff ff       	call   800338 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800edf:	83 c4 2c             	add    $0x2c,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef5:	b8 08 00 00 00       	mov    $0x8,%eax
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	89 df                	mov    %ebx,%edi
  800f02:	89 de                	mov    %ebx,%esi
  800f04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f06:	85 c0                	test   %eax,%eax
  800f08:	7e 28                	jle    800f32 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f15:	00 
  800f16:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f25:	00 
  800f26:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800f2d:	e8 06 f4 ff ff       	call   800338 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f32:	83 c4 2c             	add    $0x2c,%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f48:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f50:	8b 55 08             	mov    0x8(%ebp),%edx
  800f53:	89 df                	mov    %ebx,%edi
  800f55:	89 de                	mov    %ebx,%esi
  800f57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 28                	jle    800f85 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f61:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f68:	00 
  800f69:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800f80:	e8 b3 f3 ff ff       	call   800338 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f85:	83 c4 2c             	add    $0x2c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	89 df                	mov    %ebx,%edi
  800fa8:	89 de                	mov    %ebx,%esi
  800faa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	7e 28                	jle    800fd8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fcb:	00 
  800fcc:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  800fd3:	e8 60 f3 ff ff       	call   800338 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fd8:	83 c4 2c             	add    $0x2c,%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	be 00 00 00 00       	mov    $0x0,%esi
  800feb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	57                   	push   %edi
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801011:	b8 0d 00 00 00       	mov    $0xd,%eax
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	89 cb                	mov    %ecx,%ebx
  80101b:	89 cf                	mov    %ecx,%edi
  80101d:	89 ce                	mov    %ecx,%esi
  80101f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801021:	85 c0                	test   %eax,%eax
  801023:	7e 28                	jle    80104d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801025:	89 44 24 10          	mov    %eax,0x10(%esp)
  801029:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801030:	00 
  801031:	c7 44 24 08 3f 2a 80 	movl   $0x802a3f,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  801048:	e8 eb f2 ff ff       	call   800338 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80104d:	83 c4 2c             	add    $0x2c,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	00 00                	add    %al,(%eax)
	...

00801058 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 24             	sub    $0x24,%esp
  80105f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801062:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  801064:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801068:	75 20                	jne    80108a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  80106a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80106e:	c7 44 24 08 6c 2a 80 	movl   $0x802a6c,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  801085:	e8 ae f2 ff ff       	call   800338 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80108a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801090:	89 d8                	mov    %ebx,%eax
  801092:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801095:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109c:	f6 c4 08             	test   $0x8,%ah
  80109f:	75 1c                	jne    8010bd <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8010a1:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  8010b8:	e8 7b f2 ff ff       	call   800338 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  8010bd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010c4:	00 
  8010c5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010cc:	00 
  8010cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d4:	e8 14 fd ff ff       	call   800ded <sys_page_alloc>
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	79 20                	jns    8010fd <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  8010dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e1:	c7 44 24 08 f6 2a 80 	movl   $0x802af6,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  8010f8:	e8 3b f2 ff ff       	call   800338 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  8010fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801104:	00 
  801105:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801109:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801110:	e8 5f fa ff ff       	call   800b74 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  801115:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80111c:	00 
  80111d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801121:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801138:	e8 04 fd ff ff       	call   800e41 <sys_page_map>
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 20                	jns    801161 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  801141:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801145:	c7 44 24 08 09 2b 80 	movl   $0x802b09,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80115c:	e8 d7 f1 ff ff       	call   800338 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  801161:	83 c4 24             	add    $0x24,%esp
  801164:	5b                   	pop    %ebx
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  801170:	c7 04 24 58 10 80 00 	movl   $0x801058,(%esp)
  801177:	e8 5c 10 00 00       	call   8021d8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80117c:	ba 07 00 00 00       	mov    $0x7,%edx
  801181:	89 d0                	mov    %edx,%eax
  801183:	cd 30                	int    $0x30
  801185:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801188:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  80118b:	85 c0                	test   %eax,%eax
  80118d:	79 20                	jns    8011af <fork+0x48>
		panic("sys_exofork: %e", envid);
  80118f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801193:	c7 44 24 08 1a 2b 80 	movl   $0x802b1a,0x8(%esp)
  80119a:	00 
  80119b:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  8011a2:	00 
  8011a3:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  8011aa:	e8 89 f1 ff ff       	call   800338 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  8011af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011b3:	75 25                	jne    8011da <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011b5:	e8 f5 fb ff ff       	call   800daf <sys_getenvid>
  8011ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011c6:	c1 e0 07             	shl    $0x7,%eax
  8011c9:	29 d0                	sub    %edx,%eax
  8011cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011d5:	e9 58 02 00 00       	jmp    801432 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  8011da:	bf 00 00 00 00       	mov    $0x0,%edi
  8011df:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8011e4:	89 f0                	mov    %esi,%eax
  8011e6:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8011e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f0:	a8 01                	test   $0x1,%al
  8011f2:	0f 84 7a 01 00 00    	je     801372 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8011f8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8011ff:	a8 01                	test   $0x1,%al
  801201:	0f 84 6b 01 00 00    	je     801372 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801207:	a1 04 40 80 00       	mov    0x804004,%eax
  80120c:	8b 40 48             	mov    0x48(%eax),%eax
  80120f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801212:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801219:	f6 c4 04             	test   $0x4,%ah
  80121c:	74 52                	je     801270 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80121e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801225:	25 07 0e 00 00       	and    $0xe07,%eax
  80122a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801235:	89 44 24 08          	mov    %eax,0x8(%esp)
  801239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80123d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801240:	89 04 24             	mov    %eax,(%esp)
  801243:	e8 f9 fb ff ff       	call   800e41 <sys_page_map>
  801248:	85 c0                	test   %eax,%eax
  80124a:	0f 89 22 01 00 00    	jns    801372 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801250:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801254:	c7 44 24 08 2a 2b 80 	movl   $0x802b2a,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801263:	00 
  801264:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80126b:	e8 c8 f0 ff ff       	call   800338 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801270:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801277:	f6 c4 08             	test   $0x8,%ah
  80127a:	75 0f                	jne    80128b <fork+0x124>
  80127c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801283:	a8 02                	test   $0x2,%al
  801285:	0f 84 99 00 00 00    	je     801324 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80128b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801292:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801295:	83 f8 01             	cmp    $0x1,%eax
  801298:	19 db                	sbb    %ebx,%ebx
  80129a:	83 e3 fc             	and    $0xfffffffc,%ebx
  80129d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8012a3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012a7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b9:	89 04 24             	mov    %eax,(%esp)
  8012bc:	e8 80 fb ff ff       	call   800e41 <sys_page_map>
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	79 20                	jns    8012e5 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8012c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c9:	c7 44 24 08 2a 2b 80 	movl   $0x802b2a,0x8(%esp)
  8012d0:	00 
  8012d1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8012d8:	00 
  8012d9:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  8012e0:	e8 53 f0 ff ff       	call   800338 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8012e5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012e9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	e8 41 fb ff ff       	call   800e41 <sys_page_map>
  801300:	85 c0                	test   %eax,%eax
  801302:	79 6e                	jns    801372 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801304:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801308:	c7 44 24 08 2a 2b 80 	movl   $0x802b2a,0x8(%esp)
  80130f:	00 
  801310:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801317:	00 
  801318:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80131f:	e8 14 f0 ff ff       	call   800338 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801324:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80132b:	25 07 0e 00 00       	and    $0xe07,%eax
  801330:	89 44 24 10          	mov    %eax,0x10(%esp)
  801334:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80133b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801343:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 f3 fa ff ff       	call   800e41 <sys_page_map>
  80134e:	85 c0                	test   %eax,%eax
  801350:	79 20                	jns    801372 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801352:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801356:	c7 44 24 08 2a 2b 80 	movl   $0x802b2a,0x8(%esp)
  80135d:	00 
  80135e:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801365:	00 
  801366:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80136d:	e8 c6 ef ff ff       	call   800338 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801372:	46                   	inc    %esi
  801373:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801379:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80137f:	0f 85 5f fe ff ff    	jne    8011e4 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801385:	c7 44 24 04 78 22 80 	movl   $0x802278,0x4(%esp)
  80138c:	00 
  80138d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801390:	89 04 24             	mov    %eax,(%esp)
  801393:	e8 f5 fb ff ff       	call   800f8d <sys_env_set_pgfault_upcall>
  801398:	85 c0                	test   %eax,%eax
  80139a:	79 20                	jns    8013bc <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  80139c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a0:	c7 44 24 08 cc 2a 80 	movl   $0x802acc,0x8(%esp)
  8013a7:	00 
  8013a8:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8013af:	00 
  8013b0:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  8013b7:	e8 7c ef ff ff       	call   800338 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8013bc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013c3:	00 
  8013c4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013cb:	ee 
  8013cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013cf:	89 04 24             	mov    %eax,(%esp)
  8013d2:	e8 16 fa ff ff       	call   800ded <sys_page_alloc>
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	79 20                	jns    8013fb <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8013db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013df:	c7 44 24 08 f6 2a 80 	movl   $0x802af6,0x8(%esp)
  8013e6:	00 
  8013e7:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8013ee:	00 
  8013ef:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  8013f6:	e8 3d ef ff ff       	call   800338 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8013fb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801402:	00 
  801403:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801406:	89 04 24             	mov    %eax,(%esp)
  801409:	e8 d9 fa ff ff       	call   800ee7 <sys_env_set_status>
  80140e:	85 c0                	test   %eax,%eax
  801410:	79 20                	jns    801432 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801412:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801416:	c7 44 24 08 3c 2b 80 	movl   $0x802b3c,0x8(%esp)
  80141d:	00 
  80141e:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801425:	00 
  801426:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80142d:	e8 06 ef ff ff       	call   800338 <_panic>
	}
	
	return envid;
}
  801432:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801435:	83 c4 3c             	add    $0x3c,%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5f                   	pop    %edi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    

0080143d <sfork>:

// Challenge!
int
sfork(void)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801443:	c7 44 24 08 53 2b 80 	movl   $0x802b53,0x8(%esp)
  80144a:	00 
  80144b:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801452:	00 
  801453:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80145a:	e8 d9 ee ff ff       	call   800338 <_panic>
	...

00801460 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	05 00 00 00 30       	add    $0x30000000,%eax
  80146b:	c1 e8 0c             	shr    $0xc,%eax
}
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 df ff ff ff       	call   801460 <fd2num>
  801481:	05 20 00 0d 00       	add    $0xd0020,%eax
  801486:	c1 e0 0c             	shl    $0xc,%eax
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801492:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801497:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 16             	shr    $0x16,%edx
  80149e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a5:	f6 c2 01             	test   $0x1,%dl
  8014a8:	74 11                	je     8014bb <fd_alloc+0x30>
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 0c             	shr    $0xc,%edx
  8014af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	75 09                	jne    8014c4 <fd_alloc+0x39>
			*fd_store = fd;
  8014bb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	eb 17                	jmp    8014db <fd_alloc+0x50>
  8014c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ce:	75 c7                	jne    801497 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014db:	5b                   	pop    %ebx
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e4:	83 f8 1f             	cmp    $0x1f,%eax
  8014e7:	77 36                	ja     80151f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014ee:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	c1 ea 16             	shr    $0x16,%edx
  8014f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fd:	f6 c2 01             	test   $0x1,%dl
  801500:	74 24                	je     801526 <fd_lookup+0x48>
  801502:	89 c2                	mov    %eax,%edx
  801504:	c1 ea 0c             	shr    $0xc,%edx
  801507:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150e:	f6 c2 01             	test   $0x1,%dl
  801511:	74 1a                	je     80152d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801513:	8b 55 0c             	mov    0xc(%ebp),%edx
  801516:	89 02                	mov    %eax,(%edx)
	return 0;
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	eb 13                	jmp    801532 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801524:	eb 0c                	jmp    801532 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb 05                	jmp    801532 <fd_lookup+0x54>
  80152d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	eb 0e                	jmp    801556 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801548:	39 08                	cmp    %ecx,(%eax)
  80154a:	75 09                	jne    801555 <dev_lookup+0x21>
			*dev = devtab[i];
  80154c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80154e:	b8 00 00 00 00       	mov    $0x0,%eax
  801553:	eb 33                	jmp    801588 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801555:	42                   	inc    %edx
  801556:	8b 04 95 e8 2b 80 00 	mov    0x802be8(,%edx,4),%eax
  80155d:	85 c0                	test   %eax,%eax
  80155f:	75 e7                	jne    801548 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801561:	a1 04 40 80 00       	mov    0x804004,%eax
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80156d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801571:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  801578:	e8 b3 ee ff ff       	call   800430 <cprintf>
	*dev = 0;
  80157d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801583:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801588:	83 c4 14             	add    $0x14,%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 30             	sub    $0x30,%esp
  801596:	8b 75 08             	mov    0x8(%ebp),%esi
  801599:	8a 45 0c             	mov    0xc(%ebp),%al
  80159c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80159f:	89 34 24             	mov    %esi,(%esp)
  8015a2:	e8 b9 fe ff ff       	call   801460 <fd2num>
  8015a7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015ae:	89 04 24             	mov    %eax,(%esp)
  8015b1:	e8 28 ff ff ff       	call   8014de <fd_lookup>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 05                	js     8015c1 <fd_close+0x33>
	    || fd != fd2)
  8015bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015bf:	74 0d                	je     8015ce <fd_close+0x40>
		return (must_exist ? r : 0);
  8015c1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015c5:	75 46                	jne    80160d <fd_close+0x7f>
  8015c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015cc:	eb 3f                	jmp    80160d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d5:	8b 06                	mov    (%esi),%eax
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	e8 55 ff ff ff       	call   801534 <dev_lookup>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 18                	js     8015fd <fd_close+0x6f>
		if (dev->dev_close)
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	8b 40 10             	mov    0x10(%eax),%eax
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 09                	je     8015f8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ef:	89 34 24             	mov    %esi,(%esp)
  8015f2:	ff d0                	call   *%eax
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	eb 05                	jmp    8015fd <fd_close+0x6f>
		else
			r = 0;
  8015f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801608:	e8 87 f8 ff ff       	call   800e94 <sys_page_unmap>
	return r;
}
  80160d:	89 d8                	mov    %ebx,%eax
  80160f:	83 c4 30             	add    $0x30,%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 b0 fe ff ff       	call   8014de <fd_lookup>
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 13                	js     801645 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801632:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801639:	00 
  80163a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 49 ff ff ff       	call   80158e <fd_close>
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <close_all>:

void
close_all(void)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80164e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 bb ff ff ff       	call   801616 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80165b:	43                   	inc    %ebx
  80165c:	83 fb 20             	cmp    $0x20,%ebx
  80165f:	75 f2                	jne    801653 <close_all+0xc>
		close(i);
}
  801661:	83 c4 14             	add    $0x14,%esp
  801664:	5b                   	pop    %ebx
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	57                   	push   %edi
  80166b:	56                   	push   %esi
  80166c:	53                   	push   %ebx
  80166d:	83 ec 4c             	sub    $0x4c,%esp
  801670:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801673:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 59 fe ff ff       	call   8014de <fd_lookup>
  801685:	89 c3                	mov    %eax,%ebx
  801687:	85 c0                	test   %eax,%eax
  801689:	0f 88 e1 00 00 00    	js     801770 <dup+0x109>
		return r;
	close(newfdnum);
  80168f:	89 3c 24             	mov    %edi,(%esp)
  801692:	e8 7f ff ff ff       	call   801616 <close>

	newfd = INDEX2FD(newfdnum);
  801697:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80169d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 c5 fd ff ff       	call   801470 <fd2data>
  8016ab:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016ad:	89 34 24             	mov    %esi,(%esp)
  8016b0:	e8 bb fd ff ff       	call   801470 <fd2data>
  8016b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b8:	89 d8                	mov    %ebx,%eax
  8016ba:	c1 e8 16             	shr    $0x16,%eax
  8016bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c4:	a8 01                	test   $0x1,%al
  8016c6:	74 46                	je     80170e <dup+0xa7>
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	c1 e8 0c             	shr    $0xc,%eax
  8016cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d4:	f6 c2 01             	test   $0x1,%dl
  8016d7:	74 35                	je     80170e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016f7:	00 
  8016f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801703:	e8 39 f7 ff ff       	call   800e41 <sys_page_map>
  801708:	89 c3                	mov    %eax,%ebx
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 3b                	js     801749 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801711:	89 c2                	mov    %eax,%edx
  801713:	c1 ea 0c             	shr    $0xc,%edx
  801716:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80171d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801723:	89 54 24 10          	mov    %edx,0x10(%esp)
  801727:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80172b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801732:	00 
  801733:	89 44 24 04          	mov    %eax,0x4(%esp)
  801737:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173e:	e8 fe f6 ff ff       	call   800e41 <sys_page_map>
  801743:	89 c3                	mov    %eax,%ebx
  801745:	85 c0                	test   %eax,%eax
  801747:	79 25                	jns    80176e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801749:	89 74 24 04          	mov    %esi,0x4(%esp)
  80174d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801754:	e8 3b f7 ff ff       	call   800e94 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80175c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801767:	e8 28 f7 ff ff       	call   800e94 <sys_page_unmap>
	return r;
  80176c:	eb 02                	jmp    801770 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80176e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	83 c4 4c             	add    $0x4c,%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	53                   	push   %ebx
  80177e:	83 ec 24             	sub    $0x24,%esp
  801781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801784:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 4b fd ff ff       	call   8014de <fd_lookup>
  801793:	85 c0                	test   %eax,%eax
  801795:	78 6d                	js     801804 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	8b 00                	mov    (%eax),%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 89 fd ff ff       	call   801534 <dev_lookup>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 55                	js     801804 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b2:	8b 50 08             	mov    0x8(%eax),%edx
  8017b5:	83 e2 03             	and    $0x3,%edx
  8017b8:	83 fa 01             	cmp    $0x1,%edx
  8017bb:	75 23                	jne    8017e0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c2:	8b 40 48             	mov    0x48(%eax),%eax
  8017c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	c7 04 24 ad 2b 80 00 	movl   $0x802bad,(%esp)
  8017d4:	e8 57 ec ff ff       	call   800430 <cprintf>
		return -E_INVAL;
  8017d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017de:	eb 24                	jmp    801804 <read+0x8a>
	}
	if (!dev->dev_read)
  8017e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e3:	8b 52 08             	mov    0x8(%edx),%edx
  8017e6:	85 d2                	test   %edx,%edx
  8017e8:	74 15                	je     8017ff <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017f8:	89 04 24             	mov    %eax,(%esp)
  8017fb:	ff d2                	call   *%edx
  8017fd:	eb 05                	jmp    801804 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801804:	83 c4 24             	add    $0x24,%esp
  801807:	5b                   	pop    %ebx
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	57                   	push   %edi
  80180e:	56                   	push   %esi
  80180f:	53                   	push   %ebx
  801810:	83 ec 1c             	sub    $0x1c,%esp
  801813:	8b 7d 08             	mov    0x8(%ebp),%edi
  801816:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801819:	bb 00 00 00 00       	mov    $0x0,%ebx
  80181e:	eb 23                	jmp    801843 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801820:	89 f0                	mov    %esi,%eax
  801822:	29 d8                	sub    %ebx,%eax
  801824:	89 44 24 08          	mov    %eax,0x8(%esp)
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	01 d8                	add    %ebx,%eax
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	89 3c 24             	mov    %edi,(%esp)
  801834:	e8 41 ff ff ff       	call   80177a <read>
		if (m < 0)
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 10                	js     80184d <readn+0x43>
			return m;
		if (m == 0)
  80183d:	85 c0                	test   %eax,%eax
  80183f:	74 0a                	je     80184b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801841:	01 c3                	add    %eax,%ebx
  801843:	39 f3                	cmp    %esi,%ebx
  801845:	72 d9                	jb     801820 <readn+0x16>
  801847:	89 d8                	mov    %ebx,%eax
  801849:	eb 02                	jmp    80184d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80184b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80184d:	83 c4 1c             	add    $0x1c,%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5f                   	pop    %edi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	83 ec 24             	sub    $0x24,%esp
  80185c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 70 fc ff ff       	call   8014de <fd_lookup>
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 68                	js     8018da <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	8b 00                	mov    (%eax),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 ae fc ff ff       	call   801534 <dev_lookup>
  801886:	85 c0                	test   %eax,%eax
  801888:	78 50                	js     8018da <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801891:	75 23                	jne    8018b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801893:	a1 04 40 80 00       	mov    0x804004,%eax
  801898:	8b 40 48             	mov    0x48(%eax),%eax
  80189b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	c7 04 24 c9 2b 80 00 	movl   $0x802bc9,(%esp)
  8018aa:	e8 81 eb ff ff       	call   800430 <cprintf>
		return -E_INVAL;
  8018af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b4:	eb 24                	jmp    8018da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018bc:	85 d2                	test   %edx,%edx
  8018be:	74 15                	je     8018d5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ce:	89 04 24             	mov    %eax,(%esp)
  8018d1:	ff d2                	call   *%edx
  8018d3:	eb 05                	jmp    8018da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018da:	83 c4 24             	add    $0x24,%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f0:	89 04 24             	mov    %eax,(%esp)
  8018f3:	e8 e6 fb ff ff       	call   8014de <fd_lookup>
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 0e                	js     80190a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	53                   	push   %ebx
  801910:	83 ec 24             	sub    $0x24,%esp
  801913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801916:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191d:	89 1c 24             	mov    %ebx,(%esp)
  801920:	e8 b9 fb ff ff       	call   8014de <fd_lookup>
  801925:	85 c0                	test   %eax,%eax
  801927:	78 61                	js     80198a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801930:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801933:	8b 00                	mov    (%eax),%eax
  801935:	89 04 24             	mov    %eax,(%esp)
  801938:	e8 f7 fb ff ff       	call   801534 <dev_lookup>
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 49                	js     80198a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801944:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801948:	75 23                	jne    80196d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80194a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80194f:	8b 40 48             	mov    0x48(%eax),%eax
  801952:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195a:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  801961:	e8 ca ea ff ff       	call   800430 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80196b:	eb 1d                	jmp    80198a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80196d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801970:	8b 52 18             	mov    0x18(%edx),%edx
  801973:	85 d2                	test   %edx,%edx
  801975:	74 0e                	je     801985 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	ff d2                	call   *%edx
  801983:	eb 05                	jmp    80198a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801985:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80198a:	83 c4 24             	add    $0x24,%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 24             	sub    $0x24,%esp
  801997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	89 04 24             	mov    %eax,(%esp)
  8019a7:	e8 32 fb ff ff       	call   8014de <fd_lookup>
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 52                	js     801a02 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ba:	8b 00                	mov    (%eax),%eax
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 70 fb ff ff       	call   801534 <dev_lookup>
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 3a                	js     801a02 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019cf:	74 2c                	je     8019fd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019db:	00 00 00 
	stat->st_isdir = 0;
  8019de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e5:	00 00 00 
	stat->st_dev = dev;
  8019e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019f5:	89 14 24             	mov    %edx,(%esp)
  8019f8:	ff 50 14             	call   *0x14(%eax)
  8019fb:	eb 05                	jmp    801a02 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a02:	83 c4 24             	add    $0x24,%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a17:	00 
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	89 04 24             	mov    %eax,(%esp)
  801a1e:	e8 fe 01 00 00       	call   801c21 <open>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 1b                	js     801a44 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 58 ff ff ff       	call   801990 <fstat>
  801a38:	89 c6                	mov    %eax,%esi
	close(fd);
  801a3a:	89 1c 24             	mov    %ebx,(%esp)
  801a3d:	e8 d4 fb ff ff       	call   801616 <close>
	return r;
  801a42:	89 f3                	mov    %esi,%ebx
}
  801a44:	89 d8                	mov    %ebx,%eax
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5e                   	pop    %esi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    
  801a4d:	00 00                	add    %al,(%eax)
	...

00801a50 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	83 ec 10             	sub    $0x10,%esp
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a5c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a63:	75 11                	jne    801a76 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a6c:	e8 fc 08 00 00       	call   80236d <ipc_find_env>
  801a71:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a7d:	00 
  801a7e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a85:	00 
  801a86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a8a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 6c 08 00 00       	call   802303 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a9e:	00 
  801a9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aaa:	e8 ed 07 00 00       	call   80229c <ipc_recv>
}
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad9:	e8 72 ff ff ff       	call   801a50 <fsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	8b 40 0c             	mov    0xc(%eax),%eax
  801aec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801af1:	ba 00 00 00 00       	mov    $0x0,%edx
  801af6:	b8 06 00 00 00       	mov    $0x6,%eax
  801afb:	e8 50 ff ff ff       	call   801a50 <fsipc>
}
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	53                   	push   %ebx
  801b06:	83 ec 14             	sub    $0x14,%esp
  801b09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b12:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b17:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b21:	e8 2a ff ff ff       	call   801a50 <fsipc>
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 2b                	js     801b55 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b2a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b31:	00 
  801b32:	89 1c 24             	mov    %ebx,(%esp)
  801b35:	e8 c1 ee ff ff       	call   8009fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b3a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b45:	a1 84 50 80 00       	mov    0x805084,%eax
  801b4a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b55:	83 c4 14             	add    $0x14,%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b61:	c7 44 24 08 f8 2b 80 	movl   $0x802bf8,0x8(%esp)
  801b68:	00 
  801b69:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b70:	00 
  801b71:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801b78:	e8 bb e7 ff ff       	call   800338 <_panic>

00801b7d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 10             	sub    $0x10,%esp
  801b85:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b88:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b99:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba3:	e8 a8 fe ff ff       	call   801a50 <fsipc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 6a                	js     801c18 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bae:	39 c6                	cmp    %eax,%esi
  801bb0:	73 24                	jae    801bd6 <devfile_read+0x59>
  801bb2:	c7 44 24 0c 21 2c 80 	movl   $0x802c21,0xc(%esp)
  801bb9:	00 
  801bba:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  801bc1:	00 
  801bc2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801bc9:	00 
  801bca:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801bd1:	e8 62 e7 ff ff       	call   800338 <_panic>
	assert(r <= PGSIZE);
  801bd6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bdb:	7e 24                	jle    801c01 <devfile_read+0x84>
  801bdd:	c7 44 24 0c 3d 2c 80 	movl   $0x802c3d,0xc(%esp)
  801be4:	00 
  801be5:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  801bec:	00 
  801bed:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bf4:	00 
  801bf5:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801bfc:	e8 37 e7 ff ff       	call   800338 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c05:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c0c:	00 
  801c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c10:	89 04 24             	mov    %eax,(%esp)
  801c13:	e8 5c ef ff ff       	call   800b74 <memmove>
	return r;
}
  801c18:	89 d8                	mov    %ebx,%eax
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 20             	sub    $0x20,%esp
  801c29:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c2c:	89 34 24             	mov    %esi,(%esp)
  801c2f:	e8 94 ed ff ff       	call   8009c8 <strlen>
  801c34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c39:	7f 60                	jg     801c9b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 45 f8 ff ff       	call   80148b <fd_alloc>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 54                	js     801ca0 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c50:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c57:	e8 9f ed ff ff       	call   8009fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c67:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6c:	e8 df fd ff ff       	call   801a50 <fsipc>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	85 c0                	test   %eax,%eax
  801c75:	79 15                	jns    801c8c <open+0x6b>
		fd_close(fd, 0);
  801c77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c7e:	00 
  801c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c82:	89 04 24             	mov    %eax,(%esp)
  801c85:	e8 04 f9 ff ff       	call   80158e <fd_close>
		return r;
  801c8a:	eb 14                	jmp    801ca0 <open+0x7f>
	}

	return fd2num(fd);
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	89 04 24             	mov    %eax,(%esp)
  801c92:	e8 c9 f7 ff ff       	call   801460 <fd2num>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	eb 05                	jmp    801ca0 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c9b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	83 c4 20             	add    $0x20,%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801caf:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb4:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb9:	e8 92 fd ff ff       	call   801a50 <fsipc>
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 10             	sub    $0x10,%esp
  801cc8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	89 04 24             	mov    %eax,(%esp)
  801cd1:	e8 9a f7 ff ff       	call   801470 <fd2data>
  801cd6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801cd8:	c7 44 24 04 49 2c 80 	movl   $0x802c49,0x4(%esp)
  801cdf:	00 
  801ce0:	89 34 24             	mov    %esi,(%esp)
  801ce3:	e8 13 ed ff ff       	call   8009fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ce8:	8b 43 04             	mov    0x4(%ebx),%eax
  801ceb:	2b 03                	sub    (%ebx),%eax
  801ced:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801cf3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cfa:	00 00 00 
	stat->st_dev = &devpipe;
  801cfd:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801d04:	30 80 00 
	return 0;
}
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 14             	sub    $0x14,%esp
  801d1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d28:	e8 67 f1 ff ff       	call   800e94 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d2d:	89 1c 24             	mov    %ebx,(%esp)
  801d30:	e8 3b f7 ff ff       	call   801470 <fd2data>
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d40:	e8 4f f1 ff ff       	call   800e94 <sys_page_unmap>
}
  801d45:	83 c4 14             	add    $0x14,%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	57                   	push   %edi
  801d4f:	56                   	push   %esi
  801d50:	53                   	push   %ebx
  801d51:	83 ec 2c             	sub    $0x2c,%esp
  801d54:	89 c7                	mov    %eax,%edi
  801d56:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d59:	a1 04 40 80 00       	mov    0x804004,%eax
  801d5e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d61:	89 3c 24             	mov    %edi,(%esp)
  801d64:	e8 4b 06 00 00       	call   8023b4 <pageref>
  801d69:	89 c6                	mov    %eax,%esi
  801d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 3e 06 00 00       	call   8023b4 <pageref>
  801d76:	39 c6                	cmp    %eax,%esi
  801d78:	0f 94 c0             	sete   %al
  801d7b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d7e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d84:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d87:	39 cb                	cmp    %ecx,%ebx
  801d89:	75 08                	jne    801d93 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d8b:	83 c4 2c             	add    $0x2c,%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d93:	83 f8 01             	cmp    $0x1,%eax
  801d96:	75 c1                	jne    801d59 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d98:	8b 42 58             	mov    0x58(%edx),%eax
  801d9b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801da2:	00 
  801da3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dab:	c7 04 24 50 2c 80 00 	movl   $0x802c50,(%esp)
  801db2:	e8 79 e6 ff ff       	call   800430 <cprintf>
  801db7:	eb a0                	jmp    801d59 <_pipeisclosed+0xe>

00801db9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	57                   	push   %edi
  801dbd:	56                   	push   %esi
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 1c             	sub    $0x1c,%esp
  801dc2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dc5:	89 34 24             	mov    %esi,(%esp)
  801dc8:	e8 a3 f6 ff ff       	call   801470 <fd2data>
  801dcd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dcf:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd4:	eb 3c                	jmp    801e12 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dd6:	89 da                	mov    %ebx,%edx
  801dd8:	89 f0                	mov    %esi,%eax
  801dda:	e8 6c ff ff ff       	call   801d4b <_pipeisclosed>
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	75 38                	jne    801e1b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801de3:	e8 e6 ef ff ff       	call   800dce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801de8:	8b 43 04             	mov    0x4(%ebx),%eax
  801deb:	8b 13                	mov    (%ebx),%edx
  801ded:	83 c2 20             	add    $0x20,%edx
  801df0:	39 d0                	cmp    %edx,%eax
  801df2:	73 e2                	jae    801dd6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801df4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801dfa:	89 c2                	mov    %eax,%edx
  801dfc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e02:	79 05                	jns    801e09 <devpipe_write+0x50>
  801e04:	4a                   	dec    %edx
  801e05:	83 ca e0             	or     $0xffffffe0,%edx
  801e08:	42                   	inc    %edx
  801e09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e0d:	40                   	inc    %eax
  801e0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e11:	47                   	inc    %edi
  801e12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e15:	75 d1                	jne    801de8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e17:	89 f8                	mov    %edi,%eax
  801e19:	eb 05                	jmp    801e20 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e1b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e20:	83 c4 1c             	add    $0x1c,%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    

00801e28 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	57                   	push   %edi
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 1c             	sub    $0x1c,%esp
  801e31:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e34:	89 3c 24             	mov    %edi,(%esp)
  801e37:	e8 34 f6 ff ff       	call   801470 <fd2data>
  801e3c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3e:	be 00 00 00 00       	mov    $0x0,%esi
  801e43:	eb 3a                	jmp    801e7f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e45:	85 f6                	test   %esi,%esi
  801e47:	74 04                	je     801e4d <devpipe_read+0x25>
				return i;
  801e49:	89 f0                	mov    %esi,%eax
  801e4b:	eb 40                	jmp    801e8d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e4d:	89 da                	mov    %ebx,%edx
  801e4f:	89 f8                	mov    %edi,%eax
  801e51:	e8 f5 fe ff ff       	call   801d4b <_pipeisclosed>
  801e56:	85 c0                	test   %eax,%eax
  801e58:	75 2e                	jne    801e88 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e5a:	e8 6f ef ff ff       	call   800dce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e5f:	8b 03                	mov    (%ebx),%eax
  801e61:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e64:	74 df                	je     801e45 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e66:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e6b:	79 05                	jns    801e72 <devpipe_read+0x4a>
  801e6d:	48                   	dec    %eax
  801e6e:	83 c8 e0             	or     $0xffffffe0,%eax
  801e71:	40                   	inc    %eax
  801e72:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e79:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e7c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7e:	46                   	inc    %esi
  801e7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e82:	75 db                	jne    801e5f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e84:	89 f0                	mov    %esi,%eax
  801e86:	eb 05                	jmp    801e8d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e8d:	83 c4 1c             	add    $0x1c,%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	57                   	push   %edi
  801e99:	56                   	push   %esi
  801e9a:	53                   	push   %ebx
  801e9b:	83 ec 3c             	sub    $0x3c,%esp
  801e9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ea1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ea4:	89 04 24             	mov    %eax,(%esp)
  801ea7:	e8 df f5 ff ff       	call   80148b <fd_alloc>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	0f 88 45 01 00 00    	js     801ffb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ebd:	00 
  801ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecc:	e8 1c ef ff ff       	call   800ded <sys_page_alloc>
  801ed1:	89 c3                	mov    %eax,%ebx
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	0f 88 20 01 00 00    	js     801ffb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801edb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ede:	89 04 24             	mov    %eax,(%esp)
  801ee1:	e8 a5 f5 ff ff       	call   80148b <fd_alloc>
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	0f 88 f8 00 00 00    	js     801fe8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef7:	00 
  801ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801efb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f06:	e8 e2 ee ff ff       	call   800ded <sys_page_alloc>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	0f 88 d3 00 00 00    	js     801fe8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f18:	89 04 24             	mov    %eax,(%esp)
  801f1b:	e8 50 f5 ff ff       	call   801470 <fd2data>
  801f20:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f29:	00 
  801f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f35:	e8 b3 ee ff ff       	call   800ded <sys_page_alloc>
  801f3a:	89 c3                	mov    %eax,%ebx
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	0f 88 91 00 00 00    	js     801fd5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f47:	89 04 24             	mov    %eax,(%esp)
  801f4a:	e8 21 f5 ff ff       	call   801470 <fd2data>
  801f4f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f56:	00 
  801f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f62:	00 
  801f63:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6e:	e8 ce ee ff ff       	call   800e41 <sys_page_map>
  801f73:	89 c3                	mov    %eax,%ebx
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 4c                	js     801fc5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f79:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f82:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f87:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f8e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f97:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f99:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f9c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa6:	89 04 24             	mov    %eax,(%esp)
  801fa9:	e8 b2 f4 ff ff       	call   801460 <fd2num>
  801fae:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801fb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fb3:	89 04 24             	mov    %eax,(%esp)
  801fb6:	e8 a5 f4 ff ff       	call   801460 <fd2num>
  801fbb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801fbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc3:	eb 36                	jmp    801ffb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801fc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd0:	e8 bf ee ff ff       	call   800e94 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe3:	e8 ac ee ff ff       	call   800e94 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fe8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801feb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff6:	e8 99 ee ff ff       	call   800e94 <sys_page_unmap>
    err:
	return r;
}
  801ffb:	89 d8                	mov    %ebx,%eax
  801ffd:	83 c4 3c             	add    $0x3c,%esp
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802012:	8b 45 08             	mov    0x8(%ebp),%eax
  802015:	89 04 24             	mov    %eax,(%esp)
  802018:	e8 c1 f4 ff ff       	call   8014de <fd_lookup>
  80201d:	85 c0                	test   %eax,%eax
  80201f:	78 15                	js     802036 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802024:	89 04 24             	mov    %eax,(%esp)
  802027:	e8 44 f4 ff ff       	call   801470 <fd2data>
	return _pipeisclosed(fd, p);
  80202c:	89 c2                	mov    %eax,%edx
  80202e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802031:	e8 15 fd ff ff       	call   801d4b <_pipeisclosed>
}
  802036:	c9                   	leave  
  802037:	c3                   	ret    

00802038 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    

00802042 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802048:	c7 44 24 04 63 2c 80 	movl   $0x802c63,0x4(%esp)
  80204f:	00 
  802050:	8b 45 0c             	mov    0xc(%ebp),%eax
  802053:	89 04 24             	mov    %eax,(%esp)
  802056:	e8 a0 e9 ff ff       	call   8009fb <strcpy>
	return 0;
}
  80205b:	b8 00 00 00 00       	mov    $0x0,%eax
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	57                   	push   %edi
  802066:	56                   	push   %esi
  802067:	53                   	push   %ebx
  802068:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80206e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802073:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802079:	eb 30                	jmp    8020ab <devcons_write+0x49>
		m = n - tot;
  80207b:	8b 75 10             	mov    0x10(%ebp),%esi
  80207e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802080:	83 fe 7f             	cmp    $0x7f,%esi
  802083:	76 05                	jbe    80208a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802085:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80208a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80208e:	03 45 0c             	add    0xc(%ebp),%eax
  802091:	89 44 24 04          	mov    %eax,0x4(%esp)
  802095:	89 3c 24             	mov    %edi,(%esp)
  802098:	e8 d7 ea ff ff       	call   800b74 <memmove>
		sys_cputs(buf, m);
  80209d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020a1:	89 3c 24             	mov    %edi,(%esp)
  8020a4:	e8 77 ec ff ff       	call   800d20 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a9:	01 f3                	add    %esi,%ebx
  8020ab:	89 d8                	mov    %ebx,%eax
  8020ad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020b0:	72 c9                	jb     80207b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020b2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    

008020bd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8020c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c7:	75 07                	jne    8020d0 <devcons_read+0x13>
  8020c9:	eb 25                	jmp    8020f0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020cb:	e8 fe ec ff ff       	call   800dce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020d0:	e8 69 ec ff ff       	call   800d3e <sys_cgetc>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	74 f2                	je     8020cb <devcons_read+0xe>
  8020d9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 1d                	js     8020fc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020df:	83 f8 04             	cmp    $0x4,%eax
  8020e2:	74 13                	je     8020f7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e7:	88 10                	mov    %dl,(%eax)
	return 1;
  8020e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ee:	eb 0c                	jmp    8020fc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f5:	eb 05                	jmp    8020fc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80210a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802111:	00 
  802112:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802115:	89 04 24             	mov    %eax,(%esp)
  802118:	e8 03 ec ff ff       	call   800d20 <sys_cputs>
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <getchar>:

int
getchar(void)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802125:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80212c:	00 
  80212d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802130:	89 44 24 04          	mov    %eax,0x4(%esp)
  802134:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213b:	e8 3a f6 ff ff       	call   80177a <read>
	if (r < 0)
  802140:	85 c0                	test   %eax,%eax
  802142:	78 0f                	js     802153 <getchar+0x34>
		return r;
	if (r < 1)
  802144:	85 c0                	test   %eax,%eax
  802146:	7e 06                	jle    80214e <getchar+0x2f>
		return -E_EOF;
	return c;
  802148:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80214c:	eb 05                	jmp    802153 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80214e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802153:	c9                   	leave  
  802154:	c3                   	ret    

00802155 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80215b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802162:	8b 45 08             	mov    0x8(%ebp),%eax
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 71 f3 ff ff       	call   8014de <fd_lookup>
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 11                	js     802182 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802174:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80217a:	39 10                	cmp    %edx,(%eax)
  80217c:	0f 94 c0             	sete   %al
  80217f:	0f b6 c0             	movzbl %al,%eax
}
  802182:	c9                   	leave  
  802183:	c3                   	ret    

00802184 <opencons>:

int
opencons(void)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80218a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218d:	89 04 24             	mov    %eax,(%esp)
  802190:	e8 f6 f2 ff ff       	call   80148b <fd_alloc>
  802195:	85 c0                	test   %eax,%eax
  802197:	78 3c                	js     8021d5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802199:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021a0:	00 
  8021a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021af:	e8 39 ec ff ff       	call   800ded <sys_page_alloc>
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	78 1d                	js     8021d5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021cd:	89 04 24             	mov    %eax,(%esp)
  8021d0:	e8 8b f2 ff ff       	call   801460 <fd2num>
}
  8021d5:	c9                   	leave  
  8021d6:	c3                   	ret    
	...

008021d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021de:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021e5:	0f 85 80 00 00 00    	jne    80226b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8021eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8021f0:	8b 40 48             	mov    0x48(%eax),%eax
  8021f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021fa:	00 
  8021fb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802202:	ee 
  802203:	89 04 24             	mov    %eax,(%esp)
  802206:	e8 e2 eb ff ff       	call   800ded <sys_page_alloc>
  80220b:	85 c0                	test   %eax,%eax
  80220d:	79 20                	jns    80222f <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80220f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802213:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  80221a:	00 
  80221b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802222:	00 
  802223:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  80222a:	e8 09 e1 ff ff       	call   800338 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80222f:	a1 04 40 80 00       	mov    0x804004,%eax
  802234:	8b 40 48             	mov    0x48(%eax),%eax
  802237:	c7 44 24 04 78 22 80 	movl   $0x802278,0x4(%esp)
  80223e:	00 
  80223f:	89 04 24             	mov    %eax,(%esp)
  802242:	e8 46 ed ff ff       	call   800f8d <sys_env_set_pgfault_upcall>
  802247:	85 c0                	test   %eax,%eax
  802249:	79 20                	jns    80226b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80224b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224f:	c7 44 24 08 9c 2c 80 	movl   $0x802c9c,0x8(%esp)
  802256:	00 
  802257:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80225e:	00 
  80225f:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  802266:	e8 cd e0 ff ff       	call   800338 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802273:	c9                   	leave  
  802274:	c3                   	ret    
  802275:	00 00                	add    %al,(%eax)
	...

00802278 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802278:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802279:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80227e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802280:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802283:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  802287:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802289:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  80228c:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  80228d:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802290:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  802292:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802295:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  802296:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802299:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80229a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80229b:	c3                   	ret    

0080229c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	83 ec 10             	sub    $0x10,%esp
  8022a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8022a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8022ad:	85 c0                	test   %eax,%eax
  8022af:	75 05                	jne    8022b6 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8022b1:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8022b6:	89 04 24             	mov    %eax,(%esp)
  8022b9:	e8 45 ed ff ff       	call   801003 <sys_ipc_recv>
	if (!err) {
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	75 26                	jne    8022e8 <ipc_recv+0x4c>
		if (from_env_store) {
  8022c2:	85 f6                	test   %esi,%esi
  8022c4:	74 0a                	je     8022d0 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8022c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8022cb:	8b 40 74             	mov    0x74(%eax),%eax
  8022ce:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8022d0:	85 db                	test   %ebx,%ebx
  8022d2:	74 0a                	je     8022de <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8022d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8022d9:	8b 40 78             	mov    0x78(%eax),%eax
  8022dc:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8022de:	a1 04 40 80 00       	mov    0x804004,%eax
  8022e3:	8b 40 70             	mov    0x70(%eax),%eax
  8022e6:	eb 14                	jmp    8022fc <ipc_recv+0x60>
	}
	if (from_env_store) {
  8022e8:	85 f6                	test   %esi,%esi
  8022ea:	74 06                	je     8022f2 <ipc_recv+0x56>
		*from_env_store = 0;
  8022ec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8022f2:	85 db                	test   %ebx,%ebx
  8022f4:	74 06                	je     8022fc <ipc_recv+0x60>
		*perm_store = 0;
  8022f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    

00802303 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802303:	55                   	push   %ebp
  802304:	89 e5                	mov    %esp,%ebp
  802306:	57                   	push   %edi
  802307:	56                   	push   %esi
  802308:	53                   	push   %ebx
  802309:	83 ec 1c             	sub    $0x1c,%esp
  80230c:	8b 75 10             	mov    0x10(%ebp),%esi
  80230f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802312:	85 f6                	test   %esi,%esi
  802314:	75 05                	jne    80231b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802316:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80231b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80231f:	89 74 24 08          	mov    %esi,0x8(%esp)
  802323:	8b 45 0c             	mov    0xc(%ebp),%eax
  802326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232a:	8b 45 08             	mov    0x8(%ebp),%eax
  80232d:	89 04 24             	mov    %eax,(%esp)
  802330:	e8 ab ec ff ff       	call   800fe0 <sys_ipc_try_send>
  802335:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802337:	e8 92 ea ff ff       	call   800dce <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  80233c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80233f:	74 da                	je     80231b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802341:	85 db                	test   %ebx,%ebx
  802343:	74 20                	je     802365 <ipc_send+0x62>
		panic("send fail: %e", err);
  802345:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802349:	c7 44 24 08 da 2c 80 	movl   $0x802cda,0x8(%esp)
  802350:	00 
  802351:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802358:	00 
  802359:	c7 04 24 e8 2c 80 00 	movl   $0x802ce8,(%esp)
  802360:	e8 d3 df ff ff       	call   800338 <_panic>
	}
	return;
}
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    

0080236d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80236d:	55                   	push   %ebp
  80236e:	89 e5                	mov    %esp,%ebp
  802370:	53                   	push   %ebx
  802371:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802374:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802379:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802380:	89 c2                	mov    %eax,%edx
  802382:	c1 e2 07             	shl    $0x7,%edx
  802385:	29 ca                	sub    %ecx,%edx
  802387:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80238d:	8b 52 50             	mov    0x50(%edx),%edx
  802390:	39 da                	cmp    %ebx,%edx
  802392:	75 0f                	jne    8023a3 <ipc_find_env+0x36>
			return envs[i].env_id;
  802394:	c1 e0 07             	shl    $0x7,%eax
  802397:	29 c8                	sub    %ecx,%eax
  802399:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80239e:	8b 40 40             	mov    0x40(%eax),%eax
  8023a1:	eb 0c                	jmp    8023af <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023a3:	40                   	inc    %eax
  8023a4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023a9:	75 ce                	jne    802379 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ab:	66 b8 00 00          	mov    $0x0,%ax
}
  8023af:	5b                   	pop    %ebx
  8023b0:	5d                   	pop    %ebp
  8023b1:	c3                   	ret    
	...

008023b4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023ba:	89 c2                	mov    %eax,%edx
  8023bc:	c1 ea 16             	shr    $0x16,%edx
  8023bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023c6:	f6 c2 01             	test   $0x1,%dl
  8023c9:	74 1e                	je     8023e9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023cb:	c1 e8 0c             	shr    $0xc,%eax
  8023ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023d5:	a8 01                	test   $0x1,%al
  8023d7:	74 17                	je     8023f0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023d9:	c1 e8 0c             	shr    $0xc,%eax
  8023dc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023e3:	ef 
  8023e4:	0f b7 c0             	movzwl %ax,%eax
  8023e7:	eb 0c                	jmp    8023f5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ee:	eb 05                	jmp    8023f5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023f0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023f5:	5d                   	pop    %ebp
  8023f6:	c3                   	ret    
	...

008023f8 <__udivdi3>:
  8023f8:	55                   	push   %ebp
  8023f9:	57                   	push   %edi
  8023fa:	56                   	push   %esi
  8023fb:	83 ec 10             	sub    $0x10,%esp
  8023fe:	8b 74 24 20          	mov    0x20(%esp),%esi
  802402:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802406:	89 74 24 04          	mov    %esi,0x4(%esp)
  80240a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80240e:	89 cd                	mov    %ecx,%ebp
  802410:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802414:	85 c0                	test   %eax,%eax
  802416:	75 2c                	jne    802444 <__udivdi3+0x4c>
  802418:	39 f9                	cmp    %edi,%ecx
  80241a:	77 68                	ja     802484 <__udivdi3+0x8c>
  80241c:	85 c9                	test   %ecx,%ecx
  80241e:	75 0b                	jne    80242b <__udivdi3+0x33>
  802420:	b8 01 00 00 00       	mov    $0x1,%eax
  802425:	31 d2                	xor    %edx,%edx
  802427:	f7 f1                	div    %ecx
  802429:	89 c1                	mov    %eax,%ecx
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	89 f8                	mov    %edi,%eax
  80242f:	f7 f1                	div    %ecx
  802431:	89 c7                	mov    %eax,%edi
  802433:	89 f0                	mov    %esi,%eax
  802435:	f7 f1                	div    %ecx
  802437:	89 c6                	mov    %eax,%esi
  802439:	89 f0                	mov    %esi,%eax
  80243b:	89 fa                	mov    %edi,%edx
  80243d:	83 c4 10             	add    $0x10,%esp
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	39 f8                	cmp    %edi,%eax
  802446:	77 2c                	ja     802474 <__udivdi3+0x7c>
  802448:	0f bd f0             	bsr    %eax,%esi
  80244b:	83 f6 1f             	xor    $0x1f,%esi
  80244e:	75 4c                	jne    80249c <__udivdi3+0xa4>
  802450:	39 f8                	cmp    %edi,%eax
  802452:	bf 00 00 00 00       	mov    $0x0,%edi
  802457:	72 0a                	jb     802463 <__udivdi3+0x6b>
  802459:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80245d:	0f 87 ad 00 00 00    	ja     802510 <__udivdi3+0x118>
  802463:	be 01 00 00 00       	mov    $0x1,%esi
  802468:	89 f0                	mov    %esi,%eax
  80246a:	89 fa                	mov    %edi,%edx
  80246c:	83 c4 10             	add    $0x10,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
  802474:	31 ff                	xor    %edi,%edi
  802476:	31 f6                	xor    %esi,%esi
  802478:	89 f0                	mov    %esi,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 10             	add    $0x10,%esp
  80247f:	5e                   	pop    %esi
  802480:	5f                   	pop    %edi
  802481:	5d                   	pop    %ebp
  802482:	c3                   	ret    
  802483:	90                   	nop
  802484:	89 fa                	mov    %edi,%edx
  802486:	89 f0                	mov    %esi,%eax
  802488:	f7 f1                	div    %ecx
  80248a:	89 c6                	mov    %eax,%esi
  80248c:	31 ff                	xor    %edi,%edi
  80248e:	89 f0                	mov    %esi,%eax
  802490:	89 fa                	mov    %edi,%edx
  802492:	83 c4 10             	add    $0x10,%esp
  802495:	5e                   	pop    %esi
  802496:	5f                   	pop    %edi
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    
  802499:	8d 76 00             	lea    0x0(%esi),%esi
  80249c:	89 f1                	mov    %esi,%ecx
  80249e:	d3 e0                	shl    %cl,%eax
  8024a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a4:	b8 20 00 00 00       	mov    $0x20,%eax
  8024a9:	29 f0                	sub    %esi,%eax
  8024ab:	89 ea                	mov    %ebp,%edx
  8024ad:	88 c1                	mov    %al,%cl
  8024af:	d3 ea                	shr    %cl,%edx
  8024b1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8024b5:	09 ca                	or     %ecx,%edx
  8024b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024bb:	89 f1                	mov    %esi,%ecx
  8024bd:	d3 e5                	shl    %cl,%ebp
  8024bf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8024c3:	89 fd                	mov    %edi,%ebp
  8024c5:	88 c1                	mov    %al,%cl
  8024c7:	d3 ed                	shr    %cl,%ebp
  8024c9:	89 fa                	mov    %edi,%edx
  8024cb:	89 f1                	mov    %esi,%ecx
  8024cd:	d3 e2                	shl    %cl,%edx
  8024cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024d3:	88 c1                	mov    %al,%cl
  8024d5:	d3 ef                	shr    %cl,%edi
  8024d7:	09 d7                	or     %edx,%edi
  8024d9:	89 f8                	mov    %edi,%eax
  8024db:	89 ea                	mov    %ebp,%edx
  8024dd:	f7 74 24 08          	divl   0x8(%esp)
  8024e1:	89 d1                	mov    %edx,%ecx
  8024e3:	89 c7                	mov    %eax,%edi
  8024e5:	f7 64 24 0c          	mull   0xc(%esp)
  8024e9:	39 d1                	cmp    %edx,%ecx
  8024eb:	72 17                	jb     802504 <__udivdi3+0x10c>
  8024ed:	74 09                	je     8024f8 <__udivdi3+0x100>
  8024ef:	89 fe                	mov    %edi,%esi
  8024f1:	31 ff                	xor    %edi,%edi
  8024f3:	e9 41 ff ff ff       	jmp    802439 <__udivdi3+0x41>
  8024f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024fc:	89 f1                	mov    %esi,%ecx
  8024fe:	d3 e2                	shl    %cl,%edx
  802500:	39 c2                	cmp    %eax,%edx
  802502:	73 eb                	jae    8024ef <__udivdi3+0xf7>
  802504:	8d 77 ff             	lea    -0x1(%edi),%esi
  802507:	31 ff                	xor    %edi,%edi
  802509:	e9 2b ff ff ff       	jmp    802439 <__udivdi3+0x41>
  80250e:	66 90                	xchg   %ax,%ax
  802510:	31 f6                	xor    %esi,%esi
  802512:	e9 22 ff ff ff       	jmp    802439 <__udivdi3+0x41>
	...

00802518 <__umoddi3>:
  802518:	55                   	push   %ebp
  802519:	57                   	push   %edi
  80251a:	56                   	push   %esi
  80251b:	83 ec 20             	sub    $0x20,%esp
  80251e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802522:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802526:	89 44 24 14          	mov    %eax,0x14(%esp)
  80252a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80252e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802532:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802536:	89 c7                	mov    %eax,%edi
  802538:	89 f2                	mov    %esi,%edx
  80253a:	85 ed                	test   %ebp,%ebp
  80253c:	75 16                	jne    802554 <__umoddi3+0x3c>
  80253e:	39 f1                	cmp    %esi,%ecx
  802540:	0f 86 a6 00 00 00    	jbe    8025ec <__umoddi3+0xd4>
  802546:	f7 f1                	div    %ecx
  802548:	89 d0                	mov    %edx,%eax
  80254a:	31 d2                	xor    %edx,%edx
  80254c:	83 c4 20             	add    $0x20,%esp
  80254f:	5e                   	pop    %esi
  802550:	5f                   	pop    %edi
  802551:	5d                   	pop    %ebp
  802552:	c3                   	ret    
  802553:	90                   	nop
  802554:	39 f5                	cmp    %esi,%ebp
  802556:	0f 87 ac 00 00 00    	ja     802608 <__umoddi3+0xf0>
  80255c:	0f bd c5             	bsr    %ebp,%eax
  80255f:	83 f0 1f             	xor    $0x1f,%eax
  802562:	89 44 24 10          	mov    %eax,0x10(%esp)
  802566:	0f 84 a8 00 00 00    	je     802614 <__umoddi3+0xfc>
  80256c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802570:	d3 e5                	shl    %cl,%ebp
  802572:	bf 20 00 00 00       	mov    $0x20,%edi
  802577:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80257b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80257f:	89 f9                	mov    %edi,%ecx
  802581:	d3 e8                	shr    %cl,%eax
  802583:	09 e8                	or     %ebp,%eax
  802585:	89 44 24 18          	mov    %eax,0x18(%esp)
  802589:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80258d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802591:	d3 e0                	shl    %cl,%eax
  802593:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802597:	89 f2                	mov    %esi,%edx
  802599:	d3 e2                	shl    %cl,%edx
  80259b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80259f:	d3 e0                	shl    %cl,%eax
  8025a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8025a5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025a9:	89 f9                	mov    %edi,%ecx
  8025ab:	d3 e8                	shr    %cl,%eax
  8025ad:	09 d0                	or     %edx,%eax
  8025af:	d3 ee                	shr    %cl,%esi
  8025b1:	89 f2                	mov    %esi,%edx
  8025b3:	f7 74 24 18          	divl   0x18(%esp)
  8025b7:	89 d6                	mov    %edx,%esi
  8025b9:	f7 64 24 0c          	mull   0xc(%esp)
  8025bd:	89 c5                	mov    %eax,%ebp
  8025bf:	89 d1                	mov    %edx,%ecx
  8025c1:	39 d6                	cmp    %edx,%esi
  8025c3:	72 67                	jb     80262c <__umoddi3+0x114>
  8025c5:	74 75                	je     80263c <__umoddi3+0x124>
  8025c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025cb:	29 e8                	sub    %ebp,%eax
  8025cd:	19 ce                	sbb    %ecx,%esi
  8025cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025d3:	d3 e8                	shr    %cl,%eax
  8025d5:	89 f2                	mov    %esi,%edx
  8025d7:	89 f9                	mov    %edi,%ecx
  8025d9:	d3 e2                	shl    %cl,%edx
  8025db:	09 d0                	or     %edx,%eax
  8025dd:	89 f2                	mov    %esi,%edx
  8025df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025e3:	d3 ea                	shr    %cl,%edx
  8025e5:	83 c4 20             	add    $0x20,%esp
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	85 c9                	test   %ecx,%ecx
  8025ee:	75 0b                	jne    8025fb <__umoddi3+0xe3>
  8025f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f5:	31 d2                	xor    %edx,%edx
  8025f7:	f7 f1                	div    %ecx
  8025f9:	89 c1                	mov    %eax,%ecx
  8025fb:	89 f0                	mov    %esi,%eax
  8025fd:	31 d2                	xor    %edx,%edx
  8025ff:	f7 f1                	div    %ecx
  802601:	89 f8                	mov    %edi,%eax
  802603:	e9 3e ff ff ff       	jmp    802546 <__umoddi3+0x2e>
  802608:	89 f2                	mov    %esi,%edx
  80260a:	83 c4 20             	add    $0x20,%esp
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    
  802611:	8d 76 00             	lea    0x0(%esi),%esi
  802614:	39 f5                	cmp    %esi,%ebp
  802616:	72 04                	jb     80261c <__umoddi3+0x104>
  802618:	39 f9                	cmp    %edi,%ecx
  80261a:	77 06                	ja     802622 <__umoddi3+0x10a>
  80261c:	89 f2                	mov    %esi,%edx
  80261e:	29 cf                	sub    %ecx,%edi
  802620:	19 ea                	sbb    %ebp,%edx
  802622:	89 f8                	mov    %edi,%eax
  802624:	83 c4 20             	add    $0x20,%esp
  802627:	5e                   	pop    %esi
  802628:	5f                   	pop    %edi
  802629:	5d                   	pop    %ebp
  80262a:	c3                   	ret    
  80262b:	90                   	nop
  80262c:	89 d1                	mov    %edx,%ecx
  80262e:	89 c5                	mov    %eax,%ebp
  802630:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802634:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802638:	eb 8d                	jmp    8025c7 <__umoddi3+0xaf>
  80263a:	66 90                	xchg   %ax,%ax
  80263c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802640:	72 ea                	jb     80262c <__umoddi3+0x114>
  802642:	89 f1                	mov    %esi,%ecx
  802644:	eb 81                	jmp    8025c7 <__umoddi3+0xaf>
