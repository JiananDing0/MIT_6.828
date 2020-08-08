
obj/user/forktree:     file format elf32-i386


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
  80003e:	e8 38 0b 00 00       	call   800b7b <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  800052:	e8 a5 01 00 00       	call   8001fc <cprintf>

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
  800090:	e8 ff 06 00 00       	call   800794 <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 71 15 80 	movl   $0x801571,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 a8 06 00 00       	call   800769 <snprintf>
	if (fork() == 0) {
  8000c1:	e8 19 0e 00 00       	call   800edf <fork>
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
  8000e6:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
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
  800102:	e8 74 0a 00 00       	call   800b7b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 f6                	test   %esi,%esi
  800124:	7e 07                	jle    80012d <libmain+0x39>
		binaryname = argv[0];
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 cf 09 00 00       	call   800b29 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 19                	jne    800192 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800179:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800180:	00 
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 60 09 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800192:	ff 43 04             	incl   0x4(%ebx)
}
  800195:	83 c4 14             	add    $0x14,%esp
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001d7:	e8 82 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 f8 08 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	e8 87 ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 3c             	sub    $0x3c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d7                	mov    %edx,%edi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800235:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	85 c0                	test   %eax,%eax
  80023a:	75 08                	jne    800244 <printnum+0x2c>
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 57                	ja     80029b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 74 24 10          	mov    %esi,0x10(%esp)
  800248:	4b                   	dec    %ebx
  800249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800258:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80025c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800263:	00 
  800264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	e8 7e 10 00 00       	call   8012f4 <__udivdi3>
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	89 54 24 04          	mov    %edx,0x4(%esp)
  800285:	89 fa                	mov    %edi,%edx
  800287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028a:	e8 89 ff ff ff       	call   800218 <printnum>
  80028f:	eb 0f                	jmp    8002a0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	89 34 24             	mov    %esi,(%esp)
  800298:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f f1                	jg     800291 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	e8 4b 11 00 00       	call   801414 <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 80 15 80 00 	movsbl 0x801580(%eax),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002da:	83 c4 3c             	add    $0x3c,%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 08                	jae    800334 <sprintputch+0x18>
		*b->buf++ = ch;
  80032c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032f:	88 0a                	mov    %cl,(%edx)
  800331:	42                   	inc    %edx
  800332:	89 10                	mov    %edx,(%eax)
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80033c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800343:	8b 45 10             	mov    0x10(%ebp),%eax
  800346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 02 00 00 00       	call   80035e <vprintfmt>
	va_end(ap);
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 4c             	sub    $0x4c,%esp
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 75 10             	mov    0x10(%ebp),%esi
  80036d:	eb 12                	jmp    800381 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036f:	85 c0                	test   %eax,%eax
  800371:	0f 84 8b 03 00 00    	je     800702 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800377:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	0f b6 06             	movzbl (%esi),%eax
  800384:	46                   	inc    %esi
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e5                	jne    80036f <vprintfmt+0x11>
  80038a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80038e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800395:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a6:	eb 26                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003af:	eb 1d                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b8:	eb 14                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c4:	eb 08                	jmp    8003ce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	0f b6 06             	movzbl (%esi),%eax
  8003d1:	8d 56 01             	lea    0x1(%esi),%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003d7:	8a 16                	mov    (%esi),%dl
  8003d9:	83 ea 23             	sub    $0x23,%edx
  8003dc:	80 fa 55             	cmp    $0x55,%dl
  8003df:	0f 87 01 03 00 00    	ja     8006e6 <vprintfmt+0x388>
  8003e5:	0f b6 d2             	movzbl %dl,%edx
  8003e8:	ff 24 95 40 16 80 00 	jmp    *0x801640(,%edx,4)
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003fe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800401:	8d 50 d0             	lea    -0x30(%eax),%edx
  800404:	83 fa 09             	cmp    $0x9,%edx
  800407:	77 2a                	ja     800433 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040a:	eb eb                	jmp    8003f7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041a:	eb 17                	jmp    800433 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80041c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800420:	78 98                	js     8003ba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800425:	eb a7                	jmp    8003ce <vprintfmt+0x70>
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800431:	eb 9b                	jmp    8003ce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800437:	79 95                	jns    8003ce <vprintfmt+0x70>
  800439:	eb 8b                	jmp    8003c6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043f:	eb 8d                	jmp    8003ce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 23 ff ff ff       	jmp    800381 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	79 02                	jns    80046f <vprintfmt+0x111>
  80046d:	f7 d8                	neg    %eax
  80046f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 08             	cmp    $0x8,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x123>
  800476:	8b 04 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%eax
  80047d:	85 c0                	test   %eax,%eax
  80047f:	75 23                	jne    8004a4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800481:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800485:	c7 44 24 08 98 15 80 	movl   $0x801598,0x8(%esp)
  80048c:	00 
  80048d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 9a fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049f:	e9 dd fe ff ff       	jmp    800381 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a8:	c7 44 24 08 a1 15 80 	movl   $0x8015a1,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	89 14 24             	mov    %edx,(%esp)
  8004ba:	e8 77 fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	e9 ba fe ff ff       	jmp    800381 <vprintfmt+0x23>
  8004c7:	89 f9                	mov    %edi,%ecx
  8004c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 30                	mov    (%eax),%esi
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	75 05                	jne    8004e3 <vprintfmt+0x185>
				p = "(null)";
  8004de:	be 91 15 80 00       	mov    $0x801591,%esi
			if (width > 0 && padc != '-')
  8004e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e7:	0f 8e 84 00 00 00    	jle    800571 <vprintfmt+0x213>
  8004ed:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f1:	74 7e                	je     800571 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f7:	89 34 24             	mov    %esi,(%esp)
  8004fa:	e8 ab 02 00 00       	call   8007aa <strnlen>
  8004ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800502:	29 c2                	sub    %eax,%edx
  800504:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800507:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80050b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80050e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800511:	89 de                	mov    %ebx,%esi
  800513:	89 d3                	mov    %edx,%ebx
  800515:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	eb 0b                	jmp    800524 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051d:	89 3c 24             	mov    %edi,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <vprintfmt+0x1bb>
  800528:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052b:	89 f3                	mov    %esi,%ebx
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	79 05                	jns    80053c <vprintfmt+0x1de>
  800537:	b8 00 00 00 00       	mov    $0x0,%eax
  80053c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053f:	29 c2                	sub    %eax,%edx
  800541:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800544:	eb 2b                	jmp    800571 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054a:	74 18                	je     800564 <vprintfmt+0x206>
  80054c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054f:	83 fa 5e             	cmp    $0x5e,%edx
  800552:	76 10                	jbe    800564 <vprintfmt+0x206>
					putch('?', putdat);
  800554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800558:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	eb 0a                	jmp    80056e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	ff 4d e4             	decl   -0x1c(%ebp)
  800571:	0f be 06             	movsbl (%esi),%eax
  800574:	46                   	inc    %esi
  800575:	85 c0                	test   %eax,%eax
  800577:	74 21                	je     80059a <vprintfmt+0x23c>
  800579:	85 ff                	test   %edi,%edi
  80057b:	78 c9                	js     800546 <vprintfmt+0x1e8>
  80057d:	4f                   	dec    %edi
  80057e:	79 c6                	jns    800546 <vprintfmt+0x1e8>
  800580:	8b 7d 08             	mov    0x8(%ebp),%edi
  800583:	89 de                	mov    %ebx,%esi
  800585:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800588:	eb 18                	jmp    8005a2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	eb 08                	jmp    8005a2 <vprintfmt+0x244>
  80059a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059d:	89 de                	mov    %ebx,%esi
  80059f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	7f e4                	jg     80058a <vprintfmt+0x22c>
  8005a6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005a9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ce fd ff ff       	jmp    800381 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 f9 01             	cmp    $0x1,%ecx
  8005b6:	7e 10                	jle    8005c8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
  8005c3:	8b 78 04             	mov    0x4(%eax),%edi
  8005c6:	eb 26                	jmp    8005ee <vprintfmt+0x290>
	else if (lflag)
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	74 12                	je     8005de <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 30                	mov    (%eax),%esi
  8005d7:	89 f7                	mov    %esi,%edi
  8005d9:	c1 ff 1f             	sar    $0x1f,%edi
  8005dc:	eb 10                	jmp    8005ee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	89 f7                	mov    %esi,%edi
  8005eb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	78 0a                	js     8005fc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 ac 00 00 00       	jmp    8006a8 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800600:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060a:	f7 de                	neg    %esi
  80060c:	83 d7 00             	adc    $0x0,%edi
  80060f:	f7 df                	neg    %edi
			}
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	e9 8d 00 00 00       	jmp    8006a8 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061b:	89 ca                	mov    %ecx,%edx
  80061d:	8d 45 14             	lea    0x14(%ebp),%eax
  800620:	e8 bd fc ff ff       	call   8002e2 <getuint>
  800625:	89 c6                	mov    %eax,%esi
  800627:	89 d7                	mov    %edx,%edi
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062e:	eb 78                	jmp    8006a8 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80063e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800642:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800649:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80065d:	e9 1f fd ff ff       	jmp    800381 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800666:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800687:	8b 30                	mov    (%eax),%esi
  800689:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800693:	eb 13                	jmp    8006a8 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 43 fc ff ff       	call   8002e2 <getuint>
  80069f:	89 c6                	mov    %eax,%esi
  8006a1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bb:	89 34 24             	mov    %esi,(%esp)
  8006be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	e8 4c fb ff ff       	call   800218 <printnum>
			break;
  8006cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006cf:	e9 ad fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e1:	e9 9b fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f4:	eb 01                	jmp    8006f7 <vprintfmt+0x399>
  8006f6:	4e                   	dec    %esi
  8006f7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006fb:	75 f9                	jne    8006f6 <vprintfmt+0x398>
  8006fd:	e9 7f fc ff ff       	jmp    800381 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800702:	83 c4 4c             	add    $0x4c,%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 28             	sub    $0x28,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 30                	je     80075b <vsnprintf+0x51>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 33                	jle    800762 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800736:	8b 45 10             	mov    0x10(%ebp),%eax
  800739:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800740:	89 44 24 04          	mov    %eax,0x4(%esp)
  800744:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80074b:	e8 0e fc ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	eb 0c                	jmp    800767 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb 05                	jmp    800767 <vsnprintf+0x5d>
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800772:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	e8 7b ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    
  800791:	00 00                	add    %al,(%eax)
	...

00800794 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
  80079f:	eb 01                	jmp    8007a2 <strlen+0xe>
		n++;
  8007a1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	75 f9                	jne    8007a1 <strlen+0xd>
		n++;
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb 01                	jmp    8007bb <strnlen+0x11>
		n++;
  8007ba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	39 d0                	cmp    %edx,%eax
  8007bd:	74 06                	je     8007c5 <strnlen+0x1b>
  8007bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c3:	75 f5                	jne    8007ba <strnlen+0x10>
		n++;
	return n;
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007dc:	42                   	inc    %edx
  8007dd:	84 c9                	test   %cl,%cl
  8007df:	75 f5                	jne    8007d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e1:	5b                   	pop    %ebx
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ee:	89 1c 24             	mov    %ebx,(%esp)
  8007f1:	e8 9e ff ff ff       	call   800794 <strlen>
	strcpy(dst + len, src);
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fd:	01 d8                	add    %ebx,%eax
  8007ff:	89 04 24             	mov    %eax,(%esp)
  800802:	e8 c0 ff ff ff       	call   8007c7 <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800822:	eb 0c                	jmp    800830 <strncpy+0x21>
		*dst++ = *src;
  800824:	8a 1a                	mov    (%edx),%bl
  800826:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800829:	80 3a 01             	cmpb   $0x1,(%edx)
  80082c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082f:	41                   	inc    %ecx
  800830:	39 f1                	cmp    %esi,%ecx
  800832:	75 f0                	jne    800824 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800843:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800846:	85 d2                	test   %edx,%edx
  800848:	75 0a                	jne    800854 <strlcpy+0x1c>
  80084a:	89 f0                	mov    %esi,%eax
  80084c:	eb 1a                	jmp    800868 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084e:	88 18                	mov    %bl,(%eax)
  800850:	40                   	inc    %eax
  800851:	41                   	inc    %ecx
  800852:	eb 02                	jmp    800856 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800854:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800856:	4a                   	dec    %edx
  800857:	74 0a                	je     800863 <strlcpy+0x2b>
  800859:	8a 19                	mov    (%ecx),%bl
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ef                	jne    80084e <strlcpy+0x16>
  80085f:	89 c2                	mov    %eax,%edx
  800861:	eb 02                	jmp    800865 <strlcpy+0x2d>
  800863:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800865:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800868:	29 f0                	sub    %esi,%eax
}
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800877:	eb 02                	jmp    80087b <strcmp+0xd>
		p++, q++;
  800879:	41                   	inc    %ecx
  80087a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087b:	8a 01                	mov    (%ecx),%al
  80087d:	84 c0                	test   %al,%al
  80087f:	74 04                	je     800885 <strcmp+0x17>
  800881:	3a 02                	cmp    (%edx),%al
  800883:	74 f4                	je     800879 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800885:	0f b6 c0             	movzbl %al,%eax
  800888:	0f b6 12             	movzbl (%edx),%edx
  80088b:	29 d0                	sub    %edx,%eax
}
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800899:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80089c:	eb 03                	jmp    8008a1 <strncmp+0x12>
		n--, p++, q++;
  80089e:	4a                   	dec    %edx
  80089f:	40                   	inc    %eax
  8008a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	74 14                	je     8008b9 <strncmp+0x2a>
  8008a5:	8a 18                	mov    (%eax),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	74 04                	je     8008af <strncmp+0x20>
  8008ab:	3a 19                	cmp    (%ecx),%bl
  8008ad:	74 ef                	je     80089e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 11             	movzbl (%ecx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	eb 05                	jmp    8008be <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ca:	eb 05                	jmp    8008d1 <strchr+0x10>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0c                	je     8008dc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	40                   	inc    %eax
  8008d1:	8a 10                	mov    (%eax),%dl
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f5                	jne    8008cc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e7:	eb 05                	jmp    8008ee <strfind+0x10>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	74 07                	je     8008f4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ed:	40                   	inc    %eax
  8008ee:	8a 10                	mov    (%eax),%dl
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f5                	jne    8008e9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	57                   	push   %edi
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 30                	je     800939 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800909:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090f:	75 25                	jne    800936 <memset+0x40>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 20                	jne    800936 <memset+0x40>
		c &= 0xFF;
  800916:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d3                	mov    %edx,%ebx
  80091b:	c1 e3 08             	shl    $0x8,%ebx
  80091e:	89 d6                	mov    %edx,%esi
  800920:	c1 e6 18             	shl    $0x18,%esi
  800923:	89 d0                	mov    %edx,%eax
  800925:	c1 e0 10             	shl    $0x10,%eax
  800928:	09 f0                	or     %esi,%eax
  80092a:	09 d0                	or     %edx,%eax
  80092c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800931:	fc                   	cld    
  800932:	f3 ab                	rep stos %eax,%es:(%edi)
  800934:	eb 03                	jmp    800939 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800936:	fc                   	cld    
  800937:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800939:	89 f8                	mov    %edi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094e:	39 c6                	cmp    %eax,%esi
  800950:	73 34                	jae    800986 <memmove+0x46>
  800952:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800955:	39 d0                	cmp    %edx,%eax
  800957:	73 2d                	jae    800986 <memmove+0x46>
		s += n;
		d += n;
  800959:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095c:	f6 c2 03             	test   $0x3,%dl
  80095f:	75 1b                	jne    80097c <memmove+0x3c>
  800961:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800967:	75 13                	jne    80097c <memmove+0x3c>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 0e                	jne    80097c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096e:	83 ef 04             	sub    $0x4,%edi
  800971:	8d 72 fc             	lea    -0x4(%edx),%esi
  800974:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800977:	fd                   	std    
  800978:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097a:	eb 07                	jmp    800983 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097c:	4f                   	dec    %edi
  80097d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800980:	fd                   	std    
  800981:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800983:	fc                   	cld    
  800984:	eb 20                	jmp    8009a6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800986:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098c:	75 13                	jne    8009a1 <memmove+0x61>
  80098e:	a8 03                	test   $0x3,%al
  800990:	75 0f                	jne    8009a1 <memmove+0x61>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 0a                	jne    8009a1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800997:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 05                	jmp    8009a6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	89 04 24             	mov    %eax,(%esp)
  8009c4:	e8 77 ff ff ff       	call   800940 <memmove>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009da:	ba 00 00 00 00       	mov    $0x0,%edx
  8009df:	eb 16                	jmp    8009f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009e1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009e4:	42                   	inc    %edx
  8009e5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009e9:	38 c8                	cmp    %cl,%al
  8009eb:	74 0a                	je     8009f7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009ed:	0f b6 c0             	movzbl %al,%eax
  8009f0:	0f b6 c9             	movzbl %cl,%ecx
  8009f3:	29 c8                	sub    %ecx,%eax
  8009f5:	eb 09                	jmp    800a00 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	39 da                	cmp    %ebx,%edx
  8009f9:	75 e6                	jne    8009e1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0e:	89 c2                	mov    %eax,%edx
  800a10:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a13:	eb 05                	jmp    800a1a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a15:	38 08                	cmp    %cl,(%eax)
  800a17:	74 05                	je     800a1e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a19:	40                   	inc    %eax
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	72 f7                	jb     800a15 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 55 08             	mov    0x8(%ebp),%edx
  800a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2c:	eb 01                	jmp    800a2f <strtol+0xf>
		s++;
  800a2e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	8a 02                	mov    (%edx),%al
  800a31:	3c 20                	cmp    $0x20,%al
  800a33:	74 f9                	je     800a2e <strtol+0xe>
  800a35:	3c 09                	cmp    $0x9,%al
  800a37:	74 f5                	je     800a2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a39:	3c 2b                	cmp    $0x2b,%al
  800a3b:	75 08                	jne    800a45 <strtol+0x25>
		s++;
  800a3d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a43:	eb 13                	jmp    800a58 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a45:	3c 2d                	cmp    $0x2d,%al
  800a47:	75 0a                	jne    800a53 <strtol+0x33>
		s++, neg = 1;
  800a49:	8d 52 01             	lea    0x1(%edx),%edx
  800a4c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a51:	eb 05                	jmp    800a58 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	74 05                	je     800a61 <strtol+0x41>
  800a5c:	83 fb 10             	cmp    $0x10,%ebx
  800a5f:	75 28                	jne    800a89 <strtol+0x69>
  800a61:	8a 02                	mov    (%edx),%al
  800a63:	3c 30                	cmp    $0x30,%al
  800a65:	75 10                	jne    800a77 <strtol+0x57>
  800a67:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a6b:	75 0a                	jne    800a77 <strtol+0x57>
		s += 2, base = 16;
  800a6d:	83 c2 02             	add    $0x2,%edx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 12                	jmp    800a89 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 0e                	jne    800a89 <strtol+0x69>
  800a7b:	3c 30                	cmp    $0x30,%al
  800a7d:	75 05                	jne    800a84 <strtol+0x64>
		s++, base = 8;
  800a7f:	42                   	inc    %edx
  800a80:	b3 08                	mov    $0x8,%bl
  800a82:	eb 05                	jmp    800a89 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a84:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a90:	8a 0a                	mov    (%edx),%cl
  800a92:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a95:	80 fb 09             	cmp    $0x9,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0x82>
			dig = *s - '0';
  800a9a:	0f be c9             	movsbl %cl,%ecx
  800a9d:	83 e9 30             	sub    $0x30,%ecx
  800aa0:	eb 1e                	jmp    800ac0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aa2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aaa:	0f be c9             	movsbl %cl,%ecx
  800aad:	83 e9 57             	sub    $0x57,%ecx
  800ab0:	eb 0e                	jmp    800ac0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ab2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ab5:	80 fb 19             	cmp    $0x19,%bl
  800ab8:	77 12                	ja     800acc <strtol+0xac>
			dig = *s - 'A' + 10;
  800aba:	0f be c9             	movsbl %cl,%ecx
  800abd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac0:	39 f1                	cmp    %esi,%ecx
  800ac2:	7d 0c                	jge    800ad0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ac4:	42                   	inc    %edx
  800ac5:	0f af c6             	imul   %esi,%eax
  800ac8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aca:	eb c4                	jmp    800a90 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800acc:	89 c1                	mov    %eax,%ecx
  800ace:	eb 02                	jmp    800ad2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 05                	je     800add <strtol+0xbd>
		*endptr = (char *) s;
  800ad8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800adb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800add:	85 ff                	test   %edi,%edi
  800adf:	74 04                	je     800ae5 <strtol+0xc5>
  800ae1:	89 c8                	mov    %ecx,%eax
  800ae3:	f7 d8                	neg    %eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    
	...

00800aec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	89 c6                	mov    %eax,%esi
  800b03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	89 cb                	mov    %ecx,%ebx
  800b41:	89 cf                	mov    %ecx,%edi
  800b43:	89 ce                	mov    %ecx,%esi
  800b45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7e 28                	jle    800b73 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b4f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b56:	00 
  800b57:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800b5e:	00 
  800b5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b66:	00 
  800b67:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800b6e:	e8 65 06 00 00       	call   8011d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	83 c4 2c             	add    $0x2c,%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 28                	jle    800c05 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800be8:	00 
  800be9:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800bf0:	00 
  800bf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf8:	00 
  800bf9:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800c00:	e8 d3 05 00 00       	call   8011d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c05:	83 c4 2c             	add    $0x2c,%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 28                	jle    800c58 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c34:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c3b:	00 
  800c3c:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800c43:	00 
  800c44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4b:	00 
  800c4c:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800c53:	e8 80 05 00 00       	call   8011d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	83 c4 2c             	add    $0x2c,%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 28                	jle    800cab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c87:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800c96:	00 
  800c97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9e:	00 
  800c9f:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800ca6:	e8 2d 05 00 00       	call   8011d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cab:	83 c4 2c             	add    $0x2c,%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7e 28                	jle    800cfe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cda:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ce1:	00 
  800ce2:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800ce9:	00 
  800cea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf1:	00 
  800cf2:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800cf9:	e8 da 04 00 00       	call   8011d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfe:	83 c4 2c             	add    $0x2c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 09 00 00 00       	mov    $0x9,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 28                	jle    800d51 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d34:	00 
  800d35:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800d3c:	00 
  800d3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d44:	00 
  800d45:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800d4c:	e8 87 04 00 00       	call   8011d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d51:	83 c4 2c             	add    $0x2c,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	be 00 00 00 00       	mov    $0x0,%esi
  800d64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 cb                	mov    %ecx,%ebx
  800d94:	89 cf                	mov    %ecx,%edi
  800d96:	89 ce                	mov    %ecx,%esi
  800d98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 28                	jle    800dc6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800da9:	00 
  800daa:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800db1:	00 
  800db2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db9:	00 
  800dba:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800dc1:	e8 12 04 00 00       	call   8011d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc6:	83 c4 2c             	add    $0x2c,%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
	...

00800dd0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 24             	sub    $0x24,%esp
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dda:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800ddc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de0:	75 20                	jne    800e02 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800de2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800de6:	c7 44 24 08 f0 17 80 	movl   $0x8017f0,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  800dfd:	e8 d6 03 00 00       	call   8011d8 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e02:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e0d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e14:	f6 c4 08             	test   $0x8,%ah
  800e17:	75 1c                	jne    800e35 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e19:	c7 44 24 08 20 18 80 	movl   $0x801820,0x8(%esp)
  800e20:	00 
  800e21:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e28:	00 
  800e29:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  800e30:	e8 a3 03 00 00       	call   8011d8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800e35:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e44:	00 
  800e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4c:	e8 68 fd ff ff       	call   800bb9 <sys_page_alloc>
  800e51:	85 c0                	test   %eax,%eax
  800e53:	79 20                	jns    800e75 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800e55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e59:	c7 44 24 08 7a 18 80 	movl   $0x80187a,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  800e70:	e8 63 03 00 00       	call   8011d8 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800e75:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e7c:	00 
  800e7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e81:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e88:	e8 b3 fa ff ff       	call   800940 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800e8d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e94:	00 
  800e95:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb0:	e8 58 fd ff ff       	call   800c0d <sys_page_map>
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	79 20                	jns    800ed9 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	c7 44 24 08 8d 18 80 	movl   $0x80188d,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  800ed4:	e8 ff 02 00 00       	call   8011d8 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800ed9:	83 c4 24             	add    $0x24,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800ee8:	c7 04 24 d0 0d 80 00 	movl   $0x800dd0,(%esp)
  800eef:	e8 3c 03 00 00       	call   801230 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef4:	ba 07 00 00 00       	mov    $0x7,%edx
  800ef9:	89 d0                	mov    %edx,%eax
  800efb:	cd 30                	int    $0x30
  800efd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f00:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800f03:	85 c0                	test   %eax,%eax
  800f05:	79 20                	jns    800f27 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800f07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0b:	c7 44 24 08 9e 18 80 	movl   $0x80189e,0x8(%esp)
  800f12:	00 
  800f13:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800f1a:	00 
  800f1b:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  800f22:	e8 b1 02 00 00       	call   8011d8 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800f27:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f2b:	75 25                	jne    800f52 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2d:	e8 49 fc ff ff       	call   800b7b <sys_getenvid>
  800f32:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f3e:	c1 e0 07             	shl    $0x7,%eax
  800f41:	29 d0                	sub    %edx,%eax
  800f43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f48:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f4d:	e9 58 02 00 00       	jmp    8011aa <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800f52:	bf 00 00 00 00       	mov    $0x0,%edi
  800f57:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800f5c:	89 f0                	mov    %esi,%eax
  800f5e:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f61:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f68:	a8 01                	test   $0x1,%al
  800f6a:	0f 84 7a 01 00 00    	je     8010ea <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800f70:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f77:	a8 01                	test   $0x1,%al
  800f79:	0f 84 6b 01 00 00    	je     8010ea <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800f7f:	a1 04 20 80 00       	mov    0x802004,%eax
  800f84:	8b 40 48             	mov    0x48(%eax),%eax
  800f87:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800f8a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f91:	f6 c4 04             	test   $0x4,%ah
  800f94:	74 52                	je     800fe8 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800f96:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9d:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb8:	89 04 24             	mov    %eax,(%esp)
  800fbb:	e8 4d fc ff ff       	call   800c0d <sys_page_map>
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	0f 89 22 01 00 00    	jns    8010ea <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  800fc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fcc:	c7 44 24 08 ae 18 80 	movl   $0x8018ae,0x8(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800fdb:	00 
  800fdc:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  800fe3:	e8 f0 01 00 00       	call   8011d8 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  800fe8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fef:	f6 c4 08             	test   $0x8,%ah
  800ff2:	75 0f                	jne    801003 <fork+0x124>
  800ff4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffb:	a8 02                	test   $0x2,%al
  800ffd:	0f 84 99 00 00 00    	je     80109c <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801003:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100a:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  80100d:	83 f8 01             	cmp    $0x1,%eax
  801010:	19 db                	sbb    %ebx,%ebx
  801012:	83 e3 fc             	and    $0xfffffffc,%ebx
  801015:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80101b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80101f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801023:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801026:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80102e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801031:	89 04 24             	mov    %eax,(%esp)
  801034:	e8 d4 fb ff ff       	call   800c0d <sys_page_map>
  801039:	85 c0                	test   %eax,%eax
  80103b:	79 20                	jns    80105d <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  80103d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801041:	c7 44 24 08 ae 18 80 	movl   $0x8018ae,0x8(%esp)
  801048:	00 
  801049:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  801058:	e8 7b 01 00 00       	call   8011d8 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80105d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801061:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801070:	89 04 24             	mov    %eax,(%esp)
  801073:	e8 95 fb ff ff       	call   800c0d <sys_page_map>
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 6e                	jns    8010ea <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80107c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801080:	c7 44 24 08 ae 18 80 	movl   $0x8018ae,0x8(%esp)
  801087:	00 
  801088:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80108f:	00 
  801090:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  801097:	e8 3c 01 00 00       	call   8011d8 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80109c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ac:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010be:	89 04 24             	mov    %eax,(%esp)
  8010c1:	e8 47 fb ff ff       	call   800c0d <sys_page_map>
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 20                	jns    8010ea <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ce:	c7 44 24 08 ae 18 80 	movl   $0x8018ae,0x8(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8010dd:	00 
  8010de:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  8010e5:	e8 ee 00 00 00       	call   8011d8 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8010ea:	46                   	inc    %esi
  8010eb:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010f1:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010f7:	0f 85 5f fe ff ff    	jne    800f5c <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8010fd:	c7 44 24 04 d0 12 80 	movl   $0x8012d0,0x4(%esp)
  801104:	00 
  801105:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801108:	89 04 24             	mov    %eax,(%esp)
  80110b:	e8 f6 fb ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
  801110:	85 c0                	test   %eax,%eax
  801112:	79 20                	jns    801134 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801118:	c7 44 24 08 50 18 80 	movl   $0x801850,0x8(%esp)
  80111f:	00 
  801120:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801127:	00 
  801128:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  80112f:	e8 a4 00 00 00       	call   8011d8 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801134:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801143:	ee 
  801144:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	e8 6a fa ff ff       	call   800bb9 <sys_page_alloc>
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 20                	jns    801173 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  801153:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801157:	c7 44 24 08 7a 18 80 	movl   $0x80187a,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  80116e:	e8 65 00 00 00       	call   8011d8 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801173:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80117a:	00 
  80117b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80117e:	89 04 24             	mov    %eax,(%esp)
  801181:	e8 2d fb ff ff       	call   800cb3 <sys_env_set_status>
  801186:	85 c0                	test   %eax,%eax
  801188:	79 20                	jns    8011aa <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  80118a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118e:	c7 44 24 08 c0 18 80 	movl   $0x8018c0,0x8(%esp)
  801195:	00 
  801196:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80119d:	00 
  80119e:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  8011a5:	e8 2e 00 00 00       	call   8011d8 <_panic>
	}
	
	return envid;
}
  8011aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ad:	83 c4 3c             	add    $0x3c,%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011bb:	c7 44 24 08 d7 18 80 	movl   $0x8018d7,0x8(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8011ca:	00 
  8011cb:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  8011d2:	e8 01 00 00 00       	call   8011d8 <_panic>
	...

008011d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011e3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011e9:	e8 8d f9 ff ff       	call   800b7b <sys_getenvid>
  8011ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801200:	89 44 24 04          	mov    %eax,0x4(%esp)
  801204:	c7 04 24 f0 18 80 00 	movl   $0x8018f0,(%esp)
  80120b:	e8 ec ef ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801210:	89 74 24 04          	mov    %esi,0x4(%esp)
  801214:	8b 45 10             	mov    0x10(%ebp),%eax
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	e8 7c ef ff ff       	call   80019b <vcprintf>
	cprintf("\n");
  80121f:	c7 04 24 6f 15 80 00 	movl   $0x80156f,(%esp)
  801226:	e8 d1 ef ff ff       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80122b:	cc                   	int3   
  80122c:	eb fd                	jmp    80122b <_panic+0x53>
	...

00801230 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801236:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80123d:	0f 85 80 00 00 00    	jne    8012c3 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  801243:	a1 04 20 80 00       	mov    0x802004,%eax
  801248:	8b 40 48             	mov    0x48(%eax),%eax
  80124b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801252:	00 
  801253:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80125a:	ee 
  80125b:	89 04 24             	mov    %eax,(%esp)
  80125e:	e8 56 f9 ff ff       	call   800bb9 <sys_page_alloc>
  801263:	85 c0                	test   %eax,%eax
  801265:	79 20                	jns    801287 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  801267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126b:	c7 44 24 08 14 19 80 	movl   $0x801914,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80127a:	00 
  80127b:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  801282:	e8 51 ff ff ff       	call   8011d8 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  801287:	a1 04 20 80 00       	mov    0x802004,%eax
  80128c:	8b 40 48             	mov    0x48(%eax),%eax
  80128f:	c7 44 24 04 d0 12 80 	movl   $0x8012d0,0x4(%esp)
  801296:	00 
  801297:	89 04 24             	mov    %eax,(%esp)
  80129a:	e8 67 fa ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	79 20                	jns    8012c3 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  8012a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a7:	c7 44 24 08 40 19 80 	movl   $0x801940,0x8(%esp)
  8012ae:	00 
  8012af:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8012b6:	00 
  8012b7:	c7 04 24 70 19 80 00 	movl   $0x801970,(%esp)
  8012be:	e8 15 ff ff ff       	call   8011d8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    
  8012cd:	00 00                	add    %al,(%eax)
	...

008012d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012d1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012d8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8012db:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8012df:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8012e1:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8012e4:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8012e5:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8012e8:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8012ea:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8012ed:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8012ee:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8012f1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012f2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8012f3:	c3                   	ret    

008012f4 <__udivdi3>:
  8012f4:	55                   	push   %ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	83 ec 10             	sub    $0x10,%esp
  8012fa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012fe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801302:	89 74 24 04          	mov    %esi,0x4(%esp)
  801306:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80130a:	89 cd                	mov    %ecx,%ebp
  80130c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801310:	85 c0                	test   %eax,%eax
  801312:	75 2c                	jne    801340 <__udivdi3+0x4c>
  801314:	39 f9                	cmp    %edi,%ecx
  801316:	77 68                	ja     801380 <__udivdi3+0x8c>
  801318:	85 c9                	test   %ecx,%ecx
  80131a:	75 0b                	jne    801327 <__udivdi3+0x33>
  80131c:	b8 01 00 00 00       	mov    $0x1,%eax
  801321:	31 d2                	xor    %edx,%edx
  801323:	f7 f1                	div    %ecx
  801325:	89 c1                	mov    %eax,%ecx
  801327:	31 d2                	xor    %edx,%edx
  801329:	89 f8                	mov    %edi,%eax
  80132b:	f7 f1                	div    %ecx
  80132d:	89 c7                	mov    %eax,%edi
  80132f:	89 f0                	mov    %esi,%eax
  801331:	f7 f1                	div    %ecx
  801333:	89 c6                	mov    %eax,%esi
  801335:	89 f0                	mov    %esi,%eax
  801337:	89 fa                	mov    %edi,%edx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
  801340:	39 f8                	cmp    %edi,%eax
  801342:	77 2c                	ja     801370 <__udivdi3+0x7c>
  801344:	0f bd f0             	bsr    %eax,%esi
  801347:	83 f6 1f             	xor    $0x1f,%esi
  80134a:	75 4c                	jne    801398 <__udivdi3+0xa4>
  80134c:	39 f8                	cmp    %edi,%eax
  80134e:	bf 00 00 00 00       	mov    $0x0,%edi
  801353:	72 0a                	jb     80135f <__udivdi3+0x6b>
  801355:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801359:	0f 87 ad 00 00 00    	ja     80140c <__udivdi3+0x118>
  80135f:	be 01 00 00 00       	mov    $0x1,%esi
  801364:	89 f0                	mov    %esi,%eax
  801366:	89 fa                	mov    %edi,%edx
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    
  80136f:	90                   	nop
  801370:	31 ff                	xor    %edi,%edi
  801372:	31 f6                	xor    %esi,%esi
  801374:	89 f0                	mov    %esi,%eax
  801376:	89 fa                	mov    %edi,%edx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	5e                   	pop    %esi
  80137c:	5f                   	pop    %edi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    
  80137f:	90                   	nop
  801380:	89 fa                	mov    %edi,%edx
  801382:	89 f0                	mov    %esi,%eax
  801384:	f7 f1                	div    %ecx
  801386:	89 c6                	mov    %eax,%esi
  801388:	31 ff                	xor    %edi,%edi
  80138a:	89 f0                	mov    %esi,%eax
  80138c:	89 fa                	mov    %edi,%edx
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	89 f1                	mov    %esi,%ecx
  80139a:	d3 e0                	shl    %cl,%eax
  80139c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a0:	b8 20 00 00 00       	mov    $0x20,%eax
  8013a5:	29 f0                	sub    %esi,%eax
  8013a7:	89 ea                	mov    %ebp,%edx
  8013a9:	88 c1                	mov    %al,%cl
  8013ab:	d3 ea                	shr    %cl,%edx
  8013ad:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013b1:	09 ca                	or     %ecx,%edx
  8013b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013b7:	89 f1                	mov    %esi,%ecx
  8013b9:	d3 e5                	shl    %cl,%ebp
  8013bb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8013bf:	89 fd                	mov    %edi,%ebp
  8013c1:	88 c1                	mov    %al,%cl
  8013c3:	d3 ed                	shr    %cl,%ebp
  8013c5:	89 fa                	mov    %edi,%edx
  8013c7:	89 f1                	mov    %esi,%ecx
  8013c9:	d3 e2                	shl    %cl,%edx
  8013cb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013cf:	88 c1                	mov    %al,%cl
  8013d1:	d3 ef                	shr    %cl,%edi
  8013d3:	09 d7                	or     %edx,%edi
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	89 ea                	mov    %ebp,%edx
  8013d9:	f7 74 24 08          	divl   0x8(%esp)
  8013dd:	89 d1                	mov    %edx,%ecx
  8013df:	89 c7                	mov    %eax,%edi
  8013e1:	f7 64 24 0c          	mull   0xc(%esp)
  8013e5:	39 d1                	cmp    %edx,%ecx
  8013e7:	72 17                	jb     801400 <__udivdi3+0x10c>
  8013e9:	74 09                	je     8013f4 <__udivdi3+0x100>
  8013eb:	89 fe                	mov    %edi,%esi
  8013ed:	31 ff                	xor    %edi,%edi
  8013ef:	e9 41 ff ff ff       	jmp    801335 <__udivdi3+0x41>
  8013f4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013f8:	89 f1                	mov    %esi,%ecx
  8013fa:	d3 e2                	shl    %cl,%edx
  8013fc:	39 c2                	cmp    %eax,%edx
  8013fe:	73 eb                	jae    8013eb <__udivdi3+0xf7>
  801400:	8d 77 ff             	lea    -0x1(%edi),%esi
  801403:	31 ff                	xor    %edi,%edi
  801405:	e9 2b ff ff ff       	jmp    801335 <__udivdi3+0x41>
  80140a:	66 90                	xchg   %ax,%ax
  80140c:	31 f6                	xor    %esi,%esi
  80140e:	e9 22 ff ff ff       	jmp    801335 <__udivdi3+0x41>
	...

00801414 <__umoddi3>:
  801414:	55                   	push   %ebp
  801415:	57                   	push   %edi
  801416:	56                   	push   %esi
  801417:	83 ec 20             	sub    $0x20,%esp
  80141a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80141e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801422:	89 44 24 14          	mov    %eax,0x14(%esp)
  801426:	8b 74 24 34          	mov    0x34(%esp),%esi
  80142a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80142e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801432:	89 c7                	mov    %eax,%edi
  801434:	89 f2                	mov    %esi,%edx
  801436:	85 ed                	test   %ebp,%ebp
  801438:	75 16                	jne    801450 <__umoddi3+0x3c>
  80143a:	39 f1                	cmp    %esi,%ecx
  80143c:	0f 86 a6 00 00 00    	jbe    8014e8 <__umoddi3+0xd4>
  801442:	f7 f1                	div    %ecx
  801444:	89 d0                	mov    %edx,%eax
  801446:	31 d2                	xor    %edx,%edx
  801448:	83 c4 20             	add    $0x20,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	39 f5                	cmp    %esi,%ebp
  801452:	0f 87 ac 00 00 00    	ja     801504 <__umoddi3+0xf0>
  801458:	0f bd c5             	bsr    %ebp,%eax
  80145b:	83 f0 1f             	xor    $0x1f,%eax
  80145e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801462:	0f 84 a8 00 00 00    	je     801510 <__umoddi3+0xfc>
  801468:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80146c:	d3 e5                	shl    %cl,%ebp
  80146e:	bf 20 00 00 00       	mov    $0x20,%edi
  801473:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801477:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80147b:	89 f9                	mov    %edi,%ecx
  80147d:	d3 e8                	shr    %cl,%eax
  80147f:	09 e8                	or     %ebp,%eax
  801481:	89 44 24 18          	mov    %eax,0x18(%esp)
  801485:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801489:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80148d:	d3 e0                	shl    %cl,%eax
  80148f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801493:	89 f2                	mov    %esi,%edx
  801495:	d3 e2                	shl    %cl,%edx
  801497:	8b 44 24 14          	mov    0x14(%esp),%eax
  80149b:	d3 e0                	shl    %cl,%eax
  80149d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8014a1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014a5:	89 f9                	mov    %edi,%ecx
  8014a7:	d3 e8                	shr    %cl,%eax
  8014a9:	09 d0                	or     %edx,%eax
  8014ab:	d3 ee                	shr    %cl,%esi
  8014ad:	89 f2                	mov    %esi,%edx
  8014af:	f7 74 24 18          	divl   0x18(%esp)
  8014b3:	89 d6                	mov    %edx,%esi
  8014b5:	f7 64 24 0c          	mull   0xc(%esp)
  8014b9:	89 c5                	mov    %eax,%ebp
  8014bb:	89 d1                	mov    %edx,%ecx
  8014bd:	39 d6                	cmp    %edx,%esi
  8014bf:	72 67                	jb     801528 <__umoddi3+0x114>
  8014c1:	74 75                	je     801538 <__umoddi3+0x124>
  8014c3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014c7:	29 e8                	sub    %ebp,%eax
  8014c9:	19 ce                	sbb    %ecx,%esi
  8014cb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014cf:	d3 e8                	shr    %cl,%eax
  8014d1:	89 f2                	mov    %esi,%edx
  8014d3:	89 f9                	mov    %edi,%ecx
  8014d5:	d3 e2                	shl    %cl,%edx
  8014d7:	09 d0                	or     %edx,%eax
  8014d9:	89 f2                	mov    %esi,%edx
  8014db:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014df:	d3 ea                	shr    %cl,%edx
  8014e1:	83 c4 20             	add    $0x20,%esp
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    
  8014e8:	85 c9                	test   %ecx,%ecx
  8014ea:	75 0b                	jne    8014f7 <__umoddi3+0xe3>
  8014ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f1:	31 d2                	xor    %edx,%edx
  8014f3:	f7 f1                	div    %ecx
  8014f5:	89 c1                	mov    %eax,%ecx
  8014f7:	89 f0                	mov    %esi,%eax
  8014f9:	31 d2                	xor    %edx,%edx
  8014fb:	f7 f1                	div    %ecx
  8014fd:	89 f8                	mov    %edi,%eax
  8014ff:	e9 3e ff ff ff       	jmp    801442 <__umoddi3+0x2e>
  801504:	89 f2                	mov    %esi,%edx
  801506:	83 c4 20             	add    $0x20,%esp
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
  801510:	39 f5                	cmp    %esi,%ebp
  801512:	72 04                	jb     801518 <__umoddi3+0x104>
  801514:	39 f9                	cmp    %edi,%ecx
  801516:	77 06                	ja     80151e <__umoddi3+0x10a>
  801518:	89 f2                	mov    %esi,%edx
  80151a:	29 cf                	sub    %ecx,%edi
  80151c:	19 ea                	sbb    %ebp,%edx
  80151e:	89 f8                	mov    %edi,%eax
  801520:	83 c4 20             	add    $0x20,%esp
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    
  801527:	90                   	nop
  801528:	89 d1                	mov    %edx,%ecx
  80152a:	89 c5                	mov    %eax,%ebp
  80152c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801530:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801534:	eb 8d                	jmp    8014c3 <__umoddi3+0xaf>
  801536:	66 90                	xchg   %ax,%ax
  801538:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80153c:	72 ea                	jb     801528 <__umoddi3+0x114>
  80153e:	89 f1                	mov    %esi,%ecx
  801540:	eb 81                	jmp    8014c3 <__umoddi3+0xaf>
