
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 8b 02 00 00       	call   8002bc <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 5d 0e 00 00       	call   800ea2 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	4b                   	dec    %ebx
  800046:	75 f8                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  800048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80004f:	e8 8e 12 00 00       	call   8012e2 <close>
	if ((r = opencons()) < 0)
  800054:	e8 0f 02 00 00       	call   800268 <opencons>
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 20                	jns    80007d <umain+0x49>
		panic("opencons: %e", r);
  80005d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800061:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800070:	00 
  800071:	c7 04 24 0d 22 80 00 	movl   $0x80220d,(%esp)
  800078:	e8 af 02 00 00       	call   80032c <_panic>
	if (r != 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 20                	je     8000a1 <umain+0x6d>
		panic("first opencons used fd %d", r);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 1c 22 80 	movl   $0x80221c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 0d 22 80 00 	movl   $0x80220d,(%esp)
  80009c:	e8 8b 02 00 00       	call   80032c <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a8:	00 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 7e 12 00 00       	call   801333 <dup>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0xa5>
		panic("dup: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 36 22 80 	movl   $0x802236,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 0d 22 80 00 	movl   $0x80220d,(%esp)
  8000d4:	e8 53 02 00 00       	call   80032c <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000d9:	c7 04 24 3e 22 80 00 	movl   $0x80223e,(%esp)
  8000e0:	e8 d7 08 00 00       	call   8009bc <readline>
		if (buf != NULL)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	74 1a                	je     800103 <umain+0xcf>
			fprintf(1, "%s\n", buf);
  8000e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ed:	c7 44 24 04 4c 22 80 	movl   $0x80224c,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fc:	e8 7f 19 00 00       	call   801a80 <fprintf>
  800101:	eb d6                	jmp    8000d9 <umain+0xa5>
		else
			fprintf(1, "(end of file received)\n");
  800103:	c7 44 24 04 50 22 80 	movl   $0x802250,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800112:	e8 69 19 00 00       	call   801a80 <fprintf>
  800117:	eb c0                	jmp    8000d9 <umain+0xa5>
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80012c:	c7 44 24 04 68 22 80 	movl   $0x802268,0x4(%esp)
  800133:	00 
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 90 09 00 00       	call   800acf <strcpy>
	return 0;
}
  80013f:	b8 00 00 00 00       	mov    $0x0,%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800152:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800157:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80015d:	eb 30                	jmp    80018f <devcons_write+0x49>
		m = n - tot;
  80015f:	8b 75 10             	mov    0x10(%ebp),%esi
  800162:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800164:	83 fe 7f             	cmp    $0x7f,%esi
  800167:	76 05                	jbe    80016e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800169:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80016e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800172:	03 45 0c             	add    0xc(%ebp),%eax
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	89 3c 24             	mov    %edi,(%esp)
  80017c:	e8 c7 0a 00 00       	call   800c48 <memmove>
		sys_cputs(buf, m);
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 3c 24             	mov    %edi,(%esp)
  800188:	e8 67 0c 00 00       	call   800df4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80018d:	01 f3                	add    %esi,%ebx
  80018f:	89 d8                	mov    %ebx,%eax
  800191:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800194:	72 c9                	jb     80015f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8001a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001ab:	75 07                	jne    8001b4 <devcons_read+0x13>
  8001ad:	eb 25                	jmp    8001d4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001af:	e8 ee 0c 00 00       	call   800ea2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001b4:	e8 59 0c 00 00       	call   800e12 <sys_cgetc>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	74 f2                	je     8001af <devcons_read+0xe>
  8001bd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	78 1d                	js     8001e0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001c3:	83 f8 04             	cmp    $0x4,%eax
  8001c6:	74 13                	je     8001db <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	88 10                	mov    %dl,(%eax)
	return 1;
  8001cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8001d2:	eb 0c                	jmp    8001e0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	eb 05                	jmp    8001e0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f5:	00 
  8001f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 f3 0b 00 00       	call   800df4 <sys_cputs>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <getchar>:

int
getchar(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800209:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800210:	00 
  800211:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021f:	e8 22 12 00 00       	call   801446 <read>
	if (r < 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	78 0f                	js     800237 <getchar+0x34>
		return r;
	if (r < 1)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 06                	jle    800232 <getchar+0x2f>
		return -E_EOF;
	return c;
  80022c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800230:	eb 05                	jmp    800237 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800232:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80023f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 59 0f 00 00       	call   8011aa <fd_lookup>
  800251:	85 c0                	test   %eax,%eax
  800253:	78 11                	js     800266 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800258:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80025e:	39 10                	cmp    %edx,(%eax)
  800260:	0f 94 c0             	sete   %al
  800263:	0f b6 c0             	movzbl %al,%eax
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <opencons>:

int
opencons(void)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 de 0e 00 00       	call   801157 <fd_alloc>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 3c                	js     8002b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80027d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800284:	00 
  800285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800293:	e8 29 0c 00 00       	call   800ec1 <sys_page_alloc>
  800298:	85 c0                	test   %eax,%eax
  80029a:	78 1d                	js     8002b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80029c:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 73 0e 00 00       	call   80112c <fd2num>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
	...

008002bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 10             	sub    $0x10,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8002ca:	e8 b4 0b 00 00       	call   800e83 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002db:	c1 e0 07             	shl    $0x7,%eax
  8002de:	29 d0                	sub    %edx,%eax
  8002e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e5:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ea:	85 f6                	test   %esi,%esi
  8002ec:	7e 07                	jle    8002f5 <libmain+0x39>
		binaryname = argv[0];
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	e8 33 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800301:	e8 0a 00 00 00       	call   800310 <exit>
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    
  80030d:	00 00                	add    %al,(%eax)
	...

00800310 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800316:	e8 f8 0f 00 00       	call   801313 <close_all>
	sys_env_destroy(0);
  80031b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800322:	e8 0a 0b 00 00       	call   800e31 <sys_env_destroy>
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    
  800329:	00 00                	add    %al,(%eax)
	...

0080032c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
  800331:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800337:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  80033d:	e8 41 0b 00 00       	call   800e83 <sys_getenvid>
  800342:	8b 55 0c             	mov    0xc(%ebp),%edx
  800345:	89 54 24 10          	mov    %edx,0x10(%esp)
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800350:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	c7 04 24 80 22 80 00 	movl   $0x802280,(%esp)
  80035f:	e8 c0 00 00 00       	call   800424 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 45 10             	mov    0x10(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 50 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  800373:	c7 04 24 66 22 80 00 	movl   $0x802266,(%esp)
  80037a:	e8 a5 00 00 00       	call   800424 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037f:	cc                   	int3   
  800380:	eb fd                	jmp    80037f <_panic+0x53>
	...

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 14             	sub    $0x14,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 03                	mov    (%ebx),%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800397:	40                   	inc    %eax
  800398:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039f:	75 19                	jne    8003ba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003a8:	00 
  8003a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 40 0a 00 00       	call   800df4 <sys_cputs>
		b->idx = 0;
  8003b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ba:	ff 43 04             	incl   0x4(%ebx)
}
  8003bd:	83 c4 14             	add    $0x14,%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  8003ff:	e8 82 01 00 00       	call   800586 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800404:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80040a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	e8 d8 09 00 00       	call   800df4 <sys_cputs>

	return b.cnt;
}
  80041c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 87 ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    
	...

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 3c             	sub    $0x3c,%esp
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80045d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800460:	85 c0                	test   %eax,%eax
  800462:	75 08                	jne    80046c <printnum+0x2c>
  800464:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800467:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046a:	77 57                	ja     8004c3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800470:	4b                   	dec    %ebx
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	8b 45 10             	mov    0x10(%ebp),%eax
  800478:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800480:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800484:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048b:	00 
  80048c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	e8 fa 1a 00 00       	call   801f98 <__udivdi3>
  80049e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ad:	89 fa                	mov    %edi,%edx
  8004af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b2:	e8 89 ff ff ff       	call   800440 <printnum>
  8004b7:	eb 0f                	jmp    8004c8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bd:	89 34 24             	mov    %esi,(%esp)
  8004c0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c3:	4b                   	dec    %ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f f1                	jg     8004b9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004de:	00 
  8004df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	e8 c7 1b 00 00       	call   8020b8 <__umoddi3>
  8004f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f5:	0f be 80 a3 22 80 00 	movsbl 0x8022a3(%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800502:	83 c4 3c             	add    $0x3c,%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050d:	83 fa 01             	cmp    $0x1,%edx
  800510:	7e 0e                	jle    800520 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800512:	8b 10                	mov    (%eax),%edx
  800514:	8d 4a 08             	lea    0x8(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 02                	mov    (%edx),%eax
  80051b:	8b 52 04             	mov    0x4(%edx),%edx
  80051e:	eb 22                	jmp    800542 <getuint+0x38>
	else if (lflag)
  800520:	85 d2                	test   %edx,%edx
  800522:	74 10                	je     800534 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800524:	8b 10                	mov    (%eax),%edx
  800526:	8d 4a 04             	lea    0x4(%edx),%ecx
  800529:	89 08                	mov    %ecx,(%eax)
  80052b:	8b 02                	mov    (%edx),%eax
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
  800532:	eb 0e                	jmp    800542 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800534:	8b 10                	mov    (%eax),%edx
  800536:	8d 4a 04             	lea    0x4(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	3b 50 04             	cmp    0x4(%eax),%edx
  800552:	73 08                	jae    80055c <sprintputch+0x18>
		*b->buf++ = ch;
  800554:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800557:	88 0a                	mov    %cl,(%edx)
  800559:	42                   	inc    %edx
  80055a:	89 10                	mov    %edx,(%eax)
}
  80055c:	5d                   	pop    %ebp
  80055d:	c3                   	ret    

0080055e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800564:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800567:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056b:	8b 45 10             	mov    0x10(%ebp),%eax
  80056e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	8b 45 08             	mov    0x8(%ebp),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	e8 02 00 00 00       	call   800586 <vprintfmt>
	va_end(ap);
}
  800584:	c9                   	leave  
  800585:	c3                   	ret    

00800586 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	57                   	push   %edi
  80058a:	56                   	push   %esi
  80058b:	53                   	push   %ebx
  80058c:	83 ec 4c             	sub    $0x4c,%esp
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	8b 75 10             	mov    0x10(%ebp),%esi
  800595:	eb 12                	jmp    8005a9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800597:	85 c0                	test   %eax,%eax
  800599:	0f 84 8b 03 00 00    	je     80092a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80059f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a9:	0f b6 06             	movzbl (%esi),%eax
  8005ac:	46                   	inc    %esi
  8005ad:	83 f8 25             	cmp    $0x25,%eax
  8005b0:	75 e5                	jne    800597 <vprintfmt+0x11>
  8005b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005d7:	eb 1d                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005dc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005e0:	eb 14                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	0f b6 06             	movzbl (%esi),%eax
  8005f9:	8d 56 01             	lea    0x1(%esi),%edx
  8005fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ff:	8a 16                	mov    (%esi),%dl
  800601:	83 ea 23             	sub    $0x23,%edx
  800604:	80 fa 55             	cmp    $0x55,%dl
  800607:	0f 87 01 03 00 00    	ja     80090e <vprintfmt+0x388>
  80060d:	0f b6 d2             	movzbl %dl,%edx
  800610:	ff 24 95 e0 23 80 00 	jmp    *0x8023e0(,%edx,4)
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80061f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800622:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800626:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800629:	8d 50 d0             	lea    -0x30(%eax),%edx
  80062c:	83 fa 09             	cmp    $0x9,%edx
  80062f:	77 2a                	ja     80065b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800631:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800632:	eb eb                	jmp    80061f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800642:	eb 17                	jmp    80065b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800644:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800648:	78 98                	js     8005e2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064d:	eb a7                	jmp    8005f6 <vprintfmt+0x70>
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800652:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800659:	eb 9b                	jmp    8005f6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80065b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065f:	79 95                	jns    8005f6 <vprintfmt+0x70>
  800661:	eb 8b                	jmp    8005ee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800663:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800667:	eb 8d                	jmp    8005f6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800681:	e9 23 ff ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	79 02                	jns    800697 <vprintfmt+0x111>
  800695:	f7 d8                	neg    %eax
  800697:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800699:	83 f8 0f             	cmp    $0xf,%eax
  80069c:	7f 0b                	jg     8006a9 <vprintfmt+0x123>
  80069e:	8b 04 85 40 25 80 00 	mov    0x802540(,%eax,4),%eax
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	75 23                	jne    8006cc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ad:	c7 44 24 08 bb 22 80 	movl   $0x8022bb,0x8(%esp)
  8006b4:	00 
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	e8 9a fe ff ff       	call   80055e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006c7:	e9 dd fe ff ff       	jmp    8005a9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d0:	c7 44 24 08 ae 26 80 	movl   $0x8026ae,0x8(%esp)
  8006d7:	00 
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006df:	89 14 24             	mov    %edx,(%esp)
  8006e2:	e8 77 fe ff ff       	call   80055e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ea:	e9 ba fe ff ff       	jmp    8005a9 <vprintfmt+0x23>
  8006ef:	89 f9                	mov    %edi,%ecx
  8006f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 30                	mov    (%eax),%esi
  800702:	85 f6                	test   %esi,%esi
  800704:	75 05                	jne    80070b <vprintfmt+0x185>
				p = "(null)";
  800706:	be b4 22 80 00       	mov    $0x8022b4,%esi
			if (width > 0 && padc != '-')
  80070b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80070f:	0f 8e 84 00 00 00    	jle    800799 <vprintfmt+0x213>
  800715:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800719:	74 7e                	je     800799 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80071f:	89 34 24             	mov    %esi,(%esp)
  800722:	e8 8b 03 00 00       	call   800ab2 <strnlen>
  800727:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072a:	29 c2                	sub    %eax,%edx
  80072c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80072f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800733:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800736:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800739:	89 de                	mov    %ebx,%esi
  80073b:	89 d3                	mov    %edx,%ebx
  80073d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073f:	eb 0b                	jmp    80074c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800741:	89 74 24 04          	mov    %esi,0x4(%esp)
  800745:	89 3c 24             	mov    %edi,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	4b                   	dec    %ebx
  80074c:	85 db                	test   %ebx,%ebx
  80074e:	7f f1                	jg     800741 <vprintfmt+0x1bb>
  800750:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800753:	89 f3                	mov    %esi,%ebx
  800755:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075b:	85 c0                	test   %eax,%eax
  80075d:	79 05                	jns    800764 <vprintfmt+0x1de>
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800767:	29 c2                	sub    %eax,%edx
  800769:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076c:	eb 2b                	jmp    800799 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80076e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800772:	74 18                	je     80078c <vprintfmt+0x206>
  800774:	8d 50 e0             	lea    -0x20(%eax),%edx
  800777:	83 fa 5e             	cmp    $0x5e,%edx
  80077a:	76 10                	jbe    80078c <vprintfmt+0x206>
					putch('?', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
  80078a:	eb 0a                	jmp    800796 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	ff 4d e4             	decl   -0x1c(%ebp)
  800799:	0f be 06             	movsbl (%esi),%eax
  80079c:	46                   	inc    %esi
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 21                	je     8007c2 <vprintfmt+0x23c>
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	78 c9                	js     80076e <vprintfmt+0x1e8>
  8007a5:	4f                   	dec    %edi
  8007a6:	79 c6                	jns    80076e <vprintfmt+0x1e8>
  8007a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ab:	89 de                	mov    %ebx,%esi
  8007ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007b0:	eb 18                	jmp    8007ca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bf:	4b                   	dec    %ebx
  8007c0:	eb 08                	jmp    8007ca <vprintfmt+0x244>
  8007c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c5:	89 de                	mov    %ebx,%esi
  8007c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ca:	85 db                	test   %ebx,%ebx
  8007cc:	7f e4                	jg     8007b2 <vprintfmt+0x22c>
  8007ce:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007d1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d6:	e9 ce fd ff ff       	jmp    8005a9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007db:	83 f9 01             	cmp    $0x1,%ecx
  8007de:	7e 10                	jle    8007f0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 08             	lea    0x8(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 30                	mov    (%eax),%esi
  8007eb:	8b 78 04             	mov    0x4(%eax),%edi
  8007ee:	eb 26                	jmp    800816 <vprintfmt+0x290>
	else if (lflag)
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	74 12                	je     800806 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 50 04             	lea    0x4(%eax),%edx
  8007fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fd:	8b 30                	mov    (%eax),%esi
  8007ff:	89 f7                	mov    %esi,%edi
  800801:	c1 ff 1f             	sar    $0x1f,%edi
  800804:	eb 10                	jmp    800816 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 30                	mov    (%eax),%esi
  800811:	89 f7                	mov    %esi,%edi
  800813:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	85 ff                	test   %edi,%edi
  800818:	78 0a                	js     800824 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081f:	e9 ac 00 00 00       	jmp    8008d0 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800832:	f7 de                	neg    %esi
  800834:	83 d7 00             	adc    $0x0,%edi
  800837:	f7 df                	neg    %edi
			}
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083e:	e9 8d 00 00 00       	jmp    8008d0 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800843:	89 ca                	mov    %ecx,%edx
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	e8 bd fc ff ff       	call   80050a <getuint>
  80084d:	89 c6                	mov    %eax,%esi
  80084f:	89 d7                	mov    %edx,%edi
			base = 10;
  800851:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800856:	eb 78                	jmp    8008d0 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800858:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800863:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800866:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800871:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800874:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800878:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80087f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800882:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800885:	e9 1f fd ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80088a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800895:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800898:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 50 04             	lea    0x4(%eax),%edx
  8008ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008af:	8b 30                	mov    (%eax),%esi
  8008b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008bb:	eb 13                	jmp    8008d0 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bd:	89 ca                	mov    %ecx,%edx
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c2:	e8 43 fc ff ff       	call   80050a <getuint>
  8008c7:	89 c6                	mov    %eax,%esi
  8008c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8008cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e3:	89 34 24             	mov    %esi,(%esp)
  8008e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ea:	89 da                	mov    %ebx,%edx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	e8 4c fb ff ff       	call   800440 <printnum>
			break;
  8008f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f7:	e9 ad fc ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800900:	89 04 24             	mov    %eax,(%esp)
  800903:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800909:	e9 9b fc ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800912:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800919:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091c:	eb 01                	jmp    80091f <vprintfmt+0x399>
  80091e:	4e                   	dec    %esi
  80091f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800923:	75 f9                	jne    80091e <vprintfmt+0x398>
  800925:	e9 7f fc ff ff       	jmp    8005a9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80092a:	83 c4 4c             	add    $0x4c,%esp
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	83 ec 28             	sub    $0x28,%esp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800941:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800945:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800948:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094f:	85 c0                	test   %eax,%eax
  800951:	74 30                	je     800983 <vsnprintf+0x51>
  800953:	85 d2                	test   %edx,%edx
  800955:	7e 33                	jle    80098a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800957:	8b 45 14             	mov    0x14(%ebp),%eax
  80095a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095e:	8b 45 10             	mov    0x10(%ebp),%eax
  800961:	89 44 24 08          	mov    %eax,0x8(%esp)
  800965:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096c:	c7 04 24 44 05 80 00 	movl   $0x800544,(%esp)
  800973:	e8 0e fc ff ff       	call   800586 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800978:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80097b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800981:	eb 0c                	jmp    80098f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800983:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800988:	eb 05                	jmp    80098f <vsnprintf+0x5d>
  80098a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800997:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80099a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099e:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	e8 7b ff ff ff       	call   800932 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    
  8009b9:	00 00                	add    %al,(%eax)
	...

008009bc <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	83 ec 1c             	sub    $0x1c,%esp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009c8:	85 c0                	test   %eax,%eax
  8009ca:	74 18                	je     8009e4 <readline+0x28>
		fprintf(1, "%s", prompt);
  8009cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d0:	c7 44 24 04 ae 26 80 	movl   $0x8026ae,0x4(%esp)
  8009d7:	00 
  8009d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009df:	e8 9c 10 00 00       	call   801a80 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8009e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009eb:	e8 49 f8 ff ff       	call   800239 <iscons>
  8009f0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009f2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009f7:	e8 07 f8 ff ff       	call   800203 <getchar>
  8009fc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009fe:	85 c0                	test   %eax,%eax
  800a00:	79 20                	jns    800a22 <readline+0x66>
			if (c != -E_EOF)
  800a02:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800a05:	0f 84 82 00 00 00    	je     800a8d <readline+0xd1>
				cprintf("read error: %e\n", c);
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	c7 04 24 9f 25 80 00 	movl   $0x80259f,(%esp)
  800a16:	e8 09 fa ff ff       	call   800424 <cprintf>
			return NULL;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	eb 70                	jmp    800a92 <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a22:	83 f8 08             	cmp    $0x8,%eax
  800a25:	74 05                	je     800a2c <readline+0x70>
  800a27:	83 f8 7f             	cmp    $0x7f,%eax
  800a2a:	75 17                	jne    800a43 <readline+0x87>
  800a2c:	85 f6                	test   %esi,%esi
  800a2e:	7e 13                	jle    800a43 <readline+0x87>
			if (echoing)
  800a30:	85 ff                	test   %edi,%edi
  800a32:	74 0c                	je     800a40 <readline+0x84>
				cputchar('\b');
  800a34:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a3b:	e8 a2 f7 ff ff       	call   8001e2 <cputchar>
			i--;
  800a40:	4e                   	dec    %esi
  800a41:	eb b4                	jmp    8009f7 <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a43:	83 fb 1f             	cmp    $0x1f,%ebx
  800a46:	7e 1d                	jle    800a65 <readline+0xa9>
  800a48:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a4e:	7f 15                	jg     800a65 <readline+0xa9>
			if (echoing)
  800a50:	85 ff                	test   %edi,%edi
  800a52:	74 08                	je     800a5c <readline+0xa0>
				cputchar(c);
  800a54:	89 1c 24             	mov    %ebx,(%esp)
  800a57:	e8 86 f7 ff ff       	call   8001e2 <cputchar>
			buf[i++] = c;
  800a5c:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a62:	46                   	inc    %esi
  800a63:	eb 92                	jmp    8009f7 <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800a65:	83 fb 0a             	cmp    $0xa,%ebx
  800a68:	74 05                	je     800a6f <readline+0xb3>
  800a6a:	83 fb 0d             	cmp    $0xd,%ebx
  800a6d:	75 88                	jne    8009f7 <readline+0x3b>
			if (echoing)
  800a6f:	85 ff                	test   %edi,%edi
  800a71:	74 0c                	je     800a7f <readline+0xc3>
				cputchar('\n');
  800a73:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800a7a:	e8 63 f7 ff ff       	call   8001e2 <cputchar>
			buf[i] = 0;
  800a7f:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a86:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a8b:	eb 05                	jmp    800a92 <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a92:	83 c4 1c             	add    $0x1c,%esp
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
	...

00800a9c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	eb 01                	jmp    800aaa <strlen+0xe>
		n++;
  800aa9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aaa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aae:	75 f9                	jne    800aa9 <strlen+0xd>
		n++;
	return n;
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	eb 01                	jmp    800ac3 <strnlen+0x11>
		n++;
  800ac2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ac3:	39 d0                	cmp    %edx,%eax
  800ac5:	74 06                	je     800acd <strnlen+0x1b>
  800ac7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800acb:	75 f5                	jne    800ac2 <strnlen+0x10>
		n++;
	return n;
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	53                   	push   %ebx
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ae1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ae4:	42                   	inc    %edx
  800ae5:	84 c9                	test   %cl,%cl
  800ae7:	75 f5                	jne    800ade <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	53                   	push   %ebx
  800af0:	83 ec 08             	sub    $0x8,%esp
  800af3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af6:	89 1c 24             	mov    %ebx,(%esp)
  800af9:	e8 9e ff ff ff       	call   800a9c <strlen>
	strcpy(dst + len, src);
  800afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b01:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b05:	01 d8                	add    %ebx,%eax
  800b07:	89 04 24             	mov    %eax,(%esp)
  800b0a:	e8 c0 ff ff ff       	call   800acf <strcpy>
	return dst;
}
  800b0f:	89 d8                	mov    %ebx,%eax
  800b11:	83 c4 08             	add    $0x8,%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b22:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	eb 0c                	jmp    800b38 <strncpy+0x21>
		*dst++ = *src;
  800b2c:	8a 1a                	mov    (%edx),%bl
  800b2e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b31:	80 3a 01             	cmpb   $0x1,(%edx)
  800b34:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b37:	41                   	inc    %ecx
  800b38:	39 f1                	cmp    %esi,%ecx
  800b3a:	75 f0                	jne    800b2c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 75 08             	mov    0x8(%ebp),%esi
  800b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b4e:	85 d2                	test   %edx,%edx
  800b50:	75 0a                	jne    800b5c <strlcpy+0x1c>
  800b52:	89 f0                	mov    %esi,%eax
  800b54:	eb 1a                	jmp    800b70 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b56:	88 18                	mov    %bl,(%eax)
  800b58:	40                   	inc    %eax
  800b59:	41                   	inc    %ecx
  800b5a:	eb 02                	jmp    800b5e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b5c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b5e:	4a                   	dec    %edx
  800b5f:	74 0a                	je     800b6b <strlcpy+0x2b>
  800b61:	8a 19                	mov    (%ecx),%bl
  800b63:	84 db                	test   %bl,%bl
  800b65:	75 ef                	jne    800b56 <strlcpy+0x16>
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	eb 02                	jmp    800b6d <strlcpy+0x2d>
  800b6b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b6d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b70:	29 f0                	sub    %esi,%eax
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b7f:	eb 02                	jmp    800b83 <strcmp+0xd>
		p++, q++;
  800b81:	41                   	inc    %ecx
  800b82:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b83:	8a 01                	mov    (%ecx),%al
  800b85:	84 c0                	test   %al,%al
  800b87:	74 04                	je     800b8d <strcmp+0x17>
  800b89:	3a 02                	cmp    (%edx),%al
  800b8b:	74 f4                	je     800b81 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8d:	0f b6 c0             	movzbl %al,%eax
  800b90:	0f b6 12             	movzbl (%edx),%edx
  800b93:	29 d0                	sub    %edx,%eax
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	53                   	push   %ebx
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ba4:	eb 03                	jmp    800ba9 <strncmp+0x12>
		n--, p++, q++;
  800ba6:	4a                   	dec    %edx
  800ba7:	40                   	inc    %eax
  800ba8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ba9:	85 d2                	test   %edx,%edx
  800bab:	74 14                	je     800bc1 <strncmp+0x2a>
  800bad:	8a 18                	mov    (%eax),%bl
  800baf:	84 db                	test   %bl,%bl
  800bb1:	74 04                	je     800bb7 <strncmp+0x20>
  800bb3:	3a 19                	cmp    (%ecx),%bl
  800bb5:	74 ef                	je     800ba6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb7:	0f b6 00             	movzbl (%eax),%eax
  800bba:	0f b6 11             	movzbl (%ecx),%edx
  800bbd:	29 d0                	sub    %edx,%eax
  800bbf:	eb 05                	jmp    800bc6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bd2:	eb 05                	jmp    800bd9 <strchr+0x10>
		if (*s == c)
  800bd4:	38 ca                	cmp    %cl,%dl
  800bd6:	74 0c                	je     800be4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bd8:	40                   	inc    %eax
  800bd9:	8a 10                	mov    (%eax),%dl
  800bdb:	84 d2                	test   %dl,%dl
  800bdd:	75 f5                	jne    800bd4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bef:	eb 05                	jmp    800bf6 <strfind+0x10>
		if (*s == c)
  800bf1:	38 ca                	cmp    %cl,%dl
  800bf3:	74 07                	je     800bfc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bf5:	40                   	inc    %eax
  800bf6:	8a 10                	mov    (%eax),%dl
  800bf8:	84 d2                	test   %dl,%dl
  800bfa:	75 f5                	jne    800bf1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c0d:	85 c9                	test   %ecx,%ecx
  800c0f:	74 30                	je     800c41 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c11:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c17:	75 25                	jne    800c3e <memset+0x40>
  800c19:	f6 c1 03             	test   $0x3,%cl
  800c1c:	75 20                	jne    800c3e <memset+0x40>
		c &= 0xFF;
  800c1e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	c1 e3 08             	shl    $0x8,%ebx
  800c26:	89 d6                	mov    %edx,%esi
  800c28:	c1 e6 18             	shl    $0x18,%esi
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	c1 e0 10             	shl    $0x10,%eax
  800c30:	09 f0                	or     %esi,%eax
  800c32:	09 d0                	or     %edx,%eax
  800c34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c39:	fc                   	cld    
  800c3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c3c:	eb 03                	jmp    800c41 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c3e:	fc                   	cld    
  800c3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c41:	89 f8                	mov    %edi,%eax
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c56:	39 c6                	cmp    %eax,%esi
  800c58:	73 34                	jae    800c8e <memmove+0x46>
  800c5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c5d:	39 d0                	cmp    %edx,%eax
  800c5f:	73 2d                	jae    800c8e <memmove+0x46>
		s += n;
		d += n;
  800c61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c64:	f6 c2 03             	test   $0x3,%dl
  800c67:	75 1b                	jne    800c84 <memmove+0x3c>
  800c69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c6f:	75 13                	jne    800c84 <memmove+0x3c>
  800c71:	f6 c1 03             	test   $0x3,%cl
  800c74:	75 0e                	jne    800c84 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c76:	83 ef 04             	sub    $0x4,%edi
  800c79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c7c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c7f:	fd                   	std    
  800c80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c82:	eb 07                	jmp    800c8b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c84:	4f                   	dec    %edi
  800c85:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c88:	fd                   	std    
  800c89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8b:	fc                   	cld    
  800c8c:	eb 20                	jmp    800cae <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c94:	75 13                	jne    800ca9 <memmove+0x61>
  800c96:	a8 03                	test   $0x3,%al
  800c98:	75 0f                	jne    800ca9 <memmove+0x61>
  800c9a:	f6 c1 03             	test   $0x3,%cl
  800c9d:	75 0a                	jne    800ca9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c9f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ca2:	89 c7                	mov    %eax,%edi
  800ca4:	fc                   	cld    
  800ca5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca7:	eb 05                	jmp    800cae <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca9:	89 c7                	mov    %eax,%edi
  800cab:	fc                   	cld    
  800cac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	89 04 24             	mov    %eax,(%esp)
  800ccc:	e8 77 ff ff ff       	call   800c48 <memmove>
}
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    

00800cd3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	eb 16                	jmp    800cff <memcmp+0x2c>
		if (*s1 != *s2)
  800ce9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cec:	42                   	inc    %edx
  800ced:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cf1:	38 c8                	cmp    %cl,%al
  800cf3:	74 0a                	je     800cff <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cf5:	0f b6 c0             	movzbl %al,%eax
  800cf8:	0f b6 c9             	movzbl %cl,%ecx
  800cfb:	29 c8                	sub    %ecx,%eax
  800cfd:	eb 09                	jmp    800d08 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cff:	39 da                	cmp    %ebx,%edx
  800d01:	75 e6                	jne    800ce9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d16:	89 c2                	mov    %eax,%edx
  800d18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d1b:	eb 05                	jmp    800d22 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1d:	38 08                	cmp    %cl,(%eax)
  800d1f:	74 05                	je     800d26 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d21:	40                   	inc    %eax
  800d22:	39 d0                	cmp    %edx,%eax
  800d24:	72 f7                	jb     800d1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d34:	eb 01                	jmp    800d37 <strtol+0xf>
		s++;
  800d36:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d37:	8a 02                	mov    (%edx),%al
  800d39:	3c 20                	cmp    $0x20,%al
  800d3b:	74 f9                	je     800d36 <strtol+0xe>
  800d3d:	3c 09                	cmp    $0x9,%al
  800d3f:	74 f5                	je     800d36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d41:	3c 2b                	cmp    $0x2b,%al
  800d43:	75 08                	jne    800d4d <strtol+0x25>
		s++;
  800d45:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d46:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4b:	eb 13                	jmp    800d60 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d4d:	3c 2d                	cmp    $0x2d,%al
  800d4f:	75 0a                	jne    800d5b <strtol+0x33>
		s++, neg = 1;
  800d51:	8d 52 01             	lea    0x1(%edx),%edx
  800d54:	bf 01 00 00 00       	mov    $0x1,%edi
  800d59:	eb 05                	jmp    800d60 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d60:	85 db                	test   %ebx,%ebx
  800d62:	74 05                	je     800d69 <strtol+0x41>
  800d64:	83 fb 10             	cmp    $0x10,%ebx
  800d67:	75 28                	jne    800d91 <strtol+0x69>
  800d69:	8a 02                	mov    (%edx),%al
  800d6b:	3c 30                	cmp    $0x30,%al
  800d6d:	75 10                	jne    800d7f <strtol+0x57>
  800d6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d73:	75 0a                	jne    800d7f <strtol+0x57>
		s += 2, base = 16;
  800d75:	83 c2 02             	add    $0x2,%edx
  800d78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7d:	eb 12                	jmp    800d91 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d7f:	85 db                	test   %ebx,%ebx
  800d81:	75 0e                	jne    800d91 <strtol+0x69>
  800d83:	3c 30                	cmp    $0x30,%al
  800d85:	75 05                	jne    800d8c <strtol+0x64>
		s++, base = 8;
  800d87:	42                   	inc    %edx
  800d88:	b3 08                	mov    $0x8,%bl
  800d8a:	eb 05                	jmp    800d91 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
  800d96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d98:	8a 0a                	mov    (%edx),%cl
  800d9a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d9d:	80 fb 09             	cmp    $0x9,%bl
  800da0:	77 08                	ja     800daa <strtol+0x82>
			dig = *s - '0';
  800da2:	0f be c9             	movsbl %cl,%ecx
  800da5:	83 e9 30             	sub    $0x30,%ecx
  800da8:	eb 1e                	jmp    800dc8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800daa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dad:	80 fb 19             	cmp    $0x19,%bl
  800db0:	77 08                	ja     800dba <strtol+0x92>
			dig = *s - 'a' + 10;
  800db2:	0f be c9             	movsbl %cl,%ecx
  800db5:	83 e9 57             	sub    $0x57,%ecx
  800db8:	eb 0e                	jmp    800dc8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800dba:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800dbd:	80 fb 19             	cmp    $0x19,%bl
  800dc0:	77 12                	ja     800dd4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800dc2:	0f be c9             	movsbl %cl,%ecx
  800dc5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dc8:	39 f1                	cmp    %esi,%ecx
  800dca:	7d 0c                	jge    800dd8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800dcc:	42                   	inc    %edx
  800dcd:	0f af c6             	imul   %esi,%eax
  800dd0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dd2:	eb c4                	jmp    800d98 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dd4:	89 c1                	mov    %eax,%ecx
  800dd6:	eb 02                	jmp    800dda <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dd8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dde:	74 05                	je     800de5 <strtol+0xbd>
		*endptr = (char *) s;
  800de0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800de5:	85 ff                	test   %edi,%edi
  800de7:	74 04                	je     800ded <strtol+0xc5>
  800de9:	89 c8                	mov    %ecx,%eax
  800deb:	f7 d8                	neg    %eax
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
	...

00800df4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	89 c7                	mov    %eax,%edi
  800e09:	89 c6                	mov    %eax,%esi
  800e0b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e22:	89 d1                	mov    %edx,%ecx
  800e24:	89 d3                	mov    %edx,%ebx
  800e26:	89 d7                	mov    %edx,%edi
  800e28:	89 d6                	mov    %edx,%esi
  800e2a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 28                	jle    800e7b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e57:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800e76:	e8 b1 f4 ff ff       	call   80032c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e7b:	83 c4 2c             	add    $0x2c,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e93:	89 d1                	mov    %edx,%ecx
  800e95:	89 d3                	mov    %edx,%ebx
  800e97:	89 d7                	mov    %edx,%edi
  800e99:	89 d6                	mov    %edx,%esi
  800e9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <sys_yield>:

void
sys_yield(void)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ead:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eb2:	89 d1                	mov    %edx,%ecx
  800eb4:	89 d3                	mov    %edx,%ebx
  800eb6:	89 d7                	mov    %edx,%edi
  800eb8:	89 d6                	mov    %edx,%esi
  800eba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	be 00 00 00 00       	mov    $0x0,%esi
  800ecf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 f7                	mov    %esi,%edi
  800edf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	7e 28                	jle    800f0d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800f08:	e8 1f f4 ff ff       	call   80032c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f0d:	83 c4 2c             	add    $0x2c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f23:	8b 75 18             	mov    0x18(%ebp),%esi
  800f26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f34:	85 c0                	test   %eax,%eax
  800f36:	7e 28                	jle    800f60 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f43:	00 
  800f44:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f53:	00 
  800f54:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800f5b:	e8 cc f3 ff ff       	call   80032c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f60:	83 c4 2c             	add    $0x2c,%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f76:	b8 06 00 00 00       	mov    $0x6,%eax
  800f7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f81:	89 df                	mov    %ebx,%edi
  800f83:	89 de                	mov    %ebx,%esi
  800f85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 28                	jle    800fb3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f96:	00 
  800f97:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  800fae:	e8 79 f3 ff ff       	call   80032c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fb3:	83 c4 2c             	add    $0x2c,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd4:	89 df                	mov    %ebx,%edi
  800fd6:	89 de                	mov    %ebx,%esi
  800fd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	7e 28                	jle    801006 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fe9:	00 
  800fea:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff9:	00 
  800ffa:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801001:	e8 26 f3 ff ff       	call   80032c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801006:	83 c4 2c             	add    $0x2c,%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801017:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101c:	b8 09 00 00 00       	mov    $0x9,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 df                	mov    %ebx,%edi
  801029:	89 de                	mov    %ebx,%esi
  80102b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102d:	85 c0                	test   %eax,%eax
  80102f:	7e 28                	jle    801059 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801031:	89 44 24 10          	mov    %eax,0x10(%esp)
  801035:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80103c:	00 
  80103d:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  801044:	00 
  801045:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104c:	00 
  80104d:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801054:	e8 d3 f2 ff ff       	call   80032c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801059:	83 c4 2c             	add    $0x2c,%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801074:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801077:	8b 55 08             	mov    0x8(%ebp),%edx
  80107a:	89 df                	mov    %ebx,%edi
  80107c:	89 de                	mov    %ebx,%esi
  80107e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801080:	85 c0                	test   %eax,%eax
  801082:	7e 28                	jle    8010ac <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801084:	89 44 24 10          	mov    %eax,0x10(%esp)
  801088:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80108f:	00 
  801090:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  801097:	00 
  801098:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109f:	00 
  8010a0:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  8010a7:	e8 80 f2 ff ff       	call   80032c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ac:	83 c4 2c             	add    $0x2c,%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ba:	be 00 00 00 00       	mov    $0x0,%esi
  8010bf:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ed:	89 cb                	mov    %ecx,%ebx
  8010ef:	89 cf                	mov    %ecx,%edi
  8010f1:	89 ce                	mov    %ecx,%esi
  8010f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	7e 28                	jle    801121 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801104:	00 
  801105:	c7 44 24 08 af 25 80 	movl   $0x8025af,0x8(%esp)
  80110c:	00 
  80110d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801114:	00 
  801115:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80111c:	e8 0b f2 ff ff       	call   80032c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801121:	83 c4 2c             	add    $0x2c,%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    
  801129:	00 00                	add    %al,(%eax)
	...

0080112c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	05 00 00 00 30       	add    $0x30000000,%eax
  801137:	c1 e8 0c             	shr    $0xc,%eax
}
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	89 04 24             	mov    %eax,(%esp)
  801148:	e8 df ff ff ff       	call   80112c <fd2num>
  80114d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801152:	c1 e0 0c             	shl    $0xc,%eax
}
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	53                   	push   %ebx
  80115b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80115e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801163:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801165:	89 c2                	mov    %eax,%edx
  801167:	c1 ea 16             	shr    $0x16,%edx
  80116a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801171:	f6 c2 01             	test   $0x1,%dl
  801174:	74 11                	je     801187 <fd_alloc+0x30>
  801176:	89 c2                	mov    %eax,%edx
  801178:	c1 ea 0c             	shr    $0xc,%edx
  80117b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801182:	f6 c2 01             	test   $0x1,%dl
  801185:	75 09                	jne    801190 <fd_alloc+0x39>
			*fd_store = fd;
  801187:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
  80118e:	eb 17                	jmp    8011a7 <fd_alloc+0x50>
  801190:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801195:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119a:	75 c7                	jne    801163 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011a2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011a7:	5b                   	pop    %ebx
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b0:	83 f8 1f             	cmp    $0x1f,%eax
  8011b3:	77 36                	ja     8011eb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011ba:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	c1 ea 16             	shr    $0x16,%edx
  8011c2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c9:	f6 c2 01             	test   $0x1,%dl
  8011cc:	74 24                	je     8011f2 <fd_lookup+0x48>
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	c1 ea 0c             	shr    $0xc,%edx
  8011d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011da:	f6 c2 01             	test   $0x1,%dl
  8011dd:	74 1a                	je     8011f9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e2:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e9:	eb 13                	jmp    8011fe <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f0:	eb 0c                	jmp    8011fe <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f7:	eb 05                	jmp    8011fe <fd_lookup+0x54>
  8011f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	53                   	push   %ebx
  801204:	83 ec 14             	sub    $0x14,%esp
  801207:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80120d:	ba 00 00 00 00       	mov    $0x0,%edx
  801212:	eb 0e                	jmp    801222 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801214:	39 08                	cmp    %ecx,(%eax)
  801216:	75 09                	jne    801221 <dev_lookup+0x21>
			*dev = devtab[i];
  801218:	89 03                	mov    %eax,(%ebx)
			return 0;
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
  80121f:	eb 33                	jmp    801254 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801221:	42                   	inc    %edx
  801222:	8b 04 95 5c 26 80 00 	mov    0x80265c(,%edx,4),%eax
  801229:	85 c0                	test   %eax,%eax
  80122b:	75 e7                	jne    801214 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122d:	a1 04 44 80 00       	mov    0x804404,%eax
  801232:	8b 40 48             	mov    0x48(%eax),%eax
  801235:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123d:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  801244:	e8 db f1 ff ff       	call   800424 <cprintf>
	*dev = 0;
  801249:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801254:	83 c4 14             	add    $0x14,%esp
  801257:	5b                   	pop    %ebx
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 30             	sub    $0x30,%esp
  801262:	8b 75 08             	mov    0x8(%ebp),%esi
  801265:	8a 45 0c             	mov    0xc(%ebp),%al
  801268:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126b:	89 34 24             	mov    %esi,(%esp)
  80126e:	e8 b9 fe ff ff       	call   80112c <fd2num>
  801273:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801276:	89 54 24 04          	mov    %edx,0x4(%esp)
  80127a:	89 04 24             	mov    %eax,(%esp)
  80127d:	e8 28 ff ff ff       	call   8011aa <fd_lookup>
  801282:	89 c3                	mov    %eax,%ebx
  801284:	85 c0                	test   %eax,%eax
  801286:	78 05                	js     80128d <fd_close+0x33>
	    || fd != fd2)
  801288:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80128b:	74 0d                	je     80129a <fd_close+0x40>
		return (must_exist ? r : 0);
  80128d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801291:	75 46                	jne    8012d9 <fd_close+0x7f>
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
  801298:	eb 3f                	jmp    8012d9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	8b 06                	mov    (%esi),%eax
  8012a3:	89 04 24             	mov    %eax,(%esp)
  8012a6:	e8 55 ff ff ff       	call   801200 <dev_lookup>
  8012ab:	89 c3                	mov    %eax,%ebx
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 18                	js     8012c9 <fd_close+0x6f>
		if (dev->dev_close)
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	8b 40 10             	mov    0x10(%eax),%eax
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	74 09                	je     8012c4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012bb:	89 34 24             	mov    %esi,(%esp)
  8012be:	ff d0                	call   *%eax
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	eb 05                	jmp    8012c9 <fd_close+0x6f>
		else
			r = 0;
  8012c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d4:	e8 8f fc ff ff       	call   800f68 <sys_page_unmap>
	return r;
}
  8012d9:	89 d8                	mov    %ebx,%eax
  8012db:	83 c4 30             	add    $0x30,%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 b0 fe ff ff       	call   8011aa <fd_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 13                	js     801311 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801305:	00 
  801306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 49 ff ff ff       	call   80125a <fd_close>
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <close_all>:

void
close_all(void)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 bb ff ff ff       	call   8012e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801327:	43                   	inc    %ebx
  801328:	83 fb 20             	cmp    $0x20,%ebx
  80132b:	75 f2                	jne    80131f <close_all+0xc>
		close(i);
}
  80132d:	83 c4 14             	add    $0x14,%esp
  801330:	5b                   	pop    %ebx
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	57                   	push   %edi
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	83 ec 4c             	sub    $0x4c,%esp
  80133c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80133f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	8b 45 08             	mov    0x8(%ebp),%eax
  801349:	89 04 24             	mov    %eax,(%esp)
  80134c:	e8 59 fe ff ff       	call   8011aa <fd_lookup>
  801351:	89 c3                	mov    %eax,%ebx
  801353:	85 c0                	test   %eax,%eax
  801355:	0f 88 e1 00 00 00    	js     80143c <dup+0x109>
		return r;
	close(newfdnum);
  80135b:	89 3c 24             	mov    %edi,(%esp)
  80135e:	e8 7f ff ff ff       	call   8012e2 <close>

	newfd = INDEX2FD(newfdnum);
  801363:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801369:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80136c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	e8 c5 fd ff ff       	call   80113c <fd2data>
  801377:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801379:	89 34 24             	mov    %esi,(%esp)
  80137c:	e8 bb fd ff ff       	call   80113c <fd2data>
  801381:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801384:	89 d8                	mov    %ebx,%eax
  801386:	c1 e8 16             	shr    $0x16,%eax
  801389:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801390:	a8 01                	test   $0x1,%al
  801392:	74 46                	je     8013da <dup+0xa7>
  801394:	89 d8                	mov    %ebx,%eax
  801396:	c1 e8 0c             	shr    $0xc,%eax
  801399:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a0:	f6 c2 01             	test   $0x1,%dl
  8013a3:	74 35                	je     8013da <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013c3:	00 
  8013c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013cf:	e8 41 fb ff ff       	call   800f15 <sys_page_map>
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 3b                	js     801415 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	c1 ea 0c             	shr    $0xc,%edx
  8013e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013ef:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013fe:	00 
  8013ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801403:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140a:	e8 06 fb ff ff       	call   800f15 <sys_page_map>
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	85 c0                	test   %eax,%eax
  801413:	79 25                	jns    80143a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801415:	89 74 24 04          	mov    %esi,0x4(%esp)
  801419:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801420:	e8 43 fb ff ff       	call   800f68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801425:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801433:	e8 30 fb ff ff       	call   800f68 <sys_page_unmap>
	return r;
  801438:	eb 02                	jmp    80143c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80143a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80143c:	89 d8                	mov    %ebx,%eax
  80143e:	83 c4 4c             	add    $0x4c,%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 24             	sub    $0x24,%esp
  80144d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801450:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801453:	89 44 24 04          	mov    %eax,0x4(%esp)
  801457:	89 1c 24             	mov    %ebx,(%esp)
  80145a:	e8 4b fd ff ff       	call   8011aa <fd_lookup>
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 6d                	js     8014d0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	8b 00                	mov    (%eax),%eax
  80146f:	89 04 24             	mov    %eax,(%esp)
  801472:	e8 89 fd ff ff       	call   801200 <dev_lookup>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 55                	js     8014d0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147e:	8b 50 08             	mov    0x8(%eax),%edx
  801481:	83 e2 03             	and    $0x3,%edx
  801484:	83 fa 01             	cmp    $0x1,%edx
  801487:	75 23                	jne    8014ac <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801489:	a1 04 44 80 00       	mov    0x804404,%eax
  80148e:	8b 40 48             	mov    0x48(%eax),%eax
  801491:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801495:	89 44 24 04          	mov    %eax,0x4(%esp)
  801499:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  8014a0:	e8 7f ef ff ff       	call   800424 <cprintf>
		return -E_INVAL;
  8014a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014aa:	eb 24                	jmp    8014d0 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014af:	8b 52 08             	mov    0x8(%edx),%edx
  8014b2:	85 d2                	test   %edx,%edx
  8014b4:	74 15                	je     8014cb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014c4:	89 04 24             	mov    %eax,(%esp)
  8014c7:	ff d2                	call   *%edx
  8014c9:	eb 05                	jmp    8014d0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014d0:	83 c4 24             	add    $0x24,%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	57                   	push   %edi
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
  8014dc:	83 ec 1c             	sub    $0x1c,%esp
  8014df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ea:	eb 23                	jmp    80150f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ec:	89 f0                	mov    %esi,%eax
  8014ee:	29 d8                	sub    %ebx,%eax
  8014f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f7:	01 d8                	add    %ebx,%eax
  8014f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fd:	89 3c 24             	mov    %edi,(%esp)
  801500:	e8 41 ff ff ff       	call   801446 <read>
		if (m < 0)
  801505:	85 c0                	test   %eax,%eax
  801507:	78 10                	js     801519 <readn+0x43>
			return m;
		if (m == 0)
  801509:	85 c0                	test   %eax,%eax
  80150b:	74 0a                	je     801517 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150d:	01 c3                	add    %eax,%ebx
  80150f:	39 f3                	cmp    %esi,%ebx
  801511:	72 d9                	jb     8014ec <readn+0x16>
  801513:	89 d8                	mov    %ebx,%eax
  801515:	eb 02                	jmp    801519 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801517:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801519:	83 c4 1c             	add    $0x1c,%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5e                   	pop    %esi
  80151e:	5f                   	pop    %edi
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    

00801521 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 24             	sub    $0x24,%esp
  801528:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	89 1c 24             	mov    %ebx,(%esp)
  801535:	e8 70 fc ff ff       	call   8011aa <fd_lookup>
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 68                	js     8015a6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801541:	89 44 24 04          	mov    %eax,0x4(%esp)
  801545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801548:	8b 00                	mov    (%eax),%eax
  80154a:	89 04 24             	mov    %eax,(%esp)
  80154d:	e8 ae fc ff ff       	call   801200 <dev_lookup>
  801552:	85 c0                	test   %eax,%eax
  801554:	78 50                	js     8015a6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155d:	75 23                	jne    801582 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80155f:	a1 04 44 80 00       	mov    0x804404,%eax
  801564:	8b 40 48             	mov    0x48(%eax),%eax
  801567:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80156b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156f:	c7 04 24 3c 26 80 00 	movl   $0x80263c,(%esp)
  801576:	e8 a9 ee ff ff       	call   800424 <cprintf>
		return -E_INVAL;
  80157b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801580:	eb 24                	jmp    8015a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 0c             	mov    0xc(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 15                	je     8015a1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80158f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801593:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801596:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80159a:	89 04 24             	mov    %eax,(%esp)
  80159d:	ff d2                	call   *%edx
  80159f:	eb 05                	jmp    8015a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015a6:	83 c4 24             	add    $0x24,%esp
  8015a9:	5b                   	pop    %ebx
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	89 04 24             	mov    %eax,(%esp)
  8015bf:	e8 e6 fb ff ff       	call   8011aa <fd_lookup>
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 0e                	js     8015d6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 24             	sub    $0x24,%esp
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e9:	89 1c 24             	mov    %ebx,(%esp)
  8015ec:	e8 b9 fb ff ff       	call   8011aa <fd_lookup>
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 61                	js     801656 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	8b 00                	mov    (%eax),%eax
  801601:	89 04 24             	mov    %eax,(%esp)
  801604:	e8 f7 fb ff ff       	call   801200 <dev_lookup>
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 49                	js     801656 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801614:	75 23                	jne    801639 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801616:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161b:	8b 40 48             	mov    0x48(%eax),%eax
  80161e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801622:	89 44 24 04          	mov    %eax,0x4(%esp)
  801626:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  80162d:	e8 f2 ed ff ff       	call   800424 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801632:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801637:	eb 1d                	jmp    801656 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801639:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163c:	8b 52 18             	mov    0x18(%edx),%edx
  80163f:	85 d2                	test   %edx,%edx
  801641:	74 0e                	je     801651 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801643:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801646:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	ff d2                	call   *%edx
  80164f:	eb 05                	jmp    801656 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801651:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801656:	83 c4 24             	add    $0x24,%esp
  801659:	5b                   	pop    %ebx
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 24             	sub    $0x24,%esp
  801663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166d:	8b 45 08             	mov    0x8(%ebp),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 32 fb ff ff       	call   8011aa <fd_lookup>
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 52                	js     8016ce <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	8b 00                	mov    (%eax),%eax
  801688:	89 04 24             	mov    %eax,(%esp)
  80168b:	e8 70 fb ff ff       	call   801200 <dev_lookup>
  801690:	85 c0                	test   %eax,%eax
  801692:	78 3a                	js     8016ce <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801697:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80169b:	74 2c                	je     8016c9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80169d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016a7:	00 00 00 
	stat->st_isdir = 0;
  8016aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b1:	00 00 00 
	stat->st_dev = dev;
  8016b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c1:	89 14 24             	mov    %edx,(%esp)
  8016c4:	ff 50 14             	call   *0x14(%eax)
  8016c7:	eb 05                	jmp    8016ce <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ce:	83 c4 24             	add    $0x24,%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016e3:	00 
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 fe 01 00 00       	call   8018ed <open>
  8016ef:	89 c3                	mov    %eax,%ebx
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 1b                	js     801710 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8016f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fc:	89 1c 24             	mov    %ebx,(%esp)
  8016ff:	e8 58 ff ff ff       	call   80165c <fstat>
  801704:	89 c6                	mov    %eax,%esi
	close(fd);
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 d4 fb ff ff       	call   8012e2 <close>
	return r;
  80170e:	89 f3                	mov    %esi,%ebx
}
  801710:	89 d8                	mov    %ebx,%eax
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    
  801719:	00 00                	add    %al,(%eax)
	...

0080171c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	83 ec 10             	sub    $0x10,%esp
  801724:	89 c3                	mov    %eax,%ebx
  801726:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801728:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80172f:	75 11                	jne    801742 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801731:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801738:	e8 d0 07 00 00       	call   801f0d <ipc_find_env>
  80173d:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801742:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801749:	00 
  80174a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801751:	00 
  801752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801756:	a1 00 44 80 00       	mov    0x804400,%eax
  80175b:	89 04 24             	mov    %eax,(%esp)
  80175e:	e8 40 07 00 00       	call   801ea3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801763:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80176a:	00 
  80176b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80176f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801776:	e8 c1 06 00 00       	call   801e3c <ipc_recv>
}
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 40 0c             	mov    0xc(%eax),%eax
  80178e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801793:	8b 45 0c             	mov    0xc(%ebp),%eax
  801796:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a5:	e8 72 ff ff ff       	call   80171c <fsipc>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c7:	e8 50 ff ff ff       	call   80171c <fsipc>
}
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 14             	sub    $0x14,%esp
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 40 0c             	mov    0xc(%eax),%eax
  8017de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ed:	e8 2a ff ff ff       	call   80171c <fsipc>
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 2b                	js     801821 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017fd:	00 
  8017fe:	89 1c 24             	mov    %ebx,(%esp)
  801801:	e8 c9 f2 ff ff       	call   800acf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801806:	a1 80 50 80 00       	mov    0x805080,%eax
  80180b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801811:	a1 84 50 80 00       	mov    0x805084,%eax
  801816:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801821:	83 c4 14             	add    $0x14,%esp
  801824:	5b                   	pop    %ebx
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80182d:	c7 44 24 08 6c 26 80 	movl   $0x80266c,0x8(%esp)
  801834:	00 
  801835:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80183c:	00 
  80183d:	c7 04 24 8a 26 80 00 	movl   $0x80268a,(%esp)
  801844:	e8 e3 ea ff ff       	call   80032c <_panic>

00801849 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	83 ec 10             	sub    $0x10,%esp
  801851:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	8b 40 0c             	mov    0xc(%eax),%eax
  80185a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80185f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	b8 03 00 00 00       	mov    $0x3,%eax
  80186f:	e8 a8 fe ff ff       	call   80171c <fsipc>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	85 c0                	test   %eax,%eax
  801878:	78 6a                	js     8018e4 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80187a:	39 c6                	cmp    %eax,%esi
  80187c:	73 24                	jae    8018a2 <devfile_read+0x59>
  80187e:	c7 44 24 0c 95 26 80 	movl   $0x802695,0xc(%esp)
  801885:	00 
  801886:	c7 44 24 08 9c 26 80 	movl   $0x80269c,0x8(%esp)
  80188d:	00 
  80188e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801895:	00 
  801896:	c7 04 24 8a 26 80 00 	movl   $0x80268a,(%esp)
  80189d:	e8 8a ea ff ff       	call   80032c <_panic>
	assert(r <= PGSIZE);
  8018a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a7:	7e 24                	jle    8018cd <devfile_read+0x84>
  8018a9:	c7 44 24 0c b1 26 80 	movl   $0x8026b1,0xc(%esp)
  8018b0:	00 
  8018b1:	c7 44 24 08 9c 26 80 	movl   $0x80269c,0x8(%esp)
  8018b8:	00 
  8018b9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8018c0:	00 
  8018c1:	c7 04 24 8a 26 80 00 	movl   $0x80268a,(%esp)
  8018c8:	e8 5f ea ff ff       	call   80032c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d1:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018d8:	00 
  8018d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018dc:	89 04 24             	mov    %eax,(%esp)
  8018df:	e8 64 f3 ff ff       	call   800c48 <memmove>
	return r;
}
  8018e4:	89 d8                	mov    %ebx,%eax
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5e                   	pop    %esi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	56                   	push   %esi
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 20             	sub    $0x20,%esp
  8018f5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f8:	89 34 24             	mov    %esi,(%esp)
  8018fb:	e8 9c f1 ff ff       	call   800a9c <strlen>
  801900:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801905:	7f 60                	jg     801967 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	89 04 24             	mov    %eax,(%esp)
  80190d:	e8 45 f8 ff ff       	call   801157 <fd_alloc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	78 54                	js     80196c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801918:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801923:	e8 a7 f1 ff ff       	call   800acf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801930:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801933:	b8 01 00 00 00       	mov    $0x1,%eax
  801938:	e8 df fd ff ff       	call   80171c <fsipc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	85 c0                	test   %eax,%eax
  801941:	79 15                	jns    801958 <open+0x6b>
		fd_close(fd, 0);
  801943:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80194a:	00 
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 04 f9 ff ff       	call   80125a <fd_close>
		return r;
  801956:	eb 14                	jmp    80196c <open+0x7f>
	}

	return fd2num(fd);
  801958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195b:	89 04 24             	mov    %eax,(%esp)
  80195e:	e8 c9 f7 ff ff       	call   80112c <fd2num>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	eb 05                	jmp    80196c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801967:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196c:	89 d8                	mov    %ebx,%eax
  80196e:	83 c4 20             	add    $0x20,%esp
  801971:	5b                   	pop    %ebx
  801972:	5e                   	pop    %esi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 08 00 00 00       	mov    $0x8,%eax
  801985:	e8 92 fd ff ff       	call   80171c <fsipc>
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	53                   	push   %ebx
  801990:	83 ec 14             	sub    $0x14,%esp
  801993:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801995:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801999:	7e 32                	jle    8019cd <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80199b:	8b 40 04             	mov    0x4(%eax),%eax
  80199e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019a2:	8d 43 10             	lea    0x10(%ebx),%eax
  8019a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a9:	8b 03                	mov    (%ebx),%eax
  8019ab:	89 04 24             	mov    %eax,(%esp)
  8019ae:	e8 6e fb ff ff       	call   801521 <write>
		if (result > 0)
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	7e 03                	jle    8019ba <writebuf+0x2e>
			b->result += result;
  8019b7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019ba:	39 43 04             	cmp    %eax,0x4(%ebx)
  8019bd:	74 0e                	je     8019cd <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8019bf:	89 c2                	mov    %eax,%edx
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	7e 05                	jle    8019ca <writebuf+0x3e>
  8019c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ca:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8019cd:	83 c4 14             	add    $0x14,%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <putch>:

static void
putch(int ch, void *thunk)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019dd:	8b 43 04             	mov    0x4(%ebx),%eax
  8019e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8019e3:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8019e7:	40                   	inc    %eax
  8019e8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8019eb:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019f0:	75 0e                	jne    801a00 <putch+0x2d>
		writebuf(b);
  8019f2:	89 d8                	mov    %ebx,%eax
  8019f4:	e8 93 ff ff ff       	call   80198c <writebuf>
		b->idx = 0;
  8019f9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a00:	83 c4 04             	add    $0x4,%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a18:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a1f:	00 00 00 
	b.result = 0;
  801a22:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a29:	00 00 00 
	b.error = 1;
  801a2c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a33:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a36:	8b 45 10             	mov    0x10(%ebp),%eax
  801a39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a44:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4e:	c7 04 24 d3 19 80 00 	movl   $0x8019d3,(%esp)
  801a55:	e8 2c eb ff ff       	call   800586 <vprintfmt>
	if (b.idx > 0)
  801a5a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a61:	7e 0b                	jle    801a6e <vfprintf+0x68>
		writebuf(&b);
  801a63:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a69:	e8 1e ff ff ff       	call   80198c <writebuf>

	return (b.result ? b.result : b.error);
  801a6e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a74:	85 c0                	test   %eax,%eax
  801a76:	75 06                	jne    801a7e <vfprintf+0x78>
  801a78:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a86:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a89:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	89 04 24             	mov    %eax,(%esp)
  801a9a:	e8 67 ff ff ff       	call   801a06 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <printf>:

int
printf(const char *fmt, ...)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aa7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801aaa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801abc:	e8 45 ff ff ff       	call   801a06 <vfprintf>
	va_end(ap);

	return cnt;
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    
	...

00801ac4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	83 ec 10             	sub    $0x10,%esp
  801acc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	89 04 24             	mov    %eax,(%esp)
  801ad5:	e8 62 f6 ff ff       	call   80113c <fd2data>
  801ada:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801adc:	c7 44 24 04 bd 26 80 	movl   $0x8026bd,0x4(%esp)
  801ae3:	00 
  801ae4:	89 34 24             	mov    %esi,(%esp)
  801ae7:	e8 e3 ef ff ff       	call   800acf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aec:	8b 43 04             	mov    0x4(%ebx),%eax
  801aef:	2b 03                	sub    (%ebx),%eax
  801af1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801af7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801afe:	00 00 00 
	stat->st_dev = &devpipe;
  801b01:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801b08:	30 80 00 
	return 0;
}
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	53                   	push   %ebx
  801b1b:	83 ec 14             	sub    $0x14,%esp
  801b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2c:	e8 37 f4 ff ff       	call   800f68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b31:	89 1c 24             	mov    %ebx,(%esp)
  801b34:	e8 03 f6 ff ff       	call   80113c <fd2data>
  801b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b44:	e8 1f f4 ff ff       	call   800f68 <sys_page_unmap>
}
  801b49:	83 c4 14             	add    $0x14,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	57                   	push   %edi
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	83 ec 2c             	sub    $0x2c,%esp
  801b58:	89 c7                	mov    %eax,%edi
  801b5a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b5d:	a1 04 44 80 00       	mov    0x804404,%eax
  801b62:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b65:	89 3c 24             	mov    %edi,(%esp)
  801b68:	e8 e7 03 00 00       	call   801f54 <pageref>
  801b6d:	89 c6                	mov    %eax,%esi
  801b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 da 03 00 00       	call   801f54 <pageref>
  801b7a:	39 c6                	cmp    %eax,%esi
  801b7c:	0f 94 c0             	sete   %al
  801b7f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b82:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801b88:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b8b:	39 cb                	cmp    %ecx,%ebx
  801b8d:	75 08                	jne    801b97 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b8f:	83 c4 2c             	add    $0x2c,%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b97:	83 f8 01             	cmp    $0x1,%eax
  801b9a:	75 c1                	jne    801b5d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b9c:	8b 42 58             	mov    0x58(%edx),%eax
  801b9f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ba6:	00 
  801ba7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801baf:	c7 04 24 c4 26 80 00 	movl   $0x8026c4,(%esp)
  801bb6:	e8 69 e8 ff ff       	call   800424 <cprintf>
  801bbb:	eb a0                	jmp    801b5d <_pipeisclosed+0xe>

00801bbd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 1c             	sub    $0x1c,%esp
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc9:	89 34 24             	mov    %esi,(%esp)
  801bcc:	e8 6b f5 ff ff       	call   80113c <fd2data>
  801bd1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd3:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd8:	eb 3c                	jmp    801c16 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bda:	89 da                	mov    %ebx,%edx
  801bdc:	89 f0                	mov    %esi,%eax
  801bde:	e8 6c ff ff ff       	call   801b4f <_pipeisclosed>
  801be3:	85 c0                	test   %eax,%eax
  801be5:	75 38                	jne    801c1f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be7:	e8 b6 f2 ff ff       	call   800ea2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bec:	8b 43 04             	mov    0x4(%ebx),%eax
  801bef:	8b 13                	mov    (%ebx),%edx
  801bf1:	83 c2 20             	add    $0x20,%edx
  801bf4:	39 d0                	cmp    %edx,%eax
  801bf6:	73 e2                	jae    801bda <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801bfe:	89 c2                	mov    %eax,%edx
  801c00:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c06:	79 05                	jns    801c0d <devpipe_write+0x50>
  801c08:	4a                   	dec    %edx
  801c09:	83 ca e0             	or     $0xffffffe0,%edx
  801c0c:	42                   	inc    %edx
  801c0d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c11:	40                   	inc    %eax
  801c12:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c15:	47                   	inc    %edi
  801c16:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c19:	75 d1                	jne    801bec <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c1b:	89 f8                	mov    %edi,%eax
  801c1d:	eb 05                	jmp    801c24 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c24:	83 c4 1c             	add    $0x1c,%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5f                   	pop    %edi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	57                   	push   %edi
  801c30:	56                   	push   %esi
  801c31:	53                   	push   %ebx
  801c32:	83 ec 1c             	sub    $0x1c,%esp
  801c35:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c38:	89 3c 24             	mov    %edi,(%esp)
  801c3b:	e8 fc f4 ff ff       	call   80113c <fd2data>
  801c40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c42:	be 00 00 00 00       	mov    $0x0,%esi
  801c47:	eb 3a                	jmp    801c83 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c49:	85 f6                	test   %esi,%esi
  801c4b:	74 04                	je     801c51 <devpipe_read+0x25>
				return i;
  801c4d:	89 f0                	mov    %esi,%eax
  801c4f:	eb 40                	jmp    801c91 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c51:	89 da                	mov    %ebx,%edx
  801c53:	89 f8                	mov    %edi,%eax
  801c55:	e8 f5 fe ff ff       	call   801b4f <_pipeisclosed>
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	75 2e                	jne    801c8c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c5e:	e8 3f f2 ff ff       	call   800ea2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c63:	8b 03                	mov    (%ebx),%eax
  801c65:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c68:	74 df                	je     801c49 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c6a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c6f:	79 05                	jns    801c76 <devpipe_read+0x4a>
  801c71:	48                   	dec    %eax
  801c72:	83 c8 e0             	or     $0xffffffe0,%eax
  801c75:	40                   	inc    %eax
  801c76:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c80:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	46                   	inc    %esi
  801c83:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c86:	75 db                	jne    801c63 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c88:	89 f0                	mov    %esi,%eax
  801c8a:	eb 05                	jmp    801c91 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c91:	83 c4 1c             	add    $0x1c,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	83 ec 3c             	sub    $0x3c,%esp
  801ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ca8:	89 04 24             	mov    %eax,(%esp)
  801cab:	e8 a7 f4 ff ff       	call   801157 <fd_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	0f 88 45 01 00 00    	js     801dff <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cc1:	00 
  801cc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd0:	e8 ec f1 ff ff       	call   800ec1 <sys_page_alloc>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 20 01 00 00    	js     801dff <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cdf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ce2:	89 04 24             	mov    %eax,(%esp)
  801ce5:	e8 6d f4 ff ff       	call   801157 <fd_alloc>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	85 c0                	test   %eax,%eax
  801cee:	0f 88 f8 00 00 00    	js     801dec <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cfb:	00 
  801cfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0a:	e8 b2 f1 ff ff       	call   800ec1 <sys_page_alloc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	85 c0                	test   %eax,%eax
  801d13:	0f 88 d3 00 00 00    	js     801dec <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d1c:	89 04 24             	mov    %eax,(%esp)
  801d1f:	e8 18 f4 ff ff       	call   80113c <fd2data>
  801d24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d2d:	00 
  801d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d39:	e8 83 f1 ff ff       	call   800ec1 <sys_page_alloc>
  801d3e:	89 c3                	mov    %eax,%ebx
  801d40:	85 c0                	test   %eax,%eax
  801d42:	0f 88 91 00 00 00    	js     801dd9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 e9 f3 ff ff       	call   80113c <fd2data>
  801d53:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d5a:	00 
  801d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d66:	00 
  801d67:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d72:	e8 9e f1 ff ff       	call   800f15 <sys_page_map>
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 4c                	js     801dc9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d7d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d86:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d9b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801da0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801daa:	89 04 24             	mov    %eax,(%esp)
  801dad:	e8 7a f3 ff ff       	call   80112c <fd2num>
  801db2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 6d f3 ff ff       	call   80112c <fd2num>
  801dbf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dc7:	eb 36                	jmp    801dff <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801dc9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd4:	e8 8f f1 ff ff       	call   800f68 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de7:	e8 7c f1 ff ff       	call   800f68 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801def:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dfa:	e8 69 f1 ff ff       	call   800f68 <sys_page_unmap>
    err:
	return r;
}
  801dff:	89 d8                	mov    %ebx,%eax
  801e01:	83 c4 3c             	add    $0x3c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	89 04 24             	mov    %eax,(%esp)
  801e1c:	e8 89 f3 ff ff       	call   8011aa <fd_lookup>
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 15                	js     801e3a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e28:	89 04 24             	mov    %eax,(%esp)
  801e2b:	e8 0c f3 ff ff       	call   80113c <fd2data>
	return _pipeisclosed(fd, p);
  801e30:	89 c2                	mov    %eax,%edx
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	e8 15 fd ff ff       	call   801b4f <_pipeisclosed>
}
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	83 ec 10             	sub    $0x10,%esp
  801e44:	8b 75 08             	mov    0x8(%ebp),%esi
  801e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	75 05                	jne    801e56 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801e51:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	e8 79 f2 ff ff       	call   8010d7 <sys_ipc_recv>
	if (!err) {
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	75 26                	jne    801e88 <ipc_recv+0x4c>
		if (from_env_store) {
  801e62:	85 f6                	test   %esi,%esi
  801e64:	74 0a                	je     801e70 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801e66:	a1 04 44 80 00       	mov    0x804404,%eax
  801e6b:	8b 40 74             	mov    0x74(%eax),%eax
  801e6e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801e70:	85 db                	test   %ebx,%ebx
  801e72:	74 0a                	je     801e7e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801e74:	a1 04 44 80 00       	mov    0x804404,%eax
  801e79:	8b 40 78             	mov    0x78(%eax),%eax
  801e7c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801e7e:	a1 04 44 80 00       	mov    0x804404,%eax
  801e83:	8b 40 70             	mov    0x70(%eax),%eax
  801e86:	eb 14                	jmp    801e9c <ipc_recv+0x60>
	}
	if (from_env_store) {
  801e88:	85 f6                	test   %esi,%esi
  801e8a:	74 06                	je     801e92 <ipc_recv+0x56>
		*from_env_store = 0;
  801e8c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801e92:	85 db                	test   %ebx,%ebx
  801e94:	74 06                	je     801e9c <ipc_recv+0x60>
		*perm_store = 0;
  801e96:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    

00801ea3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	57                   	push   %edi
  801ea7:	56                   	push   %esi
  801ea8:	53                   	push   %ebx
  801ea9:	83 ec 1c             	sub    $0x1c,%esp
  801eac:	8b 75 10             	mov    0x10(%ebp),%esi
  801eaf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801eb2:	85 f6                	test   %esi,%esi
  801eb4:	75 05                	jne    801ebb <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801eb6:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ebb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ebf:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	89 04 24             	mov    %eax,(%esp)
  801ed0:	e8 df f1 ff ff       	call   8010b4 <sys_ipc_try_send>
  801ed5:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801ed7:	e8 c6 ef ff ff       	call   800ea2 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801edc:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801edf:	74 da                	je     801ebb <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801ee1:	85 db                	test   %ebx,%ebx
  801ee3:	74 20                	je     801f05 <ipc_send+0x62>
		panic("send fail: %e", err);
  801ee5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ee9:	c7 44 24 08 dc 26 80 	movl   $0x8026dc,0x8(%esp)
  801ef0:	00 
  801ef1:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801ef8:	00 
  801ef9:	c7 04 24 ea 26 80 00 	movl   $0x8026ea,(%esp)
  801f00:	e8 27 e4 ff ff       	call   80032c <_panic>
	}
	return;
}
  801f05:	83 c4 1c             	add    $0x1c,%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	53                   	push   %ebx
  801f11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f19:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f20:	89 c2                	mov    %eax,%edx
  801f22:	c1 e2 07             	shl    $0x7,%edx
  801f25:	29 ca                	sub    %ecx,%edx
  801f27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f2d:	8b 52 50             	mov    0x50(%edx),%edx
  801f30:	39 da                	cmp    %ebx,%edx
  801f32:	75 0f                	jne    801f43 <ipc_find_env+0x36>
			return envs[i].env_id;
  801f34:	c1 e0 07             	shl    $0x7,%eax
  801f37:	29 c8                	sub    %ecx,%eax
  801f39:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f3e:	8b 40 40             	mov    0x40(%eax),%eax
  801f41:	eb 0c                	jmp    801f4f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f43:	40                   	inc    %eax
  801f44:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f49:	75 ce                	jne    801f19 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f4b:	66 b8 00 00          	mov    $0x0,%ax
}
  801f4f:	5b                   	pop    %ebx
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
	...

00801f54 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	c1 ea 16             	shr    $0x16,%edx
  801f5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f66:	f6 c2 01             	test   $0x1,%dl
  801f69:	74 1e                	je     801f89 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6b:	c1 e8 0c             	shr    $0xc,%eax
  801f6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f75:	a8 01                	test   $0x1,%al
  801f77:	74 17                	je     801f90 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f79:	c1 e8 0c             	shr    $0xc,%eax
  801f7c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f83:	ef 
  801f84:	0f b7 c0             	movzwl %ax,%eax
  801f87:	eb 0c                	jmp    801f95 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8e:	eb 05                	jmp    801f95 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    
	...

00801f98 <__udivdi3>:
  801f98:	55                   	push   %ebp
  801f99:	57                   	push   %edi
  801f9a:	56                   	push   %esi
  801f9b:	83 ec 10             	sub    $0x10,%esp
  801f9e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801fa2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801faa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801fae:	89 cd                	mov    %ecx,%ebp
  801fb0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	75 2c                	jne    801fe4 <__udivdi3+0x4c>
  801fb8:	39 f9                	cmp    %edi,%ecx
  801fba:	77 68                	ja     802024 <__udivdi3+0x8c>
  801fbc:	85 c9                	test   %ecx,%ecx
  801fbe:	75 0b                	jne    801fcb <__udivdi3+0x33>
  801fc0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc5:	31 d2                	xor    %edx,%edx
  801fc7:	f7 f1                	div    %ecx
  801fc9:	89 c1                	mov    %eax,%ecx
  801fcb:	31 d2                	xor    %edx,%edx
  801fcd:	89 f8                	mov    %edi,%eax
  801fcf:	f7 f1                	div    %ecx
  801fd1:	89 c7                	mov    %eax,%edi
  801fd3:	89 f0                	mov    %esi,%eax
  801fd5:	f7 f1                	div    %ecx
  801fd7:	89 c6                	mov    %eax,%esi
  801fd9:	89 f0                	mov    %esi,%eax
  801fdb:	89 fa                	mov    %edi,%edx
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	39 f8                	cmp    %edi,%eax
  801fe6:	77 2c                	ja     802014 <__udivdi3+0x7c>
  801fe8:	0f bd f0             	bsr    %eax,%esi
  801feb:	83 f6 1f             	xor    $0x1f,%esi
  801fee:	75 4c                	jne    80203c <__udivdi3+0xa4>
  801ff0:	39 f8                	cmp    %edi,%eax
  801ff2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ff7:	72 0a                	jb     802003 <__udivdi3+0x6b>
  801ff9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ffd:	0f 87 ad 00 00 00    	ja     8020b0 <__udivdi3+0x118>
  802003:	be 01 00 00 00       	mov    $0x1,%esi
  802008:	89 f0                	mov    %esi,%eax
  80200a:	89 fa                	mov    %edi,%edx
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	5e                   	pop    %esi
  802010:	5f                   	pop    %edi
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    
  802013:	90                   	nop
  802014:	31 ff                	xor    %edi,%edi
  802016:	31 f6                	xor    %esi,%esi
  802018:	89 f0                	mov    %esi,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    
  802023:	90                   	nop
  802024:	89 fa                	mov    %edi,%edx
  802026:	89 f0                	mov    %esi,%eax
  802028:	f7 f1                	div    %ecx
  80202a:	89 c6                	mov    %eax,%esi
  80202c:	31 ff                	xor    %edi,%edi
  80202e:	89 f0                	mov    %esi,%eax
  802030:	89 fa                	mov    %edi,%edx
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	8d 76 00             	lea    0x0(%esi),%esi
  80203c:	89 f1                	mov    %esi,%ecx
  80203e:	d3 e0                	shl    %cl,%eax
  802040:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802044:	b8 20 00 00 00       	mov    $0x20,%eax
  802049:	29 f0                	sub    %esi,%eax
  80204b:	89 ea                	mov    %ebp,%edx
  80204d:	88 c1                	mov    %al,%cl
  80204f:	d3 ea                	shr    %cl,%edx
  802051:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802055:	09 ca                	or     %ecx,%edx
  802057:	89 54 24 08          	mov    %edx,0x8(%esp)
  80205b:	89 f1                	mov    %esi,%ecx
  80205d:	d3 e5                	shl    %cl,%ebp
  80205f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802063:	89 fd                	mov    %edi,%ebp
  802065:	88 c1                	mov    %al,%cl
  802067:	d3 ed                	shr    %cl,%ebp
  802069:	89 fa                	mov    %edi,%edx
  80206b:	89 f1                	mov    %esi,%ecx
  80206d:	d3 e2                	shl    %cl,%edx
  80206f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802073:	88 c1                	mov    %al,%cl
  802075:	d3 ef                	shr    %cl,%edi
  802077:	09 d7                	or     %edx,%edi
  802079:	89 f8                	mov    %edi,%eax
  80207b:	89 ea                	mov    %ebp,%edx
  80207d:	f7 74 24 08          	divl   0x8(%esp)
  802081:	89 d1                	mov    %edx,%ecx
  802083:	89 c7                	mov    %eax,%edi
  802085:	f7 64 24 0c          	mull   0xc(%esp)
  802089:	39 d1                	cmp    %edx,%ecx
  80208b:	72 17                	jb     8020a4 <__udivdi3+0x10c>
  80208d:	74 09                	je     802098 <__udivdi3+0x100>
  80208f:	89 fe                	mov    %edi,%esi
  802091:	31 ff                	xor    %edi,%edi
  802093:	e9 41 ff ff ff       	jmp    801fd9 <__udivdi3+0x41>
  802098:	8b 54 24 04          	mov    0x4(%esp),%edx
  80209c:	89 f1                	mov    %esi,%ecx
  80209e:	d3 e2                	shl    %cl,%edx
  8020a0:	39 c2                	cmp    %eax,%edx
  8020a2:	73 eb                	jae    80208f <__udivdi3+0xf7>
  8020a4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8020a7:	31 ff                	xor    %edi,%edi
  8020a9:	e9 2b ff ff ff       	jmp    801fd9 <__udivdi3+0x41>
  8020ae:	66 90                	xchg   %ax,%ax
  8020b0:	31 f6                	xor    %esi,%esi
  8020b2:	e9 22 ff ff ff       	jmp    801fd9 <__udivdi3+0x41>
	...

008020b8 <__umoddi3>:
  8020b8:	55                   	push   %ebp
  8020b9:	57                   	push   %edi
  8020ba:	56                   	push   %esi
  8020bb:	83 ec 20             	sub    $0x20,%esp
  8020be:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020c2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8020c6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8020ca:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020d2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020d6:	89 c7                	mov    %eax,%edi
  8020d8:	89 f2                	mov    %esi,%edx
  8020da:	85 ed                	test   %ebp,%ebp
  8020dc:	75 16                	jne    8020f4 <__umoddi3+0x3c>
  8020de:	39 f1                	cmp    %esi,%ecx
  8020e0:	0f 86 a6 00 00 00    	jbe    80218c <__umoddi3+0xd4>
  8020e6:	f7 f1                	div    %ecx
  8020e8:	89 d0                	mov    %edx,%eax
  8020ea:	31 d2                	xor    %edx,%edx
  8020ec:	83 c4 20             	add    $0x20,%esp
  8020ef:	5e                   	pop    %esi
  8020f0:	5f                   	pop    %edi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    
  8020f3:	90                   	nop
  8020f4:	39 f5                	cmp    %esi,%ebp
  8020f6:	0f 87 ac 00 00 00    	ja     8021a8 <__umoddi3+0xf0>
  8020fc:	0f bd c5             	bsr    %ebp,%eax
  8020ff:	83 f0 1f             	xor    $0x1f,%eax
  802102:	89 44 24 10          	mov    %eax,0x10(%esp)
  802106:	0f 84 a8 00 00 00    	je     8021b4 <__umoddi3+0xfc>
  80210c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802110:	d3 e5                	shl    %cl,%ebp
  802112:	bf 20 00 00 00       	mov    $0x20,%edi
  802117:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80211b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80211f:	89 f9                	mov    %edi,%ecx
  802121:	d3 e8                	shr    %cl,%eax
  802123:	09 e8                	or     %ebp,%eax
  802125:	89 44 24 18          	mov    %eax,0x18(%esp)
  802129:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80212d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802131:	d3 e0                	shl    %cl,%eax
  802133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802137:	89 f2                	mov    %esi,%edx
  802139:	d3 e2                	shl    %cl,%edx
  80213b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80213f:	d3 e0                	shl    %cl,%eax
  802141:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802145:	8b 44 24 14          	mov    0x14(%esp),%eax
  802149:	89 f9                	mov    %edi,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 d0                	or     %edx,%eax
  80214f:	d3 ee                	shr    %cl,%esi
  802151:	89 f2                	mov    %esi,%edx
  802153:	f7 74 24 18          	divl   0x18(%esp)
  802157:	89 d6                	mov    %edx,%esi
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	89 c5                	mov    %eax,%ebp
  80215f:	89 d1                	mov    %edx,%ecx
  802161:	39 d6                	cmp    %edx,%esi
  802163:	72 67                	jb     8021cc <__umoddi3+0x114>
  802165:	74 75                	je     8021dc <__umoddi3+0x124>
  802167:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80216b:	29 e8                	sub    %ebp,%eax
  80216d:	19 ce                	sbb    %ecx,%esi
  80216f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802173:	d3 e8                	shr    %cl,%eax
  802175:	89 f2                	mov    %esi,%edx
  802177:	89 f9                	mov    %edi,%ecx
  802179:	d3 e2                	shl    %cl,%edx
  80217b:	09 d0                	or     %edx,%eax
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802183:	d3 ea                	shr    %cl,%edx
  802185:	83 c4 20             	add    $0x20,%esp
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	85 c9                	test   %ecx,%ecx
  80218e:	75 0b                	jne    80219b <__umoddi3+0xe3>
  802190:	b8 01 00 00 00       	mov    $0x1,%eax
  802195:	31 d2                	xor    %edx,%edx
  802197:	f7 f1                	div    %ecx
  802199:	89 c1                	mov    %eax,%ecx
  80219b:	89 f0                	mov    %esi,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	f7 f1                	div    %ecx
  8021a1:	89 f8                	mov    %edi,%eax
  8021a3:	e9 3e ff ff ff       	jmp    8020e6 <__umoddi3+0x2e>
  8021a8:	89 f2                	mov    %esi,%edx
  8021aa:	83 c4 20             	add    $0x20,%esp
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    
  8021b1:	8d 76 00             	lea    0x0(%esi),%esi
  8021b4:	39 f5                	cmp    %esi,%ebp
  8021b6:	72 04                	jb     8021bc <__umoddi3+0x104>
  8021b8:	39 f9                	cmp    %edi,%ecx
  8021ba:	77 06                	ja     8021c2 <__umoddi3+0x10a>
  8021bc:	89 f2                	mov    %esi,%edx
  8021be:	29 cf                	sub    %ecx,%edi
  8021c0:	19 ea                	sbb    %ebp,%edx
  8021c2:	89 f8                	mov    %edi,%eax
  8021c4:	83 c4 20             	add    $0x20,%esp
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    
  8021cb:	90                   	nop
  8021cc:	89 d1                	mov    %edx,%ecx
  8021ce:	89 c5                	mov    %eax,%ebp
  8021d0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8021d4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8021d8:	eb 8d                	jmp    802167 <__umoddi3+0xaf>
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8021e0:	72 ea                	jb     8021cc <__umoddi3+0x114>
  8021e2:	89 f1                	mov    %esi,%ecx
  8021e4:	eb 81                	jmp    802167 <__umoddi3+0xaf>
