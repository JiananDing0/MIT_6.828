
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 40 0b 00 00       	call   800b83 <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  800052:	e8 ad 01 00 00       	call   800204 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 07 07 00 00       	call   80079c <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 91 24 80 	movl   $0x802491,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 b0 06 00 00       	call   800771 <snprintf>
	if (fork() == 0) {
  8000c1:	e8 75 0e 00 00       	call   800f3b <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 6e 00 00 00       	call   800148 <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800102:	e8 7c 0a 00 00       	call   800b83 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 f6                	test   %esi,%esi
  800124:	7e 07                	jle    80012d <libmain+0x39>
		binaryname = argv[0];
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800131:	89 34 24             	mov    %esi,(%esp)
  800134:	e8 a7 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    
  800145:	00 00                	add    %al,(%eax)
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 c8 12 00 00       	call   80141b <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 d2 09 00 00       	call   800b31 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	40                   	inc    %eax
  800178:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	75 19                	jne    80019a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800181:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800188:	00 
  800189:	8d 43 08             	lea    0x8(%ebx),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 60 09 00 00       	call   800af4 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019a:	ff 43 04             	incl   0x4(%ebx)
}
  80019d:	83 c4 14             	add    $0x14,%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	c7 04 24 64 01 80 00 	movl   $0x800164,(%esp)
  8001df:	e8 82 01 00 00       	call   800366 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 f8 08 00 00       	call   800af4 <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	e8 87 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	85 c0                	test   %eax,%eax
  800242:	75 08                	jne    80024c <printnum+0x2c>
  800244:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 57                	ja     8002a3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800250:	4b                   	dec    %ebx
  800251:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800260:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800264:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026b:	00 
  80026c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	e8 a6 1f 00 00       	call   802224 <__udivdi3>
  80027e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800282:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028d:	89 fa                	mov    %edi,%edx
  80028f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800292:	e8 89 ff ff ff       	call   800220 <printnum>
  800297:	eb 0f                	jmp    8002a8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	89 34 24             	mov    %esi,(%esp)
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	4b                   	dec    %ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f f1                	jg     800299 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002be:	00 
  8002bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	e8 73 20 00 00       	call   802344 <__umoddi3>
  8002d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d5:	0f be 80 a0 24 80 00 	movsbl 0x8024a0(%eax),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e2:	83 c4 3c             	add    $0x3c,%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x38>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 08                	jae    80033c <sprintputch+0x18>
		*b->buf++ = ch;
  800334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800337:	88 0a                	mov    %cl,(%edx)
  800339:	42                   	inc    %edx
  80033a:	89 10                	mov    %edx,(%eax)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034b:	8b 45 10             	mov    0x10(%ebp),%eax
  80034e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	e8 02 00 00 00       	call   800366 <vprintfmt>
	va_end(ap);
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 4c             	sub    $0x4c,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800372:	8b 75 10             	mov    0x10(%ebp),%esi
  800375:	eb 12                	jmp    800389 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800377:	85 c0                	test   %eax,%eax
  800379:	0f 84 8b 03 00 00    	je     80070a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80037f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800389:	0f b6 06             	movzbl (%esi),%eax
  80038c:	46                   	inc    %esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e5                	jne    800377 <vprintfmt+0x11>
  800392:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800396:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80039d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ae:	eb 26                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003b7:	eb 1d                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c0:	eb 14                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cc:	eb 08                	jmp    8003d6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	0f b6 06             	movzbl (%esi),%eax
  8003d9:	8d 56 01             	lea    0x1(%esi),%edx
  8003dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003df:	8a 16                	mov    (%esi),%dl
  8003e1:	83 ea 23             	sub    $0x23,%edx
  8003e4:	80 fa 55             	cmp    $0x55,%dl
  8003e7:	0f 87 01 03 00 00    	ja     8006ee <vprintfmt+0x388>
  8003ed:	0f b6 d2             	movzbl %dl,%edx
  8003f0:	ff 24 95 e0 25 80 00 	jmp    *0x8025e0(,%edx,4)
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800402:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800406:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800409:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040c:	83 fa 09             	cmp    $0x9,%edx
  80040f:	77 2a                	ja     80043b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb eb                	jmp    8003ff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800422:	eb 17                	jmp    80043b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800424:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800428:	78 98                	js     8003c2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042d:	eb a7                	jmp    8003d6 <vprintfmt+0x70>
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800432:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800439:	eb 9b                	jmp    8003d6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	79 95                	jns    8003d6 <vprintfmt+0x70>
  800441:	eb 8b                	jmp    8003ce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800443:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800447:	eb 8d                	jmp    8003d6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800461:	e9 23 ff ff ff       	jmp    800389 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	79 02                	jns    800477 <vprintfmt+0x111>
  800475:	f7 d8                	neg    %eax
  800477:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 0f             	cmp    $0xf,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x123>
  80047e:	8b 04 85 40 27 80 00 	mov    0x802740(,%eax,4),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	75 23                	jne    8004ac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  800494:	00 
  800495:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 9a fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a7:	e9 dd fe ff ff       	jmp    800389 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b0:	c7 44 24 08 9a 29 80 	movl   $0x80299a,0x8(%esp)
  8004b7:	00 
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	89 14 24             	mov    %edx,(%esp)
  8004c2:	e8 77 fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ca:	e9 ba fe ff ff       	jmp    800389 <vprintfmt+0x23>
  8004cf:	89 f9                	mov    %edi,%ecx
  8004d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 30                	mov    (%eax),%esi
  8004e2:	85 f6                	test   %esi,%esi
  8004e4:	75 05                	jne    8004eb <vprintfmt+0x185>
				p = "(null)";
  8004e6:	be b1 24 80 00       	mov    $0x8024b1,%esi
			if (width > 0 && padc != '-')
  8004eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ef:	0f 8e 84 00 00 00    	jle    800579 <vprintfmt+0x213>
  8004f5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f9:	74 7e                	je     800579 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ff:	89 34 24             	mov    %esi,(%esp)
  800502:	e8 ab 02 00 00       	call   8007b2 <strnlen>
  800507:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800513:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800516:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800519:	89 de                	mov    %ebx,%esi
  80051b:	89 d3                	mov    %edx,%ebx
  80051d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0b                	jmp    80052c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800521:	89 74 24 04          	mov    %esi,0x4(%esp)
  800525:	89 3c 24             	mov    %edi,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	4b                   	dec    %ebx
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f f1                	jg     800521 <vprintfmt+0x1bb>
  800530:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800533:	89 f3                	mov    %esi,%ebx
  800535:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053b:	85 c0                	test   %eax,%eax
  80053d:	79 05                	jns    800544 <vprintfmt+0x1de>
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800547:	29 c2                	sub    %eax,%edx
  800549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054c:	eb 2b                	jmp    800579 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800552:	74 18                	je     80056c <vprintfmt+0x206>
  800554:	8d 50 e0             	lea    -0x20(%eax),%edx
  800557:	83 fa 5e             	cmp    $0x5e,%edx
  80055a:	76 10                	jbe    80056c <vprintfmt+0x206>
					putch('?', putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
  80056a:	eb 0a                	jmp    800576 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	ff 4d e4             	decl   -0x1c(%ebp)
  800579:	0f be 06             	movsbl (%esi),%eax
  80057c:	46                   	inc    %esi
  80057d:	85 c0                	test   %eax,%eax
  80057f:	74 21                	je     8005a2 <vprintfmt+0x23c>
  800581:	85 ff                	test   %edi,%edi
  800583:	78 c9                	js     80054e <vprintfmt+0x1e8>
  800585:	4f                   	dec    %edi
  800586:	79 c6                	jns    80054e <vprintfmt+0x1e8>
  800588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058b:	89 de                	mov    %ebx,%esi
  80058d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	89 74 24 04          	mov    %esi,0x4(%esp)
  800596:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	4b                   	dec    %ebx
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x244>
  8005a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a5:	89 de                	mov    %ebx,%esi
  8005a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005aa:	85 db                	test   %ebx,%ebx
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x22c>
  8005ae:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ce fd ff ff       	jmp    800389 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 f9 01             	cmp    $0x1,%ecx
  8005be:	7e 10                	jle    8005d0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	8b 78 04             	mov    0x4(%eax),%edi
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x290>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 12                	je     8005e6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 30                	mov    (%eax),%esi
  8005df:	89 f7                	mov    %esi,%edi
  8005e1:	c1 ff 1f             	sar    $0x1f,%edi
  8005e4:	eb 10                	jmp    8005f6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 30                	mov    (%eax),%esi
  8005f1:	89 f7                	mov    %esi,%edi
  8005f3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	78 0a                	js     800604 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ff:	e9 ac 00 00 00       	jmp    8006b0 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800612:	f7 de                	neg    %esi
  800614:	83 d7 00             	adc    $0x0,%edi
  800617:	f7 df                	neg    %edi
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 8d 00 00 00       	jmp    8006b0 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800623:	89 ca                	mov    %ecx,%edx
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 bd fc ff ff       	call   8002ea <getuint>
  80062d:	89 c6                	mov    %eax,%esi
  80062f:	89 d7                	mov    %edx,%edi
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800636:	eb 78                	jmp    8006b0 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800646:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800651:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800665:	e9 1f fd ff ff       	jmp    800389 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800675:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068f:	8b 30                	mov    (%eax),%esi
  800691:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069b:	eb 13                	jmp    8006b0 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069d:	89 ca                	mov    %ecx,%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 43 fc ff ff       	call   8002ea <getuint>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006b4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c3:	89 34 24             	mov    %esi,(%esp)
  8006c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ca:	89 da                	mov    %ebx,%edx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	e8 4c fb ff ff       	call   800220 <printnum>
			break;
  8006d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d7:	e9 ad fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e9:	e9 9b fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	eb 01                	jmp    8006ff <vprintfmt+0x399>
  8006fe:	4e                   	dec    %esi
  8006ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800703:	75 f9                	jne    8006fe <vprintfmt+0x398>
  800705:	e9 7f fc ff ff       	jmp    800389 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80070a:	83 c4 4c             	add    $0x4c,%esp
  80070d:	5b                   	pop    %ebx
  80070e:	5e                   	pop    %esi
  80070f:	5f                   	pop    %edi
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 28             	sub    $0x28,%esp
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800721:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800725:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 30                	je     800763 <vsnprintf+0x51>
  800733:	85 d2                	test   %edx,%edx
  800735:	7e 33                	jle    80076a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073e:	8b 45 10             	mov    0x10(%ebp),%eax
  800741:	89 44 24 08          	mov    %eax,0x8(%esp)
  800745:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  800753:	e8 0e fc ff ff       	call   800366 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	eb 0c                	jmp    80076f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800768:	eb 05                	jmp    80076f <vsnprintf+0x5d>
  80076a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8b 45 0c             	mov    0xc(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	89 04 24             	mov    %eax,(%esp)
  800792:	e8 7b ff ff ff       	call   800712 <vsnprintf>
	va_end(ap);

	return rc;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    
  800799:	00 00                	add    %al,(%eax)
	...

0080079c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a7:	eb 01                	jmp    8007aa <strlen+0xe>
		n++;
  8007a9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f9                	jne    8007a9 <strlen+0xd>
		n++;
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	eb 01                	jmp    8007c3 <strnlen+0x11>
		n++;
  8007c2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c3:	39 d0                	cmp    %edx,%eax
  8007c5:	74 06                	je     8007cd <strnlen+0x1b>
  8007c7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cb:	75 f5                	jne    8007c2 <strnlen+0x10>
		n++;
	return n;
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007e1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e4:	42                   	inc    %edx
  8007e5:	84 c9                	test   %cl,%cl
  8007e7:	75 f5                	jne    8007de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f6:	89 1c 24             	mov    %ebx,(%esp)
  8007f9:	e8 9e ff ff ff       	call   80079c <strlen>
	strcpy(dst + len, src);
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	89 54 24 04          	mov    %edx,0x4(%esp)
  800805:	01 d8                	add    %ebx,%eax
  800807:	89 04 24             	mov    %eax,(%esp)
  80080a:	e8 c0 ff ff ff       	call   8007cf <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	83 c4 08             	add    $0x8,%esp
  800814:	5b                   	pop    %ebx
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082a:	eb 0c                	jmp    800838 <strncpy+0x21>
		*dst++ = *src;
  80082c:	8a 1a                	mov    (%edx),%bl
  80082e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800831:	80 3a 01             	cmpb   $0x1,(%edx)
  800834:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800837:	41                   	inc    %ecx
  800838:	39 f1                	cmp    %esi,%ecx
  80083a:	75 f0                	jne    80082c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 75 08             	mov    0x8(%ebp),%esi
  800848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084e:	85 d2                	test   %edx,%edx
  800850:	75 0a                	jne    80085c <strlcpy+0x1c>
  800852:	89 f0                	mov    %esi,%eax
  800854:	eb 1a                	jmp    800870 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800856:	88 18                	mov    %bl,(%eax)
  800858:	40                   	inc    %eax
  800859:	41                   	inc    %ecx
  80085a:	eb 02                	jmp    80085e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80085e:	4a                   	dec    %edx
  80085f:	74 0a                	je     80086b <strlcpy+0x2b>
  800861:	8a 19                	mov    (%ecx),%bl
  800863:	84 db                	test   %bl,%bl
  800865:	75 ef                	jne    800856 <strlcpy+0x16>
  800867:	89 c2                	mov    %eax,%edx
  800869:	eb 02                	jmp    80086d <strlcpy+0x2d>
  80086b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80086d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800870:	29 f0                	sub    %esi,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087f:	eb 02                	jmp    800883 <strcmp+0xd>
		p++, q++;
  800881:	41                   	inc    %ecx
  800882:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800883:	8a 01                	mov    (%ecx),%al
  800885:	84 c0                	test   %al,%al
  800887:	74 04                	je     80088d <strcmp+0x17>
  800889:	3a 02                	cmp    (%edx),%al
  80088b:	74 f4                	je     800881 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 c0             	movzbl %al,%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008a4:	eb 03                	jmp    8008a9 <strncmp+0x12>
		n--, p++, q++;
  8008a6:	4a                   	dec    %edx
  8008a7:	40                   	inc    %eax
  8008a8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	74 14                	je     8008c1 <strncmp+0x2a>
  8008ad:	8a 18                	mov    (%eax),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	74 04                	je     8008b7 <strncmp+0x20>
  8008b3:	3a 19                	cmp    (%ecx),%bl
  8008b5:	74 ef                	je     8008a6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 00             	movzbl (%eax),%eax
  8008ba:	0f b6 11             	movzbl (%ecx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
  8008bf:	eb 05                	jmp    8008c6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d2:	eb 05                	jmp    8008d9 <strchr+0x10>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 0c                	je     8008e4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d8:	40                   	inc    %eax
  8008d9:	8a 10                	mov    (%eax),%dl
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	75 f5                	jne    8008d4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ef:	eb 05                	jmp    8008f6 <strfind+0x10>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 07                	je     8008fc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f5:	40                   	inc    %eax
  8008f6:	8a 10                	mov    (%eax),%dl
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f5                	jne    8008f1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090d:	85 c9                	test   %ecx,%ecx
  80090f:	74 30                	je     800941 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800911:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800917:	75 25                	jne    80093e <memset+0x40>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 20                	jne    80093e <memset+0x40>
		c &= 0xFF;
  80091e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800921:	89 d3                	mov    %edx,%ebx
  800923:	c1 e3 08             	shl    $0x8,%ebx
  800926:	89 d6                	mov    %edx,%esi
  800928:	c1 e6 18             	shl    $0x18,%esi
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	c1 e0 10             	shl    $0x10,%eax
  800930:	09 f0                	or     %esi,%eax
  800932:	09 d0                	or     %edx,%eax
  800934:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800936:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 03                	jmp    800941 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 34                	jae    80098e <memmove+0x46>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2d                	jae    80098e <memmove+0x46>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	f6 c2 03             	test   $0x3,%dl
  800967:	75 1b                	jne    800984 <memmove+0x3c>
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 13                	jne    800984 <memmove+0x3c>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 0e                	jne    800984 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800976:	83 ef 04             	sub    $0x4,%edi
  800979:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097f:	fd                   	std    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 07                	jmp    80098b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800984:	4f                   	dec    %edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 20                	jmp    8009ae <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	75 13                	jne    8009a9 <memmove+0x61>
  800996:	a8 03                	test   $0x3,%al
  800998:	75 0f                	jne    8009a9 <memmove+0x61>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0a                	jne    8009a9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 05                	jmp    8009ae <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	89 04 24             	mov    %eax,(%esp)
  8009cc:	e8 77 ff ff ff       	call   800948 <memmove>
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	eb 16                	jmp    8009ff <memcmp+0x2c>
		if (*s1 != *s2)
  8009e9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009ec:	42                   	inc    %edx
  8009ed:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009f1:	38 c8                	cmp    %cl,%al
  8009f3:	74 0a                	je     8009ff <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009f5:	0f b6 c0             	movzbl %al,%eax
  8009f8:	0f b6 c9             	movzbl %cl,%ecx
  8009fb:	29 c8                	sub    %ecx,%eax
  8009fd:	eb 09                	jmp    800a08 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	39 da                	cmp    %ebx,%edx
  800a01:	75 e6                	jne    8009e9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a16:	89 c2                	mov    %eax,%edx
  800a18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1b:	eb 05                	jmp    800a22 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	38 08                	cmp    %cl,(%eax)
  800a1f:	74 05                	je     800a26 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a21:	40                   	inc    %eax
  800a22:	39 d0                	cmp    %edx,%eax
  800a24:	72 f7                	jb     800a1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	eb 01                	jmp    800a37 <strtol+0xf>
		s++;
  800a36:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a37:	8a 02                	mov    (%edx),%al
  800a39:	3c 20                	cmp    $0x20,%al
  800a3b:	74 f9                	je     800a36 <strtol+0xe>
  800a3d:	3c 09                	cmp    $0x9,%al
  800a3f:	74 f5                	je     800a36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a41:	3c 2b                	cmp    $0x2b,%al
  800a43:	75 08                	jne    800a4d <strtol+0x25>
		s++;
  800a45:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4b:	eb 13                	jmp    800a60 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	75 0a                	jne    800a5b <strtol+0x33>
		s++, neg = 1;
  800a51:	8d 52 01             	lea    0x1(%edx),%edx
  800a54:	bf 01 00 00 00       	mov    $0x1,%edi
  800a59:	eb 05                	jmp    800a60 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	74 05                	je     800a69 <strtol+0x41>
  800a64:	83 fb 10             	cmp    $0x10,%ebx
  800a67:	75 28                	jne    800a91 <strtol+0x69>
  800a69:	8a 02                	mov    (%edx),%al
  800a6b:	3c 30                	cmp    $0x30,%al
  800a6d:	75 10                	jne    800a7f <strtol+0x57>
  800a6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a73:	75 0a                	jne    800a7f <strtol+0x57>
		s += 2, base = 16;
  800a75:	83 c2 02             	add    $0x2,%edx
  800a78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7d:	eb 12                	jmp    800a91 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a7f:	85 db                	test   %ebx,%ebx
  800a81:	75 0e                	jne    800a91 <strtol+0x69>
  800a83:	3c 30                	cmp    $0x30,%al
  800a85:	75 05                	jne    800a8c <strtol+0x64>
		s++, base = 8;
  800a87:	42                   	inc    %edx
  800a88:	b3 08                	mov    $0x8,%bl
  800a8a:	eb 05                	jmp    800a91 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a98:	8a 0a                	mov    (%edx),%cl
  800a9a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x82>
			dig = *s - '0';
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 30             	sub    $0x30,%ecx
  800aa8:	eb 1e                	jmp    800ac8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aad:	80 fb 19             	cmp    $0x19,%bl
  800ab0:	77 08                	ja     800aba <strtol+0x92>
			dig = *s - 'a' + 10;
  800ab2:	0f be c9             	movsbl %cl,%ecx
  800ab5:	83 e9 57             	sub    $0x57,%ecx
  800ab8:	eb 0e                	jmp    800ac8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aba:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800abd:	80 fb 19             	cmp    $0x19,%bl
  800ac0:	77 12                	ja     800ad4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac8:	39 f1                	cmp    %esi,%ecx
  800aca:	7d 0c                	jge    800ad8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800acc:	42                   	inc    %edx
  800acd:	0f af c6             	imul   %esi,%eax
  800ad0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ad2:	eb c4                	jmp    800a98 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ad4:	89 c1                	mov    %eax,%ecx
  800ad6:	eb 02                	jmp    800ada <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ada:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ade:	74 05                	je     800ae5 <strtol+0xbd>
		*endptr = (char *) s;
  800ae0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	74 04                	je     800aed <strtol+0xc5>
  800ae9:	89 c8                	mov    %ecx,%eax
  800aeb:	f7 d8                	neg    %eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    
	...

00800af4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	89 c3                	mov    %eax,%ebx
  800b07:	89 c7                	mov    %eax,%edi
  800b09:	89 c6                	mov    %eax,%esi
  800b0b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 cb                	mov    %ecx,%ebx
  800b49:	89 cf                	mov    %ecx,%edi
  800b4b:	89 ce                	mov    %ecx,%esi
  800b4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	7e 28                	jle    800b7b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b57:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b5e:	00 
  800b5f:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800b66:	00 
  800b67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b6e:	00 
  800b6f:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800b76:	e8 31 14 00 00       	call   801fac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7b:	83 c4 2c             	add    $0x2c,%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_yield>:

void
sys_yield(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	be 00 00 00 00       	mov    $0x0,%esi
  800bcf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 f7                	mov    %esi,%edi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 28                	jle    800c0d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bf0:	00 
  800bf1:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800bf8:	00 
  800bf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c00:	00 
  800c01:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800c08:	e8 9f 13 00 00       	call   801fac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0d:	83 c4 2c             	add    $0x2c,%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c23:	8b 75 18             	mov    0x18(%ebp),%esi
  800c26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 28                	jle    800c60 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c43:	00 
  800c44:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800c4b:	00 
  800c4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c53:	00 
  800c54:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800c5b:	e8 4c 13 00 00       	call   801fac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c60:	83 c4 2c             	add    $0x2c,%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 df                	mov    %ebx,%edi
  800c83:	89 de                	mov    %ebx,%esi
  800c85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 28                	jle    800cb3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c96:	00 
  800c97:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca6:	00 
  800ca7:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800cae:	e8 f9 12 00 00       	call   801fac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb3:	83 c4 2c             	add    $0x2c,%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 28                	jle    800d06 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ce9:	00 
  800cea:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800cf1:	00 
  800cf2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf9:	00 
  800cfa:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800d01:	e8 a6 12 00 00       	call   801fac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d06:	83 c4 2c             	add    $0x2c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 28                	jle    800d59 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d35:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d3c:	00 
  800d3d:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800d44:	00 
  800d45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4c:	00 
  800d4d:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800d54:	e8 53 12 00 00       	call   801fac <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d59:	83 c4 2c             	add    $0x2c,%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	89 df                	mov    %ebx,%edi
  800d7c:	89 de                	mov    %ebx,%esi
  800d7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7e 28                	jle    800dac <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d88:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d8f:	00 
  800d90:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800d97:	00 
  800d98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9f:	00 
  800da0:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800da7:	e8 00 12 00 00       	call   801fac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dac:	83 c4 2c             	add    $0x2c,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	be 00 00 00 00       	mov    $0x0,%esi
  800dbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	89 cb                	mov    %ecx,%ebx
  800def:	89 cf                	mov    %ecx,%edi
  800df1:	89 ce                	mov    %ecx,%esi
  800df3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7e 28                	jle    800e21 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e04:	00 
  800e05:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800e0c:	00 
  800e0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e14:	00 
  800e15:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800e1c:	e8 8b 11 00 00       	call   801fac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e21:	83 c4 2c             	add    $0x2c,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
  800e29:	00 00                	add    %al,(%eax)
	...

00800e2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 24             	sub    $0x24,%esp
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e36:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800e38:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e3c:	75 20                	jne    800e5e <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e3e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e42:	c7 44 24 08 cc 27 80 	movl   $0x8027cc,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  800e59:	e8 4e 11 00 00       	call   801fac <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e64:	89 d8                	mov    %ebx,%eax
  800e66:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e70:	f6 c4 08             	test   $0x8,%ah
  800e73:	75 1c                	jne    800e91 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e75:	c7 44 24 08 fc 27 80 	movl   $0x8027fc,0x8(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e84:	00 
  800e85:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  800e8c:	e8 1b 11 00 00       	call   801fac <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800e91:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e98:	00 
  800e99:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ea0:	00 
  800ea1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea8:	e8 14 fd ff ff       	call   800bc1 <sys_page_alloc>
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	79 20                	jns    800ed1 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800eb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eb5:	c7 44 24 08 56 28 80 	movl   $0x802856,0x8(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ec4:	00 
  800ec5:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  800ecc:	e8 db 10 00 00       	call   801fac <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800ed1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ed8:	00 
  800ed9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800edd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ee4:	e8 5f fa ff ff       	call   800948 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800ee9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ef0:	00 
  800ef1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ef5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0c:	e8 04 fd ff ff       	call   800c15 <sys_page_map>
  800f11:	85 c0                	test   %eax,%eax
  800f13:	79 20                	jns    800f35 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800f15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f19:	c7 44 24 08 69 28 80 	movl   $0x802869,0x8(%esp)
  800f20:	00 
  800f21:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f28:	00 
  800f29:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  800f30:	e8 77 10 00 00       	call   801fac <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800f35:	83 c4 24             	add    $0x24,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800f44:	c7 04 24 2c 0e 80 00 	movl   $0x800e2c,(%esp)
  800f4b:	e8 b4 10 00 00       	call   802004 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f50:	ba 07 00 00 00       	mov    $0x7,%edx
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	cd 30                	int    $0x30
  800f59:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 20                	jns    800f83 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f67:	c7 44 24 08 7a 28 80 	movl   $0x80287a,0x8(%esp)
  800f6e:	00 
  800f6f:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f76:	00 
  800f77:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  800f7e:	e8 29 10 00 00       	call   801fac <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f83:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f87:	75 25                	jne    800fae <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f89:	e8 f5 fb ff ff       	call   800b83 <sys_getenvid>
  800f8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f9a:	c1 e0 07             	shl    $0x7,%eax
  800f9d:	29 d0                	sub    %edx,%eax
  800f9f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fa9:	e9 58 02 00 00       	jmp    801206 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800fae:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb3:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fb8:	89 f0                	mov    %esi,%eax
  800fba:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fbd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc4:	a8 01                	test   $0x1,%al
  800fc6:	0f 84 7a 01 00 00    	je     801146 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800fcc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fd3:	a8 01                	test   $0x1,%al
  800fd5:	0f 84 6b 01 00 00    	je     801146 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800fdb:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe0:	8b 40 48             	mov    0x48(%eax),%eax
  800fe3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800fe6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fed:	f6 c4 04             	test   $0x4,%ah
  800ff0:	74 52                	je     801044 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800ff2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff9:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801002:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801006:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801009:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801014:	89 04 24             	mov    %eax,(%esp)
  801017:	e8 f9 fb ff ff       	call   800c15 <sys_page_map>
  80101c:	85 c0                	test   %eax,%eax
  80101e:	0f 89 22 01 00 00    	jns    801146 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801024:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801028:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  80103f:	e8 68 0f 00 00       	call   801fac <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801044:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104b:	f6 c4 08             	test   $0x8,%ah
  80104e:	75 0f                	jne    80105f <fork+0x124>
  801050:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801057:	a8 02                	test   $0x2,%al
  801059:	0f 84 99 00 00 00    	je     8010f8 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80105f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801066:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801069:	83 f8 01             	cmp    $0x1,%eax
  80106c:	19 db                	sbb    %ebx,%ebx
  80106e:	83 e3 fc             	and    $0xfffffffc,%ebx
  801071:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801077:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801082:	89 44 24 08          	mov    %eax,0x8(%esp)
  801086:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80108a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108d:	89 04 24             	mov    %eax,(%esp)
  801090:	e8 80 fb ff ff       	call   800c15 <sys_page_map>
  801095:	85 c0                	test   %eax,%eax
  801097:	79 20                	jns    8010b9 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109d:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  8010b4:	e8 f3 0e 00 00       	call   801fac <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010b9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 41 fb ff ff       	call   800c15 <sys_page_map>
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	79 6e                	jns    801146 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010dc:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  8010f3:	e8 b4 0e 00 00       	call   801fac <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010f8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801104:	89 44 24 10          	mov    %eax,0x10(%esp)
  801108:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80110c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80110f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801113:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111a:	89 04 24             	mov    %eax,(%esp)
  80111d:	e8 f3 fa ff ff       	call   800c15 <sys_page_map>
  801122:	85 c0                	test   %eax,%eax
  801124:	79 20                	jns    801146 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112a:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  801131:	00 
  801132:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801139:	00 
  80113a:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  801141:	e8 66 0e 00 00       	call   801fac <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801146:	46                   	inc    %esi
  801147:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80114d:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801153:	0f 85 5f fe ff ff    	jne    800fb8 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801159:	c7 44 24 04 a4 20 80 	movl   $0x8020a4,0x4(%esp)
  801160:	00 
  801161:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801164:	89 04 24             	mov    %eax,(%esp)
  801167:	e8 f5 fb ff ff       	call   800d61 <sys_env_set_pgfault_upcall>
  80116c:	85 c0                	test   %eax,%eax
  80116e:	79 20                	jns    801190 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801170:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801174:	c7 44 24 08 2c 28 80 	movl   $0x80282c,0x8(%esp)
  80117b:	00 
  80117c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801183:	00 
  801184:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  80118b:	e8 1c 0e 00 00       	call   801fac <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801190:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80119f:	ee 
  8011a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a3:	89 04 24             	mov    %eax,(%esp)
  8011a6:	e8 16 fa ff ff       	call   800bc1 <sys_page_alloc>
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 20                	jns    8011cf <fork+0x294>
		panic("sys_page_alloc: %e", r);
  8011af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b3:	c7 44 24 08 56 28 80 	movl   $0x802856,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  8011ca:	e8 dd 0d 00 00       	call   801fac <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011cf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011d6:	00 
  8011d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011da:	89 04 24             	mov    %eax,(%esp)
  8011dd:	e8 d9 fa ff ff       	call   800cbb <sys_env_set_status>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	79 20                	jns    801206 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  8011e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ea:	c7 44 24 08 9c 28 80 	movl   $0x80289c,0x8(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  801201:	e8 a6 0d 00 00       	call   801fac <_panic>
	}
	
	return envid;
}
  801206:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801209:	83 c4 3c             	add    $0x3c,%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sfork>:

// Challenge!
int
sfork(void)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801217:	c7 44 24 08 b3 28 80 	movl   $0x8028b3,0x8(%esp)
  80121e:	00 
  80121f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801226:	00 
  801227:	c7 04 24 4b 28 80 00 	movl   $0x80284b,(%esp)
  80122e:	e8 79 0d 00 00       	call   801fac <_panic>
	...

00801234 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
  80123a:	05 00 00 00 30       	add    $0x30000000,%eax
  80123f:	c1 e8 0c             	shr    $0xc,%eax
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80124a:	8b 45 08             	mov    0x8(%ebp),%eax
  80124d:	89 04 24             	mov    %eax,(%esp)
  801250:	e8 df ff ff ff       	call   801234 <fd2num>
  801255:	05 20 00 0d 00       	add    $0xd0020,%eax
  80125a:	c1 e0 0c             	shl    $0xc,%eax
}
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	53                   	push   %ebx
  801263:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801266:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80126b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	c1 ea 16             	shr    $0x16,%edx
  801272:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	74 11                	je     80128f <fd_alloc+0x30>
  80127e:	89 c2                	mov    %eax,%edx
  801280:	c1 ea 0c             	shr    $0xc,%edx
  801283:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128a:	f6 c2 01             	test   $0x1,%dl
  80128d:	75 09                	jne    801298 <fd_alloc+0x39>
			*fd_store = fd;
  80128f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 17                	jmp    8012af <fd_alloc+0x50>
  801298:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a2:	75 c7                	jne    80126b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012af:	5b                   	pop    %ebx
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b8:	83 f8 1f             	cmp    $0x1f,%eax
  8012bb:	77 36                	ja     8012f3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012bd:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012c2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	c1 ea 16             	shr    $0x16,%edx
  8012ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d1:	f6 c2 01             	test   $0x1,%dl
  8012d4:	74 24                	je     8012fa <fd_lookup+0x48>
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	c1 ea 0c             	shr    $0xc,%edx
  8012db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e2:	f6 c2 01             	test   $0x1,%dl
  8012e5:	74 1a                	je     801301 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	eb 13                	jmp    801306 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb 0c                	jmp    801306 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ff:	eb 05                	jmp    801306 <fd_lookup+0x54>
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 14             	sub    $0x14,%esp
  80130f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801312:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	eb 0e                	jmp    80132a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80131c:	39 08                	cmp    %ecx,(%eax)
  80131e:	75 09                	jne    801329 <dev_lookup+0x21>
			*dev = devtab[i];
  801320:	89 03                	mov    %eax,(%ebx)
			return 0;
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	eb 33                	jmp    80135c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801329:	42                   	inc    %edx
  80132a:	8b 04 95 48 29 80 00 	mov    0x802948(,%edx,4),%eax
  801331:	85 c0                	test   %eax,%eax
  801333:	75 e7                	jne    80131c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801335:	a1 04 40 80 00       	mov    0x804004,%eax
  80133a:	8b 40 48             	mov    0x48(%eax),%eax
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	c7 04 24 cc 28 80 00 	movl   $0x8028cc,(%esp)
  80134c:	e8 b3 ee ff ff       	call   800204 <cprintf>
	*dev = 0;
  801351:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801357:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135c:	83 c4 14             	add    $0x14,%esp
  80135f:	5b                   	pop    %ebx
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 30             	sub    $0x30,%esp
  80136a:	8b 75 08             	mov    0x8(%ebp),%esi
  80136d:	8a 45 0c             	mov    0xc(%ebp),%al
  801370:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801373:	89 34 24             	mov    %esi,(%esp)
  801376:	e8 b9 fe ff ff       	call   801234 <fd2num>
  80137b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80137e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	e8 28 ff ff ff       	call   8012b2 <fd_lookup>
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 05                	js     801395 <fd_close+0x33>
	    || fd != fd2)
  801390:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801393:	74 0d                	je     8013a2 <fd_close+0x40>
		return (must_exist ? r : 0);
  801395:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801399:	75 46                	jne    8013e1 <fd_close+0x7f>
  80139b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a0:	eb 3f                	jmp    8013e1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	8b 06                	mov    (%esi),%eax
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	e8 55 ff ff ff       	call   801308 <dev_lookup>
  8013b3:	89 c3                	mov    %eax,%ebx
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 18                	js     8013d1 <fd_close+0x6f>
		if (dev->dev_close)
  8013b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bc:	8b 40 10             	mov    0x10(%eax),%eax
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	74 09                	je     8013cc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013c3:	89 34 24             	mov    %esi,(%esp)
  8013c6:	ff d0                	call   *%eax
  8013c8:	89 c3                	mov    %eax,%ebx
  8013ca:	eb 05                	jmp    8013d1 <fd_close+0x6f>
		else
			r = 0;
  8013cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013dc:	e8 87 f8 ff ff       	call   800c68 <sys_page_unmap>
	return r;
}
  8013e1:	89 d8                	mov    %ebx,%eax
  8013e3:	83 c4 30             	add    $0x30,%esp
  8013e6:	5b                   	pop    %ebx
  8013e7:	5e                   	pop    %esi
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	89 04 24             	mov    %eax,(%esp)
  8013fd:	e8 b0 fe ff ff       	call   8012b2 <fd_lookup>
  801402:	85 c0                	test   %eax,%eax
  801404:	78 13                	js     801419 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801406:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80140d:	00 
  80140e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 49 ff ff ff       	call   801362 <fd_close>
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <close_all>:

void
close_all(void)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	53                   	push   %ebx
  80141f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801422:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801427:	89 1c 24             	mov    %ebx,(%esp)
  80142a:	e8 bb ff ff ff       	call   8013ea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80142f:	43                   	inc    %ebx
  801430:	83 fb 20             	cmp    $0x20,%ebx
  801433:	75 f2                	jne    801427 <close_all+0xc>
		close(i);
}
  801435:	83 c4 14             	add    $0x14,%esp
  801438:	5b                   	pop    %ebx
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	57                   	push   %edi
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	83 ec 4c             	sub    $0x4c,%esp
  801444:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801447:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	89 04 24             	mov    %eax,(%esp)
  801454:	e8 59 fe ff ff       	call   8012b2 <fd_lookup>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	85 c0                	test   %eax,%eax
  80145d:	0f 88 e1 00 00 00    	js     801544 <dup+0x109>
		return r;
	close(newfdnum);
  801463:	89 3c 24             	mov    %edi,(%esp)
  801466:	e8 7f ff ff ff       	call   8013ea <close>

	newfd = INDEX2FD(newfdnum);
  80146b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801471:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801477:	89 04 24             	mov    %eax,(%esp)
  80147a:	e8 c5 fd ff ff       	call   801244 <fd2data>
  80147f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801481:	89 34 24             	mov    %esi,(%esp)
  801484:	e8 bb fd ff ff       	call   801244 <fd2data>
  801489:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	c1 e8 16             	shr    $0x16,%eax
  801491:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801498:	a8 01                	test   $0x1,%al
  80149a:	74 46                	je     8014e2 <dup+0xa7>
  80149c:	89 d8                	mov    %ebx,%eax
  80149e:	c1 e8 0c             	shr    $0xc,%eax
  8014a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a8:	f6 c2 01             	test   $0x1,%dl
  8014ab:	74 35                	je     8014e2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014cb:	00 
  8014cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d7:	e8 39 f7 ff ff       	call   800c15 <sys_page_map>
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 3b                	js     80151d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	c1 ea 0c             	shr    $0xc,%edx
  8014ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801506:	00 
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801512:	e8 fe f6 ff ff       	call   800c15 <sys_page_map>
  801517:	89 c3                	mov    %eax,%ebx
  801519:	85 c0                	test   %eax,%eax
  80151b:	79 25                	jns    801542 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80151d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801528:	e8 3b f7 ff ff       	call   800c68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153b:	e8 28 f7 ff ff       	call   800c68 <sys_page_unmap>
	return r;
  801540:	eb 02                	jmp    801544 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801542:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801544:	89 d8                	mov    %ebx,%eax
  801546:	83 c4 4c             	add    $0x4c,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	53                   	push   %ebx
  801552:	83 ec 24             	sub    $0x24,%esp
  801555:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801558:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155f:	89 1c 24             	mov    %ebx,(%esp)
  801562:	e8 4b fd ff ff       	call   8012b2 <fd_lookup>
  801567:	85 c0                	test   %eax,%eax
  801569:	78 6d                	js     8015d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	8b 00                	mov    (%eax),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 89 fd ff ff       	call   801308 <dev_lookup>
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 55                	js     8015d8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	8b 50 08             	mov    0x8(%eax),%edx
  801589:	83 e2 03             	and    $0x3,%edx
  80158c:	83 fa 01             	cmp    $0x1,%edx
  80158f:	75 23                	jne    8015b4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801591:	a1 04 40 80 00       	mov    0x804004,%eax
  801596:	8b 40 48             	mov    0x48(%eax),%eax
  801599:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80159d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a1:	c7 04 24 0d 29 80 00 	movl   $0x80290d,(%esp)
  8015a8:	e8 57 ec ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  8015ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b2:	eb 24                	jmp    8015d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8015b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b7:	8b 52 08             	mov    0x8(%edx),%edx
  8015ba:	85 d2                	test   %edx,%edx
  8015bc:	74 15                	je     8015d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015cc:	89 04 24             	mov    %eax,(%esp)
  8015cf:	ff d2                	call   *%edx
  8015d1:	eb 05                	jmp    8015d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015d8:	83 c4 24             	add    $0x24,%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	57                   	push   %edi
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 1c             	sub    $0x1c,%esp
  8015e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f2:	eb 23                	jmp    801617 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f4:	89 f0                	mov    %esi,%eax
  8015f6:	29 d8                	sub    %ebx,%eax
  8015f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ff:	01 d8                	add    %ebx,%eax
  801601:	89 44 24 04          	mov    %eax,0x4(%esp)
  801605:	89 3c 24             	mov    %edi,(%esp)
  801608:	e8 41 ff ff ff       	call   80154e <read>
		if (m < 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 10                	js     801621 <readn+0x43>
			return m;
		if (m == 0)
  801611:	85 c0                	test   %eax,%eax
  801613:	74 0a                	je     80161f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801615:	01 c3                	add    %eax,%ebx
  801617:	39 f3                	cmp    %esi,%ebx
  801619:	72 d9                	jb     8015f4 <readn+0x16>
  80161b:	89 d8                	mov    %ebx,%eax
  80161d:	eb 02                	jmp    801621 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80161f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801621:	83 c4 1c             	add    $0x1c,%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5f                   	pop    %edi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 24             	sub    $0x24,%esp
  801630:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	89 1c 24             	mov    %ebx,(%esp)
  80163d:	e8 70 fc ff ff       	call   8012b2 <fd_lookup>
  801642:	85 c0                	test   %eax,%eax
  801644:	78 68                	js     8016ae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801650:	8b 00                	mov    (%eax),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 ae fc ff ff       	call   801308 <dev_lookup>
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 50                	js     8016ae <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801665:	75 23                	jne    80168a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801667:	a1 04 40 80 00       	mov    0x804004,%eax
  80166c:	8b 40 48             	mov    0x48(%eax),%eax
  80166f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	c7 04 24 29 29 80 00 	movl   $0x802929,(%esp)
  80167e:	e8 81 eb ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  801683:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801688:	eb 24                	jmp    8016ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 0c             	mov    0xc(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 15                	je     8016a9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801694:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801697:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80169b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016a2:	89 04 24             	mov    %eax,(%esp)
  8016a5:	ff d2                	call   *%edx
  8016a7:	eb 05                	jmp    8016ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016ae:	83 c4 24             	add    $0x24,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 e6 fb ff ff       	call   8012b2 <fd_lookup>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 0e                	js     8016de <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 24             	sub    $0x24,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	89 1c 24             	mov    %ebx,(%esp)
  8016f4:	e8 b9 fb ff ff       	call   8012b2 <fd_lookup>
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 61                	js     80175e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801700:	89 44 24 04          	mov    %eax,0x4(%esp)
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	8b 00                	mov    (%eax),%eax
  801709:	89 04 24             	mov    %eax,(%esp)
  80170c:	e8 f7 fb ff ff       	call   801308 <dev_lookup>
  801711:	85 c0                	test   %eax,%eax
  801713:	78 49                	js     80175e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801718:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171c:	75 23                	jne    801741 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80171e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801723:	8b 40 48             	mov    0x48(%eax),%eax
  801726:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80172a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172e:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  801735:	e8 ca ea ff ff       	call   800204 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173f:	eb 1d                	jmp    80175e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801741:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801744:	8b 52 18             	mov    0x18(%edx),%edx
  801747:	85 d2                	test   %edx,%edx
  801749:	74 0e                	je     801759 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	ff d2                	call   *%edx
  801757:	eb 05                	jmp    80175e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801759:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80175e:	83 c4 24             	add    $0x24,%esp
  801761:	5b                   	pop    %ebx
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	53                   	push   %ebx
  801768:	83 ec 24             	sub    $0x24,%esp
  80176b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801771:	89 44 24 04          	mov    %eax,0x4(%esp)
  801775:	8b 45 08             	mov    0x8(%ebp),%eax
  801778:	89 04 24             	mov    %eax,(%esp)
  80177b:	e8 32 fb ff ff       	call   8012b2 <fd_lookup>
  801780:	85 c0                	test   %eax,%eax
  801782:	78 52                	js     8017d6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801784:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	8b 00                	mov    (%eax),%eax
  801790:	89 04 24             	mov    %eax,(%esp)
  801793:	e8 70 fb ff ff       	call   801308 <dev_lookup>
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 3a                	js     8017d6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80179c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a3:	74 2c                	je     8017d1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017af:	00 00 00 
	stat->st_isdir = 0;
  8017b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b9:	00 00 00 
	stat->st_dev = dev;
  8017bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c9:	89 14 24             	mov    %edx,(%esp)
  8017cc:	ff 50 14             	call   *0x14(%eax)
  8017cf:	eb 05                	jmp    8017d6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d6:	83 c4 24             	add    $0x24,%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017eb:	00 
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 fe 01 00 00       	call   8019f5 <open>
  8017f7:	89 c3                	mov    %eax,%ebx
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 1b                	js     801818 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801800:	89 44 24 04          	mov    %eax,0x4(%esp)
  801804:	89 1c 24             	mov    %ebx,(%esp)
  801807:	e8 58 ff ff ff       	call   801764 <fstat>
  80180c:	89 c6                	mov    %eax,%esi
	close(fd);
  80180e:	89 1c 24             	mov    %ebx,(%esp)
  801811:	e8 d4 fb ff ff       	call   8013ea <close>
	return r;
  801816:	89 f3                	mov    %esi,%ebx
}
  801818:	89 d8                	mov    %ebx,%eax
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    
  801821:	00 00                	add    %al,(%eax)
	...

00801824 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	83 ec 10             	sub    $0x10,%esp
  80182c:	89 c3                	mov    %eax,%ebx
  80182e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801830:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801837:	75 11                	jne    80184a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801839:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801840:	e8 54 09 00 00       	call   802199 <ipc_find_env>
  801845:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801851:	00 
  801852:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801859:	00 
  80185a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185e:	a1 00 40 80 00       	mov    0x804000,%eax
  801863:	89 04 24             	mov    %eax,(%esp)
  801866:	e8 c4 08 00 00       	call   80212f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80186b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801872:	00 
  801873:	89 74 24 04          	mov    %esi,0x4(%esp)
  801877:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187e:	e8 45 08 00 00       	call   8020c8 <ipc_recv>
}
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	8b 40 0c             	mov    0xc(%eax),%eax
  801896:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80189b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ad:	e8 72 ff ff ff       	call   801824 <fsipc>
}
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8018cf:	e8 50 ff ff ff       	call   801824 <fsipc>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 14             	sub    $0x14,%esp
  8018dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f5:	e8 2a ff ff ff       	call   801824 <fsipc>
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 2b                	js     801929 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018fe:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801905:	00 
  801906:	89 1c 24             	mov    %ebx,(%esp)
  801909:	e8 c1 ee ff ff       	call   8007cf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190e:	a1 80 50 80 00       	mov    0x805080,%eax
  801913:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801919:	a1 84 50 80 00       	mov    0x805084,%eax
  80191e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801929:	83 c4 14             	add    $0x14,%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801935:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  80193c:	00 
  80193d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801944:	00 
  801945:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  80194c:	e8 5b 06 00 00       	call   801fac <_panic>

00801951 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	83 ec 10             	sub    $0x10,%esp
  801959:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 40 0c             	mov    0xc(%eax),%eax
  801962:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801967:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 03 00 00 00       	mov    $0x3,%eax
  801977:	e8 a8 fe ff ff       	call   801824 <fsipc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 6a                	js     8019ec <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801982:	39 c6                	cmp    %eax,%esi
  801984:	73 24                	jae    8019aa <devfile_read+0x59>
  801986:	c7 44 24 0c 81 29 80 	movl   $0x802981,0xc(%esp)
  80198d:	00 
  80198e:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  801995:	00 
  801996:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80199d:	00 
  80199e:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  8019a5:	e8 02 06 00 00       	call   801fac <_panic>
	assert(r <= PGSIZE);
  8019aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019af:	7e 24                	jle    8019d5 <devfile_read+0x84>
  8019b1:	c7 44 24 0c 9d 29 80 	movl   $0x80299d,0xc(%esp)
  8019b8:	00 
  8019b9:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  8019c0:	00 
  8019c1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019c8:	00 
  8019c9:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  8019d0:	e8 d7 05 00 00       	call   801fac <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019e0:	00 
  8019e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	e8 5c ef ff ff       	call   800948 <memmove>
	return r;
}
  8019ec:	89 d8                	mov    %ebx,%eax
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 20             	sub    $0x20,%esp
  8019fd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a00:	89 34 24             	mov    %esi,(%esp)
  801a03:	e8 94 ed ff ff       	call   80079c <strlen>
  801a08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a0d:	7f 60                	jg     801a6f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 45 f8 ff ff       	call   80125f <fd_alloc>
  801a1a:	89 c3                	mov    %eax,%ebx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 54                	js     801a74 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a20:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a24:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a2b:	e8 9f ed ff ff       	call   8007cf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a40:	e8 df fd ff ff       	call   801824 <fsipc>
  801a45:	89 c3                	mov    %eax,%ebx
  801a47:	85 c0                	test   %eax,%eax
  801a49:	79 15                	jns    801a60 <open+0x6b>
		fd_close(fd, 0);
  801a4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a52:	00 
  801a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 04 f9 ff ff       	call   801362 <fd_close>
		return r;
  801a5e:	eb 14                	jmp    801a74 <open+0x7f>
	}

	return fd2num(fd);
  801a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a63:	89 04 24             	mov    %eax,(%esp)
  801a66:	e8 c9 f7 ff ff       	call   801234 <fd2num>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	eb 05                	jmp    801a74 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a6f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a74:	89 d8                	mov    %ebx,%eax
  801a76:	83 c4 20             	add    $0x20,%esp
  801a79:	5b                   	pop    %ebx
  801a7a:	5e                   	pop    %esi
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	b8 08 00 00 00       	mov    $0x8,%eax
  801a8d:	e8 92 fd ff ff       	call   801824 <fsipc>
}
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 10             	sub    $0x10,%esp
  801a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 9a f7 ff ff       	call   801244 <fd2data>
  801aaa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801aac:	c7 44 24 04 a9 29 80 	movl   $0x8029a9,0x4(%esp)
  801ab3:	00 
  801ab4:	89 34 24             	mov    %esi,(%esp)
  801ab7:	e8 13 ed ff ff       	call   8007cf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801abc:	8b 43 04             	mov    0x4(%ebx),%eax
  801abf:	2b 03                	sub    (%ebx),%eax
  801ac1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ac7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ace:	00 00 00 
	stat->st_dev = &devpipe;
  801ad1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801ad8:	30 80 00 
	return 0;
}
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5e                   	pop    %esi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 14             	sub    $0x14,%esp
  801aee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801af5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afc:	e8 67 f1 ff ff       	call   800c68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b01:	89 1c 24             	mov    %ebx,(%esp)
  801b04:	e8 3b f7 ff ff       	call   801244 <fd2data>
  801b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b14:	e8 4f f1 ff ff       	call   800c68 <sys_page_unmap>
}
  801b19:	83 c4 14             	add    $0x14,%esp
  801b1c:	5b                   	pop    %ebx
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	57                   	push   %edi
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	83 ec 2c             	sub    $0x2c,%esp
  801b28:	89 c7                	mov    %eax,%edi
  801b2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b32:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b35:	89 3c 24             	mov    %edi,(%esp)
  801b38:	e8 a3 06 00 00       	call   8021e0 <pageref>
  801b3d:	89 c6                	mov    %eax,%esi
  801b3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 96 06 00 00       	call   8021e0 <pageref>
  801b4a:	39 c6                	cmp    %eax,%esi
  801b4c:	0f 94 c0             	sete   %al
  801b4f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b52:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b58:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b5b:	39 cb                	cmp    %ecx,%ebx
  801b5d:	75 08                	jne    801b67 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b5f:	83 c4 2c             	add    $0x2c,%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b67:	83 f8 01             	cmp    $0x1,%eax
  801b6a:	75 c1                	jne    801b2d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b6c:	8b 42 58             	mov    0x58(%edx),%eax
  801b6f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801b76:	00 
  801b77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b7f:	c7 04 24 b0 29 80 00 	movl   $0x8029b0,(%esp)
  801b86:	e8 79 e6 ff ff       	call   800204 <cprintf>
  801b8b:	eb a0                	jmp    801b2d <_pipeisclosed+0xe>

00801b8d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	57                   	push   %edi
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	83 ec 1c             	sub    $0x1c,%esp
  801b96:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b99:	89 34 24             	mov    %esi,(%esp)
  801b9c:	e8 a3 f6 ff ff       	call   801244 <fd2data>
  801ba1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba8:	eb 3c                	jmp    801be6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801baa:	89 da                	mov    %ebx,%edx
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	e8 6c ff ff ff       	call   801b1f <_pipeisclosed>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	75 38                	jne    801bef <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bb7:	e8 e6 ef ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bbc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bbf:	8b 13                	mov    (%ebx),%edx
  801bc1:	83 c2 20             	add    $0x20,%edx
  801bc4:	39 d0                	cmp    %edx,%eax
  801bc6:	73 e2                	jae    801baa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801bce:	89 c2                	mov    %eax,%edx
  801bd0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801bd6:	79 05                	jns    801bdd <devpipe_write+0x50>
  801bd8:	4a                   	dec    %edx
  801bd9:	83 ca e0             	or     $0xffffffe0,%edx
  801bdc:	42                   	inc    %edx
  801bdd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be1:	40                   	inc    %eax
  801be2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be5:	47                   	inc    %edi
  801be6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be9:	75 d1                	jne    801bbc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801beb:	89 f8                	mov    %edi,%eax
  801bed:	eb 05                	jmp    801bf4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf4:	83 c4 1c             	add    $0x1c,%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5f                   	pop    %edi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 1c             	sub    $0x1c,%esp
  801c05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c08:	89 3c 24             	mov    %edi,(%esp)
  801c0b:	e8 34 f6 ff ff       	call   801244 <fd2data>
  801c10:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c12:	be 00 00 00 00       	mov    $0x0,%esi
  801c17:	eb 3a                	jmp    801c53 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c19:	85 f6                	test   %esi,%esi
  801c1b:	74 04                	je     801c21 <devpipe_read+0x25>
				return i;
  801c1d:	89 f0                	mov    %esi,%eax
  801c1f:	eb 40                	jmp    801c61 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	89 f8                	mov    %edi,%eax
  801c25:	e8 f5 fe ff ff       	call   801b1f <_pipeisclosed>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	75 2e                	jne    801c5c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c2e:	e8 6f ef ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c33:	8b 03                	mov    (%ebx),%eax
  801c35:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c38:	74 df                	je     801c19 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c3f:	79 05                	jns    801c46 <devpipe_read+0x4a>
  801c41:	48                   	dec    %eax
  801c42:	83 c8 e0             	or     $0xffffffe0,%eax
  801c45:	40                   	inc    %eax
  801c46:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c50:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c52:	46                   	inc    %esi
  801c53:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c56:	75 db                	jne    801c33 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c58:	89 f0                	mov    %esi,%eax
  801c5a:	eb 05                	jmp    801c61 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c61:	83 c4 1c             	add    $0x1c,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	57                   	push   %edi
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 3c             	sub    $0x3c,%esp
  801c72:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c75:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 df f5 ff ff       	call   80125f <fd_alloc>
  801c80:	89 c3                	mov    %eax,%ebx
  801c82:	85 c0                	test   %eax,%eax
  801c84:	0f 88 45 01 00 00    	js     801dcf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c91:	00 
  801c92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca0:	e8 1c ef ff ff       	call   800bc1 <sys_page_alloc>
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 20 01 00 00    	js     801dcf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801caf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801cb2:	89 04 24             	mov    %eax,(%esp)
  801cb5:	e8 a5 f5 ff ff       	call   80125f <fd_alloc>
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	0f 88 f8 00 00 00    	js     801dbc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ccb:	00 
  801ccc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cda:	e8 e2 ee ff ff       	call   800bc1 <sys_page_alloc>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	0f 88 d3 00 00 00    	js     801dbc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 50 f5 ff ff       	call   801244 <fd2data>
  801cf4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cfd:	00 
  801cfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d09:	e8 b3 ee ff ff       	call   800bc1 <sys_page_alloc>
  801d0e:	89 c3                	mov    %eax,%ebx
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 91 00 00 00    	js     801da9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d1b:	89 04 24             	mov    %eax,(%esp)
  801d1e:	e8 21 f5 ff ff       	call   801244 <fd2data>
  801d23:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d2a:	00 
  801d2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d36:	00 
  801d37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d42:	e8 ce ee ff ff       	call   800c15 <sys_page_map>
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	78 4c                	js     801d99 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d56:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d5b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d62:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d6b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d70:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d7a:	89 04 24             	mov    %eax,(%esp)
  801d7d:	e8 b2 f4 ff ff       	call   801234 <fd2num>
  801d82:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d87:	89 04 24             	mov    %eax,(%esp)
  801d8a:	e8 a5 f4 ff ff       	call   801234 <fd2num>
  801d8f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d97:	eb 36                	jmp    801dcf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801d99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da4:	e8 bf ee ff ff       	call   800c68 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801da9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db7:	e8 ac ee ff ff       	call   800c68 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dca:	e8 99 ee ff ff       	call   800c68 <sys_page_unmap>
    err:
	return r;
}
  801dcf:	89 d8                	mov    %ebx,%eax
  801dd1:	83 c4 3c             	add    $0x3c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	89 04 24             	mov    %eax,(%esp)
  801dec:	e8 c1 f4 ff ff       	call   8012b2 <fd_lookup>
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 15                	js     801e0a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 44 f4 ff ff       	call   801244 <fd2data>
	return _pipeisclosed(fd, p);
  801e00:	89 c2                	mov    %eax,%edx
  801e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e05:	e8 15 fd ff ff       	call   801b1f <_pipeisclosed>
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    

00801e16 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801e1c:	c7 44 24 04 c8 29 80 	movl   $0x8029c8,0x4(%esp)
  801e23:	00 
  801e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e27:	89 04 24             	mov    %eax,(%esp)
  801e2a:	e8 a0 e9 ff ff       	call   8007cf <strcpy>
	return 0;
}
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	57                   	push   %edi
  801e3a:	56                   	push   %esi
  801e3b:	53                   	push   %ebx
  801e3c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e42:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4d:	eb 30                	jmp    801e7f <devcons_write+0x49>
		m = n - tot;
  801e4f:	8b 75 10             	mov    0x10(%ebp),%esi
  801e52:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801e54:	83 fe 7f             	cmp    $0x7f,%esi
  801e57:	76 05                	jbe    801e5e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801e59:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e5e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801e62:	03 45 0c             	add    0xc(%ebp),%eax
  801e65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e69:	89 3c 24             	mov    %edi,(%esp)
  801e6c:	e8 d7 ea ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801e71:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e75:	89 3c 24             	mov    %edi,(%esp)
  801e78:	e8 77 ec ff ff       	call   800af4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7d:	01 f3                	add    %esi,%ebx
  801e7f:	89 d8                	mov    %ebx,%eax
  801e81:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e84:	72 c9                	jb     801e4f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e86:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5e                   	pop    %esi
  801e8e:	5f                   	pop    %edi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e9b:	75 07                	jne    801ea4 <devcons_read+0x13>
  801e9d:	eb 25                	jmp    801ec4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e9f:	e8 fe ec ff ff       	call   800ba2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ea4:	e8 69 ec ff ff       	call   800b12 <sys_cgetc>
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	74 f2                	je     801e9f <devcons_read+0xe>
  801ead:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	78 1d                	js     801ed0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eb3:	83 f8 04             	cmp    $0x4,%eax
  801eb6:	74 13                	je     801ecb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebb:	88 10                	mov    %dl,(%eax)
	return 1;
  801ebd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec2:	eb 0c                	jmp    801ed0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ec4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec9:	eb 05                	jmp    801ed0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ede:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ee5:	00 
  801ee6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee9:	89 04 24             	mov    %eax,(%esp)
  801eec:	e8 03 ec ff ff       	call   800af4 <sys_cputs>
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <getchar>:

int
getchar(void)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ef9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f00:	00 
  801f01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0f:	e8 3a f6 ff ff       	call   80154e <read>
	if (r < 0)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 0f                	js     801f27 <getchar+0x34>
		return r;
	if (r < 1)
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	7e 06                	jle    801f22 <getchar+0x2f>
		return -E_EOF;
	return c;
  801f1c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f20:	eb 05                	jmp    801f27 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f22:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f27:	c9                   	leave  
  801f28:	c3                   	ret    

00801f29 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f36:	8b 45 08             	mov    0x8(%ebp),%eax
  801f39:	89 04 24             	mov    %eax,(%esp)
  801f3c:	e8 71 f3 ff ff       	call   8012b2 <fd_lookup>
  801f41:	85 c0                	test   %eax,%eax
  801f43:	78 11                	js     801f56 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f4e:	39 10                	cmp    %edx,(%eax)
  801f50:	0f 94 c0             	sete   %al
  801f53:	0f b6 c0             	movzbl %al,%eax
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <opencons>:

int
opencons(void)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 f6 f2 ff ff       	call   80125f <fd_alloc>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 3c                	js     801fa9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f6d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f74:	00 
  801f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f83:	e8 39 ec ff ff       	call   800bc1 <sys_page_alloc>
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 1d                	js     801fa9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f8c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 8b f2 ff ff       	call   801234 <fd2num>
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    
	...

00801fac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	56                   	push   %esi
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801fb4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fb7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801fbd:	e8 c1 eb ff ff       	call   800b83 <sys_getenvid>
  801fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fc5:	89 54 24 10          	mov    %edx,0x10(%esp)
  801fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  801fcc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fd0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	c7 04 24 d4 29 80 00 	movl   $0x8029d4,(%esp)
  801fdf:	e8 20 e2 ff ff       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe8:	8b 45 10             	mov    0x10(%ebp),%eax
  801feb:	89 04 24             	mov    %eax,(%esp)
  801fee:	e8 b0 e1 ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  801ff3:	c7 04 24 8f 24 80 00 	movl   $0x80248f,(%esp)
  801ffa:	e8 05 e2 ff ff       	call   800204 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fff:	cc                   	int3   
  802000:	eb fd                	jmp    801fff <_panic+0x53>
	...

00802004 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80200a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802011:	0f 85 80 00 00 00    	jne    802097 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  802017:	a1 04 40 80 00       	mov    0x804004,%eax
  80201c:	8b 40 48             	mov    0x48(%eax),%eax
  80201f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802026:	00 
  802027:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80202e:	ee 
  80202f:	89 04 24             	mov    %eax,(%esp)
  802032:	e8 8a eb ff ff       	call   800bc1 <sys_page_alloc>
  802037:	85 c0                	test   %eax,%eax
  802039:	79 20                	jns    80205b <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80203b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203f:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  802046:	00 
  802047:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80204e:	00 
  80204f:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  802056:	e8 51 ff ff ff       	call   801fac <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80205b:	a1 04 40 80 00       	mov    0x804004,%eax
  802060:	8b 40 48             	mov    0x48(%eax),%eax
  802063:	c7 44 24 04 a4 20 80 	movl   $0x8020a4,0x4(%esp)
  80206a:	00 
  80206b:	89 04 24             	mov    %eax,(%esp)
  80206e:	e8 ee ec ff ff       	call   800d61 <sys_env_set_pgfault_upcall>
  802073:	85 c0                	test   %eax,%eax
  802075:	79 20                	jns    802097 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  802077:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207b:	c7 44 24 08 24 2a 80 	movl   $0x802a24,0x8(%esp)
  802082:	00 
  802083:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80208a:	00 
  80208b:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  802092:	e8 15 ff ff ff       	call   801fac <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802097:	8b 45 08             	mov    0x8(%ebp),%eax
  80209a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80209f:	c9                   	leave  
  8020a0:	c3                   	ret    
  8020a1:	00 00                	add    %al,(%eax)
	...

008020a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020a5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020ac:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8020af:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8020b3:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8020b5:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8020b8:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8020b9:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8020bc:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8020be:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8020c1:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8020c2:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8020c5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020c6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8020c7:	c3                   	ret    

008020c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 10             	sub    $0x10,%esp
  8020d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8020d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	75 05                	jne    8020e2 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8020dd:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8020e2:	89 04 24             	mov    %eax,(%esp)
  8020e5:	e8 ed ec ff ff       	call   800dd7 <sys_ipc_recv>
	if (!err) {
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	75 26                	jne    802114 <ipc_recv+0x4c>
		if (from_env_store) {
  8020ee:	85 f6                	test   %esi,%esi
  8020f0:	74 0a                	je     8020fc <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8020f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f7:	8b 40 74             	mov    0x74(%eax),%eax
  8020fa:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8020fc:	85 db                	test   %ebx,%ebx
  8020fe:	74 0a                	je     80210a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802100:	a1 04 40 80 00       	mov    0x804004,%eax
  802105:	8b 40 78             	mov    0x78(%eax),%eax
  802108:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80210a:	a1 04 40 80 00       	mov    0x804004,%eax
  80210f:	8b 40 70             	mov    0x70(%eax),%eax
  802112:	eb 14                	jmp    802128 <ipc_recv+0x60>
	}
	if (from_env_store) {
  802114:	85 f6                	test   %esi,%esi
  802116:	74 06                	je     80211e <ipc_recv+0x56>
		*from_env_store = 0;
  802118:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  80211e:	85 db                	test   %ebx,%ebx
  802120:	74 06                	je     802128 <ipc_recv+0x60>
		*perm_store = 0;
  802122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	5b                   	pop    %ebx
  80212c:	5e                   	pop    %esi
  80212d:	5d                   	pop    %ebp
  80212e:	c3                   	ret    

0080212f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
  802132:	57                   	push   %edi
  802133:	56                   	push   %esi
  802134:	53                   	push   %ebx
  802135:	83 ec 1c             	sub    $0x1c,%esp
  802138:	8b 75 10             	mov    0x10(%ebp),%esi
  80213b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  80213e:	85 f6                	test   %esi,%esi
  802140:	75 05                	jne    802147 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802142:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  802147:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80214b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80214f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802152:	89 44 24 04          	mov    %eax,0x4(%esp)
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 53 ec ff ff       	call   800db4 <sys_ipc_try_send>
  802161:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802163:	e8 3a ea ff ff       	call   800ba2 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802168:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80216b:	74 da                	je     802147 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  80216d:	85 db                	test   %ebx,%ebx
  80216f:	74 20                	je     802191 <ipc_send+0x62>
		panic("send fail: %e", err);
  802171:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802175:	c7 44 24 08 62 2a 80 	movl   $0x802a62,0x8(%esp)
  80217c:	00 
  80217d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802184:	00 
  802185:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  80218c:	e8 1b fe ff ff       	call   801fac <_panic>
	}
	return;
}
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	53                   	push   %ebx
  80219d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021a5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021ac:	89 c2                	mov    %eax,%edx
  8021ae:	c1 e2 07             	shl    $0x7,%edx
  8021b1:	29 ca                	sub    %ecx,%edx
  8021b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b9:	8b 52 50             	mov    0x50(%edx),%edx
  8021bc:	39 da                	cmp    %ebx,%edx
  8021be:	75 0f                	jne    8021cf <ipc_find_env+0x36>
			return envs[i].env_id;
  8021c0:	c1 e0 07             	shl    $0x7,%eax
  8021c3:	29 c8                	sub    %ecx,%eax
  8021c5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021ca:	8b 40 40             	mov    0x40(%eax),%eax
  8021cd:	eb 0c                	jmp    8021db <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021cf:	40                   	inc    %eax
  8021d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d5:	75 ce                	jne    8021a5 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021d7:	66 b8 00 00          	mov    $0x0,%ax
}
  8021db:	5b                   	pop    %ebx
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    
	...

008021e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e6:	89 c2                	mov    %eax,%edx
  8021e8:	c1 ea 16             	shr    $0x16,%edx
  8021eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021f2:	f6 c2 01             	test   $0x1,%dl
  8021f5:	74 1e                	je     802215 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021f7:	c1 e8 0c             	shr    $0xc,%eax
  8021fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802201:	a8 01                	test   $0x1,%al
  802203:	74 17                	je     80221c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802205:	c1 e8 0c             	shr    $0xc,%eax
  802208:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80220f:	ef 
  802210:	0f b7 c0             	movzwl %ax,%eax
  802213:	eb 0c                	jmp    802221 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
  80221a:	eb 05                	jmp    802221 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    
	...

00802224 <__udivdi3>:
  802224:	55                   	push   %ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	83 ec 10             	sub    $0x10,%esp
  80222a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80222e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802232:	89 74 24 04          	mov    %esi,0x4(%esp)
  802236:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80223a:	89 cd                	mov    %ecx,%ebp
  80223c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802240:	85 c0                	test   %eax,%eax
  802242:	75 2c                	jne    802270 <__udivdi3+0x4c>
  802244:	39 f9                	cmp    %edi,%ecx
  802246:	77 68                	ja     8022b0 <__udivdi3+0x8c>
  802248:	85 c9                	test   %ecx,%ecx
  80224a:	75 0b                	jne    802257 <__udivdi3+0x33>
  80224c:	b8 01 00 00 00       	mov    $0x1,%eax
  802251:	31 d2                	xor    %edx,%edx
  802253:	f7 f1                	div    %ecx
  802255:	89 c1                	mov    %eax,%ecx
  802257:	31 d2                	xor    %edx,%edx
  802259:	89 f8                	mov    %edi,%eax
  80225b:	f7 f1                	div    %ecx
  80225d:	89 c7                	mov    %eax,%edi
  80225f:	89 f0                	mov    %esi,%eax
  802261:	f7 f1                	div    %ecx
  802263:	89 c6                	mov    %eax,%esi
  802265:	89 f0                	mov    %esi,%eax
  802267:	89 fa                	mov    %edi,%edx
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	5e                   	pop    %esi
  80226d:	5f                   	pop    %edi
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    
  802270:	39 f8                	cmp    %edi,%eax
  802272:	77 2c                	ja     8022a0 <__udivdi3+0x7c>
  802274:	0f bd f0             	bsr    %eax,%esi
  802277:	83 f6 1f             	xor    $0x1f,%esi
  80227a:	75 4c                	jne    8022c8 <__udivdi3+0xa4>
  80227c:	39 f8                	cmp    %edi,%eax
  80227e:	bf 00 00 00 00       	mov    $0x0,%edi
  802283:	72 0a                	jb     80228f <__udivdi3+0x6b>
  802285:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802289:	0f 87 ad 00 00 00    	ja     80233c <__udivdi3+0x118>
  80228f:	be 01 00 00 00       	mov    $0x1,%esi
  802294:	89 f0                	mov    %esi,%eax
  802296:	89 fa                	mov    %edi,%edx
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	5e                   	pop    %esi
  80229c:	5f                   	pop    %edi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    
  80229f:	90                   	nop
  8022a0:	31 ff                	xor    %edi,%edi
  8022a2:	31 f6                	xor    %esi,%esi
  8022a4:	89 f0                	mov    %esi,%eax
  8022a6:	89 fa                	mov    %edi,%edx
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
  8022b0:	89 fa                	mov    %edi,%edx
  8022b2:	89 f0                	mov    %esi,%eax
  8022b4:	f7 f1                	div    %ecx
  8022b6:	89 c6                	mov    %eax,%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	89 f0                	mov    %esi,%eax
  8022bc:	89 fa                	mov    %edi,%edx
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	89 f1                	mov    %esi,%ecx
  8022ca:	d3 e0                	shl    %cl,%eax
  8022cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022d5:	29 f0                	sub    %esi,%eax
  8022d7:	89 ea                	mov    %ebp,%edx
  8022d9:	88 c1                	mov    %al,%cl
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022e1:	09 ca                	or     %ecx,%edx
  8022e3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022e7:	89 f1                	mov    %esi,%ecx
  8022e9:	d3 e5                	shl    %cl,%ebp
  8022eb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8022ef:	89 fd                	mov    %edi,%ebp
  8022f1:	88 c1                	mov    %al,%cl
  8022f3:	d3 ed                	shr    %cl,%ebp
  8022f5:	89 fa                	mov    %edi,%edx
  8022f7:	89 f1                	mov    %esi,%ecx
  8022f9:	d3 e2                	shl    %cl,%edx
  8022fb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022ff:	88 c1                	mov    %al,%cl
  802301:	d3 ef                	shr    %cl,%edi
  802303:	09 d7                	or     %edx,%edi
  802305:	89 f8                	mov    %edi,%eax
  802307:	89 ea                	mov    %ebp,%edx
  802309:	f7 74 24 08          	divl   0x8(%esp)
  80230d:	89 d1                	mov    %edx,%ecx
  80230f:	89 c7                	mov    %eax,%edi
  802311:	f7 64 24 0c          	mull   0xc(%esp)
  802315:	39 d1                	cmp    %edx,%ecx
  802317:	72 17                	jb     802330 <__udivdi3+0x10c>
  802319:	74 09                	je     802324 <__udivdi3+0x100>
  80231b:	89 fe                	mov    %edi,%esi
  80231d:	31 ff                	xor    %edi,%edi
  80231f:	e9 41 ff ff ff       	jmp    802265 <__udivdi3+0x41>
  802324:	8b 54 24 04          	mov    0x4(%esp),%edx
  802328:	89 f1                	mov    %esi,%ecx
  80232a:	d3 e2                	shl    %cl,%edx
  80232c:	39 c2                	cmp    %eax,%edx
  80232e:	73 eb                	jae    80231b <__udivdi3+0xf7>
  802330:	8d 77 ff             	lea    -0x1(%edi),%esi
  802333:	31 ff                	xor    %edi,%edi
  802335:	e9 2b ff ff ff       	jmp    802265 <__udivdi3+0x41>
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	31 f6                	xor    %esi,%esi
  80233e:	e9 22 ff ff ff       	jmp    802265 <__udivdi3+0x41>
	...

00802344 <__umoddi3>:
  802344:	55                   	push   %ebp
  802345:	57                   	push   %edi
  802346:	56                   	push   %esi
  802347:	83 ec 20             	sub    $0x20,%esp
  80234a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80234e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802352:	89 44 24 14          	mov    %eax,0x14(%esp)
  802356:	8b 74 24 34          	mov    0x34(%esp),%esi
  80235a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80235e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802362:	89 c7                	mov    %eax,%edi
  802364:	89 f2                	mov    %esi,%edx
  802366:	85 ed                	test   %ebp,%ebp
  802368:	75 16                	jne    802380 <__umoddi3+0x3c>
  80236a:	39 f1                	cmp    %esi,%ecx
  80236c:	0f 86 a6 00 00 00    	jbe    802418 <__umoddi3+0xd4>
  802372:	f7 f1                	div    %ecx
  802374:	89 d0                	mov    %edx,%eax
  802376:	31 d2                	xor    %edx,%edx
  802378:	83 c4 20             	add    $0x20,%esp
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop
  802380:	39 f5                	cmp    %esi,%ebp
  802382:	0f 87 ac 00 00 00    	ja     802434 <__umoddi3+0xf0>
  802388:	0f bd c5             	bsr    %ebp,%eax
  80238b:	83 f0 1f             	xor    $0x1f,%eax
  80238e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802392:	0f 84 a8 00 00 00    	je     802440 <__umoddi3+0xfc>
  802398:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80239c:	d3 e5                	shl    %cl,%ebp
  80239e:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023a7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ab:	89 f9                	mov    %edi,%ecx
  8023ad:	d3 e8                	shr    %cl,%eax
  8023af:	09 e8                	or     %ebp,%eax
  8023b1:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023b5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023b9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023bd:	d3 e0                	shl    %cl,%eax
  8023bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	d3 e2                	shl    %cl,%edx
  8023c7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023cb:	d3 e0                	shl    %cl,%eax
  8023cd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023d1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	09 d0                	or     %edx,%eax
  8023db:	d3 ee                	shr    %cl,%esi
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	f7 74 24 18          	divl   0x18(%esp)
  8023e3:	89 d6                	mov    %edx,%esi
  8023e5:	f7 64 24 0c          	mull   0xc(%esp)
  8023e9:	89 c5                	mov    %eax,%ebp
  8023eb:	89 d1                	mov    %edx,%ecx
  8023ed:	39 d6                	cmp    %edx,%esi
  8023ef:	72 67                	jb     802458 <__umoddi3+0x114>
  8023f1:	74 75                	je     802468 <__umoddi3+0x124>
  8023f3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023f7:	29 e8                	sub    %ebp,%eax
  8023f9:	19 ce                	sbb    %ecx,%esi
  8023fb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023ff:	d3 e8                	shr    %cl,%eax
  802401:	89 f2                	mov    %esi,%edx
  802403:	89 f9                	mov    %edi,%ecx
  802405:	d3 e2                	shl    %cl,%edx
  802407:	09 d0                	or     %edx,%eax
  802409:	89 f2                	mov    %esi,%edx
  80240b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80240f:	d3 ea                	shr    %cl,%edx
  802411:	83 c4 20             	add    $0x20,%esp
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	85 c9                	test   %ecx,%ecx
  80241a:	75 0b                	jne    802427 <__umoddi3+0xe3>
  80241c:	b8 01 00 00 00       	mov    $0x1,%eax
  802421:	31 d2                	xor    %edx,%edx
  802423:	f7 f1                	div    %ecx
  802425:	89 c1                	mov    %eax,%ecx
  802427:	89 f0                	mov    %esi,%eax
  802429:	31 d2                	xor    %edx,%edx
  80242b:	f7 f1                	div    %ecx
  80242d:	89 f8                	mov    %edi,%eax
  80242f:	e9 3e ff ff ff       	jmp    802372 <__umoddi3+0x2e>
  802434:	89 f2                	mov    %esi,%edx
  802436:	83 c4 20             	add    $0x20,%esp
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	39 f5                	cmp    %esi,%ebp
  802442:	72 04                	jb     802448 <__umoddi3+0x104>
  802444:	39 f9                	cmp    %edi,%ecx
  802446:	77 06                	ja     80244e <__umoddi3+0x10a>
  802448:	89 f2                	mov    %esi,%edx
  80244a:	29 cf                	sub    %ecx,%edi
  80244c:	19 ea                	sbb    %ebp,%edx
  80244e:	89 f8                	mov    %edi,%eax
  802450:	83 c4 20             	add    $0x20,%esp
  802453:	5e                   	pop    %esi
  802454:	5f                   	pop    %edi
  802455:	5d                   	pop    %ebp
  802456:	c3                   	ret    
  802457:	90                   	nop
  802458:	89 d1                	mov    %edx,%ecx
  80245a:	89 c5                	mov    %eax,%ebp
  80245c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802460:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802464:	eb 8d                	jmp    8023f3 <__umoddi3+0xaf>
  802466:	66 90                	xchg   %ax,%ax
  802468:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80246c:	72 ea                	jb     802458 <__umoddi3+0x114>
  80246e:	89 f1                	mov    %esi,%ecx
  802470:	eb 81                	jmp    8023f3 <__umoddi3+0xaf>
