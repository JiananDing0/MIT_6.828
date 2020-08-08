
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	c7 04 24 80 22 80 00 	movl   $0x802280,(%esp)
  800041:	e8 fe 01 00 00       	call   800244 <cprintf>
	exit();
  800046:	e8 3d 01 00 00       	call   800188 <exit>
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800063:	8b 45 0c             	mov    0xc(%ebp),%eax
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	8d 45 08             	lea    0x8(%ebp),%eax
  80006d:	89 04 24             	mov    %eax,(%esp)
  800070:	e8 f7 0d 00 00       	call   800e6c <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800075:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80007a:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  800080:	eb 11                	jmp    800093 <umain+0x46>
		if (i == '1')
  800082:	83 f8 31             	cmp    $0x31,%eax
  800085:	74 07                	je     80008e <umain+0x41>
			usefprint = 1;
		else
			usage();
  800087:	e8 a8 ff ff ff       	call   800034 <usage>
  80008c:	eb 05                	jmp    800093 <umain+0x46>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  80008e:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800093:	89 1c 24             	mov    %ebx,(%esp)
  800096:	e8 0a 0e 00 00       	call   800ea5 <argnext>
  80009b:	85 c0                	test   %eax,%eax
  80009d:	79 e3                	jns    800082 <umain+0x35>
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a4:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	e8 3e 14 00 00       	call   8014f4 <fstat>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 66                	js     800120 <umain+0xd3>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 36                	je     8000f4 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000c1:	8b 40 04             	mov    0x4(%eax),%eax
  8000c4:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000cb:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d2:	89 44 24 10          	mov    %eax,0x10(%esp)
					i, st.st_name, st.st_isdir,
  8000d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000de:	c7 44 24 04 94 22 80 	movl   $0x802294,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 26 18 00 00       	call   801918 <fprintf>
  8000f2:	eb 2c                	jmp    800120 <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f7:	8b 40 04             	mov    0x4(%eax),%eax
  8000fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800101:	89 44 24 10          	mov    %eax,0x10(%esp)
  800105:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800108:	89 44 24 0c          	mov    %eax,0xc(%esp)
					i, st.st_name, st.st_isdir,
  80010c:	89 74 24 08          	mov    %esi,0x8(%esp)
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  800110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800114:	c7 04 24 94 22 80 00 	movl   $0x802294,(%esp)
  80011b:	e8 24 01 00 00       	call   800244 <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  800120:	43                   	inc    %ebx
  800121:	83 fb 20             	cmp    $0x20,%ebx
  800124:	75 84                	jne    8000aa <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800126:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 10             	sub    $0x10,%esp
  80013c:	8b 75 08             	mov    0x8(%ebp),%esi
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800142:	e8 7c 0a 00 00       	call   800bc3 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800153:	c1 e0 07             	shl    $0x7,%eax
  800156:	29 d0                	sub    %edx,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800162:	85 f6                	test   %esi,%esi
  800164:	7e 07                	jle    80016d <libmain+0x39>
		binaryname = argv[0];
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800171:	89 34 24             	mov    %esi,(%esp)
  800174:	e8 d4 fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800179:	e8 0a 00 00 00       	call   800188 <exit>
}
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80018e:	e8 18 10 00 00       	call   8011ab <close_all>
	sys_env_destroy(0);
  800193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019a:	e8 d2 09 00 00       	call   800b71 <sys_env_destroy>
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    
  8001a1:	00 00                	add    %al,(%eax)
	...

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b7:	40                   	inc    %eax
  8001b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 19                	jne    8001da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c8:	00 
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 60 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001da:	ff 43 04             	incl   0x4(%ebx)
}
  8001dd:	83 c4 14             	add    $0x14,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 a4 01 80 00 	movl   $0x8001a4,(%esp)
  80021f:	e8 82 01 00 00       	call   8003a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800224:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	e8 f8 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  80023c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 87 ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	85 c0                	test   %eax,%eax
  800282:	75 08                	jne    80028c <printnum+0x2c>
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 57                	ja     8002e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800290:	4b                   	dec    %ebx
  800291:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ab:	00 
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	e8 6a 1d 00 00       	call   802028 <__udivdi3>
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	89 fa                	mov    %edi,%edx
  8002cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d2:	e8 89 ff ff ff       	call   800260 <printnum>
  8002d7:	eb 0f                	jmp    8002e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dd:	89 34 24             	mov    %esi,(%esp)
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e3:	4b                   	dec    %ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f f1                	jg     8002d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fe:	00 
  8002ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	e8 37 1e 00 00       	call   802148 <__umoddi3>
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	0f be 80 c6 22 80 00 	movsbl 0x8022c6(%eax),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800322:	83 c4 3c             	add    $0x3c,%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 08                	jae    80037c <sprintputch+0x18>
		*b->buf++ = ch;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 0a                	mov    %cl,(%edx)
  800379:	42                   	inc    %edx
  80037a:	89 10                	mov    %edx,(%eax)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038b:	8b 45 10             	mov    0x10(%ebp),%eax
  80038e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 02 00 00 00       	call   8003a6 <vprintfmt>
	va_end(ap);
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	57                   	push   %edi
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 4c             	sub    $0x4c,%esp
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 8b 03 00 00    	je     80074a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8003bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 06             	movzbl (%esi),%eax
  8003cc:	46                   	inc    %esi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e5                	jne    8003b7 <vprintfmt+0x11>
  8003d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	eb 26                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003f7:	eb 1d                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800400:	eb 14                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800405:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80040c:	eb 08                	jmp    800416 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80040e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800411:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	0f b6 06             	movzbl (%esi),%eax
  800419:	8d 56 01             	lea    0x1(%esi),%edx
  80041c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041f:	8a 16                	mov    (%esi),%dl
  800421:	83 ea 23             	sub    $0x23,%edx
  800424:	80 fa 55             	cmp    $0x55,%dl
  800427:	0f 87 01 03 00 00    	ja     80072e <vprintfmt+0x388>
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	ff 24 95 00 24 80 00 	jmp    *0x802400(,%edx,4)
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800442:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800446:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800449:	8d 50 d0             	lea    -0x30(%eax),%edx
  80044c:	83 fa 09             	cmp    $0x9,%edx
  80044f:	77 2a                	ja     80047b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800451:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800452:	eb eb                	jmp    80043f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 17                	jmp    80047b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800464:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800468:	78 98                	js     800402 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046d:	eb a7                	jmp    800416 <vprintfmt+0x70>
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800472:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800479:	eb 9b                	jmp    800416 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047f:	79 95                	jns    800416 <vprintfmt+0x70>
  800481:	eb 8b                	jmp    80040e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800487:	eb 8d                	jmp    800416 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a1:	e9 23 ff ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	79 02                	jns    8004b7 <vprintfmt+0x111>
  8004b5:	f7 d8                	neg    %eax
  8004b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 0f             	cmp    $0xf,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x123>
  8004be:	8b 04 85 60 25 80 00 	mov    0x802560(,%eax,4),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cd:	c7 44 24 08 de 22 80 	movl   $0x8022de,0x8(%esp)
  8004d4:	00 
  8004d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 9a fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e7:	e9 dd fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 ba 26 80 	movl   $0x8026ba,0x8(%esp)
  8004f7:	00 
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 14 24             	mov    %edx,(%esp)
  800502:	e8 77 fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 ba fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
  80050f:	89 f9                	mov    %edi,%ecx
  800511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800514:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 30                	mov    (%eax),%esi
  800522:	85 f6                	test   %esi,%esi
  800524:	75 05                	jne    80052b <vprintfmt+0x185>
				p = "(null)";
  800526:	be d7 22 80 00       	mov    $0x8022d7,%esi
			if (width > 0 && padc != '-')
  80052b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052f:	0f 8e 84 00 00 00    	jle    8005b9 <vprintfmt+0x213>
  800535:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800539:	74 7e                	je     8005b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053f:	89 34 24             	mov    %esi,(%esp)
  800542:	e8 ab 02 00 00       	call   8007f2 <strnlen>
  800547:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80054f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800553:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800556:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800559:	89 de                	mov    %ebx,%esi
  80055b:	89 d3                	mov    %edx,%ebx
  80055d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 0b                	jmp    80056c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	89 3c 24             	mov    %edi,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4b                   	dec    %ebx
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f f1                	jg     800561 <vprintfmt+0x1bb>
  800570:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800573:	89 f3                	mov    %esi,%ebx
  800575:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057b:	85 c0                	test   %eax,%eax
  80057d:	79 05                	jns    800584 <vprintfmt+0x1de>
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800587:	29 c2                	sub    %eax,%edx
  800589:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058c:	eb 2b                	jmp    8005b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800592:	74 18                	je     8005ac <vprintfmt+0x206>
  800594:	8d 50 e0             	lea    -0x20(%eax),%edx
  800597:	83 fa 5e             	cmp    $0x5e,%edx
  80059a:	76 10                	jbe    8005ac <vprintfmt+0x206>
					putch('?', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	eb 0a                	jmp    8005b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b9:	0f be 06             	movsbl (%esi),%eax
  8005bc:	46                   	inc    %esi
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	74 21                	je     8005e2 <vprintfmt+0x23c>
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	78 c9                	js     80058e <vprintfmt+0x1e8>
  8005c5:	4f                   	dec    %edi
  8005c6:	79 c6                	jns    80058e <vprintfmt+0x1e8>
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x244>
  8005e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x22c>
  8005ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f6:	e9 ce fd ff ff       	jmp    8003c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7e 10                	jle    800610 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 08             	lea    0x8(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	8b 78 04             	mov    0x4(%eax),%edi
  80060e:	eb 26                	jmp    800636 <vprintfmt+0x290>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 12                	je     800626 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 f7                	mov    %esi,%edi
  800621:	c1 ff 1f             	sar    $0x1f,%edi
  800624:	eb 10                	jmp    800636 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	89 f7                	mov    %esi,%edi
  800633:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	85 ff                	test   %edi,%edi
  800638:	78 0a                	js     800644 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 ac 00 00 00       	jmp    8006f0 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	f7 de                	neg    %esi
  800654:	83 d7 00             	adc    $0x0,%edi
  800657:	f7 df                	neg    %edi
			}
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 8d 00 00 00       	jmp    8006f0 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800663:	89 ca                	mov    %ecx,%edx
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 bd fc ff ff       	call   80032a <getuint>
  80066d:	89 c6                	mov    %eax,%esi
  80066f:	89 d7                	mov    %edx,%edi
			base = 10;
  800671:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800676:	eb 78                	jmp    8006f0 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800691:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a5:	e9 1f fd ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 43 fc ff ff       	call   80032a <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 4c fb ff ff       	call   800260 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 ad fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 9b fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x399>
  80073e:	4e                   	dec    %esi
  80073f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800743:	75 f9                	jne    80073e <vprintfmt+0x398>
  800745:	e9 7f fc ff ff       	jmp    8003c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 4c             	add    $0x4c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 33                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 64 03 80 00 	movl   $0x800364,(%esp)
  800793:	e8 0e fc ff ff       	call   8003a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 0c                	jmp    8007af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x5d>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 7b ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800bb6:	e8 b9 12 00 00       	call   801e74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	83 c4 2c             	add    $0x2c,%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800c48:	e8 27 12 00 00       	call   801e74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 75 18             	mov    0x18(%ebp),%esi
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 28                	jle    800ca0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c83:	00 
  800c84:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800c9b:	e8 d4 11 00 00       	call   801e74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	83 c4 2c             	add    $0x2c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800cee:	e8 81 11 00 00       	call   801e74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800d41:	e8 2e 11 00 00       	call   801e74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	83 c4 2c             	add    $0x2c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800d94:	e8 db 10 00 00       	call   801e74 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800de7:	e8 88 10 00 00       	call   801e74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dec:	83 c4 2c             	add    $0x2c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800dfa:	be 00 00 00 00       	mov    $0x0,%esi
  800dff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 cb                	mov    %ecx,%ebx
  800e2f:	89 cf                	mov    %ecx,%edi
  800e31:	89 ce                	mov    %ecx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800e5c:	e8 13 10 00 00       	call   801e74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e78:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e7a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e7d:	83 3a 01             	cmpl   $0x1,(%edx)
  800e80:	7e 0b                	jle    800e8d <argstart+0x21>
  800e82:	85 c9                	test   %ecx,%ecx
  800e84:	75 0e                	jne    800e94 <argstart+0x28>
  800e86:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8b:	eb 0c                	jmp    800e99 <argstart+0x2d>
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	eb 05                	jmp    800e99 <argstart+0x2d>
  800e94:	ba 91 22 80 00       	mov    $0x802291,%edx
  800e99:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <argnext>:

int
argnext(struct Argstate *args)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 14             	sub    $0x14,%esp
  800eac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800eaf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800eb6:	8b 43 08             	mov    0x8(%ebx),%eax
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	74 6c                	je     800f29 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  800ebd:	80 38 00             	cmpb   $0x0,(%eax)
  800ec0:	75 4d                	jne    800f0f <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800ec2:	8b 0b                	mov    (%ebx),%ecx
  800ec4:	83 39 01             	cmpl   $0x1,(%ecx)
  800ec7:	74 52                	je     800f1b <argnext+0x76>
		    || args->argv[1][0] != '-'
  800ec9:	8b 53 04             	mov    0x4(%ebx),%edx
  800ecc:	8b 42 04             	mov    0x4(%edx),%eax
  800ecf:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ed2:	75 47                	jne    800f1b <argnext+0x76>
		    || args->argv[1][1] == '\0')
  800ed4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ed8:	74 41                	je     800f1b <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800eda:	40                   	inc    %eax
  800edb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ede:	8b 01                	mov    (%ecx),%eax
  800ee0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eeb:	8d 42 08             	lea    0x8(%edx),%eax
  800eee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef2:	83 c2 04             	add    $0x4,%edx
  800ef5:	89 14 24             	mov    %edx,(%esp)
  800ef8:	e8 8b fa ff ff       	call   800988 <memmove>
		(*args->argc)--;
  800efd:	8b 03                	mov    (%ebx),%eax
  800eff:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800f01:	8b 43 08             	mov    0x8(%ebx),%eax
  800f04:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f07:	75 06                	jne    800f0f <argnext+0x6a>
  800f09:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f0d:	74 0c                	je     800f1b <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800f0f:	8b 53 08             	mov    0x8(%ebx),%edx
  800f12:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800f15:	42                   	inc    %edx
  800f16:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800f19:	eb 13                	jmp    800f2e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  800f1b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f27:	eb 05                	jmp    800f2e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f2e:	83 c4 14             	add    $0x14,%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 14             	sub    $0x14,%esp
  800f3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f3e:	8b 43 08             	mov    0x8(%ebx),%eax
  800f41:	85 c0                	test   %eax,%eax
  800f43:	74 59                	je     800f9e <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  800f45:	80 38 00             	cmpb   $0x0,(%eax)
  800f48:	74 0c                	je     800f56 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f4a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f4d:	c7 43 08 91 22 80 00 	movl   $0x802291,0x8(%ebx)
  800f54:	eb 43                	jmp    800f99 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  800f56:	8b 03                	mov    (%ebx),%eax
  800f58:	83 38 01             	cmpl   $0x1,(%eax)
  800f5b:	7e 2e                	jle    800f8b <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  800f5d:	8b 53 04             	mov    0x4(%ebx),%edx
  800f60:	8b 4a 04             	mov    0x4(%edx),%ecx
  800f63:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f66:	8b 00                	mov    (%eax),%eax
  800f68:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f73:	8d 42 08             	lea    0x8(%edx),%eax
  800f76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7a:	83 c2 04             	add    $0x4,%edx
  800f7d:	89 14 24             	mov    %edx,(%esp)
  800f80:	e8 03 fa ff ff       	call   800988 <memmove>
		(*args->argc)--;
  800f85:	8b 03                	mov    (%ebx),%eax
  800f87:	ff 08                	decl   (%eax)
  800f89:	eb 0e                	jmp    800f99 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  800f8b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f92:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f99:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f9c:	eb 05                	jmp    800fa3 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800fa3:	83 c4 14             	add    $0x14,%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 18             	sub    $0x18,%esp
  800faf:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800fb2:	8b 42 0c             	mov    0xc(%edx),%eax
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	75 08                	jne    800fc1 <argvalue+0x18>
  800fb9:	89 14 24             	mov    %edx,(%esp)
  800fbc:	e8 73 ff ff ff       	call   800f34 <argnextvalue>
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    
	...

00800fc4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	05 00 00 00 30       	add    $0x30000000,%eax
  800fcf:	c1 e8 0c             	shr    $0xc,%eax
}
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fda:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	e8 df ff ff ff       	call   800fc4 <fd2num>
  800fe5:	05 20 00 0d 00       	add    $0xd0020,%eax
  800fea:	c1 e0 0c             	shl    $0xc,%eax
}
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	53                   	push   %ebx
  800ff3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ff6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ffb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 ea 16             	shr    $0x16,%edx
  801002:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801009:	f6 c2 01             	test   $0x1,%dl
  80100c:	74 11                	je     80101f <fd_alloc+0x30>
  80100e:	89 c2                	mov    %eax,%edx
  801010:	c1 ea 0c             	shr    $0xc,%edx
  801013:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101a:	f6 c2 01             	test   $0x1,%dl
  80101d:	75 09                	jne    801028 <fd_alloc+0x39>
			*fd_store = fd;
  80101f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	eb 17                	jmp    80103f <fd_alloc+0x50>
  801028:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80102d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801032:	75 c7                	jne    800ffb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801034:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80103a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80103f:	5b                   	pop    %ebx
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801048:	83 f8 1f             	cmp    $0x1f,%eax
  80104b:	77 36                	ja     801083 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80104d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801052:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801055:	89 c2                	mov    %eax,%edx
  801057:	c1 ea 16             	shr    $0x16,%edx
  80105a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801061:	f6 c2 01             	test   $0x1,%dl
  801064:	74 24                	je     80108a <fd_lookup+0x48>
  801066:	89 c2                	mov    %eax,%edx
  801068:	c1 ea 0c             	shr    $0xc,%edx
  80106b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801072:	f6 c2 01             	test   $0x1,%dl
  801075:	74 1a                	je     801091 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801077:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107a:	89 02                	mov    %eax,(%edx)
	return 0;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	eb 13                	jmp    801096 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801083:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801088:	eb 0c                	jmp    801096 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80108a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108f:	eb 05                	jmp    801096 <fd_lookup+0x54>
  801091:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	53                   	push   %ebx
  80109c:	83 ec 14             	sub    $0x14,%esp
  80109f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010aa:	eb 0e                	jmp    8010ba <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8010ac:	39 08                	cmp    %ecx,(%eax)
  8010ae:	75 09                	jne    8010b9 <dev_lookup+0x21>
			*dev = devtab[i];
  8010b0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	eb 33                	jmp    8010ec <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010b9:	42                   	inc    %edx
  8010ba:	8b 04 95 68 26 80 00 	mov    0x802668(,%edx,4),%eax
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	75 e7                	jne    8010ac <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ca:	8b 40 48             	mov    0x48(%eax),%eax
  8010cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d5:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  8010dc:	e8 63 f1 ff ff       	call   800244 <cprintf>
	*dev = 0;
  8010e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010ec:	83 c4 14             	add    $0x14,%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 30             	sub    $0x30,%esp
  8010fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fd:	8a 45 0c             	mov    0xc(%ebp),%al
  801100:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801103:	89 34 24             	mov    %esi,(%esp)
  801106:	e8 b9 fe ff ff       	call   800fc4 <fd2num>
  80110b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80110e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801112:	89 04 24             	mov    %eax,(%esp)
  801115:	e8 28 ff ff ff       	call   801042 <fd_lookup>
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 05                	js     801125 <fd_close+0x33>
	    || fd != fd2)
  801120:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801123:	74 0d                	je     801132 <fd_close+0x40>
		return (must_exist ? r : 0);
  801125:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801129:	75 46                	jne    801171 <fd_close+0x7f>
  80112b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801130:	eb 3f                	jmp    801171 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801132:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801135:	89 44 24 04          	mov    %eax,0x4(%esp)
  801139:	8b 06                	mov    (%esi),%eax
  80113b:	89 04 24             	mov    %eax,(%esp)
  80113e:	e8 55 ff ff ff       	call   801098 <dev_lookup>
  801143:	89 c3                	mov    %eax,%ebx
  801145:	85 c0                	test   %eax,%eax
  801147:	78 18                	js     801161 <fd_close+0x6f>
		if (dev->dev_close)
  801149:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114c:	8b 40 10             	mov    0x10(%eax),%eax
  80114f:	85 c0                	test   %eax,%eax
  801151:	74 09                	je     80115c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801153:	89 34 24             	mov    %esi,(%esp)
  801156:	ff d0                	call   *%eax
  801158:	89 c3                	mov    %eax,%ebx
  80115a:	eb 05                	jmp    801161 <fd_close+0x6f>
		else
			r = 0;
  80115c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801161:	89 74 24 04          	mov    %esi,0x4(%esp)
  801165:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116c:	e8 37 fb ff ff       	call   800ca8 <sys_page_unmap>
	return r;
}
  801171:	89 d8                	mov    %ebx,%eax
  801173:	83 c4 30             	add    $0x30,%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801180:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801183:	89 44 24 04          	mov    %eax,0x4(%esp)
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	89 04 24             	mov    %eax,(%esp)
  80118d:	e8 b0 fe ff ff       	call   801042 <fd_lookup>
  801192:	85 c0                	test   %eax,%eax
  801194:	78 13                	js     8011a9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801196:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80119d:	00 
  80119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a1:	89 04 24             	mov    %eax,(%esp)
  8011a4:	e8 49 ff ff ff       	call   8010f2 <fd_close>
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <close_all>:

void
close_all(void)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011b7:	89 1c 24             	mov    %ebx,(%esp)
  8011ba:	e8 bb ff ff ff       	call   80117a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011bf:	43                   	inc    %ebx
  8011c0:	83 fb 20             	cmp    $0x20,%ebx
  8011c3:	75 f2                	jne    8011b7 <close_all+0xc>
		close(i);
}
  8011c5:	83 c4 14             	add    $0x14,%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 4c             	sub    $0x4c,%esp
  8011d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	89 04 24             	mov    %eax,(%esp)
  8011e4:	e8 59 fe ff ff       	call   801042 <fd_lookup>
  8011e9:	89 c3                	mov    %eax,%ebx
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	0f 88 e1 00 00 00    	js     8012d4 <dup+0x109>
		return r;
	close(newfdnum);
  8011f3:	89 3c 24             	mov    %edi,(%esp)
  8011f6:	e8 7f ff ff ff       	call   80117a <close>

	newfd = INDEX2FD(newfdnum);
  8011fb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801201:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	e8 c5 fd ff ff       	call   800fd4 <fd2data>
  80120f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801211:	89 34 24             	mov    %esi,(%esp)
  801214:	e8 bb fd ff ff       	call   800fd4 <fd2data>
  801219:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	c1 e8 16             	shr    $0x16,%eax
  801221:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801228:	a8 01                	test   $0x1,%al
  80122a:	74 46                	je     801272 <dup+0xa7>
  80122c:	89 d8                	mov    %ebx,%eax
  80122e:	c1 e8 0c             	shr    $0xc,%eax
  801231:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801238:	f6 c2 01             	test   $0x1,%dl
  80123b:	74 35                	je     801272 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80123d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801244:	25 07 0e 00 00       	and    $0xe07,%eax
  801249:	89 44 24 10          	mov    %eax,0x10(%esp)
  80124d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801250:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801254:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80125b:	00 
  80125c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801267:	e8 e9 f9 ff ff       	call   800c55 <sys_page_map>
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 3b                	js     8012ad <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 0c             	shr    $0xc,%edx
  80127a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801281:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801287:	89 54 24 10          	mov    %edx,0x10(%esp)
  80128b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80128f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801296:	00 
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a2:	e8 ae f9 ff ff       	call   800c55 <sys_page_map>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	79 25                	jns    8012d2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b8:	e8 eb f9 ff ff       	call   800ca8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cb:	e8 d8 f9 ff ff       	call   800ca8 <sys_page_unmap>
	return r;
  8012d0:	eb 02                	jmp    8012d4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012d2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	83 c4 4c             	add    $0x4c,%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5f                   	pop    %edi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 24             	sub    $0x24,%esp
  8012e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	89 1c 24             	mov    %ebx,(%esp)
  8012f2:	e8 4b fd ff ff       	call   801042 <fd_lookup>
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 6d                	js     801368 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	8b 00                	mov    (%eax),%eax
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	e8 89 fd ff ff       	call   801098 <dev_lookup>
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 55                	js     801368 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801313:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801316:	8b 50 08             	mov    0x8(%eax),%edx
  801319:	83 e2 03             	and    $0x3,%edx
  80131c:	83 fa 01             	cmp    $0x1,%edx
  80131f:	75 23                	jne    801344 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801321:	a1 04 40 80 00       	mov    0x804004,%eax
  801326:	8b 40 48             	mov    0x48(%eax),%eax
  801329:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80132d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801331:	c7 04 24 2d 26 80 00 	movl   $0x80262d,(%esp)
  801338:	e8 07 ef ff ff       	call   800244 <cprintf>
		return -E_INVAL;
  80133d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801342:	eb 24                	jmp    801368 <read+0x8a>
	}
	if (!dev->dev_read)
  801344:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801347:	8b 52 08             	mov    0x8(%edx),%edx
  80134a:	85 d2                	test   %edx,%edx
  80134c:	74 15                	je     801363 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80134e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801351:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801355:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801358:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80135c:	89 04 24             	mov    %eax,(%esp)
  80135f:	ff d2                	call   *%edx
  801361:	eb 05                	jmp    801368 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801363:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801368:	83 c4 24             	add    $0x24,%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    

0080136e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 1c             	sub    $0x1c,%esp
  801377:	8b 7d 08             	mov    0x8(%ebp),%edi
  80137a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80137d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801382:	eb 23                	jmp    8013a7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801384:	89 f0                	mov    %esi,%eax
  801386:	29 d8                	sub    %ebx,%eax
  801388:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138f:	01 d8                	add    %ebx,%eax
  801391:	89 44 24 04          	mov    %eax,0x4(%esp)
  801395:	89 3c 24             	mov    %edi,(%esp)
  801398:	e8 41 ff ff ff       	call   8012de <read>
		if (m < 0)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 10                	js     8013b1 <readn+0x43>
			return m;
		if (m == 0)
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	74 0a                	je     8013af <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a5:	01 c3                	add    %eax,%ebx
  8013a7:	39 f3                	cmp    %esi,%ebx
  8013a9:	72 d9                	jb     801384 <readn+0x16>
  8013ab:	89 d8                	mov    %ebx,%eax
  8013ad:	eb 02                	jmp    8013b1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013af:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013b1:	83 c4 1c             	add    $0x1c,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 24             	sub    $0x24,%esp
  8013c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ca:	89 1c 24             	mov    %ebx,(%esp)
  8013cd:	e8 70 fc ff ff       	call   801042 <fd_lookup>
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 68                	js     80143e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e0:	8b 00                	mov    (%eax),%eax
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	e8 ae fc ff ff       	call   801098 <dev_lookup>
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 50                	js     80143e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f5:	75 23                	jne    80141a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013fc:	8b 40 48             	mov    0x48(%eax),%eax
  8013ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801403:	89 44 24 04          	mov    %eax,0x4(%esp)
  801407:	c7 04 24 49 26 80 00 	movl   $0x802649,(%esp)
  80140e:	e8 31 ee ff ff       	call   800244 <cprintf>
		return -E_INVAL;
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801418:	eb 24                	jmp    80143e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141d:	8b 52 0c             	mov    0xc(%edx),%edx
  801420:	85 d2                	test   %edx,%edx
  801422:	74 15                	je     801439 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801424:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801427:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801432:	89 04 24             	mov    %eax,(%esp)
  801435:	ff d2                	call   *%edx
  801437:	eb 05                	jmp    80143e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801439:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80143e:	83 c4 24             	add    $0x24,%esp
  801441:	5b                   	pop    %ebx
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <seek>:

int
seek(int fdnum, off_t offset)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80144d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	89 04 24             	mov    %eax,(%esp)
  801457:	e8 e6 fb ff ff       	call   801042 <fd_lookup>
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 0e                	js     80146e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801460:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801463:	8b 55 0c             	mov    0xc(%ebp),%edx
  801466:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	53                   	push   %ebx
  801474:	83 ec 24             	sub    $0x24,%esp
  801477:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	89 1c 24             	mov    %ebx,(%esp)
  801484:	e8 b9 fb ff ff       	call   801042 <fd_lookup>
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 61                	js     8014ee <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801490:	89 44 24 04          	mov    %eax,0x4(%esp)
  801494:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801497:	8b 00                	mov    (%eax),%eax
  801499:	89 04 24             	mov    %eax,(%esp)
  80149c:	e8 f7 fb ff ff       	call   801098 <dev_lookup>
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 49                	js     8014ee <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ac:	75 23                	jne    8014d1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ae:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014b3:	8b 40 48             	mov    0x48(%eax),%eax
  8014b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  8014c5:	e8 7a ed ff ff       	call   800244 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cf:	eb 1d                	jmp    8014ee <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8014d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d4:	8b 52 18             	mov    0x18(%edx),%edx
  8014d7:	85 d2                	test   %edx,%edx
  8014d9:	74 0e                	je     8014e9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	ff d2                	call   *%edx
  8014e7:	eb 05                	jmp    8014ee <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014ee:	83 c4 24             	add    $0x24,%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 24             	sub    $0x24,%esp
  8014fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801501:	89 44 24 04          	mov    %eax,0x4(%esp)
  801505:	8b 45 08             	mov    0x8(%ebp),%eax
  801508:	89 04 24             	mov    %eax,(%esp)
  80150b:	e8 32 fb ff ff       	call   801042 <fd_lookup>
  801510:	85 c0                	test   %eax,%eax
  801512:	78 52                	js     801566 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 04 24             	mov    %eax,(%esp)
  801523:	e8 70 fb ff ff       	call   801098 <dev_lookup>
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 3a                	js     801566 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801533:	74 2c                	je     801561 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801535:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801538:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80153f:	00 00 00 
	stat->st_isdir = 0;
  801542:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801549:	00 00 00 
	stat->st_dev = dev;
  80154c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801559:	89 14 24             	mov    %edx,(%esp)
  80155c:	ff 50 14             	call   *0x14(%eax)
  80155f:	eb 05                	jmp    801566 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801561:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801566:	83 c4 24             	add    $0x24,%esp
  801569:	5b                   	pop    %ebx
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801574:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80157b:	00 
  80157c:	8b 45 08             	mov    0x8(%ebp),%eax
  80157f:	89 04 24             	mov    %eax,(%esp)
  801582:	e8 fe 01 00 00       	call   801785 <open>
  801587:	89 c3                	mov    %eax,%ebx
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 1b                	js     8015a8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80158d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801590:	89 44 24 04          	mov    %eax,0x4(%esp)
  801594:	89 1c 24             	mov    %ebx,(%esp)
  801597:	e8 58 ff ff ff       	call   8014f4 <fstat>
  80159c:	89 c6                	mov    %eax,%esi
	close(fd);
  80159e:	89 1c 24             	mov    %ebx,(%esp)
  8015a1:	e8 d4 fb ff ff       	call   80117a <close>
	return r;
  8015a6:	89 f3                	mov    %esi,%ebx
}
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    
  8015b1:	00 00                	add    %al,(%eax)
	...

008015b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 10             	sub    $0x10,%esp
  8015bc:	89 c3                	mov    %eax,%ebx
  8015be:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015c0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015c7:	75 11                	jne    8015da <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015d0:	e8 c8 09 00 00       	call   801f9d <ipc_find_env>
  8015d5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015da:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015e1:	00 
  8015e2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015e9:	00 
  8015ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 38 09 00 00       	call   801f33 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801602:	00 
  801603:	89 74 24 04          	mov    %esi,0x4(%esp)
  801607:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160e:	e8 b9 08 00 00       	call   801ecc <ipc_recv>
}
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	8b 40 0c             	mov    0xc(%eax),%eax
  801626:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801633:	ba 00 00 00 00       	mov    $0x0,%edx
  801638:	b8 02 00 00 00       	mov    $0x2,%eax
  80163d:	e8 72 ff ff ff       	call   8015b4 <fsipc>
}
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 40 0c             	mov    0xc(%eax),%eax
  801650:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 06 00 00 00       	mov    $0x6,%eax
  80165f:	e8 50 ff ff ff       	call   8015b4 <fsipc>
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 14             	sub    $0x14,%esp
  80166d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	8b 40 0c             	mov    0xc(%eax),%eax
  801676:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	b8 05 00 00 00       	mov    $0x5,%eax
  801685:	e8 2a ff ff ff       	call   8015b4 <fsipc>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 2b                	js     8016b9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801695:	00 
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 71 f1 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169e:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b9:	83 c4 14             	add    $0x14,%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016c5:	c7 44 24 08 78 26 80 	movl   $0x802678,0x8(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016d4:	00 
  8016d5:	c7 04 24 96 26 80 00 	movl   $0x802696,(%esp)
  8016dc:	e8 93 07 00 00       	call   801e74 <_panic>

008016e1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 10             	sub    $0x10,%esp
  8016e9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	b8 03 00 00 00       	mov    $0x3,%eax
  801707:	e8 a8 fe ff ff       	call   8015b4 <fsipc>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 6a                	js     80177c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801712:	39 c6                	cmp    %eax,%esi
  801714:	73 24                	jae    80173a <devfile_read+0x59>
  801716:	c7 44 24 0c a1 26 80 	movl   $0x8026a1,0xc(%esp)
  80171d:	00 
  80171e:	c7 44 24 08 a8 26 80 	movl   $0x8026a8,0x8(%esp)
  801725:	00 
  801726:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80172d:	00 
  80172e:	c7 04 24 96 26 80 00 	movl   $0x802696,(%esp)
  801735:	e8 3a 07 00 00       	call   801e74 <_panic>
	assert(r <= PGSIZE);
  80173a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80173f:	7e 24                	jle    801765 <devfile_read+0x84>
  801741:	c7 44 24 0c bd 26 80 	movl   $0x8026bd,0xc(%esp)
  801748:	00 
  801749:	c7 44 24 08 a8 26 80 	movl   $0x8026a8,0x8(%esp)
  801750:	00 
  801751:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801758:	00 
  801759:	c7 04 24 96 26 80 00 	movl   $0x802696,(%esp)
  801760:	e8 0f 07 00 00       	call   801e74 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801765:	89 44 24 08          	mov    %eax,0x8(%esp)
  801769:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801770:	00 
  801771:	8b 45 0c             	mov    0xc(%ebp),%eax
  801774:	89 04 24             	mov    %eax,(%esp)
  801777:	e8 0c f2 ff ff       	call   800988 <memmove>
	return r;
}
  80177c:	89 d8                	mov    %ebx,%eax
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	5b                   	pop    %ebx
  801782:	5e                   	pop    %esi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	83 ec 20             	sub    $0x20,%esp
  80178d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801790:	89 34 24             	mov    %esi,(%esp)
  801793:	e8 44 f0 ff ff       	call   8007dc <strlen>
  801798:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80179d:	7f 60                	jg     8017ff <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80179f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 45 f8 ff ff       	call   800fef <fd_alloc>
  8017aa:	89 c3                	mov    %eax,%ebx
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 54                	js     801804 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017bb:	e8 4f f0 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d0:	e8 df fd ff ff       	call   8015b4 <fsipc>
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	79 15                	jns    8017f0 <open+0x6b>
		fd_close(fd, 0);
  8017db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017e2:	00 
  8017e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e6:	89 04 24             	mov    %eax,(%esp)
  8017e9:	e8 04 f9 ff ff       	call   8010f2 <fd_close>
		return r;
  8017ee:	eb 14                	jmp    801804 <open+0x7f>
	}

	return fd2num(fd);
  8017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f3:	89 04 24             	mov    %eax,(%esp)
  8017f6:	e8 c9 f7 ff ff       	call   800fc4 <fd2num>
  8017fb:	89 c3                	mov    %eax,%ebx
  8017fd:	eb 05                	jmp    801804 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017ff:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801804:	89 d8                	mov    %ebx,%eax
  801806:	83 c4 20             	add    $0x20,%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
  801818:	b8 08 00 00 00       	mov    $0x8,%eax
  80181d:	e8 92 fd ff ff       	call   8015b4 <fsipc>
}
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	83 ec 14             	sub    $0x14,%esp
  80182b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80182d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801831:	7e 32                	jle    801865 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801833:	8b 40 04             	mov    0x4(%eax),%eax
  801836:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183a:	8d 43 10             	lea    0x10(%ebx),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	8b 03                	mov    (%ebx),%eax
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 6e fb ff ff       	call   8013b9 <write>
		if (result > 0)
  80184b:	85 c0                	test   %eax,%eax
  80184d:	7e 03                	jle    801852 <writebuf+0x2e>
			b->result += result;
  80184f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801852:	39 43 04             	cmp    %eax,0x4(%ebx)
  801855:	74 0e                	je     801865 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801857:	89 c2                	mov    %eax,%edx
  801859:	85 c0                	test   %eax,%eax
  80185b:	7e 05                	jle    801862 <writebuf+0x3e>
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801865:	83 c4 14             	add    $0x14,%esp
  801868:	5b                   	pop    %ebx
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <putch>:

static void
putch(int ch, void *thunk)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801875:	8b 43 04             	mov    0x4(%ebx),%eax
  801878:	8b 55 08             	mov    0x8(%ebp),%edx
  80187b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80187f:	40                   	inc    %eax
  801880:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801883:	3d 00 01 00 00       	cmp    $0x100,%eax
  801888:	75 0e                	jne    801898 <putch+0x2d>
		writebuf(b);
  80188a:	89 d8                	mov    %ebx,%eax
  80188c:	e8 93 ff ff ff       	call   801824 <writebuf>
		b->idx = 0;
  801891:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801898:	83 c4 04             	add    $0x4,%esp
  80189b:	5b                   	pop    %ebx
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018b0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018b7:	00 00 00 
	b.result = 0;
  8018ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018c1:	00 00 00 
	b.error = 1;
  8018c4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018cb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018dc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	c7 04 24 6b 18 80 00 	movl   $0x80186b,(%esp)
  8018ed:	e8 b4 ea ff ff       	call   8003a6 <vprintfmt>
	if (b.idx > 0)
  8018f2:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018f9:	7e 0b                	jle    801906 <vfprintf+0x68>
		writebuf(&b);
  8018fb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801901:	e8 1e ff ff ff       	call   801824 <writebuf>

	return (b.result ? b.result : b.error);
  801906:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80190c:	85 c0                	test   %eax,%eax
  80190e:	75 06                	jne    801916 <vfprintf+0x78>
  801910:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80191e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801921:	89 44 24 08          	mov    %eax,0x8(%esp)
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 67 ff ff ff       	call   80189e <vfprintf>
	va_end(ap);

	return cnt;
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <printf>:

int
printf(const char *fmt, ...)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80193f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801942:	89 44 24 08          	mov    %eax,0x8(%esp)
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801954:	e8 45 ff ff ff       	call   80189e <vfprintf>
	va_end(ap);

	return cnt;
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    
	...

0080195c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	83 ec 10             	sub    $0x10,%esp
  801964:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	89 04 24             	mov    %eax,(%esp)
  80196d:	e8 62 f6 ff ff       	call   800fd4 <fd2data>
  801972:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801974:	c7 44 24 04 c9 26 80 	movl   $0x8026c9,0x4(%esp)
  80197b:	00 
  80197c:	89 34 24             	mov    %esi,(%esp)
  80197f:	e8 8b ee ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801984:	8b 43 04             	mov    0x4(%ebx),%eax
  801987:	2b 03                	sub    (%ebx),%eax
  801989:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80198f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801996:	00 00 00 
	stat->st_dev = &devpipe;
  801999:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019a0:	30 80 00 
	return 0;
}
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	53                   	push   %ebx
  8019b3:	83 ec 14             	sub    $0x14,%esp
  8019b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c4:	e8 df f2 ff ff       	call   800ca8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019c9:	89 1c 24             	mov    %ebx,(%esp)
  8019cc:	e8 03 f6 ff ff       	call   800fd4 <fd2data>
  8019d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019dc:	e8 c7 f2 ff ff       	call   800ca8 <sys_page_unmap>
}
  8019e1:	83 c4 14             	add    $0x14,%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	57                   	push   %edi
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 2c             	sub    $0x2c,%esp
  8019f0:	89 c7                	mov    %eax,%edi
  8019f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8019fa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019fd:	89 3c 24             	mov    %edi,(%esp)
  801a00:	e8 df 05 00 00       	call   801fe4 <pageref>
  801a05:	89 c6                	mov    %eax,%esi
  801a07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0a:	89 04 24             	mov    %eax,(%esp)
  801a0d:	e8 d2 05 00 00       	call   801fe4 <pageref>
  801a12:	39 c6                	cmp    %eax,%esi
  801a14:	0f 94 c0             	sete   %al
  801a17:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a1a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a20:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a23:	39 cb                	cmp    %ecx,%ebx
  801a25:	75 08                	jne    801a2f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a27:	83 c4 2c             	add    $0x2c,%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5f                   	pop    %edi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a2f:	83 f8 01             	cmp    $0x1,%eax
  801a32:	75 c1                	jne    8019f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a34:	8b 42 58             	mov    0x58(%edx),%eax
  801a37:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801a3e:	00 
  801a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a47:	c7 04 24 d0 26 80 00 	movl   $0x8026d0,(%esp)
  801a4e:	e8 f1 e7 ff ff       	call   800244 <cprintf>
  801a53:	eb a0                	jmp    8019f5 <_pipeisclosed+0xe>

00801a55 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	57                   	push   %edi
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	83 ec 1c             	sub    $0x1c,%esp
  801a5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a61:	89 34 24             	mov    %esi,(%esp)
  801a64:	e8 6b f5 ff ff       	call   800fd4 <fd2data>
  801a69:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a70:	eb 3c                	jmp    801aae <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a72:	89 da                	mov    %ebx,%edx
  801a74:	89 f0                	mov    %esi,%eax
  801a76:	e8 6c ff ff ff       	call   8019e7 <_pipeisclosed>
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	75 38                	jne    801ab7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7f:	e8 5e f1 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a84:	8b 43 04             	mov    0x4(%ebx),%eax
  801a87:	8b 13                	mov    (%ebx),%edx
  801a89:	83 c2 20             	add    $0x20,%edx
  801a8c:	39 d0                	cmp    %edx,%eax
  801a8e:	73 e2                	jae    801a72 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a90:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a93:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a96:	89 c2                	mov    %eax,%edx
  801a98:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a9e:	79 05                	jns    801aa5 <devpipe_write+0x50>
  801aa0:	4a                   	dec    %edx
  801aa1:	83 ca e0             	or     $0xffffffe0,%edx
  801aa4:	42                   	inc    %edx
  801aa5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aa9:	40                   	inc    %eax
  801aaa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aad:	47                   	inc    %edi
  801aae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab1:	75 d1                	jne    801a84 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ab3:	89 f8                	mov    %edi,%eax
  801ab5:	eb 05                	jmp    801abc <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801abc:	83 c4 1c             	add    $0x1c,%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5f                   	pop    %edi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	57                   	push   %edi
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 1c             	sub    $0x1c,%esp
  801acd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad0:	89 3c 24             	mov    %edi,(%esp)
  801ad3:	e8 fc f4 ff ff       	call   800fd4 <fd2data>
  801ad8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ada:	be 00 00 00 00       	mov    $0x0,%esi
  801adf:	eb 3a                	jmp    801b1b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ae1:	85 f6                	test   %esi,%esi
  801ae3:	74 04                	je     801ae9 <devpipe_read+0x25>
				return i;
  801ae5:	89 f0                	mov    %esi,%eax
  801ae7:	eb 40                	jmp    801b29 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ae9:	89 da                	mov    %ebx,%edx
  801aeb:	89 f8                	mov    %edi,%eax
  801aed:	e8 f5 fe ff ff       	call   8019e7 <_pipeisclosed>
  801af2:	85 c0                	test   %eax,%eax
  801af4:	75 2e                	jne    801b24 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801af6:	e8 e7 f0 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801afb:	8b 03                	mov    (%ebx),%eax
  801afd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b00:	74 df                	je     801ae1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b02:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b07:	79 05                	jns    801b0e <devpipe_read+0x4a>
  801b09:	48                   	dec    %eax
  801b0a:	83 c8 e0             	or     $0xffffffe0,%eax
  801b0d:	40                   	inc    %eax
  801b0e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b15:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b18:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1a:	46                   	inc    %esi
  801b1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b1e:	75 db                	jne    801afb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b20:	89 f0                	mov    %esi,%eax
  801b22:	eb 05                	jmp    801b29 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b29:	83 c4 1c             	add    $0x1c,%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5f                   	pop    %edi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	57                   	push   %edi
  801b35:	56                   	push   %esi
  801b36:	53                   	push   %ebx
  801b37:	83 ec 3c             	sub    $0x3c,%esp
  801b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b40:	89 04 24             	mov    %eax,(%esp)
  801b43:	e8 a7 f4 ff ff       	call   800fef <fd_alloc>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	0f 88 45 01 00 00    	js     801c97 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b59:	00 
  801b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b68:	e8 94 f0 ff ff       	call   800c01 <sys_page_alloc>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 20 01 00 00    	js     801c97 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b77:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 6d f4 ff ff       	call   800fef <fd_alloc>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 f8 00 00 00    	js     801c84 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b93:	00 
  801b94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba2:	e8 5a f0 ff ff       	call   800c01 <sys_page_alloc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	0f 88 d3 00 00 00    	js     801c84 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 18 f4 ff ff       	call   800fd4 <fd2data>
  801bbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bc5:	00 
  801bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd1:	e8 2b f0 ff ff       	call   800c01 <sys_page_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 91 00 00 00    	js     801c71 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 e9 f3 ff ff       	call   800fd4 <fd2data>
  801beb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bf2:	00 
  801bf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bfe:	00 
  801bff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0a:	e8 46 f0 ff ff       	call   800c55 <sys_page_map>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 4c                	js     801c61 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c35:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c42:	89 04 24             	mov    %eax,(%esp)
  801c45:	e8 7a f3 ff ff       	call   800fc4 <fd2num>
  801c4a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c4f:	89 04 24             	mov    %eax,(%esp)
  801c52:	e8 6d f3 ff ff       	call   800fc4 <fd2num>
  801c57:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5f:	eb 36                	jmp    801c97 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801c61:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c6c:	e8 37 f0 ff ff       	call   800ca8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7f:	e8 24 f0 ff ff       	call   800ca8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c92:	e8 11 f0 ff ff       	call   800ca8 <sys_page_unmap>
    err:
	return r;
}
  801c97:	89 d8                	mov    %ebx,%eax
  801c99:	83 c4 3c             	add    $0x3c,%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801caa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 89 f3 ff ff       	call   801042 <fd_lookup>
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 15                	js     801cd2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc0:	89 04 24             	mov    %eax,(%esp)
  801cc3:	e8 0c f3 ff ff       	call   800fd4 <fd2data>
	return _pipeisclosed(fd, p);
  801cc8:	89 c2                	mov    %eax,%edx
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	e8 15 fd ff ff       	call   8019e7 <_pipeisclosed>
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ce4:	c7 44 24 04 e8 26 80 	movl   $0x8026e8,0x4(%esp)
  801ceb:	00 
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	89 04 24             	mov    %eax,(%esp)
  801cf2:	e8 18 eb ff ff       	call   80080f <strcpy>
	return 0;
}
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d15:	eb 30                	jmp    801d47 <devcons_write+0x49>
		m = n - tot;
  801d17:	8b 75 10             	mov    0x10(%ebp),%esi
  801d1a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d1c:	83 fe 7f             	cmp    $0x7f,%esi
  801d1f:	76 05                	jbe    801d26 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801d21:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d26:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d2a:	03 45 0c             	add    0xc(%ebp),%eax
  801d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d31:	89 3c 24             	mov    %edi,(%esp)
  801d34:	e8 4f ec ff ff       	call   800988 <memmove>
		sys_cputs(buf, m);
  801d39:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3d:	89 3c 24             	mov    %edi,(%esp)
  801d40:	e8 ef ed ff ff       	call   800b34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d45:	01 f3                	add    %esi,%ebx
  801d47:	89 d8                	mov    %ebx,%eax
  801d49:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d4c:	72 c9                	jb     801d17 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d4e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    

00801d59 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d63:	75 07                	jne    801d6c <devcons_read+0x13>
  801d65:	eb 25                	jmp    801d8c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d67:	e8 76 ee ff ff       	call   800be2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d6c:	e8 e1 ed ff ff       	call   800b52 <sys_cgetc>
  801d71:	85 c0                	test   %eax,%eax
  801d73:	74 f2                	je     801d67 <devcons_read+0xe>
  801d75:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 1d                	js     801d98 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d7b:	83 f8 04             	cmp    $0x4,%eax
  801d7e:	74 13                	je     801d93 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d83:	88 10                	mov    %dl,(%eax)
	return 1;
  801d85:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8a:	eb 0c                	jmp    801d98 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d91:	eb 05                	jmp    801d98 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801da0:	8b 45 08             	mov    0x8(%ebp),%eax
  801da3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801dad:	00 
  801dae:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db1:	89 04 24             	mov    %eax,(%esp)
  801db4:	e8 7b ed ff ff       	call   800b34 <sys_cputs>
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <getchar>:

int
getchar(void)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801dc8:	00 
  801dc9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd7:	e8 02 f5 ff ff       	call   8012de <read>
	if (r < 0)
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 0f                	js     801def <getchar+0x34>
		return r;
	if (r < 1)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	7e 06                	jle    801dea <getchar+0x2f>
		return -E_EOF;
	return c;
  801de4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de8:	eb 05                	jmp    801def <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801e01:	89 04 24             	mov    %eax,(%esp)
  801e04:	e8 39 f2 ff ff       	call   801042 <fd_lookup>
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 11                	js     801e1e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e16:	39 10                	cmp    %edx,(%eax)
  801e18:	0f 94 c0             	sete   %al
  801e1b:	0f b6 c0             	movzbl %al,%eax
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <opencons>:

int
opencons(void)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e29:	89 04 24             	mov    %eax,(%esp)
  801e2c:	e8 be f1 ff ff       	call   800fef <fd_alloc>
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 3c                	js     801e71 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e35:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e3c:	00 
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4b:	e8 b1 ed ff ff       	call   800c01 <sys_page_alloc>
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 1d                	js     801e71 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e54:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e62:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e69:	89 04 24             	mov    %eax,(%esp)
  801e6c:	e8 53 f1 ff ff       	call   800fc4 <fd2num>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    
	...

00801e74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801e7c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e7f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e85:	e8 39 ed ff ff       	call   800bc3 <sys_getenvid>
  801e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e8d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e91:	8b 55 08             	mov    0x8(%ebp),%edx
  801e94:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea0:	c7 04 24 f4 26 80 00 	movl   $0x8026f4,(%esp)
  801ea7:	e8 98 e3 ff ff       	call   800244 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eac:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb3:	89 04 24             	mov    %eax,(%esp)
  801eb6:	e8 28 e3 ff ff       	call   8001e3 <vcprintf>
	cprintf("\n");
  801ebb:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  801ec2:	e8 7d e3 ff ff       	call   800244 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ec7:	cc                   	int3   
  801ec8:	eb fd                	jmp    801ec7 <_panic+0x53>
	...

00801ecc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	56                   	push   %esi
  801ed0:	53                   	push   %ebx
  801ed1:	83 ec 10             	sub    $0x10,%esp
  801ed4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801edd:	85 c0                	test   %eax,%eax
  801edf:	75 05                	jne    801ee6 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801ee1:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 29 ef ff ff       	call   800e17 <sys_ipc_recv>
	if (!err) {
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	75 26                	jne    801f18 <ipc_recv+0x4c>
		if (from_env_store) {
  801ef2:	85 f6                	test   %esi,%esi
  801ef4:	74 0a                	je     801f00 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801ef6:	a1 04 40 80 00       	mov    0x804004,%eax
  801efb:	8b 40 74             	mov    0x74(%eax),%eax
  801efe:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801f00:	85 db                	test   %ebx,%ebx
  801f02:	74 0a                	je     801f0e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801f04:	a1 04 40 80 00       	mov    0x804004,%eax
  801f09:	8b 40 78             	mov    0x78(%eax),%eax
  801f0c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801f0e:	a1 04 40 80 00       	mov    0x804004,%eax
  801f13:	8b 40 70             	mov    0x70(%eax),%eax
  801f16:	eb 14                	jmp    801f2c <ipc_recv+0x60>
	}
	if (from_env_store) {
  801f18:	85 f6                	test   %esi,%esi
  801f1a:	74 06                	je     801f22 <ipc_recv+0x56>
		*from_env_store = 0;
  801f1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801f22:	85 db                	test   %ebx,%ebx
  801f24:	74 06                	je     801f2c <ipc_recv+0x60>
		*perm_store = 0;
  801f26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 1c             	sub    $0x1c,%esp
  801f3c:	8b 75 10             	mov    0x10(%ebp),%esi
  801f3f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801f42:	85 f6                	test   %esi,%esi
  801f44:	75 05                	jne    801f4b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801f46:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f4f:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	89 04 24             	mov    %eax,(%esp)
  801f60:	e8 8f ee ff ff       	call   800df4 <sys_ipc_try_send>
  801f65:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801f67:	e8 76 ec ff ff       	call   800be2 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801f6c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801f6f:	74 da                	je     801f4b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	74 20                	je     801f95 <ipc_send+0x62>
		panic("send fail: %e", err);
  801f75:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f79:	c7 44 24 08 18 27 80 	movl   $0x802718,0x8(%esp)
  801f80:	00 
  801f81:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801f88:	00 
  801f89:	c7 04 24 26 27 80 00 	movl   $0x802726,(%esp)
  801f90:	e8 df fe ff ff       	call   801e74 <_panic>
	}
	return;
}
  801f95:	83 c4 1c             	add    $0x1c,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	53                   	push   %ebx
  801fa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801fb0:	89 c2                	mov    %eax,%edx
  801fb2:	c1 e2 07             	shl    $0x7,%edx
  801fb5:	29 ca                	sub    %ecx,%edx
  801fb7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fbd:	8b 52 50             	mov    0x50(%edx),%edx
  801fc0:	39 da                	cmp    %ebx,%edx
  801fc2:	75 0f                	jne    801fd3 <ipc_find_env+0x36>
			return envs[i].env_id;
  801fc4:	c1 e0 07             	shl    $0x7,%eax
  801fc7:	29 c8                	sub    %ecx,%eax
  801fc9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fce:	8b 40 40             	mov    0x40(%eax),%eax
  801fd1:	eb 0c                	jmp    801fdf <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd3:	40                   	inc    %eax
  801fd4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd9:	75 ce                	jne    801fa9 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fdb:	66 b8 00 00          	mov    $0x0,%ax
}
  801fdf:	5b                   	pop    %ebx
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    
	...

00801fe4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fea:	89 c2                	mov    %eax,%edx
  801fec:	c1 ea 16             	shr    $0x16,%edx
  801fef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ff6:	f6 c2 01             	test   $0x1,%dl
  801ff9:	74 1e                	je     802019 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ffb:	c1 e8 0c             	shr    $0xc,%eax
  801ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802005:	a8 01                	test   $0x1,%al
  802007:	74 17                	je     802020 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802009:	c1 e8 0c             	shr    $0xc,%eax
  80200c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802013:	ef 
  802014:	0f b7 c0             	movzwl %ax,%eax
  802017:	eb 0c                	jmp    802025 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
  80201e:	eb 05                	jmp    802025 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
	...

00802028 <__udivdi3>:
  802028:	55                   	push   %ebp
  802029:	57                   	push   %edi
  80202a:	56                   	push   %esi
  80202b:	83 ec 10             	sub    $0x10,%esp
  80202e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802032:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80203e:	89 cd                	mov    %ecx,%ebp
  802040:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802044:	85 c0                	test   %eax,%eax
  802046:	75 2c                	jne    802074 <__udivdi3+0x4c>
  802048:	39 f9                	cmp    %edi,%ecx
  80204a:	77 68                	ja     8020b4 <__udivdi3+0x8c>
  80204c:	85 c9                	test   %ecx,%ecx
  80204e:	75 0b                	jne    80205b <__udivdi3+0x33>
  802050:	b8 01 00 00 00       	mov    $0x1,%eax
  802055:	31 d2                	xor    %edx,%edx
  802057:	f7 f1                	div    %ecx
  802059:	89 c1                	mov    %eax,%ecx
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	89 f8                	mov    %edi,%eax
  80205f:	f7 f1                	div    %ecx
  802061:	89 c7                	mov    %eax,%edi
  802063:	89 f0                	mov    %esi,%eax
  802065:	f7 f1                	div    %ecx
  802067:	89 c6                	mov    %eax,%esi
  802069:	89 f0                	mov    %esi,%eax
  80206b:	89 fa                	mov    %edi,%edx
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	39 f8                	cmp    %edi,%eax
  802076:	77 2c                	ja     8020a4 <__udivdi3+0x7c>
  802078:	0f bd f0             	bsr    %eax,%esi
  80207b:	83 f6 1f             	xor    $0x1f,%esi
  80207e:	75 4c                	jne    8020cc <__udivdi3+0xa4>
  802080:	39 f8                	cmp    %edi,%eax
  802082:	bf 00 00 00 00       	mov    $0x0,%edi
  802087:	72 0a                	jb     802093 <__udivdi3+0x6b>
  802089:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80208d:	0f 87 ad 00 00 00    	ja     802140 <__udivdi3+0x118>
  802093:	be 01 00 00 00       	mov    $0x1,%esi
  802098:	89 f0                	mov    %esi,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	5e                   	pop    %esi
  8020a0:	5f                   	pop    %edi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    
  8020a3:	90                   	nop
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	31 f6                	xor    %esi,%esi
  8020a8:	89 f0                	mov    %esi,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	5e                   	pop    %esi
  8020b0:	5f                   	pop    %edi
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    
  8020b3:	90                   	nop
  8020b4:	89 fa                	mov    %edi,%edx
  8020b6:	89 f0                	mov    %esi,%eax
  8020b8:	f7 f1                	div    %ecx
  8020ba:	89 c6                	mov    %eax,%esi
  8020bc:	31 ff                	xor    %edi,%edi
  8020be:	89 f0                	mov    %esi,%eax
  8020c0:	89 fa                	mov    %edi,%edx
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d 76 00             	lea    0x0(%esi),%esi
  8020cc:	89 f1                	mov    %esi,%ecx
  8020ce:	d3 e0                	shl    %cl,%eax
  8020d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d9:	29 f0                	sub    %esi,%eax
  8020db:	89 ea                	mov    %ebp,%edx
  8020dd:	88 c1                	mov    %al,%cl
  8020df:	d3 ea                	shr    %cl,%edx
  8020e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8020e5:	09 ca                	or     %ecx,%edx
  8020e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020eb:	89 f1                	mov    %esi,%ecx
  8020ed:	d3 e5                	shl    %cl,%ebp
  8020ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8020f3:	89 fd                	mov    %edi,%ebp
  8020f5:	88 c1                	mov    %al,%cl
  8020f7:	d3 ed                	shr    %cl,%ebp
  8020f9:	89 fa                	mov    %edi,%edx
  8020fb:	89 f1                	mov    %esi,%ecx
  8020fd:	d3 e2                	shl    %cl,%edx
  8020ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802103:	88 c1                	mov    %al,%cl
  802105:	d3 ef                	shr    %cl,%edi
  802107:	09 d7                	or     %edx,%edi
  802109:	89 f8                	mov    %edi,%eax
  80210b:	89 ea                	mov    %ebp,%edx
  80210d:	f7 74 24 08          	divl   0x8(%esp)
  802111:	89 d1                	mov    %edx,%ecx
  802113:	89 c7                	mov    %eax,%edi
  802115:	f7 64 24 0c          	mull   0xc(%esp)
  802119:	39 d1                	cmp    %edx,%ecx
  80211b:	72 17                	jb     802134 <__udivdi3+0x10c>
  80211d:	74 09                	je     802128 <__udivdi3+0x100>
  80211f:	89 fe                	mov    %edi,%esi
  802121:	31 ff                	xor    %edi,%edi
  802123:	e9 41 ff ff ff       	jmp    802069 <__udivdi3+0x41>
  802128:	8b 54 24 04          	mov    0x4(%esp),%edx
  80212c:	89 f1                	mov    %esi,%ecx
  80212e:	d3 e2                	shl    %cl,%edx
  802130:	39 c2                	cmp    %eax,%edx
  802132:	73 eb                	jae    80211f <__udivdi3+0xf7>
  802134:	8d 77 ff             	lea    -0x1(%edi),%esi
  802137:	31 ff                	xor    %edi,%edi
  802139:	e9 2b ff ff ff       	jmp    802069 <__udivdi3+0x41>
  80213e:	66 90                	xchg   %ax,%ax
  802140:	31 f6                	xor    %esi,%esi
  802142:	e9 22 ff ff ff       	jmp    802069 <__udivdi3+0x41>
	...

00802148 <__umoddi3>:
  802148:	55                   	push   %ebp
  802149:	57                   	push   %edi
  80214a:	56                   	push   %esi
  80214b:	83 ec 20             	sub    $0x20,%esp
  80214e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802152:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802156:	89 44 24 14          	mov    %eax,0x14(%esp)
  80215a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80215e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802162:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802166:	89 c7                	mov    %eax,%edi
  802168:	89 f2                	mov    %esi,%edx
  80216a:	85 ed                	test   %ebp,%ebp
  80216c:	75 16                	jne    802184 <__umoddi3+0x3c>
  80216e:	39 f1                	cmp    %esi,%ecx
  802170:	0f 86 a6 00 00 00    	jbe    80221c <__umoddi3+0xd4>
  802176:	f7 f1                	div    %ecx
  802178:	89 d0                	mov    %edx,%eax
  80217a:	31 d2                	xor    %edx,%edx
  80217c:	83 c4 20             	add    $0x20,%esp
  80217f:	5e                   	pop    %esi
  802180:	5f                   	pop    %edi
  802181:	5d                   	pop    %ebp
  802182:	c3                   	ret    
  802183:	90                   	nop
  802184:	39 f5                	cmp    %esi,%ebp
  802186:	0f 87 ac 00 00 00    	ja     802238 <__umoddi3+0xf0>
  80218c:	0f bd c5             	bsr    %ebp,%eax
  80218f:	83 f0 1f             	xor    $0x1f,%eax
  802192:	89 44 24 10          	mov    %eax,0x10(%esp)
  802196:	0f 84 a8 00 00 00    	je     802244 <__umoddi3+0xfc>
  80219c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021a0:	d3 e5                	shl    %cl,%ebp
  8021a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8021ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021af:	89 f9                	mov    %edi,%ecx
  8021b1:	d3 e8                	shr    %cl,%eax
  8021b3:	09 e8                	or     %ebp,%eax
  8021b5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8021b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021c1:	d3 e0                	shl    %cl,%eax
  8021c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021c7:	89 f2                	mov    %esi,%edx
  8021c9:	d3 e2                	shl    %cl,%edx
  8021cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021cf:	d3 e0                	shl    %cl,%eax
  8021d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8021d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021d9:	89 f9                	mov    %edi,%ecx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	09 d0                	or     %edx,%eax
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	89 f2                	mov    %esi,%edx
  8021e3:	f7 74 24 18          	divl   0x18(%esp)
  8021e7:	89 d6                	mov    %edx,%esi
  8021e9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ed:	89 c5                	mov    %eax,%ebp
  8021ef:	89 d1                	mov    %edx,%ecx
  8021f1:	39 d6                	cmp    %edx,%esi
  8021f3:	72 67                	jb     80225c <__umoddi3+0x114>
  8021f5:	74 75                	je     80226c <__umoddi3+0x124>
  8021f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021fb:	29 e8                	sub    %ebp,%eax
  8021fd:	19 ce                	sbb    %ecx,%esi
  8021ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802203:	d3 e8                	shr    %cl,%eax
  802205:	89 f2                	mov    %esi,%edx
  802207:	89 f9                	mov    %edi,%ecx
  802209:	d3 e2                	shl    %cl,%edx
  80220b:	09 d0                	or     %edx,%eax
  80220d:	89 f2                	mov    %esi,%edx
  80220f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802213:	d3 ea                	shr    %cl,%edx
  802215:	83 c4 20             	add    $0x20,%esp
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	85 c9                	test   %ecx,%ecx
  80221e:	75 0b                	jne    80222b <__umoddi3+0xe3>
  802220:	b8 01 00 00 00       	mov    $0x1,%eax
  802225:	31 d2                	xor    %edx,%edx
  802227:	f7 f1                	div    %ecx
  802229:	89 c1                	mov    %eax,%ecx
  80222b:	89 f0                	mov    %esi,%eax
  80222d:	31 d2                	xor    %edx,%edx
  80222f:	f7 f1                	div    %ecx
  802231:	89 f8                	mov    %edi,%eax
  802233:	e9 3e ff ff ff       	jmp    802176 <__umoddi3+0x2e>
  802238:	89 f2                	mov    %esi,%edx
  80223a:	83 c4 20             	add    $0x20,%esp
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
  802241:	8d 76 00             	lea    0x0(%esi),%esi
  802244:	39 f5                	cmp    %esi,%ebp
  802246:	72 04                	jb     80224c <__umoddi3+0x104>
  802248:	39 f9                	cmp    %edi,%ecx
  80224a:	77 06                	ja     802252 <__umoddi3+0x10a>
  80224c:	89 f2                	mov    %esi,%edx
  80224e:	29 cf                	sub    %ecx,%edi
  802250:	19 ea                	sbb    %ebp,%edx
  802252:	89 f8                	mov    %edi,%eax
  802254:	83 c4 20             	add    $0x20,%esp
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	90                   	nop
  80225c:	89 d1                	mov    %edx,%ecx
  80225e:	89 c5                	mov    %eax,%ebp
  802260:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802264:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802268:	eb 8d                	jmp    8021f7 <__umoddi3+0xaf>
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802270:	72 ea                	jb     80225c <__umoddi3+0x114>
  802272:	89 f1                	mov    %esi,%ecx
  802274:	eb 81                	jmp    8021f7 <__umoddi3+0xaf>
