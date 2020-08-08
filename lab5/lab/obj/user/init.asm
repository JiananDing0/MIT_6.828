
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 b3 03 00 00       	call   8003e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	eb 0a                	jmp    800055 <sum+0x21>
		tot ^= i * s[i];
  80004b:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004f:	0f af ca             	imul   %edx,%ecx
  800052:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800054:	42                   	inc    %edx
  800055:	39 da                	cmp    %ebx,%edx
  800057:	7c f2                	jl     80004b <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800059:	5b                   	pop    %ebx
  80005a:	5e                   	pop    %esi
  80005b:	5d                   	pop    %ebp
  80005c:	c3                   	ret    

0080005d <umain>:

void
umain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800069:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006c:	c7 04 24 40 27 80 00 	movl   $0x802740,(%esp)
  800073:	e8 d4 04 00 00       	call   80054c <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <sum>
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 1a                	je     8000ad <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009a:	00 
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 08 28 80 00 	movl   $0x802808,(%esp)
  8000a6:	e8 a1 04 00 00       	call   80054c <cprintf>
  8000ab:	eb 0c                	jmp    8000b9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ad:	c7 04 24 4f 27 80 00 	movl   $0x80274f,(%esp)
  8000b4:	e8 93 04 00 00       	call   80054c <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c0:	00 
  8000c1:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <sum>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 12                	je     8000e3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 44 28 80 00 	movl   $0x802844,(%esp)
  8000dc:	e8 6b 04 00 00       	call   80054c <cprintf>
  8000e1:	eb 0c                	jmp    8000ef <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e3:	c7 04 24 66 27 80 00 	movl   $0x802766,(%esp)
  8000ea:	e8 5d 04 00 00       	call   80054c <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ef:	c7 44 24 04 7c 27 80 	movl   $0x80277c,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 2f 0a 00 00       	call   800b34 <strcat>
	for (i = 0; i < argc; i++) {
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80010a:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800110:	eb 30                	jmp    800142 <umain+0xe5>
		strcat(args, " '");
  800112:	c7 44 24 04 88 27 80 	movl   $0x802788,0x4(%esp)
  800119:	00 
  80011a:	89 34 24             	mov    %esi,(%esp)
  80011d:	e8 12 0a 00 00       	call   800b34 <strcat>
		strcat(args, argv[i]);
  800122:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 03 0a 00 00       	call   800b34 <strcat>
		strcat(args, "'");
  800131:	c7 44 24 04 89 27 80 	movl   $0x802789,0x4(%esp)
  800138:	00 
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 f3 09 00 00       	call   800b34 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800141:	43                   	inc    %ebx
  800142:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800145:	7c cb                	jl     800112 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800147:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 8b 27 80 00 	movl   $0x80278b,(%esp)
  800158:	e8 ef 03 00 00       	call   80054c <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  800164:	e8 e3 03 00 00       	call   80054c <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 b5 11 00 00       	call   80132a <close>
	if ((r = opencons()) < 0)
  800175:	e8 16 02 00 00       	call   800390 <opencons>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 20                	jns    80019e <umain+0x141>
		panic("opencons: %e", r);
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 a1 27 80 	movl   $0x8027a1,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 ae 27 80 00 	movl   $0x8027ae,(%esp)
  800199:	e8 b6 02 00 00       	call   800454 <_panic>
	if (r != 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 20                	je     8001c2 <umain+0x165>
		panic("first opencons used fd %d", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 ba 27 80 	movl   $0x8027ba,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 ae 27 80 00 	movl   $0x8027ae,(%esp)
  8001bd:	e8 92 02 00 00       	call   800454 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d1:	e8 a5 11 00 00       	call   80137b <dup>
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	79 20                	jns    8001fa <umain+0x19d>
		panic("dup: %e", r);
  8001da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001de:	c7 44 24 08 d4 27 80 	movl   $0x8027d4,0x8(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001ed:	00 
  8001ee:	c7 04 24 ae 27 80 00 	movl   $0x8027ae,(%esp)
  8001f5:	e8 5a 02 00 00       	call   800454 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001fa:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800201:	e8 46 03 00 00       	call   80054c <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 f0 27 80 	movl   $0x8027f0,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 ef 27 80 00 	movl   $0x8027ef,(%esp)
  80021d:	e8 0e 1d 00 00       	call   801f30 <spawnl>
		if (r < 0) {
  800222:	85 c0                	test   %eax,%eax
  800224:	79 12                	jns    800238 <umain+0x1db>
			cprintf("init: spawn sh: %e\n", r);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  800231:	e8 16 03 00 00       	call   80054c <cprintf>
			continue;
  800236:	eb c2                	jmp    8001fa <umain+0x19d>
		}
		wait(r);
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 d8 20 00 00       	call   802318 <wait>
  800240:	eb b8                	jmp    8001fa <umain+0x19d>
	...

00800244 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800247:	b8 00 00 00 00       	mov    $0x0,%eax
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800254:	c7 44 24 04 73 28 80 	movl   $0x802873,0x4(%esp)
  80025b:	00 
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 b0 08 00 00       	call   800b17 <strcpy>
	return 0;
}
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80027f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800285:	eb 30                	jmp    8002b7 <devcons_write+0x49>
		m = n - tot;
  800287:	8b 75 10             	mov    0x10(%ebp),%esi
  80028a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80028c:	83 fe 7f             	cmp    $0x7f,%esi
  80028f:	76 05                	jbe    800296 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800291:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800296:	89 74 24 08          	mov    %esi,0x8(%esp)
  80029a:	03 45 0c             	add    0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	89 3c 24             	mov    %edi,(%esp)
  8002a4:	e8 e7 09 00 00       	call   800c90 <memmove>
		sys_cputs(buf, m);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	89 3c 24             	mov    %edi,(%esp)
  8002b0:	e8 87 0b 00 00       	call   800e3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002b5:	01 f3                	add    %esi,%ebx
  8002b7:	89 d8                	mov    %ebx,%eax
  8002b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002bc:	72 c9                	jb     800287 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002d3:	75 07                	jne    8002dc <devcons_read+0x13>
  8002d5:	eb 25                	jmp    8002fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002d7:	e8 0e 0c 00 00       	call   800eea <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002dc:	e8 79 0b 00 00       	call   800e5a <sys_cgetc>
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	74 f2                	je     8002d7 <devcons_read+0xe>
  8002e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	78 1d                	js     800308 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002eb:	83 f8 04             	cmp    $0x4,%eax
  8002ee:	74 13                	je     800303 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8002f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8002fa:	eb 0c                	jmp    800308 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	eb 05                	jmp    800308 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031d:	00 
  80031e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 13 0b 00 00       	call   800e3c <sys_cputs>
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <getchar>:

int
getchar(void)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800347:	e8 42 11 00 00       	call   80148e <read>
	if (r < 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	78 0f                	js     80035f <getchar+0x34>
		return r;
	if (r < 1)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 06                	jle    80035a <getchar+0x2f>
		return -E_EOF;
	return c;
  800354:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800358:	eb 05                	jmp    80035f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80035a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	e8 79 0e 00 00       	call   8011f2 <fd_lookup>
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 11                	js     80038e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800386:	39 10                	cmp    %edx,(%eax)
  800388:	0f 94 c0             	sete   %al
  80038b:	0f b6 c0             	movzbl %al,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <opencons>:

int
opencons(void)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 fe 0d 00 00       	call   80119f <fd_alloc>
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	78 3c                	js     8003e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003bb:	e8 49 0b 00 00       	call   800f09 <sys_page_alloc>
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	78 1d                	js     8003e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003c4:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	e8 93 0d 00 00       	call   801174 <fd2num>
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    
	...

008003e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 10             	sub    $0x10,%esp
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8003f2:	e8 d4 0a 00 00       	call   800ecb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8003f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800403:	c1 e0 07             	shl    $0x7,%eax
  800406:	29 d0                	sub    %edx,%eax
  800408:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80040d:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800412:	85 f6                	test   %esi,%esi
  800414:	7e 07                	jle    80041d <libmain+0x39>
		binaryname = argv[0];
  800416:	8b 03                	mov    (%ebx),%eax
  800418:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	89 34 24             	mov    %esi,(%esp)
  800424:	e8 34 fc ff ff       	call   80005d <umain>

	// exit gracefully
	exit();
  800429:	e8 0a 00 00 00       	call   800438 <exit>
}
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
  800435:	00 00                	add    %al,(%eax)
	...

00800438 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80043e:	e8 18 0f 00 00       	call   80135b <close_all>
	sys_env_destroy(0);
  800443:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80044a:	e8 2a 0a 00 00       	call   800e79 <sys_env_destroy>
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    
  800451:	00 00                	add    %al,(%eax)
	...

00800454 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80045c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045f:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  800465:	e8 61 0a 00 00       	call   800ecb <sys_getenvid>
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  800487:	e8 c0 00 00 00       	call   80054c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 50 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  80049b:	c7 04 24 80 2d 80 00 	movl   $0x802d80,(%esp)
  8004a2:	e8 a5 00 00 00       	call   80054c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x53>
	...

008004ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 14             	sub    $0x14,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b6:	8b 03                	mov    (%ebx),%eax
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bf:	40                   	inc    %eax
  8004c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c7:	75 19                	jne    8004e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d0:	00 
  8004d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 60 09 00 00       	call   800e3c <sys_cputs>
		b->idx = 0;
  8004dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e2:	ff 43 04             	incl   0x4(%ebx)
}
  8004e5:	83 c4 14             	add    $0x14,%esp
  8004e8:	5b                   	pop    %ebx
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 ac 04 80 00 	movl   $0x8004ac,(%esp)
  800527:	e8 82 01 00 00       	call   8006ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 f8 08 00 00       	call   800e3c <sys_cputs>

	return b.cnt;
}
  800544:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800552:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 87 ff ff ff       	call   8004eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 3c             	sub    $0x3c,%esp
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	89 d7                	mov    %edx,%edi
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80057c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800585:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	85 c0                	test   %eax,%eax
  80058a:	75 08                	jne    800594 <printnum+0x2c>
  80058c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800592:	77 57                	ja     8005eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800594:	89 74 24 10          	mov    %esi,0x10(%esp)
  800598:	4b                   	dec    %ebx
  800599:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059d:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b3:	00 
  8005b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	e8 1a 1f 00 00       	call   8024e0 <__udivdi3>
  8005c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d5:	89 fa                	mov    %edi,%edx
  8005d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005da:	e8 89 ff ff ff       	call   800568 <printnum>
  8005df:	eb 0f                	jmp    8005f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e5:	89 34 24             	mov    %esi,(%esp)
  8005e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800606:	00 
  800607:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	e8 e7 1f 00 00       	call   802600 <__umoddi3>
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	0f be 80 af 28 80 00 	movsbl 0x8028af(%eax),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062a:	83 c4 3c             	add    $0x3c,%esp
  80062d:	5b                   	pop    %ebx
  80062e:	5e                   	pop    %esi
  80062f:	5f                   	pop    %edi
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800635:	83 fa 01             	cmp    $0x1,%edx
  800638:	7e 0e                	jle    800648 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063f:	89 08                	mov    %ecx,(%eax)
  800641:	8b 02                	mov    (%edx),%eax
  800643:	8b 52 04             	mov    0x4(%edx),%edx
  800646:	eb 22                	jmp    80066a <getuint+0x38>
	else if (lflag)
  800648:	85 d2                	test   %edx,%edx
  80064a:	74 10                	je     80065c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800651:	89 08                	mov    %ecx,(%eax)
  800653:	8b 02                	mov    (%edx),%eax
  800655:	ba 00 00 00 00       	mov    $0x0,%edx
  80065a:	eb 0e                	jmp    80066a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800661:	89 08                	mov    %ecx,(%eax)
  800663:	8b 02                	mov    (%edx),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800672:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800675:	8b 10                	mov    (%eax),%edx
  800677:	3b 50 04             	cmp    0x4(%eax),%edx
  80067a:	73 08                	jae    800684 <sprintputch+0x18>
		*b->buf++ = ch;
  80067c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067f:	88 0a                	mov    %cl,(%edx)
  800681:	42                   	inc    %edx
  800682:	89 10                	mov    %edx,(%eax)
}
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 10             	mov    0x10(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 02 00 00 00       	call   8006ae <vprintfmt>
	va_end(ap);
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	57                   	push   %edi
  8006b2:	56                   	push   %esi
  8006b3:	53                   	push   %ebx
  8006b4:	83 ec 4c             	sub    $0x4c,%esp
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bd:	eb 12                	jmp    8006d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 84 8b 03 00 00    	je     800a52 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d1:	0f b6 06             	movzbl (%esi),%eax
  8006d4:	46                   	inc    %esi
  8006d5:	83 f8 25             	cmp    $0x25,%eax
  8006d8:	75 e5                	jne    8006bf <vprintfmt+0x11>
  8006da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f6:	eb 26                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006ff:	eb 1d                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800704:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800708:	eb 14                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80070d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800714:	eb 08                	jmp    80071e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800716:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800719:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	0f b6 06             	movzbl (%esi),%eax
  800721:	8d 56 01             	lea    0x1(%esi),%edx
  800724:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800727:	8a 16                	mov    (%esi),%dl
  800729:	83 ea 23             	sub    $0x23,%edx
  80072c:	80 fa 55             	cmp    $0x55,%dl
  80072f:	0f 87 01 03 00 00    	ja     800a36 <vprintfmt+0x388>
  800735:	0f b6 d2             	movzbl %dl,%edx
  800738:	ff 24 95 00 2a 80 00 	jmp    *0x802a00(,%edx,4)
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800747:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80074e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800751:	8d 50 d0             	lea    -0x30(%eax),%edx
  800754:	83 fa 09             	cmp    $0x9,%edx
  800757:	77 2a                	ja     800783 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800759:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075a:	eb eb                	jmp    800747 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 50 04             	lea    0x4(%eax),%edx
  800762:	89 55 14             	mov    %edx,0x14(%ebp)
  800765:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076a:	eb 17                	jmp    800783 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80076c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800770:	78 98                	js     80070a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800775:	eb a7                	jmp    80071e <vprintfmt+0x70>
  800777:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80077a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800781:	eb 9b                	jmp    80071e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800783:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800787:	79 95                	jns    80071e <vprintfmt+0x70>
  800789:	eb 8b                	jmp    800716 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80078b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078f:	eb 8d                	jmp    80071e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a9:	e9 23 ff ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	79 02                	jns    8007bf <vprintfmt+0x111>
  8007bd:	f7 d8                	neg    %eax
  8007bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c1:	83 f8 0f             	cmp    $0xf,%eax
  8007c4:	7f 0b                	jg     8007d1 <vprintfmt+0x123>
  8007c6:	8b 04 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%eax
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	75 23                	jne    8007f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d5:	c7 44 24 08 c7 28 80 	movl   $0x8028c7,0x8(%esp)
  8007dc:	00 
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	e8 9a fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ef:	e9 dd fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f8:	c7 44 24 08 ba 2c 80 	movl   $0x802cba,0x8(%esp)
  8007ff:	00 
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	89 14 24             	mov    %edx,(%esp)
  80080a:	e8 77 fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800812:	e9 ba fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
  800817:	89 f9                	mov    %edi,%ecx
  800819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 30                	mov    (%eax),%esi
  80082a:	85 f6                	test   %esi,%esi
  80082c:	75 05                	jne    800833 <vprintfmt+0x185>
				p = "(null)";
  80082e:	be c0 28 80 00       	mov    $0x8028c0,%esi
			if (width > 0 && padc != '-')
  800833:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800837:	0f 8e 84 00 00 00    	jle    8008c1 <vprintfmt+0x213>
  80083d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800841:	74 7e                	je     8008c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800843:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800847:	89 34 24             	mov    %esi,(%esp)
  80084a:	e8 ab 02 00 00       	call   800afa <strnlen>
  80084f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800852:	29 c2                	sub    %eax,%edx
  800854:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800857:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80085b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80085e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800861:	89 de                	mov    %ebx,%esi
  800863:	89 d3                	mov    %edx,%ebx
  800865:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800867:	eb 0b                	jmp    800874 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800869:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086d:	89 3c 24             	mov    %edi,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800873:	4b                   	dec    %ebx
  800874:	85 db                	test   %ebx,%ebx
  800876:	7f f1                	jg     800869 <vprintfmt+0x1bb>
  800878:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800883:	85 c0                	test   %eax,%eax
  800885:	79 05                	jns    80088c <vprintfmt+0x1de>
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088f:	29 c2                	sub    %eax,%edx
  800891:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800894:	eb 2b                	jmp    8008c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800896:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80089a:	74 18                	je     8008b4 <vprintfmt+0x206>
  80089c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089f:	83 fa 5e             	cmp    $0x5e,%edx
  8008a2:	76 10                	jbe    8008b4 <vprintfmt+0x206>
					putch('?', putdat);
  8008a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008af:	ff 55 08             	call   *0x8(%ebp)
  8008b2:	eb 0a                	jmp    8008be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008be:	ff 4d e4             	decl   -0x1c(%ebp)
  8008c1:	0f be 06             	movsbl (%esi),%eax
  8008c4:	46                   	inc    %esi
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 21                	je     8008ea <vprintfmt+0x23c>
  8008c9:	85 ff                	test   %edi,%edi
  8008cb:	78 c9                	js     800896 <vprintfmt+0x1e8>
  8008cd:	4f                   	dec    %edi
  8008ce:	79 c6                	jns    800896 <vprintfmt+0x1e8>
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	89 de                	mov    %ebx,%esi
  8008d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d8:	eb 18                	jmp    8008f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008e7:	4b                   	dec    %ebx
  8008e8:	eb 08                	jmp    8008f2 <vprintfmt+0x244>
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	89 de                	mov    %ebx,%esi
  8008ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	7f e4                	jg     8008da <vprintfmt+0x22c>
  8008f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fe:	e9 ce fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800903:	83 f9 01             	cmp    $0x1,%ecx
  800906:	7e 10                	jle    800918 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8d 50 08             	lea    0x8(%eax),%edx
  80090e:	89 55 14             	mov    %edx,0x14(%ebp)
  800911:	8b 30                	mov    (%eax),%esi
  800913:	8b 78 04             	mov    0x4(%eax),%edi
  800916:	eb 26                	jmp    80093e <vprintfmt+0x290>
	else if (lflag)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	74 12                	je     80092e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8d 50 04             	lea    0x4(%eax),%edx
  800922:	89 55 14             	mov    %edx,0x14(%ebp)
  800925:	8b 30                	mov    (%eax),%esi
  800927:	89 f7                	mov    %esi,%edi
  800929:	c1 ff 1f             	sar    $0x1f,%edi
  80092c:	eb 10                	jmp    80093e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 30                	mov    (%eax),%esi
  800939:	89 f7                	mov    %esi,%edi
  80093b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80093e:	85 ff                	test   %edi,%edi
  800940:	78 0a                	js     80094c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800942:	b8 0a 00 00 00       	mov    $0xa,%eax
  800947:	e9 ac 00 00 00       	jmp    8009f8 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800957:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80095a:	f7 de                	neg    %esi
  80095c:	83 d7 00             	adc    $0x0,%edi
  80095f:	f7 df                	neg    %edi
			}
			base = 10;
  800961:	b8 0a 00 00 00       	mov    $0xa,%eax
  800966:	e9 8d 00 00 00       	jmp    8009f8 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80096b:	89 ca                	mov    %ecx,%edx
  80096d:	8d 45 14             	lea    0x14(%ebp),%eax
  800970:	e8 bd fc ff ff       	call   800632 <getuint>
  800975:	89 c6                	mov    %eax,%esi
  800977:	89 d7                	mov    %edx,%edi
			base = 10;
  800979:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80097e:	eb 78                	jmp    8009f8 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800984:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80098b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80098e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800992:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800999:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80099c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009ad:	e9 1f fd ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8009b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d1:	8d 50 04             	lea    0x4(%eax),%edx
  8009d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009d7:	8b 30                	mov    (%eax),%esi
  8009d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009e3:	eb 13                	jmp    8009f8 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009e5:	89 ca                	mov    %ecx,%edx
  8009e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ea:	e8 43 fc ff ff       	call   800632 <getuint>
  8009ef:	89 c6                	mov    %eax,%esi
  8009f1:	89 d7                	mov    %edx,%edi
			base = 16;
  8009f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a03:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0b:	89 34 24             	mov    %esi,(%esp)
  800a0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a12:	89 da                	mov    %ebx,%edx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	e8 4c fb ff ff       	call   800568 <printnum>
			break;
  800a1c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a1f:	e9 ad fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a31:	e9 9b fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a41:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a44:	eb 01                	jmp    800a47 <vprintfmt+0x399>
  800a46:	4e                   	dec    %esi
  800a47:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a4b:	75 f9                	jne    800a46 <vprintfmt+0x398>
  800a4d:	e9 7f fc ff ff       	jmp    8006d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a52:	83 c4 4c             	add    $0x4c,%esp
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 28             	sub    $0x28,%esp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a69:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a6d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a77:	85 c0                	test   %eax,%eax
  800a79:	74 30                	je     800aab <vsnprintf+0x51>
  800a7b:	85 d2                	test   %edx,%edx
  800a7d:	7e 33                	jle    800ab2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a86:	8b 45 10             	mov    0x10(%ebp),%eax
  800a89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a94:	c7 04 24 6c 06 80 00 	movl   $0x80066c,(%esp)
  800a9b:	e8 0e fc ff ff       	call   8006ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aa3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa9:	eb 0c                	jmp    800ab7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ab0:	eb 05                	jmp    800ab7 <vsnprintf+0x5d>
  800ab2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800abf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ac2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ac6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	89 04 24             	mov    %eax,(%esp)
  800ada:	e8 7b ff ff ff       	call   800a5a <vsnprintf>
	va_end(ap);

	return rc;
}
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    
  800ae1:	00 00                	add    %al,(%eax)
	...

00800ae4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	eb 01                	jmp    800af2 <strlen+0xe>
		n++;
  800af1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800af2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800af6:	75 f9                	jne    800af1 <strlen+0xd>
		n++;
	return n;
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	eb 01                	jmp    800b0b <strnlen+0x11>
		n++;
  800b0a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0b:	39 d0                	cmp    %edx,%eax
  800b0d:	74 06                	je     800b15 <strnlen+0x1b>
  800b0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b13:	75 f5                	jne    800b0a <strnlen+0x10>
		n++;
	return n;
}
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b29:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b2c:	42                   	inc    %edx
  800b2d:	84 c9                	test   %cl,%cl
  800b2f:	75 f5                	jne    800b26 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b31:	5b                   	pop    %ebx
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b3e:	89 1c 24             	mov    %ebx,(%esp)
  800b41:	e8 9e ff ff ff       	call   800ae4 <strlen>
	strcpy(dst + len, src);
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b49:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b4d:	01 d8                	add    %ebx,%eax
  800b4f:	89 04 24             	mov    %eax,(%esp)
  800b52:	e8 c0 ff ff ff       	call   800b17 <strcpy>
	return dst;
}
  800b57:	89 d8                	mov    %ebx,%eax
  800b59:	83 c4 08             	add    $0x8,%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b72:	eb 0c                	jmp    800b80 <strncpy+0x21>
		*dst++ = *src;
  800b74:	8a 1a                	mov    (%edx),%bl
  800b76:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b79:	80 3a 01             	cmpb   $0x1,(%edx)
  800b7c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b7f:	41                   	inc    %ecx
  800b80:	39 f1                	cmp    %esi,%ecx
  800b82:	75 f0                	jne    800b74 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b96:	85 d2                	test   %edx,%edx
  800b98:	75 0a                	jne    800ba4 <strlcpy+0x1c>
  800b9a:	89 f0                	mov    %esi,%eax
  800b9c:	eb 1a                	jmp    800bb8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b9e:	88 18                	mov    %bl,(%eax)
  800ba0:	40                   	inc    %eax
  800ba1:	41                   	inc    %ecx
  800ba2:	eb 02                	jmp    800ba6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ba6:	4a                   	dec    %edx
  800ba7:	74 0a                	je     800bb3 <strlcpy+0x2b>
  800ba9:	8a 19                	mov    (%ecx),%bl
  800bab:	84 db                	test   %bl,%bl
  800bad:	75 ef                	jne    800b9e <strlcpy+0x16>
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	eb 02                	jmp    800bb5 <strlcpy+0x2d>
  800bb3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bb5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bb8:	29 f0                	sub    %esi,%eax
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bc7:	eb 02                	jmp    800bcb <strcmp+0xd>
		p++, q++;
  800bc9:	41                   	inc    %ecx
  800bca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bcb:	8a 01                	mov    (%ecx),%al
  800bcd:	84 c0                	test   %al,%al
  800bcf:	74 04                	je     800bd5 <strcmp+0x17>
  800bd1:	3a 02                	cmp    (%edx),%al
  800bd3:	74 f4                	je     800bc9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd5:	0f b6 c0             	movzbl %al,%eax
  800bd8:	0f b6 12             	movzbl (%edx),%edx
  800bdb:	29 d0                	sub    %edx,%eax
}
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	53                   	push   %ebx
  800be3:	8b 45 08             	mov    0x8(%ebp),%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bec:	eb 03                	jmp    800bf1 <strncmp+0x12>
		n--, p++, q++;
  800bee:	4a                   	dec    %edx
  800bef:	40                   	inc    %eax
  800bf0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bf1:	85 d2                	test   %edx,%edx
  800bf3:	74 14                	je     800c09 <strncmp+0x2a>
  800bf5:	8a 18                	mov    (%eax),%bl
  800bf7:	84 db                	test   %bl,%bl
  800bf9:	74 04                	je     800bff <strncmp+0x20>
  800bfb:	3a 19                	cmp    (%ecx),%bl
  800bfd:	74 ef                	je     800bee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bff:	0f b6 00             	movzbl (%eax),%eax
  800c02:	0f b6 11             	movzbl (%ecx),%edx
  800c05:	29 d0                	sub    %edx,%eax
  800c07:	eb 05                	jmp    800c0e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c1a:	eb 05                	jmp    800c21 <strchr+0x10>
		if (*s == c)
  800c1c:	38 ca                	cmp    %cl,%dl
  800c1e:	74 0c                	je     800c2c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c20:	40                   	inc    %eax
  800c21:	8a 10                	mov    (%eax),%dl
  800c23:	84 d2                	test   %dl,%dl
  800c25:	75 f5                	jne    800c1c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c37:	eb 05                	jmp    800c3e <strfind+0x10>
		if (*s == c)
  800c39:	38 ca                	cmp    %cl,%dl
  800c3b:	74 07                	je     800c44 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c3d:	40                   	inc    %eax
  800c3e:	8a 10                	mov    (%eax),%dl
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 f5                	jne    800c39 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c55:	85 c9                	test   %ecx,%ecx
  800c57:	74 30                	je     800c89 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5f:	75 25                	jne    800c86 <memset+0x40>
  800c61:	f6 c1 03             	test   $0x3,%cl
  800c64:	75 20                	jne    800c86 <memset+0x40>
		c &= 0xFF;
  800c66:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c69:	89 d3                	mov    %edx,%ebx
  800c6b:	c1 e3 08             	shl    $0x8,%ebx
  800c6e:	89 d6                	mov    %edx,%esi
  800c70:	c1 e6 18             	shl    $0x18,%esi
  800c73:	89 d0                	mov    %edx,%eax
  800c75:	c1 e0 10             	shl    $0x10,%eax
  800c78:	09 f0                	or     %esi,%eax
  800c7a:	09 d0                	or     %edx,%eax
  800c7c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c7e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c81:	fc                   	cld    
  800c82:	f3 ab                	rep stos %eax,%es:(%edi)
  800c84:	eb 03                	jmp    800c89 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c86:	fc                   	cld    
  800c87:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c89:	89 f8                	mov    %edi,%eax
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c9e:	39 c6                	cmp    %eax,%esi
  800ca0:	73 34                	jae    800cd6 <memmove+0x46>
  800ca2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ca5:	39 d0                	cmp    %edx,%eax
  800ca7:	73 2d                	jae    800cd6 <memmove+0x46>
		s += n;
		d += n;
  800ca9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cac:	f6 c2 03             	test   $0x3,%dl
  800caf:	75 1b                	jne    800ccc <memmove+0x3c>
  800cb1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb7:	75 13                	jne    800ccc <memmove+0x3c>
  800cb9:	f6 c1 03             	test   $0x3,%cl
  800cbc:	75 0e                	jne    800ccc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cbe:	83 ef 04             	sub    $0x4,%edi
  800cc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cc7:	fd                   	std    
  800cc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cca:	eb 07                	jmp    800cd3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ccc:	4f                   	dec    %edi
  800ccd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cd0:	fd                   	std    
  800cd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd3:	fc                   	cld    
  800cd4:	eb 20                	jmp    800cf6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cdc:	75 13                	jne    800cf1 <memmove+0x61>
  800cde:	a8 03                	test   $0x3,%al
  800ce0:	75 0f                	jne    800cf1 <memmove+0x61>
  800ce2:	f6 c1 03             	test   $0x3,%cl
  800ce5:	75 0a                	jne    800cf1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ce7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cea:	89 c7                	mov    %eax,%edi
  800cec:	fc                   	cld    
  800ced:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cef:	eb 05                	jmp    800cf6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf1:	89 c7                	mov    %eax,%edi
  800cf3:	fc                   	cld    
  800cf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d00:	8b 45 10             	mov    0x10(%ebp),%eax
  800d03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	89 04 24             	mov    %eax,(%esp)
  800d14:	e8 77 ff ff ff       	call   800c90 <memmove>
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	eb 16                	jmp    800d47 <memcmp+0x2c>
		if (*s1 != *s2)
  800d31:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d34:	42                   	inc    %edx
  800d35:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d39:	38 c8                	cmp    %cl,%al
  800d3b:	74 0a                	je     800d47 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d3d:	0f b6 c0             	movzbl %al,%eax
  800d40:	0f b6 c9             	movzbl %cl,%ecx
  800d43:	29 c8                	sub    %ecx,%eax
  800d45:	eb 09                	jmp    800d50 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d47:	39 da                	cmp    %ebx,%edx
  800d49:	75 e6                	jne    800d31 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d5e:	89 c2                	mov    %eax,%edx
  800d60:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d63:	eb 05                	jmp    800d6a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d65:	38 08                	cmp    %cl,(%eax)
  800d67:	74 05                	je     800d6e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d69:	40                   	inc    %eax
  800d6a:	39 d0                	cmp    %edx,%eax
  800d6c:	72 f7                	jb     800d65 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7c:	eb 01                	jmp    800d7f <strtol+0xf>
		s++;
  800d7e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7f:	8a 02                	mov    (%edx),%al
  800d81:	3c 20                	cmp    $0x20,%al
  800d83:	74 f9                	je     800d7e <strtol+0xe>
  800d85:	3c 09                	cmp    $0x9,%al
  800d87:	74 f5                	je     800d7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d89:	3c 2b                	cmp    $0x2b,%al
  800d8b:	75 08                	jne    800d95 <strtol+0x25>
		s++;
  800d8d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d93:	eb 13                	jmp    800da8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d95:	3c 2d                	cmp    $0x2d,%al
  800d97:	75 0a                	jne    800da3 <strtol+0x33>
		s++, neg = 1;
  800d99:	8d 52 01             	lea    0x1(%edx),%edx
  800d9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800da1:	eb 05                	jmp    800da8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	85 db                	test   %ebx,%ebx
  800daa:	74 05                	je     800db1 <strtol+0x41>
  800dac:	83 fb 10             	cmp    $0x10,%ebx
  800daf:	75 28                	jne    800dd9 <strtol+0x69>
  800db1:	8a 02                	mov    (%edx),%al
  800db3:	3c 30                	cmp    $0x30,%al
  800db5:	75 10                	jne    800dc7 <strtol+0x57>
  800db7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dbb:	75 0a                	jne    800dc7 <strtol+0x57>
		s += 2, base = 16;
  800dbd:	83 c2 02             	add    $0x2,%edx
  800dc0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dc5:	eb 12                	jmp    800dd9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800dc7:	85 db                	test   %ebx,%ebx
  800dc9:	75 0e                	jne    800dd9 <strtol+0x69>
  800dcb:	3c 30                	cmp    $0x30,%al
  800dcd:	75 05                	jne    800dd4 <strtol+0x64>
		s++, base = 8;
  800dcf:	42                   	inc    %edx
  800dd0:	b3 08                	mov    $0x8,%bl
  800dd2:	eb 05                	jmp    800dd9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800dd4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de0:	8a 0a                	mov    (%edx),%cl
  800de2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800de5:	80 fb 09             	cmp    $0x9,%bl
  800de8:	77 08                	ja     800df2 <strtol+0x82>
			dig = *s - '0';
  800dea:	0f be c9             	movsbl %cl,%ecx
  800ded:	83 e9 30             	sub    $0x30,%ecx
  800df0:	eb 1e                	jmp    800e10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800df2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800df5:	80 fb 19             	cmp    $0x19,%bl
  800df8:	77 08                	ja     800e02 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dfa:	0f be c9             	movsbl %cl,%ecx
  800dfd:	83 e9 57             	sub    $0x57,%ecx
  800e00:	eb 0e                	jmp    800e10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800e02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e05:	80 fb 19             	cmp    $0x19,%bl
  800e08:	77 12                	ja     800e1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800e0a:	0f be c9             	movsbl %cl,%ecx
  800e0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e10:	39 f1                	cmp    %esi,%ecx
  800e12:	7d 0c                	jge    800e20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800e14:	42                   	inc    %edx
  800e15:	0f af c6             	imul   %esi,%eax
  800e18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e1a:	eb c4                	jmp    800de0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e1c:	89 c1                	mov    %eax,%ecx
  800e1e:	eb 02                	jmp    800e22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e26:	74 05                	je     800e2d <strtol+0xbd>
		*endptr = (char *) s;
  800e28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e2d:	85 ff                	test   %edi,%edi
  800e2f:	74 04                	je     800e35 <strtol+0xc5>
  800e31:	89 c8                	mov    %ecx,%eax
  800e33:	f7 d8                	neg    %eax
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
	...

00800e3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e42:	b8 00 00 00 00       	mov    $0x0,%eax
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4d:	89 c3                	mov    %eax,%ebx
  800e4f:	89 c7                	mov    %eax,%edi
  800e51:	89 c6                	mov    %eax,%esi
  800e53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	ba 00 00 00 00       	mov    $0x0,%edx
  800e65:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6a:	89 d1                	mov    %edx,%ecx
  800e6c:	89 d3                	mov    %edx,%ebx
  800e6e:	89 d7                	mov    %edx,%edi
  800e70:	89 d6                	mov    %edx,%esi
  800e72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
  800e7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e87:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8f:	89 cb                	mov    %ecx,%ebx
  800e91:	89 cf                	mov    %ecx,%edi
  800e93:	89 ce                	mov    %ecx,%esi
  800e95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e97:	85 c0                	test   %eax,%eax
  800e99:	7e 28                	jle    800ec3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800eae:	00 
  800eaf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb6:	00 
  800eb7:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800ebe:	e8 91 f5 ff ff       	call   800454 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ec3:	83 c4 2c             	add    $0x2c,%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed6:	b8 02 00 00 00       	mov    $0x2,%eax
  800edb:	89 d1                	mov    %edx,%ecx
  800edd:	89 d3                	mov    %edx,%ebx
  800edf:	89 d7                	mov    %edx,%edi
  800ee1:	89 d6                	mov    %edx,%esi
  800ee3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <sys_yield>:

void
sys_yield(void)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800efa:	89 d1                	mov    %edx,%ecx
  800efc:	89 d3                	mov    %edx,%ebx
  800efe:	89 d7                	mov    %edx,%edi
  800f00:	89 d6                	mov    %edx,%esi
  800f02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	be 00 00 00 00       	mov    $0x0,%esi
  800f17:	b8 04 00 00 00       	mov    $0x4,%eax
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 f7                	mov    %esi,%edi
  800f27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	7e 28                	jle    800f55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f38:	00 
  800f39:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800f40:	00 
  800f41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800f50:	e8 ff f4 ff ff       	call   800454 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f55:	83 c4 2c             	add    $0x2c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f66:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800f6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f77:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	7e 28                	jle    800fa8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800f93:	00 
  800f94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9b:	00 
  800f9c:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800fa3:	e8 ac f4 ff ff       	call   800454 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fa8:	83 c4 2c             	add    $0x2c,%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800fc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	89 df                	mov    %ebx,%edi
  800fcb:	89 de                	mov    %ebx,%esi
  800fcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	7e 28                	jle    800ffb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fde:	00 
  800fdf:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800ff6:	e8 59 f4 ff ff       	call   800454 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ffb:	83 c4 2c             	add    $0x2c,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801011:	b8 08 00 00 00       	mov    $0x8,%eax
  801016:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801019:	8b 55 08             	mov    0x8(%ebp),%edx
  80101c:	89 df                	mov    %ebx,%edi
  80101e:	89 de                	mov    %ebx,%esi
  801020:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	7e 28                	jle    80104e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801026:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  801049:	e8 06 f4 ff ff       	call   800454 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80104e:	83 c4 2c             	add    $0x2c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801064:	b8 09 00 00 00       	mov    $0x9,%eax
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	89 df                	mov    %ebx,%edi
  801071:	89 de                	mov    %ebx,%esi
  801073:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801075:	85 c0                	test   %eax,%eax
  801077:	7e 28                	jle    8010a1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801079:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801084:	00 
  801085:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  80108c:	00 
  80108d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801094:	00 
  801095:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  80109c:	e8 b3 f3 ff ff       	call   800454 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010a1:	83 c4 2c             	add    $0x2c,%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	57                   	push   %edi
  8010ad:	56                   	push   %esi
  8010ae:	53                   	push   %ebx
  8010af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c2:	89 df                	mov    %ebx,%edi
  8010c4:	89 de                	mov    %ebx,%esi
  8010c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	7e 28                	jle    8010f4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  8010df:	00 
  8010e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e7:	00 
  8010e8:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  8010ef:	e8 60 f3 ff ff       	call   800454 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010f4:	83 c4 2c             	add    $0x2c,%esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801102:	be 00 00 00 00       	mov    $0x0,%esi
  801107:	b8 0c 00 00 00       	mov    $0xc,%eax
  80110c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80110f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801115:	8b 55 08             	mov    0x8(%ebp),%edx
  801118:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801128:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801132:	8b 55 08             	mov    0x8(%ebp),%edx
  801135:	89 cb                	mov    %ecx,%ebx
  801137:	89 cf                	mov    %ecx,%edi
  801139:	89 ce                	mov    %ecx,%esi
  80113b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80113d:	85 c0                	test   %eax,%eax
  80113f:	7e 28                	jle    801169 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801141:	89 44 24 10          	mov    %eax,0x10(%esp)
  801145:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80114c:	00 
  80114d:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  801154:	00 
  801155:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80115c:	00 
  80115d:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  801164:	e8 eb f2 ff ff       	call   800454 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801169:	83 c4 2c             	add    $0x2c,%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    
  801171:	00 00                	add    %al,(%eax)
	...

00801174 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	05 00 00 00 30       	add    $0x30000000,%eax
  80117f:	c1 e8 0c             	shr    $0xc,%eax
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80118a:	8b 45 08             	mov    0x8(%ebp),%eax
  80118d:	89 04 24             	mov    %eax,(%esp)
  801190:	e8 df ff ff ff       	call   801174 <fd2num>
  801195:	05 20 00 0d 00       	add    $0xd0020,%eax
  80119a:	c1 e0 0c             	shl    $0xc,%eax
}
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	53                   	push   %ebx
  8011a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011a6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011ab:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	c1 ea 16             	shr    $0x16,%edx
  8011b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b9:	f6 c2 01             	test   $0x1,%dl
  8011bc:	74 11                	je     8011cf <fd_alloc+0x30>
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	c1 ea 0c             	shr    $0xc,%edx
  8011c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ca:	f6 c2 01             	test   $0x1,%dl
  8011cd:	75 09                	jne    8011d8 <fd_alloc+0x39>
			*fd_store = fd;
  8011cf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d6:	eb 17                	jmp    8011ef <fd_alloc+0x50>
  8011d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e2:	75 c7                	jne    8011ab <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ef:	5b                   	pop    %ebx
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f8:	83 f8 1f             	cmp    $0x1f,%eax
  8011fb:	77 36                	ja     801233 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fd:	05 00 00 0d 00       	add    $0xd0000,%eax
  801202:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 16             	shr    $0x16,%edx
  80120a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 24                	je     80123a <fd_lookup+0x48>
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 0c             	shr    $0xc,%edx
  80121b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 1a                	je     801241 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122a:	89 02                	mov    %eax,(%edx)
	return 0;
  80122c:	b8 00 00 00 00       	mov    $0x0,%eax
  801231:	eb 13                	jmp    801246 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb 0c                	jmp    801246 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123f:	eb 05                	jmp    801246 <fd_lookup+0x54>
  801241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 14             	sub    $0x14,%esp
  80124f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801252:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801255:	ba 00 00 00 00       	mov    $0x0,%edx
  80125a:	eb 0e                	jmp    80126a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80125c:	39 08                	cmp    %ecx,(%eax)
  80125e:	75 09                	jne    801269 <dev_lookup+0x21>
			*dev = devtab[i];
  801260:	89 03                	mov    %eax,(%ebx)
			return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	eb 33                	jmp    80129c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801269:	42                   	inc    %edx
  80126a:	8b 04 95 68 2c 80 00 	mov    0x802c68(,%edx,4),%eax
  801271:	85 c0                	test   %eax,%eax
  801273:	75 e7                	jne    80125c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801275:	a1 90 67 80 00       	mov    0x806790,%eax
  80127a:	8b 40 48             	mov    0x48(%eax),%eax
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	89 44 24 04          	mov    %eax,0x4(%esp)
  801285:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  80128c:	e8 bb f2 ff ff       	call   80054c <cprintf>
	*dev = 0;
  801291:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129c:	83 c4 14             	add    $0x14,%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 30             	sub    $0x30,%esp
  8012aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ad:	8a 45 0c             	mov    0xc(%ebp),%al
  8012b0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b3:	89 34 24             	mov    %esi,(%esp)
  8012b6:	e8 b9 fe ff ff       	call   801174 <fd2num>
  8012bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c2:	89 04 24             	mov    %eax,(%esp)
  8012c5:	e8 28 ff ff ff       	call   8011f2 <fd_lookup>
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 05                	js     8012d5 <fd_close+0x33>
	    || fd != fd2)
  8012d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d3:	74 0d                	je     8012e2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8012d5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012d9:	75 46                	jne    801321 <fd_close+0x7f>
  8012db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e0:	eb 3f                	jmp    801321 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e9:	8b 06                	mov    (%esi),%eax
  8012eb:	89 04 24             	mov    %eax,(%esp)
  8012ee:	e8 55 ff ff ff       	call   801248 <dev_lookup>
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 18                	js     801311 <fd_close+0x6f>
		if (dev->dev_close)
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	8b 40 10             	mov    0x10(%eax),%eax
  8012ff:	85 c0                	test   %eax,%eax
  801301:	74 09                	je     80130c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801303:	89 34 24             	mov    %esi,(%esp)
  801306:	ff d0                	call   *%eax
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	eb 05                	jmp    801311 <fd_close+0x6f>
		else
			r = 0;
  80130c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801311:	89 74 24 04          	mov    %esi,0x4(%esp)
  801315:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131c:	e8 8f fc ff ff       	call   800fb0 <sys_page_unmap>
	return r;
}
  801321:	89 d8                	mov    %ebx,%eax
  801323:	83 c4 30             	add    $0x30,%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801333:	89 44 24 04          	mov    %eax,0x4(%esp)
  801337:	8b 45 08             	mov    0x8(%ebp),%eax
  80133a:	89 04 24             	mov    %eax,(%esp)
  80133d:	e8 b0 fe ff ff       	call   8011f2 <fd_lookup>
  801342:	85 c0                	test   %eax,%eax
  801344:	78 13                	js     801359 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801346:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80134d:	00 
  80134e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801351:	89 04 24             	mov    %eax,(%esp)
  801354:	e8 49 ff ff ff       	call   8012a2 <fd_close>
}
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <close_all>:

void
close_all(void)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	53                   	push   %ebx
  80135f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801362:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801367:	89 1c 24             	mov    %ebx,(%esp)
  80136a:	e8 bb ff ff ff       	call   80132a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136f:	43                   	inc    %ebx
  801370:	83 fb 20             	cmp    $0x20,%ebx
  801373:	75 f2                	jne    801367 <close_all+0xc>
		close(i);
}
  801375:	83 c4 14             	add    $0x14,%esp
  801378:	5b                   	pop    %ebx
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	57                   	push   %edi
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 4c             	sub    $0x4c,%esp
  801384:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801387:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 59 fe ff ff       	call   8011f2 <fd_lookup>
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	0f 88 e1 00 00 00    	js     801484 <dup+0x109>
		return r;
	close(newfdnum);
  8013a3:	89 3c 24             	mov    %edi,(%esp)
  8013a6:	e8 7f ff ff ff       	call   80132a <close>

	newfd = INDEX2FD(newfdnum);
  8013ab:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013b1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b7:	89 04 24             	mov    %eax,(%esp)
  8013ba:	e8 c5 fd ff ff       	call   801184 <fd2data>
  8013bf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013c1:	89 34 24             	mov    %esi,(%esp)
  8013c4:	e8 bb fd ff ff       	call   801184 <fd2data>
  8013c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013cc:	89 d8                	mov    %ebx,%eax
  8013ce:	c1 e8 16             	shr    $0x16,%eax
  8013d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d8:	a8 01                	test   $0x1,%al
  8013da:	74 46                	je     801422 <dup+0xa7>
  8013dc:	89 d8                	mov    %ebx,%eax
  8013de:	c1 e8 0c             	shr    $0xc,%eax
  8013e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e8:	f6 c2 01             	test   $0x1,%dl
  8013eb:	74 35                	je     801422 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801400:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801404:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80140b:	00 
  80140c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801410:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801417:	e8 41 fb ff ff       	call   800f5d <sys_page_map>
  80141c:	89 c3                	mov    %eax,%ebx
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 3b                	js     80145d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801425:	89 c2                	mov    %eax,%edx
  801427:	c1 ea 0c             	shr    $0xc,%edx
  80142a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801431:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801437:	89 54 24 10          	mov    %edx,0x10(%esp)
  80143b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80143f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801446:	00 
  801447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801452:	e8 06 fb ff ff       	call   800f5d <sys_page_map>
  801457:	89 c3                	mov    %eax,%ebx
  801459:	85 c0                	test   %eax,%eax
  80145b:	79 25                	jns    801482 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80145d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801461:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801468:	e8 43 fb ff ff       	call   800fb0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801470:	89 44 24 04          	mov    %eax,0x4(%esp)
  801474:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147b:	e8 30 fb ff ff       	call   800fb0 <sys_page_unmap>
	return r;
  801480:	eb 02                	jmp    801484 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801482:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801484:	89 d8                	mov    %ebx,%eax
  801486:	83 c4 4c             	add    $0x4c,%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5f                   	pop    %edi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	53                   	push   %ebx
  801492:	83 ec 24             	sub    $0x24,%esp
  801495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149f:	89 1c 24             	mov    %ebx,(%esp)
  8014a2:	e8 4b fd ff ff       	call   8011f2 <fd_lookup>
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 6d                	js     801518 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b5:	8b 00                	mov    (%eax),%eax
  8014b7:	89 04 24             	mov    %eax,(%esp)
  8014ba:	e8 89 fd ff ff       	call   801248 <dev_lookup>
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 55                	js     801518 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c6:	8b 50 08             	mov    0x8(%eax),%edx
  8014c9:	83 e2 03             	and    $0x3,%edx
  8014cc:	83 fa 01             	cmp    $0x1,%edx
  8014cf:	75 23                	jne    8014f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d1:	a1 90 67 80 00       	mov    0x806790,%eax
  8014d6:	8b 40 48             	mov    0x48(%eax),%eax
  8014d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e1:	c7 04 24 2d 2c 80 00 	movl   $0x802c2d,(%esp)
  8014e8:	e8 5f f0 ff ff       	call   80054c <cprintf>
		return -E_INVAL;
  8014ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f2:	eb 24                	jmp    801518 <read+0x8a>
	}
	if (!dev->dev_read)
  8014f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f7:	8b 52 08             	mov    0x8(%edx),%edx
  8014fa:	85 d2                	test   %edx,%edx
  8014fc:	74 15                	je     801513 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801501:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801505:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801508:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80150c:	89 04 24             	mov    %eax,(%esp)
  80150f:	ff d2                	call   *%edx
  801511:	eb 05                	jmp    801518 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801513:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801518:	83 c4 24             	add    $0x24,%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	57                   	push   %edi
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	83 ec 1c             	sub    $0x1c,%esp
  801527:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801532:	eb 23                	jmp    801557 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801534:	89 f0                	mov    %esi,%eax
  801536:	29 d8                	sub    %ebx,%eax
  801538:	89 44 24 08          	mov    %eax,0x8(%esp)
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	01 d8                	add    %ebx,%eax
  801541:	89 44 24 04          	mov    %eax,0x4(%esp)
  801545:	89 3c 24             	mov    %edi,(%esp)
  801548:	e8 41 ff ff ff       	call   80148e <read>
		if (m < 0)
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 10                	js     801561 <readn+0x43>
			return m;
		if (m == 0)
  801551:	85 c0                	test   %eax,%eax
  801553:	74 0a                	je     80155f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801555:	01 c3                	add    %eax,%ebx
  801557:	39 f3                	cmp    %esi,%ebx
  801559:	72 d9                	jb     801534 <readn+0x16>
  80155b:	89 d8                	mov    %ebx,%eax
  80155d:	eb 02                	jmp    801561 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80155f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801561:	83 c4 1c             	add    $0x1c,%esp
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	53                   	push   %ebx
  80156d:	83 ec 24             	sub    $0x24,%esp
  801570:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801576:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157a:	89 1c 24             	mov    %ebx,(%esp)
  80157d:	e8 70 fc ff ff       	call   8011f2 <fd_lookup>
  801582:	85 c0                	test   %eax,%eax
  801584:	78 68                	js     8015ee <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801590:	8b 00                	mov    (%eax),%eax
  801592:	89 04 24             	mov    %eax,(%esp)
  801595:	e8 ae fc ff ff       	call   801248 <dev_lookup>
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 50                	js     8015ee <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a5:	75 23                	jne    8015ca <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a7:	a1 90 67 80 00       	mov    0x806790,%eax
  8015ac:	8b 40 48             	mov    0x48(%eax),%eax
  8015af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b7:	c7 04 24 49 2c 80 00 	movl   $0x802c49,(%esp)
  8015be:	e8 89 ef ff ff       	call   80054c <cprintf>
		return -E_INVAL;
  8015c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c8:	eb 24                	jmp    8015ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d0:	85 d2                	test   %edx,%edx
  8015d2:	74 15                	je     8015e9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015e2:	89 04 24             	mov    %eax,(%esp)
  8015e5:	ff d2                	call   *%edx
  8015e7:	eb 05                	jmp    8015ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015ee:	83 c4 24             	add    $0x24,%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801601:	8b 45 08             	mov    0x8(%ebp),%eax
  801604:	89 04 24             	mov    %eax,(%esp)
  801607:	e8 e6 fb ff ff       	call   8011f2 <fd_lookup>
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 0e                	js     80161e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801610:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801613:	8b 55 0c             	mov    0xc(%ebp),%edx
  801616:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801619:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 24             	sub    $0x24,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801631:	89 1c 24             	mov    %ebx,(%esp)
  801634:	e8 b9 fb ff ff       	call   8011f2 <fd_lookup>
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 61                	js     80169e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801640:	89 44 24 04          	mov    %eax,0x4(%esp)
  801644:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801647:	8b 00                	mov    (%eax),%eax
  801649:	89 04 24             	mov    %eax,(%esp)
  80164c:	e8 f7 fb ff ff       	call   801248 <dev_lookup>
  801651:	85 c0                	test   %eax,%eax
  801653:	78 49                	js     80169e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165c:	75 23                	jne    801681 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80165e:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801663:	8b 40 48             	mov    0x48(%eax),%eax
  801666:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80166a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166e:	c7 04 24 0c 2c 80 00 	movl   $0x802c0c,(%esp)
  801675:	e8 d2 ee ff ff       	call   80054c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167f:	eb 1d                	jmp    80169e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801681:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801684:	8b 52 18             	mov    0x18(%edx),%edx
  801687:	85 d2                	test   %edx,%edx
  801689:	74 0e                	je     801699 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801692:	89 04 24             	mov    %eax,(%esp)
  801695:	ff d2                	call   *%edx
  801697:	eb 05                	jmp    80169e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801699:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80169e:	83 c4 24             	add    $0x24,%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 24             	sub    $0x24,%esp
  8016ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	89 04 24             	mov    %eax,(%esp)
  8016bb:	e8 32 fb ff ff       	call   8011f2 <fd_lookup>
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 52                	js     801716 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ce:	8b 00                	mov    (%eax),%eax
  8016d0:	89 04 24             	mov    %eax,(%esp)
  8016d3:	e8 70 fb ff ff       	call   801248 <dev_lookup>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 3a                	js     801716 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e3:	74 2c                	je     801711 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ef:	00 00 00 
	stat->st_isdir = 0;
  8016f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f9:	00 00 00 
	stat->st_dev = dev;
  8016fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801702:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801706:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801709:	89 14 24             	mov    %edx,(%esp)
  80170c:	ff 50 14             	call   *0x14(%eax)
  80170f:	eb 05                	jmp    801716 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801711:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801716:	83 c4 24             	add    $0x24,%esp
  801719:	5b                   	pop    %ebx
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801724:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80172b:	00 
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	89 04 24             	mov    %eax,(%esp)
  801732:	e8 fe 01 00 00       	call   801935 <open>
  801737:	89 c3                	mov    %eax,%ebx
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 1b                	js     801758 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80173d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801740:	89 44 24 04          	mov    %eax,0x4(%esp)
  801744:	89 1c 24             	mov    %ebx,(%esp)
  801747:	e8 58 ff ff ff       	call   8016a4 <fstat>
  80174c:	89 c6                	mov    %eax,%esi
	close(fd);
  80174e:	89 1c 24             	mov    %ebx,(%esp)
  801751:	e8 d4 fb ff ff       	call   80132a <close>
	return r;
  801756:	89 f3                	mov    %esi,%ebx
}
  801758:	89 d8                	mov    %ebx,%eax
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    
  801761:	00 00                	add    %al,(%eax)
	...

00801764 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	83 ec 10             	sub    $0x10,%esp
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801770:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801777:	75 11                	jne    80178a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801779:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801780:	e8 d0 0c 00 00       	call   802455 <ipc_find_env>
  801785:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801791:	00 
  801792:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801799:	00 
  80179a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179e:	a1 00 50 80 00       	mov    0x805000,%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 40 0c 00 00       	call   8023eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b2:	00 
  8017b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017be:	e8 c1 0b 00 00       	call   802384 <ipc_recv>
}
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8017db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017de:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ed:	e8 72 ff ff ff       	call   801764 <fsipc>
}
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801800:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	b8 06 00 00 00       	mov    $0x6,%eax
  80180f:	e8 50 ff ff ff       	call   801764 <fsipc>
}
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 14             	sub    $0x14,%esp
  80181d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	8b 40 0c             	mov    0xc(%eax),%eax
  801826:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	b8 05 00 00 00       	mov    $0x5,%eax
  801835:	e8 2a ff ff ff       	call   801764 <fsipc>
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 2b                	js     801869 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80183e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801845:	00 
  801846:	89 1c 24             	mov    %ebx,(%esp)
  801849:	e8 c9 f2 ff ff       	call   800b17 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184e:	a1 80 70 80 00       	mov    0x807080,%eax
  801853:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801859:	a1 84 70 80 00       	mov    0x807084,%eax
  80185e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801864:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801869:	83 c4 14             	add    $0x14,%esp
  80186c:	5b                   	pop    %ebx
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801875:	c7 44 24 08 78 2c 80 	movl   $0x802c78,0x8(%esp)
  80187c:	00 
  80187d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801884:	00 
  801885:	c7 04 24 96 2c 80 00 	movl   $0x802c96,(%esp)
  80188c:	e8 c3 eb ff ff       	call   800454 <_panic>

00801891 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	83 ec 10             	sub    $0x10,%esp
  801899:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a2:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8018a7:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b7:	e8 a8 fe ff ff       	call   801764 <fsipc>
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 6a                	js     80192c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018c2:	39 c6                	cmp    %eax,%esi
  8018c4:	73 24                	jae    8018ea <devfile_read+0x59>
  8018c6:	c7 44 24 0c a1 2c 80 	movl   $0x802ca1,0xc(%esp)
  8018cd:	00 
  8018ce:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  8018d5:	00 
  8018d6:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018dd:	00 
  8018de:	c7 04 24 96 2c 80 00 	movl   $0x802c96,(%esp)
  8018e5:	e8 6a eb ff ff       	call   800454 <_panic>
	assert(r <= PGSIZE);
  8018ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ef:	7e 24                	jle    801915 <devfile_read+0x84>
  8018f1:	c7 44 24 0c bd 2c 80 	movl   $0x802cbd,0xc(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  801900:	00 
  801901:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801908:	00 
  801909:	c7 04 24 96 2c 80 00 	movl   $0x802c96,(%esp)
  801910:	e8 3f eb ff ff       	call   800454 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801915:	89 44 24 08          	mov    %eax,0x8(%esp)
  801919:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801920:	00 
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	89 04 24             	mov    %eax,(%esp)
  801927:	e8 64 f3 ff ff       	call   800c90 <memmove>
	return r;
}
  80192c:	89 d8                	mov    %ebx,%eax
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	83 ec 20             	sub    $0x20,%esp
  80193d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801940:	89 34 24             	mov    %esi,(%esp)
  801943:	e8 9c f1 ff ff       	call   800ae4 <strlen>
  801948:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80194d:	7f 60                	jg     8019af <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 45 f8 ff ff       	call   80119f <fd_alloc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 54                	js     8019b4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801960:	89 74 24 04          	mov    %esi,0x4(%esp)
  801964:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  80196b:	e8 a7 f1 ff ff       	call   800b17 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801970:	8b 45 0c             	mov    0xc(%ebp),%eax
  801973:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801978:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197b:	b8 01 00 00 00       	mov    $0x1,%eax
  801980:	e8 df fd ff ff       	call   801764 <fsipc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	85 c0                	test   %eax,%eax
  801989:	79 15                	jns    8019a0 <open+0x6b>
		fd_close(fd, 0);
  80198b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801992:	00 
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	89 04 24             	mov    %eax,(%esp)
  801999:	e8 04 f9 ff ff       	call   8012a2 <fd_close>
		return r;
  80199e:	eb 14                	jmp    8019b4 <open+0x7f>
	}

	return fd2num(fd);
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 c9 f7 ff ff       	call   801174 <fd2num>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	eb 05                	jmp    8019b4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019af:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b4:	89 d8                	mov    %ebx,%eax
  8019b6:	83 c4 20             	add    $0x20,%esp
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019cd:	e8 92 fd ff ff       	call   801764 <fsipc>
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	57                   	push   %edi
  8019d8:	56                   	push   %esi
  8019d9:	53                   	push   %ebx
  8019da:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019e7:	00 
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	89 04 24             	mov    %eax,(%esp)
  8019ee:	e8 42 ff ff ff       	call   801935 <open>
  8019f3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	0f 88 05 05 00 00    	js     801f06 <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a01:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a08:	00 
  801a09:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a13:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 fd fa ff ff       	call   80151e <readn>
  801a21:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a26:	75 0c                	jne    801a34 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801a28:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a2f:	45 4c 46 
  801a32:	74 3b                	je     801a6f <spawn+0x9b>
		close(fd);
  801a34:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a3a:	89 04 24             	mov    %eax,(%esp)
  801a3d:	e8 e8 f8 ff ff       	call   80132a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a42:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801a49:	46 
  801a4a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801a50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a54:	c7 04 24 c9 2c 80 00 	movl   $0x802cc9,(%esp)
  801a5b:	e8 ec ea ff ff       	call   80054c <cprintf>
		return -E_NOT_EXEC;
  801a60:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801a67:	ff ff ff 
  801a6a:	e9 a3 04 00 00       	jmp    801f12 <spawn+0x53e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801a6f:	ba 07 00 00 00       	mov    $0x7,%edx
  801a74:	89 d0                	mov    %edx,%eax
  801a76:	cd 30                	int    $0x30
  801a78:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a7e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a84:	85 c0                	test   %eax,%eax
  801a86:	0f 88 86 04 00 00    	js     801f12 <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801a98:	c1 e0 07             	shl    $0x7,%eax
  801a9b:	29 d0                	sub    %edx,%eax
  801a9d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801aa3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801aa9:	b9 11 00 00 00       	mov    $0x11,%ecx
  801aae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801ab0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ab6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801abc:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ac1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ac9:	eb 0d                	jmp    801ad8 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801acb:	89 04 24             	mov    %eax,(%esp)
  801ace:	e8 11 f0 ff ff       	call   800ae4 <strlen>
  801ad3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ad7:	46                   	inc    %esi
  801ad8:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801ada:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ae1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	75 e3                	jne    801acb <spawn+0xf7>
  801ae8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801aee:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801af4:	bf 00 10 40 00       	mov    $0x401000,%edi
  801af9:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801afb:	89 f8                	mov    %edi,%eax
  801afd:	83 e0 fc             	and    $0xfffffffc,%eax
  801b00:	f7 d2                	not    %edx
  801b02:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801b05:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b0b:	89 d0                	mov    %edx,%eax
  801b0d:	83 e8 08             	sub    $0x8,%eax
  801b10:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b15:	0f 86 08 04 00 00    	jbe    801f23 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b1b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b22:	00 
  801b23:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b2a:	00 
  801b2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b32:	e8 d2 f3 ff ff       	call   800f09 <sys_page_alloc>
  801b37:	85 c0                	test   %eax,%eax
  801b39:	0f 88 e9 03 00 00    	js     801f28 <spawn+0x554>
  801b3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b44:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b4d:	eb 2e                	jmp    801b7d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b4f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b55:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b5b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801b5e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b65:	89 3c 24             	mov    %edi,(%esp)
  801b68:	e8 aa ef ff ff       	call   800b17 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b6d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b70:	89 04 24             	mov    %eax,(%esp)
  801b73:	e8 6c ef ff ff       	call   800ae4 <strlen>
  801b78:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b7c:	43                   	inc    %ebx
  801b7d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801b83:	7c ca                	jl     801b4f <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b85:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b8b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b91:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b98:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b9e:	74 24                	je     801bc4 <spawn+0x1f0>
  801ba0:	c7 44 24 0c 40 2d 80 	movl   $0x802d40,0xc(%esp)
  801ba7:	00 
  801ba8:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  801baf:	00 
  801bb0:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801bb7:	00 
  801bb8:	c7 04 24 e3 2c 80 00 	movl   $0x802ce3,(%esp)
  801bbf:	e8 90 e8 ff ff       	call   800454 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bc4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bca:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bcf:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bd5:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801bd8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bde:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801be1:	89 d0                	mov    %edx,%eax
  801be3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801be8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bee:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801bf5:	00 
  801bf6:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801bfd:	ee 
  801bfe:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c08:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c0f:	00 
  801c10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c17:	e8 41 f3 ff ff       	call   800f5d <sys_page_map>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 1a                	js     801c3c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c22:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c29:	00 
  801c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c31:	e8 7a f3 ff ff       	call   800fb0 <sys_page_unmap>
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	79 1f                	jns    801c5b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c3c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c43:	00 
  801c44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4b:	e8 60 f3 ff ff       	call   800fb0 <sys_page_unmap>
	return r;
  801c50:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801c56:	e9 b7 02 00 00       	jmp    801f12 <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c5b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801c61:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801c67:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c6d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801c74:	00 00 00 
  801c77:	e9 bb 01 00 00       	jmp    801e37 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801c7c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c82:	83 38 01             	cmpl   $0x1,(%eax)
  801c85:	0f 85 9f 01 00 00    	jne    801e2a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c8b:	89 c2                	mov    %eax,%edx
  801c8d:	8b 40 18             	mov    0x18(%eax),%eax
  801c90:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c93:	83 f8 01             	cmp    $0x1,%eax
  801c96:	19 c0                	sbb    %eax,%eax
  801c98:	83 e0 fe             	and    $0xfffffffe,%eax
  801c9b:	83 c0 07             	add    $0x7,%eax
  801c9e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ca4:	8b 52 04             	mov    0x4(%edx),%edx
  801ca7:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801cad:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cb3:	8b 40 10             	mov    0x10(%eax),%eax
  801cb6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801cbc:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801cc2:	8b 52 14             	mov    0x14(%edx),%edx
  801cc5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801ccb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cd1:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801cd4:	89 f8                	mov    %edi,%eax
  801cd6:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cdb:	74 16                	je     801cf3 <spawn+0x31f>
		va -= i;
  801cdd:	29 c7                	sub    %eax,%edi
		memsz += i;
  801cdf:	01 c2                	add    %eax,%edx
  801ce1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801ce7:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ced:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf8:	e9 1f 01 00 00       	jmp    801e1c <spawn+0x448>
		if (i >= filesz) {
  801cfd:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801d03:	77 2b                	ja     801d30 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d05:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d13:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d19:	89 04 24             	mov    %eax,(%esp)
  801d1c:	e8 e8 f1 ff ff       	call   800f09 <sys_page_alloc>
  801d21:	85 c0                	test   %eax,%eax
  801d23:	0f 89 e7 00 00 00    	jns    801e10 <spawn+0x43c>
  801d29:	89 c6                	mov    %eax,%esi
  801d2b:	e9 b2 01 00 00       	jmp    801ee2 <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d30:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d37:	00 
  801d38:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d3f:	00 
  801d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d47:	e8 bd f1 ff ff       	call   800f09 <sys_page_alloc>
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	0f 88 84 01 00 00    	js     801ed8 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d54:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801d5a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d60:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d66:	89 04 24             	mov    %eax,(%esp)
  801d69:	e8 86 f8 ff ff       	call   8015f4 <seek>
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 66 01 00 00    	js     801edc <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d76:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d7c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d83:	76 05                	jbe    801d8a <spawn+0x3b6>
  801d85:	b8 00 10 00 00       	mov    $0x1000,%eax
  801d8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d8e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d95:	00 
  801d96:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 7a f7 ff ff       	call   80151e <readn>
  801da4:	85 c0                	test   %eax,%eax
  801da6:	0f 88 34 01 00 00    	js     801ee0 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801dac:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801db2:	89 54 24 10          	mov    %edx,0x10(%esp)
  801db6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801dba:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801dc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dcb:	00 
  801dcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd3:	e8 85 f1 ff ff       	call   800f5d <sys_page_map>
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	79 20                	jns    801dfc <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801ddc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de0:	c7 44 24 08 ef 2c 80 	movl   $0x802cef,0x8(%esp)
  801de7:	00 
  801de8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801def:	00 
  801df0:	c7 04 24 e3 2c 80 00 	movl   $0x802ce3,(%esp)
  801df7:	e8 58 e6 ff ff       	call   800454 <_panic>
			sys_page_unmap(0, UTEMP);
  801dfc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e03:	00 
  801e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0b:	e8 a0 f1 ff ff       	call   800fb0 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e10:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e16:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801e1c:	89 de                	mov    %ebx,%esi
  801e1e:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801e24:	0f 87 d3 fe ff ff    	ja     801cfd <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e2a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801e30:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801e37:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e3e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801e44:	0f 8c 32 fe ff ff    	jl     801c7c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801e4a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e50:	89 04 24             	mov    %eax,(%esp)
  801e53:	e8 d2 f4 ff ff       	call   80132a <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e58:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e5f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e62:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e72:	89 04 24             	mov    %eax,(%esp)
  801e75:	e8 dc f1 ff ff       	call   801056 <sys_env_set_trapframe>
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	79 20                	jns    801e9e <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  801e7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e82:	c7 44 24 08 0c 2d 80 	movl   $0x802d0c,0x8(%esp)
  801e89:	00 
  801e8a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801e91:	00 
  801e92:	c7 04 24 e3 2c 80 00 	movl   $0x802ce3,(%esp)
  801e99:	e8 b6 e5 ff ff       	call   800454 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e9e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801ea5:	00 
  801ea6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 4f f1 ff ff       	call   801003 <sys_env_set_status>
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	79 5a                	jns    801f12 <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  801eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebc:	c7 44 24 08 26 2d 80 	movl   $0x802d26,0x8(%esp)
  801ec3:	00 
  801ec4:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801ecb:	00 
  801ecc:	c7 04 24 e3 2c 80 00 	movl   $0x802ce3,(%esp)
  801ed3:	e8 7c e5 ff ff       	call   800454 <_panic>
  801ed8:	89 c6                	mov    %eax,%esi
  801eda:	eb 06                	jmp    801ee2 <spawn+0x50e>
  801edc:	89 c6                	mov    %eax,%esi
  801ede:	eb 02                	jmp    801ee2 <spawn+0x50e>
  801ee0:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801ee2:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	e8 89 ef ff ff       	call   800e79 <sys_env_destroy>
	close(fd);
  801ef0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ef6:	89 04 24             	mov    %eax,(%esp)
  801ef9:	e8 2c f4 ff ff       	call   80132a <close>
	return r;
  801efe:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801f04:	eb 0c                	jmp    801f12 <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801f06:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f0c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f12:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f18:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5f                   	pop    %edi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801f23:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801f28:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801f2e:	eb e2                	jmp    801f12 <spawn+0x53e>

00801f30 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	57                   	push   %edi
  801f34:	56                   	push   %esi
  801f35:	53                   	push   %ebx
  801f36:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801f39:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f3c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f41:	eb 03                	jmp    801f46 <spawnl+0x16>
		argc++;
  801f43:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f44:	89 d0                	mov    %edx,%eax
  801f46:	8d 50 04             	lea    0x4(%eax),%edx
  801f49:	83 38 00             	cmpl   $0x0,(%eax)
  801f4c:	75 f5                	jne    801f43 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f4e:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801f55:	83 e0 f0             	and    $0xfffffff0,%eax
  801f58:	29 c4                	sub    %eax,%esp
  801f5a:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801f5e:	83 e7 f0             	and    $0xfffffff0,%edi
  801f61:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f66:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801f68:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801f6f:	00 

	va_start(vl, arg0);
  801f70:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
  801f78:	eb 09                	jmp    801f83 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801f7a:	40                   	inc    %eax
  801f7b:	8b 1a                	mov    (%edx),%ebx
  801f7d:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801f80:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f83:	39 c8                	cmp    %ecx,%eax
  801f85:	75 f3                	jne    801f7a <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	89 04 24             	mov    %eax,(%esp)
  801f91:	e8 3e fa ff ff       	call   8019d4 <spawn>
}
  801f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    
	...

00801fa0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	83 ec 10             	sub    $0x10,%esp
  801fa8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 ce f1 ff ff       	call   801184 <fd2data>
  801fb6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801fb8:	c7 44 24 04 68 2d 80 	movl   $0x802d68,0x4(%esp)
  801fbf:	00 
  801fc0:	89 34 24             	mov    %esi,(%esp)
  801fc3:	e8 4f eb ff ff       	call   800b17 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fc8:	8b 43 04             	mov    0x4(%ebx),%eax
  801fcb:	2b 03                	sub    (%ebx),%eax
  801fcd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801fd3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801fda:	00 00 00 
	stat->st_dev = &devpipe;
  801fdd:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  801fe4:	47 80 00 
	return 0;
}
  801fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	5b                   	pop    %ebx
  801ff0:	5e                   	pop    %esi
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    

00801ff3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	53                   	push   %ebx
  801ff7:	83 ec 14             	sub    $0x14,%esp
  801ffa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ffd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802001:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802008:	e8 a3 ef ff ff       	call   800fb0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80200d:	89 1c 24             	mov    %ebx,(%esp)
  802010:	e8 6f f1 ff ff       	call   801184 <fd2data>
  802015:	89 44 24 04          	mov    %eax,0x4(%esp)
  802019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802020:	e8 8b ef ff ff       	call   800fb0 <sys_page_unmap>
}
  802025:	83 c4 14             	add    $0x14,%esp
  802028:	5b                   	pop    %ebx
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    

0080202b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	57                   	push   %edi
  80202f:	56                   	push   %esi
  802030:	53                   	push   %ebx
  802031:	83 ec 2c             	sub    $0x2c,%esp
  802034:	89 c7                	mov    %eax,%edi
  802036:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802039:	a1 90 67 80 00       	mov    0x806790,%eax
  80203e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802041:	89 3c 24             	mov    %edi,(%esp)
  802044:	e8 53 04 00 00       	call   80249c <pageref>
  802049:	89 c6                	mov    %eax,%esi
  80204b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80204e:	89 04 24             	mov    %eax,(%esp)
  802051:	e8 46 04 00 00       	call   80249c <pageref>
  802056:	39 c6                	cmp    %eax,%esi
  802058:	0f 94 c0             	sete   %al
  80205b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80205e:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802064:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802067:	39 cb                	cmp    %ecx,%ebx
  802069:	75 08                	jne    802073 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80206b:	83 c4 2c             	add    $0x2c,%esp
  80206e:	5b                   	pop    %ebx
  80206f:	5e                   	pop    %esi
  802070:	5f                   	pop    %edi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802073:	83 f8 01             	cmp    $0x1,%eax
  802076:	75 c1                	jne    802039 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802078:	8b 42 58             	mov    0x58(%edx),%eax
  80207b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802082:	00 
  802083:	89 44 24 08          	mov    %eax,0x8(%esp)
  802087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80208b:	c7 04 24 6f 2d 80 00 	movl   $0x802d6f,(%esp)
  802092:	e8 b5 e4 ff ff       	call   80054c <cprintf>
  802097:	eb a0                	jmp    802039 <_pipeisclosed+0xe>

00802099 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	57                   	push   %edi
  80209d:	56                   	push   %esi
  80209e:	53                   	push   %ebx
  80209f:	83 ec 1c             	sub    $0x1c,%esp
  8020a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020a5:	89 34 24             	mov    %esi,(%esp)
  8020a8:	e8 d7 f0 ff ff       	call   801184 <fd2data>
  8020ad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020af:	bf 00 00 00 00       	mov    $0x0,%edi
  8020b4:	eb 3c                	jmp    8020f2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020b6:	89 da                	mov    %ebx,%edx
  8020b8:	89 f0                	mov    %esi,%eax
  8020ba:	e8 6c ff ff ff       	call   80202b <_pipeisclosed>
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	75 38                	jne    8020fb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020c3:	e8 22 ee ff ff       	call   800eea <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020c8:	8b 43 04             	mov    0x4(%ebx),%eax
  8020cb:	8b 13                	mov    (%ebx),%edx
  8020cd:	83 c2 20             	add    $0x20,%edx
  8020d0:	39 d0                	cmp    %edx,%eax
  8020d2:	73 e2                	jae    8020b6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8020da:	89 c2                	mov    %eax,%edx
  8020dc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8020e2:	79 05                	jns    8020e9 <devpipe_write+0x50>
  8020e4:	4a                   	dec    %edx
  8020e5:	83 ca e0             	or     $0xffffffe0,%edx
  8020e8:	42                   	inc    %edx
  8020e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020ed:	40                   	inc    %eax
  8020ee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f1:	47                   	inc    %edi
  8020f2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020f5:	75 d1                	jne    8020c8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020f7:	89 f8                	mov    %edi,%eax
  8020f9:	eb 05                	jmp    802100 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	57                   	push   %edi
  80210c:	56                   	push   %esi
  80210d:	53                   	push   %ebx
  80210e:	83 ec 1c             	sub    $0x1c,%esp
  802111:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802114:	89 3c 24             	mov    %edi,(%esp)
  802117:	e8 68 f0 ff ff       	call   801184 <fd2data>
  80211c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80211e:	be 00 00 00 00       	mov    $0x0,%esi
  802123:	eb 3a                	jmp    80215f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802125:	85 f6                	test   %esi,%esi
  802127:	74 04                	je     80212d <devpipe_read+0x25>
				return i;
  802129:	89 f0                	mov    %esi,%eax
  80212b:	eb 40                	jmp    80216d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80212d:	89 da                	mov    %ebx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	e8 f5 fe ff ff       	call   80202b <_pipeisclosed>
  802136:	85 c0                	test   %eax,%eax
  802138:	75 2e                	jne    802168 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80213a:	e8 ab ed ff ff       	call   800eea <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80213f:	8b 03                	mov    (%ebx),%eax
  802141:	3b 43 04             	cmp    0x4(%ebx),%eax
  802144:	74 df                	je     802125 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802146:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80214b:	79 05                	jns    802152 <devpipe_read+0x4a>
  80214d:	48                   	dec    %eax
  80214e:	83 c8 e0             	or     $0xffffffe0,%eax
  802151:	40                   	inc    %eax
  802152:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802156:	8b 55 0c             	mov    0xc(%ebp),%edx
  802159:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80215c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80215e:	46                   	inc    %esi
  80215f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802162:	75 db                	jne    80213f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802164:	89 f0                	mov    %esi,%eax
  802166:	eb 05                	jmp    80216d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802168:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80216d:	83 c4 1c             	add    $0x1c,%esp
  802170:	5b                   	pop    %ebx
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    

00802175 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	57                   	push   %edi
  802179:	56                   	push   %esi
  80217a:	53                   	push   %ebx
  80217b:	83 ec 3c             	sub    $0x3c,%esp
  80217e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802181:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802184:	89 04 24             	mov    %eax,(%esp)
  802187:	e8 13 f0 ff ff       	call   80119f <fd_alloc>
  80218c:	89 c3                	mov    %eax,%ebx
  80218e:	85 c0                	test   %eax,%eax
  802190:	0f 88 45 01 00 00    	js     8022db <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802196:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80219d:	00 
  80219e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ac:	e8 58 ed ff ff       	call   800f09 <sys_page_alloc>
  8021b1:	89 c3                	mov    %eax,%ebx
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	0f 88 20 01 00 00    	js     8022db <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8021be:	89 04 24             	mov    %eax,(%esp)
  8021c1:	e8 d9 ef ff ff       	call   80119f <fd_alloc>
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	0f 88 f8 00 00 00    	js     8022c8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021d7:	00 
  8021d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e6:	e8 1e ed ff ff       	call   800f09 <sys_page_alloc>
  8021eb:	89 c3                	mov    %eax,%ebx
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	0f 88 d3 00 00 00    	js     8022c8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021f8:	89 04 24             	mov    %eax,(%esp)
  8021fb:	e8 84 ef ff ff       	call   801184 <fd2data>
  802200:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802202:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802209:	00 
  80220a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802215:	e8 ef ec ff ff       	call   800f09 <sys_page_alloc>
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	85 c0                	test   %eax,%eax
  80221e:	0f 88 91 00 00 00    	js     8022b5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802224:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802227:	89 04 24             	mov    %eax,(%esp)
  80222a:	e8 55 ef ff ff       	call   801184 <fd2data>
  80222f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802236:	00 
  802237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80223b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802242:	00 
  802243:	89 74 24 04          	mov    %esi,0x4(%esp)
  802247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80224e:	e8 0a ed ff ff       	call   800f5d <sys_page_map>
  802253:	89 c3                	mov    %eax,%ebx
  802255:	85 c0                	test   %eax,%eax
  802257:	78 4c                	js     8022a5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802259:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80225f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802262:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802267:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80226e:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802274:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802277:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802279:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80227c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802286:	89 04 24             	mov    %eax,(%esp)
  802289:	e8 e6 ee ff ff       	call   801174 <fd2num>
  80228e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802290:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802293:	89 04 24             	mov    %eax,(%esp)
  802296:	e8 d9 ee ff ff       	call   801174 <fd2num>
  80229b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80229e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022a3:	eb 36                	jmp    8022db <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8022a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b0:	e8 fb ec ff ff       	call   800fb0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c3:	e8 e8 ec ff ff       	call   800fb0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d6:	e8 d5 ec ff ff       	call   800fb0 <sys_page_unmap>
    err:
	return r;
}
  8022db:	89 d8                	mov    %ebx,%eax
  8022dd:	83 c4 3c             	add    $0x3c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    

008022e5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	89 04 24             	mov    %eax,(%esp)
  8022f8:	e8 f5 ee ff ff       	call   8011f2 <fd_lookup>
  8022fd:	85 c0                	test   %eax,%eax
  8022ff:	78 15                	js     802316 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802304:	89 04 24             	mov    %eax,(%esp)
  802307:	e8 78 ee ff ff       	call   801184 <fd2data>
	return _pipeisclosed(fd, p);
  80230c:	89 c2                	mov    %eax,%edx
  80230e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802311:	e8 15 fd ff ff       	call   80202b <_pipeisclosed>
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	56                   	push   %esi
  80231c:	53                   	push   %ebx
  80231d:	83 ec 10             	sub    $0x10,%esp
  802320:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802323:	85 f6                	test   %esi,%esi
  802325:	75 24                	jne    80234b <wait+0x33>
  802327:	c7 44 24 0c 87 2d 80 	movl   $0x802d87,0xc(%esp)
  80232e:	00 
  80232f:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  802336:	00 
  802337:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80233e:	00 
  80233f:	c7 04 24 92 2d 80 00 	movl   $0x802d92,(%esp)
  802346:	e8 09 e1 ff ff       	call   800454 <_panic>
	e = &envs[ENVX(envid)];
  80234b:	89 f3                	mov    %esi,%ebx
  80234d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802353:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80235a:	c1 e3 07             	shl    $0x7,%ebx
  80235d:	29 c3                	sub    %eax,%ebx
  80235f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802365:	eb 05                	jmp    80236c <wait+0x54>
		sys_yield();
  802367:	e8 7e eb ff ff       	call   800eea <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80236c:	8b 43 48             	mov    0x48(%ebx),%eax
  80236f:	39 f0                	cmp    %esi,%eax
  802371:	75 07                	jne    80237a <wait+0x62>
  802373:	8b 43 54             	mov    0x54(%ebx),%eax
  802376:	85 c0                	test   %eax,%eax
  802378:	75 ed                	jne    802367 <wait+0x4f>
		sys_yield();
}
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    
  802381:	00 00                	add    %al,(%eax)
	...

00802384 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
  802387:	56                   	push   %esi
  802388:	53                   	push   %ebx
  802389:	83 ec 10             	sub    $0x10,%esp
  80238c:	8b 75 08             	mov    0x8(%ebp),%esi
  80238f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802392:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802395:	85 c0                	test   %eax,%eax
  802397:	75 05                	jne    80239e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  802399:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80239e:	89 04 24             	mov    %eax,(%esp)
  8023a1:	e8 79 ed ff ff       	call   80111f <sys_ipc_recv>
	if (!err) {
  8023a6:	85 c0                	test   %eax,%eax
  8023a8:	75 26                	jne    8023d0 <ipc_recv+0x4c>
		if (from_env_store) {
  8023aa:	85 f6                	test   %esi,%esi
  8023ac:	74 0a                	je     8023b8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8023ae:	a1 90 67 80 00       	mov    0x806790,%eax
  8023b3:	8b 40 74             	mov    0x74(%eax),%eax
  8023b6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8023b8:	85 db                	test   %ebx,%ebx
  8023ba:	74 0a                	je     8023c6 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8023bc:	a1 90 67 80 00       	mov    0x806790,%eax
  8023c1:	8b 40 78             	mov    0x78(%eax),%eax
  8023c4:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8023c6:	a1 90 67 80 00       	mov    0x806790,%eax
  8023cb:	8b 40 70             	mov    0x70(%eax),%eax
  8023ce:	eb 14                	jmp    8023e4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8023d0:	85 f6                	test   %esi,%esi
  8023d2:	74 06                	je     8023da <ipc_recv+0x56>
		*from_env_store = 0;
  8023d4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8023da:	85 db                	test   %ebx,%ebx
  8023dc:	74 06                	je     8023e4 <ipc_recv+0x60>
		*perm_store = 0;
  8023de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8023e4:	83 c4 10             	add    $0x10,%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    

008023eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	57                   	push   %edi
  8023ef:	56                   	push   %esi
  8023f0:	53                   	push   %ebx
  8023f1:	83 ec 1c             	sub    $0x1c,%esp
  8023f4:	8b 75 10             	mov    0x10(%ebp),%esi
  8023f7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8023fa:	85 f6                	test   %esi,%esi
  8023fc:	75 05                	jne    802403 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8023fe:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  802403:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802407:	89 74 24 08          	mov    %esi,0x8(%esp)
  80240b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80240e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802412:	8b 45 08             	mov    0x8(%ebp),%eax
  802415:	89 04 24             	mov    %eax,(%esp)
  802418:	e8 df ec ff ff       	call   8010fc <sys_ipc_try_send>
  80241d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80241f:	e8 c6 ea ff ff       	call   800eea <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802424:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802427:	74 da                	je     802403 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802429:	85 db                	test   %ebx,%ebx
  80242b:	74 20                	je     80244d <ipc_send+0x62>
		panic("send fail: %e", err);
  80242d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802431:	c7 44 24 08 9d 2d 80 	movl   $0x802d9d,0x8(%esp)
  802438:	00 
  802439:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802440:	00 
  802441:	c7 04 24 ab 2d 80 00 	movl   $0x802dab,(%esp)
  802448:	e8 07 e0 ff ff       	call   800454 <_panic>
	}
	return;
}
  80244d:	83 c4 1c             	add    $0x1c,%esp
  802450:	5b                   	pop    %ebx
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    

00802455 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	53                   	push   %ebx
  802459:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80245c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802461:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802468:	89 c2                	mov    %eax,%edx
  80246a:	c1 e2 07             	shl    $0x7,%edx
  80246d:	29 ca                	sub    %ecx,%edx
  80246f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802475:	8b 52 50             	mov    0x50(%edx),%edx
  802478:	39 da                	cmp    %ebx,%edx
  80247a:	75 0f                	jne    80248b <ipc_find_env+0x36>
			return envs[i].env_id;
  80247c:	c1 e0 07             	shl    $0x7,%eax
  80247f:	29 c8                	sub    %ecx,%eax
  802481:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802486:	8b 40 40             	mov    0x40(%eax),%eax
  802489:	eb 0c                	jmp    802497 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80248b:	40                   	inc    %eax
  80248c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802491:	75 ce                	jne    802461 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802493:	66 b8 00 00          	mov    $0x0,%ax
}
  802497:	5b                   	pop    %ebx
  802498:	5d                   	pop    %ebp
  802499:	c3                   	ret    
	...

0080249c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024a2:	89 c2                	mov    %eax,%edx
  8024a4:	c1 ea 16             	shr    $0x16,%edx
  8024a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024ae:	f6 c2 01             	test   $0x1,%dl
  8024b1:	74 1e                	je     8024d1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024b3:	c1 e8 0c             	shr    $0xc,%eax
  8024b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024bd:	a8 01                	test   $0x1,%al
  8024bf:	74 17                	je     8024d8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c1:	c1 e8 0c             	shr    $0xc,%eax
  8024c4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024cb:	ef 
  8024cc:	0f b7 c0             	movzwl %ax,%eax
  8024cf:	eb 0c                	jmp    8024dd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d6:	eb 05                	jmp    8024dd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024d8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    
	...

008024e0 <__udivdi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	83 ec 10             	sub    $0x10,%esp
  8024e6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024ea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8024f6:	89 cd                	mov    %ecx,%ebp
  8024f8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8024fc:	85 c0                	test   %eax,%eax
  8024fe:	75 2c                	jne    80252c <__udivdi3+0x4c>
  802500:	39 f9                	cmp    %edi,%ecx
  802502:	77 68                	ja     80256c <__udivdi3+0x8c>
  802504:	85 c9                	test   %ecx,%ecx
  802506:	75 0b                	jne    802513 <__udivdi3+0x33>
  802508:	b8 01 00 00 00       	mov    $0x1,%eax
  80250d:	31 d2                	xor    %edx,%edx
  80250f:	f7 f1                	div    %ecx
  802511:	89 c1                	mov    %eax,%ecx
  802513:	31 d2                	xor    %edx,%edx
  802515:	89 f8                	mov    %edi,%eax
  802517:	f7 f1                	div    %ecx
  802519:	89 c7                	mov    %eax,%edi
  80251b:	89 f0                	mov    %esi,%eax
  80251d:	f7 f1                	div    %ecx
  80251f:	89 c6                	mov    %eax,%esi
  802521:	89 f0                	mov    %esi,%eax
  802523:	89 fa                	mov    %edi,%edx
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	5e                   	pop    %esi
  802529:	5f                   	pop    %edi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    
  80252c:	39 f8                	cmp    %edi,%eax
  80252e:	77 2c                	ja     80255c <__udivdi3+0x7c>
  802530:	0f bd f0             	bsr    %eax,%esi
  802533:	83 f6 1f             	xor    $0x1f,%esi
  802536:	75 4c                	jne    802584 <__udivdi3+0xa4>
  802538:	39 f8                	cmp    %edi,%eax
  80253a:	bf 00 00 00 00       	mov    $0x0,%edi
  80253f:	72 0a                	jb     80254b <__udivdi3+0x6b>
  802541:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802545:	0f 87 ad 00 00 00    	ja     8025f8 <__udivdi3+0x118>
  80254b:	be 01 00 00 00       	mov    $0x1,%esi
  802550:	89 f0                	mov    %esi,%eax
  802552:	89 fa                	mov    %edi,%edx
  802554:	83 c4 10             	add    $0x10,%esp
  802557:	5e                   	pop    %esi
  802558:	5f                   	pop    %edi
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    
  80255b:	90                   	nop
  80255c:	31 ff                	xor    %edi,%edi
  80255e:	31 f6                	xor    %esi,%esi
  802560:	89 f0                	mov    %esi,%eax
  802562:	89 fa                	mov    %edi,%edx
  802564:	83 c4 10             	add    $0x10,%esp
  802567:	5e                   	pop    %esi
  802568:	5f                   	pop    %edi
  802569:	5d                   	pop    %ebp
  80256a:	c3                   	ret    
  80256b:	90                   	nop
  80256c:	89 fa                	mov    %edi,%edx
  80256e:	89 f0                	mov    %esi,%eax
  802570:	f7 f1                	div    %ecx
  802572:	89 c6                	mov    %eax,%esi
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 f0                	mov    %esi,%eax
  802578:	89 fa                	mov    %edi,%edx
  80257a:	83 c4 10             	add    $0x10,%esp
  80257d:	5e                   	pop    %esi
  80257e:	5f                   	pop    %edi
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    
  802581:	8d 76 00             	lea    0x0(%esi),%esi
  802584:	89 f1                	mov    %esi,%ecx
  802586:	d3 e0                	shl    %cl,%eax
  802588:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80258c:	b8 20 00 00 00       	mov    $0x20,%eax
  802591:	29 f0                	sub    %esi,%eax
  802593:	89 ea                	mov    %ebp,%edx
  802595:	88 c1                	mov    %al,%cl
  802597:	d3 ea                	shr    %cl,%edx
  802599:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80259d:	09 ca                	or     %ecx,%edx
  80259f:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025a3:	89 f1                	mov    %esi,%ecx
  8025a5:	d3 e5                	shl    %cl,%ebp
  8025a7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8025ab:	89 fd                	mov    %edi,%ebp
  8025ad:	88 c1                	mov    %al,%cl
  8025af:	d3 ed                	shr    %cl,%ebp
  8025b1:	89 fa                	mov    %edi,%edx
  8025b3:	89 f1                	mov    %esi,%ecx
  8025b5:	d3 e2                	shl    %cl,%edx
  8025b7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025bb:	88 c1                	mov    %al,%cl
  8025bd:	d3 ef                	shr    %cl,%edi
  8025bf:	09 d7                	or     %edx,%edi
  8025c1:	89 f8                	mov    %edi,%eax
  8025c3:	89 ea                	mov    %ebp,%edx
  8025c5:	f7 74 24 08          	divl   0x8(%esp)
  8025c9:	89 d1                	mov    %edx,%ecx
  8025cb:	89 c7                	mov    %eax,%edi
  8025cd:	f7 64 24 0c          	mull   0xc(%esp)
  8025d1:	39 d1                	cmp    %edx,%ecx
  8025d3:	72 17                	jb     8025ec <__udivdi3+0x10c>
  8025d5:	74 09                	je     8025e0 <__udivdi3+0x100>
  8025d7:	89 fe                	mov    %edi,%esi
  8025d9:	31 ff                	xor    %edi,%edi
  8025db:	e9 41 ff ff ff       	jmp    802521 <__udivdi3+0x41>
  8025e0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025e4:	89 f1                	mov    %esi,%ecx
  8025e6:	d3 e2                	shl    %cl,%edx
  8025e8:	39 c2                	cmp    %eax,%edx
  8025ea:	73 eb                	jae    8025d7 <__udivdi3+0xf7>
  8025ec:	8d 77 ff             	lea    -0x1(%edi),%esi
  8025ef:	31 ff                	xor    %edi,%edi
  8025f1:	e9 2b ff ff ff       	jmp    802521 <__udivdi3+0x41>
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	31 f6                	xor    %esi,%esi
  8025fa:	e9 22 ff ff ff       	jmp    802521 <__udivdi3+0x41>
	...

00802600 <__umoddi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	83 ec 20             	sub    $0x20,%esp
  802606:	8b 44 24 30          	mov    0x30(%esp),%eax
  80260a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80260e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802612:	8b 74 24 34          	mov    0x34(%esp),%esi
  802616:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80261a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80261e:	89 c7                	mov    %eax,%edi
  802620:	89 f2                	mov    %esi,%edx
  802622:	85 ed                	test   %ebp,%ebp
  802624:	75 16                	jne    80263c <__umoddi3+0x3c>
  802626:	39 f1                	cmp    %esi,%ecx
  802628:	0f 86 a6 00 00 00    	jbe    8026d4 <__umoddi3+0xd4>
  80262e:	f7 f1                	div    %ecx
  802630:	89 d0                	mov    %edx,%eax
  802632:	31 d2                	xor    %edx,%edx
  802634:	83 c4 20             	add    $0x20,%esp
  802637:	5e                   	pop    %esi
  802638:	5f                   	pop    %edi
  802639:	5d                   	pop    %ebp
  80263a:	c3                   	ret    
  80263b:	90                   	nop
  80263c:	39 f5                	cmp    %esi,%ebp
  80263e:	0f 87 ac 00 00 00    	ja     8026f0 <__umoddi3+0xf0>
  802644:	0f bd c5             	bsr    %ebp,%eax
  802647:	83 f0 1f             	xor    $0x1f,%eax
  80264a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80264e:	0f 84 a8 00 00 00    	je     8026fc <__umoddi3+0xfc>
  802654:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802658:	d3 e5                	shl    %cl,%ebp
  80265a:	bf 20 00 00 00       	mov    $0x20,%edi
  80265f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802663:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802667:	89 f9                	mov    %edi,%ecx
  802669:	d3 e8                	shr    %cl,%eax
  80266b:	09 e8                	or     %ebp,%eax
  80266d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802671:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802675:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802679:	d3 e0                	shl    %cl,%eax
  80267b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267f:	89 f2                	mov    %esi,%edx
  802681:	d3 e2                	shl    %cl,%edx
  802683:	8b 44 24 14          	mov    0x14(%esp),%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80268d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802691:	89 f9                	mov    %edi,%ecx
  802693:	d3 e8                	shr    %cl,%eax
  802695:	09 d0                	or     %edx,%eax
  802697:	d3 ee                	shr    %cl,%esi
  802699:	89 f2                	mov    %esi,%edx
  80269b:	f7 74 24 18          	divl   0x18(%esp)
  80269f:	89 d6                	mov    %edx,%esi
  8026a1:	f7 64 24 0c          	mull   0xc(%esp)
  8026a5:	89 c5                	mov    %eax,%ebp
  8026a7:	89 d1                	mov    %edx,%ecx
  8026a9:	39 d6                	cmp    %edx,%esi
  8026ab:	72 67                	jb     802714 <__umoddi3+0x114>
  8026ad:	74 75                	je     802724 <__umoddi3+0x124>
  8026af:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026b3:	29 e8                	sub    %ebp,%eax
  8026b5:	19 ce                	sbb    %ecx,%esi
  8026b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	89 f2                	mov    %esi,%edx
  8026bf:	89 f9                	mov    %edi,%ecx
  8026c1:	d3 e2                	shl    %cl,%edx
  8026c3:	09 d0                	or     %edx,%eax
  8026c5:	89 f2                	mov    %esi,%edx
  8026c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	83 c4 20             	add    $0x20,%esp
  8026d0:	5e                   	pop    %esi
  8026d1:	5f                   	pop    %edi
  8026d2:	5d                   	pop    %ebp
  8026d3:	c3                   	ret    
  8026d4:	85 c9                	test   %ecx,%ecx
  8026d6:	75 0b                	jne    8026e3 <__umoddi3+0xe3>
  8026d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8026dd:	31 d2                	xor    %edx,%edx
  8026df:	f7 f1                	div    %ecx
  8026e1:	89 c1                	mov    %eax,%ecx
  8026e3:	89 f0                	mov    %esi,%eax
  8026e5:	31 d2                	xor    %edx,%edx
  8026e7:	f7 f1                	div    %ecx
  8026e9:	89 f8                	mov    %edi,%eax
  8026eb:	e9 3e ff ff ff       	jmp    80262e <__umoddi3+0x2e>
  8026f0:	89 f2                	mov    %esi,%edx
  8026f2:	83 c4 20             	add    $0x20,%esp
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d 76 00             	lea    0x0(%esi),%esi
  8026fc:	39 f5                	cmp    %esi,%ebp
  8026fe:	72 04                	jb     802704 <__umoddi3+0x104>
  802700:	39 f9                	cmp    %edi,%ecx
  802702:	77 06                	ja     80270a <__umoddi3+0x10a>
  802704:	89 f2                	mov    %esi,%edx
  802706:	29 cf                	sub    %ecx,%edi
  802708:	19 ea                	sbb    %ebp,%edx
  80270a:	89 f8                	mov    %edi,%eax
  80270c:	83 c4 20             	add    $0x20,%esp
  80270f:	5e                   	pop    %esi
  802710:	5f                   	pop    %edi
  802711:	5d                   	pop    %ebp
  802712:	c3                   	ret    
  802713:	90                   	nop
  802714:	89 d1                	mov    %edx,%ecx
  802716:	89 c5                	mov    %eax,%ebp
  802718:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80271c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802720:	eb 8d                	jmp    8026af <__umoddi3+0xaf>
  802722:	66 90                	xchg   %ax,%ax
  802724:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802728:	72 ea                	jb     802714 <__umoddi3+0x114>
  80272a:	89 f1                	mov    %esi,%ecx
  80272c:	eb 81                	jmp    8026af <__umoddi3+0xaf>
