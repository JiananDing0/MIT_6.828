
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 03 05 00 00       	call   800534 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 3c 24             	mov    %edi,(%esp)
  800050:	e8 f7 1a 00 00       	call   801b4c <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 eb 1a 00 00       	call   801b4c <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 60 2d 80 00 	movl   $0x802d60,(%esp)
  800068:	e8 2f 06 00 00       	call   80069c <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 cb 2d 80 00 	movl   $0x802dcb,(%esp)
  800074:	e8 23 06 00 00       	call   80069c <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 02 0f 00 00       	call   800f8c <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 48 19 00 00       	call   8019e6 <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 da 2d 80 00 	movl   $0x802dda,(%esp)
  8000a9:	e8 ee 05 00 00       	call   80069c <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 cd 0e 00 00       	call   800f8c <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c6:	00 
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 3c 24             	mov    %edi,(%esp)
  8000ce:	e8 13 19 00 00       	call   8019e6 <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 d5 2d 80 00 	movl   $0x802dd5,(%esp)
  8000de:	e8 b9 05 00 00       	call   80069c <cprintf>
	exit();
  8000e3:	e8 a0 04 00 00       	call   800588 <exit>
}
  8000e8:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 7a 17 00 00       	call   801882 <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 6e 17 00 00       	call   801882 <close>
	opencons();
  800114:	e8 c7 03 00 00       	call   8004e0 <opencons>
	opencons();
  800119:	e8 c2 03 00 00       	call   8004e0 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 e8 2d 80 00 	movl   $0x802de8,(%esp)
  80012d:	e8 5b 1d 00 00       	call   801e8d <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 f5 2d 80 	movl   $0x802df5,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  800153:	e8 4c 04 00 00       	call   8005a4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 6a 25 00 00       	call   8026cd <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 1c 2e 80 	movl   $0x802e1c,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  800182:	e8 1d 04 00 00       	call   8005a4 <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  800191:	e8 06 05 00 00       	call   80069c <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 38 12 00 00       	call   8013d3 <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 a1 32 80 	movl   $0x8032a1,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  8001ba:	e8 e5 03 00 00       	call   8005a4 <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 fc 16 00 00       	call   8018d3 <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 ec 16 00 00       	call   8018d3 <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 93 16 00 00       	call   801882 <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 8b 16 00 00       	call   801882 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 25 2e 80 	movl   $0x802e25,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 f2 2d 80 	movl   $0x802df2,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 28 2e 80 00 	movl   $0x802e28,(%esp)
  800216:	e8 6d 22 00 00       	call   802488 <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 2c 2e 80 	movl   $0x802e2c,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  80023c:	e8 63 03 00 00       	call   8005a4 <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 35 16 00 00       	call   801882 <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 29 16 00 00       	call   801882 <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 0f 26 00 00       	call   802870 <wait>
		exit();
  800261:	e8 22 03 00 00       	call   800588 <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 14 16 00 00       	call   801882 <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 0c 16 00 00       	call   801882 <close>

	rfd = pfds[0];
  800276:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 36 2e 80 00 	movl   $0x802e36,(%esp)
  800288:	e8 00 1c 00 00       	call   801e8d <open>
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	85 c0                	test   %eax,%eax
  800291:	79 20                	jns    8002b3 <umain+0x1c0>
		panic("open testshell.key for reading: %e", kfd);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	c7 44 24 08 a8 2d 80 	movl   $0x802da8,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  8002ae:	e8 f1 02 00 00       	call   8005a4 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8002ba:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c8:	00 
  8002c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	89 3c 24             	mov    %edi,(%esp)
  8002d3:	e8 0e 17 00 00       	call   8019e6 <read>
  8002d8:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e1:	00 
  8002e2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	e8 f5 16 00 00       	call   8019e6 <read>
		if (n1 < 0)
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	79 20                	jns    800315 <umain+0x222>
			panic("reading testshell.out: %e", n1);
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	c7 44 24 08 44 2e 80 	movl   $0x802e44,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  800310:	e8 8f 02 00 00       	call   8005a4 <_panic>
		if (n2 < 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	79 20                	jns    800339 <umain+0x246>
			panic("reading testshell.key: %e", n2);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	c7 44 24 08 5e 2e 80 	movl   $0x802e5e,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 0b 2e 80 00 	movl   $0x802e0b,(%esp)
  800334:	e8 6b 02 00 00       	call   8005a4 <_panic>
		if (n1 == 0 && n2 == 0)
  800339:	85 db                	test   %ebx,%ebx
  80033b:	75 06                	jne    800343 <umain+0x250>
  80033d:	85 c0                	test   %eax,%eax
  80033f:	75 14                	jne    800355 <umain+0x262>
  800341:	eb 39                	jmp    80037c <umain+0x289>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800343:	83 fb 01             	cmp    $0x1,%ebx
  800346:	75 0d                	jne    800355 <umain+0x262>
  800348:	83 f8 01             	cmp    $0x1,%eax
  80034b:	75 08                	jne    800355 <umain+0x262>
  80034d:	8a 45 e6             	mov    -0x1a(%ebp),%al
  800350:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800353:	74 13                	je     800368 <umain+0x275>
			wrong(rfd, kfd, nloff);
  800355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	89 3c 24             	mov    %edi,(%esp)
  800363:	e8 cc fc ff ff       	call   800034 <wrong>
		if (c1 == '\n')
  800368:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  80036c:	75 06                	jne    800374 <umain+0x281>
			nloff = off+1;
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800374:	ff 45 d4             	incl   -0x2c(%ebp)
	}
  800377:	e9 45 ff ff ff       	jmp    8002c1 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 78 2e 80 00 	movl   $0x802e78,(%esp)
  800383:	e8 14 03 00 00       	call   80069c <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	00 00                	add    %al,(%eax)
	...

00800394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003a4:	c7 44 24 04 8d 2e 80 	movl   $0x802e8d,0x4(%esp)
  8003ab:	00 
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 b0 08 00 00       	call   800c67 <strcpy>
	return 0;
}
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d5:	eb 30                	jmp    800407 <devcons_write+0x49>
		m = n - tot;
  8003d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8003da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003dc:	83 fe 7f             	cmp    $0x7f,%esi
  8003df:	76 05                	jbe    8003e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8003e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8003e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ea:	03 45 0c             	add    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	89 3c 24             	mov    %edi,(%esp)
  8003f4:	e8 e7 09 00 00       	call   800de0 <memmove>
		sys_cputs(buf, m);
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	89 3c 24             	mov    %edi,(%esp)
  800400:	e8 87 0b 00 00       	call   800f8c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800405:	01 f3                	add    %esi,%ebx
  800407:	89 d8                	mov    %ebx,%eax
  800409:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80040c:	72 c9                	jb     8003d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80040e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800414:	5b                   	pop    %ebx
  800415:	5e                   	pop    %esi
  800416:	5f                   	pop    %edi
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80041f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800423:	75 07                	jne    80042c <devcons_read+0x13>
  800425:	eb 25                	jmp    80044c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800427:	e8 0e 0c 00 00       	call   80103a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80042c:	e8 79 0b 00 00       	call   800faa <sys_cgetc>
  800431:	85 c0                	test   %eax,%eax
  800433:	74 f2                	je     800427 <devcons_read+0xe>
  800435:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800437:	85 c0                	test   %eax,%eax
  800439:	78 1d                	js     800458 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80043b:	83 f8 04             	cmp    $0x4,%eax
  80043e:	74 13                	je     800453 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	88 10                	mov    %dl,(%eax)
	return 1;
  800445:	b8 01 00 00 00       	mov    $0x1,%eax
  80044a:	eb 0c                	jmp    800458 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	eb 05                	jmp    800458 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80046d:	00 
  80046e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 13 0b 00 00       	call   800f8c <sys_cputs>
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <getchar>:

int
getchar(void)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800488:	00 
  800489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800497:	e8 4a 15 00 00       	call   8019e6 <read>
	if (r < 0)
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 0f                	js     8004af <getchar+0x34>
		return r;
	if (r < 1)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	7e 06                	jle    8004aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8004a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004a8:	eb 05                	jmp    8004af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 81 12 00 00       	call   80174a <fd_lookup>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	78 11                	js     8004de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004d6:	39 10                	cmp    %edx,(%eax)
  8004d8:	0f 94 c0             	sete   %al
  8004db:	0f b6 c0             	movzbl %al,%eax
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <opencons>:

int
opencons(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 06 12 00 00       	call   8016f7 <fd_alloc>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 3c                	js     800531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8004f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8004fc:	00 
  8004fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050b:	e8 49 0b 00 00       	call   801059 <sys_page_alloc>
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1d                	js     800531 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800514:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80051a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80051f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 9b 11 00 00       	call   8016cc <fd2num>
}
  800531:	c9                   	leave  
  800532:	c3                   	ret    
	...

00800534 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 10             	sub    $0x10,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800542:	e8 d4 0a 00 00       	call   80101b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800547:	25 ff 03 00 00       	and    $0x3ff,%eax
  80054c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800553:	c1 e0 07             	shl    $0x7,%eax
  800556:	29 d0                	sub    %edx,%eax
  800558:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80055d:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800562:	85 f6                	test   %esi,%esi
  800564:	7e 07                	jle    80056d <libmain+0x39>
		binaryname = argv[0];
  800566:	8b 03                	mov    (%ebx),%eax
  800568:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 7a fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  800579:	e8 0a 00 00 00       	call   800588 <exit>
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	5b                   	pop    %ebx
  800582:	5e                   	pop    %esi
  800583:	5d                   	pop    %ebp
  800584:	c3                   	ret    
  800585:	00 00                	add    %al,(%eax)
	...

00800588 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80058e:	e8 20 13 00 00       	call   8018b3 <close_all>
	sys_env_destroy(0);
  800593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059a:	e8 2a 0a 00 00       	call   800fc9 <sys_env_destroy>
}
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    
  8005a1:	00 00                	add    %al,(%eax)
	...

008005a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	56                   	push   %esi
  8005a8:	53                   	push   %ebx
  8005a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005af:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005b5:	e8 61 0a 00 00       	call   80101b <sys_getenvid>
  8005ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  8005d7:	e8 c0 00 00 00       	call   80069c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 50 00 00 00       	call   80063b <vcprintf>
	cprintf("\n");
  8005eb:	c7 04 24 d8 2d 80 00 	movl   $0x802dd8,(%esp)
  8005f2:	e8 a5 00 00 00       	call   80069c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f7:	cc                   	int3   
  8005f8:	eb fd                	jmp    8005f7 <_panic+0x53>
	...

008005fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	53                   	push   %ebx
  800600:	83 ec 14             	sub    $0x14,%esp
  800603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800606:	8b 03                	mov    (%ebx),%eax
  800608:	8b 55 08             	mov    0x8(%ebp),%edx
  80060b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80060f:	40                   	inc    %eax
  800610:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800612:	3d ff 00 00 00       	cmp    $0xff,%eax
  800617:	75 19                	jne    800632 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800619:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800620:	00 
  800621:	8d 43 08             	lea    0x8(%ebx),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	e8 60 09 00 00       	call   800f8c <sys_cputs>
		b->idx = 0;
  80062c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800632:	ff 43 04             	incl   0x4(%ebx)
}
  800635:	83 c4 14             	add    $0x14,%esp
  800638:	5b                   	pop    %ebx
  800639:	5d                   	pop    %ebp
  80063a:	c3                   	ret    

0080063b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800644:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064b:	00 00 00 
	b.cnt = 0;
  80064e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800655:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	89 44 24 08          	mov    %eax,0x8(%esp)
  800666:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800670:	c7 04 24 fc 05 80 00 	movl   $0x8005fc,(%esp)
  800677:	e8 82 01 00 00       	call   8007fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80067c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800682:	89 44 24 04          	mov    %eax,0x4(%esp)
  800686:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 f8 08 00 00       	call   800f8c <sys_cputs>

	return b.cnt;
}
  800694:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	89 04 24             	mov    %eax,(%esp)
  8006af:	e8 87 ff ff ff       	call   80063b <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    
	...

008006b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 3c             	sub    $0x3c,%esp
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c4:	89 d7                	mov    %edx,%edi
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	75 08                	jne    8006e4 <printnum+0x2c>
  8006dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006e2:	77 57                	ja     80073b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006e8:	4b                   	dec    %ebx
  8006e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8006fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800703:	00 
  800704:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80070d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800711:	e8 e6 23 00 00       	call   802afc <__udivdi3>
  800716:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80071a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071e:	89 04 24             	mov    %eax,(%esp)
  800721:	89 54 24 04          	mov    %edx,0x4(%esp)
  800725:	89 fa                	mov    %edi,%edx
  800727:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80072a:	e8 89 ff ff ff       	call   8006b8 <printnum>
  80072f:	eb 0f                	jmp    800740 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800731:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800735:	89 34 24             	mov    %esi,(%esp)
  800738:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80073b:	4b                   	dec    %ebx
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f f1                	jg     800731 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800744:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800748:	8b 45 10             	mov    0x10(%ebp),%eax
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800756:	00 
  800757:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	e8 b3 24 00 00       	call   802c1c <__umoddi3>
  800769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076d:	0f be 80 c7 2e 80 00 	movsbl 0x802ec7(%eax),%eax
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80077a:	83 c4 3c             	add    $0x3c,%esp
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5f                   	pop    %edi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800785:	83 fa 01             	cmp    $0x1,%edx
  800788:	7e 0e                	jle    800798 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078a:	8b 10                	mov    (%eax),%edx
  80078c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80078f:	89 08                	mov    %ecx,(%eax)
  800791:	8b 02                	mov    (%edx),%eax
  800793:	8b 52 04             	mov    0x4(%edx),%edx
  800796:	eb 22                	jmp    8007ba <getuint+0x38>
	else if (lflag)
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 10                	je     8007ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a1:	89 08                	mov    %ecx,(%eax)
  8007a3:	8b 02                	mov    (%edx),%eax
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	eb 0e                	jmp    8007ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b1:	89 08                	mov    %ecx,(%eax)
  8007b3:	8b 02                	mov    (%edx),%eax
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ca:	73 08                	jae    8007d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	88 0a                	mov    %cl,(%edx)
  8007d1:	42                   	inc    %edx
  8007d2:	89 10                	mov    %edx,(%eax)
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 02 00 00 00       	call   8007fe <vprintfmt>
	va_end(ap);
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	57                   	push   %edi
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	83 ec 4c             	sub    $0x4c,%esp
  800807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080a:	8b 75 10             	mov    0x10(%ebp),%esi
  80080d:	eb 12                	jmp    800821 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80080f:	85 c0                	test   %eax,%eax
  800811:	0f 84 8b 03 00 00    	je     800ba2 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800821:	0f b6 06             	movzbl (%esi),%eax
  800824:	46                   	inc    %esi
  800825:	83 f8 25             	cmp    $0x25,%eax
  800828:	75 e5                	jne    80080f <vprintfmt+0x11>
  80082a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80082e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800835:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80083a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	eb 26                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80084b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80084f:	eb 1d                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800854:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800858:	eb 14                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80085d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800864:	eb 08                	jmp    80086e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800866:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800869:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086e:	0f b6 06             	movzbl (%esi),%eax
  800871:	8d 56 01             	lea    0x1(%esi),%edx
  800874:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800877:	8a 16                	mov    (%esi),%dl
  800879:	83 ea 23             	sub    $0x23,%edx
  80087c:	80 fa 55             	cmp    $0x55,%dl
  80087f:	0f 87 01 03 00 00    	ja     800b86 <vprintfmt+0x388>
  800885:	0f b6 d2             	movzbl %dl,%edx
  800888:	ff 24 95 00 30 80 00 	jmp    *0x803000(,%edx,4)
  80088f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800892:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800897:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80089a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80089e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008a4:	83 fa 09             	cmp    $0x9,%edx
  8008a7:	77 2a                	ja     8008d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008aa:	eb eb                	jmp    800897 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 50 04             	lea    0x4(%eax),%edx
  8008b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ba:	eb 17                	jmp    8008d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c0:	78 98                	js     80085a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c5:	eb a7                	jmp    80086e <vprintfmt+0x70>
  8008c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008d1:	eb 9b                	jmp    80086e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d7:	79 95                	jns    80086e <vprintfmt+0x70>
  8008d9:	eb 8b                	jmp    800866 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008df:	eb 8d                	jmp    80086e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8d 50 04             	lea    0x4(%eax),%edx
  8008e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f9:	e9 23 ff ff ff       	jmp    800821 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8d 50 04             	lea    0x4(%eax),%edx
  800904:	89 55 14             	mov    %edx,0x14(%ebp)
  800907:	8b 00                	mov    (%eax),%eax
  800909:	85 c0                	test   %eax,%eax
  80090b:	79 02                	jns    80090f <vprintfmt+0x111>
  80090d:	f7 d8                	neg    %eax
  80090f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800911:	83 f8 0f             	cmp    $0xf,%eax
  800914:	7f 0b                	jg     800921 <vprintfmt+0x123>
  800916:	8b 04 85 60 31 80 00 	mov    0x803160(,%eax,4),%eax
  80091d:	85 c0                	test   %eax,%eax
  80091f:	75 23                	jne    800944 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800921:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800925:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  80092c:	00 
  80092d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	e8 9a fe ff ff       	call   8007d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80093f:	e9 dd fe ff ff       	jmp    800821 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800944:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800948:	c7 44 24 08 ba 33 80 	movl   $0x8033ba,0x8(%esp)
  80094f:	00 
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	8b 55 08             	mov    0x8(%ebp),%edx
  800957:	89 14 24             	mov    %edx,(%esp)
  80095a:	e8 77 fe ff ff       	call   8007d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800962:	e9 ba fe ff ff       	jmp    800821 <vprintfmt+0x23>
  800967:	89 f9                	mov    %edi,%ecx
  800969:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80096c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096f:	8b 45 14             	mov    0x14(%ebp),%eax
  800972:	8d 50 04             	lea    0x4(%eax),%edx
  800975:	89 55 14             	mov    %edx,0x14(%ebp)
  800978:	8b 30                	mov    (%eax),%esi
  80097a:	85 f6                	test   %esi,%esi
  80097c:	75 05                	jne    800983 <vprintfmt+0x185>
				p = "(null)";
  80097e:	be d8 2e 80 00       	mov    $0x802ed8,%esi
			if (width > 0 && padc != '-')
  800983:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800987:	0f 8e 84 00 00 00    	jle    800a11 <vprintfmt+0x213>
  80098d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800991:	74 7e                	je     800a11 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800993:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800997:	89 34 24             	mov    %esi,(%esp)
  80099a:	e8 ab 02 00 00       	call   800c4a <strnlen>
  80099f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009a2:	29 c2                	sub    %eax,%edx
  8009a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009b1:	89 de                	mov    %ebx,%esi
  8009b3:	89 d3                	mov    %edx,%ebx
  8009b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b7:	eb 0b                	jmp    8009c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009bd:	89 3c 24             	mov    %edi,(%esp)
  8009c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c3:	4b                   	dec    %ebx
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	7f f1                	jg     8009b9 <vprintfmt+0x1bb>
  8009c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	79 05                	jns    8009dc <vprintfmt+0x1de>
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009df:	29 c2                	sub    %eax,%edx
  8009e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009e4:	eb 2b                	jmp    800a11 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009ea:	74 18                	je     800a04 <vprintfmt+0x206>
  8009ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009ef:	83 fa 5e             	cmp    $0x5e,%edx
  8009f2:	76 10                	jbe    800a04 <vprintfmt+0x206>
					putch('?', putdat);
  8009f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009ff:	ff 55 08             	call   *0x8(%ebp)
  800a02:	eb 0a                	jmp    800a0e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0e:	ff 4d e4             	decl   -0x1c(%ebp)
  800a11:	0f be 06             	movsbl (%esi),%eax
  800a14:	46                   	inc    %esi
  800a15:	85 c0                	test   %eax,%eax
  800a17:	74 21                	je     800a3a <vprintfmt+0x23c>
  800a19:	85 ff                	test   %edi,%edi
  800a1b:	78 c9                	js     8009e6 <vprintfmt+0x1e8>
  800a1d:	4f                   	dec    %edi
  800a1e:	79 c6                	jns    8009e6 <vprintfmt+0x1e8>
  800a20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a23:	89 de                	mov    %ebx,%esi
  800a25:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a28:	eb 18                	jmp    800a42 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a35:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a37:	4b                   	dec    %ebx
  800a38:	eb 08                	jmp    800a42 <vprintfmt+0x244>
  800a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3d:	89 de                	mov    %ebx,%esi
  800a3f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	7f e4                	jg     800a2a <vprintfmt+0x22c>
  800a46:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a49:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a4e:	e9 ce fd ff ff       	jmp    800821 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a53:	83 f9 01             	cmp    $0x1,%ecx
  800a56:	7e 10                	jle    800a68 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8d 50 08             	lea    0x8(%eax),%edx
  800a5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a61:	8b 30                	mov    (%eax),%esi
  800a63:	8b 78 04             	mov    0x4(%eax),%edi
  800a66:	eb 26                	jmp    800a8e <vprintfmt+0x290>
	else if (lflag)
  800a68:	85 c9                	test   %ecx,%ecx
  800a6a:	74 12                	je     800a7e <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6f:	8d 50 04             	lea    0x4(%eax),%edx
  800a72:	89 55 14             	mov    %edx,0x14(%ebp)
  800a75:	8b 30                	mov    (%eax),%esi
  800a77:	89 f7                	mov    %esi,%edi
  800a79:	c1 ff 1f             	sar    $0x1f,%edi
  800a7c:	eb 10                	jmp    800a8e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	8d 50 04             	lea    0x4(%eax),%edx
  800a84:	89 55 14             	mov    %edx,0x14(%ebp)
  800a87:	8b 30                	mov    (%eax),%esi
  800a89:	89 f7                	mov    %esi,%edi
  800a8b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a8e:	85 ff                	test   %edi,%edi
  800a90:	78 0a                	js     800a9c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a97:	e9 ac 00 00 00       	jmp    800b48 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aa7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aaa:	f7 de                	neg    %esi
  800aac:	83 d7 00             	adc    $0x0,%edi
  800aaf:	f7 df                	neg    %edi
			}
			base = 10;
  800ab1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab6:	e9 8d 00 00 00       	jmp    800b48 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800abb:	89 ca                	mov    %ecx,%edx
  800abd:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac0:	e8 bd fc ff ff       	call   800782 <getuint>
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	89 d7                	mov    %edx,%edi
			base = 10;
  800ac9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800ace:	eb 78                	jmp    800b48 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800ad0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800adb:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800ade:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800ae9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800aec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800af7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afa:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800afd:	e9 1f fd ff ff       	jmp    800821 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800b02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b06:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b0d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b14:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b1b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b21:	8d 50 04             	lea    0x4(%eax),%edx
  800b24:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b27:	8b 30                	mov    (%eax),%esi
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b2e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b33:	eb 13                	jmp    800b48 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b35:	89 ca                	mov    %ecx,%edx
  800b37:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3a:	e8 43 fc ff ff       	call   800782 <getuint>
  800b3f:	89 c6                	mov    %eax,%esi
  800b41:	89 d7                	mov    %edx,%edi
			base = 16;
  800b43:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b48:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b4c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b53:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5b:	89 34 24             	mov    %esi,(%esp)
  800b5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b62:	89 da                	mov    %ebx,%edx
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	e8 4c fb ff ff       	call   8006b8 <printnum>
			break;
  800b6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b6f:	e9 ad fc ff ff       	jmp    800821 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b78:	89 04 24             	mov    %eax,(%esp)
  800b7b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b7e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b81:	e9 9b fc ff ff       	jmp    800821 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b91:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b94:	eb 01                	jmp    800b97 <vprintfmt+0x399>
  800b96:	4e                   	dec    %esi
  800b97:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b9b:	75 f9                	jne    800b96 <vprintfmt+0x398>
  800b9d:	e9 7f fc ff ff       	jmp    800821 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ba2:	83 c4 4c             	add    $0x4c,%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 28             	sub    $0x28,%esp
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bbd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	74 30                	je     800bfb <vsnprintf+0x51>
  800bcb:	85 d2                	test   %edx,%edx
  800bcd:	7e 33                	jle    800c02 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be4:	c7 04 24 bc 07 80 00 	movl   $0x8007bc,(%esp)
  800beb:	e8 0e fc ff ff       	call   8007fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf9:	eb 0c                	jmp    800c07 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bfb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c00:	eb 05                	jmp    800c07 <vsnprintf+0x5d>
  800c02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c0f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c16:	8b 45 10             	mov    0x10(%ebp),%eax
  800c19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	89 04 24             	mov    %eax,(%esp)
  800c2a:	e8 7b ff ff ff       	call   800baa <vsnprintf>
	va_end(ap);

	return rc;
}
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    
  800c31:	00 00                	add    %al,(%eax)
	...

00800c34 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	eb 01                	jmp    800c42 <strlen+0xe>
		n++;
  800c41:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c42:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c46:	75 f9                	jne    800c41 <strlen+0xd>
		n++;
	return n;
}
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c50:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
  800c58:	eb 01                	jmp    800c5b <strnlen+0x11>
		n++;
  800c5a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5b:	39 d0                	cmp    %edx,%eax
  800c5d:	74 06                	je     800c65 <strnlen+0x1b>
  800c5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c63:	75 f5                	jne    800c5a <strnlen+0x10>
		n++;
	return n;
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	53                   	push   %ebx
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c71:	ba 00 00 00 00       	mov    $0x0,%edx
  800c76:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c79:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c7c:	42                   	inc    %edx
  800c7d:	84 c9                	test   %cl,%cl
  800c7f:	75 f5                	jne    800c76 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c81:	5b                   	pop    %ebx
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	83 ec 08             	sub    $0x8,%esp
  800c8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c8e:	89 1c 24             	mov    %ebx,(%esp)
  800c91:	e8 9e ff ff ff       	call   800c34 <strlen>
	strcpy(dst + len, src);
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c99:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c9d:	01 d8                	add    %ebx,%eax
  800c9f:	89 04 24             	mov    %eax,(%esp)
  800ca2:	e8 c0 ff ff ff       	call   800c67 <strcpy>
	return dst;
}
  800ca7:	89 d8                	mov    %ebx,%eax
  800ca9:	83 c4 08             	add    $0x8,%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cba:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc2:	eb 0c                	jmp    800cd0 <strncpy+0x21>
		*dst++ = *src;
  800cc4:	8a 1a                	mov    (%edx),%bl
  800cc6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cc9:	80 3a 01             	cmpb   $0x1,(%edx)
  800ccc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ccf:	41                   	inc    %ecx
  800cd0:	39 f1                	cmp    %esi,%ecx
  800cd2:	75 f0                	jne    800cc4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ce6:	85 d2                	test   %edx,%edx
  800ce8:	75 0a                	jne    800cf4 <strlcpy+0x1c>
  800cea:	89 f0                	mov    %esi,%eax
  800cec:	eb 1a                	jmp    800d08 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cee:	88 18                	mov    %bl,(%eax)
  800cf0:	40                   	inc    %eax
  800cf1:	41                   	inc    %ecx
  800cf2:	eb 02                	jmp    800cf6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cf6:	4a                   	dec    %edx
  800cf7:	74 0a                	je     800d03 <strlcpy+0x2b>
  800cf9:	8a 19                	mov    (%ecx),%bl
  800cfb:	84 db                	test   %bl,%bl
  800cfd:	75 ef                	jne    800cee <strlcpy+0x16>
  800cff:	89 c2                	mov    %eax,%edx
  800d01:	eb 02                	jmp    800d05 <strlcpy+0x2d>
  800d03:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d05:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d08:	29 f0                	sub    %esi,%eax
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d14:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d17:	eb 02                	jmp    800d1b <strcmp+0xd>
		p++, q++;
  800d19:	41                   	inc    %ecx
  800d1a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d1b:	8a 01                	mov    (%ecx),%al
  800d1d:	84 c0                	test   %al,%al
  800d1f:	74 04                	je     800d25 <strcmp+0x17>
  800d21:	3a 02                	cmp    (%edx),%al
  800d23:	74 f4                	je     800d19 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d25:	0f b6 c0             	movzbl %al,%eax
  800d28:	0f b6 12             	movzbl (%edx),%edx
  800d2b:	29 d0                	sub    %edx,%eax
}
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	53                   	push   %ebx
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d3c:	eb 03                	jmp    800d41 <strncmp+0x12>
		n--, p++, q++;
  800d3e:	4a                   	dec    %edx
  800d3f:	40                   	inc    %eax
  800d40:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d41:	85 d2                	test   %edx,%edx
  800d43:	74 14                	je     800d59 <strncmp+0x2a>
  800d45:	8a 18                	mov    (%eax),%bl
  800d47:	84 db                	test   %bl,%bl
  800d49:	74 04                	je     800d4f <strncmp+0x20>
  800d4b:	3a 19                	cmp    (%ecx),%bl
  800d4d:	74 ef                	je     800d3e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	0f b6 11             	movzbl (%ecx),%edx
  800d55:	29 d0                	sub    %edx,%eax
  800d57:	eb 05                	jmp    800d5e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d6a:	eb 05                	jmp    800d71 <strchr+0x10>
		if (*s == c)
  800d6c:	38 ca                	cmp    %cl,%dl
  800d6e:	74 0c                	je     800d7c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d70:	40                   	inc    %eax
  800d71:	8a 10                	mov    (%eax),%dl
  800d73:	84 d2                	test   %dl,%dl
  800d75:	75 f5                	jne    800d6c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d87:	eb 05                	jmp    800d8e <strfind+0x10>
		if (*s == c)
  800d89:	38 ca                	cmp    %cl,%dl
  800d8b:	74 07                	je     800d94 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d8d:	40                   	inc    %eax
  800d8e:	8a 10                	mov    (%eax),%dl
  800d90:	84 d2                	test   %dl,%dl
  800d92:	75 f5                	jne    800d89 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da5:	85 c9                	test   %ecx,%ecx
  800da7:	74 30                	je     800dd9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daf:	75 25                	jne    800dd6 <memset+0x40>
  800db1:	f6 c1 03             	test   $0x3,%cl
  800db4:	75 20                	jne    800dd6 <memset+0x40>
		c &= 0xFF;
  800db6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db9:	89 d3                	mov    %edx,%ebx
  800dbb:	c1 e3 08             	shl    $0x8,%ebx
  800dbe:	89 d6                	mov    %edx,%esi
  800dc0:	c1 e6 18             	shl    $0x18,%esi
  800dc3:	89 d0                	mov    %edx,%eax
  800dc5:	c1 e0 10             	shl    $0x10,%eax
  800dc8:	09 f0                	or     %esi,%eax
  800dca:	09 d0                	or     %edx,%eax
  800dcc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dce:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dd1:	fc                   	cld    
  800dd2:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd4:	eb 03                	jmp    800dd9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd6:	fc                   	cld    
  800dd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd9:	89 f8                	mov    %edi,%eax
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800deb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dee:	39 c6                	cmp    %eax,%esi
  800df0:	73 34                	jae    800e26 <memmove+0x46>
  800df2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df5:	39 d0                	cmp    %edx,%eax
  800df7:	73 2d                	jae    800e26 <memmove+0x46>
		s += n;
		d += n;
  800df9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfc:	f6 c2 03             	test   $0x3,%dl
  800dff:	75 1b                	jne    800e1c <memmove+0x3c>
  800e01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e07:	75 13                	jne    800e1c <memmove+0x3c>
  800e09:	f6 c1 03             	test   $0x3,%cl
  800e0c:	75 0e                	jne    800e1c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e0e:	83 ef 04             	sub    $0x4,%edi
  800e11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e14:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e17:	fd                   	std    
  800e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1a:	eb 07                	jmp    800e23 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e1c:	4f                   	dec    %edi
  800e1d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e20:	fd                   	std    
  800e21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e23:	fc                   	cld    
  800e24:	eb 20                	jmp    800e46 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e2c:	75 13                	jne    800e41 <memmove+0x61>
  800e2e:	a8 03                	test   $0x3,%al
  800e30:	75 0f                	jne    800e41 <memmove+0x61>
  800e32:	f6 c1 03             	test   $0x3,%cl
  800e35:	75 0a                	jne    800e41 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e37:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e3a:	89 c7                	mov    %eax,%edi
  800e3c:	fc                   	cld    
  800e3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3f:	eb 05                	jmp    800e46 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e41:	89 c7                	mov    %eax,%edi
  800e43:	fc                   	cld    
  800e44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e50:	8b 45 10             	mov    0x10(%ebp),%eax
  800e53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	89 04 24             	mov    %eax,(%esp)
  800e64:	e8 77 ff ff ff       	call   800de0 <memmove>
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7f:	eb 16                	jmp    800e97 <memcmp+0x2c>
		if (*s1 != *s2)
  800e81:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e84:	42                   	inc    %edx
  800e85:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e89:	38 c8                	cmp    %cl,%al
  800e8b:	74 0a                	je     800e97 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e8d:	0f b6 c0             	movzbl %al,%eax
  800e90:	0f b6 c9             	movzbl %cl,%ecx
  800e93:	29 c8                	sub    %ecx,%eax
  800e95:	eb 09                	jmp    800ea0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e97:	39 da                	cmp    %ebx,%edx
  800e99:	75 e6                	jne    800e81 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eb3:	eb 05                	jmp    800eba <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb5:	38 08                	cmp    %cl,(%eax)
  800eb7:	74 05                	je     800ebe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb9:	40                   	inc    %eax
  800eba:	39 d0                	cmp    %edx,%eax
  800ebc:	72 f7                	jb     800eb5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ecc:	eb 01                	jmp    800ecf <strtol+0xf>
		s++;
  800ece:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ecf:	8a 02                	mov    (%edx),%al
  800ed1:	3c 20                	cmp    $0x20,%al
  800ed3:	74 f9                	je     800ece <strtol+0xe>
  800ed5:	3c 09                	cmp    $0x9,%al
  800ed7:	74 f5                	je     800ece <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed9:	3c 2b                	cmp    $0x2b,%al
  800edb:	75 08                	jne    800ee5 <strtol+0x25>
		s++;
  800edd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ede:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee3:	eb 13                	jmp    800ef8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee5:	3c 2d                	cmp    $0x2d,%al
  800ee7:	75 0a                	jne    800ef3 <strtol+0x33>
		s++, neg = 1;
  800ee9:	8d 52 01             	lea    0x1(%edx),%edx
  800eec:	bf 01 00 00 00       	mov    $0x1,%edi
  800ef1:	eb 05                	jmp    800ef8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef8:	85 db                	test   %ebx,%ebx
  800efa:	74 05                	je     800f01 <strtol+0x41>
  800efc:	83 fb 10             	cmp    $0x10,%ebx
  800eff:	75 28                	jne    800f29 <strtol+0x69>
  800f01:	8a 02                	mov    (%edx),%al
  800f03:	3c 30                	cmp    $0x30,%al
  800f05:	75 10                	jne    800f17 <strtol+0x57>
  800f07:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f0b:	75 0a                	jne    800f17 <strtol+0x57>
		s += 2, base = 16;
  800f0d:	83 c2 02             	add    $0x2,%edx
  800f10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f15:	eb 12                	jmp    800f29 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f17:	85 db                	test   %ebx,%ebx
  800f19:	75 0e                	jne    800f29 <strtol+0x69>
  800f1b:	3c 30                	cmp    $0x30,%al
  800f1d:	75 05                	jne    800f24 <strtol+0x64>
		s++, base = 8;
  800f1f:	42                   	inc    %edx
  800f20:	b3 08                	mov    $0x8,%bl
  800f22:	eb 05                	jmp    800f29 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f24:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f30:	8a 0a                	mov    (%edx),%cl
  800f32:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f35:	80 fb 09             	cmp    $0x9,%bl
  800f38:	77 08                	ja     800f42 <strtol+0x82>
			dig = *s - '0';
  800f3a:	0f be c9             	movsbl %cl,%ecx
  800f3d:	83 e9 30             	sub    $0x30,%ecx
  800f40:	eb 1e                	jmp    800f60 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f42:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f45:	80 fb 19             	cmp    $0x19,%bl
  800f48:	77 08                	ja     800f52 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f4a:	0f be c9             	movsbl %cl,%ecx
  800f4d:	83 e9 57             	sub    $0x57,%ecx
  800f50:	eb 0e                	jmp    800f60 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f52:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f55:	80 fb 19             	cmp    $0x19,%bl
  800f58:	77 12                	ja     800f6c <strtol+0xac>
			dig = *s - 'A' + 10;
  800f5a:	0f be c9             	movsbl %cl,%ecx
  800f5d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f60:	39 f1                	cmp    %esi,%ecx
  800f62:	7d 0c                	jge    800f70 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f64:	42                   	inc    %edx
  800f65:	0f af c6             	imul   %esi,%eax
  800f68:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f6a:	eb c4                	jmp    800f30 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f6c:	89 c1                	mov    %eax,%ecx
  800f6e:	eb 02                	jmp    800f72 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f70:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f76:	74 05                	je     800f7d <strtol+0xbd>
		*endptr = (char *) s;
  800f78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f7b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f7d:	85 ff                	test   %edi,%edi
  800f7f:	74 04                	je     800f85 <strtol+0xc5>
  800f81:	89 c8                	mov    %ecx,%eax
  800f83:	f7 d8                	neg    %eax
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
	...

00800f8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	b8 00 00 00 00       	mov    $0x0,%eax
  800f97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9d:	89 c3                	mov    %eax,%ebx
  800f9f:	89 c7                	mov    %eax,%edi
  800fa1:	89 c6                	mov    %eax,%esi
  800fa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sys_cgetc>:

int
sys_cgetc(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fba:	89 d1                	mov    %edx,%ecx
  800fbc:	89 d3                	mov    %edx,%ebx
  800fbe:	89 d7                	mov    %edx,%edi
  800fc0:	89 d6                	mov    %edx,%esi
  800fc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdf:	89 cb                	mov    %ecx,%ebx
  800fe1:	89 cf                	mov    %ecx,%edi
  800fe3:	89 ce                	mov    %ecx,%esi
  800fe5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 28                	jle    801013 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800feb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  80100e:	e8 91 f5 ff ff       	call   8005a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801013:	83 c4 2c             	add    $0x2c,%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	b8 02 00 00 00       	mov    $0x2,%eax
  80102b:	89 d1                	mov    %edx,%ecx
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 d7                	mov    %edx,%edi
  801031:	89 d6                	mov    %edx,%esi
  801033:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_yield>:

void
sys_yield(void)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801040:	ba 00 00 00 00       	mov    $0x0,%edx
  801045:	b8 0b 00 00 00       	mov    $0xb,%eax
  80104a:	89 d1                	mov    %edx,%ecx
  80104c:	89 d3                	mov    %edx,%ebx
  80104e:	89 d7                	mov    %edx,%edi
  801050:	89 d6                	mov    %edx,%esi
  801052:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
  80105f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801062:	be 00 00 00 00       	mov    $0x0,%esi
  801067:	b8 04 00 00 00       	mov    $0x4,%eax
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801072:	8b 55 08             	mov    0x8(%ebp),%edx
  801075:	89 f7                	mov    %esi,%edi
  801077:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	7e 28                	jle    8010a5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801081:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801088:	00 
  801089:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  801090:	00 
  801091:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  8010a0:	e8 ff f4 ff ff       	call   8005a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010a5:	83 c4 2c             	add    $0x2c,%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	57                   	push   %edi
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8010be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	7e 28                	jle    8010f8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010db:	00 
  8010dc:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  8010f3:	e8 ac f4 ff ff       	call   8005a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f8:	83 c4 2c             	add    $0x2c,%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
  801106:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801109:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110e:	b8 06 00 00 00       	mov    $0x6,%eax
  801113:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801116:	8b 55 08             	mov    0x8(%ebp),%edx
  801119:	89 df                	mov    %ebx,%edi
  80111b:	89 de                	mov    %ebx,%esi
  80111d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	7e 28                	jle    80114b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801123:	89 44 24 10          	mov    %eax,0x10(%esp)
  801127:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80112e:	00 
  80112f:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  801136:	00 
  801137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113e:	00 
  80113f:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  801146:	e8 59 f4 ff ff       	call   8005a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80114b:	83 c4 2c             	add    $0x2c,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801161:	b8 08 00 00 00       	mov    $0x8,%eax
  801166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801169:	8b 55 08             	mov    0x8(%ebp),%edx
  80116c:	89 df                	mov    %ebx,%edi
  80116e:	89 de                	mov    %ebx,%esi
  801170:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801172:	85 c0                	test   %eax,%eax
  801174:	7e 28                	jle    80119e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801176:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801181:	00 
  801182:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  801189:	00 
  80118a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801191:	00 
  801192:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  801199:	e8 06 f4 ff ff       	call   8005a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80119e:	83 c4 2c             	add    $0x2c,%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	57                   	push   %edi
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8011b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	89 df                	mov    %ebx,%edi
  8011c1:	89 de                	mov    %ebx,%esi
  8011c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	7e 28                	jle    8011f1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011cd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011d4:	00 
  8011d5:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  8011dc:	00 
  8011dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e4:	00 
  8011e5:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  8011ec:	e8 b3 f3 ff ff       	call   8005a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011f1:	83 c4 2c             	add    $0x2c,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	57                   	push   %edi
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	b8 0a 00 00 00       	mov    $0xa,%eax
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120f:	8b 55 08             	mov    0x8(%ebp),%edx
  801212:	89 df                	mov    %ebx,%edi
  801214:	89 de                	mov    %ebx,%esi
  801216:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801218:	85 c0                	test   %eax,%eax
  80121a:	7e 28                	jle    801244 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801220:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801227:	00 
  801228:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  80122f:	00 
  801230:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801237:	00 
  801238:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  80123f:	e8 60 f3 ff ff       	call   8005a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801244:	83 c4 2c             	add    $0x2c,%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801252:	be 00 00 00 00       	mov    $0x0,%esi
  801257:	b8 0c 00 00 00       	mov    $0xc,%eax
  80125c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80125f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801265:	8b 55 08             	mov    0x8(%ebp),%edx
  801268:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	57                   	push   %edi
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801278:	b9 00 00 00 00       	mov    $0x0,%ecx
  80127d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801282:	8b 55 08             	mov    0x8(%ebp),%edx
  801285:	89 cb                	mov    %ecx,%ebx
  801287:	89 cf                	mov    %ecx,%edi
  801289:	89 ce                	mov    %ecx,%esi
  80128b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80128d:	85 c0                	test   %eax,%eax
  80128f:	7e 28                	jle    8012b9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801291:	89 44 24 10          	mov    %eax,0x10(%esp)
  801295:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80129c:	00 
  80129d:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ac:	00 
  8012ad:	c7 04 24 dc 31 80 00 	movl   $0x8031dc,(%esp)
  8012b4:	e8 eb f2 ff ff       	call   8005a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012b9:	83 c4 2c             	add    $0x2c,%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5f                   	pop    %edi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    
  8012c1:	00 00                	add    %al,(%eax)
	...

008012c4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 24             	sub    $0x24,%esp
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8012ce:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  8012d0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8012d4:	75 20                	jne    8012f6 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  8012d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012da:	c7 44 24 08 ec 31 80 	movl   $0x8031ec,0x8(%esp)
  8012e1:	00 
  8012e2:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8012e9:	00 
  8012ea:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  8012f1:	e8 ae f2 ff ff       	call   8005a4 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8012f6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8012fc:	89 d8                	mov    %ebx,%eax
  8012fe:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801301:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801308:	f6 c4 08             	test   $0x8,%ah
  80130b:	75 1c                	jne    801329 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  80130d:	c7 44 24 08 1c 32 80 	movl   $0x80321c,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  801324:	e8 7b f2 ff ff       	call   8005a4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  801329:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801330:	00 
  801331:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801338:	00 
  801339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801340:	e8 14 fd ff ff       	call   801059 <sys_page_alloc>
  801345:	85 c0                	test   %eax,%eax
  801347:	79 20                	jns    801369 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  801349:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134d:	c7 44 24 08 76 32 80 	movl   $0x803276,0x8(%esp)
  801354:	00 
  801355:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80135c:	00 
  80135d:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  801364:	e8 3b f2 ff ff       	call   8005a4 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  801369:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801370:	00 
  801371:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801375:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80137c:	e8 5f fa ff ff       	call   800de0 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  801381:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801388:	00 
  801389:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80138d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a4:	e8 04 fd ff ff       	call   8010ad <sys_page_map>
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	79 20                	jns    8013cd <pgfault+0x109>
		panic("sys_page_map: %e", r);
  8013ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b1:	c7 44 24 08 89 32 80 	movl   $0x803289,0x8(%esp)
  8013b8:	00 
  8013b9:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8013c0:	00 
  8013c1:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  8013c8:	e8 d7 f1 ff ff       	call   8005a4 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  8013cd:	83 c4 24             	add    $0x24,%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    

008013d3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	57                   	push   %edi
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  8013dc:	c7 04 24 c4 12 80 00 	movl   $0x8012c4,(%esp)
  8013e3:	e8 f4 14 00 00       	call   8028dc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8013e8:	ba 07 00 00 00       	mov    $0x7,%edx
  8013ed:	89 d0                	mov    %edx,%eax
  8013ef:	cd 30                	int    $0x30
  8013f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	79 20                	jns    80141b <fork+0x48>
		panic("sys_exofork: %e", envid);
  8013fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ff:	c7 44 24 08 9a 32 80 	movl   $0x80329a,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  801416:	e8 89 f1 ff ff       	call   8005a4 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  80141b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80141f:	75 25                	jne    801446 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801421:	e8 f5 fb ff ff       	call   80101b <sys_getenvid>
  801426:	25 ff 03 00 00       	and    $0x3ff,%eax
  80142b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801432:	c1 e0 07             	shl    $0x7,%eax
  801435:	29 d0                	sub    %edx,%eax
  801437:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80143c:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801441:	e9 58 02 00 00       	jmp    80169e <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  801446:	bf 00 00 00 00       	mov    $0x0,%edi
  80144b:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801450:	89 f0                	mov    %esi,%eax
  801452:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801455:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80145c:	a8 01                	test   $0x1,%al
  80145e:	0f 84 7a 01 00 00    	je     8015de <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801464:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80146b:	a8 01                	test   $0x1,%al
  80146d:	0f 84 6b 01 00 00    	je     8015de <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801473:	a1 04 50 80 00       	mov    0x805004,%eax
  801478:	8b 40 48             	mov    0x48(%eax),%eax
  80147b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  80147e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801485:	f6 c4 04             	test   $0x4,%ah
  801488:	74 52                	je     8014dc <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80148a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801491:	25 07 0e 00 00       	and    $0xe07,%eax
  801496:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80149e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 f9 fb ff ff       	call   8010ad <sys_page_map>
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	0f 89 22 01 00 00    	jns    8015de <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8014bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c0:	c7 44 24 08 aa 32 80 	movl   $0x8032aa,0x8(%esp)
  8014c7:	00 
  8014c8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8014cf:	00 
  8014d0:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  8014d7:	e8 c8 f0 ff ff       	call   8005a4 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8014dc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014e3:	f6 c4 08             	test   $0x8,%ah
  8014e6:	75 0f                	jne    8014f7 <fork+0x124>
  8014e8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014ef:	a8 02                	test   $0x2,%al
  8014f1:	0f 84 99 00 00 00    	je     801590 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8014f7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014fe:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801501:	83 f8 01             	cmp    $0x1,%eax
  801504:	19 db                	sbb    %ebx,%ebx
  801506:	83 e3 fc             	and    $0xfffffffc,%ebx
  801509:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80150f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801513:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801517:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80151a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80151e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 80 fb ff ff       	call   8010ad <sys_page_map>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	79 20                	jns    801551 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801531:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801535:	c7 44 24 08 aa 32 80 	movl   $0x8032aa,0x8(%esp)
  80153c:	00 
  80153d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801544:	00 
  801545:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  80154c:	e8 53 f0 ff ff       	call   8005a4 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801551:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801555:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801559:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80155c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801560:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801564:	89 04 24             	mov    %eax,(%esp)
  801567:	e8 41 fb ff ff       	call   8010ad <sys_page_map>
  80156c:	85 c0                	test   %eax,%eax
  80156e:	79 6e                	jns    8015de <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801570:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801574:	c7 44 24 08 aa 32 80 	movl   $0x8032aa,0x8(%esp)
  80157b:	00 
  80157c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801583:	00 
  801584:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  80158b:	e8 14 f0 ff ff       	call   8005a4 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801590:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801597:	25 07 0e 00 00       	and    $0xe07,%eax
  80159c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b2:	89 04 24             	mov    %eax,(%esp)
  8015b5:	e8 f3 fa ff ff       	call   8010ad <sys_page_map>
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	79 20                	jns    8015de <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8015be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c2:	c7 44 24 08 aa 32 80 	movl   $0x8032aa,0x8(%esp)
  8015c9:	00 
  8015ca:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8015d1:	00 
  8015d2:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  8015d9:	e8 c6 ef ff ff       	call   8005a4 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8015de:	46                   	inc    %esi
  8015df:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8015e5:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8015eb:	0f 85 5f fe ff ff    	jne    801450 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8015f1:	c7 44 24 04 7c 29 80 	movl   $0x80297c,0x4(%esp)
  8015f8:	00 
  8015f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015fc:	89 04 24             	mov    %eax,(%esp)
  8015ff:	e8 f5 fb ff ff       	call   8011f9 <sys_env_set_pgfault_upcall>
  801604:	85 c0                	test   %eax,%eax
  801606:	79 20                	jns    801628 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801608:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160c:	c7 44 24 08 4c 32 80 	movl   $0x80324c,0x8(%esp)
  801613:	00 
  801614:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80161b:	00 
  80161c:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  801623:	e8 7c ef ff ff       	call   8005a4 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801628:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80162f:	00 
  801630:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801637:	ee 
  801638:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80163b:	89 04 24             	mov    %eax,(%esp)
  80163e:	e8 16 fa ff ff       	call   801059 <sys_page_alloc>
  801643:	85 c0                	test   %eax,%eax
  801645:	79 20                	jns    801667 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  801647:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80164b:	c7 44 24 08 76 32 80 	movl   $0x803276,0x8(%esp)
  801652:	00 
  801653:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  80165a:	00 
  80165b:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  801662:	e8 3d ef ff ff       	call   8005a4 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801667:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80166e:	00 
  80166f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	e8 d9 fa ff ff       	call   801153 <sys_env_set_status>
  80167a:	85 c0                	test   %eax,%eax
  80167c:	79 20                	jns    80169e <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  80167e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801682:	c7 44 24 08 bc 32 80 	movl   $0x8032bc,0x8(%esp)
  801689:	00 
  80168a:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801691:	00 
  801692:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  801699:	e8 06 ef ff ff       	call   8005a4 <_panic>
	}
	
	return envid;
}
  80169e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016a1:	83 c4 3c             	add    $0x3c,%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <sfork>:

// Challenge!
int
sfork(void)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016af:	c7 44 24 08 d3 32 80 	movl   $0x8032d3,0x8(%esp)
  8016b6:	00 
  8016b7:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8016be:	00 
  8016bf:	c7 04 24 6b 32 80 00 	movl   $0x80326b,(%esp)
  8016c6:	e8 d9 ee ff ff       	call   8005a4 <_panic>
	...

008016cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8016d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	e8 df ff ff ff       	call   8016cc <fd2num>
  8016ed:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016f2:	c1 e0 0c             	shl    $0xc,%eax
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801703:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801705:	89 c2                	mov    %eax,%edx
  801707:	c1 ea 16             	shr    $0x16,%edx
  80170a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801711:	f6 c2 01             	test   $0x1,%dl
  801714:	74 11                	je     801727 <fd_alloc+0x30>
  801716:	89 c2                	mov    %eax,%edx
  801718:	c1 ea 0c             	shr    $0xc,%edx
  80171b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801722:	f6 c2 01             	test   $0x1,%dl
  801725:	75 09                	jne    801730 <fd_alloc+0x39>
			*fd_store = fd;
  801727:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
  80172e:	eb 17                	jmp    801747 <fd_alloc+0x50>
  801730:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801735:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80173a:	75 c7                	jne    801703 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80173c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801742:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801747:	5b                   	pop    %ebx
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801750:	83 f8 1f             	cmp    $0x1f,%eax
  801753:	77 36                	ja     80178b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801755:	05 00 00 0d 00       	add    $0xd0000,%eax
  80175a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	c1 ea 16             	shr    $0x16,%edx
  801762:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801769:	f6 c2 01             	test   $0x1,%dl
  80176c:	74 24                	je     801792 <fd_lookup+0x48>
  80176e:	89 c2                	mov    %eax,%edx
  801770:	c1 ea 0c             	shr    $0xc,%edx
  801773:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80177a:	f6 c2 01             	test   $0x1,%dl
  80177d:	74 1a                	je     801799 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80177f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801782:	89 02                	mov    %eax,(%edx)
	return 0;
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
  801789:	eb 13                	jmp    80179e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80178b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801790:	eb 0c                	jmp    80179e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801797:	eb 05                	jmp    80179e <fd_lookup+0x54>
  801799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 14             	sub    $0x14,%esp
  8017a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	eb 0e                	jmp    8017c2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8017b4:	39 08                	cmp    %ecx,(%eax)
  8017b6:	75 09                	jne    8017c1 <dev_lookup+0x21>
			*dev = devtab[i];
  8017b8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bf:	eb 33                	jmp    8017f4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017c1:	42                   	inc    %edx
  8017c2:	8b 04 95 68 33 80 00 	mov    0x803368(,%edx,4),%eax
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	75 e7                	jne    8017b4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017cd:	a1 04 50 80 00       	mov    0x805004,%eax
  8017d2:	8b 40 48             	mov    0x48(%eax),%eax
  8017d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	c7 04 24 ec 32 80 00 	movl   $0x8032ec,(%esp)
  8017e4:	e8 b3 ee ff ff       	call   80069c <cprintf>
	*dev = 0;
  8017e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017f4:	83 c4 14             	add    $0x14,%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 30             	sub    $0x30,%esp
  801802:	8b 75 08             	mov    0x8(%ebp),%esi
  801805:	8a 45 0c             	mov    0xc(%ebp),%al
  801808:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80180b:	89 34 24             	mov    %esi,(%esp)
  80180e:	e8 b9 fe ff ff       	call   8016cc <fd2num>
  801813:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801816:	89 54 24 04          	mov    %edx,0x4(%esp)
  80181a:	89 04 24             	mov    %eax,(%esp)
  80181d:	e8 28 ff ff ff       	call   80174a <fd_lookup>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	85 c0                	test   %eax,%eax
  801826:	78 05                	js     80182d <fd_close+0x33>
	    || fd != fd2)
  801828:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80182b:	74 0d                	je     80183a <fd_close+0x40>
		return (must_exist ? r : 0);
  80182d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801831:	75 46                	jne    801879 <fd_close+0x7f>
  801833:	bb 00 00 00 00       	mov    $0x0,%ebx
  801838:	eb 3f                	jmp    801879 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80183a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	8b 06                	mov    (%esi),%eax
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 55 ff ff ff       	call   8017a0 <dev_lookup>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 18                	js     801869 <fd_close+0x6f>
		if (dev->dev_close)
  801851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801854:	8b 40 10             	mov    0x10(%eax),%eax
  801857:	85 c0                	test   %eax,%eax
  801859:	74 09                	je     801864 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80185b:	89 34 24             	mov    %esi,(%esp)
  80185e:	ff d0                	call   *%eax
  801860:	89 c3                	mov    %eax,%ebx
  801862:	eb 05                	jmp    801869 <fd_close+0x6f>
		else
			r = 0;
  801864:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801869:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801874:	e8 87 f8 ff ff       	call   801100 <sys_page_unmap>
	return r;
}
  801879:	89 d8                	mov    %ebx,%eax
  80187b:	83 c4 30             	add    $0x30,%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 b0 fe ff ff       	call   80174a <fd_lookup>
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 13                	js     8018b1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80189e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018a5:	00 
  8018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a9:	89 04 24             	mov    %eax,(%esp)
  8018ac:	e8 49 ff ff ff       	call   8017fa <fd_close>
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <close_all>:

void
close_all(void)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018bf:	89 1c 24             	mov    %ebx,(%esp)
  8018c2:	e8 bb ff ff ff       	call   801882 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018c7:	43                   	inc    %ebx
  8018c8:	83 fb 20             	cmp    $0x20,%ebx
  8018cb:	75 f2                	jne    8018bf <close_all+0xc>
		close(i);
}
  8018cd:	83 c4 14             	add    $0x14,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	57                   	push   %edi
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 4c             	sub    $0x4c,%esp
  8018dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e9:	89 04 24             	mov    %eax,(%esp)
  8018ec:	e8 59 fe ff ff       	call   80174a <fd_lookup>
  8018f1:	89 c3                	mov    %eax,%ebx
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	0f 88 e1 00 00 00    	js     8019dc <dup+0x109>
		return r;
	close(newfdnum);
  8018fb:	89 3c 24             	mov    %edi,(%esp)
  8018fe:	e8 7f ff ff ff       	call   801882 <close>

	newfd = INDEX2FD(newfdnum);
  801903:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801909:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80190c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 c5 fd ff ff       	call   8016dc <fd2data>
  801917:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801919:	89 34 24             	mov    %esi,(%esp)
  80191c:	e8 bb fd ff ff       	call   8016dc <fd2data>
  801921:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801924:	89 d8                	mov    %ebx,%eax
  801926:	c1 e8 16             	shr    $0x16,%eax
  801929:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801930:	a8 01                	test   $0x1,%al
  801932:	74 46                	je     80197a <dup+0xa7>
  801934:	89 d8                	mov    %ebx,%eax
  801936:	c1 e8 0c             	shr    $0xc,%eax
  801939:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801940:	f6 c2 01             	test   $0x1,%dl
  801943:	74 35                	je     80197a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801945:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80194c:	25 07 0e 00 00       	and    $0xe07,%eax
  801951:	89 44 24 10          	mov    %eax,0x10(%esp)
  801955:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801958:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80195c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801963:	00 
  801964:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801968:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196f:	e8 39 f7 ff ff       	call   8010ad <sys_page_map>
  801974:	89 c3                	mov    %eax,%ebx
  801976:	85 c0                	test   %eax,%eax
  801978:	78 3b                	js     8019b5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80197a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	c1 ea 0c             	shr    $0xc,%edx
  801982:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801989:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80198f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801993:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801997:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80199e:	00 
  80199f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019aa:	e8 fe f6 ff ff       	call   8010ad <sys_page_map>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	79 25                	jns    8019da <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c0:	e8 3b f7 ff ff       	call   801100 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d3:	e8 28 f7 ff ff       	call   801100 <sys_page_unmap>
	return r;
  8019d8:	eb 02                	jmp    8019dc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8019da:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	83 c4 4c             	add    $0x4c,%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 24             	sub    $0x24,%esp
  8019ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f7:	89 1c 24             	mov    %ebx,(%esp)
  8019fa:	e8 4b fd ff ff       	call   80174a <fd_lookup>
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 6d                	js     801a70 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0d:	8b 00                	mov    (%eax),%eax
  801a0f:	89 04 24             	mov    %eax,(%esp)
  801a12:	e8 89 fd ff ff       	call   8017a0 <dev_lookup>
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 55                	js     801a70 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1e:	8b 50 08             	mov    0x8(%eax),%edx
  801a21:	83 e2 03             	and    $0x3,%edx
  801a24:	83 fa 01             	cmp    $0x1,%edx
  801a27:	75 23                	jne    801a4c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a29:	a1 04 50 80 00       	mov    0x805004,%eax
  801a2e:	8b 40 48             	mov    0x48(%eax),%eax
  801a31:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a39:	c7 04 24 2d 33 80 00 	movl   $0x80332d,(%esp)
  801a40:	e8 57 ec ff ff       	call   80069c <cprintf>
		return -E_INVAL;
  801a45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a4a:	eb 24                	jmp    801a70 <read+0x8a>
	}
	if (!dev->dev_read)
  801a4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a4f:	8b 52 08             	mov    0x8(%edx),%edx
  801a52:	85 d2                	test   %edx,%edx
  801a54:	74 15                	je     801a6b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a64:	89 04 24             	mov    %eax,(%esp)
  801a67:	ff d2                	call   *%edx
  801a69:	eb 05                	jmp    801a70 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a6b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801a70:	83 c4 24             	add    $0x24,%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	57                   	push   %edi
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 1c             	sub    $0x1c,%esp
  801a7f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a82:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8a:	eb 23                	jmp    801aaf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a8c:	89 f0                	mov    %esi,%eax
  801a8e:	29 d8                	sub    %ebx,%eax
  801a90:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a97:	01 d8                	add    %ebx,%eax
  801a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9d:	89 3c 24             	mov    %edi,(%esp)
  801aa0:	e8 41 ff ff ff       	call   8019e6 <read>
		if (m < 0)
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 10                	js     801ab9 <readn+0x43>
			return m;
		if (m == 0)
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	74 0a                	je     801ab7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aad:	01 c3                	add    %eax,%ebx
  801aaf:	39 f3                	cmp    %esi,%ebx
  801ab1:	72 d9                	jb     801a8c <readn+0x16>
  801ab3:	89 d8                	mov    %ebx,%eax
  801ab5:	eb 02                	jmp    801ab9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801ab7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801ab9:	83 c4 1c             	add    $0x1c,%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 24             	sub    $0x24,%esp
  801ac8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801acb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad2:	89 1c 24             	mov    %ebx,(%esp)
  801ad5:	e8 70 fc ff ff       	call   80174a <fd_lookup>
  801ada:	85 c0                	test   %eax,%eax
  801adc:	78 68                	js     801b46 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae8:	8b 00                	mov    (%eax),%eax
  801aea:	89 04 24             	mov    %eax,(%esp)
  801aed:	e8 ae fc ff ff       	call   8017a0 <dev_lookup>
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 50                	js     801b46 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801afd:	75 23                	jne    801b22 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801aff:	a1 04 50 80 00       	mov    0x805004,%eax
  801b04:	8b 40 48             	mov    0x48(%eax),%eax
  801b07:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0f:	c7 04 24 49 33 80 00 	movl   $0x803349,(%esp)
  801b16:	e8 81 eb ff ff       	call   80069c <cprintf>
		return -E_INVAL;
  801b1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b20:	eb 24                	jmp    801b46 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b25:	8b 52 0c             	mov    0xc(%edx),%edx
  801b28:	85 d2                	test   %edx,%edx
  801b2a:	74 15                	je     801b41 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b2f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b36:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b3a:	89 04 24             	mov    %eax,(%esp)
  801b3d:	ff d2                	call   *%edx
  801b3f:	eb 05                	jmp    801b46 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b46:	83 c4 24             	add    $0x24,%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <seek>:

int
seek(int fdnum, off_t offset)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b52:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 e6 fb ff ff       	call   80174a <fd_lookup>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 0e                	js     801b76 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b68:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 24             	sub    $0x24,%esp
  801b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b89:	89 1c 24             	mov    %ebx,(%esp)
  801b8c:	e8 b9 fb ff ff       	call   80174a <fd_lookup>
  801b91:	85 c0                	test   %eax,%eax
  801b93:	78 61                	js     801bf6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9f:	8b 00                	mov    (%eax),%eax
  801ba1:	89 04 24             	mov    %eax,(%esp)
  801ba4:	e8 f7 fb ff ff       	call   8017a0 <dev_lookup>
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 49                	js     801bf6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bb4:	75 23                	jne    801bd9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bb6:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bbb:	8b 40 48             	mov    0x48(%eax),%eax
  801bbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc6:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  801bcd:	e8 ca ea ff ff       	call   80069c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bd7:	eb 1d                	jmp    801bf6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bdc:	8b 52 18             	mov    0x18(%edx),%edx
  801bdf:	85 d2                	test   %edx,%edx
  801be1:	74 0e                	je     801bf1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	ff d2                	call   *%edx
  801bef:	eb 05                	jmp    801bf6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bf1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801bf6:	83 c4 24             	add    $0x24,%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	53                   	push   %ebx
  801c00:	83 ec 24             	sub    $0x24,%esp
  801c03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	89 04 24             	mov    %eax,(%esp)
  801c13:	e8 32 fb ff ff       	call   80174a <fd_lookup>
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 52                	js     801c6e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c26:	8b 00                	mov    (%eax),%eax
  801c28:	89 04 24             	mov    %eax,(%esp)
  801c2b:	e8 70 fb ff ff       	call   8017a0 <dev_lookup>
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 3a                	js     801c6e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c3b:	74 2c                	je     801c69 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c3d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c40:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c47:	00 00 00 
	stat->st_isdir = 0;
  801c4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c51:	00 00 00 
	stat->st_dev = dev;
  801c54:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c5e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c61:	89 14 24             	mov    %edx,(%esp)
  801c64:	ff 50 14             	call   *0x14(%eax)
  801c67:	eb 05                	jmp    801c6e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c69:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c6e:	83 c4 24             	add    $0x24,%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c83:	00 
  801c84:	8b 45 08             	mov    0x8(%ebp),%eax
  801c87:	89 04 24             	mov    %eax,(%esp)
  801c8a:	e8 fe 01 00 00       	call   801e8d <open>
  801c8f:	89 c3                	mov    %eax,%ebx
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 1b                	js     801cb0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9c:	89 1c 24             	mov    %ebx,(%esp)
  801c9f:	e8 58 ff ff ff       	call   801bfc <fstat>
  801ca4:	89 c6                	mov    %eax,%esi
	close(fd);
  801ca6:	89 1c 24             	mov    %ebx,(%esp)
  801ca9:	e8 d4 fb ff ff       	call   801882 <close>
	return r;
  801cae:	89 f3                	mov    %esi,%ebx
}
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	00 00                	add    %al,(%eax)
	...

00801cbc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 10             	sub    $0x10,%esp
  801cc4:	89 c3                	mov    %eax,%ebx
  801cc6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cc8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ccf:	75 11                	jne    801ce2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801cd8:	e8 94 0d 00 00       	call   802a71 <ipc_find_env>
  801cdd:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ce2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ce9:	00 
  801cea:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801cf1:	00 
  801cf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf6:	a1 00 50 80 00       	mov    0x805000,%eax
  801cfb:	89 04 24             	mov    %eax,(%esp)
  801cfe:	e8 04 0d 00 00       	call   802a07 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d0a:	00 
  801d0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d16:	e8 85 0c 00 00       	call   8029a0 <ipc_recv>
}
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d28:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801d2e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d36:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d40:	b8 02 00 00 00       	mov    $0x2,%eax
  801d45:	e8 72 ff ff ff       	call   801cbc <fsipc>
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	8b 40 0c             	mov    0xc(%eax),%eax
  801d58:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d62:	b8 06 00 00 00       	mov    $0x6,%eax
  801d67:	e8 50 ff ff ff       	call   801cbc <fsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	53                   	push   %ebx
  801d72:	83 ec 14             	sub    $0x14,%esp
  801d75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d83:	ba 00 00 00 00       	mov    $0x0,%edx
  801d88:	b8 05 00 00 00       	mov    $0x5,%eax
  801d8d:	e8 2a ff ff ff       	call   801cbc <fsipc>
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 2b                	js     801dc1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d96:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d9d:	00 
  801d9e:	89 1c 24             	mov    %ebx,(%esp)
  801da1:	e8 c1 ee ff ff       	call   800c67 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801da6:	a1 80 60 80 00       	mov    0x806080,%eax
  801dab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801db1:	a1 84 60 80 00       	mov    0x806084,%eax
  801db6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc1:	83 c4 14             	add    $0x14,%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801dcd:	c7 44 24 08 78 33 80 	movl   $0x803378,0x8(%esp)
  801dd4:	00 
  801dd5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ddc:	00 
  801ddd:	c7 04 24 96 33 80 00 	movl   $0x803396,(%esp)
  801de4:	e8 bb e7 ff ff       	call   8005a4 <_panic>

00801de9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	83 ec 10             	sub    $0x10,%esp
  801df1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	8b 40 0c             	mov    0xc(%eax),%eax
  801dfa:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dff:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e05:	ba 00 00 00 00       	mov    $0x0,%edx
  801e0a:	b8 03 00 00 00       	mov    $0x3,%eax
  801e0f:	e8 a8 fe ff ff       	call   801cbc <fsipc>
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 6a                	js     801e84 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e1a:	39 c6                	cmp    %eax,%esi
  801e1c:	73 24                	jae    801e42 <devfile_read+0x59>
  801e1e:	c7 44 24 0c a1 33 80 	movl   $0x8033a1,0xc(%esp)
  801e25:	00 
  801e26:	c7 44 24 08 a8 33 80 	movl   $0x8033a8,0x8(%esp)
  801e2d:	00 
  801e2e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e35:	00 
  801e36:	c7 04 24 96 33 80 00 	movl   $0x803396,(%esp)
  801e3d:	e8 62 e7 ff ff       	call   8005a4 <_panic>
	assert(r <= PGSIZE);
  801e42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e47:	7e 24                	jle    801e6d <devfile_read+0x84>
  801e49:	c7 44 24 0c bd 33 80 	movl   $0x8033bd,0xc(%esp)
  801e50:	00 
  801e51:	c7 44 24 08 a8 33 80 	movl   $0x8033a8,0x8(%esp)
  801e58:	00 
  801e59:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e60:	00 
  801e61:	c7 04 24 96 33 80 00 	movl   $0x803396,(%esp)
  801e68:	e8 37 e7 ff ff       	call   8005a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e71:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e78:	00 
  801e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 5c ef ff ff       	call   800de0 <memmove>
	return r;
}
  801e84:	89 d8                	mov    %ebx,%eax
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	5b                   	pop    %ebx
  801e8a:	5e                   	pop    %esi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	83 ec 20             	sub    $0x20,%esp
  801e95:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e98:	89 34 24             	mov    %esi,(%esp)
  801e9b:	e8 94 ed ff ff       	call   800c34 <strlen>
  801ea0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ea5:	7f 60                	jg     801f07 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaa:	89 04 24             	mov    %eax,(%esp)
  801ead:	e8 45 f8 ff ff       	call   8016f7 <fd_alloc>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	78 54                	js     801f0c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801eb8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ebc:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ec3:	e8 9f ed ff ff       	call   800c67 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecb:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ed0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed8:	e8 df fd ff ff       	call   801cbc <fsipc>
  801edd:	89 c3                	mov    %eax,%ebx
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	79 15                	jns    801ef8 <open+0x6b>
		fd_close(fd, 0);
  801ee3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801eea:	00 
  801eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eee:	89 04 24             	mov    %eax,(%esp)
  801ef1:	e8 04 f9 ff ff       	call   8017fa <fd_close>
		return r;
  801ef6:	eb 14                	jmp    801f0c <open+0x7f>
	}

	return fd2num(fd);
  801ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efb:	89 04 24             	mov    %eax,(%esp)
  801efe:	e8 c9 f7 ff ff       	call   8016cc <fd2num>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	eb 05                	jmp    801f0c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f07:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f0c:	89 d8                	mov    %ebx,%eax
  801f0e:	83 c4 20             	add    $0x20,%esp
  801f11:	5b                   	pop    %ebx
  801f12:	5e                   	pop    %esi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f20:	b8 08 00 00 00       	mov    $0x8,%eax
  801f25:	e8 92 fd ff ff       	call   801cbc <fsipc>
}
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	57                   	push   %edi
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801f38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f3f:	00 
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 42 ff ff ff       	call   801e8d <open>
  801f4b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801f51:	85 c0                	test   %eax,%eax
  801f53:	0f 88 05 05 00 00    	js     80245e <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f59:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801f60:	00 
  801f61:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 fd fa ff ff       	call   801a76 <readn>
  801f79:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f7e:	75 0c                	jne    801f8c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801f80:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f87:	45 4c 46 
  801f8a:	74 3b                	je     801fc7 <spawn+0x9b>
		close(fd);
  801f8c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f92:	89 04 24             	mov    %eax,(%esp)
  801f95:	e8 e8 f8 ff ff       	call   801882 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f9a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801fa1:	46 
  801fa2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fac:	c7 04 24 c9 33 80 00 	movl   $0x8033c9,(%esp)
  801fb3:	e8 e4 e6 ff ff       	call   80069c <cprintf>
		return -E_NOT_EXEC;
  801fb8:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801fbf:	ff ff ff 
  801fc2:	e9 a3 04 00 00       	jmp    80246a <spawn+0x53e>
  801fc7:	ba 07 00 00 00       	mov    $0x7,%edx
  801fcc:	89 d0                	mov    %edx,%eax
  801fce:	cd 30                	int    $0x30
  801fd0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801fd6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	0f 88 86 04 00 00    	js     80246a <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801fe4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fe9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ff0:	c1 e0 07             	shl    $0x7,%eax
  801ff3:	29 d0                	sub    %edx,%eax
  801ff5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801ffb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802001:	b9 11 00 00 00       	mov    $0x11,%ecx
  802006:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802008:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80200e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802014:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802019:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802021:	eb 0d                	jmp    802030 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802023:	89 04 24             	mov    %eax,(%esp)
  802026:	e8 09 ec ff ff       	call   800c34 <strlen>
  80202b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80202f:	46                   	inc    %esi
  802030:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802032:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802039:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  80203c:	85 c0                	test   %eax,%eax
  80203e:	75 e3                	jne    802023 <spawn+0xf7>
  802040:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802046:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80204c:	bf 00 10 40 00       	mov    $0x401000,%edi
  802051:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802053:	89 f8                	mov    %edi,%eax
  802055:	83 e0 fc             	and    $0xfffffffc,%eax
  802058:	f7 d2                	not    %edx
  80205a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80205d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802063:	89 d0                	mov    %edx,%eax
  802065:	83 e8 08             	sub    $0x8,%eax
  802068:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80206d:	0f 86 08 04 00 00    	jbe    80247b <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802073:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80207a:	00 
  80207b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802082:	00 
  802083:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208a:	e8 ca ef ff ff       	call   801059 <sys_page_alloc>
  80208f:	85 c0                	test   %eax,%eax
  802091:	0f 88 e9 03 00 00    	js     802480 <spawn+0x554>
  802097:	bb 00 00 00 00       	mov    $0x0,%ebx
  80209c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8020a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020a5:	eb 2e                	jmp    8020d5 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8020a7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8020ad:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020b3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8020b6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8020b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bd:	89 3c 24             	mov    %edi,(%esp)
  8020c0:	e8 a2 eb ff ff       	call   800c67 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8020c5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8020c8:	89 04 24             	mov    %eax,(%esp)
  8020cb:	e8 64 eb ff ff       	call   800c34 <strlen>
  8020d0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8020d4:	43                   	inc    %ebx
  8020d5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8020db:	7c ca                	jl     8020a7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8020dd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020e3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8020e9:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8020f0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8020f6:	74 24                	je     80211c <spawn+0x1f0>
  8020f8:	c7 44 24 0c 28 34 80 	movl   $0x803428,0xc(%esp)
  8020ff:	00 
  802100:	c7 44 24 08 a8 33 80 	movl   $0x8033a8,0x8(%esp)
  802107:	00 
  802108:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80210f:	00 
  802110:	c7 04 24 e3 33 80 00 	movl   $0x8033e3,(%esp)
  802117:	e8 88 e4 ff ff       	call   8005a4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80211c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802122:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802127:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80212d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802130:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802136:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802139:	89 d0                	mov    %edx,%eax
  80213b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802140:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802146:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80214d:	00 
  80214e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802155:	ee 
  802156:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80215c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802160:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802167:	00 
  802168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216f:	e8 39 ef ff ff       	call   8010ad <sys_page_map>
  802174:	89 c3                	mov    %eax,%ebx
  802176:	85 c0                	test   %eax,%eax
  802178:	78 1a                	js     802194 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80217a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802181:	00 
  802182:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802189:	e8 72 ef ff ff       	call   801100 <sys_page_unmap>
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	85 c0                	test   %eax,%eax
  802192:	79 1f                	jns    8021b3 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802194:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80219b:	00 
  80219c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a3:	e8 58 ef ff ff       	call   801100 <sys_page_unmap>
	return r;
  8021a8:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8021ae:	e9 b7 02 00 00       	jmp    80246a <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8021b3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8021b9:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8021bf:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021c5:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8021cc:	00 00 00 
  8021cf:	e9 bb 01 00 00       	jmp    80238f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8021d4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8021da:	83 38 01             	cmpl   $0x1,(%eax)
  8021dd:	0f 85 9f 01 00 00    	jne    802382 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8021e3:	89 c2                	mov    %eax,%edx
  8021e5:	8b 40 18             	mov    0x18(%eax),%eax
  8021e8:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8021eb:	83 f8 01             	cmp    $0x1,%eax
  8021ee:	19 c0                	sbb    %eax,%eax
  8021f0:	83 e0 fe             	and    $0xfffffffe,%eax
  8021f3:	83 c0 07             	add    $0x7,%eax
  8021f6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8021fc:	8b 52 04             	mov    0x4(%edx),%edx
  8021ff:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802205:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80220b:	8b 40 10             	mov    0x10(%eax),%eax
  80220e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802214:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80221a:	8b 52 14             	mov    0x14(%edx),%edx
  80221d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802223:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802229:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80222c:	89 f8                	mov    %edi,%eax
  80222e:	25 ff 0f 00 00       	and    $0xfff,%eax
  802233:	74 16                	je     80224b <spawn+0x31f>
		va -= i;
  802235:	29 c7                	sub    %eax,%edi
		memsz += i;
  802237:	01 c2                	add    %eax,%edx
  802239:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  80223f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802245:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80224b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802250:	e9 1f 01 00 00       	jmp    802374 <spawn+0x448>
		if (i >= filesz) {
  802255:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  80225b:	77 2b                	ja     802288 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80225d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802263:	89 54 24 08          	mov    %edx,0x8(%esp)
  802267:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80226b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802271:	89 04 24             	mov    %eax,(%esp)
  802274:	e8 e0 ed ff ff       	call   801059 <sys_page_alloc>
  802279:	85 c0                	test   %eax,%eax
  80227b:	0f 89 e7 00 00 00    	jns    802368 <spawn+0x43c>
  802281:	89 c6                	mov    %eax,%esi
  802283:	e9 b2 01 00 00       	jmp    80243a <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802288:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80228f:	00 
  802290:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802297:	00 
  802298:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229f:	e8 b5 ed ff ff       	call   801059 <sys_page_alloc>
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	0f 88 84 01 00 00    	js     802430 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8022ac:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8022b2:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022be:	89 04 24             	mov    %eax,(%esp)
  8022c1:	e8 86 f8 ff ff       	call   801b4c <seek>
  8022c6:	85 c0                	test   %eax,%eax
  8022c8:	0f 88 66 01 00 00    	js     802434 <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8022ce:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8022d4:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8022d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022db:	76 05                	jbe    8022e2 <spawn+0x3b6>
  8022dd:	b8 00 10 00 00       	mov    $0x1000,%eax
  8022e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022ed:	00 
  8022ee:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022f4:	89 04 24             	mov    %eax,(%esp)
  8022f7:	e8 7a f7 ff ff       	call   801a76 <readn>
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	0f 88 34 01 00 00    	js     802438 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802304:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80230a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80230e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802312:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80231c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802323:	00 
  802324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232b:	e8 7d ed ff ff       	call   8010ad <sys_page_map>
  802330:	85 c0                	test   %eax,%eax
  802332:	79 20                	jns    802354 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802334:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802338:	c7 44 24 08 ef 33 80 	movl   $0x8033ef,0x8(%esp)
  80233f:	00 
  802340:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802347:	00 
  802348:	c7 04 24 e3 33 80 00 	movl   $0x8033e3,(%esp)
  80234f:	e8 50 e2 ff ff       	call   8005a4 <_panic>
			sys_page_unmap(0, UTEMP);
  802354:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80235b:	00 
  80235c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802363:	e8 98 ed ff ff       	call   801100 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802368:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80236e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802374:	89 de                	mov    %ebx,%esi
  802376:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  80237c:	0f 87 d3 fe ff ff    	ja     802255 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802382:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802388:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80238f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802396:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  80239c:	0f 8c 32 fe ff ff    	jl     8021d4 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8023a2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8023a8:	89 04 24             	mov    %eax,(%esp)
  8023ab:	e8 d2 f4 ff ff       	call   801882 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8023b0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8023b7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8023ba:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8023c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c4:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023ca:	89 04 24             	mov    %eax,(%esp)
  8023cd:	e8 d4 ed ff ff       	call   8011a6 <sys_env_set_trapframe>
  8023d2:	85 c0                	test   %eax,%eax
  8023d4:	79 20                	jns    8023f6 <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  8023d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023da:	c7 44 24 08 0c 34 80 	movl   $0x80340c,0x8(%esp)
  8023e1:	00 
  8023e2:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8023e9:	00 
  8023ea:	c7 04 24 e3 33 80 00 	movl   $0x8033e3,(%esp)
  8023f1:	e8 ae e1 ff ff       	call   8005a4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8023f6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8023fd:	00 
  8023fe:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802404:	89 04 24             	mov    %eax,(%esp)
  802407:	e8 47 ed ff ff       	call   801153 <sys_env_set_status>
  80240c:	85 c0                	test   %eax,%eax
  80240e:	79 5a                	jns    80246a <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  802410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802414:	c7 44 24 08 bc 32 80 	movl   $0x8032bc,0x8(%esp)
  80241b:	00 
  80241c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802423:	00 
  802424:	c7 04 24 e3 33 80 00 	movl   $0x8033e3,(%esp)
  80242b:	e8 74 e1 ff ff       	call   8005a4 <_panic>
  802430:	89 c6                	mov    %eax,%esi
  802432:	eb 06                	jmp    80243a <spawn+0x50e>
  802434:	89 c6                	mov    %eax,%esi
  802436:	eb 02                	jmp    80243a <spawn+0x50e>
  802438:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  80243a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802440:	89 04 24             	mov    %eax,(%esp)
  802443:	e8 81 eb ff ff       	call   800fc9 <sys_env_destroy>
	close(fd);
  802448:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 2c f4 ff ff       	call   801882 <close>
	return r;
  802456:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  80245c:	eb 0c                	jmp    80246a <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80245e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802464:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80246a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802470:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802476:	5b                   	pop    %ebx
  802477:	5e                   	pop    %esi
  802478:	5f                   	pop    %edi
  802479:	5d                   	pop    %ebp
  80247a:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80247b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802480:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802486:	eb e2                	jmp    80246a <spawn+0x53e>

00802488 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	57                   	push   %edi
  80248c:	56                   	push   %esi
  80248d:	53                   	push   %ebx
  80248e:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802491:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802494:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802499:	eb 03                	jmp    80249e <spawnl+0x16>
		argc++;
  80249b:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80249c:	89 d0                	mov    %edx,%eax
  80249e:	8d 50 04             	lea    0x4(%eax),%edx
  8024a1:	83 38 00             	cmpl   $0x0,(%eax)
  8024a4:	75 f5                	jne    80249b <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8024a6:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8024ad:	83 e0 f0             	and    $0xfffffff0,%eax
  8024b0:	29 c4                	sub    %eax,%esp
  8024b2:	8d 7c 24 17          	lea    0x17(%esp),%edi
  8024b6:	83 e7 f0             	and    $0xfffffff0,%edi
  8024b9:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  8024bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024be:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  8024c0:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  8024c7:	00 

	va_start(vl, arg0);
  8024c8:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8024cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d0:	eb 09                	jmp    8024db <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  8024d2:	40                   	inc    %eax
  8024d3:	8b 1a                	mov    (%edx),%ebx
  8024d5:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8024d8:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8024db:	39 c8                	cmp    %ecx,%eax
  8024dd:	75 f3                	jne    8024d2 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8024df:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e6:	89 04 24             	mov    %eax,(%esp)
  8024e9:	e8 3e fa ff ff       	call   801f2c <spawn>
}
  8024ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024f1:	5b                   	pop    %ebx
  8024f2:	5e                   	pop    %esi
  8024f3:	5f                   	pop    %edi
  8024f4:	5d                   	pop    %ebp
  8024f5:	c3                   	ret    
	...

008024f8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	56                   	push   %esi
  8024fc:	53                   	push   %ebx
  8024fd:	83 ec 10             	sub    $0x10,%esp
  802500:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802503:	8b 45 08             	mov    0x8(%ebp),%eax
  802506:	89 04 24             	mov    %eax,(%esp)
  802509:	e8 ce f1 ff ff       	call   8016dc <fd2data>
  80250e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802510:	c7 44 24 04 4e 34 80 	movl   $0x80344e,0x4(%esp)
  802517:	00 
  802518:	89 34 24             	mov    %esi,(%esp)
  80251b:	e8 47 e7 ff ff       	call   800c67 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802520:	8b 43 04             	mov    0x4(%ebx),%eax
  802523:	2b 03                	sub    (%ebx),%eax
  802525:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80252b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802532:	00 00 00 
	stat->st_dev = &devpipe;
  802535:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  80253c:	40 80 00 
	return 0;
}
  80253f:	b8 00 00 00 00       	mov    $0x0,%eax
  802544:	83 c4 10             	add    $0x10,%esp
  802547:	5b                   	pop    %ebx
  802548:	5e                   	pop    %esi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    

0080254b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80254b:	55                   	push   %ebp
  80254c:	89 e5                	mov    %esp,%ebp
  80254e:	53                   	push   %ebx
  80254f:	83 ec 14             	sub    $0x14,%esp
  802552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802555:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802559:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802560:	e8 9b eb ff ff       	call   801100 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802565:	89 1c 24             	mov    %ebx,(%esp)
  802568:	e8 6f f1 ff ff       	call   8016dc <fd2data>
  80256d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802571:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802578:	e8 83 eb ff ff       	call   801100 <sys_page_unmap>
}
  80257d:	83 c4 14             	add    $0x14,%esp
  802580:	5b                   	pop    %ebx
  802581:	5d                   	pop    %ebp
  802582:	c3                   	ret    

00802583 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802583:	55                   	push   %ebp
  802584:	89 e5                	mov    %esp,%ebp
  802586:	57                   	push   %edi
  802587:	56                   	push   %esi
  802588:	53                   	push   %ebx
  802589:	83 ec 2c             	sub    $0x2c,%esp
  80258c:	89 c7                	mov    %eax,%edi
  80258e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802591:	a1 04 50 80 00       	mov    0x805004,%eax
  802596:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802599:	89 3c 24             	mov    %edi,(%esp)
  80259c:	e8 17 05 00 00       	call   802ab8 <pageref>
  8025a1:	89 c6                	mov    %eax,%esi
  8025a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025a6:	89 04 24             	mov    %eax,(%esp)
  8025a9:	e8 0a 05 00 00       	call   802ab8 <pageref>
  8025ae:	39 c6                	cmp    %eax,%esi
  8025b0:	0f 94 c0             	sete   %al
  8025b3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8025b6:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8025bc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8025bf:	39 cb                	cmp    %ecx,%ebx
  8025c1:	75 08                	jne    8025cb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8025c3:	83 c4 2c             	add    $0x2c,%esp
  8025c6:	5b                   	pop    %ebx
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8025cb:	83 f8 01             	cmp    $0x1,%eax
  8025ce:	75 c1                	jne    802591 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8025d0:	8b 42 58             	mov    0x58(%edx),%eax
  8025d3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8025da:	00 
  8025db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025e3:	c7 04 24 55 34 80 00 	movl   $0x803455,(%esp)
  8025ea:	e8 ad e0 ff ff       	call   80069c <cprintf>
  8025ef:	eb a0                	jmp    802591 <_pipeisclosed+0xe>

008025f1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	57                   	push   %edi
  8025f5:	56                   	push   %esi
  8025f6:	53                   	push   %ebx
  8025f7:	83 ec 1c             	sub    $0x1c,%esp
  8025fa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8025fd:	89 34 24             	mov    %esi,(%esp)
  802600:	e8 d7 f0 ff ff       	call   8016dc <fd2data>
  802605:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802607:	bf 00 00 00 00       	mov    $0x0,%edi
  80260c:	eb 3c                	jmp    80264a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80260e:	89 da                	mov    %ebx,%edx
  802610:	89 f0                	mov    %esi,%eax
  802612:	e8 6c ff ff ff       	call   802583 <_pipeisclosed>
  802617:	85 c0                	test   %eax,%eax
  802619:	75 38                	jne    802653 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80261b:	e8 1a ea ff ff       	call   80103a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802620:	8b 43 04             	mov    0x4(%ebx),%eax
  802623:	8b 13                	mov    (%ebx),%edx
  802625:	83 c2 20             	add    $0x20,%edx
  802628:	39 d0                	cmp    %edx,%eax
  80262a:	73 e2                	jae    80260e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80262c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80262f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802632:	89 c2                	mov    %eax,%edx
  802634:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80263a:	79 05                	jns    802641 <devpipe_write+0x50>
  80263c:	4a                   	dec    %edx
  80263d:	83 ca e0             	or     $0xffffffe0,%edx
  802640:	42                   	inc    %edx
  802641:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802645:	40                   	inc    %eax
  802646:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802649:	47                   	inc    %edi
  80264a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80264d:	75 d1                	jne    802620 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80264f:	89 f8                	mov    %edi,%eax
  802651:	eb 05                	jmp    802658 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802653:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802658:	83 c4 1c             	add    $0x1c,%esp
  80265b:	5b                   	pop    %ebx
  80265c:	5e                   	pop    %esi
  80265d:	5f                   	pop    %edi
  80265e:	5d                   	pop    %ebp
  80265f:	c3                   	ret    

00802660 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	57                   	push   %edi
  802664:	56                   	push   %esi
  802665:	53                   	push   %ebx
  802666:	83 ec 1c             	sub    $0x1c,%esp
  802669:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80266c:	89 3c 24             	mov    %edi,(%esp)
  80266f:	e8 68 f0 ff ff       	call   8016dc <fd2data>
  802674:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802676:	be 00 00 00 00       	mov    $0x0,%esi
  80267b:	eb 3a                	jmp    8026b7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80267d:	85 f6                	test   %esi,%esi
  80267f:	74 04                	je     802685 <devpipe_read+0x25>
				return i;
  802681:	89 f0                	mov    %esi,%eax
  802683:	eb 40                	jmp    8026c5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802685:	89 da                	mov    %ebx,%edx
  802687:	89 f8                	mov    %edi,%eax
  802689:	e8 f5 fe ff ff       	call   802583 <_pipeisclosed>
  80268e:	85 c0                	test   %eax,%eax
  802690:	75 2e                	jne    8026c0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802692:	e8 a3 e9 ff ff       	call   80103a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802697:	8b 03                	mov    (%ebx),%eax
  802699:	3b 43 04             	cmp    0x4(%ebx),%eax
  80269c:	74 df                	je     80267d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80269e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8026a3:	79 05                	jns    8026aa <devpipe_read+0x4a>
  8026a5:	48                   	dec    %eax
  8026a6:	83 c8 e0             	or     $0xffffffe0,%eax
  8026a9:	40                   	inc    %eax
  8026aa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8026ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026b1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8026b4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026b6:	46                   	inc    %esi
  8026b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8026ba:	75 db                	jne    802697 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8026bc:	89 f0                	mov    %esi,%eax
  8026be:	eb 05                	jmp    8026c5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8026c0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8026c5:	83 c4 1c             	add    $0x1c,%esp
  8026c8:	5b                   	pop    %ebx
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	5d                   	pop    %ebp
  8026cc:	c3                   	ret    

008026cd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8026cd:	55                   	push   %ebp
  8026ce:	89 e5                	mov    %esp,%ebp
  8026d0:	57                   	push   %edi
  8026d1:	56                   	push   %esi
  8026d2:	53                   	push   %ebx
  8026d3:	83 ec 3c             	sub    $0x3c,%esp
  8026d6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8026d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8026dc:	89 04 24             	mov    %eax,(%esp)
  8026df:	e8 13 f0 ff ff       	call   8016f7 <fd_alloc>
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	85 c0                	test   %eax,%eax
  8026e8:	0f 88 45 01 00 00    	js     802833 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026f5:	00 
  8026f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802704:	e8 50 e9 ff ff       	call   801059 <sys_page_alloc>
  802709:	89 c3                	mov    %eax,%ebx
  80270b:	85 c0                	test   %eax,%eax
  80270d:	0f 88 20 01 00 00    	js     802833 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802713:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802716:	89 04 24             	mov    %eax,(%esp)
  802719:	e8 d9 ef ff ff       	call   8016f7 <fd_alloc>
  80271e:	89 c3                	mov    %eax,%ebx
  802720:	85 c0                	test   %eax,%eax
  802722:	0f 88 f8 00 00 00    	js     802820 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802728:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80272f:	00 
  802730:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802733:	89 44 24 04          	mov    %eax,0x4(%esp)
  802737:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80273e:	e8 16 e9 ff ff       	call   801059 <sys_page_alloc>
  802743:	89 c3                	mov    %eax,%ebx
  802745:	85 c0                	test   %eax,%eax
  802747:	0f 88 d3 00 00 00    	js     802820 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80274d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802750:	89 04 24             	mov    %eax,(%esp)
  802753:	e8 84 ef ff ff       	call   8016dc <fd2data>
  802758:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80275a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802761:	00 
  802762:	89 44 24 04          	mov    %eax,0x4(%esp)
  802766:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80276d:	e8 e7 e8 ff ff       	call   801059 <sys_page_alloc>
  802772:	89 c3                	mov    %eax,%ebx
  802774:	85 c0                	test   %eax,%eax
  802776:	0f 88 91 00 00 00    	js     80280d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80277c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80277f:	89 04 24             	mov    %eax,(%esp)
  802782:	e8 55 ef ff ff       	call   8016dc <fd2data>
  802787:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80278e:	00 
  80278f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802793:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80279a:	00 
  80279b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80279f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027a6:	e8 02 e9 ff ff       	call   8010ad <sys_page_map>
  8027ab:	89 c3                	mov    %eax,%ebx
  8027ad:	85 c0                	test   %eax,%eax
  8027af:	78 4c                	js     8027fd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8027b1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8027b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027ba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8027bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8027c6:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8027cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027cf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8027d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027d4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8027db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027de:	89 04 24             	mov    %eax,(%esp)
  8027e1:	e8 e6 ee ff ff       	call   8016cc <fd2num>
  8027e6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8027e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027eb:	89 04 24             	mov    %eax,(%esp)
  8027ee:	e8 d9 ee ff ff       	call   8016cc <fd2num>
  8027f3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8027f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027fb:	eb 36                	jmp    802833 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8027fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  802801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802808:	e8 f3 e8 ff ff       	call   801100 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80280d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802810:	89 44 24 04          	mov    %eax,0x4(%esp)
  802814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80281b:	e8 e0 e8 ff ff       	call   801100 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802823:	89 44 24 04          	mov    %eax,0x4(%esp)
  802827:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80282e:	e8 cd e8 ff ff       	call   801100 <sys_page_unmap>
    err:
	return r;
}
  802833:	89 d8                	mov    %ebx,%eax
  802835:	83 c4 3c             	add    $0x3c,%esp
  802838:	5b                   	pop    %ebx
  802839:	5e                   	pop    %esi
  80283a:	5f                   	pop    %edi
  80283b:	5d                   	pop    %ebp
  80283c:	c3                   	ret    

0080283d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80283d:	55                   	push   %ebp
  80283e:	89 e5                	mov    %esp,%ebp
  802840:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80284a:	8b 45 08             	mov    0x8(%ebp),%eax
  80284d:	89 04 24             	mov    %eax,(%esp)
  802850:	e8 f5 ee ff ff       	call   80174a <fd_lookup>
  802855:	85 c0                	test   %eax,%eax
  802857:	78 15                	js     80286e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80285c:	89 04 24             	mov    %eax,(%esp)
  80285f:	e8 78 ee ff ff       	call   8016dc <fd2data>
	return _pipeisclosed(fd, p);
  802864:	89 c2                	mov    %eax,%edx
  802866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802869:	e8 15 fd ff ff       	call   802583 <_pipeisclosed>
}
  80286e:	c9                   	leave  
  80286f:	c3                   	ret    

00802870 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802870:	55                   	push   %ebp
  802871:	89 e5                	mov    %esp,%ebp
  802873:	56                   	push   %esi
  802874:	53                   	push   %ebx
  802875:	83 ec 10             	sub    $0x10,%esp
  802878:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80287b:	85 f6                	test   %esi,%esi
  80287d:	75 24                	jne    8028a3 <wait+0x33>
  80287f:	c7 44 24 0c 6d 34 80 	movl   $0x80346d,0xc(%esp)
  802886:	00 
  802887:	c7 44 24 08 a8 33 80 	movl   $0x8033a8,0x8(%esp)
  80288e:	00 
  80288f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802896:	00 
  802897:	c7 04 24 78 34 80 00 	movl   $0x803478,(%esp)
  80289e:	e8 01 dd ff ff       	call   8005a4 <_panic>
	e = &envs[ENVX(envid)];
  8028a3:	89 f3                	mov    %esi,%ebx
  8028a5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8028ab:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8028b2:	c1 e3 07             	shl    $0x7,%ebx
  8028b5:	29 c3                	sub    %eax,%ebx
  8028b7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8028bd:	eb 05                	jmp    8028c4 <wait+0x54>
		sys_yield();
  8028bf:	e8 76 e7 ff ff       	call   80103a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8028c4:	8b 43 48             	mov    0x48(%ebx),%eax
  8028c7:	39 f0                	cmp    %esi,%eax
  8028c9:	75 07                	jne    8028d2 <wait+0x62>
  8028cb:	8b 43 54             	mov    0x54(%ebx),%eax
  8028ce:	85 c0                	test   %eax,%eax
  8028d0:	75 ed                	jne    8028bf <wait+0x4f>
		sys_yield();
}
  8028d2:	83 c4 10             	add    $0x10,%esp
  8028d5:	5b                   	pop    %ebx
  8028d6:	5e                   	pop    %esi
  8028d7:	5d                   	pop    %ebp
  8028d8:	c3                   	ret    
  8028d9:	00 00                	add    %al,(%eax)
	...

008028dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028dc:	55                   	push   %ebp
  8028dd:	89 e5                	mov    %esp,%ebp
  8028df:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028e2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8028e9:	0f 85 80 00 00 00    	jne    80296f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8028ef:	a1 04 50 80 00       	mov    0x805004,%eax
  8028f4:	8b 40 48             	mov    0x48(%eax),%eax
  8028f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8028fe:	00 
  8028ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802906:	ee 
  802907:	89 04 24             	mov    %eax,(%esp)
  80290a:	e8 4a e7 ff ff       	call   801059 <sys_page_alloc>
  80290f:	85 c0                	test   %eax,%eax
  802911:	79 20                	jns    802933 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  802913:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802917:	c7 44 24 08 84 34 80 	movl   $0x803484,0x8(%esp)
  80291e:	00 
  80291f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802926:	00 
  802927:	c7 04 24 e0 34 80 00 	movl   $0x8034e0,(%esp)
  80292e:	e8 71 dc ff ff       	call   8005a4 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  802933:	a1 04 50 80 00       	mov    0x805004,%eax
  802938:	8b 40 48             	mov    0x48(%eax),%eax
  80293b:	c7 44 24 04 7c 29 80 	movl   $0x80297c,0x4(%esp)
  802942:	00 
  802943:	89 04 24             	mov    %eax,(%esp)
  802946:	e8 ae e8 ff ff       	call   8011f9 <sys_env_set_pgfault_upcall>
  80294b:	85 c0                	test   %eax,%eax
  80294d:	79 20                	jns    80296f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80294f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802953:	c7 44 24 08 b0 34 80 	movl   $0x8034b0,0x8(%esp)
  80295a:	00 
  80295b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  802962:	00 
  802963:	c7 04 24 e0 34 80 00 	movl   $0x8034e0,(%esp)
  80296a:	e8 35 dc ff ff       	call   8005a4 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80296f:	8b 45 08             	mov    0x8(%ebp),%eax
  802972:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802977:	c9                   	leave  
  802978:	c3                   	ret    
  802979:	00 00                	add    %al,(%eax)
	...

0080297c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80297c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80297d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802982:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802984:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802987:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80298b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80298d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802990:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802991:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802994:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  802996:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802999:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80299a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80299d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80299e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80299f:	c3                   	ret    

008029a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	56                   	push   %esi
  8029a4:	53                   	push   %ebx
  8029a5:	83 ec 10             	sub    $0x10,%esp
  8029a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8029ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8029b1:	85 c0                	test   %eax,%eax
  8029b3:	75 05                	jne    8029ba <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8029b5:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8029ba:	89 04 24             	mov    %eax,(%esp)
  8029bd:	e8 ad e8 ff ff       	call   80126f <sys_ipc_recv>
	if (!err) {
  8029c2:	85 c0                	test   %eax,%eax
  8029c4:	75 26                	jne    8029ec <ipc_recv+0x4c>
		if (from_env_store) {
  8029c6:	85 f6                	test   %esi,%esi
  8029c8:	74 0a                	je     8029d4 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8029ca:	a1 04 50 80 00       	mov    0x805004,%eax
  8029cf:	8b 40 74             	mov    0x74(%eax),%eax
  8029d2:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8029d4:	85 db                	test   %ebx,%ebx
  8029d6:	74 0a                	je     8029e2 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8029d8:	a1 04 50 80 00       	mov    0x805004,%eax
  8029dd:	8b 40 78             	mov    0x78(%eax),%eax
  8029e0:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8029e2:	a1 04 50 80 00       	mov    0x805004,%eax
  8029e7:	8b 40 70             	mov    0x70(%eax),%eax
  8029ea:	eb 14                	jmp    802a00 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8029ec:	85 f6                	test   %esi,%esi
  8029ee:	74 06                	je     8029f6 <ipc_recv+0x56>
		*from_env_store = 0;
  8029f0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8029f6:	85 db                	test   %ebx,%ebx
  8029f8:	74 06                	je     802a00 <ipc_recv+0x60>
		*perm_store = 0;
  8029fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802a00:	83 c4 10             	add    $0x10,%esp
  802a03:	5b                   	pop    %ebx
  802a04:	5e                   	pop    %esi
  802a05:	5d                   	pop    %ebp
  802a06:	c3                   	ret    

00802a07 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a07:	55                   	push   %ebp
  802a08:	89 e5                	mov    %esp,%ebp
  802a0a:	57                   	push   %edi
  802a0b:	56                   	push   %esi
  802a0c:	53                   	push   %ebx
  802a0d:	83 ec 1c             	sub    $0x1c,%esp
  802a10:	8b 75 10             	mov    0x10(%ebp),%esi
  802a13:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802a16:	85 f6                	test   %esi,%esi
  802a18:	75 05                	jne    802a1f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802a1a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  802a1f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a23:	89 74 24 08          	mov    %esi,0x8(%esp)
  802a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  802a31:	89 04 24             	mov    %eax,(%esp)
  802a34:	e8 13 e8 ff ff       	call   80124c <sys_ipc_try_send>
  802a39:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802a3b:	e8 fa e5 ff ff       	call   80103a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802a40:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802a43:	74 da                	je     802a1f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802a45:	85 db                	test   %ebx,%ebx
  802a47:	74 20                	je     802a69 <ipc_send+0x62>
		panic("send fail: %e", err);
  802a49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802a4d:	c7 44 24 08 ee 34 80 	movl   $0x8034ee,0x8(%esp)
  802a54:	00 
  802a55:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802a5c:	00 
  802a5d:	c7 04 24 fc 34 80 00 	movl   $0x8034fc,(%esp)
  802a64:	e8 3b db ff ff       	call   8005a4 <_panic>
	}
	return;
}
  802a69:	83 c4 1c             	add    $0x1c,%esp
  802a6c:	5b                   	pop    %ebx
  802a6d:	5e                   	pop    %esi
  802a6e:	5f                   	pop    %edi
  802a6f:	5d                   	pop    %ebp
  802a70:	c3                   	ret    

00802a71 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a71:	55                   	push   %ebp
  802a72:	89 e5                	mov    %esp,%ebp
  802a74:	53                   	push   %ebx
  802a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802a78:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a7d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802a84:	89 c2                	mov    %eax,%edx
  802a86:	c1 e2 07             	shl    $0x7,%edx
  802a89:	29 ca                	sub    %ecx,%edx
  802a8b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a91:	8b 52 50             	mov    0x50(%edx),%edx
  802a94:	39 da                	cmp    %ebx,%edx
  802a96:	75 0f                	jne    802aa7 <ipc_find_env+0x36>
			return envs[i].env_id;
  802a98:	c1 e0 07             	shl    $0x7,%eax
  802a9b:	29 c8                	sub    %ecx,%eax
  802a9d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802aa2:	8b 40 40             	mov    0x40(%eax),%eax
  802aa5:	eb 0c                	jmp    802ab3 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802aa7:	40                   	inc    %eax
  802aa8:	3d 00 04 00 00       	cmp    $0x400,%eax
  802aad:	75 ce                	jne    802a7d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802aaf:	66 b8 00 00          	mov    $0x0,%ax
}
  802ab3:	5b                   	pop    %ebx
  802ab4:	5d                   	pop    %ebp
  802ab5:	c3                   	ret    
	...

00802ab8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ab8:	55                   	push   %ebp
  802ab9:	89 e5                	mov    %esp,%ebp
  802abb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802abe:	89 c2                	mov    %eax,%edx
  802ac0:	c1 ea 16             	shr    $0x16,%edx
  802ac3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802aca:	f6 c2 01             	test   $0x1,%dl
  802acd:	74 1e                	je     802aed <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802acf:	c1 e8 0c             	shr    $0xc,%eax
  802ad2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ad9:	a8 01                	test   $0x1,%al
  802adb:	74 17                	je     802af4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802add:	c1 e8 0c             	shr    $0xc,%eax
  802ae0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802ae7:	ef 
  802ae8:	0f b7 c0             	movzwl %ax,%eax
  802aeb:	eb 0c                	jmp    802af9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802aed:	b8 00 00 00 00       	mov    $0x0,%eax
  802af2:	eb 05                	jmp    802af9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802af4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802af9:	5d                   	pop    %ebp
  802afa:	c3                   	ret    
	...

00802afc <__udivdi3>:
  802afc:	55                   	push   %ebp
  802afd:	57                   	push   %edi
  802afe:	56                   	push   %esi
  802aff:	83 ec 10             	sub    $0x10,%esp
  802b02:	8b 74 24 20          	mov    0x20(%esp),%esi
  802b06:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802b0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b0e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802b12:	89 cd                	mov    %ecx,%ebp
  802b14:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802b18:	85 c0                	test   %eax,%eax
  802b1a:	75 2c                	jne    802b48 <__udivdi3+0x4c>
  802b1c:	39 f9                	cmp    %edi,%ecx
  802b1e:	77 68                	ja     802b88 <__udivdi3+0x8c>
  802b20:	85 c9                	test   %ecx,%ecx
  802b22:	75 0b                	jne    802b2f <__udivdi3+0x33>
  802b24:	b8 01 00 00 00       	mov    $0x1,%eax
  802b29:	31 d2                	xor    %edx,%edx
  802b2b:	f7 f1                	div    %ecx
  802b2d:	89 c1                	mov    %eax,%ecx
  802b2f:	31 d2                	xor    %edx,%edx
  802b31:	89 f8                	mov    %edi,%eax
  802b33:	f7 f1                	div    %ecx
  802b35:	89 c7                	mov    %eax,%edi
  802b37:	89 f0                	mov    %esi,%eax
  802b39:	f7 f1                	div    %ecx
  802b3b:	89 c6                	mov    %eax,%esi
  802b3d:	89 f0                	mov    %esi,%eax
  802b3f:	89 fa                	mov    %edi,%edx
  802b41:	83 c4 10             	add    $0x10,%esp
  802b44:	5e                   	pop    %esi
  802b45:	5f                   	pop    %edi
  802b46:	5d                   	pop    %ebp
  802b47:	c3                   	ret    
  802b48:	39 f8                	cmp    %edi,%eax
  802b4a:	77 2c                	ja     802b78 <__udivdi3+0x7c>
  802b4c:	0f bd f0             	bsr    %eax,%esi
  802b4f:	83 f6 1f             	xor    $0x1f,%esi
  802b52:	75 4c                	jne    802ba0 <__udivdi3+0xa4>
  802b54:	39 f8                	cmp    %edi,%eax
  802b56:	bf 00 00 00 00       	mov    $0x0,%edi
  802b5b:	72 0a                	jb     802b67 <__udivdi3+0x6b>
  802b5d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802b61:	0f 87 ad 00 00 00    	ja     802c14 <__udivdi3+0x118>
  802b67:	be 01 00 00 00       	mov    $0x1,%esi
  802b6c:	89 f0                	mov    %esi,%eax
  802b6e:	89 fa                	mov    %edi,%edx
  802b70:	83 c4 10             	add    $0x10,%esp
  802b73:	5e                   	pop    %esi
  802b74:	5f                   	pop    %edi
  802b75:	5d                   	pop    %ebp
  802b76:	c3                   	ret    
  802b77:	90                   	nop
  802b78:	31 ff                	xor    %edi,%edi
  802b7a:	31 f6                	xor    %esi,%esi
  802b7c:	89 f0                	mov    %esi,%eax
  802b7e:	89 fa                	mov    %edi,%edx
  802b80:	83 c4 10             	add    $0x10,%esp
  802b83:	5e                   	pop    %esi
  802b84:	5f                   	pop    %edi
  802b85:	5d                   	pop    %ebp
  802b86:	c3                   	ret    
  802b87:	90                   	nop
  802b88:	89 fa                	mov    %edi,%edx
  802b8a:	89 f0                	mov    %esi,%eax
  802b8c:	f7 f1                	div    %ecx
  802b8e:	89 c6                	mov    %eax,%esi
  802b90:	31 ff                	xor    %edi,%edi
  802b92:	89 f0                	mov    %esi,%eax
  802b94:	89 fa                	mov    %edi,%edx
  802b96:	83 c4 10             	add    $0x10,%esp
  802b99:	5e                   	pop    %esi
  802b9a:	5f                   	pop    %edi
  802b9b:	5d                   	pop    %ebp
  802b9c:	c3                   	ret    
  802b9d:	8d 76 00             	lea    0x0(%esi),%esi
  802ba0:	89 f1                	mov    %esi,%ecx
  802ba2:	d3 e0                	shl    %cl,%eax
  802ba4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ba8:	b8 20 00 00 00       	mov    $0x20,%eax
  802bad:	29 f0                	sub    %esi,%eax
  802baf:	89 ea                	mov    %ebp,%edx
  802bb1:	88 c1                	mov    %al,%cl
  802bb3:	d3 ea                	shr    %cl,%edx
  802bb5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802bb9:	09 ca                	or     %ecx,%edx
  802bbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  802bbf:	89 f1                	mov    %esi,%ecx
  802bc1:	d3 e5                	shl    %cl,%ebp
  802bc3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802bc7:	89 fd                	mov    %edi,%ebp
  802bc9:	88 c1                	mov    %al,%cl
  802bcb:	d3 ed                	shr    %cl,%ebp
  802bcd:	89 fa                	mov    %edi,%edx
  802bcf:	89 f1                	mov    %esi,%ecx
  802bd1:	d3 e2                	shl    %cl,%edx
  802bd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802bd7:	88 c1                	mov    %al,%cl
  802bd9:	d3 ef                	shr    %cl,%edi
  802bdb:	09 d7                	or     %edx,%edi
  802bdd:	89 f8                	mov    %edi,%eax
  802bdf:	89 ea                	mov    %ebp,%edx
  802be1:	f7 74 24 08          	divl   0x8(%esp)
  802be5:	89 d1                	mov    %edx,%ecx
  802be7:	89 c7                	mov    %eax,%edi
  802be9:	f7 64 24 0c          	mull   0xc(%esp)
  802bed:	39 d1                	cmp    %edx,%ecx
  802bef:	72 17                	jb     802c08 <__udivdi3+0x10c>
  802bf1:	74 09                	je     802bfc <__udivdi3+0x100>
  802bf3:	89 fe                	mov    %edi,%esi
  802bf5:	31 ff                	xor    %edi,%edi
  802bf7:	e9 41 ff ff ff       	jmp    802b3d <__udivdi3+0x41>
  802bfc:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c00:	89 f1                	mov    %esi,%ecx
  802c02:	d3 e2                	shl    %cl,%edx
  802c04:	39 c2                	cmp    %eax,%edx
  802c06:	73 eb                	jae    802bf3 <__udivdi3+0xf7>
  802c08:	8d 77 ff             	lea    -0x1(%edi),%esi
  802c0b:	31 ff                	xor    %edi,%edi
  802c0d:	e9 2b ff ff ff       	jmp    802b3d <__udivdi3+0x41>
  802c12:	66 90                	xchg   %ax,%ax
  802c14:	31 f6                	xor    %esi,%esi
  802c16:	e9 22 ff ff ff       	jmp    802b3d <__udivdi3+0x41>
	...

00802c1c <__umoddi3>:
  802c1c:	55                   	push   %ebp
  802c1d:	57                   	push   %edi
  802c1e:	56                   	push   %esi
  802c1f:	83 ec 20             	sub    $0x20,%esp
  802c22:	8b 44 24 30          	mov    0x30(%esp),%eax
  802c26:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802c2a:	89 44 24 14          	mov    %eax,0x14(%esp)
  802c2e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c32:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c36:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802c3a:	89 c7                	mov    %eax,%edi
  802c3c:	89 f2                	mov    %esi,%edx
  802c3e:	85 ed                	test   %ebp,%ebp
  802c40:	75 16                	jne    802c58 <__umoddi3+0x3c>
  802c42:	39 f1                	cmp    %esi,%ecx
  802c44:	0f 86 a6 00 00 00    	jbe    802cf0 <__umoddi3+0xd4>
  802c4a:	f7 f1                	div    %ecx
  802c4c:	89 d0                	mov    %edx,%eax
  802c4e:	31 d2                	xor    %edx,%edx
  802c50:	83 c4 20             	add    $0x20,%esp
  802c53:	5e                   	pop    %esi
  802c54:	5f                   	pop    %edi
  802c55:	5d                   	pop    %ebp
  802c56:	c3                   	ret    
  802c57:	90                   	nop
  802c58:	39 f5                	cmp    %esi,%ebp
  802c5a:	0f 87 ac 00 00 00    	ja     802d0c <__umoddi3+0xf0>
  802c60:	0f bd c5             	bsr    %ebp,%eax
  802c63:	83 f0 1f             	xor    $0x1f,%eax
  802c66:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c6a:	0f 84 a8 00 00 00    	je     802d18 <__umoddi3+0xfc>
  802c70:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c74:	d3 e5                	shl    %cl,%ebp
  802c76:	bf 20 00 00 00       	mov    $0x20,%edi
  802c7b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802c7f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c83:	89 f9                	mov    %edi,%ecx
  802c85:	d3 e8                	shr    %cl,%eax
  802c87:	09 e8                	or     %ebp,%eax
  802c89:	89 44 24 18          	mov    %eax,0x18(%esp)
  802c8d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c91:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c95:	d3 e0                	shl    %cl,%eax
  802c97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c9b:	89 f2                	mov    %esi,%edx
  802c9d:	d3 e2                	shl    %cl,%edx
  802c9f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ca3:	d3 e0                	shl    %cl,%eax
  802ca5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802ca9:	8b 44 24 14          	mov    0x14(%esp),%eax
  802cad:	89 f9                	mov    %edi,%ecx
  802caf:	d3 e8                	shr    %cl,%eax
  802cb1:	09 d0                	or     %edx,%eax
  802cb3:	d3 ee                	shr    %cl,%esi
  802cb5:	89 f2                	mov    %esi,%edx
  802cb7:	f7 74 24 18          	divl   0x18(%esp)
  802cbb:	89 d6                	mov    %edx,%esi
  802cbd:	f7 64 24 0c          	mull   0xc(%esp)
  802cc1:	89 c5                	mov    %eax,%ebp
  802cc3:	89 d1                	mov    %edx,%ecx
  802cc5:	39 d6                	cmp    %edx,%esi
  802cc7:	72 67                	jb     802d30 <__umoddi3+0x114>
  802cc9:	74 75                	je     802d40 <__umoddi3+0x124>
  802ccb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802ccf:	29 e8                	sub    %ebp,%eax
  802cd1:	19 ce                	sbb    %ecx,%esi
  802cd3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802cd7:	d3 e8                	shr    %cl,%eax
  802cd9:	89 f2                	mov    %esi,%edx
  802cdb:	89 f9                	mov    %edi,%ecx
  802cdd:	d3 e2                	shl    %cl,%edx
  802cdf:	09 d0                	or     %edx,%eax
  802ce1:	89 f2                	mov    %esi,%edx
  802ce3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ce7:	d3 ea                	shr    %cl,%edx
  802ce9:	83 c4 20             	add    $0x20,%esp
  802cec:	5e                   	pop    %esi
  802ced:	5f                   	pop    %edi
  802cee:	5d                   	pop    %ebp
  802cef:	c3                   	ret    
  802cf0:	85 c9                	test   %ecx,%ecx
  802cf2:	75 0b                	jne    802cff <__umoddi3+0xe3>
  802cf4:	b8 01 00 00 00       	mov    $0x1,%eax
  802cf9:	31 d2                	xor    %edx,%edx
  802cfb:	f7 f1                	div    %ecx
  802cfd:	89 c1                	mov    %eax,%ecx
  802cff:	89 f0                	mov    %esi,%eax
  802d01:	31 d2                	xor    %edx,%edx
  802d03:	f7 f1                	div    %ecx
  802d05:	89 f8                	mov    %edi,%eax
  802d07:	e9 3e ff ff ff       	jmp    802c4a <__umoddi3+0x2e>
  802d0c:	89 f2                	mov    %esi,%edx
  802d0e:	83 c4 20             	add    $0x20,%esp
  802d11:	5e                   	pop    %esi
  802d12:	5f                   	pop    %edi
  802d13:	5d                   	pop    %ebp
  802d14:	c3                   	ret    
  802d15:	8d 76 00             	lea    0x0(%esi),%esi
  802d18:	39 f5                	cmp    %esi,%ebp
  802d1a:	72 04                	jb     802d20 <__umoddi3+0x104>
  802d1c:	39 f9                	cmp    %edi,%ecx
  802d1e:	77 06                	ja     802d26 <__umoddi3+0x10a>
  802d20:	89 f2                	mov    %esi,%edx
  802d22:	29 cf                	sub    %ecx,%edi
  802d24:	19 ea                	sbb    %ebp,%edx
  802d26:	89 f8                	mov    %edi,%eax
  802d28:	83 c4 20             	add    $0x20,%esp
  802d2b:	5e                   	pop    %esi
  802d2c:	5f                   	pop    %edi
  802d2d:	5d                   	pop    %ebp
  802d2e:	c3                   	ret    
  802d2f:	90                   	nop
  802d30:	89 d1                	mov    %edx,%ecx
  802d32:	89 c5                	mov    %eax,%ebp
  802d34:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802d38:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802d3c:	eb 8d                	jmp    802ccb <__umoddi3+0xaf>
  802d3e:	66 90                	xchg   %ax,%ax
  802d40:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802d44:	72 ea                	jb     802d30 <__umoddi3+0x114>
  802d46:	89 f1                	mov    %esi,%ecx
  802d48:	eb 81                	jmp    802ccb <__umoddi3+0xaf>
