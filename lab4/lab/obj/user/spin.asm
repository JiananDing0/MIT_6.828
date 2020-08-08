
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  800042:	e8 71 01 00 00       	call   8001b8 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 4f 0e 00 00       	call   800e9b <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 78 15 80 00 	movl   $0x801578,(%esp)
  800059:	e8 5a 01 00 00       	call   8001b8 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  800067:	e8 4c 01 00 00       	call   8001b8 <cprintf>
	sys_yield();
  80006c:	e8 e5 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  800071:	e8 e0 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  800076:	e8 db 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  80007b:	e8 d6 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  800080:	e8 d1 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  800085:	e8 cc 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  80008a:	e8 c7 0a 00 00       	call   800b56 <sys_yield>
	sys_yield();
  80008f:	e8 c2 0a 00 00       	call   800b56 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 50 15 80 00 	movl   $0x801550,(%esp)
  80009b:	e8 18 01 00 00       	call   8001b8 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 3d 0a 00 00       	call   800ae5 <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000be:	e8 74 0a 00 00       	call   800b37 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x39>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ed:	89 34 24             	mov    %esi,(%esp)
  8000f0:	e8 3f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80010a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800111:	e8 cf 09 00 00       	call   800ae5 <sys_env_destroy>
}
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 14             	sub    $0x14,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 03                	mov    (%ebx),%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012b:	40                   	inc    %eax
  80012c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 19                	jne    80014e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800135:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80013c:	00 
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	89 04 24             	mov    %eax,(%esp)
  800143:	e8 60 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  800148:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80014e:	ff 43 04             	incl   0x4(%ebx)
}
  800151:	83 c4 14             	add    $0x14,%esp
  800154:	5b                   	pop    %ebx
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800182:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	c7 04 24 18 01 80 00 	movl   $0x800118,(%esp)
  800193:	e8 82 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 f8 08 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 87 ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    
	...

008001d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 3c             	sub    $0x3c,%esp
  8001dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e0:	89 d7                	mov    %edx,%edi
  8001e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	75 08                	jne    800200 <printnum+0x2c>
  8001f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fe:	77 57                	ja     800257 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	89 74 24 10          	mov    %esi,0x10(%esp)
  800204:	4b                   	dec    %ebx
  800205:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800209:	8b 45 10             	mov    0x10(%ebp),%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800214:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	e8 7e 10 00 00       	call   8012b0 <__udivdi3>
  800232:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800236:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800241:	89 fa                	mov    %edi,%edx
  800243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800246:	e8 89 ff ff ff       	call   8001d4 <printnum>
  80024b:	eb 0f                	jmp    80025c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800251:	89 34 24             	mov    %esi,(%esp)
  800254:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800257:	4b                   	dec    %ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f f1                	jg     80024d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800272:	00 
  800273:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	e8 4b 11 00 00       	call   8013d0 <__umoddi3>
  800285:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800289:	0f be 80 a0 15 80 00 	movsbl 0x8015a0(%eax),%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800296:	83 c4 3c             	add    $0x3c,%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a1:	83 fa 01             	cmp    $0x1,%edx
  8002a4:	7e 0e                	jle    8002b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	eb 22                	jmp    8002d6 <getuint+0x38>
	else if (lflag)
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 10                	je     8002c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0e                	jmp    8002d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e6:	73 08                	jae    8002f0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002eb:	88 0a                	mov    %cl,(%edx)
  8002ed:	42                   	inc    %edx
  8002ee:	89 10                	mov    %edx,(%eax)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
  800309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 02 00 00 00       	call   80031a <vprintfmt>
	va_end(ap);
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 4c             	sub    $0x4c,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800326:	8b 75 10             	mov    0x10(%ebp),%esi
  800329:	eb 12                	jmp    80033d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032b:	85 c0                	test   %eax,%eax
  80032d:	0f 84 8b 03 00 00    	je     8006be <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800333:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033d:	0f b6 06             	movzbl (%esi),%eax
  800340:	46                   	inc    %esi
  800341:	83 f8 25             	cmp    $0x25,%eax
  800344:	75 e5                	jne    80032b <vprintfmt+0x11>
  800346:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80034a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800351:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800356:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 26                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80036b:	eb 1d                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800370:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800374:	eb 14                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800379:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800380:	eb 08                	jmp    80038a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800382:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800385:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	0f b6 06             	movzbl (%esi),%eax
  80038d:	8d 56 01             	lea    0x1(%esi),%edx
  800390:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800393:	8a 16                	mov    (%esi),%dl
  800395:	83 ea 23             	sub    $0x23,%edx
  800398:	80 fa 55             	cmp    $0x55,%dl
  80039b:	0f 87 01 03 00 00    	ja     8006a2 <vprintfmt+0x388>
  8003a1:	0f b6 d2             	movzbl %dl,%edx
  8003a4:	ff 24 95 60 16 80 00 	jmp    *0x801660(,%edx,4)
  8003ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ae:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003b6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003bd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 2a                	ja     8003ef <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb eb                	jmp    8003b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 17                	jmp    8003ef <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003dc:	78 98                	js     800376 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e1:	eb a7                	jmp    80038a <vprintfmt+0x70>
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003ed:	eb 9b                	jmp    80038a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f3:	79 95                	jns    80038a <vprintfmt+0x70>
  8003f5:	eb 8b                	jmp    800382 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fb:	eb 8d                	jmp    80038a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800415:	e9 23 ff ff ff       	jmp    80033d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	79 02                	jns    80042b <vprintfmt+0x111>
  800429:	f7 d8                	neg    %eax
  80042b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042d:	83 f8 08             	cmp    $0x8,%eax
  800430:	7f 0b                	jg     80043d <vprintfmt+0x123>
  800432:	8b 04 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%eax
  800439:	85 c0                	test   %eax,%eax
  80043b:	75 23                	jne    800460 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80043d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800441:	c7 44 24 08 b8 15 80 	movl   $0x8015b8,0x8(%esp)
  800448:	00 
  800449:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 9a fe ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 dd fe ff ff       	jmp    80033d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800464:	c7 44 24 08 c1 15 80 	movl   $0x8015c1,0x8(%esp)
  80046b:	00 
  80046c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800470:	8b 55 08             	mov    0x8(%ebp),%edx
  800473:	89 14 24             	mov    %edx,(%esp)
  800476:	e8 77 fe ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80047e:	e9 ba fe ff ff       	jmp    80033d <vprintfmt+0x23>
  800483:	89 f9                	mov    %edi,%ecx
  800485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 30                	mov    (%eax),%esi
  800496:	85 f6                	test   %esi,%esi
  800498:	75 05                	jne    80049f <vprintfmt+0x185>
				p = "(null)";
  80049a:	be b1 15 80 00       	mov    $0x8015b1,%esi
			if (width > 0 && padc != '-')
  80049f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a3:	0f 8e 84 00 00 00    	jle    80052d <vprintfmt+0x213>
  8004a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004ad:	74 7e                	je     80052d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b3:	89 34 24             	mov    %esi,(%esp)
  8004b6:	e8 ab 02 00 00       	call   800766 <strnlen>
  8004bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004cd:	89 de                	mov    %ebx,%esi
  8004cf:	89 d3                	mov    %edx,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	eb 0b                	jmp    8004e0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d9:	89 3c 24             	mov    %edi,(%esp)
  8004dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	4b                   	dec    %ebx
  8004e0:	85 db                	test   %ebx,%ebx
  8004e2:	7f f1                	jg     8004d5 <vprintfmt+0x1bb>
  8004e4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004e7:	89 f3                	mov    %esi,%ebx
  8004e9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	79 05                	jns    8004f8 <vprintfmt+0x1de>
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004fb:	29 c2                	sub    %eax,%edx
  8004fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800500:	eb 2b                	jmp    80052d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800506:	74 18                	je     800520 <vprintfmt+0x206>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 10                	jbe    800520 <vprintfmt+0x206>
					putch('?', putdat);
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
  80051e:	eb 0a                	jmp    80052a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	ff 4d e4             	decl   -0x1c(%ebp)
  80052d:	0f be 06             	movsbl (%esi),%eax
  800530:	46                   	inc    %esi
  800531:	85 c0                	test   %eax,%eax
  800533:	74 21                	je     800556 <vprintfmt+0x23c>
  800535:	85 ff                	test   %edi,%edi
  800537:	78 c9                	js     800502 <vprintfmt+0x1e8>
  800539:	4f                   	dec    %edi
  80053a:	79 c6                	jns    800502 <vprintfmt+0x1e8>
  80053c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053f:	89 de                	mov    %ebx,%esi
  800541:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800544:	eb 18                	jmp    80055e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800551:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	4b                   	dec    %ebx
  800554:	eb 08                	jmp    80055e <vprintfmt+0x244>
  800556:	8b 7d 08             	mov    0x8(%ebp),%edi
  800559:	89 de                	mov    %ebx,%esi
  80055b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80055e:	85 db                	test   %ebx,%ebx
  800560:	7f e4                	jg     800546 <vprintfmt+0x22c>
  800562:	89 7d 08             	mov    %edi,0x8(%ebp)
  800565:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056a:	e9 ce fd ff ff       	jmp    80033d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 f9 01             	cmp    $0x1,%ecx
  800572:	7e 10                	jle    800584 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 30                	mov    (%eax),%esi
  80057f:	8b 78 04             	mov    0x4(%eax),%edi
  800582:	eb 26                	jmp    8005aa <vprintfmt+0x290>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	74 12                	je     80059a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 30                	mov    (%eax),%esi
  800593:	89 f7                	mov    %esi,%edi
  800595:	c1 ff 1f             	sar    $0x1f,%edi
  800598:	eb 10                	jmp    8005aa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 30                	mov    (%eax),%esi
  8005a5:	89 f7                	mov    %esi,%edi
  8005a7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	78 0a                	js     8005b8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	e9 ac 00 00 00       	jmp    800664 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c6:	f7 de                	neg    %esi
  8005c8:	83 d7 00             	adc    $0x0,%edi
  8005cb:	f7 df                	neg    %edi
			}
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 8d 00 00 00       	jmp    800664 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d7:	89 ca                	mov    %ecx,%edx
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 bd fc ff ff       	call   80029e <getuint>
  8005e1:	89 c6                	mov    %eax,%esi
  8005e3:	89 d7                	mov    %edx,%edi
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ea:	eb 78                	jmp    800664 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8005fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fe:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800619:	e9 1f fd ff ff       	jmp    80033d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80061e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800622:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800629:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064f:	eb 13                	jmp    800664 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800651:	89 ca                	mov    %ecx,%edx
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 43 fc ff ff       	call   80029e <getuint>
  80065b:	89 c6                	mov    %eax,%esi
  80065d:	89 d7                	mov    %edx,%edi
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800668:	89 54 24 10          	mov    %edx,0x10(%esp)
  80066c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800673:	89 44 24 08          	mov    %eax,0x8(%esp)
  800677:	89 34 24             	mov    %esi,(%esp)
  80067a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067e:	89 da                	mov    %ebx,%edx
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	e8 4c fb ff ff       	call   8001d4 <printnum>
			break;
  800688:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068b:	e9 ad fc ff ff       	jmp    80033d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069d:	e9 9b fc ff ff       	jmp    80033d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b0:	eb 01                	jmp    8006b3 <vprintfmt+0x399>
  8006b2:	4e                   	dec    %esi
  8006b3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b7:	75 f9                	jne    8006b2 <vprintfmt+0x398>
  8006b9:	e9 7f fc ff ff       	jmp    80033d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006be:	83 c4 4c             	add    $0x4c,%esp
  8006c1:	5b                   	pop    %ebx
  8006c2:	5e                   	pop    %esi
  8006c3:	5f                   	pop    %edi
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 28             	sub    $0x28,%esp
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	74 30                	je     800717 <vsnprintf+0x51>
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	7e 33                	jle    80071e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800700:	c7 04 24 d8 02 80 00 	movl   $0x8002d8,(%esp)
  800707:	e8 0e fc ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	eb 0c                	jmp    800723 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071c:	eb 05                	jmp    800723 <vsnprintf+0x5d>
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800732:	8b 45 10             	mov    0x10(%ebp),%eax
  800735:	89 44 24 08          	mov    %eax,0x8(%esp)
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	e8 7b ff ff ff       	call   8006c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    
  80074d:	00 00                	add    %al,(%eax)
	...

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 01                	jmp    80075e <strlen+0xe>
		n++;
  80075d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800762:	75 f9                	jne    80075d <strlen+0xd>
		n++;
	return n;
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80076c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	eb 01                	jmp    800777 <strnlen+0x11>
		n++;
  800776:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 d0                	cmp    %edx,%eax
  800779:	74 06                	je     800781 <strnlen+0x1b>
  80077b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077f:	75 f5                	jne    800776 <strnlen+0x10>
		n++;
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
  800792:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800795:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800798:	42                   	inc    %edx
  800799:	84 c9                	test   %cl,%cl
  80079b:	75 f5                	jne    800792 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	89 1c 24             	mov    %ebx,(%esp)
  8007ad:	e8 9e ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b9:	01 d8                	add    %ebx,%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 c0 ff ff ff       	call   800783 <strcpy>
	return dst;
}
  8007c3:	89 d8                	mov    %ebx,%eax
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007de:	eb 0c                	jmp    8007ec <strncpy+0x21>
		*dst++ = *src;
  8007e0:	8a 1a                	mov    (%edx),%bl
  8007e2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	41                   	inc    %ecx
  8007ec:	39 f1                	cmp    %esi,%ecx
  8007ee:	75 f0                	jne    8007e0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	75 0a                	jne    800810 <strlcpy+0x1c>
  800806:	89 f0                	mov    %esi,%eax
  800808:	eb 1a                	jmp    800824 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080a:	88 18                	mov    %bl,(%eax)
  80080c:	40                   	inc    %eax
  80080d:	41                   	inc    %ecx
  80080e:	eb 02                	jmp    800812 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800812:	4a                   	dec    %edx
  800813:	74 0a                	je     80081f <strlcpy+0x2b>
  800815:	8a 19                	mov    (%ecx),%bl
  800817:	84 db                	test   %bl,%bl
  800819:	75 ef                	jne    80080a <strlcpy+0x16>
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	eb 02                	jmp    800821 <strlcpy+0x2d>
  80081f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 02                	jmp    800837 <strcmp+0xd>
		p++, q++;
  800835:	41                   	inc    %ecx
  800836:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800837:	8a 01                	mov    (%ecx),%al
  800839:	84 c0                	test   %al,%al
  80083b:	74 04                	je     800841 <strcmp+0x17>
  80083d:	3a 02                	cmp    (%edx),%al
  80083f:	74 f4                	je     800835 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800855:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800858:	eb 03                	jmp    80085d <strncmp+0x12>
		n--, p++, q++;
  80085a:	4a                   	dec    %edx
  80085b:	40                   	inc    %eax
  80085c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	85 d2                	test   %edx,%edx
  80085f:	74 14                	je     800875 <strncmp+0x2a>
  800861:	8a 18                	mov    (%eax),%bl
  800863:	84 db                	test   %bl,%bl
  800865:	74 04                	je     80086b <strncmp+0x20>
  800867:	3a 19                	cmp    (%ecx),%bl
  800869:	74 ef                	je     80085a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	0f b6 11             	movzbl (%ecx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb 05                	jmp    80087a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800886:	eb 05                	jmp    80088d <strchr+0x10>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 0c                	je     800898 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088c:	40                   	inc    %eax
  80088d:	8a 10                	mov    (%eax),%dl
  80088f:	84 d2                	test   %dl,%dl
  800891:	75 f5                	jne    800888 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a3:	eb 05                	jmp    8008aa <strfind+0x10>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 07                	je     8008b0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	40                   	inc    %eax
  8008aa:	8a 10                	mov    (%eax),%dl
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	75 f5                	jne    8008a5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c1:	85 c9                	test   %ecx,%ecx
  8008c3:	74 30                	je     8008f5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 25                	jne    8008f2 <memset+0x40>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 20                	jne    8008f2 <memset+0x40>
		c &= 0xFF;
  8008d2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	89 d3                	mov    %edx,%ebx
  8008d7:	c1 e3 08             	shl    $0x8,%ebx
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	c1 e6 18             	shl    $0x18,%esi
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	c1 e0 10             	shl    $0x10,%eax
  8008e4:	09 f0                	or     %esi,%eax
  8008e6:	09 d0                	or     %edx,%eax
  8008e8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb 03                	jmp    8008f5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	fc                   	cld    
  8008f3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f5:	89 f8                	mov    %edi,%eax
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 75 0c             	mov    0xc(%ebp),%esi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090a:	39 c6                	cmp    %eax,%esi
  80090c:	73 34                	jae    800942 <memmove+0x46>
  80090e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800911:	39 d0                	cmp    %edx,%eax
  800913:	73 2d                	jae    800942 <memmove+0x46>
		s += n;
		d += n;
  800915:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	f6 c2 03             	test   $0x3,%dl
  80091b:	75 1b                	jne    800938 <memmove+0x3c>
  80091d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800923:	75 13                	jne    800938 <memmove+0x3c>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 0e                	jne    800938 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092a:	83 ef 04             	sub    $0x4,%edi
  80092d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800930:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800933:	fd                   	std    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb 07                	jmp    80093f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800938:	4f                   	dec    %edi
  800939:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093c:	fd                   	std    
  80093d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093f:	fc                   	cld    
  800940:	eb 20                	jmp    800962 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800948:	75 13                	jne    80095d <memmove+0x61>
  80094a:	a8 03                	test   $0x3,%al
  80094c:	75 0f                	jne    80095d <memmove+0x61>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0a                	jne    80095d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800953:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800956:	89 c7                	mov    %eax,%edi
  800958:	fc                   	cld    
  800959:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095b:	eb 05                	jmp    800962 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800962:	5e                   	pop    %esi
  800963:	5f                   	pop    %edi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80096c:	8b 45 10             	mov    0x10(%ebp),%eax
  80096f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	89 04 24             	mov    %eax,(%esp)
  800980:	e8 77 ff ff ff       	call   8008fc <memmove>
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	eb 16                	jmp    8009b3 <memcmp+0x2c>
		if (*s1 != *s2)
  80099d:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009a0:	42                   	inc    %edx
  8009a1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009a5:	38 c8                	cmp    %cl,%al
  8009a7:	74 0a                	je     8009b3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009a9:	0f b6 c0             	movzbl %al,%eax
  8009ac:	0f b6 c9             	movzbl %cl,%ecx
  8009af:	29 c8                	sub    %ecx,%eax
  8009b1:	eb 09                	jmp    8009bc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	39 da                	cmp    %ebx,%edx
  8009b5:	75 e6                	jne    80099d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009cf:	eb 05                	jmp    8009d6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	38 08                	cmp    %cl,(%eax)
  8009d3:	74 05                	je     8009da <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	40                   	inc    %eax
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	72 f7                	jb     8009d1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 01                	jmp    8009eb <strtol+0xf>
		s++;
  8009ea:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	8a 02                	mov    (%edx),%al
  8009ed:	3c 20                	cmp    $0x20,%al
  8009ef:	74 f9                	je     8009ea <strtol+0xe>
  8009f1:	3c 09                	cmp    $0x9,%al
  8009f3:	74 f5                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f5:	3c 2b                	cmp    $0x2b,%al
  8009f7:	75 08                	jne    800a01 <strtol+0x25>
		s++;
  8009f9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ff:	eb 13                	jmp    800a14 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a01:	3c 2d                	cmp    $0x2d,%al
  800a03:	75 0a                	jne    800a0f <strtol+0x33>
		s++, neg = 1;
  800a05:	8d 52 01             	lea    0x1(%edx),%edx
  800a08:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0d:	eb 05                	jmp    800a14 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	85 db                	test   %ebx,%ebx
  800a16:	74 05                	je     800a1d <strtol+0x41>
  800a18:	83 fb 10             	cmp    $0x10,%ebx
  800a1b:	75 28                	jne    800a45 <strtol+0x69>
  800a1d:	8a 02                	mov    (%edx),%al
  800a1f:	3c 30                	cmp    $0x30,%al
  800a21:	75 10                	jne    800a33 <strtol+0x57>
  800a23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a27:	75 0a                	jne    800a33 <strtol+0x57>
		s += 2, base = 16;
  800a29:	83 c2 02             	add    $0x2,%edx
  800a2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a31:	eb 12                	jmp    800a45 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	75 0e                	jne    800a45 <strtol+0x69>
  800a37:	3c 30                	cmp    $0x30,%al
  800a39:	75 05                	jne    800a40 <strtol+0x64>
		s++, base = 8;
  800a3b:	42                   	inc    %edx
  800a3c:	b3 08                	mov    $0x8,%bl
  800a3e:	eb 05                	jmp    800a45 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a40:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4c:	8a 0a                	mov    (%edx),%cl
  800a4e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a51:	80 fb 09             	cmp    $0x9,%bl
  800a54:	77 08                	ja     800a5e <strtol+0x82>
			dig = *s - '0';
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 30             	sub    $0x30,%ecx
  800a5c:	eb 1e                	jmp    800a7c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a5e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a61:	80 fb 19             	cmp    $0x19,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a66:	0f be c9             	movsbl %cl,%ecx
  800a69:	83 e9 57             	sub    $0x57,%ecx
  800a6c:	eb 0e                	jmp    800a7c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a6e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 12                	ja     800a88 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a76:	0f be c9             	movsbl %cl,%ecx
  800a79:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a7c:	39 f1                	cmp    %esi,%ecx
  800a7e:	7d 0c                	jge    800a8c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a80:	42                   	inc    %edx
  800a81:	0f af c6             	imul   %esi,%eax
  800a84:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a86:	eb c4                	jmp    800a4c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a88:	89 c1                	mov    %eax,%ecx
  800a8a:	eb 02                	jmp    800a8e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a8c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a92:	74 05                	je     800a99 <strtol+0xbd>
		*endptr = (char *) s;
  800a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a97:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	74 04                	je     800aa1 <strtol+0xc5>
  800a9d:	89 c8                	mov    %ecx,%eax
  800a9f:	f7 d8                	neg    %eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    
	...

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	b8 03 00 00 00       	mov    $0x3,%eax
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 28                	jle    800b2f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b12:	00 
  800b13:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800b1a:	00 
  800b1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b22:	00 
  800b23:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800b2a:	e8 65 06 00 00       	call   801194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2f:	83 c4 2c             	add    $0x2c,%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 02 00 00 00       	mov    $0x2,%eax
  800b47:	89 d1                	mov    %edx,%ecx
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	89 d7                	mov    %edx,%edi
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_yield>:

void
sys_yield(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	be 00 00 00 00       	mov    $0x0,%esi
  800b83:	b8 04 00 00 00       	mov    $0x4,%eax
  800b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 f7                	mov    %esi,%edi
  800b93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7e 28                	jle    800bc1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ba4:	00 
  800ba5:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800bac:	00 
  800bad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb4:	00 
  800bb5:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800bbc:	e8 d3 05 00 00       	call   801194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc1:	83 c4 2c             	add    $0x2c,%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7e 28                	jle    800c14 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bf7:	00 
  800bf8:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800bff:	00 
  800c00:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c07:	00 
  800c08:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800c0f:	e8 80 05 00 00       	call   801194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	83 c4 2c             	add    $0x2c,%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	89 de                	mov    %ebx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 28                	jle    800c67 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c43:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800c52:	00 
  800c53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5a:	00 
  800c5b:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800c62:	e8 2d 05 00 00       	call   801194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c67:	83 c4 2c             	add    $0x2c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 28                	jle    800cba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c96:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cad:	00 
  800cae:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800cb5:	e8 da 04 00 00       	call   801194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	83 c4 2c             	add    $0x2c,%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800d08:	e8 87 04 00 00       	call   801194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	be 00 00 00 00       	mov    $0x0,%esi
  800d20:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d25:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	89 cb                	mov    %ecx,%ebx
  800d50:	89 cf                	mov    %ecx,%edi
  800d52:	89 ce                	mov    %ecx,%esi
  800d54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 28                	jle    800d82 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d65:	00 
  800d66:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d75:	00 
  800d76:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800d7d:	e8 12 04 00 00       	call   801194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d82:	83 c4 2c             	add    $0x2c,%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    
	...

00800d8c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 24             	sub    $0x24,%esp
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d96:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800d98:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d9c:	75 20                	jne    800dbe <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800d9e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800da2:	c7 44 24 08 10 18 80 	movl   $0x801810,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  800db9:	e8 d6 03 00 00       	call   801194 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800dbe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800dc4:	89 d8                	mov    %ebx,%eax
  800dc6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800dc9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd0:	f6 c4 08             	test   $0x8,%ah
  800dd3:	75 1c                	jne    800df1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800dd5:	c7 44 24 08 40 18 80 	movl   $0x801840,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  800dec:	e8 a3 03 00 00       	call   801194 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800df1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800df8:	00 
  800df9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e00:	00 
  800e01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e08:	e8 68 fd ff ff       	call   800b75 <sys_page_alloc>
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	79 20                	jns    800e31 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800e11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e15:	c7 44 24 08 9a 18 80 	movl   $0x80189a,0x8(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800e24:	00 
  800e25:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  800e2c:	e8 63 03 00 00       	call   801194 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800e31:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e38:	00 
  800e39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e3d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e44:	e8 b3 fa ff ff       	call   8008fc <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800e49:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e50:	00 
  800e51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e6c:	e8 58 fd ff ff       	call   800bc9 <sys_page_map>
  800e71:	85 c0                	test   %eax,%eax
  800e73:	79 20                	jns    800e95 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800e75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e79:	c7 44 24 08 ad 18 80 	movl   $0x8018ad,0x8(%esp)
  800e80:	00 
  800e81:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800e88:	00 
  800e89:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  800e90:	e8 ff 02 00 00       	call   801194 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800e95:	83 c4 24             	add    $0x24,%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800ea4:	c7 04 24 8c 0d 80 00 	movl   $0x800d8c,(%esp)
  800eab:	e8 3c 03 00 00       	call   8011ec <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb0:	ba 07 00 00 00       	mov    $0x7,%edx
  800eb5:	89 d0                	mov    %edx,%eax
  800eb7:	cd 30                	int    $0x30
  800eb9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ebc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 20                	jns    800ee3 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800ec3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec7:	c7 44 24 08 be 18 80 	movl   $0x8018be,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  800ede:	e8 b1 02 00 00       	call   801194 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  800ee3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ee7:	75 25                	jne    800f0e <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee9:	e8 49 fc ff ff       	call   800b37 <sys_getenvid>
  800eee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800efa:	c1 e0 07             	shl    $0x7,%eax
  800efd:	29 d0                	sub    %edx,%eax
  800eff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f04:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f09:	e9 58 02 00 00       	jmp    801166 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  800f0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f13:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800f18:	89 f0                	mov    %esi,%eax
  800f1a:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f1d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f24:	a8 01                	test   $0x1,%al
  800f26:	0f 84 7a 01 00 00    	je     8010a6 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800f2c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f33:	a8 01                	test   $0x1,%al
  800f35:	0f 84 6b 01 00 00    	je     8010a6 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800f3b:	a1 04 20 80 00       	mov    0x802004,%eax
  800f40:	8b 40 48             	mov    0x48(%eax),%eax
  800f43:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  800f46:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f4d:	f6 c4 04             	test   $0x4,%ah
  800f50:	74 52                	je     800fa4 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800f52:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f59:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f62:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f69:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f74:	89 04 24             	mov    %eax,(%esp)
  800f77:	e8 4d fc ff ff       	call   800bc9 <sys_page_map>
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	0f 89 22 01 00 00    	jns    8010a6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  800f84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f88:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  800f8f:	00 
  800f90:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f97:	00 
  800f98:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  800f9f:	e8 f0 01 00 00       	call   801194 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  800fa4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fab:	f6 c4 08             	test   $0x8,%ah
  800fae:	75 0f                	jne    800fbf <fork+0x124>
  800fb0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb7:	a8 02                	test   $0x2,%al
  800fb9:	0f 84 99 00 00 00    	je     801058 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  800fbf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc6:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  800fc9:	83 f8 01             	cmp    $0x1,%eax
  800fcc:	19 db                	sbb    %ebx,%ebx
  800fce:	83 e3 fc             	and    $0xfffffffc,%ebx
  800fd1:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  800fd7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fed:	89 04 24             	mov    %eax,(%esp)
  800ff0:	e8 d4 fb ff ff       	call   800bc9 <sys_page_map>
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 20                	jns    801019 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  800ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ffd:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  801014:	e8 7b 01 00 00       	call   801194 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801019:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80101d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801024:	89 44 24 08          	mov    %eax,0x8(%esp)
  801028:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80102c:	89 04 24             	mov    %eax,(%esp)
  80102f:	e8 95 fb ff ff       	call   800bc9 <sys_page_map>
  801034:	85 c0                	test   %eax,%eax
  801036:	79 6e                	jns    8010a6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801038:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103c:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  801053:	e8 3c 01 00 00       	call   801194 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801058:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105f:	25 07 0e 00 00       	and    $0xe07,%eax
  801064:	89 44 24 10          	mov    %eax,0x10(%esp)
  801068:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80106f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801073:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107a:	89 04 24             	mov    %eax,(%esp)
  80107d:	e8 47 fb ff ff       	call   800bc9 <sys_page_map>
  801082:	85 c0                	test   %eax,%eax
  801084:	79 20                	jns    8010a6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801086:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108a:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801091:	00 
  801092:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801099:	00 
  80109a:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  8010a1:	e8 ee 00 00 00       	call   801194 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8010a6:	46                   	inc    %esi
  8010a7:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010ad:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010b3:	0f 85 5f fe ff ff    	jne    800f18 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8010b9:	c7 44 24 04 8c 12 80 	movl   $0x80128c,0x4(%esp)
  8010c0:	00 
  8010c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010c4:	89 04 24             	mov    %eax,(%esp)
  8010c7:	e8 f6 fb ff ff       	call   800cc2 <sys_env_set_pgfault_upcall>
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 20                	jns    8010f0 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8010d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d4:	c7 44 24 08 70 18 80 	movl   $0x801870,0x8(%esp)
  8010db:	00 
  8010dc:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  8010eb:	e8 a4 00 00 00       	call   801194 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  8010f0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010ff:	ee 
  801100:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	e8 6a fa ff ff       	call   800b75 <sys_page_alloc>
  80110b:	85 c0                	test   %eax,%eax
  80110d:	79 20                	jns    80112f <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80110f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801113:	c7 44 24 08 9a 18 80 	movl   $0x80189a,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  80112a:	e8 65 00 00 00       	call   801194 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80112f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801136:	00 
  801137:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80113a:	89 04 24             	mov    %eax,(%esp)
  80113d:	e8 2d fb ff ff       	call   800c6f <sys_env_set_status>
  801142:	85 c0                	test   %eax,%eax
  801144:	79 20                	jns    801166 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801146:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114a:	c7 44 24 08 e0 18 80 	movl   $0x8018e0,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801159:	00 
  80115a:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  801161:	e8 2e 00 00 00       	call   801194 <_panic>
	}
	
	return envid;
}
  801166:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801169:	83 c4 3c             	add    $0x3c,%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <sfork>:

// Challenge!
int
sfork(void)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801177:	c7 44 24 08 f7 18 80 	movl   $0x8018f7,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 8f 18 80 00 	movl   $0x80188f,(%esp)
  80118e:	e8 01 00 00 00       	call   801194 <_panic>
	...

00801194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80119c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80119f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011a5:	e8 8d f9 ff ff       	call   800b37 <sys_getenvid>
  8011aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c0:	c7 04 24 10 19 80 00 	movl   $0x801910,(%esp)
  8011c7:	e8 ec ef ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d3:	89 04 24             	mov    %eax,(%esp)
  8011d6:	e8 7c ef ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  8011db:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  8011e2:	e8 d1 ef ff ff       	call   8001b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011e7:	cc                   	int3   
  8011e8:	eb fd                	jmp    8011e7 <_panic+0x53>
	...

008011ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011f2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8011f9:	0f 85 80 00 00 00    	jne    80127f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8011ff:	a1 04 20 80 00       	mov    0x802004,%eax
  801204:	8b 40 48             	mov    0x48(%eax),%eax
  801207:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80120e:	00 
  80120f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801216:	ee 
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	e8 56 f9 ff ff       	call   800b75 <sys_page_alloc>
  80121f:	85 c0                	test   %eax,%eax
  801221:	79 20                	jns    801243 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  801223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801227:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  80122e:	00 
  80122f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801236:	00 
  801237:	c7 04 24 90 19 80 00 	movl   $0x801990,(%esp)
  80123e:	e8 51 ff ff ff       	call   801194 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  801243:	a1 04 20 80 00       	mov    0x802004,%eax
  801248:	8b 40 48             	mov    0x48(%eax),%eax
  80124b:	c7 44 24 04 8c 12 80 	movl   $0x80128c,0x4(%esp)
  801252:	00 
  801253:	89 04 24             	mov    %eax,(%esp)
  801256:	e8 67 fa ff ff       	call   800cc2 <sys_env_set_pgfault_upcall>
  80125b:	85 c0                	test   %eax,%eax
  80125d:	79 20                	jns    80127f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80125f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801263:	c7 44 24 08 60 19 80 	movl   $0x801960,0x8(%esp)
  80126a:	00 
  80126b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801272:	00 
  801273:	c7 04 24 90 19 80 00 	movl   $0x801990,(%esp)
  80127a:	e8 15 ff ff ff       	call   801194 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801287:	c9                   	leave  
  801288:	c3                   	ret    
  801289:	00 00                	add    %al,(%eax)
	...

0080128c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80128c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80128d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801292:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801294:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  801297:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80129b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80129d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8012a0:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8012a1:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8012a4:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8012a6:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8012a9:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8012aa:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8012ad:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012ae:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8012af:	c3                   	ret    

008012b0 <__udivdi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	83 ec 10             	sub    $0x10,%esp
  8012b6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012ba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8012c6:	89 cd                	mov    %ecx,%ebp
  8012c8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	75 2c                	jne    8012fc <__udivdi3+0x4c>
  8012d0:	39 f9                	cmp    %edi,%ecx
  8012d2:	77 68                	ja     80133c <__udivdi3+0x8c>
  8012d4:	85 c9                	test   %ecx,%ecx
  8012d6:	75 0b                	jne    8012e3 <__udivdi3+0x33>
  8012d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8012dd:	31 d2                	xor    %edx,%edx
  8012df:	f7 f1                	div    %ecx
  8012e1:	89 c1                	mov    %eax,%ecx
  8012e3:	31 d2                	xor    %edx,%edx
  8012e5:	89 f8                	mov    %edi,%eax
  8012e7:	f7 f1                	div    %ecx
  8012e9:	89 c7                	mov    %eax,%edi
  8012eb:	89 f0                	mov    %esi,%eax
  8012ed:	f7 f1                	div    %ecx
  8012ef:	89 c6                	mov    %eax,%esi
  8012f1:	89 f0                	mov    %esi,%eax
  8012f3:	89 fa                	mov    %edi,%edx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    
  8012fc:	39 f8                	cmp    %edi,%eax
  8012fe:	77 2c                	ja     80132c <__udivdi3+0x7c>
  801300:	0f bd f0             	bsr    %eax,%esi
  801303:	83 f6 1f             	xor    $0x1f,%esi
  801306:	75 4c                	jne    801354 <__udivdi3+0xa4>
  801308:	39 f8                	cmp    %edi,%eax
  80130a:	bf 00 00 00 00       	mov    $0x0,%edi
  80130f:	72 0a                	jb     80131b <__udivdi3+0x6b>
  801311:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801315:	0f 87 ad 00 00 00    	ja     8013c8 <__udivdi3+0x118>
  80131b:	be 01 00 00 00       	mov    $0x1,%esi
  801320:	89 f0                	mov    %esi,%eax
  801322:	89 fa                	mov    %edi,%edx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
  80132b:	90                   	nop
  80132c:	31 ff                	xor    %edi,%edi
  80132e:	31 f6                	xor    %esi,%esi
  801330:	89 f0                	mov    %esi,%eax
  801332:	89 fa                	mov    %edi,%edx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    
  80133b:	90                   	nop
  80133c:	89 fa                	mov    %edi,%edx
  80133e:	89 f0                	mov    %esi,%eax
  801340:	f7 f1                	div    %ecx
  801342:	89 c6                	mov    %eax,%esi
  801344:	31 ff                	xor    %edi,%edi
  801346:	89 f0                	mov    %esi,%eax
  801348:	89 fa                	mov    %edi,%edx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	5e                   	pop    %esi
  80134e:	5f                   	pop    %edi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    
  801351:	8d 76 00             	lea    0x0(%esi),%esi
  801354:	89 f1                	mov    %esi,%ecx
  801356:	d3 e0                	shl    %cl,%eax
  801358:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135c:	b8 20 00 00 00       	mov    $0x20,%eax
  801361:	29 f0                	sub    %esi,%eax
  801363:	89 ea                	mov    %ebp,%edx
  801365:	88 c1                	mov    %al,%cl
  801367:	d3 ea                	shr    %cl,%edx
  801369:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80136d:	09 ca                	or     %ecx,%edx
  80136f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801373:	89 f1                	mov    %esi,%ecx
  801375:	d3 e5                	shl    %cl,%ebp
  801377:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80137b:	89 fd                	mov    %edi,%ebp
  80137d:	88 c1                	mov    %al,%cl
  80137f:	d3 ed                	shr    %cl,%ebp
  801381:	89 fa                	mov    %edi,%edx
  801383:	89 f1                	mov    %esi,%ecx
  801385:	d3 e2                	shl    %cl,%edx
  801387:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80138b:	88 c1                	mov    %al,%cl
  80138d:	d3 ef                	shr    %cl,%edi
  80138f:	09 d7                	or     %edx,%edi
  801391:	89 f8                	mov    %edi,%eax
  801393:	89 ea                	mov    %ebp,%edx
  801395:	f7 74 24 08          	divl   0x8(%esp)
  801399:	89 d1                	mov    %edx,%ecx
  80139b:	89 c7                	mov    %eax,%edi
  80139d:	f7 64 24 0c          	mull   0xc(%esp)
  8013a1:	39 d1                	cmp    %edx,%ecx
  8013a3:	72 17                	jb     8013bc <__udivdi3+0x10c>
  8013a5:	74 09                	je     8013b0 <__udivdi3+0x100>
  8013a7:	89 fe                	mov    %edi,%esi
  8013a9:	31 ff                	xor    %edi,%edi
  8013ab:	e9 41 ff ff ff       	jmp    8012f1 <__udivdi3+0x41>
  8013b0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013b4:	89 f1                	mov    %esi,%ecx
  8013b6:	d3 e2                	shl    %cl,%edx
  8013b8:	39 c2                	cmp    %eax,%edx
  8013ba:	73 eb                	jae    8013a7 <__udivdi3+0xf7>
  8013bc:	8d 77 ff             	lea    -0x1(%edi),%esi
  8013bf:	31 ff                	xor    %edi,%edi
  8013c1:	e9 2b ff ff ff       	jmp    8012f1 <__udivdi3+0x41>
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	31 f6                	xor    %esi,%esi
  8013ca:	e9 22 ff ff ff       	jmp    8012f1 <__udivdi3+0x41>
	...

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	83 ec 20             	sub    $0x20,%esp
  8013d6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013da:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8013de:	89 44 24 14          	mov    %eax,0x14(%esp)
  8013e2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013ea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8013ee:	89 c7                	mov    %eax,%edi
  8013f0:	89 f2                	mov    %esi,%edx
  8013f2:	85 ed                	test   %ebp,%ebp
  8013f4:	75 16                	jne    80140c <__umoddi3+0x3c>
  8013f6:	39 f1                	cmp    %esi,%ecx
  8013f8:	0f 86 a6 00 00 00    	jbe    8014a4 <__umoddi3+0xd4>
  8013fe:	f7 f1                	div    %ecx
  801400:	89 d0                	mov    %edx,%eax
  801402:	31 d2                	xor    %edx,%edx
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    
  80140b:	90                   	nop
  80140c:	39 f5                	cmp    %esi,%ebp
  80140e:	0f 87 ac 00 00 00    	ja     8014c0 <__umoddi3+0xf0>
  801414:	0f bd c5             	bsr    %ebp,%eax
  801417:	83 f0 1f             	xor    $0x1f,%eax
  80141a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141e:	0f 84 a8 00 00 00    	je     8014cc <__umoddi3+0xfc>
  801424:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801428:	d3 e5                	shl    %cl,%ebp
  80142a:	bf 20 00 00 00       	mov    $0x20,%edi
  80142f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801433:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801437:	89 f9                	mov    %edi,%ecx
  801439:	d3 e8                	shr    %cl,%eax
  80143b:	09 e8                	or     %ebp,%eax
  80143d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801441:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801445:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801449:	d3 e0                	shl    %cl,%eax
  80144b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144f:	89 f2                	mov    %esi,%edx
  801451:	d3 e2                	shl    %cl,%edx
  801453:	8b 44 24 14          	mov    0x14(%esp),%eax
  801457:	d3 e0                	shl    %cl,%eax
  801459:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80145d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801461:	89 f9                	mov    %edi,%ecx
  801463:	d3 e8                	shr    %cl,%eax
  801465:	09 d0                	or     %edx,%eax
  801467:	d3 ee                	shr    %cl,%esi
  801469:	89 f2                	mov    %esi,%edx
  80146b:	f7 74 24 18          	divl   0x18(%esp)
  80146f:	89 d6                	mov    %edx,%esi
  801471:	f7 64 24 0c          	mull   0xc(%esp)
  801475:	89 c5                	mov    %eax,%ebp
  801477:	89 d1                	mov    %edx,%ecx
  801479:	39 d6                	cmp    %edx,%esi
  80147b:	72 67                	jb     8014e4 <__umoddi3+0x114>
  80147d:	74 75                	je     8014f4 <__umoddi3+0x124>
  80147f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801483:	29 e8                	sub    %ebp,%eax
  801485:	19 ce                	sbb    %ecx,%esi
  801487:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80148b:	d3 e8                	shr    %cl,%eax
  80148d:	89 f2                	mov    %esi,%edx
  80148f:	89 f9                	mov    %edi,%ecx
  801491:	d3 e2                	shl    %cl,%edx
  801493:	09 d0                	or     %edx,%eax
  801495:	89 f2                	mov    %esi,%edx
  801497:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80149b:	d3 ea                	shr    %cl,%edx
  80149d:	83 c4 20             	add    $0x20,%esp
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    
  8014a4:	85 c9                	test   %ecx,%ecx
  8014a6:	75 0b                	jne    8014b3 <__umoddi3+0xe3>
  8014a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ad:	31 d2                	xor    %edx,%edx
  8014af:	f7 f1                	div    %ecx
  8014b1:	89 c1                	mov    %eax,%ecx
  8014b3:	89 f0                	mov    %esi,%eax
  8014b5:	31 d2                	xor    %edx,%edx
  8014b7:	f7 f1                	div    %ecx
  8014b9:	89 f8                	mov    %edi,%eax
  8014bb:	e9 3e ff ff ff       	jmp    8013fe <__umoddi3+0x2e>
  8014c0:	89 f2                	mov    %esi,%edx
  8014c2:	83 c4 20             	add    $0x20,%esp
  8014c5:	5e                   	pop    %esi
  8014c6:	5f                   	pop    %edi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    
  8014c9:	8d 76 00             	lea    0x0(%esi),%esi
  8014cc:	39 f5                	cmp    %esi,%ebp
  8014ce:	72 04                	jb     8014d4 <__umoddi3+0x104>
  8014d0:	39 f9                	cmp    %edi,%ecx
  8014d2:	77 06                	ja     8014da <__umoddi3+0x10a>
  8014d4:	89 f2                	mov    %esi,%edx
  8014d6:	29 cf                	sub    %ecx,%edi
  8014d8:	19 ea                	sbb    %ebp,%edx
  8014da:	89 f8                	mov    %edi,%eax
  8014dc:	83 c4 20             	add    $0x20,%esp
  8014df:	5e                   	pop    %esi
  8014e0:	5f                   	pop    %edi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    
  8014e3:	90                   	nop
  8014e4:	89 d1                	mov    %edx,%ecx
  8014e6:	89 c5                	mov    %eax,%ebp
  8014e8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8014ec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8014f0:	eb 8d                	jmp    80147f <__umoddi3+0xaf>
  8014f2:	66 90                	xchg   %ax,%ax
  8014f4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8014f8:	72 ea                	jb     8014e4 <__umoddi3+0x114>
  8014fa:	89 f1                	mov    %esi,%ecx
  8014fc:	eb 81                	jmp    80147f <__umoddi3+0xaf>
